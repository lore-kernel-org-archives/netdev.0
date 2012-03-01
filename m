From: Jay Vosburgh <fubar@us.ibm.com>
Subject: Re: [PATCH][RFC] bonding: delete migrated IP addresses from the rlb hash table
Date: Wed, 29 Feb 2012 18:12:20 -0800
Message-ID: <14150.1330567940@death.nxdomain>
References: <20120227173400.GB816@midget.suse.cz>
Cc: Andy Gospodarek <andy@greyhouse.net>, netdev@vger.kernel.org
To: Jiri Bohac <jbohac@suse.cz>
Return-path: <netdev-owner@vger.kernel.org>
Received: from e38.co.us.ibm.com ([32.97.110.159]:50390 "EHLO
	e38.co.us.ibm.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1753464Ab2CACNE (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 29 Feb 2012 21:13:04 -0500
Received: from /spool/local
	by e38.co.us.ibm.com with IBM ESMTP SMTP Gateway: Authorized Use Only! Violators will be prosecuted
	for <netdev@vger.kernel.org> from <fubar@us.ibm.com>;
	Wed, 29 Feb 2012 19:13:02 -0700
Received: from d01relay04.pok.ibm.com (d01relay04.pok.ibm.com [9.56.227.236])
	by d01dlp03.pok.ibm.com (Postfix) with ESMTP id CE0B5C9005C
	for <netdev@vger.kernel.org>; Wed, 29 Feb 2012 21:12:22 -0500 (EST)
Received: from d03av06.boulder.ibm.com (d03av06.boulder.ibm.com [9.17.195.245])
	by d01relay04.pok.ibm.com (8.13.8/8.13.8/NCO v10.0) with ESMTP id q212CMdI338880
	for <netdev@vger.kernel.org>; Wed, 29 Feb 2012 21:12:22 -0500
Received: from d03av06.boulder.ibm.com (loopback [127.0.0.1])
	by d03av06.boulder.ibm.com (8.14.4/8.13.1/NCO v10.0 AVout) with ESMTP id q212CZcB020928
	for <netdev@vger.kernel.org>; Wed, 29 Feb 2012 19:12:35 -0700
In-reply-to: <20120227173400.GB816@midget.suse.cz>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Jiri Bohac <jbohac@suse.cz> wrote:

>Bonding in balance-alb mode records information from ARP packets
>passing through the bond in a hash table (rx_hashtbl).
>
>At certain situations (e.g. link change of a slave),
>rlb_update_rx_clients() will send out ARP packets to update ARP
>caches of other hosts on the network to achieve RX load balancing.
>
>The problem is that once an IP address is recorded in the hash
>table, it stays there indefinitely [1]. If this IP address is
>migrated to a different host in the network, bonding still sends
>out ARP packets that poison other systems' ARP caches with
>invalid information.
>
>This patch solves this by looking at all incoming ARP packets,
>and checking if the source IP address is one of the source
>addresses stored in the rx_hashtbl. If it is, the corresponding
>hash table entries are removed. Thus, when an IP address is
>migrated, the first ARP broadcast by its new owner will purge the
>offending entries of rx_hashtbl.
>
>  (a simpler approach, where bonding would monitor IP address
>   changes on the local system does not work for setups like:
>   HostA --- NetworkA --- eth0-bond0-br0 --- NetworkB --- hostB
>   and an IP address migrating from HostB to HostA)
>
>The hash table is hashed by ip_dst. To be able to do the above
>check efficiently (not walking the whole hash table), we need a
>reverse mapping (by ip_src).
>
>I added three new members in struct rlb_client_info:
>   rx_hashtbl[x].reverse_first will point to the start of a list of
>      entries for which hash(ip_src) == x.
>   The list is linked with reverse_next and reverse_prev.
>
>When an incoming ARP packet arrives at rlb_arp_recv()
>rlb_purge_src_ip() can quickly walk only the entries on the
>corresponding lists, i.e. the entries that are likely to contain
>the offending IP address.

	I've done some initial testing with this, and so far I'm seeing
one problem: every time the local host (with bonding) sends a broadcast
ARP, that ends up flushing the entire RLB table.  Well, all entries that
match the IP on the bond that's sending an ARP request, which is just
one address in my testing.

	Anyway, this happens because the switch forwards the broadcast
ARP back around to one of the other bond slaves, and then that
"incoming" ARP bears an ip_src of our already-in-use IP address, and
that matches everything in the table.

	So, yes, this does work to flush entries out of the table using
a particular IP source address, but as a practical matter the false
positives will vastly outnumber the valid hits.  Yes, the table will
repopulate itself, but that does have some cost if, e.g., flows bounce
around from one interface to another.  How often this happens would be a
function of how often the bond has to ARP for an unknown address (i.e.,
send a broadcast ARP).

	Perhaps a check that the ip_src being flushed is not actually in
use locally is warranted?

	-J

>-----
>[1]: ... unless it is replaced with another value that happens to
>have the same hash -- rx_hashtbl is not a proper hash table. In
>case of a collision, the old entry is replaced by the new one.
>
>Signed-off-by: Jiri Bohac <jbohac@suse.cz>
>
>--- a/drivers/net/bonding/bond_alb.c
>+++ b/drivers/net/bonding/bond_alb.c
>@@ -84,6 +84,9 @@ static inline struct arp_pkt *arp_pkt(const struct sk_buff *skb)
>
> /* Forward declaration */
> static void alb_send_learning_packets(struct slave *slave, u8 mac_addr[]);
>+static void rlb_purge_src_ip(struct bonding *bond, u32 ip_src);
>+static void rlb_delete_table_entry_reverse(struct bonding* bond, u32 index);
>+static void rlb_set_reverse_entry(struct bonding* bond, u32 ip_src_hash, u32 ip_dst_hash);
>
> static inline u8 _simple_hash(const u8 *hash_start, int hash_size)
> {
>@@ -366,6 +369,15 @@ static void rlb_arp_recv(struct sk_buff *skb, struct bonding *bond,
> 		return;
> 	}
>
>+	/* We received an ARP from arp->ip_src.
>+	 * We might have used this IP address previously (on the bonding host
>+	 * itself or on a system that is bridged together with the bond), but
>+	 * now the IP has migrated elsewhere and we must prevent sending out
>+	 * client updates with this IP address as the source.
>+	 * Clean up all hash table entries that have this address as ip_src.
>+	 */
>+	rlb_purge_src_ip(bond, arp->ip_src);
>+
> 	if (arp->op_code == htons(ARPOP_REPLY)) {
> 		/* update rx hash table for this ARP */
> 		rlb_update_entry_from_arp(bond, arp);
>@@ -657,6 +669,13 @@ static struct slave *rlb_choose_channel(struct sk_buff *skb, struct bonding *bon
> 	assigned_slave = rlb_next_rx_slave(bond);
>
> 	if (assigned_slave) {
>+		if (!(client_info->assigned && client_info->ip_src == arp->ip_src)) {
>+			/* ip_src is going to be updated, fix the reverse hashing */
>+			u32 hash_src = _simple_hash((u8 *)&arp->ip_src, sizeof(arp->ip_src));
>+			rlb_delete_table_entry_reverse(bond, hash_index);
>+			rlb_set_reverse_entry(bond, hash_src, hash_index);
>+		}
>+
> 		client_info->ip_src = arp->ip_src;
> 		client_info->ip_dst = arp->ip_dst;
> 		/* arp->mac_dst is broadcast for arp reqeusts.
>@@ -769,11 +788,111 @@ static void rlb_rebalance(struct bonding *bond)
> }
>
> /* Caller must hold rx_hashtbl lock */
>-static void rlb_init_table_entry(struct rlb_client_info *entry)
>+static void rlb_init_table_entry_forward(struct rlb_client_info *entry)
> {
>-	memset(entry, 0, sizeof(struct rlb_client_info));
> 	entry->next = RLB_NULL_INDEX;
> 	entry->prev = RLB_NULL_INDEX;
>+	entry->assigned = 0;
>+	entry->slave = NULL;
>+	entry->tag = 0;
>+}
>+static void rlb_init_table_entry_reverse(struct rlb_client_info *entry)
>+{
>+	entry->reverse_first = RLB_NULL_INDEX;
>+	entry->reverse_prev = RLB_NULL_INDEX;
>+	entry->reverse_next = RLB_NULL_INDEX;
>+}
>+
>+static void rlb_init_table_entry(struct rlb_client_info *entry)
>+{
>+	memset(entry, 0, sizeof(struct rlb_client_info));
>+	rlb_init_table_entry_forward(entry);
>+	rlb_init_table_entry_reverse(entry);
>+}
>+
>+static void rlb_delete_table_entry_forward(struct bonding* bond, u32 index)
>+{
>+	struct alb_bond_info *bond_info = &(BOND_ALB_INFO(bond));
>+	u32 next_index = bond_info->rx_hashtbl[index].next;
>+	u32 prev_index = bond_info->rx_hashtbl[index].prev;
>+
>+	if (index == bond_info->rx_hashtbl_head) {
>+		bond_info->rx_hashtbl_head = next_index;
>+	}
>+	if (prev_index != RLB_NULL_INDEX) {
>+		bond_info->rx_hashtbl[prev_index].next = next_index;
>+	}
>+	if (next_index != RLB_NULL_INDEX) {
>+		bond_info->rx_hashtbl[next_index].prev = prev_index;
>+	}
>+}
>+
>+static void rlb_delete_table_entry_reverse(struct bonding* bond, u32 index)
>+{
>+	struct alb_bond_info *bond_info = &(BOND_ALB_INFO(bond));
>+	u32 next_index = bond_info->rx_hashtbl[index].reverse_next;
>+	u32 prev_index = bond_info->rx_hashtbl[index].reverse_prev;
>+
>+	bond_info->rx_hashtbl[index].reverse_next = RLB_NULL_INDEX;
>+	bond_info->rx_hashtbl[index].reverse_prev = RLB_NULL_INDEX;
>+
>+	if (next_index != RLB_NULL_INDEX) {
>+		bond_info->rx_hashtbl[next_index].reverse_prev = prev_index;
>+	}
>+
>+	if (prev_index ==  RLB_NULL_INDEX)
>+		return;
>+
>+	/* is prev_index pointing to the head of this chain? */
>+	if (bond_info->rx_hashtbl[prev_index].reverse_first == index)
>+		bond_info->rx_hashtbl[prev_index].reverse_first = next_index;
>+	else
>+		bond_info->rx_hashtbl[prev_index].reverse_next = next_index;
>+
>+}
>+
>+static void rlb_delete_table_entry(struct bonding* bond, u32 index)
>+{
>+	struct alb_bond_info *bond_info = &(BOND_ALB_INFO(bond));
>+	struct rlb_client_info *entry = &(bond_info->rx_hashtbl[index]);
>+
>+	rlb_delete_table_entry_forward(bond, index);
>+	rlb_init_table_entry_forward(entry);
>+
>+	rlb_delete_table_entry_reverse(bond, index);
>+}
>+
>+static void rlb_set_reverse_entry(struct bonding* bond, u32 ip_src_hash, u32 ip_dst_hash)
>+{
>+	struct alb_bond_info *bond_info = &(BOND_ALB_INFO(bond));
>+	u32 next;
>+
>+	bond_info->rx_hashtbl[ip_dst_hash].reverse_prev = ip_src_hash;
>+	next = bond_info->rx_hashtbl[ip_src_hash].reverse_first;
>+	bond_info->rx_hashtbl[ip_dst_hash].reverse_next = next;
>+	if (next != RLB_NULL_INDEX)
>+		bond_info->rx_hashtbl[next].reverse_prev = ip_dst_hash;
>+	bond_info->rx_hashtbl[ip_src_hash].reverse_first = ip_dst_hash;
>+}
>+
>+/* deletes all entries with a given ip_src */
>+static void rlb_purge_src_ip(struct bonding *bond, u32 ip_src)
>+{
>+	struct alb_bond_info *bond_info = &(BOND_ALB_INFO(bond));
>+	u32 ip_src_hash = _simple_hash((u8*)&(ip_src), sizeof(ip_src));
>+	u32 index;
>+
>+	_lock_rx_hashtbl_bh(bond);
>+
>+	index = bond_info->rx_hashtbl[ip_src_hash].reverse_first;
>+	while (index != RLB_NULL_INDEX) {
>+		struct rlb_client_info *entry = &(bond_info->rx_hashtbl[index]);
>+		u32 next_index = entry->reverse_next;
>+		if (entry->ip_src == ip_src)
>+			rlb_delete_table_entry(bond, index);
>+		index = next_index;
>+	}
>+	_unlock_rx_hashtbl_bh(bond);
> }
>
> static int rlb_initialize(struct bonding *bond)
>@@ -831,21 +950,9 @@ static void rlb_clear_vlan(struct bonding *bond, unsigned short vlan_id)
> 	while (curr_index != RLB_NULL_INDEX) {
> 		struct rlb_client_info *curr = &(bond_info->rx_hashtbl[curr_index]);
> 		u32 next_index = bond_info->rx_hashtbl[curr_index].next;
>-		u32 prev_index = bond_info->rx_hashtbl[curr_index].prev;
>
>-		if (curr->tag && (curr->vlan_id == vlan_id)) {
>-			if (curr_index == bond_info->rx_hashtbl_head) {
>-				bond_info->rx_hashtbl_head = next_index;
>-			}
>-			if (prev_index != RLB_NULL_INDEX) {
>-				bond_info->rx_hashtbl[prev_index].next = next_index;
>-			}
>-			if (next_index != RLB_NULL_INDEX) {
>-				bond_info->rx_hashtbl[next_index].prev = prev_index;
>-			}
>-
>-			rlb_init_table_entry(curr);
>-		}
>+		if (curr->tag && (curr->vlan_id == vlan_id))
>+			rlb_delete_table_entry(bond, curr_index);
>
> 		curr_index = next_index;
> 	}
>diff --git a/drivers/net/bonding/bond_alb.h b/drivers/net/bonding/bond_alb.h
>index 90f140a..f10ecf7 100644
>--- a/drivers/net/bonding/bond_alb.h
>+++ b/drivers/net/bonding/bond_alb.h
>@@ -108,6 +108,9 @@ struct rlb_client_info {
> 	struct slave *slave;	/* the slave assigned to this client */
> 	u8 tag;			/* flag - need to tag skb */
> 	unsigned short vlan_id;	/* VLAN tag associated with IP address */
>+	u32 reverse_next;	/* next entry with same hash(ip_src) */
>+	u32 reverse_prev;	/* prev entry with same hash(ip_src) */
>+	u32 reverse_first;	/* first entry with hash(ip_src) == this entry's index */
> };
>
> struct tlb_slave_info {
>
>-- 
>Jiri Bohac <jbohac@suse.cz>
>SUSE Labs, SUSE CZ
>

---
	-Jay Vosburgh, IBM Linux Technology Center, fubar@us.ibm.com
