From: Casey Leedom <leedom@chelsio.com>
Subject: [PATCH net-26 3/4] cxgb4vf: Quiesce Virtual Interfaces on shutdown ...
Date: Mon, 14 Feb 2011 14:56:24 -0800
Message-ID: <1297724185-27452-4-git-send-email-leedom@chelsio.com>
References: <1297724185-27452-1-git-send-email-leedom@chelsio.com>
Cc: davem@davemloft.net, Casey Leedom <leedom@chelsio.com>
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from stargate.chelsio.com ([67.207.112.58]:2691 "EHLO
	stargate.chelsio.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751197Ab1BNW43 (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 14 Feb 2011 17:56:29 -0500
In-Reply-To: <1297724185-27452-1-git-send-email-leedom@chelsio.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

When a Virtual Machine is rebooted, KVM currently fails to issue a Function
Level Reset against any "Attached PCI Devices" (AKA "PCI Passthrough").  In
addition to leaving the attached device in a random state in the next booted
kernel (which sort of violates the entire idea of a reboot reseting hardware
state), this leaves our peer thinking that the link is still up.  (Note that
a bug has been filed with the KVM folks, #25332, but there's been no
response on that as of yet.)  So, we add a "->shutdown()" method for the
Virtual Function PCI Device to handle administrative shutdowns like a
reboot.

Signed-off-by: Casey Leedom <leedom@chelsio.com>
---
 drivers/net/cxgb4vf/cxgb4vf_main.c |   41 ++++++++++++++++++++++++++++++++++++
 1 files changed, 41 insertions(+), 0 deletions(-)

diff --git a/drivers/net/cxgb4vf/cxgb4vf_main.c b/drivers/net/cxgb4vf/cxgb4vf_main.c
index 2be1088..6aad64d 100644
--- a/drivers/net/cxgb4vf/cxgb4vf_main.c
+++ b/drivers/net/cxgb4vf/cxgb4vf_main.c
@@ -2862,6 +2862,46 @@ static void __devexit cxgb4vf_pci_remove(struct pci_dev *pdev)
 }
 
 /*
+ * "Shutdown" quiesce the device, stopping Ingress Packet and Interrupt
+ * delivery.
+ */
+static void __devexit cxgb4vf_pci_shutdown(struct pci_dev *pdev)
+{
+	struct adapter *adapter;
+	int pidx;
+
+	adapter = pci_get_drvdata(pdev);
+	if (!adapter)
+		return;
+
+	/*
+	 * Disable all Virtual Interfaces.  This will shut down the
+	 * delivery of all ingress packets into the chip for these
+	 * Virtual Interfaces.
+	 */
+	for_each_port(adapter, pidx) {
+		struct net_device *netdev;
+		struct port_info *pi;
+
+		if (!test_bit(pidx, &adapter->registered_device_map))
+			continue;
+
+		netdev = adapter->port[pidx];
+		if (!netdev)
+			continue;
+
+		pi = netdev_priv(netdev);
+		t4vf_enable_vi(adapter, pi->viid, false, false);
+	}
+
+	/*
+	 * Free up all Queues which will prevent further DMA and
+	 * Interrupts allowing various internal pathways to drain.
+	 */
+	t4vf_free_sge_resources(adapter);
+}
+
+/*
  * PCI Device registration data structures.
  */
 #define CH_DEVICE(devid, idx) \
@@ -2894,6 +2934,7 @@ static struct pci_driver cxgb4vf_driver = {
 	.id_table	= cxgb4vf_pci_tbl,
 	.probe		= cxgb4vf_pci_probe,
 	.remove		= __devexit_p(cxgb4vf_pci_remove),
+	.shutdown	= __devexit_p(cxgb4vf_pci_shutdown),
 };
 
 /*
-- 
1.7.0.4

