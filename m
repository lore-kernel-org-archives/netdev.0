From: Eric Dumazet <eric.dumazet@gmail.com>
Subject: [PATCH net-next] net: remove support for per driver ndo_busy_poll()
Date: Thu, 02 Feb 2017 18:43:28 -0800
Message-ID: <1486089808.21871.59.camel@edumazet-glaptop3.roam.corp.google.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="UTF-8"
Content-Transfer-Encoding: 7bit
Cc: netdev <netdev@vger.kernel.org>
To: David Miller <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-pg0-f67.google.com ([74.125.83.67]:33476 "EHLO
        mail-pg0-f67.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1751653AbdBCCnb (ORCPT
        <rfc822;netdev@vger.kernel.org>); Thu, 2 Feb 2017 21:43:31 -0500
Received: by mail-pg0-f67.google.com with SMTP id 194so641307pgd.0
        for <netdev@vger.kernel.org>; Thu, 02 Feb 2017 18:43:30 -0800 (PST)
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Eric Dumazet <edumazet@google.com>

We added generic support for busy polling in NAPI layer in linux-4.5

No network driver uses ndo_busy_poll() anymore, we can get rid
of the pointer in struct net_device_ops, and its use in sk_busy_loop()

Saves NETIF_F_BUSY_POLL features bit.

Signed-off-by: Eric Dumazet <edumazet@google.com>
---

This patch makes sense only if all prior ones are merged.

Thanks !

 include/linux/netdev_features.h |    2 --
 include/linux/netdevice.h       |    3 ---
 net/core/dev.c                  |   15 ---------------
 net/core/ethtool.c              |    1 -
 4 files changed, 21 deletions(-)

diff --git a/include/linux/netdev_features.h b/include/linux/netdev_features.h
index 9c6c8ef2e9e704513cc4272b0a3ee2fec6809d46..9a0419594e842ca00a5ecfca53823b38bad207bb 100644
--- a/include/linux/netdev_features.h
+++ b/include/linux/netdev_features.h
@@ -71,7 +71,6 @@ enum {
 	NETIF_F_HW_VLAN_STAG_RX_BIT,	/* Receive VLAN STAG HW acceleration */
 	NETIF_F_HW_VLAN_STAG_FILTER_BIT,/* Receive filtering on VLAN STAGs */
 	NETIF_F_HW_L2FW_DOFFLOAD_BIT,	/* Allow L2 Forwarding in Hardware */
-	NETIF_F_BUSY_POLL_BIT,		/* Busy poll */
 
 	NETIF_F_HW_TC_BIT,		/* Offload TC infrastructure */
 
@@ -134,7 +133,6 @@ enum {
 #define NETIF_F_HW_VLAN_STAG_RX	__NETIF_F(HW_VLAN_STAG_RX)
 #define NETIF_F_HW_VLAN_STAG_TX	__NETIF_F(HW_VLAN_STAG_TX)
 #define NETIF_F_HW_L2FW_DOFFLOAD	__NETIF_F(HW_L2FW_DOFFLOAD)
-#define NETIF_F_BUSY_POLL	__NETIF_F(BUSY_POLL)
 #define NETIF_F_HW_TC		__NETIF_F(HW_TC)
 
 #define for_each_netdev_feature(mask_addr, bit)	\
diff --git a/include/linux/netdevice.h b/include/linux/netdevice.h
index f3878fbe7786854c2028055cf6d0a52a20762d6e..6f18b509fb2f473029561d85646713c149df49ac 100644
--- a/include/linux/netdevice.h
+++ b/include/linux/netdevice.h
@@ -1185,9 +1185,6 @@ struct net_device_ops {
 						     struct netpoll_info *info);
 	void			(*ndo_netpoll_cleanup)(struct net_device *dev);
 #endif
-#ifdef CONFIG_NET_RX_BUSY_POLL
-	int			(*ndo_busy_poll)(struct napi_struct *dev);
-#endif
 	int			(*ndo_set_vf_mac)(struct net_device *dev,
 						  int queue, u8 *mac);
 	int			(*ndo_set_vf_vlan)(struct net_device *dev,
diff --git a/net/core/dev.c b/net/core/dev.c
index 727b6fda0e8c6497ee42dc6d3065e326e9192c21..4cde8bfb9bab449b83890192a7e28a423b319e23 100644
--- a/net/core/dev.c
+++ b/net/core/dev.c
@@ -4978,7 +4978,6 @@ bool sk_busy_loop(struct sock *sk, int nonblock)
 {
 	unsigned long end_time = !nonblock ? sk_busy_loop_end_time(sk) : 0;
 	int (*napi_poll)(struct napi_struct *napi, int budget);
-	int (*busy_poll)(struct napi_struct *dev);
 	void *have_poll_lock = NULL;
 	struct napi_struct *napi;
 	int rc;
@@ -4993,17 +4992,10 @@ bool sk_busy_loop(struct sock *sk, int nonblock)
 	if (!napi)
 		goto out;
 
-	/* Note: ndo_busy_poll method is optional in linux-4.5 */
-	busy_poll = napi->dev->netdev_ops->ndo_busy_poll;
-
 	preempt_disable();
 	for (;;) {
 		rc = 0;
 		local_bh_disable();
-		if (busy_poll) {
-			rc = busy_poll(napi);
-			goto count;
-		}
 		if (!napi_poll) {
 			unsigned long val = READ_ONCE(napi->state);
 
@@ -6956,13 +6948,6 @@ static netdev_features_t netdev_fix_features(struct net_device *dev,
 		features &= ~dev->gso_partial_features;
 	}
 
-#ifdef CONFIG_NET_RX_BUSY_POLL
-	if (dev->netdev_ops->ndo_busy_poll)
-		features |= NETIF_F_BUSY_POLL;
-	else
-#endif
-		features &= ~NETIF_F_BUSY_POLL;
-
 	return features;
 }
 
diff --git a/net/core/ethtool.c b/net/core/ethtool.c
index 6b3eee0834a0663d3c48ae42a34e3bdd032fa5f9..d5f412b3093d4b3ccef40d4808bedf353f483594 100644
--- a/net/core/ethtool.c
+++ b/net/core/ethtool.c
@@ -102,7 +102,6 @@ static const char netdev_features_strings[NETDEV_FEATURE_COUNT][ETH_GSTRING_LEN]
 	[NETIF_F_RXFCS_BIT] =            "rx-fcs",
 	[NETIF_F_RXALL_BIT] =            "rx-all",
 	[NETIF_F_HW_L2FW_DOFFLOAD_BIT] = "l2-fwd-offload",
-	[NETIF_F_BUSY_POLL_BIT] =        "busy-poll",
 	[NETIF_F_HW_TC_BIT] =		 "hw-tc-offload",
 };
 
