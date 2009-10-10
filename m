From: "Michael Chan" <mchan@broadcom.com>
Subject: [PATCH 5/7] cnic: Refactor some code.
Date: Sat, 10 Oct 2009 16:46:57 -0700
Message-ID: <1255218419-17320-5-git-send-email-mchan@broadcom.com>
References: <1255218419-17320-1-git-send-email-mchan@broadcom.com>
Mime-Version: 1.0
Content-Type: text/plain
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, michaelc@cs.wisc.edu,
	shmulikr@broadcom.com, eilong@broadcom.com,
	"Michael Chan" <mchan@broadcom.com>
To: davem@davemloft.net
Return-path: <netdev-owner@vger.kernel.org>
Received: from mms2.broadcom.com ([216.31.210.18]:2223 "EHLO mms2.broadcom.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1757985AbZJJXjL (ORCPT <rfc822;netdev@vger.kernel.org>);
	Sat, 10 Oct 2009 19:39:11 -0400
In-Reply-To: <1255218419-17320-1-git-send-email-mchan@broadcom.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Refactor ring init. code for subsequent 10G patches.  Also add rtnl_lock()
in cnic_uio_open() to prevent race condition with netdev events.

Signed-off-by: Michael Chan <mchan@broadcom.com>
---
 drivers/net/cnic.c |   64 +++++++++++++++++++++++++++++++++++++--------------
 1 files changed, 46 insertions(+), 18 deletions(-)

diff --git a/drivers/net/cnic.c b/drivers/net/cnic.c
index 46c87ec..eac68f9 100644
--- a/drivers/net/cnic.c
+++ b/drivers/net/cnic.c
@@ -67,9 +67,8 @@ static struct cnic_ops cnic_bnx2_ops = {
 	.cnic_ctl	= cnic_ctl,
 };
 
-static void cnic_shutdown_bnx2_rx_ring(struct cnic_dev *);
-static void cnic_init_bnx2_tx_ring(struct cnic_dev *);
-static void cnic_init_bnx2_rx_ring(struct cnic_dev *);
+static void cnic_shutdown_rings(struct cnic_dev *);
+static void cnic_init_rings(struct cnic_dev *);
 static int cnic_cm_set_pg(struct cnic_sock *);
 
 static int cnic_uio_open(struct uio_info *uinfo, struct inode *inode)
@@ -83,10 +82,16 @@ static int cnic_uio_open(struct uio_info *uinfo, struct inode *inode)
 	if (cp->uio_dev != -1)
 		return -EBUSY;
 
+	rtnl_lock();
+	if (!test_bit(CNIC_F_CNIC_UP, &dev->flags)) {
+		rtnl_unlock();
+		return -ENODEV;
+	}
+
 	cp->uio_dev = iminor(inode);
 
-	cnic_init_bnx2_tx_ring(dev);
-	cnic_init_bnx2_rx_ring(dev);
+	cnic_init_rings(dev);
+	rtnl_unlock();
 
 	return 0;
 }
@@ -96,7 +101,7 @@ static int cnic_uio_close(struct uio_info *uinfo, struct inode *inode)
 	struct cnic_dev *dev = uinfo->priv;
 	struct cnic_local *cp = dev->cnic_priv;
 
-	cnic_shutdown_bnx2_rx_ring(dev);
+	cnic_shutdown_rings(dev);
 
 	cp->uio_dev = -1;
 	return 0;
@@ -675,6 +680,21 @@ error:
 	return -ENOMEM;
 }
 
+static void cnic_free_context(struct cnic_dev *dev)
+{
+	struct cnic_local *cp = dev->cnic_priv;
+	int i;
+
+	for (i = 0; i < cp->ctx_blks; i++) {
+		if (cp->ctx_arr[i].ctx) {
+			pci_free_consistent(dev->pcidev, cp->ctx_blk_size,
+					    cp->ctx_arr[i].ctx,
+					    cp->ctx_arr[i].mapping);
+			cp->ctx_arr[i].ctx = NULL;
+		}
+	}
+}
+
 static void cnic_free_resc(struct cnic_dev *dev)
 {
 	struct cnic_local *cp = dev->cnic_priv;
@@ -702,14 +722,7 @@ static void cnic_free_resc(struct cnic_dev *dev)
 		cp->l2_ring = NULL;
 	}
 
-	for (i = 0; i < cp->ctx_blks; i++) {
-		if (cp->ctx_arr[i].ctx) {
-			pci_free_consistent(dev->pcidev, cp->ctx_blk_size,
-					    cp->ctx_arr[i].ctx,
-					    cp->ctx_arr[i].mapping);
-			cp->ctx_arr[i].ctx = NULL;
-		}
-	}
+	cnic_free_context(dev);
 	kfree(cp->ctx_arr);
 	cp->ctx_arr = NULL;
 	cp->ctx_blks = 0;
@@ -808,8 +821,8 @@ static int cnic_alloc_uio(struct cnic_dev *dev) {
 	uinfo->mem[0].size = dev->netdev->mem_end - dev->netdev->mem_start;
 	uinfo->mem[0].memtype = UIO_MEM_PHYS;
 
-	uinfo->mem[1].addr = (unsigned long) cp->status_blk & PAGE_MASK;
 	if (test_bit(CNIC_F_BNX2_CLASS, &dev->flags)) {
+		uinfo->mem[1].addr = (unsigned long) cp->status_blk & PAGE_MASK;
 		if (cp->ethdev->drv_state & CNIC_DRV_STATE_USING_MSIX)
 			uinfo->mem[1].size = BNX2_SBLK_MSIX_ALIGN_SIZE * 9;
 		else
@@ -1012,7 +1025,7 @@ static int cnic_get_kcqes(struct cnic_dev *dev, u16 hw_prod, u16 *sw_prod)
 	return last_cnt;
 }
 
-static void cnic_chk_bnx2_pkt_rings(struct cnic_local *cp)
+static void cnic_chk_pkt_rings(struct cnic_local *cp)
 {
 	u16 rx_cons = *cp->rx_cons_ptr;
 	u16 tx_cons = *cp->tx_cons_ptr;
@@ -1062,7 +1075,7 @@ done:
 
 	cp->kcq_prod_idx = sw_prod;
 
-	cnic_chk_bnx2_pkt_rings(cp);
+	cnic_chk_pkt_rings(cp);
 	return status_idx;
 }
 
@@ -1100,7 +1113,7 @@ done:
 	CNIC_WR16(dev, cp->kcq_io_addr, sw_prod);
 	cp->kcq_prod_idx = sw_prod;
 
-	cnic_chk_bnx2_pkt_rings(cp);
+	cnic_chk_pkt_rings(cp);
 
 	cp->last_status_idx = status_idx;
 	CNIC_WR(dev, BNX2_PCICFG_INT_ACK_CMD, cp->int_num |
@@ -2464,6 +2477,21 @@ static int cnic_start_bnx2_hw(struct cnic_dev *dev)
 	return 0;
 }
 
+static void cnic_init_rings(struct cnic_dev *dev)
+{
+	if (test_bit(CNIC_F_BNX2_CLASS, &dev->flags)) {
+		cnic_init_bnx2_tx_ring(dev);
+		cnic_init_bnx2_rx_ring(dev);
+	}
+}
+
+static void cnic_shutdown_rings(struct cnic_dev *dev)
+{
+	if (test_bit(CNIC_F_BNX2_CLASS, &dev->flags)) {
+		cnic_shutdown_bnx2_rx_ring(dev);
+	}
+}
+
 static int cnic_register_netdev(struct cnic_dev *dev)
 {
 	struct cnic_local *cp = dev->cnic_priv;
-- 
1.6.4.GIT


