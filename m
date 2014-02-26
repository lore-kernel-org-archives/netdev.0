From: Vlad Yasevich <vyasevic@redhat.com>
Subject: Re: [PATCH 3/7] bridge: Add addresses from static fdbs to
 bridge address list
Date: Wed, 26 Feb 2014 10:43:57 -0500
Message-ID: <530E0BBD.9050404@redhat.com>
References: <1393427905-6811-1-git-send-email-vyasevic@redhat.com>
	<1393427905-6811-4-git-send-email-vyasevic@redhat.com>
	<20140226154655.GD15330@redhat.com>
Reply-To: vyasevic@redhat.com
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1
Content-Transfer-Encoding: 7bit
Cc: john.r.fastabend@intel.com, netdev@vger.kernel.org, shemminger@vyatta.com,
	bridge@lists.linux-foundation.org, jhs@mojatatu.com
To: "Michael S. Tsirkin" <mst@redhat.com>
Return-path: <bridge-bounces@lists.linux-foundation.org>
In-Reply-To: <20140226154655.GD15330@redhat.com>
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

On 02/26/2014 10:46 AM, Michael S. Tsirkin wrote:
>> +
>> diff --git a/net/bridge/br_if.c b/net/bridge/br_if.c
>> index f072b34..e782c2e 100644
>> --- a/net/bridge/br_if.c
>> +++ b/net/bridge/br_if.c
>> @@ -144,7 +144,7 @@ static void del_nbp(struct net_bridge_port *p)
>>  
>>  	br_ifinfo_notify(RTM_DELLINK, p);
>>  
>> -	list_del_rcu(&p->list);
>> +	dev->priv_flags &= ~IFF_BRIDGE_PORT;
>>  
>>  	if (p->flags & BR_FLOOD)
>>  		br_del_flood_port(p, br);
>> @@ -152,7 +152,7 @@ static void del_nbp(struct net_bridge_port *p)
>>  	nbp_vlan_flush(p);
>>  	br_fdb_delete_by_port(br, p, 1);
>>  
>> -	dev->priv_flags &= ~IFF_BRIDGE_PORT;
>> +	list_del_rcu(&p->list);
>>  
>>  	netdev_rx_handler_unregister(dev);
>>
> 
> Hmm here we are moving list_del_rcu
> back to after nbp_vlan_flush.
> Was the reordering in the previous patch necessary?

Oops.  Will fix it up.

-vlad

>   
>> @@ -473,6 +473,8 @@ static void br_add_flood_port(struct net_bridge_port *p, struct net_bridge *br)
>>  	br->n_flood_ports++;
>>  	if (br->n_flood_ports == 1)
>>  		br->c_flood_port = p;
>> +
>> +	br_fdb_addrs_sync(br);
>>  }
>>  
>>  static void br_del_flood_port(struct net_bridge_port *p, struct net_bridge *br)
>> @@ -485,13 +487,17 @@ static void br_del_flood_port(struct net_bridge_port *p, struct net_bridge *br)
>>  	 * set it if it is not set.
>>  	 */
>>  	br->n_flood_ports--;
>> -	if (p == br->c_flood_port)
>> +	if (p == br->c_flood_port) {
>> +		br_fdb_addrs_unsync(br);
>>  		br->c_flood_port = NULL;
>> +	}
>>  
>>  	if (br->n_flood_ports == 1) {
>>  		list_for_each_entry(port, &p->br->port_list, list) {
>> -			if (port->flags & BR_FLOOD) {
>> +			if (br_port_exists(port->dev) &&
>> +			    (port->flags & BR_FLOOD)) {
>>  				br->c_flood_port = port;
>> +				br_fdb_addrs_sync(br);
>>  				break;
>>  			}
>>  		}
>> diff --git a/net/bridge/br_private.h b/net/bridge/br_private.h
>> index 26a3987..40a6927 100644
>> --- a/net/bridge/br_private.h
>> +++ b/net/bridge/br_private.h
>> @@ -296,6 +296,7 @@ struct net_bridge
>>  	u8				vlan_enabled;
>>  	struct net_port_vlans __rcu	*vlan_info;
>>  #endif
>> +	struct netdev_hw_addr_list	conf_addrs;
>>  };
>>  
>>  struct br_input_skb_cb {
>> @@ -397,6 +398,8 @@ int br_fdb_add(struct ndmsg *nlh, struct nlattr *tb[], struct net_device *dev,
>>  	       const unsigned char *addr, u16 nlh_flags);
>>  int br_fdb_dump(struct sk_buff *skb, struct netlink_callback *cb,
>>  		struct net_device *dev, int idx);
>> +void br_fdb_addrs_sync(struct net_bridge *br);
>> +void br_fdb_addrs_unsync(struct net_bridge *br);
>>  
>>  /* br_forward.c */
>>  void br_deliver(const struct net_bridge_port *to, struct sk_buff *skb);
>> diff --git a/net/core/dev.c b/net/core/dev.c
>> index 4ad1b78..eca4d476 100644
>> --- a/net/core/dev.c
>> +++ b/net/core/dev.c
>> @@ -5212,6 +5212,7 @@ void __dev_set_rx_mode(struct net_device *dev)
>>  	if (ops->ndo_set_rx_mode)
>>  		ops->ndo_set_rx_mode(dev);
>>  }
>> +EXPORT_SYMBOL(__dev_set_rx_mode);
>>  
>>  void dev_set_rx_mode(struct net_device *dev)
>>  {
>> diff --git a/net/core/dev_addr_lists.c b/net/core/dev_addr_lists.c
>> index 329d579..3de44a3 100644
>> --- a/net/core/dev_addr_lists.c
>> +++ b/net/core/dev_addr_lists.c
>> @@ -81,13 +81,14 @@ static int __hw_addr_add_ex(struct netdev_hw_addr_list *list,
>>  				   sync);
>>  }
>>  
>> -static int __hw_addr_add(struct netdev_hw_addr_list *list,
>> -			 const unsigned char *addr, int addr_len,
>> -			 unsigned char addr_type)
>> +int __hw_addr_add(struct netdev_hw_addr_list *list,
>> +		  const unsigned char *addr, int addr_len,
>> +		  unsigned char addr_type)
>>  {
>>  	return __hw_addr_add_ex(list, addr, addr_len, addr_type, false, false,
>>  				0);
>>  }
>> +EXPORT_SYMBOL(__hw_addr_add);
>>  
>>  static int __hw_addr_del_entry(struct netdev_hw_addr_list *list,
>>  			       struct netdev_hw_addr *ha, bool global,
>> @@ -127,12 +128,13 @@ static int __hw_addr_del_ex(struct netdev_hw_addr_list *list,
>>  	return -ENOENT;
>>  }
>>  
>> -static int __hw_addr_del(struct netdev_hw_addr_list *list,
>> -			 const unsigned char *addr, int addr_len,
>> -			 unsigned char addr_type)
>> +int __hw_addr_del(struct netdev_hw_addr_list *list,
>> +		  const unsigned char *addr, int addr_len,
>> +		  unsigned char addr_type)
>>  {
>>  	return __hw_addr_del_ex(list, addr, addr_len, addr_type, false, false);
>>  }
>> +EXPORT_SYMBOL(__hw_addr_del);
>>  
>>  static int __hw_addr_sync_one(struct netdev_hw_addr_list *to_list,
>>  			       struct netdev_hw_addr *ha,
>> -- 
>> 1.8.5.3
> 
> 
> I would split net/core/ changes out, and  Cc more people
> on it.
> 
