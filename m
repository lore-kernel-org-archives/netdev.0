From: Paolo Abeni <pabeni@redhat.com>
Subject: [PATCH net-next 3/4] vxlan: remove gro_cell support
Date: Thu,  7 Jul 2016 17:58:49 +0200
Message-ID: <6f90239eb6ccb9145a886d4f01c6620c6d6ec87f.1467907022.git.pabeni@redhat.com>
References: <cover.1467907022.git.pabeni@redhat.com>
Cc: "David S. Miller" <davem@davemloft.net>,
	Jesse Gross <jesse@kernel.org>,
	Tom Herbert <tom@herbertland.com>,
	Hannes Frederic Sowa <hannes@stressinduktion.org>,
	Jiri Benc <jbenc@redhat.com>
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mx1.redhat.com ([209.132.183.28]:51574 "EHLO mx1.redhat.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1753127AbcGGQAs (ORCPT <rfc822;netdev@vger.kernel.org>);
	Thu, 7 Jul 2016 12:00:48 -0400
In-Reply-To: <cover.1467907022.git.pabeni@redhat.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

GRO is now handled entirely by the udp_offload layer and  there is no need
for trying it again at the device level. We can drop gro_cell usage,
simplifying the driver a bit, while maintaining the same performance for
TCP and improving slightly for UDP.
This basically reverts the commit 58ce31cca1ff ("vxlan: GRO support
at tunnel layer")

Signed-off-by: Paolo Abeni <pabeni@redhat.com>
---
 drivers/net/vxlan.c | 9 ++-------
 include/net/vxlan.h | 1 -
 2 files changed, 2 insertions(+), 8 deletions(-)

diff --git a/drivers/net/vxlan.c b/drivers/net/vxlan.c
index ae7455d..050cf40 100644
--- a/drivers/net/vxlan.c
+++ b/drivers/net/vxlan.c
@@ -1351,7 +1351,7 @@ static int vxlan_rcv(struct sock *sk, struct sk_buff *skb)
 	stats->rx_bytes += skb->len;
 	u64_stats_update_end(&stats->syncp);
 
-	gro_cells_receive(&vxlan->gro_cells, skb);
+	netif_rx(skb);
 	return 0;
 
 drop:
@@ -2533,8 +2533,6 @@ static void vxlan_setup(struct net_device *dev)
 
 	vxlan->dev = dev;
 
-	gro_cells_init(&vxlan->gro_cells, dev);
-
 	for (h = 0; h < FDB_HASH_SIZE; ++h)
 		INIT_HLIST_HEAD(&vxlan->fdb_head[h]);
 }
@@ -3044,7 +3042,6 @@ static void vxlan_dellink(struct net_device *dev, struct list_head *head)
 		hlist_del_rcu(&vxlan->hlist);
 	spin_unlock(&vn->sock_lock);
 
-	gro_cells_destroy(&vxlan->gro_cells);
 	list_del(&vxlan->next);
 	unregister_netdevice_queue(dev, head);
 }
@@ -3295,10 +3292,8 @@ static void __net_exit vxlan_exit_net(struct net *net)
 		/* If vxlan->dev is in the same netns, it has already been added
 		 * to the list by the previous loop.
 		 */
-		if (!net_eq(dev_net(vxlan->dev), net)) {
-			gro_cells_destroy(&vxlan->gro_cells);
+		if (!net_eq(dev_net(vxlan->dev), net))
 			unregister_netdevice_queue(vxlan->dev, &list);
-		}
 	}
 
 	unregister_netdevice_many(&list);
diff --git a/include/net/vxlan.h b/include/net/vxlan.h
index b96d036..9fa3247 100644
--- a/include/net/vxlan.h
+++ b/include/net/vxlan.h
@@ -237,7 +237,6 @@ struct vxlan_dev {
 	struct timer_list age_timer;
 	spinlock_t	  hash_lock;
 	unsigned int	  addrcnt;
-	struct gro_cells  gro_cells;
 
 	struct vxlan_config	cfg;
 
-- 
1.8.3.1
