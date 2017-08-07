From: Stephen Rothwell <sfr@canb.auug.org.au>
Subject: linux-next: manual merge of the net-next tree with the net tree
Date: Mon, 7 Aug 2017 12:01:13 +1000
Message-ID: <20170807120113.5e51eec0@canb.auug.org.au>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Cc: Linux-Next Mailing List <linux-next@vger.kernel.org>,
        Linux Kernel Mailing List <linux-kernel@vger.kernel.org>,
        Neal Cardwell <ncardwell@google.com>,
        Yuchung Cheng <ycheng@google.com>
To: David Miller <davem@davemloft.net>,
        Networking <netdev@vger.kernel.org>
Return-path: <linux-kernel-owner@vger.kernel.org>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Hi all,

Today's linux-next merge of the net-next tree got a conflict in:

  net/ipv4/tcp_output.c

between commit:

  a2815817ffa6 ("tcp: enable xmit timer fix by having TLP use time when RTO should fire")

from the net tree and commit:

  bb4d991a28cc ("tcp: adjust tail loss probe timeout")

from the net-next tree.

I fixed it up (see below) and can carry the fix as necessary. This
is now fixed as far as linux-next is concerned, but any non trivial
conflicts should be mentioned to your upstream maintainer when your tree
is submitted for merging.  You may also want to consider cooperating
with the maintainer of the conflicting tree to minimise any particularly
complex conflicts.

-- 
Cheers,
Stephen Rothwell

diff --cc net/ipv4/tcp_output.c
index 276406a83a37,d49bff51bdb7..000000000000
--- a/net/ipv4/tcp_output.c
+++ b/net/ipv4/tcp_output.c
@@@ -2377,9 -2375,13 +2375,8 @@@ bool tcp_schedule_loss_probe(struct soc
  {
  	struct inet_connection_sock *icsk = inet_csk(sk);
  	struct tcp_sock *tp = tcp_sk(sk);
- 	u32 rtt = usecs_to_jiffies(tp->srtt_us >> 3);
 -	u32 timeout, tlp_time_stamp, rto_time_stamp;
 +	u32 timeout, rto_delta_us;
  
 -	/* No consecutive loss probes. */
 -	if (WARN_ON(icsk->icsk_pending == ICSK_TIME_LOSS_PROBE)) {
 -		tcp_rearm_rto(sk);
 -		return false;
 -	}
  	/* Don't do any loss probe on a Fast Open connection before 3WHS
  	 * finishes.
  	 */
@@@ -2402,16 -2408,24 +2399,20 @@@
  	 * for delayed ack when there's one outstanding packet. If no RTT
  	 * sample is available then probe after TCP_TIMEOUT_INIT.
  	 */
- 	timeout = rtt << 1 ? : TCP_TIMEOUT_INIT;
- 	if (tp->packets_out == 1)
- 		timeout = max_t(u32, timeout,
- 				(rtt + (rtt >> 1) + TCP_DELACK_MAX));
- 	timeout = max_t(u32, timeout, msecs_to_jiffies(10));
+ 	if (tp->srtt_us) {
+ 		timeout = usecs_to_jiffies(tp->srtt_us >> 2);
+ 		if (tp->packets_out == 1)
+ 			timeout += TCP_RTO_MIN;
+ 		else
+ 			timeout += TCP_TIMEOUT_MIN;
+ 	} else {
+ 		timeout = TCP_TIMEOUT_INIT;
+ 	}
  
 -	/* If RTO is shorter, just schedule TLP in its place. */
 -	tlp_time_stamp = tcp_jiffies32 + timeout;
 -	rto_time_stamp = (u32)inet_csk(sk)->icsk_timeout;
 -	if ((s32)(tlp_time_stamp - rto_time_stamp) > 0) {
 -		s32 delta = rto_time_stamp - tcp_jiffies32;
 -		if (delta > 0)
 -			timeout = delta;
 -	}
 +	/* If the RTO formula yields an earlier time, then use that time. */
 +	rto_delta_us = tcp_rto_delta_us(sk);  /* How far in future is RTO? */
 +	if (rto_delta_us > 0)
 +		timeout = min_t(u32, timeout, usecs_to_jiffies(rto_delta_us));
  
  	inet_csk_reset_xmit_timer(sk, ICSK_TIME_LOSS_PROBE, timeout,
  				  TCP_RTO_MAX);
