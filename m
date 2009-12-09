From: Joe Perches <joe@perches.com>
Subject: Re: [PATCH] Add sysctl to set the advertised TCP initial receive
 window.
Date: Tue, 08 Dec 2009 16:59:29 -0800
Message-ID: <1260320369.27677.183.camel@Joe-Laptop.home>
References: <pvmljhdat12.fsf@chavey.mtv.corp.google.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="UTF-8"
Content-Transfer-Encoding: 7bit
Cc: davem@davemloft.net, netdev@vger.kernel.org, therbert@google.com
To: chavey@google.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail.perches.com ([173.55.12.10]:1105 "EHLO mail.perches.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S967060AbZLIA7Y (ORCPT <rfc822;netdev@vger.kernel.org>);
	Tue, 8 Dec 2009 19:59:24 -0500
In-Reply-To: <pvmljhdat12.fsf@chavey.mtv.corp.google.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Tue, 2009-12-08 at 16:30 -0800, chavey@google.com wrote:
> Add a sysctl, tcp_init_rcv_wnd, to set the TCP initial receive window
> size advertised by passive and active TCP connections.

Hi Laurent.

> diff --git a/net/ipv4/sysctl_net_ipv4.c b/net/ipv4/sysctl_net_ipv4.c
> index 2dcf04d..1257f89 100644
> --- a/net/ipv4/sysctl_net_ipv4.c
> +++ b/net/ipv4/sysctl_net_ipv4.c
> @@ -656,6 +656,16 @@ static struct ctl_table ipv4_table[] = {
>  		.mode		= 0644,
>  		.proc_handler	= proc_dointvec
>  	},
> +	{
> +		.ctl_name	= CTL_UNNUMBERED,
> +		.procname	= "tcp_init_rcv_wnd",
> +		.data 		= &sysctl_tcp_init_rcv_wnd,
> +		.maxlen 	= sizeof(int),
> +		.mode 		= 0644,
> +		.proc_handler 	= proc_dointvec_minmax,
> +		.extra1		= &zero,
> +		.extra2		= TCP_INIT_RCV_WND_MAX

This won't work if you use proc_dointvec_minmax.

.extra1 and .extra2 are used as pointers to int,
not the int values themselves.

You'd have to use something like:

static const int zero = 0;
static const int tcp_init_rcv_wnd_max = TCP_INIT_RCV_WND_MAX;

[...]
		.proc_handler 	= proc_dointvec_minmax,
		.extra1		= &zero,
		.extra2		= &tcp_init_rcv_wnd_max;

For instance, the tcp_retries1 entry:

{
	.procname = "tcp_retries1",
	.data = &sysctl_tcp_retries1,
	.maxlen = sizeof(int),
	.mode = 0644,
	.proc_handler = proc_dointvec_minmax,
	.extra2 = &tcp_retr1_max
}


