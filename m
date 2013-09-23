From: Stephen Hemminger <stephen@networkplumber.org>
Subject: Re: [PATCH net-next] dev: advertise rx_flags changes
Date: Mon, 23 Sep 2013 12:27:15 -0700
Message-ID: <20130923122715.1d1b2005@nehalam.linuxnetplumber.net>
References: <1379946334-4183-1-git-send-email-nicolas.dichtel@6wind.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, davem@davemloft.net
To: Nicolas Dichtel <nicolas.dichtel@6wind.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-pa0-f49.google.com ([209.85.220.49]:55490 "EHLO
	mail-pa0-f49.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752529Ab3IWT1T (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 23 Sep 2013 15:27:19 -0400
Received: by mail-pa0-f49.google.com with SMTP id ld10so3939319pab.8
        for <netdev@vger.kernel.org>; Mon, 23 Sep 2013 12:27:18 -0700 (PDT)
In-Reply-To: <1379946334-4183-1-git-send-email-nicolas.dichtel@6wind.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Mon, 23 Sep 2013 16:25:34 +0200
Nicolas Dichtel <nicolas.dichtel@6wind.com> wrote:

> There is no netlink message/call to notifier chains when rx_flags are updated,
> let's advertise everybody.
> 
> Signed-off-by: Nicolas Dichtel <nicolas.dichtel@6wind.com>
> ---
>  net/core/dev.c | 9 +++++++--
>  1 file changed, 7 insertions(+), 2 deletions(-)
> 
> diff --git a/net/core/dev.c b/net/core/dev.c
> index 5c713f2239cc..6c91d3919279 100644
> --- a/net/core/dev.c
> +++ b/net/core/dev.c
> @@ -4818,8 +4818,13 @@ static void dev_change_rx_flags(struct net_device *dev, int flags)
>  {
>  	const struct net_device_ops *ops = dev->netdev_ops;
>  
> -	if ((dev->flags & IFF_UP) && ops->ndo_change_rx_flags)
> -		ops->ndo_change_rx_flags(dev, flags);
> +	if (dev->flags & IFF_UP) {
> +		if (ops->ndo_change_rx_flags)
> +			ops->ndo_change_rx_flags(dev, flags);
> +
> +		call_netdevice_notifiers(NETDEV_CHANGE, dev);
> +		rtmsg_ifinfo(RTM_NEWLINK, dev, flags);
> +	}
>  }
>  
>  static int __dev_set_promiscuity(struct net_device *dev, int inc)

This will cause duplicate notification if IFF_MULTICAST changes:

1. dev_change_flags
      __dev_change_flags
         dev_change_rx_flags
            call_netdevice_notifiers...

2. dev_change_flags
     __dev_notify_flags
        call_netdevice_notifiers...


        
