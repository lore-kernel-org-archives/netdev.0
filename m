From: Roopa Prabhu <roopa@cumulusnetworks.com>
Subject: Re: [RFC PATCH net-next v2 1/1] net: Support for switch port configuration
Date: Thu, 18 Dec 2014 09:49:44 -0800
Message-ID: <549313B8.6050102@cumulusnetworks.com>
References: <C4896FB061E7DE4AAC93031BDCA044B104AD7B82@IRSMSX108.ger.corp.intel.com> <5492E85C.6010802@cumulusnetworks.com> <C4896FB061E7DE4AAC93031BDCA044B104AD9E53@IRSMSX108.ger.corp.intel.com> <5492EFC3.8030102@cumulusnetworks.com> <C4896FB061E7DE4AAC93031BDCA044B104ADA16F@IRSMSX108.ger.corp.intel.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1; format=flowed
Content-Transfer-Encoding: 7bit
Cc: "netdev@vger.kernel.org" <netdev@vger.kernel.org>,
	"Fastabend, John R" <john.r.fastabend@intel.com>,
	Thomas Graf <tgraf@suug.ch>, Jiri Pirko <jiri@resnulli.us>,
	"sfeldma@gmail.com" <sfeldma@gmail.com>,
	"linux-kernel@vger.kernel.org" <linux-kernel@vger.kernel.org>
To: "Varlese, Marco" <marco.varlese@intel.com>
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <C4896FB061E7DE4AAC93031BDCA044B104ADA16F@IRSMSX108.ger.corp.intel.com>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On 12/18/14, 9:25 AM, Varlese, Marco wrote:
>> -----Original Message-----
>> From: netdev-owner@vger.kernel.org [mailto:netdev-
>> owner@vger.kernel.org] On Behalf Of Roopa Prabhu
>> Sent: Thursday, December 18, 2014 3:16 PM
>> To: Varlese, Marco
>> Cc: netdev@vger.kernel.org; Fastabend, John R; Thomas Graf; Jiri Pirko;
>> sfeldma@gmail.com; linux-kernel@vger.kernel.org
>> Subject: Re: [RFC PATCH net-next v2 1/1] net: Support for switch port
>> configuration
>>
>> On 12/18/14, 6:55 AM, Varlese, Marco wrote:
>>>> -----Original Message-----
>>>> From: Roopa Prabhu [mailto:roopa@cumulusnetworks.com]
>>>> Sent: Thursday, December 18, 2014 2:45 PM
>>>> To: Varlese, Marco
>>>> Cc: netdev@vger.kernel.org; Fastabend, John R; Thomas Graf; Jiri
>>>> Pirko; sfeldma@gmail.com; linux-kernel@vger.kernel.org
>>>> Subject: Re: [RFC PATCH net-next v2 1/1] net: Support for switch port
>>>> configuration
>>>>
>>>> On 12/18/14, 3:29 AM, Varlese, Marco wrote:
>>>>> From: Marco Varlese <marco.varlese@intel.com>
>>>>>
>>>>> Switch hardware offers a list of attributes that are configurable on
>>>>> a per port basis.
>>>>> This patch provides a mechanism to configure switch ports by adding
>>>>> an NDO for setting specific values to specific attributes.
>>>>> There will be a separate patch that adds the "get" functionality via
>>>>> another NDO and another patch that extends iproute2 to call the two
>>>>> new NDOs.
>>>>>
>>>>> Signed-off-by: Marco Varlese <marco.varlese@intel.com>
>>>>> ---
>>>>>     include/linux/netdevice.h    |  5 ++++
>>>>>     include/uapi/linux/if_link.h | 15 ++++++++++++
>>>>>     net/core/rtnetlink.c         | 54
>>>> ++++++++++++++++++++++++++++++++++++++++++++
>>>>>     3 files changed, 74 insertions(+)
>>>>>
>>>>> diff --git a/include/linux/netdevice.h b/include/linux/netdevice.h
>>>>> index c31f74d..4881c7b 100644
>>>>> --- a/include/linux/netdevice.h
>>>>> +++ b/include/linux/netdevice.h
>>>>> @@ -1027,6 +1027,9 @@ typedef u16 (*select_queue_fallback_t)(struct
>>>> net_device *dev,
>>>>>      * int (*ndo_switch_port_stp_update)(struct net_device *dev, u8
>> state);
>>>>>      *	Called to notify switch device port of bridge port STP
>>>>>      *	state change.
>>>>> + * int (*ndo_switch_port_set_cfg)(struct net_device *dev,
>>>>> + *                                u32 attr, u64 value);
>>>>> + *	Called to set specific switch ports attributes.
>>>>>      */
>>>>>     struct net_device_ops {
>>>>>     	int			(*ndo_init)(struct net_device *dev);
>>>>> @@ -1185,6 +1188,8 @@ struct net_device_ops {
>>>>>     							    struct
>>>> netdev_phys_item_id *psid);
>>>>>     	int			(*ndo_switch_port_stp_update)(struct
>>>> net_device *dev,
>>>>>     							      u8 state);
>>>>> +	int			(*ndo_switch_port_set_cfg)(struct
>>>> net_device *dev,
>>>>> +							   u32 attr, u64 value);
>>>>>     #endif
>>>>>     };
>>>>>
>>>>> diff --git a/include/uapi/linux/if_link.h
>>>>> b/include/uapi/linux/if_link.h index f7d0d2d..19cb51a 100644
>>>>> --- a/include/uapi/linux/if_link.h
>>>>> +++ b/include/uapi/linux/if_link.h
>>>>> @@ -146,6 +146,7 @@ enum {
>>>>>     	IFLA_PHYS_PORT_ID,
>>>>>     	IFLA_CARRIER_CHANGES,
>>>>>     	IFLA_PHYS_SWITCH_ID,
>>>>> +	IFLA_SWITCH_PORT_CFG,
>>>>>     	__IFLA_MAX
>>>>>     };
>>>>>
>>>>> @@ -603,4 +604,18 @@ enum {
>>>>>
>>>>>     #define IFLA_HSR_MAX (__IFLA_HSR_MAX - 1)
>>>>>
>>>>> +/* Switch Port Attributes section */
>>>>> +
>>>>> +enum {
>>>>> +	IFLA_ATTR_UNSPEC,
>>>>> +	IFLA_ATTR_LEARNING,
>>>> Any reason you want learning here ?. This is covered as part  of the
>>>> bridge setlink attributes.
>>>>
>>> Yes, because the user may _not_ want to go through a bridge interface
>> necessarily.
>> But, the bridge setlink/getlink interface was changed to accommodate 'self'
>> for exactly such cases.
>> I kind of understand your case for the other attributes (these are per port
>> settings that switch asics provide).
>>
>> However, i don't understand the reason to pull in bridge attributes here.
>>
> Maybe, I am missing something so you might help. The learning attribute - in my case - it is like all other attributes: a port attribute (as you said, port settings that the switch provides per port).
> So, what I was saying is "why the user shall go through a bridge to configure the learning attribute"? From my perspective, it is as any other attribute and as such configurable on the port.

Thinking about this some more, i don't see why any of these attributes 
(except loopback. I dont understand the loopback attribute)
cant be part of the birdge port attributes.

With this we will end up adding l2 attributes in two places: the general 
link attributes and bridge attributes.

And since we have gone down the path of using ndo_bridge_setlink/getlink 
with 'self'....we should stick to that for all l2 attributes.

The idea of overloading ndo_bridge_set/getlink, was to have the same set 
of attributes but support both cases where the user wants to go through 
the bridge driver or directly to the switch port driver. So, you are not 
really going through the bridge driver if you use 'self' and 
ndo_bridge_setlink/getlink.





>>>>> +	IFLA_ATTR_LOOPBACK,
>>>>> +	IFLA_ATTR_BCAST_FLOODING,
>>>>> +	IFLA_ATTR_UCAST_FLOODING,
>>>>> +	IFLA_ATTR_MCAST_FLOODING,
>>>>> +	__IFLA_ATTR_MAX
>>>>> +};
>>>>> +
>>>>> +#define IFLA_ATTR_MAX (__IFLA_ATTR_MAX - 1)
>>>>> +
>>>>>     #endif /* _UAPI_LINUX_IF_LINK_H */ diff --git
>>>>> a/net/core/rtnetlink.c b/net/core/rtnetlink.c index
>>>>> eaa057f..c0d1c45 100644
>>>>> --- a/net/core/rtnetlink.c
>>>>> +++ b/net/core/rtnetlink.c
>>>>> @@ -1389,6 +1389,46 @@ static int validate_linkmsg(struct net_device
>>>> *dev, struct nlattr *tb[])
>>>>>     	return 0;
>>>>>     }
>>>>>
>>>>> +#ifdef CONFIG_NET_SWITCHDEV
>>>>> +static int do_setswcfg(struct net_device *dev, struct nlattr *attr) {
>>>>> +	int rem, err = -EINVAL;
>>>>> +	struct nlattr *v;
>>>>> +	const struct net_device_ops *ops = dev->netdev_ops;
>>>>> +
>>>>> +	nla_for_each_nested(v, attr, rem) {
>>>>> +		u32 op = nla_type(v);
>>>>> +		u64 value = 0;
>>>>> +
>>>>> +		switch (op) {
>>>>> +		case IFLA_ATTR_LEARNING:
>>>>> +		case IFLA_ATTR_LOOPBACK:
>>>>> +		case IFLA_ATTR_BCAST_FLOODING:
>>>>> +		case IFLA_ATTR_UCAST_FLOODING:
>>>>> +		case IFLA_ATTR_MCAST_FLOODING: {
>>>>> +			if (nla_len(v) < sizeof(value)) {
>>>>> +				err = -EINVAL;
>>>>> +				break;
>>>>> +			}
>>>>> +
>>>>> +			value = nla_get_u64(v);
>>>>> +			err = ops->ndo_switch_port_set_cfg(dev,
>>>>> +							   op,
>>>>> +							   value);
>>>>> +			break;
>>>>> +		}
>>>>> +		default:
>>>>> +			err = -EINVAL;
>>>>> +			break;
>>>>> +		}
>>>>> +		if (err)
>>>>> +			break;
>>>>> +	}
>>>>> +	return err;
>>>>> +}
>>>>> +
>>>>> +#endif
>>>>> +
>>>>>     static int do_setvfinfo(struct net_device *dev, struct nlattr *attr)
>>>>>     {
>>>>>     	int rem, err = -EINVAL;
>>>>> @@ -1740,6 +1780,20 @@ static int do_setlink(const struct sk_buff *skb,
>>>>>     			status |= DO_SETLINK_NOTIFY;
>>>>>     		}
>>>>>     	}
>>>>> +#ifdef CONFIG_NET_SWITCHDEV
>>>>> +	if (tb[IFLA_SWITCH_PORT_CFG]) {
>>>>> +		err = -EOPNOTSUPP;
>>>>> +		if (!ops->ndo_switch_port_set_cfg)
>>>>> +			goto errout;
>>>>> +		if (!ops->ndo_switch_parent_id_get)
>>>>> +			goto errout;
>>>>> +		err = do_setswcfg(dev, tb[IFLA_SWITCH_PORT_CFG]);
>>>>> +		if (err < 0)
>>>>> +			goto errout;
>>>>> +
>>>>> +		status |= DO_SETLINK_NOTIFY;
>>>>> +	}
>>>>> +#endif
>>>>>     	err = 0;
>>>>>
>>>>>     errout:
>>> --
>>> To unsubscribe from this list: send the line "unsubscribe netdev" in
>>> the body of a message to majordomo@vger.kernel.org More majordomo
>> info
>>> at  http://vger.kernel.org/majordomo-info.html
>> --
>> To unsubscribe from this list: send the line "unsubscribe netdev" in the body
>> of a message to majordomo@vger.kernel.org More majordomo info at
>> http://vger.kernel.org/majordomo-info.html
