From: Daniel Mack <daniel@zonque.org>
Subject: [PATCH v9 5/6] net: ipv4, ipv6: run cgroup eBPF egress programs
Date: Wed, 23 Nov 2016 16:52:29 +0100
Message-ID: <1479916350-28462-6-git-send-email-daniel@zonque.org>
References: <1479916350-28462-1-git-send-email-daniel@zonque.org>
Cc: davem@davemloft.net, kafai@fb.com, fw@strlen.de,
        pablo@netfilter.org, harald@redhat.com, netdev@vger.kernel.org,
        sargun@sargun.me, cgroups@vger.kernel.org,
        Daniel Mack <daniel@zonque.org>
To: htejun@fb.com, daniel@iogearbox.net, ast@fb.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from svenfoo.org ([82.94.215.22]:49654 "EHLO mail.zonque.de"
        rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
        id S935098AbcKWPwn (ORCPT <rfc822;netdev@vger.kernel.org>);
        Wed, 23 Nov 2016 10:52:43 -0500
In-Reply-To: <1479916350-28462-1-git-send-email-daniel@zonque.org>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

If the cgroup associated with the receiving socket has an eBPF
programs installed, run them from ip_output(), ip6_output() and
ip_mc_output(). From mentioned functions we have two socket contexts
as per 7026b1ddb6b8 ("netfilter: Pass socket pointer down through
okfn()."). We explicitly need to use sk instead of skb->sk here,
since otherwise the same program would run multiple times on egress
when encap devices are involved, which is not desired in our case.

eBPF programs used in this context are expected to either return 1 to
let the packet pass, or != 1 to drop them. The programs have access to
the skb through bpf_skb_load_bytes(), and the payload starts at the
network headers (L3).

Note that cgroup_bpf_run_filter() is stubbed out as static inline nop
for !CONFIG_CGROUP_BPF, and is otherwise guarded by a static key if
the feature is unused.

Signed-off-by: Daniel Mack <daniel@zonque.org>
Acked-by: Alexei Starovoitov <ast@kernel.org>
---
 net/ipv4/ip_output.c  | 26 ++++++++++++++++++++++++--
 net/ipv6/ip6_output.c |  9 +++++++++
 2 files changed, 33 insertions(+), 2 deletions(-)

diff --git a/net/ipv4/ip_output.c b/net/ipv4/ip_output.c
index 03e7f73..ed0c276 100644
--- a/net/ipv4/ip_output.c
+++ b/net/ipv4/ip_output.c
@@ -74,6 +74,7 @@
 #include <net/checksum.h>
 #include <net/inetpeer.h>
 #include <net/lwtunnel.h>
+#include <linux/bpf-cgroup.h>
 #include <linux/igmp.h>
 #include <linux/netfilter_ipv4.h>
 #include <linux/netfilter_bridge.h>
@@ -281,6 +282,13 @@ static int ip_finish_output_gso(struct net *net, struct sock *sk,
 static int ip_finish_output(struct net *net, struct sock *sk, struct sk_buff *skb)
 {
 	unsigned int mtu;
+	int ret;
+
+	ret = BPF_CGROUP_RUN_PROG_INET_EGRESS(sk, skb);
+	if (ret) {
+		kfree_skb(skb);
+		return ret;
+	}
 
 #if defined(CONFIG_NETFILTER) && defined(CONFIG_XFRM)
 	/* Policy lookup after SNAT yielded a new policy */
@@ -299,6 +307,20 @@ static int ip_finish_output(struct net *net, struct sock *sk, struct sk_buff *sk
 	return ip_finish_output2(net, sk, skb);
 }
 
+static int ip_mc_finish_output(struct net *net, struct sock *sk,
+			       struct sk_buff *skb)
+{
+	int ret;
+
+	ret = BPF_CGROUP_RUN_PROG_INET_EGRESS(sk, skb);
+	if (ret) {
+		kfree_skb(skb);
+		return ret;
+	}
+
+	return dev_loopback_xmit(net, sk, skb);
+}
+
 int ip_mc_output(struct net *net, struct sock *sk, struct sk_buff *skb)
 {
 	struct rtable *rt = skb_rtable(skb);
@@ -336,7 +358,7 @@ int ip_mc_output(struct net *net, struct sock *sk, struct sk_buff *skb)
 			if (newskb)
 				NF_HOOK(NFPROTO_IPV4, NF_INET_POST_ROUTING,
 					net, sk, newskb, NULL, newskb->dev,
-					dev_loopback_xmit);
+					ip_mc_finish_output);
 		}
 
 		/* Multicasts with ttl 0 must not go beyond the host */
@@ -352,7 +374,7 @@ int ip_mc_output(struct net *net, struct sock *sk, struct sk_buff *skb)
 		if (newskb)
 			NF_HOOK(NFPROTO_IPV4, NF_INET_POST_ROUTING,
 				net, sk, newskb, NULL, newskb->dev,
-				dev_loopback_xmit);
+				ip_mc_finish_output);
 	}
 
 	return NF_HOOK_COND(NFPROTO_IPV4, NF_INET_POST_ROUTING,
diff --git a/net/ipv6/ip6_output.c b/net/ipv6/ip6_output.c
index 6001e78..ddeb41e 100644
--- a/net/ipv6/ip6_output.c
+++ b/net/ipv6/ip6_output.c
@@ -39,6 +39,7 @@
 #include <linux/module.h>
 #include <linux/slab.h>
 
+#include <linux/bpf-cgroup.h>
 #include <linux/netfilter.h>
 #include <linux/netfilter_ipv6.h>
 
@@ -131,6 +132,14 @@ static int ip6_finish_output2(struct net *net, struct sock *sk, struct sk_buff *
 
 static int ip6_finish_output(struct net *net, struct sock *sk, struct sk_buff *skb)
 {
+	int ret;
+
+	ret = BPF_CGROUP_RUN_PROG_INET_EGRESS(sk, skb);
+	if (ret) {
+		kfree_skb(skb);
+		return ret;
+	}
+
 	if ((skb->len > ip6_skb_dst_mtu(skb) && !skb_is_gso(skb)) ||
 	    dst_allfrag(skb_dst(skb)) ||
 	    (IP6CB(skb)->frag_max_size && skb->len > IP6CB(skb)->frag_max_size))
-- 
2.7.4
