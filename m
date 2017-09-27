From: Yunsheng Lin <linyunsheng@huawei.com>
Subject: Re: [PATCH v2 net-next 10/10] net: hns3: Add mqprio support when
 interacting with network stack
Date: Wed, 27 Sep 2017 08:51:44 +0800
Message-ID: <7eb4e0c0-f60c-ed0d-d75f-8cd5d4bc437d@huawei.com>
References: <1506392718-50463-1-git-send-email-linyunsheng@huawei.com>
 <1506392718-50463-11-git-send-email-linyunsheng@huawei.com>
 <AM0PR0502MB3683C922A7D87D3E1F64B93EBF7B0@AM0PR0502MB3683.eurprd05.prod.outlook.com>
 <3fe662df-a216-4966-863c-d98555ef3ed2@huawei.com>
 <AM0PR0502MB3683FFF227DA3D136AA63987BF7B0@AM0PR0502MB3683.eurprd05.prod.outlook.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="utf-8"
Content-Transfer-Encoding: 7bit
Cc: "huangdaode@hisilicon.com" <huangdaode@hisilicon.com>,
        "xuwei5@hisilicon.com" <xuwei5@hisilicon.com>,
        "liguozhu@hisilicon.com" <liguozhu@hisilicon.com>,
        "Yisen.Zhuang@huawei.com" <Yisen.Zhuang@huawei.com>,
        "gabriele.paoloni@huawei.com" <gabriele.paoloni@huawei.com>,
        "john.garry@huawei.com" <john.garry@huawei.com>,
        "linuxarm@huawei.com" <linuxarm@huawei.com>,
        "salil.mehta@huawei.com" <salil.mehta@huawei.com>,
        "lipeng321@huawei.com" <lipeng321@huawei.com>,
        "netdev@vger.kernel.org" <netdev@vger.kernel.org>,
        "linux-kernel@vger.kernel.org" <linux-kernel@vger.kernel.org>,
        "davem@davemloft.net" <davem@davemloft.net>
To: Yuval Mintz <yuvalm@mellanox.com>
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <AM0PR0502MB3683FFF227DA3D136AA63987BF7B0@AM0PR0502MB3683.eurprd05.prod.outlook.com>
Content-Language: en-US
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Hi, Yuval

On 2017/9/26 20:29, Yuval Mintz wrote:
>> Hi, Yuval
>>
>> On 2017/9/26 14:43, Yuval Mintz wrote:
>>>> When using tc qdisc to configure DCB parameter, dcb_ops->setup_tc
>>>> is used to tell hclge_dcb module to do the setup.
>>>
>>> While this might be a step in the right direction, this causes an inconsistency
>>> in user experience - Some [well, most] vendors didn't allow the mqprio
>>> priority mapping to affect DCB, instead relying on the dcbnl functionality
>>> to control that configuration.
>>>
>>> A couple of options to consider:
>>>   - Perhaps said logic shouldn't be contained inside the driver but rather
>>>      in mqprio logic itself. I.e., rely on DCBNL functionality [if available] from
>>>      within mqprio and try changing the configuration.
>>
>> In net/dcb/dcbnl.c
>> dcbnl_ieee_set already call dcbnl_ieee_notify to notify the user space
>> configuration has changed, does this dcbnl_ieee_notify function do the
>> job for us? I am not sure if lldpad has registered for this notifition.
> 
> Not that familiar with the dcbnl calls; Shouldn't dcbnl_setall be called to
> make the configuration apply [or is that only for ieee]?

dcbnl_setall is for cee to make the configuration apply.
ieee does not have the apply operation.

> Regardless, don't know if it makes sense to assume user-application would
> fix the qdisc configuration by notification while dcbnl logic in kernel could have
> done that instead.
> 
>> As you suggested below, can we add a new TC_MQPRIO_HW_OFFLOAD_
>> value to
>> reflect that the configuration is needed to be changed by dcbnl_ieee_set
>> (perhaps some other function) in dcbnl?
>> Do you think it is feasible?
> 
> Either I'm miseading your answer or we think of it from 2 opposite end.
> I was thinking that the new offloaded flag would indicate to the underlying
> driver that it's expected to offload the prio mapping [as part of DCB].
> If the driver would be incapable of that it would refuse the offload.
> User would then have to explicitly request that the qdisc offload.


Adding a new offloaded flag to indicate that mqpri is using a hardware offload
shared by dcbnl seems a good idea.
As I do not know how the idea go with other, I will drop the mqprio support in
this patch, and try to add the mqprio support as you suggested in the next
patchset.

Thanks again for the lengthly reply.

> 
>>
>>
>>>   - Add a new TC_MQPRIO_HW_OFFLOAD_ value to explicitly reflect user
>>>      request to allow this configuration to affect DCB.
>>>
>>>> When using lldptool to configure DCB parameter, hclge_dcb module
>>>> call the client_ops->setup_tc to tell network stack which queue
>>>> and priority is using for specific tc.
>>>
>>> You're basically bypassing the mqprio logic.
>>> Since you're configuring the prio->queue mapping from DCB flow,
>>> you'll get an mqprio-like behavior [meaning a transmitted packet
>>> would reach a transmission queue associated with its priority] even
>>> if device wasn't grated with an mqprio qdisc.
>>> Why should your user even use mqprio? What benefit does he get from it?
>>>
>>> ...
>>>
>>>> +static int hns3_nic_set_real_num_queue(struct net_device *netdev)
>>>> +{
>>>> +	struct hns3_nic_priv *priv = netdev_priv(netdev);
>>>> +	struct hnae3_handle *h = priv->ae_handle;
>>>> +	struct hnae3_knic_private_info *kinfo = &h->kinfo;
>>>> +	unsigned int queue_size = kinfo->rss_size * kinfo->num_tc;
>>>> +	int ret;
>>>> +
>>>> +	ret = netif_set_real_num_tx_queues(netdev, queue_size);
>>>> +	if (ret) {
>>>> +		netdev_err(netdev,
>>>> +			   "netif_set_real_num_tx_queues fail, ret=%d!\n",
>>>> +			   ret);
>>>> +		return ret;
>>>> +	}
>>>> +
>>>> +	ret = netif_set_real_num_rx_queues(netdev, queue_size);
>>>
>>> I don't think you're changing the driver behavior, but why are you setting
>>> the real number of rx queues based on the number of TCs?
>>> Do you actually open (TC x RSS) Rx queues?
>>>
>>> .
>>>
> 
