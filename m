From: Stephen Hemminger <stephen@networkplumber.org>
Subject: Re: [PATCH net-next v2] dev: always advertise rx_flags changes
Date: Tue, 24 Sep 2013 09:47:07 -0700
Message-ID: <20130924094707.41641042@nehalam.linuxnetplumber.net>
References: <20130923122715.1d1b2005@nehalam.linuxnetplumber.net>
	<1380039692-8157-1-git-send-email-nicolas.dichtel@6wind.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, davem@davemloft.net
To: Nicolas Dichtel <nicolas.dichtel@6wind.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-pa0-f42.google.com ([209.85.220.42]:34447 "EHLO
	mail-pa0-f42.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752856Ab3IXQrM (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 24 Sep 2013 12:47:12 -0400
Received: by mail-pa0-f42.google.com with SMTP id lj1so5247047pab.29
        for <netdev@vger.kernel.org>; Tue, 24 Sep 2013 09:47:12 -0700 (PDT)
In-Reply-To: <1380039692-8157-1-git-send-email-nicolas.dichtel@6wind.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Tue, 24 Sep 2013 18:21:32 +0200
Nicolas Dichtel <nicolas.dichtel@6wind.com> wrote:

> diff --git a/net/core/dev.c b/net/core/dev.c
> index 5c713f2239cc..067bfbe70c4c 100644
> --- a/net/core/dev.c
> +++ b/net/core/dev.c
> @@ -4822,7 +4822,7 @@ static void dev_change_rx_flags(struct net_device *dev, int flags)
>  		ops->ndo_change_rx_flags(dev, flags);
>  }
>  
> -static int __dev_set_promiscuity(struct net_device *dev, int inc)
> +static int __dev_set_promiscuity(struct net_device *dev, int inc, bool notif)
>  {
>  	unsigned int old_flags = dev->flags;
>  	kuid_t uid;
> @@ -4865,6 +4865,10 @@ static int __dev_set_promiscuity(struct net_device *dev, int inc)
>  
>  		dev_change_rx_flags(dev, IFF_PROMISC);
>  	}
> +	if (notif) {
> +		call_netdevice_notifiers(NETDEV_CHANGE, dev);
> +		rtmsg_ifinfo(RTM_NEWLINK, dev, IFF_PROMISC);
> +	}
>  	return 0;
>  }

This is getting uglier as the conditional is added to each
function. Why not create a helper function and change callers.

static void __dev_notify_flag(dev, int flags)
{
        call_netdevice_notifiers(NETDEV_CHANGE, dev);
	rtmsg_ifinfo(RTM_NEWLINK, dev, flags);
}
