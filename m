From: Roopa Prabhu <roopa@cumulusnetworks.com>
Subject: Re: [PATCH net-next v2 2/4] swdevice: add new api to set and del
 bridge port attributes
Date: Thu, 11 Dec 2014 10:27:32 -0800
Message-ID: <5489E214.4080708@cumulusnetworks.com>
References: <1418202320-19491-3-git-send-email-roopa@cumulusnetworks.com> <20141210093755.GB1863@nanopsycho.orion> <5489CBBA.7050302@cumulusnetworks.com> <20141211171145.GG1912@nanopsycho.orion> <5489DB73.1080808@cumulusnetworks.com> <20141211180743.GA2010@nanopsycho.orion>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1; format=flowed
Content-Transfer-Encoding: 7bit
Cc: sfeldma@gmail.com, jhs@mojatatu.com, bcrl@kvack.org, tgraf@suug.ch,
	john.fastabend@gmail.com, stephen@networkplumber.org,
	linville@tuxdriver.com, vyasevic@redhat.com,
	netdev@vger.kernel.org, davem@davemloft.net,
	shm@cumulusnetworks.com, gospo@cumulusnetworks.com
To: Jiri Pirko <jiri@resnulli.us>
Return-path: <netdev-owner@vger.kernel.org>
Received: from ext3.cumulusnetworks.com ([198.211.106.187]:41430 "EHLO
	ext3.cumulusnetworks.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1755889AbaLKS1i (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 11 Dec 2014 13:27:38 -0500
In-Reply-To: <20141211180743.GA2010@nanopsycho.orion>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On 12/11/14, 10:07 AM, Jiri Pirko wrote:
> Thu, Dec 11, 2014 at 06:59:15PM CET, roopa@cumulusnetworks.com wrote:
>> On 12/11/14, 9:11 AM, Jiri Pirko wrote:
>>> Thu, Dec 11, 2014 at 05:52:10PM CET, roopa@cumulusnetworks.com wrote:
>>>> On 12/10/14, 1:37 AM, Jiri Pirko wrote:
>>>>> Wed, Dec 10, 2014 at 10:05:18AM CET, roopa@cumulusnetworks.com wrote:
>>>>>> From: Roopa Prabhu <roopa@cumulusnetworks.com>
>>>>>>
>>>>>> This patch adds two new api's netdev_switch_port_bridge_setlink
>>>>>> and netdev_switch_port_bridge_dellink to offload bridge port attributes
>>>>>> to switch asic
>>>>>>
>>>>>> (The names of the apis look odd with 'switch_port_bridge',
>>>>>> but am more inclined to change the prefix of the api to something else.
>>>>>> Will take any suggestions).
>>>>>>
>>>>>> The api's look at the NETIF_F_HW_NETFUNC_OFFLOAD feature flag to
>>>>>> pass bridge port attributes to the port device.
>>>>>>
>>>>>> If the device has the NETIF_F_HW_NETFUNC_OFFLOAD, but does not support
>>>>>> the bridge port attribute offload ndo, call bridge port attribute ndo's on
>>>>>> the lowerdevs if supported. This is one way to pass bridge port attributes
>>>>>> through stacked netdevs (example when bridge port is a bond and bond slaves
>>>>>> are switch ports).
>>>>>>
>>>>>> Signed-off-by: Roopa Prabhu <roopa@cumulusnetworks.com>
>>>>>> ---
>>>>>> include/net/switchdev.h   |    5 +++-
>>>>>> net/switchdev/switchdev.c |   70 +++++++++++++++++++++++++++++++++++++++++++++
>>>>>> 2 files changed, 74 insertions(+), 1 deletion(-)
>>>>>>
>>>>>> diff --git a/include/net/switchdev.h b/include/net/switchdev.h
>>>>>> index 8a6d164..22676b6 100644
>>>>>> --- a/include/net/switchdev.h
>>>>>> +++ b/include/net/switchdev.h
>>>>>> @@ -17,7 +17,10 @@
>>>>>> int netdev_switch_parent_id_get(struct net_device *dev,
>>>>>> 				struct netdev_phys_item_id *psid);
>>>>>> int netdev_switch_port_stp_update(struct net_device *dev, u8 state);
>>>>>> -
>>>>>> +int netdev_switch_port_bridge_setlink(struct net_device *dev,
>>>>>> +				struct nlmsghdr *nlh, u16 flags);
>>>>>> +int netdev_switch_port_bridge_dellink(struct net_device *dev,
>>>>>> +				struct nlmsghdr *nlh, u16 flags);
>>>>>> #else
>>>>>>
>>>>>> static inline int netdev_switch_parent_id_get(struct net_device *dev,
>>>>>> diff --git a/net/switchdev/switchdev.c b/net/switchdev/switchdev.c
>>>>>> index d162b21..62317e1 100644
>>>>>> --- a/net/switchdev/switchdev.c
>>>>>> +++ b/net/switchdev/switchdev.c
>>>>>> @@ -50,3 +50,73 @@ int netdev_switch_port_stp_update(struct net_device *dev, u8 state)
>>>>>> 	return ops->ndo_switch_port_stp_update(dev, state);
>>>>>> }
>>>>>> EXPORT_SYMBOL(netdev_switch_port_stp_update);
>>>>>> +
>>>>>> +/**
>>>>>> + *	netdev_switch_port_bridge_setlink - Notify switch device port of bridge
>>>>>> + *	port attributes
>>>>>> + *
>>>>>> + *	@dev: port device
>>>>>> + *	@nlh: netlink msg with bridge port attributes
>>>>>> + *
>>>>>> + *	Notify switch device port of bridge port attributes
>>>>>> + */
>>>>>> +int netdev_switch_port_bridge_setlink(struct net_device *dev,
>>>>>> +									  struct nlmsghdr *nlh, u16 flags)
>>>>>> +{
>>>>>> +	const struct net_device_ops *ops = dev->netdev_ops;
>>>>>> +	struct net_device *lower_dev;
>>>>>> +	struct list_head *iter;
>>>>>> +	int ret = 0, err = 0;
>>>>>> +
>>>>>> +	if (!(dev->features & NETIF_F_HW_NETFUNC_OFFLOAD))
>>>>>> +		return err;
>>>>>> +
>>>>>> +	if (ops->ndo_bridge_setlink) {
>>>>>> +	    WARN_ON(!ops->ndo_switch_parent_id_get);
>>>>>> +	    return ops->ndo_bridge_setlink(dev, nlh, flags);
>>>>> 	You have to change ndo_bridge_setlink in netdevice.h first.
>>>>> 	Otherwise when only this patch is applied (during bisection)
>>>>> 	this won't compile.
>>>> ack, will fix it and keep that in mind next time.
>>>>>> +	}
>>>>>> +
>>>>>> +	netdev_for_each_lower_dev(dev, lower_dev, iter) {
>>>>> 	I do not understand why to iterate over lower devices. At this
>>>>> 	stage we don't know a thing about this upper or its lowers. Let
>>>>> 	the uppers (/masters) to decide if this needs to be propagated
>>>>> 	or not.
>>>> Jiri, In the stacked devices case, there is no way to propagate the bridge
>>>> port attributes to switch device driver today (vlan and other bridge port
>>>> attributes). Can you tell me if there is a way ?. no, ndo_vlan* ndo's are not
>>>> useful here. Nor we should go and implement ndo_bridge_setlink* in all
>>>> devices that can be bridge ports.
>>> Hmm. I just think that is cleaner to implement ndo_bridge_setlink in
>>> bonding for example and let it propagate the the call to slaves.
>> No, that will require bridge attribute support in all drivers. And that is no
>> good.
> Not all drivers, just all masters which want to support this. Like bond,
> team, macvlan etc. That would be the same as for
> ndo_vlan_rx_add_vid/ndo_vlan_rx_kill_vid/ndo_change_mtu etc. I do not
> see any problem in that. It is much much clearer over big hammer iterate
> over lowers in my opinion.

You cannot avoid the lowerdev iteration in any case.
If you added it in the individual drivers: bond, macvlan and other 
drivers will all have to do the same thing.
ie Call bridge setlink on lowerdevs.
My patch avoids the need to modify these drivers. Besides it does this 
only when the OFFLOAD flag is set.

It will not stop at adding the ndo_bridge_setlink to bond/macvlan etc. 
It will be all other ndo_ops we will need for switch asics.
It will be l3 tomorrow, if the route is through a bond (But at that 
point, we may end up having to introduce switch device instead of going 
to the port. Lets see).

Today this patch introduces an abstract way to get to the switch driver 
by getting to the slave switch port (And only when the OFFLOAD flag is set).


>
>
>>> Let every "upper" to handle ndo_bridge_setlink their way. Sometimes it
>>> might not make sense to propagate to "lowers".
>> This does not really propagate to lowers. It is just trying to get to a
>> switch port and from there to the switch driver.
>> Example, bond driver does not need to care if its a bridge port. It will
>> simply pass the call to its slave which
>> might be a switch port.
>>
>> bond driver does not care if its a bridge port. But the switch driver cares,
>> because it knows that the bond was created with switch ports.
>>
>>
>>>> And this allows a switch driver to receive these callbacks if it has marked
>>>> the switch port with an offload flag. Your way of using the switch port to
>>>> get to the switch driver does not help in these cases.
>>> I do not follow how this is related to this case (stacked layout).
>>>
>>>> The other option is to use the 'switch device (not port)' to get to the
>>>> switch driver.
>>> That would not help this case (stacked layout) I believe.
>>>
>>>
>>>> This patch shows that you can still do this with the ndo ops.
>>>>>> +		err = netdev_switch_port_bridge_setlink(lower_dev, nlh, flags);
>>>>>> +		if (err)
>>>>>> +			ret = err;
>>>>>> +    }
>>>>>   ^^^^^ Indent is off. This should be catched by scripts/checkpatch.pl.
>>>>>
>>>>>> +
>>>>>> +	return ret;
>>>>>> +}
>>>>>> +EXPORT_SYMBOL(netdev_switch_port_bridge_setlink);
>>>>>> +
>>>>>> +/**
>>>>>> + *	netdev_switch_port_bridge_dellink - Notify switch device port of bridge
>>>>>> + *	attribute delete
>>>>>> + *
>>>>>> + *	@dev: port device
>>>>>> + *	@nlh: netlink msg with bridge port attributes
>>>>>> + *
>>>>>> + *	Notify switch device port of bridge port attribute delete
>>>>>> + */
>>>>>> +int netdev_switch_port_bridge_dellink(struct net_device *dev,
>>>>>> +									  struct nlmsghdr *nlh, u16 flags)
>>>>>> +{
>>>>>> +	const struct net_device_ops *ops = dev->netdev_ops;
>>>>>> +	struct net_device *lower_dev;
>>>>>> +	struct list_head *iter;
>>>>>> +	int ret = 0, err = 0;
>>>>>> +
>>>>>> +	if (!(dev->features & NETIF_F_HW_NETFUNC_OFFLOAD))
>>>>>> +		return err;
>>>>>> +
>>>>>> +	if (ops->ndo_bridge_dellink) {
>>>>>> +		WARN_ON(!ops->ndo_switch_parent_id_get);
>>>>>> +		return ops->ndo_bridge_dellink(dev, nlh, flags);
>>>>>> +	}
>>>>>> +
>>>>>> +	netdev_for_each_lower_dev(dev, lower_dev, iter) {
>>>>>> +		err = netdev_switch_port_bridge_dellink(lower_dev, nlh, flags);
>>>>>> +		if (err)
>>>>>> +			ret = err;
>>>>>> +	}
>>>>>> +
>>>>>> +	return ret;
>>>>>> +}
>>>>>> +EXPORT_SYMBOL(netdev_switch_port_bridge_dellink);
>>>>>> -- 
>>>>>> 1.7.10.4
>>>>>>
>>> --
>>> To unsubscribe from this list: send the line "unsubscribe netdev" in
>>> the body of a message to majordomo@vger.kernel.org
>>> More majordomo info at  http://vger.kernel.org/majordomo-info.html
