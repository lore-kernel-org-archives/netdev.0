From: David Dillow <dave@thedillows.org>
Subject: [PATCH] typhoon: fix incorrect use of smp_wmb()
Date: Thu, 04 Mar 2010 09:37:16 -0500
Message-ID: <1267713436.2328.12.camel@lap75545.ornl.gov>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Content-Transfer-Encoding: 8BIT
Cc: David Miller <davem@davemloft.net>
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from emroute2.ornl.gov ([160.91.86.17]:53391 "EHLO emroute2.ornl.gov"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1753319Ab0CDPAK convert rfc822-to-8bit (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 4 Mar 2010 10:00:10 -0500
Received: from emroute2.ornl.gov ([127.0.0.1])
 by emroute2.ornl.gov (PMDF V6.4 #31561)
 with ESMTP id <0KYR001Q3HY894@emroute2.ornl.gov> for netdev@vger.kernel.org;
 Thu, 04 Mar 2010 09:37:20 -0500 (EST)
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

The typhoon driver was incorrectly using smp_wmb() to order memory
accesses against IO to the NIC in a few instances. Use wmb() instead,
which is required to actually order between memory types.

Signed-off-by: David Dillow <dave@thedillows.org>
---
This is against Linus's tree, which doesn't appear to have net-next in
it yet. It should apply with offsets, though. I can redo against
net-next if needed, but likely won't have quick access to that tree
until the weekend.

diff --git a/drivers/net/typhoon.c b/drivers/net/typhoon.c
index 39f1fc6..a192852 100644
--- a/drivers/net/typhoon.c
+++ b/drivers/net/typhoon.c
@@ -487,7 +487,7 @@ typhoon_hello(struct typhoon *tp)
 		typhoon_inc_cmd_index(&ring->lastWrite, 1);
 
 		INIT_COMMAND_NO_RESPONSE(cmd, TYPHOON_CMD_HELLO_RESP);
-		smp_wmb();
+		wmb();
 		iowrite32(ring->lastWrite, tp->ioaddr + TYPHOON_REG_CMD_READY);
 		spin_unlock(&tp->command_lock);
 	}
@@ -1321,13 +1321,15 @@ typhoon_init_interface(struct typhoon *tp)
 
 	tp->txlo_dma_addr = le32_to_cpu(iface->txLoAddr);
 	tp->card_state = Sleeping;
-	smp_wmb();
 
 	tp->offload = TYPHOON_OFFLOAD_IP_CHKSUM | TYPHOON_OFFLOAD_TCP_CHKSUM;
 	tp->offload |= TYPHOON_OFFLOAD_UDP_CHKSUM | TSO_OFFLOAD_ON;
 
 	spin_lock_init(&tp->command_lock);
 	spin_lock_init(&tp->state_lock);
+
+	/* Force the writes to the shared memory area out before continuing. */
+	wmb();
 }
 
 static void

