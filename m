From: Daniel Mack <daniel@zonque.org>
Subject: [PATCH v8 5/6] net: ipv4, ipv6: run cgroup eBPF egress programs
Date: Thu, 17 Nov 2016 19:27:08 +0100
Message-ID: <1479407229-14861-6-git-send-email-daniel@zonque.org>
References: <1479407229-14861-1-git-send-email-daniel@zonque.org>
Cc: davem@davemloft.net, kafai@fb.com, fw@strlen.de,
        pablo@netfilter.org, harald@redhat.com, netdev@vger.kernel.org,
        sargun@sargun.me, cgroups@vger.kernel.org,
        Daniel Mack <daniel@zonque.org>
To: htejun@fb.com, daniel@iogearbox.net, ast@fb.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from svenfoo.org ([82.94.215.22]:55763 "EHLO mail.zonque.de"
        rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
        id S1753435AbcKQS1Y (ORCPT <rfc822;netdev@vger.kernel.org>);
        Thu, 17 Nov 2016 13:27:24 -0500
In-Reply-To: <1479407229-14861-1-git-send-email-daniel@zonque.org>
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
 net/ipv4/ip_output.c  | 15 +++++++++++++++
 net/ipv6/ip6_output.c |  8 ++++++++
 2 files changed, 23 insertions(+)

diff --git a/net/ipv4/ip_output.c b/net/ipv4/ip_output.c
index 03e7f73..5914006 100644
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
@@ -303,6 +304,7 @@ int ip_mc_output(struct net *net, struct sock *sk, struct sk_buff *skb)
 {
 	struct rtable *rt = skb_rtable(skb);
 	struct net_device *dev = rt->dst.dev;
+	int ret;
 
 	/*
 	 *	If the indicated interface is up and running, send the packet.
@@ -312,6 +314,12 @@ int ip_mc_output(struct net *net, struct sock *sk, struct sk_buff *skb)
 	skb->dev = dev;
 	skb->protocol = htons(ETH_P_IP);
 
+	ret = BPF_CGROUP_RUN_PROG_INET_EGRESS(sk, skb);
+	if (ret) {
+		kfree_skb(skb);
+		return ret;
+	}
+
 	/*
 	 *	Multicasts are looped back for other local users
 	 */
@@ -364,12 +372,19 @@ int ip_mc_output(struct net *net, struct sock *sk, struct sk_buff *skb)
 int ip_output(struct net *net, struct sock *sk, struct sk_buff *skb)
 {
 	struct net_device *dev = skb_dst(skb)->dev;
+	int ret;
 
 	IP_UPD_PO_STATS(net, IPSTATS_MIB_OUT, skb->len);
 
 	skb->dev = dev;
 	skb->protocol = htons(ETH_P_IP);
 
+	ret = BPF_CGROUP_RUN_PROG_INET_EGRESS(sk, skb);
+	if (ret) {
+		kfree_skb(skb);
+		return ret;
+	}
+
 	return NF_HOOK_COND(NFPROTO_IPV4, NF_INET_POST_ROUTING,
 			    net, sk, skb, NULL, dev,
 			    ip_finish_output,
diff --git a/net/ipv6/ip6_output.c b/net/ipv6/ip6_output.c
index 6001e78..483f91b 100644
--- a/net/ipv6/ip6_output.c
+++ b/net/ipv6/ip6_output.c
@@ -39,6 +39,7 @@
 #include <linux/module.h>
 #include <linux/slab.h>
 
+#include <linux/bpf-cgroup.h>
 #include <linux/netfilter.h>
 #include <linux/netfilter_ipv6.h>
 
@@ -143,6 +144,7 @@ int ip6_output(struct net *net, struct sock *sk, struct sk_buff *skb)
 {
 	struct net_device *dev = skb_dst(skb)->dev;
 	struct inet6_dev *idev = ip6_dst_idev(skb_dst(skb));
+	int ret;
 
 	if (unlikely(idev->cnf.disable_ipv6)) {
 		IP6_INC_STATS(net, idev, IPSTATS_MIB_OUTDISCARDS);
@@ -150,6 +152,12 @@ int ip6_output(struct net *net, struct sock *sk, struct sk_buff *skb)
 		return 0;
 	}
 
+	ret = BPF_CGROUP_RUN_PROG_INET_EGRESS(sk, skb);
+	if (ret) {
+		kfree_skb(skb);
+		return ret;
+	}
+
 	return NF_HOOK_COND(NFPROTO_IPV6, NF_INET_POST_ROUTING,
 			    net, sk, skb, NULL, dev,
 			    ip6_finish_output,
-- 
2.7.4
