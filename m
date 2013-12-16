From: Hariprasad Shenai <hariprasad@chelsio.com>
Subject: [PATCH net 1/9] cxgb4: Properly account for server filter entries
Date: Mon, 16 Dec 2013 17:42:10 +0530
Message-ID: <1387195938-3531-2-git-send-email-hariprasad@chelsio.com>
References: <1387195938-3531-1-git-send-email-hariprasad@chelsio.com>
Cc: davem@davemloft.net, roland@purestorage.com, dm@chelsio.com,
	swise@opengridcomputing.com, leedom@chelsio.com,
	santosh@chelsio.com, kumaras@chelsio.com, hariprasad@chelsio.com,
	nirranjan@chelsio.com
To: netdev@vger.kernel.org, linux-rdma@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from stargate.chelsio.com ([67.207.112.58]:1677 "EHLO
	stargate.chelsio.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1753900Ab3LPMTw (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 16 Dec 2013 07:19:52 -0500
In-Reply-To: <1387195938-3531-1-git-send-email-hariprasad@chelsio.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Kumar Sanghvi <kumaras@chelsio.com>

When creating server filters via LE-Workaround path, properly track
the server filter entries, and don't confuse them with regular
server entries.

Based on original work by Hariprasad Shenai <hariprasad@chelsio.com>

Signed-off-by: Hariprasad Shenai <hariprasad@chelsio.com>
Signed-off-by: Kumar Sanghvi <kumaras@chelsio.com>
---
 drivers/net/ethernet/chelsio/cxgb4/cxgb4_main.c | 7 ++++++-
 drivers/net/ethernet/chelsio/cxgb4/cxgb4_uld.h  | 1 +
 2 files changed, 7 insertions(+), 1 deletion(-)

diff --git a/drivers/net/ethernet/chelsio/cxgb4/cxgb4_main.c b/drivers/net/ethernet/chelsio/cxgb4/cxgb4_main.c
index d6b12e0..f9f0505 100644
--- a/drivers/net/ethernet/chelsio/cxgb4/cxgb4_main.c
+++ b/drivers/net/ethernet/chelsio/cxgb4/cxgb4_main.c
@@ -3013,7 +3013,7 @@ int cxgb4_alloc_sftid(struct tid_info *t, int family, void *data)
 	if (stid >= 0) {
 		t->stid_tab[stid].data = data;
 		stid += t->stid_base;
-		t->stids_in_use++;
+		t->sftids_in_use++;
 	}
 	spin_unlock_bh(&t->stid_lock);
 	return stid;
@@ -3032,6 +3032,10 @@ void cxgb4_free_stid(struct tid_info *t, unsigned int stid, int family)
 		bitmap_release_region(t->stid_bmap, stid, 2);
 	t->stid_tab[stid].data = NULL;
 	t->stids_in_use--;
+	if (stid < t->nstids)
+		t->stids_in_use--;
+	else
+		t->sftids_in_use--;
 	spin_unlock_bh(&t->stid_lock);
 }
 EXPORT_SYMBOL(cxgb4_free_stid);
@@ -3156,6 +3160,7 @@ static int tid_init(struct tid_info *t)
 	spin_lock_init(&t->atid_lock);
 
 	t->stids_in_use = 0;
+	t->sftids_in_use = 0;
 	t->afree = NULL;
 	t->atids_in_use = 0;
 	atomic_set(&t->tids_in_use, 0);
diff --git a/drivers/net/ethernet/chelsio/cxgb4/cxgb4_uld.h b/drivers/net/ethernet/chelsio/cxgb4/cxgb4_uld.h
index 6f21f24..795ab25 100644
--- a/drivers/net/ethernet/chelsio/cxgb4/cxgb4_uld.h
+++ b/drivers/net/ethernet/chelsio/cxgb4/cxgb4_uld.h
@@ -115,6 +115,7 @@ struct tid_info {
 
 	spinlock_t stid_lock;
 	unsigned int stids_in_use;
+	unsigned int sftids_in_use;
 
 	atomic_t tids_in_use;
 };
-- 
1.8.0
