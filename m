From: Wangyufen <wangyufen@huawei.com>
Subject: [PATCH] bonding:fix speed unknown,lacp bonding failed
Date: Fri, 5 Jul 2013 14:32:59 +0800
Message-ID: <1373005979-10196-1-git-send-email-wangyufen@huawei.com>
Mime-Version: 1.0
Content-Type: text/plain
Cc: <zhangdianfang@huawei.com>
To: <netdev@vger.kernel.org>, <lizefan@huawei.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from szxga01-in.huawei.com ([119.145.14.64]:58573 "EHLO
	szxga01-in.huawei.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752535Ab3GEGdK (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 5 Jul 2013 02:33:10 -0400
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
 drivers/net/bonding/bond_main.c | 5 ++++-
 1 file changed, 4 insertions(+), 1 deletion(-)

diff --git a/drivers/net/bonding/bond_main.c b/drivers/net/bonding/bond_main.c
index f975696..d288a98 100644
--- a/drivers/net/bonding/bond_main.c
+++ b/drivers/net/bonding/bond_main.c
@@ -2301,8 +2301,11 @@ static int bond_miimon_inspect(struct bonding *bond)
 
 		switch (slave->link) {
 		case BOND_LINK_UP:
-			if (link_state)
+			if (link_state) {
+				if (slave->speed == SPEED_UNKNOWN)
+					bond_update_speed_duplex(slave);
 				continue;
+			}
 
 			slave->link = BOND_LINK_FAIL;
 			slave->delay = bond->params.downdelay;
-- 
1.8.0
