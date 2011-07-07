From: Shreyas Bhatewara <sbhatewara@vmware.com>
Subject: [PATCH] vmxnet3: round down # of queues to power of two
Date: Wed, 6 Jul 2011 17:58:51 -0700 (PDT)
Message-ID: <alpine.LRH.2.00.1107061751120.3509@sbhatewara-dev1.eng.vmware.com>
Mime-Version: 1.0
Content-Type: TEXT/PLAIN; charset=US-ASCII
Cc: yongwang@vmware.com
To: "pv-drivers@vmware.com" <pv-drivers@vmware.com>,
	"netdev@vger.kernel.org" <netdev@vger.kernel.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from smtp-outbound-2.vmware.com ([65.115.85.73]:3281 "EHLO
	smtp-outbound-2.vmware.com" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with ESMTP id S1754298Ab1GGA6t (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 6 Jul 2011 20:58:49 -0400
Received: from mailhost2.vmware.com (mailhost2.vmware.com [10.16.67.167])
	by smtp-outbound-2.vmware.com (Postfix) with ESMTP id 0F4DA51006
	for <netdev@vger.kernel.org>; Wed,  6 Jul 2011 17:58:49 -0700 (PDT)
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>


vmxnet3 device supports only power-of-two number of queues. The driver
therefore needs to check this and rounds down the number of queues to the
nearest power of two.

Signed-off-by: Yong Wang <yongwang@vmware.com>
Signed-off-by: Shreyas N Bhatewara <sbhatewara@vmware.com>
--

diff --git a/drivers/net/vmxnet3/vmxnet3_drv.c b/drivers/net/vmxnet3/vmxnet3_drv.c
index fabcded..4ee7750 100644
--- a/drivers/net/vmxnet3/vmxnet3_drv.c
+++ b/drivers/net/vmxnet3/vmxnet3_drv.c
@@ -2898,12 +2898,18 @@ vmxnet3_probe_device(struct pci_dev *pdev,
 #endif
 		num_rx_queues = 1;
 
+	if (!is_power_of_2(num_rx_queues))
+		num_rx_queues = rounddown_pow_of_two(num_rx_queues);
+
 	if (enable_mq)
 		num_tx_queues = min(VMXNET3_DEVICE_MAX_TX_QUEUES,
 				    (int)num_online_cpus());
 	else
 		num_tx_queues = 1;
 
+	if (!is_power_of_2(num_tx_queues))
+		num_tx_queues = rounddown_pow_of_two(num_tx_queues);
+
 	netdev = alloc_etherdev_mq(sizeof(struct vmxnet3_adapter),
 				   max(num_tx_queues, num_rx_queues));
 	printk(KERN_INFO "# of Tx queues : %d, # of Rx queues : %d\n",
@@ -3089,6 +3095,9 @@ vmxnet3_remove_device(struct pci_dev *pdev)
 #endif
 		num_rx_queues = 1;
 
+	if (!is_power_of_2(num_rx_queues))
+		num_rx_queues = rounddown_pow_of_two(num_rx_queues);
+
 	cancel_work_sync(&adapter->work);
 
 	unregister_netdev(netdev);
diff --git a/drivers/net/vmxnet3/vmxnet3_int.h b/drivers/net/vmxnet3/vmxnet3_int.h
index a9cb3fa..b18eac1 100644
--- a/drivers/net/vmxnet3/vmxnet3_int.h
+++ b/drivers/net/vmxnet3/vmxnet3_int.h
@@ -56,6 +56,7 @@
 #include <linux/if_vlan.h>
 #include <linux/if_arp.h>
 #include <linux/inetdevice.h>
+#include <linux/log2.h>
 
 #include "vmxnet3_defs.h"
 
@@ -69,10 +70,10 @@
 /*
  * Version numbers
  */
-#define VMXNET3_DRIVER_VERSION_STRING   "1.1.14.0-k"
+#define VMXNET3_DRIVER_VERSION_STRING   "1.1.18.0-k"
 
 /* a 32-bit int, each byte encode a verion number in VMXNET3_DRIVER_VERSION */
-#define VMXNET3_DRIVER_VERSION_NUM      0x01010E00
+#define VMXNET3_DRIVER_VERSION_NUM      0x01011200
 
 #if defined(CONFIG_PCI_MSI)
 	/* RSS only makes sense if MSI-X is supported. */
