From: Herbert Xu <herbert@gondor.apana.org.au>
Subject: Re: pppoe and receive checksum offload
Date: Tue, 1 Mar 2005 12:04:24 +1100
Message-ID: <20050301010424.GA14851@gondor.apana.org.au>
References: <20050224155906.73890361@dxpl.pdx.osdl.net> <20050228113106.GA3268@gondor.apana.org.au> <20050228113938.GA3393@gondor.apana.org.au> <20050228140401.GA27937@yakov.inr.ac.ru>
Mime-Version: 1.0
Content-Type: multipart/mixed; boundary="h31gzZEtNLTqOjlF"
Cc: Stephen Hemminger <shemminger@osdl.org>,
        "David S. Miller" <davem@davemloft.net>, mostrows@speakeasy.net,
        netdev@oss.sgi.com
To: Alexey Kuznetsov <kuznet@ms2.inr.ac.ru>
Content-Disposition: inline
In-Reply-To: <20050228140401.GA27937@yakov.inr.ac.ru>
Sender: netdev-bounce@oss.sgi.com
Errors-to: netdev-bounce@oss.sgi.com
List-Id: netdev.vger.kernel.org


--h31gzZEtNLTqOjlF
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline

On Mon, Feb 28, 2005 at 05:04:01PM +0300, Alexey Kuznetsov wrote:
>
> ppp_input() could do the same thing. It does not, hence suggested patch
> is corrrect minimal solution.

Agreed.  We should use Stephen's patch for 2.6.11.

For 2.6.12, does this patch look sane? As usual, I'd love to get
some better names for the new helper functions.

Cheers,
-- 
Visit Openswan at http://www.openswan.org/
Email: Herbert Xu ~{PmV>HI~} <herbert@gondor.apana.org.au>
Home Page: http://gondor.apana.org.au/~herbert/
PGP Key: http://gondor.apana.org.au/~herbert/pubkey.txt

--h31gzZEtNLTqOjlF
Content-Type: text/plain; charset=us-ascii
Content-Disposition: attachment; filename=p

===== drivers/net/pppoe.c 1.48 vs edited =====
--- 1.48/drivers/net/pppoe.c	2005-01-21 16:02:12 +11:00
+++ edited/drivers/net/pppoe.c	2005-03-01 11:20:44 +11:00
@@ -338,7 +338,9 @@
 		struct pppoe_hdr *ph = (struct pppoe_hdr *) skb->nh.raw;
 		int len = ntohs(ph->length);
 		skb_pull(skb, sizeof(struct pppoe_hdr));
-		skb_trim(skb, len);
+		skb_postpull_rcsum(skb, ph, sizeof(*ph));
+		if (pskb_trim_rcsum(skb, len))
+			goto abort_kfree;
 
 		ppp_input(&po->chan, skb);
 	} else if (sk->sk_state & PPPOX_RELAY) {
===== include/linux/skbuff.h 1.60 vs edited =====
--- 1.60/include/linux/skbuff.h	2005-02-06 14:23:06 +11:00
+++ edited/include/linux/skbuff.h	2005-03-01 11:15:43 +11:00
@@ -1054,6 +1054,42 @@
 	return __skb_linearize(skb, gfp);
 }
 
+/**
+ *	skb_postpull_rcsum - update checksum for received skb after pull
+ *	@skb: buffer to update
+ *	@start: start of data before pull
+ *	@len: length of data pulled
+ *
+ *	After doing a pull on a received packet, you need to call this to
+ *	update the CHECKSUM_HW checksum, or set ip_summed to CHECKSUM_NONE
+ *	so that it can be recomputed from scratch.
+ */
+
+static inline void skb_postpull_rcsum(struct sk_buff *skb,
+					 const void *start, int len)
+{
+	if (skb->ip_summed == CHECKSUM_HW)
+		skb->csum = csum_sub(skb->csum, csum_partial(start, len, 0));
+}
+
+/**
+ *	pskb_trim_rcsum - trim received skb and update checksum
+ *	@skb: buffer to trim
+ *	@len: new length
+ *
+ *	This is exactly the same as pskb_trim except that it ensures the
+ *	checksum of received packets are still valid after the operation.
+ */
+
+static inline int pskb_trim_rcsum(struct sk_buff *skb, unsigned int len)
+{
+	if (len >= skb->len)
+		return 0;
+	if (skb->ip_summed == CHECKSUM_HW)
+		skb->ip_summed = CHECKSUM_NONE;
+	return __pskb_trim(skb, len);
+}
+
 static inline void *kmap_skb_frag(const skb_frag_t *frag)
 {
 #ifdef CONFIG_HIGHMEM
===== net/ipv4/ip_gre.c 1.46 vs edited =====
--- 1.46/net/ipv4/ip_gre.c	2005-01-14 15:41:05 +11:00
+++ edited/net/ipv4/ip_gre.c	2005-03-01 11:17:35 +11:00
@@ -618,10 +618,8 @@
 
 		skb->mac.raw = skb->nh.raw;
 		skb->nh.raw = __pskb_pull(skb, offset);
+		skb_postpull_rcsum(skb, skb->mac.raw, offset);
 		memset(&(IPCB(skb)->opt), 0, sizeof(struct ip_options));
-		if (skb->ip_summed == CHECKSUM_HW)
-			skb->csum = csum_sub(skb->csum,
-					     csum_partial(skb->mac.raw, skb->nh.raw-skb->mac.raw, 0));
 		skb->pkt_type = PACKET_HOST;
 #ifdef CONFIG_NET_IPGRE_BROADCAST
 		if (MULTICAST(iph->daddr)) {
===== net/ipv4/ip_input.c 1.27 vs edited =====
--- 1.27/net/ipv4/ip_input.c	2005-01-27 17:03:17 +11:00
+++ edited/net/ipv4/ip_input.c	2005-03-01 11:21:19 +11:00
@@ -410,10 +410,9 @@
 		 * is IP we can trim to the true length of the frame.
 		 * Note this now means skb->len holds ntohs(iph->tot_len).
 		 */
-		if (skb->len > len) {
-			__pskb_trim(skb, len);
-			if (skb->ip_summed == CHECKSUM_HW)
-				skb->ip_summed = CHECKSUM_NONE;
+		if (pskb_trim_rcsum(skb, len)) {
+			IP_INC_STATS_BH(IPSTATS_MIB_INDISCARDS);
+			goto drop;
 		}
 	}
 
===== net/ipv6/ip6_input.c 1.22 vs edited =====
--- 1.22/net/ipv6/ip6_input.c	2004-08-23 18:15:14 +10:00
+++ edited/net/ipv6/ip6_input.c	2005-03-01 11:24:32 +11:00
@@ -95,15 +95,11 @@
 	if (pkt_len || hdr->nexthdr != NEXTHDR_HOP) {
 		if (pkt_len + sizeof(struct ipv6hdr) > skb->len)
 			goto truncated;
-		if (pkt_len + sizeof(struct ipv6hdr) < skb->len) {
-			if (__pskb_trim(skb, pkt_len + sizeof(struct ipv6hdr))){
-				IP6_INC_STATS_BH(IPSTATS_MIB_INHDRERRORS);
-				goto drop;
-			}
-			hdr = skb->nh.ipv6h;
-			if (skb->ip_summed == CHECKSUM_HW)
-				skb->ip_summed = CHECKSUM_NONE;
+		if (pskb_trim_rcsum(skb, pkt_len + sizeof(struct ipv6hdr))) {
+			IP6_INC_STATS_BH(IPSTATS_MIB_INHDRERRORS);
+			goto drop;
 		}
+		hdr = skb->nh.ipv6h;
 	}
 
 	if (hdr->nexthdr == NEXTHDR_HOP) {
@@ -138,7 +134,6 @@
 	unsigned int nhoff;
 	int nexthdr;
 	u8 hash;
-	int cksum_sub = 0;
 
 	skb->h.raw = skb->nh.raw + sizeof(struct ipv6hdr);
 
@@ -173,11 +168,8 @@
 		if (ipprot->flags & INET6_PROTO_FINAL) {
 			struct ipv6hdr *hdr;	
 
-			if (!cksum_sub && skb->ip_summed == CHECKSUM_HW) {
-				skb->csum = csum_sub(skb->csum,
-						     csum_partial(skb->nh.raw, skb->h.raw-skb->nh.raw, 0));
-				cksum_sub++;
-			}
+			skb_postpull_rcsum(skb, skb->nh.raw,
+					   skb->h.raw - skb->nh.raw);
 			hdr = skb->nh.ipv6h;
 			if (ipv6_addr_is_multicast(&hdr->daddr) &&
 			    !ipv6_chk_mcast_addr(skb->dev, &hdr->daddr,

--h31gzZEtNLTqOjlF--
