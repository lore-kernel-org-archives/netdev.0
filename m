From: "Michael Chan" <mchan@broadcom.com>
Subject: [PATCH 6/8 net-next] cnic: Add cnic_uio_dev struct
Date: Wed, 13 Oct 2010 17:06:49 -0700
Message-ID: <1287014811-10979-7-git-send-email-mchan@broadcom.com>
References: <1287014811-10979-1-git-send-email-mchan@broadcom.com>
 <1287014811-10979-2-git-send-email-mchan@broadcom.com>
 <1287014811-10979-3-git-send-email-mchan@broadcom.com>
 <1287014811-10979-4-git-send-email-mchan@broadcom.com>
 <1287014811-10979-5-git-send-email-mchan@broadcom.com>
 <1287014811-10979-6-git-send-email-mchan@broadcom.com>
Mime-Version: 1.0
Content-Type: text/plain
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org
To: davem@davemloft.net
Return-path: <netdev-owner@vger.kernel.org>
Received: from mms2.broadcom.com ([216.31.210.18]:1605 "EHLO mms2.broadcom.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1753325Ab0JNBED (ORCPT <rfc822;netdev@vger.kernel.org>);
	Wed, 13 Oct 2010 21:04:03 -0400
In-Reply-To: <1287014811-10979-6-git-send-email-mchan@broadcom.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

and put all uio related structures and ring buffers in it.  This allows
uio operations to be done independent of the cnic device structures.

Signed-off-by: Michael Chan <mchan@broadcom.com>
---
 drivers/net/cnic.c |  195 ++++++++++++++++++++++++++++------------------------
 drivers/net/cnic.h |   29 +++++---
 2 files changed, 124 insertions(+), 100 deletions(-)

diff --git a/drivers/net/cnic.c b/drivers/net/cnic.c
index 739ffcb..e8f2836 100644
--- a/drivers/net/cnic.c
+++ b/drivers/net/cnic.c
@@ -89,22 +89,24 @@ static int cnic_cm_set_pg(struct cnic_sock *);
 
 static int cnic_uio_open(struct uio_info *uinfo, struct inode *inode)
 {
-	struct cnic_dev *dev = uinfo->priv;
-	struct cnic_local *cp = dev->cnic_priv;
+	struct cnic_uio_dev *udev = uinfo->priv;
+	struct cnic_dev *dev;
 
 	if (!capable(CAP_NET_ADMIN))
 		return -EPERM;
 
-	if (cp->uio_dev != -1)
+	if (udev->uio_dev != -1)
 		return -EBUSY;
 
 	rtnl_lock();
+	dev = udev->dev;
+
 	if (!test_bit(CNIC_F_CNIC_UP, &dev->flags)) {
 		rtnl_unlock();
 		return -ENODEV;
 	}
 
-	cp->uio_dev = iminor(inode);
+	udev->uio_dev = iminor(inode);
 
 	cnic_init_rings(dev);
 	rtnl_unlock();
@@ -114,12 +116,12 @@ static int cnic_uio_open(struct uio_info *uinfo, struct inode *inode)
 
 static int cnic_uio_close(struct uio_info *uinfo, struct inode *inode)
 {
-	struct cnic_dev *dev = uinfo->priv;
-	struct cnic_local *cp = dev->cnic_priv;
+	struct cnic_uio_dev *udev = uinfo->priv;
+	struct cnic_dev *dev = udev->dev;
 
 	cnic_shutdown_rings(dev);
 
-	cp->uio_dev = -1;
+	udev->uio_dev = -1;
 	return 0;
 }
 
@@ -276,8 +278,9 @@ static int cnic_send_nlmsg(struct cnic_local *cp, u32 type,
 	u16 len = 0;
 	u32 msg_type = ISCSI_KEVENT_IF_DOWN;
 	struct cnic_ulp_ops *ulp_ops;
+	struct cnic_uio_dev *udev = cp->udev;
 
-	if (cp->uio_dev == -1)
+	if (!udev || udev->uio_dev == -1)
 		return -ENODEV;
 
 	if (csk) {
@@ -408,8 +411,7 @@ static void cnic_uio_stop(void)
 	list_for_each_entry(dev, &cnic_dev_list, list) {
 		struct cnic_local *cp = dev->cnic_priv;
 
-		if (cp->cnic_uinfo)
-			cnic_send_nlmsg(cp, ISCSI_KEVENT_IF_DOWN, NULL);
+		cnic_send_nlmsg(cp, ISCSI_KEVENT_IF_DOWN, NULL);
 	}
 	read_unlock(&cnic_dev_lock);
 }
@@ -770,48 +772,44 @@ static void cnic_free_context(struct cnic_dev *dev)
 	}
 }
 
-static void __cnic_free_uio(struct cnic_dev *dev)
+static void __cnic_free_uio(struct cnic_uio_dev *udev)
 {
-	struct cnic_local *cp = dev->cnic_priv;
-
-	if (cp->cnic_uinfo)
-		uio_unregister_device(cp->cnic_uinfo);
+	uio_unregister_device(&udev->cnic_uinfo);
 
-	kfree(cp->cnic_uinfo);
-	cp->cnic_uinfo = NULL;
-
-	if (cp->l2_buf) {
-		dma_free_coherent(&dev->pcidev->dev, cp->l2_buf_size,
-				  cp->l2_buf, cp->l2_buf_map);
-		cp->l2_buf = NULL;
+	if (udev->l2_buf) {
+		dma_free_coherent(&udev->pdev->dev, udev->l2_buf_size,
+				  udev->l2_buf, udev->l2_buf_map);
+		udev->l2_buf = NULL;
 	}
 
-	if (cp->l2_ring) {
-		dma_free_coherent(&dev->pcidev->dev, cp->l2_ring_size,
-				  cp->l2_ring, cp->l2_ring_map);
-		cp->l2_ring = NULL;
+	if (udev->l2_ring) {
+		dma_free_coherent(&udev->pdev->dev, udev->l2_ring_size,
+				  udev->l2_ring, udev->l2_ring_map);
+		udev->l2_ring = NULL;
 	}
 }
 
-static void cnic_free_uio(struct cnic_dev *dev)
+static void cnic_free_uio(struct cnic_uio_dev *udev)
 {
-	if (!dev)
+	if (!udev)
 		return;
 
-	__cnic_free_uio(dev);
+	__cnic_free_uio(udev);
 }
 
 static void cnic_free_resc(struct cnic_dev *dev)
 {
 	struct cnic_local *cp = dev->cnic_priv;
+	struct cnic_uio_dev *udev = cp->udev;
 	int i = 0;
 
-	if (cp->cnic_uinfo) {
-		while (cp->uio_dev != -1 && i < 15) {
+	if (udev) {
+		while (udev->uio_dev != -1 && i < 15) {
 			msleep(100);
 			i++;
 		}
-		cnic_free_uio(dev);
+		cnic_free_uio(udev);
+		cp->udev = NULL;
 	}
 
 	cnic_free_context(dev);
@@ -913,37 +911,53 @@ static int cnic_alloc_kcq(struct cnic_dev *dev, struct kcq_info *info)
 	return 0;
 }
 
-static int cnic_alloc_l2_rings(struct cnic_dev *dev, int pages)
+static int cnic_alloc_uio_rings(struct cnic_dev *dev, int pages)
 {
 	struct cnic_local *cp = dev->cnic_priv;
+	struct cnic_uio_dev *udev;
+
+	udev = kzalloc(sizeof(struct cnic_uio_dev), GFP_ATOMIC);
+	if (!udev)
+		return -ENOMEM;
+
+	udev->uio_dev = -1;
 
-	cp->l2_ring_size = pages * BCM_PAGE_SIZE;
-	cp->l2_ring = dma_alloc_coherent(&dev->pcidev->dev, cp->l2_ring_size,
-					 &cp->l2_ring_map,
-					 GFP_KERNEL | __GFP_COMP);
-	if (!cp->l2_ring)
+	udev->dev = dev;
+	udev->pdev = dev->pcidev;
+	udev->l2_ring_size = pages * BCM_PAGE_SIZE;
+	udev->l2_ring = dma_alloc_coherent(&udev->pdev->dev, udev->l2_ring_size,
+					   &udev->l2_ring_map,
+					   GFP_KERNEL | __GFP_COMP);
+	if (!udev->l2_ring)
 		return -ENOMEM;
 
-	cp->l2_buf_size = (cp->l2_rx_ring_size + 1) * cp->l2_single_buf_size;
-	cp->l2_buf_size = PAGE_ALIGN(cp->l2_buf_size);
-	cp->l2_buf = dma_alloc_coherent(&dev->pcidev->dev, cp->l2_buf_size,
-					&cp->l2_buf_map,
-					GFP_KERNEL | __GFP_COMP);
-	if (!cp->l2_buf)
+	udev->l2_buf_size = (cp->l2_rx_ring_size + 1) * cp->l2_single_buf_size;
+	udev->l2_buf_size = PAGE_ALIGN(udev->l2_buf_size);
+	udev->l2_buf = dma_alloc_coherent(&udev->pdev->dev, udev->l2_buf_size,
+					  &udev->l2_buf_map,
+					  GFP_KERNEL | __GFP_COMP);
+	if (!udev->l2_buf)
 		return -ENOMEM;
 
+	cp->udev = udev;
+
 	return 0;
 }
 
-static int cnic_alloc_uio(struct cnic_dev *dev) {
+static int cnic_init_uio(struct cnic_dev *dev)
+{
 	struct cnic_local *cp = dev->cnic_priv;
+	struct cnic_uio_dev *udev = cp->udev;
 	struct uio_info *uinfo;
-	int ret;
+	int ret = 0;
 
-	uinfo = kzalloc(sizeof(*uinfo), GFP_ATOMIC);
-	if (!uinfo)
+	if (!udev)
 		return -ENOMEM;
 
+	udev->uio_dev = -1;
+
+	uinfo = &udev->cnic_uinfo;
+
 	uinfo->mem[0].addr = dev->netdev->base_addr;
 	uinfo->mem[0].internal_addr = dev->regview;
 	uinfo->mem[0].size = dev->netdev->mem_end - dev->netdev->mem_start;
@@ -951,7 +965,7 @@ static int cnic_alloc_uio(struct cnic_dev *dev) {
 
 	if (test_bit(CNIC_F_BNX2_CLASS, &dev->flags)) {
 		uinfo->mem[1].addr = (unsigned long) cp->status_blk.gen &
-			PAGE_MASK;
+					PAGE_MASK;
 		if (cp->ethdev->drv_state & CNIC_DRV_STATE_USING_MSIX)
 			uinfo->mem[1].size = BNX2_SBLK_MSIX_ALIGN_SIZE * 9;
 		else
@@ -968,12 +982,12 @@ static int cnic_alloc_uio(struct cnic_dev *dev) {
 
 	uinfo->mem[1].memtype = UIO_MEM_LOGICAL;
 
-	uinfo->mem[2].addr = (unsigned long) cp->l2_ring;
-	uinfo->mem[2].size = cp->l2_ring_size;
+	uinfo->mem[2].addr = (unsigned long) udev->l2_ring;
+	uinfo->mem[2].size = udev->l2_ring_size;
 	uinfo->mem[2].memtype = UIO_MEM_LOGICAL;
 
-	uinfo->mem[3].addr = (unsigned long) cp->l2_buf;
-	uinfo->mem[3].size = cp->l2_buf_size;
+	uinfo->mem[3].addr = (unsigned long) udev->l2_buf;
+	uinfo->mem[3].size = udev->l2_buf_size;
 	uinfo->mem[3].memtype = UIO_MEM_LOGICAL;
 
 	uinfo->version = CNIC_MODULE_VERSION;
@@ -982,16 +996,11 @@ static int cnic_alloc_uio(struct cnic_dev *dev) {
 	uinfo->open = cnic_uio_open;
 	uinfo->release = cnic_uio_close;
 
-	uinfo->priv = dev;
+	uinfo->priv = udev;
 
-	ret = uio_register_device(&dev->pcidev->dev, uinfo);
-	if (ret) {
-		kfree(uinfo);
-		return ret;
-	}
+	ret = uio_register_device(&udev->pdev->dev, uinfo);
 
-	cp->cnic_uinfo = uinfo;
-	return 0;
+	return ret;
 }
 
 static int cnic_alloc_bnx2_resc(struct cnic_dev *dev)
@@ -1012,11 +1021,11 @@ static int cnic_alloc_bnx2_resc(struct cnic_dev *dev)
 	if (ret)
 		goto error;
 
-	ret = cnic_alloc_l2_rings(dev, 2);
+	ret = cnic_alloc_uio_rings(dev, 2);
 	if (ret)
 		goto error;
 
-	ret = cnic_alloc_uio(dev);
+	ret = cnic_init_uio(dev);
 	if (ret)
 		goto error;
 
@@ -1150,11 +1159,11 @@ static int cnic_alloc_bnx2x_resc(struct cnic_dev *dev)
 
 	cp->l2_rx_ring_size = 15;
 
-	ret = cnic_alloc_l2_rings(dev, 4);
+	ret = cnic_alloc_uio_rings(dev, 4);
 	if (ret)
 		goto error;
 
-	ret = cnic_alloc_uio(dev);
+	ret = cnic_init_uio(dev);
 	if (ret)
 		goto error;
 
@@ -2226,8 +2235,9 @@ static int cnic_get_kcqes(struct cnic_dev *dev, struct kcq_info *info)
 static int cnic_l2_completion(struct cnic_local *cp)
 {
 	u16 hw_cons, sw_cons;
+	struct cnic_uio_dev *udev = cp->udev;
 	union eth_rx_cqe *cqe, *cqe_ring = (union eth_rx_cqe *)
-					(cp->l2_ring + (2 * BCM_PAGE_SIZE));
+					(udev->l2_ring + (2 * BCM_PAGE_SIZE));
 	u32 cmd;
 	int comp = 0;
 
@@ -2273,7 +2283,8 @@ static void cnic_chk_pkt_rings(struct cnic_local *cp)
 		cp->tx_cons = tx_cons;
 		cp->rx_cons = rx_cons;
 
-		uio_event_notify(cp->cnic_uinfo);
+		if (cp->udev)
+			uio_event_notify(&cp->udev->cnic_uinfo);
 	}
 	if (comp)
 		clear_bit(CNIC_LCL_FL_L2_WAIT, &cp->cnic_local_flags);
@@ -2435,8 +2446,7 @@ static void cnic_ulp_stop(struct cnic_dev *dev)
 	struct cnic_local *cp = dev->cnic_priv;
 	int if_type;
 
-	if (cp->cnic_uinfo)
-		cnic_send_nlmsg(cp, ISCSI_KEVENT_IF_DOWN, NULL);
+	cnic_send_nlmsg(cp, ISCSI_KEVENT_IF_DOWN, NULL);
 
 	for (if_type = 0; if_type < MAX_CNIC_ULP_TYPE; if_type++) {
 		struct cnic_ulp_ops *ulp_ops;
@@ -3658,11 +3668,12 @@ static void cnic_init_bnx2_tx_ring(struct cnic_dev *dev)
 {
 	struct cnic_local *cp = dev->cnic_priv;
 	struct cnic_eth_dev *ethdev = cp->ethdev;
+	struct cnic_uio_dev *udev = cp->udev;
 	u32 cid_addr, tx_cid, sb_id;
 	u32 val, offset0, offset1, offset2, offset3;
 	int i;
 	struct tx_bd *txbd;
-	dma_addr_t buf_map;
+	dma_addr_t buf_map, ring_map = udev->l2_ring_map;
 	struct status_block *s_blk = cp->status_blk.gen;
 
 	sb_id = cp->status_blk_num;
@@ -3704,18 +3715,18 @@ static void cnic_init_bnx2_tx_ring(struct cnic_dev *dev)
 	val = BNX2_L2CTX_CMD_TYPE_TYPE_L2 | (8 << 16);
 	cnic_ctx_wr(dev, cid_addr, offset1, val);
 
-	txbd = (struct tx_bd *) cp->l2_ring;
+	txbd = (struct tx_bd *) udev->l2_ring;
 
-	buf_map = cp->l2_buf_map;
+	buf_map = udev->l2_buf_map;
 	for (i = 0; i < MAX_TX_DESC_CNT; i++, txbd++) {
 		txbd->tx_bd_haddr_hi = (u64) buf_map >> 32;
 		txbd->tx_bd_haddr_lo = (u64) buf_map & 0xffffffff;
 	}
-	val = (u64) cp->l2_ring_map >> 32;
+	val = (u64) ring_map >> 32;
 	cnic_ctx_wr(dev, cid_addr, offset2, val);
 	txbd->tx_bd_haddr_hi = val;
 
-	val = (u64) cp->l2_ring_map & 0xffffffff;
+	val = (u64) ring_map & 0xffffffff;
 	cnic_ctx_wr(dev, cid_addr, offset3, val);
 	txbd->tx_bd_haddr_lo = val;
 }
@@ -3724,10 +3735,12 @@ static void cnic_init_bnx2_rx_ring(struct cnic_dev *dev)
 {
 	struct cnic_local *cp = dev->cnic_priv;
 	struct cnic_eth_dev *ethdev = cp->ethdev;
+	struct cnic_uio_dev *udev = cp->udev;
 	u32 cid_addr, sb_id, val, coal_reg, coal_val;
 	int i;
 	struct rx_bd *rxbd;
 	struct status_block *s_blk = cp->status_blk.gen;
+	dma_addr_t ring_map = udev->l2_ring_map;
 
 	sb_id = cp->status_blk_num;
 	cnic_init_context(dev, 2);
@@ -3761,22 +3774,22 @@ static void cnic_init_bnx2_rx_ring(struct cnic_dev *dev)
 		val = BNX2_L2CTX_L2_STATUSB_NUM(sb_id);
 	cnic_ctx_wr(dev, cid_addr, BNX2_L2CTX_HOST_BDIDX, val);
 
-	rxbd = (struct rx_bd *) (cp->l2_ring + BCM_PAGE_SIZE);
+	rxbd = (struct rx_bd *) (udev->l2_ring + BCM_PAGE_SIZE);
 	for (i = 0; i < MAX_RX_DESC_CNT; i++, rxbd++) {
 		dma_addr_t buf_map;
 		int n = (i % cp->l2_rx_ring_size) + 1;
 
-		buf_map = cp->l2_buf_map + (n * cp->l2_single_buf_size);
+		buf_map = udev->l2_buf_map + (n * cp->l2_single_buf_size);
 		rxbd->rx_bd_len = cp->l2_single_buf_size;
 		rxbd->rx_bd_flags = RX_BD_FLAGS_START | RX_BD_FLAGS_END;
 		rxbd->rx_bd_haddr_hi = (u64) buf_map >> 32;
 		rxbd->rx_bd_haddr_lo = (u64) buf_map & 0xffffffff;
 	}
-	val = (u64) (cp->l2_ring_map + BCM_PAGE_SIZE) >> 32;
+	val = (u64) (ring_map + BCM_PAGE_SIZE) >> 32;
 	cnic_ctx_wr(dev, cid_addr, BNX2_L2CTX_NX_BDHADDR_HI, val);
 	rxbd->rx_bd_haddr_hi = val;
 
-	val = (u64) (cp->l2_ring_map + BCM_PAGE_SIZE) & 0xffffffff;
+	val = (u64) (ring_map + BCM_PAGE_SIZE) & 0xffffffff;
 	cnic_ctx_wr(dev, cid_addr, BNX2_L2CTX_NX_BDHADDR_LO, val);
 	rxbd->rx_bd_haddr_lo = val;
 
@@ -4038,8 +4051,9 @@ static void cnic_init_bnx2x_tx_ring(struct cnic_dev *dev,
 				    struct client_init_ramrod_data *data)
 {
 	struct cnic_local *cp = dev->cnic_priv;
-	union eth_tx_bd_types *txbd = (union eth_tx_bd_types *) cp->l2_ring;
-	dma_addr_t buf_map, ring_map = cp->l2_ring_map;
+	struct cnic_uio_dev *udev = cp->udev;
+	union eth_tx_bd_types *txbd = (union eth_tx_bd_types *) udev->l2_ring;
+	dma_addr_t buf_map, ring_map = udev->l2_ring_map;
 	struct host_sp_status_block *sb = cp->bnx2x_def_status_blk;
 	int port = CNIC_PORT(cp);
 	int i;
@@ -4048,7 +4062,7 @@ static void cnic_init_bnx2x_tx_ring(struct cnic_dev *dev,
 
 	memset(txbd, 0, BCM_PAGE_SIZE);
 
-	buf_map = cp->l2_buf_map;
+	buf_map = udev->l2_buf_map;
 	for (i = 0; i < MAX_TX_DESC_CNT; i += 3, txbd += 3) {
 		struct eth_tx_start_bd *start_bd = &txbd->start_bd;
 		struct eth_tx_bd *reg_bd = &((txbd + 2)->reg_bd);
@@ -4096,17 +4110,18 @@ static void cnic_init_bnx2x_rx_ring(struct cnic_dev *dev,
 				    struct client_init_ramrod_data *data)
 {
 	struct cnic_local *cp = dev->cnic_priv;
-	struct eth_rx_bd *rxbd = (struct eth_rx_bd *) (cp->l2_ring +
+	struct cnic_uio_dev *udev = cp->udev;
+	struct eth_rx_bd *rxbd = (struct eth_rx_bd *) (udev->l2_ring +
 				BCM_PAGE_SIZE);
 	struct eth_rx_cqe_next_page *rxcqe = (struct eth_rx_cqe_next_page *)
-				(cp->l2_ring + (2 * BCM_PAGE_SIZE));
+				(udev->l2_ring + (2 * BCM_PAGE_SIZE));
 	struct host_sp_status_block *sb = cp->bnx2x_def_status_blk;
 	int i;
 	int port = CNIC_PORT(cp);
 	int cli = BNX2X_ISCSI_CL_ID(CNIC_E1HVN(cp));
 	int cl_qzone_id = BNX2X_CL_QZONE_ID(cp, cli);
 	u32 val;
-	dma_addr_t ring_map = cp->l2_ring_map;
+	dma_addr_t ring_map = udev->l2_ring_map;
 
 	/* General data */
 	data->general.client_id = cli;
@@ -4119,7 +4134,7 @@ static void cnic_init_bnx2x_rx_ring(struct cnic_dev *dev,
 		dma_addr_t buf_map;
 		int n = (i % cp->l2_rx_ring_size) + 1;
 
-		buf_map = cp->l2_buf_map + (n * cp->l2_single_buf_size);
+		buf_map = udev->l2_buf_map + (n * cp->l2_single_buf_size);
 		rxbd->addr_hi = cpu_to_le32((u64) buf_map >> 32);
 		rxbd->addr_lo = cpu_to_le32(buf_map & 0xffffffff);
 	}
@@ -4320,6 +4335,7 @@ static int cnic_start_bnx2x_hw(struct cnic_dev *dev)
 static void cnic_init_rings(struct cnic_dev *dev)
 {
 	struct cnic_local *cp = dev->cnic_priv;
+	struct cnic_uio_dev *udev = cp->udev;
 
 	if (test_bit(CNIC_LCL_FL_RINGS_INITED, &cp->cnic_local_flags))
 		return;
@@ -4350,15 +4366,15 @@ static void cnic_init_rings(struct cnic_dev *dev)
 
 		set_bit(CNIC_LCL_FL_L2_WAIT, &cp->cnic_local_flags);
 
-		data = cp->l2_buf;
+		data = udev->l2_buf;
 
 		memset(data, 0, sizeof(*data));
 
 		cnic_init_bnx2x_tx_ring(dev, data);
 		cnic_init_bnx2x_rx_ring(dev, data);
 
-		l5_data.phy_address.lo = cp->l2_buf_map & 0xffffffff;
-		l5_data.phy_address.hi = (u64) cp->l2_buf_map >> 32;
+		l5_data.phy_address.lo = udev->l2_buf_map & 0xffffffff;
+		l5_data.phy_address.hi = (u64) udev->l2_buf_map >> 32;
 
 		type = (ETH_CONNECTION_TYPE << SPE_HDR_CONN_TYPE_SHIFT)
 			& SPE_HDR_CONN_TYPE;
@@ -4539,7 +4555,7 @@ static void cnic_stop_hw(struct cnic_dev *dev)
 		/* Need to wait for the ring shutdown event to complete
 		 * before clearing the CNIC_UP flag.
 		 */
-		while (cp->uio_dev != -1 && i < 15) {
+		while (cp->udev->uio_dev != -1 && i < 15) {
 			msleep(100);
 			i++;
 		}
@@ -4591,7 +4607,6 @@ static struct cnic_dev *cnic_alloc_dev(struct net_device *dev,
 
 	cp = cdev->cnic_priv;
 	cp->dev = cdev;
-	cp->uio_dev = -1;
 	cp->l2_single_buf_size = 0x400;
 	cp->l2_rx_ring_size = 3;
 
diff --git a/drivers/net/cnic.h b/drivers/net/cnic.h
index 47cd801..928af9e 100644
--- a/drivers/net/cnic.h
+++ b/drivers/net/cnic.h
@@ -195,6 +195,23 @@ struct iro {
 	u16 size;
 };
 
+struct cnic_uio_dev {
+	struct uio_info		cnic_uinfo;
+	u32			uio_dev;
+
+	int			l2_ring_size;
+	void			*l2_ring;
+	dma_addr_t		l2_ring_map;
+
+	int			l2_buf_size;
+	void			*l2_buf;
+	dma_addr_t		l2_buf_map;
+
+	struct cnic_dev		*dev;
+	struct pci_dev		*pdev;
+	struct list_head	list;
+};
+
 struct cnic_local {
 
 	spinlock_t cnic_ulp_lock;
@@ -214,14 +231,9 @@ struct cnic_local {
 
 	struct cnic_eth_dev *ethdev;
 
-	void		*l2_ring;
-	dma_addr_t	l2_ring_map;
-	int		l2_ring_size;
-	int		l2_rx_ring_size;
+	struct cnic_uio_dev *udev;
 
-	void		*l2_buf;
-	dma_addr_t	l2_buf_map;
-	int		l2_buf_size;
+	int		l2_rx_ring_size;
 	int		l2_single_buf_size;
 
 	u16		*rx_cons_ptr;
@@ -301,9 +313,6 @@ struct cnic_local {
 	u32			pfid;
 	u32			shmem_base;
 
-	u32			uio_dev;
-	struct uio_info		*cnic_uinfo;
-
 	struct cnic_ops		*cnic_ops;
 	int			(*start_hw)(struct cnic_dev *);
 	void			(*stop_hw)(struct cnic_dev *);
-- 
1.6.4.GIT


