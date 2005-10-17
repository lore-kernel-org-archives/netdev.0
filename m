From: Bart De Schuymer <bdschuym-LPO8gxj9N8aZIoH1IeqzKA@public.gmane.org>
Subject: Re: [PATCH] ebtables: Port ebt_[u]log.c to nf[netlink]_log
Date: Mon, 17 Oct 2005 17:59:59 +0000
Message-ID: <1129571999.3383.6.camel@localhost.localdomain>
References: <20051007234903.GR4450@rama.customers.eurospot.com>
Mime-Version: 1.0
Content-Type: text/plain
Content-Transfer-Encoding: 7bit
Cc: Linux Netdev List <netdev-u79uwXL29TY76Z2rM5mHXA@public.gmane.org>,
	ebtables-devel-5NWGOfrQmneRv+LV9MX5uipxlwaOVQ5f@public.gmane.org
Return-path: <ebtables-devel-admin-5NWGOfrQmneRv+LV9MX5uipxlwaOVQ5f@public.gmane.org>
To: Harald Welte <laforge-Cap9r6Oaw4JrovVCs/uTlw@public.gmane.org>
In-Reply-To: <20051007234903.GR4450-5xaKNk1AN7bNqB9Gf7YOJg/oQhhTQFE7QQ4Iyu8u01E@public.gmane.org>
Sender: ebtables-devel-admin-5NWGOfrQmneRv+LV9MX5uipxlwaOVQ5f@public.gmane.org
Errors-To: ebtables-devel-admin-5NWGOfrQmneRv+LV9MX5uipxlwaOVQ5f@public.gmane.org
List-Unsubscribe: <https://lists.sourceforge.net/lists/listinfo/ebtables-devel>,
	<mailto:ebtables-devel-request-5NWGOfrQmneRv+LV9MX5uipxlwaOVQ5f@public.gmane.org?subject=unsubscribe>
List-Post: <mailto:ebtables-devel-5NWGOfrQmneRv+LV9MX5uipxlwaOVQ5f@public.gmane.org>
List-Help: <mailto:ebtables-devel-request-5NWGOfrQmneRv+LV9MX5uipxlwaOVQ5f@public.gmane.org?subject=help>
List-Subscribe: <https://lists.sourceforge.net/lists/listinfo/ebtables-devel>,
	<mailto:ebtables-devel-request-5NWGOfrQmneRv+LV9MX5uipxlwaOVQ5f@public.gmane.org?subject=subscribe>
List-Archive: <http://sourceforge.net/mailarchive/forum.php?forum=ebtables-devel>
List-Id: netdev.vger.kernel.org

Op za, 08-10-2005 te 01:49 +0200, schreef Harald Welte:
> Hi Bart!
> 
> The patch below is totally untested (though it compiles), and updates
> ebtables to resemble the behaviour that we now have in ipv4 (and ipv6):
> {ip,ip6,eb}tables just tell the nf_log core that they want to log a
> packet, the mechanism (syslog, nfnetlink_log, ...) is actually decided
> by nf_log.
> 
> By default, everything will behave like before.
> 
> Please review, and test that ebt_log and ebt_ulog are still working as
> expected.  Thanks!

Sorry for the late reply, some hardware problems got in the way.
Apart from the comments below, the patch is fine by me (I tested both).

Thanks a lot,
Bart

> @@ -144,6 +153,21 @@ static void ebt_log(const struct sk_buff
>  out:
>  	printk("\n");
>  	spin_unlock_bh(&ebt_log_lock);
> +
> +}
> +
> +static void ebt_log(const struct sk_buff *skb, unsigned int hooknr,
> +   const struct net_device *in, const struct net_device *out,
> +   const void *data, unsigned int datalen)
> +{
> +	struct ebt_log_info *info = (struct ebt_log_info *)data;
> +	struct nf_loginfo li;
> +
> +	li.type = NF_LOG_TYPE_LOG;
> +	li.u.log.level = info->loglevel;
> +	li.u.log.logflags = info->bitmask;
> +
> +	nf_log_packet(PF_BRIDGE, hooknr, skb, in, out, &li, info->prefix);

Should be ebt_log_packet

>  }
>  
>  static struct ebt_watcher log =
> @@ -154,13 +178,32 @@ static struct ebt_watcher log =
>  	.me		= THIS_MODULE,
>  };
>  
> +static struct nf_logger ebt_log_logger = {
> +	.name 		= "ebt_log",
> +	.logfn		= &ebt_log_packet,
> +	.me		= THIS_MODULE,
> +};
> +
>  static int __init init(void)
>  {
> -	return ebt_register_watcher(&log);
> +	int ret;
> +
> +	ret = ebt_register_watcher(&log);
> +	if (ret < 0)
> +		return ret;
> +	if (nf_log_register(PF_BRIDGE, &ebt_log_logger) < 0) {
> +		printk(KERN_WARNING "ebt_log: not logging via system console "
> +		       "since somebody else already registered for PF_INET\n");
> +		/* wecannot make module load fail here, since otherwise 
> +		 * ebtables userspace would abort */
> +	}

Since we're using PF_BRIDGE instead of PF_INET now, this if construct
can be replaced by a simple call to nf_log_register.




-------------------------------------------------------
This SF.Net email is sponsored by:
Power Architecture Resource Center: Free content, downloads, discussions,
and more. http://solutions.newsforge.com/ibmarch.tmpl
