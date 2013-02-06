From: "Michael S. Tsirkin" <mst@redhat.com>
Subject: Re: regression caused by 1d2024f61ec14bdb0c57a97a3fe73685abc2d198?
Date: Wed, 6 Feb 2013 17:50:49 +0200
Message-ID: <20130206155049.GB14735@redhat.com>
References: <20130206114321.GA13497@redhat.com>
 <1360156059.28557.28.camel@edumazet-glaptop>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: alexander.h.duyck@intel.com, stephen.s.ko@intel.com,
	jeffrey.t.kirsher@intel.com, David Miller <davem@davemloft.net>,
	netdev@vger.kernel.org, sony.chacko@qlogic.com, mchan@broadcom.com,
	jitendra.kalsaria@qlogic.com, eilong@broadcom.com
To: Eric Dumazet <eric.dumazet@gmail.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mx1.redhat.com ([209.132.183.28]:40651 "EHLO mx1.redhat.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1754896Ab3BFQDa (ORCPT <rfc822;netdev@vger.kernel.org>);
	Wed, 6 Feb 2013 11:03:30 -0500
Content-Disposition: inline
In-Reply-To: <1360156059.28557.28.camel@edumazet-glaptop>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Wed, Feb 06, 2013 at 05:07:39AM -0800, Eric Dumazet wrote:
> On Wed, 2013-02-06 at 13:43 +0200, Michael S. Tsirkin wrote:
> > It seems that starting with kernel 3.3 ixgbe sets gso_size for
> > incoming frames. It seems that this might result in gso_size
> > being set even when gso_type is 0.
> > This in turn leads to a crash at macvtap_skb_to_vnet_hdr
> > drivers/net/macvtap.c:628
> > which has this code:
> > 
> >        if (skb_is_gso(skb)) {
> >                 struct skb_shared_info *sinfo = skb_shinfo(skb);
> > 
> >                 /* This is a hint as to how much should be linear. */
> >                 vnet_hdr->hdr_len = skb_headlen(skb);
> >                 vnet_hdr->gso_size = sinfo->gso_size;
> >                 if (sinfo->gso_type & SKB_GSO_TCPV4)
> >                         vnet_hdr->gso_type = VIRTIO_NET_HDR_GSO_TCPV4;
> >                 else if (sinfo->gso_type & SKB_GSO_TCPV6)
> >                         vnet_hdr->gso_type = VIRTIO_NET_HDR_GSO_TCPV6;
> >                 else if (sinfo->gso_type & SKB_GSO_UDP)
> >                         vnet_hdr->gso_type = VIRTIO_NET_HDR_GSO_UDP;
> >                 else
> >                         BUG();
> >                 if (sinfo->gso_type & SKB_GSO_TCP_ECN)
> >                         vnet_hdr->gso_type |= VIRTIO_NET_HDR_GSO_ECN;
> >         } else
> >                 vnet_hdr->gso_type = VIRTIO_NET_HDR_GSO_NONE;
> > 
> > 
> > Since skb_is_gso tests gso_size.
> > 
> > What's the right way to handle this? Should skb_is_gso be
> > changed to test gso_type != 0?
> > 
> 
> Or fix ixgbe to set gso_type in ixgbe_get_headlen(), as it does all the
> dissection.


Hmm, ixgbe_get_headlen isn't run on linear skbs though.

Also, I'm not sure I understand when should drivers set gso size
for incoming messages and what is a reasonable value.
Commit log talks about improved performance for lossy connections,
in this case, isn't this something net core should set?

I see 3 in-tree drivers that do this:

drivers/net/ethernet/broadcom/bnx2x/bnx2x_cmn.c:                skb_shinfo(skb)->gso_size = bnx2x
drivers/net/ethernet/intel/ixgbe/ixgbe_main.c:  skb_shinfo(skb)->gso_size = DIV_ROUND_UP((skb->le
drivers/net/ethernet/qlogic/qlcnic/qlcnic_io.c:         skb_shinfo(skb)->gso_size = qlcnic_get_lr

It seems likely the same issue applies there?


-- 
MST
