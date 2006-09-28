From: Karsten Keil <kkeil@suse.de>
Subject: [Resend][RFC/PATCH] fix deadlock on high loads in bond_alb_monitor()
Date: Thu, 28 Sep 2006 14:39:41 +0200
Message-ID: <20060928123941.GA10067@pingi.kke.suse.de>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: netdev@vger.kernel.org, bonding-devel@lists.sourceforge.net
Return-path: <netdev-owner@vger.kernel.org>
Received: from cantor2.suse.de ([195.135.220.15]:63928 "EHLO mx2.suse.de")
	by vger.kernel.org with ESMTP id S1750776AbWI1Mjn (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 28 Sep 2006 08:39:43 -0400
To: Jay Vosburgh <fubar@us.ibm.com>
Content-Disposition: inline
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

In bond_alb_monitor the bond->curr_slave_lock write lock is taken
and then dev_set_promiscuity maybe called which can take some time,
depending on the network HW. If a network IRQ for this card come in
the softirq handler maybe try to deliver more packets which end up in
a request to the read lock of bond->curr_slave_lock -> deadlock.
This issue was found by a test lab during network stress tests, this patch
disable the softirq handler for this case and solved the issue.

Signed-off-by: Karsten Keil <kkeil@suse.de>


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


-- 
Karsten Keil
SuSE Labs
