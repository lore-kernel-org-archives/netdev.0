From: Herbert Xu <herbert@gondor.apana.org.au>
Subject: [AH6] Replace skb by iph in clear_mutable_options
Date: Sat, 24 Jul 2004 14:50:41 +1000
Sender: netdev-bounce@oss.sgi.com
Message-ID: <20040724045041.GA7091@gondor.apana.org.au>
Mime-Version: 1.0
Content-Type: multipart/mixed; boundary="GvXjxJ+pjyke8COw"
Return-path: <netdev-bounce@oss.sgi.com>
To: "David S. Miller" <davem@redhat.com>,
        Kazunori Miyazawa <kazunori@miyazawa.org>, netdev@oss.sgi.com
Content-Disposition: inline
Errors-to: netdev-bounce@oss.sgi.com
List-Id: netdev.vger.kernel.org


--GvXjxJ+pjyke8COw
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline

Hi:

This patch replaces the skb argument in ipv6_clear_mutable_options() by
an ipv6hdr.  Doing so allows us to point skb->nh elsewhere when calling
this function.

I've also thrown in some obvious clean-ups for that function.

Signed-off-by: Herbert Xu <herbert@gondor.apana.org.au>

Cheers,
-- 
Visit Openswan at http://www.openswan.org/
Email: Herbert Xu ~{PmV>HI~} <herbert@gondor.apana.org.au>
Home Page: http://gondor.apana.org.au/~herbert/
PGP Key: http://gondor.apana.org.au/~herbert/pubkey.txt

--GvXjxJ+pjyke8COw
Content-Type: text/plain; charset=us-ascii
Content-Disposition: attachment; filename=p

===== ah6.c 1.33 vs edited =====
--- 1.33/net/ipv6/ah6.c	2004-07-24 09:54:15 +10:00
+++ edited/ah6.c	2004-07-24 14:39:24 +10:00
@@ -74,49 +74,42 @@
 	return 0;
 }
 
-static int ipv6_clear_mutable_options(struct sk_buff *skb,
-				      unsigned int hdr_len)
+static int ipv6_clear_mutable_options(struct ipv6hdr *iph, int len)
 {
-	u16 offset = sizeof(struct ipv6hdr);
-	struct ipv6_opt_hdr *exthdr = (struct ipv6_opt_hdr*)(skb->nh.raw + offset);
-	u8 nexthdr = skb->nh.ipv6h->nexthdr;
+	union {
+		struct ipv6hdr *iph;
+		struct ipv6_opt_hdr *opth;
+		struct ipv6_rt_hdr *rth;
+		char *raw;
+	} exthdr = { .iph = iph };
+	char *end = exthdr.raw + len;
+	int nexthdr = iph->nexthdr;
 
-	while (offset + 1 <= hdr_len) {
+	exthdr.iph++;
 
+	while (exthdr.raw < end) {
 		switch (nexthdr) {
-
 		case NEXTHDR_HOP:
-			offset += ipv6_optlen(exthdr);
-			if (!zero_out_mutable_opts(exthdr)) {
-				LIMIT_NETDEBUG(
-				printk(KERN_WARNING "overrun hopopts\n")); 
+		case NEXTHDR_DEST:
+			if (!zero_out_mutable_opts(exthdr.opth)) {
+				LIMIT_NETDEBUG(printk(
+					KERN_WARNING "overrun %sopts\n",
+					nexthdr == NEXTHDR_HOP ?
+						"hop" : "dest"));
 				return -EINVAL;
 			}
-			nexthdr = exthdr->nexthdr;
-			exthdr = (struct ipv6_opt_hdr*)(skb->nh.raw + offset);
 			break;
 
 		case NEXTHDR_ROUTING:
-			offset += ipv6_optlen(exthdr);
-			((struct ipv6_rt_hdr*)exthdr)->segments_left = 0; 
-			nexthdr = exthdr->nexthdr;
-			exthdr = (struct ipv6_opt_hdr*)(skb->nh.raw + offset);
-			break;
-
-		case NEXTHDR_DEST:
-			offset += ipv6_optlen(exthdr);
-			if (!zero_out_mutable_opts(exthdr))  {
-				LIMIT_NETDEBUG(
-					printk(KERN_WARNING "overrun destopt\n")); 
-				return -EINVAL;
-			}
-			nexthdr = exthdr->nexthdr;
-			exthdr = (struct ipv6_opt_hdr*)(skb->nh.raw + offset);
+			exthdr.rth->segments_left = 0; 
 			break;
 
 		default :
 			return 0;
 		}
+
+		nexthdr = exthdr.opth->nexthdr;
+		exthdr.raw += ipv6_optlen(exthdr.opth);
 	}
 
 	return 0;
@@ -175,7 +168,7 @@
 		(*pskb)->nh.ipv6h = (struct ipv6hdr*)skb_push(*pskb, x->props.header_len);
 		iph->payload_len = htons((*pskb)->len - sizeof(struct ipv6hdr));
 		memcpy((*pskb)->nh.ipv6h, iph, hdr_len);
-		err = ipv6_clear_mutable_options(*pskb, hdr_len);
+		err = ipv6_clear_mutable_options((*pskb)->nh.ipv6h, hdr_len);
 		if (err)
 			goto error_free_iph;
 
@@ -283,7 +276,7 @@
 	if (!tmp_hdr)
 		goto out;
 	memcpy(tmp_hdr, skb->nh.raw, hdr_len);
-	if (ipv6_clear_mutable_options(skb, hdr_len))
+	if (ipv6_clear_mutable_options(skb->nh.ipv6h, hdr_len))
 		goto out;
 	skb->nh.ipv6h->priority    = 0;
 	skb->nh.ipv6h->flow_lbl[0] = 0;

--GvXjxJ+pjyke8COw--
