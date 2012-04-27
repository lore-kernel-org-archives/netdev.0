From: Jiri Bohac <jbohac@suse.cz>
Subject: Re: [PATCH][RFC] bonding: delete migrated IP addresses from the rlb
 hash table
Date: Fri, 27 Apr 2012 23:03:45 +0200
Message-ID: <20120427210345.GA12957@midget.suse.cz>
References: <20120227173400.GB816@midget.suse.cz>
 <14150.1330567940@death.nxdomain>
 <20120307160216.GB11474@midget.suse.cz>
 <20120420185609.GB16028@midget.suse.cz>
 <19845.1335471502@death.nxdomain>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: Jiri Bohac <jbohac@suse.cz>, Andy Gospodarek <andy@greyhouse.net>,
	netdev@vger.kernel.org
To: Jay Vosburgh <fubar@us.ibm.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from cantor2.suse.de ([195.135.220.15]:50522 "EHLO mx2.suse.de"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1751836Ab2D0VDr (ORCPT <rfc822;netdev@vger.kernel.org>);
	Fri, 27 Apr 2012 17:03:47 -0400
Content-Disposition: inline
In-Reply-To: <19845.1335471502@death.nxdomain>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Thu, Apr 26, 2012 at 01:18:22PM -0700, Jay Vosburgh wrote:
> >On Wed, Mar 07, 2012 at 05:02:16PM +0100, Jiri Bohac wrote:
> >> I think it would be better to also
> >> store the source (server) MAC address in struct client_info and
> >> only flush the hash table entries if the MAC address from the
> >> incoming APR packet and the source MAC address stored in the hash
> >> table differ.
> 
> 	Just to make sure I understand: the additional check you propose
> (beyond a check that the IP source address is not locally in use) is for
> the purpose of minimizing unnecessary flushes, by insuring that the
> address really has moved.  Correct?

No. There is no check whether the IP source address is local.
The check looks if the IP source address is stored in the rlb
hash table as ip_src. Could be a result of using the IP address
locally, or by other hosts bridged with the bonding master.

And the additional check that prevents unnecessarry flushes
(caused by ARP packets sent out from the bond being looped back
by a switch) is a check for the MAC address in the ARP packet.
If the MAC address is different from the MAC address stored in
the rlb hash table, it means the host with IP address ip_src does
no longer use mac_src and we must not send out client updates
with this ip_src/mac_src combination.

If the MAC address in the ARP packet is equal to the mac_src, it
could mean two things:

- the IP address has not moved and is still used locally or
  bridged to the bonding master; we received this packet because
  a switch looped it back to another slave of the bond

- the IP address has actually moved, but the MAC address remained
  the same (think of a virtual machine migration, keeping the
  virtual NIC's MAC address). We don't mind keeping the
  corresponding rlb entry, because the ip/mac combination is
  still valid and will not polute ARP caches with invalid
  information.

> 	I'm going to give this a spin this afternoon, but just skimming
> through it, I'm still not that thrilled about the "forward" and
> "reverse" terminology applying to "hash by dst" and "hash by src"; why
> not just call 'em "dst_next" and "src_next", et al, and cut out the
> middle man?

How about these naming changes - patch below:

	next -> used_next
	prev -> used_prev
	rx_hashtbl_head -> rx_hashtbl_used_head
	
the currect linked list is _not_ a list of hash table
entries with colliding ip_dst. It's a list of entries that are
being used; its purpose is to avoid walking the whole hash table
when looking for used entries;

	reverse_next -> src_next
	reverse_prev -> src_prev
	reverse_first -> src_first

I also renamed some of the functions, e.g.
	rlb_src_unlink/rlb_src_link instead of
	rlb_delete_table_entry_reverse/rlb_set_reverse_entry
because they actually link the existing entries to the
corresponding linked list.

Signed-off-by: Jiri Bohac <jbohac@suse.cz>


diff --git a/drivers/net/bonding/bond_alb.c b/drivers/net/bonding/bond_alb.c
index 9abfde4..a7809ae 100644
--- a/drivers/net/bonding/bond_alb.c
+++ b/drivers/net/bonding/bond_alb.c
@@ -84,6 +84,9 @@ static inline struct arp_pkt *arp_pkt(const struct sk_buff *skb)
 
 /* Forward declaration */
 static void alb_send_learning_packets(struct slave *slave, u8 mac_addr[]);
+static void rlb_purge_src_ip(struct bonding *bond, struct arp_pkt *arp);
+static void rlb_src_unlink(struct bonding *bond, u32 index);
+static void rlb_src_link(struct bonding *bond, u32 ip_src_hash, u32 ip_dst_hash);
 
 static inline u8 _simple_hash(const u8 *hash_start, int hash_size)
 {
@@ -364,6 +367,17 @@ static void rlb_arp_recv(struct sk_buff *skb, struct bonding *bond,
 		return;
 	}
 
+	/* We received an ARP from arp->ip_src.
+	 * We might have used this IP address previously (on the bonding host
+	 * itself or on a system that is bridged together with the bond).
+	 * However, if arp->mac_src is different than what is stored in
+	 * rx_hashtbl, some other host is now using the IP and we must prevent
+	 * sending out client updates with this IP address and the old MAC address.
+	 * Clean up all hash table entries that have this address as ip_src but
+	 * have a dirrerent mac_src.
+	 */
+	rlb_purge_src_ip(bond, arp);
+
 	if (arp->op_code == htons(ARPOP_REPLY)) {
 		/* update rx hash table for this ARP */
 		rlb_update_entry_from_arp(bond, arp);
@@ -440,9 +454,9 @@ static void rlb_clear_slave(struct bonding *bond, struct slave *slave)
 	_lock_rx_hashtbl_bh(bond);
 
 	rx_hash_table = bond_info->rx_hashtbl;
-	index = bond_info->rx_hashtbl_head;
+	index = bond_info->rx_hashtbl_used_head;
 	for (; index != RLB_NULL_INDEX; index = next_index) {
-		next_index = rx_hash_table[index].next;
+		next_index = rx_hash_table[index].used_next;
 		if (rx_hash_table[index].slave == slave) {
 			struct slave *assigned_slave = rlb_next_rx_slave(bond);
 
@@ -527,8 +541,8 @@ static void rlb_update_rx_clients(struct bonding *bond)
 
 	_lock_rx_hashtbl_bh(bond);
 
-	hash_index = bond_info->rx_hashtbl_head;
-	for (; hash_index != RLB_NULL_INDEX; hash_index = client_info->next) {
+	hash_index = bond_info->rx_hashtbl_used_head;
+	for (; hash_index != RLB_NULL_INDEX; hash_index = client_info->used_next) {
 		client_info = &(bond_info->rx_hashtbl[hash_index]);
 		if (client_info->ntt) {
 			rlb_update_client(client_info);
@@ -556,8 +570,8 @@ static void rlb_req_update_slave_clients(struct bonding *bond, struct slave *sla
 
 	_lock_rx_hashtbl_bh(bond);
 
-	hash_index = bond_info->rx_hashtbl_head;
-	for (; hash_index != RLB_NULL_INDEX; hash_index = client_info->next) {
+	hash_index = bond_info->rx_hashtbl_used_head;
+	for (; hash_index != RLB_NULL_INDEX; hash_index = client_info->used_next) {
 		client_info = &(bond_info->rx_hashtbl[hash_index]);
 
 		if ((client_info->slave == slave) &&
@@ -586,8 +600,8 @@ static void rlb_req_update_subnet_clients(struct bonding *bond, __be32 src_ip)
 
 	_lock_rx_hashtbl(bond);
 
-	hash_index = bond_info->rx_hashtbl_head;
-	for (; hash_index != RLB_NULL_INDEX; hash_index = client_info->next) {
+	hash_index = bond_info->rx_hashtbl_used_head;
+	for (; hash_index != RLB_NULL_INDEX; hash_index = client_info->used_next) {
 		client_info = &(bond_info->rx_hashtbl[hash_index]);
 
 		if (!client_info->slave) {
@@ -633,6 +647,7 @@ static struct slave *rlb_choose_channel(struct sk_buff *skb, struct bonding *bon
 				/* update mac address from arp */
 				memcpy(client_info->mac_dst, arp->mac_dst, ETH_ALEN);
 			}
+			memcpy(client_info->mac_src, arp->mac_src, ETH_ALEN);
 
 			assigned_slave = client_info->slave;
 			if (assigned_slave) {
@@ -655,6 +670,13 @@ static struct slave *rlb_choose_channel(struct sk_buff *skb, struct bonding *bon
 	assigned_slave = rlb_next_rx_slave(bond);
 
 	if (assigned_slave) {
+		if (!(client_info->assigned && client_info->ip_src == arp->ip_src)) {
+			/* ip_src is going to be updated, fix the src hash list */
+			u32 hash_src = _simple_hash((u8 *)&arp->ip_src, sizeof(arp->ip_src));
+			rlb_src_unlink(bond, hash_index);
+			rlb_src_link(bond, hash_src, hash_index);
+		}
+
 		client_info->ip_src = arp->ip_src;
 		client_info->ip_dst = arp->ip_dst;
 		/* arp->mac_dst is broadcast for arp reqeusts.
@@ -662,6 +684,7 @@ static struct slave *rlb_choose_channel(struct sk_buff *skb, struct bonding *bon
 		 * upon receiving an arp reply.
 		 */
 		memcpy(client_info->mac_dst, arp->mac_dst, ETH_ALEN);
+		memcpy(client_info->mac_src, arp->mac_src, ETH_ALEN);
 		client_info->slave = assigned_slave;
 
 		if (compare_ether_addr_64bits(client_info->mac_dst, mac_bcast)) {
@@ -677,11 +700,11 @@ static struct slave *rlb_choose_channel(struct sk_buff *skb, struct bonding *bon
 		}
 
 		if (!client_info->assigned) {
-			u32 prev_tbl_head = bond_info->rx_hashtbl_head;
-			bond_info->rx_hashtbl_head = hash_index;
-			client_info->next = prev_tbl_head;
+			u32 prev_tbl_head = bond_info->rx_hashtbl_used_head;
+			bond_info->rx_hashtbl_used_head = hash_index;
+			client_info->used_next = prev_tbl_head;
 			if (prev_tbl_head != RLB_NULL_INDEX) {
-				bond_info->rx_hashtbl[prev_tbl_head].prev =
+				bond_info->rx_hashtbl[prev_tbl_head].used_prev =
 					hash_index;
 			}
 			client_info->assigned = 1;
@@ -748,8 +771,8 @@ static void rlb_rebalance(struct bonding *bond)
 	_lock_rx_hashtbl_bh(bond);
 
 	ntt = 0;
-	hash_index = bond_info->rx_hashtbl_head;
-	for (; hash_index != RLB_NULL_INDEX; hash_index = client_info->next) {
+	hash_index = bond_info->rx_hashtbl_used_head;
+	for (; hash_index != RLB_NULL_INDEX; hash_index = client_info->used_next) {
 		client_info = &(bond_info->rx_hashtbl[hash_index]);
 		assigned_slave = rlb_next_rx_slave(bond);
 		if (assigned_slave && (client_info->slave != assigned_slave)) {
@@ -767,11 +790,113 @@ static void rlb_rebalance(struct bonding *bond)
 }
 
 /* Caller must hold rx_hashtbl lock */
+static void rlb_init_table_entry_dst(struct rlb_client_info *entry)
+{
+	entry->used_next = RLB_NULL_INDEX;
+	entry->used_prev = RLB_NULL_INDEX;
+	entry->assigned = 0;
+	entry->slave = NULL;
+	entry->tag = 0;
+}
+static void rlb_init_table_entry_src(struct rlb_client_info *entry)
+{
+	entry->src_first = RLB_NULL_INDEX;
+	entry->src_prev = RLB_NULL_INDEX;
+	entry->src_next = RLB_NULL_INDEX;
+}
+
 static void rlb_init_table_entry(struct rlb_client_info *entry)
 {
 	memset(entry, 0, sizeof(struct rlb_client_info));
-	entry->next = RLB_NULL_INDEX;
-	entry->prev = RLB_NULL_INDEX;
+	rlb_init_table_entry_dst(entry);
+	rlb_init_table_entry_src(entry);
+}
+
+static void rlb_delete_table_entry_dst(struct bonding *bond, u32 index)
+{
+	struct alb_bond_info *bond_info = &(BOND_ALB_INFO(bond));
+	u32 next_index = bond_info->rx_hashtbl[index].used_next;
+	u32 prev_index = bond_info->rx_hashtbl[index].used_prev;
+
+	if (index == bond_info->rx_hashtbl_used_head)
+		bond_info->rx_hashtbl_used_head = next_index;
+	if (prev_index != RLB_NULL_INDEX)
+		bond_info->rx_hashtbl[prev_index].used_next = next_index;
+	if (next_index != RLB_NULL_INDEX)
+		bond_info->rx_hashtbl[next_index].used_prev = prev_index;
+}
+
+/* unlink a rlb hash table entry from the src list */
+static void rlb_src_unlink(struct bonding *bond, u32 index)
+{
+	struct alb_bond_info *bond_info = &(BOND_ALB_INFO(bond));
+	u32 next_index = bond_info->rx_hashtbl[index].src_next;
+	u32 prev_index = bond_info->rx_hashtbl[index].src_prev;
+
+	bond_info->rx_hashtbl[index].src_next = RLB_NULL_INDEX;
+	bond_info->rx_hashtbl[index].src_prev = RLB_NULL_INDEX;
+
+	if (next_index != RLB_NULL_INDEX)
+		bond_info->rx_hashtbl[next_index].src_prev = prev_index;
+
+	if (prev_index == RLB_NULL_INDEX)
+		return;
+
+	/* is prev_index pointing to the head of this list? */
+	if (bond_info->rx_hashtbl[prev_index].src_first == index)
+		bond_info->rx_hashtbl[prev_index].src_first = next_index;
+	else
+		bond_info->rx_hashtbl[prev_index].src_next = next_index;
+
+}
+
+static void rlb_delete_table_entry(struct bonding *bond, u32 index)
+{
+	struct alb_bond_info *bond_info = &(BOND_ALB_INFO(bond));
+	struct rlb_client_info *entry = &(bond_info->rx_hashtbl[index]);
+
+	rlb_delete_table_entry_dst(bond, index);
+	rlb_init_table_entry_dst(entry);
+
+	rlb_src_unlink(bond, index);
+}
+
+/* add the rx_hashtbl[ip_dst_hash] entry to the list
+ * of entries with identical ip_src_hash
+ */
+static void rlb_src_link(struct bonding *bond, u32 ip_src_hash, u32 ip_dst_hash)
+{
+	struct alb_bond_info *bond_info = &(BOND_ALB_INFO(bond));
+	u32 next;
+
+	bond_info->rx_hashtbl[ip_dst_hash].src_prev = ip_src_hash;
+	next = bond_info->rx_hashtbl[ip_src_hash].src_first;
+	bond_info->rx_hashtbl[ip_dst_hash].src_next = next;
+	if (next != RLB_NULL_INDEX)
+		bond_info->rx_hashtbl[next].src_prev = ip_dst_hash;
+	bond_info->rx_hashtbl[ip_src_hash].src_first = ip_dst_hash;
+}
+
+/* deletes all rx_hashtbl entries with  arp->ip_src if their mac_src does
+ * not match arp->mac_src */
+static void rlb_purge_src_ip(struct bonding *bond, struct arp_pkt *arp)
+{
+	struct alb_bond_info *bond_info = &(BOND_ALB_INFO(bond));
+	u32 ip_src_hash = _simple_hash((u8*)&(arp->ip_src), sizeof(arp->ip_src));
+	u32 index;
+
+	_lock_rx_hashtbl_bh(bond);
+
+	index = bond_info->rx_hashtbl[ip_src_hash].src_first;
+	while (index != RLB_NULL_INDEX) {
+		struct rlb_client_info *entry = &(bond_info->rx_hashtbl[index]);
+		u32 next_index = entry->src_next;
+		if (entry->ip_src == arp->ip_src &&
+		    compare_ether_addr_64bits(arp->mac_src, entry->mac_src))
+				rlb_delete_table_entry(bond, index);
+		index = next_index;
+	}
+	_unlock_rx_hashtbl_bh(bond);
 }
 
 static int rlb_initialize(struct bonding *bond)
@@ -789,7 +914,7 @@ static int rlb_initialize(struct bonding *bond)
 
 	bond_info->rx_hashtbl = new_hashtbl;
 
-	bond_info->rx_hashtbl_head = RLB_NULL_INDEX;
+	bond_info->rx_hashtbl_used_head = RLB_NULL_INDEX;
 
 	for (i = 0; i < RLB_HASH_TABLE_SIZE; i++) {
 		rlb_init_table_entry(bond_info->rx_hashtbl + i);
@@ -811,7 +936,7 @@ static void rlb_deinitialize(struct bonding *bond)
 
 	kfree(bond_info->rx_hashtbl);
 	bond_info->rx_hashtbl = NULL;
-	bond_info->rx_hashtbl_head = RLB_NULL_INDEX;
+	bond_info->rx_hashtbl_used_head = RLB_NULL_INDEX;
 
 	_unlock_rx_hashtbl_bh(bond);
 }
@@ -823,25 +948,13 @@ static void rlb_clear_vlan(struct bonding *bond, unsigned short vlan_id)
 
 	_lock_rx_hashtbl_bh(bond);
 
-	curr_index = bond_info->rx_hashtbl_head;
+	curr_index = bond_info->rx_hashtbl_used_head;
 	while (curr_index != RLB_NULL_INDEX) {
 		struct rlb_client_info *curr = &(bond_info->rx_hashtbl[curr_index]);
-		u32 next_index = bond_info->rx_hashtbl[curr_index].next;
-		u32 prev_index = bond_info->rx_hashtbl[curr_index].prev;
-
-		if (curr->tag && (curr->vlan_id == vlan_id)) {
-			if (curr_index == bond_info->rx_hashtbl_head) {
-				bond_info->rx_hashtbl_head = next_index;
-			}
-			if (prev_index != RLB_NULL_INDEX) {
-				bond_info->rx_hashtbl[prev_index].next = next_index;
-			}
-			if (next_index != RLB_NULL_INDEX) {
-				bond_info->rx_hashtbl[next_index].prev = prev_index;
-			}
+		u32 next_index = bond_info->rx_hashtbl[curr_index].used_next;
 
-			rlb_init_table_entry(curr);
-		}
+		if (curr->tag && (curr->vlan_id == vlan_id))
+			rlb_delete_table_entry(bond, curr_index);
 
 		curr_index = next_index;
 	}
diff --git a/drivers/net/bonding/bond_alb.h b/drivers/net/bonding/bond_alb.h
index 90f140a..1fbc938 100644
--- a/drivers/net/bonding/bond_alb.h
+++ b/drivers/net/bonding/bond_alb.h
@@ -100,9 +100,18 @@ struct tlb_client_info {
 struct rlb_client_info {
 	__be32 ip_src;		/* the server IP address */
 	__be32 ip_dst;		/* the client IP address */
+	u8  mac_src[ETH_ALEN];	/* the server MAC address */
 	u8  mac_dst[ETH_ALEN];	/* the client MAC address */
-	u32 next;		/* The next Hash table entry index */
-	u32 prev;		/* The previous Hash table entry index */
+
+	/* list of used hash table entries, starting at rx_hashtbl_used_head */
+	u32 used_next;
+	u32 used_prev;
+
+	/* ip_src based hashing */
+	u32 src_next;	/* next entry with same hash(ip_src) */
+	u32 src_prev;	/* prev entry with same hash(ip_src) */
+	u32 src_first;	/* first entry with hash(ip_src) == this entry's index */
+
 	u8  assigned;		/* checking whether this entry is assigned */
 	u8  ntt;		/* flag - need to transmit client info */
 	struct slave *slave;	/* the slave assigned to this client */
@@ -131,7 +140,7 @@ struct alb_bond_info {
 	int rlb_enabled;
 	struct rlb_client_info	*rx_hashtbl;	/* Receive hash table */
 	spinlock_t		rx_hashtbl_lock;
-	u32			rx_hashtbl_head;
+	u32			rx_hashtbl_used_head;
 	u8			rx_ntt;	/* flag - need to transmit
 					 * to all rx clients
 					 */
diff --git a/drivers/net/bonding/bond_debugfs.c b/drivers/net/bonding/bond_debugfs.c
index 3680aa2..a570843 100644
--- a/drivers/net/bonding/bond_debugfs.c
+++ b/drivers/net/bonding/bond_debugfs.c
@@ -31,8 +31,8 @@ static int bond_debug_rlb_hash_show(struct seq_file *m, void *v)
 
 	spin_lock_bh(&(BOND_ALB_INFO(bond).rx_hashtbl_lock));
 
-	hash_index = bond_info->rx_hashtbl_head;
-	for (; hash_index != RLB_NULL_INDEX; hash_index = client_info->next) {
+	hash_index = bond_info->rx_hashtbl_used_head;
+	for (; hash_index != RLB_NULL_INDEX; hash_index = client_info->used_next) {
 		client_info = &(bond_info->rx_hashtbl[hash_index]);
 		seq_printf(m, "%-15pI4 %-15pI4 %-17pM %s\n",
 			&client_info->ip_src,
 

-- 
Jiri Bohac <jbohac@suse.cz>
SUSE Labs, SUSE CZ
