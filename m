From: Jiri Pirko <jpirko@redhat.com>
Subject: [PATCH net-next-2.6] bonding: optimize tlb_get_least_loaded_slave
Date: Wed, 19 May 2010 15:26:39 +0200
Message-ID: <20100519132638.GC2788@psychotron.lab.eng.brq.redhat.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: davem@davemloft.net, fubar@us.ibm.com,
	bonding-devel@lists.sourceforge.net
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mx1.redhat.com ([209.132.183.28]:41712 "EHLO mx1.redhat.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1751624Ab0ESN0t (ORCPT <rfc822;netdev@vger.kernel.org>);
	Wed, 19 May 2010 09:26:49 -0400
Content-Disposition: inline
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

In the worst case, when the first loop breaks an the end of the slave list,
the slave list is iterated through twice. This patch reduces this
function only to one loop. Also makes it simpler.

Signed-off-by: Jiri Pirko <jpirko@redhat.com>
---
 drivers/net/bonding/bond_alb.c |   33 +++++++++++++--------------------
 1 files changed, 13 insertions(+), 20 deletions(-)

diff --git a/drivers/net/bonding/bond_alb.c b/drivers/net/bonding/bond_alb.c
index 40fdc41..25c14c6 100644
--- a/drivers/net/bonding/bond_alb.c
+++ b/drivers/net/bonding/bond_alb.c
@@ -233,34 +233,27 @@ static void tlb_deinitialize(struct bonding *bond)
 	_unlock_tx_hashtbl(bond);
 }
 
+static long long compute_gap(struct slave *slave)
+{
+	return (s64) (slave->speed << 20) - /* Convert to Megabit per sec */
+	       (s64) (SLAVE_TLB_INFO(slave).load << 3); /* Bytes to bits */
+}
+
 /* Caller must hold bond lock for read */
 static struct slave *tlb_get_least_loaded_slave(struct bonding *bond)
 {
 	struct slave *slave, *least_loaded;
-	s64 max_gap;
-	int i, found = 0;
-
-	/* Find the first enabled slave */
-	bond_for_each_slave(bond, slave, i) {
-		if (SLAVE_IS_OK(slave)) {
-			found = 1;
-			break;
-		}
-	}
-
-	if (!found) {
-		return NULL;
-	}
+	long long max_gap;
+	int i;
 
-	least_loaded = slave;
-	max_gap = (s64)(slave->speed << 20) - /* Convert to Megabit per sec */
-			(s64)(SLAVE_TLB_INFO(slave).load << 3); /* Bytes to bits */
+	least_loaded = NULL;
+	max_gap = LLONG_MIN;
 
 	/* Find the slave with the largest gap */
-	bond_for_each_slave_from(bond, slave, i, least_loaded) {
+	bond_for_each_slave(bond, slave, i) {
 		if (SLAVE_IS_OK(slave)) {
-			s64 gap = (s64)(slave->speed << 20) -
-					(s64)(SLAVE_TLB_INFO(slave).load << 3);
+			long long gap = compute_gap(slave);
+
 			if (max_gap < gap) {
 				least_loaded = slave;
 				max_gap = gap;
-- 
1.6.6.1

