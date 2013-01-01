From: Stephen Hemminger <shemminger@vyatta.com>
Subject: Re: [patch net-next 1/7] rtnl: use dev_set_mac_address() instead of
 plain ndo_
Date: Tue, 1 Jan 2013 10:33:06 -0800
Message-ID: <20130101103306.78e26e89@nehalam.linuxnetplumber.net>
References: <1357047019-1037-1-git-send-email-jiri@resnulli.us>
	<1357047019-1037-2-git-send-email-jiri@resnulli.us>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, davem@davemloft.net, edumazet@google.com,
	bhutchings@solarflare.com, sassmann@redhat.com, kaber@trash.net,
	richard@nod.at
To: Jiri Pirko <jiri@resnulli.us>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail.vyatta.com ([76.74.103.46]:33554 "EHLO mail.vyatta.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1752390Ab3AASeb (ORCPT <rfc822;netdev@vger.kernel.org>);
	Tue, 1 Jan 2013 13:34:31 -0500
In-Reply-To: <1357047019-1037-2-git-send-email-jiri@resnulli.us>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Tue,  1 Jan 2013 14:30:13 +0100
Jiri Pirko <jiri@resnulli.us> wrote:

> Benefit from existence of dev_set_mac_address() and remove duplicate
> code.
> 
> Signed-off-by: Jiri Pirko <jiri@resnulli.us>
> ---
>  net/core/rtnetlink.c | 20 ++------------------
>  1 file changed, 2 insertions(+), 18 deletions(-)
> 
> diff --git a/net/core/rtnetlink.c b/net/core/rtnetlink.c
> index 2ef7a56..78d05a9 100644
> --- a/net/core/rtnetlink.c
> +++ b/net/core/rtnetlink.c
> @@ -1310,7 +1310,6 @@ static int do_setlink(struct net_device *dev, struct ifinfomsg *ifm,
>  		      struct nlattr **tb, char *ifname, int modified)
>  {
>  	const struct net_device_ops *ops = dev->netdev_ops;
> -	int send_addr_notify = 0;
>  	int err;
>  
>  	if (tb[IFLA_NET_NS_PID] || tb[IFLA_NET_NS_FD]) {
> @@ -1363,16 +1362,6 @@ static int do_setlink(struct net_device *dev, struct ifinfomsg *ifm,
>  		struct sockaddr *sa;
>  		int len;
>  
> -		if (!ops->ndo_set_mac_address) {
> -			err = -EOPNOTSUPP;
> -			goto errout;
> -		}
> -
> -		if (!netif_device_present(dev)) {
> -			err = -ENODEV;
> -			goto errout;
> -		}
> -
>  		len = sizeof(sa_family_t) + dev->addr_len;
>  		sa = kmalloc(len, GFP_KERNEL);
>  		if (!sa) {
> @@ -1382,13 +1371,11 @@ static int do_setlink(struct net_device *dev, struct ifinfomsg *ifm,
>  		sa->sa_family = dev->type;
>  		memcpy(sa->sa_data, nla_data(tb[IFLA_ADDRESS]),
>  		       dev->addr_len);
> -		err = ops->ndo_set_mac_address(dev, sa);
> +		err = dev_set_mac_address(dev, sa);
>  		kfree(sa);
>  		if (err)
>  			goto errout;
> -		send_addr_notify = 1;
>  		modified = 1;
> -		add_device_randomness(dev->dev_addr, dev->addr_len);
>  	}
>  
>  	if (tb[IFLA_MTU]) {
> @@ -1425,7 +1412,7 @@ static int do_setlink(struct net_device *dev, struct ifinfomsg *ifm,
>  
>  	if (tb[IFLA_BROADCAST]) {
>  		nla_memcpy(dev->broadcast, tb[IFLA_BROADCAST], dev->addr_len);
> -		send_addr_notify = 1;
> +		call_netdevice_notifiers(NETDEV_CHANGEADDR, dev);
>  	}
>  
>  	if (ifm->ifi_flags || ifm->ifi_change) {
> @@ -1546,9 +1533,6 @@ errout:
>  		net_warn_ratelimited("A link change request failed with some changes committed already. Interface %s may have been left with an inconsistent configuration, please check.\n",
>  				     dev->name);
>  
> -	if (send_addr_notify)
> -		call_netdevice_notifiers(NETDEV_CHANGEADDR, dev);
> -
>  	return err;
>  }
>  

This will cause call_netdevice_notifiers to be called twice if both IFLA_BROADCAST and IFLA_ADDRESS
are changed in one request. Not sure if that would break anything?
