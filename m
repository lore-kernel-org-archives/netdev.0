From: Cong Wang <xiyou.wangcong@gmail.com>
Subject: [Patch net 2/3] bonding: use a larger struct for mac address
Date: Tue, 25 Apr 2017 22:03:22 -0700
Message-ID: <1493183003-884-3-git-send-email-xiyou.wangcong@gmail.com>
References: <1493183003-884-1-git-send-email-xiyou.wangcong@gmail.com>
Cc: andreyknvl@google.com, Cong Wang <xiyou.wangcong@gmail.com>,
        Jay Vosburgh <j.vosburgh@gmail.com>
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-pg0-f68.google.com ([74.125.83.68]:35054 "EHLO
        mail-pg0-f68.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S2993383AbdDZFDj (ORCPT
        <rfc822;netdev@vger.kernel.org>); Wed, 26 Apr 2017 01:03:39 -0400
Received: by mail-pg0-f68.google.com with SMTP id 68so992804pgj.2
        for <netdev@vger.kernel.org>; Tue, 25 Apr 2017 22:03:38 -0700 (PDT)
In-Reply-To: <1493183003-884-1-git-send-email-xiyou.wangcong@gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

IPv6 tunnels use sizeof(struct in6_addr) as dev->addr_len,
but in many places especially bonding, we use struct sockaddr
to copy and set mac addr, this could lead to stack out-of-bounds
access.

Fix it by using a larger address storage.

Reported-by: Andrey Konovalov <andreyknvl@google.com>
Cc: Jay Vosburgh <j.vosburgh@gmail.com>
Signed-off-by: Cong Wang <xiyou.wangcong@gmail.com>
---
 drivers/net/bonding/bond_alb.c     |  8 ++++----
 drivers/net/bonding/bond_main.c    | 17 +++++++++--------
 drivers/net/bonding/bonding_priv.h |  6 ++++++
 3 files changed, 19 insertions(+), 12 deletions(-)

diff --git a/drivers/net/bonding/bond_alb.c b/drivers/net/bonding/bond_alb.c
index c80b023..0038266 100644
--- a/drivers/net/bonding/bond_alb.c
+++ b/drivers/net/bonding/bond_alb.c
@@ -39,7 +39,7 @@
 #include <asm/byteorder.h>
 #include <net/bonding.h>
 #include <net/bond_alb.h>
-
+#include "bonding_priv.h"
 
 
 static const u8 mac_bcast[ETH_ALEN + 2] __long_aligned = {
@@ -1234,7 +1234,7 @@ static int alb_set_mac_address(struct bonding *bond, void *addr)
 {
 	struct slave *slave, *rollback_slave;
 	struct list_head *iter;
-	struct sockaddr sa;
+	struct bond_mac_addr sa;
 	char tmp_addr[ETH_ALEN];
 	int res;
 
@@ -1257,8 +1257,8 @@ static int alb_set_mac_address(struct bonding *bond, void *addr)
 	return 0;
 
 unwind:
-	memcpy(sa.sa_data, bond->dev->dev_addr, bond->dev->addr_len);
-	sa.sa_family = bond->dev->type;
+	memcpy(sa.addr, bond->dev->dev_addr, bond->dev->addr_len);
+	sa.type = bond->dev->type;
 
 	/* unwind from head to the slave that failed */
 	bond_for_each_slave(bond, rollback_slave, iter) {
diff --git a/drivers/net/bonding/bond_main.c b/drivers/net/bonding/bond_main.c
index 8a4ba8b..7a9bd30 100644
--- a/drivers/net/bonding/bond_main.c
+++ b/drivers/net/bonding/bond_main.c
@@ -1330,7 +1330,7 @@ int bond_enslave(struct net_device *bond_dev, struct net_device *slave_dev)
 	struct bonding *bond = netdev_priv(bond_dev);
 	const struct net_device_ops *slave_ops = slave_dev->netdev_ops;
 	struct slave *new_slave = NULL, *prev_slave;
-	struct sockaddr addr;
+	struct bond_mac_addr addr;
 	int link_reporting;
 	int res = 0, i;
 
@@ -1488,8 +1488,8 @@ int bond_enslave(struct net_device *bond_dev, struct net_device *slave_dev)
 		/* Set slave to master's mac address.  The application already
 		 * set the master's mac address to that of the first slave
 		 */
-		memcpy(addr.sa_data, bond_dev->dev_addr, bond_dev->addr_len);
-		addr.sa_family = slave_dev->type;
+		memcpy(addr.addr, bond_dev->dev_addr, bond_dev->addr_len);
+		addr.type = slave_dev->type;
 		res = dev_set_mac_address(slave_dev, &addr);
 		if (res) {
 			netdev_dbg(bond_dev, "Error %d calling set_mac_address\n", res);
@@ -1773,8 +1773,8 @@ int bond_enslave(struct net_device *bond_dev, struct net_device *slave_dev)
 		 * MAC if this slave's MAC is in use by the bond, or at
 		 * least print a warning.
 		 */
-		ether_addr_copy(addr.sa_data, new_slave->perm_hwaddr);
-		addr.sa_family = slave_dev->type;
+		ether_addr_copy(addr.addr, new_slave->perm_hwaddr);
+		addr.type = slave_dev->type;
 		dev_set_mac_address(slave_dev, &addr);
 	}
 
@@ -3619,7 +3619,8 @@ static int bond_set_mac_address(struct net_device *bond_dev, void *addr)
 {
 	struct bonding *bond = netdev_priv(bond_dev);
 	struct slave *slave, *rollback_slave;
-	struct sockaddr *sa = addr, tmp_sa;
+	struct sockaddr *sa = addr;
+	struct bond_mac_addr tmp_sa;
 	struct list_head *iter;
 	int res = 0;
 
@@ -3659,8 +3660,8 @@ static int bond_set_mac_address(struct net_device *bond_dev, void *addr)
 	return 0;
 
 unwind:
-	memcpy(tmp_sa.sa_data, bond_dev->dev_addr, bond_dev->addr_len);
-	tmp_sa.sa_family = bond_dev->type;
+	memcpy(tmp_sa.addr, bond_dev->dev_addr, bond_dev->addr_len);
+	tmp_sa.type = bond_dev->type;
 
 	/* unwind from head to the slave that failed */
 	bond_for_each_slave(bond, rollback_slave, iter) {
diff --git a/drivers/net/bonding/bonding_priv.h b/drivers/net/bonding/bonding_priv.h
index 5a4d81a..8b3a7e3 100644
--- a/drivers/net/bonding/bonding_priv.h
+++ b/drivers/net/bonding/bonding_priv.h
@@ -22,4 +22,10 @@
 
 #define bond_version DRV_DESCRIPTION ": v" DRV_VERSION " (" DRV_RELDATE ")\n"
 
+/* Must be compatible with struct sockaddr */
+struct bond_mac_addr {
+	unsigned short type;
+	unsigned char addr[MAX_ADDR_LEN];
+};
+
 #endif
-- 
2.5.5
