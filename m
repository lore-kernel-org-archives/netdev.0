From: Herbert Xu <herbert@gondor.apana.org.au>
Subject: [PATCH 9/10] [NETFILTER]: Avoid skb_copy/pskb_copy/skb_realloc_headroom
Date: Sun, 14 Oct 2007 12:27:47 +0800
Message-ID: <E1Igv4t-000319-00@gondolin.me.apana.org.au>
References: <20071014042604.GA11431@gondor.apana.org.au>
To: Patrick McHardy <kaber@trash.net>,
	David Miller <davem@davemloft.net>, hadi@cyberus.ca,
	netdev@vger.kernel.org, kuznet@ms2.inr.ac.ru,
	Herbert Xu <herbert@gondor.apana.org.au>
Return-path: <netdev-owner@vger.kernel.org>
Received: from rhun.apana.org.au ([64.62.148.172]:1426 "EHLO
	arnor.apana.org.au" rhost-flags-OK-OK-OK-FAIL) by vger.kernel.org
	with ESMTP id S1752025AbXJNE2R (ORCPT
	<rfc822;netdev@vger.kernel.org>); Sun, 14 Oct 2007 00:28:17 -0400
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

[NETFILTER]: Avoid skb_copy/pskb_copy/skb_realloc_headroom

This patch replaces unnecessary uses of skb_copy, pskb_copy and
skb_realloc_headroom by functions such as skb_make_writable and
pskb_expand_head.

This allows us to remove the double pointers later.

Signed-off-by: Herbert Xu <herbert@gondor.apana.org.au>
---

 net/bridge/netfilter/ebt_dnat.c     |   13 +++----------
 net/bridge/netfilter/ebt_redirect.c |   13 +++----------
 net/bridge/netfilter/ebt_snat.c     |   13 +++----------
 net/ipv4/netfilter.c                |   31 +++++++++----------------------
 net/ipv4/netfilter/arpt_mangle.c    |   14 +++-----------
 net/ipv4/netfilter/ip_queue.c       |   22 ++++++++--------------
 net/ipv4/netfilter/nf_nat_helper.c  |   10 +---------
 net/ipv6/netfilter/ip6_queue.c      |   18 ++++++------------
 net/netfilter/nfnetlink_queue.c     |   18 ++++++------------
 net/netfilter/xt_TCPMSS.c           |   10 +++-------
 10 files changed, 45 insertions(+), 117 deletions(-)

diff --git a/net/bridge/netfilter/ebt_dnat.c b/net/bridge/netfilter/ebt_dnat.c
index 4582659..9d74dee 100644
--- a/net/bridge/netfilter/ebt_dnat.c
+++ b/net/bridge/netfilter/ebt_dnat.c
@@ -8,6 +8,7 @@
  *
  */
 
+#include <linux/netfilter.h>
 #include <linux/netfilter_bridge/ebtables.h>
 #include <linux/netfilter_bridge/ebt_nat.h>
 #include <linux/module.h>
@@ -19,17 +20,9 @@ static int ebt_target_dnat(struct sk_buff **pskb, unsigned int hooknr,
 {
 	struct ebt_nat_info *info = (struct ebt_nat_info *)data;
 
-	if (skb_shared(*pskb) || skb_cloned(*pskb)) {
-		struct sk_buff *nskb;
+	if (skb_make_writable(*pskb, 0))
+		return NF_DROP;
 
-		nskb = skb_copy(*pskb, GFP_ATOMIC);
-		if (!nskb)
-			return NF_DROP;
-		if ((*pskb)->sk)
-			skb_set_owner_w(nskb, (*pskb)->sk);
-		kfree_skb(*pskb);
-		*pskb = nskb;
-	}
 	memcpy(eth_hdr(*pskb)->h_dest, info->mac, ETH_ALEN);
 	return info->target;
 }
diff --git a/net/bridge/netfilter/ebt_redirect.c b/net/bridge/netfilter/ebt_redirect.c
index 9f378ea..81371cd 100644
--- a/net/bridge/netfilter/ebt_redirect.c
+++ b/net/bridge/netfilter/ebt_redirect.c
@@ -8,6 +8,7 @@
  *
  */
 
+#include <linux/netfilter.h>
 #include <linux/netfilter_bridge/ebtables.h>
 #include <linux/netfilter_bridge/ebt_redirect.h>
 #include <linux/module.h>
@@ -20,17 +21,9 @@ static int ebt_target_redirect(struct sk_buff **pskb, unsigned int hooknr,
 {
 	struct ebt_redirect_info *info = (struct ebt_redirect_info *)data;
 
-	if (skb_shared(*pskb) || skb_cloned(*pskb)) {
-		struct sk_buff *nskb;
+	if (skb_make_writable(*pskb, 0))
+		return NF_DROP;
 
-		nskb = skb_copy(*pskb, GFP_ATOMIC);
-		if (!nskb)
-			return NF_DROP;
-		if ((*pskb)->sk)
-			skb_set_owner_w(nskb, (*pskb)->sk);
-		kfree_skb(*pskb);
-		*pskb = nskb;
-	}
 	if (hooknr != NF_BR_BROUTING)
 		memcpy(eth_hdr(*pskb)->h_dest,
 		       in->br_port->br->dev->dev_addr, ETH_ALEN);
diff --git a/net/bridge/netfilter/ebt_snat.c b/net/bridge/netfilter/ebt_snat.c
index a507221..b0c6368 100644
--- a/net/bridge/netfilter/ebt_snat.c
+++ b/net/bridge/netfilter/ebt_snat.c
@@ -8,6 +8,7 @@
  *
  */
 
+#include <linux/netfilter.h>
 #include <linux/netfilter_bridge/ebtables.h>
 #include <linux/netfilter_bridge/ebt_nat.h>
 #include <linux/module.h>
@@ -21,17 +22,9 @@ static int ebt_target_snat(struct sk_buff **pskb, unsigned int hooknr,
 {
 	struct ebt_nat_info *info = (struct ebt_nat_info *) data;
 
-	if (skb_shared(*pskb) || skb_cloned(*pskb)) {
-		struct sk_buff *nskb;
+	if (skb_make_writable(*pskb, 0))
+		return NF_DROP;
 
-		nskb = skb_copy(*pskb, GFP_ATOMIC);
-		if (!nskb)
-			return NF_DROP;
-		if ((*pskb)->sk)
-			skb_set_owner_w(nskb, (*pskb)->sk);
-		kfree_skb(*pskb);
-		*pskb = nskb;
-	}
 	memcpy(eth_hdr(*pskb)->h_source, info->mac, ETH_ALEN);
 	if (!(info->target & NAT_ARP_BIT) &&
 	    eth_hdr(*pskb)->h_proto == htons(ETH_P_ARP)) {
diff --git a/net/ipv4/netfilter.c b/net/ipv4/netfilter.c
index b441929..d1e3012 100644
--- a/net/ipv4/netfilter.c
+++ b/net/ipv4/netfilter.c
@@ -3,6 +3,7 @@
 #include <linux/netfilter.h>
 #include <linux/netfilter_ipv4.h>
 #include <linux/ip.h>
+#include <linux/skbuff.h>
 #include <net/route.h>
 #include <net/xfrm.h>
 #include <net/ip.h>
@@ -66,17 +67,10 @@ int ip_route_me_harder(struct sk_buff **pskb, unsigned addr_type)
 
 	/* Change in oif may mean change in hh_len. */
 	hh_len = (*pskb)->dst->dev->hard_header_len;
-	if (skb_headroom(*pskb) < hh_len) {
-		struct sk_buff *nskb;
-
-		nskb = skb_realloc_headroom(*pskb, hh_len);
-		if (!nskb)
-			return -1;
-		if ((*pskb)->sk)
-			skb_set_owner_w(nskb, (*pskb)->sk);
-		kfree_skb(*pskb);
-		*pskb = nskb;
-	}
+	if (skb_headroom(*pskb) < hh_len &&
+	    pskb_expand_head(*pskb, hh_len - skb_headroom(*pskb), 0,
+			     GFP_ATOMIC))
+		return -1;
 
 	return 0;
 }
@@ -107,17 +101,10 @@ int ip_xfrm_me_harder(struct sk_buff **pskb)
 
 	/* Change in oif may mean change in hh_len. */
 	hh_len = (*pskb)->dst->dev->hard_header_len;
-	if (skb_headroom(*pskb) < hh_len) {
-		struct sk_buff *nskb;
-
-		nskb = skb_realloc_headroom(*pskb, hh_len);
-		if (!nskb)
-			return -1;
-		if ((*pskb)->sk)
-			skb_set_owner_w(nskb, (*pskb)->sk);
-		kfree_skb(*pskb);
-		*pskb = nskb;
-	}
+	if (skb_headroom(*pskb) < hh_len &&
+	    pskb_expand_head(*pskb, hh_len - skb_headroom(*pskb), 0,
+			     GFP_ATOMIC))
+		return -1;
 	return 0;
 }
 EXPORT_SYMBOL(ip_xfrm_me_harder);
diff --git a/net/ipv4/netfilter/arpt_mangle.c b/net/ipv4/netfilter/arpt_mangle.c
index c4bdab4..0181f91 100644
--- a/net/ipv4/netfilter/arpt_mangle.c
+++ b/net/ipv4/netfilter/arpt_mangle.c
@@ -1,5 +1,6 @@
 /* module that allows mangling of the arp payload */
 #include <linux/module.h>
+#include <linux/netfilter.h>
 #include <linux/netfilter_arp/arpt_mangle.h>
 #include <net/sock.h>
 
@@ -18,17 +19,8 @@ target(struct sk_buff **pskb,
 	unsigned char *arpptr;
 	int pln, hln;
 
-	if (skb_shared(*pskb) || skb_cloned(*pskb)) {
-		struct sk_buff *nskb;
-
-		nskb = skb_copy(*pskb, GFP_ATOMIC);
-		if (!nskb)
-			return NF_DROP;
-		if ((*pskb)->sk)
-			skb_set_owner_w(nskb, (*pskb)->sk);
-		kfree_skb(*pskb);
-		*pskb = nskb;
-	}
+	if (skb_make_writable(*pskb, (*pskb)->len))
+		return NF_DROP;
 
 	arp = arp_hdr(*pskb);
 	arpptr = skb_network_header(*pskb) + sizeof(*arp);
diff --git a/net/ipv4/netfilter/ip_queue.c b/net/ipv4/netfilter/ip_queue.c
index 62d8867..10a2ce0 100644
--- a/net/ipv4/netfilter/ip_queue.c
+++ b/net/ipv4/netfilter/ip_queue.c
@@ -335,6 +335,7 @@ static int
 ipq_mangle_ipv4(ipq_verdict_msg_t *v, struct ipq_queue_entry *e)
 {
 	int diff;
+	int err;
 	struct iphdr *user_iph = (struct iphdr *)v->payload;
 
 	if (v->data_len < sizeof(*user_iph))
@@ -347,21 +348,14 @@ ipq_mangle_ipv4(ipq_verdict_msg_t *v, struct ipq_queue_entry *e)
 		if (v->data_len > 0xFFFF)
 			return -EINVAL;
 		if (diff > skb_tailroom(e->skb)) {
-			struct sk_buff *newskb;
-
-			newskb = skb_copy_expand(e->skb,
-						 skb_headroom(e->skb),
-						 diff,
-						 GFP_ATOMIC);
-			if (newskb == NULL) {
-				printk(KERN_WARNING "ip_queue: OOM "
-				      "in mangle, dropping packet\n");
-				return -ENOMEM;
+			err = pskb_expand_head(e->skb, 0,
+					       diff - skb_tailroom(e->skb),
+					       GFP_ATOMIC);
+			if (err) {
+				printk(KERN_WARNING "ip_queue: error "
+				      "in mangle, dropping packet: %d\n", -err);
+				return err;
 			}
-			if (e->skb->sk)
-				skb_set_owner_w(newskb, e->skb->sk);
-			kfree_skb(e->skb);
-			e->skb = newskb;
 		}
 		skb_put(e->skb, diff);
 	}
diff --git a/net/ipv4/netfilter/nf_nat_helper.c b/net/ipv4/netfilter/nf_nat_helper.c
index 6e81f76..40b429e 100644
--- a/net/ipv4/netfilter/nf_nat_helper.c
+++ b/net/ipv4/netfilter/nf_nat_helper.c
@@ -113,20 +113,12 @@ static void mangle_contents(struct sk_buff *skb,
 /* Unusual, but possible case. */
 static int enlarge_skb(struct sk_buff **pskb, unsigned int extra)
 {
-	struct sk_buff *nskb;
-
 	if ((*pskb)->len + extra > 65535)
 		return 0;
 
-	nskb = skb_copy_expand(*pskb, skb_headroom(*pskb), extra, GFP_ATOMIC);
-	if (!nskb)
+	if (pskb_expand_head(*pskb, 0, extra - skb_tailroom(*pskb), GFP_ATOMIC))
 		return 0;
 
-	/* Transfer socket to new skb. */
-	if ((*pskb)->sk)
-		skb_set_owner_w(nskb, (*pskb)->sk);
-	kfree_skb(*pskb);
-	*pskb = nskb;
 	return 1;
 }
 
diff --git a/net/ipv6/netfilter/ip6_queue.c b/net/ipv6/netfilter/ip6_queue.c
index d7080dd..6413a30 100644
--- a/net/ipv6/netfilter/ip6_queue.c
+++ b/net/ipv6/netfilter/ip6_queue.c
@@ -332,6 +332,7 @@ static int
 ipq_mangle_ipv6(ipq_verdict_msg_t *v, struct ipq_queue_entry *e)
 {
 	int diff;
+	int err;
 	struct ipv6hdr *user_iph = (struct ipv6hdr *)v->payload;
 
 	if (v->data_len < sizeof(*user_iph))
@@ -344,21 +345,14 @@ ipq_mangle_ipv6(ipq_verdict_msg_t *v, struct ipq_queue_entry *e)
 		if (v->data_len > 0xFFFF)
 			return -EINVAL;
 		if (diff > skb_tailroom(e->skb)) {
-			struct sk_buff *newskb;
-
-			newskb = skb_copy_expand(e->skb,
-						 skb_headroom(e->skb),
-						 diff,
-						 GFP_ATOMIC);
-			if (newskb == NULL) {
+			err = pskb_expand_head(e->skb, 0,
+					       diff - skb_tailroom(e->skb),
+					       GFP_ATOMIC);
+			if (err) {
 				printk(KERN_WARNING "ip6_queue: OOM "
 				      "in mangle, dropping packet\n");
-				return -ENOMEM;
+				return err;
 			}
-			if (e->skb->sk)
-				skb_set_owner_w(newskb, e->skb->sk);
-			kfree_skb(e->skb);
-			e->skb = newskb;
 		}
 		skb_put(e->skb, diff);
 	}
diff --git a/net/netfilter/nfnetlink_queue.c b/net/netfilter/nfnetlink_queue.c
index 6ba98ac..3ceeffc 100644
--- a/net/netfilter/nfnetlink_queue.c
+++ b/net/netfilter/nfnetlink_queue.c
@@ -617,6 +617,7 @@ static int
 nfqnl_mangle(void *data, int data_len, struct nfqnl_queue_entry *e)
 {
 	int diff;
+	int err;
 
 	diff = data_len - e->skb->len;
 	if (diff < 0) {
@@ -626,21 +627,14 @@ nfqnl_mangle(void *data, int data_len, struct nfqnl_queue_entry *e)
 		if (data_len > 0xFFFF)
 			return -EINVAL;
 		if (diff > skb_tailroom(e->skb)) {
-			struct sk_buff *newskb;
-
-			newskb = skb_copy_expand(e->skb,
-						 skb_headroom(e->skb),
-						 diff,
-						 GFP_ATOMIC);
-			if (newskb == NULL) {
+			err = pskb_expand_head(e->skb, 0,
+					       diff - skb_tailroom(e->skb),
+					       GFP_ATOMIC);
+			if (err) {
 				printk(KERN_WARNING "nf_queue: OOM "
 				      "in mangle, dropping packet\n");
-				return -ENOMEM;
+				return err;
 			}
-			if (e->skb->sk)
-				skb_set_owner_w(newskb, e->skb->sk);
-			kfree_skb(e->skb);
-			e->skb = newskb;
 		}
 		skb_put(e->skb, diff);
 	}
diff --git a/net/netfilter/xt_TCPMSS.c b/net/netfilter/xt_TCPMSS.c
index 31b6f9d..f111edf 100644
--- a/net/netfilter/xt_TCPMSS.c
+++ b/net/netfilter/xt_TCPMSS.c
@@ -105,14 +105,10 @@ tcpmss_mangle_packet(struct sk_buff **pskb,
 	 * MSS Option not found ?! add it..
 	 */
 	if (skb_tailroom((*pskb)) < TCPOLEN_MSS) {
-		struct sk_buff *newskb;
-
-		newskb = skb_copy_expand(*pskb, skb_headroom(*pskb),
-					 TCPOLEN_MSS, GFP_ATOMIC);
-		if (!newskb)
+		if (pskb_expand_head(*pskb, 0,
+				     TCPOLEN_MSS - skb_tailroom(*pskb),
+				     GFP_ATOMIC))
 			return -1;
-		kfree_skb(*pskb);
-		*pskb = newskb;
 		tcph = (struct tcphdr *)(skb_network_header(*pskb) + tcphoff);
 	}
 
