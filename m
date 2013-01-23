From: Mark Einon <mark.einon@gmail.com>
Subject: =?UTF-8?q?=5BRFC=20PATCH=20v4=20linux-next=5D=20et131x=3A=20Promote=20staging=20et131x=20driver=20to=20drivers/net?=
Date: Wed, 23 Jan 2013 16:24:38 +0000
Message-ID: <1358958278-3207-1-git-send-email-mark.einon@gmail.com>
References: <1358945130-3101-1-git-send-email-mark.einon@gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: netdev@vger.kernel.org, devel@driverdev.osuosl.org,
	linux-kernel@vger.kernel.org, dan.carpenter@oracle.com,
	Mark Einon <mark.einon@gmail.com>
To: davem@davemloft.net, gregkh@linuxfoundation.org,
	sfr@canb.auug.org.au
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <1358945130-3101-1-git-send-email-mark.einon@gmail.com>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

This patch moves the et131x gigabit ethernet driver from drivers/stagin=
g
to drivers/net/ethernet/agere.

All the existing issues noted for this driver have been resolved, apart
from one performance issue where some fragmented packets suffer from
frame receive errors.

Signed-off-by: Mark Einon <mark.einon@gmail.com>
---

Changes from v3 - diff format now shows file contents

 MAINTAINERS                         |   11 +-
 drivers/net/ethernet/Kconfig        |    1 +
 drivers/net/ethernet/Makefile       |    1 +
 drivers/net/ethernet/agere/Kconfig  |   32 +
 drivers/net/ethernet/agere/Makefile |    6 +
 drivers/net/ethernet/agere/et131x.c | 4981 +++++++++++++++++++++++++++=
++++++++
 drivers/net/ethernet/agere/et131x.h | 1710 ++++++++++++
 7 files changed, 6737 insertions(+), 5 deletions(-)
 create mode 100644 drivers/net/ethernet/agere/Kconfig
 create mode 100644 drivers/net/ethernet/agere/Makefile
 create mode 100644 drivers/net/ethernet/agere/et131x.c
 create mode 100644 drivers/net/ethernet/agere/et131x.h

diff --git a/MAINTAINERS b/MAINTAINERS
index e80447a..cb09e9e 100644
--- a/MAINTAINERS
+++ b/MAINTAINERS
@@ -3029,6 +3029,12 @@ T:	git git://git.kernel.org/pub/scm/linux/kernel=
/git/kristoffer/linux-hpc.git
 F:	drivers/video/s1d13xxxfb.c
 F:	include/video/s1d13xxxfb.h
=20
+ET131X NETWORK DRIVER
+M:	Mark Einon <mark.einon@gmail.com>
+L:	netdev@vger.kernel.org
+S:	Maintained
+F:	drivers/net/ethernet/agere
+
 ETHEREXPRESS-16 NETWORK DRIVER
 M:	Philip Blundell <philb@gnu.org>
 L:	netdev@vger.kernel.org
@@ -7473,11 +7479,6 @@ M:	David Rowe <david@rowetel.com>
 S:	Odd Fixes
 F:	drivers/staging/echo/
=20
-STAGING - ET131X NETWORK DRIVER
-M:	Mark Einon <mark.einon@gmail.com>
-S:	Odd Fixes
-F:	drivers/staging/et131x/
-
 STAGING - FLARION FT1000 DRIVERS
 M:	Marek Belisko <marek.belisko@gmail.com>
 S:	Odd Fixes
diff --git a/drivers/net/ethernet/Kconfig b/drivers/net/ethernet/Kconfi=
g
index ed956e0..4b4edbb 100644
--- a/drivers/net/ethernet/Kconfig
+++ b/drivers/net/ethernet/Kconfig
@@ -20,6 +20,7 @@ config SUNGEM_PHY
 source "drivers/net/ethernet/3com/Kconfig"
 source "drivers/net/ethernet/adaptec/Kconfig"
 source "drivers/net/ethernet/aeroflex/Kconfig"
+source "drivers/net/ethernet/agere/Kconfig"
 source "drivers/net/ethernet/alteon/Kconfig"
 source "drivers/net/ethernet/amd/Kconfig"
 source "drivers/net/ethernet/apple/Kconfig"
diff --git a/drivers/net/ethernet/Makefile b/drivers/net/ethernet/Makef=
ile
index 8268d85..7a96adb 100644
--- a/drivers/net/ethernet/Makefile
+++ b/drivers/net/ethernet/Makefile
@@ -6,6 +6,7 @@ obj-$(CONFIG_NET_VENDOR_3COM) +=3D 3com/
 obj-$(CONFIG_NET_VENDOR_8390) +=3D 8390/
 obj-$(CONFIG_NET_VENDOR_ADAPTEC) +=3D adaptec/
 obj-$(CONFIG_GRETH) +=3D aeroflex/
+obj-$(CONFIG_NET_VENDOR_AGERE) +=3D agere/
 obj-$(CONFIG_NET_VENDOR_ALTEON) +=3D alteon/
 obj-$(CONFIG_NET_VENDOR_AMD) +=3D amd/
 obj-$(CONFIG_NET_VENDOR_APPLE) +=3D apple/
diff --git a/drivers/net/ethernet/agere/Kconfig b/drivers/net/ethernet/=
agere/Kconfig
new file mode 100644
index 0000000..efe0b90
--- /dev/null
+++ b/drivers/net/ethernet/agere/Kconfig
@@ -0,0 +1,32 @@
+#
+# Agere device configuration
+#
+
+config NET_VENDOR_AGERE
+       bool "Agere devices"
+       default y
+       depends on PCI
+       ---help---
+         If you have a network (Ethernet) card belonging to this class=
, say Y
+         and read the Ethernet-HOWTO, available from
+         <http://www.tldp.org/docs.html#howto>.
+
+         Note that the answer to this question doesn't directly affect=
 the
+         kernel: saying N will just cause the configurator to skip all
+         the questions about Agere devices. If you say Y, you will be =
asked
+         for your specific card in the following questions.
+
+if NET_VENDOR_AGERE
+
+config ET131X
+       tristate "Agere ET-1310 Gigabit Ethernet support"
+       depends on PCI
+       select PHYLIB
+       ---help---
+         This driver supports Agere ET-1310 ethernet adapters.
+
+         To compile this driver as a module, choose M here. The module
+         will be called et131x.
+
+endif # NET_VENDOR_AGERE
+
diff --git a/drivers/net/ethernet/agere/Makefile b/drivers/net/ethernet=
/agere/Makefile
new file mode 100644
index 0000000..740f413
--- /dev/null
+++ b/drivers/net/ethernet/agere/Makefile
@@ -0,0 +1,6 @@
+#
+# Makefile for the Agere ET-131x ethernet driver
+#
+
+obj-$(CONFIG_ET131X) +=3D et131x.o
+
diff --git a/drivers/net/ethernet/agere/et131x.c b/drivers/net/ethernet=
/agere/et131x.c
new file mode 100644
index 0000000..73dc639
--- /dev/null
+++ b/drivers/net/ethernet/agere/et131x.c
@@ -0,0 +1,4981 @@
+/* Agere Systems Inc.
+ * 10/100/1000 Base-T Ethernet Driver for the ET1301 and ET131x series=
 MACs
+ *
+ * Copyright =C2=A9 2005 Agere Systems Inc.
+ * All rights reserved.
+ *   http://www.agere.com
+ *
+ * Copyright (c) 2011 Mark Einon <mark.einon@gmail.com>
+ *
+ *--------------------------------------------------------------------=
----------
+ *
+ * SOFTWARE LICENSE
+ *
+ * This software is provided subject to the following terms and condit=
ions,
+ * which you should read carefully before using the software.  Using t=
his
+ * software indicates your acceptance of these terms and conditions.  =
If you do
+ * not agree with these terms and conditions, do not use the software.
+ *
+ * Copyright =C2=A9 2005 Agere Systems Inc.
+ * All rights reserved.
+ *
+ * Redistribution and use in source or binary forms, with or without
+ * modifications, are permitted provided that the following conditions=
 are met:
+ *
+ * . Redistributions of source code must retain the above copyright no=
tice, this
+ *    list of conditions and the following Disclaimer as comments in t=
he code as
+ *    well as in the documentation and/or other materials provided wit=
h the
+ *    distribution.
+ *
+ * . Redistributions in binary form must reproduce the above copyright=
 notice,
+ *    this list of conditions and the following Disclaimer in the docu=
mentation
+ *    and/or other materials provided with the distribution.
+ *
+ * . Neither the name of Agere Systems Inc. nor the names of the contr=
ibutors
+ *    may be used to endorse or promote products derived from this sof=
tware
+ *    without specific prior written permission.
+ *
+ * Disclaimer
+ *
+ * THIS SOFTWARE IS PROVIDED "AS IS" AND ANY EXPRESS OR IMPLIED WARRAN=
TIES,
+ * INCLUDING, BUT NOT LIMITED TO, INFRINGEMENT AND THE IMPLIED WARRANT=
IES OF
+ * MERCHANTABILITY AND FITNESS FOR A PARTICULAR PURPOSE ARE DISCLAIMED=
=2E  ANY
+ * USE, MODIFICATION OR DISTRIBUTION OF THIS SOFTWARE IS SOLELY AT THE=
 USERS OWN
+ * RISK. IN NO EVENT SHALL AGERE SYSTEMS INC. OR CONTRIBUTORS BE LIABL=
E FOR ANY
+ * DIRECT, INDIRECT, INCIDENTAL, SPECIAL, EXEMPLARY, OR CONSEQUENTIAL =
DAMAGES
+ * (INCLUDING, BUT NOT LIMITED TO, PROCUREMENT OF SUBSTITUTE GOODS OR =
SERVICES;
+ * LOSS OF USE, DATA, OR PROFITS; OR BUSINESS INTERRUPTION) HOWEVER CA=
USED AND
+ * ON ANY THEORY OF LIABILITY, INCLUDING, BUT NOT LIMITED TO, CONTRACT=
, STRICT
+ * LIABILITY, OR TORT (INCLUDING NEGLIGENCE OR OTHERWISE) ARISING IN A=
NY WAY OUT
+ * OF THE USE OF THIS SOFTWARE, EVEN IF ADVISED OF THE POSSIBILITY OF =
SUCH
+ * DAMAGE.
+ */
+
+#define pr_fmt(fmt) KBUILD_MODNAME ": " fmt
+
+#include <linux/pci.h>
+#include <linux/init.h>
+#include <linux/module.h>
+#include <linux/types.h>
+#include <linux/kernel.h>
+
+#include <linux/sched.h>
+#include <linux/ptrace.h>
+#include <linux/slab.h>
+#include <linux/ctype.h>
+#include <linux/string.h>
+#include <linux/timer.h>
+#include <linux/interrupt.h>
+#include <linux/in.h>
+#include <linux/delay.h>
+#include <linux/bitops.h>
+#include <linux/io.h>
+
+#include <linux/netdevice.h>
+#include <linux/etherdevice.h>
+#include <linux/skbuff.h>
+#include <linux/if_arp.h>
+#include <linux/ioport.h>
+#include <linux/crc32.h>
+#include <linux/random.h>
+#include <linux/phy.h>
+
+#include "et131x.h"
+
+MODULE_AUTHOR("Victor Soriano <vjsoriano@agere.com>");
+MODULE_AUTHOR("Mark Einon <mark.einon@gmail.com>");
+MODULE_LICENSE("Dual BSD/GPL");
+MODULE_DESCRIPTION("10/100/1000 Base-T Ethernet Driver for the ET1310 =
by Agere Systems");
+
+/* EEPROM defines */
+#define MAX_NUM_REGISTER_POLLS          1000
+#define MAX_NUM_WRITE_RETRIES           2
+
+/* MAC defines */
+#define COUNTER_WRAP_16_BIT 0x10000
+#define COUNTER_WRAP_12_BIT 0x1000
+
+/* PCI defines */
+#define INTERNAL_MEM_SIZE       0x400	/* 1024 of internal memory */
+#define INTERNAL_MEM_RX_OFFSET  0x1FF	/* 50%   Tx, 50%   Rx */
+
+/* ISR defines */
+/* For interrupts, normal running is:
+ *       rxdma_xfr_done, phy_interrupt, mac_stat_interrupt,
+ *       watchdog_interrupt & txdma_xfer_done
+ *
+ * In both cases, when flow control is enabled for either Tx or bi-dir=
ection,
+ * we additional enable rx_fbr0_low and rx_fbr1_low, so we know when t=
he
+ * buffer rings are running low.
+ */
+#define INT_MASK_DISABLE            0xffffffff
+
+/* NOTE: Masking out MAC_STAT Interrupt for now...
+ * #define INT_MASK_ENABLE             0xfff6bf17
+ * #define INT_MASK_ENABLE_NO_FLOW     0xfff6bfd7
+ */
+#define INT_MASK_ENABLE             0xfffebf17
+#define INT_MASK_ENABLE_NO_FLOW     0xfffebfd7
+
+/* General defines */
+/* Packet and header sizes */
+#define NIC_MIN_PACKET_SIZE	60
+
+/* Multicast list size */
+#define NIC_MAX_MCAST_LIST	128
+
+/* Supported Filters */
+#define ET131X_PACKET_TYPE_DIRECTED		0x0001
+#define ET131X_PACKET_TYPE_MULTICAST		0x0002
+#define ET131X_PACKET_TYPE_BROADCAST		0x0004
+#define ET131X_PACKET_TYPE_PROMISCUOUS		0x0008
+#define ET131X_PACKET_TYPE_ALL_MULTICAST	0x0010
+
+/* Tx Timeout */
+#define ET131X_TX_TIMEOUT	(1 * HZ)
+#define NIC_SEND_HANG_THRESHOLD	0
+
+/* MP_TCB flags */
+#define FMP_DEST_MULTI			0x00000001
+#define FMP_DEST_BROAD			0x00000002
+
+/* MP_ADAPTER flags */
+#define FMP_ADAPTER_INTERRUPT_IN_USE	0x00000008
+
+/* MP_SHARED flags */
+#define FMP_ADAPTER_LOWER_POWER		0x00200000
+
+#define FMP_ADAPTER_NON_RECOVER_ERROR	0x00800000
+#define FMP_ADAPTER_HARDWARE_ERROR	0x04000000
+
+#define FMP_ADAPTER_FAIL_SEND_MASK	0x3ff00000
+
+/* Some offsets in PCI config space that are actually used. */
+#define ET1310_PCI_MAC_ADDRESS		0xA4
+#define ET1310_PCI_EEPROM_STATUS	0xB2
+#define ET1310_PCI_ACK_NACK		0xC0
+#define ET1310_PCI_REPLAY		0xC2
+#define ET1310_PCI_L0L1LATENCY		0xCF
+
+/* PCI Product IDs */
+#define ET131X_PCI_DEVICE_ID_GIG	0xED00	/* ET1310 1000 Base-T 8 */
+#define ET131X_PCI_DEVICE_ID_FAST	0xED01	/* ET1310 100  Base-T */
+
+/* Define order of magnitude converter */
+#define NANO_IN_A_MICRO	1000
+
+#define PARM_RX_NUM_BUFS_DEF    4
+#define PARM_RX_TIME_INT_DEF    10
+#define PARM_RX_MEM_END_DEF     0x2bc
+#define PARM_TX_TIME_INT_DEF    40
+#define PARM_TX_NUM_BUFS_DEF    4
+#define PARM_DMA_CACHE_DEF      0
+
+/* RX defines */
+#define FBR_CHUNKS		32
+#define MAX_DESC_PER_RING_RX	1024
+
+/* number of RFDs - default and min */
+#define RFD_LOW_WATER_MARK	40
+#define NIC_DEFAULT_NUM_RFD	1024
+#define NUM_FBRS		2
+
+#define NUM_PACKETS_HANDLED	256
+
+#define ALCATEL_MULTICAST_PKT	0x01000000
+#define ALCATEL_BROADCAST_PKT	0x02000000
+
+/* typedefs for Free Buffer Descriptors */
+struct fbr_desc {
+	u32 addr_lo;
+	u32 addr_hi;
+	u32 word2;		/* Bits 10-31 reserved, 0-9 descriptor */
+};
+
+/* Packet Status Ring Descriptors
+ *
+ * Word 0:
+ *
+ * top 16 bits are from the Alcatel Status Word as enumerated in
+ * PE-MCXMAC Data Sheet IPD DS54 0210-1 (also IPD-DS80 0205-2)
+ *
+ * 0: hp			hash pass
+ * 1: ipa			IP checksum assist
+ * 2: ipp			IP checksum pass
+ * 3: tcpa			TCP checksum assist
+ * 4: tcpp			TCP checksum pass
+ * 5: wol			WOL Event
+ * 6: rxmac_error		RXMAC Error Indicator
+ * 7: drop			Drop packet
+ * 8: ft			Frame Truncated
+ * 9: jp			Jumbo Packet
+ * 10: vp			VLAN Packet
+ * 11-15: unused
+ * 16: asw_prev_pkt_dropped	e.g. IFG too small on previous
+ * 17: asw_RX_DV_event		short receive event detected
+ * 18: asw_false_carrier_event	bad carrier since last good packet
+ * 19: asw_code_err		one or more nibbles signalled as errors
+ * 20: asw_CRC_err		CRC error
+ * 21: asw_len_chk_err		frame length field incorrect
+ * 22: asw_too_long		frame length > 1518 bytes
+ * 23: asw_OK			valid CRC + no code error
+ * 24: asw_multicast		has a multicast address
+ * 25: asw_broadcast		has a broadcast address
+ * 26: asw_dribble_nibble	spurious bits after EOP
+ * 27: asw_control_frame	is a control frame
+ * 28: asw_pause_frame		is a pause frame
+ * 29: asw_unsupported_op	unsupported OP code
+ * 30: asw_VLAN_tag		VLAN tag detected
+ * 31: asw_long_evt		Rx long event
+ *
+ * Word 1:
+ * 0-15: length			length in bytes
+ * 16-25: bi			Buffer Index
+ * 26-27: ri			Ring Index
+ * 28-31: reserved
+ */
+
+struct pkt_stat_desc {
+	u32 word0;
+	u32 word1;
+};
+
+/* Typedefs for the RX DMA status word */
+
+/* rx status word 0 holds part of the status bits of the Rx DMA engine
+ * that get copied out to memory by the ET-1310.  Word 0 is a 32 bit w=
ord
+ * which contains the Free Buffer ring 0 and 1 available offset.
+ *
+ * bit 0-9 FBR1 offset
+ * bit 10 Wrap flag for FBR1
+ * bit 16-25 FBR0 offset
+ * bit 26 Wrap flag for FBR0
+ */
+
+/* RXSTAT_WORD1_t structure holds part of the status bits of the Rx DM=
A engine
+ * that get copied out to memory by the ET-1310.  Word 3 is a 32 bit w=
ord
+ * which contains the Packet Status Ring available offset.
+ *
+ * bit 0-15 reserved
+ * bit 16-27 PSRoffset
+ * bit 28 PSRwrap
+ * bit 29-31 unused
+ */
+
+/* struct rx_status_block is a structure representing the status of th=
e Rx
+ * DMA engine it sits in free memory, and is pointed to by 0x101c / 0x=
1020
+ */
+struct rx_status_block {
+	u32 word0;
+	u32 word1;
+};
+
+/* Structure for look-up table holding free buffer ring pointers, addr=
esses
+ * and state.
+ */
+struct fbr_lookup {
+	void		*virt[MAX_DESC_PER_RING_RX];
+	u32		 bus_high[MAX_DESC_PER_RING_RX];
+	u32		 bus_low[MAX_DESC_PER_RING_RX];
+	void		*ring_virtaddr;
+	dma_addr_t	 ring_physaddr;
+	void		*mem_virtaddrs[MAX_DESC_PER_RING_RX / FBR_CHUNKS];
+	dma_addr_t	 mem_physaddrs[MAX_DESC_PER_RING_RX / FBR_CHUNKS];
+	u32		 local_full;
+	u32		 num_entries;
+	dma_addr_t	 buffsize;
+};
+
+/* struct rx_ring is the sructure representing the adaptor's local
+ * reference(s) to the rings
+ */
+struct rx_ring {
+	struct fbr_lookup *fbr[NUM_FBRS];
+	void *ps_ring_virtaddr;
+	dma_addr_t ps_ring_physaddr;
+	u32 local_psr_full;
+	u32 psr_num_entries;
+
+	struct rx_status_block *rx_status_block;
+	dma_addr_t rx_status_bus;
+
+	/* RECV */
+	struct list_head recv_list;
+	u32 num_ready_recv;
+
+	u32 num_rfd;
+
+	bool unfinished_receives;
+};
+
+/* TX defines */
+/* word 2 of the control bits in the Tx Descriptor ring for the ET-131=
0
+ *
+ * 0-15: length of packet
+ * 16-27: VLAN tag
+ * 28: VLAN CFI
+ * 29-31: VLAN priority
+ *
+ * word 3 of the control bits in the Tx Descriptor ring for the ET-131=
0
+ *
+ * 0: last packet in the sequence
+ * 1: first packet in the sequence
+ * 2: interrupt the processor when this pkt sent
+ * 3: Control word - no packet data
+ * 4: Issue half-duplex backpressure : XON/XOFF
+ * 5: send pause frame
+ * 6: Tx frame has error
+ * 7: append CRC
+ * 8: MAC override
+ * 9: pad packet
+ * 10: Packet is a Huge packet
+ * 11: append VLAN tag
+ * 12: IP checksum assist
+ * 13: TCP checksum assist
+ * 14: UDP checksum assist
+ */
+
+#define TXDESC_FLAG_LASTPKT		0x0001
+#define TXDESC_FLAG_FIRSTPKT		0x0002
+#define TXDESC_FLAG_INTPROC		0x0004
+
+/* struct tx_desc represents each descriptor on the ring */
+struct tx_desc {
+	u32 addr_hi;
+	u32 addr_lo;
+	u32 len_vlan;	/* control words how to xmit the */
+	u32 flags;	/* data (detailed above) */
+};
+
+/* The status of the Tx DMA engine it sits in free memory, and is poin=
ted to
+ * by 0x101c / 0x1020. This is a DMA10 type
+ */
+
+/* TCB (Transmit Control Block: Host Side) */
+struct tcb {
+	struct tcb *next;	/* Next entry in ring */
+	u32 flags;		/* Our flags for the packet */
+	u32 count;		/* Used to spot stuck/lost packets */
+	u32 stale;		/* Used to spot stuck/lost packets */
+	struct sk_buff *skb;	/* Network skb we are tied to */
+	u32 index;		/* Ring indexes */
+	u32 index_start;
+};
+
+/* Structure representing our local reference(s) to the ring */
+struct tx_ring {
+	/* TCB (Transmit Control Block) memory and lists */
+	struct tcb *tcb_ring;
+
+	/* List of TCBs that are ready to be used */
+	struct tcb *tcb_qhead;
+	struct tcb *tcb_qtail;
+
+	/* list of TCBs that are currently being sent.  NOTE that access to a=
ll
+	 * three of these (including used) are controlled via the
+	 * TCBSendQLock.  This lock should be secured prior to incementing /
+	 * decrementing used, or any queue manipulation on send_head /
+	 * tail
+	 */
+	struct tcb *send_head;
+	struct tcb *send_tail;
+	int used;
+
+	/* The actual descriptor ring */
+	struct tx_desc *tx_desc_ring;
+	dma_addr_t tx_desc_ring_pa;
+
+	/* send_idx indicates where we last wrote to in the descriptor ring. =
*/
+	u32 send_idx;
+
+	/* The location of the write-back status block */
+	u32 *tx_status;
+	dma_addr_t tx_status_pa;
+
+	/* Packets since the last IRQ: used for interrupt coalescing */
+	int since_irq;
+};
+
+/* Do not change these values: if changed, then change also in respect=
ive
+ * TXdma and Rxdma engines
+ */
+#define NUM_DESC_PER_RING_TX         512    /* TX Do not change these =
values */
+#define NUM_TCB                      64
+
+/* These values are all superseded by registry entries to facilitate t=
uning.
+ * Once the desired performance has been achieved, the optimal registr=
y values
+ * should be re-populated to these #defines:
+ */
+#define TX_ERROR_PERIOD             1000
+
+#define LO_MARK_PERCENT_FOR_PSR     15
+#define LO_MARK_PERCENT_FOR_RX      15
+
+/* RFD (Receive Frame Descriptor) */
+struct rfd {
+	struct list_head list_node;
+	struct sk_buff *skb;
+	u32 len;	/* total size of receive frame */
+	u16 bufferindex;
+	u8 ringindex;
+};
+
+/* Flow Control */
+#define FLOW_BOTH	0
+#define FLOW_TXONLY	1
+#define FLOW_RXONLY	2
+#define FLOW_NONE	3
+
+/* Struct to define some device statistics */
+struct ce_stats {
+	/* MIB II variables
+	 *
+	 * NOTE: atomic_t types are only guaranteed to store 24-bits; if we
+	 * MUST have 32, then we'll need another way to perform atomic
+	 * operations
+	 */
+	u32		unicast_pkts_rcvd;
+	atomic_t	unicast_pkts_xmtd;
+	u32		multicast_pkts_rcvd;
+	atomic_t	multicast_pkts_xmtd;
+	u32		broadcast_pkts_rcvd;
+	atomic_t	broadcast_pkts_xmtd;
+	u32		rcvd_pkts_dropped;
+
+	/* Tx Statistics. */
+	u32		tx_underflows;
+
+	u32		tx_collisions;
+	u32		tx_excessive_collisions;
+	u32		tx_first_collisions;
+	u32		tx_late_collisions;
+	u32		tx_max_pkt_errs;
+	u32		tx_deferred;
+
+	/* Rx Statistics. */
+	u32		rx_overflows;
+
+	u32		rx_length_errs;
+	u32		rx_align_errs;
+	u32		rx_crc_errs;
+	u32		rx_code_violations;
+	u32		rx_other_errs;
+
+	u32		synchronous_iterations;
+	u32		interrupt_status;
+};
+
+/* The private adapter structure */
+struct et131x_adapter {
+	struct net_device *netdev;
+	struct pci_dev *pdev;
+	struct mii_bus *mii_bus;
+	struct phy_device *phydev;
+	struct work_struct task;
+
+	/* Flags that indicate current state of the adapter */
+	u32 flags;
+
+	/* local link state, to determine if a state change has occurred */
+	int link;
+
+	/* Configuration  */
+	u8 rom_addr[ETH_ALEN];
+	u8 addr[ETH_ALEN];
+	bool has_eeprom;
+	u8 eeprom_data[2];
+
+	/* Spinlocks */
+	spinlock_t lock;
+
+	spinlock_t tcb_send_qlock;
+	spinlock_t tcb_ready_qlock;
+	spinlock_t send_hw_lock;
+
+	spinlock_t rcv_lock;
+	spinlock_t rcv_pend_lock;
+	spinlock_t fbr_lock;
+
+	spinlock_t phy_lock;
+
+	/* Packet Filter and look ahead size */
+	u32 packet_filter;
+
+	/* multicast list */
+	u32 multicast_addr_count;
+	u8 multicast_list[NIC_MAX_MCAST_LIST][ETH_ALEN];
+
+	/* Pointer to the device's PCI register space */
+	struct address_map __iomem *regs;
+
+	/* Registry parameters */
+	u8 wanted_flow;		/* Flow we want for 802.3x flow control */
+	u32 registry_jumbo_packet;	/* Max supported ethernet packet size */
+
+	/* Derived from the registry: */
+	u8 flowcontrol;		/* flow control validated by the far-end */
+
+	/* Minimize init-time */
+	struct timer_list error_timer;
+
+	/* variable putting the phy into coma mode when boot up with no cable
+	 * plugged in after 5 seconds
+	 */
+	u8 boot_coma;
+
+	/* Next two used to save power information at power down. This
+	 * information will be used during power up to set up parts of Power
+	 * Management in JAGCore
+	 */
+	u16 pdown_speed;
+	u8 pdown_duplex;
+
+	/* Tx Memory Variables */
+	struct tx_ring tx_ring;
+
+	/* Rx Memory Variables */
+	struct rx_ring rx_ring;
+
+	/* Stats */
+	struct ce_stats stats;
+
+	struct net_device_stats net_stats;
+};
+
+static int eeprom_wait_ready(struct pci_dev *pdev, u32 *status)
+{
+	u32 reg;
+	int i;
+
+	/* 1. Check LBCIF Status Register for bits 6 & 3:2 all equal to 0 and
+	 *    bits 7,1:0 both equal to 1, at least once after reset.
+	 *    Subsequent operations need only to check that bits 1:0 are equa=
l
+	 *    to 1 prior to starting a single byte read/write
+	 */
+
+	for (i =3D 0; i < MAX_NUM_REGISTER_POLLS; i++) {
+		/* Read registers grouped in DWORD1 */
+		if (pci_read_config_dword(pdev, LBCIF_DWORD1_GROUP, &reg))
+			return -EIO;
+
+		/* I2C idle and Phy Queue Avail both true */
+		if ((reg & 0x3000) =3D=3D 0x3000) {
+			if (status)
+				*status =3D reg;
+			return reg & 0xFF;
+		}
+	}
+	return -ETIMEDOUT;
+}
+
+/* eeprom_write - Write a byte to the ET1310's EEPROM
+ * @adapter: pointer to our private adapter structure
+ * @addr: the address to write
+ * @data: the value to write
+ *
+ * Returns 1 for a successful write.
+ */
+static int eeprom_write(struct et131x_adapter *adapter, u32 addr, u8 d=
ata)
+{
+	struct pci_dev *pdev =3D adapter->pdev;
+	int index =3D 0;
+	int retries;
+	int err =3D 0;
+	int i2c_wack =3D 0;
+	int writeok =3D 0;
+	u32 status;
+	u32 val =3D 0;
+
+	/* For an EEPROM, an I2C single byte write is defined as a START
+	 * condition followed by the device address, EEPROM address, one byte
+	 * of data and a STOP condition.  The STOP condition will trigger the
+	 * EEPROM's internally timed write cycle to the nonvolatile memory.
+	 * All inputs are disabled during this write cycle and the EEPROM wil=
l
+	 * not respond to any access until the internal write is complete.
+	 */
+
+	err =3D eeprom_wait_ready(pdev, NULL);
+	if (err)
+		return err;
+
+	 /* 2. Write to the LBCIF Control Register:  bit 7=3D1, bit 6=3D1, bi=
t 3=3D0,
+	  *    and bits 1:0 both =3D0.  Bit 5 should be set according to the
+	  *    type of EEPROM being accessed (1=3Dtwo byte addressing, 0=3Don=
e
+	  *    byte addressing).
+	  */
+	if (pci_write_config_byte(pdev, LBCIF_CONTROL_REGISTER,
+			LBCIF_CONTROL_LBCIF_ENABLE | LBCIF_CONTROL_I2C_WRITE))
+		return -EIO;
+
+	i2c_wack =3D 1;
+
+	/* Prepare EEPROM address for Step 3 */
+
+	for (retries =3D 0; retries < MAX_NUM_WRITE_RETRIES; retries++) {
+		/* Write the address to the LBCIF Address Register */
+		if (pci_write_config_dword(pdev, LBCIF_ADDRESS_REGISTER, addr))
+			break;
+		/* Write the data to the LBCIF Data Register (the I2C write
+		 * will begin).
+		 */
+		if (pci_write_config_byte(pdev, LBCIF_DATA_REGISTER, data))
+			break;
+		/* Monitor bit 1:0 of the LBCIF Status Register.  When bits
+		 * 1:0 are both equal to 1, the I2C write has completed and the
+		 * internal write cycle of the EEPROM is about to start.
+		 * (bits 1:0 =3D 01 is a legal state while waiting from both
+		 * equal to 1, but bits 1:0 =3D 10 is invalid and implies that
+		 * something is broken).
+		 */
+		err =3D eeprom_wait_ready(pdev, &status);
+		if (err < 0)
+			return 0;
+
+		/* Check bit 3 of the LBCIF Status Register.  If  equal to 1,
+		 * an error has occurred.Don't break here if we are revision
+		 * 1, this is so we do a blind write for load bug.
+		 */
+		if ((status & LBCIF_STATUS_GENERAL_ERROR)
+			&& adapter->pdev->revision =3D=3D 0)
+			break;
+
+		/* Check bit 2 of the LBCIF Status Register.  If equal to 1 an
+		 * ACK error has occurred on the address phase of the write.
+		 * This could be due to an actual hardware failure or the
+		 * EEPROM may still be in its internal write cycle from a
+		 * previous write. This write operation was ignored and must be
+		  *repeated later.
+		 */
+		if (status & LBCIF_STATUS_ACK_ERROR) {
+			/* This could be due to an actual hardware failure
+			 * or the EEPROM may still be in its internal write
+			 * cycle from a previous write. This write operation
+			 * was ignored and must be repeated later.
+			 */
+			udelay(10);
+			continue;
+		}
+
+		writeok =3D 1;
+		break;
+	}
+
+	/* Set bit 6 of the LBCIF Control Register =3D 0.
+	 */
+	udelay(10);
+
+	while (i2c_wack) {
+		if (pci_write_config_byte(pdev, LBCIF_CONTROL_REGISTER,
+			LBCIF_CONTROL_LBCIF_ENABLE))
+			writeok =3D 0;
+
+		/* Do read until internal ACK_ERROR goes away meaning write
+		 * completed
+		 */
+		do {
+			pci_write_config_dword(pdev,
+					       LBCIF_ADDRESS_REGISTER,
+					       addr);
+			do {
+				pci_read_config_dword(pdev,
+					LBCIF_DATA_REGISTER, &val);
+			} while ((val & 0x00010000) =3D=3D 0);
+		} while (val & 0x00040000);
+
+		if ((val & 0xFF00) !=3D 0xC000 || index =3D=3D 10000)
+			break;
+		index++;
+	}
+	return writeok ? 0 : -EIO;
+}
+
+/* eeprom_read - Read a byte from the ET1310's EEPROM
+ * @adapter: pointer to our private adapter structure
+ * @addr: the address from which to read
+ * @pdata: a pointer to a byte in which to store the value of the read
+ * @eeprom_id: the ID of the EEPROM
+ * @addrmode: how the EEPROM is to be accessed
+ *
+ * Returns 1 for a successful read
+ */
+static int eeprom_read(struct et131x_adapter *adapter, u32 addr, u8 *p=
data)
+{
+	struct pci_dev *pdev =3D adapter->pdev;
+	int err;
+	u32 status;
+
+	/* A single byte read is similar to the single byte write, with the
+	 * exception of the data flow:
+	 */
+
+	err =3D eeprom_wait_ready(pdev, NULL);
+	if (err)
+		return err;
+	/* Write to the LBCIF Control Register:  bit 7=3D1, bit 6=3D0, bit 3=3D=
0,
+	 * and bits 1:0 both =3D0.  Bit 5 should be set according to the type
+	 * of EEPROM being accessed (1=3Dtwo byte addressing, 0=3Done byte
+	 * addressing).
+	 */
+	if (pci_write_config_byte(pdev, LBCIF_CONTROL_REGISTER,
+				  LBCIF_CONTROL_LBCIF_ENABLE))
+		return -EIO;
+	/* Write the address to the LBCIF Address Register (I2C read will
+	 * begin).
+	 */
+	if (pci_write_config_dword(pdev, LBCIF_ADDRESS_REGISTER, addr))
+		return -EIO;
+	/* Monitor bit 0 of the LBCIF Status Register.  When =3D 1, I2C read
+	 * is complete. (if bit 1 =3D1 and bit 0 stays =3D 0, a hardware fail=
ure
+	 * has occurred).
+	 */
+	err =3D eeprom_wait_ready(pdev, &status);
+	if (err < 0)
+		return err;
+	/* Regardless of error status, read data byte from LBCIF Data
+	 * Register.
+	 */
+	*pdata =3D err;
+	/* Check bit 2 of the LBCIF Status Register.  If =3D 1,
+	 * then an error has occurred.
+	 */
+	return (status & LBCIF_STATUS_ACK_ERROR) ? -EIO : 0;
+}
+
+static int et131x_init_eeprom(struct et131x_adapter *adapter)
+{
+	struct pci_dev *pdev =3D adapter->pdev;
+	u8 eestatus;
+
+	/* We first need to check the EEPROM Status code located at offset
+	 * 0xB2 of config space
+	 */
+	pci_read_config_byte(pdev, ET1310_PCI_EEPROM_STATUS, &eestatus);
+
+	/* THIS IS A WORKAROUND:
+	 * I need to call this function twice to get my card in a
+	 * LG M1 Express Dual running. I tried also a msleep before this
+	 * function, because I thought there could be some time conditions
+	 * but it didn't work. Call the whole function twice also work.
+	 */
+	if (pci_read_config_byte(pdev, ET1310_PCI_EEPROM_STATUS, &eestatus)) =
{
+		dev_err(&pdev->dev,
+		       "Could not read PCI config space for EEPROM Status\n");
+		return -EIO;
+	}
+
+	/* Determine if the error(s) we care about are present. If they are
+	 * present we need to fail.
+	 */
+	if (eestatus & 0x4C) {
+		int write_failed =3D 0;
+		if (pdev->revision =3D=3D 0x01) {
+			int	i;
+			static const u8 eedata[4] =3D { 0xFE, 0x13, 0x10, 0xFF };
+
+			/* Re-write the first 4 bytes if we have an eeprom
+			 * present and the revision id is 1, this fixes the
+			 * corruption seen with 1310 B Silicon
+			 */
+			for (i =3D 0; i < 3; i++)
+				if (eeprom_write(adapter, i, eedata[i]) < 0)
+					write_failed =3D 1;
+		}
+		if (pdev->revision  !=3D 0x01 || write_failed) {
+			dev_err(&pdev->dev,
+			    "Fatal EEPROM Status Error - 0x%04x\n", eestatus);
+
+			/* This error could mean that there was an error
+			 * reading the eeprom or that the eeprom doesn't exist.
+			 * We will treat each case the same and not try to
+			 * gather additional information that normally would
+			 * come from the eeprom, like MAC Address
+			 */
+			adapter->has_eeprom =3D 0;
+			return -EIO;
+		}
+	}
+	adapter->has_eeprom =3D 1;
+
+	/* Read the EEPROM for information regarding LED behavior. Refer to
+	 * ET1310_phy.c, et131x_xcvr_init(), for its use.
+	 */
+	eeprom_read(adapter, 0x70, &adapter->eeprom_data[0]);
+	eeprom_read(adapter, 0x71, &adapter->eeprom_data[1]);
+
+	if (adapter->eeprom_data[0] !=3D 0xcd)
+		/* Disable all optional features */
+		adapter->eeprom_data[1] =3D 0x00;
+
+	return 0;
+}
+
+/* et131x_rx_dma_enable - re-start of Rx_DMA on the ET1310.
+ * @adapter: pointer to our adapter structure
+ */
+static void et131x_rx_dma_enable(struct et131x_adapter *adapter)
+{
+	/* Setup the receive dma configuration register for normal operation =
*/
+	u32 csr =3D  ET_RXDMA_CSR_FBR1_ENABLE;
+
+	if (adapter->rx_ring.fbr[1]->buffsize =3D=3D 4096)
+		csr |=3D ET_RXDMA_CSR_FBR1_SIZE_LO;
+	else if (adapter->rx_ring.fbr[1]->buffsize =3D=3D 8192)
+		csr |=3D ET_RXDMA_CSR_FBR1_SIZE_HI;
+	else if (adapter->rx_ring.fbr[1]->buffsize =3D=3D 16384)
+		csr |=3D ET_RXDMA_CSR_FBR1_SIZE_LO | ET_RXDMA_CSR_FBR1_SIZE_HI;
+
+	csr |=3D ET_RXDMA_CSR_FBR0_ENABLE;
+	if (adapter->rx_ring.fbr[0]->buffsize =3D=3D 256)
+		csr |=3D ET_RXDMA_CSR_FBR0_SIZE_LO;
+	else if (adapter->rx_ring.fbr[0]->buffsize =3D=3D 512)
+		csr |=3D ET_RXDMA_CSR_FBR0_SIZE_HI;
+	else if (adapter->rx_ring.fbr[0]->buffsize =3D=3D 1024)
+		csr |=3D ET_RXDMA_CSR_FBR0_SIZE_LO | ET_RXDMA_CSR_FBR0_SIZE_HI;
+	writel(csr, &adapter->regs->rxdma.csr);
+
+	csr =3D readl(&adapter->regs->rxdma.csr);
+	if (csr & ET_RXDMA_CSR_HALT_STATUS) {
+		udelay(5);
+		csr =3D readl(&adapter->regs->rxdma.csr);
+		if (csr & ET_RXDMA_CSR_HALT_STATUS) {
+			dev_err(&adapter->pdev->dev,
+			    "RX Dma failed to exit halt state.  CSR 0x%08x\n",
+				csr);
+		}
+	}
+}
+
+/* et131x_rx_dma_disable - Stop of Rx_DMA on the ET1310
+ * @adapter: pointer to our adapter structure
+ */
+static void et131x_rx_dma_disable(struct et131x_adapter *adapter)
+{
+	u32 csr;
+	/* Setup the receive dma configuration register */
+	writel(ET_RXDMA_CSR_HALT | ET_RXDMA_CSR_FBR1_ENABLE,
+	       &adapter->regs->rxdma.csr);
+	csr =3D readl(&adapter->regs->rxdma.csr);
+	if (!(csr & ET_RXDMA_CSR_HALT_STATUS)) {
+		udelay(5);
+		csr =3D readl(&adapter->regs->rxdma.csr);
+		if (!(csr & ET_RXDMA_CSR_HALT_STATUS))
+			dev_err(&adapter->pdev->dev,
+			      "RX Dma failed to enter halt state. CSR 0x%08x\n",
+			      csr);
+	}
+}
+
+/* et131x_tx_dma_enable - re-start of Tx_DMA on the ET1310.
+ * @adapter: pointer to our adapter structure
+ *
+ * Mainly used after a return to the D0 (full-power) state from a lowe=
r state.
+ */
+static void et131x_tx_dma_enable(struct et131x_adapter *adapter)
+{
+	/* Setup the transmit dma configuration register for normal
+	 * operation
+	 */
+	writel(ET_TXDMA_SNGL_EPKT|(PARM_DMA_CACHE_DEF << ET_TXDMA_CACHE_SHIFT=
),
+					&adapter->regs->txdma.csr);
+}
+
+static inline void add_10bit(u32 *v, int n)
+{
+	*v =3D INDEX10(*v + n) | (*v & ET_DMA10_WRAP);
+}
+
+static inline void add_12bit(u32 *v, int n)
+{
+	*v =3D INDEX12(*v + n) | (*v & ET_DMA12_WRAP);
+}
+
+/* et1310_config_mac_regs1 - Initialize the first part of MAC regs
+ * @adapter: pointer to our adapter structure
+ */
+static void et1310_config_mac_regs1(struct et131x_adapter *adapter)
+{
+	struct mac_regs __iomem *macregs =3D &adapter->regs->mac;
+	u32 station1;
+	u32 station2;
+	u32 ipg;
+
+	/* First we need to reset everything.  Write to MAC configuration
+	 * register 1 to perform reset.
+	 */
+	writel(ET_MAC_CFG1_SOFT_RESET | ET_MAC_CFG1_SIM_RESET  |
+	       ET_MAC_CFG1_RESET_RXMC | ET_MAC_CFG1_RESET_TXMC |
+	       ET_MAC_CFG1_RESET_RXFUNC | ET_MAC_CFG1_RESET_TXFUNC,
+	       &macregs->cfg1);
+
+	/* Next lets configure the MAC Inter-packet gap register */
+	ipg =3D 0x38005860;		/* IPG1 0x38 IPG2 0x58 B2B 0x60 */
+	ipg |=3D 0x50 << 8;		/* ifg enforce 0x50 */
+	writel(ipg, &macregs->ipg);
+
+	/* Next lets configure the MAC Half Duplex register */
+	/* BEB trunc 0xA, Ex Defer, Rexmit 0xF Coll 0x37 */
+	writel(0x00A1F037, &macregs->hfdp);
+
+	/* Next lets configure the MAC Interface Control register */
+	writel(0, &macregs->if_ctrl);
+
+	/* Let's move on to setting up the mii management configuration */
+	writel(ET_MAC_MIIMGMT_CLK_RST, &macregs->mii_mgmt_cfg);
+
+	/* Next lets configure the MAC Station Address register.  These
+	 * values are read from the EEPROM during initialization and stored
+	 * in the adapter structure.  We write what is stored in the adapter
+	 * structure to the MAC Station Address registers high and low.  This
+	 * station address is used for generating and checking pause control
+	 * packets.
+	 */
+	station2 =3D (adapter->addr[1] << ET_MAC_STATION_ADDR2_OC2_SHIFT) |
+		   (adapter->addr[0] << ET_MAC_STATION_ADDR2_OC1_SHIFT);
+	station1 =3D (adapter->addr[5] << ET_MAC_STATION_ADDR1_OC6_SHIFT) |
+		   (adapter->addr[4] << ET_MAC_STATION_ADDR1_OC5_SHIFT) |
+		   (adapter->addr[3] << ET_MAC_STATION_ADDR1_OC4_SHIFT) |
+		    adapter->addr[2];
+	writel(station1, &macregs->station_addr_1);
+	writel(station2, &macregs->station_addr_2);
+
+	/* Max ethernet packet in bytes that will be passed by the mac withou=
t
+	 * being truncated.  Allow the MAC to pass 4 more than our max packet
+	 * size.  This is 4 for the Ethernet CRC.
+	 *
+	 * Packets larger than (registry_jumbo_packet) that do not contain a
+	 * VLAN ID will be dropped by the Rx function.
+	 */
+	writel(adapter->registry_jumbo_packet + 4, &macregs->max_fm_len);
+
+	/* clear out MAC config reset */
+	writel(0, &macregs->cfg1);
+}
+
+/* et1310_config_mac_regs2 - Initialize the second part of MAC regs
+ * @adapter: pointer to our adapter structure
+ */
+static void et1310_config_mac_regs2(struct et131x_adapter *adapter)
+{
+	int32_t delay =3D 0;
+	struct mac_regs __iomem *mac =3D &adapter->regs->mac;
+	struct phy_device *phydev =3D adapter->phydev;
+	u32 cfg1;
+	u32 cfg2;
+	u32 ifctrl;
+	u32 ctl;
+
+	ctl =3D readl(&adapter->regs->txmac.ctl);
+	cfg1 =3D readl(&mac->cfg1);
+	cfg2 =3D readl(&mac->cfg2);
+	ifctrl =3D readl(&mac->if_ctrl);
+
+	/* Set up the if mode bits */
+	cfg2 &=3D ~ET_MAC_CFG2_IFMODE_MASK;
+	if (phydev && phydev->speed =3D=3D SPEED_1000) {
+		cfg2 |=3D ET_MAC_CFG2_IFMODE_1000;
+		/* Phy mode bit */
+		ifctrl &=3D ~ET_MAC_IFCTRL_PHYMODE;
+	} else {
+		cfg2 |=3D ET_MAC_CFG2_IFMODE_100;
+		ifctrl |=3D ET_MAC_IFCTRL_PHYMODE;
+	}
+
+	/* We need to enable Rx/Tx */
+	cfg1 |=3D ET_MAC_CFG1_RX_ENABLE | ET_MAC_CFG1_TX_ENABLE |
+							ET_MAC_CFG1_TX_FLOW;
+	/* Initialize loop back to off */
+	cfg1 &=3D ~(ET_MAC_CFG1_LOOPBACK | ET_MAC_CFG1_RX_FLOW);
+	if (adapter->flowcontrol =3D=3D FLOW_RXONLY ||
+				adapter->flowcontrol =3D=3D FLOW_BOTH)
+		cfg1 |=3D ET_MAC_CFG1_RX_FLOW;
+	writel(cfg1, &mac->cfg1);
+
+	/* Now we need to initialize the MAC Configuration 2 register */
+	/* preamble 7, check length, huge frame off, pad crc, crc enable
+	 * full duplex off
+	 */
+	cfg2 |=3D 0x7 << ET_MAC_CFG2_PREAMBLE_SHIFT;
+	cfg2 |=3D ET_MAC_CFG2_IFMODE_LEN_CHECK;
+	cfg2 |=3D ET_MAC_CFG2_IFMODE_PAD_CRC;
+	cfg2 |=3D	ET_MAC_CFG2_IFMODE_CRC_ENABLE;
+	cfg2 &=3D ~ET_MAC_CFG2_IFMODE_HUGE_FRAME;
+	cfg2 &=3D ~ET_MAC_CFG2_IFMODE_FULL_DPLX;
+
+	/* Turn on duplex if needed */
+	if (phydev && phydev->duplex =3D=3D DUPLEX_FULL)
+		cfg2 |=3D ET_MAC_CFG2_IFMODE_FULL_DPLX;
+
+	ifctrl &=3D ~ET_MAC_IFCTRL_GHDMODE;
+	if (phydev && phydev->duplex =3D=3D DUPLEX_HALF)
+		ifctrl |=3D ET_MAC_IFCTRL_GHDMODE;
+
+	writel(ifctrl, &mac->if_ctrl);
+	writel(cfg2, &mac->cfg2);
+
+	do {
+		udelay(10);
+		delay++;
+		cfg1 =3D readl(&mac->cfg1);
+	} while ((cfg1 & ET_MAC_CFG1_WAIT) !=3D ET_MAC_CFG1_WAIT && delay < 1=
00);
+
+	if (delay =3D=3D 100) {
+		dev_warn(&adapter->pdev->dev,
+		    "Syncd bits did not respond correctly cfg1 word 0x%08x\n",
+			cfg1);
+	}
+
+	/* Enable txmac */
+	ctl |=3D ET_TX_CTRL_TXMAC_ENABLE | ET_TX_CTRL_FC_DISABLE;
+	writel(ctl, &adapter->regs->txmac.ctl);
+
+	/* Ready to start the RXDMA/TXDMA engine */
+	if (adapter->flags & FMP_ADAPTER_LOWER_POWER) {
+		et131x_rx_dma_enable(adapter);
+		et131x_tx_dma_enable(adapter);
+	}
+}
+
+/* et1310_in_phy_coma - check if the device is in phy coma
+ * @adapter: pointer to our adapter structure
+ *
+ * Returns 0 if the device is not in phy coma, 1 if it is in phy coma
+ */
+static int et1310_in_phy_coma(struct et131x_adapter *adapter)
+{
+	u32 pmcsr;
+
+	pmcsr =3D readl(&adapter->regs->global.pm_csr);
+
+	return ET_PM_PHY_SW_COMA & pmcsr ? 1 : 0;
+}
+
+static void et1310_setup_device_for_multicast(struct et131x_adapter *a=
dapter)
+{
+	struct rxmac_regs __iomem *rxmac =3D &adapter->regs->rxmac;
+	u32 hash1 =3D 0;
+	u32 hash2 =3D 0;
+	u32 hash3 =3D 0;
+	u32 hash4 =3D 0;
+	u32 pm_csr;
+
+	/* If ET131X_PACKET_TYPE_MULTICAST is specified, then we provision
+	 * the multi-cast LIST.  If it is NOT specified, (and "ALL" is not
+	 * specified) then we should pass NO multi-cast addresses to the
+	 * driver.
+	 */
+	if (adapter->packet_filter & ET131X_PACKET_TYPE_MULTICAST) {
+		int i;
+
+		/* Loop through our multicast array and set up the device */
+		for (i =3D 0; i < adapter->multicast_addr_count; i++) {
+			u32 result;
+
+			result =3D ether_crc(6, adapter->multicast_list[i]);
+
+			result =3D (result & 0x3F800000) >> 23;
+
+			if (result < 32) {
+				hash1 |=3D (1 << result);
+			} else if ((31 < result) && (result < 64)) {
+				result -=3D 32;
+				hash2 |=3D (1 << result);
+			} else if ((63 < result) && (result < 96)) {
+				result -=3D 64;
+				hash3 |=3D (1 << result);
+			} else {
+				result -=3D 96;
+				hash4 |=3D (1 << result);
+			}
+		}
+	}
+
+	/* Write out the new hash to the device */
+	pm_csr =3D readl(&adapter->regs->global.pm_csr);
+	if (!et1310_in_phy_coma(adapter)) {
+		writel(hash1, &rxmac->multi_hash1);
+		writel(hash2, &rxmac->multi_hash2);
+		writel(hash3, &rxmac->multi_hash3);
+		writel(hash4, &rxmac->multi_hash4);
+	}
+}
+
+static void et1310_setup_device_for_unicast(struct et131x_adapter *ada=
pter)
+{
+	struct rxmac_regs __iomem *rxmac =3D &adapter->regs->rxmac;
+	u32 uni_pf1;
+	u32 uni_pf2;
+	u32 uni_pf3;
+	u32 pm_csr;
+
+	/* Set up unicast packet filter reg 3 to be the first two octets of
+	 * the MAC address for both address
+	 *
+	 * Set up unicast packet filter reg 2 to be the octets 2 - 5 of the
+	 * MAC address for second address
+	 *
+	 * Set up unicast packet filter reg 3 to be the octets 2 - 5 of the
+	 * MAC address for first address
+	 */
+	uni_pf3 =3D (adapter->addr[0] << ET_RX_UNI_PF_ADDR2_1_SHIFT) |
+		  (adapter->addr[1] << ET_RX_UNI_PF_ADDR2_2_SHIFT) |
+		  (adapter->addr[0] << ET_RX_UNI_PF_ADDR1_1_SHIFT) |
+		   adapter->addr[1];
+
+	uni_pf2 =3D (adapter->addr[2] << ET_RX_UNI_PF_ADDR2_3_SHIFT) |
+		  (adapter->addr[3] << ET_RX_UNI_PF_ADDR2_4_SHIFT) |
+		  (adapter->addr[4] << ET_RX_UNI_PF_ADDR2_5_SHIFT) |
+		   adapter->addr[5];
+
+	uni_pf1 =3D (adapter->addr[2] << ET_RX_UNI_PF_ADDR1_3_SHIFT) |
+		  (adapter->addr[3] << ET_RX_UNI_PF_ADDR1_4_SHIFT) |
+		  (adapter->addr[4] << ET_RX_UNI_PF_ADDR1_5_SHIFT) |
+		   adapter->addr[5];
+
+	pm_csr =3D readl(&adapter->regs->global.pm_csr);
+	if (!et1310_in_phy_coma(adapter)) {
+		writel(uni_pf1, &rxmac->uni_pf_addr1);
+		writel(uni_pf2, &rxmac->uni_pf_addr2);
+		writel(uni_pf3, &rxmac->uni_pf_addr3);
+	}
+}
+
+static void et1310_config_rxmac_regs(struct et131x_adapter *adapter)
+{
+	struct rxmac_regs __iomem *rxmac =3D &adapter->regs->rxmac;
+	struct phy_device *phydev =3D adapter->phydev;
+	u32 sa_lo;
+	u32 sa_hi =3D 0;
+	u32 pf_ctrl =3D 0;
+
+	/* Disable the MAC while it is being configured (also disable WOL) */
+	writel(0x8, &rxmac->ctrl);
+
+	/* Initialize WOL to disabled. */
+	writel(0, &rxmac->crc0);
+	writel(0, &rxmac->crc12);
+	writel(0, &rxmac->crc34);
+
+	/* We need to set the WOL mask0 - mask4 next.  We initialize it to
+	 * its default Values of 0x00000000 because there are not WOL masks
+	 * as of this time.
+	 */
+	writel(0, &rxmac->mask0_word0);
+	writel(0, &rxmac->mask0_word1);
+	writel(0, &rxmac->mask0_word2);
+	writel(0, &rxmac->mask0_word3);
+
+	writel(0, &rxmac->mask1_word0);
+	writel(0, &rxmac->mask1_word1);
+	writel(0, &rxmac->mask1_word2);
+	writel(0, &rxmac->mask1_word3);
+
+	writel(0, &rxmac->mask2_word0);
+	writel(0, &rxmac->mask2_word1);
+	writel(0, &rxmac->mask2_word2);
+	writel(0, &rxmac->mask2_word3);
+
+	writel(0, &rxmac->mask3_word0);
+	writel(0, &rxmac->mask3_word1);
+	writel(0, &rxmac->mask3_word2);
+	writel(0, &rxmac->mask3_word3);
+
+	writel(0, &rxmac->mask4_word0);
+	writel(0, &rxmac->mask4_word1);
+	writel(0, &rxmac->mask4_word2);
+	writel(0, &rxmac->mask4_word3);
+
+	/* Lets setup the WOL Source Address */
+	sa_lo =3D (adapter->addr[2] << ET_RX_WOL_LO_SA3_SHIFT) |
+		(adapter->addr[3] << ET_RX_WOL_LO_SA4_SHIFT) |
+		(adapter->addr[4] << ET_RX_WOL_LO_SA5_SHIFT) |
+		 adapter->addr[5];
+	writel(sa_lo, &rxmac->sa_lo);
+
+	sa_hi =3D (u32) (adapter->addr[0] << ET_RX_WOL_HI_SA1_SHIFT) |
+		       adapter->addr[1];
+	writel(sa_hi, &rxmac->sa_hi);
+
+	/* Disable all Packet Filtering */
+	writel(0, &rxmac->pf_ctrl);
+
+	/* Let's initialize the Unicast Packet filtering address */
+	if (adapter->packet_filter & ET131X_PACKET_TYPE_DIRECTED) {
+		et1310_setup_device_for_unicast(adapter);
+		pf_ctrl |=3D ET_RX_PFCTRL_UNICST_FILTER_ENABLE;
+	} else {
+		writel(0, &rxmac->uni_pf_addr1);
+		writel(0, &rxmac->uni_pf_addr2);
+		writel(0, &rxmac->uni_pf_addr3);
+	}
+
+	/* Let's initialize the Multicast hash */
+	if (!(adapter->packet_filter & ET131X_PACKET_TYPE_ALL_MULTICAST)) {
+		pf_ctrl |=3D ET_RX_PFCTRL_MLTCST_FILTER_ENABLE;
+		et1310_setup_device_for_multicast(adapter);
+	}
+
+	/* Runt packet filtering.  Didn't work in version A silicon. */
+	pf_ctrl |=3D (NIC_MIN_PACKET_SIZE + 4) << ET_RX_PFCTRL_MIN_PKT_SZ_SHI=
=46T;
+	pf_ctrl |=3D ET_RX_PFCTRL_FRAG_FILTER_ENABLE;
+
+	if (adapter->registry_jumbo_packet > 8192)
+		/* In order to transmit jumbo packets greater than 8k, the
+		 * FIFO between RxMAC and RxDMA needs to be reduced in size
+		 * to (16k - Jumbo packet size).  In order to implement this,
+		 * we must use "cut through" mode in the RxMAC, which chops
+		 * packets down into segments which are (max_size * 16).  In
+		 * this case we selected 256 bytes, since this is the size of
+		 * the PCI-Express TLP's that the 1310 uses.
+		 *
+		 * seg_en on, fc_en off, size 0x10
+		 */
+		writel(0x41, &rxmac->mcif_ctrl_max_seg);
+	else
+		writel(0, &rxmac->mcif_ctrl_max_seg);
+
+	/* Initialize the MCIF water marks */
+	writel(0, &rxmac->mcif_water_mark);
+
+	/*  Initialize the MIF control */
+	writel(0, &rxmac->mif_ctrl);
+
+	/* Initialize the Space Available Register */
+	writel(0, &rxmac->space_avail);
+
+	/* Initialize the the mif_ctrl register
+	 * bit 3:  Receive code error. One or more nibbles were signaled as
+	 *	   errors  during the reception of the packet.  Clear this
+	 *	   bit in Gigabit, set it in 100Mbit.  This was derived
+	 *	   experimentally at UNH.
+	 * bit 4:  Receive CRC error. The packet's CRC did not match the
+	 *	   internally generated CRC.
+	 * bit 5:  Receive length check error. Indicates that frame length
+	 *	   field value in the packet does not match the actual data
+	 *	   byte length and is not a type field.
+	 * bit 16: Receive frame truncated.
+	 * bit 17: Drop packet enable
+	 */
+	if (phydev && phydev->speed =3D=3D SPEED_100)
+		writel(0x30038, &rxmac->mif_ctrl);
+	else
+		writel(0x30030, &rxmac->mif_ctrl);
+
+	/* Finally we initialize RxMac to be enabled & WOL disabled.  Packet
+	 * filter is always enabled since it is where the runt packets are
+	 * supposed to be dropped.  For version A silicon, runt packet
+	 * dropping doesn't work, so it is disabled in the pf_ctrl register,
+	 * but we still leave the packet filter on.
+	 */
+	writel(pf_ctrl, &rxmac->pf_ctrl);
+	writel(ET_RX_CTRL_RXMAC_ENABLE | ET_RX_CTRL_WOL_DISABLE, &rxmac->ctrl=
);
+}
+
+static void et1310_config_txmac_regs(struct et131x_adapter *adapter)
+{
+	struct txmac_regs __iomem *txmac =3D &adapter->regs->txmac;
+
+	/* We need to update the Control Frame Parameters
+	 * cfpt - control frame pause timer set to 64 (0x40)
+	 * cfep - control frame extended pause timer set to 0x0
+	 */
+	if (adapter->flowcontrol =3D=3D FLOW_NONE)
+		writel(0, &txmac->cf_param);
+	else
+		writel(0x40, &txmac->cf_param);
+}
+
+static void et1310_config_macstat_regs(struct et131x_adapter *adapter)
+{
+	struct macstat_regs __iomem *macstat =3D
+		&adapter->regs->macstat;
+
+	/* Next we need to initialize all the macstat registers to zero on
+	 * the device.
+	 */
+	writel(0, &macstat->txrx_0_64_byte_frames);
+	writel(0, &macstat->txrx_65_127_byte_frames);
+	writel(0, &macstat->txrx_128_255_byte_frames);
+	writel(0, &macstat->txrx_256_511_byte_frames);
+	writel(0, &macstat->txrx_512_1023_byte_frames);
+	writel(0, &macstat->txrx_1024_1518_byte_frames);
+	writel(0, &macstat->txrx_1519_1522_gvln_frames);
+
+	writel(0, &macstat->rx_bytes);
+	writel(0, &macstat->rx_packets);
+	writel(0, &macstat->rx_fcs_errs);
+	writel(0, &macstat->rx_multicast_packets);
+	writel(0, &macstat->rx_broadcast_packets);
+	writel(0, &macstat->rx_control_frames);
+	writel(0, &macstat->rx_pause_frames);
+	writel(0, &macstat->rx_unknown_opcodes);
+	writel(0, &macstat->rx_align_errs);
+	writel(0, &macstat->rx_frame_len_errs);
+	writel(0, &macstat->rx_code_errs);
+	writel(0, &macstat->rx_carrier_sense_errs);
+	writel(0, &macstat->rx_undersize_packets);
+	writel(0, &macstat->rx_oversize_packets);
+	writel(0, &macstat->rx_fragment_packets);
+	writel(0, &macstat->rx_jabbers);
+	writel(0, &macstat->rx_drops);
+
+	writel(0, &macstat->tx_bytes);
+	writel(0, &macstat->tx_packets);
+	writel(0, &macstat->tx_multicast_packets);
+	writel(0, &macstat->tx_broadcast_packets);
+	writel(0, &macstat->tx_pause_frames);
+	writel(0, &macstat->tx_deferred);
+	writel(0, &macstat->tx_excessive_deferred);
+	writel(0, &macstat->tx_single_collisions);
+	writel(0, &macstat->tx_multiple_collisions);
+	writel(0, &macstat->tx_late_collisions);
+	writel(0, &macstat->tx_excessive_collisions);
+	writel(0, &macstat->tx_total_collisions);
+	writel(0, &macstat->tx_pause_honored_frames);
+	writel(0, &macstat->tx_drops);
+	writel(0, &macstat->tx_jabbers);
+	writel(0, &macstat->tx_fcs_errs);
+	writel(0, &macstat->tx_control_frames);
+	writel(0, &macstat->tx_oversize_frames);
+	writel(0, &macstat->tx_undersize_frames);
+	writel(0, &macstat->tx_fragments);
+	writel(0, &macstat->carry_reg1);
+	writel(0, &macstat->carry_reg2);
+
+	/* Unmask any counters that we want to track the overflow of.
+	 * Initially this will be all counters.  It may become clear later
+	 * that we do not need to track all counters.
+	 */
+	writel(0xFFFFBE32, &macstat->carry_reg1_mask);
+	writel(0xFFFE7E8B, &macstat->carry_reg2_mask);
+}
+
+/* et131x_phy_mii_read - Read from the PHY through the MII Interface o=
n the MAC
+ * @adapter: pointer to our private adapter structure
+ * @addr: the address of the transceiver
+ * @reg: the register to read
+ * @value: pointer to a 16-bit value in which the value will be stored
+ *
+ * Returns 0 on success, errno on failure (as defined in errno.h)
+ */
+static int et131x_phy_mii_read(struct et131x_adapter *adapter, u8 addr=
,
+	      u8 reg, u16 *value)
+{
+	struct mac_regs __iomem *mac =3D &adapter->regs->mac;
+	int status =3D 0;
+	u32 delay =3D 0;
+	u32 mii_addr;
+	u32 mii_cmd;
+	u32 mii_indicator;
+
+	/* Save a local copy of the registers we are dealing with so we can
+	 * set them back
+	 */
+	mii_addr =3D readl(&mac->mii_mgmt_addr);
+	mii_cmd =3D readl(&mac->mii_mgmt_cmd);
+
+	/* Stop the current operation */
+	writel(0, &mac->mii_mgmt_cmd);
+
+	/* Set up the register we need to read from on the correct PHY */
+	writel(ET_MAC_MII_ADDR(addr, reg), &mac->mii_mgmt_addr);
+
+	writel(0x1, &mac->mii_mgmt_cmd);
+
+	do {
+		udelay(50);
+		delay++;
+		mii_indicator =3D readl(&mac->mii_mgmt_indicator);
+	} while ((mii_indicator & ET_MAC_MGMT_WAIT) && delay < 50);
+
+	/* If we hit the max delay, we could not read the register */
+	if (delay =3D=3D 50) {
+		dev_warn(&adapter->pdev->dev,
+			    "reg 0x%08x could not be read\n", reg);
+		dev_warn(&adapter->pdev->dev, "status is  0x%08x\n",
+			    mii_indicator);
+
+		status =3D -EIO;
+	}
+
+	/* If we hit here we were able to read the register and we need to
+	 * return the value to the caller
+	 */
+	*value =3D readl(&mac->mii_mgmt_stat) & ET_MAC_MIIMGMT_STAT_PHYCRTL_M=
ASK;
+
+	/* Stop the read operation */
+	writel(0, &mac->mii_mgmt_cmd);
+
+	/* set the registers we touched back to the state at which we entered
+	 * this function
+	 */
+	writel(mii_addr, &mac->mii_mgmt_addr);
+	writel(mii_cmd, &mac->mii_mgmt_cmd);
+
+	return status;
+}
+
+static int et131x_mii_read(struct et131x_adapter *adapter, u8 reg, u16=
 *value)
+{
+	struct phy_device *phydev =3D adapter->phydev;
+
+	if (!phydev)
+		return -EIO;
+
+	return et131x_phy_mii_read(adapter, phydev->addr, reg, value);
+}
+
+/* et131x_mii_write - Write to a PHY reg through the MII interface of =
the MAC
+ * @adapter: pointer to our private adapter structure
+ * @reg: the register to read
+ * @value: 16-bit value to write
+ *
+ * FIXME: one caller in netdev still
+ *
+ * Return 0 on success, errno on failure (as defined in errno.h)
+ */
+static int et131x_mii_write(struct et131x_adapter *adapter, u8 reg, u1=
6 value)
+{
+	struct mac_regs __iomem *mac =3D &adapter->regs->mac;
+	struct phy_device *phydev =3D adapter->phydev;
+	int status =3D 0;
+	u8 addr;
+	u32 delay =3D 0;
+	u32 mii_addr;
+	u32 mii_cmd;
+	u32 mii_indicator;
+
+	if (!phydev)
+		return -EIO;
+
+	addr =3D phydev->addr;
+
+	/* Save a local copy of the registers we are dealing with so we can
+	 * set them back
+	 */
+	mii_addr =3D readl(&mac->mii_mgmt_addr);
+	mii_cmd =3D readl(&mac->mii_mgmt_cmd);
+
+	/* Stop the current operation */
+	writel(0, &mac->mii_mgmt_cmd);
+
+	/* Set up the register we need to write to on the correct PHY */
+	writel(ET_MAC_MII_ADDR(addr, reg), &mac->mii_mgmt_addr);
+
+	/* Add the value to write to the registers to the mac */
+	writel(value, &mac->mii_mgmt_ctrl);
+
+	do {
+		udelay(50);
+		delay++;
+		mii_indicator =3D readl(&mac->mii_mgmt_indicator);
+	} while ((mii_indicator & ET_MAC_MGMT_BUSY) && delay < 100);
+
+	/* If we hit the max delay, we could not write the register */
+	if (delay =3D=3D 100) {
+		u16 tmp;
+
+		dev_warn(&adapter->pdev->dev,
+		    "reg 0x%08x could not be written", reg);
+		dev_warn(&adapter->pdev->dev, "status is  0x%08x\n",
+			    mii_indicator);
+		dev_warn(&adapter->pdev->dev, "command is  0x%08x\n",
+			    readl(&mac->mii_mgmt_cmd));
+
+		et131x_mii_read(adapter, reg, &tmp);
+
+		status =3D -EIO;
+	}
+	/* Stop the write operation */
+	writel(0, &mac->mii_mgmt_cmd);
+
+	/* set the registers we touched back to the state at which we entered
+	 * this function
+	 */
+	writel(mii_addr, &mac->mii_mgmt_addr);
+	writel(mii_cmd, &mac->mii_mgmt_cmd);
+
+	return status;
+}
+
+/* Still used from _mac for BIT_READ */
+static void et1310_phy_access_mii_bit(struct et131x_adapter *adapter,
+				      u16 action, u16 regnum, u16 bitnum,
+				      u8 *value)
+{
+	u16 reg;
+	u16 mask =3D 1 << bitnum;
+
+	/* Read the requested register */
+	et131x_mii_read(adapter, regnum, &reg);
+
+	switch (action) {
+	case TRUEPHY_BIT_READ:
+		*value =3D (reg & mask) >> bitnum;
+		break;
+
+	case TRUEPHY_BIT_SET:
+		et131x_mii_write(adapter, regnum, reg | mask);
+		break;
+
+	case TRUEPHY_BIT_CLEAR:
+		et131x_mii_write(adapter, regnum, reg & ~mask);
+		break;
+
+	default:
+		break;
+	}
+}
+
+static void et1310_config_flow_control(struct et131x_adapter *adapter)
+{
+	struct phy_device *phydev =3D adapter->phydev;
+
+	if (phydev->duplex =3D=3D DUPLEX_HALF) {
+		adapter->flowcontrol =3D FLOW_NONE;
+	} else {
+		char remote_pause, remote_async_pause;
+
+		et1310_phy_access_mii_bit(adapter,
+				TRUEPHY_BIT_READ, 5, 10, &remote_pause);
+		et1310_phy_access_mii_bit(adapter,
+				TRUEPHY_BIT_READ, 5, 11,
+				&remote_async_pause);
+
+		if ((remote_pause =3D=3D TRUEPHY_BIT_SET) &&
+		    (remote_async_pause =3D=3D TRUEPHY_BIT_SET)) {
+			adapter->flowcontrol =3D adapter->wanted_flow;
+		} else if ((remote_pause =3D=3D TRUEPHY_BIT_SET) &&
+			   (remote_async_pause =3D=3D TRUEPHY_BIT_CLEAR)) {
+			if (adapter->wanted_flow =3D=3D FLOW_BOTH)
+				adapter->flowcontrol =3D FLOW_BOTH;
+			else
+				adapter->flowcontrol =3D FLOW_NONE;
+		} else if ((remote_pause =3D=3D TRUEPHY_BIT_CLEAR) &&
+			   (remote_async_pause =3D=3D TRUEPHY_BIT_CLEAR)) {
+			adapter->flowcontrol =3D FLOW_NONE;
+		} else {/* if (remote_pause =3D=3D TRUEPHY_CLEAR_BIT &&
+			 *     remote_async_pause =3D=3D TRUEPHY_SET_BIT)
+			 */
+			if (adapter->wanted_flow =3D=3D FLOW_BOTH)
+				adapter->flowcontrol =3D FLOW_RXONLY;
+			else
+				adapter->flowcontrol =3D FLOW_NONE;
+		}
+	}
+}
+
+/* et1310_update_macstat_host_counters - Update the local copy of the =
statistics
+ * @adapter: pointer to the adapter structure
+ */
+static void et1310_update_macstat_host_counters(struct et131x_adapter =
*adapter)
+{
+	struct ce_stats *stats =3D &adapter->stats;
+	struct macstat_regs __iomem *macstat =3D
+		&adapter->regs->macstat;
+
+	stats->tx_collisions	       +=3D readl(&macstat->tx_total_collisions)=
;
+	stats->tx_first_collisions     +=3D readl(&macstat->tx_single_collisi=
ons);
+	stats->tx_deferred	       +=3D readl(&macstat->tx_deferred);
+	stats->tx_excessive_collisions +=3D
+				readl(&macstat->tx_multiple_collisions);
+	stats->tx_late_collisions      +=3D readl(&macstat->tx_late_collision=
s);
+	stats->tx_underflows	       +=3D readl(&macstat->tx_undersize_frames)=
;
+	stats->tx_max_pkt_errs	       +=3D readl(&macstat->tx_oversize_frames=
);
+
+	stats->rx_align_errs        +=3D readl(&macstat->rx_align_errs);
+	stats->rx_crc_errs          +=3D readl(&macstat->rx_code_errs);
+	stats->rcvd_pkts_dropped    +=3D readl(&macstat->rx_drops);
+	stats->rx_overflows         +=3D readl(&macstat->rx_oversize_packets)=
;
+	stats->rx_code_violations   +=3D readl(&macstat->rx_fcs_errs);
+	stats->rx_length_errs       +=3D readl(&macstat->rx_frame_len_errs);
+	stats->rx_other_errs        +=3D readl(&macstat->rx_fragment_packets)=
;
+}
+
+/* et1310_handle_macstat_interrupt
+ * @adapter: pointer to the adapter structure
+ *
+ * One of the MACSTAT counters has wrapped.  Update the local copy of
+ * the statistics held in the adapter structure, checking the "wrap"
+ * bit for each counter.
+ */
+static void et1310_handle_macstat_interrupt(struct et131x_adapter *ada=
pter)
+{
+	u32 carry_reg1;
+	u32 carry_reg2;
+
+	/* Read the interrupt bits from the register(s).  These are Clear On
+	 * Write.
+	 */
+	carry_reg1 =3D readl(&adapter->regs->macstat.carry_reg1);
+	carry_reg2 =3D readl(&adapter->regs->macstat.carry_reg2);
+
+	writel(carry_reg1, &adapter->regs->macstat.carry_reg1);
+	writel(carry_reg2, &adapter->regs->macstat.carry_reg2);
+
+	/* We need to do update the host copy of all the MAC_STAT counters.
+	 * For each counter, check it's overflow bit.  If the overflow bit is
+	 * set, then increment the host version of the count by one complete
+	 * revolution of the counter.  This routine is called when the counte=
r
+	 * block indicates that one of the counters has wrapped.
+	 */
+	if (carry_reg1 & (1 << 14))
+		adapter->stats.rx_code_violations	+=3D COUNTER_WRAP_16_BIT;
+	if (carry_reg1 & (1 << 8))
+		adapter->stats.rx_align_errs	+=3D COUNTER_WRAP_12_BIT;
+	if (carry_reg1 & (1 << 7))
+		adapter->stats.rx_length_errs	+=3D COUNTER_WRAP_16_BIT;
+	if (carry_reg1 & (1 << 2))
+		adapter->stats.rx_other_errs	+=3D COUNTER_WRAP_16_BIT;
+	if (carry_reg1 & (1 << 6))
+		adapter->stats.rx_crc_errs	+=3D COUNTER_WRAP_16_BIT;
+	if (carry_reg1 & (1 << 3))
+		adapter->stats.rx_overflows	+=3D COUNTER_WRAP_16_BIT;
+	if (carry_reg1 & (1 << 0))
+		adapter->stats.rcvd_pkts_dropped	+=3D COUNTER_WRAP_16_BIT;
+	if (carry_reg2 & (1 << 16))
+		adapter->stats.tx_max_pkt_errs	+=3D COUNTER_WRAP_12_BIT;
+	if (carry_reg2 & (1 << 15))
+		adapter->stats.tx_underflows	+=3D COUNTER_WRAP_12_BIT;
+	if (carry_reg2 & (1 << 6))
+		adapter->stats.tx_first_collisions +=3D COUNTER_WRAP_12_BIT;
+	if (carry_reg2 & (1 << 8))
+		adapter->stats.tx_deferred	+=3D COUNTER_WRAP_12_BIT;
+	if (carry_reg2 & (1 << 5))
+		adapter->stats.tx_excessive_collisions +=3D COUNTER_WRAP_12_BIT;
+	if (carry_reg2 & (1 << 4))
+		adapter->stats.tx_late_collisions	+=3D COUNTER_WRAP_12_BIT;
+	if (carry_reg2 & (1 << 2))
+		adapter->stats.tx_collisions	+=3D COUNTER_WRAP_12_BIT;
+}
+
+static int et131x_mdio_read(struct mii_bus *bus, int phy_addr, int reg=
)
+{
+	struct net_device *netdev =3D bus->priv;
+	struct et131x_adapter *adapter =3D netdev_priv(netdev);
+	u16 value;
+	int ret;
+
+	ret =3D et131x_phy_mii_read(adapter, phy_addr, reg, &value);
+
+	if (ret < 0)
+		return ret;
+	else
+		return value;
+}
+
+static int et131x_mdio_write(struct mii_bus *bus, int phy_addr,
+			     int reg, u16 value)
+{
+	struct net_device *netdev =3D bus->priv;
+	struct et131x_adapter *adapter =3D netdev_priv(netdev);
+
+	return et131x_mii_write(adapter, reg, value);
+}
+
+static int et131x_mdio_reset(struct mii_bus *bus)
+{
+	struct net_device *netdev =3D bus->priv;
+	struct et131x_adapter *adapter =3D netdev_priv(netdev);
+
+	et131x_mii_write(adapter, MII_BMCR, BMCR_RESET);
+
+	return 0;
+}
+
+/*	et1310_phy_power_down	-	PHY power control
+ *	@adapter: device to control
+ *	@down: true for off/false for back on
+ *
+ *	one hundred, ten, one thousand megs
+ *	How would you like to have your LAN accessed
+ *	Can't you see that this code processed
+ *	Phy power, phy power..
+ */
+static void et1310_phy_power_down(struct et131x_adapter *adapter, bool=
 down)
+{
+	u16 data;
+
+	et131x_mii_read(adapter, MII_BMCR, &data);
+	data &=3D ~BMCR_PDOWN;
+	if (down)
+		data |=3D BMCR_PDOWN;
+	et131x_mii_write(adapter, MII_BMCR, data);
+}
+
+/* et131x_xcvr_init - Init the phy if we are setting it into force mod=
e
+ * @adapter: pointer to our private adapter structure
+ *
+ */
+static void et131x_xcvr_init(struct et131x_adapter *adapter)
+{
+	u16 lcr2;
+
+	/* Set the LED behavior such that LED 1 indicates speed (off =3D
+	 * 10Mbits, blink =3D 100Mbits, on =3D 1000Mbits) and LED 2 indicates
+	 * link and activity (on for link, blink off for activity).
+	 *
+	 * NOTE: Some customizations have been added here for specific
+	 * vendors; The LED behavior is now determined by vendor data in the
+	 * EEPROM. However, the above description is the default.
+	 */
+	if ((adapter->eeprom_data[1] & 0x4) =3D=3D 0) {
+		et131x_mii_read(adapter, PHY_LED_2, &lcr2);
+
+		lcr2 &=3D (ET_LED2_LED_100TX | ET_LED2_LED_1000T);
+		lcr2 |=3D (LED_VAL_LINKON_ACTIVE << LED_LINK_SHIFT);
+
+		if ((adapter->eeprom_data[1] & 0x8) =3D=3D 0)
+			lcr2 |=3D (LED_VAL_1000BT_100BTX << LED_TXRX_SHIFT);
+		else
+			lcr2 |=3D (LED_VAL_LINKON << LED_TXRX_SHIFT);
+
+		et131x_mii_write(adapter, PHY_LED_2, lcr2);
+	}
+}
+
+/* et131x_configure_global_regs	- configure JAGCore global regs
+ * @adapter: pointer to our adapter structure
+ *
+ * Used to configure the global registers on the JAGCore
+ */
+static void et131x_configure_global_regs(struct et131x_adapter *adapte=
r)
+{
+	struct global_regs __iomem *regs =3D &adapter->regs->global;
+
+	writel(0, &regs->rxq_start_addr);
+	writel(INTERNAL_MEM_SIZE - 1, &regs->txq_end_addr);
+
+	if (adapter->registry_jumbo_packet < 2048) {
+		/* Tx / RxDMA and Tx/Rx MAC interfaces have a 1k word
+		 * block of RAM that the driver can split between Tx
+		 * and Rx as it desires.  Our default is to split it
+		 * 50/50:
+		 */
+		writel(PARM_RX_MEM_END_DEF, &regs->rxq_end_addr);
+		writel(PARM_RX_MEM_END_DEF + 1, &regs->txq_start_addr);
+	} else if (adapter->registry_jumbo_packet < 8192) {
+		/* For jumbo packets > 2k but < 8k, split 50-50. */
+		writel(INTERNAL_MEM_RX_OFFSET, &regs->rxq_end_addr);
+		writel(INTERNAL_MEM_RX_OFFSET + 1, &regs->txq_start_addr);
+	} else {
+		/* 9216 is the only packet size greater than 8k that
+		 * is available. The Tx buffer has to be big enough
+		 * for one whole packet on the Tx side. We'll make
+		 * the Tx 9408, and give the rest to Rx
+		 */
+		writel(0x01b3, &regs->rxq_end_addr);
+		writel(0x01b4, &regs->txq_start_addr);
+	}
+
+	/* Initialize the loopback register. Disable all loopbacks. */
+	writel(0, &regs->loopback);
+
+	/* MSI Register */
+	writel(0, &regs->msi_config);
+
+	/* By default, disable the watchdog timer.  It will be enabled when
+	 * a packet is queued.
+	 */
+	writel(0, &regs->watchdog_timer);
+}
+
+/* et131x_config_rx_dma_regs - Start of Rx_DMA init sequence
+ * @adapter: pointer to our adapter structure
+ */
+static void et131x_config_rx_dma_regs(struct et131x_adapter *adapter)
+{
+	struct rxdma_regs __iomem *rx_dma =3D &adapter->regs->rxdma;
+	struct rx_ring *rx_local =3D &adapter->rx_ring;
+	struct fbr_desc *fbr_entry;
+	u32 entry;
+	u32 psr_num_des;
+	unsigned long flags;
+	u8 id;
+
+	/* Halt RXDMA to perform the reconfigure.  */
+	et131x_rx_dma_disable(adapter);
+
+	/* Load the completion writeback physical address */
+	writel(upper_32_bits(rx_local->rx_status_bus), &rx_dma->dma_wb_base_h=
i);
+	writel(lower_32_bits(rx_local->rx_status_bus), &rx_dma->dma_wb_base_l=
o);
+
+	memset(rx_local->rx_status_block, 0, sizeof(struct rx_status_block));
+
+	/* Set the address and parameters of the packet status ring into the
+	 * 1310's registers
+	 */
+	writel(upper_32_bits(rx_local->ps_ring_physaddr), &rx_dma->psr_base_h=
i);
+	writel(lower_32_bits(rx_local->ps_ring_physaddr), &rx_dma->psr_base_l=
o);
+	writel(rx_local->psr_num_entries - 1, &rx_dma->psr_num_des);
+	writel(0, &rx_dma->psr_full_offset);
+
+	psr_num_des =3D readl(&rx_dma->psr_num_des) & ET_RXDMA_PSR_NUM_DES_MA=
SK;
+	writel((psr_num_des * LO_MARK_PERCENT_FOR_PSR) / 100,
+	       &rx_dma->psr_min_des);
+
+	spin_lock_irqsave(&adapter->rcv_lock, flags);
+
+	/* These local variables track the PSR in the adapter structure */
+	rx_local->local_psr_full =3D 0;
+
+	for (id =3D 0; id < NUM_FBRS; id++) {
+		u32 __iomem *num_des;
+		u32 __iomem *full_offset;
+		u32 __iomem *min_des;
+		u32 __iomem *base_hi;
+		u32 __iomem *base_lo;
+
+		if (id =3D=3D 0) {
+			num_des =3D &rx_dma->fbr0_num_des;
+			full_offset =3D &rx_dma->fbr0_full_offset;
+			min_des =3D &rx_dma->fbr0_min_des;
+			base_hi =3D &rx_dma->fbr0_base_hi;
+			base_lo =3D &rx_dma->fbr0_base_lo;
+		} else {
+			num_des =3D &rx_dma->fbr1_num_des;
+			full_offset =3D &rx_dma->fbr1_full_offset;
+			min_des =3D &rx_dma->fbr1_min_des;
+			base_hi =3D &rx_dma->fbr1_base_hi;
+			base_lo =3D &rx_dma->fbr1_base_lo;
+		}
+
+		/* Now's the best time to initialize FBR contents */
+		fbr_entry =3D
+		    (struct fbr_desc *) rx_local->fbr[id]->ring_virtaddr;
+		for (entry =3D 0;
+		     entry < rx_local->fbr[id]->num_entries; entry++) {
+			fbr_entry->addr_hi =3D rx_local->fbr[id]->bus_high[entry];
+			fbr_entry->addr_lo =3D rx_local->fbr[id]->bus_low[entry];
+			fbr_entry->word2 =3D entry;
+			fbr_entry++;
+		}
+
+		/* Set the address and parameters of Free buffer ring 1 and 0
+		 * into the 1310's registers
+		 */
+		writel(upper_32_bits(rx_local->fbr[id]->ring_physaddr),
+		       base_hi);
+		writel(lower_32_bits(rx_local->fbr[id]->ring_physaddr),
+		       base_lo);
+		writel(rx_local->fbr[id]->num_entries - 1, num_des);
+		writel(ET_DMA10_WRAP, full_offset);
+
+		/* This variable tracks the free buffer ring 1 full position,
+		 * so it has to match the above.
+		 */
+		rx_local->fbr[id]->local_full =3D ET_DMA10_WRAP;
+		writel(((rx_local->fbr[id]->num_entries *
+					LO_MARK_PERCENT_FOR_RX) / 100) - 1,
+		       min_des);
+	}
+
+	/* Program the number of packets we will receive before generating an
+	 * interrupt.
+	 * For version B silicon, this value gets updated once autoneg is
+	 *complete.
+	 */
+	writel(PARM_RX_NUM_BUFS_DEF, &rx_dma->num_pkt_done);
+
+	/* The "time_done" is not working correctly to coalesce interrupts
+	 * after a given time period, but rather is giving us an interrupt
+	 * regardless of whether we have received packets.
+	 * This value gets updated once autoneg is complete.
+	 */
+	writel(PARM_RX_TIME_INT_DEF, &rx_dma->max_pkt_time);
+
+	spin_unlock_irqrestore(&adapter->rcv_lock, flags);
+}
+
+/* et131x_config_tx_dma_regs - Set up the tx dma section of the JAGCor=
e.
+ * @adapter: pointer to our private adapter structure
+ *
+ * Configure the transmit engine with the ring buffers we have created
+ * and prepare it for use.
+ */
+static void et131x_config_tx_dma_regs(struct et131x_adapter *adapter)
+{
+	struct txdma_regs __iomem *txdma =3D &adapter->regs->txdma;
+
+	/* Load the hardware with the start of the transmit descriptor ring. =
*/
+	writel(upper_32_bits(adapter->tx_ring.tx_desc_ring_pa),
+	       &txdma->pr_base_hi);
+	writel(lower_32_bits(adapter->tx_ring.tx_desc_ring_pa),
+	       &txdma->pr_base_lo);
+
+	/* Initialise the transmit DMA engine */
+	writel(NUM_DESC_PER_RING_TX - 1, &txdma->pr_num_des);
+
+	/* Load the completion writeback physical address */
+	writel(upper_32_bits(adapter->tx_ring.tx_status_pa),
+	       &txdma->dma_wb_base_hi);
+	writel(lower_32_bits(adapter->tx_ring.tx_status_pa),
+	       &txdma->dma_wb_base_lo);
+
+	*adapter->tx_ring.tx_status =3D 0;
+
+	writel(0, &txdma->service_request);
+	adapter->tx_ring.send_idx =3D 0;
+}
+
+/* et131x_adapter_setup - Set the adapter up as per cassini+ documenta=
tion
+ * @adapter: pointer to our private adapter structure
+ *
+ * Returns 0 on success, errno on failure (as defined in errno.h)
+ */
+static void et131x_adapter_setup(struct et131x_adapter *adapter)
+{
+	/* Configure the JAGCore */
+	et131x_configure_global_regs(adapter);
+
+	et1310_config_mac_regs1(adapter);
+
+	/* Configure the MMC registers */
+	/* All we need to do is initialize the Memory Control Register */
+	writel(ET_MMC_ENABLE, &adapter->regs->mmc.mmc_ctrl);
+
+	et1310_config_rxmac_regs(adapter);
+	et1310_config_txmac_regs(adapter);
+
+	et131x_config_rx_dma_regs(adapter);
+	et131x_config_tx_dma_regs(adapter);
+
+	et1310_config_macstat_regs(adapter);
+
+	et1310_phy_power_down(adapter, 0);
+	et131x_xcvr_init(adapter);
+}
+
+/* et131x_soft_reset - Issue a soft reset to the hardware, complete fo=
r ET1310
+ * @adapter: pointer to our private adapter structure
+ */
+static void et131x_soft_reset(struct et131x_adapter *adapter)
+{
+	u32 reg;
+
+	/* Disable MAC Core */
+	reg =3D ET_MAC_CFG1_SOFT_RESET | ET_MAC_CFG1_SIM_RESET |
+	      ET_MAC_CFG1_RESET_RXMC | ET_MAC_CFG1_RESET_TXMC |
+	      ET_MAC_CFG1_RESET_RXFUNC | ET_MAC_CFG1_RESET_TXFUNC;
+	writel(reg, &adapter->regs->mac.cfg1);
+
+	reg =3D ET_RESET_ALL;
+	writel(reg, &adapter->regs->global.sw_reset);
+
+	reg =3D ET_MAC_CFG1_RESET_RXMC | ET_MAC_CFG1_RESET_TXMC |
+	      ET_MAC_CFG1_RESET_RXFUNC | ET_MAC_CFG1_RESET_TXFUNC;
+	writel(reg, &adapter->regs->mac.cfg1);
+	writel(0, &adapter->regs->mac.cfg1);
+}
+
+/*	et131x_enable_interrupts	-	enable interrupt
+ *	@adapter: et131x device
+ *
+ *	Enable the appropriate interrupts on the ET131x according to our
+ *	configuration
+ */
+static void et131x_enable_interrupts(struct et131x_adapter *adapter)
+{
+	u32 mask;
+
+	/* Enable all global interrupts */
+	if (adapter->flowcontrol =3D=3D FLOW_TXONLY ||
+			    adapter->flowcontrol =3D=3D FLOW_BOTH)
+		mask =3D INT_MASK_ENABLE;
+	else
+		mask =3D INT_MASK_ENABLE_NO_FLOW;
+
+	writel(mask, &adapter->regs->global.int_mask);
+}
+
+/*	et131x_disable_interrupts	-	interrupt disable
+ *	@adapter: et131x device
+ *
+ *	Block all interrupts from the et131x device at the device itself
+ */
+static void et131x_disable_interrupts(struct et131x_adapter *adapter)
+{
+	/* Disable all global interrupts */
+	writel(INT_MASK_DISABLE, &adapter->regs->global.int_mask);
+}
+
+/* et131x_tx_dma_disable - Stop of Tx_DMA on the ET1310
+ * @adapter: pointer to our adapter structure
+ */
+static void et131x_tx_dma_disable(struct et131x_adapter *adapter)
+{
+	/* Setup the tramsmit dma configuration register */
+	writel(ET_TXDMA_CSR_HALT | ET_TXDMA_SNGL_EPKT,
+					&adapter->regs->txdma.csr);
+}
+
+/* et131x_enable_txrx - Enable tx/rx queues
+ * @netdev: device to be enabled
+ */
+static void et131x_enable_txrx(struct net_device *netdev)
+{
+	struct et131x_adapter *adapter =3D netdev_priv(netdev);
+
+	/* Enable the Tx and Rx DMA engines (if not already enabled) */
+	et131x_rx_dma_enable(adapter);
+	et131x_tx_dma_enable(adapter);
+
+	/* Enable device interrupts */
+	if (adapter->flags & FMP_ADAPTER_INTERRUPT_IN_USE)
+		et131x_enable_interrupts(adapter);
+
+	/* We're ready to move some data, so start the queue */
+	netif_start_queue(netdev);
+}
+
+/* et131x_disable_txrx - Disable tx/rx queues
+ * @netdev: device to be disabled
+ */
+static void et131x_disable_txrx(struct net_device *netdev)
+{
+	struct et131x_adapter *adapter =3D netdev_priv(netdev);
+
+	/* First thing is to stop the queue */
+	netif_stop_queue(netdev);
+
+	/* Stop the Tx and Rx DMA engines */
+	et131x_rx_dma_disable(adapter);
+	et131x_tx_dma_disable(adapter);
+
+	/* Disable device interrupts */
+	et131x_disable_interrupts(adapter);
+}
+
+/* et131x_init_send - Initialize send data structures
+ * @adapter: pointer to our private adapter structure
+ */
+static void et131x_init_send(struct et131x_adapter *adapter)
+{
+	struct tcb *tcb;
+	u32 ct;
+	struct tx_ring *tx_ring;
+
+	/* Setup some convenience pointers */
+	tx_ring =3D &adapter->tx_ring;
+	tcb =3D adapter->tx_ring.tcb_ring;
+
+	tx_ring->tcb_qhead =3D tcb;
+
+	memset(tcb, 0, sizeof(struct tcb) * NUM_TCB);
+
+	/* Go through and set up each TCB */
+	for (ct =3D 0; ct++ < NUM_TCB; tcb++)
+		/* Set the link pointer in HW TCB to the next TCB in the
+		 * chain
+		 */
+		tcb->next =3D tcb + 1;
+
+	/* Set the  tail pointer */
+	tcb--;
+	tx_ring->tcb_qtail =3D tcb;
+	tcb->next =3D NULL;
+	/* Curr send queue should now be empty */
+	tx_ring->send_head =3D NULL;
+	tx_ring->send_tail =3D NULL;
+}
+
+/* et1310_enable_phy_coma - called when network cable is unplugged
+ * @adapter: pointer to our adapter structure
+ *
+ * driver receive an phy status change interrupt while in D0 and check=
 that
+ * phy_status is down.
+ *
+ *          -- gate off JAGCore;
+ *          -- set gigE PHY in Coma mode
+ *          -- wake on phy_interrupt; Perform software reset JAGCore,
+ *             re-initialize jagcore and gigE PHY
+ *
+ *      Add D0-ASPM-PhyLinkDown Support:
+ *          -- while in D0, when there is a phy_interrupt indicating p=
hy link
+ *             down status, call the MPSetPhyComa routine to enter thi=
s active
+ *             state power saving mode
+ *          -- while in D0-ASPM-PhyLinkDown mode, when there is a phy_=
interrupt
+ *       indicating linkup status, call the MPDisablePhyComa routine t=
o
+ *             restore JAGCore and gigE PHY
+ */
+static void et1310_enable_phy_coma(struct et131x_adapter *adapter)
+{
+	unsigned long flags;
+	u32 pmcsr;
+
+	pmcsr =3D readl(&adapter->regs->global.pm_csr);
+
+	/* Save the GbE PHY speed and duplex modes. Need to restore this
+	 * when cable is plugged back in
+	 */
+	/* TODO - when PM is re-enabled, check if we need to
+	 * perform a similar task as this -
+	 * adapter->pdown_speed =3D adapter->ai_force_speed;
+	 * adapter->pdown_duplex =3D adapter->ai_force_duplex;
+	 */
+
+	/* Stop sending packets. */
+	spin_lock_irqsave(&adapter->send_hw_lock, flags);
+	adapter->flags |=3D FMP_ADAPTER_LOWER_POWER;
+	spin_unlock_irqrestore(&adapter->send_hw_lock, flags);
+
+	/* Wait for outstanding Receive packets */
+
+	et131x_disable_txrx(adapter->netdev);
+
+	/* Gate off JAGCore 3 clock domains */
+	pmcsr &=3D ~ET_PMCSR_INIT;
+	writel(pmcsr, &adapter->regs->global.pm_csr);
+
+	/* Program gigE PHY in to Coma mode */
+	pmcsr |=3D ET_PM_PHY_SW_COMA;
+	writel(pmcsr, &adapter->regs->global.pm_csr);
+}
+
+/* et1310_disable_phy_coma - Disable the Phy Coma Mode
+ * @adapter: pointer to our adapter structure
+ */
+static void et1310_disable_phy_coma(struct et131x_adapter *adapter)
+{
+	u32 pmcsr;
+
+	pmcsr =3D readl(&adapter->regs->global.pm_csr);
+
+	/* Disable phy_sw_coma register and re-enable JAGCore clocks */
+	pmcsr |=3D ET_PMCSR_INIT;
+	pmcsr &=3D ~ET_PM_PHY_SW_COMA;
+	writel(pmcsr, &adapter->regs->global.pm_csr);
+
+	/* Restore the GbE PHY speed and duplex modes;
+	 * Reset JAGCore; re-configure and initialize JAGCore and gigE PHY
+	 */
+	/* TODO - when PM is re-enabled, check if we need to
+	 * perform a similar task as this -
+	 * adapter->ai_force_speed =3D adapter->pdown_speed;
+	 * adapter->ai_force_duplex =3D adapter->pdown_duplex;
+	 */
+
+	/* Re-initialize the send structures */
+	et131x_init_send(adapter);
+
+	/* Bring the device back to the state it was during init prior to
+	 * autonegotiation being complete.  This way, when we get the auto-ne=
g
+	 * complete interrupt, we can complete init by calling ConfigMacREGS2=
=2E
+	 */
+	et131x_soft_reset(adapter);
+
+	/* setup et1310 as per the documentation ?? */
+	et131x_adapter_setup(adapter);
+
+	/* Allow Tx to restart */
+	adapter->flags &=3D ~FMP_ADAPTER_LOWER_POWER;
+
+	et131x_enable_txrx(adapter->netdev);
+}
+
+static inline u32 bump_free_buff_ring(u32 *free_buff_ring, u32 limit)
+{
+	u32 tmp_free_buff_ring =3D *free_buff_ring;
+	tmp_free_buff_ring++;
+	/* This works for all cases where limit < 1024. The 1023 case
+	 * works because 1023++ is 1024 which means the if condition is not
+	 * taken but the carry of the bit into the wrap bit toggles the wrap
+	 * value correctly
+	 */
+	if ((tmp_free_buff_ring & ET_DMA10_MASK) > limit) {
+		tmp_free_buff_ring &=3D ~ET_DMA10_MASK;
+		tmp_free_buff_ring ^=3D ET_DMA10_WRAP;
+	}
+	/* For the 1023 case */
+	tmp_free_buff_ring &=3D (ET_DMA10_MASK|ET_DMA10_WRAP);
+	*free_buff_ring =3D tmp_free_buff_ring;
+	return tmp_free_buff_ring;
+}
+
+/* et131x_rx_dma_memory_alloc
+ * @adapter: pointer to our private adapter structure
+ *
+ * Returns 0 on success and errno on failure (as defined in errno.h)
+ *
+ * Allocates Free buffer ring 1 for sure, free buffer ring 0 if requir=
ed,
+ * and the Packet Status Ring.
+ */
+static int et131x_rx_dma_memory_alloc(struct et131x_adapter *adapter)
+{
+	u8 id;
+	u32 i, j;
+	u32 bufsize;
+	u32 pktstat_ringsize;
+	u32 fbr_chunksize;
+	struct rx_ring *rx_ring;
+
+	/* Setup some convenience pointers */
+	rx_ring =3D &adapter->rx_ring;
+
+	/* Alloc memory for the lookup table */
+	rx_ring->fbr[0] =3D kmalloc(sizeof(struct fbr_lookup), GFP_KERNEL);
+	rx_ring->fbr[1] =3D kmalloc(sizeof(struct fbr_lookup), GFP_KERNEL);
+
+	/* The first thing we will do is configure the sizes of the buffer
+	 * rings. These will change based on jumbo packet support.  Larger
+	 * jumbo packets increases the size of each entry in FBR0, and the
+	 * number of entries in FBR0, while at the same time decreasing the
+	 * number of entries in FBR1.
+	 *
+	 * FBR1 holds "large" frames, FBR0 holds "small" frames.  If FBR1
+	 * entries are huge in order to accommodate a "jumbo" frame, then it
+	 * will have less entries.  Conversely, FBR1 will now be relied upon
+	 * to carry more "normal" frames, thus it's entry size also increases
+	 * and the number of entries goes up too (since it now carries
+	 * "small" + "regular" packets.
+	 *
+	 * In this scheme, we try to maintain 512 entries between the two
+	 * rings. Also, FBR1 remains a constant size - when it's size doubles
+	 * the number of entries halves.  FBR0 increases in size, however.
+	 */
+
+	if (adapter->registry_jumbo_packet < 2048) {
+		rx_ring->fbr[0]->buffsize =3D 256;
+		rx_ring->fbr[0]->num_entries =3D 512;
+		rx_ring->fbr[1]->buffsize =3D 2048;
+		rx_ring->fbr[1]->num_entries =3D 512;
+	} else if (adapter->registry_jumbo_packet < 4096) {
+		rx_ring->fbr[0]->buffsize =3D 512;
+		rx_ring->fbr[0]->num_entries =3D 1024;
+		rx_ring->fbr[1]->buffsize =3D 4096;
+		rx_ring->fbr[1]->num_entries =3D 512;
+	} else {
+		rx_ring->fbr[0]->buffsize =3D 1024;
+		rx_ring->fbr[0]->num_entries =3D 768;
+		rx_ring->fbr[1]->buffsize =3D 16384;
+		rx_ring->fbr[1]->num_entries =3D 128;
+	}
+
+	adapter->rx_ring.psr_num_entries =3D
+				adapter->rx_ring.fbr[0]->num_entries +
+				adapter->rx_ring.fbr[1]->num_entries;
+
+	for (id =3D 0; id < NUM_FBRS; id++) {
+		/* Allocate an area of memory for Free Buffer Ring */
+		bufsize =3D
+		    (sizeof(struct fbr_desc) * rx_ring->fbr[id]->num_entries);
+		rx_ring->fbr[id]->ring_virtaddr =3D
+				dma_alloc_coherent(&adapter->pdev->dev,
+					bufsize,
+					&rx_ring->fbr[id]->ring_physaddr,
+					GFP_KERNEL);
+		if (!rx_ring->fbr[id]->ring_virtaddr) {
+			dev_err(&adapter->pdev->dev,
+			   "Cannot alloc memory for Free Buffer Ring %d\n", id);
+			return -ENOMEM;
+		}
+	}
+
+	for (id =3D 0; id < NUM_FBRS; id++) {
+		fbr_chunksize =3D (FBR_CHUNKS * rx_ring->fbr[id]->buffsize);
+
+		for (i =3D 0;
+		     i < (rx_ring->fbr[id]->num_entries / FBR_CHUNKS); i++) {
+			dma_addr_t fbr_tmp_physaddr;
+
+			rx_ring->fbr[id]->mem_virtaddrs[i] =3D dma_alloc_coherent(
+					&adapter->pdev->dev, fbr_chunksize,
+					&rx_ring->fbr[id]->mem_physaddrs[i],
+					GFP_KERNEL);
+
+			if (!rx_ring->fbr[id]->mem_virtaddrs[i]) {
+				dev_err(&adapter->pdev->dev,
+					"Could not alloc memory\n");
+				return -ENOMEM;
+			}
+
+			/* See NOTE in "Save Physical Address" comment above */
+			fbr_tmp_physaddr =3D rx_ring->fbr[id]->mem_physaddrs[i];
+
+			for (j =3D 0; j < FBR_CHUNKS; j++) {
+				u32 index =3D (i * FBR_CHUNKS) + j;
+
+				/* Save the Virtual address of this index for
+				 * quick access later
+				 */
+				rx_ring->fbr[id]->virt[index] =3D
+				  (u8 *) rx_ring->fbr[id]->mem_virtaddrs[i] +
+				  (j * rx_ring->fbr[id]->buffsize);
+
+				/* now store the physical address in the
+				 * descriptor so the device can access it
+				 */
+				rx_ring->fbr[id]->bus_high[index] =3D
+						upper_32_bits(fbr_tmp_physaddr);
+				rx_ring->fbr[id]->bus_low[index] =3D
+						lower_32_bits(fbr_tmp_physaddr);
+
+				fbr_tmp_physaddr +=3D rx_ring->fbr[id]->buffsize;
+			}
+		}
+	}
+
+	/* Allocate an area of memory for FIFO of Packet Status ring entries =
*/
+	pktstat_ringsize =3D
+	    sizeof(struct pkt_stat_desc) * adapter->rx_ring.psr_num_entries;
+
+	rx_ring->ps_ring_virtaddr =3D dma_alloc_coherent(&adapter->pdev->dev,
+						  pktstat_ringsize,
+						  &rx_ring->ps_ring_physaddr,
+						  GFP_KERNEL);
+
+	if (!rx_ring->ps_ring_virtaddr) {
+		dev_err(&adapter->pdev->dev,
+			  "Cannot alloc memory for Packet Status Ring\n");
+		return -ENOMEM;
+	}
+	pr_info("Packet Status Ring %llx\n",
+		(unsigned long long) rx_ring->ps_ring_physaddr);
+
+	/* NOTE : dma_alloc_coherent(), used above to alloc DMA regions,
+	 * ALWAYS returns SAC (32-bit) addresses. If DAC (64-bit) addresses
+	 * are ever returned, make sure the high part is retrieved here befor=
e
+	 * storing the adjusted address.
+	 */
+
+	/* Allocate an area of memory for writeback of status information */
+	rx_ring->rx_status_block =3D dma_alloc_coherent(&adapter->pdev->dev,
+					    sizeof(struct rx_status_block),
+					    &rx_ring->rx_status_bus,
+					    GFP_KERNEL);
+	if (!rx_ring->rx_status_block) {
+		dev_err(&adapter->pdev->dev,
+			  "Cannot alloc memory for Status Block\n");
+		return -ENOMEM;
+	}
+	rx_ring->num_rfd =3D NIC_DEFAULT_NUM_RFD;
+	pr_info("PRS %llx\n", (unsigned long long)rx_ring->rx_status_bus);
+
+	/* The RFDs are going to be put on lists later on, so initialize the
+	 * lists now.
+	 */
+	INIT_LIST_HEAD(&rx_ring->recv_list);
+	return 0;
+}
+
+/* et131x_rx_dma_memory_free - Free all memory allocated within this m=
odule.
+ * @adapter: pointer to our private adapter structure
+ */
+static void et131x_rx_dma_memory_free(struct et131x_adapter *adapter)
+{
+	u8 id;
+	u32 index;
+	u32 bufsize;
+	u32 pktstat_ringsize;
+	struct rfd *rfd;
+	struct rx_ring *rx_ring;
+
+	/* Setup some convenience pointers */
+	rx_ring =3D &adapter->rx_ring;
+
+	/* Free RFDs and associated packet descriptors */
+	WARN_ON(rx_ring->num_ready_recv !=3D rx_ring->num_rfd);
+
+	while (!list_empty(&rx_ring->recv_list)) {
+		rfd =3D (struct rfd *) list_entry(rx_ring->recv_list.next,
+				struct rfd, list_node);
+
+		list_del(&rfd->list_node);
+		rfd->skb =3D NULL;
+		kfree(rfd);
+	}
+
+	/* Free Free Buffer Rings */
+	for (id =3D 0; id < NUM_FBRS; id++) {
+		if (!rx_ring->fbr[id]->ring_virtaddr)
+			continue;
+
+		/* First the packet memory */
+		for (index =3D 0;
+		     index < (rx_ring->fbr[id]->num_entries / FBR_CHUNKS);
+		     index++) {
+			if (rx_ring->fbr[id]->mem_virtaddrs[index]) {
+				bufsize =3D
+				    rx_ring->fbr[id]->buffsize * FBR_CHUNKS;
+
+				dma_free_coherent(&adapter->pdev->dev,
+					bufsize,
+					rx_ring->fbr[id]->mem_virtaddrs[index],
+					rx_ring->fbr[id]->mem_physaddrs[index]);
+
+				rx_ring->fbr[id]->mem_virtaddrs[index] =3D NULL;
+			}
+		}
+
+		bufsize =3D
+		    sizeof(struct fbr_desc) * rx_ring->fbr[id]->num_entries;
+
+		dma_free_coherent(&adapter->pdev->dev, bufsize,
+				    rx_ring->fbr[id]->ring_virtaddr,
+				    rx_ring->fbr[id]->ring_physaddr);
+
+		rx_ring->fbr[id]->ring_virtaddr =3D NULL;
+	}
+
+	/* Free Packet Status Ring */
+	if (rx_ring->ps_ring_virtaddr) {
+		pktstat_ringsize =3D sizeof(struct pkt_stat_desc) *
+					adapter->rx_ring.psr_num_entries;
+
+		dma_free_coherent(&adapter->pdev->dev, pktstat_ringsize,
+				    rx_ring->ps_ring_virtaddr,
+				    rx_ring->ps_ring_physaddr);
+
+		rx_ring->ps_ring_virtaddr =3D NULL;
+	}
+
+	/* Free area of memory for the writeback of status information */
+	if (rx_ring->rx_status_block) {
+		dma_free_coherent(&adapter->pdev->dev,
+			sizeof(struct rx_status_block),
+			rx_ring->rx_status_block, rx_ring->rx_status_bus);
+		rx_ring->rx_status_block =3D NULL;
+	}
+
+	/* Free the FBR Lookup Table */
+	kfree(rx_ring->fbr[0]);
+	kfree(rx_ring->fbr[1]);
+
+	/* Reset Counters */
+	rx_ring->num_ready_recv =3D 0;
+}
+
+/* et131x_init_recv - Initialize receive data structures.
+ * @adapter: pointer to our private adapter structure
+ *
+ * Returns 0 on success and errno on failure (as defined in errno.h)
+ */
+static int et131x_init_recv(struct et131x_adapter *adapter)
+{
+	struct rfd *rfd;
+	u32 rfdct;
+	u32 numrfd =3D 0;
+	struct rx_ring *rx_ring;
+
+	/* Setup some convenience pointers */
+	rx_ring =3D &adapter->rx_ring;
+
+	/* Setup each RFD */
+	for (rfdct =3D 0; rfdct < rx_ring->num_rfd; rfdct++) {
+		rfd =3D kzalloc(sizeof(struct rfd), GFP_ATOMIC | GFP_DMA);
+
+		if (!rfd) {
+			dev_err(&adapter->pdev->dev, "Couldn't alloc RFD\n");
+			return -ENOMEM;
+		}
+
+		rfd->skb =3D NULL;
+
+		/* Add this RFD to the recv_list */
+		list_add_tail(&rfd->list_node, &rx_ring->recv_list);
+
+		/* Increment both the available RFD's, and the total RFD's. */
+		rx_ring->num_ready_recv++;
+		numrfd++;
+	}
+
+	return 0;
+}
+
+/* et131x_set_rx_dma_timer - Set the heartbeat timer according to line=
 rate.
+ * @adapter: pointer to our adapter structure
+ */
+static void et131x_set_rx_dma_timer(struct et131x_adapter *adapter)
+{
+	struct phy_device *phydev =3D adapter->phydev;
+
+	if (!phydev)
+		return;
+
+	/* For version B silicon, we do not use the RxDMA timer for 10 and 10=
0
+	 * Mbits/s line rates. We do not enable and RxDMA interrupt coalescin=
g.
+	 */
+	if ((phydev->speed =3D=3D SPEED_100) || (phydev->speed =3D=3D SPEED_1=
0)) {
+		writel(0, &adapter->regs->rxdma.max_pkt_time);
+		writel(1, &adapter->regs->rxdma.num_pkt_done);
+	}
+}
+
+/* NICReturnRFD - Recycle a RFD and put it back onto the receive list
+ * @adapter: pointer to our adapter
+ * @rfd: pointer to the RFD
+ */
+static void nic_return_rfd(struct et131x_adapter *adapter, struct rfd =
*rfd)
+{
+	struct rx_ring *rx_local =3D &adapter->rx_ring;
+	struct rxdma_regs __iomem *rx_dma =3D &adapter->regs->rxdma;
+	u16 buff_index =3D rfd->bufferindex;
+	u8 ring_index =3D rfd->ringindex;
+	unsigned long flags;
+
+	/* We don't use any of the OOB data besides status. Otherwise, we
+	 * need to clean up OOB data
+	 */
+	if (buff_index < rx_local->fbr[ring_index]->num_entries) {
+		u32 __iomem *offset;
+		struct fbr_desc *next;
+
+		spin_lock_irqsave(&adapter->fbr_lock, flags);
+
+		if (ring_index =3D=3D 0)
+			offset =3D &rx_dma->fbr0_full_offset;
+		else
+			offset =3D &rx_dma->fbr1_full_offset;
+
+		next =3D (struct fbr_desc *)
+			   (rx_local->fbr[ring_index]->ring_virtaddr) +
+				INDEX10(rx_local->fbr[ring_index]->local_full);
+
+		/* Handle the Free Buffer Ring advancement here. Write
+		 * the PA / Buffer Index for the returned buffer into
+		 * the oldest (next to be freed)FBR entry
+		 */
+		next->addr_hi =3D rx_local->fbr[ring_index]->bus_high[buff_index];
+		next->addr_lo =3D rx_local->fbr[ring_index]->bus_low[buff_index];
+		next->word2 =3D buff_index;
+
+		writel(bump_free_buff_ring(
+				  &rx_local->fbr[ring_index]->local_full,
+				  rx_local->fbr[ring_index]->num_entries - 1),
+		       offset);
+
+		spin_unlock_irqrestore(&adapter->fbr_lock, flags);
+	} else {
+		dev_err(&adapter->pdev->dev,
+			  "%s illegal Buffer Index returned\n", __func__);
+	}
+
+	/* The processing on this RFD is done, so put it back on the tail of
+	 * our list
+	 */
+	spin_lock_irqsave(&adapter->rcv_lock, flags);
+	list_add_tail(&rfd->list_node, &rx_local->recv_list);
+	rx_local->num_ready_recv++;
+	spin_unlock_irqrestore(&adapter->rcv_lock, flags);
+
+	WARN_ON(rx_local->num_ready_recv > rx_local->num_rfd);
+}
+
+/* nic_rx_pkts - Checks the hardware for available packets
+ * @adapter: pointer to our adapter
+ *
+ * Returns rfd, a pointer to our MPRFD.
+ *
+ * Checks the hardware for available packets, using completion ring
+ * If packets are available, it gets an RFD from the recv_list, attach=
es
+ * the packet to it, puts the RFD in the RecvPendList, and also return=
s
+ * the pointer to the RFD.
+ */
+static struct rfd *nic_rx_pkts(struct et131x_adapter *adapter)
+{
+	struct rx_ring *rx_local =3D &adapter->rx_ring;
+	struct rx_status_block *status;
+	struct pkt_stat_desc *psr;
+	struct rfd *rfd;
+	u32 i;
+	u8 *buf;
+	unsigned long flags;
+	struct list_head *element;
+	u8 ring_index;
+	u16 buff_index;
+	u32 len;
+	u32 word0;
+	u32 word1;
+	struct sk_buff *skb;
+
+	/* RX Status block is written by the DMA engine prior to every
+	 * interrupt. It contains the next to be used entry in the Packet
+	 * Status Ring, and also the two Free Buffer rings.
+	 */
+	status =3D rx_local->rx_status_block;
+	word1 =3D status->word1 >> 16;	/* Get the useful bits */
+
+	/* Check the PSR and wrap bits do not match */
+	if ((word1 & 0x1FFF) =3D=3D (rx_local->local_psr_full & 0x1FFF))
+		return NULL; /* Looks like this ring is not updated yet */
+
+	/* The packet status ring indicates that data is available. */
+	psr =3D (struct pkt_stat_desc *) (rx_local->ps_ring_virtaddr) +
+			(rx_local->local_psr_full & 0xFFF);
+
+	/* Grab any information that is required once the PSR is advanced,
+	 * since we can no longer rely on the memory being accurate
+	 */
+	len =3D psr->word1 & 0xFFFF;
+	ring_index =3D (psr->word1 >> 26) & 0x03;
+	buff_index =3D (psr->word1 >> 16) & 0x3FF;
+	word0 =3D psr->word0;
+
+	/* Indicate that we have used this PSR entry. */
+	/* FIXME wrap 12 */
+	add_12bit(&rx_local->local_psr_full, 1);
+	if (
+	  (rx_local->local_psr_full & 0xFFF) > rx_local->psr_num_entries - 1)=
 {
+		/* Clear psr full and toggle the wrap bit */
+		rx_local->local_psr_full &=3D  ~0xFFF;
+		rx_local->local_psr_full ^=3D 0x1000;
+	}
+
+	writel(rx_local->local_psr_full, &adapter->regs->rxdma.psr_full_offse=
t);
+
+	if (ring_index > 1 ||
+		    buff_index > rx_local->fbr[ring_index]->num_entries - 1) {
+		/* Illegal buffer or ring index cannot be used by S/W*/
+		dev_err(&adapter->pdev->dev,
+			"NICRxPkts PSR Entry %d indicates length of %d and/or bad bi(%d)\n"=
,
+			rx_local->local_psr_full & 0xFFF, len, buff_index);
+		return NULL;
+	}
+
+	/* Get and fill the RFD. */
+	spin_lock_irqsave(&adapter->rcv_lock, flags);
+
+	element =3D rx_local->recv_list.next;
+	rfd =3D (struct rfd *) list_entry(element, struct rfd, list_node);
+
+	if (!rfd) {
+		spin_unlock_irqrestore(&adapter->rcv_lock, flags);
+		return NULL;
+	}
+
+	list_del(&rfd->list_node);
+	rx_local->num_ready_recv--;
+
+	spin_unlock_irqrestore(&adapter->rcv_lock, flags);
+
+	rfd->bufferindex =3D buff_index;
+	rfd->ringindex =3D ring_index;
+
+	/* In V1 silicon, there is a bug which screws up filtering of runt
+	 * packets. Therefore runt packet filtering is disabled in the MAC an=
d
+	 * the packets are dropped here. They are also counted here.
+	 */
+	if (len < (NIC_MIN_PACKET_SIZE + 4)) {
+		adapter->stats.rx_other_errs++;
+		len =3D 0;
+	}
+
+	if (len =3D=3D 0) {
+		rfd->len =3D 0;
+		goto out;
+	}
+
+	/* Determine if this is a multicast packet coming in */
+	if ((word0 & ALCATEL_MULTICAST_PKT) &&
+	    !(word0 & ALCATEL_BROADCAST_PKT)) {
+		/* Promiscuous mode and Multicast mode are not mutually
+		 * exclusive as was first thought. I guess Promiscuous is just
+		 * considered a super-set of the other filters. Generally filter
+		 * is 0x2b when in promiscuous mode.
+		 */
+		if ((adapter->packet_filter & ET131X_PACKET_TYPE_MULTICAST)
+		   && !(adapter->packet_filter & ET131X_PACKET_TYPE_PROMISCUOUS)
+		   && !(adapter->packet_filter &
+					ET131X_PACKET_TYPE_ALL_MULTICAST)) {
+			buf =3D rx_local->fbr[ring_index]->virt[buff_index];
+
+			/* Loop through our list to see if the destination
+			 * address of this packet matches one in our list.
+			 */
+			for (i =3D 0; i < adapter->multicast_addr_count; i++) {
+				if (buf[0] =3D=3D adapter->multicast_list[i][0]
+				 && buf[1] =3D=3D adapter->multicast_list[i][1]
+				 && buf[2] =3D=3D adapter->multicast_list[i][2]
+				 && buf[3] =3D=3D adapter->multicast_list[i][3]
+				 && buf[4] =3D=3D adapter->multicast_list[i][4]
+				 && buf[5] =3D=3D adapter->multicast_list[i][5]) {
+					break;
+				}
+			}
+
+			/* If our index is equal to the number of Multicast
+			 * address we have, then this means we did not find this
+			 * packet's matching address in our list. Set the len to
+			 * zero, so we free our RFD when we return from this
+			 * function.
+			 */
+			if (i =3D=3D adapter->multicast_addr_count)
+				len =3D 0;
+		}
+
+		if (len > 0)
+			adapter->stats.multicast_pkts_rcvd++;
+	} else if (word0 & ALCATEL_BROADCAST_PKT) {
+		adapter->stats.broadcast_pkts_rcvd++;
+	} else {
+		/* Not sure what this counter measures in promiscuous mode.
+		 * Perhaps we should check the MAC address to see if it is
+		 * directed to us in promiscuous mode.
+		 */
+		adapter->stats.unicast_pkts_rcvd++;
+	}
+
+	if (len =3D=3D 0) {
+		rfd->len =3D 0;
+		goto out;
+	}
+
+	rfd->len =3D len;
+
+	skb =3D dev_alloc_skb(rfd->len + 2);
+	if (!skb) {
+		dev_err(&adapter->pdev->dev, "Couldn't alloc an SKB for Rx\n");
+		return NULL;
+	}
+
+	adapter->net_stats.rx_bytes +=3D rfd->len;
+
+	memcpy(skb_put(skb, rfd->len),
+	       rx_local->fbr[ring_index]->virt[buff_index],
+	       rfd->len);
+
+	skb->dev =3D adapter->netdev;
+	skb->protocol =3D eth_type_trans(skb, adapter->netdev);
+	skb->ip_summed =3D CHECKSUM_NONE;
+	netif_rx_ni(skb);
+
+out:
+	nic_return_rfd(adapter, rfd);
+	return rfd;
+}
+
+/* et131x_handle_recv_interrupt - Interrupt handler for receive proces=
sing
+ * @adapter: pointer to our adapter
+ *
+ * Assumption, Rcv spinlock has been acquired.
+ */
+static void et131x_handle_recv_interrupt(struct et131x_adapter *adapte=
r)
+{
+	struct rfd *rfd =3D NULL;
+	u32 count =3D 0;
+	bool done =3D true;
+
+	/* Process up to available RFD's */
+	while (count < NUM_PACKETS_HANDLED) {
+		if (list_empty(&adapter->rx_ring.recv_list)) {
+			WARN_ON(adapter->rx_ring.num_ready_recv !=3D 0);
+			done =3D false;
+			break;
+		}
+
+		rfd =3D nic_rx_pkts(adapter);
+
+		if (rfd =3D=3D NULL)
+			break;
+
+		/* Do not receive any packets until a filter has been set.
+		 * Do not receive any packets until we have link.
+		 * If length is zero, return the RFD in order to advance the
+		 * Free buffer ring.
+		 */
+		if (!adapter->packet_filter ||
+		    !netif_carrier_ok(adapter->netdev) ||
+		    rfd->len =3D=3D 0)
+			continue;
+
+		/* Increment the number of packets we received */
+		adapter->net_stats.rx_packets++;
+
+		/* Set the status on the packet, either resources or success */
+		if (adapter->rx_ring.num_ready_recv < RFD_LOW_WATER_MARK) {
+			dev_warn(&adapter->pdev->dev,
+				    "RFD's are running out\n");
+		}
+		count++;
+	}
+
+	if (count =3D=3D NUM_PACKETS_HANDLED || !done) {
+		adapter->rx_ring.unfinished_receives =3D true;
+		writel(PARM_TX_TIME_INT_DEF * NANO_IN_A_MICRO,
+		       &adapter->regs->global.watchdog_timer);
+	} else
+		/* Watchdog timer will disable itself if appropriate. */
+		adapter->rx_ring.unfinished_receives =3D false;
+}
+
+/* et131x_tx_dma_memory_alloc
+ * @adapter: pointer to our private adapter structure
+ *
+ * Returns 0 on success and errno on failure (as defined in errno.h).
+ *
+ * Allocates memory that will be visible both to the device and to the=
 CPU.
+ * The OS will pass us packets, pointers to which we will insert in th=
e Tx
+ * Descriptor queue. The device will read this queue to find the packe=
ts in
+ * memory. The device will update the "status" in memory each time it =
xmits a
+ * packet.
+ */
+static int et131x_tx_dma_memory_alloc(struct et131x_adapter *adapter)
+{
+	int desc_size =3D 0;
+	struct tx_ring *tx_ring =3D &adapter->tx_ring;
+
+	/* Allocate memory for the TCB's (Transmit Control Block) */
+	adapter->tx_ring.tcb_ring =3D
+		kcalloc(NUM_TCB, sizeof(struct tcb), GFP_ATOMIC | GFP_DMA);
+	if (!adapter->tx_ring.tcb_ring) {
+		dev_err(&adapter->pdev->dev, "Cannot alloc memory for TCBs\n");
+		return -ENOMEM;
+	}
+
+	desc_size =3D (sizeof(struct tx_desc) * NUM_DESC_PER_RING_TX);
+	tx_ring->tx_desc_ring =3D
+	    (struct tx_desc *) dma_alloc_coherent(&adapter->pdev->dev,
+						  desc_size,
+						  &tx_ring->tx_desc_ring_pa,
+						  GFP_KERNEL);
+	if (!adapter->tx_ring.tx_desc_ring) {
+		dev_err(&adapter->pdev->dev,
+			"Cannot alloc memory for Tx Ring\n");
+		return -ENOMEM;
+	}
+
+	/* Save physical address
+	 *
+	 * NOTE: dma_alloc_coherent(), used above to alloc DMA regions,
+	 * ALWAYS returns SAC (32-bit) addresses. If DAC (64-bit) addresses
+	 * are ever returned, make sure the high part is retrieved here befor=
e
+	 * storing the adjusted address.
+	 */
+	/* Allocate memory for the Tx status block */
+	tx_ring->tx_status =3D dma_alloc_coherent(&adapter->pdev->dev,
+						    sizeof(u32),
+						    &tx_ring->tx_status_pa,
+						    GFP_KERNEL);
+	if (!adapter->tx_ring.tx_status_pa) {
+		dev_err(&adapter->pdev->dev,
+				  "Cannot alloc memory for Tx status block\n");
+		return -ENOMEM;
+	}
+	return 0;
+}
+
+/* et131x_tx_dma_memory_free - Free all memory allocated within this m=
odule
+ * @adapter: pointer to our private adapter structure
+ *
+ * Returns 0 on success and errno on failure (as defined in errno.h).
+ */
+static void et131x_tx_dma_memory_free(struct et131x_adapter *adapter)
+{
+	int desc_size =3D 0;
+
+	if (adapter->tx_ring.tx_desc_ring) {
+		/* Free memory relating to Tx rings here */
+		desc_size =3D (sizeof(struct tx_desc) * NUM_DESC_PER_RING_TX);
+		dma_free_coherent(&adapter->pdev->dev,
+				    desc_size,
+				    adapter->tx_ring.tx_desc_ring,
+				    adapter->tx_ring.tx_desc_ring_pa);
+		adapter->tx_ring.tx_desc_ring =3D NULL;
+	}
+
+	/* Free memory for the Tx status block */
+	if (adapter->tx_ring.tx_status) {
+		dma_free_coherent(&adapter->pdev->dev,
+				    sizeof(u32),
+				    adapter->tx_ring.tx_status,
+				    adapter->tx_ring.tx_status_pa);
+
+		adapter->tx_ring.tx_status =3D NULL;
+	}
+	/* Free the memory for the tcb structures */
+	kfree(adapter->tx_ring.tcb_ring);
+}
+
+/* nic_send_packet - NIC specific send handler for version B silicon.
+ * @adapter: pointer to our adapter
+ * @tcb: pointer to struct tcb
+ *
+ * Returns 0 or errno.
+ */
+static int nic_send_packet(struct et131x_adapter *adapter, struct tcb =
*tcb)
+{
+	u32 i;
+	struct tx_desc desc[24];	/* 24 x 16 byte */
+	u32 frag =3D 0;
+	u32 thiscopy, remainder;
+	struct sk_buff *skb =3D tcb->skb;
+	u32 nr_frags =3D skb_shinfo(skb)->nr_frags + 1;
+	struct skb_frag_struct *frags =3D &skb_shinfo(skb)->frags[0];
+	unsigned long flags;
+	struct phy_device *phydev =3D adapter->phydev;
+	dma_addr_t dma_addr;
+
+	/* Part of the optimizations of this send routine restrict us to
+	 * sending 24 fragments at a pass.  In practice we should never see
+	 * more than 5 fragments.
+	 *
+	 * NOTE: The older version of this function (below) can handle any
+	 * number of fragments. If needed, we can call this function,
+	 * although it is less efficient.
+	 */
+	if (nr_frags > 23)
+		return -EIO;
+
+	memset(desc, 0, sizeof(struct tx_desc) * (nr_frags + 1));
+
+	for (i =3D 0; i < nr_frags; i++) {
+		/* If there is something in this element, lets get a
+		 * descriptor from the ring and get the necessary data
+		 */
+		if (i =3D=3D 0) {
+			/* If the fragments are smaller than a standard MTU,
+			 * then map them to a single descriptor in the Tx
+			 * Desc ring. However, if they're larger, as is
+			 * possible with support for jumbo packets, then
+			 * split them each across 2 descriptors.
+			 *
+			 * This will work until we determine why the hardware
+			 * doesn't seem to like large fragments.
+			 */
+			if (skb_headlen(skb) <=3D 1514) {
+				/* Low 16bits are length, high is vlan and
+				 * unused currently so zero
+				 */
+				desc[frag].len_vlan =3D skb_headlen(skb);
+				dma_addr =3D dma_map_single(&adapter->pdev->dev,
+							  skb->data,
+							  skb_headlen(skb),
+							  DMA_TO_DEVICE);
+				desc[frag].addr_lo =3D lower_32_bits(dma_addr);
+				desc[frag].addr_hi =3D upper_32_bits(dma_addr);
+				frag++;
+			} else {
+				desc[frag].len_vlan =3D skb_headlen(skb) / 2;
+				dma_addr =3D dma_map_single(&adapter->pdev->dev,
+							 skb->data,
+							 (skb_headlen(skb) / 2),
+							 DMA_TO_DEVICE);
+				desc[frag].addr_lo =3D lower_32_bits(dma_addr);
+				desc[frag].addr_hi =3D upper_32_bits(dma_addr);
+				frag++;
+
+				desc[frag].len_vlan =3D skb_headlen(skb) / 2;
+				dma_addr =3D dma_map_single(&adapter->pdev->dev,
+							 skb->data +
+							 (skb_headlen(skb) / 2),
+							 (skb_headlen(skb) / 2),
+							 DMA_TO_DEVICE);
+				desc[frag].addr_lo =3D lower_32_bits(dma_addr);
+				desc[frag].addr_hi =3D upper_32_bits(dma_addr);
+				frag++;
+			}
+		} else {
+			desc[frag].len_vlan =3D frags[i - 1].size;
+			dma_addr =3D skb_frag_dma_map(&adapter->pdev->dev,
+						    &frags[i - 1],
+						    0,
+						    frags[i - 1].size,
+						    DMA_TO_DEVICE);
+			desc[frag].addr_lo =3D lower_32_bits(dma_addr);
+			desc[frag].addr_hi =3D upper_32_bits(dma_addr);
+			frag++;
+		}
+	}
+
+	if (phydev && phydev->speed =3D=3D SPEED_1000) {
+		if (++adapter->tx_ring.since_irq =3D=3D PARM_TX_NUM_BUFS_DEF) {
+			/* Last element & Interrupt flag */
+			desc[frag - 1].flags =3D
+				    TXDESC_FLAG_INTPROC | TXDESC_FLAG_LASTPKT;
+			adapter->tx_ring.since_irq =3D 0;
+		} else { /* Last element */
+			desc[frag - 1].flags =3D TXDESC_FLAG_LASTPKT;
+		}
+	} else
+		desc[frag - 1].flags =3D
+				    TXDESC_FLAG_INTPROC | TXDESC_FLAG_LASTPKT;
+
+	desc[0].flags |=3D TXDESC_FLAG_FIRSTPKT;
+
+	tcb->index_start =3D adapter->tx_ring.send_idx;
+	tcb->stale =3D 0;
+
+	spin_lock_irqsave(&adapter->send_hw_lock, flags);
+
+	thiscopy =3D NUM_DESC_PER_RING_TX - INDEX10(adapter->tx_ring.send_idx=
);
+
+	if (thiscopy >=3D frag) {
+		remainder =3D 0;
+		thiscopy =3D frag;
+	} else {
+		remainder =3D frag - thiscopy;
+	}
+
+	memcpy(adapter->tx_ring.tx_desc_ring +
+	       INDEX10(adapter->tx_ring.send_idx), desc,
+	       sizeof(struct tx_desc) * thiscopy);
+
+	add_10bit(&adapter->tx_ring.send_idx, thiscopy);
+
+	if (INDEX10(adapter->tx_ring.send_idx) =3D=3D 0 ||
+		  INDEX10(adapter->tx_ring.send_idx) =3D=3D NUM_DESC_PER_RING_TX) {
+		adapter->tx_ring.send_idx &=3D ~ET_DMA10_MASK;
+		adapter->tx_ring.send_idx ^=3D ET_DMA10_WRAP;
+	}
+
+	if (remainder) {
+		memcpy(adapter->tx_ring.tx_desc_ring,
+		       desc + thiscopy,
+		       sizeof(struct tx_desc) * remainder);
+
+		add_10bit(&adapter->tx_ring.send_idx, remainder);
+	}
+
+	if (INDEX10(adapter->tx_ring.send_idx) =3D=3D 0) {
+		if (adapter->tx_ring.send_idx)
+			tcb->index =3D NUM_DESC_PER_RING_TX - 1;
+		else
+			tcb->index =3D ET_DMA10_WRAP|(NUM_DESC_PER_RING_TX - 1);
+	} else
+		tcb->index =3D adapter->tx_ring.send_idx - 1;
+
+	spin_lock(&adapter->tcb_send_qlock);
+
+	if (adapter->tx_ring.send_tail)
+		adapter->tx_ring.send_tail->next =3D tcb;
+	else
+		adapter->tx_ring.send_head =3D tcb;
+
+	adapter->tx_ring.send_tail =3D tcb;
+
+	WARN_ON(tcb->next !=3D NULL);
+
+	adapter->tx_ring.used++;
+
+	spin_unlock(&adapter->tcb_send_qlock);
+
+	/* Write the new write pointer back to the device. */
+	writel(adapter->tx_ring.send_idx,
+	       &adapter->regs->txdma.service_request);
+
+	/* For Gig only, we use Tx Interrupt coalescing.  Enable the software
+	 * timer to wake us up if this packet isn't followed by N more.
+	 */
+	if (phydev && phydev->speed =3D=3D SPEED_1000) {
+		writel(PARM_TX_TIME_INT_DEF * NANO_IN_A_MICRO,
+		       &adapter->regs->global.watchdog_timer);
+	}
+	spin_unlock_irqrestore(&adapter->send_hw_lock, flags);
+
+	return 0;
+}
+
+/* send_packet - Do the work to send a packet
+ * @skb: the packet(s) to send
+ * @adapter: a pointer to the device's private adapter structure
+ *
+ * Return 0 in almost all cases; non-zero value in extreme hard failur=
e only.
+ *
+ * Assumption: Send spinlock has been acquired
+ */
+static int send_packet(struct sk_buff *skb, struct et131x_adapter *ada=
pter)
+{
+	int status;
+	struct tcb *tcb =3D NULL;
+	u16 *shbufva;
+	unsigned long flags;
+
+	/* All packets must have at least a MAC address and a protocol type *=
/
+	if (skb->len < ETH_HLEN)
+		return -EIO;
+
+	/* Get a TCB for this packet */
+	spin_lock_irqsave(&adapter->tcb_ready_qlock, flags);
+
+	tcb =3D adapter->tx_ring.tcb_qhead;
+
+	if (tcb =3D=3D NULL) {
+		spin_unlock_irqrestore(&adapter->tcb_ready_qlock, flags);
+		return -ENOMEM;
+	}
+
+	adapter->tx_ring.tcb_qhead =3D tcb->next;
+
+	if (adapter->tx_ring.tcb_qhead =3D=3D NULL)
+		adapter->tx_ring.tcb_qtail =3D NULL;
+
+	spin_unlock_irqrestore(&adapter->tcb_ready_qlock, flags);
+
+	tcb->skb =3D skb;
+
+	if (skb->data !=3D NULL && skb_headlen(skb) >=3D 6) {
+		shbufva =3D (u16 *) skb->data;
+
+		if ((shbufva[0] =3D=3D 0xffff) &&
+		    (shbufva[1] =3D=3D 0xffff) && (shbufva[2] =3D=3D 0xffff)) {
+			tcb->flags |=3D FMP_DEST_BROAD;
+		} else if ((shbufva[0] & 0x3) =3D=3D 0x0001) {
+			tcb->flags |=3D  FMP_DEST_MULTI;
+		}
+	}
+
+	tcb->next =3D NULL;
+
+	/* Call the NIC specific send handler. */
+	status =3D nic_send_packet(adapter, tcb);
+
+	if (status !=3D 0) {
+		spin_lock_irqsave(&adapter->tcb_ready_qlock, flags);
+
+		if (adapter->tx_ring.tcb_qtail)
+			adapter->tx_ring.tcb_qtail->next =3D tcb;
+		else
+			/* Apparently ready Q is empty. */
+			adapter->tx_ring.tcb_qhead =3D tcb;
+
+		adapter->tx_ring.tcb_qtail =3D tcb;
+		spin_unlock_irqrestore(&adapter->tcb_ready_qlock, flags);
+		return status;
+	}
+	WARN_ON(adapter->tx_ring.used > NUM_TCB);
+	return 0;
+}
+
+/* et131x_send_packets - This function is called by the OS to send pac=
kets
+ * @skb: the packet(s) to send
+ * @netdev:device on which to TX the above packet(s)
+ *
+ * Return 0 in almost all cases; non-zero value in extreme hard failur=
e only
+ */
+static int et131x_send_packets(struct sk_buff *skb, struct net_device =
*netdev)
+{
+	int status =3D 0;
+	struct et131x_adapter *adapter =3D netdev_priv(netdev);
+
+	/* Send these packets
+	 *
+	 * NOTE: The Linux Tx entry point is only given one packet at a time
+	 * to Tx, so the PacketCount and it's array used makes no sense here
+	 */
+
+	/* TCB is not available */
+	if (adapter->tx_ring.used >=3D NUM_TCB) {
+		/* NOTE: If there's an error on send, no need to queue the
+		 * packet under Linux; if we just send an error up to the
+		 * netif layer, it will resend the skb to us.
+		 */
+		status =3D -ENOMEM;
+	} else {
+		/* We need to see if the link is up; if it's not, make the
+		 * netif layer think we're good and drop the packet
+		 */
+		if ((adapter->flags & FMP_ADAPTER_FAIL_SEND_MASK) ||
+					!netif_carrier_ok(netdev)) {
+			dev_kfree_skb_any(skb);
+			skb =3D NULL;
+
+			adapter->net_stats.tx_dropped++;
+		} else {
+			status =3D send_packet(skb, adapter);
+			if (status !=3D 0 && status !=3D -ENOMEM) {
+				/* On any other error, make netif think we're
+				 * OK and drop the packet
+				 */
+				dev_kfree_skb_any(skb);
+				skb =3D NULL;
+				adapter->net_stats.tx_dropped++;
+			}
+		}
+	}
+	return status;
+}
+
+/* free_send_packet - Recycle a struct tcb
+ * @adapter: pointer to our adapter
+ * @tcb: pointer to struct tcb
+ *
+ * Complete the packet if necessary
+ * Assumption - Send spinlock has been acquired
+ */
+static inline void free_send_packet(struct et131x_adapter *adapter,
+						struct tcb *tcb)
+{
+	unsigned long flags;
+	struct tx_desc *desc =3D NULL;
+	struct net_device_stats *stats =3D &adapter->net_stats;
+	u64  dma_addr;
+
+	if (tcb->flags & FMP_DEST_BROAD)
+		atomic_inc(&adapter->stats.broadcast_pkts_xmtd);
+	else if (tcb->flags & FMP_DEST_MULTI)
+		atomic_inc(&adapter->stats.multicast_pkts_xmtd);
+	else
+		atomic_inc(&adapter->stats.unicast_pkts_xmtd);
+
+	if (tcb->skb) {
+		stats->tx_bytes +=3D tcb->skb->len;
+
+		/* Iterate through the TX descriptors on the ring
+		 * corresponding to this packet and umap the fragments
+		 * they point to
+		 */
+		do {
+			desc =3D (struct tx_desc *)
+				    (adapter->tx_ring.tx_desc_ring +
+						INDEX10(tcb->index_start));
+
+			dma_addr =3D desc->addr_lo;
+			dma_addr |=3D (u64)desc->addr_hi << 32;
+
+			dma_unmap_single(&adapter->pdev->dev,
+					 dma_addr,
+					 desc->len_vlan, DMA_TO_DEVICE);
+
+			add_10bit(&tcb->index_start, 1);
+			if (INDEX10(tcb->index_start) >=3D
+							NUM_DESC_PER_RING_TX) {
+				tcb->index_start &=3D ~ET_DMA10_MASK;
+				tcb->index_start ^=3D ET_DMA10_WRAP;
+			}
+		} while (desc !=3D (adapter->tx_ring.tx_desc_ring +
+				INDEX10(tcb->index)));
+
+		dev_kfree_skb_any(tcb->skb);
+	}
+
+	memset(tcb, 0, sizeof(struct tcb));
+
+	/* Add the TCB to the Ready Q */
+	spin_lock_irqsave(&adapter->tcb_ready_qlock, flags);
+
+	adapter->net_stats.tx_packets++;
+
+	if (adapter->tx_ring.tcb_qtail)
+		adapter->tx_ring.tcb_qtail->next =3D tcb;
+	else
+		/* Apparently ready Q is empty. */
+		adapter->tx_ring.tcb_qhead =3D tcb;
+
+	adapter->tx_ring.tcb_qtail =3D tcb;
+
+	spin_unlock_irqrestore(&adapter->tcb_ready_qlock, flags);
+	WARN_ON(adapter->tx_ring.used < 0);
+}
+
+/* et131x_free_busy_send_packets - Free and complete the stopped activ=
e sends
+ * @adapter: pointer to our adapter
+ *
+ * Assumption - Send spinlock has been acquired
+ */
+static void et131x_free_busy_send_packets(struct et131x_adapter *adapt=
er)
+{
+	struct tcb *tcb;
+	unsigned long flags;
+	u32 freed =3D 0;
+
+	/* Any packets being sent? Check the first TCB on the send list */
+	spin_lock_irqsave(&adapter->tcb_send_qlock, flags);
+
+	tcb =3D adapter->tx_ring.send_head;
+
+	while (tcb !=3D NULL && freed < NUM_TCB) {
+		struct tcb *next =3D tcb->next;
+
+		adapter->tx_ring.send_head =3D next;
+
+		if (next =3D=3D NULL)
+			adapter->tx_ring.send_tail =3D NULL;
+
+		adapter->tx_ring.used--;
+
+		spin_unlock_irqrestore(&adapter->tcb_send_qlock, flags);
+
+		freed++;
+		free_send_packet(adapter, tcb);
+
+		spin_lock_irqsave(&adapter->tcb_send_qlock, flags);
+
+		tcb =3D adapter->tx_ring.send_head;
+	}
+
+	WARN_ON(freed =3D=3D NUM_TCB);
+
+	spin_unlock_irqrestore(&adapter->tcb_send_qlock, flags);
+
+	adapter->tx_ring.used =3D 0;
+}
+
+/* et131x_handle_send_interrupt - Interrupt handler for sending proces=
sing
+ * @adapter: pointer to our adapter
+ *
+ * Re-claim the send resources, complete sends and get more to send fr=
om
+ * the send wait queue.
+ *
+ * Assumption - Send spinlock has been acquired
+ */
+static void et131x_handle_send_interrupt(struct et131x_adapter *adapte=
r)
+{
+	unsigned long flags;
+	u32 serviced;
+	struct tcb *tcb;
+	u32 index;
+
+	serviced =3D readl(&adapter->regs->txdma.new_service_complete);
+	index =3D INDEX10(serviced);
+
+	/* Has the ring wrapped?  Process any descriptors that do not have
+	 * the same "wrap" indicator as the current completion indicator
+	 */
+	spin_lock_irqsave(&adapter->tcb_send_qlock, flags);
+
+	tcb =3D adapter->tx_ring.send_head;
+
+	while (tcb &&
+	       ((serviced ^ tcb->index) & ET_DMA10_WRAP) &&
+	       index < INDEX10(tcb->index)) {
+		adapter->tx_ring.used--;
+		adapter->tx_ring.send_head =3D tcb->next;
+		if (tcb->next =3D=3D NULL)
+			adapter->tx_ring.send_tail =3D NULL;
+
+		spin_unlock_irqrestore(&adapter->tcb_send_qlock, flags);
+		free_send_packet(adapter, tcb);
+		spin_lock_irqsave(&adapter->tcb_send_qlock, flags);
+
+		/* Goto the next packet */
+		tcb =3D adapter->tx_ring.send_head;
+	}
+	while (tcb &&
+	       !((serviced ^ tcb->index) & ET_DMA10_WRAP)
+	       && index > (tcb->index & ET_DMA10_MASK)) {
+		adapter->tx_ring.used--;
+		adapter->tx_ring.send_head =3D tcb->next;
+		if (tcb->next =3D=3D NULL)
+			adapter->tx_ring.send_tail =3D NULL;
+
+		spin_unlock_irqrestore(&adapter->tcb_send_qlock, flags);
+		free_send_packet(adapter, tcb);
+		spin_lock_irqsave(&adapter->tcb_send_qlock, flags);
+
+		/* Goto the next packet */
+		tcb =3D adapter->tx_ring.send_head;
+	}
+
+	/* Wake up the queue when we hit a low-water mark */
+	if (adapter->tx_ring.used <=3D NUM_TCB / 3)
+		netif_wake_queue(adapter->netdev);
+
+	spin_unlock_irqrestore(&adapter->tcb_send_qlock, flags);
+}
+
+static int et131x_get_settings(struct net_device *netdev,
+			       struct ethtool_cmd *cmd)
+{
+	struct et131x_adapter *adapter =3D netdev_priv(netdev);
+
+	return phy_ethtool_gset(adapter->phydev, cmd);
+}
+
+static int et131x_set_settings(struct net_device *netdev,
+			       struct ethtool_cmd *cmd)
+{
+	struct et131x_adapter *adapter =3D netdev_priv(netdev);
+
+	return phy_ethtool_sset(adapter->phydev, cmd);
+}
+
+static int et131x_get_regs_len(struct net_device *netdev)
+{
+#define ET131X_REGS_LEN 256
+	return ET131X_REGS_LEN * sizeof(u32);
+}
+
+static void et131x_get_regs(struct net_device *netdev,
+			    struct ethtool_regs *regs, void *regs_data)
+{
+	struct et131x_adapter *adapter =3D netdev_priv(netdev);
+	struct address_map __iomem *aregs =3D adapter->regs;
+	u32 *regs_buff =3D regs_data;
+	u32 num =3D 0;
+	u16 tmp;
+
+	memset(regs_data, 0, et131x_get_regs_len(netdev));
+
+	regs->version =3D (1 << 24) | (adapter->pdev->revision << 16) |
+			adapter->pdev->device;
+
+	/* PHY regs */
+	et131x_mii_read(adapter, MII_BMCR, &tmp);
+	regs_buff[num++] =3D tmp;
+	et131x_mii_read(adapter, MII_BMSR, &tmp);
+	regs_buff[num++] =3D tmp;
+	et131x_mii_read(adapter, MII_PHYSID1, &tmp);
+	regs_buff[num++] =3D tmp;
+	et131x_mii_read(adapter, MII_PHYSID2, &tmp);
+	regs_buff[num++] =3D tmp;
+	et131x_mii_read(adapter, MII_ADVERTISE, &tmp);
+	regs_buff[num++] =3D tmp;
+	et131x_mii_read(adapter, MII_LPA, &tmp);
+	regs_buff[num++] =3D tmp;
+	et131x_mii_read(adapter, MII_EXPANSION, &tmp);
+	regs_buff[num++] =3D tmp;
+	/* Autoneg next page transmit reg */
+	et131x_mii_read(adapter, 0x07, &tmp);
+	regs_buff[num++] =3D tmp;
+	/* Link partner next page reg */
+	et131x_mii_read(adapter, 0x08, &tmp);
+	regs_buff[num++] =3D tmp;
+	et131x_mii_read(adapter, MII_CTRL1000, &tmp);
+	regs_buff[num++] =3D tmp;
+	et131x_mii_read(adapter, MII_STAT1000, &tmp);
+	regs_buff[num++] =3D tmp;
+	et131x_mii_read(adapter, 0x0b, &tmp);
+	regs_buff[num++] =3D tmp;
+	et131x_mii_read(adapter, 0x0c, &tmp);
+	regs_buff[num++] =3D tmp;
+	et131x_mii_read(adapter, MII_MMD_CTRL, &tmp);
+	regs_buff[num++] =3D tmp;
+	et131x_mii_read(adapter, MII_MMD_DATA, &tmp);
+	regs_buff[num++] =3D tmp;
+	et131x_mii_read(adapter, MII_ESTATUS, &tmp);
+	regs_buff[num++] =3D tmp;
+
+	et131x_mii_read(adapter, PHY_INDEX_REG, &tmp);
+	regs_buff[num++] =3D tmp;
+	et131x_mii_read(adapter, PHY_DATA_REG, &tmp);
+	regs_buff[num++] =3D tmp;
+	et131x_mii_read(adapter, PHY_MPHY_CONTROL_REG, &tmp);
+	regs_buff[num++] =3D tmp;
+	et131x_mii_read(adapter, PHY_LOOPBACK_CONTROL, &tmp);
+	regs_buff[num++] =3D tmp;
+	et131x_mii_read(adapter, PHY_LOOPBACK_CONTROL + 1, &tmp);
+	regs_buff[num++] =3D tmp;
+
+	et131x_mii_read(adapter, PHY_REGISTER_MGMT_CONTROL, &tmp);
+	regs_buff[num++] =3D tmp;
+	et131x_mii_read(adapter, PHY_CONFIG, &tmp);
+	regs_buff[num++] =3D tmp;
+	et131x_mii_read(adapter, PHY_PHY_CONTROL, &tmp);
+	regs_buff[num++] =3D tmp;
+	et131x_mii_read(adapter, PHY_INTERRUPT_MASK, &tmp);
+	regs_buff[num++] =3D tmp;
+	et131x_mii_read(adapter, PHY_INTERRUPT_STATUS, &tmp);
+	regs_buff[num++] =3D tmp;
+	et131x_mii_read(adapter, PHY_PHY_STATUS, &tmp);
+	regs_buff[num++] =3D tmp;
+	et131x_mii_read(adapter, PHY_LED_1, &tmp);
+	regs_buff[num++] =3D tmp;
+	et131x_mii_read(adapter, PHY_LED_2, &tmp);
+	regs_buff[num++] =3D tmp;
+
+	/* Global regs */
+	regs_buff[num++] =3D readl(&aregs->global.txq_start_addr);
+	regs_buff[num++] =3D readl(&aregs->global.txq_end_addr);
+	regs_buff[num++] =3D readl(&aregs->global.rxq_start_addr);
+	regs_buff[num++] =3D readl(&aregs->global.rxq_end_addr);
+	regs_buff[num++] =3D readl(&aregs->global.pm_csr);
+	regs_buff[num++] =3D adapter->stats.interrupt_status;
+	regs_buff[num++] =3D readl(&aregs->global.int_mask);
+	regs_buff[num++] =3D readl(&aregs->global.int_alias_clr_en);
+	regs_buff[num++] =3D readl(&aregs->global.int_status_alias);
+	regs_buff[num++] =3D readl(&aregs->global.sw_reset);
+	regs_buff[num++] =3D readl(&aregs->global.slv_timer);
+	regs_buff[num++] =3D readl(&aregs->global.msi_config);
+	regs_buff[num++] =3D readl(&aregs->global.loopback);
+	regs_buff[num++] =3D readl(&aregs->global.watchdog_timer);
+
+	/* TXDMA regs */
+	regs_buff[num++] =3D readl(&aregs->txdma.csr);
+	regs_buff[num++] =3D readl(&aregs->txdma.pr_base_hi);
+	regs_buff[num++] =3D readl(&aregs->txdma.pr_base_lo);
+	regs_buff[num++] =3D readl(&aregs->txdma.pr_num_des);
+	regs_buff[num++] =3D readl(&aregs->txdma.txq_wr_addr);
+	regs_buff[num++] =3D readl(&aregs->txdma.txq_wr_addr_ext);
+	regs_buff[num++] =3D readl(&aregs->txdma.txq_rd_addr);
+	regs_buff[num++] =3D readl(&aregs->txdma.dma_wb_base_hi);
+	regs_buff[num++] =3D readl(&aregs->txdma.dma_wb_base_lo);
+	regs_buff[num++] =3D readl(&aregs->txdma.service_request);
+	regs_buff[num++] =3D readl(&aregs->txdma.service_complete);
+	regs_buff[num++] =3D readl(&aregs->txdma.cache_rd_index);
+	regs_buff[num++] =3D readl(&aregs->txdma.cache_wr_index);
+	regs_buff[num++] =3D readl(&aregs->txdma.tx_dma_error);
+	regs_buff[num++] =3D readl(&aregs->txdma.desc_abort_cnt);
+	regs_buff[num++] =3D readl(&aregs->txdma.payload_abort_cnt);
+	regs_buff[num++] =3D readl(&aregs->txdma.writeback_abort_cnt);
+	regs_buff[num++] =3D readl(&aregs->txdma.desc_timeout_cnt);
+	regs_buff[num++] =3D readl(&aregs->txdma.payload_timeout_cnt);
+	regs_buff[num++] =3D readl(&aregs->txdma.writeback_timeout_cnt);
+	regs_buff[num++] =3D readl(&aregs->txdma.desc_error_cnt);
+	regs_buff[num++] =3D readl(&aregs->txdma.payload_error_cnt);
+	regs_buff[num++] =3D readl(&aregs->txdma.writeback_error_cnt);
+	regs_buff[num++] =3D readl(&aregs->txdma.dropped_tlp_cnt);
+	regs_buff[num++] =3D readl(&aregs->txdma.new_service_complete);
+	regs_buff[num++] =3D readl(&aregs->txdma.ethernet_packet_cnt);
+
+	/* RXDMA regs */
+	regs_buff[num++] =3D readl(&aregs->rxdma.csr);
+	regs_buff[num++] =3D readl(&aregs->rxdma.dma_wb_base_hi);
+	regs_buff[num++] =3D readl(&aregs->rxdma.dma_wb_base_lo);
+	regs_buff[num++] =3D readl(&aregs->rxdma.num_pkt_done);
+	regs_buff[num++] =3D readl(&aregs->rxdma.max_pkt_time);
+	regs_buff[num++] =3D readl(&aregs->rxdma.rxq_rd_addr);
+	regs_buff[num++] =3D readl(&aregs->rxdma.rxq_rd_addr_ext);
+	regs_buff[num++] =3D readl(&aregs->rxdma.rxq_wr_addr);
+	regs_buff[num++] =3D readl(&aregs->rxdma.psr_base_hi);
+	regs_buff[num++] =3D readl(&aregs->rxdma.psr_base_lo);
+	regs_buff[num++] =3D readl(&aregs->rxdma.psr_num_des);
+	regs_buff[num++] =3D readl(&aregs->rxdma.psr_avail_offset);
+	regs_buff[num++] =3D readl(&aregs->rxdma.psr_full_offset);
+	regs_buff[num++] =3D readl(&aregs->rxdma.psr_access_index);
+	regs_buff[num++] =3D readl(&aregs->rxdma.psr_min_des);
+	regs_buff[num++] =3D readl(&aregs->rxdma.fbr0_base_lo);
+	regs_buff[num++] =3D readl(&aregs->rxdma.fbr0_base_hi);
+	regs_buff[num++] =3D readl(&aregs->rxdma.fbr0_num_des);
+	regs_buff[num++] =3D readl(&aregs->rxdma.fbr0_avail_offset);
+	regs_buff[num++] =3D readl(&aregs->rxdma.fbr0_full_offset);
+	regs_buff[num++] =3D readl(&aregs->rxdma.fbr0_rd_index);
+	regs_buff[num++] =3D readl(&aregs->rxdma.fbr0_min_des);
+	regs_buff[num++] =3D readl(&aregs->rxdma.fbr1_base_lo);
+	regs_buff[num++] =3D readl(&aregs->rxdma.fbr1_base_hi);
+	regs_buff[num++] =3D readl(&aregs->rxdma.fbr1_num_des);
+	regs_buff[num++] =3D readl(&aregs->rxdma.fbr1_avail_offset);
+	regs_buff[num++] =3D readl(&aregs->rxdma.fbr1_full_offset);
+	regs_buff[num++] =3D readl(&aregs->rxdma.fbr1_rd_index);
+	regs_buff[num++] =3D readl(&aregs->rxdma.fbr1_min_des);
+}
+
+static void et131x_get_drvinfo(struct net_device *netdev,
+			       struct ethtool_drvinfo *info)
+{
+	struct et131x_adapter *adapter =3D netdev_priv(netdev);
+
+	strlcpy(info->driver, DRIVER_NAME, sizeof(info->driver));
+	strlcpy(info->version, DRIVER_VERSION, sizeof(info->version));
+	strlcpy(info->bus_info, pci_name(adapter->pdev),
+		sizeof(info->bus_info));
+}
+
+static struct ethtool_ops et131x_ethtool_ops =3D {
+	.get_settings	=3D et131x_get_settings,
+	.set_settings	=3D et131x_set_settings,
+	.get_drvinfo	=3D et131x_get_drvinfo,
+	.get_regs_len	=3D et131x_get_regs_len,
+	.get_regs	=3D et131x_get_regs,
+	.get_link	=3D ethtool_op_get_link,
+};
+
+/* et131x_hwaddr_init - set up the MAC Address on the ET1310
+ * @adapter: pointer to our private adapter structure
+ */
+static void et131x_hwaddr_init(struct et131x_adapter *adapter)
+{
+	/* If have our default mac from init and no mac address from
+	 * EEPROM then we need to generate the last octet and set it on the
+	 * device
+	 */
+	if (is_zero_ether_addr(adapter->rom_addr)) {
+		/* We need to randomly generate the last octet so we
+		 * decrease our chances of setting the mac address to
+		 * same as another one of our cards in the system
+		 */
+		get_random_bytes(&adapter->addr[5], 1);
+		/* We have the default value in the register we are
+		 * working with so we need to copy the current
+		 * address into the permanent address
+		 */
+		memcpy(adapter->rom_addr,
+			adapter->addr, ETH_ALEN);
+	} else {
+		/* We do not have an override address, so set the
+		 * current address to the permanent address and add
+		 * it to the device
+		 */
+		memcpy(adapter->addr,
+		       adapter->rom_addr, ETH_ALEN);
+	}
+}
+
+/* et131x_pci_init	 - initial PCI setup
+ * @adapter: pointer to our private adapter structure
+ * @pdev: our PCI device
+ *
+ * Perform the initial setup of PCI registers and if possible initiali=
se
+ * the MAC address. At this point the I/O registers have yet to be map=
ped
+ */
+static int et131x_pci_init(struct et131x_adapter *adapter,
+						struct pci_dev *pdev)
+{
+	u16 max_payload;
+	int i, rc;
+
+	rc =3D et131x_init_eeprom(adapter);
+	if (rc < 0)
+		goto out;
+
+	if (!pci_is_pcie(pdev)) {
+		dev_err(&pdev->dev, "Missing PCIe capabilities\n");
+		goto err_out;
+	}
+
+	/* Let's set up the PORT LOGIC Register.  First we need to know what
+	 * the max_payload_size is
+	 */
+	if (pcie_capability_read_word(pdev, PCI_EXP_DEVCAP, &max_payload)) {
+		dev_err(&pdev->dev,
+		    "Could not read PCI config space for Max Payload Size\n");
+		goto err_out;
+	}
+
+	/* Program the Ack/Nak latency and replay timers */
+	max_payload &=3D 0x07;
+
+	if (max_payload < 2) {
+		static const u16 acknak[2] =3D { 0x76, 0xD0 };
+		static const u16 replay[2] =3D { 0x1E0, 0x2ED };
+
+		if (pci_write_config_word(pdev, ET1310_PCI_ACK_NACK,
+					       acknak[max_payload])) {
+			dev_err(&pdev->dev,
+			  "Could not write PCI config space for ACK/NAK\n");
+			goto err_out;
+		}
+		if (pci_write_config_word(pdev, ET1310_PCI_REPLAY,
+					       replay[max_payload])) {
+			dev_err(&pdev->dev,
+			  "Could not write PCI config space for Replay Timer\n");
+			goto err_out;
+		}
+	}
+
+	/* l0s and l1 latency timers.  We are using default values.
+	 * Representing 001 for L0s and 010 for L1
+	 */
+	if (pci_write_config_byte(pdev, ET1310_PCI_L0L1LATENCY, 0x11)) {
+		dev_err(&pdev->dev,
+		  "Could not write PCI config space for Latency Timers\n");
+		goto err_out;
+	}
+
+	/* Change the max read size to 2k */
+	if (pcie_capability_clear_and_set_word(pdev, PCI_EXP_DEVCTL,
+				PCI_EXP_DEVCTL_READRQ, 0x4 << 12)) {
+		dev_err(&pdev->dev,
+			"Couldn't change PCI config space for Max read size\n");
+		goto err_out;
+	}
+
+	/* Get MAC address from config space if an eeprom exists, otherwise
+	 * the MAC address there will not be valid
+	 */
+	if (!adapter->has_eeprom) {
+		et131x_hwaddr_init(adapter);
+		return 0;
+	}
+
+	for (i =3D 0; i < ETH_ALEN; i++) {
+		if (pci_read_config_byte(pdev, ET1310_PCI_MAC_ADDRESS + i,
+					adapter->rom_addr + i)) {
+			dev_err(&pdev->dev, "Could not read PCI config space for MAC addres=
s\n");
+			goto err_out;
+		}
+	}
+	memcpy(adapter->addr, adapter->rom_addr, ETH_ALEN);
+out:
+	return rc;
+err_out:
+	rc =3D -EIO;
+	goto out;
+}
+
+/* et131x_error_timer_handler
+ * @data: timer-specific variable; here a pointer to our adapter struc=
ture
+ *
+ * The routine called when the error timer expires, to track the numbe=
r of
+ * recurring errors.
+ */
+static void et131x_error_timer_handler(unsigned long data)
+{
+	struct et131x_adapter *adapter =3D (struct et131x_adapter *) data;
+	struct phy_device *phydev =3D adapter->phydev;
+
+	if (et1310_in_phy_coma(adapter)) {
+		/* Bring the device immediately out of coma, to
+		 * prevent it from sleeping indefinitely, this
+		 * mechanism could be improved!
+		 */
+		et1310_disable_phy_coma(adapter);
+		adapter->boot_coma =3D 20;
+	} else {
+		et1310_update_macstat_host_counters(adapter);
+	}
+
+	if (!phydev->link && adapter->boot_coma < 11)
+		adapter->boot_coma++;
+
+	if (adapter->boot_coma =3D=3D 10) {
+		if (!phydev->link) {
+			if (!et1310_in_phy_coma(adapter)) {
+				/* NOTE - This was originally a 'sync with
+				 *  interrupt'. How to do that under Linux?
+				 */
+				et131x_enable_interrupts(adapter);
+				et1310_enable_phy_coma(adapter);
+			}
+		}
+	}
+
+	/* This is a periodic timer, so reschedule */
+	mod_timer(&adapter->error_timer, jiffies + TX_ERROR_PERIOD * HZ / 100=
0);
+}
+
+/* et131x_adapter_memory_free - Free all memory allocated for use by T=
x & Rx
+ * @adapter: pointer to our private adapter structure
+ */
+static void et131x_adapter_memory_free(struct et131x_adapter *adapter)
+{
+	/* Free DMA memory */
+	et131x_tx_dma_memory_free(adapter);
+	et131x_rx_dma_memory_free(adapter);
+}
+
+/* et131x_adapter_memory_alloc
+ * @adapter: pointer to our private adapter structure
+ *
+ * Returns 0 on success, errno on failure (as defined in errno.h).
+ *
+ * Allocate all the memory blocks for send, receive and others.
+ */
+static int et131x_adapter_memory_alloc(struct et131x_adapter *adapter)
+{
+	int status;
+
+	/* Allocate memory for the Tx Ring */
+	status =3D et131x_tx_dma_memory_alloc(adapter);
+	if (status !=3D 0) {
+		dev_err(&adapter->pdev->dev,
+			  "et131x_tx_dma_memory_alloc FAILED\n");
+		return status;
+	}
+	/* Receive buffer memory allocation */
+	status =3D et131x_rx_dma_memory_alloc(adapter);
+	if (status !=3D 0) {
+		dev_err(&adapter->pdev->dev,
+			  "et131x_rx_dma_memory_alloc FAILED\n");
+		et131x_tx_dma_memory_free(adapter);
+		return status;
+	}
+
+	/* Init receive data structures */
+	status =3D et131x_init_recv(adapter);
+	if (status) {
+		dev_err(&adapter->pdev->dev,
+			"et131x_init_recv FAILED\n");
+		et131x_adapter_memory_free(adapter);
+	}
+	return status;
+}
+
+static void et131x_adjust_link(struct net_device *netdev)
+{
+	struct et131x_adapter *adapter =3D netdev_priv(netdev);
+	struct  phy_device *phydev =3D adapter->phydev;
+
+	if (phydev && phydev->link !=3D adapter->link) {
+		/* Check to see if we are in coma mode and if
+		 * so, disable it because we will not be able
+		 * to read PHY values until we are out.
+		 */
+		if (et1310_in_phy_coma(adapter))
+			et1310_disable_phy_coma(adapter);
+
+		adapter->link =3D phydev->link;
+		phy_print_status(phydev);
+
+		if (phydev->link) {
+			adapter->boot_coma =3D 20;
+			if (phydev && phydev->speed =3D=3D SPEED_10) {
+				/* NOTE - Is there a way to query this without
+				 * TruePHY?
+				 * && TRU_QueryCoreType(adapter->hTruePhy, 0)=3D=3D
+				 * EMI_TRUEPHY_A13O) {
+				 */
+				u16 register18;
+
+				et131x_mii_read(adapter, PHY_MPHY_CONTROL_REG,
+						 &register18);
+				et131x_mii_write(adapter, PHY_MPHY_CONTROL_REG,
+						 register18 | 0x4);
+				et131x_mii_write(adapter, PHY_INDEX_REG,
+						 register18 | 0x8402);
+				et131x_mii_write(adapter, PHY_DATA_REG,
+						 register18 | 511);
+				et131x_mii_write(adapter, PHY_MPHY_CONTROL_REG,
+						 register18);
+			}
+
+			et1310_config_flow_control(adapter);
+
+			if (phydev && phydev->speed =3D=3D SPEED_1000 &&
+					adapter->registry_jumbo_packet > 2048) {
+				u16 reg;
+
+				et131x_mii_read(adapter, PHY_CONFIG, &reg);
+				reg &=3D ~ET_PHY_CONFIG_TX_FIFO_DEPTH;
+				reg |=3D ET_PHY_CONFIG_FIFO_DEPTH_32;
+				et131x_mii_write(adapter, PHY_CONFIG, reg);
+			}
+
+			et131x_set_rx_dma_timer(adapter);
+			et1310_config_mac_regs2(adapter);
+		} else {
+			adapter->boot_coma =3D 0;
+
+			if (phydev->speed =3D=3D SPEED_10) {
+				/* NOTE - Is there a way to query this without
+				 * TruePHY?
+				 * && TRU_QueryCoreType(adapter->hTruePhy, 0) =3D=3D
+				 * EMI_TRUEPHY_A13O)
+				 */
+				u16 register18;
+
+				et131x_mii_read(adapter, PHY_MPHY_CONTROL_REG,
+						 &register18);
+				et131x_mii_write(adapter, PHY_MPHY_CONTROL_REG,
+						 register18 | 0x4);
+				et131x_mii_write(adapter, PHY_INDEX_REG,
+						 register18 | 0x8402);
+				et131x_mii_write(adapter, PHY_DATA_REG,
+						 register18 | 511);
+				et131x_mii_write(adapter, PHY_MPHY_CONTROL_REG,
+						 register18);
+			}
+
+			/* Free the packets being actively sent & stopped */
+			et131x_free_busy_send_packets(adapter);
+
+			/* Re-initialize the send structures */
+			et131x_init_send(adapter);
+
+			/* Bring the device back to the state it was during
+			 * init prior to autonegotiation being complete. This
+			 * way, when we get the auto-neg complete interrupt,
+			 * we can complete init by calling config_mac_regs2.
+			 */
+			et131x_soft_reset(adapter);
+
+			/* Setup ET1310 as per the documentation */
+			et131x_adapter_setup(adapter);
+
+			/* perform reset of tx/rx */
+			et131x_disable_txrx(netdev);
+			et131x_enable_txrx(netdev);
+		}
+
+	}
+}
+
+static int et131x_mii_probe(struct net_device *netdev)
+{
+	struct et131x_adapter *adapter =3D netdev_priv(netdev);
+	struct  phy_device *phydev =3D NULL;
+
+	phydev =3D phy_find_first(adapter->mii_bus);
+	if (!phydev) {
+		dev_err(&adapter->pdev->dev, "no PHY found\n");
+		return -ENODEV;
+	}
+
+	phydev =3D phy_connect(netdev, dev_name(&phydev->dev),
+			     &et131x_adjust_link, PHY_INTERFACE_MODE_MII);
+
+	if (IS_ERR(phydev)) {
+		dev_err(&adapter->pdev->dev, "Could not attach to PHY\n");
+		return PTR_ERR(phydev);
+	}
+
+	phydev->supported &=3D (SUPPORTED_10baseT_Half
+				| SUPPORTED_10baseT_Full
+				| SUPPORTED_100baseT_Half
+				| SUPPORTED_100baseT_Full
+				| SUPPORTED_Autoneg
+				| SUPPORTED_MII
+				| SUPPORTED_TP);
+
+	if (adapter->pdev->device !=3D ET131X_PCI_DEVICE_ID_FAST)
+		phydev->supported |=3D SUPPORTED_1000baseT_Full;
+
+	phydev->advertising =3D phydev->supported;
+	adapter->phydev =3D phydev;
+
+	dev_info(&adapter->pdev->dev, "attached PHY driver [%s] (mii_bus:phy_=
addr=3D%s)\n",
+		 phydev->drv->name, dev_name(&phydev->dev));
+
+	return 0;
+}
+
+/* et131x_adapter_init
+ * @adapter: pointer to the private adapter struct
+ * @pdev: pointer to the PCI device
+ *
+ * Initialize the data structures for the et131x_adapter object and li=
nk
+ * them together with the platform provided device structures.
+ */
+static struct et131x_adapter *et131x_adapter_init(struct net_device *n=
etdev,
+		struct pci_dev *pdev)
+{
+	static const u8 default_mac[] =3D { 0x00, 0x05, 0x3d, 0x00, 0x02, 0x0=
0 };
+
+	struct et131x_adapter *adapter;
+
+	/* Allocate private adapter struct and copy in relevant information *=
/
+	adapter =3D netdev_priv(netdev);
+	adapter->pdev =3D pci_dev_get(pdev);
+	adapter->netdev =3D netdev;
+
+	/* Initialize spinlocks here */
+	spin_lock_init(&adapter->lock);
+	spin_lock_init(&adapter->tcb_send_qlock);
+	spin_lock_init(&adapter->tcb_ready_qlock);
+	spin_lock_init(&adapter->send_hw_lock);
+	spin_lock_init(&adapter->rcv_lock);
+	spin_lock_init(&adapter->rcv_pend_lock);
+	spin_lock_init(&adapter->fbr_lock);
+	spin_lock_init(&adapter->phy_lock);
+
+	adapter->registry_jumbo_packet =3D 1514;	/* 1514-9216 */
+
+	/* Set the MAC address to a default */
+	memcpy(adapter->addr, default_mac, ETH_ALEN);
+
+	return adapter;
+}
+
+/* et131x_pci_remove
+ * @pdev: a pointer to the device's pci_dev structure
+ *
+ * Registered in the pci_driver structure, this function is called whe=
n the
+ * PCI subsystem detects that a PCI device which matches the informati=
on
+ * contained in the pci_device_id table has been removed.
+ */
+static void et131x_pci_remove(struct pci_dev *pdev)
+{
+	struct net_device *netdev =3D pci_get_drvdata(pdev);
+	struct et131x_adapter *adapter =3D netdev_priv(netdev);
+
+	unregister_netdev(netdev);
+	phy_disconnect(adapter->phydev);
+	mdiobus_unregister(adapter->mii_bus);
+	kfree(adapter->mii_bus->irq);
+	mdiobus_free(adapter->mii_bus);
+
+	et131x_adapter_memory_free(adapter);
+	iounmap(adapter->regs);
+	pci_dev_put(pdev);
+
+	free_netdev(netdev);
+	pci_release_regions(pdev);
+	pci_disable_device(pdev);
+}
+
+/* et131x_up - Bring up a device for use.
+ * @netdev: device to be opened
+ */
+static void et131x_up(struct net_device *netdev)
+{
+	struct et131x_adapter *adapter =3D netdev_priv(netdev);
+
+	et131x_enable_txrx(netdev);
+	phy_start(adapter->phydev);
+}
+
+/* et131x_down - Bring down the device
+ * @netdev: device to be brought down
+ */
+static void et131x_down(struct net_device *netdev)
+{
+	struct et131x_adapter *adapter =3D netdev_priv(netdev);
+
+	/* Save the timestamp for the TX watchdog, prevent a timeout */
+	netdev->trans_start =3D jiffies;
+
+	phy_stop(adapter->phydev);
+	et131x_disable_txrx(netdev);
+}
+
+#ifdef CONFIG_PM_SLEEP
+static int et131x_suspend(struct device *dev)
+{
+	struct pci_dev *pdev =3D to_pci_dev(dev);
+	struct net_device *netdev =3D pci_get_drvdata(pdev);
+
+	if (netif_running(netdev)) {
+		netif_device_detach(netdev);
+		et131x_down(netdev);
+		pci_save_state(pdev);
+	}
+
+	return 0;
+}
+
+static int et131x_resume(struct device *dev)
+{
+	struct pci_dev *pdev =3D to_pci_dev(dev);
+	struct net_device *netdev =3D pci_get_drvdata(pdev);
+
+	if (netif_running(netdev)) {
+		pci_restore_state(pdev);
+		et131x_up(netdev);
+		netif_device_attach(netdev);
+	}
+
+	return 0;
+}
+
+static SIMPLE_DEV_PM_OPS(et131x_pm_ops, et131x_suspend, et131x_resume)=
;
+#define ET131X_PM_OPS (&et131x_pm_ops)
+#else
+#define ET131X_PM_OPS NULL
+#endif
+
+/* et131x_isr - The Interrupt Service Routine for the driver.
+ * @irq: the IRQ on which the interrupt was received.
+ * @dev_id: device-specific info (here a pointer to a net_device struc=
t)
+ *
+ * Returns a value indicating if the interrupt was handled.
+ */
+static irqreturn_t et131x_isr(int irq, void *dev_id)
+{
+	bool handled =3D true;
+	struct net_device *netdev =3D (struct net_device *)dev_id;
+	struct et131x_adapter *adapter =3D NULL;
+	u32 status;
+
+	if (!netif_device_present(netdev)) {
+		handled =3D false;
+		goto out;
+	}
+
+	adapter =3D netdev_priv(netdev);
+
+	/* If the adapter is in low power state, then it should not
+	 * recognize any interrupt
+	 */
+
+	/* Disable Device Interrupts */
+	et131x_disable_interrupts(adapter);
+
+	/* Get a copy of the value in the interrupt status register
+	 * so we can process the interrupting section
+	 */
+	status =3D readl(&adapter->regs->global.int_status);
+
+	if (adapter->flowcontrol =3D=3D FLOW_TXONLY ||
+	    adapter->flowcontrol =3D=3D FLOW_BOTH) {
+		status &=3D ~INT_MASK_ENABLE;
+	} else {
+		status &=3D ~INT_MASK_ENABLE_NO_FLOW;
+	}
+
+	/* Make sure this is our interrupt */
+	if (!status) {
+		handled =3D false;
+		et131x_enable_interrupts(adapter);
+		goto out;
+	}
+
+	/* This is our interrupt, so process accordingly */
+
+	if (status & ET_INTR_WATCHDOG) {
+		struct tcb *tcb =3D adapter->tx_ring.send_head;
+
+		if (tcb)
+			if (++tcb->stale > 1)
+				status |=3D ET_INTR_TXDMA_ISR;
+
+		if (adapter->rx_ring.unfinished_receives)
+			status |=3D ET_INTR_RXDMA_XFR_DONE;
+		else if (tcb =3D=3D NULL)
+			writel(0, &adapter->regs->global.watchdog_timer);
+
+		status &=3D ~ET_INTR_WATCHDOG;
+	}
+
+	if (status =3D=3D 0) {
+		/* This interrupt has in some way been "handled" by
+		 * the ISR. Either it was a spurious Rx interrupt, or
+		 * it was a Tx interrupt that has been filtered by
+		 * the ISR.
+		 */
+		et131x_enable_interrupts(adapter);
+		goto out;
+	}
+
+	/* We need to save the interrupt status value for use in our
+	 * DPC. We will clear the software copy of that in that
+	 * routine.
+	 */
+	adapter->stats.interrupt_status =3D status;
+
+	/* Schedule the ISR handler as a bottom-half task in the
+	 * kernel's tq_immediate queue, and mark the queue for
+	 * execution
+	 */
+	schedule_work(&adapter->task);
+out:
+	return IRQ_RETVAL(handled);
+}
+
+/* et131x_isr_handler - The ISR handler
+ * @p_adapter, a pointer to the device's private adapter structure
+ *
+ * scheduled to run in a deferred context by the ISR. This is where th=
e ISR's
+ * work actually gets done.
+ */
+static void et131x_isr_handler(struct work_struct *work)
+{
+	struct et131x_adapter *adapter =3D
+		container_of(work, struct et131x_adapter, task);
+	u32 status =3D adapter->stats.interrupt_status;
+	struct address_map __iomem *iomem =3D adapter->regs;
+
+	/* These first two are by far the most common.  Once handled, we clea=
r
+	 * their two bits in the status word.  If the word is now zero, we
+	 * exit.
+	 */
+	/* Handle all the completed Transmit interrupts */
+	if (status & ET_INTR_TXDMA_ISR)
+		et131x_handle_send_interrupt(adapter);
+
+	/* Handle all the completed Receives interrupts */
+	if (status & ET_INTR_RXDMA_XFR_DONE)
+		et131x_handle_recv_interrupt(adapter);
+
+	status &=3D 0xffffffd7;
+
+	if (!status)
+		goto out;
+
+	/* Handle the TXDMA Error interrupt */
+	if (status & ET_INTR_TXDMA_ERR) {
+		u32 txdma_err;
+
+		/* Following read also clears the register (COR) */
+		txdma_err =3D readl(&iomem->txdma.tx_dma_error);
+
+		dev_warn(&adapter->pdev->dev,
+			    "TXDMA_ERR interrupt, error =3D %d\n",
+			    txdma_err);
+	}
+
+	/* Handle Free Buffer Ring 0 and 1 Low interrupt */
+	if (status & (ET_INTR_RXDMA_FB_R0_LOW | ET_INTR_RXDMA_FB_R1_LOW)) {
+		/* This indicates the number of unused buffers in RXDMA free
+		 * buffer ring 0 is <=3D the limit you programmed. Free buffer
+		 * resources need to be returned.  Free buffers are consumed as
+		 * packets are passed from the network to the host. The host
+		 * becomes aware of the packets from the contents of the packet
+		 * status ring. This ring is queried when the packet done
+		 * interrupt occurs. Packets are then passed to the OS. When
+		 * the OS is done with the packets the resources can be
+		 * returned to the ET1310 for re-use. This interrupt is one
+		 * method of returning resources.
+		 */
+
+		/*  If the user has flow control on, then we will
+		 * send a pause packet, otherwise just exit
+		 */
+		if (adapter->flowcontrol =3D=3D FLOW_TXONLY ||
+		    adapter->flowcontrol =3D=3D FLOW_BOTH) {
+			u32 pm_csr;
+
+			/* Tell the device to send a pause packet via the back
+			 * pressure register (bp req and bp xon/xoff)
+			 */
+			pm_csr =3D readl(&iomem->global.pm_csr);
+			if (!et1310_in_phy_coma(adapter))
+				writel(3, &iomem->txmac.bp_ctrl);
+		}
+	}
+
+	/* Handle Packet Status Ring Low Interrupt */
+	if (status & ET_INTR_RXDMA_STAT_LOW) {
+		/* Same idea as with the two Free Buffer Rings. Packets going
+		 * from the network to the host each consume a free buffer
+		 * resource and a packet status resource. These resoures are
+		 * passed to the OS. When the OS is done with the resources,
+		 * they need to be returned to the ET1310. This is one method
+		 * of returning the resources.
+		 */
+	}
+
+	/* Handle RXDMA Error Interrupt */
+	if (status & ET_INTR_RXDMA_ERR) {
+		/* The rxdma_error interrupt is sent when a time-out on a
+		 * request issued by the JAGCore has occurred or a completion is
+		 * returned with an un-successful status. In both cases the
+		 * request is considered complete. The JAGCore will
+		 * automatically re-try the request in question. Normally
+		 * information on events like these are sent to the host using
+		 * the "Advanced Error Reporting" capability. This interrupt is
+		 * another way of getting similar information. The only thing
+		 * required is to clear the interrupt by reading the ISR in the
+		 * global resources. The JAGCore will do a re-try on the
+		 * request. Normally you should never see this interrupt. If
+		 * you start to see this interrupt occurring frequently then
+		 * something bad has occurred. A reset might be the thing to do.
+		 */
+		/* TRAP();*/
+
+		dev_warn(&adapter->pdev->dev,
+			    "RxDMA_ERR interrupt, error %x\n",
+			    readl(&iomem->txmac.tx_test));
+	}
+
+	/* Handle the Wake on LAN Event */
+	if (status & ET_INTR_WOL) {
+		/* This is a secondary interrupt for wake on LAN. The driver
+		 * should never see this, if it does, something serious is
+		 * wrong. We will TRAP the message when we are in DBG mode,
+		 * otherwise we will ignore it.
+		 */
+		dev_err(&adapter->pdev->dev, "WAKE_ON_LAN interrupt\n");
+	}
+
+	/* Let's move on to the TxMac */
+	if (status & ET_INTR_TXMAC) {
+		u32 err =3D readl(&iomem->txmac.err);
+
+		/* When any of the errors occur and TXMAC generates an
+		 * interrupt to report these errors, it usually means that
+		 * TXMAC has detected an error in the data stream retrieved
+		 * from the on-chip Tx Q. All of these errors are catastrophic
+		 * and TXMAC won't be able to recover data when these errors
+		 * occur. In a nutshell, the whole Tx path will have to be reset
+		 * and re-configured afterwards.
+		 */
+		dev_warn(&adapter->pdev->dev,
+			 "TXMAC interrupt, error 0x%08x\n",
+			 err);
+
+		/* If we are debugging, we want to see this error, otherwise we
+		 * just want the device to be reset and continue
+		 */
+	}
+
+	/* Handle RXMAC Interrupt */
+	if (status & ET_INTR_RXMAC) {
+		/* These interrupts are catastrophic to the device, what we need
+		 * to do is disable the interrupts and set the flag to cause us
+		 * to reset so we can solve this issue.
+		 */
+		/* MP_SET_FLAG( adapter, FMP_ADAPTER_HARDWARE_ERROR); */
+
+		dev_warn(&adapter->pdev->dev,
+			 "RXMAC interrupt, error 0x%08x.  Requesting reset\n",
+			 readl(&iomem->rxmac.err_reg));
+
+		dev_warn(&adapter->pdev->dev,
+			 "Enable 0x%08x, Diag 0x%08x\n",
+			 readl(&iomem->rxmac.ctrl),
+			 readl(&iomem->rxmac.rxq_diag));
+
+		/* If we are debugging, we want to see this error, otherwise we
+		 * just want the device to be reset and continue
+		 */
+	}
+
+	/* Handle MAC_STAT Interrupt */
+	if (status & ET_INTR_MAC_STAT) {
+		/* This means at least one of the un-masked counters in the
+		 * MAC_STAT block has rolled over. Use this to maintain the top,
+		 * software managed bits of the counter(s).
+		 */
+		et1310_handle_macstat_interrupt(adapter);
+	}
+
+	/* Handle SLV Timeout Interrupt */
+	if (status & ET_INTR_SLV_TIMEOUT) {
+		/* This means a timeout has occurred on a read or write request
+		 * to one of the JAGCore registers. The Global Resources block
+		 * has terminated the request and on a read request, returned a
+		 * "fake" value. The most likely reasons are: Bad Address or the
+		 * addressed module is in a power-down state and can't respond.
+		 */
+	}
+out:
+	et131x_enable_interrupts(adapter);
+}
+
+/* et131x_stats - Return the current device statistics.
+ * @netdev: device whose stats are being queried
+ *
+ * Returns 0 on success, errno on failure (as defined in errno.h)
+ */
+static struct net_device_stats *et131x_stats(struct net_device *netdev=
)
+{
+	struct et131x_adapter *adapter =3D netdev_priv(netdev);
+	struct net_device_stats *stats =3D &adapter->net_stats;
+	struct ce_stats *devstat =3D &adapter->stats;
+
+	stats->rx_errors =3D devstat->rx_length_errs +
+			   devstat->rx_align_errs +
+			   devstat->rx_crc_errs +
+			   devstat->rx_code_violations +
+			   devstat->rx_other_errs;
+	stats->tx_errors =3D devstat->tx_max_pkt_errs;
+	stats->multicast =3D devstat->multicast_pkts_rcvd;
+	stats->collisions =3D devstat->tx_collisions;
+
+	stats->rx_length_errors =3D devstat->rx_length_errs;
+	stats->rx_over_errors =3D devstat->rx_overflows;
+	stats->rx_crc_errors =3D devstat->rx_crc_errs;
+
+	/* NOTE: These stats don't have corresponding values in CE_STATS,
+	 * so we're going to have to update these directly from within the
+	 * TX/RX code
+	 */
+	/* stats->rx_bytes            =3D 20; devstat->; */
+	/* stats->tx_bytes            =3D 20;  devstat->; */
+	/* stats->rx_dropped          =3D devstat->; */
+	/* stats->tx_dropped          =3D devstat->; */
+
+	/*  NOTE: Not used, can't find analogous statistics */
+	/* stats->rx_frame_errors     =3D devstat->; */
+	/* stats->rx_fifo_errors      =3D devstat->; */
+	/* stats->rx_missed_errors    =3D devstat->; */
+
+	/* stats->tx_aborted_errors   =3D devstat->; */
+	/* stats->tx_carrier_errors   =3D devstat->; */
+	/* stats->tx_fifo_errors      =3D devstat->; */
+	/* stats->tx_heartbeat_errors =3D devstat->; */
+	/* stats->tx_window_errors    =3D devstat->; */
+	return stats;
+}
+
+/* et131x_open - Open the device for use.
+ * @netdev: device to be opened
+ *
+ * Returns 0 on success, errno on failure (as defined in errno.h)
+ */
+static int et131x_open(struct net_device *netdev)
+{
+	struct et131x_adapter *adapter =3D netdev_priv(netdev);
+	struct pci_dev *pdev =3D adapter->pdev;
+	unsigned int irq =3D pdev->irq;
+	int result;
+
+	/* Start the timer to track NIC errors */
+	init_timer(&adapter->error_timer);
+	adapter->error_timer.expires =3D jiffies + TX_ERROR_PERIOD * HZ / 100=
0;
+	adapter->error_timer.function =3D et131x_error_timer_handler;
+	adapter->error_timer.data =3D (unsigned long)adapter;
+	add_timer(&adapter->error_timer);
+
+	result =3D request_irq(irq, et131x_isr,
+			     IRQF_SHARED, netdev->name, netdev);
+	if (result) {
+		dev_err(&pdev->dev, "could not register IRQ %d\n", irq);
+		return result;
+	}
+
+	adapter->flags |=3D FMP_ADAPTER_INTERRUPT_IN_USE;
+
+	et131x_up(netdev);
+
+	return result;
+}
+
+/* et131x_close - Close the device
+ * @netdev: device to be closed
+ *
+ * Returns 0 on success, errno on failure (as defined in errno.h)
+ */
+static int et131x_close(struct net_device *netdev)
+{
+	struct et131x_adapter *adapter =3D netdev_priv(netdev);
+
+	et131x_down(netdev);
+
+	adapter->flags &=3D ~FMP_ADAPTER_INTERRUPT_IN_USE;
+	free_irq(adapter->pdev->irq, netdev);
+
+	/* Stop the error timer */
+	return del_timer_sync(&adapter->error_timer);
+}
+
+/* et131x_ioctl - The I/O Control handler for the driver
+ * @netdev: device on which the control request is being made
+ * @reqbuf: a pointer to the IOCTL request buffer
+ * @cmd: the IOCTL command code
+ *
+ * Returns 0 on success, errno on failure (as defined in errno.h)
+ */
+static int et131x_ioctl(struct net_device *netdev, struct ifreq *reqbu=
f,
+			int cmd)
+{
+	struct et131x_adapter *adapter =3D netdev_priv(netdev);
+
+	if (!adapter->phydev)
+		return -EINVAL;
+
+	return phy_mii_ioctl(adapter->phydev, reqbuf, cmd);
+}
+
+/* et131x_set_packet_filter - Configures the Rx Packet filtering on th=
e device
+ * @adapter: pointer to our private adapter structure
+ *
+ * FIXME: lot of dups with MAC code
+ *
+ * Returns 0 on success, errno on failure
+ */
+static int et131x_set_packet_filter(struct et131x_adapter *adapter)
+{
+	int filter =3D adapter->packet_filter;
+	int status =3D 0;
+	u32 ctrl;
+	u32 pf_ctrl;
+
+	ctrl =3D readl(&adapter->regs->rxmac.ctrl);
+	pf_ctrl =3D readl(&adapter->regs->rxmac.pf_ctrl);
+
+	/* Default to disabled packet filtering.  Enable it in the individual
+	 * case statements that require the device to filter something
+	 */
+	ctrl |=3D 0x04;
+
+	/* Set us to be in promiscuous mode so we receive everything, this
+	 * is also true when we get a packet filter of 0
+	 */
+	if ((filter & ET131X_PACKET_TYPE_PROMISCUOUS) || filter =3D=3D 0)
+		pf_ctrl &=3D ~7;	/* Clear filter bits */
+	else {
+		/* Set us up with Multicast packet filtering.  Three cases are
+		 * possible - (1) we have a multi-cast list, (2) we receive ALL
+		 * multicast entries or (3) we receive none.
+		 */
+		if (filter & ET131X_PACKET_TYPE_ALL_MULTICAST)
+			pf_ctrl &=3D ~2;	/* Multicast filter bit */
+		else {
+			et1310_setup_device_for_multicast(adapter);
+			pf_ctrl |=3D 2;
+			ctrl &=3D ~0x04;
+		}
+
+		/* Set us up with Unicast packet filtering */
+		if (filter & ET131X_PACKET_TYPE_DIRECTED) {
+			et1310_setup_device_for_unicast(adapter);
+			pf_ctrl |=3D 4;
+			ctrl &=3D ~0x04;
+		}
+
+		/* Set us up with Broadcast packet filtering */
+		if (filter & ET131X_PACKET_TYPE_BROADCAST) {
+			pf_ctrl |=3D 1;	/* Broadcast filter bit */
+			ctrl &=3D ~0x04;
+		} else
+			pf_ctrl &=3D ~1;
+
+		/* Setup the receive mac configuration registers - Packet
+		 * Filter control + the enable / disable for packet filter
+		 * in the control reg.
+		 */
+		writel(pf_ctrl, &adapter->regs->rxmac.pf_ctrl);
+		writel(ctrl, &adapter->regs->rxmac.ctrl);
+	}
+	return status;
+}
+
+/* et131x_multicast - The handler to configure multicasting on the int=
erface
+ * @netdev: a pointer to a net_device struct representing the device
+ */
+static void et131x_multicast(struct net_device *netdev)
+{
+	struct et131x_adapter *adapter =3D netdev_priv(netdev);
+	int packet_filter;
+	unsigned long flags;
+	struct netdev_hw_addr *ha;
+	int i;
+
+	spin_lock_irqsave(&adapter->lock, flags);
+
+	/* Before we modify the platform-independent filter flags, store them
+	 * locally. This allows us to determine if anything's changed and if
+	 * we even need to bother the hardware
+	 */
+	packet_filter =3D adapter->packet_filter;
+
+	/* Clear the 'multicast' flag locally; because we only have a single
+	 * flag to check multicast, and multiple multicast addresses can be
+	 * set, this is the easiest way to determine if more than one
+	 * multicast address is being set.
+	 */
+	packet_filter &=3D ~ET131X_PACKET_TYPE_MULTICAST;
+
+	/* Check the net_device flags and set the device independent flags
+	 * accordingly
+	 */
+
+	if (netdev->flags & IFF_PROMISC)
+		adapter->packet_filter |=3D ET131X_PACKET_TYPE_PROMISCUOUS;
+	else
+		adapter->packet_filter &=3D ~ET131X_PACKET_TYPE_PROMISCUOUS;
+
+	if (netdev->flags & IFF_ALLMULTI)
+		adapter->packet_filter |=3D ET131X_PACKET_TYPE_ALL_MULTICAST;
+
+	if (netdev_mc_count(netdev) > NIC_MAX_MCAST_LIST)
+		adapter->packet_filter |=3D ET131X_PACKET_TYPE_ALL_MULTICAST;
+
+	if (netdev_mc_count(netdev) < 1) {
+		adapter->packet_filter &=3D ~ET131X_PACKET_TYPE_ALL_MULTICAST;
+		adapter->packet_filter &=3D ~ET131X_PACKET_TYPE_MULTICAST;
+	} else
+		adapter->packet_filter |=3D ET131X_PACKET_TYPE_MULTICAST;
+
+	/* Set values in the private adapter struct */
+	i =3D 0;
+	netdev_for_each_mc_addr(ha, netdev) {
+		if (i =3D=3D NIC_MAX_MCAST_LIST)
+			break;
+		memcpy(adapter->multicast_list[i++], ha->addr, ETH_ALEN);
+	}
+	adapter->multicast_addr_count =3D i;
+
+	/* Are the new flags different from the previous ones? If not, then n=
o
+	 * action is required
+	 *
+	 * NOTE - This block will always update the multicast_list with the
+	 *        hardware, even if the addresses aren't the same.
+	 */
+	if (packet_filter !=3D adapter->packet_filter) {
+		/* Call the device's filter function */
+		et131x_set_packet_filter(adapter);
+	}
+	spin_unlock_irqrestore(&adapter->lock, flags);
+}
+
+/* et131x_tx - The handler to tx a packet on the device
+ * @skb: data to be Tx'd
+ * @netdev: device on which data is to be Tx'd
+ *
+ * Returns 0 on success, errno on failure (as defined in errno.h)
+ */
+static int et131x_tx(struct sk_buff *skb, struct net_device *netdev)
+{
+	int status =3D 0;
+	struct et131x_adapter *adapter =3D netdev_priv(netdev);
+
+	/* stop the queue if it's getting full */
+	if (adapter->tx_ring.used >=3D NUM_TCB - 1 &&
+	    !netif_queue_stopped(netdev))
+		netif_stop_queue(netdev);
+
+	/* Save the timestamp for the TX timeout watchdog */
+	netdev->trans_start =3D jiffies;
+
+	/* Call the device-specific data Tx routine */
+	status =3D et131x_send_packets(skb, netdev);
+
+	/* Check status and manage the netif queue if necessary */
+	if (status !=3D 0) {
+		if (status =3D=3D -ENOMEM)
+			status =3D NETDEV_TX_BUSY;
+		else
+			status =3D NETDEV_TX_OK;
+	}
+	return status;
+}
+
+/* et131x_tx_timeout - Timeout handler
+ * @netdev: a pointer to a net_device struct representing the device
+ *
+ * The handler called when a Tx request times out. The timeout period =
is
+ * specified by the 'tx_timeo" element in the net_device structure (se=
e
+ * et131x_alloc_device() to see how this value is set).
+ */
+static void et131x_tx_timeout(struct net_device *netdev)
+{
+	struct et131x_adapter *adapter =3D netdev_priv(netdev);
+	struct tcb *tcb;
+	unsigned long flags;
+
+	/* If the device is closed, ignore the timeout */
+	if (~(adapter->flags & FMP_ADAPTER_INTERRUPT_IN_USE))
+		return;
+
+	/* Any nonrecoverable hardware error?
+	 * Checks adapter->flags for any failure in phy reading
+	 */
+	if (adapter->flags & FMP_ADAPTER_NON_RECOVER_ERROR)
+		return;
+
+	/* Hardware failure? */
+	if (adapter->flags & FMP_ADAPTER_HARDWARE_ERROR) {
+		dev_err(&adapter->pdev->dev, "hardware error - reset\n");
+		return;
+	}
+
+	/* Is send stuck? */
+	spin_lock_irqsave(&adapter->tcb_send_qlock, flags);
+
+	tcb =3D adapter->tx_ring.send_head;
+
+	if (tcb !=3D NULL) {
+		tcb->count++;
+
+		if (tcb->count > NIC_SEND_HANG_THRESHOLD) {
+			spin_unlock_irqrestore(&adapter->tcb_send_qlock,
+					       flags);
+
+			dev_warn(&adapter->pdev->dev,
+				"Send stuck - reset.  tcb->WrIndex %x, flags 0x%08x\n",
+				tcb->index,
+				tcb->flags);
+
+			adapter->net_stats.tx_errors++;
+
+			/* perform reset of tx/rx */
+			et131x_disable_txrx(netdev);
+			et131x_enable_txrx(netdev);
+			return;
+		}
+	}
+
+	spin_unlock_irqrestore(&adapter->tcb_send_qlock, flags);
+}
+
+/* et131x_change_mtu - The handler called to change the MTU for the de=
vice
+ * @netdev: device whose MTU is to be changed
+ * @new_mtu: the desired MTU
+ *
+ * Returns 0 on success, errno on failure (as defined in errno.h)
+ */
+static int et131x_change_mtu(struct net_device *netdev, int new_mtu)
+{
+	int result =3D 0;
+	struct et131x_adapter *adapter =3D netdev_priv(netdev);
+
+	/* Make sure the requested MTU is valid */
+	if (new_mtu < 64 || new_mtu > 9216)
+		return -EINVAL;
+
+	et131x_disable_txrx(netdev);
+	et131x_handle_send_interrupt(adapter);
+	et131x_handle_recv_interrupt(adapter);
+
+	/* Set the new MTU */
+	netdev->mtu =3D new_mtu;
+
+	/* Free Rx DMA memory */
+	et131x_adapter_memory_free(adapter);
+
+	/* Set the config parameter for Jumbo Packet support */
+	adapter->registry_jumbo_packet =3D new_mtu + 14;
+	et131x_soft_reset(adapter);
+
+	/* Alloc and init Rx DMA memory */
+	result =3D et131x_adapter_memory_alloc(adapter);
+	if (result !=3D 0) {
+		dev_warn(&adapter->pdev->dev,
+			"Change MTU failed; couldn't re-alloc DMA memory\n");
+		return result;
+	}
+
+	et131x_init_send(adapter);
+
+	et131x_hwaddr_init(adapter);
+	memcpy(netdev->dev_addr, adapter->addr, ETH_ALEN);
+
+	/* Init the device with the new settings */
+	et131x_adapter_setup(adapter);
+
+	et131x_enable_txrx(netdev);
+
+	return result;
+}
+
+/* et131x_set_mac_addr - handler to change the MAC address for the dev=
ice
+ * @netdev: device whose MAC is to be changed
+ * @new_mac: the desired MAC address
+ *
+ * Returns 0 on success, errno on failure (as defined in errno.h)
+ *
+ * IMPLEMENTED BY : blux http://berndlux.de 22.01.2007 21:14
+ */
+static int et131x_set_mac_addr(struct net_device *netdev, void *new_ma=
c)
+{
+	int result =3D 0;
+	struct et131x_adapter *adapter =3D netdev_priv(netdev);
+	struct sockaddr *address =3D new_mac;
+
+	/* begin blux */
+
+	if (adapter =3D=3D NULL)
+		return -ENODEV;
+
+	/* Make sure the requested MAC is valid */
+	if (!is_valid_ether_addr(address->sa_data))
+		return -EADDRNOTAVAIL;
+
+	et131x_disable_txrx(netdev);
+	et131x_handle_send_interrupt(adapter);
+	et131x_handle_recv_interrupt(adapter);
+
+	/* Set the new MAC */
+	/* netdev->set_mac_address  =3D &new_mac; */
+
+	memcpy(netdev->dev_addr, address->sa_data, netdev->addr_len);
+
+	netdev_info(netdev, "Setting MAC address to %pM\n",
+		    netdev->dev_addr);
+
+	/* Free Rx DMA memory */
+	et131x_adapter_memory_free(adapter);
+
+	et131x_soft_reset(adapter);
+
+	/* Alloc and init Rx DMA memory */
+	result =3D et131x_adapter_memory_alloc(adapter);
+	if (result !=3D 0) {
+		dev_err(&adapter->pdev->dev,
+			"Change MAC failed; couldn't re-alloc DMA memory\n");
+		return result;
+	}
+
+	et131x_init_send(adapter);
+
+	et131x_hwaddr_init(adapter);
+
+	/* Init the device with the new settings */
+	et131x_adapter_setup(adapter);
+
+	et131x_enable_txrx(netdev);
+
+	return result;
+}
+
+static const struct net_device_ops et131x_netdev_ops =3D {
+	.ndo_open		=3D et131x_open,
+	.ndo_stop		=3D et131x_close,
+	.ndo_start_xmit		=3D et131x_tx,
+	.ndo_set_rx_mode	=3D et131x_multicast,
+	.ndo_tx_timeout		=3D et131x_tx_timeout,
+	.ndo_change_mtu		=3D et131x_change_mtu,
+	.ndo_set_mac_address	=3D et131x_set_mac_addr,
+	.ndo_validate_addr	=3D eth_validate_addr,
+	.ndo_get_stats		=3D et131x_stats,
+	.ndo_do_ioctl		=3D et131x_ioctl,
+};
+
+/* et131x_pci_setup - Perform device initialization
+ * @pdev: a pointer to the device's pci_dev structure
+ * @ent: this device's entry in the pci_device_id table
+ *
+ * Returns 0 on success, errno on failure (as defined in errno.h)
+ *
+ * Registered in the pci_driver structure, this function is called whe=
n the
+ * PCI subsystem finds a new PCI device which matches the information
+ * contained in the pci_device_id table. This routine is the equivalen=
t to
+ * a device insertion routine.
+ */
+static int et131x_pci_setup(struct pci_dev *pdev,
+			       const struct pci_device_id *ent)
+{
+	struct net_device *netdev;
+	struct et131x_adapter *adapter;
+	int rc;
+	int ii;
+
+	rc =3D pci_enable_device(pdev);
+	if (rc < 0) {
+		dev_err(&pdev->dev, "pci_enable_device() failed\n");
+		goto out;
+	}
+
+	/* Perform some basic PCI checks */
+	if (!(pci_resource_flags(pdev, 0) & IORESOURCE_MEM)) {
+		dev_err(&pdev->dev, "Can't find PCI device's base address\n");
+		rc =3D -ENODEV;
+		goto err_disable;
+	}
+
+	rc =3D pci_request_regions(pdev, DRIVER_NAME);
+	if (rc < 0) {
+		dev_err(&pdev->dev, "Can't get PCI resources\n");
+		goto err_disable;
+	}
+
+	pci_set_master(pdev);
+
+	/* Check the DMA addressing support of this device */
+	if (!dma_set_mask(&pdev->dev, DMA_BIT_MASK(64))) {
+		rc =3D dma_set_coherent_mask(&pdev->dev, DMA_BIT_MASK(64));
+		if (rc < 0) {
+			dev_err(&pdev->dev,
+			  "Unable to obtain 64 bit DMA for consistent allocations\n");
+			goto err_release_res;
+		}
+	} else if (!dma_set_mask(&pdev->dev, DMA_BIT_MASK(32))) {
+		rc =3D dma_set_coherent_mask(&pdev->dev, DMA_BIT_MASK(32));
+		if (rc < 0) {
+			dev_err(&pdev->dev,
+			  "Unable to obtain 32 bit DMA for consistent allocations\n");
+			goto err_release_res;
+		}
+	} else {
+		dev_err(&pdev->dev, "No usable DMA addressing method\n");
+		rc =3D -EIO;
+		goto err_release_res;
+	}
+
+	/* Allocate netdev and private adapter structs */
+	netdev =3D alloc_etherdev(sizeof(struct et131x_adapter));
+	if (!netdev) {
+		dev_err(&pdev->dev, "Couldn't alloc netdev struct\n");
+		rc =3D -ENOMEM;
+		goto err_release_res;
+	}
+
+	netdev->watchdog_timeo =3D ET131X_TX_TIMEOUT;
+	netdev->netdev_ops     =3D &et131x_netdev_ops;
+
+	SET_NETDEV_DEV(netdev, &pdev->dev);
+	SET_ETHTOOL_OPS(netdev, &et131x_ethtool_ops);
+
+	adapter =3D et131x_adapter_init(netdev, pdev);
+
+	rc =3D et131x_pci_init(adapter, pdev);
+	if (rc < 0)
+		goto err_free_dev;
+
+	/* Map the bus-relative registers to system virtual memory */
+	adapter->regs =3D pci_ioremap_bar(pdev, 0);
+	if (!adapter->regs) {
+		dev_err(&pdev->dev, "Cannot map device registers\n");
+		rc =3D -ENOMEM;
+		goto err_free_dev;
+	}
+
+	/* If Phy COMA mode was enabled when we went down, disable it here. *=
/
+	writel(ET_PMCSR_INIT,  &adapter->regs->global.pm_csr);
+
+	/* Issue a global reset to the et1310 */
+	et131x_soft_reset(adapter);
+
+	/* Disable all interrupts (paranoid) */
+	et131x_disable_interrupts(adapter);
+
+	/* Allocate DMA memory */
+	rc =3D et131x_adapter_memory_alloc(adapter);
+	if (rc < 0) {
+		dev_err(&pdev->dev, "Could not alloc adapater memory (DMA)\n");
+		goto err_iounmap;
+	}
+
+	/* Init send data structures */
+	et131x_init_send(adapter);
+
+	/* Set up the task structure for the ISR's deferred handler */
+	INIT_WORK(&adapter->task, et131x_isr_handler);
+
+	/* Copy address into the net_device struct */
+	memcpy(netdev->dev_addr, adapter->addr, ETH_ALEN);
+
+	/* Init variable for counting how long we do not have link status */
+	adapter->boot_coma =3D 0;
+	et1310_disable_phy_coma(adapter);
+
+	rc =3D -ENOMEM;
+
+	/* Setup the mii_bus struct */
+	adapter->mii_bus =3D mdiobus_alloc();
+	if (!adapter->mii_bus) {
+		dev_err(&pdev->dev, "Alloc of mii_bus struct failed\n");
+		goto err_mem_free;
+	}
+
+	adapter->mii_bus->name =3D "et131x_eth_mii";
+	snprintf(adapter->mii_bus->id, MII_BUS_ID_SIZE, "%x",
+		(adapter->pdev->bus->number << 8) | adapter->pdev->devfn);
+	adapter->mii_bus->priv =3D netdev;
+	adapter->mii_bus->read =3D et131x_mdio_read;
+	adapter->mii_bus->write =3D et131x_mdio_write;
+	adapter->mii_bus->reset =3D et131x_mdio_reset;
+	adapter->mii_bus->irq =3D kmalloc(sizeof(int)*PHY_MAX_ADDR, GFP_KERNE=
L);
+	if (!adapter->mii_bus->irq) {
+		dev_err(&pdev->dev, "mii_bus irq allocation failed\n");
+		goto err_mdio_free;
+	}
+
+	for (ii =3D 0; ii < PHY_MAX_ADDR; ii++)
+		adapter->mii_bus->irq[ii] =3D PHY_POLL;
+
+	rc =3D mdiobus_register(adapter->mii_bus);
+	if (rc < 0) {
+		dev_err(&pdev->dev, "failed to register MII bus\n");
+		goto err_mdio_free_irq;
+	}
+
+	rc =3D et131x_mii_probe(netdev);
+	if (rc < 0) {
+		dev_err(&pdev->dev, "failed to probe MII bus\n");
+		goto err_mdio_unregister;
+	}
+
+	/* Setup et1310 as per the documentation */
+	et131x_adapter_setup(adapter);
+
+	/* We can enable interrupts now
+	 *
+	 *  NOTE - Because registration of interrupt handler is done in the
+	 *         device's open(), defer enabling device interrupts to that
+	 *         point
+	 */
+
+	/* Register the net_device struct with the Linux network layer */
+	rc =3D register_netdev(netdev);
+	if (rc < 0) {
+		dev_err(&pdev->dev, "register_netdev() failed\n");
+		goto err_phy_disconnect;
+	}
+
+	/* Register the net_device struct with the PCI subsystem. Save a copy
+	 * of the PCI config space for this device now that the device has
+	 * been initialized, just in case it needs to be quickly restored.
+	 */
+	pci_set_drvdata(pdev, netdev);
+out:
+	return rc;
+
+err_phy_disconnect:
+	phy_disconnect(adapter->phydev);
+err_mdio_unregister:
+	mdiobus_unregister(adapter->mii_bus);
+err_mdio_free_irq:
+	kfree(adapter->mii_bus->irq);
+err_mdio_free:
+	mdiobus_free(adapter->mii_bus);
+err_mem_free:
+	et131x_adapter_memory_free(adapter);
+err_iounmap:
+	iounmap(adapter->regs);
+err_free_dev:
+	pci_dev_put(pdev);
+	free_netdev(netdev);
+err_release_res:
+	pci_release_regions(pdev);
+err_disable:
+	pci_disable_device(pdev);
+	goto out;
+}
+
+static DEFINE_PCI_DEVICE_TABLE(et131x_pci_table) =3D {
+	{ PCI_VDEVICE(ATT, ET131X_PCI_DEVICE_ID_GIG), 0UL},
+	{ PCI_VDEVICE(ATT, ET131X_PCI_DEVICE_ID_FAST), 0UL},
+	{0,}
+};
+MODULE_DEVICE_TABLE(pci, et131x_pci_table);
+
+static struct pci_driver et131x_driver =3D {
+	.name		=3D DRIVER_NAME,
+	.id_table	=3D et131x_pci_table,
+	.probe		=3D et131x_pci_setup,
+	.remove		=3D et131x_pci_remove,
+	.driver.pm	=3D ET131X_PM_OPS,
+};
+
+module_pci_driver(et131x_driver);
diff --git a/drivers/net/ethernet/agere/et131x.h b/drivers/net/ethernet=
/agere/et131x.h
new file mode 100644
index 0000000..bbe78a7
--- /dev/null
+++ b/drivers/net/ethernet/agere/et131x.h
@@ -0,0 +1,1710 @@
+/*
+ * Copyright =C2=A9 2005 Agere Systems Inc.
+ * All rights reserved.
+ *   http://www.agere.com
+ *
+ * SOFTWARE LICENSE
+ *
+ * This software is provided subject to the following terms and condit=
ions,
+ * which you should read carefully before using the software.  Using t=
his
+ * software indicates your acceptance of these terms and conditions.  =
If you do
+ * not agree with these terms and conditions, do not use the software.
+ *
+ * Copyright =C2=A9 2005 Agere Systems Inc.
+ * All rights reserved.
+ *
+ * Redistribution and use in source or binary forms, with or without
+ * modifications, are permitted provided that the following conditions=
 are met:
+ *
+ * . Redistributions of source code must retain the above copyright no=
tice, this
+ *    list of conditions and the following Disclaimer as comments in t=
he code as
+ *    well as in the documentation and/or other materials provided wit=
h the
+ *    distribution.
+ *
+ * . Redistributions in binary form must reproduce the above copyright=
 notice,
+ *    this list of conditions and the following Disclaimer in the docu=
mentation
+ *    and/or other materials provided with the distribution.
+ *
+ * . Neither the name of Agere Systems Inc. nor the names of the contr=
ibutors
+ *    may be used to endorse or promote products derived from this sof=
tware
+ *    without specific prior written permission.
+ *
+ * Disclaimer
+ *
+ * THIS SOFTWARE IS PROVIDED "AS IS" AND ANY EXPRESS OR IMPLIED WARRAN=
TIES,
+ * INCLUDING, BUT NOT LIMITED TO, INFRINGEMENT AND THE IMPLIED WARRANT=
IES OF
+ * MERCHANTABILITY AND FITNESS FOR A PARTICULAR PURPOSE ARE DISCLAIMED=
=2E  ANY
+ * USE, MODIFICATION OR DISTRIBUTION OF THIS SOFTWARE IS SOLELY AT THE=
 USERS OWN
+ * RISK. IN NO EVENT SHALL AGERE SYSTEMS INC. OR CONTRIBUTORS BE LIABL=
E FOR ANY
+ * DIRECT, INDIRECT, INCIDENTAL, SPECIAL, EXEMPLARY, OR CONSEQUENTIAL =
DAMAGES
+ * (INCLUDING, BUT NOT LIMITED TO, PROCUREMENT OF SUBSTITUTE GOODS OR =
SERVICES;
+ * LOSS OF USE, DATA, OR PROFITS; OR BUSINESS INTERRUPTION) HOWEVER CA=
USED AND
+ * ON ANY THEORY OF LIABILITY, INCLUDING, BUT NOT LIMITED TO, CONTRACT=
, STRICT
+ * LIABILITY, OR TORT (INCLUDING NEGLIGENCE OR OTHERWISE) ARISING IN A=
NY WAY OUT
+ * OF THE USE OF THIS SOFTWARE, EVEN IF ADVISED OF THE POSSIBILITY OF =
SUCH
+ * DAMAGE.
+ *
+ */
+
+#define DRIVER_NAME "et131x"
+#define DRIVER_VERSION "v2.0"
+
+/* EEPROM registers */
+
+/* LBCIF Register Groups (addressed via 32-bit offsets) */
+#define LBCIF_DWORD0_GROUP       0xAC
+#define LBCIF_DWORD1_GROUP       0xB0
+
+/* LBCIF Registers (addressed via 8-bit offsets) */
+#define LBCIF_ADDRESS_REGISTER   0xAC
+#define LBCIF_DATA_REGISTER      0xB0
+#define LBCIF_CONTROL_REGISTER   0xB1
+#define LBCIF_STATUS_REGISTER    0xB2
+
+/* LBCIF Control Register Bits */
+#define LBCIF_CONTROL_SEQUENTIAL_READ   0x01
+#define LBCIF_CONTROL_PAGE_WRITE        0x02
+#define LBCIF_CONTROL_EEPROM_RELOAD     0x08
+#define LBCIF_CONTROL_TWO_BYTE_ADDR     0x20
+#define LBCIF_CONTROL_I2C_WRITE         0x40
+#define LBCIF_CONTROL_LBCIF_ENABLE      0x80
+
+/* LBCIF Status Register Bits */
+#define LBCIF_STATUS_PHY_QUEUE_AVAIL    0x01
+#define LBCIF_STATUS_I2C_IDLE           0x02
+#define LBCIF_STATUS_ACK_ERROR          0x04
+#define LBCIF_STATUS_GENERAL_ERROR      0x08
+#define LBCIF_STATUS_CHECKSUM_ERROR     0x40
+#define LBCIF_STATUS_EEPROM_PRESENT     0x80
+
+/* START OF GLOBAL REGISTER ADDRESS MAP */
+
+/*
+ * 10bit registers
+ *
+ * Tx queue start address reg in global address map at address 0x0000
+ * tx queue end address reg in global address map at address 0x0004
+ * rx queue start address reg in global address map at address 0x0008
+ * rx queue end address reg in global address map at address 0x000C
+ */
+
+/*
+ * structure for power management control status reg in global address=
 map
+ * located at address 0x0010
+ *	jagcore_rx_rdy	bit 9
+ *	jagcore_tx_rdy	bit 8
+ *	phy_lped_en	bit 7
+ *	phy_sw_coma	bit 6
+ *	rxclk_gate	bit 5
+ *	txclk_gate	bit 4
+ *	sysclk_gate	bit 3
+ *	jagcore_rx_en	bit 2
+ *	jagcore_tx_en	bit 1
+ *	gigephy_en	bit 0
+ */
+
+#define ET_PM_PHY_SW_COMA		0x40
+#define ET_PMCSR_INIT			0x38
+
+/*
+ * Interrupt status reg at address 0x0018
+ */
+
+#define	ET_INTR_TXDMA_ISR	0x00000008
+#define ET_INTR_TXDMA_ERR	0x00000010
+#define ET_INTR_RXDMA_XFR_DONE	0x00000020
+#define ET_INTR_RXDMA_FB_R0_LOW	0x00000040
+#define ET_INTR_RXDMA_FB_R1_LOW	0x00000080
+#define ET_INTR_RXDMA_STAT_LOW	0x00000100
+#define ET_INTR_RXDMA_ERR	0x00000200
+#define ET_INTR_WATCHDOG	0x00004000
+#define ET_INTR_WOL		0x00008000
+#define ET_INTR_PHY		0x00010000
+#define ET_INTR_TXMAC		0x00020000
+#define ET_INTR_RXMAC		0x00040000
+#define ET_INTR_MAC_STAT	0x00080000
+#define ET_INTR_SLV_TIMEOUT	0x00100000
+
+/*
+ * Interrupt mask register at address 0x001C
+ * Interrupt alias clear mask reg at address 0x0020
+ * Interrupt status alias reg at address 0x0024
+ *
+ * Same masks as above
+ */
+
+/*
+ * Software reset reg at address 0x0028
+ * 0:	txdma_sw_reset
+ * 1:	rxdma_sw_reset
+ * 2:	txmac_sw_reset
+ * 3:	rxmac_sw_reset
+ * 4:	mac_sw_reset
+ * 5:	mac_stat_sw_reset
+ * 6:	mmc_sw_reset
+ *31:	selfclr_disable
+ */
+
+#define ET_RESET_ALL	0x007F;
+
+/*
+ * SLV Timer reg at address 0x002C (low 24 bits)
+ */
+
+/*
+ * MSI Configuration reg at address 0x0030
+ */
+
+#define ET_MSI_VECTOR	0x0000001F
+#define ET_MSI_TC	0x00070000
+
+/*
+ * Loopback reg located at address 0x0034
+ */
+
+#define ET_LOOP_MAC	0x00000001
+#define ET_LOOP_DMA	0x00000002
+
+/*
+ * GLOBAL Module of JAGCore Address Mapping
+ * Located at address 0x0000
+ */
+struct global_regs {				/* Location: */
+	u32 txq_start_addr;			/*  0x0000 */
+	u32 txq_end_addr;			/*  0x0004 */
+	u32 rxq_start_addr;			/*  0x0008 */
+	u32 rxq_end_addr;			/*  0x000C */
+	u32 pm_csr;				/*  0x0010 */
+	u32 unused;				/*  0x0014 */
+	u32 int_status;				/*  0x0018 */
+	u32 int_mask;				/*  0x001C */
+	u32 int_alias_clr_en;			/*  0x0020 */
+	u32 int_status_alias;			/*  0x0024 */
+	u32 sw_reset;				/*  0x0028 */
+	u32 slv_timer;				/*  0x002C */
+	u32 msi_config;				/*  0x0030 */
+	u32 loopback;				/*  0x0034 */
+	u32 watchdog_timer;			/*  0x0038 */
+};
+
+
+/* START OF TXDMA REGISTER ADDRESS MAP */
+
+/*
+ * txdma control status reg at address 0x1000
+ */
+
+#define ET_TXDMA_CSR_HALT	0x00000001
+#define ET_TXDMA_DROP_TLP	0x00000002
+#define ET_TXDMA_CACHE_THRS	0x000000F0
+#define ET_TXDMA_CACHE_SHIFT	4
+#define ET_TXDMA_SNGL_EPKT	0x00000100
+#define ET_TXDMA_CLASS		0x00001E00
+
+/*
+ * structure for txdma packet ring base address hi reg in txdma addres=
s map
+ * located at address 0x1004
+ * Defined earlier (u32)
+ */
+
+/*
+ * structure for txdma packet ring base address low reg in txdma addre=
ss map
+ * located at address 0x1008
+ * Defined earlier (u32)
+ */
+
+/*
+ * structure for txdma packet ring number of descriptor reg in txdma a=
ddress
+ * map.  Located at address 0x100C
+ *
+ * 31-10: unused
+ * 9-0: pr ndes
+ */
+
+#define ET_DMA12_MASK		0x0FFF	/* 12 bit mask for DMA12W types */
+#define ET_DMA12_WRAP		0x1000
+#define ET_DMA10_MASK		0x03FF	/* 10 bit mask for DMA10W types */
+#define ET_DMA10_WRAP		0x0400
+#define ET_DMA4_MASK		0x000F	/* 4 bit mask for DMA4W types */
+#define ET_DMA4_WRAP		0x0010
+
+#define INDEX12(x)	((x) & ET_DMA12_MASK)
+#define INDEX10(x)	((x) & ET_DMA10_MASK)
+#define INDEX4(x)	((x) & ET_DMA4_MASK)
+
+/*
+ * 10bit DMA with wrap
+ * txdma tx queue write address reg in txdma address map at 0x1010
+ * txdma tx queue write address external reg in txdma address map at 0=
x1014
+ * txdma tx queue read address reg in txdma address map at 0x1018
+ *
+ * u32
+ * txdma status writeback address hi reg in txdma address map at0x101C
+ * txdma status writeback address lo reg in txdma address map at 0x102=
0
+ *
+ * 10bit DMA with wrap
+ * txdma service request reg in txdma address map at 0x1024
+ * structure for txdma service complete reg in txdma address map at 0x=
1028
+ *
+ * 4bit DMA with wrap
+ * txdma tx descriptor cache read index reg in txdma address map at 0x=
102C
+ * txdma tx descriptor cache write index reg in txdma address map at 0=
x1030
+ *
+ * txdma error reg in txdma address map at address 0x1034
+ * 0: PyldResend
+ * 1: PyldRewind
+ * 4: DescrResend
+ * 5: DescrRewind
+ * 8: WrbkResend
+ * 9: WrbkRewind
+ */
+
+/*
+ * Tx DMA Module of JAGCore Address Mapping
+ * Located at address 0x1000
+ */
+struct txdma_regs {			/* Location: */
+	u32 csr;			/*  0x1000 */
+	u32 pr_base_hi;			/*  0x1004 */
+	u32 pr_base_lo;			/*  0x1008 */
+	u32 pr_num_des;			/*  0x100C */
+	u32 txq_wr_addr;		/*  0x1010 */
+	u32 txq_wr_addr_ext;		/*  0x1014 */
+	u32 txq_rd_addr;		/*  0x1018 */
+	u32 dma_wb_base_hi;		/*  0x101C */
+	u32 dma_wb_base_lo;		/*  0x1020 */
+	u32 service_request;		/*  0x1024 */
+	u32 service_complete;		/*  0x1028 */
+	u32 cache_rd_index;		/*  0x102C */
+	u32 cache_wr_index;		/*  0x1030 */
+	u32 tx_dma_error;		/*  0x1034 */
+	u32 desc_abort_cnt;		/*  0x1038 */
+	u32 payload_abort_cnt;		/*  0x103c */
+	u32 writeback_abort_cnt;	/*  0x1040 */
+	u32 desc_timeout_cnt;		/*  0x1044 */
+	u32 payload_timeout_cnt;	/*  0x1048 */
+	u32 writeback_timeout_cnt;	/*  0x104c */
+	u32 desc_error_cnt;		/*  0x1050 */
+	u32 payload_error_cnt;		/*  0x1054 */
+	u32 writeback_error_cnt;	/*  0x1058 */
+	u32 dropped_tlp_cnt;		/*  0x105c */
+	u32 new_service_complete;	/*  0x1060 */
+	u32 ethernet_packet_cnt;	/*  0x1064 */
+};
+
+/* END OF TXDMA REGISTER ADDRESS MAP */
+
+
+/* START OF RXDMA REGISTER ADDRESS MAP */
+
+/*
+ * structure for control status reg in rxdma address map
+ * Located at address 0x2000
+ *
+ * CSR
+ * 0: halt
+ * 1-3: tc
+ * 4: fbr_big_endian
+ * 5: psr_big_endian
+ * 6: pkt_big_endian
+ * 7: dma_big_endian
+ * 8-9: fbr0_size
+ * 10: fbr0_enable
+ * 11-12: fbr1_size
+ * 13: fbr1_enable
+ * 14: unused
+ * 15: pkt_drop_disable
+ * 16: pkt_done_flush
+ * 17: halt_status
+ * 18-31: unused
+ */
+
+#define ET_RXDMA_CSR_HALT		0x0001
+#define ET_RXDMA_CSR_FBR0_SIZE_LO	0x0100
+#define ET_RXDMA_CSR_FBR0_SIZE_HI	0x0200
+#define ET_RXDMA_CSR_FBR0_ENABLE	0x0400
+#define ET_RXDMA_CSR_FBR1_SIZE_LO	0x0800
+#define ET_RXDMA_CSR_FBR1_SIZE_HI	0x1000
+#define ET_RXDMA_CSR_FBR1_ENABLE	0x2000
+#define ET_RXDMA_CSR_HALT_STATUS	0x00020000
+
+/*
+ * structure for dma writeback lo reg in rxdma address map
+ * located at address 0x2004
+ * Defined earlier (u32)
+ */
+
+/*
+ * structure for dma writeback hi reg in rxdma address map
+ * located at address 0x2008
+ * Defined earlier (u32)
+ */
+
+/*
+ * structure for number of packets done reg in rxdma address map
+ * located at address 0x200C
+ *
+ * 31-8: unused
+ * 7-0: num done
+ */
+
+/*
+ * structure for max packet time reg in rxdma address map
+ * located at address 0x2010
+ *
+ * 31-18: unused
+ * 17-0: time done
+ */
+
+/*
+ * structure for rx queue read address reg in rxdma address map
+ * located at address 0x2014
+ * Defined earlier (u32)
+ */
+
+/*
+ * structure for rx queue read address external reg in rxdma address m=
ap
+ * located at address 0x2018
+ * Defined earlier (u32)
+ */
+
+/*
+ * structure for rx queue write address reg in rxdma address map
+ * located at address 0x201C
+ * Defined earlier (u32)
+ */
+
+/*
+ * structure for packet status ring base address lo reg in rxdma addre=
ss map
+ * located at address 0x2020
+ * Defined earlier (u32)
+ */
+
+/*
+ * structure for packet status ring base address hi reg in rxdma addre=
ss map
+ * located at address 0x2024
+ * Defined earlier (u32)
+ */
+
+/*
+ * structure for packet status ring number of descriptors reg in rxdma=
 address
+ * map.  Located at address 0x2028
+ *
+ * 31-12: unused
+ * 11-0: psr ndes
+ */
+
+#define ET_RXDMA_PSR_NUM_DES_MASK	0xFFF;
+
+/*
+ * structure for packet status ring available offset reg in rxdma addr=
ess map
+ * located at address 0x202C
+ *
+ * 31-13: unused
+ * 12: psr avail wrap
+ * 11-0: psr avail
+ */
+
+/*
+ * structure for packet status ring full offset reg in rxdma address m=
ap
+ * located at address 0x2030
+ *
+ * 31-13: unused
+ * 12: psr full wrap
+ * 11-0: psr full
+ */
+
+/*
+ * structure for packet status ring access index reg in rxdma address =
map
+ * located at address 0x2034
+ *
+ * 31-5: unused
+ * 4-0: psr_ai
+ */
+
+/*
+ * structure for packet status ring minimum descriptors reg in rxdma a=
ddress
+ * map.  Located at address 0x2038
+ *
+ * 31-12: unused
+ * 11-0: psr_min
+ */
+
+/*
+ * structure for free buffer ring base lo address reg in rxdma address=
 map
+ * located at address 0x203C
+ * Defined earlier (u32)
+ */
+
+/*
+ * structure for free buffer ring base hi address reg in rxdma address=
 map
+ * located at address 0x2040
+ * Defined earlier (u32)
+ */
+
+/*
+ * structure for free buffer ring number of descriptors reg in rxdma a=
ddress
+ * map.  Located at address 0x2044
+ *
+ * 31-10: unused
+ * 9-0: fbr ndesc
+ */
+
+/*
+ * structure for free buffer ring 0 available offset reg in rxdma addr=
ess map
+ * located at address 0x2048
+ * Defined earlier (u32)
+ */
+
+/*
+ * structure for free buffer ring 0 full offset reg in rxdma address m=
ap
+ * located at address 0x204C
+ * Defined earlier (u32)
+ */
+
+/*
+ * structure for free buffer cache 0 full offset reg in rxdma address =
map
+ * located at address 0x2050
+ *
+ * 31-5: unused
+ * 4-0: fbc rdi
+ */
+
+/*
+ * structure for free buffer ring 0 minimum descriptor reg in rxdma ad=
dress map
+ * located at address 0x2054
+ *
+ * 31-10: unused
+ * 9-0: fbr min
+ */
+
+/*
+ * structure for free buffer ring 1 base address lo reg in rxdma addre=
ss map
+ * located at address 0x2058 - 0x205C
+ * Defined earlier (RXDMA_FBR_BASE_LO_t and RXDMA_FBR_BASE_HI_t)
+ */
+
+/*
+ * structure for free buffer ring 1 number of descriptors reg in rxdma=
 address
+ * map.  Located at address 0x2060
+ * Defined earlier (RXDMA_FBR_NUM_DES_t)
+ */
+
+/*
+ * structure for free buffer ring 1 available offset reg in rxdma addr=
ess map
+ * located at address 0x2064
+ * Defined Earlier (RXDMA_FBR_AVAIL_OFFSET_t)
+ */
+
+/*
+ * structure for free buffer ring 1 full offset reg in rxdma address m=
ap
+ * located at address 0x2068
+ * Defined Earlier (RXDMA_FBR_FULL_OFFSET_t)
+ */
+
+/*
+ * structure for free buffer cache 1 read index reg in rxdma address m=
ap
+ * located at address 0x206C
+ * Defined Earlier (RXDMA_FBC_RD_INDEX_t)
+ */
+
+/*
+ * structure for free buffer ring 1 minimum descriptor reg in rxdma ad=
dress map
+ * located at address 0x2070
+ * Defined Earlier (RXDMA_FBR_MIN_DES_t)
+ */
+
+/*
+ * Rx DMA Module of JAGCore Address Mapping
+ * Located at address 0x2000
+ */
+struct rxdma_regs {					/* Location: */
+	u32 csr;					/*  0x2000 */
+	u32 dma_wb_base_lo;				/*  0x2004 */
+	u32 dma_wb_base_hi;				/*  0x2008 */
+	u32 num_pkt_done;				/*  0x200C */
+	u32 max_pkt_time;				/*  0x2010 */
+	u32 rxq_rd_addr;				/*  0x2014 */
+	u32 rxq_rd_addr_ext;				/*  0x2018 */
+	u32 rxq_wr_addr;				/*  0x201C */
+	u32 psr_base_lo;				/*  0x2020 */
+	u32 psr_base_hi;				/*  0x2024 */
+	u32 psr_num_des;				/*  0x2028 */
+	u32 psr_avail_offset;				/*  0x202C */
+	u32 psr_full_offset;				/*  0x2030 */
+	u32 psr_access_index;				/*  0x2034 */
+	u32 psr_min_des;				/*  0x2038 */
+	u32 fbr0_base_lo;				/*  0x203C */
+	u32 fbr0_base_hi;				/*  0x2040 */
+	u32 fbr0_num_des;				/*  0x2044 */
+	u32 fbr0_avail_offset;				/*  0x2048 */
+	u32 fbr0_full_offset;				/*  0x204C */
+	u32 fbr0_rd_index;				/*  0x2050 */
+	u32 fbr0_min_des;				/*  0x2054 */
+	u32 fbr1_base_lo;				/*  0x2058 */
+	u32 fbr1_base_hi;				/*  0x205C */
+	u32 fbr1_num_des;				/*  0x2060 */
+	u32 fbr1_avail_offset;				/*  0x2064 */
+	u32 fbr1_full_offset;				/*  0x2068 */
+	u32 fbr1_rd_index;				/*  0x206C */
+	u32 fbr1_min_des;				/*  0x2070 */
+};
+
+/* END OF RXDMA REGISTER ADDRESS MAP */
+
+
+/* START OF TXMAC REGISTER ADDRESS MAP */
+
+/*
+ * structure for control reg in txmac address map
+ * located at address 0x3000
+ *
+ * bits
+ * 31-8: unused
+ * 7: cklseg_disable
+ * 6: ckbcnt_disable
+ * 5: cksegnum
+ * 4: async_disable
+ * 3: fc_disable
+ * 2: mcif_disable
+ * 1: mif_disable
+ * 0: txmac_en
+ */
+
+#define ET_TX_CTRL_FC_DISABLE	0x0008
+#define ET_TX_CTRL_TXMAC_ENABLE	0x0001
+
+/*
+ * structure for shadow pointer reg in txmac address map
+ * located at address 0x3004
+ * 31-27: reserved
+ * 26-16: txq rd ptr
+ * 15-11: reserved
+ * 10-0: txq wr ptr
+ */
+
+/*
+ * structure for error count reg in txmac address map
+ * located at address 0x3008
+ *
+ * 31-12: unused
+ * 11-8: reserved
+ * 7-4: txq_underrun
+ * 3-0: fifo_underrun
+ */
+
+/*
+ * structure for max fill reg in txmac address map
+ * located at address 0x300C
+ * 31-12: unused
+ * 11-0: max fill
+ */
+
+/*
+ * structure for cf parameter reg in txmac address map
+ * located at address 0x3010
+ * 31-16: cfep
+ * 15-0: cfpt
+ */
+
+/*
+ * structure for tx test reg in txmac address map
+ * located at address 0x3014
+ * 31-17: unused
+ * 16: reserved
+ * 15: txtest_en
+ * 14-11: unused
+ * 10-0: txq test pointer
+ */
+
+/*
+ * structure for error reg in txmac address map
+ * located at address 0x3018
+ *
+ * 31-9: unused
+ * 8: fifo_underrun
+ * 7-6: unused
+ * 5: ctrl2_err
+ * 4: txq_underrun
+ * 3: bcnt_err
+ * 2: lseg_err
+ * 1: segnum_err
+ * 0: seg0_err
+ */
+
+/*
+ * structure for error interrupt reg in txmac address map
+ * located at address 0x301C
+ *
+ * 31-9: unused
+ * 8: fifo_underrun
+ * 7-6: unused
+ * 5: ctrl2_err
+ * 4: txq_underrun
+ * 3: bcnt_err
+ * 2: lseg_err
+ * 1: segnum_err
+ * 0: seg0_err
+ */
+
+/*
+ * structure for error interrupt reg in txmac address map
+ * located at address 0x3020
+ *
+ * 31-2: unused
+ * 1: bp_req
+ * 0: bp_xonxoff
+ */
+
+/*
+ * Tx MAC Module of JAGCore Address Mapping
+ */
+struct txmac_regs {			/* Location: */
+	u32 ctl;			/*  0x3000 */
+	u32 shadow_ptr;			/*  0x3004 */
+	u32 err_cnt;			/*  0x3008 */
+	u32 max_fill;			/*  0x300C */
+	u32 cf_param;			/*  0x3010 */
+	u32 tx_test;			/*  0x3014 */
+	u32 err;			/*  0x3018 */
+	u32 err_int;			/*  0x301C */
+	u32 bp_ctrl;			/*  0x3020 */
+};
+
+/* END OF TXMAC REGISTER ADDRESS MAP */
+
+/* START OF RXMAC REGISTER ADDRESS MAP */
+
+/*
+ * structure for rxmac control reg in rxmac address map
+ * located at address 0x4000
+ *
+ * 31-7: reserved
+ * 6: rxmac_int_disable
+ * 5: async_disable
+ * 4: mif_disable
+ * 3: wol_disable
+ * 2: pkt_filter_disable
+ * 1: mcif_disable
+ * 0: rxmac_en
+ */
+
+#define ET_RX_CTRL_WOL_DISABLE	0x0008
+#define ET_RX_CTRL_RXMAC_ENABLE	0x0001
+
+/*
+ * structure for Wake On Lan Control and CRC 0 reg in rxmac address ma=
p
+ * located at address 0x4004
+ * 31-16: crc
+ * 15-12: reserved
+ * 11: ignore_pp
+ * 10: ignore_mp
+ * 9: clr_intr
+ * 8: ignore_link_chg
+ * 7: ignore_uni
+ * 6: ignore_multi
+ * 5: ignore_broad
+ * 4-0: valid_crc 4-0
+ */
+
+/*
+ * structure for CRC 1 and CRC 2 reg in rxmac address map
+ * located at address 0x4008
+ *
+ * 31-16: crc2
+ * 15-0: crc1
+ */
+
+/*
+ * structure for CRC 3 and CRC 4 reg in rxmac address map
+ * located at address 0x400C
+ *
+ * 31-16: crc4
+ * 15-0: crc3
+ */
+
+/*
+ * structure for Wake On Lan Source Address Lo reg in rxmac address ma=
p
+ * located at address 0x4010
+ *
+ * 31-24: sa3
+ * 23-16: sa4
+ * 15-8: sa5
+ * 7-0: sa6
+ */
+
+#define ET_RX_WOL_LO_SA3_SHIFT 24
+#define ET_RX_WOL_LO_SA4_SHIFT 16
+#define ET_RX_WOL_LO_SA5_SHIFT 8
+
+/*
+ * structure for Wake On Lan Source Address Hi reg in rxmac address ma=
p
+ * located at address 0x4014
+ *
+ * 31-16: reserved
+ * 15-8: sa1
+ * 7-0: sa2
+ */
+
+#define ET_RX_WOL_HI_SA1_SHIFT 8
+
+/*
+ * structure for Wake On Lan mask reg in rxmac address map
+ * located at address 0x4018 - 0x4064
+ * Defined earlier (u32)
+ */
+
+/*
+ * structure for Unicast Paket Filter Address 1 reg in rxmac address m=
ap
+ * located at address 0x4068
+ *
+ * 31-24: addr1_3
+ * 23-16: addr1_4
+ * 15-8: addr1_5
+ * 7-0: addr1_6
+ */
+
+#define ET_RX_UNI_PF_ADDR1_3_SHIFT 24
+#define ET_RX_UNI_PF_ADDR1_4_SHIFT 16
+#define ET_RX_UNI_PF_ADDR1_5_SHIFT 8
+
+/*
+ * structure for Unicast Paket Filter Address 2 reg in rxmac address m=
ap
+ * located at address 0x406C
+ *
+ * 31-24: addr2_3
+ * 23-16: addr2_4
+ * 15-8: addr2_5
+ * 7-0: addr2_6
+ */
+
+#define ET_RX_UNI_PF_ADDR2_3_SHIFT 24
+#define ET_RX_UNI_PF_ADDR2_4_SHIFT 16
+#define ET_RX_UNI_PF_ADDR2_5_SHIFT 8
+
+/*
+ * structure for Unicast Paket Filter Address 1 & 2 reg in rxmac addre=
ss map
+ * located at address 0x4070
+ *
+ * 31-24: addr2_1
+ * 23-16: addr2_2
+ * 15-8: addr1_1
+ * 7-0: addr1_2
+ */
+
+#define ET_RX_UNI_PF_ADDR2_1_SHIFT 24
+#define ET_RX_UNI_PF_ADDR2_2_SHIFT 16
+#define ET_RX_UNI_PF_ADDR1_1_SHIFT 8
+
+/*
+ * structure for Multicast Hash reg in rxmac address map
+ * located at address 0x4074 - 0x4080
+ * Defined earlier (u32)
+ */
+
+/*
+ * structure for Packet Filter Control reg in rxmac address map
+ * located at address 0x4084
+ *
+ * 31-23: unused
+ * 22-16: min_pkt_size
+ * 15-4: unused
+ * 3: filter_frag_en
+ * 2: filter_uni_en
+ * 1: filter_multi_en
+ * 0: filter_broad_en
+ */
+
+#define ET_RX_PFCTRL_MIN_PKT_SZ_SHIFT		16;
+#define ET_RX_PFCTRL_FRAG_FILTER_ENABLE		0x0008;
+#define ET_RX_PFCTRL_UNICST_FILTER_ENABLE	0x0004;
+#define ET_RX_PFCTRL_MLTCST_FILTER_ENABLE	0x0002;
+#define ET_RX_PFCTRL_BRDCST_FILTER_ENABLE	0x0001;
+
+/*
+ * structure for Memory Controller Interface Control Max Segment reg i=
n rxmac
+ * address map.  Located at address 0x4088
+ *
+ * 31-10: reserved
+ * 9-2: max_size
+ * 1: fc_en
+ * 0: seg_en
+ */
+
+#define ET_RX_MCIF_CTRL_MAX_SEG_SIZE_SHIFT	2;
+#define ET_RX_MCIF_CTRL_MAX_SEG_FC_ENABLE	0x0002;
+#define ET_RX_MCIF_CTRL_MAX_SEG_ENABLE		0x0001;
+
+/*
+ * structure for Memory Controller Interface Water Mark reg in rxmac a=
ddress
+ * map.  Located at address 0x408C
+ *
+ * 31-26: unused
+ * 25-16: mark_hi
+ * 15-10: unused
+ * 9-0: mark_lo
+ */
+
+/*
+ * structure for Rx Queue Dialog reg in rxmac address map.
+ * located at address 0x4090
+ *
+ * 31-26: reserved
+ * 25-16: rd_ptr
+ * 15-10: reserved
+ * 9-0: wr_ptr
+ */
+
+/*
+ * structure for space available reg in rxmac address map.
+ * located at address 0x4094
+ *
+ * 31-17: reserved
+ * 16: space_avail_en
+ * 15-10: reserved
+ * 9-0: space_avail
+ */
+
+/*
+ * structure for management interface reg in rxmac address map.
+ * located at address 0x4098
+ *
+ * 31-18: reserved
+ * 17: drop_pkt_en
+ * 16-0: drop_pkt_mask
+ */
+
+/*
+ * structure for Error reg in rxmac address map.
+ * located at address 0x409C
+ *
+ * 31-4: unused
+ * 3: mif
+ * 2: async
+ * 1: pkt_filter
+ * 0: mcif
+ */
+
+/*
+ * Rx MAC Module of JAGCore Address Mapping
+ */
+struct rxmac_regs {					/* Location: */
+	u32 ctrl;					/*  0x4000 */
+	u32 crc0;					/*  0x4004 */
+	u32 crc12;					/*  0x4008 */
+	u32 crc34;					/*  0x400C */
+	u32 sa_lo;					/*  0x4010 */
+	u32 sa_hi;					/*  0x4014 */
+	u32 mask0_word0;				/*  0x4018 */
+	u32 mask0_word1;				/*  0x401C */
+	u32 mask0_word2;				/*  0x4020 */
+	u32 mask0_word3;				/*  0x4024 */
+	u32 mask1_word0;				/*  0x4028 */
+	u32 mask1_word1;				/*  0x402C */
+	u32 mask1_word2;				/*  0x4030 */
+	u32 mask1_word3;				/*  0x4034 */
+	u32 mask2_word0;				/*  0x4038 */
+	u32 mask2_word1;				/*  0x403C */
+	u32 mask2_word2;				/*  0x4040 */
+	u32 mask2_word3;				/*  0x4044 */
+	u32 mask3_word0;				/*  0x4048 */
+	u32 mask3_word1;				/*  0x404C */
+	u32 mask3_word2;				/*  0x4050 */
+	u32 mask3_word3;				/*  0x4054 */
+	u32 mask4_word0;				/*  0x4058 */
+	u32 mask4_word1;				/*  0x405C */
+	u32 mask4_word2;				/*  0x4060 */
+	u32 mask4_word3;				/*  0x4064 */
+	u32 uni_pf_addr1;				/*  0x4068 */
+	u32 uni_pf_addr2;				/*  0x406C */
+	u32 uni_pf_addr3;				/*  0x4070 */
+	u32 multi_hash1;				/*  0x4074 */
+	u32 multi_hash2;				/*  0x4078 */
+	u32 multi_hash3;				/*  0x407C */
+	u32 multi_hash4;				/*  0x4080 */
+	u32 pf_ctrl;					/*  0x4084 */
+	u32 mcif_ctrl_max_seg;				/*  0x4088 */
+	u32 mcif_water_mark;				/*  0x408C */
+	u32 rxq_diag;					/*  0x4090 */
+	u32 space_avail;				/*  0x4094 */
+
+	u32 mif_ctrl;					/*  0x4098 */
+	u32 err_reg;					/*  0x409C */
+};
+
+/* END OF RXMAC REGISTER ADDRESS MAP */
+
+/* START OF MAC REGISTER ADDRESS MAP */
+
+/*
+ * structure for configuration #1 reg in mac address map.
+ * located at address 0x5000
+ *
+ * 31: soft reset
+ * 30: sim reset
+ * 29-20: reserved
+ * 19: reset rx mc
+ * 18: reset tx mc
+ * 17: reset rx func
+ * 16: reset tx fnc
+ * 15-9: reserved
+ * 8: loopback
+ * 7-6: reserved
+ * 5: rx flow
+ * 4: tx flow
+ * 3: syncd rx en
+ * 2: rx enable
+ * 1: syncd tx en
+ * 0: tx enable
+ */
+
+#define ET_MAC_CFG1_SOFT_RESET		0x80000000
+#define ET_MAC_CFG1_SIM_RESET		0x40000000
+#define ET_MAC_CFG1_RESET_RXMC		0x00080000
+#define ET_MAC_CFG1_RESET_TXMC		0x00040000
+#define ET_MAC_CFG1_RESET_RXFUNC	0x00020000
+#define ET_MAC_CFG1_RESET_TXFUNC	0x00010000
+#define ET_MAC_CFG1_LOOPBACK		0x00000100
+#define ET_MAC_CFG1_RX_FLOW		0x00000020
+#define ET_MAC_CFG1_TX_FLOW		0x00000010
+#define ET_MAC_CFG1_RX_ENABLE		0x00000004
+#define ET_MAC_CFG1_TX_ENABLE		0x00000001
+#define ET_MAC_CFG1_WAIT		0x0000000A	/* RX & TX syncd */
+
+/*
+ * structure for configuration #2 reg in mac address map.
+ * located at address 0x5004
+ * 31-16: reserved
+ * 15-12: preamble
+ * 11-10: reserved
+ * 9-8: if mode
+ * 7-6: reserved
+ * 5: huge frame
+ * 4: length check
+ * 3: undefined
+ * 2: pad crc
+ * 1: crc enable
+ * 0: full duplex
+ */
+
+#define ET_MAC_CFG2_PREAMBLE_SHIFT	12;
+#define ET_MAC_CFG2_IFMODE_MASK		0x0300;
+#define ET_MAC_CFG2_IFMODE_1000		0x0200;
+#define ET_MAC_CFG2_IFMODE_100		0x0100;
+#define ET_MAC_CFG2_IFMODE_HUGE_FRAME	0x0020;
+#define ET_MAC_CFG2_IFMODE_LEN_CHECK	0x0010;
+#define ET_MAC_CFG2_IFMODE_PAD_CRC	0x0004;
+#define ET_MAC_CFG2_IFMODE_CRC_ENABLE	0x0002;
+#define ET_MAC_CFG2_IFMODE_FULL_DPLX	0x0001;
+
+/*
+ * structure for Interpacket gap reg in mac address map.
+ * located at address 0x5008
+ *
+ * 31: reserved
+ * 30-24: non B2B ipg 1
+ * 23: undefined
+ * 22-16: non B2B ipg 2
+ * 15-8: Min ifg enforce
+ * 7-0: B2B ipg
+ *
+ * structure for half duplex reg in mac address map.
+ * located at address 0x500C
+ * 31-24: reserved
+ * 23-20: Alt BEB trunc
+ * 19: Alt BEB enable
+ * 18: BP no backoff
+ * 17: no backoff
+ * 16: excess defer
+ * 15-12: re-xmit max
+ * 11-10: reserved
+ * 9-0: collision window
+ */
+
+/*
+ * structure for Maximum Frame Length reg in mac address map.
+ * located at address 0x5010: bits 0-15 hold the length.
+ */
+
+/*
+ * structure for Reserve 1 reg in mac address map.
+ * located at address 0x5014 - 0x5018
+ * Defined earlier (u32)
+ */
+
+/*
+ * structure for Test reg in mac address map.
+ * located at address 0x501C
+ * test: bits 0-2, rest unused
+ */
+
+/*
+ * structure for MII Management Configuration reg in mac address map.
+ * located at address 0x5020
+ *
+ * 31: reset MII mgmt
+ * 30-6: unused
+ * 5: scan auto increment
+ * 4: preamble suppress
+ * 3: undefined
+ * 2-0: mgmt clock reset
+ */
+
+#define ET_MAC_MIIMGMT_CLK_RST	0x0007
+
+/*
+ * structure for MII Management Command reg in mac address map.
+ * located at address 0x5024
+ * bit 1: scan cycle
+ * bit 0: read cycle
+ */
+
+/*
+ * structure for MII Management Address reg in mac address map.
+ * located at address 0x5028
+ * 31-13: reserved
+ * 12-8: phy addr
+ * 7-5: reserved
+ * 4-0: register
+ */
+
+#define ET_MAC_MII_ADDR(phy, reg)	((phy) << 8 | (reg))
+
+/*
+ * structure for MII Management Control reg in mac address map.
+ * located at address 0x502C
+ * 31-16: reserved
+ * 15-0: phy control
+ */
+
+/*
+ * structure for MII Management Status reg in mac address map.
+ * located at address 0x5030
+ * 31-16: reserved
+ * 15-0: phy control
+ */
+
+#define ET_MAC_MIIMGMT_STAT_PHYCRTL_MASK 0xFFFF;
+
+/*
+ * structure for MII Management Indicators reg in mac address map.
+ * located at address 0x5034
+ * 31-3: reserved
+ * 2: not valid
+ * 1: scanning
+ * 0: busy
+ */
+
+#define ET_MAC_MGMT_BUSY	0x00000001	/* busy */
+#define ET_MAC_MGMT_WAIT	0x00000005	/* busy | not valid */
+
+/*
+ * structure for Interface Control reg in mac address map.
+ * located at address 0x5038
+ *
+ * 31: reset if module
+ * 30-28: reserved
+ * 27: tbi mode
+ * 26: ghd mode
+ * 25: lhd mode
+ * 24: phy mode
+ * 23: reset per mii
+ * 22-17: reserved
+ * 16: speed
+ * 15: reset pe100x
+ * 14-11: reserved
+ * 10: force quiet
+ * 9: no cipher
+ * 8: disable link fail
+ * 7: reset gpsi
+ * 6-1: reserved
+ * 0: enable jabber protection
+ */
+
+#define ET_MAC_IFCTRL_GHDMODE	(1 << 26)
+#define ET_MAC_IFCTRL_PHYMODE	(1 << 24)
+
+/*
+ * structure for Interface Status reg in mac address map.
+ * located at address 0x503C
+ *
+ * 31-10: reserved
+ * 9: excess_defer
+ * 8: clash
+ * 7: phy_jabber
+ * 6: phy_link_ok
+ * 5: phy_full_duplex
+ * 4: phy_speed
+ * 3: pe100x_link_fail
+ * 2: pe10t_loss_carrier
+ * 1: pe10t_sqe_error
+ * 0: pe10t_jabber
+ */
+
+/*
+ * structure for Mac Station Address, Part 1 reg in mac address map.
+ * located at address 0x5040
+ *
+ * 31-24: Octet6
+ * 23-16: Octet5
+ * 15-8: Octet4
+ * 7-0: Octet3
+ */
+
+#define ET_MAC_STATION_ADDR1_OC6_SHIFT 24
+#define ET_MAC_STATION_ADDR1_OC5_SHIFT 16
+#define ET_MAC_STATION_ADDR1_OC4_SHIFT 8
+
+/*
+ * structure for Mac Station Address, Part 2 reg in mac address map.
+ * located at address 0x5044
+ *
+ * 31-24: Octet2
+ * 23-16: Octet1
+ * 15-0: reserved
+ */
+
+#define ET_MAC_STATION_ADDR2_OC2_SHIFT 24
+#define ET_MAC_STATION_ADDR2_OC1_SHIFT 16
+
+/*
+ * MAC Module of JAGCore Address Mapping
+ */
+struct mac_regs {					/* Location: */
+	u32 cfg1;					/*  0x5000 */
+	u32 cfg2;					/*  0x5004 */
+	u32 ipg;					/*  0x5008 */
+	u32 hfdp;					/*  0x500C */
+	u32 max_fm_len;					/*  0x5010 */
+	u32 rsv1;					/*  0x5014 */
+	u32 rsv2;					/*  0x5018 */
+	u32 mac_test;					/*  0x501C */
+	u32 mii_mgmt_cfg;				/*  0x5020 */
+	u32 mii_mgmt_cmd;				/*  0x5024 */
+	u32 mii_mgmt_addr;				/*  0x5028 */
+	u32 mii_mgmt_ctrl;				/*  0x502C */
+	u32 mii_mgmt_stat;				/*  0x5030 */
+	u32 mii_mgmt_indicator;				/*  0x5034 */
+	u32 if_ctrl;					/*  0x5038 */
+	u32 if_stat;					/*  0x503C */
+	u32 station_addr_1;				/*  0x5040 */
+	u32 station_addr_2;				/*  0x5044 */
+};
+
+/* END OF MAC REGISTER ADDRESS MAP */
+
+/* START OF MAC STAT REGISTER ADDRESS MAP */
+
+/*
+ * structure for Carry Register One and it's Mask Register reg located=
 in mac
+ * stat address map address 0x6130 and 0x6138.
+ *
+ * 31: tr64
+ * 30: tr127
+ * 29: tr255
+ * 28: tr511
+ * 27: tr1k
+ * 26: trmax
+ * 25: trmgv
+ * 24-17: unused
+ * 16: rbyt
+ * 15: rpkt
+ * 14: rfcs
+ * 13: rmca
+ * 12: rbca
+ * 11: rxcf
+ * 10: rxpf
+ * 9: rxuo
+ * 8: raln
+ * 7: rflr
+ * 6: rcde
+ * 5: rcse
+ * 4: rund
+ * 3: rovr
+ * 2: rfrg
+ * 1: rjbr
+ * 0: rdrp
+ */
+
+/*
+ * structure for Carry Register Two Mask Register reg in mac stat addr=
ess map.
+ * located at address 0x613C
+ *
+ * 31-20: unused
+ * 19: tjbr
+ * 18: tfcs
+ * 17: txcf
+ * 16: tovr
+ * 15: tund
+ * 14: trfg
+ * 13: tbyt
+ * 12: tpkt
+ * 11: tmca
+ * 10: tbca
+ * 9: txpf
+ * 8: tdfr
+ * 7: tedf
+ * 6: tscl
+ * 5: tmcl
+ * 4: tlcl
+ * 3: txcl
+ * 2: tncl
+ * 1: tpfh
+ * 0: tdrp
+ */
+
+/*
+ * MAC STATS Module of JAGCore Address Mapping
+ */
+struct macstat_regs {			/* Location: */
+	u32 pad[32];			/*  0x6000 - 607C */
+
+	/* Tx/Rx 0-64 Byte Frame Counter */
+	u32 txrx_0_64_byte_frames;	/*  0x6080 */
+
+	/* Tx/Rx 65-127 Byte Frame Counter */
+	u32 txrx_65_127_byte_frames;	/*  0x6084 */
+
+	/* Tx/Rx 128-255 Byte Frame Counter */
+	u32 txrx_128_255_byte_frames;	/*  0x6088 */
+
+	/* Tx/Rx 256-511 Byte Frame Counter */
+	u32 txrx_256_511_byte_frames;	/*  0x608C */
+
+	/* Tx/Rx 512-1023 Byte Frame Counter */
+	u32 txrx_512_1023_byte_frames;	/*  0x6090 */
+
+	/* Tx/Rx 1024-1518 Byte Frame Counter */
+	u32 txrx_1024_1518_byte_frames;	/*  0x6094 */
+
+	/* Tx/Rx 1519-1522 Byte Good VLAN Frame Count */
+	u32 txrx_1519_1522_gvln_frames;	/*  0x6098 */
+
+	/* Rx Byte Counter */
+	u32 rx_bytes;			/*  0x609C */
+
+	/* Rx Packet Counter */
+	u32 rx_packets;			/*  0x60A0 */
+
+	/* Rx FCS Error Counter */
+	u32 rx_fcs_errs;		/*  0x60A4 */
+
+	/* Rx Multicast Packet Counter */
+	u32 rx_multicast_packets;	/*  0x60A8 */
+
+	/* Rx Broadcast Packet Counter */
+	u32 rx_broadcast_packets;	/*  0x60AC */
+
+	/* Rx Control Frame Packet Counter */
+	u32 rx_control_frames;		/*  0x60B0 */
+
+	/* Rx Pause Frame Packet Counter */
+	u32 rx_pause_frames;		/*  0x60B4 */
+
+	/* Rx Unknown OP Code Counter */
+	u32 rx_unknown_opcodes;		/*  0x60B8 */
+
+	/* Rx Alignment Error Counter */
+	u32 rx_align_errs;		/*  0x60BC */
+
+	/* Rx Frame Length Error Counter */
+	u32 rx_frame_len_errs;		/*  0x60C0 */
+
+	/* Rx Code Error Counter */
+	u32 rx_code_errs;		/*  0x60C4 */
+
+	/* Rx Carrier Sense Error Counter */
+	u32 rx_carrier_sense_errs;	/*  0x60C8 */
+
+	/* Rx Undersize Packet Counter */
+	u32 rx_undersize_packets;	/*  0x60CC */
+
+	/* Rx Oversize Packet Counter */
+	u32 rx_oversize_packets;	/*  0x60D0 */
+
+	/* Rx Fragment Counter */
+	u32 rx_fragment_packets;	/*  0x60D4 */
+
+	/* Rx Jabber Counter */
+	u32 rx_jabbers;			/*  0x60D8 */
+
+	/* Rx Drop */
+	u32 rx_drops;			/*  0x60DC */
+
+	/* Tx Byte Counter */
+	u32 tx_bytes;			/*  0x60E0 */
+
+	/* Tx Packet Counter */
+	u32 tx_packets;			/*  0x60E4 */
+
+	/* Tx Multicast Packet Counter */
+	u32 tx_multicast_packets;	/*  0x60E8 */
+
+	/* Tx Broadcast Packet Counter */
+	u32 tx_broadcast_packets;	/*  0x60EC */
+
+	/* Tx Pause Control Frame Counter */
+	u32 tx_pause_frames;		/*  0x60F0 */
+
+	/* Tx Deferral Packet Counter */
+	u32 tx_deferred;		/*  0x60F4 */
+
+	/* Tx Excessive Deferral Packet Counter */
+	u32 tx_excessive_deferred;	/*  0x60F8 */
+
+	/* Tx Single Collision Packet Counter */
+	u32 tx_single_collisions;	/*  0x60FC */
+
+	/* Tx Multiple Collision Packet Counter */
+	u32 tx_multiple_collisions;	/*  0x6100 */
+
+	/* Tx Late Collision Packet Counter */
+	u32 tx_late_collisions;		/*  0x6104 */
+
+	/* Tx Excessive Collision Packet Counter */
+	u32 tx_excessive_collisions;	/*  0x6108 */
+
+	/* Tx Total Collision Packet Counter */
+	u32 tx_total_collisions;	/*  0x610C */
+
+	/* Tx Pause Frame Honored Counter */
+	u32 tx_pause_honored_frames;	/*  0x6110 */
+
+	/* Tx Drop Frame Counter */
+	u32 tx_drops;			/*  0x6114 */
+
+	/* Tx Jabber Frame Counter */
+	u32 tx_jabbers;			/*  0x6118 */
+
+	/* Tx FCS Error Counter */
+	u32 tx_fcs_errs;		/*  0x611C */
+
+	/* Tx Control Frame Counter */
+	u32 tx_control_frames;		/*  0x6120 */
+
+	/* Tx Oversize Frame Counter */
+	u32 tx_oversize_frames;		/*  0x6124 */
+
+	/* Tx Undersize Frame Counter */
+	u32 tx_undersize_frames;	/*  0x6128 */
+
+	/* Tx Fragments Frame Counter */
+	u32 tx_fragments;		/*  0x612C */
+
+	/* Carry Register One Register */
+	u32 carry_reg1;			/*  0x6130 */
+
+	/* Carry Register Two Register */
+	u32 carry_reg2;			/*  0x6134 */
+
+	/* Carry Register One Mask Register */
+	u32 carry_reg1_mask;		/*  0x6138 */
+
+	/* Carry Register Two Mask Register */
+	u32 carry_reg2_mask;		/*  0x613C */
+};
+
+/* END OF MAC STAT REGISTER ADDRESS MAP */
+
+/* START OF MMC REGISTER ADDRESS MAP */
+
+/*
+ * Main Memory Controller Control reg in mmc address map.
+ * located at address 0x7000
+ */
+
+#define ET_MMC_ENABLE		1
+#define ET_MMC_ARB_DISABLE	2
+#define ET_MMC_RXMAC_DISABLE	4
+#define ET_MMC_TXMAC_DISABLE	8
+#define ET_MMC_TXDMA_DISABLE	16
+#define ET_MMC_RXDMA_DISABLE	32
+#define ET_MMC_FORCE_CE		64
+
+/*
+ * Main Memory Controller Host Memory Access Address reg in mmc
+ * address map.  Located at address 0x7004. Top 16 bits hold the addre=
ss bits
+ */
+
+#define ET_SRAM_REQ_ACCESS	1
+#define ET_SRAM_WR_ACCESS	2
+#define ET_SRAM_IS_CTRL		4
+
+/*
+ * structure for Main Memory Controller Host Memory Access Data reg in=
 mmc
+ * address map.  Located at address 0x7008 - 0x7014
+ * Defined earlier (u32)
+ */
+
+/*
+ * Memory Control Module of JAGCore Address Mapping
+ */
+struct mmc_regs {		/* Location: */
+	u32 mmc_ctrl;		/*  0x7000 */
+	u32 sram_access;	/*  0x7004 */
+	u32 sram_word1;		/*  0x7008 */
+	u32 sram_word2;		/*  0x700C */
+	u32 sram_word3;		/*  0x7010 */
+	u32 sram_word4;		/*  0x7014 */
+};
+
+/* END OF MMC REGISTER ADDRESS MAP */
+
+
+/*
+ * JAGCore Address Mapping
+ */
+struct address_map {
+	struct global_regs global;
+	/* unused section of global address map */
+	u8 unused_global[4096 - sizeof(struct global_regs)];
+	struct txdma_regs txdma;
+	/* unused section of txdma address map */
+	u8 unused_txdma[4096 - sizeof(struct txdma_regs)];
+	struct rxdma_regs rxdma;
+	/* unused section of rxdma address map */
+	u8 unused_rxdma[4096 - sizeof(struct rxdma_regs)];
+	struct txmac_regs txmac;
+	/* unused section of txmac address map */
+	u8 unused_txmac[4096 - sizeof(struct txmac_regs)];
+	struct rxmac_regs rxmac;
+	/* unused section of rxmac address map */
+	u8 unused_rxmac[4096 - sizeof(struct rxmac_regs)];
+	struct mac_regs mac;
+	/* unused section of mac address map */
+	u8 unused_mac[4096 - sizeof(struct mac_regs)];
+	struct macstat_regs macstat;
+	/* unused section of mac stat address map */
+	u8 unused_mac_stat[4096 - sizeof(struct macstat_regs)];
+	struct mmc_regs mmc;
+	/* unused section of mmc address map */
+	u8 unused_mmc[4096 - sizeof(struct mmc_regs)];
+	/* unused section of address map */
+	u8 unused_[1015808];
+
+	u8 unused_exp_rom[4096];	/* MGS-size TBD */
+	u8 unused__[524288];	/* unused section of address map */
+};
+
+/*
+ * Defines for generic MII registers 0x00 -> 0x0F can be found in
+ * include/linux/mii.h
+ */
+
+/* some defines for modem registers that seem to be 'reserved' */
+#define PHY_INDEX_REG              0x10
+#define PHY_DATA_REG               0x11
+#define PHY_MPHY_CONTROL_REG       0x12
+
+/* defines for specified registers */
+#define PHY_LOOPBACK_CONTROL       0x13	/* TRU_VMI_LOOPBACK_CONTROL_1_=
REG 19 */
+					/* TRU_VMI_LOOPBACK_CONTROL_2_REG 20 */
+#define PHY_REGISTER_MGMT_CONTROL  0x15	/* TRU_VMI_MI_SEQ_CONTROL_REG =
    21 */
+#define PHY_CONFIG                 0x16	/* TRU_VMI_CONFIGURATION_REG  =
    22 */
+#define PHY_PHY_CONTROL            0x17	/* TRU_VMI_PHY_CONTROL_REG    =
    23 */
+#define PHY_INTERRUPT_MASK         0x18	/* TRU_VMI_INTERRUPT_MASK_REG =
    24 */
+#define PHY_INTERRUPT_STATUS       0x19	/* TRU_VMI_INTERRUPT_STATUS_RE=
G   25 */
+#define PHY_PHY_STATUS             0x1A	/* TRU_VMI_PHY_STATUS_REG     =
    26 */
+#define PHY_LED_1                  0x1B	/* TRU_VMI_LED_CONTROL_1_REG  =
    27 */
+#define PHY_LED_2                  0x1C	/* TRU_VMI_LED_CONTROL_2_REG  =
    28 */
+					/* TRU_VMI_LINK_CONTROL_REG       29 */
+					/* TRU_VMI_TIMING_CONTROL_REG        */
+
+/* MI Register 10: Gigabit basic mode status reg(Reg 0x0A) */
+#define ET_1000BT_MSTR_SLV 0x4000
+
+/* MI Register 16 - 18: Reserved Reg(0x10-0x12) */
+
+/* MI Register 19: Loopback Control Reg(0x13)
+ *	15:	mii_en
+ *	14:	pcs_en
+ *	13:	pmd_en
+ *	12:	all_digital_en
+ *	11:	replica_en
+ *	10:	line_driver_en
+ *	9-0:	reserved
+ */
+
+/* MI Register 20: Reserved Reg(0x14) */
+
+/* MI Register 21: Management Interface Control Reg(0x15)
+ *	15-11:	reserved
+ *	10-4:	mi_error_count
+ *	3:	reserved
+ *	2:	ignore_10g_fr
+ *	1:	reserved
+ *	0:	preamble_suppress_en
+ */
+
+/* MI Register 22: PHY Configuration Reg(0x16)
+ *	15:	crs_tx_en
+ *	14:	reserved
+ *	13-12:	tx_fifo_depth
+ *	11-10:	speed_downshift
+ *	9:	pbi_detect
+ *	8:	tbi_rate
+ *	7:	alternate_np
+ *	6:	group_mdio_en
+ *	5:	tx_clock_en
+ *	4:	sys_clock_en
+ *	3:	reserved
+ *	2-0:	mac_if_mode
+ */
+
+#define ET_PHY_CONFIG_TX_FIFO_DEPTH	0x3000
+
+#define ET_PHY_CONFIG_FIFO_DEPTH_8	0x0000
+#define ET_PHY_CONFIG_FIFO_DEPTH_16	0x1000
+#define ET_PHY_CONFIG_FIFO_DEPTH_32	0x2000
+#define ET_PHY_CONFIG_FIFO_DEPTH_64	0x3000
+
+/* MI Register 23: PHY CONTROL Reg(0x17)
+ *	15:	reserved
+ *	14:	tdr_en
+ *	13:	reserved
+ *	12-11:	downshift_attempts
+ *	10-6:	reserved
+ *	5:	jabber_10baseT
+ *	4:	sqe_10baseT
+ *	3:	tp_loopback_10baseT
+ *	2:	preamble_gen_en
+ *	1:	reserved
+ *	0:	force_int
+ */
+
+/* MI Register 24: Interrupt Mask Reg(0x18)
+ *	15-10:	reserved
+ *	9:	mdio_sync_lost
+ *	8:	autoneg_status
+ *	7:	hi_bit_err
+ *	6:	np_rx
+ *	5:	err_counter_full
+ *	4:	fifo_over_underflow
+ *	3:	rx_status
+ *	2:	link_status
+ *	1:	automatic_speed
+ *	0:	int_en
+ */
+
+/* MI Register 25: Interrupt Status Reg(0x19)
+ *	15-10:	reserved
+ *	9:	mdio_sync_lost
+ *	8:	autoneg_status
+ *	7:	hi_bit_err
+ *	6:	np_rx
+ *	5:	err_counter_full
+ *	4:	fifo_over_underflow
+ *	3:	rx_status
+ *	2:	link_status
+ *	1:	automatic_speed
+ *	0:	int_en
+ */
+
+/* MI Register 26: PHY Status Reg(0x1A)
+ *	15:	reserved
+ *	14-13:	autoneg_fault
+ *	12:	autoneg_status
+ *	11:	mdi_x_status
+ *	10:	polarity_status
+ *	9-8:	speed_status
+ *	7:	duplex_status
+ *	6:	link_status
+ *	5:	tx_status
+ *	4:	rx_status
+ *	3:	collision_status
+ *	2:	autoneg_en
+ *	1:	pause_en
+ *	0:	asymmetric_dir
+ */
+#define ET_PHY_AUTONEG_STATUS	0x1000
+#define ET_PHY_POLARITY_STATUS	0x0400
+#define ET_PHY_SPEED_STATUS	0x0300
+#define ET_PHY_DUPLEX_STATUS	0x0080
+#define ET_PHY_LSTATUS		0x0040
+#define ET_PHY_AUTONEG_ENABLE	0x0020
+
+/* MI Register 27: LED Control Reg 1(0x1B)
+ *	15-14:	reserved
+ *	13-12:	led_dup_indicate
+ *	11-10:	led_10baseT
+ *	9-8:	led_collision
+ *	7-4:	reserved
+ *	3-2:	pulse_dur
+ *	1:	pulse_stretch1
+ *	0:	pulse_stretch0
+ */
+
+/* MI Register 28: LED Control Reg 2(0x1C)
+ *	15-12:	led_link
+ *	11-8:	led_tx_rx
+ *	7-4:	led_100BaseTX
+ *	3-0:	led_1000BaseT
+ */
+#define ET_LED2_LED_LINK	0xF000
+#define ET_LED2_LED_TXRX	0x0F00
+#define ET_LED2_LED_100TX	0x00F0
+#define ET_LED2_LED_1000T	0x000F
+
+/* defines for LED control reg 2 values */
+#define LED_VAL_1000BT			0x0
+#define LED_VAL_100BTX			0x1
+#define LED_VAL_10BT			0x2
+#define LED_VAL_1000BT_100BTX		0x3 /* 1000BT on, 100BTX blink */
+#define LED_VAL_LINKON			0x4
+#define LED_VAL_TX			0x5
+#define LED_VAL_RX			0x6
+#define LED_VAL_TXRX			0x7 /* TX or RX */
+#define LED_VAL_DUPLEXFULL		0x8
+#define LED_VAL_COLLISION		0x9
+#define LED_VAL_LINKON_ACTIVE		0xA /* Link on, activity blink */
+#define LED_VAL_LINKON_RECV		0xB /* Link on, receive blink */
+#define LED_VAL_DUPLEXFULL_COLLISION	0xC /* Duplex on, collision blink=
 */
+#define LED_VAL_BLINK			0xD
+#define LED_VAL_ON			0xE
+#define LED_VAL_OFF			0xF
+
+#define LED_LINK_SHIFT			12
+#define LED_TXRX_SHIFT			8
+#define LED_100TX_SHIFT			4
+
+/* MI Register 29 - 31: Reserved Reg(0x1D - 0x1E) */
+
+/* Defines for PHY access routines */
+
+/* Define bit operation flags */
+#define TRUEPHY_BIT_CLEAR               0
+#define TRUEPHY_BIT_SET                 1
+#define TRUEPHY_BIT_READ                2
+
+/* Define read/write operation flags */
+#ifndef TRUEPHY_READ
+#define TRUEPHY_READ                    0
+#define TRUEPHY_WRITE                   1
+#define TRUEPHY_MASK                    2
+#endif
+
+/* Define master/slave configuration values */
+#define TRUEPHY_CFG_SLAVE               0
+#define TRUEPHY_CFG_MASTER              1
+
+/* Define MDI/MDI-X settings */
+#define TRUEPHY_MDI                     0
+#define TRUEPHY_MDIX                    1
+#define TRUEPHY_AUTO_MDI_MDIX           2
+
+/* Define 10Base-T link polarities */
+#define TRUEPHY_POLARITY_NORMAL         0
+#define TRUEPHY_POLARITY_INVERTED       1
+
+/* Define auto-negotiation results */
+#define TRUEPHY_ANEG_NOT_COMPLETE       0
+#define TRUEPHY_ANEG_COMPLETE           1
+#define TRUEPHY_ANEG_DISABLED           2
+
+/* Define duplex advertisement flags */
+#define TRUEPHY_ADV_DUPLEX_NONE         0x00
+#define TRUEPHY_ADV_DUPLEX_FULL         0x01
+#define TRUEPHY_ADV_DUPLEX_HALF         0x02
+#define TRUEPHY_ADV_DUPLEX_BOTH     \
+	(TRUEPHY_ADV_DUPLEX_FULL | TRUEPHY_ADV_DUPLEX_HALF)
+
--=20
1.7.10.4
