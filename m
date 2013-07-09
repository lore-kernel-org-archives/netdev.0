From: Wangyufen <wangyufen@huawei.com>
Subject: [PATCH v2] bonding:fix speed unknown,lacp bonding failed
Date: Tue, 9 Jul 2013 08:52:02 +0800
Message-ID: <1373331122-10052-1-git-send-email-wangyufen@huawei.com>
Mime-Version: 1.0
Content-Type: text/plain
Cc: <zhangdianfang@huawei.com>
To: <netdev@vger.kernel.org>, <lizefan@huawei.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from szxga03-in.huawei.com ([119.145.14.66]:9874 "EHLO
	szxga03-in.huawei.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1753435Ab3GIAwd (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 8 Jul 2013 20:52:33 -0400
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: "Wang Yufen" <wangyufen@huawei.com>

We bonded nic using LACP mode repeatedly, occasionally LACP bonding failed,
because a slave nic port speed was unknown. But when we used ethtool to 
check the slave NIC status, the nic status was normal,speed was 10000Mb/s.
	
Bonding get the NIC speed from NIC drivers,just when enslave nic 
and receive NETDEV_CHANGE event.We call bond_update_speed_duplex to 
update speed and duplex when miimon inspect slave link is OK and slave 
speed is unknown.
	
	
Signed-off-by: Wang Yufen <wangyufen@huawei.com>
---
 drivers/net/bonding/bond_main.c | 16 +++++++++++++++-
 1 file changed, 15 insertions(+), 1 deletion(-)

diff --git a/drivers/net/bonding/bond_main.c b/drivers/net/bonding/bond_main.c
index f975696..4ccc173 100644
--- a/drivers/net/bonding/bond_main.c
+++ b/drivers/net/bonding/bond_main.c
@@ -2301,8 +2301,22 @@ static int bond_miimon_inspect(struct bonding *bond)
 
 		switch (slave->link) {
 		case BOND_LINK_UP:
-			if (link_state)
+			if (link_state) {
+				if (slave->speed == SPEED_UNKNOWN) {
+					rtnl_lock();
+					bond_update_speed_duplex(slave);
+					if (slave->speed != SPEED_UNKNOWN
+					&& bond->params.mode
+					== BOND_MODE_8023AD) {
+						bond_3ad_adapter_speed_changed(
+						slave);
+						bond_3ad_adapter_duplex_changed(
+						slave);
+					}
+					rtnl_unlock();
+				}
 				continue;
+			}
 
 			slave->link = BOND_LINK_FAIL;
 			slave->delay = bond->params.downdelay;
-- 
1.8.0
