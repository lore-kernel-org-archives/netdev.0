From: Wolfram Sang <w.sang@pengutronix.de>
Subject: [RFC] irda: irttp: allow zero byte packets
Date: Wed, 10 Nov 2010 00:19:47 +0100
Message-ID: <1289344787-12160-1-git-send-email-w.sang@pengutronix.de>
Cc: netdev@vger.kernel.org, Wolfram Sang <w.sang@pengutronix.de>,
	Samuel Ortiz <samuel@sortiz.org>
To: irda-users@lists.sourceforge.net
Return-path: <netdev-owner@vger.kernel.org>
Received: from metis.ext.pengutronix.de ([92.198.50.35]:55867 "EHLO
	metis.ext.pengutronix.de" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1753483Ab0KIXTo (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 9 Nov 2010 18:19:44 -0500
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Sending zero byte packets is not neccessarily an error (AF_INET accepts it,
too), so just apply a shortcut. This was discovered because of a non-working
software with WINE. See

  http://bugs.winehq.org/show_bug.cgi?id=19397#c86
  http://thread.gmane.org/gmane.linux.irda.general/1643

for very detailed debugging information and a testcase. Kudos to Wolfgang for
those!

Reported-by: Wolfgang Schwotzer <wolfgang.schwotzer@gmx.net>
Signed-off-by: Wolfram Sang <w.sang@pengutronix.de>
Tested-by: Mike Evans <mike.evans@cardolan.com>
Cc: Samuel Ortiz <samuel@sortiz.org>
---

I found Wolfgang's very detailed report while looking for WINE-bugreports
affecting the kernel somehow. His mail sadly went to an almost dead
mailing-list and he told me he lost interest meanwhile. This is why I picked
the issue up and created this straightforward patch which helps the case at
least (thanks Mike for testing!).

 net/irda/irttp.c |   25 +++++++++++++++++++------
 1 files changed, 19 insertions(+), 6 deletions(-)

diff --git a/net/irda/irttp.c b/net/irda/irttp.c
index 285761e..6cfaeaf 100644
--- a/net/irda/irttp.c
+++ b/net/irda/irttp.c
@@ -550,16 +550,23 @@ EXPORT_SYMBOL(irttp_close_tsap);
  */
 int irttp_udata_request(struct tsap_cb *self, struct sk_buff *skb)
 {
+	int ret = -1;
+
 	IRDA_ASSERT(self != NULL, return -1;);
 	IRDA_ASSERT(self->magic == TTP_TSAP_MAGIC, return -1;);
 	IRDA_ASSERT(skb != NULL, return -1;);
 
 	IRDA_DEBUG(4, "%s()\n", __func__);
 
+	/* Take shortcut on zero byte packets */
+	if (skb->len == 0) {
+		ret = 0;
+		goto err;
+	}
+
 	/* Check that nothing bad happens */
-	if ((skb->len == 0) || (!self->connected)) {
-		IRDA_DEBUG(1, "%s(), No data, or not connected\n",
-			   __func__);
+	if (!self->connected) {
+		IRDA_DEBUG(1, "%s(), Not connected\n", __func__);
 		goto err;
 	}
 
@@ -576,7 +583,7 @@ int irttp_udata_request(struct tsap_cb *self, struct sk_buff *skb)
 
 err:
 	dev_kfree_skb(skb);
-	return -1;
+	return ret;
 }
 EXPORT_SYMBOL(irttp_udata_request);
 
@@ -599,9 +606,15 @@ int irttp_data_request(struct tsap_cb *self, struct sk_buff *skb)
 	IRDA_DEBUG(2, "%s() : queue len = %d\n", __func__,
 		   skb_queue_len(&self->tx_queue));
 
+	/* Take shortcut on zero byte packets */
+	if (skb->len == 0) {
+		ret = 0;
+		goto err;
+	}
+
 	/* Check that nothing bad happens */
-	if ((skb->len == 0) || (!self->connected)) {
-		IRDA_WARNING("%s: No data, or not connected\n", __func__);
+	if (!self->connected) {
+		IRDA_WARNING("%s: Not connected\n", __func__);
 		ret = -ENOTCONN;
 		goto err;
 	}
-- 
1.7.2.3

