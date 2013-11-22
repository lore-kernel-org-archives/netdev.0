From: Herbert Xu <herbert@gondor.apana.org.au>
Subject: [1/2] gro: Only verify TCP checksums for candidates
Date: Fri, 22 Nov 2013 10:31:29 +0800
Message-ID: <20131122023129.GA6506@gondor.apana.org.au>
References: <5286F018.8060801@gmail.com>
 <20131116064611.GA12146@gondor.apana.org.au>
 <528A51B6.2040609@intel.com>
 <20131121.133501.272071098922555423.davem@davemloft.net>
 <20131122023013.GA6387@gondor.apana.org.au>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: alexander.h.duyck@intel.com, alexander.duyck@gmail.com,
	netdev@vger.kernel.org, edumazet@google.com
To: David Miller <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from ringil.hengli.com.au ([178.18.16.133]:36526 "EHLO
	fornost.hengli.com.au" rhost-flags-OK-OK-OK-FAIL) by vger.kernel.org
	with ESMTP id S1751250Ab3KVCbc (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 21 Nov 2013 21:31:32 -0500
Content-Disposition: inline
In-Reply-To: <20131122023013.GA6387@gondor.apana.org.au>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

In some cases we may receive IP packets that are longer than
their stated lengths.  Such packets are never merged in GRO.
However, we may end up computing their checksums incorrectly
and end up allowing packets with a bogus checksum enter our
stack with the checksum status set as verified.

Since such packets are rare and not performance-critical, this
patch simply skips the checksum verification for them.

Reported-by: Alexander Duyck <alexander.h.duyck@intel.com>
Signed-off-by: Herbert Xu <herbert@gondor.apana.org.au>
Acked-by: Alexander Duyck <alexander.h.duyck@intel.com>

diff --git a/net/ipv4/tcp_offload.c b/net/ipv4/tcp_offload.c
index a2b68a1..55aeec9 100644
--- a/net/ipv4/tcp_offload.c
+++ b/net/ipv4/tcp_offload.c
@@ -276,6 +276,10 @@ static struct sk_buff **tcp4_gro_receive(struct sk_buff **head, struct sk_buff *
 	__wsum wsum;
 	__sum16 sum;
 
+	/* Don't bother verifying checksum if we're going to flush anyway. */
+	if (NAPI_GRO_CB(skb)->flush)
+		goto skip_csum;
+
 	switch (skb->ip_summed) {
 	case CHECKSUM_COMPLETE:
 		if (!tcp_v4_check(skb_gro_len(skb), iph->saddr, iph->daddr,
@@ -301,6 +305,7 @@ flush:
 		break;
 	}
 
+skip_csum:
 	return tcp_gro_receive(head, skb);
 }
 
diff --git a/net/ipv6/tcpv6_offload.c b/net/ipv6/tcpv6_offload.c
index c1097c7..71923d1 100644
--- a/net/ipv6/tcpv6_offload.c
+++ b/net/ipv6/tcpv6_offload.c
@@ -39,6 +39,10 @@ static struct sk_buff **tcp6_gro_receive(struct sk_buff **head,
 	__wsum wsum;
 	__sum16 sum;
 
+	/* Don't bother verifying checksum if we're going to flush anyway. */
+	if (NAPI_GRO_CB(skb)->flush)
+		goto skip_csum;
+
 	switch (skb->ip_summed) {
 	case CHECKSUM_COMPLETE:
 		if (!tcp_v6_check(skb_gro_len(skb), &iph->saddr, &iph->daddr,
@@ -65,6 +69,7 @@ flush:
 		break;
 	}
 
+skip_csum:
 	return tcp_gro_receive(head, skb);
 }

Thanks,
-- 
Email: Herbert Xu <herbert@gondor.apana.org.au>
Home Page: http://gondor.apana.org.au/~herbert/
PGP Key: http://gondor.apana.org.au/~herbert/pubkey.txt
