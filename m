From: Tom Herbert <tom@herbertland.com>
Subject: [PATCH net-next v3 2/3] vxlan: GRO support at tunnel layer
Date: Wed, 19 Aug 2015 17:07:33 -0700
Message-ID: <1440029254-1551546-3-git-send-email-tom@herbertland.com>
References: <1440029254-1551546-1-git-send-email-tom@herbertland.com>
Mime-Version: 1.0
Content-Type: text/plain
Cc: <kernel-team@fb.com>
To: <davem@davemloft.net>, <netdev@vger.kernel.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mx0b-00082601.pphosted.com ([67.231.153.30]:43184 "EHLO
	mx0b-00082601.pphosted.com" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with ESMTP id S1751438AbbHTAH6 (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 19 Aug 2015 20:07:58 -0400
Received: from pps.filterd (m0004077 [127.0.0.1])
	by mx0b-00082601.pphosted.com (8.14.5/8.14.5) with SMTP id t7K02gef024845
	for <netdev@vger.kernel.org>; Wed, 19 Aug 2015 17:07:58 -0700
Received: from mail.thefacebook.com ([199.201.64.23])
	by mx0b-00082601.pphosted.com with ESMTP id 1wd2px8dpe-1
	(version=TLSv1/SSLv3 cipher=AES128-SHA bits=128 verify=NOT)
	for <netdev@vger.kernel.org>; Wed, 19 Aug 2015 17:07:58 -0700
Received: from facebook.com (2401:db00:20:702e:face:0:23:0)	by
 mx-out.facebook.com (10.223.101.97) with ESMTP	id
 816d1a2c46cf11e5ba9524be0595f910-747fc2b0 for <netdev@vger.kernel.org>;	Wed,
 19 Aug 2015 17:07:54 -0700
In-Reply-To: <1440029254-1551546-1-git-send-email-tom@herbertland.com>
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
index 15b6ced..0192b15 100644
--- a/drivers/net/vxlan.c
+++ b/drivers/net/vxlan.c
@@ -1208,7 +1208,7 @@ static void vxlan_rcv(struct vxlan_sock *vs, struct sk_buff *skb,
 	stats->rx_bytes += skb->len;
 	u64_stats_update_end(&stats->syncp);
 
-	netif_rx(skb);
+	gro_cells_receive(&vxlan->gro_cells, skb);
 
 	return;
 drop:
@@ -2435,6 +2435,8 @@ static void vxlan_setup(struct net_device *dev)
 
 	vxlan->dev = dev;
 
+	gro_cells_init(&vxlan->gro_cells, dev);
+
 	for (h = 0; h < FDB_HASH_SIZE; ++h)
 		INIT_HLIST_HEAD(&vxlan->fdb_head[h]);
 }
@@ -2874,6 +2876,7 @@ static void vxlan_dellink(struct net_device *dev, struct list_head *head)
 		hlist_del_rcu(&vxlan->hlist);
 	spin_unlock(&vn->sock_lock);
 
+	gro_cells_destroy(&vxlan->gro_cells);
 	list_del(&vxlan->next);
 	unregister_netdevice_queue(dev, head);
 }
@@ -3082,8 +3085,10 @@ static void __net_exit vxlan_exit_net(struct net *net)
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
index e4534f1..cc10159 100644
--- a/include/net/vxlan.h
+++ b/include/net/vxlan.h
@@ -161,6 +161,7 @@ struct vxlan_dev {
 	struct timer_list age_timer;
 	spinlock_t	  hash_lock;
 	unsigned int	  addrcnt;
+	struct gro_cells  gro_cells;
 
 	struct vxlan_config	cfg;
 
-- 
1.8.1
