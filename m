From: Eric Dumazet <eric.dumazet@gmail.com>
Subject: Re: [PATCH v2 1/2] tcp: setup timestamp offset when write_seq
 already set
Date: Wed, 22 Feb 2017 05:17:54 -0800
Message-ID: <1487769474.9415.44.camel@edumazet-glaptop3.roam.corp.google.com>
References: <1487759036-2800-1-git-send-email-alexey.kodanev@oracle.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="UTF-8"
Content-Transfer-Encoding: 7bit
Cc: David Miller <davem@davemloft.net>,
        netdev <netdev@vger.kernel.org>, Florian Westphal <fw@strlen.de>,
        Eric Dumazet <edumazet@google.com>
To: Alexey Kodanev <alexey.kodanev@oracle.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-pg0-f65.google.com ([74.125.83.65]:36838 "EHLO
        mail-pg0-f65.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S932415AbdBVNR5 (ORCPT
        <rfc822;netdev@vger.kernel.org>); Wed, 22 Feb 2017 08:17:57 -0500
Received: by mail-pg0-f65.google.com with SMTP id z128so354962pgb.3
        for <netdev@vger.kernel.org>; Wed, 22 Feb 2017 05:17:56 -0800 (PST)
In-Reply-To: <1487759036-2800-1-git-send-email-alexey.kodanev@oracle.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Wed, 2017-02-22 at 13:23 +0300, Alexey Kodanev wrote:
> Found that when randomized tcp offsets are enabled (by default)
> TCP client can still start new connections without them. Later,
> if server does active close and re-uses sockets in TIME-WAIT
> state, new SYN from client can be rejected on PAWS check inside
> tcp_timewait_state_process(), because either tw_ts_recent or
> rcv_tsval doesn't really have an offset set.
> 
> Here is how to reproduce it with LTP netstress tool:
>     netstress -R 1 &
>     netstress -H 127.0.0.1 -lr 1000000 -a1
> 
>     [...]
>     < S  seq 1956977072 win 43690 TS val 295618 ecr 459956970
>     > .  ack 1956911535 win 342 TS val 459967184 ecr 1547117608
>     < R  seq 1956911535 win 0 length 0
> +1. < S  seq 1956977072 win 43690 TS val 296640 ecr 459956970
>     > S. seq 657450664 ack 1956977073 win 43690 TS val 459968205 ecr 296640
> 
> Fixes: 95a22caee396 ("tcp: randomize tcp timestamp offsets for each connection")
> Signed-off-by: Alexey Kodanev <alexey.kodanev@oracle.com>
> ---
> v2: * remove 'else if' clause and add new variable 'seq' to store tmp result,
>     * change slightly the subject and commit message.
> 
>  net/ipv4/tcp_ipv4.c |   16 ++++++++++------
>  net/ipv6/tcp_ipv6.c |   16 ++++++++++------
>  2 files changed, 20 insertions(+), 12 deletions(-)
> 
> diff --git a/net/ipv4/tcp_ipv4.c b/net/ipv4/tcp_ipv4.c
> index fe9da4f..c5169b8 100644
> --- a/net/ipv4/tcp_ipv4.c
> +++ b/net/ipv4/tcp_ipv4.c
> @@ -145,6 +145,7 @@ int tcp_v4_connect(struct sock *sk, struct sockaddr *uaddr, int addr_len)
>  	struct flowi4 *fl4;
>  	struct rtable *rt;
>  	int err;
> +	u32 seq;
>  	struct ip_options_rcu *inet_opt;
>  
>  	if (addr_len < sizeof(struct sockaddr_in))
> @@ -232,12 +233,15 @@ int tcp_v4_connect(struct sock *sk, struct sockaddr *uaddr, int addr_len)
>  	sk->sk_gso_type = SKB_GSO_TCPV4;
>  	sk_setup_caps(sk, &rt->dst);
>  
> -	if (!tp->write_seq && likely(!tp->repair))
> -		tp->write_seq = secure_tcp_sequence_number(inet->inet_saddr,
> -							   inet->inet_daddr,
> -							   inet->inet_sport,
> -							   usin->sin_port,
> -							   &tp->tsoffset);
> +	if (likely(!tp->repair)) {
> +		seq = secure_tcp_sequence_number(inet->inet_saddr,
> +						 inet->inet_daddr,
> +						 inet->inet_sport,
> +						 usin->sin_port,
> +						 &tp->tsoffset);
> +		if (!tp->write_seq)
> +			tp->write_seq = seq;
> +	}
>  

Nice catch !

secure_tcp_sequence_number() could be renamed, because it has two
purposes really.

Acked-by: Eric Dumazet <edumazet@google.com>
