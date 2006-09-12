From: Al Viro <viro@ftp.linux.org.uk>
Subject: ipip and ip_gre encapsulation bugs
Date: Tue, 12 Sep 2006 17:50:58 +0100
Message-ID: <E1GNBTO-0001v7-Pb@ZenIV.linux.org.uk>
Cc: torvalds@osdl.org, netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from zeniv.linux.org.uk ([195.92.253.2]:14539 "EHLO
	ZenIV.linux.org.uk") by vger.kernel.org with ESMTP id S1030284AbWILQu7
	(ORCPT <rfc822;netdev@vger.kernel.org>);
	Tue, 12 Sep 2006 12:50:59 -0400
To: davem@davemloft.net
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Handling of ipip and ip_gre ICMP error relaying is b0rken; it accesses
32bit net-endian field as host-endian, does comparison, subtraction and
stuffs the result to 32bit net-endian.  Without any conversions.

Fixed, made endian-clean.

Signed-off-by: Al Viro <viro@zeniv.linux.org.uk>
----

diff --git a/net/ipv4/ip_gre.c b/net/ipv4/ip_gre.c
index 0f9b3a3..b9dd2f0 100644
--- a/net/ipv4/ip_gre.c
+++ b/net/ipv4/ip_gre.c
@@ -393,7 +393,8 @@ #else
 	int code = skb->h.icmph->code;
 	int rel_type = 0;
 	int rel_code = 0;
-	int rel_info = 0;
+	__be32 rel_info = 0;
+	__u32 n = 0;
 	u16 flags;
 	int grehlen = (iph->ihl<<2) + 4;
 	struct sk_buff *skb2;
@@ -422,14 +423,16 @@ #else
 	default:
 		return;
 	case ICMP_PARAMETERPROB:
-		if (skb->h.icmph->un.gateway < (iph->ihl<<2))
+		n = ntohl(skb->h.icmph->un.gateway);
+		if (n < (iph->ihl<<2))
 			return;
 
 		/* So... This guy found something strange INSIDE encapsulated
 		   packet. Well, he is fool, but what can we do ?
 		 */
 		rel_type = ICMP_PARAMETERPROB;
-		rel_info = skb->h.icmph->un.gateway - grehlen;
+		n -= grehlen;
+		rel_info = htonl(n);
 		break;
 
 	case ICMP_DEST_UNREACH:
@@ -440,13 +443,14 @@ #else
 			return;
 		case ICMP_FRAG_NEEDED:
 			/* And it is the only really necessary thing :-) */
-			rel_info = ntohs(skb->h.icmph->un.frag.mtu);
-			if (rel_info < grehlen+68)
+			n = ntohs(skb->h.icmph->un.frag.mtu);
+			if (n < grehlen+68)
 				return;
-			rel_info -= grehlen;
+			n -= grehlen;
 			/* BSD 4.2 MORE DOES NOT EXIST IN NATURE. */
-			if (rel_info > ntohs(eiph->tot_len))
+			if (n > ntohs(eiph->tot_len))
 				return;
+			rel_info = htonl(n);
 			break;
 		default:
 			/* All others are translated to HOST_UNREACH.
@@ -508,12 +512,11 @@ #else
 
 	/* change mtu on this route */
 	if (type == ICMP_DEST_UNREACH && code == ICMP_FRAG_NEEDED) {
-		if (rel_info > dst_mtu(skb2->dst)) {
+		if (n > dst_mtu(skb2->dst)) {
 			kfree_skb(skb2);
 			return;
 		}
-		skb2->dst->ops->update_pmtu(skb2->dst, rel_info);
-		rel_info = htonl(rel_info);
+		skb2->dst->ops->update_pmtu(skb2->dst, n);
 	} else if (type == ICMP_TIME_EXCEEDED) {
 		struct ip_tunnel *t = netdev_priv(skb2->dev);
 		if (t->parms.iph.ttl) {
diff --git a/net/ipv4/ipip.c b/net/ipv4/ipip.c
index 76ab50b..c27b071 100644
--- a/net/ipv4/ipip.c
+++ b/net/ipv4/ipip.c
@@ -341,7 +341,8 @@ #else
 	int code = skb->h.icmph->code;
 	int rel_type = 0;
 	int rel_code = 0;
-	int rel_info = 0;
+	__be32 rel_info = 0;
+	__u32 n = 0;
 	struct sk_buff *skb2;
 	struct flowi fl;
 	struct rtable *rt;
@@ -354,14 +355,15 @@ #else
 	default:
 		return 0;
 	case ICMP_PARAMETERPROB:
-		if (skb->h.icmph->un.gateway < hlen)
+		n = htonl(skb->h.icmph->un.gateway);
+		if (n < hlen)
 			return 0;
 
 		/* So... This guy found something strange INSIDE encapsulated
 		   packet. Well, he is fool, but what can we do ?
 		 */
 		rel_type = ICMP_PARAMETERPROB;
-		rel_info = skb->h.icmph->un.gateway - hlen;
+		rel_info = htonl(n - hlen);
 		break;
 
 	case ICMP_DEST_UNREACH:
@@ -372,13 +374,14 @@ #else
 			return 0;
 		case ICMP_FRAG_NEEDED:
 			/* And it is the only really necessary thing :-) */
-			rel_info = ntohs(skb->h.icmph->un.frag.mtu);
-			if (rel_info < hlen+68)
+			n = ntohs(skb->h.icmph->un.frag.mtu);
+			if (n < hlen+68)
 				return 0;
-			rel_info -= hlen;
+			n -= hlen;
 			/* BSD 4.2 MORE DOES NOT EXIST IN NATURE. */
-			if (rel_info > ntohs(eiph->tot_len))
+			if (n > ntohs(eiph->tot_len))
 				return 0;
+			rel_info = htonl(n);
 			break;
 		default:
 			/* All others are translated to HOST_UNREACH.
@@ -440,12 +443,11 @@ #else
 
 	/* change mtu on this route */
 	if (type == ICMP_DEST_UNREACH && code == ICMP_FRAG_NEEDED) {
-		if (rel_info > dst_mtu(skb2->dst)) {
+		if (n > dst_mtu(skb2->dst)) {
 			kfree_skb(skb2);
 			return 0;
 		}
-		skb2->dst->ops->update_pmtu(skb2->dst, rel_info);
-		rel_info = htonl(rel_info);
+		skb2->dst->ops->update_pmtu(skb2->dst, n);
 	} else if (type == ICMP_TIME_EXCEEDED) {
 		struct ip_tunnel *t = netdev_priv(skb2->dev);
 		if (t->parms.iph.ttl) {
