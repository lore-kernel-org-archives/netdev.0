From: zhangfei <zhangfei.gao@linaro.org>
Subject: Re: [PATCH v1] net: phy: resume phydev when going to RESUMING
Date: Thu, 15 May 2014 09:57:39 +0800
Message-ID: <53741F13.5030805@linaro.org>
References: <1400031098-19072-1-git-send-email-zhangfei.gao@linaro.org>	 <1400031616-19287-1-git-send-email-zhangfei.gao@linaro.org> <1400032650.24350.79.camel@joe-AO725>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1; format=flowed
Content-Transfer-Encoding: 7bit
Cc: sebastian.hesselbarth@gmail.com, f.fainelli@gmail.com,
	davem@davemloft.net, sergei.shtylyov@cogentembedded.com,
	netdev@vger.kernel.org, Jiancheng Xue <xuejiancheng@huawei.com>
To: Joe Perches <joe@perches.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-pa0-f47.google.com ([209.85.220.47]:54482 "EHLO
	mail-pa0-f47.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751940AbaEOB5r (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 14 May 2014 21:57:47 -0400
Received: by mail-pa0-f47.google.com with SMTP id lf10so380051pab.34
        for <netdev@vger.kernel.org>; Wed, 14 May 2014 18:57:46 -0700 (PDT)
In-Reply-To: <1400032650.24350.79.camel@joe-AO725>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>



On 05/14/2014 09:57 AM, Joe Perches wrote:
> On Wed, 2014-05-14 at 09:40 +0800, Zhangfei Gao wrote:
>> With commit be9dad1f9f26604fb ("net: phy: suspend phydev when going
>> to HALTED"), an unused PHY device will be put in a low-power mode
>> using BMCR_PDOWN. Some Ethernet drivers might be calling phy_start()
>> and phy_stop() from ndo_open and ndo_close() respectively, while
>> calling phy_connect() and phy_disconnect() from probe and remove.
>> In such a case, the PHY will be powered down during the phy_stop()
>> call, but will fail to be powered up in phy_start().
>> This patch fixes this scenario.
>
> trivial notes:
>
>> diff --git a/drivers/net/phy/phy.c b/drivers/net/phy/phy.c
> []
>> @@ -715,7 +715,7 @@ void phy_state_machine(struct work_struct *work)
>>   	struct delayed_work *dwork = to_delayed_work(work);
>>   	struct phy_device *phydev =
>>   			container_of(dwork, struct phy_device, state_queue);
>> -	int needs_aneg = 0, do_suspend = 0;
>> +	int needs_aneg = 0, do_suspend = 0, do_resume = 0;
>
> Perhaps these 3 vars should bool
Yes, agree.
>
>> @@ -876,6 +878,9 @@ void phy_state_machine(struct work_struct *work)
>>   	if (do_suspend)
>>   		phy_suspend(phydev);
>>
>> +	if (do_resume)
>> +		phy_resume(phydev);
>> +
>
> and these should be else if
>
> 	if (needs_aneg)
> 		...
> 	else if (do_suspend)
> 		...
> 	else if (do_resume)
> 		...
Ok, since needs_aneg can not happen simultaneously with suspend/resume.

Thanks
