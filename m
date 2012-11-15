From: Annie Li <annie.li@oracle.com>
Subject: [PATCH 2/4] xen/netback: Split one page pool into two(tx/rx) page pool.
Date: Thu, 15 Nov 2012 15:04:49 +0800
Message-ID: <1352963089-599-1-git-send-email-annie.li@oracle.com>
References: <1352962987-541-1-git-send-email-annie.li@oracle.com>
Cc: annie.li@oracle.com
To: xen-devel@lists.xensource.com, netdev@vger.kernel.org,
	konrad.wilk@oracle.com, Ian.Campbell@citrix.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from userp1040.oracle.com ([156.151.31.81]:36904 "EHLO
	userp1040.oracle.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751970Ab2KOHGB (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 15 Nov 2012 02:06:01 -0500
In-Reply-To: <1352962987-541-1-git-send-email-annie.li@oracle.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

For tx path, this implementation simplifies the work of searching out
grant page from page pool based on grant reference.

Signed-off-by: Annie Li <annie.li@oracle.com>
---
 drivers/net/xen-netback/common.h    |   14 ++++++++++----
 drivers/net/xen-netback/interface.c |   12 ++++++++----
 drivers/net/xen-netback/netback.c   |   15 +++++++++------
 3 files changed, 27 insertions(+), 14 deletions(-)

diff --git a/drivers/net/xen-netback/common.h b/drivers/net/xen-netback/common.h
index a85cac6..02c8573 100644
--- a/drivers/net/xen-netback/common.h
+++ b/drivers/net/xen-netback/common.h
@@ -47,8 +47,6 @@
 
 #define XEN_NETIF_TX_RING_SIZE __CONST_RING_SIZE(xen_netif_tx, PAGE_SIZE)
 #define XEN_NETIF_RX_RING_SIZE __CONST_RING_SIZE(xen_netif_rx, PAGE_SIZE)
-#define MAXIMUM_OUTSTANDING_BLOCK_REQS \
-			(XEN_NETIF_TX_RING_SIZE + XEN_NETIF_RX_RING_SIZE)
 
 struct xen_netbk;
 
@@ -111,8 +109,16 @@ struct xenvif {
 
 	wait_queue_head_t waiting_to_free;
 
-	struct persistent_entry *persistent_gnt[MAXIMUM_OUTSTANDING_BLOCK_REQS];
-	unsigned int persistent_gntcnt;
+	struct persistent_entry *persistent_tx_gnt[XEN_NETIF_TX_RING_SIZE];
+
+	/*
+	 * 2*XEN_NETIF_RX_RING_SIZE is for the case of each head/fragment page
+	 * using 2 copy operations.
+	 */
+	struct persistent_entry *persistent_rx_gnt[2*XEN_NETIF_RX_RING_SIZE];
+
+	unsigned int persistent_tx_gntcnt;
+	unsigned int persistent_rx_gntcnt;
 };
 
 static inline struct xenbus_device *xenvif_to_xenbus_device(struct xenvif *vif)
diff --git a/drivers/net/xen-netback/interface.c b/drivers/net/xen-netback/interface.c
index 226d159..ecbe116 100644
--- a/drivers/net/xen-netback/interface.c
+++ b/drivers/net/xen-netback/interface.c
@@ -300,7 +300,8 @@ struct xenvif *xenvif_alloc(struct device *parent, domid_t domid,
 		return ERR_PTR(err);
 	}
 
-	vif->persistent_gntcnt = 0;
+	vif->persistent_tx_gntcnt = 0;
+	vif->persistent_rx_gntcnt = 0;
 
 	netdev_dbg(dev, "Successfully created xenvif\n");
 	return vif;
@@ -385,9 +386,12 @@ void xenvif_disconnect(struct xenvif *vif)
 	unregister_netdev(vif->dev);
 
 	xen_netbk_unmap_frontend_rings(vif);
-	if (vif->persistent_grant)
-		xenvif_free_grants(vif->persistent_gnt,
-				   vif->persistent_gntcnt);
+	if (vif->persistent_grant) {
+		xenvif_free_grants(vif->persistent_tx_gnt,
+				   vif->persistent_tx_gntcnt);
+		xenvif_free_grants(vif->persistent_rx_gnt,
+				   vif->persistent_rx_gntcnt);
+	}
 
 	free_netdev(vif->dev);
 }
diff --git a/drivers/net/xen-netback/netback.c b/drivers/net/xen-netback/netback.c
index a26d3fc..ec59c73 100644
--- a/drivers/net/xen-netback/netback.c
+++ b/drivers/net/xen-netback/netback.c
@@ -208,14 +208,17 @@ grant_memory_copy_op(unsigned int cmd, void *vuop, unsigned int count,
 
 	BUG_ON(cmd != GNTTABOP_copy);
 	for (i = 0; i < count; i++) {
-		if (tx_pool)
+		if (tx_pool) {
 			vif = netbk->gnttab_tx_vif[i];
-		else
+			gnt_count = &vif->persistent_tx_gntcnt;
+			gnt_total = XEN_NETIF_TX_RING_SIZE;
+			pers_entry = vif->persistent_tx_gnt;
+		} else {
 			vif = netbk->gnttab_rx_vif[i];
-
-		pers_entry = vif->persistent_gnt;
-		gnt_count = &vif->persistent_gntcnt;
-		gnt_total = MAXIMUM_OUTSTANDING_BLOCK_REQS;
+			gnt_count = &vif->persistent_rx_gntcnt;
+			gnt_total = 2*XEN_NETIF_RX_RING_SIZE;
+			pers_entry = vif->persistent_rx_gnt;
+		}
 
 		if (vif->persistent_grant) {
 			void *saddr, *daddr;
-- 
1.7.3.4
