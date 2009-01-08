From: Yevgeny Petrilin <yevgenyp@mellanox.co.il>
Subject: IP LRO
Date: Thu, 08 Jan 2009 10:54:27 +0200
Message-ID: <4965BF43.1060801@mellanox.co.il>
Mime-Version: 1.0
Content-Type: multipart/mixed;
 boundary="------------060905080200010303060405"
Cc: liranl@mellanox.co.il, tziporet@mellanox.co.il
To: davem@davemloft.net, netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail.mellanox.co.il ([194.90.237.43]:43303 "EHLO mellanox.co.il"
	rhost-flags-OK-OK-OK-FAIL) by vger.kernel.org with ESMTP
	id S1751738AbZAHIzb (ORCPT <rfc822;netdev@vger.kernel.org>);
	Thu, 8 Jan 2009 03:55:31 -0500
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

This is a multi-part message in MIME format.

--------------060905080200010303060405
Content-Type: text/plain; charset=ISO-8859-1
Content-Transfer-Encoding: 7bit

Hi,
We have recently implemented a reassembly of fragmented IP packets in
mlx4_en driver. This offload gives a performance boost in case of incoming
traffic with fragmented packets (such as UDP traffic with message size larger
then MTU). The attached patch contains this offload. I believe that we can make
this code generic, maybe part of inet_lro.
Please review and comment.

Thanks,
Yevgeny

--------------060905080200010303060405
Content-Type: text/x-patch;
 name="IP_LRO.patch"
Content-Transfer-Encoding: 7bit
Content-Disposition: inline;
 filename="IP_LRO.patch"

>From 836650837d2c24014cdcc132c7c901676b1563d8 Mon Sep 17 00:00:00 2001
From: Yevgeny Petrilin <yevgenyp@mellanox.co.il>
Date: Wed, 7 Jan 2009 19:31:59 +0200
Subject: [PATCH] IP LRO

Signed-off-by: Yevgeny Petrilin <yevgenyp@mellanox.co.il>
---
 drivers/net/mlx4/Makefile    |    2 +-
 drivers/net/mlx4/en_frag.c   |  246 ++++++++++++++++++++++++++++++++++++++++++
 drivers/net/mlx4/en_params.c |    4 +
 drivers/net/mlx4/en_rx.c     |   29 +++--
 drivers/net/mlx4/mlx4_en.h   |   36 ++++++-
 5 files changed, 304 insertions(+), 13 deletions(-)
 create mode 100644 drivers/net/mlx4/en_frag.c

diff --git a/drivers/net/mlx4/Makefile b/drivers/net/mlx4/Makefile
index a7a97bf..913759e 100644
--- a/drivers/net/mlx4/Makefile
+++ b/drivers/net/mlx4/Makefile
@@ -6,4 +6,4 @@ mlx4_core-y :=	alloc.o catas.o cmd.o cq.o eq.o fw.o icm.o intf.o main.o mcg.o \
 obj-$(CONFIG_MLX4_EN)               += mlx4_en.o
 
 mlx4_en-y := 	en_main.o en_tx.o en_rx.o en_params.o en_port.o en_cq.o \
-		en_resources.o en_netdev.o
+		en_resources.o en_netdev.o en_frag.o
diff --git a/drivers/net/mlx4/en_frag.c b/drivers/net/mlx4/en_frag.c
new file mode 100644
index 0000000..9fb7bb2
--- /dev/null
+++ b/drivers/net/mlx4/en_frag.c
@@ -0,0 +1,246 @@
+/*
+ * Copyright (c) 2007 Mellanox Technologies. All rights reserved.
+ *
+ * This software is available to you under a choice of one of two
+ * licenses.  You may choose to be licensed under the terms of the GNU
+ * General Public License (GPL) Version 2, available from the file
+ * COPYING in the main directory of this source tree, or the
+ * OpenIB.org BSD license below:
+ *
+ *     Redistribution and use in source and binary forms, with or
+ *     without modification, are permitted provided that the following
+ *     conditions are met:
+ *
+ *      - Redistributions of source code must retain the above
+ *        copyright notice, this list of conditions and the following
+ *        disclaimer.
+ *
+ *      - Redistributions in binary form must reproduce the above
+ *        copyright notice, this list of conditions and the following
+ *        disclaimer in the documentation and/or other materials
+ *        provided with the distribution.
+ *
+ * THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND,
+ * EXPRESS OR IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF
+ * MERCHANTABILITY, FITNESS FOR A PARTICULAR PURPOSE AND
+ * NONINFRINGEMENT. IN NO EVENT SHALL THE AUTHORS OR COPYRIGHT HOLDERS
+ * BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER LIABILITY, WHETHER IN AN
+ * ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM, OUT OF OR IN
+ * CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN THE
+ * SOFTWARE.
+ *
+ */
+
+#include <linux/skbuff.h>
+#include <linux/ip.h>
+#include <linux/if_vlan.h>
+#include <net/ip.h>
+#include <linux/etherdevice.h>
+
+#include "mlx4_en.h"
+
+
+static struct mlx4_en_ipfrag *find_session(struct mlx4_en_rx_ring *ring,
+					   struct iphdr *iph)
+{
+	struct mlx4_en_ipfrag *session;
+	int i;
+
+	for (i = 0; i < MLX4_EN_NUM_IPFRAG_SESSIONS; i++) {
+		session = &ring->ipfrag[i];
+		if (session->fragments == NULL)
+			continue;
+		if (session->daddr == iph->daddr &&
+		    session->saddr == iph->saddr &&
+		    session->id == iph->id &&
+		    session->protocol == iph->protocol) {
+			return session;
+		}
+	}
+	return NULL;
+}
+
+static struct mlx4_en_ipfrag *start_session(struct mlx4_en_rx_ring *ring,
+					    struct iphdr *iph)
+{
+	struct mlx4_en_ipfrag *session;
+	int index = -1;
+	int i;
+
+	for (i = 0; i < MLX4_EN_NUM_IPFRAG_SESSIONS; i++) {
+		if (ring->ipfrag[i].fragments == NULL) {
+			index = i;
+			break;
+		}
+	}
+	if (index < 0)
+		return NULL;
+
+	session = &ring->ipfrag[index];
+
+	return session;
+}
+
+
+static void flush_session(struct mlx4_en_priv *priv,
+			  struct mlx4_en_ipfrag *session,
+			  u16 more)
+{
+	struct sk_buff *skb = session->fragments;
+	struct iphdr *iph = (struct iphdr *) skb->data;
+	struct net_device *dev = skb->dev;
+
+	/* Update IP length and checksum */
+	iph->tot_len = htons(session->total_len);
+	iph->frag_off = htons(more | (session->offset >> 3));
+	iph->check = 0;
+	iph->check = ip_fast_csum((unsigned char *)iph, iph->ihl);
+
+	/* Update skb */
+	skb->truesize = skb->len + sizeof(struct sk_buff);
+
+	if (session->vlan)
+		vlan_hwaccel_receive_skb(skb, priv->vlgrp,
+					 be16_to_cpu(session->sl_vid));
+	else
+		netif_receive_skb(skb);
+	dev->last_rx = jiffies;
+	session->fragments = NULL;
+}
+
+
+static inline int frag_append(struct mlx4_en_priv *priv,
+			      struct mlx4_en_ipfrag *session,
+			      struct mlx4_en_rx_desc *rx_desc,
+			      struct skb_frag_struct *skb_frags,
+			      struct mlx4_en_rx_alloc *page_alloc,
+			      unsigned int data_len,
+			      int hlen)
+{
+	struct sk_buff *skb = session->fragments;
+	struct skb_shared_info *info;
+	struct skb_frag_struct *frags_copy;
+	int nr_frags;
+
+	info = skb_shinfo(skb);
+
+	/* Copy fragments from descriptor ring to skb */
+	frags_copy = info->frags + info->nr_frags;
+	nr_frags = mlx4_en_complete_rx_desc(priv, rx_desc, skb_frags,
+					    frags_copy,
+					    page_alloc,
+					    data_len + hlen);
+	if (!nr_frags) {
+		mlx4_dbg(DRV, priv, "Failed completing rx desc during LRO append\n");
+		return -ENOMEM;
+	}
+
+	/* Skip over headers */
+	frags_copy[0].page_offset += hlen;
+
+	if (nr_frags == 1)
+		frags_copy[0].size = data_len;
+	else {
+		/* Adjust size of last fragment to match packet length.
+		 * Note: if this fragment is also the first one, the
+		 *       operation is completed in the next line */
+		frags_copy[nr_frags - 1].size = hlen + data_len -
+			priv->frag_info[nr_frags - 1].frag_prefix_size;
+
+		/* Adjust size of first fragment */
+		frags_copy[0].size -= hlen;
+	}
+
+	/* Update skb bookkeeping */
+	skb->len += data_len;
+	skb->data_len += data_len;
+	session->total_len += data_len;
+	info->nr_frags += nr_frags;
+	return 0;
+}
+
+int mlx4_en_rx_frags(struct mlx4_en_priv *priv, struct mlx4_en_rx_ring *ring,
+		     struct mlx4_en_rx_desc *rx_desc,
+		     struct skb_frag_struct *skb_frags,
+		     unsigned int length,
+		     struct mlx4_cqe *cqe)
+{
+	struct mlx4_en_ipfrag *session;
+	struct sk_buff *skb;
+	struct iphdr *iph;
+	void *va;
+	u16 ip_len;
+	u16 ip_hlen;
+	int data_len;
+	int hlen;
+	int err;
+	u16 offset;
+
+	va = page_address(skb_frags[0].page) + skb_frags[0].page_offset;
+	iph = va + ETH_HLEN;
+	ip_len = ntohs(iph->tot_len);
+	ip_hlen = iph->ihl * 4;
+	data_len = ip_len - ip_hlen;
+	hlen = ETH_HLEN + ip_hlen;
+	offset = ntohs(iph->frag_off);
+	offset &= IP_OFFSET;
+	offset <<= 3;
+
+	session = find_session(ring, iph);
+	if (session) {
+		if (unlikely(session->offset + session->total_len !=
+			     offset + ip_hlen)) {
+			flush_session(priv, session, IP_MF);
+			goto new_session;
+		}
+		err = frag_append(priv, session, rx_desc, skb_frags,
+				  ring->page_alloc, data_len, hlen);
+		if (err) {
+			flush_session(priv, session, IP_MF);
+			return err;
+		}
+	} else {
+new_session:
+		session = start_session(ring, iph);
+		if (unlikely(!session))
+			return -ENOSPC;
+		skb = mlx4_en_rx_skb(priv, rx_desc, skb_frags, ring->page_alloc,
+								ETH_HLEN + ip_len);
+		if (skb) {
+			skb->protocol = eth_type_trans(skb, priv->dev);
+			skb->ip_summed = CHECKSUM_NONE;
+			session->fragments = skb;
+			session->daddr = iph->daddr;
+			session->saddr = iph->saddr;
+			session->id = iph->id;
+			session->protocol = iph->protocol;
+			session->total_len = ip_len;
+			session->offset = offset;
+			session->vlan = (priv->vlgrp &&
+					 (be32_to_cpu(cqe->vlan_my_qpn) &
+					  MLX4_CQE_VLAN_PRESENT_MASK)) ? 1 : 0;
+			session->sl_vid = cqe->sl_vid;
+		}
+	}
+	if (!(ntohs(iph->frag_off) & IP_MF))
+		flush_session(priv, session, 0);
+	else if (skb_shinfo(session->fragments)->nr_frags +
+		 priv->num_frags > MAX_SKB_FRAGS)
+		flush_session(priv, session, IP_MF);
+
+	return 0;
+}
+
+
+void mlx4_en_flush_frags(struct mlx4_en_priv *priv,
+			 struct mlx4_en_rx_ring *ring)
+{
+	struct mlx4_en_ipfrag *session;
+	int i;
+
+	for (i = 0; i < MLX4_EN_NUM_IPFRAG_SESSIONS; i++) {
+		session = &ring->ipfrag[i];
+		if (session->fragments)
+			flush_session(priv, session, IP_MF);
+	}
+}
diff --git a/drivers/net/mlx4/en_params.c b/drivers/net/mlx4/en_params.c
index c1bd040..113aa8d 100644
--- a/drivers/net/mlx4/en_params.c
+++ b/drivers/net/mlx4/en_params.c
@@ -59,6 +59,9 @@ MLX4_EN_PARM_INT(rss_mask, 0xf, "RSS hash type bitmask");
 MLX4_EN_PARM_INT(num_lro, MLX4_EN_MAX_LRO_DESCRIPTORS,
 		 "Number of LRO sessions per ring or disabled (0)");
 
+/* Allow reassembly of fragmented IP packets */
+MLX4_EN_PARM_INT(ip_reasm, 1, "Allow reassembly of fragmented IP packets (!0)");
+
 /* Priority pausing */
 MLX4_EN_PARM_INT(pfctx, 0, "Priority based Flow Control policy on TX[7:0]."
 			   " Per priority bit mask");
@@ -73,6 +76,7 @@ int mlx4_en_get_profile(struct mlx4_en_dev *mdev)
 	params->rss_xor = (rss_xor != 0);
 	params->rss_mask = rss_mask & 0x1f;
 	params->num_lro = min_t(int, num_lro , MLX4_EN_MAX_LRO_DESCRIPTORS);
+	params->ip_reasm = ip_reasm;
 	for (i = 1; i <= MLX4_MAX_PORTS; i++) {
 		params->prof[i].rx_pause = 1;
 		params->prof[i].rx_ppp = pfcrx;
diff --git a/drivers/net/mlx4/en_rx.c b/drivers/net/mlx4/en_rx.c
index c61b0bd..ffdc528 100644
--- a/drivers/net/mlx4/en_rx.c
+++ b/drivers/net/mlx4/en_rx.c
@@ -518,12 +518,12 @@ void mlx4_en_deactivate_rx_ring(struct mlx4_en_priv *priv,
 
 
 /* Unmap a completed descriptor and free unused pages */
-static int mlx4_en_complete_rx_desc(struct mlx4_en_priv *priv,
-				    struct mlx4_en_rx_desc *rx_desc,
-				    struct skb_frag_struct *skb_frags,
-				    struct skb_frag_struct *skb_frags_rx,
-				    struct mlx4_en_rx_alloc *page_alloc,
-				    int length)
+int mlx4_en_complete_rx_desc(struct mlx4_en_priv *priv,
+			     struct mlx4_en_rx_desc *rx_desc,
+			     struct skb_frag_struct *skb_frags,
+			     struct skb_frag_struct *skb_frags_rx,
+			     struct mlx4_en_rx_alloc *page_alloc,
+			     int length)
 {
 	struct mlx4_en_dev *mdev = priv->mdev;
 	struct mlx4_en_frag_info *frag_info;
@@ -566,11 +566,11 @@ fail:
 }
 
 
-static struct sk_buff *mlx4_en_rx_skb(struct mlx4_en_priv *priv,
-				      struct mlx4_en_rx_desc *rx_desc,
-				      struct skb_frag_struct *skb_frags,
-				      struct mlx4_en_rx_alloc *page_alloc,
-				      unsigned int length)
+struct sk_buff *mlx4_en_rx_skb(struct mlx4_en_priv *priv,
+			       struct mlx4_en_rx_desc *rx_desc,
+			       struct skb_frag_struct *skb_frags,
+			       struct mlx4_en_rx_alloc *page_alloc,
+			       unsigned int length)
 {
 	struct mlx4_en_dev *mdev = priv->mdev;
 	struct sk_buff *skb;
@@ -753,6 +753,12 @@ int mlx4_en_process_rx_cq(struct net_device *dev, struct mlx4_en_cq *cq, int bud
 			} else {
 				ip_summed = CHECKSUM_NONE;
 				priv->port_stats.rx_chksum_none++;
+				if (mdev->profile.ip_reasm &&
+				    cqe->status &
+					cpu_to_be16(MLX4_CQE_STATUS_IPV4) &&
+				    !mlx4_en_rx_frags(priv, ring, rx_desc,
+						      skb_frags, length, cqe))
+					goto next;
 			}
 		} else {
 			ip_summed = CHECKSUM_NONE;
@@ -790,6 +796,7 @@ next:
 	}
 
 	/* If CQ is empty flush all LRO sessions unconditionally */
+	mlx4_en_flush_frags(priv, ring);
 	lro_flush_all(&ring->lro);
 
 out:
diff --git a/drivers/net/mlx4/mlx4_en.h b/drivers/net/mlx4/mlx4_en.h
index e9af32d..5ddebf9 100644
--- a/drivers/net/mlx4/mlx4_en.h
+++ b/drivers/net/mlx4/mlx4_en.h
@@ -104,6 +104,7 @@
 #define MLX4_EN_ALLOC_SIZE	(PAGE_SIZE << MLX4_EN_ALLOC_ORDER)
 
 #define MLX4_EN_MAX_LRO_DESCRIPTORS	32
+#define MLX4_EN_NUM_IPFRAG_SESSIONS	16
 
 /* Receive fragment sizes; we use at most 4 fragments (for 9600 byte MTU
  * and 4K allocations) */
@@ -258,6 +259,19 @@ struct mlx4_en_tx_ring {
 	spinlock_t comp_lock;
 };
 
+
+struct mlx4_en_ipfrag {
+	struct sk_buff *fragments;
+	__be32          saddr;
+	__be32          daddr;
+	__be16          id;
+	u8              protocol;
+	int             total_len;
+	u16             offset;
+	unsigned int	vlan;
+	__be16		sl_vid;
+};
+
 struct mlx4_en_rx_desc {
 	struct mlx4_wqe_srq_next_seg next;
 	/* actual number of entries depends on rx ring stride */
@@ -284,6 +298,7 @@ struct mlx4_en_rx_ring {
 	void *rx_info;
 	unsigned long bytes;
 	unsigned long packets;
+	struct mlx4_en_ipfrag ipfrag[MLX4_EN_NUM_IPFRAG_SESSIONS];
 };
 
 
@@ -335,6 +350,7 @@ struct mlx4_en_port_profile {
 struct mlx4_en_profile {
 	int rss_xor;
 	int num_lro;
+	int ip_reasm;
 	u8 rss_mask;
 	u32 active_ports;
 	u32 small_pkt_int;
@@ -489,7 +505,13 @@ struct mlx4_en_priv {
 	struct mlx4_en_stat_out_mbox hw_stats;
 };
 
-
+int mlx4_en_rx_frags(struct mlx4_en_priv *priv, struct mlx4_en_rx_ring *ring,
+		     struct mlx4_en_rx_desc *rx_desc,
+		     struct skb_frag_struct *skb_frags,
+		     unsigned int length,
+		     struct mlx4_cqe *cqe);
+void mlx4_en_flush_frags(struct mlx4_en_priv *priv,
+			 struct mlx4_en_rx_ring *ring);
 void mlx4_en_destroy_netdev(struct net_device *dev);
 int mlx4_en_init_netdev(struct mlx4_en_dev *mdev, int port,
 			struct mlx4_en_port_profile *prof);
@@ -542,6 +564,18 @@ int mlx4_en_map_buffer(struct mlx4_buf *buf);
 void mlx4_en_unmap_buffer(struct mlx4_buf *buf);
 
 void mlx4_en_calc_rx_buf(struct net_device *dev);
+int mlx4_en_complete_rx_desc(struct mlx4_en_priv *priv,
+			     struct mlx4_en_rx_desc *rx_desc,
+			     struct skb_frag_struct *skb_frags,
+			     struct skb_frag_struct *skb_frags_rx,
+			     struct mlx4_en_rx_alloc *page_alloc,
+			     int length);
+struct sk_buff *mlx4_en_rx_skb(struct mlx4_en_priv *priv,
+			       struct mlx4_en_rx_desc *rx_desc,
+			       struct skb_frag_struct *skb_frags,
+			       struct mlx4_en_rx_alloc *page_alloc,
+			       unsigned int length);
+
 void mlx4_en_set_default_rss_map(struct mlx4_en_priv *priv,
 				 struct mlx4_en_rss_map *rss_map,
 				 int num_entries, int num_rings);
-- 
1.5.4


--------------060905080200010303060405--
