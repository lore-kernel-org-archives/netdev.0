From: "David S. Miller" <davem@davemloft.net>
Subject: Re: bad TSO performance in 2.6.9-rc2-BK
Date: Wed, 29 Sep 2004 16:29:23 -0700
Sender: netdev-bounce@oss.sgi.com
Message-ID: <20040929162923.796d142e.davem@davemloft.net>
References: <Pine.NEB.4.33.0409291648560.3434-100000@dexter.psc.edu>
	<415B24C0.2020208@us.ibm.com>
	<20040929145050.71afa1ac.davem@davemloft.net>
	<20040929215613.GC26714@wotan.suse.de>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Cc: niv@us.ibm.com, jheffner@psc.edu, ak@suse.de, herbert@gondor.apana.org.au,
        andy.grover@gmail.com, anton@samba.org, netdev@oss.sgi.com
Return-path: <netdev-bounce@oss.sgi.com>
To: Andi Kleen <ak@suse.de>
In-Reply-To: <20040929215613.GC26714@wotan.suse.de>
Errors-to: netdev-bounce@oss.sgi.com
List-Id: netdev.vger.kernel.org


Ok, found the bug.  This bug was in the existing code and
the assertions in the new code was merely discovering it.

What happens is that we set TCP_SKB_CB(skb)->tso_factor,
for tcp_snd_test() or similar, for example.  But this packet
does not go out, and tcp_sendmsg() or tcp_sendpages() tacks
more data onto the tail of the SKB without updating
TCP_SKB_CB(skb)->tso_factor.

Simply setting the tso_factor to zero in these cases gets
it recalculated, and reduces the number of tso_factor
recalculations.  This works because by definition these
SKBs have not been sent for the first time yet.  We never
tack data onto the end of retransmitted SKBs.  And because
of that invariante there will be a tcp_set_skb_tso_factor()
call before it gets to tcp_transmit_skb() (which will BUG
otherwise).

I've also audited other spots that don't update the tso_factor
when they should, tcp_trim_head() was another such spot.
Finally, I added an assertion to retransmit queue collapsing
to make sure we don't collapse SKBs with non-1 TSO factors.
And the Solaris FIN workaround pskb_trim() needs to reset
the TSO factor as well.

Let me know if this cures the issue, and if it does we can
move back to Andi's performance issue and the MSS stuff
John Heffner just discovered.

# This is a BitKeeper generated diff -Nru style patch.
#
# ChangeSet
#   2004/09/29 16:09:18-07:00 davem@nuts.davemloft.net 
#   [TCP]: Fix inaccuracies in tso_factor settings.
#   
#   1) If tcp_{sendmsg,sendpage} tacks on more data to an
#      existing SKB, this can make tso_factor inaccurate.
#      Invalidate it, which forces it to be recalculated,
#      by simply setting it to zero.
#   2) __tcp_trim_head() changes skb->len thus we need
#      to recalculate tso_factor
#   3) BUG check that tcp_retrans_try_collapse() does not
#      try to collapse packets with non-1 tso_factor
#   4) The Solaris FIN workaround in tcp_retransmit_skb()
#      changes packet size, need to fixup tso_factor
#   
#   Signed-off-by: David S. Miller <davem@davemloft.net>
# 
# net/ipv4/tcp_output.c
#   2004/09/29 16:06:54-07:00 davem@nuts.davemloft.net +15 -5
#   [TCP]: Fix inaccuracies in tso_factor settings.
# 
# net/ipv4/tcp.c
#   2004/09/29 16:06:54-07:00 davem@nuts.davemloft.net +2 -0
#   [TCP]: Fix inaccuracies in tso_factor settings.
# 
diff -Nru a/net/ipv4/tcp.c b/net/ipv4/tcp.c
--- a/net/ipv4/tcp.c	2004-09-29 16:09:42 -07:00
+++ b/net/ipv4/tcp.c	2004-09-29 16:09:42 -07:00
@@ -691,6 +691,7 @@
 		skb->ip_summed = CHECKSUM_HW;
 		tp->write_seq += copy;
 		TCP_SKB_CB(skb)->end_seq += copy;
+		TCP_SKB_CB(skb)->tso_factor = 0;
 
 		if (!copied)
 			TCP_SKB_CB(skb)->flags &= ~TCPCB_FLAG_PSH;
@@ -937,6 +938,7 @@
 
 			tp->write_seq += copy;
 			TCP_SKB_CB(skb)->end_seq += copy;
+			TCP_SKB_CB(skb)->tso_factor = 0;
 
 			from += copy;
 			copied += copy;
diff -Nru a/net/ipv4/tcp_output.c b/net/ipv4/tcp_output.c
--- a/net/ipv4/tcp_output.c	2004-09-29 16:09:42 -07:00
+++ b/net/ipv4/tcp_output.c	2004-09-29 16:09:42 -07:00
@@ -553,7 +553,7 @@
 	return skb->tail;
 }
 
-static int __tcp_trim_head(struct sock *sk, struct sk_buff *skb, u32 len)
+static int __tcp_trim_head(struct tcp_opt *tp, struct sk_buff *skb, u32 len)
 {
 	if (skb_cloned(skb) &&
 	    pskb_expand_head(skb, 0, 0, GFP_ATOMIC))
@@ -567,12 +567,18 @@
 	}
 
 	skb->ip_summed = CHECKSUM_HW;
+
+	/* Any change of skb->len requires recalculation of tso
+	 * factor and mss.
+	 */
+	tcp_set_skb_tso_factor(skb, tp->mss_cache_std);
+
 	return 0;
 }
 
-static inline int tcp_trim_head(struct sock *sk, struct sk_buff *skb, u32 len)
+static inline int tcp_trim_head(struct tcp_opt *tp, struct sk_buff *skb, u32 len)
 {
-	int err = __tcp_trim_head(sk, skb, len);
+	int err = __tcp_trim_head(tp, skb, len);
 
 	if (!err)
 		TCP_SKB_CB(skb)->seq += len;
@@ -897,6 +903,9 @@
 		    ((skb_size + next_skb_size) > mss_now))
 			return;
 
+		BUG_ON(TCP_SKB_CB(skb)->tso_factor != 1 ||
+		       TCP_SKB_CB(next_skb)->tso_factor != 1);
+
 		/* Ok.  We will be able to collapse the packet. */
 		__skb_unlink(next_skb, next_skb->list);
 
@@ -1018,7 +1027,7 @@
 	if (skb->len > (data_end_seq - data_seq)) {
 		u32 to_trim = skb->len - (data_end_seq - data_seq);
 
-		if (__tcp_trim_head(sk, skb, to_trim))
+		if (__tcp_trim_head(tp, skb, to_trim))
 			return -ENOMEM;
 	}		
 
@@ -1032,7 +1041,7 @@
 			tp->mss_cache = tp->mss_cache_std;
 		}
 
-		if (tcp_trim_head(sk, skb, tp->snd_una - TCP_SKB_CB(skb)->seq))
+		if (tcp_trim_head(tp, skb, tp->snd_una - TCP_SKB_CB(skb)->seq))
 			return -ENOMEM;
 	}
 
@@ -1080,6 +1089,7 @@
 	   tp->snd_una == (TCP_SKB_CB(skb)->end_seq - 1)) {
 		if (!pskb_trim(skb, 0)) {
 			TCP_SKB_CB(skb)->seq = TCP_SKB_CB(skb)->end_seq - 1;
+			TCP_SKB_CB(skb)->tso_factor = 1;
 			skb->ip_summed = CHECKSUM_NONE;
 			skb->csum = 0;
 		}
