From: Ursula Braun <ubraun@linux.vnet.ibm.com>
Subject: [PATCH net-next 09/13] s390/qeth: extract qeth_l2_remove_mac()
Date: Wed, 11 Jan 2017 12:55:56 +0100
Message-ID: <20170111115600.4524-10-ubraun@linux.vnet.ibm.com>
References: <20170111115600.4524-1-ubraun@linux.vnet.ibm.com>
Cc: netdev@vger.kernel.org, linux-s390@vger.kernel.org,
        schwidefsky@de.ibm.com, heiko.carstens@de.ibm.com,
        stable@vger.kernel.org, ubraun@linux.vnet.ibm.com
To: davem@davemloft.net
Return-path: <stable-owner@vger.kernel.org>
In-Reply-To: <20170111115600.4524-1-ubraun@linux.vnet.ibm.com>
Sender: stable-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

From: Julian Wiedmann <jwi@linux.vnet.ibm.com>

This matches qeth_l2_write_mac().

Signed-off-by: Julian Wiedmann <jwi@linux.vnet.ibm.com>
Signed-off-by: Ursula Braun <ubraun@linux.vnet.ibm.com>
Reviewed-by: Thomas Richter <tmricht@linux.vnet.ibm.com>
---
 drivers/s390/net/qeth_l2_main.c | 27 +++++++++++++--------------
 1 file changed, 13 insertions(+), 14 deletions(-)

diff --git a/drivers/s390/net/qeth_l2_main.c b/drivers/s390/net/qeth_l2_main.c
index 074fc62..d456740 100644
--- a/drivers/s390/net/qeth_l2_main.c
+++ b/drivers/s390/net/qeth_l2_main.c
@@ -200,16 +200,22 @@ static inline u32 qeth_l2_mac_hash(const u8 *addr)
 
 static int qeth_l2_write_mac(struct qeth_card *card, struct qeth_mac *mac)
 {
-
-	int rc;
-
 	if (mac->is_uc) {
-		rc = qeth_l2_send_setdelmac(card, mac->mac_addr,
+		return qeth_l2_send_setdelmac(card, mac->mac_addr,
 						IPA_CMD_SETVMAC);
 	} else {
-		rc = qeth_l2_send_setgroupmac(card, mac->mac_addr);
+		return qeth_l2_send_setgroupmac(card, mac->mac_addr);
+	}
+}
+
+static int qeth_l2_remove_mac(struct qeth_card *card, struct qeth_mac *mac)
+{
+	if (mac->is_uc) {
+		return qeth_l2_send_setdelmac(card, mac->mac_addr,
+						IPA_CMD_DELVMAC);
+	} else {
+		return qeth_l2_send_delgroupmac(card, mac->mac_addr);
 	}
-	return rc;
 }
 
 static void qeth_l2_del_all_macs(struct qeth_card *card)
@@ -782,14 +788,7 @@ static void qeth_l2_set_rx_mode(struct net_device *dev)
 
 	hash_for_each_safe(card->mac_htable, i, tmp, mac, hnode) {
 		if (mac->disp_flag == QETH_DISP_ADDR_DELETE) {
-			if (!mac->is_uc)
-				rc = qeth_l2_send_delgroupmac(card,
-						mac->mac_addr);
-			else {
-				rc = qeth_l2_send_setdelmac(card, mac->mac_addr,
-						IPA_CMD_DELVMAC);
-			}
-
+			qeth_l2_remove_mac(card, mac);
 			hash_del(&mac->hnode);
 			kfree(mac);
 
-- 
2.8.4
