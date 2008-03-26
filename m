From: Ben Hutchings <bhutchings@solarflare.com>
Subject: [PATCH 3/8] New driver "sfc" for Solarstorm SFC4000 controller (try #9)
Date: Wed, 26 Mar 2008 12:14:27 +0000
Message-ID: <20080326121425.GH24160@solarflare.com>
References: <20080326121210.GE24160@solarflare.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: linux-net-drivers@solarflare.com, Jeff Garzik <jgarzik@pobox.com>,
	David Miller <davem@davemloft.net>
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from 82-69-137-158.dsl.in-addr.zen.co.uk ([82.69.137.158]:59126 "EHLO
	uklogin.uk.level5networks.com" rhost-flags-OK-OK-OK-FAIL)
	by vger.kernel.org with ESMTP id S1753387AbYCZMOp (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 26 Mar 2008 08:14:45 -0400
Content-Disposition: inline
In-Reply-To: <20080326121210.GE24160@solarflare.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Signed-off-by: Ben Hutchings <bhutchings@solarflare.com>
diff --git a/drivers/net/sfc/net_driver.h b/drivers/net/sfc/net_driver.h
new file mode 100644
index 0000000..f0559d0
--- /dev/null
+++ b/drivers/net/sfc/net_driver.h
@@ -0,0 +1,883 @@
+/****************************************************************************
+ * Driver for Solarflare Solarstorm network controllers and boards
+ * Copyright 2005-2006 Fen Systems Ltd.
+ * Copyright 2005-2008 Solarflare Communications Inc.
+ *
+ * This program is free software; you can redistribute it and/or modify it
+ * under the terms of the GNU General Public License version 2 as published
+ * by the Free Software Foundation, incorporated herein by reference.
+ */
+
+/* Common definitions for all Efx net driver code */
+
+#ifndef EFX_NET_DRIVER_H
+#define EFX_NET_DRIVER_H
+
+#include <linux/version.h>
+#include <linux/netdevice.h>
+#include <linux/etherdevice.h>
+#include <linux/ethtool.h>
+#include <linux/if_vlan.h>
+#include <linux/timer.h>
+#include <linux/mii.h>
+#include <linux/list.h>
+#include <linux/pci.h>
+#include <linux/device.h>
+#include <linux/highmem.h>
+#include <linux/workqueue.h>
+#include <linux/inet_lro.h>
+
+#include "enum.h"
+#include "bitfield.h"
+#include "i2c-direct.h"
+
+#define EFX_MAX_LRO_DESCRIPTORS 8
+#define EFX_MAX_LRO_AGGR MAX_SKB_FRAGS
+
+/**************************************************************************
+ *
+ * Build definitions
+ *
+ **************************************************************************/
+#ifndef EFX_DRIVER_NAME
+#define EFX_DRIVER_NAME	"sfc"
+#endif
+#define EFX_DRIVER_VERSION	"2.2.0121"
+
+#ifdef EFX_ENABLE_DEBUG
+#define EFX_BUG_ON_PARANOID(x) BUG_ON(x)
+#define EFX_WARN_ON_PARANOID(x) WARN_ON(x)
+#else
+#define EFX_BUG_ON_PARANOID(x) do {} while (0)
+#define EFX_WARN_ON_PARANOID(x) do {} while (0)
+#endif
+
+#define NET_DEV_REGISTERED(efx)					\
+	((efx)->net_dev->reg_state == NETREG_REGISTERED)
+
+/* Include net device name in log messages if it has been registered.
+ * Use efx->name not efx->net_dev->name so that races with (un)registration
+ * are harmless.
+ */
+#define NET_DEV_NAME(efx) (NET_DEV_REGISTERED(efx) ? (efx)->name : "")
+
+/* Un-rate-limited logging */
+#define EFX_ERR(efx, fmt, args...) \
+dev_err(&((efx)->pci_dev->dev), "ERR: %s " fmt, NET_DEV_NAME(efx), ##args)
+
+#define EFX_INFO(efx, fmt, args...) \
+dev_info(&((efx)->pci_dev->dev), "INFO: %s " fmt, NET_DEV_NAME(efx), ##args)
+
+#ifdef EFX_ENABLE_DEBUG
+#define EFX_LOG(efx, fmt, args...) \
+dev_info(&((efx)->pci_dev->dev), "DBG: %s " fmt, NET_DEV_NAME(efx), ##args)
+#else
+#define EFX_LOG(efx, fmt, args...) \
+dev_dbg(&((efx)->pci_dev->dev), "DBG: %s " fmt, NET_DEV_NAME(efx), ##args)
+#endif
+
+#define EFX_TRACE(efx, fmt, args...) do {} while (0)
+
+#define EFX_REGDUMP(efx, fmt, args...) do {} while (0)
+
+/* Rate-limited logging */
+#define EFX_ERR_RL(efx, fmt, args...) \
+do {if (net_ratelimit()) EFX_ERR(efx, fmt, ##args); } while (0)
+
+#define EFX_INFO_RL(efx, fmt, args...) \
+do {if (net_ratelimit()) EFX_INFO(efx, fmt, ##args); } while (0)
+
+#define EFX_LOG_RL(efx, fmt, args...) \
+do {if (net_ratelimit()) EFX_LOG(efx, fmt, ##args); } while (0)
+
+/* Kernel headers may redefine inline anyway */
+#ifndef inline
+#define inline inline __attribute__ ((always_inline))
+#endif
+
+/**************************************************************************
+ *
+ * Efx data structures
+ *
+ **************************************************************************/
+
+#define EFX_MAX_CHANNELS 32
+#define EFX_MAX_TX_QUEUES 1
+#define EFX_MAX_RX_QUEUES EFX_MAX_CHANNELS
+
+/**
+ * struct efx_special_buffer - An Efx special buffer
+ * @addr: CPU base address of the buffer
+ * @dma_addr: DMA base address of the buffer
+ * @len: Buffer length, in bytes
+ * @index: Buffer index within controller;s buffer table
+ * @entries: Number of buffer table entries
+ *
+ * Special buffers are used for the event queues and the TX and RX
+ * descriptor queues for each channel.  They are *not* used for the
+ * actual transmit and receive buffers.
+ *
+ * Note that for Falcon, TX and RX descriptor queues live in host memory.
+ * Allocation and freeing procedures must take this into account.
+ */
+struct efx_special_buffer {
+	void *addr;
+	dma_addr_t dma_addr;
+	unsigned int len;
+	int index;
+	int entries;
+};
+
+/**
+ * struct efx_tx_buffer - An Efx TX buffer
+ * @skb: The associated socket buffer.
+ *	Set only on the final fragment of a packet; %NULL for all other
+ *	fragments.  When this fragment completes, then we can free this
+ *	skb.
+ * @dma_addr: DMA address of the fragment.
+ * @len: Length of this fragment.
+ *	This field is zero when the queue slot is empty.
+ * @continuation: True if this fragment is not the end of a packet.
+ * @unmap_single: True if pci_unmap_single should be used.
+ * @unmap_addr: DMA address to unmap
+ * @unmap_len: Length of this fragment to unmap
+ */
+struct efx_tx_buffer {
+	const struct sk_buff *skb;
+	dma_addr_t dma_addr;
+	unsigned short len;
+	unsigned char continuation;
+	unsigned char unmap_single;
+	dma_addr_t unmap_addr;
+	unsigned short unmap_len;
+};
+
+/**
+ * struct efx_tx_queue - An Efx TX queue
+ *
+ * This is a ring buffer of TX fragments.
+ * Since the TX completion path always executes on the same
+ * CPU and the xmit path can operate on different CPUs,
+ * performance is increased by ensuring that the completion
+ * path and the xmit path operate on different cache lines.
+ * This is particularly important if the xmit path is always
+ * executing on one CPU which is different from the completion
+ * path.  There is also a cache line for members which are
+ * read but not written on the fast path.
+ *
+ * @efx: The associated Efx NIC
+ * @queue: DMA queue number
+ * @used: Queue is used by net driver
+ * @channel: The associated channel
+ * @buffer: The software buffer ring
+ * @txd: The hardware descriptor ring
+ * @read_count: Current read pointer.
+ *	This is the number of buffers that have been removed from both rings.
+ * @stopped: Stopped flag.
+ *	Set if this TX queue is currently stopping its port.
+ * @insert_count: Current insert pointer
+ *	This is the number of buffers that have been added to the
+ *	software ring.
+ * @write_count: Current write pointer
+ *	This is the number of buffers that have been added to the
+ *	hardware ring.
+ * @old_read_count: The value of read_count when last checked.
+ *	This is here for performance reasons.  The xmit path will
+ *	only get the up-to-date value of read_count if this
+ *	variable indicates that the queue is full.  This is to
+ *	avoid cache-line ping-pong between the xmit path and the
+ *	completion path.
+ */
+struct efx_tx_queue {
+	/* Members which don't change on the fast path */
+	struct efx_nic *efx ____cacheline_aligned_in_smp;
+	int queue;
+	int used;
+	struct efx_channel *channel;
+	struct efx_nic *nic;
+	struct efx_tx_buffer *buffer;
+	struct efx_special_buffer txd;
+
+	/* Members used mainly on the completion path */
+	unsigned int read_count ____cacheline_aligned_in_smp;
+	int stopped;
+
+	/* Members used only on the xmit path */
+	unsigned int insert_count ____cacheline_aligned_in_smp;
+	unsigned int write_count;
+	unsigned int old_read_count;
+};
+
+/**
+ * struct efx_rx_buffer - An Efx RX data buffer
+ * @dma_addr: DMA base address of the buffer
+ * @skb: The associated socket buffer, if any.
+ *	If both this and page are %NULL, the buffer slot is currently free.
+ * @page: The associated page buffer, if any.
+ *	If both this and skb are %NULL, the buffer slot is currently free.
+ * @data: Pointer to ethernet header
+ * @len: Buffer length, in bytes.
+ * @unmap_addr: DMA address to unmap
+ */
+struct efx_rx_buffer {
+	dma_addr_t dma_addr;
+	struct sk_buff *skb;
+	struct page *page;
+	char *data;
+	unsigned int len;
+	dma_addr_t unmap_addr;
+};
+
+/**
+ * struct efx_rx_queue - An Efx RX queue
+ * @efx: The associated Efx NIC
+ * @queue: DMA queue number
+ * @used: Queue is used by net driver
+ * @channel: The associated channel
+ * @buffer: The software buffer ring
+ * @rxd: The hardware descriptor ring
+ * @added_count: Number of buffers added to the receive queue.
+ * @notified_count: Number of buffers given to NIC (<= @added_count).
+ * @removed_count: Number of buffers removed from the receive queue.
+ * @add_lock: Receive queue descriptor add spin lock.
+ *	This lock must be held in order to add buffers to the RX
+ *	descriptor ring (rxd and buffer) and to update added_count (but
+ *	not removed_count).
+ * @max_fill: RX descriptor maximum fill level (<= ring size)
+ * @fast_fill_trigger: RX descriptor fill level that will trigger a fast fill
+ *	(<= @max_fill)
+ * @fast_fill_limit: The level to which a fast fill will fill
+ *	(@fast_fill_trigger <= @fast_fill_limit <= @max_fill)
+ * @min_fill: RX descriptor minimum non-zero fill level.
+ *	This records the minimum fill level observed when a ring
+ *	refill was triggered.
+ * @min_overfill: RX descriptor minimum overflow fill level.
+ *	This records the minimum fill level at which RX queue
+ *	overflow was observed.  It should never be set.
+ * @alloc_page_count: RX allocation strategy counter.
+ * @alloc_skb_count: RX allocation strategy counter.
+ * @work: Descriptor push work thread
+ * @buf_page: Page for next RX buffer.
+ *	We can use a single page for multiple RX buffers. This tracks
+ *	the remaining space in the allocation.
+ * @buf_dma_addr: Page's DMA address.
+ * @buf_data: Page's host address.
+ */
+struct efx_rx_queue {
+	struct efx_nic *efx;
+	int queue;
+	int used;
+	struct efx_channel *channel;
+	struct efx_rx_buffer *buffer;
+	struct efx_special_buffer rxd;
+
+	int added_count;
+	int notified_count;
+	int removed_count;
+	spinlock_t add_lock;
+	unsigned int max_fill;
+	unsigned int fast_fill_trigger;
+	unsigned int fast_fill_limit;
+	unsigned int min_fill;
+	unsigned int min_overfill;
+	unsigned int alloc_page_count;
+	unsigned int alloc_skb_count;
+	struct delayed_work work;
+	unsigned int slow_fill_count;
+
+	struct page *buf_page;
+	dma_addr_t buf_dma_addr;
+	char *buf_data;
+};
+
+/**
+ * struct efx_buffer - An Efx general-purpose buffer
+ * @addr: host base address of the buffer
+ * @dma_addr: DMA base address of the buffer
+ * @len: Buffer length, in bytes
+ *
+ * Falcon uses these buffers for its interrupt status registers and
+ * MAC stats dumps.
+ */
+struct efx_buffer {
+	void *addr;
+	dma_addr_t dma_addr;
+	unsigned int len;
+};
+
+
+/* Flags for channel->used_flags */
+#define EFX_USED_BY_RX 1
+#define EFX_USED_BY_TX 2
+#define EFX_USED_BY_RX_TX (EFX_USED_BY_RX | EFX_USED_BY_TX)
+
+enum efx_rx_alloc_method {
+	RX_ALLOC_METHOD_AUTO = 0,
+	RX_ALLOC_METHOD_SKB = 1,
+	RX_ALLOC_METHOD_PAGE = 2,
+};
+
+/**
+ * struct efx_channel - An Efx channel
+ *
+ * A channel comprises an event queue, at least one TX queue, at least
+ * one RX queue, and an associated tasklet for processing the event
+ * queue.
+ *
+ * @efx: Associated Efx NIC
+ * @evqnum: Event queue number
+ * @channel: Channel instance number
+ * @used_flags: Channel is used by net driver
+ * @enabled: Channel enabled indicator
+ * @irq: IRQ number (MSI and MSI-X only)
+ * @has_interrupt: Channel has an interrupt
+ * @irq_moderation: IRQ moderation value (in us)
+ * @napi_dev: Net device used with NAPI
+ * @napi_str: NAPI control structure
+ * @reset_work: Scheduled reset work thread
+ * @work_pending: Is work pending via NAPI?
+ * @eventq: Event queue buffer
+ * @eventq_read_ptr: Event queue read pointer
+ * @last_eventq_read_ptr: Last event queue read pointer value.
+ * @eventq_magic: Event queue magic value for driver-generated test events
+ * @lro_mgr: LRO state
+ * @rx_alloc_level: Watermark based heuristic counter for pushing descriptors
+ *	and diagnostic counters
+ * @rx_alloc_push_pages: RX allocation method currently in use for pushing
+ *	descriptors
+ * @rx_alloc_pop_pages: RX allocation method currently in use for popping
+ *	descriptors
+ * @n_rx_tobe_disc: Count of RX_TOBE_DISC errors
+ * @n_rx_ip_frag_err: Count of RX IP fragment errors
+ * @n_rx_ip_hdr_chksum_err: Count of RX IP header checksum errors
+ * @n_rx_tcp_udp_chksum_err: Count of RX TCP and UDP checksum errors
+ * @n_rx_frm_trunc: Count of RX_FRM_TRUNC errors
+ * @n_rx_overlength: Count of RX_OVERLENGTH errors
+ * @n_skbuff_leaks: Count of skbuffs leaked due to RX overrun
+ */
+struct efx_channel {
+	struct efx_nic *efx;
+	int evqnum;
+	int channel;
+	int used_flags;
+	int enabled;
+	int irq;
+	unsigned int has_interrupt;
+	unsigned int irq_moderation;
+	struct net_device *napi_dev;
+	struct napi_struct napi_str;
+	struct work_struct reset_work;
+	int work_pending;
+	struct efx_special_buffer eventq;
+	unsigned int eventq_read_ptr;
+	unsigned int last_eventq_read_ptr;
+	unsigned int eventq_magic;
+
+	struct net_lro_mgr lro_mgr;
+	int rx_alloc_level;
+	int rx_alloc_push_pages;
+	int rx_alloc_pop_pages;
+
+	unsigned n_rx_tobe_disc;
+	unsigned n_rx_ip_frag_err;
+	unsigned n_rx_ip_hdr_chksum_err;
+	unsigned n_rx_tcp_udp_chksum_err;
+	unsigned n_rx_frm_trunc;
+	unsigned n_rx_overlength;
+	unsigned n_skbuff_leaks;
+
+	/* Used to pipeline received packets in order to optimise memory
+	 * access with prefetches.
+	 */
+	struct efx_rx_buffer *rx_pkt;
+	int rx_pkt_csummed;
+
+};
+
+/**
+ * struct efx_blinker - S/W LED blinking context
+ * @led_num: LED ID (board-specific meaning)
+ * @state: Current state - on or off
+ * @resubmit: Timer resubmission flag
+ * @timer: Control timer for blinking
+ */
+struct efx_blinker {
+	int led_num;
+	int state;
+	int resubmit;
+	struct timer_list timer;
+};
+
+
+/**
+ * struct efx_board - board information
+ * @type: Board model type
+ * @major: Major rev. ('A', 'B' ...)
+ * @minor: Minor rev. (0, 1, ...)
+ * @init: Initialisation function
+ * @init_leds: Sets up board LEDs
+ * @set_fault_led: Turns the fault LED on or off
+ * @blink: Starts/stops blinking
+ * @blinker: used to blink LEDs in software
+ */
+struct efx_board {
+	int type;
+	int major;
+	int minor;
+	int (*init) (struct efx_nic *nic);
+	/* As the LEDs are typically attached to the PHY, LEDs
+	 * have a separate init callback that happens later than
+	 * board init. */
+	int (*init_leds)(struct efx_nic *efx);
+	void (*set_fault_led) (struct efx_nic *efx, int state);
+	void (*blink) (struct efx_nic *efx, int start);
+	struct efx_blinker blinker;
+};
+
+enum efx_int_mode {
+	/* Be careful if altering to correct macro below */
+	EFX_INT_MODE_MSIX = 0,
+	EFX_INT_MODE_MSI = 1,
+	EFX_INT_MODE_LEGACY = 2,
+	EFX_INT_MODE_MAX	/* Insert any new items before this */
+};
+#define EFX_INT_MODE_USE_MSI(x) (((x)->interrupt_mode) <= EFX_INT_MODE_MSI)
+
+enum phy_type {
+	PHY_TYPE_NONE = 0,
+	PHY_TYPE_CX4_RTMR = 1,
+	PHY_TYPE_1G_ALASKA = 2,
+	PHY_TYPE_10XPRESS = 3,
+	PHY_TYPE_XFP = 4,
+	PHY_TYPE_PM8358 = 6,
+	PHY_TYPE_MAX	/* Insert any new items before this */
+};
+
+#define PHY_ADDR_INVALID 0xff
+
+enum nic_state {
+	STATE_INIT = 0,
+	STATE_RUNNING = 1,
+	STATE_FINI = 2,
+	STATE_RESETTING = 3, /* rtnl_lock always held */
+	STATE_DISABLED = 4,
+	STATE_MAX,
+};
+
+/*
+ * Alignment of page-allocated RX buffers
+ *
+ * Controls the number of bytes inserted at the start of an RX buffer.
+ * This is the equivalent of NET_IP_ALIGN [which controls the alignment
+ * of the skb->head for hardware DMA].
+ */
+#ifdef __ia64__
+#define EFX_PAGE_IP_ALIGN 2
+#else
+#define EFX_PAGE_IP_ALIGN 0
+#endif
+
+/*
+ * Alignment of the skb->head which wraps a page-allocated RX buffer
+ *
+ * The skb allocated to wrap an rx_buffer can have this alignment. Since
+ * the data is memcpy'd from the rx_buf, it does not need to be equal to
+ * EFX_PAGE_IP_ALIGN.
+ */
+#define EFX_PAGE_SKB_ALIGN 2
+
+/* Forward declaration */
+struct efx_nic;
+
+/* Pseudo bit-mask flow control field */
+enum efx_fc_type {
+	EFX_FC_RX = 1,
+	EFX_FC_TX = 2,
+	EFX_FC_AUTO = 4,
+};
+
+/**
+ * struct efx_phy_operations - Efx PHY operations table
+ * @init: Initialise PHY
+ * @fini: Shut down PHY
+ * @reconfigure: Reconfigure PHY (e.g. for new link parameters)
+ * @clear_interrupt: Clear down interrupt
+ * @blink: Blink LEDs
+ * @check_hw: Check hardware
+ * @reset_xaui: Reset XAUI side of PHY for (software sequenced reset)
+ * @mmds: MMD presence mask
+ */
+struct efx_phy_operations {
+	int (*init) (struct efx_nic *efx);
+	void (*fini) (struct efx_nic *efx);
+	void (*reconfigure) (struct efx_nic *efx);
+	void (*clear_interrupt) (struct efx_nic *efx);
+	int (*check_hw) (struct efx_nic *efx);
+	void (*reset_xaui) (struct efx_nic *efx);
+	int mmds;
+};
+
+/*
+ * Efx extended statistics
+ *
+ * Not all statistics are provided by all supported MACs.  The purpose
+ * is this structure is to contain the raw statistics provided by each
+ * MAC.
+ */
+struct efx_mac_stats {
+	u64 tx_bytes;
+	u64 tx_good_bytes;
+	u64 tx_bad_bytes;
+	unsigned long tx_packets;
+	unsigned long tx_bad;
+	unsigned long tx_pause;
+	unsigned long tx_control;
+	unsigned long tx_unicast;
+	unsigned long tx_multicast;
+	unsigned long tx_broadcast;
+	unsigned long tx_lt64;
+	unsigned long tx_64;
+	unsigned long tx_65_to_127;
+	unsigned long tx_128_to_255;
+	unsigned long tx_256_to_511;
+	unsigned long tx_512_to_1023;
+	unsigned long tx_1024_to_15xx;
+	unsigned long tx_15xx_to_jumbo;
+	unsigned long tx_gtjumbo;
+	unsigned long tx_collision;
+	unsigned long tx_single_collision;
+	unsigned long tx_multiple_collision;
+	unsigned long tx_excessive_collision;
+	unsigned long tx_deferred;
+	unsigned long tx_late_collision;
+	unsigned long tx_excessive_deferred;
+	unsigned long tx_non_tcpudp;
+	unsigned long tx_mac_src_error;
+	unsigned long tx_ip_src_error;
+	u64 rx_bytes;
+	u64 rx_good_bytes;
+	u64 rx_bad_bytes;
+	unsigned long rx_packets;
+	unsigned long rx_good;
+	unsigned long rx_bad;
+	unsigned long rx_pause;
+	unsigned long rx_control;
+	unsigned long rx_unicast;
+	unsigned long rx_multicast;
+	unsigned long rx_broadcast;
+	unsigned long rx_lt64;
+	unsigned long rx_64;
+	unsigned long rx_65_to_127;
+	unsigned long rx_128_to_255;
+	unsigned long rx_256_to_511;
+	unsigned long rx_512_to_1023;
+	unsigned long rx_1024_to_15xx;
+	unsigned long rx_15xx_to_jumbo;
+	unsigned long rx_gtjumbo;
+	unsigned long rx_bad_lt64;
+	unsigned long rx_bad_64_to_15xx;
+	unsigned long rx_bad_15xx_to_jumbo;
+	unsigned long rx_bad_gtjumbo;
+	unsigned long rx_overflow;
+	unsigned long rx_missed;
+	unsigned long rx_false_carrier;
+	unsigned long rx_symbol_error;
+	unsigned long rx_align_error;
+	unsigned long rx_length_error;
+	unsigned long rx_internal_error;
+	unsigned long rx_good_lt64;
+};
+
+/* Number of bits used in a multicast filter hash address */
+#define EFX_MCAST_HASH_BITS 8
+
+/* Number of (single-bit) entries in a multicast filter hash */
+#define EFX_MCAST_HASH_ENTRIES (1 << EFX_MCAST_HASH_BITS)
+
+/* An Efx multicast filter hash */
+union efx_multicast_hash {
+	u8 byte[EFX_MCAST_HASH_ENTRIES / 8];
+	efx_oword_t oword[EFX_MCAST_HASH_ENTRIES / sizeof(efx_oword_t) / 8];
+};
+
+/**
+ * struct efx_nic - an Efx NIC
+ * @name: Device name (net device name or bus id before net device registered)
+ * @pci_dev: The PCI device
+ * @type: Controller type attributes
+ * @legacy_irq: IRQ number
+ * @workqueue: Workqueue for resets, port reconfigures and the HW monitor
+ * @reset_work: Scheduled reset workitem
+ * @monitor_work: Hardware monitor workitem
+ * @membase_phys: Memory BAR value as physical address
+ * @membase: Memory BAR value
+ * @biu_lock: BIU (bus interface unit) lock
+ * @interrupt_mode: Interrupt mode
+ * @i2c: I2C interface
+ * @board_info: Board-level information
+ * @state: Device state flag. Serialised by the rtnl_lock.
+ * @reset_pending: Pending reset method (normally RESET_TYPE_NONE)
+ * @tx_queue: TX DMA queues
+ * @rx_queue: RX DMA queues
+ * @channel: Channels
+ * @rss_queues: Number of RSS queues
+ * @rx_buffer_len: RX buffer length
+ * @rx_buffer_order: Order (log2) of number of pages for each RX buffer
+ * @irq_status: Interrupt status buffer
+ * @last_irq_cpu: Last CPU to handle interrupt.
+ *	This register is written with the SMP processor ID whenever an
+ *	interrupt is handled.  It is used by falcon_test_interrupt()
+ *	to verify that an interrupt has occurred.
+ * @n_rx_nodesc_drop_cnt: RX no descriptor drop count
+ * @nic_data: Hardware dependant state
+ * @mac_lock: MAC access lock. Protects @port_enabled, efx_monitor() and
+ *	efx_reconfigure_port()
+ * @port_enabled: Port enabled indicator.
+ *	Serialises efx_stop_all(), efx_start_all() and efx_monitor() and
+ *	efx_reconfigure_work with kernel interfaces. Safe to read under any
+ *	one of the rtnl_lock, mac_lock, or netif_tx_lock, but all three must
+ *	be held to modify it.
+ * @port_initialized: Port initialized?
+ * @net_dev: Operating system network device. Consider holding the rtnl lock
+ * @rx_checksum_enabled: RX checksumming enabled
+ * @netif_stop_count: Port stop count
+ * @netif_stop_lock: Port stop lock
+ * @mac_stats: MAC statistics. These include all statistics the MACs
+ *	can provide.  Generic code converts these into a standard
+ *	&struct net_device_stats.
+ * @stats_buffer: DMA buffer for statistics
+ * @stats_lock: Statistics update lock
+ * @mac_address: Permanent MAC address
+ * @phy_type: PHY type
+ * @phy_lock: PHY access lock
+ * @phy_op: PHY interface
+ * @phy_data: PHY private data (including PHY-specific stats)
+ * @mii: PHY interface
+ * @phy_powered: PHY power state
+ * @tx_disabled: PHY transmitter turned off
+ * @link_up: Link status
+ * @link_options: Link options (MII/GMII format)
+ * @n_link_state_changes: Number of times the link has changed state
+ * @promiscuous: Promiscuous flag. Protected by netif_tx_lock.
+ * @multicast_hash: Multicast hash table
+ * @flow_control: Flow control flags - separate RX/TX so can't use link_options
+ * @reconfigure_work: work item for dealing with PHY events
+ *
+ * The @priv field of the corresponding &struct net_device points to
+ * this.
+ */
+struct efx_nic {
+	char name[IFNAMSIZ];
+	struct pci_dev *pci_dev;
+	const struct efx_nic_type *type;
+	int legacy_irq;
+	struct workqueue_struct *workqueue;
+	struct work_struct reset_work;
+	struct delayed_work monitor_work;
+	unsigned long membase_phys;
+	void __iomem *membase;
+	spinlock_t biu_lock;
+	enum efx_int_mode interrupt_mode;
+
+	struct efx_i2c_interface i2c;
+	struct efx_board board_info;
+
+	enum nic_state state;
+	enum reset_type reset_pending;
+
+	struct efx_tx_queue tx_queue[EFX_MAX_TX_QUEUES];
+	struct efx_rx_queue rx_queue[EFX_MAX_RX_QUEUES];
+	struct efx_channel channel[EFX_MAX_CHANNELS];
+
+	int rss_queues;
+	unsigned int rx_buffer_len;
+	unsigned int rx_buffer_order;
+
+	struct efx_buffer irq_status;
+	volatile signed int last_irq_cpu;
+
+	unsigned n_rx_nodesc_drop_cnt;
+
+	void *nic_data;
+
+	struct mutex mac_lock;
+	int port_enabled;
+
+	int port_initialized;
+	struct net_device *net_dev;
+	int rx_checksum_enabled;
+
+	atomic_t netif_stop_count;
+	spinlock_t netif_stop_lock;
+
+	struct efx_mac_stats mac_stats;
+	struct efx_buffer stats_buffer;
+	spinlock_t stats_lock;
+
+	unsigned char mac_address[ETH_ALEN];
+
+	enum phy_type phy_type;
+	spinlock_t phy_lock;
+	struct efx_phy_operations *phy_op;
+	void *phy_data;
+	struct mii_if_info mii;
+
+	int link_up;
+	unsigned int link_options;
+	unsigned int n_link_state_changes;
+
+	int promiscuous;
+	union efx_multicast_hash multicast_hash;
+	enum efx_fc_type flow_control;
+	struct work_struct reconfigure_work;
+
+	atomic_t rx_reset;
+};
+
+/**
+ * struct efx_nic_type - Efx device type definition
+ * @mem_bar: Memory BAR number
+ * @mem_map_size: Memory BAR mapped size
+ * @txd_ptr_tbl_base: TX descriptor ring base address
+ * @rxd_ptr_tbl_base: RX descriptor ring base address
+ * @buf_tbl_base: Buffer table base address
+ * @evq_ptr_tbl_base: Event queue pointer table base address
+ * @evq_rptr_tbl_base: Event queue read-pointer table base address
+ * @txd_ring_mask: TX descriptor ring size - 1 (must be a power of two - 1)
+ * @rxd_ring_mask: RX descriptor ring size - 1 (must be a power of two - 1)
+ * @evq_size: Event queue size (must be a power of two)
+ * @max_dma_mask: Maximum possible DMA mask
+ * @tx_dma_mask: TX DMA mask
+ * @bug5391_mask: Address mask for bug 5391 workaround
+ * @rx_xoff_thresh: RX FIFO XOFF watermark (bytes)
+ * @rx_xon_thresh: RX FIFO XON watermark (bytes)
+ * @rx_buffer_padding: Padding added to each RX buffer
+ * @max_interrupt_mode: Highest capability interrupt mode supported
+ *	from &enum efx_init_mode.
+ * @phys_addr_channels: Number of channels with physically addressed
+ *	descriptors
+ */
+struct efx_nic_type {
+	unsigned int mem_bar;
+	unsigned int mem_map_size;
+	unsigned int txd_ptr_tbl_base;
+	unsigned int rxd_ptr_tbl_base;
+	unsigned int buf_tbl_base;
+	unsigned int evq_ptr_tbl_base;
+	unsigned int evq_rptr_tbl_base;
+
+	unsigned int txd_ring_mask;
+	unsigned int rxd_ring_mask;
+	unsigned int evq_size;
+	dma_addr_t max_dma_mask;
+	unsigned int tx_dma_mask;
+	unsigned bug5391_mask;
+
+	int rx_xoff_thresh;
+	int rx_xon_thresh;
+	unsigned int rx_buffer_padding;
+	unsigned int max_interrupt_mode;
+	unsigned int phys_addr_channels;
+};
+
+/**************************************************************************
+ *
+ * Prototypes and inline functions
+ *
+ *************************************************************************/
+
+/* Iterate over all used channels */
+#define efx_for_each_channel(_channel, _efx)				\
+	for (_channel = &_efx->channel[0];				\
+	     _channel < &_efx->channel[EFX_MAX_CHANNELS];		\
+	     _channel++)						\
+		if (!_channel->used_flags)				\
+			continue;					\
+		else
+
+/* Iterate over all used channels with interrupts */
+#define efx_for_each_channel_with_interrupt(_channel, _efx)		\
+	for (_channel = &_efx->channel[0];				\
+	     _channel < &_efx->channel[EFX_MAX_CHANNELS];		\
+	     _channel++)						\
+		if (!(_channel->used_flags && _channel->has_interrupt))	\
+			continue;					\
+		else
+
+/* Iterate over all used TX queues */
+#define efx_for_each_tx_queue(_tx_queue, _efx)				\
+	for (_tx_queue = &_efx->tx_queue[0];				\
+	     _tx_queue < &_efx->tx_queue[EFX_MAX_TX_QUEUES];		\
+	     _tx_queue++)						\
+		if (!_tx_queue->used)					\
+			continue;					\
+		else
+
+/* Iterate over all TX queues belonging to a channel */
+#define efx_for_each_channel_tx_queue(_tx_queue, _channel)		\
+	for (_tx_queue = &_channel->efx->tx_queue[0];			\
+	     _tx_queue < &_channel->efx->tx_queue[EFX_MAX_TX_QUEUES];	\
+	     _tx_queue++)						\
+		if ((!_tx_queue->used) ||				\
+		    (_tx_queue->channel != _channel))			\
+			continue;					\
+		else
+
+/* Iterate over all used RX queues */
+#define efx_for_each_rx_queue(_rx_queue, _efx)				\
+	for (_rx_queue = &_efx->rx_queue[0];				\
+	     _rx_queue < &_efx->rx_queue[EFX_MAX_RX_QUEUES];		\
+	     _rx_queue++)						\
+		if (!_rx_queue->used)					\
+			continue;					\
+		else
+
+/* Iterate over all RX queues belonging to a channel */
+#define efx_for_each_channel_rx_queue(_rx_queue, _channel)		\
+	for (_rx_queue = &_channel->efx->rx_queue[0];			\
+	     _rx_queue < &_channel->efx->rx_queue[EFX_MAX_RX_QUEUES];	\
+	     _rx_queue++)						\
+		if ((!_rx_queue->used) ||				\
+		    (_rx_queue->channel != _channel))			\
+			continue;					\
+		else
+
+/* Returns a pointer to the specified receive buffer in the RX
+ * descriptor queue.
+ */
+static inline struct efx_rx_buffer *efx_rx_buffer(struct efx_rx_queue *rx_queue,
+						  unsigned int index)
+{
+	return (&rx_queue->buffer[index]);
+}
+
+/* Set bit in a little-endian bitfield */
+static inline void set_bit_le(int nr, unsigned char *addr)
+{
+	addr[nr / 8] |= (1 << (nr % 8));
+}
+
+/* Clear bit in a little-endian bitfield */
+static inline void clear_bit_le(int nr, unsigned char *addr)
+{
+	addr[nr / 8] &= ~(1 << (nr % 8));
+}
+
+
+/**
+ * EFX_MAX_FRAME_LEN - calculate maximum frame length
+ *
+ * This calculates the maximum frame length that will be used for a
+ * given MTU.  The frame length will be equal to the MTU plus a
+ * constant amount of header space and padding.  This is the quantity
+ * that the net driver will program into the MAC as the maximum frame
+ * length.
+ *
+ * The 10G MAC used in Falcon requires 8-byte alignment on the frame
+ * length, so we round up to the nearest 8.
+ */
+#define EFX_MAX_FRAME_LEN(mtu) \
+	((((mtu) + ETH_HLEN + VLAN_HLEN + 4/* FCS */) + 7) & ~7)
+
+
+#endif /* EFX_NET_DRIVER_H */
diff --git a/drivers/net/sfc/bitfield.h b/drivers/net/sfc/bitfield.h
new file mode 100644
index 0000000..2806201
--- /dev/null
+++ b/drivers/net/sfc/bitfield.h
@@ -0,0 +1,508 @@
+/****************************************************************************
+ * Driver for Solarflare Solarstorm network controllers and boards
+ * Copyright 2005-2006 Fen Systems Ltd.
+ * Copyright 2006-2008 Solarflare Communications Inc.
+ *
+ * This program is free software; you can redistribute it and/or modify it
+ * under the terms of the GNU General Public License version 2 as published
+ * by the Free Software Foundation, incorporated herein by reference.
+ */
+
+#ifndef EFX_BITFIELD_H
+#define EFX_BITFIELD_H
+
+/*
+ * Efx bitfield access
+ *
+ * Efx NICs make extensive use of bitfields up to 128 bits
+ * wide.  Since there is no native 128-bit datatype on most systems,
+ * and since 64-bit datatypes are inefficient on 32-bit systems and
+ * vice versa, we wrap accesses in a way that uses the most efficient
+ * datatype.
+ *
+ * The NICs are PCI devices and therefore little-endian.  Since most
+ * of the quantities that we deal with are DMAed to/from host memory,
+ * we define our datatypes (efx_oword_t, efx_qword_t and
+ * efx_dword_t) to be little-endian.
+ */
+
+/* Lowest bit numbers and widths */
+#define EFX_DUMMY_FIELD_LBN 0
+#define EFX_DUMMY_FIELD_WIDTH 0
+#define EFX_DWORD_0_LBN 0
+#define EFX_DWORD_0_WIDTH 32
+#define EFX_DWORD_1_LBN 32
+#define EFX_DWORD_1_WIDTH 32
+#define EFX_DWORD_2_LBN 64
+#define EFX_DWORD_2_WIDTH 32
+#define EFX_DWORD_3_LBN 96
+#define EFX_DWORD_3_WIDTH 32
+
+/* Specified attribute (e.g. LBN) of the specified field */
+#define EFX_VAL(field, attribute) field ## _ ## attribute
+/* Low bit number of the specified field */
+#define EFX_LOW_BIT(field) EFX_VAL(field, LBN)
+/* Bit width of the specified field */
+#define EFX_WIDTH(field) EFX_VAL(field, WIDTH)
+/* High bit number of the specified field */
+#define EFX_HIGH_BIT(field) (EFX_LOW_BIT(field) + EFX_WIDTH(field) - 1)
+/* Mask equal in width to the specified field.
+ *
+ * For example, a field with width 5 would have a mask of 0x1f.
+ *
+ * The maximum width mask that can be generated is 64 bits.
+ */
+#define EFX_MASK64(field)					\
+	(EFX_WIDTH(field) == 64 ? ~((u64) 0) :		\
+	 (((((u64) 1) << EFX_WIDTH(field))) - 1))
+
+/* Mask equal in width to the specified field.
+ *
+ * For example, a field with width 5 would have a mask of 0x1f.
+ *
+ * The maximum width mask that can be generated is 32 bits.  Use
+ * EFX_MASK64 for higher width fields.
+ */
+#define EFX_MASK32(field)					\
+	(EFX_WIDTH(field) == 32 ? ~((u32) 0) :		\
+	 (((((u32) 1) << EFX_WIDTH(field))) - 1))
+
+/* A doubleword (i.e. 4 byte) datatype - little-endian in HW */
+typedef union efx_dword {
+	__le32 u32[1];
+} efx_dword_t;
+
+/* A quadword (i.e. 8 byte) datatype - little-endian in HW */
+typedef union efx_qword {
+	__le64 u64[1];
+	__le32 u32[2];
+	efx_dword_t dword[2];
+} efx_qword_t;
+
+/* An octword (eight-word, i.e. 16 byte) datatype - little-endian in HW */
+typedef union efx_oword {
+	__le64 u64[2];
+	efx_qword_t qword[2];
+	__le32 u32[4];
+	efx_dword_t dword[4];
+} efx_oword_t;
+
+/* Format string and value expanders for printk */
+#define EFX_DWORD_FMT "%08x"
+#define EFX_QWORD_FMT "%08x:%08x"
+#define EFX_OWORD_FMT "%08x:%08x:%08x:%08x"
+#define EFX_DWORD_VAL(dword)				\
+	((unsigned int) le32_to_cpu((dword).u32[0]))
+#define EFX_QWORD_VAL(qword)				\
+	((unsigned int) le32_to_cpu((qword).u32[1])),	\
+	((unsigned int) le32_to_cpu((qword).u32[0]))
+#define EFX_OWORD_VAL(oword)				\
+	((unsigned int) le32_to_cpu((oword).u32[3])),	\
+	((unsigned int) le32_to_cpu((oword).u32[2])),	\
+	((unsigned int) le32_to_cpu((oword).u32[1])),	\
+	((unsigned int) le32_to_cpu((oword).u32[0]))
+
+/*
+ * Extract bit field portion [low,high) from the native-endian element
+ * which contains bits [min,max).
+ *
+ * For example, suppose "element" represents the high 32 bits of a
+ * 64-bit value, and we wish to extract the bits belonging to the bit
+ * field occupying bits 28-45 of this 64-bit value.
+ *
+ * Then EFX_EXTRACT ( element, 32, 63, 28, 45 ) would give
+ *
+ *   ( element ) << 4
+ *
+ * The result will contain the relevant bits filled in in the range
+ * [0,high-low), with garbage in bits [high-low+1,...).
+ */
+#define EFX_EXTRACT_NATIVE(native_element, min, max, low, high)		\
+	(((low > max) || (high < min)) ? 0 :				\
+	 ((low > min) ?							\
+	  ((native_element) >> (low - min)) :				\
+	  ((native_element) << (min - low))))
+
+/*
+ * Extract bit field portion [low,high) from the 64-bit little-endian
+ * element which contains bits [min,max)
+ */
+#define EFX_EXTRACT64(element, min, max, low, high)			\
+	EFX_EXTRACT_NATIVE(le64_to_cpu(element), min, max, low, high)
+
+/*
+ * Extract bit field portion [low,high) from the 32-bit little-endian
+ * element which contains bits [min,max)
+ */
+#define EFX_EXTRACT32(element, min, max, low, high)			\
+	EFX_EXTRACT_NATIVE(le32_to_cpu(element), min, max, low, high)
+
+#define EFX_EXTRACT_OWORD64(oword, low, high)				\
+	(EFX_EXTRACT64((oword).u64[0], 0, 63, low, high) |		\
+	 EFX_EXTRACT64((oword).u64[1], 64, 127, low, high))
+
+#define EFX_EXTRACT_QWORD64(qword, low, high)				\
+	EFX_EXTRACT64((qword).u64[0], 0, 63, low, high)
+
+#define EFX_EXTRACT_OWORD32(oword, low, high)				\
+	(EFX_EXTRACT32((oword).u32[0], 0, 31, low, high) |		\
+	 EFX_EXTRACT32((oword).u32[1], 32, 63, low, high) |		\
+	 EFX_EXTRACT32((oword).u32[2], 64, 95, low, high) |		\
+	 EFX_EXTRACT32((oword).u32[3], 96, 127, low, high))
+
+#define EFX_EXTRACT_QWORD32(qword, low, high)				\
+	(EFX_EXTRACT32((qword).u32[0], 0, 31, low, high) |		\
+	 EFX_EXTRACT32((qword).u32[1], 32, 63, low, high))
+
+#define EFX_EXTRACT_DWORD(dword, low, high)				\
+	EFX_EXTRACT32((dword).u32[0], 0, 31, low, high)
+
+#define EFX_OWORD_FIELD64(oword, field)					\
+	(EFX_EXTRACT_OWORD64(oword, EFX_LOW_BIT(field), EFX_HIGH_BIT(field)) \
+	 & EFX_MASK64(field))
+
+#define EFX_QWORD_FIELD64(qword, field)					\
+	(EFX_EXTRACT_QWORD64(qword, EFX_LOW_BIT(field), EFX_HIGH_BIT(field)) \
+	 & EFX_MASK64(field))
+
+#define EFX_OWORD_FIELD32(oword, field)					\
+	(EFX_EXTRACT_OWORD32(oword, EFX_LOW_BIT(field), EFX_HIGH_BIT(field)) \
+	 & EFX_MASK32(field))
+
+#define EFX_QWORD_FIELD32(qword, field)					\
+	(EFX_EXTRACT_QWORD32(qword, EFX_LOW_BIT(field), EFX_HIGH_BIT(field)) \
+	 & EFX_MASK32(field))
+
+#define EFX_DWORD_FIELD(dword, field)					   \
+	(EFX_EXTRACT_DWORD(dword, EFX_LOW_BIT(field), EFX_HIGH_BIT(field)) \
+	 & EFX_MASK32(field))
+
+#define EFX_OWORD_IS_ZERO64(oword)					\
+	(((oword).u64[0] | (oword).u64[1]) == (__force __le64) 0)
+
+#define EFX_QWORD_IS_ZERO64(qword)					\
+	(((qword).u64[0]) == (__force __le64) 0)
+
+#define EFX_OWORD_IS_ZERO32(oword)					     \
+	(((oword).u32[0] | (oword).u32[1] | (oword).u32[2] | (oword).u32[3]) \
+	 == (__force __le32) 0)
+
+#define EFX_QWORD_IS_ZERO32(qword)					\
+	(((qword).u32[0] | (qword).u32[1]) == (__force __le32) 0)
+
+#define EFX_DWORD_IS_ZERO(dword)					\
+	(((dword).u32[0]) == (__force __le32) 0)
+
+#define EFX_OWORD_IS_ALL_ONES64(oword)					\
+	(((oword).u64[0] & (oword).u64[1]) == ~((__force __le64) 0))
+
+#define EFX_QWORD_IS_ALL_ONES64(qword)					\
+	((qword).u64[0] == ~((__force __le64) 0))
+
+#define EFX_OWORD_IS_ALL_ONES32(oword)					\
+	(((oword).u32[0] & (oword).u32[1] & (oword).u32[2] & (oword).u32[3]) \
+	 == ~((__force __le32) 0))
+
+#define EFX_QWORD_IS_ALL_ONES32(qword)					\
+	(((qword).u32[0] & (qword).u32[1]) == ~((__force __le32) 0))
+
+#define EFX_DWORD_IS_ALL_ONES(dword)					\
+	((dword).u32[0] == ~((__force __le32) 0))
+
+#if BITS_PER_LONG == 64
+#define EFX_OWORD_FIELD		EFX_OWORD_FIELD64
+#define EFX_QWORD_FIELD		EFX_QWORD_FIELD64
+#define EFX_OWORD_IS_ZERO	EFX_OWORD_IS_ZERO64
+#define EFX_QWORD_IS_ZERO	EFX_QWORD_IS_ZERO64
+#define EFX_OWORD_IS_ALL_ONES	EFX_OWORD_IS_ALL_ONES64
+#define EFX_QWORD_IS_ALL_ONES	EFX_QWORD_IS_ALL_ONES64
+#else
+#define EFX_OWORD_FIELD		EFX_OWORD_FIELD32
+#define EFX_QWORD_FIELD		EFX_QWORD_FIELD32
+#define EFX_OWORD_IS_ZERO	EFX_OWORD_IS_ZERO32
+#define EFX_QWORD_IS_ZERO	EFX_QWORD_IS_ZERO32
+#define EFX_OWORD_IS_ALL_ONES	EFX_OWORD_IS_ALL_ONES32
+#define EFX_QWORD_IS_ALL_ONES	EFX_QWORD_IS_ALL_ONES32
+#endif
+
+/*
+ * Construct bit field portion
+ *
+ * Creates the portion of the bit field [low,high) that lies within
+ * the range [min,max).
+ */
+#define EFX_INSERT_NATIVE64(min, max, low, high, value)		\
+	(((low > max) || (high < min)) ? 0 :			\
+	 ((low > min) ?						\
+	  (((u64) (value)) << (low - min)) :		\
+	  (((u64) (value)) >> (min - low))))
+
+#define EFX_INSERT_NATIVE32(min, max, low, high, value)		\
+	(((low > max) || (high < min)) ? 0 :			\
+	 ((low > min) ?						\
+	  (((u32) (value)) << (low - min)) :		\
+	  (((u32) (value)) >> (min - low))))
+
+#define EFX_INSERT_NATIVE(min, max, low, high, value)		\
+	((((max - min) >= 32) || ((high - low) >= 32)) ?	\
+	 EFX_INSERT_NATIVE64(min, max, low, high, value) :	\
+	 EFX_INSERT_NATIVE32(min, max, low, high, value))
+
+/*
+ * Construct bit field portion
+ *
+ * Creates the portion of the named bit field that lies within the
+ * range [min,max).
+ */
+#define EFX_INSERT_FIELD_NATIVE(min, max, field, value)		\
+	EFX_INSERT_NATIVE(min, max, EFX_LOW_BIT(field),		\
+			  EFX_HIGH_BIT(field), value)
+
+/*
+ * Construct bit field
+ *
+ * Creates the portion of the named bit fields that lie within the
+ * range [min,max).
+ */
+#define EFX_INSERT_FIELDS_NATIVE(min, max,				\
+				 field1, value1,			\
+				 field2, value2,			\
+				 field3, value3,			\
+				 field4, value4,			\
+				 field5, value5,			\
+				 field6, value6,			\
+				 field7, value7,			\
+				 field8, value8,			\
+				 field9, value9,			\
+				 field10, value10)			\
+	(EFX_INSERT_FIELD_NATIVE((min), (max), field1, (value1)) |	\
+	 EFX_INSERT_FIELD_NATIVE((min), (max), field2, (value2)) |	\
+	 EFX_INSERT_FIELD_NATIVE((min), (max), field3, (value3)) |	\
+	 EFX_INSERT_FIELD_NATIVE((min), (max), field4, (value4)) |	\
+	 EFX_INSERT_FIELD_NATIVE((min), (max), field5, (value5)) |	\
+	 EFX_INSERT_FIELD_NATIVE((min), (max), field6, (value6)) |	\
+	 EFX_INSERT_FIELD_NATIVE((min), (max), field7, (value7)) |	\
+	 EFX_INSERT_FIELD_NATIVE((min), (max), field8, (value8)) |	\
+	 EFX_INSERT_FIELD_NATIVE((min), (max), field9, (value9)) |	\
+	 EFX_INSERT_FIELD_NATIVE((min), (max), field10, (value10)))
+
+#define EFX_INSERT_FIELDS64(...)				\
+	cpu_to_le64(EFX_INSERT_FIELDS_NATIVE(__VA_ARGS__))
+
+#define EFX_INSERT_FIELDS32(...)				\
+	cpu_to_le32(EFX_INSERT_FIELDS_NATIVE(__VA_ARGS__))
+
+#define EFX_POPULATE_OWORD64(oword, ...) do {				\
+	(oword).u64[0] = EFX_INSERT_FIELDS64(0, 63, __VA_ARGS__);	\
+	(oword).u64[1] = EFX_INSERT_FIELDS64(64, 127, __VA_ARGS__);	\
+	} while (0)
+
+#define EFX_POPULATE_QWORD64(qword, ...) do {				\
+	(qword).u64[0] = EFX_INSERT_FIELDS64(0, 63, __VA_ARGS__);	\
+	} while (0)
+
+#define EFX_POPULATE_OWORD32(oword, ...) do {				\
+	(oword).u32[0] = EFX_INSERT_FIELDS32(0, 31, __VA_ARGS__);	\
+	(oword).u32[1] = EFX_INSERT_FIELDS32(32, 63, __VA_ARGS__);	\
+	(oword).u32[2] = EFX_INSERT_FIELDS32(64, 95, __VA_ARGS__);	\
+	(oword).u32[3] = EFX_INSERT_FIELDS32(96, 127, __VA_ARGS__);	\
+	} while (0)
+
+#define EFX_POPULATE_QWORD32(qword, ...) do {				\
+	(qword).u32[0] = EFX_INSERT_FIELDS32(0, 31, __VA_ARGS__);	\
+	(qword).u32[1] = EFX_INSERT_FIELDS32(32, 63, __VA_ARGS__);	\
+	} while (0)
+
+#define EFX_POPULATE_DWORD(dword, ...) do {				\
+	(dword).u32[0] = EFX_INSERT_FIELDS32(0, 31, __VA_ARGS__);	\
+	} while (0)
+
+#if BITS_PER_LONG == 64
+#define EFX_POPULATE_OWORD EFX_POPULATE_OWORD64
+#define EFX_POPULATE_QWORD EFX_POPULATE_QWORD64
+#else
+#define EFX_POPULATE_OWORD EFX_POPULATE_OWORD32
+#define EFX_POPULATE_QWORD EFX_POPULATE_QWORD32
+#endif
+
+/* Populate an octword field with various numbers of arguments */
+#define EFX_POPULATE_OWORD_10 EFX_POPULATE_OWORD
+#define EFX_POPULATE_OWORD_9(oword, ...) \
+	EFX_POPULATE_OWORD_10(oword, EFX_DUMMY_FIELD, 0, __VA_ARGS__)
+#define EFX_POPULATE_OWORD_8(oword, ...) \
+	EFX_POPULATE_OWORD_9(oword, EFX_DUMMY_FIELD, 0, __VA_ARGS__)
+#define EFX_POPULATE_OWORD_7(oword, ...) \
+	EFX_POPULATE_OWORD_8(oword, EFX_DUMMY_FIELD, 0, __VA_ARGS__)
+#define EFX_POPULATE_OWORD_6(oword, ...) \
+	EFX_POPULATE_OWORD_7(oword, EFX_DUMMY_FIELD, 0, __VA_ARGS__)
+#define EFX_POPULATE_OWORD_5(oword, ...) \
+	EFX_POPULATE_OWORD_6(oword, EFX_DUMMY_FIELD, 0, __VA_ARGS__)
+#define EFX_POPULATE_OWORD_4(oword, ...) \
+	EFX_POPULATE_OWORD_5(oword, EFX_DUMMY_FIELD, 0, __VA_ARGS__)
+#define EFX_POPULATE_OWORD_3(oword, ...) \
+	EFX_POPULATE_OWORD_4(oword, EFX_DUMMY_FIELD, 0, __VA_ARGS__)
+#define EFX_POPULATE_OWORD_2(oword, ...) \
+	EFX_POPULATE_OWORD_3(oword, EFX_DUMMY_FIELD, 0, __VA_ARGS__)
+#define EFX_POPULATE_OWORD_1(oword, ...) \
+	EFX_POPULATE_OWORD_2(oword, EFX_DUMMY_FIELD, 0, __VA_ARGS__)
+#define EFX_ZERO_OWORD(oword) \
+	EFX_POPULATE_OWORD_1(oword, EFX_DUMMY_FIELD, 0)
+#define EFX_SET_OWORD(oword) \
+	EFX_POPULATE_OWORD_4(oword, \
+			     EFX_DWORD_0, 0xffffffff, \
+			     EFX_DWORD_1, 0xffffffff, \
+			     EFX_DWORD_2, 0xffffffff, \
+			     EFX_DWORD_3, 0xffffffff)
+
+/* Populate a quadword field with various numbers of arguments */
+#define EFX_POPULATE_QWORD_10 EFX_POPULATE_QWORD
+#define EFX_POPULATE_QWORD_9(qword, ...) \
+	EFX_POPULATE_QWORD_10(qword, EFX_DUMMY_FIELD, 0, __VA_ARGS__)
+#define EFX_POPULATE_QWORD_8(qword, ...) \
+	EFX_POPULATE_QWORD_9(qword, EFX_DUMMY_FIELD, 0, __VA_ARGS__)
+#define EFX_POPULATE_QWORD_7(qword, ...) \
+	EFX_POPULATE_QWORD_8(qword, EFX_DUMMY_FIELD, 0, __VA_ARGS__)
+#define EFX_POPULATE_QWORD_6(qword, ...) \
+	EFX_POPULATE_QWORD_7(qword, EFX_DUMMY_FIELD, 0, __VA_ARGS__)
+#define EFX_POPULATE_QWORD_5(qword, ...) \
+	EFX_POPULATE_QWORD_6(qword, EFX_DUMMY_FIELD, 0, __VA_ARGS__)
+#define EFX_POPULATE_QWORD_4(qword, ...) \
+	EFX_POPULATE_QWORD_5(qword, EFX_DUMMY_FIELD, 0, __VA_ARGS__)
+#define EFX_POPULATE_QWORD_3(qword, ...) \
+	EFX_POPULATE_QWORD_4(qword, EFX_DUMMY_FIELD, 0, __VA_ARGS__)
+#define EFX_POPULATE_QWORD_2(qword, ...) \
+	EFX_POPULATE_QWORD_3(qword, EFX_DUMMY_FIELD, 0, __VA_ARGS__)
+#define EFX_POPULATE_QWORD_1(qword, ...) \
+	EFX_POPULATE_QWORD_2(qword, EFX_DUMMY_FIELD, 0, __VA_ARGS__)
+#define EFX_ZERO_QWORD(qword) \
+	EFX_POPULATE_QWORD_1(qword, EFX_DUMMY_FIELD, 0)
+#define EFX_SET_QWORD(qword) \
+	EFX_POPULATE_QWORD_2(qword, \
+			     EFX_DWORD_0, 0xffffffff, \
+			     EFX_DWORD_1, 0xffffffff)
+
+/* Populate a dword field with various numbers of arguments */
+#define EFX_POPULATE_DWORD_10 EFX_POPULATE_DWORD
+#define EFX_POPULATE_DWORD_9(dword, ...) \
+	EFX_POPULATE_DWORD_10(dword, EFX_DUMMY_FIELD, 0, __VA_ARGS__)
+#define EFX_POPULATE_DWORD_8(dword, ...) \
+	EFX_POPULATE_DWORD_9(dword, EFX_DUMMY_FIELD, 0, __VA_ARGS__)
+#define EFX_POPULATE_DWORD_7(dword, ...) \
+	EFX_POPULATE_DWORD_8(dword, EFX_DUMMY_FIELD, 0, __VA_ARGS__)
+#define EFX_POPULATE_DWORD_6(dword, ...) \
+	EFX_POPULATE_DWORD_7(dword, EFX_DUMMY_FIELD, 0, __VA_ARGS__)
+#define EFX_POPULATE_DWORD_5(dword, ...) \
+	EFX_POPULATE_DWORD_6(dword, EFX_DUMMY_FIELD, 0, __VA_ARGS__)
+#define EFX_POPULATE_DWORD_4(dword, ...) \
+	EFX_POPULATE_DWORD_5(dword, EFX_DUMMY_FIELD, 0, __VA_ARGS__)
+#define EFX_POPULATE_DWORD_3(dword, ...) \
+	EFX_POPULATE_DWORD_4(dword, EFX_DUMMY_FIELD, 0, __VA_ARGS__)
+#define EFX_POPULATE_DWORD_2(dword, ...) \
+	EFX_POPULATE_DWORD_3(dword, EFX_DUMMY_FIELD, 0, __VA_ARGS__)
+#define EFX_POPULATE_DWORD_1(dword, ...) \
+	EFX_POPULATE_DWORD_2(dword, EFX_DUMMY_FIELD, 0, __VA_ARGS__)
+#define EFX_ZERO_DWORD(dword) \
+	EFX_POPULATE_DWORD_1(dword, EFX_DUMMY_FIELD, 0)
+#define EFX_SET_DWORD(dword) \
+	EFX_POPULATE_DWORD_1(dword, EFX_DWORD_0, 0xffffffff)
+
+/*
+ * Modify a named field within an already-populated structure.  Used
+ * for read-modify-write operations.
+ *
+ */
+
+#define EFX_INVERT_OWORD(oword) do {		\
+	(oword).u64[0] = ~((oword).u64[0]);	\
+	(oword).u64[1] = ~((oword).u64[1]);	\
+	} while (0)
+
+#define EFX_INSERT_FIELD64(...)					\
+	cpu_to_le64(EFX_INSERT_FIELD_NATIVE(__VA_ARGS__))
+
+#define EFX_INSERT_FIELD32(...)					\
+	cpu_to_le32(EFX_INSERT_FIELD_NATIVE(__VA_ARGS__))
+
+#define EFX_INPLACE_MASK64(min, max, field)			\
+	EFX_INSERT_FIELD64(min, max, field, EFX_MASK64(field))
+
+#define EFX_INPLACE_MASK32(min, max, field)			\
+	EFX_INSERT_FIELD32(min, max, field, EFX_MASK32(field))
+
+#define EFX_SET_OWORD_FIELD64(oword, field, value) do {			\
+	(oword).u64[0] = (((oword).u64[0] 				\
+			   & ~EFX_INPLACE_MASK64(0,  63, field))	\
+			  | EFX_INSERT_FIELD64(0,  63, field, value));  \
+	(oword).u64[1] = (((oword).u64[1] 				\
+			   & ~EFX_INPLACE_MASK64(64, 127, field))	\
+			  | EFX_INSERT_FIELD64(64, 127, field, value)); \
+	} while (0)
+
+#define EFX_SET_QWORD_FIELD64(qword, field, value) do {			\
+	(qword).u64[0] = (((qword).u64[0] 				\
+			   & ~EFX_INPLACE_MASK64(0, 63, field))		\
+			  | EFX_INSERT_FIELD64(0, 63, field, value));	\
+	} while (0)
+
+#define EFX_SET_OWORD_FIELD32(oword, field, value) do {			\
+	(oword).u32[0] = (((oword).u32[0] 				\
+			   & ~EFX_INPLACE_MASK32(0, 31, field))		\
+			  | EFX_INSERT_FIELD32(0, 31, field, value));	\
+	(oword).u32[1] = (((oword).u32[1] 				\
+			   & ~EFX_INPLACE_MASK32(32, 63, field))	\
+			  | EFX_INSERT_FIELD32(32, 63, field, value));	\
+	(oword).u32[2] = (((oword).u32[2] 				\
+			   & ~EFX_INPLACE_MASK32(64, 95, field))	\
+			  | EFX_INSERT_FIELD32(64, 95, field, value));	\
+	(oword).u32[3] = (((oword).u32[3] 				\
+			   & ~EFX_INPLACE_MASK32(96, 127, field))	\
+			  | EFX_INSERT_FIELD32(96, 127, field, value));	\
+	} while (0)
+
+#define EFX_SET_QWORD_FIELD32(qword, field, value) do {			\
+	(qword).u32[0] = (((qword).u32[0] 				\
+			   & ~EFX_INPLACE_MASK32(0, 31, field))		\
+			  | EFX_INSERT_FIELD32(0, 31, field, value));	\
+	(qword).u32[1] = (((qword).u32[1] 				\
+			   & ~EFX_INPLACE_MASK32(32, 63, field))	\
+			  | EFX_INSERT_FIELD32(32, 63, field, value));	\
+	} while (0)
+
+#define EFX_SET_DWORD_FIELD(dword, field, value) do {			\
+	(dword).u32[0] = (((dword).u32[0] 				\
+			   & ~EFX_INPLACE_MASK32(0, 31, field))		\
+			  | EFX_INSERT_FIELD32(0, 31, field, value));	\
+	} while (0)
+
+#if BITS_PER_LONG == 64
+#define EFX_SET_OWORD_FIELD EFX_SET_OWORD_FIELD64
+#define EFX_SET_QWORD_FIELD EFX_SET_QWORD_FIELD64
+#else
+#define EFX_SET_OWORD_FIELD EFX_SET_OWORD_FIELD32
+#define EFX_SET_QWORD_FIELD EFX_SET_QWORD_FIELD32
+#endif
+
+#define EFX_SET_OWORD_FIELD_VER(efx, oword, field, value) do { \
+	if (FALCON_REV(efx) >= FALCON_REV_B0) {			   \
+		EFX_SET_OWORD_FIELD((oword), field##_B0, (value)); \
+	} else { \
+		EFX_SET_OWORD_FIELD((oword), field##_A1, (value)); \
+	} \
+} while (0)
+
+#define EFX_QWORD_FIELD_VER(efx, qword, field)	\
+	(FALCON_REV(efx) >= FALCON_REV_B0 ?	\
+	 EFX_QWORD_FIELD((qword), field##_B0) :	\
+	 EFX_QWORD_FIELD((qword), field##_A1))
+
+/* Used to avoid compiler warnings about shift range exceeding width
+ * of the data types when dma_addr_t is only 32 bits wide.
+ */
+#define DMA_ADDR_T_WIDTH	(8 * sizeof(dma_addr_t))
+#define EFX_DMA_TYPE_WIDTH(width) \
+	(((width) < DMA_ADDR_T_WIDTH) ? (width) : DMA_ADDR_T_WIDTH)
+#define EFX_DMA_MAX_MASK ((DMA_ADDR_T_WIDTH == 64) ? \
+			  ~((u64) 0) : ~((u32) 0))
+#define EFX_DMA_MASK(mask) ((mask) & EFX_DMA_MAX_MASK)
+
+#endif /* EFX_BITFIELD_H */
diff --git a/drivers/net/sfc/enum.h b/drivers/net/sfc/enum.h
new file mode 100644
index 0000000..43663a4
--- /dev/null
+++ b/drivers/net/sfc/enum.h
@@ -0,0 +1,50 @@
+/****************************************************************************
+ * Driver for Solarflare Solarstorm network controllers and boards
+ * Copyright 2007 Solarflare Communications Inc.
+ *
+ * This program is free software; you can redistribute it and/or modify it
+ * under the terms of the GNU General Public License version 2 as published
+ * by the Free Software Foundation, incorporated herein by reference.
+ */
+
+#ifndef EFX_ENUM_H
+#define EFX_ENUM_H
+
+/*****************************************************************************/
+
+/**
+ * enum reset_type - reset types
+ *
+ * %RESET_TYPE_INVSIBLE, %RESET_TYPE_ALL, %RESET_TYPE_WORLD and
+ * %RESET_TYPE_DISABLE specify the method/scope of the reset.  The
+ * other valuesspecify reasons, which efx_schedule_reset() will choose
+ * a method for.
+ *
+ * @RESET_TYPE_INVISIBLE: don't reset the PHYs or interrupts
+ * @RESET_TYPE_ALL: reset everything but PCI core blocks
+ * @RESET_TYPE_WORLD: reset everything, save & restore PCI config
+ * @RESET_TYPE_DISABLE: disable NIC
+ * @RESET_TYPE_MONITOR: reset due to hardware monitor
+ * @RESET_TYPE_INT_ERROR: reset due to internal error
+ * @RESET_TYPE_RX_RECOVERY: reset to recover from RX datapath errors
+ * @RESET_TYPE_RX_DESC_FETCH: pcie error during rx descriptor fetch
+ * @RESET_TYPE_TX_DESC_FETCH: pcie error during tx descriptor fetch
+ * @RESET_TYPE_TX_SKIP: hardware completed empty tx descriptors
+ */
+enum reset_type {
+	RESET_TYPE_NONE = -1,
+	RESET_TYPE_INVISIBLE = 0,
+	RESET_TYPE_ALL = 1,
+	RESET_TYPE_WORLD = 2,
+	RESET_TYPE_DISABLE = 3,
+	RESET_TYPE_MAX_METHOD,
+	RESET_TYPE_MONITOR,
+	RESET_TYPE_INT_ERROR,
+	RESET_TYPE_RX_RECOVERY,
+	RESET_TYPE_RX_DESC_FETCH,
+	RESET_TYPE_TX_DESC_FETCH,
+	RESET_TYPE_TX_SKIP,
+	RESET_TYPE_MAX,
+};
+
+#endif /* EFX_ENUM_H */

-- 
Ben Hutchings, Senior Software Engineer, Solarflare Communications
Not speaking for my employer; that's the marketing department's job.
