From: Troy Kisky <troy.kisky@boundarydevices.com>
Subject: Re: [PATCH net v2 2/2] net: fec: Let fec_ptp have its own interrupt
 routine
Date: Wed, 18 Oct 2017 11:10:52 -0700
Message-ID: <677439a7-c225-c231-bbc8-986e2590ebed@boundarydevices.com>
References: <20171014020940.32736-1-troy.kisky@boundarydevices.com>
 <20171014020940.32736-2-troy.kisky@boundarydevices.com>
 <AM4PR0401MB226019650A8FB767B11B8B91FF4F0@AM4PR0401MB2260.eurprd04.prod.outlook.com>
 <542a126c-d7ff-7232-9dde-e5c6f1e1f55f@boundarydevices.com>
 <AM4PR0401MB226072C7D7775F16C533316FFF4D0@AM4PR0401MB2260.eurprd04.prod.outlook.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=utf-8
Content-Transfer-Encoding: 7bit
Cc: Fabio Estevam <fabio.estevam@nxp.com>,
        "lznuaa@gmail.com" <lznuaa@gmail.com>,
        "andrew@lunn.ch" <andrew@lunn.ch>
To: Andy Duan <fugang.duan@nxp.com>,
        "shawn.guo@linaro.org" <shawn.guo@linaro.org>,
        "netdev@vger.kernel.org" <netdev@vger.kernel.org>,
        "davem@davemloft.net" <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-oi0-f67.google.com ([209.85.218.67]:51938 "EHLO
        mail-oi0-f67.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1750730AbdJRSKx (ORCPT
        <rfc822;netdev@vger.kernel.org>); Wed, 18 Oct 2017 14:10:53 -0400
Received: by mail-oi0-f67.google.com with SMTP id j126so10422015oib.8
        for <netdev@vger.kernel.org>; Wed, 18 Oct 2017 11:10:53 -0700 (PDT)
In-Reply-To: <AM4PR0401MB226072C7D7775F16C533316FFF4D0@AM4PR0401MB2260.eurprd04.prod.outlook.com>
Content-Language: en-US
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On 10/17/2017 7:30 PM, Andy Duan wrote:
> From: Troy Kisky <troy.kisky@boundarydevices.com> Sent: Wednesday, October 18, 2017 5:34 AM
>>>> This is better for code locality and should slightly speed up normal
>> interrupts.
>>>>
>>>> This also allows PPS clock output to start working for i.mx7. This is
>>>> because
>>>> i.mx7 was already using the limit of 3 interrupts, and needed another.
>>>>
>>>> Signed-off-by: Troy Kisky <troy.kisky@boundarydevices.com>
>>>>
>>>> ---
>>>>
>>>> v2: made this change independent of any devicetree change so that old
>>>> dtbs continue to work.
>>>>
>>>> Continue to register ptp clock if interrupt is not found.
>>>> ---
>>>> drivers/net/ethernet/freescale/fec.h      |  3 +-
>>>> drivers/net/ethernet/freescale/fec_main.c | 25 ++++++----
>>>> drivers/net/ethernet/freescale/fec_ptp.c  | 82
>>>> ++++++++++++++++++--------
>>>> -----
>>>> 3 files changed, 65 insertions(+), 45 deletions(-)
>>>>
>>>> diff --git a/drivers/net/ethernet/freescale/fec.h
>>>> b/drivers/net/ethernet/freescale/fec.h
>>>> index ede1876a9a19..be56ac1f1ac4 100644
>>>> --- a/drivers/net/ethernet/freescale/fec.h
>>>> +++ b/drivers/net/ethernet/freescale/fec.h
>>>> @@ -582,12 +582,11 @@ struct fec_enet_private {
>>>> 	u64 ethtool_stats[0];
>>>> };
>>>>
>>>> -void fec_ptp_init(struct platform_device *pdev);
>>>> +void fec_ptp_init(struct platform_device *pdev, int irq_index);
>>>> void fec_ptp_stop(struct platform_device *pdev);  void
>>>> fec_ptp_start_cyclecounter(struct net_device *ndev);  int
>>>> fec_ptp_set(struct net_device *ndev, struct ifreq *ifr);  int
>>>> fec_ptp_get(struct net_device *ndev, struct ifreq *ifr); -uint
>>>> fec_ptp_check_pps_event(struct fec_enet_private *fep);
>>>>
>>>>
>>>>
>> /**********************************************************
>>>> ******************/
>>>> #endif /* FEC_H */
>>>> diff --git a/drivers/net/ethernet/freescale/fec_main.c
>>>> b/drivers/net/ethernet/freescale/fec_main.c
>>>> index 3dc2d771a222..21afabbc560f 100644
>>>> --- a/drivers/net/ethernet/freescale/fec_main.c
>>>> +++ b/drivers/net/ethernet/freescale/fec_main.c
>>>> @@ -1602,10 +1602,6 @@ fec_enet_interrupt(int irq, void *dev_id)
>>>> 		ret = IRQ_HANDLED;
>>>> 		complete(&fep->mdio_done);
>>>> 	}
>>>> -
>>>> -	if (fep->ptp_clock)
>>>> -		if (fec_ptp_check_pps_event(fep))
>>>> -			ret = IRQ_HANDLED;
>>>> 	return ret;
>>>> }
>>>>
>>>> @@ -3325,6 +3321,8 @@ fec_probe(struct platform_device *pdev)
>>>> 	struct device_node *np = pdev->dev.of_node, *phy_node;
>>>> 	int num_tx_qs;
>>>> 	int num_rx_qs;
>>>> +	char irq_name[8];
>>>> +	int irq_cnt;
>>>>
>>>> 	fec_enet_get_queue_num(pdev, &num_tx_qs, &num_rx_qs);
>>>>
>>>> @@ -3465,18 +3463,27 @@ fec_probe(struct platform_device *pdev)
>>>> 	if (ret)
>>>> 		goto failed_reset;
>>>>
>>>> +	irq_cnt = platform_irq_count(pdev);
>>>> +	if (irq_cnt > FEC_IRQ_NUM)
>>>> +		irq_cnt = FEC_IRQ_NUM;	/* last for ptp */
>>>> +	else if (irq_cnt == 2)
>>>> +		irq_cnt = 1;	/* last for ptp */
>>>> +	else if (irq_cnt <= 0)
>>>> +		irq_cnt = 1;	/* Let the for loop fail */
>>>
>>> Don't do like this. Don't suppose pps interrupt is the last one.
>>
>>
>> I don't. If the pps interrupt is named, the named interrupt will be used. If it is
>> NOT named, the last interrupt is used, if 2 interrupts, or >3 interrupt are
>> provided.
>> Otherwise, no pps interrupt is assumed.
>> Fortunately this seems to be true currently.
>>
> If pps interrupt is not named, then it limit the last one is pps.
> We cannot get the pps interrupt based on current chip interrupt define, we never know the future chip how to define interrupt.
> Although your current implementation can work with current chips, but it is not really good solution.
> 
>>
>>> And if irq_cnt is 1 like imx28/imx5x,  the patch will break fec interrupt
>> function.
>>
>> How ?  fec_ptp_init will not be called as bufdesc_ex is 0.
>>
> Imx28 also support enhanced buffer descriptor,  if define the ptp clock in dts then bufdesc_ex also can be 1.


Only if FEC_QUIRK_HAS_BUFDESC_EX is set, which it is not. Here's the relevant code snippets

	}, {
		.name = "imx25-fec",
		.driver_data = FEC_QUIRK_USE_GASKET | FEC_QUIRK_MIB_CLEAR,
	}, {
		.name = "imx27-fec",
		.driver_data = FEC_QUIRK_MIB_CLEAR,
	}, {
		.name = "imx28-fec",
		.driver_data = FEC_QUIRK_ENET_MAC | FEC_QUIRK_SWAP_FRAME |
				FEC_QUIRK_SINGLE_MDIO | FEC_QUIRK_HAS_RACC,
	}, {

....
	fep->bufdesc_ex = fep->quirks & FEC_QUIRK_HAS_BUFDESC_EX;
	fep->clk_ptp = devm_clk_get(&pdev->dev, "ptp");
	if (IS_ERR(fep->clk_ptp)) {
		fep->clk_ptp = NULL;
		fep->bufdesc_ex = false;
	}
______________

You could make your way work though, if you remove the pps clock from imx50.dtsi, imx51.dtsi, and
imx53.dtsi.

Then you would not need the FEC_QUIRK_HAS_BUFDESC_EX quirk.
This is all a little off topic though.


> 
> I still suggest to use v1 logic check pps interrupt that need to check irq name.


I could add that back. But it seems redundant when also looking up by name "int0", "int1", "int2".

I would think that we could recommend in the binding documentation that either all are
named, or none are. And I don't think we need to make work mistakes like

interrupt-names = "irq0", "ptp", "int1", "int2"

but
interrupt-names = "int0", "ptp", "int1", "int2"
should currently work.


Let me know if you want me to make work
interrupt-names = "", "ptp", "", ""

or if you just don't think this patch is necessary. I might have some more
reasons to try and persuade you.



> 
>>
>> Also, if only 1 interrupt is provided, it is assumed there is no unnamed pps
>> interrupt.
>>
>>
>>>
>>> I suggest to use .platform_get_irq_byname() to get pps(ptp) interrupt like
>> your v1 logic check.
>>>
>>>> +
>>>> 	if (fep->bufdesc_ex)
>>>> -		fec_ptp_init(pdev);
>>>> +		fec_ptp_init(pdev, irq_cnt);
>>>>
>>>> 	ret = fec_enet_init(ndev);
>>>> 	if (ret)
>>>> 		goto failed_init;
>>>>
>>>> -	for (i = 0; i < FEC_IRQ_NUM; i++) {
>>>> -		irq = platform_get_irq(pdev, i);
>>>> +	for (i = 0; i < irq_cnt; i++) {
>>>> +		sprintf(irq_name, "int%d", i);
>>>> +		irq = platform_get_irq_byname(pdev, irq_name);
>>>> +		if (irq < 0)
>>>> +			irq = platform_get_irq(pdev, i);
>>>> 		if (irq < 0) {
>>>> -			if (i)
>>>> -				break;
>>>> 			ret = irq;
>>>> 			goto failed_irq;
>>>> 		}


Thanks for the review

Troy
