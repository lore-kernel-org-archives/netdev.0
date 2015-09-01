From: Martin KaFai Lau <kafai@fb.com>
Subject: [PATCH net 3/3] ipv6: Fix dst_entry refcnt bugs in ip6_tunnel
Date: Tue, 1 Sep 2015 11:55:03 -0700
Message-ID: <1441133703-1570969-4-git-send-email-kafai@fb.com>
References: <1441133703-1570969-1-git-send-email-kafai@fb.com>
Mime-Version: 1.0
Content-Type: text/plain
Cc: Kernel Team <kernel-team@fb.com>
To: netdev <netdev@vger.kernel.org>,
	"David S. Miller" <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mx0a-00082601.pphosted.com ([67.231.145.42]:4823 "EHLO
	mx0a-00082601.pphosted.com" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with ESMTP id S1751860AbbIASzP (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 1 Sep 2015 14:55:15 -0400
Received: from pps.filterd (m0004346 [127.0.0.1])
	by mx0a-00082601.pphosted.com (8.14.5/8.14.5) with SMTP id t81IrkpM011790
	for <netdev@vger.kernel.org>; Tue, 1 Sep 2015 11:55:15 -0700
Received: from mail.thefacebook.com ([199.201.64.23])
	by mx0a-00082601.pphosted.com with ESMTP id 1wngjrr64c-3
	(version=TLSv1/SSLv3 cipher=AES128-SHA bits=128 verify=NOT)
	for <netdev@vger.kernel.org>; Tue, 01 Sep 2015 11:55:15 -0700
Received: from facebook.com (2401:db00:20:7029:face:0:33:0)	by
 mx-out.facebook.com (10.212.236.89) with ESMTP	id
 f4f6c60e50da11e59af50002c95209d8-f3bfa240 for <netdev@vger.kernel.org>;	Tue,
 01 Sep 2015 11:55:04 -0700
In-Reply-To: <1441133703-1570969-1-git-send-email-kafai@fb.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Problems in the current dst_entry cache in the ip6_tunnel:

1. ip6_tnl_dst_set is racy.  There is no lock to protect it:
   - One major problem is that the dst refcnt gets messed up. F.e.
     the same dst_cache can be released multiple times and then
     triggering the infamous dst refcnt < 0 warning message.
   - Another issue is the inconsistency between dst_cache and
     dst_cookie.

   It can be reproduced by adding and removing the ip6gre tunnel
   while running a super_netperf TCP_CRR test.

2. In ip6_tnl_xmit2() and ip6gre_xmit2(), the outgoing skb does
   not hold a dst_entry's refcnt.

This patch:
1. Create a percpu dst_entry cache in ip6_tnl
2. Use a spinlock to protect the dst_cache operations
3. The outgoing skb always holds the dst_entry's refcnt

Signed-off-by: Martin KaFai Lau <kafai@fb.com>
---
 include/net/ip6_tunnel.h |  11 ++++-
 net/ipv6/ip6_gre.c       |  38 ++++++++-------
 net/ipv6/ip6_tunnel.c    | 122 +++++++++++++++++++++++++++++++++++------------
 3 files changed, 123 insertions(+), 48 deletions(-)

diff --git a/include/net/ip6_tunnel.h b/include/net/ip6_tunnel.h
index 979b081..60b4f40 100644
--- a/include/net/ip6_tunnel.h
+++ b/include/net/ip6_tunnel.h
@@ -32,6 +32,12 @@ struct __ip6_tnl_parm {
 	__be32			o_key;
 };
 
+struct ip6_tnl_dst {
+	spinlock_t lock;
+	struct dst_entry *dst;
+	u32 cookie;
+};
+
 /* IPv6 tunnel */
 struct ip6_tnl {
 	struct ip6_tnl __rcu *next;	/* next tunnel in list */
@@ -39,8 +45,7 @@ struct ip6_tnl {
 	struct net *net;	/* netns for packet i/o */
 	struct __ip6_tnl_parm parms;	/* tunnel configuration parameters */
 	struct flowi fl;	/* flowi template for xmit */
-	struct dst_entry *dst_cache;    /* cached dst */
-	u32 dst_cookie;
+	struct ip6_tnl_dst __percpu *dst_cache;	/* cached dst */
 
 	int err_count;
 	unsigned long err_time;
@@ -61,6 +66,8 @@ struct ipv6_tlv_tnl_enc_lim {
 } __packed;
 
 struct dst_entry *ip6_tnl_dst_get(struct ip6_tnl *t);
+int ip6_tnl_dst_init(struct ip6_tnl *t);
+void ip6_tnl_dst_destroy(struct ip6_tnl *t);
 void ip6_tnl_dst_reset(struct ip6_tnl *t);
 void ip6_tnl_dst_set(struct ip6_tnl *t, struct dst_entry *dst);
 int ip6_tnl_rcv_ctl(struct ip6_tnl *t, const struct in6_addr *laddr,
diff --git a/net/ipv6/ip6_gre.c b/net/ipv6/ip6_gre.c
index 2f2cff0..76fb4ac 100644
--- a/net/ipv6/ip6_gre.c
+++ b/net/ipv6/ip6_gre.c
@@ -637,17 +637,17 @@ static netdev_tx_t ip6gre_xmit2(struct sk_buff *skb,
 		dst = ip6_tnl_dst_get(tunnel);
 
 	if (!dst) {
-		ndst = ip6_route_output(net, NULL, fl6);
+		dst = ip6_route_output(net, NULL, fl6);
 
-		if (ndst->error)
+		if (dst->error)
 			goto tx_err_link_failure;
-		ndst = xfrm_lookup(net, ndst, flowi6_to_flowi(fl6), NULL, 0);
-		if (IS_ERR(ndst)) {
-			err = PTR_ERR(ndst);
-			ndst = NULL;
+		dst = xfrm_lookup(net, dst, flowi6_to_flowi(fl6), NULL, 0);
+		if (IS_ERR(dst)) {
+			err = PTR_ERR(dst);
+			dst = NULL;
 			goto tx_err_link_failure;
 		}
-		dst = ndst;
+		ndst = dst;
 	}
 
 	tdev = dst->dev;
@@ -702,12 +702,9 @@ static netdev_tx_t ip6gre_xmit2(struct sk_buff *skb,
 		skb = new_skb;
 	}
 
-	if (fl6->flowi6_mark) {
-		skb_dst_set(skb, dst);
-		ndst = NULL;
-	} else {
-		skb_dst_set_noref(skb, dst);
-	}
+	if (!fl6->flowi6_mark && ndst)
+		ip6_tnl_dst_set(tunnel, ndst);
+	skb_dst_set(skb, dst);
 
 	proto = NEXTHDR_GRE;
 	if (encap_limit >= 0) {
@@ -762,14 +759,12 @@ static netdev_tx_t ip6gre_xmit2(struct sk_buff *skb,
 	skb_set_inner_protocol(skb, protocol);
 
 	ip6tunnel_xmit(NULL, skb, dev);
-	if (ndst)
-		ip6_tnl_dst_set(tunnel, ndst);
 	return 0;
 tx_err_link_failure:
 	stats->tx_carrier_errors++;
 	dst_link_failure(skb);
 tx_err_dst_release:
-	dst_release(ndst);
+	dst_release(dst);
 	return err;
 }
 
@@ -1222,6 +1217,9 @@ static const struct net_device_ops ip6gre_netdev_ops = {
 
 static void ip6gre_dev_free(struct net_device *dev)
 {
+	struct ip6_tnl *t = netdev_priv(dev);
+
+	ip6_tnl_dst_destroy(t);
 	free_percpu(dev->tstats);
 	free_netdev(dev);
 }
@@ -1247,6 +1245,7 @@ static void ip6gre_tunnel_setup(struct net_device *dev)
 static int ip6gre_tunnel_init_common(struct net_device *dev)
 {
 	struct ip6_tnl *tunnel;
+	int ret;
 
 	tunnel = netdev_priv(dev);
 
@@ -1258,6 +1257,13 @@ static int ip6gre_tunnel_init_common(struct net_device *dev)
 	if (!dev->tstats)
 		return -ENOMEM;
 
+	ret = ip6_tnl_dst_init(tunnel);
+	if (ret) {
+		free_percpu(dev->tstats);
+		dev->tstats = NULL;
+		return ret;
+	}
+
 	return 0;
 }
 
diff --git a/net/ipv6/ip6_tunnel.c b/net/ipv6/ip6_tunnel.c
index d2dc9e7..97b3e781 100644
--- a/net/ipv6/ip6_tunnel.c
+++ b/net/ipv6/ip6_tunnel.c
@@ -126,37 +126,90 @@ static struct net_device_stats *ip6_get_stats(struct net_device *dev)
  * Locking : hash tables are protected by RCU and RTNL
  */
 
-struct dst_entry *ip6_tnl_dst_get(struct ip6_tnl *t)
+static void __ip6_tnl_per_cpu_dst_set(struct ip6_tnl_dst *idst,
+				      struct dst_entry *dst)
 {
-	struct dst_entry *dst = t->dst_cache;
-
-	if (dst && dst->obsolete &&
-	    !dst->ops->check(dst, t->dst_cookie)) {
-		t->dst_cache = NULL;
-		dst_release(dst);
-		return NULL;
+	dst_release(idst->dst);
+	idst->dst = dst;
+	if (dst) {
+		dst_hold(dst);
+		idst->cookie = rt6_get_cookie((struct rt6_info *)dst);
+	} else {
+		idst->cookie = 0;
 	}
+}
+
+static void ip6_tnl_per_cpu_dst_set(struct ip6_tnl_dst *idst,
+				    struct dst_entry *dst)
+{
 
+	spin_lock_bh(&idst->lock);
+	__ip6_tnl_per_cpu_dst_set(idst, dst);
+	spin_unlock_bh(&idst->lock);
+}
+
+struct dst_entry *ip6_tnl_dst_get(struct ip6_tnl *t)
+{
+	struct dst_entry *dst;
+	struct ip6_tnl_dst *idst;
+
+	idst = raw_cpu_ptr(t->dst_cache);
+	spin_lock_bh(&idst->lock);
+	dst = idst->dst;
+	if (dst) {
+		if (!dst->obsolete || dst->ops->check(dst, idst->cookie)) {
+			dst_hold(idst->dst);
+		} else {
+			__ip6_tnl_per_cpu_dst_set(idst, NULL);
+			dst = NULL;
+		}
+	}
+	spin_unlock_bh(&idst->lock);
 	return dst;
 }
 EXPORT_SYMBOL_GPL(ip6_tnl_dst_get);
 
 void ip6_tnl_dst_reset(struct ip6_tnl *t)
 {
-	dst_release(t->dst_cache);
-	t->dst_cache = NULL;
+	int i;
+
+	for_each_possible_cpu(i)
+		ip6_tnl_per_cpu_dst_set(raw_cpu_ptr(t->dst_cache), NULL);
 }
 EXPORT_SYMBOL_GPL(ip6_tnl_dst_reset);
 
 void ip6_tnl_dst_set(struct ip6_tnl *t, struct dst_entry *dst)
 {
-	struct rt6_info *rt = (struct rt6_info *) dst;
-	t->dst_cookie = rt6_get_cookie(rt);
-	dst_release(t->dst_cache);
-	t->dst_cache = dst;
+	ip6_tnl_per_cpu_dst_set(raw_cpu_ptr(t->dst_cache), dst);
+
 }
 EXPORT_SYMBOL_GPL(ip6_tnl_dst_set);
 
+void ip6_tnl_dst_destroy(struct ip6_tnl *t)
+{
+	if (!t->dst_cache)
+		return;
+
+	ip6_tnl_dst_reset(t);
+	free_percpu(t->dst_cache);
+}
+EXPORT_SYMBOL_GPL(ip6_tnl_dst_destroy);
+
+int ip6_tnl_dst_init(struct ip6_tnl *t)
+{
+	int i;
+
+	t->dst_cache = alloc_percpu(struct ip6_tnl_dst);
+	if (!t->dst_cache)
+		return -ENOMEM;
+
+	for_each_possible_cpu(i)
+		spin_lock_init(&per_cpu_ptr(t->dst_cache, i)->lock);
+
+	return 0;
+}
+EXPORT_SYMBOL_GPL(ip6_tnl_dst_init);
+
 /**
  * ip6_tnl_lookup - fetch tunnel matching the end-point addresses
  *   @remote: the address of the tunnel exit-point
@@ -271,6 +324,9 @@ ip6_tnl_unlink(struct ip6_tnl_net *ip6n, struct ip6_tnl *t)
 
 static void ip6_dev_free(struct net_device *dev)
 {
+	struct ip6_tnl *t = netdev_priv(dev);
+
+	ip6_tnl_dst_destroy(t);
 	free_percpu(dev->tstats);
 	free_netdev(dev);
 }
@@ -1016,17 +1072,17 @@ static int ip6_tnl_xmit2(struct sk_buff *skb,
 		goto tx_err_link_failure;
 
 	if (!dst) {
-		ndst = ip6_route_output(net, NULL, fl6);
+		dst = ip6_route_output(net, NULL, fl6);
 
-		if (ndst->error)
+		if (dst->error)
 			goto tx_err_link_failure;
-		ndst = xfrm_lookup(net, ndst, flowi6_to_flowi(fl6), NULL, 0);
-		if (IS_ERR(ndst)) {
-			err = PTR_ERR(ndst);
-			ndst = NULL;
+		dst = xfrm_lookup(net, dst, flowi6_to_flowi(fl6), NULL, 0);
+		if (IS_ERR(dst)) {
+			err = PTR_ERR(dst);
+			dst = NULL;
 			goto tx_err_link_failure;
 		}
-		dst = ndst;
+		ndst = dst;
 	}
 
 	tdev = dst->dev;
@@ -1072,12 +1128,11 @@ static int ip6_tnl_xmit2(struct sk_buff *skb,
 		consume_skb(skb);
 		skb = new_skb;
 	}
-	if (fl6->flowi6_mark) {
-		skb_dst_set(skb, dst);
-		ndst = NULL;
-	} else {
-		skb_dst_set_noref(skb, dst);
-	}
+
+	if (!fl6->flowi6_mark && ndst)
+		ip6_tnl_dst_set(t, ndst);
+	skb_dst_set(skb, dst);
+
 	skb->transport_header = skb->network_header;
 
 	proto = fl6->flowi6_proto;
@@ -1101,14 +1156,12 @@ static int ip6_tnl_xmit2(struct sk_buff *skb,
 	ipv6h->saddr = fl6->saddr;
 	ipv6h->daddr = fl6->daddr;
 	ip6tunnel_xmit(NULL, skb, dev);
-	if (ndst)
-		ip6_tnl_dst_set(t, ndst);
 	return 0;
 tx_err_link_failure:
 	stats->tx_carrier_errors++;
 	dst_link_failure(skb);
 tx_err_dst_release:
-	dst_release(ndst);
+	dst_release(dst);
 	return err;
 }
 
@@ -1573,12 +1626,21 @@ static inline int
 ip6_tnl_dev_init_gen(struct net_device *dev)
 {
 	struct ip6_tnl *t = netdev_priv(dev);
+	int ret;
 
 	t->dev = dev;
 	t->net = dev_net(dev);
 	dev->tstats = netdev_alloc_pcpu_stats(struct pcpu_sw_netstats);
 	if (!dev->tstats)
 		return -ENOMEM;
+
+	ret = ip6_tnl_dst_init(t);
+	if (ret) {
+		free_percpu(dev->tstats);
+		dev->tstats = NULL;
+		return ret;
+	}
+
 	return 0;
 }
 
-- 
1.8.1
