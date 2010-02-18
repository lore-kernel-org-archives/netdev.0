From: Sridhar Samudrala <sri@us.ibm.com>
Subject: Re: [PATCH net-next-2.6] macvtap: Add GSO/csum offload support
Date: Thu, 18 Feb 2010 12:03:43 -0800
Message-ID: <1266523423.15681.24.camel@w-sridhar.beaverton.ibm.com>
References: <1266013667.6105.18.camel@w-sridhar.beaverton.ibm.com>
	 <201002181710.45121.arnd@arndb.de>
Mime-Version: 1.0
Content-Type: text/plain
Content-Transfer-Encoding: 7bit
Cc: David Miller <davem@davemloft.net>,
	Herbert Xu <herbert@gondor.apana.org.au>,
	netdev <netdev@vger.kernel.org>
To: Arnd Bergmann <arnd@arndb.de>
Return-path: <netdev-owner@vger.kernel.org>
Received: from e2.ny.us.ibm.com ([32.97.182.142]:53971 "EHLO e2.ny.us.ibm.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1752683Ab0BRUDv (ORCPT <rfc822;netdev@vger.kernel.org>);
	Thu, 18 Feb 2010 15:03:51 -0500
Received: from d01relay06.pok.ibm.com (d01relay06.pok.ibm.com [9.56.227.116])
	by e2.ny.us.ibm.com (8.14.3/8.13.1) with ESMTP id o1IJrloW029909
	for <netdev@vger.kernel.org>; Thu, 18 Feb 2010 14:53:47 -0500
Received: from d01av04.pok.ibm.com (d01av04.pok.ibm.com [9.56.224.64])
	by d01relay06.pok.ibm.com (8.13.8/8.13.8/NCO v10.0) with ESMTP id o1IK3lBE1794160
	for <netdev@vger.kernel.org>; Thu, 18 Feb 2010 15:03:47 -0500
Received: from d01av04.pok.ibm.com (loopback [127.0.0.1])
	by d01av04.pok.ibm.com (8.14.3/8.13.1/NCO v10.0 AVout) with ESMTP id o1IK3jSM005813
	for <netdev@vger.kernel.org>; Thu, 18 Feb 2010 15:03:46 -0500
In-Reply-To: <201002181710.45121.arnd@arndb.de>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Thu, 2010-02-18 at 17:10 +0100, Arnd Bergmann wrote:
> On Friday 12 February 2010, Sridhar Samudrala wrote:
> > This patch adds GSO/checksum offload support to macvtap driver and applies
> > on top of Arnd's refcnt bugfix.
> > 	http://patchwork.ozlabs.org/patch/45136/
> > 
> > Added flags field to macvtap_queue to enable/disable processing of
> > virtio_net_hdr via IFF_VNET_HDR. This flag is checked to prepend virtio_net_hdr
> > in the receive path and process/skip virtio_net_hdr in the send path.
> > 
> > Signed-off-by: Sridhar Samudrala <sri@us.ibm.com>
> 
> I've just sent out the new version of this, with further changes from
> myself and rebased on my vhost-net series. Here are some more comments
> about stuff that I changed in the process and why:
> 
> >  /* Get packet from user space buffer */
> >  static ssize_t macvtap_get_user(struct macvtap_queue *q,
> >  				const struct iovec *iv, size_t count,
> > @@ -336,31 +362,99 @@ static ssize_t macvtap_get_user(struct macvtap_queue *q,
> >  	struct sk_buff *skb;
> >  	size_t len = count;
> >  	int err;
> > +	struct virtio_net_hdr vnet_hdr = { 0 };
> > +	int vnet_hdr_len = 0;
> > +	unsigned short gso_type = 0;
> > +
> > +	if (q->flags & IFF_VNET_HDR) {
> > +		vnet_hdr_len = sizeof(vnet_hdr); 
> > +
> > +		err = -EINVAL;
> > +		if ((len -= vnet_hdr_len) < 0)
> > +			goto out;
> > +
> > +		err = (memcpy_fromiovecend((void *)&vnet_hdr, iv, 0,
> > +					   vnet_hdr_len));
> > +		if (err < 0)
> > +			goto out;			
> > +
> > +		if ((vnet_hdr.flags & VIRTIO_NET_HDR_F_NEEDS_CSUM) &&
> > +		     vnet_hdr.csum_start + vnet_hdr.csum_offset + 2 > 
> > +							vnet_hdr.hdr_len)
> > +			vnet_hdr.hdr_len = vnet_hdr.csum_start +
> > +						vnet_hdr.csum_offset + 2;
> > +
> > +		err = -EINVAL;
> > +		if (vnet_hdr.hdr_len > len)
> > +			goto out;
> > +
> > +		if (vnet_hdr.gso_type != VIRTIO_NET_HDR_GSO_NONE) {
> > +			switch (vnet_hdr.gso_type & ~VIRTIO_NET_HDR_GSO_ECN) {
> > +			case VIRTIO_NET_HDR_GSO_TCPV4:
> > +				gso_type = SKB_GSO_TCPV4;
> > +				break;
> > +			case VIRTIO_NET_HDR_GSO_TCPV6:
> > +				gso_type = SKB_GSO_TCPV6;
> > +				break;
> > +			case VIRTIO_NET_HDR_GSO_UDP:
> > +				gso_type = SKB_GSO_UDP;
> > +				break;
> > +			default:
> > +				goto out;
> > +			}
> > +
> > +			if (vnet_hdr.gso_type & VIRTIO_NET_HDR_GSO_ECN)
> > +				gso_type |= SKB_GSO_TCP_ECN;
> > +               
> > +			if (vnet_hdr.gso_size == 0)
> > +				goto out;
> > +		}
> > +	}
> 
> I've moved most of this to a separate function. The function was getting
> far too complex to read, and splitting it out makes it possible to move
> it into a common location later so it can also be used by the tun/tap
> driver that does basically the same here.

Yes. I agree. We could share this code with tap and af_packet socket
offload too.

> >  
> >  	macvlan_start_xmit(skb, q->vlan->dev);
> >  
> > +	macvlan_count_rx(q->vlan, skb->len, 1, 0);
> >  	return count;
> > +
> > +out_free:
> > +	kfree_skb(skb);
> > +out:
> > +	macvlan_count_rx(q->vlan, 0, false, false);
> > +	return -EINVAL;
> >  }
> 
> macvlan_count_rx() is really the wrong thing to do here, since we're
> transmitting the data, not receiving it. On success, the accounting will
> be done by macvlan_start_xmit, and I've added a corresponding tx_dropped
> count in the failure path.

OK.
>   
> >  static ssize_t macvtap_aio_write(struct kiocb *iocb, const struct iovec *iv,
> > @@ -387,14 +481,54 @@ static ssize_t macvtap_put_user(struct macvtap_queue *q,
> >  {
> >  	struct macvlan_dev *vlan = q->vlan;
> >  	int ret;
> > +	int vnet_hdr_len = 0;
> > +
> > +	if (q->flags & IFF_VNET_HDR) {
> > +		struct virtio_net_hdr vnet_hdr = { 0 };
> > +
> > +		vnet_hdr_len = sizeof(vnet_hdr);
> > +		if ((len -= vnet_hdr_len) < 0)
> > +			return -EINVAL;
> > +
> > +		if (skb_is_gso(skb)) {
> > +			struct skb_shared_info *sinfo = skb_shinfo(skb);
> > +
> > +			/* This is a hint as to how much should be linear. */
> > +			vnet_hdr.hdr_len = skb_headlen(skb);
> > +			vnet_hdr.gso_size = sinfo->gso_size;
> > +			if (sinfo->gso_type & SKB_GSO_TCPV4)
> > +				vnet_hdr.gso_type = VIRTIO_NET_HDR_GSO_TCPV4;
> > +			else if (sinfo->gso_type & SKB_GSO_TCPV6)
> > +				vnet_hdr.gso_type = VIRTIO_NET_HDR_GSO_TCPV6;
> > +			else if (sinfo->gso_type & SKB_GSO_UDP)
> > +				vnet_hdr.gso_type = VIRTIO_NET_HDR_GSO_UDP;
> > +			else
> > +				BUG();
> > +			if (sinfo->gso_type & SKB_GSO_TCP_ECN)
> > +				vnet_hdr.gso_type |= VIRTIO_NET_HDR_GSO_ECN;
> > +		} else
> > +			vnet_hdr.gso_type = VIRTIO_NET_HDR_GSO_NONE;
> > +
> > +		if (skb->ip_summed == CHECKSUM_PARTIAL) {
> > +			vnet_hdr.flags = VIRTIO_NET_HDR_F_NEEDS_CSUM;
> > +			vnet_hdr.csum_start = skb->csum_start -
> > +						skb_headroom(skb);
> > +			vnet_hdr.csum_offset = skb->csum_offset;
> > +		} /* else everything is zero */
> > +
> > +		if (unlikely(memcpy_toiovecend(iv, (void *)&vnet_hdr, 0,
> > +								vnet_hdr_len)))
> > +			return -EFAULT;
> > +	}
> > +
> 
> This code is now also a separate function, same reason as above.
> 
> >  	case TUNSETOFFLOAD:
> > -		/* let the user check for future flags */
> > -		if (arg & ~(TUN_F_CSUM | TUN_F_TSO4 | TUN_F_TSO6 |
> > -			  TUN_F_TSO_ECN | TUN_F_UFO))
> > -			return -EINVAL;
> > -
> > -		/* TODO: add support for these, so far we don't
> > -			 support any offload */
> > -		if (arg & (TUN_F_CSUM | TUN_F_TSO4 | TUN_F_TSO6 |
> > -			 TUN_F_TSO_ECN | TUN_F_UFO))
> > -			return -EINVAL;
> > -
> > -		return 0;
> > +		q = macvtap_file_get_queue(file);
> > +		if (!q)
> > +			return -ENOLINK;
> > +		ret = 0;
> > +		if (!(q->flags & IFF_VNET_HDR))
> > +			ret =  -EINVAL;
> > +		macvtap_file_put_queue(q);
> > +		return ret;
> 
> I still feel uncomfortable about this, but partly because I don't fully
> understand the GSO functionality. I've added a comment for now so we can
> have another look.
> 
> macvtap is different from tun/tap here, because the data direction is the
> opposite: reading from a macvtap chardev corresponds to receive, while
> writing to it is a transmit in the network stack. In the tap driver, we
> just set the GSO flags of the netdev and dev_queue_xmit will do the right
> thing when forwarding data to the tap, but for macvtap, incoming frames
> never go through dev_queue_xmit (they go through netif_rx), so if the
> external device passes us GSO frames, we just pass them on unmodified
> to the guest, even if that guest does not understand GSO.

If a guest is connected to a macvtap device attached to an underlying physical
device with GRO enabled, it is possible to receive large SKBs and we don't handle
them correctly. The current workaround is to disable GRO on the physical device.

> 
> In particular, when we have two guests using macvtap in bridge mode,
> we don't even go through the network stack and just pass down the
> SKB we got from the other side if the destination MAC address matches.
> That means that a sender using virtio-net with GSO will send garbage
> to another guest using a hardware emulated NIC that cannot receive
> GSO (GRO?) frames.

Yes. I think we need to do something similar to dev_gso_segment() in
macvtap_forward() if skb_is_gso() and IFF_VNET_HDR is not set in
q->flags.

> 
> I hope you have an idea how to do this right or can convince me that
> everything is ok, otherwise we'd have to defer this patch.

I would prefer getting this patch in as it helps peformance when both
the guest and the physical device support offloads and also we have 
workaround for other situations. In the meantime, I will start looking
into addressing this specific case in macvtap_forward().

Thanks
Sridhar

