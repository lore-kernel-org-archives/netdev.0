From: sunil.kovvuri@gmail.com
Subject: [PATCH v2 3/4] net: thunderx: Fix invalid mac addresses for node1
 interfaces
Date: Tue,  7 Mar 2017 18:09:10 +0530
Message-ID: <1488890351-18493-4-git-send-email-sunil.kovvuri@gmail.com>
References: <1488890351-18493-1-git-send-email-sunil.kovvuri@gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
Cc: Sunil Goutham <sgoutham@cavium.com>, linux-kernel@vger.kernel.org,
 linux-arm-kernel@lists.infradead.org
To: netdev@vger.kernel.org
Return-path: <linux-arm-kernel-bounces+linux-arm-kernel=m.gmane.org@lists.infradead.org>
In-Reply-To: <1488890351-18493-1-git-send-email-sunil.kovvuri@gmail.com>
List-Unsubscribe: <http://lists.infradead.org/mailman/options/linux-arm-kernel>,
 <mailto:linux-arm-kernel-request@lists.infradead.org?subject=unsubscribe>
List-Archive: <http://lists.infradead.org/pipermail/linux-arm-kernel/>
List-Post: <mailto:linux-arm-kernel@lists.infradead.org>
List-Help: <mailto:linux-arm-kernel-request@lists.infradead.org?subject=help>
List-Subscribe: <http://lists.infradead.org/mailman/listinfo/linux-arm-kernel>,
 <mailto:linux-arm-kernel-request@lists.infradead.org?subject=subscribe>
Sender: "linux-arm-kernel" <linux-arm-kernel-bounces@lists.infradead.org>
Errors-To: linux-arm-kernel-bounces+linux-arm-kernel=m.gmane.org@lists.infradead.org
List-Id: netdev.vger.kernel.org

From: Sunil Goutham <sgoutham@cavium.com>

When booted with ACPI, random mac addresses are being
assigned to node1 interfaces due to mismatch of bgx_id
in BGX driver and ACPI tables.

This patch fixes this issue by setting maximum BGX devices
per node based on platform/soc instead of a macro. This
change will set the bgx_id appropriately.

Signed-off-by: Sunil Goutham <sgoutham@cavium.com>
---
 drivers/net/ethernet/cavium/thunder/thunder_bgx.c | 58 ++++++++++++++++++-----
 drivers/net/ethernet/cavium/thunder/thunder_bgx.h |  1 -
 2 files changed, 45 insertions(+), 14 deletions(-)

diff --git a/drivers/net/ethernet/cavium/thunder/thunder_bgx.c b/drivers/net/ethernet/cavium/thunder/thunder_bgx.c
index 9b8a53e..64a1095 100644
--- a/drivers/net/ethernet/cavium/thunder/thunder_bgx.c
+++ b/drivers/net/ethernet/cavium/thunder/thunder_bgx.c
@@ -123,14 +123,44 @@ static int bgx_poll_reg(struct bgx *bgx, u8 lmac, u64 reg, u64 mask, bool zero)
 	return 1;
 }
 
+static int max_bgx_per_node;
+static void set_max_bgx_per_node(struct pci_dev *pdev)
+{
+	u16 sdevid;
+
+	if (max_bgx_per_node)
+		return;
+
+	pci_read_config_word(pdev, PCI_SUBSYSTEM_ID, &sdevid);
+	switch (sdevid) {
+	case PCI_SUBSYS_DEVID_81XX_BGX:
+		max_bgx_per_node = MAX_BGX_PER_CN81XX;
+		break;
+	case PCI_SUBSYS_DEVID_83XX_BGX:
+		max_bgx_per_node = MAX_BGX_PER_CN83XX;
+		break;
+	case PCI_SUBSYS_DEVID_88XX_BGX:
+	default:
+		max_bgx_per_node = MAX_BGX_PER_CN88XX;
+		break;
+	}
+}
+
+static struct bgx *get_bgx(int node, int bgx_idx)
+{
+	int idx = (node * max_bgx_per_node) + bgx_idx;
+
+	return bgx_vnic[idx];
+}
+
 /* Return number of BGX present in HW */
 unsigned bgx_get_map(int node)
 {
 	int i;
 	unsigned map = 0;
 
-	for (i = 0; i < MAX_BGX_PER_NODE; i++) {
-		if (bgx_vnic[(node * MAX_BGX_PER_NODE) + i])
+	for (i = 0; i < max_bgx_per_node; i++) {
+		if (bgx_vnic[(node * max_bgx_per_node) + i])
 			map |= (1 << i);
 	}
 
@@ -143,7 +173,7 @@ int bgx_get_lmac_count(int node, int bgx_idx)
 {
 	struct bgx *bgx;
 
-	bgx = bgx_vnic[(node * MAX_BGX_PER_NODE) + bgx_idx];
+	bgx = get_bgx(node, bgx_idx);
 	if (bgx)
 		return bgx->lmac_count;
 
@@ -158,7 +188,7 @@ void bgx_get_lmac_link_state(int node, int bgx_idx, int lmacid, void *status)
 	struct bgx *bgx;
 	struct lmac *lmac;
 
-	bgx = bgx_vnic[(node * MAX_BGX_PER_NODE) + bgx_idx];
+	bgx = get_bgx(node, bgx_idx);
 	if (!bgx)
 		return;
 
@@ -172,7 +202,7 @@ EXPORT_SYMBOL(bgx_get_lmac_link_state);
 
 const u8 *bgx_get_lmac_mac(int node, int bgx_idx, int lmacid)
 {
-	struct bgx *bgx = bgx_vnic[(node * MAX_BGX_PER_NODE) + bgx_idx];
+	struct bgx *bgx = get_bgx(node, bgx_idx);
 
 	if (bgx)
 		return bgx->lmac[lmacid].mac;
@@ -183,7 +213,7 @@ EXPORT_SYMBOL(bgx_get_lmac_mac);
 
 void bgx_set_lmac_mac(int node, int bgx_idx, int lmacid, const u8 *mac)
 {
-	struct bgx *bgx = bgx_vnic[(node * MAX_BGX_PER_NODE) + bgx_idx];
+	struct bgx *bgx = get_bgx(node, bgx_idx);
 
 	if (!bgx)
 		return;
@@ -194,7 +224,7 @@ EXPORT_SYMBOL(bgx_set_lmac_mac);
 
 void bgx_lmac_rx_tx_enable(int node, int bgx_idx, int lmacid, bool enable)
 {
-	struct bgx *bgx = bgx_vnic[(node * MAX_BGX_PER_NODE) + bgx_idx];
+	struct bgx *bgx = get_bgx(node, bgx_idx);
 	struct lmac *lmac;
 	u64 cfg;
 
@@ -217,7 +247,7 @@ EXPORT_SYMBOL(bgx_lmac_rx_tx_enable);
 void bgx_lmac_get_pfc(int node, int bgx_idx, int lmacid, void *pause)
 {
 	struct pfc *pfc = (struct pfc *)pause;
-	struct bgx *bgx = bgx_vnic[(node * MAX_BGX_PER_CN88XX) + bgx_idx];
+	struct bgx *bgx = get_bgx(node, bgx_idx);
 	struct lmac *lmac;
 	u64 cfg;
 
@@ -237,7 +267,7 @@ EXPORT_SYMBOL(bgx_lmac_get_pfc);
 void bgx_lmac_set_pfc(int node, int bgx_idx, int lmacid, void *pause)
 {
 	struct pfc *pfc = (struct pfc *)pause;
-	struct bgx *bgx = bgx_vnic[(node * MAX_BGX_PER_CN88XX) + bgx_idx];
+	struct bgx *bgx = get_bgx(node, bgx_idx);
 	struct lmac *lmac;
 	u64 cfg;
 
@@ -369,7 +399,7 @@ u64 bgx_get_rx_stats(int node, int bgx_idx, int lmac, int idx)
 {
 	struct bgx *bgx;
 
-	bgx = bgx_vnic[(node * MAX_BGX_PER_NODE) + bgx_idx];
+	bgx = get_bgx(node, bgx_idx);
 	if (!bgx)
 		return 0;
 
@@ -383,7 +413,7 @@ u64 bgx_get_tx_stats(int node, int bgx_idx, int lmac, int idx)
 {
 	struct bgx *bgx;
 
-	bgx = bgx_vnic[(node * MAX_BGX_PER_NODE) + bgx_idx];
+	bgx = get_bgx(node, bgx_idx);
 	if (!bgx)
 		return 0;
 
@@ -411,7 +441,7 @@ void bgx_lmac_internal_loopback(int node, int bgx_idx,
 	struct lmac *lmac;
 	u64    cfg;
 
-	bgx = bgx_vnic[(node * MAX_BGX_PER_NODE) + bgx_idx];
+	bgx = get_bgx(node, bgx_idx);
 	if (!bgx)
 		return;
 
@@ -1328,11 +1358,13 @@ static int bgx_probe(struct pci_dev *pdev, const struct pci_device_id *ent)
 		goto err_release_regions;
 	}
 
+	set_max_bgx_per_node(pdev);
+
 	pci_read_config_word(pdev, PCI_DEVICE_ID, &sdevid);
 	if (sdevid != PCI_DEVICE_ID_THUNDER_RGX) {
 		bgx->bgx_id = (pci_resource_start(pdev,
 			PCI_CFG_REG_BAR_NUM) >> 24) & BGX_ID_MASK;
-		bgx->bgx_id += nic_get_node_id(pdev) * MAX_BGX_PER_NODE;
+		bgx->bgx_id += nic_get_node_id(pdev) * max_bgx_per_node;
 		bgx->max_lmac = MAX_LMAC_PER_BGX;
 		bgx_vnic[bgx->bgx_id] = bgx;
 	} else {
diff --git a/drivers/net/ethernet/cavium/thunder/thunder_bgx.h b/drivers/net/ethernet/cavium/thunder/thunder_bgx.h
index a60f189..c5080f2c 100644
--- a/drivers/net/ethernet/cavium/thunder/thunder_bgx.h
+++ b/drivers/net/ethernet/cavium/thunder/thunder_bgx.h
@@ -22,7 +22,6 @@
 #define    MAX_BGX_PER_CN88XX			2
 #define    MAX_BGX_PER_CN81XX			3 /* 2 BGXs + 1 RGX */
 #define    MAX_BGX_PER_CN83XX			4
-#define    MAX_BGX_PER_NODE			4
 #define    MAX_LMAC_PER_BGX			4
 #define    MAX_BGX_CHANS_PER_LMAC		16
 #define    MAX_DMAC_PER_LMAC			8
-- 
2.7.4
