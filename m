From: Ondrej Zary <linux@rainbow-software.org>
Subject: [PATCH 03/11] tlan: Add ethtool support
Date: Mon, 30 Jun 2014 18:38:29 +0200
Message-ID: <1404146317-3094-4-git-send-email-linux@rainbow-software.org>
References: <1404146317-3094-1-git-send-email-linux@rainbow-software.org>
Cc: netdev@vger.kernel.org, linux-kernel@vger.kernel.org
To: Samuel Chessman <chessman@tux.org>
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <1404146317-3094-1-git-send-email-linux@rainbow-software.org>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Add basic ethtool support to tlan driver:
 - driver info  - link detect (this allows NetworkManager to detect carrier)
 - EEPROM read

Signed-off-by: Ondrej Zary <linux@rainbow-software.org>
---
 drivers/net/ethernet/ti/tlan.c |   37 +++++++++++++++++++++++++++++++++++++
 drivers/net/ethernet/ti/tlan.h |    1 +
 2 files changed, 38 insertions(+)

diff --git a/drivers/net/ethernet/ti/tlan.c b/drivers/net/ethernet/ti/tlan.c
index c75ad6b..ae9fece 100644
--- a/drivers/net/ethernet/ti/tlan.c
+++ b/drivers/net/ethernet/ti/tlan.c
@@ -779,7 +779,43 @@ static const struct net_device_ops tlan_netdev_ops = {
 #endif
 };
 
+static void tlan_get_drvinfo(struct net_device *dev,
+			     struct ethtool_drvinfo *info)
+{
+	struct tlan_priv *priv = netdev_priv(dev);
+
+	strlcpy(info->driver, KBUILD_MODNAME, sizeof(info->driver));
+	if (priv->pci_dev)
+		strlcpy(info->bus_info, pci_name(priv->pci_dev),
+			sizeof(info->bus_info));
+	else
+		strlcpy(info->bus_info, "EISA",	sizeof(info->bus_info));
+	info->eedump_len = TLAN_EEPROM_SIZE;
+}
+
+static int tlan_get_eeprom_len(struct net_device *dev)
+{
+	return TLAN_EEPROM_SIZE;
+}
 
+static int tlan_get_eeprom(struct net_device *dev,
+			   struct ethtool_eeprom *eeprom, u8 *data)
+{
+	int i;
+
+	for (i = 0; i < TLAN_EEPROM_SIZE; i++)
+		if (tlan_ee_read_byte(dev, i, &data[i]))
+			return -EIO;
+
+	return 0;
+}
+
+static const struct ethtool_ops tlan_ethtool_ops = {
+	.get_drvinfo	= tlan_get_drvinfo,
+	.get_link	= ethtool_op_get_link,
+	.get_eeprom_len	= tlan_get_eeprom_len,
+	.get_eeprom	= tlan_get_eeprom,
+};
 
 /***************************************************************
  *	tlan_init
@@ -842,6 +878,7 @@ static int tlan_init(struct net_device *dev)
 
 	/* Device methods */
 	dev->netdev_ops = &tlan_netdev_ops;
+	dev->ethtool_ops = &tlan_ethtool_ops;
 	dev->watchdog_timeo = TX_TIMEOUT;
 
 	return 0;
diff --git a/drivers/net/ethernet/ti/tlan.h b/drivers/net/ethernet/ti/tlan.h
index 4ced905..b6ceeba 100644
--- a/drivers/net/ethernet/ti/tlan.h
+++ b/drivers/net/ethernet/ti/tlan.h
@@ -240,6 +240,7 @@ struct tlan_priv {
 #define TLAN_EEPROM_ACK		0
 #define TLAN_EEPROM_STOP	1
 
+#define TLAN_EEPROM_SIZE	256
 
 
 
-- 
Ondrej Zary
