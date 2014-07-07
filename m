From: Pavel Machek <pavel@denx.de>
Subject: Re: socfpga/sockit ethernet problems
Date: Mon, 7 Jul 2014 23:43:40 +0200
Message-ID: <20140707214340.GA29061@amd.pavel.ucw.cz>
References: <20140507104518.GB18139@amd.pavel.ucw.cz>
 <20140703093548.GA9937@amd.pavel.ucw.cz>
 <1404764751.14294.3.camel@linux-builds1>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: peppe.cavallaro@st.com, netdev@vger.kernel.org,
	linux-arm-kernel@lists.infradead.org, gsi@denx.de, dzu@denx.de,
	s.trumtrar@pengutronix.de
To: Dinh Nguyen <dinguyen@altera.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from atrey.karlin.mff.cuni.cz ([195.113.26.193]:34829 "EHLO
	atrey.karlin.mff.cuni.cz" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1750979AbaGGVnm (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 7 Jul 2014 17:43:42 -0400
Content-Disposition: inline
In-Reply-To: <1404764751.14294.3.camel@linux-builds1>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Hi!

> > I made this, but ethernet problems I currently see are not frequent
> > enough to allow easy debugging. If link takes long to  estabilish for
> > you, could you test the patch below?

> > +static int ksz9021rn_phy_fixup(struct phy_device *phydev)
> > +{
> > +        if (IS_BUILTIN(CONFIG_PHYLIB)) {
> > +		printk("------------- running phy fixup\n");
> > +
> > +                /* min rx data delay */
> > +                phy_write(phydev, MICREL_KSZ9021_EXTREG_CTRL,
> > +			  0x8000 | MICREL_KSZ9021_RGMII_RX_DATA_PAD_SKEW);
> > +                phy_write(phydev, MICREL_KSZ9021_EXTREG_DATA_WRITE, 0x0000);
> > +
> > +                phy_write(phydev, MICREL_KSZ9021_EXTREG_CTRL,
> > +			  0x8000 | MICREL_KSZ9021_RGMII_TX_DATA_PAD_SKEW);
> > +                phy_write(phydev, MICREL_KSZ9021_EXTREG_DATA_WRITE, 0x0000);
> > +
> > +                /* max rx/tx clock delay, min rx/tx control delay */
> > +                phy_write(phydev, MICREL_KSZ9021_EXTREG_CTRL,
> > +			  0x8000 | MICREL_KSZ9021_RGMII_CLK_CTRL_PAD_SKEW);
> > +                phy_write(phydev, MICREL_KSZ9021_EXTREG_DATA_WRITE, 0xf0f0);
> > +                phy_write(phydev, MICREL_KSZ9021_EXTREG_CTRL,
> > +			  MICREL_KSZ9021_RGMII_CLK_CTRL_PAD_SKEW);
> > +        }
> > +
> > +        return 0;
> > +}
> > +
> 
> All of this stuff is not needed as it's already taken care of by the
> Micrel phy driver. The clock skew values are now represented in the DTS.
> Please look at:
> 
> Documentation/devicetree/bindings/net/micrel-ksz90x1.txt

Aah, thanks for the pointer. 

At least socfpga_cyclone5_socrates.dts is in the mainline, but it does
not have any skew configuration. That may explain why the board seems
to have problems with ethernet... (or not).

Are there suitable default values?

u-boot uses these defaults:

include/configs/socfpga_common.h:#define CONFIG_KSZ9021_CLK_SKEW_VAL
0xf0f0
include/configs/socfpga_common.h:#define CONFIG_KSZ9021_DATA_SKEW_VAL
0x0

...that should correspond to txc-skew-ps == rxc-skew-ps == 3000, all
other skew values == 0?

Could someone with socrates board and network problems test if this
makes any difference?

Signed-off-by: Pavel Machek <pavel@denx.de>

diff --git a/arch/arm/boot/dts/socfpga_cyclone5_socrates.dts b/arch/arm/boot/dts/socfpga_cyclone5_socrates.dts
index a1814b4..eba8eea 100644
--- a/arch/arm/boot/dts/socfpga_cyclone5_socrates.dts
+++ b/arch/arm/boot/dts/socfpga_cyclone5_socrates.dts
@@ -34,6 +34,16 @@
 
 &gmac1 {
 	status = "okay";
+	phy-mode = "rgmii";
+
+	rxd0-skew-ps = <0>;
+	rxd1-skew-ps = <0>;
+	rxd2-skew-ps = <0>;
+	rxd3-skew-ps = <0>;
+	txen-skew-ps = <0>;
+	txc-skew-ps = <3000>;
+	rxdv-skew-ps = <0>;
+	rxc-skew-ps = <3000>;
 };
 
 &i2c0 {



-- 
(english) http://www.livejournal.com/~pavelmachek
(cesky, pictures) http://atrey.karlin.mff.cuni.cz/~pavel/picture/horses/blog.html
