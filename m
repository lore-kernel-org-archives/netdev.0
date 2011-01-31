From: Joe Perches <joe-6d6DIl74uiNBDgjK7y7TUQ@public.gmane.org>
Subject: Re: [PATCH 1/1] compat-wireless: Fix ath9k debug log issue.
Date: Mon, 31 Jan 2011 10:58:16 -0800
Message-ID: <1296500296.4131.175.camel@Joe-Laptop>
References: <1296473865-18529-1-git-send-email-senthilkumar@atheros.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="UTF-8"
Content-Transfer-Encoding: 7bit
Cc: luis.rodriguez-DlyHzToyqoxBDgjK7y7TUQ@public.gmane.org, mcgrof-Re5JQEeQqe8AvxtiuMwx3w@public.gmane.org,
	linux-wireless-u79uwXL29TY76Z2rM5mHXA@public.gmane.org, netdev-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
To: Senthil Balasubramanian <senthilkumar-DlyHzToyqoxBDgjK7y7TUQ@public.gmane.org>
Return-path: <linux-wireless-owner-u79uwXL29TY76Z2rM5mHXA@public.gmane.org>
In-Reply-To: <1296473865-18529-1-git-send-email-senthilkumar-DlyHzToyqoxBDgjK7y7TUQ@public.gmane.org>
Sender: linux-wireless-owner-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
List-Id: netdev.vger.kernel.org

On Mon, 2011-01-31 at 17:07 +0530, Senthil Balasubramanian wrote:
> ath9k debug logs are not shown as we are using recursive vsnprintf
> which are supported in kernel 2.6.36 and above. use vprintk for older
> kernels.

#ifdefs spread around the tree for this sort of
change are not very nice.

Perhaps wireless-compat should not be an impediment to
mainline progress and these sorts of changes should be
minimized.
 
If this is really necessary for backward compatibility,
I think the %pV could just be removed.

If not, because this style would be used in several
places, perhaps another macro could be used to hide the
use of %pV.

Maybe something like:

#if (LINUX_VERSION_CODE >= KERNEL_VERSION(2,6,36))
#define PRINTK_VA_LIST(level, prefix, fmt, __va_list)	\
({							\
 	struct va_format vaf;				\
 							\
 	vaf.fmt = fmt;					\
 	vaf.va = &__va_list;				\
							\
	printk("%s" prefix "%pV", level, &vaf);		\
})
#else
#define PRINTK_VA_LIST(level, prefix, fmt, __va_list)	\
({							\
	printk("%s" prefix, level);			\
	vprintk(fmt, __va_list);			\
})
#endif

> +diff --git a/drivers/net/wireless/ath/main.c b/drivers/net/wireless/ath/main.c
> +index c325202..e3e60d4 100644
> +--- a/drivers/net/wireless/ath/main.c
> ++++ b/drivers/net/wireless/ath/main.c
> +@@ -60,16 +60,23 @@ EXPORT_SYMBOL(ath_rxbuf_alloc);
> + int ath_printk(const char *level, struct ath_common *common,
> + 	       const char *fmt, ...)
> + {
> ++#if (LINUX_VERSION_CODE >= KERNEL_VERSION(2,6,36))
> + 	struct va_format vaf;
> ++#endif
> + 	va_list args;
> + 	int rtn;
> + 
> + 	va_start(args, fmt);
> + 
> ++#if (LINUX_VERSION_CODE >= KERNEL_VERSION(2,6,36))
> + 	vaf.fmt = fmt;
> + 	vaf.va = &args;
> + 
> + 	rtn = printk("%sath: %pV", level, &vaf);
> ++#else
> ++	printk("%sath: ", level);
> ++	rtn = vprintk(fmt, args);
> ++#endif
> + 
> + 	va_end(args);
> + 

So this would become something like:

int ath_printk(const char *level, struct ath_common *common,
	       const char *fmt, ...)
{
	va_list args;
	int rtn;

	va_start(args, fmt);

	rtn = PRINTK_VA_LIST(level, "ath: ", fmt, args);

	va_end(args);

	return rtn;
}


--
To unsubscribe from this list: send the line "unsubscribe linux-wireless" in
the body of a message to majordomo-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
More majordomo info at  http://vger.kernel.org/majordomo-info.html
