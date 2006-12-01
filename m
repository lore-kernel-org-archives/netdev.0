From: "Amit S. Kale" <amitkale@netxen.com>
Subject: [PATCH 1/3] NetXen: driver cleanup, removed unnecessary __iomem type casts
Date: Fri, 1 Dec 2006 05:36:22 -0800
Message-ID: <200612011336.kB1DaMQL014614@dut39.unminc.com>
Cc: amitkale@netxen.com, brazilnut@us.ibm.com, jeff@garzik.org,
	netxenproj@linsyssoft.com, rob@netxen.com, romieu@fr.zoreil.com,
	sanjeev@netxen.com, shemminger@osdl.org, wendyx@us.ibm.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from 66-126-254-34.unm.net ([66.126.254.34]:48478 "EHLO
	nxmail.netxen.com") by vger.kernel.org with ESMTP id S1031372AbWLANgX
	(ORCPT <rfc822;netdev@vger.kernel.org>);
	Fri, 1 Dec 2006 08:36:23 -0500
To: netdev@vger.kernel.org
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Signed-off-by: Amit S. Kale <amitkale@netxen.com>

 netxen_nic.h         |   38 ++++++++------------------------------
 netxen_nic_ethtool.c |    5 ++---
 netxen_nic_hw.c      |   12 +++++-------
 netxen_nic_main.c    |    8 +++-----
 4 files changed, 18 insertions(+), 45 deletions(-)


diff --git a/drivers/net/netxen/netxen_nic.h b/drivers/net/netxen/netxen_nic.h
index 1bee560..d925053 100644
--- a/drivers/net/netxen/netxen_nic.h
+++ b/drivers/net/netxen/netxen_nic.h
@@ -343,7 +343,6 @@ typedef enum {
 	NETXEN_BRDTYPE_P2_SB31_10G_HMEZ = 0x000e,
 	NETXEN_BRDTYPE_P2_SB31_10G_CX4 = 0x000f
 } netxen_brdtype_t;
-#define NUM_SUPPORTED_BOARDS (sizeof(netxen_boards)/sizeof(netxen_brdinfo_t))
 
 typedef enum {
 	NETXEN_BRDMFG_INVENTEC = 1
@@ -937,9 +936,7 @@ static inline void netxen_nic_disable_in
 	/*
 	 * ISR_INT_MASK: Can be read from window 0 or 1.
 	 */
-	writel(0x7ff,
-	       (void __iomem
-		*)(PCI_OFFSET_SECOND_RANGE(adapter, ISR_INT_MASK)));
+	writel(0x7ff, PCI_OFFSET_SECOND_RANGE(adapter, ISR_INT_MASK));
 
 }
 
@@ -959,14 +956,12 @@ static inline void netxen_nic_enable_int
 		break;
 	}
 
-	writel(mask,
-	       (void __iomem
-		*)(PCI_OFFSET_SECOND_RANGE(adapter, ISR_INT_MASK)));
+	writel(mask, PCI_OFFSET_SECOND_RANGE(adapter, ISR_INT_MASK));
 
 	if (!(adapter->flags & NETXEN_NIC_MSI_ENABLED)) {
 		mask = 0xbff;
-		writel(mask, (void __iomem *)
-		       (PCI_OFFSET_SECOND_RANGE(adapter, ISR_INT_TARGET_MASK)));
+		writel(mask, PCI_OFFSET_SECOND_RANGE(adapter,
+						     ISR_INT_TARGET_MASK));
 	}
 }
 
@@ -975,13 +970,13 @@ static inline void netxen_nic_enable_int
  */
 
 #define NETXEN_MAX_SHORT_NAME 16
-typedef struct {
+struct netxen_brdinfo {
 	netxen_brdtype_t brdtype;	/* type of board */
 	long ports;		/* max no of physical ports */
 	char short_name[NETXEN_MAX_SHORT_NAME];
-} netxen_brdinfo_t;
+};
 
-static const netxen_brdinfo_t netxen_boards[] = {
+static const struct netxen_brdinfo netxen_boards[] = {
 	{NETXEN_BRDTYPE_P2_SB31_10G_CX4, 1, "XGb CX4"},
 	{NETXEN_BRDTYPE_P2_SB31_10G_HMEZ, 1, "XGb HMEZ"},
 	{NETXEN_BRDTYPE_P2_SB31_10G_IMEZ, 2, "XGb IMEZ"},
@@ -990,24 +985,7 @@ static const netxen_brdinfo_t netxen_boa
 	{NETXEN_BRDTYPE_P2_SB31_2G, 2, "Dual Gb"},
 };
 
-#define NUM_SUPPORTED_BOARDS (sizeof(netxen_boards)/sizeof(netxen_brdinfo_t))
-
-static inline void get_brd_ports_name_by_type(u32 type, int *ports, char *name)
-{
-	int i, found = 0;
-	for (i = 0; i < NUM_SUPPORTED_BOARDS; ++i) {
-		if (netxen_boards[i].brdtype == type) {
-			*ports = netxen_boards[i].ports;
-			strcpy(name, netxen_boards[i].short_name);
-			found = 1;
-			break;
-		}
-	}
-	if (!found) {
-		*ports = 0;
-		name = "Unknown";
-	}
-}
+#define NUM_SUPPORTED_BOARDS (sizeof(netxen_boards)/sizeof(struct netxen_brdinfo))
 
 static inline void get_brd_port_by_type(u32 type, int *ports)
 {
diff --git a/drivers/net/netxen/netxen_nic_ethtool.c b/drivers/net/netxen/netxen_nic_ethtool.c
index f3fc35c..9a914ae 100644
--- a/drivers/net/netxen/netxen_nic_ethtool.c
+++ b/drivers/net/netxen/netxen_nic_ethtool.c
@@ -139,8 +139,7 @@ netxen_nic_get_settings(struct net_devic
 {
 	struct netxen_port *port = netdev_priv(dev);
 	struct netxen_adapter *adapter = port->adapter;
-	struct netxen_board_info *boardinfo;
-	boardinfo = &adapter->ahw.boardcfg;
+	struct netxen_board_info *boardinfo = &adapter->ahw.boardcfg;
 
 	/* read which mode */
 	if (adapter->ahw.board_type == NETXEN_NIC_GBE) {
@@ -208,7 +207,7 @@ netxen_nic_get_settings(struct net_devic
 		ecmd->autoneg = AUTONEG_DISABLE;
 		break;
 	default:
-		printk("ERROR: Unsupported board model %d\n",
+		printk(KERN_ERR "netxen-nic: Unsupported board model %d\n",
 		       (netxen_brdtype_t) boardinfo->board_type);
 		return -EIO;
 
diff --git a/drivers/net/netxen/netxen_nic_hw.c b/drivers/net/netxen/netxen_nic_hw.c
index 99e647a..105c24f 100644
--- a/drivers/net/netxen/netxen_nic_hw.c
+++ b/drivers/net/netxen/netxen_nic_hw.c
@@ -275,10 +275,8 @@ int netxen_nic_hw_resources(struct netxe
 			rcv_desc->desc_head = (struct rcv_desc *)addr;
 		}
 
-		addr = netxen_alloc(adapter->ahw.pdev,
-				    STATUS_DESC_RINGSIZE,
-				    &recv_ctx->
-				    rcv_status_desc_phys_addr,
+		addr = netxen_alloc(adapter->ahw.pdev, STATUS_DESC_RINGSIZE,
+				    &recv_ctx->rcv_status_desc_phys_addr,
 				    &recv_ctx->rcv_status_desc_pdev);
 		if (addr == NULL) {
 			DPRINTK(ERR, "bad return from"
@@ -675,7 +673,7 @@ void netxen_nic_write_w0(struct netxen_a
 	void __iomem *addr;
 
 	netxen_nic_pci_change_crbwindow(adapter, 0);
-	addr = (void __iomem *)(pci_base_offset(adapter, index));
+	addr = pci_base_offset(adapter, index);
 	writel(value, addr);
 	netxen_nic_pci_change_crbwindow(adapter, 1);
 }
@@ -685,7 +683,7 @@ void netxen_nic_read_w0(struct netxen_ad
 {
 	void __iomem *addr;
 
-	addr = (void __iomem *)(pci_base_offset(adapter, index));
+	addr = pci_base_offset(adapter, index);
 
 	netxen_nic_pci_change_crbwindow(adapter, 0);
 	*value = readl(addr);
@@ -865,7 +863,7 @@ netxen_crb_writelit_adapter(struct netxe
 		writel(data, NETXEN_CRB_NORMALIZE(adapter, off));
 	} else {
 		netxen_nic_pci_change_crbwindow(adapter, 0);
-		addr = (void __iomem *)(pci_base_offset(adapter, off));
+		addr = pci_base_offset(adapter, off);
 		writel(data, addr);
 		netxen_nic_pci_change_crbwindow(adapter, 1);
 	}
diff --git a/drivers/net/netxen/netxen_nic_main.c b/drivers/net/netxen/netxen_nic_main.c
index cd1336e..1cb662d 100644
--- a/drivers/net/netxen/netxen_nic_main.c
+++ b/drivers/net/netxen/netxen_nic_main.c
@@ -969,11 +969,9 @@ netxen_handle_int(struct netxen_adapter
 		netxen_nic_disable_int(adapter);
 		/* Window = 0 or 1 */
 		do {
-			writel(0xffffffff, (void __iomem *)
-			       (PCI_OFFSET_SECOND_RANGE
-				(adapter, ISR_INT_TARGET_STATUS)));
-			mask = readl((void __iomem *)
-				     pci_base_offset(adapter, ISR_INT_VECTOR));
+			writel(0xffffffff, PCI_OFFSET_SECOND_RANGE(adapter,
+						ISR_INT_TARGET_STATUS));
+			mask = readl(pci_base_offset(adapter, ISR_INT_VECTOR));
 		} while (((mask & 0x80) != 0) && (++count < 32));
 		if ((mask & 0x80) != 0)
 			printk("Could not disable interrupt completely\n");
