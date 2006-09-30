From: Jay Vosburgh <fubar@us.ibm.com>
Subject: [PATCH] bonding: fix deadlock on high loads in bond_alb_monitor()
Date: Fri, 29 Sep 2006 23:28:42 -0700
Message-ID: <200609300628.k8U6SgZt030638@death.nxdomain.ibm.com>
Cc: Jeff Garzik <jgarzik@pobox.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from e33.co.us.ibm.com ([32.97.110.151]:5509 "EHLO e33.co.us.ibm.com")
	by vger.kernel.org with ESMTP id S1751063AbWI3G2p (ORCPT
	<rfc822;netdev@vger.kernel.org>); Sat, 30 Sep 2006 02:28:45 -0400
Received: from westrelay02.boulder.ibm.com (westrelay02.boulder.ibm.com [9.17.195.11])
	by e33.co.us.ibm.com (8.13.8/8.12.11) with ESMTP id k8U6SilK007269
	for <netdev@vger.kernel.org>; Sat, 30 Sep 2006 02:28:44 -0400
Received: from d03av01.boulder.ibm.com (d03av01.boulder.ibm.com [9.17.195.167])
	by westrelay02.boulder.ibm.com (8.13.6/8.13.6/NCO v8.1.1) with ESMTP id k8U6SidX518262
	for <netdev@vger.kernel.org>; Sat, 30 Sep 2006 00:28:44 -0600
Received: from d03av01.boulder.ibm.com (loopback [127.0.0.1])
	by d03av01.boulder.ibm.com (8.12.11.20060308/8.13.3) with ESMTP id k8U6SiHf005871
	for <netdev@vger.kernel.org>; Sat, 30 Sep 2006 00:28:44 -0600
To: netdev@vger.kernel.org, bonding-devel@lists.sourceforge.net
Subject: 
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org


From: Karsten Keil <kkeil@suse.de>

In bond_alb_monitor the bond->curr_slave_lock write lock is taken
and then dev_set_promiscuity maybe called which can take some time,
depending on the network HW. If a network IRQ for this card come in
the softirq handler maybe try to deliver more packets which end up in
a request to the read lock of bond->curr_slave_lock -> deadlock.
This issue was found by a test lab during network stress tests, this patch
disable the softirq handler for this case and solved the issue.

Signed-off-by: Karsten Keil <kkeil@suse.de>
Acked-by: Jay Vosburgh <fubar@us.ibm.com>

---

 drivers/net/bonding/bond_alb.c |    4 ++--
 1 files changed, 2 insertions(+), 2 deletions(-)

921ada40bf96d7dc9c4258821af3d4616fb3cbae
diff --git a/drivers/net/bonding/bond_alb.c b/drivers/net/bonding/bond_alb.c
index e83bc82..3292316 100644
--- a/drivers/net/bonding/bond_alb.c
+++ b/drivers/net/bonding/bond_alb.c
@@ -1433,7 +1433,7 @@ void bond_alb_monitor(struct bonding *bo
 		 * write lock to protect from other code that also
 		 * sets the promiscuity.
 		 */
-		write_lock(&bond->curr_slave_lock);
+		write_lock_bh(&bond->curr_slave_lock);
 
 		if (bond_info->primary_is_promisc &&
 		    (++bond_info->rlb_promisc_timeout_counter >= RLB_PROMISC_TIMEOUT)) {
@@ -1448,7 +1448,7 @@ void bond_alb_monitor(struct bonding *bo
 			bond_info->primary_is_promisc = 0;
 		}
 
-		write_unlock(&bond->curr_slave_lock);
+		write_unlock_bh(&bond->curr_slave_lock);
 
 		if (bond_info->rlb_rebalance) {
 			bond_info->rlb_rebalance = 0;


