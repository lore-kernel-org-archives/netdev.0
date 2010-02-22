From: Wolfgang Grandegger <wg@grandegger.com>
Subject: Re: [PATCH 1/2] can:ti_hecc: Add pm hook-up
Date: Mon, 22 Feb 2010 15:40:48 +0100
Message-ID: <4B829770.4080508@grandegger.com>
References: <1266845736-7161-1-git-send-email-srk@ti.com>	 <4B828E3C.40203@grandegger.com> <413a6a951002220611j91b8da8ga670a3efbb1c1f08@mail.gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1
Content-Transfer-Encoding: 7bit
Cc: Sriramakrishnan <srk@ti.com>, socketcan-core@lists.berlios.de,
	netdev@vger.kernel.org, K R Baalaaji <krbaalaaji@ti.com>
To: Daniel Baluta <daniel.baluta@gmail.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-out.m-online.net ([212.18.0.10]:50129 "EHLO
	mail-out.m-online.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1753319Ab0BVOmJ (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 22 Feb 2010 09:42:09 -0500
In-Reply-To: <413a6a951002220611j91b8da8ga670a3efbb1c1f08@mail.gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Daniel Baluta wrote:
> On Mon, Feb 22, 2010 at 4:01 PM, Wolfgang Grandegger <wg@grandegger.com> wrote:
>> Sriramakrishnan wrote:
>>> Added the suspend and resume implementation in the HECC (CAN)
>>> driver.
>>>
>>> Signed-off-by: K R Baalaaji <krbaalaaji@ti.com>
>>> Signed-off-by: Sriramakrishnan <srk@ti.com>
>>> Acked-by: Anant Gole <anantgole@ti.com>
>>> ---
>>>  drivers/net/can/ti_hecc.c |   51 ++++++++++++++++++++++++++++++++++++++++++--
>>>  1 files changed, 48 insertions(+), 3 deletions(-)
>>>
>>> diff --git a/drivers/net/can/ti_hecc.c b/drivers/net/can/ti_hecc.c
>>> index 5c993c2..df27d82 100644
>>> --- a/drivers/net/can/ti_hecc.c
>>> +++ b/drivers/net/can/ti_hecc.c
>>> @@ -824,7 +824,6 @@ static int ti_hecc_open(struct net_device *ndev)
>>>               return err;
>>>       }
>>>
>>> -     clk_enable(priv->clk);
>>>       ti_hecc_start(ndev);
>>>       napi_enable(&priv->napi);
>>>       netif_start_queue(ndev);
>>> @@ -840,7 +839,6 @@ static int ti_hecc_close(struct net_device *ndev)
>>>       napi_disable(&priv->napi);
>>>       ti_hecc_stop(ndev);
>>>       free_irq(ndev->irq, ndev);
>>> -     clk_disable(priv->clk);
>>>       close_candev(ndev);
>>>
>>>       return 0;
>>> @@ -925,6 +923,7 @@ static int ti_hecc_probe(struct platform_device *pdev)
>>>       netif_napi_add(ndev, &priv->napi, ti_hecc_rx_poll,
>>>               HECC_DEF_NAPI_WEIGHT);
>>>
>>> +     clk_enable(priv->clk);
>>>       err = register_candev(ndev);
>>>       if (err) {
>>>               dev_err(&pdev->dev, "register_candev() failed\n");
>>> @@ -953,6 +952,7 @@ static int __devexit ti_hecc_remove(struct platform_device *pdev)
>>>       struct net_device *ndev = platform_get_drvdata(pdev);
>>>       struct ti_hecc_priv *priv = netdev_priv(ndev);
>>>
>>> +     clk_disable(priv->clk);
>>>       clk_put(priv->clk);
>>>       res = platform_get_resource(pdev, IORESOURCE_MEM, 0);
>>>       iounmap(priv->base);
>>> @@ -964,6 +964,48 @@ static int __devexit ti_hecc_remove(struct platform_device *pdev)
>>>       return 0;
>>>  }
>>>
>>> +
>>> +#ifdef CONFIG_PM
>>> +static int ti_hecc_suspend(struct platform_device *pdev, pm_message_t state)
>>> +{
>>> +     struct net_device *dev = platform_get_drvdata(pdev);
>>> +     struct ti_hecc_priv *priv = netdev_priv(dev);
>>> +
>>> +     if (netif_running(dev)) {
>>> +             netif_stop_queue(dev);
>>> +             netif_device_detach(dev);
>>> +     }
>>> +
>>> +     hecc_set_bit(priv, HECC_CANMC, HECC_CANMC_PDR);
>>> +     priv->can.state = CAN_STATE_SLEEPING;
>>> +
>>> +     clk_disable(priv->clk);
>>> +
>>> +     return 0;
>>> +}
>>> +
>>> +static int ti_hecc_resume(struct platform_device *pdev)
>>> +{
>>> +     struct net_device *dev = platform_get_drvdata(pdev);
>>> +     struct ti_hecc_priv *priv = netdev_priv(dev);
>>> +
>>> +     clk_enable(priv->clk);
>>> +
>>> +     hecc_clear_bit(priv, HECC_CANMC, HECC_CANMC_PDR);
>>> +     priv->can.state = CAN_STATE_ERROR_ACTIVE;
>>> +
>>> +     if (netif_running(dev)) {
>>> +             netif_device_attach(dev);
>>> +             netif_start_queue(dev);
>>> +     }
>>> +
>>> +     return 0;
>>> +}
>>> +#else
>>> +#define ti_hecc_suspend NULL
>>> +#define ti_hecc_resume NULL
>>> +#endif
>>> +
>>>  /* TI HECC netdevice driver: platform driver structure */
>>>  static struct platform_driver ti_hecc_driver = {
>>>       .driver = {
>>> @@ -972,6 +1014,8 @@ static struct platform_driver ti_hecc_driver = {
>>>       },
>>>       .probe = ti_hecc_probe,
>>>       .remove = __devexit_p(ti_hecc_remove),
>>> +     .suspend = ti_hecc_suspend,
>>> +     .resume = ti_hecc_resume,
>>>  };
>>>
>>>  static int __init ti_hecc_init_driver(void)
>>> @@ -979,14 +1023,15 @@ static int __init ti_hecc_init_driver(void)
>>>       printk(KERN_INFO DRV_DESC "\n");
>>>       return platform_driver_register(&ti_hecc_driver);
>>>  }
>>> -module_init(ti_hecc_init_driver);
>>>
>>>  static void __exit ti_hecc_exit_driver(void)
>>>  {
>>>       printk(KERN_INFO DRV_DESC " unloaded\n");
>>>       platform_driver_unregister(&ti_hecc_driver);
>>>  }
>>> +
>>>  module_exit(ti_hecc_exit_driver);
>>> +module_init(ti_hecc_init_driver);
>> What is the reason for moving around module_init? Please revert. Then
>> you can add my "Acked-by: Wolfgang Grandegger <wg@grandegger.com>".
> 
> I think "revert" is not the most appropriate word.
> As you can see module_init was placed before ti_hecc_exit_driver function.
> 
> The best way to do it is to have at the end:
> 
> module_init(ti_hecc_init_driver);
> module_exit(ti_hecc_exit_driver);

I personally disagree! But it seems to be the most popular method. And
this change is not related to the subject nor is it described in the
patch description. Anyway, it's a minor issue and if Dave think it's OK,
 I will not insist.

Wolfgang.

