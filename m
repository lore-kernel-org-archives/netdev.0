From: Vlad Yasevich <vyasevich@gmail.com>
Subject: Re: [RFC PATCH v2 net-next 4/7] bridge: Automatically
 manage port promiscuous mode.
Date: Wed, 30 Apr 2014 10:17:21 -0400
Message-ID: <536105F1.40809@gmail.com>
References: <1398806428-640-1-git-send-email-vyasevic@redhat.com>
	<1398806428-640-5-git-send-email-vyasevic@redhat.com>
	<20140430114625.GB22962@redhat.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1
Content-Transfer-Encoding: 7bit
Cc: john.r.fastabend@intel.com, netdev@vger.kernel.org, shemminger@vyatta.com,
	bridge@lists.linux-foundation.org, jhs@mojatatu.com
To: "Michael S. Tsirkin" <mst@redhat.com>, Vlad Yasevich <vyasevic@redhat.com>
Return-path: <bridge-bounces@lists.linux-foundation.org>
In-Reply-To: <20140430114625.GB22962@redhat.com>
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

On 04/30/2014 07:46 AM, Michael S. Tsirkin wrote:
> On Tue, Apr 29, 2014 at 05:20:25PM -0400, Vlad Yasevich wrote:
>> When there is only 1 port that can learn mac addresses and flood
>> unknown traffic, this port can function in non-promiscouse mode.
> 
> typo: non-promiscous
> 
> I think the code is correct here. But I'm not sure the explanation
> addresses the question that has been raised in the past:
> why is it correct to tie the output (flood) and input (learning)
> together and have it affect input (promisc).
> 

I found that thinking of the code in terms of possible configuration
examples helped clarify the behavior in my head.

> I would offer the following explanation to address the above
> question:
> 
> 
> Consider a specific port X. All traffic on its input will be
> output through one of the other ports (or dropped).
> Thus if *no* other port need to flood traffic
> on its output, then the combination of FDB entries for other
> ports completely specifies the set of legal mac addresses on the input
> of port X.

Right.  I tried to lead to this with the first two examples where one is
an extension of another.  It is sometimes easier to think about the
behavior when you have specifics instead of abstract concepts.
May be I didn't do this very well.

> 
> If, additionally, learning is disabled for all other ports,
> these FDB entries for other ports are static, so this set
> of mac addresses on port X does not change much.
> 
> This patch detects that no other port needs to flood or has learning
> enabled, and disables promisc mode for port X, instead programming the
> set of output mac addresses for other ports from the static fdb into the
> hardware filtering table in the underlying device.
> 
> Note: an alternative would be to simply check that no other port needs
> to flood, however, this would mean that non-static FDB updates by
> learning on other ports need to be propagated to hardware on port X,
> which is harder to implement efficiently.

Not only this, but without some sort of mac validation, this is a source
of attack against the bridge as it a single malicious node can now
saturate the hw filter and cause the bridge to consume extra memory.

> 
> It might be a good idea to put something like this above in
> commit log, along with the examples you provide below.
> A shortened version might be helpful in code comments as well.
> 
>> The simplest example of this configuration is a bridge with only
>> 1 port.  In this case, the bridge can't forward traffic anywhere.
>> All it can do is recevie traffic destined to it.  It doesn't need
>> to the interface into promiscouse mode.
>> A more complicated example is a bridge with 2 or more ports where
>> only 1 port remains capable of auto-discover and all others disable
>> mac learning and flooding thus requiring static configuration.  You
>> could think of this configuraiton as mimicking and edge relay with
>> 1 uplink port (the one can still learn things), and N downlink ports
>> that have to be manually programmed by user or managment entity.
>> In this case, the 1 uplink doesn't really have
>> to be promiscous either since the bridge would have all the necessary
>> data in the fdb through static configuration.  This one port can be
>> manually programmed to allow to recieve necessary traffic.
>> Another case where there is no need for promiscuous mode is when
>> there are no "proverbial" uplinks and all ports are manually managed.
>> All necessary information will be provided, so anything an interface
>> receives in promiscouse mode is extra and could even be considered
>> security threat.
> 
> Might be a good idea to clarify: the security problem is that with
> hardware filtering by MAC being off, it's easier to cause load spikes on
> multiple bridges on the LAN.
> 
> 
>> This patch supports the above scenarios.
>>
>> Signed-off-by: Vlad Yasevich <vyasevic@redhat.com>
> 
> 
> I think what this patchset is trying to do correct.
> Minor comments below.
> 
> 
> Would bisect hit partially broken configurations if
> it picks patch 4 but not 5-7?
> If yes it's best to smash patches 5-7 in with this one.

I think I can restructure patch 5 so that it can be before this one
and stand on its own.
Patches 6 and 7 could potentially break some configurations during
bisect.  They are small enough that they can be squashed, but anything
that makes this patch more complicated to review is not so good IMO.
I'll give it a go and see what it looks like.

> 
> 
>> ---
>>  net/bridge/br_if.c      | 85 +++++++++++++++++++++++++++++++++++++++++++++----
>>  net/bridge/br_private.h |  2 ++
>>  2 files changed, 81 insertions(+), 6 deletions(-)
>>
>> diff --git a/net/bridge/br_if.c b/net/bridge/br_if.c
>> index 7e60c4c..5a26ca2 100644
>> --- a/net/bridge/br_if.c
>> +++ b/net/bridge/br_if.c
>> @@ -85,6 +85,64 @@ void br_port_carrier_check(struct net_bridge_port *p)
>>  	spin_unlock_bh(&br->lock);
>>  }
>>  
>> +static void br_port_set_promisc(struct net_bridge_port *p)
>> +{
>> +	int err = 0;
>> +
>> +	if (br_is_promisc_port(p))
>> +		return;
>> +
>> +	err = dev_set_promiscuity(p->dev, 1);
>> +	if (err)
>> +		return;
> 
> Can this happen here? We can't recover so maybe warn if it does?
> 

It can happen if the device promiscuity count overflows.  If that
happens a warning is already printed.
The good thing is that the device is already in promisc mode so
everything still works.

>> +
>> +	br_fdb_unsync_static(p->br, p);
>> +	p->flags |= BR_PROMISC;
>> +}
>> +
>> +static void br_port_clear_promisc(struct net_bridge_port *p)
>> +{
>> +	int err;
>> +
>> +	if (!br_is_promisc_port(p))
>> +		return;
>> +
>> +	/* Since we'll be clearing the promisc mode, program the port
>> +	 * first so that we don't have interruption in traffic.
>> +	 */
>> +	err = br_fdb_sync_static(p->br, p);
>> +	if (err)
>> +		return;
>> +
>> +	dev_set_promiscuity(p->dev, -1);
>> +	p->flags &= ~BR_PROMISC;
>> +}
>> +
>> +/* When a port is added or removed or when certain port flags
>> + * change, this function is called to automatically mange
>> + * promiscuity setting of all the bridge ports.  We are always called
>> + * under RTNL so can skip using rcu primitives.
>> + */
>> +static void br_manage_promisc(struct net_bridge *br)
>> +{
>> +	struct net_bridge_port *p;
>> +
>> +	/* Algorithm is simple.
> 
> I think it's best to drop this line.
> It doesn't really clarify anything :)
> 
>>  If all the port
> 
> all the ports?
> 
>> require static
>> +	 * configuration, we know everything and can simply write
>> +	 * that down to the ports and clear promisc.
>> +	 * If only 1 port is automatic and all the others require
>> +	 * static configuration, we can write all the static data
>> +	 * to this one automatic port and still make non-promisc.
> 
> 
> make *this port* non promisc.
> 
>> +	 */
> 
> It's best to move this comment within list_for_each_entry,
> near the code it documents.
> 

Will fix

>> +	list_for_each_entry(p, &br->port_list, list) {
>> +		if (br->auto_cnt == 0 ||
>> +		    (br->auto_cnt == 1 && br_is_auto_port(p)))
> 
> 
> This is correct but I think it would be clearer as follows:
> 
> 	list_for_each_entry(p, &br->port_list, list) {
> 		/* If this is the only automatic port, others are not automatic so
> 		 * their output configuration is determined by static fdb entries.
> 		 * Thus, since input on this port will become output on one of the
> 		 * others, this means our input configuration is static: write it out to
> 		 * hardware and disable promiscous mode.
> 		 * Otherwise, make the port promiscous.
> 		 */
> 		if (br->auto_cnt <= br_is_auto_port(p))
> 				br_port_clear_promisc(p);
> 			else
> 				br_port_set_promisc(p);
> 	}
> 
> 
> instead of enumerating cases in comments and in code like you did above.
> 

br_is_auto_port give a boolean.  I suppose I can make it return an
integer, but that IMO makes it more confusing.  I can questions about
why do we clear it when there are no automatic ports.  I was trying to
be very explicit in the conditions.

Thanks
-vlad

> 	
> 
> 
>> +			br_port_clear_promisc(p);
>> +		else
>> +			br_port_set_promisc(p);
>> +	}
>> +}
>> +
>>  static void nbp_update_port_count(struct net_bridge *br)
>>  {
>>  	struct net_bridge_port *p;
>> @@ -94,7 +152,23 @@ static void nbp_update_port_count(struct net_bridge *br)
>>  		if (br_is_auto_port(p))
>>  			cnt++;
>>  	}
>> -	br->auto_cnt = cnt;
>> +	if (br->auto_cnt != cnt) {
>> +		br->auto_cnt = cnt;
>> +		br_manage_promisc(br);
>> +	}
>> +}
>> +
>> +static void nbp_delete_promisc(struct net_bridge_port *p)
>> +{
>> +	/* If port is currently promiscous, unset promiscuity.
>> +	 * Otherwise, it is a static port so remove all addresses
>> +	 * from it.
>> +	 */
>> +	dev_set_allmulti(p->dev, -1);
>> +	if (br_is_promisc_port(p))
>> +		dev_set_promiscuity(p->dev, -1);
>> +	else
>> +		br_fdb_unsync_static(p->br, p);
>>  }
>>  
>>  static void release_nbp(struct kobject *kobj)
>> @@ -145,7 +219,7 @@ static void del_nbp(struct net_bridge_port *p)
>>  
>>  	sysfs_remove_link(br->ifobj, p->dev->name);
>>  
>> -	dev_set_promiscuity(dev, -1);
>> +	nbp_delete_promisc(p);
>>  
>>  	spin_lock_bh(&br->lock);
>>  	br_stp_disable_port(p);
>> @@ -153,11 +227,10 @@ static void del_nbp(struct net_bridge_port *p)
>>  
>>  	br_ifinfo_notify(RTM_DELLINK, p);
>>  
>> -	nbp_vlan_flush(p);
>> -	br_fdb_delete_by_port(br, p, 1);
>> -
>>  	list_del_rcu(&p->list);
>>  
>> +	nbp_vlan_flush(p);
>> +	br_fdb_delete_by_port(br, p, 1);
>>  	nbp_update_port_count(br);
>>  
>>  	dev->priv_flags &= ~IFF_BRIDGE_PORT;
>> @@ -367,7 +440,7 @@ int br_add_if(struct net_bridge *br, struct net_device *dev)
>>  
>>  	call_netdevice_notifiers(NETDEV_JOIN, dev);
>>  
>> -	err = dev_set_promiscuity(dev, 1);
>> +	err = dev_set_allmulti(dev, 1);
>>  	if (err)
>>  		goto put_back;
>>  
>> diff --git a/net/bridge/br_private.h b/net/bridge/br_private.h
>> index 2023671..1c794fef 100644
>> --- a/net/bridge/br_private.h
>> +++ b/net/bridge/br_private.h
>> @@ -175,6 +175,7 @@ struct net_bridge_port
>>  #define BR_LEARNING		0x00000020
>>  #define BR_FLOOD		0x00000040
>>  #define BR_AUTO_MASK (BR_FLOOD | BR_LEARNING)
>> +#define BR_PROMISC		0x00000080
>>  
>>  #ifdef CONFIG_BRIDGE_IGMP_SNOOPING
>>  	struct bridge_mcast_query	ip4_query;
>> @@ -200,6 +201,7 @@ struct net_bridge_port
>>  };
>>  
>>  #define br_is_auto_port(p) (((p)->flags & BR_AUTO_MASK) == BR_AUTO_MASK)
>> +#define br_is_promisc_port(p) ((p)->flags & BR_PROMISC)
>>  
>>  #define br_port_exists(dev) (dev->priv_flags & IFF_BRIDGE_PORT)
>>  
>> -- 
>> 1.9.0
> --
> To unsubscribe from this list: send the line "unsubscribe netdev" in
> the body of a message to majordomo@vger.kernel.org
> More majordomo info at  http://vger.kernel.org/majordomo-info.html
> 
