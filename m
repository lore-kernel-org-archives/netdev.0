From: Ganesh Goudar <ganeshgr@chelsio.com>
Subject: [PATCH net-next] cxgb4: Increase max number of tc u32 links
Date: Thu, 16 Feb 2017 12:22:45 +0530
Message-ID: <1487227965-29381-1-git-send-email-ganeshgr@chelsio.com>
Cc: nirranjan@chelsio.com, Arjun V <arjun@chelsio.com>,
        Rahul Lakkireddy <rahul.lakkireddy@chelsio.com>,
        Casey Leedom <leedom@chelsio.com>,
        Ganesh Goudar <ganeshgr@chelsio.com>
To: netdev@vger.kernel.org, davem@davemloft.net
Return-path: <netdev-owner@vger.kernel.org>
Received: from stargate.chelsio.com ([12.32.117.8]:13069 "EHLO
        stargate.chelsio.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1752486AbdBPGyW (ORCPT
        <rfc822;netdev@vger.kernel.org>); Thu, 16 Feb 2017 01:54:22 -0500
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Arjun V <arjun@chelsio.com>

Make max number of supported tc u32 links equal to max number of filters
supported by hardware.

Signed-off-by: Arjun V <arjun@chelsio.com>
Signed-off-by: Rahul Lakkireddy <rahul.lakkireddy@chelsio.com>
Signed-off-by: Casey Leedom <leedom@chelsio.com>
Signed-off-by: Ganesh Goudar <ganeshgr@chelsio.com>
---
 drivers/net/ethernet/chelsio/cxgb4/cxgb4_main.c   |  3 +--
 drivers/net/ethernet/chelsio/cxgb4/cxgb4_tc_u32.c | 12 +++++-------
 drivers/net/ethernet/chelsio/cxgb4/cxgb4_tc_u32.h |  5 +----
 3 files changed, 7 insertions(+), 13 deletions(-)

diff --git a/drivers/net/ethernet/chelsio/cxgb4/cxgb4_main.c b/drivers/net/ethernet/chelsio/cxgb4/cxgb4_main.c
index 8ba3dc2..afb0967 100644
--- a/drivers/net/ethernet/chelsio/cxgb4/cxgb4_main.c
+++ b/drivers/net/ethernet/chelsio/cxgb4/cxgb4_main.c
@@ -4907,8 +4907,7 @@ static int init_one(struct pci_dev *pdev, const struct pci_device_id *ent)
 			 "continuing\n");
 		adapter->params.offload = 0;
 	} else {
-		adapter->tc_u32 = cxgb4_init_tc_u32(adapter,
-						    CXGB4_MAX_LINK_HANDLE);
+		adapter->tc_u32 = cxgb4_init_tc_u32(adapter);
 		if (!adapter->tc_u32)
 			dev_warn(&pdev->dev,
 				 "could not offload tc u32, continuing\n");
diff --git a/drivers/net/ethernet/chelsio/cxgb4/cxgb4_tc_u32.c b/drivers/net/ethernet/chelsio/cxgb4/cxgb4_tc_u32.c
index 52af62e..a1b1942 100644
--- a/drivers/net/ethernet/chelsio/cxgb4/cxgb4_tc_u32.c
+++ b/drivers/net/ethernet/chelsio/cxgb4/cxgb4_tc_u32.c
@@ -437,28 +437,26 @@ void cxgb4_cleanup_tc_u32(struct adapter *adap)
 	t4_free_mem(adap->tc_u32);
 }
 
-struct cxgb4_tc_u32_table *cxgb4_init_tc_u32(struct adapter *adap,
-					     unsigned int size)
+struct cxgb4_tc_u32_table *cxgb4_init_tc_u32(struct adapter *adap)
 {
+	unsigned int max_tids = adap->tids.nftids;
 	struct cxgb4_tc_u32_table *t;
 	unsigned int i;
 
-	if (!size)
+	if (!max_tids)
 		return NULL;
 
 	t = t4_alloc_mem(sizeof(*t) +
-			 (size * sizeof(struct cxgb4_link)));
+			 (max_tids * sizeof(struct cxgb4_link)));
 	if (!t)
 		return NULL;
 
-	t->size = size;
+	t->size = max_tids;
 
 	for (i = 0; i < t->size; i++) {
 		struct cxgb4_link *link = &t->table[i];
 		unsigned int bmap_size;
-		unsigned int max_tids;
 
-		max_tids = adap->tids.nftids;
 		bmap_size = BITS_TO_LONGS(max_tids);
 		link->tid_map = t4_alloc_mem(sizeof(unsigned long) * bmap_size);
 		if (!link->tid_map)
diff --git a/drivers/net/ethernet/chelsio/cxgb4/cxgb4_tc_u32.h b/drivers/net/ethernet/chelsio/cxgb4/cxgb4_tc_u32.h
index 6bdc885..021261a 100644
--- a/drivers/net/ethernet/chelsio/cxgb4/cxgb4_tc_u32.h
+++ b/drivers/net/ethernet/chelsio/cxgb4/cxgb4_tc_u32.h
@@ -37,8 +37,6 @@
 
 #include <net/pkt_cls.h>
 
-#define CXGB4_MAX_LINK_HANDLE 32
-
 static inline bool can_tc_u32_offload(struct net_device *dev)
 {
 	struct adapter *adap = netdev2adap(dev);
@@ -52,6 +50,5 @@ int cxgb4_delete_knode(struct net_device *dev, __be16 protocol,
 		       struct tc_cls_u32_offload *cls);
 
 void cxgb4_cleanup_tc_u32(struct adapter *adapter);
-struct cxgb4_tc_u32_table *cxgb4_init_tc_u32(struct adapter *adap,
-					     unsigned int size);
+struct cxgb4_tc_u32_table *cxgb4_init_tc_u32(struct adapter *adap);
 #endif /* __CXGB4_TC_U32_H */
-- 
2.1.0
