From: Andreas Born <futur.andy@googlemail.com>
Subject: [PATCH] bonding: require speed/duplex only for 802.3ad, alb and tlb
Date: Thu, 10 Aug 2017 06:41:44 +0200
Message-ID: <20170810044144.17398-1-futur.andy@googlemail.com>
Cc: Mahesh Bandewar <maheshb@google.com>,
        Andreas Born <futur.andy@googlemail.com>
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-wm0-f65.google.com ([74.125.82.65]:37160 "EHLO
        mail-wm0-f65.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1750837AbdHJEmZ (ORCPT
        <rfc822;netdev@vger.kernel.org>); Thu, 10 Aug 2017 00:42:25 -0400
Received: by mail-wm0-f65.google.com with SMTP id t138so1595617wmt.4
        for <netdev@vger.kernel.org>; Wed, 09 Aug 2017 21:42:25 -0700 (PDT)
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

The patch c4adfc822bf5 ("bonding: make speed, duplex setting consistent
with link state") puts the link state to down if
bond_update_speed_duplex() cannot retrieve speed and duplex settings.
Assumably the patch was written with 802.3ad mode in mind which relies
on link speed/duplex settings. For other modes like active-backup these
settings are not required. Thus, only for these other modes, this patch
reintroduces support for slaves that do not support reporting speed or
duplex such as wireless devices. This fixes the regression reported in
bug 196547 (https://bugzilla.kernel.org/show_bug.cgi?id=196547).

Fixes: c4adfc822bf5 ("bonding: make speed, duplex setting consistent
with link state")
Signed-off-by: Andreas Born <futur.andy@googlemail.com>
---
 drivers/net/bonding/bond_main.c | 6 ++++--
 include/net/bonding.h           | 5 +++++
 2 files changed, 9 insertions(+), 2 deletions(-)

diff --git a/drivers/net/bonding/bond_main.c b/drivers/net/bonding/bond_main.c
index 9bee6c1c70cc..85bb272d2a34 100644
--- a/drivers/net/bonding/bond_main.c
+++ b/drivers/net/bonding/bond_main.c
@@ -1569,7 +1569,8 @@ int bond_enslave(struct net_device *bond_dev, struct net_device *slave_dev)
 	new_slave->delay = 0;
 	new_slave->link_failure_count = 0;
 
-	if (bond_update_speed_duplex(new_slave))
+	if (bond_update_speed_duplex(new_slave) &&
+	    bond_needs_speed_duplex(bond))
 		new_slave->link = BOND_LINK_DOWN;
 
 	new_slave->last_rx = jiffies -
@@ -2140,7 +2141,8 @@ static void bond_miimon_commit(struct bonding *bond)
 			continue;
 
 		case BOND_LINK_UP:
-			if (bond_update_speed_duplex(slave)) {
+			if (bond_update_speed_duplex(slave) &&
+			    bond_needs_speed_duplex(bond)) {
 				slave->link = BOND_LINK_DOWN;
 				netdev_warn(bond->dev,
 					    "failed to get link speed/duplex for %s\n",
diff --git a/include/net/bonding.h b/include/net/bonding.h
index b00508d22e0a..b2e68657a216 100644
--- a/include/net/bonding.h
+++ b/include/net/bonding.h
@@ -277,6 +277,11 @@ static inline bool bond_is_lb(const struct bonding *bond)
 	       BOND_MODE(bond) == BOND_MODE_ALB;
 }
 
+static inline bool bond_needs_speed_duplex(const struct bonding *bond)
+{
+	return BOND_MODE(bond) == BOND_MODE_8023AD || bond_is_lb(bond);
+}
+
 static inline bool bond_is_nondyn_tlb(const struct bonding *bond)
 {
 	return (BOND_MODE(bond) == BOND_MODE_TLB)  &&
-- 
2.14.0
