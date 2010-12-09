From: Dan Williams <dcbw@redhat.com>
Subject: Re: Behaviour of ETHTOOL_GLINK for an interface that's down
Date: Thu, 09 Dec 2010 00:02:37 -0600
Message-ID: <1291874559.24551.10.camel@dcbw.foobar.com>
References: <1291672786.5405.23.camel@bwh-desktop>
	 <1291873629.24551.7.camel@dcbw.foobar.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="UTF-8"
Content-Transfer-Encoding: 7bit
Cc: netdev <netdev@vger.kernel.org>,
	sf-linux-drivers <linux-net-drivers@solarflare.com>
To: Ben Hutchings <bhutchings@solarflare.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mx1.redhat.com ([209.132.183.28]:2685 "EHLO mx1.redhat.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1751321Ab0LIGC4 (ORCPT <rfc822;netdev@vger.kernel.org>);
	Thu, 9 Dec 2010 01:02:56 -0500
In-Reply-To: <1291873629.24551.7.camel@dcbw.foobar.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Wed, 2010-12-08 at 23:47 -0600, Dan Williams wrote:
> On Mon, 2010-12-06 at 21:59 +0000, Ben Hutchings wrote:
> > ETHTOOL_GLINK is yet another ethtool operation that has unclear
> > semantics that results in differing behaviour when the interface is
> > down.
> > 
> > The two reasonable semantics I can see are:
> > 1. Report whether the host has a working link, i.e. netif_running() &&
> > netif_carrier_on().
> > 2. Report whether the port has a working link.  For hardware interfaces,
> > poll the PHY or firmware unless the port is powered-off.  For software
> > interfaces, report whether the interface could plausibly pass traffic.
> > 
> > The default implementation (ethtool_op_get_link) uses
> > netif_carrier_ok(), implementing the rather unreasonable semantics:
> > 3. Report whether the port had a working link when the interface was
> > last up.
> > 
> > At least one driver works around this by setting carrier off in its
> > ndo_stop() operation.
> > 
> > Here's a small sample of driver behaviours:
> > 
> > bnx2: (1)
> > bnx2x: (1) (I think)
> > cxgb3: (1) (but also (2) because PHY is powered off)
> > e1000e: (2)
> > gianfar: (3)
> > igb: (2)
> > ixgbe: (1)
> > niu: (3)
> > sfc: (3) (approximately)
> > sky2: (3)
> > tg3: (3) (but also (1) due to setting carrier off in tg3_close())
> > 
> > DaveM said that Network Manager may require (2), although I don't think
> > this is correct.  At least the current version brings all managed
> > interfaces up whether or not they have link-up already.
> 
> NM has used netlink + IFF_RUNNING (not ethtool) for a few years for
> actual carrier detection.  Ethtool (and MII ioctls) are called as a
> "best effort" method of determining that the device actually *has*
> carrier detection at all, since if the device has gone to the trouble to
> implement either MII or ethtool, it probably also has carrier detection.
> 
> But ethtool isn't actually used to determine carrier status in NM.  It's
> netlink all the way down.

And as a follow-on, yes, NM does bring all devices it is allowed to
manager IFF_UP because that's the only way (at this point) that we can
guarantee functional carrier detect from the card.  I'd love it if that
weren't the case, and if we could have some indicator that the driver
could do carrier detect while in a lower-power state and !IFF_UP, but we
don't have that yet.

Dan


