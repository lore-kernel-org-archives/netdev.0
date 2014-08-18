From: "fugang.duan@freescale.com" <fugang.duan@freescale.com>
Subject: RE: [PATCH v3 1/1] net: fec: ptp: avoid register access when ipg
 clock is disabled
Date: Mon, 18 Aug 2014 06:07:00 +0000
Message-ID: <b50df5011728419887508cbf3af0a5a7@BLUPR03MB373.namprd03.prod.outlook.com>
References: <1408081975-15087-1-git-send-email-b38611@freescale.com>
 <1408081975-15087-2-git-send-email-b38611@freescale.com>
 <20140815180854.GA6897@localhost.localdomain>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 8BIT
Cc: "davem@davemloft.net" <davem@davemloft.net>,
	"netdev@vger.kernel.org" <netdev@vger.kernel.org>,
	"shawn.guo@linaro.org" <shawn.guo@linaro.org>
To: Richard Cochran <richardcochran@gmail.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-bn1lp0140.outbound.protection.outlook.com ([207.46.163.140]:16585
	"EHLO na01-bn1-obe.outbound.protection.outlook.com"
	rhost-flags-OK-OK-OK-FAIL) by vger.kernel.org with ESMTP
	id S1751142AbaHRGHD convert rfc822-to-8bit (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 18 Aug 2014 02:07:03 -0400
In-Reply-To: <20140815180854.GA6897@localhost.localdomain>
Content-Language: en-US
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Richard Cochran <richardcochran@gmail.com> Data: Saturday, August 16, 2014 2:09 AM
>To: Duan Fugang-B38611
>Cc: davem@davemloft.net; netdev@vger.kernel.org; shawn.guo@linaro.org
>Subject: Re: [PATCH v3 1/1] net: fec: ptp: avoid register access when ipg
>clock is disabled
>
>Looks better, but ...
>
>On Fri, Aug 15, 2014 at 01:52:55PM +0800, Fugang Duan wrote:
>
>> diff --git a/drivers/net/ethernet/freescale/fec_main.c
>b/drivers/net/ethernet/freescale/fec_main.c
>> index 66fe1f6..ba35994 100644
>> --- a/drivers/net/ethernet/freescale/fec_main.c
>> +++ b/drivers/net/ethernet/freescale/fec_main.c
>> @@ -1613,14 +1613,18 @@ static int fec_enet_clk_enable(struct net_device
>*ndev, bool enable)
>>  			ret = clk_prepare_enable(fep->clk_ptp);
>>  			if (ret)
>>  				goto failed_clk_ptp;
>> +			else
>> +				fep->ptp_clk_on = true;
>>  		}
>>  	} else {
>>  		clk_disable_unprepare(fep->clk_ahb);
>>  		clk_disable_unprepare(fep->clk_ipg);
>>  		if (fep->clk_enet_out)
>>  			clk_disable_unprepare(fep->clk_enet_out);
>> -		if (fep->clk_ptp)
>> +		if (fep->clk_ptp) {
>>  			clk_disable_unprepare(fep->clk_ptp);
>> +			fep->ptp_clk_on = false;
>
>Set the flag to false first, because this races ...
Hi, Richard,

Pls ignore my comments in previous mail.
1. Set the flag to false firstly.
2. Don't need to add mutex to protect the flag.(My previous mail ask one mutex to protect the flag)
   Just pull the flag into the protected field by spin_lock_irqsave() like :
fec_time_keep()
{
...
        spin_lock_irqsave(&fep->tmreg_lock, flags);
-       ns = timecounter_read(&fep->tc);
+       if (fep->ptp_clk_on)
+               ns = timecounter_read(&fep->tc);
        spin_unlock_irqrestore(&fep->tmreg_lock, flags);
...
}	

And, if there have no other comments, I will send the next version for the patch ?

>
>> diff --git a/drivers/net/ethernet/freescale/fec_ptp.c
>b/drivers/net/ethernet/freescale/fec_ptp.c
>> index 82386b2..8084aaf 100644
>> --- a/drivers/net/ethernet/freescale/fec_ptp.c
>> +++ b/drivers/net/ethernet/freescale/fec_ptp.c
>> @@ -245,6 +245,10 @@ static int fec_ptp_settime(struct ptp_clock_info
>*ptp,
>>  	u64 ns;
>>  	unsigned long flags;
>>
>> +	/* Check the ptp clock */
>> +	if (!fep->ptp_clk_on)
>> +		return -EINVAL;
>
>with this and ...
>
>> +
>>  	ns = ts->tv_sec * 1000000000ULL;
>>  	ns += ts->tv_nsec;
>>
>> @@ -338,17 +342,20 @@ int fec_ptp_get(struct net_device *ndev, struct
>ifreq *ifr)
>>   * fec_time_keep - call timecounter_read every second to avoid timer
>overrun
>>   *                 because ENET just support 32bit counter, will
>timeout in 4s
>>   */
>> -static void fec_time_keep(unsigned long _data)
>> +static void fec_time_keep(struct work_struct *work)
>>  {
>> -	struct fec_enet_private *fep = (struct fec_enet_private *)_data;
>> +	struct delayed_work *dwork = to_delayed_work(work);
>> +	struct fec_enet_private *fep = container_of(dwork, struct
>fec_enet_private, time_keep);
>>  	u64 ns;
>>  	unsigned long flags;
>>
>> -	spin_lock_irqsave(&fep->tmreg_lock, flags);
>> -	ns = timecounter_read(&fep->tc);
>> -	spin_unlock_irqrestore(&fep->tmreg_lock, flags);
>> +	if (fep->ptp_clk_on) {
>
>with this.
>
>> +		spin_lock_irqsave(&fep->tmreg_lock, flags);
>> +		ns = timecounter_read(&fep->tc);
>> +		spin_unlock_irqrestore(&fep->tmreg_lock, flags);
>> +	}
>
>Thanks,
>Richard
