From: Jane Li <jiel@marvell.com>
Subject: Re: [PATCH v2] net: mvneta: support suspend and resume
Date: Thu, 16 Mar 2017 15:13:42 +0800
Message-ID: <c4f690a2-09c5-99d4-c20c-3b10e0425dd4@marvell.com>
References: <1489634350-36991-1-git-send-email-jiel@marvell.com>
 <20170316113736.68d842f3@xhacker>
Mime-Version: 1.0
Content-Type: text/plain; charset="windows-1252"; format=flowed
Content-Transfer-Encoding: 7bit
Cc: <thomas.petazzoni@free-electrons.com>, <netdev@vger.kernel.org>,
        <linux-kernel@vger.kernel.org>
To: Jisheng Zhang <jszhang@marvell.com>
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <20170316113736.68d842f3@xhacker>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org



On 03/16/2017 11:37 AM, Jisheng Zhang wrote:
> On Thu, 16 Mar 2017 11:19:10 +0800 Jane Li wrote:
>
>> Add basic support for handling suspend and resume.
>>
>> Signed-off-by: Jane Li <jiel@marvell.com>
>> ---
>> Since v1:
>> - add mvneta_conf_mbus_windows() and mvneta_bm_port_init() in mvneta_resume()
>>
>>   drivers/net/ethernet/marvell/mvneta.c | 62 ++++++++++++++++++++++++++++++++---
>>   1 file changed, 58 insertions(+), 4 deletions(-)
>>
>> diff --git a/drivers/net/ethernet/marvell/mvneta.c b/drivers/net/ethernet/marvell/mvneta.c
>> index 61dd446..250017b 100644
>> --- a/drivers/net/ethernet/marvell/mvneta.c
>> +++ b/drivers/net/ethernet/marvell/mvneta.c
>> @@ -431,6 +431,7 @@ struct mvneta_port {
>>   	/* Flags for special SoC configurations */
>>   	bool neta_armada3700;
>>   	u16 rx_offset_correction;
>> +	const struct mbus_dram_target_info *dram_target_info;
>>   };
>>   
>>   /* The mvneta_tx_desc and mvneta_rx_desc structures describe the
>> @@ -4118,7 +4119,6 @@ static int mvneta_port_power_up(struct mvneta_port *pp, int phy_mode)
>>   /* Device initialization routine */
>>   static int mvneta_probe(struct platform_device *pdev)
>>   {
>> -	const struct mbus_dram_target_info *dram_target_info;
>>   	struct resource *res;
>>   	struct device_node *dn = pdev->dev.of_node;
>>   	struct device_node *phy_node;
>> @@ -4267,13 +4267,13 @@ static int mvneta_probe(struct platform_device *pdev)
>>   
>>   	pp->tx_csum_limit = tx_csum_limit;
>>   
>> -	dram_target_info = mv_mbus_dram_info();
>> +	pp->dram_target_info = mv_mbus_dram_info();
>>   	/* Armada3700 requires setting default configuration of Mbus
>>   	 * windows, however without using filled mbus_dram_target_info
>>   	 * structure.
>>   	 */
>> -	if (dram_target_info || pp->neta_armada3700)
>> -		mvneta_conf_mbus_windows(pp, dram_target_info);
>> +	if (pp->dram_target_info || pp->neta_armada3700)
>> +		mvneta_conf_mbus_windows(pp, pp->dram_target_info);
>>   
>>   	pp->tx_ring_size = MVNETA_MAX_TXD;
>>   	pp->rx_ring_size = MVNETA_MAX_RXD;
>> @@ -4405,6 +4405,59 @@ static int mvneta_remove(struct platform_device *pdev)
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
>> +	struct platform_device *pdev = to_platform_device(device);
>> +	struct net_device *dev = dev_get_drvdata(device);
>> +	struct mvneta_port *pp = netdev_priv(dev);
>> +	int err;
>> +
>> +	clk_prepare_enable(pp->clk);
>> +	clk_prepare_enable(pp->clk_bus);
>> +	if (pp->dram_target_info || pp->neta_armada3700)
>> +		mvneta_conf_mbus_windows(pp, pp->dram_target_info);
>> +	if (pp->bm_priv) {
>> +		err = mvneta_bm_port_init(pdev, pp);
>> +		if (err < 0) {
>> +			dev_info(&pdev->dev, "use SW buffer management\n");
>> +			pp->bm_priv = NULL;
>> +		}
>> +	}
>> +	mvneta_defaults_set(pp);
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
> we could make use of SIMPLE_DEV_PM_OPS to simplify the code
>
> Thanks
Done. Modify this in patch v3.

Thanks,
Jane
