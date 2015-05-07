From: Andy Zhou <azhou@nicira.com>
Subject: [net-next fragmenation icmp v2 2/2] bridge_netfilter: No ICMP packet on IPv4 fragmentation error
Date: Wed,  6 May 2015 18:27:13 -0700
Message-ID: <1430962033-16141-3-git-send-email-azhou@nicira.com>
References: <1430962033-16141-1-git-send-email-azhou@nicira.com>
Cc: netdev@vger.kernel.org, Andy Zhou <azhou@nicira.com>
To: davem@davemloft.net
Return-path: <netdev-owner@vger.kernel.org>
Received: from na3sys009aog133.obsmtp.com ([74.125.149.82]:48702 "HELO
	na3sys009aog133.obsmtp.com" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with SMTP id S1750824AbbEGBtC (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 6 May 2015 21:49:02 -0400
Received: by mail-pd0-f173.google.com with SMTP id nk13so26272903pdb.0
        for <netdev@vger.kernel.org>; Wed, 06 May 2015 18:49:01 -0700 (PDT)
In-Reply-To: <1430962033-16141-1-git-send-email-azhou@nicira.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

When bridge netfilter re-fragments an IP packet for output, it should
silently discard the packet if it can not be re-fragmented to its
original input size.

Current code has two issues. 1) In bridge netfilter use cases, it
generates ICMP packets that is not desirable. 2) In normal routing
use cases, check for max input fragmentation size is not necessary.

This patch refactors the ip_fragment() API, and fixes both issues.

Signed-off-by: Andy Zhou <azhou@nicira.com>
---
 include/net/ip.h          |  2 ++
 net/bridge/br_netfilter.c | 21 ++++++++++++++++++++-
 net/ipv4/ip_output.c      | 36 ++++++++++++++++++++++++------------
 3 files changed, 46 insertions(+), 13 deletions(-)

diff --git a/include/net/ip.h b/include/net/ip.h
index 8d81c865..ffd9a99 100644
--- a/include/net/ip.h
+++ b/include/net/ip.h
@@ -111,6 +111,8 @@ int ip_output(struct sock *sk, struct sk_buff *skb);
 int ip_mc_output(struct sock *sk, struct sk_buff *skb);
 int ip_fragment(struct sock *sk, struct sk_buff *skb,
 		int (*output)(struct sock *, struct sk_buff *));
+int ip_do_fragment(struct sock *sk, struct sk_buff *skb,
+		   int (*output)(struct sock *, struct sk_buff *));
 int ip_do_nat(struct sk_buff *skb);
 void ip_send_check(struct iphdr *ip);
 int __ip_local_out(struct sk_buff *skb);
diff --git a/net/bridge/br_netfilter.c b/net/bridge/br_netfilter.c
index e5cfca4..908675d 100644
--- a/net/bridge/br_netfilter.c
+++ b/net/bridge/br_netfilter.c
@@ -848,6 +848,25 @@ static int br_nf_push_frag_xmit(struct sock *sk, struct sk_buff *skb)
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
@@ -879,7 +898,7 @@ static int br_nf_dev_queue_xmit(struct sock *sk, struct sk_buff *skb)
 		skb_copy_from_linear_data_offset(skb, -data->size, data->mac,
 						 data->size);
 
-		ret = ip_fragment(sk, skb, br_nf_push_frag_xmit);
+		ret = br_nf_ip_fragment(sk, skb, br_nf_push_frag_xmit);
 	} else {
 		ret = br_dev_queue_push_xmit(sk, skb);
 	}
diff --git a/net/ipv4/ip_output.c b/net/ipv4/ip_output.c
index c65b93a..aa90ca0 100644
--- a/net/ipv4/ip_output.c
+++ b/net/ipv4/ip_output.c
@@ -478,6 +478,27 @@ static void ip_copy_metadata(struct sk_buff *to, struct sk_buff *from)
 	skb_copy_secmark(to, from);
 }
 
+int ip_fragment(struct sock *sk, struct sk_buff *skb,
+		int (*output)(struct sock *, struct sk_buff *))
+{
+	struct iphdr *iph = ip_hdr(skb);
+
+	if (unlikely(((iph->frag_off & htons(IP_DF)) && !skb->ignore_df))) {
+		unsigned int mtu = ip_skb_dst_mtu(skb);
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
+EXPORT_SYMBOL(ip_fragment);
+
 /*
  *	This IP datagram is too large to be sent in one piece.  Break it up into
  *	smaller pieces (each of size equal to IP header plus
@@ -485,8 +506,8 @@ static void ip_copy_metadata(struct sk_buff *to, struct sk_buff *from)
  *	single device frame, and queue such a frame for sending.
  */
 
-int ip_fragment(struct sock *sk, struct sk_buff *skb,
-		int (*output)(struct sock *, struct sk_buff *))
+int ip_do_fragment(struct sock *sk, struct sk_buff *skb,
+		   int (*output)(struct sock *, struct sk_buff *))
 {
 	struct iphdr *iph;
 	int ptr;
@@ -507,15 +528,6 @@ int ip_fragment(struct sock *sk, struct sk_buff *skb,
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
@@ -751,7 +763,7 @@ fail:
 	IP_INC_STATS(dev_net(dev), IPSTATS_MIB_FRAGFAILS);
 	return err;
 }
-EXPORT_SYMBOL(ip_fragment);
+EXPORT_SYMBOL(ip_do_fragment);
 
 int
 ip_generic_getfrag(void *from, char *to, int offset, int len, int odd, struct sk_buff *skb)
-- 
1.9.1
