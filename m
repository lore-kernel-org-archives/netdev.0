From: Chao Pei <peichao85@gmail.com>
Subject: Question about timewait timer
Date: Wed, 28 Mar 2012 22:21:59 +0800
Message-ID: <CAJkE24+8NJfkgLRTvUiMyCC=qZ9bnKWTr7pBXtaC8YPMOyMfew@mail.gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-ee0-f46.google.com ([74.125.83.46]:50747 "EHLO
	mail-ee0-f46.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1758141Ab2C1OWA (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 28 Mar 2012 10:22:00 -0400
Received: by eekc41 with SMTP id c41so306896eek.19
        for <netdev@vger.kernel.org>; Wed, 28 Mar 2012 07:21:59 -0700 (PDT)
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Hi,
    I have a qestion about timewait timer in tcp_keepalive_timer. In
the following code:

int tcp_rcv_state_process(struct sock *sk, struct sk_buff *skb,
			  const struct tcphdr *th, unsigned int len)
{
    .....
    case FIN_WAIT_1:
    ......
            tmo = tcp_fin_time(sk);
            if (tmo > TCP_TIMEWAIT_LEN) {
                inet_csk_reset_keepalive_timer(sk, tmo - TCP_TIMEWAIT_LEN);
            } else if (.....)
    ......
}

    If tmo is larger than TCP_TIMEWAIT_LEN and the FIN flag is not
set, schedule keepalive timer. But in tcp_keepalive_timer, the timer
is set to tcp_fin_time(sk) -TCP_TIMEWAIT_LEN again. See the source
code below:
	if (sk->sk_state == TCP_FIN_WAIT2 && sock_flag(sk, SOCK_DEAD)) {
		if (tp->linger2 >= 0) {
			const int tmo = tcp_fin_time(sk) - TCP_TIMEWAIT_LEN;

			if (tmo > 0) {
				tcp_time_wait(sk, TCP_FIN_WAIT2, tmo);
				goto out;
			}
		}
		.....
	}

    I think the first piece of code set keepalive timer to
tmo-TCP_TIMEWAIT_LEN is because TCP_TIMEWAIT_LEN is the longest timer
that tcp_death_row can handle. So the extra time should be taken care
of by the keepalive timer first. If this is correct, then the timer
should be set to TCP_TIMEWAIT_LEN in tcp_keepalive_timer, instead of
tcp_fin_time(sk) - TCP_TIMEWAIT_LEN.

Thanks.
