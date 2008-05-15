From: "Subbu Seetharaman" <subbus@serverengines.com>
Subject: [PATCH 1/15] BE NIC driver - header and initialization functions
Date: Thu, 15 May 2008 02:02:40 -0700
Message-ID: <20080515090240.5ecbd2e3@mailhost.serverengines.com>
Mime-Version: 1.0
Content-Type: text/plain;
	charset="us-ascii"
Content-Transfer-Encoding: 8BIT
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail192.messagelabs.com ([216.82.245.99]:2353 "EHLO
	mail192.messagelabs.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1750970AbYEOI6C convert rfc822-to-8bit (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 15 May 2008 04:58:02 -0400
Received: from 124.30.166.146 ([124.30.166.146])
	by mailhost.serverengines.com
	for netdev@vger.kernel.org;
	Thu, 15 May 2008 02:02:41 -0700
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Hi,

Thanks to everyone who reviewed the first submission of the NIC driver
for BladeEngine (ServerEngines' 10Gb NIC) driver. I am submitting the driver
with all changes for another round of review.  Here is a summary
of the changes :

1.  All bit fields have been eliminated.
2.  All typedefs of structures have been eliminated.  There are still
    a few typedefs left.  These are needed to keep the h/w access library
    (beclib) OS neutral. We would like to keep them if possible.
3.  The LRO infrastructure in Linux is used instead of logic in the
    driver to coalesce small frames to larger frames.
4.  All other comments from first review  implemented.
5.  There are 6 errors from checkpatch.pl about macros that
    seem to be hard to eliminate.

BladeEngine is a dual function device with network and storage functions.
This patch includes the network driver and beclib - the OS neutral code that
implements the interactions between the host drivers and the adapter.

beclib is common to both storage and network drivers and
hence is organized under the directory drivers/message/beclib. The
storage driver is not part of this patch and will be submitted after
this review.

This patch is made against the current git tree.

Thank you.

Signed-off-by: Subbu Seetharaman <subbus@serverengines.com>
---
 drivers/net/benet/be.h      |  329 +++++++++++
 drivers/net/benet/be_init.c | 1356 +++++++++++++++++++++++++++++++++++++++++++
 drivers/net/benet/bni.h     |  335 +++++++++++
 3 files changed, 2020 insertions(+), 0 deletions(-)
 create mode 100644 drivers/net/benet/be.h
 create mode 100644 drivers/net/benet/be_init.c
 create mode 100644 drivers/net/benet/bni.h

diff --git a/drivers/net/benet/be.h b/drivers/net/benet/be.h
new file mode 100644
index 0000000..b19493b
--- /dev/null
+++ b/drivers/net/benet/be.h
@@ -0,0 +1,329 @@
+/*
+ * Copyright (C) 2005 - 2008 ServerEngines
+ * All rights reserved.
+ *
+ * This program is free software; you can redistribute it and/or
+ * modify it under the terms of the GNU General Public License
+ * as published by the Free Software Foundation; either version 2
+ * of the License, or at your option any later version.
+ *
+ * This program is distributed in the hope that it will be useful, but
+ * WITHOUT ANY WARRANTY; without even the implied warranty of
+ * MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.
+ * See the GNU General Public License for more details.
+ *
+ * You should have received a copy of the GNU General Public License
+ * along with this program; if not, write to the Free Software
+ * Foundation, Inc., 51 Franklin Street, 5th Floor
+ * Boston, MA 02110-1301 USA
+ *
+ *
+ * The full GNU General Public License is included in this distribution
+ * in the file called GPL.
+ *
+ * Contact Information:
+ * linux-drivers@serverengines.com
+ *
+ * ServerEngines
+ * 209 N. Fair Oaks Ave
+ * Sunnyvale, CA 94085
+ *
+ */
+#ifndef _BE_H
+#define _BE_H
+
+#include <linux/netdevice.h>
+#include <linux/inet_lro.h>
+#include "bni.h"
+
+#define BE_MAX_MTU	8974
+
+#define BE_MAX_LRO_DESCRIPTORS			8
+#define BE_LRO_MAX_PKTS				64
+#define BE_MAX_FRAGS_PER_FRAME			6
+
+extern unsigned int pm_resume;
+
+extern const char be_drvr_ver[];
+extern char be_fw_ver[];
+extern char be_driver_name[];
+
+extern struct ethtool_ops be_ethtool_ops;
+
+
+#define BE_DEV_STATE_NONE 0
+#define BE_DEV_STATE_INIT 1
+#define BE_DEV_STATE_OPEN 2
+
+/*
+ * BE driver statistics.
+ */
+struct be_drvr_stat {
+	u32 bes_tx_reqs;	/* number of TX requests initiated */
+	u32 bes_tx_fails;	/* number of TX requests that failed */
+	u32 bes_fwd_reqs;	/* number of send reqs through forwarding i/f */
+	u32 bes_tx_wrbs;	/* number of tx WRBs used */
+
+	u32 bes_ints;		/* number of interrupts */
+	u32 bes_polls;		/* number of times NAPI called poll function */
+	u32 bes_events;		/* total evet entries processed */
+	u32 bes_tx_events;	/* number of tx completion events  */
+	u32 bes_ucrx_events;	/* number of ucast rx completion events  */
+	u32 bes_bcrx_events;	/* number of bcast rx completion events  */
+	u32 bes_tx_compl;	/* number of tx completion entries processed */
+	u32 bes_ucrx_compl;	/* number of ucrx completion entries
+				   processed */
+	u32 bes_bcrx_compl;	/* number of bcrx completion entries
+				   processed */
+	u32 bes_ethrx_post_fail;	/* number of ethrx buffer alloc
+					   failures */
+	/*
+	 * number of non ether type II frames dropped where
+	 * frame len > length field of Mac Hdr
+	 */
+	u32 bes_802_3_dropped_frames;
+	/*
+	 * number of non ether type II frames malformed where
+	 * in frame len < length field of Mac Hdr
+	 */
+	u32 bes_802_3_malformed_frames;
+	u32 bes_ips;		/*  interrupts / sec */
+	u32 bes_prev_ints;	/* bes_ints at last IPS calculation  */
+	u16 bes_eth_tx_rate;	/*  ETH TX rate - Mb/sec */
+	u16 bes_eth_rx_rate;	/*  ETH RX rate - Mb/sec */
+	u32 bes_rx_coal;	/* Num pkts coalasced */
+	u32 bes_rx_flush;	/* Num times coalasced */
+	u32 bes_link_change_physical;	/*Num of times physical link changed */
+	u32 bes_link_change_virtual;	/*Num of times virtual link changed */
+	u32 bes_rx_misc_pkts;	/* Misc pkts received */
+};
+
+/* Maximum interrupt delay (in microseconds) allowed */
+#define MAX_EQD				120
+
+/*
+ * timer to prevent system shutdown hang for ever if h/w stops responding
+ */
+struct be_timer_ctxt {
+	atomic_t get_stat_flag;
+	struct timer_list get_stats_timer;
+	unsigned long get_stat_sem;	/* semaphore to wait  */
+} ;
+
+/* This structure is the main BladeEngine driver context.  */
+struct be_adapter {
+	struct net_device *netdevp;
+	struct be_drvr_stat be_stat;
+	struct net_device_stats benet_stats;
+	u32 num_bars;
+	struct SA_DEV_BAR_LOCATIONS pci_bars[3];	/* PCI BAR details */
+	struct SA_DEV sa_device;	/* device object owned by beclib */
+	struct BE_CHIP_OBJECT chip_object;	/* BEClib chip object  */
+
+	struct tasklet_struct sts_handler;
+	struct timer_list cq_timer;
+	spinlock_t int_lock;
+
+	struct IOCTL_ETH_GET_STATISTICS *eth_statsp;
+	/*
+	 * This will enable the use of ethtool to enable or disable
+	 * Checksum on Rx pkts to be obeyed or disobeyed.
+	 * If this is TRUE = 1, then whatever is the checksum on the
+	 * Received pkt as per BE, it will be given to the stack.
+	 * Else the stack will re calculate it.
+	 */
+	bool rx_csum;
+	/*
+	 * This will enable the use of ethtool to enable or disable
+	 * Coalese on Rx pkts to be obeyed or disobeyed.
+	 * If this is grater than 0 and less than 16 then coalascing
+	 * is enabled else it is disabled
+	 */
+	u32 max_rx_coal;
+	struct pci_dev *pdev;	/* Pointer to OS's PCI dvice */
+
+	spinlock_t txq_lock;
+
+	u32 isr;		/* copy of Intr status reg. */
+
+	u32 port0_link_sts;	/* Port 0 link status */
+	u32 port1_link_sts;	/* port 1 list status */
+	struct BE_LINK_STATUS *be_link_sts;
+
+	/* pointer to the first netobject of this adapter */
+	struct bni_net_object *net_obj;
+
+	/*  Flags to indicate what to clean up */
+	bool tasklet_started;
+	bool isr_registered;
+	/*
+	 * adaptive interrupt coalescing (AIC) related
+	 */
+	bool enable_aic;	/* 1 if AIC is enabled */
+	u16 min_eqd;		/* minimum EQ delay in usec */
+	u16 max_eqd;		/* minimum EQ delay in usec */
+	u16 cur_eqd;		/* current EQ delay in usec */
+	/*
+	 * book keeping for interrupt / sec and TX/RX rate calculation
+	 */
+	ulong ips_jiffies;	/* jiffies at last IPS calc */
+	u32 eth_tx_bytes;
+	ulong eth_tx_jiffies;
+	u32 eth_rx_bytes;
+	ulong eth_rx_jiffies;
+
+	struct semaphore get_eth_stat_sem;
+
+	/* timer ctxt to prevent shutdown hanging due to un-responsive BE */
+	struct be_timer_ctxt timer_ctxt;
+
+#define BE_MAX_MSIX_VECTORS             32
+#define BE_MAX_REQ_MSIX_VECTORS         1 /* only one EQ in Linux driver */
+	struct msix_entry msix_entries[BE_MAX_MSIX_VECTORS];
+	bool msix_enabled;	/* MSI has been enabled */
+	bool dma_64bit_cap;	/* the Device DAC capable  or not */
+	bool pm_resume; /* power management resume in progress */
+	u8 dev_state;	/* The current state of the device */
+	u8 dev_pm_state; /* The State of device before going to suspend */
+};
+
+
+struct be_rx_page_info {
+	struct page *page;
+	dma_addr_t bus;
+	u16 page_offset;
+} ;
+
+/*
+ * linux_net_object is an extension to BNI's NetObject structure.
+ * NetObject has a pointer to this structure
+ */
+struct linux_net_object {
+	void *os_handle;	/* Context info for VMM */
+	struct BNI_RECV_BUFFER eth_rx_bufs[256];	/* to pass Rx buffer
+							   addresses */
+	struct be_adapter *adapter;	/* Pointer to OSM adapter */
+	u32 devno;		/* OSM, network dev no. */
+	u32 use_port;		/* Current active port */
+	struct be_rx_page_info *rx_page_info;	/* Array of Rx buf pages */
+	u32 rx_pg_info_hd;	/* Head of queue */
+	int rxbuf_post_fail;	/* RxBuff posting fail count */
+	bool rx_pg_shared;	/* Is an allocsted page shared as two frags ? */
+	struct vlan_group *vlan_grp;
+	u32 num_vlans;		/* Number of vlans in BE's filter */
+	u16 vlan_tag[BE_NUM_VLAN_SUPPORTED]; /* vlans currently configured */
+#ifdef CONFIG_BENET_NAPI
+	struct napi_struct napi;
+	u32 work_quota;		/* Max RX packets to process */
+	bool rx_sched;
+	spinlock_t rx_lock;
+#endif
+#ifdef CONFIG_INET_LRO
+	struct net_lro_mgr lro_mgr;
+	struct net_lro_desc lro_desc[BE_MAX_LRO_DESCRIPTORS];
+#endif
+} ;
+
+/* functions to update RX/TX rates */
+static inline void
+update_rx_rate(struct be_adapter *adapter)
+{
+	/* update the rate once in two seconds */
+	if ((jiffies - adapter->eth_rx_jiffies) > 2*(HZ)) {
+		u32 r;
+		r = adapter->eth_rx_bytes /
+			((jiffies-adapter->eth_rx_jiffies)/(HZ));
+		r = (r / 1000000); /* MB/Sec */
+		adapter->be_stat.bes_eth_rx_rate = (r * 8); /* Mega Bits/Sec */
+		adapter->eth_rx_jiffies = jiffies;
+		adapter->eth_rx_bytes = 0;
+	}
+}
+
+static inline void
+update_tx_rate(struct be_adapter *adapter)
+{
+	/* update the rate once in two seconds */
+	if ((jiffies - adapter->eth_tx_jiffies) > 2*(HZ)) {
+		u32 r;
+		r = adapter->eth_tx_bytes /
+			((jiffies-adapter->eth_tx_jiffies)/(HZ));
+		r = (r / 1000000); /* MB/Sec */
+		adapter->be_stat.bes_eth_tx_rate = (r * 8); /* Mega Bits/Sec */
+		adapter->eth_tx_jiffies = jiffies;
+		adapter->eth_tx_bytes = 0;
+	}
+}
+/*
+ * Every second we look at the ints/sec and adjust eq_delay
+ * between adapter->min_eqd and adapter->max_eqd to keep the ints/sec between
+ * IPS_HI_WM and IPS_LO_WM.
+ */
+#define IPS_HI_WM	18000
+#define IPS_LO_WM	8000
+
+static inline void
+update_eqd(struct be_adapter *adapter, struct bni_net_object *pnob)
+{
+	/* update once a second */
+	if ((jiffies - adapter->ips_jiffies) > 1*(HZ)) {
+		/* One second elapsed since last update	 */
+		u32 r, new_eqd = -1;
+		if (adapter->be_stat.bes_prev_ints >
+				adapter->be_stat.bes_ints) {
+			/* interrupt counter wrapped aroud */
+			r = (0xFFFFFFFF - adapter->be_stat.bes_prev_ints) +
+				adapter->be_stat.bes_ints;
+		} else
+			r = adapter->be_stat.bes_ints -
+				adapter->be_stat.bes_prev_ints;
+		r =  r / ((jiffies - adapter->ips_jiffies)/(HZ));
+		adapter->be_stat.bes_ips = r;
+		adapter->ips_jiffies = jiffies;
+		adapter->be_stat.bes_prev_ints = adapter->be_stat.bes_ints;
+		if (r > IPS_HI_WM && adapter->cur_eqd < adapter->max_eqd) {
+			/* increase eqdelay by a notch */
+			new_eqd = (adapter->cur_eqd + 8);
+		}
+		if (r < IPS_LO_WM && adapter->cur_eqd > adapter->min_eqd) {
+			/* decrease eqdelay by a notch */
+			new_eqd = (adapter->cur_eqd - 8);
+		}
+		if (adapter->enable_aic && new_eqd != -1) {
+			/* program new delay */
+			if (bni_change_eqd(pnob, new_eqd) == BE_SUCCESS)
+				adapter->cur_eqd = new_eqd;
+		}
+	}
+}
+/* convenience macro to access members in Linux extension of NetObject */
+#define OSM_NOB(x)	((struct linux_net_object *)((x)->osm_netobj))
+
+/* proto declarations */
+
+int benet_probe(struct net_device *);
+int be_ethtool_ioctl(struct net_device *, struct ifreq *);
+struct net_device_stats *benet_get_stats(struct net_device *);
+
+void osm_process_sts(unsigned long context);
+irqreturn_t be_int(int irq, void *dev, struct pt_regs *regs);
+
+void post_eth_rx_buffs(struct bni_net_object *);
+void get_stat_cb(void *, BESTATUS, struct MCC_WRB_AMAP *);
+
+void get_stats_timer_handler(unsigned long);
+
+void enable_eq_intr(struct bni_net_object *);
+void disable_eq_intr(struct bni_net_object *);
+
+void wait_nic_tx_cmpl(struct bni_net_object *);
+void be_print_link_info(struct BE_LINK_STATUS *);
+void be_update_link_status(struct be_adapter *);
+
+void be_init_procfs(struct be_adapter *);
+void be_cleanup_procfs(struct be_adapter *);
+
+#ifdef CONFIG_BENET_NAPI
+int be_poll(struct napi_struct *, int);
+#endif
+#endif /* _BE_H */
diff --git a/drivers/net/benet/be_init.c b/drivers/net/benet/be_init.c
new file mode 100644
index 0000000..0de2d22
--- /dev/null
+++ b/drivers/net/benet/be_init.c
@@ -0,0 +1,1356 @@
+/*
+ * Copyright (C) 2005 - 2008 ServerEngines
+ * All rights reserved.
+ *
+ * This program is free software; you can redistribute it and/or
+ * modify it under the terms of the GNU General Public License
+ * as published by the Free Software Foundation; either version 2
+ * of the License, or at your option any later version.
+ *
+ * This program is distributed in the hope that it will be useful, but
+ * WITHOUT ANY WARRANTY; without even the implied warranty of
+ * MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.
+ * See the GNU General Public License for more details.
+ *
+ * You should have received a copy of the GNU General Public License
+ * along with this program; if not, write to the Free Software
+ * Foundation, Inc., 51 Franklin Street, 5th Floor
+ * Boston, MA 02110-1301 USA
+ *
+ *
+ * The full GNU General Public License is included in this distribution
+ * in the file called GPL.
+ *
+ * Contact Information:
+ * linux-drivers@serverengines.com
+ *
+ * ServerEngines
+ * 209 N. Fair Oaks Ave
+ * Sunnyvale, CA 94085
+ *
+ */
+
+#include <linux/pci.h>
+#include <linux/etherdevice.h>
+
+#include "be.h"
+
+#define  DRVR_VERSION  "1.0.688"
+
+static struct pci_device_id be_device_id_table[] = {
+	{PCI_DEVICE(0x19a2, 0x0201)},
+	{0}
+};
+
+MODULE_DEVICE_TABLE(pci, be_device_id_table);
+
+MODULE_VERSION(DRVR_VERSION);
+
+#define DRV_DESCRIPTION "ServerEngines BladeEngine Network Driver Version "
+
+MODULE_DESCRIPTION(DRV_DESCRIPTION DRVR_VERSION);
+MODULE_AUTHOR("ServerEngines");
+MODULE_LICENSE("GPL");
+
+static unsigned int msix; /* default - msix disabled */
+module_param(msix, uint, (0 | 1));
+MODULE_PARM_DESC(msix, "Use MSI-x interrupts");
+
+static unsigned int rxbuf_size = 2048;	/* Size of RX buffers */
+module_param(rxbuf_size, uint, 0);
+MODULE_PARM_DESC(rxbuf_size, "Size of buffers to hold Rx data");
+
+const char be_drvr_ver[] = DRVR_VERSION;
+char be_fw_ver[32];		/* F/W version filled in by be_probe */
+char be_driver_name[] = "benet";
+
+/*
+ * Number of entries in each queue.
+ */
+#define EVENT_Q_LEN		1024
+#define ETH_TXQ_LEN		2048
+#define ETH_TXCQ_LEN		1024
+#define ETH_RXQ_LEN		1024	/* Does not support any other value */
+#define ETH_UC_RXCQ_LEN		1024
+#define ETH_BC_RXCQ_LEN		256
+#define MCC_Q_LEN               64	/* total size not to exceed 8 pages */
+#define MCC_CQ_LEN              256
+
+/*
+ * Intialize and register a network device for the pnob.
+ */
+static int
+init_be_netdev(struct be_adapter *adapter, struct bni_net_object *pnob)
+{
+	struct net_device *netdev;
+	int ret = 0;
+	unsigned char *p;
+
+#ifdef CONFIG_PM
+	if (adapter->pm_resume) {
+		bni_set_uc_mac_adr(pnob, 0, 0, 0,
+				   (struct SA_MAC_ADDRESS *) pnob->mac_address,
+				   NULL, NULL);
+		return 0;
+	}
+#endif
+
+	/*
+	 * Allocate netdev. No private data structure is
+	 * allocated with netdev
+	 */
+	netdev = alloc_etherdev(0);
+	if (netdev == NULL)
+		return -ENOMEM;
+
+	p = (u8 *) (pnob->mac_address);
+	/*
+	 * Get MAC address from receive table
+	 */
+	bni_get_uc_mac_adrr(pnob, 0, 0, OSM_NOB(pnob)->devno,
+		(struct SA_MAC_ADDRESS *) pnob->mac_address, NULL, NULL);
+
+	memcpy(netdev->dev_addr, pnob->mac_address, 6);
+	netdev->priv = pnob;	/* We use the Net Object as private data */
+	netdev->init = &benet_probe;
+	/*
+	 * Initialize to No Link.  Link will be enabled during
+	 * benet_open() or when physical Link is up
+	 */
+	netif_carrier_off(netdev);
+	netif_stop_queue(netdev);
+
+	strcpy(netdev->name, "eth%d");
+
+	SET_NETDEV_DEV(netdev, &(adapter->pdev->dev));
+	ret = register_netdev(netdev);
+	if (ret != 0) {
+		free_netdev(netdev);
+		return (ret);
+	}
+	OSM_NOB(pnob)->os_handle = netdev;
+	return ret;
+}
+
+/* Initialize the pci_info structure for this function */
+static int
+init_pci_be_function(struct be_adapter *adapter, struct pci_dev *pdev)
+{
+	adapter->num_bars = 3;
+	/* CSR */
+	adapter->pci_bars[0].base_pa = pci_resource_start(pdev, 2);
+	adapter->pci_bars[0].base_va =
+		ioremap_nocache(adapter->pci_bars[0].base_pa,
+			    pci_resource_len(pdev, 2));
+	if (adapter->pci_bars[0].base_va == NULL)
+		return -ENOMEM;
+	adapter->pci_bars[0].length = sizeof(struct BLADE_ENGINE_CSRMAP_AMAP);
+	adapter->pci_bars[0].mem_or_io_mapped = SA_MEM_MAPPED;
+	adapter->pci_bars[0].type = SA_BAR_TYPE_CSR;
+
+	/* Door Bell */
+	adapter->pci_bars[1].base_pa = pci_resource_start(pdev, 4);
+	adapter->pci_bars[1].base_va =
+	    ioremap_nocache(adapter->pci_bars[1].base_pa, (128 * 1024));
+	if (adapter->pci_bars[1].base_va == NULL) {
+		iounmap(adapter->pci_bars[0].base_va);
+		return -ENOMEM;
+	}
+	adapter->pci_bars[1].length =
+				sizeof(struct PROTECTION_DOMAIN_DBMAP_AMAP);
+	adapter->pci_bars[1].mem_or_io_mapped = SA_MEM_MAPPED;
+	adapter->pci_bars[1].type = SA_BAR_TYPE_PD;
+
+	/* PCI */
+	adapter->pci_bars[2].base_pa = pci_resource_start(pdev, 1);
+	adapter->pci_bars[2].length = pci_resource_len(pdev, 1);
+	adapter->pci_bars[2].base_va =
+	    ioremap_nocache(adapter->pci_bars[2].base_pa,
+			    adapter->pci_bars[2].length);
+	if (adapter->pci_bars[2].base_va == NULL) {
+		iounmap(adapter->pci_bars[0].base_va);
+		iounmap(adapter->pci_bars[1].base_va);
+		return -ENOMEM;
+	}
+	adapter->pci_bars[2].mem_or_io_mapped = SA_MEM_MAPPED;
+	adapter->pci_bars[2].type = SA_BAR_TYPE_PCI;
+
+	adapter->pdev = pdev;
+
+	return 0;
+}
+
+/*
+ * Enable MSIx and return 1 if successful. Else return 0
+ */
+static int be_enable_msix(struct be_adapter *adapter)
+{
+	unsigned int i, ret;
+
+	if (!msix)
+		return 0;
+
+	adapter->msix_enabled = 1;
+
+	for (i = 0; i < BE_MAX_REQ_MSIX_VECTORS; i++)
+		adapter->msix_entries[i].entry = i;
+
+	ret = pci_enable_msix(adapter->pdev,
+			      adapter->msix_entries,
+			      BE_MAX_REQ_MSIX_VECTORS);
+
+	if (ret) {
+		adapter->msix_enabled = 0;
+		return 0;
+	}
+
+	return 1;
+}
+
+/*
+ * Registers ISR for BE. Uses MSIx interrupt if configured and requested.
+ * If not, uses INTx interrupt. Returns 0 for success and -1 for filure.
+ */
+static int
+be_register_isr(struct be_adapter *adapter, struct bni_net_object *pnob)
+{
+	int msix_intr, r;
+	struct net_device *netdev = OSM_NOB(pnob)->os_handle;
+	u32 msix_ret = 0;
+
+	netdev->irq = adapter->pdev->irq;
+
+	msix_intr = 0;
+	msix_ret = be_enable_msix(adapter);
+	if (msix_ret) {
+		/* Register MSIx Interrupt handler */
+		r = request_irq(adapter->msix_entries[0].vector,
+				(void *)be_int, IRQF_SHARED,
+				netdev->name, netdev);
+		if (r) {
+			printk(KERN_WARNING
+			       "MSIX Request IRQ failed - Errno %d\n", r);
+		} else {
+			msix_intr = 1;
+		}
+	}
+	if (msix_intr == 0) {
+		/* request legacy INTx interrupt */
+		r = request_irq(netdev->irq, (void *)be_int,
+				IRQF_SHARED, netdev->name, netdev);
+		if (r) {
+			printk(KERN_ERR
+			       "INTx Request IRQ failed - Errno %d\n", r);
+			return (-1);
+		}
+	}
+	return (0);
+}
+
+/*
+ * free all resources associated with a pnob
+ * Called at the time of module cleanup as well a any error during
+ * module init.  Some resources may be partially allocated in a NetObj.
+ */
+static void
+cleanup_netobject(struct bni_net_object *pnob)
+{
+	struct net_device *netdev;
+	struct be_adapter *adapter;
+	struct sk_buff *skb;
+	int i;
+
+	SA_ASSERT(pnob);
+	netdev = (struct net_device *)OSM_NOB(pnob)->os_handle;
+	SA_ASSERT(netdev);
+	adapter = (struct be_adapter *) OSM_NOB(pnob)->adapter;
+	SA_ASSERT(adapter);
+
+	/* Only if this netdev is up */
+	if (netif_running(netdev)) {
+		/*
+		 * Let us stop the dev queue for the
+		 * interface associated with this netobj.
+		 */
+		netif_stop_queue(netdev);
+
+		/* Wait until no more pending transmits  */
+		wait_nic_tx_cmpl(pnob);
+
+		/* Disable this EQ's interrupt  */
+		bni_disable_eq_intr(pnob);
+	}
+
+	if ((adapter->isr_registered) & (adapter->msix_enabled))
+		free_irq(adapter->msix_entries[0].vector, netdev);
+	else if ((adapter->isr_registered) & !(adapter->msix_enabled))
+		free_irq(netdev->irq, netdev);
+
+	adapter->isr_registered = 0;
+	if (adapter->msix_enabled) {
+		pci_disable_msix(adapter->pdev);
+		adapter->msix_enabled = 0;
+	}
+	if (adapter->tasklet_started) {
+		tasklet_kill(&(adapter->sts_handler));
+		adapter->tasklet_started = 0;
+	}
+	/* Disable chip interrupt */
+	bni_disable_intr(pnob);
+
+	unregister_netdev(netdev);
+	/* memory associted with netdev is freed by OS  */
+
+	/* Destroy Net Object */
+	bni_destroy_netobj(pnob, &adapter->sa_device);
+
+	adapter->net_obj = NULL;
+	adapter->netdevp = NULL;
+
+	/* free all the memory allocated for the queues */
+
+	if (pnob->mcc_q) {
+		free_pages((unsigned long)pnob->mcc_q,
+			   sa_log2(pnob->mcc_q_pages));
+	}
+
+	if (pnob->mcc_wrb_ctxt) {
+		free_pages((unsigned long)pnob->mcc_wrb_ctxt,
+			   sa_log2(pnob->mcc_wrb_ctxt_pages));
+	}
+
+	if (pnob->mcc_cq) {
+		free_pages((unsigned long)pnob->mcc_cq,
+			   sa_log2(pnob->mcc_cq_pages));
+	}
+
+	if (pnob->event_q) {
+		free_pages((unsigned long)pnob->event_q,
+			   sa_log2(pnob->event_q_pages));
+	}
+
+	if (pnob->tx_cq) {
+		free_pages((unsigned long)pnob->tx_cq,
+			   sa_log2(pnob->tx_cq_pages));
+	}
+
+	if (pnob->tx_q) {
+		free_pages((unsigned long)pnob->tx_q,
+			   sa_log2(pnob->tx_q_pages));
+	}
+
+	if (pnob->bcrx_cq) {
+		free_pages((unsigned long)pnob->bcrx_cq,
+			   sa_log2(pnob->bcrx_cq_pages));
+	}
+
+	if (pnob->rx_q) {
+		free_pages((unsigned long)pnob->rx_q,
+			   sa_log2(pnob->rx_q_pages));
+	}
+
+	if (pnob->ucrx_cq) {
+		free_pages((unsigned long)pnob->ucrx_cq,
+			   sa_log2(pnob->ucrx_cq_pages));
+	}
+
+	/* free all allocated memory stored in the net object */
+	if (pnob->rx_ctxt) {
+		struct be_rx_page_info *rx_page_info;
+		/*
+		 * go through RX context array and free data buffs
+		 */
+		for (i = 0; i < pnob->rx_q_len; i++) {
+			rx_page_info = &(OSM_NOB(pnob)->rx_page_info[i]);
+			if ((OSM_NOB(pnob)->rx_pg_shared == FALSE) ||
+						(rx_page_info->page_offset)) {
+				pci_unmap_page(adapter->pdev,
+					pci_unmap_addr(rx_page_info, bus),
+					pnob->rx_buf_size, PCI_DMA_FROMDEVICE);
+			}
+			if (rx_page_info->page)
+				put_page(rx_page_info->page);
+			memset(rx_page_info, 0, sizeof(struct be_rx_page_info));
+		}
+		OSM_NOB(pnob)->rx_pg_info_hd = 0;
+		kfree(OSM_NOB(pnob)->rx_page_info);
+		kfree(pnob->rx_ctxt);
+	}
+
+	if (pnob->tx_ctxt) {
+		for (i = 0; i < pnob->tx_q_len; i++) {
+			skb = (struct sk_buff *)pnob->tx_ctxt[i];
+			if (skb)
+				kfree_skb(skb);
+		}
+		kfree(pnob->tx_ctxt);
+	}
+
+	kfree(pnob->mb_ptr);
+
+	if (OSM_NOB(pnob))
+		kfree(OSM_NOB(pnob));
+
+	/* finally,  free the net object itself */
+	kfree(pnob);
+
+}
+
+/*
+ * allocate RX resources.
+ */
+static int
+be_setup_tx_res(struct bni_net_object *pnob)
+{
+	int n;
+	struct be_adapter *adapter = OSM_NOB(pnob)->adapter;
+
+	n = pnob->tx_q_len * sizeof(void **);
+	if (!adapter->pm_resume) {
+		pnob->tx_ctxt = kmalloc(n, GFP_KERNEL);
+
+		if (pnob->tx_ctxt == NULL)
+			return -1;
+	}
+	memset(pnob->tx_ctxt, 0, n);
+
+	return 0;
+}
+
+/*
+ * Allocate TX resources.
+ */
+static int
+be_setup_rx_res(struct bni_net_object *pnob)
+{
+	int n;
+	struct be_adapter *adapter = OSM_NOB(pnob)->adapter;
+
+	if (!adapter->pm_resume) {
+		n = (pnob->rx_q_len * sizeof(void *));
+		pnob->rx_ctxt = kmalloc(n, GFP_KERNEL);
+		if (pnob->rx_ctxt == NULL)
+			return -1;
+
+		n = (pnob->rx_q_len * sizeof(struct be_rx_page_info));
+		OSM_NOB(pnob)->rx_page_info = kzalloc(n, GFP_KERNEL);
+		if (OSM_NOB(pnob)->rx_page_info == NULL) {
+			kfree(pnob->rx_ctxt);
+			return -1;
+		}
+	}
+	memset(pnob->rx_ctxt, 0, pnob->rx_q_len * sizeof(void *));
+	memset(OSM_NOB(pnob)->rx_page_info, 0,
+		pnob->rx_q_len * sizeof(struct be_rx_page_info));
+
+	OSM_NOB(pnob)->rx_pg_info_hd = 0;
+	pnob->rx_q_hd = 0;
+	pnob->rx_q_posted = 0;
+	/* post  ETH RX buffers */
+	post_eth_rx_buffs(pnob);
+
+	return 0;
+}
+
+/*
+ * this function creates a pnob with a set of Eth rings.
+ */
+static int
+be_prepare_interface(struct be_adapter *adapter)
+{
+	struct net_device *netdev = NULL;
+	struct bni_net_object *pnob = NULL;
+	struct SA_DEV_BAR_LOCATIONS pci_bars[3];
+	int status;
+	u32 n, m;
+	void *p;
+
+	if (!adapter->pm_resume) {
+		/*Normal Mode */
+		memcpy(pci_bars, adapter->pci_bars,
+		       sizeof(adapter->pci_bars));
+
+		pnob = (struct bni_net_object *)
+		    kzalloc(sizeof(struct bni_net_object), GFP_KERNEL);
+
+		if (pnob == NULL)
+			goto err_ret1;
+
+		pnob->osm_netobj = (struct linux_net_object *)
+		    kzalloc(sizeof(struct linux_net_object), GFP_KERNEL);
+		if (pnob->osm_netobj == NULL) {
+			kfree(pnob);
+			goto err_ret1;
+		}
+
+		OSM_NOB(pnob)->devno = 0;
+		OSM_NOB(pnob)->adapter = adapter;
+
+		/* Mail box sgl */
+		pnob->mb_sgl.length = sizeof(struct MCC_MAILBOX_AMAP);
+		p = kzalloc(pnob->mb_sgl.length + 16, GFP_KERNEL);
+		if (p == NULL)
+			goto err_ret1;
+		/* Mailbox pointer needs to be 16 byte aligned */
+		pnob->mb_ptr = p;
+		p = (void *) ((unsigned long)(p + 15) & ~0xf);
+		pnob->mb_sgl.va = (void *)p;
+		pnob->mb_sgl.pa = virt_to_phys(p);
+		pnob->mb_sgl.pa = cpu_to_le64(pnob->mb_sgl.pa);
+		/*
+		 * Event queue
+		 */
+		pnob->event_q_len = EVENT_Q_LEN;
+		n = pnob->event_q_len * sizeof(struct EQ_ENTRY_AMAP);
+		n = MAX(n, (2 * PAGE_SIZE));
+		/* Get number of pages */
+		m = (n + (PAGE_SIZE - 1)) / (PAGE_SIZE);
+		pnob->event_q = (struct EQ_ENTRY_AMAP *)
+		    __get_free_pages(GFP_KERNEL, sa_log2(m));
+		if (pnob->event_q == NULL)
+			goto err_ret1;
+		pnob->event_q_pa = virt_to_phys(pnob->event_q);
+		pnob->event_q_pa = cpu_to_le64(pnob->event_q_pa);
+		pnob->event_q_pages = m;
+		/*
+		 * Eth TX queue
+		 */
+		pnob->tx_q_len = ETH_TXQ_LEN;
+		pnob->tx_q_port = 0;	/* No port binding */
+		n = pnob->tx_q_len * sizeof(struct ETH_WRB_AMAP);
+		n = MAX(n, PAGE_SIZE);	/* Need to allocate alteast one page */
+		/* Get number of pages */
+		m = (n + (PAGE_SIZE - 1)) / (PAGE_SIZE);
+		pnob->tx_q = (struct ETH_WRB_AMAP *)
+		    __get_free_pages(GFP_KERNEL, sa_log2(m));
+		if (pnob->tx_q == NULL)
+			goto err_ret1;
+		pnob->tx_q_pa = virt_to_phys(pnob->tx_q);
+		pnob->tx_q_pa = cpu_to_le64(pnob->tx_q_pa);
+		pnob->tx_q_pages = m;
+		/*
+		 * Eth TX Compl queue
+		 */
+		pnob->txcq_len = ETH_TXCQ_LEN;
+		n = pnob->txcq_len * sizeof(struct ETH_TX_COMPL_AMAP);
+		n = MAX(n, PAGE_SIZE);	/* Need to allocate alteast one page */
+		/* Get number of pages */
+		m = (n + (PAGE_SIZE - 1)) / (PAGE_SIZE);
+		pnob->tx_cq = (struct ETH_TX_COMPL_AMAP *)
+		    __get_free_pages(GFP_KERNEL, sa_log2(m));
+		if (pnob->tx_cq == NULL)
+			goto err_ret1;
+		pnob->tx_cq_pa = virt_to_phys(pnob->tx_cq);
+		pnob->tx_cq_pa = cpu_to_le64(pnob->tx_cq_pa);
+		pnob->tx_cq_pages = m;
+		/*
+		 * Eth RX queue
+		 */
+		pnob->rx_q_len = ETH_RXQ_LEN;
+		n = pnob->rx_q_len * sizeof(struct ETH_RX_D_AMAP);
+		n = MAX(n, PAGE_SIZE);	/* Need to allocate alteast one page */
+		/* Get number of pages */
+		m = (n + (PAGE_SIZE - 1)) / (PAGE_SIZE);
+		pnob->rx_q = (struct ETH_RX_D_AMAP *)
+		    __get_free_pages(GFP_KERNEL, sa_log2(m));
+		if (pnob->rx_q == NULL)
+			goto err_ret1;
+		pnob->rx_q_pa = virt_to_phys(pnob->rx_q);
+		pnob->rx_q_pa = cpu_to_le64(pnob->rx_q_pa);
+		pnob->rx_q_pages = m;
+		/*
+		 * Eth Unicast RX Compl queue
+		 */
+		pnob->ucrx_cq_len = ETH_UC_RXCQ_LEN;
+		n = pnob->ucrx_cq_len * sizeof(struct ETH_RX_COMPL_AMAP);
+		n = MAX(n, PAGE_SIZE);	/* Need to allocate alteast one page */
+		/* Get number of pages */
+		m = (n + (PAGE_SIZE - 1)) / (PAGE_SIZE);
+		pnob->ucrx_cq = (struct ETH_RX_COMPL_AMAP *)
+		    __get_free_pages(GFP_KERNEL, sa_log2(m));
+		if (pnob->ucrx_cq == NULL)
+			goto err_ret1;
+		pnob->ucrx_cq_pa = virt_to_phys(pnob->ucrx_cq);
+		pnob->ucrx_cq_pa = cpu_to_le64(pnob->ucrx_cq_pa);
+		pnob->ucrx_cq_pages = m;
+		/*
+		 * Eth Broadcast RX Compl queue
+		 */
+		pnob->bcrx_cq_len = ETH_BC_RXCQ_LEN;
+		n = pnob->bcrx_cq_len * sizeof(struct ETH_RX_COMPL_AMAP);
+		n = MAX(n, PAGE_SIZE);
+		/* Get number of pages */
+		m = (n + (PAGE_SIZE - 1)) / (PAGE_SIZE);
+		pnob->bcrx_cq = (struct ETH_RX_COMPL_AMAP *)
+		    __get_free_pages(GFP_KERNEL, sa_log2(m));
+		if (pnob->bcrx_cq == NULL)
+			goto err_ret1;
+		pnob->bcrx_cq_pa = virt_to_phys(pnob->bcrx_cq);
+		pnob->bcrx_cq_pa = cpu_to_le64(pnob->bcrx_cq_pa);
+		pnob->bcrx_cq_pages = m;
+
+		/* Allocate DMA'ble Memory for IOCTL_ETH_GET_STATISTICS */
+		adapter->eth_statsp = (struct IOCTL_ETH_GET_STATISTICS *)
+			kmalloc(sizeof(struct IOCTL_ETH_GET_STATISTICS),
+								GFP_KERNEL);
+		if (adapter->eth_statsp == NULL)
+			goto err_ret1;
+		pnob->rx_buf_size = rxbuf_size;
+		/*
+		 * Set dev close to be TRUE. This will be enabled on dev open
+		 */
+		adapter->dev_state = BE_DEV_STATE_NONE;
+	} else {
+		pnob = adapter->net_obj;
+		memcpy(pci_bars, adapter->pci_bars,
+		       sizeof(adapter->pci_bars));
+	}
+
+	memset(pnob->event_q, 0, pnob->event_q_pages * PAGE_SIZE);
+	pnob->event_q_tl = 0;
+
+	memset(pnob->tx_q, 0, pnob->tx_q_pages * PAGE_SIZE);
+	pnob->tx_q_hd = 0;
+	pnob->tx_q_tl = 0;
+
+	memset(pnob->tx_cq, 0, pnob->tx_cq_pages * PAGE_SIZE);
+	pnob->tx_cq_tl = 0;
+
+	memset(pnob->rx_q, 0, pnob->rx_q_pages * PAGE_SIZE);
+
+	memset(pnob->ucrx_cq, 0, pnob->ucrx_cq_pages * PAGE_SIZE);
+	pnob->ucrx_cq_tl = 0;
+
+	memset(pnob->bcrx_cq, 0, pnob->bcrx_cq_pages * PAGE_SIZE);
+	pnob->bcrx_cq_tl = 0;
+	n = bni_create_netobj(pnob, pci_bars, adapter->num_bars,
+				   &adapter->sa_device,
+				   &adapter->chip_object);
+	if (n != BE_SUCCESS)
+		goto err_ret1;
+
+	status = init_be_netdev(adapter, pnob);
+	if (status < 0)
+		goto err_ret;
+	netdev = OSM_NOB(pnob)->os_handle;
+
+	if (be_setup_tx_res(pnob))
+		goto err_ret;
+	if (be_setup_rx_res(pnob))
+		goto err_ret;
+
+	if (!adapter->pm_resume) {
+#ifdef CONFIG_BENET_NAPI
+		netif_napi_add(netdev, &OSM_NOB(pnob)->napi, be_poll, 64);
+		OSM_NOB(pnob)->rx_sched = FALSE;
+		spin_lock_init(&OSM_NOB(pnob)->rx_lock);
+#endif
+		adapter->netdevp = OSM_NOB(pnob)->os_handle;
+		adapter->net_obj = pnob;
+	}
+	return 0;
+
+err_ret:
+	cleanup_netobject(pnob);
+
+err_ret1:
+	printk(KERN_ERR "Interface initialization failed\n");
+	return -1;
+}
+
+/* This function handles async callback for link status */
+static void
+be_link_status_async_callback(void *context, u32 event_code, void *event)
+{
+	struct ASYNC_EVENT_LINK_STATE_AMAP *link_status =
+				(struct ASYNC_EVENT_LINK_STATE_AMAP *) event;
+	struct be_adapter *adapter = (struct be_adapter *) context;
+	bool  link_enable = FALSE;
+	struct bni_net_object *pnob;
+	struct ASYNC_EVENT_TRAILER_AMAP *async_trailer;
+	struct net_device *netdev;
+	u32 async_event_code, async_event_type, active_port;
+	u32 port0_link_status, port1_link_status, port0_duplex, port1_duplex;
+	u32 port0_speed, port1_speed;
+
+	if (event_code != ASYNC_EVENT_CODE_LINK_STATE) {
+		/* Not our event to handle */
+		return;
+	}
+	async_trailer = (struct ASYNC_EVENT_TRAILER_AMAP *)
+			((u8 *) event + sizeof(struct MCC_CQ_ENTRY_AMAP) -
+				sizeof(struct ASYNC_EVENT_TRAILER_AMAP));
+
+	async_event_code = AMAP_GET_BITS_PTR(ASYNC_EVENT_TRAILER, event_code,
+				async_trailer);
+	SA_ASSERT(async_event_code == ASYNC_EVENT_CODE_LINK_STATE);
+
+	pnob = adapter->net_obj;
+	SA_ASSERT(pnob);
+	netdev = (struct net_device *)OSM_NOB(pnob)->os_handle;
+	SA_ASSERT(netdev);
+
+	/* Determine if this event is a switch VLD or a physical link event */
+	async_event_type = AMAP_GET_BITS_PTR(ASYNC_EVENT_TRAILER, event_type,
+					async_trailer);
+	active_port = AMAP_GET_BITS_PTR(ASYNC_EVENT_LINK_STATE,
+				active_port, link_status);
+	port0_link_status = AMAP_GET_BITS_PTR(ASYNC_EVENT_LINK_STATE,
+				port0_link_status, link_status);
+	port1_link_status = AMAP_GET_BITS_PTR(ASYNC_EVENT_LINK_STATE,
+				port1_link_status, link_status);
+	port0_duplex = AMAP_GET_BITS_PTR(ASYNC_EVENT_LINK_STATE,
+				port0_duplex, link_status);
+	port1_duplex = AMAP_GET_BITS_PTR(ASYNC_EVENT_LINK_STATE,
+				port1_duplex, link_status);
+	port0_speed = AMAP_GET_BITS_PTR(ASYNC_EVENT_LINK_STATE,
+				port0_speed, link_status);
+	port1_speed = AMAP_GET_BITS_PTR(ASYNC_EVENT_LINK_STATE,
+				port1_speed, link_status);
+	if (async_event_type == NTWK_LINK_TYPE_VIRTUAL) {
+		adapter->be_stat.bes_link_change_virtual++;
+		if (adapter->be_link_sts->active_port != active_port) {
+			printk(KERN_NOTICE
+				"Active port changed due to VLD on switch\n");
+		} else {
+			/* Link of atleast one of the ports changed */
+			printk(KERN_NOTICE "Link status update\n");
+		}
+
+	} else {
+		adapter->be_stat.bes_link_change_physical++;
+		if (adapter->be_link_sts->active_port != active_port) {
+			printk(KERN_NOTICE
+				"Active port changed due to port link status"
+				" change\n");
+		} else {
+			/* Link of atleast one of the ports changed */
+			printk(KERN_NOTICE "Link status update\n");
+		}
+	}
+
+	/* Clear memory of adapter->be_link_sts */
+	memset(adapter->be_link_sts, 0, sizeof(adapter->be_link_sts));
+
+	if ((port0_link_status == ASYNC_EVENT_LINK_UP) ||
+	    (port1_link_status == ASYNC_EVENT_LINK_UP)) {
+		if ((adapter->port0_link_sts == BE_PORT_LINK_DOWN) &&
+		    (adapter->port1_link_sts == BE_PORT_LINK_DOWN)) {
+			/*
+			 * Earlier both the ports are down
+			 * So link is up
+			 */
+			link_enable = TRUE;
+		}
+
+		if (port0_link_status == ASYNC_EVENT_LINK_UP) {
+			adapter->port0_link_sts = BE_PORT_LINK_UP;
+			adapter->be_link_sts->mac0_duplex = port0_duplex;
+			adapter->be_link_sts->mac0_speed = port0_speed;
+			if (active_port == NTWK_PORT_A)
+				adapter->be_link_sts->active_port = 0;
+		} else
+			adapter->port0_link_sts = BE_PORT_LINK_DOWN;
+
+		if (port1_link_status == ASYNC_EVENT_LINK_UP) {
+			adapter->port1_link_sts = BE_PORT_LINK_UP;
+			adapter->be_link_sts->mac1_duplex = port1_duplex;
+			adapter->be_link_sts->mac1_speed = port1_speed;
+			if (active_port == NTWK_PORT_B)
+				adapter->be_link_sts->active_port = 1;
+		} else
+			adapter->port1_link_sts = BE_PORT_LINK_DOWN;
+
+		printk(KERN_INFO "Link Properties for %s:\n", netdev->name);
+		be_print_link_info(adapter->be_link_sts);
+
+		if (!link_enable)
+			return;
+		/*
+		 * Both ports were down previously, but atleast one of
+		 * them has come up if this netdevice's carrier is not up,
+		 * then indicate to stack
+		 */
+		if (!netif_carrier_ok(netdev)) {
+			netif_start_queue(netdev);
+			netif_carrier_on(netdev);
+		}
+		return;
+	}
+
+	/* Now both the ports are down. Tell the stack about it */
+	printk(KERN_INFO "Both ports are down\n");
+
+	adapter->port0_link_sts = BE_PORT_LINK_DOWN;
+	adapter->port1_link_sts = BE_PORT_LINK_DOWN;
+
+	/* if this netdevice's carrier is not down, then indicate to stack */
+	if (netif_carrier_ok(netdev)) {
+		netif_carrier_off(netdev);
+		netif_stop_queue(netdev);
+	}
+	return;
+}
+
+/* Function to initialize MCC rings */
+static int
+be_mcc_init(struct be_adapter *adapter)
+{
+	u32 n, r, m;
+	struct bni_net_object *pnob;
+
+	pnob = adapter->net_obj;
+	if (!adapter->pm_resume) {
+		/*
+		 * Create the MCC ring so that all further communication with
+		 * MCC can go thru the ring. we do this at the end since
+		 * we do not want to be dealing with interrupts until the
+		 * initialization is complete.
+		 */
+		pnob->mcc_q_len = MCC_Q_LEN;
+		n = pnob->mcc_q_len * sizeof(struct MCC_WRB_AMAP);
+		n = MAX(n, PAGE_SIZE);
+		/* Get number of pages */
+		m = (n + (PAGE_SIZE - 1)) / (PAGE_SIZE);
+		pnob->mcc_q =
+		    (struct MCC_WRB_AMAP *) __get_free_pages(GFP_KERNEL,
+								sa_log2(m));
+		if (pnob->mcc_q == NULL)
+			goto cleanup;
+		pnob->mcc_q_pages = m;
+		pnob->mcc_q_pa = virt_to_phys(pnob->mcc_q);
+		pnob->mcc_q_pa = cpu_to_le64(pnob->mcc_q_pa);
+		/*
+		 * space for MCC WRB context
+		 */
+		pnob->mcc_wrb_ctxtLen = MCC_Q_LEN;
+		n = pnob->mcc_wrb_ctxtLen * sizeof(struct BE_MCC_WRB_CONTEXT);
+		n = MAX(n, PAGE_SIZE);	/* Need to allocate alteast one page */
+		/* Get number of pages */
+		m = (n + (PAGE_SIZE - 1)) / (PAGE_SIZE);
+		pnob->mcc_wrb_ctxt =
+		    (void *) __get_free_pages(GFP_KERNEL, sa_log2(m));
+		if (pnob->mcc_wrb_ctxt == NULL)
+			goto cleanup;
+		pnob->mcc_wrb_ctxt_pages = m;
+		/*
+		 * Space for MCC compl. ring
+		 */
+		pnob->mcc_cq_len = MCC_CQ_LEN;
+		n = pnob->mcc_cq_len * sizeof(struct MCC_CQ_ENTRY_AMAP);
+		n = MAX(n, PAGE_SIZE);	/* Need to allocate alteast one page */
+		/* Get number of pages */
+		m = (n + (PAGE_SIZE - 1)) / (PAGE_SIZE);
+		pnob->mcc_cq =
+		    (struct MCC_CQ_ENTRY_AMAP *) __get_free_pages(GFP_KERNEL,
+						     sa_log2(m));
+		if (pnob->mcc_cq == NULL)
+			goto cleanup;
+		pnob->mcc_cq_pa = virt_to_phys(pnob->mcc_cq);
+		pnob->mcc_cq_pa = cpu_to_le64(pnob->mcc_cq_pa);
+		pnob->mcc_cq_pages = m;
+
+	}
+	memset(pnob->mcc_q, 0, pnob->mcc_q_pages * PAGE_SIZE);
+	pnob->mcc_q_hd = 0;
+
+	memset(pnob->mcc_wrb_ctxt, 0, pnob->mcc_wrb_ctxt_pages * PAGE_SIZE);
+
+	memset(pnob->mcc_cq, 0, pnob->mcc_cq_pages * PAGE_SIZE);
+	pnob->mcc_cq_tl = 0;
+
+	r = bni_create_mcc_rings(adapter->net_obj);
+	if (r != BE_SUCCESS)
+		goto cleanup;
+
+	return 0;
+cleanup:
+	return -ENOMEM;
+
+}
+
+static void
+be_remove(struct pci_dev *pdev)
+{
+	struct bni_net_object *pnob = NULL;
+	struct be_adapter *adapter = NULL;
+	int status;
+	int i;
+
+	adapter = pci_get_drvdata(pdev);
+	pnob = (struct bni_net_object *) adapter->net_obj;
+
+	SA_ASSERT(adapter);
+
+	flush_scheduled_work();
+
+	/* Unregister async call back function for link status updates */
+	status = be_mcc_add_async_event_callback(&pnob->mcc_q_obj, NULL, NULL);
+	if (status != BE_SUCCESS)
+		printk(KERN_WARNING "Unregister async callback for link "
+		       "status updates failed.\n");
+
+	cleanup_netobject(pnob);
+
+	bni_cleanup(&adapter->chip_object);
+
+	for (i = 0; i < adapter->num_bars; i++) {
+		if (adapter->pci_bars[i].base_va)
+			iounmap(adapter->pci_bars[i].base_va);
+	}
+
+	pci_release_regions(adapter->pdev);
+	pci_disable_device(adapter->pdev);
+
+	/* Free Link status structure */
+	kfree(adapter->be_link_sts);
+	kfree(adapter->eth_statsp);
+
+	del_timer_sync(&adapter->timer_ctxt.get_stats_timer);
+
+	kfree(adapter);
+}
+
+/*
+ * This function is called by the PCI sub-system when it finds a PCI
+ * device with dev/vendor IDs that match with one of our devices.
+ * All of the driver initialization is done in this function.
+ */
+static int
+be_probe(struct pci_dev *pdev, const struct pci_device_id *pdev_id)
+{
+	int status = 0;
+	struct be_adapter *adapter = NULL;
+	u32 r;
+	u32 adapt_num = 0;
+	struct IOCTL_COMMON_GET_FW_VERSION_RESPONSE_PAYLOAD ioctl_pload;
+	struct bni_net_object *pnob = NULL;
+
+	status = pci_enable_device(pdev);
+	if (status) {
+		printk(KERN_ERR "pci_enable_device() for BE adapter %d failed",
+		       adapt_num);
+		return status;
+	}
+
+	status = pci_request_regions(pdev, be_driver_name);
+	if (status)
+		return status;
+
+	pci_set_master(pdev);
+
+	adapter = kzalloc(sizeof(struct be_adapter), GFP_KERNEL);
+	if (adapter == NULL) {
+		pci_release_regions(pdev);
+		goto err_ret;
+	}
+
+	pci_set_drvdata(pdev, adapter);
+	/*
+	 * Adapative interrupt coalescing limits in usecs.
+	 * should be a multiple of 8.
+	 */
+	adapter->enable_aic = 1;
+	adapter->max_eqd = MAX_EQD;
+	adapter->min_eqd = 0;
+	adapter->cur_eqd = 0;	/* start with no EQ delay */
+	r = pci_set_dma_mask(pdev, DMA_64BIT_MASK);
+	if (!r) {
+		/* Device is DAC Capable.  */
+		adapter->dma_64bit_cap = TRUE;
+	} else {
+		adapter->dma_64bit_cap = FALSE;
+		r = pci_set_dma_mask(pdev, DMA_32BIT_MASK);
+		if (r) {
+			printk(KERN_ERR "Could not set PCI DMA Mask\n");
+			return r;
+		}
+	}
+
+	status = init_pci_be_function(adapter, pdev);
+	if (status < 0) {
+		printk(KERN_ERR "Failed to map PCI BARS\n");
+		status = -ENOMEM;
+		goto cleanup1;
+	}
+
+	(void)sa_trace_set_level((DL_ALWAYS | DL_ERR));
+
+	r = bni_init(&adapter->chip_object);
+	if (r != 0) {
+		printk(KERN_ERR "bni_init() failed - Error %d\n", r);
+		goto cleanup1;
+	}
+
+	/* Allocate Memory for getting the Link status */
+	adapter->be_link_sts = (struct BE_LINK_STATUS *)
+	    kmalloc(sizeof(struct BE_LINK_STATUS), GFP_KERNEL);
+	if (adapter->be_link_sts == NULL) {
+		printk(KERN_ERR "Memory allocation for link status "
+				"buffer failed\n");
+		goto cleanup1;
+	}
+	spin_lock_init(&adapter->txq_lock);
+
+	status = be_prepare_interface(adapter);
+	if (status < 0)
+		goto cleanup1;
+
+	pnob = adapter->net_obj;
+
+	/* if the rx_frag size if 2K, one page is shared as two RX frags */
+	OSM_NOB(pnob)->rx_pg_shared =
+			(pnob->rx_buf_size <= PAGE_SIZE / 2) ? TRUE : FALSE;
+	if (pnob->rx_buf_size != rxbuf_size) {
+		printk(KERN_WARNING
+		       "Could not set Rx buffer size to %d. Using %d\n",
+		       rxbuf_size, pnob->rx_buf_size);
+		rxbuf_size = pnob->rx_buf_size;
+	}
+
+	tasklet_init(&(adapter->sts_handler), osm_process_sts,
+		     (unsigned long)adapter);
+	adapter->tasklet_started = 1;	/* indication to cleanup */
+	spin_lock_init(&(adapter->int_lock));
+
+
+	if (be_register_isr(adapter, pnob) != 0)
+		goto cleanup;
+
+	adapter->isr_registered = 1;
+	adapter->rx_csum = 1;	/* enable RX checksum check */
+	adapter->max_rx_coal = BE_LRO_MAX_PKTS;
+
+	/* print the version numbers */
+	memset(&ioctl_pload, 0,
+	       sizeof(struct IOCTL_COMMON_GET_FW_VERSION_RESPONSE_PAYLOAD));
+	printk(KERN_INFO "BladeEngine Driver version:%s. "
+	       "Copyright ServerEngines, Corporation 2005 - 2008\n",
+		be_drvr_ver);
+	status = be_function_get_fw_version(&pnob->fn_obj, &ioctl_pload, NULL,
+				       NULL);
+	if (status == BE_SUCCESS) {
+		strncpy(be_fw_ver, ioctl_pload.firmware_version_string, 32);
+		printk(KERN_INFO "BladeEngine Firmware Version:%s\n",
+		       ioctl_pload.firmware_version_string);
+	} else {
+		printk(KERN_WARNING "Unable to get BE Firmware Version\n");
+	}
+
+	sema_init(&adapter->get_eth_stat_sem, 0);
+
+	init_timer(&adapter->timer_ctxt.get_stats_timer);
+	atomic_set(&adapter->timer_ctxt.get_stat_flag, 0);
+	adapter->timer_ctxt.get_stats_timer.function = &get_stats_timer_handler;
+
+	status = be_mcc_init(adapter);
+	if (status < 0)
+		goto cleanup;
+	be_update_link_status(adapter);
+
+	/* Register async call back function to handle link status updates */
+	status = be_mcc_add_async_event_callback(&adapter->net_obj->mcc_q_obj,
+			    be_link_status_async_callback, (void *) adapter);
+	if (status != BE_SUCCESS) {
+		printk(KERN_WARNING "add_async_event_callback failed");
+		printk(KERN_WARNING
+		       "Link status changes may not be reflected\n");
+	}
+
+	/* Enable ChipInterrupt and EQ Interrupt */
+	bni_enable_intr(adapter->net_obj);
+	bni_enable_eq_intr(adapter->net_obj);
+	adapter->dev_state = BE_DEV_STATE_INIT;
+	return 0;		/* successful return */
+
+cleanup1:
+	pci_release_regions(pdev);
+	pci_disable_device(pdev);
+	kfree(adapter);
+	goto err_ret;
+
+cleanup:
+	be_remove(pdev);
+
+err_ret:
+	printk(KERN_ERR "BladeEngine init failed\n");
+	return -ENOMEM;
+}
+
+/*
+ * Get the current link status and print the status on console
+ */
+void
+be_update_link_status(struct be_adapter *adapter)
+{
+	int status;
+	struct bni_net_object *pnob = adapter->net_obj;
+
+	status = bni_get_link_sts(pnob, adapter->be_link_sts, NULL, NULL);
+
+	if (status == BE_SUCCESS) {
+		if (adapter->be_link_sts->mac0_speed &&
+		    adapter->be_link_sts->mac0_duplex)
+			adapter->port0_link_sts = BE_PORT_LINK_UP;
+		else
+			adapter->port0_link_sts = BE_PORT_LINK_DOWN;
+
+		if (adapter->be_link_sts->mac1_speed &&
+		    adapter->be_link_sts->mac1_duplex)
+			adapter->port1_link_sts = BE_PORT_LINK_UP;
+		else
+			adapter->port1_link_sts = BE_PORT_LINK_DOWN;
+
+		printk(KERN_INFO "Link Properties for %s:\n",
+		       ((struct net_device *)(OSM_NOB(pnob)->os_handle))->name);
+		be_print_link_info(adapter->be_link_sts);
+		return;
+	}
+	printk(KERN_WARNING "Could not get link status for %s\n",
+	       ((struct net_device *)(OSM_NOB(pnob)->os_handle))->name);
+	return;
+}
+
+
+#ifdef CONFIG_PM
+static void
+be_pm_cleanup(struct be_adapter *adapter,
+		  struct bni_net_object *pnob, struct net_device *netdev)
+{
+	u32 i;
+
+	netif_carrier_off(netdev);
+	netif_stop_queue(netdev);
+
+	wait_nic_tx_cmpl(pnob);
+	bni_disable_eq_intr(pnob);
+
+	if (adapter->tasklet_started) {
+		tasklet_kill(&adapter->sts_handler);
+		adapter->tasklet_started = 0;
+	}
+
+	if (adapter->msix_enabled) {
+		if (adapter->isr_registered) {
+			free_irq(adapter->msix_entries[0].vector, netdev);
+			adapter->tasklet_started = 0;
+			adapter->isr_registered = 0;
+		}
+	}
+
+	if (adapter->isr_registered) {
+		/* This is an INTX Interrupt */
+		free_irq(netdev->irq, netdev);
+		adapter->isr_registered = 0;
+	}
+
+	/* Disable chip interrupt */
+	bni_disable_intr(pnob);
+	bni_destroy_netobj(pnob, &adapter->sa_device);
+
+	if (pnob->rx_ctxt) {
+		struct be_rx_page_info *rx_page_info;
+
+		/*
+		 * go through RX context array and free
+		 * data buffs
+		 */
+		for (i = 0; i < pnob->rx_q_len; i++) {
+			rx_page_info = &(OSM_NOB(pnob)->rx_page_info[i]);
+			if ((OSM_NOB(pnob)->rx_pg_shared == FALSE) ||
+						(rx_page_info->page_offset))
+				pci_unmap_page(adapter->pdev,
+					       pci_unmap_addr(rx_page_info,
+							      bus),
+					       pnob->rx_buf_size,
+					       PCI_DMA_FROMDEVICE);
+			if (rx_page_info->page)
+				put_page(rx_page_info->page);
+			memset(rx_page_info, 0, sizeof(struct be_rx_page_info));
+		}
+		OSM_NOB(pnob)->rx_pg_info_hd = 0;
+	}
+
+}
+static int
+be_suspend(struct pci_dev *pdev, pm_message_t state)
+{
+	struct net_device *netdev = NULL;
+	struct bni_net_object *pnob = NULL;
+	struct be_adapter *adapter = NULL;
+
+	adapter = pci_get_drvdata(pdev);
+	netdev = adapter->netdevp;
+	pnob = (struct bni_net_object *) netdev->priv;
+	adapter->dev_pm_state = adapter->dev_state;
+	adapter->dev_state = BE_DEV_STATE_INIT;
+
+	netif_device_detach(netdev);
+	SA_ASSERT(adapter);
+
+	netif_device_detach(netdev);
+	if (netif_running(netdev))
+		be_pm_cleanup(adapter, pnob, netdev);
+
+	pci_enable_wake(pdev, 3, 1);
+	pci_enable_wake(pdev, 4, 1);	/* D3 Cold = 4 */
+	pci_save_state(pdev);
+	pci_disable_device(pdev);
+	pci_set_power_state(pdev, pci_choose_state(pdev, state));
+	return 0;
+}
+
+static void
+be_up(struct be_adapter *adapter)
+{
+	struct bni_net_object *pnob = adapter->net_obj;
+
+	if (OSM_NOB(pnob)->num_vlans != 0)
+		bni_config_vlan(pnob, OSM_NOB(pnob)->vlan_tag,
+				OSM_NOB(pnob)->num_vlans, NULL, NULL, 0);
+
+}
+static int
+be_resume(struct pci_dev *pdev)
+{
+	int status = 0;
+	struct net_device *netdev = NULL;
+	struct bni_net_object *pnob = NULL;
+	struct be_adapter *adapter = NULL;
+
+	adapter = pci_get_drvdata(pdev);
+	adapter->pm_resume = 1;
+	netdev = adapter->netdevp;
+	pnob = (struct bni_net_object *) netdev->priv;
+	netif_device_detach(netdev);
+
+	SA_ASSERT(adapter);
+
+	status = pci_enable_device(pdev);
+	if (status)
+		return status;
+
+	pci_set_power_state(pdev, 0);
+	pci_restore_state(pdev);
+	pci_enable_wake(pdev, 3, 0);
+	pci_enable_wake(pdev, 4, 0);	/* 4 is D3 cold */
+
+	netif_carrier_on(netdev);
+	netif_start_queue(netdev);
+
+	if (netif_running(netdev)) {
+		status = be_prepare_interface(adapter);
+
+		if (status < 0)
+			return (status);
+
+		tasklet_init(&(adapter->sts_handler), osm_process_sts,
+				(unsigned long)adapter);
+		adapter->tasklet_started = 1;	/* indication to cleanup */
+
+		if (be_register_isr(adapter, pnob) != 0) {
+			printk(KERN_ERR "be_register_isr failed\n");
+			return (status);
+		}
+
+		adapter->isr_registered = 1;
+
+		status = be_mcc_init(adapter);
+		if (status < 0) {
+			printk(KERN_ERR "be_mcc_init failed\n");
+			return (status);
+		}
+		be_update_link_status(adapter);
+		/*
+		 * Register async call back function to handle link
+		 * status updates
+		 */
+		status = be_mcc_add_async_event_callback(
+			&adapter->net_obj->mcc_q_obj,
+			be_link_status_async_callback,
+					    (void *) adapter);
+		if (status != BE_SUCCESS) {
+			printk(KERN_WARNING "add_async_event_callback failed");
+			printk(KERN_WARNING
+			       "Link status changes may not be reflected\n");
+		}
+		bni_enable_intr(pnob);
+		bni_enable_eq_intr(pnob);
+		be_up(adapter);
+	}
+	netif_device_attach(netdev);
+	adapter->dev_state = adapter->dev_pm_state;
+	adapter->pm_resume = 0;
+	return 0;
+
+}
+
+
+#endif
+
+/* Wait until no more pending transmits  */
+void
+wait_nic_tx_cmpl(struct bni_net_object *pnob)
+{
+	int i;
+
+	/* Wait for 20us * 50000 (= 1s) and no more */
+	i = 0;
+	while ((pnob->tx_q_tl != pnob->tx_q_hd) && (i < 50000)) {
+		++i;
+		udelay(20);
+	}
+
+	/* Check for no more pending transmits */
+	if (i >= 50000) {
+		printk(KERN_WARNING
+		       "Did not receive completions for all TX requests\n");
+	}
+}
+
+static struct pci_driver be_driver = {
+      .name = be_driver_name,
+      .id_table = be_device_id_table,
+      .probe = be_probe,
+#ifdef CONFIG_PM
+      .suspend = be_suspend,
+      .resume = be_resume,
+#endif
+      .remove = be_remove
+};
+
+/*
+ * Module init entry point. Registers our our device and return.
+ * Our probe will be called if the device is found.
+ */
+
+static int __init be_init_module(void)
+{
+	int ret;
+
+	if ((rxbuf_size != 8192) && (rxbuf_size != 4096)
+	    && (rxbuf_size != 2048)) {
+		printk(KERN_WARNING
+		       "Unsupported receive buffer size (%d) requested\n",
+		       rxbuf_size);
+		printk(KERN_WARNING
+		       "Must be 2048, 4096 or 8192. Defaulting to 2048\n");
+		rxbuf_size = 2048;
+	}
+
+	ret = pci_register_driver(&be_driver);
+
+	return ret;
+}
+
+module_init(be_init_module);
+
+/*
+ * be_exit_module - Driver Exit Cleanup Routine
+ */
+static void __exit be_exit_module(void)
+{
+	pci_unregister_driver(&be_driver);
+}
+
+module_exit(be_exit_module);
diff --git a/drivers/net/benet/bni.h b/drivers/net/benet/bni.h
new file mode 100644
index 0000000..073c76d
--- /dev/null
+++ b/drivers/net/benet/bni.h
@@ -0,0 +1,335 @@
+/*
+ * Copyright (C) 2005 - 2008 ServerEngines
+ * All rights reserved.
+ *
+ * This program is free software; you can redistribute it and/or
+ * modify it under the terms of the GNU General Public License
+ * as published by the Free Software Foundation; either version 2
+ * of the License, or at your option any later version.
+ *
+ * This program is distributed in the hope that it will be useful, but
+ * WITHOUT ANY WARRANTY; without even the implied warranty of
+ * MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.
+ * See the GNU General Public License for more details.
+ *
+ * You should have received a copy of the GNU General Public License
+ * along with this program; if not, write to the Free Software
+ * Foundation, Inc., 51 Franklin Street, 5th Floor
+ * Boston, MA 02110-1301 USA
+ *
+ *
+ * The full GNU General Public License is included in this distribution
+ * in the file called GPL.
+ *
+ * Contact Information:
+ * linux-drivers@serverengines.com
+ *
+ * ServerEngines
+ * 209 N. Fair Oaks Ave
+ * Sunnyvale, CA 94085
+ *
+ */
+/*
+
+@file
+    bni.h
+
+@brief
+    Definitions and macros that are required for all .c files
+    that use the BNI API and implement the BNI API functions
+*/
+#ifndef _BNI_H
+#define _BNI_H
+
+#define _SA_MODULE_NAME "net-driver"
+#include "beclib_ll.h"
+
+#define VLAN_VALID_BIT		0x8000
+#define BE_NUM_VLAN_SUPPORTED	32
+#define BE_PORT_LINK_DOWN       0000
+#define BE_PORT_LINK_UP         0001
+
+#define TOU32(_struct_) *((u32 *)(&(_struct_)))
+
+/*
+@brief
+    This structure is used by the OSM driver to give BNI
+    physical fragments to use for DMAing data from NIC.
+*/
+struct BNI_RECV_BUFFER {
+	SA_LIST_ENTRY rxb_list;	/* for maintaining a linked list */
+	void *rxb_va;		/* buffer virtual address */
+	u32 rxb_pa_lo;		/* low part of physical address */
+	u32 rxb_pa_hi;		/* high part of physical address */
+	u32 rxb_len;		/* length of recv buffer */
+	void *rxb_ctxt;		/* context for OSM driver to use */
+};
+
+/*
+ * fragment list to describe scattered data.
+ */
+struct BNI_TX_FRAG_LIST {
+	u32 txb_len;		/* Size of this fragment */
+	u32 txb_pa_lo;		/* Lower 32 bits of 64 bit physical addr */
+	u32 txb_pa_hi;		/* Higher 32 bits of 64 bit physical addr */
+};
+/*
+ * maximum fragements in a TX request
+ */
+#define	BE_MAX_TX_FRAG_COUNT		(30)
+
+/*
+ * Flag bits for send operation
+ */
+#define IPCS            (1 << 0)	/* Enable IP checksum offload */
+#define UDPCS           (1 << 1)	/* Enable UDP checksum offload */
+#define TCPCS           (1 << 2)	/* Enable TCP checksum offload */
+#define LSO             (1 << 3)	/* Enable Large Segment  offload */
+#define ETHVLAN         (1 << 4)	/* Enable VLAN insert */
+#define ETHEVENT        (1 << 5)	/* Generate  event on completion */
+#define ETHCOMPLETE     (1 << 6)	/* Generate completion when done */
+#define IPSEC           (1 << 7)	/* Enable IPSEC */
+#define FORWARD         (1 << 8)	/* Send the packet in forwarding path */
+#define FIN             (1 << 9)	/* Issue FIN segment */
+
+/* @brief
+ *  This structure is the main tracking structure for a NIC interface.
+ *  This data structure contains OS agnostic data members for processing
+ *  intialization, sends, receives, and asynchronous events from the
+ *  BladeEngine network function. The OSM driver makes
+ *  calls into functions defined at this layer for initialization,
+ *  eumeration and population of physical fragments with per-packet
+ *  control flags for send and receive operations, population of
+ *  receive buffers for NIC , and handling asynchronous
+ *  events (such as link status change, packet pattern recognition etc.).
+ */
+struct bni_net_object {
+
+	/*
+	 * MCC Ring - used to send ioctl cmds to embedded ARM processor
+	 */
+	struct MCC_WRB_AMAP *mcc_q;	/* VA of the start of the ring */
+	u32 mcc_q_len;			/* # of WRB entries in this ring */
+	u32 mcc_q_hd;			/* MCC ring head */
+	u8 mcc_q_created;		/* flag to help cleanup */
+	u8 mcc_q_pages;			/* Num of pages allocacted by OSM */
+	struct BE_MCC_OBJECT mcc_q_obj;	/* BECLIB's MCC ring Object */
+	u64 mcc_q_pa;			/* Physical address in LE order */
+	/*
+	 * MCC Completion Ring - ARM's responses to ioctls sent from MCC ring
+	 */
+	struct MCC_CQ_ENTRY_AMAP *mcc_cq; /* VA of the start of the ring */
+	u32 mcc_cq_len;			/* # of compl. entries in this ring */
+	u32 mcc_cq_tl;			/* compl. ring tail */
+	u8 mcc_cq_created;		/* flag to help cleanup */
+	u8 mcc_cq_pages;		/* Num of pages allocacted by OSM */
+	struct BE_CQ_OBJECT mcc_cq_obj;	/* BECLIB's MCC compl. ring object */
+	u32 mcc_cq_id;			/* MCC ring ID */
+	u64 mcc_cq_pa;			/* Physical address in LE order */
+	/*
+	 * BEClib uses an array of context objects to track outstanding
+	 * requests to the MCC.  We need allocate the same number of
+	 * conext entries as the number of entries in the MCC WRB ring
+	 */
+	u8 mcc_wrb_ctxt_pages;		/* Num of pages allocacted by OSM */
+	void *mcc_wrb_ctxt;		/* pointer to the context area */
+	u32 mcc_wrb_ctxtLen;		/* Number of entries in the context */
+	/*
+	 * NIC send request ring - used for xmitting raw ether frames.
+	 */
+	struct ETH_WRB_AMAP *tx_q;	/* VA of the start of the ring */
+	u32 tx_q_len;			/* # if entries in the send ring */
+	u32 tx_q_hd;			/* Head index. Next req. goes here */
+	u32 tx_q_tl;			/* Tail indx. oldest outstanding req. */
+	u8 tx_q_created;		/* flag to help cleanup */
+	u8 tx_q_pages;			/* Num of pages allocacted by OSM */
+	struct BE_ETHSQ_OBJECT tx_q_obj;/* BECLIB's send Q handle */
+	u64 tx_q_pa;			/* Physical address in LE order */
+	u32 tx_q_id;			/* send queue ring ID */
+	u32 tx_q_port;			/* 0 no binding, 1 port A,  2 port B */
+	u32 tx_q_used;			/* # of WRBs used */
+	/* ptr to an array in which we store context info for each send req. */
+	void **tx_ctxt;
+	/*
+	 * NIC Send compl. ring - completion status for all NIC frames xmitted.
+	 */
+	struct ETH_TX_COMPL_AMAP *tx_cq;/* VA of start of the ring */
+	u32 txcq_len;			/* # of entries in the ring */
+	/*
+	 * index into compl ring where the host expects next completion entry
+	 */
+	u32 tx_cq_tl;
+	u32 tx_cq_id;			/* completion queue id */
+	u8 tx_cq_created;		/* flag to help cleanup */
+	u8 tx_cq_pages;			/* Num of pages allocacted by OSM */
+	struct BE_CQ_OBJECT tx_cq_obj;
+	u64 tx_cq_pa;			/* Physical address in LE order */
+	/*
+	 * Event Queue - all completion entries post events here.
+	 */
+	struct EQ_ENTRY_AMAP *event_q;	/* VA of start of event queue */
+	u32 event_q_len;		/* # of entries */
+	u32 event_q_tl;			/* Tail of the event queue */
+	u32 event_q_id;			/* Event queue ID */
+	u8 event_q_created;		/* flag to help cleanup */
+	u8 event_q_pages;		/* Num of pages allocacted by OSM */
+	struct BE_EQ_OBJECT event_q_obj; /* Queue handle */
+	u64 event_q_pa;			/* Physical address in LE order */
+	/*
+	 * NIC receive queue - Data buffers to be used for receiving unicast,
+	 * broadcast and multi-cast frames  are posted here.
+	 */
+	struct ETH_RX_D_AMAP *rx_q;	/* VA of start of the queue */
+	u32 rx_q_len;			/* # of entries */
+	u32 rx_q_hd;			/* Head of the queue */
+	u32 rx_q_posted;		/* number of posted buffers */
+	u32 rx_q_id;			/* queue ID */
+	u8 rx_q_created;		/* flag to help cleanup */
+	u8 rx_q_pages;			/* Num of pages allocacted by OSM */
+	struct BE_ETHRQ_OBJECT rx_q_obj;	/* NIC RX queue handle */
+	u64 rx_q_pa;			/* Physical address */
+	/*
+	 * Pointer to an array of opaque context object for use by OSM driver
+	 */
+	void **rx_ctxt;
+	/*
+	 * NIC unicast RX completion queue - all unicast ether frame completion
+	 * statuses from BE come here.
+	 */
+	struct ETH_RX_COMPL_AMAP *ucrx_cq;	/* VA of start of the queue */
+	u32 ucrx_cq_len;		/* # of entries */
+	u32 ucrx_cq_tl;			/* Tail of the queue */
+	u32 ucrx_cq_id;			/* queue ID */
+	u8 ucrx_cq_created;		/* flag to help cleanup */
+	u8 ucrx_cq_pages;		/* Num of pages allocacted by OSM */
+	struct BE_CQ_OBJECT ucrx_cq_obj;	/* queue handle */
+	u64 ucrx_cq_pa;			/* Physical address in LE order */
+	/*
+	 * Broadcast RX completion queue - all broadcast and multicast ether
+	 * completion statues from BE come here.
+	 */
+	struct ETH_RX_COMPL_AMAP *bcrx_cq;	/* VA of start of queue */
+	u32 bcrx_cq_len;		/* # of entries */
+	u32 bcrx_cq_tl;			/* Tail of the queue */
+	u32 bcrx_cq_id;			/* Queue ID */
+	u8 bcrx_cq_created;		/* flag to help cleanup */
+	u8 bcrx_cq_pages;		/* Num of pages allocacted by OSM */
+	struct BE_CQ_OBJECT bcrx_cq_obj;	/* queue handle */
+	u64 bcrx_cq_pa;			/* Physical address in LE order */
+
+	struct BE_FUNCTION_OBJECT fn_obj;	/* function object   */
+	u32 rx_buf_size;		/* Size of the RX buffers */
+	u8 mac_address[6];		/* MAC address */
+	/*
+	 * OSM handle. OSM drivers can use this pointer to extend NetObject.
+	 */
+	void *osm_netobj;
+	struct SA_SGL mb_sgl;			/* SGL for MCC_MAIL_BOX */
+	void *mb_ptr;			/* mailbox ptr to be freed  */
+};
+
+/*
+ * convenience macros to access some NetObject members
+ */
+#define NET_FH(np)       (&(np)->fn_obj)
+
+/*
+ * Functions to advance the head and tail in various rings.
+ */
+static INLINE void bni_adv_eq_tl(struct bni_net_object *pnob)
+{
+	pnob->event_q_tl = (pnob->event_q_tl + 1) % pnob->event_q_len;
+}
+
+static INLINE void bni_adv_txq_hd(struct bni_net_object *pnob)
+{
+	pnob->tx_q_hd = (pnob->tx_q_hd + 1) % pnob->tx_q_len;
+}
+
+static INLINE void bni_adv_txq_tl(struct bni_net_object *pnob)
+{
+	pnob->tx_q_tl = (pnob->tx_q_tl + 1) % pnob->tx_q_len;
+}
+
+static INLINE void bni_adv_txcq_tl(struct bni_net_object *pnob)
+{
+	pnob->tx_cq_tl = (pnob->tx_cq_tl + 1) % pnob->txcq_len;
+}
+
+static INLINE void bni_adv_rxq_hd(struct bni_net_object *pnob)
+{
+	pnob->rx_q_hd = (pnob->rx_q_hd + 1) % pnob->rx_q_len;
+}
+
+static INLINE void bni_adv_ucrxcq_tl(struct bni_net_object *pnob)
+{
+	pnob->ucrx_cq_tl = (pnob->ucrx_cq_tl + 1) % pnob->ucrx_cq_len;
+}
+
+static INLINE void bni_adv_bcrxcq_tl(struct bni_net_object *pnob)
+{
+	pnob->bcrx_cq_tl = (pnob->bcrx_cq_tl + 1) % pnob->bcrx_cq_len;
+}
+
+static INLINE BESTATUS bni_process_mcc_cmpl(struct BE_MCC_OBJECT *pmccob)
+{
+	return (be_mcc_process_cq(pmccob, 1));
+}
+
+/* forward declarations of function prototypes */
+BESTATUS bni_init(struct BE_CHIP_OBJECT *);
+BESTATUS bni_create_mcc_rings(struct bni_net_object *);
+extern void bni_destroy_netobj(struct bni_net_object *, struct SA_DEV *);
+void bni_cleanup(struct BE_CHIP_OBJECT *);
+
+BESTATUS bni_create_netobj(struct bni_net_object *,
+			struct SA_DEV_BAR_LOCATIONS *, u32,
+			struct SA_DEV *, struct BE_CHIP_OBJECT *);
+
+BESTATUS bni_tx_pkt(struct bni_net_object *, struct BNI_TX_FRAG_LIST *, u32,
+		    u32, u32, void *, u32);
+void bni_start_tx(struct bni_net_object *, u32);
+
+u32 bni_post_rx_buffs(struct bni_net_object *, SA_LIST_ENTRY *);
+BESTATUS bni_change_eqd(struct bni_net_object *, u32);
+
+struct ETH_TX_COMPL_AMAP *bni_get_tx_cmpl(struct bni_net_object *);
+struct ETH_RX_COMPL_AMAP *bni_get_ucrx_cmpl(struct bni_net_object *);
+struct ETH_RX_COMPL_AMAP *bni_get_bcrx_cmpl(struct bni_net_object *);
+void bni_notify_cmpl(struct bni_net_object *, int, int, int);
+
+void bni_enable_intr(struct bni_net_object *);
+void bni_enable_eq_intr(struct bni_net_object *);
+void bni_disable_intr(struct bni_net_object *);
+void bni_disable_eq_intr(struct bni_net_object *);
+
+u32 bni_get_isr(struct bni_net_object *);
+
+struct EQ_ENTRY_AMAP *bni_get_event(struct bni_net_object *);
+void bni_notify_event(struct bni_net_object *, int, int);
+
+BESTATUS bni_get_uc_mac_adrr(struct bni_net_object *, u8, u8, u8,
+		     struct SA_MAC_ADDRESS  *, MCC_WRB_CQE_CALLBACK, void *);
+
+BESTATUS bni_set_uc_mac_adr(struct bni_net_object *, u8, u8, u8,
+		    struct SA_MAC_ADDRESS *, MCC_WRB_CQE_CALLBACK, void *);
+
+BESTATUS bni_set_mc_filter(struct bni_net_object *, u32,
+		   bool, struct SA_MAC_ADDRESS *, MCC_WRB_CQE_CALLBACK, void *);
+
+void bni_set_promisc(struct bni_net_object *);
+void bni_reset_promisc(struct bni_net_object *);
+BESTATUS bni_config_vlan(struct bni_net_object *, u16 *,
+			 u32, MCC_WRB_CQE_CALLBACK, void *, bool);
+
+BESTATUS bni_get_stats(struct bni_net_object *,
+		       struct IOCTL_ETH_GET_STATISTICS *,
+		       u64, MCC_WRB_CQE_CALLBACK, void *);
+
+BESTATUS bni_get_link_sts(struct bni_net_object *, struct BE_LINK_STATUS *,
+			  MCC_WRB_CQE_CALLBACK, void *);
+BESTATUS bni_set_flow_ctll(struct BE_FUNCTION_OBJECT *, bool, bool);
+BESTATUS bni_get_flow_ctl(struct BE_FUNCTION_OBJECT *pFnObj, bool *, bool *);
+u32 bni_process_rx_flush_cmpl(struct bni_net_object *);
+
+#endif /* #ifndef _BNI_H_ */
-- 
1.5.5

___________________________________________________________________________________
This message, together with any attachment(s), contains confidential and proprietary information of
ServerEngines Corporation and is intended only for the designated recipient(s) named above. Any unauthorized
review, printing, retention, copying, disclosure or distribution is strictly prohibited.  If you are not the
intended recipient of this message, please immediately advise the sender by reply email message and
delete all copies of this message and any attachment(s). Thank you.

