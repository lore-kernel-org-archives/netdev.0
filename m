From: Francois Romieu <romieu@fr.zoreil.com>
Subject: Re: [PATCH v3] netpoll: protect napi_poll and poll_controller during dev_[open|close]
Date: Fri, 1 Feb 2013 22:21:51 +0100
Message-ID: <20130201212151.GA13221@electric-eye.fr.zoreil.com>
References: <1359578665-29248-1-git-send-email-nhorman@tuxdriver.com> <1359740951-23156-1-git-send-email-nhorman@tuxdriver.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: netdev@vger.kernel.org, Ivan Vecera <ivecera@redhat.com>,
	"David S. Miller" <davem@davemloft.net>,
	Ben Hutchings <bhutchings@solarflare.com>,
	Eric Dumazet <eric.dumazet@gmail.com>
To: Neil Horman <nhorman@tuxdriver.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from violet.fr.zoreil.com ([92.243.8.30]:36490 "EHLO
	violet.fr.zoreil.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1757470Ab3BAVxE (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 1 Feb 2013 16:53:04 -0500
Content-Disposition: inline
In-Reply-To: <1359740951-23156-1-git-send-email-nhorman@tuxdriver.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Neil Horman <nhorman@tuxdriver.com> :
[...]
> diff --git a/net/core/dev.c b/net/core/dev.c
> index a87bc74..90b267a 100644
> --- a/net/core/dev.c
> +++ b/net/core/dev.c
[...]
> @@ -1266,6 +1268,19 @@ static int __dev_open(struct net_device *dev)
>  	if (!netif_device_present(dev))
>  		return -ENODEV;
>  
> +	/*
> +	 * Block netpoll from trying to do any rx path servicing
> +	 * If we don't do this there is a chance ndo_poll_controller
> +	 * or ndo_poll may be running while we open the device
> +	 */
> +	rcu_read_lock();
> +	ni = rcu_dereference(dev->npinfo);
> +	if (ni && test_and_set_bit(NETPOLL_RX_ACTIVE, &ni->flags)) {
> +		rcu_read_unlock();
> +		return -EBUSY;
> +	}
> +	rcu_read_unlock();
> +

struct net_device contains no npinfo member when CONFIG_NETPOLL is not set.

-- 
Ueimor
