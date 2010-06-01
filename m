From: Eric Dumazet <eric.dumazet@gmail.com>
Subject: [PATCH net-next-2.6] net: CONFIG_NET_NS reduction
Date: Tue, 01 Jun 2010 18:51:19 +0200
Message-ID: <1275411079.2738.231.camel@edumazet-laptop>
Mime-Version: 1.0
Content-Type: text/plain; charset="UTF-8"
Content-Transfer-Encoding: 7bit
Cc: netdev <netdev@vger.kernel.org>, Patrick McHardy <kaber@trash.net>
To: David Miller <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-wy0-f174.google.com ([74.125.82.174]:52008 "EHLO
	mail-wy0-f174.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1754182Ab0FAQv0 (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 1 Jun 2010 12:51:26 -0400
Received: by wyi11 with SMTP id 11so1154126wyi.19
        for <netdev@vger.kernel.org>; Tue, 01 Jun 2010 09:51:24 -0700 (PDT)
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Use read_pnet() and write_pnet() to reduce number of ifdef CONFIG_NET_NS

Signed-off-by: Eric Dumazet <eric.dumazet@gmail.com>
---
 include/linux/netdevice.h            |    6 +-----
 include/net/cfg80211.h               |   15 ++-------------
 include/net/genetlink.h              |   15 ++-------------
 include/net/netfilter/nf_conntrack.h |    6 +-----
 include/net/sock.h                   |   10 ++--------
 net/ipv6/addrlabel.c                 |    6 +-----
 net/netfilter/nf_conntrack_core.c    |    8 ++------
 7 files changed, 11 insertions(+), 55 deletions(-)

diff --git a/include/linux/netdevice.h b/include/linux/netdevice.h
index a249161..bd6b753 100644
--- a/include/linux/netdevice.h
+++ b/include/linux/netdevice.h
@@ -1087,11 +1087,7 @@ static inline void netdev_for_each_tx_queue(struct net_device *dev,
 static inline
 struct net *dev_net(const struct net_device *dev)
 {
-#ifdef CONFIG_NET_NS
-	return dev->nd_net;
-#else
-	return &init_net;
-#endif
+	return read_pnet(&dev->nd_net);
 }
 
 static inline
diff --git a/include/net/cfg80211.h b/include/net/cfg80211.h
index b44a2e5..e7ebeb8 100644
--- a/include/net/cfg80211.h
+++ b/include/net/cfg80211.h
@@ -1330,26 +1330,15 @@ struct wiphy {
 	char priv[0] __attribute__((__aligned__(NETDEV_ALIGN)));
 };
 
-#ifdef CONFIG_NET_NS
-static inline struct net *wiphy_net(struct wiphy *wiphy)
-{
-	return wiphy->_net;
-}
-
-static inline void wiphy_net_set(struct wiphy *wiphy, struct net *net)
-{
-	wiphy->_net = net;
-}
-#else
 static inline struct net *wiphy_net(struct wiphy *wiphy)
 {
-	return &init_net;
+	return read_pnet(&wiphy->_net);
 }
 
 static inline void wiphy_net_set(struct wiphy *wiphy, struct net *net)
 {
+	write_pnet(&wiphy->_net, net);
 }
-#endif
 
 /**
  * wiphy_priv - return priv from wiphy
diff --git a/include/net/genetlink.h b/include/net/genetlink.h
index eb551ba..f7dcd2c 100644
--- a/include/net/genetlink.h
+++ b/include/net/genetlink.h
@@ -68,26 +68,15 @@ struct genl_info {
 #endif
 };
 
-#ifdef CONFIG_NET_NS
 static inline struct net *genl_info_net(struct genl_info *info)
 {
-	return info->_net;
+	return read_pnet(&info->_net);
 }
 
 static inline void genl_info_net_set(struct genl_info *info, struct net *net)
 {
-	info->_net = net;
+	write_pnet(&info->_net, net);
 }
-#else
-static inline struct net *genl_info_net(struct genl_info *info)
-{
-	return &init_net;
-}
-
-static inline void genl_info_net_set(struct genl_info *info, struct net *net)
-{
-}
-#endif
 
 /**
  * struct genl_ops - generic netlink operations
diff --git a/include/net/netfilter/nf_conntrack.h b/include/net/netfilter/nf_conntrack.h
index bde095f..bbfdd94 100644
--- a/include/net/netfilter/nf_conntrack.h
+++ b/include/net/netfilter/nf_conntrack.h
@@ -152,11 +152,7 @@ extern struct net init_net;
 
 static inline struct net *nf_ct_net(const struct nf_conn *ct)
 {
-#ifdef CONFIG_NET_NS
-	return ct->ct_net;
-#else
-	return &init_net;
-#endif
+	return read_pnet(&ct->ct_net);
 }
 
 /* Alter reply tuple (maybe alter helper). */
diff --git a/include/net/sock.h b/include/net/sock.h
index ca241ea..3461e5d 100644
--- a/include/net/sock.h
+++ b/include/net/sock.h
@@ -1724,19 +1724,13 @@ static inline void sk_eat_skb(struct sock *sk, struct sk_buff *skb, int copied_e
 static inline
 struct net *sock_net(const struct sock *sk)
 {
-#ifdef CONFIG_NET_NS
-	return sk->sk_net;
-#else
-	return &init_net;
-#endif
+	return read_pnet(&sk->sk_net);
 }
 
 static inline
 void sock_net_set(struct sock *sk, struct net *net)
 {
-#ifdef CONFIG_NET_NS
-	sk->sk_net = net;
-#endif
+	write_pnet(&sk->sk_net, net);
 }
 
 /*
diff --git a/net/ipv6/addrlabel.c b/net/ipv6/addrlabel.c
index 8c4348c..f0e774c 100644
--- a/net/ipv6/addrlabel.c
+++ b/net/ipv6/addrlabel.c
@@ -53,11 +53,7 @@ static struct ip6addrlbl_table
 static inline
 struct net *ip6addrlbl_net(const struct ip6addrlbl_entry *lbl)
 {
-#ifdef CONFIG_NET_NS
-	return lbl->lbl_net;
-#else
-	return &init_net;
-#endif
+	return read_pnet(&lbl->lbl_net);
 }
 
 /*
diff --git a/net/netfilter/nf_conntrack_core.c b/net/netfilter/nf_conntrack_core.c
index eeeb8bc..7728898 100644
--- a/net/netfilter/nf_conntrack_core.c
+++ b/net/netfilter/nf_conntrack_core.c
@@ -619,9 +619,7 @@ struct nf_conn *nf_conntrack_alloc(struct net *net, u16 zone,
 	ct->tuplehash[IP_CT_DIR_REPLY].hnnode.pprev = NULL;
 	/* Don't set timer yet: wait for confirmation */
 	setup_timer(&ct->timeout, death_by_timeout, (unsigned long)ct);
-#ifdef CONFIG_NET_NS
-	ct->ct_net = net;
-#endif
+	write_pnet(&ct->ct_net, net);
 #ifdef CONFIG_NF_CONNTRACK_ZONES
 	if (zone) {
 		struct nf_conntrack_zone *nf_ct_zone;
@@ -1363,9 +1361,7 @@ static int nf_conntrack_init_init_net(void)
 		goto err_extend;
 #endif
 	/* Set up fake conntrack: to never be deleted, not in any hashes */
-#ifdef CONFIG_NET_NS
-	nf_conntrack_untracked.ct_net = &init_net;
-#endif
+	write_pnet(&nf_conntrack_untracked.ct_net, &init_net);
 	atomic_set(&nf_conntrack_untracked.ct_general.use, 1);
 	/*  - and look it like as a confirmed connection */
 	set_bit(IPS_CONFIRMED_BIT, &nf_conntrack_untracked.status);


