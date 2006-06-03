From: Herbert Xu <herbert@gondor.apana.org.au>
Subject: Re: [Bug 6421] kernel 2.6.10-2.6.16 on alpha: arch/alpha/kernel/io.c, iowrite16_rep() BUG_ON((unsigned long)src & 0x1) triggered
Date: Sat, 3 Jun 2006 19:54:42 +1000
Message-ID: <20060603095442.GA373@gondor.apana.org.au>
References: <200605271731.k4RHVJTb018158@fire-2.osdl.org>
Mime-Version: 1.0
Content-Type: multipart/mixed; boundary="gKMricLos+KVdGMg"
Cc: "David S. Miller" <davem@davemloft.net>, netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from rhun.apana.org.au ([64.62.148.172]:39441 "EHLO
	arnor.apana.org.au") by vger.kernel.org with ESMTP id S932601AbWFCJyz
	(ORCPT <rfc822;netdev@vger.kernel.org>);
	Sat, 3 Jun 2006 05:54:55 -0400
To: bugme-daemon@bugzilla.kernel.org
Content-Disposition: inline
In-Reply-To: <200605271731.k4RHVJTb018158@fire-2.osdl.org>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org


--gKMricLos+KVdGMg
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline

On Sat, May 27, 2006 at 10:31:19AM -0700, bugme-daemon@bugzilla.kernel.org wrote:
> 
> Ok, see the attachment (ALL.txt.gz) for the tcpdump output. If you would like
> the hexdump or more, please give the tcpdump filter rule to me.

Thanks a lot.  So it wasn't as uncommon as I thought.  In fact, partial
odd acks like yours happen all the time as part of FIN handling.  So this
is something that we want to address.

BTW, we should also fix arch/alpha/kernel/io.c to not crash on
unaligned data.  Most other common architectures will grin and
bear it.

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

Signed-off-by: Herbert Xu <herbert@gondor.apana.org.au>

Cheers,
-- 
Visit Openswan at http://www.openswan.org/
Email: Herbert Xu ~{PmV>HI~} <herbert@gondor.apana.org.au>
Home Page: http://gondor.apana.org.au/~herbert/
PGP Key: http://gondor.apana.org.au/~herbert/pubkey.txt

--gKMricLos+KVdGMg
Content-Type: text/plain; charset=us-ascii
Content-Disposition: attachment; filename="tcp-trim-head.patch"

diff --git a/net/ipv4/tcp_output.c b/net/ipv4/tcp_output.c
index 743016b..bd7c89b 100644
--- a/net/ipv4/tcp_output.c
+++ b/net/ipv4/tcp_output.c
@@ -676,7 +676,7 @@ int tcp_trim_head(struct sock *sk, struc
 	    pskb_expand_head(skb, 0, 0, GFP_ATOMIC))
 		return -ENOMEM;
 
-	if (len <= skb_headlen(skb)) {
+	if (len < skb_headlen(skb)) {
 		__skb_pull(skb, len);
 	} else {
 		if (__pskb_trim_head(skb, len-skb_headlen(skb)) == NULL)

--gKMricLos+KVdGMg--
