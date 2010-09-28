From: Yuri Chislov <yuri@itinteg.net>
Subject: Re: [Bugme-new] [Bug 18952] New: The mount of SYN retries is not equal to /proc/sys/net/ipv4/tcp_syn_retries
Date: Tue, 28 Sep 2010 09:40:52 +0200
Message-ID: <201009280940.53153.yuri@itinteg.net>
References: <201009271007.06705.yuri@itinteg.net> <1285617608.9983.30.camel@nexus> <20100927.215241.246534990.davem@davemloft.net>
Mime-Version: 1.0
Content-Type: Text/Plain;
  charset="iso-8859-1"
Content-Transfer-Encoding: 7bit
Cc: damian@tvk.rwth-aachen.de, akpm@linux-foundation.org,
	netdev@vger.kernel.org, bugzilla-daemon@bugzilla.kernel.org,
	bugme-daemon@bugzilla.kernel.org
To: David Miller <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from gw-0.itinteg.net ([212.235.43.25]:58403 "EHLO gw-0.itinteg.net"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1752978Ab0I1HjY (ORCPT <rfc822;netdev@vger.kernel.org>);
	Tue, 28 Sep 2010 03:39:24 -0400
In-Reply-To: <20100927.215241.246534990.davem@davemloft.net>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

 What is advantage in the replace compare by calculation?
Please clarify, if possible.
Thanks.
Yuri.     


--- linux-2.6.31.14/net/ipv4/tcp_timer.c        2010-07-05 17:11:43.000000000 
+0000
+++ linux-2.6.32.15/net/ipv4/tcp_timer.c        2010-06-01 16:56:03.000000000 
+0000
@@ -137,13 +137,14 @@
 {
        struct inet_connection_sock *icsk = inet_csk(sk);
        int retry_until;
+       bool do_reset;
 
        if ((1 << sk->sk_state) & (TCPF_SYN_SENT | TCPF_SYN_RECV)) {
                if (icsk->icsk_retransmits)
                        dst_negative_advice(&sk->sk_dst_cache);
                retry_until = icsk->icsk_syn_retries ? : 
sysctl_tcp_syn_retries;
        } else {
-               if (icsk->icsk_retransmits >= sysctl_tcp_retries1) {
+               if (retransmits_timed_out(sk, sysctl_tcp_retries1)) {
                        /* Black hole detection */
                        tcp_mtu_probing(icsk, sk);
 
@@ -155,13 +156,15 @@
                        const int alive = (icsk->icsk_rto < TCP_RTO_MAX);
 
                        retry_until = tcp_orphan_retries(sk, alive);
+                       do_reset = alive ||
+                                  !retransmits_timed_out(sk, retry_until);
 
-                       if (tcp_out_of_resources(sk, alive || icsk-
>icsk_retransmits < retry_until))
+                       if (tcp_out_of_resources(sk, do_reset))
                                return 1;
                }
        }
 
-       if (icsk->icsk_retransmits >= retry_until) {
+       if (retransmits_timed_out(sk, retry_until)) {
                /* Has it gone just too far? */
                tcp_write_err(sk);
                return 1;
@@ -279,7 +282,7 @@
  *     The TCP retransmit timer.
  */
 
-static void tcp_retransmit_timer(struct sock *sk)
+void tcp_retransmit_timer(struct sock *sk)
 {
        struct tcp_sock *tp = tcp_sk(sk);
        struct inet_connection_sock *icsk = inet_csk(sk);
@@ -385,7 +388,7 @@
 out_reset_timer:
        icsk->icsk_rto = min(icsk->icsk_rto << 1, TCP_RTO_MAX);
        inet_csk_reset_xmit_timer(sk, ICSK_TIME_RETRANS, icsk->icsk_rto, 
TCP_RTO_MAX);
-       if (icsk->icsk_retransmits > sysctl_tcp_retries1)
+       if (retransmits_timed_out(sk, sysctl_tcp_retries1 + 1))
                __sk_dst_reset(sk);
 
 out:;
@@ -499,8 +502,7 @@
        elapsed = tcp_time_stamp - tp->rcv_tstamp;
 
        if (elapsed >= keepalive_time_when(tp)) {
-               if ((!tp->keepalive_probes && icsk->icsk_probes_out >= 
sysctl_tcp_keepalive_probes) ||
-                    (tp->keepalive_probes && icsk->icsk_probes_out >= tp-
>keepalive_probes)) {
+               if (icsk->icsk_probes_out >= keepalive_probes(tp)) {
                        tcp_send_active_reset(sk, GFP_ATOMIC);
                        tcp_write_err(sk);
                        goto out;


On Tuesday, September 28, 2010 06:52:41 am David Miller wrote:
> From: Damian Lukowski <damian@tvk.rwth-aachen.de>
> Date: Mon, 27 Sep 2010 22:00:08 +0200
> 
> > My suggestion for solving this issue:
> > Introducing a third boolean parameter for retransmits_timed_out()
> > indicating whether the socket is in SYN state or not. In the SYN case,
> > TCP_TIMEOUT_INIT will be used for the calculation instead of
> > TCP_RTO_MIN.
> > 
> > Is that ok?
> 
> Sounds fine to me, please prepare a patch.
> 
> Thanks!
