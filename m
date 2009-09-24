From: Jarek Poplawski <jarkao2@gmail.com>
Subject: Re: [PATCH] net: Fix sock_wfree() race
Date: Thu, 24 Sep 2009 22:07:38 +0200
Message-ID: <4ABBD18A.70208@gmail.com>
References: <4AA64A11.7090804@gmail.com>	<4AA6DF7B.7060105@gmail.com>	<20090911.114337.150207703.davem@davemloft.net> <20090911.125242.244008840.davem@davemloft.net> <4ABA262F.9040407@gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1
Content-Transfer-Encoding: 7bit
Cc: David Miller <davem@davemloft.net>, albcamus@gmail.com,
	parag.lkml@gmail.com, linux-kernel@vger.kernel.org,
	netdev@vger.kernel.org
To: Eric Dumazet <eric.dumazet@gmail.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-bw0-f210.google.com ([209.85.218.210]:43935 "EHLO
	mail-bw0-f210.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751467AbZIXUIf (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 24 Sep 2009 16:08:35 -0400
In-Reply-To: <4ABA262F.9040407@gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Eric Dumazet wrote, On 09/23/2009 03:44 PM:

...
> Here is the patch for reference :
> 
> [PATCH] net: Fix sock_wfree() race
> 
> Commit 2b85a34e911bf483c27cfdd124aeb1605145dc80
> (net: No more expensive sock_hold()/sock_put() on each tx)
> opens a window in sock_wfree() where another cpu
> might free the socket we are working on.
> 
> A fix is to call sk->sk_write_space(sk) while still
> holding a reference on sk.
> 
> 
> Reported-by: Jike Song <albcamus@gmail.com>
> Signed-off-by: Eric Dumazet <eric.dumazet@gmail.com>
> ---
>  net/core/sock.c |   19 ++++++++++++-------
>  1 files changed, 12 insertions(+), 7 deletions(-)
> 
> diff --git a/net/core/sock.c b/net/core/sock.c
> index 30d5446..e1f034e 100644
> --- a/net/core/sock.c
> +++ b/net/core/sock.c
> @@ -1228,17 +1228,22 @@ void __init sk_init(void)
>  void sock_wfree(struct sk_buff *skb)
>  {
>  	struct sock *sk = skb->sk;
> -	int res;
> +	unsigned int len = skb->truesize;
>  
> -	/* In case it might be waiting for more memory. */
> -	res = atomic_sub_return(skb->truesize, &sk->sk_wmem_alloc);
> -	if (!sock_flag(sk, SOCK_USE_WRITE_QUEUE))
> +	if (!sock_flag(sk, SOCK_USE_WRITE_QUEUE)) {
> +		/*
> +		 * Keep a reference on sk_wmem_alloc, this will be released
> +		 * after sk_write_space() call
> +		 */
> +		atomic_sub(len - 1, &sk->sk_wmem_alloc);
>  		sk->sk_write_space(sk);
> +		len = 1;
> +	}
>  	/*
> -	 * if sk_wmem_alloc reached 0, we are last user and should
> -	 * free this sock, as sk_free() call could not do it.
> +	 * if sk_wmem_alloc reaches 0, we must finish what sk_free()
> +	 * could not do because of in-flight packets
>  	 */
> -	if (res == 0)
> +	if (atomic_sub_return(len, &sk->sk_wmem_alloc) == 0)
>  		__sk_free(sk);


Probably atomic_sub_and_test() is more popular for this.

Jarek P.

>  }
>  EXPORT_SYMBOL(sock_wfree);
> 
> --
> To unsubscribe from this list: send the line "unsubscribe netdev" in
> the body of a message to majordomo@vger.kernel.org
> More majordomo info at  http://vger.kernel.org/majordomo-info.html
> 


