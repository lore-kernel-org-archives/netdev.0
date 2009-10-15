From: Randy Dunlap <randy.dunlap@oracle.com>
Subject: [PATCH -next] vmxnet: fix 2 build problems
Date: Wed, 14 Oct 2009 18:17:15 -0700
Message-ID: <20091014181715.09a82630.randy.dunlap@oracle.com>
References: <20091014163445.f0441473.sfr@canb.auug.org.au>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Cc: linux-next@vger.kernel.org, LKML <linux-kernel@vger.kernel.org>,
	davem@davemloft.net, <pv-drivers@vmware.com>
To: Stephen Rothwell <sfr@canb.auug.org.au>,
	netdev <netdev@vger.kernel.org>,
	Shreyas Bhatewara <sbhatewara@vmware.com>
Return-path: <linux-next-owner@vger.kernel.org>
In-Reply-To: <20091014163445.f0441473.sfr@canb.auug.org.au>
Sender: linux-next-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

From: Randy Dunlap <randy.dunlap@oracle.com>

vmxnet3 uses in_dev* interfaces so it should depend on INET.
Also fix so that the driver builds when CONFIG_PCI_MSI is disabled.

vmxnet3_drv.c:(.text+0x2a88cb): undefined reference to `in_dev_finish_destroy'

drivers/net/vmxnet3/vmxnet3_drv.c:1335: error: 'struct vmxnet3_intr' has no member named 'msix_entries'
drivers/net/vmxnet3/vmxnet3_drv.c:1384: error: 'struct vmxnet3_intr' has no member named 'msix_entries'
drivers/net/vmxnet3/vmxnet3_drv.c:2137: error: 'struct vmxnet3_intr' has no member named 'msix_entries'
drivers/net/vmxnet3/vmxnet3_drv.c:2138: error: 'struct vmxnet3_intr' has no member named 'msix_entries'

Signed-off-by: Randy Dunlap <randy.dunlap@oracle.com>
---
 drivers/net/Kconfig               |    2 +-
 drivers/net/vmxnet3/vmxnet3_drv.c |   11 ++++++++++-
 2 files changed, 11 insertions(+), 2 deletions(-)

--- linux-next-20091014.orig/drivers/net/vmxnet3/vmxnet3_drv.c
+++ linux-next-20091014/drivers/net/vmxnet3/vmxnet3_drv.c
@@ -1314,9 +1314,11 @@ vmxnet3_netpoll(struct net_device *netde
 	struct vmxnet3_adapter *adapter = netdev_priv(netdev);
 	int irq;
 
+#ifdef CONFIG_PCI_MSI
 	if (adapter->intr.type == VMXNET3_IT_MSIX)
 		irq = adapter->intr.msix_entries[0].vector;
 	else
+#endif
 		irq = adapter->pdev->irq;
 
 	disable_irq(irq);
@@ -1330,12 +1332,15 @@ vmxnet3_request_irqs(struct vmxnet3_adap
 {
 	int err;
 
+#ifdef CONFIG_PCI_MSI
 	if (adapter->intr.type == VMXNET3_IT_MSIX) {
 		/* we only use 1 MSI-X vector */
 		err = request_irq(adapter->intr.msix_entries[0].vector,
 				  vmxnet3_intr, 0, adapter->netdev->name,
 				  adapter->netdev);
-	} else if (adapter->intr.type == VMXNET3_IT_MSI) {
+	} else
+#endif
+	if (adapter->intr.type == VMXNET3_IT_MSI) {
 		err = request_irq(adapter->pdev->irq, vmxnet3_intr, 0,
 				  adapter->netdev->name, adapter->netdev);
 	} else {
@@ -1376,6 +1381,7 @@ vmxnet3_free_irqs(struct vmxnet3_adapter
 	       adapter->intr.num_intrs <= 0);
 
 	switch (adapter->intr.type) {
+#ifdef CONFIG_PCI_MSI
 	case VMXNET3_IT_MSIX:
 	{
 		int i;
@@ -1385,6 +1391,7 @@ vmxnet3_free_irqs(struct vmxnet3_adapter
 				 adapter->netdev);
 		break;
 	}
+#endif
 	case VMXNET3_IT_MSI:
 		free_irq(adapter->pdev->irq, adapter->netdev);
 		break;
@@ -2134,6 +2141,7 @@ vmxnet3_alloc_intr_resources(struct vmxn
 	if (adapter->intr.type == VMXNET3_IT_AUTO) {
 		int err;
 
+#ifdef CONFIG_PCI_MSI
 		adapter->intr.msix_entries[0].entry = 0;
 		err = pci_enable_msix(adapter->pdev, adapter->intr.msix_entries,
 				      VMXNET3_LINUX_MAX_MSIX_VECT);
@@ -2142,6 +2150,7 @@ vmxnet3_alloc_intr_resources(struct vmxn
 			adapter->intr.type = VMXNET3_IT_MSIX;
 			return;
 		}
+#endif
 
 		err = pci_enable_msi(adapter->pdev);
 		if (!err) {
--- linux-next-20091014.orig/drivers/net/Kconfig
+++ linux-next-20091014/drivers/net/Kconfig
@@ -3232,7 +3232,7 @@ config VIRTIO_NET
 
 config VMXNET3
        tristate "VMware VMXNET3 ethernet driver"
-       depends on PCI && X86
+       depends on PCI && X86 && INET
        help
          This driver supports VMware's vmxnet3 virtual ethernet NIC.
          To compile this driver as a module, choose M here: the
