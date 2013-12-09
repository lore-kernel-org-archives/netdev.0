From: Jiri Pirko <jiri@resnulli.us>
Subject: Re: [patch net/stable v2] br: fix use of ->rx_handler_data in code
 executed on non-rx_handler path
Date: Mon, 9 Dec 2013 22:52:20 +0100
Message-ID: <20131209215220.GC2449@minipsycho.orion>
References: <1386257257-25258-1-git-send-email-jiri@resnulli.us>
 <20131209115835.GA15564@redhat.com>
 <52A61AA5.9000000@redhat.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: "Michael S. Tsirkin" <mst@redhat.com>, netdev@vger.kernel.org,
	davem@davemloft.net, jtluka@redhat.com, zhiguohong@tencent.com,
	bridge@lists.linux-foundation.org, stephen@networkplumber.org,
	edumazet@google.com, laine@redhat.com, paulmck@linux.vnet.ibm.com
To: Vlad Yasevich <vyasevic@redhat.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-ea0-f176.google.com ([209.85.215.176]:42743 "EHLO
	mail-ea0-f176.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751349Ab3LIVwZ (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 9 Dec 2013 16:52:25 -0500
Received: by mail-ea0-f176.google.com with SMTP id h14so1830724eaj.21
        for <netdev@vger.kernel.org>; Mon, 09 Dec 2013 13:52:23 -0800 (PST)
Content-Disposition: inline
In-Reply-To: <52A61AA5.9000000@redhat.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Mon, Dec 09, 2013 at 08:31:49PM CET, vyasevic@redhat.com wrote:
>On 12/09/2013 06:58 AM, Michael S. Tsirkin wrote:
>> On Thu, Dec 05, 2013 at 04:27:37PM +0100, Jiri Pirko wrote:
>>> br_stp_rcv() is reached by non-rx_handler path. That means there is no
>>> guarantee that dev is bridge port and therefore simple NULL check of
>>> ->rx_handler_data is not enough. There is need to check if dev is really
>>> bridge port and since only rcu read lock is held here, do it by checking
>>> ->rx_handler pointer.
>>>
>>> Note that synchronize_net() in netdev_rx_handler_unregister() ensures
>>> this approach as valid.
>>>
>>> Introduced originally by:
>>> commit f350a0a87374418635689471606454abc7beaa3a
>>>   "bridge: use rx_handler_data pointer to store net_bridge_port pointer"
>>>
>>> Fixed but not in the best way by:
>>> commit b5ed54e94d324f17c97852296d61a143f01b227a
>>>   "bridge: fix RCU races with bridge port"
>>>
>>> Reintroduced by:
>>> commit 716ec052d2280d511e10e90ad54a86f5b5d4dcc2
>>>   "bridge: fix NULL pointer deref of br_port_get_rcu"
>>>
>>> Please apply to stable trees as well. Thanks.
>>>
>>> RH bugzilla reference: https://bugzilla.redhat.com/show_bug.cgi?id=1025770
>>>
>>> Reported-by: Laine Stump <laine@redhat.com>
>>> Debugged-by: Michael S. Tsirkin <mst@redhat.com>
>>> Signed-off-by: Michael S. Tsirkin <mst@redhat.com>
>>> Signed-off-by: Jiri Pirko <jiri@resnulli.us>
>>> ---
>>> v1->v2: moved br_port_get_check_rcu definition below br_handle_frame definition
>>>
>>>  net/bridge/br_private.h  | 10 ++++++++++
>>>  net/bridge/br_stp_bpdu.c |  2 +-
>>>  2 files changed, 11 insertions(+), 1 deletion(-)
>>>
>>> diff --git a/net/bridge/br_private.h b/net/bridge/br_private.h
>>> index 229d820..045d56e 100644
>>> --- a/net/bridge/br_private.h
>>> +++ b/net/bridge/br_private.h
>>> @@ -426,6 +426,16 @@ netdev_features_t br_features_recompute(struct net_bridge *br,
>>>  int br_handle_frame_finish(struct sk_buff *skb);
>>>  rx_handler_result_t br_handle_frame(struct sk_buff **pskb);
>>>  
>>> +static inline bool br_rx_handler_check_rcu(const struct net_device *dev)
>>> +{
>>> +	return rcu_dereference(dev->rx_handler) == br_handle_frame;
>> 
>> Actually this started to bother me.
>> rcu_dereference is for when we dereference, isn't it?
>> I think we should use rcu_access_pointer here.
>> 
>> 
>>> +}
>> 
>> 
>> Given all the confusion, how about we create an API to
>> access rx handler data outside rx handler itself in a
>> safe, documented way?
>> 
>> If everyone agrees, we can then re-implement
>> br_port_get_check_rcu on top of this API.
>> 
>> What do others think?
>> 
>> ---
>> 
>> netdevice: allow access to rx_handler_data outside rx handler
>> 
>> rx_handler_data is easy to use correctly within
>> rx handler itself. Outside of that context, one must
>> validate the handler first.
>> 
>> Add an API to do this in a uniform way.
>> 
>> Signed-off-by: Michael S. Tsirkin <mst@redhat.com>
>
>This looks very nice is a usefull API.
>
>Acked-by: Vlad Yasevich <vyasevic@redhat.com>
>
>however, as I mentioned to Jiri, I've been trying to understand why
>Stephen's patch is insufficient and so far I can't come up with a race
>scenario that would break a simple check for dev->priv_flags.
>
>So, I've decided to look at the history that Jiri mentioned in his
>commit.  In particular, I was reading
>    commit b5ed54e94d324f17c97852296d61a143f01b227a
>    "bridge: fix RCU races with bridge port"
>
>that claimed that there is a race in RCU section when just checking
>the priv_flags for IFF_BRIDGE_PORT flag.  Doing a little more digging
>shows that at the time that commit was added, there was no call to
>synchronise_net() in netdev_rx_handler_unregister().  So, at the time
>of that commit there truly was a race, and the race still was not fixed
>until Eric submitted
>    commit 00cfec37484761a44a3b6f4675a54caa618210ae
>    net: add a synchronize_net() in netdev_rx_handler_unregister()
>
>So, I think now it is perfectly safe to simply use the construct
>    if (!br_port_exists(dev))
>         return;
>
>    port = br_port_get_rcu(dev);
>
>under rcu protection.  In fact, we are guaranteed to have a valid
>bridge port in this situation due to the fact that the the flag is
>is turned off before netdev_rx_handler_unregister() is called.


You are right. The check Stephen suggested is enough. But even still,
checking against the "paired" rcu pointer (dev->rx_handler) seems nicer
here. And with Michael's generic patch, this can be done for all
rx_handler users without them taking care of it (flags, etc)
individually.


>
>-vlad
>
>-vlad
>
>> 
>> -->
>> 
>> diff --git a/include/linux/netdevice.h b/include/linux/netdevice.h
>> index 7f0ed42..7a353b1 100644
>> --- a/include/linux/netdevice.h
>> +++ b/include/linux/netdevice.h
>> @@ -1320,6 +1320,9 @@ struct net_device {
>>  #endif
>>  
>>  	rx_handler_func_t __rcu	*rx_handler;
>> +	/* rx_handler itself can use rx_handler_data directly.
>> +	 * Others must use netdev_rx_handler_data_rcu_dereference.
>> +	 */
>>  	void __rcu		*rx_handler_data;
>>  
>>  	struct netdev_queue __rcu *ingress_queue;
>> @@ -2399,6 +2402,31 @@ int netdev_rx_handler_register(struct net_device *dev,
>>  			       void *rx_handler_data);
>>  void netdev_rx_handler_unregister(struct net_device *dev);
>>  
>> +/**
>> + *	netdev_rx_handler_data_rcu_dereference - access receive handler data
>> + *	@dev: device to get handler data for
>> + *	@rx_handler: receive handler used to register this data
>> + *
>> + *	Check that the receive handler is valid for the device.
>> + *	Return handler data if it is, NULL otherwise.
>> + *
>> + *	Use this function if you want to access rx handler data
>> + *	outside rx handler itself.
>> + *
>> + *	The caller must invoke this function under RCU read lock.
>> + *
>> + *	For a general description of rx_handler, see enum rx_handler_result.
>> + */
>> +static inline
>> +void *netdev_rx_handler_data_rcu_dereference(struct net_device *dev,
>> +					     rx_handler_func_t *rx_handler)
>> +{
>> +	if (rcu_access_pointer(dev->rx_handler) != rx_handler)
>> +		return NULL;
>> +
>> +	return rcu_dereference(dev->rx_handler_data);
>> +}
>> +
>>  bool dev_valid_name(const char *name);
>>  int dev_ioctl(struct net *net, unsigned int cmd, void __user *);
>>  int dev_ethtool(struct net *net, struct ifreq *);
>> --
>> To unsubscribe from this list: send the line "unsubscribe netdev" in
>> the body of a message to majordomo@vger.kernel.org
>> More majordomo info at  http://vger.kernel.org/majordomo-info.html
>> 
>
