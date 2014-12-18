From: "Arad, Ronen" <ronen.arad@intel.com>
Subject: RE: [RFC PATCH net-next v2 1/1] net: Support for switch port
 configuration
Date: Thu, 18 Dec 2014 17:17:08 +0000
Message-ID: <E4CD12F19ABA0C4D8729E087A761DC3505DC072A@ORSMSX101.amr.corp.intel.com>
References: <C4896FB061E7DE4AAC93031BDCA044B104AD7B82@IRSMSX108.ger.corp.intel.com>
 <5492E85C.6010802@cumulusnetworks.com>
 <C4896FB061E7DE4AAC93031BDCA044B104AD9E53@IRSMSX108.ger.corp.intel.com>
 <E4CD12F19ABA0C4D8729E087A761DC3505DBA430@ORSMSX101.amr.corp.intel.com>
 <5492FD51.5030503@intel.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 8BIT
Cc: Thomas Graf <tgraf@suug.ch>, Jiri Pirko <jiri@resnulli.us>,
	"sfeldma@gmail.com" <sfeldma@gmail.com>,
	"linux-kernel@vger.kernel.org" <linux-kernel@vger.kernel.org>
To: "Fastabend, John R" <john.r.fastabend@intel.com>,
	"Varlese, Marco" <marco.varlese@intel.com>,
	Roopa Prabhu <roopa@cumulusnetworks.com>,
	"netdev@vger.kernel.org" <netdev@vger.kernel.org>
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <5492FD51.5030503@intel.com>
Content-Language: en-US
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org



> -----Original Message-----
> From: Fastabend, John R
> Sent: Thursday, December 18, 2014 6:14 PM
> To: Arad, Ronen; Varlese, Marco; Roopa Prabhu; netdev@vger.kernel.org
> Cc: Thomas Graf; Jiri Pirko; sfeldma@gmail.com; linux-
> kernel@vger.kernel.org
> Subject: Re: [RFC PATCH net-next v2 1/1] net: Support for switch port
> configuration
> 
> On 12/18/2014 07:47 AM, Arad, Ronen wrote:
> >
> >
> >> -----Original Message-----
> >> From: netdev-owner@vger.kernel.org [mailto:netdev-
> >> owner@vger.kernel.org] On Behalf Of Varlese, Marco
> >> Sent: Thursday, December 18, 2014 4:56 PM
> >> To: Roopa Prabhu
> >> Cc: netdev@vger.kernel.org; Fastabend, John R; Thomas Graf; Jiri
> >> Pirko; sfeldma@gmail.com; linux-kernel@vger.kernel.org
> >> Subject: RE: [RFC PATCH net-next v2 1/1] net: Support for switch port
> >> configuration
> >>
> >>> -----Original Message-----
> >>> From: Roopa Prabhu [mailto:roopa@cumulusnetworks.com]
> >>> Sent: Thursday, December 18, 2014 2:45 PM
> >>> To: Varlese, Marco
> >>> Cc: netdev@vger.kernel.org; Fastabend, John R; Thomas Graf; Jiri
> >>> Pirko; sfeldma@gmail.com; linux-kernel@vger.kernel.org
> >>> Subject: Re: [RFC PATCH net-next v2 1/1] net: Support for switch
> >>> port configuration
> >>>
> >>> On 12/18/14, 3:29 AM, Varlese, Marco wrote:
> >>>> From: Marco Varlese <marco.varlese@intel.com>
> >>>>
> >>>> Switch hardware offers a list of attributes that are configurable
> >>>> on a per port basis.
> >>>> This patch provides a mechanism to configure switch ports by adding
> >>>> an NDO for setting specific values to specific attributes.
> >>>> There will be a separate patch that adds the "get" functionality
> >>>> via another NDO and another patch that extends iproute2 to call the
> >>>> two new NDOs.
> >>>>
> >>>> Signed-off-by: Marco Varlese <marco.varlese@intel.com>
> >>>> ---
> >>>>   include/linux/netdevice.h    |  5 ++++
> >>>>   include/uapi/linux/if_link.h | 15 ++++++++++++
> >>>>   net/core/rtnetlink.c         | 54
> >>> ++++++++++++++++++++++++++++++++++++++++++++
> >>>>   3 files changed, 74 insertions(+)
> >>>>
> >>>> diff --git a/include/linux/netdevice.h b/include/linux/netdevice.h
> >>>> index c31f74d..4881c7b 100644
> >>>> --- a/include/linux/netdevice.h
> >>>> +++ b/include/linux/netdevice.h
> >>>> @@ -1027,6 +1027,9 @@ typedef u16
> (*select_queue_fallback_t)(struct
> >>> net_device *dev,
> >>>>    * int (*ndo_switch_port_stp_update)(struct net_device *dev, u8
> state);
> >>>>    *	Called to notify switch device port of bridge port STP
> >>>>    *	state change.
> >>>> + * int (*ndo_switch_port_set_cfg)(struct net_device *dev,
> >>>> + *                                u32 attr, u64 value);
> >>>> + *	Called to set specific switch ports attributes.
> >>>>    */
> >>>>   struct net_device_ops {
> >>>>   	int			(*ndo_init)(struct net_device *dev);
> >>>> @@ -1185,6 +1188,8 @@ struct net_device_ops {
> >>>>   							    struct
> >>> netdev_phys_item_id *psid);
> >>>>   	int			(*ndo_switch_port_stp_update)(struct
> >>> net_device *dev,
> >>>>   							      u8 state);
> >>>> +	int			(*ndo_switch_port_set_cfg)(struct
> >>> net_device *dev,
> >>>> +							   u32 attr, u64 value);
> >>>>   #endif
> >>>>   };
> >>>>
> >>>> diff --git a/include/uapi/linux/if_link.h
> >>>> b/include/uapi/linux/if_link.h index f7d0d2d..19cb51a 100644
> >>>> --- a/include/uapi/linux/if_link.h
> >>>> +++ b/include/uapi/linux/if_link.h
> >>>> @@ -146,6 +146,7 @@ enum {
> >>>>   	IFLA_PHYS_PORT_ID,
> >>>>   	IFLA_CARRIER_CHANGES,
> >>>>   	IFLA_PHYS_SWITCH_ID,
> >>>> +	IFLA_SWITCH_PORT_CFG,
> >>>>   	__IFLA_MAX
> >>>>   };
> >>>>
> >>>> @@ -603,4 +604,18 @@ enum {
> >>>>
> >>>>   #define IFLA_HSR_MAX (__IFLA_HSR_MAX - 1)
> >>>>
> >>>> +/* Switch Port Attributes section */
> >>>> +
> >>>> +enum {
> >>>> +	IFLA_ATTR_UNSPEC,
> >>>> +	IFLA_ATTR_LEARNING,
> >>> Any reason you want learning here ?. This is covered as part  of the
> >>> bridge setlink attributes.
> >>>
> >>
> >> Yes, because the user may _not_ want to go through a bridge interface
> >> necessarily.
> >
> > Some bridge attributes or more accurately bridge port attributes overlap
> with port attributes.
> > IFLA_BRPORT_LEARNING from IFLA_PROTINFO and
> BRIDGE_VLAN_INFO_PVID flag
> > of IFLA_BRIDGE_VLAN_INFO from IFLA_AF_SPEC are two examples where
> > bridge port properties might have to be mapped to a common or driver
> > specific port attribute.
> 
> You've lost me a bit.
> 
> > Switch port driver that works without and explicit bridge device has
> > to implement the bridge NDO's ndo_bridge_setlink/ndo_bridge_dellink.
> > It could take care of mapping such attributes from the bridge netlink
> > message to either driver-specific port attribute of to an explicit one
> > (assuming IFLA_ATTR_LEARNING would be accepted). For example the
> > driver could process the bridge learning information from the protinfo
> > as such:
> 
> still lost unfortunately.
> 
> So you want to enable learning on a port by port basis? Then we also need to
> define how the two bits interact.
> 
> 	switch_learning + port_learning = port in learning mode
> 	!switch_learning + port_learning = port not in learning mode?
> 	etc.
>

This is a valid issue. I don't believe there is a way for the switch port driver to figure out whether an AF_BRIDGE RTM_SETLINK message was intended to the bridge or to the specific port targeted. It could only make such decision separately for each attribute configured.
When an explicit bridge instance is present, directing the netlink message to the bridge with SELF flag implies bridge property; Directing it to a bridge port netdev with MASTER implies bridge port property. 
 
> Do bridges and users actually enable learning on a per port basis?


My understanding is that learning configuration is already on a port by port basis. That's what I see in the rocker driver. The LERNING and LEARNING_SYNC are stored in the brport_flags of a rocker_port structure.
My statement was that synchronization is needed between bridge port configuration and equivalent switch port attribute.
The switch port driver implementing bridge setlink NDOs has to take care of such synchronization.
 
> 
> > int sw_driver_br_setlink(struct net_device *dev, struct nlmsghdr *nlh)
> > {
> >         struct nlattr *protinfo;
> >         protinfo = nlmsg_find_attr(nlh, sizeof(struct ifinfomsg),
> >                                    IFLA_PROTINFO);
> >         if (protinfo) {
> >                 struct nlattr *attr;
> >                 attr = nla_find_nested(protinfo, IFLA_BRPORT_LEARNING);
> >                 if (attr) {
> >                         if (nla_len(attr) >= sizeof(u8)) {
> >                                 if (nla_get_u8(attr))
> >                                         brport_flags |= BR_LEARNING;
> >                                 else
> >                                         brport_flags &= ~BR_LEARNING;
> >                         }
> >                 }
> >                 /*
> >                  * Map bridge port attributes to driver-specific port attributes
> >                  */
> >         }
> >         return 0;
> > }
> >
> >>
> >>>> +	IFLA_ATTR_LOOPBACK,
> >>>> +	IFLA_ATTR_BCAST_FLOODING,
> >>>> +	IFLA_ATTR_UCAST_FLOODING,
> >>>> +	IFLA_ATTR_MCAST_FLOODING,
> >>>> +	__IFLA_ATTR_MAX
> >>>> +};
> >>>> +
> >>>> +#define IFLA_ATTR_MAX (__IFLA_ATTR_MAX - 1)
> >>>> +
> >>>>   #endif /* _UAPI_LINUX_IF_LINK_H */ diff --git
> >>>> a/net/core/rtnetlink.c b/net/core/rtnetlink.c index
> >>>> eaa057f..c0d1c45 100644
> >>>> --- a/net/core/rtnetlink.c
> >>>> +++ b/net/core/rtnetlink.c
> >>>> @@ -1389,6 +1389,46 @@ static int validate_linkmsg(struct
> >>>> net_device
> >>> *dev, struct nlattr *tb[])
> >>>>   	return 0;
> >>>>   }
> >>>>
> >>>> +#ifdef CONFIG_NET_SWITCHDEV
> >>>> +static int do_setswcfg(struct net_device *dev, struct nlattr *attr) {
> >>>> +	int rem, err = -EINVAL;
> >>>> +	struct nlattr *v;
> >>>> +	const struct net_device_ops *ops = dev->netdev_ops;
> >>>> +
> >>>> +	nla_for_each_nested(v, attr, rem) {
> >>>> +		u32 op = nla_type(v);
> >>>> +		u64 value = 0;
> >>>> +
> >>>> +		switch (op) {
> >>>> +		case IFLA_ATTR_LEARNING:
> >>>> +		case IFLA_ATTR_LOOPBACK:
> >>>> +		case IFLA_ATTR_BCAST_FLOODING:
> >>>> +		case IFLA_ATTR_UCAST_FLOODING:
> >>>> +		case IFLA_ATTR_MCAST_FLOODING: {
> >>>> +			if (nla_len(v) < sizeof(value)) {
> >>>> +				err = -EINVAL;
> >>>> +				break;
> >>>> +			}
> >>>> +
> >>>> +			value = nla_get_u64(v);
> >>>> +			err = ops->ndo_switch_port_set_cfg(dev,
> >>>> +							   op,
> >>>> +							   value);
> >>>> +			break;
> >>>> +		}
> >>>> +		default:
> >>>> +			err = -EINVAL;
> >>>> +			break;
> >>>> +		}
> >>>> +		if (err)
> >>>> +			break;
> >>>> +	}
> >>>> +	return err;
> >>>> +}
> >>>> +
> >>>> +#endif
> >>>> +
> >>>>   static int do_setvfinfo(struct net_device *dev, struct nlattr *attr)
> >>>>   {
> >>>>   	int rem, err = -EINVAL;
> >>>> @@ -1740,6 +1780,20 @@ static int do_setlink(const struct sk_buff
> *skb,
> >>>>   			status |= DO_SETLINK_NOTIFY;
> >>>>   		}
> >>>>   	}
> >>>> +#ifdef CONFIG_NET_SWITCHDEV
> >>>> +	if (tb[IFLA_SWITCH_PORT_CFG]) {
> >>>> +		err = -EOPNOTSUPP;
> >>>> +		if (!ops->ndo_switch_port_set_cfg)
> >>>> +			goto errout;
> >>>> +		if (!ops->ndo_switch_parent_id_get)
> >>>> +			goto errout;
> >>>> +		err = do_setswcfg(dev, tb[IFLA_SWITCH_PORT_CFG]);
> >>>> +		if (err < 0)
> >>>> +			goto errout;
> >>>> +
> >>>> +		status |= DO_SETLINK_NOTIFY;
> >>>> +	}
> >>>> +#endif
> >>>>   	err = 0;
> >>>>
> >>>>   errout:
> >>
> >> --
> >> To unsubscribe from this list: send the line "unsubscribe netdev" in
> >> the body of a message to majordomo@vger.kernel.org More majordomo
> >> info at http://vger.kernel.org/majordomo-info.html
