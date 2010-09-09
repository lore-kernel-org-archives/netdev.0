From: Cyril Chemparathy <cyril@ti.com>
Subject: Re: [PATCH v3 00/10] split out emac cpdma and mdio for reuse
Date: Thu, 09 Sep 2010 17:24:14 -0400
Message-ID: <4C89507E.9040407@ti.com>
References: <1283891142-15522-1-git-send-email-cyril@ti.com>	<871v95f2xv.fsf@deeprootsystems.com>	<4C86F369.6040906@criticallink.com> <4C880733.5010909@ti.com>	<4C882EAA.9030903@criticallink.com>	<4C892AC0.80409@criticallink.com> <4C893ADE.809@ti.com>
Reply-To: cyril@ti.com
Mime-Version: 1.0
Content-Type: multipart/mixed;
 boundary="------------040904040607070104020200"
Cc: Michael Williamson <michael.williamson@criticallink.com>,
	"davinci-linux-open-source@linux.davincidsp.com"
	<davinci-linux-open-source@linux.davincidsp.com>,
	"netdev@vger.kernel.org" <netdev@vger.kernel.org>,
	"tony@atomide.com" <tony@atomide.com>,
	"linux-omap@vger.kernel.org" <linux-omap@vger.kernel.org>,
	"davem@davemloft.net" <davem@davemloft.net>
To: "Chemparathy, Cyril" <cyril@ti.com>
Return-path: <linux-omap-owner@vger.kernel.org>
In-Reply-To: <4C893ADE.809@ti.com>
Sender: linux-omap-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

This is a multi-part message in MIME format.
--------------040904040607070104020200
Content-Type: text/plain; charset=UTF-8
Content-Transfer-Encoding: 7bit

Hi Mike,

[...]
> An EMAC soft-reset clobbering the MDIO controller state is a
> possibility.  I will poll TI designers to see if this could be the case.

To test this theory out, I hacked up a crude
beat-it-to-death-and-see-if-it-breaks kinda patch (attached).  This
tests 10000 mdio read cycles while constantly doing an emac soft-reset.

I ran this on a dm365 evm, and the test didn't raise a single failed read:
> davinci_mdio davinci_mdio.0: davinci mdio revision 1.4
> davinci_mdio davinci_mdio.0: detected phy mask fffffffc
> 10000 test loops completed, 10000 reads ok

The failure in question seems to be limited to the da8xx family (tested
da830 evm), where:
> davinci_mdio davinci_mdio.0: davinci mdio revision 1.5
> davinci_mdio davinci_mdio.0: detected phy mask fffffff1
> idle triggered!!

The MDIO module upgrade (rev 1.4 -> 1.5) could have something to do with
this behavior.  Even so, I can't explain why this issue wasn't seen on
da8xx prior to this series.  The original code should (at least in
theory) have sporadically locked up on emac open.

Regards
Cyril.

--------------040904040607070104020200
Content-Type: text/x-patch;
 name="beat-emac-soft-reset.patch"
Content-Transfer-Encoding: 7bit
Content-Disposition: attachment;
 filename="beat-emac-soft-reset.patch"

diff --git a/drivers/net/davinci_mdio.c b/drivers/net/davinci_mdio.c
index d34a53a..8cd6d28 100644
--- a/drivers/net/davinci_mdio.c
+++ b/drivers/net/davinci_mdio.c
@@ -157,6 +157,56 @@ static int davinci_mdio_write(struct mii_bus *bus, int phy_id,
 	return 0;
 }
 
+#if 0 /* DM365 */
+#define EMAC_BASE			(0x01D07000)
+#define EMAC_CNTRL_OFFSET		(0x0000)
+#define PHY_ADDR			1
+#endif
+
+#if 1 /* DA8XX */
+#define EMAC_BASE			(0x01e20000)
+#define EMAC_CNTRL_OFFSET		(0x3000)
+#define PHY_ADDR			1	/* 1-3 is ok on da830 evm */
+#endif
+
+#define EMAC_SOFTRESET			(0x174)
+#define PHY_REG				MII_PHYSID1
+
+static void mdio_emac_soft_reset_test(struct davinci_mdio_data *data)
+{
+	struct davinci_mdio_regs __iomem *regs = data->regs;
+	int loops = 0, status_ok = 0;
+	void __iomem *emac;
+	u32 reg;
+
+	emac = ioremap(EMAC_BASE + EMAC_CNTRL_OFFSET, SZ_4K);
+	if (WARN_ON(!emac))
+		return;
+
+	for (loops = 0; loops < 10000; loops++) {
+		while (__raw_readl(&regs->user[0].access) &
+				USERACCESS_GO)
+			;
+
+		reg = (USERACCESS_GO | USERACCESS_READ |
+		       (PHY_REG << 21) | (PHY_ADDR << 16));
+		__raw_writel(reg, &regs->user[0].access);
+
+		while (__raw_readl(&regs->user[0].access) &
+				USERACCESS_GO) {
+			__raw_writel(1, emac + EMAC_SOFTRESET);
+			if (__raw_readl(&regs->control) & CONTROL_IDLE) {
+				printk(KERN_ERR "idle triggered!!\n");
+				return;
+			}
+		}
+		if (__raw_readl(&regs->user[0].access) & USERACCESS_ACK)
+			status_ok++;
+	}
+	printk(KERN_ERR "%d test loops completed, %d reads ok\n", loops,
+			status_ok);
+}
+
 static int __devinit davinci_mdio_probe(struct platform_device *pdev)
 {
 	struct mdio_platform_data *pdata = pdev->dev.platform_data;
@@ -262,6 +312,8 @@ static int __devinit davinci_mdio_probe(struct platform_device *pdev)
 	}
 	data->bus->phy_mask = phy_mask;
 
+	mdio_emac_soft_reset_test(data);
+
 	/* register the mii bus */
 	ret = mdiobus_register(data->bus);
 	if (ret)

--------------040904040607070104020200--
