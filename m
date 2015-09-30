From: "Eric W. Biederman" <ebiederm@xmission.com>
Subject: [PATCH net-next 4/6] ipv6: Pass struct net through ip6_fragment
Date: Wed, 30 Sep 2015 16:25:34 -0500
Message-ID: <1443648336-31741-4-git-send-email-ebiederm@xmission.com>
References: <877fn7eh2f.fsf_-_@x220.int.ebiederm.org>
Cc: Pablo Neira Ayuso <pablo@netfilter.org>,
	netfilter-devel@vger.kernel.org, <netdev@vger.kernel.org>,
	Nicolas Dichtel <nicolas.dichtel@6wind.com>
To: David Miller <davem@davemloft.net>
Return-path: <netfilter-devel-owner@vger.kernel.org>
In-Reply-To: <877fn7eh2f.fsf_-_@x220.int.ebiederm.org>
Sender: netfilter-devel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Signed-off-by: Eric W. Biederman <ebiederm@xmission.com>
---
 include/linux/netfilter_ipv6.h  |  4 ++--
 include/net/ip6_route.h         |  4 ++--
 net/bridge/br_netfilter_hooks.c |  2 +-
 net/ipv6/ip6_output.c           | 16 +++++++---------
 net/ipv6/xfrm6_output.c         | 10 ++++++++--
 net/openvswitch/actions.c       |  2 +-
 6 files changed, 21 insertions(+), 17 deletions(-)

diff --git a/include/linux/netfilter_ipv6.h b/include/linux/netfilter_ipv6.h
index 2ac8369fa96c..47c6b04c28c0 100644
--- a/include/linux/netfilter_ipv6.h
+++ b/include/linux/netfilter_ipv6.h
@@ -17,8 +17,8 @@ struct nf_ipv6_ops {
 	int (*chk_addr)(struct net *net, const struct in6_addr *addr,
 			const struct net_device *dev, int strict);
 	void (*route_input)(struct sk_buff *skb);
-	int (*fragment)(struct sock *sk, struct sk_buff *skb,
-			int (*output)(struct sock *, struct sk_buff *));
+	int (*fragment)(struct net *net, struct sock *sk, struct sk_buff *skb,
+			int (*output)(struct net *, struct sock *, struct sk_buff *));
 };
 
 #ifdef CONFIG_NETFILTER
diff --git a/include/net/ip6_route.h b/include/net/ip6_route.h
index 297629aadb19..2bfb2ad2fab1 100644
--- a/include/net/ip6_route.h
+++ b/include/net/ip6_route.h
@@ -173,8 +173,8 @@ static inline bool ipv6_anycast_destination(const struct dst_entry *dst,
 		 ipv6_addr_equal(&rt->rt6i_dst.addr, daddr));
 }
 
-int ip6_fragment(struct sock *sk, struct sk_buff *skb,
-		 int (*output)(struct sock *, struct sk_buff *));
+int ip6_fragment(struct net *net, struct sock *sk, struct sk_buff *skb,
+		 int (*output)(struct net *, struct sock *, struct sk_buff *));
 
 static inline int ip6_skb_dst_mtu(struct sk_buff *skb)
 {
diff --git a/net/bridge/br_netfilter_hooks.c b/net/bridge/br_netfilter_hooks.c
index 00e356c236cf..815994d5b02d 100644
--- a/net/bridge/br_netfilter_hooks.c
+++ b/net/bridge/br_netfilter_hooks.c
@@ -786,7 +786,7 @@ static int br_nf_dev_queue_xmit(struct net *net, struct sock *sk, struct sk_buff
 						 data->size);
 
 		if (v6ops)
-			return v6ops->fragment(sk, skb, br_nf_push_frag_xmit_sk);
+			return v6ops->fragment(net, sk, skb, br_nf_push_frag_xmit);
 
 		kfree_skb(skb);
 		return -EMSGSIZE;
diff --git a/net/ipv6/ip6_output.c b/net/ipv6/ip6_output.c
index a598fe2c0849..caf7d14a1bdd 100644
--- a/net/ipv6/ip6_output.c
+++ b/net/ipv6/ip6_output.c
@@ -56,11 +56,10 @@
 #include <net/checksum.h>
 #include <linux/mroute6.h>
 
-static int ip6_finish_output2(struct sock *sk, struct sk_buff *skb)
+static int ip6_finish_output2(struct net *net, struct sock *sk, struct sk_buff *skb)
 {
 	struct dst_entry *dst = skb_dst(skb);
 	struct net_device *dev = dst->dev;
-	struct net *net = dev_net(dev);
 	struct neighbour *neigh;
 	struct in6_addr *nexthop;
 	int ret;
@@ -126,9 +125,9 @@ static int ip6_finish_output(struct net *net, struct sock *sk, struct sk_buff *s
 	if ((skb->len > ip6_skb_dst_mtu(skb) && !skb_is_gso(skb)) ||
 	    dst_allfrag(skb_dst(skb)) ||
 	    (IP6CB(skb)->frag_max_size && skb->len > IP6CB(skb)->frag_max_size))
-		return ip6_fragment(sk, skb, ip6_finish_output2);
+		return ip6_fragment(net, sk, skb, ip6_finish_output2);
 	else
-		return ip6_finish_output2(sk, skb);
+		return ip6_finish_output2(net, sk, skb);
 }
 
 int ip6_output(struct sock *sk, struct sk_buff *skb)
@@ -554,8 +553,8 @@ static void ip6_copy_metadata(struct sk_buff *to, struct sk_buff *from)
 	skb_copy_secmark(to, from);
 }
 
-int ip6_fragment(struct sock *sk, struct sk_buff *skb,
-		 int (*output)(struct sock *, struct sk_buff *))
+int ip6_fragment(struct net *net, struct sock *sk, struct sk_buff *skb,
+		 int (*output)(struct net *, struct sock *, struct sk_buff *))
 {
 	struct sk_buff *frag;
 	struct rt6_info *rt = (struct rt6_info *)skb_dst(skb);
@@ -568,7 +567,6 @@ int ip6_fragment(struct sock *sk, struct sk_buff *skb,
 	__be32 frag_id;
 	int ptr, offset = 0, err = 0;
 	u8 *prevhdr, nexthdr = 0;
-	struct net *net = dev_net(skb_dst(skb)->dev);
 
 	hlen = ip6_find_1stfragopt(skb, &prevhdr);
 	nexthdr = *prevhdr;
@@ -688,7 +686,7 @@ int ip6_fragment(struct sock *sk, struct sk_buff *skb,
 				ip6_copy_metadata(frag, skb);
 			}
 
-			err = output(sk, skb);
+			err = output(net, sk, skb);
 			if (!err)
 				IP6_INC_STATS(net, ip6_dst_idev(&rt->dst),
 					      IPSTATS_MIB_FRAGCREATES);
@@ -816,7 +814,7 @@ slow_path:
 		/*
 		 *	Put this fragment into the sending queue.
 		 */
-		err = output(sk, frag);
+		err = output(net, sk, frag);
 		if (err)
 			goto fail;
 
diff --git a/net/ipv6/xfrm6_output.c b/net/ipv6/xfrm6_output.c
index 0c3e9ffcf231..335066a64b45 100644
--- a/net/ipv6/xfrm6_output.c
+++ b/net/ipv6/xfrm6_output.c
@@ -131,6 +131,12 @@ int xfrm6_output_finish(struct sock *sk, struct sk_buff *skb)
 	return xfrm_output(sk, skb);
 }
 
+static int __xfrm6_output_finish(struct net *net, struct sock *sk, struct sk_buff *skb)
+{
+	struct xfrm_state *x = skb_dst(skb)->xfrm;
+	return x->outer_mode->afinfo->output_finish(sk, skb);
+}
+
 static int __xfrm6_output(struct net *net, struct sock *sk, struct sk_buff *skb)
 {
 	struct dst_entry *dst = skb_dst(skb);
@@ -160,8 +166,8 @@ static int __xfrm6_output(struct net *net, struct sock *sk, struct sk_buff *skb)
 	if (x->props.mode == XFRM_MODE_TUNNEL &&
 	    ((skb->len > mtu && !skb_is_gso(skb)) ||
 		dst_allfrag(skb_dst(skb)))) {
-		return ip6_fragment(sk, skb,
-				    x->outer_mode->afinfo->output_finish);
+		return ip6_fragment(net, sk, skb,
+				    __xfrm6_output_finish);
 	}
 	return x->outer_mode->afinfo->output_finish(sk, skb);
 }
diff --git a/net/openvswitch/actions.c b/net/openvswitch/actions.c
index b281b2b76c3f..f33c627f97b3 100644
--- a/net/openvswitch/actions.c
+++ b/net/openvswitch/actions.c
@@ -727,7 +727,7 @@ static void ovs_fragment(struct net *net, struct vport *vport,
 		skb_dst_set_noref(skb, &ovs_rt.dst);
 		IP6CB(skb)->frag_max_size = mru;
 
-		v6ops->fragment(skb->sk, skb, ovs_vport_output_sk);
+		v6ops->fragment(net, skb->sk, skb, ovs_vport_output);
 		refdst_drop(orig_dst);
 	} else {
 		WARN_ONCE(1, "Failed fragment ->%s: eth=%04x, MRU=%d, MTU=%d.",
-- 
2.2.1

