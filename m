From: Frank Pavlic <fpavlic@de.ibm.com>
Subject: [patch 2/7] s390: minor modification in qeth layer2 code
Date: Thu, 10 Nov 2005 13:49:15 +0100
Message-ID: <20051110124915.GB7936@pavlic>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: netdev@vger.kernel.org, linux-kernel@vger.kernel.org
Return-path: <linux-kernel-owner+glk-linux-kernel-3=40m.gmane.org-S1750732AbVKJMrD@vger.kernel.org>
To: jgarzik@pobox.com
Content-Disposition: inline
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

[patch 2/7] s390: minor modification in qeth layer2 code

From: Frank Pavlic <fpavlic@de.ibm.com>
	- use qeth_layer2_send_setdelvlan_cb to check
	  return code of a SET/DELVLAN IP Assist command.
	  It fits better in qeth's design and mechanism of IP Assist
	  command handling.
	  
Signed-off-by: Frank Pavlic <fpavlic@de.ibm.com>

diffstat:
 qeth_main.c |   40 ++++++++++++++++++++++++++--------------
 1 files changed, 26 insertions(+), 14 deletions(-)

diff -Naupr orig/drivers/s390/net/qeth_main.c patched-linux/drivers/s390/net/qeth_main.c
--- orig/drivers/s390/net/qeth_main.c	2005-11-09 20:06:57.000000000 +0100
+++ patched-linux/drivers/s390/net/qeth_main.c	2005-11-09 20:20:06.000000000 +0100
@@ -1,6 +1,6 @@
 /*
  *
- * linux/drivers/s390/net/qeth_main.c ($Revision: 1.224 $)
+ * linux/drivers/s390/net/qeth_main.c ($Revision: 1.235 $)
  *
  * Linux on zSeries OSA Express and HiperSockets support
  *
@@ -12,7 +12,7 @@
  *			  Frank Pavlic (pavlic@de.ibm.com) and
  *		 	  Thomas Spatzier <tspat@de.ibm.com>
  *
- *    $Revision: 1.224 $	 $Date: 2005/05/04 20:19:18 $
+ *    $Revision: 1.235 $	 $Date: 2005/05/04 20:19:18 $
  *
  * This program is free software; you can redistribute it and/or modify
  * it under the terms of the GNU General Public License as published by
@@ -72,7 +72,7 @@
 #include "qeth_eddp.h"
 #include "qeth_tso.h"
 
-#define VERSION_QETH_C "$Revision: 1.224 $"
+#define VERSION_QETH_C "$Revision: 1.235 $"
 static const char *version = "qeth S/390 OSA-Express driver";
 
 /**
@@ -5350,11 +5350,30 @@ qeth_free_vlan_addresses6(struct qeth_ca
 #endif /* CONFIG_QETH_IPV6 */
 }
 
-static void
+static int
+qeth_layer2_send_setdelvlan_cb(struct qeth_card *card,
+                               struct qeth_reply *reply,
+                               unsigned long data)
+{
+        struct qeth_ipa_cmd *cmd;
+
+        QETH_DBF_TEXT(trace, 2, "L2sdvcb");
+        cmd = (struct qeth_ipa_cmd *) data;
+        if (cmd->hdr.return_code) {
+		PRINT_ERR("Error in processing VLAN %i on %s: 0x%x. "
+			  "Continuing\n",cmd->data.setdelvlan.vlan_id, 
+			  QETH_CARD_IFNAME(card), cmd->hdr.return_code);
+		QETH_DBF_TEXT_(trace, 2, "L2VL%4x", cmd->hdr.command);
+		QETH_DBF_TEXT_(trace, 2, "L2%s", CARD_BUS_ID(card));
+		QETH_DBF_TEXT_(trace, 2, "err%d", cmd->hdr.return_code);
+	}
+        return 0;
+}
+
+static int
 qeth_layer2_send_setdelvlan(struct qeth_card *card, __u16 i,
 			    enum qeth_ipa_cmds ipacmd)
 {
- 	int rc;
 	struct qeth_ipa_cmd *cmd;
 	struct qeth_cmd_buffer *iob;
 
@@ -5362,15 +5381,8 @@ qeth_layer2_send_setdelvlan(struct qeth_
 	iob = qeth_get_ipacmd_buffer(card, ipacmd, QETH_PROT_IPV4);
 	cmd = (struct qeth_ipa_cmd *)(iob->data+IPA_PDU_HEADER_SIZE);
         cmd->data.setdelvlan.vlan_id = i;
-
-	rc = qeth_send_ipa_cmd(card, iob, NULL, NULL);
-        if (rc) {
-                PRINT_ERR("Error in processing VLAN %i on %s: 0x%x. "
-			  "Continuing\n",i, QETH_CARD_IFNAME(card), rc);
-		QETH_DBF_TEXT_(trace, 2, "L2VL%4x", ipacmd);
-		QETH_DBF_TEXT_(trace, 2, "L2%s", CARD_BUS_ID(card));
-		QETH_DBF_TEXT_(trace, 2, "err%d", rc);
-        }
+	return qeth_send_ipa_cmd(card, iob, 
+				 qeth_layer2_send_setdelvlan_cb, NULL);
 }
 
 static void
