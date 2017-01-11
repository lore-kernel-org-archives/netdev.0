From: Ursula Braun <ubraun@linux.vnet.ibm.com>
Subject: [PATCH net-next 08/13] s390/qeth: consolidate errno translation
Date: Wed, 11 Jan 2017 12:55:55 +0100
Message-ID: <20170111115600.4524-9-ubraun@linux.vnet.ibm.com>
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

Consolidate errno handling for MAC management: Instead of doing this in every
caller, do it in one place.

Signed-off-by: Julian Wiedmann <jwi@linux.vnet.ibm.com>
Signed-off-by: Ursula Braun <ubraun@linux.vnet.ibm.com>
Reviewed-by: Thomas Richter <tmricht@linux.vnet.ibm.com>
---
 drivers/s390/net/qeth_l2_main.c | 20 ++++++++------------
 1 file changed, 8 insertions(+), 12 deletions(-)

diff --git a/drivers/s390/net/qeth_l2_main.c b/drivers/s390/net/qeth_l2_main.c
index 38fae10..074fc62 100644
--- a/drivers/s390/net/qeth_l2_main.c
+++ b/drivers/s390/net/qeth_l2_main.c
@@ -170,8 +170,7 @@ static int qeth_l2_send_setgroupmac(struct qeth_card *card, __u8 *mac)
 	int rc;
 
 	QETH_CARD_TEXT(card, 2, "L2Sgmac");
-	rc = qeth_setdel_makerc(card, qeth_l2_send_setdelmac(card, mac,
-					IPA_CMD_SETGMAC));
+	rc = qeth_l2_send_setdelmac(card, mac, IPA_CMD_SETGMAC);
 	if (rc == -EEXIST)
 		QETH_DBF_MESSAGE(2, "Group MAC %pM already existing on %s\n",
 			mac, QETH_CARD_IFNAME(card));
@@ -186,8 +185,7 @@ static int qeth_l2_send_delgroupmac(struct qeth_card *card, __u8 *mac)
 	int rc;
 
 	QETH_CARD_TEXT(card, 2, "L2Dgmac");
-	rc = qeth_setdel_makerc(card, qeth_l2_send_setdelmac(card, mac,
-					IPA_CMD_DELGMAC));
+	rc = qeth_l2_send_setdelmac(card, mac, IPA_CMD_DELGMAC);
 	if (rc)
 		QETH_DBF_MESSAGE(2,
 			"Could not delete group MAC %pM on %s: %d\n",
@@ -206,9 +204,8 @@ static int qeth_l2_write_mac(struct qeth_card *card, struct qeth_mac *mac)
 	int rc;
 
 	if (mac->is_uc) {
-		rc = qeth_setdel_makerc(card,
-				qeth_l2_send_setdelmac(card, mac->mac_addr,
-						IPA_CMD_SETVMAC));
+		rc = qeth_l2_send_setdelmac(card, mac->mac_addr,
+						IPA_CMD_SETVMAC);
 	} else {
 		rc = qeth_l2_send_setgroupmac(card, mac->mac_addr);
 	}
@@ -582,7 +579,8 @@ static int qeth_l2_send_setdelmac(struct qeth_card *card, __u8 *mac,
 	cmd = (struct qeth_ipa_cmd *)(iob->data+IPA_PDU_HEADER_SIZE);
 	cmd->data.setdelmac.mac_length = OSA_ADDR_LEN;
 	memcpy(&cmd->data.setdelmac.mac, mac, OSA_ADDR_LEN);
-	return qeth_send_ipa_cmd(card, iob, NULL, NULL);
+	return qeth_setdel_makerc(card, qeth_send_ipa_cmd(card, iob,
+					NULL, NULL));
 }
 
 static int qeth_l2_send_setmac(struct qeth_card *card, __u8 *mac)
@@ -590,8 +588,7 @@ static int qeth_l2_send_setmac(struct qeth_card *card, __u8 *mac)
 	int rc;
 
 	QETH_CARD_TEXT(card, 2, "L2Setmac");
-	rc = qeth_setdel_makerc(card, qeth_l2_send_setdelmac(card, mac,
-					IPA_CMD_SETVMAC));
+	rc = qeth_l2_send_setdelmac(card, mac, IPA_CMD_SETVMAC);
 	if (rc == 0) {
 		card->info.mac_bits |= QETH_LAYER2_MAC_REGISTERED;
 		memcpy(card->dev->dev_addr, mac, OSA_ADDR_LEN);
@@ -621,8 +618,7 @@ static int qeth_l2_send_delmac(struct qeth_card *card, __u8 *mac)
 	QETH_CARD_TEXT(card, 2, "L2Delmac");
 	if (!(card->info.mac_bits & QETH_LAYER2_MAC_REGISTERED))
 		return 0;
-	rc = qeth_setdel_makerc(card, qeth_l2_send_setdelmac(card, mac,
-					IPA_CMD_DELVMAC));
+	rc = qeth_l2_send_setdelmac(card, mac, IPA_CMD_DELVMAC);
 	if (rc == 0)
 		card->info.mac_bits &= ~QETH_LAYER2_MAC_REGISTERED;
 	return rc;
-- 
2.8.4
