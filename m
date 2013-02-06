From: Ben Hutchings <bhutchings@solarflare.com>
Subject: Re: regression caused by 1d2024f61ec14bdb0c57a97a3fe73685abc2d198?
Date: Wed, 6 Feb 2013 19:58:21 +0000
Message-ID: <1360180701.2659.12.camel@bwh-desktop.uk.solarflarecom.com>
References: <20130206114321.GA13497@redhat.com>
	 <1360156059.28557.28.camel@edumazet-glaptop>
	 <20130206155049.GB14735@redhat.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="UTF-8"
Content-Transfer-Encoding: 7bit
Cc: Eric Dumazet <eric.dumazet@gmail.com>,
	<alexander.h.duyck@intel.com>, <stephen.s.ko@intel.com>,
	<jeffrey.t.kirsher@intel.com>, David Miller <davem@davemloft.net>,
	<netdev@vger.kernel.org>, <sony.chacko@qlogic.com>,
	<mchan@broadcom.com>, <jitendra.kalsaria@qlogic.com>,
	<eilong@broadcom.com>
To: "Michael S. Tsirkin" <mst@redhat.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from webmail.solarflare.com ([12.187.104.25]:46414 "EHLO
	webmail.solarflare.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1758068Ab3BFT6n (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 6 Feb 2013 14:58:43 -0500
In-Reply-To: <20130206155049.GB14735@redhat.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Wed, 2013-02-06 at 17:50 +0200, Michael S. Tsirkin wrote:
> On Wed, Feb 06, 2013 at 05:07:39AM -0800, Eric Dumazet wrote:
> > On Wed, 2013-02-06 at 13:43 +0200, Michael S. Tsirkin wrote:
> > > It seems that starting with kernel 3.3 ixgbe sets gso_size for
> > > incoming frames. It seems that this might result in gso_size
> > > being set even when gso_type is 0.
> > > This in turn leads to a crash at macvtap_skb_to_vnet_hdr
> > > drivers/net/macvtap.c:628
> > > which has this code:
> > > 
> > >        if (skb_is_gso(skb)) {
> > >                 struct skb_shared_info *sinfo = skb_shinfo(skb);
> > > 
> > >                 /* This is a hint as to how much should be linear. */
> > >                 vnet_hdr->hdr_len = skb_headlen(skb);
> > >                 vnet_hdr->gso_size = sinfo->gso_size;
> > >                 if (sinfo->gso_type & SKB_GSO_TCPV4)
> > >                         vnet_hdr->gso_type = VIRTIO_NET_HDR_GSO_TCPV4;
> > >                 else if (sinfo->gso_type & SKB_GSO_TCPV6)
> > >                         vnet_hdr->gso_type = VIRTIO_NET_HDR_GSO_TCPV6;
> > >                 else if (sinfo->gso_type & SKB_GSO_UDP)
> > >                         vnet_hdr->gso_type = VIRTIO_NET_HDR_GSO_UDP;
> > >                 else
> > >                         BUG();
> > >                 if (sinfo->gso_type & SKB_GSO_TCP_ECN)
> > >                         vnet_hdr->gso_type |= VIRTIO_NET_HDR_GSO_ECN;
> > >         } else
> > >                 vnet_hdr->gso_type = VIRTIO_NET_HDR_GSO_NONE;
> > > 
> > > 
> > > Since skb_is_gso tests gso_size.
> > > 
> > > What's the right way to handle this? Should skb_is_gso be
> > > changed to test gso_type != 0?
> > > 
> > 
> > Or fix ixgbe to set gso_type in ixgbe_get_headlen(), as it does all the
> > dissection.
> 
> 
> Hmm, ixgbe_get_headlen isn't run on linear skbs though.
> 
> Also, I'm not sure I understand when should drivers set gso size
> for incoming messages and what is a reasonable value.
> Commit log talks about improved performance for lossy connections,
> in this case, isn't this something net core should set?
[...]

It should be set to the segment size on the wire, so TCP gets a correct
picture of packet loss.  The networking core has no idea what hardware/
firmware LRO did.

I've previously raised this issue of macvlan vs LRO (which is the same
issue we previously had with IP forwarding and with bridging):
     http://thread.gmane.org/gmane.linux.network/221695

Ben.

-- 
Ben Hutchings, Staff Engineer, Solarflare
Not speaking for my employer; that's the marketing department's job.
They asked us to note that Solarflare product names are trademarked.
