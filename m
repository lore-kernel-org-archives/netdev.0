From: Vlad Yasevich <vyasevic@redhat.com>
Subject: Re: [RFC PATCH net-next 1/3] bridge: Add mac_management
	sysfs interface
Date: Wed, 06 Mar 2013 21:35:31 -0500
Message-ID: <5137FCF3.2030309@redhat.com>
References: <1362623485-18209-1-git-send-email-vyasevic@redhat.com>
	<1362623485-18209-2-git-send-email-vyasevic@redhat.com>
Reply-To: vyasevic@redhat.com
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1; format=flowed
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, bridge@lists.linux-foundation.org
To: Vlad Yasevich <vyasevic@redhat.com>
Return-path: <bridge-bounces@lists.linux-foundation.org>
In-Reply-To: <1362623485-18209-2-git-send-email-vyasevic@redhat.com>
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

On 03/06/2013 09:31 PM, Vlad Yasevich wrote:
> Add an sysfs interface to turn MAC address management on an off.
> When MAC management is off (default), all interfaces in the bridge
> are in promisc mode.  When MAC management is on, promisc mode is
> turned off and the expectation is that user will manually program
> the MAC filter.

Sorry, the description is stale,  I forgot to update it after fixing up
the patch.  The change is is actually to add sysfs to control promisc
mode.  By default, it's on.  It can be turned off if user wants to.

-vlad

>
> Signed-off-by: Vlad Yasevich <vyasevic@redhat.com>
> ---
>   net/bridge/br_device.c   |   41 +++++++++++++++++++++++++++++++++++++++++
>   net/bridge/br_if.c       |   22 +++++++++++++++++-----
>   net/bridge/br_private.h  |    2 ++
>   net/bridge/br_sysfs_br.c |   17 +++++++++++++++++
>   4 files changed, 77 insertions(+), 5 deletions(-)
>
> diff --git a/net/bridge/br_device.c b/net/bridge/br_device.c
> index d5f1d3f..160bc74 100644
> --- a/net/bridge/br_device.c
> +++ b/net/bridge/br_device.c
> @@ -185,6 +185,46 @@ static int br_set_mac_address(struct net_device *dev, void *p)
>   	return 0;
>   }
>
> +int br_set_promisc(struct net_bridge* br, unsigned long val)
> +{
> +	struct net_bridge_port *p;
> +
> +	if (!rtnl_trylock())
> +		return restart_syscall();
> +
> +	spin_lock_bh(&br->lock);
> +
> +	if (val) {
> +		if (br->promisc_enabled)
> +			goto unlock;
> +
> +		br->promisc_enabled = 1;
> +		/* For each port on the bridge, turn on promisc mode and
> +		 * turn off ALLMULTI to handle multicast traffic.
> +		 */
> +		list_for_each_entry(p, &br->port_list, list) {
> +			dev_set_promiscuity(p->dev, 1);
> +			dev_set_allmulti(p->dev, -1);
> +		}
> +
> +	} else {
> +		if (!br->promisc_enabled)
> +			goto unlock;
> +
> +		br->promisc_enabled = 0;
> +		/* For each port on the bridge, turn off promisc mode */
> +		list_for_each_entry(p, &br->port_list, list) {
> +			dev_set_allmulti(p->dev, 1);
> +			dev_set_promiscuity(p->dev, -1);
> +		}
> +	}
> +unlock:
> +	spin_unlock_bh(&br->lock);
> +	rtnl_unlock();
> +	return 0;
> +}
> +
> +
>   static void br_getinfo(struct net_device *dev, struct ethtool_drvinfo *info)
>   {
>   	strlcpy(info->driver, "bridge", sizeof(info->driver));
> @@ -371,6 +411,7 @@ void br_dev_setup(struct net_device *dev)
>   	br->bridge_hello_time = br->hello_time = 2 * HZ;
>   	br->bridge_forward_delay = br->forward_delay = 15 * HZ;
>   	br->ageing_time = 300 * HZ;
> +	br->promisc_enabled = 1;
>
>   	br_netfilter_rtable_init(br);
>   	br_stp_timer_init(br);
> diff --git a/net/bridge/br_if.c b/net/bridge/br_if.c
> index ef1b914..02b4440 100644
> --- a/net/bridge/br_if.c
> +++ b/net/bridge/br_if.c
> @@ -132,7 +132,10 @@ static void del_nbp(struct net_bridge_port *p)
>
>   	sysfs_remove_link(br->ifobj, p->dev->name);
>
> -	dev_set_promiscuity(dev, -1);
> +	if (br->promisc_enabled)
> +		dev_set_promiscuity(dev, -1);
> +	else
> +		dev_set_allmulti(dev, -1);
>
>   	spin_lock_bh(&br->lock);
>   	br_stp_disable_port(p);
> @@ -350,9 +353,15 @@ int br_add_if(struct net_bridge *br, struct net_device *dev)
>
>   	call_netdevice_notifiers(NETDEV_JOIN, dev);
>
> -	err = dev_set_promiscuity(dev, 1);
> -	if (err)
> -		goto put_back;
> +	if (br->promisc_enabled) {
> +		err = dev_set_promiscuity(dev, 1);
> +		if (err)
> +			goto put_back;
> +	} else {
> +		err = dev_set_allmulti(dev, 1);
> +		if (err)
> +			goto put_back;
> +	}
>
>   	err = kobject_init_and_add(&p->kobj, &brport_ktype, &(dev->dev.kobj),
>   				   SYSFS_BRIDGE_PORT_ATTR);
> @@ -414,7 +423,10 @@ err2:
>   	kobject_put(&p->kobj);
>   	p = NULL; /* kobject_put frees */
>   err1:
> -	dev_set_promiscuity(dev, -1);
> +	if (br->promisc_enabled)
> +		dev_set_promiscuity(dev, -1);
> +	else
> +		dev_set_allmulti(dev, -1);
>   put_back:
>   	dev_put(dev);
>   	kfree(p);
> diff --git a/net/bridge/br_private.h b/net/bridge/br_private.h
> index 6d314c4..4a0fa29 100644
> --- a/net/bridge/br_private.h
> +++ b/net/bridge/br_private.h
> @@ -277,6 +277,7 @@ struct net_bridge
>   	struct timer_list		topology_change_timer;
>   	struct timer_list		gc_timer;
>   	struct kobject			*ifobj;
> +	u8				promisc_enabled;
>   #ifdef CONFIG_BRIDGE_VLAN_FILTERING
>   	u8				vlan_enabled;
>   	struct net_port_vlans __rcu	*vlan_info;
> @@ -327,6 +328,7 @@ extern void br_dev_setup(struct net_device *dev);
>   extern void br_dev_delete(struct net_device *dev, struct list_head *list);
>   extern netdev_tx_t br_dev_xmit(struct sk_buff *skb,
>   			       struct net_device *dev);
> +extern int br_set_promisc(struct net_bridge *br, unsigned long val);
>   #ifdef CONFIG_NET_POLL_CONTROLLER
>   static inline struct netpoll_info *br_netpoll_info(struct net_bridge *br)
>   {
> diff --git a/net/bridge/br_sysfs_br.c b/net/bridge/br_sysfs_br.c
> index 8baa9c0..5489219 100644
> --- a/net/bridge/br_sysfs_br.c
> +++ b/net/bridge/br_sysfs_br.c
> @@ -710,6 +710,22 @@ static DEVICE_ATTR(vlan_filtering, S_IRUGO | S_IWUSR,
>   		   show_vlan_filtering, store_vlan_filtering);
>   #endif
>
> +static ssize_t show_promisc(struct device *d,
> +			    struct device_attribute *attr, char *buf)
> +{
> +	struct net_bridge *br = to_bridge(d);
> +	return sprintf(buf, "%d\n", br->promisc_enabled);
> +}
> +
> +static ssize_t store_promisc(struct device *d,
> +			     struct device_attribute *attr,
> +			     const char *buf, size_t len)
> +{
> +	return store_bridge_parm(d, buf, len, br_set_promisc);
> +}
> +static DEVICE_ATTR(promisc, S_IRUGO | S_IWUSR, show_promisc,
> +		   store_promisc);
> +
>   static struct attribute *bridge_attrs[] = {
>   	&dev_attr_forward_delay.attr,
>   	&dev_attr_hello_time.attr,
> @@ -753,6 +769,7 @@ static struct attribute *bridge_attrs[] = {
>   #ifdef CONFIG_BRIDGE_VLAN_FILTERING
>   	&dev_attr_vlan_filtering.attr,
>   #endif
> +	&dev_attr_promisc.attr,
>   	NULL
>   };
>
>
