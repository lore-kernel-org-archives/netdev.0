From: Herbert Xu <herbert@gondor.apana.org.au>
Subject: Re: 2.6.9 failed assertion in tcp_timer.c
Date: Sat, 23 Oct 2004 09:24:03 +1000
Sender: netdev-bounce@oss.sgi.com
Message-ID: <20041022232403.GA14618@gondor.apana.org.au>
References: <20041019215054.GA17565@linuxace.com> <E1CK3Az-0004P2-00@gondolin.me.apana.org.au> <20041020164748.GA20905@linuxace.com> <20041020212651.GA8534@gondor.apana.org.au> <20041020225536.GA22179@linuxace.com> <20041021130339.GA19345@gondor.apana.org.au> <20041021165224.GA25399@linuxace.com> <20041021215743.GA23062@gondor.apana.org.au> <20041022185435.GA30709@linuxace.com> <20041022215040.GA13309@gondor.apana.org.au>
Mime-Version: 1.0
Content-Type: multipart/mixed; boundary="MGYHOYXEY6WxJCY8"
Cc: linux-net@vger.kernel.org, netdev@oss.sgi.com,
        "David S. Miller" <davem@davemloft.net>
Return-path: <netdev-bounce@oss.sgi.com>
To: Phil Oester <kernel@linuxace.com>
Content-Disposition: inline
In-Reply-To: <20041022215040.GA13309@gondor.apana.org.au>
Errors-to: netdev-bounce@oss.sgi.com
List-Id: netdev.vger.kernel.org


--MGYHOYXEY6WxJCY8
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline

On Sat, Oct 23, 2004 at 07:50:40AM +1000, herbert wrote:
>
> So we don't really know whether it went further or not :)

Actually, I think we've caught your crash now.  If that code path
is triggering at all, then it'll trigger with TSO packets too.  If
we get a truly partial ack on a TSO packet, then tcp_tso_acked will
not trim it off.  So we will fall through to this last-ditch trim
call, which doesn't update packets_out.

There are two solutions to this problem.  I've taken the simpler
approach for now.  We simply trim off the partial bits in tcp_tso_acked
and live with the fact that the packet counters may differ from
what's on the netwrok by one.

Signed-off-by: Herbert Xu <herbert@gondor.apana.org.au>

Later on we can "fix" this by remembering where the original TSO
packet started from, perhaps in skb->h or somewhere.  Dave, is this
worth it?

Cheers,
-- 
Visit Openswan at http://www.openswan.org/
Email: Herbert Xu ~{PmV>HI~} <herbert@gondor.apana.org.au>
Home Page: http://gondor.apana.org.au/~herbert/
PGP Key: http://gondor.apana.org.au/~herbert/pubkey.txt

--MGYHOYXEY6WxJCY8
Content-Type: text/plain; charset=us-ascii
Content-Disposition: attachment; filename=p

===== net/ipv4/tcp_input.c 1.81 vs edited =====
--- 1.81/net/ipv4/tcp_input.c	2004-10-04 07:31:39 +10:00
+++ edited/net/ipv4/tcp_input.c	2004-10-23 09:12:42 +10:00
@@ -2369,25 +2369,19 @@
 {
 	struct tcp_opt *tp = tcp_sk(sk);
 	struct tcp_skb_cb *scb = TCP_SKB_CB(skb); 
-	__u32 mss = tcp_skb_mss(skb);
-	__u32 snd_una = tp->snd_una;
-	__u32 orig_seq, seq;
-	__u32 packets_acked = 0;
+	__u32 seq = tp->snd_una;
+	__u32 packets_acked;
 	int acked = 0;
 
 	/* If we get here, the whole TSO packet has not been
 	 * acked.
 	 */
-	BUG_ON(!after(scb->end_seq, snd_una));
+	BUG_ON(!after(scb->end_seq, seq));
 
-	seq = orig_seq = scb->seq;
-	while (!after(seq + mss, snd_una)) {
-		packets_acked++;
-		seq += mss;
-	}
-
-	if (tcp_trim_head(sk, skb, (seq - orig_seq)))
+	packets_acked = tcp_skb_pcount(skb);
+	if (tcp_trim_head(sk, skb, seq - scb->seq))
 		return 0;
+	packets_acked -= tcp_skb_pcount(skb);
 
 	if (packets_acked) {
 		__u8 sacked = scb->sacked;
--- linux-2.6/net/ipv4/tcp_output.c.orig	2004-10-23 08:44:16.000000000 +1000
+++ linux-2.6/net/ipv4/tcp_output.c	2004-10-23 09:10:13.000000000 +1000
@@ -588,7 +588,7 @@
 	/* Any change of skb->len requires recalculation of tso
 	 * factor and mss.
 	 */
-	if (tcp_skb_mss(skb))
+	if (tcp_skb_pcount(skb) > 1)
 		tcp_set_skb_tso_segs(skb, tcp_skb_mss(skb));
 
 	return 0;

--MGYHOYXEY6WxJCY8--
