From: Eric Dumazet <eric.dumazet@gmail.com>
Subject: [PATCH net-next] net: remove netdevice gso_min_segs
Date: Sat, 09 Apr 2016 11:29:58 -0700
Message-ID: <1460226598.6473.518.camel@edumazet-glaptop3.roam.corp.google.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="UTF-8"
Content-Transfer-Encoding: 7bit
Cc: netdev <netdev@vger.kernel.org>
To: David Miller <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-qk0-f173.google.com ([209.85.220.173]:33482 "EHLO
	mail-qk0-f173.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1753969AbcDISaC (ORCPT
	<rfc822;netdev@vger.kernel.org>); Sat, 9 Apr 2016 14:30:02 -0400
Received: by mail-qk0-f173.google.com with SMTP id k135so52383564qke.0
        for <netdev@vger.kernel.org>; Sat, 09 Apr 2016 11:30:01 -0700 (PDT)
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Eric Dumazet <edumazet@google.com>

After introduction of ndo_features_check(), we believe that very
specific checks for rare features should not be done in core
networking stack.

No driver uses gso_min_segs yet, so we revert this feature and save
few instructions per tx packet in fast path.

Signed-off-by: Eric Dumazet <edumazet@google.com>
---
 include/linux/netdevice.h |    4 +---
 net/core/dev.c            |    3 +--
 2 files changed, 2 insertions(+), 5 deletions(-)

diff --git a/include/linux/netdevice.h b/include/linux/netdevice.h
index cb4e508b3f38..dd3391aafa7d 100644
--- a/include/linux/netdevice.h
+++ b/include/linux/netdevice.h
@@ -1586,8 +1586,6 @@ enum netdev_priv_flags {
  *	@gso_max_size:	Maximum size of generic segmentation offload
  *	@gso_max_segs:	Maximum number of segments that can be passed to the
  *			NIC for GSO
- *	@gso_min_segs:	Minimum number of segments that can be passed to the
- *			NIC for GSO
  *
  *	@dcbnl_ops:	Data Center Bridging netlink ops
  *	@num_tc:	Number of traffic classes in the net device
@@ -1858,7 +1856,7 @@ struct net_device {
 	unsigned int		gso_max_size;
 #define GSO_MAX_SEGS		65535
 	u16			gso_max_segs;
-	u16			gso_min_segs;
+
 #ifdef CONFIG_DCB
 	const struct dcbnl_rtnl_ops *dcbnl_ops;
 #endif
diff --git a/net/core/dev.c b/net/core/dev.c
index 273f10d1e306..b75dfdb37422 100644
--- a/net/core/dev.c
+++ b/net/core/dev.c
@@ -2831,7 +2831,7 @@ netdev_features_t netif_skb_features(struct sk_buff *skb)
 	netdev_features_t features = dev->features;
 	u16 gso_segs = skb_shinfo(skb)->gso_segs;
 
-	if (gso_segs > dev->gso_max_segs || gso_segs < dev->gso_min_segs)
+	if (gso_segs > dev->gso_max_segs)
 		features &= ~NETIF_F_GSO_MASK;
 
 	/* If encapsulation offload request, verify we are testing
@@ -7428,7 +7428,6 @@ struct net_device *alloc_netdev_mqs(int sizeof_priv, const char *name,
 
 	dev->gso_max_size = GSO_MAX_SIZE;
 	dev->gso_max_segs = GSO_MAX_SEGS;
-	dev->gso_min_segs = 0;
 
 	INIT_LIST_HEAD(&dev->napi_list);
 	INIT_LIST_HEAD(&dev->unreg_list);
