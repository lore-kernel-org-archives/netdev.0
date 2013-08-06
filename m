From: Veaceslav Falico <vfalico@redhat.com>
Subject: [RFC PATCH net-next 4/6] bonding: convert bond_has_this_ip to use bond->dev->vlan_info
Date: Tue,  6 Aug 2013 19:59:02 +0200
Message-ID: <1375811944-31942-5-git-send-email-vfalico@redhat.com>
References: <1375811944-31942-1-git-send-email-vfalico@redhat.com>
Cc: Veaceslav Falico <vfalico@redhat.com>,
	Jay Vosburgh <fubar@us.ibm.com>,
	Andy Gospodarek <andy@greyhouse.net>
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mx1.redhat.com ([209.132.183.28]:44360 "EHLO mx1.redhat.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1756325Ab3HFR6p (ORCPT <rfc822;netdev@vger.kernel.org>);
	Tue, 6 Aug 2013 13:58:45 -0400
In-Reply-To: <1375811944-31942-1-git-send-email-vfalico@redhat.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Use __vlan_find_dev_next_id() to loop through __vlan_find_dev_next_id() and
__vlan_find_dev_deep() to dereference the actual vlan device and verify if
it has the ip requested.

CC: Jay Vosburgh <fubar@us.ibm.com>
CC: Andy Gospodarek <andy@greyhouse.net>
Signed-off-by: Veaceslav Falico <vfalico@redhat.com>
---
 drivers/net/bonding/bond_main.c |   15 +++++++++------
 1 files changed, 9 insertions(+), 6 deletions(-)

diff --git a/drivers/net/bonding/bond_main.c b/drivers/net/bonding/bond_main.c
index 9d1045d..00f6011 100644
--- a/drivers/net/bonding/bond_main.c
+++ b/drivers/net/bonding/bond_main.c
@@ -2392,20 +2392,23 @@ re_arm:
 
 static int bond_has_this_ip(struct bonding *bond, __be32 ip)
 {
-	struct vlan_entry *vlan;
 	struct net_device *vlan_dev;
+	u16 vlan_id = 0;
 
 	if (ip == bond_confirm_addr(bond->dev, 0, ip))
 		return 1;
 
-	list_for_each_entry(vlan, &bond->vlan_list, vlan_list) {
-		rcu_read_lock();
+	rcu_read_lock();
+	while ((vlan_id = __vlan_find_dev_next_id(bond->dev, vlan_id+1))) {
 		vlan_dev = __vlan_find_dev_deep(bond->dev, htons(ETH_P_8021Q),
-						vlan->vlan_id);
-		rcu_read_unlock();
-		if (vlan_dev && ip == bond_confirm_addr(vlan_dev, 0, ip))
+						vlan_id);
+
+		if (vlan_dev && ip == bond_confirm_addr(vlan_dev, 0, ip)) {
+			rcu_read_unlock();
 			return 1;
+		}
 	}
+	rcu_read_unlock();
 
 	return 0;
 }
-- 
1.7.1
