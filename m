From: Russell King - ARM Linux <linux@arm.linux.org.uk>
Subject: Re: mvneta: SGMII fixed-link not so fixed
Date: Fri, 18 Sep 2015 00:14:22 +0100
Message-ID: <20150917231422.GY21084@n2100.arm.linux.org.uk>
References: <20150914103207.GH21084@n2100.arm.linux.org.uk>
 <55F6AA25.2070603@list.ru>
 <20150914114209.GL21084@n2100.arm.linux.org.uk>
 <20150917.151247.2129216999071943354.davem@davemloft.net>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: stsp@list.ru, andrew@lunn.ch, linux-arm-kernel@lists.infradead.org,
	netdev@vger.kernel.org
To: David Miller <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from pandora.arm.linux.org.uk ([78.32.30.218]:56434 "EHLO
	pandora.arm.linux.org.uk" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751981AbbIQXOf (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 17 Sep 2015 19:14:35 -0400
Content-Disposition: inline
In-Reply-To: <20150917.151247.2129216999071943354.davem@davemloft.net>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Thu, Sep 17, 2015 at 03:12:47PM -0700, David Miller wrote:
> From: Russell King - ARM Linux <linux@arm.linux.org.uk>
> Date: Mon, 14 Sep 2015 12:42:09 +0100
> 
> > Thanks, I think that will solve it.  I have to wonder why that patch
> > (f8af8e6eb9509 in mainline) didn't made it into v4.2 though, as it's
> > billed as a regression that occurred in the previous merge window, and
> > given that it was sent in July, and we're now in September.  As it
> > wasn't in v4.2, it looks like it should be a stable candidate.
> 
> The series had a whole bunch of non bug fixes in it and we were in
> the final phases of 4.2, in which case I defer to applying patches
> to net-next only unless I'm told otherwise.
> 
> It's up the the patch/series author to let me know that an important
> regression fix is hidden in there, but they should have submitted
> it seperately from the rest in that kind of situation anyways.
> 
> > David, any objections to having the stable guys pick this regression
> > fix up, if not already done so?
> 
> More than this patch is needed, the one before it (3/4) instantiates
> the necessary property in the DT, for example.
> 
> I can queue up the whole series for -stable if you want.

Sorry in advance for this rambling reply...

I'm not entirely certain that'd be a good idea at the moment, for a
number of reasons, which are coming up because I'm looking at getting
a SFP cage supported with mvneta hardware.

1. Serdes gigabit ethernet links have two operating modes for in-band
   "negotiation" - Cisco SGMII format, and 1000base-X format.  Both use
   exactly the same encoding on the wire, the only differences between
   them are the contents of a 16-bit configuration word and how each
   end of the link handles that.  SFP can use either format depending
   on the module hot-plugged in - fiber modules will normally use
   1000base-X, but copper modules which contain a PHY may use either
   SGMII or 1000base-X.  (Fiber modules for 100baseFX will probably
   use SGMII though.)

   The issue there is two-fold: that the new DT property just says it's
   "in-band" or "auto" but there's no way to specify the format of the
   in-band configuration.

2. With Serdes, the PCS layer of the PHY, which does the autonegotiation,
   is moved to the MAC.  When connected to a SGMII PHY, the PHY may report
   over the Serdes connection the Cisco SGMII configuration word which
   instructs the MAC how to configure itself.  It's not "negotiation" by
   any means, but "phy telling the MAC how to configure itself" word.

   Having "in-band" enabled pretty much requires the use of the "fixed-link"
   property, which seems to be a total hack around the PCS layer being in
   the MAC - the "fixed-link" phy is no longer fixed, but is used as a
   means to convey the negotiated results from the MAC side PCS to the
   software-emulated PHY, only to have them pop back out into the MAC
   driver.

   If you specify "in-band" without a "fixed-link" but have other MACs
   making use of the fixed-link support, all hell breaks loose, because
   mvneta will call the fixed-link update function with the real phy
   with the in-band results, and this can hit a fixed-link PHY for some
   other network adapter.  The fixed-link PHY code makes no attempt to
   validate that the phy_device passed in really is a fixed-link phy
   and not a MDIO phy.

3. Having DT specify a fixed-link with parameters along with in-band
   negotiation results in the fixed-link parameters being ignored.
   This means if a fixed-link DT declaration specifies a speed, that
   declaration will be ignored.  What I'm basically saying is that:

		phy-mode = "sgmii";
		fixed-link {
			speed = <1000>;
		};

   specifies a fixed-speed serdes link at 1000mbps, but:

		phy-mode = "sgmii";
		managed = "in-band-status";
		fixed-link {
			speed = <1000>;
		};

   does not fix the speed at all.  _But_ using the in-band status
   property fundamentally requires this for mvneta to behave correctly:

		phy-mode = "sgmii";
		managed = "in-band-status";
		fixed-link {
		};

   with _no_ phy node.

4. Going back to the SFP problem, the link is only up when the SFP
   module pins indicate that there's no transmitter fault, no loss of
   signal _and_ the PCS layer at the MAC indicates that it has completed
   negotiation.  This pretty much rules out trying to emulate a SFP cage
   as a software-based PHY.  I've code right now doing exactly that, and
   it results in netif_carrier_on() being called far too early.

What I don't know is how many generations of the mvneta hardware have
support for both serdes modes, but what I'm basically saying is that
the solution we now have seems to be somewhat lacking - maybe it should
have been "auto", "in-band-sgmii" and "in-band-1000base-x" with the
ability to add additional modes later.

The other point I'm making above is that I'm forming the opinion that
the existing PHY layer isn't flexible enough for supporting SFP, and I
need some way to represent at least part of the autonegotiation at the
MAC level without involving the PHY level - especially when considering
that a real PHY might be inside the SFP cage which can be talked to
over I2C.

This is the problem I'm presently grappling with, and it's taking lots
of thought right now.  I'm aware of other drivers in the kernel which
support SFP, each using their own implementations to support that.


Lastly, while looking at this, I've a small stack of patches for the PHY
code resolving some of the issues I've mentioned above, and fixing broken
reference counting and mdio bus module removal issues:

 phy: fixed-phy: properly validate phy in fixed_phy_update_state()
 net: fix phy refcounting in a bunch of drivers
 of_mdio: fix MDIO phy device refcounting
 phy: add proper phy struct device refcounting
 phy: fix mdiobus module safety
 phy: fix of_mdio_find_bus() device refcount leak

I hope to be able to send those out in the next few days - they have
nothing to do with SFP itself but are the results of looking through the
PHY code.

-- 
FTTC broadband for 0.8mile line: currently at 9.6Mbps down 400kbps up
according to speedtest.net.
