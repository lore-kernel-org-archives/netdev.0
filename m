From: Andy Gospodarek <andy@greyhouse.net>
Subject: [PATCH 1/4] bonding: allow previous slave to be used when
	re-balancing traffic on tlb/alb interfaces
Date: Fri, 11 Sep 2009 17:10:10 -0400
Message-ID: <20090911211009.GQ8515@gospo.rdu.redhat.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
To: netdev@vger.kernel.org, fubar@us.ibm.com,
	bonding-devel@lists.sourceforge.net
Return-path: <netdev-owner@vger.kernel.org>
Received: from mx1.redhat.com ([209.132.183.28]:19660 "EHLO mx1.redhat.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1751307AbZIKVKV (ORCPT <rfc822;netdev@vger.kernel.org>);
	Fri, 11 Sep 2009 17:10:21 -0400
Content-Disposition: inline
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

[PATCH] bonding: allow previous slave to be used when re-balancing traffic on tlb/alb interfaces

When using tlb (mode 5) or alb (mode 6) bonding, a task runs every 10s
and re-balances the output devices based on load.  I was trying to
diagnose some connectivity issues and realized that a high-traffic host
would often switch output interfaces every 10s.  I discovered this
happened because the 'least loaded interface' was chosen as the next
output interface for any given stream and quite often some lower load
traffic would slip in an take the interface previously used by our
stream.  This meant the 'least loaded interface' was no longer the one
we used during the last interval.

The switching of streams to another interface was not extremely helpful
as it would force the destination host or router to update its ARP
tables and produce some additional ARP traffic as the destination host
verified that is was using the MAC address it expected.  Having the
destination MAC for a given IP change every 10s seems undesirable.

The decision was made to use the same slave during this interval if the
current load on that interface was < 10.  A load of < 10 indicates that
during the last 10s sample, roughly 100bytes were sent by all streams
currently assigned to that interface.  This essentially means the
interface is unloaded, but allows for a few frames that will probably
have minimal impact to slip into the same interface we were using in the
past.

Signed-off-by: Andy Gospodarek <andy@greyhouse.net>

---
 drivers/net/bonding/bond_alb.c |   21 ++++++++++++++++++++-
 drivers/net/bonding/bond_alb.h |    4 ++++
 2 files changed, 24 insertions(+), 1 deletions(-)

diff --git a/drivers/net/bonding/bond_alb.c b/drivers/net/bonding/bond_alb.c
index 46d312b..bcf25c6 100644
--- a/drivers/net/bonding/bond_alb.c
+++ b/drivers/net/bonding/bond_alb.c
@@ -143,6 +143,7 @@ static inline void tlb_init_table_entry(struct tlb_client_info *entry, int save_
 		entry->load_history = 1 + entry->tx_bytes /
 				      BOND_TLB_REBALANCE_INTERVAL;
 		entry->tx_bytes = 0;
+		entry->last_slave = entry->tx_slave;
 	}
 
 	entry->tx_slave = NULL;
@@ -263,6 +264,24 @@ static struct slave *tlb_get_least_loaded_slave(struct bonding *bond)
 	return least_loaded;
 }
 
+/* Caller must hold bond lock for read and hashtbl lock */
+static struct slave *tlb_get_best_slave(struct bonding *bond, u32 hash_index)
+{
+	struct alb_bond_info *bond_info = &(BOND_ALB_INFO(bond));
+	struct tlb_client_info *tx_hash_table = bond_info->tx_hashtbl;
+	struct slave *last_slave = tx_hash_table[hash_index].last_slave;
+	struct slave *next_slave = NULL;
+
+	if (last_slave && SLAVE_IS_OK(last_slave)) {
+		/* Use the last slave listed in the tx hashtbl if:
+		   the last slave currently is essentially unloaded. */
+		if (SLAVE_TLB_INFO(last_slave).load < 10)
+			next_slave = last_slave;
+	}
+
+	return next_slave ? next_slave : tlb_get_least_loaded_slave(bond);
+}
+
 /* Caller must hold bond lock for read */
 static struct slave *tlb_choose_channel(struct bonding *bond, u32 hash_index, u32 skb_len)
 {
@@ -275,7 +294,7 @@ static struct slave *tlb_choose_channel(struct bonding *bond, u32 hash_index, u3
 	hash_table = bond_info->tx_hashtbl;
 	assigned_slave = hash_table[hash_index].tx_slave;
 	if (!assigned_slave) {
-		assigned_slave = tlb_get_least_loaded_slave(bond);
+		assigned_slave = tlb_get_best_slave(bond, hash_index);
 
 		if (assigned_slave) {
 			struct tlb_slave_info *slave_info =
diff --git a/drivers/net/bonding/bond_alb.h b/drivers/net/bonding/bond_alb.h
index 50968f8..b65fd29 100644
--- a/drivers/net/bonding/bond_alb.h
+++ b/drivers/net/bonding/bond_alb.h
@@ -36,6 +36,10 @@ struct tlb_client_info {
 				 * packets to a Client that the Hash function
 				 * gave this entry index.
 				 */
+	struct slave *last_slave; /* Pointer to last slave used for transmiting
+				 * packets to a Client that the Hash function
+				 * gave this entry index.
+				 */
 	u32 tx_bytes;		/* Each Client acumulates the BytesTx that
 				 * were tranmitted to it, and after each
 				 * CallBack the LoadHistory is devided
-- 
1.5.5.6

