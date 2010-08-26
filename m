From: Ville Sundell <ville.sundell@digilent.ro>
Subject: [PATCH] drivers/net/: ll_temac_main.c & ll_temac.h: Adding ethtool
 interface
Date: Thu, 26 Aug 2010 21:13:26 +0300
Message-ID: <1282846407.2081.79.camel@ville-desktop>
Mime-Version: 1.0
Content-Type: text/plain
Content-Transfer-Encoding: 7bit
Cc: john.linn@xilinx.com, dkirjanov@kernel.org, jpirko@redhat.com,
	netdev@vger.kernel.org, linux-kernel@vger.kernel.org,
	devicetree-discuss@lists.ozlabs.org,
	Joshua Pederson <josh@digilentinc.com>
To: davem@davemloft.net, grant.likely@secretlab.ca
Return-path: <linux-kernel-owner@vger.kernel.org>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

This patch adds an interface to the ethtool subsystem and
implements read/write functionality for handling settings with the
ethtool_cmd structure. "Speed" is the only setting implemented so far.
Other settings (like reading the duplex value) can be easily implemented
later on.

One can read the speed of the link by reading /sys/class/net/eth0/speed.
It seems that you can't write to /sys/class/net/eth0/speed, so the
"ethtool" command line utility must be used to set the speed.

So far, it is tested only in the DMA mode, since I don't have hardware
with DCR available.

Signed-off-by: Ville Sundell <ville.sundell@digilent.ro>
---

When using a non-static PHY and 100Mbit connection in Temac, the speed
is not changed and stays at the reset value (1000Mbit). This leads to a
situation where data is not sent or received correctly since
temac_adjust_link() is not called due to lack of static PHY.  Therefore
the link speed retains the reset value.

There is also no possibility to read or set the link speed from the user
space.

The patch is done against the newest version of ll_temac_main.cc and
ll_temac.h of the linux-next tree.

Thanks to Michal Simek for his feedback on this patch!

Regards,
Ville Sundell
Digilent Inc.

 drivers/net/ll_temac.h      |    3 ++
 drivers/net/ll_temac_main.c |   76 +++++++++++++++++++++++++++++++++++++++++++
 2 files changed, 79 insertions(+), 0 deletions(-)

diff --git a/drivers/net/ll_temac.h b/drivers/net/ll_temac.h
index 522abe2..ddd00cc 100644
--- a/drivers/net/ll_temac.h
+++ b/drivers/net/ll_temac.h
@@ -247,6 +247,9 @@ This option defaults to enabled (set) */
 #define XTE_EMCFG_LINKSPD_10		0x00000000 /* 10 Mbit LINKSPD_MASK */
 #define XTE_EMCFG_LINKSPD_100		(1 << 30)  /* 100 Mbit LINKSPD_MASK */
 #define XTE_EMCFG_LINKSPD_1000		(1 << 31)  /* 1000 Mbit LINKSPD_MASK */
+#define XTE_EMCFG_LINKSPD_NA		0xC0000000 /* For undefined speed */
+
+#define TEMAC_SPEED_NA			0 /* To indicate XTE_EMCFG_LINKSPD_NA */
 
 #define XTE_GMIC_OFFSET			0x00000320 /* RGMII/SGMII config */
 #define XTE_MC_OFFSET			0x00000340 /* MDIO configuration */
diff --git a/drivers/net/ll_temac_main.c b/drivers/net/ll_temac_main.c
index bdf2149..ae08fd4 100644
--- a/drivers/net/ll_temac_main.c
+++ b/drivers/net/ll_temac_main.c
@@ -951,6 +951,81 @@ static const struct attribute_group temac_attr_group = {
 	.attrs = temac_device_attrs,
 };
 
+/* Ethtool interface implementation
+ * SETTINGS
+ * With the following functions below, you can
+ * read and set following settings:
+ * Speed:
+ *	Speed of the TEMAC controller is indicated by two most significant bits
+ *	in the XTE_EMCFG_OFFSET register in the follwoing way:
+ *	00 = 10 Mbit connection
+ *	01 = 100 Mbit connection
+ *	10 = 1000 Mbit connection
+ *	11 = Undefined connection speed
+*/
+
+static int temac_get_settings(struct net_device *ndev, struct ethtool_cmd *cmd)
+{
+	struct temac_local *lp = netdev_priv(ndev);
+	u32 reg = temac_indirect_in32(lp, XTE_EMCFG_OFFSET);
+
+	switch (reg & XTE_EMCFG_LINKSPD_MASK) {
+	case XTE_EMCFG_LINKSPD_10:
+		cmd->speed = SPEED_10;
+		break;
+	case XTE_EMCFG_LINKSPD_100:
+		cmd->speed = SPEED_100;
+		break;
+	case XTE_EMCFG_LINKSPD_1000:
+		cmd->speed = SPEED_1000;
+		break;
+	default:
+		cmd->speed = TEMAC_SPEED_NA; /* Undefined speed */
+		break;
+	}
+
+	/* TODO: Insert more setting reading code here */
+
+	return 0;
+}
+
+static int temac_set_settings(struct net_device *ndev, struct ethtool_cmd *cmd)
+{
+	struct temac_local *lp = netdev_priv(ndev);
+	u32 reg = temac_indirect_in32(lp, XTE_EMCFG_OFFSET);
+
+	reg &= ~XTE_EMCFG_LINKSPD_MASK;
+	switch (cmd->speed) {
+	case SPEED_10:
+		reg |= XTE_EMCFG_LINKSPD_10;
+		break;
+	case SPEED_100:
+		reg |= XTE_EMCFG_LINKSPD_100;
+		break;
+	case SPEED_1000:
+		reg |= XTE_EMCFG_LINKSPD_1000;
+		break;
+	default:
+		reg |= XTE_EMCFG_LINKSPD_NA; /* Undefined speed */
+		break;
+	}
+
+	/* TODO: Insert more setting writing code here */
+
+	temac_indirect_out32(lp, XTE_EMCFG_OFFSET, reg);
+
+	return 0;
+}
+
+/*
+ * Defining the ethtool operations.
+ * This will be passed to the ethtool subsystem in the probe function
+ */
+static const struct ethtool_ops temac_ethtool_ops = {
+	.get_settings = temac_get_settings,
+	.set_settings = temac_set_settings,
+};
+
 static int __init
 temac_of_probe(struct platform_device *op, const struct of_device_id *match)
 {
@@ -970,6 +1045,7 @@ temac_of_probe(struct platform_device *op, const struct of_device_id *match)
 	ether_setup(ndev);
 	dev_set_drvdata(&op->dev, ndev);
 	SET_NETDEV_DEV(ndev, &op->dev);
+	SET_ETHTOOL_OPS(ndev, &temac_ethtool_ops);
 	ndev->flags &= ~IFF_MULTICAST;  /* clear multicast */
 	ndev->features = NETIF_F_SG | NETIF_F_FRAGLIST;
 	ndev->netdev_ops = &temac_netdev_ops;
