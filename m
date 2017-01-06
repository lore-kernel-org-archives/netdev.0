From: Russell King - ARM Linux <linux@armlinux.org.uk>
Subject: Re: [PATCH net-next v4 0/4] Fix OdroidC2 Gigabit Tx link issue
Date: Fri, 6 Jan 2017 11:42:26 +0000
Message-ID: <20170106114226.GX14217@n2100.armlinux.org.uk>
References: <1480348229-25672-1-git-send-email-jbrunet@baylibre.com>
 <049b1efc-3bad-92e0-45ef-0563dc5d81de@gmail.com>
 <20170105232508.GU14217@n2100.armlinux.org.uk>
 <1483697496.28003.40.camel@baylibre.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=iso-8859-1
Content-Transfer-Encoding: 8bit
Cc: Florian Fainelli <f.fainelli@gmail.com>, netdev@vger.kernel.org,
        devicetree@vger.kernel.org, Andrew Lunn <andrew@lunn.ch>,
        Alexandre TORGUE <alexandre.torgue@st.com>,
        Neil Armstrong <narmstrong@baylibre.com>,
        Martin Blumenstingl <martin.blumenstingl@googlemail.com>,
        Kevin Hilman <khilman@baylibre.com>,
        linux-kernel@vger.kernel.org,
        Yegor Yefremov <yegorslists@googlemail.com>,
        Julia Lawall <julia.lawall@lip6.fr>,
        Andre Roth <neolynx@gmail.com>,
        linux-amlogic@lists.infradead.org, Carlo Caione <carlo@caione.org>,
        Giuseppe Cavallaro <peppe.cavallaro@st.com>,
        Andreas =?iso-8859-1?Q?F=E4rber?= <afaerber@suse.de>,
        linux-arm-kernel@lists.infradead.org
To: Jerome Brunet <jbrunet@baylibre.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from pandora.armlinux.org.uk ([78.32.30.218]:43696 "EHLO
        pandora.armlinux.org.uk" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1755133AbdAFLng (ORCPT
        <rfc822;netdev@vger.kernel.org>); Fri, 6 Jan 2017 06:43:36 -0500
Content-Disposition: inline
In-Reply-To: <1483697496.28003.40.camel@baylibre.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Fri, Jan 06, 2017 at 11:11:36AM +0100, Jerome Brunet wrote:
> The purpose of this patch is to provide a way to mark as broken a
> particular eee mode. At first, it had nothing to do with "set_eee" but,
> as Florian rightly pointed out, users shouldn't be able to re-enable a
> broken mode.

I think something else has been missed - I don't see much point to
telling userspace that (eg) 1000baseT EEE is supported and then
ignore attempts to advertise it.

If it's broken, then arguably the hardware doesn't support the mode,
so we should really be masking those bits from the EEE supported mask
as well.

> I wonder if we should return an error though. With the current
> implementation, user space application could simply ask to activate
> everything, excepting the kernel to sort it out and return an error
> only if something horribly wrong happened. If we start returning an
> error for unsupported modes, we could break things. I guess we should
> just silently filter the requested modes.

The ethtool behaviour for advertisments is that errors are not returned
unless the attempted advert is really wrong.

So, for example, when setting an advertisment for link modes, we accept
the user's supplied mask, and bitwise AND it with the supported mask,
so unsupported link modes are cleared.  Only if the result is an empty
mask do we then return an error to userspace.

It's similar for forcing the link parameters - phylib attempts to find
the best phy setting mode which fuzzily matches the users request, but
doesn't error out if we can't do exactly what the user requested.

In the EEE case, an empty mask is acceptable (it means "EEE is supported
in no link modes") so it isn't appropriate to return errors there.

> >  - maybe the problem here is that the PCS doesn't support support
> > EEE in 1000baseT mode?
> 
> 
> It does, and that's kind of the problem. EEE in ON for 100Tx and 1000T
> by default with this PHY. I have several platform with the same MAC-PHY 
> combination. Only the OdroidC2 shows this particular issue with 1000T-
> EEE
> 
> As explained in other mails in this thread. The problem does not come
> from the MAC entering LPI. It actually comes from the link partner
> entering LPI on the Rx path under significant Tx transfer. For some
> reason, this completely mess up our PHY.

For a 1000baseT link to enter low power, both ends have to enter LPI
(see 802.3 78.1.3.3.1) - the Tx and Rx paths can't independently enter
LPI.

So, if you have a busy Tx link, the link itself can't be entering LPI.
Your link partner may be sending a request to enter LPI due to its own
Tx path being idle, which should then be forwarded to your MAC.

It's pretty hard to see what could be messed up with that - I'd have
expected the problems to occur when both ends were idle and the link
had entered low power mode.

> > On the SolidRun boards, they're using AR8035, and have suffered this
> > occasional link drop problem.  What has been found is that it seems
> > to
> > be to do with the timing parameters, and it seemed to only be 1000bT
> > that was affected.  I don't remember off hand exactly which or what
> > the change was they made to stabilise it though, but I can probabily
> > find out tomorrow.
> > 
> 
> Since the same combination of MAC-PHY works well on other designs, it
> is also my feeling that is has something to do with some timing
> parameter, maybe related to this particular PCB.

Maybe a different PHY interface?  Meson seems to use RGMII, maybe
others use SGMII - but then I'd expect 100base-Tx to also be broken.
So not really sure.

I was talking to Florian about that last night, because the mis-named
phy_init_eee() tests for various phy interface modes before proceeding,
which seems to be fairly rubbish as the list of interface modes is
gradually increasing since it was introduced (and I need to add SGMII
to it.)  The conclusion I've come to there is that the test should
never have been part of phylib, because if there are restrictions on
which phy interface modes are allowable for EEE, they're likely to be
either PHY or MAC specific.

The other problem that having the test there causes is that if the
existing users can't handle EEE over SGMII, then when I add SGMII to
support my hardware, they end up breaking - far from desirable.
There's no information on why the test is there, or even which PHYs
or MACs it's applicable to, which makes this unnecessarily more
difficult to now resolve.

My feeling is that the integration of EEE into phylib is fairly poor
at the moment, and we need to be a lot smarter about it.

BTW, one of the problems (not caused by your patch) is that changing
the EEE advertisment does not (on all PHY drivers) cause the link to
be renegotiated - there's no call to phy_start_aneg() when the advert
changes, and even if there was, there's no guarantee that
phy_start_aneg() will even set the AN restart bit in the control
register.

However, given that you're hooking into the set_eee function, I'm not
sure why you placed your EEE advertisment thing into config_aneg() -
isn't it more an initialisation thing (so should be in config_init()?)

-- 
RMK's Patch system: http://www.armlinux.org.uk/developer/patches/
FTTC broadband for 0.8mile line: currently at 9.6Mbps down 400kbps up
according to speedtest.net.
