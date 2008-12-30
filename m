From: Herbert Xu <herbert@gondor.apana.org.au>
Subject: [1/2] gro: Use gso_size to store MSS
Date: Tue, 30 Dec 2008 21:07:05 +1100
Message-ID: <20081230100705.GA31741@gondor.apana.org.au>
References: <20081226225157.GA22866@gondor.apana.org.au> <20081229122445.GA11161@gondor.apana.org.au> <20081229.230703.265458431.davem@davemloft.net>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: netdev@vger.kernel.org
To: David Miller <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from rhun.apana.org.au ([64.62.148.172]:33368 "EHLO
	arnor.apana.org.au" rhost-flags-OK-OK-OK-FAIL) by vger.kernel.org
	with ESMTP id S1751156AbYL3KHJ (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 30 Dec 2008 05:07:09 -0500
Content-Disposition: inline
In-Reply-To: <20081229.230703.265458431.davem@davemloft.net>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Mon, Dec 29, 2008 at 11:07:03PM -0800, David Miller wrote:
> 
> When you want me to apply this stuff, send them as two
> seperate changes with updated commit messages.

OK here we go:

gro: Use gso_size to store MSS

In order to allow GRO packets without frag_list at all, we need to
store the MSS in the packet itself.  The obvious place is gso_size.
The only thing to watch out for is if the packet ends up not being
GRO then we need to clear gso_size before pushing the packet into
the stack.

Signed-off-by: Herbert Xu <herbert@gondor.apana.org.au>

diff --git a/net/core/dev.c b/net/core/dev.c
index 4464240..67a6ff4 100644
--- a/net/core/dev.c
+++ b/net/core/dev.c
@@ -2365,6 +2365,7 @@ static int napi_gro_complete(struct sk_buff *skb)
 	}
 
 out:
+	skb_shinfo(skb)->gso_size = 0;
 	__skb_push(skb, -skb_network_offset(skb));
 	return netif_receive_skb(skb);
 }
@@ -2446,6 +2447,7 @@ int napi_gro_receive(struct napi_struct *napi, struct sk_buff *skb)
 	}
 
 	NAPI_GRO_CB(skb)->count = 1;
+	skb_shinfo(skb)->gso_size = skb->len;
 	skb->next = napi->gro_list;
 	napi->gro_list = skb;
 
diff --git a/net/core/skbuff.c b/net/core/skbuff.c
index b8d0abb..3aafb10 100644
--- a/net/core/skbuff.c
+++ b/net/core/skbuff.c
@@ -2613,6 +2613,7 @@ int skb_gro_receive(struct sk_buff **head, struct sk_buff *skb)
 
 	*NAPI_GRO_CB(nskb) = *NAPI_GRO_CB(p);
 	skb_shinfo(nskb)->frag_list = p;
+	skb_shinfo(nskb)->gso_size = skb_shinfo(p)->gso_size;
 	skb_header_release(p);
 	nskb->prev = p;
 
diff --git a/net/ipv4/tcp.c b/net/ipv4/tcp.c
index 1f3d529..218a6e5 100644
--- a/net/ipv4/tcp.c
+++ b/net/ipv4/tcp.c
@@ -2518,9 +2518,7 @@ found:
 	flush |= memcmp(th + 1, th2 + 1, thlen - sizeof(*th));
 
 	total = p->len;
-	mss = total;
-	if (skb_shinfo(p)->frag_list)
-		mss = skb_shinfo(p)->frag_list->len;
+	mss = skb_shinfo(p)->gso_size;
 
 	flush |= skb->len > mss || skb->len <= 0;
 	flush |= ntohl(th2->seq) + total != ntohl(th->seq);
@@ -2556,7 +2554,6 @@ int tcp_gro_complete(struct sk_buff *skb)
 	skb->csum_offset = offsetof(struct tcphdr, check);
 	skb->ip_summed = CHECKSUM_PARTIAL;
 
-	skb_shinfo(skb)->gso_size = skb_shinfo(skb)->frag_list->len;
 	skb_shinfo(skb)->gso_segs = NAPI_GRO_CB(skb)->count;
 
 	if (th->cwr)

Thanks,
-- 
Visit Openswan at http://www.openswan.org/
Email: Herbert Xu ~{PmV>HI~} <herbert@gondor.apana.org.au>
Home Page: http://gondor.apana.org.au/~herbert/
PGP Key: http://gondor.apana.org.au/~herbert/pubkey.txt
