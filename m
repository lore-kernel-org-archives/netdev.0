From: Tom Herbert <therbert@google.com>
Subject: [PATCH 2/2 v3] ipv4: Use percpu Cache route in IP tunnels
Date: Thu, 2 Jan 2014 11:48:33 -0800 (PST)
Message-ID: <alpine.DEB.2.02.1401021140470.32674@tomh.mtv.corp.google.com>
Mime-Version: 1.0
Content-Type: TEXT/PLAIN; charset=US-ASCII
To: davem@davemloft.net, netdev@vger.kernel.org, eric.dumazet@gmail.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-qc0-f202.google.com ([209.85.216.202]:60850 "EHLO
	mail-qc0-f202.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751915AbaABTsf (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 2 Jan 2014 14:48:35 -0500
Received: by mail-qc0-f202.google.com with SMTP id i17so944893qcy.1
        for <netdev@vger.kernel.org>; Thu, 02 Jan 2014 11:48:34 -0800 (PST)
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

percpu route cache eliminates share of dst refcnt between CPUs.

Signed-off-by: Tom Herbert <therbert@google.com>
---
 include/net/ip_tunnels.h |  8 ++++++--
 net/ipv4/ip_tunnel.c     | 44 ++++++++++++++++++++++++++++++++------------
 2 files changed, 38 insertions(+), 14 deletions(-)

diff --git a/include/net/ip_tunnels.h b/include/net/ip_tunnels.h
index bde50fc..9e25b1b 100644
--- a/include/net/ip_tunnels.h
+++ b/include/net/ip_tunnels.h
@@ -38,6 +38,11 @@ struct ip_tunnel_prl_entry {
 	struct rcu_head			rcu_head;
 };
 
+struct ip_tunnel_dst {
+	struct dst_entry __rcu 		*dst;
+	spinlock_t			lock;
+};
+
 struct ip_tunnel {
 	struct ip_tunnel __rcu	*next;
 	struct hlist_node hash_node;
@@ -54,8 +59,7 @@ struct ip_tunnel {
 	int		hlen;		/* Precalculated header length */
 	int		mlink;
 
-	struct		dst_entry __rcu *dst_cache;
-	spinlock_t	dst_lock;
+	struct ip_tunnel_dst __percpu *dst_cache;
 
 	struct ip_tunnel_parm parms;
 
diff --git a/net/ipv4/ip_tunnel.c b/net/ipv4/ip_tunnel.c
index 27d756f..b153486 100644
--- a/net/ipv4/ip_tunnel.c
+++ b/net/ipv4/ip_tunnel.c
@@ -68,23 +68,24 @@ static unsigned int ip_tunnel_hash(struct ip_tunnel_net *itn,
 			 IP_TNL_HASH_BITS);
 }
 
-static inline void __tunnel_dst_set(struct ip_tunnel *t, struct dst_entry *dst)
+static inline void __tunnel_dst_set(struct ip_tunnel_dst *idst,
+				    struct dst_entry *dst)
 {
 	struct dst_entry *old_dst;
 
 	if (dst && (dst->flags & DST_NOCACHE))
 		dst = NULL;
 
-	spin_lock_bh(&t->dst_lock);
-	old_dst = rcu_dereference_raw(t->dst_cache);
-	rcu_assign_pointer(t->dst_cache, dst);
+	spin_lock_bh(&idst->lock);
+	old_dst = rcu_dereference(idst->dst);
+	rcu_assign_pointer(idst->dst, dst);
 	dst_release(old_dst);
-	spin_unlock_bh(&t->dst_lock);
+	spin_unlock_bh(&idst->lock);
 }
 
 static inline void tunnel_dst_set(struct ip_tunnel *t, struct dst_entry *dst)
 {
-	__tunnel_dst_set(t, dst);
+	__tunnel_dst_set(this_cpu_ptr(t->dst_cache), dst);
 }
 
 static inline void tunnel_dst_reset(struct ip_tunnel *t)
@@ -92,12 +93,20 @@ static inline void tunnel_dst_reset(struct ip_tunnel *t)
 	tunnel_dst_set(t, NULL);
 }
 
+static void tunnel_dst_reset_all(struct ip_tunnel *t)
+{
+	int i;
+
+	for_each_possible_cpu(i)
+		__tunnel_dst_set(per_cpu_ptr(t->dst_cache, i), NULL);
+}
+
 static inline struct dst_entry *tunnel_dst_get(struct ip_tunnel *t)
 {
 	struct dst_entry *dst;
 
 	rcu_read_lock();
-	dst = rcu_dereference(t->dst_cache);
+	dst = rcu_dereference(this_cpu_ptr(t->dst_cache)->dst);
 	if (dst)
 		dst_hold(dst);
 	rcu_read_unlock();
@@ -755,7 +764,7 @@ static void ip_tunnel_update(struct ip_tunnel_net *itn,
 		if (set_mtu)
 			dev->mtu = mtu;
 	}
-	tunnel_dst_reset(t);
+	tunnel_dst_reset_all(t);
 	netdev_state_change(dev);
 }
 
@@ -871,6 +880,7 @@ static void ip_tunnel_dev_free(struct net_device *dev)
 	struct ip_tunnel *tunnel = netdev_priv(dev);
 
 	gro_cells_destroy(&tunnel->gro_cells);
+	free_percpu(tunnel->dst_cache);
 	free_percpu(dev->tstats);
 	free_netdev(dev);
 }
@@ -1049,8 +1059,21 @@ int ip_tunnel_init(struct net_device *dev)
 		u64_stats_init(&ipt_stats->syncp);
 	}
 
+	tunnel->dst_cache = alloc_percpu(struct ip_tunnel_dst *);
+	if (!tunnel->dst_cache) {
+		free_percpu(dev->tstats);
+		return -ENOMEM;
+	}
+
+	for_each_possible_cpu(i) {
+		struct ip_tunnel_dst *idst = per_cpu_ptr(tunnel->dst_cache, i);
+		idst-> dst = NULL;
+		spin_lock_init(&idst->lock);
+	}
+
 	err = gro_cells_init(&tunnel->gro_cells, dev);
 	if (err) {
+		free_percpu(tunnel->dst_cache);
 		free_percpu(dev->tstats);
 		return err;
 	}
@@ -1061,9 +1084,6 @@ int ip_tunnel_init(struct net_device *dev)
 	iph->version		= 4;
 	iph->ihl		= 5;
 
-	tunnel->dst_cache = NULL;
-	spin_lock_init(&tunnel->dst_lock);
-
 	return 0;
 }
 EXPORT_SYMBOL_GPL(ip_tunnel_init);
@@ -1079,7 +1099,7 @@ void ip_tunnel_uninit(struct net_device *dev)
 	if (itn->fb_tunnel_dev != dev)
 		ip_tunnel_del(netdev_priv(dev));
 
-	tunnel_dst_reset(tunnel);
+	tunnel_dst_reset_all(tunnel);
 }
 EXPORT_SYMBOL_GPL(ip_tunnel_uninit);
 
-- 
1.8.5.1
