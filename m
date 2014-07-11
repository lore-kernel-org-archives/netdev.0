From: Wei Liu <wei.liu2@citrix.com>
Subject: [PATCH for stable 3.10] xen-netback: drop SKB from internal queue if frontend is disconnected
Date: Fri, 11 Jul 2014 14:08:32 +0100
Message-ID: <1405084112-8134-1-git-send-email-wei.liu2@citrix.com>
Mime-Version: 1.0
Content-Type: text/plain
Cc: Wei Liu <wei.liu2@citrix.com>, Philipp Hahn <hahn@univention.de>,
	Ian Campbell <ian.campbell@citrix.com>
To: <xen-devel@lists.xen.org>, <netdev@vger.kernel.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from smtp.citrix.com ([66.165.176.89]:7519 "EHLO SMTP.CITRIX.COM"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1752892AbaGKNIe (ORCPT <rfc822;netdev@vger.kernel.org>);
	Fri, 11 Jul 2014 09:08:34 -0400
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

In 88a810def7 ("xen-netback: fix refcnt unbalance for 3.10"), we moved
the ref counting code from xenvif_disconnect to xenvif_free.

It can occur that frontend is disconnected while there's still SKB
stuck in netback's rx_queue in rare case. When netback thread wakes up,
it will try to write to an already unmapped ring, resulting in kernel
oops.

Moving the ref counting back to xenvif_disconnect isn't an option as it
reintroduces an old bug. Further more, writing into a dead frontend's
ring and memory is just wrong. Dropping those SKBs seems to be a good
strategy.

This patch fixes that corner case: introduce a flag to indicate whether
frontend ring is mapped. If the ring is unmapped, just drop those SKBs.

This bug only manifests in 3.10 kernel. Kernel >=3.12 doesn't have it.

Reported-by: Philipp Hahn <hahn@univention.de>
Signed-off-by: Wei Liu <wei.liu2@citrix.com>
Signed-off-by: Philipp Hahn <hahn@univention.de>
Tested-by: Philipp Hahn <hahn@univention.de>
Cc: Ian Campbell <ian.campbell@citrix.com>
---
 drivers/net/xen-netback/common.h    |    1 +
 drivers/net/xen-netback/interface.c |    1 +
 drivers/net/xen-netback/netback.c   |   13 +++++++++++++
 3 files changed, 15 insertions(+)

diff --git a/drivers/net/xen-netback/common.h b/drivers/net/xen-netback/common.h
index f2faa77..3418215 100644
--- a/drivers/net/xen-netback/common.h
+++ b/drivers/net/xen-netback/common.h
@@ -66,6 +66,7 @@ struct xenvif {
 	/* The shared rings and indexes. */
 	struct xen_netif_tx_back_ring tx;
 	struct xen_netif_rx_back_ring rx;
+	bool ring_mapped;
 
 	/* Frontend feature information. */
 	u8 can_sg:1;
diff --git a/drivers/net/xen-netback/interface.c b/drivers/net/xen-netback/interface.c
index 540a796..cfdff0d 100644
--- a/drivers/net/xen-netback/interface.c
+++ b/drivers/net/xen-netback/interface.c
@@ -271,6 +271,7 @@ struct xenvif *xenvif_alloc(struct device *parent, domid_t domid,
 	vif->dev = dev;
 	INIT_LIST_HEAD(&vif->schedule_list);
 	INIT_LIST_HEAD(&vif->notify_list);
+	vif->ring_mapped = false;
 
 	vif->credit_bytes = vif->remaining_credit = ~0UL;
 	vif->credit_usec  = 0UL;
diff --git a/drivers/net/xen-netback/netback.c b/drivers/net/xen-netback/netback.c
index 70b830f..aa3f0de 100644
--- a/drivers/net/xen-netback/netback.c
+++ b/drivers/net/xen-netback/netback.c
@@ -720,6 +720,16 @@ static void xen_netbk_rx_action(struct xen_netbk *netbk)
 		vif = netdev_priv(skb->dev);
 		nr_frags = skb_shinfo(skb)->nr_frags;
 
+		/* In rare case that frontend is disconnected while
+		 * there's still SKBs stuck in netback internal
+		 * rx_queue, drop these SKBs.
+		 */
+		if (unlikely(!vif->ring_mapped)) {
+			dev_kfree_skb(skb);
+			xenvif_put(vif);
+			continue;
+		}
+
 		sco = (struct skb_cb_overlay *)skb->cb;
 		sco->meta_slots_used = netbk_gop_skb(skb, &npo);
 
@@ -1864,6 +1874,8 @@ static int xen_netbk_kthread(void *data)
 
 void xen_netbk_unmap_frontend_rings(struct xenvif *vif)
 {
+	vif->ring_mapped = false;
+
 	if (vif->tx.sring)
 		xenbus_unmap_ring_vfree(xenvif_to_xenbus_device(vif),
 					vif->tx.sring);
@@ -1899,6 +1911,7 @@ int xen_netbk_map_frontend_rings(struct xenvif *vif,
 	BACK_RING_INIT(&vif->rx, rxs, PAGE_SIZE);
 
 	vif->rx_req_cons_peek = 0;
+	vif->ring_mapped = true;
 
 	return 0;
 
-- 
1.7.10.4
