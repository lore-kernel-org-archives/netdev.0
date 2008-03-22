From: Herbert Xu <herbert@gondor.apana.org.au>
Subject: [TCP]: Let skbs grow over a page on fast peers
Date: Sat, 22 Mar 2008 20:59:50 +0800
Message-ID: <20080322125950.GA25816@gondor.apana.org.au>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
To: "David S. Miller" <davem@davemloft.net>, netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from rhun.apana.org.au ([64.62.148.172]:40683 "EHLO
	arnor.apana.org.au" rhost-flags-OK-OK-OK-FAIL) by vger.kernel.org
	with ESMTP id S1753330AbYCVM7y (ORCPT
	<rfc822;netdev@vger.kernel.org>); Sat, 22 Mar 2008 08:59:54 -0400
Content-Disposition: inline
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Hi Dave:

[TCP]: Let skbs grow over a page on fast peers

While testing the virtio-net driver on KVM with TSO I noticed
that TSO performance with a 1500 MTU is significantly worse
compared to the performance of non-TSO with a 16436 MTU.  The
packet dump shows that most of the packets sent are smaller
than a page.

Looking at the code this actually is quite obvious as it always
stop extending the packet if it's the first packet yet to be
sent and if it's larger than the MSS.  Since each extension is
bound by the page size, this means that (given a 1500 MTU) we're
very unlikely to construct packets greater than a page, provided
that the receiver and the path is fast enough so that packets can
always be sent immediately.

The fix is also quite obvious.  The push calls inside the loop
is just an optimisation so that we don't end up doing all the
sending at the end of the loop.  Therefore there is no specific
reason why it has to do so at MSS boundaries.  For TSO, the
most natural extension of this optimisation is to do the pushing
once the skb exceeds the TSO size goal.

This is what the patch does and testing with KVM shows that the
TSO performance with a 1500 MTU easily surpasses that of a 16436
MTU and indeed the packet sizes sent are generally larger than
16436.

I don't see any obvious downsides for slower peers or connections,
but it would be prudent to test this extensively to ensure that
those cases don't regress.

Signed-off-by: Herbert Xu <herbert@gondor.apana.org.au>

Cheers,
-- 
Visit Openswan at http://www.openswan.org/
Email: Herbert Xu ~{PmV>HI~} <herbert@gondor.apana.org.au>
Home Page: http://gondor.apana.org.au/~herbert/
PGP Key: http://gondor.apana.org.au/~herbert/pubkey.txt
--
diff --git a/net/ipv4/tcp.c b/net/ipv4/tcp.c
index 071e83a..39b629a 100644
--- a/net/ipv4/tcp.c
+++ b/net/ipv4/tcp.c
@@ -735,7 +735,7 @@ new_segment:
 		if (!(psize -= copy))
 			goto out;
 
-		if (skb->len < mss_now || (flags & MSG_OOB))
+		if (skb->len < size_goal || (flags & MSG_OOB))
 			continue;
 
 		if (forced_push(tp)) {
@@ -981,7 +981,7 @@ new_segment:
 			if ((seglen -= copy) == 0 && iovlen == 0)
 				goto out;
 
-			if (skb->len < mss_now || (flags & MSG_OOB))
+			if (skb->len < size_goal || (flags & MSG_OOB))
 				continue;
 
 			if (forced_push(tp)) {
