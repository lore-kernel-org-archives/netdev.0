From: jamal <hadi@cyberus.ca>
Subject: Re: dummy as IMQ replacement
Date: 31 Jan 2005 08:45:40 -0500
Message-ID: <1107179140.7840.157.camel@jzny.localdomain>
References: <1107123123.8021.80.camel@jzny.localdomain>
	 <200501311438.01118.hasso@estpak.ee>
	 <1107175673.7847.130.camel@jzny.localdomain>
	 <200501311502.56796.hasso@estpak.ee>
	 <20050131132819.GB31837@postel.suug.ch>
Reply-To: hadi@cyberus.ca
Mime-Version: 1.0
Content-Type: text/plain
Content-Transfer-Encoding: 7bit
Cc: Hasso Tepper <hasso@estpak.ee>, netdev@oss.sgi.com,
        Nguyen Dinh Nam <nguyendinhnam@gmail.com>,
        Remus <rmocius@auste.elnet.lt>, Andre Tomt <andre@tomt.net>,
        syrius.ml@no-log.org, Andy Furniss <andy.furniss@dsl.pipex.com>,
        Damion de Soto <damion@snapgear.com>
Return-path: <netdev-bounce@oss.sgi.com>
To: Thomas Graf <tgraf@suug.ch>
In-Reply-To: <20050131132819.GB31837@postel.suug.ch>
Sender: netdev-bounce@oss.sgi.com
Errors-to: netdev-bounce@oss.sgi.com
List-Id: netdev.vger.kernel.org


Yeah, that would fix it. Note however, that i am trying to highly
discourage use of iptables and i would rather let people who use
iptables to suffer;-> (sounds rude i know). At some point i plan to
remove the dependency on iptables altogether. So i am not sure whether i
should encourage pushing of this patch or not ;->
All this hooking in 100 hooks is one of the reasons i disliked IMQ as
well

cheers,
jamal

PS:- also note in 2.6.6 tc action was not yet in, so 
On Mon, 2005-01-31 at 08:28, Thomas Graf wrote:
> > > > http://mailman.ds9a.nl/pipermail/lartc/2004q2/012422.html
> 
> It depends on whether you have CONFIG_NET_CLS_ACT enabled or not.
> If so, the ingress qdisc is hit before PREROUTING and thus can't
> see the mark for a good reason. Simply removing the dependcy on
> the mark resolves the issue for you.
> 
> If you don't have CONFIG_NET_CLS_ACT enabled you would see the
> mark if the ingress qdisc would register on the IPv6 PREROUTING
> hook but apparently it doesn't.
> 
> The patch below should fix it, it is completely untested though.
> 
> --- linux-2.6.11-rc2-bk8.orig/net/sched/sch_ingress.c	2005-01-30 21:19:51.000000000 +0100
> +++ linux-2.6.11-rc2-bk8/net/sched/sch_ingress.c	2005-01-31 14:23:08.000000000 +0100
> @@ -271,6 +271,14 @@
>  	.priority       = NF_IP_PRI_FILTER + 1,
>  };
>  
> +static struct nf_hook_ops ing6_ops = {
> +	.hook           = ing_hook,
> +	.owner		= THIS_MODULE,
> +	.pf             = PF_INET6,
> +	.hooknum        = NF_IP6_PRE_ROUTING,
> +	.priority       = NF_IP6_PRI_FILTER + 1,
> +};
> +
>  #endif
>  #endif
>  
> @@ -296,6 +304,11 @@
>  			printk("ingress qdisc registration error \n");
>  			return -EINVAL;
>  		}
> +		if (nf_register_hook(&ing6_ops) < 0) {
> +			nf_unregister_hook(&ing_ops);
> +			printk("ingress ipv6 qdisc registration error \n");
> +			return -EINVAL;
> +		}
>  		nf_registered++;
>  	}
>  #endif
> @@ -408,8 +421,10 @@
>  	unregister_qdisc(&ingress_qdisc_ops);
>  #ifndef CONFIG_NET_CLS_ACT
>  #ifdef CONFIG_NETFILTER
> -	if (nf_registered)
> +	if (nf_registered) {
>  		nf_unregister_hook(&ing_ops);
> +		nf_unregister_hook(&ing6_ops);
> +	}
>  #endif
>  #endif
>  }
> 
> 
