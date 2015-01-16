From: Thomas Jarosch <thomas.jarosch@intra2net.com>
Subject: Re: tcp: Do not apply TSO segment limit to non-TSO packets
Date: Fri, 16 Jan 2015 11:45:44 +0100
Message-ID: <74814478.Xs0dcijNdd@storm>
References: <1709726.jUgUSQI9sl@pikkukde.a.i2n> <20141201102522.GA16579@gondor.apana.org.au> <20141231133923.GA30248@gondor.apana.org.au>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7Bit
Cc: netdev@vger.kernel.org, edumazet@google.com,
	Steffen Klassert <steffen.klassert@secunet.com>,
	Ben Hutchings <bhutchings@solarflare.com>,
	"David S. Miller" <davem@davemloft.net>
To: Herbert Xu <herbert@gondor.apana.org.au>
Return-path: <netdev-owner@vger.kernel.org>
Received: from rs04.intra2net.com ([85.214.66.2]:33908 "EHLO
	rs04.intra2net.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752633AbbAPKpw (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 16 Jan 2015 05:45:52 -0500
In-Reply-To: <20141231133923.GA30248@gondor.apana.org.au>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Thursday, 1. January 2015 00:39:23 Herbert Xu wrote:
> On Mon, Dec 01, 2014 at 06:25:22PM +0800, Herbert Xu wrote:
> > Thomas Jarosch <thomas.jarosch@intra2net.com> wrote:
> > > When I revert it, even kernel v3.18-rc6 starts working.
> > > But I doubt this is the root problem, may be just hiding another
> > > issue.
> > 
> > Can you do a tcpdump with this patch reverted? I would like to
> > see the size of the packets that are sent out vs. the ICMP message
> > that came back.
> 
> Thanks for providing the data.  Here is a patch that should fix
> the problem.

Thanks for the fix, Herbert! I've verified the patch is working fine
and the tcpdump looks good, too. In fact the PMTU discovery
only takes 0.001s, you can barely notice it ;)

For backporting to -stable: Kernel 3.14 lacks tcp_tso_autosize().
So I've borrowed that from 3.19-rc4+ and also added the max_segs variable.
The final and tested code looks like this:

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
Signed-off-by: Thomas Jarosch <thomas.jarosch@intra2net.com>

diff --git a/net/ipv4/tcp_output.c b/net/ipv4/tcp_output.c
index 17a11e6..a109032 100644
--- a/net/ipv4/tcp_output.c
+++ b/net/ipv4/tcp_output.c
@@ -1432,6 +1432,27 @@ static bool tcp_nagle_check(bool partial, const struct tcp_sock *tp,
 		((nonagle & TCP_NAGLE_CORK) ||
 		 (!nonagle && tp->packets_out && tcp_minshall_check(tp)));
 }
+
+/* Return how many segs we'd like on a TSO packet,
+ * to send one TSO packet per ms
+ */
+static u32 tcp_tso_autosize(const struct sock *sk, unsigned int mss_now)
+{
+	u32 bytes, segs;
+
+	bytes = min(sk->sk_pacing_rate >> 10,
+		    sk->sk_gso_max_size - 1 - MAX_TCP_HEADER);
+
+	/* Goal is to send at least one packet per ms,
+	* not one big TSO packet every 100 ms.
+	* This preserves ACK clocking and is consistent
+	* with tcp_tso_should_defer() heuristic.
+	*/
+	segs = max_t(u32, bytes / mss_now, sysctl_tcp_min_tso_segs);
+
+	return min_t(u32, segs, sk->sk_gso_max_segs);
+}
+
 /* Returns the portion of skb which can be sent right away */
 static unsigned int tcp_mss_split_point(const struct sock *sk,
 					const struct sk_buff *skb,
@@ -1857,6 +1878,7 @@ static bool tcp_write_xmit(struct sock *sk, unsigned int mss_now, int nonagle,
 	unsigned int tso_segs, sent_pkts;
 	int cwnd_quota;
 	int result;
+	u32 max_segs;
 
 	sent_pkts = 0;
 
@@ -1870,6 +1892,7 @@ static bool tcp_write_xmit(struct sock *sk, unsigned int mss_now, int nonagle,
 		}
 	}
 
+	max_segs = tcp_tso_autosize(sk, mss_now);
 	while ((skb = tcp_send_head(sk))) {
 		unsigned int limit;
 
@@ -1891,7 +1914,7 @@ static bool tcp_write_xmit(struct sock *sk, unsigned int mss_now, int nonagle,
 		if (unlikely(!tcp_snd_wnd_test(tp, skb, mss_now)))
 			break;
 
-		if (tso_segs == 1) {
+		if (tso_segs == 1 || !max_segs) {
 			if (unlikely(!tcp_nagle_test(tp, skb, mss_now,
 						     (tcp_skb_is_last(sk, skb) ?
 						      nonagle : TCP_NAGLE_PUSH))))
@@ -1928,7 +1951,7 @@ static bool tcp_write_xmit(struct sock *sk, unsigned int mss_now, int nonagle,
 		}
 
 		limit = mss_now;
-		if (tso_segs > 1 && !tcp_urg_mode(tp))
+		if (tso_segs > 1 && max_segs && !tcp_urg_mode(tp))
 			limit = tcp_mss_split_point(sk, skb, mss_now,
 						    min_t(unsigned int,
 							  cwnd_quota,
-- 
1.9.3
