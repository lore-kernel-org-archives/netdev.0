From: Russell King - ARM Linux <linux-I+IVW8TIWO2tmTQ+vhA3Yw@public.gmane.org>
Subject: Re: [PATCHv2 net-next 11/16] net: mvpp2: handle misc PPv2.1/PPv2.2
 differences
Date: Sat, 7 Jan 2017 20:10:57 +0000
Message-ID: <20170107201057.GQ14217@n2100.armlinux.org.uk>
References: <1482943592-12556-1-git-send-email-thomas.petazzoni@free-electrons.com>
 <1482943592-12556-12-git-send-email-thomas.petazzoni@free-electrons.com>
 <20170107093834.GJ14217@n2100.armlinux.org.uk>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: Mark Rutland <mark.rutland-5wv7dgnIgG8@public.gmane.org>, devicetree-u79uwXL29TY76Z2rM5mHXA@public.gmane.org,
        Yehuda Yitschak <yehuday-eYqpPyKDWXRBDgjK7y7TUQ@public.gmane.org>,
        Jason Cooper <jason-NLaQJdtUoK4Be96aLqz0jA@public.gmane.org>,
        Pawel Moll <pawel.moll-5wv7dgnIgG8@public.gmane.org>,
        Ian Campbell <ijc+devicetree-KcIKpvwj1kUDXYZnReoRVg@public.gmane.org>,
        netdev-u79uwXL29TY76Z2rM5mHXA@public.gmane.org, Hanna Hawa <hannah-eYqpPyKDWXRBDgjK7y7TUQ@public.gmane.org>,
        Nadav Haklai <nadavh-eYqpPyKDWXRBDgjK7y7TUQ@public.gmane.org>,
        Rob Herring <robh+dt-DgEjT+Ai2ygdnm+yROfE0A@public.gmane.org>, Andrew Lunn <andrew-g2DYL2Zd6BY@public.gmane.org>,
        Kumar Gala <galak-sgV2jX0FEOL9JmXXK+q4OQ@public.gmane.org>,
        Gregory Clement <gregory.clement-wi1+55ScJUtKEb57/3fJTNBPR1lH4CV8@public.gmane.org>,
        Stefan Chulski <stefanc-eYqpPyKDWXRBDgjK7y7TUQ@public.gmane.org>,
        Marcin Wojtas <mw-nYOzD4b6Jr9Wk0Htik3J/w@public.gmane.org>,
        "David S. Miller" <davem-fT/PcQaiUtIeIZ0/mPfg9Q@public.gmane.org>,
        linux-arm-kernel-IAPFreCvJWM7uuMidbF8XUB+6BGkLq7r@public.gmane.org,
        Sebastian Hesselbarth <sebastian.hesselbarth-Re5JQEeQqe8AvxtiuMwx3w@public.gmane.org>
To: Thomas Petazzoni <thomas.petazzoni-wi1+55ScJUtKEb57/3fJTNBPR1lH4CV8@public.gmane.org>
Return-path: <devicetree-owner-u79uwXL29TY76Z2rM5mHXA@public.gmane.org>
Content-Disposition: inline
In-Reply-To: <20170107093834.GJ14217-l+eeeJia6m9URfEZ8mYm6t73F7V6hmMc@public.gmane.org>
Sender: devicetree-owner-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
List-Id: netdev.vger.kernel.org

On Sat, Jan 07, 2017 at 09:38:34AM +0000, Russell King - ARM Linux wrote:
> On Wed, Dec 28, 2016 at 05:46:27PM +0100, Thomas Petazzoni wrote:
> > @@ -6511,7 +6515,9 @@ static int mvpp2_port_probe(struct platform_device *pdev,
> >  		dev_err(&pdev->dev, "failed to init port %d\n", id);
> >  		goto err_free_stats;
> >  	}
> > -	mvpp2_port_power_up(port);
> > +
> > +	if (priv->hw_version == MVPP21)
> > +		mvpp21_port_power_up(port);
> 
> This has the side effect that nothing clears the port reset bit in the
> GMAC, which means there's no hope of the interface working - with the
> reset bit set, the port is well and truely held in "link down" state.
> 
> In any case, the GMAC part is much the same as mvneta, and I think
> that code should be shared rather than writing new versions of it.
> There are some subtle differences between neta, pp2.1 and pp2.2, but
> it's entirely doable (I have an implementation here as I wasn't going
> to duplicate this code for my phylink conversion.)

In addition to comphy configuration and the above, I also need the
following to have working SGMII.  The change of MACMODE is needed
because uboot has configured the port for 10Gbase-R mode (it has a
10G PHY on it, but the PHY switches to SGMII in <10G modes.)  The
GMAC control register 4 is needed to properly configure for SGMII
mode.  I also included RGMII mode as well in there, as I expect you'd
need it to have GMAC properly configured for RGMII.

With this in place (and the other bits mentioned above), I can ping
the clearfog switch on the other end of eth0's cable:

# ping6 -I eth0 fe80::250:43ff:fe02:302
PING fe80::250:43ff:fe02:302(fe80::250:43ff:fe02:302) from fe80::200:ff:fe00:1 eth0: 56 data bytes
64 bytes from fe80::250:43ff:fe02:302: icmp_seq=1 ttl=64 time=0.297 ms

diff --git a/drivers/net/ethernet/marvell/mvpp2.c b/drivers/net/ethernet/marvell/mvpp2.c
index bc97eebf7eee..4b6ec6213e9c 100644
--- a/drivers/net/ethernet/marvell/mvpp2.c
+++ b/drivers/net/ethernet/marvell/mvpp2.c
@@ -345,7 +345,17 @@
 #define      MVPP2_GMAC_TX_FIFO_MIN_TH_ALL_MASK	0x1fc0
 #define      MVPP2_GMAC_TX_FIFO_MIN_TH_MASK(v)	(((v) << 6) & \
 					MVPP2_GMAC_TX_FIFO_MIN_TH_ALL_MASK)
+#define MVPP22_GMAC_CTRL_4_REG			0x90
+#define      MVPP22_CTRL4_EXT_PIN_GMII_SEL	BIT(0)
+#define      MVPP22_CTRL4_DP_CLK_SEL		BIT(5)
+#define      MVPP22_CTRL4_SYNC_BYPASS		BIT(6)
+#define      MVPP22_CTRL4_QSGMII_BYPASS_ACTIVE	BIT(7)
+
+#define MVPP22_XLG_CTRL3_REG			0x11c
+#define      MVPP22_XLG_CTRL3_MACMODESELECT_MASK	(7 << 13)
+#define      MVPP22_XLG_CTRL3_MACMODESELECT_GMAC	(0 << 13)
 
+/* offsets from iface_base */
 #define MVPP22_SMI_MISC_CFG_REG			0x2a204
 #define      MVPP22_SMI_POLLING_EN		BIT(10)
 
@@ -4171,6 +4181,23 @@ static void mvpp2_port_mii_set(struct mvpp2_port *port)
 {
 	u32 val;
 
+	if (port->priv->hw_version == MVPP22) {
+		val = readl(port->base + MVPP22_XLG_CTRL3_REG);
+		val &= ~MVPP22_XLG_CTRL3_MACMODESELECT_MASK;
+		val |= MVPP22_XLG_CTRL3_MACMODESELECT_GMAC;
+		writel(val, port->base + MVPP22_XLG_CTRL3_REG);
+
+		val = readl(port->base + MVPP22_GMAC_CTRL_4_REG);
+		if (port->phy_interface == PHY_INTERFACE_MODE_RGMII)
+			val |= MVPP22_CTRL4_EXT_PIN_GMII_SEL;
+		else
+			val &= ~MVPP22_CTRL4_EXT_PIN_GMII_SEL;
+		val &= ~MVPP22_CTRL4_DP_CLK_SEL;
+		val |= MVPP22_CTRL4_SYNC_BYPASS;
+		val |= MVPP22_CTRL4_QSGMII_BYPASS_ACTIVE;
+		writel(val, port->base + MVPP22_GMAC_CTRL_4_REG);
+	}
+
 	val = readl(port->base + MVPP2_GMAC_CTRL_2_REG);
 
 	switch (port->phy_interface) {


-- 
RMK's Patch system: http://www.armlinux.org.uk/developer/patches/
FTTC broadband for 0.8mile line: currently at 9.6Mbps down 400kbps up
according to speedtest.net.
--
To unsubscribe from this list: send the line "unsubscribe devicetree" in
the body of a message to majordomo-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
More majordomo info at  http://vger.kernel.org/majordomo-info.html
