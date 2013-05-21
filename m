From: Vipul Pandya <vipul@chelsio.com>
Subject: [PATCH net-next 1/2] cxgb3: Fix warning about using rcu_dereference when not in a rcu-locked section
Date: Tue, 21 May 2013 19:51:28 +0530
Message-ID: <1369146089-19060-2-git-send-email-vipul@chelsio.com>
References: <1369146089-19060-1-git-send-email-vipul@chelsio.com>
Cc: davem@davemloft.net, divy@chelsio.com, dm@chelsio.com,
	santosh@chelsio.com, fenlason@redhat.com, vipul@chelsio.com
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from stargate.chelsio.com ([67.207.112.58]:14602 "EHLO
	stargate.chelsio.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1754485Ab3EUO14 (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 21 May 2013 10:27:56 -0400
In-Reply-To: <1369146089-19060-1-git-send-email-vipul@chelsio.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Jay Fenlason <fenlason@redhat.com>

It is about using rcu_dereference() when not in a rcu-locked section. It only
happens on initialization hence fix the initialization to not rcu_dereference()

Signed-off-by: Jay Fenlason <fenlason@redhat.com>
---
 drivers/net/ethernet/chelsio/cxgb3/cxgb3_offload.c | 9 +++++----
 1 file changed, 5 insertions(+), 4 deletions(-)

diff --git a/drivers/net/ethernet/chelsio/cxgb3/cxgb3_offload.c b/drivers/net/ethernet/chelsio/cxgb3/cxgb3_offload.c
index 0c96e5f..4058b85 100644
--- a/drivers/net/ethernet/chelsio/cxgb3/cxgb3_offload.c
+++ b/drivers/net/ethernet/chelsio/cxgb3/cxgb3_offload.c
@@ -1246,6 +1246,7 @@ int cxgb3_offload_activate(struct adapter *adapter)
 	struct tid_range stid_range, tid_range;
 	struct mtutab mtutab;
 	unsigned int l2t_capacity;
+	struct l2t_data *l2td;
 
 	t = kzalloc(sizeof(*t), GFP_KERNEL);
 	if (!t)
@@ -1261,8 +1262,8 @@ int cxgb3_offload_activate(struct adapter *adapter)
 		goto out_free;
 
 	err = -ENOMEM;
-	RCU_INIT_POINTER(dev->l2opt, t3_init_l2t(l2t_capacity));
-	if (!L2DATA(dev))
+	l2td = t3_init_l2t(l2t_capacity);
+	if (!l2td)
 		goto out_free;
 
 	natids = min(tid_range.num / 2, MAX_ATIDS);
@@ -1279,6 +1280,7 @@ int cxgb3_offload_activate(struct adapter *adapter)
 	INIT_LIST_HEAD(&t->list_node);
 	t->dev = dev;
 
+	RCU_INIT_POINTER(dev->l2opt, l2td);
 	T3C_DATA(dev) = t;
 	dev->recv = process_rx;
 	dev->neigh_update = t3_l2t_update;
@@ -1294,8 +1296,7 @@ int cxgb3_offload_activate(struct adapter *adapter)
 	return 0;
 
 out_free_l2t:
-	t3_free_l2t(L2DATA(dev));
-	RCU_INIT_POINTER(dev->l2opt, NULL);
+	t3_free_l2t(l2td);
 out_free:
 	kfree(t);
 	return err;
-- 
1.8.0
