From: "Anton.Glukhov" <anton.a.glukhov@gmail.com>
Subject: Re: [PATCH v2] net, can, ti_hecc: fix a run time warn_on.
Date: Tue, 20 Oct 2015 19:30:03 +0300
Message-ID: <56266C0B.1040006@gmail.com>
References: <1445351968-18956-1-git-send-email-anton.a.glukhov@gmail.com>
 <562653CD.5040101@pengutronix.de>
Mime-Version: 1.0
Content-Type: text/plain; charset=utf-8
Content-Transfer-Encoding: 7bit
Cc: hs@denx.de, netdev@vger.kernel.org
To: Marc Kleine-Budde <mkl@pengutronix.de>, linux-can@vger.kernel.org
Return-path: <linux-can-owner@vger.kernel.org>
In-Reply-To: <562653CD.5040101@pengutronix.de>
Sender: linux-can-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Thank you for review Marc!

On 20.10.2015 17:46, Marc Kleine-Budde wrote:
> On 10/20/2015 04:39 PM, Anton Glukhov wrote:
>> This patch fixes a warning in clk_enable by calling
>> clk_prepare_enable instead.
>>
>> Signed-off-by: Heiko Schocher <hs@denx.de>
>> Signed-off-by: Anton Glukhov <anton.a.glukhov@gmail.com>
>> ---
>>  drivers/net/can/ti_hecc.c | 13 +++++++------
>>  1 file changed, 7 insertions(+), 6 deletions(-)
>>
>> diff --git a/drivers/net/can/ti_hecc.c b/drivers/net/can/ti_hecc.c
>> index cf345cb..77dd170 100644
>> --- a/drivers/net/can/ti_hecc.c
>> +++ b/drivers/net/can/ti_hecc.c
>> @@ -951,7 +951,7 @@ static int ti_hecc_probe(struct platform_device *pdev)
>>  	netif_napi_add(ndev, &priv->napi, ti_hecc_rx_poll,
>>  		HECC_DEF_NAPI_WEIGHT);
>>  
>> -	clk_enable(priv->clk);
>> +	clk_prepare_enable(priv->clk);
> 
> please add error checking
> 
>>  	err = register_candev(ndev);
>>  	if (err) {
>>  		dev_err(&pdev->dev, "register_candev() failed\n");
>> @@ -966,7 +966,8 @@ static int ti_hecc_probe(struct platform_device *pdev)
>>  	return 0;
>>  
>>  probe_exit_clk:
>> -	clk_put(priv->clk);
> 
> Why do you remove the clk_put()?
> 

My fault. I'll fix it in ver3.

>> +	clk_disable_unprepare(priv->clk);
>> +	priv->clk = NULL;
> 
> The NULLing of priv->clk is not needed.
> 
>>  probe_exit_candev:
>>  	free_candev(ndev);
>>  probe_exit_iounmap:
>> @@ -984,8 +985,8 @@ static int ti_hecc_remove(struct platform_device *pdev)
>>  	struct ti_hecc_priv *priv = netdev_priv(ndev);
>>  
>>  	unregister_candev(ndev);
>> -	clk_disable(priv->clk);
>> -	clk_put(priv->clk);
> 
> Why do you remoe the clk_put()?
> 
>> +	clk_disable_unprepare(priv->clk);
>> +	priv->clk = NULL;
>>  	res = platform_get_resource(pdev, IORESOURCE_MEM, 0);
>>  	iounmap(priv->base);
>>  	release_mem_region(res->start, resource_size(res));
>> @@ -1009,7 +1010,7 @@ static int ti_hecc_suspend(struct platform_device *pdev, pm_message_t state)
>>  	hecc_set_bit(priv, HECC_CANMC, HECC_CANMC_PDR);
>>  	priv->can.state = CAN_STATE_SLEEPING;
>>  
>> -	clk_disable(priv->clk);
>> +	clk_disable_unprepare(priv->clk);
>>  
>>  	return 0;
>>  }
>> @@ -1019,7 +1020,7 @@ static int ti_hecc_resume(struct platform_device *pdev)
>>  	struct net_device *dev = platform_get_drvdata(pdev);
>>  	struct ti_hecc_priv *priv = netdev_priv(dev);
>>  
>> -	clk_enable(priv->clk);
>> +	clk_prepare_enable(priv->clk);
> 
> please add error checking.
> 

Why it wasn't added with clk_enable? Is it bug? I'm confused here, because in so many drivers
there is no checking err after clk_enable or clk_prepare_enable. Maybe I missed something...
Could you clarify this part please?

>>  
>>  	hecc_clear_bit(priv, HECC_CANMC, HECC_CANMC_PDR);
>>  	priv->can.state = CAN_STATE_ERROR_ACTIVE;
>>
> 
> Marc
> 

regards,
Anton
