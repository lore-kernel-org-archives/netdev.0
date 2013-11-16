From: Herbert Xu <herbert@gondor.apana.org.au>
Subject: Re: [PATCH v3] net: Do not include padding in TCP GRO checksum
Date: Sat, 16 Nov 2013 15:23:50 +0800
Message-ID: <20131116072350.GA12530@gondor.apana.org.au>
References: <20131115225856.6988.69733.stgit@ahduyck-fpga.jf.intel.com>
 <20131116004738.GA1491@gondor.apana.org.au>
 <20131116015301.GA1999@gondor.apana.org.au>
 <5286F018.8060801@gmail.com>
 <20131116064611.GA12146@gondor.apana.org.au>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: Alexander Duyck <alexander.h.duyck@intel.com>, davem@davemloft.net,
	netdev@vger.kernel.org, edumazet@google.com
To: Alexander Duyck <alexander.duyck@gmail.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from ringil.hengli.com.au ([178.18.16.133]:48530 "EHLO
	fornost.hengli.com.au" rhost-flags-OK-OK-OK-FAIL) by vger.kernel.org
	with ESMTP id S1751208Ab3KPHX5 (ORCPT
	<rfc822;netdev@vger.kernel.org>); Sat, 16 Nov 2013 02:23:57 -0500
Content-Disposition: inline
In-Reply-To: <20131116064611.GA12146@gondor.apana.org.au>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Sat, Nov 16, 2013 at 02:46:11PM +0800, Herbert Xu wrote:
> 
> gro: Only verify TCP checksums for candidates

And here is a patch on top of it that simplifies the checksum
code.

gro: Clean up tcpX_gro_receive checksum verification
    
This patch simplifies the checksum verification in tcpX_gro_receive
by reusing the CHECKSUM_COMPLETE code for CHECKSUM_NONE.  All it
does for CHECKSUM_NONE is compute the partial checksum and then
treat it as if it came from the hardware (CHECKSUM_COMPLETE).
    
Signed-off-by: Herbert Xu <herbert@gondor.apana.org.au>

diff --git a/net/ipv4/tcp_offload.c b/net/ipv4/tcp_offload.c
index 55aeec9..0560635 100644
--- a/net/ipv4/tcp_offload.c
+++ b/net/ipv4/tcp_offload.c
@@ -274,35 +274,29 @@ static struct sk_buff **tcp4_gro_receive(struct sk_buff **head, struct sk_buff *
 {
 	const struct iphdr *iph = skb_gro_network_header(skb);
 	__wsum wsum;
-	__sum16 sum;
 
 	/* Don't bother verifying checksum if we're going to flush anyway. */
 	if (NAPI_GRO_CB(skb)->flush)
 		goto skip_csum;
 
+	wsum = skb->csum;
+
 	switch (skb->ip_summed) {
+	case CHECKSUM_NONE:
+		wsum = skb_checksum(skb, skb_gro_offset(skb), skb_gro_len(skb),
+				    0);
+
+		/* fall through */
+
 	case CHECKSUM_COMPLETE:
 		if (!tcp_v4_check(skb_gro_len(skb), iph->saddr, iph->daddr,
-				  skb->csum)) {
+				  wsum)) {
 			skb->ip_summed = CHECKSUM_UNNECESSARY;
 			break;
 		}
-flush:
+
 		NAPI_GRO_CB(skb)->flush = 1;
 		return NULL;
-
-	case CHECKSUM_NONE:
-		wsum = csum_tcpudp_nofold(iph->saddr, iph->daddr,
-					  skb_gro_len(skb), IPPROTO_TCP, 0);
-		sum = csum_fold(skb_checksum(skb,
-					     skb_gro_offset(skb),
-					     skb_gro_len(skb),
-					     wsum));
-		if (sum)
-			goto flush;
-
-		skb->ip_summed = CHECKSUM_UNNECESSARY;
-		break;
 	}
 
 skip_csum:
diff --git a/net/ipv6/tcpv6_offload.c b/net/ipv6/tcpv6_offload.c
index 71923d1..6d18157 100644
--- a/net/ipv6/tcpv6_offload.c
+++ b/net/ipv6/tcpv6_offload.c
@@ -37,36 +37,29 @@ static struct sk_buff **tcp6_gro_receive(struct sk_buff **head,
 {
 	const struct ipv6hdr *iph = skb_gro_network_header(skb);
 	__wsum wsum;
-	__sum16 sum;
 
 	/* Don't bother verifying checksum if we're going to flush anyway. */
 	if (NAPI_GRO_CB(skb)->flush)
 		goto skip_csum;
 
+	wsum = skb->csum;
+
 	switch (skb->ip_summed) {
+	case CHECKSUM_NONE:
+		wsum = skb_checksum(skb, skb_gro_offset(skb), skb_gro_len(skb),
+				    wsum);
+
+		/* fall through */
+
 	case CHECKSUM_COMPLETE:
 		if (!tcp_v6_check(skb_gro_len(skb), &iph->saddr, &iph->daddr,
-				  skb->csum)) {
+				  wsum)) {
 			skb->ip_summed = CHECKSUM_UNNECESSARY;
 			break;
 		}
-flush:
+
 		NAPI_GRO_CB(skb)->flush = 1;
 		return NULL;
-
-	case CHECKSUM_NONE:
-		wsum = ~csum_unfold(csum_ipv6_magic(&iph->saddr, &iph->daddr,
-						    skb_gro_len(skb),
-						    IPPROTO_TCP, 0));
-		sum = csum_fold(skb_checksum(skb,
-					     skb_gro_offset(skb),
-					     skb_gro_len(skb),
-					     wsum));
-		if (sum)
-			goto flush;
-
-		skb->ip_summed = CHECKSUM_UNNECESSARY;
-		break;
 	}
 
 skip_csum:

Cheers,
-- 
Email: Herbert Xu <herbert@gondor.apana.org.au>
Home Page: http://gondor.apana.org.au/~herbert/
PGP Key: http://gondor.apana.org.au/~herbert/pubkey.txt
