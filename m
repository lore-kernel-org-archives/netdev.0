From: Joe Perches <joe@perches.com>
Subject: Re: [PATCH] ath9k:  Add wiphy name to log messages.
Date: Wed, 07 Mar 2012 16:54:59 -0800
Message-ID: <1331168099.20565.28.camel@joe2Laptop>
References: <1331165106-10359-1-git-send-email-greearb@candelatech.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="UTF-8"
Content-Transfer-Encoding: 7bit
Cc: ath9k-devel@venema.h4ckr.net, netdev@vger.kernel.org
To: greearb@candelatech.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from perches-mx.perches.com ([206.117.179.246]:58995 "EHLO
	labridge.com" rhost-flags-OK-OK-OK-FAIL) by vger.kernel.org with ESMTP
	id S1750973Ab2CHAzC (ORCPT <rfc822;netdev@vger.kernel.org>);
	Wed, 7 Mar 2012 19:55:02 -0500
In-Reply-To: <1331165106-10359-1-git-send-email-greearb@candelatech.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Wed, 2012-03-07 at 16:05 -0800, greearb@candelatech.com wrote:
> From: Ben Greear <greearb@candelatech.com>
> 
> On systems with multiple NICs, it's nice to know which
> one is producing warnings.  Here is an example of the
> new ouput:
> 
> ath: wiphy0: Failed to stop TX DMA, queues=0x005!

Makes some sense.

> diff --git a/drivers/net/wireless/ath/ath.h b/drivers/net/wireless/ath/ath.h
[]
> @@ -174,12 +174,13 @@ bool ath_hw_keyreset(struct ath_common *common, u16 entry);
>  void ath_hw_cycle_counters_update(struct ath_common *common);
>  int32_t ath_hw_get_listen_time(struct ath_common *common);
>  
> -extern __printf(2, 3) void ath_printk(const char *level, const char *fmt, ...);
> +extern __printf(3, 4) void ath_printk(const char *level,
> +				      const struct ath_common *common,
> +				      const char *fmt, ...);

Maybe

__printf(3, 4)
void ath_printk(etc...

>  
>  #define _ath_printk(level, common, fmt, ...)			\
>  do {								\
> -	__always_unused struct ath_common *unused = common;	\
> -	ath_printk(level, fmt, ##__VA_ARGS__);			\
> +	ath_printk(level, common, fmt, ##__VA_ARGS__);		\
>  } while (0)
>  
>  #define ath_emerg(common, fmt, ...)				\

It's probably better to remove the _ath_printk
indirection altogether and just use ath_printk
directly in the ath_<level> macros.

> diff --git a/drivers/net/wireless/ath/main.c b/drivers/net/wireless/ath/main.c
[]
> @@ -57,7 +57,8 @@ struct sk_buff *ath_rxbuf_alloc(struct ath_common *common,
>  }
>  EXPORT_SYMBOL(ath_rxbuf_alloc);
>  
> -void ath_printk(const char *level, const char *fmt, ...)
> +void ath_printk(const char *level, const struct ath_common* common,
> +		const char *fmt, ...)
>  {
>  	struct va_format vaf;
>  	va_list args;
> @@ -67,7 +68,11 @@ void ath_printk(const char *level, const char *fmt, ...)
>  	vaf.fmt = fmt;
>  	vaf.va = &args;
>  
> -	printk("%sath: %pV", level, &vaf);
> +	if (common && common->hw && common->hw->wiphy)
> +		printk("%sath: %s: %pV",
> +		       level, wiphy_name(common->hw->wiphy), &vaf);
> +	else
> +		printk("%sath: %pV", level, &vaf);
>  
>  	va_end(args);

Maybe it's better to print wiphyX: only when
multiple ath nics exist?
