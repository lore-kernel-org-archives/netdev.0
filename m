From: David Ahern <dsahern@gmail.com>
Subject: Re: [Patch net] ipv6: avoid unregistering inet6_dev for loopback
Date: Wed, 21 Jun 2017 23:07:07 -0400
Message-ID: <f11ffe19-ed48-86c2-6726-9af9b2954a7e@gmail.com>
References: <1498080898-17338-1-git-send-email-xiyou.wangcong@gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=windows-1252
Content-Transfer-Encoding: 7bit
Cc: Andrey Konovalov <andreyknvl@google.com>,
        Daniel Lezcano <dlezcano@fr.ibm.com>
To: Cong Wang <xiyou.wangcong@gmail.com>, netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-qk0-f196.google.com ([209.85.220.196]:36618 "EHLO
        mail-qk0-f196.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1751997AbdFVDHw (ORCPT
        <rfc822;netdev@vger.kernel.org>); Wed, 21 Jun 2017 23:07:52 -0400
Received: by mail-qk0-f196.google.com with SMTP id r62so553189qkf.3
        for <netdev@vger.kernel.org>; Wed, 21 Jun 2017 20:07:52 -0700 (PDT)
In-Reply-To: <1498080898-17338-1-git-send-email-xiyou.wangcong@gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On 6/21/17 5:34 PM, Cong Wang wrote:
> diff --git a/net/ipv6/addrconf.c b/net/ipv6/addrconf.c
> index 686c923..1d2dbac 100644
> --- a/net/ipv6/addrconf.c
> +++ b/net/ipv6/addrconf.c
> @@ -3369,6 +3369,7 @@ static int addrconf_notify(struct notifier_block *this, unsigned long event,
>  	struct net_device *dev = netdev_notifier_info_to_dev(ptr);
>  	struct netdev_notifier_changeupper_info *info;
>  	struct inet6_dev *idev = __in6_dev_get(dev);
> +	struct net *net = dev_net(dev);

Given the number of NETDEV events and the fact that only 2 need net,
perhaps the dev_net(dev) should be inline ...

>  	int run_pending = 0;
>  	int err;
>  
> @@ -3384,7 +3385,7 @@ static int addrconf_notify(struct notifier_block *this, unsigned long event,
>  	case NETDEV_CHANGEMTU:
>  		/* if MTU under IPV6_MIN_MTU stop IPv6 on this interface. */
>  		if (dev->mtu < IPV6_MIN_MTU) {
> -			addrconf_ifdown(dev, 1);
> +			addrconf_ifdown(dev, dev != net->loopback_dev);

so:
			addrconf_ifdown(dev, dev != dev_net(dev)->loopback_dev);


>  			break;
>  		}
>  
> @@ -3500,7 +3501,7 @@ static int addrconf_notify(struct notifier_block *this, unsigned long event,
>  			 * IPV6_MIN_MTU stop IPv6 on this interface.
>  			 */
>  			if (dev->mtu < IPV6_MIN_MTU)
> -				addrconf_ifdown(dev, 1);
> +				addrconf_ifdown(dev, dev != net->loopback_dev);
>  		}
>  		break;
>  
> 

The overall idea of not destroying idev for loopback on a failure to set
MTU seems correct to me.

Acked-by: David Ahern <dsahern@gmail.com>
