From: Julian Anastasov <ja@ssi.bg>
Subject: Re: [PATCH net-next 1/3 v7] net: track link-status of ipv4
 nexthops
Date: Tue, 8 Sep 2015 23:32:56 +0300 (EEST)
Message-ID: <alpine.LFD.2.11.1509082313120.1756@ja.home.ssi.bg>
References: <1435081538-1620-1-git-send-email-gospo@cumulusnetworks.com> <1435081538-1620-2-git-send-email-gospo@cumulusnetworks.com>
Mime-Version: 1.0
Content-Type: TEXT/PLAIN; charset=US-ASCII
Cc: netdev@vger.kernel.org, davem@davemloft.net,
	ddutt@cumulusnetworks.com, sfeldma@gmail.com,
	alexander.duyck@gmail.com, hannes@stressinduktion.org,
	stephen@networkplumber.org
To: Andy Gospodarek <gospo@cumulusnetworks.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from ja.ssi.bg ([178.16.129.10]:58284 "EHLO ja.ssi.bg"
	rhost-flags-OK-FAIL-OK-FAIL) by vger.kernel.org with ESMTP
	id S1752337AbbIHUdU (ORCPT <rfc822;netdev@vger.kernel.org>);
	Tue, 8 Sep 2015 16:33:20 -0400
In-Reply-To: <1435081538-1620-2-git-send-email-gospo@cumulusnetworks.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>


	Hello,

On Tue, 23 Jun 2015, Andy Gospodarek wrote:

> Add a fib flag called RTNH_F_LINKDOWN to any ipv4 nexthops that are
> reachable via an interface where carrier is off.  No action is taken,
> but additional flags are passed to userspace to indicate carrier status.
> 
> This also includes a cleanup to fib_disable_ip to more clearly indicate
> what event made the function call to replace the more cryptic force
> option previously used.
> 

> diff --git a/net/ipv4/fib_frontend.c b/net/ipv4/fib_frontend.c
> index 872494e..534eb14 100644
> --- a/net/ipv4/fib_frontend.c
> +++ b/net/ipv4/fib_frontend.c

> @@ -1093,7 +1093,7 @@ static int fib_inetaddr_event(struct notifier_block *this, unsigned long event,
>  			/* Last address was deleted from this interface.
>  			 * Disable IP.
>  			 */
> -			fib_disable_ip(dev, 1);
> +			fib_disable_ip(dev, event);

	NETDEV_DOWN for "inetaddr" event is used instead of force=1 ...

>  	case NETDEV_DOWN:
> -		fib_disable_ip(dev, 0);
> +		fib_disable_ip(dev, event);

	Ops, NETDEV_DOWN for different "netdev" event is
used this time for force=0 ...

> diff --git a/net/ipv4/fib_semantics.c b/net/ipv4/fib_semantics.c
> index 28ec3c1..b1b305b 100644
> --- a/net/ipv4/fib_semantics.c
> +++ b/net/ipv4/fib_semantics.c

> @@ -1112,7 +1124,8 @@ int fib_sync_down_dev(struct net_device *dev, int force)
>  	struct hlist_head *head = &fib_info_devhash[hash];
>  	struct fib_nh *nh;
>  
> -	if (force)
> +	if (event == NETDEV_UNREGISTER ||
> +	    event == NETDEV_DOWN)

	Wrong, both kinds of NETDEV_DOWN events set scope = -1.
May be this leads to removal of RT_SCOPE_NOWHERE NHs when
"netdev" event NETDEV_DOWN comes. May be we still need a
flag to know if the NETDEV_DOWN event was for force=1 and
to check it again above? Or may be to use "force" flag again?

>  		scope = -1;

Regards

--
Julian Anastasov <ja@ssi.bg>
