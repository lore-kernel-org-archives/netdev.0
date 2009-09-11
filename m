From: Andy Gospodarek <andy@greyhouse.net>
Subject: [PATCH 3/4] bonding: send ARP requests on interfaces other than
	the primary for tlb/alb
Date: Fri, 11 Sep 2009 17:11:42 -0400
Message-ID: <20090911211142.GS8515@gospo.rdu.redhat.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
To: netdev@vger.kernel.org, fubar@us.ibm.com,
	bonding-devel@lists.sourceforge.net
Return-path: <netdev-owner@vger.kernel.org>
Received: from mx1.redhat.com ([209.132.183.28]:19164 "EHLO mx1.redhat.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1756830AbZIKVL4 (ORCPT <rfc822;netdev@vger.kernel.org>);
	Fri, 11 Sep 2009 17:11:56 -0400
Content-Disposition: inline
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>


Subject: [PATCH] bonding: send ARP requests on interfaces other than the primary for tlb/alb

This patch sends ARP request on the correct destination output interface
rather than always sending them on the primary interface.  I've also
added some bits to make sure that the source and destination address in
the ARP header are correct since simply changing the source MAC and
output interface will not be that helpful.

Signed-off-by: Andy Gospodarek <andy@greyhouse.net>

---
 drivers/net/bonding/bond_alb.c |   45 ++++++++++++++++++---------------------
 1 files changed, 21 insertions(+), 24 deletions(-)

diff --git a/drivers/net/bonding/bond_alb.c b/drivers/net/bonding/bond_alb.c
index a88d0ec..7db8835 100644
--- a/drivers/net/bonding/bond_alb.c
+++ b/drivers/net/bonding/bond_alb.c
@@ -747,35 +747,32 @@ static struct slave *rlb_arp_xmit(struct sk_buff *skb, struct bonding *bond)
 	struct arp_pkt *arp = arp_pkt(skb);
 	struct slave *tx_slave = NULL;
 
-	if (arp->op_code == htons(ARPOP_REPLY)) {
-		/* the arp must be sent on the selected
-		* rx channel
-		*/
-		tx_slave = rlb_choose_channel(skb, bond);
-		if (tx_slave) {
-			memcpy(arp->mac_src,tx_slave->dev->dev_addr, ETH_ALEN);
-		}
-		pr_debug("Server sent ARP Reply packet\n");
-	} else if (arp->op_code == htons(ARPOP_REQUEST)) {
-		/* Create an entry in the rx_hashtbl for this client as a
-		 * place holder.
-		 * When the arp reply is received the entry will be updated
-		 * with the correct unicast address of the client.
-		 */
-		rlb_choose_channel(skb, bond);
+	/* Choose an output channel for the ARP frame */
+	tx_slave = rlb_choose_channel(skb, bond);
 
-		/* The ARP relpy packets must be delayed so that
-		 * they can cancel out the influence of the ARP request.
-		 */
+	/* If a valid interface is returned, make sure the sender and target MAC
+	 * addresses are correct based on the interface that will be transmitting
+	 * the frame. */
+	if (tx_slave) {
+		/* If sender mac is the bond's address, rewrite */
+		if (!compare_ether_addr_64bits(arp->mac_src,bond->dev->dev_addr))
+			memcpy(arp->mac_src,tx_slave->dev->dev_addr,bond->dev->addr_len);
+
+		/* If target mac is the bond's address, rewrite */
+		if (!compare_ether_addr_64bits(arp->mac_dst,bond->dev->dev_addr))
+			memcpy(arp->mac_dst,tx_slave->dev->dev_addr,bond->dev->addr_len);
+
+	} else if (arp->op_code == htons(ARPOP_REQUEST)) {
+		/* if tx_slave is NULL, the periodic ARP replies must
+		 * be delayed so they can cancel out the influence of
+		 * the ARP request. */
 		bond->alb_info.rlb_update_delay_counter = RLB_UPDATE_DELAY;
 
-		/* arp requests are broadcast and are sent on the primary
-		 * the arp request will collapse all clients on the subnet to
+		/* ARP requests are broadcast and are sent on the primary
+		 * the ARP request will collapse all clients on the subnet to
 		 * the primary slave. We must register these clients to be
-		 * updated with their assigned mac.
-		 */
+		 * updated with their assigned MAC. */
 		rlb_req_update_subnet_clients(bond, arp->ip_src);
-		pr_debug("Server sent ARP Request packet\n");
 	}
 
 	return tx_slave;
-- 
1.5.5.6

