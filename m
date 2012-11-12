From: Zheng Li <zheng.x.li@oracle.com>
Subject: [PATCH] bonding: rlb mode of bond should not alter ARP replies originating via bridge
Date: Mon, 12 Nov 2012 17:55:43 +0800
Message-ID: <1352714143-28160-1-git-send-email-zheng.x.li@oracle.com>
Cc: linux-kernel@vger.kernel.org, davem@davemloft.net,
	joe.jin@oracle.com, zheng.x.li@oracle.com
To: netdev@vger.kernel.org, fubar@us.ibm.com, andy@greyhouse.net
Return-path: <linux-kernel-owner@vger.kernel.org>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

ARP traffic passing through a bridge and out via the bond (when the bond is a 
port of the bridge) should not have its source MAC address adjusted by the 
receive load balance code in rlb_arp_xmit.

Signed-off-by: Zheng Li <zheng.x.li@oracle.com>
Cc: Jay Vosburgh <fubar@us.ibm.com>
Cc: Andy Gospodarek <andy@greyhouse.net>
Cc: "David S. Miller" <davem@davemloft.net>

---
 drivers/net/bonding/bond_alb.c |   21 ++++++++++++++++++++-
 1 files changed, 20 insertions(+), 1 deletions(-)

diff --git a/drivers/net/bonding/bond_alb.c b/drivers/net/bonding/bond_alb.c
index e15cc11..a99e658 100644
--- a/drivers/net/bonding/bond_alb.c
+++ b/drivers/net/bonding/bond_alb.c
@@ -685,6 +685,18 @@ static struct slave *rlb_choose_channel(struct sk_buff *skb, struct bonding *bon
 	return assigned_slave;
 }
 
+struct slave *bond_slave_has_mac(struct bonding *bond, const u8 *mac)
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
+
 /* chooses (and returns) transmit channel for arp reply
  * does not choose channel for other arp types since they are
  * sent on the curr_active_slave
@@ -700,7 +712,14 @@ static struct slave *rlb_arp_xmit(struct sk_buff *skb, struct bonding *bond)
 		*/
 		tx_slave = rlb_choose_channel(skb, bond);
 		if (tx_slave) {
-			memcpy(arp->mac_src,tx_slave->dev->dev_addr, ETH_ALEN);
+			struct slave *tmp_slave = NULL;
+			/* Only modify ARP's MAC if it originates locally;
+			 * don't change ARPs arriving via a bridge.
+			 */
+			tmp_slave = bond_slave_has_mac(bond, arp->mac_src);
+			if (tmp_slave)
+				memcpy(arp->mac_src, tx_slave->dev->dev_addr,
+				       ETH_ALEN);
 		}
 		pr_debug("Server sent ARP Reply packet\n");
 	} else if (arp->op_code == htons(ARPOP_REQUEST)) {
-- 
1.7.6.5
