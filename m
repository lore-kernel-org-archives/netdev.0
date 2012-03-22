From: Weiping Pan <panweiping3@gmail.com>
Subject: [PATCH net 2/2] bonding:delete rlb entry at regular intervals
Date: Thu, 22 Mar 2012 16:18:32 +0800
Message-ID: <200ebddbbe5037adde0a440f06f0c08181f085b6.1332386801.git.panweiping3@gmail.com>
References: <cover.1332386801.git.panweiping3@gmail.com>
Cc: Weiping Pan <panweiping3@gmail.com>,
	Jay Vosburgh <fubar@us.ibm.com> (supporter:BONDING DRIVER),
	Andy Gospodarek <andy@greyhouse.net> (supporter:BONDING DRIVER),
	netdev@vger.kernel.org (open list:BONDING DRIVER),
	linux-kernel@vger.kernel.org (open list)
To: unlisted-recipients:; (no To-header on input)
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <cover.1332386801.git.panweiping3@gmail.com>
In-Reply-To: <cover.1332386801.git.panweiping3@gmail.com>
References: <cover.1332386801.git.panweiping3@gmail.com>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Jiri Bohac(jbohac@suse.cz) found that once an IP address is recorded in the
rlb hash table, it stays there indefinitely. If this IP address is migrated
to a different host in the network, bonding still sends out ARP packets
that poison other systems' ARP caches with invalid information.

Assume the rlb entry is like <source ip, dest ip, dest mac>.

There are some kinds of migration.

1 delete ip address from bond device
If one ip address is deleted from bond device, the rlb table still contains
the old mapping.

2 swap ip address between bond0 and HostB
before the change:
                            ---- HostC(ipC)--
HostA(ipA) ----- switch ---|-- eth0 - bond0  |
HostB(ipB) -----/       \--|-- eth1 -/       |
                            -----------------

Like this topo, HostC and HostB can swap their ip addresses.
after the change:
                            ---- HostC(ipB)--
HostA(ipA) ----- switch ---|-- eth0 - bond0  |
HostB(ipC) -----/       \--|-- eth1 -/       |
                            -----------------
Then bonding will still send arp replies to HostA with the source ip  is ipC,
and it will poison arp cache of HostA, so HostA can not ping HostB now.

3 clients change their ip address, even swap them
before the change:
                           ----- HostC(ipC)--
HostA(ipA) ----- switch ---|-- eth0 - bond0  |
HostB(ipB) -----/       \--|-- eth1 -/       |
                            -----------------

after the change:
                            ---- HostC(ipC)--
HostA(ipB) ----- switch ---|-- eth0 - bond0  |
HostB(ipA) -----/       \--|-- eth1 -/       |
                            -----------------

Then rlb table still contains old mapping, that is <ipC, ipA, macA> and
<ipC, ipB, macB>, and continues to send arp replies to them.

4 bond can be enslave to a bridge
before the change:
                                 br0
                                  |
                                bond0
                               ___|___
                              |       |
HostA(ipA) --- NetworkA --- eth0     eth1 --- NetworkB --- hostB(ipB)

after the change:
                                 br0
                                  |
                                bond0
                               ___|___
                              |       |
HostA(ipB) --- NetworkA --- eth0     eth1 --- NetworkB --- hostB(ipA)

Then rlb table still contains old mapping, that is <ipA, ipB, macB>,
and continues to send arp replies to HostB, it will poison arp cache of HostB.

There are some attempts to fix this problem, 
http://marc.info/?l=linux-netdev&m=133036407906892&w=4
http://marc.info/?l=linux-netdev&m=133057427414043&w=4

But they did not fix the root cause of the problem, that rlb table does not
have a aging mechanism, the entry is valid for ever unless it is replaced.

In this patchset I want to add aging mechanism to rlb table.

Assume RLB_MONITOR_DELAY is 2 seconds and RLB_WORK_COUNTER_TIMES is 3.
Every 6 seconds bonding will make all entries invalid.
Every 2 seconds, bonding will send arp requests to its all
clients, then if it receives corresponding arp reply, bonding will deem that
this entry is valid.
And we give a entry 3 opportunities to survive in 6 seconds.

TODO:
The ntt (need to transmit) mechanism of rlb has duplicate functions with this
patch, if this patch is accepted, ntt mechanism can be deleted.

Signed-off-by: Weiping Pan <panweiping3@gmail.com>
---
 drivers/net/bonding/bond_alb.c  |   95 ++++++++++++++++++++++++++++++++++----
 drivers/net/bonding/bond_alb.h  |    7 +++
 drivers/net/bonding/bond_main.c |   10 +++-
 3 files changed, 100 insertions(+), 12 deletions(-)

diff --git a/drivers/net/bonding/bond_alb.c b/drivers/net/bonding/bond_alb.c
index bca1039..4be5bf1 100644
--- a/drivers/net/bonding/bond_alb.c
+++ b/drivers/net/bonding/bond_alb.c
@@ -333,12 +333,15 @@ static void rlb_update_entry_from_arp(struct bonding *bond, struct arp_pkt *arp)
 
 	if ((client_info->assigned) &&
 	    (client_info->ip_src == arp->ip_dst) &&
-	    (client_info->ip_dst == arp->ip_src) &&
-	    (compare_ether_addr_64bits(client_info->mac_dst, arp->mac_src))) {
-		/* update the clients MAC address */
-		memcpy(client_info->mac_dst, arp->mac_src, ETH_ALEN);
-		client_info->ntt = 1;
-		bond_info->rx_ntt = 1;
+	    (client_info->ip_dst == arp->ip_src)) {
+		if (compare_ether_addr_64bits(client_info->mac_dst,
+						arp->mac_src)) {
+			/* update the clients MAC address */
+			memcpy(client_info->mac_dst, arp->mac_src, ETH_ALEN);
+			client_info->ntt = 1;
+			bond_info->rx_ntt = 1;
+		} else
+			client_info->used = 1;
 	}
 
 	_unlock_rx_hashtbl_bh(bond);
@@ -485,14 +488,20 @@ static void rlb_update_client(struct rlb_client_info *client_info)
 {
 	int i;
 
+	if (client_info->used)
+		return;
+
 	if (!client_info->slave) {
 		return;
 	}
 
+	if (is_zero_ether_addr(client_info->mac_dst))
+		return;
+
 	for (i = 0; i < RLB_ARP_BURST_SIZE; i++) {
 		struct sk_buff *skb;
 
-		skb = arp_create(ARPOP_REPLY, ETH_P_ARP,
+		skb = arp_create(ARPOP_REQUEST, ETH_P_ARP,
 				 client_info->ip_dst,
 				 client_info->slave->dev,
 				 client_info->ip_src,
@@ -521,7 +530,7 @@ static void rlb_update_client(struct rlb_client_info *client_info)
 }
 
 /* sends ARP REPLIES that update the clients that need updating */
-static void rlb_update_rx_clients(struct bonding *bond)
+static void rlb_update_rx_clients(struct bonding *bond, bool force)
 {
 	struct alb_bond_info *bond_info = &(BOND_ALB_INFO(bond));
 	struct rlb_client_info *client_info;
@@ -532,7 +541,7 @@ static void rlb_update_rx_clients(struct bonding *bond)
 	hash_index = bond_info->rx_hashtbl_head;
 	for (; hash_index != RLB_NULL_INDEX; hash_index = client_info->next) {
 		client_info = &(bond_info->rx_hashtbl[hash_index]);
-		if (client_info->ntt) {
+		if (client_info->ntt || force) {
 			rlb_update_client(client_info);
 			if (bond_info->rlb_update_retry_counter == 0) {
 				client_info->ntt = 0;
@@ -776,6 +785,67 @@ static void rlb_init_table_entry(struct rlb_client_info *entry)
 	entry->prev = RLB_NULL_INDEX;
 }
 
+/*
+ * bond_rlb_monitor
+ *
+ * Every RLB_MONITOR_DELAY seconds, send arp requests for all clients.
+ * And if bond receives corresponding arp reply from client,
+ * rlb_client_info->used will be set to 1.
+ * If rlb_client_info->used is not set to 1 during
+ * RLB_WORK_COUNTER_TIMES * RLB_MONITOR_DELAY seconds,
+ * then delete the rlb entry.
+ */
+void bond_rlb_monitor(struct work_struct *work)
+{
+	struct alb_bond_info *bond_info = container_of(work, struct alb_bond_info,
+					    rlb_work.work);
+
+	struct bonding *bond = container_of(bond_info, struct bonding,
+					    alb_info);
+	struct rlb_client_info *client_info;
+	u32 curr_index;
+
+	_lock_rx_hashtbl_bh(bond);
+	if (bond_info->rlb_work_counter++ < RLB_WORK_COUNTER_TIMES) {
+		_lock_rx_hashtbl_bh(bond);
+		rlb_update_rx_clients(bond, true);
+		queue_delayed_work(bond->wq, &bond_info->rlb_work, RLB_MONITOR_DELAY);
+		return;
+	}
+
+	bond_info->rlb_work_counter = 0;
+
+	curr_index = bond_info->rx_hashtbl_head;
+	for (; curr_index != RLB_NULL_INDEX;) {
+		u32 next_index;
+		u32 prev_index;
+		client_info = &(bond_info->rx_hashtbl[curr_index]);
+		next_index = client_info->next;
+		prev_index = client_info->prev;
+		if (client_info->used != 1) {
+			/* delete this rlb entry */
+			if (curr_index == bond_info->rx_hashtbl_head) {
+				bond_info->rx_hashtbl_head = next_index;
+			}
+			if (prev_index != RLB_NULL_INDEX) {
+				bond_info->rx_hashtbl[prev_index].next = next_index;
+			}
+			if (next_index != RLB_NULL_INDEX) {
+				bond_info->rx_hashtbl[next_index].prev = prev_index;
+			}
+
+			rlb_init_table_entry(client_info);
+		} else
+			client_info->used = 0;
+
+		curr_index = next_index;
+	}
+
+	_unlock_rx_hashtbl_bh(bond);
+
+	queue_delayed_work(bond->wq, &bond_info->rlb_work, RLB_MONITOR_DELAY);
+}
+
 static int rlb_initialize(struct bonding *bond)
 {
 	struct alb_bond_info *bond_info = &(BOND_ALB_INFO(bond));
@@ -804,6 +874,9 @@ static int rlb_initialize(struct bonding *bond)
 	/* register to receive ARPs */
 	bond->recv_probe = rlb_arp_recv;
 
+	INIT_DELAYED_WORK(&bond_info->rlb_work, bond_rlb_monitor);
+	queue_delayed_work(bond->wq, &bond_info->rlb_work, 0);
+
 	return 0;
 }
 
@@ -818,6 +891,8 @@ static void rlb_deinitialize(struct bonding *bond)
 	bond_info->rx_hashtbl_head = RLB_NULL_INDEX;
 
 	_unlock_rx_hashtbl_bh(bond);
+
+	cancel_delayed_work_sync(&bond_info->rlb_work);
 }
 
 static void rlb_clear_vlan(struct bonding *bond, unsigned short vlan_id)
@@ -1497,7 +1572,7 @@ void bond_alb_monitor(struct work_struct *work)
 			if (bond_info->rlb_update_delay_counter) {
 				--bond_info->rlb_update_delay_counter;
 			} else {
-				rlb_update_rx_clients(bond);
+				rlb_update_rx_clients(bond, false);
 				if (bond_info->rlb_update_retry_counter) {
 					--bond_info->rlb_update_retry_counter;
 				} else {
diff --git a/drivers/net/bonding/bond_alb.h b/drivers/net/bonding/bond_alb.h
index 38863fc..5b7c433 100644
--- a/drivers/net/bonding/bond_alb.h
+++ b/drivers/net/bonding/bond_alb.h
@@ -68,6 +68,9 @@ struct slave;
  */
 #define RLB_PROMISC_TIMEOUT	(10*ALB_TIMER_TICKS_PER_SEC)
 
+#define RLB_MONITOR_DELAY 2 * HZ
+#define RLB_WORK_COUNTER_TIMES 3
+
 
 struct tlb_client_info {
 	struct slave *tx_slave;	/* A pointer to slave used for transmiting
@@ -104,6 +107,8 @@ struct rlb_client_info {
 	u32 next;		/* The next Hash table entry index */
 	u32 prev;		/* The previous Hash table entry index */
 	u8  assigned;		/* checking whether this entry is assigned */
+	u8  used;		/* checking whether this entry is used during
+				   RLB_MONITOR_DELAY seconds*/
 	u8  ntt;		/* flag - need to transmit client info */
 	struct slave *slave;	/* the slave assigned to this client */
 	u8 tag;			/* flag - need to tag skb */
@@ -135,6 +140,8 @@ struct alb_bond_info {
 	u8			rx_ntt;	/* flag - need to transmit
 					 * to all rx clients
 					 */
+	struct delayed_work 	rlb_work;
+	int 			rlb_work_counter;
 	struct slave		*next_rx_slave;/* next slave to be assigned
 						* to a new rx client for
 						*/
diff --git a/drivers/net/bonding/bond_main.c b/drivers/net/bonding/bond_main.c
index ec071b9..b2bd96f 100644
--- a/drivers/net/bonding/bond_main.c
+++ b/drivers/net/bonding/bond_main.c
@@ -4351,16 +4351,22 @@ static void bond_setup(struct net_device *bond_dev)
 
 static void bond_work_cancel_all(struct bonding *bond)
 {
+	struct alb_bond_info *bond_info = &BOND_ALB_INFO(bond);
+
 	if (bond->params.miimon && delayed_work_pending(&bond->mii_work))
 		cancel_delayed_work_sync(&bond->mii_work);
 
 	if (bond->params.arp_interval && delayed_work_pending(&bond->arp_work))
 		cancel_delayed_work_sync(&bond->arp_work);
 
-	if (bond->params.mode == BOND_MODE_ALB &&
-	    delayed_work_pending(&bond->alb_work))
+	if (bond->params.mode == BOND_MODE_ALB) {
+	    if (delayed_work_pending(&bond->alb_work))
 		cancel_delayed_work_sync(&bond->alb_work);
 
+	    if (delayed_work_pending(&bond_info->rlb_work))
+		cancel_delayed_work_sync(&bond_info->rlb_work);
+	}
+
 	if (bond->params.mode == BOND_MODE_8023AD &&
 	    delayed_work_pending(&bond->ad_work))
 		cancel_delayed_work_sync(&bond->ad_work);
-- 
1.7.4
