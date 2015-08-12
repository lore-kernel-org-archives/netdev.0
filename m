From: Hariprasad Shenai <hariprasad@chelsio.com>
Subject: [PATCH net-next 3/4] cxgb4: Differentiate between stids between server and filter region
Date: Wed, 12 Aug 2015 16:55:06 +0530
Message-ID: <1439378707-14462-4-git-send-email-hariprasad@chelsio.com>
References: <1439378707-14462-1-git-send-email-hariprasad@chelsio.com>
Cc: davem@davemloft.net, leedom@chelsio.com, nirranjan@chelsio.com,
	Hariprasad Shenai <hariprasad@chelsio.com>
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from stargate.chelsio.com ([67.207.112.58]:31426 "EHLO
	stargate3.asicdesigners.com" rhost-flags-OK-OK-OK-FAIL)
	by vger.kernel.org with ESMTP id S1750974AbbHLLZO (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 12 Aug 2015 07:25:14 -0400
In-Reply-To: <1439378707-14462-1-git-send-email-hariprasad@chelsio.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

For T4 adapter, offloaded servers tid for IPv4 connections are
allocated from filter region. So add a new field for server filter tid if
server tid is allocated from filter region.

Signed-off-by: Hariprasad Shenai <hariprasad@chelsio.com>
---
 drivers/net/ethernet/chelsio/cxgb4/cxgb4_main.c | 15 ++++++++++-----
 drivers/net/ethernet/chelsio/cxgb4/cxgb4_uld.h  |  1 +
 2 files changed, 11 insertions(+), 5 deletions(-)

diff --git a/drivers/net/ethernet/chelsio/cxgb4/cxgb4_main.c b/drivers/net/ethernet/chelsio/cxgb4/cxgb4_main.c
index df6cba1..f35dd22 100644
--- a/drivers/net/ethernet/chelsio/cxgb4/cxgb4_main.c
+++ b/drivers/net/ethernet/chelsio/cxgb4/cxgb4_main.c
@@ -1548,7 +1548,7 @@ int cxgb4_alloc_sftid(struct tid_info *t, int family, void *data)
 		t->stid_tab[stid].data = data;
 		stid -= t->nstids;
 		stid += t->sftid_base;
-		t->stids_in_use++;
+		t->sftids_in_use++;
 	}
 	spin_unlock_bh(&t->stid_lock);
 	return stid;
@@ -1573,10 +1573,14 @@ void cxgb4_free_stid(struct tid_info *t, unsigned int stid, int family)
 	else
 		bitmap_release_region(t->stid_bmap, stid, 2);
 	t->stid_tab[stid].data = NULL;
-	if (family == PF_INET)
-		t->stids_in_use--;
-	else
-		t->stids_in_use -= 4;
+	if (stid < t->nstids) {
+		if (family == PF_INET)
+			t->stids_in_use--;
+		else
+			t->stids_in_use -= 4;
+	} else {
+		t->sftids_in_use--;
+	}
 	spin_unlock_bh(&t->stid_lock);
 }
 EXPORT_SYMBOL(cxgb4_free_stid);
@@ -1707,6 +1711,7 @@ static int tid_init(struct tid_info *t)
 	spin_lock_init(&t->atid_lock);
 
 	t->stids_in_use = 0;
+	t->sftids_in_use = 0;
 	t->afree = NULL;
 	t->atids_in_use = 0;
 	atomic_set(&t->tids_in_use, 0);
diff --git a/drivers/net/ethernet/chelsio/cxgb4/cxgb4_uld.h b/drivers/net/ethernet/chelsio/cxgb4/cxgb4_uld.h
index f61fed1..c3a8be5 100644
--- a/drivers/net/ethernet/chelsio/cxgb4/cxgb4_uld.h
+++ b/drivers/net/ethernet/chelsio/cxgb4/cxgb4_uld.h
@@ -117,6 +117,7 @@ struct tid_info {
 
 	spinlock_t stid_lock;
 	unsigned int stids_in_use;
+	unsigned int sftids_in_use;
 
 	/* TIDs in the TCAM */
 	atomic_t tids_in_use;
-- 
2.3.4
