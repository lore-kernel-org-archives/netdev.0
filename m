From: Andy Zhou <azhou@nicira.com>
Subject: [net-next fragmentation icmp v5 3/3] bridge_netfilter: No ICMP packet on IPv4 fragmentation error
Date: Fri, 15 May 2015 14:15:37 -0700
Message-ID: <1431724537-1919-4-git-send-email-azhou@nicira.com>
References: <1431724537-1919-1-git-send-email-azhou@nicira.com>
Cc: netdev@vger.kernel.org, Andy Zhou <azhou@nicira.com>
To: davem@davemloft.net
Return-path: <netdev-owner@vger.kernel.org>
Received: from na3sys009aog104.obsmtp.com ([74.125.149.73]:34513 "HELO
	na3sys009aog104.obsmtp.com" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with SMTP id S1946142AbbEOVhH (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 15 May 2015 17:37:07 -0400
Received: by mail-pa0-f51.google.com with SMTP id bw4so29636316pad.0
        for <netdev@vger.kernel.org>; Fri, 15 May 2015 14:37:07 -0700 (PDT)
In-Reply-To: <1431724537-1919-1-git-send-email-azhou@nicira.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

When bridge netfilter re-fragments an IP packet for output, all
packets that can not be re-fragmented to their original input size
should be silently discarded.

However, current bridge netfilter output path generates an ICMP packet
with 'size exceeded MTU' message for such packets, this is a bug.

This patch refactors the ip_fragment() API to allow two separate
use cases. The bridge netfilter user case will not
send ICMP, the routing output will, as before.

Signed-off-by: Andy Zhou <azhou@nicira.com>
---
 include/net/ip.h          |  4 ++--
 net/bridge/br_netfilter.c | 21 ++++++++++++++++++++-
 net/ipv4/ip_output.c      | 40 ++++++++++++++++++++++++++++------------
 3 files changed, 50 insertions(+), 15 deletions(-)

diff --git a/include/net/ip.h b/include/net/ip.h
index 43f6f39..cd7a6a4 100644
--- a/include/net/ip.h
+++ b/include/net/ip.h
@@ -108,8 +108,8 @@ int ip_local_deliver(struct sk_buff *skb);
 int ip_mr_input(struct sk_buff *skb);
 int ip_output(struct sock *sk, struct sk_buff *skb);
 int ip_mc_output(struct sock *sk, struct sk_buff *skb);
-int ip_fragment(struct sock *sk, struct sk_buff *skb,
-		int (*output)(struct sock *, struct sk_buff *));
+int ip_do_fragment(struct sock *sk, struct sk_buff *skb,
+		   int (*output)(struct sock *, struct sk_buff *));
 int ip_do_nat(struct sk_buff *skb);
 void ip_send_check(struct iphdr *ip);
 int __ip_local_out(struct sk_buff *skb);
diff --git a/net/bridge/br_netfilter.c b/net/bridge/br_netfilter.c
index ab55e24..3f30645 100644
--- a/net/bridge/br_netfilter.c
+++ b/net/bridge/br_netfilter.c
@@ -844,6 +844,25 @@ static int br_nf_push_frag_xmit(struct sock *sk, struct sk_buff *skb)
 	return br_dev_queue_push_xmit(sk, skb);
 }
 
+static int br_nf_ip_fragment(struct sock *sk, struct sk_buff *skb,
+			     int (*output)(struct sock *, struct sk_buff *))
+{
+	unsigned int mtu = ip_skb_dst_mtu(skb);
+	struct iphdr *iph = ip_hdr(skb);
+	struct rtable *rt = skb_rtable(skb);
+	struct net_device *dev = rt->dst.dev;
+
+	if (unlikely(((iph->frag_off & htons(IP_DF)) && !skb->ignore_df) ||
+		     (IPCB(skb)->frag_max_size &&
+		      IPCB(skb)->frag_max_size > mtu))) {
+		IP_INC_STATS(dev_net(dev), IPSTATS_MIB_FRAGFAILS);
+		kfree_skb(skb);
+		return -EMSGSIZE;
+	}
+
+	return ip_do_fragment(sk, skb, output);
+}
+
 static int br_nf_dev_queue_xmit(struct sock *sk, struct sk_buff *skb)
 {
 	int ret;
@@ -875,7 +894,7 @@ static int br_nf_dev_queue_xmit(struct sock *sk, struct sk_buff *skb)
 		skb_copy_from_linear_data_offset(skb, -data->size, data->mac,
 						 data->size);
 
-		ret = ip_fragment(sk, skb, br_nf_push_frag_xmit);
+		ret = br_nf_ip_fragment(sk, skb, br_nf_push_frag_xmit);
 	} else {
 		ret = br_dev_queue_push_xmit(sk, skb);
 	}
diff --git a/net/ipv4/ip_output.c b/net/ipv4/ip_output.c
index 2acc5dc..8d91b92 100644
--- a/net/ipv4/ip_output.c
+++ b/net/ipv4/ip_output.c
@@ -83,6 +83,9 @@
 int sysctl_ip_default_ttl __read_mostly = IPDEFTTL;
 EXPORT_SYMBOL(sysctl_ip_default_ttl);
 
+static int ip_fragment(struct sock *sk, struct sk_buff *skb,
+		       int (*output)(struct sock *, struct sk_buff *));
+
 /* Generate a checksum for an outgoing IP datagram. */
 void ip_send_check(struct iphdr *iph)
 {
@@ -478,6 +481,28 @@ static void ip_copy_metadata(struct sk_buff *to, struct sk_buff *from)
 	skb_copy_secmark(to, from);
 }
 
+static int ip_fragment(struct sock *sk, struct sk_buff *skb,
+		       int (*output)(struct sock *, struct sk_buff *))
+{
+	struct iphdr *iph = ip_hdr(skb);
+	unsigned int mtu = ip_skb_dst_mtu(skb);
+
+	if (unlikely(((iph->frag_off & htons(IP_DF)) && !skb->ignore_df) ||
+		     (IPCB(skb)->frag_max_size &&
+		      IPCB(skb)->frag_max_size > mtu))) {
+		struct rtable *rt = skb_rtable(skb);
+		struct net_device *dev = rt->dst.dev;
+
+		IP_INC_STATS(dev_net(dev), IPSTATS_MIB_FRAGFAILS);
+		icmp_send(skb, ICMP_DEST_UNREACH, ICMP_FRAG_NEEDED,
+			  htonl(mtu));
+		kfree_skb(skb);
+		return -EMSGSIZE;
+	}
+
+	return ip_do_fragment(sk, skb, output);
+}
+
 /*
  *	This IP datagram is too large to be sent in one piece.  Break it up into
  *	smaller pieces (each of size equal to IP header plus
@@ -485,8 +510,8 @@ static void ip_copy_metadata(struct sk_buff *to, struct sk_buff *from)
  *	single device frame, and queue such a frame for sending.
  */
 
-int ip_fragment(struct sock *sk, struct sk_buff *skb,
-		int (*output)(struct sock *, struct sk_buff *))
+int ip_do_fragment(struct sock *sk, struct sk_buff *skb,
+		   int (*output)(struct sock *, struct sk_buff *))
 {
 	struct iphdr *iph;
 	int ptr;
@@ -507,15 +532,6 @@ int ip_fragment(struct sock *sk, struct sk_buff *skb,
 	iph = ip_hdr(skb);
 
 	mtu = ip_skb_dst_mtu(skb);
-	if (unlikely(((iph->frag_off & htons(IP_DF)) && !skb->ignore_df) ||
-		     (IPCB(skb)->frag_max_size &&
-		      IPCB(skb)->frag_max_size > mtu))) {
-		IP_INC_STATS(dev_net(dev), IPSTATS_MIB_FRAGFAILS);
-		icmp_send(skb, ICMP_DEST_UNREACH, ICMP_FRAG_NEEDED,
-			  htonl(mtu));
-		kfree_skb(skb);
-		return -EMSGSIZE;
-	}
 
 	/*
 	 *	Setup starting values.
@@ -751,7 +767,7 @@ fail:
 	IP_INC_STATS(dev_net(dev), IPSTATS_MIB_FRAGFAILS);
 	return err;
 }
-EXPORT_SYMBOL(ip_fragment);
+EXPORT_SYMBOL(ip_do_fragment);
 
 int
 ip_generic_getfrag(void *from, char *to, int offset, int len, int odd, struct sk_buff *skb)
-- 
1.9.1
