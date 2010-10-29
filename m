From: Jon Mason <jon.mason@exar.com>
Subject: [PATCH 08/11] vxge: Titan1A detection
Date: Thu, 28 Oct 2010 21:19:43 -0500
Message-ID: <1288318786-12319-8-git-send-email-jon.mason@exar.com>
References: <1288318786-12319-1-git-send-email-jon.mason@exar.com>
Cc: netdev@vger.kernel.org,
	Sivakumar Subramani <sivakumar.subramani@exar.com>,
	Sreenivasa Honnur <sreenivasa.honnur@exar.com>,
	Ram Vepa <ram.vepa@exar.com>
To: David Miller <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-yx0-f174.google.com ([209.85.213.174]:38952 "EHLO
	mail-yx0-f174.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1760163Ab0J2CUS (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 28 Oct 2010 22:20:18 -0400
Received: by mail-yx0-f174.google.com with SMTP id 8so1381877yxk.19
        for <netdev@vger.kernel.org>; Thu, 28 Oct 2010 19:20:18 -0700 (PDT)
In-Reply-To: <1288318786-12319-1-git-send-email-jon.mason@exar.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Detect if the adapter is Titan or Titan1A, and tune the driver for this
hardware.  Also, remove unnecessary function __vxge_hw_device_id_get.

Signed-off-by: Jon Mason <jon.mason@exar.com>
Signed-off-by: Ram Vepa <ram.vepa@exar.com>
---
 drivers/net/vxge/vxge-config.c |   37 ++++++--------------------
 drivers/net/vxge/vxge-config.h |    9 ------
 drivers/net/vxge/vxge-main.c   |   53 ++++++++++++++++++++++++++++++++------
 drivers/net/vxge/vxge-main.h   |   55 +++++++++++++++++++++++++++-------------
 4 files changed, 90 insertions(+), 64 deletions(-)

diff --git a/drivers/net/vxge/vxge-config.c b/drivers/net/vxge/vxge-config.c
index e18b2f9..d61d7f4 100644
--- a/drivers/net/vxge/vxge-config.c
+++ b/drivers/net/vxge/vxge-config.c
@@ -657,26 +657,6 @@ exit:
 }
 
 /*
- * __vxge_hw_device_id_get
- * This routine returns sets the device id and revision numbers into the device
- * structure
- */
-void __vxge_hw_device_id_get(struct __vxge_hw_device *hldev)
-{
-	u64 val64;
-
-	val64 = readq(&hldev->common_reg->titan_asic_id);
-	hldev->device_id =
-		(u16)VXGE_HW_TITAN_ASIC_ID_GET_INITIAL_DEVICE_ID(val64);
-
-	hldev->major_revision =
-		(u8)VXGE_HW_TITAN_ASIC_ID_GET_INITIAL_MAJOR_REVISION(val64);
-
-	hldev->minor_revision =
-		(u8)VXGE_HW_TITAN_ASIC_ID_GET_INITIAL_MINOR_REVISION(val64);
-}
-
-/*
  * __vxge_hw_device_access_rights_get: Get Access Rights of the driver
  * This routine returns the Access Rights of the driver
  */
@@ -1178,7 +1158,6 @@ vxge_hw_device_initialize(
 		vfree(hldev);
 		goto exit;
 	}
-	__vxge_hw_device_id_get(hldev);
 
 	__vxge_hw_device_host_info_get(hldev);
 
@@ -4329,16 +4308,18 @@ vpath_open_exit1:
 void
 vxge_hw_vpath_rx_doorbell_init(struct __vxge_hw_vpath_handle *vp)
 {
-	struct __vxge_hw_virtualpath *vpath = NULL;
+	struct __vxge_hw_virtualpath *vpath = vp->vpath;
+	struct __vxge_hw_ring *ring = vpath->ringh;
+	struct vxgedev *vdev = netdev_priv(vpath->hldev->ndev);
 	u64 new_count, val64, val164;
-	struct __vxge_hw_ring *ring;
 
-	vpath = vp->vpath;
-	ring = vpath->ringh;
+	if (vdev->titan1) {
+		new_count = readq(&vpath->vp_reg->rxdmem_size);
+		new_count &= 0x1fff;
+	} else
+		new_count = ring->config->ring_blocks * VXGE_HW_BLOCK_SIZE / 8;
 
-	new_count = readq(&vpath->vp_reg->rxdmem_size);
-	new_count &= 0x1fff;
-	val164 = (VXGE_HW_RXDMEM_SIZE_PRC_RXDMEM_SIZE(new_count));
+	val164 = VXGE_HW_RXDMEM_SIZE_PRC_RXDMEM_SIZE(new_count);
 
 	writeq(VXGE_HW_PRC_RXD_DOORBELL_NEW_QW_CNT(val164),
 		&vpath->vp_reg->prc_rxd_doorbell);
diff --git a/drivers/net/vxge/vxge-config.h b/drivers/net/vxge/vxge-config.h
index 3859d59..252969c 100644
--- a/drivers/net/vxge/vxge-config.h
+++ b/drivers/net/vxge/vxge-config.h
@@ -713,9 +713,6 @@ struct __vxge_hw_vpath_handle{
 /**
  * struct __vxge_hw_device  - Hal device object
  * @magic: Magic Number
- * @device_id: PCI Device Id of the adapter
- * @major_revision: PCI Device major revision
- * @minor_revision: PCI Device minor revision
  * @bar0: BAR0 virtual address.
  * @pdev: Physical device handle
  * @config: Confguration passed by the LL driver at initialization
@@ -727,9 +724,6 @@ struct __vxge_hw_device {
 	u32				magic;
 #define VXGE_HW_DEVICE_MAGIC		0x12345678
 #define VXGE_HW_DEVICE_DEAD		0xDEADDEAD
-	u16				device_id;
-	u8				major_revision;
-	u8				minor_revision;
 	void __iomem			*bar0;
 	struct pci_dev			*pdev;
 	struct net_device		*ndev;
@@ -2212,9 +2206,6 @@ __vxge_hw_device_toc_get(void __iomem *bar0);
 enum vxge_hw_status
 __vxge_hw_device_reg_addr_get(struct __vxge_hw_device *hldev);
 
-void
-__vxge_hw_device_id_get(struct __vxge_hw_device *hldev);
-
 enum vxge_hw_status
 vxge_hw_device_flick_link_led(struct __vxge_hw_device *devh, u64 on_off);
 
diff --git a/drivers/net/vxge/vxge-main.c b/drivers/net/vxge/vxge-main.c
index a365784..c014b26 100644
--- a/drivers/net/vxge/vxge-main.c
+++ b/drivers/net/vxge/vxge-main.c
@@ -2001,8 +2001,23 @@ int vxge_open_vpaths(struct vxgedev *vdev)
 
 	for (i = 0; i < vdev->no_of_vpath; i++) {
 		vpath = &vdev->vpaths[i];
-
 		vxge_assert(vpath->is_configured);
+
+		if (!vdev->titan1) {
+			struct vxge_hw_vp_config *vcfg;
+			vcfg = &vdev->devh->config.vp_config[vpath->device_id];
+
+			vcfg->rti.urange_a = RTI_T1A_RX_URANGE_A;
+			vcfg->rti.urange_b = RTI_T1A_RX_URANGE_B;
+			vcfg->rti.urange_c = RTI_T1A_RX_URANGE_C;
+			vcfg->tti.uec_a = TTI_T1A_TX_UFC_A;
+			vcfg->tti.uec_b = TTI_T1A_TX_UFC_B;
+			vcfg->tti.uec_c = TTI_T1A_TX_UFC_C(vdev->mtu);
+			vcfg->tti.uec_d = TTI_T1A_TX_UFC_D(vdev->mtu);
+			vcfg->tti.ltimer_val = VXGE_T1A_TTI_LTIMER_VAL;
+			vcfg->tti.rtimer_val = VXGE_T1A_TTI_RTIMER_VAL;
+		}
+
 		attr.vp_id = vpath->device_id;
 		attr.fifo_attr.callback = vxge_xmit_compl;
 		attr.fifo_attr.txdl_term = vxge_tx_term;
@@ -2699,9 +2714,10 @@ vxge_open(struct net_device *dev)
 		vxge_os_timer(vdev->vp_reset_timer,
 			vxge_poll_vp_reset, vdev, (HZ/2));
 
-	if (vdev->vp_lockup_timer.function == NULL)
-		vxge_os_timer(vdev->vp_lockup_timer,
-			vxge_poll_vp_lockup, vdev, (HZ/2));
+	/* There is no need to check for RxD leak and RxD lookup on Titan1A */
+	if (vdev->titan1 && vdev->vp_lockup_timer.function == NULL)
+		vxge_os_timer(vdev->vp_lockup_timer, vxge_poll_vp_lockup, vdev,
+			      HZ / 2);
 
 	set_bit(__VXGE_STATE_CARD_UP, &vdev->state);
 
@@ -2833,7 +2849,9 @@ int do_vxge_close(struct net_device *dev, int do_io)
 
 		smp_wmb();
 	}
-	del_timer_sync(&vdev->vp_lockup_timer);
+
+	if (vdev->titan1)
+		del_timer_sync(&vdev->vp_lockup_timer);
 
 	del_timer_sync(&vdev->vp_reset_timer);
 
@@ -3251,10 +3269,23 @@ static const struct net_device_ops vxge_netdev_ops = {
 #endif
 };
 
-int __devinit vxge_device_register(struct __vxge_hw_device *hldev,
-				   struct vxge_config *config,
-				   int high_dma, int no_of_vpath,
-				   struct vxgedev **vdev_out)
+static int __devinit vxge_device_revision(struct vxgedev *vdev)
+{
+	int ret;
+	u8 revision;
+
+	ret = pci_read_config_byte(vdev->pdev, PCI_REVISION_ID, &revision);
+	if (ret)
+		return -EIO;
+
+	vdev->titan1 = (revision == VXGE_HW_TITAN1_PCI_REVISION);
+	return 0;
+}
+
+static int __devinit vxge_device_register(struct __vxge_hw_device *hldev,
+					  struct vxge_config *config,
+					  int high_dma, int no_of_vpath,
+					  struct vxgedev **vdev_out)
 {
 	struct net_device *ndev;
 	enum vxge_hw_status status = VXGE_HW_OK;
@@ -3291,6 +3322,10 @@ int __devinit vxge_device_register(struct __vxge_hw_device *hldev,
 	vdev->rx_csum = 1;	/* Enable Rx CSUM by default. */
 	vdev->rx_hwts = 0;
 
+	ret = vxge_device_revision(vdev);
+	if (ret < 0)
+		goto _out1;
+
 	SET_NETDEV_DEV(ndev, &vdev->pdev->dev);
 
 	ndev->features |= NETIF_F_HW_VLAN_TX | NETIF_F_HW_VLAN_RX |
diff --git a/drivers/net/vxge/vxge-main.h b/drivers/net/vxge/vxge-main.h
index 947893e..151f54b 100644
--- a/drivers/net/vxge/vxge-main.h
+++ b/drivers/net/vxge/vxge-main.h
@@ -29,6 +29,9 @@
 
 #define PCI_DEVICE_ID_TITAN_WIN		0x5733
 #define PCI_DEVICE_ID_TITAN_UNI		0x5833
+#define VXGE_HW_TITAN1_PCI_REVISION	1
+#define VXGE_HW_TITAN1A_PCI_REVISION	2
+
 #define	VXGE_USE_DEFAULT		0xffffffff
 #define VXGE_HW_VPATH_MSIX_ACTIVE	4
 #define VXGE_ALARM_MSIX_ID		2
@@ -53,11 +56,13 @@
 
 #define VXGE_TTI_BTIMER_VAL 250000
 
-#define VXGE_TTI_LTIMER_VAL 1000
-#define VXGE_TTI_RTIMER_VAL 0
-#define VXGE_RTI_BTIMER_VAL 250
-#define VXGE_RTI_LTIMER_VAL 100
-#define VXGE_RTI_RTIMER_VAL 0
+#define VXGE_TTI_LTIMER_VAL	1000
+#define VXGE_T1A_TTI_LTIMER_VAL	80
+#define VXGE_TTI_RTIMER_VAL	0
+#define VXGE_T1A_TTI_RTIMER_VAL	400
+#define VXGE_RTI_BTIMER_VAL	250
+#define VXGE_RTI_LTIMER_VAL	100
+#define VXGE_RTI_RTIMER_VAL	0
 #define VXGE_FIFO_INDICATE_MAX_PKTS VXGE_DEF_FIFO_LENGTH
 #define VXGE_ISR_POLLING_CNT 	8
 #define VXGE_MAX_CONFIG_DEV	0xFF
@@ -76,14 +81,32 @@
 #define TTI_TX_UFC_B	40
 #define TTI_TX_UFC_C	60
 #define TTI_TX_UFC_D	100
+#define TTI_T1A_TX_UFC_A	30
+#define TTI_T1A_TX_UFC_B	80
+/* Slope - (max_mtu - min_mtu)/(max_mtu_ufc - min_mtu_ufc) */
+/* Slope - 93 */
+/* 60 - 9k Mtu, 140 - 1.5k mtu */
+#define TTI_T1A_TX_UFC_C(mtu)	(60 + ((VXGE_HW_MAX_MTU - mtu) / 93))
+
+/* Slope - 37 */
+/* 100 - 9k Mtu, 300 - 1.5k mtu */
+#define TTI_T1A_TX_UFC_D(mtu)	(100 + ((VXGE_HW_MAX_MTU - mtu) / 37))
+
+
+#define RTI_RX_URANGE_A		5
+#define RTI_RX_URANGE_B		15
+#define RTI_RX_URANGE_C		40
+#define RTI_T1A_RX_URANGE_A	1
+#define RTI_T1A_RX_URANGE_B	20
+#define RTI_T1A_RX_URANGE_C	50
+#define RTI_RX_UFC_A		1
+#define RTI_RX_UFC_B		5
+#define RTI_RX_UFC_C		10
+#define RTI_RX_UFC_D		15
+#define RTI_T1A_RX_UFC_B	20
+#define RTI_T1A_RX_UFC_C	50
+#define RTI_T1A_RX_UFC_D	60
 
-#define RTI_RX_URANGE_A	5
-#define RTI_RX_URANGE_B	15
-#define RTI_RX_URANGE_C	40
-#define RTI_RX_UFC_A	1
-#define RTI_RX_UFC_B	5
-#define RTI_RX_UFC_C	10
-#define RTI_RX_UFC_D	15
 
 /* Milli secs timer period */
 #define VXGE_TIMER_DELAY		10000
@@ -329,7 +352,8 @@ struct vxgedev {
 
 	 /* A flag indicating whether rx_csum is to be used or not. */
 	u32	rx_csum:1,
-		rx_hwts:1;
+		rx_hwts:1,
+		titan1:1;
 
 	struct vxge_msix_entry *vxge_entries;
 	struct msix_entry *entries;
@@ -396,11 +420,6 @@ struct vxge_tx_priv {
 		mod_timer(&timer, (jiffies + exp)); \
 	} while (0);
 
-int __devinit vxge_device_register(struct __vxge_hw_device *devh,
-				    struct vxge_config *config,
-				    int high_dma, int no_of_vpath,
-				    struct vxgedev **vdev);
-
 void vxge_device_unregister(struct __vxge_hw_device *devh);
 
 void vxge_vpath_intr_enable(struct vxgedev *vdev, int vp_id);
-- 
1.7.0.4

