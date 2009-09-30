From: Jay Vosburgh <fubar@us.ibm.com>
Subject: [PATCH 3/3] bonding: send ARP requests on interfaces other than the primary for tlb/alb
Date: Tue, 29 Sep 2009 17:15:31 -0700
Message-ID: <1254269731-7341-4-git-send-email-fubar@us.ibm.com>
References: <1254269731-7341-1-git-send-email-fubar@us.ibm.com>
 <1254269731-7341-2-git-send-email-fubar@us.ibm.com>
 <1254269731-7341-3-git-send-email-fubar@us.ibm.com>
Cc: David Miller <davem@davemloft.net>,
	Andy Gospodarek <andy@greyhouse.net>
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from e8.ny.us.ibm.com ([32.97.182.138]:44168 "EHLO e8.ny.us.ibm.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1753638AbZI3APg (ORCPT <rfc822;netdev@vger.kernel.org>);
	Tue, 29 Sep 2009 20:15:36 -0400
Received: from d01relay04.pok.ibm.com (d01relay04.pok.ibm.com [9.56.227.236])
	by e8.ny.us.ibm.com (8.14.3/8.13.1) with ESMTP id n8U0DH03017020
	for <netdev@vger.kernel.org>; Tue, 29 Sep 2009 20:13:17 -0400
Received: from d01av04.pok.ibm.com (d01av04.pok.ibm.com [9.56.224.64])
	by d01relay04.pok.ibm.com (8.13.8/8.13.8/NCO v10.0) with ESMTP id n8U0Fe06252720
	for <netdev@vger.kernel.org>; Tue, 29 Sep 2009 20:15:40 -0400
Received: from d01av04.pok.ibm.com (loopback [127.0.0.1])
	by d01av04.pok.ibm.com (8.12.11.20060308/8.13.3) with ESMTP id n8U0FdDp023172
	for <netdev@vger.kernel.org>; Tue, 29 Sep 2009 20:15:40 -0400
In-Reply-To: <1254269731-7341-3-git-send-email-fubar@us.ibm.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Andy Gospodarek <andy@greyhouse.net>

This patch sends ARP request on the correct destination output interface
rather than always sending them on the primary interface.  I've also
added some bits to make sure that the source and destination address in
the ARP header are correct since simply changing the source MAC and
output interface will not be that helpful.

Signed-off-by: Andy Gospodarek <andy@greyhouse.net>
Signed-off-by: Jay Vosburgh <fubar@us.ibm.com>

---
 drivers/net/bonding/bond_alb.c |   45 ++++++++++++++++++---------------------
 1 files changed, 21 insertions(+), 24 deletions(-)

diff --git a/drivers/net/bonding/bond_alb.c b/drivers/net/bonding/bond_alb.c
index 5cd0400..9148c75 100644
--- a/drivers/net/bonding/bond_alb.c
+++ b/drivers/net/bonding/bond_alb.c
@@ -726,35 +726,32 @@ static struct slave *rlb_arp_xmit(struct sk_buff *skb, struct bonding *bond)
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
1.6.0.2

