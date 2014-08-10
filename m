From: Romain Perier <romain.perier@gmail.com>
Subject: Re: [PATCH 1/2] ethernet: arc: Add support for specific SoC glue
 layer device tree bindings
Date: Sun, 10 Aug 2014 18:14:31 +0200
Message-ID: <53E79A67.7040305@gmail.com>
References: <1407500875-23851-1-git-send-email-romain.perier@gmail.com> <1809945.K2DXtKLbxa@diego>
Mime-Version: 1.0
Content-Type: text/plain; charset=windows-1252;
	format=flowed
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: davem@davemloft.net, max.schwarz@online.de, b.galvani@gmail.com,
	eric.dumazet@gmail.com, netdev@vger.kernel.org, arnd@arndb.de
To: =?windows-1252?Q?Heiko_St=FCbner?= <heiko@sntech.de>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-we0-f172.google.com ([74.125.82.172]:64299 "EHLO
	mail-we0-f172.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751167AbaHJQMq (ORCPT
	<rfc822;netdev@vger.kernel.org>); Sun, 10 Aug 2014 12:12:46 -0400
Received: by mail-we0-f172.google.com with SMTP id x48so7654906wes.3
        for <netdev@vger.kernel.org>; Sun, 10 Aug 2014 09:12:44 -0700 (PDT)
In-Reply-To: <1809945.K2DXtKLbxa@diego>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Hi Heiko,

Le 10/08/2014 14:03, Heiko St=FCbner a =E9crit :
> Hi Romain,
>
> [I've added Arnd, because he seemed interested in this when we talked=
 about it
> in IRC]
>
> Am Freitag, 8. August 2014, 12:27:54 schrieb Romain Perier:
>> Some platforms have special bank registers which might be used to se=
lect
>> the correct clock or the right mode for Media Indepent Interface
>> controllers. Sometimes, it is also required to activate vcc regulato=
rs in
>> the right order to supply the ethernet controller at the right time.=
 This
>> patch is a refactoring of the arc-emac device driver, it adds a new
>> software architecture design which allows to add specific platform g=
lue
>> layer. Each platform has now its own module which performs custom
>> initialization and remove for the target and then calls to the core =
driver.
>>
>> Signed-off-by: Romain Perier <romain.perier@gmail.com>
> mixing functional changes with general renames makes everything reall=
y hard to
> review. At most, you should have them separated into two patches.
Mhhh... yeah, I will split this into different patches.

>
> I'm not sure how I personally feel about renaming all the core functi=
ons for
> this. In my mind they could also simply keep their current naming, as=
 the
> whole IP is supposed to not have to many implementations except the a=
rc (and
> Rockchip one).

it would be really confusing... I don't want to put the arc logic into=20
emac_main.c. So we would have emac_arc.c module containing=20
"emac_arc_<foo>" functions or "arc_<foo>" and the core emac_main.c whic=
h=20
would contain "arc_emac_<foo>" functions ?
That's important to have a consistency naming, imho.


>
>
> [...]
>
>> diff --git a/drivers/net/ethernet/arc/emac_arc.c
>> b/drivers/net/ethernet/arc/emac_arc.c new file mode 100644
>> index 0000000..80ebb52
>> --- /dev/null
>> +++ b/drivers/net/ethernet/arc/emac_arc.c
>> @@ -0,0 +1,79 @@
>> +/**
>> + * emac_arc.c - ARC EMAC specific glue layer
>> + *
>> + * Copyright (C) 2014 Romain Perier
>> + *
>> + * Romain Perier  <romain.perier@gmail.com>
>> + *
>> + * This program is free software; you can redistribute it and/or mo=
dify
>> + * it under the terms of the GNU General Public License as publishe=
d by
>> + * the Free Software Foundation; either version 2 of the License, o=
r
>> + * (at your option) any later version.
>> + *
>> + * This program is distributed in the hope that it will be useful,
>> + * but WITHOUT ANY WARRANTY; without even the implied warranty of
>> + * MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
>> + * GNU General Public License for more details.
>> + */
>> +
>> +#include "emac.h"
>> +#include <linux/of_net.h>
>> +#include <linux/platform_device.h>
>> +#include <linux/module.h>
>> +#include <linux/clk.h>
>> +
>> +#define DRV_NAME "arc_emac"
>> +#define DRV_VERSION "1.0"
>> +
>> +static int arc_emac_probe(struct platform_device *pdev)
>> +{
>> +	struct emac_platform_data *emac_plat_data =3D NULL;
>> +	struct device *dev =3D &pdev->dev;
>> +	int ret =3D 0;
>> +
>> +	emac_plat_data =3D devm_kzalloc(dev, sizeof(*emac_plat_data), GFP_=
KERNEL);
>> +	if (!emac_plat_data)
>> +		return -ENOMEM;
>> +	emac_plat_data->name =3D DRV_NAME;
>> +	emac_plat_data->version =3D DRV_VERSION;
>> +	emac_plat_data->set_mac_speed =3D NULL;
>> +	emac_plat_data->priv =3D emac;
>> +
>> +	emac_plat_data->interface =3D of_get_phy_mode(dev->of_node);
> the original probe function, had an unconditional default value of
> PHY_INTERFACE_MODE_MII . So you should handle the of_get_phy_mode val=
ue as
> optional to keep compatibility:
>
> emac_plat_data->interface =3D of_get_phy_mode(dev->of_node);
> if (emac_plat_data->interface < 0)
> 	emac_plat_data->interface =3D PHY_INTERFACE_MODE_MII;
Ok noted, thanks.

Romain

>
>
> Heiko
>
>> +
>> +	emac_plat_data->clk =3D of_clk_get(dev->of_node, 0);
>> +        if (IS_ERR(emac_plat_data->clk)) {
>> +		dev_err(dev, "failed to retrieve clock from device tree\n");
>> +		return PTR_ERR_OR_ZERO(emac_plat_data->clk);
>> +	}
>> +
>> +	return emac_drv_probe(dev, emac_plat_data);
>> +}
>> +
>> +static int arc_emac_remove(struct platform_device *pdev)
>> +{
>> +	struct net_device *ndev =3D dev_get_drvdata(&pdev->dev);
>> +
>> +	return emac_drv_remove(ndev);
>> +}
>> +
>> +static const struct of_device_id arc_emac_dt_ids[] =3D {
>> +	{ .compatible =3D "snps,arc-emac" },
>> +	{ /* Sentinel */ }
>> +};
>> +
>> +static struct platform_driver arc_emac_driver =3D {
>> +	.probe =3D arc_emac_probe,
>> +	.remove =3D arc_emac_remove,
>> +	.driver =3D {
>> +		.name =3D DRV_NAME,
>> +		.owner =3D THIS_MODULE,
>> +		.of_match_table  =3D arc_emac_dt_ids,
>> +	},
>> +};
>> +
>> +module_platform_driver(arc_emac_driver);
>> +
>> +MODULE_AUTHOR("Romain Perier <romain.perier@gmail.com>");
>> +MODULE_DESCRIPTION("ARC EMAC driver");
>> +MODULE_LICENSE("GPL");
>> diff --git a/drivers/net/ethernet/arc/emac_main.c
>> b/drivers/net/ethernet/arc/emac_main.c index 18e2fac..ce04890 100644
>> --- a/drivers/net/ethernet/arc/emac_main.c
>> +++ b/drivers/net/ethernet/arc/emac_main.c
>> @@ -11,6 +11,7 @@
>>    *		Amit Bhor
>>    *		Sameer Dhavale
>>    *		Vineet Gupta
>> + *		Romain Perier
>>    */
>>
>>   #include <linux/crc32.h>
>> @@ -26,19 +27,17 @@
>>
>>   #include "emac.h"
>>
>> -#define DRV_NAME	"arc_emac"
>> -#define DRV_VERSION	"1.0"
>>
>>   /**
>> - * arc_emac_adjust_link - Adjust the PHY link duplex.
>> + * emac_adjust_link - Adjust the PHY link duplex.
>>    * @ndev:	Pointer to the net_device structure.
>>    *
>>    * This function is called to change the duplex setting after auto
>> negotiation * is done by the PHY.
>>    */
>> -static void arc_emac_adjust_link(struct net_device *ndev)
>> +static void emac_adjust_link(struct net_device *ndev)
>>   {
>> -	struct arc_emac_priv *priv =3D netdev_priv(ndev);
>> +	struct emac_priv *priv =3D netdev_priv(ndev);
>>   	struct phy_device *phy_dev =3D priv->phy_dev;
>>   	unsigned int reg, state_changed =3D 0;
>>
>> @@ -50,17 +49,19 @@ static void arc_emac_adjust_link(struct net_devi=
ce
>> *ndev) if (priv->speed !=3D phy_dev->speed) {
>>   		priv->speed =3D phy_dev->speed;
>>   		state_changed =3D 1;
>> +		if (priv->plat_data->set_mac_speed)
>> +			priv->plat_data->set_mac_speed(priv->plat_data->priv, priv-
>> speed);
>>   	}
>>
>>   	if (priv->duplex !=3D phy_dev->duplex) {
>> -		reg =3D arc_reg_get(priv, R_CTRL);
>> +		reg =3D emac_reg_get(priv, R_CTRL);
>>
>>   		if (DUPLEX_FULL =3D=3D phy_dev->duplex)
>>   			reg |=3D ENFL_MASK;
>>   		else
>>   			reg &=3D ~ENFL_MASK;
>>
>> -		arc_reg_set(priv, R_CTRL, reg);
>> +		emac_reg_set(priv, R_CTRL, reg);
>>   		priv->duplex =3D phy_dev->duplex;
>>   		state_changed =3D 1;
>>   	}
>> @@ -70,7 +71,7 @@ static void arc_emac_adjust_link(struct net_device=
 *ndev)
>>   }
>>
>>   /**
>> - * arc_emac_get_settings - Get PHY settings.
>> + * emac_get_settings - Get PHY settings.
>>    * @ndev:	Pointer to net_device structure.
>>    * @cmd:	Pointer to ethtool_cmd structure.
>>    *
>> @@ -79,16 +80,16 @@ static void arc_emac_adjust_link(struct net_devi=
ce
>> *ndev) * relevant PHY ethtool API to get the PHY settings.
>>    * Issue "ethtool ethX" under linux prompt to execute this functio=
n.
>>    */
>> -static int arc_emac_get_settings(struct net_device *ndev,
>> +static int emac_get_settings(struct net_device *ndev,
>>   				 struct ethtool_cmd *cmd)
>>   {
>> -	struct arc_emac_priv *priv =3D netdev_priv(ndev);
>> +	struct emac_priv *priv =3D netdev_priv(ndev);
>>
>>   	return phy_ethtool_gset(priv->phy_dev, cmd);
>>   }
>>
>>   /**
>> - * arc_emac_set_settings - Set PHY settings as passed in the argume=
nt.
>> + * emac_set_settings - Set PHY settings as passed in the argument.
>>    * @ndev:	Pointer to net_device structure.
>>    * @cmd:	Pointer to ethtool_cmd structure.
>>    *
>> @@ -98,10 +99,10 @@ static int arc_emac_get_settings(struct net_devi=
ce
>> *ndev, * Issue e.g. "ethtool -s ethX speed 1000" under linux prompt =
to
>> execute this * function.
>>    */
>> -static int arc_emac_set_settings(struct net_device *ndev,
>> -				 struct ethtool_cmd *cmd)
>> +static int emac_set_settings(struct net_device *ndev,
>> +			     struct ethtool_cmd *cmd)
>>   {
>> -	struct arc_emac_priv *priv =3D netdev_priv(ndev);
>> +	struct emac_priv *priv =3D netdev_priv(ndev);
>>
>>   	if (!capable(CAP_NET_ADMIN))
>>   		return -EPERM;
>> @@ -110,42 +111,44 @@ static int arc_emac_set_settings(struct net_de=
vice
>> *ndev, }
>>
>>   /**
>> - * arc_emac_get_drvinfo - Get EMAC driver information.
>> + * emac_get_drvinfo - Get EMAC driver information.
>>    * @ndev:	Pointer to net_device structure.
>>    * @info:	Pointer to ethtool_drvinfo structure.
>>    *
>>    * This implements ethtool command for getting the driver informat=
ion.
>>    * Issue "ethtool -i ethX" under linux prompt to execute this func=
tion.
>>    */
>> -static void arc_emac_get_drvinfo(struct net_device *ndev,
>> +static void emac_get_drvinfo(struct net_device *ndev,
>>   				 struct ethtool_drvinfo *info)
>>   {
>> -	strlcpy(info->driver, DRV_NAME, sizeof(info->driver));
>> -	strlcpy(info->version, DRV_VERSION, sizeof(info->version));
>> +	struct emac_priv *priv =3D netdev_priv(ndev);
>> +
>> +	strlcpy(info->driver, priv->plat_data->name, sizeof(info->driver))=
;
>> +	strlcpy(info->version, priv->plat_data->version, sizeof(info->vers=
ion));
>>   }
>>
>> -static const struct ethtool_ops arc_emac_ethtool_ops =3D {
>> -	.get_settings	=3D arc_emac_get_settings,
>> -	.set_settings	=3D arc_emac_set_settings,
>> -	.get_drvinfo	=3D arc_emac_get_drvinfo,
>> +static const struct ethtool_ops emac_ethtool_ops =3D {
>> +	.get_settings	=3D emac_get_settings,
>> +	.set_settings	=3D emac_set_settings,
>> +	.get_drvinfo	=3D emac_get_drvinfo,
>>   	.get_link	=3D ethtool_op_get_link,
>>   };
>>
>>   #define FIRST_OR_LAST_MASK	(FIRST_MASK | LAST_MASK)
>>
>>   /**
>> - * arc_emac_tx_clean - clears processed by EMAC Tx BDs.
>> + * emac_tx_clean - clears processed by EMAC Tx BDs.
>>    * @ndev:	Pointer to the network device.
>>    */
>> -static void arc_emac_tx_clean(struct net_device *ndev)
>> +static void emac_tx_clean(struct net_device *ndev)
>>   {
>> -	struct arc_emac_priv *priv =3D netdev_priv(ndev);
>> +	struct emac_priv *priv =3D netdev_priv(ndev);
>>   	struct net_device_stats *stats =3D &priv->stats;
>>   	unsigned int i;
>>
>>   	for (i =3D 0; i < TX_BD_NUM; i++) {
>>   		unsigned int *txbd_dirty =3D &priv->txbd_dirty;
>> -		struct arc_emac_bd *txbd =3D &priv->txbd[*txbd_dirty];
>> +		struct emac_bd *txbd =3D &priv->txbd[*txbd_dirty];
>>   		struct buffer_state *tx_buff =3D &priv->tx_buff[*txbd_dirty];
>>   		struct sk_buff *skb =3D tx_buff->skb;
>>   		unsigned int info =3D le32_to_cpu(txbd->info);
>> @@ -187,7 +190,7 @@ static void arc_emac_tx_clean(struct net_device =
*ndev)
>>   }
>>
>>   /**
>> - * arc_emac_rx - processing of Rx packets.
>> + * emac_rx - processing of Rx packets.
>>    * @ndev:	Pointer to the network device.
>>    * @budget:	How many BDs to process on 1 call.
>>    *
>> @@ -195,16 +198,16 @@ static void arc_emac_tx_clean(struct net_devic=
e *ndev)
>> *
>>    * Iterate through Rx BDs and deliver received packages to upper l=
ayer.
>>    */
>> -static int arc_emac_rx(struct net_device *ndev, int budget)
>> +static int emac_rx(struct net_device *ndev, int budget)
>>   {
>> -	struct arc_emac_priv *priv =3D netdev_priv(ndev);
>> +	struct emac_priv *priv =3D netdev_priv(ndev);
>>   	unsigned int work_done;
>>
>>   	for (work_done =3D 0; work_done < budget; work_done++) {
>>   		unsigned int *last_rx_bd =3D &priv->last_rx_bd;
>>   		struct net_device_stats *stats =3D &priv->stats;
>>   		struct buffer_state *rx_buff =3D &priv->rx_buff[*last_rx_bd];
>> -		struct arc_emac_bd *rxbd =3D &priv->rxbd[*last_rx_bd];
>> +		struct emac_bd *rxbd =3D &priv->rxbd[*last_rx_bd];
>>   		unsigned int pktlen, info =3D le32_to_cpu(rxbd->info);
>>   		struct sk_buff *skb;
>>   		dma_addr_t addr;
>> @@ -281,55 +284,55 @@ static int arc_emac_rx(struct net_device *ndev=
, int
>> budget) }
>>
>>   /**
>> - * arc_emac_poll - NAPI poll handler.
>> + * emac_poll - NAPI poll handler.
>>    * @napi:	Pointer to napi_struct structure.
>>    * @budget:	How many BDs to process on 1 call.
>>    *
>>    * returns:	Number of processed BDs
>>    */
>> -static int arc_emac_poll(struct napi_struct *napi, int budget)
>> +static int emac_poll(struct napi_struct *napi, int budget)
>>   {
>>   	struct net_device *ndev =3D napi->dev;
>> -	struct arc_emac_priv *priv =3D netdev_priv(ndev);
>> +	struct emac_priv *priv =3D netdev_priv(ndev);
>>   	unsigned int work_done;
>>
>> -	arc_emac_tx_clean(ndev);
>> +	emac_tx_clean(ndev);
>>
>> -	work_done =3D arc_emac_rx(ndev, budget);
>> +	work_done =3D emac_rx(ndev, budget);
>>   	if (work_done < budget) {
>>   		napi_complete(napi);
>> -		arc_reg_or(priv, R_ENABLE, RXINT_MASK);
>> +		emac_reg_or(priv, R_ENABLE, RXINT_MASK);
>>   	}
>>
>>   	return work_done;
>>   }
>>
>>   /**
>> - * arc_emac_intr - Global interrupt handler for EMAC.
>> + * emac_intr - Global interrupt handler for EMAC.
>>    * @irq:		irq number.
>>    * @dev_instance:	device instance.
>>    *
>>    * returns: IRQ_HANDLED for all cases.
>>    *
>> - * ARC EMAC has only 1 interrupt line, and depending on bits raised=
 in
>> + * EMAC has only 1 interrupt line, and depending on bits raised in
>>    * STATUS register we may tell what is a reason for interrupt to f=
ire.
>>    */
>> -static irqreturn_t arc_emac_intr(int irq, void *dev_instance)
>> +static irqreturn_t emac_intr(int irq, void *dev_instance)
>>   {
>>   	struct net_device *ndev =3D dev_instance;
>> -	struct arc_emac_priv *priv =3D netdev_priv(ndev);
>> +	struct emac_priv *priv =3D netdev_priv(ndev);
>>   	struct net_device_stats *stats =3D &priv->stats;
>>   	unsigned int status;
>>
>> -	status =3D arc_reg_get(priv, R_STATUS);
>> +	status =3D emac_reg_get(priv, R_STATUS);
>>   	status &=3D ~MDIO_MASK;
>>
>>   	/* Reset all flags except "MDIO complete" */
>> -	arc_reg_set(priv, R_STATUS, status);
>> +	emac_reg_set(priv, R_STATUS, status);
>>
>>   	if (status & RXINT_MASK) {
>>   		if (likely(napi_schedule_prep(&priv->napi))) {
>> -			arc_reg_clr(priv, R_ENABLE, RXINT_MASK);
>> +			emac_reg_clr(priv, R_ENABLE, RXINT_MASK);
>>   			__napi_schedule(&priv->napi);
>>   		}
>>   	}
>> @@ -364,16 +367,16 @@ static irqreturn_t arc_emac_intr(int irq, void
>> *dev_instance) }
>>
>>   #ifdef CONFIG_NET_POLL_CONTROLLER
>> -static void arc_emac_poll_controller(struct net_device *dev)
>> +static void emac_poll_controller(struct net_device *dev)
>>   {
>>   	disable_irq(dev->irq);
>> -	arc_emac_intr(dev->irq, dev);
>> +	emac_intr(dev->irq, dev);
>>   	enable_irq(dev->irq);
>>   }
>>   #endif
>>
>>   /**
>> - * arc_emac_open - Open the network device.
>> + * emac_open - Open the network device.
>>    * @ndev:	Pointer to the network device.
>>    *
>>    * returns: 0, on success or non-zero error value on failure.
>> @@ -382,9 +385,9 @@ static void arc_emac_poll_controller(struct net_=
device
>> *dev) * for the EMAC device and starts the Tx queue.
>>    * It also connects to the phy device.
>>    */
>> -static int arc_emac_open(struct net_device *ndev)
>> +static int emac_open(struct net_device *ndev)
>>   {
>> -	struct arc_emac_priv *priv =3D netdev_priv(ndev);
>> +	struct emac_priv *priv =3D netdev_priv(ndev);
>>   	struct phy_device *phy_dev =3D priv->phy_dev;
>>   	int i;
>>
>> @@ -399,7 +402,7 @@ static int arc_emac_open(struct net_device *ndev=
)
>>   	for (i =3D 0; i < RX_BD_NUM; i++) {
>>   		dma_addr_t addr;
>>   		unsigned int *last_rx_bd =3D &priv->last_rx_bd;
>> -		struct arc_emac_bd *rxbd =3D &priv->rxbd[*last_rx_bd];
>> +		struct emac_bd *rxbd =3D &priv->rxbd[*last_rx_bd];
>>   		struct buffer_state *rx_buff =3D &priv->rx_buff[*last_rx_bd];
>>
>>   		rx_buff->skb =3D netdev_alloc_skb_ip_align(ndev,
>> @@ -432,18 +435,18 @@ static int arc_emac_open(struct net_device *nd=
ev)
>>   	memset(priv->txbd, 0, TX_RING_SZ);
>>
>>   	/* Initialize logical address filter */
>> -	arc_reg_set(priv, R_LAFL, 0);
>> -	arc_reg_set(priv, R_LAFH, 0);
>> +	emac_reg_set(priv, R_LAFL, 0);
>> +	emac_reg_set(priv, R_LAFH, 0);
>>
>>   	/* Set BD ring pointers for device side */
>> -	arc_reg_set(priv, R_RX_RING, (unsigned int)priv->rxbd_dma);
>> -	arc_reg_set(priv, R_TX_RING, (unsigned int)priv->txbd_dma);
>> +	emac_reg_set(priv, R_RX_RING, (unsigned int)priv->rxbd_dma);
>> +	emac_reg_set(priv, R_TX_RING, (unsigned int)priv->txbd_dma);
>>
>>   	/* Enable interrupts */
>> -	arc_reg_set(priv, R_ENABLE, RXINT_MASK | ERR_MASK);
>> +	emac_reg_set(priv, R_ENABLE, RXINT_MASK | ERR_MASK);
>>
>>   	/* Set CONTROL */
>> -	arc_reg_set(priv, R_CTRL,
>> +	emac_reg_set(priv, R_CTRL,
>>   		     (RX_BD_NUM << 24) |	/* RX BD table length */
>>   		     (TX_BD_NUM << 16) |	/* TX BD table length */
>>   		     TXRN_MASK | RXRN_MASK);
>> @@ -451,7 +454,7 @@ static int arc_emac_open(struct net_device *ndev=
)
>>   	napi_enable(&priv->napi);
>>
>>   	/* Enable EMAC */
>> -	arc_reg_or(priv, R_CTRL, EN_MASK);
>> +	emac_reg_or(priv, R_CTRL, EN_MASK);
>>
>>   	phy_start_aneg(priv->phy_dev);
>>
>> @@ -461,24 +464,24 @@ static int arc_emac_open(struct net_device *nd=
ev)
>>   }
>>
>>   /**
>> - * arc_emac_set_rx_mode - Change the receive filtering mode.
>> + * emac_set_rx_mode - Change the receive filtering mode.
>>    * @ndev:	Pointer to the network device.
>>    *
>>    * This function enables/disables promiscuous or all-multicast mod=
e
>>    * and updates the multicast filtering list of the network device.
>>    */
>> -static void arc_emac_set_rx_mode(struct net_device *ndev)
>> +static void emac_set_rx_mode(struct net_device *ndev)
>>   {
>> -	struct arc_emac_priv *priv =3D netdev_priv(ndev);
>> +	struct emac_priv *priv =3D netdev_priv(ndev);
>>
>>   	if (ndev->flags & IFF_PROMISC) {
>> -		arc_reg_or(priv, R_CTRL, PROM_MASK);
>> +		emac_reg_or(priv, R_CTRL, PROM_MASK);
>>   	} else {
>> -		arc_reg_clr(priv, R_CTRL, PROM_MASK);
>> +		emac_reg_clr(priv, R_CTRL, PROM_MASK);
>>
>>   		if (ndev->flags & IFF_ALLMULTI) {
>> -			arc_reg_set(priv, R_LAFL, ~0);
>> -			arc_reg_set(priv, R_LAFH, ~0);
>> +			emac_reg_set(priv, R_LAFL, ~0);
>> +			emac_reg_set(priv, R_LAFH, ~0);
>>   		} else {
>>   			struct netdev_hw_addr *ha;
>>   			unsigned int filter[2] =3D { 0, 0 };
>> @@ -489,52 +492,52 @@ static void arc_emac_set_rx_mode(struct net_de=
vice
>> *ndev) filter[bit >> 5] |=3D 1 << (bit & 31);
>>   			}
>>
>> -			arc_reg_set(priv, R_LAFL, filter[0]);
>> -			arc_reg_set(priv, R_LAFH, filter[1]);
>> +			emac_reg_set(priv, R_LAFL, filter[0]);
>> +			emac_reg_set(priv, R_LAFH, filter[1]);
>>   		}
>>   	}
>>   }
>>
>>   /**
>> - * arc_emac_stop - Close the network device.
>> + * emac_stop - Close the network device.
>>    * @ndev:	Pointer to the network device.
>>    *
>>    * This function stops the Tx queue, disables interrupts and frees=
 the IRQ
>> for * the EMAC device.
>>    * It also disconnects the PHY device associated with the EMAC dev=
ice.
>>    */
>> -static int arc_emac_stop(struct net_device *ndev)
>> +static int emac_stop(struct net_device *ndev)
>>   {
>> -	struct arc_emac_priv *priv =3D netdev_priv(ndev);
>> +	struct emac_priv *priv =3D netdev_priv(ndev);
>>
>>   	napi_disable(&priv->napi);
>>   	netif_stop_queue(ndev);
>>
>>   	/* Disable interrupts */
>> -	arc_reg_clr(priv, R_ENABLE, RXINT_MASK | ERR_MASK);
>> +	emac_reg_clr(priv, R_ENABLE, RXINT_MASK | ERR_MASK);
>>
>>   	/* Disable EMAC */
>> -	arc_reg_clr(priv, R_CTRL, EN_MASK);
>> +	emac_reg_clr(priv, R_CTRL, EN_MASK);
>>
>>   	return 0;
>>   }
>>
>>   /**
>> - * arc_emac_stats - Get system network statistics.
>> + * emac_stats - Get system network statistics.
>>    * @ndev:	Pointer to net_device structure.
>>    *
>>    * Returns the address of the device statistics structure.
>>    * Statistics are updated in interrupt handler.
>>    */
>> -static struct net_device_stats *arc_emac_stats(struct net_device *n=
dev)
>> +static struct net_device_stats *emac_stats(struct net_device *ndev)
>>   {
>> -	struct arc_emac_priv *priv =3D netdev_priv(ndev);
>> +	struct emac_priv *priv =3D netdev_priv(ndev);
>>   	struct net_device_stats *stats =3D &priv->stats;
>>   	unsigned long miss, rxerr;
>>   	u8 rxcrc, rxfram, rxoflow;
>>
>> -	rxerr =3D arc_reg_get(priv, R_RXERR);
>> -	miss =3D arc_reg_get(priv, R_MISS);
>> +	rxerr =3D emac_reg_get(priv, R_RXERR);
>> +	miss =3D emac_reg_get(priv, R_MISS);
>>
>>   	rxcrc =3D rxerr;
>>   	rxfram =3D rxerr >> 8;
>> @@ -552,7 +555,7 @@ static struct net_device_stats *arc_emac_stats(s=
truct
>> net_device *ndev) }
>>
>>   /**
>> - * arc_emac_tx - Starts the data transmission.
>> + * emac_tx - Starts the data transmission.
>>    * @skb:	sk_buff pointer that contains data to be Transmitted.
>>    * @ndev:	Pointer to net_device structure.
>>    *
>> @@ -561,9 +564,9 @@ static struct net_device_stats *arc_emac_stats(s=
truct
>> net_device *ndev) *
>>    * This function is invoked from upper layers to initiate transmis=
sion.
>>    */
>> -static int arc_emac_tx(struct sk_buff *skb, struct net_device *ndev=
)
>> +static int emac_tx(struct sk_buff *skb, struct net_device *ndev)
>>   {
>> -	struct arc_emac_priv *priv =3D netdev_priv(ndev);
>> +	struct emac_priv *priv =3D netdev_priv(ndev);
>>   	unsigned int len, *txbd_curr =3D &priv->txbd_curr;
>>   	struct net_device_stats *stats =3D &priv->stats;
>>   	__le32 *info =3D &priv->txbd[*txbd_curr].info;
>> @@ -614,25 +617,25 @@ static int arc_emac_tx(struct sk_buff *skb, st=
ruct
>> net_device *ndev) if (unlikely((le32_to_cpu(*info) & OWN_MASK) =3D=3D
>> FOR_EMAC))
>>   		netif_stop_queue(ndev);
>>
>> -	arc_reg_set(priv, R_STATUS, TXPL_MASK);
>> +	emac_reg_set(priv, R_STATUS, TXPL_MASK);
>>
>>   	return NETDEV_TX_OK;
>>   }
>>
>> -static void arc_emac_set_address_internal(struct net_device *ndev)
>> +static void emac_set_address_internal(struct net_device *ndev)
>>   {
>> -	struct arc_emac_priv *priv =3D netdev_priv(ndev);
>> +	struct emac_priv *priv =3D netdev_priv(ndev);
>>   	unsigned int addr_low, addr_hi;
>>
>>   	addr_low =3D le32_to_cpu(*(__le32 *) &ndev->dev_addr[0]);
>>   	addr_hi =3D le16_to_cpu(*(__le16 *) &ndev->dev_addr[4]);
>>
>> -	arc_reg_set(priv, R_ADDRL, addr_low);
>> -	arc_reg_set(priv, R_ADDRH, addr_hi);
>> +	emac_reg_set(priv, R_ADDRL, addr_low);
>> +	emac_reg_set(priv, R_ADDRH, addr_hi);
>>   }
>>
>>   /**
>> - * arc_emac_set_address - Set the MAC address for this device.
>> + * emac_set_address - Set the MAC address for this device.
>>    * @ndev:	Pointer to net_device structure.
>>    * @p:		6 byte Address to be written as MAC address.
>>    *
>> @@ -642,7 +645,7 @@ static void arc_emac_set_address_internal(struct
>> net_device *ndev) * returns:	-EBUSY if the net device is busy or 0 i=
f the
>> address is set *		successfully.
>>    */
>> -static int arc_emac_set_address(struct net_device *ndev, void *p)
>> +static int emac_set_address(struct net_device *ndev, void *p)
>>   {
>>   	struct sockaddr *addr =3D p;
>>
>> @@ -654,141 +657,129 @@ static int arc_emac_set_address(struct net_d=
evice
>> *ndev, void *p)
>>
>>   	memcpy(ndev->dev_addr, addr->sa_data, ndev->addr_len);
>>
>> -	arc_emac_set_address_internal(ndev);
>> +	emac_set_address_internal(ndev);
>>
>>   	return 0;
>>   }
>>
>> -static const struct net_device_ops arc_emac_netdev_ops =3D {
>> -	.ndo_open		=3D arc_emac_open,
>> -	.ndo_stop		=3D arc_emac_stop,
>> -	.ndo_start_xmit		=3D arc_emac_tx,
>> -	.ndo_set_mac_address	=3D arc_emac_set_address,
>> -	.ndo_get_stats		=3D arc_emac_stats,
>> -	.ndo_set_rx_mode	=3D arc_emac_set_rx_mode,
>> +static const struct net_device_ops emac_netdev_ops =3D {
>> +	.ndo_open		=3D emac_open,
>> +	.ndo_stop		=3D emac_stop,
>> +	.ndo_start_xmit		=3D emac_tx,
>> +	.ndo_set_mac_address	=3D emac_set_address,
>> +	.ndo_get_stats		=3D emac_stats,
>> +	.ndo_set_rx_mode	=3D emac_set_rx_mode,
>>   #ifdef CONFIG_NET_POLL_CONTROLLER
>> -	.ndo_poll_controller	=3D arc_emac_poll_controller,
>> +	.ndo_poll_controller	=3D emac_poll_controller,
>>   #endif
>>   };
>>
>> -static int arc_emac_probe(struct platform_device *pdev)
>> +int emac_drv_probe(struct device *dev, const struct emac_platform_d=
ata
>> *plat_data) {
>>   	struct resource res_regs;
>>   	struct device_node *phy_node;
>> -	struct arc_emac_priv *priv;
>> +	struct emac_priv *priv;
>>   	struct net_device *ndev;
>>   	const char *mac_addr;
>>   	unsigned int id, clock_frequency, irq;
>>   	int err;
>>
>> -	if (!pdev->dev.of_node)
>> -		return -ENODEV;
>> -
>>   	/* Get PHY from device tree */
>> -	phy_node =3D of_parse_phandle(pdev->dev.of_node, "phy", 0);
>> +	phy_node =3D of_parse_phandle(dev->of_node, "phy", 0);
>>   	if (!phy_node) {
>> -		dev_err(&pdev->dev, "failed to retrieve phy description from devi=
ce
>> tree\n"); +		dev_err(dev, "failed to retrieve phy description from
> device
>> tree\n"); return -ENODEV;
>>   	}
>>
>>   	/* Get EMAC registers base address from device tree */
>> -	err =3D of_address_to_resource(pdev->dev.of_node, 0, &res_regs);
>> +	err =3D of_address_to_resource(dev->of_node, 0, &res_regs);
>>   	if (err) {
>> -		dev_err(&pdev->dev, "failed to retrieve registers base from devic=
e
>> tree\n"); +		dev_err(dev, "failed to retrieve registers base from
> device
>> tree\n"); return -ENODEV;
>>   	}
>>
>>   	/* Get IRQ from device tree */
>> -	irq =3D irq_of_parse_and_map(pdev->dev.of_node, 0);
>> +	irq =3D irq_of_parse_and_map(dev->of_node, 0);
>>   	if (!irq) {
>> -		dev_err(&pdev->dev, "failed to retrieve <irq> value from device
> tree\n");
>> +		dev_err(dev, "failed to retrieve <irq> value from device tree\n")=
;
>> return -ENODEV;
>>   	}
>>
>> -	ndev =3D alloc_etherdev(sizeof(struct arc_emac_priv));
>> +	ndev =3D alloc_etherdev(sizeof(struct emac_priv));
>>   	if (!ndev)
>>   		return -ENOMEM;
>>
>> -	platform_set_drvdata(pdev, ndev);
>> -	SET_NETDEV_DEV(ndev, &pdev->dev);
>> +	dev_set_drvdata(dev, ndev);
>> +	SET_NETDEV_DEV(ndev, dev);
>>
>> -	ndev->netdev_ops =3D &arc_emac_netdev_ops;
>> -	ndev->ethtool_ops =3D &arc_emac_ethtool_ops;
>> +	ndev->netdev_ops =3D &emac_netdev_ops;
>> +	ndev->ethtool_ops =3D &emac_ethtool_ops;
>>   	ndev->watchdog_timeo =3D TX_TIMEOUT;
>>   	/* FIXME :: no multicast support yet */
>>   	ndev->flags &=3D ~IFF_MULTICAST;
>>
>>   	priv =3D netdev_priv(ndev);
>> -	priv->dev =3D &pdev->dev;
>> +	priv->dev =3D dev;
>>   	priv->ndev =3D ndev;
>> +	priv->plat_data =3D plat_data;
>>
>> -	priv->regs =3D devm_ioremap_resource(&pdev->dev, &res_regs);
>> +	priv->regs =3D devm_ioremap_resource(dev, &res_regs);
>>   	if (IS_ERR(priv->regs)) {
>>   		err =3D PTR_ERR(priv->regs);
>>   		goto out_netdev;
>>   	}
>> -	dev_dbg(&pdev->dev, "Registers base address is 0x%p\n", priv->regs=
);
>> -
>> -	priv->clk =3D of_clk_get(pdev->dev.of_node, 0);
>> -	if (IS_ERR(priv->clk)) {
>> -		/* Get CPU clock frequency from device tree */
>> -		if (of_property_read_u32(pdev->dev.of_node, "clock-frequency",
>> -					&clock_frequency)) {
>> -			dev_err(&pdev->dev, "failed to retrieve <clock-frequency> from
> device
>> tree\n"); -			err =3D -EINVAL;
>> -			goto out_netdev;
>> -		}
>> -	} else {
>> -		err =3D clk_prepare_enable(priv->clk);
>> +	dev_dbg(dev, "Registers base address is 0x%p\n", priv->regs);
>> +
>> +	if (plat_data->clk) {
>> +		err =3D clk_prepare_enable(plat_data->clk);
>>   		if (err) {
>> -			dev_err(&pdev->dev, "failed to enable clock\n");
>> +			dev_err(dev, "failed to enable clock\n");
>>   			goto out_clkget;
>>   		}
>> -
>> -		clock_frequency =3D clk_get_rate(priv->clk);
>> +		clock_frequency =3D clk_get_rate(plat_data->clk);
>>   	}
>>
>> -	id =3D arc_reg_get(priv, R_ID);
>> +	id =3D emac_reg_get(priv, R_ID);
>>
>>   	/* Check for EMAC revision 5 or 7, magic number */
>>   	if (!(id =3D=3D 0x0005fd02 || id =3D=3D 0x0007fd02)) {
>> -		dev_err(&pdev->dev, "ARC EMAC not detected, id=3D0x%x\n", id);
>> +		dev_err(dev, "EMAC not detected, id=3D0x%x\n", id);
>>   		err =3D -ENODEV;
>>   		goto out_clken;
>>   	}
>> -	dev_info(&pdev->dev, "ARC EMAC detected with id: 0x%x\n", id);
>> +	dev_info(dev, "EMAC detected with id: 0x%x\n", id);
>>
>>   	/* Set poll rate so that it polls every 1 ms */
>> -	arc_reg_set(priv, R_POLLRATE, clock_frequency / 1000000);
>> +	emac_reg_set(priv, R_POLLRATE, clock_frequency / 1000000);
>>
>>   	ndev->irq =3D irq;
>> -	dev_info(&pdev->dev, "IRQ is %d\n", ndev->irq);
>> +	dev_dbg(dev, "IRQ is %d\n", ndev->irq);
>>
>>   	/* Register interrupt handler for device */
>> -	err =3D devm_request_irq(&pdev->dev, ndev->irq, arc_emac_intr, 0,
>> +	err =3D devm_request_irq(dev, ndev->irq, emac_intr, 0,
>>   			       ndev->name, ndev);
>>   	if (err) {
>> -		dev_err(&pdev->dev, "could not allocate IRQ\n");
>> +		dev_err(dev, "could not allocate IRQ\n");
>>   		goto out_clken;
>>   	}
>>
>>   	/* Get MAC address from device tree */
>> -	mac_addr =3D of_get_mac_address(pdev->dev.of_node);
>> +	mac_addr =3D of_get_mac_address(dev->of_node);
>>
>>   	if (mac_addr)
>>   		memcpy(ndev->dev_addr, mac_addr, ETH_ALEN);
>>   	else
>>   		eth_hw_addr_random(ndev);
>>
>> -	arc_emac_set_address_internal(ndev);
>> -	dev_info(&pdev->dev, "MAC address is now %pM\n", ndev->dev_addr);
>> +	emac_set_address_internal(ndev);
>> +	dev_info(dev, "MAC address is now %pM\n", ndev->dev_addr);
>>
>>   	/* Do 1 allocation instead of 2 separate ones for Rx and Tx BD ri=
ngs */
>> -	priv->rxbd =3D dmam_alloc_coherent(&pdev->dev, RX_RING_SZ + TX_RIN=
G_SZ,
>> +	priv->rxbd =3D dmam_alloc_coherent(dev, RX_RING_SZ + TX_RING_SZ,
>>   					 &priv->rxbd_dma, GFP_KERNEL);
>>
>>   	if (!priv->rxbd) {
>> -		dev_err(&pdev->dev, "failed to allocate data buffers\n");
>> +		dev_err(dev, "failed to allocate data buffers\n");
>>   		err =3D -ENOMEM;
>>   		goto out_clken;
>>   	}
>> @@ -796,31 +787,31 @@ static int arc_emac_probe(struct platform_devi=
ce
>> *pdev) priv->txbd =3D priv->rxbd + RX_BD_NUM;
>>
>>   	priv->txbd_dma =3D priv->rxbd_dma + RX_RING_SZ;
>> -	dev_dbg(&pdev->dev, "EMAC Device addr: Rx Ring [0x%x], Tx Ring[%x]=
\n",
>> +	dev_dbg(dev, "EMAC Device addr: Rx Ring [0x%x], Tx Ring[%x]\n",
>>   		(unsigned int)priv->rxbd_dma, (unsigned int)priv->txbd_dma);
>>
>> -	err =3D arc_mdio_probe(pdev, priv);
>> +	err =3D emac_mdio_probe(priv);
>>   	if (err) {
>> -		dev_err(&pdev->dev, "failed to probe MII bus\n");
>> +		dev_err(dev, "failed to probe MII bus\n");
>>   		goto out_clken;
>>   	}
>>
>> -	priv->phy_dev =3D of_phy_connect(ndev, phy_node, arc_emac_adjust_l=
ink, 0,
>> -				       PHY_INTERFACE_MODE_MII);
>> +	priv->phy_dev =3D of_phy_connect(ndev, phy_node, emac_adjust_link,=
 0,
>> +				       plat_data->interface);
>>   	if (!priv->phy_dev) {
>> -		dev_err(&pdev->dev, "of_phy_connect() failed\n");
>> +		dev_err(dev, "of_phy_connect() failed\n");
>>   		err =3D -ENODEV;
>>   		goto out_mdio;
>>   	}
>>
>> -	dev_info(&pdev->dev, "connected to %s phy with id 0x%x\n",
>> +	dev_info(dev, "connected to %s phy with id 0x%x\n",
>>   		 priv->phy_dev->drv->name, priv->phy_dev->phy_id);
>>
>> -	netif_napi_add(ndev, &priv->napi, arc_emac_poll, ARC_EMAC_NAPI_WEI=
GHT);
>> +	netif_napi_add(ndev, &priv->napi, emac_poll, EMAC_NAPI_WEIGHT);
>>
>>   	err =3D register_netdev(ndev);
>>   	if (err) {
>> -		dev_err(&pdev->dev, "failed to register network device\n");
>> +		dev_err(dev, "failed to register network device\n");
>>   		goto out_netif_api;
>>   	}
>>
>> @@ -831,32 +822,31 @@ out_netif_api:
>>   	phy_disconnect(priv->phy_dev);
>>   	priv->phy_dev =3D NULL;
>>   out_mdio:
>> -	arc_mdio_remove(priv);
>> +	emac_mdio_remove(priv);
>>   out_clken:
>> -	if (!IS_ERR(priv->clk))
>> -		clk_disable_unprepare(priv->clk);
>> +	if (!IS_ERR(plat_data->clk))
>> +		clk_disable_unprepare(plat_data->clk);
>>   out_clkget:
>> -	if (!IS_ERR(priv->clk))
>> -		clk_put(priv->clk);
>> +	if (!IS_ERR(plat_data->clk))
>> +		clk_put(plat_data->clk);
>>   out_netdev:
>>   	free_netdev(ndev);
>>   	return err;
>>   }
>>
>> -static int arc_emac_remove(struct platform_device *pdev)
>> +int emac_drv_remove(struct net_device *ndev)
>>   {
>> -	struct net_device *ndev =3D platform_get_drvdata(pdev);
>> -	struct arc_emac_priv *priv =3D netdev_priv(ndev);
>> +	struct emac_priv *priv =3D netdev_priv(ndev);
>>
>>   	phy_disconnect(priv->phy_dev);
>>   	priv->phy_dev =3D NULL;
>> -	arc_mdio_remove(priv);
>> +	emac_mdio_remove(priv);
>>   	unregister_netdev(ndev);
>>   	netif_napi_del(&priv->napi);
>>
>> -	if (!IS_ERR(priv->clk)) {
>> -		clk_disable_unprepare(priv->clk);
>> -		clk_put(priv->clk);
>> +	if (priv->plat_data->clk) {
>> +		clk_disable_unprepare(priv->plat_data->clk);
>> +		clk_put(priv->plat_data->clk);
>>   	}
>>
>>   	free_netdev(ndev);
>> @@ -864,24 +854,6 @@ static int arc_emac_remove(struct platform_devi=
ce
>> *pdev) return 0;
>>   }
>>
>> -static const struct of_device_id arc_emac_dt_ids[] =3D {
>> -	{ .compatible =3D "snps,arc-emac" },
>> -	{ /* Sentinel */ }
>> -};
>> -MODULE_DEVICE_TABLE(of, arc_emac_dt_ids);
>> -
>> -static struct platform_driver arc_emac_driver =3D {
>> -	.probe =3D arc_emac_probe,
>> -	.remove =3D arc_emac_remove,
>> -	.driver =3D {
>> -		.name =3D DRV_NAME,
>> -		.owner =3D THIS_MODULE,
>> -		.of_match_table  =3D arc_emac_dt_ids,
>> -		},
>> -};
>> -
>> -module_platform_driver(arc_emac_driver);
>> -
>>   MODULE_AUTHOR("Alexey Brodkin <abrodkin@synopsys.com>");
>> -MODULE_DESCRIPTION("ARC EMAC driver");
>> +MODULE_DESCRIPTION("EMAC driver");
>>   MODULE_LICENSE("GPL");
>> diff --git a/drivers/net/ethernet/arc/emac_mdio.c
>> b/drivers/net/ethernet/arc/emac_mdio.c index 26ba242..b1397ea 100644
>> --- a/drivers/net/ethernet/arc/emac_mdio.c
>> +++ b/drivers/net/ethernet/arc/emac_mdio.c
>> @@ -1,7 +1,7 @@
>>   /*
>>    * Copyright (C) 2004-2013 Synopsys, Inc. (www.synopsys.com)
>>    *
>> - * MDIO implementation for ARC EMAC
>> + * MDIO implementation for EMAC
>>    */
>>
>>   #include <linux/delay.h>
>> @@ -11,26 +11,26 @@
>>   #include "emac.h"
>>
>>   /* Number of seconds we wait for "MDIO complete" flag to appear */
>> -#define ARC_MDIO_COMPLETE_POLL_COUNT	1
>> +#define EMAC_MDIO_COMPLETE_POLL_COUNT	1
>>
>>   /**
>> - * arc_mdio_complete_wait - Waits until MDIO transaction is complet=
ed.
>> - * @priv:	Pointer to ARC EMAC private data structure.
>> + * emac_mdio_complete_wait - Waits until MDIO transaction is comple=
ted.
>> + * @priv:	Pointer to EMAC private data structure.
>>    *
>>    * returns:	0 on success, -ETIMEDOUT on a timeout.
>>    */
>> -static int arc_mdio_complete_wait(struct arc_emac_priv *priv)
>> +static int emac_mdio_complete_wait(struct emac_priv *priv)
>>   {
>>   	unsigned int i;
>>
>> -	for (i =3D 0; i < ARC_MDIO_COMPLETE_POLL_COUNT * 40; i++) {
>> -		unsigned int status =3D arc_reg_get(priv, R_STATUS);
>> +	for (i =3D 0; i < EMAC_MDIO_COMPLETE_POLL_COUNT * 40; i++) {
>> +		unsigned int status =3D emac_reg_get(priv, R_STATUS);
>>
>>   		status &=3D MDIO_MASK;
>>
>>   		if (status) {
>>   			/* Reset "MDIO complete" flag */
>> -			arc_reg_set(priv, R_STATUS, status);
>> +			emac_reg_set(priv, R_STATUS, status);
>>   			return 0;
>>   		}
>>
>> @@ -41,7 +41,7 @@ static int arc_mdio_complete_wait(struct arc_emac_=
priv
>> *priv) }
>>
>>   /**
>> - * arc_mdio_read - MDIO interface read function.
>> + * emac_mdio_read - MDIO interface read function.
>>    * @bus:	Pointer to MII bus structure.
>>    * @phy_addr:	Address of the PHY device.
>>    * @reg_num:	PHY register to read.
>> @@ -51,29 +51,29 @@ static int arc_mdio_complete_wait(struct arc_ema=
c_priv
>> *priv) * Reads the contents of the requested register from the reque=
sted
>> PHY * address.
>>    */
>> -static int arc_mdio_read(struct mii_bus *bus, int phy_addr, int reg=
_num)
>> +static int emac_mdio_read(struct mii_bus *bus, int phy_addr, int re=
g_num)
>>   {
>> -	struct arc_emac_priv *priv =3D bus->priv;
>> +	struct emac_priv *priv =3D bus->priv;
>>   	unsigned int value;
>>   	int error;
>>
>> -	arc_reg_set(priv, R_MDIO,
>> +	emac_reg_set(priv, R_MDIO,
>>   		    0x60020000 | (phy_addr << 23) | (reg_num << 18));
>>
>> -	error =3D arc_mdio_complete_wait(priv);
>> +	error =3D emac_mdio_complete_wait(priv);
>>   	if (error < 0)
>>   		return error;
>>
>> -	value =3D arc_reg_get(priv, R_MDIO) & 0xffff;
>> +	value =3D emac_reg_get(priv, R_MDIO) & 0xffff;
>>
>> -	dev_dbg(priv->dev, "arc_mdio_read(phy_addr=3D%i, reg_num=3D%x) =3D=
 %x\n",
>> +	dev_dbg(priv->dev, "emac_mdio_read(phy_addr=3D%i, reg_num=3D%x) =3D=
 %x\n",
>>   		phy_addr, reg_num, value);
>>
>>   	return value;
>>   }
>>
>>   /**
>> - * arc_mdio_write - MDIO interface write function.
>> + * emac_mdio_write - MDIO interface write function.
>>    * @bus:	Pointer to MII bus structure.
>>    * @phy_addr:	Address of the PHY device.
>>    * @reg_num:	PHY register to write to.
>> @@ -83,32 +83,32 @@ static int arc_mdio_read(struct mii_bus *bus, in=
t
>> phy_addr, int reg_num) *
>>    * Writes the value to the requested register.
>>    */
>> -static int arc_mdio_write(struct mii_bus *bus, int phy_addr,
>> +static int emac_mdio_write(struct mii_bus *bus, int phy_addr,
>>   			  int reg_num, u16 value)
>>   {
>> -	struct arc_emac_priv *priv =3D bus->priv;
>> +	struct emac_priv *priv =3D bus->priv;
>>
>>   	dev_dbg(priv->dev,
>> -		"arc_mdio_write(phy_addr=3D%i, reg_num=3D%x, value=3D%x)\n",
>> +		"emac_mdio_write(phy_addr=3D%i, reg_num=3D%x, value=3D%x)\n",
>>   		phy_addr, reg_num, value);
>>
>> -	arc_reg_set(priv, R_MDIO,
>> +	emac_reg_set(priv, R_MDIO,
>>   		     0x50020000 | (phy_addr << 23) | (reg_num << 18) | value);
>>
>> -	return arc_mdio_complete_wait(priv);
>> +	return emac_mdio_complete_wait(priv);
>>   }
>>
>>   /**
>> - * arc_mdio_probe - MDIO probe function.
>> + * emac_mdio_probe - MDIO probe function.
>>    * @pdev:	Pointer to platform device.
>> - * @priv:	Pointer to ARC EMAC private data structure.
>> + * @priv:	Pointer to EMAC private data structure.
>>    *
>>    * returns:	0 on success, -ENOMEM when mdiobus_alloc
>>    * (to allocate memory for MII bus structure) fails.
>>    *
>>    * Sets up and registers the MDIO interface.
>>    */
>> -int arc_mdio_probe(struct platform_device *pdev, struct arc_emac_pr=
iv
>> *priv) +int emac_mdio_probe(struct emac_priv *priv)
>>   {
>>   	struct mii_bus *bus;
>>   	int error;
>> @@ -121,12 +121,12 @@ int arc_mdio_probe(struct platform_device *pde=
v,
>> struct arc_emac_priv *priv) bus->priv =3D priv;
>>   	bus->parent =3D priv->dev;
>>   	bus->name =3D "Synopsys MII Bus",
>> -	bus->read =3D &arc_mdio_read;
>> -	bus->write =3D &arc_mdio_write;
>> +	bus->read =3D &emac_mdio_read;
>> +	bus->write =3D &emac_mdio_write;
>>
>> -	snprintf(bus->id, MII_BUS_ID_SIZE, "%s", pdev->name);
>> +	snprintf(bus->id, MII_BUS_ID_SIZE, "%s", bus->name);
>>
>> -	error =3D of_mdiobus_register(bus, pdev->dev.of_node);
>> +	error =3D of_mdiobus_register(bus, priv->dev->of_node);
>>   	if (error) {
>>   		dev_err(priv->dev, "cannot register MDIO bus %s\n", bus->name);
>>   		mdiobus_free(bus);
>> @@ -137,12 +137,12 @@ int arc_mdio_probe(struct platform_device *pde=
v,
>> struct arc_emac_priv *priv) }
>>
>>   /**
>> - * arc_mdio_remove - MDIO remove function.
>> - * @priv:	Pointer to ARC EMAC private data structure.
>> + * emac_mdio_remove - MDIO remove function.
>> + * @priv:	Pointer to EMAC private data structure.
>>    *
>>    * Unregisters the MDIO and frees any associate memory for MII bus=
=2E
>>    */
>> -int arc_mdio_remove(struct arc_emac_priv *priv)
>> +int emac_mdio_remove(struct emac_priv *priv)
>>   {
>>   	mdiobus_unregister(priv->bus);
>>   	mdiobus_free(priv->bus);
