From: Tom Herbert <tom@herbertland.com>
Subject: [PATCH v2 net-next 2/4] vxlan: GRO support at tunnel layer
Date: Mon, 3 Aug 2015 10:11:16 -0700
Message-ID: <1438621878-1113072-3-git-send-email-tom@herbertland.com>
References: <1438621878-1113072-1-git-send-email-tom@herbertland.com>
Mime-Version: 1.0
Content-Type: text/plain
Cc: <kernel-team@fb.com>
To: <davem@davemloft.net>, <netdev@vger.kernel.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mx0a-00082601.pphosted.com ([67.231.145.42]:58236 "EHLO
	mx0a-00082601.pphosted.com" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with ESMTP id S1755209AbbHCRL7 (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 3 Aug 2015 13:11:59 -0400
Received: from pps.filterd (m0044008 [127.0.0.1])
	by mx0a-00082601.pphosted.com (8.14.5/8.14.5) with SMTP id t73HAmjE009765
	for <netdev@vger.kernel.org>; Mon, 3 Aug 2015 10:11:58 -0700
Received: from mail.thefacebook.com ([199.201.64.23])
	by mx0a-00082601.pphosted.com with ESMTP id 1w2c1mg2qn-1
	(version=TLSv1/SSLv3 cipher=AES128-SHA bits=128 verify=NOT)
	for <netdev@vger.kernel.org>; Mon, 03 Aug 2015 10:11:58 -0700
Received: from facebook.com (2401:db00:20:702e:face:0:23:0)	by
 mx-out.facebook.com (10.223.101.97) with ESMTP	id
 be47cd2c3a0211e5939724be0595f910-e43f12b0 for <netdev@vger.kernel.org>;	Mon,
 03 Aug 2015 10:11:56 -0700
In-Reply-To: <1438621878-1113072-1-git-send-email-tom@herbertland.com>
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
 drivers/net/vxlan.c | 9 +++++++--
 include/net/vxlan.h | 1 +
 2 files changed, 8 insertions(+), 2 deletions(-)

diff --git a/drivers/net/vxlan.c b/drivers/net/vxlan.c
index 60b5b42..ef30037 100644
--- a/drivers/net/vxlan.c
+++ b/drivers/net/vxlan.c
@@ -1208,7 +1208,7 @@ static void vxlan_rcv(struct vxlan_sock *vs, struct sk_buff *skb,
 	stats->rx_bytes += skb->len;
 	u64_stats_update_end(&stats->syncp);
 
-	netif_rx(skb);
+	gro_cells_receive(&vxlan->gro_cells, skb);
 
 	return;
 drop:
@@ -2436,6 +2436,8 @@ static void vxlan_setup(struct net_device *dev)
 
 	vxlan->dev = dev;
 
+	gro_cells_init(&vxlan->gro_cells, dev);
+
 	for (h = 0; h < FDB_HASH_SIZE; ++h)
 		INIT_HLIST_HEAD(&vxlan->fdb_head[h]);
 }
@@ -2880,6 +2882,7 @@ static void vxlan_dellink(struct net_device *dev, struct list_head *head)
 		hlist_del_rcu(&vxlan->hlist);
 	spin_unlock(&vn->sock_lock);
 
+	gro_cells_destroy(&vxlan->gro_cells);
 	list_del(&vxlan->next);
 	unregister_netdevice_queue(dev, head);
 }
@@ -3088,8 +3091,10 @@ static void __net_exit vxlan_exit_net(struct net *net)
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
diff --git a/include/net/vxlan.h b/include/net/vxlan.h
index eb8d721..21f1ff5 100644
--- a/include/net/vxlan.h
+++ b/include/net/vxlan.h
@@ -161,6 +161,7 @@ struct vxlan_dev {
 	struct timer_list age_timer;
 	spinlock_t	  hash_lock;
 	unsigned int	  addrcnt;
+	struct gro_cells  gro_cells;
 
 	struct vxlan_config	cfg;
 
-- 
1.8.5.6
