From: Florian Fainelli <f.fainelli@gmail.com>
Subject: Re: [PATCH 1/1] forcedeth: add MII ioctls support
Date: Thu, 12 Dec 2013 10:17:05 -0800
Message-ID: <CAGVrzcY-eU55kGaNku0TLWQ8wL7-tZk+=RX_bpv0wVcahcbxQw@mail.gmail.com>
References: <1386829089-24477-1-git-send-email-noureddine@aristanetworks.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Cc: "David S. Miller" <davem@davemloft.net>,
	Jiri Pirko <jiri@resnulli.us>,
	Patrick McHardy <kaber@trash.net>,
	Larry Finger <Larry.Finger@lwfinger.net>,
	Peter Zijlstra <peterz@infradead.org>,
	netdev <netdev@vger.kernel.org>
To: Salam Noureddine <noureddine@aristanetworks.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-pd0-f182.google.com ([209.85.192.182]:34707 "EHLO
	mail-pd0-f182.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751519Ab3LLSRq (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 12 Dec 2013 13:17:46 -0500
Received: by mail-pd0-f182.google.com with SMTP id v10so941364pde.13
        for <netdev@vger.kernel.org>; Thu, 12 Dec 2013 10:17:46 -0800 (PST)
In-Reply-To: <1386829089-24477-1-git-send-email-noureddine@aristanetworks.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

2013/12/11 Salam Noureddine <noureddine@aristanetworks.com>:
>
> Signed-off-by: Salam Noureddine <noureddine@aristanetworks.com>

Would you consider implementing the PHY library knobs instead? You
would get all of that basically for free.

> ---
>  drivers/net/ethernet/nvidia/forcedeth.c |   34 +++++++++++++++++++++++++++++++
>  1 files changed, 34 insertions(+), 0 deletions(-)
>
> diff --git a/drivers/net/ethernet/nvidia/forcedeth.c b/drivers/net/ethernet/nvidia/forcedeth.c
> index 2d045be..0d8c88a 100644
> --- a/drivers/net/ethernet/nvidia/forcedeth.c
> +++ b/drivers/net/ethernet/nvidia/forcedeth.c
> @@ -5558,6 +5558,38 @@ static int nv_close(struct net_device *dev)
>         return 0;
>  }
>
> +static int nv_ioctl(struct net_device *dev, struct ifreq *req, int cmd)
> +{
> +       int ret = 0;
> +       u32 val;
> +       struct fe_priv *np = netdev_priv(dev);
> +       struct mii_ioctl_data *data = (struct mii_ioctl_data *) &req->ifr_data;
> +
> +       switch (cmd) {
> +       case SIOCGMIIPHY:
> +               data->phy_id = np->phyaddr;
> +               break;
> +       case SIOCGMIIREG:
> +               spin_lock_irq(&np->lock);
> +               val = mii_rw(dev, np->phyaddr, data->reg_num & 0x1f, MII_READ);
> +               spin_unlock_irq(&np->lock);
> +               data->val_out = val;
> +               break;
> +       case SIOCSMIIREG:
> +               if (!capable(CAP_NET_ADMIN))
> +                       return -EPERM;
> +               spin_lock_irq(&np->lock);
> +               ret = mii_rw(dev, np->phyaddr, data->reg_num & 0x1f,
> +                            data->val_in);
> +               spin_unlock_irq(&np->lock);
> +               break;
> +       default:
> +               return -EOPNOTSUPP;
> +       }
> +
> +       return ret;
> +}
> +
>  static const struct net_device_ops nv_netdev_ops = {
>         .ndo_open               = nv_open,
>         .ndo_stop               = nv_close,
> @@ -5568,6 +5600,7 @@ static const struct net_device_ops nv_netdev_ops = {
>         .ndo_fix_features       = nv_fix_features,
>         .ndo_set_features       = nv_set_features,
>         .ndo_validate_addr      = eth_validate_addr,
> +       .ndo_do_ioctl           = nv_ioctl,
>         .ndo_set_mac_address    = nv_set_mac_address,
>         .ndo_set_rx_mode        = nv_set_multicast,
>  #ifdef CONFIG_NET_POLL_CONTROLLER
> @@ -5585,6 +5618,7 @@ static const struct net_device_ops nv_netdev_ops_optimized = {
>         .ndo_fix_features       = nv_fix_features,
>         .ndo_set_features       = nv_set_features,
>         .ndo_validate_addr      = eth_validate_addr,
> +       .ndo_do_ioctl           = nv_ioctl,
>         .ndo_set_mac_address    = nv_set_mac_address,
>         .ndo_set_rx_mode        = nv_set_multicast,
>  #ifdef CONFIG_NET_POLL_CONTROLLER
> --
> 1.7.4.4
>
> --
> To unsubscribe from this list: send the line "unsubscribe netdev" in
> the body of a message to majordomo@vger.kernel.org
> More majordomo info at  http://vger.kernel.org/majordomo-info.html



-- 
Florian
