From: Nikolay Aleksandrov <nikolay@redhat.com>
Subject: [PATCH 5/5] bonding: in bond_mc_swap() bond's mc addr list is walked without lock
Date: Thu, 18 Apr 2013 16:34:57 +0200
Message-ID: <1366295697-31037-6-git-send-email-nikolay@redhat.com>
References: <1366295697-31037-1-git-send-email-nikolay@redhat.com>
Cc: andy@greyhouse.net, fubar@us.ibm.com, davem@davemloft.net
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mx1.redhat.com ([209.132.183.28]:8707 "EHLO mx1.redhat.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S965340Ab3DROir (ORCPT <rfc822;netdev@vger.kernel.org>);
	Thu, 18 Apr 2013 10:38:47 -0400
In-Reply-To: <1366295697-31037-1-git-send-email-nikolay@redhat.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Use netif_addr_lock_bh() to acquire the appropriate lock before walking.

Signed-off-by: Nikolay Aleksandrov <nikolay@redhat.com>
---
 drivers/net/bonding/bond_main.c | 4 ++++
 1 file changed, 4 insertions(+)

diff --git a/drivers/net/bonding/bond_main.c b/drivers/net/bonding/bond_main.c
index 62bfde7..d7239c9 100644
--- a/drivers/net/bonding/bond_main.c
+++ b/drivers/net/bonding/bond_main.c
@@ -846,8 +846,10 @@ static void bond_mc_swap(struct bonding *bond, struct slave *new_active,
 		if (bond->dev->flags & IFF_ALLMULTI)
 			dev_set_allmulti(old_active->dev, -1);
 
+		netif_addr_lock_bh(bond->dev);
 		netdev_for_each_mc_addr(ha, bond->dev)
 			dev_mc_del(old_active->dev, ha->addr);
+		netif_addr_unlock_bh(bond->dev);
 	}
 
 	if (new_active) {
@@ -858,8 +860,10 @@ static void bond_mc_swap(struct bonding *bond, struct slave *new_active,
 		if (bond->dev->flags & IFF_ALLMULTI)
 			dev_set_allmulti(new_active->dev, 1);
 
+		netif_addr_lock_bh(bond->dev);
 		netdev_for_each_mc_addr(ha, bond->dev)
 			dev_mc_add(new_active->dev, ha->addr);
+		netif_addr_unlock_bh(bond->dev);
 	}
 }
 
-- 
1.8.1.4
