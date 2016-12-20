From: Murali Karicheri <m-karicheri2-l0cyMroinI0@public.gmane.org>
Subject: [PATCH net-next 09/10] net: netcp: ale: use ale_status to size the ale table
Date: Tue, 20 Dec 2016 17:09:52 -0500
Message-ID: <1482271793-7671-10-git-send-email-m-karicheri2@ti.com>
References: <1482271793-7671-1-git-send-email-m-karicheri2@ti.com>
Mime-Version: 1.0
Content-Type: text/plain
To: <netdev-u79uwXL29TY76Z2rM5mHXA@public.gmane.org>, <linux-omap-u79uwXL29TY76Z2rM5mHXA@public.gmane.org>,
        <grygorii.strashko-l0cyMroinI0@public.gmane.org>, <mugunthanvnm-l0cyMroinI0@public.gmane.org>,
        <linux-kernel-u79uwXL29TY76Z2rM5mHXA@public.gmane.org>, <arnd-r2nGTMty4D4@public.gmane.org>,
        <davem-fT/PcQaiUtIeIZ0/mPfg9Q@public.gmane.org>, <devicetree-u79uwXL29TY76Z2rM5mHXA@public.gmane.org>,
        <mark.rutland-5wv7dgnIgG8@public.gmane.org>, <robh+dt-DgEjT+Ai2ygdnm+yROfE0A@public.gmane.org>
Return-path: <devicetree-owner-u79uwXL29TY76Z2rM5mHXA@public.gmane.org>
In-Reply-To: <1482271793-7671-1-git-send-email-m-karicheri2-l0cyMroinI0@public.gmane.org>
Sender: devicetree-owner-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
List-Id: netdev.vger.kernel.org

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

Signed-off-by: Murali Karicheri <m-karicheri2-l0cyMroinI0@public.gmane.org>
Signed-off-by: Sekhar Nori <nsekhar-l0cyMroinI0@public.gmane.org>
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
index b37fb73..80d68cb 100644
--- a/drivers/net/ethernet/ti/netcp_ethss.c
+++ b/drivers/net/ethernet/ti/netcp_ethss.c
@@ -94,7 +94,6 @@
 #define GBENU_CPTS_OFFSET		0x1d000
 #define GBENU_ALE_OFFSET		0x1e000
 #define GBENU_HOST_PORT_NUM		0
-#define GBENU_NUM_ALE_ENTRIES		1024
 
 /* 10G Ethernet SS defines */
 #define XGBE_MODULE_NAME		"netcp-xgbe"
@@ -114,7 +113,7 @@
 #define XGBE10_ALE_OFFSET		0x700
 #define XGBE10_HW_STATS_OFFSET		0x800
 #define XGBE10_HOST_PORT_NUM		0
-#define XGBE10_NUM_ALE_ENTRIES		1024
+#define XGBE10_NUM_ALE_ENTRIES		2048
 
 #define	GBE_TIMER_INTERVAL			(HZ / 2)
 
@@ -3548,7 +3547,6 @@ static int set_gbenu_ethss_priv(struct gbe_priv *gbe_dev,
 	gbe_dev->ale_reg = gbe_dev->switch_regs + GBENU_ALE_OFFSET;
 	gbe_dev->ale_ports = gbe_dev->max_num_ports;
 	gbe_dev->host_port = GBENU_HOST_PORT_NUM;
-	gbe_dev->ale_entries = GBE13_NUM_ALE_ENTRIES;
 	gbe_dev->stats_en_mask = (1 << (gbe_dev->max_num_ports)) - 1;
 
 	/* Subsystem registers */
-- 
1.9.1

--
To unsubscribe from this list: send the line "unsubscribe devicetree" in
the body of a message to majordomo-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
More majordomo info at  http://vger.kernel.org/majordomo-info.html
