From: Francois Romieu <romieu@fr.zoreil.com>
Subject: Re: [PATCH] (4/4) convert irlan to seq_file interface
Date: Mon, 18 Aug 2003 23:25:54 +0200
Sender: netdev-bounce@oss.sgi.com
Message-ID: <20030818232554.A7779@electric-eye.fr.zoreil.com>
References: <20030818122702.67e9162d.shemminger@osdl.org>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: Jean Tourrilhes <jt@bougret.hpl.hp.com>,
   "David S. Miller" <davem@redhat.com>, irda-users@lists.sourceforge.net,
   netdev@oss.sgi.com
Return-path: <netdev-bounce@oss.sgi.com>
To: Stephen Hemminger <shemminger@osdl.org>
Content-Disposition: inline
In-Reply-To: <20030818122702.67e9162d.shemminger@osdl.org>; from shemminger@osdl.org on Mon, Aug 18, 2003 at 12:27:02PM -0700
Errors-to: netdev-bounce@oss.sgi.com
List-Id: netdev.vger.kernel.org

Stephen Hemminger <shemminger@osdl.org> :
> Convert irlan /proc interface to safer seq_file library.
[...]
> diff -Nru a/net/irda/irlan/irlan_filter.c b/net/irda/irlan/irlan_filter.c
> --- a/net/irda/irlan/irlan_filter.c	Mon Aug 18 11:11:02 2003
> +++ b/net/irda/irlan/irlan_filter.c	Mon Aug 18 11:11:02 2003
[...]
> @@ -216,26 +217,24 @@
>   *    Print status of filter. Used by /proc file system
>   *
>   */
> -int irlan_print_filter(int filter_type, char *buf)
> +#ifdef CONFIG_PROC_FS
> +void irlan_print_filter(struct seq_file *seq, int filter_type)
>  {
> -	int len = 0;
> -
>  	if (filter_type & IRLAN_DIRECTED)
> -		len += sprintf(buf+len, "%s", "DIRECTED ");
> +		seq_printf(seq, "%s", "DIRECTED ");
>  	if (filter_type & IRLAN_FUNCTIONAL)
> -		len += sprintf(buf+len, "%s", "FUNCTIONAL ");
> +		seq_printf(seq, "%s", "FUNCTIONAL ");
>  	if (filter_type & IRLAN_GROUP)
> -		len += sprintf(buf+len, "%s", "GROUP ");
> +		seq_printf(seq, "%s", "GROUP ");
>  	if (filter_type & IRLAN_MAC_FRAME)
> -		len += sprintf(buf+len, "%s", "MAC_FRAME ");
> +		seq_printf(seq, "%s", "MAC_FRAME ");
>  	if (filter_type & IRLAN_MULTICAST)
> -		len += sprintf(buf+len, "%s", "MULTICAST ");
> +		seq_printf(seq, "%s", "MULTICAST ");
>  	if (filter_type & IRLAN_BROADCAST)
> -		len += sprintf(buf+len, "%s", "BROADCAST ");
> +		seq_printf(seq, "%s", "BROADCAST ");
>  	if (filter_type & IRLAN_IPX_SOCKET)
> -		len += sprintf(buf+len, "%s", "IPX_SOCKET");
> -
> -	len += sprintf(buf+len, "\n");
> +		seq_printf(seq, "%s", "IPX_SOCKET");
>  
> -	return len;
> +	seq_putc(seq, '\n');
>  }
> +#endif

(Ugly) variable naming apart, what about:

void irlan_print_filter(struct seq_file *seq, int filter_type)
{
	static struct {
		int mask;
		char *str;
	} filter_mask2str[] = {
		{ IRLAN_DIRECTED,	"DIRECTED" },
		{ IRLAN_FUNCTIONAL,	"FUNCTIONAL" },
		{ IRLAN_GROUP,		"GROUP" },
		{ IRLAN_MAC_FRAME,	"MAC_FRAME" },
		{ IRLAN_MULTICAST,	"MULTICAST" },
		{ IRLAN_BROADCAST,	"BROADCAST" },
		{ IRLAN_IPX_SOCKET,	"IPX_SOCKET" },
		{ 0,			NULL }
	}, *p;

	for (p = filter_mask2str; p->str; p++) {
		if (filter_type & p->mask)
			seq_printf(seq, "%s ", p->str);
	}
	seq_putc(seq, '\n');
}

--
Ueimor
