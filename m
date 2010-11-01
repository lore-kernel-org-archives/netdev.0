From: Chris Metcalf <cmetcalf@tilera.com>
Subject: [PATCH] drivers/net/tile/: on-chip network drivers for the tile architecture
Date: Mon, 1 Nov 2010 17:00:37 -0400
Message-ID: <201011012107.oA1L7TGd031588@farm-0027.internal.tilera.com>
Return-path: <linux-kernel-owner@vger.kernel.org>
To: linux-kernel@vger.kernel.org
TO: netdev@vger.kernel.org
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

This change adds the first network driver for the tile architecture,
supporting the on-chip XGBE and GBE shims.

The infrastructure is present for the TILE-Gx networking drivers (another
three source files in the new directory) but for now the the actual
tilegx sources are waiting on releasing hardware to initial customers.

Note that arch/tile/include/hv/* are "upstream" headers from the
Tilera hypervisor and will probably benefit less from LKML review.

Signed-off-by: Chris Metcalf <cmetcalf@tilera.com>
---
 arch/tile/include/hv/drv_xgbe_impl.h |  300 ++++
 arch/tile/include/hv/drv_xgbe_intf.h |  615 +++++++
 arch/tile/include/hv/netio_errors.h  |  122 ++
 arch/tile/include/hv/netio_intf.h    | 2975 ++++++++++++++++++++++++++++++++++
 arch/tile/mm/init.c                  |    8 +-
 drivers/net/Kconfig                  |   12 +
 drivers/net/Makefile                 |    1 +
 drivers/net/tile/Makefile            |   10 +
 drivers/net/tile/tilepro.c           | 2452 ++++++++++++++++++++++++++++
 9 files changed, 6493 insertions(+), 2 deletions(-)
 create mode 100644 arch/tile/include/hv/drv_xgbe_impl.h
 create mode 100644 arch/tile/include/hv/drv_xgbe_intf.h
 create mode 100644 arch/tile/include/hv/netio_errors.h
 create mode 100644 arch/tile/include/hv/netio_intf.h
 create mode 100644 drivers/net/tile/Makefile
 create mode 100644 drivers/net/tile/tilepro.c

diff --git a/arch/tile/include/hv/drv_xgbe_impl.h b/arch/tile/include/hv/drv_xgbe_impl.h
new file mode 100644
index 0000000..3a73b2b
--- /dev/null
+++ b/arch/tile/include/hv/drv_xgbe_impl.h
@@ -0,0 +1,300 @@
+/*
+ * Copyright 2010 Tilera Corporation. All Rights Reserved.
+ *
+ *   This program is free software; you can redistribute it and/or
+ *   modify it under the terms of the GNU General Public License
+ *   as published by the Free Software Foundation, version 2.
+ *
+ *   This program is distributed in the hope that it will be useful, but
+ *   WITHOUT ANY WARRANTY; without even the implied warranty of
+ *   MERCHANTABILITY OR FITNESS FOR A PARTICULAR PURPOSE, GOOD TITLE or
+ *   NON INFRINGEMENT.  See the GNU General Public License for
+ *   more details.
+ */
+
+/**
+ * @file drivers/xgbe/impl.h
+ * Implementation details for the NetIO library.
+ */
+
+#ifndef __DRV_XGBE_IMPL_H__
+#define __DRV_XGBE_IMPL_H__
+
+#include <hv/netio_errors.h>
+#include <hv/netio_intf.h>
+#include <hv/drv_xgbe_intf.h>
+
+
+/** How many groups we have (log2). */
+#define LOG2_NUM_GROUPS (12)
+/** How many groups we have. */
+#define NUM_GROUPS (1 << LOG2_NUM_GROUPS)
+
+/** Number of output requests we'll buffer per tile. */
+#define EPP_REQS_PER_TILE (32)
+
+/** Words used in an eDMA command without checksum acceleration. */
+#define EDMA_WDS_NO_CSUM      8
+/** Words used in an eDMA command with checksum acceleration. */
+#define EDMA_WDS_CSUM        10
+/** Total available words in the eDMA command FIFO. */
+#define EDMA_WDS_TOTAL      128
+
+
+/*
+ * FIXME: These definitions are internal and should have underscores!
+ * NOTE: The actual numeric values here are intentional and allow us to
+ * optimize the concept "if small ... else if large ... else ...", by
+ * checking for the low bit being set, and then for non-zero.
+ * These are used as array indices, so they must have the values (0, 1, 2)
+ * in some order.
+ */
+#define SIZE_SMALL (1)       /**< Small packet queue. */
+#define SIZE_LARGE (2)       /**< Large packet queue. */
+#define SIZE_JUMBO (0)       /**< Jumbo packet queue. */
+
+/** The number of "SIZE_xxx" values. */
+#define NETIO_NUM_SIZES 3
+
+
+/*
+ * Default numbers of packets for IPP drivers.  These values are chosen
+ * such that CIPP1 will not overflow its L2 cache.
+ */
+
+/** The default number of small packets. */
+#define NETIO_DEFAULT_SMALL_PACKETS 2750
+/** The default number of large packets. */
+#define NETIO_DEFAULT_LARGE_PACKETS 2500
+/** The default number of jumbo packets. */
+#define NETIO_DEFAULT_JUMBO_PACKETS 250
+
+
+/** Log2 of the size of a memory arena. */
+#define NETIO_ARENA_SHIFT      24      /* 16 MB */
+/** Size of a memory arena. */
+#define NETIO_ARENA_SIZE       (1 << NETIO_ARENA_SHIFT)
+
+
+/** A queue of packets.
+ *
+ * This structure partially defines a queue of packets waiting to be
+ * processed.  The queue as a whole is written to by an interrupt handler and
+ * read by non-interrupt code; this data structure is what's touched by the
+ * interrupt handler.  The other part of the queue state, the read offset, is
+ * kept in user space, not in hypervisor space, so it is in a separate data
+ * structure.
+ *
+ * The read offset (__packet_receive_read in the user part of the queue
+ * structure) points to the next packet to be read. When the read offset is
+ * equal to the write offset, the queue is empty; therefore the queue must
+ * contain one more slot than the required maximum queue size.
+ *
+ * Here's an example of all 3 state variables and what they mean.  All
+ * pointers move left to right.
+ *
+ * @code
+ *   I   I   V   V   V   V   I   I   I   I
+ *   0   1   2   3   4   5   6   7   8   9  10
+ *           ^       ^       ^               ^
+ *           |               |               |
+ *           |               |               __last_packet_plus_one
+ *           |               __buffer_write
+ *           __packet_receive_read
+ * @endcode
+ *
+ * This queue has 10 slots, and thus can hold 9 packets (_last_packet_plus_one
+ * = 10).  The read pointer is at 2, and the write pointer is at 6; thus,
+ * there are valid, unread packets in slots 2, 3, 4, and 5.  The remaining
+ * slots are invalid (do not contain a packet).
+ */
+typedef struct {
+  /** Byte offset of the next notify packet to be written: zero for the first
+   *  packet on the queue, sizeof (netio_pkt_t) for the second packet on the
+   *  queue, etc. */
+  volatile uint32_t __packet_write;
+
+  /** Offset of the packet after the last valid packet (i.e., when any
+   *  pointer is incremented to this value, it wraps back to zero). */
+  uint32_t __last_packet_plus_one;
+}
+__netio_packet_queue_t;
+
+
+/** A queue of buffers.
+ *
+ * This structure partially defines a queue of empty buffers which have been
+ * obtained via requests to the IPP.  (The elements of the queue are packet
+ * handles, which are transformed into a full netio_pkt_t when the buffer is
+ * retrieved.)  The queue as a whole is written to by an interrupt handler and
+ * read by non-interrupt code; this data structure is what's touched by the
+ * interrupt handler.  The other parts of the queue state, the read offset and
+ * requested write offset, are kept in user space, not in hypervisor space, so
+ * they are in a separate data structure.
+ *
+ * The read offset (__buffer_read in the user part of the queue structure)
+ * points to the next buffer to be read. When the read offset is equal to the
+ * write offset, the queue is empty; therefore the queue must contain one more
+ * slot than the required maximum queue size.
+ *
+ * The requested write offset (__buffer_requested_write in the user part of
+ * the queue structure) points to the slot which will hold the next buffer we
+ * request from the IPP, once we get around to sending such a request.  When
+ * the requested write offset is equal to the write offset, no requests for
+ * new buffers are outstanding; when the requested write offset is one greater
+ * than the read offset, no more requests may be sent.
+ *
+ * Note that, unlike the packet_queue, the buffer_queue places incoming
+ * buffers at decreasing addresses.  This makes the check for "is it time to
+ * wrap the buffer pointer" cheaper in the assembly code which receives new
+ * buffers, and means that the value which defines the queue size,
+ * __last_buffer, is different than in the packet queue.  Also, the offset
+ * used in the packet_queue is already scaled by the size of a packet; here we
+ * use unscaled slot indices for the offsets.  (These differences are
+ * historical, and in the future it's possible that the packet_queue will look
+ * more like this queue.)
+ *
+ * @code
+ * Here's an example of all 4 state variables and what they mean.  Remember:
+ * all pointers move right to left.
+ *
+ *   V   V   V   I   I   R   R   V   V   V
+ *   0   1   2   3   4   5   6   7   8   9
+ *           ^       ^       ^           ^
+ *           |       |       |           |
+ *           |       |       |           __last_buffer
+ *           |       |       __buffer_write
+ *           |       __buffer_requested_write
+ *           __buffer_read
+ * @endcode
+ *
+ * This queue has 10 slots, and thus can hold 9 buffers (_last_buffer = 9).
+ * The read pointer is at 2, and the write pointer is at 6; thus, there are
+ * valid, unread buffers in slots 2, 1, 0, 9, 8, and 7.  The requested write
+ * pointer is at 4; thus, requests have been made to the IPP for buffers which
+ * will be placed in slots 6 and 5 when they arrive.  Finally, the remaining
+ * slots are invalid (do not contain a buffer).
+ */
+typedef struct
+{
+  /** Ordinal number of the next buffer to be written: 0 for the first slot in
+   *  the queue, 1 for the second slot in the queue, etc. */
+  volatile uint32_t __buffer_write;
+
+  /** Ordinal number of the last buffer (i.e., when any pointer is decremented
+   *  below zero, it is reloaded with this value). */
+  uint32_t __last_buffer;
+}
+__netio_buffer_queue_t;
+
+
+/**
+ * An object for providing Ethernet packets to a process.
+ */
+typedef struct __netio_queue_impl_t
+{
+  /** The queue of packets waiting to be received. */
+  __netio_packet_queue_t __packet_receive_queue;
+  /** The intr bit mask that IDs this device. */
+  unsigned int __intr_id;
+  /** Offset to queues of empty buffers, one per size. */
+  uint32_t __buffer_queue[NETIO_NUM_SIZES];
+  /** The address of the first EPP tile, or -1 if no EPP. */
+  /* ISSUE: Actually this is always "0" or "~0". */
+  uint32_t __epp_location;
+  /** The queue ID that this queue represents. */
+  unsigned int __queue_id;
+  /** Number of acknowledgements received. */
+  volatile uint32_t __acks_received;
+  /** Last completion number received for packet_sendv. */
+  volatile uint32_t __last_completion_rcv;
+  /** Number of packets allowed to be outstanding. */
+  uint32_t __max_outstanding;
+  /** First VA available for packets. */
+  void* __va_0;
+  /** First VA in second range available for packets. */
+  void* __va_1;
+  /** Padding to align the "__packets" field to the size of a netio_pkt_t. */
+  uint32_t __padding[3];
+  /** The packets themselves. */
+  netio_pkt_t __packets[0];
+}
+netio_queue_impl_t;
+
+
+/**
+ * An object for managing the user end of a NetIO queue.
+ */
+typedef struct __netio_queue_user_impl_t
+{
+  /** The next incoming packet to be read. */
+  uint32_t __packet_receive_read;
+  /** The next empty buffers to be read, one index per size. */
+  uint8_t __buffer_read[NETIO_NUM_SIZES];
+  /** Where the empty buffer we next request from the IPP will go, one index
+   * per size. */
+  uint8_t __buffer_requested_write[NETIO_NUM_SIZES];
+  /** PCIe interface flag. */
+  uint8_t __pcie;
+  /** Number of packets left to be received before we send a credit update. */
+  uint32_t __receive_credit_remaining;
+  /** Value placed in __receive_credit_remaining when it reaches zero. */
+  uint32_t __receive_credit_interval;
+  /** First fast I/O routine index. */
+  uint32_t __fastio_index;
+  /** Number of acknowledgements expected. */
+  uint32_t __acks_outstanding;
+  /** Last completion number requested. */
+  uint32_t __last_completion_req;
+  /** File descriptor for driver. */
+  int __fd;
+}
+netio_queue_user_impl_t;
+
+
+#define NETIO_GROUP_CHUNK_SIZE   64   /**< Max # groups in one IPP request */
+#define NETIO_BUCKET_CHUNK_SIZE  64   /**< Max # buckets in one IPP request */
+
+
+/** Internal structure used to convey packet send information to the
+ * hypervisor.  FIXME: Actually, it's not used for that anymore, but
+ * netio_packet_send() still uses it internally.
+ */
+typedef struct
+{
+  uint16_t flags;              /**< Packet flags (__NETIO_SEND_FLG_xxx) */
+  uint16_t transfer_size;      /**< Size of packet */
+  uint32_t va;                 /**< VA of start of packet */
+  __netio_pkt_handle_t handle; /**< Packet handle */
+  uint32_t csum0;              /**< First checksum word */
+  uint32_t csum1;              /**< Second checksum word */
+}
+__netio_send_cmd_t;
+
+
+/** Flags used in two contexts:
+ *  - As the "flags" member in the __netio_send_cmd_t, above; used only
+ *    for netio_pkt_send_{prepare,commit}.
+ *  - As part of the flags passed to the various send packet fast I/O calls.
+ */
+
+/** Need acknowledgement on this packet.  Note that some code in the
+ *  normal send_pkt fast I/O handler assumes that this is equal to 1. */
+#define __NETIO_SEND_FLG_ACK    0x1
+
+/** Do checksum on this packet.  (Only used with the __netio_send_cmd_t;
+ *  normal packet sends use a special fast I/O index to denote checksumming,
+ *  and multi-segment sends test the checksum descriptor.) */
+#define __NETIO_SEND_FLG_CSUM   0x2
+
+/** Get a completion on this packet.  Only used with multi-segment sends.  */
+#define __NETIO_SEND_FLG_COMPLETION 0x4
+
+/** Position of the number-of-extra-segments value in the flags word.
+    Only used with multi-segment sends. */
+#define __NETIO_SEND_FLG_XSEG_SHIFT 3
+
+/** Width of the number-of-extra-segments value in the flags word. */
+#define __NETIO_SEND_FLG_XSEG_WIDTH 2
+
+#endif /* __DRV_XGBE_IMPL_H__ */
diff --git a/arch/tile/include/hv/drv_xgbe_intf.h b/arch/tile/include/hv/drv_xgbe_intf.h
new file mode 100644
index 0000000..31dd38a
--- /dev/null
+++ b/arch/tile/include/hv/drv_xgbe_intf.h
@@ -0,0 +1,615 @@
+/*
+ * Copyright 2010 Tilera Corporation. All Rights Reserved.
+ *
+ *   This program is free software; you can redistribute it and/or
+ *   modify it under the terms of the GNU General Public License
+ *   as published by the Free Software Foundation, version 2.
+ *
+ *   This program is distributed in the hope that it will be useful, but
+ *   WITHOUT ANY WARRANTY; without even the implied warranty of
+ *   MERCHANTABILITY OR FITNESS FOR A PARTICULAR PURPOSE, GOOD TITLE or
+ *   NON INFRINGEMENT.  See the GNU General Public License for
+ *   more details.
+ */
+
+/**
+ * @file drv_xgbe_intf.h
+ * Interface to the hypervisor XGBE driver.
+ */
+
+#ifndef __DRV_XGBE_INTF_H__
+#define __DRV_XGBE_INTF_H__
+
+/**
+ * An object for forwarding VAs and PAs to the hypervisor.
+ * @ingroup types
+ *
+ * This allows the supervisor to specify a number of areas of memory to
+ * store packet buffers.
+ */
+typedef struct
+{
+  /** The physical address of the memory. */
+  HV_PhysAddr pa;
+  /** Page table entry for the memory.  This is only used to derive the
+   *  memory's caching mode; the PA bits are ignored. */
+  HV_PTE pte;
+  /** The virtual address of the memory. */
+  HV_VirtAddr va;
+  /** Size (in bytes) of the memory area. */
+  int size;
+
+}
+netio_ipp_address_t;
+
+/** The various pread/pwrite offsets into the hypervisor-level driver.
+ * @ingroup types
+ */
+typedef enum
+{
+  /** Inform the Linux driver of the address of the NetIO arena memory.
+   *  This offset is actually only used to convey information from netio
+   *  to the Linux driver; it never makes it from there to the hypervisor.
+   *  Write-only; takes a uint32_t specifying the VA address. */
+  NETIO_FIXED_ADDR               = 0x5000000000000000ULL,
+
+  /** Inform the Linux driver of the size of the NetIO arena memory.
+   *  This offset is actually only used to convey information from netio
+   *  to the Linux driver; it never makes it from there to the hypervisor.
+   *  Write-only; takes a uint32_t specifying the VA size. */
+  NETIO_FIXED_SIZE               = 0x5100000000000000ULL,
+
+  /** Register current tile with IPP.  Write then read: write, takes a
+   *  netio_input_config_t, read returns a pointer to a netio_queue_impl_t. */
+  NETIO_IPP_INPUT_REGISTER_OFF   = 0x6000000000000000ULL,
+
+  /** Unregister current tile from IPP.  Write-only, takes a dummy argument. */
+  NETIO_IPP_INPUT_UNREGISTER_OFF = 0x6100000000000000ULL,
+
+  /** Start packets flowing.  Write-only, takes a dummy argument. */
+  NETIO_IPP_INPUT_INIT_OFF       = 0x6200000000000000ULL,
+
+  /** Stop packets flowing.  Write-only, takes a dummy argument. */
+  NETIO_IPP_INPUT_UNINIT_OFF     = 0x6300000000000000ULL,
+
+  /** Configure group (typically we group on VLAN).  Write-only: takes an
+   *  array of netio_group_t's, low 24 bits of the offset is the base group
+   *  number times the size of a netio_group_t. */
+  NETIO_IPP_INPUT_GROUP_CFG_OFF  = 0x6400000000000000ULL,
+
+  /** Configure bucket.  Write-only: takes an array of netio_bucket_t's, low
+   *  24 bits of the offset is the base bucket number times the size of a
+   *  netio_bucket_t. */
+  NETIO_IPP_INPUT_BUCKET_CFG_OFF = 0x6500000000000000ULL,
+
+  /** Get/set a parameter.  Read or write: read or write data is the parameter
+   *  value, low 32 bits of the offset is a __netio_getset_offset_t. */
+  NETIO_IPP_PARAM_OFF            = 0x6600000000000000ULL,
+
+  /** Get fast I/O index.  Read-only; returns a 4-byte base index value. */
+  NETIO_IPP_GET_FASTIO_OFF       = 0x6700000000000000ULL,
+
+  /** Configure hijack IP address.  Packets with this IPv4 dest address
+   *  go to bucket NETIO_NUM_BUCKETS - 1.  Write-only: takes an IP address
+   *  in some standard form.  FIXME: Define the form! */
+  NETIO_IPP_INPUT_HIJACK_CFG_OFF  = 0x6800000000000000ULL,
+
+  /**
+   * Offsets beyond this point are reserved for the supervisor (although that
+   * enforcement must be done by the supervisor driver itself).
+   */
+  NETIO_IPP_USER_MAX_OFF         = 0x6FFFFFFFFFFFFFFFULL,
+
+  /** Register I/O memory.  Write-only, takes a netio_ipp_address_t. */
+  NETIO_IPP_IOMEM_REGISTER_OFF   = 0x7000000000000000ULL,
+
+  /** Unregister I/O memory.  Write-only, takes a netio_ipp_address_t. */
+  NETIO_IPP_IOMEM_UNREGISTER_OFF = 0x7100000000000000ULL,
+
+  /* Offsets greater than 0x7FFFFFFF can't be used directly from Linux
+   * userspace code due to limitations in the pread/pwrite syscalls. */
+
+  /** Drain LIPP buffers. */
+  NETIO_IPP_DRAIN_OFF              = 0xFA00000000000000ULL,
+
+  /** Supply a netio_ipp_address_t to be used as shared memory for the
+   *  LEPP command queue. */
+  NETIO_EPP_SHM_OFF              = 0xFB00000000000000ULL,
+
+  /* 0xFC... is currently unused. */
+
+  /** Stop IPP/EPP tiles.  Write-only, takes a dummy argument.  */
+  NETIO_IPP_STOP_SHIM_OFF        = 0xFD00000000000000ULL,
+
+  /** Start IPP/EPP tiles.  Write-only, takes a dummy argument.  */
+  NETIO_IPP_START_SHIM_OFF       = 0xFE00000000000000ULL,
+
+  /** Supply packet arena.  Write-only, takes an array of
+    * netio_ipp_address_t values. */
+  NETIO_IPP_ADDRESS_OFF          = 0xFF00000000000000ULL,
+} netio_hv_offset_t;
+
+/** Extract the base offset from an offset */
+#define NETIO_BASE_OFFSET(off)    ((off) & 0xFF00000000000000ULL)
+/** Extract the local offset from an offset */
+#define NETIO_LOCAL_OFFSET(off)   ((off) & 0x00FFFFFFFFFFFFFFULL)
+
+
+/**
+ * Get/set offset.
+ */
+typedef union
+{
+  struct
+  {
+    uint64_t addr:48;        /**< Class-specific address */
+    unsigned int class:8;    /**< Class (e.g., NETIO_PARAM) */
+    unsigned int opcode:8;   /**< High 8 bits of NETIO_IPP_PARAM_OFF */
+  }
+  bits;                      /**< Bitfields */
+  uint64_t word;             /**< Aggregated value to use as the offset */
+}
+__netio_getset_offset_t;
+
+/**
+ * Fast I/O index offsets (must be contiguous).
+ */
+typedef enum
+{
+  NETIO_FASTIO_ALLOCATE         = 0, /**< Get empty packet buffer */
+  NETIO_FASTIO_FREE_BUFFER      = 1, /**< Give buffer back to IPP */
+  NETIO_FASTIO_RETURN_CREDITS   = 2, /**< Give credits to IPP */
+  NETIO_FASTIO_SEND_PKT_NOCK    = 3, /**< Send a packet, no checksum */
+  NETIO_FASTIO_SEND_PKT_CK      = 4, /**< Send a packet, with checksum */
+  NETIO_FASTIO_SEND_PKT_VEC     = 5, /**< Send a vector of packets */
+  NETIO_FASTIO_SENDV_PKT        = 6, /**< Sendv one packet */
+  NETIO_FASTIO_NUM_INDEX        = 7, /**< Total number of fast I/O indices */
+} netio_fastio_index_t;
+
+/** 3-word return type for Fast I/O call. */
+typedef struct
+{
+  int err;            /**< Error code. */
+  uint32_t val0;      /**< Value.  Meaning depends upon the specific call. */
+  uint32_t val1;      /**< Value.  Meaning depends upon the specific call. */
+} netio_fastio_rv3_t;
+
+/** 0-argument fast I/O call */
+int __netio_fastio0(uint32_t fastio_index);
+/** 1-argument fast I/O call */
+int __netio_fastio1(uint32_t fastio_index, uint32_t arg0);
+/** 3-argument fast I/O call, 2-word return value */
+netio_fastio_rv3_t __netio_fastio3_rv3(uint32_t fastio_index, uint32_t arg0,
+                                       uint32_t arg1, uint32_t arg2);
+/** 4-argument fast I/O call */
+int __netio_fastio4(uint32_t fastio_index, uint32_t arg0, uint32_t arg1,
+                    uint32_t arg2, uint32_t arg3);
+/** 6-argument fast I/O call */
+int __netio_fastio6(uint32_t fastio_index, uint32_t arg0, uint32_t arg1,
+                    uint32_t arg2, uint32_t arg3, uint32_t arg4, uint32_t arg5);
+/** 9-argument fast I/O call */
+int __netio_fastio9(uint32_t fastio_index, uint32_t arg0, uint32_t arg1,
+                    uint32_t arg2, uint32_t arg3, uint32_t arg4, uint32_t arg5,
+                    uint32_t arg6, uint32_t arg7, uint32_t arg8);
+
+/** Allocate an empty packet.
+ * @param fastio_index Fast I/O index.
+ * @param size Size of the packet to allocate.
+ */
+#define __netio_fastio_allocate(fastio_index, size) \
+  __netio_fastio1((fastio_index) + NETIO_FASTIO_ALLOCATE, size)
+
+/** Free a buffer.
+ * @param fastio_index Fast I/O index.
+ * @param handle Handle for the packet to free.
+ */
+#define __netio_fastio_free_buffer(fastio_index, handle) \
+  __netio_fastio1((fastio_index) + NETIO_FASTIO_FREE_BUFFER, handle)
+
+/** Increment our receive credits.
+ * @param fastio_index Fast I/O index.
+ * @param credits Number of credits to add.
+ */
+#define __netio_fastio_return_credits(fastio_index, credits) \
+  __netio_fastio1((fastio_index) + NETIO_FASTIO_RETURN_CREDITS, credits)
+
+/** Send packet, no checksum.
+ * @param fastio_index Fast I/O index.
+ * @param ackflag Nonzero if we want an ack.
+ * @param size Size of the packet.
+ * @param va Virtual address of start of packet.
+ * @param handle Packet handle.
+ */
+#define __netio_fastio_send_pkt_nock(fastio_index, ackflag, size, va, handle) \
+  __netio_fastio4((fastio_index) + NETIO_FASTIO_SEND_PKT_NOCK, ackflag, \
+                  size, va, handle)
+
+/** Send packet, calculate checksum.
+ * @param fastio_index Fast I/O index.
+ * @param ackflag Nonzero if we want an ack.
+ * @param size Size of the packet.
+ * @param va Virtual address of start of packet.
+ * @param handle Packet handle.
+ * @param csum0 Shim checksum header.
+ * @param csum1 Checksum seed.
+ */
+#define __netio_fastio_send_pkt_ck(fastio_index, ackflag, size, va, handle, \
+                                   csum0, csum1) \
+  __netio_fastio6((fastio_index) + NETIO_FASTIO_SEND_PKT_CK, ackflag, \
+                  size, va, handle, csum0, csum1)
+
+
+/** Format for the "csum0" argument to the __netio_fastio_send routines
+ * and LEPP.  Note that this is currently exactly identical to the
+ * ShimProtocolOffloadHeader.
+ */
+typedef union
+{
+  struct
+  {
+    unsigned int start_byte:7;       /**< The first byte to be checksummed */
+    unsigned int count:14;           /**< Number of bytes to be checksummed. */
+    unsigned int destination_byte:7; /**< The byte to write the checksum to. */
+    unsigned int reserved:4;         /**< Reserved. */
+  } bits;                            /**< Decomposed method of access. */
+  unsigned int word;                 /**< To send out the IDN. */
+} __netio_checksum_header_t;
+
+
+/** Sendv packet with 1 or 2 segments.
+ * @param fastio_index Fast I/O index.
+ * @param flags Ack/csum/notify flags in low 3 bits; number of segments minus
+ *        1 in next 2 bits; expected checksum in high 16 bits.
+ * @param confno Confirmation number to request, if notify flag set.
+ * @param csum0 Checksum descriptor; if zero, no checksum.
+ * @param va_F Virtual address of first segment.
+ * @param va_L Virtual address of last segment, if 2 segments.
+ * @param len_F_L Length of first segment in low 16 bits; length of last
+ *        segment, if 2 segments, in high 16 bits.
+ */
+#define __netio_fastio_sendv_pkt_1_2(fastio_index, flags, confno, csum0, \
+                                     va_F, va_L, len_F_L) \
+  __netio_fastio6((fastio_index) + NETIO_FASTIO_SENDV_PKT, flags, confno, \
+                  csum0, va_F, va_L, len_F_L)
+
+/** Send packet on PCIe interface.
+ * @param fastio_index Fast I/O index.
+ * @param flags Ack/csum/notify flags in low 3 bits.
+ * @param confno Confirmation number to request, if notify flag set.
+ * @param csum0 Checksum descriptor; Hard wired 0, not needed for PCIe.
+ * @param va_F Virtual address of the packet buffer.
+ * @param va_L Virtual address of last segment, if 2 segments. Hard wired 0.
+ * @param len_F_L Length of the packet buffer in low 16 bits.
+ */
+#define __netio_fastio_send_pcie_pkt(fastio_index, flags, confno, csum0, \
+                                     va_F, va_L, len_F_L) \
+  __netio_fastio6((fastio_index) + PCIE_FASTIO_SENDV_PKT, flags, confno, \
+                  csum0, va_F, va_L, len_F_L)
+
+/** Sendv packet with 3 or 4 segments.
+ * @param fastio_index Fast I/O index.
+ * @param flags Ack/csum/notify flags in low 3 bits; number of segments minus
+ *        1 in next 2 bits; expected checksum in high 16 bits.
+ * @param confno Confirmation number to request, if notify flag set.
+ * @param csum0 Checksum descriptor; if zero, no checksum.
+ * @param va_F Virtual address of first segment.
+ * @param va_L Virtual address of last segment (third segment if 3 segments,
+ *        fourth segment if 4 segments).
+ * @param len_F_L Length of first segment in low 16 bits; length of last
+ *        segment in high 16 bits.
+ * @param va_M0 Virtual address of "middle 0" segment; this segment is sent
+ *        second when there are three segments, and third if there are four.
+ * @param va_M1 Virtual address of "middle 1" segment; this segment is sent
+ *        second when there are four segments.
+ * @param len_M0_M1 Length of middle 0 segment in low 16 bits; length of middle
+ *        1 segment, if 4 segments, in high 16 bits.
+ */
+#define __netio_fastio_sendv_pkt_3_4(fastio_index, flags, confno, csum0, va_F, \
+                                     va_L, len_F_L, va_M0, va_M1, len_M0_M1) \
+  __netio_fastio9((fastio_index) + NETIO_FASTIO_SENDV_PKT, flags, confno, \
+                  csum0, va_F, va_L, len_F_L, va_M0, va_M1, len_M0_M1)
+
+/** Send vector of packets.
+ * @param fastio_index Fast I/O index.
+ * @param seqno Number of packets transmitted so far on this interface;
+ *        used to decide which packets should be acknowledged.
+ * @param nentries Number of entries in vector.
+ * @param va Virtual address of start of vector entry array.
+ * @return 3-word netio_fastio_rv3_t structure.  The structure's err member
+ *         is an error code, or zero if no error.  The val0 member is the
+ *         updated value of seqno; it has been incremented by 1 for each
+ *         packet sent.  That increment may be less than nentries if an
+ *         error occured, or if some of the entries in the vector contain
+ *         handles equal to NETIO_PKT_HANDLE_NONE.  The val1 member is the
+ *         updated value of nentries; it has been decremented by 1 for each
+ *         vector entry processed.  Again, that decrement may be less than
+ *         nentries (leaving the returned value positive) if an error
+ *         occurred.
+ */
+#define __netio_fastio_send_pkt_vec(fastio_index, seqno, nentries, va) \
+  __netio_fastio3_rv3((fastio_index) + NETIO_FASTIO_SEND_PKT_VEC, seqno, \
+                      nentries, va)
+
+
+/** An egress DMA command for LEPP. */
+typedef struct
+{
+  /** Is this a TSO transfer?
+   *
+   * NOTE: This field is always 0, to distinguish it from
+   * lepp_tso_cmd_t.  It must come first!
+   */
+  uint8_t tso               : 1;
+
+  /** Unused padding bits. */
+  uint8_t _unused           : 3;
+
+  /** Should this packet be sent directly from caches instead of DRAM,
+   * using hash-for-home to locate the packet data?
+   */
+  uint8_t hash_for_home     : 1;
+
+  /** Should we compute a checksum? */
+  uint8_t compute_checksum  : 1;
+
+  /** Is this the final buffer for this packet?
+   *
+   * A single packet can be split over several input buffers (a "gather"
+   * operation).  This flag indicates that this is the last buffer
+   * in a packet.
+   */
+  uint8_t end_of_packet     : 1;
+
+  /** Should LEPP advance 'comp_busy' when this DMA is fully finished? */
+  uint8_t send_completion   : 1;
+
+  /** High bits of Client Physical Address of the start of the buffer
+   *  to be egressed.
+   *
+   *  NOTE: Only 6 bits are actually needed here, as CPAs are
+   *  currently 38 bits.  So two bits could be scavenged from this.
+   */
+  uint8_t cpa_hi;
+
+  /** The number of bytes to be egressed. */
+  uint16_t length;
+
+  /** Low 32 bits of Client Physical Address of the start of the buffer
+   *  to be egressed.
+   */
+  uint32_t cpa_lo;
+
+  /** Checksum information (only used if 'compute_checksum'). */
+  __netio_checksum_header_t checksum_data;
+
+} lepp_cmd_t;
+
+
+/** A chunk of physical memory for a TSO egress. */
+typedef struct
+{
+  /** The low bits of the CPA. */
+  uint32_t cpa_lo;
+  /** The high bits of the CPA. */
+  uint16_t cpa_hi		: 15;
+  /** Should this packet be sent directly from caches instead of DRAM,
+   *  using hash-for-home to locate the packet data?
+   */
+  uint16_t hash_for_home	: 1;
+  /** The length in bytes. */
+  uint16_t length;
+} lepp_frag_t;
+
+
+/** An LEPP command that handles TSO. */
+typedef struct
+{
+  /** Is this a TSO transfer?
+   *
+   *  NOTE: This field is always 1, to distinguish it from
+   *  lepp_cmd_t.  It must come first!
+   */
+  uint8_t tso             : 1;
+
+  /** Unused padding bits. */
+  uint8_t _unused         : 7;
+
+  /** Size of the header[] array in bytes.  It must be in the range
+   *  [40, 127], which are the smallest header for a TCP packet over
+   *  Ethernet and the maximum possible prepend size supported by
+   *  hardware, respectively.  Note that the array storage must be
+   *  padded out to a multiple of four bytes so that the following
+   *  LEPP command is aligned properly.
+   */
+  uint8_t header_size;
+
+  /** Byte offset of the IP header in header[]. */
+  uint8_t ip_offset;
+
+  /** Byte offset of the TCP header in header[]. */
+  uint8_t tcp_offset;
+
+  /** The number of bytes to use for the payload of each packet,
+   *  except of course the last one, which may not have enough bytes.
+   *  This means that each Ethernet packet except the last will have a
+   *  size of header_size + payload_size.
+   */
+  uint16_t payload_size;
+
+  /** The length of the 'frags' array that follows this struct. */
+  uint16_t num_frags;
+
+  /** The actual frags. */
+  lepp_frag_t frags[0 /* Variable-sized; num_frags entries. */];
+
+  /*
+   * The packet header template logically follows frags[],
+   * but you can't declare that in C.
+   *
+   * uint32_t header[header_size_in_words_rounded_up];
+   */
+
+} lepp_tso_cmd_t;
+
+
+/** An LEPP completion ring entry. */
+typedef void* lepp_comp_t;
+
+
+/** Maximum number of frags for one TSO command.  This is adapted from
+ *  linux's "MAX_SKB_FRAGS", and presumably over-estimates by one, for
+ *  our page size of exactly 65536.  We add one for a "body" fragment.
+ */
+#define LEPP_MAX_FRAGS (65536 / HV_PAGE_SIZE_SMALL + 2 + 1)
+
+/** Total number of bytes needed for an lepp_tso_cmd_t. */
+#define LEPP_TSO_CMD_SIZE(num_frags, header_size) \
+  (sizeof(lepp_tso_cmd_t) + \
+   (num_frags) * sizeof(lepp_frag_t) + \
+   (((header_size) + 3) & -4))
+
+/** The size of the lepp "cmd" queue. */
+#define LEPP_CMD_QUEUE_BYTES \
+ (((CHIP_L2_CACHE_SIZE() - 2 * CHIP_L2_LINE_SIZE()) / \
+  (sizeof(lepp_cmd_t) + sizeof(lepp_comp_t))) * sizeof(lepp_cmd_t))
+
+/** The largest possible command that can go in lepp_queue_t::cmds[]. */
+#define LEPP_MAX_CMD_SIZE LEPP_TSO_CMD_SIZE(LEPP_MAX_FRAGS, 128)
+
+/** The largest possible value of lepp_queue_t::cmd_{head, tail} (inclusive).
+ */
+#define LEPP_CMD_LIMIT \
+  (LEPP_CMD_QUEUE_BYTES - LEPP_MAX_CMD_SIZE)
+
+/** The maximum number of completions in an LEPP queue. */
+#define LEPP_COMP_QUEUE_SIZE \
+  ((LEPP_CMD_LIMIT + sizeof(lepp_cmd_t) - 1) / sizeof(lepp_cmd_t))
+
+/** Increment an index modulo the queue size. */
+#define LEPP_QINC(var) \
+  (var = __insn_mnz(var - (LEPP_COMP_QUEUE_SIZE - 1), var + 1))
+
+/** A queue used to convey egress commands from the client to LEPP. */
+typedef struct
+{
+  /** Index of first completion not yet processed by user code.
+   *  If this is equal to comp_busy, there are no such completions.
+   *
+   *  NOTE: This is only read/written by the user.
+   */
+  unsigned int comp_head;
+
+  /** Index of first completion record not yet completed.
+   *  If this is equal to comp_tail, there are no such completions.
+   *  This index gets advanced (modulo LEPP_QUEUE_SIZE) whenever
+   *  a command with the 'completion' bit set is finished.
+   *
+   *  NOTE: This is only written by LEPP, only read by the user.
+   */
+  volatile unsigned int comp_busy;
+
+  /** Index of the first empty slot in the completion ring.
+   *  Entries from this up to but not including comp_head (in ring order)
+   *  can be filled in with completion data.
+   *
+   *  NOTE: This is only read/written by the user.
+   */
+  unsigned int comp_tail;
+
+  /** Byte index of first command enqueued for LEPP but not yet processed.
+   *
+   *  This is always divisible by sizeof(void*) and always <= LEPP_CMD_LIMIT.
+   *
+   *  NOTE: LEPP advances this counter as soon as it no longer needs
+   *  the cmds[] storage for this entry, but the transfer is not actually
+   *  complete (i.e. the buffer pointed to by the command is no longer
+   *  needed) until comp_busy advances.
+   *
+   *  If this is equal to cmd_tail, the ring is empty.
+   *
+   *  NOTE: This is only written by LEPP, only read by the user.
+   */
+  volatile unsigned int cmd_head;
+
+  /** Byte index of first empty slot in the command ring.  This field can
+   *  be incremented up to but not equal to cmd_head (because that would
+   *  mean the ring is empty).
+   *
+   *  This is always divisible by sizeof(void*) and always <= LEPP_CMD_LIMIT.
+   *
+   *  NOTE: This is read/written by the user, only read by LEPP.
+   */
+  volatile unsigned int cmd_tail;
+
+  /** A ring of variable-sized egress DMA commands.
+   *
+   *  NOTE: Only written by the user, only read by LEPP.
+   */
+  char cmds[LEPP_CMD_QUEUE_BYTES]
+    __attribute__((aligned(CHIP_L2_LINE_SIZE())));
+
+  /** A ring of user completion data.
+   *  NOTE: Only read/written by the user.
+   */
+  lepp_comp_t comps[LEPP_COMP_QUEUE_SIZE]
+    __attribute__((aligned(CHIP_L2_LINE_SIZE())));
+} lepp_queue_t;
+
+
+/** An internal helper function for determining the number of entries
+ *  available in a ring buffer, given that there is one sentinel.
+ */
+static inline unsigned int
+_lepp_num_free_slots(unsigned int head, unsigned int tail)
+{
+  /*
+   * One entry is reserved for use as a sentinel, to distinguish
+   * "empty" from "full".  So we compute
+   * (head - tail - 1) % LEPP_QUEUE_SIZE, but without using a slow % operation.
+   */
+  return (head - tail - 1) + ((head <= tail) ? LEPP_COMP_QUEUE_SIZE : 0);
+}
+
+
+/** Returns how many new comp entries can be enqueued. */
+static inline unsigned int
+lepp_num_free_comp_slots(const lepp_queue_t* q)
+{
+  return _lepp_num_free_slots(q->comp_head, q->comp_tail);
+}
+
+static inline int
+lepp_qsub(int v1, int v2)
+{
+  int delta = v1 - v2;
+  return delta + ((delta >> 31) & LEPP_COMP_QUEUE_SIZE);
+}
+
+
+/* FIXME: Check this from linux, via a new "pwrite()" call. */
+#define LIPP_VERSION 1
+
+
+/** We use exactly two bytes of alignment padding. */
+#define LIPP_PACKET_PADDING 2
+
+/** The minimum size of a "small" buffer (including the padding). */
+#define LIPP_SMALL_PACKET_SIZE 128
+
+/*
+ * NOTE: The following two values should total to less than around
+ * 13582, to keep the total size used for "lipp_state_t" below 64K.
+ */
+
+/** The maximum number of "small" buffers.
+ *  This is enough for 53 network cpus with 128 credits.  Note that
+ *  if these are exhausted, we will fall back to using large buffers.
+ */
+#define LIPP_SMALL_BUFFERS 6785
+
+/** The maximum number of "large" buffers.
+ *  This is enough for 53 network cpus with 128 credits.
+ */
+#define LIPP_LARGE_BUFFERS 6785
+
+#endif /* __DRV_XGBE_INTF_H__ */
diff --git a/arch/tile/include/hv/netio_errors.h b/arch/tile/include/hv/netio_errors.h
new file mode 100644
index 0000000..e1591bf
--- /dev/null
+++ b/arch/tile/include/hv/netio_errors.h
@@ -0,0 +1,122 @@
+/*
+ * Copyright 2010 Tilera Corporation. All Rights Reserved.
+ *
+ *   This program is free software; you can redistribute it and/or
+ *   modify it under the terms of the GNU General Public License
+ *   as published by the Free Software Foundation, version 2.
+ *
+ *   This program is distributed in the hope that it will be useful, but
+ *   WITHOUT ANY WARRANTY; without even the implied warranty of
+ *   MERCHANTABILITY OR FITNESS FOR A PARTICULAR PURPOSE, GOOD TITLE or
+ *   NON INFRINGEMENT.  See the GNU General Public License for
+ *   more details.
+ */
+
+/**
+ * Error codes returned from NetIO routines.
+ */
+
+#ifndef __NETIO_ERRORS_H__
+#define __NETIO_ERRORS_H__
+
+/**
+ * @addtogroup error
+ *
+ * @brief The error codes returned by NetIO functions.
+ *
+ * NetIO functions return 0 (defined as ::NETIO_NO_ERROR) on success, and
+ * a negative value if an error occurs.
+ *
+ * In cases where a NetIO function failed due to a error reported by
+ * system libraries, the error code will be the negation of the
+ * system errno at the time of failure.  The @ref netio_strerror()
+ * function will deliver error strings for both NetIO and system error
+ * codes.
+ *
+ * @{
+ */
+
+/** The set of all NetIO errors. */
+typedef enum
+{
+  /** Operation successfully completed. */
+  NETIO_NO_ERROR        = 0,
+
+  /** A packet was successfully retrieved from an input queue. */
+  NETIO_PKT             = 0,
+
+  /** Largest NetIO error number. */
+  NETIO_ERR_MAX         = -701,
+
+  /** The tile is not registered with the IPP. */
+  NETIO_NOT_REGISTERED  = -701,
+
+  /** No packet was available to retrieve from the input queue. */
+  NETIO_NOPKT           = -702,
+
+  /** The requested function is not implemented. */
+  NETIO_NOT_IMPLEMENTED = -703,
+
+  /** On a registration operation, the target queue already has the maximum
+   *  number of tiles registered for it, and no more may be added.  On a
+   *  packet send operation, the output queue is full and nothing more can
+   *  be queued until some of the queued packets are actually transmitted. */
+  NETIO_QUEUE_FULL      = -704,
+
+  /** The calling process or thread is not bound to exactly one CPU. */
+  NETIO_BAD_AFFINITY    = -705,
+
+  /** Cannot allocate memory on requested controllers. */
+  NETIO_CANNOT_HOME     = -706,
+
+  /** On a registration operation, the IPP specified is not configured
+   *  to support the options requested; for instance, the application
+   *  wants a specific type of tagged headers which the configured IPP
+   *  doesn't support.  Or, the supplied configuration information is
+   *  not self-consistent, or is out of range; for instance, specifying
+   *  both NETIO_RECV and NETIO_NO_RECV, or asking for more than
+   *  NETIO_MAX_SEND_BUFFERS to be preallocated.  On a VLAN or bucket
+   *  configure operation, the number of items, or the base item, was
+   *  out of range.
+   */
+  NETIO_BAD_CONFIG      = -707,
+
+  /** Too many tiles have registered to transmit packets. */
+  NETIO_TOOMANY_XMIT    = -708,
+
+  /** Packet transmission was attempted on a queue which was registered
+      with transmit disabled. */
+  NETIO_UNREG_XMIT      = -709,
+
+  /** This tile is already registered with the IPP. */
+  NETIO_ALREADY_REGISTERED = -710,
+
+  /** The Ethernet link is down. The application should try again later. */
+  NETIO_LINK_DOWN       = -711,
+
+  /** An invalid memory buffer has been specified.  This may be an unmapped
+   * virtual address, or one which does not meet alignment requirements.
+   * For netio_input_register(), this error may be returned when multiple
+   * processes specify different memory regions to be used for NetIO
+   * buffers.  That can happen if these processes specify explicit memory
+   * regions with the ::NETIO_FIXED_BUFFER_VA flag, or if tmc_cmem_init()
+   * has not been called by a common ancestor of the processes.
+   */
+  NETIO_FAULT           = -712,
+
+  /** Cannot combine user-managed shared memory and cache coherence. */
+  NETIO_BAD_CACHE_CONFIG = -713,
+
+  /** Smallest NetIO error number. */
+  NETIO_ERR_MIN         = -713,
+
+#ifndef __DOXYGEN__
+  /** Used internally to mean that no response is needed; never returned to
+   *  an application. */
+  NETIO_NO_RESPONSE     = 1
+#endif
+} netio_error_t;
+
+/** @} */
+
+#endif /* __NETIO_ERRORS_H__ */
diff --git a/arch/tile/include/hv/netio_intf.h b/arch/tile/include/hv/netio_intf.h
new file mode 100644
index 0000000..8d20972
--- /dev/null
+++ b/arch/tile/include/hv/netio_intf.h
@@ -0,0 +1,2975 @@
+/*
+ * Copyright 2010 Tilera Corporation. All Rights Reserved.
+ *
+ *   This program is free software; you can redistribute it and/or
+ *   modify it under the terms of the GNU General Public License
+ *   as published by the Free Software Foundation, version 2.
+ *
+ *   This program is distributed in the hope that it will be useful, but
+ *   WITHOUT ANY WARRANTY; without even the implied warranty of
+ *   MERCHANTABILITY OR FITNESS FOR A PARTICULAR PURPOSE, GOOD TITLE or
+ *   NON INFRINGEMENT.  See the GNU General Public License for
+ *   more details.
+ */
+
+/**
+ * NetIO interface structures and macros.
+ */
+
+#ifndef __NETIO_INTF_H__
+#define __NETIO_INTF_H__
+
+#include <hv/netio_errors.h>
+
+#ifdef __KERNEL__
+#include <linux/types.h>
+#else
+#include <stdint.h>
+#endif
+
+#if !defined(__HV__) && !defined(__BOGUX__) && !defined(__KERNEL__)
+#include <assert.h>
+#define netio_assert assert  /**< Enable assertions from macros */
+#else
+#define netio_assert(...) ((void)(0))  /**< Disable assertions from macros */
+#endif
+
+/*
+ * If none of these symbols are defined, we're building libnetio in an
+ * environment where we have pthreads, so we'll enable locking.
+ */
+#if !defined(__HV__) && !defined(__BOGUX__) && !defined(__KERNEL__) && \
+    !defined(__NEWLIB__)
+#define _NETIO_PTHREAD       /**< Include a mutex in netio_queue_t below */
+
+/*
+ * If NETIO_UNLOCKED is defined, we don't do use per-cpu locks on
+ * per-packet NetIO operations.  We still do pthread locking on things
+ * like netio_input_register, though.  This is used for building
+ * libnetio_unlocked.
+ */
+#ifndef NETIO_UNLOCKED
+
+/* Avoid PLT overhead by using our own inlined per-cpu lock. */
+#include <sched.h>
+typedef int _netio_percpu_mutex_t;
+
+static __inline int
+_netio_percpu_mutex_init(_netio_percpu_mutex_t* lock)
+{
+  *lock = 0;
+  return 0;
+}
+
+static __inline int
+_netio_percpu_mutex_lock(_netio_percpu_mutex_t* lock)
+{
+  while (__builtin_expect(__insn_tns(lock), 0))
+    sched_yield();
+  return 0;
+}
+
+static __inline int
+_netio_percpu_mutex_unlock(_netio_percpu_mutex_t* lock)
+{
+  *lock = 0;
+  return 0;
+}
+
+#else /* NETIO_UNLOCKED */
+
+/* Don't do any locking for per-packet NetIO operations. */
+typedef int _netio_percpu_mutex_t;
+#define _netio_percpu_mutex_init(L)
+#define _netio_percpu_mutex_lock(L)
+#define _netio_percpu_mutex_unlock(L)
+
+#endif /* NETIO_UNLOCKED */
+#endif /* !__HV__, !__BOGUX, !__KERNEL__, !__NEWLIB__ */
+
+/** How many tiles can register for a given queue.
+ *  @ingroup setup */
+#define NETIO_MAX_TILES_PER_QUEUE  64
+
+
+/** Largest permissible queue identifier.
+ *  @ingroup setup  */
+#define NETIO_MAX_QUEUE_ID        255
+
+
+#ifndef __DOXYGEN__
+
+/* Metadata packet checksum/ethertype flags. */
+
+/** The L4 checksum has not been calculated. */
+#define _NETIO_PKT_NO_L4_CSUM_SHIFT           0
+#define _NETIO_PKT_NO_L4_CSUM_RMASK           1
+#define _NETIO_PKT_NO_L4_CSUM_MASK \
+         (_NETIO_PKT_NO_L4_CSUM_RMASK << _NETIO_PKT_NO_L4_CSUM_SHIFT)
+
+/** The L3 checksum has not been calculated. */
+#define _NETIO_PKT_NO_L3_CSUM_SHIFT           1
+#define _NETIO_PKT_NO_L3_CSUM_RMASK           1
+#define _NETIO_PKT_NO_L3_CSUM_MASK \
+         (_NETIO_PKT_NO_L3_CSUM_RMASK << _NETIO_PKT_NO_L3_CSUM_SHIFT)
+
+/** The L3 checksum is incorrect (or perhaps has not been calculated). */
+#define _NETIO_PKT_BAD_L3_CSUM_SHIFT          2
+#define _NETIO_PKT_BAD_L3_CSUM_RMASK          1
+#define _NETIO_PKT_BAD_L3_CSUM_MASK \
+         (_NETIO_PKT_BAD_L3_CSUM_RMASK << _NETIO_PKT_BAD_L3_CSUM_SHIFT)
+
+/** The Ethernet packet type is unrecognized. */
+#define _NETIO_PKT_TYPE_UNRECOGNIZED_SHIFT    3
+#define _NETIO_PKT_TYPE_UNRECOGNIZED_RMASK    1
+#define _NETIO_PKT_TYPE_UNRECOGNIZED_MASK \
+         (_NETIO_PKT_TYPE_UNRECOGNIZED_RMASK << \
+          _NETIO_PKT_TYPE_UNRECOGNIZED_SHIFT)
+
+/* Metadata packet type flags. */
+
+/** Where the packet type bits are; this field is the index into
+ *  _netio_pkt_info. */
+#define _NETIO_PKT_TYPE_SHIFT        4
+#define _NETIO_PKT_TYPE_RMASK        0x3F
+
+/** How many VLAN tags the packet has, and, if we have two, which one we
+ *  actually grouped on.  A VLAN within a proprietary (Marvell or Broadcom)
+ *  tag is counted here. */
+#define _NETIO_PKT_VLAN_SHIFT        4
+#define _NETIO_PKT_VLAN_RMASK        0x3
+#define _NETIO_PKT_VLAN_MASK \
+         (_NETIO_PKT_VLAN_RMASK << _NETIO_PKT_VLAN_SHIFT)
+#define _NETIO_PKT_VLAN_NONE         0   /* No VLAN tag. */
+#define _NETIO_PKT_VLAN_ONE          1   /* One VLAN tag. */
+#define _NETIO_PKT_VLAN_TWO_OUTER    2   /* Two VLAN tags, outer one used. */
+#define _NETIO_PKT_VLAN_TWO_INNER    3   /* Two VLAN tags, inner one used. */
+
+/** Which proprietary tags the packet has. */
+#define _NETIO_PKT_TAG_SHIFT         6
+#define _NETIO_PKT_TAG_RMASK         0x3
+#define _NETIO_PKT_TAG_MASK \
+          (_NETIO_PKT_TAG_RMASK << _NETIO_PKT_TAG_SHIFT)
+#define _NETIO_PKT_TAG_NONE          0   /* No proprietary tags. */
+#define _NETIO_PKT_TAG_MRVL          1   /* Marvell HyperG.Stack tags. */
+#define _NETIO_PKT_TAG_MRVL_EXT      2   /* HyperG.Stack extended tags. */
+#define _NETIO_PKT_TAG_BRCM          3   /* Broadcom HiGig tags. */
+
+/** Whether a packet has an LLC + SNAP header. */
+#define _NETIO_PKT_SNAP_SHIFT        8
+#define _NETIO_PKT_SNAP_RMASK        0x1
+#define _NETIO_PKT_SNAP_MASK \
+          (_NETIO_PKT_SNAP_RMASK << _NETIO_PKT_SNAP_SHIFT)
+
+/* NOTE: Bits 9 and 10 are unused. */
+
+/** Length of any custom data before the L2 header, in words. */
+#define _NETIO_PKT_CUSTOM_LEN_SHIFT  11
+#define _NETIO_PKT_CUSTOM_LEN_RMASK  0x1F
+#define _NETIO_PKT_CUSTOM_LEN_MASK \
+          (_NETIO_PKT_CUSTOM_LEN_RMASK << _NETIO_PKT_CUSTOM_LEN_SHIFT)
+
+/** The L4 checksum is incorrect (or perhaps has not been calculated). */
+#define _NETIO_PKT_BAD_L4_CSUM_SHIFT 16
+#define _NETIO_PKT_BAD_L4_CSUM_RMASK 0x1
+#define _NETIO_PKT_BAD_L4_CSUM_MASK \
+          (_NETIO_PKT_BAD_L4_CSUM_RMASK << _NETIO_PKT_BAD_L4_CSUM_SHIFT)
+
+/** Length of the L2 header, in words. */
+#define _NETIO_PKT_L2_LEN_SHIFT  17
+#define _NETIO_PKT_L2_LEN_RMASK  0x1F
+#define _NETIO_PKT_L2_LEN_MASK \
+          (_NETIO_PKT_L2_LEN_RMASK << _NETIO_PKT_L2_LEN_SHIFT)
+
+
+/* Flags in minimal packet metadata. */
+
+/** We need an eDMA checksum on this packet. */
+#define _NETIO_PKT_NEED_EDMA_CSUM_SHIFT            0
+#define _NETIO_PKT_NEED_EDMA_CSUM_RMASK            1
+#define _NETIO_PKT_NEED_EDMA_CSUM_MASK \
+         (_NETIO_PKT_NEED_EDMA_CSUM_RMASK << _NETIO_PKT_NEED_EDMA_CSUM_SHIFT)
+
+/* Data within the packet information table. */
+
+/* Note that, for efficiency, code which uses these fields assumes that none
+ * of the shift values below are zero.  See uses below for an explanation. */
+
+/** Offset within the L2 header of the innermost ethertype (in halfwords). */
+#define _NETIO_PKT_INFO_ETYPE_SHIFT       6
+#define _NETIO_PKT_INFO_ETYPE_RMASK    0x1F
+
+/** Offset within the L2 header of the VLAN tag (in halfwords). */
+#define _NETIO_PKT_INFO_VLAN_SHIFT       11
+#define _NETIO_PKT_INFO_VLAN_RMASK     0x1F
+
+#endif
+
+
+/** The size of a memory buffer representing a small packet.
+ *  @ingroup egress */
+#define SMALL_PACKET_SIZE 256
+
+/** The size of a memory buffer representing a large packet.
+ *  @ingroup egress */
+#define LARGE_PACKET_SIZE 2048
+
+/** The size of a memory buffer representing a jumbo packet.
+ *  @ingroup egress */
+#define JUMBO_PACKET_SIZE (12 * 1024)
+
+
+/* Common ethertypes.
+ * @ingroup ingress */
+/** @{ */
+/** The ethertype of IPv4. */
+#define ETHERTYPE_IPv4 (0x0800)
+/** The ethertype of ARP. */
+#define ETHERTYPE_ARP (0x0806)
+/** The ethertype of VLANs. */
+#define ETHERTYPE_VLAN (0x8100)
+/** The ethertype of a Q-in-Q header. */
+#define ETHERTYPE_Q_IN_Q (0x9100)
+/** The ethertype of IPv6. */
+#define ETHERTYPE_IPv6 (0x86DD)
+/** The ethertype of MPLS. */
+#define ETHERTYPE_MPLS (0x8847)
+/** @} */
+
+
+/** The possible return values of NETIO_PKT_STATUS.
+ * @ingroup ingress
+ */
+typedef enum
+{
+  /** No problems were detected with this packet. */
+  NETIO_PKT_STATUS_OK,
+  /** The packet is undersized; this is expected behavior if the packet's
+    * ethertype is unrecognized, but otherwise the packet is likely corrupt. */
+  NETIO_PKT_STATUS_UNDERSIZE,
+  /** The packet is oversized and some trailing bytes have been discarded.
+      This is expected behavior for short packets, since it's impossible to
+      precisely determine the amount of padding which may have been added to
+      them to make them meet the minimum Ethernet packet size. */
+  NETIO_PKT_STATUS_OVERSIZE,
+  /** The packet was judged to be corrupt by hardware (for instance, it had
+      a bad CRC, or part of it was discarded due to lack of buffer space in
+      the I/O shim) and should be discarded. */
+  NETIO_PKT_STATUS_BAD
+} netio_pkt_status_t;
+
+
+/** Log2 of how many buckets we have. */
+#define NETIO_LOG2_NUM_BUCKETS (10)
+
+/** How many buckets we have.
+ * @ingroup ingress */
+#define NETIO_NUM_BUCKETS (1 << NETIO_LOG2_NUM_BUCKETS)
+
+
+/**
+ * @brief A group-to-bucket identifier.
+ *
+ * @ingroup setup
+ *
+ * This tells us what to do with a given group.
+ */
+typedef union {
+  /** The header broken down into bits. */
+  struct {
+    /** Whether we should balance on L4, if available */
+    unsigned int __balance_on_l4:1;
+    /** Whether we should balance on L3, if available */
+    unsigned int __balance_on_l3:1;
+    /** Whether we should balance on L2, if available */
+    unsigned int __balance_on_l2:1;
+    /** Reserved for future use */
+    unsigned int __reserved:1;
+    /** The base bucket to use to send traffic */
+    unsigned int __bucket_base:NETIO_LOG2_NUM_BUCKETS;
+    /** The mask to apply to the balancing value. This must be one less
+     * than a power of two, e.g. 0x3 or 0xFF.
+     */
+    unsigned int __bucket_mask:NETIO_LOG2_NUM_BUCKETS;
+    /** Pad to 32 bits */
+    unsigned int __padding:(32 - 4 - 2 * NETIO_LOG2_NUM_BUCKETS);
+  } bits;
+  /** To send out the IDN. */
+  unsigned int word;
+}
+netio_group_t;
+
+
+/**
+ * @brief A VLAN-to-bucket identifier.
+ *
+ * @ingroup setup
+ *
+ * This tells us what to do with a given VLAN.
+ */
+typedef netio_group_t netio_vlan_t;
+
+
+/**
+ * A bucket-to-queue mapping.
+ * @ingroup setup
+ */
+typedef unsigned char netio_bucket_t;
+
+
+/**
+ * A packet size can always fit in a netio_size_t.
+ * @ingroup setup
+ */
+typedef unsigned int netio_size_t;
+
+
+/**
+ * @brief Ethernet standard (ingress) packet metadata.
+ *
+ * @ingroup ingress
+ *
+ * This is additional data associated with each packet.
+ * This structure is opaque and accessed through the @ref ingress.
+ *
+ * Also, the buffer population operation currently assumes that standard
+ * metadata is at least as large as minimal metadata, and will need to be
+ * modified if that is no longer the case.
+ */
+typedef struct
+{
+#ifdef __DOXYGEN__
+  /** This structure is opaque. */
+  unsigned char opaque[24];
+#else
+  /** The overall ordinal of the packet */
+  unsigned int __packet_ordinal;
+  /** The ordinal of the packet within the group */
+  unsigned int __group_ordinal;
+  /** The best flow hash IPP could compute. */
+  unsigned int __flow_hash;
+  /** Flags pertaining to checksum calculation, packet type, etc. */
+  unsigned int __flags;
+  /** The first word of "user data". */
+  unsigned int __user_data_0;
+  /** The second word of "user data". */
+  unsigned int __user_data_1;
+#endif
+}
+netio_pkt_metadata_t;
+
+
+/** To ensure that the L3 header is aligned mod 4, the L2 header should be
+ * aligned mod 4 plus 2, since every supported L2 header is 4n + 2 bytes
+ * long.  The standard way to do this is to simply add 2 bytes of padding
+ * before the L2 header.
+ */
+#define NETIO_PACKET_PADDING 2
+
+
+
+/**
+ * @brief Ethernet minimal (egress) packet metadata.
+ *
+ * @ingroup egress
+ *
+ * This structure represents information about packets which have
+ * been processed by @ref netio_populate_buffer() or
+ * @ref netio_populate_prepend_buffer().  This structure is opaque
+ * and accessed through the @ref egress.
+ *
+ * @internal This structure is actually copied into the memory used by
+ * standard metadata, which is assumed to be large enough.
+ */
+typedef struct
+{
+#ifdef __DOXYGEN__
+  /** This structure is opaque. */
+  unsigned char opaque[14];
+#else
+  /** The offset of the L2 header from the start of the packet data. */
+  unsigned short l2_offset;
+  /** The offset of the L3 header from the start of the packet data. */
+  unsigned short l3_offset;
+  /** Where to write the checksum. */
+  unsigned char csum_location;
+  /** Where to start checksumming from. */
+  unsigned char csum_start;
+  /** Flags pertaining to checksum calculation etc. */
+  unsigned short flags;
+  /** The L2 length of the packet. */
+  unsigned short l2_length;
+  /** The checksum with which to seed the checksum generator. */
+  unsigned short csum_seed;
+  /** How much to checksum. */
+  unsigned short csum_length;
+#endif
+}
+netio_pkt_minimal_metadata_t;
+
+
+#ifndef __DOXYGEN__
+
+/**
+ * @brief An I/O notification header.
+ *
+ * This is the first word of data received from an I/O shim in a notification
+ * packet. It contains framing and status information.
+ */
+typedef union
+{
+  unsigned int word; /**< The whole word. */
+  /** The various fields. */
+  struct
+  {
+    unsigned int __channel:7;    /**< Resource channel. */
+    unsigned int __type:4;       /**< Type. */
+    unsigned int __ack:1;        /**< Whether an acknowledgement is needed. */
+    unsigned int __reserved:1;   /**< Reserved. */
+    unsigned int __protocol:1;   /**< A protocol-specific word is added. */
+    unsigned int __status:2;     /**< Status of the transfer. */
+    unsigned int __framing:2;    /**< Framing of the transfer. */
+    unsigned int __transfer_size:14; /**< Transfer size in bytes (total). */
+  } bits;
+}
+__netio_pkt_notif_t;
+
+
+/**
+ * Returns the base address of the packet.
+ */
+#define _NETIO_PKT_HANDLE_BASE(p) \
+  ((unsigned char*)((p).word & 0xFFFFFFC0))
+
+/**
+ * Returns the base address of the packet.
+ */
+#define _NETIO_PKT_BASE(p) \
+  _NETIO_PKT_HANDLE_BASE(p->__packet)
+
+/**
+ * @brief An I/O notification packet (second word)
+ *
+ * This is the second word of data received from an I/O shim in a notification
+ * packet.  This is the virtual address of the packet buffer, plus some flag
+ * bits.  (The virtual address of the packet is always 256-byte aligned so we
+ * have room for 8 bits' worth of flags in the low 8 bits.)
+ *
+ * @internal
+ * NOTE: The low two bits must contain "__queue", so the "packet size"
+ * (SIZE_SMALL, SIZE_LARGE, or SIZE_JUMBO) can be determined quickly.
+ *
+ * If __addr or __offset are moved, _NETIO_PKT_BASE
+ * (defined right below this) must be changed.
+ */
+typedef union
+{
+  unsigned int word; /**< The whole word. */
+  /** The various fields. */
+  struct
+  {
+    /** Which queue the packet will be returned to once it is sent back to
+        the IPP.  This is one of the SIZE_xxx values. */
+    unsigned int __queue:2;
+
+    /** The IPP handle of the sending IPP. */
+    unsigned int __ipp_handle:2;
+
+    /** Reserved for future use. */
+    unsigned int __reserved:1;
+
+    /** If 1, this packet has minimal (egress) metadata; otherwise, it
+        has standard (ingress) metadata. */
+    unsigned int __minimal:1;
+
+    /** Offset of the metadata within the packet.  This value is multiplied
+     *  by 64 and added to the base packet address to get the metadata
+     *  address.  Note that this field is aligned within the word such that
+     *  you can easily extract the metadata address with a 26-bit mask. */
+    unsigned int __offset:2;
+
+    /** The top 24 bits of the packet's virtual address. */
+    unsigned int __addr:24;
+  } bits;
+}
+__netio_pkt_handle_t;
+
+#endif /* !__DOXYGEN__ */
+
+
+/**
+ * @brief A handle for an I/O packet's storage.
+ * @ingroup ingress
+ *
+ * netio_pkt_handle_t encodes the concept of a ::netio_pkt_t with its
+ * packet metadata removed.  It is a much smaller type that exists to
+ * facilitate applications where the full ::netio_pkt_t type is too
+ * large, such as those that cache enormous numbers of packets or wish
+ * to transmit packet descriptors over the UDN.
+ *
+ * Because there is no metadata, most ::netio_pkt_t operations cannot be
+ * performed on a netio_pkt_handle_t.  It supports only
+ * netio_free_handle() (to free the buffer) and
+ * NETIO_PKT_CUSTOM_DATA_H() (to access a pointer to its contents).
+ * The application must acquire any additional metadata it wants from the
+ * original ::netio_pkt_t and record it separately.
+ *
+ * A netio_pkt_handle_t can be extracted from a ::netio_pkt_t by calling
+ * NETIO_PKT_HANDLE().  An invalid handle (analogous to NULL) can be
+ * created by assigning the value ::NETIO_PKT_HANDLE_NONE. A handle can
+ * be tested for validity with NETIO_PKT_HANDLE_IS_VALID().
+ */
+typedef struct
+{
+  unsigned int word; /**< Opaque bits. */
+} netio_pkt_handle_t;
+
+/**
+ * @brief A packet descriptor.
+ *
+ * @ingroup ingress
+ * @ingroup egress
+ *
+ * This data structure represents a packet.  The structure is manipulated
+ * through the @ref ingress and the @ref egress.
+ *
+ * While the contents of a netio_pkt_t are opaque, the structure itself is
+ * portable.  This means that it may be shared between all tiles which have
+ * done a netio_input_register() call for the interface on which the pkt_t
+ * was initially received (via netio_get_packet()) or retrieved (via
+ * netio_get_buffer()).  The contents of a netio_pkt_t can be transmitted to
+ * another tile via shared memory, or via a UDN message, or by other means.
+ * The destination tile may then use the pkt_t as if it had originally been
+ * received locally; it may read or write the packet's data, read its
+ * metadata, free the packet, send the packet, transfer the netio_pkt_t to
+ * yet another tile, and so forth.
+ *
+ * Once a netio_pkt_t has been transferred to a second tile, the first tile
+ * should not reference the original copy; in particular, if more than one
+ * tile frees or sends the same netio_pkt_t, the IPP's packet free lists will
+ * become corrupted.  Note also that each tile which reads or modifies
+ * packet data must obey the memory coherency rules outlined in @ref input.
+ */
+typedef struct
+{
+#ifdef __DOXYGEN__
+  /** This structure is opaque. */
+  unsigned char opaque[32];
+#else
+  /** For an ingress packet (one with standard metadata), this is the
+   *  notification header we got from the I/O shim.  For an egress packet
+   *  (one with minimal metadata), this word is zero if the packet has not
+   *  been populated, and nonzero if it has. */
+  __netio_pkt_notif_t __notif_header;
+
+  /** Virtual address of the packet buffer, plus state flags. */
+  __netio_pkt_handle_t __packet;
+
+  /** Metadata associated with the packet. */
+  netio_pkt_metadata_t __metadata;
+#endif
+}
+netio_pkt_t;
+
+
+#ifndef __DOXYGEN__
+
+#define __NETIO_PKT_NOTIF_HEADER(pkt) ((pkt)->__notif_header)
+#define __NETIO_PKT_IPP_HANDLE(pkt) ((pkt)->__packet.bits.__ipp_handle)
+#define __NETIO_PKT_QUEUE(pkt) ((pkt)->__packet.bits.__queue)
+#define __NETIO_PKT_NOTIF_HEADER_M(mda, pkt) ((pkt)->__notif_header)
+#define __NETIO_PKT_IPP_HANDLE_M(mda, pkt) ((pkt)->__packet.bits.__ipp_handle)
+#define __NETIO_PKT_MINIMAL(pkt) ((pkt)->__packet.bits.__minimal)
+#define __NETIO_PKT_QUEUE_M(mda, pkt) ((pkt)->__packet.bits.__queue)
+#define __NETIO_PKT_FLAGS_M(mda, pkt) ((mda)->__flags)
+
+/* Packet information table, used by the attribute access functions below. */
+extern const uint16_t _netio_pkt_info[];
+
+#endif /* __DOXYGEN__ */
+
+
+#ifndef __DOXYGEN__
+/* These macros are deprecated and will disappear in a future MDE release. */
+#define NETIO_PKT_GOOD_CHECKSUM(pkt) \
+  NETIO_PKT_L4_CSUM_CORRECT(pkt)
+#define NETIO_PKT_GOOD_CHECKSUM_M(mda, pkt) \
+  NETIO_PKT_L4_CSUM_CORRECT_M(mda, pkt)
+#endif /* __DOXYGEN__ */
+
+
+/* Packet attribute access functions. */
+
+/** Return a pointer to the metadata for a packet.
+ * @ingroup ingress
+ *
+ * Calling this function once and passing the result to other retrieval
+ * functions with a "_M" suffix usually improves performance.  This
+ * function must be called on an 'ingress' packet (i.e. one retrieved
+ * by @ref netio_get_packet(), on which @ref netio_populate_buffer() or
+ * @ref netio_populate_prepend_buffer have not been called). Use of this
+ * function on an 'egress' packet will cause an assertion failure.
+ *
+ * @param[in] pkt Packet on which to operate.
+ * @return A pointer to the packet's standard metadata.
+ */
+static __inline netio_pkt_metadata_t*
+NETIO_PKT_METADATA(netio_pkt_t* pkt)
+{
+  netio_assert(!pkt->__packet.bits.__minimal);
+  return &pkt->__metadata;
+}
+
+
+/** Return a pointer to the minimal metadata for a packet.
+ * @ingroup egress
+ *
+ * Calling this function once and passing the result to other retrieval
+ * functions with a "_MM" suffix usually improves performance.  This
+ * function must be called on an 'egress' packet (i.e. one on which
+ * @ref netio_populate_buffer() or @ref netio_populate_prepend_buffer()
+ * have been called, or one retrieved by @ref netio_get_buffer()). Use of
+ * this function on an 'ingress' packet will cause an assertion failure.
+ *
+ * @param[in] pkt Packet on which to operate.
+ * @return A pointer to the packet's standard metadata.
+ */
+static __inline netio_pkt_minimal_metadata_t*
+NETIO_PKT_MINIMAL_METADATA(netio_pkt_t* pkt)
+{
+  netio_assert(pkt->__packet.bits.__minimal);
+  return (netio_pkt_minimal_metadata_t*) &pkt->__metadata;
+}
+
+
+/** Determine whether a packet has 'minimal' metadata.
+ * @ingroup pktfuncs
+ *
+ * This function will return nonzero if the packet is an 'egress'
+ * packet (i.e. one on which @ref netio_populate_buffer() or
+ * @ref netio_populate_prepend_buffer() have been called, or one
+ * retrieved by @ref netio_get_buffer()), and zero if the packet
+ * is an 'ingress' packet (i.e. one retrieved by @ref netio_get_packet(),
+ * which has not been converted into an 'egress' packet).
+ *
+ * @param[in] pkt Packet on which to operate.
+ * @return Nonzero if the packet has minimal metadata.
+ */
+static __inline unsigned int
+NETIO_PKT_IS_MINIMAL(netio_pkt_t* pkt)
+{
+  return pkt->__packet.bits.__minimal;
+}
+
+
+/** Return a handle for a packet's storage.
+ * @ingroup pktfuncs
+ *
+ * @param[in] pkt Packet on which to operate.
+ * @return A handle for the packet's storage.
+ */
+static __inline netio_pkt_handle_t
+NETIO_PKT_HANDLE(netio_pkt_t* pkt)
+{
+  netio_pkt_handle_t h;
+  h.word = pkt->__packet.word;
+  return h;
+}
+
+
+/** A special reserved value indicating the absence of a packet handle.
+ *
+ * @ingroup pktfuncs
+ */
+#define NETIO_PKT_HANDLE_NONE ((netio_pkt_handle_t) { 0 })
+
+
+/** Test whether a packet handle is valid.
+ *
+ * Applications may wish to use the reserved value NETIO_PKT_HANDLE_NONE
+ * to indicate no packet at all.  This function tests to see if a packet
+ * handle is a real handle, not this special reserved value.
+ *
+ * @ingroup pktfuncs
+ *
+ * @param[in] handle Handle on which to operate.
+ * @return One if the packet handle is valid, else zero.
+ */
+static __inline unsigned int
+NETIO_PKT_HANDLE_IS_VALID(netio_pkt_handle_t handle)
+{
+  return handle.word != 0;
+}
+
+
+
+/** Return a pointer to the start of the packet's custom header.
+ *  A custom header may or may not be present, depending upon the IPP; its
+ *  contents and alignment are also IPP-dependent.  Currently, none of the
+ *  standard IPPs supplied by Tilera produce a custom header.  If present,
+ *  the custom header precedes the L2 header in the packet buffer.
+ * @ingroup ingress
+ *
+ * @param[in] handle Handle on which to operate.
+ * @return A pointer to start of the packet.
+ */
+static __inline unsigned char*
+NETIO_PKT_CUSTOM_DATA_H(netio_pkt_handle_t handle)
+{
+  return _NETIO_PKT_HANDLE_BASE(handle) + NETIO_PACKET_PADDING;
+}
+
+
+/** Return the length of the packet's custom header.
+ *  A custom header may or may not be present, depending upon the IPP; its
+ *  contents and alignment are also IPP-dependent.  Currently, none of the
+ *  standard IPPs supplied by Tilera produce a custom header.  If present,
+ *  the custom header precedes the L2 header in the packet buffer.
+ *
+ * @ingroup ingress
+ *
+ * @param[in] mda Pointer to packet's standard metadata.
+ * @param[in] pkt Packet on which to operate.
+ * @return The length of the packet's custom header, in bytes.
+ */
+static __inline netio_size_t
+NETIO_PKT_CUSTOM_HEADER_LENGTH_M(netio_pkt_metadata_t* mda, netio_pkt_t* pkt)
+{
+  /*
+   * Note that we effectively need to extract a quantity from the flags word
+   * which is measured in words, and then turn it into bytes by shifting
+   * it left by 2.  We do this all at once by just shifting right two less
+   * bits, and shifting the mask up two bits.
+   */
+  return ((mda->__flags >> (_NETIO_PKT_CUSTOM_LEN_SHIFT - 2)) &
+          (_NETIO_PKT_CUSTOM_LEN_RMASK << 2));
+}
+
+
+/** Return the length of the packet, starting with the custom header.
+ *  A custom header may or may not be present, depending upon the IPP; its
+ *  contents and alignment are also IPP-dependent.  Currently, none of the
+ *  standard IPPs supplied by Tilera produce a custom header.  If present,
+ *  the custom header precedes the L2 header in the packet buffer.
+ * @ingroup ingress
+ *
+ * @param[in] mda Pointer to packet's standard metadata.
+ * @param[in] pkt Packet on which to operate.
+ * @return The length of the packet, in bytes.
+ */
+static __inline netio_size_t
+NETIO_PKT_CUSTOM_LENGTH_M(netio_pkt_metadata_t* mda, netio_pkt_t* pkt)
+{
+  return (__NETIO_PKT_NOTIF_HEADER(pkt).bits.__transfer_size -
+          NETIO_PACKET_PADDING);
+}
+
+
+/** Return a pointer to the start of the packet's custom header.
+ *  A custom header may or may not be present, depending upon the IPP; its
+ *  contents and alignment are also IPP-dependent.  Currently, none of the
+ *  standard IPPs supplied by Tilera produce a custom header.  If present,
+ *  the custom header precedes the L2 header in the packet buffer.
+ * @ingroup ingress
+ *
+ * @param[in] mda Pointer to packet's standard metadata.
+ * @param[in] pkt Packet on which to operate.
+ * @return A pointer to start of the packet.
+ */
+static __inline unsigned char*
+NETIO_PKT_CUSTOM_DATA_M(netio_pkt_metadata_t* mda, netio_pkt_t* pkt)
+{
+  return NETIO_PKT_CUSTOM_DATA_H(NETIO_PKT_HANDLE(pkt));
+}
+
+
+/** Return the length of the packet's L2 (Ethernet plus VLAN or SNAP) header.
+ * @ingroup ingress
+ *
+ * @param[in] mda Pointer to packet's standard metadata.
+ * @param[in] pkt Packet on which to operate.
+ * @return The length of the packet's L2 header, in bytes.
+ */
+static __inline netio_size_t
+NETIO_PKT_L2_HEADER_LENGTH_M(netio_pkt_metadata_t* mda, netio_pkt_t* pkt)
+{
+  /*
+   * Note that we effectively need to extract a quantity from the flags word
+   * which is measured in words, and then turn it into bytes by shifting
+   * it left by 2.  We do this all at once by just shifting right two less
+   * bits, and shifting the mask up two bits.  We then add two bytes.
+   */
+  return ((mda->__flags >> (_NETIO_PKT_L2_LEN_SHIFT - 2)) &
+          (_NETIO_PKT_L2_LEN_RMASK << 2)) + 2;
+}
+
+
+/** Return the length of the packet, starting with the L2 (Ethernet) header.
+ * @ingroup ingress
+ *
+ * @param[in] mda Pointer to packet's standard metadata.
+ * @param[in] pkt Packet on which to operate.
+ * @return The length of the packet, in bytes.
+ */
+static __inline netio_size_t
+NETIO_PKT_L2_LENGTH_M(netio_pkt_metadata_t* mda, netio_pkt_t* pkt)
+{
+  return (NETIO_PKT_CUSTOM_LENGTH_M(mda, pkt) -
+          NETIO_PKT_CUSTOM_HEADER_LENGTH_M(mda,pkt));
+}
+
+
+/** Return a pointer to the start of the packet's L2 (Ethernet) header.
+ * @ingroup ingress
+ *
+ * @param[in] mda Pointer to packet's standard metadata.
+ * @param[in] pkt Packet on which to operate.
+ * @return A pointer to start of the packet.
+ */
+static __inline unsigned char*
+NETIO_PKT_L2_DATA_M(netio_pkt_metadata_t* mda, netio_pkt_t* pkt)
+{
+  return (NETIO_PKT_CUSTOM_DATA_M(mda, pkt) +
+          NETIO_PKT_CUSTOM_HEADER_LENGTH_M(mda, pkt));
+}
+
+
+/** Retrieve the length of the packet, starting with the L3 (generally,
+ *  the IP) header.
+ * @ingroup ingress
+ *
+ * @param[in] mda Pointer to packet's standard metadata.
+ * @param[in] pkt Packet on which to operate.
+ * @return Length of the packet's L3 header and data, in bytes.
+ */
+static __inline netio_size_t
+NETIO_PKT_L3_LENGTH_M(netio_pkt_metadata_t* mda, netio_pkt_t* pkt)
+{
+  return (NETIO_PKT_L2_LENGTH_M(mda, pkt) -
+          NETIO_PKT_L2_HEADER_LENGTH_M(mda,pkt));
+}
+
+
+/** Return a pointer to the packet's L3 (generally, the IP) header.
+ * @ingroup ingress
+ *
+ * Note that we guarantee word alignment of the L3 header.
+ *
+ * @param[in] mda Pointer to packet's standard metadata.
+ * @param[in] pkt Packet on which to operate.
+ * @return A pointer to the packet's L3 header.
+ */
+static __inline unsigned char*
+NETIO_PKT_L3_DATA_M(netio_pkt_metadata_t* mda, netio_pkt_t* pkt)
+{
+  return (NETIO_PKT_L2_DATA_M(mda, pkt) +
+          NETIO_PKT_L2_HEADER_LENGTH_M(mda, pkt));
+}
+
+
+/** Return the ordinal of the packet.
+ * @ingroup ingress
+ *
+ * Each packet is given an ordinal number when it is delivered by the IPP.
+ * In the medium term, the ordinal is unique and monotonically increasing,
+ * being incremented by 1 for each packet; the ordinal of the first packet
+ * delivered after the IPP starts is zero.  (Since the ordinal is of finite
+ * size, given enough input packets, it will eventually wrap around to zero;
+ * in the long term, therefore, ordinals are not unique.)  The ordinals
+ * handed out by different IPPs are not disjoint, so two packets from
+ * different IPPs may have identical ordinals.  Packets dropped by the
+ * IPP or by the I/O shim are not assigned ordinals.
+ *
+ * @param[in] mda Pointer to packet's standard metadata.
+ * @param[in] pkt Packet on which to operate.
+ * @return The packet's per-IPP packet ordinal.
+ */
+static __inline unsigned int
+NETIO_PKT_ORDINAL_M(netio_pkt_metadata_t* mda, netio_pkt_t* pkt)
+{
+  return mda->__packet_ordinal;
+}
+
+
+/** Return the per-group ordinal of the packet.
+ * @ingroup ingress
+ *
+ * Each packet is given a per-group ordinal number when it is
+ * delivered by the IPP. By default, the group is the packet's VLAN,
+ * although IPP can be recompiled to use different values.  In
+ * the medium term, the ordinal is unique and monotonically
+ * increasing, being incremented by 1 for each packet; the ordinal of
+ * the first packet distributed to a particular group is zero.
+ * (Since the ordinal is of finite size, given enough input packets,
+ * it will eventually wrap around to zero; in the long term,
+ * therefore, ordinals are not unique.)  The ordinals handed out by
+ * different IPPs are not disjoint, so two packets from different IPPs
+ * may have identical ordinals; similarly, packets distributed to
+ * different groups may have identical ordinals.  Packets dropped by
+ * the IPP or by the I/O shim are not assigned ordinals.
+ *
+ * @param[in] mda Pointer to packet's standard metadata.
+ * @param[in] pkt Packet on which to operate.
+ * @return The packet's per-IPP, per-group ordinal.
+ */
+static __inline unsigned int
+NETIO_PKT_GROUP_ORDINAL_M(netio_pkt_metadata_t* mda, netio_pkt_t* pkt)
+{
+  return mda->__group_ordinal;
+}
+
+
+/** Return the VLAN ID assigned to the packet.
+ * @ingroup ingress
+ *
+ * This value is usually contained within the packet header.
+ *
+ * This value will be zero if the packet does not have a VLAN tag, or if
+ * this value was not extracted from the packet.
+ *
+ * @param[in] mda Pointer to packet's standard metadata.
+ * @param[in] pkt Packet on which to operate.
+ * @return The packet's VLAN ID.
+ */
+static __inline unsigned short
+NETIO_PKT_VLAN_ID_M(netio_pkt_metadata_t* mda, netio_pkt_t* pkt)
+{
+  int vl = (mda->__flags >> _NETIO_PKT_VLAN_SHIFT) & _NETIO_PKT_VLAN_RMASK;
+  unsigned short* pkt_p;
+  int index;
+  unsigned short val;
+
+  if (vl == _NETIO_PKT_VLAN_NONE)
+    return 0;
+
+  pkt_p = (unsigned short*) NETIO_PKT_L2_DATA_M(mda, pkt);
+  index = (mda->__flags >> _NETIO_PKT_TYPE_SHIFT) & _NETIO_PKT_TYPE_RMASK;
+
+  val = pkt_p[(_netio_pkt_info[index] >> _NETIO_PKT_INFO_VLAN_SHIFT) &
+              _NETIO_PKT_INFO_VLAN_RMASK];
+
+#ifdef __TILECC__
+  return (__insn_bytex(val) >> 16) & 0xFFF;
+#else
+  return (__builtin_bswap32(val) >> 16) & 0xFFF;
+#endif
+}
+
+
+/** Return the ethertype of the packet.
+ * @ingroup ingress
+ *
+ * This value is usually contained within the packet header.
+ *
+ * This value is reliable if @ref NETIO_PKT_ETHERTYPE_RECOGNIZED_M()
+ * returns true, and otherwise, may not be well defined.
+ *
+ * @param[in] mda Pointer to packet's standard metadata.
+ * @param[in] pkt Packet on which to operate.
+ * @return The packet's ethertype.
+ */
+static __inline unsigned short
+NETIO_PKT_ETHERTYPE_M(netio_pkt_metadata_t* mda, netio_pkt_t* pkt)
+{
+  unsigned short* pkt_p = (unsigned short*) NETIO_PKT_L2_DATA_M(mda, pkt);
+  int index = (mda->__flags >> _NETIO_PKT_TYPE_SHIFT) & _NETIO_PKT_TYPE_RMASK;
+
+  unsigned short val =
+    pkt_p[(_netio_pkt_info[index] >> _NETIO_PKT_INFO_ETYPE_SHIFT) &
+          _NETIO_PKT_INFO_ETYPE_RMASK];
+
+  return __builtin_bswap32(val) >> 16;
+}
+
+
+/** Return the flow hash computed on the packet.
+ * @ingroup ingress
+ *
+ * For TCP and UDP packets, this hash is calculated by hashing together
+ * the "5-tuple" values, specifically the source IP address, destination
+ * IP address, protocol type, source port and destination port.
+ * The hash value is intended to be helpful for millions of distinct
+ * flows.
+ *
+ * For IPv4 or IPv6 packets which are neither TCP nor UDP, the flow hash is
+ * derived by hashing together the source and destination IP addresses.
+ *
+ * For MPLS-encapsulated packets, the flow hash is derived by hashing
+ * the first MPLS label.
+ *
+ * For all other packets the flow hash is computed from the source
+ * and destination Ethernet addresses.
+ *
+ * The hash is symmetric, meaning it produces the same value if the
+ * source and destination are swapped. The only exceptions are
+ * tunneling protocols 0x04 (IP in IP Encapsulation), 0x29 (Simple
+ * Internet Protocol), 0x2F (General Routing Encapsulation) and 0x32
+ * (Encap Security Payload), which use only the destination address
+ * since the source address is not meaningful.
+ *
+ * @param[in] mda Pointer to packet's standard metadata.
+ * @param[in] pkt Packet on which to operate.
+ * @return The packet's 32-bit flow hash.
+ */
+static __inline unsigned int
+NETIO_PKT_FLOW_HASH_M(netio_pkt_metadata_t* mda, netio_pkt_t* pkt)
+{
+  return mda->__flow_hash;
+}
+
+
+/** Return the first word of "user data" for the packet.
+ *
+ * The contents of the user data words depend on the IPP.
+ *
+ * When using the standard ipp1, ipp2, or ipp4 sub-drivers, the first
+ * word of user data contains the least significant bits of the 64-bit
+ * arrival cycle count (see @c get_cycle_count_low()).
+ *
+ * See the <em>System Programmer's Guide</em> for details.
+ *
+ * @ingroup ingress
+ *
+ * @param[in] mda Pointer to packet's standard metadata.
+ * @param[in] pkt Packet on which to operate.
+ * @return The packet's first word of "user data".
+ */
+static __inline unsigned int
+NETIO_PKT_USER_DATA_0_M(netio_pkt_metadata_t* mda, netio_pkt_t* pkt)
+{
+  return mda->__user_data_0;
+}
+
+
+/** Return the second word of "user data" for the packet.
+ *
+ * The contents of the user data words depend on the IPP.
+ *
+ * When using the standard ipp1, ipp2, or ipp4 sub-drivers, the second
+ * word of user data contains the most significant bits of the 64-bit
+ * arrival cycle count (see @c get_cycle_count_high()).
+ *
+ * See the <em>System Programmer's Guide</em> for details.
+ *
+ * @ingroup ingress
+ *
+ * @param[in] mda Pointer to packet's standard metadata.
+ * @param[in] pkt Packet on which to operate.
+ * @return The packet's second word of "user data".
+ */
+static __inline unsigned int
+NETIO_PKT_USER_DATA_1_M(netio_pkt_metadata_t* mda, netio_pkt_t* pkt)
+{
+  return mda->__user_data_1;
+}
+
+
+/** Determine whether the L4 (TCP/UDP) checksum was calculated.
+ * @ingroup ingress
+ *
+ * @param[in] mda Pointer to packet's standard metadata.
+ * @param[in] pkt Packet on which to operate.
+ * @return Nonzero if the L4 checksum was calculated.
+ */
+static __inline unsigned int
+NETIO_PKT_L4_CSUM_CALCULATED_M(netio_pkt_metadata_t* mda, netio_pkt_t* pkt)
+{
+  return !(mda->__flags & _NETIO_PKT_NO_L4_CSUM_MASK);
+}
+
+
+/** Determine whether the L4 (TCP/UDP) checksum was calculated and found to
+ *  be correct.
+ * @ingroup ingress
+ *
+ * @param[in] mda Pointer to packet's standard metadata.
+ * @param[in] pkt Packet on which to operate.
+ * @return Nonzero if the checksum was calculated and is correct.
+ */
+static __inline unsigned int
+NETIO_PKT_L4_CSUM_CORRECT_M(netio_pkt_metadata_t* mda, netio_pkt_t* pkt)
+{
+  return !(mda->__flags &
+           (_NETIO_PKT_BAD_L4_CSUM_MASK | _NETIO_PKT_NO_L4_CSUM_MASK));
+}
+
+
+/** Determine whether the L3 (IP) checksum was calculated.
+ * @ingroup ingress
+ *
+ * @param[in] mda Pointer to packet's standard metadata.
+ * @param[in] pkt Packet on which to operate.
+ * @return Nonzero if the L3 (IP) checksum was calculated.
+*/
+static __inline unsigned int
+NETIO_PKT_L3_CSUM_CALCULATED_M(netio_pkt_metadata_t* mda, netio_pkt_t* pkt)
+{
+  return !(mda->__flags & _NETIO_PKT_NO_L3_CSUM_MASK);
+}
+
+
+/** Determine whether the L3 (IP) checksum was calculated and found to be
+ *  correct.
+ * @ingroup ingress
+ *
+ * @param[in] mda Pointer to packet's standard metadata.
+ * @param[in] pkt Packet on which to operate.
+ * @return Nonzero if the checksum was calculated and is correct.
+ */
+static __inline unsigned int
+NETIO_PKT_L3_CSUM_CORRECT_M(netio_pkt_metadata_t* mda, netio_pkt_t* pkt)
+{
+  return !(mda->__flags &
+           (_NETIO_PKT_BAD_L3_CSUM_MASK | _NETIO_PKT_NO_L3_CSUM_MASK));
+}
+
+
+/** Determine whether the ethertype was recognized and L3 packet data was
+ *  processed.
+ * @ingroup ingress
+ *
+ * @param[in] mda Pointer to packet's standard metadata.
+ * @param[in] pkt Packet on which to operate.
+ * @return Nonzero if the ethertype was recognized and L3 packet data was
+ *   processed.
+ */
+static __inline unsigned int
+NETIO_PKT_ETHERTYPE_RECOGNIZED_M(netio_pkt_metadata_t* mda, netio_pkt_t* pkt)
+{
+  return !(mda->__flags & _NETIO_PKT_TYPE_UNRECOGNIZED_MASK);
+}
+
+
+/** Retrieve the status of a packet and any errors that may have occurred
+ * during ingress processing (length mismatches, CRC errors, etc.).
+ * @ingroup ingress
+ *
+ * Note that packets for which @ref NETIO_PKT_ETHERTYPE_RECOGNIZED()
+ * returns zero are always reported as underlength, as there is no a priori
+ * means to determine their length.  Normally, applications should use
+ * @ref NETIO_PKT_BAD_M() instead of explicitly checking status with this
+ * function.
+ *
+ * @param[in] mda Pointer to packet's standard metadata.
+ * @param[in] pkt Packet on which to operate.
+ * @return The packet's status.
+ */
+static __inline netio_pkt_status_t
+NETIO_PKT_STATUS_M(netio_pkt_metadata_t* mda, netio_pkt_t* pkt)
+{
+  return (netio_pkt_status_t) __NETIO_PKT_NOTIF_HEADER(pkt).bits.__status;
+}
+
+
+/** Report whether a packet is bad (i.e., was shorter than expected based on
+ *  its headers, or had a bad CRC).
+ * @ingroup ingress
+ *
+ * Note that this function does not verify L3 or L4 checksums.
+ *
+ * @param[in] mda Pointer to packet's standard metadata.
+ * @param[in] pkt Packet on which to operate.
+ * @return Nonzero if the packet is bad and should be discarded.
+ */
+static __inline unsigned int
+NETIO_PKT_BAD_M(netio_pkt_metadata_t* mda, netio_pkt_t* pkt)
+{
+  return ((NETIO_PKT_STATUS_M(mda, pkt) & 1) &&
+          (NETIO_PKT_ETHERTYPE_RECOGNIZED_M(mda, pkt) ||
+           NETIO_PKT_STATUS_M(mda, pkt) == NETIO_PKT_STATUS_BAD));
+}
+
+
+/** Return the length of the packet, starting with the L2 (Ethernet) header.
+ * @ingroup egress
+ *
+ * @param[in] mmd Pointer to packet's minimal metadata.
+ * @param[in] pkt Packet on which to operate.
+ * @return The length of the packet, in bytes.
+ */
+static __inline netio_size_t
+NETIO_PKT_L2_LENGTH_MM(netio_pkt_minimal_metadata_t* mmd, netio_pkt_t* pkt)
+{
+  return mmd->l2_length;
+}
+
+
+/** Return the length of the L2 (Ethernet) header.
+ * @ingroup egress
+ *
+ * @param[in] mmd Pointer to packet's minimal metadata.
+ * @param[in] pkt Packet on which to operate.
+ * @return The length of the packet's L2 header, in bytes.
+ */
+static __inline netio_size_t
+NETIO_PKT_L2_HEADER_LENGTH_MM(netio_pkt_minimal_metadata_t* mmd,
+                              netio_pkt_t* pkt)
+{
+  return mmd->l3_offset - mmd->l2_offset;
+}
+
+
+/** Return the length of the packet, starting with the L3 (IP) header.
+ * @ingroup egress
+ *
+ * @param[in] mmd Pointer to packet's minimal metadata.
+ * @param[in] pkt Packet on which to operate.
+ * @return Length of the packet's L3 header and data, in bytes.
+ */
+static __inline netio_size_t
+NETIO_PKT_L3_LENGTH_MM(netio_pkt_minimal_metadata_t* mmd, netio_pkt_t* pkt)
+{
+  return (NETIO_PKT_L2_LENGTH_MM(mmd, pkt) -
+          NETIO_PKT_L2_HEADER_LENGTH_MM(mmd, pkt));
+}
+
+
+/** Return a pointer to the packet's L3 (generally, the IP) header.
+ * @ingroup egress
+ *
+ * Note that we guarantee word alignment of the L3 header.
+ *
+ * @param[in] mmd Pointer to packet's minimal metadata.
+ * @param[in] pkt Packet on which to operate.
+ * @return A pointer to the packet's L3 header.
+ */
+static __inline unsigned char*
+NETIO_PKT_L3_DATA_MM(netio_pkt_minimal_metadata_t* mmd, netio_pkt_t* pkt)
+{
+  return _NETIO_PKT_BASE(pkt) + mmd->l3_offset;
+}
+
+
+/** Return a pointer to the packet's L2 (Ethernet) header.
+ * @ingroup egress
+ *
+ * @param[in] mmd Pointer to packet's minimal metadata.
+ * @param[in] pkt Packet on which to operate.
+ * @return A pointer to start of the packet.
+ */
+static __inline unsigned char*
+NETIO_PKT_L2_DATA_MM(netio_pkt_minimal_metadata_t* mmd, netio_pkt_t* pkt)
+{
+  return _NETIO_PKT_BASE(pkt) + mmd->l2_offset;
+}
+
+
+/** Retrieve the status of a packet and any errors that may have occurred
+ * during ingress processing (length mismatches, CRC errors, etc.).
+ * @ingroup ingress
+ *
+ * Note that packets for which @ref NETIO_PKT_ETHERTYPE_RECOGNIZED()
+ * returns zero are always reported as underlength, as there is no a priori
+ * means to determine their length.  Normally, applications should use
+ * @ref NETIO_PKT_BAD() instead of explicitly checking status with this
+ * function.
+ *
+ * @param[in] pkt Packet on which to operate.
+ * @return The packet's status.
+ */
+static __inline netio_pkt_status_t
+NETIO_PKT_STATUS(netio_pkt_t* pkt)
+{
+  netio_assert(!pkt->__packet.bits.__minimal);
+
+  return (netio_pkt_status_t) __NETIO_PKT_NOTIF_HEADER(pkt).bits.__status;
+}
+
+
+/** Report whether a packet is bad (i.e., was shorter than expected based on
+ *  its headers, or had a bad CRC).
+ * @ingroup ingress
+ *
+ * Note that this function does not verify L3 or L4 checksums.
+ *
+ * @param[in] pkt Packet on which to operate.
+ * @return Nonzero if the packet is bad and should be discarded.
+ */
+static __inline unsigned int
+NETIO_PKT_BAD(netio_pkt_t* pkt)
+{
+  netio_pkt_metadata_t* mda = NETIO_PKT_METADATA(pkt);
+
+  return NETIO_PKT_BAD_M(mda, pkt);
+}
+
+
+/** Return the length of the packet's custom header.
+ *  A custom header may or may not be present, depending upon the IPP; its
+ *  contents and alignment are also IPP-dependent.  Currently, none of the
+ *  standard IPPs supplied by Tilera produce a custom header.  If present,
+ *  the custom header precedes the L2 header in the packet buffer.
+ * @ingroup pktfuncs
+ *
+ * @param[in] pkt Packet on which to operate.
+ * @return The length of the packet's custom header, in bytes.
+ */
+static __inline netio_size_t
+NETIO_PKT_CUSTOM_HEADER_LENGTH(netio_pkt_t* pkt)
+{
+  netio_pkt_metadata_t* mda = NETIO_PKT_METADATA(pkt);
+
+  return NETIO_PKT_CUSTOM_HEADER_LENGTH_M(mda, pkt);
+}
+
+
+/** Return the length of the packet, starting with the custom header.
+ *  A custom header may or may not be present, depending upon the IPP; its
+ *  contents and alignment are also IPP-dependent.  Currently, none of the
+ *  standard IPPs supplied by Tilera produce a custom header.  If present,
+ *  the custom header precedes the L2 header in the packet buffer.
+ * @ingroup pktfuncs
+ *
+ * @param[in] pkt Packet on which to operate.
+ * @return  The length of the packet, in bytes.
+ */
+static __inline netio_size_t
+NETIO_PKT_CUSTOM_LENGTH(netio_pkt_t* pkt)
+{
+  netio_pkt_metadata_t* mda = NETIO_PKT_METADATA(pkt);
+
+  return NETIO_PKT_CUSTOM_LENGTH_M(mda, pkt);
+}
+
+
+/** Return a pointer to the packet's custom header.
+ *  A custom header may or may not be present, depending upon the IPP; its
+ *  contents and alignment are also IPP-dependent.  Currently, none of the
+ *  standard IPPs supplied by Tilera produce a custom header.  If present,
+ *  the custom header precedes the L2 header in the packet buffer.
+ * @ingroup pktfuncs
+ *
+ * @param[in] pkt Packet on which to operate.
+ * @return A pointer to start of the packet.
+ */
+static __inline unsigned char*
+NETIO_PKT_CUSTOM_DATA(netio_pkt_t* pkt)
+{
+  netio_pkt_metadata_t* mda = NETIO_PKT_METADATA(pkt);
+
+  return NETIO_PKT_CUSTOM_DATA_M(mda, pkt);
+}
+
+
+/** Return the length of the packet's L2 (Ethernet plus VLAN or SNAP) header.
+ * @ingroup pktfuncs
+ *
+ * @param[in] pkt Packet on which to operate.
+ * @return The length of the packet's L2 header, in bytes.
+ */
+static __inline netio_size_t
+NETIO_PKT_L2_HEADER_LENGTH(netio_pkt_t* pkt)
+{
+  if (NETIO_PKT_IS_MINIMAL(pkt))
+  {
+    netio_pkt_minimal_metadata_t* mmd = NETIO_PKT_MINIMAL_METADATA(pkt);
+
+    return NETIO_PKT_L2_HEADER_LENGTH_MM(mmd, pkt);
+  }
+  else
+  {
+    netio_pkt_metadata_t* mda = NETIO_PKT_METADATA(pkt);
+
+    return NETIO_PKT_L2_HEADER_LENGTH_M(mda, pkt);
+  }
+}
+
+
+/** Return the length of the packet, starting with the L2 (Ethernet) header.
+ * @ingroup pktfuncs
+ *
+ * @param[in] pkt Packet on which to operate.
+ * @return  The length of the packet, in bytes.
+ */
+static __inline netio_size_t
+NETIO_PKT_L2_LENGTH(netio_pkt_t* pkt)
+{
+  if (NETIO_PKT_IS_MINIMAL(pkt))
+  {
+    netio_pkt_minimal_metadata_t* mmd = NETIO_PKT_MINIMAL_METADATA(pkt);
+
+    return NETIO_PKT_L2_LENGTH_MM(mmd, pkt);
+  }
+  else
+  {
+    netio_pkt_metadata_t* mda = NETIO_PKT_METADATA(pkt);
+
+    return NETIO_PKT_L2_LENGTH_M(mda, pkt);
+  }
+}
+
+
+/** Return a pointer to the packet's L2 (Ethernet) header.
+ * @ingroup pktfuncs
+ *
+ * @param[in] pkt Packet on which to operate.
+ * @return A pointer to start of the packet.
+ */
+static __inline unsigned char*
+NETIO_PKT_L2_DATA(netio_pkt_t* pkt)
+{
+  if (NETIO_PKT_IS_MINIMAL(pkt))
+  {
+    netio_pkt_minimal_metadata_t* mmd = NETIO_PKT_MINIMAL_METADATA(pkt);
+
+    return NETIO_PKT_L2_DATA_MM(mmd, pkt);
+  }
+  else
+  {
+    netio_pkt_metadata_t* mda = NETIO_PKT_METADATA(pkt);
+
+    return NETIO_PKT_L2_DATA_M(mda, pkt);
+  }
+}
+
+
+/** Retrieve the length of the packet, starting with the L3 (generally, the IP)
+ * header.
+ * @ingroup pktfuncs
+ *
+ * @param[in] pkt Packet on which to operate.
+ * @return Length of the packet's L3 header and data, in bytes.
+ */
+static __inline netio_size_t
+NETIO_PKT_L3_LENGTH(netio_pkt_t* pkt)
+{
+  if (NETIO_PKT_IS_MINIMAL(pkt))
+  {
+    netio_pkt_minimal_metadata_t* mmd = NETIO_PKT_MINIMAL_METADATA(pkt);
+
+    return NETIO_PKT_L3_LENGTH_MM(mmd, pkt);
+  }
+  else
+  {
+    netio_pkt_metadata_t* mda = NETIO_PKT_METADATA(pkt);
+
+    return NETIO_PKT_L3_LENGTH_M(mda, pkt);
+  }
+}
+
+
+/** Return a pointer to the packet's L3 (generally, the IP) header.
+ * @ingroup pktfuncs
+ *
+ * Note that we guarantee word alignment of the L3 header.
+ *
+ * @param[in] pkt Packet on which to operate.
+ * @return A pointer to the packet's L3 header.
+ */
+static __inline unsigned char*
+NETIO_PKT_L3_DATA(netio_pkt_t* pkt)
+{
+  if (NETIO_PKT_IS_MINIMAL(pkt))
+  {
+    netio_pkt_minimal_metadata_t* mmd = NETIO_PKT_MINIMAL_METADATA(pkt);
+
+    return NETIO_PKT_L3_DATA_MM(mmd, pkt);
+  }
+  else
+  {
+    netio_pkt_metadata_t* mda = NETIO_PKT_METADATA(pkt);
+
+    return NETIO_PKT_L3_DATA_M(mda, pkt);
+  }
+}
+
+
+/** Return the ordinal of the packet.
+ * @ingroup ingress
+ *
+ * Each packet is given an ordinal number when it is delivered by the IPP.
+ * In the medium term, the ordinal is unique and monotonically increasing,
+ * being incremented by 1 for each packet; the ordinal of the first packet
+ * delivered after the IPP starts is zero.  (Since the ordinal is of finite
+ * size, given enough input packets, it will eventually wrap around to zero;
+ * in the long term, therefore, ordinals are not unique.)  The ordinals
+ * handed out by different IPPs are not disjoint, so two packets from
+ * different IPPs may have identical ordinals.  Packets dropped by the
+ * IPP or by the I/O shim are not assigned ordinals.
+ *
+ *
+ * @param[in] pkt Packet on which to operate.
+ * @return The packet's per-IPP packet ordinal.
+ */
+static __inline unsigned int
+NETIO_PKT_ORDINAL(netio_pkt_t* pkt)
+{
+  netio_pkt_metadata_t* mda = NETIO_PKT_METADATA(pkt);
+
+  return NETIO_PKT_ORDINAL_M(mda, pkt);
+}
+
+
+/** Return the per-group ordinal of the packet.
+ * @ingroup ingress
+ *
+ * Each packet is given a per-group ordinal number when it is
+ * delivered by the IPP. By default, the group is the packet's VLAN,
+ * although IPP can be recompiled to use different values.  In
+ * the medium term, the ordinal is unique and monotonically
+ * increasing, being incremented by 1 for each packet; the ordinal of
+ * the first packet distributed to a particular group is zero.
+ * (Since the ordinal is of finite size, given enough input packets,
+ * it will eventually wrap around to zero; in the long term,
+ * therefore, ordinals are not unique.)  The ordinals handed out by
+ * different IPPs are not disjoint, so two packets from different IPPs
+ * may have identical ordinals; similarly, packets distributed to
+ * different groups may have identical ordinals.  Packets dropped by
+ * the IPP or by the I/O shim are not assigned ordinals.
+ *
+ * @param[in] pkt Packet on which to operate.
+ * @return The packet's per-IPP, per-group ordinal.
+ */
+static __inline unsigned int
+NETIO_PKT_GROUP_ORDINAL(netio_pkt_t* pkt)
+{
+  netio_pkt_metadata_t* mda = NETIO_PKT_METADATA(pkt);
+
+  return NETIO_PKT_GROUP_ORDINAL_M(mda, pkt);
+}
+
+
+/** Return the VLAN ID assigned to the packet.
+ * @ingroup ingress
+ *
+ * This is usually also contained within the packet header.  If the packet
+ * does not have a VLAN tag, the VLAN ID returned by this function is zero.
+ *
+ * @param[in] pkt Packet on which to operate.
+ * @return The packet's VLAN ID.
+ */
+static __inline unsigned short
+NETIO_PKT_VLAN_ID(netio_pkt_t* pkt)
+{
+  netio_pkt_metadata_t* mda = NETIO_PKT_METADATA(pkt);
+
+  return NETIO_PKT_VLAN_ID_M(mda, pkt);
+}
+
+
+/** Return the ethertype of the packet.
+ * @ingroup ingress
+ *
+ * This value is reliable if @ref NETIO_PKT_ETHERTYPE_RECOGNIZED()
+ * returns true, and otherwise, may not be well defined.
+ *
+ * @param[in] pkt Packet on which to operate.
+ * @return The packet's ethertype.
+ */
+static __inline unsigned short
+NETIO_PKT_ETHERTYPE(netio_pkt_t* pkt)
+{
+  netio_pkt_metadata_t* mda = NETIO_PKT_METADATA(pkt);
+
+  return NETIO_PKT_ETHERTYPE_M(mda, pkt);
+}
+
+
+/** Return the flow hash computed on the packet.
+ * @ingroup ingress
+ *
+ * For TCP and UDP packets, this hash is calculated by hashing together
+ * the "5-tuple" values, specifically the source IP address, destination
+ * IP address, protocol type, source port and destination port.
+ * The hash value is intended to be helpful for millions of distinct
+ * flows.
+ *
+ * For IPv4 or IPv6 packets which are neither TCP nor UDP, the flow hash is
+ * derived by hashing together the source and destination IP addresses.
+ *
+ * For MPLS-encapsulated packets, the flow hash is derived by hashing
+ * the first MPLS label.
+ *
+ * For all other packets the flow hash is computed from the source
+ * and destination Ethernet addresses.
+ *
+ * The hash is symmetric, meaning it produces the same value if the
+ * source and destination are swapped. The only exceptions are
+ * tunneling protocols 0x04 (IP in IP Encapsulation), 0x29 (Simple
+ * Internet Protocol), 0x2F (General Routing Encapsulation) and 0x32
+ * (Encap Security Payload), which use only the destination address
+ * since the source address is not meaningful.
+ *
+ * @param[in] pkt Packet on which to operate.
+ * @return The packet's 32-bit flow hash.
+ */
+static __inline unsigned int
+NETIO_PKT_FLOW_HASH(netio_pkt_t* pkt)
+{
+  netio_pkt_metadata_t* mda = NETIO_PKT_METADATA(pkt);
+
+  return NETIO_PKT_FLOW_HASH_M(mda, pkt);
+}
+
+
+/** Return the first word of "user data" for the packet.
+ *
+ * The contents of the user data words depend on the IPP.
+ *
+ * When using the standard ipp1, ipp2, or ipp4 sub-drivers, the first
+ * word of user data contains the least significant bits of the 64-bit
+ * arrival cycle count (see @c get_cycle_count_low()).
+ *
+ * See the <em>System Programmer's Guide</em> for details.
+ *
+ * @ingroup ingress
+ *
+ * @param[in] pkt Packet on which to operate.
+ * @return The packet's first word of "user data".
+ */
+static __inline unsigned int
+NETIO_PKT_USER_DATA_0(netio_pkt_t* pkt)
+{
+  netio_pkt_metadata_t* mda = NETIO_PKT_METADATA(pkt);
+
+  return NETIO_PKT_USER_DATA_0_M(mda, pkt);
+}
+
+
+/** Return the second word of "user data" for the packet.
+ *
+ * The contents of the user data words depend on the IPP.
+ *
+ * When using the standard ipp1, ipp2, or ipp4 sub-drivers, the second
+ * word of user data contains the most significant bits of the 64-bit
+ * arrival cycle count (see @c get_cycle_count_high()).
+ *
+ * See the <em>System Programmer's Guide</em> for details.
+ *
+ * @ingroup ingress
+ *
+ * @param[in] pkt Packet on which to operate.
+ * @return The packet's second word of "user data".
+ */
+static __inline unsigned int
+NETIO_PKT_USER_DATA_1(netio_pkt_t* pkt)
+{
+  netio_pkt_metadata_t* mda = NETIO_PKT_METADATA(pkt);
+
+  return NETIO_PKT_USER_DATA_1_M(mda, pkt);
+}
+
+
+/** Determine whether the L4 (TCP/UDP) checksum was calculated.
+ * @ingroup ingress
+ *
+ * @param[in] pkt Packet on which to operate.
+ * @return Nonzero if the L4 checksum was calculated.
+ */
+static __inline unsigned int
+NETIO_PKT_L4_CSUM_CALCULATED(netio_pkt_t* pkt)
+{
+  netio_pkt_metadata_t* mda = NETIO_PKT_METADATA(pkt);
+
+  return NETIO_PKT_L4_CSUM_CALCULATED_M(mda, pkt);
+}
+
+
+/** Determine whether the L4 (TCP/UDP) checksum was calculated and found to
+ *  be correct.
+ * @ingroup ingress
+ *
+ * @param[in] pkt Packet on which to operate.
+ * @return Nonzero if the checksum was calculated and is correct.
+ */
+static __inline unsigned int
+NETIO_PKT_L4_CSUM_CORRECT(netio_pkt_t* pkt)
+{
+  netio_pkt_metadata_t* mda = NETIO_PKT_METADATA(pkt);
+
+  return NETIO_PKT_L4_CSUM_CORRECT_M(mda, pkt);
+}
+
+
+/** Determine whether the L3 (IP) checksum was calculated.
+ * @ingroup ingress
+ *
+ * @param[in] pkt Packet on which to operate.
+ * @return Nonzero if the L3 (IP) checksum was calculated.
+*/
+static __inline unsigned int
+NETIO_PKT_L3_CSUM_CALCULATED(netio_pkt_t* pkt)
+{
+  netio_pkt_metadata_t* mda = NETIO_PKT_METADATA(pkt);
+
+  return NETIO_PKT_L3_CSUM_CALCULATED_M(mda, pkt);
+}
+
+
+/** Determine whether the L3 (IP) checksum was calculated and found to be
+ *  correct.
+ * @ingroup ingress
+ *
+ * @param[in] pkt Packet on which to operate.
+ * @return Nonzero if the checksum was calculated and is correct.
+ */
+static __inline unsigned int
+NETIO_PKT_L3_CSUM_CORRECT(netio_pkt_t* pkt)
+{
+  netio_pkt_metadata_t* mda = NETIO_PKT_METADATA(pkt);
+
+  return NETIO_PKT_L3_CSUM_CORRECT_M(mda, pkt);
+}
+
+
+/** Determine whether the Ethertype was recognized and L3 packet data was
+ *  processed.
+ * @ingroup ingress
+ *
+ * @param[in] pkt Packet on which to operate.
+ * @return Nonzero if the Ethertype was recognized and L3 packet data was
+ *   processed.
+ */
+static __inline unsigned int
+NETIO_PKT_ETHERTYPE_RECOGNIZED(netio_pkt_t* pkt)
+{
+  netio_pkt_metadata_t* mda = NETIO_PKT_METADATA(pkt);
+
+  return NETIO_PKT_ETHERTYPE_RECOGNIZED_M(mda, pkt);
+}
+
+
+/** Set an egress packet's L2 length, using a metadata pointer to speed the
+ * computation.
+ * @ingroup egress
+ *
+ * @param[in,out] mmd Pointer to packet's minimal metadata.
+ * @param[in] pkt Packet on which to operate.
+ * @param[in] len Packet L2 length, in bytes.
+ */
+static __inline void
+NETIO_PKT_SET_L2_LENGTH_MM(netio_pkt_minimal_metadata_t* mmd, netio_pkt_t* pkt,
+                           int len)
+{
+  mmd->l2_length = len;
+}
+
+
+/** Set an egress packet's L2 length.
+ * @ingroup egress
+ *
+ * @param[in,out] pkt Packet on which to operate.
+ * @param[in] len Packet L2 length, in bytes.
+ */
+static __inline void
+NETIO_PKT_SET_L2_LENGTH(netio_pkt_t* pkt, int len)
+{
+  netio_pkt_minimal_metadata_t* mmd = NETIO_PKT_MINIMAL_METADATA(pkt);
+
+  NETIO_PKT_SET_L2_LENGTH_MM(mmd, pkt, len);
+}
+
+
+/** Set an egress packet's L2 header length, using a metadata pointer to
+ *  speed the computation.
+ * @ingroup egress
+ *
+ * It is not normally necessary to call this routine; only the L2 length,
+ * not the header length, is needed to transmit a packet.  It may be useful if
+ * the egress packet will later be processed by code which expects to use
+ * functions like @ref NETIO_PKT_L3_DATA() to get a pointer to the L3 payload.
+ *
+ * @param[in,out] mmd Pointer to packet's minimal metadata.
+ * @param[in] pkt Packet on which to operate.
+ * @param[in] len Packet L2 header length, in bytes.
+ */
+static __inline void
+NETIO_PKT_SET_L2_HEADER_LENGTH_MM(netio_pkt_minimal_metadata_t* mmd,
+                                  netio_pkt_t* pkt, int len)
+{
+  mmd->l3_offset = mmd->l2_offset + len;
+}
+
+
+/** Set an egress packet's L2 header length.
+ * @ingroup egress
+ *
+ * It is not normally necessary to call this routine; only the L2 length,
+ * not the header length, is needed to transmit a packet.  It may be useful if
+ * the egress packet will later be processed by code which expects to use
+ * functions like @ref NETIO_PKT_L3_DATA() to get a pointer to the L3 payload.
+ *
+ * @param[in,out] pkt Packet on which to operate.
+ * @param[in] len Packet L2 header length, in bytes.
+ */
+static __inline void
+NETIO_PKT_SET_L2_HEADER_LENGTH(netio_pkt_t* pkt, int len)
+{
+  netio_pkt_minimal_metadata_t* mmd = NETIO_PKT_MINIMAL_METADATA(pkt);
+
+  NETIO_PKT_SET_L2_HEADER_LENGTH_MM(mmd, pkt, len);
+}
+
+
+/** Set up an egress packet for hardware checksum computation, using a
+ *  metadata pointer to speed the operation.
+ * @ingroup egress
+ *
+ *  NetIO provides the ability to automatically calculate a standard
+ *  16-bit Internet checksum on transmitted packets.  The application
+ *  may specify the point in the packet where the checksum starts, the
+ *  number of bytes to be checksummed, and the two bytes in the packet
+ *  which will be replaced with the completed checksum.  (If the range
+ *  of bytes to be checksummed includes the bytes to be replaced, the
+ *  initial values of those bytes will be included in the checksum.)
+ *
+ *  For some protocols, the packet checksum covers data which is not present
+ *  in the packet, or is at least not contiguous to the main data payload.
+ *  For instance, the TCP checksum includes a "pseudo-header" which includes
+ *  the source and destination IP addresses of the packet.  To accommodate
+ *  this, the checksum engine may be "seeded" with an initial value, which
+ *  the application would need to compute based on the specific protocol's
+ *  requirements.  Note that the seed is given in host byte order (little-
+ *  endian), not network byte order (big-endian); code written to compute a
+ *  pseudo-header checksum in network byte order will need to byte-swap it
+ *  before use as the seed.
+ *
+ *  Note that the checksum is computed as part of the transmission process,
+ *  so it will not be present in the packet upon completion of this routine.
+ *
+ * @param[in,out] mmd Pointer to packet's minimal metadata.
+ * @param[in] pkt Packet on which to operate.
+ * @param[in] start Offset within L2 packet of the first byte to include in
+ *   the checksum.
+ * @param[in] length Number of bytes to include in the checksum.
+ *   the checksum.
+ * @param[in] location Offset within L2 packet of the first of the two bytes
+ *   to be replaced with the calculated checksum.
+ * @param[in] seed Initial value of the running checksum before any of the
+ *   packet data is added.
+ */
+static __inline void
+NETIO_PKT_DO_EGRESS_CSUM_MM(netio_pkt_minimal_metadata_t* mmd,
+                            netio_pkt_t* pkt, int start, int length,
+                            int location, uint16_t seed)
+{
+  mmd->csum_start = start;
+  mmd->csum_length = length;
+  mmd->csum_location = location;
+  mmd->csum_seed = seed;
+  mmd->flags |= _NETIO_PKT_NEED_EDMA_CSUM_MASK;
+}
+
+
+/** Set up an egress packet for hardware checksum computation.
+ * @ingroup egress
+ *
+ *  NetIO provides the ability to automatically calculate a standard
+ *  16-bit Internet checksum on transmitted packets.  The application
+ *  may specify the point in the packet where the checksum starts, the
+ *  number of bytes to be checksummed, and the two bytes in the packet
+ *  which will be replaced with the completed checksum.  (If the range
+ *  of bytes to be checksummed includes the bytes to be replaced, the
+ *  initial values of those bytes will be included in the checksum.)
+ *
+ *  For some protocols, the packet checksum covers data which is not present
+ *  in the packet, or is at least not contiguous to the main data payload.
+ *  For instance, the TCP checksum includes a "pseudo-header" which includes
+ *  the source and destination IP addresses of the packet.  To accommodate
+ *  this, the checksum engine may be "seeded" with an initial value, which
+ *  the application would need to compute based on the specific protocol's
+ *  requirements.  Note that the seed is given in host byte order (little-
+ *  endian), not network byte order (big-endian); code written to compute a
+ *  pseudo-header checksum in network byte order will need to byte-swap it
+ *  before use as the seed.
+ *
+ *  Note that the checksum is computed as part of the transmission process,
+ *  so it will not be present in the packet upon completion of this routine.
+ *
+ * @param[in,out] pkt Packet on which to operate.
+ * @param[in] start Offset within L2 packet of the first byte to include in
+ *   the checksum.
+ * @param[in] length Number of bytes to include in the checksum.
+ *   the checksum.
+ * @param[in] location Offset within L2 packet of the first of the two bytes
+ *   to be replaced with the calculated checksum.
+ * @param[in] seed Initial value of the running checksum before any of the
+ *   packet data is added.
+ */
+static __inline void
+NETIO_PKT_DO_EGRESS_CSUM(netio_pkt_t* pkt, int start, int length,
+                         int location, uint16_t seed)
+{
+  netio_pkt_minimal_metadata_t* mmd = NETIO_PKT_MINIMAL_METADATA(pkt);
+
+  NETIO_PKT_DO_EGRESS_CSUM_MM(mmd, pkt, start, length, location, seed);
+}
+
+
+/** Return the number of bytes which could be prepended to a packet, using a
+ *  metadata pointer to speed the operation.
+ *  See @ref netio_populate_prepend_buffer() to get a full description of
+ *  prepending.
+ *
+ * @param[in,out] mda Pointer to packet's standard metadata.
+ * @param[in] pkt Packet on which to operate.
+ */
+static __inline int
+NETIO_PKT_PREPEND_AVAIL_M(netio_pkt_metadata_t* mda, netio_pkt_t* pkt)
+{
+  return (pkt->__packet.bits.__offset << 6) +
+         NETIO_PKT_CUSTOM_HEADER_LENGTH_M(mda, pkt);
+}
+
+
+/** Return the number of bytes which could be prepended to a packet, using a
+ *  metadata pointer to speed the operation.
+ *  See @ref netio_populate_prepend_buffer() to get a full description of
+ *  prepending.
+ * @ingroup egress
+ *
+ * @param[in,out] mmd Pointer to packet's minimal metadata.
+ * @param[in] pkt Packet on which to operate.
+ */
+static __inline int
+NETIO_PKT_PREPEND_AVAIL_MM(netio_pkt_minimal_metadata_t* mmd, netio_pkt_t* pkt)
+{
+  return (pkt->__packet.bits.__offset << 6) + mmd->l2_offset;
+}
+
+
+/** Return the number of bytes which could be prepended to a packet.
+ *  See @ref netio_populate_prepend_buffer() to get a full description of
+ *  prepending.
+ * @ingroup egress
+ *
+ * @param[in] pkt Packet on which to operate.
+ */
+static __inline int
+NETIO_PKT_PREPEND_AVAIL(netio_pkt_t* pkt)
+{
+  if (NETIO_PKT_IS_MINIMAL(pkt))
+  {
+    netio_pkt_minimal_metadata_t* mmd = NETIO_PKT_MINIMAL_METADATA(pkt);
+
+    return NETIO_PKT_PREPEND_AVAIL_MM(mmd, pkt);
+  }
+  else
+  {
+    netio_pkt_metadata_t* mda = NETIO_PKT_METADATA(pkt);
+
+    return NETIO_PKT_PREPEND_AVAIL_M(mda, pkt);
+  }
+}
+
+
+/** Flush a packet's minimal metadata from the cache, using a metadata pointer
+ *  to speed the operation.
+ * @ingroup egress
+ *
+ * @param[in] mmd Pointer to packet's minimal metadata.
+ * @param[in] pkt Packet on which to operate.
+ */
+static __inline void
+NETIO_PKT_FLUSH_MINIMAL_METADATA_MM(netio_pkt_minimal_metadata_t* mmd,
+                                    netio_pkt_t* pkt)
+{
+}
+
+
+/** Invalidate a packet's minimal metadata from the cache, using a metadata
+ *  pointer to speed the operation.
+ * @ingroup egress
+ *
+ * @param[in] mmd Pointer to packet's minimal metadata.
+ * @param[in] pkt Packet on which to operate.
+ */
+static __inline void
+NETIO_PKT_INV_MINIMAL_METADATA_MM(netio_pkt_minimal_metadata_t* mmd,
+                                  netio_pkt_t* pkt)
+{
+}
+
+
+/** Flush and then invalidate a packet's minimal metadata from the cache,
+ *  using a metadata pointer to speed the operation.
+ * @ingroup egress
+ *
+ * @param[in] mmd Pointer to packet's minimal metadata.
+ * @param[in] pkt Packet on which to operate.
+ */
+static __inline void
+NETIO_PKT_FLUSH_INV_MINIMAL_METADATA_MM(netio_pkt_minimal_metadata_t* mmd,
+                                        netio_pkt_t* pkt)
+{
+}
+
+
+/** Flush a packet's metadata from the cache, using a metadata pointer
+ *  to speed the operation.
+ * @ingroup ingress
+ *
+ * @param[in] mda Pointer to packet's minimal metadata.
+ * @param[in] pkt Packet on which to operate.
+ */
+static __inline void
+NETIO_PKT_FLUSH_METADATA_M(netio_pkt_metadata_t* mda, netio_pkt_t* pkt)
+{
+}
+
+
+/** Invalidate a packet's metadata from the cache, using a metadata
+ *  pointer to speed the operation.
+ * @ingroup ingress
+ *
+ * @param[in] mda Pointer to packet's metadata.
+ * @param[in] pkt Packet on which to operate.
+ */
+static __inline void
+NETIO_PKT_INV_METADATA_M(netio_pkt_metadata_t* mda, netio_pkt_t* pkt)
+{
+}
+
+
+/** Flush and then invalidate a packet's metadata from the cache,
+ *  using a metadata pointer to speed the operation.
+ * @ingroup ingress
+ *
+ * @param[in] mda Pointer to packet's metadata.
+ * @param[in] pkt Packet on which to operate.
+ */
+static __inline void
+NETIO_PKT_FLUSH_INV_METADATA_M(netio_pkt_metadata_t* mda, netio_pkt_t* pkt)
+{
+}
+
+
+/** Flush a packet's minimal metadata from the cache.
+ * @ingroup egress
+ *
+ * @param[in] pkt Packet on which to operate.
+ */
+static __inline void
+NETIO_PKT_FLUSH_MINIMAL_METADATA(netio_pkt_t* pkt)
+{
+}
+
+
+/** Invalidate a packet's minimal metadata from the cache.
+ * @ingroup egress
+ *
+ * @param[in] pkt Packet on which to operate.
+ */
+static __inline void
+NETIO_PKT_INV_MINIMAL_METADATA(netio_pkt_t* pkt)
+{
+}
+
+
+/** Flush and then invalidate a packet's minimal metadata from the cache.
+ * @ingroup egress
+ *
+ * @param[in] pkt Packet on which to operate.
+ */
+static __inline void
+NETIO_PKT_FLUSH_INV_MINIMAL_METADATA(netio_pkt_t* pkt)
+{
+}
+
+
+/** Flush a packet's metadata from the cache.
+ * @ingroup ingress
+ *
+ * @param[in] pkt Packet on which to operate.
+ */
+static __inline void
+NETIO_PKT_FLUSH_METADATA(netio_pkt_t* pkt)
+{
+}
+
+
+/** Invalidate a packet's metadata from the cache.
+ * @ingroup ingress
+ *
+ * @param[in] pkt Packet on which to operate.
+ */
+static __inline void
+NETIO_PKT_INV_METADATA(netio_pkt_t* pkt)
+{
+}
+
+
+/** Flush and then invalidate a packet's metadata from the cache.
+ * @ingroup ingress
+ *
+ * @param[in] pkt Packet on which to operate.
+ */
+static __inline void
+NETIO_PKT_FLUSH_INV_METADATA(netio_pkt_t* pkt)
+{
+}
+
+/** Number of NUMA nodes we can distribute buffers to.
+ * @ingroup setup */
+#define NETIO_NUM_NODE_WEIGHTS  16
+
+/**
+ * @brief An object for specifying the characteristics of NetIO communication
+ * endpoint.
+ *
+ * @ingroup setup
+ *
+ * The @ref netio_input_register() function uses this structure to define
+ * how an application tile will communicate with an IPP.
+ *
+ *
+ * Future updates to NetIO may add new members to this structure,
+ * which can affect the success of the registration operation.  Thus,
+ * if dynamically initializing the structure, applications are urged to
+ * zero it out first, for example:
+ *
+ * @code
+ * netio_input_config_t config;
+ * memset(&config, 0, sizeof (config));
+ * config.flags = NETIO_RECV | NETIO_XMIT_CSUM | NETIO_TAG_NONE;
+ * config.num_receive_packets = NETIO_MAX_RECEIVE_PKTS;
+ * config.queue_id = 0;
+ *     .
+ *     .
+ *     .
+ * @endcode
+ *
+ * since that guarantees that any unused structure members, including
+ * members which did not exist when the application was first developed,
+ * will not have unexpected values.
+ *
+ * If statically initializing the structure, we strongly recommend use of
+ * C99-style named initializers, for example:
+ *
+ * @code
+ * netio_input_config_t config = {
+ *    .flags = NETIO_RECV | NETIO_XMIT_CSUM | NETIO_TAG_NONE,
+ *    .num_receive_packets = NETIO_MAX_RECEIVE_PKTS,
+ *    .queue_id = 0,
+ * },
+ * @endcode
+ *
+ * instead of the old-style structure initialization:
+ *
+ * @code
+ * // Bad example! Currently equivalent to the above, but don't do this.
+ * netio_input_config_t config = {
+ *    NETIO_RECV | NETIO_XMIT_CSUM | NETIO_TAG_NONE, NETIO_MAX_RECEIVE_PKTS, 0
+ * },
+ * @endcode
+ *
+ * since the C99 style requires no changes to the code if elements of the
+ * config structure are rearranged.  (It also makes the initialization much
+ * easier to understand.)
+ *
+ * Except for items which address a particular tile's transmit or receive
+ * characteristics, such as the ::NETIO_RECV flag, applications are advised
+ * to specify the same set of configuration data on all registrations.
+ * This prevents differing results if multiple tiles happen to do their
+ * registration operations in a different order on different invocations of
+ * the application.  This is particularly important for things like link
+ * management flags, and buffer size and homing specifications.
+ *
+ * Unless the ::NETIO_FIXED_BUFFER_VA flag is specified in flags, the NetIO
+ * buffer pool is automatically created and mapped into the application's
+ * virtual address space at an address chosen by the operating system,
+ * using the common memory (cmem) facility in the Tilera Multicore
+ * Components library.  The cmem facility allows multiple processes to gain
+ * access to shared memory which is mapped into each process at an
+ * identical virtual address.  In order for this to work, the processes
+ * must have a common ancestor, which must create the common memory using
+ * tmc_cmem_init().
+ *
+ * In programs using the iLib process creation API, or in programs which use
+ * only one process (which include programs using the pthreads library),
+ * tmc_cmem_init() is called automatically.  All other applications
+ * must call it explicitly, before any child processes which might call
+ * netio_input_register() are created.
+ */
+typedef struct
+{
+  /** Registration characteristics.
+
+      This value determines several characteristics of the registration;
+      flags for different types of behavior are ORed together to make the
+      final flag value.  Generally applications should specify exactly
+      one flag from each of the following categories:
+
+      - Whether the application will be receiving packets on this queue
+        (::NETIO_RECV or ::NETIO_NO_RECV).
+
+      - Whether the application will be transmitting packets on this queue,
+        and if so, whether it will request egress checksum calculation
+        (::NETIO_XMIT, ::NETIO_XMIT_CSUM, or ::NETIO_NO_XMIT).  It is
+        legal to call netio_get_buffer() without one of the XMIT flags,
+        as long as ::NETIO_RECV is specified; in this case, the retrieved
+        buffers must be passed to another tile for transmission.
+
+      - Whether the application expects any vendor-specific tags in
+        its packets' L2 headers (::NETIO_TAG_NONE, ::NETIO_TAG_BRCM,
+        or ::NETIO_TAG_MRVL).  This must match the configuration of the
+        target IPP.
+
+      To accommodate applications written to previous versions of the NetIO
+      interface, none of the flags above are currently required; if omitted,
+      NetIO behaves more or less as if ::NETIO_RECV | ::NETIO_XMIT_CSUM |
+      ::NETIO_TAG_NONE were used.  However, explicit specification of
+      the relevant flags allows NetIO to do a better job of resource
+      allocation, allows earlier detection of certain configuration errors,
+      and may enable advanced features or higher performance in the future,
+      so their use is strongly recommended.
+
+      Note that specifying ::NETIO_NO_RECV along with ::NETIO_NO_XMIT
+      is a special case, intended primarily for use by programs which
+      retrieve network statistics or do link management operations.
+      When these flags are both specified, the resulting queue may not
+      be used with NetIO routines other than netio_get(), netio_set(),
+      and netio_input_unregister().  See @ref link for more information
+      on link management.
+
+      Other flags are optional; their use is described below.
+  */
+  int flags;
+
+  /** Interface name.  This is a string which identifies the specific
+      Ethernet controller hardware to be used.  The format of the string
+      is a device type and a device index, separated by a slash; so,
+      the first 10 Gigabit Ethernet controller is named "xgbe/0", while
+      the second 10/100/1000 Megabit Ethernet controller is named "gbe/1".
+   */
+  const char* interface;
+
+  /** Receive packet queue size.  This specifies the maximum number
+      of ingress packets that can be received on this queue without
+      being retrieved by @ref netio_get_packet().  If the IPP's distribution
+      algorithm calls for a packet to be sent to this queue, and this
+      number of packets are already pending there, the new packet
+      will either be discarded, or sent to another tile registered
+      for the same queue_id (see @ref drops).  This value must
+      be at least ::NETIO_MIN_RECEIVE_PKTS, can always be at least
+      ::NETIO_MAX_RECEIVE_PKTS, and may be larger than that on certain
+      interfaces.
+   */
+  int num_receive_packets;
+
+  /** The queue ID being requested.  Legal values for this range from 0
+      to ::NETIO_MAX_QUEUE_ID, inclusive.  ::NETIO_MAX_QUEUE_ID is always
+      greater than or equal to the number of tiles; this allows one queue
+      for each tile, plus at least one additional queue.  Some applications
+      may wish to use the additional queue as a destination for unwanted
+      packets, since packets delivered to queues for which no tiles have
+      registered are discarded.
+   */
+  unsigned int queue_id;
+
+  /** Maximum number of small send buffers to be held in the local empty
+      buffer cache.  This specifies the size of the area which holds
+      empty small egress buffers requested from the IPP but not yet
+      retrieved via @ref netio_get_buffer().  This value must be greater
+      than zero if the application will ever use @ref netio_get_buffer()
+      to allocate empty small egress buffers; it may be no larger than
+      ::NETIO_MAX_SEND_BUFFERS.  See @ref epp for more details on empty
+      buffer caching.
+   */
+  int num_send_buffers_small_total;
+
+  /** Number of small send buffers to be preallocated at registration.
+      If this value is nonzero, the specified number of empty small egress
+      buffers will be requested from the IPP during the netio_input_register
+      operation; this may speed the execution of @ref netio_get_buffer().
+      This may be no larger than @ref num_send_buffers_small_total.  See @ref
+      epp for more details on empty buffer caching.
+   */
+  int num_send_buffers_small_prealloc;
+
+  /** Maximum number of large send buffers to be held in the local empty
+      buffer cache.  This specifies the size of the area which holds empty
+      large egress buffers requested from the IPP but not yet retrieved via
+      @ref netio_get_buffer().  This value must be greater than zero if the
+      application will ever use @ref netio_get_buffer() to allocate empty
+      large egress buffers; it may be no larger than ::NETIO_MAX_SEND_BUFFERS.
+      See @ref epp for more details on empty buffer caching.
+   */
+  int num_send_buffers_large_total;
+
+  /** Number of large send buffers to be preallocated at registration.
+      If this value is nonzero, the specified number of empty large egress
+      buffers will be requested from the IPP during the netio_input_register
+      operation; this may speed the execution of @ref netio_get_buffer().
+      This may be no larger than @ref num_send_buffers_large_total.  See @ref
+      epp for more details on empty buffer caching.
+   */
+  int num_send_buffers_large_prealloc;
+
+  /** Maximum number of jumbo send buffers to be held in the local empty
+      buffer cache.  This specifies the size of the area which holds empty
+      jumbo egress buffers requested from the IPP but not yet retrieved via
+      @ref netio_get_buffer().  This value must be greater than zero if the
+      application will ever use @ref netio_get_buffer() to allocate empty
+      jumbo egress buffers; it may be no larger than ::NETIO_MAX_SEND_BUFFERS.
+      See @ref epp for more details on empty buffer caching.
+   */
+  int num_send_buffers_jumbo_total;
+
+  /** Number of jumbo send buffers to be preallocated at registration.
+      If this value is nonzero, the specified number of empty jumbo egress
+      buffers will be requested from the IPP during the netio_input_register
+      operation; this may speed the execution of @ref netio_get_buffer().
+      This may be no larger than @ref num_send_buffers_jumbo_total.  See @ref
+      epp for more details on empty buffer caching.
+   */
+  int num_send_buffers_jumbo_prealloc;
+
+  /** Total packet buffer size.  This determines the total size, in bytes,
+      of the NetIO buffer pool.  Note that the maximum number of available
+      buffers of each size is determined during hypervisor configuration
+      (see the <em>System Programmer's Guide</em> for details); this just
+      influences how much host memory is allocated for those buffers.
+
+      The buffer pool is allocated from common memory, which will be
+      automatically initialized if needed.  If your buffer pool is larger
+      than 240 MB, you might need to explicitly call @c tmc_cmem_init(),
+      as described in the Application Libraries Reference Manual (UG227).
+
+      Packet buffers are currently allocated in chunks of 16 MB; this
+      value will be rounded up to the next larger multiple of 16 MB.
+      If this value is zero, a default of 32 MB will be used; this was
+      the value used by previous versions of NetIO.  Note that taking this
+      default also affects the placement of buffers on Linux NUMA nodes.
+      See @ref buffer_node_weights for an explanation of buffer placement.
+
+      In order to successfully allocate packet buffers, Linux must have
+      available huge pages on the relevant Linux NUMA nodes.  See the
+      <em>System Programmer's Guide</em> for information on configuring
+      huge page support in Linux.
+   */
+  uint64_t total_buffer_size;
+
+  /** Buffer placement weighting factors.
+
+      This array specifies the relative amount of buffering to place
+      on each of the available Linux NUMA nodes.  This array is
+      indexed by the NUMA node, and the values in the array are
+      proportional to the amount of buffer space to allocate on that
+      node.
+
+      If memory striping is enabled in the Hypervisor, then there is
+      only one logical NUMA node (node 0). In that case, NetIO will by
+      default ignore the suggested buffer node weights, and buffers
+      will be striped across the physical memory controllers. See
+      UG209 System Programmer's Guide for a description of the
+      hypervisor option that controls memory striping.
+
+      If memory striping is disabled, then there are up to four NUMA
+      nodes, corresponding to the four DDRAM controllers in the TILE
+      processor architecture.  See UG100 Tile Processor Architecture
+      Overview for a diagram showing the location of each of the DDRAM
+      controllers relative to the tile array.
+
+      For instance, if memory striping is disabled, the following
+      configuration strucure:
+
+      @code
+      netio_input_config_t config = {
+            .
+            .
+            .
+        .total_buffer_size = 4 * 16 * 1024 * 1024;
+        .buffer_node_weights = { 1, 0, 1, 0 },
+      },
+      @endcode
+
+      would result in 32 MB of buffers being placed on controller 0, and
+      32 MB on controller 2.  (Since buffers are allocated in units of
+      16 MB, some sets of weights will not be able to be matched exactly.)
+
+      For the weights to be effective, @ref total_buffer_size must be
+      nonzero.  If @ref total_buffer_size is zero, causing the default
+      32 MB of buffer space to be used, then any specified weights will
+      be ignored, and buffers will positioned as they were in previous
+      versions of NetIO:
+
+      - For xgbe/0 and gbe/0, 16 MB of buffers will be placed on controller 1,
+        and the other 16 MB will be placed on controller 2.
+
+      - For xgbe/1 and gbe/1, 16 MB of buffers will be placed on controller 2,
+        and the other 16 MB will be placed on controller 3.
+
+      If @ref total_buffer_size is nonzero, but all weights are zero,
+      then all buffer space will be allocated on Linux NUMA node zero.
+
+      By default, the specified buffer placement is treated as a hint;
+      if sufficient free memory is not available on the specified
+      controllers, the buffers will be allocated elsewhere.  However,
+      if the ::NETIO_STRICT_HOMING flag is specified in @ref flags, then a
+      failure to allocate buffer space exactly as requested will cause the
+      registration operation to fail with an error of ::NETIO_CANNOT_HOME.
+
+      Note that maximal network performance cannot be achieved with
+      only one memory controller.
+   */
+  uint8_t buffer_node_weights[NETIO_NUM_NODE_WEIGHTS];
+
+  /** Fixed virtual address for packet buffers.  Only valid when
+      ::NETIO_FIXED_BUFFER_VA is specified in @ref flags; see the
+      description of that flag for details.
+   */
+  void* fixed_buffer_va;
+
+  /**
+      Maximum number of outstanding send packet requests.  This value is
+      only relevant when an EPP is in use; it determines the number of
+      slots in the EPP's outgoing packet queue which this tile is allowed
+      to consume, and thus the number of packets which may be sent before
+      the sending tile must wait for an acknowledgment from the EPP.
+      Modifying this value is generally only helpful when using @ref
+      netio_send_packet_vector(), where it can help improve performance by
+      allowing a single vector send operation to process more packets.
+      Typically it is not specified, and the default, which divides the
+      outgoing packet slots evenly between all tiles on the chip, is used.
+
+      If a registration asks for more outgoing packet queue slots than are
+      available, ::NETIO_TOOMANY_XMIT will be returned.  The total number
+      of packet queue slots which are available for all tiles for each EPP
+      is subject to change, but is currently ::NETIO_TOTAL_SENDS_OUTSTANDING.
+
+
+      This value is ignored if ::NETIO_XMIT is not specified in flags.
+      If you want to specify a large value here for a specific tile, you are
+      advised to specify NETIO_NO_XMIT on other, non-transmitting tiles so
+      that they do not consume a default number of packet slots.  Any tile
+      transmitting is required to have at least ::NETIO_MIN_SENDS_OUTSTANDING
+      slots allocated to it; values less than that will be silently
+      increased by the NetIO library.
+   */
+  int num_sends_outstanding;
+}
+netio_input_config_t;
+
+
+/** Registration flags; used in the @ref netio_input_config_t structure.
+ * @addtogroup setup
+ */
+/** @{ */
+
+/** Fail a registration request if we can't put packet buffers
+    on the specified memory controllers. */
+#define NETIO_STRICT_HOMING   0x00000002
+
+/** This application expects no tags on its L2 headers. */
+#define NETIO_TAG_NONE        0x00000004
+
+/** This application expects Marvell extended tags on its L2 headers. */
+#define NETIO_TAG_MRVL        0x00000008
+
+/** This application expects Broadcom tags on its L2 headers. */
+#define NETIO_TAG_BRCM        0x00000010
+
+/** This registration may call routines which receive packets. */
+#define NETIO_RECV            0x00000020
+
+/** This registration may not call routines which receive packets. */
+#define NETIO_NO_RECV         0x00000040
+
+/** This registration may call routines which transmit packets. */
+#define NETIO_XMIT            0x00000080
+
+/** This registration may call routines which transmit packets with
+    checksum acceleration. */
+#define NETIO_XMIT_CSUM       0x00000100
+
+/** This registration may not call routines which transmit packets. */
+#define NETIO_NO_XMIT         0x00000200
+
+/** This registration wants NetIO buffers mapped at an application-specified
+    virtual address.
+
+    NetIO buffers are by default created by the TMC common memory facility,
+    which must be configured by a common ancestor of all processes sharing
+    a network interface.  When this flag is specified, NetIO buffers are
+    instead mapped at an address chosen by the application (and specified
+    in @ref netio_input_config_t::fixed_buffer_va).  This allows multiple
+    unrelated but cooperating processes to share a NetIO interface.
+    All processes sharing the same interface must specify this flag,
+    and all must specify the same fixed virtual address.
+
+    @ref netio_input_config_t::fixed_buffer_va must be a
+    multiple of 16 MB, and the packet buffers will occupy @ref
+    netio_input_config_t::total_buffer_size bytes of virtual address
+    space, beginning at that address.  If any of those virtual addresses
+    are currently occupied by other memory objects, like application or
+    shared library code or data, @ref netio_input_register() will return
+    ::NETIO_FAULT.  While it is impossible to provide a fixed_buffer_va
+    which will work for all applications, a good first guess might be to
+    use 0xb0000000 minus @ref netio_input_config_t::total_buffer_size.
+    If that fails, it might be helpful to consult the running application's
+    virtual address description file (/proc/<em>pid</em>/maps) to see
+    which regions of virtual address space are available.
+ */
+#define NETIO_FIXED_BUFFER_VA 0x00000400
+
+/** This registration call will not complete unless the network link
+    is up.  The process will wait several seconds for this to happen (the
+    precise interval is link-dependent), but if the link does not come up,
+    ::NETIO_LINK_DOWN will be returned.  This flag is the default if
+    ::NETIO_NOREQUIRE_LINK_UP is not specified.  Note that this flag by
+    itself does not request that the link be brought up; that can be done
+    with the ::NETIO_AUTO_LINK_UPDN or ::NETIO_AUTO_LINK_UP flags (the
+    latter is the default if no NETIO_AUTO_LINK_xxx flags are specified),
+    or by explicitly setting the link's desired state via netio_set().
+    If the link is not brought up by one of those methods, and this flag
+    is specified, the registration operation will return ::NETIO_LINK_DOWN.
+    This flag is ignored if it is specified along with ::NETIO_NO_XMIT and
+    ::NETIO_NO_RECV.  See @ref link for more information on link
+    management.
+ */
+#define NETIO_REQUIRE_LINK_UP    0x00000800
+
+/** This registration call will complete even if the network link is not up.
+    Whenever the link is not up, packets will not be sent or received:
+    netio_get_packet() will return ::NETIO_NOPKT once all queued packets
+    have been drained, and netio_send_packet() and similar routines will
+    return NETIO_QUEUE_FULL once the outgoing packet queue in the EPP
+    or the I/O shim is full.  See @ref link for more information on link
+    management.
+ */
+#define NETIO_NOREQUIRE_LINK_UP  0x00001000
+
+#ifndef __DOXYGEN__
+/*
+ * These are part of the implementation of the NETIO_AUTO_LINK_xxx flags,
+ * but should not be used directly by applications, and are thus not
+ * documented.
+ */
+#define _NETIO_AUTO_UP        0x00002000
+#define _NETIO_AUTO_DN        0x00004000
+#define _NETIO_AUTO_PRESENT   0x00008000
+#endif
+
+/** Set the desired state of the link to up, allowing any speeds which are
+    supported by the link hardware, as part of this registration operation.
+    Do not take down the link automatically.  This is the default if
+    no other NETIO_AUTO_LINK_xxx flags are specified.  This flag is ignored
+    if it is specified along with ::NETIO_NO_XMIT and ::NETIO_NO_RECV.
+    See @ref link for more information on link management.
+ */
+#define NETIO_AUTO_LINK_UP     (_NETIO_AUTO_PRESENT | _NETIO_AUTO_UP)
+
+/** Set the desired state of the link to up, allowing any speeds which are
+    supported by the link hardware, as part of this registration operation.
+    Set the desired state of the link to down the next time no tiles are
+    registered for packet reception or transmission.  This flag is ignored
+    if it is specified along with ::NETIO_NO_XMIT and ::NETIO_NO_RECV.
+    See @ref link for more information on link management.
+ */
+#define NETIO_AUTO_LINK_UPDN   (_NETIO_AUTO_PRESENT | _NETIO_AUTO_UP | \
+                                _NETIO_AUTO_DN)
+
+/** Set the desired state of the link to down the next time no tiles are
+    registered for packet reception or transmission.  This flag is ignored
+    if it is specified along with ::NETIO_NO_XMIT and ::NETIO_NO_RECV.
+    See @ref link for more information on link management.
+ */
+#define NETIO_AUTO_LINK_DN     (_NETIO_AUTO_PRESENT | _NETIO_AUTO_DN)
+
+/** Do not bring up the link automatically as part of this registration
+    operation.  Do not take down the link automatically.  This flag
+    is ignored if it is specified along with ::NETIO_NO_XMIT and
+    ::NETIO_NO_RECV.  See @ref link for more information on link management.
+  */
+#define NETIO_AUTO_LINK_NONE   _NETIO_AUTO_PRESENT
+
+
+/** Minimum number of receive packets. */
+#define NETIO_MIN_RECEIVE_PKTS            16
+
+/** Lower bound on the maximum number of receive packets; may be higher
+    than this on some interfaces. */
+#define NETIO_MAX_RECEIVE_PKTS           128
+
+/** Maximum number of send buffers, per packet size. */
+#define NETIO_MAX_SEND_BUFFERS            16
+
+/** Number of EPP queue slots, and thus outstanding sends, per EPP. */
+#define NETIO_TOTAL_SENDS_OUTSTANDING   2015
+
+/** Minimum number of EPP queue slots, and thus outstanding sends, per
+ *  transmitting tile. */
+#define NETIO_MIN_SENDS_OUTSTANDING       16
+
+
+/**@}*/
+
+#ifndef __DOXYGEN__
+
+/**
+ * An object for providing Ethernet packets to a process.
+ */
+struct __netio_queue_impl_t;
+
+/**
+ * An object for managing the user end of a NetIO queue.
+ */
+struct __netio_queue_user_impl_t;
+
+#endif /* !__DOXYGEN__ */
+
+
+/** A netio_queue_t describes a NetIO communications endpoint.
+ * @ingroup setup
+ */
+typedef struct
+{
+#ifdef __DOXYGEN__
+  uint8_t opaque[8];                 /**< This is an opaque structure. */
+#else
+  struct __netio_queue_impl_t* __system_part;    /**< The system part. */
+  struct __netio_queue_user_impl_t* __user_part; /**< The user part. */
+#ifdef _NETIO_PTHREAD
+  _netio_percpu_mutex_t lock;                    /**< Queue lock. */
+#endif
+#endif
+}
+netio_queue_t;
+
+
+/**
+ * @brief Packet send context.
+ *
+ * @ingroup egress
+ *
+ * Packet send context for use with netio_send_packet_prepare and _commit.
+ */
+typedef struct
+{
+#ifdef __DOXYGEN__
+  uint8_t opaque[44];   /**< This is an opaque structure. */
+#else
+  uint8_t flags;        /**< Defined below */
+  uint8_t datalen;      /**< Number of valid words pointed to by data. */
+  uint32_t request[9];  /**< Request to be sent to the EPP or shim.  Note
+                             that this is smaller than the 11-word maximum
+                             request size, since some constant values are
+                             not saved in the context. */
+  uint32_t *data;       /**< Data to be sent to the EPP or shim via IDN. */
+#endif
+}
+netio_send_pkt_context_t;
+
+
+#ifndef __DOXYGEN__
+#define SEND_PKT_CTX_USE_EPP   1  /**< We're sending to an EPP. */
+#define SEND_PKT_CTX_SEND_CSUM 2  /**< Request includes a checksum. */
+#endif
+
+/**
+ * @brief Packet vector entry.
+ *
+ * @ingroup egress
+ *
+ * This data structure is used with netio_send_packet_vector() to send multiple
+ * packets with one NetIO call.  The structure should be initialized by
+ * calling netio_pkt_vector_set(), rather than by setting the fields
+ * directly.
+ *
+ * This structure is guaranteed to be a power of two in size, no
+ * bigger than one L2 cache line, and to be aligned modulo its size.
+ */
+typedef struct
+#ifndef __DOXYGEN__
+__attribute__((aligned(8)))
+#endif
+{
+  /** Reserved for use by the user application.  When initialized with
+   *  the netio_set_pkt_vector_entry() function, this field is guaranteed
+   *  to be visible to readers only after all other fields are already
+   *  visible.  This way it can be used as a valid flag or generation
+   *  counter. */
+  uint8_t user_data;
+
+  /* Structure members below this point should not be accessed directly by
+   * applications, as they may change in the future. */
+
+  /** Low 8 bits of the packet address to send.  The high bits are
+   *  acquired from the 'handle' field. */
+  uint8_t buffer_address_low;
+
+  /** Number of bytes to transmit. */
+  uint16_t size;
+
+  /** The raw handle from a netio_pkt_t.  If this is NETIO_PKT_HANDLE_NONE,
+   *  this vector entry will be skipped and no packet will be transmitted. */
+  netio_pkt_handle_t handle;
+}
+netio_pkt_vector_entry_t;
+
+
+/**
+ * @brief Initialize fields in a packet vector entry.
+ *
+ * @ingroup egress
+ *
+ * @param[out] v Pointer to the vector entry to be initialized.
+ * @param[in] pkt Packet to be transmitted when the vector entry is passed to
+ *        netio_send_packet_vector().  Note that the packet's attributes
+ *        (e.g., its L2 offset and length) are captured at the time this
+ *        routine is called; subsequent changes in those attributes will not
+ *        be reflected in the packet which is actually transmitted.
+ *        Changes in the packet's contents, however, will be so reflected.
+ *        If this is NULL, no packet will be transmitted.
+ * @param[in] user_data User data to be set in the vector entry.
+ *        This function guarantees that the "user_data" field will become
+ *        visible to a reader only after all other fields have become visible.
+ *        This allows a structure in a ring buffer to be written and read
+ *        by a polling reader without any locks or other synchronization.
+ */
+static __inline void
+netio_pkt_vector_set(volatile netio_pkt_vector_entry_t* v, netio_pkt_t* pkt,
+                     uint8_t user_data)
+{
+  if (pkt)
+  {
+    if (NETIO_PKT_IS_MINIMAL(pkt))
+    {
+      netio_pkt_minimal_metadata_t* mmd =
+        (netio_pkt_minimal_metadata_t*) &pkt->__metadata;
+      v->buffer_address_low = (uintptr_t) NETIO_PKT_L2_DATA_MM(mmd, pkt) & 0xFF;
+      v->size = NETIO_PKT_L2_LENGTH_MM(mmd, pkt);
+    }
+    else
+    {
+      netio_pkt_metadata_t* mda = &pkt->__metadata;
+      v->buffer_address_low = (uintptr_t) NETIO_PKT_L2_DATA_M(mda, pkt) & 0xFF;
+      v->size = NETIO_PKT_L2_LENGTH_M(mda, pkt);
+    }
+    v->handle.word = pkt->__packet.word;
+  }
+  else
+  {
+    v->handle.word = 0;   /* Set handle to NETIO_PKT_HANDLE_NONE. */
+  }
+
+  __asm__("" : : : "memory");
+
+  v->user_data = user_data;
+}
+
+
+/**
+ * Flags and structures for @ref netio_get() and @ref netio_set().
+ * @ingroup config
+ */
+
+/** @{ */
+/** Parameter class; addr is a NETIO_PARAM_xxx value. */
+#define NETIO_PARAM       0
+/** Interface MAC address. This address is only valid with @ref netio_get().
+ *  The value is a 6-byte MAC address.  Depending upon the overall system
+ *  design, a MAC address may or may not be available for each interface. */
+#define NETIO_PARAM_MAC        0
+
+/** Determine whether to suspend output on the receipt of pause frames.
+ *  If the value is nonzero, the I/O shim will suspend output when a pause
+ *  frame is received.  If the value is zero, pause frames will be ignored. */
+#define NETIO_PARAM_PAUSE_IN   1
+
+/** Determine whether to send pause frames if the I/O shim packet FIFOs are
+ *  nearly full.  If the value is zero, pause frames are not sent.  If
+ *  the value is nonzero, it is the delay value which will be sent in any
+ *  pause frames which are output, in units of 512 bit times. */
+#define NETIO_PARAM_PAUSE_OUT  2
+
+/** Jumbo frame support.  The value is a 4-byte integer.  If the value is
+ *  nonzero, the MAC will accept frames of up to 10240 bytes.  If the value
+ *  is zero, the MAC will only accept frames of up to 1544 bytes. */
+#define NETIO_PARAM_JUMBO      3
+
+/** I/O shim's overflow statistics register.  The value is two 16-bit integers.
+ *  The first 16-bit value (or the low 16 bits, if the value is treated as a
+ *  32-bit number) is the count of packets which were completely dropped and
+ *  not delivered by the shim.  The second 16-bit value (or the high 16 bits,
+ *  if the value is treated as a 32-bit number) is the count of packets
+ *  which were truncated and thus only partially delivered by the shim.  This
+ *  register is automatically reset to zero after it has been read.
+ */
+#define NETIO_PARAM_OVERFLOW   4
+
+/** IPP statistics.  This address is only valid with @ref netio_get().  The
+ *  value is a netio_stat_t structure.  Unlike the I/O shim statistics, the
+ *  IPP statistics are not all reset to zero on read; see the description
+ *  of the netio_stat_t for details. */
+#define NETIO_PARAM_STAT 5
+
+/** Possible link state.  The value is a combination of "NETIO_LINK_xxx"
+ *  flags.  With @ref netio_get(), this will indicate which flags are
+ *  actually supported by the hardware.
+ *
+ *  For historical reasons, specifying this value to netio_set() will have
+ *  the same behavior as using ::NETIO_PARAM_LINK_CONFIG, but this usage is
+ *  discouraged.
+ */
+#define NETIO_PARAM_LINK_POSSIBLE_STATE 6
+
+/** Link configuration. The value is a combination of "NETIO_LINK_xxx" flags.
+ *  With @ref netio_set(), this will attempt to immediately bring up the
+ *  link using whichever of the requested flags are supported by the
+ *  hardware, or take down the link if the flags are zero; if this is
+ *  not possible, an error will be returned.  Many programs will want
+ *  to use ::NETIO_PARAM_LINK_DESIRED_STATE instead.
+ *
+ *  For historical reasons, specifying this value to netio_get() will
+ *  have the same behavior as using ::NETIO_PARAM_LINK_POSSIBLE_STATE,
+ *  but this usage is discouraged.
+ */
+#define NETIO_PARAM_LINK_CONFIG NETIO_PARAM_LINK_POSSIBLE_STATE
+
+/** Current link state. This address is only valid with @ref netio_get().
+ *  The value is zero or more of the "NETIO_LINK_xxx" flags, ORed together.
+ *  If the link is down, the value ANDed with NETIO_LINK_SPEED will be
+ *  zero; if the link is up, the value ANDed with NETIO_LINK_SPEED will
+ *  result in exactly one of the NETIO_LINK_xxx values, indicating the
+ *  current speed. */
+#define NETIO_PARAM_LINK_CURRENT_STATE 7
+
+/** Variant symbol for current state, retained for compatibility with
+ *  pre-MDE-2.1 programs. */
+#define NETIO_PARAM_LINK_STATUS NETIO_PARAM_LINK_CURRENT_STATE
+
+/** Packet Coherence protocol. This address is only valid with @ref netio_get().
+ *  The value is nonzero if the interface is configured for cache-coherent DMA.
+ */
+#define NETIO_PARAM_COHERENT 8
+
+/** Desired link state. The value is a conbination of "NETIO_LINK_xxx"
+ *  flags, which specify the desired state for the link.  With @ref
+ *  netio_set(), this will, in the background, attempt to bring up the link
+ *  using whichever of the requested flags are reasonable, or take down the
+ *  link if the flags are zero.  The actual link up or down operation may
+ *  happen after this call completes.  If the link state changes in the
+ *  future, the system will continue to try to get back to the desired link
+ *  state; for instance, if the link is brought up successfully, and then
+ *  the network cable is disconnected, the link will go down.  However, the
+ *  desired state of the link is still up, so if the cable is reconnected,
+ *  the link will be brought up again.
+ *
+ *  With @ref netio_get(), this will indicate the desired state for the
+ *  link, as set with a previous netio_set() call, or implicitly by a
+ *  netio_input_register() or netio_input_unregister() operation.  This may
+ *  not reflect the current state of the link; to get that, use
+ *  ::NETIO_PARAM_LINK_CURRENT_STATE. */
+#define NETIO_PARAM_LINK_DESIRED_STATE 9
+
+/** NetIO statistics structure.  Retrieved using the ::NETIO_PARAM_STAT
+ *  address passed to @ref netio_get(). */
+typedef struct
+{
+  /** Number of packets which have been received by the IPP and forwarded
+   *  to a tile's receive queue for processing.  This value wraps at its
+   *  maximum, and is not cleared upon read. */
+  uint32_t packets_received;
+
+  /** Number of packets which have been dropped by the IPP, because they could
+   *  not be received, or could not be forwarded to a tile.  The former happens
+   *  when the IPP does not have a free packet buffer of suitable size for an
+   *  incoming frame.  The latter happens when all potential destination tiles
+   *  for a packet, as defined by the group, bucket, and queue configuration,
+   *  have full receive queues.   This value wraps at its maximum, and is not
+   *  cleared upon read. */
+  uint32_t packets_dropped;
+
+  /*
+   * Note: the #defines after each of the following four one-byte values
+   * denote their location within the third word of the netio_stat_t.  They
+   * are intended for use only by the IPP implementation and are thus omitted
+   * from the Doxygen output.
+   */
+
+  /** Number of packets dropped because no worker was able to accept a new
+   *  packet.  This value saturates at its maximum, and is cleared upon
+   *  read. */
+  uint8_t drops_no_worker;
+#ifndef __DOXYGEN__
+#define NETIO_STAT_DROPS_NO_WORKER   0
+#endif
+
+  /** Number of packets dropped because no small buffers were available.
+   *  This value saturates at its maximum, and is cleared upon read. */
+  uint8_t drops_no_smallbuf;
+#ifndef __DOXYGEN__
+#define NETIO_STAT_DROPS_NO_SMALLBUF 1
+#endif
+
+  /** Number of packets dropped because no large buffers were available.
+   *  This value saturates at its maximum, and is cleared upon read. */
+  uint8_t drops_no_largebuf;
+#ifndef __DOXYGEN__
+#define NETIO_STAT_DROPS_NO_LARGEBUF 2
+#endif
+
+  /** Number of packets dropped because no jumbo buffers were available.
+   *  This value saturates at its maximum, and is cleared upon read. */
+  uint8_t drops_no_jumbobuf;
+#ifndef __DOXYGEN__
+#define NETIO_STAT_DROPS_NO_JUMBOBUF 3
+#endif
+}
+netio_stat_t;
+
+
+/** Link can run, should run, or is running at 10 Mbps. */
+#define NETIO_LINK_10M         0x01
+
+/** Link can run, should run, or is running at 100 Mbps. */
+#define NETIO_LINK_100M        0x02
+
+/** Link can run, should run, or is running at 1 Gbps. */
+#define NETIO_LINK_1G          0x04
+
+/** Link can run, should run, or is running at 10 Gbps. */
+#define NETIO_LINK_10G         0x08
+
+/** Link should run at the highest speed supported by the link and by
+ *  the device connected to the link.  Only usable as a value for
+ *  the link's desired state; never returned as a value for the current
+ *  or possible states. */
+#define NETIO_LINK_ANYSPEED    0x10
+
+/** All legal link speeds. */
+#define NETIO_LINK_SPEED  (NETIO_LINK_10M  | \
+                           NETIO_LINK_100M | \
+                           NETIO_LINK_1G   | \
+                           NETIO_LINK_10G  | \
+                           NETIO_LINK_ANYSPEED)
+
+
+/** MAC register class.  Addr is a register offset within the MAC.
+ *  Registers within the XGbE and GbE MACs are documented in the Tile
+ *  Processor I/O Device Guide (UG104). MAC registers start at address
+ *  0x4000, and do not include the MAC_INTERFACE registers. */
+#define NETIO_MAC             1
+
+/** MDIO register class (IEEE 802.3 clause 22 format).  Addr is the "addr"
+ *  member of a netio_mdio_addr_t structure. */
+#define NETIO_MDIO            2
+
+/** MDIO register class (IEEE 802.3 clause 45 format).  Addr is the "addr"
+ *  member of a netio_mdio_addr_t structure. */
+#define NETIO_MDIO_CLAUSE45   3
+
+/** NetIO MDIO address type.  Retrieved or provided using the ::NETIO_MDIO
+ *  address passed to @ref netio_get() or @ref netio_set(). */
+typedef union
+{
+  struct
+  {
+    unsigned int reg:16;  /**< MDIO register offset.  For clause 22 access,
+                               must be less than 32. */
+    unsigned int phy:5;   /**< Which MDIO PHY to access. */
+    unsigned int dev:5;   /**< Which MDIO device to access within that PHY.
+                               Applicable for clause 45 access only; ignored
+                               for clause 22 access. */
+  }
+  bits;                   /**< Container for bitfields. */
+  uint64_t addr;          /**< Value to pass to @ref netio_get() or
+                           *   @ref netio_set(). */
+}
+netio_mdio_addr_t;
+
+/** @} */
+
+#endif /* __NETIO_INTF_H__ */
diff --git a/arch/tile/mm/init.c b/arch/tile/mm/init.c
index 78e1982..0b9ce69 100644
--- a/arch/tile/mm/init.c
+++ b/arch/tile/mm/init.c
@@ -988,8 +988,12 @@ static long __write_once initfree = 1;
 /* Select whether to free (1) or mark unusable (0) the __init pages. */
 static int __init set_initfree(char *str)
 {
-	strict_strtol(str, 0, &initfree);
-	pr_info("initfree: %s free init pages\n", initfree ? "will" : "won't");
+	long val;
+	if (strict_strtol(str, 0, &val)) {
+		initfree = val;
+		pr_info("initfree: %s free init pages\n",
+			initfree ? "will" : "won't");
+	}
 	return 1;
 }
 __setup("initfree=", set_initfree);
diff --git a/drivers/net/Kconfig b/drivers/net/Kconfig
index f6668cd..43db398 100644
--- a/drivers/net/Kconfig
+++ b/drivers/net/Kconfig
@@ -2945,6 +2945,18 @@ source "drivers/s390/net/Kconfig"
 
 source "drivers/net/caif/Kconfig"
 
+config TILE_NET
+	tristate "Tilera GBE/XGBE network driver support"
+	depends on TILE
+	default y
+	select CRC32
+	help
+	  This is a standard Linux network device driver for the
+	  on-chip Tilera Gigabit Ethernet and XAUI interfaces.
+
+	  To compile this driver as a module, choose M here: the module
+	  will be called tile_net.
+
 config XEN_NETDEV_FRONTEND
 	tristate "Xen network device frontend driver"
 	depends on XEN
diff --git a/drivers/net/Makefile b/drivers/net/Makefile
index 652fc6b..b90738d 100644
--- a/drivers/net/Makefile
+++ b/drivers/net/Makefile
@@ -301,3 +301,4 @@ obj-$(CONFIG_CAIF) += caif/
 
 obj-$(CONFIG_OCTEON_MGMT_ETHERNET) += octeon/
 obj-$(CONFIG_PCH_GBE) += pch_gbe/
+obj-$(CONFIG_TILE_NET) += tile/
diff --git a/drivers/net/tile/Makefile b/drivers/net/tile/Makefile
new file mode 100644
index 0000000..f634f14
--- /dev/null
+++ b/drivers/net/tile/Makefile
@@ -0,0 +1,10 @@
+#
+# Makefile for the TILE on-chip networking support.
+#
+
+obj-$(CONFIG_TILE_NET) += tile_net.o
+ifdef CONFIG_TILEGX
+tile_net-objs := tilegx.o mpipe.o iorpc_mpipe.o dma_queue.o
+else
+tile_net-objs := tilepro.o
+endif
diff --git a/drivers/net/tile/tilepro.c b/drivers/net/tile/tilepro.c
new file mode 100644
index 0000000..5869b05
--- /dev/null
+++ b/drivers/net/tile/tilepro.c
@@ -0,0 +1,2452 @@
+/*
+ * Copyright 2010 Tilera Corporation. All Rights Reserved.
+ *
+ *   This program is free software; you can redistribute it and/or
+ *   modify it under the terms of the GNU General Public License
+ *   as published by the Free Software Foundation, version 2.
+ *
+ *   This program is distributed in the hope that it will be useful, but
+ *   WITHOUT ANY WARRANTY; without even the implied warranty of
+ *   MERCHANTABILITY OR FITNESS FOR A PARTICULAR PURPOSE, GOOD TITLE or
+ *   NON INFRINGEMENT.  See the GNU General Public License for
+ *   more details.
+ */
+
+#include <linux/module.h>
+#include <linux/init.h>
+#include <linux/moduleparam.h>
+#include <linux/sched.h>
+#include <linux/kernel.h>      /* printk() */
+#include <linux/slab.h>        /* kmalloc() */
+#include <linux/errno.h>       /* error codes */
+#include <linux/types.h>       /* size_t */
+#include <linux/interrupt.h>
+#include <linux/in.h>
+#include <linux/netdevice.h>   /* struct device, and other headers */
+#include <linux/etherdevice.h> /* eth_type_trans */
+#include <linux/skbuff.h>
+#include <linux/ioctl.h>
+#include <linux/cdev.h>
+#include <linux/hugetlb.h>
+#include <linux/in6.h>
+#include <linux/timer.h>
+#include <linux/io.h>
+#include <asm/checksum.h>
+#include <asm/homecache.h>
+
+#include <hv/drv_xgbe_intf.h>
+#include <hv/drv_xgbe_impl.h>
+#include <hv/hypervisor.h>
+#include <hv/netio_intf.h>
+
+/* For TSO */
+#include <linux/ip.h>
+#include <linux/tcp.h>
+
+
+/* There is no singlethread_cpu, so schedule work on the current cpu. */
+#define singlethread_cpu -1
+
+
+/*
+ * First, "tile_net_init_module()" initializes all four "devices" which
+ * can be used by linux.
+ *
+ * Then, "ifconfig DEVICE up" calls "tile_net_open()", which analyzes
+ * the network cpus, then uses "tile_net_open_aux()" to initialize
+ * LIPP/LEPP, and then uses "tile_net_open_inner()" to register all
+ * the tiles, provide buffers to LIPP, allow ingress to start, and
+ * turn on hypervisor interrupt handling (and NAPI) on all tiles.
+ *
+ * If registration fails due to the link being down, then "retry_work"
+ * is used to keep calling "tile_net_open_inner()" until it succeeds.
+ *
+ * If "ifconfig DEVICE down" is called, it uses "tile_net_stop()" to
+ * stop egress, drain the LIPP buffers, unregister all the tiles, stop
+ * LIPP/LEPP, and wipe the LEPP queue.
+ *
+ * We start out with the ingress interrupt enabled on each CPU.  When
+ * this interrupt fires, we disable it, and call "napi_schedule()".
+ * This will cause "tile_net_poll()" to be called, which will pull
+ * packets from the netio queue, filtering them out, or passing them
+ * to "netif_receive_skb()".  If our budget is exhausted, we will
+ * return, knowing we will be called again later.  Otherwise, we
+ * reenable the ingress interrupt, and call "napi_complete()".
+ *
+ *
+ * NOTE: The use of "native_driver" ensures that EPP exists, and that
+ * "epp_sendv" is legal, and that "LIPP" is being used.
+ *
+ * NOTE: Failing to free completions for an arbitrarily long time
+ * (which is defined to be illegal) does in fact cause bizarre
+ * problems.  The "egress_timer" helps prevent this from happening.
+ *
+ * NOTE: The egress code can be interrupted by the interrupt handler.
+ */
+
+
+/* HACK: Allow use of "jumbo" packets. */
+/* This should be 1500 if "jumbo" is not set in LIPP. */
+/* This should be at most 10226 (10240 - 14) if "jumbo" is set in LIPP. */
+/* ISSUE: This has not been thoroughly tested (except at 1500). */
+#define TILE_NET_MTU 1500
+
+/* HACK: Define to support GSO. */
+/* ISSUE: This may actually hurt performance of the TCP blaster. */
+/* #define TILE_NET_GSO */
+
+/* Define this to collapse "duplicate" acks. */
+/* #define IGNORE_DUP_ACKS */
+
+/* HACK: Define this to verify incoming packets. */
+/* #define TILE_NET_VERIFY_INGRESS */
+
+/* Use 3000 to enable the Linux Traffic Control (QoS) layer, else 0. */
+#define TILE_NET_TX_QUEUE_LEN 0
+
+/* Define to dump packets (prints out the whole packet on tx and rx). */
+/* #define TILE_NET_DUMP_PACKETS */
+
+/* Define to enable debug spew (all PDEBUG's are enabled). */
+/* #define TILE_NET_DEBUG */
+
+
+/* Define to activate paranoia checks. */
+/* #define TILE_NET_PARANOIA */
+
+/* Default transmit lockup timeout period, in jiffies. */
+#define TILE_NET_TIMEOUT (5 * HZ)
+
+/* Default retry interval for bringing up the NetIO interface, in jiffies. */
+#define TILE_NET_RETRY_INTERVAL (5 * HZ)
+
+/* Number of ports (xgbe0, xgbe1, gbe0, gbe1). */
+#define TILE_NET_DEVS 4
+
+
+
+/* Paranoia. */
+#if NET_IP_ALIGN != LIPP_PACKET_PADDING
+#error "NET_IP_ALIGN must match LIPP_PACKET_PADDING."
+#endif
+
+
+/* Debug print. */
+#ifdef TILE_NET_DEBUG
+#define PDEBUG(fmt, args...) net_printk(fmt, ## args)
+#else
+#define PDEBUG(fmt, args...)
+#endif
+
+
+MODULE_AUTHOR("Tilera");
+MODULE_LICENSE("GPL");
+
+
+#define IS_MULTICAST(mac_addr) \
+	(((uint8_t *)(mac_addr))[0] & 0x01)
+
+#define IS_BROADCAST(mac_addr) \
+	(((uint16_t *)(mac_addr))[0] == 0xffff)
+
+
+/* ISSUE: In "sys/hv", we check "CHIP_HAS_REV1_DMA_PACKETS()". */
+#if CHIP_HAS_CBOX_HOME_MAP()
+#define HASH_DEFAULT hash_default
+#else
+#define HASH_DEFAULT 0
+#endif
+
+
+/*
+ * Queue of incoming packets for a specific cpu and device.
+ *
+ * Includes a pointer to the "system" data, and the actual "user" data.
+ */
+struct tile_netio_queue {
+	netio_queue_impl_t *__system_part;
+	netio_queue_user_impl_t __user_part;
+
+};
+
+
+/*
+ * Statistics counters for a specific cpu and device.
+ */
+struct tile_net_stats_t {
+	uint32_t rx_packets;
+	uint32_t rx_bytes;
+	uint32_t tx_packets;
+	uint32_t tx_bytes;
+};
+
+
+/*
+ * Info for a specific cpu and device.
+ *
+ * ISSUE: There is a "dev" pointer in "napi" as well.
+ */
+struct tile_net_cpu {
+	/* The NAPI struct. */
+	struct napi_struct napi;
+	/* Packet queue. */
+	struct tile_netio_queue queue;
+	/* Statistics. */
+	struct tile_net_stats_t stats;
+	/* ISSUE: Is this needed? */
+	bool napi_enabled;
+	/* True if this tile has succcessfully registered with the IPP. */
+	bool registered;
+	/* True if the link was down last time we tried to register. */
+	bool link_down;
+	/* True if "egress_timer" is scheduled. */
+	bool egress_timer_scheduled;
+	/* Number of small sk_buffs which must still be provided. */
+	unsigned int num_needed_small_buffers;
+	/* Number of large sk_buffs which must still be provided. */
+	unsigned int num_needed_large_buffers;
+	/* A timer for handling egress completions. */
+	struct timer_list egress_timer;
+};
+
+
+/*
+ * Info for a specific device.
+ */
+struct tile_net_priv {
+	/* Our network device. */
+	struct net_device *dev;
+	/* The actual egress queue. */
+	lepp_queue_t *epp_queue;
+	/* Protects "epp_queue->cmd_tail" and "epp_queue->comp_tail" */
+	spinlock_t cmd_lock;
+	/* Protects "epp_queue->comp_head". */
+	spinlock_t comp_lock;
+	/* The hypervisor handle for this interface. */
+	int hv_devhdl;
+	/* The intr bit mask that IDs this device. */
+	uint32_t intr_id;
+	/* True iff "tile_net_open_aux()" has succeeded. */
+	int partly_opened;
+	/* True iff "tile_net_open_inner()" has succeeded. */
+	int fully_opened;
+	/* Effective network cpus. */
+	struct cpumask network_cpus_map;
+	/* Number of network cpus. */
+	int network_cpus_count;
+	/* Credits per network cpu. */
+	int network_cpus_credits;
+	/* Network stats. */
+	struct net_device_stats stats;
+	/* For NetIO bringup retries. */
+	struct delayed_work retry_work;
+	/* Quick access to per cpu data. */
+	struct tile_net_cpu *cpu[NR_CPUS];
+};
+
+
+/*
+ * The actual devices (xgbe0, xgbe1, gbe0, gbe1).
+ */
+static struct net_device *tile_net_devs[TILE_NET_DEVS];
+
+/*
+ * The "tile_net_cpu" structures for each device.
+ */
+static DEFINE_PER_CPU(struct tile_net_cpu, hv_xgbe0);
+static DEFINE_PER_CPU(struct tile_net_cpu, hv_xgbe1);
+static DEFINE_PER_CPU(struct tile_net_cpu, hv_gbe0);
+static DEFINE_PER_CPU(struct tile_net_cpu, hv_gbe1);
+
+
+/*
+ * True if "network_cpus" was specified.
+ */
+static bool network_cpus_used;
+
+/*
+ * The actual cpus in "network_cpus".
+ */
+static struct cpumask network_cpus_map;
+
+
+
+#ifdef TILE_NET_DEBUG
+/*
+ * printk with extra stuff.
+ *
+ * We print the CPU we're running in brackets.
+ */
+static void net_printk(char *fmt, ...)
+{
+	int i;
+	int len;
+	va_list args;
+	static char buf[256];
+
+	len = sprintf(buf, "tile_net[%2.2d]: ", smp_processor_id());
+	va_start(args, fmt);
+	i = vscnprintf(buf + len, sizeof(buf) - len - 1, fmt, args);
+	va_end(args);
+	buf[255] = '\0';
+	pr_notice(buf);
+}
+#endif
+
+
+#ifdef TILE_NET_DUMP_PACKETS
+/*
+ * Dump a packet.
+ */
+static void dump_packet(unsigned char *data, unsigned long length, char *s)
+{
+	unsigned long i;
+	static unsigned int count;
+
+	pr_info("dump_packet(data %p, length 0x%lx s %s count 0x%x)\n",
+	       data, length, s, count++);
+
+	pr_info("\n");
+
+	for (i = 0; i < length; i++) {
+		if ((i & 0xf) == 0)
+			sprintf(buf, "%8.8lx:", i);
+		sprintf(buf + strlen(buf), " %2.2x", data[i]);
+		if ((i & 0xf) == 0xf || i == length - 1)
+			pr_info("%s\n", buf);
+	}
+}
+#endif
+
+
+/*
+ * Provide support for the __netio_fastio1() swint
+ * (see <hv/drv_xgbe_intf.h> for how it is used).
+ *
+ * The fastio swint2 call may clobber all the caller-saved registers.
+ * It rarely clobbers memory, but we allow for the possibility in
+ * the signature just to be on the safe side.
+ *
+ * Also, gcc doesn't seem to allow an input operand to be
+ * clobbered, so we fake it with dummy outputs.
+ *
+ * This function can't be static because of the way it is declared
+ * in the netio header.
+ */
+inline int __netio_fastio1(uint32_t fastio_index, uint32_t arg0)
+{
+	long result, clobber_r1, clobber_r10;
+	asm volatile("swint2"
+		     : "=R00" (result),
+		       "=R01" (clobber_r1), "=R10" (clobber_r10)
+		     : "R10" (fastio_index), "R01" (arg0)
+		     : "memory", "r2", "r3", "r4",
+		       "r5", "r6", "r7", "r8", "r9",
+		       "r11", "r12", "r13", "r14",
+		       "r15", "r16", "r17", "r18", "r19",
+		       "r20", "r21", "r22", "r23", "r24",
+		     "r25", "r26", "r27", "r28", "r29");
+	return result;
+}
+
+
+/*
+ * Provide a linux buffer to LIPP.
+ */
+static void tile_net_provide_linux_buffer(struct tile_net_cpu *info,
+					  void *va, bool small)
+{
+	struct tile_netio_queue *queue = &info->queue;
+
+	/* Convert "va" and "small" to "linux_buffer_t". */
+	unsigned int buffer = ((unsigned int)(__pa(va) >> 7) << 1) + small;
+
+	__netio_fastio_free_buffer(queue->__user_part.__fastio_index, buffer);
+}
+
+
+/*
+ * Provide a linux buffer for LIPP.
+ */
+static bool tile_net_provide_needed_buffer(struct tile_net_cpu *info,
+					   bool small)
+{
+	/* ISSUE: What should we use here? */
+	unsigned int large_size = NET_IP_ALIGN + TILE_NET_MTU + 100;
+
+	/* Round up to ensure to avoid "false sharing" with last cache line. */
+	unsigned int buffer_size =
+		 (((small ? LIPP_SMALL_PACKET_SIZE : large_size) +
+		   CHIP_L2_LINE_SIZE() - 1) & -CHIP_L2_LINE_SIZE());
+
+	/*
+	 * ISSUE: Since CPAs are 38 bits, and we can only encode the
+	 * high 31 bits in a "linux_buffer_t", the low 7 bits must be
+	 * zero, and thus, we must align the actual "va" mod 128.
+	 */
+	const unsigned long align = 128;
+
+	struct sk_buff *skb;
+	void *va;
+
+	struct sk_buff **skb_ptr;
+
+	/* Note that "dev_alloc_skb()" adds NET_SKB_PAD more bytes, */
+	/* and also "reserves" that many bytes. */
+	/* ISSUE: Can we "share" the NET_SKB_PAD bytes with "skb_ptr"? */
+	int len = sizeof(*skb_ptr) + align + buffer_size;
+
+	while (1) {
+
+		/* Allocate (or fail). */
+		skb = dev_alloc_skb(len);
+		if (skb == NULL)
+			return false;
+
+		/* Make room for a back-pointer to 'skb'. */
+		skb_reserve(skb, sizeof(*skb_ptr));
+
+		/* Make sure we are aligned. */
+		skb_reserve(skb, -(long)skb->data & (align - 1));
+
+		/* This address is given to IPP. */
+		va = skb->data;
+
+		if (small)
+			break;
+
+		/* ISSUE: This has never been observed! */
+		/* Large buffers must not span a huge page. */
+		if (((((long)va & ~HPAGE_MASK) + 1535) & HPAGE_MASK) == 0)
+			break;
+		pr_err("Leaking unaligned linux buffer at %p.\n", va);
+	}
+
+	/* Skip two bytes to satisfy LIPP assumptions. */
+	/* Note that this aligns IP on a 16 byte boundary. */
+	/* ISSUE: Do this when the packet arrives? */
+	skb_reserve(skb, NET_IP_ALIGN);
+
+	/* Save a back-pointer to 'skb'. */
+	skb_ptr = va - sizeof(*skb_ptr);
+	*skb_ptr = skb;
+
+	/* Invalidate the packet buffer. */
+	if (!HASH_DEFAULT)
+		__inv_buffer(skb->data, buffer_size);
+
+	/* Make sure "skb_ptr" has been flushed. */
+	__insn_mf();
+
+#ifdef TILE_NET_PARANOIA
+#if CHIP_HAS_CBOX_HOME_MAP()
+	if (hash_default) {
+		HV_PTE pte = *virt_to_pte(current->mm, (unsigned long)va);
+		if (hv_pte_get_mode(pte) != HV_PTE_MODE_CACHE_HASH_L3)
+			panic("Non-coherent ingress buffer!");
+	}
+#endif
+#endif
+
+	/* Provide the new buffer. */
+	tile_net_provide_linux_buffer(info, va, small);
+
+	return true;
+}
+
+
+/*
+ * Provide linux buffers for LIPP.
+ */
+static void tile_net_provide_needed_buffers(struct tile_net_cpu *info)
+{
+	while (info->num_needed_small_buffers != 0) {
+		if (!tile_net_provide_needed_buffer(info, true))
+			goto oops;
+		info->num_needed_small_buffers--;
+	}
+
+	while (info->num_needed_large_buffers != 0) {
+		if (!tile_net_provide_needed_buffer(info, false))
+			goto oops;
+		info->num_needed_large_buffers--;
+	}
+
+	return;
+
+oops:
+
+	/* Add a description to the page allocation failure dump. */
+	pr_notice("Could not provide a linux buffer to LIPP.\n");
+}
+
+
+/*
+ * Grab some LEPP completions, and store them in "comps", of size
+ * "comps_size", and return the number of completions which were
+ * stored, so the caller can free them.
+ *
+ * If "pending" is not NULL, it will be set to true if there might
+ * still be some pending completions caused by this tile, else false.
+ */
+static unsigned int tile_net_lepp_grab_comps(struct net_device *dev,
+					     struct sk_buff *comps[],
+					     unsigned int comps_size,
+					     bool *pending)
+{
+	struct tile_net_priv *priv = netdev_priv(dev);
+
+	lepp_queue_t *eq = priv->epp_queue;
+
+	unsigned int n = 0;
+
+	unsigned int comp_head;
+	unsigned int comp_busy;
+	unsigned int comp_tail;
+
+	spin_lock(&priv->comp_lock);
+
+	comp_head = eq->comp_head;
+	comp_busy = eq->comp_busy;
+	comp_tail = eq->comp_tail;
+
+	while (comp_head != comp_busy && n < comps_size) {
+		comps[n++] = eq->comps[comp_head];
+		LEPP_QINC(comp_head);
+	}
+
+	if (pending != NULL)
+		*pending = (comp_head != comp_tail);
+
+	eq->comp_head = comp_head;
+
+	spin_unlock(&priv->comp_lock);
+
+	return n;
+}
+
+
+/*
+ * Make sure the egress timer is scheduled.
+ *
+ * Note that we use "schedule if not scheduled" logic instead of the more
+ * obvious "reschedule" logic, because "reschedule" is fairly expensive.
+ */
+static void tile_net_schedule_egress_timer(struct tile_net_cpu *info)
+{
+	if (!info->egress_timer_scheduled) {
+		mod_timer_pinned(&info->egress_timer, jiffies + 1);
+		info->egress_timer_scheduled = true;
+	}
+}
+
+
+/*
+ * The "function" for "info->egress_timer".
+ *
+ * This timer will reschedule itself as long as there are any pending
+ * completions expected (on behalf of any tile).
+ *
+ * ISSUE: Realistically, will the timer ever stop scheduling itself?
+ *
+ * ISSUE: This timer is almost never actually needed, so just use a global
+ * timer that can run on any tile.
+ *
+ * ISSUE: Maybe instead track number of expected completions, and free
+ * only that many, resetting to zero if "pending" is ever false.
+ */
+static void tile_net_handle_egress_timer(unsigned long arg)
+{
+	struct tile_net_cpu *info = (struct tile_net_cpu *)arg;
+	struct net_device *dev = info->napi.dev;
+
+	struct sk_buff *olds[32];
+	unsigned int wanted = 32;
+	unsigned int i, nolds = 0;
+	bool pending;
+
+	/* The timer is no longer scheduled. */
+	info->egress_timer_scheduled = false;
+
+	nolds = tile_net_lepp_grab_comps(dev, olds, wanted, &pending);
+
+	for (i = 0; i < nolds; i++)
+		kfree_skb(olds[i]);
+
+	/* Reschedule timer if needed. */
+	if (pending)
+		tile_net_schedule_egress_timer(info);
+}
+
+
+#ifdef IGNORE_DUP_ACKS
+
+/*
+ * Help detect "duplicate" ACKs.  These are sequential packets (for a
+ * given flow) which are exactly 66 bytes long, sharing everything but
+ * ID=2@0x12, Hsum=2@0x18, Ack=4@0x2a, WinSize=2@0x30, Csum=2@0x32,
+ * Tstamps=10@0x38.  The ID's are +1, the Hsum's are -1, the Ack's are
+ * +N, and the Tstamps are usually identical.
+ *
+ * NOTE: Apparently truly duplicate acks (with identical "ack" values),
+ * should not be collapsed, as they are used for some kind of flow control.
+ */
+static bool is_dup_ack(char *s1, char *s2, unsigned int len)
+{
+	int i;
+
+	unsigned long long ignorable = 0;
+
+	/* Identification. */
+	ignorable |= (1ULL << 0x12);
+	ignorable |= (1ULL << 0x13);
+
+	/* Header checksum. */
+	ignorable |= (1ULL << 0x18);
+	ignorable |= (1ULL << 0x19);
+
+	/* ACK. */
+	ignorable |= (1ULL << 0x2a);
+	ignorable |= (1ULL << 0x2b);
+	ignorable |= (1ULL << 0x2c);
+	ignorable |= (1ULL << 0x2d);
+
+	/* WinSize. */
+	ignorable |= (1ULL << 0x30);
+	ignorable |= (1ULL << 0x31);
+
+	/* Checksum. */
+	ignorable |= (1ULL << 0x32);
+	ignorable |= (1ULL << 0x33);
+
+	for (i = 0; i < len; i++, ignorable >>= 1) {
+
+		if ((ignorable & 1) || (s1[i] == s2[i]))
+			continue;
+
+#ifdef TILE_NET_DEBUG
+		/* HACK: Mention non-timestamp diffs. */
+		if (i < 0x38 && i != 0x2f &&
+		    net_ratelimit())
+			pr_info("Diff at 0x%x\n", i);
+#endif
+
+		return false;
+	}
+
+#ifdef TILE_NET_NO_SUPPRESS_DUP_ACKS
+	/* HACK: Do not suppress truly duplicate ACKs. */
+	/* ISSUE: Is this actually necessary or helpful? */
+	if (s1[0x2a] == s2[0x2a] &&
+	    s1[0x2b] == s2[0x2b] &&
+	    s1[0x2c] == s2[0x2c] &&
+	    s1[0x2d] == s2[0x2d]) {
+		return false;
+	}
+#endif
+
+	return true;
+}
+
+#endif
+
+
+
+/*
+ * Like "tile_net_handle_packets()", but just discard packets.
+ */
+static void tile_net_discard_packets(struct net_device *dev)
+{
+	struct tile_net_priv *priv = netdev_priv(dev);
+	int my_cpu = smp_processor_id();
+	struct tile_net_cpu *info = priv->cpu[my_cpu];
+	struct tile_netio_queue *queue = &info->queue;
+	netio_queue_impl_t *qsp = queue->__system_part;
+	netio_queue_user_impl_t *qup = &queue->__user_part;
+
+	while (qup->__packet_receive_read !=
+	       qsp->__packet_receive_queue.__packet_write) {
+
+		int index = qup->__packet_receive_read;
+
+		int index2_aux = index + sizeof(netio_pkt_t);
+		int index2 =
+			((index2_aux ==
+			  qsp->__packet_receive_queue.__last_packet_plus_one) ?
+			 0 : index2_aux);
+
+		netio_pkt_t *pkt = (netio_pkt_t *)
+			((unsigned long) &qsp[1] + index);
+
+		/* Extract the "linux_buffer_t". */
+		unsigned int buffer = pkt->__packet.word;
+
+		/* Convert "linux_buffer_t" to "va". */
+		void *va = __va((phys_addr_t)(buffer >> 1) << 7);
+
+		/* Acquire the associated "skb". */
+		struct sk_buff **skb_ptr = va - sizeof(*skb_ptr);
+		struct sk_buff *skb = *skb_ptr;
+
+		kfree_skb(skb);
+
+		/* Consume this packet. */
+		qup->__packet_receive_read = index2;
+	}
+}
+
+
+/*
+ * Handle the next packet.  Return true if "processed", false if "filtered".
+ */
+static bool tile_net_poll_aux(struct tile_net_cpu *info, int index)
+{
+	struct net_device *dev = info->napi.dev;
+
+	struct tile_netio_queue *queue = &info->queue;
+	netio_queue_impl_t *qsp = queue->__system_part;
+	netio_queue_user_impl_t *qup = &queue->__user_part;
+	struct tile_net_stats_t *stats = &info->stats;
+
+	int filter;
+
+	int index2_aux = index + sizeof(netio_pkt_t);
+	int index2 =
+		((index2_aux ==
+		  qsp->__packet_receive_queue.__last_packet_plus_one) ?
+		 0 : index2_aux);
+
+	netio_pkt_t *pkt = (netio_pkt_t *)((unsigned long) &qsp[1] + index);
+
+	netio_pkt_metadata_t *metadata = NETIO_PKT_METADATA(pkt);
+
+	/* Extract the packet size. */
+	unsigned long len =
+		(NETIO_PKT_CUSTOM_LENGTH(pkt) +
+		 NET_IP_ALIGN - NETIO_PACKET_PADDING);
+
+	/* Extract the "linux_buffer_t". */
+	unsigned int buffer = pkt->__packet.word;
+
+	/* Extract "small" (vs "large"). */
+	bool small = ((buffer & 1) != 0);
+
+	/* Convert "linux_buffer_t" to "va". */
+	void *va = __va((phys_addr_t)(buffer >> 1) << 7);
+
+	/* Extract the packet data pointer. */
+	/* Compare to "NETIO_PKT_CUSTOM_DATA(pkt)". */
+	unsigned char *buf = va + NET_IP_ALIGN;
+
+#ifdef IGNORE_DUP_ACKS
+
+	static int other;
+	static int final;
+	static int keep;
+	static int skip;
+
+#endif
+
+	/* Invalidate the packet buffer. */
+	if (!HASH_DEFAULT)
+		__inv_buffer(buf, len);
+
+	/* ISSUE: Is this needed? */
+	dev->last_rx = jiffies;
+
+#ifdef TILE_NET_DUMP_PACKETS
+	dump_packet(buf, len, "rx");
+#endif /* TILE_NET_DUMP_PACKETS */
+
+#ifdef TILE_NET_VERIFY_INGRESS
+	if (!NETIO_PKT_L4_CSUM_CORRECT_M(metadata, pkt) &&
+	    NETIO_PKT_L4_CSUM_CALCULATED_M(metadata, pkt)) {
+		/*
+		 * FIXME: This complains about UDP packets
+		 * with a "zero" checksum (bug 6624).
+		 */
+#ifdef TILE_NET_PANIC_ON_BAD
+		dump_packet(buf, len, "rx");
+		panic("Bad L4 checksum.");
+#else
+		pr_warning("Bad L4 checksum on %d byte packet.\n", len);
+#endif
+	}
+	if (!NETIO_PKT_L3_CSUM_CORRECT_M(metadata, pkt) &&
+	    NETIO_PKT_L3_CSUM_CALCULATED_M(metadata, pkt)) {
+		dump_packet(buf, len, "rx");
+		panic("Bad L3 checksum.");
+	}
+	switch (NETIO_PKT_STATUS_M(metadata, pkt)) {
+	case NETIO_PKT_STATUS_OVERSIZE:
+		if (len >= 64) {
+			dump_packet(buf, len, "rx");
+			panic("Unexpected OVERSIZE.");
+		}
+		break;
+	case NETIO_PKT_STATUS_BAD:
+#ifdef TILE_NET_PANIC_ON_BAD
+		dump_packet(buf, len, "rx");
+		panic("Unexpected BAD packet.");
+#else
+		pr_warning("Unexpected BAD %d byte packet.\n", len);
+#endif
+	}
+#endif
+
+	filter = 0;
+
+	if (!(dev->flags & IFF_UP)) {
+		/* Filter packets received before we're up. */
+		filter = 1;
+	} else if (!(dev->flags & IFF_PROMISC)) {
+		/*
+		 * FIXME: Implement HW multicast filter.
+		 */
+		if (!IS_MULTICAST(buf) && !IS_BROADCAST(buf)) {
+			/* Filter packets not for our address. */
+			const u8 *mine = dev->dev_addr;
+			filter = compare_ether_addr(mine, buf);
+		}
+	}
+
+#ifdef IGNORE_DUP_ACKS
+
+	if (len != 66) {
+		/* FIXME: Must check "is_tcp_ack(buf, len)" somehow. */
+
+		other++;
+
+	} else if (index2 ==
+		   qsp->__packet_receive_queue.__packet_write) {
+
+		final++;
+
+	} else {
+
+		netio_pkt_t *pkt2 = (netio_pkt_t *)
+			((unsigned long) &qsp[1] + index2);
+
+		netio_pkt_metadata_t *metadata2 =
+			NETIO_PKT_METADATA(pkt2);
+
+		/* Extract the packet size. */
+		unsigned long len2 =
+			(NETIO_PKT_CUSTOM_LENGTH(pkt2) +
+			 NET_IP_ALIGN - NETIO_PACKET_PADDING);
+
+		if (len2 == 66 &&
+		    NETIO_PKT_FLOW_HASH_M(metadata, pkt) ==
+		    NETIO_PKT_FLOW_HASH_M(metadata2, pkt2)) {
+
+			/* Extract the "linux_buffer_t". */
+			unsigned int buffer2 = pkt2->__packet.word;
+
+			/* Convert "linux_buffer_t" to "va". */
+			void *va2 =
+				__va((phys_addr_t)(buffer2 >> 1) << 7);
+
+			/* Extract the packet data pointer. */
+			/* Compare to "NETIO_PKT_CUSTOM_DATA(pkt)". */
+			unsigned char *buf2 = va2 + NET_IP_ALIGN;
+
+			/* Invalidate the packet buffer. */
+			if (!HASH_DEFAULT)
+				__inv_buffer(buf2, len2);
+
+			if (is_dup_ack(buf, buf2, len)) {
+				skip++;
+				filter = 1;
+			} else {
+				keep++;
+			}
+		}
+	}
+
+	if (net_ratelimit())
+		pr_info("Other %d Final %d Keep %d Skip %d.\n",
+			other, final, keep, skip);
+
+#endif
+
+	if (filter) {
+
+		/* ISSUE: Update "drop" statistics? */
+
+		tile_net_provide_linux_buffer(info, va, small);
+
+	} else {
+
+		/* Acquire the associated "skb". */
+		struct sk_buff **skb_ptr = va - sizeof(*skb_ptr);
+		struct sk_buff *skb = *skb_ptr;
+
+		/* Paranoia. */
+		if (skb->data != buf)
+			panic("Corrupt linux buffer from LIPP! "
+			      "VA=%p, skb=%p, skb->data=%p\n",
+			      va, skb, skb->data);
+
+		/* Encode the actual packet length. */
+		skb_put(skb, len);
+
+		/* NOTE: This call also sets "skb->dev = dev". */
+		skb->protocol = eth_type_trans(skb, dev);
+
+		/* ISSUE: Discard corrupt packets? */
+		/* ISSUE: Discard packets with bad checksums? */
+
+		/* Avoid recomputing TCP/UDP checksums. */
+		if (NETIO_PKT_L4_CSUM_CORRECT_M(metadata, pkt))
+			skb->ip_summed = CHECKSUM_UNNECESSARY;
+
+		netif_receive_skb(skb);
+
+		stats->rx_packets++;
+		stats->rx_bytes += len;
+
+		if (small)
+			info->num_needed_small_buffers++;
+		else
+			info->num_needed_large_buffers++;
+	}
+
+	/* Return four credits after every fourth packet. */
+	if (--qup->__receive_credit_remaining == 0) {
+		uint32_t interval = qup->__receive_credit_interval;
+		qup->__receive_credit_remaining = interval;
+		__netio_fastio_return_credits(qup->__fastio_index, interval);
+	}
+
+	/* Consume this packet. */
+	qup->__packet_receive_read = index2;
+
+	return !filter;
+}
+
+
+/*
+ * Handle some packets for the given device on the current CPU.
+ *
+ * ISSUE: The "rotting packet" race condition occurs if a packet
+ * arrives after the queue appears to be empty, and before the
+ * hypervisor interrupt is re-enabled.
+ */
+static int tile_net_poll(struct napi_struct *napi, int budget)
+{
+	struct net_device *dev = napi->dev;
+	struct tile_net_priv *priv = netdev_priv(dev);
+	int my_cpu = smp_processor_id();
+	struct tile_net_cpu *info = priv->cpu[my_cpu];
+	struct tile_netio_queue *queue = &info->queue;
+	netio_queue_impl_t *qsp = queue->__system_part;
+	netio_queue_user_impl_t *qup = &queue->__user_part;
+
+	unsigned int work = 0;
+
+	while (1) {
+		int index = qup->__packet_receive_read;
+		if (index == qsp->__packet_receive_queue.__packet_write)
+			break;
+
+		if (tile_net_poll_aux(info, index)) {
+			if (++work >= budget)
+				goto done;
+		}
+	}
+
+	napi_complete(&info->napi);
+
+	/* Re-enable hypervisor interrupts. */
+	enable_percpu_irq(priv->intr_id);
+
+	/* HACK: Avoid the "rotting packet" problem. */
+	if (qup->__packet_receive_read !=
+	    qsp->__packet_receive_queue.__packet_write)
+		napi_schedule(&info->napi);
+
+	/* ISSUE: Handle completions? */
+
+done:
+
+	tile_net_provide_needed_buffers(info);
+
+	return work;
+}
+
+
+/*
+ * Handle an ingress interrupt for the given device on the current cpu.
+ */
+static irqreturn_t tile_net_handle_ingress_interrupt(int irq, void *dev_ptr)
+{
+	struct net_device *dev = (struct net_device *)dev_ptr;
+	struct tile_net_priv *priv = netdev_priv(dev);
+	int my_cpu = smp_processor_id();
+	struct tile_net_cpu *info = priv->cpu[my_cpu];
+
+	/* Disable hypervisor interrupt. */
+	disable_percpu_irq(priv->intr_id);
+
+	napi_schedule(&info->napi);
+
+	return IRQ_HANDLED;
+}
+
+
+/*
+ * One time initialization per interface.
+ */
+static int tile_net_open_aux(struct net_device *dev)
+{
+	struct tile_net_priv *priv = netdev_priv(dev);
+
+	int ret;
+	int dummy;
+	unsigned int epp_lotar;
+
+	/*
+	 * Find out where EPP memory should be homed.
+	 */
+	ret = hv_dev_pread(priv->hv_devhdl, 0,
+			   (HV_VirtAddr)&epp_lotar, sizeof(epp_lotar),
+			   NETIO_EPP_SHM_OFF);
+	if (ret < 0) {
+		pr_err("could not read epp_shm_queue lotar.\n");
+		return -EIO;
+	}
+
+	/*
+	 * Home the page on the EPP.
+	 */
+	{
+		int epp_home = hv_lotar_to_cpu(epp_lotar);
+		struct page *page = virt_to_page(priv->epp_queue);
+		homecache_change_page_home(page, 0, epp_home);
+	}
+
+	/*
+	 * Register the EPP shared memory queue.
+	 */
+	{
+		netio_ipp_address_t ea = {
+			.va = 0,
+			.pa = __pa(priv->epp_queue),
+			.pte = hv_pte(0),
+			.size = PAGE_SIZE,
+		};
+		ea.pte = hv_pte_set_lotar(ea.pte, epp_lotar);
+		ea.pte = hv_pte_set_mode(ea.pte, HV_PTE_MODE_CACHE_TILE_L3);
+		ret = hv_dev_pwrite(priv->hv_devhdl, 0,
+				    (HV_VirtAddr)&ea,
+				    sizeof(ea),
+				    NETIO_EPP_SHM_OFF);
+		if (ret < 0)
+			return -EIO;
+	}
+
+	/*
+	 * Start LIPP/LEPP.
+	 */
+	if (hv_dev_pwrite(priv->hv_devhdl, 0, (HV_VirtAddr)&dummy,
+			  sizeof(dummy), NETIO_IPP_START_SHIM_OFF) < 0) {
+		pr_warning("Failed to start LIPP/LEPP.\n");
+		return -EIO;
+	}
+
+	return 0;
+}
+
+
+/*
+ * Register with hypervisor on each CPU.
+ *
+ * Strangely, this function does important things even if it "fails",
+ * which is especially common if the link is not up yet.  Hopefully
+ * these things are all "harmless" if done twice!
+ */
+static void tile_net_register(void *dev_ptr)
+{
+	struct net_device *dev = (struct net_device *)dev_ptr;
+	struct tile_net_priv *priv = netdev_priv(dev);
+	int my_cpu = smp_processor_id();
+	struct tile_net_cpu *info;
+
+	struct tile_netio_queue *queue;
+
+	/* Only network cpus can receive packets. */
+	int queue_id =
+		cpumask_test_cpu(my_cpu, &priv->network_cpus_map) ? 0 : 255;
+
+	netio_input_config_t config = {
+		.flags = 0,
+		.num_receive_packets = priv->network_cpus_credits,
+		.queue_id = queue_id
+	};
+
+	int ret = 0;
+	netio_queue_impl_t *queuep;
+
+	PDEBUG("tile_net_register(queue_id %d)\n", queue_id);
+
+	if (!strcmp(dev->name, "xgbe0"))
+		info = &__get_cpu_var(hv_xgbe0);
+	else if (!strcmp(dev->name, "xgbe1"))
+		info = &__get_cpu_var(hv_xgbe1);
+	else if (!strcmp(dev->name, "gbe0"))
+		info = &__get_cpu_var(hv_gbe0);
+	else if (!strcmp(dev->name, "gbe1"))
+		info = &__get_cpu_var(hv_gbe1);
+	else
+		BUG();
+
+	/* Initialize the egress timer. */
+	init_timer(&info->egress_timer);
+	info->egress_timer.data = (long)info;
+	info->egress_timer.function = tile_net_handle_egress_timer;
+
+	priv->cpu[my_cpu] = info;
+
+	/*
+	 * Register ourselves with the IPP.
+	 */
+	ret = hv_dev_pwrite(priv->hv_devhdl, 0,
+			    (HV_VirtAddr)&config,
+			    sizeof(netio_input_config_t),
+			    NETIO_IPP_INPUT_REGISTER_OFF);
+	PDEBUG("hv_dev_pwrite(NETIO_IPP_INPUT_REGISTER_OFF) returned %d\n",
+	       ret);
+	if (ret < 0) {
+		printk(KERN_DEBUG "hv_dev_pwrite NETIO_IPP_INPUT_REGISTER_OFF"
+		       " failure %d\n", ret);
+		info->link_down = (ret == NETIO_LINK_DOWN);
+		return;
+	}
+
+	/*
+	 * Get the pointer to our queue's system part.
+	 */
+
+	ret = hv_dev_pread(priv->hv_devhdl, 0,
+			   (HV_VirtAddr)&queuep,
+			   sizeof(netio_queue_impl_t *),
+			   NETIO_IPP_INPUT_REGISTER_OFF);
+	PDEBUG("hv_dev_pread(NETIO_IPP_INPUT_REGISTER_OFF) returned %d\n",
+	       ret);
+	PDEBUG("queuep %p\n", queuep);
+	if (ret <= 0) {
+		/* ISSUE: Shouldn't this be a fatal error? */
+		pr_err("hv_dev_pread NETIO_IPP_INPUT_REGISTER_OFF failure\n");
+		return;
+	}
+
+	queue = &info->queue;
+
+	queue->__system_part = queuep;
+
+	memset(&queue->__user_part, 0, sizeof(netio_queue_user_impl_t));
+
+	/* This is traditionally "config.num_receive_packets / 2". */
+	queue->__user_part.__receive_credit_interval = 4;
+	queue->__user_part.__receive_credit_remaining =
+		queue->__user_part.__receive_credit_interval;
+
+	/*
+	 * Get a fastio index from the hypervisor.
+	 * ISSUE: Shouldn't this check the result?
+	 */
+	ret = hv_dev_pread(priv->hv_devhdl, 0,
+			   (HV_VirtAddr)&queue->__user_part.__fastio_index,
+			   sizeof(queue->__user_part.__fastio_index),
+			   NETIO_IPP_GET_FASTIO_OFF);
+	PDEBUG("hv_dev_pread(NETIO_IPP_GET_FASTIO_OFF) returned %d\n", ret);
+
+	netif_napi_add(dev, &info->napi, tile_net_poll, 64);
+
+	/* Now we are registered. */
+	info->registered = true;
+}
+
+
+/*
+ * Unregister with hypervisor on each CPU.
+ */
+static void tile_net_unregister(void *dev_ptr)
+{
+	struct net_device *dev = (struct net_device *)dev_ptr;
+	struct tile_net_priv *priv = netdev_priv(dev);
+	int my_cpu = smp_processor_id();
+	struct tile_net_cpu *info = priv->cpu[my_cpu];
+
+	int ret = 0;
+	int dummy = 0;
+
+	/* Do nothing if never registered. */
+	if (info == NULL)
+		return;
+
+	/* Do nothing if already unregistered. */
+	if (!info->registered)
+		return;
+
+	/*
+	 * Unregister ourselves with LIPP.
+	 */
+	ret = hv_dev_pwrite(priv->hv_devhdl, 0, (HV_VirtAddr)&dummy,
+			    sizeof(dummy), NETIO_IPP_INPUT_UNREGISTER_OFF);
+	PDEBUG("hv_dev_pwrite(NETIO_IPP_INPUT_UNREGISTER_OFF) returned %d\n",
+	       ret);
+	if (ret < 0) {
+		/* FIXME: Just panic? */
+		pr_err("hv_dev_pwrite NETIO_IPP_INPUT_UNREGISTER_OFF"
+		       " failure %d\n", ret);
+	}
+
+	/*
+	 * Discard all packets still in our NetIO queue.  Hopefully,
+	 * once the unregister call is complete, there will be no
+	 * packets still in flight on the IDN.
+	 */
+	tile_net_discard_packets(dev);
+
+	/* Reset state. */
+	info->num_needed_small_buffers = 0;
+	info->num_needed_large_buffers = 0;
+
+	/* Cancel egress timer. */
+	del_timer(&info->egress_timer);
+	info->egress_timer_scheduled = false;
+
+	netif_napi_del(&info->napi);
+
+	/* Now we are unregistered. */
+	info->registered = false;
+}
+
+
+/*
+ * Helper function for "tile_net_stop()".
+ *
+ * Also used to handle registration failure in "tile_net_open_inner()",
+ * when "fully_opened" is known to be false, and the various extra
+ * steps in "tile_net_stop()" are not necessary.  ISSUE: It might be
+ * simpler if we could just call "tile_net_stop()" anyway.
+ */
+static void tile_net_stop_aux(struct net_device *dev)
+{
+	struct tile_net_priv *priv = netdev_priv(dev);
+
+	int dummy = 0;
+
+	/* Unregister all tiles, so LIPP will stop delivering packets. */
+	on_each_cpu(tile_net_unregister, (void *)dev, 1);
+
+	/* Stop LIPP/LEPP. */
+	if (hv_dev_pwrite(priv->hv_devhdl, 0, (HV_VirtAddr)&dummy,
+			  sizeof(dummy), NETIO_IPP_STOP_SHIM_OFF) < 0)
+		panic("Failed to stop LIPP/LEPP!\n");
+
+	priv->partly_opened = 0;
+}
+
+
+/*
+ * Disable ingress interrupts for the given device on the current cpu.
+ */
+static void tile_net_disable_intr(void *dev_ptr)
+{
+	struct net_device *dev = (struct net_device *)dev_ptr;
+	struct tile_net_priv *priv = netdev_priv(dev);
+	int my_cpu = smp_processor_id();
+	struct tile_net_cpu *info = priv->cpu[my_cpu];
+
+	/* Disable hypervisor interrupt. */
+	disable_percpu_irq(priv->intr_id);
+
+	/* Disable NAPI if needed. */
+	if (info != NULL && info->napi_enabled) {
+		napi_disable(&info->napi);
+		info->napi_enabled = false;
+	}
+}
+
+
+/*
+ * Enable ingress interrupts for the given device on the current cpu.
+ */
+static void tile_net_enable_intr(void *dev_ptr)
+{
+	struct net_device *dev = (struct net_device *)dev_ptr;
+	struct tile_net_priv *priv = netdev_priv(dev);
+	int my_cpu = smp_processor_id();
+	struct tile_net_cpu *info = priv->cpu[my_cpu];
+
+	/* Enable hypervisor interrupt. */
+	enable_percpu_irq(priv->intr_id);
+
+	/* Enable NAPI. */
+	napi_enable(&info->napi);
+	info->napi_enabled = true;
+}
+
+
+/*
+ * tile_net_open_inner does most of the work of bringing up the interface.
+ * It's called from tile_net_open(), and also from tile_net_retry_open().
+ * The return value is 0 if the interface was brought up, < 0 if
+ * tile_net_open() should return the return value as an error, and > 0 if
+ * tile_net_open() should return success and schedule a work item to
+ * periodically retry the bringup.
+ */
+static int tile_net_open_inner(struct net_device *dev)
+{
+	struct tile_net_priv *priv = netdev_priv(dev);
+	int my_cpu = smp_processor_id();
+	struct tile_net_cpu *info;
+	struct tile_netio_queue *queue;
+	unsigned int irq;
+	int i;
+
+	/*
+	 * First try to register just on the local CPU, and handle any
+	 * semi-expected "link down" failure specially.  Note that we
+	 * do NOT call "tile_net_stop_aux()", unlike below.
+	 */
+	tile_net_register(dev);
+	info = priv->cpu[my_cpu];
+	if (!info->registered) {
+		if (info->link_down)
+			return 1;
+		return -EAGAIN;
+	}
+
+	/*
+	 * Now register everywhere else.  If any registration fails,
+	 * even for "link down" (which might not be possible), we
+	 * clean up using "tile_net_stop_aux()".
+	 */
+	smp_call_function(tile_net_register, (void *)dev, 1);
+	for_each_online_cpu(i) {
+		if (!priv->cpu[i]->registered) {
+			tile_net_stop_aux(dev);
+			return -EAGAIN;
+		}
+	}
+
+	queue = &info->queue;
+
+	/*
+	 * Set the device intr bit mask.
+	 * The tile_net_register above sets per tile __intr_id.
+	 */
+	priv->intr_id = queue->__system_part->__intr_id;
+	BUG_ON(!priv->intr_id);
+
+	/*
+	 * Register the device interrupt handler.
+	 * The __ffs() function returns the index into the interrupt handler
+	 * table from the interrupt bit mask which should have one bit
+	 * and one bit only set.
+	 */
+	irq = __ffs(priv->intr_id);
+	tile_irq_activate(irq, TILE_IRQ_PERCPU);
+	BUG_ON(request_irq(irq, tile_net_handle_ingress_interrupt,
+			   0, dev->name, (void *)dev) != 0);
+
+	/* ISSUE: How could "priv->fully_opened" ever be "true" here? */
+
+	if (!priv->fully_opened) {
+
+		int dummy = 0;
+
+		/* Allocate initial buffers. */
+
+		int max_buffers =
+			priv->network_cpus_count * priv->network_cpus_credits;
+
+		info->num_needed_small_buffers =
+			min(LIPP_SMALL_BUFFERS, max_buffers);
+
+		info->num_needed_large_buffers =
+			min(LIPP_LARGE_BUFFERS, max_buffers);
+
+		tile_net_provide_needed_buffers(info);
+
+		if (info->num_needed_small_buffers != 0 ||
+		    info->num_needed_large_buffers != 0)
+			panic("Insufficient memory for buffer stack!");
+
+		/* Start LIPP/LEPP and activate "ingress" at the shim. */
+		if (hv_dev_pwrite(priv->hv_devhdl, 0, (HV_VirtAddr)&dummy,
+				  sizeof(dummy), NETIO_IPP_INPUT_INIT_OFF) < 0)
+			panic("Failed to activate the LIPP Shim!\n");
+
+		priv->fully_opened = 1;
+	}
+
+	/* On each tile, enable the hypervisor to trigger interrupts. */
+	/* ISSUE: Do this before starting LIPP/LEPP? */
+	on_each_cpu(tile_net_enable_intr, (void *)dev, 1);
+
+	/* Start our transmit queue. */
+	netif_start_queue(dev);
+
+	return 0;
+}
+
+
+/*
+ * Called periodically to retry bringing up the NetIO interface,
+ * if it doesn't come up cleanly during tile_net_open().
+ */
+static void tile_net_open_retry(struct work_struct *w)
+{
+	struct delayed_work *dw =
+		container_of(w, struct delayed_work, work);
+
+	struct tile_net_priv *priv =
+		container_of(dw, struct tile_net_priv, retry_work);
+
+	/*
+	 * Try to bring the NetIO interface up.  If it fails, reschedule
+	 * ourselves to try again later; otherwise, tell Linux we now have
+	 * a working link.  ISSUE: What if the return value is negative?
+	 */
+	if (tile_net_open_inner(priv->dev))
+		schedule_delayed_work_on(singlethread_cpu, &priv->retry_work,
+					 TILE_NET_RETRY_INTERVAL);
+	else
+		netif_carrier_on(priv->dev);
+}
+
+
+/*
+ * Called when a network interface is made active.
+ *
+ * Returns 0 on success, negative value on failure.
+ *
+ * The open entry point is called when a network interface is made
+ * active by the system (IFF_UP).  At this point all resources needed
+ * for transmit and receive operations are allocated, the interrupt
+ * handler is registered with the OS, the watchdog timer is started,
+ * and the stack is notified that the interface is ready.
+ *
+ * If the actual link is not available yet, then we tell Linux that
+ * we have no carrier, and we keep checking until the link comes up.
+ */
+static int tile_net_open(struct net_device *dev)
+{
+	int ret = 0;
+	struct tile_net_priv *priv = netdev_priv(dev);
+
+	/*
+	 * We rely on priv->partly_opened to tell us if this is the
+	 * first time this interface is being brought up. If it is
+	 * set, the IPP was already initialized and should not be
+	 * initialized again.
+	 */
+	if (!priv->partly_opened) {
+
+		int count;
+		int credits;
+
+		/* Initialize LIPP/LEPP, and start the Shim. */
+		ret = tile_net_open_aux(dev);
+		if (ret < 0) {
+			pr_err("tile_net_open_aux failed: %d\n", ret);
+			return ret;
+		}
+
+		/* Analyze the network cpus. */
+
+		if (network_cpus_used)
+			cpumask_copy(&priv->network_cpus_map,
+				     &network_cpus_map);
+		else
+			cpumask_copy(&priv->network_cpus_map, cpu_online_mask);
+
+
+		count = cpumask_weight(&priv->network_cpus_map);
+
+		/* Limit credits to available buffers, and apply min. */
+		credits = max(16, (LIPP_LARGE_BUFFERS / count) & ~1);
+
+		/* Apply "GBE" max limit. */
+		/* ISSUE: Use higher limit for XGBE? */
+		credits = min(NETIO_MAX_RECEIVE_PKTS, credits);
+
+		priv->network_cpus_count = count;
+		priv->network_cpus_credits = credits;
+
+#ifdef TILE_NET_DEBUG
+		pr_info("Using %d network cpus, with %d credits each\n",
+		       priv->network_cpus_count, priv->network_cpus_credits);
+#endif
+
+		priv->partly_opened = 1;
+	}
+
+	/*
+	 * Attempt to bring up the link.
+	 */
+	ret = tile_net_open_inner(dev);
+	if (ret <= 0) {
+		if (ret == 0)
+			netif_carrier_on(dev);
+		return ret;
+	}
+
+	/*
+	 * We were unable to bring up the NetIO interface, but we want to
+	 * try again in a little bit.  Tell Linux that we have no carrier
+	 * so it doesn't try to use the interface before the link comes up
+	 * and then remember to try again later.
+	 */
+	netif_carrier_off(dev);
+	schedule_delayed_work_on(singlethread_cpu, &priv->retry_work,
+				 TILE_NET_RETRY_INTERVAL);
+
+	return 0;
+}
+
+
+/*
+ * Disables a network interface.
+ *
+ * Returns 0, this is not allowed to fail.
+ *
+ * The close entry point is called when an interface is de-activated
+ * by the OS.  The hardware is still under the drivers control, but
+ * needs to be disabled.  A global MAC reset is issued to stop the
+ * hardware, and all transmit and receive resources are freed.
+ *
+ * ISSUE: Can this can be called while "tile_net_poll()" is running?
+ */
+static int tile_net_stop(struct net_device *dev)
+{
+	struct tile_net_priv *priv = netdev_priv(dev);
+
+	bool pending = true;
+
+	PDEBUG("tile_net_stop()\n");
+
+	/* ISSUE: Only needed if not yet fully open. */
+	cancel_delayed_work_sync(&priv->retry_work);
+
+	/* Can't transmit any more. */
+	netif_stop_queue(dev);
+
+	/*
+	 * Disable hypervisor interrupts on each tile.
+	 */
+	on_each_cpu(tile_net_disable_intr, (void *)dev, 1);
+
+	/*
+	 * Unregister the interrupt handler.
+	 * The __ffs() function returns the index into the interrupt handler
+	 * table from the interrupt bit mask which should have one bit
+	 * and one bit only set.
+	 */
+	if (priv->intr_id)
+		free_irq(__ffs(priv->intr_id), dev);
+
+	/*
+	 * Drain all the LIPP buffers.
+	 */
+
+	while (true) {
+		int buffer;
+
+		/* NOTE: This should never fail. */
+		if (hv_dev_pread(priv->hv_devhdl, 0, (HV_VirtAddr)&buffer,
+				 sizeof(buffer), NETIO_IPP_DRAIN_OFF) < 0)
+			break;
+
+		/* Stop when done. */
+		if (buffer == 0)
+			break;
+
+		{
+			/* Convert "linux_buffer_t" to "va". */
+			void *va = __va((phys_addr_t)(buffer >> 1) << 7);
+
+			/* Acquire the associated "skb". */
+			struct sk_buff **skb_ptr = va - sizeof(*skb_ptr);
+			struct sk_buff *skb = *skb_ptr;
+
+			kfree_skb(skb);
+		}
+	}
+
+	/* Stop LIPP/LEPP. */
+	tile_net_stop_aux(dev);
+
+
+	priv->fully_opened = 0;
+
+
+	/*
+	 * XXX: ISSUE: It appears that, in practice anyway, by the
+	 * time we get here, there are no pending completions.
+	 */
+	while (pending) {
+
+		struct sk_buff *olds[32];
+		unsigned int wanted = 32;
+		unsigned int i, nolds = 0;
+
+		nolds = tile_net_lepp_grab_comps(dev, olds,
+						 wanted, &pending);
+
+		/* ISSUE: We have never actually seen this debug spew. */
+		if (nolds != 0)
+			pr_info("During tile_net_stop(), grabbed %d comps.\n",
+			       nolds);
+
+		for (i = 0; i < nolds; i++)
+			kfree_skb(olds[i]);
+	}
+
+
+	/* Wipe the EPP queue. */
+	memset(priv->epp_queue, 0, sizeof(lepp_queue_t));
+
+	/* Evict the EPP queue. */
+	finv_buffer(priv->epp_queue, PAGE_SIZE);
+
+	return 0;
+}
+
+
+/*
+ * HACK: Somehow, touching memory after an "finv" does something useful.
+ *
+ * FIXME: If MEMORY_STRIPING is active, we should touch one byte on every
+ * 8192 byte page.  Below, as a hack, we touch the last byte as a totally
+ * hacky approximation of this, which is WRONG for the TSO/GSO cases.
+ */
+static void
+flush_buffer_remote(void *buffer, size_t size)
+{
+	__flush_buffer(buffer, size);
+
+	__insn_mf();
+
+	__insn_finv(buffer);
+
+	*(volatile char *)buffer;
+
+	*(volatile char *)(buffer + size - 1);
+
+	__insn_mf();
+}
+
+
+/*
+ * Prepare the "frags" info for the resulting LEPP command.
+ *
+ * If needed, flush the memory used by the frags.
+ */
+static unsigned int tile_net_tx_frags(lepp_frag_t *frags,
+				      struct sk_buff *skb,
+				      void *b_data, unsigned int b_len)
+{
+	unsigned int i, n = 0;
+
+	struct skb_shared_info *sh = skb_shinfo(skb);
+
+	phys_addr_t cpa;
+
+	/*
+	 * ISSUE: Could the flushing be more efficient?
+	 * This seems like an excessive amount of fencing.
+	 */
+
+	if (b_len != 0) {
+
+		if (!HASH_DEFAULT)
+			flush_buffer_remote(b_data, b_len);
+
+		cpa = __pa(b_data);
+		frags[n].cpa_lo = cpa;
+		frags[n].cpa_hi = cpa >> 32;
+		frags[n].length = b_len;
+		frags[n].hash_for_home = HASH_DEFAULT;
+		n++;
+	}
+
+	for (i = 0; i < sh->nr_frags; i++) {
+
+		skb_frag_t *f = &sh->frags[i];
+		unsigned long pfn = page_to_pfn(f->page);
+
+		/* FIXME: Compute "hash_for_home" properly. */
+		int hash_for_home = HASH_DEFAULT;
+
+		/* FIXME: Hmmm. */
+		if (!HASH_DEFAULT) {
+			void *va = pfn_to_kaddr(pfn) + f->page_offset;
+			BUG_ON(PageHighMem(f->page));
+			flush_buffer_remote(va, f->size);
+		}
+
+		cpa = ((phys_addr_t)pfn << PAGE_SHIFT) + f->page_offset;
+		frags[n].cpa_lo = cpa;
+		frags[n].cpa_hi = cpa >> 32;
+		frags[n].length = f->size;
+		frags[n].hash_for_home = hash_for_home;
+		n++;
+	}
+
+	return n;
+}
+
+
+/*
+ * This function takes "skb", consisting of a header template and a
+ * payload, and hands it to LEPP, to emit as one or more segments,
+ * each consisting of a possibly modified header, plus a piece of the
+ * payload, via a process known as "tcp segmentation offload".
+ *
+ * Usually, "data" will contain the header template, of size "sh_len",
+ * and "sh->frags" will contain "skb->data_len" bytes of payload, and
+ * there will be "sh->gso_segs" segments.
+ *
+ * Sometimes, if "sendfile()" requires copying, we will be called with
+ * "data" containing the header and payload, with "frags" being empty.
+ *
+ * In theory, "sh->nr_frags" could be 3, but in practice, it seems
+ * that this will never actually happen.
+ *
+ * See "emulate_large_send_offload()" for some reference code, which
+ * does not handle checksumming.
+ *
+ * ISSUE: How do we make sure that high memory DMA does not migrate?
+ */
+static int tile_net_tx_tso(struct sk_buff *skb, struct net_device *dev)
+{
+	struct tile_net_priv *priv = netdev_priv(dev);
+	int my_cpu = smp_processor_id();
+	struct tile_net_cpu *info = priv->cpu[my_cpu];
+	struct tile_net_stats_t *stats = &info->stats;
+
+	struct skb_shared_info *sh = skb_shinfo(skb);
+
+	unsigned char *data = skb->data;
+
+	/* The ip header follows the ethernet header. */
+	struct iphdr *ih = ip_hdr(skb);
+	unsigned int ih_len = ih->ihl * 4;
+
+	/* Note that "nh == ih", by definition. */
+	unsigned char *nh = skb_network_header(skb);
+	unsigned int eh_len = nh - data;
+
+	/* The tcp header follows the ip header. */
+	struct tcphdr *th = (struct tcphdr *)(nh + ih_len);
+	unsigned int th_len = th->doff * 4;
+
+	/* The total number of header bytes. */
+	/* NOTE: This may be less than skb_headlen(skb). */
+	unsigned int sh_len = eh_len + ih_len + th_len;
+
+	/* The number of payload bytes at "skb->data + sh_len". */
+	/* This is non-zero for sendfile() without HIGHDMA. */
+	unsigned int b_len = skb_headlen(skb) - sh_len;
+
+	/* The total number of payload bytes. */
+	unsigned int d_len = b_len + skb->data_len;
+
+	/* The maximum payload size. */
+	unsigned int p_len = sh->gso_size;
+
+	/* The total number of segments. */
+	unsigned int num_segs = sh->gso_segs;
+
+	/* The temporary copy of the command. */
+	uint32_t cmd_body[(LEPP_MAX_CMD_SIZE + 3) / 4];
+	lepp_tso_cmd_t *cmd = (lepp_tso_cmd_t *)cmd_body;
+
+	/* Analyze the "frags". */
+	unsigned int num_frags =
+		tile_net_tx_frags(cmd->frags, skb, data + sh_len, b_len);
+
+	/* The size of the command, including frags and header. */
+	size_t cmd_size = LEPP_TSO_CMD_SIZE(num_frags, sh_len);
+
+	/* The command header. */
+	lepp_tso_cmd_t cmd_init = {
+		.tso = true,
+		.header_size = sh_len,
+		.ip_offset = eh_len,
+		.tcp_offset = eh_len + ih_len,
+		.payload_size = p_len,
+		.num_frags = num_frags,
+	};
+
+	unsigned long irqflags;
+
+	lepp_queue_t *eq = priv->epp_queue;
+
+	struct sk_buff *olds[4];
+	unsigned int wanted = 4;
+	unsigned int i, nolds = 0;
+
+	unsigned int cmd_head, cmd_tail, cmd_next;
+	unsigned int comp_tail;
+
+	unsigned int free_slots;
+
+
+	/* Paranoia. */
+	BUG_ON(skb->protocol != htons(ETH_P_IP));
+	BUG_ON(ih->protocol != IPPROTO_TCP);
+	BUG_ON(skb->ip_summed != CHECKSUM_PARTIAL);
+	BUG_ON(num_frags > LEPP_MAX_FRAGS);
+	/*--BUG_ON(num_segs != (d_len + (p_len - 1)) / p_len); */
+	BUG_ON(num_segs <= 1);
+
+
+	/* Finish preparing the command. */
+
+	/* Copy the command header. */
+	*cmd = cmd_init;
+
+	/* Copy the "header". */
+	memcpy(&cmd->frags[num_frags], data, sh_len);
+
+
+	/* HACK: Make sure "eq" is available. */
+
+	/*--*(volatile int *)&eq->comp_head; */
+	*(volatile int *)&eq->comp_tail;
+
+	/*--*(volatile int *)&eq->cmd_head; */
+	*(volatile int *)&eq->cmd_tail;
+
+	__insn_mf();
+
+
+	/* Enqueue the command. */
+
+	spin_lock_irqsave(&priv->cmd_lock, irqflags);
+
+	/*
+	 * Handle completions if needed to make room.
+	 * HACK: Spin until there is sufficient room.
+	 */
+	free_slots = lepp_num_free_comp_slots(eq);
+	if (free_slots < 1) {
+spin:
+		nolds += tile_net_lepp_grab_comps(dev, olds + nolds,
+						  wanted - nolds, NULL);
+		if (lepp_num_free_comp_slots(eq) < 1)
+			goto spin;
+	}
+
+	cmd_head = eq->cmd_head;
+	cmd_tail = eq->cmd_tail;
+
+	/* NOTE: The "gotos" below are untested. */
+
+	/* Prepare to advance, detecting full queue. */
+	cmd_next = cmd_tail + cmd_size;
+	if (cmd_tail < cmd_head && cmd_next >= cmd_head)
+		goto spin;
+	if (cmd_next > LEPP_CMD_LIMIT) {
+		cmd_next = 0;
+		if (cmd_next == cmd_head)
+			goto spin;
+	}
+
+	/* Copy the command. */
+	memcpy(&eq->cmds[cmd_tail], cmd, cmd_size);
+
+	/* Advance. */
+	cmd_tail = cmd_next;
+
+	/* Record "skb" for eventual freeing. */
+	comp_tail = eq->comp_tail;
+	eq->comps[comp_tail] = skb;
+	LEPP_QINC(comp_tail);
+	eq->comp_tail = comp_tail;
+
+	/* Flush before allowing LEPP to handle the command. */
+	__insn_mf();
+
+	eq->cmd_tail = cmd_tail;
+
+	spin_unlock_irqrestore(&priv->cmd_lock, irqflags);
+
+	if (nolds == 0)
+		nolds = tile_net_lepp_grab_comps(dev, olds, wanted, NULL);
+
+	/* Handle completions. */
+	for (i = 0; i < nolds; i++)
+		kfree_skb(olds[i]);
+
+	/* Update stats. */
+	stats->tx_packets += num_segs;
+	stats->tx_bytes += (num_segs * sh_len) + d_len;
+
+	/* Make sure the egress timer is scheduled. */
+	tile_net_schedule_egress_timer(info);
+
+	return NETDEV_TX_OK;
+}
+
+
+/*
+ * Transmit a packet (called by the kernel via "hard_start_xmit" hook).
+ */
+static int tile_net_tx(struct sk_buff *skb, struct net_device *dev)
+{
+	struct tile_net_priv *priv = netdev_priv(dev);
+	int my_cpu = smp_processor_id();
+	struct tile_net_cpu *info = priv->cpu[my_cpu];
+	struct tile_net_stats_t *stats = &info->stats;
+
+	unsigned long irqflags;
+
+	struct skb_shared_info *sh = skb_shinfo(skb);
+
+	unsigned int len = skb->len;
+	unsigned char *data = skb->data;
+
+	unsigned int csum_start = skb->csum_start - skb_headroom(skb);
+
+	lepp_frag_t frags[LEPP_MAX_FRAGS];
+
+	unsigned int num_frags;
+
+	lepp_queue_t *eq = priv->epp_queue;
+
+	struct sk_buff *olds[4];
+	unsigned int wanted = 4;
+	unsigned int i, nolds = 0;
+
+	unsigned int cmd_size = sizeof(lepp_cmd_t);
+
+	unsigned int cmd_head, cmd_tail, cmd_next;
+	unsigned int comp_tail;
+
+	lepp_cmd_t cmds[LEPP_MAX_FRAGS];
+
+	unsigned int free_slots;
+
+
+	/*
+	 * This is paranoia, since we think that if the link doesn't come
+	 * up, telling Linux we have no carrier will keep it from trying
+	 * to transmit.  If it does, though, we can't execute this routine,
+	 * since data structures we depend on aren't set up yet.
+	 */
+	if (!info->registered)
+		return NETDEV_TX_BUSY;
+
+
+	/* Save the timestamp. */
+	dev->trans_start = jiffies;
+
+
+#ifdef TILE_NET_PARANOIA
+#if CHIP_HAS_CBOX_HOME_MAP()
+	if (hash_default) {
+		HV_PTE pte = *virt_to_pte(current->mm, (unsigned long)data);
+		if (hv_pte_get_mode(pte) != HV_PTE_MODE_CACHE_HASH_L3)
+			panic("Non-coherent egress buffer!");
+	}
+#endif
+#endif
+
+
+#ifdef TILE_NET_DUMP_PACKETS
+	/* ISSUE: Does not dump the "frags". */
+	dump_packet(data, skb_headlen(skb), "tx");
+#endif /* TILE_NET_DUMP_PACKETS */
+
+
+	if (sh->gso_size != 0)
+		return tile_net_tx_tso(skb, dev);
+
+
+	/* Prepare the commands. */
+
+	num_frags = tile_net_tx_frags(frags, skb, data, skb_headlen(skb));
+
+	for (i = 0; i < num_frags; i++) {
+
+		bool final = (i == num_frags - 1);
+
+		lepp_cmd_t cmd = {
+			.cpa_lo = frags[i].cpa_lo,
+			.cpa_hi = frags[i].cpa_hi,
+			.length = frags[i].length,
+			.hash_for_home = frags[i].hash_for_home,
+			.send_completion = final,
+			.end_of_packet = final
+		};
+
+		if (i == 0 && skb->ip_summed == CHECKSUM_PARTIAL) {
+			cmd.compute_checksum = 1;
+			cmd.checksum_data.bits.start_byte = csum_start;
+			cmd.checksum_data.bits.count = len - csum_start;
+			cmd.checksum_data.bits.destination_byte =
+				csum_start + skb->csum_offset;
+		}
+
+		cmds[i] = cmd;
+	}
+
+
+	/* HACK: Make sure "eq" is available. */
+
+	/*--*(volatile int *)&eq->comp_head; */
+	*(volatile int *)&eq->comp_tail;
+
+	/*--*(volatile int *)&eq->cmd_head; */
+	*(volatile int *)&eq->cmd_tail;
+
+	__insn_mf();
+
+
+	/* Enqueue the commands. */
+
+	spin_lock_irqsave(&priv->cmd_lock, irqflags);
+
+	/*
+	 * Handle completions if needed to make room.
+	 * HACK: Spin until there is sufficient room.
+	 */
+	free_slots = lepp_num_free_comp_slots(eq);
+	if (free_slots < 1) {
+spin:
+		nolds += tile_net_lepp_grab_comps(dev, olds + nolds,
+						  wanted - nolds, NULL);
+		if (lepp_num_free_comp_slots(eq) < 1)
+			goto spin;
+	}
+
+	cmd_head = eq->cmd_head;
+	cmd_tail = eq->cmd_tail;
+
+	/* NOTE: The "gotos" below are untested. */
+
+	/* Copy the commands, or fail. */
+	for (i = 0; i < num_frags; i++) {
+
+		/* Prepare to advance, detecting full queue. */
+		cmd_next = cmd_tail + cmd_size;
+		if (cmd_tail < cmd_head && cmd_next >= cmd_head)
+			goto spin;
+		if (cmd_next > LEPP_CMD_LIMIT) {
+			cmd_next = 0;
+			if (cmd_next == cmd_head)
+				goto spin;
+		}
+
+		/* Copy the command. */
+		*(lepp_cmd_t *)&eq->cmds[cmd_tail] = cmds[i];
+
+		/* Advance. */
+		cmd_tail = cmd_next;
+	}
+
+	/* Record "skb" for eventual freeing. */
+	comp_tail = eq->comp_tail;
+	eq->comps[comp_tail] = skb;
+	LEPP_QINC(comp_tail);
+	eq->comp_tail = comp_tail;
+
+	/* Flush before allowing LEPP to handle the command. */
+	__insn_mf();
+
+	eq->cmd_tail = cmd_tail;
+
+	spin_unlock_irqrestore(&priv->cmd_lock, irqflags);
+
+	if (nolds == 0)
+		nolds = tile_net_lepp_grab_comps(dev, olds, wanted, NULL);
+
+	/* Handle completions. */
+	for (i = 0; i < nolds; i++)
+		kfree_skb(olds[i]);
+
+	/* HACK: Track "expanded" size for short packets (e.g. 42 < 60). */
+	stats->tx_packets++;
+	stats->tx_bytes += ((len >= ETH_ZLEN) ? len : ETH_ZLEN);
+
+	/* Make sure the egress timer is scheduled. */
+	tile_net_schedule_egress_timer(info);
+
+	return NETDEV_TX_OK;
+}
+
+
+/*
+ * Deal with a transmit timeout.
+ */
+static void tile_net_tx_timeout(struct net_device *dev)
+{
+	PDEBUG("tile_net_tx_timeout()\n");
+	PDEBUG("Transmit timeout at %ld, latency %ld\n", jiffies,
+	       jiffies - dev->trans_start);
+
+	/* XXX: ISSUE: This doesn't seem useful for us. */
+	netif_wake_queue(dev);
+}
+
+
+/*
+ * Ioctl commands.
+ */
+static int tile_net_ioctl(struct net_device *dev, struct ifreq *rq, int cmd)
+{
+	return -EOPNOTSUPP;
+}
+
+
+/*
+ * Get System Network Statistics.
+ *
+ * Returns the address of the device statistics structure.
+ */
+static struct net_device_stats *tile_net_get_stats(struct net_device *dev)
+{
+	struct tile_net_priv *priv = netdev_priv(dev);
+	uint32_t rx_packets = 0;
+	uint32_t tx_packets = 0;
+	uint32_t rx_bytes = 0;
+	uint32_t tx_bytes = 0;
+	int i;
+
+	for_each_online_cpu(i) {
+		if (priv->cpu[i]) {
+			rx_packets += priv->cpu[i]->stats.rx_packets;
+			rx_bytes += priv->cpu[i]->stats.rx_bytes;
+			tx_packets += priv->cpu[i]->stats.tx_packets;
+			tx_bytes += priv->cpu[i]->stats.tx_bytes;
+		}
+	}
+
+	priv->stats.rx_packets = rx_packets;
+	priv->stats.rx_bytes = rx_bytes;
+	priv->stats.tx_packets = tx_packets;
+	priv->stats.tx_bytes = tx_bytes;
+
+	return &priv->stats;
+}
+
+
+/*
+ * Change the "mtu".
+ *
+ * The "change_mtu" method is usually not needed.
+ * If you need it, it must be like this.
+ */
+static int tile_net_change_mtu(struct net_device *dev, int new_mtu)
+{
+	PDEBUG("tile_net_change_mtu()\n");
+
+	/* Check ranges. */
+	if ((new_mtu < 68) || (new_mtu > 1500))
+		return -EINVAL;
+
+	/* Accept the value. */
+	dev->mtu = new_mtu;
+
+	return 0;
+}
+
+
+/*
+ * Change the Ethernet Address of the NIC.
+ *
+ * The hypervisor driver does not support changing MAC address.  However,
+ * the IPP does not do anything with the MAC address, so the address which
+ * gets used on outgoing packets, and which is accepted on incoming packets,
+ * is completely up to the NetIO program or kernel driver which is actually
+ * handling them.
+ *
+ * Returns 0 on success, negative on failure.
+ */
+static int tile_net_set_mac_address(struct net_device *dev, void *p)
+{
+	struct sockaddr *addr = p;
+
+	if (!is_valid_ether_addr(addr->sa_data))
+		return -EINVAL;
+
+	/* ISSUE: Note that "dev_addr" is now a pointer. */
+	memcpy(dev->dev_addr, addr->sa_data, dev->addr_len);
+
+	return 0;
+}
+
+
+/*
+ * Obtain the MAC address from the hypervisor.
+ * This must be done before opening the device.
+ */
+static int tile_net_get_mac(struct net_device *dev)
+{
+	struct tile_net_priv *priv = netdev_priv(dev);
+
+	char hv_dev_name[32];
+	int len;
+
+	__netio_getset_offset_t offset = { .word = NETIO_IPP_PARAM_OFF };
+
+	int ret;
+
+	/* For example, "xgbe0". */
+	strcpy(hv_dev_name, dev->name);
+	len = strlen(hv_dev_name);
+
+	/* For example, "xgbe/0". */
+	hv_dev_name[len] = hv_dev_name[len - 1];
+	hv_dev_name[len - 1] = '/';
+	len++;
+
+	/* For example, "xgbe/0/native_hash". */
+	strcpy(hv_dev_name + len, HASH_DEFAULT ? "/native_hash" : "/native");
+
+	/* Get the hypervisor handle for this device. */
+	priv->hv_devhdl = hv_dev_open((HV_VirtAddr)hv_dev_name, 0);
+	PDEBUG("hv_dev_open(%s) returned %d %p\n",
+	       hv_dev_name, priv->hv_devhdl, &priv->hv_devhdl);
+	if (priv->hv_devhdl < 0) {
+		if (priv->hv_devhdl == HV_ENODEV)
+			printk(KERN_DEBUG "Ignoring unconfigured device %s\n",
+				 hv_dev_name);
+		else
+			printk(KERN_DEBUG "hv_dev_open(%s) returned %d\n",
+				 hv_dev_name, priv->hv_devhdl);
+		return -1;
+	}
+
+	/*
+	 * Read the hardware address from the hypervisor.
+	 * ISSUE: Note that "dev_addr" is now a pointer.
+	 */
+	offset.bits.class = NETIO_PARAM;
+	offset.bits.addr = NETIO_PARAM_MAC;
+	ret = hv_dev_pread(priv->hv_devhdl, 0,
+			   (HV_VirtAddr)dev->dev_addr, dev->addr_len,
+			   offset.word);
+	PDEBUG("hv_dev_pread(NETIO_PARAM_MAC) returned %d\n", ret);
+	if (ret <= 0) {
+		printk(KERN_DEBUG "hv_dev_pread(NETIO_PARAM_MAC) %s failed\n",
+		       dev->name);
+		/*
+		 * Since the device is configured by the hypervisor but we
+		 * can't get its MAC address, we are most likely running
+		 * the simulator, so let's generate a random MAC address.
+		 */
+		random_ether_addr(dev->dev_addr);
+	}
+
+	return 0;
+}
+
+
+static struct net_device_ops tile_net_ops = {
+	.ndo_open = tile_net_open,
+	.ndo_stop = tile_net_stop,
+	.ndo_start_xmit = tile_net_tx,
+	.ndo_do_ioctl = tile_net_ioctl,
+	.ndo_get_stats = tile_net_get_stats,
+	.ndo_change_mtu = tile_net_change_mtu,
+	.ndo_tx_timeout = tile_net_tx_timeout,
+	.ndo_set_mac_address = tile_net_set_mac_address
+};
+
+
+/*
+ * The setup function.
+ *
+ * This uses ether_setup() to assign various fields in dev, including
+ * setting IFF_BROADCAST and IFF_MULTICAST, then sets some extra fields.
+ */
+static void tile_net_setup(struct net_device *dev)
+{
+	PDEBUG("tile_net_setup()\n");
+
+	ether_setup(dev);
+
+	dev->netdev_ops = &tile_net_ops;
+
+	dev->watchdog_timeo = TILE_NET_TIMEOUT;
+
+	/* We want lockless xmit. */
+	dev->features |= NETIF_F_LLTX;
+
+	/* We support hardware tx checksums. */
+	dev->features |= NETIF_F_HW_CSUM;
+
+	/* We support scatter/gather. */
+	dev->features |= NETIF_F_SG;
+
+	/* We support TSO. */
+	dev->features |= NETIF_F_TSO;
+
+#ifdef TILE_NET_GSO
+	/* We support GSO. */
+	dev->features |= NETIF_F_GSO;
+#endif
+
+	if (HASH_DEFAULT)
+		dev->features |= NETIF_F_HIGHDMA;
+
+	/* ISSUE: We should support NETIF_F_UFO. */
+
+	dev->tx_queue_len = TILE_NET_TX_QUEUE_LEN;
+
+	dev->mtu = TILE_NET_MTU;
+}
+
+
+/*
+ * Allocate the device structure, register the device, and obtain the
+ * MAC address from the hypervisor.
+ */
+static struct net_device *tile_net_dev_init(const char *name)
+{
+	int ret;
+	struct net_device *dev;
+	struct tile_net_priv *priv;
+	struct page *page;
+
+	/*
+	 * Allocate the device structure.  This allocates "priv", calls
+	 * tile_net_setup(), and saves "name".  Normally, "name" is a
+	 * template, instantiated by register_netdev(), but not for us.
+	 */
+	dev = alloc_netdev(sizeof(*priv), name, tile_net_setup);
+	if (!dev) {
+		pr_err("alloc_netdev(%s) failed\n", name);
+		return NULL;
+	}
+
+	priv = netdev_priv(dev);
+
+	/* Initialize "priv". */
+
+	memset(priv, 0, sizeof(*priv));
+
+	/* Save "dev" for "tile_net_open_retry()". */
+	priv->dev = dev;
+
+	INIT_DELAYED_WORK(&priv->retry_work, tile_net_open_retry);
+
+	spin_lock_init(&priv->cmd_lock);
+	spin_lock_init(&priv->comp_lock);
+
+	/* Allocate "epp_queue". */
+	BUG_ON(get_order(sizeof(lepp_queue_t)) != 0);
+	page = alloc_pages(GFP_KERNEL | __GFP_ZERO, 0);
+	if (!page) {
+		free_netdev(dev);
+		return NULL;
+	}
+	priv->epp_queue = page_address(page);
+
+	/* Register the network device. */
+	ret = register_netdev(dev);
+	if (ret) {
+		pr_err("register_netdev %s failed %d\n", dev->name, ret);
+		free_page((unsigned long)priv->epp_queue);
+		free_netdev(dev);
+		return NULL;
+	}
+
+	/* Get the MAC address. */
+	ret = tile_net_get_mac(dev);
+	if (ret < 0) {
+		unregister_netdev(dev);
+		free_page((unsigned long)priv->epp_queue);
+		free_netdev(dev);
+		return NULL;
+	}
+
+	return dev;
+}
+
+
+/*
+ * Module cleanup.
+ */
+static void tile_net_cleanup(void)
+{
+	int i;
+
+	for (i = 0; i < TILE_NET_DEVS; i++) {
+		if (tile_net_devs[i]) {
+			struct net_device *dev = tile_net_devs[i];
+			struct tile_net_priv *priv = netdev_priv(dev);
+			unregister_netdev(dev);
+			finv_buffer(priv->epp_queue, PAGE_SIZE);
+			free_page((unsigned long)priv->epp_queue);
+			free_netdev(dev);
+		}
+	}
+}
+
+
+/*
+ * Module initialization.
+ */
+static int tile_net_init_module(void)
+{
+	pr_info("Tilera IPP Net Driver\n");
+
+	tile_net_devs[0] = tile_net_dev_init("xgbe0");
+	tile_net_devs[1] = tile_net_dev_init("xgbe1");
+	tile_net_devs[2] = tile_net_dev_init("gbe0");
+	tile_net_devs[3] = tile_net_dev_init("gbe1");
+
+	return 0;
+}
+
+
+#ifndef MODULE
+/*
+ * The "network_cpus" boot argument specifies the cpus that are dedicated
+ * to handle ingress packets.
+ *
+ * The parameter should be in the form "network_cpus=m-n[,x-y]", where
+ * m, n, x, y are integer numbers that represent the cpus that can be
+ * neither a dedicated cpu nor a dataplane cpu.
+ */
+static int __init network_cpus_setup(char *str)
+{
+	int rc = cpulist_parse_crop(str, &network_cpus_map);
+	if (rc != 0) {
+		pr_warning("network_cpus=%s: malformed cpu list\n",
+		       str);
+	} else {
+
+		/* Remove dedicated cpus. */
+		cpumask_and(&network_cpus_map, &network_cpus_map,
+			    cpu_possible_mask);
+
+
+		if (cpumask_empty(&network_cpus_map)) {
+			pr_warning("Ignoring network_cpus='%s'.\n",
+			       str);
+		} else {
+			char buf[1024];
+			cpulist_scnprintf(buf, sizeof(buf), &network_cpus_map);
+			pr_info("Linux network CPUs: %s\n", buf);
+			network_cpus_used = true;
+		}
+	}
+
+	return 0;
+}
+__setup("network_cpus=", network_cpus_setup);
+#endif
+
+
+module_init(tile_net_init_module);
+module_exit(tile_net_cleanup);
-- 
1.6.5.2
