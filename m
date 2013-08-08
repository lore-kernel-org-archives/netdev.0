From: Veaceslav Falico <vfalico@redhat.com>
Subject: [PATCH v2 net-next 4/6] bonding: convert bond_has_this_ip to use bond->dev->vlan_info
Date: Thu,  8 Aug 2013 18:57:57 +0200
Message-ID: <1375981079-2936-5-git-send-email-vfalico@redhat.com>
References: <1375981079-2936-1-git-send-email-vfalico@redhat.com>
Cc: Veaceslav Falico <vfalico@redhat.com>,
	Jay Vosburgh <fubar@us.ibm.com>,
	Andy Gospodarek <andy@greyhouse.net>
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mx1.redhat.com ([209.132.183.28]:49331 "EHLO mx1.redhat.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1758052Ab3HHQ5v (ORCPT <rfc822;netdev@vger.kernel.org>);
	Thu, 8 Aug 2013 12:57:51 -0400
In-Reply-To: <1375981079-2936-1-git-send-email-vfalico@redhat.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

RFC -> v1: use the new __vlan_find_dev_next(), which simplifies the code
	   and omits issues with vlan id 0.
v1  -> v2: fix the use of uninitialized vlan_dev

Use __vlan_find_dev_next() to loop through dev's vlan devices and verify if
the ip matches.

CC: Jay Vosburgh <fubar@us.ibm.com>
CC: Andy Gospodarek <andy@greyhouse.net>
Signed-off-by: Veaceslav Falico <vfalico@redhat.com>
---
 drivers/net/bonding/bond_main.c |   16 +++++++---------
 1 files changed, 7 insertions(+), 9 deletions(-)

diff --git a/drivers/net/bonding/bond_main.c b/drivers/net/bonding/bond_main.c
index 9d1045d..e52e2d5 100644
--- a/drivers/net/bonding/bond_main.c
+++ b/drivers/net/bonding/bond_main.c
@@ -2392,20 +2392,18 @@ re_arm:
 
 static int bond_has_this_ip(struct bonding *bond, __be32 ip)
 {
-	struct vlan_entry *vlan;
-	struct net_device *vlan_dev;
+	struct net_device *vlan_dev = NULL;
 
 	if (ip == bond_confirm_addr(bond->dev, 0, ip))
 		return 1;
 
-	list_for_each_entry(vlan, &bond->vlan_list, vlan_list) {
-		rcu_read_lock();
-		vlan_dev = __vlan_find_dev_deep(bond->dev, htons(ETH_P_8021Q),
-						vlan->vlan_id);
-		rcu_read_unlock();
-		if (vlan_dev && ip == bond_confirm_addr(vlan_dev, 0, ip))
+	rcu_read_lock();
+	while ((vlan_dev = __vlan_find_dev_next(bond->dev, vlan_dev)))
+		if (ip == bond_confirm_addr(vlan_dev, 0, ip)) {
+			rcu_read_unlock();
 			return 1;
-	}
+		}
+	rcu_read_unlock();
 
 	return 0;
 }
-- 
1.7.1
