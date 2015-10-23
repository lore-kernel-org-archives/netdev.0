From: Jakub Kicinski <jakub.kicinski@netronome.com>
Subject: [PATCH 2/2] net: add driver for Netronome NFP4000/NFP6000 NIC VFs
Date: Fri, 23 Oct 2015 19:58:11 +0100
Message-ID: <1445626691-19819-3-git-send-email-jakub.kicinski@netronome.com>
References: <1445626691-19819-1-git-send-email-jakub.kicinski@netronome.com>
Cc: netdev@vger.kernel.org, rolf.neugebauer@netronome.com,
	jason.mcmullan@netronome.com, simon.horman@netronome.com,
	Jakub Kicinski <jakub.kicinski@netronome.com>
To: David Miller <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-wi0-f170.google.com ([209.85.212.170]:38018 "EHLO
	mail-wi0-f170.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751616AbbJWS6W (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 23 Oct 2015 14:58:22 -0400
Received: by wicll6 with SMTP id ll6so43760531wic.1
        for <netdev@vger.kernel.org>; Fri, 23 Oct 2015 11:58:20 -0700 (PDT)
In-Reply-To: <1445626691-19819-1-git-send-email-jakub.kicinski@netronome.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Add driver for Virtual Functions for the Netronome's
NFP-4000 and NFP-6000 based NICs.

Signed-off-by: Jakub Kicinski <jakub.kicinski@netronome.com>
Acked-by: Jason S. McMullan <jason.mcmullan@netronome.com>
Signed-off-by: Rolf Neugebauer <rolf.neugebauer@netronome.com>
---
 MAINTAINERS                                        |    7 +
 drivers/net/ethernet/Kconfig                       |    1 +
 drivers/net/ethernet/Makefile                      |    1 +
 drivers/net/ethernet/netronome/Kconfig             |   33 +
 drivers/net/ethernet/netronome/Makefile            |    5 +
 drivers/net/ethernet/netronome/nfp/Makefile        |    8 +
 drivers/net/ethernet/netronome/nfp/nfp_net.h       |  744 ++++++
 .../net/ethernet/netronome/nfp/nfp_net_common.c    | 2525 ++++++++++++++++++++
 drivers/net/ethernet/netronome/nfp/nfp_net_ctrl.h  |  318 +++
 .../net/ethernet/netronome/nfp/nfp_net_debugfs.c   |  235 ++
 .../net/ethernet/netronome/nfp/nfp_net_ethtool.c   |  704 ++++++
 .../net/ethernet/netronome/nfp/nfp_netvf_main.c    |  404 ++++
 12 files changed, 4985 insertions(+)
 create mode 100644 drivers/net/ethernet/netronome/Kconfig
 create mode 100644 drivers/net/ethernet/netronome/Makefile
 create mode 100644 drivers/net/ethernet/netronome/nfp/Makefile
 create mode 100644 drivers/net/ethernet/netronome/nfp/nfp_net.h
 create mode 100644 drivers/net/ethernet/netronome/nfp/nfp_net_common.c
 create mode 100644 drivers/net/ethernet/netronome/nfp/nfp_net_ctrl.h
 create mode 100644 drivers/net/ethernet/netronome/nfp/nfp_net_debugfs.c
 create mode 100644 drivers/net/ethernet/netronome/nfp/nfp_net_ethtool.c
 create mode 100644 drivers/net/ethernet/netronome/nfp/nfp_netvf_main.c

diff --git a/MAINTAINERS b/MAINTAINERS
index fb8603e2a3f3..6e9c1a1eecc5 100644
--- a/MAINTAINERS
+++ b/MAINTAINERS
@@ -7232,6 +7232,13 @@ F:	include/net/netrom.h
 F:	include/uapi/linux/netrom.h
 F:	net/netrom/
 
+NETRONOME ETHERNET DRIVERS
+M:	Jakub Kicinski <jakub.kicinski@netronome.com>
+M:	Rolf Neugebauer <rolf.neugebauer@netronome.com>
+L:	oss-drivers@netronome.com
+S:	Maintained
+F:	drivers/net/ethernet/netronome/
+
 NETWORK BLOCK DEVICE (NBD)
 M:	Markus Pargmann <mpa@pengutronix.de>
 S:	Maintained
diff --git a/drivers/net/ethernet/Kconfig b/drivers/net/ethernet/Kconfig
index 05aa7597dab9..64e4056530ed 100644
--- a/drivers/net/ethernet/Kconfig
+++ b/drivers/net/ethernet/Kconfig
@@ -122,6 +122,7 @@ config FEALNX
 	  cards. <http://www.myson.com.tw/>
 
 source "drivers/net/ethernet/natsemi/Kconfig"
+source "drivers/net/ethernet/netronome/Kconfig"
 source "drivers/net/ethernet/8390/Kconfig"
 
 config NET_NETX
diff --git a/drivers/net/ethernet/Makefile b/drivers/net/ethernet/Makefile
index ddfc808110a1..0bc9e166d9ca 100644
--- a/drivers/net/ethernet/Makefile
+++ b/drivers/net/ethernet/Makefile
@@ -53,6 +53,7 @@ obj-$(CONFIG_NET_VENDOR_MOXART) += moxa/
 obj-$(CONFIG_NET_VENDOR_MYRI) += myricom/
 obj-$(CONFIG_FEALNX) += fealnx.o
 obj-$(CONFIG_NET_VENDOR_NATSEMI) += natsemi/
+obj-$(CONFIG_NET_VENDOR_NETRONOME) += netronome/
 obj-$(CONFIG_NET_NETX) += netx-eth.o
 obj-$(CONFIG_NET_VENDOR_NUVOTON) += nuvoton/
 obj-$(CONFIG_NET_VENDOR_NVIDIA) += nvidia/
diff --git a/drivers/net/ethernet/netronome/Kconfig b/drivers/net/ethernet/netronome/Kconfig
new file mode 100644
index 000000000000..9d2277a3d2f4
--- /dev/null
+++ b/drivers/net/ethernet/netronome/Kconfig
@@ -0,0 +1,33 @@
+#
+# Netronome device configuration
+#
+
+config NET_VENDOR_NETRONOME
+	bool "Netronome(R) devices"
+	default y
+	---help---
+	  If you have a Netronome(R) network (Ethernet) card or device, say Y.
+
+	  Note that the answer to this question doesn't directly affect the
+	  kernel: saying N will just cause the configurator to skip all
+	  the questions about Netronome(R) cards. If you say Y, you will be
+	  asked for your specific card in the following questions.
+
+if NET_VENDOR_NETRONOME
+
+config NFP_NETVF
+	tristate "Netronome(R) NFP4000/NFP6000 VF NIC driver"
+	depends on PCI && PCI_MSI
+	---help---
+	  This driver supports SR-IOV virtual functions of
+	  the Netronome(R) NFP4000/NFP6000 cards working as
+	  a advanced Ethernet NIC.
+
+config NFP_NET_DEBUG
+       bool "Debug support for Netronome(R) NFP4000/NFP6000 NIC drivers"
+       depends on NFP_NETVF
+       ---help---
+	  Enable debugfs support, debug messages and extra sanity checks
+	  in Netronome(R) NFP4000/NFP6000 NIC drivers.
+
+endif
diff --git a/drivers/net/ethernet/netronome/Makefile b/drivers/net/ethernet/netronome/Makefile
new file mode 100644
index 000000000000..dcb7b383f634
--- /dev/null
+++ b/drivers/net/ethernet/netronome/Makefile
@@ -0,0 +1,5 @@
+#
+# Makefile for the Netronome network device drivers
+#
+
+obj-$(CONFIG_NFP_NETVF) += nfp/
diff --git a/drivers/net/ethernet/netronome/nfp/Makefile b/drivers/net/ethernet/netronome/nfp/Makefile
new file mode 100644
index 000000000000..68178819ff12
--- /dev/null
+++ b/drivers/net/ethernet/netronome/nfp/Makefile
@@ -0,0 +1,8 @@
+obj-$(CONFIG_NFP_NETVF)	+= nfp_netvf.o
+
+nfp_netvf-objs := \
+	    nfp_net_common.o \
+	    nfp_net_ethtool.o \
+	    nfp_netvf_main.o
+
+nfp_netvf-$(CONFIG_NFP_NET_DEBUG) += nfp_net_debugfs.o
diff --git a/drivers/net/ethernet/netronome/nfp/nfp_net.h b/drivers/net/ethernet/netronome/nfp/nfp_net.h
new file mode 100644
index 000000000000..0be6bbe7d580
--- /dev/null
+++ b/drivers/net/ethernet/netronome/nfp/nfp_net.h
@@ -0,0 +1,744 @@
+/*
+ * Copyright (C) 2015 Netronome Systems, Inc.
+ *
+ * This software is dual licensed under the GNU General License Version 2,
+ * June 1991 as shown in the file COPYING in the top-level directory of this
+ * source tree or the BSD 2-Clause License provided below.  You have the
+ * option to license this software under the complete terms of either license.
+ *
+ * The BSD 2-Clause License:
+ *
+ *     Redistribution and use in source and binary forms, with or
+ *     without modification, are permitted provided that the following
+ *     conditions are met:
+ *
+ *      1. Redistributions of source code must retain the above
+ *         copyright notice, this list of conditions and the following
+ *         disclaimer.
+ *
+ *      2. Redistributions in binary form must reproduce the above
+ *         copyright notice, this list of conditions and the following
+ *         disclaimer in the documentation and/or other materials
+ *         provided with the distribution.
+ *
+ * THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND,
+ * EXPRESS OR IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF
+ * MERCHANTABILITY, FITNESS FOR A PARTICULAR PURPOSE AND
+ * NONINFRINGEMENT. IN NO EVENT SHALL THE AUTHORS OR COPYRIGHT HOLDERS
+ * BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER LIABILITY, WHETHER IN AN
+ * ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM, OUT OF OR IN
+ * CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN THE
+ * SOFTWARE.
+ */
+
+/*
+ * nfp_net.h
+ * Declarations for Netronome network device driver.
+ * Authors: Jakub Kicinski <jakub.kicinski@netronome.com>
+ *          Jason McMullan <jason.mcmullan@netronome.com>
+ *          Rolf Neugebauer <rolf.neugebauer@netronome.com>
+ */
+
+#ifndef _NFP_NET_H_
+#define _NFP_NET_H_
+
+#include <linux/netdevice.h>
+#include <linux/pci.h>
+#include <asm-generic/io-64-nonatomic-hi-lo.h>
+
+#include "nfp_net_ctrl.h"
+
+#ifdef CONFIG_NFP_NET_DEBUG
+#define DEBUG
+#endif
+
+#define nn_err(nn, fmt, args...)  netdev_err((nn)->netdev, fmt, ## args)
+#define nn_warn(nn, fmt, args...) netdev_warn((nn)->netdev, fmt, ## args)
+#define nn_info(nn, fmt, args...) netdev_info((nn)->netdev, fmt, ## args)
+#define nn_warn_ratelimit(nn, fmt, args...)				\
+	do {								\
+		if (unlikely(net_ratelimit()))				\
+			netdev_warn((nn)->netdev, fmt, ## args);	\
+	} while (0)
+
+#ifdef CONFIG_NFP_NET_DEBUG
+#define nn_dbg(nn, fmt, args...)  netdev_info((nn)->netdev, fmt, ## args)
+#define nn_assert(cond, fmt, args...)					\
+	do {								\
+		if (unlikely(!(cond))) {				\
+			pr_err("assertion %s failed: %s:%d\n",		\
+			       #cond, __func__, __LINE__);		\
+			pr_err(fmt, ## args);				\
+			BUG();						\
+		}							\
+	} while (0)
+#else
+#define nn_dbg(nn, fmt, args...)	do { } while (0)
+#define nn_assert(cond, fmt, args...)	do { } while (0)
+#endif
+
+/* NAPI weight */
+#define NFP_NET_NAPI_WEIGHT    64
+
+/* Max time to wait for NFP to respond on updates (in ms) */
+#define NFP_NET_POLL_TIMEOUT	5000
+
+/* Bar allocation */
+#define NFP_NET_CRTL_BAR	0
+#define NFP_NET_Q0_BAR		2
+#define NFP_NET_Q1_BAR		4	/* OBSOLETE */
+
+/* Max bits in DMA address */
+#define NFP_NET_MAX_DMA_BITS	40
+
+/* Default size for MTU and freelist buffer sizes */
+#define NFP_NET_DEFAULT_MTU		1500
+#define NFP_NET_DEFAULT_RX_BUFSZ	2048
+
+/* Maximum number of bytes prepended to a packet */
+#define NFP_NET_MAX_PREPEND		64
+
+/* Interrupt definitions */
+#define NFP_NET_NON_Q_VECTORS		2
+#define NFP_NET_IRQ_LSC_IDX		0
+#define NFP_NET_IRQ_EXN_IDX		1
+
+/* Queue/Ring definitions */
+#define NFP_NET_MAX_TX_RINGS	64	/* Max. # of Tx rings per device */
+#define NFP_NET_MAX_RX_RINGS	64	/* Max. # of Rx rings per device */
+
+#define NFP_NET_MIN_TX_DESCS	256	/* Min. # of Tx descs per ring */
+#define NFP_NET_MIN_RX_DESCS	256	/* Min. # of Rx descs per ring */
+#define NFP_NET_MAX_TX_DESCS	(256 * 1024) /* Max. # of Tx descs per ring */
+#define NFP_NET_MAX_RX_DESCS	(256 * 1024) /* Max. # of Rx descs per ring */
+
+#define NFP_NET_TX_DESCS_DEFAULT 4096	/* Default # of Tx descs per ring */
+#define NFP_NET_RX_DESCS_DEFAULT 4096	/* Default # of Rx descs per ring */
+
+#define NFP_NET_FL_BATCH	16	/* Add freelist in this Batch size */
+
+/* Offload definitions */
+#define NFP_NET_N_VXLAN_PORTS	(NFP_NET_CFG_VXLAN_SZ / sizeof(__be16))
+
+/* Forward declarations */
+struct nfp_net;
+struct nfp_net_r_vector;
+
+/* Convenience macro for writing dma address into RX/TX descriptors */
+#define nfp_desc_set_dma_addr(desc, dma_addr)				\
+	do {								\
+		__typeof(desc) __d = (desc);				\
+		dma_addr_t __addr = (dma_addr);				\
+									\
+		__d->dma_addr_lo = cpu_to_le32(lower_32_bits(__addr));	\
+		__d->dma_addr_hi = upper_32_bits(__addr) & 0xff;	\
+	} while (0)
+
+/* TX descriptor format */
+
+#define PCIE_DESC_TX_EOP		BIT(7)
+#define PCIE_DESC_TX_OFFSET_MASK	GENMASK(6, 0)
+
+/* Flags in the host TX descriptor */
+#define PCIE_DESC_TX_CSUM		BIT(7)
+#define PCIE_DESC_TX_IP4_CSUM		BIT(6)
+#define PCIE_DESC_TX_TCP_CSUM		BIT(5)
+#define PCIE_DESC_TX_UDP_CSUM		BIT(4)
+#define PCIE_DESC_TX_VLAN		BIT(3)
+#define PCIE_DESC_TX_LSO		BIT(2)
+#define PCIE_DESC_TX_ENCAP_VXLAN	BIT(1)
+#define PCIE_DESC_TX_ENCAP_NVGRE	BIT(0)
+#define PCIE_DESC_TX_ENCAP_NONE		0
+
+struct nfp_net_tx_desc {
+	union {
+		struct {
+			u8 dma_addr_hi; /* High bits of host buf address */
+			__le16 dma_len;	/* Length to DMA for this desc */
+			u8 offset_eop;	/* Offset in buf where pkt starts +
+					 * highest bit is eop flag.
+					 */
+			__le32 dma_addr_lo; /* Low 32bit of host buf addr */
+
+			__le16 lso;	/* MSS to be used for LSO */
+			u8 l4_offset;	/* LSO, where the L4 data starts */
+			u8 flags;	/* TX Flags, see @PCIE_DESC_TX_* */
+
+			__le16 vlan;	/* VLAN tag to add if indicated */
+			__le16 data_len; /* Length of frame + meta data */
+		} __packed;
+		__le32 vals[4];
+	};
+};
+
+/**
+ * struct nfp_net_tx_buf - software TX buffer descriptor
+ * @skb:	sk_buff associated with this buffer
+ * @dma_addr:	DMA mapping address of the buffer
+ * @fidx:	Fragment index (-1 for the head and [0..nr_frags-1] for frags)
+ * @pkt_cnt:	Number of packets to be produced out of the skb associated
+ *		with this buffer (valid only on the head's buffer).
+ *		Will be 1 for all non-TSO packets.
+ * @real_len:	Number of bytes which to be produced out of the skb (valid only
+ *		on the head's buffer). Equal to skb->len for non-TSO packets.
+ */
+struct nfp_net_tx_buf {
+	struct sk_buff *skb;
+	dma_addr_t dma_addr;
+	short int fidx;
+	u16 pkt_cnt;
+	u32 real_len;
+};
+
+/**
+ * struct nfp_net_tx_ring - TX ring structure
+ * @r_vec:      Back pointer to ring vector structure
+ * @idx:        Ring index from Linux's perspective
+ * @qcidx:      Queue Controller Peripheral (QCP) queue index for the TX queue
+ * @qcp_q:      Pointer to base of the QCP TX queue
+ * @cnt:        Size of the queue in number of descriptors
+ * @wr_p:       TX ring write pointer (free running)
+ * @rd_p:       TX ring read pointer (free running)
+ * @qcp_rd_p:   Local copy of QCP TX queue read pointer
+ * @wr_ptr_add:	Accumulated number of buffers to add to QCP write pointer
+ *		(used for .xmit_more delayed kick)
+ * @txbufs:     Array of transmitted TX buffers, to free on transmit
+ * @txds:       Virtual address of TX ring in host memory
+ * @dma:        DMA address of the TX ring
+ * @size:       Size, in bytes, of the TX ring (needed to free)
+ */
+struct nfp_net_tx_ring {
+	struct nfp_net_r_vector *r_vec;
+
+	int idx;
+	int qcidx;
+	u8 __iomem *qcp_q;
+
+	int cnt;
+	u32 wr_p;
+	u32 rd_p;
+	u32 qcp_rd_p;
+
+	u32 wr_ptr_add;
+
+	struct nfp_net_tx_buf *txbufs;
+	struct nfp_net_tx_desc *txds;
+
+	dma_addr_t dma;
+	unsigned int size;
+} ____cacheline_aligned;
+
+/* RX and freelist descriptor format */
+
+#define PCIE_DESC_RX_DD			BIT(7)
+#define PCIE_DESC_RX_META_LEN_MASK	GENMASK(6, 0)
+
+/* Flags in the RX descriptor */
+#define PCIE_DESC_RX_RSS		cpu_to_le16(BIT(15))
+#define PCIE_DESC_RX_I_IP4_CSUM		cpu_to_le16(BIT(14))
+#define PCIE_DESC_RX_I_IP4_CSUM_OK	cpu_to_le16(BIT(13))
+#define PCIE_DESC_RX_I_TCP_CSUM		cpu_to_le16(BIT(12))
+#define PCIE_DESC_RX_I_TCP_CSUM_OK	cpu_to_le16(BIT(11))
+#define PCIE_DESC_RX_I_UDP_CSUM		cpu_to_le16(BIT(10))
+#define PCIE_DESC_RX_I_UDP_CSUM_OK	cpu_to_le16(BIT(9))
+#define PCIE_DESC_RX_SPARE		cpu_to_le16(BIT(8))
+#define PCIE_DESC_RX_EOP		cpu_to_le16(BIT(7))
+#define PCIE_DESC_RX_IP4_CSUM		cpu_to_le16(BIT(6))
+#define PCIE_DESC_RX_IP4_CSUM_OK	cpu_to_le16(BIT(5))
+#define PCIE_DESC_RX_TCP_CSUM		cpu_to_le16(BIT(4))
+#define PCIE_DESC_RX_TCP_CSUM_OK	cpu_to_le16(BIT(3))
+#define PCIE_DESC_RX_UDP_CSUM		cpu_to_le16(BIT(2))
+#define PCIE_DESC_RX_UDP_CSUM_OK	cpu_to_le16(BIT(1))
+#define PCIE_DESC_RX_VLAN		cpu_to_le16(BIT(0))
+
+#define PCIE_DESC_RX_CSUM_ALL		(PCIE_DESC_RX_IP4_CSUM |	\
+					 PCIE_DESC_RX_TCP_CSUM |	\
+					 PCIE_DESC_RX_UDP_CSUM |	\
+					 PCIE_DESC_RX_I_IP4_CSUM |	\
+					 PCIE_DESC_RX_I_TCP_CSUM |	\
+					 PCIE_DESC_RX_I_UDP_CSUM)
+#define PCIE_DESC_RX_CSUM_OK_SHIFT	1
+#define __PCIE_DESC_RX_CSUM_ALL		le16_to_cpu(PCIE_DESC_RX_CSUM_ALL)
+#define __PCIE_DESC_RX_CSUM_ALL_OK	(__PCIE_DESC_RX_CSUM_ALL >>	\
+					 PCIE_DESC_RX_CSUM_OK_SHIFT)
+
+struct nfp_net_rx_desc {
+	union {
+		struct {
+			u8 dma_addr_hi;	/* High bits of the buf address */
+			__le16 padding;
+			u8 meta_len_dd; /* Must be zero */
+
+			__le32 dma_addr_lo; /* Low bits of the buffer address */
+		} __packed fld;
+
+		struct {
+			__le16 data_len; /* Length of the frame + meta data */
+			u8 reserved;
+			u8 meta_len_dd;	/* Length of meta data prepended +
+					 * descriptor done flag.
+					 */
+
+			__le16 flags;	/* RX flags. See @PCIE_DESC_RX_* */
+			__le16 vlan;	/* VLAN if stripped */
+		} __packed rxd;
+
+		__le32 vals[2];
+	};
+};
+
+struct nfp_net_rx_hash {
+	__be32 hash_type;
+	__be32 hash;
+};
+
+/**
+ * struct nfp_net_rx_ring - RX ring structure
+ * @r_vec:      Back pointer to ring vector structure
+ * @cnt:        Size of the queue in number of descriptors
+ * @wr_p:       FL/RX ring write pointer (free running)
+ * @rd_p:       FL/RX ring read pointer (free running)
+ * @idx:        Ring index from Linux's perspective
+ * @fl_qcidx:   Queue Controller Peripheral (QCP) queue index for the freelist
+ * @rx_qcidx:   Queue Controller Peripheral (QCP) queue index for the RX queue
+ * @qcp_fl:     Pointer to base of the QCP freelist queue
+ * @qcp_rx:     Pointer to base of the QCP RX queue
+ * @rxbufs:     Array of transmitted FL/RX buffers
+ * @rxds:       Virtual address of FL/RX ring in host memory
+ * @dma:        DMA address of the FL/RX ring
+ * @size:       Size, in bytes, of the FL/RX ring (needed to free)
+ */
+struct nfp_net_rx_ring {
+	struct nfp_net_r_vector *r_vec;
+
+	int cnt;
+	u32 wr_p;
+	u32 rd_p;
+
+	int idx;
+	int fl_qcidx;
+	int rx_qcidx;
+	u8 __iomem *qcp_fl;
+	u8 __iomem *qcp_rx;
+
+	struct {
+		struct sk_buff *skb;
+		dma_addr_t dma_addr;
+	} *rxbufs;
+
+	struct nfp_net_rx_desc *rxds;
+	dma_addr_t dma;
+	unsigned int size;
+} ____cacheline_aligned;
+
+/**
+ * struct nfp_net_r_vector - Per ring interrupt vector configuration
+ * @nfp_net:        Backpointer to nfp_net structure
+ * @napi:           NAPI structure for this ring vec
+ * @flags:          Flags
+ * @idx:            Index of this ring vector
+ * @tx_ring:        Pointer to TX ring
+ * @rx_ring:        Pointer to RX ring
+ * @handler:        Interrupt handler for this ring vector
+ * @irq_idx:        Index into MSI-X table
+ * @requested:      Has this vector been requested?
+ * @name:           Name of the interrupt vector
+ * @affinity_mask:  SMP affinity mask for this vector
+ * @rx_sync:	    Seqlock for atomic updates of RX stats
+ * @rx_pkts:        Number of received packets
+ * @rx_bytes:	    Number of received bytes
+ * @hw_csum_rx_ok:  Counter of packets where the HW checksum was OK
+ * @hw_csum_rx_inner_ok: Counter of packets where the inner HW checksum was OK
+ * @hw_csum_rx_error:	 Counter of packets with bad checksums
+ * @tx_sync:	    Seqlock for atomic updates of TX stats
+ * @tx_pkts:	    Number of Transmitted packets
+ * @tx_bytes:	    Number of Transmitted bytes
+ * @hw_csum_tx:	    Counter of packets with TX checksum offload requested
+ * @hw_csum_tx_inner:	 Counter of inner TX checksum offload requests
+ * @tx_gather:	    Counter of packets with Gather DMA
+ * @tx_lso:	    Counter of LSO packets sent
+ * @tx_errors:	    How many TX errors were encountered
+ * @tx_busy:        How often was TX busy (no space)?
+ *
+ * This structure ties RX and TX rings to interrupt vectors and a NAPI
+ * context. This currently only supports one RX and TX ring per
+ * interrupt vector but might be extended in the future to allow
+ * association of multiple rings per vector.
+ */
+struct nfp_net_r_vector {
+	struct nfp_net *nfp_net;
+	struct napi_struct napi;
+	unsigned long flags;
+#define NFP_NET_RVEC_NAPI_STARTED	BIT(0)
+
+	int idx;
+	struct nfp_net_tx_ring *tx_ring;
+	struct nfp_net_rx_ring *rx_ring;
+
+	irq_handler_t handler;
+	int irq_idx;
+	int requested;
+	char name[IFNAMSIZ + 8];
+
+	cpumask_t affinity_mask;
+
+	struct u64_stats_sync rx_sync;
+	u64 rx_pkts;
+	u64 rx_bytes;
+	u64 hw_csum_rx_ok;
+	u64 hw_csum_rx_inner_ok;
+	u64 hw_csum_rx_error;
+
+	struct u64_stats_sync tx_sync;
+	u64 tx_pkts;
+	u64 tx_bytes;
+	u64 hw_csum_tx;
+	u64 hw_csum_tx_inner;
+	u64 tx_gather;
+	u64 tx_lso;
+	u64 tx_errors;
+	u64 tx_busy;
+};
+
+/**
+ * struct nfp_net - NFP network device structure
+ * @pdev:               Backpointer to PCI device
+ * @netdev:             Backpointer to net_device structure
+ * @nfp_fallback:       Is the driver used in fallback mode?
+ * @is_vf:              Is the driver attached to a VF?
+ * @is_nfp3200:         Is the driver for a NFP-3200 card?
+ * @removing_pdev:      Are we in the process of removing the device driver
+ * @link_up:            Is the link up?
+ * @fw_loaded:          Is the firmware loaded?
+ * @ctrl:               Local copy of the control register/word.
+ * @fl_bufsz:           Currently configured size of the freelist buffers
+ * @rx_offset:		Offset in the RX buffers where packet data starts
+ * @cpp:                Pointer to the CPP handle
+ * @nfp_dev_cpp:        Pointer to the NFP Device handle
+ * @ctrl_area:          Pointer to the CPP area for the control BAR
+ * @tx_area:            Pointer to the CPP area for the TX queues
+ * @rx_area:            Pointer to the CPP area for the FL/RX queues
+ * @ver:                Firmware version
+ * @cap:                Capabilities advertised by the Firmware
+ * @max_mtu:            Maximum support MTU advertised by the Firmware
+ * @rss_cfg:            RSS configuration
+ * @rss_key:            RSS secret key
+ * @rss_itbl:           RSS indirection table
+ * @max_tx_rings:       Maximum number of TX rings supported by the Firmware
+ * @max_rx_rings:       Maximum number of RX rings supported by the Firmware
+ * @num_tx_rings:       Currently configured number of TX rings
+ * @num_rx_rings:       Currently configured number of RX rings
+ * @txd_cnt:            Size of the TX ring in number of descriptors
+ * @rxd_cnt:            Size of the RX ring in number of descriptors
+ * @tx_rings:           Array of pre-allocated TX ring structures
+ * @rx_rings:           Array of pre-allocated RX ring structures
+ * @per_vector_masking: Are we using per vector masking?
+ * @msix_table:         Pointer to mapped MSI-X table
+ * @num_irqs:	        Number of allocated interrupt vectors
+ * @num_r_vecs:         Number of used ring vectors
+ * @r_vecs:             Pre-allocated array of ring vectors
+ * @irq_entries:        Pre-allocated array of MSI-X entries
+ * @lsc_handler:        Handler for Link State Change interrupt
+ * @lsc_name:           Name for Link State Change interrupt
+ * @exn_handler:        Handler for Exception interrupt
+ * @exn_name:           Name for Exception interrupt
+ * @shared_handler:     Handler for shared interrupts
+ * @shared_name:        Name for shared interrupt
+ * @me_freq_mhz:        ME clock_freq (MHz)
+ * @reconfig_lock:	Protects HW reconfiguration request regs/machinery
+ * @rx_coalesce_usecs      RX interrupt moderation usecs delay parameter
+ * @rx_coalesce_max_frames RX interrupt moderation frame count parameter
+ * @tx_coalesce_usecs      TX interrupt moderation usecs delay parameter
+ * @tx_coalesce_max_frames TX interrupt moderation frame count parameter
+ * @vxlan_ports:	VXLAN ports for RX inner csum offload communicated to HW
+ * @qcp_cfg:            Pointer to QCP queue used for configuration notification
+ * @ctrl_bar:           Pointer to mapped control BAR
+ * @tx_bar:             Pointer to mapped TX queues
+ * @rx_bar:             Pointer to mapped FL/RX queues
+ * @debugfs_dir:	Device directory in debugfs
+ */
+struct nfp_net {
+	struct pci_dev *pdev;
+	struct net_device *netdev;
+
+	unsigned nfp_fallback:1;
+	unsigned is_vf:1;
+	unsigned is_nfp3200:1;
+	unsigned removing_pdev:1;
+	unsigned link_up:1;
+	unsigned fw_loaded:1;
+
+	u32 ctrl;
+	u32 fl_bufsz;
+
+	u32 rx_offset;
+
+#ifdef CONFIG_PCI_IOV
+	unsigned int num_vfs;
+	struct vf_data_storage *vfinfo;
+	int vf_rate_link_speed;
+#endif
+
+	struct nfp_cpp *cpp;
+	struct platform_device *nfp_dev_cpp;
+	struct nfp_cpp_area *ctrl_area;
+	struct nfp_cpp_area *tx_area;
+	struct nfp_cpp_area *rx_area;
+
+	u32 ver;
+	u32 cap;
+	u32 max_mtu;
+
+	u32 rss_cfg;
+	u32 rss_key[NFP_NET_CFG_RSS_KEY_SZ / sizeof(u32)];
+	u8 rss_itbl[NFP_NET_CFG_RSS_ITBL_SZ];
+
+	int max_tx_rings;
+	int max_rx_rings;
+
+	int num_tx_rings;
+	int num_rx_rings;
+
+	int stride_tx;
+	int stride_rx;
+
+	int txd_cnt;
+	int rxd_cnt;
+
+	struct nfp_net_tx_ring tx_rings[NFP_NET_MAX_TX_RINGS];
+	struct nfp_net_rx_ring rx_rings[NFP_NET_MAX_RX_RINGS];
+
+	unsigned per_vector_masking:1;
+	u8 __iomem *msix_table;
+	u8 num_irqs;
+	u8 num_r_vecs;
+	struct nfp_net_r_vector r_vecs[NFP_NET_MAX_TX_RINGS];
+	struct msix_entry irq_entries[NFP_NET_NON_Q_VECTORS +
+				      NFP_NET_MAX_TX_RINGS];
+
+	irq_handler_t lsc_handler;
+	char lsc_name[IFNAMSIZ + 8];
+
+	irq_handler_t exn_handler;
+	char exn_name[IFNAMSIZ + 8];
+
+	irq_handler_t shared_handler;
+	char shared_name[IFNAMSIZ + 8];
+
+	u32 me_freq_mhz;
+
+	spinlock_t reconfig_lock;
+
+	u32 rx_coalesce_usecs;
+	u32 rx_coalesce_max_frames;
+	u32 tx_coalesce_usecs;
+	u32 tx_coalesce_max_frames;
+
+	__be16 vxlan_ports[NFP_NET_N_VXLAN_PORTS];
+
+	u8 __iomem *qcp_cfg;
+
+	u8 __iomem *ctrl_bar;
+	u8 __iomem *q_bar;
+	u8 __iomem *tx_bar;
+	u8 __iomem *rx_bar;
+
+	struct dentry *debugfs_dir;
+};
+
+/* Functions to read/write from/to a BAR
+ * Performs any endian conversion necessary.
+ */
+static inline void nn_writeb(struct nfp_net *nn, int off, u8 val)
+{
+	writeb(val, nn->ctrl_bar + off);
+}
+
+/* NFP-3200 can't handle 16-bit accesses too well - hence no readw/writew */
+
+static inline u32 nn_readl(struct nfp_net *nn, int off)
+{
+	return readl(nn->ctrl_bar + off);
+}
+
+static inline void nn_writel(struct nfp_net *nn, int off, u32 val)
+{
+	writel(val, nn->ctrl_bar + off);
+}
+
+static inline u64 nn_readq(struct nfp_net *nn, int off)
+{
+	return readq(nn->ctrl_bar + off);
+}
+
+static inline void nn_writeq(struct nfp_net *nn, int off, u64 val)
+{
+	writeq(val, nn->ctrl_bar + off);
+}
+
+/* Flush posted PCI writes by reading something without side effects */
+static inline void nn_pci_flush(struct nfp_net *nn)
+{
+	nn_readl(nn, NFP_NET_CFG_VERSION);
+}
+
+/* Queue Controller Peripheral access functions and definitions.
+ *
+ * Some of the BARs of the NFP are mapped to portions of the Queue
+ * Controller Peripheral (QCP) address space on the NFP.  A QCP queue
+ * has a read and a write pointer (as well as a size and flags,
+ * indicating overflow etc).  The QCP offers a number of different
+ * operation on queue pointers, but here we only offer function to
+ * either add to a pointer or to read the pointer value.
+ */
+#define NFP_QCP_QUEUE_ADDR_SZ			0x800
+#define NFP_QCP_QUEUE_OFF(_x)			((_x) * NFP_QCP_QUEUE_ADDR_SZ)
+#define NFP_QCP_QUEUE_ADD_RPTR			0x0000
+#define NFP_QCP_QUEUE_ADD_WPTR			0x0004
+#define NFP_QCP_QUEUE_STS_LO			0x0008
+#define NFP_QCP_QUEUE_STS_LO_READPTR_mask	0x3ffff
+#define NFP_QCP_QUEUE_STS_HI			0x000c
+#define NFP_QCP_QUEUE_STS_HI_WRITEPTR_mask	0x3ffff
+
+/* The offset of a QCP queues in the PCIe Target (same on NFP3200 and NFP6000 */
+#define NFP_PCIE_QUEUE(_q) (0x80000 + (NFP_QCP_QUEUE_ADDR_SZ * ((_q) & 0xff)))
+
+/* nfp_qcp_ptr - Read or Write Pointer of a queue */
+enum nfp_qcp_ptr {
+	NFP_QCP_READ_PTR = 0,
+	NFP_QCP_WRITE_PTR
+};
+
+/* There appear to be an *undocumented* upper limit on the value which
+ * one can add to a queue and that value is either 0x3f or 0x7f.  We
+ * go with 0x3f as a conservative measure.
+ */
+#define NFP_QCP_MAX_ADD				0x3f
+
+static inline void _nfp_qcp_ptr_add(u8 __iomem *q,
+				    enum nfp_qcp_ptr ptr, u32 val)
+{
+	u32 off;
+
+	if (ptr == NFP_QCP_READ_PTR)
+		off = NFP_QCP_QUEUE_ADD_RPTR;
+	else
+		off = NFP_QCP_QUEUE_ADD_WPTR;
+
+	while (val > NFP_QCP_MAX_ADD) {
+		writel(NFP_QCP_MAX_ADD, q + off);
+		val -= NFP_QCP_MAX_ADD;
+	}
+
+	writel(val, q + off);
+}
+
+/**
+ * nfp_qcp_rd_ptr_add() - Add the value to the read pointer of a queue
+ *
+ * @q:   Base address for queue structure
+ * @val: Value to add to the queue pointer
+ *
+ * If @val is greater than @NFP_QCP_MAX_ADD multiple writes are performed.
+ */
+static inline void nfp_qcp_rd_ptr_add(u8 __iomem *q, u32 val)
+{
+	_nfp_qcp_ptr_add(q, NFP_QCP_READ_PTR, val);
+}
+
+/**
+ * nfp_qcp_wr_ptr_add() - Add the value to the write pointer of a queue
+ *
+ * @q:   Base address for queue structure
+ * @val: Value to add to the queue pointer
+ *
+ * If @val is greater than @NFP_QCP_MAX_ADD multiple writes are performed.
+ */
+static inline void nfp_qcp_wr_ptr_add(u8 __iomem *q, u32 val)
+{
+	_nfp_qcp_ptr_add(q, NFP_QCP_WRITE_PTR, val);
+}
+
+static inline u32 _nfp_qcp_read(u8 __iomem *q, enum nfp_qcp_ptr ptr)
+{
+	u32 off;
+	u32 val;
+
+	if (ptr == NFP_QCP_READ_PTR)
+		off = NFP_QCP_QUEUE_STS_LO;
+	else
+		off = NFP_QCP_QUEUE_STS_HI;
+
+	val = readl(q + off);
+
+	if (ptr == NFP_QCP_READ_PTR)
+		return val & NFP_QCP_QUEUE_STS_LO_READPTR_mask;
+	else
+		return val & NFP_QCP_QUEUE_STS_HI_WRITEPTR_mask;
+}
+
+/**
+ * nfp_qcp_rd_ptr_read() - Read the current read pointer value for a queue
+ * @q:  Base address for queue structure
+ *
+ * Return: Value read.
+ */
+static inline u32 nfp_qcp_rd_ptr_read(u8 __iomem *q)
+{
+	return _nfp_qcp_read(q, NFP_QCP_READ_PTR);
+}
+
+/**
+ * nfp_qcp_wr_ptr_read() - Read the current write pointer value for a queue
+ * @q:  Base address for queue structure
+ *
+ * Return: Value read.
+ */
+static inline u32 nfp_qcp_wr_ptr_read(u8 __iomem *q)
+{
+	return _nfp_qcp_read(q, NFP_QCP_WRITE_PTR);
+}
+
+/* Globals */
+extern const char nfp_net_driver_name[];
+extern const char nfp_net_driver_version[];
+
+/* Prototypes */
+struct nfp_net *nfp_net_netdev_alloc(struct pci_dev *pdev,
+				     int max_tx_rings, int max_rx_rings);
+void nfp_net_netdev_free(struct nfp_net *nn);
+int nfp_net_netdev_init(struct net_device *netdev);
+void nfp_net_netdev_clean(struct net_device *netdev);
+void nfp_net_set_ethtool_ops(struct net_device *netdev);
+void nfp_net_info(struct nfp_net *nn);
+int nfp_net_reconfig(struct nfp_net *nn, u32 update);
+void nfp_net_rss_write_itbl(struct nfp_net *nn);
+void nfp_net_coalesce_write_cfg(struct nfp_net *nn);
+int nfp_net_irqs_alloc(struct nfp_net *nn);
+void nfp_net_irqs_disable(struct nfp_net *nn);
+void __iomem *nfp_net_msix_map(struct pci_dev *pdev, unsigned nr_entries);
+
+#ifdef CONFIG_NFP_NET_DEBUG
+void nfp_net_debugfs_create(void);
+void nfp_net_debugfs_destroy(void);
+void nfp_net_debugfs_adapter_add(struct nfp_net *nn);
+void nfp_net_debugfs_adapter_del(struct nfp_net *nn);
+#else
+static inline void nfp_net_debugfs_create(void)
+{
+}
+
+static inline void nfp_net_debugfs_destroy(void)
+{
+}
+
+static inline void nfp_net_debugfs_adapter_add(struct nfp_net *nn)
+{
+}
+
+static inline void nfp_net_debugfs_adapter_del(struct nfp_net *nn)
+{
+}
+#endif /* CONFIG_NFP_NET_DEBUG */
+
+#endif /* _NFP_NET_H_ */
diff --git a/drivers/net/ethernet/netronome/nfp/nfp_net_common.c b/drivers/net/ethernet/netronome/nfp/nfp_net_common.c
new file mode 100644
index 000000000000..b02728a1f13e
--- /dev/null
+++ b/drivers/net/ethernet/netronome/nfp/nfp_net_common.c
@@ -0,0 +1,2525 @@
+/*
+ * Copyright (C) 2015 Netronome Systems, Inc.
+ *
+ * This software is dual licensed under the GNU General License Version 2,
+ * June 1991 as shown in the file COPYING in the top-level directory of this
+ * source tree or the BSD 2-Clause License provided below.  You have the
+ * option to license this software under the complete terms of either license.
+ *
+ * The BSD 2-Clause License:
+ *
+ *     Redistribution and use in source and binary forms, with or
+ *     without modification, are permitted provided that the following
+ *     conditions are met:
+ *
+ *      1. Redistributions of source code must retain the above
+ *         copyright notice, this list of conditions and the following
+ *         disclaimer.
+ *
+ *      2. Redistributions in binary form must reproduce the above
+ *         copyright notice, this list of conditions and the following
+ *         disclaimer in the documentation and/or other materials
+ *         provided with the distribution.
+ *
+ * THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND,
+ * EXPRESS OR IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF
+ * MERCHANTABILITY, FITNESS FOR A PARTICULAR PURPOSE AND
+ * NONINFRINGEMENT. IN NO EVENT SHALL THE AUTHORS OR COPYRIGHT HOLDERS
+ * BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER LIABILITY, WHETHER IN AN
+ * ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM, OUT OF OR IN
+ * CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN THE
+ * SOFTWARE.
+ */
+
+/*
+ * nfp_net_common.c
+ * Netronome network device driver: Common functions between PF and VF
+ * Authors: Jakub Kicinski <jakub.kicinski@netronome.com>
+ *          Jason McMullan <jason.mcmullan@netronome.com>
+ *          Rolf Neugebauer <rolf.neugebauer@netronome.com>
+ *          Brad Petrus <brad.petrus@netronome.com>
+ *          Chris Telfer <chris.telfer@netronome.com>
+ */
+
+#include <linux/version.h>
+#include <linux/module.h>
+#include <linux/kernel.h>
+#include <linux/init.h>
+#include <linux/fs.h>
+#include <linux/netdevice.h>
+#include <linux/etherdevice.h>
+#include <linux/interrupt.h>
+#include <linux/ip.h>
+#include <linux/ipv6.h>
+#include <linux/pci.h>
+#include <linux/pci_regs.h>
+#include <linux/msi.h>
+#include <linux/ethtool.h>
+#include <linux/log2.h>
+#include <linux/if_vlan.h>
+#include <linux/random.h>
+
+#include <linux/ktime.h>
+
+#include <net/vxlan.h>
+
+#include "nfp_net_ctrl.h"
+#include "nfp_net.h"
+
+/**
+ * nfp_net_reconfig() - Reconfigure the firmware
+ * @nn:      NFP Net device to reconfigure
+ * @update:  The value for the update field in the BAR config
+ *
+ * Write the update word to the BAR and ping the reconfig queue.  The
+ * poll until the firmware has acknowledged the update by zeroing the
+ * update word.
+ *
+ * Return: Negative errno on error, 0 on success
+ */
+int nfp_net_reconfig(struct nfp_net *nn, u32 update)
+{
+	int cnt, ret = 0;
+	u32 new;
+
+	spin_lock_bh(&nn->reconfig_lock);
+
+	nn_writel(nn, NFP_NET_CFG_UPDATE, update);
+	/* ensure update is written before pinging HW */
+	nn_pci_flush(nn);
+	nfp_qcp_wr_ptr_add(nn->qcp_cfg, 1);
+
+	/* Poll update field, waiting for NFP to ack the config */
+	for (cnt = 0; ; cnt++) {
+		new = nn_readl(nn, NFP_NET_CFG_UPDATE);
+		if (new == 0)
+			break;
+		if (new & NFP_NET_CFG_UPDATE_ERR) {
+			nn_err(nn, "Reconfig error: 0x%08x\n", new);
+			ret = -EIO;
+			break;
+		} else if (cnt >= NFP_NET_POLL_TIMEOUT) {
+			nn_err(nn, "Reconfig timeout for 0x%08x after %dms\n",
+			       update, cnt);
+			ret = -EIO;
+			break;
+		}
+		mdelay(1);
+	}
+
+	spin_unlock_bh(&nn->reconfig_lock);
+	return ret;
+}
+
+/**
+ * nfp_net_msix_map() - Map the MSI-X table
+ * @pdev:       PCI Device structure
+ * @nr_entries: Number of entries in table to map
+ *
+ * If successful, the table must be un-mapped using iounmap().
+ *
+ * Return: Pointer to mapped table or NULL
+ */
+void __iomem *nfp_net_msix_map(struct pci_dev *pdev, unsigned nr_entries)
+{
+	resource_size_t phys_addr;
+	u32 table_offset;
+	u8 msix_cap;
+	u8 bir;
+
+	msix_cap = pdev->msix_cap;
+
+	pci_read_config_dword(pdev, msix_cap + PCI_MSIX_TABLE,
+			      &table_offset);
+
+	bir = (u8)(table_offset & PCI_MSIX_TABLE_BIR);
+	table_offset &= PCI_MSIX_TABLE_OFFSET;
+
+	phys_addr = pci_resource_start(pdev, bir) + table_offset;
+
+	return ioremap_nocache(phys_addr, nr_entries * PCI_MSIX_ENTRY_SIZE);
+}
+
+/* Interrupt configuration and handling
+ */
+
+/**
+ * nfp_net_irq_unmask() - Unmask an interrupt
+ * @nn:       NFP Network structure
+ * @entry_nr: MSI-X table entry
+ *
+ * If MSI-X auto-masking is enabled clear the mask bit, otherwise
+ * clear the ICR for the entry.
+ */
+static void nfp_net_irq_unmask(struct nfp_net *nn, unsigned int entry_nr)
+{
+	struct pci_dev *pdev = nn->pdev;
+	int off;
+
+	if (!pdev->msix_enabled)
+		return;
+
+	if (nn->ctrl & NFP_NET_CFG_CTRL_MSIXAUTO) {
+		/* If MSI-X auto-masking is used, clear the entry */
+		off = (PCI_MSIX_ENTRY_SIZE * entry_nr) +
+			PCI_MSIX_ENTRY_VECTOR_CTRL;
+		writel(0, nn->msix_table + off);
+	} else {
+		nn_writeb(nn,
+			  NFP_NET_CFG_ICR(entry_nr), NFP_NET_CFG_ICR_UNMASKED);
+	}
+}
+
+/**
+ * nfp_net_msix_alloc() - Try to allocate MSI-X irqs
+ * @nn:       NFP Network structure
+ * @nr_vecs:  Number of MSI-X vectors to allocate
+ *
+ * For MSI-X we want at least NFP_NET_NON_Q_VECTORS + 1 vectors.
+ *
+ * Return: Number of MSI-X vectors obtained or 0 on error.
+ */
+static int nfp_net_msix_alloc(struct nfp_net *nn, int nr_vecs)
+{
+	struct pci_dev *pdev = nn->pdev;
+	int nvecs;
+	int i;
+
+	for (i = 0; i < nr_vecs; i++)
+		nn->irq_entries[i].entry = i;
+
+	nvecs = pci_enable_msix_range(pdev, nn->irq_entries,
+				      NFP_NET_NON_Q_VECTORS + 1, nr_vecs);
+	if (nvecs < 0) {
+		nn_warn(nn, "Failed to enable MSI-X. Wanted %d-%d (err=%d)\n",
+			NFP_NET_NON_Q_VECTORS + 1, nr_vecs, nvecs);
+		return 0;
+	}
+
+	nn->per_vector_masking = 1;
+
+	return nvecs;
+}
+
+/**
+ * nfp_net_irqs_wanted() - Work out how many interrupt vectors we want
+ * @nn:       NFP Network structure
+ *
+ * We want a vector per CPU (or ring), whatever is smaller plus
+ * NFP_NET_NON_Q_VECTORS for LSC etc.
+ *
+ * Return: Number of interrupts wanted
+ */
+static int nfp_net_irqs_wanted(struct nfp_net *nn)
+{
+	int ncpus;
+	int vecs;
+
+	ncpus = num_online_cpus();
+
+	vecs = max_t(int, nn->num_tx_rings, nn->num_rx_rings);
+	vecs = min_t(int, vecs, ncpus);
+
+	return vecs + NFP_NET_NON_Q_VECTORS;
+}
+
+/**
+ * nfp_net_irqs_alloc() - allocates MSI-X irqs
+ * @nn:       NFP Network structure
+ *
+ * Return: Number of irqs obtained or 0 on error.
+ */
+int nfp_net_irqs_alloc(struct nfp_net *nn)
+{
+	int wanted_irqs;
+
+	wanted_irqs = nfp_net_irqs_wanted(nn);
+
+	nn->num_irqs = nfp_net_msix_alloc(nn, wanted_irqs);
+	if (nn->num_irqs == 0) {
+		nn_err(nn, "Failed to allocate MSI-X IRQs\n");
+		return 0;
+	}
+
+	nn->num_r_vecs = nn->num_irqs - NFP_NET_NON_Q_VECTORS;
+
+	if (nn->num_irqs < wanted_irqs)
+		nn_warn(nn, "Unable to allocate %d vectors. Got %d instead\n",
+			wanted_irqs, nn->num_irqs);
+
+	return nn->num_irqs;
+}
+
+/**
+ * nfp_net_irqs_disable() - Disable interrupts
+ * @nn:       NFP Network structure
+ *
+ * Undoes what @nfp_net_irqs_alloc() does.
+ */
+void nfp_net_irqs_disable(struct nfp_net *nn)
+{
+	if (nn->pdev->msix_enabled)
+		pci_disable_msix(nn->pdev);
+}
+
+/**
+ * nfp_net_irq_rxtx() - Interrupt service routine for RX/TX rings.
+ * @irq:      Interrupt
+ * @data:     Opaque data structure
+ *
+ * Return: Indicate if the interrupt has been handled.
+ */
+static irqreturn_t nfp_net_irq_rxtx(int irq, void *data)
+{
+	struct nfp_net_r_vector *r_vec = data;
+	struct napi_struct *napi = &r_vec->napi;
+
+	if (!r_vec->rx_ring && !r_vec->tx_ring)
+		return IRQ_HANDLED;
+
+	/* The FW auto-masks any interrupt, either via the MASK bit in
+	 * the MSI-X table or via the per entry ICR field.  So there
+	 * is no need to disable interrupts here.
+	 */
+
+	/* There is a short period between enabling interrupts and
+	 * enabling NAPI.  If a interrupt gets delivered during this
+	 * period, NAPI will not get scheduled and the auto-masked
+	 * interrupt will never get un-masked.  Handle this case here.
+	 */
+	if (unlikely(!test_bit(NFP_NET_RVEC_NAPI_STARTED, &r_vec->flags))) {
+		nfp_net_irq_unmask(r_vec->nfp_net, r_vec->irq_idx);
+		return IRQ_HANDLED;
+	}
+
+	napi_schedule(napi);
+
+	return IRQ_HANDLED;
+}
+
+static void nfp_net_print_link(struct nfp_net *nn, bool isup)
+{
+	if (isup)
+		netdev_info(nn->netdev, "NIC Link is Up\n");
+	else
+		netdev_info(nn->netdev, "NIC Link is Down\n");
+}
+
+/**
+ * nfp_net_irq_lsc() - Interrupt service routine for link state changes
+ * @irq:      Interrupt
+ * @data:     Opaque data structure
+ *
+ * Return: Indicate if the interrupt has been handled.
+ */
+static irqreturn_t nfp_net_irq_lsc(int irq, void *data)
+{
+	struct net_device *netdev = data;
+	struct nfp_net *nn = netdev_priv(netdev);
+	bool link_up;
+	u32 sts;
+
+	sts = nn_readl(nn, NFP_NET_CFG_STS);
+	link_up = !!(sts & NFP_NET_CFG_STS_LINK);
+
+	if (nn->link_up == link_up)
+		goto unmask_lsc_irq;
+
+	nn->link_up = link_up;
+
+	if (nn->link_up)
+		netif_carrier_on(netdev);
+	else
+		netif_carrier_off(netdev);
+
+	nfp_net_print_link(nn, sts & NFP_NET_CFG_STS_LINK);
+
+unmask_lsc_irq:
+	nfp_net_irq_unmask(nn, NFP_NET_IRQ_LSC_IDX);
+
+	return IRQ_HANDLED;
+}
+
+/**
+ * nfp_net_irq_exn() - Interrupt service routine for exceptions
+ * @irq:      Interrupt
+ * @data:     Opaque data structure
+ *
+ * Return: Indicate if the interrupt has been handled.
+ */
+static irqreturn_t nfp_net_irq_exn(int irq, void *data)
+{
+	struct net_device *netdev = data;
+	struct nfp_net *nn = netdev_priv(netdev);
+
+	nn_err(nn, "%s: UNIMPLEMENTED.\n", __func__);
+	/* XXX TO BE IMPLEMENTED */
+	return IRQ_HANDLED;
+}
+
+/**
+ * nfp_net_tx_ring_init() - Fill in the boilerplate for a TX ring
+ * @tx_ring:  TX ring structure
+ */
+static void nfp_net_tx_ring_init(struct nfp_net_tx_ring *tx_ring)
+{
+	struct nfp_net_r_vector *r_vec = tx_ring->r_vec;
+	struct nfp_net *nn = r_vec->nfp_net;
+
+	tx_ring->qcidx = tx_ring->idx * nn->stride_tx;
+	tx_ring->qcp_q = nn->tx_bar + NFP_QCP_QUEUE_OFF(tx_ring->qcidx);
+}
+
+/**
+ * nfp_net_rx_ring_init() - Fill in the boilerplate for a RX ring
+ * @rx_ring:  RX ring structure
+ */
+static void nfp_net_rx_ring_init(struct nfp_net_rx_ring *rx_ring)
+{
+	struct nfp_net_r_vector *r_vec = rx_ring->r_vec;
+	struct nfp_net *nn = r_vec->nfp_net;
+
+	rx_ring->fl_qcidx = rx_ring->idx * nn->stride_rx;
+	rx_ring->rx_qcidx = rx_ring->fl_qcidx + (nn->stride_rx - 1);
+
+	rx_ring->qcp_fl = nn->rx_bar + NFP_QCP_QUEUE_OFF(rx_ring->fl_qcidx);
+	rx_ring->qcp_rx = nn->rx_bar + NFP_QCP_QUEUE_OFF(rx_ring->rx_qcidx);
+}
+
+/**
+ * nfp_net_irqs_assign() - Assign IRQs and setup rvecs.
+ * @netdev:   netdev structure
+ */
+static void nfp_net_irqs_assign(struct net_device *netdev)
+{
+	struct nfp_net *nn = netdev_priv(netdev);
+	struct nfp_net_r_vector *r_vec;
+	int i, r;
+
+	nn_assert(nn->num_irqs > 0, "num_irqs is zero");
+	nn_assert(nn->num_r_vecs > 0, "num_r_vecs is zero");
+
+	/* Assumes nn->num_tx_rings == nn->num_rx_rings */
+	if (nn->num_tx_rings > nn->num_r_vecs) {
+		nn_warn(nn, "More rings (%d) than vectors (%d).\n",
+			nn->num_tx_rings, nn->num_r_vecs);
+		nn->num_tx_rings = nn->num_r_vecs;
+		nn->num_rx_rings = nn->num_r_vecs;
+	}
+
+	nn->lsc_handler = nfp_net_irq_lsc;
+	nn->exn_handler = nfp_net_irq_exn;
+
+	for (i = NFP_NET_NON_Q_VECTORS, r = 0; i < nn->num_irqs; i++, r++) {
+		r_vec = &nn->r_vecs[r];
+		r_vec->nfp_net = nn;
+		r_vec->idx = r;
+		r_vec->handler = nfp_net_irq_rxtx;
+		r_vec->irq_idx = i;
+		r_vec->requested = 0;
+
+		cpumask_set_cpu(r, &r_vec->affinity_mask);
+
+		r_vec->tx_ring = &nn->tx_rings[r];
+		nn->tx_rings[r].idx = r;
+		nn->tx_rings[r].r_vec = r_vec;
+		nfp_net_tx_ring_init(r_vec->tx_ring);
+
+		r_vec->rx_ring = &nn->rx_rings[r];
+		nn->rx_rings[r].idx = r;
+		nn->rx_rings[r].r_vec = r_vec;
+		nfp_net_rx_ring_init(r_vec->rx_ring);
+	}
+}
+
+/**
+ * nfp_net_irqs_request() - Request the common interrupts
+ * @netdev:   netdev structure
+ *
+ * Interrupts for LSC and EXN (ring vectors are requested elsewhere)
+ */
+static int nfp_net_irqs_request(struct net_device *netdev)
+{
+	struct msix_entry *lsc_entry, *exn_entry;
+	struct nfp_net *nn = netdev_priv(netdev);
+	int err;
+
+	nn_assert(nn->num_irqs > 0, "num_irqs is zero");
+
+	lsc_entry = &nn->irq_entries[NFP_NET_IRQ_LSC_IDX];
+
+	snprintf(nn->lsc_name, sizeof(nn->lsc_name), "%s-lsc", netdev->name);
+	err = request_irq(lsc_entry->vector,
+			  nn->lsc_handler, 0, nn->lsc_name, netdev);
+	if (err) {
+		nn_err(nn, "Failed to request IRQ %d (err=%d).\n",
+		       lsc_entry->vector, err);
+		return err;
+	}
+	nn_writeb(nn, NFP_NET_CFG_LSC, NFP_NET_IRQ_LSC_IDX);
+
+	exn_entry = &nn->irq_entries[NFP_NET_IRQ_EXN_IDX];
+
+	snprintf(nn->exn_name, sizeof(nn->exn_name), "%s-exn", netdev->name);
+	err = request_irq(exn_entry->vector,
+			  nn->exn_handler, 0, nn->exn_name, netdev);
+	if (err) {
+		nn_err(nn, "Failed to request IRQ %d (err=%d).\n",
+		       exn_entry->vector, err);
+		goto err_exn;
+	}
+	nn_writeb(nn, NFP_NET_CFG_EXN, NFP_NET_IRQ_EXN_IDX);
+
+	return 0;
+
+err_exn:
+	free_irq(lsc_entry->vector, netdev);
+	nn_writeb(nn, NFP_NET_CFG_LSC, 0xff);
+	return err;
+}
+
+/**
+ * nfp_net_irqs_free() - Free the requested common interrupts
+ * @netdev:   netdev structure
+ *
+ * This frees the general interrupt (not the ring interrupts). It
+ * undoes what @nfp_net_irqs_request set-up.
+ */
+static void nfp_net_irqs_free(struct net_device *netdev)
+{
+	struct nfp_net *nn = netdev_priv(netdev);
+
+	nn_assert(nn->num_irqs > 0, "num_irqs is 0");
+
+	synchronize_irq(nn->irq_entries[NFP_NET_IRQ_EXN_IDX].vector);
+	free_irq(nn->irq_entries[NFP_NET_IRQ_EXN_IDX].vector, netdev);
+	nn_writeb(nn, NFP_NET_CFG_EXN, 0xff);
+
+	synchronize_irq(nn->irq_entries[NFP_NET_IRQ_LSC_IDX].vector);
+	free_irq(nn->irq_entries[NFP_NET_IRQ_LSC_IDX].vector, netdev);
+	nn_writeb(nn, NFP_NET_CFG_LSC, 0xff);
+}
+
+/* Transmit
+ *
+ * One queue controller peripheral queue is used for transmit.  The
+ * driver en-queues packets for transmit by advancing the write
+ * pointer.  The device indicates that packets have transmitted by
+ * advancing the read pointer.  The driver maintains a local copy of
+ * the read and write pointer in @struct nfp_net_tx_ring.  The driver
+ * keeps @wr_p in sync with the queue controller write pointer and can
+ * determine how many packets have been transmitted by comparing its
+ * copy of the read pointer @rd_p with the read pointer maintained by
+ * the queue controller peripheral.
+ */
+
+/**
+ * nfp_net_tx_full() - Check if the TX ring is full
+ * @tx_ring: TX ring to check
+ * @dcnt:    Number of descriptors that need to be enqueued (must be >= 1)
+ *
+ * This function checks, based on the *host copy* of read/write
+ * pointer if a given TX ring is full.  The real TX queue may have
+ * some newly made available slots.
+ *
+ * Return: True if the ring is full.
+ */
+static inline int nfp_net_tx_full(struct nfp_net_tx_ring *tx_ring, int dcnt)
+{
+	return (tx_ring->wr_p - tx_ring->rd_p) >= (tx_ring->cnt - dcnt);
+}
+
+/* Wrappers for deciding when to stop and restart TX queues */
+static int nfp_net_tx_ring_should_wake(struct nfp_net_tx_ring *tx_ring)
+{
+	return !nfp_net_tx_full(tx_ring, MAX_SKB_FRAGS * 4);
+}
+
+static int nfp_net_tx_ring_should_stop(struct nfp_net_tx_ring *tx_ring)
+{
+	return nfp_net_tx_full(tx_ring, MAX_SKB_FRAGS + 1);
+}
+
+/**
+ * nfp_net_tx_ring_stop() - stop tx ring
+ * @nd_q:    netdev queue
+ * @tx_ring: driver tx queue structure
+ *
+ * Safely stop TX ring.  Remember that while we are running .start_xmit()
+ * someone else may be cleaning the TX ring completions so we need to be
+ * extra careful here.
+ */
+static void nfp_net_tx_ring_stop(struct netdev_queue *nd_q,
+				 struct nfp_net_tx_ring *tx_ring)
+{
+	netif_tx_stop_queue(nd_q);
+
+	/* We can race with the TX completion out of NAPI so recheck */
+	smp_mb();
+	if (unlikely(nfp_net_tx_ring_should_wake(tx_ring)))
+		netif_tx_start_queue(nd_q);
+}
+
+/**
+ * nfp_net_tx_tso() - Set up Tx descriptor for LSO
+ * @nn:  NFP Net device
+ * @r_vec: per-ring structure
+ * @txbuf: Pointer to driver soft TX descriptor
+ * @txd: Pointer to HW TX descriptor
+ * @skb: Pointer to SKB
+ *
+ * Set up Tx descriptor for LSO, do nothing for non-LSO skbs.
+ * Return error on packet header greater than maximum supported LSO header size.
+ */
+static int nfp_net_tx_tso(struct nfp_net *nn, struct nfp_net_r_vector *r_vec,
+			  struct nfp_net_tx_buf *txbuf,
+			  struct nfp_net_tx_desc *txd, struct sk_buff *skb)
+{
+	u32 hdrlen;
+
+	if (!skb_is_gso(skb))
+		return 0;
+
+	if (!skb->encapsulation)
+		hdrlen = skb_transport_offset(skb) + tcp_hdrlen(skb);
+	else
+		hdrlen = skb_inner_transport_header(skb) - skb->data +
+			inner_tcp_hdrlen(skb);
+
+	txbuf->pkt_cnt = skb_shinfo(skb)->gso_segs;
+	txbuf->real_len += hdrlen * (txbuf->pkt_cnt - 1);
+
+	txd->l4_offset = hdrlen;
+	txd->lso = cpu_to_le16(skb_shinfo(skb)->gso_size);
+
+	u64_stats_update_begin(&r_vec->tx_sync);
+	r_vec->tx_lso++;
+	u64_stats_update_end(&r_vec->tx_sync);
+
+	return 0;
+}
+
+/**
+ * nfp_net_tx_csum() - Set TX CSUM offload flags in TX descriptor
+ * @nn:  NFP Net device
+ * @r_vec: per-ring structure
+ * @txbuf: Pointer to driver soft TX descriptor
+ * @txd: Pointer to TX descriptor
+ * @skb: Pointer to SKB
+ *
+ * This function sets the TX checksum flags in the TX descriptor based
+ * on the configuration and the protocol of the packet to be transmitted.
+ */
+static void nfp_net_tx_csum(struct nfp_net *nn, struct nfp_net_r_vector *r_vec,
+			    struct nfp_net_tx_buf *txbuf,
+			    struct nfp_net_tx_desc *txd, struct sk_buff *skb)
+{
+	struct ipv6hdr *ipv6h;
+	struct iphdr *iph;
+	u8 l4_hdr;
+
+	if (!(nn->ctrl & NFP_NET_CFG_CTRL_TXCSUM))
+		return;
+
+	if (skb->ip_summed != CHECKSUM_PARTIAL)
+		return;
+
+	txd->flags |= PCIE_DESC_TX_CSUM;
+
+	iph = skb->encapsulation ? inner_ip_hdr(skb) : ip_hdr(skb);
+	ipv6h = skb->encapsulation ? inner_ipv6_hdr(skb) : ipv6_hdr(skb);
+
+	if (iph->version == 4) {
+		txd->flags |= PCIE_DESC_TX_IP4_CSUM;
+		l4_hdr = iph->protocol;
+	} else if (ipv6h->version == 6) {
+		l4_hdr = ipv6h->nexthdr;
+	} else {
+		nn_warn_ratelimit(nn, "partial checksum but ipv=%x!\n",
+				  iph->version);
+		return;
+	}
+
+	switch (l4_hdr) {
+	case IPPROTO_TCP:
+		txd->flags |= PCIE_DESC_TX_TCP_CSUM;
+		break;
+	case IPPROTO_UDP:
+		txd->flags |= PCIE_DESC_TX_UDP_CSUM;
+		break;
+	default:
+		nn_warn_ratelimit(nn, "partial checksum but l4 proto=%x!\n",
+				  l4_hdr);
+		return;
+	}
+
+	if (skb->encapsulation) {
+		switch (vlan_get_protocol(skb)) {
+		case htons(ETH_P_IP):
+			l4_hdr = ip_hdr(skb)->protocol;
+			break;
+		case htons(ETH_P_IPV6):
+			l4_hdr = ipv6_hdr(skb)->nexthdr;
+			break;
+		default:
+			nn_warn_ratelimit(nn, "invalid proto for encap=%x!\n",
+					  vlan_get_protocol(skb));
+			return;
+		}
+
+		switch (l4_hdr) {
+		case IPPROTO_GRE:
+			txd->flags |= PCIE_DESC_TX_ENCAP_NVGRE;
+			break;
+		case IPPROTO_UDP:
+			txd->flags |= PCIE_DESC_TX_ENCAP_VXLAN;
+			break;
+		default:
+			nn_warn_ratelimit(nn, "invalid encap l4 proto=%x!\n",
+					  l4_hdr);
+			return;
+		}
+
+		u64_stats_update_begin(&r_vec->tx_sync);
+		r_vec->hw_csum_tx_inner += txbuf->pkt_cnt;
+		u64_stats_update_end(&r_vec->tx_sync);
+		return;
+	}
+
+	u64_stats_update_begin(&r_vec->tx_sync);
+	r_vec->hw_csum_tx += txbuf->pkt_cnt;
+	u64_stats_update_end(&r_vec->tx_sync);
+}
+
+/**
+ * nfp_net_tx() - Main transmit entry point
+ * @skb:    SKB to transmit
+ * @netdev: netdev structure
+ *
+ * Return: NETDEV_TX_OK on success.
+ */
+static int nfp_net_tx(struct sk_buff *skb, struct net_device *netdev)
+{
+	struct nfp_net *nn = netdev_priv(netdev);
+	const struct skb_frag_struct *frag;
+	struct nfp_net_r_vector *r_vec;
+	struct nfp_net_tx_desc *txd, txdg;
+	struct nfp_net_tx_buf *txbuf;
+	struct nfp_net_tx_ring *tx_ring;
+	struct netdev_queue *nd_q;
+	dma_addr_t dma_addr;
+	unsigned int fsize;
+	int nr_frags;
+	int wr_idx;
+	u16 qidx;
+	int err, f;
+
+	qidx = skb_get_queue_mapping(skb);
+	tx_ring = &nn->tx_rings[qidx];
+	r_vec = tx_ring->r_vec;
+	nd_q = netdev_get_tx_queue(nn->netdev, qidx);
+
+	nn_assert((tx_ring->wr_p - tx_ring->rd_p) <= tx_ring->cnt,
+		  "rd_p=%u wr_p=%u cnt=%u\n",
+		  tx_ring->rd_p, tx_ring->wr_p, tx_ring->cnt);
+
+	nr_frags = skb_shinfo(skb)->nr_frags;
+
+	if (unlikely(nfp_net_tx_full(tx_ring, nr_frags + 1))) {
+		nn_warn_ratelimit(nn, "TX ring %d busy. wrp=%u rdp=%u\n",
+				  qidx, tx_ring->wr_p, tx_ring->rd_p);
+		netif_tx_stop_queue(nd_q);
+		u64_stats_update_begin(&r_vec->tx_sync);
+		r_vec->tx_busy++;
+		u64_stats_update_end(&r_vec->tx_sync);
+		return NETDEV_TX_BUSY;
+	}
+
+	/* Start with the head skbuf */
+	dma_addr = dma_map_single(&nn->pdev->dev, skb->data, skb_headlen(skb),
+				  DMA_TO_DEVICE);
+	if (dma_mapping_error(&nn->pdev->dev, dma_addr))
+		goto err_free;
+
+	wr_idx = tx_ring->wr_p % tx_ring->cnt;
+
+	/* Stash the soft descriptor of the head then initialize it */
+	txbuf = &tx_ring->txbufs[wr_idx];
+	txbuf->skb = skb;
+	txbuf->dma_addr = dma_addr;
+	txbuf->fidx = -1;
+	txbuf->pkt_cnt = 1;
+	txbuf->real_len = skb->len;
+
+	/* Build TX descriptor */
+	txd = &tx_ring->txds[wr_idx];
+	txd->offset_eop = (nr_frags == 0) ? PCIE_DESC_TX_EOP : 0;
+	txd->dma_len = cpu_to_le16(skb_headlen(skb));
+	nfp_desc_set_dma_addr(txd, dma_addr);
+	txd->data_len = cpu_to_le16(skb->len);
+
+	txd->lso = 0;
+	txd->l4_offset = 0;
+	err = nfp_net_tx_tso(nn, r_vec, txbuf, txd, skb);
+	if (err)
+		goto err_unmap_head;
+
+	txd->flags = 0;
+	nfp_net_tx_csum(nn, r_vec, txbuf, txd, skb);
+
+	if (skb_vlan_tag_present(skb) && nn->ctrl & NFP_NET_CFG_CTRL_TXVLAN) {
+		txd->flags |= PCIE_DESC_TX_VLAN;
+		txd->vlan = cpu_to_le16(skb_vlan_tag_get(skb));
+	}
+
+	/* Gather DMA */
+	if (nr_frags > 0) {
+		/* all descs must match except for in addr, length and eop */
+		txdg = *txd;
+
+		for (f = 0; f < nr_frags; f++) {
+			frag = &skb_shinfo(skb)->frags[f];
+			fsize = skb_frag_size(frag);
+
+			dma_addr = skb_frag_dma_map(&nn->pdev->dev, frag, 0,
+						    fsize, DMA_TO_DEVICE);
+			if (dma_mapping_error(&nn->pdev->dev, dma_addr))
+				goto err_unmap_frags;
+
+			wr_idx = (wr_idx + 1) % tx_ring->cnt;
+			tx_ring->txbufs[wr_idx].skb = skb;
+			tx_ring->txbufs[wr_idx].dma_addr = dma_addr;
+			tx_ring->txbufs[wr_idx].fidx = f;
+
+			txd = &tx_ring->txds[wr_idx];
+			*txd = txdg;
+			txd->dma_len = cpu_to_le16(fsize);
+			nfp_desc_set_dma_addr(txd, dma_addr);
+			txd->offset_eop =
+				(f == nr_frags - 1) ? PCIE_DESC_TX_EOP : 0;
+		}
+
+		u64_stats_update_begin(&r_vec->tx_sync);
+		r_vec->tx_gather++;
+		u64_stats_update_end(&r_vec->tx_sync);
+	}
+
+	netdev_tx_sent_queue(nd_q, txbuf->real_len);
+
+	tx_ring->wr_p += nr_frags + 1;
+	if (nfp_net_tx_ring_should_stop(tx_ring))
+		nfp_net_tx_ring_stop(nd_q, tx_ring);
+
+	tx_ring->wr_ptr_add += nr_frags + 1;
+	if (!skb->xmit_more || netif_xmit_stopped(nd_q)) {
+		/* force memory write before we let HW know */
+		wmb();
+		nfp_qcp_wr_ptr_add(tx_ring->qcp_q, tx_ring->wr_ptr_add);
+		tx_ring->wr_ptr_add = 0;
+	}
+
+	skb_tx_timestamp(skb);
+
+	nn_assert((tx_ring->wr_p - tx_ring->rd_p) <= tx_ring->cnt,
+		  "rd_p=%u wr_p=%u cnt=%u\n",
+		  tx_ring->rd_p, tx_ring->wr_p, tx_ring->cnt);
+
+	return NETDEV_TX_OK;
+
+err_unmap_frags:
+	--f;
+	while (f >= 0) {
+		frag = &skb_shinfo(skb)->frags[f];
+		dma_unmap_page(&nn->pdev->dev,
+			       tx_ring->txbufs[wr_idx].dma_addr,
+			       skb_frag_size(frag), DMA_TO_DEVICE);
+		tx_ring->txbufs[wr_idx].skb = NULL;
+		tx_ring->txbufs[wr_idx].dma_addr = 0;
+		tx_ring->txbufs[wr_idx].fidx = -2;
+		wr_idx = wr_idx - 1;
+		if (wr_idx < 0)
+			wr_idx += tx_ring->cnt;
+	}
+err_unmap_head:
+	dma_unmap_single(&nn->pdev->dev, tx_ring->txbufs[wr_idx].dma_addr,
+			 skb_headlen(skb), DMA_TO_DEVICE);
+	tx_ring->txbufs[wr_idx].skb = NULL;
+	tx_ring->txbufs[wr_idx].dma_addr = 0;
+	tx_ring->txbufs[wr_idx].fidx = -2;
+err_free:
+	nn_warn_ratelimit(nn, "Failed to map DMA TX buffer\n");
+	u64_stats_update_begin(&r_vec->tx_sync);
+	r_vec->tx_errors++;
+	u64_stats_update_end(&r_vec->tx_sync);
+	dev_kfree_skb_any(skb);
+	return NETDEV_TX_OK;
+}
+
+/**
+ * nfp_net_tx_complete() - Handled completed TX packets
+ * @tx_ring:   TX ring structure
+ *
+ * Return: Number of completed TX descriptors
+ */
+static int nfp_net_tx_complete(struct nfp_net_tx_ring *tx_ring)
+{
+	struct nfp_net_r_vector *r_vec = tx_ring->r_vec;
+	struct nfp_net *nn = r_vec->nfp_net;
+	const struct skb_frag_struct *frag;
+	struct netdev_queue *nd_q;
+	u32 done_pkts = 0, done_bytes = 0;
+	int todo, completed = 0;
+	struct sk_buff *skb;
+	int nr_frags;
+	u32 qcp_rd_p;
+	int fidx;
+	int idx;
+
+	nn_assert((tx_ring->wr_p - tx_ring->rd_p) <= tx_ring->cnt,
+		  "rd_p=%u wr_p=%u cnt=%u\n",
+		  tx_ring->rd_p, tx_ring->wr_p, tx_ring->cnt);
+
+	/* Work out how many descriptors have been transmitted */
+	qcp_rd_p = nfp_qcp_rd_ptr_read(tx_ring->qcp_q);
+
+	if (qcp_rd_p == tx_ring->qcp_rd_p)
+		return 0;
+
+	if (qcp_rd_p > tx_ring->qcp_rd_p)
+		todo = qcp_rd_p - tx_ring->qcp_rd_p;
+	else
+		todo = qcp_rd_p + tx_ring->cnt - tx_ring->qcp_rd_p;
+
+	while (todo > completed) {
+		idx = tx_ring->rd_p % tx_ring->cnt;
+		tx_ring->rd_p++;
+		completed++;
+
+		skb = tx_ring->txbufs[idx].skb;
+		if (!skb)
+			continue;
+
+		nr_frags = skb_shinfo(skb)->nr_frags;
+		fidx = tx_ring->txbufs[idx].fidx;
+
+		if (fidx == -1) {
+			/* unmap head */
+			dma_unmap_single(&nn->pdev->dev,
+					 tx_ring->txbufs[idx].dma_addr,
+					 skb_headlen(skb), DMA_TO_DEVICE);
+
+			done_pkts += tx_ring->txbufs[idx].pkt_cnt;
+			done_bytes += tx_ring->txbufs[idx].real_len;
+		} else {
+			/* unmap fragment */
+			frag = &skb_shinfo(skb)->frags[fidx];
+			dma_unmap_page(&nn->pdev->dev,
+				       tx_ring->txbufs[idx].dma_addr,
+				       skb_frag_size(frag), DMA_TO_DEVICE);
+		}
+
+		/* check for last gather fragment */
+		if (fidx == nr_frags - 1)
+			dev_kfree_skb_any(skb);
+
+		tx_ring->txbufs[idx].dma_addr = 0;
+		tx_ring->txbufs[idx].skb = NULL;
+		tx_ring->txbufs[idx].fidx = -2;
+	}
+
+	tx_ring->qcp_rd_p = qcp_rd_p;
+
+	u64_stats_update_begin(&r_vec->tx_sync);
+	r_vec->tx_bytes += done_bytes;
+	r_vec->tx_pkts += done_pkts;
+	u64_stats_update_end(&r_vec->tx_sync);
+
+	nd_q = netdev_get_tx_queue(nn->netdev, tx_ring->idx);
+	netdev_tx_completed_queue(nd_q, done_pkts, done_bytes);
+	if (nfp_net_tx_ring_should_wake(tx_ring)) {
+		/* Make sure TX thread will see updated tx_ring->rd_p */
+		smp_mb();
+
+		if (unlikely(netif_tx_queue_stopped(nd_q)))
+			netif_tx_wake_queue(nd_q);
+	}
+
+	return completed;
+}
+
+/**
+ * nfp_net_tx_flush() - Free any untransmitted buffers currently on the TX ring
+ * @tx_ring:     TX ring structure
+ *
+ * Assumes that the device is stopped
+ */
+static void nfp_net_tx_flush(struct nfp_net_tx_ring *tx_ring)
+{
+	struct nfp_net_r_vector *r_vec = tx_ring->r_vec;
+	struct nfp_net *nn = r_vec->nfp_net;
+	struct pci_dev *pdev = nn->pdev;
+	const struct skb_frag_struct *frag;
+	struct netdev_queue *nd_q;
+	struct sk_buff *skb;
+	int nr_frags;
+	int fidx;
+	int idx;
+
+	nn_assert((tx_ring->wr_p - tx_ring->rd_p) <= tx_ring->cnt,
+		  "rd_p=%u wr_p=%u cnt=%u\n",
+		  tx_ring->rd_p, tx_ring->wr_p, tx_ring->cnt);
+
+	while (tx_ring->rd_p != tx_ring->wr_p) {
+		idx = tx_ring->rd_p % tx_ring->cnt;
+
+		skb = tx_ring->txbufs[idx].skb;
+		if (skb) {
+			nr_frags = skb_shinfo(skb)->nr_frags;
+			fidx = tx_ring->txbufs[idx].fidx;
+
+			if (fidx == -1) {
+				/* unmap head */
+				dma_unmap_single(&pdev->dev,
+						 tx_ring->txbufs[idx].dma_addr,
+						 skb_headlen(skb),
+						 DMA_TO_DEVICE);
+			} else {
+				/* unmap fragment */
+				frag = &skb_shinfo(skb)->frags[fidx];
+				dma_unmap_page(&pdev->dev,
+					       tx_ring->txbufs[idx].dma_addr,
+					       skb_frag_size(frag),
+					       DMA_TO_DEVICE);
+			}
+
+			/* check for last gather fragment */
+			if (fidx == nr_frags - 1)
+				dev_kfree_skb_any(skb);
+
+			tx_ring->txbufs[idx].dma_addr = 0;
+			tx_ring->txbufs[idx].skb = NULL;
+			tx_ring->txbufs[idx].fidx = -2;
+		}
+
+		memset(&tx_ring->txds[idx], 0, sizeof(tx_ring->txds[idx]));
+
+		tx_ring->qcp_rd_p++;
+		tx_ring->rd_p++;
+	}
+
+	nd_q = netdev_get_tx_queue(nn->netdev, tx_ring->idx);
+	netdev_tx_reset_queue(nd_q);
+}
+
+static void nfp_net_tx_timeout(struct net_device *netdev)
+{
+	struct nfp_net *nn = netdev_priv(netdev);
+	int i;
+
+	for (i = 0; i < nn->num_tx_rings; i++) {
+		if (!netif_tx_queue_stopped(netdev_get_tx_queue(netdev, i)))
+			continue;
+		nn_warn(nn, "TX timeout on ring: %d\n", i);
+	}
+	nn_warn(nn, "TX watchdog timeout\n");
+}
+
+/* Receive processing
+ */
+
+/**
+ * nfp_net_rx_space() - return the number of free slots on the RX ring
+ * @rx_ring:   RX ring structure
+ *
+ * Make sure we leave at least one slot free.
+ *
+ * Return: True if there is space on the RX ring
+ */
+static inline int nfp_net_rx_space(struct nfp_net_rx_ring *rx_ring)
+{
+	return (rx_ring->cnt - 1) - (rx_ring->wr_p - rx_ring->rd_p);
+}
+
+/**
+ * nfp_net_rx_csum_has_errors() - group check if rxd has any csum errors
+ * @flags: RX descriptor flags field in CPU byte order
+ */
+static int nfp_net_rx_csum_has_errors(u16 flags)
+{
+	u16 csum_all_checked, csum_all_ok;
+
+	csum_all_checked = flags & __PCIE_DESC_RX_CSUM_ALL;
+	csum_all_ok = flags & __PCIE_DESC_RX_CSUM_ALL_OK;
+
+	return csum_all_checked != (csum_all_ok << PCIE_DESC_RX_CSUM_OK_SHIFT);
+}
+
+/**
+ * nfp_net_rx_csum() - set SKB checksum field based on RX descriptor flags
+ * @nn:  NFP Net device
+ * @r_vec: per-ring structure
+ * @rxd: Pointer to RX descriptor
+ * @skb: Pointer to SKB
+ */
+static void nfp_net_rx_csum(struct nfp_net *nn, struct nfp_net_r_vector *r_vec,
+			    struct nfp_net_rx_desc *rxd, struct sk_buff *skb)
+{
+	skb_checksum_none_assert(skb);
+
+	if (!(nn->netdev->features & NETIF_F_RXCSUM))
+		return;
+
+	if (nfp_net_rx_csum_has_errors(le16_to_cpu(rxd->rxd.flags))) {
+		u64_stats_update_begin(&r_vec->rx_sync);
+		r_vec->hw_csum_rx_error++;
+		u64_stats_update_end(&r_vec->rx_sync);
+		return;
+	}
+
+	/* Assume that the firmware will never report inner CSUM_OK unless outer
+	 * L4 headers were successfully parsed. FW will always report zero UDP
+	 * checksum as CSUM_OK.
+	 */
+	if (rxd->rxd.flags & PCIE_DESC_RX_TCP_CSUM_OK ||
+	    rxd->rxd.flags & PCIE_DESC_RX_UDP_CSUM_OK) {
+		__skb_incr_checksum_unnecessary(skb);
+		u64_stats_update_begin(&r_vec->rx_sync);
+		r_vec->hw_csum_rx_ok++;
+		u64_stats_update_end(&r_vec->rx_sync);
+	}
+
+	if (rxd->rxd.flags & PCIE_DESC_RX_I_TCP_CSUM_OK ||
+	    rxd->rxd.flags & PCIE_DESC_RX_I_UDP_CSUM_OK) {
+		__skb_incr_checksum_unnecessary(skb);
+		u64_stats_update_begin(&r_vec->rx_sync);
+		r_vec->hw_csum_rx_inner_ok++;
+		u64_stats_update_end(&r_vec->rx_sync);
+	}
+}
+
+/**
+ * nfp_net_set_hash() - Set SKB hash data
+ * @skb:   SKB to set the hash data on
+ * @rxd:   RX descriptor
+ *
+ * The RSS hash and hash-type are pre-pended to the packet data.
+ * Extract and decode it and set the skb fields.
+ */
+static void nfp_net_set_hash(struct sk_buff *skb, struct nfp_net_rx_desc *rxd)
+{
+	struct nfp_net_rx_hash *rx_hash;
+
+	if (!(rxd->rxd.flags & PCIE_DESC_RX_RSS)) {
+		skb_set_hash(skb, 0, PKT_HASH_TYPE_NONE);
+		return;
+	}
+
+	rx_hash = (struct nfp_net_rx_hash *)(skb->data - sizeof(*rx_hash));
+
+	switch (be32_to_cpu(rx_hash->hash_type)) {
+	case NFP_NET_RSS_IPV4:
+	case NFP_NET_RSS_IPV6:
+	case NFP_NET_RSS_IPV6_EX:
+		skb_set_hash(skb, be32_to_cpu(rx_hash->hash), PKT_HASH_TYPE_L3);
+		break;
+	default:
+		skb_set_hash(skb, be32_to_cpu(rx_hash->hash), PKT_HASH_TYPE_L4);
+	}
+}
+
+/**
+ * nfp_net_rx() - receive up to @budget packets on @rx_ring
+ * @rx_ring:   RX ring to receive from
+ * @budget:    NAPI budget
+ *
+ * Note, this function is separated out from the napi poll function to
+ * more cleanly separate packet receive code from other bookkeeping
+ * functions performed in the napi poll function.
+ *
+ * There are differences between the NFP-3200 firmware and the
+ * NFP-6000 firmware.  The NFP-3200 firmware uses a dedicated RX queue
+ * to indicate that new packets have arrived.  The NFP-6000 does not
+ * have this queue and uses the DD bit in the RX descriptor. This
+ * method cannot be used on the NFP-3200 as it causes a race
+ * condition: The RX ring write pointer on the NFP-3200 is updated
+ * after packets (and descriptors) have been DMAed.  If the DD bit is
+ * used and subsequently the read pointer is updated this may lead to
+ * the RX queue to underflow (if the firmware has not yet update the
+ * write pointer).  Therefore we use slightly ugly conditional code
+ * below to handle the differences.  We may, in the future update the
+ * NFP-3200 firmware to behave the same as the firmware on the
+ * NFP-6000.
+ *
+ * Return: Number of packets received.
+ */
+static int nfp_net_rx(struct nfp_net_rx_ring *rx_ring, int budget)
+{
+	struct nfp_net_r_vector *r_vec = rx_ring->r_vec;
+	struct nfp_net *nn = r_vec->nfp_net;
+	unsigned int data_len, meta_len;
+	int avail = 0, pkts_polled = 0;
+	struct nfp_net_rx_desc *rxd;
+	struct sk_buff *skb;
+	u32 qcp_wr_p;
+	int idx;
+
+	if (nn->is_nfp3200) {
+		/* Work out how many packets arrived */
+		qcp_wr_p = nfp_qcp_wr_ptr_read(rx_ring->qcp_rx);
+		idx = rx_ring->rd_p % rx_ring->cnt;
+
+		if (qcp_wr_p == idx)
+			/* No new packets */
+			return 0;
+
+		if (qcp_wr_p > idx)
+			avail = qcp_wr_p - idx;
+		else
+			avail = qcp_wr_p + rx_ring->cnt - idx;
+	} else {
+		avail = budget + 1;
+	}
+
+	while (avail > 0 && pkts_polled < budget) {
+		idx = rx_ring->rd_p % rx_ring->cnt;
+
+		skb = rx_ring->rxbufs[idx].skb;
+		if (!skb) {
+			nn_err(nn, "No SKB with RX descriptor %d:%u\n",
+			       rx_ring->idx, idx);
+			break;
+		}
+
+		rxd = &rx_ring->rxds[idx];
+		if (!(rxd->rxd.meta_len_dd & PCIE_DESC_RX_DD)) {
+			if (nn->is_nfp3200)
+				nn_dbg(nn, "RX descriptor not valid (DD)%d:%u rxd[0]=%#x rxd[1]=%#x\n",
+				       rx_ring->idx, idx,
+				       rxd->vals[0], rxd->vals[1]);
+			break;
+		}
+		/* Memory barrier to ensure that we won't do other reads
+		 * before the DD bit.
+		 */
+		dma_rmb();
+
+		nn_assert(le16_to_cpu(rxd->rxd.data_len) <= nn->fl_bufsz,
+			  "RX data larger than freelist buffer (%u > %u) on %d:%u rxd[0]=%#x rxd[1]=%#x\n",
+			  le16_to_cpu(rxd->rxd.data_len), nn->fl_bufsz,
+			  rx_ring->idx, idx, rxd->vals[0], rxd->vals[1]);
+
+		dma_unmap_single(&nn->pdev->dev,
+				 rx_ring->rxbufs[idx].dma_addr,
+				 nn->fl_bufsz, DMA_FROM_DEVICE);
+
+		meta_len = rxd->rxd.meta_len_dd & PCIE_DESC_RX_META_LEN_MASK;
+		data_len = le16_to_cpu(rxd->rxd.data_len);
+
+		if (nn->rx_offset == NFP_NET_CFG_RX_OFFSET_DYNAMIC) {
+			/* The packet data starts after the metadata */
+			skb_reserve(skb, meta_len);
+		} else {
+			/* The packet data starts at a fixed offset */
+			skb_reserve(skb, nn->rx_offset);
+		}
+
+		/* Adjust the SKB for the dynamic meta data pre-pended */
+		skb_put(skb, data_len - meta_len);
+
+		nfp_net_set_hash(skb, rxd);
+
+		/* Pad small frames to minimum */
+		if (skb_put_padto(skb, 60))
+			break;
+
+		/* Stats update */
+		u64_stats_update_begin(&r_vec->rx_sync);
+		r_vec->rx_pkts++;
+		r_vec->rx_bytes += skb->len;
+		u64_stats_update_end(&r_vec->rx_sync);
+
+		skb_record_rx_queue(skb, rx_ring->idx);
+		skb->protocol = eth_type_trans(skb, nn->netdev);
+
+		nfp_net_rx_csum(nn, r_vec, rxd, skb);
+
+		if (rxd->rxd.flags & PCIE_DESC_RX_VLAN)
+			__vlan_hwaccel_put_tag(skb, htons(ETH_P_8021Q),
+					       le16_to_cpu(rxd->rxd.vlan));
+
+		napi_gro_receive(&rx_ring->r_vec->napi, skb);
+
+		/* Clear internal state to be on the safe side */
+		rx_ring->rxbufs[idx].skb = NULL;
+		rx_ring->rxbufs[idx].dma_addr = 0;
+		memset(&rx_ring->rxds[idx], 0, sizeof(rx_ring->rxds[idx]));
+
+		rx_ring->rd_p++;
+		pkts_polled++;
+		avail--;
+	}
+
+	if (nn->is_nfp3200)
+		nfp_qcp_rd_ptr_add(rx_ring->qcp_rx, pkts_polled);
+
+	return pkts_polled;
+}
+
+/**
+ * nfp_net_rx_freelist_alloc_one() - Allocate, map and write descriptors
+ * @rx_ring: RX add the buffer to
+ *
+ * This function will allcate a new skb, map it for DMA and write HW and SW
+ * descriptors.  It will, however, *not* give the buffer to HW.
+ */
+static int nfp_net_rx_freelist_alloc_one(struct nfp_net_rx_ring *rx_ring)
+{
+	struct nfp_net *nn = rx_ring->r_vec->nfp_net;
+	struct nfp_net_rx_desc *rxd;
+	struct sk_buff *skb;
+	dma_addr_t dma_addr;
+	int wr_idx;
+
+	skb = netdev_alloc_skb(nn->netdev, nn->fl_bufsz);
+	if (!skb) {
+		nn_warn_ratelimit(nn, "Failed to alloc receive SKB\n");
+		return -ENOMEM;
+	}
+
+	dma_addr = dma_map_single(&nn->pdev->dev, skb->data,
+				  nn->fl_bufsz, DMA_FROM_DEVICE);
+	if (dma_mapping_error(&nn->pdev->dev, dma_addr)) {
+		dev_kfree_skb_any(skb);
+		nn_warn_ratelimit(nn, "Failed to map DMA RX buffer\n");
+		return -ENOMEM;
+	}
+
+	wr_idx = rx_ring->wr_p % rx_ring->cnt;
+
+	/* Stash SKB and DMA address away */
+	rx_ring->rxbufs[wr_idx].skb = skb;
+	rx_ring->rxbufs[wr_idx].dma_addr = dma_addr;
+
+	/* Fill freelist descriptor */
+	rxd = &rx_ring->rxds[wr_idx];
+	rxd->fld.meta_len_dd = 0;
+	nfp_desc_set_dma_addr(&rxd->fld, dma_addr);
+	rx_ring->wr_p++;
+
+	return 0;
+}
+
+/**
+ * nfp_net_rx_fill_freelist() - Attempt filling freelist with RX buffers
+ * @rx_ring: RX ring to fill
+ *
+ * Try to fill as many buffers as possible into freelist.  Return
+ * number of buffers added.
+ *
+ * Return: Number of freelist buffers added.
+ */
+static int nfp_net_rx_fill_freelist(struct nfp_net_rx_ring *rx_ring)
+{
+	int added = 0;
+	int i;
+
+	while (nfp_net_rx_space(rx_ring) >= NFP_NET_FL_BATCH) {
+		for (i = 0; i < NFP_NET_FL_BATCH; i++) {
+			if (nfp_net_rx_freelist_alloc_one(rx_ring))
+				break;
+		}
+
+		/* Update write pointer of the freelist queue. Make
+		 * sure all writes are flushed before telling the hardware.
+		 */
+		wmb();
+		nfp_qcp_wr_ptr_add(rx_ring->qcp_fl, i);
+		added += i;
+
+		/* stop on error */
+		if (i < NFP_NET_FL_BATCH)
+			break;
+	}
+
+	return added;
+}
+
+/**
+ * nfp_net_rx_flush() - Free any buffers currently on the RX ring
+ * @rx_ring:  RX ring to remove buffers from
+ *
+ * Assumes that the device is stopped
+ */
+static void nfp_net_rx_flush(struct nfp_net_rx_ring *rx_ring)
+{
+	struct nfp_net *nn = rx_ring->r_vec->nfp_net;
+	struct pci_dev *pdev = nn->pdev;
+	int idx;
+
+	while (rx_ring->rd_p != rx_ring->wr_p) {
+		idx = rx_ring->rd_p % rx_ring->cnt;
+
+		if (rx_ring->rxbufs[idx].skb) {
+			dma_unmap_single(&pdev->dev,
+					 rx_ring->rxbufs[idx].dma_addr,
+					 nn->fl_bufsz, DMA_FROM_DEVICE);
+			dev_kfree_skb_any(rx_ring->rxbufs[idx].skb);
+			rx_ring->rxbufs[idx].dma_addr = 0;
+			rx_ring->rxbufs[idx].skb = NULL;
+		}
+
+		memset(&rx_ring->rxds[idx], 0, sizeof(rx_ring->rxds[idx]));
+
+		rx_ring->rd_p++;
+	}
+}
+
+/**
+ * nfp_net_poll() - napi poll function
+ * @napi:    NAPI structure
+ * @budget:  NAPI budget
+ *
+ * Return: 0 if done with polling.
+ */
+static int nfp_net_poll(struct napi_struct *napi, int budget)
+{
+	struct nfp_net_r_vector *r_vec =
+		container_of(napi, struct nfp_net_r_vector, napi);
+	struct nfp_net_rx_ring *rx_ring = r_vec->rx_ring;
+	struct nfp_net_tx_ring *tx_ring = r_vec->tx_ring;
+	struct nfp_net *nn = r_vec->nfp_net;
+	struct netdev_queue *txq;
+	bool complete = true;
+	int pkts_completed;
+	int pkts_polled;
+
+	/* Handle completed TX. If the TX queue was stopped, re-enable it */
+	tx_ring = &nn->tx_rings[rx_ring->idx];
+	txq = netdev_get_tx_queue(nn->netdev, tx_ring->idx);
+
+	pkts_completed = nfp_net_tx_complete(tx_ring);
+	if (pkts_completed)
+		complete = false;
+
+	/* Receive any packets */
+	pkts_polled = nfp_net_rx(rx_ring, budget);
+	if (pkts_polled)
+		complete = false;
+
+	/* refill freelist  */
+	nfp_net_rx_fill_freelist(rx_ring);
+
+	if (!complete)
+		return budget;
+
+	/* If there are no more packets to receive and no more TX
+	 * descriptors to be cleaned, unmask the MSI-X vector and
+	 * switch NAPI back into interrupt mode.
+	 */
+	napi_complete_done(napi, pkts_polled);
+
+	nfp_net_irq_unmask(nn, r_vec->irq_idx);
+
+	return pkts_polled;
+}
+
+/* Setup and Configuration
+ */
+
+/**
+ * nfp_net_tx_ring_free() - Free resources allocated to a TX ring
+ * @tx_ring:   TX ring to free
+ */
+static void nfp_net_tx_ring_free(struct nfp_net_tx_ring *tx_ring)
+{
+	struct nfp_net_r_vector *r_vec = tx_ring->r_vec;
+	struct nfp_net *nn = r_vec->nfp_net;
+	struct pci_dev *pdev = nn->pdev;
+
+	nn_writeq(nn, NFP_NET_CFG_TXR_ADDR(tx_ring->idx), 0);
+	nn_writeb(nn, NFP_NET_CFG_TXR_SZ(tx_ring->idx), 0);
+	nn_writeb(nn, NFP_NET_CFG_TXR_VEC(tx_ring->idx), 0);
+
+	kfree(tx_ring->txbufs);
+
+	if (tx_ring->txds)
+		dma_free_coherent(&pdev->dev, tx_ring->size,
+				  tx_ring->txds, tx_ring->dma);
+
+	tx_ring->cnt = 0;
+	tx_ring->wr_p = 0;
+	tx_ring->rd_p = 0;
+	tx_ring->qcp_rd_p = 0;
+
+	tx_ring->txbufs = NULL;
+	tx_ring->txds = NULL;
+	tx_ring->dma = 0;
+	tx_ring->size = 0;
+}
+
+/**
+ * nfp_net_tx_ring_alloc() - Allocate resource for a TX ring
+ * @tx_ring:   TX Ring structure to allocate
+ *
+ * Return: 0 on success, negative errno otherwise.
+ */
+static int nfp_net_tx_ring_alloc(struct nfp_net_tx_ring *tx_ring)
+{
+	struct nfp_net_r_vector *r_vec = tx_ring->r_vec;
+	struct nfp_net *nn = r_vec->nfp_net;
+	struct pci_dev *pdev = nn->pdev;
+	int err, sz;
+
+	tx_ring->cnt = nn->txd_cnt;
+
+	tx_ring->size = sizeof(*tx_ring->txds) * tx_ring->cnt;
+	tx_ring->txds = dma_zalloc_coherent(&pdev->dev, tx_ring->size,
+					    &tx_ring->dma, GFP_KERNEL);
+	if (!tx_ring->txds) {
+		err = -ENOMEM;
+		goto err_alloc;
+	}
+
+	sz = sizeof(*tx_ring->txbufs) * tx_ring->cnt;
+	tx_ring->txbufs = kzalloc(sz, GFP_KERNEL);
+	if (!tx_ring->txbufs) {
+		err = -ENOMEM;
+		goto err_alloc;
+	}
+
+	/* Write the DMA address, size and MSI-X info to the device */
+	nn_writeq(nn, NFP_NET_CFG_TXR_ADDR(tx_ring->idx), tx_ring->dma);
+	nn_writeb(nn, NFP_NET_CFG_TXR_SZ(tx_ring->idx), ilog2(tx_ring->cnt));
+	nn_writeb(nn, NFP_NET_CFG_TXR_VEC(tx_ring->idx), r_vec->irq_idx);
+
+	netif_set_xps_queue(nn->netdev, &r_vec->affinity_mask, tx_ring->idx);
+
+	nn_dbg(nn, "TxQ%02d: QCidx=%02d cnt=%d dma=%#llx host=%p\n",
+	       tx_ring->idx, tx_ring->qcidx,
+	       tx_ring->cnt, (unsigned long long)tx_ring->dma, tx_ring->txds);
+
+	return 0;
+
+err_alloc:
+	nfp_net_tx_ring_free(tx_ring);
+	return err;
+}
+
+/**
+ * nfp_net_rx_ring_free() - Free resources allocated to a RX ring
+ * @rx_ring:  RX ring to free
+ */
+static void nfp_net_rx_ring_free(struct nfp_net_rx_ring *rx_ring)
+{
+	struct nfp_net_r_vector *r_vec = rx_ring->r_vec;
+	struct nfp_net *nn = r_vec->nfp_net;
+	struct pci_dev *pdev = nn->pdev;
+
+	nn_writeq(nn, NFP_NET_CFG_RXR_ADDR(rx_ring->idx), 0);
+	nn_writeb(nn, NFP_NET_CFG_RXR_SZ(rx_ring->idx), 0);
+	nn_writeb(nn, NFP_NET_CFG_RXR_VEC(rx_ring->idx), 0);
+
+	kfree(rx_ring->rxbufs);
+
+	if (rx_ring->rxds)
+		dma_free_coherent(&pdev->dev, rx_ring->size,
+				  rx_ring->rxds, rx_ring->dma);
+
+	rx_ring->cnt = 0;
+	rx_ring->wr_p = 0;
+	rx_ring->rd_p = 0;
+
+	rx_ring->rxbufs = NULL;
+	rx_ring->rxds = NULL;
+	rx_ring->dma = 0;
+	rx_ring->size = 0;
+}
+
+/**
+ * nfp_net_rx_ring_alloc() - Allocate resource for a RX ring
+ * @rx_ring:  RX ring to allocate
+ *
+ * Return: 0 on success, negative errno otherwise.
+ */
+static int nfp_net_rx_ring_alloc(struct nfp_net_rx_ring *rx_ring)
+{
+	struct nfp_net_r_vector *r_vec = rx_ring->r_vec;
+	struct nfp_net *nn = r_vec->nfp_net;
+	struct pci_dev *pdev = nn->pdev;
+	int err, sz;
+
+	rx_ring->cnt = nn->rxd_cnt;
+
+	rx_ring->size = sizeof(*rx_ring->rxds) * rx_ring->cnt;
+	rx_ring->rxds = dma_zalloc_coherent(&pdev->dev, rx_ring->size,
+					    &rx_ring->dma, GFP_KERNEL);
+	if (!rx_ring->rxds) {
+		err = -ENOMEM;
+		goto err_alloc;
+	}
+
+	sz = sizeof(*rx_ring->rxbufs) * rx_ring->cnt;
+	rx_ring->rxbufs = kzalloc(sz, GFP_KERNEL);
+	if (!rx_ring->rxbufs) {
+		err = -ENOMEM;
+		goto err_alloc;
+	}
+
+	/* Write the DMA address, size and MSI-X info to the device */
+	nn_writeq(nn, NFP_NET_CFG_RXR_ADDR(rx_ring->idx), rx_ring->dma);
+	nn_writeb(nn, NFP_NET_CFG_RXR_SZ(rx_ring->idx), ilog2(rx_ring->cnt));
+	nn_writeb(nn, NFP_NET_CFG_RXR_VEC(rx_ring->idx), r_vec->irq_idx);
+
+	nn_dbg(nn, "RxQ%02d: FlQCidx=%02d RxQCidx=%02d cnt=%d dma=%#llx host=%p\n",
+	       rx_ring->idx, rx_ring->fl_qcidx, rx_ring->rx_qcidx,
+	       rx_ring->cnt, (unsigned long long)rx_ring->dma, rx_ring->rxds);
+
+	return 0;
+
+err_alloc:
+	nfp_net_rx_ring_free(rx_ring);
+	return err;
+}
+
+/**
+ * nfp_net_alloc_resources() - Allocate resources for RX and TX rings
+ * @nn:      NFP Net device to reconfigure
+ *
+ * Return: 0 on success or negative errno on error.
+ */
+static int nfp_net_alloc_resources(struct nfp_net *nn)
+{
+	struct nfp_net_r_vector *r_vec;
+	struct msix_entry *entry;
+	int err;
+	int r;
+
+	for (r = 0; r < nn->num_r_vecs; r++) {
+		r_vec = &nn->r_vecs[r];
+
+		clear_bit(NFP_NET_RVEC_NAPI_STARTED, &r_vec->flags);
+
+		/* Setup NAPI */
+		netif_napi_add(nn->netdev, &r_vec->napi,
+			       nfp_net_poll, NFP_NET_NAPI_WEIGHT);
+
+		entry = &nn->irq_entries[r_vec->irq_idx];
+
+		snprintf(r_vec->name, sizeof(r_vec->name),
+			 "%s-rxtx-%d", nn->netdev->name, r);
+		err = request_irq(entry->vector, r_vec->handler, 0,
+				  r_vec->name, r_vec);
+		if (err) {
+			nn_dbg(nn, "Error requesting IRQ %d\n", entry->vector);
+			goto err_alloc;
+		}
+
+		r_vec->requested = 1;
+
+		irq_set_affinity_hint(entry->vector, &r_vec->affinity_mask);
+
+		nn_dbg(nn, "RV%02d: irq=%03d/%03d\n",
+		       r, entry->vector, entry->entry);
+
+		/* Allocate TX ring resources */
+		if (r_vec->tx_ring) {
+			err = nfp_net_tx_ring_alloc(r_vec->tx_ring);
+			if (err)
+				goto err_alloc;
+		}
+
+		/* Allocate RX ring resources */
+		if (r_vec->rx_ring) {
+			err = nfp_net_rx_ring_alloc(r_vec->rx_ring);
+			if (err)
+				goto err_alloc;
+		}
+	}
+
+	return 0;
+
+err_alloc:
+	while (r--) {
+		r_vec =  &nn->r_vecs[r];
+
+		if (r_vec->rx_ring)
+			nfp_net_rx_ring_free(r_vec->rx_ring);
+		if (r_vec->tx_ring)
+			nfp_net_tx_ring_free(r_vec->tx_ring);
+
+		if (r_vec->requested) {
+			entry = &nn->irq_entries[r_vec->irq_idx];
+			irq_set_affinity_hint(entry->vector, NULL);
+			free_irq(entry->vector, r_vec);
+			r_vec->requested = 0;
+		}
+		netif_napi_del(&r_vec->napi);
+	}
+	return err;
+}
+
+/**
+ * nfp_net_free_resources() - Free all resources
+ * @nn:      NFP Net device to reconfigure
+ */
+static void nfp_net_free_resources(struct nfp_net *nn)
+{
+	struct nfp_net_r_vector *r_vec;
+	struct msix_entry *entry;
+	int i;
+
+	for (i = 0; i < nn->num_r_vecs; i++) {
+		r_vec = &nn->r_vecs[i];
+		entry = &nn->irq_entries[r_vec->irq_idx];
+
+		if (r_vec->rx_ring)
+			nfp_net_rx_ring_free(r_vec->rx_ring);
+		if (r_vec->tx_ring)
+			nfp_net_tx_ring_free(r_vec->tx_ring);
+
+		if (r_vec->requested) {
+			irq_set_affinity_hint(entry->vector, NULL);
+			synchronize_irq(entry->vector);
+			free_irq(entry->vector, r_vec);
+			r_vec->requested = 0;
+		}
+
+		netif_napi_del(&r_vec->napi);
+	}
+}
+
+/**
+ * nfp_net_rss_write_itbl() - Write RSS indirection table to device
+ * @nn:      NFP Net device to reconfigure
+ */
+void nfp_net_rss_write_itbl(struct nfp_net *nn)
+{
+	u32 val;
+	int i, j;
+
+	for (i = 0, j = 0; i < NFP_NET_CFG_RSS_ITBL_SZ; i += 4) {
+		val = nn->rss_itbl[j++];
+		val |= nn->rss_itbl[j++] << 8;
+		val |= nn->rss_itbl[j++] << 16;
+		val |= nn->rss_itbl[j++] << 24;
+
+		nn_writel(nn, NFP_NET_CFG_RSS_ITBL + i, val);
+	}
+}
+
+/**
+ * nfp_net_coalesce_write_cfg() - Write irq coalescence configuration to HW
+ * @nn:      NFP Net device to reconfigure
+ */
+void nfp_net_coalesce_write_cfg(struct nfp_net *nn)
+{
+	u8 i;
+	u32 factor;
+	u32 value;
+
+	/* Compute factor used to convert coalesce '_usecs' parameters to
+	 * ME timestamp ticks.  There are 16 ME clock cycles for each timestamp
+	 * count.
+	 */
+	factor = nn->me_freq_mhz / 16;
+
+	/* copy RX interrupt coalesce parameters */
+	value = (nn->rx_coalesce_max_frames << 16) |
+		(factor * nn->rx_coalesce_usecs);
+	for (i = 0; i < nn->num_r_vecs; i++)
+		nn_writel(nn, NFP_NET_CFG_RXR_IRQ_MOD(i), value);
+
+	/* copy TX interrupt coalesce parameters */
+	value = (nn->tx_coalesce_max_frames << 16) |
+		(factor * nn->tx_coalesce_usecs);
+	for (i = 0; i < nn->num_r_vecs; i++)
+		nn_writel(nn, NFP_NET_CFG_TXR_IRQ_MOD(i), value);
+}
+
+/**
+ * nfp_net_write_mac_addr() - Write mac address to device registers
+ * @nn:      NFP Net device to reconfigure
+ * @mac:     Six-byte MAC address to be written
+ *
+ * We do a bit of byte swapping dance because firmware is LE.
+ */
+static void nfp_net_write_mac_addr(struct nfp_net *nn, const u8 *mac)
+{
+	nn_writel(nn, NFP_NET_CFG_MACADDR + 0,
+		  get_unaligned_be32(nn->netdev->dev_addr));
+	/* We can't do writew for NFP-3200 compatibility */
+	nn_writel(nn, NFP_NET_CFG_MACADDR + 4,
+		  get_unaligned_be16(nn->netdev->dev_addr + 4) << 16);
+}
+
+static int nfp_net_netdev_open(struct net_device *netdev)
+{
+	struct nfp_net *nn = netdev_priv(netdev);
+	int err, n, i, r;
+	u32 update = 0;
+	u32 new_ctrl;
+	u32 rss_cfg;
+	u32 sts;
+
+	if (nn->ctrl & NFP_NET_CFG_CTRL_ENABLE) {
+		nn_err(nn, "Dev is already enabled: 0x%08x\n", nn->ctrl);
+		return -EBUSY;
+	}
+
+	netif_carrier_off(netdev);
+
+	new_ctrl = nn->ctrl;
+
+	/* Step 1: Allocate resources for rings and the like
+	 * - Request interrupts
+	 * - Allocate RX and TX ring resources
+	 * - Setup initial RSS table
+	 */
+	err = nfp_net_irqs_request(netdev);
+	if (err)
+		return err;
+
+	err = nfp_net_alloc_resources(nn);
+	if (err)
+		goto err_alloc_rings;
+
+	err = netif_set_real_num_tx_queues(netdev, nn->num_tx_rings);
+	if (err)
+		goto err_set_queues;
+
+	err = netif_set_real_num_rx_queues(netdev, nn->num_rx_rings);
+	if (err)
+		goto err_set_queues;
+
+	if (nn->cap & NFP_NET_CFG_CTRL_RSS) {
+		for (i = 0; i < sizeof(nn->rss_itbl); i++)
+			nn->rss_itbl[i] =
+				ethtool_rxfh_indir_default(i, nn->num_rx_rings);
+		nfp_net_rss_write_itbl(nn);
+
+		new_ctrl |= NFP_NET_CFG_CTRL_RSS;
+
+		/* Enable IPv4/IPv6 TCP by default */
+		rss_cfg = NFP_NET_CFG_RSS_IPV4_TCP |
+			NFP_NET_CFG_RSS_IPV6_TCP |
+			NFP_NET_CFG_RSS_TOEPLITZ |
+			NFP_NET_CFG_RSS_MASK;
+		writel(rss_cfg, nn->ctrl_bar + NFP_NET_CFG_RSS_CTRL);
+		update |= NFP_NET_CFG_UPDATE_RSS;
+	}
+
+	if (nn->pdev->msix_enabled && (nn->cap & NFP_NET_CFG_CTRL_IRQMOD)) {
+		/* defaults correspond to no IRQ moderation */
+		nn->rx_coalesce_usecs      = 0;
+		nn->rx_coalesce_max_frames = 1;
+		nn->tx_coalesce_usecs      = 0;
+		nn->tx_coalesce_max_frames = 1;
+
+		/* write configuration to device */
+		nfp_net_coalesce_write_cfg(nn);
+
+		new_ctrl |= NFP_NET_CFG_CTRL_IRQMOD;
+		update |= NFP_NET_CFG_UPDATE_IRQMOD;
+	}
+
+	/* Step 2: Configure the NFP
+	 * - Enable rings from 0 to tx_rings/rx_rings - 1.
+	 * - Write MAC address (in case it changed)
+	 * - Set the MTU
+	 * - Set the Freelist buffer size
+	 * - Enable the FW
+	 */
+	nn_writeq(nn, NFP_NET_CFG_TXRS_ENABLE, nn->num_tx_rings == 64 ?
+		  0xffffffffffffffffULL : ((u64)1 << nn->num_tx_rings) - 1);
+
+	nn_writeq(nn, NFP_NET_CFG_RXRS_ENABLE, nn->num_rx_rings == 64 ?
+		  0xffffffffffffffffULL : ((u64)1 << nn->num_rx_rings) - 1);
+
+	nfp_net_write_mac_addr(nn, netdev->dev_addr);
+
+	nn_writel(nn, NFP_NET_CFG_MTU, netdev->mtu);
+	nn_writel(nn, NFP_NET_CFG_FLBUFSZ, nn->fl_bufsz);
+
+	/* Enable device */
+	new_ctrl |= NFP_NET_CFG_CTRL_ENABLE;
+	update |= NFP_NET_CFG_UPDATE_GEN;
+	update |= NFP_NET_CFG_UPDATE_RING;
+	if (nn->cap & NFP_NET_CFG_CTRL_RINGCFG)
+		new_ctrl |= NFP_NET_CFG_CTRL_RINGCFG;
+
+	if (nn->pdev->msix_enabled)
+		update |= NFP_NET_CFG_UPDATE_MSIX;
+
+	if (nn->rss_cfg)
+		update |= NFP_NET_CFG_UPDATE_RSS;
+
+	nn_writel(nn, NFP_NET_CFG_CTRL, new_ctrl);
+	err = nfp_net_reconfig(nn, update);
+	if (err)
+		goto err_reconfig;
+
+	nn->ctrl = new_ctrl;
+
+	/* Step 3: Enable for kernel
+	 * - put some freelist descriptors on each RX ring
+	 * - enable NAPI on each ring
+	 * - enable all TX queues
+	 * - set link state
+	 */
+	for (r = 0; r < nn->num_r_vecs; r++) {
+		struct nfp_net_r_vector *r_vec = &nn->r_vecs[r];
+
+		/* Because we don't have any "RX enable bit" as soon as we give
+		 * FW buffers it can start consuming them.  Add to that the IRQ
+		 * automasking feature and we can deadlock the RX - FW may
+		 * consume all the buffers before we can take interrupts.
+		 *
+		 * As a workaround we set 32 buffers aside - we put them on the
+		 * ring just don't increment the ring count for FW.  We can then
+		 * give them to FW once IRQs are fully ready without risking any
+		 * races with IRQ/napi handlers.
+		 * We need at least 32 buffers because thats the batch size
+		 * in which FW consumes them.
+		 */
+		for (i = 0; i < 32; i++)
+			if (nfp_net_rx_freelist_alloc_one(r_vec->rx_ring))
+				goto err_reconfig;
+
+		n = nfp_net_rx_fill_freelist(r_vec->rx_ring);
+		nn_dbg(nn, "RV%02d RxQ%02d: Added %d freelist buffers\n",
+		       r, r_vec->rx_ring->idx, n + 1);
+
+		napi_enable(&r_vec->napi);
+		set_bit(NFP_NET_RVEC_NAPI_STARTED, &r_vec->flags);
+	}
+
+	netif_tx_wake_all_queues(netdev);
+
+	/* Now we are fully set up - unmask IRQs and release extra buffers */
+	for (r = 0; r < nn->num_r_vecs; r++)
+		nfp_net_irq_unmask(nn, nn->r_vecs[r].irq_idx);
+	msleep(1);
+	for (r = 0; r < nn->num_r_vecs; r++)
+		nfp_qcp_wr_ptr_add(nn->r_vecs[r].rx_ring->qcp_fl, 32);
+
+	sts = nn_readl(nn, NFP_NET_CFG_STS);
+	nn->link_up = !!(sts & NFP_NET_CFG_STS_LINK);
+	if (nn->link_up) {
+		nfp_net_print_link(nn, true);
+		netif_carrier_on(netdev);
+	} else {
+		nfp_net_print_link(nn, false);
+	}
+
+	return 0;
+
+err_reconfig:
+	/* Could clean up some of the cfg BAR settings here */
+err_set_queues:
+	nfp_net_free_resources(nn);
+err_alloc_rings:
+	nfp_net_irqs_free(netdev);
+	return err;
+}
+
+/**
+ * nfp_net_netdev_close() - Called when the device is downed
+ * @netdev:      netdev structure
+ */
+static int nfp_net_netdev_close(struct net_device *netdev)
+{
+	struct nfp_net *nn = netdev_priv(netdev);
+	unsigned int new_ctrl, update;
+	int err, r, i;
+
+	if (!(nn->ctrl & NFP_NET_CFG_CTRL_ENABLE)) {
+		nn_err(nn, "Dev is not up: 0x%08x\n", nn->ctrl);
+		return 0;
+	}
+
+	/* Step 1: Disable RX and TX rings from the Linux kernel perspective
+	 */
+	netif_carrier_off(netdev);
+
+	for (r = 0; r < nn->num_r_vecs; r++) {
+		clear_bit(NFP_NET_RVEC_NAPI_STARTED, &nn->r_vecs[r].flags);
+		napi_disable(&nn->r_vecs[r].napi);
+	}
+
+	netif_tx_disable(netdev);
+
+	/* Step 2: Tell NFP
+	 */
+	new_ctrl = nn->ctrl;
+	new_ctrl &= ~NFP_NET_CFG_CTRL_ENABLE;
+	update = NFP_NET_CFG_UPDATE_GEN;
+	update |= NFP_NET_CFG_UPDATE_RING;
+	if (nn->pdev->msix_enabled)
+		update |= NFP_NET_CFG_UPDATE_MSIX;
+
+	if (nn->cap & NFP_NET_CFG_CTRL_RINGCFG)
+		new_ctrl &= ~NFP_NET_CFG_CTRL_RINGCFG;
+
+	nn_writeq(nn, NFP_NET_CFG_TXRS_ENABLE, 0);
+	nn_writeq(nn, NFP_NET_CFG_RXRS_ENABLE, 0);
+
+	/* Step 3: Notify NFP
+	 */
+	nn_writel(nn, NFP_NET_CFG_CTRL, new_ctrl);
+	err = nfp_net_reconfig(nn, update);
+	if (err)
+		return err;
+
+	nn->ctrl = new_ctrl;
+
+	/* Step 4: Free resources
+	 */
+	for (i = 0; i < nn->num_r_vecs; i++) {
+		nfp_net_rx_flush(nn->r_vecs[i].rx_ring);
+		nfp_net_tx_flush(nn->r_vecs[i].tx_ring);
+	}
+
+	nfp_net_free_resources(nn);
+	nfp_net_irqs_free(netdev);
+
+	nn_dbg(nn, "%s down", netdev->name);
+	return 0;
+}
+
+static void nfp_net_set_rx_mode(struct net_device *netdev)
+{
+	struct nfp_net *nn = netdev_priv(netdev);
+	u32 new_ctrl, update;
+
+	if (netdev->flags & IFF_PROMISC &&
+	    !(nn->cap & NFP_NET_CFG_CTRL_PROMISC)) {
+		nn_warn(nn, "FW does not support promiscuous mode");
+		return;
+	}
+
+	new_ctrl = nn->ctrl;
+
+	if (netdev->flags & IFF_PROMISC) {
+		if (!(nn->cap & NFP_NET_CFG_CTRL_PROMISC)) {
+			nn_warn(nn, "FW does not support promiscuous mode");
+			return;
+		}
+		new_ctrl |= NFP_NET_CFG_CTRL_PROMISC;
+	} else {
+		new_ctrl &= ~NFP_NET_CFG_CTRL_PROMISC;
+	}
+
+	if (netdev->flags & IFF_ALLMULTI) {
+		if (!(nn->cap & NFP_NET_CFG_CTRL_L2MC))
+			nn_warn(nn, "FW does not support ALLMULTI");
+		else
+			new_ctrl |= NFP_NET_CFG_CTRL_L2MC;
+	} else {
+		new_ctrl &= ~NFP_NET_CFG_CTRL_L2MC;
+	}
+
+	if (new_ctrl != nn->ctrl) {
+		update = NFP_NET_CFG_UPDATE_GEN;
+		nn_writel(nn, NFP_NET_CFG_CTRL, new_ctrl);
+		nfp_net_reconfig(nn, update);
+		nn->ctrl = new_ctrl;
+	}
+}
+
+static int nfp_net_change_mtu(struct net_device *netdev, int new_mtu)
+{
+	struct nfp_net *nn = netdev_priv(netdev);
+	u32 tmp;
+
+	nn_dbg(nn, "New MTU = %d", new_mtu);
+
+	if (new_mtu < 68 || new_mtu > nn->max_mtu) {
+		nn_err(nn, "New MTU (%d) is not valid\n", new_mtu);
+		return -EINVAL;
+	}
+
+	netdev->mtu = new_mtu;
+
+	/* Freelist buffer size rounded up to the nearest 1K */
+	tmp = new_mtu + ETH_HLEN + VLAN_HLEN + NFP_NET_MAX_PREPEND;
+	nn->fl_bufsz = roundup(tmp, 1024);
+
+	/* restart if running */
+	if (netif_running(netdev)) {
+		nfp_net_netdev_close(netdev);
+		nfp_net_netdev_open(netdev);
+	}
+
+	return 0;
+}
+
+static struct rtnl_link_stats64 *nfp_net_stat64(struct net_device *netdev,
+						struct rtnl_link_stats64 *stats)
+{
+	struct nfp_net *nn = netdev_priv(netdev);
+	int i;
+
+	for (i = 0; i < nn->num_r_vecs; i++) {
+		struct nfp_net_r_vector *r_vec = &nn->r_vecs[i];
+		u64 data[3];
+		unsigned int start;
+
+		do {
+			start = u64_stats_fetch_begin(&r_vec->rx_sync);
+			data[0] = r_vec->rx_pkts;
+			data[1] = r_vec->rx_bytes;
+		} while (u64_stats_fetch_retry(&r_vec->rx_sync, start));
+		stats->rx_packets += data[0];
+		stats->rx_bytes += data[1];
+
+		do {
+			start = u64_stats_fetch_begin(&r_vec->tx_sync);
+			data[0] = r_vec->tx_pkts;
+			data[1] = r_vec->tx_bytes;
+			data[2] = r_vec->tx_errors;
+		} while (u64_stats_fetch_retry(&r_vec->tx_sync, start));
+		stats->tx_packets += data[0];
+		stats->tx_bytes += data[1];
+		stats->tx_errors += data[2];
+	}
+
+	return stats;
+}
+
+static int nfp_net_set_features(struct net_device *netdev,
+				netdev_features_t features)
+{
+	netdev_features_t changed = netdev->features ^ features;
+	struct nfp_net *nn = netdev_priv(netdev);
+	u32 new_ctrl, update;
+	int err;
+
+	/* Assume this is not called with features we have not advertised */
+
+	new_ctrl = nn->ctrl;
+
+	if (changed & NETIF_F_RXCSUM) {
+		if (features & NETIF_F_RXCSUM)
+			new_ctrl |= NFP_NET_CFG_CTRL_RXCSUM;
+		else
+			new_ctrl &= ~NFP_NET_CFG_CTRL_RXCSUM;
+	}
+
+	if (changed & (NETIF_F_IP_CSUM | NETIF_F_IPV6_CSUM)) {
+		if (features & (NETIF_F_IP_CSUM | NETIF_F_IPV6_CSUM))
+			new_ctrl |= NFP_NET_CFG_CTRL_TXCSUM;
+		else
+			new_ctrl &= ~NFP_NET_CFG_CTRL_TXCSUM;
+	}
+
+	if (changed & (NETIF_F_TSO | NETIF_F_TSO6)) {
+		if (features & (NETIF_F_TSO | NETIF_F_TSO6))
+			new_ctrl |= NFP_NET_CFG_CTRL_LSO;
+		else
+			new_ctrl &= ~NFP_NET_CFG_CTRL_LSO;
+	}
+
+	if (changed & (NETIF_F_RXHASH | NETIF_F_NTUPLE)) {
+		if (features & (NETIF_F_RXHASH | NETIF_F_NTUPLE))
+			new_ctrl |= NFP_NET_CFG_CTRL_RSS;
+		else
+			new_ctrl &= ~NFP_NET_CFG_CTRL_RSS;
+	}
+
+	if (changed & NETIF_F_HW_VLAN_CTAG_RX) {
+		if (features & NETIF_F_HW_VLAN_CTAG_RX)
+			new_ctrl |= NFP_NET_CFG_CTRL_RXVLAN;
+		else
+			new_ctrl &= ~NFP_NET_CFG_CTRL_RXVLAN;
+	}
+
+	if (changed & NETIF_F_HW_VLAN_CTAG_TX) {
+		if (features & NETIF_F_HW_VLAN_CTAG_TX)
+			new_ctrl |= NFP_NET_CFG_CTRL_TXVLAN;
+		else
+			new_ctrl &= ~NFP_NET_CFG_CTRL_TXVLAN;
+	}
+
+	if (changed & NETIF_F_SG) {
+		if (features & NETIF_F_SG)
+			new_ctrl |= NFP_NET_CFG_CTRL_GATHER;
+		else
+			new_ctrl &= ~NFP_NET_CFG_CTRL_GATHER;
+	}
+
+	nn_dbg(nn, "Feature change 0x%llx -> 0x%llx (changed=0x%llx)\n",
+	       (long long)netdev->features, (long long)features,
+	       (long long)changed);
+
+	if (new_ctrl != nn->ctrl) {
+		nn_dbg(nn, "NIC ctrl: 0x%x -> 0x%x", nn->ctrl, new_ctrl);
+		update = NFP_NET_CFG_UPDATE_GEN;
+		nn_writel(nn, NFP_NET_CFG_CTRL, new_ctrl);
+		err = nfp_net_reconfig(nn, update);
+		if (err)
+			return err;
+		nn->ctrl = new_ctrl;
+	}
+
+	netdev->features = features;
+
+	return 0;
+}
+
+static netdev_features_t
+nfp_net_features_check(struct sk_buff *skb, struct net_device *dev,
+		       netdev_features_t features)
+{
+	u8 l4_hdr;
+
+	/* We can't do TSO over double tagged packets (802.1AD) */
+	features &= vlan_features_check(skb, features);
+
+	if (!skb->encapsulation)
+		return features;
+
+	/* Ensure that inner L4 header offset fits into TX descriptor field */
+	if (skb_is_gso(skb)) {
+		u32 hdrlen;
+
+		hdrlen = skb_inner_transport_header(skb) - skb->data +
+			inner_tcp_hdrlen(skb);
+
+		if (unlikely(hdrlen > NFP_NET_LSO_MAX_HDR_SZ))
+			features &= ~NETIF_F_GSO_MASK;
+	}
+
+	/* VXLAN/GRE check */
+	switch (vlan_get_protocol(skb)) {
+	case htons(ETH_P_IP):
+		l4_hdr = ip_hdr(skb)->protocol;
+		break;
+	case htons(ETH_P_IPV6):
+		l4_hdr = ipv6_hdr(skb)->nexthdr;
+		break;
+	default:
+		return features & ~(NETIF_F_ALL_CSUM | NETIF_F_GSO_MASK);
+	}
+
+	if (skb->inner_protocol_type != ENCAP_TYPE_ETHER ||
+	    skb->inner_protocol != htons(ETH_P_TEB) ||
+	    (l4_hdr != IPPROTO_UDP && l4_hdr != IPPROTO_GRE) ||
+	    (l4_hdr == IPPROTO_UDP &&
+	     (skb_inner_mac_header(skb) - skb_transport_header(skb) !=
+	      sizeof(struct udphdr) + sizeof(struct vxlanhdr))))
+		return features & ~(NETIF_F_ALL_CSUM | NETIF_F_GSO_MASK);
+
+	return features;
+}
+
+/**
+ * nfp_net_set_vxlan_port() - set vxlan port in SW and HW
+ * @nn:   NFP Net device to reconfigure
+ * @idx:  Index into the port table where new port should be written
+ * @port: UDP port to configure (pass zero to remove VXLAN port)
+ */
+static void nfp_net_set_vxlan_port(struct nfp_net *nn, int idx, __be16 port)
+{
+	int i;
+
+	BUILD_BUG_ON(NFP_NET_N_VXLAN_PORTS & 1);
+
+	nn->vxlan_ports[idx] = port;
+
+	for (i = 0; i < NFP_NET_N_VXLAN_PORTS; i += 2)
+		nn_writel(nn, NFP_NET_CFG_VXLAN_PORT,
+			  be16_to_cpu(nn->vxlan_ports[i + 1]) << 16 |
+			  be16_to_cpu(nn->vxlan_ports[i]));
+
+	nfp_net_reconfig(nn, NFP_NET_CFG_UPDATE_VXLAN);
+}
+
+static void nfp_net_add_vxlan_port(struct net_device *netdev,
+				   sa_family_t sa_family, __be16 port)
+{
+	struct nfp_net *nn = netdev_priv(netdev);
+	int i, free_idx = -1;
+
+	for (i = 0; i < NFP_NET_N_VXLAN_PORTS; i++) {
+		if (nn->vxlan_ports[i] == port)
+			return;
+		if (!nn->vxlan_ports[i])
+			free_idx = i;
+	}
+
+	if (free_idx == -1)
+		return;
+
+	nfp_net_set_vxlan_port(nn, free_idx, port);
+}
+
+static void nfp_net_del_vxlan_port(struct net_device *netdev,
+				   sa_family_t sa_family, __be16 port)
+{
+	struct nfp_net *nn = netdev_priv(netdev);
+	int i;
+
+	for (i = 0; i < NFP_NET_N_VXLAN_PORTS; i++)
+		if (nn->vxlan_ports[i] == port)
+			nfp_net_set_vxlan_port(nn, i, 0);
+}
+
+static struct net_device_ops nfp_net_netdev_ops = {
+	.ndo_open		= nfp_net_netdev_open,
+	.ndo_stop		= nfp_net_netdev_close,
+	.ndo_start_xmit		= nfp_net_tx,
+	.ndo_get_stats64	= nfp_net_stat64,
+	.ndo_tx_timeout		= nfp_net_tx_timeout,
+	.ndo_set_rx_mode	= nfp_net_set_rx_mode,
+	.ndo_change_mtu		= nfp_net_change_mtu,
+	.ndo_set_mac_address	= eth_mac_addr,
+	.ndo_set_features	= nfp_net_set_features,
+	.ndo_features_check	= nfp_net_features_check,
+	.ndo_add_vxlan_port     = nfp_net_add_vxlan_port,
+	.ndo_del_vxlan_port     = nfp_net_del_vxlan_port,
+};
+
+/**
+ * nfp_net_info() - Print general info about the NIC
+ * @nn:      NFP Net device to reconfigure
+ */
+void nfp_net_info(struct nfp_net *nn)
+{
+	nn_info(nn, "Netronome %s %sNetdev: TxQs=%d/%d RxQs=%d/%d\n",
+		nn->is_nfp3200 ? "NFP-32xx" : "NFP-6xxx",
+		nn->is_vf ? "VF " : "",
+		nn->num_tx_rings, nn->max_tx_rings,
+		nn->num_rx_rings, nn->max_rx_rings);
+	nn_info(nn, "VER: %#x, Maximum supported MTU: %d\n",
+		nn->ver, nn->max_mtu);
+	nn_info(nn, "CAP: %#x %s%s%s%s%s%s%s%s%s%s%s%s%s%s%s%s\n",
+		nn->cap,
+		nn->cap & NFP_NET_CFG_CTRL_PROMISC  ? "PROMISC "  : "",
+		nn->cap & NFP_NET_CFG_CTRL_L2BC     ? "L2BCFILT " : "",
+		nn->cap & NFP_NET_CFG_CTRL_L2MC     ? "L2MCFILT " : "",
+		nn->cap & NFP_NET_CFG_CTRL_RXCSUM   ? "RXCSUM "   : "",
+		nn->cap & NFP_NET_CFG_CTRL_TXCSUM   ? "TXCSUM "   : "",
+		nn->cap & NFP_NET_CFG_CTRL_RXVLAN   ? "RXVLAN "   : "",
+		nn->cap & NFP_NET_CFG_CTRL_TXVLAN   ? "TXVLAN "   : "",
+		nn->cap & NFP_NET_CFG_CTRL_SCATTER  ? "SCATTER "  : "",
+		nn->cap & NFP_NET_CFG_CTRL_GATHER   ? "GATHER "   : "",
+		nn->cap & NFP_NET_CFG_CTRL_LSO      ? "TSO "      : "",
+		nn->cap & NFP_NET_CFG_CTRL_RSS      ? "RSS "      : "",
+		nn->cap & NFP_NET_CFG_CTRL_L2SWITCH ? "L2SWITCH " : "",
+		nn->cap & NFP_NET_CFG_CTRL_MSIXAUTO ? "AUTOMASK " : "",
+		nn->cap & NFP_NET_CFG_CTRL_IRQMOD   ? "IRQMOD "   : "",
+		nn->cap & NFP_NET_CFG_CTRL_VXLAN    ? "VXLAN "    : "",
+		nn->cap & NFP_NET_CFG_CTRL_NVGRE    ? "NVGRE "	  : "");
+}
+
+/**
+ * nfp_net_netdev_alloc() - Allocate netdev and related structure
+ * @pdev:         PCI device
+ * @max_tx_rings: Maximum number of TX rings supported by device
+ * @max_rx_rings: Maximum number of RX rings supported by device
+ *
+ * This function allocates a netdev device and fills in the initial
+ * part of the @struct nfp_net structure.
+ *
+ * Return: NFP Net device structure, or ERR_PTR on error.
+ */
+struct nfp_net *nfp_net_netdev_alloc(struct pci_dev *pdev,
+				     int max_tx_rings, int max_rx_rings)
+{
+	struct net_device *netdev;
+	struct nfp_net *nn;
+	int nqs;
+
+	netdev = alloc_etherdev_mqs(sizeof(struct nfp_net),
+				    max_tx_rings, max_rx_rings);
+	if (!netdev)
+		return ERR_PTR(-ENOMEM);
+
+	SET_NETDEV_DEV(netdev, &pdev->dev);
+	nn = netdev_priv(netdev);
+
+	nn->netdev = netdev;
+	nn->pdev = pdev;
+
+	nn->max_tx_rings = max_tx_rings;
+	nn->max_rx_rings = max_rx_rings;
+
+	nqs = netif_get_num_default_rss_queues();
+	nn->num_tx_rings = min_t(int, nqs, max_tx_rings);
+	nn->num_rx_rings = min_t(int, nqs, max_rx_rings);
+
+	nn->txd_cnt = NFP_NET_TX_DESCS_DEFAULT;
+	nn->rxd_cnt = NFP_NET_RX_DESCS_DEFAULT;
+
+	spin_lock_init(&nn->reconfig_lock);
+
+	return nn;
+}
+
+/**
+ * nfp_net_netdev_free() - Undo what @nfp_net_netdev_alloc() did
+ * @nn:      NFP Net device to reconfigure
+ */
+void nfp_net_netdev_free(struct nfp_net *nn)
+{
+	free_netdev(nn->netdev);
+}
+
+/**
+ * nfp_net_netdev_init() - Initialise/finalise the netdev structure
+ * @netdev:      netdev structure
+ *
+ * Return: 0 on success or negative errno on error.
+ */
+int nfp_net_netdev_init(struct net_device *netdev)
+{
+	struct nfp_net *nn = netdev_priv(netdev);
+	int i, err;
+
+	/* Get some of the read-only fields from the BAR */
+	nn->ver = nn_readl(nn, NFP_NET_CFG_VERSION);
+	nn->cap = nn_readl(nn, NFP_NET_CFG_CAP);
+	nn->max_mtu = nn_readl(nn, NFP_NET_CFG_MAX_MTU);
+
+	nfp_net_write_mac_addr(nn, nn->netdev->dev_addr);
+
+	/* Set default MTU and Freelist buffer size */
+	if (nn->max_mtu < NFP_NET_DEFAULT_MTU)
+		netdev->mtu = nn->max_mtu;
+	else
+		netdev->mtu = NFP_NET_DEFAULT_MTU;
+	nn->fl_bufsz = NFP_NET_DEFAULT_RX_BUFSZ;
+
+	/* Advertise/enable offloads based on capabilities
+	 *
+	 * Note: netdev->features show the currently enabled features
+	 * and netdev->hw_features advertises which features are
+	 * supported.  By default we enable most features.
+	 */
+	netdev->hw_features = NETIF_F_HIGHDMA;
+	if (nn->cap & NFP_NET_CFG_CTRL_RXCSUM) {
+		netdev->hw_features |= NETIF_F_RXCSUM;
+		nn->ctrl |= NFP_NET_CFG_CTRL_RXCSUM;
+	}
+	if (nn->cap & NFP_NET_CFG_CTRL_TXCSUM) {
+		netdev->hw_features |= NETIF_F_IP_CSUM | NETIF_F_IPV6_CSUM;
+		nn->ctrl |= NFP_NET_CFG_CTRL_TXCSUM;
+	}
+	if (nn->cap & NFP_NET_CFG_CTRL_SCATTER &&
+	    nn->cap & NFP_NET_CFG_CTRL_GATHER) {
+		netdev->hw_features |= NETIF_F_SG;
+		nn->ctrl |= NFP_NET_CFG_CTRL_SCATTER | NFP_NET_CFG_CTRL_GATHER;
+	}
+	if (nn->cap & NFP_NET_CFG_CTRL_RSS) {
+		netdev->hw_features |= NETIF_F_RXHASH | NETIF_F_NTUPLE;
+		nn->ctrl |= NFP_NET_CFG_CTRL_RSS;
+	}
+	if (nn->cap & NFP_NET_CFG_CTRL_GATHER) {
+		netdev->hw_features |= NETIF_F_SG;
+		nn->ctrl |= NFP_NET_CFG_CTRL_GATHER;
+	}
+
+	netdev->vlan_features = netdev->hw_features;
+
+	if (nn->cap & NFP_NET_CFG_CTRL_RXVLAN) {
+		netdev->hw_features |= NETIF_F_HW_VLAN_CTAG_RX;
+		nn->ctrl |= NFP_NET_CFG_CTRL_RXVLAN;
+	}
+	if (nn->cap & NFP_NET_CFG_CTRL_TXVLAN) {
+		netdev->hw_features |= NETIF_F_HW_VLAN_CTAG_TX;
+		nn->ctrl |= NFP_NET_CFG_CTRL_TXVLAN;
+	}
+
+	netdev->features = netdev->hw_features;
+
+	/* Advertise but disable TSO by default. */
+	if (nn->cap & NFP_NET_CFG_CTRL_LSO)
+		netdev->hw_features |= NETIF_F_TSO | NETIF_F_TSO6;
+
+	if (nn->cap & NFP_NET_CFG_CTRL_VXLAN &&
+	    nn->cap & NFP_NET_CFG_CTRL_NVGRE) {
+		if (nn->cap & NFP_NET_CFG_CTRL_LSO)
+			netdev->hw_features |= NETIF_F_GSO_GRE |
+					       NETIF_F_GSO_UDP_TUNNEL;
+
+		/* Advertise features we support on encapsulated packets */
+		netdev->hw_enc_features =
+			netdev->hw_features & (NETIF_F_IP_CSUM |
+					       NETIF_F_IPV6_CSUM |
+					       NETIF_F_TSO |
+					       NETIF_F_TSO6 |
+					       NETIF_F_GSO_GRE |
+					       NETIF_F_GSO_UDP_TUNNEL);
+
+		nn->ctrl |= NFP_NET_CFG_CTRL_VXLAN | NFP_NET_CFG_CTRL_NVGRE;
+	}
+
+	/* Allow L2 Broadcast through by default, if supported */
+	if (nn->cap & NFP_NET_CFG_CTRL_L2BC)
+		nn->ctrl |= NFP_NET_CFG_CTRL_L2BC;
+
+	/* Allow IRQ moderation, if supported */
+	if (nn->pdev->msix_enabled && (nn->cap & NFP_NET_CFG_CTRL_IRQMOD))
+		nn->ctrl |= NFP_NET_CFG_CTRL_IRQMOD;
+
+	/* On NFP-3200 enable MSI-X auto-masking, if supported and the
+	 * interrupts are not shared.
+	 */
+	if (nn->is_nfp3200 && nn->cap & NFP_NET_CFG_CTRL_MSIXAUTO &&
+	    nn->per_vector_masking)
+		nn->ctrl |= NFP_NET_CFG_CTRL_MSIXAUTO;
+
+	/* On NFP4000/NFP6000, determine RX packet/metadata boundary offset */
+	if ((nn->ver & NFP_NET_CFG_VERSION_MAJOR_MASK) >=
+	    NFP_NET_CFG_VERSION_MAJOR(2))
+		nn->rx_offset = nn_readl(nn, NFP_NET_CFG_RX_OFFSET);
+	else
+		nn->rx_offset = NFP_NET_RX_OFFSET;
+
+	/* Generate some random bits for RSS and write to device */
+	if (nn->cap & NFP_NET_CFG_CTRL_RSS) {
+		get_random_bytes(nn->rss_key, NFP_NET_CFG_RSS_KEY_SZ);
+		for (i = 0; i < NFP_NET_CFG_RSS_KEY_SZ; i += 4)
+			nn_writel(nn, NFP_NET_CFG_RSS_KEY + i,
+				  nn->rss_key[i / sizeof(u32)]);
+	}
+
+	/* Stash the re-configuration queue away.  First odd queue in TX Bar */
+	nn->qcp_cfg = nn->tx_bar + NFP_QCP_QUEUE_ADDR_SZ;
+
+	/* Make sure the FW knows the netdev is supposed to be disabled here */
+	nn_writel(nn, NFP_NET_CFG_CTRL, 0);
+	nn_writeq(nn, NFP_NET_CFG_TXRS_ENABLE, 0);
+	nn_writeq(nn, NFP_NET_CFG_RXRS_ENABLE, 0);
+	err = nfp_net_reconfig(
+		nn, NFP_NET_CFG_UPDATE_RING | NFP_NET_CFG_UPDATE_GEN);
+	if (err)
+		goto err_reconfig;
+
+	/* Finalise the netdev setup */
+	ether_setup(netdev);
+	netdev->netdev_ops = &nfp_net_netdev_ops;
+	netdev->watchdog_timeo = msecs_to_jiffies(5 * 1000);
+
+	nfp_net_set_ethtool_ops(netdev);
+
+	err = register_netdev(netdev);
+	if (err)
+		return err;
+
+	nfp_net_irqs_assign(netdev);
+
+	return 0;
+
+err_reconfig:
+	return err;
+}
+
+/**
+ * nfp_net_netdev_clean() - Undo what nfp_net_netdev_init() did.
+ * @netdev:      netdev structure
+ */
+void nfp_net_netdev_clean(struct net_device *netdev)
+{
+	unregister_netdev(netdev);
+}
diff --git a/drivers/net/ethernet/netronome/nfp/nfp_net_ctrl.h b/drivers/net/ethernet/netronome/nfp/nfp_net_ctrl.h
new file mode 100644
index 000000000000..6a7c0a0fa7f2
--- /dev/null
+++ b/drivers/net/ethernet/netronome/nfp/nfp_net_ctrl.h
@@ -0,0 +1,318 @@
+/*
+ * Copyright (C) 2015 Netronome Systems, Inc.
+ *
+ * This software is dual licensed under the GNU General License Version 2,
+ * June 1991 as shown in the file COPYING in the top-level directory of this
+ * source tree or the BSD 2-Clause License provided below.  You have the
+ * option to license this software under the complete terms of either license.
+ *
+ * The BSD 2-Clause License:
+ *
+ *     Redistribution and use in source and binary forms, with or
+ *     without modification, are permitted provided that the following
+ *     conditions are met:
+ *
+ *      1. Redistributions of source code must retain the above
+ *         copyright notice, this list of conditions and the following
+ *         disclaimer.
+ *
+ *      2. Redistributions in binary form must reproduce the above
+ *         copyright notice, this list of conditions and the following
+ *         disclaimer in the documentation and/or other materials
+ *         provided with the distribution.
+ *
+ * THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND,
+ * EXPRESS OR IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF
+ * MERCHANTABILITY, FITNESS FOR A PARTICULAR PURPOSE AND
+ * NONINFRINGEMENT. IN NO EVENT SHALL THE AUTHORS OR COPYRIGHT HOLDERS
+ * BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER LIABILITY, WHETHER IN AN
+ * ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM, OUT OF OR IN
+ * CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN THE
+ * SOFTWARE.
+ */
+
+/*
+ * nfp_net_ctrl.h
+ * Netronome network device driver: Control BAR layout
+ * Authors: Jakub Kicinski <jakub.kicinski@netronome.com>
+ *          Jason McMullan <jason.mcmullan@netronome.com>
+ *          Rolf Neugebauer <rolf.neugebauer@netronome.com>
+ *          Brad Petrus <brad.petrus@netronome.com>
+ */
+
+#ifndef _NFP_NET_CTRL_H_
+#define _NFP_NET_CTRL_H_
+
+/* IMPORTANT: This header file is shared with the FW,
+ *	      no OS specific constructs, please!
+ */
+
+/**
+ * Configuration BAR size.
+ *
+ * The configuration BAR is 8K in size, but on the NFP6000, due to
+ * THB-350, 32k needs to be reserved.
+ */
+#define NFP_NET_CFG_BAR_SZ              (32 * 1024)
+
+/**
+ * Offset in Freelist buffer where packet starts on RX
+ */
+#define NFP_NET_RX_OFFSET               32
+
+/**
+ * Maximum header size supported for LSO frames
+ */
+#define NFP_NET_LSO_MAX_HDR_SZ		255
+
+/**
+ * Hash type pre-pended when a RSS hash was computed
+ */
+#define NFP_NET_RSS_NONE                0
+#define NFP_NET_RSS_IPV4                1
+#define NFP_NET_RSS_IPV6                2
+#define NFP_NET_RSS_IPV6_EX             3
+#define NFP_NET_RSS_IPV4_TCP            4
+#define NFP_NET_RSS_IPV6_TCP            5
+#define NFP_NET_RSS_IPV6_EX_TCP         6
+#define NFP_NET_RSS_IPV4_UDP            7
+#define NFP_NET_RSS_IPV6_UDP            8
+#define NFP_NET_RSS_IPV6_EX_UDP         9
+
+/**
+ * @NFP_NET_TXR_MAX:         Maximum number of TX rings
+ * @NFP_NET_TXR_MASK:        Mask for TX rings
+ * @NFP_NET_RXR_MAX:         Maximum number of RX rings
+ * @NFP_NET_RXR_MASK:        Mask for RX rings
+ */
+#define NFP_NET_TXR_MAX                 64
+#define NFP_NET_TXR_MASK                (NFP_NET_TXR_MAX - 1)
+#define NFP_NET_RXR_MAX                 64
+#define NFP_NET_RXR_MASK                (NFP_NET_RXR_MAX - 1)
+
+/**
+ * Read/Write config words (0x0000 - 0x002c)
+ * @NFP_NET_CFG_CTRL:        Global control
+ * @NFP_NET_CFG_UPDATE:      Indicate which fields are updated
+ * @NFP_NET_CFG_TXRS_ENABLE: Bitmask of enabled TX rings
+ * @NFP_NET_CFG_RXRS_ENABLE: Bitmask of enabled RX rings
+ * @NFP_NET_CFG_MTU:         Set MTU size
+ * @NFP_NET_CFG_FLBUFSZ:     Set freelist buffer size (must be larger than MTU)
+ * @NFP_NET_CFG_EXN:         MSI-X table entry for exceptions
+ * @NFP_NET_CFG_LSC:         MSI-X table entry for link state changes
+ * @NFP_NET_CFG_MACADDR:     MAC address
+ *
+ * TODO:
+ * - define Error details in UPDATE
+ */
+#define NFP_NET_CFG_CTRL                0x0000
+#define   NFP_NET_CFG_CTRL_ENABLE         (0x1 <<  0) /* Global enable */
+#define   NFP_NET_CFG_CTRL_PROMISC        (0x1 <<  1) /* Enable Promisc mode */
+#define   NFP_NET_CFG_CTRL_L2BC           (0x1 <<  2) /* Allow L2 Broadcast */
+#define   NFP_NET_CFG_CTRL_L2MC           (0x1 <<  3) /* Allow L2 Multicast */
+#define   NFP_NET_CFG_CTRL_RXCSUM         (0x1 <<  4) /* Enable RX Checksum */
+#define   NFP_NET_CFG_CTRL_TXCSUM         (0x1 <<  5) /* Enable TX Checksum */
+#define   NFP_NET_CFG_CTRL_RXVLAN         (0x1 <<  6) /* Enable VLAN strip */
+#define   NFP_NET_CFG_CTRL_TXVLAN         (0x1 <<  7) /* Enable VLAN insert */
+#define   NFP_NET_CFG_CTRL_SCATTER        (0x1 <<  8) /* Scatter DMA */
+#define   NFP_NET_CFG_CTRL_GATHER         (0x1 <<  9) /* Gather DMA */
+#define   NFP_NET_CFG_CTRL_LSO            (0x1 << 10) /* LSO/TSO */
+#define   NFP_NET_CFG_CTRL_RINGCFG        (0x1 << 16) /* Ring runtime changes */
+#define   NFP_NET_CFG_CTRL_RSS            (0x1 << 17) /* RSS */
+#define   NFP_NET_CFG_CTRL_IRQMOD         (0x1 << 18) /* Interrupt moderation */
+#define   NFP_NET_CFG_CTRL_RINGPRIO       (0x1 << 19) /* Ring priorities */
+#define   NFP_NET_CFG_CTRL_MSIXAUTO       (0x1 << 20) /* MSI-X auto-masking */
+#define   NFP_NET_CFG_CTRL_TXRWB          (0x1 << 21) /* Write-back of TX ring*/
+#define   NFP_NET_CFG_CTRL_L2SWITCH       (0x1 << 22) /* L2 Switch */
+#define   NFP_NET_CFG_CTRL_L2SWITCH_LOCAL (0x1 << 23) /* Switch to local */
+#define   NFP_NET_CFG_CTRL_VXLAN	  (0x1 << 24) /* VXLAN tunnel support */
+#define   NFP_NET_CFG_CTRL_NVGRE	  (0x1 << 25) /* NVGRE tunnel support */
+#define NFP_NET_CFG_UPDATE              0x0004
+#define   NFP_NET_CFG_UPDATE_GEN          (0x1 <<  0) /* General update */
+#define   NFP_NET_CFG_UPDATE_RING         (0x1 <<  1) /* Ring config change */
+#define   NFP_NET_CFG_UPDATE_RSS          (0x1 <<  2) /* RSS config change */
+#define   NFP_NET_CFG_UPDATE_TXRPRIO      (0x1 <<  3) /* TX Ring prio change */
+#define   NFP_NET_CFG_UPDATE_RXRPRIO      (0x1 <<  4) /* RX Ring prio change */
+#define   NFP_NET_CFG_UPDATE_MSIX         (0x1 <<  5) /* MSI-X change */
+#define   NFP_NET_CFG_UPDATE_L2SWITCH     (0x1 <<  6) /* Switch changes */
+#define   NFP_NET_CFG_UPDATE_RESET        (0x1 <<  7) /* Update due to FLR */
+#define   NFP_NET_CFG_UPDATE_IRQMOD       (0x1 <<  8) /* IRQ mod change */
+#define   NFP_NET_CFG_UPDATE_VXLAN	  (0x1 <<  9) /* VXLAN port change */
+#define   NFP_NET_CFG_UPDATE_ERR          (0x1 << 31) /* A error occurred */
+#define NFP_NET_CFG_TXRS_ENABLE         0x0008
+#define NFP_NET_CFG_RXRS_ENABLE         0x0010
+#define NFP_NET_CFG_MTU                 0x0018
+#define NFP_NET_CFG_FLBUFSZ             0x001c
+#define NFP_NET_CFG_EXN                 0x001f
+#define NFP_NET_CFG_LSC                 0x0020
+#define NFP_NET_CFG_MACADDR             0x0024
+
+/**
+ * Read-only words (0x0030 - 0x0050):
+ * @NFP_NET_CFG_VERSION:     Firmware version number
+ * @NFP_NET_CFG_STS:         Status
+ * @NFP_NET_CFG_CAP:         Capabilities (same bits as @NFP_NET_CFG_CTRL)
+ * @NFP_NET_MAX_TXRINGS:     Maximum number of TX rings
+ * @NFP_NET_MAX_RXRINGS:     Maximum number of RX rings
+ * @NFP_NET_MAX_MTU:         Maximum support MTU
+ * @NFP_NET_CFG_START_TXQ:   Start Queue Control Queue to use for TX (PF only)
+ * @NFP_NET_CFG_START_RXQ:   Start Queue Control Queue to use for RX (PF only)
+ *
+ * TODO:
+ * - define more STS bits
+ */
+#define NFP_NET_CFG_VERSION             0x0030
+#define   NFP_NET_CFG_VERSION_RESERVED_MASK	(0xff << 24)
+#define   NFP_NET_CFG_VERSION_CLASS_MASK  (0xff << 16)
+#define   NFP_NET_CFG_VERSION_CLASS(x)    (((x) & 0xff) << 16)
+#define   NFP_NET_CFG_VERSION_CLASS_GENERIC	0
+#define   NFP_NET_CFG_VERSION_MAJOR_MASK  (0xff <<  8)
+#define   NFP_NET_CFG_VERSION_MAJOR(x)    (((x) & 0xff) <<  8)
+#define   NFP_NET_CFG_VERSION_MINOR_MASK  (0xff <<  0)
+#define   NFP_NET_CFG_VERSION_MINOR(x)    (((x) & 0xff) <<  0)
+#define NFP_NET_CFG_STS                 0x0034
+#define   NFP_NET_CFG_STS_LINK            (0x1 << 0) /* Link up or down */
+#define NFP_NET_CFG_CAP                 0x0038
+#define NFP_NET_CFG_MAX_TXRINGS         0x003c
+#define NFP_NET_CFG_MAX_RXRINGS         0x0040
+#define NFP_NET_CFG_MAX_MTU             0x0044
+/* Next two words are being used by VFs for solving THB350 issue */
+#define NFP_NET_CFG_START_TXQ           0x0048
+#define NFP_NET_CFG_START_RXQ           0x004c
+
+/**
+ * NFP-3200 workaround (0x0050 - 0x0058)
+ * @NFP_NET_CFG_SPARE_ADDR:  DMA address for ME code to use (e.g. YDS-155 fix)
+ */
+#define NFP_NET_CFG_SPARE_ADDR          0x0050
+/**
+ * NFP6000/NFP4000 - Prepend configuration
+ */
+#define NFP_NET_CFG_RX_OFFSET		0x0050
+#define NFP_NET_CFG_RX_OFFSET_DYNAMIC		0	/* Prepend mode */
+
+#define NFP_NET_CFG_VXLAN_PORT		0x0060
+#define NFP_NET_CFG_VXLAN_SZ		0x0008
+
+/**
+ * 64B reserved for future use (0x0080 - 0x00c0)
+ */
+#define NFP_NET_CFG_RESERVED            0x0080
+#define NFP_NET_CFG_RESERVED_SZ         0x0040
+
+/**
+ * RSS configuration (0x0100 - 0x01ac):
+ * Used only when NFP_NET_CFG_CTRL_RSS is enabled
+ * @NFP_NET_CFG_RSS_CFG:     RSS configuration word
+ * @NFP_NET_CFG_RSS_KEY:     RSS "secret" key
+ * @NFP_NET_CFG_RSS_ITBL:    RSS indirection table
+ */
+#define NFP_NET_CFG_RSS_BASE            0x0100
+#define NFP_NET_CFG_RSS_CTRL            NFP_NET_CFG_RSS_BASE
+#define   NFP_NET_CFG_RSS_MASK            (0x7f)
+#define   NFP_NET_CFG_RSS_MASK_of(_x)     ((_x) & 0x7f)
+#define   NFP_NET_CFG_RSS_IPV4            (1 <<  8) /* RSS for IPv4 */
+#define   NFP_NET_CFG_RSS_IPV6            (1 <<  9) /* RSS for IPv6 */
+#define   NFP_NET_CFG_RSS_IPV4_TCP        (1 << 10) /* RSS for IPv4/TCP */
+#define   NFP_NET_CFG_RSS_IPV4_UDP        (1 << 11) /* RSS for IPv4/UDP */
+#define   NFP_NET_CFG_RSS_IPV6_TCP        (1 << 12) /* RSS for IPv6/TCP */
+#define   NFP_NET_CFG_RSS_IPV6_UDP        (1 << 13) /* RSS for IPv6/UDP */
+#define   NFP_NET_CFG_RSS_TOEPLITZ        (1 << 24) /* Use Toeplitz hash */
+#define NFP_NET_CFG_RSS_KEY             (NFP_NET_CFG_RSS_BASE + 0x4)
+#define NFP_NET_CFG_RSS_KEY_SZ          0x28
+#define NFP_NET_CFG_RSS_ITBL            (NFP_NET_CFG_RSS_BASE + 0x4 + \
+					 NFP_NET_CFG_RSS_KEY_SZ)
+#define NFP_NET_CFG_RSS_ITBL_SZ         0x80
+
+/**
+ * TX ring configuration (0x200 - 0x800)
+ * @NFP_NET_CFG_TXR_BASE:    Base offset for TX ring configuration
+ * @NFP_NET_CFG_TXR_ADDR:    Per TX ring DMA address (8B entries)
+ * @NFP_NET_CFG_TXR_WB_ADDR: Per TX ring write back DMA address (8B entries)
+ * @NFP_NET_CFG_TXR_SZ:      Per TX ring ring size (1B entries)
+ * @NFP_NET_CFG_TXR_VEC:     Per TX ring MSI-X table entry (1B entries)
+ * @NFP_NET_CFG_TXR_PRIO:    Per TX ring priority (1B entries)
+ * @NFP_NET_CFG_TXR_IRQ_MOD: Per TX ring interrupt moderation packet
+ */
+#define NFP_NET_CFG_TXR_BASE            0x0200
+#define NFP_NET_CFG_TXR_ADDR(_x)        (NFP_NET_CFG_TXR_BASE + ((_x) * 0x8))
+#define NFP_NET_CFG_TXR_WB_ADDR(_x)     (NFP_NET_CFG_TXR_BASE + 0x200 + \
+					 ((_x) * 0x8))
+#define NFP_NET_CFG_TXR_SZ(_x)          (NFP_NET_CFG_TXR_BASE + 0x400 + (_x))
+#define NFP_NET_CFG_TXR_VEC(_x)         (NFP_NET_CFG_TXR_BASE + 0x440 + (_x))
+#define NFP_NET_CFG_TXR_PRIO(_x)        (NFP_NET_CFG_TXR_BASE + 0x480 + (_x))
+#define NFP_NET_CFG_TXR_IRQ_MOD(_x)	(NFP_NET_CFG_TXR_BASE + 0x500 + \
+					 ((_x) * 0x4))
+
+/**
+ * RX ring configuration (0x0800 - 0x0c00)
+ * @NFP_NET_CFG_RXR_BASE:    Base offset for RX ring configuration
+ * @NFP_NET_CFG_RXR_ADDR:    Per RX ring DMA address (8B entries)
+ * @NFP_NET_CFG_RXR_SZ:      Per RX ring ring size (1B entries)
+ * @NFP_NET_CFG_RXR_VEC:     Per RX ring MSI-X table entry (1B entries)
+ * @NFP_NET_CFG_RXR_PRIO:    Per RX ring priority (1B entries)
+ * @NFP_NET_CFG_RXR_IRQ_MOD: Per RX ring interrupt moderation (4B entries)
+ */
+#define NFP_NET_CFG_RXR_BASE            0x0800
+#define NFP_NET_CFG_RXR_ADDR(_x)        (NFP_NET_CFG_RXR_BASE + ((_x) * 0x8))
+#define NFP_NET_CFG_RXR_SZ(_x)          (NFP_NET_CFG_RXR_BASE + 0x200 + (_x))
+#define NFP_NET_CFG_RXR_VEC(_x)         (NFP_NET_CFG_RXR_BASE + 0x240 + (_x))
+#define NFP_NET_CFG_RXR_PRIO(_x)        (NFP_NET_CFG_RXR_BASE + 0x280 + (_x))
+#define NFP_NET_CFG_RXR_IRQ_MOD(_x)	(NFP_NET_CFG_RXR_BASE + 0x300 + \
+					 ((_x) * 0x4))
+
+/**
+ * Interrupt Control/Cause registers (0x0c00 - 0x0d00)
+ * These registers are only used when MSI-X auto-masking is not
+ * enabled (@NFP_NET_CFG_CTRL_MSIXAUTO not set).  The array is index
+ * by MSI-X entry and are 1B in size.  If an entry is zero, the
+ * corresponding entry is enabled.  If the FW generates an interrupt,
+ * it writes a cause into the corresponding field.  This also masks
+ * the MSI-X entry and the host driver must clear the register to
+ * re-enable the interrupt.
+ */
+#define NFP_NET_CFG_ICR_BASE            0x0c00
+#define NFP_NET_CFG_ICR(_x)             (NFP_NET_CFG_ICR_BASE + (_x))
+#define   NFP_NET_CFG_ICR_UNMASKED      0x0
+#define   NFP_NET_CFG_ICR_RXTX          0x1
+#define   NFP_NET_CFG_ICR_LSC           0x2
+
+/**
+ * General device stats (0x0d00 - 0x0d90)
+ * all counters are 64bit.
+ */
+#define NFP_NET_CFG_STATS_BASE          0x0d00
+#define NFP_NET_CFG_STATS_RX_DISCARDS   (NFP_NET_CFG_STATS_BASE + 0x00)
+#define NFP_NET_CFG_STATS_RX_ERRORS     (NFP_NET_CFG_STATS_BASE + 0x08)
+#define NFP_NET_CFG_STATS_RX_OCTETS     (NFP_NET_CFG_STATS_BASE + 0x10)
+#define NFP_NET_CFG_STATS_RX_UC_OCTETS  (NFP_NET_CFG_STATS_BASE + 0x18)
+#define NFP_NET_CFG_STATS_RX_MC_OCTETS  (NFP_NET_CFG_STATS_BASE + 0x20)
+#define NFP_NET_CFG_STATS_RX_BC_OCTETS  (NFP_NET_CFG_STATS_BASE + 0x28)
+#define NFP_NET_CFG_STATS_RX_FRAMES     (NFP_NET_CFG_STATS_BASE + 0x30)
+#define NFP_NET_CFG_STATS_RX_MC_FRAMES  (NFP_NET_CFG_STATS_BASE + 0x38)
+#define NFP_NET_CFG_STATS_RX_BC_FRAMES  (NFP_NET_CFG_STATS_BASE + 0x40)
+
+#define NFP_NET_CFG_STATS_TX_DISCARDS   (NFP_NET_CFG_STATS_BASE + 0x48)
+#define NFP_NET_CFG_STATS_TX_ERRORS     (NFP_NET_CFG_STATS_BASE + 0x50)
+#define NFP_NET_CFG_STATS_TX_OCTETS     (NFP_NET_CFG_STATS_BASE + 0x58)
+#define NFP_NET_CFG_STATS_TX_UC_OCTETS  (NFP_NET_CFG_STATS_BASE + 0x60)
+#define NFP_NET_CFG_STATS_TX_MC_OCTETS  (NFP_NET_CFG_STATS_BASE + 0x68)
+#define NFP_NET_CFG_STATS_TX_BC_OCTETS  (NFP_NET_CFG_STATS_BASE + 0x70)
+#define NFP_NET_CFG_STATS_TX_FRAMES     (NFP_NET_CFG_STATS_BASE + 0x78)
+#define NFP_NET_CFG_STATS_TX_MC_FRAMES  (NFP_NET_CFG_STATS_BASE + 0x80)
+#define NFP_NET_CFG_STATS_TX_BC_FRAMES  (NFP_NET_CFG_STATS_BASE + 0x88)
+
+/**
+ * Per ring stats (0x1000 - 0x1800)
+ * options, 64bit per entry
+ * @NFP_NET_CFG_TXR_STATS:   TX ring statistics (Packet and Byte count)
+ * @NFP_NET_CFG_RXR_STATS:   RX ring statistics (Packet and Byte count)
+ */
+#define NFP_NET_CFG_TXR_STATS_BASE      0x1000
+#define NFP_NET_CFG_TXR_STATS(_x)       (NFP_NET_CFG_TXR_STATS_BASE + \
+					 ((_x) * 0x10))
+#define NFP_NET_CFG_RXR_STATS_BASE      0x1400
+#define NFP_NET_CFG_RXR_STATS(_x)       (NFP_NET_CFG_RXR_STATS_BASE + \
+					 ((_x) * 0x10))
+
+#endif /* _NFP_NET_CTRL_H_ */
diff --git a/drivers/net/ethernet/netronome/nfp/nfp_net_debugfs.c b/drivers/net/ethernet/netronome/nfp/nfp_net_debugfs.c
new file mode 100644
index 000000000000..4c97c713121c
--- /dev/null
+++ b/drivers/net/ethernet/netronome/nfp/nfp_net_debugfs.c
@@ -0,0 +1,235 @@
+/*
+ * Copyright (C) 2015 Netronome Systems, Inc.
+ *
+ * This software is dual licensed under the GNU General License Version 2,
+ * June 1991 as shown in the file COPYING in the top-level directory of this
+ * source tree or the BSD 2-Clause License provided below.  You have the
+ * option to license this software under the complete terms of either license.
+ *
+ * The BSD 2-Clause License:
+ *
+ *     Redistribution and use in source and binary forms, with or
+ *     without modification, are permitted provided that the following
+ *     conditions are met:
+ *
+ *      1. Redistributions of source code must retain the above
+ *         copyright notice, this list of conditions and the following
+ *         disclaimer.
+ *
+ *      2. Redistributions in binary form must reproduce the above
+ *         copyright notice, this list of conditions and the following
+ *         disclaimer in the documentation and/or other materials
+ *         provided with the distribution.
+ *
+ * THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND,
+ * EXPRESS OR IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF
+ * MERCHANTABILITY, FITNESS FOR A PARTICULAR PURPOSE AND
+ * NONINFRINGEMENT. IN NO EVENT SHALL THE AUTHORS OR COPYRIGHT HOLDERS
+ * BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER LIABILITY, WHETHER IN AN
+ * ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM, OUT OF OR IN
+ * CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN THE
+ * SOFTWARE.
+ */
+#include <linux/debugfs.h>
+#include <linux/module.h>
+#include <linux/rtnetlink.h>
+
+#include "nfp_net.h"
+
+static struct dentry *nfp_dir;
+
+static int nfp_net_debugfs_rx_q_read(struct seq_file *file, void *data)
+{
+	struct nfp_net_rx_ring *rx_ring = file->private;
+	int fl_rd_p, fl_wr_p, rx_rd_p, rx_wr_p, rxd_cnt;
+	struct nfp_net_rx_desc *rxd;
+	struct sk_buff *skb;
+	struct nfp_net *nn;
+	int i;
+
+	rtnl_lock();
+
+	if (!rx_ring->r_vec || !rx_ring->r_vec->nfp_net)
+		goto out;
+	nn = rx_ring->r_vec->nfp_net;
+	if (!netif_running(nn->netdev))
+		goto out;
+
+	rxd_cnt = rx_ring->cnt;
+
+	fl_rd_p = nfp_qcp_rd_ptr_read(rx_ring->qcp_fl);
+	fl_wr_p = nfp_qcp_wr_ptr_read(rx_ring->qcp_fl);
+	rx_rd_p = nfp_qcp_rd_ptr_read(rx_ring->qcp_rx);
+	rx_wr_p = nfp_qcp_wr_ptr_read(rx_ring->qcp_rx);
+
+	seq_printf(file, "RX[%02d]: H_RD=%d H_WR=%d FL_RD=%d FL_WR=%d RX_RD=%d RX_WR=%d\n",
+		   rx_ring->idx, rx_ring->rd_p, rx_ring->wr_p,
+		   fl_rd_p, fl_wr_p, rx_rd_p, rx_wr_p);
+
+	for (i = 0; i < rxd_cnt; i++) {
+		rxd = &rx_ring->rxds[i];
+		seq_printf(file, "%04d: 0x%08x 0x%08x", i,
+			   rxd->vals[0], rxd->vals[1]);
+
+		skb = READ_ONCE(rx_ring->rxbufs[i].skb);
+		if (skb)
+			seq_printf(file, " skb->head=%p skb->data=%p",
+				   skb->head, skb->data);
+
+		if (rx_ring->rxbufs[i].dma_addr)
+			seq_printf(file, " dma_addr=%pad",
+				   &rx_ring->rxbufs[i].dma_addr);
+
+		if (i == rx_ring->rd_p % rxd_cnt)
+			seq_puts(file, " H_RD ");
+		if (i == rx_ring->wr_p % rxd_cnt)
+			seq_puts(file, " H_WR ");
+		if (i == fl_rd_p % rxd_cnt)
+			seq_puts(file, " FL_RD");
+		if (i == fl_wr_p % rxd_cnt)
+			seq_puts(file, " FL_WR");
+		if (i == rx_rd_p % rxd_cnt)
+			seq_puts(file, " RX_RD");
+		if (i == rx_wr_p % rxd_cnt)
+			seq_puts(file, " RX_WR");
+
+		seq_putc(file, '\n');
+	}
+out:
+	rtnl_unlock();
+	return 0;
+}
+
+static int nfp_net_debugfs_rx_q_open(struct inode *inode, struct file *f)
+{
+	return single_open(f, nfp_net_debugfs_rx_q_read, inode->i_private);
+}
+
+static const struct file_operations nfp_rx_q_fops = {
+	.owner = THIS_MODULE,
+	.open = nfp_net_debugfs_rx_q_open,
+	.release = single_release,
+	.read = seq_read,
+	.llseek = seq_lseek
+};
+
+static int nfp_net_debugfs_tx_q_read(struct seq_file *file, void *data)
+{
+	struct nfp_net_tx_ring *tx_ring = file->private;
+	struct nfp_net_tx_desc *txd;
+	int d_rd_p, d_wr_p, txd_cnt;
+	struct sk_buff *skb;
+	struct nfp_net *nn;
+	int i;
+
+	rtnl_lock();
+
+	if (!tx_ring->r_vec || !tx_ring->r_vec->nfp_net)
+		goto out;
+	nn = tx_ring->r_vec->nfp_net;
+	if (!netif_running(nn->netdev))
+		goto out;
+
+	txd_cnt = tx_ring->cnt;
+
+	d_rd_p = nfp_qcp_rd_ptr_read(tx_ring->qcp_q);
+	d_wr_p = nfp_qcp_wr_ptr_read(tx_ring->qcp_q);
+
+	seq_printf(file, "TX[%02d]: H_RD=%d H_WR=%d D_RD=%d D_WR=%d\n",
+		   tx_ring->idx, tx_ring->rd_p, tx_ring->wr_p, d_rd_p, d_wr_p);
+
+	for (i = 0; i < txd_cnt; i++) {
+		txd = &tx_ring->txds[i];
+		seq_printf(file, "%04d: 0x%08x 0x%08x 0x%08x 0x%08x", i,
+			   txd->vals[0], txd->vals[1],
+			   txd->vals[2], txd->vals[3]);
+
+		skb = READ_ONCE(tx_ring->txbufs[i].skb);
+		if (skb)
+			seq_printf(file, " skb->head=%p skb->data=%p",
+				   skb->head, skb->data);
+		if (tx_ring->txbufs[i].dma_addr)
+			seq_printf(file, " dma_addr=%pad",
+				   &tx_ring->txbufs[i].dma_addr);
+
+		if (i == tx_ring->rd_p % txd_cnt)
+			seq_puts(file, " H_RD");
+		if (i == tx_ring->wr_p % txd_cnt)
+			seq_puts(file, " H_WR");
+		if (i == d_rd_p % txd_cnt)
+			seq_puts(file, " D_RD");
+		if (i == d_wr_p % txd_cnt)
+			seq_puts(file, " D_WR");
+
+		seq_putc(file, '\n');
+	}
+out:
+	rtnl_unlock();
+	return 0;
+}
+
+static int nfp_net_debugfs_tx_q_open(struct inode *inode, struct file *f)
+{
+	return single_open(f, nfp_net_debugfs_tx_q_read, inode->i_private);
+}
+
+static const struct file_operations nfp_tx_q_fops = {
+	.owner = THIS_MODULE,
+	.open = nfp_net_debugfs_tx_q_open,
+	.release = single_release,
+	.read = seq_read,
+	.llseek = seq_lseek
+};
+
+void nfp_net_debugfs_adapter_add(struct nfp_net *nn)
+{
+	static struct dentry *queues, *tx, *rx;
+	char int_name[16];
+	int i;
+
+	if (IS_ERR_OR_NULL(nfp_dir))
+		return;
+
+	nn->debugfs_dir = debugfs_create_dir(pci_name(nn->pdev), nfp_dir);
+	if (IS_ERR_OR_NULL(nn->debugfs_dir))
+		return;
+
+	/* Create queue debugging sub-tree */
+	queues = debugfs_create_dir("queue", nn->debugfs_dir);
+	if (IS_ERR_OR_NULL(nn->debugfs_dir))
+		return;
+
+	rx = debugfs_create_dir("rx", queues);
+	tx = debugfs_create_dir("tx", queues);
+	if (IS_ERR_OR_NULL(rx) || IS_ERR_OR_NULL(tx))
+		return;
+
+	for (i = 0; i < nn->num_rx_rings; i++) {
+		sprintf(int_name, "%d", i);
+		debugfs_create_file(int_name, S_IRUSR, rx,
+				    &nn->rx_rings[i], &nfp_rx_q_fops);
+	}
+
+	for (i = 0; i < nn->num_tx_rings; i++) {
+		sprintf(int_name, "%d", i);
+		debugfs_create_file(int_name, S_IRUSR, tx,
+				    &nn->tx_rings[i], &nfp_tx_q_fops);
+	}
+}
+
+void nfp_net_debugfs_adapter_del(struct nfp_net *nn)
+{
+	debugfs_remove_recursive(nn->debugfs_dir);
+	nn->debugfs_dir = NULL;
+}
+
+void nfp_net_debugfs_create(void)
+{
+	nfp_dir = debugfs_create_dir("nfp_net", NULL);
+}
+
+void nfp_net_debugfs_destroy(void)
+{
+	debugfs_remove_recursive(nfp_dir);
+	nfp_dir = NULL;
+}
diff --git a/drivers/net/ethernet/netronome/nfp/nfp_net_ethtool.c b/drivers/net/ethernet/netronome/nfp/nfp_net_ethtool.c
new file mode 100644
index 000000000000..062961fe3f7d
--- /dev/null
+++ b/drivers/net/ethernet/netronome/nfp/nfp_net_ethtool.c
@@ -0,0 +1,704 @@
+/*
+ * Copyright (C) 2015 Netronome Systems, Inc.
+ *
+ * This software is dual licensed under the GNU General License Version 2,
+ * June 1991 as shown in the file COPYING in the top-level directory of this
+ * source tree or the BSD 2-Clause License provided below.  You have the
+ * option to license this software under the complete terms of either license.
+ *
+ * The BSD 2-Clause License:
+ *
+ *     Redistribution and use in source and binary forms, with or
+ *     without modification, are permitted provided that the following
+ *     conditions are met:
+ *
+ *      1. Redistributions of source code must retain the above
+ *         copyright notice, this list of conditions and the following
+ *         disclaimer.
+ *
+ *      2. Redistributions in binary form must reproduce the above
+ *         copyright notice, this list of conditions and the following
+ *         disclaimer in the documentation and/or other materials
+ *         provided with the distribution.
+ *
+ * THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND,
+ * EXPRESS OR IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF
+ * MERCHANTABILITY, FITNESS FOR A PARTICULAR PURPOSE AND
+ * NONINFRINGEMENT. IN NO EVENT SHALL THE AUTHORS OR COPYRIGHT HOLDERS
+ * BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER LIABILITY, WHETHER IN AN
+ * ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM, OUT OF OR IN
+ * CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN THE
+ * SOFTWARE.
+ */
+
+/*
+ * nfp_net_ethtool.c
+ * Netronome network device driver: ethtool support
+ * Authors: Jakub Kicinski <jakub.kicinski@netronome.com>
+ *          Jason McMullan <jason.mcmullan@netronome.com>
+ *          Rolf Neugebauer <rolf.neugebauer@netronome.com>
+ *          Brad Petrus <brad.petrus@netronome.com>
+ */
+
+#include <linux/version.h>
+#include <linux/kernel.h>
+#include <linux/netdevice.h>
+#include <linux/etherdevice.h>
+#include <linux/interrupt.h>
+#include <linux/pci.h>
+#include <linux/ethtool.h>
+
+#include "nfp_net_ctrl.h"
+#include "nfp_net.h"
+
+/* Support for stats. Returns netdev, driver, and device stats */
+enum { NETDEV_ET_STATS, NFP_NET_DRV_ET_STATS, NFP_NET_DEV_ET_STATS };
+struct _nfp_net_et_stats {
+	char name[ETH_GSTRING_LEN];
+	int type;
+	int sz;
+	int off;
+};
+
+#define NN_ET_NETDEV_STAT(m) NETDEV_ET_STATS,			\
+		FIELD_SIZEOF(struct net_device_stats, m),	\
+		offsetof(struct net_device_stats, m)
+/* For stats in the control BAR (other than Q stats) */
+#define NN_ET_DEV_STAT(m) NFP_NET_DEV_ET_STATS,			\
+		sizeof(u64),					\
+		(m)
+static const struct _nfp_net_et_stats nfp_net_et_stats[] = {
+	/* netdev stats */
+	{"rx_packets", NN_ET_NETDEV_STAT(rx_packets)},
+	{"tx_packets", NN_ET_NETDEV_STAT(tx_packets)},
+	{"rx_bytes", NN_ET_NETDEV_STAT(rx_bytes)},
+	{"tx_bytes", NN_ET_NETDEV_STAT(tx_bytes)},
+	{"rx_errors", NN_ET_NETDEV_STAT(rx_errors)},
+	{"tx_errors", NN_ET_NETDEV_STAT(tx_errors)},
+	{"rx_dropped", NN_ET_NETDEV_STAT(rx_dropped)},
+	{"tx_dropped", NN_ET_NETDEV_STAT(tx_dropped)},
+	{"multicast", NN_ET_NETDEV_STAT(multicast)},
+	{"collisions", NN_ET_NETDEV_STAT(collisions)},
+	{"rx_over_errors", NN_ET_NETDEV_STAT(rx_over_errors)},
+	{"rx_crc_errors", NN_ET_NETDEV_STAT(rx_crc_errors)},
+	{"rx_frame_errors", NN_ET_NETDEV_STAT(rx_frame_errors)},
+	{"rx_fifo_errors", NN_ET_NETDEV_STAT(rx_fifo_errors)},
+	{"rx_missed_errors", NN_ET_NETDEV_STAT(rx_missed_errors)},
+	{"tx_aborted_errors", NN_ET_NETDEV_STAT(tx_aborted_errors)},
+	{"tx_carrier_errors", NN_ET_NETDEV_STAT(tx_carrier_errors)},
+	{"tx_fifo_errors", NN_ET_NETDEV_STAT(tx_fifo_errors)},
+	/* Stats from the device */
+	{"dev_rx_discards", NN_ET_DEV_STAT(NFP_NET_CFG_STATS_RX_DISCARDS)},
+	{"dev_rx_errors", NN_ET_DEV_STAT(NFP_NET_CFG_STATS_RX_ERRORS)},
+	{"dev_rx_bytes", NN_ET_DEV_STAT(NFP_NET_CFG_STATS_RX_OCTETS)},
+	{"dev_rx_uc_bytes", NN_ET_DEV_STAT(NFP_NET_CFG_STATS_RX_UC_OCTETS)},
+	{"dev_rx_mc_bytes", NN_ET_DEV_STAT(NFP_NET_CFG_STATS_RX_MC_OCTETS)},
+	{"dev_rx_bc_bytes", NN_ET_DEV_STAT(NFP_NET_CFG_STATS_RX_BC_OCTETS)},
+	{"dev_rx_pkts", NN_ET_DEV_STAT(NFP_NET_CFG_STATS_RX_FRAMES)},
+	{"dev_rx_mc_pkts", NN_ET_DEV_STAT(NFP_NET_CFG_STATS_RX_MC_FRAMES)},
+	{"dev_rx_bc_pkts", NN_ET_DEV_STAT(NFP_NET_CFG_STATS_RX_BC_FRAMES)},
+
+	{"dev_tx_discards", NN_ET_DEV_STAT(NFP_NET_CFG_STATS_TX_DISCARDS)},
+	{"dev_tx_errors", NN_ET_DEV_STAT(NFP_NET_CFG_STATS_TX_ERRORS)},
+	{"dev_tx_bytes", NN_ET_DEV_STAT(NFP_NET_CFG_STATS_TX_OCTETS)},
+	{"dev_tx_uc_bytes", NN_ET_DEV_STAT(NFP_NET_CFG_STATS_TX_UC_OCTETS)},
+	{"dev_tx_mc_bytes", NN_ET_DEV_STAT(NFP_NET_CFG_STATS_TX_MC_OCTETS)},
+	{"dev_tx_bc_bytes", NN_ET_DEV_STAT(NFP_NET_CFG_STATS_TX_BC_OCTETS)},
+	{"dev_tx_pkts", NN_ET_DEV_STAT(NFP_NET_CFG_STATS_TX_FRAMES)},
+	{"dev_tx_mc_pkts", NN_ET_DEV_STAT(NFP_NET_CFG_STATS_TX_MC_FRAMES)},
+	{"dev_tx_bc_pkts", NN_ET_DEV_STAT(NFP_NET_CFG_STATS_TX_BC_FRAMES)},
+};
+
+#define NN_ET_GLOBAL_STATS_LEN ARRAY_SIZE(nfp_net_et_stats)
+#define NN_ET_RVEC_STATS_LEN (nn->num_r_vecs * 3)
+#define NN_ET_RVEC_GATHER_STATS 7
+#define NN_ET_QUEUE_STATS_LEN ((nn->num_tx_rings + nn->num_rx_rings) * 2)
+#define NN_ET_STATS_LEN (NN_ET_GLOBAL_STATS_LEN + NN_ET_RVEC_GATHER_STATS + \
+			 NN_ET_RVEC_STATS_LEN + NN_ET_QUEUE_STATS_LEN)
+
+static void nfp_net_get_drvinfo(struct net_device *netdev,
+				struct ethtool_drvinfo *drvinfo)
+{
+	struct nfp_net *nn = netdev_priv(netdev);
+
+	strlcpy(drvinfo->driver, nfp_net_driver_name, sizeof(drvinfo->driver));
+	strlcpy(drvinfo->version, nfp_net_driver_version,
+		sizeof(drvinfo->version));
+
+	snprintf(drvinfo->fw_version, sizeof(drvinfo->fw_version),
+		 "%d.%d.%d.%d",
+		 (nn->ver >> 24) & 0xff, (nn->ver >> 16) & 0xff,
+		 (nn->ver >>  8) & 0xff, (nn->ver >>  0) & 0xff);
+	strlcpy(drvinfo->bus_info, pci_name(nn->pdev),
+		sizeof(drvinfo->bus_info));
+
+	drvinfo->n_stats = NN_ET_STATS_LEN;
+	drvinfo->regdump_len = NFP_NET_CFG_BAR_SZ;
+}
+
+static void nfp_net_get_ringparam(struct net_device *netdev,
+				  struct ethtool_ringparam *ring)
+{
+	struct nfp_net *nn = netdev_priv(netdev);
+
+	ring->rx_max_pending = NFP_NET_MAX_RX_DESCS;
+	ring->tx_max_pending = NFP_NET_MAX_TX_DESCS;
+	ring->rx_pending = nn->rxd_cnt;
+	ring->tx_pending = nn->txd_cnt;
+}
+
+static int nfp_net_set_ringparam(struct net_device *netdev,
+				 struct ethtool_ringparam *ring)
+{
+	struct nfp_net *nn = netdev_priv(netdev);
+	u32 rxd_cnt, txd_cnt;
+
+	if (netif_running(netdev)) {
+		/* Some NIC drivers allow reconfiguration on the fly,
+		 * some down the interface, change and then up it
+		 * again.  For now we don't allow changes when the
+		 * device is up.
+		 */
+		nn_warn(nn, "Can't change rings while device is up\n");
+		return -EBUSY;
+	}
+
+	/* We don't have separate queues/rings for small/large frames. */
+	if (ring->rx_mini_pending || ring->rx_jumbo_pending)
+		return -EINVAL;
+
+	/* Round up to supported values */
+	rxd_cnt = roundup_pow_of_two(ring->rx_pending);
+	rxd_cnt = max_t(u32, rxd_cnt, NFP_NET_MIN_RX_DESCS);
+	rxd_cnt = min_t(u32, rxd_cnt, NFP_NET_MAX_RX_DESCS);
+
+	txd_cnt = roundup_pow_of_two(ring->tx_pending);
+	txd_cnt = max_t(u32, txd_cnt, NFP_NET_MIN_TX_DESCS);
+	txd_cnt = min_t(u32, txd_cnt, NFP_NET_MAX_TX_DESCS);
+
+	if (nn->rxd_cnt != rxd_cnt || nn->txd_cnt != txd_cnt)
+		nn_dbg(nn, "Change ring size: RxQ %u->%u, TxQ %u->%u\n",
+		       nn->rxd_cnt, rxd_cnt, nn->txd_cnt, txd_cnt);
+
+	nn->rxd_cnt = rxd_cnt;
+	nn->txd_cnt = txd_cnt;
+
+	return 0;
+}
+
+static void nfp_net_get_strings(struct net_device *netdev,
+				u32 stringset, u8 *data)
+{
+	struct nfp_net *nn = netdev_priv(netdev);
+	u8 *p = data;
+	int i;
+
+	switch (stringset) {
+	case ETH_SS_STATS:
+		for (i = 0; i < NN_ET_GLOBAL_STATS_LEN; i++) {
+			memcpy(p, nfp_net_et_stats[i].name, ETH_GSTRING_LEN);
+			p += ETH_GSTRING_LEN;
+		}
+		for (i = 0; i < nn->num_r_vecs; i++) {
+			sprintf(p, "rvec_%u_rx_pkts", i);
+			p += ETH_GSTRING_LEN;
+			sprintf(p, "rvec_%u_tx_pkts", i);
+			p += ETH_GSTRING_LEN;
+			sprintf(p, "rvec_%u_tx_busy", i);
+			p += ETH_GSTRING_LEN;
+		}
+		strncpy(p, "hw_rx_csum_ok", ETH_GSTRING_LEN);
+		p += ETH_GSTRING_LEN;
+		strncpy(p, "hw_rx_csum_inner_ok", ETH_GSTRING_LEN);
+		p += ETH_GSTRING_LEN;
+		strncpy(p, "hw_rx_csum_err", ETH_GSTRING_LEN);
+		p += ETH_GSTRING_LEN;
+		strncpy(p, "hw_tx_csum", ETH_GSTRING_LEN);
+		p += ETH_GSTRING_LEN;
+		strncpy(p, "hw_tx_inner_csum", ETH_GSTRING_LEN);
+		p += ETH_GSTRING_LEN;
+		strncpy(p, "tx_gather", ETH_GSTRING_LEN);
+		p += ETH_GSTRING_LEN;
+		strncpy(p, "tx_lso", ETH_GSTRING_LEN);
+		p += ETH_GSTRING_LEN;
+		for (i = 0; i < nn->num_tx_rings; i++) {
+			sprintf(p, "txq_%u_pkts", i);
+			p += ETH_GSTRING_LEN;
+			sprintf(p, "txq_%u_bytes", i);
+			p += ETH_GSTRING_LEN;
+		}
+		for (i = 0; i < nn->num_rx_rings; i++) {
+			sprintf(p, "rxq_%u_pkts", i);
+			p += ETH_GSTRING_LEN;
+			sprintf(p, "rxq_%u_bytes", i);
+			p += ETH_GSTRING_LEN;
+		}
+		break;
+	}
+}
+
+static void nfp_net_get_stats(struct net_device *netdev,
+			      struct ethtool_stats *stats, u64 *data)
+{
+	struct nfp_net *nn = netdev_priv(netdev);
+	struct rtnl_link_stats64 *netdev_stats;
+	struct rtnl_link_stats64 temp;
+	u64 tmp[NN_ET_RVEC_GATHER_STATS];
+	u64 gathered_stats[NN_ET_RVEC_GATHER_STATS] = {};
+	int i, j, k;
+	u8 __iomem *io_p;
+	u8 *p;
+
+	netdev_stats = dev_get_stats(netdev, &temp);
+
+	for (i = 0; i < NN_ET_GLOBAL_STATS_LEN; i++) {
+		switch (nfp_net_et_stats[i].type) {
+		case NETDEV_ET_STATS:
+			p = (char *)netdev_stats + nfp_net_et_stats[i].off;
+			data[i] = nfp_net_et_stats[i].sz == sizeof(u64) ?
+				*(u64 *)p : *(u32 *)p;
+			break;
+
+		case NFP_NET_DEV_ET_STATS:
+			io_p = nn->ctrl_bar + nfp_net_et_stats[i].off;
+			data[i] = readq(io_p);
+			break;
+		}
+	}
+	for (j = 0; j < nn->num_r_vecs; j++) {
+		unsigned int start;
+
+		do {
+			start = u64_stats_fetch_begin(&nn->r_vecs[j].rx_sync);
+			data[i++] = nn->r_vecs[j].rx_pkts;
+			tmp[0] = nn->r_vecs[j].hw_csum_rx_ok;
+			tmp[1] = nn->r_vecs[j].hw_csum_rx_inner_ok;
+			tmp[2] = nn->r_vecs[j].hw_csum_rx_error;
+		} while (u64_stats_fetch_retry(&nn->r_vecs[j].rx_sync, start));
+
+		do {
+			start = u64_stats_fetch_begin(&nn->r_vecs[j].tx_sync);
+			data[i++] = nn->r_vecs[j].tx_pkts;
+			data[i++] = nn->r_vecs[j].tx_busy;
+			tmp[3] = nn->r_vecs[j].hw_csum_tx;
+			tmp[4] = nn->r_vecs[j].hw_csum_tx_inner;
+			tmp[5] = nn->r_vecs[j].tx_gather;
+			tmp[6] = nn->r_vecs[j].tx_lso;
+		} while (u64_stats_fetch_retry(&nn->r_vecs[j].tx_sync, start));
+
+		for (k = 0; k < NN_ET_RVEC_GATHER_STATS; k++)
+			gathered_stats[k] += tmp[k];
+	}
+	for (j = 0; j < NN_ET_RVEC_GATHER_STATS; j++)
+		data[i++] = gathered_stats[j];
+	for (j = 0; j < nn->num_tx_rings; j++) {
+		io_p = nn->ctrl_bar + NFP_NET_CFG_TXR_STATS(j);
+		data[i++] = readq(io_p);
+		io_p = nn->ctrl_bar + NFP_NET_CFG_TXR_STATS(j) + 8;
+		data[i++] = readq(io_p);
+	}
+	for (j = 0; j < nn->num_rx_rings; j++) {
+		io_p = nn->ctrl_bar + NFP_NET_CFG_RXR_STATS(j);
+		data[i++] = readq(io_p);
+		io_p = nn->ctrl_bar + NFP_NET_CFG_RXR_STATS(j) + 8;
+		data[i++] = readq(io_p);
+	}
+}
+
+static int nfp_net_get_sset_count(struct net_device *netdev, int sset)
+{
+	struct nfp_net *nn = netdev_priv(netdev);
+
+	switch (sset) {
+	case ETH_SS_STATS:
+		return NN_ET_STATS_LEN;
+	default:
+		return -EOPNOTSUPP;
+	}
+}
+
+/* RX network flow classification (RSS, filters, etc)
+ */
+static int nfp_net_get_rss_hash_opts(struct nfp_net *nn,
+				     struct ethtool_rxnfc *cmd)
+{
+	cmd->data = 0;
+
+	if (!(nn->cap & NFP_NET_CFG_CTRL_RSS))
+		return -EOPNOTSUPP;
+
+	/* Report enabled RSS options */
+	switch (cmd->flow_type) {
+	case TCP_V4_FLOW:
+		if (nn->rss_cfg & NFP_NET_CFG_RSS_IPV4_TCP)
+			cmd->data |= RXH_L4_B_0_1 | RXH_L4_B_2_3;
+		cmd->data |= RXH_IP_SRC | RXH_IP_DST;
+		break;
+	case UDP_V4_FLOW:
+		if (nn->rss_cfg & NFP_NET_CFG_RSS_IPV4_UDP)
+			cmd->data |= RXH_L4_B_0_1 | RXH_L4_B_2_3;
+		cmd->data |= RXH_IP_SRC | RXH_IP_DST;
+		break;
+	case IPV4_FLOW:
+		if (nn->rss_cfg & NFP_NET_CFG_RSS_IPV4)
+			cmd->data |= RXH_L4_B_0_1 | RXH_L4_B_2_3;
+		cmd->data |= RXH_IP_SRC | RXH_IP_DST;
+		break;
+	case TCP_V6_FLOW:
+		if (nn->rss_cfg & NFP_NET_CFG_RSS_IPV6_TCP)
+			cmd->data |= RXH_L4_B_0_1 | RXH_L4_B_2_3;
+		cmd->data |= RXH_IP_SRC | RXH_IP_DST;
+		break;
+	case UDP_V6_FLOW:
+		if (nn->rss_cfg & NFP_NET_CFG_RSS_IPV6_UDP)
+			cmd->data |= RXH_L4_B_0_1 | RXH_L4_B_2_3;
+		cmd->data |= RXH_IP_SRC | RXH_IP_DST;
+		break;
+	case IPV6_FLOW:
+		if (nn->rss_cfg & NFP_NET_CFG_RSS_IPV6)
+			cmd->data |= RXH_L4_B_0_1 | RXH_L4_B_2_3;
+		cmd->data |= RXH_IP_SRC | RXH_IP_DST;
+		break;
+	default:
+		return -EINVAL;
+	}
+
+	return 0;
+}
+
+static int nfp_net_get_rxnfc(struct net_device *netdev,
+			     struct ethtool_rxnfc *cmd, u32 *rule_locs)
+{
+	struct nfp_net *nn = netdev_priv(netdev);
+	int ret = -EOPNOTSUPP;
+
+	switch (cmd->cmd) {
+	case ETHTOOL_GRXRINGS:
+		cmd->data = nn->num_rx_rings;
+		return 0;
+	case ETHTOOL_GRXFH:
+		ret = nfp_net_get_rss_hash_opts(nn, cmd);
+		break;
+	default:
+		break;
+	}
+
+	return ret;
+}
+
+static int nfp_net_set_rss_hash_opt(struct nfp_net *nn,
+				    struct ethtool_rxnfc *nfc)
+{
+	u32 new_rss_cfg = nn->rss_cfg;
+	int err;
+
+	if (!(nn->cap & NFP_NET_CFG_CTRL_RSS))
+		return -EOPNOTSUPP;
+
+	/* RSS only supports IP SA/DA and L4 src/dst ports  */
+	if (nfc->data & ~(RXH_IP_SRC | RXH_IP_DST |
+			  RXH_L4_B_0_1 | RXH_L4_B_2_3))
+		return -EINVAL;
+
+	/* We need at least the IP SA/DA fields for hashing */
+	if (!(nfc->data & RXH_IP_SRC) ||
+	    !(nfc->data & RXH_IP_DST))
+		return -EINVAL;
+
+	switch (nfc->flow_type) {
+	case TCP_V4_FLOW:
+		switch (nfc->data & (RXH_L4_B_0_1 | RXH_L4_B_2_3)) {
+		case 0:
+			new_rss_cfg &= ~NFP_NET_CFG_RSS_IPV4_TCP;
+			break;
+		case (RXH_L4_B_0_1 | RXH_L4_B_2_3):
+			new_rss_cfg |= NFP_NET_CFG_RSS_IPV4_TCP;
+			break;
+		default:
+			return -EINVAL;
+		}
+		break;
+	case TCP_V6_FLOW:
+		switch (nfc->data & (RXH_L4_B_0_1 | RXH_L4_B_2_3)) {
+		case 0:
+			new_rss_cfg &= ~NFP_NET_CFG_RSS_IPV6_TCP;
+			break;
+		case (RXH_L4_B_0_1 | RXH_L4_B_2_3):
+			new_rss_cfg |= NFP_NET_CFG_RSS_IPV6_TCP;
+			break;
+		default:
+			return -EINVAL;
+		}
+		break;
+	case UDP_V4_FLOW:
+		switch (nfc->data & (RXH_L4_B_0_1 | RXH_L4_B_2_3)) {
+		case 0:
+			new_rss_cfg &= ~NFP_NET_CFG_RSS_IPV4_UDP;
+			break;
+		case (RXH_L4_B_0_1 | RXH_L4_B_2_3):
+			new_rss_cfg |= NFP_NET_CFG_RSS_IPV4_UDP;
+			break;
+		default:
+			return -EINVAL;
+		}
+		break;
+	case UDP_V6_FLOW:
+		switch (nfc->data & (RXH_L4_B_0_1 | RXH_L4_B_2_3)) {
+		case 0:
+			new_rss_cfg &= ~NFP_NET_CFG_RSS_IPV6_UDP;
+			break;
+		case (RXH_L4_B_0_1 | RXH_L4_B_2_3):
+			new_rss_cfg |= NFP_NET_CFG_RSS_IPV6_UDP;
+			break;
+		default:
+			return -EINVAL;
+		}
+		break;
+	case IPV4_FLOW:
+		switch (nfc->data & (RXH_L4_B_0_1 | RXH_L4_B_2_3)) {
+		case 0:
+			new_rss_cfg &= ~NFP_NET_CFG_RSS_IPV4;
+			break;
+		case (RXH_L4_B_0_1 | RXH_L4_B_2_3):
+			new_rss_cfg |= NFP_NET_CFG_RSS_IPV4;
+			break;
+		default:
+			return -EINVAL;
+		}
+		break;
+	case IPV6_FLOW:
+		switch (nfc->data & (RXH_L4_B_0_1 | RXH_L4_B_2_3)) {
+		case 0:
+			new_rss_cfg &= ~NFP_NET_CFG_RSS_IPV6;
+			break;
+		case (RXH_L4_B_0_1 | RXH_L4_B_2_3):
+			new_rss_cfg |= NFP_NET_CFG_RSS_IPV6;
+			break;
+		default:
+			return -EINVAL;
+		}
+		break;
+	default:
+		return -EINVAL;
+	}
+
+	new_rss_cfg |= NFP_NET_CFG_RSS_TOEPLITZ;
+	new_rss_cfg |= NFP_NET_CFG_RSS_MASK;
+
+	if (new_rss_cfg == nn->rss_cfg)
+		return 0;
+
+	writel(new_rss_cfg, nn->ctrl_bar + NFP_NET_CFG_RSS_CTRL);
+	err = nfp_net_reconfig(nn, NFP_NET_CFG_UPDATE_RSS);
+	if (err)
+		return err;
+
+	nn->rss_cfg = new_rss_cfg;
+
+	nn_dbg(nn, "Changed RSS config to 0x%x\n", nn->rss_cfg);
+	return 0;
+}
+
+static int nfp_net_set_rxnfc(struct net_device *netdev,
+			     struct ethtool_rxnfc *cmd)
+{
+	struct nfp_net *nn = netdev_priv(netdev);
+	int ret = -EOPNOTSUPP;
+
+	switch (cmd->cmd) {
+	case ETHTOOL_SRXFH:
+		ret = nfp_net_set_rss_hash_opt(nn, cmd);
+		break;
+	default:
+		break;
+	}
+
+	return ret;
+}
+
+static u32 nfp_net_get_rxfh_indir_size(struct net_device *netdev)
+{
+	struct nfp_net *nn = netdev_priv(netdev);
+
+	if (!(nn->cap & NFP_NET_CFG_CTRL_RSS))
+		return 0;
+
+	return ARRAY_SIZE(nn->rss_itbl);
+}
+
+static int nfp_net_get_rxfh(struct net_device *netdev, u32 *indir, u8 *key,
+			    u8 *hfunc)
+{
+	struct nfp_net *nn = netdev_priv(netdev);
+	int i;
+
+	if (!(nn->cap & NFP_NET_CFG_CTRL_RSS))
+		return -EOPNOTSUPP;
+
+	if (indir)
+		for (i = 0; i < ARRAY_SIZE(nn->rss_itbl); i++)
+			indir[i] = nn->rss_itbl[i];
+
+	if (hfunc)
+		*hfunc = ETH_RSS_HASH_UNKNOWN;
+
+	return 0;
+}
+
+static int nfp_net_set_rxfh(struct net_device *netdev,
+			    const u32 *indir, const u8 *key,
+			    const u8 hfunc)
+{
+	struct nfp_net *nn = netdev_priv(netdev);
+	int i;
+
+	if (!(nn->cap & NFP_NET_CFG_CTRL_RSS) ||
+	    !(hfunc == ETH_RSS_HASH_NO_CHANGE || hfunc == ETH_RSS_HASH_TOP) ||
+	    key)
+		return -EOPNOTSUPP;
+	if (!indir)
+		return 0;
+
+	for (i = 0; i < ARRAY_SIZE(nn->rss_itbl); i++)
+		nn->rss_itbl[i] = indir[i];
+
+	nfp_net_rss_write_itbl(nn);
+	return nfp_net_reconfig(nn, NFP_NET_CFG_UPDATE_RSS);
+}
+
+/* Dump BAR registers
+ */
+static int nfp_net_get_regs_len(struct net_device *netdev)
+{
+	return NFP_NET_CFG_BAR_SZ;
+}
+
+static void nfp_net_get_regs(struct net_device *netdev,
+			     struct ethtool_regs *regs, void *p)
+{
+	struct nfp_net *nn = netdev_priv(netdev);
+	u32 *regs_buf = p;
+	int i;
+
+	regs->version = nn->ver;
+
+	for (i = 0; i < NFP_NET_CFG_BAR_SZ / sizeof(u32); i++)
+		regs_buf[i] = readl(nn->ctrl_bar + (i * sizeof(u32)));
+}
+
+static int nfp_net_get_coalesce(struct net_device *netdev,
+				struct ethtool_coalesce *ec)
+{
+	struct nfp_net *nn = netdev_priv(netdev);
+
+	if (!(nn->pdev->msix_enabled && (nn->cap & NFP_NET_CFG_CTRL_IRQMOD)))
+		return -EINVAL;
+
+	ec->rx_coalesce_usecs       = nn->rx_coalesce_usecs;
+	ec->rx_max_coalesced_frames = nn->rx_coalesce_max_frames;
+	ec->tx_coalesce_usecs       = nn->tx_coalesce_usecs;
+	ec->tx_max_coalesced_frames = nn->tx_coalesce_max_frames;
+
+	return 0;
+}
+
+static int nfp_net_set_coalesce(struct net_device *netdev,
+				struct ethtool_coalesce *ec)
+{
+	struct nfp_net *nn = netdev_priv(netdev);
+	unsigned int factor;
+
+	if (ec->rx_coalesce_usecs_irq ||
+	    ec->rx_max_coalesced_frames_irq ||
+	    ec->tx_coalesce_usecs_irq ||
+	    ec->tx_max_coalesced_frames_irq ||
+	    ec->stats_block_coalesce_usecs ||
+	    ec->use_adaptive_rx_coalesce ||
+	    ec->use_adaptive_tx_coalesce ||
+	    ec->pkt_rate_low ||
+	    ec->rx_coalesce_usecs_low ||
+	    ec->rx_max_coalesced_frames_low ||
+	    ec->tx_coalesce_usecs_low ||
+	    ec->tx_max_coalesced_frames_low ||
+	    ec->pkt_rate_high ||
+	    ec->rx_coalesce_usecs_high ||
+	    ec->rx_max_coalesced_frames_high ||
+	    ec->tx_coalesce_usecs_high ||
+	    ec->tx_max_coalesced_frames_high ||
+	    ec->rate_sample_interval)
+		return -ENOTSUPP;
+
+	/* Compute factor used to convert coalesce '_usecs' parameters to
+	 * ME timestamp ticks.  There are 16 ME clock cycles for each timestamp
+	 * count.
+	 */
+	factor = nn->me_freq_mhz / 16;
+
+	/* Each pair of (usecs, max_frames) fields specifies that interrupts
+	 * should be coalesced until
+	 *      (usecs > 0 && time_since_first_completion >= usecs) ||
+	 *      (max_frames > 0 && completed_frames >= max_frames)
+	 *
+	 * It is illegal to set both usecs and max_frames to zero as this would
+	 * cause interrupts to never be generated.  To disable coalescing, set
+	 * usecs = 0 and max_frames = 1.
+	 *
+	 * Some implementations ignore the value of max_frames and use the
+	 * condition time_since_first_completion >= usecs
+	 */
+
+	if (!(nn->pdev->msix_enabled && (nn->cap & NFP_NET_CFG_CTRL_IRQMOD)))
+		return -EINVAL;
+
+	/* ensure valid configuration */
+	if (!ec->rx_coalesce_usecs && !ec->rx_max_coalesced_frames)
+		return -EINVAL;
+
+	if (!ec->tx_coalesce_usecs && !ec->tx_max_coalesced_frames)
+		return -EINVAL;
+
+	if (ec->rx_coalesce_usecs * factor >= ((1 << 16) - 1))
+		return -EINVAL;
+
+	if (ec->tx_coalesce_usecs * factor >= ((1 << 16) - 1))
+		return -EINVAL;
+
+	if (ec->rx_max_coalesced_frames >= ((1 << 16) - 1))
+		return -EINVAL;
+
+	if (ec->tx_max_coalesced_frames >= ((1 << 16) - 1))
+		return -EINVAL;
+
+	/* configuration is valid */
+	nn->rx_coalesce_usecs      = ec->rx_coalesce_usecs;
+	nn->rx_coalesce_max_frames = ec->rx_max_coalesced_frames;
+	nn->tx_coalesce_usecs      = ec->tx_coalesce_usecs;
+	nn->tx_coalesce_max_frames = ec->tx_max_coalesced_frames;
+
+	/* write configuration to device */
+	nfp_net_coalesce_write_cfg(nn);
+	return nfp_net_reconfig(nn, NFP_NET_CFG_UPDATE_IRQMOD);
+}
+
+static const struct ethtool_ops nfp_net_ethtool_ops = {
+	.get_drvinfo		= nfp_net_get_drvinfo,
+	.get_ringparam		= nfp_net_get_ringparam,
+	.set_ringparam		= nfp_net_set_ringparam,
+	.get_strings		= nfp_net_get_strings,
+	.get_ethtool_stats	= nfp_net_get_stats,
+	.get_sset_count		= nfp_net_get_sset_count,
+	.get_rxnfc		= nfp_net_get_rxnfc,
+	.set_rxnfc		= nfp_net_set_rxnfc,
+	.get_rxfh_indir_size	= nfp_net_get_rxfh_indir_size,
+	.get_rxfh		= nfp_net_get_rxfh,
+	.set_rxfh		= nfp_net_set_rxfh,
+	.get_regs_len		= nfp_net_get_regs_len,
+	.get_regs		= nfp_net_get_regs,
+	.get_coalesce           = nfp_net_get_coalesce,
+	.set_coalesce           = nfp_net_set_coalesce,
+};
+
+void nfp_net_set_ethtool_ops(struct net_device *netdev)
+{
+	netdev->ethtool_ops = &nfp_net_ethtool_ops;
+}
diff --git a/drivers/net/ethernet/netronome/nfp/nfp_netvf_main.c b/drivers/net/ethernet/netronome/nfp/nfp_netvf_main.c
new file mode 100644
index 000000000000..7f2b9a2e9c03
--- /dev/null
+++ b/drivers/net/ethernet/netronome/nfp/nfp_netvf_main.c
@@ -0,0 +1,404 @@
+/*
+ * Copyright (C) 2015 Netronome Systems, Inc.
+ *
+ * This software is dual licensed under the GNU General License Version 2,
+ * June 1991 as shown in the file COPYING in the top-level directory of this
+ * source tree or the BSD 2-Clause License provided below.  You have the
+ * option to license this software under the complete terms of either license.
+ *
+ * The BSD 2-Clause License:
+ *
+ *     Redistribution and use in source and binary forms, with or
+ *     without modification, are permitted provided that the following
+ *     conditions are met:
+ *
+ *      1. Redistributions of source code must retain the above
+ *         copyright notice, this list of conditions and the following
+ *         disclaimer.
+ *
+ *      2. Redistributions in binary form must reproduce the above
+ *         copyright notice, this list of conditions and the following
+ *         disclaimer in the documentation and/or other materials
+ *         provided with the distribution.
+ *
+ * THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND,
+ * EXPRESS OR IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF
+ * MERCHANTABILITY, FITNESS FOR A PARTICULAR PURPOSE AND
+ * NONINFRINGEMENT. IN NO EVENT SHALL THE AUTHORS OR COPYRIGHT HOLDERS
+ * BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER LIABILITY, WHETHER IN AN
+ * ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM, OUT OF OR IN
+ * CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN THE
+ * SOFTWARE.
+ */
+
+/*
+ * nfp_netvf_main.c
+ * Netronome virtual function network device driver: Main entry point
+ * Author: Jason McMullan <jason.mcmullan@netronome.com>
+ *         Rolf Neugebauer <rolf.neugebauer@netronome.com>
+ */
+
+#include <linux/version.h>
+#include <linux/module.h>
+#include <linux/kernel.h>
+#include <linux/init.h>
+#include <linux/etherdevice.h>
+
+#include "nfp_net_ctrl.h"
+#include "nfp_net.h"
+
+const char nfp_net_driver_name[] = "nfp_netvf";
+const char nfp_net_driver_version[] = "0.1";
+#define PCI_DEVICE_NFP6000VF		0x6003
+static const struct pci_device_id nfp_netvf_pci_device_ids[] = {
+	{ PCI_VENDOR_ID_NETRONOME, PCI_DEVICE_NFP6000VF,
+	  PCI_VENDOR_ID_NETRONOME, PCI_ANY_ID,
+	  PCI_ANY_ID, 0,
+	},
+	{ 0, } /* Required last entry. */
+};
+MODULE_DEVICE_TABLE(pci, nfp_netvf_pci_device_ids);
+
+static void nfp_netvf_get_mac_addr(struct nfp_net *nn)
+{
+	u8 mac_addr[ETH_ALEN];
+
+	put_unaligned_be32(nn_readl(nn, NFP_NET_CFG_MACADDR + 0), &mac_addr[0]);
+	/* We can't do readw for NFP-3200 compatibility */
+	put_unaligned_be16(nn_readl(nn, NFP_NET_CFG_MACADDR + 4) >> 16,
+			   &mac_addr[4]);
+
+	if (!is_valid_ether_addr(mac_addr)) {
+		eth_hw_addr_random(nn->netdev);
+		return;
+	}
+
+	ether_addr_copy(nn->netdev->dev_addr, mac_addr);
+	ether_addr_copy(nn->netdev->perm_addr, mac_addr);
+}
+
+static int nfp_netvf_pci_probe(struct pci_dev *pdev,
+			       const struct pci_device_id *pci_id)
+{
+	int max_tx_rings, max_rx_rings;
+	u32 tx_bar_off, rx_bar_off;
+	u32 tx_bar_sz, rx_bar_sz;
+	int tx_bar_no, rx_bar_no;
+	u8 __iomem *ctrl_bar;
+	struct nfp_net *nn;
+	int is_nfp3200;
+	u32 version;
+	u32 startq;
+	int stride;
+	int err;
+
+	err = pci_enable_device_mem(pdev);
+	if (err)
+		return err;
+
+	err = pci_request_regions(pdev, nfp_net_driver_name);
+	if (err) {
+		dev_err(&pdev->dev, "Unable to allocate device memory.\n");
+		goto err_pci_regions;
+	}
+
+	switch (pdev->device) {
+	case PCI_DEVICE_NFP6000VF:
+		is_nfp3200 = 0;
+		break;
+	default:
+		err = -ENODEV;
+		goto err_dma_mask;
+	}
+
+	pci_set_master(pdev);
+
+	err = dma_set_mask_and_coherent(&pdev->dev,
+					DMA_BIT_MASK(NFP_NET_MAX_DMA_BITS));
+	if (err)
+		goto err_dma_mask;
+
+	/* Map the Control BAR.
+	 *
+	 * Irrespective of the advertised BAR size we only map the
+	 * first NFP_NET_CFG_BAR_SZ of the BAR.  This keeps the code
+	 * the identical for PF and VF drivers.
+	 */
+	ctrl_bar = ioremap_nocache(pci_resource_start(pdev, NFP_NET_CRTL_BAR),
+				   NFP_NET_CFG_BAR_SZ);
+	if (!ctrl_bar) {
+		dev_err(&pdev->dev,
+			"Failed to map resource %d\n", NFP_NET_CRTL_BAR);
+		err = -EIO;
+		goto err_dma_mask;
+	}
+
+	/* Determine stride */
+	version = readl(ctrl_bar + NFP_NET_CFG_VERSION);
+
+	if ((NFP_NET_CFG_VERSION_CLASS_MASK & version) !=
+	    NFP_NET_CFG_VERSION_CLASS(NFP_NET_CFG_VERSION_CLASS_GENERIC)) {
+		/* We only support the Generic Class */
+		dev_err(&pdev->dev, "Unknown Firmware ABI %d.%d.%d.%d\n",
+			(version >> 24) & 0xff, (version >> 16) & 0xff,
+			(version >>  8) & 0xff, (version >>  0) & 0xff);
+		err = -EINVAL;
+		goto err_nn_init;
+	}
+
+	if (version == 0x00000000 ||
+	    version == 0x00000001 ||
+	    version == 0x00001248) {
+		stride = 2;
+		tx_bar_no = NFP_NET_Q0_BAR;
+		rx_bar_no = NFP_NET_Q1_BAR;
+		dev_warn(&pdev->dev, "OBSOLETE Firmware detected - VF isolation not available\n");
+	} else {
+		switch (NFP_NET_CFG_VERSION_MAJOR_MASK & version) {
+		case NFP_NET_CFG_VERSION_MAJOR(1):
+		case NFP_NET_CFG_VERSION_MAJOR(2):
+			if (is_nfp3200) {
+				stride = 2;
+				tx_bar_no = NFP_NET_Q0_BAR;
+				rx_bar_no = NFP_NET_Q1_BAR;
+			} else {
+				stride = 4;
+				tx_bar_no = NFP_NET_Q0_BAR;
+				rx_bar_no = tx_bar_no;
+			}
+			break;
+		default:
+			dev_err(&pdev->dev, "Unsupported Firmware ABI %d.%d.%d.%d\n",
+				(version >> 24) & 0xff, (version >> 16) & 0xff,
+				(version >>  8) & 0xff,	(version >>  0) & 0xff);
+			err = -EINVAL;
+			goto err_nn_init;
+		}
+	}
+
+	/* Find out how many rings are supported */
+	max_tx_rings = readl(ctrl_bar + NFP_NET_CFG_MAX_TXRINGS);
+	max_rx_rings = readl(ctrl_bar + NFP_NET_CFG_MAX_RXRINGS);
+
+	tx_bar_sz = NFP_QCP_QUEUE_ADDR_SZ * max_tx_rings * stride;
+	rx_bar_sz = NFP_QCP_QUEUE_ADDR_SZ * max_rx_rings * stride;
+
+	/* Sanity checks */
+	if (tx_bar_sz > pci_resource_len(pdev, tx_bar_no)) {
+		dev_err(&pdev->dev,
+			"TX BAR too small for number of TX rings. Adjusting");
+		tx_bar_sz = pci_resource_len(pdev, tx_bar_no);
+		max_tx_rings = (tx_bar_sz / NFP_QCP_QUEUE_ADDR_SZ) / 2;
+	}
+	if (rx_bar_sz > pci_resource_len(pdev, rx_bar_no)) {
+		dev_err(&pdev->dev,
+			"RX BAR too small for number of RX rings. Adjusting");
+		rx_bar_sz = pci_resource_len(pdev, rx_bar_no);
+		max_rx_rings = (rx_bar_sz / NFP_QCP_QUEUE_ADDR_SZ) / 2;
+	}
+
+	/* XXX Implement a workaround for THB-350 here.  Ideally, we
+	 * have a different PCI ID for A rev VFs.
+	 */
+	switch (pdev->device) {
+	case PCI_DEVICE_NFP6000VF:
+		startq = readl(ctrl_bar + NFP_NET_CFG_START_TXQ);
+		tx_bar_off = NFP_PCIE_QUEUE(startq);
+		startq = readl(ctrl_bar + NFP_NET_CFG_START_RXQ);
+		rx_bar_off = NFP_PCIE_QUEUE(startq);
+		break;
+	default:
+		err = -ENODEV;
+		goto err_nn_init;
+	}
+
+	/* Allocate and initialise the netdev */
+	nn = nfp_net_netdev_alloc(pdev, max_tx_rings, max_rx_rings);
+	if (IS_ERR(nn)) {
+		err = PTR_ERR(nn);
+		goto err_nn_init;
+	}
+
+	nn->ver = version;
+	nn->ctrl_bar = ctrl_bar;
+	nn->is_vf = 1;
+	nn->is_nfp3200 = is_nfp3200;
+	nn->stride_tx = stride;
+	nn->stride_rx = stride;
+
+	if (rx_bar_no == tx_bar_no) {
+		u32 bar_off, bar_sz;
+		resource_size_t map_addr;
+
+		/* Make a single overlapping BAR mapping */
+		if (tx_bar_off < rx_bar_off)
+			bar_off = tx_bar_off;
+		else
+			bar_off = rx_bar_off;
+
+		if ((tx_bar_off + tx_bar_sz) > (rx_bar_off + rx_bar_sz))
+			bar_sz = (tx_bar_off + tx_bar_sz) - bar_off;
+		else
+			bar_sz = (rx_bar_off + rx_bar_sz) - bar_off;
+
+		map_addr = pci_resource_start(pdev, tx_bar_no) + bar_off;
+		nn->q_bar = ioremap_nocache(map_addr, bar_sz);
+		if (!nn->q_bar) {
+			nn_err(nn, "Failed to map resource %d", tx_bar_no);
+			err = -EIO;
+			goto err_barmap_tx;
+		}
+
+		/* TX queues */
+		nn->tx_bar = nn->q_bar + (tx_bar_off - bar_off);
+		/* RX queues */
+		nn->rx_bar = nn->q_bar + (rx_bar_off - bar_off);
+	} else {
+		resource_size_t map_addr;
+
+		/* TX queues */
+		map_addr = pci_resource_start(pdev, tx_bar_no) + tx_bar_off;
+		nn->tx_bar = ioremap_nocache(map_addr, tx_bar_sz);
+		if (!nn->tx_bar) {
+			nn_err(nn, "Failed to map resource %d", tx_bar_no);
+			err = -EIO;
+			goto err_barmap_tx;
+		}
+
+		/* RX queues */
+		map_addr = pci_resource_start(pdev, rx_bar_no) + rx_bar_off;
+		nn->rx_bar = ioremap_nocache(map_addr, rx_bar_sz);
+		if (!nn->rx_bar) {
+			nn_err(nn, "Failed to map resource %d", rx_bar_no);
+			err = -EIO;
+			goto err_barmap_rx;
+		}
+	}
+
+	nfp_netvf_get_mac_addr(nn);
+
+	err = nfp_net_irqs_alloc(nn);
+	if (!err) {
+		nn_warn(nn, "Unable to allocate MSI-X Vectors. Exiting\n");
+		err = -EIO;
+		goto err_irqs_alloc;
+	}
+
+	if (pdev->msix_enabled) {
+		nn->msix_table = nfp_net_msix_map(pdev, 255);
+		if (!nn->msix_table) {
+			err = -EIO;
+			goto err_map_msix_table;
+		}
+	}
+
+	/* Get ME clock frequency from ctrl BAR
+	 * XXX for now frequency is hardcoded until we figure out how
+	 * to get the value from nfp-hwinfo into ctrl bar
+	 */
+	nn->me_freq_mhz = 1200;
+
+	err = nfp_net_netdev_init(nn->netdev);
+	if (err)
+		goto err_netdev_init;
+
+	pci_set_drvdata(pdev, nn);
+
+	nfp_net_info(nn);
+	nfp_net_debugfs_adapter_add(nn);
+
+	return 0;
+
+err_netdev_init:
+	if (nn->msix_table)
+		iounmap(nn->msix_table);
+err_map_msix_table:
+	nfp_net_irqs_disable(nn);
+err_irqs_alloc:
+	if (!nn->q_bar)
+		iounmap(nn->rx_bar);
+err_barmap_rx:
+	if (!nn->q_bar)
+		iounmap(nn->tx_bar);
+	else
+		iounmap(nn->q_bar);
+err_barmap_tx:
+	pci_set_drvdata(pdev, NULL);
+	nfp_net_netdev_free(nn);
+err_nn_init:
+	iounmap(ctrl_bar);
+err_dma_mask:
+	pci_release_regions(pdev);
+err_pci_regions:
+	pci_disable_device(pdev);
+	return err;
+}
+
+static void nfp_netvf_pci_remove(struct pci_dev *pdev)
+{
+	struct nfp_net *nn = pci_get_drvdata(pdev);
+
+	/* Note, the order is slightly different from above as we need
+	 * to keep the nn pointer around till we have freed everything.
+	 */
+	nfp_net_debugfs_adapter_del(nn);
+
+	nn->removing_pdev = 1;
+	nfp_net_netdev_clean(nn->netdev);
+
+	if (nn->msix_table)
+		iounmap(nn->msix_table);
+	nfp_net_irqs_disable(nn);
+
+	if (!nn->q_bar) {
+		iounmap(nn->rx_bar);
+		iounmap(nn->tx_bar);
+	} else {
+		iounmap(nn->q_bar);
+	}
+	iounmap(nn->ctrl_bar);
+
+	pci_set_drvdata(pdev, NULL);
+
+	nfp_net_netdev_free(nn);
+
+	pci_release_regions(pdev);
+	pci_disable_device(pdev);
+}
+
+static struct pci_driver nfp_netvf_pci_driver = {
+	.name        = nfp_net_driver_name,
+	.id_table    = nfp_netvf_pci_device_ids,
+	.probe       = nfp_netvf_pci_probe,
+	.remove      = nfp_netvf_pci_remove,
+};
+
+static int __init nfp_netvf_init(void)
+{
+	int err;
+
+	pr_info("%s: NFP VF Network driver, Copyright (C) 2014-2015 Netronome Systems\n",
+		nfp_net_driver_name);
+
+	nfp_net_debugfs_create();
+	err = pci_register_driver(&nfp_netvf_pci_driver);
+	if (err) {
+		nfp_net_debugfs_destroy();
+		return err;
+	}
+
+	return 0;
+}
+
+static void __exit nfp_netvf_exit(void)
+{
+	pci_unregister_driver(&nfp_netvf_pci_driver);
+	nfp_net_debugfs_destroy();
+}
+
+module_init(nfp_netvf_init);
+module_exit(nfp_netvf_exit);
+
+MODULE_AUTHOR("Netronome Systems <oss-drivers@netronome.com>");
+MODULE_LICENSE("GPL");
+MODULE_DESCRIPTION("NFP VF network device driver");
-- 
1.9.1
