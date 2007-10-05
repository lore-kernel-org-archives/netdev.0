From: Ursula Braun <braunu@de.ibm.com>
Subject: [patch 2/5] qeth: EDDP does not work on large MTUs
Date: Fri, 05 Oct 2007 16:45:45 +0200
Message-ID: <20071005144822.884499000@linux.vnet.ibm.com>
References: <20071005144543.448852000@linux.vnet.ibm.com>
Cc: Frank Blaschka <frank.blaschka@de.ibm.com>
To: davem@davemloft.net, netdev@vger.kernel.org,
	linux-s390@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mtagate1.de.ibm.com ([195.212.29.150]:61898 "EHLO
	mtagate1.de.ibm.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1759632AbXJEOs0 (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 5 Oct 2007 10:48:26 -0400
Content-Disposition: inline; filename=708-qeth-eddp.diff
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

From: Frank Blaschka <frank.blaschka@de.ibm.com>

Fix filling the qdio buffers in EDDP mode.

Signed-off-by: Frank Blaschka <frank.blaschka@de.ibm.com>
Signed-off-by: Ursula Braun <braunu@de.ibm.com>
---

 drivers/s390/net/qeth_eddp.c |   16 +++++++++-------
 drivers/s390/net/qeth_main.c |    3 ++-
 2 files changed, 11 insertions(+), 8 deletions(-)

Index: linux-2.6-uschi/drivers/s390/net/qeth_eddp.c
===================================================================
--- linux-2.6-uschi.orig/drivers/s390/net/qeth_eddp.c
+++ linux-2.6-uschi/drivers/s390/net/qeth_eddp.c
@@ -159,13 +159,15 @@ qeth_eddp_fill_buffer(struct qeth_qdio_o
 		buffer = buf->buffer;
 		/* fill one skb into buffer */
 		for (i = 0; i < ctx->elements_per_skb; ++i){
-			buffer->element[buf->next_element_to_fill].addr =
-				ctx->elements[element].addr;
-			buffer->element[buf->next_element_to_fill].length =
-				ctx->elements[element].length;
-			buffer->element[buf->next_element_to_fill].flags =
-				ctx->elements[element].flags;
-			buf->next_element_to_fill++;
+			if (ctx->elements[element].length != 0) {
+				buffer->element[buf->next_element_to_fill].
+				addr = ctx->elements[element].addr;
+				buffer->element[buf->next_element_to_fill].
+				length = ctx->elements[element].length;
+				buffer->element[buf->next_element_to_fill].
+				flags = ctx->elements[element].flags;
+				buf->next_element_to_fill++;
+			}
 			element++;
 			elements--;
 		}
Index: linux-2.6-uschi/drivers/s390/net/qeth_main.c
===================================================================
--- linux-2.6-uschi.orig/drivers/s390/net/qeth_main.c
+++ linux-2.6-uschi/drivers/s390/net/qeth_main.c
@@ -4500,7 +4500,8 @@ qeth_do_send_packet(struct qeth_card *ca
 			/* check if we have enough elements (including following
 			 * free buffers) to handle eddp context */
 			if (qeth_eddp_check_buffers_for_context(queue,ctx) < 0){
-				printk("eddp tx_dropped 1\n");
+				if (net_ratelimit())
+					PRINT_WARN("eddp tx_dropped 1\n");
 				rc = -EBUSY;
 				goto out;
 			}

-- 
