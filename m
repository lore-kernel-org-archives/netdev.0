From: Jeff Garzik <jeff@garzik.org>
Subject: [git patches] net driver fixes
Date: Wed, 20 Feb 2008 11:55:57 -0500
Message-ID: <20080220165557.GA18816@havoc.gtf.org>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: netdev@vger.kernel.org, LKML <linux-kernel@vger.kernel.org>
To: David Miller <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from havoc.gtf.org ([69.61.125.42]:52147 "EHLO havoc.gtf.org"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1753628AbYBTQ4B (ORCPT <rfc822;netdev@vger.kernel.org>);
	Wed, 20 Feb 2008 11:56:01 -0500
Content-Disposition: inline
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>


Note:  this is based off of Linus's latest commit
(5d9c4a7de64d398604a978d267a6987f1f4025b7), since all my previous
submissions are now upstream (thanks!).


Please pull from 'upstream-davem' branch of
master.kernel.org:/pub/scm/linux/kernel/git/jgarzik/netdev-2.6.git upstream-davem

to receive the following updates:

 MAINTAINERS                        |   11 +-
 drivers/net/cs89x0.c               |   12 +-
 drivers/net/ehea/ehea.h            |   34 +++++-
 drivers/net/ehea/ehea_main.c       |  281 +++++++++++++++++++++++++++++++++---
 drivers/net/fs_enet/fs_enet-main.c |    7 +-
 drivers/net/gianfar.c              |   14 +-
 drivers/net/igb/igb_main.c         |   15 +--
 drivers/net/pcmcia/pcnet_cs.c      |   10 +-
 drivers/net/phy/mdio_bus.c         |    4 +-
 drivers/net/sis190.c               |   15 ++-
 drivers/net/tlan.c                 |   64 ++++----
 drivers/net/tulip/uli526x.c        |   12 ++-
 drivers/net/virtio_net.c           |    2 +-
 drivers/s390/net/claw.c            |   39 +++---
 14 files changed, 399 insertions(+), 121 deletions(-)

Adrian Bunk (1):
      net/phy/mdio_bus.c: fix a check-after-use

Andy Gospodarek (1):
      igb: fix legacy mode irq issue

Becky Bruce (1):
      gianfar: don't pass NULL dev ptr to DMA ops

Bill Hayes (1):
      igb: Fix panic with NICs with 1000BASE-SX PHY

Christian Borntraeger (1):
      virtio_net: Fix oops on early interrupts - introduced by virtio reset code

Francois Romieu (1):
      sis190: read the mac address from the eeprom first

Grant Grundler (2):
      update TULIP MAINTAINERS
      uli526x partially recognizing interface

Harvey Harrison (1):
      tlan: add static to function definitions

Julia Lawall (1):
      claw: make use of DIV_ROUND_UP

Komuro (1):
      pcnet_cs: if AX88190-based card, printk "use axnet_cs instead" message.

Leonardo Potenza (1):
      drivers/net/cs89x0.c: compilation warning fix

Scott Wood (1):
      fs_enet: Don't call phy_mii_ioctl() in atomic context.

Thomas Klein (1):
      ehea: add kdump support

diff --git a/MAINTAINERS b/MAINTAINERS
index 082d1ee..53b6e60 100644
--- a/MAINTAINERS
+++ b/MAINTAINERS
@@ -3887,10 +3887,13 @@ M:	trivial@kernel.org
 L:	linux-kernel@vger.kernel.org
 S:	Maintained
 
-TULIP NETWORK DRIVER
-L:	tulip-users@lists.sourceforge.net
-W:	http://sourceforge.net/projects/tulip/
-S:	Orphan
+TULIP NETWORK DRIVERS
+P:	Grant Grundler
+M:	grundler@parisc-linux.org
+P:	Kyle McMartin
+M:	kyle@parisc-linux.org
+L:	netdev@vger.kernel.org
+S:	Maintained
 
 TUN/TAP driver
 P:	Maxim Krasnyansky
diff --git a/drivers/net/cs89x0.c b/drivers/net/cs89x0.c
index 5717509..348371f 100644
--- a/drivers/net/cs89x0.c
+++ b/drivers/net/cs89x0.c
@@ -172,30 +172,30 @@ static char version[] __initdata =
    them to system IRQ numbers. This mapping is card specific and is set to
    the configuration of the Cirrus Eval board for this chip. */
 #ifdef CONFIG_ARCH_CLPS7500
-static unsigned int netcard_portlist[] __initdata =
+static unsigned int netcard_portlist[] __used __initdata =
    { 0x80090303, 0x300, 0x320, 0x340, 0x360, 0x200, 0x220, 0x240, 0x260, 0x280, 0x2a0, 0x2c0, 0x2e0, 0};
 static unsigned int cs8900_irq_map[] = {12,0,0,0};
 #elif defined(CONFIG_SH_HICOSH4)
-static unsigned int netcard_portlist[] __initdata =
+static unsigned int netcard_portlist[] __used __initdata =
    { 0x0300, 0};
 static unsigned int cs8900_irq_map[] = {1,0,0,0};
 #elif defined(CONFIG_MACH_IXDP2351)
-static unsigned int netcard_portlist[] __initdata = {IXDP2351_VIRT_CS8900_BASE, 0};
+static unsigned int netcard_portlist[] __used __initdata = {IXDP2351_VIRT_CS8900_BASE, 0};
 static unsigned int cs8900_irq_map[] = {IRQ_IXDP2351_CS8900, 0, 0, 0};
 #include <asm/irq.h>
 #elif defined(CONFIG_ARCH_IXDP2X01)
 #include <asm/irq.h>
-static unsigned int netcard_portlist[] __initdata = {IXDP2X01_CS8900_VIRT_BASE, 0};
+static unsigned int netcard_portlist[] __used __initdata = {IXDP2X01_CS8900_VIRT_BASE, 0};
 static unsigned int cs8900_irq_map[] = {IRQ_IXDP2X01_CS8900, 0, 0, 0};
 #elif defined(CONFIG_ARCH_PNX010X)
 #include <asm/irq.h>
 #include <asm/arch/gpio.h>
 #define CIRRUS_DEFAULT_BASE	IO_ADDRESS(EXT_STATIC2_s0_BASE + 0x200000)	/* = Physical address 0x48200000 */
 #define CIRRUS_DEFAULT_IRQ	VH_INTC_INT_NUM_CASCADED_INTERRUPT_1 /* Event inputs bank 1 - ID 35/bit 3 */
-static unsigned int netcard_portlist[] __initdata = {CIRRUS_DEFAULT_BASE, 0};
+static unsigned int netcard_portlist[] __used __initdata = {CIRRUS_DEFAULT_BASE, 0};
 static unsigned int cs8900_irq_map[] = {CIRRUS_DEFAULT_IRQ, 0, 0, 0};
 #else
-static unsigned int netcard_portlist[] __initdata =
+static unsigned int netcard_portlist[] __used __initdata =
    { 0x300, 0x320, 0x340, 0x360, 0x200, 0x220, 0x240, 0x260, 0x280, 0x2a0, 0x2c0, 0x2e0, 0};
 static unsigned int cs8900_irq_map[] = {10,11,12,5};
 #endif
diff --git a/drivers/net/ehea/ehea.h b/drivers/net/ehea/ehea.h
index 88fb53e..7c4ead3 100644
--- a/drivers/net/ehea/ehea.h
+++ b/drivers/net/ehea/ehea.h
@@ -40,7 +40,7 @@
 #include <asm/io.h>
 
 #define DRV_NAME	"ehea"
-#define DRV_VERSION	"EHEA_0083"
+#define DRV_VERSION	"EHEA_0087"
 
 /* eHEA capability flags */
 #define DLPAR_PORT_ADD_REM 1
@@ -386,6 +386,13 @@ struct ehea_port_res {
 
 
 #define EHEA_MAX_PORTS 16
+
+#define EHEA_NUM_PORTRES_FW_HANDLES    6  /* QP handle, SendCQ handle,
+					     RecvCQ handle, EQ handle,
+					     SendMR handle, RecvMR handle */
+#define EHEA_NUM_PORT_FW_HANDLES       1  /* EQ handle */
+#define EHEA_NUM_ADAPTER_FW_HANDLES    2  /* MR handle, NEQ handle */
+
 struct ehea_adapter {
 	u64 handle;
 	struct of_device *ofdev;
@@ -405,6 +412,31 @@ struct ehea_mc_list {
 	u64 macaddr;
 };
 
+/* kdump support */
+struct ehea_fw_handle_entry {
+	u64 adh;               /* Adapter Handle */
+	u64 fwh;               /* Firmware Handle */
+};
+
+struct ehea_fw_handle_array {
+	struct ehea_fw_handle_entry *arr;
+	int num_entries;
+	struct semaphore lock;
+};
+
+struct ehea_bcmc_reg_entry {
+	u64 adh;               /* Adapter Handle */
+	u32 port_id;           /* Logical Port Id */
+	u8 reg_type;           /* Registration Type */
+	u64 macaddr;
+};
+
+struct ehea_bcmc_reg_array {
+	struct ehea_bcmc_reg_entry *arr;
+	int num_entries;
+	struct semaphore lock;
+};
+
 #define EHEA_PORT_UP 1
 #define EHEA_PORT_DOWN 0
 #define EHEA_PHY_LINK_UP 1
diff --git a/drivers/net/ehea/ehea_main.c b/drivers/net/ehea/ehea_main.c
index c051c7e..21af674 100644
--- a/drivers/net/ehea/ehea_main.c
+++ b/drivers/net/ehea/ehea_main.c
@@ -35,6 +35,7 @@
 #include <linux/if_ether.h>
 #include <linux/notifier.h>
 #include <linux/reboot.h>
+#include <asm/kexec.h>
 
 #include <net/ip.h>
 
@@ -98,8 +99,10 @@ static int port_name_cnt;
 static LIST_HEAD(adapter_list);
 u64 ehea_driver_flags;
 struct work_struct ehea_rereg_mr_task;
-
 struct semaphore dlpar_mem_lock;
+struct ehea_fw_handle_array ehea_fw_handles;
+struct ehea_bcmc_reg_array ehea_bcmc_regs;
+
 
 static int __devinit ehea_probe_adapter(struct of_device *dev,
 					const struct of_device_id *id);
@@ -132,6 +135,160 @@ void ehea_dump(void *adr, int len, char *msg)
 	}
 }
 
+static void ehea_update_firmware_handles(void)
+{
+	struct ehea_fw_handle_entry *arr = NULL;
+	struct ehea_adapter *adapter;
+	int num_adapters = 0;
+	int num_ports = 0;
+	int num_portres = 0;
+	int i = 0;
+	int num_fw_handles, k, l;
+
+	/* Determine number of handles */
+	list_for_each_entry(adapter, &adapter_list, list) {
+		num_adapters++;
+
+		for (k = 0; k < EHEA_MAX_PORTS; k++) {
+			struct ehea_port *port = adapter->port[k];
+
+			if (!port || (port->state != EHEA_PORT_UP))
+				continue;
+
+			num_ports++;
+			num_portres += port->num_def_qps + port->num_add_tx_qps;
+		}
+	}
+
+	num_fw_handles = num_adapters * EHEA_NUM_ADAPTER_FW_HANDLES +
+			 num_ports * EHEA_NUM_PORT_FW_HANDLES +
+			 num_portres * EHEA_NUM_PORTRES_FW_HANDLES;
+
+	if (num_fw_handles) {
+		arr = kzalloc(num_fw_handles * sizeof(*arr), GFP_KERNEL);
+		if (!arr)
+			return;  /* Keep the existing array */
+	} else
+		goto out_update;
+
+	list_for_each_entry(adapter, &adapter_list, list) {
+		for (k = 0; k < EHEA_MAX_PORTS; k++) {
+			struct ehea_port *port = adapter->port[k];
+
+			if (!port || (port->state != EHEA_PORT_UP))
+				continue;
+
+			for (l = 0;
+			     l < port->num_def_qps + port->num_add_tx_qps;
+			     l++) {
+				struct ehea_port_res *pr = &port->port_res[l];
+
+				arr[i].adh = adapter->handle;
+				arr[i++].fwh = pr->qp->fw_handle;
+				arr[i].adh = adapter->handle;
+				arr[i++].fwh = pr->send_cq->fw_handle;
+				arr[i].adh = adapter->handle;
+				arr[i++].fwh = pr->recv_cq->fw_handle;
+				arr[i].adh = adapter->handle;
+				arr[i++].fwh = pr->eq->fw_handle;
+				arr[i].adh = adapter->handle;
+				arr[i++].fwh = pr->send_mr.handle;
+				arr[i].adh = adapter->handle;
+				arr[i++].fwh = pr->recv_mr.handle;
+			}
+			arr[i].adh = adapter->handle;
+			arr[i++].fwh = port->qp_eq->fw_handle;
+		}
+
+		arr[i].adh = adapter->handle;
+		arr[i++].fwh = adapter->neq->fw_handle;
+
+		if (adapter->mr.handle) {
+			arr[i].adh = adapter->handle;
+			arr[i++].fwh = adapter->mr.handle;
+		}
+	}
+
+out_update:
+	kfree(ehea_fw_handles.arr);
+	ehea_fw_handles.arr = arr;
+	ehea_fw_handles.num_entries = i;
+}
+
+static void ehea_update_bcmc_registrations(void)
+{
+	struct ehea_bcmc_reg_entry *arr = NULL;
+	struct ehea_adapter *adapter;
+	struct ehea_mc_list *mc_entry;
+	int num_registrations = 0;
+	int i = 0;
+	int k;
+
+	/* Determine number of registrations */
+	list_for_each_entry(adapter, &adapter_list, list)
+		for (k = 0; k < EHEA_MAX_PORTS; k++) {
+			struct ehea_port *port = adapter->port[k];
+
+			if (!port || (port->state != EHEA_PORT_UP))
+				continue;
+
+			num_registrations += 2;	/* Broadcast registrations */
+
+			list_for_each_entry(mc_entry, &port->mc_list->list,list)
+				num_registrations += 2;
+		}
+
+	if (num_registrations) {
+		arr = kzalloc(num_registrations * sizeof(*arr), GFP_KERNEL);
+		if (!arr)
+			return;  /* Keep the existing array */
+	} else
+		goto out_update;
+
+	list_for_each_entry(adapter, &adapter_list, list) {
+		for (k = 0; k < EHEA_MAX_PORTS; k++) {
+			struct ehea_port *port = adapter->port[k];
+
+			if (!port || (port->state != EHEA_PORT_UP))
+				continue;
+
+			arr[i].adh = adapter->handle;
+			arr[i].port_id = port->logical_port_id;
+			arr[i].reg_type = EHEA_BCMC_BROADCAST |
+					  EHEA_BCMC_UNTAGGED;
+			arr[i++].macaddr = port->mac_addr;
+
+			arr[i].adh = adapter->handle;
+			arr[i].port_id = port->logical_port_id;
+			arr[i].reg_type = EHEA_BCMC_BROADCAST |
+					  EHEA_BCMC_VLANID_ALL;
+			arr[i++].macaddr = port->mac_addr;
+
+			list_for_each_entry(mc_entry,
+					    &port->mc_list->list, list) {
+				arr[i].adh = adapter->handle;
+				arr[i].port_id = port->logical_port_id;
+				arr[i].reg_type = EHEA_BCMC_SCOPE_ALL |
+						  EHEA_BCMC_MULTICAST |
+						  EHEA_BCMC_UNTAGGED;
+				arr[i++].macaddr = mc_entry->macaddr;
+
+				arr[i].adh = adapter->handle;
+				arr[i].port_id = port->logical_port_id;
+				arr[i].reg_type = EHEA_BCMC_SCOPE_ALL |
+						  EHEA_BCMC_MULTICAST |
+						  EHEA_BCMC_VLANID_ALL;
+				arr[i++].macaddr = mc_entry->macaddr;
+			}
+		}
+	}
+
+out_update:
+	kfree(ehea_bcmc_regs.arr);
+	ehea_bcmc_regs.arr = arr;
+	ehea_bcmc_regs.num_entries = i;
+}
+
 static struct net_device_stats *ehea_get_stats(struct net_device *dev)
 {
 	struct ehea_port *port = netdev_priv(dev);
@@ -1601,19 +1758,25 @@ static int ehea_set_mac_addr(struct net_device *dev, void *sa)
 
 	memcpy(dev->dev_addr, mac_addr->sa_data, dev->addr_len);
 
+	down(&ehea_bcmc_regs.lock);
+
 	/* Deregister old MAC in pHYP */
 	ret = ehea_broadcast_reg_helper(port, H_DEREG_BCMC);
 	if (ret)
-		goto out_free;
+		goto out_upregs;
 
 	port->mac_addr = cb0->port_mac_addr << 16;
 
 	/* Register new MAC in pHYP */
 	ret = ehea_broadcast_reg_helper(port, H_REG_BCMC);
 	if (ret)
-		goto out_free;
+		goto out_upregs;
 
 	ret = 0;
+
+out_upregs:
+	ehea_update_bcmc_registrations();
+	up(&ehea_bcmc_regs.lock);
 out_free:
 	kfree(cb0);
 out:
@@ -1775,9 +1938,11 @@ static void ehea_set_multicast_list(struct net_device *dev)
 	}
 	ehea_promiscuous(dev, 0);
 
+	down(&ehea_bcmc_regs.lock);
+
 	if (dev->flags & IFF_ALLMULTI) {
 		ehea_allmulti(dev, 1);
-		return;
+		goto out;
 	}
 	ehea_allmulti(dev, 0);
 
@@ -1803,6 +1968,8 @@ static void ehea_set_multicast_list(struct net_device *dev)
 
 	}
 out:
+	ehea_update_bcmc_registrations();
+	up(&ehea_bcmc_regs.lock);
 	return;
 }
 
@@ -2285,6 +2452,8 @@ static int ehea_up(struct net_device *dev)
 	if (port->state == EHEA_PORT_UP)
 		return 0;
 
+	down(&ehea_fw_handles.lock);
+
 	ret = ehea_port_res_setup(port, port->num_def_qps,
 				  port->num_add_tx_qps);
 	if (ret) {
@@ -2321,8 +2490,17 @@ static int ehea_up(struct net_device *dev)
 		}
 	}
 
-	ret = 0;
+	down(&ehea_bcmc_regs.lock);
+
+	ret = ehea_broadcast_reg_helper(port, H_REG_BCMC);
+	if (ret) {
+		ret = -EIO;
+		goto out_free_irqs;
+	}
+
 	port->state = EHEA_PORT_UP;
+
+	ret = 0;
 	goto out;
 
 out_free_irqs:
@@ -2334,6 +2512,12 @@ out:
 	if (ret)
 		ehea_info("Failed starting %s. ret=%i", dev->name, ret);
 
+	ehea_update_bcmc_registrations();
+	up(&ehea_bcmc_regs.lock);
+
+	ehea_update_firmware_handles();
+	up(&ehea_fw_handles.lock);
+
 	return ret;
 }
 
@@ -2382,16 +2566,27 @@ static int ehea_down(struct net_device *dev)
 	if (port->state == EHEA_PORT_DOWN)
 		return 0;
 
+	down(&ehea_bcmc_regs.lock);
 	ehea_drop_multicast_list(dev);
+	ehea_broadcast_reg_helper(port, H_DEREG_BCMC);
+
 	ehea_free_interrupts(dev);
 
+	down(&ehea_fw_handles.lock);
+
 	port->state = EHEA_PORT_DOWN;
 
+	ehea_update_bcmc_registrations();
+	up(&ehea_bcmc_regs.lock);
+
 	ret = ehea_clean_all_portres(port);
 	if (ret)
 		ehea_info("Failed freeing resources for %s. ret=%i",
 			  dev->name, ret);
 
+	ehea_update_firmware_handles();
+	up(&ehea_fw_handles.lock);
+
 	return ret;
 }
 
@@ -2920,19 +3115,12 @@ struct ehea_port *ehea_setup_single_port(struct ehea_adapter *adapter,
 	dev->watchdog_timeo = EHEA_WATCH_DOG_TIMEOUT;
 
 	INIT_WORK(&port->reset_task, ehea_reset_port);
-
-	ret = ehea_broadcast_reg_helper(port, H_REG_BCMC);
-	if (ret) {
-		ret = -EIO;
-		goto out_unreg_port;
-	}
-
 	ehea_set_ethtool_ops(dev);
 
 	ret = register_netdev(dev);
 	if (ret) {
 		ehea_error("register_netdev failed. ret=%d", ret);
-		goto out_dereg_bc;
+		goto out_unreg_port;
 	}
 
 	port->lro_max_aggr = lro_max_aggr;
@@ -2949,9 +3137,6 @@ struct ehea_port *ehea_setup_single_port(struct ehea_adapter *adapter,
 
 	return port;
 
-out_dereg_bc:
-	ehea_broadcast_reg_helper(port, H_DEREG_BCMC);
-
 out_unreg_port:
 	ehea_unregister_port(port);
 
@@ -2971,7 +3156,6 @@ static void ehea_shutdown_single_port(struct ehea_port *port)
 {
 	unregister_netdev(port->netdev);
 	ehea_unregister_port(port);
-	ehea_broadcast_reg_helper(port, H_DEREG_BCMC);
 	kfree(port->mc_list);
 	free_netdev(port->netdev);
 	port->adapter->active_ports--;
@@ -3014,7 +3198,6 @@ static int ehea_setup_ports(struct ehea_adapter *adapter)
 
 		i++;
 	};
-
 	return 0;
 }
 
@@ -3159,6 +3342,7 @@ static int __devinit ehea_probe_adapter(struct of_device *dev,
 		ehea_error("Invalid ibmebus device probed");
 		return -EINVAL;
 	}
+	down(&ehea_fw_handles.lock);
 
 	adapter = kzalloc(sizeof(*adapter), GFP_KERNEL);
 	if (!adapter) {
@@ -3239,7 +3423,10 @@ out_kill_eq:
 
 out_free_ad:
 	kfree(adapter);
+
 out:
+	ehea_update_firmware_handles();
+	up(&ehea_fw_handles.lock);
 	return ret;
 }
 
@@ -3258,18 +3445,41 @@ static int __devexit ehea_remove(struct of_device *dev)
 
 	flush_scheduled_work();
 
+	down(&ehea_fw_handles.lock);
+
 	ibmebus_free_irq(adapter->neq->attr.ist1, adapter);
 	tasklet_kill(&adapter->neq_tasklet);
 
 	ehea_destroy_eq(adapter->neq);
 	ehea_remove_adapter_mr(adapter);
 	list_del(&adapter->list);
-
 	kfree(adapter);
 
+	ehea_update_firmware_handles();
+	up(&ehea_fw_handles.lock);
+
 	return 0;
 }
 
+void ehea_crash_handler(void)
+{
+	int i;
+
+	if (ehea_fw_handles.arr)
+		for (i = 0; i < ehea_fw_handles.num_entries; i++)
+			ehea_h_free_resource(ehea_fw_handles.arr[i].adh,
+					     ehea_fw_handles.arr[i].fwh,
+					     FORCE_FREE);
+
+	if (ehea_bcmc_regs.arr)
+		for (i = 0; i < ehea_bcmc_regs.num_entries; i++)
+			ehea_h_reg_dereg_bcmc(ehea_bcmc_regs.arr[i].adh,
+					      ehea_bcmc_regs.arr[i].port_id,
+					      ehea_bcmc_regs.arr[i].reg_type,
+					      ehea_bcmc_regs.arr[i].macaddr,
+					      0, H_DEREG_BCMC);
+}
+
 static int ehea_reboot_notifier(struct notifier_block *nb,
 				unsigned long action, void *unused)
 {
@@ -3330,7 +3540,12 @@ int __init ehea_module_init(void)
 
 
 	INIT_WORK(&ehea_rereg_mr_task, ehea_rereg_mrs);
+	memset(&ehea_fw_handles, 0, sizeof(ehea_fw_handles));
+	memset(&ehea_bcmc_regs, 0, sizeof(ehea_bcmc_regs));
+
 	sema_init(&dlpar_mem_lock, 1);
+	sema_init(&ehea_fw_handles.lock, 1);
+	sema_init(&ehea_bcmc_regs.lock, 1);
 
 	ret = check_module_parm();
 	if (ret)
@@ -3340,12 +3555,18 @@ int __init ehea_module_init(void)
 	if (ret)
 		goto out;
 
-	register_reboot_notifier(&ehea_reboot_nb);
+	ret = register_reboot_notifier(&ehea_reboot_nb);
+	if (ret)
+		ehea_info("failed registering reboot notifier");
+
+	ret = crash_shutdown_register(&ehea_crash_handler);
+	if (ret)
+		ehea_info("failed registering crash handler");
 
 	ret = ibmebus_register_driver(&ehea_driver);
 	if (ret) {
 		ehea_error("failed registering eHEA device driver on ebus");
-		goto out;
+		goto out2;
 	}
 
 	ret = driver_create_file(&ehea_driver.driver,
@@ -3353,21 +3574,33 @@ int __init ehea_module_init(void)
 	if (ret) {
 		ehea_error("failed to register capabilities attribute, ret=%d",
 			   ret);
-		unregister_reboot_notifier(&ehea_reboot_nb);
-		ibmebus_unregister_driver(&ehea_driver);
-		goto out;
+		goto out3;
 	}
 
+	return ret;
+
+out3:
+	ibmebus_unregister_driver(&ehea_driver);
+out2:
+	unregister_reboot_notifier(&ehea_reboot_nb);
+	crash_shutdown_unregister(&ehea_crash_handler);
 out:
 	return ret;
 }
 
 static void __exit ehea_module_exit(void)
 {
+	int ret;
+
 	flush_scheduled_work();
 	driver_remove_file(&ehea_driver.driver, &driver_attr_capabilities);
 	ibmebus_unregister_driver(&ehea_driver);
 	unregister_reboot_notifier(&ehea_reboot_nb);
+	ret = crash_shutdown_unregister(&ehea_crash_handler);
+	if (ret)
+		ehea_info("failed unregistering crash handler");
+	kfree(ehea_fw_handles.arr);
+	kfree(ehea_bcmc_regs.arr);
 	ehea_destroy_busmap();
 }
 
diff --git a/drivers/net/fs_enet/fs_enet-main.c b/drivers/net/fs_enet/fs_enet-main.c
index 42d94ed..af869cf 100644
--- a/drivers/net/fs_enet/fs_enet-main.c
+++ b/drivers/net/fs_enet/fs_enet-main.c
@@ -946,16 +946,11 @@ static int fs_ioctl(struct net_device *dev, struct ifreq *rq, int cmd)
 {
 	struct fs_enet_private *fep = netdev_priv(dev);
 	struct mii_ioctl_data *mii = (struct mii_ioctl_data *)&rq->ifr_data;
-	unsigned long flags;
-	int rc;
 
 	if (!netif_running(dev))
 		return -EINVAL;
 
-	spin_lock_irqsave(&fep->lock, flags);
-	rc = phy_mii_ioctl(fep->phydev, mii, cmd);
-	spin_unlock_irqrestore(&fep->lock, flags);
-	return rc;
+	return phy_mii_ioctl(fep->phydev, mii, cmd);
 }
 
 extern int fs_mii_connect(struct net_device *dev);
diff --git a/drivers/net/gianfar.c b/drivers/net/gianfar.c
index 4244fc2..718cf77 100644
--- a/drivers/net/gianfar.c
+++ b/drivers/net/gianfar.c
@@ -605,7 +605,7 @@ void stop_gfar(struct net_device *dev)
 
 	free_skb_resources(priv);
 
-	dma_free_coherent(NULL,
+	dma_free_coherent(&dev->dev,
 			sizeof(struct txbd8)*priv->tx_ring_size
 			+ sizeof(struct rxbd8)*priv->rx_ring_size,
 			priv->tx_bd_base,
@@ -626,7 +626,7 @@ static void free_skb_resources(struct gfar_private *priv)
 	for (i = 0; i < priv->tx_ring_size; i++) {
 
 		if (priv->tx_skbuff[i]) {
-			dma_unmap_single(NULL, txbdp->bufPtr,
+			dma_unmap_single(&priv->dev->dev, txbdp->bufPtr,
 					txbdp->length,
 					DMA_TO_DEVICE);
 			dev_kfree_skb_any(priv->tx_skbuff[i]);
@@ -643,7 +643,7 @@ static void free_skb_resources(struct gfar_private *priv)
 	if(priv->rx_skbuff != NULL) {
 		for (i = 0; i < priv->rx_ring_size; i++) {
 			if (priv->rx_skbuff[i]) {
-				dma_unmap_single(NULL, rxbdp->bufPtr,
+				dma_unmap_single(&priv->dev->dev, rxbdp->bufPtr,
 						priv->rx_buffer_size,
 						DMA_FROM_DEVICE);
 
@@ -708,7 +708,7 @@ int startup_gfar(struct net_device *dev)
 	gfar_write(&regs->imask, IMASK_INIT_CLEAR);
 
 	/* Allocate memory for the buffer descriptors */
-	vaddr = (unsigned long) dma_alloc_coherent(NULL,
+	vaddr = (unsigned long) dma_alloc_coherent(&dev->dev,
 			sizeof (struct txbd8) * priv->tx_ring_size +
 			sizeof (struct rxbd8) * priv->rx_ring_size,
 			&addr, GFP_KERNEL);
@@ -919,7 +919,7 @@ err_irq_fail:
 rx_skb_fail:
 	free_skb_resources(priv);
 tx_skb_fail:
-	dma_free_coherent(NULL,
+	dma_free_coherent(&dev->dev,
 			sizeof(struct txbd8)*priv->tx_ring_size
 			+ sizeof(struct rxbd8)*priv->rx_ring_size,
 			priv->tx_bd_base,
@@ -1053,7 +1053,7 @@ static int gfar_start_xmit(struct sk_buff *skb, struct net_device *dev)
 
 	/* Set buffer length and pointer */
 	txbdp->length = skb->len;
-	txbdp->bufPtr = dma_map_single(NULL, skb->data,
+	txbdp->bufPtr = dma_map_single(&dev->dev, skb->data,
 			skb->len, DMA_TO_DEVICE);
 
 	/* Save the skb pointer so we can free it later */
@@ -1332,7 +1332,7 @@ struct sk_buff * gfar_new_skb(struct net_device *dev, struct rxbd8 *bdp)
 	 */
 	skb_reserve(skb, alignamount);
 
-	bdp->bufPtr = dma_map_single(NULL, skb->data,
+	bdp->bufPtr = dma_map_single(&dev->dev, skb->data,
 			priv->rx_buffer_size, DMA_FROM_DEVICE);
 
 	bdp->length = 0;
diff --git a/drivers/net/igb/igb_main.c b/drivers/net/igb/igb_main.c
index bff280e..6a1f230 100644
--- a/drivers/net/igb/igb_main.c
+++ b/drivers/net/igb/igb_main.c
@@ -439,7 +439,7 @@ static int igb_request_irq(struct igb_adapter *adapter)
 		err = igb_request_msix(adapter);
 		if (!err) {
 			/* enable IAM, auto-mask,
-			 * DO NOT USE EIAME or IAME in legacy mode */
+			 * DO NOT USE EIAM or IAM in legacy mode */
 			wr32(E1000_IAM, IMS_ENABLE_MASK);
 			goto request_done;
 		}
@@ -465,14 +465,9 @@ static int igb_request_irq(struct igb_adapter *adapter)
 	err = request_irq(adapter->pdev->irq, &igb_intr, IRQF_SHARED,
 			  netdev->name, netdev);
 
-	if (err) {
+	if (err)
 		dev_err(&adapter->pdev->dev, "Error %d getting interrupt\n",
 			err);
-		goto request_done;
-	}
-
-	/* enable IAM, auto-mask */
-	wr32(E1000_IAM, IMS_ENABLE_MASK);
 
 request_done:
 	return err;
@@ -821,7 +816,8 @@ void igb_reset(struct igb_adapter *adapter)
 	wr32(E1000_VET, ETHERNET_IEEE_VLAN_TYPE);
 
 	igb_reset_adaptive(&adapter->hw);
-	adapter->hw.phy.ops.get_phy_info(&adapter->hw);
+	if (adapter->hw.phy.ops.get_phy_info)
+		adapter->hw.phy.ops.get_phy_info(&adapter->hw);
 }
 
 /**
@@ -2057,7 +2053,8 @@ static void igb_set_multi(struct net_device *netdev)
 static void igb_update_phy_info(unsigned long data)
 {
 	struct igb_adapter *adapter = (struct igb_adapter *) data;
-	adapter->hw.phy.ops.get_phy_info(&adapter->hw);
+	if (adapter->hw.phy.ops.get_phy_info)
+		adapter->hw.phy.ops.get_phy_info(&adapter->hw);
 }
 
 /**
diff --git a/drivers/net/pcmcia/pcnet_cs.c b/drivers/net/pcmcia/pcnet_cs.c
index 6323988..c1a4139 100644
--- a/drivers/net/pcmcia/pcnet_cs.c
+++ b/drivers/net/pcmcia/pcnet_cs.c
@@ -590,6 +590,13 @@ static int pcnet_config(struct pcmcia_device *link)
 	dev->if_port = 0;
     }
 
+    if ((link->conf.ConfigBase == 0x03c0) 
+	&& (link->manf_id == 0x149) && (link->card_id = 0xc1ab)) {
+    	printk(KERN_INFO "pcnet_cs: this is an AX88190 card!\n");
+    	printk(KERN_INFO "pcnet_cs: use axnet_cs instead.\n");
+	goto failed;
+    }
+
     local_hw_info = get_hwinfo(link);
     if (local_hw_info == NULL)
 	local_hw_info = get_prom(link);
@@ -1567,12 +1574,11 @@ static struct pcmcia_device_id pcnet_ids[] = {
 	PCMCIA_DEVICE_MANF_CARD(0x0104, 0x0145),
 	PCMCIA_DEVICE_MANF_CARD(0x0149, 0x0230),
 	PCMCIA_DEVICE_MANF_CARD(0x0149, 0x4530),
-/*	PCMCIA_DEVICE_MANF_CARD(0x0149, 0xc1ab), conflict with axnet_cs */
+	PCMCIA_DEVICE_MANF_CARD(0x0149, 0xc1ab), 
 	PCMCIA_DEVICE_MANF_CARD(0x0186, 0x0110),
 	PCMCIA_DEVICE_MANF_CARD(0x01bf, 0x2328),
 	PCMCIA_DEVICE_MANF_CARD(0x01bf, 0x8041),
 	PCMCIA_DEVICE_MANF_CARD(0x0213, 0x2452),
-/*	PCMCIA_DEVICE_MANF_CARD(0x021b, 0x0202), conflict with axnet_cs */
 	PCMCIA_DEVICE_MANF_CARD(0x026f, 0x0300),
 	PCMCIA_DEVICE_MANF_CARD(0x026f, 0x0307),
 	PCMCIA_DEVICE_MANF_CARD(0x026f, 0x030a),
diff --git a/drivers/net/phy/mdio_bus.c b/drivers/net/phy/mdio_bus.c
index 6e9f619..963630c 100644
--- a/drivers/net/phy/mdio_bus.c
+++ b/drivers/net/phy/mdio_bus.c
@@ -49,13 +49,13 @@ int mdiobus_register(struct mii_bus *bus)
 	int i;
 	int err = 0;
 
-	mutex_init(&bus->mdio_lock);
-
 	if (NULL == bus || NULL == bus->name ||
 			NULL == bus->read ||
 			NULL == bus->write)
 		return -EINVAL;
 
+	mutex_init(&bus->mdio_lock);
+
 	if (bus->reset)
 		bus->reset(bus);
 
diff --git a/drivers/net/sis190.c b/drivers/net/sis190.c
index 202fdf3..20745fd 100644
--- a/drivers/net/sis190.c
+++ b/drivers/net/sis190.c
@@ -1633,13 +1633,18 @@ static inline void sis190_init_rxfilter(struct net_device *dev)
 static int __devinit sis190_get_mac_addr(struct pci_dev *pdev, 
 					 struct net_device *dev)
 {
-	u8 from;
+	int rc;
+
+	rc = sis190_get_mac_addr_from_eeprom(pdev, dev);
+	if (rc < 0) {
+		u8 reg;
 
-	pci_read_config_byte(pdev, 0x73, &from);
+		pci_read_config_byte(pdev, 0x73, &reg);
 
-	return (from & 0x00000001) ?
-		sis190_get_mac_addr_from_apc(pdev, dev) :
-		sis190_get_mac_addr_from_eeprom(pdev, dev);
+		if (reg & 0x00000001)
+			rc = sis190_get_mac_addr_from_apc(pdev, dev);
+	}
+	return rc;
 }
 
 static void sis190_set_speed_auto(struct net_device *dev)
diff --git a/drivers/net/tlan.c b/drivers/net/tlan.c
index 3af5b92..0166407 100644
--- a/drivers/net/tlan.c
+++ b/drivers/net/tlan.c
@@ -1400,7 +1400,7 @@ static void TLan_SetMulticastList( struct net_device *dev )
 	 *
 	 **************************************************************/
 
-u32 TLan_HandleInvalid( struct net_device *dev, u16 host_int )
+static u32 TLan_HandleInvalid( struct net_device *dev, u16 host_int )
 {
 	/* printk( "TLAN:  Invalid interrupt on %s.\n", dev->name ); */
 	return 0;
@@ -1432,7 +1432,7 @@ u32 TLan_HandleInvalid( struct net_device *dev, u16 host_int )
 	 *
 	 **************************************************************/
 
-u32 TLan_HandleTxEOF( struct net_device *dev, u16 host_int )
+static u32 TLan_HandleTxEOF( struct net_device *dev, u16 host_int )
 {
 	TLanPrivateInfo	*priv = netdev_priv(dev);
 	int		eoc = 0;
@@ -1518,7 +1518,7 @@ u32 TLan_HandleTxEOF( struct net_device *dev, u16 host_int )
 	 *
 	 **************************************************************/
 
-u32 TLan_HandleStatOverflow( struct net_device *dev, u16 host_int )
+static u32 TLan_HandleStatOverflow( struct net_device *dev, u16 host_int )
 {
 	TLan_ReadAndClearStats( dev, TLAN_RECORD );
 
@@ -1554,7 +1554,7 @@ u32 TLan_HandleStatOverflow( struct net_device *dev, u16 host_int )
 	 *
 	 **************************************************************/
 
-u32 TLan_HandleRxEOF( struct net_device *dev, u16 host_int )
+static u32 TLan_HandleRxEOF( struct net_device *dev, u16 host_int )
 {
 	TLanPrivateInfo	*priv = netdev_priv(dev);
 	u32		ack = 0;
@@ -1689,7 +1689,7 @@ u32 TLan_HandleRxEOF( struct net_device *dev, u16 host_int )
 	 *
 	 **************************************************************/
 
-u32 TLan_HandleDummy( struct net_device *dev, u16 host_int )
+static u32 TLan_HandleDummy( struct net_device *dev, u16 host_int )
 {
 	printk( "TLAN:  Test interrupt on %s.\n", dev->name );
 	return 1;
@@ -1719,7 +1719,7 @@ u32 TLan_HandleDummy( struct net_device *dev, u16 host_int )
 	 *
 	 **************************************************************/
 
-u32 TLan_HandleTxEOC( struct net_device *dev, u16 host_int )
+static u32 TLan_HandleTxEOC( struct net_device *dev, u16 host_int )
 {
 	TLanPrivateInfo	*priv = netdev_priv(dev);
 	TLanList		*head_list;
@@ -1767,7 +1767,7 @@ u32 TLan_HandleTxEOC( struct net_device *dev, u16 host_int )
 	 *
 	 **************************************************************/
 
-u32 TLan_HandleStatusCheck( struct net_device *dev, u16 host_int )
+static u32 TLan_HandleStatusCheck( struct net_device *dev, u16 host_int )
 {
 	TLanPrivateInfo	*priv = netdev_priv(dev);
 	u32		ack;
@@ -1842,7 +1842,7 @@ u32 TLan_HandleStatusCheck( struct net_device *dev, u16 host_int )
 	 *
 	 **************************************************************/
 
-u32 TLan_HandleRxEOC( struct net_device *dev, u16 host_int )
+static u32 TLan_HandleRxEOC( struct net_device *dev, u16 host_int )
 {
 	TLanPrivateInfo	*priv = netdev_priv(dev);
 	dma_addr_t	head_list_phys;
@@ -1902,7 +1902,7 @@ u32 TLan_HandleRxEOC( struct net_device *dev, u16 host_int )
 	 *
 	 **************************************************************/
 
-void TLan_Timer( unsigned long data )
+static void TLan_Timer( unsigned long data )
 {
 	struct net_device	*dev = (struct net_device *) data;
 	TLanPrivateInfo	*priv = netdev_priv(dev);
@@ -1983,7 +1983,7 @@ void TLan_Timer( unsigned long data )
 	 *
 	 **************************************************************/
 
-void TLan_ResetLists( struct net_device *dev )
+static void TLan_ResetLists( struct net_device *dev )
 {
 	TLanPrivateInfo *priv = netdev_priv(dev);
 	int		i;
@@ -2043,7 +2043,7 @@ void TLan_ResetLists( struct net_device *dev )
 } /* TLan_ResetLists */
 
 
-void TLan_FreeLists( struct net_device *dev )
+static void TLan_FreeLists( struct net_device *dev )
 {
 	TLanPrivateInfo *priv = netdev_priv(dev);
 	int		i;
@@ -2092,7 +2092,7 @@ void TLan_FreeLists( struct net_device *dev )
 	 *
 	 **************************************************************/
 
-void TLan_PrintDio( u16 io_base )
+static void TLan_PrintDio( u16 io_base )
 {
 	u32 data0, data1;
 	int	i;
@@ -2127,7 +2127,7 @@ void TLan_PrintDio( u16 io_base )
 	 *
 	 **************************************************************/
 
-void TLan_PrintList( TLanList *list, char *type, int num)
+static void TLan_PrintList( TLanList *list, char *type, int num)
 {
 	int i;
 
@@ -2163,7 +2163,7 @@ void TLan_PrintList( TLanList *list, char *type, int num)
 	 *
 	 **************************************************************/
 
-void TLan_ReadAndClearStats( struct net_device *dev, int record )
+static void TLan_ReadAndClearStats( struct net_device *dev, int record )
 {
 	TLanPrivateInfo	*priv = netdev_priv(dev);
 	u32		tx_good, tx_under;
@@ -2238,7 +2238,7 @@ void TLan_ReadAndClearStats( struct net_device *dev, int record )
 	 *
 	 **************************************************************/
 
-void
+static void
 TLan_ResetAdapter( struct net_device *dev )
 {
 	TLanPrivateInfo	*priv = netdev_priv(dev);
@@ -2324,7 +2324,7 @@ TLan_ResetAdapter( struct net_device *dev )
 
 
 
-void
+static void
 TLan_FinishReset( struct net_device *dev )
 {
 	TLanPrivateInfo	*priv = netdev_priv(dev);
@@ -2448,7 +2448,7 @@ TLan_FinishReset( struct net_device *dev )
 	 *
 	 **************************************************************/
 
-void TLan_SetMac( struct net_device *dev, int areg, char *mac )
+static void TLan_SetMac( struct net_device *dev, int areg, char *mac )
 {
 	int i;
 
@@ -2490,7 +2490,7 @@ void TLan_SetMac( struct net_device *dev, int areg, char *mac )
 	 *
 	 ********************************************************************/
 
-void TLan_PhyPrint( struct net_device *dev )
+static void TLan_PhyPrint( struct net_device *dev )
 {
 	TLanPrivateInfo *priv = netdev_priv(dev);
 	u16 i, data0, data1, data2, data3, phy;
@@ -2539,7 +2539,7 @@ void TLan_PhyPrint( struct net_device *dev )
 	 *
 	 ********************************************************************/
 
-void TLan_PhyDetect( struct net_device *dev )
+static void TLan_PhyDetect( struct net_device *dev )
 {
 	TLanPrivateInfo *priv = netdev_priv(dev);
 	u16		control;
@@ -2586,7 +2586,7 @@ void TLan_PhyDetect( struct net_device *dev )
 
 
 
-void TLan_PhyPowerDown( struct net_device *dev )
+static void TLan_PhyPowerDown( struct net_device *dev )
 {
 	TLanPrivateInfo	*priv = netdev_priv(dev);
 	u16		value;
@@ -2611,7 +2611,7 @@ void TLan_PhyPowerDown( struct net_device *dev )
 
 
 
-void TLan_PhyPowerUp( struct net_device *dev )
+static void TLan_PhyPowerUp( struct net_device *dev )
 {
 	TLanPrivateInfo	*priv = netdev_priv(dev);
 	u16		value;
@@ -2632,7 +2632,7 @@ void TLan_PhyPowerUp( struct net_device *dev )
 
 
 
-void TLan_PhyReset( struct net_device *dev )
+static void TLan_PhyReset( struct net_device *dev )
 {
 	TLanPrivateInfo	*priv = netdev_priv(dev);
 	u16		phy;
@@ -2660,7 +2660,7 @@ void TLan_PhyReset( struct net_device *dev )
 
 
 
-void TLan_PhyStartLink( struct net_device *dev )
+static void TLan_PhyStartLink( struct net_device *dev )
 {
 	TLanPrivateInfo	*priv = netdev_priv(dev);
 	u16		ability;
@@ -2747,7 +2747,7 @@ void TLan_PhyStartLink( struct net_device *dev )
 
 
 
-void TLan_PhyFinishAutoNeg( struct net_device *dev )
+static void TLan_PhyFinishAutoNeg( struct net_device *dev )
 {
 	TLanPrivateInfo	*priv = netdev_priv(dev);
 	u16		an_adv;
@@ -2903,7 +2903,7 @@ void TLan_PhyMonitor( struct net_device *dev )
 	 *
 	 **************************************************************/
 
-int TLan_MiiReadReg( struct net_device *dev, u16 phy, u16 reg, u16 *val )
+static int TLan_MiiReadReg( struct net_device *dev, u16 phy, u16 reg, u16 *val )
 {
 	u8	nack;
 	u16	sio, tmp;
@@ -2993,7 +2993,7 @@ int TLan_MiiReadReg( struct net_device *dev, u16 phy, u16 reg, u16 *val )
 	 *
 	 **************************************************************/
 
-void TLan_MiiSendData( u16 base_port, u32 data, unsigned num_bits )
+static void TLan_MiiSendData( u16 base_port, u32 data, unsigned num_bits )
 {
 	u16 sio;
 	u32 i;
@@ -3035,7 +3035,7 @@ void TLan_MiiSendData( u16 base_port, u32 data, unsigned num_bits )
 	 *
 	 **************************************************************/
 
-void TLan_MiiSync( u16 base_port )
+static void TLan_MiiSync( u16 base_port )
 {
 	int i;
 	u16 sio;
@@ -3074,7 +3074,7 @@ void TLan_MiiSync( u16 base_port )
 	 *
 	 **************************************************************/
 
-void TLan_MiiWriteReg( struct net_device *dev, u16 phy, u16 reg, u16 val )
+static void TLan_MiiWriteReg( struct net_device *dev, u16 phy, u16 reg, u16 val )
 {
 	u16	sio;
 	int	minten;
@@ -3144,7 +3144,7 @@ void TLan_MiiWriteReg( struct net_device *dev, u16 phy, u16 reg, u16 val )
 	 *
 	 **************************************************************/
 
-void TLan_EeSendStart( u16 io_base )
+static void TLan_EeSendStart( u16 io_base )
 {
 	u16	sio;
 
@@ -3184,7 +3184,7 @@ void TLan_EeSendStart( u16 io_base )
 	 *
 	 **************************************************************/
 
-int TLan_EeSendByte( u16 io_base, u8 data, int stop )
+static int TLan_EeSendByte( u16 io_base, u8 data, int stop )
 {
 	int	err;
 	u8	place;
@@ -3245,7 +3245,7 @@ int TLan_EeSendByte( u16 io_base, u8 data, int stop )
 	 *
 	 **************************************************************/
 
-void TLan_EeReceiveByte( u16 io_base, u8 *data, int stop )
+static void TLan_EeReceiveByte( u16 io_base, u8 *data, int stop )
 {
 	u8  place;
 	u16 sio;
@@ -3303,7 +3303,7 @@ void TLan_EeReceiveByte( u16 io_base, u8 *data, int stop )
 	 *
 	 **************************************************************/
 
-int TLan_EeReadByte( struct net_device *dev, u8 ee_addr, u8 *data )
+static int TLan_EeReadByte( struct net_device *dev, u8 ee_addr, u8 *data )
 {
 	int err;
 	TLanPrivateInfo *priv = netdev_priv(dev);
diff --git a/drivers/net/tulip/uli526x.c b/drivers/net/tulip/uli526x.c
index a7afeea..a59c1f2 100644
--- a/drivers/net/tulip/uli526x.c
+++ b/drivers/net/tulip/uli526x.c
@@ -482,9 +482,11 @@ static void uli526x_init(struct net_device *dev)
 	struct uli526x_board_info *db = netdev_priv(dev);
 	unsigned long ioaddr = db->ioaddr;
 	u8	phy_tmp;
+	u8	timeout;
 	u16	phy_value;
 	u16 phy_reg_reset;
 
+
 	ULI526X_DBUG(0, "uli526x_init()", 0);
 
 	/* Reset M526x MAC controller */
@@ -509,11 +511,19 @@ static void uli526x_init(struct net_device *dev)
 	/* Parser SROM and media mode */
 	db->media_mode = uli526x_media_mode;
 
-	/* Phyxcer capability setting */
+	/* phyxcer capability setting */
 	phy_reg_reset = phy_read(db->ioaddr, db->phy_addr, 0, db->chip_id);
 	phy_reg_reset = (phy_reg_reset | 0x8000);
 	phy_write(db->ioaddr, db->phy_addr, 0, phy_reg_reset, db->chip_id);
+
+	/* See IEEE 802.3-2002.pdf (Section 2, Chapter "22.2.4 Management
+	 * functions") or phy data sheet for details on phy reset
+	 */
 	udelay(500);
+	timeout = 10;
+	while (timeout-- &&
+		phy_read(db->ioaddr, db->phy_addr, 0, db->chip_id) & 0x8000)
+			udelay(100);
 
 	/* Process Phyxcer Media Mode */
 	uli526x_set_phyxcer(db);
diff --git a/drivers/net/virtio_net.c b/drivers/net/virtio_net.c
index fdc2367..19fd4cb 100644
--- a/drivers/net/virtio_net.c
+++ b/drivers/net/virtio_net.c
@@ -361,6 +361,7 @@ static int virtnet_probe(struct virtio_device *vdev)
 	netif_napi_add(dev, &vi->napi, virtnet_poll, napi_weight);
 	vi->dev = dev;
 	vi->vdev = vdev;
+	vdev->priv = vi;
 
 	/* We expect two virtqueues, receive then send. */
 	vi->rvq = vdev->config->find_vq(vdev, 0, skb_recv_done);
@@ -395,7 +396,6 @@ static int virtnet_probe(struct virtio_device *vdev)
 	}
 
 	pr_debug("virtnet: registered device %s\n", dev->name);
-	vdev->priv = vi;
 	return 0;
 
 unregister:
diff --git a/drivers/s390/net/claw.c b/drivers/s390/net/claw.c
index c307621..d8a5c22 100644
--- a/drivers/s390/net/claw.c
+++ b/drivers/s390/net/claw.c
@@ -1851,8 +1851,7 @@ claw_hw_tx(struct sk_buff *skb, struct net_device *dev, long linkid)
                 }
         }
         /*      See how many write buffers are required to hold this data */
-        numBuffers= ( skb->len + privptr->p_env->write_size - 1) /
-			( privptr->p_env->write_size);
+	numBuffers = DIV_ROUND_UP(skb->len, privptr->p_env->write_size);
 
         /*      If that number of buffers isn't available, give up for now */
         if (privptr->write_free_count < numBuffers ||
@@ -2114,8 +2113,7 @@ init_ccw_bk(struct net_device *dev)
         */
         ccw_blocks_perpage= PAGE_SIZE /  CCWBK_SIZE;
         ccw_pages_required=
-		(ccw_blocks_required+ccw_blocks_perpage -1) /
-			 ccw_blocks_perpage;
+		DIV_ROUND_UP(ccw_blocks_required, ccw_blocks_perpage);
 
 #ifdef DEBUGMSG
         printk(KERN_INFO "%s: %s() > ccw_blocks_perpage=%d\n",
@@ -2131,30 +2129,29 @@ init_ccw_bk(struct net_device *dev)
 	 * provide good performance. With packing buffers support 32k
 	 * buffers are used.
          */
-        if (privptr->p_env->read_size < PAGE_SIZE) {
-            claw_reads_perpage= PAGE_SIZE / privptr->p_env->read_size;
-            claw_read_pages= (privptr->p_env->read_buffers +
-	    	claw_reads_perpage -1) / claw_reads_perpage;
+	if (privptr->p_env->read_size < PAGE_SIZE) {
+		claw_reads_perpage = PAGE_SIZE / privptr->p_env->read_size;
+		claw_read_pages = DIV_ROUND_UP(privptr->p_env->read_buffers,
+						claw_reads_perpage);
          }
          else {       /* > or equal  */
-            privptr->p_buff_pages_perread=
-	    	(privptr->p_env->read_size + PAGE_SIZE - 1) / PAGE_SIZE;
-            claw_read_pages=
-	    	privptr->p_env->read_buffers * privptr->p_buff_pages_perread;
+		privptr->p_buff_pages_perread =
+			DIV_ROUND_UP(privptr->p_env->read_size, PAGE_SIZE);
+		claw_read_pages = privptr->p_env->read_buffers *
+					privptr->p_buff_pages_perread;
          }
         if (privptr->p_env->write_size < PAGE_SIZE) {
-            claw_writes_perpage=
-	    	PAGE_SIZE / privptr->p_env->write_size;
-            claw_write_pages=
-	    	(privptr->p_env->write_buffers + claw_writes_perpage -1) /
-			claw_writes_perpage;
+		claw_writes_perpage =
+			PAGE_SIZE / privptr->p_env->write_size;
+		claw_write_pages = DIV_ROUND_UP(privptr->p_env->write_buffers,
+						claw_writes_perpage);
 
         }
         else {      /* >  or equal  */
-            privptr->p_buff_pages_perwrite=
-	    	 (privptr->p_env->read_size + PAGE_SIZE - 1) / PAGE_SIZE;
-            claw_write_pages=
-	     	privptr->p_env->write_buffers * privptr->p_buff_pages_perwrite;
+		privptr->p_buff_pages_perwrite =
+			DIV_ROUND_UP(privptr->p_env->read_size, PAGE_SIZE);
+		claw_write_pages = privptr->p_env->write_buffers *
+					privptr->p_buff_pages_perwrite;
         }
 #ifdef DEBUGMSG
         if (privptr->p_env->read_size < PAGE_SIZE) {
