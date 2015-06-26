From: Tom Herbert <tom@herbertland.com>
Subject: [PATCH RFC net-next] vxlan: GRO support at tunnel layer
Date: Fri, 26 Jun 2015 16:09:49 -0700
Message-ID: <1435360189-641007-1-git-send-email-tom@herbertland.com>
Mime-Version: 1.0
Content-Type: text/plain
To: <davem@davemloft.net>, <netdev@vger.kernel.org>,
	<sramamur@linux.vnet.ibm.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mx0a-00082601.pphosted.com ([67.231.145.42]:56658 "EHLO
	mx0a-00082601.pphosted.com" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with ESMTP id S1751922AbbFZXOk (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 26 Jun 2015 19:14:40 -0400
Received: from pps.filterd (m0004348 [127.0.0.1])
	by m0004348.ppops.net (8.14.5/8.14.5) with SMTP id t5QNDu0S011895
	for <netdev@vger.kernel.org>; Fri, 26 Jun 2015 16:14:39 -0700
Received: from mail.thefacebook.com ([199.201.64.23])
	by m0004348.ppops.net with ESMTP id 1v9at1rk72-2
	(version=TLSv1/SSLv3 cipher=AES128-SHA bits=128 verify=NOT)
	for <netdev@vger.kernel.org>; Fri, 26 Jun 2015 16:14:39 -0700
Received: from facebook.com (2401:db00:20:702e:face:0:23:0)	by
 mx-out.facebook.com (10.212.232.63) with ESMTP	id
 7e6d4ad21c5811e5a43f0002c992ebde-99bd82b0 for <netdev@vger.kernel.org>;	Fri,
 26 Jun 2015 16:10:11 -0700
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Add calls to gro_cells infrastructure to do GRO when receiving on a tunnel.

Testing:

Ran 200 netperf TCP_STREAM instance

- With fix (GRO enabled on VXLAN interface)

  Verify GRO is happening.

  9084 MBps tput
  3.44% CPU utilization

- Without fix (GRO disabled on VXLAN interface)

  Verified no GRO is happening.

  9084 MBps tput
  5.54% CPU utilization

Signed-off-by: Tom Herbert <tom@herbertland.com>
---
 drivers/net/vxlan.c | 11 +++++++++--
 1 file changed, 9 insertions(+), 2 deletions(-)

diff --git a/drivers/net/vxlan.c b/drivers/net/vxlan.c
index 34c519e..d433f8a 100644
--- a/drivers/net/vxlan.c
+++ b/drivers/net/vxlan.c
@@ -28,6 +28,7 @@
 #include <linux/hash.h>
 #include <linux/ethtool.h>
 #include <net/arp.h>
+#include <net/gro_cells.h>
 #include <net/ndisc.h>
 #include <net/ip.h>
 #include <net/ip_tunnels.h>
@@ -132,6 +133,7 @@ struct vxlan_dev {
 	spinlock_t	  hash_lock;
 	unsigned int	  addrcnt;
 	unsigned int	  addrmax;
+	struct gro_cells  gro_cells;
 
 	struct hlist_head fdb_head[FDB_HASH_SIZE];
 };
@@ -1326,7 +1328,7 @@ static void vxlan_rcv(struct vxlan_sock *vs, struct sk_buff *skb,
 	stats->rx_bytes += skb->len;
 	u64_stats_update_end(&stats->syncp);
 
-	netif_rx(skb);
+	gro_cells_receive(&vxlan->gro_cells, skb);
 
 	return;
 drop:
@@ -2384,6 +2386,8 @@ static void vxlan_setup(struct net_device *dev)
 
 	vxlan->dev = dev;
 
+	gro_cells_init(&vxlan->gro_cells, dev);
+
 	for (h = 0; h < FDB_HASH_SIZE; ++h)
 		INIT_HLIST_HEAD(&vxlan->fdb_head[h]);
 }
@@ -2759,6 +2763,7 @@ static void vxlan_dellink(struct net_device *dev, struct list_head *head)
 		hlist_del_rcu(&vxlan->hlist);
 	spin_unlock(&vn->sock_lock);
 
+	gro_cells_destroy(&vxlan->gro_cells);
 	list_del(&vxlan->next);
 	unregister_netdevice_queue(dev, head);
 }
@@ -2964,8 +2969,10 @@ static void __net_exit vxlan_exit_net(struct net *net)
 		/* If vxlan->dev is in the same netns, it has already been added
 		 * to the list by the previous loop.
 		 */
-		if (!net_eq(dev_net(vxlan->dev), net))
+		if (!net_eq(dev_net(vxlan->dev), net)) {
+			gro_cells_destroy(&vxlan->gro_cells);
 			unregister_netdevice_queue(vxlan->dev, &list);
+		}
 	}
 
 	unregister_netdevice_many(&list);
-- 
1.8.1
