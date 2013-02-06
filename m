From: "Michael S. Tsirkin" <mst@redhat.com>
Subject: Re: regression caused by 1d2024f61ec14bdb0c57a97a3fe73685abc2d198?
Date: Thu, 7 Feb 2013 00:26:54 +0200
Message-ID: <20130206222654.GA6195@redhat.com>
References: <20130206114321.GA13497@redhat.com>
 <1360156059.28557.28.camel@edumazet-glaptop>
 <20130206155049.GB14735@redhat.com>
 <1360180701.2659.12.camel@bwh-desktop.uk.solarflarecom.com>
 <20130206214544.GA19139@redhat.com>
 <1360187747.2659.35.camel@bwh-desktop.uk.solarflarecom.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: Eric Dumazet <eric.dumazet@gmail.com>, alexander.h.duyck@intel.com,
	stephen.s.ko@intel.com, jeffrey.t.kirsher@intel.com,
	David Miller <davem@davemloft.net>, netdev@vger.kernel.org,
	sony.chacko@qlogic.com, mchan@broadcom.com,
	jitendra.kalsaria@qlogic.com, eilong@broadcom.com
To: Ben Hutchings <bhutchings@solarflare.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mx1.redhat.com ([209.132.183.28]:56550 "EHLO mx1.redhat.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S932108Ab3BFWWk (ORCPT <rfc822;netdev@vger.kernel.org>);
	Wed, 6 Feb 2013 17:22:40 -0500
Content-Disposition: inline
In-Reply-To: <1360187747.2659.35.camel@bwh-desktop.uk.solarflarecom.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Wed, Feb 06, 2013 at 09:55:47PM +0000, Ben Hutchings wrote:
> On Wed, 2013-02-06 at 23:45 +0200, Michael S. Tsirkin wrote:
> > On Wed, Feb 06, 2013 at 07:58:21PM +0000, Ben Hutchings wrote:
> > > On Wed, 2013-02-06 at 17:50 +0200, Michael S. Tsirkin wrote:
> > > > On Wed, Feb 06, 2013 at 05:07:39AM -0800, Eric Dumazet wrote:
> > > > > On Wed, 2013-02-06 at 13:43 +0200, Michael S. Tsirkin wrote:
> > > > > > It seems that starting with kernel 3.3 ixgbe sets gso_size for
> > > > > > incoming frames. It seems that this might result in gso_size
> > > > > > being set even when gso_type is 0.
> > > > > > This in turn leads to a crash at macvtap_skb_to_vnet_hdr
> > > > > > drivers/net/macvtap.c:628
> > > > > > which has this code:
> > > > > > 
> > > > > >        if (skb_is_gso(skb)) {
> > > > > >                 struct skb_shared_info *sinfo = skb_shinfo(skb);
> > > > > > 
> > > > > >                 /* This is a hint as to how much should be linear. */
> > > > > >                 vnet_hdr->hdr_len = skb_headlen(skb);
> > > > > >                 vnet_hdr->gso_size = sinfo->gso_size;
> > > > > >                 if (sinfo->gso_type & SKB_GSO_TCPV4)
> > > > > >                         vnet_hdr->gso_type = VIRTIO_NET_HDR_GSO_TCPV4;
> > > > > >                 else if (sinfo->gso_type & SKB_GSO_TCPV6)
> > > > > >                         vnet_hdr->gso_type = VIRTIO_NET_HDR_GSO_TCPV6;
> > > > > >                 else if (sinfo->gso_type & SKB_GSO_UDP)
> > > > > >                         vnet_hdr->gso_type = VIRTIO_NET_HDR_GSO_UDP;
> > > > > >                 else
> > > > > >                         BUG();
> > > > > >                 if (sinfo->gso_type & SKB_GSO_TCP_ECN)
> > > > > >                         vnet_hdr->gso_type |= VIRTIO_NET_HDR_GSO_ECN;
> > > > > >         } else
> > > > > >                 vnet_hdr->gso_type = VIRTIO_NET_HDR_GSO_NONE;
> > > > > > 
> > > > > > 
> > > > > > Since skb_is_gso tests gso_size.
> > > > > > 
> > > > > > What's the right way to handle this? Should skb_is_gso be
> > > > > > changed to test gso_type != 0?
> > > > > > 
> > > > > 
> > > > > Or fix ixgbe to set gso_type in ixgbe_get_headlen(), as it does all the
> > > > > dissection.
> > > > 
> > > > 
> > > > Hmm, ixgbe_get_headlen isn't run on linear skbs though.
> > > > 
> > > > Also, I'm not sure I understand when should drivers set gso size
> > > > for incoming messages and what is a reasonable value.
> > > > Commit log talks about improved performance for lossy connections,
> > > > in this case, isn't this something net core should set?
> > > [...]
> > > 
> > > It should be set to the segment size on the wire, so TCP gets a correct
> > > picture of packet loss.  The networking core has no idea what hardware/
> > > firmware LRO did.
> > > 
> > > I've previously raised this issue of macvlan vs LRO (which is the same
> > > issue we previously had with IP forwarding and with bridging):
> > >      http://thread.gmane.org/gmane.linux.network/221695
> > > 
> > > Ben.
> > 
> > I see, you proposed disabling LRO the moment a macvlan is attached.
> > If I understand correctly, the difference as compared to bridge is that
> > bridge normally consumes all incoming packets, macvlan is often used in
> > parallel with the underlying interface.
> 
> Not so different from IP forwarding, though, in that a single interface
> can both forward packets and deliver them locally.

Hmm, for ip forwarding we don't try do disable LRO on the device, do we?
What's the solution there?

> > BTW are there other issues with forwarding/bridging and LRO? If everyone
> > sets gso_type in packets it seems we can leave LRO set even with
> > bridging?
> 
> Some implementations of LRO violate the end-to-end principle by merging
> segments with varying lengths and TCP timestamps.  GRO is very careful
> to ensure that the original packets can be recovered from the skbs it
> produces.
> 
> Ben.
> 
> -- 
> Ben Hutchings, Staff Engineer, Solarflare
> Not speaking for my employer; that's the marketing department's job.
> They asked us to note that Solarflare product names are trademarked.
