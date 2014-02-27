From: Vlad Yasevich <vyasevic@redhat.com>
Subject: Re: [PATCH 2/7] bridge: Keep track of ports capable of
	flooding.
Date: Thu, 27 Feb 2014 07:54:54 -0500
Message-ID: <530F359E.1040407@redhat.com>
References: <1393427905-6811-1-git-send-email-vyasevic@redhat.com>
	<1393427905-6811-3-git-send-email-vyasevic@redhat.com>
	<530F288D.4050400@lab.ntt.co.jp>
Reply-To: vyasevic@redhat.com
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-2022-JP
Content-Transfer-Encoding: 7bit
Cc: john.r.fastabend@intel.com, shemminger@vyatta.com,
	bridge@lists.linux-foundation.org, jhs@mojatatu.com, mst@redhat.com
To: Toshiaki Makita <makita.toshiaki@lab.ntt.co.jp>, netdev@vger.kernel.org
Return-path: <bridge-bounces@lists.linux-foundation.org>
In-Reply-To: <530F288D.4050400@lab.ntt.co.jp>
List-Unsubscribe: <https://lists.linuxfoundation.org/mailman/options/bridge>,
	<mailto:bridge-request@lists.linux-foundation.org?subject=unsubscribe>
List-Archive: <http://lists.linuxfoundation.org/pipermail/bridge/>
List-Post: <mailto:bridge@lists.linux-foundation.org>
List-Help: <mailto:bridge-request@lists.linux-foundation.org?subject=help>
List-Subscribe: <https://lists.linuxfoundation.org/mailman/listinfo/bridge>,
	<mailto:bridge-request@lists.linux-foundation.org?subject=subscribe>
Sender: bridge-bounces@lists.linux-foundation.org
Errors-To: bridge-bounces@lists.linux-foundation.org
List-Id: netdev.vger.kernel.org

On 02/27/2014 06:59 AM, Toshiaki Makita wrote:
> (2014/02/27 0:18), Vlad Yasevich wrote:
>> Keep track of bridge ports that have unicast flooding turned on.
>> This will later be used by the algorithm to automatically manage
>> address programming and promisc mode.
>>
> ...
>> @@ -383,6 +389,9 @@ int br_add_if(struct net_bridge *br, struct net_device *dev)
>>  	dev_disable_lro(dev);
>>  
>>  	list_add_rcu(&p->list, &br->port_list);
>> +
>> +	if (p->flags & BR_FLOOD)
>> +		br_add_flood_port(p, br);
> 
> BR_FLOOD seems to be set in new_nbp().
> Is this condition check needed?
> 

Not currently, but I think there is an api in the works to allow
adding port with port flags set to begin with.  This just guards
for this case.

>>  
>>  	netdev_update_features(br->dev);
>>  
>> @@ -455,3 +464,50 @@ int br_del_if(struct net_bridge *br, struct net_device *dev)
>>  
>>  	return 0;
>>  }
>> +
>> +static void br_add_flood_port(struct net_bridge_port *p, struct net_bridge *br)
>> +{
>> +	/* Increment the number of  flooding ports, and if we
>> +	 * only have 1 flooding port cache if for future use.
>> +	 */
>> +	br->n_flood_ports++;
>> +	if (br->n_flood_ports == 1)
>> +		br->c_flood_port = p;
> 
> Needn't c_flood_port be cleared if n_flood_ports == 2?
> 

It can be, but there is no reason to do it.  It is not used
if the number or flood ports is > 1.
We can clean it up when we delete it, but we keep it around
on the off chance that it will be come the lone flood port again.
That's likely in some scenarios.

-vlad

> Thanks,
> Toshiaki Makita
> 
>> +}
>> +
>> +static void br_del_flood_port(struct net_bridge_port *p, struct net_bridge *br)
>> +{
>> +	struct net_bridge_port *port;
>> +
>> +	/* Decrement the  number of flood port.
>> +	 * If we are deleting the current flood port, clear
>> +	 * the cached port.  If we are down to 1 flood port,
>> +	 * set it if it is not set.
>> +	 */
>> +	br->n_flood_ports--;
>> +	if (p == br->c_flood_port)
>> +		br->c_flood_port = NULL;
>> +
>> +	if (br->n_flood_ports == 1) {
>> +		list_for_each_entry(port, &p->br->port_list, list) {
>> +			if (port->flags & BR_FLOOD) {
>> +				br->c_flood_port = port;
>> +				break;
>> +			}
>> +		}
>> +	}
>> +}
>> +
>> +void br_port_flags_change(struct net_bridge_port *p, unsigned long mask)
>> +{
>> +	struct net_bridge *br = p->br;
>> +
>> +	/* We are only interested FLOOD flag */
>> +	if (!(mask & BR_FLOOD))
>> +		return;
>> +
>> +	if (p->flags & BR_FLOOD)
>> +		br_add_flood_port(p, br);
>> +	else
>> +		br_del_flood_port(p, br);
>> +}
>> diff --git a/net/bridge/br_netlink.c b/net/bridge/br_netlink.c
>> index e74b6d53..01382b9 100644
>> --- a/net/bridge/br_netlink.c
>> +++ b/net/bridge/br_netlink.c
>> @@ -328,6 +328,7 @@ static void br_set_port_flag(struct net_bridge_port *p, struct nlattr *tb[],
>>  static int br_setport(struct net_bridge_port *p, struct nlattr *tb[])
>>  {
>>  	int err;
>> +	unsigned long old_flags = p->flags;
>>  
>>  	br_set_port_flag(p, tb, IFLA_BRPORT_MODE, BR_HAIRPIN_MODE);
>>  	br_set_port_flag(p, tb, IFLA_BRPORT_GUARD, BR_BPDU_GUARD);
>> @@ -353,6 +354,8 @@ static int br_setport(struct net_bridge_port *p, struct nlattr *tb[])
>>  		if (err)
>>  			return err;
>>  	}
>> +
>> +	br_port_flags_change(p, old_flags ^ p->flags);
>>  	return 0;
>>  }
>>  
>> diff --git a/net/bridge/br_private.h b/net/bridge/br_private.h
>> index 3ba11bc..26a3987 100644
>> --- a/net/bridge/br_private.h
>> +++ b/net/bridge/br_private.h
>> @@ -290,6 +290,8 @@ struct net_bridge
>>  	struct timer_list		topology_change_timer;
>>  	struct timer_list		gc_timer;
>>  	struct kobject			*ifobj;
>> +	struct net_bridge_port		*c_flood_port;
>> +	u32				n_flood_ports;
>>  #ifdef CONFIG_BRIDGE_VLAN_FILTERING
>>  	u8				vlan_enabled;
>>  	struct net_port_vlans __rcu	*vlan_info;
>> @@ -415,6 +417,8 @@ int br_del_if(struct net_bridge *br, struct net_device *dev);
>>  int br_min_mtu(const struct net_bridge *br);
>>  netdev_features_t br_features_recompute(struct net_bridge *br,
>>  					netdev_features_t features);
>> +void br_port_flags_change(struct net_bridge_port *port,
>> +			  unsigned long mask);
>>  
>>  /* br_input.c */
>>  int br_handle_frame_finish(struct sk_buff *skb);
>> diff --git a/net/bridge/br_sysfs_if.c b/net/bridge/br_sysfs_if.c
>> index 7f66aa4..9ff6691 100644
>> --- a/net/bridge/br_sysfs_if.c
>> +++ b/net/bridge/br_sysfs_if.c
>> @@ -51,7 +51,10 @@ static BRPORT_ATTR(_name, S_IRUGO | S_IWUSR,			\
>>  static int store_flag(struct net_bridge_port *p, unsigned long v,
>>  		     unsigned long mask)
>>  {
>> -	unsigned long flags = p->flags;
>> +	unsigned long flags;
>> +	unsigned long old_flags;
>> +
>> +	old_flags = flags = p->flags;
>>  
>>  	if (v)
>>  		flags |= mask;
>> @@ -60,6 +63,7 @@ static int store_flag(struct net_bridge_port *p, unsigned long v,
>>  
>>  	if (flags != p->flags) {
>>  		p->flags = flags;
>> +		br_port_flags_change(p, old_flags ^ flags);
>>  		br_ifinfo_notify(RTM_NEWLINK, p);
>>  	}
>>  	return 0;
>>
