From: Vitaly Kuznetsov <vkuznets@redhat.com>
Subject: Re: [PATCH V5 4/9] Drivers: hv: ring_buffer: enhance hv_ringbuffer_read() to support hvsock
Date: Tue, 05 Jan 2016 13:31:24 +0100
Message-ID: <87r3hw1a3n.fsf@vitty.brq.redhat.com>
References: <1450966476-13175-1-git-send-email-decui@microsoft.com>
Mime-Version: 1.0
Content-Type: text/plain
Cc: gregkh@linuxfoundation.org, davem@davemloft.net,
	stephen@networkplumber.org, netdev@vger.kernel.org,
	linux-kernel@vger.kernel.org,
	driverdev-devel@linuxdriverproject.org, olaf@aepfle.de,
	apw@canonical.com, jasowang@redhat.com, kys@microsoft.com,
	pebolle@tiscali.nl, stefanha@redhat.com, dan.carpenter@oracle.com
To: Dexuan Cui <decui@microsoft.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mx1.redhat.com ([209.132.183.28]:39219 "EHLO mx1.redhat.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1751722AbcAEMbc (ORCPT <rfc822;netdev@vger.kernel.org>);
	Tue, 5 Jan 2016 07:31:32 -0500
In-Reply-To: <1450966476-13175-1-git-send-email-decui@microsoft.com> (Dexuan
	Cui's message of "Thu, 24 Dec 2015 06:14:36 -0800")
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Dexuan Cui <decui@microsoft.com> writes:

> To get the payload of hvsock, we need raw=0 to skip the level-1 header
> (i.e., struct vmpacket_descriptor desc) and we also need to skip the
> level-2 header (i.e., struct vmpipe_proto_header pipe_hdr).
>
> NB: if the length of the hvsock payload is not aligned with the 8-byte
> boundeary, at most 7 padding bytes are appended, so the real hvsock
> payload's length must be retrieved by the pipe_hdr.data_size field.
>
> I 'upgrade' the 'raw' parameter of hv_ringbuffer_read() to a
> 'read_flags', trying to share the logic of the function.

When I was touching this code last time I was actually thinking about
eliminating 'raw' flag by making all ring reads raw and moving this
header filtering job to the upper layer (as we already have
vmbus_recvpacket()/vmbus_recvpacket_raw()) but for some reason I didn't
do it. I believe you have more or less the same reasoing for introducing
new read type instead of parsing this at a higher level. Some comments
below ...

>
> This patch is required by the next patch, which will introduce the hvsock
> send/recv APIs.
>
> Signed-off-by: Dexuan Cui <decui@microsoft.com>
> Cc: Vitaly Kuznetsov <vkuznets@redhat.com>
> ---
>  drivers/hv/channel.c      | 10 +++++----
>  drivers/hv/hyperv_vmbus.h | 13 +++++++++++-
>  drivers/hv/ring_buffer.c  | 54 ++++++++++++++++++++++++++++++++++++-----------
>  include/linux/hyperv.h    | 12 +++++++++++
>  4 files changed, 72 insertions(+), 17 deletions(-)
>
> diff --git a/drivers/hv/channel.c b/drivers/hv/channel.c
> index eaaa066..cc49966 100644
> --- a/drivers/hv/channel.c
> +++ b/drivers/hv/channel.c
> @@ -940,13 +940,14 @@ EXPORT_SYMBOL_GPL(vmbus_sendpacket_multipagebuffer);
>  static inline int
>  __vmbus_recvpacket(struct vmbus_channel *channel, void *buffer,
>  		   u32 bufferlen, u32 *buffer_actual_len, u64 *requestid,
> -		   bool raw)
> +		   u32 read_flags)
>  {
>  	int ret;
>  	bool signal = false;
>
>  	ret = hv_ringbuffer_read(&channel->inbound, buffer, bufferlen,
> -				 buffer_actual_len, requestid, &signal, raw);
> +				 buffer_actual_len, requestid, &signal,
> +				 read_flags);
>
>  	if (signal)
>  		vmbus_setevent(channel);
> @@ -959,7 +960,7 @@ int vmbus_recvpacket(struct vmbus_channel *channel, void *buffer,
>  		     u64 *requestid)
>  {
>  	return __vmbus_recvpacket(channel, buffer, bufferlen,
> -				  buffer_actual_len, requestid, false);
> +				  buffer_actual_len, requestid, 0);
>  }
>  EXPORT_SYMBOL(vmbus_recvpacket);
>
> @@ -971,6 +972,7 @@ int vmbus_recvpacket_raw(struct vmbus_channel *channel, void *buffer,
>  			      u64 *requestid)
>  {
>  	return __vmbus_recvpacket(channel, buffer, bufferlen,
> -				  buffer_actual_len, requestid, true);
> +				  buffer_actual_len, requestid,
> +				  HV_RINGBUFFER_READ_FLAG_RAW);
>  }
>  EXPORT_SYMBOL_GPL(vmbus_recvpacket_raw);
> diff --git a/drivers/hv/hyperv_vmbus.h b/drivers/hv/hyperv_vmbus.h
> index 0411b7b..46206b6 100644
> --- a/drivers/hv/hyperv_vmbus.h
> +++ b/drivers/hv/hyperv_vmbus.h
> @@ -619,9 +619,20 @@ int hv_ringbuffer_write(struct hv_ring_buffer_info *ring_info,
>  		    struct kvec *kv_list,
>  		    u32 kv_count, bool *signal);
>
> +/*
> + * By default, a read_flags of 0 means: the payload offset is
> + * sizeof(struct vmpacket_descriptor).
> + *
> + * If HV_RINGBUFFER_READ_FLAG_RAW is used, the payload offset is 0.
> + *
> + * If HV_RINGBUFFER_READ_FLAG_HVSOCK is used, the payload offset is
> + * sizeof(struct vmpacket_descriptor) + sizeof(struct
> vmpipe_proto_header).

So these are mutually exclusive, right? Should we introduce 'int
payload_offset' parameter instead of flags? 

> + */
> +#define HV_RINGBUFFER_READ_FLAG_RAW		(1 << 0)
> +#define HV_RINGBUFFER_READ_FLAG_HVSOCK		(1 << 1)
>  int hv_ringbuffer_read(struct hv_ring_buffer_info *inring_info,
>  		       void *buffer, u32 buflen, u32 *buffer_actual_len,
> -		       u64 *requestid, bool *signal, bool raw);
> +		       u64 *requestid, bool *signal, u32 read_flags);
>
>  void hv_ringbuffer_get_debuginfo(struct hv_ring_buffer_info *ring_info,
>  			    struct hv_ring_buffer_debug_info *debug_info);
> diff --git a/drivers/hv/ring_buffer.c b/drivers/hv/ring_buffer.c
> index b53702c..03a509c 100644
> --- a/drivers/hv/ring_buffer.c
> +++ b/drivers/hv/ring_buffer.c
> @@ -382,32 +382,43 @@ int hv_ringbuffer_write(struct hv_ring_buffer_info *outring_info,
>
>  int hv_ringbuffer_read(struct hv_ring_buffer_info *inring_info,
>  		       void *buffer, u32 buflen, u32 *buffer_actual_len,
> -		       u64 *requestid, bool *signal, bool raw)
> +		       u64 *requestid, bool *signal, u32 read_flags)
>  {
> +	bool raw = !!(read_flags & HV_RINGBUFFER_READ_FLAG_RAW);
> +	bool hvsock = !!(read_flags & HV_RINGBUFFER_READ_FLAG_HVSOCK);
> +
>  	u32 bytes_avail_towrite;
>  	u32 bytes_avail_toread;
>  	u32 next_read_location = 0;
>  	u64 prev_indices = 0;
>  	unsigned long flags;
> -	struct vmpacket_descriptor desc;
> +	struct vmpipe_proto_header *pipe_hdr;
> +	struct vmpacket_descriptor *desc;
>  	u32 offset;
> -	u32 packetlen;
> +	u32 packetlen, tot_hdrlen;
>  	int ret = 0;
>
>  	if (buflen <= 0)
>  		return -EINVAL;
>
> +	tot_hdrlen = sizeof(*desc);
> +	if (hvsock)
> +		tot_hdrlen += sizeof(*pipe_hdr);
> +
>  	spin_lock_irqsave(&inring_info->ring_lock, flags);
>
>  	*buffer_actual_len = 0;
> -	*requestid = 0;
> +
> +	/* If some driver doesn't need the info, a NULL is passed in. */
> +	if (requestid)
> +		*requestid = 0;
>
>  	hv_get_ringbuffer_availbytes(inring_info,
>  				&bytes_avail_toread,
>  				&bytes_avail_towrite);
>
>  	/* Make sure there is something to read */
> -	if (bytes_avail_toread < sizeof(desc)) {
> +	if (bytes_avail_toread < tot_hdrlen) {
>  		/*
>  		 * No error is set when there is even no header, drivers are
>  		 * supposed to analyze buffer_actual_len.
> @@ -415,17 +426,26 @@ int hv_ringbuffer_read(struct hv_ring_buffer_info *inring_info,
>  		goto out_unlock;
>  	}
>
> +	if (tot_hdrlen > buflen) {
> +		ret = -ENOBUFS;
> +		goto out_unlock;
> +	}
> +
> +	desc = (struct vmpacket_descriptor *)buffer;
> +
>  	next_read_location = hv_get_next_read_location(inring_info);
> -	next_read_location = hv_copyfrom_ringbuffer(inring_info, &desc,
> -						    sizeof(desc),
> +	next_read_location = hv_copyfrom_ringbuffer(inring_info, desc,
> +						    tot_hdrlen,
>  						    next_read_location);
> +	offset = 0;
> +	if (!raw)
> +		offset += (desc->offset8 << 3);
> +	if (hvsock)
> +		offset += sizeof(*pipe_hdr);

So in case of !raw and hvsock we add both offsets?

>
> -	offset = raw ? 0 : (desc.offset8 << 3);
> -	packetlen = (desc.len8 << 3) - offset;
> -	*buffer_actual_len = packetlen;
> -	*requestid = desc.trans_id;
> +	packetlen = (desc->len8 << 3) - offset;
>
> -	if (bytes_avail_toread < packetlen + offset) {
> +	if (bytes_avail_toread < (desc->len8 << 3)) {
>  		ret = -EAGAIN;
>  		goto out_unlock;
>  	}
> @@ -435,6 +455,16 @@ int hv_ringbuffer_read(struct hv_ring_buffer_info *inring_info,
>  		goto out_unlock;
>  	}
>
> +	if (requestid)
> +		*requestid = desc->trans_id;
> +
> +	if (!hvsock)
> +		*buffer_actual_len = packetlen;
> +	else {
> +		pipe_hdr = (struct vmpipe_proto_header *)(desc + 1);
> +		*buffer_actual_len = pipe_hdr->data_size;
> +	}
> +
>  	next_read_location =
>  		hv_get_next_readlocation_withoffset(inring_info, offset);
>
> diff --git a/include/linux/hyperv.h b/include/linux/hyperv.h
> index b835d80..e005223 100644
> --- a/include/linux/hyperv.h
> +++ b/include/linux/hyperv.h
> @@ -1268,4 +1268,16 @@ extern __u32 vmbus_proto_version;
>
>  int vmbus_send_tl_connect_request(const uuid_le *shv_guest_servie_id,
>  				  const uuid_le *shv_host_servie_id);
> +struct vmpipe_proto_header {
> +	u32 pkt_type;
> +
> +	union {
> +		u32 data_size;
> +		struct {
> +			u16 data_size;
> +			u16 offset;
> +		} partial;
> +	};
> +} __packed;
> +
>  #endif /* _HYPERV_H */

-- 
  Vitaly
