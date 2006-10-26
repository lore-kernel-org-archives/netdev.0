From: "Glenn Grundstrom" <ggrundstrom@NetEffect.com>
Subject: [PATCH 2/9] NetEffect 10Gb RNIC Driver: main kernel driver c file
Date: Thu, 26 Oct 2006 18:54:18 -0500
Message-ID: <5E701717F2B2ED4EA60F87C8AA57B7CC064C9EB6@venom2>
Reply-To: <glenng@neteffect.com>
Mime-Version: 1.0
Content-Type: text/plain;
	charset="us-ascii"
Content-Transfer-Encoding: 8BIT
Cc: <netdev@vger.kernel.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail2.neteffect.com ([204.57.75.68]:18909 "EHLO
	mail2.neteffect.com") by vger.kernel.org with ESMTP
	id S1423670AbWJZXyT convert rfc822-to-8bit (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 26 Oct 2006 19:54:19 -0400
Content-class: urn:content-classes:message
To: <openib-general@openib.org>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Kernel driver patch 2 of 9.

Signed-off-by: Glenn Grundstrom <glenng@neteffect.com>

======================================================

diff -ruNp old/drivers/infiniband/hw/nes/nes.c
new/drivers/infiniband/hw/nes/nes.c
--- old/drivers/infiniband/hw/nes/nes.c	1969-12-31 18:00:00.000000000
-0600
+++ new/drivers/infiniband/hw/nes/nes.c	2006-10-25 10:15:49.000000000
-0500
@@ -0,0 +1,653 @@
+/*
+ * Copyright (c) 2006 NetEffect, Inc. All rights reserved.
+ * Copyright (c) 2005 Open Grid Computing, Inc. All rights reserved.
+ *
+ * This software is available to you under a choice of one of two
+ * licenses.  You may choose to be licensed under the terms of the GNU
+ * General Public License (GPL) Version 2, available from the file
+ * COPYING in the main directory of this source tree, or the
+ * OpenIB.org BSD license below:
+ *
+ *     Redistribution and use in source and binary forms, with or
+ *     without modification, are permitted provided that the following
+ *     conditions are met:
+ *
+ *      - Redistributions of source code must retain the above
+ *        copyright notice, this list of conditions and the following
+ *        disclaimer.
+ *
+ *      - Redistributions in binary form must reproduce the above
+ *        copyright notice, this list of conditions and the following
+ *        disclaimer in the documentation and/or other materials
+ *        provided with the distribution.
+ *
+ * THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND,
+ * EXPRESS OR IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF
+ * MERCHANTABILITY, FITNESS FOR A PARTICULAR PURPOSE AND
+ * NONINFRINGEMENT. IN NO EVENT SHALL THE AUTHORS OR COPYRIGHT HOLDERS
+ * BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER LIABILITY, WHETHER IN AN
+ * ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM, OUT OF OR IN
+ * CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN THE
+ * SOFTWARE.
+ */
+#include <linux/module.h>
+#include <linux/moduleparam.h>
+#include <linux/etherdevice.h>
+#include <linux/ethtool.h>
+#include <linux/mii.h>
+#include <linux/if_vlan.h>
+#include <linux/crc32.h>
+#include <linux/in.h>
+#include <linux/init.h>
+#include <linux/if_arp.h>
+#include <asm/io.h>
+#include <asm/irq.h>
+#include <asm/byteorder.h>
+
+#include <rdma/ib_smi.h>
+#include <rdma/ib_verbs.h>
+#include <rdma/ib_pack.h>
+#include <rdma/iw_cm.h>
+
+#include "nes.h"
+
+MODULE_AUTHOR("NetEffect");
+MODULE_DESCRIPTION("NetEffect RNIC Low-level iWARP Driver");
+MODULE_LICENSE("Dual BSD/GPL");
+MODULE_VERSION(DRV_VERSION);
+
+int max_mtu = ETH_DATA_LEN;
+
+
+/* Interoperability */
+int mpa_version = 1;
+module_param(mpa_version, int, 0);
+MODULE_PARM_DESC(mpa_version, "MPA version to be used int MPA Req/Resp
(0 or 1)");
+
+/* Interoperability */
+int disable_mpa_crc = 0;
+module_param(disable_mpa_crc, int, 0);
+MODULE_PARM_DESC(disable_mpa_crc, "Disable checking of MPA CRC");
+
+
+unsigned int send_first = 0;
+module_param(send_first, int, 0);
+MODULE_PARM_DESC(send_first, "Send RDMA Message First on Active
Connection");
+
+
+LIST_HEAD(nes_adapter_list);
+LIST_HEAD(nes_dev_list);
+
+static int nes_device_event(struct notifier_block *notifier, unsigned
long event, void *ptr);
+static int nes_inetaddr_event(struct notifier_block *notifier, unsigned
long event, void *ptr);
+static void nes_print_macaddr(struct net_device *netdev);
+static irqreturn_t nes_interrupt(int, void *, struct pt_regs *);
+static int __devinit nes_probe(struct pci_dev *, const struct
pci_device_id *);
+static int nes_suspend(struct pci_dev *, pm_message_t);
+static int nes_resume(struct pci_dev *);
+static void __devexit nes_remove(struct pci_dev *);
+static int __init nes_init_module(void);
+static void __exit nes_exit_module(void);
+
+extern  struct nes_dev      *nes_ifs[];
+
+// _the_ function interface handle to nes_tcpip module
+struct nes_stack_ops *stack_ops_p;
+
+static struct pci_device_id nes_pci_table[] = {
+	{PCI_VENDOR_ID_NETEFFECT, PCI_DEVICE_ID_NETEFFECT_NE010,
PCI_ANY_ID, PCI_ANY_ID},
+	{0}
+};
+
+MODULE_DEVICE_TABLE(pci, nes_pci_table);
+
+
+static struct notifier_block nes_dev_notifier = {
+	notifier_call:  nes_device_event
+};
+
+static struct notifier_block nes_inetaddr_notifier = {
+	notifier_call:  nes_inetaddr_event
+};
+
+
+/**
+ * nes_device_event
+ * 
+ * @param notifier
+ * @param event
+ * @param ptr
+ * 
+ * @return int
+ */
+static int nes_device_event(struct notifier_block *notifier,
+							unsigned long
event, void *ptr)
+{
+	struct net_device  *netdev = (struct  net_device *)ptr;
+	struct nes_dev *nesdev;
+
+	dprintk("nes_device_event: notifier %p event=%ld netdev=%p,
interface name = %s.\n",
+			notifier, event, netdev, netdev->name);
+
+	list_for_each_entry(nesdev, &nes_dev_list, list) {
+		dprintk("Nesdev list entry = 0x%p.\n", nesdev);
+		if (nesdev->netdev == netdev) {
+			switch (event) {
+				case    NETDEV_DOWN:
+					{
+						nes_ifs[0] = NULL;
+						dprintk("event:DOWN
\n");
+						nes_stop_cm(nesdev);
+					}
+					break;
+				case    NETDEV_REGISTER:
+					{
+						dprintk("event:Register
\n");
+						nes_ifs[0] = nesdev;
+						if
(nesdev->nes_stack_start == 0)
+						{
+							// initialize
tcpip stack
+							if
(!nes_register_stack_client(0, &stack_ops_p, nes_update_arp))
+							{
+								//
initialize the stack
+
stack_ops_p->stack_init((void *)nesdev->netdev);
+								//
disable dhcp
+
stack_ops_p->dhcp_control(0x00);
+
+
nesdev->nes_stack_start = 1;
+							}
+						}
+					}
+					break;
+				default:
+					break;
+			}   
+		}
+	}
+
+	return (NOTIFY_DONE);
+}
+
+
+/**
+ * nes_inetaddr_event
+ * 
+ * @param notifier
+ * @param event
+ * @param ptr
+ * 
+ * @return int
+ */
+static int nes_inetaddr_event(struct notifier_block *notifier,
+							  unsigned long
event, void *ptr)
+{
+	struct in_ifaddr *ifa = ptr;
+	struct net_device *netdev = ifa->ifa_dev->dev;
+	struct nes_dev *nesdev;
+	unsigned int addr;
+	unsigned int mask;
+	int ret;
+
+	dprintk("nes_inetaddr_event: notifier %p event=%ld netdev=%p,
interface name = %s.\n",
+				notifier, event, netdev, netdev->name);
+    dprintk("nes_inetaddr_event: ifa_address=%08X, ifa_mask=%08X\n",
ifa->ifa_address, ifa->ifa_mask);
+
+	addr = ntohl(ifa->ifa_address);
+	mask = ntohl(ifa->ifa_mask);
+	dprintk("nes_inetaddr_event: ip address %08X, netmask %08X.\n",
addr, mask);
+	list_for_each_entry(nesdev, &nes_dev_list, list) {
+		dprintk("Nesdev list entry = 0x%p.\n", nesdev);
+		if (nesdev->netdev == netdev) {
+			// we have ifa->ifa_address/mask here if we need
it
+			switch (event) {
+				case    NETDEV_DOWN:
+					{
+						dprintk("event:DOWN
\n");
+
nes_write_indexed(nesdev->index_reg, 
+
NES_IDX_DST_IP_ADDR+(0x10*PCI_FUNC(nesdev->pcidev->devfn)), 0);
+						// del the IP addr 
+
stack_ops_p->del_ipaddr(addr, mask);
+						nesdev->local_ipaddr =
0;
+
stack_ops_p->dump_rt_table();
+					}
+					break;
+				case    NETDEV_UP:
+					{
+						dprintk("event:UP \n");
+						// Add the address to
the IP table
+
stack_ops_p->add_ipaddr(addr, mask);
+						nesdev->local_ipaddr =
ifa->ifa_address;
+
+
nes_write_indexed(nesdev->index_reg, 
+
NES_IDX_DST_IP_ADDR+(0x10*PCI_FUNC(nesdev->pcidev->devfn)),
ntohl(ifa->ifa_address));
+
+
stack_ops_p->dump_rt_table();
+						if (0 ==
nesdev->of_device_registered)
+						{
+							ret =
nes_register_device(nesdev);
+							if (ret) {
+
printk(KERN_ERR PFX "Unable to register RDMA device, ret = %d\n", ret);
+							} else {
+
nesdev->of_device_registered = 1;
+							}
+						}
+					}
+					break;
+				default:
+					break;
+			}   
+		}
+	}
+	return (NOTIFY_DONE);
+}
+
+
+/**
+ * nes_print_macaddr
+ * 
+ * @param netdev
+ */
+static void nes_print_macaddr(struct net_device *netdev)
+{
+	dprintk("%s: MAC %02X:%02X:%02X:%02X:%02X:%02X, "
+			"IRQ %u\n", netdev->name,
+			netdev->dev_addr[0], netdev->dev_addr[1],
netdev->dev_addr[2],
+			netdev->dev_addr[3], netdev->dev_addr[4],
netdev->dev_addr[5],
+			netdev->irq);
+}
+
+
+/**
+ * nes_add_ref
+ * 
+ * @param ibqp
+ */
+void nes_add_ref(struct ib_qp *ibqp)
+{
+	struct nes_qp *nesqp;
+	dprintk("%s: Bumping refcount for QP%u.\n", __FUNCTION__,
ibqp->qp_num );
+
+	nesqp = to_nesqp(ibqp);
+	atomic_inc(&nesqp->refcount);
+}
+
+
+/**
+ * nes_rem_ref
+ * 
+ * @param ibqp
+ */
+void nes_rem_ref(struct ib_qp *ibqp)
+{
+	struct nes_qp *nesqp;
+	dprintk("%s: Decing refcount for QP%u.\n", __FUNCTION__,
ibqp->qp_num );
+
+	nesqp = to_nesqp(ibqp);
+	if (atomic_dec_and_test(&nesqp->refcount)) {
+		dprintk("%s: Refcount for QP%u is 0. Freeing QP
structure\n", __FUNCTION__, ibqp->qp_num );
+		kfree(nesqp->allocated_buffer);
+	}
+}
+
+
+/**
+ * nes_get_qp
+ * 
+ * @param device
+ * @param qpn
+ * 
+ * @return struct ib_qp*
+ */
+struct ib_qp *nes_get_qp(struct ib_device *device, int qpn)
+{
+	struct nes_dev *nesdev = to_nesdev(device);
+	struct nes_adapter *nesadapter = nesdev->nesadapter;
+
+	if ((qpn<NES_FIRST_QPN) ||
(qpn>=(NES_FIRST_QPN+nesadapter->max_qp)))
+		return NULL;
+
+	return (&nesadapter->qp_table[qpn-NES_FIRST_QPN]->ibqp);
+}
+
+
+/**
+ * nes_interrupt - handle interrupts
+ */
+static irqreturn_t nes_interrupt(int irq, void *dev_id, struct pt_regs
*regs)
+{
+	struct nes_dev *nesdev = (struct nes_dev *) dev_id;
+	int handled = 0;
+
+	handled = nes_read32(nesdev->regs+NES_INT_PENDING );
+	// dprintk("Interrupt Pending value  = 0x%08X\n", handled );
+
+	if (handled) {
+		tasklet_schedule(&nesdev->dpc_tasklet);
+		return IRQ_HANDLED;
+	} else {
+		return IRQ_NONE;
+	}
+}
+
+
+/**
+ * nes_probe -
+ * 
+ * @param pcidev
+ * @param ent
+ * 
+ * @return int __devinit
+ */
+static int __devinit nes_probe(struct pci_dev *pcidev, const struct
pci_device_id *ent)
+{
+	int ret = 0;
+	unsigned long reg0_start, reg0_flags, reg0_len;
+	unsigned long reg1_start, reg1_flags, reg1_len;
+	struct net_device *netdev = NULL;
+	struct nes_dev *nesdev = NULL;
+	void __iomem *mmio_regs = NULL;
+	
+	assert(pcidev != NULL);
+	assert(ent != NULL);
+	
+	printk(KERN_INFO PFX "%s: NetEffect RNIC driver v%s loading\n",
pci_name(pcidev), DRV_VERSION);
+	
+	/* Enable PCI device */
+	ret = pci_enable_device(pcidev);
+	if (ret){
+		printk(KERN_ERR PFX "%s: Unable to enable PCI device\n",
pci_name(pcidev));
+		goto bail0;
+	}
+	
+	reg0_start = pci_resource_start(pcidev, BAR_0);
+	reg0_len = pci_resource_len(pcidev, BAR_0);
+	reg0_flags = pci_resource_flags(pcidev, BAR_0);
+	
+	reg1_start = pci_resource_start(pcidev, BAR_1);
+	reg1_len = pci_resource_len(pcidev, BAR_1);
+	reg1_flags = pci_resource_flags(pcidev, BAR_1);
+	
+	dprintk("BAR0 (@0x%08lX) size = 0x%lX bytes\n", reg0_start,
reg0_len);
+	dprintk("BAR1 (@0x%08lX) size = 0x%lX bytes\n", reg1_start,
reg1_len);
+	
+	/* Make sure PCI base addr are MMIO */
+	if (!(reg0_flags & IORESOURCE_MEM) || !(reg1_flags &
IORESOURCE_MEM)) {
+		printk(KERN_ERR PFX "PCI regions not an MMIO
resource\n");
+		ret = -ENODEV;
+		goto bail1;
+	}
+	
+	/* Reserve PCI I/O and memory resources */
+	ret = pci_request_regions(pcidev, DRV_NAME);
+	if (ret) {
+		printk(KERN_ERR PFX "%s: Unable to request regions\n",
pci_name(pcidev));
+		goto bail1;
+	}
+	
+	if ((sizeof(dma_addr_t) > 4)) {
+		ret = pci_set_dma_mask(pcidev, DMA_64BIT_MASK);
+		if (ret < 0) {
+			printk(KERN_ERR PFX "64b DMA configuration
failed\n");
+			goto bail2;
+		}
+	} else {
+		ret = pci_set_dma_mask(pcidev, DMA_32BIT_MASK);
+		if (ret < 0){
+			printk(KERN_ERR PFX "32b DMA configuration
failed\n");
+			goto bail2;
+		}
+	}
+	
+	/* Enables bus-mastering on the device */
+	pci_set_master(pcidev);
+
+	/* pci tweaks */
+	pci_write_config_word(pcidev, 0x000c, 0xfc10);
+	pci_write_config_dword(pcidev, 0x0048, 0x00480007);
+
+	/* Allocate hardware structure */
+	nesdev = (struct nes_dev *)ib_alloc_device(sizeof *nesdev);
+	if (!nesdev) {
+		printk(KERN_ERR PFX "%s: Unable to alloc hardware
struct\n", pci_name(pcidev));
+		ret = -ENOMEM;
+		iounmap(mmio_regs);
+		goto bail2;
+	}
+	
+	memset(nesdev, 0, sizeof(*nesdev));
+	spin_lock_init(&nesdev->lock);
+	nesdev->pcidev = pcidev;
+	nesdev->cur_tx = 0;
+	
+	/* Remap the PCI registers in adapter BAR0 to kernel VA space */
+	mmio_regs = ioremap_nocache(reg0_start, sizeof(mmio_regs));
+	if (mmio_regs == 0UL){
+		printk(KERN_ERR PFX "Unable to remap BAR0\n");
+		ret = -EIO;
+		goto bail35;
+	}
+	nesdev->regs = mmio_regs;
+	nesdev->index_reg = 0x50 + (PCI_FUNC(pcidev->devfn)*8) +
mmio_regs;
+	
+	// Ensure interrupts are disabled
+	nes_write32(nesdev->regs+NES_INT_MASK, 0x7fffffff );
+
+	tasklet_init(&nesdev->dpc_tasklet, nes_dpc, (unsigned long)
nesdev);
+	
+	/* Request an interrupt line for the driver */
+	ret = request_irq(pcidev->irq, nes_interrupt, SA_SHIRQ,
DRV_NAME, nesdev);
+	if (ret) {
+		printk(KERN_ERR PFX "%s: requested IRQ %u is busy\n",
pci_name(pcidev), pcidev->irq);
+		iounmap(mmio_regs);
+		goto bail3;
+	}
+	
+	// Init the adapter
+	nesdev->nesadapter = nes_adapter_init(nesdev, (reg1_len /
4096));
+	if (!nesdev->nesadapter) {
+		printk(KERN_ERR PFX "Unable to initialize adapter.\n" );
+		ret = -ENOMEM;
+		goto bail37;
+	}
+	
+	nesdev->nesadapter->csr_start = reg0_start;
+	nesdev->nesadapter->doorbell_start = reg1_start;
+
+	if (nes_read_eeprom_values(nesdev)) {
+		printk(KERN_ERR PFX "Unable to read EEPROM data.\n");
+		ret = -ENODEV;
+		goto bail4;
+	}
+	
+	/* Set driver specific data */
+	pci_set_drvdata(pcidev, nesdev);
+	
+	/* Initialize network device */
+	if ((netdev = nes_netdev_init(nesdev, mmio_regs)) == NULL) {
+		goto bail4;
+	}
+	
+	/* Register network device */
+	ret = register_netdev(netdev);
+	if (ret) {
+		printk(KERN_ERR PFX "Unable to register netdev, ret =
%d\n", ret);
+		goto bail5;
+	}
+	
+	/* Disable network packets */
+	netif_stop_queue(netdev);
+	
+	dprintk("CQP Status       = 0x%08X bytes\n",
nes_read_indexed(nesdev->index_reg, 0xa0));
+	dprintk("PCI Function #   = %u.\n", PCI_FUNC(pcidev->devfn) );
+	
+	/* Print out the MAC address */
+	nes_print_macaddr(netdev);
+
+	dprintk("%s:%s:%u\n", __FILE__, __FUNCTION__, __LINE__);
+
+	register_netdevice_notifier(&nes_dev_notifier);
+	register_inetaddr_notifier(&nes_inetaddr_notifier);
+
+	printk(KERN_ERR PFX "%s: NetEffect RNIC driver successfully
loaded.\n", pci_name(pcidev));
+
+	return 0;
+
+bail5:
+   printk(KERN_ERR PFX "bail5\n");
+   nes_netdev_exit(nesdev);
+   free_netdev(netdev);
+
+bail4:
+   printk(KERN_ERR PFX "bail4\n");
+   /* Deallocate the Adapter Structure */
+   nes_adapter_free(nesdev->nesadapter);
+
+bail37:
+   printk(KERN_ERR PFX "bail37\n");
+   /* Unmap adapter PA space */
+   iounmap(mmio_regs);
+
+bail35:
+   printk(KERN_ERR PFX "bail3.5\n");
+   free_irq(pcidev->irq, nesdev);
+
+bail3:
+   printk(KERN_ERR PFX "bail3\n");
+   ib_dealloc_device(&nesdev->ibdev);
+
+bail2:
+   pci_release_regions(pcidev);
+
+bail1:
+   pci_disable_device(pcidev);
+
+bail0:
+   return (ret);
+}
+
+
+/**
+ * nes_suspend - power management
+ */
+static int nes_suspend(struct pci_dev *pcidev, pm_message_t state)
+{
+	dprintk("pcidev=%p\n", pcidev);
+
+	return (0);
+}
+
+
+/**
+ * nes_resume - power management
+ */
+static int nes_resume(struct pci_dev *pcidev)
+{
+	dprintk("pcidev=%p\n", pcidev);
+
+	return (0);
+}
+
+
+/**
+ * nes_remove - unload from kernel
+ * 
+ * @param pcidev
+ * 
+ * @return void __devexit
+ */
+static void __devexit nes_remove(struct pci_dev *pcidev)
+{
+	struct nes_dev *nesdev = pci_get_drvdata(pcidev);
+	struct net_device *netdev = nesdev->netdev;
+	
+	dprintk("nes_remove called.\n");
+	assert(netdev != NULL);
+
+	unregister_inetaddr_notifier(&nes_inetaddr_notifier);
+	unregister_netdevice_notifier(&nes_dev_notifier);
+	
+	/* Clean up the RNIC resources */
+	dprintk("nes_remove: calling unregister_netdev.\n");
+	/* Remove network device from the kernel */
+	unregister_netdev(netdev);
+
+	dprintk("nes_remove: calling nes_netdev_exit.\n");
+	/* Free network device */
+	nes_netdev_exit(nesdev);
+	free_netdev(netdev);
+	
+	dprintk("nes_remove: calling free_irq.\n");
+	/* Free the interrupt line */
+	free_irq(pcidev->irq, nesdev);
+	
+	/* missing: Turn LEDs off here */
+	
+	dprintk("nes_remove: calling nes_adapter_free(%p).\n",
nesdev->nesadapter);
+	/* Deallocate the Adapter Structure */
+	nes_adapter_free(nesdev->nesadapter);
+	
+	dprintk("nes_remove: calling iounmap.\n");
+	/* Unmap adapter PA space */
+	iounmap(nesdev->regs);
+
+	/* Unregister with OpenFabrics */
+	if (nesdev->of_device_registered) {
+		dprintk("nes_remove: calling nes_unregister_device.\n");
+		nes_unregister_device(nesdev);
+	}
+	
+	dprintk("nes_remove: calling ib_dealloc_device.\n");
+	/* Free the hardware structure */
+	ib_dealloc_device(&nesdev->ibdev);
+
+	dprintk("nes_remove: calling pci_release_regions.\n");
+	/* Release reserved PCI I/O and memory resources */
+	pci_release_regions(pcidev);
+	
+	dprintk("nes_remove: calling pci_disable_device.\n");
+	/* Disable PCI device */
+	pci_disable_device(pcidev);
+	
+	dprintk("nes_remove: calling pci_set_drvdata.\n");
+	/* Clear driver specific data */
+	pci_set_drvdata(pcidev, NULL);
+}
+
+
+static struct pci_driver nes_pci_driver = {
+	.name = DRV_NAME,
+	.id_table = nes_pci_table,
+	.probe = nes_probe,
+	.remove = __devexit_p(nes_remove),
+#ifdef CONFIG_PM
+	.suspend = nes_suspend,
+	.resume = nes_resume,
+#endif
+};
+
+
+/**
+ * nes_init_module - module initialization entry point
+ * 
+ * @return int __init
+ */
+static int __init nes_init_module(void)
+{
+	return (pci_module_init(&nes_pci_driver));
+}
+
+
+/**
+ * nes_exit_module - module unload entry point
+ * 
+ * @return void __exit
+ */
+static void __exit nes_exit_module(void)
+{
+	pci_unregister_driver(&nes_pci_driver);
+}
+
+
+module_init(nes_init_module);
+module_exit(nes_exit_module);
+					   


