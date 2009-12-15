From: Ben Hutchings <ben@decadent.org.uk>
Subject: [PATCH] via-velocity: Give RX descriptors to the NIC later on open
 or MTU change
Date: Tue, 15 Dec 2009 02:05:09 +0000
Message-ID: <1260842710.4532.691.camel@localhost>
Mime-Version: 1.0
Content-Type: text/plain; charset="UTF-8"
Content-Transfer-Encoding: 8BIT
Cc: netdev <netdev@vger.kernel.org>, 508527@bugs.debian.org
To: Francois Romieu <romieu@fr.zoreil.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from shadbolt.e.decadent.org.uk ([88.96.1.126]:38861 "EHLO
	shadbolt.e.decadent.org.uk" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with ESMTP id S1758143AbZLOCGl convert rfc822-to-8bit
	(ORCPT <rfc822;netdev@vger.kernel.org>);
	Mon, 14 Dec 2009 21:06:41 -0500
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

velocity_open() calls velocity_give_many_rx_descs(), which gives RX
descriptors to the NIC, before installing an interrupt handler or
calling velocity_init_registers().  I think this is very unsafe and it
appears to explain the bug report <http://bugs.debian.org/508527>.

On MTU change, velocity_give_many_rx_descs() is again called before
velocity_init_registers().  I'm not sure whether this is unsafe but
it does look wrong.

Therefore, move the calls to velocity_give_many_rx_descs() after
request_irq() and velocity_init_registers().

Signed-off-by: Ben Hutchings <ben@decadent.org.uk>
---
This is untested; I don't have this hardware.

Ben.

 drivers/net/via-velocity.c |    8 ++++----
 1 files changed, 4 insertions(+), 4 deletions(-)

diff --git a/drivers/net/via-velocity.c b/drivers/net/via-velocity.c
index 4ceb441..c93f58f 100644
--- a/drivers/net/via-velocity.c
+++ b/drivers/net/via-velocity.c
@@ -2237,8 +2237,6 @@ static int velocity_open(struct net_device *dev)
 	/* Ensure chip is running */
 	pci_set_power_state(vptr->pdev, PCI_D0);
 
-	velocity_give_many_rx_descs(vptr);
-
 	velocity_init_registers(vptr, VELOCITY_INIT_COLD);
 
 	ret = request_irq(vptr->pdev->irq, velocity_intr, IRQF_SHARED,
@@ -2250,6 +2248,8 @@ static int velocity_open(struct net_device *dev)
 		goto out;
 	}
 
+	velocity_give_many_rx_descs(vptr);
+
 	mac_enable_int(vptr->mac_regs);
 	netif_start_queue(dev);
 	napi_enable(&vptr->napi);
@@ -2339,10 +2339,10 @@ static int velocity_change_mtu(struct net_device *dev, int new_mtu)
 
 		dev->mtu = new_mtu;
 
-		velocity_give_many_rx_descs(vptr);
-
 		velocity_init_registers(vptr, VELOCITY_INIT_COLD);
 
+		velocity_give_many_rx_descs(vptr);
+
 		mac_enable_int(vptr->mac_regs);
 		netif_start_queue(dev);
 
-- 
1.6.5.4


