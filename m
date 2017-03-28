From: Benjamin Herrenschmidt <benh@kernel.crashing.org>
Subject: Re: genphy_read_status() vs. 1000bT Pause capability
Date: Tue, 28 Mar 2017 16:17:18 +1100
Message-ID: <1490678238.3177.102.camel@kernel.crashing.org>
References: <1490662190.3177.91.camel@kernel.crashing.org>
         <20170328010940.GG25549@lunn.ch>
         <1490668137.3177.98.camel@kernel.crashing.org>
         <1490669734.3177.100.camel@au1.ibm.com>
         <20170328041405.045FEB206B@b01ledav03.gho.pok.ibm.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="UTF-8"
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, Russell King <rmk+kernel@armlinux.org.uk>
To: Florian Fainelli <f.fainelli@gmail.com>,
        Andrew Lunn <andrew@lunn.ch>
Return-path: <netdev-owner@vger.kernel.org>
Received: from gate.crashing.org ([63.228.1.57]:48859 "EHLO gate.crashing.org"
        rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
        id S1753051AbdC1FSC (ORCPT <rfc822;netdev@vger.kernel.org>);
        Tue, 28 Mar 2017 01:18:02 -0400
In-Reply-To: <20170328041405.045FEB206B@b01ledav03.gho.pok.ibm.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Mon, 2017-03-27 at 21:14 -0700, Florian Fainelli wrote:
> > Doesn't fix my other problem with Pause in 1000bT land. Do you know if
> > that way of reflecting the pause capability by hijacking the old
> > LPA bits is widely implemented enough that we should put it in
> > genphy_read_status() ?
> 
> Not sure I follow you here? The link partner pause capability is
> reflected in phydev->pause and phydev->asym_pause (yes, these are
> terrible names) when the link is established. 

Right. The problem is that they aren't for some gigabit links :-)

Basically, in my setup with a PHY which uses genphy_read_status()
(like most of them), I never get those advertised despite the fact
that, I *think* they are supported by the other end (even after fixing
my side of the advertising).

I added a printk inside genphy_read_status() to inspect the result
of the negociation, and this is what I read:

lpa=c1e1 lpagb=3800 adv=de1 common_adv=1e1 common_adv_gb=800

As you can see, LPA doesn't have the Pause bits. *However* it does
have bit 0x80 which can mean ADVERTISE_100HALF, but according to
our own mii.h can also mean ADVERTISE_1000XPAUSE. Similarily it 
has bit 0x100 which can mean ADVERTISE_100FULL but also can mean
ADVERTISE_1000XPSE_ASYM.

In fact we appear to have two functions to interpret them as
such inn the non-uapi mii.h:

	ethtool_adv_to_mii_adv_x
	mii_adv_to_ethtool_adv_x

However they aren't used much in the tree and not at all by the
"genphy" code.

So my question is... when we observe that we have a 1000 link
established, should we use these to "interpret" the LPA bits as
above ?

As it is, we never seem to advertise the capability because we never
decode the above (tried with 2 different PHYs, a Realtek and a
Broadcom) while my Cisco switches, I think, do support Pause.

Hence my question ... how "standard" is the re-use of the LPA bits
for these alternate meanings in 1000bT and should we update genphy
to perform that decoding ?

(I'm trying to download the 802.3 document referenced in the phy.txt
to see if it says anything about it but it's taking forever for some
reason).

Cheers,
Ben.
