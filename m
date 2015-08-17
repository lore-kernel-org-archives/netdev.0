From: Jarod Wilson <jarod@redhat.com>
Subject: [PATCH] net/bonding: send arp in interval if no active slave
Date: Mon, 17 Aug 2015 12:23:03 -0400
Message-ID: <1439828583-27325-1-git-send-email-jarod@redhat.com>
Cc: Uwe Koziolek <uwe.koziolek@redknee.com>,
	Jay Vosburgh <j.vosburgh@gmail.com>,
	Veaceslav Falico <vfalico@gmail.com>,
	Andy Gospodarek <gospo@cumulusnetworks.com>,
	netdev@vger.kernel.org, Jarod Wilson <jarod@redhat.com>
To: linux-kernel@vger.kernel.org
Return-path: <linux-kernel-owner@vger.kernel.org>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

From: Uwe Koziolek <uwe.koziolek@redknee.com>

With some very finicky switch hardware, active backup bonding can get into
a situation where we play ping-pong between interfaces, trying to get one
to come up as the active slave. There seems to be an issue with the
switch's arp replies either taking too long, or simply getting lost, so we
wind up unable to get any interface up and active. Sometimes, the issue
sorts itself out after a while, sometimes it doesn't.

Testing with num_grat_arp has proven fruitless, but sending an additional
arp on curr_arp_slave if we're still in the arp_interval timeslice in
bond_ab_arp_probe(), has shown to produce 100% reliability in testing with
this hardware combination.

[jarod: manufacturing of changelog]
CC: Jay Vosburgh <j.vosburgh@gmail.com>
CC: Veaceslav Falico <vfalico@gmail.com>
CC: Andy Gospodarek <gospo@cumulusnetworks.com>
CC: netdev@vger.kernel.org
Signed-off-by: Uwe Koziolek <uwe.koziolek@redknee.com>
Signed-off-by: Jarod Wilson <jarod@redhat.com>
---
 drivers/net/bonding/bond_main.c | 5 +++++
 1 file changed, 5 insertions(+)

diff --git a/drivers/net/bonding/bond_main.c b/drivers/net/bonding/bond_main.c
index 0c627b4..60b9483 100644
--- a/drivers/net/bonding/bond_main.c
+++ b/drivers/net/bonding/bond_main.c
@@ -2794,6 +2794,11 @@ static bool bond_ab_arp_probe(struct bonding *bond)
 			return should_notify_rtnl;
 	}
 
+	if (bond_time_in_interval(bond, curr_arp_slave->last_link_up, 2)) {
+		bond_arp_send_all(bond, curr_arp_slave);
+		return should_notify_rtnl;
+	}
+
 	bond_set_slave_inactive_flags(curr_arp_slave, BOND_SLAVE_NOTIFY_LATER);
 
 	bond_for_each_slave_rcu(bond, slave, iter) {
-- 
1.8.3.1
