From: Weiping Pan <wpan@redhat.com>
Subject: [PATCH] bonding:update speed/duplex for NETDEV_CHANGE
Date: Mon, 31 Oct 2011 22:19:41 +0800
Message-ID: <e00468a2cbb8a25d7a89028e876769449454309f.1320070684.git.wpan@redhat.com>
References: <4EAE0D9A.9060408@gmail.com>
Cc: fubar@us.ibm.com, andy@greyhouse.net, linux-kernel@vger.kernel.org,
	Weiping Pan <wpan@redhat.com>
To: netdev@vger.kernel.org
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <4EAE0D9A.9060408@gmail.com>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Zheng Liang(lzheng@redhat.com) found a bug that if we config bonding with
arp monitor, sometimes bonding driver cannot get the speed and duplex from
its slaves, it will assume them to be 100Mb/sec and Full, please see
/proc/net/bonding/bond0.
But there is no such problem when uses miimon.

(Take igb for example)
I find that the reason is that after dev_open() in bond_enslave(),
bond_update_speed_duplex() will call igb_get_settings()
, but in that function,
it runs ethtool_cmd_speed_set(ecmd, -1); ecmd->duplex = -1;
because igb get an error value of status.
So even dev_open() is called, but the device is not really ready to get its
settings.

Maybe it is safe for us to call igb_get_settings() only after
this message shows up, that is "igb: p4p1 NIC Link is Up 1000 Mbps Full Duplex,
Flow Control: RX".

So I prefer to update the speed and duplex for a slave when reseices
NETDEV_CHANGE/NETDEV_UP event.

Signed-off-by: Weiping Pan <wpan@redhat.com>
---
 drivers/net/bonding/bond_main.c |   19 ++++++++-----------
 1 files changed, 8 insertions(+), 11 deletions(-)

diff --git a/drivers/net/bonding/bond_main.c b/drivers/net/bonding/bond_main.c
index c34cc1e..f5458eb 100644
--- a/drivers/net/bonding/bond_main.c
+++ b/drivers/net/bonding/bond_main.c
@@ -3220,6 +3220,7 @@ static int bond_slave_netdev_event(unsigned long event,
 {
 	struct net_device *bond_dev = slave_dev->master;
 	struct bonding *bond = netdev_priv(bond_dev);
+	struct slave *slave = NULL;
 
 	switch (event) {
 	case NETDEV_UNREGISTER:
@@ -3230,20 +3231,16 @@ static int bond_slave_netdev_event(unsigned long event,
 				bond_release(bond_dev, slave_dev);
 		}
 		break;
+	case NETDEV_UP:
 	case NETDEV_CHANGE:
-		if (bond->params.mode == BOND_MODE_8023AD || bond_is_lb(bond)) {
-			struct slave *slave;
-
-			slave = bond_get_slave_by_dev(bond, slave_dev);
-			if (slave) {
-				u32 old_speed = slave->speed;
-				u8  old_duplex = slave->duplex;
-
-				bond_update_speed_duplex(slave);
+		slave = bond_get_slave_by_dev(bond, slave_dev);
+		if (slave) {
+			u32 old_speed = slave->speed;
+			u8  old_duplex = slave->duplex;
 
-				if (bond_is_lb(bond))
-					break;
+			bond_update_speed_duplex(slave);
 
+			if (bond->params.mode == BOND_MODE_8023AD) {
 				if (old_speed != slave->speed)
 					bond_3ad_adapter_speed_changed(slave);
 				if (old_duplex != slave->duplex)
-- 
1.7.4
