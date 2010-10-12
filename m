From: nhorman@tuxdriver.com
Subject: [PATCH 2/5] Fix deadlock in bonding driver resulting from internal locking when using netpoll
Date: Tue, 12 Oct 2010 16:29:34 -0400
Message-ID: <1286915377-1612-3-git-send-email-nhorman@tuxdriver.com>
References: <1286915377-1612-1-git-send-email-nhorman@tuxdriver.com>
Cc: bonding-devel@lists.sourceforge.net, fubar@us.ibm.com,
	davem@davemloft.net, andy@greyhouse.net, amwang@redhat.com,
	nhorman@tuxdriver.com
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from cpe-076-182-075-229.nc.res.rr.com ([76.182.75.229]:50234 "EHLO
	localhost.localdomain" rhost-flags-OK-OK-OK-FAIL) by vger.kernel.org
	with ESMTP id S1751032Ab0JLVXM (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 12 Oct 2010 17:23:12 -0400
In-Reply-To: <1286915377-1612-1-git-send-email-nhorman@tuxdriver.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Neil Horman <nhorman@tuxdriver.com>

The monitoring paths in the bonding driver take write locks that are shared by
the tx path.  If netconsole is in use, these paths can call printk which puts us
in the netpoll tx path, which, if netconsole is attached to the bonding driver,
result in deadlock (the xmit_lock guards are useless in netpoll_send_skb, as the
monitor paths in the bonding driver don't claim the xmit_lock, nor should they).
The solution is to use a per cpu flag internal to the driver to indicate when a
cpu is holding the lock in a path that might recusrse into the tx path for the
driver via netconsole.  By checking this flag on transmit, we can defer the
sending of the netconsole frames until a later time using the retransmit feature
of netpoll_send_skb that is triggered on the return code NETDEV_TX_BUSY.  I've
tested this and am able to transmit via netconsole while causing failover
conditions on the bond slave links.

Signed-off-by: Neil Horman <nhorman@tuxdriver.com>
---
 drivers/net/bonding/bond_main.c |   67 ++++++++++++++++++++++++++++++++++++--
 1 files changed, 63 insertions(+), 4 deletions(-)

diff --git a/drivers/net/bonding/bond_main.c b/drivers/net/bonding/bond_main.c
index eb7d089..1d0d8c5 100644
--- a/drivers/net/bonding/bond_main.c
+++ b/drivers/net/bonding/bond_main.c
@@ -76,6 +76,7 @@
 #include <linux/if_vlan.h>
 #include <linux/if_bonding.h>
 #include <linux/jiffies.h>
+#include <linux/preempt.h>
 #include <net/route.h>
 #include <net/net_namespace.h>
 #include <net/netns/generic.h>
@@ -169,6 +170,35 @@ MODULE_PARM_DESC(resend_igmp, "Number of IGMP membership reports to send on link
 
 /*----------------------------- Global variables ----------------------------*/
 
+#ifdef CONFIG_NET_POLL_CONTROLLER
+static cpumask_var_t netpoll_block_tx;
+
+static inline void block_netpoll_tx(void
+{
+	preempt_disable();
+	BUG_ON(cpumask_test_and_set_cpu(smp_processor_id(),
+					netpoll_block_tx));
+}
+
+static inline void unblock_netpoll_tx(void)
+{
+	BUG_ON(!cpumask_test_and_clear_cpu(smp_processor_id(),
+					  netpoll_block_tx));
+	preempt_enable();
+}
+
+static inline int is_netpoll_tx_blocked(struct net_device *dev)
+{
+	if (unlikely(dev->priv_flags & IFF_IN_NETPOLL))
+		return cpumask_test_cpu(smp_processor_id(), netpoll_block_tx);
+	return 0;
+}
+#else
+#define block_netpoll_tx()
+#define unblock_netpoll_tx()
+#define is_netpoll_tx_blocked(dev)
+#endif
+
 static const char * const version =
 	DRV_DESCRIPTION ": v" DRV_VERSION " (" DRV_RELDATE ")\n";
 
@@ -310,6 +340,7 @@ static int bond_del_vlan(struct bonding *bond, unsigned short vlan_id)
 
 	pr_debug("bond: %s, vlan id %d\n", bond->dev->name, vlan_id);
 
+	block_netpoll_tx();
 	write_lock_bh(&bond->lock);
 
 	list_for_each_entry(vlan, &bond->vlan_list, vlan_list) {
@@ -344,6 +375,7 @@ static int bond_del_vlan(struct bonding *bond, unsigned short vlan_id)
 
 out:
 	write_unlock_bh(&bond->lock);
+	unblock_netpoll_tx();
 	return res;
 }
 
@@ -1804,10 +1836,6 @@ int bond_enslave(struct net_device *bond_dev, struct net_device *slave_dev)
 	bond_set_carrier(bond);
 
 #ifdef CONFIG_NET_POLL_CONTROLLER
-	/*
-	 * Netpoll and bonding is broken, make sure it is not initialized
-	 * until it is fixed.
-	 */
 	if (disable_netpoll) {
 		bond_dev->priv_flags |= IFF_DISABLE_NETPOLL;
 	} else {
@@ -1892,6 +1920,7 @@ int bond_release(struct net_device *bond_dev, struct net_device *slave_dev)
 		return -EINVAL;
 	}
 
+	block_netpoll_tx();
 	netdev_bonding_change(bond_dev, NETDEV_BONDING_DESLAVE);
 	write_lock_bh(&bond->lock);
 
@@ -1901,6 +1930,7 @@ int bond_release(struct net_device *bond_dev, struct net_device *slave_dev)
 		pr_info("%s: %s not enslaved\n",
 			bond_dev->name, slave_dev->name);
 		write_unlock_bh(&bond->lock);
+		unblock_netpoll_tx();
 		return -EINVAL;
 	}
 
@@ -1994,6 +2024,7 @@ int bond_release(struct net_device *bond_dev, struct net_device *slave_dev)
 	}
 
 	write_unlock_bh(&bond->lock);
+	unblock_netpoll_tx();
 
 	/* must do this from outside any spinlocks */
 	bond_destroy_slave_symlinks(bond_dev, slave_dev);
@@ -2085,6 +2116,7 @@ static int bond_release_all(struct net_device *bond_dev)
 	struct net_device *slave_dev;
 	struct sockaddr addr;
 
+	block_netpoll_tx();
 	write_lock_bh(&bond->lock);
 
 	netif_carrier_off(bond_dev);
@@ -2183,6 +2215,7 @@ static int bond_release_all(struct net_device *bond_dev)
 
 out:
 	write_unlock_bh(&bond->lock);
+	unblock_netpoll_tx();
 
 	return 0;
 }
@@ -2232,9 +2265,11 @@ static int bond_ioctl_change_active(struct net_device *bond_dev, struct net_devi
 	    (old_active) &&
 	    (new_active->link == BOND_LINK_UP) &&
 	    IS_UP(new_active->dev)) {
+		block_netpoll_tx();
 		write_lock_bh(&bond->curr_slave_lock);
 		bond_change_active_slave(bond, new_active);
 		write_unlock_bh(&bond->curr_slave_lock);
+		unblock_netpoll_tx();
 	} else
 		res = -EINVAL;
 
@@ -2466,9 +2501,11 @@ static void bond_miimon_commit(struct bonding *bond)
 
 do_failover:
 		ASSERT_RTNL();
+		block_netpoll_tx();
 		write_lock_bh(&bond->curr_slave_lock);
 		bond_select_active_slave(bond);
 		write_unlock_bh(&bond->curr_slave_lock);
+		unblock_netpoll_tx();
 	}
 
 	bond_set_carrier(bond);
@@ -2911,11 +2948,13 @@ void bond_loadbalance_arp_mon(struct work_struct *work)
 	}
 
 	if (do_failover) {
+		block_netpoll_tx();
 		write_lock_bh(&bond->curr_slave_lock);
 
 		bond_select_active_slave(bond);
 
 		write_unlock_bh(&bond->curr_slave_lock);
+		unblock_netpoll_tx();
 	}
 
 re_arm:
@@ -3074,9 +3113,11 @@ static void bond_ab_arp_commit(struct bonding *bond, int delta_in_ticks)
 
 do_failover:
 		ASSERT_RTNL();
+		block_netpoll_tx();
 		write_lock_bh(&bond->curr_slave_lock);
 		bond_select_active_slave(bond);
 		write_unlock_bh(&bond->curr_slave_lock);
+		unblock_netpoll_tx();
 	}
 
 	bond_set_carrier(bond);
@@ -4564,6 +4605,13 @@ static netdev_tx_t bond_start_xmit(struct sk_buff *skb, struct net_device *dev)
 {
 	struct bonding *bond = netdev_priv(dev);
 
+	/*
+	 * If we risk deadlock from transmitting this in the
+	 * netpoll path, tell netpoll to queue the frame for later tx
+	 */
+	if (is_netpoll_tx_blocked(dev))
+		return NETDEV_TX_BUSY;
+
 	if (TX_QUEUE_OVERRIDE(bond->params.mode)) {
 		if (!bond_slave_override(bond, skb))
 			return NETDEV_TX_OK;
@@ -5295,6 +5343,13 @@ static int __init bonding_init(void)
 	if (res)
 		goto err;
 
+#ifdef CONFIG_NET_POLL_CONTROLLER
+	if (!alloc_cpumask_var(&netpoll_block_tx, GFP_KERNEL)) {
+		res = -ENOMEM;
+		bond_destroy_sysfs();
+		goto err;
+	}
+#endif
 	register_netdevice_notifier(&bond_netdev_notifier);
 	register_inetaddr_notifier(&bond_inetaddr_notifier);
 	bond_register_ipv6_notifier();
@@ -5316,6 +5371,10 @@ static void __exit bonding_exit(void)
 
 	bond_destroy_sysfs();
 
+#ifdef CONFIG_NET_POLL_CONTROLLER
+	free_cpumask_var(netpoll_block_tx);
+#endif
+
 	rtnl_link_unregister(&bond_link_ops);
 	unregister_pernet_subsys(&bond_net_ops);
 }
-- 
1.7.2.3

