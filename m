From: Luciano Coelho <coelho@ti.com>
Subject: Re: [PATCH wireless-next 18/20] ti: Use pr_<level>
Date: Fri, 15 Jun 2012 11:36:14 +0300
Message-ID: <1339749374.4502.80.camel@cumari.coelho.fi>
References: <cover.1339739415.git.joe@perches.com>
	 <a4533db379be3689e3b29ed9b0d170263d875f7d.1339739416.git.joe@perches.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="UTF-8"
Content-Transfer-Encoding: 7bit
Cc: linux-kernel@vger.kernel.org,
	"John W. Linville" <linville@tuxdriver.com>,
	linux-wireless@vger.kernel.org, netdev@vger.kernel.org
To: Joe Perches <joe@perches.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from na3sys009aog138.obsmtp.com ([74.125.149.19]:34979 "EHLO
	na3sys009aog138.obsmtp.com" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with ESMTP id S1751342Ab2FOIgT (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 15 Jun 2012 04:36:19 -0400
Received: by laap9 with SMTP id p9so1952112laa.36
        for <netdev@vger.kernel.org>; Fri, 15 Jun 2012 01:36:16 -0700 (PDT)
In-Reply-To: <a4533db379be3689e3b29ed9b0d170263d875f7d.1339739416.git.joe@perches.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Hi Joe,

On Thu, 2012-06-14 at 22:53 -0700, Joe Perches wrote:
> Use a more current logging style.
> 
> Convert printks to pr_<level>.
> Coalesce formats, align arguments.
> 
> Add newlines to calls, remove from macros.
> Remove unnecessary duplicate newlines from calls.
> Remove spaces before newlines.
> 
> Signed-off-by: Joe Perches <joe@perches.com>
> ---

As Johannes already mentioned, I have to also ask why do you need to do
this? I see the point, slightly, with the wl1251 code, because it is
still using printks, but with wlcore and friends, there's no functional
change.

[...]

> diff --git a/drivers/net/wireless/ti/wl1251/wl1251.h b/drivers/net/wireless/ti/wl1251/wl1251.h
> index 9d8f581..e4d0063 100644
> --- a/drivers/net/wireless/ti/wl1251/wl1251.h
> +++ b/drivers/net/wireless/ti/wl1251/wl1251.h
> @@ -54,22 +54,22 @@ enum {
>  
>  #define DEBUG_DUMP_LIMIT 1024
>  
> -#define wl1251_error(fmt, arg...) \
> -	printk(KERN_ERR DRIVER_PREFIX "ERROR " fmt "\n", ##arg)
> +#define wl1251_err(fmt, arg...)				\
> +	pr_err(DRIVER_PREFIX "ERROR " fmt, ##arg)
>  
> -#define wl1251_warning(fmt, arg...) \
> -	printk(KERN_WARNING DRIVER_PREFIX "WARNING " fmt "\n", ##arg)
> +#define wl1251_warn(fmt, arg...)				\
> +	pr_warn(DRIVER_PREFIX "WARNING " fmt, ##arg)
>  
> -#define wl1251_notice(fmt, arg...) \
> -	printk(KERN_INFO DRIVER_PREFIX fmt "\n", ##arg)
> +#define wl1251_notice(fmt, arg...)		\
> +	pr_info(DRIVER_PREFIX fmt, ##arg)
>  
> -#define wl1251_info(fmt, arg...) \
> -	printk(KERN_DEBUG DRIVER_PREFIX fmt "\n", ##arg)
> +#define wl1251_info(fmt, arg...)				\
> +	printk(KERN_DEBUG DRIVER_PREFIX fmt, ##arg)
>  
>  #define wl1251_debug(level, fmt, arg...) \
> -	do { \
> +	do {				 \
>  		if (level & DEBUG_LEVEL) \
> -			printk(KERN_DEBUG DRIVER_PREFIX fmt "\n", ##arg); \
> +			printk(KERN_DEBUG DRIVER_PREFIX fmt, ##arg); \
>  	} while (0)

As mentioned above, this change here is acceptable, but removing the \n
from the macro and adding it at the end of each and every call is
useless and will just skew git-blame and make it harder to do rebase or
apply patches because of conflicts.

[...]

> diff --git a/drivers/net/wireless/ti/wlcore/debug.h b/drivers/net/wireless/ti/wlcore/debug.h
> index 6b800b3..83b72c2 100644
> --- a/drivers/net/wireless/ti/wlcore/debug.h
> +++ b/drivers/net/wireless/ti/wlcore/debug.h
> @@ -61,22 +61,22 @@ extern u32 wl12xx_debug_level;
>  
>  #define DEBUG_DUMP_LIMIT 1024
>  
> -#define wl1271_error(fmt, arg...) \
> -	pr_err(DRIVER_PREFIX "ERROR " fmt "\n", ##arg)
> +#define wl1271_err(fmt, arg...)				\
> +	pr_err(DRIVER_PREFIX "ERROR " fmt, ##arg)
>  
> -#define wl1271_warning(fmt, arg...) \
> -	pr_warning(DRIVER_PREFIX "WARNING " fmt "\n", ##arg)
> +#define wl1271_warn(fmt, arg...)				\
> +	pr_warn(DRIVER_PREFIX "WARNING " fmt, ##arg)

Using pr_warn instead of pr_warning is pointless.  pr_warning is the
main definition, actually, and pr_warn is just a "mirror".


> -#define wl1271_notice(fmt, arg...) \
> -	pr_info(DRIVER_PREFIX fmt "\n", ##arg)
> +#define wl1271_notice(fmt, arg...)		\
> +	pr_info(DRIVER_PREFIX fmt, ##arg)
>  
> -#define wl1271_info(fmt, arg...) \
> -	pr_info(DRIVER_PREFIX fmt "\n", ##arg)
> +#define wl1271_info(fmt, arg...)		\
> +	pr_info(DRIVER_PREFIX fmt, ##arg)
>  
> -#define wl1271_debug(level, fmt, arg...) \
> -	do { \
> +#define wl1271_debug(level, fmt, arg...)	\
> +	do {					\
>  		if (level & wl12xx_debug_level) \
> -			pr_debug(DRIVER_PREFIX fmt "\n", ##arg); \
> +			pr_debug(DRIVER_PREFIX fmt, ##arg); \
>  	} while (0)

Again, moving the \n from the macro definition and changing all the
callers is an unnecessary, intrusive change.

We have wanted to change "wl1271" to "wl12xx" for a long time, but we
don't do it exactly because this means we need to change the calls
everywhere.

So, this is a NACK from me, unless you have a really good reason why
this change is needed.

--
Luca.
