From: Andreas Born <futur.andy@googlemail.com>
Subject: [PATCH v2] bonding: ratelimit failed speed/duplex update warning
Date: Sat, 12 Aug 2017 00:36:55 +0200
Message-ID: <20170811223655.11446-1-futur.andy@googlemail.com>
Cc: Joe Perches <joe@perches.com>, David Miller <davem@davemloft.net>,
        Andreas Born <futur.andy@googlemail.com>
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-wr0-f195.google.com ([209.85.128.195]:36906 "EHLO
        mail-wr0-f195.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1753659AbdHKWhP (ORCPT
        <rfc822;netdev@vger.kernel.org>); Fri, 11 Aug 2017 18:37:15 -0400
Received: by mail-wr0-f195.google.com with SMTP id f38so3359174wrf.4
        for <netdev@vger.kernel.org>; Fri, 11 Aug 2017 15:37:15 -0700 (PDT)
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

bond_miimon_commit() handles the UP transition for each slave of a bond
in the case of MII. It is triggered 10 times per second for the default
MII Polling interval of 100ms. For device drivers that do not implement
__ethtool_get_link_ksettings() the call to bond_update_speed_duplex()
fails persistently while the MII status could remain UP. That is, in
this and other cases where the speed/duplex update keeps failing over a
longer period of time while the MII state is UP, a warning is printed
every MII polling interval.

To address these excessive warnings net_ratelimit() should be used.
Printing a warning once would not be sufficient since the call to
bond_update_speed_duplex() could recover to succeed and fail again
later. In that case there would be no new indication what went wrong.

Fixes: b5bf0f5b16b9c (bonding: correctly update link status during mii-commit phase)
Signed-off-by: Andreas Born <futur.andy@googlemail.com>
---
Changes in v2:
* swapped pr_warn_ratelimited() for net_ratelimit()

 drivers/net/bonding/bond_main.c | 7 ++++---
 1 file changed, 4 insertions(+), 3 deletions(-)

diff --git a/drivers/net/bonding/bond_main.c b/drivers/net/bonding/bond_main.c
index 85bb272d2a34..fc63992ab0e0 100644
--- a/drivers/net/bonding/bond_main.c
+++ b/drivers/net/bonding/bond_main.c
@@ -2144,9 +2144,10 @@ static void bond_miimon_commit(struct bonding *bond)
 			if (bond_update_speed_duplex(slave) &&
 			    bond_needs_speed_duplex(bond)) {
 				slave->link = BOND_LINK_DOWN;
-				netdev_warn(bond->dev,
-					    "failed to get link speed/duplex for %s\n",
-					    slave->dev->name);
+				if (net_ratelimit())
+					netdev_warn(bond->dev,
+						    "failed to get link speed/duplex for %s\n",
+						    slave->dev->name);
 				continue;
 			}
 			bond_set_slave_link_state(slave, BOND_LINK_UP,
-- 
2.14.0
