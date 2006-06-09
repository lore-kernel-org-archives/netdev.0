From: Herbert Xu <herbert@gondor.apana.org.au>
Subject: [3/3] [NET]: skb_trim audit
Date: Fri, 9 Jun 2006 17:44:33 +1000
Message-ID: <20060609074433.GB19524@gondor.apana.org.au>
References: <20060609074234.GA17580@gondor.apana.org.au>
Mime-Version: 1.0
Content-Type: multipart/mixed; boundary="Y7xTucakfITjPcLV"
Return-path: <netdev-owner@vger.kernel.org>
Received: from rhun.apana.org.au ([64.62.148.172]:38161 "EHLO
	arnor.apana.org.au") by vger.kernel.org with ESMTP id S1751423AbWFIHog
	(ORCPT <rfc822;netdev@vger.kernel.org>);
	Fri, 9 Jun 2006 03:44:36 -0400
To: "David S. Miller" <davem@davemloft.net>, netdev@vger.kernel.org
Content-Disposition: inline
In-Reply-To: <20060609074234.GA17580@gondor.apana.org.au>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org


--Y7xTucakfITjPcLV
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline

Hi:

[NET]: skb_trim audit

I found a few more spots where pskb_trim_rcsum could be used but were not.
This patch changes them to use it.

Also, sk_filter can get paged skb data.  Therefore we must use pskb_trim
instead of skb_trim.

Signed-off-by: Herbert Xu <herbert@gondor.apana.org.au>

Cheers,
-- 
Visit Openswan at http://www.openswan.org/
Email: Herbert Xu ~{PmV>HI~} <herbert@gondor.apana.org.au>
Home Page: http://gondor.apana.org.au/~herbert/
PGP Key: http://gondor.apana.org.au/~herbert/pubkey.txt

--Y7xTucakfITjPcLV
Content-Type: text/plain; charset=us-ascii
Content-Disposition: attachment; filename="p3.patch"

diff --git a/include/net/sock.h b/include/net/sock.h
--- a/include/net/sock.h
+++ b/include/net/sock.h
@@ -873,10 +873,7 @@ static inline int sk_filter(struct sock 
 		if (filter) {
 			unsigned int pkt_len = sk_run_filter(skb, filter->insns,
 							     filter->len);
-			if (!pkt_len)
-				err = -EPERM;
-			else
-				skb_trim(skb, pkt_len);
+			err = pkt_len ? pskb_trim(skb, pkt_len) : -EPERM;
 		}
 
 		if (needlock)
diff --git a/net/bridge/br_netfilter.c b/net/bridge/br_netfilter.c
--- a/net/bridge/br_netfilter.c
+++ b/net/bridge/br_netfilter.c
@@ -407,12 +407,8 @@ static unsigned int br_nf_pre_routing_ip
 	if (pkt_len || hdr->nexthdr != NEXTHDR_HOP) {
 		if (pkt_len + sizeof(struct ipv6hdr) > skb->len)
 			goto inhdr_error;
-		if (pkt_len + sizeof(struct ipv6hdr) < skb->len) {
-			if (__pskb_trim(skb, pkt_len + sizeof(struct ipv6hdr)))
-				goto inhdr_error;
-			if (skb->ip_summed == CHECKSUM_HW)
-				skb->ip_summed = CHECKSUM_NONE;
-		}
+		if (pskb_trim_rcsum(skb, pkt_len + sizeof(struct ipv6hdr)))
+			goto inhdr_error;
 	}
 	if (hdr->nexthdr == NEXTHDR_HOP && check_hbh_len(skb))
 		goto inhdr_error;
@@ -495,11 +491,7 @@ static unsigned int br_nf_pre_routing(un
 	if (skb->len < len || len < 4 * iph->ihl)
 		goto inhdr_error;
 
-	if (skb->len > len) {
-		__pskb_trim(skb, len);
-		if (skb->ip_summed == CHECKSUM_HW)
-			skb->ip_summed = CHECKSUM_NONE;
-	}
+	pskb_trim_rcsum(skb, len);
 
 	nf_bridge_put(skb->nf_bridge);
 	if (!nf_bridge_alloc(skb))
diff --git a/net/ipv6/netfilter/nf_conntrack_reasm.c b/net/ipv6/netfilter/nf_conntrack_reasm.c
--- a/net/ipv6/netfilter/nf_conntrack_reasm.c
+++ b/net/ipv6/netfilter/nf_conntrack_reasm.c
@@ -456,13 +456,9 @@ static int nf_ct_frag6_queue(struct nf_c
 		DEBUGP("queue: message is too short.\n");
 		goto err;
 	}
-	if (end-offset < skb->len) {
-		if (pskb_trim(skb, end - offset)) {
-			DEBUGP("Can't trim\n");
-			goto err;
-		}
-		if (skb->ip_summed != CHECKSUM_UNNECESSARY)
-			skb->ip_summed = CHECKSUM_NONE;
+	if (pskb_trim_rcsum(skb, end - offset)) {
+		DEBUGP("Can't trim\n");
+		goto err;
 	}
 
 	/* Find out which fragments are in front and at the back of us

--Y7xTucakfITjPcLV--
