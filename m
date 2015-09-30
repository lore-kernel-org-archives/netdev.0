From: "Eric W. Biederman" <ebiederm@xmission.com>
Subject: [PATCH net-next 3/6] ipv4: Pass struct net through ip_fragment
Date: Wed, 30 Sep 2015 16:25:33 -0500
Message-ID: <1443648336-31741-3-git-send-email-ebiederm@xmission.com>
References: <877fn7eh2f.fsf_-_@x220.int.ebiederm.org>
Cc: Pablo Neira Ayuso <pablo@netfilter.org>,
	netfilter-devel@vger.kernel.org, <netdev@vger.kernel.org>,
	Nicolas Dichtel <nicolas.dichtel@6wind.com>
To: David Miller <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from out03.mta.xmission.com ([166.70.13.233]:45869 "EHLO
	out03.mta.xmission.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1754550AbbI3VeT (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 30 Sep 2015 17:34:19 -0400
In-Reply-To: <877fn7eh2f.fsf_-_@x220.int.ebiederm.org>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Signed-off-by: "Eric W. Biederman" <ebiederm@xmission.com>
---
 include/net/ip.h                |  4 ++--
 net/bridge/br_netfilter_hooks.c |  6 +++---
 net/ipv4/ip_output.c            | 44 +++++++++++++++++++----------------------
 net/openvswitch/actions.c       |  2 +-
 4 files changed, 26 insertions(+), 30 deletions(-)

diff --git a/include/net/ip.h b/include/net/ip.h
index 91a6b2c88341..b783141b0671 100644
--- a/include/net/ip.h
+++ b/include/net/ip.h
@@ -109,8 +109,8 @@ int ip_local_deliver(struct sk_buff *skb);
 int ip_mr_input(struct sk_buff *skb);
 int ip_output(struct sock *sk, struct sk_buff *skb);
 int ip_mc_output(struct sock *sk, struct sk_buff *skb);
-int ip_do_fragment(struct sock *sk, struct sk_buff *skb,
-		   int (*output)(struct sock *, struct sk_buff *));
+int ip_do_fragment(struct net *net, struct sock *sk, struct sk_buff *skb,
+		   int (*output)(struct net *, struct sock *, struct sk_buff *));
 void ip_send_check(struct iphdr *ip);
 int __ip_local_out(struct sk_buff *skb);
 int ip_local_out_sk(struct sock *sk, struct sk_buff *skb);
diff --git a/net/bridge/br_netfilter_hooks.c b/net/bridge/br_netfilter_hooks.c
index 13f03671c88d..00e356c236cf 100644
--- a/net/bridge/br_netfilter_hooks.c
+++ b/net/bridge/br_netfilter_hooks.c
@@ -701,7 +701,7 @@ static int br_nf_push_frag_xmit_sk(struct sock *sk, struct sk_buff *skb)
 #if IS_ENABLED(CONFIG_NF_DEFRAG_IPV4)
 static int
 br_nf_ip_fragment(struct net *net, struct sock *sk, struct sk_buff *skb,
-		  int (*output)(struct sock *, struct sk_buff *))
+		  int (*output)(struct net *, struct sock *, struct sk_buff *))
 {
 	unsigned int mtu = ip_skb_dst_mtu(skb);
 	struct iphdr *iph = ip_hdr(skb);
@@ -714,7 +714,7 @@ br_nf_ip_fragment(struct net *net, struct sock *sk, struct sk_buff *skb,
 		return -EMSGSIZE;
 	}
 
-	return ip_do_fragment(sk, skb, output);
+	return ip_do_fragment(net, sk, skb, output);
 }
 #endif
 
@@ -763,7 +763,7 @@ static int br_nf_dev_queue_xmit(struct net *net, struct sock *sk, struct sk_buff
 		skb_copy_from_linear_data_offset(skb, -data->size, data->mac,
 						 data->size);
 
-		return br_nf_ip_fragment(net, sk, skb, br_nf_push_frag_xmit_sk);
+		return br_nf_ip_fragment(net, sk, skb, br_nf_push_frag_xmit);
 	}
 #endif
 #if IS_ENABLED(CONFIG_NF_DEFRAG_IPV6)
diff --git a/net/ipv4/ip_output.c b/net/ipv4/ip_output.c
index aff6766922e8..911ea739049a 100644
--- a/net/ipv4/ip_output.c
+++ b/net/ipv4/ip_output.c
@@ -83,9 +83,10 @@
 int sysctl_ip_default_ttl __read_mostly = IPDEFTTL;
 EXPORT_SYMBOL(sysctl_ip_default_ttl);
 
-static int ip_fragment(struct sock *sk, struct sk_buff *skb,
-		       unsigned int mtu,
-		       int (*output)(struct sock *, struct sk_buff *));
+static int
+ip_fragment(struct net *net, struct sock *sk, struct sk_buff *skb,
+	    unsigned int mtu,
+	    int (*output)(struct net *, struct sock *, struct sk_buff *));
 
 /* Generate a checksum for an outgoing IP datagram. */
 void ip_send_check(struct iphdr *iph)
@@ -176,12 +177,11 @@ int ip_build_and_send_pkt(struct sk_buff *skb, const struct sock *sk,
 }
 EXPORT_SYMBOL_GPL(ip_build_and_send_pkt);
 
-static int ip_finish_output2(struct sock *sk, struct sk_buff *skb)
+static int ip_finish_output2(struct net *net, struct sock *sk, struct sk_buff *skb)
 {
 	struct dst_entry *dst = skb_dst(skb);
 	struct rtable *rt = (struct rtable *)dst;
 	struct net_device *dev = dst->dev;
-	struct net *net = dev_net(dev);
 	unsigned int hh_len = LL_RESERVED_SPACE(dev);
 	struct neighbour *neigh;
 	u32 nexthop;
@@ -225,8 +225,8 @@ static int ip_finish_output2(struct sock *sk, struct sk_buff *skb)
 	return -EINVAL;
 }
 
-static int ip_finish_output_gso(struct sock *sk, struct sk_buff *skb,
-				unsigned int mtu)
+static int ip_finish_output_gso(struct net *net, struct sock *sk,
+				struct sk_buff *skb, unsigned int mtu)
 {
 	netdev_features_t features;
 	struct sk_buff *segs;
@@ -235,7 +235,7 @@ static int ip_finish_output_gso(struct sock *sk, struct sk_buff *skb,
 	/* common case: locally created skb or seglen is <= mtu */
 	if (((IPCB(skb)->flags & IPSKB_FORWARDED) == 0) ||
 	      skb_gso_network_seglen(skb) <= mtu)
-		return ip_finish_output2(sk, skb);
+		return ip_finish_output2(net, sk, skb);
 
 	/* Slowpath -  GSO segment length is exceeding the dst MTU.
 	 *
@@ -258,7 +258,7 @@ static int ip_finish_output_gso(struct sock *sk, struct sk_buff *skb,
 		int err;
 
 		segs->next = NULL;
-		err = ip_fragment(sk, segs, mtu, ip_finish_output2);
+		err = ip_fragment(net, sk, segs, mtu, ip_finish_output2);
 
 		if (err && ret == 0)
 			ret = err;
@@ -281,12 +281,12 @@ static int ip_finish_output(struct net *net, struct sock *sk, struct sk_buff *sk
 #endif
 	mtu = ip_skb_dst_mtu(skb);
 	if (skb_is_gso(skb))
-		return ip_finish_output_gso(sk, skb, mtu);
+		return ip_finish_output_gso(net, sk, skb, mtu);
 
 	if (skb->len > mtu || (IPCB(skb)->flags & IPSKB_FRAG_PMTU))
-		return ip_fragment(sk, skb, mtu, ip_finish_output2);
+		return ip_fragment(net, sk, skb, mtu, ip_finish_output2);
 
-	return ip_finish_output2(sk, skb);
+	return ip_finish_output2(net, sk, skb);
 }
 
 int ip_mc_output(struct sock *sk, struct sk_buff *skb)
@@ -495,20 +495,18 @@ static void ip_copy_metadata(struct sk_buff *to, struct sk_buff *from)
 	skb_copy_secmark(to, from);
 }
 
-static int ip_fragment(struct sock *sk, struct sk_buff *skb,
+static int ip_fragment(struct net *net, struct sock *sk, struct sk_buff *skb,
 		       unsigned int mtu,
-		       int (*output)(struct sock *, struct sk_buff *))
+		       int (*output)(struct net *, struct sock *, struct sk_buff *))
 {
 	struct iphdr *iph = ip_hdr(skb);
 
 	if ((iph->frag_off & htons(IP_DF)) == 0)
-		return ip_do_fragment(sk, skb, output);
+		return ip_do_fragment(net, sk, skb, output);
 
 	if (unlikely(!skb->ignore_df ||
 		     (IPCB(skb)->frag_max_size &&
 		      IPCB(skb)->frag_max_size > mtu))) {
-		struct net *net = dev_net(skb_rtable(skb)->dst.dev);
-
 		IP_INC_STATS(net, IPSTATS_MIB_FRAGFAILS);
 		icmp_send(skb, ICMP_DEST_UNREACH, ICMP_FRAG_NEEDED,
 			  htonl(mtu));
@@ -516,7 +514,7 @@ static int ip_fragment(struct sock *sk, struct sk_buff *skb,
 		return -EMSGSIZE;
 	}
 
-	return ip_do_fragment(sk, skb, output);
+	return ip_do_fragment(net, sk, skb, output);
 }
 
 /*
@@ -526,8 +524,8 @@ static int ip_fragment(struct sock *sk, struct sk_buff *skb,
  *	single device frame, and queue such a frame for sending.
  */
 
-int ip_do_fragment(struct sock *sk, struct sk_buff *skb,
-		   int (*output)(struct sock *, struct sk_buff *))
+int ip_do_fragment(struct net *net, struct sock *sk, struct sk_buff *skb,
+		   int (*output)(struct net *, struct sock *, struct sk_buff *))
 {
 	struct iphdr *iph;
 	int ptr;
@@ -537,11 +535,9 @@ int ip_do_fragment(struct sock *sk, struct sk_buff *skb,
 	int offset;
 	__be16 not_last_frag;
 	struct rtable *rt = skb_rtable(skb);
-	struct net *net;
 	int err = 0;
 
 	dev = rt->dst.dev;
-	net = dev_net(dev);
 
 	/*
 	 *	Point into the IP datagram header.
@@ -631,7 +627,7 @@ int ip_do_fragment(struct sock *sk, struct sk_buff *skb,
 				ip_send_check(iph);
 			}
 
-			err = output(sk, skb);
+			err = output(net, sk, skb);
 
 			if (!err)
 				IP_INC_STATS(net, IPSTATS_MIB_FRAGCREATES);
@@ -771,7 +767,7 @@ slow_path:
 
 		ip_send_check(iph);
 
-		err = output(sk, skb2);
+		err = output(net, sk, skb2);
 		if (err)
 			goto fail;
 
diff --git a/net/openvswitch/actions.c b/net/openvswitch/actions.c
index ba38662f9f5e..b281b2b76c3f 100644
--- a/net/openvswitch/actions.c
+++ b/net/openvswitch/actions.c
@@ -705,7 +705,7 @@ static void ovs_fragment(struct net *net, struct vport *vport,
 		skb_dst_set_noref(skb, &ovs_dst);
 		IPCB(skb)->frag_max_size = mru;
 
-		ip_do_fragment(skb->sk, skb, ovs_vport_output_sk);
+		ip_do_fragment(net, skb->sk, skb, ovs_vport_output);
 		refdst_drop(orig_dst);
 	} else if (ethertype == htons(ETH_P_IPV6)) {
 		const struct nf_ipv6_ops *v6ops = nf_get_ipv6_ops();
-- 
2.2.1
