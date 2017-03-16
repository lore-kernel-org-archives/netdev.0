From: Jane Li <jiel@marvell.com>
Subject: Re: [PATCH] net: mvneta: support suspend and resume
Date: Thu, 16 Mar 2017 11:23:54 +0800
Message-ID: <12f81ffd-ff49-46ff-e93e-ad4cc15ef21b@marvell.com>
References: <1489561714-2368-1-git-send-email-jiel@marvell.com>
 <20170315151843.258f214f@xhacker>
Mime-Version: 1.0
Content-Type: text/plain; charset="UTF-8"; format=flowed
Content-Transfer-Encoding: 8bit
Cc: <thomas.petazzoni@free-electrons.com>, <netdev@vger.kernel.org>,
        <linux-kernel@vger.kernel.org>
To: Jisheng Zhang <jszhang@marvell.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mx0a-0016f401.pphosted.com ([67.231.148.174]:49127 "EHLO
        mx0b-0016f401.pphosted.com" rhost-flags-OK-OK-OK-FAIL)
        by vger.kernel.org with ESMTP id S1750885AbdCPDYA (ORCPT
        <rfc822;netdev@vger.kernel.org>); Wed, 15 Mar 2017 23:24:00 -0400
In-Reply-To: <20170315151843.258f214f@xhacker>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Hi Jisheng,


On 2017年03月15日 15:18, Jisheng Zhang wrote:
> Hi Jane,
>
> On Wed, 15 Mar 2017 15:08:34 +0800 Jane Li  wrote:
>
>> Add basic support for handling suspend and resume.
>>
>> Signed-off-by: Jane Li <jiel@marvell.com>
>> ---
>>   drivers/net/ethernet/marvell/mvneta.c | 44 +++++++++++++++++++++++++++++++++++
>>   1 file changed, 44 insertions(+)
>>
>> diff --git a/drivers/net/ethernet/marvell/mvneta.c b/drivers/net/ethernet/marvell/mvneta.c
>> index 61dd446..4f16342 100644
>> --- a/drivers/net/ethernet/marvell/mvneta.c
>> +++ b/drivers/net/ethernet/marvell/mvneta.c
>> @@ -4405,6 +4405,49 @@ static int mvneta_remove(struct platform_device *pdev)
>>   	return 0;
>>   }
>>   
>> +#ifdef CONFIG_PM_SLEEP
>> +static int mvneta_suspend(struct device *device)
>> +{
>> +	struct net_device *dev = dev_get_drvdata(device);
>> +	struct mvneta_port *pp = netdev_priv(dev);
>> +
>> +	if (netif_running(dev))
>> +		mvneta_stop(dev);
>> +	netif_device_detach(dev);
>> +	clk_disable_unprepare(pp->clk_bus);
>> +	clk_disable_unprepare(pp->clk);
>> +	return 0;
>> +}
>> +
>> +static int mvneta_resume(struct device *device)
>> +{
>> +	struct net_device *dev = dev_get_drvdata(device);
>> +	struct mvneta_port *pp = netdev_priv(dev);
>> +	int err;
>> +
>> +	clk_prepare_enable(pp->clk);
>> +	clk_prepare_enable(pp->clk_bus);
> we may miss the necessary registers setting in mvneta_bm_port_init() and
> mvneta_conf_mbus_windows(). those registers also need to be restored.
>
Done. Add them in patch v2.
>> +	mvneta_defaults_set(pp);
> before restore the default setting, is it safer to mvneta_port_disable()?
>
> Thanks,
> Jisheng
During suspend, mvneta_port_disable() has been executed as bellow path.
It seems it is not need to do mvneta_port_disable() during resume.

mvneta_suspend() -> mvneta_stop() -> mvneta_stop_dev() -> 
mvneta_port_disable()

Thanks,
Jane
>> +	err = mvneta_port_power_up(pp, pp->phy_interface);
>> +	if (err < 0) {
>> +		dev_err(device, "can't power up port\n");
>> +		return err;
>> +	}
>> +
>> +	if (pp->use_inband_status)
>> +		mvneta_fixed_link_update(pp, dev->phydev);
>> +
>> +	netif_device_attach(dev);
>> +	if (netif_running(dev))
>> +		mvneta_open(dev);
>> +	return 0;
>> +}
>> +#endif
>> +
>> +static const struct dev_pm_ops mvneta_pm_ops = {
>> +	SET_LATE_SYSTEM_SLEEP_PM_OPS(mvneta_suspend, mvneta_resume)
>> +};
>> +
>>   static const struct of_device_id mvneta_match[] = {
>>   	{ .compatible = "marvell,armada-370-neta" },
>>   	{ .compatible = "marvell,armada-xp-neta" },
>> @@ -4419,6 +4462,7 @@ static int mvneta_remove(struct platform_device *pdev)
>>   	.driver = {
>>   		.name = MVNETA_DRIVER_NAME,
>>   		.of_match_table = mvneta_match,
>> +		.pm = &mvneta_pm_ops,
>>   	},
>>   };
>>   
