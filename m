From: Robert Jarzmik <robert.jarzmik@free.fr>
Subject: Re: [PATCH v2] net: ethernet: davicom: fix devicetree irq resource
Date: Sun, 07 Feb 2016 11:46:01 +0100
Message-ID: <87twlk3ija.fsf@belgarion.home>
References: <1454796693-4446-1-git-send-email-robert.jarzmik@free.fr>
	<20160207102303.GA4976@electric-eye.fr.zoreil.com>
Mime-Version: 1.0
Content-Type: text/plain
Cc: netdev@vger.kernel.org, "David S. Miller" <davem@davemloft.net>,
	linux-kernel@vger.kernel.org,
	Sergei Shtylyov <sergei.shtylyov@cogentembedded.com>
To: Francois Romieu <romieu@fr.zoreil.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from smtp03.smtpout.orange.fr ([80.12.242.125]:31033 "EHLO
	smtp.smtpout.orange.fr" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1753328AbcBGKqG (ORCPT
	<rfc822;netdev@vger.kernel.org>); Sun, 7 Feb 2016 05:46:06 -0500
In-Reply-To: <20160207102303.GA4976@electric-eye.fr.zoreil.com> (Francois
	Romieu's message of "Sun, 7 Feb 2016 11:23:03 +0100")
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Francois Romieu <romieu@fr.zoreil.com> writes:

> Robert Jarzmik <robert.jarzmik@free.fr> :
> [...]
>> diff --git a/drivers/net/ethernet/davicom/dm9000.c b/drivers/net/ethernet/davicom/dm9000.c
>> index cf94b72dbacd..2bae5c8c1f85 100644
>> --- a/drivers/net/ethernet/davicom/dm9000.c
>> +++ b/drivers/net/ethernet/davicom/dm9000.c
> [...]
>> @@ -1500,15 +1496,21 @@ dm9000_probe(struct platform_device *pdev)
>>  
>>  	db->addr_res = platform_get_resource(pdev, IORESOURCE_MEM, 0);
>>  	db->data_res = platform_get_resource(pdev, IORESOURCE_MEM, 1);
>> -	db->irq_res  = platform_get_resource(pdev, IORESOURCE_IRQ, 0);
>>  
>> -	if (db->addr_res == NULL || db->data_res == NULL ||
>> -	    db->irq_res == NULL) {
>> -		dev_err(db->dev, "insufficient resources\n");
>> +	if (!db->addr_res || !db->data_res) {
>> +		dev_err(db->dev, "insufficient resources addr=%p data=%p\n",
>> +			db->addr_res, db->data_res);
>>  		ret = -ENOENT;
>>  		goto out;
>>  	}
>>  
>> +	ndev->irq = platform_get_irq(pdev, 0);
>> +	if (ndev->irq < 0) {
>> +		dev_err(db->dev, "interrupt resource unavailable: %d\n",
>> +			ndev->irq);
>> +		return ndev->irq;
>> +	}
>> +
>
> Leak: please set 'ret = ndev->irq;' and proceed to the 'out' label.
Indeed, the etherdev, good catch.

> If you have some spare time, it would be nice to avoid db->irq_wake leak
> on probe failure or driver removal.
Sorry but not in this patch.

I suppose the right patch would be to use devm_*() in the probe function for
ioremaps and request_irqs, which would address this point.

Cheers.

-- 
Robert
