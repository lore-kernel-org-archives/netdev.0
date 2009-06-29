From: Herbert Xu <herbert@gondor.apana.org.au>
Subject: Re: forcedeth skb_gso_segment warning
Date: Mon, 29 Jun 2009 12:03:30 +0800
Message-ID: <20090629040330.GA2981@gondor.apana.org.au>
References: <1244539163.4672.5.camel@johannes.local>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: netdev@vger.kernel.org
To: Johannes Berg <johannes@sipsolutions.net>,
	"David S. Miller" <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from rhun.apana.org.au ([64.62.148.172]:60298 "EHLO
	arnor.apana.org.au" rhost-flags-OK-OK-OK-FAIL) by vger.kernel.org
	with ESMTP id S1750734AbZF2EDe (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 29 Jun 2009 00:03:34 -0400
Content-Disposition: inline
In-Reply-To: <1244539163.4672.5.camel@johannes.local>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Tue, Jun 09, 2009 at 11:19:23AM +0200, Johannes Berg wrote:
> Happened a number of times:
> 
> Jun  8 18:56:25 johannes kernel: [33987.849090] ------------[ cut here ]------------
> Jun  8 18:56:25 johannes kernel: [33987.849106] WARNING: at /home/johannes/sys/wireless-testing/net/core/dev.c:1560 skb_gso_segment+0x233/0x2e0()
> Jun  8 18:56:25 johannes kernel: [33987.849110] Hardware name: MacBook5,1
> Jun  8 18:56:25 johannes kernel: [33987.849114] forcedeth: caps=(0x10823, 0x19082b) len=65212 data_len=63712 ip_summed=0

Thank you!

This was the clue I needed.  The fact that the packet is TSO and
not completely non-linear.

tcp: Stop non-TSO packets morphing into TSO

If a socket starts out on a non-TSO route, and then switches to
a TSO route, then the tail on the tx queue can morph into a TSO
packet, causing mischief because the rest of the stack does not
expect a partially linear TSO packet.

This patch fixes this by ensuring that skb->ip_summed is set to
CHECKSUM_PARTIAL before declaring a packet as TSO.

Signed-off-by: Herbert Xu <herbert@gondor.apana.org.au>

diff --git a/net/ipv4/tcp_output.c b/net/ipv4/tcp_output.c
index 416fc4c..5bdf08d 100644
--- a/net/ipv4/tcp_output.c
+++ b/net/ipv4/tcp_output.c
@@ -725,7 +725,8 @@ static void tcp_queue_skb(struct sock *sk, struct sk_buff *skb)
 static void tcp_set_skb_tso_segs(struct sock *sk, struct sk_buff *skb,
 				 unsigned int mss_now)
 {
-	if (skb->len <= mss_now || !sk_can_gso(sk)) {
+	if (skb->len <= mss_now || !sk_can_gso(sk) ||
+	    skb->ip_summed == CHECKSUM_NONE) {
 		/* Avoid the costly divide in the normal
 		 * non-TSO case.
 		 */

Thanks,
-- 
Visit Openswan at http://www.openswan.org/
Email: Herbert Xu ~{PmV>HI~} <herbert@gondor.apana.org.au>
Home Page: http://gondor.apana.org.au/~herbert/
PGP Key: http://gondor.apana.org.au/~herbert/pubkey.txt
