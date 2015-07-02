From: Tom Herbert <tom@herbertland.com>
Subject: [PATCH net-next 3/3] vxlan: GRO support at tunnel layer
Date: Thu, 2 Jul 2015 14:06:23 -0700
Message-ID: <1435871183-655424-4-git-send-email-tom@herbertland.com>
Mime-Version: 1.0
Content-Type: text/plain
To: <davem@davemloft.net>, <netdev@vger.kernel.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mx0b-00082601.pphosted.com ([67.231.153.30]:54198 "EHLO
	mx0b-00082601.pphosted.com" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with ESMTP id S1754410AbbGBVGe (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 2 Jul 2015 17:06:34 -0400
Received: from pps.filterd (m0004060 [127.0.0.1])
	by mx0b-00082601.pphosted.com (8.14.5/8.14.5) with SMTP id t62L5OPR008917
	for <netdev@vger.kernel.org>; Thu, 2 Jul 2015 14:06:33 -0700
Received: from mail.thefacebook.com ([199.201.64.23])
	by mx0b-00082601.pphosted.com with ESMTP id 1vdc1r071c-2
	(version=TLSv1/SSLv3 cipher=AES128-SHA bits=128 verify=NOT)
	for <netdev@vger.kernel.org>; Thu, 02 Jul 2015 14:06:33 -0700
Received: from facebook.com (2401:db00:20:702e:face:0:23:0)	by
 mx-out.facebook.com (10.223.100.97) with ESMTP	id
 3675621420fe11e5947c24be0593f280-3ecce2b0 for <netdev@vger.kernel.org>;	Thu,
 02 Jul 2015 14:06:31 -0700
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
index d41b482..363f6b1 100644
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
@@ -1318,7 +1320,7 @@ static void vxlan_rcv(struct vxlan_sock *vs, struct sk_buff *skb,
 	stats->rx_bytes += skb->len;
 	u64_stats_update_end(&stats->syncp);
 
-	netif_rx(skb);
+	gro_cells_receive(&vxlan->gro_cells, skb);
 
 	return;
 drop:
@@ -2376,6 +2378,8 @@ static void vxlan_setup(struct net_device *dev)
 
 	vxlan->dev = dev;
 
+	gro_cells_init(&vxlan->gro_cells, dev);
+
 	for (h = 0; h < FDB_HASH_SIZE; ++h)
 		INIT_HLIST_HEAD(&vxlan->fdb_head[h]);
 }
@@ -2751,6 +2755,7 @@ static void vxlan_dellink(struct net_device *dev, struct list_head *head)
 		hlist_del_rcu(&vxlan->hlist);
 	spin_unlock(&vn->sock_lock);
 
+	gro_cells_destroy(&vxlan->gro_cells);
 	list_del(&vxlan->next);
 	unregister_netdevice_queue(dev, head);
 }
@@ -2956,8 +2961,10 @@ static void __net_exit vxlan_exit_net(struct net *net)
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
