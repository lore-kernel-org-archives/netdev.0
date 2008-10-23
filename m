From: Andy Gospodarek <andy@greyhouse.net>
Subject: [PATCH net-next] bonding: fix panic when taking bond interface
	down before removing module
Date: Wed, 22 Oct 2008 21:50:24 -0400
Message-ID: <20081023015024.GB11129@gospo.rdu.redhat.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: stable@kernel.org
To: netdev@vger.kernel.org, fubar@us.ibm.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from mx2.redhat.com ([66.187.237.31]:59635 "EHLO mx2.redhat.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1751195AbYJWBub (ORCPT <rfc822;netdev@vger.kernel.org>);
	Wed, 22 Oct 2008 21:50:31 -0400
Content-Disposition: inline
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>


A panic was discovered with bonding when using mode 5 or 6 and trying to
remove the slaves from the bond after the interface was taken down.
When calling 'ifconfig bond0 down' the following happens:

    bond_close()
        bond_alb_deinitialize()
            tlb_deinitialize()
		kfree(bond_info->tx_hashtbl)
                bond_info->tx_hashtbl = NULL

Unfortunately if there are still slaves in the bond, when removing the
module the following happens:

    bonding_exit()
        bond_free_all()
            bond_release_all()
                bond_alb_deinit_slave()
                    tlb_clear_slave()
                        tx_hash_table = BOND_ALB_INFO(bond).tx_hashtbl
			u32 next_index = tx_hash_table[index].next

As you might guess we panic when trying to access a few entries into the
table that no longer exists.

I experimented with several options (like moving the calls to
tlb_deinitialize somewhere else), but it really makes the most sense to
be part of the bond_close routine.  It also didn't seem logical move
tlb_clear_slave around too much, so the simplest option seems to add a
check in tlb_clear_slave to make sure we haven't already wiped the
tx_hashtbl away before searching for all the non-existent hash-table
entries that used to point to the slave as the output interface.

Signed-off-by: Andy Gospodarek <andy@greyhouse.net>
---

 bond_alb.c |   13 ++++++++-----
 1 file changed, 8 insertions(+), 5 deletions(-)

diff --git a/drivers/net/bonding/bond_alb.c b/drivers/net/bonding/bond_alb.c
index ade5f3f..87437c7 100644
--- a/drivers/net/bonding/bond_alb.c
+++ b/drivers/net/bonding/bond_alb.c
@@ -169,11 +169,14 @@ static void tlb_clear_slave(struct bonding *bond, struct slave *slave, int save_
 	/* clear slave from tx_hashtbl */
 	tx_hash_table = BOND_ALB_INFO(bond).tx_hashtbl;
 
-	index = SLAVE_TLB_INFO(slave).head;
-	while (index != TLB_NULL_INDEX) {
-		u32 next_index = tx_hash_table[index].next;
-		tlb_init_table_entry(&tx_hash_table[index], save_load);
-		index = next_index;
+	/* skip this if we've already freed the tx hash table */
+	if (tx_hash_table) {
+		index = SLAVE_TLB_INFO(slave).head;
+		while (index != TLB_NULL_INDEX) {
+			u32 next_index = tx_hash_table[index].next;
+			tlb_init_table_entry(&tx_hash_table[index], save_load);
+			index = next_index;
+		}
 	}
 
 	tlb_init_slave(slave);
