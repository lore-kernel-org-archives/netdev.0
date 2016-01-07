From: <zyjzyj2000@gmail.com>
Subject: [PATCH 1/1] bonding: restrict up state in 802.3ad mode
Date: Thu, 7 Jan 2016 14:13:57 +0800
Message-ID: <1452147237-22839-1-git-send-email-zyjzyj2000@gmail.com>
Mime-Version: 1.0
Content-Type: text/plain
Cc: <vfalico@gmail.com>, <gospo@cumulusnetworks.com>,
	<netdev@vger.kernel.org>, <boris.shteinbock@windriver.com>
To: <emil.s.tantilov@intel.com>, <mkubecek@suse.cz>,
	<jay.vosburgh@canonical.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail.windriver.com ([147.11.1.11]:39758 "EHLO
	mail.windriver.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1750707AbcAGGNc (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 7 Jan 2016 01:13:32 -0500
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Zhu Yanjun <yanjun.zhu@windriver.com>

In 802.3ad mode, the speed and duplex is needed. But in some NIC,
there is a time span between NIC up state and getting speed and duplex.
As such, sometimes a slave in 802.3ad mode is in up state without
speed and duplex. This will make bonding in 802.3ad mode can not
work well.
To make bonding driver be compatible with more NICs, it is
necessary to restrict the up state in 802.3ad mode.

Signed-off-by: Zhu Yanjun <yanjun.zhu@windriver.com>
---
 drivers/net/bonding/bond_main.c |   11 +++++++++++
 1 file changed, 11 insertions(+)

diff --git a/drivers/net/bonding/bond_main.c b/drivers/net/bonding/bond_main.c
index 09f8a48..7df8af5 100644
--- a/drivers/net/bonding/bond_main.c
+++ b/drivers/net/bonding/bond_main.c
@@ -1991,6 +1991,17 @@ static int bond_miimon_inspect(struct bonding *bond)
 
 		link_state = bond_check_dev_link(bond, slave->dev, 0);
 
+		if ((BMSR_LSTATUS == link_state) &&
+		    (BOND_MODE(bond) == BOND_MODE_8023AD)) {
+			rtnl_lock();
+			bond_update_speed_duplex(slave);
+			rtnl_unlock();
+			if ((slave->speed == SPEED_UNKNOWN) ||
+			    (slave->duplex == DUPLEX_UNKNOWN)) {
+				link_state = 0;
+				netdev_info(bond->dev, "In 802.3ad mode, it is not enough to up without speed and duplex");
+			}
+		}
 		switch (slave->link) {
 		case BOND_LINK_UP:
 			if (link_state)
-- 
1.7.9.5
