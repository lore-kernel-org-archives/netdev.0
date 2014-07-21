From: "fugang.duan@freescale.com" <fugang.duan@freescale.com>
Subject: RE: [PATCH] net: fec: ptp: avoid register access when ipg clock is
 disabled
Date: Mon, 21 Jul 2014 10:46:31 +0000
Message-ID: <08eaaff4b82b42538d6a0f4193ecb805@BLUPR03MB373.namprd03.prod.outlook.com>
References: <1405910155-29760-1-git-send-email-b38611@freescale.com>
 <20140721040301.GA4035@localhost.localdomain>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 8BIT
Cc: "shawn.guo@linaro.org" <shawn.guo@linaro.org>,
	"Frank.Li@freescale.com" <Frank.Li@freescale.com>,
	"davem@davemloft.net" <davem@davemloft.net>,
	"netdev@vger.kernel.org" <netdev@vger.kernel.org>
To: Richard Cochran <richardcochran@gmail.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-bl2lp0212.outbound.protection.outlook.com ([207.46.163.212]:5920
	"EHLO na01-bl2-obe.outbound.protection.outlook.com"
	rhost-flags-OK-OK-OK-FAIL) by vger.kernel.org with ESMTP
	id S1754324AbaGUKqx convert rfc822-to-8bit (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 21 Jul 2014 06:46:53 -0400
In-Reply-To: <20140721040301.GA4035@localhost.localdomain>
Content-Language: en-US
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: netdev-owner@vger.kernel.org <netdev-owner@vger.kernel.org>
>Sent: Monday, July 21, 2014 12:03 PM
>To: Duan Fugang-B38611
>Cc: shawn.guo@linaro.org; Li Frank-B20596; davem@davemloft.net;
>netdev@vger.kernel.org
>Subject: Re: [PATCH] net: fec: ptp: avoid register access when ipg clock
>is disabled
>
>On Mon, Jul 21, 2014 at 10:35:55AM +0800, Fugang Duan wrote:
>
>> diff --git a/drivers/net/ethernet/freescale/fec_main.c
>> b/drivers/net/ethernet/freescale/fec_main.c
>> index e0efb21..c4944e1 100644
>> --- a/drivers/net/ethernet/freescale/fec_main.c
>> +++ b/drivers/net/ethernet/freescale/fec_main.c
>> @@ -997,7 +997,7 @@ fec_restart(struct net_device *ndev)
>>  	writel(ecntl, fep->hwp + FEC_ECNTRL);
>>  	writel(0, fep->hwp + FEC_R_DES_ACTIVE);
>>
>> -	if (fep->bufdesc_ex)
>> +	if (fep->bufdesc_ex && (fep->hwts_tx_en || fep->hwts_rx_en))
>>  		fec_ptp_start_cyclecounter(ndev);
>>
>>  	/* Enable interrupts we wish to service */ @@ -1026,6 +1026,9 @@
>> fec_stop(struct net_device *ndev)
>>  	writel(fep->phy_speed, fep->hwp + FEC_MII_SPEED);
>>  	writel(FEC_DEFAULT_IMASK, fep->hwp + FEC_IMASK);
>>
>> +	if (fep->bufdesc_ex && (fep->hwts_tx_en || fep->hwts_rx_en))
>> +		fec_ptp_stop(ndev);
>
>So if user space turns time stamping off, then you keep running the timer.
>That is wrong, isn't it?
>
If user close the ethx interface, or do suspend operation, fec driver will
Close all clocks to save power, we also need to stop ptp, otherwise ptp timer
Keep access register that cause system hang.

I don't think this is a good method, maybe I need some time to struct better solution.

>>  	/* We have to keep ENET enabled to have MII interrupt stay working
>*/
>>  	if (id_entry->driver_data & FEC_QUIRK_ENET_MAC) {
>>  		writel(2, fep->hwp + FEC_ECNTRL);
>> diff --git a/drivers/net/ethernet/freescale/fec_ptp.c
>> b/drivers/net/ethernet/freescale/fec_ptp.c
>> index 82386b2..b2e9eb4 100644
>> --- a/drivers/net/ethernet/freescale/fec_ptp.c
>> +++ b/drivers/net/ethernet/freescale/fec_ptp.c
>> @@ -128,6 +128,9 @@ void fec_ptp_start_cyclecounter(struct net_device
>*ndev)
>>  	timecounter_init(&fep->tc, &fep->cc, ktime_to_ns(ktime_get_real()));
>>
>>  	spin_unlock_irqrestore(&fep->tmreg_lock, flags);
>> +
>> +	if (!timer_pending(&fep->time_keep))
>> +		add_timer(&fep->time_keep);
>
>Why not use a work queue for this?
>
>Thanks,
>Richard
>
There need one period timer to sync hw timer to avoid 32 bit hw counter overflow.

>>  }
>>
>>  /**
>> @@ -390,7 +393,6 @@ void fec_ptp_init(struct platform_device *pdev)
>>  	fep->time_keep.data = (unsigned long)fep;
>>  	fep->time_keep.function = fec_time_keep;
>>  	fep->time_keep.expires = jiffies + HZ;
>> -	add_timer(&fep->time_keep);
>>
>>  	fep->ptp_clock = ptp_clock_register(&fep->ptp_caps, &pdev->dev);
>>  	if (IS_ERR(fep->ptp_clock)) {
>> @@ -398,3 +400,20 @@ void fec_ptp_init(struct platform_device *pdev)
>>  		pr_err("ptp_clock_register failed\n");
>>  	}
>>  }
>> +
>> +/*
>> + * Cleanup routine for 1588 module.
>> + * When FEC is stopped this routing is called  */ void
>> +fec_ptp_stop(struct net_device *ndev) {
>> +	struct fec_enet_private *priv = netdev_priv(ndev);
>> +
>> +	writel(0, priv->hwp + FEC_ATIME_CTRL);
>> +	writel(FEC_T_CTRL_RESTART, priv->hwp + FEC_ATIME_CTRL);
>> +
>> +	priv->hwts_tx_en = 0;
>> +	priv->hwts_rx_en = 0;
>> +
>> +	del_timer_sync(&priv->time_keep);
>> +}
>> --
>> 1.7.8
>>
