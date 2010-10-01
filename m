From: Stephen Rothwell <sfr@canb.auug.org.au>
Subject: linux-next: manual merge of the net tree with the net-current tree
Date: Fri, 1 Oct 2010 12:48:30 +1000
Message-ID: <20101001124830.9c35d36f.sfr@canb.auug.org.au>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Cc: linux-next@vger.kernel.org, linux-kernel@vger.kernel.org,
	Damian Lukowski <damian@tvk.rwth-aachen.de>,
	Jerry Chu <hkchu@google.com>
To: David Miller <davem@davemloft.net>, <netdev@vger.kernel.org>
Return-path: <linux-kernel-owner@vger.kernel.org>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Hi all,

Today's linux-next merge of the net tree got a conflict in
net/ipv4/tcp_timer.c between commit
4d22f7d372f5769c6c0149e427ed6353e2dcfe61 ("net-2.6: SYN retransmits: Add
new parameter to retransmits_timed_out()") from the net-current tree and
commit dca43c75e7e545694a9dd6288553f55c53e2a3a3 ("tcp: Add
TCP_USER_TIMEOUT socket option") from the net tree.

I fixed it up (see below) and can carry the fix as necessary.
-- 
Cheers,
Stephen Rothwell                    sfr@canb.auug.org.au

diff --cc net/ipv4/tcp_timer.c
index 74c54b3,baea4a1..0000000
--- a/net/ipv4/tcp_timer.c
+++ b/net/ipv4/tcp_timer.c
@@@ -140,11 -139,9 +140,11 @@@ static void tcp_mtu_probing(struct inet
   */
  static bool retransmits_timed_out(struct sock *sk,
  				  unsigned int boundary,
 -				  unsigned int timeout)
++				  unsigned int timeout,
 +				  bool syn_set)
  {
- 	unsigned int timeout, linear_backoff_thresh;
- 	unsigned int start_ts;
+ 	unsigned int linear_backoff_thresh, start_ts;
 +	unsigned int rto_base = syn_set ? TCP_TIMEOUT_INIT : TCP_RTO_MIN;
  
  	if (!inet_csk(sk)->icsk_retransmits)
  		return false;
@@@ -154,14 -151,15 +154,16 @@@
  	else
  		start_ts = tcp_sk(sk)->retrans_stamp;
  
- 	linear_backoff_thresh = ilog2(TCP_RTO_MAX/rto_base);
+ 	if (likely(timeout == 0)) {
 -		linear_backoff_thresh = ilog2(TCP_RTO_MAX/TCP_RTO_MIN);
++		linear_backoff_thresh = ilog2(TCP_RTO_MAX/rto_base);
  
- 	if (boundary <= linear_backoff_thresh)
- 		timeout = ((2 << boundary) - 1) * rto_base;
- 	else
- 		timeout = ((2 << linear_backoff_thresh) - 1) * rto_base +
- 			  (boundary - linear_backoff_thresh) * TCP_RTO_MAX;
+ 		if (boundary <= linear_backoff_thresh)
 -			timeout = ((2 << boundary) - 1) * TCP_RTO_MIN;
++			timeout = ((2 << boundary) - 1) * rto_base;
+ 		else
 -			timeout = ((2 << linear_backoff_thresh) - 1) * TCP_RTO_MIN +
++			timeout = ((2 << linear_backoff_thresh) - 1) * rto_base +
+ 				(boundary - linear_backoff_thresh) * TCP_RTO_MAX;
 +
+ 	}
  	return (tcp_time_stamp - start_ts) >= timeout;
  }
  
@@@ -176,9 -174,8 +178,9 @@@ static int tcp_write_timeout(struct soc
  		if (icsk->icsk_retransmits)
  			dst_negative_advice(sk);
  		retry_until = icsk->icsk_syn_retries ? : sysctl_tcp_syn_retries;
 +		syn_set = 1;
  	} else {
--		if (retransmits_timed_out(sk, sysctl_tcp_retries1, 0)) {
++		if (retransmits_timed_out(sk, sysctl_tcp_retries1, 0, 0)) {
  			/* Black hole detection */
  			tcp_mtu_probing(icsk, sk);
  
@@@ -191,14 -188,16 +193,16 @@@
  
  			retry_until = tcp_orphan_retries(sk, alive);
  			do_reset = alive ||
--				   !retransmits_timed_out(sk, retry_until, 0);
++				   !retransmits_timed_out(sk, retry_until, 0, 0);
  
  			if (tcp_out_of_resources(sk, do_reset))
  				return 1;
  		}
  	}
  
- 	if (retransmits_timed_out(sk, retry_until, syn_set)) {
+ 	if (retransmits_timed_out(sk, retry_until,
+ 	    (1 << sk->sk_state) & (TCPF_SYN_SENT | TCPF_SYN_RECV) ? 0 :
 -	    icsk->icsk_user_timeout)) {
++	    icsk->icsk_user_timeout, syn_set)) {
  		/* Has it gone just too far? */
  		tcp_write_err(sk);
  		return 1;
@@@ -440,7 -439,7 +444,7 @@@ out_reset_timer
  		icsk->icsk_rto = min(icsk->icsk_rto << 1, TCP_RTO_MAX);
  	}
  	inet_csk_reset_xmit_timer(sk, ICSK_TIME_RETRANS, icsk->icsk_rto, TCP_RTO_MAX);
--	if (retransmits_timed_out(sk, sysctl_tcp_retries1 + 1, 0))
++	if (retransmits_timed_out(sk, sysctl_tcp_retries1 + 1, 0, 0))
  		__sk_dst_reset(sk);
  
  out:;
