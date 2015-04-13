From: Varun Prakash <varun@chelsio.com>
Subject: [PATCH net-next v2 3/4] cxgb4: add DDP support for FCoE target
Date: Mon, 13 Apr 2015 19:34:25 +0530
Message-ID: <a8d335d453e84d5cf2ca7826e6de24eba96af253.1428930614.git.varun@chelsio.com>
References: <cover.1428930614.git.varun@chelsio.com>
Cc: davem@davemloft.net, JBottomley@parallels.com,
	roland@purestorage.com, leedom@chelsio.com, anish@chelsio.com,
	hariprasad@chelsio.com, swise@opengridcomputing.com,
	kxie@chelsio.com, praveenm@chelsio.com, kumaras@chelsio.com,
	varun@chelsio.com
To: netdev@vger.kernel.org, linux-scsi@vger.kernel.org,
	linux-rdma@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from stargate.chelsio.com ([67.207.112.58]:22035 "EHLO
	stargate3.asicdesigners.com" rhost-flags-OK-OK-OK-FAIL)
	by vger.kernel.org with ESMTP id S1754138AbbDMOF2 (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 13 Apr 2015 10:05:28 -0400
In-Reply-To: <cover.1428930614.git.varun@chelsio.com>
In-Reply-To: <cover.1428930614.git.varun@chelsio.com>
References: <cover.1428930614.git.varun@chelsio.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

This patch adds code for ndo_fcoe_ddp_target and
ndo_fcoe_ddp_done.

Signed-off-by: Varun Prakash <varun@chelsio.com>
---
 drivers/net/ethernet/chelsio/cxgb4/cxgb4.h      |    1 +
 drivers/net/ethernet/chelsio/cxgb4/cxgb4_fcoe.c |  600 +++++++++++++++++++++++
 drivers/net/ethernet/chelsio/cxgb4/cxgb4_main.c |   39 ++-
 drivers/net/ethernet/chelsio/cxgb4/sge.c        |  328 ++++++++++++-
 drivers/net/ethernet/chelsio/cxgb4/t4_hw.c      |    1 +
 5 files changed, 963 insertions(+), 6 deletions(-)

diff --git a/drivers/net/ethernet/chelsio/cxgb4/cxgb4.h b/drivers/net/ethernet/chelsio/cxgb4/cxgb4.h
index 524d110..8cc53f9 100644
--- a/drivers/net/ethernet/chelsio/cxgb4/cxgb4.h
+++ b/drivers/net/ethernet/chelsio/cxgb4/cxgb4.h
@@ -247,6 +247,7 @@ struct tp_params {
 	 * places we store their offsets here, or a -1 if the field isn't
 	 * present.
 	 */
+	int fcoe_shift;
 	int vlan_shift;
 	int vnic_shift;
 	int port_shift;
diff --git a/drivers/net/ethernet/chelsio/cxgb4/cxgb4_fcoe.c b/drivers/net/ethernet/chelsio/cxgb4/cxgb4_fcoe.c
index 6c8a62e..f78d632 100644
--- a/drivers/net/ethernet/chelsio/cxgb4/cxgb4_fcoe.c
+++ b/drivers/net/ethernet/chelsio/cxgb4/cxgb4_fcoe.c
@@ -34,8 +34,10 @@
 
 #ifdef CONFIG_CHELSIO_T4_FCOE
 
+#include <linux/if_vlan.h>
 #include <scsi/fc/fc_fs.h>
 #include <scsi/libfcoe.h>
+#include "t4_msg.h"
 #include "cxgb4.h"
 
 bool cxgb_fcoe_sof_eof_supported(struct adapter *adap, struct sk_buff *skb)
@@ -59,6 +61,528 @@ bool cxgb_fcoe_sof_eof_supported(struct adapter *adap, struct sk_buff *skb)
 	return true;
 }
 
+static inline struct cxgb_fcoe_ddp *
+cxgb_fcoe_lookup_ddp(struct port_info *pi, unsigned int tid)
+{
+	struct adapter *adap = pi->adapter;
+	struct cxgb_fcoe *fcoe = &pi->fcoe;
+	struct cxgb_fcoe_ddp *ddp;
+	u16 xid;
+
+	if (tid >= adap->tids.ntids) {
+		dev_err(adap->pdev_dev, "tid %x out of bounds\n", tid);
+		return NULL;
+	}
+
+	xid = adap->vres.tid2xid[tid];
+
+	if (xid >= CXGB_FCOE_MAX_XCHGS_PORT) {
+		dev_err(adap->pdev_dev, "xid %x out of bounds, tid:%x\n",
+			xid, tid);
+		return NULL;
+	}
+
+	ddp = &fcoe->ddp[xid];
+
+	if ((fcoe->flags & CXGB_FCOE_ENABLED) && (ddp->tid == tid) && ddp->sgl)
+		return ddp;
+
+	return NULL;
+}
+
+static inline struct sk_buff *
+cxgb_fcoe_init_skb(struct adapter *adapter, u16 xid, struct port_info *pi,
+		   struct cxgb_fcoe_ddp *ddp, struct cpl_fcoe_hdr *cfcoe_hdr,
+		   struct sge_eth_rxq *rxq)
+{
+	struct sk_buff *skb;
+	struct ethhdr *eh;
+	struct fcoe_crc_eof *cp;
+	struct fc_frame_header *fh;
+	unsigned int hlen;		/* fcoe header length */
+	unsigned int tlen;		/* fcoe trailer length */
+	unsigned int elen;		/* eth header excluding vlan */
+	unsigned int fclen;		/* fc header len */
+	u8 rctl;
+	struct fcoe_hdr *hp;
+
+	elen = sizeof(struct ethhdr);
+	hlen = sizeof(struct fcoe_hdr);
+	fclen = sizeof(struct fc_frame_header);
+	tlen = sizeof(struct fcoe_crc_eof);
+
+	skb = dev_alloc_skb(elen + hlen + fclen + tlen);
+	if (!skb)
+		return NULL;
+
+	rctl = FCOE_FCHDR_RCTL_G(be32_to_cpu(cfcoe_hdr->rctl_fctl));
+
+	skb->ip_summed = CHECKSUM_UNNECESSARY;
+	skb->protocol = htons(ETH_P_FCOE);
+	skb->dev = adapter->port[pi->port_id];
+
+	eh = (struct ethhdr *)skb_put(skb, elen);
+	ether_addr_copy(eh->h_source, ddp->h_dest);
+	ether_addr_copy(eh->h_dest, ddp->h_source);
+	eh->h_proto = htons(ETH_P_FCOE);
+
+	hp = (struct fcoe_hdr *)skb_put(skb, hlen);
+	memset(hp, 0, sizeof(*hp));
+	if (FC_FCOE_VER)
+		FC_FCOE_ENCAPS_VER(hp, FC_FCOE_VER);
+	hp->fcoe_sof = cfcoe_hdr->sof;
+
+	fh = (struct fc_frame_header *)skb_put(skb, fclen);
+	fh->fh_r_ctl = rctl;
+	memcpy(fh->fh_d_id, &ddp->h_source[3], 3);
+	memcpy(fh->fh_s_id, ddp->d_id, 3);
+
+	fh->fh_cs_ctl = cfcoe_hdr->cs_ctl;
+	fh->fh_type = cfcoe_hdr->type;
+	memcpy(fh->fh_f_ctl, ((char *)&cfcoe_hdr->rctl_fctl) + 1, 3);
+	fh->fh_seq_id = cfcoe_hdr->seq_id;
+	fh->fh_df_ctl = cfcoe_hdr->df_ctl;
+	fh->fh_seq_cnt = cfcoe_hdr->seq_cnt;
+	fh->fh_ox_id = cfcoe_hdr->oxid;
+	fh->fh_rx_id = htons(xid);
+	fh->fh_parm_offset = cfcoe_hdr->param;
+
+	cp = (struct fcoe_crc_eof *)skb_put(skb, tlen);
+
+	memset(cp, 0, sizeof(*cp));
+	cp->fcoe_eof = cfcoe_hdr->eof;
+
+	skb_reset_mac_header(skb);
+	skb_set_network_header(skb, sizeof(*eh));
+	__skb_pull(skb, sizeof(*eh));
+	skb_record_rx_queue(skb, rxq->rspq.idx);
+
+	return skb;
+}
+
+static inline void
+cxgb_fcoe_cpl_fcoe_hdr(struct port_info *pi, struct sge_rspq *q,
+		       struct cpl_fcoe_hdr *cfcoe_hdr)
+{
+	struct adapter *adap = pi->adapter;
+	struct sk_buff *skb;
+	struct cxgb_fcoe_ddp *ddp;
+	struct sge_eth_rxq *rxq = container_of(q, struct sge_eth_rxq, rspq);
+	unsigned int tid = GET_TID(cfcoe_hdr);
+	u32 fctl;
+
+	ddp = cxgb_fcoe_lookup_ddp(pi, tid);
+	if (!ddp)
+		return;
+
+	if (ddp->flags & CXGB_FCOE_DDP_ERROR)
+		return;
+
+	fctl = G_FCOE_FCHDR_FCTL(be32_to_cpu(cfcoe_hdr->rctl_fctl));
+
+	ddp->ddp_len += ntohs(cfcoe_hdr->len);
+
+	/* Send skb only on transfer of sequence initiative (last frame) */
+	if ((fctl & (FC_FC_SEQ_INIT | FC_FC_END_SEQ)) !=
+					(FC_FC_SEQ_INIT | FC_FC_END_SEQ))
+		return;
+
+	/* Synth a skb */
+	skb = cxgb_fcoe_init_skb(adap, ddp->xid, pi, ddp, cfcoe_hdr, rxq);
+	if (unlikely(!skb)) {
+		ddp->flags |= CXGB_FCOE_DDP_ERROR;
+		return;
+	}
+
+	if (ddp->vlan_tci)
+		__vlan_hwaccel_put_tag(skb, htons(ETH_P_8021Q), ddp->vlan_tci);
+
+	netif_receive_skb(skb);
+}
+
+static void cxgb_fcoe_cpl_rx_fcoe_ddp(struct port_info *pi,
+				      struct cpl_rx_fcoe_ddp *cfcoe_ddp)
+{
+	struct adapter *adap = pi->adapter;
+	struct cxgb_fcoe_ddp *ddp;
+	unsigned int tid = GET_TID(cfcoe_ddp);
+
+	ddp = cxgb_fcoe_lookup_ddp(pi, tid);
+	if (!ddp)
+		return;
+
+	dev_warn(adap->pdev_dev, "DDP Error, xid:%x tid:%x report:%x"
+		 " vld:%x\n", ddp->xid, tid,
+		 be32_to_cpu(cfcoe_ddp->ddp_report),
+		 be32_to_cpu(cfcoe_ddp->ddpvld));
+
+	ddp->flags |= CXGB_FCOE_DDP_ERROR;
+}
+
+int cxgb_fcoe_rx_handler(struct sge_rspq *q, const __be64 *rsp)
+{
+	struct port_info *pi = netdev_priv(q->netdev);
+
+	switch (*(u8 *)rsp) {
+	case CPL_FCOE_HDR:
+		cxgb_fcoe_cpl_fcoe_hdr(pi, q,
+				       (struct cpl_fcoe_hdr *)&rsp[1]);
+		break;
+	case CPL_RX_FCOE_DDP:
+		cxgb_fcoe_cpl_rx_fcoe_ddp(pi,
+					  (struct cpl_rx_fcoe_ddp *)&rsp[1]);
+		break;
+	case CPL_FCOE_DATA:
+		break;
+	default:
+		return 0;
+	}
+
+	return 1;
+}
+
+/**
+ * cxgb_fcoe_alloc_ppods - Allocate page pods
+ * @adap: adapter
+ * @n: number of page pods to allocate
+ *
+ * Returns -1 on failure or the page pod tag
+ */
+static inline int
+cxgb_fcoe_alloc_ppods(struct adapter *adap, unsigned int n)
+{
+	unsigned int i, j;
+	struct cxgb4_virt_res *vres = &adap->vres;
+
+	if (unlikely(!vres->ppod_map))
+		return -1;
+
+	spin_lock_bh(&vres->ppod_map_lock);
+
+	/* Look for n consecutive available page pods.
+	 * Make sure to guard from scanning beyond the table.
+	 */
+	for (i = 0; i + n - 1 < vres->fcoe_nppods; ) {
+		for (j = 0; j < n; ++j)		/* scan ppod_map[i..i+n-1] */
+			if (vres->ppod_map[i + j]) {
+				i = i + j + 1;
+				goto next;
+			}
+
+		memset(&vres->ppod_map[i], 1, n);   /* allocate range */
+		spin_unlock_bh(&vres->ppod_map_lock);
+		return i;
+next:
+		continue;
+	}
+
+	spin_unlock_bh(&vres->ppod_map_lock);
+	return -1;
+}
+
+void
+cxgb_fcoe_free_ppods(struct adapter *adap, unsigned int tag, unsigned int n)
+{
+	struct cxgb4_virt_res *vres = &adap->vres;
+
+	spin_lock_bh(&vres->ppod_map_lock);
+	memset(&vres->ppod_map[tag], 0, n);
+	spin_unlock_bh(&vres->ppod_map_lock);
+}
+
+static inline void cxgb_fcoe_clear_ddp(struct cxgb_fcoe_ddp *ddp)
+{
+	ddp->sgl = NULL;
+	ddp->sgc = 0;
+	ddp->first_pg_off = 0;
+	ddp->nppods = 0;
+	ddp->ppod_tag = 0;
+	ddp->xfer_len = 0;
+	ddp->ddp_len = 0;
+	ddp->npages = 0;
+	ddp->flags = 0;
+}
+
+void cxgb_fcoe_cpl_act_open_rpl(struct adapter *adap, unsigned int atid,
+				unsigned int tid, unsigned int status)
+{
+	u16 xid = CXGB_FCOE_GET_XID(atid);
+	u8 port_id = CXGB_FCOE_GET_PORTID(atid);
+	struct port_info *pi = adap2pinfo(adap, port_id);
+	struct cxgb_fcoe *fcoe = &pi->fcoe;
+	struct cxgb_fcoe_ddp *ddp = &fcoe->ddp[xid];
+
+	if ((status == CPL_ERR_NONE) &&
+	    (tid < adap->tids.ntids)) {
+		ddp->tid = tid;
+		ddp->flags |= CXGB_FCOE_DDP_TID_VALID;
+		adap->vres.tid2xid[tid] = xid;
+	} else
+		dev_err(adap->pdev_dev, "tid allocation failed xid 0x%x status 0x%x\n",
+			xid, status);
+
+	complete(fcoe->cmpl);
+}
+
+static int cxgb_fcoe_alloc_tid(struct port_info *pi, u16 xid)
+{
+	struct adapter *adap = pi->adapter;
+	struct cxgb_fcoe *fcoe = &pi->fcoe;
+	struct cxgb_fcoe_ddp *ddp = &fcoe->ddp[xid];
+	struct tp_params *tp = &adap->params.tp;
+	struct cpl_t5_act_open_req *req;
+	struct sk_buff *skb;
+	unsigned int qid_atid = xid;
+
+	skb = alloc_skb(sizeof(*req), GFP_KERNEL);
+	if (!skb)
+		return 1;
+
+	qid_atid |= BIT(CXGB_FCOE_ATID);
+	qid_atid |= (pi->port_id << CXGB_FCOE_SHIFT_PORTID);
+	qid_atid |= (adap->sge.fw_evtq.abs_id << 14);
+
+	req = (struct cpl_t5_act_open_req *)__skb_put(skb, sizeof(*req));
+	memset(req, 0, sizeof(*req));
+
+	INIT_TP_WR(req, 0);
+	OPCODE_TID(req) = htonl(MK_OPCODE_TID(CPL_ACT_OPEN_REQ, qid_atid));
+
+	req->peer_port = cpu_to_be16(xid);
+	req->opt0 = cpu_to_be64(ULP_MODE_V(ULP_MODE_FCOE) |
+			NON_OFFLOAD_F | NO_CONG_F | TX_CHAN_V(pi->tx_chan) |
+			RCV_BUFSIZ_V(RCV_BUFSIZ_M) | L2T_IDX_V(0));
+
+	req->params = cpu_to_be64(FILTER_TUPLE_V(
+				(pi->port_id << tp->port_shift) |
+				(1 << tp->fcoe_shift)) | AOPEN_FCOEMASK_F);
+
+	if (t4_mgmt_tx(adap, skb) == NET_XMIT_DROP)
+		return 1;
+
+	wait_for_completion(fcoe->cmpl);
+
+	reinit_completion(fcoe->cmpl);
+
+	if (!(ddp->flags & CXGB_FCOE_DDP_TID_VALID))
+		return 1;
+
+	return 0;
+}
+
+static void cxgb_fcoe_free_tid(struct port_info *pi, u16 xid)
+{
+	struct adapter *adap = pi->adapter;
+	struct cxgb_fcoe *fcoe = &pi->fcoe;
+	struct cxgb_fcoe_ddp *ddp = &fcoe->ddp[xid];
+	struct cpl_tid_release *req;
+	struct sk_buff *skb;
+	unsigned int len = ALIGN(sizeof(*req), 16);
+
+	skb = alloc_skb(len, GFP_KERNEL);
+	if (!skb)
+		return;
+
+	req = (struct cpl_tid_release *)__skb_put(skb, len);
+	memset(req, 0, len);
+
+	INIT_TP_WR(req, 0);
+	OPCODE_TID(req) = htonl(MK_OPCODE_TID(CPL_TID_RELEASE, ddp->tid));
+
+	t4_mgmt_tx(adap, skb);
+}
+
+static void cxgb_fcoe_free_ddp(struct port_info *pi, u16 xid)
+{
+	struct cxgb_fcoe *fcoe = &pi->fcoe;
+	struct cxgb_fcoe_ddp *ddp;
+	u16 i;
+
+	for (i = 0; i < xid; i++) {
+		ddp = &fcoe->ddp[i];
+		kfree(ddp->ppod_gl);
+		cxgb_fcoe_free_tid(pi, i);
+	}
+}
+
+/* Return the # of page pods needed to accommodate a # of pages.
+ */
+static inline unsigned int pages2ppods(unsigned int pages)
+{
+	return (pages + PPOD_PAGES - 1) / PPOD_PAGES +
+			CXGB_FCOE_NUM_SENTINEL_PPODS;
+}
+
+/**
+ * cxgb_fcoe_ddp_setup - setup ddp in target mode
+ * @netdev: net device
+ * @xid: exchange id
+ * @sgl: scatterlist
+ * @sgc: number of scatterlist elements
+ *
+ * Returns 1 on success or 0 on failure.
+ */
+int cxgb_fcoe_ddp_setup(struct net_device *netdev, u16 xid,
+			struct scatterlist *sgl, unsigned int sgc)
+{
+	struct port_info *pi;
+	struct adapter *adap;
+	struct cxgb_fcoe *fcoe;
+	struct cxgb_fcoe_ddp *ddp;
+	struct scatterlist *sg;
+	unsigned int nsge, i, j, len, nppods;
+	static const unsigned int bufflen = PAGE_SIZE;
+	unsigned int firstoff = 0;
+	unsigned int thisoff = 0;
+	unsigned int thislen = 0;
+	unsigned int totlen = 0;
+	int tag;
+	dma_addr_t addr;
+
+	if (!netdev || !sgl)
+		return 0;
+
+	pi = netdev_priv(netdev);
+	adap = pi->adapter;
+
+	if (xid >= CXGB_FCOE_MAX_XCHGS_PORT) {
+		dev_warn(adap->pdev_dev, "xid=0x%x out-of-range\n", xid);
+		return 0;
+	}
+
+	fcoe = &pi->fcoe;
+	ddp = &fcoe->ddp[xid];
+	if (ddp->sgl) {
+		dev_err(adap->pdev_dev, "xid 0x%x w/ non-null sgl%p nents=%d\n",
+			xid, ddp->sgl, ddp->sgc);
+		return 0;
+	}
+
+	cxgb_fcoe_clear_ddp(ddp);
+
+	nsge = pci_map_sg(adap->pdev, sgl, sgc, DMA_FROM_DEVICE);
+	if (nsge == 0) {
+		dev_err(adap->pdev_dev, "xid 0x%x DMA map error\n", xid);
+		return 0;
+	}
+
+	j = 0;
+	for_each_sg(sgl, sg, nsge, i) {
+		addr = sg_dma_address(sg);
+		len = sg_dma_len(sg);
+		totlen += len;
+		while (len) {
+			/* max number of pages allowed in one DDP transfer */
+			if (j >= CXGB_FCOE_MAX_PAGE_CNT) {
+				dev_err(adap->pdev_dev,
+					"xid=%x:%d,%d,%d:addr=%llx "
+					"not enough descriptors\n",
+					xid, i, j, nsge, (u64)addr);
+				goto out_noddp;
+			}
+
+			/* get the offset of length of current buffer */
+			thisoff = addr & ((dma_addr_t)bufflen - 1);
+			thislen = min((bufflen - thisoff), len);
+
+			/* all but the 1st buffer (j == 0)
+			 * must be aligned on bufflen
+			 */
+			if ((j != 0) && (thisoff))
+				goto out_noddp;
+			/* all but the last buffer
+			 * ((i == (nsge - 1)) && (thislen == len))
+			 * must end at bufflen
+			 */
+			if (((i != (nsge - 1)) || (thislen != len)) &&
+			    ((thislen + thisoff) != bufflen))
+				goto out_noddp;
+
+			ddp->ppod_gl[j] = (dma_addr_t)(addr - thisoff);
+
+			/* only the first buffer may have none-zero offset */
+			if (j == 0)
+				firstoff = thisoff;
+			len -= thislen;
+			addr += thislen;
+			j++;
+		}
+	}
+
+	nppods = pages2ppods(j);
+	tag = cxgb_fcoe_alloc_ppods(adap, nppods);
+	if (tag < 0) {
+		dev_err(adap->pdev_dev, "Failed to allocate %d ppods"
+					" xid:0x%x\n", nppods, xid);
+		goto out_noddp;
+	}
+
+	/* Should be offset by TOE's ppods */
+	tag += adap->vres.toe_nppods;
+
+	ddp->sgl = sgl;
+	ddp->sgc = sgc;
+	ddp->xfer_len = totlen;
+	ddp->first_pg_off = firstoff;
+	ddp->nppods = nppods;
+	ddp->npages = j;
+	ddp->ppod_tag = tag;
+
+	return 1;
+
+out_noddp:
+	pci_unmap_sg(adap->pdev, sgl, sgc, DMA_FROM_DEVICE);
+	return 0;
+}
+
+/**
+ * cxgb_fcoe_ddp_done - complete DDP
+ * @netdev: net device
+ * @xid: exchange id
+ *
+ * Returns length of data directly placed in bytes.
+ */
+int cxgb_fcoe_ddp_done(struct net_device *netdev, u16 xid)
+{
+	struct port_info *pi;
+	struct adapter *adap;
+	struct cxgb_fcoe *fcoe;
+	struct cxgb_fcoe_ddp *ddp;
+	int len = 0;
+
+	if (!netdev)
+		return 0;
+
+	pi = netdev_priv(netdev);
+	adap = pi->adapter;
+
+	if (xid >= CXGB_FCOE_MAX_XCHGS_PORT) {
+		dev_warn(adap->pdev_dev, "ddp_done: xid%x out-of-range\n", xid);
+		return 0;
+	}
+
+	fcoe = &pi->fcoe;
+	ddp = &fcoe->ddp[xid];
+	if (!ddp->sgl) {
+		dev_err(adap->pdev_dev, "ddp_done: xid %x with null sgl\n",
+			xid);
+		return 0;
+	}
+
+	if (!(ddp->flags & CXGB_FCOE_DDP_ERROR))
+		len = ddp->ddp_len;
+
+	cxgb_fcoe_free_ppods(adap, ddp->ppod_tag - adap->vres.toe_nppods,
+			     ddp->nppods);
+
+	if (ddp->sgl)
+		pci_unmap_sg(adap->pdev, ddp->sgl, ddp->sgc, DMA_FROM_DEVICE);
+
+	cxgb_fcoe_clear_ddp(ddp);
+
+	return len;
+}
+
 /**
  * cxgb_fcoe_enable - enable FCoE offload features
  * @netdev: net device
@@ -70,6 +594,10 @@ int cxgb_fcoe_enable(struct net_device *netdev)
 	struct port_info *pi = netdev_priv(netdev);
 	struct adapter *adap = pi->adapter;
 	struct cxgb_fcoe *fcoe = &pi->fcoe;
+	struct tp_params *tp = &adap->params.tp;
+	struct cxgb_fcoe_ddp *ddp;
+	struct completion cmpl;
+	u16 xid;
 
 	if (is_t4(adap->params.chip))
 		return -EINVAL;
@@ -77,12 +605,48 @@ int cxgb_fcoe_enable(struct net_device *netdev)
 	if (!(adap->flags & FULL_INIT_DONE))
 		return -EINVAL;
 
+	if (adap->tids.natids > 8192)
+		return -EINVAL;
+
+	if ((tp->port_shift < 0) || (tp->fcoe_shift < 0))
+		return -EINVAL;
+
+	if (!adap->vres.ppod_map || !adap->vres.tid2xid) {
+		dev_warn(adap->pdev_dev, "FCoE Offload resources "
+			 " unavailable\n");
+		return -EINVAL;
+	}
+
 	dev_info(adap->pdev_dev, "Enabling FCoE offload features\n");
 
+	init_completion(&cmpl);
+	fcoe->cmpl = &cmpl;
+	memset(fcoe->ddp, 0, sizeof(*ddp) * CXGB_FCOE_MAX_XCHGS_PORT);
+
+	for (xid = 0; xid < CXGB_FCOE_MAX_XCHGS_PORT; xid++) {
+		ddp = &fcoe->ddp[xid];
+		ddp->xid = xid;
+		ddp->ppod_gl = kcalloc(CXGB_FCOE_MAX_PAGE_CNT,
+					sizeof(dma_addr_t), GFP_KERNEL);
+		if (!ddp->ppod_gl) {
+			cxgb_fcoe_free_ddp(pi, xid);
+			return -EINVAL;
+		}
+
+		if (cxgb_fcoe_alloc_tid(pi, xid)) {
+			dev_warn(adap->pdev_dev, "Unable to allocate "
+				 "tid xid 0x%x\n", xid);
+			kfree(ddp->ppod_gl);
+			cxgb_fcoe_free_ddp(pi, xid);
+			return -EINVAL;
+		}
+	}
+
 	netdev->features |= NETIF_F_FCOE_CRC;
 	netdev->vlan_features |= NETIF_F_FCOE_CRC;
 	netdev->features |= NETIF_F_FCOE_MTU;
 	netdev->vlan_features |= NETIF_F_FCOE_MTU;
+	netdev->fcoe_ddp_xid = CXGB_FCOE_MAX_XCHGS_PORT - 1;
 
 	netdev_features_change(netdev);
 
@@ -114,9 +678,45 @@ int cxgb_fcoe_disable(struct net_device *netdev)
 	netdev->vlan_features &= ~NETIF_F_FCOE_CRC;
 	netdev->features &= ~NETIF_F_FCOE_MTU;
 	netdev->vlan_features &= ~NETIF_F_FCOE_MTU;
+	netdev->fcoe_ddp_xid = 0;
 
 	netdev_features_change(netdev);
 
+	cxgb_fcoe_free_ddp(pi, CXGB_FCOE_MAX_XCHGS_PORT);
+
 	return 0;
 }
+
+void cxgb_fcoe_init_ddp(struct adapter *adap)
+{
+	u32 tot_ppods = adap->vres.ddp.size / CXGB_FCOE_PPOD_SIZE;
+	u32 fcoe_ddp_size, fcoe_ddp_start;
+
+	adap->vres.fcoe_nppods = tot_ppods / 2;
+	adap->vres.toe_nppods = tot_ppods - adap->vres.fcoe_nppods;
+
+	adap->vres.ddp.size = adap->vres.toe_nppods * CXGB_FCOE_PPOD_SIZE;
+	fcoe_ddp_size = adap->vres.fcoe_nppods * CXGB_FCOE_PPOD_SIZE;
+	fcoe_ddp_start = adap->vres.ddp.start + adap->vres.ddp.size;
+
+	dev_info(adap->pdev_dev, "TOE ddp start:0x%x size:%d"
+		 " nppods:%d\n", adap->vres.ddp.start,
+		 adap->vres.ddp.size, adap->vres.toe_nppods);
+	dev_info(adap->pdev_dev, "FCoE ddp start:0x%x size:%d"
+		 " nppods:%d tids:%d\n",
+		 fcoe_ddp_start, fcoe_ddp_size,
+		 adap->vres.fcoe_nppods, adap->tids.ntids);
+
+	spin_lock_init(&adap->vres.ppod_map_lock);
+
+	adap->vres.ppod_map = kzalloc(adap->vres.fcoe_nppods, GFP_KERNEL);
+	adap->vres.tid2xid = kcalloc(adap->tids.ntids, sizeof(u16),
+				GFP_KERNEL);
+}
+
+void cxgb_fcoe_exit_ddp(struct adapter *adap)
+{
+	kfree(adap->vres.ppod_map);
+	kfree(adap->vres.tid2xid);
+}
 #endif /* CONFIG_CHELSIO_T4_FCOE */
diff --git a/drivers/net/ethernet/chelsio/cxgb4/cxgb4_main.c b/drivers/net/ethernet/chelsio/cxgb4/cxgb4_main.c
index 24e10ea..95e7527 100644
--- a/drivers/net/ethernet/chelsio/cxgb4/cxgb4_main.c
+++ b/drivers/net/ethernet/chelsio/cxgb4/cxgb4_main.c
@@ -544,6 +544,23 @@ static void clear_filter(struct adapter *adap, struct filter_entry *f)
 	memset(f, 0, sizeof(*f));
 }
 
+#ifdef CONFIG_CHELSIO_T4_FCOE
+static void hash_filter_rpl(struct adapter *adap,
+			    const struct cpl_act_open_rpl *rpl)
+{
+	unsigned int tid = GET_TID(rpl);
+	unsigned int ftid = TID_TID_G(AOPEN_ATID_G(ntohl(rpl->atid_status)));
+	unsigned int status  = AOPEN_STATUS_G(ntohl(rpl->atid_status));
+
+	/* ATID is 14 bit value [0..13], MAX_ATIDS is 8192
+	 * ATID needs max 13 bits [0..12], using 13th bit in
+	 * ATID for FCoE CPL_ACT_OPEN_REQ.
+	 */
+	if (ftid & BIT(CXGB_FCOE_ATID))
+		cxgb_fcoe_cpl_act_open_rpl(adap, ftid, tid, status);
+}
+#endif /* CONFIG_CHELSIO_T4_FCOE */
+
 /* Handle a filter write/deletion reply.
  */
 static void filter_rpl(struct adapter *adap, const struct cpl_set_tcb_rpl *rpl)
@@ -661,7 +678,15 @@ static int fwevtq_handler(struct sge_rspq *q, const __be64 *rsp,
 		const struct cpl_set_tcb_rpl *p = (void *)rsp;
 
 		filter_rpl(q->adap, p);
-	} else
+	}
+#ifdef CONFIG_CHELSIO_T4_FCOE
+	else if (opcode == CPL_ACT_OPEN_RPL) {
+		const struct cpl_act_open_rpl *p = (void *)rsp;
+
+		hash_filter_rpl(q->adap, p);
+	}
+#endif /* CONFIG_CHELSIO_T4_FCOE */
+	else
 		dev_err(q->adap->pdev_dev,
 			"unexpected CPL %#x on FW event queue\n", opcode);
 out:
@@ -3010,6 +3035,8 @@ static const struct net_device_ops cxgb4_netdev_ops = {
 #ifdef CONFIG_CHELSIO_T4_FCOE
 	.ndo_fcoe_enable      = cxgb_fcoe_enable,
 	.ndo_fcoe_disable     = cxgb_fcoe_disable,
+	.ndo_fcoe_ddp_target  = cxgb_fcoe_ddp_setup,
+	.ndo_fcoe_ddp_done    = cxgb_fcoe_ddp_done,
 #endif /* CONFIG_CHELSIO_T4_FCOE */
 #ifdef CONFIG_NET_RX_BUSY_POLL
 	.ndo_busy_poll        = cxgb_busy_poll,
@@ -3845,6 +3872,10 @@ static int adap_init0(struct adapter *adap)
 		adap->vres.ddp.start = val[3];
 		adap->vres.ddp.size = val[4] - val[3] + 1;
 		adap->params.ofldq_wr_cred = val[5];
+#ifdef CONFIG_CHELSIO_T4_FCOE
+		if (ntohs(caps_cmd.fcoecaps) & FW_CAPS_CONFIG_POFCOE_TARGET)
+			cxgb_fcoe_init_ddp(adap);
+#endif /* CONFIG_CHELSIO_T4_FCOE */
 
 		adap->params.offload = 1;
 	}
@@ -3965,6 +3996,9 @@ bye:
 	kfree(adap->sge.txq_maperr);
 	if (ret != -ETIMEDOUT && ret != -EIO)
 		t4_fw_bye(adap, adap->mbox);
+#ifdef CONFIG_CHELSIO_T4_FCOE
+	cxgb_fcoe_exit_ddp(adap);
+#endif /* CONFIG_CHELSIO_T4_FCOE */
 	return ret;
 }
 
@@ -4757,6 +4791,9 @@ static void remove_one(struct pci_dev *pdev)
 		iounmap(adapter->regs);
 		if (!is_t4(adapter->params.chip))
 			iounmap(adapter->bar2);
+#ifdef CONFIG_CHELSIO_T4_FCOE
+		cxgb_fcoe_exit_ddp(adapter);
+#endif /* CONFIG_CHELSIO_T4_FCOE */
 		pci_disable_pcie_error_reporting(pdev);
 		if ((adapter->flags & DEV_ENABLED)) {
 			pci_disable_device(pdev);
diff --git a/drivers/net/ethernet/chelsio/cxgb4/sge.c b/drivers/net/ethernet/chelsio/cxgb4/sge.c
index e622214..05e8c93 100644
--- a/drivers/net/ethernet/chelsio/cxgb4/sge.c
+++ b/drivers/net/ethernet/chelsio/cxgb4/sge.c
@@ -48,6 +48,8 @@
 #endif /* CONFIG_NET_RX_BUSY_POLL */
 #ifdef CONFIG_CHELSIO_T4_FCOE
 #include <scsi/fc/fc_fcoe.h>
+#include <scsi/libfcoe.h>
+#include "t4_tcb.h"
 #endif /* CONFIG_CHELSIO_T4_FCOE */
 #include "cxgb4.h"
 #include "t4_regs.h"
@@ -1048,11 +1050,260 @@ static inline void txq_advance(struct sge_txq *q, unsigned int n)
 }
 
 #ifdef CONFIG_CHELSIO_T4_FCOE
+
+#define CXGB_FCOE_NUM_IMM_PPODS		4
+
+#define CXGB_FCOE_NUM_IMM_PPOD_BYTES	\
+	(CXGB_FCOE_NUM_IMM_PPODS * CXGB_FCOE_PPOD_SIZE)
+
+#define WR_LEN_MAX_PPODS	\
+	(sizeof(struct ulp_mem_io) + \
+	sizeof(struct ulptx_idata) + \
+	CXGB_FCOE_NUM_IMM_PPOD_BYTES)
+
+#define WR_CRED_MAX_PPODS	(DIV_ROUND_UP(WR_LEN_MAX_PPODS, IDXSIZE_UNIT_X))
+
+#define WR_LEN_SET_TCBS \
+	(sizeof(struct fw_pofcoe_ulptx_wr) + \
+	 (5 * ALIGN(sizeof(struct cpl_set_tcb_field), 16)))
+
+#define WR_LEN16_SET_TCBS DIV_ROUND_UP(WR_LEN_SET_TCBS, 16)
+
+#define WR_NDESC_SET_TCBS DIV_ROUND_UP(WR_LEN_SET_TCBS, IDXSIZE_UNIT_X)
+
+static inline int calc_ddp_credits(struct sk_buff *skb, unsigned int nppods)
+{
+	unsigned int n_full = (nppods / CXGB_FCOE_NUM_IMM_PPODS);
+	int credits = n_full * WR_CRED_MAX_PPODS;
+	unsigned int last_ppod_len = (nppods % CXGB_FCOE_NUM_IMM_PPODS) *
+					CXGB_FCOE_PPOD_SIZE;
+	unsigned int last_len;
+	unsigned int flits;
+
+	if (last_ppod_len) {
+		last_len = sizeof(struct ulp_mem_io) +
+				sizeof(struct ulptx_idata) + last_ppod_len;
+		credits += DIV_ROUND_UP(last_len, IDXSIZE_UNIT_X);
+	}
+
+	credits += WR_NDESC_SET_TCBS;
+
+	flits = calc_tx_flits(skb);
+	credits += flits_to_desc(flits);
+
+	return credits;
+}
+
+static inline void
+cxgb_fcoe_set_tcb_field(struct cpl_set_tcb_field *req, unsigned int tid,
+			unsigned int word, u64 mask, u64 val)
+{
+	struct ulp_txpkt *txpkt = (struct ulp_txpkt *)req;
+	struct ulptx_idata *sc = (struct ulptx_idata *)(txpkt + 1);
+
+	txpkt->cmd_dest = htonl(ULPTX_CMD_V(ULP_TX_PKT) | ULP_TXPKT_DEST_V(0));
+	txpkt->len = htonl((tid << 8) | DIV_ROUND_UP(sizeof(*req), 16));
+	sc->cmd_more = htonl(ULPTX_CMD_V(ULP_TX_SC_IMM));
+	sc->len = htonl(sizeof(*req) - sizeof(struct work_request_hdr));
+	OPCODE_TID(req) = htonl(MK_OPCODE_TID(CPL_SET_TCB_FIELD, tid));
+	req->reply_ctrl = htons(NO_REPLY_V(1) | REPLY_CHAN_V(0) |
+				QUEUENO_V(0));
+	req->word_cookie = htons(TCB_WORD(word) | TCB_COOKIE_V(0));
+	req->mask = cpu_to_be64(mask);
+	req->val = cpu_to_be64(val);
+	sc = (struct ulptx_idata *)(req + 1);
+	sc->cmd_more = htonl(ULPTX_CMD_V(ULP_TX_SC_NOOP));
+	sc->len = htonl(0);
+}
+
+static inline void
+cxgb_fcoe_set_tcbs(struct adapter *adap, const struct port_info *pi,
+		   struct sge_eth_txq *q,
+		   struct cxgb_fcoe_ddp *ddp, u16 iqid)
+{
+	struct cpl_set_tcb_field *req;
+	struct fw_pofcoe_ulptx_wr *wr;
+	u8 buf[WR_LEN_SET_TCBS] = {0};
+	u8 *end, *wrp = (u8 *)&q->q.desc[q->q.pidx];
+	unsigned int len = ALIGN(sizeof(struct cpl_set_tcb_field), 16);
+
+	end = wrp + WR_LEN_SET_TCBS;
+	wr = (struct fw_pofcoe_ulptx_wr *)
+		((u8 *)end > (u8 *)q->q.stat ? buf : wrp);
+
+	wr->op_pkd = htonl(FW_WR_OP_V(FW_POFCOE_ULPTX_WR));
+	wr->equiq_to_len16 = htonl(FW_WR_LEN16_V(WR_LEN16_SET_TCBS));
+
+	req = (struct cpl_set_tcb_field *)(wr + 1);
+	cxgb_fcoe_set_tcb_field(req, ddp->tid, TCB_RX_DDP_BUF0_TAG_W,
+				TCB_RX_DDP_BUF0_TAG_V(TCB_RX_DDP_BUF0_TAG_M),
+				TCB_RX_DDP_BUF0_TAG_V(
+					PPOD_TAG_V(ddp->ppod_tag)));
+
+	req = (struct cpl_set_tcb_field *)((u8 *)req + len);
+	cxgb_fcoe_set_tcb_field(req, ddp->tid, TCB_RX_DDP_BUF0_OFFSET_W,
+				TCB_RX_DDP_BUF0_OFFSET_V(
+					TCB_RX_DDP_BUF0_OFFSET_M) |
+				TCB_RX_DDP_BUF0_LEN_V(TCB_RX_DDP_BUF0_LEN_M),
+				TCB_RX_DDP_BUF0_OFFSET_V(0) |
+				TCB_RX_DDP_BUF0_LEN_V(ddp->xfer_len));
+
+	req = (struct cpl_set_tcb_field *)((u8 *)req + len);
+	cxgb_fcoe_set_tcb_field(req, ddp->tid, TCB_T_STATE_W,
+				TCB_T_STATE_V(TCB_T_STATE_M) |
+				TCB_RSS_INFO_V(TCB_RSS_INFO_M),
+				TCB_T_STATE_V(0x4) |
+				TCB_RSS_INFO_V(iqid));
+
+	req = (struct cpl_set_tcb_field *)((u8 *)req + len);
+	cxgb_fcoe_set_tcb_field(req, ddp->tid, TCB_T_FLAGS_W,
+				TF_NON_OFFLOAD_V(1), 0);
+
+	req = (struct cpl_set_tcb_field *)((u8 *)req + len);
+	cxgb_fcoe_set_tcb_field(req, ddp->tid, TCB_RX_DDP_FLAGS_W,
+				TF_DDP_BUF_INF_V(1) |
+				TF_DDP_INDICATE_OUT_V(1) |
+				TF_DDP_BUF0_INDICATE_V(1) |
+				TF_DDP_BUF0_VALID_V(1) |
+				TF_DDP_OFF_V(1),
+				TF_DDP_BUF_INF_V(1) |
+				TF_DDP_INDICATE_OUT_V(1) |
+				TF_DDP_BUF0_INDICATE_V(1) |
+				TF_DDP_BUF0_VALID_V(1) |
+				TF_DDP_OFF_V(0));
+
+	if (unlikely((u8 *)end > (u8 *)q->q.stat)) {
+		unsigned int part0 = (u8 *)q->q.stat - (u8 *)wrp, part1;
+
+		if (likely(part0))
+			memcpy(wrp, buf, part0);
+		part1 = (u8 *)end - (u8 *)q->q.stat;
+		memcpy(q->q.desc, (u8 *)buf + part0, part1);
+		end = (void *)q->q.desc + part1;
+	}
+
+	if ((uintptr_t)end & 8)		/* 0-pad to multiple of 16 */
+		*(u64 *)end = 0;
+
+	/* Post this WR */
+	txq_advance(&q->q, WR_NDESC_SET_TCBS);
+	ring_tx_db(adap, &q->q, WR_NDESC_SET_TCBS);
+}
+
+static inline void
+cxgb_setup_ppods(struct adapter *adap, const struct port_info *pi,
+		 struct sge_eth_txq *q, struct cxgb_fcoe_ddp *ddp)
+{
+	unsigned int i, j, pidx;
+	struct pagepod *p;
+	u8 *wrp = (u8 *)&q->q.desc[q->q.pidx];
+	struct fw_pofcoe_ulptx_wr *mwr;
+	struct ulp_mem_io *wr;
+	struct ulptx_idata *sc;
+	unsigned int tid = ddp->tid;
+	unsigned int color = 0;
+	unsigned int nppods = ddp->nppods;
+	unsigned int tag = ddp->ppod_tag;
+	unsigned int maxoff = ddp->xfer_len;
+	unsigned int pg_off = ddp->first_pg_off;
+	unsigned int ppod_addr = tag * CXGB_FCOE_PPOD_SIZE +
+					adap->vres.ddp.start;
+	unsigned int len, podchunk, ndesc;
+	u8 buf[WR_LEN_MAX_PPODS];
+	u8 *end, *to;
+	__be32 cmd = htonl(ULPTX_CMD_V(ULP_TX_MEM_WRITE));
+
+	if (is_t4(adap->params.chip))
+		cmd |= htonl(ULP_MEMIO_ORDER_V(1));
+	else
+		cmd |= htonl(T5_ULP_MEMIO_IMM_V(1));
+
+	for (i = 0; i < nppods; ppod_addr += podchunk) {
+		unsigned int ppodout = 0;
+
+		podchunk = ((nppods - i) >= CXGB_FCOE_NUM_IMM_PPODS) ?
+				CXGB_FCOE_NUM_IMM_PPODS : (nppods - i);
+		podchunk *= CXGB_FCOE_PPOD_SIZE;
+
+		len = roundup(sizeof(*wr) + sizeof(*sc) + podchunk, 16);
+		end = wrp + len;
+		to = (u8 *)end > (u8 *)q->q.stat ? buf : wrp;
+
+		mwr = (struct fw_pofcoe_ulptx_wr *)to;
+		mwr->op_pkd = htonl(FW_WR_OP_V(FW_POFCOE_ULPTX_WR));
+		mwr->equiq_to_len16 = htonl(FW_WR_LEN16_V(
+						DIV_ROUND_UP(len, 16)));
+		wr = (struct ulp_mem_io *)to;
+		wr->cmd = cmd;
+		wr->dlen = htonl(ULP_MEMIO_DATA_LEN_V(podchunk / 32));
+		wr->len16 = htonl((ddp->tid << 8) |
+					DIV_ROUND_UP(len - sizeof(wr->wr), 16));
+		wr->lock_addr = htonl(ULP_MEMIO_ADDR_V(ppod_addr >> 5));
+		sc = (struct ulptx_idata *)(wr + 1);
+		sc->cmd_more = htonl(ULPTX_CMD_V(ULP_TX_SC_IMM));
+		sc->len = htonl(podchunk);
+		p = (struct pagepod *)(sc + 1);
+
+		do {
+			pidx = 4 * i;
+			if (likely(i < nppods - CXGB_FCOE_NUM_SENTINEL_PPODS)) {
+				p->vld_tid_pgsz_tag_color =
+					cpu_to_be64(PPOD_VALID_F |
+							PPOD_TID_V(tid) |
+							PPOD_TAG_V(tag) |
+							PPOD_COLOR_V(color));
+				p->len_offset = cpu_to_be64(PPOD_LEN_V(maxoff) |
+							PPOD_OFST_V(pg_off));
+				p->rsvd = 0;
+				for (j = 0; j < 5; ++j, ++pidx)
+					p->addr[j] = pidx < ddp->npages ?
+					    cpu_to_be64(ddp->ppod_gl[pidx]) : 0;
+			} else {
+				/* mark sentinel page pods invalid */
+				p->vld_tid_pgsz_tag_color = 0;
+			}
+			p++;
+			ppodout += CXGB_FCOE_PPOD_SIZE;
+			i++;
+
+		} while (ppodout < podchunk);
+
+		if (unlikely((u8 *)end > (u8 *)q->q.stat)) {
+			unsigned int part0 = (u8 *)q->q.stat - (u8 *)wrp, part1;
+
+			if (likely(part0))
+				memcpy(wrp, buf, part0);
+			part1 = (u8 *)end - (u8 *)q->q.stat;
+			memcpy(q->q.desc, (u8 *)buf + part0, part1);
+			end = (void *)q->q.desc + part1;
+		}
+
+		if ((uintptr_t)end & 8)		/* 0-pad to multiple of 16 */
+			*(u64 *)end = 0;
+
+		/* Post this WR */
+		ndesc = DIV_ROUND_UP(len, IDXSIZE_UNIT_X);
+		txq_advance(&q->q, ndesc);
+		ring_tx_db(adap, &q->q, ndesc);
+
+		wrp = (u8 *)&q->q.desc[q->q.pidx];
+	} /* for all pagepod chunks */
+}
+
 static inline int
-cxgb_fcoe_offload(struct sk_buff *skb, struct adapter *adap,
-		  const struct port_info *pi, u64 *cntrl)
+cxgb_fcoe_offload(struct sk_buff *skb, struct net_device *dev,
+		  struct adapter *adap, const struct port_info *pi,
+		  struct sge_eth_txq *q, u64 *cntrl)
 {
 	const struct cxgb_fcoe *fcoe = &pi->fcoe;
+	struct cxgb_fcoe_ddp *ddp;
+	struct ethhdr *eh;
+	struct fc_frame_header *fh;
+	struct sge_eth_rxq *rxq;
+	unsigned int ndesc;
+	int qidx, credits;
+	u16 xid, vlan_tci = 0;
+	u32 fctl;
 
 	if (!(fcoe->flags & CXGB_FCOE_ENABLED))
 		return 0;
@@ -1075,6 +1326,64 @@ cxgb_fcoe_offload(struct sk_buff *skb, struct adapter *adap,
 		     TXPKT_CSUM_START(CXGB_FCOE_TXPKT_CSUM_START) |
 		     TXPKT_CSUM_END(CXGB_FCOE_TXPKT_CSUM_END) |
 		     TXPKT_CSUM_LOC(CXGB_FCOE_TXPKT_CSUM_END);
+
+	if (skb_vlan_tag_present(skb)) {
+		vlan_tci = skb_vlan_tag_get(skb);
+		vlan_tci |= ((skb->priority & 0x7) << VLAN_PRIO_SHIFT);
+	}
+
+	fh = (struct fc_frame_header *)(skb_transport_header(skb));
+
+	/* Program DDP for XFER_RDY frames only */
+	if (fh->fh_r_ctl != FC_RCTL_DD_DATA_DESC)
+		return 0;
+
+	fctl = ntoh24(fh->fh_f_ctl);
+	if (!(fctl & FC_FC_EX_CTX))
+		return 0;
+
+	xid = be16_to_cpu(fh->fh_rx_id);
+
+	if (xid >= CXGB_FCOE_MAX_XCHGS_PORT)
+		return 0;
+
+	ddp = (struct cxgb_fcoe_ddp *)&fcoe->ddp[xid];
+
+	/* Upper layer may not have requested for ddp_setup */
+	if (!ddp->sgl)
+		return 0;
+
+	eh = (struct ethhdr *)skb_mac_header(skb);
+	/* Save d_id, smac, dmac, vlan */
+	ether_addr_copy(ddp->h_source, eh->h_source);
+	ether_addr_copy(ddp->h_dest, eh->h_dest);
+	memcpy(ddp->d_id, fh->fh_d_id, 3);
+	ddp->vlan_tci = vlan_tci;
+
+	/* program ppods on the card. They should already have been
+	 * allocated in cxgb_fcoe_ddp_setup
+	 */
+
+	/* Calculate number credits required for ddp */
+	ndesc = calc_ddp_credits(skb, ddp->nppods);
+
+	credits = txq_avail(&q->q) - ndesc;
+
+	if (unlikely(credits < 0))
+		return -EBUSY;
+
+	/* Get an associated iqid */
+	qidx = skb_get_queue_mapping(skb);
+	rxq = &adap->sge.ethrxq[qidx + pi->first_qset];
+
+	cxgb_fcoe_set_tcbs(adap, pi, q, ddp, rxq->rspq.abs_id);
+
+	cxgb_setup_ppods(adap, pi, q, ddp);
+
+	dev->trans_start = jiffies;
+
+	reclaim_completed_tx(adap, &q->q, true);
+
 	return 0;
 }
 #endif /* CONFIG_CHELSIO_T4_FCOE */
@@ -1123,9 +1432,16 @@ out_free:	dev_kfree_skb_any(skb);
 	cntrl = TXPKT_L4CSUM_DIS | TXPKT_IPCSUM_DIS;
 
 #ifdef CONFIG_CHELSIO_T4_FCOE
-	err = cxgb_fcoe_offload(skb, adap, pi, &cntrl);
-	if (unlikely(err == -ENOTSUPP))
-		goto out_free;
+	err = cxgb_fcoe_offload(skb, dev, adap, pi, q, &cntrl);
+	if (unlikely(err == -EBUSY)) {
+		eth_txq_stop(q);
+		dev_err(adap->pdev_dev,
+			"%s: (fcoe) Tx ring %u full while queue awake!\n",
+			dev->name, qidx);
+		return NETDEV_TX_BUSY;
+	} else if (unlikely(err == -ENOTSUPP)) {
+			goto out_free;
+	}
 #endif /* CONFIG_CHELSIO_T4_FCOE */
 
 	flits = calc_tx_flits(skb);
@@ -1810,6 +2126,8 @@ int t4_ethrx_handler(struct sge_rspq *q, const __be64 *rsp,
 			    CPL_TRACE_PKT : CPL_TRACE_PKT_T5;
 #ifdef CONFIG_CHELSIO_T4_FCOE
 	struct port_info *pi;
+	if (cxgb_fcoe_rx_handler(q, rsp))
+		return 0;
 #endif
 
 	if (unlikely(*(u8 *)rsp == cpl_trace_pkt))
diff --git a/drivers/net/ethernet/chelsio/cxgb4/t4_hw.c b/drivers/net/ethernet/chelsio/cxgb4/t4_hw.c
index 5959e3a..bcb0567 100644
--- a/drivers/net/ethernet/chelsio/cxgb4/t4_hw.c
+++ b/drivers/net/ethernet/chelsio/cxgb4/t4_hw.c
@@ -5303,6 +5303,7 @@ int t4_init_tp_params(struct adapter *adap)
 	 * shift positions of several elements of the Compressed Filter Tuple
 	 * for this adapter which we need frequently ...
 	 */
+	adap->params.tp.fcoe_shift = t4_filter_field_shift(adap, FCOE_F);
 	adap->params.tp.vlan_shift = t4_filter_field_shift(adap, VLAN_F);
 	adap->params.tp.vnic_shift = t4_filter_field_shift(adap, VNIC_ID_F);
 	adap->params.tp.port_shift = t4_filter_field_shift(adap, PORT_F);
-- 
1.7.1
