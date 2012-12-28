From: Flavio Leitner <fbl@redhat.com>
Subject: Re: [PATCH net-next] bridge: respect RFC2863 operational state
Date: Fri, 28 Dec 2012 11:03:37 -0200
Message-ID: <20121228130337.GA30336@obelix.rh>
References: <20121227222854.6ec132dd@nehalam.linuxnetplumber.net>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: David Miller <davem@davemloft.net>, netdev@vger.kernel.org
To: Stephen Hemminger <shemminger@vyatta.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mx1.redhat.com ([209.132.183.28]:15611 "EHLO mx1.redhat.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1753536Ab2L1NDm (ORCPT <rfc822;netdev@vger.kernel.org>);
	Fri, 28 Dec 2012 08:03:42 -0500
Content-Disposition: inline
In-Reply-To: <20121227222854.6ec132dd@nehalam.linuxnetplumber.net>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Thu, Dec 27, 2012 at 10:28:54PM -0800, Stephen Hemminger wrote:
> The bridge link detection should follow the operational state
> of the lower device, rather than the carrier bit. This allows devices
> like tunnels that are controlled by userspace control plane to work
> with bridge STP link management.
> 
> 
> Signed-off-by: Stephen Hemminger <shemminger@vyatta.com>
> 
> 
> --- a/net/bridge/br_if.c	2012-10-25 09:11:15.627272524 -0700
> +++ b/net/bridge/br_if.c	2012-12-14 08:58:14.329847361 -0800
> @@ -66,14 +66,14 @@ void br_port_carrier_check(struct net_br
>  	struct net_device *dev = p->dev;
>  	struct net_bridge *br = p->br;
>  
> -	if (netif_running(dev) && netif_carrier_ok(dev))
> +	if (netif_running(dev) && netif_oper_up(dev))
>  		p->path_cost = port_cost(dev);
>  
>  	if (!netif_running(br->dev))
>  		return;
>  
>  	spin_lock_bh(&br->lock);
> -	if (netif_running(dev) && netif_carrier_ok(dev)) {
> +	if (netif_running(dev) && netif_oper_up(dev))
>  		if (p->state == BR_STATE_DISABLED)
>  			br_stp_enable_port(p);

I found this piece still using netif_carrier_ok():
321 int br_add_if(struct net_bridge *br, struct net_device *dev)
322 {
...
385 
386         if ((dev->flags & IFF_UP) && netif_carrier_ok(dev) &&
387             (br->dev->flags & IFF_UP))
388                 br_stp_enable_port(p);
389         spin_unlock_bh(&br->lock);
390 

Is there any reason for enabling stp on a port using operstate
in br_port_carrier_check() but not in br_add_if() ?

The same thing happens with br_stp_enable_bridge():

 56   list_for_each_entry(p, &br->port_list, list) {
 57          if ((p->dev->flags & IFF_UP) && netif_carrier_ok(p->dev))
 58                  br_stp_enable_port(p);

Also, as operstate UP means that packets are flowing, there is no need to
check if the device is opened, so checking only for operstate should be
enough, right? I.e.

-           if ((p->dev->flags & IFF_UP) && netif_carrier_ok(p->dev))
+           if (netif_oper_up(dev))


>  	} else {
> --- a/net/bridge/br_notify.c	2012-10-25 09:11:15.631272484 -0700
> +++ b/net/bridge/br_notify.c	2012-12-14 08:57:36.954222724 -0800
> @@ -82,7 +82,7 @@ static int br_device_event(struct notifi
>  		break;
>  
>  	case NETDEV_UP:
> -		if (netif_carrier_ok(dev) && (br->dev->flags & IFF_UP)) {
> +		if (netif_running(br->dev) && netif_oper_up(dev)) {
>  			spin_lock_bh(&br->lock);
>  			br_stp_enable_port(p);
>  			spin_unlock_bh(&br->lock);

You are not just changing to use operstate, but also to check another
flag - before it was IFF_UP and now __LINK_STATE_START. Any reason
for that besides being consistent with other checks?

thanks!
-- 
fbl
