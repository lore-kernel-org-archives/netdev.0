From: David Ahern <dsa@cumulusnetworks.com>
Subject: [PATCH net-next 02/11] net: l3mdev: Add hook to output path
Date: Sat, 10 Sep 2016 12:09:53 -0700
Message-ID: <1473534602-23602-3-git-send-email-dsa@cumulusnetworks.com>
References: <1473534602-23602-1-git-send-email-dsa@cumulusnetworks.com>
Cc: shm@cumulusnetworks.com, David Ahern <dsa@cumulusnetworks.com>
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-pa0-f54.google.com ([209.85.220.54]:34102 "EHLO
        mail-pa0-f54.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1751537AbcIJTL1 (ORCPT
        <rfc822;netdev@vger.kernel.org>); Sat, 10 Sep 2016 15:11:27 -0400
Received: by mail-pa0-f54.google.com with SMTP id to9so38543671pac.1
        for <netdev@vger.kernel.org>; Sat, 10 Sep 2016 12:11:27 -0700 (PDT)
In-Reply-To: <1473534602-23602-1-git-send-email-dsa@cumulusnetworks.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

This patch adds the infrastructure to the output path to pass an skb
to an l3mdev device if it has a hook registered. This is the Tx parallel
to l3mdev_ip{6}_rcv in the receive path and is the basis for removing
the existing hook that returns the vrf dst on the fib lookup.

Signed-off-by: David Ahern <dsa@cumulusnetworks.com>
---
 include/net/l3mdev.h   | 48 ++++++++++++++++++++++++++++++++++++++++++++++++
 net/ipv4/ip_output.c   |  8 ++++++++
 net/ipv6/ip6_output.c  |  8 ++++++++
 net/ipv6/output_core.c |  7 +++++++
 net/ipv6/raw.c         |  7 +++++++
 5 files changed, 78 insertions(+)

diff --git a/include/net/l3mdev.h b/include/net/l3mdev.h
index 81e175e80537..53d5274920e3 100644
--- a/include/net/l3mdev.h
+++ b/include/net/l3mdev.h
@@ -11,6 +11,7 @@
 #ifndef _NET_L3MDEV_H_
 #define _NET_L3MDEV_H_
 
+#include <net/dst.h>
 #include <net/fib_rules.h>
 
 /**
@@ -18,6 +19,10 @@
  *
  * @l3mdev_fib_table: Get FIB table id to use for lookups
  *
+ * @l3mdev_l3_rcv:    Hook in L3 receive path
+ *
+ * @l3mdev_l3_out:    Hook in L3 output path
+ *
  * @l3mdev_get_rtable: Get cached IPv4 rtable (dst_entry) for device
  *
  * @l3mdev_get_saddr: Get source address for a flow
@@ -29,6 +34,9 @@ struct l3mdev_ops {
 	u32		(*l3mdev_fib_table)(const struct net_device *dev);
 	struct sk_buff * (*l3mdev_l3_rcv)(struct net_device *dev,
 					  struct sk_buff *skb, u16 proto);
+	struct sk_buff * (*l3mdev_l3_out)(struct net_device *dev,
+					  struct sock *sk, struct sk_buff *skb,
+					  u16 proto);
 
 	/* IPv4 ops */
 	struct rtable *	(*l3mdev_get_rtable)(const struct net_device *dev,
@@ -201,6 +209,34 @@ struct sk_buff *l3mdev_ip6_rcv(struct sk_buff *skb)
 	return l3mdev_l3_rcv(skb, AF_INET6);
 }
 
+static inline
+struct sk_buff *l3mdev_l3_out(struct sock *sk, struct sk_buff *skb, u16 proto)
+{
+	struct net_device *dev = skb_dst(skb)->dev;
+
+	if (netif_is_l3_slave(dev)) {
+		struct net_device *master;
+
+		master = netdev_master_upper_dev_get_rcu(dev);
+		if (master && master->l3mdev_ops->l3mdev_l3_out)
+			skb = master->l3mdev_ops->l3mdev_l3_out(master, sk,
+								skb, proto);
+	}
+
+	return skb;
+}
+
+static inline
+struct sk_buff *l3mdev_ip_out(struct sock *sk, struct sk_buff *skb)
+{
+	return l3mdev_l3_out(sk, skb, AF_INET);
+}
+
+static inline
+struct sk_buff *l3mdev_ip6_out(struct sock *sk, struct sk_buff *skb)
+{
+	return l3mdev_l3_out(sk, skb, AF_INET6);
+}
 #else
 
 static inline int l3mdev_master_ifindex_rcu(const struct net_device *dev)
@@ -287,6 +323,18 @@ struct sk_buff *l3mdev_ip6_rcv(struct sk_buff *skb)
 }
 
 static inline
+struct sk_buff *l3mdev_ip_out(struct sock *sk, struct sk_buff *skb)
+{
+	return skb;
+}
+
+static inline
+struct sk_buff *l3mdev_ip6_out(struct sock *sk, struct sk_buff *skb)
+{
+	return skb;
+}
+
+static inline
 int l3mdev_fib_rule_match(struct net *net, struct flowi *fl,
 			  struct fib_lookup_arg *arg)
 {
diff --git a/net/ipv4/ip_output.c b/net/ipv4/ip_output.c
index 65569274efb8..4f37cbaa57b2 100644
--- a/net/ipv4/ip_output.c
+++ b/net/ipv4/ip_output.c
@@ -99,6 +99,14 @@ int __ip_local_out(struct net *net, struct sock *sk, struct sk_buff *skb)
 
 	iph->tot_len = htons(skb->len);
 	ip_send_check(iph);
+
+	/* if egress device is enslaved to an L3 master device pass the
+	 * skb to its handler for processing
+	 */
+	skb = l3mdev_ip_out(sk, skb);
+	if (unlikely(!skb))
+		return 0;
+
 	return nf_hook(NFPROTO_IPV4, NF_INET_LOCAL_OUT,
 		       net, sk, skb, NULL, skb_dst(skb)->dev,
 		       dst_output);
diff --git a/net/ipv6/ip6_output.c b/net/ipv6/ip6_output.c
index 993fd9666f1b..6ea6caace3a8 100644
--- a/net/ipv6/ip6_output.c
+++ b/net/ipv6/ip6_output.c
@@ -236,6 +236,14 @@ int ip6_xmit(const struct sock *sk, struct sk_buff *skb, struct flowi6 *fl6,
 	if ((skb->len <= mtu) || skb->ignore_df || skb_is_gso(skb)) {
 		IP6_UPD_PO_STATS(net, ip6_dst_idev(skb_dst(skb)),
 			      IPSTATS_MIB_OUT, skb->len);
+
+		/* if egress device is enslaved to an L3 master device pass the
+		 * skb to its handler for processing
+		 */
+		skb = l3mdev_ip6_out((struct sock *)sk, skb);
+		if (unlikely(!skb))
+			return 0;
+
 		/* hooks should never assume socket lock is held.
 		 * we promote our socket to non const
 		 */
diff --git a/net/ipv6/output_core.c b/net/ipv6/output_core.c
index 462f2a76b5c2..7cca8ac66fe9 100644
--- a/net/ipv6/output_core.c
+++ b/net/ipv6/output_core.c
@@ -148,6 +148,13 @@ int __ip6_local_out(struct net *net, struct sock *sk, struct sk_buff *skb)
 	ipv6_hdr(skb)->payload_len = htons(len);
 	IP6CB(skb)->nhoff = offsetof(struct ipv6hdr, nexthdr);
 
+	/* if egress device is enslaved to an L3 master device pass the
+	 * skb to its handler for processing
+	 */
+	skb = l3mdev_ip6_out(sk, skb);
+	if (unlikely(!skb))
+		return 0;
+
 	return nf_hook(NFPROTO_IPV6, NF_INET_LOCAL_OUT,
 		       net, sk, skb, NULL, skb_dst(skb)->dev,
 		       dst_output);
diff --git a/net/ipv6/raw.c b/net/ipv6/raw.c
index 590dd1f7746f..54404f08efcc 100644
--- a/net/ipv6/raw.c
+++ b/net/ipv6/raw.c
@@ -653,6 +653,13 @@ static int rawv6_send_hdrinc(struct sock *sk, struct msghdr *msg, int length,
 	if (err)
 		goto error_fault;
 
+	/* if egress device is enslaved to an L3 master device pass the
+	 * skb to its handler for processing
+	 */
+	skb = l3mdev_ip6_out(sk, skb);
+	if (unlikely(!skb))
+		return 0;
+
 	IP6_UPD_PO_STATS(net, rt->rt6i_idev, IPSTATS_MIB_OUT, skb->len);
 	err = NF_HOOK(NFPROTO_IPV6, NF_INET_LOCAL_OUT, net, sk, skb,
 		      NULL, rt->dst.dev, dst_output);
-- 
2.1.4
