From: Mahesh Bandewar <mahesh@bandewar.net>
Subject: [PATCH next 3/5] bonding: make speed, duplex setting consistent with link state
Date: Mon, 27 Mar 2017 11:37:35 -0700
Message-ID: <20170327183735.30921-1-mahesh@bandewar.net>
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
Received: from mail-pg0-f68.google.com ([74.125.83.68]:33974 "EHLO
        mail-pg0-f68.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1751287AbdC0SiC (ORCPT
        <rfc822;netdev@vger.kernel.org>); Mon, 27 Mar 2017 14:38:02 -0400
Received: by mail-pg0-f68.google.com with SMTP id o123so12251325pga.1
        for <netdev@vger.kernel.org>; Mon, 27 Mar 2017 11:37:57 -0700 (PDT)
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Mahesh Bandewar <maheshb@google.com>

bond_update_speed_duplex() retrieves speed and duplex settings. There
is a possibility of failure in retrieving these values but caller has
to assume it's always successful. This leads to having inconsistent
slave link settings. If these (speed, duplex) values cannot be
retrieved, then keeping the link UP causes problems.

The updated bond_update_speed_duplex() returns 0 on success if it
retrieves sane values for speed and duplex. On failure it returns 1
and marks the link down.

Signed-off-by: Mahesh Bandewar <maheshb@google.com>
---
 drivers/net/bonding/bond_main.c | 24 ++++++++++++++----------
 1 file changed, 14 insertions(+), 10 deletions(-)

diff --git a/drivers/net/bonding/bond_main.c b/drivers/net/bonding/bond_main.c
index 85999e479916..ad317bb63193 100644
--- a/drivers/net/bonding/bond_main.c
+++ b/drivers/net/bonding/bond_main.c
@@ -365,9 +365,10 @@ int bond_set_carrier(struct bonding *bond)
 /* Get link speed and duplex from the slave's base driver
  * using ethtool. If for some reason the call fails or the
  * values are invalid, set speed and duplex to -1,
- * and return.
+ * and return. Return 1 if speed or duplex settings are
+ * UNKNOWN; 0 otherwise.
  */
-static void bond_update_speed_duplex(struct slave *slave)
+static int bond_update_speed_duplex(struct slave *slave)
 {
 	struct net_device *slave_dev = slave->dev;
 	struct ethtool_link_ksettings ecmd;
@@ -377,24 +378,27 @@ static void bond_update_speed_duplex(struct slave *slave)
 	slave->duplex = DUPLEX_UNKNOWN;
 
 	res = __ethtool_get_link_ksettings(slave_dev, &ecmd);
-	if (res < 0)
-		return;
-
-	if (ecmd.base.speed == 0 || ecmd.base.speed == ((__u32)-1))
-		return;
-
+	if (res < 0) {
+		slave->link = BOND_LINK_DOWN;
+		return 1;
+	}
+	if (ecmd.base.speed == 0 || ecmd.base.speed == ((__u32)-1)) {
+		slave->link = BOND_LINK_DOWN;
+		return 1;
+	}
 	switch (ecmd.base.duplex) {
 	case DUPLEX_FULL:
 	case DUPLEX_HALF:
 		break;
 	default:
-		return;
+		slave->link = BOND_LINK_DOWN;
+		return 1;
 	}
 
 	slave->speed = ecmd.base.speed;
 	slave->duplex = ecmd.base.duplex;
 
-	return;
+	return 0;
 }
 
 const char *bond_slave_link_status(s8 link)
-- 
2.12.1.578.ge9c3154ca4-goog
