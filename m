From: Michal Kubecek <mkubecek@suse.cz>
Subject: Re: [PATCH net] netdevice: Prefer NETIF_F_HW_CSUM when intersecting
 features
Date: Thu, 20 Apr 2017 08:13:12 +0200
Message-ID: <20170420061312.GF13789@unicorn.suse.cz>
References: <1492650743-28164-1-git-send-email-vyasevic@redhat.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: netdev@vger.kernel.org, tom@herbertland.com,
        Vladislav Yasevich <vyasevic@redhat.com>
To: Vladislav Yasevich <vyasevich@gmail.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mx2.suse.de ([195.135.220.15]:41998 "EHLO mx1.suse.de"
        rhost-flags-OK-OK-OK-FAIL) by vger.kernel.org with ESMTP
        id S941393AbdDTGNO (ORCPT <rfc822;netdev@vger.kernel.org>);
        Thu, 20 Apr 2017 02:13:14 -0400
Content-Disposition: inline
In-Reply-To: <1492650743-28164-1-git-send-email-vyasevic@redhat.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Wed, Apr 19, 2017 at 09:12:23PM -0400, Vladislav Yasevich wrote:
> While hardware device use either NETIF_F_(IP|IPV6)_CSUM or
> NETIF_F_HW_CSUM, all of the software devices use HW_CSUM.
> This results in an interesting situation when the software
> device is configured on top of hw device using (IP|IPV6)_CSUM.
> In this situation, the user can't turn off checksum offloading
> features on the software device.
> 
> This patch resolves that by prefering the NETIF_F_HW_CSUM setting
> when computing a feature intersect.

The reasoning makes sense to me but perhaps we should rename the helper
then to make it obvious that it doesn't work like intersection anymore
(not even in the logical sense).

> diff --git a/include/linux/netdevice.h b/include/linux/netdevice.h
> index 97456b25..3d811c1 100644
> --- a/include/linux/netdevice.h
> +++ b/include/linux/netdevice.h
> @@ -4019,9 +4019,9 @@ static inline netdev_features_t netdev_intersect_features(netdev_features_t f1,
>  {
>  	if ((f1 ^ f2) & NETIF_F_HW_CSUM) {
>  		if (f1 & NETIF_F_HW_CSUM)
> -			f1 |= (NETIF_F_IP_CSUM|NETIF_F_IPV6_CSUM);
> +			f2 |= NETIF_F_HW_CSUM;
>  		else
> -			f2 |= (NETIF_F_IP_CSUM|NETIF_F_IPV6_CSUM);
> +			f1 |= NETIF_F_HW_CSUM;
>  	}
>  
>  	return f1 & f2;

I hope I didn't miss something but it seems we can avoid nested ifs now:

 	if ((f1 ^ f2) & NETIF_F_HW_CSUM) {
		f1 |= NETIF_F_HW_CSUM;
		f2 |= NETIF_F_HW_CSUM;
 	}

Michal Kubecek
