From: Jiri Pirko <jpirko@redhat.com>
Subject: [patch net-next-2.6 4/8] bonding: wrap slave state work
Date: Sat,  5 Mar 2011 11:29:25 +0100
Message-ID: <1299320969-7951-5-git-send-email-jpirko@redhat.com>
References: <1299320969-7951-1-git-send-email-jpirko@redhat.com>
Cc: davem@davemloft.net, shemminger@linux-foundation.org,
	kaber@trash.net, fubar@us.ibm.com, eric.dumazet@gmail.com,
	nicolas.2p.debian@gmail.com, andy@greyhouse.net
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mx1.redhat.com ([209.132.183.28]:20091 "EHLO mx1.redhat.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1752484Ab1CEK3o (ORCPT <rfc822;netdev@vger.kernel.org>);
	Sat, 5 Mar 2011 05:29:44 -0500
In-Reply-To: <1299320969-7951-1-git-send-email-jpirko@redhat.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

transfers slave->state into slave->backup (that it's going to transfer
into bitfield. Introduce wrapper inlines to do the work with it.

Signed-off-by: Jiri Pirko <jpirko@redhat.com>
---
 drivers/net/bonding/bond_3ad.c   |    2 +-
 drivers/net/bonding/bond_main.c  |   36 ++++++++++++++++++------------------
 drivers/net/bonding/bond_sysfs.c |    2 +-
 drivers/net/bonding/bonding.h    |   31 ++++++++++++++++++++++++++-----
 4 files changed, 46 insertions(+), 25 deletions(-)

diff --git a/drivers/net/bonding/bond_3ad.c b/drivers/net/bonding/bond_3ad.c
index 1024ae1..047af0b 100644
--- a/drivers/net/bonding/bond_3ad.c
+++ b/drivers/net/bonding/bond_3ad.c
@@ -246,7 +246,7 @@ static inline void __enable_port(struct port *port)
  */
 static inline int __port_is_enabled(struct port *port)
 {
-	return port->slave->state == BOND_STATE_ACTIVE;
+	return bond_is_active_slave(port->slave);
 }
 
 /**
diff --git a/drivers/net/bonding/bond_main.c b/drivers/net/bonding/bond_main.c
index 7923184..62020a7 100644
--- a/drivers/net/bonding/bond_main.c
+++ b/drivers/net/bonding/bond_main.c
@@ -1872,7 +1872,7 @@ int bond_enslave(struct net_device *bond_dev, struct net_device *slave_dev)
 		break;
 	case BOND_MODE_TLB:
 	case BOND_MODE_ALB:
-		new_slave->state = BOND_STATE_ACTIVE;
+		bond_set_active_slave(new_slave);
 		bond_set_slave_inactive_flags(new_slave);
 		bond_select_active_slave(bond);
 		break;
@@ -1880,7 +1880,7 @@ int bond_enslave(struct net_device *bond_dev, struct net_device *slave_dev)
 		pr_debug("This slave is always active in trunk mode\n");
 
 		/* always active in trunk mode */
-		new_slave->state = BOND_STATE_ACTIVE;
+		bond_set_active_slave(new_slave);
 
 		/* In trunking mode there is little meaning to curr_active_slave
 		 * anyway (it holds no special properties of the bond device),
@@ -1918,7 +1918,7 @@ int bond_enslave(struct net_device *bond_dev, struct net_device *slave_dev)
 
 	pr_info("%s: enslaving %s as a%s interface with a%s link.\n",
 		bond_dev->name, slave_dev->name,
-		new_slave->state == BOND_STATE_ACTIVE ? "n active" : " backup",
+		bond_is_active_slave(new_slave) ? "n active" : " backup",
 		new_slave->link != BOND_LINK_DOWN ? "n up" : " down");
 
 	/* enslave is successful */
@@ -2016,7 +2016,7 @@ int bond_release(struct net_device *bond_dev, struct net_device *slave_dev)
 
 	pr_info("%s: releasing %s interface %s\n",
 		bond_dev->name,
-		(slave->state == BOND_STATE_ACTIVE) ? "active" : "backup",
+		bond_is_active_slave(slave) ? "active" : "backup",
 		slave_dev->name);
 
 	oldcurrent = bond->curr_active_slave;
@@ -2357,7 +2357,7 @@ static int bond_slave_info_query(struct net_device *bond_dev, struct ifslave *in
 			res = 0;
 			strcpy(info->slave_name, slave->dev->name);
 			info->link = slave->link;
-			info->state = slave->state;
+			info->state = bond_slave_state(slave);
 			info->link_failure_count = slave->link_failure_count;
 			break;
 		}
@@ -2396,7 +2396,7 @@ static int bond_miimon_inspect(struct bonding *bond)
 					bond->dev->name,
 					(bond->params.mode ==
 					 BOND_MODE_ACTIVEBACKUP) ?
-					((slave->state == BOND_STATE_ACTIVE) ?
+					(bond_is_active_slave(slave) ?
 					 "active " : "backup ") : "",
 					slave->dev->name,
 					bond->params.downdelay * bond->params.miimon);
@@ -2487,13 +2487,13 @@ static void bond_miimon_commit(struct bonding *bond)
 
 			if (bond->params.mode == BOND_MODE_8023AD) {
 				/* prevent it from being the active one */
-				slave->state = BOND_STATE_BACKUP;
+				bond_set_backup_slave(slave);
 			} else if (bond->params.mode != BOND_MODE_ACTIVEBACKUP) {
 				/* make it immediately active */
-				slave->state = BOND_STATE_ACTIVE;
+				bond_set_active_slave(slave);
 			} else if (slave != bond->primary_slave) {
 				/* prevent it from being the active one */
-				slave->state = BOND_STATE_BACKUP;
+				bond_set_backup_slave(slave);
 			}
 
 			bond_update_speed_duplex(slave);
@@ -2871,7 +2871,7 @@ static int bond_arp_rcv(struct sk_buff *skb, struct net_device *dev, struct pack
 	memcpy(&tip, arp_ptr, 4);
 
 	pr_debug("bond_arp_rcv: %s %s/%d av %d sv %d sip %pI4 tip %pI4\n",
-		 bond->dev->name, slave->dev->name, slave->state,
+		 bond->dev->name, slave->dev->name, bond_slave_state(slave),
 		 bond->params.arp_validate, slave_do_arp_validate(bond, slave),
 		 &sip, &tip);
 
@@ -2883,7 +2883,7 @@ static int bond_arp_rcv(struct sk_buff *skb, struct net_device *dev, struct pack
 	 * the active, through one switch, the router, then the other
 	 * switch before reaching the backup.
 	 */
-	if (slave->state == BOND_STATE_ACTIVE)
+	if (bond_is_active_slave(slave))
 		bond_validate_arp(bond, slave, sip, tip);
 	else
 		bond_validate_arp(bond, slave, tip, sip);
@@ -2945,7 +2945,7 @@ void bond_loadbalance_arp_mon(struct work_struct *work)
 				slave->dev->last_rx + delta_in_ticks)) {
 
 				slave->link  = BOND_LINK_UP;
-				slave->state = BOND_STATE_ACTIVE;
+				bond_set_active_slave(slave);
 
 				/* primary_slave has no meaning in round-robin
 				 * mode. the window of a slave being up and
@@ -2978,7 +2978,7 @@ void bond_loadbalance_arp_mon(struct work_struct *work)
 				slave->dev->last_rx + 2 * delta_in_ticks)) {
 
 				slave->link  = BOND_LINK_DOWN;
-				slave->state = BOND_STATE_BACKUP;
+				bond_set_backup_slave(slave);
 
 				if (slave->link_failure_count < UINT_MAX)
 					slave->link_failure_count++;
@@ -3072,7 +3072,7 @@ static int bond_ab_arp_inspect(struct bonding *bond, int delta_in_ticks)
 		 * gives each slave a chance to tx/rx traffic
 		 * before being taken out
 		 */
-		if (slave->state == BOND_STATE_BACKUP &&
+		if (!bond_is_active_slave(slave) &&
 		    !bond->current_arp_slave &&
 		    !time_in_range(jiffies,
 			slave_last_rx(bond, slave) - delta_in_ticks,
@@ -3089,7 +3089,7 @@ static int bond_ab_arp_inspect(struct bonding *bond, int delta_in_ticks)
 		 *    the bond has an IP address)
 		 */
 		trans_start = dev_trans_start(slave->dev);
-		if ((slave->state == BOND_STATE_ACTIVE) &&
+		if (bond_is_active_slave(slave) &&
 		    (!time_in_range(jiffies,
 			trans_start - delta_in_ticks,
 			trans_start + 2 * delta_in_ticks) ||
@@ -4446,7 +4446,7 @@ static int bond_xmit_roundrobin(struct sk_buff *skb, struct net_device *bond_dev
 	bond_for_each_slave_from(bond, slave, i, start_at) {
 		if (IS_UP(slave->dev) &&
 		    (slave->link == BOND_LINK_UP) &&
-		    (slave->state == BOND_STATE_ACTIVE)) {
+		    bond_is_active_slave(slave)) {
 			res = bond_dev_queue_xmit(bond, skb, slave->dev);
 			break;
 		}
@@ -4523,7 +4523,7 @@ static int bond_xmit_xor(struct sk_buff *skb, struct net_device *bond_dev)
 	bond_for_each_slave_from(bond, slave, i, start_at) {
 		if (IS_UP(slave->dev) &&
 		    (slave->link == BOND_LINK_UP) &&
-		    (slave->state == BOND_STATE_ACTIVE)) {
+		    bond_is_active_slave(slave)) {
 			res = bond_dev_queue_xmit(bond, skb, slave->dev);
 			break;
 		}
@@ -4564,7 +4564,7 @@ static int bond_xmit_broadcast(struct sk_buff *skb, struct net_device *bond_dev)
 	bond_for_each_slave_from(bond, slave, i, start_at) {
 		if (IS_UP(slave->dev) &&
 		    (slave->link == BOND_LINK_UP) &&
-		    (slave->state == BOND_STATE_ACTIVE)) {
+		    bond_is_active_slave(slave)) {
 			if (tx_dev) {
 				struct sk_buff *skb2 = skb_clone(skb, GFP_ATOMIC);
 				if (!skb2) {
diff --git a/drivers/net/bonding/bond_sysfs.c b/drivers/net/bonding/bond_sysfs.c
index 05e0ae5..344d23f 100644
--- a/drivers/net/bonding/bond_sysfs.c
+++ b/drivers/net/bonding/bond_sysfs.c
@@ -1579,7 +1579,7 @@ static ssize_t bonding_store_slaves_active(struct device *d,
 	}
 
 	bond_for_each_slave(bond, slave, i) {
-		if (slave->state == BOND_STATE_BACKUP) {
+		if (!bond_is_active_slave(slave)) {
 			if (new_value)
 				slave->dev->priv_flags &= ~IFF_SLAVE_INACTIVE;
 			else
diff --git a/drivers/net/bonding/bonding.h b/drivers/net/bonding/bonding.h
index ddee62f..8a3718b 100644
--- a/drivers/net/bonding/bonding.h
+++ b/drivers/net/bonding/bonding.h
@@ -53,7 +53,7 @@
 		    (((slave)->dev->flags & IFF_UP)  && \
 		     netif_running((slave)->dev)     && \
 		     ((slave)->link == BOND_LINK_UP) && \
-		     ((slave)->state == BOND_STATE_ACTIVE))
+		     bond_is_active_slave(slave))
 
 
 #define USES_PRIMARY(mode)				\
@@ -190,7 +190,8 @@ struct slave {
 	unsigned long last_arp_rx;
 	s8     link;    /* one of BOND_LINK_XXXX */
 	s8     new_link;
-	s8     state;   /* one of BOND_STATE_XXXX */
+	u8     backup;	/* indicates backup slave. Value corresponds with
+			   BOND_STATE_ACTIVE and BOND_STATE_BACKUP */
 	u32    original_mtu;
 	u32    link_failure_count;
 	u8     perm_hwaddr[ETH_ALEN];
@@ -302,6 +303,26 @@ static inline bool bond_is_lb(const struct bonding *bond)
 		bond->params.mode == BOND_MODE_ALB);
 }
 
+static inline void bond_set_active_slave(struct slave *slave)
+{
+	slave->backup = 0;
+}
+
+static inline void bond_set_backup_slave(struct slave *slave)
+{
+	slave->backup = 1;
+}
+
+static inline int bond_slave_state(struct slave *slave)
+{
+	return slave->backup;
+}
+
+static inline bool bond_is_active_slave(struct slave *slave)
+{
+	return !bond_slave_state(slave);
+}
+
 #define BOND_PRI_RESELECT_ALWAYS	0
 #define BOND_PRI_RESELECT_BETTER	1
 #define BOND_PRI_RESELECT_FAILURE	2
@@ -319,7 +340,7 @@ static inline bool bond_is_lb(const struct bonding *bond)
 static inline int slave_do_arp_validate(struct bonding *bond,
 					struct slave *slave)
 {
-	return bond->params.arp_validate & (1 << slave->state);
+	return bond->params.arp_validate & (1 << bond_slave_state(slave));
 }
 
 static inline unsigned long slave_last_rx(struct bonding *bond,
@@ -351,14 +372,14 @@ static inline void bond_set_slave_inactive_flags(struct slave *slave)
 {
 	struct bonding *bond = netdev_priv(slave->dev->master);
 	if (!bond_is_lb(bond))
-		slave->state = BOND_STATE_BACKUP;
+		bond_set_backup_slave(slave);
 	if (!bond->params.all_slaves_active)
 		slave->dev->priv_flags |= IFF_SLAVE_INACTIVE;
 }
 
 static inline void bond_set_slave_active_flags(struct slave *slave)
 {
-	slave->state = BOND_STATE_ACTIVE;
+	bond_set_active_slave(slave);
 	slave->dev->priv_flags &= ~IFF_SLAVE_INACTIVE;
 }
 
-- 
1.7.4

