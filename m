From: "=?ISO-8859-15?Q?Ilpo_J=E4rvinen?=" <ilpo.jarvinen@helsinki.fi>
Subject: Re: [Bugme-new] [Bug 18952] New: The mount of SYN retries is not
 equal to /proc/sys/net/ipv4/tcp_syn_retries
Date: Tue, 28 Sep 2010 12:47:23 +0300 (EEST)
Message-ID: <alpine.DEB.2.00.1009281244040.26447@wel-95.cs.helsinki.fi>
References: <201009271007.06705.yuri@itinteg.net> <1285617608.9983.30.camel@nexus> <20100927.215241.246534990.davem@davemloft.net> <201009280940.53153.yuri@itinteg.net>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: David Miller <davem@davemloft.net>, damian@tvk.rwth-aachen.de,
	Andrew Morton <akpm@linux-foundation.org>,
	Netdev <netdev@vger.kernel.org>,
	bugzilla-daemon@bugzilla.kernel.org,
	bugme-daemon@bugzilla.kernel.org
To: Yuri Chislov <yuri@itinteg.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from courier.cs.helsinki.fi ([128.214.9.1]:54246 "EHLO
	mail.cs.helsinki.fi" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1753527Ab0I1Jr0 (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 28 Sep 2010 05:47:26 -0400
In-Reply-To: <201009280940.53153.yuri@itinteg.net>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Tue, 28 Sep 2010, Yuri Chislov wrote:

>  What is advantage in the replace compare by calculation?
> Please clarify, if possible.
> Thanks.
> Yuri.     

If you did take this from kernel history, reading the particular log 
message might have helped?!?

> --- linux-2.6.31.14/net/ipv4/tcp_timer.c        2010-07-05 17:11:43.000000000 
> +0000
> +++ linux-2.6.32.15/net/ipv4/tcp_timer.c        2010-06-01 16:56:03.000000000 
> +0000
> @@ -137,13 +137,14 @@
>  {
>         struct inet_connection_sock *icsk = inet_csk(sk);
>         int retry_until;
> +       bool do_reset;
>  
>         if ((1 << sk->sk_state) & (TCPF_SYN_SENT | TCPF_SYN_RECV)) {
>                 if (icsk->icsk_retransmits)
>                         dst_negative_advice(&sk->sk_dst_cache);
>                 retry_until = icsk->icsk_syn_retries ? : 
> sysctl_tcp_syn_retries;
>         } else {
> -               if (icsk->icsk_retransmits >= sysctl_tcp_retries1) {
> +               if (retransmits_timed_out(sk, sysctl_tcp_retries1)) {
>                         /* Black hole detection */
>                         tcp_mtu_probing(icsk, sk);
>  
> @@ -155,13 +156,15 @@
>                         const int alive = (icsk->icsk_rto < TCP_RTO_MAX);
>  
>                         retry_until = tcp_orphan_retries(sk, alive);
> +                       do_reset = alive ||
> +                                  !retransmits_timed_out(sk, retry_until);
>  
> -                       if (tcp_out_of_resources(sk, alive || icsk-
> >icsk_retransmits < retry_until))
> +                       if (tcp_out_of_resources(sk, do_reset))
>                                 return 1;
>                 }
>         }
>  
> -       if (icsk->icsk_retransmits >= retry_until) {
> +       if (retransmits_timed_out(sk, retry_until)) {
>                 /* Has it gone just too far? */
>                 tcp_write_err(sk);
>                 return 1;
> @@ -279,7 +282,7 @@
>   *     The TCP retransmit timer.
>   */
>  
> -static void tcp_retransmit_timer(struct sock *sk)
> +void tcp_retransmit_timer(struct sock *sk)
>  {
>         struct tcp_sock *tp = tcp_sk(sk);
>         struct inet_connection_sock *icsk = inet_csk(sk);
> @@ -385,7 +388,7 @@
>  out_reset_timer:
>         icsk->icsk_rto = min(icsk->icsk_rto << 1, TCP_RTO_MAX);
>         inet_csk_reset_xmit_timer(sk, ICSK_TIME_RETRANS, icsk->icsk_rto, 
> TCP_RTO_MAX);
> -       if (icsk->icsk_retransmits > sysctl_tcp_retries1)
> +       if (retransmits_timed_out(sk, sysctl_tcp_retries1 + 1))
>                 __sk_dst_reset(sk);
>  
>  out:;
> @@ -499,8 +502,7 @@
>         elapsed = tcp_time_stamp - tp->rcv_tstamp;
>  
>         if (elapsed >= keepalive_time_when(tp)) {
> -               if ((!tp->keepalive_probes && icsk->icsk_probes_out >= 
> sysctl_tcp_keepalive_probes) ||
> -                    (tp->keepalive_probes && icsk->icsk_probes_out >= tp-
> >keepalive_probes)) {
> +               if (icsk->icsk_probes_out >= keepalive_probes(tp)) {
>                         tcp_send_active_reset(sk, GFP_ATOMIC);
>                         tcp_write_err(sk);


-- 
 i.
