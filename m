From: "Yankejian (Hackim Yim)" <yankejian@huawei.com>
Subject: Re: [PATCH net] net: hns: fix the bug about loopback
Date: Fri, 4 Mar 2016 11:46:46 +0800
Message-ID: <56D90526.6000003@huawei.com>
References: <1457006579-236479-1-git-send-email-yankejian@huawei.com>
 <1457012385.13244.243.camel@linux.intel.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, linuxarm@huawei.com, haifeng.wei@huawei.com,
 linux-arm-kernel@lists.infradead.org, linux-kernel@vger.kernel.org
To: Andy Shevchenko <andriy.shevchenko@linux.intel.com>, <davem@davemloft.net>,
 <yisen.zhuang@huawei.com>, <salil.mehta@huawei.com>,
 <liguozhu@huawei.com>, <huangdaode@hisilicon.com>, <arnd@arndb.de>,
 <andrew@lunn.ch>, <chenny.xu@huawei.com>, <ivecera@redhat.com>,
 <lisheng011@huawei.com>, <fengguang.wu@intel.com>
Return-path: <linux-arm-kernel-bounces+linux-arm-kernel=m.gmane.org@lists.infradead.org>
In-Reply-To: <1457012385.13244.243.camel@linux.intel.com>
List-Unsubscribe: <http://lists.infradead.org/mailman/options/linux-arm-kernel>,
 <mailto:linux-arm-kernel-request@lists.infradead.org?subject=unsubscribe>
List-Archive: <http://lists.infradead.org/pipermail/linux-arm-kernel/>
List-Post: <mailto:linux-arm-kernel@lists.infradead.org>
List-Help: <mailto:linux-arm-kernel-request@lists.infradead.org?subject=help>
List-Subscribe: <http://lists.infradead.org/mailman/listinfo/linux-arm-kernel>,
 <mailto:linux-arm-kernel-request@lists.infradead.org?subject=subscribe>
Sender: "linux-arm-kernel" <linux-arm-kernel-bounces@lists.infradead.org>
Errors-To: linux-arm-kernel-bounces+linux-arm-kernel=m.gmane.org@lists.infradead.org
List-Id: netdev.vger.kernel.org



On 2016/3/3 21:39, Andy Shevchenko wrote:
> On Thu, 2016-03-03 at 20:02 +0800, Kejian Yan wrote:
>> It will always be passed if the soc is tested the loopback cases.
>> This
>> patch will fix this bug.
> Few style related comments.
>
>> @@ -686,6 +690,10 @@ static int hns_ae_config_loopback(struct
>> hnae_handle *handle,
>>  	default:
>>  		ret = -EINVAL;
>>  	}
>> +
>> +	if (!ret)
>> +		hns_dsaf_set_inner_lb(mac_cb->dsaf_dev, mac_cb-
>>> mac_id, en);
>> +
>>  	return ret;
> if (ret)
>  return ret;
>
> whatever();
> return 0;

Hi, Andy,
Thanks for your suggestion. I think it should be return ret. the other case will be return the value from hardware.
it can tell callers if the operation is successful or not.

Best Regards

>>  }
> --- a/drivers/net/ethernet/hisilicon/hns/hns_dsaf_main.c
>> +++ b/drivers/net/ethernet/hisilicon/hns/hns_dsaf_main.c
>> @@ -230,6 +230,30 @@ static void hns_dsaf_mix_def_qid_cfg(struct
>> dsaf_device *dsaf_dev)
>>  	}
>>  }
>>  
>> +static void hns_dsaf_inner_qid_cfg(struct dsaf_device *dsaf_dev)
>> +{
>> +	u16 max_q_per_vf, max_vfn;
>> +	u32 q_id = 0, q_num_per_port;
>> +	u32 mac_id;
>> +
>> +	if (AE_IS_VER1(dsaf_dev->dsaf_ver))
>> +		return;
>> +
>> +	hns_rcb_get_queue_mode(dsaf_dev->dsaf_mode,
>> +			       HNS_DSAF_COMM_SERVICE_NW_IDX,
>> +			       &max_vfn, &max_q_per_vf);
>> +	q_num_per_port = max_vfn * max_q_per_vf;
>> +
>> +	for (mac_id = 0, q_id = 0; mac_id < DSAF_SERVICE_NW_NUM; 
> q_id is already assigned to 0. Get rid of either.

Thanks. I will fix it in next submit

>> mac_id++) {
>> +		dsaf_set_dev_field(dsaf_dev,
>> +				   DSAFV2_SERDES_LBK_0_REG + 0x4 *
>> mac_id,
>> +				   DSAFV2_SERDES_LBK_QID_M,
>> +				   DSAFV2_SERDES_LBK_QID_S,
>> +				   q_id);
>> +		q_id += q_num_per_port;
>> +	}
>> +}
>  
>> +void hns_dsaf_set_inner_lb(struct dsaf_device *dsaf_dev, u32 mac_id,
>> u32 en)
>> +{
>> +	if (AE_IS_VER1(dsaf_dev->dsaf_ver) ||
>> +	    dsaf_dev->mac_cb[mac_id].mac_type == HNAE_PORT_DEBUG)
>> +		return;
>> +
>> +	dsaf_set_dev_bit(dsaf_dev, DSAFV2_SERDES_LBK_0_REG + 0x4 *
>> mac_id,
> 0x4 -> 4 (it's about register width, right?)

Thanks. I will fix it in next submit

>> +			 DSAFV2_SERDES_LBK_EN_B, !!en);
>> +}
>>  #define PPEV2_CFG_RSS_TBL_4N3_S	24
>>  #define PPEV2_CFG_RSS_TBL_4N3_M	(((1UL << 5) - 1) <<
>> PPEV2_CFG_RSS_TBL_4N3_S)
>>  
>> +#define DSAFV2_SERDES_LBK_EN_B  8
>> +#define DSAFV2_SERDES_LBK_QID_S 0
>> +#define DSAFV2_SERDES_LBK_QID_M \
>> +	(((1UL << DSAFV2_SERDES_LBK_EN_B) - 1) <<
>> DSAFV2_SERDES_LBK_QID_S)
> Why not like above?
>
> #define DSAFV2_SERDES_LBK_QID_M	(((1UL << 8) - 1)
> << DSAFV2_SERDES_LBK_QID_S)

to keep the unifying style, i will fix it in next submit.

>> +static void __lb_fill_txt_skb_buff(struct net_device *ndev,
>> +				   struct sk_buff *skb)
>> +{
>> +	struct hns_nic_priv *priv = netdev_priv(ndev);
>> +	struct hnae_handle *h = priv->ae_handle;
>> +	u32 frame_size;
>> +
>> +	frame_size = skb->len;
>> +	memset(skb->data, 0xFF, frame_size);
>> +
>> +	if ((!AE_IS_VER1(priv->enet_ver)) &&
>> +	    (h->port_type == HNAE_PORT_SERVICE)) {
>> +		memcpy(skb->data, ndev->dev_addr, 6);
> ether_addr_copy() ?

ok, thanks.i will fix it in next submit.



>> +		skb->data[5] += 0x1f;
> This has to be explained.
>
>> +	}
>> +
>> +	frame_size &= ~1ul;
> And how 1ul is different to plain 1 here?

the bit width must be 32bit

>
>> +	memset(&skb->data[frame_size / 2], 0xAA, frame_size / 2 -
>> 1);
>> +	memset(&skb->data[frame_size / 2 + 10], 0xBE, frame_size / 2
>> - 11);
>> +	memset(&skb->data[frame_size / 2 + 12], 0xAF, frame_size / 2
>> - 13);
> Magic numbers have to be explained.
> Also, what is the logic to overwrite the data if frame_size is big
> enough?

the caller, who generates the frame, ensure that it will not be overwritten. it is only one caller in the system.

>> +}
>> +
