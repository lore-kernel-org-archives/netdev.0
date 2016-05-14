From: Eric Dumazet <eric.dumazet@gmail.com>
Subject: Re: [PATCH] nf_conntrack: avoid kernel pointer value leak in slab
 name
Date: Sat, 14 May 2016 11:46:06 -0700
Message-ID: <1463251566.18194.31.camel@edumazet-glaptop3.roam.corp.google.com>
References: <alpine.LFD.2.20.1605141116100.24646@i7>
Mime-Version: 1.0
Content-Type: text/plain; charset="UTF-8"
Content-Transfer-Encoding: 7bit
Cc: David Miller <davem@davemloft.net>, Willy Tarreau <w@1wt.eu>,
	Network Development List <netdev@vger.kernel.org>
To: Linus Torvalds <torvalds@linux-foundation.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-pa0-f66.google.com ([209.85.220.66]:35743 "EHLO
	mail-pa0-f66.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752370AbcENSqK (ORCPT
	<rfc822;netdev@vger.kernel.org>); Sat, 14 May 2016 14:46:10 -0400
Received: by mail-pa0-f66.google.com with SMTP id zy2so12957693pac.2
        for <netdev@vger.kernel.org>; Sat, 14 May 2016 11:46:09 -0700 (PDT)
In-Reply-To: <alpine.LFD.2.20.1605141116100.24646@i7>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Sat, 2016-05-14 at 11:24 -0700, Linus Torvalds wrote:
> From: Linus Torvalds <torvalds@linux-foundation.org>
> Date: Sat, 14 May 2016 11:11:44 -0700
> Subject: [PATCH] nf_conntrack: avoid kernel pointer value leak in slab name
> 
> The slab name ends up being visible in the directory structure under
> /sys, and even if you don't have access rights to the file you can see
> the filenames.
> 
> Just use a 64-bit counter instead of the pointer to the 'net' structure
> to generate a unique name.
> 
> This code will go away in 4.7 when the conntrack code moves to a single
> kmemcache, but this is the backportable simple solution to avoiding
> leaking kernel pointers to user space.
> 
> Signed-off-by: Linus Torvalds <torvalds@linux-foundation.org>
> Acked-by: Eric Dumazet <eric.dumazet@gmail.com>
> Cc: stable@vger.kernel.org
> ---
> 
> This would seem to be the minimal patch.
> 
> Eric - I marked you as "acking" this patch from the discussion. It's not 
> actually any of the exact patches that were flying around, but close 
> enough..
> 
> It's been "tested" by booting and looking at the end result. Seems to 
> work, and it's not exactly complicated.
> 
> diff --git a/net/netfilter/nf_conntrack_core.c b/net/netfilter/nf_conntrack_core.c
> index 895d11dced3c..e27fd17c6743 100644
> --- a/net/netfilter/nf_conntrack_core.c
> +++ b/net/netfilter/nf_conntrack_core.c
> @@ -1778,6 +1778,7 @@ void nf_conntrack_init_end(void)
>  
>  int nf_conntrack_init_net(struct net *net)
>  {
> +	static atomic64_t unique_id;
>  	int ret = -ENOMEM;
>  	int cpu;
>  
> @@ -1800,7 +1801,8 @@ int nf_conntrack_init_net(struct net *net)
>  	if (!net->ct.stat)
>  		goto err_pcpu_lists;
>  
> -	net->ct.slabname = kasprintf(GFP_KERNEL, "nf_conntrack_%p", net);
> +	net->ct.slabname = kasprintf(GFP_KERNEL, "nf_conntrack_%llu",
> +				(u64)atomic64_inc_return(&unique_id));
>  	if (!net->ct.slabname)
>  		goto err_slabname;
>  

SGTM, thanks Linus.

Fixes: 5b3501faa874 ("netfilter: nf_conntrack: per netns nf_conntrack_cachep")
