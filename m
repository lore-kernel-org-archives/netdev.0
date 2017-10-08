From: Nikolay Aleksandrov <nikolay@cumulusnetworks.com>
Subject: Re: [patch net-next 1/6] net: bridge: Use the MDB_RTR_TYPE_TEMP on
 bridge device too
Date: Sun, 8 Oct 2017 12:42:19 +0300
Message-ID: <52b8e2d1-ce5a-f0d5-cfa7-b483bf223f78@cumulusnetworks.com>
References: <20171005103642.1414-1-jiri@resnulli.us>
 <20171005103642.1414-2-jiri@resnulli.us>
 <b9cfcf9f-bb3a-6649-5b6a-39be0a957550@cumulusnetworks.com>
 <b782b23c-b85f-680d-0e91-5de3a3d436f6@mellanox.com>
 <c282f731-2d8e-a30d-b36d-d407cf7ccfe8@cumulusnetworks.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=windows-1252
Content-Transfer-Encoding: 7bit
Cc: davem@davemloft.net, idosch@mellanox.com, nogahf@mellanox.com,
        mlxsw@mellanox.com, ivecera@redhat.com, andrew@lunn.ch,
        stephen@networkplumber.org, nbd@nbd.name, roopa@cumulusnetworks.com
To: Yotam Gigi <yotamg@mellanox.com>, Jiri Pirko <jiri@resnulli.us>,
        netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-wm0-f50.google.com ([74.125.82.50]:45951 "EHLO
        mail-wm0-f50.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1751463AbdJHJmX (ORCPT
        <rfc822;netdev@vger.kernel.org>); Sun, 8 Oct 2017 05:42:23 -0400
Received: by mail-wm0-f50.google.com with SMTP id q124so15766842wmb.0
        for <netdev@vger.kernel.org>; Sun, 08 Oct 2017 02:42:22 -0700 (PDT)
In-Reply-To: <c282f731-2d8e-a30d-b36d-d407cf7ccfe8@cumulusnetworks.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On 08/10/17 12:39, Nikolay Aleksandrov wrote:
> On 08/10/17 08:23, Yotam Gigi wrote:
>> On 10/05/2017 03:09 PM, Nikolay Aleksandrov wrote:
>>> On 05/10/17 13:36, Jiri Pirko wrote:
>>>> From: Yotam Gigi <yotamg@mellanox.com>
>>>>
>>>> Every bridge port is in one of four mcast router port states:
>>>>  - MDB_RTR_TYPE_PERM - the port is set by the user to be an mrouter port
>>>>    regardless of IGMP queries.
>>>>  - MDB_RTR_TYPE_DISABLED - the port is set by the user to not be an mrouter
>>>>    port regardless of IGMP queries.
>>>>  - MDB_RTR_TYPE_TEMP - the port is set by the user to be in mcast router
>>>>    learning state, but currently it is not an mrouter port as no IGMP query
>>>>    has been received by it for the last multicast_querier_interval.
>>>>  - MDB_RTR_TYPE_TEMP_QUERY - the port is set by the user to be in mcast
>>>>    router learning state, and currently it is an mrouter port due to an
>>>>    IGMP query that has been received by it during the passed
>>>>    multicast_querier_interval.
>>> I think you got the last two partially mixed up, MDB_RTR_TYPE_TEMP marks the port as a router
>>> regardless if there were any igmp queries, while TYPE_TEMP_QUERY means it's in learning
>>> state. It is the timer (armed vs not) that defines if currently the port is a router
>>> when one of the TEMP/TEMP_QUERY are set. In the _TEMP case it is always armed as it
>>> is refreshed by user or igmp queries which was the point of that mode.
>>> So this means in br_multicast_router() just check for the timer_pending or perm mode.
>>
>>
>> As much as I tried to make this clear, it seems like I failed :)
>>
>> The 4 states I described are currently the "bridged port" states, not the
>> "bridge device" state. A bridged port has these 4 states, all can be set by the
>> user, while the bridge device only uses 3 of these states. This patch makes the
>> bridge device use the 4 states too. I thought it makes sense.
> 
> (disclaimer: this is all about bridge ports, not bridge device)
> Right, I'll try to explain again: _TEMP always marks the port as a mcast router,
> it does not put it into just learning state waiting for an igmp query and it can
> be refreshed by either a query or the user again setting the port in _TEMP.
> While _TEMP_QUERY puts the port in learning state waiting for a query to become
> a router, and _TEMP downgrades to _TEMP_QUERY if it expires.
> 
> Does that make it clearer ?
> 
> so for _TEMP you say:
>>>>  - MDB_RTR_TYPE_TEMP - the port is set by the user to be in mcast router
>>>>    learning state, but currently it is not an mrouter port as no IGMP query
>>>>    has been received by it for the last multicast_querier_interval.
> 
> which is not the case, it is always a router when that mode is set on a port.
> Same for _TEMP_QUERY.

Err, sorry by same I meant it is not correct, not that the _TEMP definition is the same.
Need to get coffee :-)

> 
>>
>> The first paragraph describes the current states of a bridged port, and the
>> second one explains the difference between bridged port and bridge device. I
>> will (try to) make it clearer if we agree on resending this patch.
>>
>> Is it clearer now?
>>
>>
>>>
>>> In the port code you have the following transitions:
>>>  _TEMP -> TEMP_QUERY (on timer fire or user-set val, port becomes learning only)
>>>  _TEMP -> _TEMP (noop on user refresh or igmp query, timer refreshes)
>>>  _TEMP_QUERY -> _TEMP_QUERY (on igmp query the timer is armed, port becomes router)
>>>
>>> you never have _TEMP_QUERY -> _TEMP, which you're using here to denote the timer
>>> getting armed and the bridge becoming a router.
>>
>>
>> I am not sure I got this one. I do address that: when an IGMP query is recieved
>> and the current state is _TEMP_QUERY, I arm the timer and set the state to
>> _TEMP. I marked that place on the patch, so you can see below.
>>
> 
> Exactly, there is no such transition for the ports. I tried to say that you're using
> the router type to distinguish between when a query is received and it is just learning.
> I get that you need to do so, but that deviates from how ports are handled, thus I
> suggested to use the timer state instead and drop the _TEMP for bridge device altogether.
> If it's possible then the patch will be much simpler and you will not need the hacks
> to hide the state from user-space which is the part I really don't like.
> 
>>
>>>
>>>> The bridge device (brX) itself can also be configured by the user to be
>>>> either fixed, disabled or learning mrouter port states, but currently there
>>>> is no distinction between the MDB_RTR_TYPE_TEMP_QUERY and MDB_RTR_TYPE_TEMP
>>>> in the bridge internal state. Due to that, when an IGMP query is received,
>>>> it is not straightforward to tell whether it changes the bridge device
>>>> mrouter port status or not.
>>> But before this patch the bridge device could not get that set.
>>>
>>>> Further patches in this patch-set will introduce notifications upon the
>>>> bridge device mrouter port state. In order to prevent resending bridge
>>>> mrouter notification when it is not needed, such distinction is necessary.
>>>>
>>> Granted the bridge device hasn't got a way to clearly distinguish the transitions
>>> without the chance for a race and if using the timer one could get an unnecessary
>>
>> Is there a race condition?
>>
> 
> With this state - no, if you try to use the timer state though there might be
> an extra notification as I've explained below, that's why I asked if it would be
> a problem. I think it is worth looking into using the timer state because it will
> remove a lot of the hacks for hiding the state needed in this patch.
> 
>>> notification but that seems like a corner case when the timer fires exactly at the
>>> same time as the igmp query is received. Can't it be handled by just checking if
>>> the new state is different in the notification receiver ?
>>> If it can't and is a problem then I'd prefer to add a new boolean to denote that
>>> router on/off transition rather than doing this.
>>>
>>>> Hence, add the distinction between MDB_RTR_TYPE_TEMP and
>>>> MDB_RTR_TYPE_TEMP_QUERY states for the bridge device, similarly to any
>>>> other bridge port.
>>>>
>>> This does not add proper MDB_RTR_TYPE_TEMP support for the bridge device
>>> but seems to abuse it to distinguish the timer state, and changes
>>> the meaning of MDB_RTR_TYPE_TEMP. Can't you just use the timer instead ?
>>> I think it will simplify the set and avoid all of this.
>>>
>>>> In order to not break the current kernel-user API, don't propagate the new
>>>> state to the user and use it only in the bridge internal state. Thus, if
>>>> the user reads (either via sysfs or netlink) the bridge device mrouter
>>>> state, he will get the MDB_RTR_TYPE_TEMP_QUERY state even if the current
>>>> bridge state is MDB_RTR_TYPE_TEMP.
>>>>
>>>> Signed-off-by: Yotam Gigi <yotamg@mellanox.com>
>>>> Reviewed-by: Nogah Frankel <nogahf@mellanox.com>
>>>> Signed-off-by: Jiri Pirko <jiri@mellanox.com>
>>>> ---
>>>>  net/bridge/br_multicast.c | 25 +++++++++++++++++++++----
>>>>  net/bridge/br_netlink.c   |  3 ++-
>>>>  net/bridge/br_private.h   | 13 ++++++++++---
>>>>  net/bridge/br_sysfs_br.c  |  3 ++-
>>>>  4 files changed, 35 insertions(+), 9 deletions(-)
>>>>
>>>> diff --git a/net/bridge/br_multicast.c b/net/bridge/br_multicast.c
>>>> index 8dc5c8d..b86307b 100644
>>>> --- a/net/bridge/br_multicast.c
>>>> +++ b/net/bridge/br_multicast.c
>>>> @@ -861,6 +861,17 @@ static void br_multicast_router_expired(unsigned long data)
>>>>  
>>>>  static void br_multicast_local_router_expired(unsigned long data)
>>>>  {
>>>> +	struct net_bridge *br = (struct net_bridge *) data;
>>>> +
>>>> +	spin_lock(&br->multicast_lock);
>>>> +	if (br->multicast_router == MDB_RTR_TYPE_DISABLED ||
>>>> +	    br->multicast_router == MDB_RTR_TYPE_PERM ||
>>>> +	    timer_pending(&br->multicast_router_timer))
>>>> +		goto out;
>>>> +
>>>> +	br->multicast_router = MDB_RTR_TYPE_TEMP_QUERY;
>>>> +out:
>>>> +	spin_unlock(&br->multicast_lock);
>>>>  }
>>>>  
>>>>  static void br_multicast_querier_expired(struct net_bridge *br,
>>>> @@ -1364,9 +1375,12 @@ static void br_multicast_mark_router(struct net_bridge *br,
>>>>  	unsigned long now = jiffies;
>>>>  
>>>>  	if (!port) {
>>>> -		if (br->multicast_router == MDB_RTR_TYPE_TEMP_QUERY)
>>>> +		if (br->multicast_router == MDB_RTR_TYPE_TEMP_QUERY ||
>>>> +		    br->multicast_router == MDB_RTR_TYPE_TEMP) {
>>>>  			mod_timer(&br->multicast_router_timer,
>>>>  				  now + br->multicast_querier_interval);
>>>> +			br->multicast_router = MDB_RTR_TYPE_TEMP;
>>>> +		}
>>
>>
>> These are the transitions:
>> _TEMP -> _TEMP_QUERY
>> _TEMP_QUERY -> _TEMP_QUERY
> 
> You clearly always set multicast_router to _TEMP, where did you see a transition
> _TEMP_QUERY -> _TEMP_QUERY or _TEMP -> _TEMP_QUERY ?
> All transitions are -> _TEMP, because you use it to differentiate between learning
> state and when a query was received. Maybe we have different definition for 
> a transition :-)
> 
>>
>> In both transitions the timer is armed.
>>
>>
>>>>  		return;
>>>>  	}
>>>>  
>>>> @@ -1952,7 +1966,7 @@ void br_multicast_init(struct net_bridge *br)
>>>>  
>>>>  	spin_lock_init(&br->multicast_lock);
>>>>  	setup_timer(&br->multicast_router_timer,
>>>> -		    br_multicast_local_router_expired, 0);
>>>> +		    br_multicast_local_router_expired, (unsigned long)br);
>>>>  	setup_timer(&br->ip4_other_query.timer,
>>>>  		    br_ip4_multicast_querier_expired, (unsigned long)br);
>>>>  	setup_timer(&br->ip4_own_query.timer, br_ip4_multicast_query_expired,
>>>> @@ -2043,11 +2057,14 @@ int br_multicast_set_router(struct net_bridge *br, unsigned long val)
>>>>  	case MDB_RTR_TYPE_DISABLED:
>>>>  	case MDB_RTR_TYPE_PERM:
>>>>  		del_timer(&br->multicast_router_timer);
>>>> -		/* fall through */
>>>> -	case MDB_RTR_TYPE_TEMP_QUERY:
>>>>  		br->multicast_router = val;
>>>>  		err = 0;
>>>>  		break;
>>>> +	case MDB_RTR_TYPE_TEMP_QUERY:
>>>> +		if (br->multicast_router != MDB_RTR_TYPE_TEMP)
>>>> +			br->multicast_router = val;
>>>> +		err = 0;
>>>> +		break;
>>>>  	}
>>>>  
>>>>  	spin_unlock_bh(&br->multicast_lock);
>>>> diff --git a/net/bridge/br_netlink.c b/net/bridge/br_netlink.c
>>>> index dea88a2..cee5016 100644
>>>> --- a/net/bridge/br_netlink.c
>>>> +++ b/net/bridge/br_netlink.c
>>>> @@ -1357,7 +1357,8 @@ static int br_fill_info(struct sk_buff *skb, const struct net_device *brdev)
>>>>  		return -EMSGSIZE;
>>>>  #endif
>>>>  #ifdef CONFIG_BRIDGE_IGMP_SNOOPING
>>>> -	if (nla_put_u8(skb, IFLA_BR_MCAST_ROUTER, br->multicast_router) ||
>>>> +	if (nla_put_u8(skb, IFLA_BR_MCAST_ROUTER,
>>>> +		       br_multicast_router_translate(br->multicast_router)) ||
>>>>  	    nla_put_u8(skb, IFLA_BR_MCAST_SNOOPING, !br->multicast_disabled) ||
>>>>  	    nla_put_u8(skb, IFLA_BR_MCAST_QUERY_USE_IFADDR,
>>>>  		       br->multicast_query_use_ifaddr) ||
>>>> diff --git a/net/bridge/br_private.h b/net/bridge/br_private.h
>>>> index ab4df24..e6e3fec 100644
>>>> --- a/net/bridge/br_private.h
>>>> +++ b/net/bridge/br_private.h
>>>> @@ -649,9 +649,8 @@ void br_multicast_get_stats(const struct net_bridge *br,
>>>>  
>>>>  static inline bool br_multicast_is_router(struct net_bridge *br)
>>>>  {
>>>> -	return br->multicast_router == 2 ||
>>>> -	       (br->multicast_router == 1 &&
>>>> -		timer_pending(&br->multicast_router_timer));
>>>> +	return br->multicast_router == MDB_RTR_TYPE_PERM ||
>>>> +	       br->multicast_router == MDB_RTR_TYPE_TEMP;
>>>>  }
>>>>  
>>>>  static inline bool
>>>> @@ -790,6 +789,14 @@ static inline int br_multicast_igmp_type(const struct sk_buff *skb)
>>>>  }
>>>>  #endif
>>>>  
>>>> +static inline unsigned char
>>> u8
>>>
>>>> +br_multicast_router_translate(unsigned char multicast_router)
>>> u8, if need be change the type of the struct member
>>
>>
>> Sorry, didn't quite get that. Currently, both the bridge_port and bridge have
>> the multicast_router field, and in both cases it is of type unsigned char. Do
>> you suggest to change both to be "u8"?
>>
> 
> Right, and this is unnecessarily long and requires to be broken ugly like that with
> the type above and name below. So I suggested to use u8 to avoid that.
> 
>>
>>>
>>>> +{
>>>> +	if (multicast_router == MDB_RTR_TYPE_TEMP)
>>>> +		return MDB_RTR_TYPE_TEMP_QUERY;
>>>> +	return multicast_router;
>>>> +}
>>>> +
>>>>  /* br_vlan.c */
>>>>  #ifdef CONFIG_BRIDGE_VLAN_FILTERING
>>>>  bool br_allowed_ingress(const struct net_bridge *br,
>>>> diff --git a/net/bridge/br_sysfs_br.c b/net/bridge/br_sysfs_br.c
>>>> index 723f25e..9b9c597 100644
>>>> --- a/net/bridge/br_sysfs_br.c
>>>> +++ b/net/bridge/br_sysfs_br.c
>>>> @@ -340,7 +340,8 @@ static ssize_t multicast_router_show(struct device *d,
>>>>  				     struct device_attribute *attr, char *buf)
>>>>  {
>>>>  	struct net_bridge *br = to_bridge(d);
>>>> -	return sprintf(buf, "%d\n", br->multicast_router);
>>>> +	return sprintf(buf, "%d\n",
>>>> +		       br_multicast_router_translate(br->multicast_router));
>>>>  }
>>>>  
>>>>  static ssize_t multicast_router_store(struct device *d,
>>>>
>>
> 
