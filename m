From: Krishna Kumar <krkumar2@in.ibm.com>
Subject: [PATCH] e1000: Simple optimizations in e1000_xmit_frame
Date: Tue, 08 May 2007 13:01:27 +0530
Message-ID: <20070508073127.17544.18180.sendpatchset@localhost.localdomain>
Cc: krkumar2@in.ibm.com, Krishna Kumar <krkumar2@in.ibm.com>
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from ausmtp04.au.ibm.com ([202.81.18.152]:64556 "EHLO
	ausmtp04.au.ibm.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S934187AbXEHHb7 (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 8 May 2007 03:31:59 -0400
Received: from sd0109e.au.ibm.com (d23rh905.au.ibm.com [202.81.18.225])
	by ausmtp04.au.ibm.com (8.13.8/8.13.8) with ESMTP id l487pVdY056214
	for <netdev@vger.kernel.org>; Tue, 8 May 2007 17:51:31 +1000
Received: from d23av02.au.ibm.com (d23av02.au.ibm.com [9.190.250.243])
	by sd0109e.au.ibm.com (8.13.8/8.13.8/NCO v8.3) with ESMTP id l487ZMJ3174968
	for <netdev@vger.kernel.org>; Tue, 8 May 2007 17:35:23 +1000
Received: from d23av02.au.ibm.com (loopback [127.0.0.1])
	by d23av02.au.ibm.com (8.12.11.20060308/8.13.3) with ESMTP id l487VoDC014227
	for <netdev@vger.kernel.org>; Tue, 8 May 2007 17:31:50 +1000
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Some simple optimizations in e1000_xmit_frame.

Patch against net-2.6.22.git

Signed-off-by: Krishna Kumar <krkumar2@in.ibm.com>
---
diff -ruNp org/drivers/net/e1000/e1000_main.c new/drivers/net/e1000/e1000_main.c
--- org/drivers/net/e1000/e1000_main.c	2007-04-09 12:40:02.000000000 +0530
+++ new/drivers/net/e1000/e1000_main.c	2007-04-09 12:42:28.000000000 +0530
@@ -3264,14 +3264,13 @@ e1000_xmit_frame(struct sk_buff *skb, st
 	unsigned int first, max_per_txd = E1000_MAX_DATA_PER_TXD;
 	unsigned int max_txd_pwr = E1000_MAX_TXD_PWR;
 	unsigned int tx_flags = 0;
-	unsigned int len = skb->len;
+	unsigned int len = skb->len - skb->data_len;
 	unsigned long flags;
-	unsigned int nr_frags = 0;
-	unsigned int mss = 0;
+	unsigned int nr_frags;
+	unsigned int mss;
 	int count = 0;
 	int tso;
 	unsigned int f;
-	len -= skb->data_len;
 
 	/* This goes back to the question of how to logically map a tx queue
 	 * to a flow.  Right now, performance is impacted slightly negatively
@@ -3305,7 +3304,7 @@ e1000_xmit_frame(struct sk_buff *skb, st
 		* points to just header, pull a few bytes of payload from
 		* frags into skb->data */
 		hdr_len = skb_transport_offset(skb) + tcp_hdrlen(skb);
-		if (skb->data_len && (hdr_len == (skb->len - skb->data_len))) {
+		if (skb->data_len && hdr_len == len) {
 			switch (adapter->hw.mac_type) {
 				unsigned int pull_size;
 			case e1000_82544:
