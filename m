From: Daniel Mack <daniel-cYrQPVfZoowdnm+yROfE0A@public.gmane.org>
Subject: [PATCH v7 5/6] net: ipv4, ipv6: run cgroup eBPF egress programs
Date: Tue, 25 Oct 2016 12:14:13 +0200
Message-ID: <1477390454-12553-6-git-send-email-daniel@zonque.org>
References: <1477390454-12553-1-git-send-email-daniel@zonque.org>
Cc: davem-fT/PcQaiUtIeIZ0/mPfg9Q@public.gmane.org, kafai-b10kYP2dOMg@public.gmane.org, fw-HFFVJYpyMKqzQB+pC5nmwQ@public.gmane.org,
        pablo-Cap9r6Oaw4JrovVCs/uTlw@public.gmane.org, harald-H+wXaHxf7aLQT0dZR+AlfA@public.gmane.org, netdev-u79uwXL29TY76Z2rM5mHXA@public.gmane.org,
        sargun-GaZTRHToo+CzQB+pC5nmwQ@public.gmane.org, cgroups-u79uwXL29TY76Z2rM5mHXA@public.gmane.org,
        Daniel Mack <daniel-cYrQPVfZoowdnm+yROfE0A@public.gmane.org>
To: htejun-b10kYP2dOMg@public.gmane.org, daniel-FeC+5ew28dpmcu3hnIyYJQ@public.gmane.org, ast-b10kYP2dOMg@public.gmane.org
Return-path: <cgroups-owner-u79uwXL29TY76Z2rM5mHXA@public.gmane.org>
In-Reply-To: <1477390454-12553-1-git-send-email-daniel-cYrQPVfZoowdnm+yROfE0A@public.gmane.org>
Sender: cgroups-owner-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
List-Id: netdev.vger.kernel.org

If the cgroup associated with the receiving socket has an eBPF
programs installed, run them from ip_output(), ip6_output() and
ip_mc_output().

eBPF programs used in this context are expected to either return 1 to
let the packet pass, or != 1 to drop them. The programs have access to
the skb through bpf_skb_load_bytes(), and the payload starts at the
network headers (L3).

Note that cgroup_bpf_run_filter() is stubbed out as static inline nop
for !CONFIG_CGROUP_BPF, and is otherwise guarded by a static key if
the feature is unused.

Signed-off-by: Daniel Mack <daniel-cYrQPVfZoowdnm+yROfE0A@public.gmane.org>
Acked-by: Alexei Starovoitov <ast-DgEjT+Ai2ygdnm+yROfE0A@public.gmane.org>
---
 net/ipv4/ip_output.c  | 17 +++++++++++++++++
 net/ipv6/ip6_output.c |  9 +++++++++
 2 files changed, 26 insertions(+)

diff --git a/net/ipv4/ip_output.c b/net/ipv4/ip_output.c
index 05d1058..ee4b249 100644
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
@@ -312,6 +314,13 @@ int ip_mc_output(struct net *net, struct sock *sk, struct sk_buff *skb)
 	skb->dev = dev;
 	skb->protocol = htons(ETH_P_IP);
 
+	ret = cgroup_bpf_run_filter(sk_to_full_sk(sk), skb,
+				    BPF_CGROUP_INET_EGRESS);
+	if (ret) {
+		kfree_skb(skb);
+		return ret;
+	}
+
 	/*
 	 *	Multicasts are looped back for other local users
 	 */
@@ -364,12 +373,20 @@ int ip_mc_output(struct net *net, struct sock *sk, struct sk_buff *skb)
 int ip_output(struct net *net, struct sock *sk, struct sk_buff *skb)
 {
 	struct net_device *dev = skb_dst(skb)->dev;
+	int ret;
 
 	IP_UPD_PO_STATS(net, IPSTATS_MIB_OUT, skb->len);
 
 	skb->dev = dev;
 	skb->protocol = htons(ETH_P_IP);
 
+	ret = cgroup_bpf_run_filter(sk_to_full_sk(sk), skb,
+				    BPF_CGROUP_INET_EGRESS);
+	if (ret) {
+		kfree_skb(skb);
+		return ret;
+	}
+
 	return NF_HOOK_COND(NFPROTO_IPV4, NF_INET_POST_ROUTING,
 			    net, sk, skb, NULL, dev,
 			    ip_finish_output,
diff --git a/net/ipv6/ip6_output.c b/net/ipv6/ip6_output.c
index 6001e78..1947026 100644
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
@@ -150,6 +152,13 @@ int ip6_output(struct net *net, struct sock *sk, struct sk_buff *skb)
 		return 0;
 	}
 
+	ret = cgroup_bpf_run_filter(sk_to_full_sk(sk), skb,
+				    BPF_CGROUP_INET_EGRESS);
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
