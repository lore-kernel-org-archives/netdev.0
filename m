From: Mahesh Bandewar <mahesh@bandewar.net>
Subject: [PATCH next 4/5] bonding: correctly update link status during mii-commit phase
Date: Mon, 27 Mar 2017 11:37:37 -0700
Message-ID: <20170327183737.30989-1-mahesh@bandewar.net>
Cc: netdev <netdev@vger.kernel.org>,
        Mahesh Bandewar <mahesh@bandewar.net>,
        Mahesh Bandewar <maheshb@google.com>
To: Jay Vosburgh <j.vosburgh@gmail.com>,
        Andy Gospodarek <andy@greyhouse.net>,
        Veaceslav Falico <vfalico@gmail.com>,
        Nikolay Aleksandrov <nikolay@redhat.com>,
        David Miller <davem@davemloft.net>,
        Eric Dumazet <edumazet@google.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-pg0-f68.google.com ([74.125.83.68]:35442 "EHLO
        mail-pg0-f68.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1751364AbdC0Siw (ORCPT
        <rfc822;netdev@vger.kernel.org>); Mon, 27 Mar 2017 14:38:52 -0400
Received: by mail-pg0-f68.google.com with SMTP id g2so14967964pge.2
        for <netdev@vger.kernel.org>; Mon, 27 Mar 2017 11:38:32 -0700 (PDT)
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Mahesh Bandewar <maheshb@google.com>

bond_miimon_commit() marks the link UP after attempting to get the speed
and duplex settings for the link. There is a possibility that
bond_update_speed_duplex() could fail. This is another place where it
could result into an inconsistent bonding link state.

With this patch the link will be marked UP only if the speed and duplex
values retrieved have sane values and processed further.

Signed-off-by: Mahesh Bandewar <maheshb@google.com>
---
 drivers/net/bonding/bond_main.c | 7 ++++++-
 1 file changed, 6 insertions(+), 1 deletion(-)

diff --git a/drivers/net/bonding/bond_main.c b/drivers/net/bonding/bond_main.c
index ad317bb63193..6cea964ab70a 100644
--- a/drivers/net/bonding/bond_main.c
+++ b/drivers/net/bonding/bond_main.c
@@ -2125,7 +2125,12 @@ static void bond_miimon_commit(struct bonding *bond)
 			continue;
 
 		case BOND_LINK_UP:
-			bond_update_speed_duplex(slave);
+			if (bond_update_speed_duplex(slave)) {
+				netdev_warn(bond->dev,
+					    "failed to get link speed/duplex for %s\n",
+					    slave->dev->name);
+				continue;
+			}
 			bond_set_slave_link_state(slave, BOND_LINK_UP,
 						  BOND_SLAVE_NOTIFY_NOW);
 			slave->last_link_up = jiffies;
-- 
2.12.1.578.ge9c3154ca4-goog
