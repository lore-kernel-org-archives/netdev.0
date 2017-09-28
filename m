From: Mahesh Bandewar <mahesh@bandewar.net>
Subject: [PATCH next] bonding: speed/duplex update at NETDEV_UP event
Date: Wed, 27 Sep 2017 18:03:49 -0700
Message-ID: <20170928010349.8988-1-mahesh@bandewar.net>
Cc: Mahesh Bandewar <mahesh@bandewar.net>,
        Netdev <netdev@vger.kernel.org>,
        Mahesh Bandewar <maheshb@google.com>
To: Jay Vosburgh <j.vosburgh@gmail.com>,
        Andy Gospodarek <andy@greyhouse.net>,
        Veaceslav Falico <vfalico@gmail.com>,
        David Miller <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-pf0-f193.google.com ([209.85.192.193]:35081 "EHLO
        mail-pf0-f193.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1752520AbdI1BDz (ORCPT
        <rfc822;netdev@vger.kernel.org>); Wed, 27 Sep 2017 21:03:55 -0400
Received: by mail-pf0-f193.google.com with SMTP id i23so18433pfi.2
        for <netdev@vger.kernel.org>; Wed, 27 Sep 2017 18:03:55 -0700 (PDT)
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Mahesh Bandewar <maheshb@google.com>

Some NIC drivers don't have correct speed/duplex settings at the
time they send NETDEV_UP notification and that messes up the
bonding state. Especially 802.3ad mode which is very sensitive
to these settings. In the current implementation we invoke
bond_update_speed_duplex() when we receive NETDEV_UP, however,
ignore the return value. If the values we get are invalid
(UNKNOWN), then slave gets removed from the aggregator with
speed and duplex set to UNKNOWN while link is still marked as UP.

This patch fixes this scenario. Also 802.3ad mode is sensitive to
these conditions while other modes are not, so making sure that it
doesn't change the behavior for other modes.

Signed-off-by: Mahesh Bandewar <maheshb@google.com>
---
 drivers/net/bonding/bond_main.c | 11 ++++++++++-
 1 file changed, 10 insertions(+), 1 deletion(-)

diff --git a/drivers/net/bonding/bond_main.c b/drivers/net/bonding/bond_main.c
index b7313c1d9dcd..177be373966b 100644
--- a/drivers/net/bonding/bond_main.c
+++ b/drivers/net/bonding/bond_main.c
@@ -3076,7 +3076,16 @@ static int bond_slave_netdev_event(unsigned long event,
 		break;
 	case NETDEV_UP:
 	case NETDEV_CHANGE:
-		bond_update_speed_duplex(slave);
+		/* For 802.3ad mode only:
+		 * Getting invalid Speed/Duplex values here will put slave
+		 * in weird state. So mark it as link-down for the time
+		 * being and let link-monitoring (miimon) set it right when
+		 * correct speeds/duplex are available.
+		 */
+		if (bond_update_speed_duplex(slave) &&
+		    BOND_MODE(bond) == BOND_MODE_8023AD)
+			slave->link = BOND_LINK_DOWN;
+
 		if (BOND_MODE(bond) == BOND_MODE_8023AD)
 			bond_3ad_adapter_speed_duplex_changed(slave);
 		/* Fallthrough */
-- 
2.14.2.822.g60be5d43e6-goog
