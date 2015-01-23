From: roopa <roopa@cumulusnetworks.com>
Subject: Re: [PATCH net-next v3 2/5] swdevice: add new api to set and del
 bridge port attributes
Date: Fri, 23 Jan 2015 15:10:01 -0800
Message-ID: <54C2D4C9.5000400@cumulusnetworks.com>
References: <1421987606-10884-3-git-send-email-roopa@cumulusnetworks.com> <20150123104127.GC2065@nanopsycho.orion> <54C26FC1.70605@cumulusnetworks.com> <20150123160636.GM2065@nanopsycho.orion> <54C2CF1A.1080905@cumulusnetworks.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1; format=flowed
Content-Transfer-Encoding: 7bit
Cc: sfeldma@gmail.com, jhs@mojatatu.com, bcrl@kvack.org, tgraf@suug.ch,
	john.fastabend@gmail.com, stephen@networkplumber.org,
	vyasevic@redhat.com, ronen.arad@intel.com, netdev@vger.kernel.org,
	davem@davemloft.net, shm@cumulusnetworks.com,
	gospo@cumulusnetworks.com
To: Jiri Pirko <jiri@resnulli.us>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-pd0-f180.google.com ([209.85.192.180]:53680 "EHLO
	mail-pd0-f180.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1750960AbbAWXKD (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 23 Jan 2015 18:10:03 -0500
Received: by mail-pd0-f180.google.com with SMTP id ft15so229978pdb.11
        for <netdev@vger.kernel.org>; Fri, 23 Jan 2015 15:10:02 -0800 (PST)
In-Reply-To: <54C2CF1A.1080905@cumulusnetworks.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On 1/23/15, 2:45 PM, roopa wrote:
> On 1/23/15, 8:06 AM, Jiri Pirko wrote:
>> Fri, Jan 23, 2015 at 04:58:57PM CET, roopa@cumulusnetworks.com wrote:
>>> On 1/23/15, 2:41 AM, Jiri Pirko wrote:
>>>
>>> <snip..>
>>>> +
>>>> +/**
>>>> + *    netdev_switch_port_bridge_dellink - Notify switch device 
>>>> port of bridge
>>>> + *    attribute delete
>>>> + *
>>>> + *    @dev: port device
>>>> + *    @nlh: netlink msg with bridge port attributes
>>>> + *
>>>> + *    Notify switch device port of bridge port attribute delete
>>>> + */
>>>> +int netdev_switch_port_bridge_dellink(struct net_device *dev,
>>>> +                      struct nlmsghdr *nlh, u16 flags)
>>>> +{
>>>> +    const struct net_device_ops *ops = dev->netdev_ops;
>>>> +    struct net_device *lower_dev;
>>>> +    struct list_head *iter;
>>>> +    int ret = 0, err = 0;
>>>> +
>>>> +    if (!(dev->features & NETIF_F_HW_NETFUNC_OFFLOAD))
>>>> +        return err;
>>>> +
>>>> +    if (ops->ndo_bridge_dellink) {
>>>> +        WARN_ON(!ops->ndo_switch_parent_id_get);
>>>> +        return ops->ndo_bridge_dellink(dev, nlh, flags);
>>>> +    }
>>>> +
>>>> +    netdev_for_each_lower_dev(dev, lower_dev, iter) {
>>>> +        err = netdev_switch_port_bridge_dellink(lower_dev, nlh, 
>>>> flags);
>>>> +        if (err)
>>>> +            ret = err;
>>>> +    }
>>>> +
>>>> +    return ret;
>>>> +}
>>>> +EXPORT_SYMBOL(netdev_switch_port_bridge_dellink);
>>>> -- 
>>>> 1.7.10.4
>>>>
>>>> Is there any other place, other than bridge code, this functions are
>>>> suppored to be called from?
>>> No other place today. Its usually the master that implements
>>> ndo_bridge_setlink/dellink.
>>>
>>>> If not, which I consider likely, it would
>>>> make more sense to me to:
>>>>
>>>> - move netdev_for_each_lower_dev iterations directly to bridge code
>>>> - let the masters (bond, team, ..) implement ndo_bridge_*link and do
>>>>    the traversing there (can be in a form of pre-prepared default
>>>>    ndo callback (ndo_dflt_netdev_switch_port_bridge_*link)
>>> But, i am still not understanding why i would modify bond, team and 
>>> other
>>> slaves
>> Well, that is the usual way to propagate ndo calls. People are used to
>> this. It is visible right away in bonding/other code that is propagated
>> some ndo call to slaves. With your code, that is somehow hidden and only
>> dependent on NETIF_F_HW_NETFUNC_OFFLOAD flag.
>>
>> Note that there are only couple of "master drivers" (for this, most 
>> likely
>> only bond and team modifications are needed).
> ndo_bridge_setlink today is only implemented by drivers that implement 
> bridging function.
> So, having the bond and team driver implement it...seems odd.
>
> But if you insist, i am going to do just that.
A side note, I dont see any reason for ndo_bridge_setlink to be renamed 
to ndo_setlink. Because it seems to take the whole netlink msg anyways. 
It can be used to offload other link attributes besides bridging (vxlan 
and so on).
Any thoughts on that ?.
