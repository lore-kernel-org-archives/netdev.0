From: "Eric W. Biederman" <ebiederm@xmission.com>
Subject: [PATCH next 05/30] net: Merge dst_output and dst_output_sk
Date: Tue, 15 Sep 2015 20:03:53 -0500
Message-ID: <1442365458-16349-5-git-send-email-ebiederm@xmission.com>
References: <87mvwn18my.fsf@x220.int.ebiederm.org>
Cc: netfilter-devel@vger.kernel.org, <netdev@vger.kernel.org>
To: Pablo Neira Ayuso <pablo@netfilter.org>,
	David Miller <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from out01.mta.xmission.com ([166.70.13.231]:60218 "EHLO
	out01.mta.xmission.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751987AbbIPBLl (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 15 Sep 2015 21:11:41 -0400
In-Reply-To: <87mvwn18my.fsf@x220.int.ebiederm.org>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Add a sock paramter to dst_output making dst_output_sk superfluous.
Add a skb->sk parameter to all of the callers of dst_output
Have the callers of dst_output_sk call dst_output.

Signed-off-by: "Eric W. Biederman" <ebiederm@xmission.com>
---
 include/net/dst.h               | 6 +-----
 net/decnet/dn_nsp_out.c         | 4 ++--
 net/ipv4/ip_forward.c           | 2 +-
 net/ipv4/ip_output.c            | 6 +++---
 net/ipv4/ip_vti.c               | 2 +-
 net/ipv4/ipmr.c                 | 2 +-
 net/ipv4/raw.c                  | 2 +-
 net/ipv4/xfrm4_output.c         | 2 +-
 net/ipv6/ip6_output.c           | 4 ++--
 net/ipv6/ip6_vti.c              | 2 +-
 net/ipv6/ip6mr.c                | 2 +-
 net/ipv6/mcast.c                | 4 ++--
 net/ipv6/ndisc.c                | 2 +-
 net/ipv6/output_core.c          | 4 ++--
 net/ipv6/raw.c                  | 2 +-
 net/ipv6/xfrm6_output.c         | 2 +-
 net/netfilter/ipvs/ip_vs_xmit.c | 4 ++--
 net/xfrm/xfrm_output.c          | 2 +-
 net/xfrm/xfrm_policy.c          | 2 +-
 19 files changed, 26 insertions(+), 30 deletions(-)

diff --git a/include/net/dst.h b/include/net/dst.h
index 9261d928303d..c72e58474e52 100644
--- a/include/net/dst.h
+++ b/include/net/dst.h
@@ -454,14 +454,10 @@ static inline void dst_set_expires(struct dst_entry *dst, int timeout)
 }
 
 /* Output packet to network from transport.  */
-static inline int dst_output_sk(struct sock *sk, struct sk_buff *skb)
+static inline int dst_output(struct sock *sk, struct sk_buff *skb)
 {
 	return skb_dst(skb)->output(sk, skb);
 }
-static inline int dst_output(struct sk_buff *skb)
-{
-	return dst_output_sk(skb->sk, skb);
-}
 
 /* Input packet from network to transport.  */
 static inline int dst_input(struct sk_buff *skb)
diff --git a/net/decnet/dn_nsp_out.c b/net/decnet/dn_nsp_out.c
index 1aaa51ebbda6..4b02dd300f50 100644
--- a/net/decnet/dn_nsp_out.c
+++ b/net/decnet/dn_nsp_out.c
@@ -85,7 +85,7 @@ static void dn_nsp_send(struct sk_buff *skb)
 	if (dst) {
 try_again:
 		skb_dst_set(skb, dst);
-		dst_output(skb);
+		dst_output(skb->sk, skb);
 		return;
 	}
 
@@ -582,7 +582,7 @@ static __inline__ void dn_nsp_do_disc(struct sock *sk, unsigned char msgflg,
 	 * associations.
 	 */
 	skb_dst_set(skb, dst_clone(dst));
-	dst_output(skb);
+	dst_output(skb->sk, skb);
 }
 
 
diff --git a/net/ipv4/ip_forward.c b/net/ipv4/ip_forward.c
index 2d3aa408fbdc..28fb90108f56 100644
--- a/net/ipv4/ip_forward.c
+++ b/net/ipv4/ip_forward.c
@@ -72,7 +72,7 @@ static int ip_forward_finish(struct sock *sk, struct sk_buff *skb)
 		ip_forward_options(skb);
 
 	skb_sender_cpu_clear(skb);
-	return dst_output_sk(sk, skb);
+	return dst_output(sk, skb);
 }
 
 int ip_forward(struct sk_buff *skb)
diff --git a/net/ipv4/ip_output.c b/net/ipv4/ip_output.c
index 0138fada0951..f076f11aa94a 100644
--- a/net/ipv4/ip_output.c
+++ b/net/ipv4/ip_output.c
@@ -102,7 +102,7 @@ static int __ip_local_out_sk(struct sock *sk, struct sk_buff *skb)
 	iph->tot_len = htons(skb->len);
 	ip_send_check(iph);
 	return nf_hook(NFPROTO_IPV4, NF_INET_LOCAL_OUT, sk, skb, NULL,
-		       skb_dst(skb)->dev, dst_output_sk);
+		       skb_dst(skb)->dev, dst_output);
 }
 
 int __ip_local_out(struct sk_buff *skb)
@@ -116,7 +116,7 @@ int ip_local_out_sk(struct sock *sk, struct sk_buff *skb)
 
 	err = __ip_local_out(skb);
 	if (likely(err == 1))
-		err = dst_output_sk(sk, skb);
+		err = dst_output(sk, skb);
 
 	return err;
 }
@@ -271,7 +271,7 @@ static int ip_finish_output(struct sock *sk, struct sk_buff *skb)
 	/* Policy lookup after SNAT yielded a new policy */
 	if (skb_dst(skb)->xfrm) {
 		IPCB(skb)->flags |= IPSKB_REROUTED;
-		return dst_output_sk(sk, skb);
+		return dst_output(sk, skb);
 	}
 #endif
 	mtu = ip_skb_dst_mtu(skb);
diff --git a/net/ipv4/ip_vti.c b/net/ipv4/ip_vti.c
index 0c152087ca15..3b87ec5178f9 100644
--- a/net/ipv4/ip_vti.c
+++ b/net/ipv4/ip_vti.c
@@ -197,7 +197,7 @@ static netdev_tx_t vti_xmit(struct sk_buff *skb, struct net_device *dev,
 	skb_dst_set(skb, dst);
 	skb->dev = skb_dst(skb)->dev;
 
-	err = dst_output(skb);
+	err = dst_output(skb->sk, skb);
 	if (net_xmit_eval(err) == 0)
 		err = skb->len;
 	iptunnel_xmit_stats(err, &dev->stats, dev->tstats);
diff --git a/net/ipv4/ipmr.c b/net/ipv4/ipmr.c
index 866ee89f5254..a0a5def920fc 100644
--- a/net/ipv4/ipmr.c
+++ b/net/ipv4/ipmr.c
@@ -1688,7 +1688,7 @@ static inline int ipmr_forward_finish(struct sock *sk, struct sk_buff *skb)
 	if (unlikely(opt->optlen))
 		ip_forward_options(skb);
 
-	return dst_output_sk(sk, skb);
+	return dst_output(sk, skb);
 }
 
 /*
diff --git a/net/ipv4/raw.c b/net/ipv4/raw.c
index 561cd4b8fc6e..09ab5bb6913a 100644
--- a/net/ipv4/raw.c
+++ b/net/ipv4/raw.c
@@ -412,7 +412,7 @@ static int raw_send_hdrinc(struct sock *sk, struct flowi4 *fl4,
 			skb_transport_header(skb))->type);
 
 	err = NF_HOOK(NFPROTO_IPV4, NF_INET_LOCAL_OUT, sk, skb,
-		      NULL, rt->dst.dev, dst_output_sk);
+		      NULL, rt->dst.dev, dst_output);
 	if (err > 0)
 		err = net_xmit_errno(err);
 	if (err)
diff --git a/net/ipv4/xfrm4_output.c b/net/ipv4/xfrm4_output.c
index 2878dbfffeb7..737f5e395a6a 100644
--- a/net/ipv4/xfrm4_output.c
+++ b/net/ipv4/xfrm4_output.c
@@ -87,7 +87,7 @@ static int __xfrm4_output(struct sock *sk, struct sk_buff *skb)
 #ifdef CONFIG_NETFILTER
 	if (!x) {
 		IPCB(skb)->flags |= IPSKB_REROUTED;
-		return dst_output_sk(sk, skb);
+		return dst_output(sk, skb);
 	}
 #endif
 
diff --git a/net/ipv6/ip6_output.c b/net/ipv6/ip6_output.c
index 26ea47930740..a80502c64523 100644
--- a/net/ipv6/ip6_output.c
+++ b/net/ipv6/ip6_output.c
@@ -225,7 +225,7 @@ int ip6_xmit(struct sock *sk, struct sk_buff *skb, struct flowi6 *fl6,
 		IP6_UPD_PO_STATS(net, ip6_dst_idev(skb_dst(skb)),
 			      IPSTATS_MIB_OUT, skb->len);
 		return NF_HOOK(NFPROTO_IPV6, NF_INET_LOCAL_OUT, sk, skb,
-			       NULL, dst->dev, dst_output_sk);
+			       NULL, dst->dev, dst_output);
 	}
 
 	skb->dev = dst->dev;
@@ -320,7 +320,7 @@ static int ip6_forward_proxy_check(struct sk_buff *skb)
 static inline int ip6_forward_finish(struct sock *sk, struct sk_buff *skb)
 {
 	skb_sender_cpu_clear(skb);
-	return dst_output_sk(sk, skb);
+	return dst_output(sk, skb);
 }
 
 static unsigned int ip6_dst_mtu_forward(const struct dst_entry *dst)
diff --git a/net/ipv6/ip6_vti.c b/net/ipv6/ip6_vti.c
index 0224c032dca5..f96f1c19b4a8 100644
--- a/net/ipv6/ip6_vti.c
+++ b/net/ipv6/ip6_vti.c
@@ -482,7 +482,7 @@ vti6_xmit(struct sk_buff *skb, struct net_device *dev, struct flowi *fl)
 		return -EMSGSIZE;
 	}
 
-	err = dst_output(skb);
+	err = dst_output(skb->sk, skb);
 	if (net_xmit_eval(err) == 0) {
 		struct pcpu_sw_netstats *tstats = this_cpu_ptr(dev->tstats);
 
diff --git a/net/ipv6/ip6mr.c b/net/ipv6/ip6mr.c
index 0e004cc42a22..e95f6b6281de 100644
--- a/net/ipv6/ip6mr.c
+++ b/net/ipv6/ip6mr.c
@@ -1991,7 +1991,7 @@ static inline int ip6mr_forward2_finish(struct sock *sk, struct sk_buff *skb)
 			 IPSTATS_MIB_OUTFORWDATAGRAMS);
 	IP6_ADD_STATS_BH(dev_net(skb_dst(skb)->dev), ip6_dst_idev(skb_dst(skb)),
 			 IPSTATS_MIB_OUTOCTETS, skb->len);
-	return dst_output_sk(sk, skb);
+	return dst_output(sk, skb);
 }
 
 /*
diff --git a/net/ipv6/mcast.c b/net/ipv6/mcast.c
index 083b2927fc67..5b3f2841acf6 100644
--- a/net/ipv6/mcast.c
+++ b/net/ipv6/mcast.c
@@ -1646,7 +1646,7 @@ static void mld_sendpack(struct sk_buff *skb)
 
 	err = NF_HOOK(NFPROTO_IPV6, NF_INET_LOCAL_OUT,
 		      net->ipv6.igmp_sk, skb, NULL, skb->dev,
-		      dst_output_sk);
+		      dst_output);
 out:
 	if (!err) {
 		ICMP6MSGOUT_INC_STATS(net, idev, ICMPV6_MLD2_REPORT);
@@ -2009,7 +2009,7 @@ static void igmp6_send(struct in6_addr *addr, struct net_device *dev, int type)
 
 	skb_dst_set(skb, dst);
 	err = NF_HOOK(NFPROTO_IPV6, NF_INET_LOCAL_OUT, sk, skb,
-		      NULL, skb->dev, dst_output_sk);
+		      NULL, skb->dev, dst_output);
 out:
 	if (!err) {
 		ICMP6MSGOUT_INC_STATS(net, idev, type);
diff --git a/net/ipv6/ndisc.c b/net/ipv6/ndisc.c
index 64a71354b069..349ac1b022b6 100644
--- a/net/ipv6/ndisc.c
+++ b/net/ipv6/ndisc.c
@@ -465,7 +465,7 @@ static void ndisc_send_skb(struct sk_buff *skb,
 
 	err = NF_HOOK(NFPROTO_IPV6, NF_INET_LOCAL_OUT, sk, skb,
 		      NULL, dst->dev,
-		      dst_output_sk);
+		      dst_output);
 	if (!err) {
 		ICMP6MSGOUT_INC_STATS(net, idev, type);
 		ICMP6_INC_STATS(net, idev, ICMP6_MIB_OUTMSGS);
diff --git a/net/ipv6/output_core.c b/net/ipv6/output_core.c
index 928a0fb0b744..8178f72fe90d 100644
--- a/net/ipv6/output_core.c
+++ b/net/ipv6/output_core.c
@@ -149,7 +149,7 @@ static int __ip6_local_out_sk(struct sock *sk, struct sk_buff *skb)
 	IP6CB(skb)->nhoff = offsetof(struct ipv6hdr, nexthdr);
 
 	return nf_hook(NFPROTO_IPV6, NF_INET_LOCAL_OUT, sk, skb,
-		       NULL, skb_dst(skb)->dev, dst_output_sk);
+		       NULL, skb_dst(skb)->dev, dst_output);
 }
 
 int __ip6_local_out(struct sk_buff *skb)
@@ -164,7 +164,7 @@ int ip6_local_out_sk(struct sock *sk, struct sk_buff *skb)
 
 	err = __ip6_local_out_sk(sk, skb);
 	if (likely(err == 1))
-		err = dst_output_sk(sk, skb);
+		err = dst_output(sk, skb);
 
 	return err;
 }
diff --git a/net/ipv6/raw.c b/net/ipv6/raw.c
index fdbada1569a3..1636537705f5 100644
--- a/net/ipv6/raw.c
+++ b/net/ipv6/raw.c
@@ -654,7 +654,7 @@ static int rawv6_send_hdrinc(struct sock *sk, struct msghdr *msg, int length,
 
 	IP6_UPD_PO_STATS(sock_net(sk), rt->rt6i_idev, IPSTATS_MIB_OUT, skb->len);
 	err = NF_HOOK(NFPROTO_IPV6, NF_INET_LOCAL_OUT, sk, skb,
-		      NULL, rt->dst.dev, dst_output_sk);
+		      NULL, rt->dst.dev, dst_output);
 	if (err > 0)
 		err = net_xmit_errno(err);
 	if (err)
diff --git a/net/ipv6/xfrm6_output.c b/net/ipv6/xfrm6_output.c
index 09c76a7b474d..b0fcd6c09837 100644
--- a/net/ipv6/xfrm6_output.c
+++ b/net/ipv6/xfrm6_output.c
@@ -140,7 +140,7 @@ static int __xfrm6_output(struct sock *sk, struct sk_buff *skb)
 #ifdef CONFIG_NETFILTER
 	if (!x) {
 		IP6CB(skb)->flags |= IP6SKB_REROUTED;
-		return dst_output_sk(sk, skb);
+		return dst_output(sk, skb);
 	}
 #endif
 
diff --git a/net/netfilter/ipvs/ip_vs_xmit.c b/net/netfilter/ipvs/ip_vs_xmit.c
index 258a0b0e82a2..b8e5544af87f 100644
--- a/net/netfilter/ipvs/ip_vs_xmit.c
+++ b/net/netfilter/ipvs/ip_vs_xmit.c
@@ -574,7 +574,7 @@ static inline int ip_vs_nat_send_or_cont(int pf, struct sk_buff *skb,
 		if (!skb->sk)
 			skb_sender_cpu_clear(skb);
 		NF_HOOK(pf, NF_INET_LOCAL_OUT, NULL, skb,
-			NULL, skb_dst(skb)->dev, dst_output_sk);
+			NULL, skb_dst(skb)->dev, dst_output);
 	} else
 		ret = NF_ACCEPT;
 
@@ -596,7 +596,7 @@ static inline int ip_vs_send_or_cont(int pf, struct sk_buff *skb,
 		if (!skb->sk)
 			skb_sender_cpu_clear(skb);
 		NF_HOOK(pf, NF_INET_LOCAL_OUT, NULL, skb,
-			NULL, skb_dst(skb)->dev, dst_output_sk);
+			NULL, skb_dst(skb)->dev, dst_output);
 	} else
 		ret = NF_ACCEPT;
 	return ret;
diff --git a/net/xfrm/xfrm_output.c b/net/xfrm/xfrm_output.c
index 68ada2ca4b60..57a50f6ce28c 100644
--- a/net/xfrm/xfrm_output.c
+++ b/net/xfrm/xfrm_output.c
@@ -139,7 +139,7 @@ int xfrm_output_resume(struct sk_buff *skb, int err)
 			goto out;
 
 		if (!skb_dst(skb)->xfrm)
-			return dst_output(skb);
+			return dst_output(skb->sk, skb);
 
 		err = nf_hook(skb_dst(skb)->ops->family,
 			      NF_INET_POST_ROUTING, skb->sk, skb,
diff --git a/net/xfrm/xfrm_policy.c b/net/xfrm/xfrm_policy.c
index 6b5d6e2b9a49..e7f64bcb78a8 100644
--- a/net/xfrm/xfrm_policy.c
+++ b/net/xfrm/xfrm_policy.c
@@ -1945,7 +1945,7 @@ static void xfrm_policy_queue_process(unsigned long arg)
 		skb_dst_drop(skb);
 		skb_dst_set(skb, dst);
 
-		dst_output(skb);
+		dst_output(skb->sk, skb);
 	}
 
 out:
-- 
2.2.1
