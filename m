From: Ursula Braun <ubraun@linux.vnet.ibm.com>
Subject: [PATCH net-next 5/8] qeth use common function qeth_get_setassparms_cmd
Date: Fri, 11 Dec 2015 12:27:54 +0100
Message-ID: <1449833277-69012-6-git-send-email-ubraun@linux.vnet.ibm.com>
References: <1449833277-69012-1-git-send-email-ubraun@linux.vnet.ibm.com>
Cc: ubraunu@linux.vnet.ibm.com
To: davem@davemloft.net, mschwid2@linux.vnet.ibm.com,
	heicars2@linux.vnet.ibm.com, netdev@vger.kernel.org,
	linux-s390@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from e06smtp09.uk.ibm.com ([195.75.94.105]:40428 "EHLO
	e06smtp09.uk.ibm.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1755113AbbLKL2H (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 11 Dec 2015 06:28:07 -0500
Received: from localhost
	by e06smtp09.uk.ibm.com with IBM ESMTP SMTP Gateway: Authorized Use Only! Violators will be prosecuted
	for <netdev@vger.kernel.org> from <ubraun@linux.vnet.ibm.com>;
	Fri, 11 Dec 2015 11:28:06 -0000
In-Reply-To: <1449833277-69012-1-git-send-email-ubraun@linux.vnet.ibm.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Thomas Richter <tmricht@linux.vnet.ibm.com>

There have been 2 identical versions of function
qeth_get_setassparms_cmd() for layer 2 and layer 3.
Remove the layer 3 function qeth_l3_get_setassparms_cmd()
and call the common one named qeth_get_setassparms_cmd()
located in qeth_core_main.c

Signed-off-by: Thomas Richter <tmricht@linux.vnet.ibm.com>
Signed-off-by: Ursula Braun <ubraun@linux.vnet.ibm.com>
Reviewed-by: Eugene Crosser <Eugene.Crosser@ru.ibm.com>
---
 drivers/s390/net/qeth_core.h      |  4 ++++
 drivers/s390/net/qeth_core_main.c |  9 +++++----
 drivers/s390/net/qeth_l3_main.c   | 37 ++++++++-----------------------------
 3 files changed, 17 insertions(+), 33 deletions(-)

diff --git a/drivers/s390/net/qeth_core.h b/drivers/s390/net/qeth_core.h
index 1766a20..ec2e014 100644
--- a/drivers/s390/net/qeth_core.h
+++ b/drivers/s390/net/qeth_core.h
@@ -981,6 +981,10 @@ int qeth_send_setassparms(struct qeth_card *, struct qeth_cmd_buffer *, __u16,
 			  int (*reply_cb)(struct qeth_card *,
 					  struct qeth_reply *, unsigned long),
 			  void *);
+struct qeth_cmd_buffer *qeth_get_setassparms_cmd(struct qeth_card *,
+						 enum qeth_ipa_funcs,
+						 __u16, __u16,
+						 enum qeth_prot_versions);
 int qeth_start_ipa_tx_checksum(struct qeth_card *);
 int qeth_set_rx_csum(struct qeth_card *, int);
 
diff --git a/drivers/s390/net/qeth_core_main.c b/drivers/s390/net/qeth_core_main.c
index 31ac53f..fe1845a 100644
--- a/drivers/s390/net/qeth_core_main.c
+++ b/drivers/s390/net/qeth_core_main.c
@@ -5297,10 +5297,10 @@ static int qeth_setassparms_cb(struct qeth_card *card,
 	return 0;
 }
 
-static struct qeth_cmd_buffer *qeth_get_setassparms_cmd(struct qeth_card *card,
-						  enum qeth_ipa_funcs ipa_func,
-						  __u16 cmd_code, __u16 len,
-						  enum qeth_prot_versions prot)
+struct qeth_cmd_buffer *qeth_get_setassparms_cmd(struct qeth_card *card,
+						 enum qeth_ipa_funcs ipa_func,
+						 __u16 cmd_code, __u16 len,
+						 enum qeth_prot_versions prot)
 {
 	struct qeth_cmd_buffer *iob;
 	struct qeth_ipa_cmd *cmd;
@@ -5319,6 +5319,7 @@ static struct qeth_cmd_buffer *qeth_get_setassparms_cmd(struct qeth_card *card,
 
 	return iob;
 }
+EXPORT_SYMBOL_GPL(qeth_get_setassparms_cmd);
 
 int qeth_send_setassparms(struct qeth_card *card,
 			  struct qeth_cmd_buffer *iob, __u16 len, long data,
diff --git a/drivers/s390/net/qeth_l3_main.c b/drivers/s390/net/qeth_l3_main.c
index 543960e..e2eb88c 100644
--- a/drivers/s390/net/qeth_l3_main.c
+++ b/drivers/s390/net/qeth_l3_main.c
@@ -1043,28 +1043,6 @@ static int qeth_l3_default_setassparms_cb(struct qeth_card *card,
 	return 0;
 }
 
-static struct qeth_cmd_buffer *qeth_l3_get_setassparms_cmd(
-	struct qeth_card *card, enum qeth_ipa_funcs ipa_func, __u16 cmd_code,
-	__u16 len, enum qeth_prot_versions prot)
-{
-	struct qeth_cmd_buffer *iob;
-	struct qeth_ipa_cmd *cmd;
-
-	QETH_CARD_TEXT(card, 4, "getasscm");
-	iob = qeth_get_ipacmd_buffer(card, IPA_CMD_SETASSPARMS, prot);
-
-	if (iob) {
-		cmd = (struct qeth_ipa_cmd *)(iob->data+IPA_PDU_HEADER_SIZE);
-		cmd->data.setassparms.hdr.assist_no = ipa_func;
-		cmd->data.setassparms.hdr.length = 8 + len;
-		cmd->data.setassparms.hdr.command_code = cmd_code;
-		cmd->data.setassparms.hdr.return_code = 0;
-		cmd->data.setassparms.hdr.seq_no = 0;
-	}
-
-	return iob;
-}
-
 #ifdef CONFIG_QETH_IPV6
 static int qeth_l3_send_simple_setassparms_ipv6(struct qeth_card *card,
 		enum qeth_ipa_funcs ipa_func, __u16 cmd_code)
@@ -1073,7 +1051,7 @@ static int qeth_l3_send_simple_setassparms_ipv6(struct qeth_card *card,
 	struct qeth_cmd_buffer *iob;
 
 	QETH_CARD_TEXT(card, 4, "simassp6");
-	iob = qeth_l3_get_setassparms_cmd(card, ipa_func, cmd_code,
+	iob = qeth_get_setassparms_cmd(card, ipa_func, cmd_code,
 				       0, QETH_PROT_IPV6);
 	if (!iob)
 		return -ENOMEM;
@@ -2344,10 +2322,11 @@ static int qeth_l3_query_arp_cache_info(struct qeth_card *card,
 
 	QETH_CARD_TEXT_(card, 3, "qarpipv%i", prot);
 
-	iob = qeth_l3_get_setassparms_cmd(card, IPA_ARP_PROCESSING,
-			IPA_CMD_ASS_ARP_QUERY_INFO,
-			sizeof(struct qeth_arp_query_data) - sizeof(char),
-			prot);
+	iob = qeth_get_setassparms_cmd(card, IPA_ARP_PROCESSING,
+				       IPA_CMD_ASS_ARP_QUERY_INFO,
+				       sizeof(struct qeth_arp_query_data)
+						- sizeof(char),
+				       prot);
 	if (!iob)
 		return -ENOMEM;
 	cmd = (struct qeth_ipa_cmd *)(iob->data+IPA_PDU_HEADER_SIZE);
@@ -2439,7 +2418,7 @@ static int qeth_l3_arp_add_entry(struct qeth_card *card,
 		return -EOPNOTSUPP;
 	}
 
-	iob = qeth_l3_get_setassparms_cmd(card, IPA_ARP_PROCESSING,
+	iob = qeth_get_setassparms_cmd(card, IPA_ARP_PROCESSING,
 				       IPA_CMD_ASS_ARP_ADD_ENTRY,
 				       sizeof(struct qeth_arp_cache_entry),
 				       QETH_PROT_IPV4);
@@ -2480,7 +2459,7 @@ static int qeth_l3_arp_remove_entry(struct qeth_card *card,
 		return -EOPNOTSUPP;
 	}
 	memcpy(buf, entry, 12);
-	iob = qeth_l3_get_setassparms_cmd(card, IPA_ARP_PROCESSING,
+	iob = qeth_get_setassparms_cmd(card, IPA_ARP_PROCESSING,
 				       IPA_CMD_ASS_ARP_REMOVE_ENTRY,
 				       12,
 				       QETH_PROT_IPV4);
-- 
2.3.9
