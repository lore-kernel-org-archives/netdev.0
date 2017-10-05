From: Florian Westphal <fw@strlen.de>
Subject: Re: [PATCH net] netfilter: x_tables: avoid stack-out-of-bounds read
 in xt_copy_counters_from_user
Date: Thu, 5 Oct 2017 11:56:44 +0200
Message-ID: <20171005095644.GB27522@breakpoint.cc>
References: <1507197007.14419.15.camel@edumazet-glaptop3.roam.corp.google.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: Pablo Neira Ayuso <pablo@netfilter.org>,
        Jozsef Kadlecsik <kadlec@blackhole.kfki.hu>,
        Florian Westphal <fw@strlen.de>,
        netfilter-devel@vger.kernel.org, netdev <netdev@vger.kernel.org>,
        Willem de Bruijn <willemb@google.com>
To: Eric Dumazet <eric.dumazet@gmail.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from Chamillionaire.breakpoint.cc ([146.0.238.67]:58522 "EHLO
        Chamillionaire.breakpoint.cc" rhost-flags-OK-OK-OK-OK)
        by vger.kernel.org with ESMTP id S1751400AbdJEJ4y (ORCPT
        <rfc822;netdev@vger.kernel.org>); Thu, 5 Oct 2017 05:56:54 -0400
Content-Disposition: inline
In-Reply-To: <1507197007.14419.15.camel@edumazet-glaptop3.roam.corp.google.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Eric Dumazet <eric.dumazet@gmail.com> wrote:
> From: Eric Dumazet <edumazet@google.com>
> 
> syzkaller reports an out of bound read in strlcpy(), triggered
> by xt_copy_counters_from_user()
> 
> Fix this by using memcpy(), then forcing a zero byte at the last position
> of the destination, as Florian did for the non COMPAT code.
> 
> Fixes: d7591f0c41ce ("netfilter: x_tables: introduce and use xt_copy_counters_from_user")
> Signed-off-by: Eric Dumazet <edumazet@google.com>
> Cc: Willem de Bruijn <willemb@google.com>
> ---
>  net/netfilter/x_tables.c |    4 ++--
>  1 file changed, 2 insertions(+), 2 deletions(-)
> 
> diff --git a/net/netfilter/x_tables.c b/net/netfilter/x_tables.c
> index c83a3b5e1c6c2a91b713b6681a794bd79ab3fa08..d8571f4142080a3c121fc90f0b52d81ee9df6712 100644
> --- a/net/netfilter/x_tables.c
> +++ b/net/netfilter/x_tables.c
> @@ -892,7 +892,7 @@ void *xt_copy_counters_from_user(const void __user *user, unsigned int len,
>  		if (copy_from_user(&compat_tmp, user, sizeof(compat_tmp)) != 0)
>  			return ERR_PTR(-EFAULT);
>  
> -		strlcpy(info->name, compat_tmp.name, sizeof(info->name));
> +		memcpy(info->name, compat_tmp.name, sizeof(info->name) - 1);

Argh, right, compat_tmp.name might not be 0 terminated :-/

Acked-by: Florian Westphal <fw@strlen.de>
