From: James Chapman <jchapman@katalix.com>
Subject: [PATCH net-next 1/2] l2tp: fix reorder timeout recovery
Date: Thu, 10 May 2012 10:43:08 +0100
Message-ID: <1336642989-4785-1-git-send-email-jchapman@katalix.com>
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from katalix.com ([82.103.140.233]:33592 "EHLO mail.katalix.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1757913Ab2EJJnN (ORCPT <rfc822;netdev@vger.kernel.org>);
	Thu, 10 May 2012 05:43:13 -0400
Received: from localhost.localdomain (jchapman.plus.com [80.229.30.198])
	(using TLSv1 with cipher DHE-RSA-AES256-SHA (256/256 bits))
	(No client certificate requested)
	(Authenticated sender: james)
	by mail.katalix.com (Postfix) with ESMTPSA id C88AEA62110
	for <netdev@vger.kernel.org>; Thu, 10 May 2012 10:43:09 +0100 (BST)
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

When L2TP data packet reordering is enabled, packets are held in a
queue while waiting for out-of-sequence packets. If a packet gets
lost, packets will be held until the reorder timeout expires, when we
are supposed to then advance to the sequence number of the next packet
but we don't currently do so. As a result, the data channel is stuck
because we are waiting for a packet that will never arrive - all
packets age out and none are passed.

The fix is to add a flag to the session context, which is set when the
reorder timeout expires and tells the receive code to reset the next
expected sequence number to that of the next packet in the queue.

Tested in a production L2TP network with Starent and Nortel L2TP gear.

Signed-off-by: James Chapman <jchapman@katalix.com>
---
 net/l2tp/l2tp_core.c |    9 +++++++++
 net/l2tp/l2tp_core.h |    1 +
 2 files changed, 10 insertions(+), 0 deletions(-)

diff --git a/net/l2tp/l2tp_core.c b/net/l2tp/l2tp_core.c
index 456b52d..d1ab3a2 100644
--- a/net/l2tp/l2tp_core.c
+++ b/net/l2tp/l2tp_core.c
@@ -428,6 +428,7 @@ start:
 			       session->name, L2TP_SKB_CB(skb)->ns,
 			       L2TP_SKB_CB(skb)->length, session->nr,
 			       skb_queue_len(&session->reorder_q));
+			session->reorder_skip = 1;
 			__skb_unlink(skb, &session->reorder_q);
 			kfree_skb(skb);
 			if (session->deref)
@@ -436,6 +437,14 @@ start:
 		}
 
 		if (L2TP_SKB_CB(skb)->has_seq) {
+			if (session->reorder_skip) {
+				PRINTK(session->debug, L2TP_MSG_SEQ, KERN_DEBUG,
+				       "%s: advancing nr to next pkt: %u -> %u",
+				       session->name, session->nr,
+				       L2TP_SKB_CB(skb)->ns);
+				session->reorder_skip = 0;
+				session->nr = L2TP_SKB_CB(skb)->ns;
+			}
 			if (L2TP_SKB_CB(skb)->ns != session->nr) {
 				PRINTK(session->debug, L2TP_MSG_SEQ, KERN_DEBUG,
 				       "%s: holding oos pkt %u len %d, "
diff --git a/net/l2tp/l2tp_core.h b/net/l2tp/l2tp_core.h
index 0bf60fc..9002634 100644
--- a/net/l2tp/l2tp_core.h
+++ b/net/l2tp/l2tp_core.h
@@ -123,6 +123,7 @@ struct l2tp_session {
 						 * categories */
 	int			reorder_timeout; /* configured reorder timeout
 						  * (in jiffies) */
+	int			reorder_skip;	/* set if skip to next nr */
 	int			mtu;
 	int			mru;
 	enum l2tp_pwtype	pwtype;
-- 
1.7.0.4
