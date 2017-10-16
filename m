From: "Nambiar, Amritha" <amritha.nambiar@intel.com>
Subject: Re: [net-next 4/9] i40e: Enable 'channel' mode in mqprio for TC
 configs
Date: Mon, 16 Oct 2017 09:03:01 -0700
Message-ID: <4e06d67d-5eea-02ea-1ce2-993666e19b2e@intel.com>
References: <20171013215249.61286-1-jeffrey.t.kirsher@intel.com>
 <20171013215249.61286-5-jeffrey.t.kirsher@intel.com>
 <7ba989ca-ab23-1572-f125-a851f87ad05a@huawei.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=utf-8
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, nhorman@redhat.com, sassmann@redhat.com,
        jogreene@redhat.com
To: Yunsheng Lin <linyunsheng@huawei.com>,
        Jeff Kirsher <jeffrey.t.kirsher@intel.com>, davem@davemloft.net
Return-path: <netdev-owner@vger.kernel.org>
Received: from mga07.intel.com ([134.134.136.100]:50804 "EHLO mga07.intel.com"
        rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
        id S1752153AbdJPQDD (ORCPT <rfc822;netdev@vger.kernel.org>);
        Mon, 16 Oct 2017 12:03:03 -0400
In-Reply-To: <7ba989ca-ab23-1572-f125-a851f87ad05a@huawei.com>
Content-Language: en-US
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On 10/16/2017 1:53 AM, Yunsheng Lin wrote:
> Hi, Jeff
> 
> On 2017/10/14 5:52, Jeff Kirsher wrote:
>> From: Amritha Nambiar <amritha.nambiar@intel.com>
>>
>> The i40e driver is modified to enable the new mqprio hardware
>> offload mode and factor the TCs and queue configuration by
>> creating channel VSIs. In this mode, the priority to traffic
>> class mapping and the user specified queue ranges are used
>> to configure the traffic classes by setting the mode option to
>> 'channel'.
>>
>> Example:
>>   map 0 0 0 0 1 2 2 3 queues 2@0 2@2 1@4 1@5\
>>   hw 1 mode channel
>>
>> qdisc mqprio 8038: root  tc 4 map 0 0 0 0 1 2 2 3 0 0 0 0 0 0 0 0
>>              queues:(0:1) (2:3) (4:4) (5:5)
>>              mode:channel
>>              shaper:dcb
>>
>> The HW channels created are removed and all the queue configuration
>> is set to default when the qdisc is detached from the root of the
>> device.
>>
>> This patch also disables setting up channels via ethtool (ethtool -L)
>> when the TCs are configured using mqprio scheduler.
>>
>> The patch also limits setting ethtool Rx flow hash indirection
>> (ethtool -X eth0 equal N) to max queues configured via mqprio.
>> The Rx flow hash indirection input through ethtool should be
>> validated so that it is within in the queue range configured via
>> tc/mqprio. The bound checking is achieved by reporting the current
>> rss size to the kernel when queues are configured via mqprio.
>>
>> Example:
>>   map 0 0 0 1 0 2 3 0 queues 2@0 4@2 8@6 11@14\
>>   hw 1 mode channel
>>
>> Cannot set RX flow hash configuration: Invalid argument
>>
>> Signed-off-by: Amritha Nambiar <amritha.nambiar@intel.com>
>> Tested-by: Andrew Bowers <andrewx.bowers@intel.com>
>> Signed-off-by: Jeff Kirsher <jeffrey.t.kirsher@intel.com>
>> ---
>>  drivers/net/ethernet/intel/i40e/i40e.h         |   3 +
>>  drivers/net/ethernet/intel/i40e/i40e_ethtool.c |   8 +-
>>  drivers/net/ethernet/intel/i40e/i40e_main.c    | 457 +++++++++++++++++++------
>>  3 files changed, 362 insertions(+), 106 deletions(-)
>>
>> diff --git a/drivers/net/ethernet/intel/i40e/i40e.h b/drivers/net/ethernet/intel/i40e/i40e.h
>> index bde982541772..024c88474951 100644
>> --- a/drivers/net/ethernet/intel/i40e/i40e.h
>> +++ b/drivers/net/ethernet/intel/i40e/i40e.h
>> @@ -54,6 +54,7 @@
>>  #include <linux/clocksource.h>
>>  #include <linux/net_tstamp.h>
>>  #include <linux/ptp_clock_kernel.h>
>> +#include <net/pkt_cls.h>
>>  #include "i40e_type.h"
>>  #include "i40e_prototype.h"
>>  #include "i40e_client.h"
>> @@ -700,6 +701,7 @@ struct i40e_vsi {
>>  	enum i40e_vsi_type type;  /* VSI type, e.g., LAN, FCoE, etc */
>>  	s16 vf_id;		/* Virtual function ID for SRIOV VSIs */
>>  
>> +	struct tc_mqprio_qopt_offload mqprio_qopt; /* queue parameters */
>>  	struct i40e_tc_configuration tc_config;
>>  	struct i40e_aqc_vsi_properties_data info;
>>  
>> @@ -725,6 +727,7 @@ struct i40e_vsi {
>>  	u16 cnt_q_avail;	/* num of queues available for channel usage */
>>  	u16 orig_rss_size;
>>  	u16 current_rss_size;
>> +	bool reconfig_rss;
>>  
>>  	u16 next_base_queue;	/* next queue to be used for channel setup */
>>  
>> diff --git a/drivers/net/ethernet/intel/i40e/i40e_ethtool.c b/drivers/net/ethernet/intel/i40e/i40e_ethtool.c
>> index afd3ca8d9851..72d5f2cdf419 100644
>> --- a/drivers/net/ethernet/intel/i40e/i40e_ethtool.c
>> +++ b/drivers/net/ethernet/intel/i40e/i40e_ethtool.c
>> @@ -2652,7 +2652,7 @@ static int i40e_get_rxnfc(struct net_device *netdev, struct ethtool_rxnfc *cmd,
>>  
>>  	switch (cmd->cmd) {
>>  	case ETHTOOL_GRXRINGS:
>> -		cmd->data = vsi->num_queue_pairs;
>> +		cmd->data = vsi->rss_size;
>>  		ret = 0;
>>  		break;
>>  	case ETHTOOL_GRXFH:
>> @@ -3897,6 +3897,12 @@ static int i40e_set_channels(struct net_device *dev,
>>  	if (vsi->type != I40E_VSI_MAIN)
>>  		return -EINVAL;
>>  
>> +	/* We do not support setting channels via ethtool when TCs are
>> +	 * configured through mqprio
>> +	 */
>> +	if (pf->flags & I40E_FLAG_TC_MQPRIO)
>> +		return -EINVAL;
>> +
>>  	/* verify they are not requesting separate vectors */
>>  	if (!count || ch->rx_count || ch->tx_count)
>>  		return -EINVAL;
>> diff --git a/drivers/net/ethernet/intel/i40e/i40e_main.c b/drivers/net/ethernet/intel/i40e/i40e_main.c
>> index e23105bee6d1..e803aa1552c6 100644
>> --- a/drivers/net/ethernet/intel/i40e/i40e_main.c
>> +++ b/drivers/net/ethernet/intel/i40e/i40e_main.c
>> @@ -1588,6 +1588,170 @@ static int i40e_set_mac(struct net_device *netdev, void *p)
>>  	return 0;
>>  }
>>  
>> +/**
>> + * i40e_config_rss_aq - Prepare for RSS using AQ commands
>> + * @vsi: vsi structure
>> + * @seed: RSS hash seed
>> + **/
> 
> [...]
> 
>> + * i40e_vsi_set_default_tc_config - set default values for tc configuration
>> + * @vsi: the VSI being configured
>> + **/
>> +static void i40e_vsi_set_default_tc_config(struct i40e_vsi *vsi)
>> +{
>> +	u16 qcount;
>> +	int i;
>> +
>> +	/* Only TC0 is enabled */
>> +	vsi->tc_config.numtc = 1;
>> +	vsi->tc_config.enabled_tc = 1;
>> +	qcount = min_t(int, vsi->alloc_queue_pairs,
>> +		       i40e_pf_get_max_q_per_tc(vsi->back));
>> +	for (i = 0; i < I40E_MAX_TRAFFIC_CLASS; i++) {
>> +		/* For the TC that is not enabled set the offset to to default
>> +		 * queue and allocate one queue for the given TC.
>> +		 */
>> +		vsi->tc_config.tc_info[i].qoffset = 0;
>> +		if (i == 0)
>> +			vsi->tc_config.tc_info[i].qcount = qcount;
>> +		else
>> +			vsi->tc_config.tc_info[i].qcount = 1;
>> +		vsi->tc_config.tc_info[i].netdev_tc = 0;
>> +	}
>> +}
>> +
>>  /**
>>   * i40e_setup_tc - configure multiple traffic classes
>>   * @netdev: net device to configure
>> - * @tc: number of traffic classes to enable
>> + * @type_data: tc offload data
>>   **/
>> -static int i40e_setup_tc(struct net_device *netdev, u8 tc)
>> +static int i40e_setup_tc(struct net_device *netdev, void *type_data)
>>  {
>> +	struct tc_mqprio_qopt_offload *mqprio_qopt = type_data;
>>  	struct i40e_netdev_priv *np = netdev_priv(netdev);
>>  	struct i40e_vsi *vsi = np->vsi;
>>  	struct i40e_pf *pf = vsi->back;
>> -	u8 enabled_tc = 0;
>> +	u8 enabled_tc = 0, num_tc, hw;
>> +	bool need_reset = false;
>>  	int ret = -EINVAL;
>> +	u16 mode;
>>  	int i;
>>  
>> -	/* Check if DCB enabled to continue */
>> -	if (!(pf->flags & I40E_FLAG_DCB_ENABLED)) {
>> -		netdev_info(netdev, "DCB is not enabled for adapter\n");
>> -		goto exit;
>> +	num_tc = mqprio_qopt->qopt.num_tc;
>> +	hw = mqprio_qopt->qopt.hw;
>> +	mode = mqprio_qopt->mode;
>> +	if (!hw) {
> 
> When stack call the ndo_setup_tc, then qopt.hw is always non-zero, Can you
> tell me why you need to check for this?

This needs to be checked here because when the qdisc is detached from
root of the device, i.e. 'tc qdisc del dev <interface>', the 'mqprio
destroy' flow calls ndo_setup_tc with the offload values zeroed out for
proper clean up.

-Amritha

> 
> Thanks,
> Yunsheng Lin
> 
>> +		pf->flags &= ~I40E_FLAG_TC_MQPRIO;
>> +		memcpy(&vsi->mqprio_qopt, mqprio_qopt, sizeof(*mqprio_qopt));
>> +		goto config_tc;
>>  	}
>>  
>>  	/* Check if MFP enabled */
>>  	if (pf->flags & I40E_FLAG_MFP_ENABLED) {
>> -		netdev_info(netdev, "Configuring TC not supported in MFP mode\n");
>> -		goto exit;
>> +		netdev_info(netdev,
>> +			    "Configuring TC not supported in MFP mode\n");
>> +		return ret;
>>  	}
>> +	switch (mode) {
>> +	case TC_MQPRIO_MODE_DCB:
>> +		pf->flags &= ~I40E_FLAG_TC_MQPRIO;
>>  
>> -	/* Check whether tc count is within enabled limit */
>> -	if (tc > i40e_pf_get_num_tc(pf)) {
>> -		netdev_info(netdev, "TC count greater than enabled on link for adapter\n");
>> -		goto exit;
>> +		/* Check if DCB enabled to continue */
>> +		if (!(pf->flags & I40E_FLAG_DCB_ENABLED)) {
>> +			netdev_info(netdev,
>> +				    "DCB is not enabled for adapter\n");
>> +			return ret;
>> +		}
>> +
>> +		/* Check whether tc count is within enabled limit */
>> +		if (num_tc > i40e_pf_get_num_tc(pf)) {
>> +			netdev_info(netdev,
>> +				    "TC count greater than enabled on link for adapter\n");
>> +			return ret;
>> +		}
>> +		break;
>> +	case TC_MQPRIO_MODE_CHANNEL:
>> +		if (pf->flags & I40E_FLAG_DCB_ENABLED) {
>> +			netdev_info(netdev,
>> +				    "Full offload of TC Mqprio options is not supported when DCB is enabled\n");
>> +			return ret;
>> +		}
>> +		if (!(pf->flags & I40E_FLAG_MSIX_ENABLED))
>> +			return ret;
>> +		ret = i40e_validate_mqprio_qopt(vsi, mqprio_qopt);
>> +		if (ret)
>> +			return ret;
>> +		memcpy(&vsi->mqprio_qopt, mqprio_qopt,
>> +		       sizeof(*mqprio_qopt));
>> +		pf->flags |= I40E_FLAG_TC_MQPRIO;
>> +		pf->flags &= ~I40E_FLAG_DCB_ENABLED;
>> +		break;
>> +	default:
>> +		return -EINVAL;
>>  	}
>>  
>> +config_tc:
>>  	/* Generate TC map for number of tc requested */
>> -	for (i = 0; i < tc; i++)
>> +	for (i = 0; i < num_tc; i++)
>>  		enabled_tc |= BIT(i);
>>  
>>  	/* Requesting same TC configuration as already enabled */
>> -	if (enabled_tc == vsi->tc_config.enabled_tc)
>> +	if (enabled_tc == vsi->tc_config.enabled_tc &&
>> +	    mode != TC_MQPRIO_MODE_CHANNEL)
>>  		return 0;
>>  
>>  	/* Quiesce VSI queues */
>>  	i40e_quiesce_vsi(vsi);
>>  
>> +	if (!hw && !(pf->flags & I40E_FLAG_TC_MQPRIO))
>> +		i40e_remove_queue_channels(vsi);
>> +
>>  	/* Configure VSI for enabled TCs */
>>  	ret = i40e_vsi_config_tc(vsi, enabled_tc);
>>  	if (ret) {
>>  		netdev_info(netdev, "Failed configuring TC for VSI seid=%d\n",
>>  			    vsi->seid);
>> +		need_reset = true;
>>  		goto exit;
>>  	}
>>  
>> @@ -6272,11 +6595,18 @@ static int i40e_setup_tc(struct net_device *netdev, u8 tc)
>>  		if (ret) {
>>  			netdev_info(netdev,
>>  				    "Failed configuring queue channels\n");
>> +			need_reset = true;
>>  			goto exit;
>>  		}
>>  	}
>>  
>>  exit:
>> +	/* Reset the configuration data to defaults, only TC0 is enabled */
>> +	if (need_reset) {
>> +		i40e_vsi_set_default_tc_config(vsi);
>> +		need_reset = false;
>> +	}
>> +
>>  	/* Unquiesce VSI */
>>  	i40e_unquiesce_vsi(vsi);
>>  	return ret;
>> @@ -6285,14 +6615,10 @@ static int i40e_setup_tc(struct net_device *netdev, u8 tc)
>>  static int __i40e_setup_tc(struct net_device *netdev, enum tc_setup_type type,
>>  			   void *type_data)
>>  {
>> -	struct tc_mqprio_qopt *mqprio = type_data;
>> -
>>  	if (type != TC_SETUP_MQPRIO)
>>  		return -EOPNOTSUPP;
>>  
>> -	mqprio->hw = TC_MQPRIO_HW_OFFLOAD_TCS;
>> -
>> -	return i40e_setup_tc(netdev, mqprio->num_tc);
>> +	return i40e_setup_tc(netdev, type_data);
>>  }
>>  
>>  /**
>> @@ -9153,45 +9479,6 @@ static int i40e_setup_misc_vector(struct i40e_pf *pf)
>>  	return err;
>>  }
>>  
>> -/**
>> - * i40e_config_rss_aq - Prepare for RSS using AQ commands
>> - * @vsi: vsi structure
>> - * @seed: RSS hash seed
>> - **/
>> -static int i40e_config_rss_aq(struct i40e_vsi *vsi, const u8 *seed,
>> -			      u8 *lut, u16 lut_size)
>> -{
>> -	struct i40e_pf *pf = vsi->back;
>> -	struct i40e_hw *hw = &pf->hw;
>> -	int ret = 0;
>> -
>> -	if (seed) {
>> -		struct i40e_aqc_get_set_rss_key_data *seed_dw =
>> -			(struct i40e_aqc_get_set_rss_key_data *)seed;
>> -		ret = i40e_aq_set_rss_key(hw, vsi->id, seed_dw);
>> -		if (ret) {
>> -			dev_info(&pf->pdev->dev,
>> -				 "Cannot set RSS key, err %s aq_err %s\n",
>> -				 i40e_stat_str(hw, ret),
>> -				 i40e_aq_str(hw, hw->aq.asq_last_status));
>> -			return ret;
>> -		}
>> -	}
>> -	if (lut) {
>> -		bool pf_lut = vsi->type == I40E_VSI_MAIN ? true : false;
>> -
>> -		ret = i40e_aq_set_rss_lut(hw, vsi->id, pf_lut, lut, lut_size);
>> -		if (ret) {
>> -			dev_info(&pf->pdev->dev,
>> -				 "Cannot set RSS lut, err %s aq_err %s\n",
>> -				 i40e_stat_str(hw, ret),
>> -				 i40e_aq_str(hw, hw->aq.asq_last_status));
>> -			return ret;
>> -		}
>> -	}
>> -	return ret;
>> -}
>> -
>>  /**
>>   * i40e_get_rss_aq - Get RSS keys and lut by using AQ commands
>>   * @vsi: Pointer to vsi structure
>> @@ -9238,46 +9525,6 @@ static int i40e_get_rss_aq(struct i40e_vsi *vsi, const u8 *seed,
>>  	return ret;
>>  }
>>  
>> -/**
>> - * i40e_vsi_config_rss - Prepare for VSI(VMDq) RSS if used
>> - * @vsi: VSI structure
>> - **/
>> -static int i40e_vsi_config_rss(struct i40e_vsi *vsi)
>> -{
>> -	u8 seed[I40E_HKEY_ARRAY_SIZE];
>> -	struct i40e_pf *pf = vsi->back;
>> -	u8 *lut;
>> -	int ret;
>> -
>> -	if (!(pf->hw_features & I40E_HW_RSS_AQ_CAPABLE))
>> -		return 0;
>> -
>> -	if (!vsi->rss_size)
>> -		vsi->rss_size = min_t(int, pf->alloc_rss_size,
>> -				      vsi->num_queue_pairs);
>> -	if (!vsi->rss_size)
>> -		return -EINVAL;
>> -
>> -	lut = kzalloc(vsi->rss_table_size, GFP_KERNEL);
>> -	if (!lut)
>> -		return -ENOMEM;
>> -	/* Use the user configured hash keys and lookup table if there is one,
>> -	 * otherwise use default
>> -	 */
>> -	if (vsi->rss_lut_user)
>> -		memcpy(lut, vsi->rss_lut_user, vsi->rss_table_size);
>> -	else
>> -		i40e_fill_rss_lut(pf, lut, vsi->rss_table_size, vsi->rss_size);
>> -	if (vsi->rss_hkey_user)
>> -		memcpy(seed, vsi->rss_hkey_user, I40E_HKEY_ARRAY_SIZE);
>> -	else
>> -		netdev_rss_key_fill((void *)seed, I40E_HKEY_ARRAY_SIZE);
>> -	ret = i40e_config_rss_aq(vsi, seed, lut, vsi->rss_table_size);
>> -	kfree(lut);
>> -
>> -	return ret;
>> -}
>> -
>>  /**
>>   * i40e_config_rss_reg - Configure RSS keys and lut by writing registers
>>   * @vsi: Pointer to vsi structure
>>
> 
