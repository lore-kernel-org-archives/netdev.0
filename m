From: Hariprasad Shenai <hariprasad@chelsio.com>
Subject: [PATCH net 5/9] cxgb4: Assign filter server TIDs properly
Date: Mon, 16 Dec 2013 17:42:14 +0530
Message-ID: <1387195938-3531-6-git-send-email-hariprasad@chelsio.com>
References: <1387195938-3531-1-git-send-email-hariprasad@chelsio.com>
Cc: davem@davemloft.net, roland@purestorage.com, dm@chelsio.com,
	swise@opengridcomputing.com, leedom@chelsio.com,
	santosh@chelsio.com, kumaras@chelsio.com, hariprasad@chelsio.com,
	nirranjan@chelsio.com
To: netdev@vger.kernel.org, linux-rdma@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from stargate.chelsio.com ([67.207.112.58]:10177 "EHLO
	stargate.chelsio.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1753285Ab3LPMUJ (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 16 Dec 2013 07:20:09 -0500
In-Reply-To: <1387195938-3531-1-git-send-email-hariprasad@chelsio.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Kumar Sanghvi <kumaras@chelsio.com>

The LE workaround code is incorrectly reusing the TCAM TIDs
(meant for allocation by firmware in case of hash collisions) for filter
servers. This patch assigns the filter server TIDs properly starting from
sftid_base index.

Based on original work by Santosh Rastapur <santosh@chelsio.com>

Signed-off-by: Hariprasad Shenai <hariprasad@chelsio.com>
Signed-off-by: Kumar Sanghvi <kumaras@chelsio.com>
---
 drivers/net/ethernet/chelsio/cxgb4/cxgb4_main.c | 16 ++++++++++++----
 drivers/net/ethernet/chelsio/cxgb4/cxgb4_uld.h  |  9 ++++++++-
 2 files changed, 20 insertions(+), 5 deletions(-)

diff --git a/drivers/net/ethernet/chelsio/cxgb4/cxgb4_main.c b/drivers/net/ethernet/chelsio/cxgb4/cxgb4_main.c
index 4bccfca..8133bee 100644
--- a/drivers/net/ethernet/chelsio/cxgb4/cxgb4_main.c
+++ b/drivers/net/ethernet/chelsio/cxgb4/cxgb4_main.c
@@ -3019,7 +3019,8 @@ int cxgb4_alloc_sftid(struct tid_info *t, int family, void *data)
 	}
 	if (stid >= 0) {
 		t->stid_tab[stid].data = data;
-		stid += t->stid_base;
+		stid -= t->nstids;
+		stid += t->sftid_base;
 		t->sftids_in_use++;
 	}
 	spin_unlock_bh(&t->stid_lock);
@@ -3031,7 +3032,14 @@ EXPORT_SYMBOL(cxgb4_alloc_sftid);
  */
 void cxgb4_free_stid(struct tid_info *t, unsigned int stid, int family)
 {
-	stid -= t->stid_base;
+	/* Is it a server filter TID? */
+	if (t->nsftids && (stid >= t->sftid_base)) {
+		stid -= t->sftid_base;
+		stid += t->nstids;
+	} else {
+		stid -= t->stid_base;
+	}
+
 	spin_lock_bh(&t->stid_lock);
 	if (family == PF_INET)
 		__clear_bit(stid, t->stid_bmap);
@@ -4201,7 +4209,7 @@ int cxgb4_create_server_filter(const struct net_device *dev, unsigned int stid,
 	adap = netdev2adap(dev);
 
 	/* Adjust stid to correct filter index */
-	stid -= adap->tids.nstids;
+	stid -= adap->tids.sftid_base;
 	stid += adap->tids.nftids;
 
 	/* Check to make sure the filter requested is writable ...
@@ -4264,7 +4272,7 @@ int cxgb4_remove_server_filter(const struct net_device *dev, unsigned int stid,
 	adap = netdev2adap(dev);
 
 	/* Adjust stid to correct filter index */
-	stid -= adap->tids.nstids;
+	stid -= adap->tids.sftid_base;
 	stid += adap->tids.nftids;
 
 	f = &adap->tids.ftid_tab[stid];
diff --git a/drivers/net/ethernet/chelsio/cxgb4/cxgb4_uld.h b/drivers/net/ethernet/chelsio/cxgb4/cxgb4_uld.h
index 795ab25..bcd7b93 100644
--- a/drivers/net/ethernet/chelsio/cxgb4/cxgb4_uld.h
+++ b/drivers/net/ethernet/chelsio/cxgb4/cxgb4_uld.h
@@ -132,7 +132,14 @@ static inline void *lookup_atid(const struct tid_info *t, unsigned int atid)
 
 static inline void *lookup_stid(const struct tid_info *t, unsigned int stid)
 {
-	stid -= t->stid_base;
+	/* Is it a server filter TID? */
+	if (t->nsftids && (stid >= t->sftid_base)) {
+		stid -= t->sftid_base;
+		stid += t->nstids;
+	} else {
+		stid -= t->stid_base;
+	}
+
 	return stid < (t->nstids + t->nsftids) ? t->stid_tab[stid].data : NULL;
 }
 
-- 
1.8.0
