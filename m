From: Ivo Calado <ivocalado@embedded.ufcg.edu.br>
Subject: [PATCH 2/4] Implement function that allows to keep track of packets
 sent in last 2 rtt
Date: Tue, 13 Oct 2009 14:24:39 -0300
Message-ID: <4AD4B7D7.1010106@embedded.ufcg.edu.br>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, ivocalado@embedded.ufcg.edu.br
To: dccp@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail.embedded.ufcg.edu.br ([150.165.63.2]:2864 "EHLO
	mail.embedded.ufcg.edu.br" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752664AbZJMRZb (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 13 Oct 2009 13:25:31 -0400
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Implement function that allows to keep track of packets sent in last 2 rtt

Changes:
 - Creates tfrc_tx_hist_two_rtt_old, that return the first list node at least 2 rtt old

Signed-off-by: Ivo Calado <ivocalado@embedded.ufcg.edu.br>
Signed-off-by: Erivaldo Xavier <desadoc@gmail.com>
Signed-off-by: Leandro Sales <leandroal@gmail.com>

Index: dccp_tree_work03/net/dccp/ccids/lib/packet_history_sp.c
===================================================================
--- dccp_tree_work03.orig/net/dccp/ccids/lib/packet_history_sp.c	2009-10-08 22:59:20.526408512 -0300
+++ dccp_tree_work03/net/dccp/ccids/lib/packet_history_sp.c	2009-10-08 22:59:32.582408479 -0300
@@ -65,7 +65,7 @@
 	}
 }
 
-int tfrc_sp_tx_hist_add(struct tfrc_tx_hist_entry **headp, u64 seqno)
+int tfrc_sp_tx_hist_add(struct tfrc_tx_hist_entry **headp, u64 seqno, u8 ccval)
 {
 	struct tfrc_tx_hist_entry *entry =
 		kmem_cache_alloc(tfrc_tx_hist_slab, gfp_any());
@@ -73,6 +73,7 @@
 	if (entry == NULL)
 		return -ENOBUFS;
 	entry->seqno = seqno;
+	entry->ccval = ccval;
 	entry->stamp = ktime_get_real();
 	entry->next  = *headp;
 	*headp	     = entry;
Index: dccp_tree_work03/net/dccp/ccids/lib/packet_history_sp.h
===================================================================
--- dccp_tree_work03.orig/net/dccp/ccids/lib/packet_history_sp.h	2009-10-08 22:59:20.526408512 -0300
+++ dccp_tree_work03/net/dccp/ccids/lib/packet_history_sp.h	2009-10-08 22:59:32.582408479 -0300
@@ -57,6 +57,7 @@
 struct tfrc_tx_hist_entry {
 	struct tfrc_tx_hist_entry *next;
 	u64			  seqno;
+	u8			  ccval:4;
 	ktime_t			  stamp;
 };
 
@@ -69,13 +70,27 @@
 }
 #endif
 
-extern int  tfrc_sp_tx_hist_add(struct tfrc_tx_hist_entry **headp, u64 seqno);
+extern int tfrc_sp_tx_hist_add(struct tfrc_tx_hist_entry **headp,
+			       u64 seqno, u8 ccval);
 extern void tfrc_sp_tx_hist_purge(struct tfrc_tx_hist_entry **headp);
 
 #ifndef _DCCP_PKT_HIST_
 /* Subtraction a-b modulo-16, respects circular wrap-around */
 #define SUB16(a, b) (((a) + 16 - (b)) & 0xF)
 
+/*
+ * tfrc_tx_hist_two_rtt_old  -  returns entry at least two rtt old
+ * head:		list of tx history entries
+ * cur_ccval:		current ccval
+ */
+static inline struct tfrc_tx_hist_entry *
+	tfrc_tx_hist_two_rtt_old(struct tfrc_tx_hist_entry *head, u8 cur_ccval)
+{
+	while ((head != NULL) && (SUB16(cur_ccval, head->ccval) <= 8))
+		head = head->next;
+	return head;
+}
+
 /* Number of packets to wait after a missing packet (RFC 4342, 6.1) */
 #define TFRC_NDUPACK 3
 

