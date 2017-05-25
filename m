From: Nithin Nayak Sujir <nsujir@tintri.com>
Subject: [PATCH] bonding: Don't update slave->link until ready to commit
Date: Wed, 24 May 2017 19:45:17 -0700
Message-ID: <1495680317-11308-1-git-send-email-nsujir@tintri.com>
Mime-Version: 1.0
Content-Type: text/plain
Cc: netdev@vger.kernel.org, Nithin Nayak Sujir <nsujir@tintri.com>,
        Mahesh Bandewar <maheshb@google.com>,
        Jay Vosburgh <jay.vosburgh@canonical.com>
To: davem@davemloft.net
Return-path: <netdev-owner@vger.kernel.org>
Received: from mx0b-0023b501.pphosted.com ([148.163.159.175]:47721 "EHLO
        mx0a-0023b501.pphosted.com" rhost-flags-OK-OK-OK-FAIL)
        by vger.kernel.org with ESMTP id S932535AbdEYCpw (ORCPT
        <rfc822;netdev@vger.kernel.org>); Wed, 24 May 2017 22:45:52 -0400
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

In the loadbalance arp monitoring scheme, when a slave link change is
detected, the slave->link is immediately updated and slave_state_changed
is set. Later down the function, the rtnl_lock is acquired and the
changes are committed, updating the bond link state.

However, the acquisition of the rtnl_lock can fail. The next time the
monitor runs, since slave->link is already updated, it determines that
link is unchanged. This results in the bond link state permanently out
of sync with the slave link.

This patch modifies bond_loadbalance_arp_mon() to handle link changes
identical to bond_ab_arp_{inspect/commit}(). The new link state is
maintained in slave->new_link until we're ready to commit at which point
it's copied into slave->link.

NOTE: miimon_{inspect/commit}() has a more complex state machine
requiring the use of the bond_{propose,commit}_link_state() functions
which maintains the intermediate state in slave->link_new_state. The arp
monitors don't require that.

Testing: This bug is very easy to reproduce with the following steps.
1. In a loop, toggle a slave link of a bond slave interface.
2. In a separate loop, do ifconfig up/down of an unrelated interface to
create contention for rtnl_lock.
Within a few iterations, the bond link goes out of sync with the slave
link.

Signed-off-by: Nithin Nayak Sujir <nsujir@tintri.com>
Cc: Mahesh Bandewar <maheshb@google.com>
Cc: Jay Vosburgh <jay.vosburgh@canonical.com>
---
 drivers/net/bonding/bond_main.c | 11 +++++++++--
 1 file changed, 9 insertions(+), 2 deletions(-)

diff --git a/drivers/net/bonding/bond_main.c b/drivers/net/bonding/bond_main.c
index 7331331..2359478b 100644
--- a/drivers/net/bonding/bond_main.c
+++ b/drivers/net/bonding/bond_main.c
@@ -2612,11 +2612,13 @@ static void bond_loadbalance_arp_mon(struct bonding *bond)
 	bond_for_each_slave_rcu(bond, slave, iter) {
 		unsigned long trans_start = dev_trans_start(slave->dev);
 
+		slave->new_link = BOND_LINK_NOCHANGE;
+
 		if (slave->link != BOND_LINK_UP) {
 			if (bond_time_in_interval(bond, trans_start, 1) &&
 			    bond_time_in_interval(bond, slave->last_rx, 1)) {
 
-				slave->link  = BOND_LINK_UP;
+				slave->new_link = BOND_LINK_UP;
 				slave_state_changed = 1;
 
 				/* primary_slave has no meaning in round-robin
@@ -2643,7 +2645,7 @@ static void bond_loadbalance_arp_mon(struct bonding *bond)
 			if (!bond_time_in_interval(bond, trans_start, 2) ||
 			    !bond_time_in_interval(bond, slave->last_rx, 2)) {
 
-				slave->link  = BOND_LINK_DOWN;
+				slave->new_link = BOND_LINK_DOWN;
 				slave_state_changed = 1;
 
 				if (slave->link_failure_count < UINT_MAX)
@@ -2674,6 +2676,11 @@ static void bond_loadbalance_arp_mon(struct bonding *bond)
 		if (!rtnl_trylock())
 			goto re_arm;
 
+		bond_for_each_slave(bond, slave, iter) {
+			if (slave->new_link != BOND_LINK_NOCHANGE)
+				slave->link = slave->new_link;
+		}
+
 		if (slave_state_changed) {
 			bond_slave_state_change(bond);
 			if (BOND_MODE(bond) == BOND_MODE_XOR)
-- 
2.8.2
