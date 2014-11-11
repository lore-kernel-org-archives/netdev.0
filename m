From: Roopa Prabhu <roopa@cumulusnetworks.com>
Subject: Re: [patch net-next v2 08/10] bridge: add API to notify bridge driver
 of learned FBD on offloaded device
Date: Tue, 11 Nov 2014 06:21:43 -0800
Message-ID: <54621B77.4050109@cumulusnetworks.com>
References: <1415530280-9190-1-git-send-email-jiri@resnulli.us> <1415530280-9190-9-git-send-email-jiri@resnulli.us>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-2; format=flowed
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, davem@davemloft.net, nhorman@tuxdriver.com,
	andy@greyhouse.net, tgraf@suug.ch, dborkman@redhat.com,
	ogerlitz@mellanox.com, jesse@nicira.com, pshelar@nicira.com,
	azhou@nicira.com, ben@decadent.org.uk, stephen@networkplumber.org,
	jeffrey.t.kirsher@intel.com, vyasevic@redhat.com,
	xiyou.wangcong@gmail.com, john.r.fastabend@intel.com,
	edumazet@google.com, jhs@mojatatu.com, sfeldma@gmail.com,
	f.fainelli@gmail.com, linville@tuxdriver.com, jasowang@redhat.com,
	ebiederm@xmission.com, nicolas.dichtel@6wind.com,
	ryazanov.s.a@gmail.com, buytenh@wantstofly.org,
	aviadr@mellanox.com, nbd@openwrt.org, alexei.starovoitov@gmail.com,
	Neil.Jerram@metaswitch.com, ronye@mellanox.com,
	simon.horman@netronome.com, alexander.h.duyck@redhat.com,
	john.ronciak@intel.com, mleitner@redhat.com, shrijeet@gmail.com,
	gospo@cumulusnetworks.com, bcrl@kvack.org
To: Jiri Pirko <jiri@resnulli.us>
Return-path: <netdev-owner@vger.kernel.org>
Received: from ext3.cumulusnetworks.com ([198.211.106.187]:55573 "EHLO
	ext3.cumulusnetworks.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751614AbaKKOVz (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 11 Nov 2014 09:21:55 -0500
In-Reply-To: <1415530280-9190-9-git-send-email-jiri@resnulli.us>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On 11/9/14, 2:51 AM, Jiri Pirko wrote:
> From: Scott Feldman <sfeldma@gmail.com>
>
> When the swdev device learns a new mac/vlan on a port, it sends some async
> notification to the driver and the driver installs an FDB in the device.
> To give a holistic system view, the learned mac/vlan should be reflected
> in the bridge's FBD table, so the user, using normal iproute2 cmds, can view
> what is currently learned by the device.  This API on the bridge driver gives
> a way for the swdev driver to install an FBD entry in the bridge FBD table.
> (And remove one).
>
> This is equivalent to the device running these cmds:
>
>    bridge fdb [add|del] <mac> dev <dev> vid <vlan id> master
>
> This patch needs some extra eyeballs for review, in paricular around the
> locking and contexts.

scott/jiri, love that you have handled this case!, This will be useful.
But, quick question, Cant this also be done using the same ndo_op that 
is done to add the static fdb..?

Thanks!.
>
> Signed-off-by: Scott Feldman <sfeldma@gmail.com>
> Signed-off-by: Jiri Pirko <jiri@resnulli.us>
> ---
>   include/linux/if_bridge.h | 18 ++++++++++
>   net/bridge/br_fdb.c       | 84 +++++++++++++++++++++++++++++++++++++++++++++++
>   2 files changed, 102 insertions(+)
>
> diff --git a/include/linux/if_bridge.h b/include/linux/if_bridge.h
> index 808dcb8..27ab217 100644
> --- a/include/linux/if_bridge.h
> +++ b/include/linux/if_bridge.h
> @@ -37,6 +37,24 @@ extern void brioctl_set(int (*ioctl_hook)(struct net *, unsigned int, void __use
>   typedef int br_should_route_hook_t(struct sk_buff *skb);
>   extern br_should_route_hook_t __rcu *br_should_route_hook;
>   
> +#if IS_ENABLED(CONFIG_BRIDGE)
> +int br_fdb_learn_add(struct net_device *dev,
> +		     const unsigned char *addr, u16 vid);
> +int br_fdb_learn_del(struct net_device *dev,
> +		     const unsigned char *addr, u16 vid);
> +#else
> +static inline int br_fdb_learn_add(struct net_device *dev,
> +				   const unsigned char *addr, u16 vid)
> +{
> +	return 0;
> +}
> +static inline int br_fdb_learn_del(struct net_device *dev,
> +				   const unsigned char *addr, u16 vid)
> +{
> +	return 0;
> +}
> +#endif
> +
>   #if IS_ENABLED(CONFIG_BRIDGE) && IS_ENABLED(CONFIG_BRIDGE_IGMP_SNOOPING)
>   int br_multicast_list_adjacent(struct net_device *dev,
>   			       struct list_head *br_ip_list);
> diff --git a/net/bridge/br_fdb.c b/net/bridge/br_fdb.c
> index f6f8bb5..e02d21b 100644
> --- a/net/bridge/br_fdb.c
> +++ b/net/bridge/br_fdb.c
> @@ -1022,3 +1022,87 @@ void br_fdb_unsync_static(struct net_bridge *br, struct net_bridge_port *p)
>   		}
>   	}
>   }
> +
> +int br_fdb_learn_add(struct net_device *dev, const unsigned char *addr,
> +		     u16 vid)
> +{
> +	struct net_bridge_port *p;
> +	struct net_bridge *br;
> +	struct hlist_head *head;
> +	struct net_bridge_fdb_entry *fdb;
> +	int err = 0;
> +
> +	rtnl_lock();
> +
> +	p = br_port_get_rtnl(dev);
> +	if (p == NULL) {
> +		pr_info("bridge: %s not a bridge port\n", dev->name);
> +		err = -EINVAL;
> +		goto err_rtnl_unlock;
> +	}
> +
> +	br = p->br;
> +
> +	spin_lock(&br->hash_lock);
> +
> +	head = &br->hash[br_mac_hash(addr, vid)];
> +	fdb = fdb_find(head, addr, vid);
> +	if (fdb == NULL) {
> +		fdb = fdb_create(head, p, addr, vid);
> +		if (!fdb) {
> +			err = -ENOMEM;
> +			goto err_unlock;
> +		}
> +		fdb->is_local = 1;
> +		fdb->used = jiffies;
> +		fdb->updated = jiffies;
> +		fdb_notify(br, fdb, RTM_NEWNEIGH);
> +	} else {
> +		err = -EEXIST;
> +	}
> +
> +err_unlock:
> +	spin_unlock(&br->hash_lock);
> +err_rtnl_unlock:
> +	rtnl_unlock();
> +
> +	return err;
> +}
> +EXPORT_SYMBOL(br_fdb_learn_add);
> +
> +int br_fdb_learn_del(struct net_device *dev, const unsigned char *addr,
> +		     u16 vid)
> +{
> +	struct net_bridge_port *p;
> +	struct net_bridge *br;
> +	struct hlist_head *head;
> +	struct net_bridge_fdb_entry *fdb;
> +	int err = 0;
> +
> +	rtnl_lock();
> +
> +	p = br_port_get_rtnl(dev);
> +	if (p == NULL) {
> +		pr_info("bridge: %s not a bridge port\n", dev->name);
> +		err = -EINVAL;
> +		goto err_rtnl_unlock;
> +	}
> +
> +	br = p->br;
> +
> +	spin_lock(&br->hash_lock);
> +
> +	head = &br->hash[br_mac_hash(addr, vid)];
> +	fdb = fdb_find(head, addr, vid);
> +	if (fdb)
> +		fdb_delete(br, fdb);
> +	else
> +		err = -ENOENT;
> +
> +	spin_unlock(&br->hash_lock);
> +err_rtnl_unlock:
> +	rtnl_unlock();
> +
> +	return err;
> +}
> +EXPORT_SYMBOL(br_fdb_learn_del);
