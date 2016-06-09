From: Gerard Garcia <ggarcia@abra.uab.cat>
Subject: Re: [RFC 3/3] vsockmon: Add vsock hooks
Date: Thu, 9 Jun 2016 17:27:20 +0200
Message-ID: <25413306-7bee-9dec-11ed-4c5e25469166@deic.uab.cat>
References: <20160528162907.14809-1-ggarcia@deic.uab.cat>
 <20160528162907.14809-4-ggarcia@deic.uab.cat>
 <20160601211913.GH15594@stefanha-x1.localdomain>
Mime-Version: 1.0
Content-Type: text/plain; charset=windows-1252; format=flowed
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, jhansen@vmware.com
To: Stefan Hajnoczi <stefanha@redhat.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-wm0-f65.google.com ([74.125.82.65]:35887 "EHLO
	mail-wm0-f65.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S932543AbcFIP1X (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 9 Jun 2016 11:27:23 -0400
Received: by mail-wm0-f65.google.com with SMTP id m124so11535986wme.3
        for <netdev@vger.kernel.org>; Thu, 09 Jun 2016 08:27:22 -0700 (PDT)
In-Reply-To: <20160601211913.GH15594@stefanha-x1.localdomain>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>



On 06/01/2016 11:19 PM, Stefan Hajnoczi wrote:
> On Sat, May 28, 2016 at 06:29:07PM +0200, ggarcia@abra.uab.cat wrote:
>> From: Gerard Garcia <ggarcia@deic.uab.cat>
>>
>> Signed-off-by: Gerard Garcia <ggarcia@deic.uab.cat>
>> ---
>>   drivers/vhost/vsock.c | 71 +++++++++++++++++++++++++++++++++++++++++++++++++++
>>   1 file changed, 71 insertions(+)
>>
>> diff --git a/drivers/vhost/vsock.c b/drivers/vhost/vsock.c
>> index 17bfe4e..8fd5125 100644
>> --- a/drivers/vhost/vsock.c
>> +++ b/drivers/vhost/vsock.c
>> @@ -14,8 +14,10 @@
>>   #include <net/sock.h>
>>   #include <linux/virtio_vsock.h>
>>   #include <linux/vhost.h>
>> +#include <linux/skbuff.h>
>>   
>>   #include <net/af_vsock.h>
>> +#include <uapi/linux/vsockmon.h>
>>   #include "vhost.h"
>>   
>>   #define VHOST_VSOCK_DEFAULT_HOST_CID	2
>> @@ -45,6 +47,67 @@ struct vhost_vsock {
>>   	u32 guest_cid;
>>   };
>>   
>> +static struct sk_buff *
>> +virtio_vsock_pkt_to_skb(struct virtio_vsock_pkt *pkt)
>> +{
>> +	struct sk_buff *skb;
>> +	struct af_vsockmon_hdr *hdr;
>> +	void *payload;
>> +
>> +	u32 skb_len = sizeof(struct af_vsockmon_hdr) + pkt->len;
>> +
>> +	skb = alloc_skb(skb_len, GFP_ATOMIC);
>> +	if (!skb)
>> +		return NULL;
>> +
>> +	skb_reserve(skb, sizeof(struct af_vsockmon_hdr));
>> +
>> +	if (pkt->len) {
>> +		payload = skb_put(skb, pkt->len);
>> +		memcpy(payload, pkt->buf, pkt->len);
>> +	}
>> +
>> +	hdr = (struct af_vsockmon_hdr *) skb_push(skb, sizeof(*hdr));
>> +	hdr->type = AF_VSOCK_VIRTIO;
>> +
>> +	switch(pkt->hdr.op) {
>> +		case VIRTIO_VSOCK_OP_REQUEST:
>> +		case VIRTIO_VSOCK_OP_RESPONSE:
>> +			hdr->g_hdr.op = AF_VSOCK_G_OP_CONNECT;
>> +			break;
>> +		case VIRTIO_VSOCK_OP_RST:
>> +		case VIRTIO_VSOCK_OP_SHUTDOWN:
>> +			hdr->g_hdr.op = AF_VSOCK_G_OP_DISCONNECT;
>> +			break;
>> +		case VIRTIO_VSOCK_OP_RW:
>> +			hdr->g_hdr.op = AF_VSOCK_G_OP_PAYLOAD;
>> +			break;
>> +		case VIRTIO_VSOCK_OP_CREDIT_UPDATE:
>> +		case VIRTIO_VSOCK_OP_CREDIT_REQUEST:
>> +			hdr->g_hdr.op = AF_VSOCK_G_OP_CONTROL;
>> +			break;
>> +		default:
>> +			hdr->g_hdr.op = AF_VSOCK_G_OP_UNKNOWN;
>> +			break;
>> +	}
>> +
>> +	hdr->g_hdr.src_cid = pkt->hdr.src_cid;
>> +	hdr->g_hdr.src_port = pkt->hdr.src_port;
>> +	hdr->g_hdr.dst_cid = pkt->hdr.dst_cid;
>> +	hdr->g_hdr.dst_port = pkt->hdr.dst_port;
> Careful with endianness here.  pkt->hdr uses little-endian fields.
True, I have not considered this.
>> +
>> +	hdr->t_hdr.virtio_hdr = pkt->hdr;
>> +
>> +	return skb;
>> +}
>> +
>> +static void vsock_deliver_tap_pkt(struct virtio_vsock_pkt *pkt)
>> +{
>> +	struct sk_buff *skb = virtio_vsock_pkt_to_skb(pkt);
>> +	if (skb)
>> +		vsock_deliver_tap(skb);
> vsock_deliver_tap() doesn't take ownership of skb so it is leaked here!
>
> In fact, given that the core vsock code is not skb-based, perhaps the
> tap code shouldn't clone at all.  Just take ownership of the skb.  This
> avoids the extra allocation and memcpy.
>
You are right! and yes, I agree that would be better to avoid the clone. 
As you say I can just take ownership of the skb before dev_queue_xmit() 
in vsock_deliver_tap() so it won't be free'd after the call and avoid 
the clone.
>> +}
>> +
>>   static u32 vhost_transport_get_local_cid(void)
>>   {
>>   	return VHOST_VSOCK_DEFAULT_HOST_CID;
>> @@ -147,6 +210,11 @@ vhost_transport_do_send_pkt(struct vhost_vsock *vsock,
>>   
>>   		vsock->total_tx_buf -= pkt->len;
>>   
>> +		/* Deliver to monitoring devices all correctly transmitted
>> +		 * packets.
>> +		 */
>> +		vsock_deliver_tap_pkt(pkt);
>> +
>>   		virtio_transport_free_pkt(pkt);
>>   	}
>>   	if (added)
>> @@ -367,6 +435,9 @@ static void vhost_vsock_handle_tx_kick(struct vhost_work *work)
>>   			continue;
>>   		}
>>   
>> +		/* Deliver to monitoring devices all received packets */
>> +		vsock_deliver_tap_pkt(pkt);
>> +
>>   		/* Only accept correctly addressed packets */
>>   		if (le64_to_cpu(pkt->hdr.src_cid) == vsock->guest_cid)
>>   			virtio_transport_recv_pkt(pkt);
>> -- 
>> 2.8.3
>>
