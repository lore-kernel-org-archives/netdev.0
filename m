From: Veaceslav Falico <vfalico@redhat.com>
Subject: [RFC PATCH net-next 5/6] bonding: convert bond_arp_send_all to use bond->dev->vlan_info
Date: Tue,  6 Aug 2013 19:59:03 +0200
Message-ID: <1375811944-31942-6-git-send-email-vfalico@redhat.com>
References: <1375811944-31942-1-git-send-email-vfalico@redhat.com>
Cc: Veaceslav Falico <vfalico@redhat.com>,
	Jay Vosburgh <fubar@us.ibm.com>,
	Andy Gospodarek <andy@greyhouse.net>
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mx1.redhat.com ([209.132.183.28]:31885 "EHLO mx1.redhat.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1756431Ab3HFR6q (ORCPT <rfc822;netdev@vger.kernel.org>);
	Tue, 6 Aug 2013 13:58:46 -0400
In-Reply-To: <1375811944-31942-1-git-send-email-vfalico@redhat.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Instead of looping through bond->vlan_list, loop through
bond->dev->vlan_info via __vlan_find_dev_next_id() and dereference the
vlan_dev through __vlan_find_dev_deep(), all under rcu_read_lock().

CC: Jay Vosburgh <fubar@us.ibm.com>
CC: Andy Gospodarek <andy@greyhouse.net>
Signed-off-by: Veaceslav Falico <vfalico@redhat.com>
---
 drivers/net/bonding/bond_main.c |   10 ++++------
 1 files changed, 4 insertions(+), 6 deletions(-)

diff --git a/drivers/net/bonding/bond_main.c b/drivers/net/bonding/bond_main.c
index 00f6011..b85c96f 100644
--- a/drivers/net/bonding/bond_main.c
+++ b/drivers/net/bonding/bond_main.c
@@ -2447,7 +2447,6 @@ static void bond_arp_send_all(struct bonding *bond, struct slave *slave)
 {
 	int i, vlan_id;
 	__be32 *targets = bond->params.arp_targets;
-	struct vlan_entry *vlan;
 	struct net_device *vlan_dev = NULL;
 	struct rtable *rt;
 
@@ -2492,19 +2491,18 @@ static void bond_arp_send_all(struct bonding *bond, struct slave *slave)
 		}
 
 		vlan_id = 0;
-		list_for_each_entry(vlan, &bond->vlan_list, vlan_list) {
-			rcu_read_lock();
+		rcu_read_lock();
+		while ((vlan_id = __vlan_find_dev_next_id(bond->dev, vlan_id+1))) {
 			vlan_dev = __vlan_find_dev_deep(bond->dev,
 							htons(ETH_P_8021Q),
-							vlan->vlan_id);
-			rcu_read_unlock();
+							vlan_id);
 			if (vlan_dev == rt->dst.dev) {
-				vlan_id = vlan->vlan_id;
 				pr_debug("basa: vlan match on %s %d\n",
 				       vlan_dev->name, vlan_id);
 				break;
 			}
 		}
+		rcu_read_unlock();
 
 		if (vlan_id && vlan_dev) {
 			ip_rt_put(rt);
-- 
1.7.1
