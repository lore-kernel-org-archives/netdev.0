From: David Lamparter <equinox@diac24.net>
Subject: Re: [PATCH net-next 0/2] 802.1ad S-VLAN support
Date: Wed, 9 Nov 2011 16:34:19 +0100
Message-ID: <20111109153419.GJ1833899@jupiter.n2.diac24.net>
References: <1320512055-1231037-1-git-send-email-equinox@diac24.net>
 <1320678704.3020.33.camel@bwh-desktop>
 <20111107154857.GC1833899@jupiter.n2.diac24.net>
 <1320701749.3020.70.camel@bwh-desktop>
 <20111107230710.GF1833899@jupiter.n2.diac24.net>
 <1320711393.3020.89.camel@bwh-desktop>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: David Lamparter <equinox@diac24.net>,
	netdev <netdev@vger.kernel.org>
To: Ben Hutchings <bhutchings@solarflare.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from spaceboyz.net ([87.106.131.203]:34808 "EHLO spaceboyz.net"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1752502Ab1KIPea (ORCPT <rfc822;netdev@vger.kernel.org>);
	Wed, 9 Nov 2011 10:34:30 -0500
Content-Disposition: inline
In-Reply-To: <1320711393.3020.89.camel@bwh-desktop>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Tue, Nov 08, 2011 at 12:16:33AM +0000, Ben Hutchings wrote:
> > Hmm. I think we need to cleanly separate MTU and MFS. MTU is used for
> > upper layer stuff like setting TCP MSS, IP fragment size, etc.
> >
> > MFS is the actual ethernet thing, and it's quite independent from the
> > MTU. Imagine the following example case:
>
> I was proposing to make a distinction between the 'untagged' MTU
> (dev->mtu) that would continue to be used by layer 3 and the physical
> MTU that would take into account the needs of any related VLAN devices.

Ah. I think we're saying the same thing with different words.

> > How about instead of propagating the MFS up, we provide an user knob to
> > adjust the MFS (on physical devices)?
>
> I suppose that may be necessary - unfortunately.

Hm. Basically, the current ndo_change_mtu call is severely misnamed, it
actually changes the MFS. MTU isn't even relevant for the driver.

With that premise, it boils down to creating new "MFS" attributes for
userspace, and cleanly splitting L2/L3 values inside the kernel.
ndo_change_mtu would become ndo_change_mfs; there'd be a MFS_CHANGED
notifier call; "mtu" becomes an IP-level thing.

While MFS constrains MTU, I'd prefer to avoid "automatic" functions like
raising MFS to make the MTU fit. (Or, worse, lowering MTU if MFS gets
changed. I'd return error instead and have the user fix his config.)

> > I admit ignorance and am duly reading code - in fact, I should probably
> > not use vlan_features for 802.1ad S-VLANs and instead force the features
> > to 0 to be on the safe side...
> 
> You shouldn't mask out all features.  I think it should be OK to copy
> NETIF_F_NO_CSUM, NETIF_F_HW_CUSM, NETIF_F_SG, NETIF_F_FRAGLIST and
> NETIF_F_HIGHDMA if those are in real_dev->vlan_features, as none of
> those are dependent on header parsing.

I'm spinning a patch introducing NETIF_F_HDR_AGNOSTIC as |ing for those.
I'll use them both for stacked VLANs (which have no features currently...)
and 802.1ad S-VLANs (and 802.1ah later).

Resending patch group tomorrow-ish,


-David
