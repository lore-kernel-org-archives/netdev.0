From: Tejun Heo <tj@kernel.org>
Subject: [PATCH 09/62] atm/nicstar: convert to idr_alloc()
Date: Sat,  2 Feb 2013 17:20:10 -0800
Message-ID: <1359854463-2538-10-git-send-email-tj@kernel.org>
References: <1359854463-2538-1-git-send-email-tj@kernel.org>
Cc: linux-kernel@vger.kernel.org, rusty@rustcorp.com.au,
	bfields@fieldses.org, skinsbursky@parallels.com,
	ebiederm@xmission.com, jmorris@namei.org, axboe@kernel.dk,
	Tejun Heo <tj@kernel.org>,
	Chas Williams <chas@cmf.nrl.navy.mil>, netdev@vger.kernel.org
To: akpm@linux-foundation.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-pa0-f48.google.com ([209.85.220.48]:54519 "EHLO
	mail-pa0-f48.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1753076Ab3BCBVg (ORCPT
	<rfc822;netdev@vger.kernel.org>); Sat, 2 Feb 2013 20:21:36 -0500
In-Reply-To: <1359854463-2538-1-git-send-email-tj@kernel.org>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Convert to the much saner new idr interface.  The existing code looks
buggy to me - ID 0 is treated as no-ID but allocation specifies 0 as
lower limit and there's no error handling after parial success.  This
conversion keeps the bugs unchanged.

Only compile tested.

Signed-off-by: Tejun Heo <tj@kernel.org>
Cc: Chas Williams <chas@cmf.nrl.navy.mil>
Cc: netdev@vger.kernel.org
---
This patch depends on an earlier idr changes and I think it would be
best to route these together through -mm.  Please holler if there's
any objection.  Thanks.

 drivers/atm/nicstar.c | 27 ++++++++++++---------------
 1 file changed, 12 insertions(+), 15 deletions(-)

diff --git a/drivers/atm/nicstar.c b/drivers/atm/nicstar.c
index 628787e..7fd6834 100644
--- a/drivers/atm/nicstar.c
+++ b/drivers/atm/nicstar.c
@@ -1026,24 +1026,21 @@ static void push_rxbufs(ns_dev * card, struct sk_buff *skb)
 				card->lbfqc += 2;
 		}
 
-		do {
-			if (!idr_pre_get(&card->idr, GFP_ATOMIC)) {
-				printk(KERN_ERR
-				       "nicstar%d: no free memory for idr\n",
-				       card->index);
+		if (!id1) {
+			id1 = idr_alloc(&card->idr, handle1, 0, 0, GFP_ATOMIC);
+			if (id1 < 0) {
+				err = id1;
 				goto out;
 			}
+		}
 
-			if (!id1)
-				err = idr_get_new_above(&card->idr, handle1, 0, &id1);
-
-			if (!id2 && err == 0)
-				err = idr_get_new_above(&card->idr, handle2, 0, &id2);
-
-		} while (err == -EAGAIN);
-
-		if (err)
-			goto out;
+		if (!id2) {
+			id2 = idr_alloc(&card->idr, handle2, 0, 0, GFP_ATOMIC);
+			if (id2 < 0) {
+				err = id2;
+				goto out;
+			}
+		}
 
 		spin_lock_irqsave(&card->res_lock, flags);
 		while (CMD_BUSY(card)) ;
-- 
1.8.1
