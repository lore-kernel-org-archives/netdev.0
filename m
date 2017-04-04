From: Jarod Wilson <jarod@redhat.com>
Subject: [PATCH net-next] bonding: attempt to better support longer hw addresses
Date: Tue,  4 Apr 2017 17:32:42 -0400
Message-ID: <20170404213242.50079-1-jarod@redhat.com>
Cc: Jarod Wilson <jarod@redhat.com>,
        Jay Vosburgh <j.vosburgh@gmail.com>,
        Veaceslav Falico <vfalico@gmail.com>,
        Andy Gospodarek <andy@greyhouse.net>, netdev@vger.kernel.org
To: linux-kernel@vger.kernel.org
Return-path: <linux-kernel-owner@vger.kernel.org>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

People are using bonding over Infiniband IPoIB connections, and who knows
what else. Infiniband has a hardware address length of 20 octets
(INFINIBAND_ALEN), and the network core defines a MAX_ADDR_LEN of 32.
Various places in the bonding code are currently hard-wired to 6 octets
(ETH_ALEN), such as the 3ad code, which I've left untouched here. Besides,
only alb is currently possible on Infiniband links right now anyway, due
to commit 1533e7731522, so the alb code is where most of the changes are.

One major component of this change is the addition of a bond_hw_addr_copy
function that takes a length argument, instead of using ether_addr_copy
everywhere that hardware addresses need to be copied about. The other
major component of this change is converting the bonding code from using
struct sockaddr for address storage to struct sockaddr_storage, as the
former has an address storage space of only 14, while the latter is 128
minus a few, which is necessary to support bonding over device with up to
MAX_ADDR_LEN octet hardware addresses. Additionally, this probably fixes
up some memory corruption issues with the current code, where it's
possible to write an infiniband hardware address into a sockaddr declared
on the stack.

Lightly tested on a dual mlx4 IPoIB setup, which properly shows a 20-octet
hardware address now:

$ cat /proc/net/bonding/bond0
Ethernet Channel Bonding Driver: v3.7.1 (April 27, 2011)

Bonding Mode: fault-tolerance (active-backup) (fail_over_mac active)
Primary Slave: mlx4_ib0 (primary_reselect always)
Currently Active Slave: mlx4_ib0
MII Status: up
MII Polling Interval (ms): 100
Up Delay (ms): 100
Down Delay (ms): 100

Slave Interface: mlx4_ib0
MII Status: up
Speed: Unknown
Duplex: Unknown
Link Failure Count: 0
Permanent HW addr:
80:00:02:08:fe:80:00:00:00:00:00:00:e4:1d:2d:03:00:1d:67:01
Slave queue ID: 0

Slave Interface: mlx4_ib1
MII Status: up
Speed: Unknown
Duplex: Unknown
Link Failure Count: 0
Permanent HW addr:
80:00:02:09:fe:80:00:00:00:00:00:01:e4:1d:2d:03:00:1d:67:02
Slave queue ID: 0

Also tested with a standard 1Gbps NIC bonding setup (with a mix of
e1000 and e1000e cards), running LNST's bonding tests.

CC: Jay Vosburgh <j.vosburgh@gmail.com>
CC: Veaceslav Falico <vfalico@gmail.com>
CC: Andy Gospodarek <andy@greyhouse.net>
CC: netdev@vger.kernel.org
Signed-off-by: Jarod Wilson <jarod@redhat.com>
---
 drivers/net/bonding/bond_alb.c    | 88 +++++++++++++++++++++++----------------
 drivers/net/bonding/bond_main.c   | 73 ++++++++++++++++++--------------
 drivers/net/bonding/bond_procfs.c |  3 +-
 include/net/bonding.h             | 12 +++++-
 4 files changed, 108 insertions(+), 68 deletions(-)

diff --git a/drivers/net/bonding/bond_alb.c b/drivers/net/bonding/bond_alb.c
index c80b023092dd..7d7a3cec149a 100644
--- a/drivers/net/bonding/bond_alb.c
+++ b/drivers/net/bonding/bond_alb.c
@@ -687,7 +687,8 @@ static struct slave *rlb_arp_xmit(struct sk_buff *skb, struct bonding *bond)
 		/* the arp must be sent on the selected rx channel */
 		tx_slave = rlb_choose_channel(skb, bond);
 		if (tx_slave)
-			ether_addr_copy(arp->mac_src, tx_slave->dev->dev_addr);
+			bond_hw_addr_copy(arp->mac_src, tx_slave->dev->dev_addr,
+					  tx_slave->dev->addr_len);
 		netdev_dbg(bond->dev, "Server sent ARP Reply packet\n");
 	} else if (arp->op_code == htons(ARPOP_REQUEST)) {
 		/* Create an entry in the rx_hashtbl for this client as a
@@ -1017,22 +1018,23 @@ static void alb_send_learning_packets(struct slave *slave, u8 mac_addr[],
 	rcu_read_unlock();
 }
 
-static int alb_set_slave_mac_addr(struct slave *slave, u8 addr[])
+static int alb_set_slave_mac_addr(struct slave *slave, u8 addr[],
+				  unsigned int len)
 {
 	struct net_device *dev = slave->dev;
-	struct sockaddr s_addr;
+	struct sockaddr_storage ss;
 
 	if (BOND_MODE(slave->bond) == BOND_MODE_TLB) {
-		memcpy(dev->dev_addr, addr, dev->addr_len);
+		memcpy(dev->dev_addr, addr, len);
 		return 0;
 	}
 
 	/* for rlb each slave must have a unique hw mac addresses so that
 	 * each slave will receive packets destined to a different mac
 	 */
-	memcpy(s_addr.sa_data, addr, dev->addr_len);
-	s_addr.sa_family = dev->type;
-	if (dev_set_mac_address(dev, &s_addr)) {
+	memcpy(ss.__data, addr, len);
+	ss.ss_family = dev->type;
+	if (dev_set_mac_address(dev, (struct sockaddr *)&ss)) {
 		netdev_err(slave->bond->dev, "dev_set_mac_address of dev %s failed! ALB mode requires that the base driver support setting the hw address also when the network device's interface is open\n",
 			   dev->name);
 		return -EOPNOTSUPP;
@@ -1046,11 +1048,14 @@ static int alb_set_slave_mac_addr(struct slave *slave, u8 addr[])
  */
 static void alb_swap_mac_addr(struct slave *slave1, struct slave *slave2)
 {
-	u8 tmp_mac_addr[ETH_ALEN];
+	u8 tmp_mac_addr[MAX_ADDR_LEN];
 
-	ether_addr_copy(tmp_mac_addr, slave1->dev->dev_addr);
-	alb_set_slave_mac_addr(slave1, slave2->dev->dev_addr);
-	alb_set_slave_mac_addr(slave2, tmp_mac_addr);
+	bond_hw_addr_copy(tmp_mac_addr, slave1->dev->dev_addr,
+			  slave1->dev->addr_len);
+	alb_set_slave_mac_addr(slave1, slave2->dev->dev_addr,
+			       slave2->dev->addr_len);
+	alb_set_slave_mac_addr(slave2, tmp_mac_addr,
+			       slave1->dev->addr_len);
 
 }
 
@@ -1177,7 +1182,8 @@ static int alb_handle_addr_collision_on_attach(struct bonding *bond, struct slav
 		/* Try setting slave mac to bond address and fall-through
 		 * to code handling that situation below...
 		 */
-		alb_set_slave_mac_addr(slave, bond->dev->dev_addr);
+		alb_set_slave_mac_addr(slave, bond->dev->dev_addr,
+				       bond->dev->addr_len);
 	}
 
 	/* The slave's address is equal to the address of the bond.
@@ -1202,7 +1208,8 @@ static int alb_handle_addr_collision_on_attach(struct bonding *bond, struct slav
 	}
 
 	if (free_mac_slave) {
-		alb_set_slave_mac_addr(slave, free_mac_slave->perm_hwaddr);
+		alb_set_slave_mac_addr(slave, free_mac_slave->perm_hwaddr,
+				       free_mac_slave->dev->addr_len);
 
 		netdev_warn(bond->dev, "the hw address of slave %s is in use by the bond; giving it the hw address of %s\n",
 			    slave->dev->name, free_mac_slave->dev->name);
@@ -1234,8 +1241,8 @@ static int alb_set_mac_address(struct bonding *bond, void *addr)
 {
 	struct slave *slave, *rollback_slave;
 	struct list_head *iter;
-	struct sockaddr sa;
-	char tmp_addr[ETH_ALEN];
+	struct sockaddr_storage ss;
+	char tmp_addr[MAX_ADDR_LEN];
 	int res;
 
 	if (bond->alb_info.rlb_enabled)
@@ -1243,12 +1250,14 @@ static int alb_set_mac_address(struct bonding *bond, void *addr)
 
 	bond_for_each_slave(bond, slave, iter) {
 		/* save net_device's current hw address */
-		ether_addr_copy(tmp_addr, slave->dev->dev_addr);
+		bond_hw_addr_copy(tmp_addr, slave->dev->dev_addr,
+				  slave->dev->addr_len);
 
 		res = dev_set_mac_address(slave->dev, addr);
 
 		/* restore net_device's hw address */
-		ether_addr_copy(slave->dev->dev_addr, tmp_addr);
+		bond_hw_addr_copy(slave->dev->dev_addr, tmp_addr,
+				  slave->dev->addr_len);
 
 		if (res)
 			goto unwind;
@@ -1257,16 +1266,19 @@ static int alb_set_mac_address(struct bonding *bond, void *addr)
 	return 0;
 
 unwind:
-	memcpy(sa.sa_data, bond->dev->dev_addr, bond->dev->addr_len);
-	sa.sa_family = bond->dev->type;
+	memcpy(ss.__data, bond->dev->dev_addr, bond->dev->addr_len);
+	ss.ss_family = bond->dev->type;
 
 	/* unwind from head to the slave that failed */
 	bond_for_each_slave(bond, rollback_slave, iter) {
 		if (rollback_slave == slave)
 			break;
-		ether_addr_copy(tmp_addr, rollback_slave->dev->dev_addr);
-		dev_set_mac_address(rollback_slave->dev, &sa);
-		ether_addr_copy(rollback_slave->dev->dev_addr, tmp_addr);
+		bond_hw_addr_copy(tmp_addr, rollback_slave->dev->dev_addr,
+				  rollback_slave->dev->addr_len);
+		dev_set_mac_address(rollback_slave->dev,
+				    (struct sockaddr *)&ss);
+		bond_hw_addr_copy(rollback_slave->dev->dev_addr, tmp_addr,
+				  rollback_slave->dev->addr_len);
 	}
 
 	return res;
@@ -1582,7 +1594,8 @@ int bond_alb_init_slave(struct bonding *bond, struct slave *slave)
 {
 	int res;
 
-	res = alb_set_slave_mac_addr(slave, slave->perm_hwaddr);
+	res = alb_set_slave_mac_addr(slave, slave->perm_hwaddr,
+				     slave->dev->addr_len);
 	if (res)
 		return res;
 
@@ -1696,17 +1709,20 @@ void bond_alb_handle_active_change(struct bonding *bond, struct slave *new_slave
 	 * and thus filter bond->dev_addr's packets, so force bond's mac
 	 */
 	if (BOND_MODE(bond) == BOND_MODE_TLB) {
-		struct sockaddr sa;
-		u8 tmp_addr[ETH_ALEN];
+		struct sockaddr_storage ss;
+		u8 tmp_addr[MAX_ADDR_LEN];
 
-		ether_addr_copy(tmp_addr, new_slave->dev->dev_addr);
+		bond_hw_addr_copy(tmp_addr, new_slave->dev->dev_addr,
+				  new_slave->dev->addr_len);
 
-		memcpy(sa.sa_data, bond->dev->dev_addr, bond->dev->addr_len);
-		sa.sa_family = bond->dev->type;
+		bond_hw_addr_copy(ss.__data, bond->dev->dev_addr,
+				  bond->dev->addr_len);
+		ss.ss_family = bond->dev->type;
 		/* we don't care if it can't change its mac, best effort */
-		dev_set_mac_address(new_slave->dev, &sa);
+		dev_set_mac_address(new_slave->dev, (struct sockaddr *)&ss);
 
-		ether_addr_copy(new_slave->dev->dev_addr, tmp_addr);
+		bond_hw_addr_copy(new_slave->dev->dev_addr, tmp_addr,
+				  new_slave->dev->addr_len);
 	}
 
 	/* curr_active_slave must be set before calling alb_swap_mac_addr */
@@ -1716,7 +1732,8 @@ void bond_alb_handle_active_change(struct bonding *bond, struct slave *new_slave
 		alb_fasten_mac_swap(bond, swap_slave, new_slave);
 	} else {
 		/* set the new_slave to the bond mac address */
-		alb_set_slave_mac_addr(new_slave, bond->dev->dev_addr);
+		alb_set_slave_mac_addr(new_slave, bond->dev->dev_addr,
+				       bond->dev->addr_len);
 		alb_send_learning_packets(new_slave, bond->dev->dev_addr,
 					  false);
 	}
@@ -1726,19 +1743,19 @@ void bond_alb_handle_active_change(struct bonding *bond, struct slave *new_slave
 int bond_alb_set_mac_address(struct net_device *bond_dev, void *addr)
 {
 	struct bonding *bond = netdev_priv(bond_dev);
-	struct sockaddr *sa = addr;
+	struct sockaddr_storage *ss = addr;
 	struct slave *curr_active;
 	struct slave *swap_slave;
 	int res;
 
-	if (!is_valid_ether_addr(sa->sa_data))
+	if (!is_valid_ether_addr(ss->__data))
 		return -EADDRNOTAVAIL;
 
 	res = alb_set_mac_address(bond, addr);
 	if (res)
 		return res;
 
-	memcpy(bond_dev->dev_addr, sa->sa_data, bond_dev->addr_len);
+	bond_hw_addr_copy(bond_dev->dev_addr, ss->__data, bond_dev->addr_len);
 
 	/* If there is no curr_active_slave there is nothing else to do.
 	 * Otherwise we'll need to pass the new address to it and handle
@@ -1754,7 +1771,8 @@ int bond_alb_set_mac_address(struct net_device *bond_dev, void *addr)
 		alb_swap_mac_addr(swap_slave, curr_active);
 		alb_fasten_mac_swap(bond, swap_slave, curr_active);
 	} else {
-		alb_set_slave_mac_addr(curr_active, bond_dev->dev_addr);
+		alb_set_slave_mac_addr(curr_active, bond_dev->dev_addr,
+				       bond_dev->addr_len);
 
 		alb_send_learning_packets(curr_active,
 					  bond_dev->dev_addr, false);
diff --git a/drivers/net/bonding/bond_main.c b/drivers/net/bonding/bond_main.c
index 27359dab78a1..fd697d30ef06 100644
--- a/drivers/net/bonding/bond_main.c
+++ b/drivers/net/bonding/bond_main.c
@@ -650,8 +650,8 @@ static void bond_do_fail_over_mac(struct bonding *bond,
 				  struct slave *new_active,
 				  struct slave *old_active)
 {
-	u8 tmp_mac[ETH_ALEN];
-	struct sockaddr saddr;
+	u8 tmp_mac[MAX_ADDR_LEN];
+	struct sockaddr_storage ss;
 	int rv;
 
 	switch (bond->params.fail_over_mac) {
@@ -671,16 +671,20 @@ static void bond_do_fail_over_mac(struct bonding *bond,
 			old_active = bond_get_old_active(bond, new_active);
 
 		if (old_active) {
-			ether_addr_copy(tmp_mac, new_active->dev->dev_addr);
-			ether_addr_copy(saddr.sa_data,
-					old_active->dev->dev_addr);
-			saddr.sa_family = new_active->dev->type;
+			bond_hw_addr_copy(tmp_mac, new_active->dev->dev_addr,
+					  new_active->dev->addr_len);
+			bond_hw_addr_copy(ss.__data,
+					  old_active->dev->dev_addr,
+					  old_active->dev->addr_len);
+			ss.ss_family = new_active->dev->type;
 		} else {
-			ether_addr_copy(saddr.sa_data, bond->dev->dev_addr);
-			saddr.sa_family = bond->dev->type;
+			bond_hw_addr_copy(ss.__data, bond->dev->dev_addr,
+					  bond->dev->addr_len);
+			ss.ss_family = bond->dev->type;
 		}
 
-		rv = dev_set_mac_address(new_active->dev, &saddr);
+		rv = dev_set_mac_address(new_active->dev,
+					 (struct sockaddr *)&ss);
 		if (rv) {
 			netdev_err(bond->dev, "Error %d setting MAC of slave %s\n",
 				   -rv, new_active->dev->name);
@@ -690,10 +694,12 @@ static void bond_do_fail_over_mac(struct bonding *bond,
 		if (!old_active)
 			goto out;
 
-		ether_addr_copy(saddr.sa_data, tmp_mac);
-		saddr.sa_family = old_active->dev->type;
+		bond_hw_addr_copy(ss.__data, tmp_mac,
+				  new_active->dev->addr_len);
+		ss.ss_family = old_active->dev->type;
 
-		rv = dev_set_mac_address(old_active->dev, &saddr);
+		rv = dev_set_mac_address(old_active->dev,
+					 (struct sockaddr *)&ss);
 		if (rv)
 			netdev_err(bond->dev, "Error %d setting MAC of slave %s\n",
 				   -rv, new_active->dev->name);
@@ -1189,7 +1195,8 @@ static rx_handler_result_t bond_handle_frame(struct sk_buff **pskb)
 			kfree_skb(skb);
 			return RX_HANDLER_CONSUMED;
 		}
-		ether_addr_copy(eth_hdr(skb)->h_dest, bond->dev->dev_addr);
+		bond_hw_addr_copy(eth_hdr(skb)->h_dest, bond->dev->dev_addr,
+				  bond->dev->addr_len);
 	}
 
 	return ret;
@@ -1328,7 +1335,7 @@ int bond_enslave(struct net_device *bond_dev, struct net_device *slave_dev)
 	struct bonding *bond = netdev_priv(bond_dev);
 	const struct net_device_ops *slave_ops = slave_dev->netdev_ops;
 	struct slave *new_slave = NULL, *prev_slave;
-	struct sockaddr addr;
+	struct sockaddr_storage ss;
 	int link_reporting;
 	int res = 0, i;
 
@@ -1479,16 +1486,17 @@ int bond_enslave(struct net_device *bond_dev, struct net_device *slave_dev)
 	 * that need it, and for restoring it upon release, and then
 	 * set it to the master's address
 	 */
-	ether_addr_copy(new_slave->perm_hwaddr, slave_dev->dev_addr);
+	bond_hw_addr_copy(new_slave->perm_hwaddr, slave_dev->dev_addr,
+			  slave_dev->addr_len);
 
 	if (!bond->params.fail_over_mac ||
 	    BOND_MODE(bond) != BOND_MODE_ACTIVEBACKUP) {
 		/* Set slave to master's mac address.  The application already
 		 * set the master's mac address to that of the first slave
 		 */
-		memcpy(addr.sa_data, bond_dev->dev_addr, bond_dev->addr_len);
-		addr.sa_family = slave_dev->type;
-		res = dev_set_mac_address(slave_dev, &addr);
+		memcpy(ss.__data, bond_dev->dev_addr, bond_dev->addr_len);
+		ss.ss_family = slave_dev->type;
+		res = dev_set_mac_address(slave_dev, (struct sockaddr *)&ss);
 		if (res) {
 			netdev_dbg(bond_dev, "Error %d calling set_mac_address\n", res);
 			goto err_restore_mtu;
@@ -1771,9 +1779,10 @@ int bond_enslave(struct net_device *bond_dev, struct net_device *slave_dev)
 		 * MAC if this slave's MAC is in use by the bond, or at
 		 * least print a warning.
 		 */
-		ether_addr_copy(addr.sa_data, new_slave->perm_hwaddr);
-		addr.sa_family = slave_dev->type;
-		dev_set_mac_address(slave_dev, &addr);
+		bond_hw_addr_copy(ss.__data, new_slave->perm_hwaddr,
+				  new_slave->dev->addr_len);
+		ss.ss_family = slave_dev->type;
+		dev_set_mac_address(slave_dev, (struct sockaddr *)&ss);
 	}
 
 err_restore_mtu:
@@ -1816,7 +1825,7 @@ static int __bond_release_one(struct net_device *bond_dev,
 {
 	struct bonding *bond = netdev_priv(bond_dev);
 	struct slave *slave, *oldcurrent;
-	struct sockaddr addr;
+	struct sockaddr_storage ss;
 	int old_flags = bond_dev->flags;
 	netdev_features_t old_features = bond_dev->features;
 
@@ -1951,9 +1960,10 @@ static int __bond_release_one(struct net_device *bond_dev,
 	if (bond->params.fail_over_mac != BOND_FOM_ACTIVE ||
 	    BOND_MODE(bond) != BOND_MODE_ACTIVEBACKUP) {
 		/* restore original ("permanent") mac address */
-		ether_addr_copy(addr.sa_data, slave->perm_hwaddr);
-		addr.sa_family = slave_dev->type;
-		dev_set_mac_address(slave_dev, &addr);
+		bond_hw_addr_copy(ss.__data, slave->perm_hwaddr,
+				  slave->dev->addr_len);
+		ss.ss_family = slave_dev->type;
+		dev_set_mac_address(slave_dev, (struct sockaddr *)&ss);
 	}
 
 	dev_set_mtu(slave_dev, slave->original_mtu);
@@ -3629,7 +3639,7 @@ static int bond_set_mac_address(struct net_device *bond_dev, void *addr)
 {
 	struct bonding *bond = netdev_priv(bond_dev);
 	struct slave *slave, *rollback_slave;
-	struct sockaddr *sa = addr, tmp_sa;
+	struct sockaddr_storage *ss = addr, tmp_ss;
 	struct list_head *iter;
 	int res = 0;
 
@@ -3646,7 +3656,7 @@ static int bond_set_mac_address(struct net_device *bond_dev, void *addr)
 	    BOND_MODE(bond) == BOND_MODE_ACTIVEBACKUP)
 		return 0;
 
-	if (!is_valid_ether_addr(sa->sa_data))
+	if (!is_valid_ether_addr(ss->__data))
 		return -EADDRNOTAVAIL;
 
 	bond_for_each_slave(bond, slave, iter) {
@@ -3665,12 +3675,12 @@ static int bond_set_mac_address(struct net_device *bond_dev, void *addr)
 	}
 
 	/* success */
-	memcpy(bond_dev->dev_addr, sa->sa_data, bond_dev->addr_len);
+	memcpy(bond_dev->dev_addr, ss->__data, bond_dev->addr_len);
 	return 0;
 
 unwind:
-	memcpy(tmp_sa.sa_data, bond_dev->dev_addr, bond_dev->addr_len);
-	tmp_sa.sa_family = bond_dev->type;
+	memcpy(tmp_ss.__data, bond_dev->dev_addr, bond_dev->addr_len);
+	tmp_ss.ss_family = bond_dev->type;
 
 	/* unwind from head to the slave that failed */
 	bond_for_each_slave(bond, rollback_slave, iter) {
@@ -3679,7 +3689,8 @@ static int bond_set_mac_address(struct net_device *bond_dev, void *addr)
 		if (rollback_slave == slave)
 			break;
 
-		tmp_res = dev_set_mac_address(rollback_slave->dev, &tmp_sa);
+		tmp_res = dev_set_mac_address(rollback_slave->dev,
+					      (struct sockaddr *)&tmp_ss);
 		if (tmp_res) {
 			netdev_dbg(bond_dev, "unwind err %d dev %s\n",
 				   tmp_res, rollback_slave->dev->name);
diff --git a/drivers/net/bonding/bond_procfs.c b/drivers/net/bonding/bond_procfs.c
index f514fe5e80a5..d8d4ada034b7 100644
--- a/drivers/net/bonding/bond_procfs.c
+++ b/drivers/net/bonding/bond_procfs.c
@@ -183,7 +183,8 @@ static void bond_info_show_slave(struct seq_file *seq,
 	seq_printf(seq, "Link Failure Count: %u\n",
 		   slave->link_failure_count);
 
-	seq_printf(seq, "Permanent HW addr: %pM\n", slave->perm_hwaddr);
+	seq_printf(seq, "Permanent HW addr: %*phC\n",
+		   slave->dev->addr_len, slave->perm_hwaddr);
 	seq_printf(seq, "Slave queue ID: %d\n", slave->queue_id);
 
 	if (BOND_MODE(bond) == BOND_MODE_8023AD) {
diff --git a/include/net/bonding.h b/include/net/bonding.h
index fb2dd97857c4..04a21e8048be 100644
--- a/include/net/bonding.h
+++ b/include/net/bonding.h
@@ -166,7 +166,7 @@ struct slave {
 	u32    link_failure_count;
 	u32    speed;
 	u16    queue_id;
-	u8     perm_hwaddr[ETH_ALEN];
+	u8     perm_hwaddr[MAX_ADDR_LEN];
 	struct ad_slave_info *ad_info;
 	struct tlb_slave_info tlb_info;
 #ifdef CONFIG_NET_POLL_CONTROLLER
@@ -402,6 +402,16 @@ static inline bool bond_slave_can_tx(struct slave *slave)
 	       bond_is_active_slave(slave);
 }
 
+static inline void bond_hw_addr_copy(u8 *dst, const u8 *src, unsigned int len)
+{
+	if (len == ETH_ALEN) {
+		ether_addr_copy(dst, src);
+		return;
+	}
+
+	memcpy(dst, src, len);
+}
+
 #define BOND_PRI_RESELECT_ALWAYS	0
 #define BOND_PRI_RESELECT_BETTER	1
 #define BOND_PRI_RESELECT_FAILURE	2
-- 
2.12.1
