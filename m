From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH] net: fec: ptp: fix convergence issue to support
 LinuxPTP stack
Date: Tue, 14 Oct 2014 12:52:39 -0400 (EDT)
Message-ID: <20141014.125239.1562178476120218308.davem@davemloft.net>
References: <1413265187-5228-1-git-send-email-b38611@freescale.com>
	<20141014103610.GA4019@localhost.localdomain>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: b38611@freescale.com, netdev@vger.kernel.org,
	bhutchings@solarflare.com, b20596@freescale.com
To: richardcochran@gmail.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from shards.monkeyblade.net ([149.20.54.216]:42618 "EHLO
	shards.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1755511AbaJNQwm (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 14 Oct 2014 12:52:42 -0400
In-Reply-To: <20141014103610.GA4019@localhost.localdomain>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Richard Cochran <richardcochran@gmail.com>
Date: Tue, 14 Oct 2014 12:36:10 +0200

> On Tue, Oct 14, 2014 at 01:39:47PM +0800, Fugang Duan wrote:
>> IEEE 1588 module has one hw issue in capturing the ATVR register. According
>> to the user manual it is:
>> 		ENET0->ATCR |= ENET_ATCR_CAPTURE_MASK;
>> 		while(ENET0->ATCR & ENET_ATCR_CAPTURE_MASK);
>> 		ts_counter_ns = ENET0->ATVR;
> 
> ...
> 
>> diff --git a/drivers/net/ethernet/freescale/fec_ptp.c b/drivers/net/ethernet/freescale/fec_ptp.c
>> index cca3617..380bb10 100644
>> --- a/drivers/net/ethernet/freescale/fec_ptp.c
>> +++ b/drivers/net/ethernet/freescale/fec_ptp.c
>> @@ -82,12 +82,17 @@ static cycle_t fec_ptp_read(const struct cyclecounter *cc)
>>  {
>>  	struct fec_enet_private *fep =
>>  		container_of(cc, struct fec_enet_private, cc);
>> +	const struct platform_device_id *id_entry =
>> +		platform_get_device_id(fep->pdev);
>>  	u32 tempval;
>>  
>>  	tempval = readl(fep->hwp + FEC_ATIME_CTRL);
>>  	tempval |= FEC_T_CTRL_CAPTURE;
>>  	writel(tempval, fep->hwp + FEC_ATIME_CTRL);
>>  
>> +	if (id_entry->driver_data & FEC_QUIRK_BUG_CAPTURE)
>> +		udelay(1);
>> +
> 
> What? You never had
> 
> 	while(ENET0->ATCR & ENET_ATCR_CAPTURE_MASK);
> 
> in the first place. Maybe you should try that.
> 
> Did this code ever work? I guess not.

Also see Luwei Zhou's series:

http://patchwork.ozlabs.org/patch/398467/
http://patchwork.ozlabs.org/patch/398465/
http://patchwork.ozlabs.org/patch/398466/

Let's get down to the bottom of all of this before I apply anything.  Does this
fec PTP code work at all?
