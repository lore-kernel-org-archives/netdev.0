From: Petr Mladek <pmladek@suse.com>
Subject: Re: [PATCH v4.2-rc1] printk: make extended printk support
 conditional on netconsole
Date: Wed, 1 Jul 2015 18:05:13 +0200
Message-ID: <20150701160513.GC8099@pathway.suse.cz>
References: <1430318704-32374-1-git-send-email-tj@kernel.org>
 <1430318704-32374-4-git-send-email-tj@kernel.org>
 <CAMuHMdWwH-3kx1ma5KE=fP94by8boxM_QYqPKpU=YJw8t3hYeg@mail.gmail.com>
 <20150629152805.GM15805@mtj.duckdns.org>
 <CAMuHMdXTn0+z4PV9UVZZmpMdk_-JUc4x-GqZweOhQyYMTzSOGQ@mail.gmail.com>
 <20150629154914.GQ15805@mtj.duckdns.org>
 <CAMuHMdX-cA3RccXF2kBifMEyT8e14rURp9Li_WFm7ODBOti=QQ@mail.gmail.com>
 <20150629161355.GS15805@mtj.duckdns.org>
 <20150629233140.GA7711@mtj.duckdns.org>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: Linus Torvalds <torvalds@linux-foundation.org>,
	Andrew Morton <akpm@linux-foundation.org>,
	"David S. Miller" <davem@davemloft.net>,
	"linux-kernel@vger.kernel.org" <linux-kernel@vger.kernel.org>,
	"netdev@vger.kernel.org" <netdev@vger.kernel.org>,
	Kay Sievers <kay@vrfy.org>,
	Josh Triplett <josh@joshtriplett.org>,
	Linux Embedded <linux-embedded@vger.kernel.org>,
	Geert Uytterhoeven <geert@linux-m68k.org>
To: Tejun Heo <tj@kernel.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from cantor2.suse.de ([195.135.220.15]:55273 "EHLO mx2.suse.de"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1753452AbbGAQFQ (ORCPT <rfc822;netdev@vger.kernel.org>);
	Wed, 1 Jul 2015 12:05:16 -0400
Content-Disposition: inline
In-Reply-To: <20150629233140.GA7711@mtj.duckdns.org>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Mon 2015-06-29 19:31:40, Tejun Heo wrote:
> 6fe29354befe ("printk: implement support for extended console
> drivers") implemented extended printk support for extended netconsole.
> The code added was miniscule but it added static 8k buffer
> unconditionally unnecessarily bloating the kernel for cases where
> extended netconsole is not used.
> 
> This patch introduces CONFIG_PRINTK_CON_EXTENDED which is selected by
> CONFIG_NETCONSOLE.  If the config option is not set, extended printk
> support is compiled out along with the static buffer.
> 
> Verified 8k reduction in vmlinux bss when !CONFIG_NETCONSOLE.
> 
> Signed-off-by: Tejun Heo <tj@kernel.org>
> Reported-and-suggested-by: Geert Uytterhoeven <geert@linux-m68k.org>
> ---
> Linus, Andrew.
> 
> This removes an unnecessary 8k bss bloat introduced during v4.2-rc1
> merge window on certain configs.  The original patch was routed
> through -mm.  How should this be routed?
> 
> Thanks.
> 
>  drivers/net/Kconfig    |    1 +
>  init/Kconfig           |    3 +++
>  kernel/printk/printk.c |   33 +++++++++++++++++++++++++++++----
>  3 files changed, 33 insertions(+), 4 deletions(-)

[...]

> --- a/kernel/printk/printk.c
> +++ b/kernel/printk/printk.c
[...]
> @@ -2561,9 +2584,11 @@ void register_console(struct console *ne
>  		console_drivers->next = newcon;
>  	}
>  
> -	if (newcon->flags & CON_EXTENDED)
> -		if (!nr_ext_console_drivers++)
> +	if (newcon->flags & CON_EXTENDED) {
> +		if (!nr_ext_console_drivers)
>  			pr_info("printk: continuation disabled due to ext consoles, expect more fragments in /dev/kmsg\n");
> +		inc_nr_ext_console_drivers();

We should handle also the situation when CON_EXTENDED is set
and CONFIG_PRINTK_CON_EXTENDED is not set by mistake. Otherwise,
we will not increment nr_ext_console_drivers here => ext_text will
not be filled in console_unlock() => call_console_drivers()
will print nothing for the CON_EXTENDED console.

At least, I would print an error here. Something like.

#ifndef CONFIG_PRINTK_CON_EXTENDED
		pr_err("The registered extended console will print nothing because the kernel is not compiled with PRINTK_CON_EXTENDED\n");
#endif

I wonder if there is a good identification of the console that can be printed.

Otherwise, it looks fine to me.

Best Regards,
Petr
