From: Herbert Xu <herbert@gondor.apana.org.au>
Subject: Re: forcedeth skb_gso_segment warning
Date: Mon, 29 Jun 2009 12:06:41 +0800
Message-ID: <20090629040641.GA3357@gondor.apana.org.au>
References: <1244539163.4672.5.camel@johannes.local> <20090629040330.GA2981@gondor.apana.org.au>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: netdev@vger.kernel.org
To: Johannes Berg <johannes@sipsolutions.net>,
	"David S. Miller" <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from rhun.apana.org.au ([64.62.148.172]:60302 "EHLO
	arnor.apana.org.au" rhost-flags-OK-OK-OK-FAIL) by vger.kernel.org
	with ESMTP id S1750759AbZF2EGo (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 29 Jun 2009 00:06:44 -0400
Content-Disposition: inline
In-Reply-To: <20090629040330.GA2981@gondor.apana.org.au>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Mon, Jun 29, 2009 at 12:03:30PM +0800, Herbert Xu wrote:
> 
> tcp: Stop non-TSO packets morphing into TSO

Here's a follow-up patch to optimise this boundary case.

tcp: Do not tack on TSO data to non-TSO packet

If a socket starts out on a non-TSO route, and then switches to
a TSO route, then we will tack on data to the tail of the tx queue
even if it started out life as non-TSO.  This is suboptimal because
all of it will then be copied and checksummed unnecessarily.

This patch fixes this by ensuring that skb->ip_summed is set to
CHECKSUM_PARTIAL before appending extra data beyond the MSS.

Signed-off-by: Herbert Xu <herbert@gondor.apana.org.au>

diff --git a/net/ipv4/tcp.c b/net/ipv4/tcp.c
index 17b89c5..7870a53 100644
--- a/net/ipv4/tcp.c
+++ b/net/ipv4/tcp.c
@@ -903,13 +903,17 @@ int tcp_sendmsg(struct kiocb *iocb, struct socket *sock, struct msghdr *msg,
 		iov++;
 
 		while (seglen > 0) {
-			int copy;
+			int copy = 0;
+			int max = size_goal;
 
 			skb = tcp_write_queue_tail(sk);
+			if (tcp_send_head(sk)) {
+				if (skb->ip_summed == CHECKSUM_NONE)
+					max = mss_now;
+				copy = max - skb->len;
+			}
 
-			if (!tcp_send_head(sk) ||
-			    (copy = size_goal - skb->len) <= 0) {
-
+			if (copy <= 0) {
 new_segment:
 				/* Allocate new segment. If the interface is SG,
 				 * allocate skb fitting to single page.
@@ -930,6 +934,7 @@ new_segment:
 
 				skb_entail(sk, skb);
 				copy = size_goal;
+				max = size_goal;
 			}
 
 			/* Try to append data to the end of skb. */
@@ -1028,7 +1033,7 @@ new_segment:
 			if ((seglen -= copy) == 0 && iovlen == 0)
 				goto out;
 
-			if (skb->len < size_goal || (flags & MSG_OOB))
+			if (skb->len < max || (flags & MSG_OOB))
 				continue;
 
 			if (forced_push(tp)) {

Cheers,
-- 
Visit Openswan at http://www.openswan.org/
Email: Herbert Xu ~{PmV>HI~} <herbert@gondor.apana.org.au>
Home Page: http://gondor.apana.org.au/~herbert/
PGP Key: http://gondor.apana.org.au/~herbert/pubkey.txt
