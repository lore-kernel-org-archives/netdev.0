From: Ying Xue <ying.xue@windriver.com>
Subject: Re: netlink: Fix netlink_insert EADDRINUSE error
Date: Fri, 16 Jan 2015 14:30:33 +0800
Message-ID: <54B8B009.6020207@windriver.com>
References: <20150116062348.GA8588@gondor.apana.org.au>
Mime-Version: 1.0
Content-Type: text/plain; charset="windows-1252"
Content-Transfer-Encoding: 7bit
To: Herbert Xu <herbert@gondor.apana.org.au>, <netdev@vger.kernel.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail1.windriver.com ([147.11.146.13]:63924 "EHLO
	mail1.windriver.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751671AbbAPGcD (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 16 Jan 2015 01:32:03 -0500
In-Reply-To: <20150116062348.GA8588@gondor.apana.org.au>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On 01/16/2015 02:23 PM, Herbert Xu wrote:
> The patch c5adde9468b0714a051eac7f9666f23eb10b61f7 ("netlink:
> eliminate nl_sk_hash_lock") introduced a bug where the EADDRINUSE
> error has been replaced by ENOMEM.  This patch rectifies that
> problem.
>

Nice catch!

Acked-by: Ying Xue <ying.xue@windriver.com>

> Signed-off-by: Herbert Xu <herbert@gondor.apana.org.au>
> 
> diff --git a/net/netlink/af_netlink.c b/net/netlink/af_netlink.c
> index 01b702d..7a94185 100644
> --- a/net/netlink/af_netlink.c
> +++ b/net/netlink/af_netlink.c
> @@ -1050,7 +1050,7 @@ netlink_update_listeners(struct sock *sk)
>  static int netlink_insert(struct sock *sk, struct net *net, u32 portid)
>  {
>  	struct netlink_table *table = &nl_table[sk->sk_protocol];
> -	int err = -EADDRINUSE;
> +	int err;
>  
>  	lock_sock(sk);
>  
> @@ -1065,10 +1065,13 @@ static int netlink_insert(struct sock *sk, struct net *net, u32 portid)
>  
>  	nlk_sk(sk)->portid = portid;
>  	sock_hold(sk);
> -	if (__netlink_insert(table, sk, net))
> -		err = 0;
> -	else
> +
> +	err = 0;
> +	if (!__netlink_insert(table, sk, net)) {
> +		err = -EADDRINUSE;
>  		sock_put(sk);
> +	}
> +
>  err:
>  	release_sock(sk);
>  	return err;
> 
