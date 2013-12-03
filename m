From: Vlad Yasevich <vyasevich@gmail.com>
Subject: Re: [PATCH v2] macvlan: Support creating macvtaps from macvlans
Date: Tue, 03 Dec 2013 11:17:37 -0500
Message-ID: <529E0421.2090504@gmail.com>
References: <1386043991-4372-1-git-send-email-kevin@pentabarf.net> <1386068122-12039-1-git-send-email-kevin@pentabarf.net>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1
Content-Transfer-Encoding: 7bit
Cc: Michal Kubecek <mkubecek@suse.cz>
To: Kevin Wallace <kevin@pentabarf.net>, netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-yh0-f45.google.com ([209.85.213.45]:59673 "EHLO
	mail-yh0-f45.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752535Ab3LCQRk (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 3 Dec 2013 11:17:40 -0500
Received: by mail-yh0-f45.google.com with SMTP id v1so9088657yhn.4
        for <netdev@vger.kernel.org>; Tue, 03 Dec 2013 08:17:40 -0800 (PST)
In-Reply-To: <1386068122-12039-1-git-send-email-kevin@pentabarf.net>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On 12/03/2013 05:55 AM, Kevin Wallace wrote:
> When running in a network namespace whose only link to the outside
> world is a macvlan device, not being able to create a macvtap off of
> it is a real pain.
> 
> So modify macvtap creation to automatically forward a creation of a
> macvtap on a macvlan to become a creation of a macvtap on the
> underlying network device, just like is currently done with
> macvlan-on-macvlan devices.
> 
> v2: Use netif_is_macvlan and macvlan_dev_real_dev helpers to make it
>     more clear what we're doing.
> 
> Signed-off-by: Kevin Wallace <kevin@pentabarf.net>
> ---
>  drivers/net/macvlan.c | 8 +++-----
>  1 file changed, 3 insertions(+), 5 deletions(-)
> 
> diff --git a/drivers/net/macvlan.c b/drivers/net/macvlan.c
> index acf9379..cfb9157 100644
> --- a/drivers/net/macvlan.c
> +++ b/drivers/net/macvlan.c
> @@ -820,13 +820,11 @@ int macvlan_common_newlink(struct net *src_net, struct net_device *dev,
>  	if (lowerdev == NULL)
>  		return -ENODEV;
>  
> -	/* When creating macvlans on top of other macvlans - use
> +	/* When creating macvlans or macvtaps on top of other macvlans - use
>  	 * the real device as the lowerdev.
>  	 */
> -	if (lowerdev->rtnl_link_ops == dev->rtnl_link_ops) {
> -		struct macvlan_dev *lowervlan = netdev_priv(lowerdev);
> -		lowerdev = lowervlan->lowerdev;
> -	}
> +	if (netif_is_macvlan(lowerdev))
> +		lowerdev = macvlan_dev_real_dev(lowerdev);
>  
>  	if (!tb[IFLA_MTU])
>  		dev->mtu = lowerdev->mtu;
> 

the other question is should this be done in a loop?  What happens if
you have nested namespaces?

-vlad
