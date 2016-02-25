From: YOSHIFUJI Hideaki <hideaki.yoshifuji@miraclelinux.com>
Subject: Re: [PATCH 1/4] kernel: time: Add current_nw_timestamp() for network
 timestamps
Date: Thu, 25 Feb 2016 17:49:20 +0900
Message-ID: <56CEC010.1080506@miraclelinux.com>
References: <1456384031-29244-1-git-send-email-deepa.kernel@gmail.com>
 <1456384031-29244-2-git-send-email-deepa.kernel@gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=iso-2022-jp
Content-Transfer-Encoding: 7bit
Cc: hideaki.yoshifuji@miraclelinux.com, arnd@arndb.de,
	John Stultz <john.stultz@linaro.org>,
	Thomas Gleixner <tglx@linutronix.de>,
	"David S. Miller" <davem@davemloft.net>,
	Alexey Kuznetsov <kuznet@ms2.inr.ac.ru>,
	James Morris <jmorris@namei.org>,
	Hideaki YOSHIFUJI <yoshfuji@linux-ipv6.org>,
	Patrick McHardy <kaber@trash.net>
To: Deepa Dinamani <deepa.kernel@gmail.com>, netdev@vger.kernel.org,
	y2038@lists.linaro.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-pa0-f51.google.com ([209.85.220.51]:36763 "EHLO
	mail-pa0-f51.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1759389AbcBYIta (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 25 Feb 2016 03:49:30 -0500
Received: by mail-pa0-f51.google.com with SMTP id yy13so28683080pab.3
        for <netdev@vger.kernel.org>; Thu, 25 Feb 2016 00:49:30 -0800 (PST)
In-Reply-To: <1456384031-29244-2-git-send-email-deepa.kernel@gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Hi,

Deepa Dinamani wrote:
> ICMP timestamp messages and IP source route options require
> timestamps to be in milliseconds modulo 24 hours from
> midnight UTC format.
> 
> Add a time function to support this. The function returns the
> required timestamp in network byte order.
> 
> The function also uses y2038 safe time functions and data
> structures.
> 
> Signed-off-by: Deepa Dinamani <deepa.kernel@gmail.com>
> Cc: John Stultz <john.stultz@linaro.org>
> Cc: Thomas Gleixner <tglx@linutronix.de>
> Cc: "David S. Miller" <davem@davemloft.net>
> Cc: Alexey Kuznetsov <kuznet@ms2.inr.ac.ru>
> Cc: James Morris <jmorris@namei.org>
> Cc: Hideaki YOSHIFUJI <yoshfuji@linux-ipv6.org>
> Cc: Patrick McHardy <kaber@trash.net>
> ---
>  include/linux/ip.h     |  2 ++
>  include/linux/time64.h |  3 +++
>  kernel/time/time.c     | 26 ++++++++++++++++++++++++++
>  3 files changed, 31 insertions(+)
> 
> diff --git a/include/linux/ip.h b/include/linux/ip.h
> index 492bc65..edf923e 100644
> --- a/include/linux/ip.h
> +++ b/include/linux/ip.h
> @@ -34,4 +34,6 @@ static inline struct iphdr *ipip_hdr(const struct sk_buff *skb)
>  {
>  	return (struct iphdr *)skb_transport_header(skb);
>  }
> +
> +extern __be32 current_nw_timestamp(void);
>  #endif	/* _LINUX_IP_H */
> diff --git a/include/linux/time64.h b/include/linux/time64.h
> index 367d5af..5b5db3b 100644
> --- a/include/linux/time64.h
> +++ b/include/linux/time64.h
> @@ -35,6 +35,9 @@ struct itimerspec64 {
>  #define NSEC_PER_SEC	1000000000L
>  #define FSEC_PER_SEC	1000000000000000LL
>  
> +#define SECONDS_PER_DAY	86400
> +#define MSEC_PER_DAY	(SECONDS_PER_DAY * MSEC_PER_SEC)
> +
>  /* Located here for timespec[64]_valid_strict */
>  #define TIME64_MAX			((s64)~((u64)1 << 63))
>  #define KTIME_MAX			((s64)~((u64)1 << 63))
> diff --git a/kernel/time/time.c b/kernel/time/time.c
> index 86751c6..6df15df 100644
> --- a/kernel/time/time.c
> +++ b/kernel/time/time.c
> @@ -245,6 +245,32 @@ struct timespec current_fs_time(struct super_block *sb)
>  EXPORT_SYMBOL(current_fs_time);
>  
>  /*
> + * current_nw_timestamp - Return network time
> + *
> + * Return milliseconds since midnight in network byte order.
> + */
> +__be32 current_nw_timestamp(void)
> +{
> +	u64 now;
> +	u32 secs;
> +	u32 msecs;
> +	struct timespec64 ts;
> +
> +	ktime_get_ts64(&ts);
> +
> +	/* Get secs since midnight. */
> +	now = div_u64_rem(ts.tv_sec, SECONDS_PER_DAY, &secs);
> +	/* Convert to msecs. */
> +	msecs = secs * MSEC_PER_SEC;
> +	/* Convert nsec to msec. */
> +	msecs += (u32)ts.tv_nsec/NSEC_PER_MSEC;
> +
> +	/* Convert to network byte order. */
> +	return htons(msecs);
> +}
> +EXPORT_SYMBOL(current_nw_timestamp);
> +
> +/*
>   * Convert jiffies to milliseconds and back.
>   *
>   * Avoid unnecessary multiplications/divisions in the
> 

Since net/ipv4/* are the only users, it is enough to put
it in under net/ipv4/.

-- 
Hideaki Yoshifuji <hideaki.yoshifuji@miraclelinux.com>
Technical Division, MIRACLE LINUX CORPORATION
