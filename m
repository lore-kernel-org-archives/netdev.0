From: Hayes Wang <hayeswang@realtek.com>
Subject: [PATCH net-next 04/14] r8152: load the default MAC address
Date: Tue, 18 Feb 2014 21:49:01 +0800
Message-ID: <1392731351-25502-5-git-send-email-hayeswang@realtek.com>
References: <1392731351-25502-1-git-send-email-hayeswang@realtek.com>
Mime-Version: 1.0
Content-Type: text/plain
Cc: <nic_swsd@realtek.com>, <linux-kernel@vger.kernel.org>,
	<linux-usb@vger.kernel.org>, Hayes Wang <hayeswang@realtek.com>
To: <netdev@vger.kernel.org>
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <1392731351-25502-1-git-send-email-hayeswang@realtek.com>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Except for RTL_VER_01, replace loading the MAC address from PLA_IDR
with from PLA_BACKUP. The default MAC address may be modified by
the other OS, so the PLA_IDR may be not the default MAC address.

The data in the PLA_BACKUP address of the RTL_VER_01 may be destoryed,
so load MAC address from PLA_IDR for RTL_VER_01.

Signed-off-by: Hayes Wang <hayeswang@realtek.com>
---
 drivers/net/usb/r8152.c | 19 +++++++++++++++++--
 1 file changed, 17 insertions(+), 2 deletions(-)

diff --git a/drivers/net/usb/r8152.c b/drivers/net/usb/r8152.c
index 4888e4f..3847c35 100644
--- a/drivers/net/usb/r8152.c
+++ b/drivers/net/usb/r8152.c
@@ -889,11 +889,26 @@ int r8152_submit_rx(struct r8152 *tp, struct rx_agg *agg, gfp_t mem_flags);
 static inline void set_ethernet_addr(struct r8152 *tp)
 {
 	struct net_device *dev = tp->netdev;
+	int ret;
 	u8 node_id[8] = {0};
 
-	if (pla_ocp_read(tp, PLA_IDR, sizeof(node_id), node_id) < 0)
+	if (tp->version == RTL_VER_01)
+		ret = pla_ocp_read(tp, PLA_IDR, sizeof(node_id), node_id);
+	else
+		ret = pla_ocp_read(tp, PLA_BACKUP, sizeof(node_id), node_id);
+
+	if (ret < 0) {
 		netif_notice(tp, probe, dev, "inet addr fail\n");
-	else {
+	} else {
+		if (tp->version != RTL_VER_01) {
+			ocp_write_byte(tp, MCU_TYPE_PLA, PLA_CRWECR,
+				       CRWECR_CONFIG);
+			pla_ocp_write(tp, PLA_IDR, BYTE_EN_SIX_BYTES,
+				      sizeof(node_id), node_id);
+			ocp_write_byte(tp, MCU_TYPE_PLA, PLA_CRWECR,
+				       CRWECR_NORAML);
+		}
+
 		memcpy(dev->dev_addr, node_id, dev->addr_len);
 		memcpy(dev->perm_addr, dev->dev_addr, dev->addr_len);
 	}
-- 
1.8.4.2
