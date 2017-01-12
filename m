From: Ursula Braun <ubraun@linux.vnet.ibm.com>
Subject: [PATCH RESEND net-next 10/12] s390/qeth: shuffle MAC management functions around
Date: Thu, 12 Jan 2017 15:48:41 +0100
Message-ID: <20170112144843.33463-11-ubraun@linux.vnet.ibm.com>
References: <20170112144843.33463-1-ubraun@linux.vnet.ibm.com>
Cc: netdev@vger.kernel.org, linux-s390@vger.kernel.org,
        schwidefsky@de.ibm.com, heiko.carstens@de.ibm.com,
        ubraun@linux.vnet.ibm.com
To: davem@davemloft.net
Return-path: <netdev-owner@vger.kernel.org>
Received: from mx0a-001b2d01.pphosted.com ([148.163.156.1]:42663 "EHLO
        mx0a-001b2d01.pphosted.com" rhost-flags-OK-OK-OK-OK)
        by vger.kernel.org with ESMTP id S1750791AbdALOtG (ORCPT
        <rfc822;netdev@vger.kernel.org>); Thu, 12 Jan 2017 09:49:06 -0500
Received: from pps.filterd (m0098394.ppops.net [127.0.0.1])
        by mx0a-001b2d01.pphosted.com (8.16.0.17/8.16.0.17) with SMTP id v0CEmwY6134162
        for <netdev@vger.kernel.org>; Thu, 12 Jan 2017 09:49:05 -0500
Received: from e06smtp09.uk.ibm.com (e06smtp09.uk.ibm.com [195.75.94.105])
        by mx0a-001b2d01.pphosted.com with ESMTP id 27xa63csjh-1
        (version=TLSv1.2 cipher=AES256-SHA bits=256 verify=NOT)
        for <netdev@vger.kernel.org>; Thu, 12 Jan 2017 09:49:04 -0500
Received: from localhost
        by e06smtp09.uk.ibm.com with IBM ESMTP SMTP Gateway: Authorized Use Only! Violators will be prosecuted
        for <netdev@vger.kernel.org> from <ubraun@linux.vnet.ibm.com>;
        Thu, 12 Jan 2017 14:49:02 -0000
In-Reply-To: <20170112144843.33463-1-ubraun@linux.vnet.ibm.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Julian Wiedmann <jwi@linux.vnet.ibm.com>

Move all MAC utility functions in one place, and drop the
forward declarations.

Signed-off-by: Julian Wiedmann <jwi@linux.vnet.ibm.com>
Reviewed-by: Thomas Richter <tmricht@linux.vnet.ibm.com>
---
 drivers/s390/net/qeth_l2_main.c | 129 ++++++++++++++++++++--------------------
 1 file changed, 63 insertions(+), 66 deletions(-)

diff --git a/drivers/s390/net/qeth_l2_main.c b/drivers/s390/net/qeth_l2_main.c
index d456740..c298759c 100644
--- a/drivers/s390/net/qeth_l2_main.c
+++ b/drivers/s390/net/qeth_l2_main.c
@@ -27,9 +27,6 @@
 
 static int qeth_l2_set_offline(struct ccwgroup_device *);
 static int qeth_l2_stop(struct net_device *);
-static int qeth_l2_send_delmac(struct qeth_card *, __u8 *);
-static int qeth_l2_send_setdelmac(struct qeth_card *, __u8 *,
-			   enum qeth_ipa_cmds);
 static void qeth_l2_set_rx_mode(struct net_device *);
 static int qeth_l2_recover(void *);
 static void qeth_bridgeport_query_support(struct qeth_card *card);
@@ -165,6 +162,64 @@ static int qeth_setdel_makerc(struct qeth_card *card, int retcode)
 	return rc;
 }
 
+static int qeth_l2_send_setdelmac(struct qeth_card *card, __u8 *mac,
+			   enum qeth_ipa_cmds ipacmd)
+{
+	struct qeth_ipa_cmd *cmd;
+	struct qeth_cmd_buffer *iob;
+
+	QETH_CARD_TEXT(card, 2, "L2sdmac");
+	iob = qeth_get_ipacmd_buffer(card, ipacmd, QETH_PROT_IPV4);
+	if (!iob)
+		return -ENOMEM;
+	cmd = (struct qeth_ipa_cmd *)(iob->data+IPA_PDU_HEADER_SIZE);
+	cmd->data.setdelmac.mac_length = OSA_ADDR_LEN;
+	memcpy(&cmd->data.setdelmac.mac, mac, OSA_ADDR_LEN);
+	return qeth_setdel_makerc(card, qeth_send_ipa_cmd(card, iob,
+					NULL, NULL));
+}
+
+static int qeth_l2_send_setmac(struct qeth_card *card, __u8 *mac)
+{
+	int rc;
+
+	QETH_CARD_TEXT(card, 2, "L2Setmac");
+	rc = qeth_l2_send_setdelmac(card, mac, IPA_CMD_SETVMAC);
+	if (rc == 0) {
+		card->info.mac_bits |= QETH_LAYER2_MAC_REGISTERED;
+		memcpy(card->dev->dev_addr, mac, OSA_ADDR_LEN);
+		dev_info(&card->gdev->dev,
+			"MAC address %pM successfully registered on device %s\n",
+			card->dev->dev_addr, card->dev->name);
+	} else {
+		card->info.mac_bits &= ~QETH_LAYER2_MAC_REGISTERED;
+		switch (rc) {
+		case -EEXIST:
+			dev_warn(&card->gdev->dev,
+				"MAC address %pM already exists\n", mac);
+			break;
+		case -EPERM:
+			dev_warn(&card->gdev->dev,
+				"MAC address %pM is not authorized\n", mac);
+			break;
+		}
+	}
+	return rc;
+}
+
+static int qeth_l2_send_delmac(struct qeth_card *card, __u8 *mac)
+{
+	int rc;
+
+	QETH_CARD_TEXT(card, 2, "L2Delmac");
+	if (!(card->info.mac_bits & QETH_LAYER2_MAC_REGISTERED))
+		return 0;
+	rc = qeth_l2_send_setdelmac(card, mac, IPA_CMD_DELVMAC);
+	if (rc == 0)
+		card->info.mac_bits &= ~QETH_LAYER2_MAC_REGISTERED;
+	return rc;
+}
+
 static int qeth_l2_send_setgroupmac(struct qeth_card *card, __u8 *mac)
 {
 	int rc;
@@ -193,11 +248,6 @@ static int qeth_l2_send_delgroupmac(struct qeth_card *card, __u8 *mac)
 	return rc;
 }
 
-static inline u32 qeth_l2_mac_hash(const u8 *addr)
-{
-	return get_unaligned((u32 *)(&addr[2]));
-}
-
 static int qeth_l2_write_mac(struct qeth_card *card, struct qeth_mac *mac)
 {
 	if (mac->is_uc) {
@@ -232,6 +282,11 @@ static void qeth_l2_del_all_macs(struct qeth_card *card)
 	spin_unlock_bh(&card->mclock);
 }
 
+static inline u32 qeth_l2_mac_hash(const u8 *addr)
+{
+	return get_unaligned((u32 *)(&addr[2]));
+}
+
 static inline int qeth_l2_get_cast_type(struct qeth_card *card,
 			struct sk_buff *skb)
 {
@@ -572,64 +627,6 @@ static int qeth_l2_poll(struct napi_struct *napi, int budget)
 	return work_done;
 }
 
-static int qeth_l2_send_setdelmac(struct qeth_card *card, __u8 *mac,
-			   enum qeth_ipa_cmds ipacmd)
-{
-	struct qeth_ipa_cmd *cmd;
-	struct qeth_cmd_buffer *iob;
-
-	QETH_CARD_TEXT(card, 2, "L2sdmac");
-	iob = qeth_get_ipacmd_buffer(card, ipacmd, QETH_PROT_IPV4);
-	if (!iob)
-		return -ENOMEM;
-	cmd = (struct qeth_ipa_cmd *)(iob->data+IPA_PDU_HEADER_SIZE);
-	cmd->data.setdelmac.mac_length = OSA_ADDR_LEN;
-	memcpy(&cmd->data.setdelmac.mac, mac, OSA_ADDR_LEN);
-	return qeth_setdel_makerc(card, qeth_send_ipa_cmd(card, iob,
-					NULL, NULL));
-}
-
-static int qeth_l2_send_setmac(struct qeth_card *card, __u8 *mac)
-{
-	int rc;
-
-	QETH_CARD_TEXT(card, 2, "L2Setmac");
-	rc = qeth_l2_send_setdelmac(card, mac, IPA_CMD_SETVMAC);
-	if (rc == 0) {
-		card->info.mac_bits |= QETH_LAYER2_MAC_REGISTERED;
-		memcpy(card->dev->dev_addr, mac, OSA_ADDR_LEN);
-		dev_info(&card->gdev->dev,
-			"MAC address %pM successfully registered on device %s\n",
-			card->dev->dev_addr, card->dev->name);
-	} else {
-		card->info.mac_bits &= ~QETH_LAYER2_MAC_REGISTERED;
-		switch (rc) {
-		case -EEXIST:
-			dev_warn(&card->gdev->dev,
-				"MAC address %pM already exists\n", mac);
-			break;
-		case -EPERM:
-			dev_warn(&card->gdev->dev,
-				"MAC address %pM is not authorized\n", mac);
-			break;
-		}
-	}
-	return rc;
-}
-
-static int qeth_l2_send_delmac(struct qeth_card *card, __u8 *mac)
-{
-	int rc;
-
-	QETH_CARD_TEXT(card, 2, "L2Delmac");
-	if (!(card->info.mac_bits & QETH_LAYER2_MAC_REGISTERED))
-		return 0;
-	rc = qeth_l2_send_setdelmac(card, mac, IPA_CMD_DELVMAC);
-	if (rc == 0)
-		card->info.mac_bits &= ~QETH_LAYER2_MAC_REGISTERED;
-	return rc;
-}
-
 static int qeth_l2_request_initial_mac(struct qeth_card *card)
 {
 	int rc = 0;
-- 
2.8.4
