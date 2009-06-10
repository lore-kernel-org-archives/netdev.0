From: Sathya Perla <sathyap@serverengines.com>
Subject: [net-next PATCH 5/5] be2net: Fix be_tx_q_clean() being called on
	freed queues
Date: Wed, 10 Jun 2009 17:53:50 +0530
Message-ID: <20090610122350.GA16751@serverengines.com>
Reply-To: Sathya Perla <sathyap@serverengines.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
To: netdev <netdev@vger.kernel.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from segment-124-30.sify.net ([124.30.166.146]:52855 "EHLO
	sperla-laptop.localdomain" rhost-flags-OK-FAIL-OK-FAIL)
	by vger.kernel.org with ESMTP id S1756453AbZFJMYC (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 10 Jun 2009 08:24:02 -0400
Content-Disposition: inline
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

In the tx queue destroy path, be_tx_q_clean() is currently called after the tx queues are freed; it must be called before.

Signed-off-by: Sathya Perla <sathyap@serverengines.com>
---
 drivers/net/benet/be_main.c |   11 ++++++-----
 1 files changed, 6 insertions(+), 5 deletions(-)

diff --git a/drivers/net/benet/be_main.c b/drivers/net/benet/be_main.c
index 86f70af..66bb568 100644
--- a/drivers/net/benet/be_main.c
+++ b/drivers/net/benet/be_main.c
@@ -1056,8 +1056,13 @@ static void be_tx_queues_destroy(struct be_adapter *adapter)
 	struct be_queue_info *q;
 
 	q = &adapter->tx_obj.q;
-	if (q->created)
+	if (q->created) {
 		be_cmd_q_destroy(&adapter->ctrl, q, QTYPE_TXQ);
+
+		/* No more tx completions can be rcvd now; clean up if there
+		 * are any pending completions or pending tx requests */
+		be_tx_q_clean(adapter);
+	}
 	be_queue_free(adapter, q);
 
 	q = &adapter->tx_obj.cq;
@@ -1065,10 +1070,6 @@ static void be_tx_queues_destroy(struct be_adapter *adapter)
 		be_cmd_q_destroy(&adapter->ctrl, q, QTYPE_CQ);
 	be_queue_free(adapter, q);
 
-	/* No more tx completions can be rcvd now; clean up if there are
-	 * any pending completions or pending tx requests */
-	be_tx_q_clean(adapter);
-
 	q = &adapter->tx_eq.q;
 	if (q->created)
 		be_cmd_q_destroy(&adapter->ctrl, q, QTYPE_EQ);
-- 
1.6.0.4

