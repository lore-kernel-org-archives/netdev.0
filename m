From: Joe Perches <joe@perches.com>
Subject: Re: [PATCH net-next] tcp: avoid possible arithmetic overflows
Date: Sat, 20 Sep 2014 11:01:11 -0700
Message-ID: <1411236071.8612.6.camel@joe-AO725>
References: <1411233550.26859.76.camel@edumazet-glaptop2.roam.corp.google.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="ISO-8859-1"
Content-Transfer-Encoding: 7bit
Cc: David Miller <davem@davemloft.net>,
	netdev <netdev@vger.kernel.org>,
	Neal Cardwell <ncardwell@google.com>,
	Yuchung Cheng <ycheng@google.com>
To: Eric Dumazet <eric.dumazet@gmail.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from smtprelay0110.hostedemail.com ([216.40.44.110]:48284 "EHLO
	smtprelay.hostedemail.com" rhost-flags-OK-OK-OK-FAIL)
	by vger.kernel.org with ESMTP id S1756052AbaITSBO (ORCPT
	<rfc822;netdev@vger.kernel.org>); Sat, 20 Sep 2014 14:01:14 -0400
In-Reply-To: <1411233550.26859.76.camel@edumazet-glaptop2.roam.corp.google.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Sat, 2014-09-20 at 10:19 -0700, Eric Dumazet wrote:
> From: Eric Dumazet <edumazet@google.com>
> 
> icsk_rto is an 32bit field, and icsk_backoff can reach 15 by default,
> or more if some sysctl (eg tcp_retries2) are changed.
> 
> Better use 64bit to perform icsk_rto << icsk_backoff operations

Maybe better to use a helper function for this?

something like:

static inline u64 icsk_rto_backoff(const struct inet_connection_sock *icsk)
{
	u64 when = (u64)icsk->icsk_rto;

	return when << icsk->icsk_backoff;
}

> diff --git a/net/ipv4/tcp_input.c b/net/ipv4/tcp_input.c
[]
> @@ -3208,9 +3208,12 @@ static void tcp_ack_probe(struct sock *sk)
>  		 * This function is not for random using!
>  		 */
>  	} else {
> +		unsigned long when;
> +
> +		when = min((u64)icsk->icsk_rto << icsk->icsk_backoff,
> +			   (u64)TCP_RTO_MAX);

Maybe:
	u32 when = (u32)min_t(u64, icsk_rto_backoff(icsk), TCP_RTO_MAX);
