From: Jay Vosburgh <fubar@us.ibm.com>
Subject: [PATCH 1/3] bonding: allow previous slave to be used when re-balancing traffic on tlb/alb interfaces
Date: Tue, 29 Sep 2009 17:15:29 -0700
Message-ID: <1254269731-7341-2-git-send-email-fubar@us.ibm.com>
References: <1254269731-7341-1-git-send-email-fubar@us.ibm.com>
Cc: David Miller <davem@davemloft.net>,
	Andy Gospodarek <andy@greyhouse.net>
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from e8.ny.us.ibm.com ([32.97.182.138]:44155 "EHLO e8.ny.us.ibm.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1753564AbZI3APe (ORCPT <rfc822;netdev@vger.kernel.org>);
	Tue, 29 Sep 2009 20:15:34 -0400
Received: from d01relay02.pok.ibm.com (d01relay02.pok.ibm.com [9.56.227.234])
	by e8.ny.us.ibm.com (8.14.3/8.13.1) with ESMTP id n8U0DFiV017010
	for <netdev@vger.kernel.org>; Tue, 29 Sep 2009 20:13:15 -0400
Received: from d01av04.pok.ibm.com (d01av04.pok.ibm.com [9.56.224.64])
	by d01relay02.pok.ibm.com (8.13.8/8.13.8/NCO v10.0) with ESMTP id n8U0FcN3248582
	for <netdev@vger.kernel.org>; Tue, 29 Sep 2009 20:15:38 -0400
Received: from d01av04.pok.ibm.com (loopback [127.0.0.1])
	by d01av04.pok.ibm.com (8.12.11.20060308/8.13.3) with ESMTP id n8U0FbIB023087
	for <netdev@vger.kernel.org>; Tue, 29 Sep 2009 20:15:38 -0400
In-Reply-To: <1254269731-7341-1-git-send-email-fubar@us.ibm.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Andy Gospodarek <andy@greyhouse.net>

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
Signed-off-by: Jay Vosburgh <fubar@us.ibm.com>

---
 drivers/net/bonding/bond_alb.c |   21 ++++++++++++++++++++-
 drivers/net/bonding/bond_alb.h |    4 ++++
 2 files changed, 24 insertions(+), 1 deletions(-)

diff --git a/drivers/net/bonding/bond_alb.c b/drivers/net/bonding/bond_alb.c
index 9b5936f..cf2842e 100644
--- a/drivers/net/bonding/bond_alb.c
+++ b/drivers/net/bonding/bond_alb.c
@@ -150,6 +150,7 @@ static inline void tlb_init_table_entry(struct tlb_client_info *entry, int save_
 		entry->load_history = 1 + entry->tx_bytes /
 				      BOND_TLB_REBALANCE_INTERVAL;
 		entry->tx_bytes = 0;
+		entry->last_slave = entry->tx_slave;
 	}
 
 	entry->tx_slave = NULL;
@@ -270,6 +271,24 @@ static struct slave *tlb_get_least_loaded_slave(struct bonding *bond)
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
@@ -282,7 +301,7 @@ static struct slave *tlb_choose_channel(struct bonding *bond, u32 hash_index, u3
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
1.6.0.2

