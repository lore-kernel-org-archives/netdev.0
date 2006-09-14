From: Al Viro <viro@ftp.linux.org.uk>
Subject: Re: ipip and ip_gre encapsulation bugs
Date: Thu, 14 Sep 2006 02:16:37 +0100
Message-ID: <20060914011637.GH29920@ftp.linux.org.uk>
References: <E1GNBTO-0001v7-Pb@ZenIV.linux.org.uk> <E1GNf14-0004dW-00@gondolin.me.apana.org.au>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: davem@davemloft.net, torvalds@osdl.org, netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from zeniv.linux.org.uk ([195.92.253.2]:46300 "EHLO
	ZenIV.linux.org.uk") by vger.kernel.org with ESMTP id S1751306AbWINBQl
	(ORCPT <rfc822;netdev@vger.kernel.org>);
	Wed, 13 Sep 2006 21:16:41 -0400
To: Herbert Xu <herbert@gondor.apana.org.au>
Content-Disposition: inline
In-Reply-To: <E1GNf14-0004dW-00@gondolin.me.apana.org.au>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On Thu, Sep 14, 2006 at 10:23:42AM +1000, Herbert Xu wrote:
> > -               if (skb->h.icmph->un.gateway < (iph->ihl<<2))
> > +               n = ntohl(skb->h.icmph->un.gateway);
> > +               if (n < (iph->ihl<<2))
> >                        return;
> 
> I don't think this is right.  The original code works correctly on
> little-endian.  The patch introduces a swab on little-endian so it
> isn't right anymore.
> I suggest that you add a member to the icmph union which is just a
> u8 since that is what RFC792 specifies for PARAMETERPROB.  That way
> we can just use that u8 value without any swapping at all.

OK, after rereading the RFC...  Pointer field is one octet, indeed.
Avoiding all swapping will be tough - icmp_send() takes 32bit argument,
net-endian.

FWIW, I'd do the same thing as we do in the other places that deal with
ICMP_PARAMETERPROB.  E.g.
./net/ipv4/ip_options.c:456:            icmp_send(skb, ICMP_PARAMETERPROB, 0, htonl((pp_ptr-iph)<<24));
and
./net/ipv4/icmp.c:651:          info = ntohl(icmph->un.gateway) >> 24;

IOW,

>From cef2804df14cfc340f0fa70ecd09551c8e22447b Mon Sep 17 00:00:00 2001
From: Al Viro <viro@ftp.linux.org.uk>
Date: Tue, 12 Sep 2006 17:50:58 +0100
Subject: [PATCH] ipip and ip_gre encapsulation bugs

Handling of ipip and ip_gre ICMP error relaying is b0rken; it accesses
8bit field + 3 reserved octets as host-endian 32bit, does comparison,
subtraction and stuffs the result back.  That breaks on big-endian.

Fixed, made endian-clean.

Signed-off-by: Al Viro <viro@zeniv.linux.org.uk>
---
 net/ipv4/ip_gre.c |   23 +++++++++++++----------
 net/ipv4/ipip.c   |   22 ++++++++++++----------
 2 files changed, 25 insertions(+), 20 deletions(-)

diff --git a/net/ipv4/ip_gre.c b/net/ipv4/ip_gre.c
index 0f9b3a3..233f009 100644
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
+		n = ntohl(skb->h.icmph->un.gateway) >> 24;
+		if (n < (iph->ihl<<2))
 			return;
 
 		/* So... This guy found something strange INSIDE encapsulated
 		   packet. Well, he is fool, but what can we do ?
 		 */
 		rel_type = ICMP_PARAMETERPROB;
-		rel_info = skb->h.icmph->un.gateway - grehlen;
+		n -= grehlen;
+		rel_info = htonl(n << 24);
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
index 76ab50b..0c45565 100644
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
+		n = ntohl(skb->h.icmph->un.gateway) >> 24;
+		if (n < hlen)
 			return 0;
 
 		/* So... This guy found something strange INSIDE encapsulated
 		   packet. Well, he is fool, but what can we do ?
 		 */
 		rel_type = ICMP_PARAMETERPROB;
-		rel_info = skb->h.icmph->un.gateway - hlen;
+		rel_info = htonl((n - hlen) << 24);
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
-- 
1.4.0.rc2

