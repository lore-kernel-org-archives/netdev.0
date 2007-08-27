From: Ursula Braun <braunu@de.ibm.com>
Subject: [patch 2/7] qeth: enforce a rate limit for inbound scatter gather messages
Date: Mon, 27 Aug 2007 19:27:33 +0200
Message-ID: <20070827173059.794198000@linux.vnet.ibm.com>
References: <20070827172731.370533000@linux.vnet.ibm.com>
Cc: frank.blaschka@de.ibm.com
To: jgarzik@pobox.com, netdev@vger.kernel.org,
	linux-s390@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mtagate5.de.ibm.com ([195.212.29.154]:44725 "EHLO
	mtagate5.de.ibm.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1761414AbXH0RbE (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 27 Aug 2007 13:31:04 -0400
Content-Disposition: inline; filename=704-qeth-rate-limit.diff
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

From: Frank Blaschka <frank.blaschka@de.ibm.com>

under memory pressure scatter gather mode switching messages must be
rate limited.

Signed-off-by: Frank Blaschka <frank.blaschka@de.ibm.com>
Signed-off-by: Ursula Braun <braunu@de.ibm.com>
---

 drivers/s390/net/qeth_main.c |   13 ++++++++-----
 1 file changed, 8 insertions(+), 5 deletions(-)

Index: linux-2.6-uschi/drivers/s390/net/qeth_main.c
===================================================================
--- linux-2.6-uschi.orig/drivers/s390/net/qeth_main.c
+++ linux-2.6-uschi/drivers/s390/net/qeth_main.c
@@ -2803,13 +2803,16 @@ qeth_queue_input_buffer(struct qeth_card
 		if (newcount < count) {
 			/* we are in memory shortage so we switch back to
 			   traditional skb allocation and drop packages */
-			if (atomic_cmpxchg(&card->force_alloc_skb, 0, 1))
-				printk(KERN_WARNING
-					"qeth: switch to alloc skb\n");
+			if (!atomic_read(&card->force_alloc_skb) &&
+			    net_ratelimit())
+				PRINT_WARN("Switch to alloc skb\n");
+			atomic_set(&card->force_alloc_skb, 3);
 			count = newcount;
 		} else {
-			if (atomic_cmpxchg(&card->force_alloc_skb, 1, 0))
-				printk(KERN_WARNING "qeth: switch to sg\n");
+			if ((atomic_read(&card->force_alloc_skb) == 1) &&
+			    net_ratelimit())
+				PRINT_WARN("Switch to sg\n");
+			atomic_add_unless(&card->force_alloc_skb, -1, 0);
 		}
 
 		/*

-- 
