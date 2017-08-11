From: Andreas Born <futur.andy@googlemail.com>
Subject: [PATCH] bonding: ratelimit failed speed/duplex update warning
Date: Fri, 11 Aug 2017 12:04:13 +0200
Message-ID: <20170811100413.16234-1-futur.andy@googlemail.com>
Cc: Andreas Born <futur.andy@googlemail.com>
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-wm0-f66.google.com ([74.125.82.66]:35250 "EHLO
        mail-wm0-f66.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1751545AbdHKKEo (ORCPT
        <rfc822;netdev@vger.kernel.org>); Fri, 11 Aug 2017 06:04:44 -0400
Received: by mail-wm0-f66.google.com with SMTP id r77so5921835wmd.2
        for <netdev@vger.kernel.org>; Fri, 11 Aug 2017 03:04:44 -0700 (PDT)
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

bond_miimon_commit() handles the UP transition for each slave of a bond
in the case of MII. It is triggered 10 times per second for the default
MII Polling interval of 100ms. For device drivers that do not implement
__ethtool_get_link_ksettings() the call to bond_update_speed_duplex()
fails persistently while the MII status could remain UP. That is, in this and
other cases where the speed/duplex update keeps failing over a longer
period of time while the MII state is UP, a warning is printed every MII
polling interval.

To address these excessive warnings pr_warn_ratelimited() should be used
instead. pr_warn_once() would not be sufficient since the call to
bond_update_speed_duplex() could recover to meanwhile succeed and fail
again later.

Fixes: b5bf0f5b16b9c (bonding: correctly update link status during mii-commit phase)
Signed-off-by: Andreas Born <futur.andy@googlemail.com>
---
 drivers/net/bonding/bond_main.c | 6 +++---
 1 file changed, 3 insertions(+), 3 deletions(-)

diff --git a/drivers/net/bonding/bond_main.c b/drivers/net/bonding/bond_main.c
index 85bb272d2a34..7b8bbee531d7 100644
--- a/drivers/net/bonding/bond_main.c
+++ b/drivers/net/bonding/bond_main.c
@@ -2144,9 +2144,9 @@ static void bond_miimon_commit(struct bonding *bond)
 			if (bond_update_speed_duplex(slave) &&
 			    bond_needs_speed_duplex(bond)) {
 				slave->link = BOND_LINK_DOWN;
-				netdev_warn(bond->dev,
-					    "failed to get link speed/duplex for %s\n",
-					    slave->dev->name);
+				pr_warn_ratelimited("%s: failed to get link speed/duplex for %s\n",
+						    bond->dev->name,
+						    slave->dev->name);
 				continue;
 			}
 			bond_set_slave_link_state(slave, BOND_LINK_UP,
-- 
2.14.0
