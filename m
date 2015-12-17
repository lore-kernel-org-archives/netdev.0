From: <zyjzyj2000@gmail.com>
Subject: [PATCH 1/1] bonding: restrict up state in 802.3ad mode
Date: Thu, 17 Dec 2015 16:03:37 +0800
Message-ID: <1450339417-31254-1-git-send-email-zyjzyj2000@gmail.com>
Mime-Version: 1.0
Content-Type: text/plain
To: <j.vosburgh@gmail.com>, <vfalico@gmail.com>,
	<gospo@cumulusnetworks.com>, <netdev@vger.kernel.org>,
	<Boris.Shteinbock@windriver.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail5.windriver.com ([192.103.53.11]:50717 "EHLO mail5.wrs.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1750837AbbLQIDX (ORCPT <rfc822;netdev@vger.kernel.org>);
	Thu, 17 Dec 2015 03:03:23 -0500
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Zhu Yanjun <zyjzyj2000@gmail.com>

In 802.3ad mode, the speed and duplex is needed. But in some NIC,
there is a time span between NIC up state and getting speed and duplex.
As such, sometimes a slave in 802.3ad mode is in up state without
speed and duplex. This will make bonding in 802.3ad mode can not
work well. 
To make bonding driver be compatible with more NICs, it is
necessary to restrict the up state in 802.3ad mode.

Signed-off-by: Zhu Yanjun <zyjzyj2000@gmail.com>
---
 drivers/net/bonding/bond_main.c |   19 +++++++++++++++++++
 1 file changed, 19 insertions(+)

diff --git a/drivers/net/bonding/bond_main.c b/drivers/net/bonding/bond_main.c
index 9e0f8a7..0a80fb3 100644
--- a/drivers/net/bonding/bond_main.c
+++ b/drivers/net/bonding/bond_main.c
@@ -1991,6 +1991,25 @@ static int bond_miimon_inspect(struct bonding *bond)
 
 		link_state = bond_check_dev_link(bond, slave->dev, 0);
 
+		/* Since some NIC has time span between netif_running and
+		 * getting speed and duples. That is, after a NIC is up (netif_running),
+		 * there is a time span before this NIC is negotiated with speed and duplex.
+		 * During this time span, the slave in 802.3ad is configured without speed
+		 * and duplex. This 802.3ad bonding will not work because it needs slave's speed
+		 * and duplex to generate key field.
+		 * As such, we restrict up in 802.3ad mode to: netif_running && peed != SPEED_UNKNOWN &&
+		 * duplex != DUPLEX_UNKNOWN
+		 */
+		if ((BMSR_LSTATUS == link_state) &&
+		    (BOND_MODE(bond) == BOND_MODE_8023AD)) {
+			bond_update_speed_duplex(slave);
+			if ((slave->speed == SPEED_UNKNOWN) ||
+			    (slave->duplex == DUPLEX_UNKNOWN)) {
+				link_state = 0;
+				netdev_info(bond->dev, "In 802.3ad mode, it is not enough to up without speed and duplex");
+			}
+		}
+
 		switch (slave->link) {
 		case BOND_LINK_UP:
 			if (link_state)
-- 
1.7.9.5
