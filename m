From: Jarek Poplawski <jarkao2@gmail.com>
Subject: Re: [PATCH] net: sk_free() should be allowed right after sk_alloc()
Date: Mon, 31 Aug 2009 09:30:19 +0000
Message-ID: <20090831093019.GI5005@ff.dom.local>
References: <20090830222340.GA17454@ami.dom.local> <4A9B6D23.9090505@gmail.com> <20090831063648.GB5005@ff.dom.local> <4A9B72B1.2040908@gmail.com> <20090831070733.GC5005@ff.dom.local> <4A9B7956.40507@gmail.com> <4A9B94B8.4050808@gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: David Miller <davem@davemloft.net>, netdev@vger.kernel.org
To: Eric Dumazet <eric.dumazet@gmail.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-bw0-f219.google.com ([209.85.218.219]:50837 "EHLO
	mail-bw0-f219.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1753676AbZHaJaX (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 31 Aug 2009 05:30:23 -0400
Received: by bwz19 with SMTP id 19so2655301bwz.37
        for <netdev@vger.kernel.org>; Mon, 31 Aug 2009 02:30:24 -0700 (PDT)
Content-Disposition: inline
In-Reply-To: <4A9B94B8.4050808@gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Mon, Aug 31, 2009 at 11:15:36AM +0200, Eric Dumazet wrote:
> From: Jarek Poplawski <jarkao2@gmail.com>
> 
> After commit 2b85a34e911bf483c27cfdd124aeb1605145dc80
> (net: No more expensive sock_hold()/sock_put() on each tx)
> sk_free() frees socks conditionally and depends
> on sk_wmem_alloc beeing set e.g. in sock_init_data(). But in some

Very nice, but I hope David could fix btw. my "beeing" misspelling.

Thanks everyone,
Jarek P.

> cases sk_free() is called earlier, usually after other alloc errors.
> 
> Fix is to move sk_wmem_alloc initialization from sock_init_data()
> to sk_alloc() itself.
> 
> Signed-off-by: Jarek Poplawski <jarkao2@gmail.com>
> Signed-off-by: Eric Dumazet <eric.dumazet@gmail.com>
> ---
> diff --git a/net/core/sock.c b/net/core/sock.c
> index bbb25be..7633422 100644
> --- a/net/core/sock.c
> +++ b/net/core/sock.c
> @@ -1025,6 +1025,7 @@ struct sock *sk_alloc(struct net *net, int family, gfp_t priority,
>  		sk->sk_prot = sk->sk_prot_creator = prot;
>  		sock_lock_init(sk);
>  		sock_net_set(sk, get_net(net));
> +		atomic_set(&sk->sk_wmem_alloc, 1);
>  	}
>  
>  	return sk;
> @@ -1872,7 +1873,6 @@ void sock_init_data(struct socket *sock, struct sock *sk)
>  	 */
>  	smp_wmb();
>  	atomic_set(&sk->sk_refcnt, 1);
> -	atomic_set(&sk->sk_wmem_alloc, 1);
>  	atomic_set(&sk->sk_drops, 0);
>  }
>  EXPORT_SYMBOL(sock_init_data);
> 
