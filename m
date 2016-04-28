From: Eric Dumazet <eric.dumazet@gmail.com>
Subject: Re: [PATCH net] soreuseport: Fix TCP listener hash collision
Date: Thu, 28 Apr 2016 13:50:11 -0700
Message-ID: <1461876611.5535.117.camel@edumazet-glaptop3.roam.corp.google.com>
References: <1461874302-18258-1-git-send-email-kraigatgoog@gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="UTF-8"
Content-Transfer-Encoding: 7bit
Cc: davem@davemloft.net, netdev@vger.kernel.org
To: Craig Gallek <kraigatgoog@gmail.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-pf0-f181.google.com ([209.85.192.181]:34041 "EHLO
	mail-pf0-f181.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752414AbcD1UuO (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 28 Apr 2016 16:50:14 -0400
Received: by mail-pf0-f181.google.com with SMTP id y69so38496344pfb.1
        for <netdev@vger.kernel.org>; Thu, 28 Apr 2016 13:50:13 -0700 (PDT)
In-Reply-To: <1461874302-18258-1-git-send-email-kraigatgoog@gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Thu, 2016-04-28 at 16:11 -0400, Craig Gallek wrote:
> From: Craig Gallek <kraig@google.com>
> 
> I forgot to include a check for listener port equality when deciding
> if two sockets should belong to the same reuseport group.  This was
> not caught previously because it's only necessary when two listening
> sockets for the same user happen to hash to the same listener bucket.
> The same error does not exist in the UDP path.
> 
> Fixes: c125e80b8868("soreuseport: fast reuseport TCP socket selection")
> Signed-off-by: Craig Gallek <kraig@google.com>
> ---
>  net/ipv4/inet_hashtables.c | 2 ++
>  1 file changed, 2 insertions(+)
> 
> diff --git a/net/ipv4/inet_hashtables.c b/net/ipv4/inet_hashtables.c
> index bc68eced0105..326d26c7a9e6 100644
> --- a/net/ipv4/inet_hashtables.c
> +++ b/net/ipv4/inet_hashtables.c
> @@ -470,6 +470,7 @@ static int inet_reuseport_add_sock(struct sock *sk,
>  						     const struct sock *sk2,
>  						     bool match_wildcard))
>  {
> +	struct inet_bind_bucket *tb = inet_csk(sk)->icsk_bind_hash;
>  	struct sock *sk2;
>  	struct hlist_nulls_node *node;
>  	kuid_t uid = sock_i_uid(sk);
> @@ -479,6 +480,7 @@ static int inet_reuseport_add_sock(struct sock *sk,
>  		    sk2->sk_family == sk->sk_family &&
>  		    ipv6_only_sock(sk2) == ipv6_only_sock(sk) &&
>  		    sk2->sk_bound_dev_if == sk->sk_bound_dev_if &&
> +		    inet_csk(sk2)->icsk_bind_hash->port == tb->port &&
>  		    sk2->sk_reuseport && uid_eq(uid, sock_i_uid(sk2)) &&
>  		    saddr_same(sk, sk2, false))
>  			return reuseport_add_sock(sk, sk2);


Not sure it is network namespace ready ?

I would simply compare the tb pointer itself, and not deref it to get
the port.
      ...  inet_csk(sk2)->icsk_bind_hash == tb 
