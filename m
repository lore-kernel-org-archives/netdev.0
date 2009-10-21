From: Stephen Hemminger <shemminger@vyatta.com>
Subject: Re: [PATCH net-next-2.6] rtnetlink: rtnl_setlink() and
 rtnl_getlink() changes
Date: Thu, 22 Oct 2009 06:48:39 +0900
Message-ID: <20091022064839.6b343125@s6510>
References: <4ADF7633.9050208@gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Cc: "David S. Miller" <davem@davemloft.net>,
	Linux Netdev List <netdev@vger.kernel.org>
To: Eric Dumazet <eric.dumazet@gmail.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail.vyatta.com ([76.74.103.46]:48353 "EHLO mail.vyatta.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1754762AbZJUVsn (ORCPT <rfc822;netdev@vger.kernel.org>);
	Wed, 21 Oct 2009 17:48:43 -0400
In-Reply-To: <4ADF7633.9050208@gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Wed, 21 Oct 2009 22:59:31 +0200
Eric Dumazet <eric.dumazet@gmail.com> wrote:

> Stephen, do you think we could change "ip link show dev ethX" to
> let it use rtnl_getlink() instead of rtnl_dump_ifinfo() ?
> 
> Thanks !
> 
> [PATCH net-next-2.6]rtnetlink: rtnl_setlink() and rtnl_getlink() changes
> 
> rtnl_getlink() & rtnl_setlink() run with RTNL held, we can use
> __dev_get_by_index() and __dev_get_by_name() variants and avoid
> dev_hold()/dev_put()
> 
> Adds to rtnl_getlink() the capability to find a device by its name,
> not only by its index.
> 
> Signed-off-by: Eric Dumazet <eric.dumazet@gmail.com>
> ---
>  net/core/rtnetlink.c |   38 +++++++++++++++++++-------------------
>  1 files changed, 19 insertions(+), 19 deletions(-)
> 
> diff --git a/net/core/rtnetlink.c b/net/core/rtnetlink.c
> index eb42873..ba13b09 100644
> --- a/net/core/rtnetlink.c
> +++ b/net/core/rtnetlink.c
> @@ -910,9 +910,9 @@ static int rtnl_setlink(struct sk_buff *skb, struct nlmsghdr *nlh, void *arg)
>  	err = -EINVAL;
>  	ifm = nlmsg_data(nlh);
>  	if (ifm->ifi_index > 0)
> -		dev = dev_get_by_index(net, ifm->ifi_index);
> +		dev = __dev_get_by_index(net, ifm->ifi_index);
>  	else if (tb[IFLA_IFNAME])
> -		dev = dev_get_by_name(net, ifname);
> +		dev = __dev_get_by_name(net, ifname);
>  	else
>  		goto errout;
>  
> @@ -922,11 +922,9 @@ static int rtnl_setlink(struct sk_buff *skb, struct nlmsghdr *nlh, void *arg)
>  	}
>  
>  	if ((err = validate_linkmsg(dev, tb)) < 0)
> -		goto errout_dev;
> +		goto errout;
>  
>  	err = do_setlink(dev, ifm, tb, ifname, 0);
> -errout_dev:
> -	dev_put(dev);
>  errout:
>  	return err;
>  }
> @@ -1154,6 +1152,7 @@ static int rtnl_getlink(struct sk_buff *skb, struct nlmsghdr* nlh, void *arg)
>  {
>  	struct net *net = sock_net(skb->sk);
>  	struct ifinfomsg *ifm;
> +	char ifname[IFNAMSIZ];
>  	struct nlattr *tb[IFLA_MAX+1];
>  	struct net_device *dev = NULL;
>  	struct sk_buff *nskb;
> @@ -1163,19 +1162,23 @@ static int rtnl_getlink(struct sk_buff *skb, struct nlmsghdr* nlh, void *arg)
>  	if (err < 0)
>  		return err;
>  
> +	if (tb[IFLA_IFNAME])
> +		nla_strlcpy(ifname, tb[IFLA_IFNAME], IFNAMSIZ);
> +
>  	ifm = nlmsg_data(nlh);
> -	if (ifm->ifi_index > 0) {
> -		dev = dev_get_by_index(net, ifm->ifi_index);
> -		if (dev == NULL)
> -			return -ENODEV;
> -	} else
> +	if (ifm->ifi_index > 0)
> +		dev = __dev_get_by_index(net, ifm->ifi_index);
> +	else if (tb[IFLA_IFNAME])
> +		dev = __dev_get_by_name(net, ifname);
> +	else
>  		return -EINVAL;
>  
> +	if (dev == NULL)
> +		return -ENODEV;
> +
>  	nskb = nlmsg_new(if_nlmsg_size(dev), GFP_KERNEL);
> -	if (nskb == NULL) {
> -		err = -ENOBUFS;
> -		goto errout;
> -	}
> +	if (nskb == NULL)
> +		return -ENOBUFS;
>  
>  	err = rtnl_fill_ifinfo(nskb, dev, RTM_NEWLINK, NETLINK_CB(skb).pid,
>  			       nlh->nlmsg_seq, 0, 0);
> @@ -1183,11 +1186,8 @@ static int rtnl_getlink(struct sk_buff *skb, struct nlmsghdr* nlh, void *arg)
>  		/* -EMSGSIZE implies BUG in if_nlmsg_size */
>  		WARN_ON(err == -EMSGSIZE);
>  		kfree_skb(nskb);
> -		goto errout;
> -	}
> -	err = rtnl_unicast(nskb, net, NETLINK_CB(skb).pid);
> -errout:
> -	dev_put(dev);
> +	} else
> +		err = rtnl_unicast(nskb, net, NETLINK_CB(skb).pid);
>  
>  	return err;
>  }

Would work, but not sure what it gains.
