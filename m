From: Herbert Xu <herbert@gondor.apana.org.au>
Subject: tcp: Do not apply TSO segment limit to non-TSO packets
Date: Thu, 1 Jan 2015 00:39:23 +1100
Message-ID: <20141231133923.GA30248@gondor.apana.org.au>
References: <1709726.jUgUSQI9sl@pikkukde.a.i2n>
 <20141201102522.GA16579@gondor.apana.org.au>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: netdev@vger.kernel.org, edumazet@google.com,
	Steffen Klassert <steffen.klassert@secunet.com>,
	Ben Hutchings <bhutchings@solarflare.com>,
	"David S. Miller" <davem@davemloft.net>
To: Thomas Jarosch <thomas.jarosch@intra2net.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from helcar.apana.org.au ([209.40.204.226]:46991 "EHLO
	helcar.apana.org.au" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751073AbaLaNjc (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 31 Dec 2014 08:39:32 -0500
Content-Disposition: inline
In-Reply-To: <20141201102522.GA16579@gondor.apana.org.au>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Mon, Dec 01, 2014 at 06:25:22PM +0800, Herbert Xu wrote:
> Thomas Jarosch <thomas.jarosch@intra2net.com> wrote:
> > 
> > When I revert it, even kernel v3.18-rc6 starts working.
> > But I doubt this is the root problem, may be just hiding another issue.
> 
> Can you do a tcpdump with this patch reverted? I would like to
> see the size of the packets that are sent out vs. the ICMP message
> that came back.

Thanks for providing the data.  Here is a patch that should fix
the problem.

-- >8 --
Thomas Jarosch reported IPsec TCP stalls when a PMTU event occurs.

In fact the problem was completely unrelated to IPsec.  The bug is
also reproducible if you just disable TSO/GSO.

The problem is that when the MSS goes down, existing queued packet
on the TX queue that have not been transmitted yet all look like
TSO packets and get treated as such.

This then triggers a bug where tcp_mss_split_point tells us to
generate a zero-sized packet on the TX queue.  Once that happens
we're screwed because the zero-sized packet can never be removed
by ACKs.

Fixes: 1485348d242 ("tcp: Apply device TSO segment limit earlier")
Reported-by: Thomas Jarosch <thomas.jarosch@intra2net.com>
Signed-off-by: Herbert Xu <herbert@gondor.apana.org.au>

diff --git a/net/ipv4/tcp_output.c b/net/ipv4/tcp_output.c
index 7f18262..65caf8b 100644
--- a/net/ipv4/tcp_output.c
+++ b/net/ipv4/tcp_output.c
@@ -2019,7 +2019,7 @@ static bool tcp_write_xmit(struct sock *sk, unsigned int mss_now, int nonagle,
 		if (unlikely(!tcp_snd_wnd_test(tp, skb, mss_now)))
 			break;
 
-		if (tso_segs == 1) {
+		if (tso_segs == 1 || !max_segs) {
 			if (unlikely(!tcp_nagle_test(tp, skb, mss_now,
 						     (tcp_skb_is_last(sk, skb) ?
 						      nonagle : TCP_NAGLE_PUSH))))
@@ -2032,7 +2032,7 @@ static bool tcp_write_xmit(struct sock *sk, unsigned int mss_now, int nonagle,
 		}
 
 		limit = mss_now;
-		if (tso_segs > 1 && !tcp_urg_mode(tp))
+		if (tso_segs > 1 && max_segs && !tcp_urg_mode(tp))
 			limit = tcp_mss_split_point(sk, skb, mss_now,
 						    min_t(unsigned int,
 							  cwnd_quota,

Cheers,
-- 
Email: Herbert Xu <herbert@gondor.apana.org.au>
Home Page: http://gondor.apana.org.au/~herbert/
PGP Key: http://gondor.apana.org.au/~herbert/pubkey.txt
