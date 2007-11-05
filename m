From: Stephen Hemminger <shemminger@linux-foundation.org>
Subject: [PATCH 2/7] sky2: status ring race fix
Date: Mon, 05 Nov 2007 15:52:09 -0800
Message-ID: <20071105235340.034607403@linux-foundation.org>
References: <20071105235207.799504040@linux-foundation.org>
Cc: netdev@vger.kernel.org
To: David Miller <davem@davemloft.net>, Jeff Garzik <jgarzik@pobox.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from smtp2.linux-foundation.org ([207.189.120.14]:46815 "EHLO
	smtp2.linux-foundation.org" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with ESMTP id S1753845AbXKEX44 (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 5 Nov 2007 18:56:56 -0500
Content-Disposition: inline; filename=sky2-status-check.patch
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

The D-Link PCI-X board (and maybe others) can lie about status
ring entries. It seems it will update the register for last status
index before completing the DMA for the ring entry. To avoid reading
stale data, zap the old entry and check.

Signed-off-by: Stephen Hemminger <shemminger@linux-foundation.org>


--- a/drivers/net/sky2.c	2007-11-05 15:01:44.000000000 -0800
+++ b/drivers/net/sky2.c	2007-11-05 15:04:55.000000000 -0800
@@ -2247,20 +2247,26 @@ static int sky2_status_intr(struct sky2_
 	do {
 		struct sky2_port *sky2;
 		struct sky2_status_le *le  = hw->st_le + hw->st_idx;
-		unsigned port = le->css & CSS_LINK_BIT;
+		unsigned port;
 		struct net_device *dev;
 		struct sk_buff *skb;
 		u32 status;
 		u16 length;
+		u8 opcode = le->opcode;
+
+		if (!(opcode & HW_OWNER))
+			break;
 
 		hw->st_idx = RING_NEXT(hw->st_idx, STATUS_RING_SIZE);
 
+		port = le->css & CSS_LINK_BIT;
 		dev = hw->dev[port];
 		sky2 = netdev_priv(dev);
 		length = le16_to_cpu(le->length);
 		status = le32_to_cpu(le->status);
 
-		switch (le->opcode & ~HW_OWNER) {
+		le->opcode = 0;
+		switch (opcode & ~HW_OWNER) {
 		case OP_RXSTAT:
 			++rx[port];
 			skb = sky2_receive(dev, length, status);
@@ -2353,7 +2359,7 @@ static int sky2_status_intr(struct sky2_
 		default:
 			if (net_ratelimit())
 				printk(KERN_WARNING PFX
-				       "unknown status opcode 0x%x\n", le->opcode);
+				       "unknown status opcode 0x%x\n", opcode);
 		}
 	} while (hw->st_idx != idx);
 

-- 
Stephen Hemminger <shemminger@linux-foundation.org>

