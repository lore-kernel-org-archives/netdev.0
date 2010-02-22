From: Daniel Baluta <daniel.baluta@gmail.com>
Subject: Re: [PATCH 1/2] can:ti_hecc: Add pm hook-up
Date: Mon, 22 Feb 2010 16:11:18 +0200
Message-ID: <413a6a951002220611j91b8da8ga670a3efbb1c1f08@mail.gmail.com>
References: <1266845736-7161-1-git-send-email-srk@ti.com>
	 <4B828E3C.40203@grandegger.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: Sriramakrishnan <srk@ti.com>, socketcan-core@lists.berlios.de,
	netdev@vger.kernel.org, K R Baalaaji <krbaalaaji@ti.com>
To: Wolfgang Grandegger <wg@grandegger.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-fx0-f219.google.com ([209.85.220.219]:55171 "EHLO
	mail-fx0-f219.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1753031Ab0BVOLU convert rfc822-to-8bit (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 22 Feb 2010 09:11:20 -0500
Received: by fxm19 with SMTP id 19so2528186fxm.21
        for <netdev@vger.kernel.org>; Mon, 22 Feb 2010 06:11:18 -0800 (PST)
In-Reply-To: <4B828E3C.40203@grandegger.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Mon, Feb 22, 2010 at 4:01 PM, Wolfgang Grandegger <wg@grandegger.com=
> wrote:
> Sriramakrishnan wrote:
>> Added the suspend and resume implementation in the HECC (CAN)
>> driver.
>>
>> Signed-off-by: K R Baalaaji <krbaalaaji@ti.com>
>> Signed-off-by: Sriramakrishnan <srk@ti.com>
>> Acked-by: Anant Gole <anantgole@ti.com>
>> ---
>> =A0drivers/net/can/ti_hecc.c | =A0 51 ++++++++++++++++++++++++++++++=
++++++++++++--
>> =A01 files changed, 48 insertions(+), 3 deletions(-)
>>
>> diff --git a/drivers/net/can/ti_hecc.c b/drivers/net/can/ti_hecc.c
>> index 5c993c2..df27d82 100644
>> --- a/drivers/net/can/ti_hecc.c
>> +++ b/drivers/net/can/ti_hecc.c
>> @@ -824,7 +824,6 @@ static int ti_hecc_open(struct net_device *ndev)
>> =A0 =A0 =A0 =A0 =A0 =A0 =A0 return err;
>> =A0 =A0 =A0 }
>>
>> - =A0 =A0 clk_enable(priv->clk);
>> =A0 =A0 =A0 ti_hecc_start(ndev);
>> =A0 =A0 =A0 napi_enable(&priv->napi);
>> =A0 =A0 =A0 netif_start_queue(ndev);
>> @@ -840,7 +839,6 @@ static int ti_hecc_close(struct net_device *ndev=
)
>> =A0 =A0 =A0 napi_disable(&priv->napi);
>> =A0 =A0 =A0 ti_hecc_stop(ndev);
>> =A0 =A0 =A0 free_irq(ndev->irq, ndev);
>> - =A0 =A0 clk_disable(priv->clk);
>> =A0 =A0 =A0 close_candev(ndev);
>>
>> =A0 =A0 =A0 return 0;
>> @@ -925,6 +923,7 @@ static int ti_hecc_probe(struct platform_device =
*pdev)
>> =A0 =A0 =A0 netif_napi_add(ndev, &priv->napi, ti_hecc_rx_poll,
>> =A0 =A0 =A0 =A0 =A0 =A0 =A0 HECC_DEF_NAPI_WEIGHT);
>>
>> + =A0 =A0 clk_enable(priv->clk);
>> =A0 =A0 =A0 err =3D register_candev(ndev);
>> =A0 =A0 =A0 if (err) {
>> =A0 =A0 =A0 =A0 =A0 =A0 =A0 dev_err(&pdev->dev, "register_candev() f=
ailed\n");
>> @@ -953,6 +952,7 @@ static int __devexit ti_hecc_remove(struct platf=
orm_device *pdev)
>> =A0 =A0 =A0 struct net_device *ndev =3D platform_get_drvdata(pdev);
>> =A0 =A0 =A0 struct ti_hecc_priv *priv =3D netdev_priv(ndev);
>>
>> + =A0 =A0 clk_disable(priv->clk);
>> =A0 =A0 =A0 clk_put(priv->clk);
>> =A0 =A0 =A0 res =3D platform_get_resource(pdev, IORESOURCE_MEM, 0);
>> =A0 =A0 =A0 iounmap(priv->base);
>> @@ -964,6 +964,48 @@ static int __devexit ti_hecc_remove(struct plat=
form_device *pdev)
>> =A0 =A0 =A0 return 0;
>> =A0}
>>
>> +
>> +#ifdef CONFIG_PM
>> +static int ti_hecc_suspend(struct platform_device *pdev, pm_message=
_t state)
>> +{
>> + =A0 =A0 struct net_device *dev =3D platform_get_drvdata(pdev);
>> + =A0 =A0 struct ti_hecc_priv *priv =3D netdev_priv(dev);
>> +
>> + =A0 =A0 if (netif_running(dev)) {
>> + =A0 =A0 =A0 =A0 =A0 =A0 netif_stop_queue(dev);
>> + =A0 =A0 =A0 =A0 =A0 =A0 netif_device_detach(dev);
>> + =A0 =A0 }
>> +
>> + =A0 =A0 hecc_set_bit(priv, HECC_CANMC, HECC_CANMC_PDR);
>> + =A0 =A0 priv->can.state =3D CAN_STATE_SLEEPING;
>> +
>> + =A0 =A0 clk_disable(priv->clk);
>> +
>> + =A0 =A0 return 0;
>> +}
>> +
>> +static int ti_hecc_resume(struct platform_device *pdev)
>> +{
>> + =A0 =A0 struct net_device *dev =3D platform_get_drvdata(pdev);
>> + =A0 =A0 struct ti_hecc_priv *priv =3D netdev_priv(dev);
>> +
>> + =A0 =A0 clk_enable(priv->clk);
>> +
>> + =A0 =A0 hecc_clear_bit(priv, HECC_CANMC, HECC_CANMC_PDR);
>> + =A0 =A0 priv->can.state =3D CAN_STATE_ERROR_ACTIVE;
>> +
>> + =A0 =A0 if (netif_running(dev)) {
>> + =A0 =A0 =A0 =A0 =A0 =A0 netif_device_attach(dev);
>> + =A0 =A0 =A0 =A0 =A0 =A0 netif_start_queue(dev);
>> + =A0 =A0 }
>> +
>> + =A0 =A0 return 0;
>> +}
>> +#else
>> +#define ti_hecc_suspend NULL
>> +#define ti_hecc_resume NULL
>> +#endif
>> +
>> =A0/* TI HECC netdevice driver: platform driver structure */
>> =A0static struct platform_driver ti_hecc_driver =3D {
>> =A0 =A0 =A0 .driver =3D {
>> @@ -972,6 +1014,8 @@ static struct platform_driver ti_hecc_driver =3D=
 {
>> =A0 =A0 =A0 },
>> =A0 =A0 =A0 .probe =3D ti_hecc_probe,
>> =A0 =A0 =A0 .remove =3D __devexit_p(ti_hecc_remove),
>> + =A0 =A0 .suspend =3D ti_hecc_suspend,
>> + =A0 =A0 .resume =3D ti_hecc_resume,
>> =A0};
>>
>> =A0static int __init ti_hecc_init_driver(void)
>> @@ -979,14 +1023,15 @@ static int __init ti_hecc_init_driver(void)
>> =A0 =A0 =A0 printk(KERN_INFO DRV_DESC "\n");
>> =A0 =A0 =A0 return platform_driver_register(&ti_hecc_driver);
>> =A0}
>> -module_init(ti_hecc_init_driver);
>>
>> =A0static void __exit ti_hecc_exit_driver(void)
>> =A0{
>> =A0 =A0 =A0 printk(KERN_INFO DRV_DESC " unloaded\n");
>> =A0 =A0 =A0 platform_driver_unregister(&ti_hecc_driver);
>> =A0}
>> +
>> =A0module_exit(ti_hecc_exit_driver);
>> +module_init(ti_hecc_init_driver);
>
> What is the reason for moving around module_init? Please revert. Then
> you can add my "Acked-by: Wolfgang Grandegger <wg@grandegger.com>".

I think "revert" is not the most appropriate word.
As you can see module_init was placed before ti_hecc_exit_driver functi=
on.

The best way to do it is to have at the end:

module_init(ti_hecc_init_driver);
module_exit(ti_hecc_exit_driver);
