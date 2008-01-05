From: Thomas Bogendoerfer <tsbogend@alpha.franken.de>
Subject: [PATCH] METH: fix MAC address handling
Date: Sat,  5 Jan 2008 23:48:42 +0100 (CET)
Message-ID: <20080105224842.78EDCC2EFB@solo.franken.de>
Cc: ralf@linux-mips.org, jgarzik@pobox.com
To: netdev@vger.kernel.org, linux-mips@linux-mips.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from elvis.franken.de ([193.175.24.41]:46161 "EHLO elvis.franken.de"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1752185AbYAEWtF (ORCPT <rfc822;netdev@vger.kernel.org>);
	Sat, 5 Jan 2008 17:49:05 -0500
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

meth didn't set a valid mac address during probing, but later during
open. Newer kernel refuse to open device with 00:00:00:00:00:00 as
mac address -> dead ethernet. This patch sets the mac address in
the probe function and uses only the mac address from the netdevice
struct when setting up the hardware.

Signed-off-by: Thomas Bogendoerfer <tsbogend@alpha.franken.de>
---

 drivers/net/meth.c |   10 +++++++---
 1 files changed, 7 insertions(+), 3 deletions(-)

diff --git a/drivers/net/meth.c b/drivers/net/meth.c
index 0c89b02..cdaa8fc 100644
--- a/drivers/net/meth.c
+++ b/drivers/net/meth.c
@@ -95,11 +95,14 @@ static inline void load_eaddr(struct net_device *dev)
 {
 	int i;
 	DECLARE_MAC_BUF(mac);
+	u64 macaddr;
 
-	for (i = 0; i < 6; i++)
-		dev->dev_addr[i] = o2meth_eaddr[i];
 	DPRINTK("Loading MAC Address: %s\n", print_mac(mac, dev->dev_addr));
-	mace->eth.mac_addr = (*(unsigned long*)o2meth_eaddr) >> 16;
+	macaddr = 0;
+	for (i = 0; i < 6; i++)
+		macaddr |= dev->dev_addr[i] << ((5 - i) * 8);
+
+	mace->eth.mac_addr = macaddr;
 }
 
 /*
@@ -794,6 +797,7 @@ static int __init meth_probe(struct platform_device *pdev)
 #endif
 	dev->irq	     = MACE_ETHERNET_IRQ;
 	dev->base_addr	     = (unsigned long)&mace->eth;
+	memcpy(dev->dev_addr, o2meth_eaddr, 6);
 
 	priv = netdev_priv(dev);
 	spin_lock_init(&priv->meth_lock);
