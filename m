From: Jiri Pirko <jiri@resnulli.us>
Subject: [patch net-next] ethtool: fix drvinfo strings set in drivers
Date: Sat,  5 Jan 2013 20:48:56 +0100
Message-ID: <1357415336-17807-1-git-send-email-jiri@resnulli.us>
Cc: davem@davemloft.net, edumazet@google.com,
	bhutchings@solarflare.com, shemminger@vyatta.com, fbl@redhat.com,
	sathya.perla@emulex.com, subbu.seetharaman@emulex.com,
	ajit.khaparde@emulex.com, roland@kernel.org, sean.hefty@intel.com,
	hal.rosenstock@gmail.com
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-ee0-f45.google.com ([74.125.83.45]:57167 "EHLO
	mail-ee0-f45.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1755832Ab3AETtE (ORCPT
	<rfc822;netdev@vger.kernel.org>); Sat, 5 Jan 2013 14:49:04 -0500
Received: by mail-ee0-f45.google.com with SMTP id d49so8435931eek.4
        for <netdev@vger.kernel.org>; Sat, 05 Jan 2013 11:49:02 -0800 (PST)
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Use strlcpy where possible to ensure the string is \0 terminated.
Use always sizeof(string) instead of 32 and custom defines.
Also use snprintf instead of strcpy in nes_nic.
Also do not do unnecessary init of drvinfo in spider_net_ethtool.

Signed-off-by: Jiri Pirko <jiri@resnulli.us>
---
 drivers/infiniband/hw/nes/nes_nic.c               | 12 +++++++-----
 drivers/infiniband/ulp/ipoib/ipoib_ethtool.c      |  2 +-
 drivers/net/bonding/bond_main.c                   |  9 +++++----
 drivers/net/ethernet/broadcom/bcm63xx_enet.c      |  9 +++++----
 drivers/net/ethernet/emulex/benet/be_ethtool.c    | 12 ++++++------
 drivers/net/ethernet/freescale/gianfar.h          |  2 --
 drivers/net/ethernet/freescale/gianfar_ethtool.c  |  9 +++++----
 drivers/net/ethernet/freescale/ucc_geth_ethtool.c |  8 ++++----
 drivers/net/ethernet/tehuti/tehuti.c              |  8 ++++----
 drivers/net/ethernet/toshiba/spider_net_ethtool.c | 12 +++++++-----
 drivers/net/macvlan.c                             |  4 ++--
 net/dsa/slave.c                                   |  8 ++++----
 12 files changed, 50 insertions(+), 45 deletions(-)

diff --git a/drivers/infiniband/hw/nes/nes_nic.c b/drivers/infiniband/hw/nes/nes_nic.c
index 9542e16..177cf76 100644
--- a/drivers/infiniband/hw/nes/nes_nic.c
+++ b/drivers/infiniband/hw/nes/nes_nic.c
@@ -1317,11 +1317,13 @@ static void nes_netdev_get_drvinfo(struct net_device *netdev,
 	struct nes_vnic *nesvnic = netdev_priv(netdev);
 	struct nes_adapter *nesadapter = nesvnic->nesdev->nesadapter;
 
-	strcpy(drvinfo->driver, DRV_NAME);
-	strcpy(drvinfo->bus_info, pci_name(nesvnic->nesdev->pcidev));
-	sprintf(drvinfo->fw_version, "%u.%u", nesadapter->firmware_version>>16,
-				nesadapter->firmware_version & 0x000000ff);
-	strcpy(drvinfo->version, DRV_VERSION);
+	strlcpy(drvinfo->driver, DRV_NAME, sizeof(drvinfo->driver));
+	strlcpy(drvinfo->bus_info, pci_name(nesvnic->nesdev->pcidev),
+		sizeof(drvinfo->bus_info));
+	snprintf(drvinfo->fw_version, sizeof(drvinfo->fw_version),
+		 "%u.%u", nesadapter->firmware_version >> 16,
+		 nesadapter->firmware_version & 0x000000ff);
+	strlcpy(drvinfo->version, DRV_VERSION, sizeof(drvinfo->version));
 	drvinfo->testinfo_len = 0;
 	drvinfo->eedump_len = 0;
 	drvinfo->regdump_len = 0;
diff --git a/drivers/infiniband/ulp/ipoib/ipoib_ethtool.c b/drivers/infiniband/ulp/ipoib/ipoib_ethtool.c
index 29bc7b5..ca13133 100644
--- a/drivers/infiniband/ulp/ipoib/ipoib_ethtool.c
+++ b/drivers/infiniband/ulp/ipoib/ipoib_ethtool.c
@@ -39,7 +39,7 @@
 static void ipoib_get_drvinfo(struct net_device *netdev,
 			      struct ethtool_drvinfo *drvinfo)
 {
-	strncpy(drvinfo->driver, "ipoib", sizeof(drvinfo->driver) - 1);
+	strlcpy(drvinfo->driver, "ipoib", sizeof(drvinfo->driver));
 }
 
 static int ipoib_get_coalesce(struct net_device *dev,
diff --git a/drivers/net/bonding/bond_main.c b/drivers/net/bonding/bond_main.c
index c495298..564cf42 100644
--- a/drivers/net/bonding/bond_main.c
+++ b/drivers/net/bonding/bond_main.c
@@ -4330,11 +4330,12 @@ void bond_set_mode_ops(struct bonding *bond, int mode)
 }
 
 static void bond_ethtool_get_drvinfo(struct net_device *bond_dev,
-				    struct ethtool_drvinfo *drvinfo)
+				     struct ethtool_drvinfo *drvinfo)
 {
-	strncpy(drvinfo->driver, DRV_NAME, 32);
-	strncpy(drvinfo->version, DRV_VERSION, 32);
-	snprintf(drvinfo->fw_version, 32, "%d", BOND_ABI_VERSION);
+	strlcpy(drvinfo->driver, DRV_NAME, sizeof(drvinfo->driver));
+	strlcpy(drvinfo->version, DRV_VERSION, sizeof(drvinfo->version));
+	snprintf(drvinfo->fw_version, sizeof(drvinfo->fw_version), "%d",
+		 BOND_ABI_VERSION);
 }
 
 static const struct ethtool_ops bond_ethtool_ops = {
diff --git a/drivers/net/ethernet/broadcom/bcm63xx_enet.c b/drivers/net/ethernet/broadcom/bcm63xx_enet.c
index 39387d6..d8a1510 100644
--- a/drivers/net/ethernet/broadcom/bcm63xx_enet.c
+++ b/drivers/net/ethernet/broadcom/bcm63xx_enet.c
@@ -1227,10 +1227,11 @@ static const u32 unused_mib_regs[] = {
 static void bcm_enet_get_drvinfo(struct net_device *netdev,
 				 struct ethtool_drvinfo *drvinfo)
 {
-	strncpy(drvinfo->driver, bcm_enet_driver_name, 32);
-	strncpy(drvinfo->version, bcm_enet_driver_version, 32);
-	strncpy(drvinfo->fw_version, "N/A", 32);
-	strncpy(drvinfo->bus_info, "bcm63xx", 32);
+	strlcpy(drvinfo->driver, bcm_enet_driver_name, sizeof(drvinfo->driver));
+	strlcpy(drvinfo->version, bcm_enet_driver_version,
+		sizeof(drvinfo->version));
+	strlcpy(drvinfo->fw_version, "N/A", sizeof(drvinfo->fw_version));
+	strlcpy(drvinfo->bus_info, "bcm63xx", sizeof(drvinfo->bus_info));
 	drvinfo->n_stats = BCM_ENET_STATS_LEN;
 }
 
diff --git a/drivers/net/ethernet/emulex/benet/be_ethtool.c b/drivers/net/ethernet/emulex/benet/be_ethtool.c
index 00454a1..76b302f 100644
--- a/drivers/net/ethernet/emulex/benet/be_ethtool.c
+++ b/drivers/net/ethernet/emulex/benet/be_ethtool.c
@@ -183,12 +183,12 @@ static void be_get_drvinfo(struct net_device *netdev,
 
 	strlcpy(drvinfo->driver, DRV_NAME, sizeof(drvinfo->driver));
 	strlcpy(drvinfo->version, DRV_VER, sizeof(drvinfo->version));
-	strncpy(drvinfo->fw_version, adapter->fw_ver, FW_VER_LEN);
-	if (memcmp(adapter->fw_ver, fw_on_flash, FW_VER_LEN) != 0) {
-		strcat(drvinfo->fw_version, " [");
-		strcat(drvinfo->fw_version, fw_on_flash);
-		strcat(drvinfo->fw_version, "]");
-	}
+	if (!memcmp(adapter->fw_ver, fw_on_flash, FW_VER_LEN))
+		strlcpy(drvinfo->fw_version, adapter->fw_ver,
+			sizeof(drvinfo->fw_version));
+	else
+		snprintf(drvinfo->fw_version, sizeof(drvinfo->fw_version),
+			 "%s [%s]", adapter->fw_ver, fw_on_flash);
 
 	strlcpy(drvinfo->bus_info, pci_name(adapter->pdev),
 		sizeof(drvinfo->bus_info));
diff --git a/drivers/net/ethernet/freescale/gianfar.h b/drivers/net/ethernet/freescale/gianfar.h
index 22eabc1..1b6a67c 100644
--- a/drivers/net/ethernet/freescale/gianfar.h
+++ b/drivers/net/ethernet/freescale/gianfar.h
@@ -649,8 +649,6 @@ struct gfar_extra_stats {
 /* Number of stats in the stats structure (ignore car and cam regs)*/
 #define GFAR_STATS_LEN (GFAR_RMON_LEN + GFAR_EXTRA_STATS_LEN)
 
-#define GFAR_INFOSTR_LEN 32
-
 struct gfar_stats {
 	u64 extra[GFAR_EXTRA_STATS_LEN];
 	u64 rmon[GFAR_RMON_LEN];
diff --git a/drivers/net/ethernet/freescale/gianfar_ethtool.c b/drivers/net/ethernet/freescale/gianfar_ethtool.c
index ab6762c..d0fe53c 100644
--- a/drivers/net/ethernet/freescale/gianfar_ethtool.c
+++ b/drivers/net/ethernet/freescale/gianfar_ethtool.c
@@ -184,10 +184,11 @@ static int gfar_sset_count(struct net_device *dev, int sset)
 static void gfar_gdrvinfo(struct net_device *dev,
 			  struct ethtool_drvinfo *drvinfo)
 {
-	strncpy(drvinfo->driver, DRV_NAME, GFAR_INFOSTR_LEN);
-	strncpy(drvinfo->version, gfar_driver_version, GFAR_INFOSTR_LEN);
-	strncpy(drvinfo->fw_version, "N/A", GFAR_INFOSTR_LEN);
-	strncpy(drvinfo->bus_info, "N/A", GFAR_INFOSTR_LEN);
+	strlcpy(drvinfo->driver, DRV_NAME, sizeof(drvinfo->driver));
+	strlcpy(drvinfo->version, gfar_driver_version,
+		sizeof(drvinfo->version));
+	strlcpy(drvinfo->fw_version, "N/A", sizeof(drvinfo->fw_version));
+	strlcpy(drvinfo->bus_info, "N/A", sizeof(drvinfo->bus_info));
 	drvinfo->regdump_len = 0;
 	drvinfo->eedump_len = 0;
 }
diff --git a/drivers/net/ethernet/freescale/ucc_geth_ethtool.c b/drivers/net/ethernet/freescale/ucc_geth_ethtool.c
index 37b0353..1ebf712 100644
--- a/drivers/net/ethernet/freescale/ucc_geth_ethtool.c
+++ b/drivers/net/ethernet/freescale/ucc_geth_ethtool.c
@@ -350,10 +350,10 @@ static void
 uec_get_drvinfo(struct net_device *netdev,
                        struct ethtool_drvinfo *drvinfo)
 {
-	strncpy(drvinfo->driver, DRV_NAME, 32);
-	strncpy(drvinfo->version, DRV_VERSION, 32);
-	strncpy(drvinfo->fw_version, "N/A", 32);
-	strncpy(drvinfo->bus_info, "QUICC ENGINE", 32);
+	strlcpy(drvinfo->driver, DRV_NAME, sizeof(drvinfo->driver));
+	strlcpy(drvinfo->version, DRV_VERSION, sizeof(drvinfo->version));
+	strlcpy(drvinfo->fw_version, "N/A", sizeof(drvinfo->fw_version));
+	strlcpy(drvinfo->bus_info, "QUICC ENGINE", sizeof(drvinfo->bus_info));
 	drvinfo->eedump_len = 0;
 	drvinfo->regdump_len = uec_get_regs_len(netdev);
 }
diff --git a/drivers/net/ethernet/tehuti/tehuti.c b/drivers/net/ethernet/tehuti/tehuti.c
index 1e4d743..e15cc71 100644
--- a/drivers/net/ethernet/tehuti/tehuti.c
+++ b/drivers/net/ethernet/tehuti/tehuti.c
@@ -2179,10 +2179,10 @@ bdx_get_drvinfo(struct net_device *netdev, struct ethtool_drvinfo *drvinfo)
 {
 	struct bdx_priv *priv = netdev_priv(netdev);
 
-	strlcat(drvinfo->driver, BDX_DRV_NAME, sizeof(drvinfo->driver));
-	strlcat(drvinfo->version, BDX_DRV_VERSION, sizeof(drvinfo->version));
-	strlcat(drvinfo->fw_version, "N/A", sizeof(drvinfo->fw_version));
-	strlcat(drvinfo->bus_info, pci_name(priv->pdev),
+	strlcpy(drvinfo->driver, BDX_DRV_NAME, sizeof(drvinfo->driver));
+	strlcpy(drvinfo->version, BDX_DRV_VERSION, sizeof(drvinfo->version));
+	strlcpy(drvinfo->fw_version, "N/A", sizeof(drvinfo->fw_version));
+	strlcpy(drvinfo->bus_info, pci_name(priv->pdev),
 		sizeof(drvinfo->bus_info));
 
 	drvinfo->n_stats = ((priv->stats_flag) ? ARRAY_SIZE(bdx_stat_names) : 0);
diff --git a/drivers/net/ethernet/toshiba/spider_net_ethtool.c b/drivers/net/ethernet/toshiba/spider_net_ethtool.c
index 9c288cd..ffe5193 100644
--- a/drivers/net/ethernet/toshiba/spider_net_ethtool.c
+++ b/drivers/net/ethernet/toshiba/spider_net_ethtool.c
@@ -72,11 +72,13 @@ spider_net_ethtool_get_drvinfo(struct net_device *netdev,
 	card = netdev_priv(netdev);
 
 	/* clear and fill out info */
-	memset(drvinfo, 0, sizeof(struct ethtool_drvinfo));
-	strncpy(drvinfo->driver, spider_net_driver_name, 32);
-	strncpy(drvinfo->version, VERSION, 32);
-	strcpy(drvinfo->fw_version, "no information");
-	strncpy(drvinfo->bus_info, pci_name(card->pdev), 32);
+	strlcpy(drvinfo->driver, spider_net_driver_name,
+		sizeof(drvinfo->driver));
+	strlcpy(drvinfo->version, VERSION, sizeof(drvinfo->version));
+	strlcpy(drvinfo->fw_version, "no information",
+		sizeof(drvinfo->fw_version));
+	strlcpy(drvinfo->bus_info, pci_name(card->pdev),
+		sizeof(drvinfo->bus_info));
 }
 
 static void
diff --git a/drivers/net/macvlan.c b/drivers/net/macvlan.c
index 0ae4518..1047e58 100644
--- a/drivers/net/macvlan.c
+++ b/drivers/net/macvlan.c
@@ -585,8 +585,8 @@ static int macvlan_fdb_del(struct ndmsg *ndm,
 static void macvlan_ethtool_get_drvinfo(struct net_device *dev,
 					struct ethtool_drvinfo *drvinfo)
 {
-	snprintf(drvinfo->driver, 32, "macvlan");
-	snprintf(drvinfo->version, 32, "0.1");
+	strlcpy(drvinfo->driver, "macvlan", sizeof(drvinfo->driver));
+	strlcpy(drvinfo->version, "0.1", sizeof(drvinfo->version));
 }
 
 static int macvlan_ethtool_get_settings(struct net_device *dev,
diff --git a/net/dsa/slave.c b/net/dsa/slave.c
index e32083d..f795b0c 100644
--- a/net/dsa/slave.c
+++ b/net/dsa/slave.c
@@ -203,10 +203,10 @@ dsa_slave_set_settings(struct net_device *dev, struct ethtool_cmd *cmd)
 static void dsa_slave_get_drvinfo(struct net_device *dev,
 				  struct ethtool_drvinfo *drvinfo)
 {
-	strncpy(drvinfo->driver, "dsa", 32);
-	strncpy(drvinfo->version, dsa_driver_version, 32);
-	strncpy(drvinfo->fw_version, "N/A", 32);
-	strncpy(drvinfo->bus_info, "platform", 32);
+	strlcpy(drvinfo->driver, "dsa", sizeof(drvinfo->driver));
+	strlcpy(drvinfo->version, dsa_driver_version, sizeof(drvinfo->version));
+	strlcpy(drvinfo->fw_version, "N/A", sizeof(drvinfo->fw_version));
+	strlcpy(drvinfo->bus_info, "platform", sizeof(drvinfo->bus_info));
 }
 
 static int dsa_slave_nway_reset(struct net_device *dev)
-- 
1.8.1
