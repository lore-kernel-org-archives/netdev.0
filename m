From: Jeff Kirsher <jeffrey.t.kirsher@intel.com>
Subject: [net-next-2.6 06/14] ixgbe: add support to FCoE DDP in target mode
Date: Mon,  7 Mar 2011 18:25:00 -0800
Message-ID: <1299551108-23663-7-git-send-email-jeffrey.t.kirsher@intel.com>
References: <1299551108-23663-1-git-send-email-jeffrey.t.kirsher@intel.com>
Cc: Yi Zou <yi.zou@intel.com>, netdev@vger.kernel.org,
	gospo@redhat.com, bphilips@novell.com,
	Kiran Patil <kiran.patil@intel.com>,
	Jeff Kirsher <jeffrey.t.kirsher@intel.com>
To: davem@davemloft.net
Return-path: <netdev-owner@vger.kernel.org>
Received: from mga11.intel.com ([192.55.52.93]:14586 "EHLO mga11.intel.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1754543Ab1CHC0G (ORCPT <rfc822;netdev@vger.kernel.org>);
	Mon, 7 Mar 2011 21:26:06 -0500
In-Reply-To: <1299551108-23663-1-git-send-email-jeffrey.t.kirsher@intel.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Yi Zou <yi.zou@intel.com>

Add support to the ndo_fcoe_ddp_target() to allow the Intel 82599 device to
also provide DDP offload capability when the upper FCoE protocol stack is
operating as a target.

Signed-off-by: Yi Zou <yi.zou@intel.com>
Signed-off-by: Kiran Patil <kiran.patil@intel.com>
Signed-off-by: Jeff Kirsher <jeffrey.t.kirsher@intel.com>
---
 drivers/net/ixgbe/ixgbe.h      |    2 +
 drivers/net/ixgbe/ixgbe_fcoe.c |   86 ++++++++++++++++++++++++++++++++++------
 drivers/net/ixgbe/ixgbe_fcoe.h |    4 ++
 drivers/net/ixgbe/ixgbe_main.c |    1 +
 4 files changed, 81 insertions(+), 12 deletions(-)

diff --git a/drivers/net/ixgbe/ixgbe.h b/drivers/net/ixgbe/ixgbe.h
index b60b81b..1e546fc 100644
--- a/drivers/net/ixgbe/ixgbe.h
+++ b/drivers/net/ixgbe/ixgbe.h
@@ -552,6 +552,8 @@ extern int ixgbe_fcoe_ddp(struct ixgbe_adapter *adapter,
                           struct sk_buff *skb);
 extern int ixgbe_fcoe_ddp_get(struct net_device *netdev, u16 xid,
                               struct scatterlist *sgl, unsigned int sgc);
+extern int ixgbe_fcoe_ddp_target(struct net_device *netdev, u16 xid,
+				 struct scatterlist *sgl, unsigned int sgc);
 extern int ixgbe_fcoe_ddp_put(struct net_device *netdev, u16 xid);
 extern int ixgbe_fcoe_enable(struct net_device *netdev);
 extern int ixgbe_fcoe_disable(struct net_device *netdev);
diff --git a/drivers/net/ixgbe/ixgbe_fcoe.c b/drivers/net/ixgbe/ixgbe_fcoe.c
index 27203c8..00af15a 100644
--- a/drivers/net/ixgbe/ixgbe_fcoe.c
+++ b/drivers/net/ixgbe/ixgbe_fcoe.c
@@ -135,22 +135,19 @@ out_ddp_put:
 	return len;
 }
 
+
 /**
- * ixgbe_fcoe_ddp_get - called to set up ddp context
+ * ixgbe_fcoe_ddp_setup - called to set up ddp context
  * @netdev: the corresponding net_device
  * @xid: the exchange id requesting ddp
  * @sgl: the scatter-gather list for this request
  * @sgc: the number of scatter-gather items
  *
- * This is the implementation of net_device_ops.ndo_fcoe_ddp_setup
- * and is expected to be called from ULD, e.g., FCP layer of libfc
- * to set up ddp for the corresponding xid of the given sglist for
- * the corresponding I/O.
- *
  * Returns : 1 for success and 0 for no ddp
  */
-int ixgbe_fcoe_ddp_get(struct net_device *netdev, u16 xid,
-		       struct scatterlist *sgl, unsigned int sgc)
+static int ixgbe_fcoe_ddp_setup(struct net_device *netdev, u16 xid,
+				struct scatterlist *sgl, unsigned int sgc,
+				int target_mode)
 {
 	struct ixgbe_adapter *adapter;
 	struct ixgbe_hw *hw;
@@ -164,7 +161,7 @@ int ixgbe_fcoe_ddp_get(struct net_device *netdev, u16 xid,
 	unsigned int lastsize;
 	unsigned int thisoff = 0;
 	unsigned int thislen = 0;
-	u32 fcbuff, fcdmarw, fcfltrw;
+	u32 fcbuff, fcdmarw, fcfltrw, fcrxctl;
 	dma_addr_t addr = 0;
 
 	if (!netdev || !sgl)
@@ -275,6 +272,9 @@ int ixgbe_fcoe_ddp_get(struct net_device *netdev, u16 xid,
 	fcbuff = (IXGBE_FCBUFF_4KB << IXGBE_FCBUFF_BUFFSIZE_SHIFT);
 	fcbuff |= ((j & 0xff) << IXGBE_FCBUFF_BUFFCNT_SHIFT);
 	fcbuff |= (firstoff << IXGBE_FCBUFF_OFFSET_SHIFT);
+	/* Set WRCONTX bit to allow DDP for target */
+	if (target_mode)
+		fcbuff |= (IXGBE_FCBUFF_WRCONTX);
 	fcbuff |= (IXGBE_FCBUFF_VALID);
 
 	fcdmarw = xid;
@@ -287,6 +287,16 @@ int ixgbe_fcoe_ddp_get(struct net_device *netdev, u16 xid,
 	/* program DMA context */
 	hw = &adapter->hw;
 	spin_lock_bh(&fcoe->lock);
+
+	/* turn on last frame indication for target mode as FCP_RSPtarget is
+	 * supposed to send FCP_RSP when it is done. */
+	if (target_mode && !test_bit(__IXGBE_FCOE_TARGET, &fcoe->mode)) {
+		set_bit(__IXGBE_FCOE_TARGET, &fcoe->mode);
+		fcrxctl = IXGBE_READ_REG(hw, IXGBE_FCRXCTRL);
+		fcrxctl |= IXGBE_FCRXCTRL_LASTSEQH;
+		IXGBE_WRITE_REG(hw, IXGBE_FCRXCTRL, fcrxctl);
+	}
+
 	IXGBE_WRITE_REG(hw, IXGBE_FCPTRL, ddp->udp & DMA_BIT_MASK(32));
 	IXGBE_WRITE_REG(hw, IXGBE_FCPTRH, (u64)ddp->udp >> 32);
 	IXGBE_WRITE_REG(hw, IXGBE_FCBUFF, fcbuff);
@@ -295,6 +305,7 @@ int ixgbe_fcoe_ddp_get(struct net_device *netdev, u16 xid,
 	IXGBE_WRITE_REG(hw, IXGBE_FCPARAM, 0);
 	IXGBE_WRITE_REG(hw, IXGBE_FCFLT, IXGBE_FCFLT_VALID);
 	IXGBE_WRITE_REG(hw, IXGBE_FCFLTRW, fcfltrw);
+
 	spin_unlock_bh(&fcoe->lock);
 
 	return 1;
@@ -309,6 +320,47 @@ out_noddp_unmap:
 }
 
 /**
+ * ixgbe_fcoe_ddp_get - called to set up ddp context in initiator mode
+ * @netdev: the corresponding net_device
+ * @xid: the exchange id requesting ddp
+ * @sgl: the scatter-gather list for this request
+ * @sgc: the number of scatter-gather items
+ *
+ * This is the implementation of net_device_ops.ndo_fcoe_ddp_setup
+ * and is expected to be called from ULD, e.g., FCP layer of libfc
+ * to set up ddp for the corresponding xid of the given sglist for
+ * the corresponding I/O.
+ *
+ * Returns : 1 for success and 0 for no ddp
+ */
+int ixgbe_fcoe_ddp_get(struct net_device *netdev, u16 xid,
+		       struct scatterlist *sgl, unsigned int sgc)
+{
+	return ixgbe_fcoe_ddp_setup(netdev, xid, sgl, sgc, 0);
+}
+
+/**
+ * ixgbe_fcoe_ddp_target - called to set up ddp context in target mode
+ * @netdev: the corresponding net_device
+ * @xid: the exchange id requesting ddp
+ * @sgl: the scatter-gather list for this request
+ * @sgc: the number of scatter-gather items
+ *
+ * This is the implementation of net_device_ops.ndo_fcoe_ddp_target
+ * and is expected to be called from ULD, e.g., FCP layer of libfc
+ * to set up ddp for the corresponding xid of the given sglist for
+ * the corresponding I/O. The DDP in target mode is a write I/O request
+ * from the initiator.
+ *
+ * Returns : 1 for success and 0 for no ddp
+ */
+int ixgbe_fcoe_ddp_target(struct net_device *netdev, u16 xid,
+			    struct scatterlist *sgl, unsigned int sgc)
+{
+	return ixgbe_fcoe_ddp_setup(netdev, xid, sgl, sgc, 1);
+}
+
+/**
  * ixgbe_fcoe_ddp - check ddp status and mark it done
  * @adapter: ixgbe adapter
  * @rx_desc: advanced rx descriptor
@@ -331,6 +383,7 @@ int ixgbe_fcoe_ddp(struct ixgbe_adapter *adapter,
 	struct ixgbe_fcoe *fcoe;
 	struct ixgbe_fcoe_ddp *ddp;
 	struct fc_frame_header *fh;
+	struct fcoe_crc_eof *crc;
 
 	if (!ixgbe_rx_is_fcoe(rx_desc))
 		goto ddp_out;
@@ -384,7 +437,18 @@ int ixgbe_fcoe_ddp(struct ixgbe_adapter *adapter,
 		else if (ddp->len)
 			rc = ddp->len;
 	}
-
+	/* In target mode, check the last data frame of the sequence.
+	 * For DDP in target mode, data is already DDPed but the header
+	 * indication of the last data frame ould allow is to tell if we
+	 * got all the data and the ULP can send FCP_RSP back, as this is
+	 * not a full fcoe frame, we fill the trailer here so it won't be
+	 * dropped by the ULP stack.
+	 */
+	if ((fh->fh_r_ctl == FC_RCTL_DD_SOL_DATA) &&
+	    (fctl & FC_FC_END_SEQ)) {
+		crc = (struct fcoe_crc_eof *)skb_put(skb, sizeof(*crc));
+		crc->fcoe_eof = FC_EOF_T;
+	}
 ddp_out:
 	return rc;
 }
@@ -840,5 +904,3 @@ int ixgbe_fcoe_get_wwn(struct net_device *netdev, u64 *wwn, int type)
 	}
 	return rc;
 }
-
-
diff --git a/drivers/net/ixgbe/ixgbe_fcoe.h b/drivers/net/ixgbe/ixgbe_fcoe.h
index 02a00d2..5a650a4 100644
--- a/drivers/net/ixgbe/ixgbe_fcoe.h
+++ b/drivers/net/ixgbe/ixgbe_fcoe.h
@@ -52,6 +52,9 @@
 /* fcerr */
 #define IXGBE_FCERR_BADCRC       0x00100000
 
+/* FCoE DDP for target mode */
+#define __IXGBE_FCOE_TARGET	1
+
 struct ixgbe_fcoe_ddp {
 	int len;
 	u32 err;
@@ -66,6 +69,7 @@ struct ixgbe_fcoe {
 	u8 tc;
 	u8 up;
 #endif
+	unsigned long mode;
 	atomic_t refcnt;
 	spinlock_t lock;
 	struct pci_pool *pool;
diff --git a/drivers/net/ixgbe/ixgbe_main.c b/drivers/net/ixgbe/ixgbe_main.c
index 32231ff..5e8c39d 100644
--- a/drivers/net/ixgbe/ixgbe_main.c
+++ b/drivers/net/ixgbe/ixgbe_main.c
@@ -7019,6 +7019,7 @@ static const struct net_device_ops ixgbe_netdev_ops = {
 #endif
 #ifdef IXGBE_FCOE
 	.ndo_fcoe_ddp_setup = ixgbe_fcoe_ddp_get,
+	.ndo_fcoe_ddp_target = ixgbe_fcoe_ddp_target,
 	.ndo_fcoe_ddp_done = ixgbe_fcoe_ddp_put,
 	.ndo_fcoe_enable = ixgbe_fcoe_enable,
 	.ndo_fcoe_disable = ixgbe_fcoe_disable,
-- 
1.7.4

