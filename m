From: Ingo Oeser <netdev-BkyiQQGWkgE@public.gmane.org>
Subject: Re: Re: [PATCH] ebtables: Port ebt_[u]log.c to nf[netlink]_log
Date: Mon, 14 Nov 2005 13:09:37 +0100
Message-ID: <200511141309.37056.netdev@axxeo.de>
References: <20051007234903.GR4450@rama.customers.eurospot.com> <1129648337.4504.3.camel@localhost.localdomain> <20051112094936.GA27644@sunbeam.de.gnumonks.org>
Mime-Version: 1.0
Content-Type: text/plain;
  charset="iso-8859-15"
Content-Transfer-Encoding: 7bit
Cc: Bart De Schuymer <bdschuym-LPO8gxj9N8aZIoH1IeqzKA@public.gmane.org>,
	Linux Netdev List <netdev-u79uwXL29TY76Z2rM5mHXA@public.gmane.org>,
	ebtables-devel-5NWGOfrQmneRv+LV9MX5uipxlwaOVQ5f@public.gmane.org
Return-path: <ebtables-devel-admin-5NWGOfrQmneRv+LV9MX5uipxlwaOVQ5f@public.gmane.org>
To: Harald Welte <laforge-TgoAw6mPHtdg9hUCZPvPmw@public.gmane.org>
In-Reply-To: <20051112094936.GA27644-XKR8MNpNCaUy1wpV0ib6OjPN8QKu1tr+@public.gmane.org>
Content-Disposition: inline
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

Hi Harald,

would you mind merging the prink()s ...

Harald Welte wrote:
> diff --git a/net/bridge/netfilter/ebt_log.c b/net/bridge/netfilter/ebt_log.c
> --- a/net/bridge/netfilter/ebt_log.c
> +++ b/net/bridge/netfilter/ebt_log.c
> @@ -55,17 +57,19 @@ static void print_MAC(unsigned char *p)
>  }
>  
>  #define myNIPQUAD(a) a[0], a[1], a[2], a[3]
> -static void ebt_log(const struct sk_buff *skb, unsigned int hooknr,
> -   const struct net_device *in, const struct net_device *out,
> -   const void *data, unsigned int datalen)
> +static void
> +ebt_log_packet(unsigned int pf, unsigned int hooknum,
> +   const struct sk_buff *skb, const struct net_device *in,
> +   const struct net_device *out, const struct nf_loginfo *loginfo,
> +   const char *prefix)
>  {
> -	struct ebt_log_info *info = (struct ebt_log_info *)data;
>  	char level_string[4] = "< >";
> +	unsigned int bitmask;
>  
> -	level_string[1] = '0' + info->loglevel;
> +	level_string[1] = '0' + loginfo->u.log.level;
>  	spin_lock_bh(&ebt_log_lock);
>  	printk(level_string);
> -	printk("%s IN=%s OUT=%s ", info->prefix, in ? in->name : "",
> +	printk("%s IN=%s OUT=%s ", prefix, in ? in->name : "",
>  	   out ? out->name : "");
>  
>  	printk("MAC source = ");

... here ...

> @@ -75,7 +79,12 @@ static void ebt_log(const struct sk_buff
>  
>  	printk("proto = 0x%04x", ntohs(eth_hdr(skb)->h_proto));
>  

... and here?

> -	if ((info->bitmask & EBT_LOG_IP) && eth_hdr(skb)->h_proto ==
> +	if (loginfo->type == NF_LOG_TYPE_LOG)
> +		bitmask = loginfo->u.log.logflags;
> +	else
> +		bitmask = NF_LOG_MASK;
> +
> +	if ((bitmask & EBT_LOG_IP) && eth_hdr(skb)->h_proto ==
>  	   htons(ETH_P_IP)){
>  		struct iphdr _iph, *ih;
>  

I prefer evil printk()s over multiple ones :-)


Regards

Ingo Oeser



-------------------------------------------------------
This SF.Net email is sponsored by the JBoss Inc.  Get Certified Today
Register for a JBoss Training Course.  Free Certification Exam
for All Training Attendees Through End of 2005. For more info visit:
http://ads.osdn.com/?ad_id=7628&alloc_id=16845&op=click
