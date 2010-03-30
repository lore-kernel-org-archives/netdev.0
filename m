From: Dimitris Michailidis <dm@chelsio.com>
Subject: [PATCH 4/6] cxgb4: Add remaining driver headers and L2T management
Date: Tue, 30 Mar 2010 10:52:20 -0800
Message-ID: <1269975142-30896-5-git-send-email-dm@chelsio.com>
References: <1269975142-30896-1-git-send-email-dm@chelsio.com>
 <1269975142-30896-2-git-send-email-dm@chelsio.com>
 <1269975142-30896-3-git-send-email-dm@chelsio.com>
 <1269975142-30896-4-git-send-email-dm@chelsio.com>
Cc: Dimitris Michailidis <dm@chelsio.com>
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from stargate.chelsio.com ([67.207.112.58]:31181 "EHLO
	stargate.chelsio.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1755287Ab0C3SwX (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 30 Mar 2010 14:52:23 -0400
Received: from maui.asicdesigners.com (maui.asicdesigners.com [10.192.180.15])
	by stargate.chelsio.com (8.13.1/8.13.1) with SMTP id o2UIqOoY011244
	for <netdev@vger.kernel.org>; Tue, 30 Mar 2010 11:52:24 -0700
In-Reply-To: <1269975142-30896-4-git-send-email-dm@chelsio.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Signed-off-by: Dimitris Michailidis <dm@chelsio.com>
---
 drivers/net/cxgb4/cxgb4.h     |  743 +++++++++++++++++++++++++++++++++++++++++
 drivers/net/cxgb4/cxgb4_uld.h |  235 +++++++++++++
 drivers/net/cxgb4/l2t.c       |  626 ++++++++++++++++++++++++++++++++++
 drivers/net/cxgb4/l2t.h       |  110 ++++++
 4 files changed, 1714 insertions(+), 0 deletions(-)
 create mode 100644 drivers/net/cxgb4/cxgb4.h
 create mode 100644 drivers/net/cxgb4/cxgb4_uld.h
 create mode 100644 drivers/net/cxgb4/l2t.c
 create mode 100644 drivers/net/cxgb4/l2t.h

diff --git a/drivers/net/cxgb4/cxgb4.h b/drivers/net/cxgb4/cxgb4.h
new file mode 100644
index 0000000..ca162ef
--- /dev/null
+++ b/drivers/net/cxgb4/cxgb4.h
@@ -0,0 +1,743 @@
+/*
+ * This file is part of the Chelsio T4 Ethernet driver for Linux.
+ *
+ * Copyright (c) 2003-2010 Chelsio Communications, Inc. All rights reserved.
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
+ */
+
+#ifndef __CXGB4_H__
+#define __CXGB4_H__
+
+#include <linux/bitops.h>
+#include <linux/cache.h>
+#include <linux/interrupt.h>
+#include <linux/list.h>
+#include <linux/netdevice.h>
+#include <linux/pci.h>
+#include <linux/spinlock.h>
+#include <linux/timer.h>
+#include <asm/io.h>
+#include "cxgb4_uld.h"
+#include "t4_hw.h"
+
+#define FW_VERSION_MAJOR 1
+#define FW_VERSION_MINOR 1
+#define FW_VERSION_MICRO 0
+
+enum {
+	MAX_NPORTS = 4,     /* max # of ports */
+	SERNUM_LEN = 16,    /* Serial # length */
+	EC_LEN     = 16,    /* E/C length */
+	ID_LEN     = 16,    /* ID length */
+};
+
+enum {
+	MEM_EDC0,
+	MEM_EDC1,
+	MEM_MC
+};
+
+enum dev_master {
+	MASTER_CANT,
+	MASTER_MAY,
+	MASTER_MUST
+};
+
+enum dev_state {
+	DEV_STATE_UNINIT,
+	DEV_STATE_INIT,
+	DEV_STATE_ERR
+};
+
+enum {
+	PAUSE_RX      = 1 << 0,
+	PAUSE_TX      = 1 << 1,
+	PAUSE_AUTONEG = 1 << 2
+};
+
+struct port_stats {
+	u64 tx_octets;            /* total # of octets in good frames */
+	u64 tx_frames;            /* all good frames */
+	u64 tx_bcast_frames;      /* all broadcast frames */
+	u64 tx_mcast_frames;      /* all multicast frames */
+	u64 tx_ucast_frames;      /* all unicast frames */
+	u64 tx_error_frames;      /* all error frames */
+
+	u64 tx_frames_64;         /* # of Tx frames in a particular range */
+	u64 tx_frames_65_127;
+	u64 tx_frames_128_255;
+	u64 tx_frames_256_511;
+	u64 tx_frames_512_1023;
+	u64 tx_frames_1024_1518;
+	u64 tx_frames_1519_max;
+
+	u64 tx_drop;              /* # of dropped Tx frames */
+	u64 tx_pause;             /* # of transmitted pause frames */
+	u64 tx_ppp0;              /* # of transmitted PPP prio 0 frames */
+	u64 tx_ppp1;              /* # of transmitted PPP prio 1 frames */
+	u64 tx_ppp2;              /* # of transmitted PPP prio 2 frames */
+	u64 tx_ppp3;              /* # of transmitted PPP prio 3 frames */
+	u64 tx_ppp4;              /* # of transmitted PPP prio 4 frames */
+	u64 tx_ppp5;              /* # of transmitted PPP prio 5 frames */
+	u64 tx_ppp6;              /* # of transmitted PPP prio 6 frames */
+	u64 tx_ppp7;              /* # of transmitted PPP prio 7 frames */
+
+	u64 rx_octets;            /* total # of octets in good frames */
+	u64 rx_frames;            /* all good frames */
+	u64 rx_bcast_frames;      /* all broadcast frames */
+	u64 rx_mcast_frames;      /* all multicast frames */
+	u64 rx_ucast_frames;      /* all unicast frames */
+	u64 rx_too_long;          /* # of frames exceeding MTU */
+	u64 rx_jabber;            /* # of jabber frames */
+	u64 rx_fcs_err;           /* # of received frames with bad FCS */
+	u64 rx_len_err;           /* # of received frames with length error */
+	u64 rx_symbol_err;        /* symbol errors */
+	u64 rx_runt;              /* # of short frames */
+
+	u64 rx_frames_64;         /* # of Rx frames in a particular range */
+	u64 rx_frames_65_127;
+	u64 rx_frames_128_255;
+	u64 rx_frames_256_511;
+	u64 rx_frames_512_1023;
+	u64 rx_frames_1024_1518;
+	u64 rx_frames_1519_max;
+
+	u64 rx_pause;             /* # of received pause frames */
+	u64 rx_ppp0;              /* # of received PPP prio 0 frames */
+	u64 rx_ppp1;              /* # of received PPP prio 1 frames */
+	u64 rx_ppp2;              /* # of received PPP prio 2 frames */
+	u64 rx_ppp3;              /* # of received PPP prio 3 frames */
+	u64 rx_ppp4;              /* # of received PPP prio 4 frames */
+	u64 rx_ppp5;              /* # of received PPP prio 5 frames */
+	u64 rx_ppp6;              /* # of received PPP prio 6 frames */
+	u64 rx_ppp7;              /* # of received PPP prio 7 frames */
+
+	u64 rx_ovflow0;           /* drops due to buffer-group 0 overflows */
+	u64 rx_ovflow1;           /* drops due to buffer-group 1 overflows */
+	u64 rx_ovflow2;           /* drops due to buffer-group 2 overflows */
+	u64 rx_ovflow3;           /* drops due to buffer-group 3 overflows */
+	u64 rx_trunc0;            /* buffer-group 0 truncated packets */
+	u64 rx_trunc1;            /* buffer-group 1 truncated packets */
+	u64 rx_trunc2;            /* buffer-group 2 truncated packets */
+	u64 rx_trunc3;            /* buffer-group 3 truncated packets */
+};
+
+struct lb_port_stats {
+	u64 octets;
+	u64 frames;
+	u64 bcast_frames;
+	u64 mcast_frames;
+	u64 ucast_frames;
+	u64 error_frames;
+
+	u64 frames_64;
+	u64 frames_65_127;
+	u64 frames_128_255;
+	u64 frames_256_511;
+	u64 frames_512_1023;
+	u64 frames_1024_1518;
+	u64 frames_1519_max;
+
+	u64 drop;
+
+	u64 ovflow0;
+	u64 ovflow1;
+	u64 ovflow2;
+	u64 ovflow3;
+	u64 trunc0;
+	u64 trunc1;
+	u64 trunc2;
+	u64 trunc3;
+};
+
+struct tp_tcp_stats {
+	u32 tcpOutRsts;
+	u64 tcpInSegs;
+	u64 tcpOutSegs;
+	u64 tcpRetransSegs;
+};
+
+struct tp_err_stats {
+	u32 macInErrs[4];
+	u32 hdrInErrs[4];
+	u32 tcpInErrs[4];
+	u32 tnlCongDrops[4];
+	u32 ofldChanDrops[4];
+	u32 tnlTxDrops[4];
+	u32 ofldVlanDrops[4];
+	u32 tcp6InErrs[4];
+	u32 ofldNoNeigh;
+	u32 ofldCongDefer;
+};
+
+struct tp_params {
+	unsigned int ntxchan;        /* # of Tx channels */
+	unsigned int tre;            /* log2 of core clocks per TP tick */
+};
+
+struct vpd_params {
+	unsigned int cclk;
+	u8 ec[EC_LEN + 1];
+	u8 sn[SERNUM_LEN + 1];
+	u8 id[ID_LEN + 1];
+};
+
+struct pci_params {
+	unsigned char speed;
+	unsigned char width;
+};
+
+struct adapter_params {
+	struct tp_params  tp;
+	struct vpd_params vpd;
+	struct pci_params pci;
+
+	unsigned int fw_vers;
+	unsigned int tp_vers;
+	u8 api_vers[7];
+
+	unsigned short mtus[NMTUS];
+	unsigned short a_wnd[NCCTRL_WIN];
+	unsigned short b_wnd[NCCTRL_WIN];
+
+	unsigned char nports;             /* # of ethernet ports */
+	unsigned char portvec;
+	unsigned char rev;                /* chip revision */
+	unsigned char offload;
+
+	unsigned int ofldq_wr_cred;
+};
+
+struct trace_params {
+	u32 data[TRACE_LEN / 4];
+	u32 mask[TRACE_LEN / 4];
+	unsigned short snap_len;
+	unsigned short min_len;
+	unsigned char skip_ofst;
+	unsigned char skip_len;
+	unsigned char invert;
+	unsigned char port;
+};
+
+struct link_config {
+	unsigned short supported;        /* link capabilities */
+	unsigned short advertising;      /* advertised capabilities */
+	unsigned short requested_speed;  /* speed user has requested */
+	unsigned short speed;            /* actual link speed */
+	unsigned char  requested_fc;     /* flow control user has requested */
+	unsigned char  fc;               /* actual link flow control */
+	unsigned char  autoneg;          /* autonegotiating? */
+	unsigned char  link_ok;          /* link up? */
+};
+
+#define FW_LEN16(fw_struct) FW_CMD_LEN16(sizeof(fw_struct) / 16)
+
+enum {
+	MAX_ETH_QSETS = 32,           /* # of Ethernet Tx/Rx queue sets */
+	MAX_OFLD_QSETS = 16,          /* # of offload Tx/Rx queue sets */
+	MAX_CTRL_QUEUES = NCHAN,      /* # of control Tx queues */
+	MAX_RDMA_QUEUES = NCHAN,      /* # of streaming RDMA Rx queues */
+};
+
+enum {
+	MAX_EGRQ = 128,         /* max # of egress queues, including FLs */
+	MAX_INGQ = 64           /* max # of interrupt-capable ingress queues */
+};
+
+struct adapter;
+struct vlan_group;
+struct sge_rspq;
+
+struct port_info {
+	struct adapter *adapter;
+	struct vlan_group *vlan_grp;
+	u16    viid;
+	s16    xact_addr_filt;        /* index of exact MAC address filter */
+	u16    rss_size;              /* size of VI's RSS table slice */
+	s8     mdio_addr;
+	u8     port_type;
+	u8     mod_type;
+	u8     port_id;
+	u8     tx_chan;
+	u8     lport;                 /* associated offload logical port */
+	u8     rx_offload;            /* CSO, etc */
+	u8     nqsets;                /* # of qsets */
+	u8     first_qset;            /* index of first qset */
+	struct link_config link_cfg;
+};
+
+/* port_info.rx_offload flags */
+enum {
+	RX_CSO = 1 << 0,
+};
+
+struct dentry;
+struct work_struct;
+struct proc_dir_entry;
+
+enum {                                 /* adapter flags */
+	FULL_INIT_DONE     = (1 << 0),
+	USING_MSI          = (1 << 1),
+	USING_MSIX         = (1 << 2),
+	QUEUES_BOUND       = (1 << 3),
+	FW_OK              = (1 << 4),
+};
+
+struct rx_sw_desc;
+
+struct sge_fl {                     /* SGE free-buffer queue state */
+	unsigned int avail;         /* # of available Rx buffers */
+	unsigned int pend_cred;     /* new buffers since last FL DB ring */
+	unsigned int cidx;          /* consumer index */
+	unsigned int pidx;          /* producer index */
+	unsigned long alloc_failed; /* # of times buffer allocation failed */
+	unsigned long large_alloc_failed;
+	unsigned long starving;
+	/* RO fields */
+	unsigned int cntxt_id;      /* SGE context id for the free list */
+	unsigned int size;          /* capacity of free list */
+	struct rx_sw_desc *sdesc;   /* address of SW Rx descriptor ring */
+	__be64 *desc;               /* address of HW Rx descriptor ring */
+	dma_addr_t addr;            /* bus address of HW ring start */
+};
+
+/* A packet gather list */
+struct pkt_gl {
+	skb_frag_t frags[MAX_SKB_FRAGS];
+	void *va;                         /* virtual address of first byte */
+	unsigned int nfrags;              /* # of fragments */
+	unsigned int tot_len;             /* total length of fragments */
+};
+
+typedef int (*rspq_handler_t)(struct sge_rspq *q, const __be64 *rsp,
+			      const struct pkt_gl *gl);
+
+struct sge_rspq {                   /* state for an SGE response queue */
+	struct napi_struct napi;
+	const __be64 *cur_desc;     /* current descriptor in queue */
+	unsigned int cidx;          /* consumer index */
+	u8 gen;                     /* current generation bit */
+	u8 intr_params;             /* interrupt holdoff parameters */
+	u8 next_intr_params;        /* holdoff params for next interrupt */
+	u8 pktcnt_idx;              /* interrupt packet threshold */
+	u8 uld;                     /* ULD handling this queue */
+	u8 idx;                     /* queue index within its group */
+	int offset;                 /* offset into current Rx buffer */
+	u16 cntxt_id;               /* SGE context id for the response q */
+	u16 abs_id;                 /* absolute SGE id for the response q */
+	__be64 *desc;               /* address of HW response ring */
+	dma_addr_t phys_addr;       /* physical address of the ring */
+	unsigned int iqe_len;       /* entry size */
+	unsigned int size;          /* capacity of response queue */
+	struct adapter *adap;
+	struct net_device *netdev;  /* associated net device */
+	rspq_handler_t handler;
+};
+
+struct sge_eth_stats {              /* Ethernet queue statistics */
+	unsigned long pkts;         /* # of ethernet packets */
+	unsigned long lro_pkts;     /* # of LRO super packets */
+	unsigned long lro_merged;   /* # of wire packets merged by LRO */
+	unsigned long rx_cso;       /* # of Rx checksum offloads */
+	unsigned long vlan_ex;      /* # of Rx VLAN extractions */
+	unsigned long rx_drops;     /* # of packets dropped due to no mem */
+};
+
+struct sge_eth_rxq {                /* SW Ethernet Rx queue */
+	struct sge_rspq rspq;
+	struct sge_fl fl;
+	struct sge_eth_stats stats;
+} ____cacheline_aligned_in_smp;
+
+struct sge_ofld_stats {             /* offload queue statistics */
+	unsigned long pkts;         /* # of packets */
+	unsigned long imm;          /* # of immediate-data packets */
+	unsigned long an;           /* # of asynchronous notifications */
+	unsigned long nomem;        /* # of responses deferred due to no mem */
+};
+
+struct sge_ofld_rxq {               /* SW offload Rx queue */
+	struct sge_rspq rspq;
+	struct sge_fl fl;
+	struct sge_ofld_stats stats;
+} ____cacheline_aligned_in_smp;
+
+struct tx_desc {
+	__be64 flit[8];
+};
+
+struct tx_sw_desc;
+
+struct sge_txq {
+	unsigned int  in_use;       /* # of in-use Tx descriptors */
+	unsigned int  size;         /* # of descriptors */
+	unsigned int  cidx;         /* SW consumer index */
+	unsigned int  pidx;         /* producer index */
+	unsigned long stops;        /* # of times q has been stopped */
+	unsigned long restarts;     /* # of queue restarts */
+	unsigned int  cntxt_id;     /* SGE context id for the Tx q */
+	struct tx_desc *desc;       /* address of HW Tx descriptor ring */
+	struct tx_sw_desc *sdesc;   /* address of SW Tx descriptor ring */
+	struct sge_qstat *stat;     /* queue status entry */
+	dma_addr_t    phys_addr;    /* physical address of the ring */
+};
+
+struct sge_eth_txq {                /* state for an SGE Ethernet Tx queue */
+	struct sge_txq q;
+	struct netdev_queue *txq;   /* associated netdev TX queue */
+	unsigned long tso;          /* # of TSO requests */
+	unsigned long tx_cso;       /* # of Tx checksum offloads */
+	unsigned long vlan_ins;     /* # of Tx VLAN insertions */
+	unsigned long mapping_err;  /* # of I/O MMU packet mapping errors */
+} ____cacheline_aligned_in_smp;
+
+struct sge_ofld_txq {               /* state for an SGE offload Tx queue */
+	struct sge_txq q;
+	struct adapter *adap;
+	struct sk_buff_head sendq;  /* list of backpressured packets */
+	struct tasklet_struct qresume_tsk; /* restarts the queue */
+	u8 full;                    /* the Tx ring is full */
+	unsigned long mapping_err;  /* # of I/O MMU packet mapping errors */
+} ____cacheline_aligned_in_smp;
+
+struct sge_ctrl_txq {               /* state for an SGE control Tx queue */
+	struct sge_txq q;
+	struct adapter *adap;
+	struct sk_buff_head sendq;  /* list of backpressured packets */
+	struct tasklet_struct qresume_tsk; /* restarts the queue */
+	u8 full;                    /* the Tx ring is full */
+} ____cacheline_aligned_in_smp;
+
+struct sge {
+	struct sge_eth_txq ethtxq[MAX_ETH_QSETS];
+	struct sge_ofld_txq ofldtxq[MAX_OFLD_QSETS];
+	struct sge_ctrl_txq ctrlq[MAX_CTRL_QUEUES];
+
+	struct sge_eth_rxq ethrxq[MAX_ETH_QSETS];
+	struct sge_ofld_rxq ofldrxq[MAX_OFLD_QSETS];
+	struct sge_ofld_rxq rdmarxq[MAX_RDMA_QUEUES];
+	struct sge_rspq fw_evtq ____cacheline_aligned_in_smp;
+
+	struct sge_rspq intrq ____cacheline_aligned_in_smp;
+	spinlock_t intrq_lock;
+
+	u16 max_ethqsets;           /* # of available Ethernet queue sets */
+	u16 ethqsets;               /* # of active Ethernet queue sets */
+	u16 ethtxq_rover;           /* Tx queue to clean up next */
+	u16 ofldqsets;              /* # of active offload queue sets */
+	u16 rdmaqs;                 /* # of available RDMA Rx queues */
+	u16 ofld_rxq[MAX_OFLD_QSETS];
+	u16 rdma_rxq[NCHAN];
+	u16 timer_val[SGE_NTIMERS];
+	u8 counter_val[SGE_NCOUNTERS];
+	unsigned int starve_thres;
+	u8 idma_state[2];
+	void *egr_map[MAX_EGRQ];    /* qid->queue egress queue map */
+	struct sge_rspq *ingr_map[MAX_INGQ]; /* qid->queue ingress queue map */
+	DECLARE_BITMAP(starving_fl, MAX_EGRQ);
+	DECLARE_BITMAP(txq_maperr, MAX_EGRQ);
+	struct timer_list rx_timer; /* refills starving FLs */
+	struct timer_list tx_timer; /* checks Tx queues */
+};
+
+#define for_each_ethrxq(sge, i) for (i = 0; i < (sge)->ethqsets; i++)
+#define for_each_ofldrxq(sge, i) for (i = 0; i < (sge)->ofldqsets; i++)
+#define for_each_rdmarxq(sge, i) for (i = 0; i < (sge)->rdmaqs; i++)
+
+struct l2t_data;
+
+struct adapter {
+	void __iomem *regs;
+	struct pci_dev *pdev;
+	struct device *pdev_dev;
+	unsigned long registered_device_map;
+	unsigned long open_device_map;
+	unsigned long flags;
+
+	const char *name;
+	int msg_enable;
+
+	struct adapter_params params;
+	struct cxgb4_virt_res vres;
+	unsigned int swintr;
+
+	unsigned int wol;
+
+	struct {
+		unsigned short vec;
+		char desc[14];
+	} msix_info[MAX_INGQ + 1];
+
+	struct sge sge;
+
+	struct net_device *port[MAX_NPORTS];
+	u8 chan_map[NCHAN];                   /* channel -> port map */
+
+	struct l2t_data *l2t;
+	void *uld_handle[CXGB4_ULD_MAX];
+	struct list_head list_node;
+
+	struct tid_info tids;
+	void **tid_release_head;
+	spinlock_t tid_release_lock;
+	struct work_struct tid_release_task;
+	bool tid_release_task_busy;
+
+	struct dentry *debugfs_root;
+	struct proc_dir_entry *proc_root;
+
+	spinlock_t stats_lock;
+};
+
+static inline u32 t4_read_reg(struct adapter *adap, u32 reg_addr)
+{
+	return readl(adap->regs + reg_addr);
+}
+
+static inline void t4_write_reg(struct adapter *adap, u32 reg_addr, u32 val)
+{
+	writel(val, adap->regs + reg_addr);
+}
+
+#ifndef readq
+static inline u64 readq(const volatile void __iomem *addr)
+{
+	return readl(addr) + ((u64)readl(addr + 4) << 32);
+}
+
+static inline void writeq(u64 val, volatile void __iomem *addr)
+{
+	writel(val, addr);
+	writel(val >> 32, addr + 4);
+}
+#endif
+
+static inline u64 t4_read_reg64(struct adapter *adap, u32 reg_addr)
+{
+	return readq(adap->regs + reg_addr);
+}
+
+static inline void t4_write_reg64(struct adapter *adap, u32 reg_addr, u64 val)
+{
+	writeq(val, adap->regs + reg_addr);
+}
+
+/**
+ * netdev2pinfo - return the port_info structure associated with a net_device
+ * @dev: the netdev
+ *
+ * Return the struct port_info associated with a net_device
+ */
+static inline struct port_info *netdev2pinfo(const struct net_device *dev)
+{
+	return netdev_priv(dev);
+}
+
+/**
+ * adap2pinfo - return the port_info of a port
+ * @adap: the adapter
+ * @idx: the port index
+ *
+ * Return the port_info structure for the port of the given index.
+ */
+static inline struct port_info *adap2pinfo(struct adapter *adap, int idx)
+{
+	return netdev_priv(adap->port[idx]);
+}
+
+/**
+ * netdev2adap - return the adapter structure associated with a net_device
+ * @dev: the netdev
+ *
+ * Return the struct adapter associated with a net_device
+ */
+static inline struct adapter *netdev2adap(const struct net_device *dev)
+{
+	return netdev2pinfo(dev)->adapter;
+}
+
+void t4_os_portmod_changed(const struct adapter *adap, int port_id);
+void t4_os_link_changed(struct adapter *adap, int port_id, int link_stat);
+
+void *t4_alloc_mem(size_t size);
+void t4_free_mem(void *addr);
+
+void t4_free_sge_resources(struct adapter *adap);
+irq_handler_t t4_intr_handler(struct adapter *adap);
+netdev_tx_t t4_eth_xmit(struct sk_buff *skb, struct net_device *dev);
+int t4_ethrx_handler(struct sge_rspq *q, const __be64 *rsp,
+		     const struct pkt_gl *gl);
+int t4_mgmt_tx(struct adapter *adap, struct sk_buff *skb);
+int t4_ofld_send(struct adapter *adap, struct sk_buff *skb);
+int t4_sge_alloc_rxq(struct adapter *adap, struct sge_rspq *iq, bool fwevtq,
+		     struct net_device *dev, int intr_idx,
+		     struct sge_fl *fl, rspq_handler_t hnd);
+int t4_sge_alloc_eth_txq(struct adapter *adap, struct sge_eth_txq *txq,
+			 struct net_device *dev, struct netdev_queue *netdevq,
+			 unsigned int iqid);
+int t4_sge_alloc_ctrl_txq(struct adapter *adap, struct sge_ctrl_txq *txq,
+			  struct net_device *dev, unsigned int iqid,
+			  unsigned int cmplqid);
+int t4_sge_alloc_ofld_txq(struct adapter *adap, struct sge_ofld_txq *txq,
+			  struct net_device *dev, unsigned int iqid);
+irqreturn_t t4_sge_intr_msix(int irq, void *cookie);
+void t4_sge_init(struct adapter *adap);
+void t4_sge_start(struct adapter *adap);
+void t4_sge_stop(struct adapter *adap);
+
+#define for_each_port(adapter, iter) \
+	for (iter = 0; iter < (adapter)->params.nports; ++iter)
+
+static inline unsigned int core_ticks_per_usec(const struct adapter *adap)
+{
+	return adap->params.vpd.cclk / 1000;
+}
+
+static inline unsigned int us_to_core_ticks(const struct adapter *adap,
+					    unsigned int us)
+{
+	return (us * adap->params.vpd.cclk) / 1000;
+}
+
+void t4_set_reg_field(struct adapter *adap, unsigned int addr, u32 mask,
+		      u32 val);
+
+int t4_wr_mbox_meat(struct adapter *adap, int mbox, const void *cmd, int size,
+		    void *rpl, bool sleep_ok);
+
+static inline int t4_wr_mbox(struct adapter *adap, int mbox, const void *cmd,
+			     int size, void *rpl)
+{
+	return t4_wr_mbox_meat(adap, mbox, cmd, size, rpl, true);
+}
+
+static inline int t4_wr_mbox_ns(struct adapter *adap, int mbox, const void *cmd,
+				int size, void *rpl)
+{
+	return t4_wr_mbox_meat(adap, mbox, cmd, size, rpl, false);
+}
+
+void t4_intr_enable(struct adapter *adapter);
+void t4_intr_disable(struct adapter *adapter);
+void t4_intr_clear(struct adapter *adapter);
+int t4_slow_intr_handler(struct adapter *adapter);
+
+int t4_link_start(struct adapter *adap, unsigned int mbox, unsigned int port,
+		  struct link_config *lc);
+int t4_restart_aneg(struct adapter *adap, unsigned int mbox, unsigned int port);
+int t4_seeprom_wp(struct adapter *adapter, bool enable);
+int t4_read_flash(struct adapter *adapter, unsigned int addr,
+		  unsigned int nwords, u32 *data, int byte_oriented);
+int t4_load_fw(struct adapter *adapter, const u8 *fw_data, unsigned int size);
+int t4_check_fw_version(struct adapter *adapter);
+int t4_prep_adapter(struct adapter *adapter);
+int t4_port_init(struct adapter *adap, int mbox, int pf, int vf);
+void t4_fatal_err(struct adapter *adapter);
+void t4_set_vlan_accel(struct adapter *adapter, unsigned int ports, int on);
+int t4_set_trace_filter(struct adapter *adapter, const struct trace_params *tp,
+			int filter_index, int enable);
+void t4_get_trace_filter(struct adapter *adapter, struct trace_params *tp,
+			 int filter_index, int *enabled);
+int t4_config_rss_range(struct adapter *adapter, int mbox, unsigned int viid,
+			int start, int n, const u16 *rspq, unsigned int nrspq);
+int t4_config_glbl_rss(struct adapter *adapter, int mbox, unsigned int mode,
+		       unsigned int flags);
+int t4_read_rss(struct adapter *adapter, u16 *entries);
+int t4_mc_read(struct adapter *adap, u32 addr, __be32 *data, u64 *parity);
+int t4_edc_read(struct adapter *adap, int idx, u32 addr, __be32 *data,
+		u64 *parity);
+
+void t4_get_port_stats(struct adapter *adap, int idx, struct port_stats *p);
+void t4_get_lb_stats(struct adapter *adap, int idx, struct lb_port_stats *p);
+
+void t4_read_mtu_tbl(struct adapter *adap, u16 *mtus, u8 *mtu_log);
+void t4_tp_get_err_stats(struct adapter *adap, struct tp_err_stats *st);
+void t4_tp_get_tcp_stats(struct adapter *adap, struct tp_tcp_stats *v4,
+			 struct tp_tcp_stats *v6);
+void t4_load_mtus(struct adapter *adap, const unsigned short *mtus,
+		  const unsigned short *alpha, const unsigned short *beta);
+
+void t4_wol_magic_enable(struct adapter *adap, unsigned int port,
+			 const u8 *addr);
+int t4_wol_pat_enable(struct adapter *adap, unsigned int port, unsigned int map,
+		      u64 mask0, u64 mask1, unsigned int crc, bool enable);
+
+int t4_fw_hello(struct adapter *adap, unsigned int mbox, unsigned int evt_mbox,
+		enum dev_master master, enum dev_state *state);
+int t4_fw_bye(struct adapter *adap, unsigned int mbox);
+int t4_early_init(struct adapter *adap, unsigned int mbox);
+int t4_fw_reset(struct adapter *adap, unsigned int mbox, int reset);
+int t4_query_params(struct adapter *adap, unsigned int mbox, unsigned int pf,
+		    unsigned int vf, unsigned int nparams, const u32 *params,
+		    u32 *val);
+int t4_set_params(struct adapter *adap, unsigned int mbox, unsigned int pf,
+		  unsigned int vf, unsigned int nparams, const u32 *params,
+		  const u32 *val);
+int t4_cfg_pfvf(struct adapter *adap, unsigned int mbox, unsigned int pf,
+		unsigned int vf, unsigned int txq, unsigned int txq_eth_ctrl,
+		unsigned int rxqi, unsigned int rxq, unsigned int tc,
+		unsigned int vi, unsigned int cmask, unsigned int pmask,
+		unsigned int nexact, unsigned int rcaps, unsigned int wxcaps);
+int t4_alloc_vi(struct adapter *adap, unsigned int mbox, unsigned int port,
+		unsigned int pf, unsigned int vf, unsigned int nmac, u8 *mac,
+		unsigned int *rss_size);
+int t4_free_vi(struct adapter *adap, unsigned int mbox, unsigned int pf,
+	       unsigned int vf, unsigned int viid);
+int t4_set_rxmode(struct adapter *adap, unsigned int mbox, unsigned int viid,
+		int mtu, int promisc, int all_multi, int bcast, bool sleep_ok);
+int t4_alloc_mac_filt(struct adapter *adap, unsigned int mbox,
+		      unsigned int viid, bool free, unsigned int naddr,
+		      const u8 **addr, u16 *idx, u64 *hash, bool sleep_ok);
+int t4_change_mac(struct adapter *adap, unsigned int mbox, unsigned int viid,
+		  int idx, const u8 *addr, bool persist, bool add_smt);
+int t4_set_addr_hash(struct adapter *adap, unsigned int mbox, unsigned int viid,
+		     bool ucast, u64 vec, bool sleep_ok);
+int t4_enable_vi(struct adapter *adap, unsigned int mbox, unsigned int viid,
+		 bool rx_en, bool tx_en);
+int t4_identify_port(struct adapter *adap, unsigned int mbox, unsigned int viid,
+		     unsigned int nblinks);
+int t4_mdio_rd(struct adapter *adap, unsigned int mbox, unsigned int phy_addr,
+	       unsigned int mmd, unsigned int reg, u16 *valp);
+int t4_mdio_wr(struct adapter *adap, unsigned int mbox, unsigned int phy_addr,
+	       unsigned int mmd, unsigned int reg, u16 val);
+int t4_iq_start_stop(struct adapter *adap, unsigned int mbox, bool start,
+		     unsigned int pf, unsigned int vf, unsigned int iqid,
+		     unsigned int fl0id, unsigned int fl1id);
+int t4_iq_free(struct adapter *adap, unsigned int mbox, unsigned int pf,
+	       unsigned int vf, unsigned int iqtype, unsigned int iqid,
+	       unsigned int fl0id, unsigned int fl1id);
+int t4_eth_eq_free(struct adapter *adap, unsigned int mbox, unsigned int pf,
+		   unsigned int vf, unsigned int eqid);
+int t4_ctrl_eq_free(struct adapter *adap, unsigned int mbox, unsigned int pf,
+		    unsigned int vf, unsigned int eqid);
+int t4_ofld_eq_free(struct adapter *adap, unsigned int mbox, unsigned int pf,
+		    unsigned int vf, unsigned int eqid);
+int t4_handle_fw_rpl(struct adapter *adap, const __be64 *rpl);
+#endif /* __CXGB4_H__ */
diff --git a/drivers/net/cxgb4/cxgb4_uld.h b/drivers/net/cxgb4/cxgb4_uld.h
new file mode 100644
index 0000000..83e81d5
--- /dev/null
+++ b/drivers/net/cxgb4/cxgb4_uld.h
@@ -0,0 +1,235 @@
+/*
+ * This file is part of the Chelsio T4 Ethernet driver for Linux.
+ *
+ * Copyright (c) 2003-2010 Chelsio Communications, Inc. All rights reserved.
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
+ */
+
+#ifndef __CXGB4_OFLD_H
+#define __CXGB4_OFLD_H
+
+#include <linux/cache.h>
+#include <linux/spinlock.h>
+#include <linux/skbuff.h>
+#include <asm/atomic.h>
+
+/* CPL message priority levels */
+enum {
+	CPL_PRIORITY_DATA     = 0,  /* data messages */
+	CPL_PRIORITY_SETUP    = 1,  /* connection setup messages */
+	CPL_PRIORITY_TEARDOWN = 0,  /* connection teardown messages */
+	CPL_PRIORITY_LISTEN   = 1,  /* listen start/stop messages */
+	CPL_PRIORITY_ACK      = 1,  /* RX ACK messages */
+	CPL_PRIORITY_CONTROL  = 1   /* control messages */
+};
+
+#define INIT_TP_WR(w, tid) do { \
+	(w)->wr.wr_hi = htonl(FW_WR_OP(FW_TP_WR) | \
+			      FW_WR_IMMDLEN(sizeof(*w) - sizeof(w->wr))); \
+	(w)->wr.wr_mid = htonl(FW_WR_LEN16(DIV_ROUND_UP(sizeof(*w), 16)) | \
+			       FW_WR_FLOWID(tid)); \
+	(w)->wr.wr_lo = cpu_to_be64(0); \
+} while (0)
+
+#define INIT_TP_WR_CPL(w, cpl, tid) do { \
+	INIT_TP_WR(w, tid); \
+	OPCODE_TID(w) = htonl(MK_OPCODE_TID(cpl, tid)); \
+} while (0)
+
+#define INIT_ULPTX_WR(w, wrlen, atomic, tid) do { \
+	(w)->wr.wr_hi = htonl(FW_WR_OP(FW_ULPTX_WR) | FW_WR_ATOMIC(atomic)); \
+	(w)->wr.wr_mid = htonl(FW_WR_LEN16(DIV_ROUND_UP(wrlen, 16)) | \
+			       FW_WR_FLOWID(tid)); \
+	(w)->wr.wr_lo = cpu_to_be64(0); \
+} while (0)
+
+/* Special asynchronous notification message */
+#define CXGB4_MSG_AN ((void *)1)
+
+struct serv_entry {
+	void *data;
+};
+
+union aopen_entry {
+	void *data;
+	union aopen_entry *next;
+};
+
+/*
+ * Holds the size, base address, free list start, etc of the TID, server TID,
+ * and active-open TID tables.  The tables themselves are allocated dynamically.
+ */
+struct tid_info {
+	void **tid_tab;
+	unsigned int ntids;
+
+	struct serv_entry *stid_tab;
+	unsigned long *stid_bmap;
+	unsigned int nstids;
+	unsigned int stid_base;
+
+	union aopen_entry *atid_tab;
+	unsigned int natids;
+
+	unsigned int nftids;
+	unsigned int ftid_base;
+
+	spinlock_t atid_lock ____cacheline_aligned_in_smp;
+	union aopen_entry *afree;
+	unsigned int atids_in_use;
+
+	spinlock_t stid_lock;
+	unsigned int stids_in_use;
+
+	atomic_t tids_in_use;
+};
+
+static inline void *lookup_tid(const struct tid_info *t, unsigned int tid)
+{
+	return tid < t->ntids ? t->tid_tab[tid] : NULL;
+}
+
+static inline void *lookup_atid(const struct tid_info *t, unsigned int atid)
+{
+	return atid < t->natids ? t->atid_tab[atid].data : NULL;
+}
+
+static inline void *lookup_stid(const struct tid_info *t, unsigned int stid)
+{
+	stid -= t->stid_base;
+	return stid < t->nstids ? t->stid_tab[stid].data : NULL;
+}
+
+static inline void cxgb4_insert_tid(struct tid_info *t, void *data,
+				    unsigned int tid)
+{
+	t->tid_tab[tid] = data;
+	atomic_inc(&t->tids_in_use);
+}
+
+int cxgb4_alloc_atid(struct tid_info *t, void *data);
+int cxgb4_alloc_stid(struct tid_info *t, int family, void *data);
+void cxgb4_free_atid(struct tid_info *t, unsigned int atid);
+void cxgb4_free_stid(struct tid_info *t, unsigned int stid, int family);
+void cxgb4_remove_tid(struct tid_info *t, unsigned int qid, unsigned int tid);
+void cxgb4_queue_tid_release(struct tid_info *t, unsigned int chan,
+			     unsigned int tid);
+
+struct in6_addr;
+
+int cxgb4_create_server(const struct net_device *dev, unsigned int stid,
+			__be32 sip, __be16 sport, unsigned int queue);
+int cxgb4_create_server6(const struct net_device *dev, unsigned int stid,
+			 const struct in6_addr *sip, __be16 sport,
+			 unsigned int queue);
+
+static inline void set_wr_txq(struct sk_buff *skb, int prio, int queue)
+{
+	skb_set_queue_mapping(skb, (queue << 1) | prio);
+}
+
+enum cxgb4_uld {
+	CXGB4_ULD_RDMA,
+	CXGB4_ULD_ISCSI,
+	CXGB4_ULD_MAX
+};
+
+enum cxgb4_state {
+	CXGB4_STATE_UP,
+	CXGB4_STATE_START_RECOVERY,
+	CXGB4_STATE_DOWN,
+	CXGB4_STATE_DETACH
+};
+
+struct pci_dev;
+struct l2t_data;
+struct net_device;
+struct pkt_gl;
+
+struct cxgb4_range {
+	unsigned int start;
+	unsigned int size;
+};
+
+struct cxgb4_virt_res {                      /* virtualized HW resources */
+	struct cxgb4_range ddp;
+	struct cxgb4_range iscsi;
+	struct cxgb4_range stag;
+	struct cxgb4_range rq;
+	struct cxgb4_range pbl;
+};
+
+/*
+ * Block of information the LLD provides to ULDs attaching to a device.
+ */
+struct cxgb4_lld_info {
+	struct pci_dev *pdev;                /* associated PCI device */
+	struct l2t_data *l2t;                /* L2 table */
+	struct tid_info *tids;               /* TID table */
+	struct net_device **ports;           /* device ports */
+	const struct cxgb4_virt_res *vr;     /* assorted HW resources */
+	const unsigned short *mtus;          /* MTU table */
+	const unsigned short *rxq_ids;       /* the ULD's Rx queue ids */
+	unsigned short nrxq;                 /* # of Rx queues */
+	unsigned short ntxq;                 /* # of Tx queues */
+	unsigned char nchan:4;               /* # of channels */
+	unsigned char nports:4;              /* # of ports */
+	unsigned char wr_cred;               /* WR 16-byte credits */
+	unsigned char adapter_type;          /* type of adapter */
+	unsigned char fw_api_ver;            /* FW API version */
+	unsigned int fw_vers;                /* FW version */
+	unsigned int iscsi_iolen;            /* iSCSI max I/O length */
+	unsigned short udb_density;          /* # of user DB/page */
+	unsigned short ucq_density;          /* # of user CQs/page */
+	void __iomem *gts_reg;               /* address of GTS register */
+	void __iomem *db_reg;                /* address of kernel doorbell */
+};
+
+struct cxgb4_uld_info {
+	const char *name;
+	void *(*add)(const struct cxgb4_lld_info *p);
+	int (*rx_handler)(void *handle, const __be64 *rsp,
+			  const struct pkt_gl *gl);
+	int (*state_change)(void *handle, enum cxgb4_state new_state);
+};
+
+int cxgb4_register_uld(enum cxgb4_uld type, const struct cxgb4_uld_info *p);
+int cxgb4_unregister_uld(enum cxgb4_uld type);
+int cxgb4_ofld_send(struct net_device *dev, struct sk_buff *skb);
+unsigned int cxgb4_port_chan(const struct net_device *dev);
+unsigned int cxgb4_port_viid(const struct net_device *dev);
+struct net_device *cxgb4_netdev_by_hwid(struct pci_dev *pdev, unsigned int id);
+unsigned int cxgb4_best_mtu(const unsigned short *mtus, unsigned short mtu,
+			    unsigned int *idx);
+void cxgb4_iscsi_init(struct net_device *dev, unsigned int tag_mask,
+		      const unsigned int *pgsz_order);
+struct sk_buff *cxgb4_pktgl_to_skb(const struct pkt_gl *gl,
+				   unsigned int skb_len, unsigned int pull_len);
+#endif  /* !__CXGB4_OFLD_H */
diff --git a/drivers/net/cxgb4/l2t.c b/drivers/net/cxgb4/l2t.c
new file mode 100644
index 0000000..cd1d7bd
--- /dev/null
+++ b/drivers/net/cxgb4/l2t.c
@@ -0,0 +1,626 @@
+/*
+ * This file is part of the Chelsio T4 Ethernet driver for Linux.
+ *
+ * Copyright (c) 2003-2010 Chelsio Communications, Inc. All rights reserved.
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
+ */
+
+#include <linux/skbuff.h>
+#include <linux/netdevice.h>
+#include <linux/if.h>
+#include <linux/if_vlan.h>
+#include <linux/jhash.h>
+#include <net/neighbour.h>
+#include "cxgb4.h"
+#include "l2t.h"
+#include "t4_msg.h"
+#include "t4fw_api.h"
+
+#define VLAN_NONE 0xfff
+
+/* identifies sync vs async L2T_WRITE_REQs */
+#define F_SYNC_WR    (1 << 12)
+
+enum {
+	L2T_STATE_VALID,      /* entry is up to date */
+	L2T_STATE_STALE,      /* entry may be used but needs revalidation */
+	L2T_STATE_RESOLVING,  /* entry needs address resolution */
+	L2T_STATE_SYNC_WRITE, /* synchronous write of entry underway */
+
+	/* when state is one of the below the entry is not hashed */
+	L2T_STATE_SWITCHING,  /* entry is being used by a switching filter */
+	L2T_STATE_UNUSED      /* entry not in use */
+};
+
+struct l2t_data {
+	rwlock_t lock;
+	atomic_t nfree;             /* number of free entries */
+	struct l2t_entry *rover;    /* starting point for next allocation */
+	struct l2t_entry l2tab[L2T_SIZE];
+};
+
+static inline unsigned int vlan_prio(const struct l2t_entry *e)
+{
+	return e->vlan >> 13;
+}
+
+static inline void l2t_hold(struct l2t_data *d, struct l2t_entry *e)
+{
+	if (atomic_add_return(1, &e->refcnt) == 1)  /* 0 -> 1 transition */
+		atomic_dec(&d->nfree);
+}
+
+/*
+ * To avoid having to check address families we do not allow v4 and v6
+ * neighbors to be on the same hash chain.  We keep v4 entries in the first
+ * half of available hash buckets and v6 in the second.
+ */
+enum {
+	L2T_SZ_HALF = L2T_SIZE / 2,
+	L2T_HASH_MASK = L2T_SZ_HALF - 1
+};
+
+static inline unsigned int arp_hash(const u32 *key, int ifindex)
+{
+	return jhash_2words(*key, ifindex, 0) & L2T_HASH_MASK;
+}
+
+static inline unsigned int ipv6_hash(const u32 *key, int ifindex)
+{
+	u32 xor = key[0] ^ key[1] ^ key[2] ^ key[3];
+
+	return L2T_SZ_HALF + (jhash_2words(xor, ifindex, 0) & L2T_HASH_MASK);
+}
+
+static unsigned int addr_hash(const u32 *addr, int addr_len, int ifindex)
+{
+	return addr_len == 4 ? arp_hash(addr, ifindex) :
+			       ipv6_hash(addr, ifindex);
+}
+
+/*
+ * Checks if an L2T entry is for the given IP/IPv6 address.  It does not check
+ * whether the L2T entry and the address are of the same address family.
+ * Callers ensure an address is only checked against L2T entries of the same
+ * family, something made trivial by the separation of IP and IPv6 hash chains
+ * mentioned above.  Returns 0 if there's a match,
+ */
+static int addreq(const struct l2t_entry *e, const u32 *addr)
+{
+	if (e->v6)
+		return (e->addr[0] ^ addr[0]) | (e->addr[1] ^ addr[1]) |
+		       (e->addr[2] ^ addr[2]) | (e->addr[3] ^ addr[3]);
+	return e->addr[0] ^ addr[0];
+}
+
+static void neigh_replace(struct l2t_entry *e, struct neighbour *n)
+{
+	neigh_hold(n);
+	if (e->neigh)
+		neigh_release(e->neigh);
+	e->neigh = n;
+}
+
+/*
+ * Write an L2T entry.  Must be called with the entry locked.
+ * The write may be synchronous or asynchronous.
+ */
+static int write_l2e(struct adapter *adap, struct l2t_entry *e, int sync)
+{
+	struct sk_buff *skb;
+	struct cpl_l2t_write_req *req;
+
+	skb = alloc_skb(sizeof(*req), GFP_ATOMIC);
+	if (!skb)
+		return -ENOMEM;
+
+	req = (struct cpl_l2t_write_req *)__skb_put(skb, sizeof(*req));
+	INIT_TP_WR(req, 0);
+
+	OPCODE_TID(req) = htonl(MK_OPCODE_TID(CPL_L2T_WRITE_REQ,
+					e->idx | (sync ? F_SYNC_WR : 0) |
+					TID_QID(adap->sge.fw_evtq.abs_id)));
+	req->params = htons(L2T_W_PORT(e->lport) | L2T_W_NOREPLY(!sync));
+	req->l2t_idx = htons(e->idx);
+	req->vlan = htons(e->vlan);
+	if (e->neigh)
+		memcpy(e->dmac, e->neigh->ha, sizeof(e->dmac));
+	memcpy(req->dst_mac, e->dmac, sizeof(req->dst_mac));
+
+	set_wr_txq(skb, CPL_PRIORITY_CONTROL, 0);
+	t4_ofld_send(adap, skb);
+
+	if (sync && e->state != L2T_STATE_SWITCHING)
+		e->state = L2T_STATE_SYNC_WRITE;
+	return 0;
+}
+
+/*
+ * Send packets waiting in an L2T entry's ARP queue.  Must be called with the
+ * entry locked.
+ */
+static void send_pending(struct adapter *adap, struct l2t_entry *e)
+{
+	while (e->arpq_head) {
+		struct sk_buff *skb = e->arpq_head;
+
+		e->arpq_head = skb->next;
+		skb->next = NULL;
+		t4_ofld_send(adap, skb);
+	}
+	e->arpq_tail = NULL;
+}
+
+/*
+ * Process a CPL_L2T_WRITE_RPL.  Wake up the ARP queue if it completes a
+ * synchronous L2T_WRITE.  Note that the TID in the reply is really the L2T
+ * index it refers to.
+ */
+void do_l2t_write_rpl(struct adapter *adap, const struct cpl_l2t_write_rpl *rpl)
+{
+	unsigned int tid = GET_TID(rpl);
+	unsigned int idx = tid & (L2T_SIZE - 1);
+
+	if (unlikely(rpl->status != CPL_ERR_NONE)) {
+		dev_err(adap->pdev_dev,
+			"Unexpected L2T_WRITE_RPL status %u for entry %u\n",
+			rpl->status, idx);
+		return;
+	}
+
+	if (tid & F_SYNC_WR) {
+		struct l2t_entry *e = &adap->l2t->l2tab[idx];
+
+		spin_lock(&e->lock);
+		if (e->state != L2T_STATE_SWITCHING) {
+			send_pending(adap, e);
+			e->state = (e->neigh->nud_state & NUD_STALE) ?
+					L2T_STATE_STALE : L2T_STATE_VALID;
+		}
+		spin_unlock(&e->lock);
+	}
+}
+
+/*
+ * Add a packet to an L2T entry's queue of packets awaiting resolution.
+ * Must be called with the entry's lock held.
+ */
+static inline void arpq_enqueue(struct l2t_entry *e, struct sk_buff *skb)
+{
+	skb->next = NULL;
+	if (e->arpq_head)
+		e->arpq_tail->next = skb;
+	else
+		e->arpq_head = skb;
+	e->arpq_tail = skb;
+}
+
+int cxgb4_l2t_send(struct net_device *dev, struct sk_buff *skb,
+		   struct l2t_entry *e)
+{
+	struct adapter *adap = netdev2adap(dev);
+
+again:
+	switch (e->state) {
+	case L2T_STATE_STALE:     /* entry is stale, kick off revalidation */
+		neigh_event_send(e->neigh, NULL);
+		spin_lock_bh(&e->lock);
+		if (e->state == L2T_STATE_STALE)
+			e->state = L2T_STATE_VALID;
+		spin_unlock_bh(&e->lock);
+	case L2T_STATE_VALID:     /* fast-path, send the packet on */
+		return t4_ofld_send(adap, skb);
+	case L2T_STATE_RESOLVING:
+	case L2T_STATE_SYNC_WRITE:
+		spin_lock_bh(&e->lock);
+		if (e->state != L2T_STATE_SYNC_WRITE &&
+		    e->state != L2T_STATE_RESOLVING) {
+			spin_unlock_bh(&e->lock);
+			goto again;
+		}
+		arpq_enqueue(e, skb);
+		spin_unlock_bh(&e->lock);
+
+		if (e->state == L2T_STATE_RESOLVING &&
+		    !neigh_event_send(e->neigh, NULL)) {
+			spin_lock_bh(&e->lock);
+			if (e->state == L2T_STATE_RESOLVING && e->arpq_head)
+				write_l2e(adap, e, 1);
+			spin_unlock_bh(&e->lock);
+		}
+	}
+	return 0;
+}
+EXPORT_SYMBOL(cxgb4_l2t_send);
+
+/*
+ * Allocate a free L2T entry.  Must be called with l2t_data.lock held.
+ */
+static struct l2t_entry *alloc_l2e(struct l2t_data *d)
+{
+	struct l2t_entry *end, *e, **p;
+
+	if (!atomic_read(&d->nfree))
+		return NULL;
+
+	/* there's definitely a free entry */
+	for (e = d->rover, end = &d->l2tab[L2T_SIZE]; e != end; ++e)
+		if (atomic_read(&e->refcnt) == 0)
+			goto found;
+
+	for (e = d->l2tab; atomic_read(&e->refcnt); ++e)
+		;
+found:
+	d->rover = e + 1;
+	atomic_dec(&d->nfree);
+
+	/*
+	 * The entry we found may be an inactive entry that is
+	 * presently in the hash table.  We need to remove it.
+	 */
+	if (e->state < L2T_STATE_SWITCHING)
+		for (p = &d->l2tab[e->hash].first; *p; p = &(*p)->next)
+			if (*p == e) {
+				*p = e->next;
+				e->next = NULL;
+				break;
+			}
+
+	e->state = L2T_STATE_UNUSED;
+	return e;
+}
+
+/*
+ * Called when an L2T entry has no more users.
+ */
+static void t4_l2e_free(struct l2t_entry *e)
+{
+	struct l2t_data *d;
+
+	spin_lock_bh(&e->lock);
+	if (atomic_read(&e->refcnt) == 0) {  /* hasn't been recycled */
+		if (e->neigh) {
+			neigh_release(e->neigh);
+			e->neigh = NULL;
+		}
+	}
+	spin_unlock_bh(&e->lock);
+
+	d = container_of(e, struct l2t_data, l2tab[e->idx]);
+	atomic_inc(&d->nfree);
+}
+
+void cxgb4_l2t_release(struct l2t_entry *e)
+{
+	if (atomic_dec_and_test(&e->refcnt))
+		t4_l2e_free(e);
+}
+EXPORT_SYMBOL(cxgb4_l2t_release);
+
+/*
+ * Update an L2T entry that was previously used for the same next hop as neigh.
+ * Must be called with softirqs disabled.
+ */
+static void reuse_entry(struct l2t_entry *e, struct neighbour *neigh)
+{
+	unsigned int nud_state;
+
+	spin_lock(&e->lock);                /* avoid race with t4_l2t_free */
+	if (neigh != e->neigh)
+		neigh_replace(e, neigh);
+	nud_state = neigh->nud_state;
+	if (memcmp(e->dmac, neigh->ha, sizeof(e->dmac)) ||
+	    !(nud_state & NUD_VALID))
+		e->state = L2T_STATE_RESOLVING;
+	else if (nud_state & NUD_CONNECTED)
+		e->state = L2T_STATE_VALID;
+	else
+		e->state = L2T_STATE_STALE;
+	spin_unlock(&e->lock);
+}
+
+struct l2t_entry *cxgb4_l2t_get(struct l2t_data *d, struct neighbour *neigh,
+				const struct net_device *physdev,
+				unsigned int priority)
+{
+	u8 lport;
+	u16 vlan;
+	struct l2t_entry *e;
+	int addr_len = neigh->tbl->key_len;
+	u32 *addr = (u32 *)neigh->primary_key;
+	int ifidx = neigh->dev->ifindex;
+	int hash = addr_hash(addr, addr_len, ifidx);
+
+	if (neigh->dev->flags & IFF_LOOPBACK)
+		lport = netdev2pinfo(physdev)->tx_chan + 4;
+	else
+		lport = netdev2pinfo(physdev)->lport;
+
+	if (neigh->dev->priv_flags & IFF_802_1Q_VLAN)
+		vlan = vlan_dev_vlan_id(neigh->dev);
+	else
+		vlan = VLAN_NONE;
+
+	write_lock_bh(&d->lock);
+	for (e = d->l2tab[hash].first; e; e = e->next)
+		if (!addreq(e, addr) && e->ifindex == ifidx &&
+		    e->vlan == vlan && e->lport == lport) {
+			l2t_hold(d, e);
+			if (atomic_read(&e->refcnt) == 1)
+				reuse_entry(e, neigh);
+			goto done;
+		}
+
+	/* Need to allocate a new entry */
+	e = alloc_l2e(d);
+	if (e) {
+		spin_lock(&e->lock);          /* avoid race with t4_l2t_free */
+		e->state = L2T_STATE_RESOLVING;
+		memcpy(e->addr, addr, addr_len);
+		e->ifindex = ifidx;
+		e->hash = hash;
+		e->lport = lport;
+		e->v6 = addr_len == 16;
+		atomic_set(&e->refcnt, 1);
+		neigh_replace(e, neigh);
+		e->vlan = vlan;
+		e->next = d->l2tab[hash].first;
+		d->l2tab[hash].first = e;
+		spin_unlock(&e->lock);
+	}
+done:
+	write_unlock_bh(&d->lock);
+	return e;
+}
+EXPORT_SYMBOL(cxgb4_l2t_get);
+
+/*
+ * Called when address resolution fails for an L2T entry to handle packets
+ * on the arpq head.  If a packet specifies a failure handler it is invoked,
+ * otherwise the packet is sent to the device.
+ */
+static void handle_failed_resolution(struct adapter *adap, struct sk_buff *arpq)
+{
+	while (arpq) {
+		struct sk_buff *skb = arpq;
+		const struct l2t_skb_cb *cb = L2T_SKB_CB(skb);
+
+		arpq = skb->next;
+		skb->next = NULL;
+		if (cb->arp_err_handler)
+			cb->arp_err_handler(cb->handle, skb);
+		else
+			t4_ofld_send(adap, skb);
+	}
+}
+
+/*
+ * Called when the host's neighbor layer makes a change to some entry that is
+ * loaded into the HW L2 table.
+ */
+void t4_l2t_update(struct adapter *adap, struct neighbour *neigh)
+{
+	struct l2t_entry *e;
+	struct sk_buff *arpq = NULL;
+	struct l2t_data *d = adap->l2t;
+	int addr_len = neigh->tbl->key_len;
+	u32 *addr = (u32 *) neigh->primary_key;
+	int ifidx = neigh->dev->ifindex;
+	int hash = addr_hash(addr, addr_len, ifidx);
+
+	read_lock_bh(&d->lock);
+	for (e = d->l2tab[hash].first; e; e = e->next)
+		if (!addreq(e, addr) && e->ifindex == ifidx) {
+			spin_lock(&e->lock);
+			if (atomic_read(&e->refcnt))
+				goto found;
+			spin_unlock(&e->lock);
+			break;
+		}
+	read_unlock_bh(&d->lock);
+	return;
+
+ found:
+	read_unlock(&d->lock);
+
+	if (neigh != e->neigh)
+		neigh_replace(e, neigh);
+
+	if (e->state == L2T_STATE_RESOLVING) {
+		if (neigh->nud_state & NUD_FAILED) {
+			arpq = e->arpq_head;
+			e->arpq_head = e->arpq_tail = NULL;
+		} else if ((neigh->nud_state & (NUD_CONNECTED | NUD_STALE)) &&
+			   e->arpq_head) {
+			write_l2e(adap, e, 1);
+		}
+	} else {
+		e->state = neigh->nud_state & NUD_CONNECTED ?
+			L2T_STATE_VALID : L2T_STATE_STALE;
+		if (memcmp(e->dmac, neigh->ha, sizeof(e->dmac)))
+			write_l2e(adap, e, 0);
+	}
+
+	spin_unlock_bh(&e->lock);
+
+	if (arpq)
+		handle_failed_resolution(adap, arpq);
+}
+
+/*
+ * Allocate an L2T entry for use by a switching rule.  Such entries need to be
+ * explicitly freed and while busy they are not on any hash chain, so normal
+ * address resolution updates do not see them.
+ */
+struct l2t_entry *t4_l2t_alloc_switching(struct l2t_data *d)
+{
+	struct l2t_entry *e;
+
+	write_lock_bh(&d->lock);
+	e = alloc_l2e(d);
+	if (e) {
+		spin_lock(&e->lock);          /* avoid race with t4_l2t_free */
+		e->state = L2T_STATE_SWITCHING;
+		atomic_set(&e->refcnt, 1);
+		spin_unlock(&e->lock);
+	}
+	write_unlock_bh(&d->lock);
+	return e;
+}
+
+/*
+ * Sets/updates the contents of a switching L2T entry that has been allocated
+ * with an earlier call to @t4_l2t_alloc_switching.
+ */
+int t4_l2t_set_switching(struct adapter *adap, struct l2t_entry *e, u16 vlan,
+			 u8 port, u8 *eth_addr)
+{
+	e->vlan = vlan;
+	e->lport = port;
+	memcpy(e->dmac, eth_addr, ETH_ALEN);
+	return write_l2e(adap, e, 0);
+}
+
+struct l2t_data *t4_init_l2t(void)
+{
+	int i;
+	struct l2t_data *d;
+
+	d = t4_alloc_mem(sizeof(*d));
+	if (!d)
+		return NULL;
+
+	d->rover = d->l2tab;
+	atomic_set(&d->nfree, L2T_SIZE);
+	rwlock_init(&d->lock);
+
+	for (i = 0; i < L2T_SIZE; ++i) {
+		d->l2tab[i].idx = i;
+		d->l2tab[i].state = L2T_STATE_UNUSED;
+		spin_lock_init(&d->l2tab[i].lock);
+		atomic_set(&d->l2tab[i].refcnt, 0);
+	}
+	return d;
+}
+
+#ifdef CONFIG_PROC_FS
+#include <linux/module.h>
+#include <linux/proc_fs.h>
+#include <linux/seq_file.h>
+
+static inline void *l2t_get_idx(struct seq_file *seq, loff_t pos)
+{
+	struct l2t_entry *l2tab = seq->private;
+
+	return pos >= L2T_SIZE ? NULL : &l2tab[pos];
+}
+
+static void *l2t_seq_start(struct seq_file *seq, loff_t *pos)
+{
+	return *pos ? l2t_get_idx(seq, *pos - 1) : SEQ_START_TOKEN;
+}
+
+static void *l2t_seq_next(struct seq_file *seq, void *v, loff_t *pos)
+{
+	v = l2t_get_idx(seq, *pos);
+	if (v)
+		++*pos;
+	return v;
+}
+
+static void l2t_seq_stop(struct seq_file *seq, void *v)
+{
+}
+
+static char l2e_state(const struct l2t_entry *e)
+{
+	switch (e->state) {
+	case L2T_STATE_VALID: return 'V';
+	case L2T_STATE_STALE: return 'S';
+	case L2T_STATE_SYNC_WRITE: return 'W';
+	case L2T_STATE_RESOLVING: return e->arpq_head ? 'A' : 'R';
+	case L2T_STATE_SWITCHING: return 'X';
+	default:
+		return 'U';
+	}
+}
+
+static int l2t_seq_show(struct seq_file *seq, void *v)
+{
+	if (v == SEQ_START_TOKEN)
+		seq_puts(seq, " Idx IP address      Ethernet address  VLAN/P "
+			 "LP State Users Port\n");
+	else {
+		char ip[60];
+		struct l2t_entry *e = v;
+
+		spin_lock_bh(&e->lock);
+		if (e->state == L2T_STATE_SWITCHING)
+			ip[0] = '\0';
+		else
+			sprintf(ip, e->v6 ? "%pI6c" : "%pI4", e->addr);
+		seq_printf(seq, "%4u %-15s %17pM %4d %u %2u   %c   %5u %s\n",
+			   e->idx, ip, e->dmac,
+			   e->vlan & VLAN_VID_MASK, vlan_prio(e), e->lport,
+			   l2e_state(e), atomic_read(&e->refcnt),
+			   e->neigh ? e->neigh->dev->name : "");
+		spin_unlock_bh(&e->lock);
+	}
+	return 0;
+}
+
+static const struct seq_operations l2t_seq_ops = {
+	.start = l2t_seq_start,
+	.next = l2t_seq_next,
+	.stop = l2t_seq_stop,
+	.show = l2t_seq_show
+};
+
+static int l2t_seq_open(struct inode *inode, struct file *file)
+{
+	int rc = seq_open(file, &l2t_seq_ops);
+
+	if (!rc) {
+		struct adapter *adap = PDE(inode)->data;
+		struct seq_file *seq = file->private_data;
+
+		seq->private = adap->l2t->l2tab;
+	}
+	return rc;
+}
+
+const struct file_operations t4_l2t_proc_fops = {
+	.owner = THIS_MODULE,
+	.open = l2t_seq_open,
+	.read = seq_read,
+	.llseek = seq_lseek,
+	.release = seq_release,
+};
+#endif
diff --git a/drivers/net/cxgb4/l2t.h b/drivers/net/cxgb4/l2t.h
new file mode 100644
index 0000000..013a2a5
--- /dev/null
+++ b/drivers/net/cxgb4/l2t.h
@@ -0,0 +1,110 @@
+/*
+ * This file is part of the Chelsio T4 Ethernet driver for Linux.
+ *
+ * Copyright (c) 2003-2010 Chelsio Communications, Inc. All rights reserved.
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
+ */
+
+#ifndef __CXGB4_L2T_H
+#define __CXGB4_L2T_H
+
+#include <linux/spinlock.h>
+#include <linux/if_ether.h>
+#include <asm/atomic.h>
+
+struct adapter;
+struct l2t_data;
+struct neighbour;
+struct net_device;
+struct file_operations;
+struct cpl_l2t_write_rpl;
+
+/*
+ * Each L2T entry plays multiple roles.  First of all, it keeps state for the
+ * corresponding entry of the HW L2 table and maintains a queue of offload
+ * packets awaiting address resolution.  Second, it is a node of a hash table
+ * chain, where the nodes of the chain are linked together through their next
+ * pointer.  Finally, each node is a bucket of a hash table, pointing to the
+ * first element in its chain through its first pointer.
+ */
+struct l2t_entry {
+	u16 state;                  /* entry state */
+	u16 idx;                    /* entry index */
+	u32 addr[4];                /* next hop IP or IPv6 address */
+	int ifindex;                /* neighbor's net_device's ifindex */
+	struct neighbour *neigh;    /* associated neighbour */
+	struct l2t_entry *first;    /* start of hash chain */
+	struct l2t_entry *next;     /* next l2t_entry on chain */
+	struct sk_buff *arpq_head;  /* queue of packets awaiting resolution */
+	struct sk_buff *arpq_tail;
+	spinlock_t lock;
+	atomic_t refcnt;            /* entry reference count */
+	u16 hash;                   /* hash bucket the entry is on */
+	u16 vlan;                   /* VLAN TCI (id: bits 0-11, prio: 13-15 */
+	u8 v6;                      /* whether entry is for IPv6 */
+	u8 lport;                   /* associated offload logical interface */
+	u8 dmac[ETH_ALEN];          /* neighbour's MAC address */
+};
+
+typedef void (*arp_err_handler_t)(void *handle, struct sk_buff *skb);
+
+/*
+ * Callback stored in an skb to handle address resolution failure.
+ */
+struct l2t_skb_cb {
+	void *handle;
+	arp_err_handler_t arp_err_handler;
+};
+
+#define L2T_SKB_CB(skb) ((struct l2t_skb_cb *)(skb)->cb)
+
+static inline void t4_set_arp_err_handler(struct sk_buff *skb, void *handle,
+					  arp_err_handler_t handler)
+{
+	L2T_SKB_CB(skb)->handle = handle;
+	L2T_SKB_CB(skb)->arp_err_handler = handler;
+}
+
+void cxgb4_l2t_release(struct l2t_entry *e);
+int cxgb4_l2t_send(struct net_device *dev, struct sk_buff *skb,
+		   struct l2t_entry *e);
+struct l2t_entry *cxgb4_l2t_get(struct l2t_data *d, struct neighbour *neigh,
+				const struct net_device *physdev,
+				unsigned int priority);
+
+void t4_l2t_update(struct adapter *adap, struct neighbour *neigh);
+struct l2t_entry *t4_l2t_alloc_switching(struct l2t_data *d);
+int t4_l2t_set_switching(struct adapter *adap, struct l2t_entry *e, u16 vlan,
+			 u8 port, u8 *eth_addr);
+struct l2t_data *t4_init_l2t(void);
+void do_l2t_write_rpl(struct adapter *p, const struct cpl_l2t_write_rpl *rpl);
+
+extern const struct file_operations t4_l2t_proc_fops;
+#endif  /* __CXGB4_L2T_H */
-- 
1.5.4

