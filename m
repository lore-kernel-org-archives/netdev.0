From: Nikolay Aleksandrov <nikolay@redhat.com>
Subject: [RFC net-next 5/5] bonding: remove last users of bond->lock and bond->lock itself
Date: Fri,  5 Sep 2014 20:16:51 +0200
Message-ID: <1409941011-5494-6-git-send-email-nikolay@redhat.com>
References: <1409941011-5494-1-git-send-email-nikolay@redhat.com>
Cc: vfalico@gmail.com, j.vosburgh@gmail.com, andy@greyhouse.net,
	davem@davemloft.net, Nikolay Aleksandrov <nikolay@redhat.com>
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mx1.redhat.com ([209.132.183.28]:52521 "EHLO mx1.redhat.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1751732AbaIESRM (ORCPT <rfc822;netdev@vger.kernel.org>);
	Fri, 5 Sep 2014 14:17:12 -0400
In-Reply-To: <1409941011-5494-1-git-send-email-nikolay@redhat.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

The usage of bond->lock in bond_main.c was completely unnecessary as it
didn't help to sync with anything, most of the spots already had RTNL.
Since there're no more users of bond->lock, remove it.

Signed-off-by: Nikolay Aleksandrov <nikolay@redhat.com>
---
 drivers/net/bonding/bond_main.c | 39 ---------------------------------------
 drivers/net/bonding/bonding.h   |  8 ++------
 2 files changed, 2 insertions(+), 45 deletions(-)

diff --git a/drivers/net/bonding/bond_main.c b/drivers/net/bonding/bond_main.c
index dcd331bd0c17..4301c3d49fce 100644
--- a/drivers/net/bonding/bond_main.c
+++ b/drivers/net/bonding/bond_main.c
@@ -3101,7 +3101,6 @@ static int bond_open(struct net_device *bond_dev)
 	struct slave *slave;
 
 	/* reset slave->backup and slave->inactive */
-	read_lock(&bond->lock);
 	if (bond_has_slaves(bond)) {
 		read_lock(&bond->curr_slave_lock);
 		bond_for_each_slave(bond, slave, iter) {
@@ -3116,7 +3115,6 @@ static int bond_open(struct net_device *bond_dev)
 		}
 		read_unlock(&bond->curr_slave_lock);
 	}
-	read_unlock(&bond->lock);
 
 	bond_work_init_all(bond);
 
@@ -3171,7 +3169,6 @@ static struct rtnl_link_stats64 *bond_get_stats(struct net_device *bond_dev,
 
 	memset(stats, 0, sizeof(*stats));
 
-	read_lock_bh(&bond->lock);
 	bond_for_each_slave(bond, slave, iter) {
 		const struct rtnl_link_stats64 *sstats =
 			dev_get_stats(slave->dev, &temp);
@@ -3202,7 +3199,6 @@ static struct rtnl_link_stats64 *bond_get_stats(struct net_device *bond_dev,
 		stats->tx_heartbeat_errors += sstats->tx_heartbeat_errors;
 		stats->tx_window_errors += sstats->tx_window_errors;
 	}
-	read_unlock_bh(&bond->lock);
 
 	return stats;
 }
@@ -3242,13 +3238,11 @@ static int bond_do_ioctl(struct net_device *bond_dev, struct ifreq *ifr, int cmd
 
 		if (mii->reg_num == 1) {
 			mii->val_out = 0;
-			read_lock(&bond->lock);
 			read_lock(&bond->curr_slave_lock);
 			if (netif_carrier_ok(bond->dev))
 				mii->val_out = BMSR_LSTATUS;
 
 			read_unlock(&bond->curr_slave_lock);
-			read_unlock(&bond->lock);
 		}
 
 		return 0;
@@ -3424,21 +3418,6 @@ static int bond_change_mtu(struct net_device *bond_dev, int new_mtu)
 
 	netdev_dbg(bond_dev, "bond=%p, new_mtu=%d\n", bond, new_mtu);
 
-	/* Can't hold bond->lock with bh disabled here since
-	 * some base drivers panic. On the other hand we can't
-	 * hold bond->lock without bh disabled because we'll
-	 * deadlock. The only solution is to rely on the fact
-	 * that we're under rtnl_lock here, and the slaves
-	 * list won't change. This doesn't solve the problem
-	 * of setting the slave's MTU while it is
-	 * transmitting, but the assumption is that the base
-	 * driver can handle that.
-	 *
-	 * TODO: figure out a way to safely iterate the slaves
-	 * list, but without holding a lock around the actual
-	 * call to the base driver.
-	 */
-
 	bond_for_each_slave(bond, slave, iter) {
 		netdev_dbg(bond_dev, "s %p c_m %p\n",
 			   slave, slave->dev->netdev_ops->ndo_change_mtu);
@@ -3513,21 +3492,6 @@ static int bond_set_mac_address(struct net_device *bond_dev, void *addr)
 	if (!is_valid_ether_addr(sa->sa_data))
 		return -EADDRNOTAVAIL;
 
-	/* Can't hold bond->lock with bh disabled here since
-	 * some base drivers panic. On the other hand we can't
-	 * hold bond->lock without bh disabled because we'll
-	 * deadlock. The only solution is to rely on the fact
-	 * that we're under rtnl_lock here, and the slaves
-	 * list won't change. This doesn't solve the problem
-	 * of setting the slave's hw address while it is
-	 * transmitting, but the assumption is that the base
-	 * driver can handle that.
-	 *
-	 * TODO: figure out a way to safely iterate the slaves
-	 * list, but without holding a lock around the actual
-	 * call to the base driver.
-	 */
-
 	bond_for_each_slave(bond, slave, iter) {
 		netdev_dbg(bond_dev, "slave %p %s\n", slave, slave->dev->name);
 		res = dev_set_mac_address(slave->dev, addr);
@@ -3853,7 +3817,6 @@ static int bond_ethtool_get_settings(struct net_device *bond_dev,
 	 * the true receive or transmit bandwidth (not all modes are symmetric)
 	 * this is an accurate maximum.
 	 */
-	read_lock(&bond->lock);
 	bond_for_each_slave(bond, slave, iter) {
 		if (bond_slave_can_tx(slave)) {
 			if (slave->speed != SPEED_UNKNOWN)
@@ -3864,7 +3827,6 @@ static int bond_ethtool_get_settings(struct net_device *bond_dev,
 		}
 	}
 	ethtool_cmd_speed_set(ecmd, speed ? : SPEED_UNKNOWN);
-	read_unlock(&bond->lock);
 
 	return 0;
 }
@@ -3927,7 +3889,6 @@ void bond_setup(struct net_device *bond_dev)
 	struct bonding *bond = netdev_priv(bond_dev);
 
 	/* initialize rwlocks */
-	rwlock_init(&bond->lock);
 	rwlock_init(&bond->curr_slave_lock);
 	bond->params = bonding_defaults;
 
diff --git a/drivers/net/bonding/bonding.h b/drivers/net/bonding/bonding.h
index aace510d08d1..1f44a78283ad 100644
--- a/drivers/net/bonding/bonding.h
+++ b/drivers/net/bonding/bonding.h
@@ -83,7 +83,7 @@
  * @pos:	current slave
  * @iter:	list_head * iterator
  *
- * Caller must hold bond->lock
+ * Caller must hold RTNL
  */
 #define bond_for_each_slave(bond, pos, iter) \
 	netdev_for_each_lower_private((bond)->dev, pos, iter)
@@ -185,11 +185,8 @@ struct slave {
 /*
  * Here are the locking policies for the two bonding locks:
  *
- * 1) Get bond->lock when reading/writing slave list.
+ * 1) Get rcu_read_lock when reading or RTNL when writing slave list.
  * 2) Get bond->curr_slave_lock when reading/writing bond->curr_active_slave.
- *    (It is unnecessary when the write-lock is put with bond->lock.)
- * 3) When we lock with bond->curr_slave_lock, we must lock with bond->lock
- *    beforehand.
  */
 struct bonding {
 	struct   net_device *dev; /* first - useful for panic debug */
@@ -200,7 +197,6 @@ struct bonding {
 	s32      slave_cnt; /* never change this value outside the attach/detach wrappers */
 	int     (*recv_probe)(const struct sk_buff *, struct bonding *,
 			      struct slave *);
-	rwlock_t lock;
 	rwlock_t curr_slave_lock;
 	u8	 send_peer_notif;
 	u8       igmp_retrans;
-- 
1.9.3
