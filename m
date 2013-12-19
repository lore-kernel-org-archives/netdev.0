From: Daniel Borkmann <dborkman@redhat.com>
Subject: Re: [PATCH net-next] ipv6: move ip6_sk_accept_pmtu from generic pmtu
 update path to ipv6 one
Date: Thu, 19 Dec 2013 13:57:54 +0100
Message-ID: <52B2ED52.90604@redhat.com>
References: <20131219115458.GC14429@order.stressinduktion.org>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8; format=flowed
Content-Transfer-Encoding: 7bit
Cc: "linux-sctp@vger.kernel.org" <linux-sctp@vger.kernel.org>,
	Hannes Frederic Sowa <hannes@stressinduktion.org>
To: netdev@vger.kernel.org, fengguang.wu@intel.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from mx1.redhat.com ([209.132.183.28]:60691 "EHLO mx1.redhat.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1755729Ab3LSM6A (ORCPT <rfc822;netdev@vger.kernel.org>);
	Thu, 19 Dec 2013 07:58:00 -0500
In-Reply-To: <20131219115458.GC14429@order.stressinduktion.org>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On 12/19/2013 12:54 PM, Hannes Frederic Sowa wrote:
> In commit 93b36cf3425b9b ("ipv6: support IPV6_PMTU_INTERFACE on sockets")
> I made a horrible mistake to add ip6_sk_accept_pmtu to the generic
> sctp_icmp_frag_needed path. This results in build warnings if IPv6 is
> disabled which were luckily caught by Fengguang's kbuild bot. But it
> also leads to a kernel panic IPv4 frag-needed packet is received.
>
> Reported-by: kbuild test robot <fengguang.wu@intel.com>
> Signed-off-by: Hannes Frederic Sowa <hannes@stressinduktion.org>

Thanks, also cc'ing linux-sctp.

Fixes: 93b36cf3425b ("ipv6: support IPV6_PMTU_INTERFACE on sockets")
Acked-by: Daniel Borkmann <dborkman@redhat.com>

> ---
>   net/sctp/input.c | 3 ---
>   net/sctp/ipv6.c  | 3 ++-
>   2 files changed, 2 insertions(+), 4 deletions(-)
>
> diff --git a/net/sctp/input.c b/net/sctp/input.c
> index 042ec6c..2a192a7 100644
> --- a/net/sctp/input.c
> +++ b/net/sctp/input.c
> @@ -389,9 +389,6 @@ void sctp_icmp_frag_needed(struct sock *sk, struct sctp_association *asoc,
>   	if (!t || (t->pathmtu <= pmtu))
>   		return;
>
> -	if (!ip6_sk_accept_pmtu(sk))
> -		return;
> -
>   	if (sock_owned_by_user(sk)) {
>   		asoc->pmtu_pending = 1;
>   		t->pmtu_pending = 1;
> diff --git a/net/sctp/ipv6.c b/net/sctp/ipv6.c
> index 32db816..00bea3f 100644
> --- a/net/sctp/ipv6.c
> +++ b/net/sctp/ipv6.c
> @@ -172,7 +172,8 @@ static void sctp_v6_err(struct sk_buff *skb, struct inet6_skb_parm *opt,
>
>   	switch (type) {
>   	case ICMPV6_PKT_TOOBIG:
> -		sctp_icmp_frag_needed(sk, asoc, transport, ntohl(info));
> +		if (ip6_sk_accept_pmtu(sk))
> +			sctp_icmp_frag_needed(sk, asoc, transport, ntohl(info));
>   		goto out_unlock;
>   	case ICMPV6_PARAMPROB:
>   		if (ICMPV6_UNK_NEXTHDR == code) {
>
