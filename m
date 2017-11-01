From: Troy Kisky <troy.kisky@boundarydevices.com>
Subject: Re: [PATCH net v4 2/2] net: fec: Let fec_ptp have its own interrupt
 routine
Date: Wed, 1 Nov 2017 10:35:46 -0700
Message-ID: <eab4a3cb-ab0e-3dfd-3c18-0b36495c3d25@boundarydevices.com>
References: <20171031201647.13006-1-troy.kisky@boundarydevices.com>
 <20171031201647.13006-2-troy.kisky@boundarydevices.com>
 <AM4PR0401MB2260054E5E297478C099281BFF5F0@AM4PR0401MB2260.eurprd04.prod.outlook.com>
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
Received: from mail-oi0-f68.google.com ([209.85.218.68]:44825 "EHLO
        mail-oi0-f68.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1751587AbdKARfp (ORCPT
        <rfc822;netdev@vger.kernel.org>); Wed, 1 Nov 2017 13:35:45 -0400
Received: by mail-oi0-f68.google.com with SMTP id v132so5648722oie.1
        for <netdev@vger.kernel.org>; Wed, 01 Nov 2017 10:35:45 -0700 (PDT)
In-Reply-To: <AM4PR0401MB2260054E5E297478C099281BFF5F0@AM4PR0401MB2260.eurprd04.prod.outlook.com>
Content-Language: en-US
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On 10/31/2017 7:43 PM, Andy Duan wrote:
> From: Troy Kisky <troy.kisky@boundarydevices.com> Sent: Wednesday, November 01, 2017 4:17 AM
>> This is better for code locality and should slightly speed up normal interrupts.
>>
>> This also allows PPS clock output to start working for i.mx7. This is because
>> i.mx7 was already using the limit of 3 interrupts, and needed another.
>>
>> Signed-off-by: Troy Kisky <troy.kisky@boundarydevices.com>
>>
>> ---
>>
>> v2: made this change independent of any devicetree change so that old dtbs
>> continue to work.
>>
>> Continue to register ptp clock if interrupt is not found.
>>
>> v3: renamed "ptp" interrupt to "pps" interrupt
>>
>> v4: no change
>> ---
>> drivers/net/ethernet/freescale/fec.h      |  3 +-
>> drivers/net/ethernet/freescale/fec_main.c | 25 ++++++----
>> drivers/net/ethernet/freescale/fec_ptp.c  | 82 ++++++++++++++++++--------
>> -----
>> 3 files changed, 65 insertions(+), 45 deletions(-)
>>
>> diff --git a/drivers/net/ethernet/freescale/fec.h
>> b/drivers/net/ethernet/freescale/fec.h
>> index ede1876a9a19..be56ac1f1ac4 100644
>> --- a/drivers/net/ethernet/freescale/fec.h
>> +++ b/drivers/net/ethernet/freescale/fec.h
>> @@ -582,12 +582,11 @@ struct fec_enet_private {
>> 	u64 ethtool_stats[0];
>> };
>>
>> -void fec_ptp_init(struct platform_device *pdev);
>> +void fec_ptp_init(struct platform_device *pdev, int irq_index);
> 
> Seems change irq_index to irq_idx much better.


no problem

>> @@ -3465,18 +3463,27 @@ fec_probe(struct platform_device *pdev)
>> 	if (ret)
>> 		goto failed_reset;
>>
>> +	irq_cnt = platform_irq_count(pdev);
>> +	if (irq_cnt > FEC_IRQ_NUM)
>> +		irq_cnt = FEC_IRQ_NUM;	/* last for pps */
>> +	else if (irq_cnt == 2)
>> +		irq_cnt = 1;	/* last for pps */
>> +	else if (irq_cnt <= 0)
>> +		irq_cnt = 1;	/* Let the for loop fail */
>> +
> 
> Do some parse on probe function seems uncomfortable...can you encapsulate these code into one api ?
> 


Do you mean something like
	irq_cnt = limit_irq(pdev);


int limit_irq(struct platform_device *pdev)
{
	int irq_cnt = platform_irq_count(pdev);

	if (irq_cnt > FEC_IRQ_NUM)
		irq_cnt = FEC_IRQ_NUM;	/* last for pps */
	else if (irq_cnt == 2)
		irq_cnt = 1;	/* last for pps */
	else if (irq_cnt <= 0)
		irq_cnt = 1;	/* At least 1 irq is needed */
	return irq_cnt;
}
___________
Can you give some code to your idea? I don't think I understand.


	
> Others seems fine to me.
> Thanks.
> 
