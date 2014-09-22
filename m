From: Joe Perches <joe@perches.com>
Subject: Re: [PATCH v2 net-next] tcp: avoid possible arithmetic overflows
Date: Sun, 21 Sep 2014 20:56:55 -0700
Message-ID: <1411358215.2952.26.camel@joe-AO725>
References: <1411233550.26859.76.camel@edumazet-glaptop2.roam.corp.google.com>
	 <1411236071.8612.6.camel@joe-AO725>
	 <CAK6E8=etvB4MUBu96ck+7yucbFLgbxvEPJ3TM8X5qBsZLTnhDg@mail.gmail.com>
	 <1411242956.26859.81.camel@edumazet-glaptop2.roam.corp.google.com>
	 <1411244392.10610.4.camel@joe-AO725>
	 <1411259357.26859.89.camel@edumazet-glaptop2.roam.corp.google.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="ISO-8859-1"
Content-Transfer-Encoding: 7bit
Cc: Yuchung Cheng <ycheng@google.com>,
	David Miller <davem@davemloft.net>,
	netdev <netdev@vger.kernel.org>,
	Neal Cardwell <ncardwell@google.com>
To: Eric Dumazet <eric.dumazet@gmail.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from smtprelay0208.hostedemail.com ([216.40.44.208]:37906 "EHLO
	smtprelay.hostedemail.com" rhost-flags-OK-OK-OK-FAIL)
	by vger.kernel.org with ESMTP id S1751498AbaIVD46 (ORCPT
	<rfc822;netdev@vger.kernel.org>); Sun, 21 Sep 2014 23:56:58 -0400
In-Reply-To: <1411259357.26859.89.camel@edumazet-glaptop2.roam.corp.google.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Sat, 2014-09-20 at 17:29 -0700, Eric Dumazet wrote:
> icsk_rto is a 32bit field, and icsk_backoff can reach 15 by default,
> or more if some sysctl (eg tcp_retries2) are changed.
> 
> Better use 64bit to perform icsk_rto << icsk_backoff operations

Thanks Eric.

> diff --git a/net/ipv4/tcp_input.c b/net/ipv4/tcp_input.c
[]
> @@ -3208,9 +3208,10 @@ static void tcp_ack_probe(struct sock *sk)
>  		 * This function is not for random using!
>  		 */
>  	} else {
> +		unsigned long when = inet_csk_rto_backoff(icsk, TCP_RTO_MAX);
> +
>  		inet_csk_reset_xmit_timer(sk, ICSK_TIME_PROBE0,
> -					  min(icsk->icsk_rto << icsk->icsk_backoff, TCP_RTO_MAX),
> -					  TCP_RTO_MAX);
> +					  when, TCP_RTO_MAX);

Pity about the possible extra compare to TCP_RTO_MAX here.
I hope gcc smart enough to optimize it away.
