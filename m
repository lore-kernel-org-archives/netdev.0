From: Vlad Yasevich <vyasevic@redhat.com>
Subject: Re: [PATCH 6/7] bridge: Manage promisc mode when vlans are
 configured on top of a bridge
Date: Fri, 28 Feb 2014 14:34:54 -0500
Message-ID: <5310E4DE.1080003@redhat.com>
References: <1393427905-6811-1-git-send-email-vyasevic@redhat.com>
	<1393427905-6811-7-git-send-email-vyasevic@redhat.com>
	<530F2A4C.6020303@lab.ntt.co.jp> <530F3AD4.6080704@redhat.com>
Reply-To: vyasevic@redhat.com
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-2022-JP
Content-Transfer-Encoding: 7bit
Cc: john.r.fastabend@intel.com, shemminger@vyatta.com,
	bridge@lists.linux-foundation.org, jhs@mojatatu.com, mst@redhat.com
To: Toshiaki Makita <makita.toshiaki@lab.ntt.co.jp>, netdev@vger.kernel.org
Return-path: <bridge-bounces@lists.linux-foundation.org>
In-Reply-To: <530F3AD4.6080704@redhat.com>
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

On 02/27/2014 08:17 AM, Vlad Yasevich wrote:
> On 02/27/2014 07:06 AM, Toshiaki Makita wrote:
>> (2014/02/27 0:18), Vlad Yasevich wrote:
>>> If the user configures vlan interfaces on top of the bridge and the bridge
>>> doesn't have vlan filtering enabled, we have to place all the ports in
>>> promsic mode so that we can correctly receive tagged frames.
>>> When vlan filtering is enabled, the vlan configuration will be provided
>>> via filtering interface.
>>> When the vlan filtering is toggled, we also have mange promiscuity.
>>
>> If we disable vlan_filtering and no vlan interface is configured on the
>> bridge, we cannot forward any tagged traffic?
> 
> We can't receive tagged traffic, so we turn promisc on.
> 
>> If we want to forward frames from one port to another port (not from/to
>> bridge device), we have to add vlan interface or set promisc mode, right?
>>
> 
> Hm..  Good point.  This isn't enough to address the scenario that Patch7
> tries to solve.  I'll need to think about that.  This is partially why
> I split functionality in Patch7 out.  It made things more difficult.
> 

I now understood what you were referring to above a bit better.
This patch solves just part of the problem.  The other part is what
happens when someone behind the bridge is using vlan tagging without
the bridge being aware of it and expects the bridge to forward such traffic.
So, if we ever want to disable promiscuous mode on the bridge ports, we
either need to depend on lan filtering being configured in the bridge
or have the ability to disable vlan filtering in the driver.

Neither is really a good thing.  I'll need to think about this.

-vlad

> -vlad
> 
>> Sorry if I misunderstood it. I'm not sure..
>>
>> Thanks,
>> Toshiaki Makita
>>
>>>
>>> Signed-off-by: Vlad Yasevich <vyasevic@redhat.com>
>>> ---
>>>  net/bridge/br_device.c  | 14 ++++++++++++++
>>>  net/bridge/br_if.c      | 17 +++++++++++++----
>>>  net/bridge/br_private.h |  9 +++++++++
>>>  net/bridge/br_vlan.c    |  1 +
>>>  4 files changed, 37 insertions(+), 4 deletions(-)
>>>
>>> diff --git a/net/bridge/br_device.c b/net/bridge/br_device.c
>>> index 0af9d6c..967abb3 100644
>>> --- a/net/bridge/br_device.c
>>> +++ b/net/bridge/br_device.c
>>> @@ -297,6 +297,18 @@ void br_netpoll_disable(struct net_bridge_port *p)
>>>  
>>>  #endif
>>>  
>>> +static int br_dev_rx_add_vid(struct net_device *br_dev, __be16 proto, u16 vid)
>>> +{
>>> +	br_manage_promisc(netdev_priv(br_dev));
>>> +	return 0;
>>> +}
>>> +
>>> +static int br_dev_rx_kill_vid(struct net_device *br_dev, __be16 proto, u16 vid)
>>> +{
>>> +	br_manage_promisc(netdev_priv(br_dev));
>>> +	return 0;
>>> +}
>>> +
>>>  static int br_add_slave(struct net_device *dev, struct net_device *slave_dev)
>>>  
>>>  {
>>> @@ -328,6 +340,8 @@ static const struct net_device_ops br_netdev_ops = {
>>>  	.ndo_change_rx_flags	 = br_dev_change_rx_flags,
>>>  	.ndo_change_mtu		 = br_change_mtu,
>>>  	.ndo_do_ioctl		 = br_dev_ioctl,
>>> +	.ndo_vlan_rx_add_vid	 = br_dev_rx_add_vid,
>>> +	.ndo_vlan_rx_kill_vid	 = br_dev_rx_kill_vid,
>>>  #ifdef CONFIG_NET_POLL_CONTROLLER
>>>  	.ndo_netpoll_setup	 = br_netpoll_setup,
>>>  	.ndo_netpoll_cleanup	 = br_netpoll_cleanup,
>>> diff --git a/net/bridge/br_if.c b/net/bridge/br_if.c
>>> index 7e92bd0..55e4e28 100644
>>> --- a/net/bridge/br_if.c
>>> +++ b/net/bridge/br_if.c
>>> @@ -497,12 +497,21 @@ static void br_port_clear_promisc(struct net_bridge_port *p)
>>>  void br_manage_promisc(struct net_bridge *br)
>>>  {
>>>  	struct net_bridge_port *p;
>>> +	int set_all = false;
>>> +
>>> +	if (br->dev->flags & IFF_PROMISC)
>>> +		set_all = true;
>>> +
>>> +	/* If vlan filtering is disabled and there are any VLANs
>>> +	 * configured on top of the bridge, set promisc on all
>>> +	 * ports.
>>> +	 */
>>> +	if (!br_vlan_enabled(br) && vlan_uses_dev(br->dev))
>>> +		set_all = true;
>>>  
>>>  	list_for_each_entry(p, &br->port_list, list) {
>>> -		if (br->dev->flags & IFF_PROMISC) {
>>> -			/* PROMISC flag has been turned on for the bridge
>>> -			 * itself.  Turn on promisc on all ports.
>>> -			 */
>>> +		if (set_all) {
>>> +			/* Set all the ports to promisc mode.  */
>>>  			br_port_set_promisc(p);
>>>  
>>>  		} else {
>>> diff --git a/net/bridge/br_private.h b/net/bridge/br_private.h
>>> index 4042f86..87dcc09 100644
>>> --- a/net/bridge/br_private.h
>>> +++ b/net/bridge/br_private.h
>>> @@ -641,6 +641,10 @@ static inline u16 br_get_pvid(const struct net_port_vlans *v)
>>>  	return v->pvid ?: VLAN_N_VID;
>>>  }
>>>  
>>> +static inline int br_vlan_enabled(struct net_bridge *br)
>>> +{
>>> +	return br->vlan_enabled;
>>> +}
>>>  #else
>>>  static inline bool br_allowed_ingress(struct net_bridge *br,
>>>  				      struct net_port_vlans *v,
>>> @@ -721,6 +725,11 @@ static inline u16 br_get_pvid(const struct net_port_vlans *v)
>>>  {
>>>  	return VLAN_N_VID;	/* Returns invalid vid */
>>>  }
>>> +
>>> +static inline int br_vlan_enabled(struct net_bridge *br);
>>> +{
>>> +	return 0;
>>> +}
>>>  #endif
>>>  
>>>  /* br_netfilter.c */
>>> diff --git a/net/bridge/br_vlan.c b/net/bridge/br_vlan.c
>>> index 8249ca7..eddc2f6 100644
>>> --- a/net/bridge/br_vlan.c
>>> +++ b/net/bridge/br_vlan.c
>>> @@ -321,6 +321,7 @@ int br_vlan_filter_toggle(struct net_bridge *br, unsigned long val)
>>>  		goto unlock;
>>>  
>>>  	br->vlan_enabled = val;
>>> +	br_manage_promisc(br);
>>>  
>>>  unlock:
>>>  	rtnl_unlock();
>>>
> 
