From: Jeff Garzik <jeff@garzik.org>
Subject: [git patches] net driver fixes
Date: Tue, 23 Jan 2007 02:12:39 -0500
Message-ID: <20070123071239.GA25717@havoc.gtf.org>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: netdev@vger.kernel.org, LKML <linux-kernel@vger.kernel.org>
Return-path: <linux-kernel-owner+glk-linux-kernel-3=40m.gmane.org-S932839AbXAWHMm@vger.kernel.org>
To: Andrew Morton <akpm@osdl.org>, Linus Torvalds <torvalds@osdl.org>
Content-Disposition: inline
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org


Please pull from 'upstream-linus' branch of
master.kernel.org:/pub/scm/linux/kernel/git/jgarzik/netdev-2.6.git upstream-linus

to receive the following updates:

 drivers/net/ehea/ehea.h              |    2 +-
 drivers/net/ehea/ehea_main.c         |   56 +++++++++++++++++++++-------------
 drivers/net/ehea/ehea_phyp.c         |   10 +++++-
 drivers/net/netxen/netxen_nic.h      |    7 ++--
 drivers/net/netxen/netxen_nic_hw.c   |    3 +-
 drivers/net/netxen/netxen_nic_main.c |    2 +-
 drivers/net/pcmcia/3c589_cs.c        |    7 +++-
 drivers/net/phy/phy.c                |    3 +-
 8 files changed, 57 insertions(+), 33 deletions(-)

Amit S. Kale (2):
      NetXen: Firmware check modifications
      NetXen: Use pci_register_driver() instead of pci_module_init() in init_module

Komuro (1):
      modify 3c589_cs to be SMP safe

Kumar Gala (1):
      PHY: Export phy ethtool helpers

Thomas Klein (7):
      ehea: Fixed wrong dereferencation
      ehea: Fixing firmware queue config issue
      ehea: Modified initial autoneg state determination
      ehea: New method to determine number of available ports
      ehea: Improved logging of permission issues
      ehea: Added logging off associated errors
      ehea: Fixed possible nullpointer access

diff --git a/drivers/net/ehea/ehea.h b/drivers/net/ehea/ehea.h
index 39ad9f7..be10a3a 100644
--- a/drivers/net/ehea/ehea.h
+++ b/drivers/net/ehea/ehea.h
@@ -39,7 +39,7 @@
 #include <asm/io.h>
 
 #define DRV_NAME	"ehea"
-#define DRV_VERSION	"EHEA_0043"
+#define DRV_VERSION	"EHEA_0044"
 
 #define EHEA_MSG_DEFAULT (NETIF_MSG_LINK | NETIF_MSG_TIMER \
 	| NETIF_MSG_RX_ERR | NETIF_MSG_TX_ERR)
diff --git a/drivers/net/ehea/ehea_main.c b/drivers/net/ehea/ehea_main.c
index 83fa32f..1072e69 100644
--- a/drivers/net/ehea/ehea_main.c
+++ b/drivers/net/ehea/ehea_main.c
@@ -558,12 +558,12 @@ static irqreturn_t ehea_qp_aff_irq_handler(int irq, void *param)
 	u32 qp_token;
 
 	eqe = ehea_poll_eq(port->qp_eq);
-	ehea_debug("eqe=%p", eqe);
+
 	while (eqe) {
-		ehea_debug("*eqe=%lx", *(u64*)eqe);
-		eqe = ehea_poll_eq(port->qp_eq);
 		qp_token = EHEA_BMASK_GET(EHEA_EQE_QP_TOKEN, eqe->entry);
-		ehea_debug("next eqe=%p", eqe);
+		ehea_error("QP aff_err: entry=0x%lx, token=0x%x",
+			   eqe->entry, qp_token);
+		eqe = ehea_poll_eq(port->qp_eq);
 	}
 
 	return IRQ_HANDLED;
@@ -575,8 +575,9 @@ static struct ehea_port *ehea_get_port(struct ehea_adapter *adapter,
 	int i;
 
 	for (i = 0; i < adapter->num_ports; i++)
-		if (adapter->port[i]->logical_port_id == logical_port)
-			return adapter->port[i];
+		if (adapter->port[i])
+	                if (adapter->port[i]->logical_port_id == logical_port)
+				return adapter->port[i];
 	return NULL;
 }
 
@@ -642,6 +643,8 @@ int ehea_sense_port_attr(struct ehea_port *port)
 		break;
 	}
 
+	port->autoneg = 1;
+
 	/* Number of default QPs */
 	port->num_def_qps = cb0->num_default_qps;
 
@@ -728,10 +731,7 @@ int ehea_set_portspeed(struct ehea_port *port, u32 port_speed)
 		}
 	} else {
 		if (hret == H_AUTHORITY) {
-			ehea_info("Hypervisor denied setting port speed. Either"
-				  " this partition is not authorized to set "
-				  "port speed or another partition has modified"
-				  " port speed first.");
+			ehea_info("Hypervisor denied setting port speed");
 			ret = -EPERM;
 		} else {
 			ret = -EIO;
@@ -998,7 +998,7 @@ static int ehea_configure_port(struct ehea_port *port)
 		     | EHEA_BMASK_SET(PXLY_RC_JUMBO_FRAME, 1);
 
 	for (i = 0; i < port->num_def_qps; i++)
-		cb0->default_qpn_arr[i] = port->port_res[i].qp->init_attr.qp_nr;
+		cb0->default_qpn_arr[i] = port->port_res[0].qp->init_attr.qp_nr;
 
 	if (netif_msg_ifup(port))
 		ehea_dump(cb0, sizeof(*cb0), "ehea_configure_port");
@@ -1485,11 +1485,12 @@ out:
 
 static void ehea_promiscuous_error(u64 hret, int enable)
 {
-	ehea_info("Hypervisor denied %sabling promiscuous mode.%s",
-		  enable == 1 ? "en" : "dis",
-		  hret != H_AUTHORITY ? "" : " Another partition owning a "
-		  "logical port on the same physical port might have altered "
-		  "promiscuous mode first.");
+	if (hret == H_AUTHORITY)
+		ehea_info("Hypervisor denied %sabling promiscuous mode",
+			  enable == 1 ? "en" : "dis");
+	else
+		ehea_error("failed %sabling promiscuous mode",
+			   enable == 1 ? "en" : "dis");
 }
 
 static void ehea_promiscuous(struct net_device *dev, int enable)
@@ -2267,6 +2268,8 @@ static void ehea_tx_watchdog(struct net_device *dev)
 int ehea_sense_adapter_attr(struct ehea_adapter *adapter)
 {
 	struct hcp_query_ehea *cb;
+	struct device_node *lhea_dn = NULL;
+	struct device_node *eth_dn = NULL;
 	u64 hret;
 	int ret;
 
@@ -2283,7 +2286,18 @@ int ehea_sense_adapter_attr(struct ehea_adapter *adapter)
 		goto out_herr;
 	}
 
-	adapter->num_ports = cb->num_ports;
+	/* Determine the number of available logical ports
+	 * by counting the child nodes of the lhea OFDT entry
+	 */
+	adapter->num_ports = 0;
+	lhea_dn = of_find_node_by_name(lhea_dn, "lhea");
+	do {
+		eth_dn = of_get_next_child(lhea_dn, eth_dn);
+		if (eth_dn)
+			adapter->num_ports++;
+	} while ( eth_dn );
+	of_node_put(lhea_dn);
+
 	adapter->max_mc_mac = cb->max_mc_mac - 1;
 	ret = 0;
 
@@ -2334,8 +2348,6 @@ static int ehea_setup_single_port(struct ehea_port *port,
 
 	INIT_LIST_HEAD(&port->mc_list->list);
 
-	ehea_set_portspeed(port, EHEA_SPEED_AUTONEG);
-
 	ret = ehea_sense_port_attr(port);
 	if (ret)
 		goto out;
@@ -2471,14 +2483,16 @@ static int __devinit ehea_probe(struct ibmebus_dev *dev,
 
 	adapter_handle = (u64*)get_property(dev->ofdev.node, "ibm,hea-handle",
 					    NULL);
-	if (!adapter_handle) {
+	if (adapter_handle)
+		adapter->handle = *adapter_handle;
+
+	if (!adapter->handle) {
 		dev_err(&dev->ofdev.dev, "failed getting handle for adapter"
 			" '%s'\n", dev->ofdev.node->full_name);
 		ret = -ENODEV;
 		goto out_free_ad;
 	}
 
-	adapter->handle = *adapter_handle;
 	adapter->pd = EHEA_PD_ID;
 
 	dev->ofdev.dev.driver_data = adapter;
diff --git a/drivers/net/ehea/ehea_phyp.c b/drivers/net/ehea/ehea_phyp.c
index 0cfc2bc..37716e0 100644
--- a/drivers/net/ehea/ehea_phyp.c
+++ b/drivers/net/ehea/ehea_phyp.c
@@ -94,6 +94,7 @@ static long ehea_plpar_hcall9(unsigned long opcode,
 {
 	long ret;
 	int i, sleep_msecs;
+	u8 cb_cat;
 
 	for (i = 0; i < 5; i++) {
 		ret = plpar_hcall9(opcode, outs,
@@ -106,7 +107,13 @@ static long ehea_plpar_hcall9(unsigned long opcode,
 			continue;
 		}
 
-		if (ret < H_SUCCESS)
+		cb_cat = EHEA_BMASK_GET(H_MEHEAPORT_CAT, arg2);
+
+		if ((ret < H_SUCCESS) && !(((ret == H_AUTHORITY)
+		    && (opcode == H_MODIFY_HEA_PORT))
+		    && (((cb_cat == H_PORT_CB4) && ((arg3 == H_PORT_CB4_JUMBO)
+		    || (arg3 == H_PORT_CB4_SPEED))) || ((cb_cat == H_PORT_CB7)
+		    && (arg3 == H_PORT_CB7_DUCQPN)))))
 			ehea_error("opcode=%lx ret=%lx"
 				   " arg1=%lx arg2=%lx arg3=%lx arg4=%lx"
 				   " arg5=%lx arg6=%lx arg7=%lx arg8=%lx"
@@ -120,7 +127,6 @@ static long ehea_plpar_hcall9(unsigned long opcode,
 				   outs[0], outs[1], outs[2], outs[3],
 				   outs[4], outs[5], outs[6], outs[7],
 				   outs[8]);
-
 		return ret;
 	}
 
diff --git a/drivers/net/netxen/netxen_nic.h b/drivers/net/netxen/netxen_nic.h
index 6490acf..59324b1 100644
--- a/drivers/net/netxen/netxen_nic.h
+++ b/drivers/net/netxen/netxen_nic.h
@@ -63,12 +63,11 @@
 
 #include "netxen_nic_hw.h"
 
-#define NETXEN_NIC_BUILD_NO     "4"
+#define NETXEN_NIC_BUILD_NO     "2"
 #define _NETXEN_NIC_LINUX_MAJOR 3
 #define _NETXEN_NIC_LINUX_MINOR 3
-#define _NETXEN_NIC_LINUX_SUBVERSION 2
-#define NETXEN_NIC_LINUX_VERSIONID  "3.3.2" "-" NETXEN_NIC_BUILD_NO
-#define NETXEN_NIC_FW_VERSIONID "3.3.2"
+#define _NETXEN_NIC_LINUX_SUBVERSION 3
+#define NETXEN_NIC_LINUX_VERSIONID  "3.3.3" "-" NETXEN_NIC_BUILD_NO
 
 #define RCV_DESC_RINGSIZE	\
 	(sizeof(struct rcv_desc) * adapter->max_rx_desc_count)
diff --git a/drivers/net/netxen/netxen_nic_hw.c b/drivers/net/netxen/netxen_nic_hw.c
index c0c31d1..191e233 100644
--- a/drivers/net/netxen/netxen_nic_hw.c
+++ b/drivers/net/netxen/netxen_nic_hw.c
@@ -984,7 +984,8 @@ void netxen_nic_flash_print(struct netxen_adapter *adapter)
 		       _NETXEN_NIC_LINUX_MAJOR, fw_major);
 		adapter->driver_mismatch = 1;
 	}
-	if (fw_minor != _NETXEN_NIC_LINUX_MINOR) {
+	if (fw_minor != _NETXEN_NIC_LINUX_MINOR &&
+			fw_minor != (_NETXEN_NIC_LINUX_MINOR + 1)) {
 		printk(KERN_ERR "The mismatch in driver version and firmware "
 		       "version minor number\n"
 		       "Driver version minor number = %d \t"
diff --git a/drivers/net/netxen/netxen_nic_main.c b/drivers/net/netxen/netxen_nic_main.c
index 8a5792f..96e1bee 100644
--- a/drivers/net/netxen/netxen_nic_main.c
+++ b/drivers/net/netxen/netxen_nic_main.c
@@ -1144,7 +1144,7 @@ static int __init netxen_init_module(void)
 	if ((netxen_workq = create_singlethread_workqueue("netxen")) == 0)
 		return -ENOMEM;
 
-	return pci_module_init(&netxen_driver);
+	return pci_register_driver(&netxen_driver);
 }
 
 module_init(netxen_init_module);
diff --git a/drivers/net/pcmcia/3c589_cs.c b/drivers/net/pcmcia/3c589_cs.c
index 342f406..461e827 100644
--- a/drivers/net/pcmcia/3c589_cs.c
+++ b/drivers/net/pcmcia/3c589_cs.c
@@ -606,11 +606,14 @@ static int el3_start_xmit(struct sk_buff *skb, struct net_device *dev)
 {
     kio_addr_t ioaddr = dev->base_addr;
     struct el3_private *priv = netdev_priv(dev);
+    unsigned long flags;
 
     DEBUG(3, "%s: el3_start_xmit(length = %ld) called, "
 	  "status %4.4x.\n", dev->name, (long)skb->len,
 	  inw(ioaddr + EL3_STATUS));
 
+    spin_lock_irqsave(&priv->lock, flags);    
+
     priv->stats.tx_bytes += skb->len;
 
     /* Put out the doubleword header... */
@@ -628,6 +631,7 @@ static int el3_start_xmit(struct sk_buff *skb, struct net_device *dev)
 
     dev_kfree_skb(skb);
     pop_tx_status(dev);
+    spin_unlock_irqrestore(&priv->lock, flags);    
     
     return 0;
 }
@@ -729,14 +733,13 @@ static void media_check(unsigned long arg)
 
     if (!netif_device_present(dev)) goto reschedule;
 
-    EL3WINDOW(1);
     /* Check for pending interrupt with expired latency timer: with
        this, we can limp along even if the interrupt is blocked */
     if ((inw(ioaddr + EL3_STATUS) & IntLatch) &&
 	(inb(ioaddr + EL3_TIMER) == 0xff)) {
 	if (!lp->fast_poll)
 	    printk(KERN_WARNING "%s: interrupt(s) dropped!\n", dev->name);
-	el3_interrupt(dev->irq, lp);
+	el3_interrupt(dev->irq, dev);
 	lp->fast_poll = HZ;
     }
     if (lp->fast_poll) {
diff --git a/drivers/net/phy/phy.c b/drivers/net/phy/phy.c
index e175f39..9765fa6 100644
--- a/drivers/net/phy/phy.c
+++ b/drivers/net/phy/phy.c
@@ -286,6 +286,7 @@ int phy_ethtool_sset(struct phy_device *phydev, struct ethtool_cmd *cmd)
 
 	return 0;
 }
+EXPORT_SYMBOL(phy_ethtool_sset);
 
 int phy_ethtool_gset(struct phy_device *phydev, struct ethtool_cmd *cmd)
 {
@@ -302,7 +303,7 @@ int phy_ethtool_gset(struct phy_device *phydev, struct ethtool_cmd *cmd)
 
 	return 0;
 }
-
+EXPORT_SYMBOL(phy_ethtool_gset);
 
 /* Note that this function is currently incompatible with the
  * PHYCONTROL layer.  It changes registers without regard to
