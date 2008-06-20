From: Patrick McHardy <kaber@trash.net>
Subject: Re: [PATCH net-next 7/8] macvlan: Check return of dev_set_allmulti
Date: Fri, 20 Jun 2008 11:45:22 +0200
Message-ID: <485B7C32.8080605@trash.net>
References: <485B0011.7060601@cn.fujitsu.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-15; format=flowed
Content-Transfer-Encoding: 7bit
Cc: "David S. Miller" <davem@davemloft.net>,
	Jeff Garzik <jgarzik@pobox.com>,
	NETDEV <netdev@vger.kernel.org>
To: Wang Chen <wangchen@cn.fujitsu.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from stinky.trash.net ([213.144.137.162]:58168 "EHLO
	stinky.trash.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751491AbYFTJp1 (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 20 Jun 2008 05:45:27 -0400
In-Reply-To: <485B0011.7060601@cn.fujitsu.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Wang Chen wrote:
> allmulti might overflow.
> Commit: "netdevice: Fix promiscuity and allmulti overflow" in net-next makes
> dev_set_promiscuity/allmulti return error number if overflow happened.
> 
> Here, we check the positive increment for allmulti to get error return.
> 
> Signed-off-by: Wang Chen <wangchen@cn.fujitsu.com>
> ---
>  drivers/net/macvlan.c |    9 +++++++--
>  1 files changed, 7 insertions(+), 2 deletions(-)
> 
> diff --git a/drivers/net/macvlan.c b/drivers/net/macvlan.c
> index c36a03a..b0ed18f 100644
> --- a/drivers/net/macvlan.c
> +++ b/drivers/net/macvlan.c
> @@ -190,8 +190,13 @@ static int macvlan_open(struct net_device *dev)
>  	err = dev_unicast_add(lowerdev, dev->dev_addr, ETH_ALEN);
>  	if (err < 0)
>  		return err;
> -	if (dev->flags & IFF_ALLMULTI)
> -		dev_set_allmulti(lowerdev, 1);
> +	if (dev->flags & IFF_ALLMULTI) {
> +		err = dev_set_allmulti(lowerdev, 1);
> +		if (err < 0) {
> +			dev_unicast_delete(lowerdev, dev->dev_addr, ETH_ALEN);
> +			return err;
> +		}
> +	}

Please change this to use gotos for rollback on error.
