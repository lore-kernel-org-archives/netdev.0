From: Jeff Garzik <jeff@garzik.org>
Subject: [git patches] net driver updates
Date: Mon, 27 Oct 2008 19:18:41 -0400
Message-ID: <20081027231841.GA26530@havoc.gtf.org>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: netdev@vger.kernel.org, LKML <linux-kernel@vger.kernel.org>
To: David Miller <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from havoc.gtf.org ([69.61.125.42]:54653 "EHLO havoc.gtf.org"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1751117AbYJ0XSm (ORCPT <rfc822;netdev@vger.kernel.org>);
	Mon, 27 Oct 2008 19:18:42 -0400
Content-Disposition: inline
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>


Note 1: The dm9601 change is, strictly speaking, an addition, but it
fixes the inability to perform several basic functions related to MAC
address.

Please pull from 'davem-fixes' branch of
master.kernel.org:/pub/scm/linux/kernel/git/jgarzik/netdev-2.6.git davem-fixes

to receive the following updates:

 drivers/net/ehea/ehea.h           |    2 +-
 drivers/net/ehea/ehea_qmr.c       |   57 +++++++++++++++++++++++++++++++++---
 drivers/net/ehea/ehea_qmr.h       |    3 ++
 drivers/net/ibm_newemac/core.c    |    2 +-
 drivers/net/mlx4/en_main.c        |    1 -
 drivers/net/mlx4/fw.c             |    2 +-
 drivers/net/tulip/dmfe.c          |   12 +++++++-
 drivers/net/usb/dm9601.c          |   15 ++++++++++
 drivers/net/via-velocity.c        |   11 ++++--
 drivers/net/wan/syncppp.c         |    5 ++-
 drivers/s390/net/qeth_core_main.c |    3 +-
 drivers/s390/net/qeth_l2_main.c   |   27 ++++++-----------
 drivers/s390/net/qeth_l3_main.c   |   13 +--------
 drivers/s390/net/qeth_l3_sys.c    |    7 ----
 14 files changed, 106 insertions(+), 54 deletions(-)

FUJITA Tomonori (1):
      dmfe: check pci_alloc_consistent errors

Frank Blaschka (2):
      qeth: fix offset error in non prealloc header path
      qeth: remove unnecessary support ckeck in sysfs route6

Huang Weiyi (1):
      mlx4_en: remove duplicated #include

Jeff Garzik (1):
      drivers/net/wan/syncppp: Fix unused-var warnings

Josh Boyer (1):
      ibm_newemac: Fix typo in flow control config option

Peter Korsgaard (1):
      dm9601: runtime mac address change support

Sven Hartge (1):
      via-velocity: use driver string instead of dev->name before register_netdev()

Thomas Klein (1):
      ehea: Detect 16GB hugepages for firmware restriction

Ursula Braun (2):
      qeth: remove non-recover-thread checkings
      qeth: avoid skb_under_panic for malformatted inbound data

Yevgeny Petrilin (1):
      mlx4: Setting the correct offset for default mac address

diff --git a/drivers/net/ehea/ehea.h b/drivers/net/ehea/ehea.h
index 82dd1a8..002d918 100644
--- a/drivers/net/ehea/ehea.h
+++ b/drivers/net/ehea/ehea.h
@@ -40,7 +40,7 @@
 #include <asm/io.h>
 
 #define DRV_NAME	"ehea"
-#define DRV_VERSION	"EHEA_0094"
+#define DRV_VERSION	"EHEA_0095"
 
 /* eHEA capability flags */
 #define DLPAR_PORT_ADD_REM 1
diff --git a/drivers/net/ehea/ehea_qmr.c b/drivers/net/ehea/ehea_qmr.c
index 9b61dc9..9d00687 100644
--- a/drivers/net/ehea/ehea_qmr.c
+++ b/drivers/net/ehea/ehea_qmr.c
@@ -632,10 +632,13 @@ static void ehea_rebuild_busmap(void)
 	}
 }
 
-static int ehea_update_busmap(unsigned long pfn, unsigned long pgnum, int add)
+static int ehea_update_busmap(unsigned long pfn, unsigned long nr_pages, int add)
 {
 	unsigned long i, start_section, end_section;
 
+	if (!nr_pages)
+		return 0;
+
 	if (!ehea_bmap) {
 		ehea_bmap = kzalloc(sizeof(struct ehea_bmap), GFP_KERNEL);
 		if (!ehea_bmap)
@@ -643,7 +646,7 @@ static int ehea_update_busmap(unsigned long pfn, unsigned long pgnum, int add)
 	}
 
 	start_section = (pfn * PAGE_SIZE) / EHEA_SECTSIZE;
-	end_section = start_section + ((pgnum * PAGE_SIZE) / EHEA_SECTSIZE);
+	end_section = start_section + ((nr_pages * PAGE_SIZE) / EHEA_SECTSIZE);
 	/* Mark entries as valid or invalid only; address is assigned later */
 	for (i = start_section; i < end_section; i++) {
 		u64 flag;
@@ -692,10 +695,54 @@ int ehea_rem_sect_bmap(unsigned long pfn, unsigned long nr_pages)
 	return ret;
 }
 
-static int ehea_create_busmap_callback(unsigned long pfn,
-				       unsigned long nr_pages, void *arg)
+static int ehea_is_hugepage(unsigned long pfn)
+{
+	int page_order;
+
+	if (pfn & EHEA_HUGEPAGE_PFN_MASK)
+		return 0;
+
+	page_order = compound_order(pfn_to_page(pfn));
+	if (page_order + PAGE_SHIFT != EHEA_HUGEPAGESHIFT)
+		return 0;
+
+	return 1;
+}
+
+static int ehea_create_busmap_callback(unsigned long initial_pfn,
+				       unsigned long total_nr_pages, void *arg)
 {
-	return ehea_update_busmap(pfn, nr_pages, EHEA_BUSMAP_ADD_SECT);
+	int ret;
+	unsigned long pfn, start_pfn, end_pfn, nr_pages;
+
+	if ((total_nr_pages * PAGE_SIZE) < EHEA_HUGEPAGE_SIZE)
+		return ehea_update_busmap(initial_pfn, total_nr_pages,
+					  EHEA_BUSMAP_ADD_SECT);
+
+	/* Given chunk is >= 16GB -> check for hugepages */
+	start_pfn = initial_pfn;
+	end_pfn = initial_pfn + total_nr_pages;
+	pfn = start_pfn;
+
+	while (pfn < end_pfn) {
+		if (ehea_is_hugepage(pfn)) {
+			/* Add mem found in front of the hugepage */
+			nr_pages = pfn - start_pfn;
+			ret = ehea_update_busmap(start_pfn, nr_pages,
+						 EHEA_BUSMAP_ADD_SECT);
+			if (ret)
+				return ret;
+
+			/* Skip the hugepage */
+			pfn += (EHEA_HUGEPAGE_SIZE / PAGE_SIZE);
+			start_pfn = pfn;
+		} else
+			pfn += (EHEA_SECTSIZE / PAGE_SIZE);
+	}
+
+	/* Add mem found behind the hugepage(s)  */
+	nr_pages = pfn - start_pfn;
+	return ehea_update_busmap(start_pfn, nr_pages, EHEA_BUSMAP_ADD_SECT);
 }
 
 int ehea_create_busmap(void)
diff --git a/drivers/net/ehea/ehea_qmr.h b/drivers/net/ehea/ehea_qmr.h
index 1e58dc0..0817c1e 100644
--- a/drivers/net/ehea/ehea_qmr.h
+++ b/drivers/net/ehea/ehea_qmr.h
@@ -40,6 +40,9 @@
 #define EHEA_PAGESIZE          (1UL << EHEA_PAGESHIFT)
 #define EHEA_SECTSIZE          (1UL << 24)
 #define EHEA_PAGES_PER_SECTION (EHEA_SECTSIZE >> EHEA_PAGESHIFT)
+#define EHEA_HUGEPAGESHIFT     34
+#define EHEA_HUGEPAGE_SIZE     (1UL << EHEA_HUGEPAGESHIFT)
+#define EHEA_HUGEPAGE_PFN_MASK ((EHEA_HUGEPAGE_SIZE - 1) >> PAGE_SHIFT)
 
 #if ((1UL << SECTION_SIZE_BITS) < EHEA_SECTSIZE)
 #error eHEA module cannot work if kernel sectionsize < ehea sectionsize
diff --git a/drivers/net/ibm_newemac/core.c b/drivers/net/ibm_newemac/core.c
index 2ee2622..901212a 100644
--- a/drivers/net/ibm_newemac/core.c
+++ b/drivers/net/ibm_newemac/core.c
@@ -2605,7 +2605,7 @@ static int __devinit emac_init_config(struct emac_instance *dev)
 		    of_device_is_compatible(np, "ibm,emac-440gr"))
 			dev->features |= EMAC_FTR_440EP_PHY_CLK_FIX;
 		if (of_device_is_compatible(np, "ibm,emac-405ez")) {
-#ifdef CONFIG_IBM_NEW_EMAC_NO_FLOW_CONTROL
+#ifdef CONFIG_IBM_NEW_EMAC_NO_FLOW_CTRL
 			dev->features |= EMAC_FTR_NO_FLOW_CONTROL_40x;
 #else
 			printk(KERN_ERR "%s: Flow control not disabled!\n",
diff --git a/drivers/net/mlx4/en_main.c b/drivers/net/mlx4/en_main.c
index 1b0eebf..4b9794e 100644
--- a/drivers/net/mlx4/en_main.c
+++ b/drivers/net/mlx4/en_main.c
@@ -35,7 +35,6 @@
 #include <linux/module.h>
 #include <linux/delay.h>
 #include <linux/netdevice.h>
-#include <linux/cpumask.h>
 
 #include <linux/mlx4/driver.h>
 #include <linux/mlx4/device.h>
diff --git a/drivers/net/mlx4/fw.c b/drivers/net/mlx4/fw.c
index be09fdb..cee199c 100644
--- a/drivers/net/mlx4/fw.c
+++ b/drivers/net/mlx4/fw.c
@@ -360,9 +360,9 @@ int mlx4_QUERY_DEV_CAP(struct mlx4_dev *dev, struct mlx4_dev_cap *dev_cap)
 #define QUERY_PORT_ETH_MTU_OFFSET		0x02
 #define QUERY_PORT_WIDTH_OFFSET			0x06
 #define QUERY_PORT_MAX_GID_PKEY_OFFSET		0x07
-#define QUERY_PORT_MAC_OFFSET			0x08
 #define QUERY_PORT_MAX_MACVLAN_OFFSET		0x0a
 #define QUERY_PORT_MAX_VL_OFFSET		0x0b
+#define QUERY_PORT_MAC_OFFSET			0x10
 
 		for (i = 1; i <= dev_cap->num_ports; ++i) {
 			err = mlx4_cmd_box(dev, 0, mailbox->dma, i, 0, MLX4_CMD_QUERY_PORT,
diff --git a/drivers/net/tulip/dmfe.c b/drivers/net/tulip/dmfe.c
index 8e46a51..c91852f 100644
--- a/drivers/net/tulip/dmfe.c
+++ b/drivers/net/tulip/dmfe.c
@@ -420,9 +420,13 @@ static int __devinit dmfe_init_one (struct pci_dev *pdev,
 	/* Allocate Tx/Rx descriptor memory */
 	db->desc_pool_ptr = pci_alloc_consistent(pdev, sizeof(struct tx_desc) *
 			DESC_ALL_CNT + 0x20, &db->desc_pool_dma_ptr);
+	if (!db->desc_pool_ptr)
+		goto err_out_res;
 
 	db->buf_pool_ptr = pci_alloc_consistent(pdev, TX_BUF_ALLOC *
 			TX_DESC_CNT + 4, &db->buf_pool_dma_ptr);
+	if (!db->buf_pool_ptr)
+		goto err_out_free_desc;
 
 	db->first_tx_desc = (struct tx_desc *) db->desc_pool_ptr;
 	db->first_tx_desc_dma = db->desc_pool_dma_ptr;
@@ -469,7 +473,7 @@ static int __devinit dmfe_init_one (struct pci_dev *pdev,
 
 	err = register_netdev (dev);
 	if (err)
-		goto err_out_res;
+		goto err_out_free_buf;
 
 	printk(KERN_INFO "%s: Davicom DM%04lx at pci%s, "
 	       "%s, irq %d.\n",
@@ -483,6 +487,12 @@ static int __devinit dmfe_init_one (struct pci_dev *pdev,
 
 	return 0;
 
+err_out_free_buf:
+	pci_free_consistent(pdev, TX_BUF_ALLOC * TX_DESC_CNT + 4,
+			    db->buf_pool_ptr, db->buf_pool_dma_ptr);
+err_out_free_desc:
+	pci_free_consistent(pdev, sizeof(struct tx_desc) * DESC_ALL_CNT + 0x20,
+			    db->desc_pool_ptr, db->desc_pool_dma_ptr);
 err_out_res:
 	pci_release_regions(pdev);
 err_out_disable:
diff --git a/drivers/net/usb/dm9601.c b/drivers/net/usb/dm9601.c
index 78df2be..db3377d 100644
--- a/drivers/net/usb/dm9601.c
+++ b/drivers/net/usb/dm9601.c
@@ -396,6 +396,20 @@ static void dm9601_set_multicast(struct net_device *net)
 	dm_write_reg_async(dev, DM_RX_CTRL, rx_ctl);
 }
 
+static int dm9601_set_mac_address(struct net_device *net, void *p)
+{
+	struct sockaddr *addr = p;
+	struct usbnet *dev = netdev_priv(net);
+
+	if (!is_valid_ether_addr(addr->sa_data))
+		return -EINVAL;
+
+	memcpy(net->dev_addr, addr->sa_data, net->addr_len);
+	dm_write_async(dev, DM_PHY_ADDR, net->addr_len, net->dev_addr);
+
+	return 0;
+}
+
 static int dm9601_bind(struct usbnet *dev, struct usb_interface *intf)
 {
 	int ret;
@@ -406,6 +420,7 @@ static int dm9601_bind(struct usbnet *dev, struct usb_interface *intf)
 
 	dev->net->do_ioctl = dm9601_ioctl;
 	dev->net->set_multicast_list = dm9601_set_multicast;
+	dev->net->set_mac_address = dm9601_set_mac_address;
 	dev->net->ethtool_ops = &dm9601_ethtool_ops;
 	dev->net->hard_header_len += DM_TX_OVERHEAD;
 	dev->hard_mtu = dev->net->mtu + dev->net->hard_header_len;
diff --git a/drivers/net/via-velocity.c b/drivers/net/via-velocity.c
index 2dced38..3590ea5 100644
--- a/drivers/net/via-velocity.c
+++ b/drivers/net/via-velocity.c
@@ -521,7 +521,7 @@ static void __devexit velocity_remove1(struct pci_dev *pdev)
  *	we don't duplicate code for each option.
  */
 
-static void __devinit velocity_set_int_opt(int *opt, int val, int min, int max, int def, char *name, char *devname)
+static void __devinit velocity_set_int_opt(int *opt, int val, int min, int max, int def, char *name, const char *devname)
 {
 	if (val == -1)
 		*opt = def;
@@ -550,7 +550,7 @@ static void __devinit velocity_set_int_opt(int *opt, int val, int min, int max,
  *	we don't duplicate code for each option.
  */
 
-static void __devinit velocity_set_bool_opt(u32 * opt, int val, int def, u32 flag, char *name, char *devname)
+static void __devinit velocity_set_bool_opt(u32 * opt, int val, int def, u32 flag, char *name, const char *devname)
 {
 	(*opt) &= (~flag);
 	if (val == -1)
@@ -576,7 +576,7 @@ static void __devinit velocity_set_bool_opt(u32 * opt, int val, int def, u32 fla
  *	for the current device
  */
 
-static void __devinit velocity_get_options(struct velocity_opt *opts, int index, char *devname)
+static void __devinit velocity_get_options(struct velocity_opt *opts, int index, const char *devname)
 {
 
 	velocity_set_int_opt(&opts->rx_thresh, rx_thresh[index], RX_THRESH_MIN, RX_THRESH_MAX, RX_THRESH_DEF, "rx_thresh", devname);
@@ -863,6 +863,7 @@ static int __devinit velocity_found1(struct pci_dev *pdev, const struct pci_devi
 	static int first = 1;
 	struct net_device *dev;
 	int i;
+	const char *drv_string;
 	const struct velocity_info_tbl *info = &chip_info_table[ent->driver_data];
 	struct velocity_info *vptr;
 	struct mac_regs __iomem * regs;
@@ -935,7 +936,9 @@ static int __devinit velocity_found1(struct pci_dev *pdev, const struct pci_devi
 		dev->dev_addr[i] = readb(&regs->PAR[i]);
 
 
-	velocity_get_options(&vptr->options, velocity_nics, dev->name);
+	drv_string = dev_driver_string(&pdev->dev);
+
+	velocity_get_options(&vptr->options, velocity_nics, drv_string);
 
 	/*
 	 *	Mask out the options cannot be set to the chip
diff --git a/drivers/net/wan/syncppp.c b/drivers/net/wan/syncppp.c
index 327d585..6e92f7b 100644
--- a/drivers/net/wan/syncppp.c
+++ b/drivers/net/wan/syncppp.c
@@ -756,10 +756,11 @@ static void sppp_cisco_input (struct sppp *sp, struct sk_buff *skb)
 	case CISCO_ADDR_REQ:
 		/* Stolen from net/ipv4/devinet.c -- SIOCGIFADDR ioctl */
 		{
-		struct in_device *in_dev;
-		struct in_ifaddr *ifa;
 		__be32 addr = 0, mask = htonl(~0U); /* FIXME: is the mask correct? */
 #ifdef CONFIG_INET
+		struct in_device *in_dev;
+		struct in_ifaddr *ifa;
+
 		rcu_read_lock();
 		if ((in_dev = __in_dev_get_rcu(dev)) != NULL)
 		{
diff --git a/drivers/s390/net/qeth_core_main.c b/drivers/s390/net/qeth_core_main.c
index 7de410d..52d2659 100644
--- a/drivers/s390/net/qeth_core_main.c
+++ b/drivers/s390/net/qeth_core_main.c
@@ -3025,7 +3025,7 @@ static inline void __qeth_fill_buffer(struct sk_buff *skb,
 	struct qdio_buffer *buffer, int is_tso, int *next_element_to_fill,
 	int offset)
 {
-	int length = skb->len - offset;
+	int length = skb->len;
 	int length_here;
 	int element;
 	char *data;
@@ -3037,6 +3037,7 @@ static inline void __qeth_fill_buffer(struct sk_buff *skb,
 
 	if (offset >= 0) {
 		data = skb->data + offset;
+		length -= offset;
 		first_lap = 0;
 	}
 
diff --git a/drivers/s390/net/qeth_l2_main.c b/drivers/s390/net/qeth_l2_main.c
index 955ba7a..1b1e803 100644
--- a/drivers/s390/net/qeth_l2_main.c
+++ b/drivers/s390/net/qeth_l2_main.c
@@ -373,8 +373,6 @@ static int qeth_l2_stop_card(struct qeth_card *card, int recovery_mode)
 	QETH_DBF_HEX(SETUP, 2, &card, sizeof(void *));
 
 	qeth_set_allowed_threads(card, 0, 1);
-	if (qeth_wait_for_threads(card, ~QETH_RECOVER_THREAD))
-		return -ERESTARTSYS;
 	if (card->read.state == CH_STATE_UP &&
 	    card->write.state == CH_STATE_UP &&
 	    (card->state == CARD_STATE_UP)) {
@@ -451,12 +449,15 @@ static void qeth_l2_process_inbound_buffer(struct qeth_card *card,
 			netif_rx(skb);
 			break;
 		case QETH_HEADER_TYPE_OSN:
-			skb_push(skb, sizeof(struct qeth_hdr));
-			skb_copy_to_linear_data(skb, hdr,
+			if (card->info.type == QETH_CARD_TYPE_OSN) {
+				skb_push(skb, sizeof(struct qeth_hdr));
+				skb_copy_to_linear_data(skb, hdr,
 						sizeof(struct qeth_hdr));
-			len = skb->len;
-			card->osn_info.data_cb(skb);
-			break;
+				len = skb->len;
+				card->osn_info.data_cb(skb);
+				break;
+			}
+			/* else unknown */
 		default:
 			dev_kfree_skb_any(skb);
 			QETH_DBF_TEXT(TRACE, 3, "inbunkno");
@@ -975,12 +976,6 @@ static int __qeth_l2_set_online(struct ccwgroup_device *gdev, int recovery_mode)
 	QETH_DBF_HEX(SETUP, 2, &card, sizeof(void *));
 
 	qeth_set_allowed_threads(card, QETH_RECOVER_THREAD, 1);
-	if (qeth_wait_for_threads(card, ~QETH_RECOVER_THREAD)) {
-		PRINT_WARN("set_online of card %s interrupted by user!\n",
-			   CARD_BUS_ID(card));
-		return -ERESTARTSYS;
-	}
-
 	recover_flag = card->state;
 	rc = ccw_device_set_online(CARD_RDEV(card));
 	if (rc) {
@@ -1091,11 +1086,7 @@ static int __qeth_l2_set_offline(struct ccwgroup_device *cgdev,
 	if (card->dev && netif_carrier_ok(card->dev))
 		netif_carrier_off(card->dev);
 	recover_flag = card->state;
-	if (qeth_l2_stop_card(card, recovery_mode) == -ERESTARTSYS) {
-		PRINT_WARN("Stopping card %s interrupted by user!\n",
-			   CARD_BUS_ID(card));
-		return -ERESTARTSYS;
-	}
+	qeth_l2_stop_card(card, recovery_mode);
 	rc  = ccw_device_set_offline(CARD_DDEV(card));
 	rc2 = ccw_device_set_offline(CARD_WDEV(card));
 	rc3 = ccw_device_set_offline(CARD_RDEV(card));
diff --git a/drivers/s390/net/qeth_l3_main.c b/drivers/s390/net/qeth_l3_main.c
index 99547de..ed59fed 100644
--- a/drivers/s390/net/qeth_l3_main.c
+++ b/drivers/s390/net/qeth_l3_main.c
@@ -2064,8 +2064,6 @@ static int qeth_l3_stop_card(struct qeth_card *card, int recovery_mode)
 	QETH_DBF_HEX(SETUP, 2, &card, sizeof(void *));
 
 	qeth_set_allowed_threads(card, 0, 1);
-	if (qeth_wait_for_threads(card, ~QETH_RECOVER_THREAD))
-		return -ERESTARTSYS;
 	if (card->read.state == CH_STATE_UP &&
 	    card->write.state == CH_STATE_UP &&
 	    (card->state == CARD_STATE_UP)) {
@@ -3049,11 +3047,6 @@ static int __qeth_l3_set_online(struct ccwgroup_device *gdev, int recovery_mode)
 	QETH_DBF_HEX(SETUP, 2, &card, sizeof(void *));
 
 	qeth_set_allowed_threads(card, QETH_RECOVER_THREAD, 1);
-	if (qeth_wait_for_threads(card, ~QETH_RECOVER_THREAD)) {
-		PRINT_WARN("set_online of card %s interrupted by user!\n",
-			   CARD_BUS_ID(card));
-		return -ERESTARTSYS;
-	}
 
 	recover_flag = card->state;
 	rc = ccw_device_set_online(CARD_RDEV(card));
@@ -3170,11 +3163,7 @@ static int __qeth_l3_set_offline(struct ccwgroup_device *cgdev,
 	if (card->dev && netif_carrier_ok(card->dev))
 		netif_carrier_off(card->dev);
 	recover_flag = card->state;
-	if (qeth_l3_stop_card(card, recovery_mode) == -ERESTARTSYS) {
-		PRINT_WARN("Stopping card %s interrupted by user!\n",
-			   CARD_BUS_ID(card));
-		return -ERESTARTSYS;
-	}
+	qeth_l3_stop_card(card, recovery_mode);
 	rc  = ccw_device_set_offline(CARD_DDEV(card));
 	rc2 = ccw_device_set_offline(CARD_WDEV(card));
 	rc3 = ccw_device_set_offline(CARD_RDEV(card));
diff --git a/drivers/s390/net/qeth_l3_sys.c b/drivers/s390/net/qeth_l3_sys.c
index 210ddb6..c144b99 100644
--- a/drivers/s390/net/qeth_l3_sys.c
+++ b/drivers/s390/net/qeth_l3_sys.c
@@ -121,9 +121,6 @@ static ssize_t qeth_l3_dev_route6_show(struct device *dev,
 	if (!card)
 		return -EINVAL;
 
-	if (!qeth_is_supported(card, IPA_IPV6))
-		return sprintf(buf, "%s\n", "n/a");
-
 	return qeth_l3_dev_route_show(card, &card->options.route6, buf);
 }
 
@@ -135,10 +132,6 @@ static ssize_t qeth_l3_dev_route6_store(struct device *dev,
 	if (!card)
 		return -EINVAL;
 
-	if (!qeth_is_supported(card, IPA_IPV6)) {
-		return -EOPNOTSUPP;
-	}
-
 	return qeth_l3_dev_route_store(card, &card->options.route6,
 				QETH_PROT_IPV6, buf, count);
 }
