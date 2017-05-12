From: Eric Dumazet <eric.dumazet@gmail.com>
Subject: Re: [PATCH net] netvsc: fix net poll mode
Date: Fri, 12 May 2017 14:15:26 -0700
Message-ID: <1494623726.7796.136.camel@edumazet-glaptop3.roam.corp.google.com>
References: <20170512200331.14433-1-sthemmin@microsoft.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="UTF-8"
Content-Transfer-Encoding: 7bit
Cc: davem@davemloft.net, netdev@vger.kernel.org,
        Stephen Hemminger <sthemmin@microsoft.com>
To: Stephen Hemminger <stephen@networkplumber.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-pf0-f195.google.com ([209.85.192.195]:34393 "EHLO
        mail-pf0-f195.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1758146AbdELVP3 (ORCPT
        <rfc822;netdev@vger.kernel.org>); Fri, 12 May 2017 17:15:29 -0400
Received: by mail-pf0-f195.google.com with SMTP id w69so8249973pfk.1
        for <netdev@vger.kernel.org>; Fri, 12 May 2017 14:15:28 -0700 (PDT)
In-Reply-To: <20170512200331.14433-1-sthemmin@microsoft.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Fri, 2017-05-12 at 13:03 -0700, Stephen Hemminger wrote:
> The ndo_poll_controller function needs to schedule NAPI to pick
> up arriving packets and send completions. Otherwise no data
> will ever be received.
> 
> Signed-off-by: Stephen Hemminger <sthemmin@microsoft.com>
> ---
>  drivers/net/hyperv/netvsc_drv.c | 17 +++++++++++++----
>  1 file changed, 13 insertions(+), 4 deletions(-)
> 
> diff --git a/drivers/net/hyperv/netvsc_drv.c b/drivers/net/hyperv/netvsc_drv.c
> index 4421a6d00375..e487ccea251c 100644
> --- a/drivers/net/hyperv/netvsc_drv.c
> +++ b/drivers/net/hyperv/netvsc_drv.c
> @@ -1158,11 +1158,20 @@ netvsc_get_rxnfc(struct net_device *dev, struct ethtool_rxnfc *info,
>  }
>  
>  #ifdef CONFIG_NET_POLL_CONTROLLER
> -static void netvsc_poll_controller(struct net_device *net)
> +static void netvsc_poll_controller(struct net_device *dev)
>  {
> -	/* As netvsc_start_xmit() works synchronous we don't have to
> -	 * trigger anything here.
> -	 */
> +	struct net_device_context *ndc = netdev_priv(dev);
> +	struct netvsc_device *ndev = rtnl_dereference(ndc->nvdev);


rtnl_dereference() can not possibly be used in an ndo_poll_controller()

You would certainly trigger a lockdep issue here if you compile a kernel
with enough debugging support.

CONFIG_PROVE_RCU=y
CONFIG_PROVE_RCU_REPEATEDLY=y
CONFIG_SPARSE_RCU_POINTER=y
