From: Joe Perches <joe@perches.com>
Subject: Re: [PATCH 1/4] ppp: Clean up kernel log messages.
Date: Fri, 21 Jan 2011 11:30:32 -0800
Message-ID: <1295638232.25868.27.camel@Joe-Laptop>
References: <20110120.235601.139098188.davem@davemloft.net>
Mime-Version: 1.0
Content-Type: text/plain; charset="UTF-8"
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, paulus@samba.org
To: David Miller <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail.perches.com ([173.55.12.10]:3238 "EHLO mail.perches.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1754895Ab1AUTae (ORCPT <rfc822;netdev@vger.kernel.org>);
	Fri, 21 Jan 2011 14:30:34 -0500
In-Reply-To: <20110120.235601.139098188.davem@davemloft.net>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Thu, 2011-01-20 at 23:56 -0800, David Miller wrote:
> Use netdev_*() and pr_*().

Perhaps it's better to standardize on "PPP: " or "ppp: "
for these outputs.

Maybe use pr_fmt(fmt) "ppp: " fmt or add a function like:

void ppp_printk(const char *level, const struct ppp* ppp, const char *fmt, ...)
{
	struct va_list args;
	struct va_format vaf;

	va_start(args, fmt);

	vaf.fmt = fmt;
	vaf.va = &args;
	if (ppp && ppp->dev)
		netdev_printk(level, ppp->dev, "ppp: %pV", &vaf);
	else
		printk("%sppp: %pV", level, &vaf);

	va_end(va);
}
and
#define ppp_err(ppp, fmt, ...) ppp_printk(KERN_ERR, ppp, fmt, ##__VA_ARGS__)
etc...

> diff --git a/drivers/net/ppp_generic.c b/drivers/net/ppp_generic.c
> -			printk(KERN_DEBUG "PPPIOCDETACH file->f_count=%ld\n",
> -			       atomic_long_read(&file->f_count));
> +			pr_warn("PPPIOCDETACH file->f_count=%ld\n",
[]
> -		printk(KERN_ERR "PPP: not interface or channel??\n");
> +		pr_err("PPP: not interface or channel??\n");
[]
>  		if (net_ratelimit())
> -			printk(KERN_ERR "ppp: compressor dropped pkt\n");
> +			netdev_err(ppp->dev, "ppp: compressor dropped pkt\n");
[]
> -				printk(KERN_DEBUG "PPP: outbound frame not passed\n");
> +				netdev_printk(KERN_DEBUG, ppp->dev,
> +					      "PPP: outbound frame "
> +					      "not passed\n");
[]
> -				printk(KERN_ERR "ppp: compression required but down - pkt dropped.\n");
> +				netdev_err(ppp->dev,
> +					   "ppp: compression required but "
> +					   "down - pkt dropped.\n");

etc.

