From: Yuval Mintz <Yuval.Mintz@qlogic.com>
Subject: [PATCH net 4/5] qed: Fix returning unlimited SPQ entries
Date: Sun, 19 Jun 2016 15:18:14 +0300
Message-ID: <1466338695-15538-5-git-send-email-Yuval.Mintz@qlogic.com>
References: <1466338695-15538-1-git-send-email-Yuval.Mintz@qlogic.com>
Mime-Version: 1.0
Content-Type: text/plain
Cc: Yuval Mintz <Yuval.Mintz@qlogic.com>
To: <davem@davemloft.net>, <netdev@vger.kernel.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mx0b-0016ce01.pphosted.com ([67.231.156.153]:19825 "EHLO
	mx0b-0016ce01.pphosted.com" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with ESMTP id S1751748AbcFSMSk (ORCPT
	<rfc822;netdev@vger.kernel.org>); Sun, 19 Jun 2016 08:18:40 -0400
In-Reply-To: <1466338695-15538-1-git-send-email-Yuval.Mintz@qlogic.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Driver has 2 sets of entries for handling ramrod configurations
toward firmware - a regular pre-allocated set of entires and a
possible 'unlimited' list of additional pending entries.

In most scenarios the 'unlimited' list would not be used, but
when it does the handling of the ramrod completion doesn't
properly handle the release of the entry.

Signed-off-by: Yuval Mintz <Yuval.Mintz@qlogic.com>
---
 drivers/net/ethernet/qlogic/qed/qed_spq.c | 21 ++++++++++++++++++---
 1 file changed, 18 insertions(+), 3 deletions(-)

diff --git a/drivers/net/ethernet/qlogic/qed/qed_spq.c b/drivers/net/ethernet/qlogic/qed/qed_spq.c
index acac662..67d9893 100644
--- a/drivers/net/ethernet/qlogic/qed/qed_spq.c
+++ b/drivers/net/ethernet/qlogic/qed/qed_spq.c
@@ -614,7 +614,9 @@ qed_spq_add_entry(struct qed_hwfn *p_hwfn,
 
 			*p_en2 = *p_ent;
 
-			kfree(p_ent);
+			/* EBLOCK responsible to free the allocated p_ent */
+			if (p_ent->comp_mode != QED_SPQ_MODE_EBLOCK)
+				kfree(p_ent);
 
 			p_ent = p_en2;
 		}
@@ -749,6 +751,15 @@ int qed_spq_post(struct qed_hwfn *p_hwfn,
 		 * Thus, after gaining the answer perform the cleanup here.
 		 */
 		rc = qed_spq_block(p_hwfn, p_ent, fw_return_code);
+
+		if (p_ent->queue == &p_spq->unlimited_pending) {
+			/* This is an allocated p_ent which does not need to
+			 * return to pool.
+			 */
+			kfree(p_ent);
+			return rc;
+		}
+
 		if (rc)
 			goto spq_post_fail2;
 
@@ -844,8 +855,12 @@ int qed_spq_completion(struct qed_hwfn *p_hwfn,
 		found->comp_cb.function(p_hwfn, found->comp_cb.cookie, p_data,
 					fw_return_code);
 
-	if (found->comp_mode != QED_SPQ_MODE_EBLOCK)
-		/* EBLOCK is responsible for freeing its own entry */
+	if ((found->comp_mode != QED_SPQ_MODE_EBLOCK) ||
+	    (found->queue == &p_spq->unlimited_pending))
+		/* EBLOCK  is responsible for returning its own entry into the
+		 * free list, unless it originally added the entry into the
+		 * unlimited pending list.
+		 */
 		qed_spq_return_entry(p_hwfn, found);
 
 	/* Attempt to post pending requests */
-- 
1.9.3
