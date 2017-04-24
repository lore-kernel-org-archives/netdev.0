From: John Fastabend <john.fastabend@gmail.com>
Subject: [PATCH 1/2] ixgbe: add XDP support for pass and drop actions
Date: Sun, 23 Apr 2017 18:31:19 -0700
Message-ID: <20170424013119.8354.18750.stgit@john-Precision-Tower-5810>
References: <20170424013004.8354.34893.stgit@john-Precision-Tower-5810>
Mime-Version: 1.0
Content-Type: text/plain; charset="utf-8"
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org
To: jeffrey.t.kirsher@intel.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-io0-f196.google.com ([209.85.223.196]:36709 "EHLO
        mail-io0-f196.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1163962AbdDXBba (ORCPT
        <rfc822;netdev@vger.kernel.org>); Sun, 23 Apr 2017 21:31:30 -0400
Received: by mail-io0-f196.google.com with SMTP id x86so44228627ioe.3
        for <netdev@vger.kernel.org>; Sun, 23 Apr 2017 18:31:30 -0700 (PDT)
In-Reply-To: <20170424013004.8354.34893.stgit@john-Precision-Tower-5810>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Basic XDP drop support for ixgbe. Uses READ_ONCE/xchg semantics on XDP
programs instead of rcu primitives as suggested by Daniel Borkmann and
Alex Duyck.

Signed-off-by: John Fastabend <john.r.fastabend@intel.com>
Acked-by: Alexander Duyck <alexander.h.duyck@intel.com>
---
 0 files changed

diff --git a/drivers/net/ethernet/intel/ixgbe/ixgbe.h b/drivers/net/ethernet/intel/ixgbe/ixgbe.h
index 656ca8f..cb14813 100644
--- a/drivers/net/ethernet/intel/ixgbe/ixgbe.h
+++ b/drivers/net/ethernet/intel/ixgbe/ixgbe.h
@@ -318,6 +318,7 @@ struct ixgbe_ring {
 	struct ixgbe_ring *next;	/* pointer to next ring in q_vector */
 	struct ixgbe_q_vector *q_vector; /* backpointer to host q_vector */
 	struct net_device *netdev;	/* netdev ring belongs to */
+	struct bpf_prog *xdp_prog;
 	struct device *dev;		/* device for DMA mapping */
 	struct ixgbe_fwd_adapter *l2_accel_priv;
 	void *desc;			/* descriptor ring memory */
@@ -555,6 +556,7 @@ struct ixgbe_adapter {
 	unsigned long active_vlans[BITS_TO_LONGS(VLAN_N_VID)];
 	/* OS defined structs */
 	struct net_device *netdev;
+	struct bpf_prog *xdp_prog;
 	struct pci_dev *pdev;
 
 	unsigned long state;
@@ -835,7 +837,7 @@ enum ixgbe_boards {
 void ixgbe_reinit_locked(struct ixgbe_adapter *adapter);
 void ixgbe_reset(struct ixgbe_adapter *adapter);
 void ixgbe_set_ethtool_ops(struct net_device *netdev);
-int ixgbe_setup_rx_resources(struct ixgbe_ring *);
+int ixgbe_setup_rx_resources(struct ixgbe_adapter *, struct ixgbe_ring *);
 int ixgbe_setup_tx_resources(struct ixgbe_ring *);
 void ixgbe_free_rx_resources(struct ixgbe_ring *);
 void ixgbe_free_tx_resources(struct ixgbe_ring *);
diff --git a/drivers/net/ethernet/intel/ixgbe/ixgbe_ethtool.c b/drivers/net/ethernet/intel/ixgbe/ixgbe_ethtool.c
index 59730ed..79a126d 100644
--- a/drivers/net/ethernet/intel/ixgbe/ixgbe_ethtool.c
+++ b/drivers/net/ethernet/intel/ixgbe/ixgbe_ethtool.c
@@ -1128,7 +1128,7 @@ static int ixgbe_set_ringparam(struct net_device *netdev,
 			       sizeof(struct ixgbe_ring));
 
 			temp_ring[i].count = new_rx_count;
-			err = ixgbe_setup_rx_resources(&temp_ring[i]);
+			err = ixgbe_setup_rx_resources(adapter, &temp_ring[i]);
 			if (err) {
 				while (i) {
 					i--;
@@ -1761,7 +1761,7 @@ static int ixgbe_setup_desc_rings(struct ixgbe_adapter *adapter)
 	rx_ring->netdev = adapter->netdev;
 	rx_ring->reg_idx = adapter->rx_ring[0]->reg_idx;
 
-	err = ixgbe_setup_rx_resources(rx_ring);
+	err = ixgbe_setup_rx_resources(adapter, rx_ring);
 	if (err) {
 		ret_val = 4;
 		goto err_nomem;
diff --git a/drivers/net/ethernet/intel/ixgbe/ixgbe_main.c b/drivers/net/ethernet/intel/ixgbe/ixgbe_main.c
index 730742a..ebcf9c0 100644
--- a/drivers/net/ethernet/intel/ixgbe/ixgbe_main.c
+++ b/drivers/net/ethernet/intel/ixgbe/ixgbe_main.c
@@ -49,6 +49,9 @@
 #include <linux/if_macvlan.h>
 #include <linux/if_bridge.h>
 #include <linux/prefetch.h>
+#include <linux/bpf.h>
+#include <linux/bpf_trace.h>
+#include <linux/atomic.h>
 #include <scsi/fc/fc_fcoe.h>
 #include <net/udp_tunnel.h>
 #include <net/pkt_cls.h>
@@ -1856,6 +1859,10 @@ static void ixgbe_dma_sync_frag(struct ixgbe_ring *rx_ring,
  * @rx_desc: pointer to the EOP Rx descriptor
  * @skb: pointer to current skb being fixed
  *
+ * Check if the skb is valid in the XDP case it will be an error pointer.
+ * Return true in this case to abort processing and advance to next
+ * descriptor.
+ *
  * Check for corrupted packet headers caused by senders on the local L2
  * embedded NIC switch not setting up their Tx Descriptors right.  These
  * should be very rare.
@@ -1874,6 +1881,10 @@ static bool ixgbe_cleanup_headers(struct ixgbe_ring *rx_ring,
 {
 	struct net_device *netdev = rx_ring->netdev;
 
+	/* XDP packets use error pointer so abort at this point */
+	if (IS_ERR(skb))
+		return true;
+
 	/* verify that the packet does not have any known errors */
 	if (unlikely(ixgbe_test_staterr(rx_desc,
 					IXGBE_RXDADV_ERR_FRAME_ERR_MASK) &&
@@ -2049,7 +2060,7 @@ static void ixgbe_put_rx_buffer(struct ixgbe_ring *rx_ring,
 		/* hand second half of page back to the ring */
 		ixgbe_reuse_rx_page(rx_ring, rx_buffer);
 	} else {
-		if (IXGBE_CB(skb)->dma == rx_buffer->dma) {
+		if (!IS_ERR(skb) && IXGBE_CB(skb)->dma == rx_buffer->dma) {
 			/* the page has been released from the ring */
 			IXGBE_CB(skb)->page_released = true;
 		} else {
@@ -2070,21 +2081,22 @@ static void ixgbe_put_rx_buffer(struct ixgbe_ring *rx_ring,
 
 static struct sk_buff *ixgbe_construct_skb(struct ixgbe_ring *rx_ring,
 					   struct ixgbe_rx_buffer *rx_buffer,
-					   union ixgbe_adv_rx_desc *rx_desc,
-					   unsigned int size)
+					   struct xdp_buff *xdp,
+					   union ixgbe_adv_rx_desc *rx_desc)
 {
-	void *va = page_address(rx_buffer->page) + rx_buffer->page_offset;
+	unsigned int size = xdp->data_end - xdp->data;
 #if (PAGE_SIZE < 8192)
 	unsigned int truesize = ixgbe_rx_pg_size(rx_ring) / 2;
 #else
-	unsigned int truesize = SKB_DATA_ALIGN(size);
+	unsigned int truesize = SKB_DATA_ALIGN(xdp->data_end -
+					       xdp->data_hard_start);
 #endif
 	struct sk_buff *skb;
 
 	/* prefetch first cache line of first page */
-	prefetch(va);
+	prefetch(xdp->data);
 #if L1_CACHE_BYTES < 128
-	prefetch(va + L1_CACHE_BYTES);
+	prefetch(xdp->data + L1_CACHE_BYTES);
 #endif
 
 	/* allocate a skb to store the frags */
@@ -2097,7 +2109,7 @@ static struct sk_buff *ixgbe_construct_skb(struct ixgbe_ring *rx_ring,
 			IXGBE_CB(skb)->dma = rx_buffer->dma;
 
 		skb_add_rx_frag(skb, 0, rx_buffer->page,
-				rx_buffer->page_offset,
+				xdp->data - page_address(rx_buffer->page),
 				size, truesize);
 #if (PAGE_SIZE < 8192)
 		rx_buffer->page_offset ^= truesize;
@@ -2105,7 +2117,8 @@ static struct sk_buff *ixgbe_construct_skb(struct ixgbe_ring *rx_ring,
 		rx_buffer->page_offset += truesize;
 #endif
 	} else {
-		memcpy(__skb_put(skb, size), va, ALIGN(size, sizeof(long)));
+		memcpy(__skb_put(skb, size),
+		       xdp->data, ALIGN(size, sizeof(long)));
 		rx_buffer->pagecnt_bias++;
 	}
 
@@ -2114,32 +2127,32 @@ static struct sk_buff *ixgbe_construct_skb(struct ixgbe_ring *rx_ring,
 
 static struct sk_buff *ixgbe_build_skb(struct ixgbe_ring *rx_ring,
 				       struct ixgbe_rx_buffer *rx_buffer,
-				       union ixgbe_adv_rx_desc *rx_desc,
-				       unsigned int size)
+				       struct xdp_buff *xdp,
+				       union ixgbe_adv_rx_desc *rx_desc)
 {
-	void *va = page_address(rx_buffer->page) + rx_buffer->page_offset;
 #if (PAGE_SIZE < 8192)
 	unsigned int truesize = ixgbe_rx_pg_size(rx_ring) / 2;
 #else
 	unsigned int truesize = SKB_DATA_ALIGN(sizeof(struct skb_shared_info)) +
-				SKB_DATA_ALIGN(IXGBE_SKB_PAD + size);
+				SKB_DATA_ALIGN(xdp->data_end -
+					       xdp->data_hard_start);
 #endif
 	struct sk_buff *skb;
 
 	/* prefetch first cache line of first page */
-	prefetch(va);
+	prefetch(xdp->data);
 #if L1_CACHE_BYTES < 128
-	prefetch(va + L1_CACHE_BYTES);
+	prefetch(xdp->data + L1_CACHE_BYTES);
 #endif
 
-	/* build an skb around the page buffer */
-	skb = build_skb(va - IXGBE_SKB_PAD, truesize);
+	/* build an skb to around the page buffer */
+	skb = build_skb(xdp->data_hard_start, truesize);
 	if (unlikely(!skb))
 		return NULL;
 
 	/* update pointers within the skb to store the data */
-	skb_reserve(skb, IXGBE_SKB_PAD);
-	__skb_put(skb, size);
+	skb_reserve(skb, xdp->data - xdp->data_hard_start);
+	__skb_put(skb, xdp->data_end - xdp->data);
 
 	/* record DMA address if this is the start of a chain of buffers */
 	if (!ixgbe_test_staterr(rx_desc, IXGBE_RXD_STAT_EOP))
@@ -2155,6 +2168,41 @@ static struct sk_buff *ixgbe_build_skb(struct ixgbe_ring *rx_ring,
 	return skb;
 }
 
+#define IXGBE_XDP_PASS 0
+#define IXGBE_XDP_CONSUMED 1
+
+static struct sk_buff *ixgbe_run_xdp(struct ixgbe_ring  *rx_ring,
+				     struct xdp_buff *xdp)
+{
+	int result = IXGBE_XDP_PASS;
+	struct bpf_prog *xdp_prog;
+	u32 act;
+
+	rcu_read_lock();
+	xdp_prog = READ_ONCE(rx_ring->xdp_prog);
+
+	if (!xdp_prog)
+		goto xdp_out;
+
+	act = bpf_prog_run_xdp(xdp_prog, xdp);
+	switch (act) {
+	case XDP_PASS:
+		break;
+	default:
+		bpf_warn_invalid_xdp_action(act);
+	case XDP_TX:
+	case XDP_ABORTED:
+		trace_xdp_exception(rx_ring->netdev, xdp_prog, act);
+		/* fallthrough -- handle aborts by dropping packet */
+	case XDP_DROP:
+		result = IXGBE_XDP_CONSUMED;
+		break;
+	}
+xdp_out:
+	rcu_read_unlock();
+	return ERR_PTR(-result);
+}
+
 /**
  * ixgbe_clean_rx_irq - Clean completed descriptors from Rx ring - bounce buf
  * @q_vector: structure containing interrupt and ring information
@@ -2184,6 +2232,7 @@ static int ixgbe_clean_rx_irq(struct ixgbe_q_vector *q_vector,
 		union ixgbe_adv_rx_desc *rx_desc;
 		struct ixgbe_rx_buffer *rx_buffer;
 		struct sk_buff *skb;
+		struct xdp_buff xdp;
 		unsigned int size;
 
 		/* return some buffers to hardware, one at a time is too slow */
@@ -2206,14 +2255,29 @@ static int ixgbe_clean_rx_irq(struct ixgbe_q_vector *q_vector,
 		rx_buffer = ixgbe_get_rx_buffer(rx_ring, rx_desc, &skb, size);
 
 		/* retrieve a buffer from the ring */
-		if (skb)
+		if (!skb) {
+			xdp.data = page_address(rx_buffer->page) +
+						rx_buffer->page_offset;
+			xdp.data_hard_start = xdp.data -
+						ixgbe_rx_offset(rx_ring);
+			xdp.data_end = xdp.data + size;
+
+			skb = ixgbe_run_xdp(rx_ring, &xdp);
+		}
+
+		if (IS_ERR(skb)) {
+			total_rx_packets++;
+			total_rx_bytes += size;
+			rx_buffer->pagecnt_bias++;
+		} else if (skb) {
 			ixgbe_add_rx_frag(rx_ring, rx_buffer, skb, size);
-		else if (ring_uses_build_skb(rx_ring))
+		} else if (ring_uses_build_skb(rx_ring)) {
 			skb = ixgbe_build_skb(rx_ring, rx_buffer,
-					      rx_desc, size);
-		else
+					      &xdp, rx_desc);
+		} else {
 			skb = ixgbe_construct_skb(rx_ring, rx_buffer,
-						  rx_desc, size);
+						  &xdp, rx_desc);
+		}
 
 		/* exit if we failed to retrieve a buffer */
 		if (!skb) {
@@ -6072,7 +6136,8 @@ static int ixgbe_setup_all_tx_resources(struct ixgbe_adapter *adapter)
  *
  * Returns 0 on success, negative on failure
  **/
-int ixgbe_setup_rx_resources(struct ixgbe_ring *rx_ring)
+int ixgbe_setup_rx_resources(struct ixgbe_adapter *adapter,
+			     struct ixgbe_ring *rx_ring)
 {
 	struct device *dev = rx_ring->dev;
 	int orig_node = dev_to_node(dev);
@@ -6109,6 +6174,8 @@ int ixgbe_setup_rx_resources(struct ixgbe_ring *rx_ring)
 	rx_ring->next_to_clean = 0;
 	rx_ring->next_to_use = 0;
 
+	rx_ring->xdp_prog = adapter->xdp_prog;
+
 	return 0;
 err:
 	vfree(rx_ring->rx_buffer_info);
@@ -6132,7 +6199,7 @@ static int ixgbe_setup_all_rx_resources(struct ixgbe_adapter *adapter)
 	int i, err = 0;
 
 	for (i = 0; i < adapter->num_rx_queues; i++) {
-		err = ixgbe_setup_rx_resources(adapter->rx_ring[i]);
+		err = ixgbe_setup_rx_resources(adapter, adapter->rx_ring[i]);
 		if (!err)
 			continue;
 
@@ -6200,6 +6267,7 @@ void ixgbe_free_rx_resources(struct ixgbe_ring *rx_ring)
 {
 	ixgbe_clean_rx_ring(rx_ring);
 
+	rx_ring->xdp_prog = NULL;
 	vfree(rx_ring->rx_buffer_info);
 	rx_ring->rx_buffer_info = NULL;
 
@@ -9468,6 +9536,54 @@ static void ixgbe_fwd_del(struct net_device *pdev, void *priv)
 	return features;
 }
 
+static int ixgbe_xdp_setup(struct net_device *dev, struct bpf_prog *prog)
+{
+	int i, frame_size = dev->mtu + ETH_HLEN + ETH_FCS_LEN + VLAN_HLEN;
+	struct ixgbe_adapter *adapter = netdev_priv(dev);
+	struct bpf_prog *old_prog;
+
+	if (adapter->flags & IXGBE_FLAG_SRIOV_ENABLED)
+		return -EINVAL;
+
+	if (adapter->flags & IXGBE_FLAG_DCB_ENABLED)
+		return -EINVAL;
+
+	/* verify ixgbe ring attributes are sufficient for XDP */
+	for (i = 0; i < adapter->num_rx_queues; i++) {
+		struct ixgbe_ring *ring = adapter->rx_ring[i];
+
+		if (ring_is_rsc_enabled(ring))
+			return -EINVAL;
+
+		if (frame_size > ixgbe_rx_bufsz(ring))
+			return -EINVAL;
+	}
+
+	old_prog = xchg(&adapter->xdp_prog, prog);
+	for (i = 0; i < adapter->num_rx_queues; i++)
+		xchg(&adapter->rx_ring[i]->xdp_prog, adapter->xdp_prog);
+
+	if (old_prog)
+		bpf_prog_put(old_prog);
+
+	return 0;
+}
+
+static int ixgbe_xdp(struct net_device *dev, struct netdev_xdp *xdp)
+{
+	struct ixgbe_adapter *adapter = netdev_priv(dev);
+
+	switch (xdp->command) {
+	case XDP_SETUP_PROG:
+		return ixgbe_xdp_setup(dev, xdp->prog);
+	case XDP_QUERY_PROG:
+		xdp->prog_attached = !!(adapter->xdp_prog);
+		return 0;
+	default:
+		return -EINVAL;
+	}
+}
+
 static const struct net_device_ops ixgbe_netdev_ops = {
 	.ndo_open		= ixgbe_open,
 	.ndo_stop		= ixgbe_close,
@@ -9513,6 +9629,7 @@ static void ixgbe_fwd_del(struct net_device *pdev, void *priv)
 	.ndo_udp_tunnel_add	= ixgbe_add_udp_tunnel_port,
 	.ndo_udp_tunnel_del	= ixgbe_del_udp_tunnel_port,
 	.ndo_features_check	= ixgbe_features_check,
+	.ndo_xdp		= ixgbe_xdp,
 };
 
 /**
