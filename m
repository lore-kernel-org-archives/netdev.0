From: Petr Mladek <pmladek@suse.com>
Subject: Re: [PATCH v2 v4.2-rc1] printk: make extended printk support
 conditional on netconsole
Date: Fri, 3 Jul 2015 16:07:34 +0200
Message-ID: <20150703140352.GD32664@pathway.suse.cz>
References: <1430318704-32374-1-git-send-email-tj@kernel.org>
 <1430318704-32374-4-git-send-email-tj@kernel.org>
 <CAMuHMdWwH-3kx1ma5KE=fP94by8boxM_QYqPKpU=YJw8t3hYeg@mail.gmail.com>
 <20150629152805.GM15805@mtj.duckdns.org>
 <CAMuHMdXTn0+z4PV9UVZZmpMdk_-JUc4x-GqZweOhQyYMTzSOGQ@mail.gmail.com>
 <20150629154914.GQ15805@mtj.duckdns.org>
 <CAMuHMdX-cA3RccXF2kBifMEyT8e14rURp9Li_WFm7ODBOti=QQ@mail.gmail.com>
 <20150629161355.GS15805@mtj.duckdns.org>
 <20150629233140.GA7711@mtj.duckdns.org>
 <20150702162141.GC30677@mtj.duckdns.org>
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
	geert@linux-m68k.org
To: Tejun Heo <tj@kernel.org>
Return-path: <linux-embedded-owner@vger.kernel.org>
Content-Disposition: inline
In-Reply-To: <20150702162141.GC30677@mtj.duckdns.org>
Sender: linux-embedded-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On Thu 2015-07-02 12:21:41, Tejun Heo wrote:
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
> v2: Added a warning for cases where CON_EXTENDED is requested while
>     CONFIG_PRINTK_CON_EXTENDED is disabled as suggested by Petr.
> 
> Cc: Petr Mladek <pmladek@suse.com>
> Signed-off-by: Tejun Heo <tj@kernel.org>
> Reported-and-suggested-by: Geert Uytterhoeven <geert@linux-m68k.org>

Reviewed-by: Petr Mladek <pmladek@suse.cz>

There is still one small thing that might get improved, see below.
But it is not that important and might be solved later. I am sorry
for not noticing it last time.


> diff --git a/kernel/printk/printk.c b/kernel/printk/printk.c
> index cf8c242..f719118 100644
> --- a/kernel/printk/printk.c
> +++ b/kernel/printk/printk.c
> @@ -84,6 +84,10 @@ static struct lockdep_map console_lock_dep_map = {
>  };
>  #endif
>  
> +#ifdef CONFIG_PRINTK_CON_EXTENDED
> +
> +#define CONSOLE_EXT_LOG_BUF_LEN		CONSOLE_EXT_LOG_MAX
> +
>  /*
>   * Number of registered extended console drivers.
>   *
> @@ -96,6 +100,32 @@ static struct lockdep_map console_lock_dep_map = {
>   */
>  static int nr_ext_console_drivers;
>  
> +static void inc_nr_ext_console_drivers(void)
> +{
> +	nr_ext_console_drivers++;
> +}
> +
> +static void dec_nr_ext_console_drivers(void)
> +{
> +	nr_ext_console_drivers--;
> +}
> +
> +#else	/* CONFIG_PRINTK_CON_EXTENDED */
> +
> +#define CONSOLE_EXT_LOG_BUF_LEN		0
> +#define nr_ext_console_drivers		0
> +
> +static void inc_nr_ext_console_drivers(void)
> +{
> +	WARN_ONCE(true, "printk: CON_EXTENDED requested when !CONFIG_PRINTK_CON_EXTENDED\n");
> +}
> +
> +static void dec_nr_ext_console_drivers(void)
> +{
> +}
> +
> +#endif	/* CONFIG_PRINTK_CON_EXTENDED */
> +
>  /*
>   * Helper macros to handle lockdep when locking/unlocking console_sem. We use
>   * macros instead of functions so that _RET_IP_ contains useful information.
> @@ -2561,9 +2591,11 @@ void register_console(struct console *newcon)
>  		console_drivers->next = newcon;
>  	}
>  
> -	if (newcon->flags & CON_EXTENDED)
> -		if (!nr_ext_console_drivers++)
> +	if (newcon->flags & CON_EXTENDED) {
> +		if (!nr_ext_console_drivers)
>  			pr_info("printk: continuation disabled due to ext consoles, expect more fragments in /dev/kmsg\n");

I would move the check and the message into
inc_nr_ext_console_drivers() when CONFIG_PRINTK_CON_EXTENDED is
defined. It does not make sense if we do not increment the counter.

Best Regards,
Petr
