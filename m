From: Nikolay Aleksandrov <nikolay@redhat.com>
Subject: [PATCH net] bonding: fix curr_active_slave/carrier with loadbalance arp monitoring
Date: Tue, 18 Nov 2014 15:14:44 +0100
Message-ID: <1416320084-25339-1-git-send-email-nikolay@redhat.com>
Cc: davem@davemloft.net, Nikolay Aleksandrov <nikolay@redhat.com>,
	Veaceslav Falico <vfalico@gmail.com>,
	Jay Vosburgh <j.vosburgh@gmail.com>,
	Andy Gospodarek <andy@greyhouse.net>,
	Ding Tianhong <dingtianhong@huawei.com>
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mx1.redhat.com ([209.132.183.28]:55281 "EHLO mx1.redhat.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1754806AbaKROPE (ORCPT <rfc822;netdev@vger.kernel.org>);
	Tue, 18 Nov 2014 09:15:04 -0500
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Since commit 6fde8f037e60 ("bonding: fix locking in
bond_loadbalance_arp_mon()") we can have a stale bond carrier state and
stale curr_active_slave when using arp monitoring in loadbalance modes. The
reason is that in bond_loadbalance_arp_mon() we can't have
do_failover == true but slave_state_changed == false, whenever do_failover
is true then slave_state_changed is also true. Then the following piece
from bond_loadbalance_arp_mon():
                if (slave_state_changed) {
                        bond_slave_state_change(bond);
                        if (BOND_MODE(bond) == BOND_MODE_XOR)
                                bond_update_slave_arr(bond, NULL);
                } else if (do_failover) {
                        block_netpoll_tx();
                        bond_select_active_slave(bond);
                        unblock_netpoll_tx();
                }

will execute only the first branch, always and regardless of do_failover.
Since these two events aren't related in such way, we need to decouple and
consider them separately.

For example this issue could lead to the following result:
Bonding Mode: load balancing (round-robin)
*MII Status: down*
MII Polling Interval (ms): 0
Up Delay (ms): 0
Down Delay (ms): 0
ARP Polling Interval (ms): 100
ARP IP target/s (n.n.n.n form): 192.168.9.2

Slave Interface: ens12
*MII Status: up*
Speed: 10000 Mbps
Duplex: full
Link Failure Count: 2
Permanent HW addr: 00:0f:53:01:42:2c
Slave queue ID: 0

Slave Interface: eth1
*MII Status: up*
Speed: Unknown
Duplex: Unknown
Link Failure Count: 70
Permanent HW addr: 52:54:00:2f:0f:8e
Slave queue ID: 0

Since some interfaces are up, then the status of the bond should also be
up, but it will never change unless something invokes bond_set_carrier()
(i.e. enslave, bond_select_active_slave etc). Now, if I force the
calling of bond_select_active_slave via for example changing
primary_reselect (it can change in any mode), then the MII status goes to
"up" because it calls bond_select_active_slave() which should've been done
from bond_loadbalance_arp_mon() itself.

CC: Veaceslav Falico <vfalico@gmail.com>
CC: Jay Vosburgh <j.vosburgh@gmail.com>
CC: Andy Gospodarek <andy@greyhouse.net>
CC: Ding Tianhong <dingtianhong@huawei.com>

Fixes: 6fde8f037e60 ("bonding: fix locking in bond_loadbalance_arp_mon()")
Signed-off-by: Nikolay Aleksandrov <nikolay@redhat.com>
---
Note: I left the parent if() the same even though we can shorten it. I think
      it's better this way since it shows that any of the two events can cause
      it to enter even though currently we can't have do_failover without
      slave_state_changed, that may also change in the future.

 drivers/net/bonding/bond_main.c | 3 ++-
 1 file changed, 2 insertions(+), 1 deletion(-)

diff --git a/drivers/net/bonding/bond_main.c b/drivers/net/bonding/bond_main.c
index c9ac06cfe6b7..a5115fb7cf33 100644
--- a/drivers/net/bonding/bond_main.c
+++ b/drivers/net/bonding/bond_main.c
@@ -2471,7 +2471,8 @@ static void bond_loadbalance_arp_mon(struct work_struct *work)
 			bond_slave_state_change(bond);
 			if (BOND_MODE(bond) == BOND_MODE_XOR)
 				bond_update_slave_arr(bond, NULL);
-		} else if (do_failover) {
+		}
+		if (do_failover) {
 			block_netpoll_tx();
 			bond_select_active_slave(bond);
 			unblock_netpoll_tx();
-- 
1.9.3
