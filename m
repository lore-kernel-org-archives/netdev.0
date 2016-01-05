From: Dexuan Cui <decui@microsoft.com>
Subject: RE: [PATCH V5 4/9] Drivers: hv: ring_buffer: enhance
 hv_ringbuffer_read() to support hvsock
Date: Tue, 5 Jan 2016 15:41:20 +0000
Message-ID: <0684d7e3211c464cbfe303e80dcab4b4@HKXPR3004MB0088.064d.mgd.msft.net>
References: <1450966476-13175-1-git-send-email-decui@microsoft.com>
 <87r3hw1a3n.fsf@vitty.brq.redhat.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 8BIT
Cc: "gregkh@linuxfoundation.org" <gregkh@linuxfoundation.org>,
	"davem@davemloft.net" <davem@davemloft.net>,
	"stephen@networkplumber.org" <stephen@networkplumber.org>,
	"netdev@vger.kernel.org" <netdev@vger.kernel.org>,
	"linux-kernel@vger.kernel.org" <linux-kernel@vger.kernel.org>,
	"driverdev-devel@linuxdriverproject.org"
	<driverdev-devel@linuxdriverproject.org>,
	"olaf@aepfle.de" <olaf@aepfle.de>,
	"apw@canonical.com" <apw@canonical.com>,
	"jasowang@redhat.com" <jasowang@redhat.com>,
	KY Srinivasan <kys@microsoft.com>,
	"pebolle@tiscali.nl" <pebolle@tiscali.nl>,
	"stefanha@redhat.com" <stefanha@redhat.com>,
	"dan.carpenter@oracle.com" <dan.carpenter@oracle.com>
To: Vitaly Kuznetsov <vkuznets@redhat.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-bl2on0107.outbound.protection.outlook.com ([65.55.169.107]:46554
	"EHLO na01-bl2-obe.outbound.protection.outlook.com"
	rhost-flags-OK-OK-OK-FAIL) by vger.kernel.org with ESMTP
	id S1752462AbcAEPla convert rfc822-to-8bit (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 5 Jan 2016 10:41:30 -0500
In-Reply-To: <87r3hw1a3n.fsf@vitty.brq.redhat.com>
Content-Language: en-US
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

> From: Vitaly Kuznetsov [mailto:vkuznets@redhat.com]
> Sent: Tuesday, January 5, 2016 20:31
> ...
> > To get the payload of hvsock, we need raw=0 to skip the level-1 header
> > (i.e., struct vmpacket_descriptor desc) and we also need to skip the
> > level-2 header (i.e., struct vmpipe_proto_header pipe_hdr).
> >
> > NB: if the length of the hvsock payload is not aligned with the 8-byte
> > boundeary, at most 7 padding bytes are appended, so the real hvsock
> > payload's length must be retrieved by the pipe_hdr.data_size field.
> >
> > I 'upgrade' the 'raw' parameter of hv_ringbuffer_read() to a
> > 'read_flags', trying to share the logic of the function.
> 
> When I was touching this code last time I was actually thinking about
> eliminating 'raw' flag by making all ring reads raw and moving this
> header filtering job to the upper layer (as we already have
> vmbus_recvpacket()/vmbus_recvpacket_raw()) but for some reason I didn't
> do it. I believe you have more or less the same reasoing for introducing
> new read type instead of parsing this at a higher level. Some comments
> below ...

I feel it's more convenient to do the parsing in the vmbus driver than in
all the driver users of vmbus driver.

However, yes, I admit hv_ringbuffer_read() becomes less readable with
my introduction of 'read_flags'.

It may be a better idea to do the parsing in higher level, i.e., the hvsock driver,
in my case.
It looks I can avoid introducing vmbus_recvpacket_hvsock() and use 
vmbus_recvpacket() directly in my hvsock driver.

Let me try to make a new patch this way.

> > This patch is required by the next patch, which will introduce the hvsock
> > send/recv APIs.
> >
> > ...
> > @@ -619,9 +619,20 @@ int hv_ringbuffer_write(struct hv_ring_buffer_info
> *ring_info,
> >  		    struct kvec *kv_list,
> >  		    u32 kv_count, bool *signal);
> >
> > +/*
> > + * By default, a read_flags of 0 means: the payload offset is
> > + * sizeof(struct vmpacket_descriptor).
> > + *
> > + * If HV_RINGBUFFER_READ_FLAG_RAW is used, the payload offset is 0.
> > + *
> > + * If HV_RINGBUFFER_READ_FLAG_HVSOCK is used, the payload offset is
> > + * sizeof(struct vmpacket_descriptor) + sizeof(struct
> > vmpipe_proto_header).
> 
> So these are mutually exclusive, right? Should we introduce 'int
> payload_offset' parameter instead of flags?
Sorry for making the code less readable. :-)
As I mentioned above, let me try to do things in a better way.

> > @@ -415,17 +426,26 @@ int hv_ringbuffer_read(struct hv_ring_buffer_info
> *inring_info,
> >  		goto out_unlock;
> >  	}
> >
> > +	if (tot_hdrlen > buflen) {
> > +		ret = -ENOBUFS;
> > +		goto out_unlock;
> > +	}
> > +
> > +	desc = (struct vmpacket_descriptor *)buffer;
> > +
> >  	next_read_location = hv_get_next_read_location(inring_info);
> > -	next_read_location = hv_copyfrom_ringbuffer(inring_info, &desc,
> > -						    sizeof(desc),
> > +	next_read_location = hv_copyfrom_ringbuffer(inring_info, desc,
> > +						    tot_hdrlen,
> >  						    next_read_location);
> > +	offset = 0;
> > +	if (!raw)
> > +		offset += (desc->offset8 << 3);
> > +	if (hvsock)
> > +		offset += sizeof(*pipe_hdr);
> 
> So in case of !raw and hvsock we add both offsets?
Yes...
 
Thanks for you review, Vitaly.

Thanks,
-- Dexuan
