From: "David S. Miller" <davem@davemloft.net>
Subject: Re: bad TSO performance in 2.6.9-rc2-BK
Date: Wed, 22 Sep 2004 13:39:06 -0700
Sender: netdev-bounce@oss.sgi.com
Message-ID: <20040922133906.7d57ef49.davem@davemloft.net>
References: <20040920063012.GL2825@krispykreme>
	<20040920203021.GD4242@wotan.suse.de>
	<20040921155835.18aee381.davem@davemloft.net>
	<20040922140000.GD27432@wotan.suse.de>
	<20040922111209.7887df53.davem@davemloft.net>
	<20040922195515.GA2619@wotan.suse.de>
	<c0a09e5c04092213126ba5f29d@mail.gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Cc: ak@suse.de, anton@samba.org, netdev@oss.sgi.com
Return-path: <netdev-bounce@oss.sgi.com>
To: Andrew Grover <andy.grover@gmail.com>
In-Reply-To: <c0a09e5c04092213126ba5f29d@mail.gmail.com>
Errors-to: netdev-bounce@oss.sgi.com
List-Id: netdev.vger.kernel.org

On Wed, 22 Sep 2004 13:12:47 -0700
Andrew Grover <andy.grover@gmail.com> wrote:

> I think this is caused by the congestion changes added between
> 2.6.9-rc1 and rc2. I am seeing good performance with rc1 and tso on
> (or off), but bad performance with rc2 and bk-latest only if tso is
> on.

Yes, we know it is the packet counting change but those
are pretty much necessary else TSO violates congestion window
rules.

There is a slight bug somewhere limiting performance, but we'll
find it.

The thing to watch if you're debugging this is what tp->packets_out
is set to, and what happens in each tcp_snd_test() call.  Also, watch
tcp_cong_avoid() to make sure that tp->snd_cwnd is incrementing
on every ACK and that tp->snd_cwnd_clamp is not some silly small
value.

Tracking tcp_snd_test() should tell you everything, watch what
happens to the values of:

	tcp_packets_in_flight(tp);
	'pkts' aka. TCP_SKB_CB(skb)->tso_factor after the
	     possible tcp_set_skb_tso_factor() call
	tp->snd_cwnd

One thing that could be biting us is the nagle check which
probably needs to be adjusted to use the standard MSS not
the TSO one... perhaps play with this patch:

===== include/net/tcp.h 1.88 vs edited =====
--- 1.88/include/net/tcp.h	2004-09-14 13:57:07 -07:00
+++ edited/include/net/tcp.h	2004-09-22 13:18:43 -07:00
@@ -1505,7 +1505,7 @@
 	 * final FIN frame.  -DaveM
 	 */
 	return (((nonagle&TCP_NAGLE_PUSH) || tp->urg_mode
-		 || !tcp_nagle_check(tp, skb, cur_mss, nonagle)) &&
+		 || !tcp_nagle_check(tp, skb, tp->mss_cache_std, nonagle)) &&
 		(((tcp_packets_in_flight(tp) + (pkts-1)) < tp->snd_cwnd) ||
 		 (TCP_SKB_CB(skb)->flags & TCPCB_FLAG_FIN)) &&
 		!after(TCP_SKB_CB(skb)->end_seq, tp->snd_una + tp->snd_wnd));
