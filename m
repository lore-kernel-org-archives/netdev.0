From: Zheng Li <zheng.x.li@oracle.com>
Subject: [PATCH] bonding: rlb mode of bond should not alter ARP originating via bridge
Date: Wed, 28 Nov 2012 17:57:04 +0800
Message-ID: <1354096624-22380-1-git-send-email-zheng.x.li@oracle.com>
Cc: linux-kernel@vger.kernel.org, davem@davemloft.net,
	joe.jin@oracle.com, zheng.x.li@oracle.com
To: netdev@vger.kernel.org, fubar@us.ibm.com, andy@greyhouse.net
Return-path: <linux-kernel-owner@vger.kernel.org>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Do not modify or load balance ARP packets passing through balance-alb
mode (wherein the ARP did not originate locally, and arrived via a bridge).

Modifying pass-through ARP replies causes an incorrect MAC address 
to be placed into the ARP packet, rendering peers unable to communicate 
with the actual destination from which the ARP reply originated.

Load balancing pass-through ARP requests causes an entry to be
created for the peer in the rlb table, and bond_alb_monitor will
occasionally issue ARP updates to all peers in the table instrucing them
as to which MAC address they should communicate with; this occurs when
some event sets rx_ntt.  In the bridged case, however, the MAC address
used for the update would be the MAC of the slave, not the actual source
MAC of the originating destination.  This would render peers unable to
communicate with the destinations beyond the bridge.

Signed-off-by: Zheng Li <zheng.x.li@oracle.com>
Cc: Jay Vosburgh <fubar@us.ibm.com>
Cc: Andy Gospodarek <andy@greyhouse.net>
Cc: "David S. Miller" <davem@davemloft.net>

---
 drivers/net/bonding/bond_alb.c |    6 ++++++
 drivers/net/bonding/bonding.h  |   13 +++++++++++++
 2 files changed, 19 insertions(+), 0 deletions(-)

diff --git a/drivers/net/bonding/bond_alb.c b/drivers/net/bonding/bond_alb.c
index e15cc11..6fecb52 100644
--- a/drivers/net/bonding/bond_alb.c
+++ b/drivers/net/bonding/bond_alb.c
@@ -694,6 +694,12 @@ static struct slave *rlb_arp_xmit(struct sk_buff *skb, struct bonding *bond)
 	struct arp_pkt *arp = arp_pkt(skb);
 	struct slave *tx_slave = NULL;
 
+	/* Don't modify or load balance ARPs that do not originate locally
+	 * (e.g.,arrive via a bridge).
+	 */
+	if (!bond_slave_has_mac(bond, arp->mac_src))
+		return NULL;
+
 	if (arp->op_code == htons(ARPOP_REPLY)) {
 		/* the arp must be sent on the selected
 		* rx channel
diff --git a/drivers/net/bonding/bonding.h b/drivers/net/bonding/bonding.h
index f8af2fc..6dded56 100644
--- a/drivers/net/bonding/bonding.h
+++ b/drivers/net/bonding/bonding.h
@@ -22,6 +22,7 @@
 #include <linux/in6.h>
 #include <linux/netpoll.h>
 #include <linux/inetdevice.h>
+#include <linux/etherdevice.h>
 #include "bond_3ad.h"
 #include "bond_alb.h"
 
@@ -450,6 +451,18 @@ static inline void bond_destroy_proc_dir(struct bond_net *bn)
 }
 #endif
 
+static inline struct slave *bond_slave_has_mac(struct bonding *bond,
+					       const u8 *mac)
+{
+	int i = 0;
+	struct slave *tmp;
+
+	bond_for_each_slave(bond, tmp, i)
+		if (ether_addr_equal_64bits(mac, tmp->dev->dev_addr))
+			return tmp;
+
+	return NULL;
+}
 
 /* exported from bond_main.c */
 extern int bond_net_id;
-- 
1.7.6.5
