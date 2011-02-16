From: Nobuhiro Iwamatsu <nobuhiro.iwamatsu.yj@renesas.com>
Subject: Re: [PATCH v2] sh: sh_eth: Add support ethtool
Date: Wed, 16 Feb 2011 16:04:44 +0900
Message-ID: <AANLkTi=2Bo2+_+8Y4GYyiTwvnd1G-EzyOA1VABuuUhm_@mail.gmail.com>
References: <1294747109-11511-1-git-send-email-nobuhiro.iwamatsu.yj@renesas.com>
 <1294761426.3637.8.camel@bwh-desktop>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: netdev@vger.kernel.org, linux-sh@vger.kernel.org,
	yoshihiro.shimoda.uh@renesas.com
To: Ben Hutchings <bhutchings@solarflare.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-px0-f174.google.com ([209.85.212.174]:56515 "EHLO
	mail-px0-f174.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751430Ab1BPHFL convert rfc822-to-8bit (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 16 Feb 2011 02:05:11 -0500
In-Reply-To: <1294761426.3637.8.camel@bwh-desktop>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

2011/1/12 Ben Hutchings <bhutchings@solarflare.com>:
> On Tue, 2011-01-11 at 20:58 +0900, nobuhiro.iwamatsu.yj@renesas.com
> wrote:
>> From: Nobuhiro Iwamatsu <nobuhiro.iwamatsu.yj@renesas.com>
>>
>> This commit supports following functions.
>> =A0- get_drvinfo
>> =A0- get_settings
>> =A0- set_settings
>> =A0- nway_reset
>> =A0- get_msglevel
>> =A0- set_msglevel
>> =A0- get_link
>> =A0- get_strings
>> =A0- get_ethtool_stats
>> =A0- get_sset_count
>>
>> About other function, the device does not support.
>>
>> Signed-off-by: Yoshihiro Shimoda <yoshihiro.shimoda.uh@renesas.com>
>> Signed-off-by: Nobuhiro Iwamatsu <nobuhiro.iwamatsu.yj@renesas.com>
>> ---
>> =A0v2: reverted one part of the checks of checkpatch.pl.
>> =A0 =A0 =A0 =A0foo *bar -> foo * bar.
>> =A0 =A0 =A0 =A0changed function copying of net_device_stats from *fo=
r* to memcopy.
>>
>> =A0drivers/net/sh_eth.c | =A0186 +++++++++++++++++++++++++++++++++++=
+++++++++++---
>> =A01 files changed, 174 insertions(+), 12 deletions(-)
>>
>> diff --git a/drivers/net/sh_eth.c b/drivers/net/sh_eth.c
>> index 819c175..0b2cb7d 100644
>> --- a/drivers/net/sh_eth.c
>> +++ b/drivers/net/sh_eth.c
> [...]
>> @@ -1063,6 +1074,154 @@ static int sh_eth_phy_start(struct net_devic=
e *ndev)
>> =A0 =A0 =A0 return 0;
>> =A0}
>>
>> +static void sh_eth_get_drvinfo(struct net_device *ndev,
>> + =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 struct ethtool_drvinfo *in=
fo)
>> +{
>> + =A0 =A0 strncpy(info->driver, "sh_eth", sizeof(info->driver) - 1);
>> + =A0 =A0 strcpy(info->version, "N/A");
>> + =A0 =A0 strcpy(info->fw_version, "N/A");
>> + =A0 =A0 strlcpy(info->bus_info, dev_name(ndev->dev.parent),
>> + =A0 =A0 =A0 =A0 =A0 =A0 sizeof(info->bus_info));
>> +}
>
> This is redundant; the default implementation already does this.

I see. I removed this.

>
> [...]
>> +static int sh_eth_set_settings(struct net_device *ndev,
>> + =A0 =A0 =A0 =A0 =A0 =A0 struct ethtool_cmd *ecmd)
>> +{
>> + =A0 =A0 struct sh_eth_private *mdp =3D netdev_priv(ndev);
>> + =A0 =A0 unsigned long flags;
>> + =A0 =A0 int ret;
>> + =A0 =A0 u32 ioaddr =3D ndev->base_addr;
>> +
>> + =A0 =A0 spin_lock_irqsave(&mdp->lock, flags);
>> +
>> + =A0 =A0 /* disable tx and rx */
>> + =A0 =A0 sh_eth_linkdown(ioaddr);
>> +
>> + =A0 =A0 ret =3D phy_ethtool_sset(mdp->phydev, ecmd);
>> + =A0 =A0 if (ret)
>> + =A0 =A0 =A0 =A0 =A0 =A0 goto error_exit;
>> +
>> + =A0 =A0 if (ecmd->duplex =3D=3D DUPLEX_FULL)
>> + =A0 =A0 =A0 =A0 =A0 =A0 mdp->duplex =3D 1;
>> + =A0 =A0 else
>> + =A0 =A0 =A0 =A0 =A0 =A0 mdp->duplex =3D 0;
>> +
>> + =A0 =A0 if (mdp->cd->set_duplex)
>> + =A0 =A0 =A0 =A0 =A0 =A0 mdp->cd->set_duplex(ndev);
>> +
>> +error_exit:
>> + =A0 =A0 mdelay(100);
>
> Ugh, 100 ms holding a spinlock?!

Oh, This was not need 100ms.
I changed to 1 ms.

>
>> + =A0 =A0 /* enable tx and rx */
>> + =A0 =A0 sh_eth_linkup(ioaddr);
>
> How do you know the link is up? =A0Shouldn't this be left to the link
> polling function?
>

Hmm. this has bad function name.

This function does not linkup. This enable recv / send function of the
hardware.
I changed a function name from sh_eth_linkup to sh_eth_rcv_send_enable.

> [...]
>> +static u32 sh_eth_get_msglevel(struct net_device *ndev)
>> +{
>> + =A0 =A0 struct sh_eth_private *mdp =3D netdev_priv(ndev);
>> + =A0 =A0 return mdp->msg_enable;
>> +}
>> +
>> +static void sh_eth_set_msglevel(struct net_device *ndev, u32 value)
>> +{
>> + =A0 =A0 struct sh_eth_private *mdp =3D netdev_priv(ndev);
>> + =A0 =A0 mdp->msg_enable =3D value;
>> +}
>
> This would be more useful if msg_enable was actually used anywhere in
> the driver.

I forgot this.
I am going to include msglevel stuff.

>
> [...]
>> @@ -1073,8 +1232,8 @@ static int sh_eth_open(struct net_device *ndev=
)
>>
>> =A0 =A0 =A0 ret =3D request_irq(ndev->irq, sh_eth_interrupt,
>> =A0#if defined(CONFIG_CPU_SUBTYPE_SH7763) || \
>> - =A0 =A0defined(CONFIG_CPU_SUBTYPE_SH7764) || \
>> - =A0 =A0defined(CONFIG_CPU_SUBTYPE_SH7757)
>> + =A0 =A0 defined(CONFIG_CPU_SUBTYPE_SH7764) || \
>> + =A0 =A0 defined(CONFIG_CPU_SUBTYPE_SH7757)
>> =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 IRQF_SHA=
RED,
>> =A0#else
>> =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 0,
>> @@ -1232,11 +1391,11 @@ static int sh_eth_close(struct net_device *n=
dev)
>> =A0 =A0 =A0 sh_eth_ring_free(ndev);
>>
>> =A0 =A0 =A0 /* free DMA buffer */
>> - =A0 =A0 ringsize =3D sizeof(struct sh_eth_rxdesc) * RX_RING_SIZE;
>> + =A0 =A0 ringsize =3D sizeof(struct sh_eth_rxdesc) *RX_RING_SIZE;
>> =A0 =A0 =A0 dma_free_coherent(NULL, ringsize, mdp->rx_ring, mdp->rx_=
desc_dma);
>>
>> =A0 =A0 =A0 /* free DMA buffer */
>> - =A0 =A0 ringsize =3D sizeof(struct sh_eth_txdesc) * TX_RING_SIZE;
>> + =A0 =A0 ringsize =3D sizeof(struct sh_eth_txdesc) *TX_RING_SIZE;
>> =A0 =A0 =A0 dma_free_coherent(NULL, ringsize, mdp->tx_ring, mdp->tx_=
desc_dma);
>>
>> =A0 =A0 =A0 pm_runtime_put_sync(&mdp->pdev->dev);
>
> Please do not include these space changes.

I revised this.

>
>> @@ -1497,8 +1656,11 @@ static int sh_eth_drv_probe(struct platform_d=
evice *pdev)
>>
>> =A0 =A0 =A0 /* set function */
>> =A0 =A0 =A0 ndev->netdev_ops =3D &sh_eth_netdev_ops;
>> + =A0 =A0 SET_ETHTOOL_OPS(ndev, &sh_eth_ethtool_ops);
>> =A0 =A0 =A0 ndev->watchdog_timeo =3D TX_TIMEOUT;
>>
>> + =A0 =A0 /* debug message level */
>> + =A0 =A0 mdp->msg_enable =3D (1 << 3) - 1;
>
> If you're actually going to *use* msg_enable, its value should be
> initialised in terms of the NETIF_MSG_* flags defined in
> <linux/netdevice.h>.

Thanks, I replaced to NETIF_MSG_*.

>
>> =A0 =A0 =A0 mdp->post_rx =3D POST_RX >> (devno << 1);
>> =A0 =A0 =A0 mdp->post_fw =3D POST_FW >> (devno << 1);
>>
>> @@ -1572,7 +1734,7 @@ static int sh_eth_runtime_nop(struct device *d=
ev)
>> =A0 =A0 =A0 return 0;
>> =A0}
>>
>> -static struct dev_pm_ops sh_eth_dev_pm_ops =3D {
>> +static const struct dev_pm_ops sh_eth_dev_pm_ops =3D {
>> =A0 =A0 =A0 .runtime_suspend =3D sh_eth_runtime_nop,
>> =A0 =A0 =A0 .runtime_resume =3D sh_eth_runtime_nop,
>> =A0};
>
> This is worthwhile but unrelated to ethtool!

Oh, I split to other patch.

>
> Ben.
>

Best regards,
  Nobuhiro
--=20
Nobuhiro Iwamatsu
