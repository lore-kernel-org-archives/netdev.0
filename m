From: Daniel Borkmann <dborkman@redhat.com>
Subject: Re: [PATCH net-next] tcp: Change return value of tcp_rcv_established()
Date: Sat, 31 Aug 2013 11:28:12 +0200
Message-ID: <5221B72C.5030106@redhat.com>
References: <1377842617-663-1-git-send-email-subramanian.vijay@gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1; format=flowed
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, davem@davemloft.net, eric.dumazet@gmail.com
To: Vijay Subramanian <subramanian.vijay@gmail.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mx1.redhat.com ([209.132.183.28]:52387 "EHLO mx1.redhat.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1752358Ab3HaJ2U (ORCPT <rfc822;netdev@vger.kernel.org>);
	Sat, 31 Aug 2013 05:28:20 -0400
In-Reply-To: <1377842617-663-1-git-send-email-subramanian.vijay@gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On 08/30/2013 08:03 AM, Vijay Subramanian wrote:
> tcp_rcv_established() returns only one value namely 0. We change the return
> value to void (as suggested by David Miller).
>
> After commit 0c24604b (tcp: implement RFC 5961 4.2), we no longer send RSTs in
> response to SYNs. We can remove the check and processing on the return value of
> tcp_rcv_established().
>
> We also fix jtcp_rcv_established() in tcp_probe.c to match that of
> tcp_rcv_established().
>
> Signed-off-by: Vijay Subramanian <subramanian.vijay@gmail.com>
> ---
> Changes: Earlier patch titled "tcp: Remove needless check of return value"
> fixed only the second issue above.
>
[...]
>
>   csum_error:
>   	TCP_INC_STATS_BH(sock_net(sk), TCP_MIB_CSUMERRORS);
> @@ -5260,7 +5260,7 @@ csum_error:
>
>   discard:
>   	__kfree_skb(skb);
> -	return 0;
> +	return;
>   }
>   EXPORT_SYMBOL(tcp_rcv_established);

You can remove this return here in discard case.

[...]
> diff --git a/net/ipv4/tcp_probe.c b/net/ipv4/tcp_probe.c
> index 622a437..8b10379 100644
> --- a/net/ipv4/tcp_probe.c
> +++ b/net/ipv4/tcp_probe.c
> @@ -122,7 +122,7 @@ static inline int tcp_probe_avail(void)
>    * Hook inserted to be called before each receive packet.
>    * Note: arguments must match tcp_rcv_established()!
>    */
> -static int jtcp_rcv_established(struct sock *sk, struct sk_buff *skb,
> +static void jtcp_rcv_established(struct sock *sk, struct sk_buff *skb,
>   				const struct tcphdr *th, unsigned int len)

Also, you should align the second line here to match opening '('.

>   {
>   	const struct tcp_sock *tp = tcp_sk(sk);
> @@ -172,7 +172,7 @@ static int jtcp_rcv_established(struct sock *sk, struct sk_buff *skb,
>   	}
>
>   	jprobe_return();
> -	return 0;
> +	return;

This return can then be removed if it's void anyway.

>   }
>
[...]
