From: Ben Hutchings <bhutchings@solarflare.com>
Subject: Re: [PATCH] net: force dst_default_metrics to const section
Date: Tue, 7 Aug 2012 21:15:27 +0100
Message-ID: <1344370527.2688.61.camel@bwh-desktop.uk.solarflarecom.com>
References: <1344355878.28967.113.camel@edumazet-glaptop>
Mime-Version: 1.0
Content-Type: text/plain; charset="UTF-8"
Content-Transfer-Encoding: 7bit
Cc: David Miller <davem@davemloft.net>, netdev <netdev@vger.kernel.org>
To: Eric Dumazet <eric.dumazet@gmail.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from webmail.solarflare.com ([12.187.104.25]:45532 "EHLO
	ocex02.SolarFlarecom.com" rhost-flags-OK-OK-OK-FAIL)
	by vger.kernel.org with ESMTP id S1755692Ab2HGUPb (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 7 Aug 2012 16:15:31 -0400
In-Reply-To: <1344355878.28967.113.camel@edumazet-glaptop>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Tue, 2012-08-07 at 18:11 +0200, Eric Dumazet wrote:
> From: Eric Dumazet <edumazet@google.com>
> 
> While investigating on network performance problems, I found this little
> gem :
> 
> $ nm -v vmlinux | grep -1 dst_default_metrics
> ffffffff82736540 b busy.46605 
> ffffffff82736560 B dst_default_metrics
> ffffffff82736598 b dst_busy_list
> 
> Apparently, declaring a const array without initializer put it in
> (writeable) bss section, in middle of possibly often dirtied cache
> lines.
> 
> Since we really want dst_default_metrics be const to avoid any possible
> false sharing and catch any buggy writes, I force a null initializer.
> 
> ffffffff818a4c20 R dst_default_metrics
>
> Signed-off-by: Eric Dumazet <edumazet@google.com>
> ---
> For reference, dst_default_metrics was added in 2.6.39
> 
>  net/core/dst.c |   10 +++++++++-
>  1 file changed, 9 insertions(+), 1 deletion(-)
> 
> diff --git a/net/core/dst.c b/net/core/dst.c
> index 069d51d..4c538be 100644
> --- a/net/core/dst.c
> +++ b/net/core/dst.c
> @@ -149,7 +149,15 @@ int dst_discard(struct sk_buff *skb)
>  }
>  EXPORT_SYMBOL(dst_discard);
>  
> -const u32 dst_default_metrics[RTAX_MAX];
> +const u32 dst_default_metrics[RTAX_MAX] = {
> +	/* This initializer is needed to force linker to place this variable
> +	 * into const section. Otherwise it might end into bss section.
> +	 * We really want to avoid false sharing on this variable, and catch
> +	 * any writes on it.
> +	 */
> +	0
> +};
> +

Some day the compiler may be smart enough to ignore the different
between explicit and implicit zero-initialisation, and put it back in
BSS.  Declaring this __cache_aligned_in_smp might be a better option.

Ben.
 
>  void *dst_alloc(struct dst_ops *ops, struct net_device *dev,
>  		int initial_ref, int initial_obsolete, unsigned short flags)


-- 
Ben Hutchings, Staff Engineer, Solarflare
Not speaking for my employer; that's the marketing department's job.
They asked us to note that Solarflare product names are trademarked.
