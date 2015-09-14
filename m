From: Russell King - ARM Linux <linux@arm.linux.org.uk>
Subject: mvneta: SGMII fixed-link not so fixed
Date: Mon, 14 Sep 2015 11:32:08 +0100
Message-ID: <20150914103207.GH21084@n2100.arm.linux.org.uk>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: linux-arm-kernel@lists.infradead.org, netdev@vger.kernel.org
To: Stas Sergeev <stsp@list.ru>, Andrew Lunn <andrew@lunn.ch>
Return-path: <netdev-owner@vger.kernel.org>
Received: from pandora.arm.linux.org.uk ([78.32.30.218]:47266 "EHLO
	pandora.arm.linux.org.uk" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1754042AbbINKcT (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 14 Sep 2015 06:32:19 -0400
Content-Disposition: inline
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

I've been bringing up the mainline kernel on a new board, which has
an Marvell SoC with a mvneta interface connected to a Marvell DSA
switch.  The DSA switch is a 88E6176.

In the DT block for the interface, I specify:

	ethernet@... {
	        phy-mode = "sgmii";
		status = "okay";

		fixed-link {
			speed = <1000>;
			full-duplex;
		};
	};

However, this doesn't work without patching mvneta to disable the
autonegotiation and forcing the link up:

diff --git a/drivers/net/ethernet/marvell/mvneta.c b/drivers/net/ethernet/marvell/mvneta.c
index 62e48bc0cb23..e1698731e429 100644
--- a/drivers/net/ethernet/marvell/mvneta.c
+++ b/drivers/net/ethernet/marvell/mvneta.c
@@ -1010,6 +1010,10 @@ static void mvneta_defaults_set(struct mvneta_port *pp)
 		val |= MVNETA_GMAC_INBAND_AN_ENABLE |
 		       MVNETA_GMAC_AN_SPEED_EN |
 		       MVNETA_GMAC_AN_DUPLEX_EN;
+		/* We appear to need the interface forced for DSA switches */
+		val &= ~(MVNETA_GMAC_AN_DUPLEX_EN |
+			 MVNETA_GMAC_AN_SPEED_EN);
+		val |= MVNETA_GMAC_FORCE_LINK_PASS;
 		mvreg_write(pp, MVNETA_GMAC_AUTONEG_CONFIG, val);
 		val = mvreg_read(pp, MVNETA_GMAC_CLOCK_DIVIDER);
 		val |= MVNETA_GMAC_1MS_CLOCK_ENABLE;

As Marvell likes to keep all their documentation secret, it's very hard
to know what's going on, and why this would be necessary.  However, when
running the board under a kernel built from Marvell's code base, it
sets this register in a similar way.

Since the link is definitely a fixed-link operating at 1G, full duplex,
with no autonegotiation, I think using the fixed-link in DT is correct,
but the mvneta driver is wrong to abuse fixed-link to mean "SGMII but
with in-band autonegotiation".

The other issue I've seen is that even with the fixed-link settings, I
have seen via ethtool that the link is reported as 10mbit - because
mvneta_fixed_link_update() changes the settings on the fixed link.  So,
fixed-link doesn't seem to be quite as fixed as "fixed" says it should
be.

Shouldn't SGMII (which is always gigabit) be treated as gigabit with
in-band negotiation when phy-mode = "sgmii" but no fixed-link, but a
real fixed speed, other parameters and forced up when phy-mode = "sgmii"
and there is a fixed link.  It seems to me that there's been a design
mistake here, and my fear is that as we seem to have had this mistake
in the tree since April, it's now almost impossible to support this
setup without breaking DT compatibility.

However, it could be that the switch is misconfigured, and some register
bit somewhere isn't set to indicate that it should provide in-band
signalling on its SGMII interface.  I've trawled the net looking at
various bits of Marvell code for driving their switches, and I see
nothing which would cause them to enable in-band signalling, but maybe
I'm missing something.

Here's the switch registers - the mvneta is connected to port 5:

    GLOBAL GLOBAL2   0    1    2    3    4    5    6
 0:  c844       0  100f 100f 100f 100f 100f  e09  e07
 1:     0       0     3    3    3    3    3   3e    3
 2:     0    ffff     0    0    0    0    0    0    0
 3:     0    ffff  1761 1761 1761 1761 1761 1761 1761
 4:  6000     258   430  430  430  430  430 373f  430
 5:     0      ff     0    0    0    0    0    0    0
 6:     0    1f0f    7e   7d   7b   77   6f 505f   3f
 7:     0    707f     0    0    0    0    0    0    0
 8:     0    7800  2080 2080 2080 2080 2080 2080 2080
 9:     0    1600     1    1    1    1    1    1    1
 a:   148       0     0    0    0    0    0    0    0
 b:  6000    1000     1    2    4    8   10   20   40
 c:     0      7f     0    0    0    0    0    0    0
 d:     0     502     0    0    0    0    0    0    0
 e:     0       0     0    0    0    0    0    0    0
 f:     0     f00  dada dada dada dada dada dada dada
10:     0       0     0    0    0    0    0    0    0
11:     0       0     0    0    0    0    0    0    0
12:  5555       0     0    0    0    0    0    0    0
13:  5555       0     0    0    0    0    0    0    0
14:  aaaa     400     0    0    0    0    0    0    0
15:  aaaa       0     0    0    0    0    0    0    0
16:  ffff       0    33   33   33   33   33   33    0
17:  ffff       0     0    0    0    0    0    0    0
18:  fa41    1884  3210 3210 3210 3210 3210 3210 3210
19:     0     1e1  7654 7654 7654 7654 7654 7654 7654
1a:  5550       0     0    0    0    0    0    0    0
1b:   1ff    f869  8000 8000 8000 8000 8000 8000 8000
1c:     0       0     0    0    0    0    0    0    0
1d:  1000       0     0    0    0    0    0    0    0
1e:     0       0     0    0    0    0    0    0    0
1f:     0       0     0    0    0    0    0    0    0

The DSA switch is configured in DT with:

	dsa@0 {
		compatible = "marvell,dsa";
		dsa,ethernet = <&eth1>;
		dsa,mii-bus = <&mdio>;
		#address-cells = <2>;
		#size-cells = <0>;
		switch@0 {
			#address-cells = <1>;
			#size-cells = <0>;
			reg = <4 0>;
...
			port@5 {
				reg = <5>;
				label = "cpu";
			};
		};
	};

-- 
FTTC broadband for 0.8mile line: currently at 9.6Mbps down 400kbps up
according to speedtest.net.
