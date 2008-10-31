From: Trent Piepho <tpiepho@freescale.com>
Subject: Re: [PATCH] gianfar: Omit TBI auto-negotiation based on device tree
Date: Thu, 30 Oct 2008 18:07:31 -0700 (PDT)
Message-ID: <Pine.LNX.4.64.0810301738020.3943@t2.domain.actdsltmp>
References: <1225234382-23050-1-git-send-email-ncase@xes-inc.com>
Mime-Version: 1.0
Content-Type: TEXT/PLAIN; charset=US-ASCII
Cc: Kumar Gala <kumar.gala@freescale.com>, linuxppc-dev@ozlabs.org,
	Andy Fleming <afleming@freescale.com>, netdev@vger.kernel.org
To: Nate Case <ncase@xes-inc.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from az33egw02.freescale.net ([192.88.158.103]:46978 "EHLO
	az33egw02.freescale.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751092AbYJaBIQ (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 30 Oct 2008 21:08:16 -0400
In-Reply-To: <1225234382-23050-1-git-send-email-ncase@xes-inc.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Tue, 28 Oct 2008, Nate Case wrote:
> Some SGMII PHYs don't auto-negotiate correctly with the TBI+SerDes
> interface on the mpc85xx processors.  Check for the "sgmii-aneg-disable"
> device tree flag and skip enabling auto-negotiation on the TBI
> side if present.  Full duplex 1000 Mbit/s will be assumed for the
> SGMII link to the PHY (note that this does not affect the link speed
> on the external side of the external PHY).

Note that there is a race in the tbi/serdes setup code.  The writes to the
TBI/SerDes with gfar_local_mdio_write() use the same MDIO bus registers as
phylib uses to talk to the real phy or phys.  There is no locking for
gfar_local_mdio vs phylib so they can (and will) clobber each other.

It doesn't usually happen, due to luck and general phylib slowness.  But I've
got some patches in 2.6.28 that speed up phylib and might makes this happen
more often...

But more relevant to your serdes problem, I also have a patch that prevents
restarting serdes auto-negotiation if the serdes link is already up.  My SGMII
PHY will auto-negotiate, but it takes about 3 seconds.  Avoiding an
unnecessary 3 second auto-negotiation when the gianfar device is opened lets
me cut my power-on to DHCP completion time in half.

I wonder if this would also fix your problem, without needing to add the extra
workaround?
