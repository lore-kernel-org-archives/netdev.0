From: Ben Hutchings <bhutchings@solarflare.com>
Subject: Re: VLAN driver question
Date: Tue, 18 Jun 2013 15:41:24 +0100
Message-ID: <1371566484.1956.16.camel@bwh-desktop.uk.level5networks.com>
References: <51BF5F81.2040207@mentor.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="UTF-8"
Content-Transfer-Encoding: 7bit
Cc: <netdev@vger.kernel.org>
To: Jim Baxter <jim_baxter@mentor.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from webmail.solarflare.com ([12.187.104.25]:49180 "EHLO
	webmail.solarflare.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1754648Ab3FROl2 (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 18 Jun 2013 10:41:28 -0400
In-Reply-To: <51BF5F81.2040207@mentor.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Mon, 2013-06-17 at 20:12 +0100, Jim Baxter wrote:
> I have a network card that has a single flag to indicate if a received
> packet contains a vlan packet.
> 
> Can I use this to accelerate the kernels handling of the packet with
> something like the following?
>
> /* Handle received VLAN packets */
> if ((ndev->features & NETIF_F_HW_VLAN_CTAG_RX) && ebdp &&
> 					(ebdp->cbd_esc &
> 					BD_ENET_RX_VLAN)) {
> 	/* Push and remove the vlan tag */
> 	struct vlan_hdr *vlan_header;
> 	u16 vlan_tag;
> 	vlan_header = (struct vlan_hdr *) skb->data;
> 	vlan_tag = ntohs(vlan_header->h_vlan_TCI);
> 	__vlan_hwaccel_put_tag(skb, vlan_tag);
> 	skb->len -= VLAN_HLEN;
> 	skb->data += VLAN_HLEN;
> 	vlan_set_encap_proto(skb, vlan_header);

You have to move the Ethernet addresses forward as well.  Imagine this
device is being bridged - the Ethernet header won't be regenerated, so
it has to be immediately before the network header.

> }
> 
> napi_gro_receive(&fep->napi, skb);

I've been meaning to add a core function to do
pull-out-VLAN-tag-and-GRO, although I'm more interested in
napi_gro_frags().  Perhaps you could add the generic wrapper for
napi_gro_receive()?

> Also I cannot find any documentation stating what the difference is
> between NETIF_F_HW_VLAN_CTAG_RX and NETIF_F_HW_VLAN_CTAG_FILTER, can
> anyone define it?
> The FILTER word on NETIF_F_HW_VLAN_CTAG_FILTER suggests it may be
> applicable to received packets.

NETIF_F_HW_VLAN_CTAG_RX means the device will extract VLAN tags so they
aren't received inline.

NETIF_F_HW_VLAN_CTAG_FILTER means the device can filter by VID.  The
driver's ndo_vlan_rx_{add,kill}_vid operations will be called to update
the filter.

Ben.

-- 
Ben Hutchings, Staff Engineer, Solarflare
Not speaking for my employer; that's the marketing department's job.
They asked us to note that Solarflare product names are trademarked.
