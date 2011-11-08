From: Ben Hutchings <bhutchings@solarflare.com>
Subject: Re: [PATCH net-next 0/2] 802.1ad S-VLAN support
Date: Tue, 8 Nov 2011 00:16:33 +0000
Message-ID: <1320711393.3020.89.camel@bwh-desktop>
References: <1320512055-1231037-1-git-send-email-equinox@diac24.net>
	 <1320678704.3020.33.camel@bwh-desktop>
	 <20111107154857.GC1833899@jupiter.n2.diac24.net>
	 <1320701749.3020.70.camel@bwh-desktop>
	 <20111107230710.GF1833899@jupiter.n2.diac24.net>
Mime-Version: 1.0
Content-Type: text/plain; charset="UTF-8"
Content-Transfer-Encoding: 7bit
Cc: netdev <netdev@vger.kernel.org>
To: David Lamparter <equinox@diac24.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from exchange.solarflare.com ([216.237.3.220]:12101 "EHLO
	exchange.solarflare.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1750871Ab1KHAQh (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 7 Nov 2011 19:16:37 -0500
In-Reply-To: <20111107230710.GF1833899@jupiter.n2.diac24.net>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Tue, 2011-11-08 at 00:07 +0100, David Lamparter wrote:
> On Mon, Nov 07, 2011 at 09:35:49PM +0000, Ben Hutchings wrote:
> > On Mon, 2011-11-07 at 16:48 +0100, David Lamparter wrote:
> > > On Mon, Nov 07, 2011 at 03:11:44PM +0000, Ben Hutchings wrote:
> > > > We definitely need to think about how MTU/MRU are configured when
> > > > multiple VLAN tags are used, though I don't think it's essential to do
> > > > before this goes in.  To be slightly more blunt than your documentation,
> > > > our current handling of MTU/MRU and VLANs is a botch.
> [...]
> > >
> > > Yes, what i'd like to do is introduce a new field into struct netdevice
> > > that tracks the hardware Max Frame Size; it'd be a read-only field
> > > that's initialized once by the driver. (The field would only be used by
> > > ethernet-like devices.) To get things started easier, the field can have
> > > a default value like 0xffff, so if the driver doesn't set it we end up
> > > with the same old nothing-checked behaviour.
> [...]
> >
> > The driver for a physical device may still need to know the overall
> > MTU/MRU.  Certainly in case of hardware/drivers which do not support DMA
> > scatter we do not want the driver to allocate oversized buffers.  Also
> > some devices may partition internal FIFOs according to the MTU/MRU and
> > we should nto unnecessarily reduce the maximum number of packets that
> > can fit in those FIFOs.
> >
> > So I think that instead of propagating MFS down, we should propagate MTU
> > change requests up, but maintaining a distinction between the MTUs for
> > untagged and tagged (with different types) packets..
> 
> Hmm. I think we need to cleanly separate MTU and MFS. MTU is used for
> upper layer stuff like setting TCP MSS, IP fragment size, etc.
>
> MFS is the actual ethernet thing, and it's quite independent from the
> MTU. Imagine the following example case:
> 
> subnet 1 has legacy 100 mbit hosts with 1514 byte limit. So it runs at
> MTU 1500. subnet 2 is used for SAN and has all-9216-equipment. We have a
> server connected with eth0 (9216 capable hw). The ethernet switch feeds
> subnet 1 untagged and subnet 2 tagged 1Q id 2 ("eth0.2").
> 
> The current code cannot handle this since if eth0 MTU = 1500, eth0.2
> cannot be set to 9200. (vlan_dev_change_mtu:
> 	if (vlan_dev_info(dev)->real_dev->mtu < new_mtu
> 		return -ERANGE;
> Note that raising eth0's MTU is wrong because now the box will send 9k
> IP packets to those poor 100mbit hosts... the only way around this would
> be to add MTU values to the routes for that subnet.

I was proposing to make a distinction between the 'untagged' MTU
(dev->mtu) that would continue to be used by layer 3 and the physical
MTU that would take into account the needs of any related VLAN devices.

> So, I'd like to define "MTU" to be layer 3 and "MFS" to be layer 2. The
> essential distinction is that the MFS value is interdependent between
> VLANs and their masters while the MTU can be arbitrarily set (within MFS
> limits).

Right.

> > we should propagate MTU change requests up
> 
> Hm. If we propagate the MFS up, we either need to track the different
> requestors so we can notice when we can lower it back down, or we end up
> ever just raising the value.
> 
> How about instead of propagating the MFS up, we provide an user knob to
> adjust the MFS (on physical devices)?

I suppose that may be necessary - unfortunately.

> Might also be relevant for lxc/network namespaces; i don't think a
> containered uid0 should have the possibility to increase your NIC's
> buffers by x6 by changing the MTU on his VLAN...

Indeed!

> (I'd still keep a max_mfs field, just to export these bits of knowledge
> from the driver to userspace. I remember a recent thread about e100 and
> hardware limits...)
> 
> > > 	dev->hw_features = NETIF_F_ALL_CSUM | NETIF_F_SG |
> > > 			   NETIF_F_FRAGLIST | NETIF_F_ALL_TSO |
> > > 			   NETIF_F_HIGHDMA | NETIF_F_SCTP_CSUM |
> > > 			   NETIF_F_ALL_FCOE;
> >
> > Those are the features that can *potentially* be toggled.
> >
> > > which is pretty much the "basic" set. I don't see why any of that should
> > > differ for 802.1ad (or even 802.1ah), but my understanding is barely
> > > enough to tell that these flags should work for 802.1ad.
> >
> > See vlan_dev_fix_features() and note that vlan_features is zero for a
> > VLAN device.
> 
> I admit ignorance and am duly reading code - in fact, I should probably
> not use vlan_features for 802.1ad S-VLANs and instead force the features
> to 0 to be on the safe side...

You shouldn't mask out all features.  I think it should be OK to copy
NETIF_F_NO_CSUM, NETIF_F_HW_CUSM, NETIF_F_SG, NETIF_F_FRAGLIST and
NETIF_F_HIGHDMA if those are in real_dev->vlan_features, as none of
those are dependent on header parsing.

Ben.

-- 
Ben Hutchings, Staff Engineer, Solarflare
Not speaking for my employer; that's the marketing department's job.
They asked us to note that Solarflare product names are trademarked.
