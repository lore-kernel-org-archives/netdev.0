From: Veaceslav Falico <vfalico@redhat.com>
Subject: [PATCH net-next v4 11/13] bonding: make alb_send_learning_packets() use upper dev list
Date: Wed, 28 Aug 2013 23:25:14 +0200
Message-ID: <1377725116-31126-12-git-send-email-vfalico@redhat.com>
References: <1377725116-31126-1-git-send-email-vfalico@redhat.com>
Cc: Veaceslav Falico <vfalico@redhat.com>,
	Jay Vosburgh <fubar@us.ibm.com>,
	Andy Gospodarek <andy@greyhouse.net>
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mx1.redhat.com ([209.132.183.28]:45317 "EHLO mx1.redhat.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1755815Ab3H1VZP (ORCPT <rfc822;netdev@vger.kernel.org>);
	Wed, 28 Aug 2013 17:25:15 -0400
In-Reply-To: <1377725116-31126-1-git-send-email-vfalico@redhat.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Currently, if there are vlans on top of bond, alb_send_learning_packets()
will never send LPs from the bond itself (i.e. untagged), which might leave
untagged clients unupdated.

Also, the 'circular vlan' logic (i.e. update only MAX_LP_BURST vlans at a
time, and save the last vlan for the next update) is really suboptimal - in
case of lots of vlans it will take a lot of time to update every vlan. It
is also never called in any hot path and sends only a few small packets -
thus the optimization by itself is useless.

So remove the whole current_alb_vlan/MAX_LP_BURST logic from
alb_send_learning_packets(). Instead, we'll first send a packet untagged
and then traverse the upper dev list, sending a tagged packet for each vlan
found. Also, remove the MAX_LP_BURST define - we already don't need it.

CC: Jay Vosburgh <fubar@us.ibm.com>
CC: Andy Gospodarek <andy@greyhouse.net>
Signed-off-by: Veaceslav Falico <vfalico@redhat.com>
---

Notes:
    v1: use netdev_for_each_upper_dev()
    v2: use netdev_for_each_upper_dev_rcu()
    v3: no change
    v4: no change

 drivers/net/bonding/bond_alb.c | 29 +++++++++++------------------
 drivers/net/bonding/bond_alb.h |  1 -
 2 files changed, 11 insertions(+), 19 deletions(-)

diff --git a/drivers/net/bonding/bond_alb.c b/drivers/net/bonding/bond_alb.c
index 3ca3c85..b6a68b4 100644
--- a/drivers/net/bonding/bond_alb.c
+++ b/drivers/net/bonding/bond_alb.c
@@ -1013,27 +1013,20 @@ static void alb_send_lp_vid(struct slave *slave, u8 mac_addr[],
 static void alb_send_learning_packets(struct slave *slave, u8 mac_addr[])
 {
 	struct bonding *bond = bond_get_bond_by_slave(slave);
-	u16 vlan_id;
-	int i;
-
-	for (i = 0; i < MAX_LP_BURST; i++) {
-		vlan_id = 0;
-
-		if (bond_vlan_used(bond)) {
-			struct vlan_entry *vlan;
+	struct net_device *upper;
+	struct list_head *iter;
 
-			vlan = bond_next_vlan(bond,
-					      bond->alb_info.current_alb_vlan);
-
-			bond->alb_info.current_alb_vlan = vlan;
-			if (!vlan)
-				continue;
-
-			vlan_id = vlan->vlan_id;
-		}
+	/* send untagged */
+	alb_send_lp_vid(slave, mac_addr, 0);
 
-		alb_send_lp_vid(slave, mac_addr, vlan_id);
+	/* loop through vlans and send one packet for each */
+	rcu_read_lock();
+	netdev_for_each_upper_dev_rcu(bond->dev, upper, iter) {
+		if (upper->priv_flags & IFF_802_1Q_VLAN)
+			alb_send_lp_vid(slave, mac_addr,
+					vlan_dev_vlan_id(upper));
 	}
+	rcu_read_unlock();
 }
 
 static int alb_set_slave_mac_addr(struct slave *slave, u8 addr[])
diff --git a/drivers/net/bonding/bond_alb.h b/drivers/net/bonding/bond_alb.h
index e7a5b8b..e139172 100644
--- a/drivers/net/bonding/bond_alb.h
+++ b/drivers/net/bonding/bond_alb.h
@@ -53,7 +53,6 @@ struct slave;
 
 
 #define TLB_NULL_INDEX		0xffffffff
-#define MAX_LP_BURST		3
 
 /* rlb defs */
 #define RLB_HASH_TABLE_SIZE	256
-- 
1.8.4
