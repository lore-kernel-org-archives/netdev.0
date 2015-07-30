From: Joe Perches <joe@perches.com>
Subject: Re: [PATCH] printk: Warn about dropped messages also on extended
 consoles
Date: Thu, 30 Jul 2015 05:10:46 -0700
Message-ID: <1438258246.2677.17.camel@perches.com>
References: <1438255732-31326-1-git-send-email-pmladek@suse.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="ISO-8859-1"
Content-Transfer-Encoding: 7bit
Cc: akpm@linux-foundation.org, Tejun Heo <tj@kernel.org>,
	davem@davemloft.net, linux-kernel@vger.kernel.org,
	netdev@vger.kernel.org
To: Petr Mladek <pmladek@suse.com>
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <1438255732-31326-1-git-send-email-pmladek@suse.com>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On Thu, 2015-07-30 at 13:28 +0200, Petr Mladek wrote:
> The commit #6fe29354befe4c ("printk: implement support for extended console
> drivers") added an extra buffer to format messages for extended consoles.
> We need to put there also the warning about dropped messages, so it appears
> on these consoles.
[]
> diff --git a/kernel/printk/printk.c b/kernel/printk/printk.c
[]
> @@ -2254,8 +2254,15 @@ again:
>  		}
>  
>  		if (console_seq < log_first_seq) {
> -			len = sprintf(text, "** %u printk messages dropped ** ",
> -				      (unsigned)(log_first_seq - console_seq));
> +			static const char dropped_msg[] =
> +				"** %u printk messages dropped ** ";

I don't see any value in dropped_msg as a
const char array instead of just using it directly
as a format in sprintf.  The linker will still use
a single format string in any case.

memcpy might be faster.

	if (nr_ext_console_drivers)
		memcpy(ext_text, text, len + 1);

> +			unsigned int dropped_count =
> +				(unsigned int)(log_first_seq - console_seq);
> +
> +			len = sprintf(text, dropped_msg, dropped_count);
> +			if (nr_ext_console_drivers)
> +				ext_len = sprintf(ext_text, dropped_msg,
> +						  dropped_count);
>  
