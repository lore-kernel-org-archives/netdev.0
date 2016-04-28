From: Eric Dumazet <eric.dumazet@gmail.com>
Subject: Re: [PATCH v2 net] soreuseport: Fix TCP listener hash collision
Date: Thu, 28 Apr 2016 14:59:33 -0700
Message-ID: <1461880773.5535.121.camel@edumazet-glaptop3.roam.corp.google.com>
References: <1461877661-21282-1-git-send-email-kraigatgoog@gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="UTF-8"
Content-Transfer-Encoding: 7bit
Cc: davem@davemloft.net, netdev@vger.kernel.org
To: Craig Gallek <kraigatgoog@gmail.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-pa0-f41.google.com ([209.85.220.41]:34091 "EHLO
	mail-pa0-f41.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751534AbcD1V7g (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 28 Apr 2016 17:59:36 -0400
Received: by mail-pa0-f41.google.com with SMTP id r5so37745277pag.1
        for <netdev@vger.kernel.org>; Thu, 28 Apr 2016 14:59:36 -0700 (PDT)
In-Reply-To: <1461877661-21282-1-git-send-email-kraigatgoog@gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Thu, 2016-04-28 at 17:07 -0400, Craig Gallek wrote:
> From: Craig Gallek <kraig@google.com>
> 
> I forgot to include a check for listener port equality when deciding
> if two sockets should belong to the same reuseport group.  This was
> not caught previously because it's only necessary when two listening
> sockets for the same user happen to hash to the same listener bucket.
> This change also includes a check for network namespace equality.
> The same error does not exist in the UDP path.
> 
> Fixes: c125e80b8868("soreuseport: fast reuseport TCP socket selection")
> Signed-off-by: Craig Gallek <kraig@google.com>
> ---
> v2 Changes
>   - Suggestions from Eric Dumazet to include network namespace equality
>     check and to avoid a dreference by simply checking inet_bind_bucket
>     pointer equality.
> ---
>  net/ipv4/inet_hashtables.c | 6 +++++-
>  1 file changed, 5 insertions(+), 1 deletion(-)
> 
> diff --git a/net/ipv4/inet_hashtables.c b/net/ipv4/inet_hashtables.c
> index bc68eced0105..5c5658268d5e 100644
> --- a/net/ipv4/inet_hashtables.c
> +++ b/net/ipv4/inet_hashtables.c
> @@ -470,15 +470,19 @@ static int inet_reuseport_add_sock(struct sock *sk,
>  						     const struct sock *sk2,
>  						     bool match_wildcard))
>  {
> +	struct inet_bind_bucket *tb = inet_csk(sk)->icsk_bind_hash;
> +	struct net *net = sock_net(sk);
>  	struct sock *sk2;
>  	struct hlist_nulls_node *node;
>  	kuid_t uid = sock_i_uid(sk);
>  
>  	sk_nulls_for_each_rcu(sk2, node, &ilb->head) {
> -		if (sk2 != sk &&
> +		if (net_eq(sock_net(sk2), net) &&
> +		    sk2 != sk &&
>  		    sk2->sk_family == sk->sk_family &&
>  		    ipv6_only_sock(sk2) == ipv6_only_sock(sk) &&
>  		    sk2->sk_bound_dev_if == sk->sk_bound_dev_if &&
> +		    inet_csk(sk2)->icsk_bind_hash == tb &&
>  		    sk2->sk_reuseport && uid_eq(uid, sock_i_uid(sk2)) &&
>  		    saddr_same(sk, sk2, false))
>  			return reuseport_add_sock(sk, sk2);

Note that I suggested to only use "inet_csk(sk2)->icsk_bind_hash == tb"

If test is true, it means that sockets share same name space and same
port ;)

Therefore the added net_eq(sock_net(sk2), net) test is redundant.

No strong opinion, as this patch works, and this is not fast path
anyway.

Acked-by: Eric Dumazet <edumazet@google.com>
