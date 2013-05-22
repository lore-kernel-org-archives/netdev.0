From: Eric Dumazet <eric.dumazet@gmail.com>
Subject: Re: RFC limit sk_mem_quantum to 8192
Date: Tue, 21 May 2013 18:09:22 -0700
Message-ID: <1369184962.3301.264.camel@edumazet-glaptop>
References: <20130522004541.GA17240@obelix.rh>
Mime-Version: 1.0
Content-Type: text/plain; charset="UTF-8"
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, David Miller <davem@davemloft.net>
To: Flavio Leitner <fbl@redhat.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-pd0-f170.google.com ([209.85.192.170]:42989 "EHLO
	mail-pd0-f170.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1750850Ab3EVBJd (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 21 May 2013 21:09:33 -0400
Received: by mail-pd0-f170.google.com with SMTP id x10so1060786pdj.1
        for <netdev@vger.kernel.org>; Tue, 21 May 2013 18:09:33 -0700 (PDT)
In-Reply-To: <20130522004541.GA17240@obelix.rh>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Tue, 2013-05-21 at 21:45 -0300, Flavio Leitner wrote:
> Hi,
> 
> The page size can be 64k on ppc64, so SK_MEM_QUANTUM increases to
> that value as well.
> 
> net/ipv4/tcp.c:
> ...
>         sysctl_tcp_wmem[0] = SK_MEM_QUANTUM;
>         sysctl_tcp_wmem[1] = 16*1024;
>         sysctl_tcp_wmem[2] = max(64*1024, max_share);
> 
>         sysctl_tcp_rmem[0] = SK_MEM_QUANTUM;
>         sysctl_tcp_rmem[1] = 87380;
>         sysctl_tcp_rmem[2] = max(87380, max_share);
> 
> and:
> include/net/sock.h:
> #define SK_MEM_QUANTUM ((int)PAGE_SIZE)
> 
> ppc64 config:
> # CONFIG_PPC_4K_PAGES is not set
> # CONFIG_PPC_16K_PAGES is not set
> CONFIG_PPC_64K_PAGES=y
> # CONFIG_PPC_256K_PAGES is not set
> 
> It seems too much for a minimum reserved memory. Also, the
> other values are meaningless in this case because default
> is only 16k and the maximum is limited to 64k.
> 
> This will require a modification in the
> Documentation/networking/ip-sysctl.txt as well which states
> that default minimum is 1 page.
> 
> Also, sk_mem_schedule() and friends will have to consider
> that SK_MEM_QUANTUM might not be PAGE_SIZE anymore.
> 
> Well, the patch below illustrates what I am talking.
> thanks,
> fbl
> 
> diff --git a/include/net/sock.h b/include/net/sock.h
> index 5d84de4..d52fa2d 100644
> --- a/include/net/sock.h
> +++ b/include/net/sock.h
> @@ -954,7 +954,12 @@ static inline struct inode *SOCK_INODE(struct socket *socket)
>  extern int __sk_mem_schedule(struct sock *sk, int size, int kind);
>  extern void __sk_mem_reclaim(struct sock *sk);
>  
> +#if PAGE_SIZE < 8192
>  #define SK_MEM_QUANTUM ((int)PAGE_SIZE)
> +#else
> +#define SK_MEM_QUANTUM ((int)8192)
> +#endif
> +
>  #define SK_MEM_QUANTUM_SHIFT ilog2(SK_MEM_QUANTUM)
>  #define SK_MEM_SEND	0
>  #define SK_MEM_RECV	1
> 

What particular problem do you want to solve ?

Wouldn't be easier to chose 4096 on all arches ?

Are you sure a network driver doesn't provide skb using a full page ?
