From: Shannon Nelson <shannon.nelson@oracle.com>
Subject: [PATCH v2 net-next 3/5] sunvnet: track port queues correctly
Date: Tue, 14 Mar 2017 10:24:41 -0700
Message-ID: <1489512283-422140-4-git-send-email-shannon.nelson@oracle.com>
References: <1489512283-422140-1-git-send-email-shannon.nelson@oracle.com>
Cc: sparclinux@vger.kernel.org, linux-kernel@vger.kernel.org,
        Shannon Nelson <shannon.nelson@oracle.com>
To: netdev@vger.kernel.org, davem@davemloft.net
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <1489512283-422140-1-git-send-email-shannon.nelson@oracle.com>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Track our used and unused queue indexies correctly.  Otherwise, as ports
dropped out and returned, they all eventually ended up with the same
queue index.

Orabug: 25190537

Signed-off-by: Shannon Nelson <shannon.nelson@oracle.com>
---
 drivers/net/ethernet/sun/sunvnet_common.c |   24 ++++++++++++++++++++----
 drivers/net/ethernet/sun/sunvnet_common.h |   11 ++---------
 2 files changed, 22 insertions(+), 13 deletions(-)

diff --git a/drivers/net/ethernet/sun/sunvnet_common.c b/drivers/net/ethernet/sun/sunvnet_common.c
index d3dc8ed..5e1d016 100644
--- a/drivers/net/ethernet/sun/sunvnet_common.c
+++ b/drivers/net/ethernet/sun/sunvnet_common.c
@@ -1728,11 +1728,25 @@ void sunvnet_poll_controller_common(struct net_device *dev, struct vnet *vp)
 void sunvnet_port_add_txq_common(struct vnet_port *port)
 {
 	struct vnet *vp = port->vp;
-	int n;
+	int smallest = 0;
+	int i;
+
+	/* find the first least-used q
+	 * When there are more ldoms than q's, we start to
+	 * double up on ports per queue.
+	 */
+	for (i = 0; i < VNET_MAX_TXQS; i++) {
+		if (vp->q_used[i] == 0) {
+			smallest = i;
+			break;
+		}
+		if (vp->q_used[i] < vp->q_used[smallest])
+			smallest = i;
+	}
 
-	n = vp->nports++;
-	n = n & (VNET_MAX_TXQS - 1);
-	port->q_index = n;
+	vp->nports++;
+	vp->q_used[smallest]++;
+	port->q_index = smallest;
 	netif_tx_wake_queue(netdev_get_tx_queue(VNET_PORT_TO_NET_DEVICE(port),
 						port->q_index));
 }
@@ -1743,5 +1757,7 @@ void sunvnet_port_rm_txq_common(struct vnet_port *port)
 	port->vp->nports--;
 	netif_tx_stop_queue(netdev_get_tx_queue(VNET_PORT_TO_NET_DEVICE(port),
 						port->q_index));
+	port->vp->q_used[port->q_index]--;
+	port->q_index = 0;
 }
 EXPORT_SYMBOL_GPL(sunvnet_port_rm_txq_common);
diff --git a/drivers/net/ethernet/sun/sunvnet_common.h b/drivers/net/ethernet/sun/sunvnet_common.h
index c0fac03..b20d6fa 100644
--- a/drivers/net/ethernet/sun/sunvnet_common.h
+++ b/drivers/net/ethernet/sun/sunvnet_common.h
@@ -112,22 +112,15 @@ struct vnet_mcast_entry {
 };
 
 struct vnet {
-	/* Protects port_list and port_hash.  */
-	spinlock_t		lock;
-
+	spinlock_t		lock; /* Protects port_list and port_hash.  */
 	struct net_device	*dev;
-
 	u32			msg_enable;
-
+	u8			q_used[VNET_MAX_TXQS];
 	struct list_head	port_list;
-
 	struct hlist_head	port_hash[VNET_PORT_HASH_SIZE];
-
 	struct vnet_mcast_entry	*mcast_list;
-
 	struct list_head	list;
 	u64			local_mac;
-
 	int			nports;
 };
 
-- 
1.7.1
