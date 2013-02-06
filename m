From: Florian Fainelli <florian@openwrt.org>
Subject: Re: [PATCH 4/4] bgmac: add ndo_set_rx_mode netdev ops
Date: Wed, 06 Feb 2013 15:58:10 +0100
Message-ID: <51126F82.2030605@openwrt.org>
References: <1360161900-2330-1-git-send-email-hauke@hauke-m.de> <1360161900-2330-5-git-send-email-hauke@hauke-m.de>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8; format=flowed
Content-Transfer-Encoding: 7bit
Cc: davem@davemloft.net, zajec5@gmail.com, netdev@vger.kernel.org
To: Hauke Mehrtens <hauke@hauke-m.de>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-bk0-f43.google.com ([209.85.214.43]:36559 "EHLO
	mail-bk0-f43.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1755350Ab3BFPBJ (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 6 Feb 2013 10:01:09 -0500
Received: by mail-bk0-f43.google.com with SMTP id jm19so678750bkc.16
        for <netdev@vger.kernel.org>; Wed, 06 Feb 2013 07:01:07 -0800 (PST)
In-Reply-To: <1360161900-2330-5-git-send-email-hauke@hauke-m.de>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Hello Hauke,

On 02/06/2013 03:45 PM, Hauke Mehrtens wrote:
> Currently it is only possible to activate or deactivate promisc mode
> while the device is up.

This is required for bridging to work, so it is definitively a good fix 
to have.

>
> Signed-off-by: Hauke Mehrtens <hauke@hauke-m.de>
> ---
>   drivers/net/ethernet/broadcom/bgmac.c |   16 ++++++++++++----
>   1 file changed, 12 insertions(+), 4 deletions(-)
>
> diff --git a/drivers/net/ethernet/broadcom/bgmac.c b/drivers/net/ethernet/broadcom/bgmac.c
> index e0775c4..23c8d4a 100644
> --- a/drivers/net/ethernet/broadcom/bgmac.c
> +++ b/drivers/net/ethernet/broadcom/bgmac.c
> @@ -771,6 +771,16 @@ static void bgmac_write_mac_address(struct bgmac *bgmac, u8 *addr)
>   	bgmac_write(bgmac, BGMAC_MACADDR_LOW, tmp);
>   }
>
> +static void bgmac_set_rx_mode(struct net_device *net_dev)
> +{
> +	struct bgmac *bgmac = netdev_priv(net_dev);
> +
> +	if (net_dev->flags & IFF_PROMISC)
> +		bgmac_cmdcfg_maskset(bgmac, ~0, BGMAC_CMDCFG_PROM, false);
> +	else
> +		bgmac_cmdcfg_maskset(bgmac, ~BGMAC_CMDCFG_PROM, 0, false);
> +}
> +
>   #if 0 /* We don't use that regs yet */
>   static void bgmac_chip_stats_update(struct bgmac *bgmac)
>   {
> @@ -1024,10 +1034,7 @@ static void bgmac_chip_init(struct bgmac *bgmac, bool full_init)
>   	/* Enable 802.3x tx flow control (honor received PAUSE frames) */
>   	bgmac_cmdcfg_maskset(bgmac, ~BGMAC_CMDCFG_RPI, 0, true);
>
> -	if (bgmac->net_dev->flags & IFF_PROMISC)
> -		bgmac_cmdcfg_maskset(bgmac, ~0, BGMAC_CMDCFG_PROM, false);
> -	else
> -		bgmac_cmdcfg_maskset(bgmac, ~BGMAC_CMDCFG_PROM, 0, false);
> +	bgmac_set_rx_mode(bgmac->net_dev);
>
>   	bgmac_write_mac_address(bgmac, bgmac->net_dev->dev_addr);
>
> @@ -1209,6 +1216,7 @@ static const struct net_device_ops bgmac_netdev_ops = {
>   	.ndo_open		= bgmac_open,
>   	.ndo_stop		= bgmac_stop,
>   	.ndo_start_xmit		= bgmac_start_xmit,
> +	.ndo_set_rx_mode	= bgmac_set_rx_mode,
>   	.ndo_set_mac_address	= bgmac_set_mac_address,
>   	.ndo_validate_addr	= eth_validate_addr,
>   	.ndo_do_ioctl           = bgmac_ioctl,
>
