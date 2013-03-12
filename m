From: Vipul Pandya <vipul@chelsio.com>
Subject: [PATCH net-next 12/22] RDMA/cxgb4: Add Support for Chelsio T5 adapter
Date: Tue, 12 Mar 2013 17:16:24 +0530
Message-ID: <1363088794-31453-13-git-send-email-vipul@chelsio.com>
References: <1363088794-31453-1-git-send-email-vipul@chelsio.com>
Cc: davem@davemloft.net, roland@purestorage.com,
	JBottomley@parallels.com, dm@chelsio.com,
	swise@opengridcomputing.com, leedom@chelsio.com,
	naresh@chelsio.com, divy@chelsio.com, santosh@chelsio.com,
	arvindb@chelsio.com, abhishek@chelsio.com,
	Vipul Pandya <vipul@chelsio.com>
To: netdev@vger.kernel.org, linux-rdma@vger.kernel.org,
	linux-scsi@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from stargate.chelsio.com ([67.207.112.58]:9209 "EHLO
	stargate.chelsio.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S932733Ab3CLLxT (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 12 Mar 2013 07:53:19 -0400
In-Reply-To: <1363088794-31453-1-git-send-email-vipul@chelsio.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Adds support for Chelsio T5 adapter.
Enables T5's Write Combining feature.

Signed-off-by: Vipul Pandya <vipul@chelsio.com>
---
 drivers/infiniband/hw/cxgb4/cm.c       |   64 +++++++++++++++++++++++--------
 drivers/infiniband/hw/cxgb4/device.c   |   13 ++++--
 drivers/infiniband/hw/cxgb4/iw_cxgb4.h |    9 ++++
 drivers/infiniband/hw/cxgb4/provider.c |   15 +++++--
 drivers/infiniband/hw/cxgb4/qp.c       |    2 +-
 drivers/infiniband/hw/cxgb4/t4.h       |    9 ----
 6 files changed, 77 insertions(+), 35 deletions(-)

diff --git a/drivers/infiniband/hw/cxgb4/cm.c b/drivers/infiniband/hw/cxgb4/cm.c
index 565bfb1..272bf78 100644
--- a/drivers/infiniband/hw/cxgb4/cm.c
+++ b/drivers/infiniband/hw/cxgb4/cm.c
@@ -511,12 +511,16 @@ static unsigned int select_ntuple(struct c4iw_dev *dev, struct dst_entry *dst,
 static int send_connect(struct c4iw_ep *ep)
 {
 	struct cpl_act_open_req *req;
+	struct cpl_t5_act_open_req *t5_req;
 	struct sk_buff *skb;
 	u64 opt0;
 	u32 opt2;
 	unsigned int mtu_idx;
 	int wscale;
-	int wrlen = roundup(sizeof *req, 16);
+	int size = is_t4(ep->com.dev->rdev.lldi.adapter_type) ?
+		sizeof(struct cpl_act_open_req) :
+		sizeof(struct cpl_t5_act_open_req);
+	int wrlen = roundup(size, 16);
 
 	PDBG("%s ep %p atid %u\n", __func__, ep, ep->atid);
 
@@ -552,17 +556,36 @@ static int send_connect(struct c4iw_ep *ep)
 		opt2 |= WND_SCALE_EN(1);
 	t4_set_arp_err_handler(skb, NULL, act_open_req_arp_failure);
 
-	req = (struct cpl_act_open_req *) skb_put(skb, wrlen);
-	INIT_TP_WR(req, 0);
-	OPCODE_TID(req) = cpu_to_be32(
-		MK_OPCODE_TID(CPL_ACT_OPEN_REQ, ((ep->rss_qid<<14)|ep->atid)));
-	req->local_port = ep->com.local_addr.sin_port;
-	req->peer_port = ep->com.remote_addr.sin_port;
-	req->local_ip = ep->com.local_addr.sin_addr.s_addr;
-	req->peer_ip = ep->com.remote_addr.sin_addr.s_addr;
-	req->opt0 = cpu_to_be64(opt0);
-	req->params = cpu_to_be32(select_ntuple(ep->com.dev, ep->dst, ep->l2t));
-	req->opt2 = cpu_to_be32(opt2);
+	if (is_t4(ep->com.dev->rdev.lldi.adapter_type)) {
+		req = (struct cpl_act_open_req *) skb_put(skb, wrlen);
+		INIT_TP_WR(req, 0);
+		OPCODE_TID(req) = cpu_to_be32(
+				MK_OPCODE_TID(CPL_ACT_OPEN_REQ,
+				((ep->rss_qid << 14) | ep->atid)));
+		req->local_port = ep->com.local_addr.sin_port;
+		req->peer_port = ep->com.remote_addr.sin_port;
+		req->local_ip = ep->com.local_addr.sin_addr.s_addr;
+		req->peer_ip = ep->com.remote_addr.sin_addr.s_addr;
+		req->opt0 = cpu_to_be64(opt0);
+		req->params = cpu_to_be32(select_ntuple(ep->com.dev,
+					ep->dst, ep->l2t));
+		req->opt2 = cpu_to_be32(opt2);
+	} else {
+		t5_req = (struct cpl_t5_act_open_req *) skb_put(skb, wrlen);
+		INIT_TP_WR(t5_req, 0);
+		OPCODE_TID(t5_req) = cpu_to_be32(
+					MK_OPCODE_TID(CPL_ACT_OPEN_REQ,
+					((ep->rss_qid << 14) | ep->atid)));
+		t5_req->local_port = ep->com.local_addr.sin_port;
+		t5_req->peer_port = ep->com.remote_addr.sin_port;
+		t5_req->local_ip = ep->com.local_addr.sin_addr.s_addr;
+		t5_req->peer_ip = ep->com.remote_addr.sin_addr.s_addr;
+		t5_req->opt0 = cpu_to_be64(opt0);
+		t5_req->params = cpu_to_be64(V_FILTER_TUPLE(
+				select_ntuple(ep->com.dev, ep->dst, ep->l2t)));
+		t5_req->opt2 = cpu_to_be32(opt2);
+	}
+
 	set_bit(ACT_OPEN_REQ, &ep->com.history);
 	return c4iw_l2t_send(&ep->com.dev->rdev, skb, ep->l2t);
 }
@@ -2869,12 +2892,14 @@ static int deferred_fw6_msg(struct c4iw_dev *dev, struct sk_buff *skb)
 static void build_cpl_pass_accept_req(struct sk_buff *skb, int stid , u8 tos)
 {
 	u32 l2info;
-	u16 vlantag, len, hdr_len;
+	u16 vlantag, len, hdr_len, eth_hdr_len;
 	u8 intf;
 	struct cpl_rx_pkt *cpl = cplhdr(skb);
 	struct cpl_pass_accept_req *req;
 	struct tcp_options_received tmp_opt;
+	struct c4iw_dev *dev;
 
+	dev = *((struct c4iw_dev **) (skb->cb + sizeof(void *)));
 	/* Store values from cpl_rx_pkt in temporary location. */
 	vlantag = (__force u16) cpl->vlan;
 	len = (__force u16) cpl->len;
@@ -2898,14 +2923,16 @@ static void build_cpl_pass_accept_req(struct sk_buff *skb, int stid , u8 tos)
 			 V_SYN_MAC_IDX(G_RX_MACIDX(
 			 (__force int) htonl(l2info))) |
 			 F_SYN_XACT_MATCH);
+	eth_hdr_len = is_t4(dev->rdev.lldi.adapter_type) ?
+			    G_RX_ETHHDR_LEN((__force int) htonl(l2info)) :
+			    G_RX_T5_ETHHDR_LEN((__force int) htonl(l2info));
 	req->hdr_len = cpu_to_be32(V_SYN_RX_CHAN(G_RX_CHAN(
 					(__force int) htonl(l2info))) |
 				   V_TCP_HDR_LEN(G_RX_TCPHDR_LEN(
 					(__force int) htons(hdr_len))) |
 				   V_IP_HDR_LEN(G_RX_IPHDR_LEN(
 					(__force int) htons(hdr_len))) |
-				   V_ETH_HDR_LEN(G_RX_ETHHDR_LEN(
-					(__force int) htonl(l2info))));
+				   V_ETH_HDR_LEN(G_RX_ETHHDR_LEN(eth_hdr_len)));
 	req->vlan = (__force __be16) vlantag;
 	req->len = (__force __be16) len;
 	req->tos_stid = cpu_to_be32(PASS_OPEN_TID(stid) |
@@ -2993,7 +3020,7 @@ static int rx_pkt(struct c4iw_dev *dev, struct sk_buff *skb)
 	u16 window;
 	struct port_info *pi;
 	struct net_device *pdev;
-	u16 rss_qid;
+	u16 rss_qid, eth_hdr_len;
 	int step;
 	u32 tx_chan;
 	struct neighbour *neigh;
@@ -3022,7 +3049,10 @@ static int rx_pkt(struct c4iw_dev *dev, struct sk_buff *skb)
 		goto reject;
 	}
 
-	if (G_RX_ETHHDR_LEN(ntohl(cpl->l2info)) == ETH_HLEN) {
+	eth_hdr_len = is_t4(dev->rdev.lldi.adapter_type) ?
+			    G_RX_ETHHDR_LEN(htonl(cpl->l2info)) :
+			    G_RX_T5_ETHHDR_LEN(htonl(cpl->l2info));
+	if (eth_hdr_len == ETH_HLEN) {
 		eh = (struct ethhdr *)(req + 1);
 		iph = (struct iphdr *)(eh + 1);
 	} else {
diff --git a/drivers/infiniband/hw/cxgb4/device.c b/drivers/infiniband/hw/cxgb4/device.c
index 80069ad..3487c08 100644
--- a/drivers/infiniband/hw/cxgb4/device.c
+++ b/drivers/infiniband/hw/cxgb4/device.c
@@ -41,7 +41,7 @@
 #define DRV_VERSION "0.1"
 
 MODULE_AUTHOR("Steve Wise");
-MODULE_DESCRIPTION("Chelsio T4 RDMA Driver");
+MODULE_DESCRIPTION("Chelsio T4/T5 RDMA Driver");
 MODULE_LICENSE("Dual BSD/GPL");
 MODULE_VERSION(DRV_VERSION);
 
@@ -614,7 +614,7 @@ static int rdma_supported(const struct cxgb4_lld_info *infop)
 {
 	return infop->vr->stag.size > 0 && infop->vr->pbl.size > 0 &&
 	       infop->vr->rq.size > 0 && infop->vr->qp.size > 0 &&
-	       infop->vr->cq.size > 0 && infop->vr->ocq.size > 0;
+	       infop->vr->cq.size > 0;
 }
 
 static struct c4iw_dev *c4iw_alloc(const struct cxgb4_lld_info *infop)
@@ -627,6 +627,11 @@ static struct c4iw_dev *c4iw_alloc(const struct cxgb4_lld_info *infop)
 		       pci_name(infop->pdev));
 		return ERR_PTR(-ENOSYS);
 	}
+	if (!ocqp_supported(infop))
+		pr_info("%s: On-Chip Queues not supported on this device.\n",
+			pci_name(infop->pdev));
+	if (!is_t4(infop->adapter_type))
+		db_fc_threshold = 100000;
 	devp = (struct c4iw_dev *)ib_alloc_device(sizeof(*devp));
 	if (!devp) {
 		printk(KERN_ERR MOD "Cannot allocate ib device\n");
@@ -678,8 +683,8 @@ static void *c4iw_uld_add(const struct cxgb4_lld_info *infop)
 	int i;
 
 	if (!vers_printed++)
-		printk(KERN_INFO MOD "Chelsio T4 RDMA Driver - version %s\n",
-		       DRV_VERSION);
+		pr_info("Chelsio T4/T5 RDMA Driver - version %s\n",
+			DRV_VERSION);
 
 	ctx = kzalloc(sizeof *ctx, GFP_KERNEL);
 	if (!ctx) {
diff --git a/drivers/infiniband/hw/cxgb4/iw_cxgb4.h b/drivers/infiniband/hw/cxgb4/iw_cxgb4.h
index 7eec5e1..34c7e62 100644
--- a/drivers/infiniband/hw/cxgb4/iw_cxgb4.h
+++ b/drivers/infiniband/hw/cxgb4/iw_cxgb4.h
@@ -817,6 +817,15 @@ static inline int compute_wscale(int win)
 	return wscale;
 }
 
+static inline int ocqp_supported(const struct cxgb4_lld_info *infop)
+{
+#if defined(__i386__) || defined(__x86_64__) || defined(CONFIG_PPC64)
+	return infop->vr->ocq.size > 0;
+#else
+	return 0;
+#endif
+}
+
 u32 c4iw_id_alloc(struct c4iw_id_table *alloc);
 void c4iw_id_free(struct c4iw_id_table *alloc, u32 obj);
 int c4iw_id_table_alloc(struct c4iw_id_table *alloc, u32 start, u32 num,
diff --git a/drivers/infiniband/hw/cxgb4/provider.c b/drivers/infiniband/hw/cxgb4/provider.c
index e084fdc..7e94c9a 100644
--- a/drivers/infiniband/hw/cxgb4/provider.c
+++ b/drivers/infiniband/hw/cxgb4/provider.c
@@ -162,8 +162,14 @@ static int c4iw_mmap(struct ib_ucontext *context, struct vm_area_struct *vma)
 		 */
 		if (addr >= rdev->oc_mw_pa)
 			vma->vm_page_prot = t4_pgprot_wc(vma->vm_page_prot);
-		else
-			vma->vm_page_prot = pgprot_noncached(vma->vm_page_prot);
+		else {
+			if (is_t5(rdev->lldi.adapter_type))
+				vma->vm_page_prot =
+					t4_pgprot_wc(vma->vm_page_prot);
+			else
+				vma->vm_page_prot =
+					pgprot_noncached(vma->vm_page_prot);
+		}
 		ret = io_remap_pfn_range(vma, vma->vm_start,
 					 addr >> PAGE_SHIFT,
 					 len, vma->vm_page_prot);
@@ -263,7 +269,7 @@ static int c4iw_query_device(struct ib_device *ibdev,
 	dev = to_c4iw_dev(ibdev);
 	memset(props, 0, sizeof *props);
 	memcpy(&props->sys_image_guid, dev->rdev.lldi.ports[0]->dev_addr, 6);
-	props->hw_ver = dev->rdev.lldi.adapter_type;
+	props->hw_ver = CHELSIO_CHIP_RELEASE(dev->rdev.lldi.adapter_type);
 	props->fw_ver = dev->rdev.lldi.fw_vers;
 	props->device_cap_flags = dev->device_cap_flags;
 	props->page_size_cap = T4_PAGESIZE_MASK;
@@ -346,7 +352,8 @@ static ssize_t show_rev(struct device *dev, struct device_attribute *attr,
 	struct c4iw_dev *c4iw_dev = container_of(dev, struct c4iw_dev,
 						 ibdev.dev);
 	PDBG("%s dev 0x%p\n", __func__, dev);
-	return sprintf(buf, "%d\n", c4iw_dev->rdev.lldi.adapter_type);
+	return sprintf(buf, "%d\n",
+		       CHELSIO_CHIP_RELEASE(c4iw_dev->rdev.lldi.adapter_type));
 }
 
 static ssize_t show_fw_ver(struct device *dev, struct device_attribute *attr,
diff --git a/drivers/infiniband/hw/cxgb4/qp.c b/drivers/infiniband/hw/cxgb4/qp.c
index 17ba4f8..c460244 100644
--- a/drivers/infiniband/hw/cxgb4/qp.c
+++ b/drivers/infiniband/hw/cxgb4/qp.c
@@ -76,7 +76,7 @@ static void dealloc_sq(struct c4iw_rdev *rdev, struct t4_sq *sq)
 
 static int alloc_oc_sq(struct c4iw_rdev *rdev, struct t4_sq *sq)
 {
-	if (!ocqp_support || !t4_ocqp_supported())
+	if (!ocqp_support || !ocqp_supported(&rdev->lldi))
 		return -ENOSYS;
 	sq->dma_addr = c4iw_ocqp_pool_alloc(rdev, sq->memsize);
 	if (!sq->dma_addr)
diff --git a/drivers/infiniband/hw/cxgb4/t4.h b/drivers/infiniband/hw/cxgb4/t4.h
index 16f26ab..689edc9 100644
--- a/drivers/infiniband/hw/cxgb4/t4.h
+++ b/drivers/infiniband/hw/cxgb4/t4.h
@@ -280,15 +280,6 @@ static inline pgprot_t t4_pgprot_wc(pgprot_t prot)
 #endif
 }
 
-static inline int t4_ocqp_supported(void)
-{
-#if defined(__i386__) || defined(__x86_64__) || defined(CONFIG_PPC64)
-	return 1;
-#else
-	return 0;
-#endif
-}
-
 enum {
 	T4_SQ_ONCHIP = (1<<0),
 };
-- 
1.7.1
