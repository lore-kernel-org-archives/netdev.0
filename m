From: Roopa Prabhu <roopa@cumulusnetworks.com>
Subject: Re: [PATCH net-next] rtnetlink: delay RTM_DELLINK notification until
 after ndo_uninit()
Date: Tue, 02 Dec 2014 08:08:56 -0800
Message-ID: <547DE418.9000309@cumulusnetworks.com>
References: <1417499650-29176-1-git-send-email-maheshb@google.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1; format=flowed
Content-Transfer-Encoding: 7bit
Cc: netdev <netdev@vger.kernel.org>,
	David Miller <davem@davemloft.net>,
	Eric Dumazet <edumazet@google.com>,
	Toshiaki Makita <makita.toshiaki@lab.ntt.co.jp>
To: Mahesh Bandewar <maheshb@google.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from ext3.cumulusnetworks.com ([198.211.106.187]:49361 "EHLO
	ext3.cumulusnetworks.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1753711AbaLBQJQ (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 2 Dec 2014 11:09:16 -0500
In-Reply-To: <1417499650-29176-1-git-send-email-maheshb@google.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On 12/1/14, 9:54 PM, Mahesh Bandewar wrote:
> The commit 56bfa7ee7c ("unregister_netdevice : move RTM_DELLINK to
> until after ndo_uninit") tried to do this ealier but while doing so
> it created a problem. Unfortunately the delayed rtmsg_ifinfo() also
> delayed call to fill_info(). So this translated into asking driver
> to remove private state and then quert it's private state. This
> could have catastropic consequences.
>
> This change breaks the rtmsg_ifinfo() into two parts - one fills the
> skb by calling fill_info() prior to calling ndo_uninit() and the second
> part just sends the message using the skb filled earlier.
>
> It was brought to notice when last link is deleted from an ipvlan device
> when it has free-ed the port and the subsequent .fill_info() call is
> trying to get the info from the port.
>
> kernel: [  255.139429] ------------[ cut here ]------------
> kernel: [  255.139439] WARNING: CPU: 12 PID: 11173 at net/core/rtnetlink.c:2238 rtmsg_ifinfo+0x100/0x110()
> kernel: [  255.139493] Modules linked in: ipvlan bonding w1_therm ds2482 wire cdc_acm ehci_pci ehci_hcd i2c_dev i2c_i801 i2c_core msr cpuid bnx2x ptp pps_core mdio libcrc32c
> kernel: [  255.139513] CPU: 12 PID: 11173 Comm: ip Not tainted 3.18.0-smp-DEV #167
> kernel: [  255.139514] Hardware name: Intel RML,PCH/Ibis_QC_18, BIOS 1.0.10 05/15/2012
> kernel: [  255.139515]  0000000000000009 ffff880851b6b828 ffffffff815d87f4 00000000000000e0
> kernel: [  255.139516]  0000000000000000 ffff880851b6b868 ffffffff8109c29c 0000000000000000
> kernel: [  255.139518]  00000000ffffffa6 00000000000000d0 ffffffff81aaf580 0000000000000011
> kernel: [  255.139520] Call Trace:
> kernel: [  255.139527]  [<ffffffff815d87f4>] dump_stack+0x46/0x58
> kernel: [  255.139531]  [<ffffffff8109c29c>] warn_slowpath_common+0x8c/0xc0
> kernel: [  255.139540]  [<ffffffff8109c2ea>] warn_slowpath_null+0x1a/0x20
> kernel: [  255.139544]  [<ffffffff8150d570>] rtmsg_ifinfo+0x100/0x110
> kernel: [  255.139547]  [<ffffffff814f78b5>] rollback_registered_many+0x1d5/0x2d0
> kernel: [  255.139549]  [<ffffffff814f79cf>] unregister_netdevice_many+0x1f/0xb0
> kernel: [  255.139551]  [<ffffffff8150acab>] rtnl_dellink+0xbb/0x110
> kernel: [  255.139553]  [<ffffffff8150da90>] rtnetlink_rcv_msg+0xa0/0x240
> kernel: [  255.139557]  [<ffffffff81329283>] ? rhashtable_lookup_compare+0x43/0x80
> kernel: [  255.139558]  [<ffffffff8150d9f0>] ? __rtnl_unlock+0x20/0x20
> kernel: [  255.139562]  [<ffffffff8152cb11>] netlink_rcv_skb+0xb1/0xc0
> kernel: [  255.139563]  [<ffffffff8150a495>] rtnetlink_rcv+0x25/0x40
> kernel: [  255.139565]  [<ffffffff8152c398>] netlink_unicast+0x178/0x230
> kernel: [  255.139567]  [<ffffffff8152c75f>] netlink_sendmsg+0x30f/0x420
> kernel: [  255.139571]  [<ffffffff814e0b0c>] sock_sendmsg+0x9c/0xd0
> kernel: [  255.139575]  [<ffffffff811d1d7f>] ? rw_copy_check_uvector+0x6f/0x130
> kernel: [  255.139577]  [<ffffffff814e11c9>] ? copy_msghdr_from_user+0x139/0x1b0
> kernel: [  255.139578]  [<ffffffff814e1774>] ___sys_sendmsg+0x304/0x310
> kernel: [  255.139581]  [<ffffffff81198723>] ? handle_mm_fault+0xca3/0xde0
> kernel: [  255.139585]  [<ffffffff811ebc4c>] ? destroy_inode+0x3c/0x70
> kernel: [  255.139589]  [<ffffffff8108e6ec>] ? __do_page_fault+0x20c/0x500
> kernel: [  255.139597]  [<ffffffff811e8336>] ? dput+0xb6/0x190
> kernel: [  255.139606]  [<ffffffff811f05f6>] ? mntput+0x26/0x40
> kernel: [  255.139611]  [<ffffffff811d2b94>] ? __fput+0x174/0x1e0
> kernel: [  255.139613]  [<ffffffff814e2129>] __sys_sendmsg+0x49/0x90
> kernel: [  255.139615]  [<ffffffff814e2182>] SyS_sendmsg+0x12/0x20
> kernel: [  255.139617]  [<ffffffff815df092>] system_call_fastpath+0x12/0x17
> kernel: [  255.139619] ---[ end trace 5e6703e87d984f6b ]---

interestingly I have never seen this. We use this heavily with most 
other logical devices.
Which tells me most logical devices do have checks in their fill_info.
The patch idea is good. My only concern is stale information
in the DELLINK notification. Because,  ndo_uninit() does do a lot of 
cleanup, sending
newlink's for some of these cleanup changes. And now with your patch the 
dellink notification
skb probably  contains information that has been already deleted by 
ndo_uninit ?





>
> Signed-off-by: Mahesh Bandewar <maheshb@google.com>
> Report-by: Toshiaki Makita <makita.toshiaki@lab.ntt.co.jp>
> Cc: Eric Dumazet <edumazet@google.com>
> Cc: Roopa Prabhu <roopa@cumulusnetworks.com>
> Cc: David S. Miller <davem@davemloft.net>
> ---
>   drivers/net/bonding/bond_main.c |  4 ++--
>   include/linux/rtnetlink.h       |  6 +++++-
>   include/net/bonding.h           |  8 ++++----
>   net/core/dev.c                  | 26 ++++++++++++++++----------
>   net/core/rtnetlink.c            | 20 ++++++++++++++++----
>   5 files changed, 43 insertions(+), 21 deletions(-)
>
> diff --git a/drivers/net/bonding/bond_main.c b/drivers/net/bonding/bond_main.c
> index 184c434ae305..06206a1439a4 100644
> --- a/drivers/net/bonding/bond_main.c
> +++ b/drivers/net/bonding/bond_main.c
> @@ -1135,7 +1135,7 @@ static int bond_master_upper_dev_link(struct net_device *bond_dev,
>   	if (err)
>   		return err;
>   	slave_dev->flags |= IFF_SLAVE;
> -	rtmsg_ifinfo(RTM_NEWLINK, slave_dev, IFF_SLAVE, GFP_KERNEL);
> +	rtmsg_ifinfo(RTM_NEWLINK, slave_dev, IFF_SLAVE, GFP_KERNEL, false);
>   	return 0;
>   }
>   
> @@ -1144,7 +1144,7 @@ static void bond_upper_dev_unlink(struct net_device *bond_dev,
>   {
>   	netdev_upper_dev_unlink(slave_dev, bond_dev);
>   	slave_dev->flags &= ~IFF_SLAVE;
> -	rtmsg_ifinfo(RTM_NEWLINK, slave_dev, IFF_SLAVE, GFP_KERNEL);
> +	rtmsg_ifinfo(RTM_NEWLINK, slave_dev, IFF_SLAVE, GFP_KERNEL, false);
>   }
>   
>   static struct slave *bond_alloc_slave(struct bonding *bond)
> diff --git a/include/linux/rtnetlink.h b/include/linux/rtnetlink.h
> index 6cacbce1a06c..545dd0b8c83d 100644
> --- a/include/linux/rtnetlink.h
> +++ b/include/linux/rtnetlink.h
> @@ -16,7 +16,11 @@ extern int rtnetlink_put_metrics(struct sk_buff *skb, u32 *metrics);
>   extern int rtnl_put_cacheinfo(struct sk_buff *skb, struct dst_entry *dst,
>   			      u32 id, long expires, u32 error);
>   
> -void rtmsg_ifinfo(int type, struct net_device *dev, unsigned change, gfp_t flags);
> +struct sk_buff *rtmsg_ifinfo(int type, struct net_device *dev, unsigned change,
> +			     gfp_t flags, bool fill_only);
> +void rtmsg_ifinfo_send(struct sk_buff *skb, struct net_device *dev,
> +		       gfp_t flags);
> +
>   
>   /* RTNL is used as a global lock for all changes to network configuration  */
>   extern void rtnl_lock(void);
> diff --git a/include/net/bonding.h b/include/net/bonding.h
> index 983a94b86b95..ea09f6c5af51 100644
> --- a/include/net/bonding.h
> +++ b/include/net/bonding.h
> @@ -315,7 +315,7 @@ static inline void bond_set_active_slave(struct slave *slave)
>   {
>   	if (slave->backup) {
>   		slave->backup = 0;
> -		rtmsg_ifinfo(RTM_NEWLINK, slave->dev, 0, GFP_ATOMIC);
> +		rtmsg_ifinfo(RTM_NEWLINK, slave->dev, 0, GFP_ATOMIC, false);
>   	}
>   }
>   
> @@ -323,7 +323,7 @@ static inline void bond_set_backup_slave(struct slave *slave)
>   {
>   	if (!slave->backup) {
>   		slave->backup = 1;
> -		rtmsg_ifinfo(RTM_NEWLINK, slave->dev, 0, GFP_ATOMIC);
> +		rtmsg_ifinfo(RTM_NEWLINK, slave->dev, 0, GFP_ATOMIC, false);
>   	}
>   }
>   
> @@ -335,7 +335,7 @@ static inline void bond_set_slave_state(struct slave *slave,
>   
>   	slave->backup = slave_state;
>   	if (notify) {
> -		rtmsg_ifinfo(RTM_NEWLINK, slave->dev, 0, GFP_ATOMIC);
> +		rtmsg_ifinfo(RTM_NEWLINK, slave->dev, 0, GFP_ATOMIC, false);
>   		slave->should_notify = 0;
>   	} else {
>   		if (slave->should_notify)
> @@ -365,7 +365,7 @@ static inline void bond_slave_state_notify(struct bonding *bond)
>   
>   	bond_for_each_slave(bond, tmp, iter) {
>   		if (tmp->should_notify) {
> -			rtmsg_ifinfo(RTM_NEWLINK, tmp->dev, 0, GFP_ATOMIC);
> +			rtmsg_ifinfo(RTM_NEWLINK, tmp->dev, 0, GFP_ATOMIC, false);
>   			tmp->should_notify = 0;
>   		}
>   	}
> diff --git a/net/core/dev.c b/net/core/dev.c
> index ac4836241a96..29bc78d5e6cb 100644
> --- a/net/core/dev.c
> +++ b/net/core/dev.c
> @@ -1230,7 +1230,7 @@ void netdev_state_change(struct net_device *dev)
>   		change_info.flags_changed = 0;
>   		call_netdevice_notifiers_info(NETDEV_CHANGE, dev,
>   					      &change_info.info);
> -		rtmsg_ifinfo(RTM_NEWLINK, dev, 0, GFP_KERNEL);
> +		rtmsg_ifinfo(RTM_NEWLINK, dev, 0, GFP_KERNEL, false);
>   	}
>   }
>   EXPORT_SYMBOL(netdev_state_change);
> @@ -1319,7 +1319,7 @@ int dev_open(struct net_device *dev)
>   	if (ret < 0)
>   		return ret;
>   
> -	rtmsg_ifinfo(RTM_NEWLINK, dev, IFF_UP|IFF_RUNNING, GFP_KERNEL);
> +	rtmsg_ifinfo(RTM_NEWLINK, dev, IFF_UP|IFF_RUNNING, GFP_KERNEL, false);
>   	call_netdevice_notifiers(NETDEV_UP, dev);
>   
>   	return ret;
> @@ -1396,7 +1396,8 @@ static int dev_close_many(struct list_head *head)
>   	__dev_close_many(head);
>   
>   	list_for_each_entry_safe(dev, tmp, head, close_list) {
> -		rtmsg_ifinfo(RTM_NEWLINK, dev, IFF_UP|IFF_RUNNING, GFP_KERNEL);
> +		rtmsg_ifinfo(RTM_NEWLINK, dev, IFF_UP|IFF_RUNNING,
> +			     GFP_KERNEL, false);
>   		call_netdevice_notifiers(NETDEV_DOWN, dev);
>   		list_del_init(&dev->close_list);
>   	}
> @@ -5683,7 +5684,7 @@ void __dev_notify_flags(struct net_device *dev, unsigned int old_flags,
>   	unsigned int changes = dev->flags ^ old_flags;
>   
>   	if (gchanges)
> -		rtmsg_ifinfo(RTM_NEWLINK, dev, gchanges, GFP_ATOMIC);
> +		rtmsg_ifinfo(RTM_NEWLINK, dev, gchanges, GFP_ATOMIC, false);
>   
>   	if (changes & IFF_UP) {
>   		if (dev->flags & IFF_UP)
> @@ -5925,6 +5926,8 @@ static void rollback_registered_many(struct list_head *head)
>   	synchronize_net();
>   
>   	list_for_each_entry(dev, head, unreg_list) {
> +		struct sk_buff *skb = NULL;
> +
>   		/* Shutdown queueing discipline. */
>   		dev_shutdown(dev);
>   
> @@ -5934,6 +5937,10 @@ static void rollback_registered_many(struct list_head *head)
>   		*/
>   		call_netdevice_notifiers(NETDEV_UNREGISTER, dev);
>   
> +		if (!dev->rtnl_link_ops ||
> +		    dev->rtnl_link_state == RTNL_LINK_INITIALIZED)
> +			skb = rtmsg_ifinfo(RTM_DELLINK, dev, ~0U, GFP_KERNEL, true);
> +
>   		/*
>   		 *	Flush the unicast and multicast chains
>   		 */
> @@ -5943,9 +5950,8 @@ static void rollback_registered_many(struct list_head *head)
>   		if (dev->netdev_ops->ndo_uninit)
>   			dev->netdev_ops->ndo_uninit(dev);
>   
> -		if (!dev->rtnl_link_ops ||
> -		    dev->rtnl_link_state == RTNL_LINK_INITIALIZED)
> -			rtmsg_ifinfo(RTM_DELLINK, dev, ~0U, GFP_KERNEL);
> +		if (skb)
> +			rtmsg_ifinfo_send(skb, dev, GFP_KERNEL);
>   
>   		/* Notifier chain MUST detach us all upper devices. */
>   		WARN_ON(netdev_has_any_upper_dev(dev));
> @@ -6334,7 +6340,7 @@ int register_netdevice(struct net_device *dev)
>   	 */
>   	if (!dev->rtnl_link_ops ||
>   	    dev->rtnl_link_state == RTNL_LINK_INITIALIZED)
> -		rtmsg_ifinfo(RTM_NEWLINK, dev, ~0U, GFP_KERNEL);
> +		rtmsg_ifinfo(RTM_NEWLINK, dev, ~0U, GFP_KERNEL, false);
>   
>   out:
>   	return ret;
> @@ -6959,7 +6965,7 @@ int dev_change_net_namespace(struct net_device *dev, struct net *net, const char
>   	call_netdevice_notifiers(NETDEV_UNREGISTER, dev);
>   	rcu_barrier();
>   	call_netdevice_notifiers(NETDEV_UNREGISTER_FINAL, dev);
> -	rtmsg_ifinfo(RTM_DELLINK, dev, ~0U, GFP_KERNEL);
> +	rtmsg_ifinfo(RTM_DELLINK, dev, ~0U, GFP_KERNEL, false);
>   
>   	/*
>   	 *	Flush the unicast and multicast chains
> @@ -7000,7 +7006,7 @@ int dev_change_net_namespace(struct net_device *dev, struct net *net, const char
>   	 *	Prevent userspace races by waiting until the network
>   	 *	device is fully setup before sending notifications.
>   	 */
> -	rtmsg_ifinfo(RTM_NEWLINK, dev, ~0U, GFP_KERNEL);
> +	rtmsg_ifinfo(RTM_NEWLINK, dev, ~0U, GFP_KERNEL, false);
>   
>   	synchronize_net();
>   	err = 0;
> diff --git a/net/core/rtnetlink.c b/net/core/rtnetlink.c
> index b9b7dfaf202b..1035d8cdbc08 100644
> --- a/net/core/rtnetlink.c
> +++ b/net/core/rtnetlink.c
> @@ -2220,8 +2220,16 @@ static int rtnl_dump_all(struct sk_buff *skb, struct netlink_callback *cb)
>   	return skb->len;
>   }
>   
> -void rtmsg_ifinfo(int type, struct net_device *dev, unsigned int change,
> -		  gfp_t flags)
> +void rtmsg_ifinfo_send(struct sk_buff *skb, struct net_device *dev, gfp_t flags)
> +{
> +	struct net *net = dev_net(dev);
> +
> +	rtnl_notify(skb, net, 0, RTNLGRP_LINK, NULL, flags);
> +}
> +EXPORT_SYMBOL(rtmsg_ifinfo_send);
> +
> +struct sk_buff *rtmsg_ifinfo(int type, struct net_device *dev,
> +			     unsigned int change, gfp_t flags, bool fill_only)
>   {
>   	struct net *net = dev_net(dev);
>   	struct sk_buff *skb;
> @@ -2239,11 +2247,15 @@ void rtmsg_ifinfo(int type, struct net_device *dev, unsigned int change,
>   		kfree_skb(skb);
>   		goto errout;
>   	}
> +	if (fill_only)
> +	    return skb;
> +
>   	rtnl_notify(skb, net, 0, RTNLGRP_LINK, NULL, flags);
> -	return;
> +	return NULL;
>   errout:
>   	if (err < 0)
>   		rtnl_set_sk_err(net, RTNLGRP_LINK, err);
> +	return NULL;
>   }
>   EXPORT_SYMBOL(rtmsg_ifinfo);
>   
> @@ -3011,7 +3023,7 @@ static int rtnetlink_event(struct notifier_block *this, unsigned long event, voi
>   	case NETDEV_JOIN:
>   		break;
>   	default:
> -		rtmsg_ifinfo(RTM_NEWLINK, dev, 0, GFP_KERNEL);
> +		rtmsg_ifinfo(RTM_NEWLINK, dev, 0, GFP_KERNEL, false);
>   		break;
>   	}
>   	return NOTIFY_DONE;
