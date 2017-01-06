From: Murali Karicheri <m-karicheri2@ti.com>
Subject: [net-next v1 7/8] net: netcp: ale: use ale_status to size the ale table
Date: Fri, 6 Jan 2017 15:37:45 -0500
Message-ID: <1483735066-14632-8-git-send-email-m-karicheri2@ti.com>
References: <1483735066-14632-1-git-send-email-m-karicheri2@ti.com>
Mime-Version: 1.0
Content-Type: text/plain
To: <davem@davemloft.net>, <arnd@arndb.de>, <netdev@vger.kernel.org>,
        <linux-kernel@vger.kernel.org>, <mugunthanvnm@ti.com>,
        <linux-omap@vger.kernel.org>, <grygorii.strashko@ti.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from lelnx194.ext.ti.com ([198.47.27.80]:37647 "EHLO
        lelnx194.ext.ti.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1030249AbdAFUhy (ORCPT
        <rfc822;netdev@vger.kernel.org>); Fri, 6 Jan 2017 15:37:54 -0500
In-Reply-To: <1483735066-14632-1-git-send-email-m-karicheri2@ti.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

ALE h/w on newer version of NetCP (K2E/L/G) does provide a ALE_STATUS
register for the size of the ALE Table implemented in h/w. Currently
for example we set ALE Table size to 1024 for NetCP ALE on
K2E even though the ALE Status/Documentation shows it has 8192 entries.
So take advantage of this register to read the size of ALE table supported
and use that value in the driver for the newer version of NetCP ALE.
For NetCP lite, ALE Table size is much less (64) and indicated by a size
of zero in ALE_STATUS. So use that as a default for now. While at it,
also fix the ale table size on 10G switch to 2048 per User guide
http://www.ti.com/lit/ug/spruhj5/spruhj5.pdf

Signed-off-by: Murali Karicheri <m-karicheri2@ti.com>
Signed-off-by: Sekhar Nori <nsekhar@ti.com>
---
 drivers/net/ethernet/ti/cpsw_ale.c    | 31 ++++++++++++++++++++++++++++++-
 drivers/net/ethernet/ti/netcp_ethss.c |  4 +---
 2 files changed, 31 insertions(+), 4 deletions(-)

diff --git a/drivers/net/ethernet/ti/cpsw_ale.c b/drivers/net/ethernet/ti/cpsw_ale.c
index e15db39..62a18d6 100644
--- a/drivers/net/ethernet/ti/cpsw_ale.c
+++ b/drivers/net/ethernet/ti/cpsw_ale.c
@@ -33,6 +33,7 @@
 
 /* ALE Registers */
 #define ALE_IDVER		0x00
+#define ALE_STATUS		0x04
 #define ALE_CONTROL		0x08
 #define ALE_PRESCALE		0x10
 #define ALE_UNKNOWNVLAN		0x18
@@ -58,6 +59,10 @@
 #define ALE_UCAST_OUI			2
 #define ALE_UCAST_TOUCHED		3
 
+#define ALE_TABLE_SIZE_MULTIPLIER	1024
+#define ALE_STATUS_SIZE_MASK		0x1f
+#define ALE_TABLE_SIZE_DEFAULT		64
+
 static inline int cpsw_ale_get_field(u32 *ale_entry, u32 start, u32 bits)
 {
 	int idx;
@@ -728,7 +733,7 @@ static void cpsw_ale_timer(unsigned long arg)
 
 void cpsw_ale_start(struct cpsw_ale *ale)
 {
-	u32 rev;
+	u32 rev, ale_entries;
 
 	rev = __raw_readl(ale->params.ale_regs + ALE_IDVER);
 	if (!ale->params.major_ver_mask)
@@ -740,6 +745,30 @@ void cpsw_ale_start(struct cpsw_ale *ale)
 		 ALE_VERSION_MAJOR(rev, ale->params.major_ver_mask),
 		 ALE_VERSION_MINOR(rev));
 
+	if (!ale->params.ale_entries) {
+		ale_entries =
+			__raw_readl(ale->params.ale_regs + ALE_STATUS) &
+				    ALE_STATUS_SIZE_MASK;
+		/* ALE available on newer NetCP switches has introduced
+		 * a register, ALE_STATUS, to indicate the size of ALE
+		 * table which shows the size as a multiple of 1024 entries.
+		 * For these, params.ale_entries will be set to zero. So
+		 * read the register and update the value of ale_entries.
+		 * ALE table on NetCP lite, is much smaller and is indicated
+		 * by a value of zero in ALE_STATUS. So use a default value
+		 * of ALE_TABLE_SIZE_DEFAULT for this. Caller is expected
+		 * to set the value of ale_entries for all other versions
+		 * of ALE.
+		 */
+		if (!ale_entries)
+			ale_entries = ALE_TABLE_SIZE_DEFAULT;
+		else
+			ale_entries *= ALE_TABLE_SIZE_MULTIPLIER;
+		ale->params.ale_entries = ale_entries;
+	}
+	dev_info(ale->params.dev,
+		 "ALE Table size %ld\n", ale->params.ale_entries);
+
 	if (ale->params.nu_switch_ale) {
 		/* Separate registers for unknown vlan configuration.
 		 * Also there are N bits, where N is number of ale
diff --git a/drivers/net/ethernet/ti/netcp_ethss.c b/drivers/net/ethernet/ti/netcp_ethss.c
index e4a1862..f7bb241 100644
--- a/drivers/net/ethernet/ti/netcp_ethss.c
+++ b/drivers/net/ethernet/ti/netcp_ethss.c
@@ -81,7 +81,6 @@
 #define GBENU_CPTS_OFFSET		0x1d000
 #define GBENU_ALE_OFFSET		0x1e000
 #define GBENU_HOST_PORT_NUM		0
-#define GBENU_NUM_ALE_ENTRIES		1024
 #define GBENU_SGMII_MODULE_SIZE		0x100
 
 /* 10G Ethernet SS defines */
@@ -103,7 +102,7 @@
 #define XGBE10_ALE_OFFSET		0x700
 #define XGBE10_HW_STATS_OFFSET		0x800
 #define XGBE10_HOST_PORT_NUM		0
-#define XGBE10_NUM_ALE_ENTRIES		1024
+#define XGBE10_NUM_ALE_ENTRIES		2048
 
 #define	GBE_TIMER_INTERVAL			(HZ / 2)
 
@@ -3441,7 +3440,6 @@ static int set_gbenu_ethss_priv(struct gbe_priv *gbe_dev,
 	gbe_dev->ale_reg = gbe_dev->switch_regs + GBENU_ALE_OFFSET;
 	gbe_dev->ale_ports = gbe_dev->max_num_ports;
 	gbe_dev->host_port = GBENU_HOST_PORT_NUM;
-	gbe_dev->ale_entries = GBE13_NUM_ALE_ENTRIES;
 	gbe_dev->stats_en_mask = (1 << (gbe_dev->max_num_ports)) - 1;
 
 	/* Subsystem registers */
-- 
1.9.1
