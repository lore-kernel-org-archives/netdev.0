From: Thomas Graf <tgraf@suug.ch>
Subject: Re: [PATCH] rtnl_unlock/lock in sch_api.c
Date: Mon, 28 Mar 2005 16:47:01 +0200
Message-ID: <20050328144701.GA3086@postel.suug.ch>
References: <Pine.LNX.4.62.0503281720430.20453@webhosting.rdsbv.ro>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: netdev@oss.sgi.com, davem@davemloft.net
Return-path: <netdev-bounce@oss.sgi.com>
To: "Catalin(ux aka Dino) BOIE" <util@deuroconsult.ro>
Content-Disposition: inline
In-Reply-To: <Pine.LNX.4.62.0503281720430.20453@webhosting.rdsbv.ro>
Sender: netdev-bounce@oss.sgi.com
Errors-to: netdev-bounce@oss.sgi.com
List-Id: netdev.vger.kernel.org

Looks good, except...

> --- linux/net/sched/sch_api.c.orig	2005-03-28 16:32:57.000000000 +0300
> +++ linux/net/sched/sch_api.c	2005-03-28 16:38:17.000000000 +0300
> @@ -404,18 +404,28 @@ qdisc_create(struct net_device *dev, u32
>  	struct Qdisc_ops *ops;
>  	int size;
>  
> +	err = -EINVAL;
>  	ops = qdisc_lookup_ops(kind);
>  #ifdef CONFIG_KMOD
> -	if (ops==NULL && tca[TCA_KIND-1] != NULL) {
> +	if (ops == NULL && kind != NULL) {
>  		char name[IFNAMSIZ];
>  		if (rtattr_strlcpy(name, kind, IFNAMSIZ) < IFNAMSIZ) {
> +			/* Must drop rtnl sem because request_module
> +			 * can try to aquire rtnl sem (see teql for
> +			 * example)
> +			 */
> +			rtnl_unlock();
>  			request_module("sch_%s", name);
> +			rtnl_lock();
>  			ops = qdisc_lookup_ops(kind);
> +			if (ops != NULL) {
> +				module_put(ops->owner);
> +				err = -EAGAIN;

You're missing a goto err_out here, the ops == NULL won't catch it.

> +			}
>  		}
>  	}
>  #endif
>  
> -	err = -EINVAL;
>  	if (ops == NULL)
>  		goto err_out;

With the above goto inserted there is no need to move the err = -EINVAL.
