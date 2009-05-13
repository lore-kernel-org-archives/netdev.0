From: Jeff Kirsher <jeffrey.t.kirsher@intel.com>
Subject: [net-next-2.6 PATCH 6/8] ixgbe: Add infrastructure code for FCoE
	large receive offload to 82599
Date: Wed, 13 May 2009 16:11:29 -0700
Message-ID: <20090513231129.11416.23975.stgit@localhost.localdomain>
References: <20090513230924.11416.68752.stgit@localhost.localdomain>
Mime-Version: 1.0
Content-Type: text/plain; charset="utf-8"
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, linux-scsi@vger.kernel.org,
	Yi Zou <yi.zou@intel.com>,
	Chris Leech <christopher.leech@intel.com>,
	Jeff Kirsher <jeffrey.t.kirsher@intel.com>
To: davem@davemloft.net
Return-path: <netdev-owner@vger.kernel.org>
Received: from qmta01.westchester.pa.mail.comcast.net ([76.96.62.16]:49905
	"EHLO QMTA01.westchester.pa.mail.comcast.net" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with ESMTP id S1761463AbZEMXLv (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 13 May 2009 19:11:51 -0400
In-Reply-To: <20090513230924.11416.68752.stgit@localhost.localdomain>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Yi Zou <yi.zou@intel.com>

This adds infrastructure code for FCoE Rx side offload feature to
82599, which provides large receive offload for FCoE by Direct
Data Placement (DDP). The ixgbe_fcoe_ddp_get() and ixgbe_fcoe_ddp_put()
pair corresponds to the netdev support to FCoE by the function pointers
provided in net_device_ops as ndo_fcoe_ddp_setup and ndo_fcoe_ddp_done.
The implementation of these in ixgbe is shown in the next patch.

Signed-off-by: Yi Zou <yi.zou@intel.com>
Signed-off-by: Chris Leech <christopher.leech@intel.com>
Signed-off-by: Jeff Kirsher <jeffrey.t.kirsher@intel.com>
---

 drivers/net/ixgbe/ixgbe.h      |    3 
 drivers/net/ixgbe/ixgbe_fcoe.c |  340 ++++++++++++++++++++++++++++++++++++++++
 drivers/net/ixgbe/ixgbe_fcoe.h |    2 
 3 files changed, 344 insertions(+), 1 deletions(-)

diff --git a/drivers/net/ixgbe/ixgbe.h b/drivers/net/ixgbe/ixgbe.h
index 06859f6..5581fa3 100644
--- a/drivers/net/ixgbe/ixgbe.h
+++ b/drivers/net/ixgbe/ixgbe.h
@@ -336,6 +336,9 @@ struct ixgbe_adapter {
 	struct timer_list sfp_timer;
 	struct work_struct multispeed_fiber_task;
 	struct work_struct sfp_config_module_task;
+#ifdef IXGBE_FCOE
+	struct ixgbe_fcoe fcoe;
+#endif /* IXGBE_FCOE */
 	u64 rsc_count;
 	u32 wol;
 	u16 eeprom_version;
diff --git a/drivers/net/ixgbe/ixgbe_fcoe.c b/drivers/net/ixgbe/ixgbe_fcoe.c
index e20facd..a11c620 100644
--- a/drivers/net/ixgbe/ixgbe_fcoe.c
+++ b/drivers/net/ixgbe/ixgbe_fcoe.c
@@ -36,6 +36,311 @@
 #include <scsi/libfcoe.h>
 
 /**
+ * ixgbe_rx_is_fcoe - check the rx desc for incoming pkt type
+ * @rx_desc: advanced rx descriptor
+ *
+ * Returns : true if it is FCoE pkt
+ */
+static inline bool ixgbe_rx_is_fcoe(union ixgbe_adv_rx_desc *rx_desc)
+{
+	u16 p;
+
+	p = le16_to_cpu(rx_desc->wb.lower.lo_dword.hs_rss.pkt_info);
+	if (p & IXGBE_RXDADV_PKTTYPE_ETQF) {
+		p &= IXGBE_RXDADV_PKTTYPE_ETQF_MASK;
+		p >>= IXGBE_RXDADV_PKTTYPE_ETQF_SHIFT;
+		return p == IXGBE_ETQF_FILTER_FCOE;
+	}
+	return false;
+}
+
+/**
+ * ixgbe_fcoe_clear_ddp - clear the given ddp context
+ * @ddp - ptr to the ixgbe_fcoe_ddp
+ *
+ * Returns : none
+ *
+ */
+static inline void ixgbe_fcoe_clear_ddp(struct ixgbe_fcoe_ddp *ddp)
+{
+	ddp->len = 0;
+	ddp->err = 0;
+	ddp->udl = NULL;
+	ddp->udp = 0UL;
+	ddp->sgl = NULL;
+	ddp->sgc = 0;
+}
+
+/**
+ * ixgbe_fcoe_ddp_put - free the ddp context for a given xid
+ * @netdev: the corresponding net_device
+ * @xid: the xid that corresponding ddp will be freed
+ *
+ * This is the implementation of net_device_ops.ndo_fcoe_ddp_done
+ * and it is expected to be called by ULD, i.e., FCP layer of libfc
+ * to release the corresponding ddp context when the I/O is done.
+ *
+ * Returns : data length already ddp-ed in bytes
+ */
+int ixgbe_fcoe_ddp_put(struct net_device *netdev, u16 xid)
+{
+	int len = 0;
+	struct ixgbe_fcoe *fcoe;
+	struct ixgbe_adapter *adapter;
+	struct ixgbe_fcoe_ddp *ddp;
+
+	if (!netdev)
+		goto out_ddp_put;
+
+	if (xid >= IXGBE_FCOE_DDP_MAX)
+		goto out_ddp_put;
+
+	adapter = netdev_priv(netdev);
+	fcoe = &adapter->fcoe;
+	ddp = &fcoe->ddp[xid];
+	if (!ddp->udl)
+		goto out_ddp_put;
+
+	len = ddp->len;
+	/* if there an error, force to invalidate ddp context */
+	if (ddp->err) {
+		spin_lock_bh(&fcoe->lock);
+		IXGBE_WRITE_REG(&adapter->hw, IXGBE_FCFLT, 0);
+		IXGBE_WRITE_REG(&adapter->hw, IXGBE_FCFLTRW,
+				(xid | IXGBE_FCFLTRW_WE));
+		IXGBE_WRITE_REG(&adapter->hw, IXGBE_FCBUFF, 0);
+		IXGBE_WRITE_REG(&adapter->hw, IXGBE_FCDMARW,
+				(xid | IXGBE_FCDMARW_WE));
+		spin_unlock_bh(&fcoe->lock);
+	}
+	if (ddp->sgl)
+		pci_unmap_sg(adapter->pdev, ddp->sgl, ddp->sgc,
+			     DMA_FROM_DEVICE);
+	pci_pool_free(fcoe->pool, ddp->udl, ddp->udp);
+	ixgbe_fcoe_clear_ddp(ddp);
+
+out_ddp_put:
+	return len;
+}
+
+/**
+ * ixgbe_fcoe_ddp_get - called to set up ddp context
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
+	struct ixgbe_adapter *adapter;
+	struct ixgbe_hw *hw;
+	struct ixgbe_fcoe *fcoe;
+	struct ixgbe_fcoe_ddp *ddp;
+	struct scatterlist *sg;
+	unsigned int i, j, dmacount;
+	unsigned int len;
+	static const unsigned int bufflen = 4096;
+	unsigned int firstoff = 0;
+	unsigned int lastsize;
+	unsigned int thisoff = 0;
+	unsigned int thislen = 0;
+	u32 fcbuff, fcdmarw, fcfltrw;
+	dma_addr_t addr;
+
+	if (!netdev || !sgl)
+		return 0;
+
+	adapter = netdev_priv(netdev);
+	if (xid >= IXGBE_FCOE_DDP_MAX) {
+		DPRINTK(DRV, WARNING, "xid=0x%x out-of-range\n", xid);
+		return 0;
+	}
+
+	fcoe = &adapter->fcoe;
+	if (!fcoe->pool) {
+		DPRINTK(DRV, WARNING, "xid=0x%x no ddp pool for fcoe\n", xid);
+		return 0;
+	}
+
+	ddp = &fcoe->ddp[xid];
+	if (ddp->sgl) {
+		DPRINTK(DRV, ERR, "xid 0x%x w/ non-null sgl=%p nents=%d\n",
+			xid, ddp->sgl, ddp->sgc);
+		return 0;
+	}
+	ixgbe_fcoe_clear_ddp(ddp);
+
+	/* setup dma from scsi command sgl */
+	dmacount = pci_map_sg(adapter->pdev, sgl, sgc, DMA_FROM_DEVICE);
+	if (dmacount == 0) {
+		DPRINTK(DRV, ERR, "xid 0x%x DMA map error\n", xid);
+		return 0;
+	}
+
+	/* alloc the udl from our ddp pool */
+	ddp->udl = pci_pool_alloc(fcoe->pool, GFP_KERNEL, &ddp->udp);
+	if (!ddp->udl) {
+		DPRINTK(DRV, ERR, "failed allocated ddp context\n");
+		goto out_noddp_unmap;
+	}
+	ddp->sgl = sgl;
+	ddp->sgc = sgc;
+
+	j = 0;
+	for_each_sg(sgl, sg, dmacount, i) {
+		addr = sg_dma_address(sg);
+		len = sg_dma_len(sg);
+		while (len) {
+			/* get the offset of length of current buffer */
+			thisoff = addr & ((dma_addr_t)bufflen - 1);
+			thislen = min((bufflen - thisoff), len);
+			/*
+			 * all but the 1st buffer (j == 0)
+			 * must be aligned on bufflen
+			 */
+			if ((j != 0) && (thisoff))
+				goto out_noddp_free;
+			/*
+			 * all but the last buffer
+			 * ((i == (dmacount - 1)) && (thislen == len))
+			 * must end at bufflen
+			 */
+			if (((i != (dmacount - 1)) || (thislen != len))
+			    && ((thislen + thisoff) != bufflen))
+				goto out_noddp_free;
+
+			ddp->udl[j] = (u64)(addr - thisoff);
+			/* only the first buffer may have none-zero offset */
+			if (j == 0)
+				firstoff = thisoff;
+			len -= thislen;
+			addr += thislen;
+			j++;
+			/* max number of buffers allowed in one DDP context */
+			if (j > IXGBE_BUFFCNT_MAX) {
+				DPRINTK(DRV, ERR, "xid=%x:%d,%d,%d:addr=%llx "
+					"not enough descriptors\n",
+					xid, i, j, dmacount, (u64)addr);
+				goto out_noddp_free;
+			}
+		}
+	}
+	/* only the last buffer may have non-full bufflen */
+	lastsize = thisoff + thislen;
+
+	fcbuff = (IXGBE_FCBUFF_4KB << IXGBE_FCBUFF_BUFFSIZE_SHIFT);
+	fcbuff |= (j << IXGBE_FCBUFF_BUFFCNT_SHIFT);
+	fcbuff |= (firstoff << IXGBE_FCBUFF_OFFSET_SHIFT);
+	fcbuff |= (IXGBE_FCBUFF_VALID);
+
+	fcdmarw = xid;
+	fcdmarw |= IXGBE_FCDMARW_WE;
+	fcdmarw |= (lastsize << IXGBE_FCDMARW_LASTSIZE_SHIFT);
+
+	fcfltrw = xid;
+	fcfltrw |= IXGBE_FCFLTRW_WE;
+
+	/* program DMA context */
+	hw = &adapter->hw;
+	spin_lock_bh(&fcoe->lock);
+	IXGBE_WRITE_REG(hw, IXGBE_FCPTRL, ddp->udp & DMA_32BIT_MASK);
+	IXGBE_WRITE_REG(hw, IXGBE_FCPTRH, (u64)ddp->udp >> 32);
+	IXGBE_WRITE_REG(hw, IXGBE_FCBUFF, fcbuff);
+	IXGBE_WRITE_REG(hw, IXGBE_FCDMARW, fcdmarw);
+	/* program filter context */
+	IXGBE_WRITE_REG(hw, IXGBE_FCPARAM, 0);
+	IXGBE_WRITE_REG(hw, IXGBE_FCFLT, IXGBE_FCFLT_VALID);
+	IXGBE_WRITE_REG(hw, IXGBE_FCFLTRW, fcfltrw);
+	spin_unlock_bh(&fcoe->lock);
+
+	return 1;
+
+out_noddp_free:
+	pci_pool_free(fcoe->pool, ddp->udl, ddp->udp);
+	ixgbe_fcoe_clear_ddp(ddp);
+
+out_noddp_unmap:
+	pci_unmap_sg(adapter->pdev, sgl, sgc, DMA_FROM_DEVICE);
+	return 0;
+}
+
+/**
+ * ixgbe_fcoe_ddp - check ddp status and mark it done
+ * @adapter: ixgbe adapter
+ * @rx_desc: advanced rx descriptor
+ * @skb: the skb holding the received data
+ *
+ * This checks ddp status.
+ *
+ * Returns : 0 for success and skb will not be delivered to ULD
+ */
+int ixgbe_fcoe_ddp(struct ixgbe_adapter *adapter,
+		   union ixgbe_adv_rx_desc *rx_desc,
+		   struct sk_buff *skb)
+{
+	u16 xid;
+	u32 sterr, fceofe, fcerr, fcstat;
+	int rc = -EINVAL;
+	struct ixgbe_fcoe *fcoe;
+	struct ixgbe_fcoe_ddp *ddp;
+	struct fc_frame_header *fh;
+
+	if (!ixgbe_rx_is_fcoe(rx_desc))
+		goto ddp_out;
+
+	skb->ip_summed = CHECKSUM_UNNECESSARY;
+	sterr = le32_to_cpu(rx_desc->wb.upper.status_error);
+	fcerr = (sterr & IXGBE_RXDADV_ERR_FCERR);
+	fceofe = (sterr & IXGBE_RXDADV_ERR_FCEOFE);
+	if (fcerr == IXGBE_FCERR_BADCRC)
+		skb->ip_summed = CHECKSUM_NONE;
+
+	skb_reset_network_header(skb);
+	skb_set_transport_header(skb, skb_network_offset(skb) +
+				 sizeof(struct fcoe_hdr));
+	fh = (struct fc_frame_header *)skb_transport_header(skb);
+	xid =  be16_to_cpu(fh->fh_ox_id);
+	if (xid >= IXGBE_FCOE_DDP_MAX)
+		goto ddp_out;
+
+	fcoe = &adapter->fcoe;
+	ddp = &fcoe->ddp[xid];
+	if (!ddp->udl)
+		goto ddp_out;
+
+	ddp->err = (fcerr | fceofe);
+	if (ddp->err)
+		goto ddp_out;
+
+	fcstat = (sterr & IXGBE_RXDADV_STAT_FCSTAT);
+	if (fcstat) {
+		/* update length of DDPed data */
+		ddp->len = le32_to_cpu(rx_desc->wb.lower.hi_dword.rss);
+		/* unmap the sg list when FCP_RSP is received */
+		if (fcstat == IXGBE_RXDADV_STAT_FCSTAT_FCPRSP) {
+			pci_unmap_sg(adapter->pdev, ddp->sgl,
+				     ddp->sgc, DMA_FROM_DEVICE);
+			ddp->sgl = NULL;
+			ddp->sgc = 0;
+		}
+		/* return 0 to bypass going to ULD for DDPed data */
+		if (fcstat == IXGBE_RXDADV_STAT_FCSTAT_DDP)
+			rc = 0;
+	}
+
+ddp_out:
+	return rc;
+}
+
+/**
  * ixgbe_fso - ixgbe FCoE Sequence Offload (FSO)
  * @adapter: ixgbe adapter
  * @tx_ring: tx desc ring
@@ -178,7 +483,20 @@ int ixgbe_fso(struct ixgbe_adapter *adapter,
 void ixgbe_configure_fcoe(struct ixgbe_adapter *adapter)
 {
 	struct ixgbe_hw *hw = &adapter->hw;
+	struct ixgbe_fcoe *fcoe = &adapter->fcoe;
+
+	/* create the pool for ddp if not created yet */
+	if (!fcoe->pool) {
+		/* allocate ddp pool */
+		fcoe->pool = pci_pool_create("ixgbe_fcoe_ddp",
+					     adapter->pdev, IXGBE_FCPTR_MAX,
+					     IXGBE_FCPTR_ALIGN, PAGE_SIZE);
+		if (!fcoe->pool)
+			DPRINTK(DRV, ERR,
+				"failed to allocated FCoE DDP pool\n");
 
+		spin_lock_init(&fcoe->lock);
+	}
 	/* L2 filter for FCoE: default to queue 0 */
 	IXGBE_WRITE_REG(hw, IXGBE_ETQF(IXGBE_ETQF_FILTER_FCOE),
 			(ETH_P_FCOE | IXGBE_ETQF_FCOE | IXGBE_ETQF_FILTER_EN));
@@ -190,3 +508,25 @@ void ixgbe_configure_fcoe(struct ixgbe_adapter *adapter)
 			IXGBE_FCRXCTRL_FCCRCBO |
 			(FC_FCOE_VER << IXGBE_FCRXCTRL_FCOEVER_SHIFT));
 }
+
+/**
+ * ixgbe_cleanup_fcoe - release all fcoe ddp context resources
+ * @adapter : ixgbe adapter
+ *
+ * Cleans up outstanding ddp context resources
+ *
+ * Returns : none
+ */
+void ixgbe_cleanup_fcoe(struct ixgbe_adapter *adapter)
+{
+	int i;
+	struct ixgbe_fcoe *fcoe = &adapter->fcoe;
+
+	/* release ddp resource */
+	if (fcoe->pool) {
+		for (i = 0; i < IXGBE_FCOE_DDP_MAX; i++)
+			ixgbe_fcoe_ddp_put(adapter->netdev, i);
+		pci_pool_destroy(fcoe->pool);
+		fcoe->pool = NULL;
+	}
+}
diff --git a/drivers/net/ixgbe/ixgbe_fcoe.h b/drivers/net/ixgbe/ixgbe_fcoe.h
index d054c1d..b7f9b63 100644
--- a/drivers/net/ixgbe/ixgbe_fcoe.h
+++ b/drivers/net/ixgbe/ixgbe_fcoe.h
@@ -54,7 +54,7 @@ struct ixgbe_fcoe_ddp {
 	unsigned int sgc;
 	struct scatterlist *sgl;
 	dma_addr_t udp;
-	unsigned long *udl;
+	u64 *udl;
 };
 
 struct ixgbe_fcoe {

