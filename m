From: Aleksey Makarov <aleksey.makarov@caviumnetworks.com>
Subject: [PATCH 04/10] net: thunderx: rework mac address handling
Date: Tue, 2 Jun 2015 11:00:21 -0700
Message-ID: <1433268028-23992-5-git-send-email-aleksey.makarov@caviumnetworks.com>
References: <1433268028-23992-1-git-send-email-aleksey.makarov@caviumnetworks.com>
Mime-Version: 1.0
Content-Type: text/plain
Cc: <linux-kernel@vger.kernel.org>,
	<linux-arm-kernel@lists.infradead.org>,
	David Daney <david.daney@cavium.com>,
	Robert Richter <robert.richter@caviumnetworks.com>,
	Aleksey Makarov <aleksey.makarov@caviumnetworks.com>,
	Sunil Goutham <sgoutham@cavium.com>,
	Robert Richter <rric@kernel.org>
To: <netdev@vger.kernel.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-by2on0088.outbound.protection.outlook.com ([207.46.100.88]:34880
	"EHLO na01-by2-obe.outbound.protection.outlook.com"
	rhost-flags-OK-OK-OK-FAIL) by vger.kernel.org with ESMTP
	id S1759915AbbFBSBM (ORCPT <rfc822;netdev@vger.kernel.org>);
	Tue, 2 Jun 2015 14:01:12 -0400
In-Reply-To: <1433268028-23992-1-git-send-email-aleksey.makarov@caviumnetworks.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

This fixes sparse message:

drivers/net/ethernet/cavium/thunder/nicvf_main.c:385:40: sparse: cast to
restricted __le64

Reported-by: kbuild test robot <fengguang.wu@intel.com>
Signed-off-by: Aleksey Makarov <aleksey.makarov@caviumnetworks.com>
---
 drivers/net/ethernet/cavium/thunder/nic.h         | 4 ++--
 drivers/net/ethernet/cavium/thunder/nic_main.c    | 8 +-------
 drivers/net/ethernet/cavium/thunder/nicvf_main.c  | 8 ++------
 drivers/net/ethernet/cavium/thunder/thunder_bgx.c | 4 ++--
 drivers/net/ethernet/cavium/thunder/thunder_bgx.h | 4 ++--
 5 files changed, 9 insertions(+), 19 deletions(-)

diff --git a/drivers/net/ethernet/cavium/thunder/nic.h b/drivers/net/ethernet/cavium/thunder/nic.h
index 4f426db..6479ce2 100644
--- a/drivers/net/ethernet/cavium/thunder/nic.h
+++ b/drivers/net/ethernet/cavium/thunder/nic.h
@@ -301,7 +301,7 @@ struct nic_cfg_msg {
 	u8    vf_id;
 	u8    tns_mode;
 	u8    node_id;
-	u64   mac_addr;
+	u8    mac_addr[ETH_ALEN];
 };
 
 /* Qset configuration */
@@ -331,7 +331,7 @@ struct sq_cfg_msg {
 struct set_mac_msg {
 	u8    msg;
 	u8    vf_id;
-	u64   addr;
+	u8    mac_addr[ETH_ALEN];
 };
 
 /* Set Maximum frame size */
diff --git a/drivers/net/ethernet/cavium/thunder/nic_main.c b/drivers/net/ethernet/cavium/thunder/nic_main.c
index 3ca7ad8..6e0c031 100644
--- a/drivers/net/ethernet/cavium/thunder/nic_main.c
+++ b/drivers/net/ethernet/cavium/thunder/nic_main.c
@@ -492,7 +492,6 @@ static void nic_handle_mbx_intr(struct nicpf *nic, int vf)
 	u64 *mbx_data;
 	u64 mbx_addr;
 	u64 reg_addr;
-	u64 mac_addr;
 	int bgx, lmac;
 	int i;
 	int ret = 0;
@@ -555,12 +554,7 @@ static void nic_handle_mbx_intr(struct nicpf *nic, int vf)
 		lmac = mbx.mac.vf_id;
 		bgx = NIC_GET_BGX_FROM_VF_LMAC_MAP(nic->vf_lmac_map[lmac]);
 		lmac = NIC_GET_LMAC_FROM_VF_LMAC_MAP(nic->vf_lmac_map[lmac]);
-#ifdef __BIG_ENDIAN
-		mac_addr = cpu_to_be64(mbx.nic_cfg.mac_addr) << 16;
-#else
-		mac_addr = cpu_to_be64(mbx.nic_cfg.mac_addr) >> 16;
-#endif
-		bgx_set_lmac_mac(nic->node, bgx, lmac, (u8 *)&mac_addr);
+		bgx_set_lmac_mac(nic->node, bgx, lmac, mbx.mac.mac_addr);
 		break;
 	case NIC_MBOX_MSG_SET_MAX_FRS:
 		ret = nic_update_hw_frs(nic, mbx.frs.max_frs,
diff --git a/drivers/net/ethernet/cavium/thunder/nicvf_main.c b/drivers/net/ethernet/cavium/thunder/nicvf_main.c
index 989f005..54bba86 100644
--- a/drivers/net/ethernet/cavium/thunder/nicvf_main.c
+++ b/drivers/net/ethernet/cavium/thunder/nicvf_main.c
@@ -197,8 +197,7 @@ static void  nicvf_handle_mbx_intr(struct nicvf *nic)
 		nic->vf_id = mbx.nic_cfg.vf_id & 0x7F;
 		nic->tns_mode = mbx.nic_cfg.tns_mode & 0x7F;
 		nic->node = mbx.nic_cfg.node_id;
-		ether_addr_copy(nic->netdev->dev_addr,
-				(u8 *)&mbx.nic_cfg.mac_addr);
+		ether_addr_copy(nic->netdev->dev_addr, mbx.nic_cfg.mac_addr);
 		nic->link_up = false;
 		nic->duplex = 0;
 		nic->speed = 0;
@@ -248,13 +247,10 @@ static void  nicvf_handle_mbx_intr(struct nicvf *nic)
 static int nicvf_hw_set_mac_addr(struct nicvf *nic, struct net_device *netdev)
 {
 	union nic_mbx mbx = {};
-	int i;
 
 	mbx.mac.msg = NIC_MBOX_MSG_SET_MAC;
 	mbx.mac.vf_id = nic->vf_id;
-	for (i = 0; i < ETH_ALEN; i++)
-		mbx.mac.addr = (mbx.mac.addr << 8) |
-				     netdev->dev_addr[i];
+	ether_addr_copy(mbx.mac.mac_addr, netdev->dev_addr);
 
 	return nicvf_send_msg_to_pf(nic, &mbx);
 }
diff --git a/drivers/net/ethernet/cavium/thunder/thunder_bgx.c b/drivers/net/ethernet/cavium/thunder/thunder_bgx.c
index cde604a..a58924c 100644
--- a/drivers/net/ethernet/cavium/thunder/thunder_bgx.c
+++ b/drivers/net/ethernet/cavium/thunder/thunder_bgx.c
@@ -163,7 +163,7 @@ void bgx_get_lmac_link_state(int node, int bgx_idx, int lmacid, void *status)
 }
 EXPORT_SYMBOL(bgx_get_lmac_link_state);
 
-const char *bgx_get_lmac_mac(int node, int bgx_idx, int lmacid)
+const u8 *bgx_get_lmac_mac(int node, int bgx_idx, int lmacid)
 {
 	struct bgx *bgx = bgx_vnic[(node * MAX_BGX_PER_CN88XX) + bgx_idx];
 
@@ -174,7 +174,7 @@ const char *bgx_get_lmac_mac(int node, int bgx_idx, int lmacid)
 }
 EXPORT_SYMBOL(bgx_get_lmac_mac);
 
-void bgx_set_lmac_mac(int node, int bgx_idx, int lmacid, const char *mac)
+void bgx_set_lmac_mac(int node, int bgx_idx, int lmacid, const u8 *mac)
 {
 	struct bgx *bgx = bgx_vnic[(node * MAX_BGX_PER_CN88XX) + bgx_idx];
 
diff --git a/drivers/net/ethernet/cavium/thunder/thunder_bgx.h b/drivers/net/ethernet/cavium/thunder/thunder_bgx.h
index f9e2170..ba4f53b 100644
--- a/drivers/net/ethernet/cavium/thunder/thunder_bgx.h
+++ b/drivers/net/ethernet/cavium/thunder/thunder_bgx.h
@@ -183,8 +183,8 @@ enum MCAST_MODE {
 void bgx_add_dmac_addr(u64 dmac, int node, int bgx_idx, int lmac);
 unsigned bgx_get_map(int node);
 int bgx_get_lmac_count(int node, int bgx);
-const char *bgx_get_lmac_mac(int node, int bgx_idx, int lmacid);
-void bgx_set_lmac_mac(int node, int bgx_idx, int lmacid, const char *mac);
+const u8 *bgx_get_lmac_mac(int node, int bgx_idx, int lmacid);
+void bgx_set_lmac_mac(int node, int bgx_idx, int lmacid, const u8 *mac);
 void bgx_get_lmac_link_state(int node, int bgx_idx, int lmacid, void *status);
 u64 bgx_get_rx_stats(int node, int bgx_idx, int lmac, int idx);
 u64 bgx_get_tx_stats(int node, int bgx_idx, int lmac, int idx);
-- 
2.4.1
