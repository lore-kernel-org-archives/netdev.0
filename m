From: Eric Dumazet <eric.dumazet@gmail.com>
Subject: [PATCH net-next] net: introduce netdevice gso_min_segs attribute
Date: Sun, 05 Oct 2014 10:11:27 -0700
Message-ID: <1412529087.11091.14.camel@edumazet-glaptop2.roam.corp.google.com>
References: <1412501722-25092-1-git-send-email-amirv@mellanox.com>
	 <54312F50.2060608@mellanox.com>
	 <1412524252.11091.3.camel@edumazet-glaptop2.roam.corp.google.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="UTF-8"
Content-Transfer-Encoding: 7bit
Cc: Eric Dumazet <edumazet@google.com>, netdev@vger.kernel.org,
	Yevgeny Petrilin <yevgenyp@mellanox.com>,
	Or Gerlitz <ogerlitz@mellanox.com>,
	Ido Shamay <idos@mellanox.com>
To: Amir Vadai <amirv@mellanox.com>,
	"David S. Miller" <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-pa0-f42.google.com ([209.85.220.42]:63663 "EHLO
	mail-pa0-f42.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751625AbaJERLa (ORCPT
	<rfc822;netdev@vger.kernel.org>); Sun, 5 Oct 2014 13:11:30 -0400
Received: by mail-pa0-f42.google.com with SMTP id bj1so4057205pad.1
        for <netdev@vger.kernel.org>; Sun, 05 Oct 2014 10:11:29 -0700 (PDT)
In-Reply-To: <1412524252.11091.3.camel@edumazet-glaptop2.roam.corp.google.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Eric Dumazet <edumazet@google.com>

Some TSO engines might have a too heavy setup cost, that impacts
performance on hosts sending small bursts (2 MSS per packet).

This patch adds a device gso_min_segs, allowing drivers to set
a minimum segment size for TSO packets, according to the NIC
performance.

Tested on a mlx4 NIC, this allows to get a ~110% increase of
throughput when sending 2 MSS per packet.

Signed-off-by: Eric Dumazet <edumazet@google.com>
---
mlx4 patch will be sent later, its a one liner.

 include/linux/netdevice.h |    4 +++-
 net/core/dev.c            |    9 ++++++---
 2 files changed, 9 insertions(+), 4 deletions(-)

diff --git a/include/linux/netdevice.h b/include/linux/netdevice.h
index 22d54b9b700d..2df86f50261c 100644
--- a/include/linux/netdevice.h
+++ b/include/linux/netdevice.h
@@ -1416,6 +1416,8 @@ enum netdev_priv_flags {
  *	@gso_max_size:	Maximum size of generic segmentation offload
  *	@gso_max_segs:	Maximum number of segments that can be passed to the
  *			NIC for GSO
+ *	@gso_min_segs:	Minimum number of segments that can be passed to the
+ *			NIC for GSO
  *
  *	@dcbnl_ops:	Data Center Bridging netlink ops
  *	@num_tc:	Number of traffic classes in the net device
@@ -1666,7 +1668,7 @@ struct net_device {
 	unsigned int		gso_max_size;
 #define GSO_MAX_SEGS		65535
 	u16			gso_max_segs;
-
+	u16			gso_min_segs;
 #ifdef CONFIG_DCB
 	const struct dcbnl_rtnl_ops *dcbnl_ops;
 #endif
diff --git a/net/core/dev.c b/net/core/dev.c
index 1a90530f83ff..16e8ebbd3316 100644
--- a/net/core/dev.c
+++ b/net/core/dev.c
@@ -2567,10 +2567,12 @@ static netdev_features_t harmonize_features(struct sk_buff *skb,
 
 netdev_features_t netif_skb_features(struct sk_buff *skb)
 {
+	const struct net_device *dev = skb->dev;
+	netdev_features_t features = dev->features;
+	u16 gso_segs = skb_shinfo(skb)->gso_segs;
 	__be16 protocol = skb->protocol;
-	netdev_features_t features = skb->dev->features;
 
-	if (skb_shinfo(skb)->gso_segs > skb->dev->gso_max_segs)
+	if (gso_segs > dev->gso_max_segs || gso_segs < dev->gso_min_segs)
 		features &= ~NETIF_F_GSO_MASK;
 
 	if (protocol == htons(ETH_P_8021Q) || protocol == htons(ETH_P_8021AD)) {
@@ -2581,7 +2583,7 @@ netdev_features_t netif_skb_features(struct sk_buff *skb)
 	}
 
 	features = netdev_intersect_features(features,
-					     skb->dev->vlan_features |
+					     dev->vlan_features |
 					     NETIF_F_HW_VLAN_CTAG_TX |
 					     NETIF_F_HW_VLAN_STAG_TX);
 
@@ -6658,6 +6660,7 @@ struct net_device *alloc_netdev_mqs(int sizeof_priv, const char *name,
 
 	dev->gso_max_size = GSO_MAX_SIZE;
 	dev->gso_max_segs = GSO_MAX_SEGS;
+	dev->gso_min_segs = 0;
 
 	INIT_LIST_HEAD(&dev->napi_list);
 	INIT_LIST_HEAD(&dev->unreg_list);
