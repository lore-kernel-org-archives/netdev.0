From: Andy Zhou <azhou@nicira.com>
Subject: [patch net-next 4/4] net: refactor IPv4 and IPv6 defragmentation APIs
Date: Mon,  9 Mar 2015 01:01:38 -0700
Message-ID: <1425888098-21875-5-git-send-email-azhou@nicira.com>
References: <1425888098-21875-1-git-send-email-azhou@nicira.com>
Cc: netdev@vger.kernel.org, Andy Zhou <azhou@nicira.com>
To: davem@davemloft.net
Return-path: <netdev-owner@vger.kernel.org>
Received: from na3sys009aog116.obsmtp.com ([74.125.149.240]:51346 "HELO
	na3sys009aog116.obsmtp.com" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with SMTP id S1752742AbbCIIK6 (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 9 Mar 2015 04:10:58 -0400
Received: by mail-pa0-f46.google.com with SMTP id et14so74313259pad.0
        for <netdev@vger.kernel.org>; Mon, 09 Mar 2015 01:10:57 -0700 (PDT)
In-Reply-To: <1425888098-21875-1-git-send-email-azhou@nicira.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Both ip_defrag() and nf_ct_frag6_gather() derive the name space
information from the netdev device attached to the skb. However,
packets processed by  openvswitch may not have a netdev device.

This patch adds new ip_defrag_net() and  nf_ct_frag6_gather_net()
API that accepts net as an argument.

Signed-off-by: Andy Zhou <azhou@nicira.com>
---
 include/net/ip.h                            |  1 +
 include/net/netfilter/ipv6/nf_defrag_ipv6.h |  2 ++
 net/ipv4/ip_fragment.c                      | 15 +++++++++++----
 net/ipv6/netfilter/nf_conntrack_reasm.c     | 18 +++++++++++++-----
 4 files changed, 27 insertions(+), 9 deletions(-)

diff --git a/include/net/ip.h b/include/net/ip.h
index e73ac20..676a493 100644
--- a/include/net/ip.h
+++ b/include/net/ip.h
@@ -495,6 +495,7 @@ enum ip_defrag_users {
 };
 
 int ip_defrag(struct sk_buff *skb, u32 user);
+int ip_defrag_net(struct net *net, struct sk_buff *skb, u32 user);
 #ifdef CONFIG_INET
 struct sk_buff *ip_check_defrag(struct sk_buff *skb, u32 user);
 #else
diff --git a/include/net/netfilter/ipv6/nf_defrag_ipv6.h b/include/net/netfilter/ipv6/nf_defrag_ipv6.h
index 27666d8..bf3b9e1 100644
--- a/include/net/netfilter/ipv6/nf_defrag_ipv6.h
+++ b/include/net/netfilter/ipv6/nf_defrag_ipv6.h
@@ -6,6 +6,8 @@ void nf_defrag_ipv6_enable(void);
 int nf_ct_frag6_init(void);
 void nf_ct_frag6_cleanup(void);
 struct sk_buff *nf_ct_frag6_gather(struct sk_buff *skb, u32 user);
+struct sk_buff *nf_ct_frag6_gather_net(struct net *net, struct sk_buff *skb,
+				   u32 user);
 void nf_ct_frag6_consume_orig(struct sk_buff *skb);
 
 struct inet_frags_ctl;
diff --git a/net/ipv4/ip_fragment.c b/net/ipv4/ip_fragment.c
index 2c8d98e..fc7ae79 100644
--- a/net/ipv4/ip_fragment.c
+++ b/net/ipv4/ip_fragment.c
@@ -628,13 +628,10 @@ out_fail:
 	return err;
 }
 
-/* Process an incoming IP datagram fragment. */
-int ip_defrag(struct sk_buff *skb, u32 user)
+int ip_defrag_net(struct net *net, struct sk_buff *skb, u32 user)
 {
 	struct ipq *qp;
-	struct net *net;
 
-	net = skb->dev ? dev_net(skb->dev) : dev_net(skb_dst(skb)->dev);
 	IP_INC_STATS_BH(net, IPSTATS_MIB_REASMREQDS);
 
 	/* Lookup (or create) queue header */
@@ -654,6 +651,16 @@ int ip_defrag(struct sk_buff *skb, u32 user)
 	kfree_skb(skb);
 	return -ENOMEM;
 }
+EXPORT_SYMBOL(ip_defrag_net);
+
+/* Process an incoming IP datagram fragment. */
+int ip_defrag(struct sk_buff *skb, u32 user)
+{
+	struct net *net;
+
+	net = skb->dev ? dev_net(skb->dev) : dev_net(skb_dst(skb)->dev);
+	return ip_defrag_net(net, skb, user);
+}
 EXPORT_SYMBOL(ip_defrag);
 
 struct sk_buff *ip_check_defrag(struct sk_buff *skb, u32 user)
diff --git a/net/ipv6/netfilter/nf_conntrack_reasm.c b/net/ipv6/netfilter/nf_conntrack_reasm.c
index 6f187c8..b8ffde9 100644
--- a/net/ipv6/netfilter/nf_conntrack_reasm.c
+++ b/net/ipv6/netfilter/nf_conntrack_reasm.c
@@ -563,12 +563,10 @@ find_prev_fhdr(struct sk_buff *skb, u8 *prevhdrp, int *prevhoff, int *fhoff)
 	return 0;
 }
 
-struct sk_buff *nf_ct_frag6_gather(struct sk_buff *skb, u32 user)
+struct sk_buff *nf_ct_frag6_gather_net(struct net *net, struct sk_buff *skb,
+				       u32 user)
 {
 	struct sk_buff *clone;
-	struct net_device *dev = skb->dev;
-	struct net *net = skb_dst(skb) ? dev_net(skb_dst(skb)->dev)
-				       : dev_net(skb->dev);
 	struct frag_hdr *fhdr;
 	struct frag_queue *fq;
 	struct ipv6hdr *hdr;
@@ -620,7 +618,7 @@ struct sk_buff *nf_ct_frag6_gather(struct sk_buff *skb, u32 user)
 
 	if (fq->q.flags == (INET_FRAG_FIRST_IN | INET_FRAG_LAST_IN) &&
 	    fq->q.meat == fq->q.len) {
-		ret_skb = nf_ct_frag6_reasm(fq, dev);
+		ret_skb = nf_ct_frag6_reasm(fq, skb->dev);
 		if (ret_skb == NULL)
 			pr_debug("Can't reassemble fragmented packets\n");
 	}
@@ -633,6 +631,15 @@ ret_orig:
 	kfree_skb(clone);
 	return skb;
 }
+EXPORT_SYMBOL(nf_ct_frag6_gather_net);
+
+struct sk_buff *nf_ct_frag6_gather(struct sk_buff *skb, u32 user)
+{
+	struct net *net = skb_dst(skb) ? dev_net(skb_dst(skb)->dev)
+				       : dev_net(skb->dev);
+
+	return nf_ct_frag6_gather_net(net, skb, user);
+}
 
 void nf_ct_frag6_consume_orig(struct sk_buff *skb)
 {
@@ -645,6 +652,7 @@ void nf_ct_frag6_consume_orig(struct sk_buff *skb)
 		s = s2;
 	}
 }
+EXPORT_SYMBOL(nf_ct_frag6_consume_orig);
 
 static int nf_ct_net_init(struct net *net)
 {
-- 
1.9.1
