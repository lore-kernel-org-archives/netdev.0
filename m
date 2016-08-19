From: David Ahern <dsa@cumulusnetworks.com>
Subject: [PATCH net-next 1/3] net: lwtunnel: Handle fragmentation
Date: Fri, 19 Aug 2016 10:09:00 -0700
Message-ID: <1471626542-13335-2-git-send-email-dsa@cumulusnetworks.com>
References: <1471626542-13335-1-git-send-email-dsa@cumulusnetworks.com>
Cc: buytenh@wantstofly.org, simon.horman@netronome.com,
        ebiederm@xmission.com, rshearma@brocade.com, tom@herbertland.com,
        tgraf@suug.ch, olivier.dugeon@orange.com,
        alexander.duyck@gmail.com, roopa@cumulusnetworks.com,
        David Ahern <dsa@cumulusnetworks.com>
To: netdev@vger.kernel.org, davem@davemloft.net
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-pf0-f172.google.com ([209.85.192.172]:32867 "EHLO
        mail-pf0-f172.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1755315AbcHSRQH (ORCPT
        <rfc822;netdev@vger.kernel.org>); Fri, 19 Aug 2016 13:16:07 -0400
Received: by mail-pf0-f172.google.com with SMTP id y134so11263194pfg.0
        for <netdev@vger.kernel.org>; Fri, 19 Aug 2016 10:16:06 -0700 (PDT)
In-Reply-To: <1471626542-13335-1-git-send-email-dsa@cumulusnetworks.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Roopa Prabhu <roopa@cumulusnetworks.com>

Today mpls iptunnel lwtunnel_output redirect expects the tunnel
output function to handle fragmentation. This is ok but can be
avoided if we did not do the mpls output redirect too early.
ie we could wait until ip fragmentation is done and then call
mpls output for each ip fragment.

To make this work we will need,
1) the lwtunnel state to carry encap headroom
2) and do the redirect to the encap output handler on the ip fragment
(essentially do the output redirect after fragmentation)

This patch adds tunnel headroom in lwtstate to make sure we
account for tunnel data in mtu calculations during fragmentation
and adds new xmit redirect handler to redirect to lwtunnel xmit func
after ip fragmentation.

This includes IPV6 and some mtu fixes and testing from David Ahern.

Signed-off-by: Roopa Prabhu <roopa@cumulusnetworks.com>
Signed-off-by: David Ahern <dsa@cumulusnetworks.com>
---
 include/net/lwtunnel.h   | 44 ++++++++++++++++++++++++++++++++++++++++++++
 net/core/lwtunnel.c      | 35 +++++++++++++++++++++++++++++++++++
 net/ipv4/ip_output.c     |  8 ++++++++
 net/ipv4/route.c         |  4 +++-
 net/ipv6/ip6_output.c    |  8 ++++++++
 net/ipv6/route.c         |  4 +++-
 net/mpls/mpls_iptunnel.c |  9 +++++----
 7 files changed, 106 insertions(+), 6 deletions(-)

diff --git a/include/net/lwtunnel.h b/include/net/lwtunnel.h
index e9f116e29c22..ea3f80f58fd6 100644
--- a/include/net/lwtunnel.h
+++ b/include/net/lwtunnel.h
@@ -13,6 +13,13 @@
 /* lw tunnel state flags */
 #define LWTUNNEL_STATE_OUTPUT_REDIRECT	BIT(0)
 #define LWTUNNEL_STATE_INPUT_REDIRECT	BIT(1)
+#define LWTUNNEL_STATE_XMIT_REDIRECT	BIT(2)
+
+enum {
+	LWTUNNEL_XMIT_DONE,
+	LWTUNNEL_XMIT_CONTINUE,
+};
+
 
 struct lwtunnel_state {
 	__u16		type;
@@ -21,6 +28,7 @@ struct lwtunnel_state {
 	int		(*orig_output)(struct net *net, struct sock *sk, struct sk_buff *skb);
 	int		(*orig_input)(struct sk_buff *);
 	int             len;
+	__u16		headroom;
 	__u8            data[0];
 };
 
@@ -34,6 +42,7 @@ struct lwtunnel_encap_ops {
 			  struct lwtunnel_state *lwtstate);
 	int (*get_encap_size)(struct lwtunnel_state *lwtstate);
 	int (*cmp_encap)(struct lwtunnel_state *a, struct lwtunnel_state *b);
+	int (*xmit)(struct sk_buff *skb);
 };
 
 #ifdef CONFIG_LWTUNNEL
@@ -75,6 +84,24 @@ static inline bool lwtunnel_input_redirect(struct lwtunnel_state *lwtstate)
 
 	return false;
 }
+
+static inline bool lwtunnel_xmit_redirect(struct lwtunnel_state *lwtstate)
+{
+	if (lwtstate && (lwtstate->flags & LWTUNNEL_STATE_XMIT_REDIRECT))
+		return true;
+
+	return false;
+}
+
+static inline unsigned int lwtunnel_headroom(struct lwtunnel_state *lwtstate,
+					     unsigned int mtu)
+{
+	if (lwtunnel_xmit_redirect(lwtstate) && lwtstate->headroom < mtu)
+		return lwtstate->headroom;
+
+	return 0;
+}
+
 int lwtunnel_encap_add_ops(const struct lwtunnel_encap_ops *op,
 			   unsigned int num);
 int lwtunnel_encap_del_ops(const struct lwtunnel_encap_ops *op,
@@ -90,6 +117,7 @@ struct lwtunnel_state *lwtunnel_state_alloc(int hdr_len);
 int lwtunnel_cmp_encap(struct lwtunnel_state *a, struct lwtunnel_state *b);
 int lwtunnel_output(struct net *net, struct sock *sk, struct sk_buff *skb);
 int lwtunnel_input(struct sk_buff *skb);
+int lwtunnel_xmit(struct sk_buff *skb);
 
 #else
 
@@ -117,6 +145,17 @@ static inline bool lwtunnel_input_redirect(struct lwtunnel_state *lwtstate)
 	return false;
 }
 
+static inline bool lwtunnel_xmit_redirect(struct lwtunnel_state *lwtstate)
+{
+	return false;
+}
+
+static inline unsigned int lwtunnel_headroom(struct lwtunnel_state *lwtstate,
+					     unsigned int mtu)
+{
+	return 0;
+}
+
 static inline int lwtunnel_encap_add_ops(const struct lwtunnel_encap_ops *op,
 					 unsigned int num)
 {
@@ -170,6 +209,11 @@ static inline int lwtunnel_input(struct sk_buff *skb)
 	return -EOPNOTSUPP;
 }
 
+static inline int lwtunnel_xmit(struct sk_buff *skb)
+{
+	return -EOPNOTSUPP;
+}
+
 #endif /* CONFIG_LWTUNNEL */
 
 #define MODULE_ALIAS_RTNL_LWT(encap_type) MODULE_ALIAS("rtnl-lwt-" __stringify(encap_type))
diff --git a/net/core/lwtunnel.c b/net/core/lwtunnel.c
index 669ecc9f884e..e5f84c26ba1a 100644
--- a/net/core/lwtunnel.c
+++ b/net/core/lwtunnel.c
@@ -251,6 +251,41 @@ int lwtunnel_output(struct net *net, struct sock *sk, struct sk_buff *skb)
 }
 EXPORT_SYMBOL(lwtunnel_output);
 
+int lwtunnel_xmit(struct sk_buff *skb)
+{
+	struct dst_entry *dst = skb_dst(skb);
+	const struct lwtunnel_encap_ops *ops;
+	struct lwtunnel_state *lwtstate;
+	int ret = -EINVAL;
+
+	if (!dst)
+		goto drop;
+
+	lwtstate = dst->lwtstate;
+
+	if (lwtstate->type == LWTUNNEL_ENCAP_NONE ||
+	    lwtstate->type > LWTUNNEL_ENCAP_MAX)
+		return 0;
+
+	ret = -EOPNOTSUPP;
+	rcu_read_lock();
+	ops = rcu_dereference(lwtun_encaps[lwtstate->type]);
+	if (likely(ops && ops->xmit))
+		ret = ops->xmit(skb);
+	rcu_read_unlock();
+
+	if (ret == -EOPNOTSUPP)
+		goto drop;
+
+	return ret;
+
+drop:
+	kfree_skb(skb);
+
+	return ret;
+}
+EXPORT_SYMBOL(lwtunnel_xmit);
+
 int lwtunnel_input(struct sk_buff *skb)
 {
 	struct dst_entry *dst = skb_dst(skb);
diff --git a/net/ipv4/ip_output.c b/net/ipv4/ip_output.c
index dde37fb340bf..65569274efb8 100644
--- a/net/ipv4/ip_output.c
+++ b/net/ipv4/ip_output.c
@@ -73,6 +73,7 @@
 #include <net/icmp.h>
 #include <net/checksum.h>
 #include <net/inetpeer.h>
+#include <net/lwtunnel.h>
 #include <linux/igmp.h>
 #include <linux/netfilter_ipv4.h>
 #include <linux/netfilter_bridge.h>
@@ -197,6 +198,13 @@ static int ip_finish_output2(struct net *net, struct sock *sk, struct sk_buff *s
 		skb = skb2;
 	}
 
+	if (lwtunnel_xmit_redirect(dst->lwtstate)) {
+		int res = lwtunnel_xmit(skb);
+
+		if (res < 0 || res == LWTUNNEL_XMIT_DONE)
+			return res;
+	}
+
 	rcu_read_lock_bh();
 	nexthop = (__force u32) rt_nexthop(rt, ip_hdr(skb)->daddr);
 	neigh = __ipv4_neigh_lookup_noref(dev, nexthop);
diff --git a/net/ipv4/route.c b/net/ipv4/route.c
index a1f2830d8110..3e992783c1d0 100644
--- a/net/ipv4/route.c
+++ b/net/ipv4/route.c
@@ -1246,7 +1246,9 @@ static unsigned int ipv4_mtu(const struct dst_entry *dst)
 			mtu = 576;
 	}
 
-	return min_t(unsigned int, mtu, IP_MAX_MTU);
+	mtu = min_t(unsigned int, mtu, IP_MAX_MTU);
+
+	return mtu - lwtunnel_headroom(dst->lwtstate, mtu);
 }
 
 static struct fib_nh_exception *find_exception(struct fib_nh *nh, __be32 daddr)
diff --git a/net/ipv6/ip6_output.c b/net/ipv6/ip6_output.c
index 1dfc402d9ad1..993fd9666f1b 100644
--- a/net/ipv6/ip6_output.c
+++ b/net/ipv6/ip6_output.c
@@ -56,6 +56,7 @@
 #include <net/checksum.h>
 #include <linux/mroute6.h>
 #include <net/l3mdev.h>
+#include <net/lwtunnel.h>
 
 static int ip6_finish_output2(struct net *net, struct sock *sk, struct sk_buff *skb)
 {
@@ -104,6 +105,13 @@ static int ip6_finish_output2(struct net *net, struct sock *sk, struct sk_buff *
 		}
 	}
 
+	if (lwtunnel_xmit_redirect(dst->lwtstate)) {
+		int res = lwtunnel_xmit(skb);
+
+		if (res < 0 || res == LWTUNNEL_XMIT_DONE)
+			return res;
+	}
+
 	rcu_read_lock_bh();
 	nexthop = rt6_nexthop((struct rt6_info *)dst, &ipv6_hdr(skb)->daddr);
 	neigh = __ipv6_neigh_lookup_noref(dst->dev, nexthop);
diff --git a/net/ipv6/route.c b/net/ipv6/route.c
index 49817555449e..09d43ff11a8d 100644
--- a/net/ipv6/route.c
+++ b/net/ipv6/route.c
@@ -1604,7 +1604,9 @@ static unsigned int ip6_mtu(const struct dst_entry *dst)
 	rcu_read_unlock();
 
 out:
-	return min_t(unsigned int, mtu, IP6_MAX_MTU);
+	mtu = min_t(unsigned int, mtu, IP6_MAX_MTU);
+
+	return mtu - lwtunnel_headroom(dst->lwtstate, mtu);
 }
 
 static struct dst_entry *icmp6_dst_gc_list;
diff --git a/net/mpls/mpls_iptunnel.c b/net/mpls/mpls_iptunnel.c
index 644a8da6d4bd..aed872cc05a6 100644
--- a/net/mpls/mpls_iptunnel.c
+++ b/net/mpls/mpls_iptunnel.c
@@ -37,7 +37,7 @@ static unsigned int mpls_encap_size(struct mpls_iptunnel_encap *en)
 	return en->labels * sizeof(struct mpls_shim_hdr);
 }
 
-static int mpls_output(struct net *net, struct sock *sk, struct sk_buff *skb)
+static int mpls_xmit(struct sk_buff *skb)
 {
 	struct mpls_iptunnel_encap *tun_encap_info;
 	struct mpls_shim_hdr *hdr;
@@ -115,7 +115,7 @@ static int mpls_output(struct net *net, struct sock *sk, struct sk_buff *skb)
 		net_dbg_ratelimited("%s: packet transmission failed: %d\n",
 				    __func__, err);
 
-	return 0;
+	return LWTUNNEL_XMIT_DONE;
 
 drop:
 	kfree_skb(skb);
@@ -153,7 +153,8 @@ static int mpls_build_state(struct net_device *dev, struct nlattr *nla,
 	if (ret)
 		goto errout;
 	newts->type = LWTUNNEL_ENCAP_MPLS;
-	newts->flags |= LWTUNNEL_STATE_OUTPUT_REDIRECT;
+	newts->flags |= LWTUNNEL_STATE_XMIT_REDIRECT;
+	newts->headroom = mpls_encap_size(tun_encap_info);
 
 	*ts = newts;
 
@@ -209,7 +210,7 @@ static int mpls_encap_cmp(struct lwtunnel_state *a, struct lwtunnel_state *b)
 
 static const struct lwtunnel_encap_ops mpls_iptun_ops = {
 	.build_state = mpls_build_state,
-	.output = mpls_output,
+	.xmit = mpls_xmit,
 	.fill_encap = mpls_fill_encap_info,
 	.get_encap_size = mpls_encap_nlsize,
 	.cmp_encap = mpls_encap_cmp,
-- 
2.1.4
