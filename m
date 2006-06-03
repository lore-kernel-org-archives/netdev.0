From: Herbert Xu <herbert@gondor.apana.org.au>
Subject: Re: [Bug 6421] kernel 2.6.10-2.6.16 on alpha: arch/alpha/kernel/io.c, iowrite16_rep() BUG_ON((unsigned long)src & 0x1) triggered
Date: Sat, 3 Jun 2006 21:07:11 +1000
Message-ID: <20060603110711.GA1754@gondor.apana.org.au>
References: <200605271731.k4RHVJTb018158@fire-2.osdl.org> <20060603095442.GA373@gondor.apana.org.au> <20060603.195123.77471511.yoshfuji@linux-ipv6.org>
Mime-Version: 1.0
Content-Type: multipart/mixed; boundary="envbJBWh7q8WU6mo"
Cc: bugme-daemon@bugzilla.kernel.org, davem@davemloft.net,
	netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from rhun.apana.org.au ([64.62.148.172]:32787 "EHLO
	arnor.apana.org.au") by vger.kernel.org with ESMTP id S932606AbWFCLH1
	(ORCPT <rfc822;netdev@vger.kernel.org>);
	Sat, 3 Jun 2006 07:07:27 -0400
To: "YOSHIFUJI Hideaki / ?$B5HF#1QL@" <yoshfuji@linux-ipv6.org>
Content-Disposition: inline
In-Reply-To: <20060603.195123.77471511.yoshfuji@linux-ipv6.org>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org


--envbJBWh7q8WU6mo
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline

On Sat, Jun 03, 2006 at 07:51:23PM +0900, YOSHIFUJI Hideaki / ?$B5HF#1QL@ wrote:
> 
> I think that people will start thinking why we cannot
> skb_pull(skb, len) if skb_headlen(skb) == len; some comment needed...

Good idea.  Here is a better one.

[TCP]: Avoid skb_pull if possible when trimming head

Trimming the head of an skb by calling skb_pull can cause the packet
to become unaligned if the length pulled is odd.  Since the length is
entirely arbitrary for a FIN packet carrying data, this is actually
quite common.

Unaligned data is not the end of the world, but we should avoid it if
it's easily done.  In this case it is trivial.  Since we're discarding
all of the head data it doesn't matter whether we move skb->data forward
or back.

However, it is still possible to have unaligned skb->data in general.
So network drivers should be prepared to handle it instead of crashing.

This patch also adds an unlikely marking on len < headlen since partial
ACKs on head data are extremely rare in the wild.  As the return value
of __pskb_trim_head is no longer ever NULL that has been removed.

Signed-off-by: Herbert Xu ~{PmV>HI~} <herbert@gondor.apana.org.au>

Thanks,
-- 
Visit Openswan at http://www.openswan.org/
Email: Herbert Xu ~{PmV>HI~} <herbert@gondor.apana.org.au>
Home Page: http://gondor.apana.org.au/~herbert/
PGP Key: http://gondor.apana.org.au/~herbert/pubkey.txt

--envbJBWh7q8WU6mo
Content-Type: text/plain; charset=us-ascii
Content-Disposition: attachment; filename="tcp-trim-head-2.patch"

diff --git a/net/ipv4/tcp_output.c b/net/ipv4/tcp_output.c
index 743016b..f33c9dd 100644
--- a/net/ipv4/tcp_output.c
+++ b/net/ipv4/tcp_output.c
@@ -642,7 +642,7 @@ int tcp_fragment(struct sock *sk, struct
  * eventually). The difference is that pulled data not copied, but
  * immediately discarded.
  */
-static unsigned char *__pskb_trim_head(struct sk_buff *skb, int len)
+static void __pskb_trim_head(struct sk_buff *skb, int len)
 {
 	int i, k, eat;
 
@@ -667,7 +667,6 @@ static unsigned char *__pskb_trim_head(s
 	skb->tail = skb->data;
 	skb->data_len -= len;
 	skb->len = skb->data_len;
-	return skb->tail;
 }
 
 int tcp_trim_head(struct sock *sk, struct sk_buff *skb, u32 len)
@@ -676,12 +675,11 @@ int tcp_trim_head(struct sock *sk, struc
 	    pskb_expand_head(skb, 0, 0, GFP_ATOMIC))
 		return -ENOMEM;
 
-	if (len <= skb_headlen(skb)) {
+	/* If len == headlen, we avoid __skb_pull to preserve alignment. */
+	if (unlikely(len < skb_headlen(skb)))
 		__skb_pull(skb, len);
-	} else {
-		if (__pskb_trim_head(skb, len-skb_headlen(skb)) == NULL)
-			return -ENOMEM;
-	}
+	else
+		__pskb_trim_head(skb, len - skb_headlen(skb));
 
 	TCP_SKB_CB(skb)->seq += len;
 	skb->ip_summed = CHECKSUM_HW;

--envbJBWh7q8WU6mo--
