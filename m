From: "Subbu Seetharaman" <subbus@serverengines.com>
Subject: [PATCH 4/12] benet: beclib (h/w access lib) header files
Date: Thu, 12 Jun 2008 03:40:42 -0700
Message-ID: <20080612104042.89fa1f08@mailhost.serverengines.com>
Mime-Version: 1.0
Content-Type: text/plain;
	charset="us-ascii"
Content-Transfer-Encoding: 8BIT
Cc: netdev@vger.kernel.org
To: jeff@garzik.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail142.messagelabs.com ([216.82.249.99]:16086 "EHLO
	mail142.messagelabs.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1756250AbYFLKkr convert rfc822-to-8bit (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 12 Jun 2008 06:40:47 -0400
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Signed-off-by: Subbu Seetharaman <subbus@serverengines.com>
---
 drivers/message/beclib/beclib_common.h      |  667 ++++++++++++++++
 drivers/message/beclib/beclib_ll_bmap_nic.h | 1111 +++++++++++++++++++++++++++
 drivers/message/beclib/beclib_ll_enum_nic.h |   48 ++
 3 files changed, 1826 insertions(+), 0 deletions(-)
 create mode 100644 drivers/message/beclib/beclib_common.h
 create mode 100644 drivers/message/beclib/beclib_ll_bmap_nic.h
 create mode 100644 drivers/message/beclib/beclib_ll_enum_nic.h

diff --git a/drivers/message/beclib/beclib_common.h b/drivers/message/beclib/beclib_common.h
new file mode 100644
index 0000000..ed1a838
--- /dev/null
+++ b/drivers/message/beclib/beclib_common.h
@@ -0,0 +1,667 @@
+/*
+ * Copyright (C) 2005 - 2008 ServerEngines
+ * All rights reserved.
+ *
+ * This program is free software; you can redistribute it and/or
+ * modify it under the terms of the GNU General Public License version 2
+ * as published by the Free Software Foundation.  The full GNU General
+ * Public License is included in this distribution in the file called COPYING.
+ *
+ * Contact Information:
+ * linux-drivers@serverengines.com
+ *
+ * ServerEngines
+ * 209 N. Fair Oaks Ave
+ * Sunnyvale, CA 94085
+ */
+#ifndef __beclib_common_h__
+#define __beclib_common_h__
+
+#include <linux/io.h>
+#include <linux/list.h>
+#include <linux/spinlock.h>
+
+/*-----  Platform specific defines for Linux -------*/
+
+#define TRUE	(1)
+#define FALSE	(0)
+
+#if !defined(SG_PACK)
+#define SG_PACK __attribute__ ((packed))
+#endif
+/*
+ *---------   Assert related --------
+ * a way to force  compilation error
+ */
+
+#define SA_C_ASSERT(_expression_)       {				\
+	struct __COMPILE_TIME_ASSERT__ {				\
+		u8 __COMPILE_TIME_ASSERT__[(_expression_)?1: -1];	\
+	};								\
+}
+
+#define SA_COMPILETIME_NAMED_TYPEDEF_ASSERT(_name_, _expression_)	\
+	struct _name_##_COMPILE_TIME_ASSERT_ {				\
+		u8 _name##_COMPILE_TIME_ASSERT_[(_expression_)?1: -1];	\
+	};
+
+
+#define SA_GLOBAL_C_ASSERT          SA_COMPILETIME_NAMED_TYPEDEF_ASSERT
+
+#define SA_ASSERT	ASSERT
+#ifdef SA_DEBUG
+
+#define ASSERT(c)       if (!(c)) \
+				BUG();
+
+#define SA_DBG_CSTR(_str_)        (_str_)
+
+#else
+
+#define ASSERT(c)
+#define SA_DBG_CSTR(_str_)        ""
+
+#endif
+
+/*---------   Trace log related --------*/
+
+/* debug levels */
+enum SA_DEBUG_LEVELS {
+	DL_ALWAYS = 0,		/* cannot be masked */
+
+	DL_ERR = 0x1,		/* errors that should never happen */
+	DL_WARN = 0x2,		/* something is questionable.
+				   recoverable errors */
+	DL_NOTE = 0x4,		/* infrequent, important debug info */
+	DL_INFO = 0x8,		/* debug information */
+
+	DL_VERBOSE = 0x10,	/* detailed information, such as
+				   buffer traces */
+	DL_ENTRY = 0x20,	/* function entry */
+	DL_EXIT = 0x40,		/* function exit */
+	DL_RSVD1 = 0x80,
+
+	SA_DL_MIN_VALUE = 0x1,	/* this is the min value used */
+	SA_DL_MAX_VALUE = 0x80	/* this is the higheset value used */
+} ;
+
+/* Bit mask describing events of interest to be traced */
+extern unsigned int trace_level;
+
+#define SA_TRACE(lm, fmt, args...)  {				\
+		if (trace_level & lm) {				\
+			printk(KERN_NOTICE "BE: %s:%d \n" fmt,	\
+			__FILE__ , __LINE__ , ## args);		\
+		}						\
+	}
+
+#define TRACE			SA_TRACE
+
+static inline unsigned int sa_trace_set_level(unsigned int l)
+{
+	unsigned int old_level = trace_level;
+	trace_level = l;
+	return old_level;
+}
+
+#define sa_trace_get_level() 	trace_level
+#define sa_trace_set_debug_level_string(lm, s)	/* nothing */
+
+/*----- power of 2  functions -----*/
+static inline u32 sa_required_bits(u32 x)
+{
+	u32 hi = 31, lo = 0;
+	u32 guess = 16;
+
+	if (x == 0)
+		return 0;
+	if (x & 0x80000000)
+		return 32;
+
+	/* Binary search */
+	while (hi > lo) {
+		if ((x >> guess) > 0) {
+			/* x is more than i bits in length */
+			lo = guess;
+			guess = (hi + guess + 1) >> 1;
+		} else {
+			hi = guess - 1;
+			guess = (lo + guess) >> 1;
+		}
+	}
+
+	return hi + 1;
+}
+
+/*
+ * Returns the log base 2 for a number, always rounding down.
+ * sa_log2 example input->output
+ * 0->4294967295, 1->0, 2->1, 3->1, 4->2, 5->2, 6->2, 7->2, 8->3, 9->3
+ */
+static inline u32 sa_log2(u32 x)
+{
+	return sa_required_bits(x) - 1;
+}
+
+/*
+ * "greater than power of 2"
+ * Returns the next higher power of 2 -- even if input is a power of 2.
+ * input->output
+ * 0->1, 1->2, 2->4, 3->4, 4->8, 5->8, 6->8, 7->8, 8->16, 9->16
+ */
+static inline u32 sa_gt_power2(u32 x)
+{
+	x = sa_required_bits(x);
+
+	if (x >= 32)
+		/* error -- cannot represent this number in 32 bits */
+		return (u32) 0xFFFFFFFF;
+
+	return (1 << x);
+}
+
+/*
+ * Status code datatype
+ */
+typedef int SA_STATUS, *PSA_STATUS;
+
+/* Error codes */
+#define SA_SUCCESS             (0x00000000L)
+
+/*-------- Basic defines -------*/
+
+/*
+ * Returns number of pages spanned by the size of data
+ * starting at the given address.
+ */
+#define SA_PAGES_SPANNED(_address, _size) \
+   ((u32)(((SA_PTR_TO_INT(_address) & (PAGE_SIZE - 1)) + \
+		(_size) + (PAGE_SIZE - 1)) >> PAGE_SHIFT))
+/*
+ * Appropriate casts to avoid compiler warnings about casting between
+ * integers and pointers.
+ */
+#define SA_PTR_TO_INT(_p_) ((size_t)(_p_))
+#define SA_PTR_TO_U32(_p_) ((u32)SA_PTR_TO_INT(_p_))
+#define SA_PTR_TO_U64(_p_) ((u64)SA_PTR_TO_INT(_p_))
+
+#define SA_PTR_TO_INT(_p_) ((size_t)(_p_))
+#define SA_U64_TO_PTR(_u_) ((void *)(size_t)(_u_))
+#define SA_U32_TO_PTR(_u_) ((void *)(size_t)(_u_))
+#define SA_PAGE_OFFSET(_addr_) (SA_PTR_TO_INT(_addr_) & (PAGE_SIZE-1))
+
+/* Conversion from 64 bit values to hi and lo 32-bit values. */
+static inline u32 sa_hi(u64 quad)
+{
+	return (u32) (quad >> 32);
+}
+static inline u32 sa_lo(u64 quad)
+{
+	return (u32) (quad);
+}
+
+static inline u64 sa_make_u64(u32 hi, u32 lo)
+{
+	return (((u64) hi) << 32) | lo;
+}
+
+static inline u32 sa_pvoid_hi(void *p)
+{
+	return sa_hi(SA_PTR_TO_U64(p));
+}
+
+static inline u32 sa_pvoid_lo(void *p)
+{
+	return sa_lo(SA_PTR_TO_U64(p));
+}
+
+static inline void *sa_make_pvoid(u32 hi, u32 lo)
+{
+	return SA_U64_TO_PTR(sa_make_u64(hi, lo));
+}
+
+/* Returns byte offset of field within given struct type. */
+#define SA_FIELD_OFFSET(_type_, _field_)              \
+	(SA_PTR_TO_U32((u8 *)&(((struct _type_ *)0)->_field_)))
+
+/* Returns byte size of given field with a structure. */
+#define SA_SIZEOF_FIELD(_type_, _field_)  \
+	sizeof(((struct _type_ *)0)->_field_)
+
+/* Returns the number of items in the field array. */
+#define SA_NUMBER_OF_FIELD(_type_, _field_)				\
+	(SA_SIZEOF_FIELD(_type_, _field_) / 				\
+			sizeof((((struct _type_ *)0)->_field_[0])))
+
+/* Returns x/y plus 1 if there is a remainder. */
+static inline u32 sa_ceiling(u32 x, u32 y)
+{
+	ASSERT(y > 0);
+	return (x + y - 1) / y;
+}
+
+/*
+ * circular subtract.
+ * Returns a - b assuming a circular number system, where a and b are
+ * in range (0, maxValue-1). If a==b, zero is returned so the
+ * highest value possible with this subtraction is maxValue-1.
+ */
+static inline u32 sa_subc(u32 a, u32 b, u32 max)
+{
+	ASSERT(a <= max && b <= max);
+	ASSERT(max > 0);
+	return (a >= b ? (a - b) : (max - b + a));
+}
+
+static inline u32 sa_addc(u32 a, u32 b, u32 max)
+{
+	ASSERT(a < max);
+	ASSERT(max > 0);
+	return ((max - a > b) ? (a + b) : (b + a - max));
+}
+
+/*------- SGL related ------*/
+
+/* descriptor for a physically contiguous  memory region */
+struct sa_sgl {
+	u32 length;
+	void *va;
+	u64 pa;
+} ;
+
+static inline u32 sa_sgl_get_byte_count(struct sa_sgl *sgl)
+{
+	return sgl->length;
+}
+
+static inline u32 sa_sgl_get_page_count(struct sa_sgl *sgl)
+{
+	return SA_PAGES_SPANNED(sgl->va, sgl->length);
+}
+
+static inline void *sa_sgl_get_base_va(struct sa_sgl *sgl)
+{
+	return sgl->va;
+}
+
+static inline u32 sa_sgl_get_offset(struct sa_sgl *sgl)
+{
+	return SA_PAGE_OFFSET(sgl->va);
+}
+
+/*
+ * Creates a SGL for a physically contiguous chunk of memory.
+ * The sgl struct must be previously allocated.
+ */
+static inline SA_STATUS
+sa_sgl_create_contiguous(void *va, u64 pa, u32 length, struct sa_sgl *sgl)
+{
+
+	sgl->va = va;
+	sgl->pa = pa;
+	sgl->length = length;
+	return SA_SUCCESS;
+}
+
+/*
+ *------- ring manipulation related ------
+ * This structure stores information about a ring shared between hardware
+ * and software.  Each ring is allocated by the driver in the uncached
+ * extension and mapped into BladeEngine's unified table.  BEKLIB manages
+ * creation and destruction of the rings in hardware.  It returns the
+ * corresponding HANDLE to the ring.
+ */
+struct sa_ring {
+	u32 pages;		/* queue size in pages */
+	u32 id;			/* queue id assigned by beklib */
+	u32 num;		/* number of elements in queue */
+	u32 cidx;		/* consumer index */
+	u32 pidx;		/* producer index -- not used by most rings */
+	u32 itemSize;		/* size in bytes of one object */
+
+	void *va;		/* The virtual address of the ring.
+				   This should be last to allow 32 & 64
+				   bit debugger extensions to work. */
+
+} ;
+
+static
+inline void sa_ring_create(struct sa_ring *ring,
+			       u32 num, u32 itemSize, void *va)
+{
+	ASSERT(ring);
+	memset(ring, 0, sizeof(struct sa_ring));
+	ring->num = num;
+	ring->pages = sa_ceiling(num * itemSize, PAGE_SIZE);
+	ring->itemSize = itemSize;
+	ring->va = va;
+}
+
+static inline void sa_ring_set_id(struct sa_ring *ring, u32 id)
+{
+	ASSERT(ring);
+	ring->id = id;
+}
+
+static inline u32 sa_ring_num(struct sa_ring *ring)
+{
+	ASSERT(ring);
+	return ring->num;
+}
+
+static inline void *sa_ring_va(struct sa_ring *ring)
+{
+	ASSERT(ring);
+	return ring->va;
+}
+
+static inline void sa_ring_clear(struct sa_ring *ring)
+{
+	ASSERT(ring);
+	ring->pidx = ring->cidx = 0;
+}
+
+/*
+ * -----------------------------------------------------------------------
+ * Interface for 2 index rings. i.e. consumer/producer rings
+ * --------------------------------------------------------------------------
+ */
+
+/* Returns TRUE if ring is empty */
+static inline bool sa_ring_is_empty(struct sa_ring *ring)
+{
+	ASSERT(ring);
+	return (ring->pidx == ring->cidx);
+}
+
+/* Define the power2 version equivalent */
+#define sa_ring_power2_is_empty sa_ring_is_empty
+
+/* Returns number items pending on ring. */
+static inline u32 sa_ring_num_pending(struct sa_ring *ring)
+{
+	ASSERT(ring);
+	if (ring->num == 0)
+		return 0;
+	return sa_subc(ring->pidx, ring->cidx, ring->num);
+}
+
+/* Returns number items free on ring. */
+static inline u32 sa_ring_num_empty(struct sa_ring *ring)
+{
+	ASSERT(ring);
+	return ring->num - 1 - sa_ring_num_pending(ring);
+}
+
+/* Returns TRUE if ring is full */
+static inline bool sa_ring_is_full(struct sa_ring *ring)
+{
+	ASSERT(ring);
+	return sa_ring_num_pending(ring) == (ring->num - 1);
+}
+
+/* Consume 1 item */
+static inline void sa_ring_consume(struct sa_ring *ring)
+{
+	ASSERT(ring);
+	ASSERT(!sa_ring_is_empty(ring));
+	ring->cidx = sa_addc(ring->cidx, 1, ring->num);
+}
+
+/* Produce 1 item */
+static inline void sa_ring_produce(struct sa_ring *ring)
+{
+	ASSERT(ring);
+	ASSERT(!sa_ring_is_full(ring));
+	ring->pidx = sa_addc(ring->pidx, 1, ring->num);
+}
+
+/* Consume count items */
+static inline void sa_ring_consume_multiple(struct sa_ring *ring, u32 count)
+{
+	ASSERT(ring);
+	ASSERT(sa_ring_num_pending(ring) >= count);
+	ring->cidx = sa_addc(ring->cidx, count, ring->num);
+}
+
+static inline void *sa_ring_item(struct sa_ring *ring, u32 index)
+{
+	ASSERT(ring);
+	ASSERT(index < ring->num);
+	ASSERT(ring->itemSize > 0);
+	return (u8 *) ring->va + index * ring->itemSize;
+}
+
+#define sa_ring_power2_item sa_ring_item
+
+/* Ptr to produce item */
+static inline void *sa_ring_producer_ptr(struct sa_ring *ring)
+{
+	ASSERT(ring);
+	ASSERT(!sa_ring_is_full(ring));
+	return sa_ring_item(ring, ring->pidx);
+}
+
+#define sa_ring_power2_producer_ptr sa_ring_producer_ptr
+
+/*
+ * Returns a pointer to the current location in the ring.
+ * This is used for rings with 1 index.
+ */
+static inline void *sa_ring_current(struct sa_ring *ring)
+{
+	ASSERT(ring);
+	ASSERT(ring->pidx == 0);	/* not used */
+
+	return sa_ring_item(ring, ring->cidx);
+}
+
+/* Ptr to consume item */
+static inline void *sa_ring_consumer_ptr(struct sa_ring *ring)
+{
+	ASSERT(ring);
+	ASSERT(!sa_ring_is_empty(ring));
+	return sa_ring_item(ring, ring->cidx);
+}
+
+#define sa_ring_power2_current sa_ring_current
+
+/*
+ * Increment index for rings with only 1 index.
+ * This is used for rings with 1 index.
+ */
+static inline void *sa_ring_next(struct sa_ring *ring)
+{
+	ASSERT(ring);
+	ASSERT(ring->num > 0);
+	ASSERT(ring->pidx == 0);	/* not used */
+
+	ring->cidx = sa_addc(ring->cidx, 1, ring->num);
+	return sa_ring_current(ring);
+}
+
+/*-----------  amap bit filed get / set macros and functions -----*/
+/*
+ * Structures defined in the map header files (under fw/amap/) with names
+ * in the format BE_<name>_AMAP are pseudo structures with members
+ * of type BE_BIT. These structures are templates that are used in
+ * conjuntion with the structures with names in the format
+ * <name>_AMAP to calculate the bit masks and bit offsets to get or set
+ * bit fields in structures. The structures <name>_AMAP are arrays
+ * of 32 bits words and have the correct size.  The following macros
+ * provide convenient ways to get and set the various members
+ * in the structures without using strucctures with bit fields.
+ * Always use the macros AMAP_GET_BITS_PTR and AMAP_SET_BITS_PTR
+ * macros to extract and set various members.
+ */
+/* Each bit is 1 byte in array maps. */
+typedef u8 AMAP_BIT, BE_BIT;
+
+/*
+ * Returns the a bit mask for the register that is NOT shifted into location.
+ * That means return values always look like: 0x1, 0xFF, 0x7FF, etc...
+ */
+static inline u32 amap_mask(u32 bit_size)
+{
+    return (bit_size == 32 ? 0xFFFFFFFF : (1 << bit_size) - 1);
+}
+
+#define AMAP_BIT_MASK_UNION(_struct_, _register_)       \
+	amap_mask(AMAP_BIT_SIZE_UNION(_struct_, _register_))  \
+
+#define AMAP_BIT_MASK(_struct_, _register_)       \
+	amap_mask(AMAP_BIT_SIZE(_struct_, _register_))  \
+
+/*
+ * non-optimized set bits function. First clears the bits and then assigns them.
+ * This does not require knowledge of the particular DWORD you are setting.
+ * e.g. AMAP_SET_BITS_PTR (struct, field1, &contextMemory, 123);
+ */
+static inline void
+amap_set(void *ptr, u32 dw_offset, u32 mask, u32 offset, u32 value)
+{
+	u32 *dw = (u32 *)ptr;
+	*(dw + dw_offset) &= ~(mask << offset);
+	*(dw + dw_offset) |= (mask & value) << offset;
+}
+
+#define AMAP_SET_BITS_PTR_UNION(_struct_, _register_, _structPtr_, _value_)  \
+	amap_set(_structPtr_, AMAP_WORD_OFFSET_UNION(_struct_, _register_), \
+		AMAP_BIT_MASK_UNION(_struct_, _register_),		\
+		AMAP_BIT_OFFSET_UNION(_struct_, _register_), _value_)	\
+
+#define AMAP_SET_BITS_PTR(_struct_, _register_, _structPtr_, _value_)	\
+	amap_set(_structPtr_, AMAP_WORD_OFFSET(_struct_, _register_),	\
+		AMAP_BIT_MASK(_struct_, _register_),			\
+		AMAP_BIT_OFFSET(_struct_, _register_), _value_)		\
+
+/*
+ * Non-optimized routine that gets the bits without knowing the correct DWORD.
+ * e.g. fieldValue = AMAP_GET_BITS_PTR (struct, field1, &contextMemory);
+ */
+static inline u32
+amap_get(void *ptr, u32 dw_offset, u32 mask, u32 offset)
+{
+	u32 *dw = (u32 *)ptr;
+	return mask & (*(dw + dw_offset) >> offset);
+}
+#define AMAP_GET_BITS_PTR(_struct_, _register_, _structPtr_)		\
+	amap_get(_structPtr_, AMAP_WORD_OFFSET(_struct_, _register_),	\
+		AMAP_BIT_MASK(_struct_, _register_),			\
+			AMAP_BIT_OFFSET(_struct_, _register_))		\
+
+/* Returns 0-31 representing bit offset within a DWORD of a bitfield */
+#define AMAP_BIT_OFFSET_UNION(_struct_, _register_)                  \
+    (((size_t)&(((union BE_ ## _struct_ ## _AMAP*)0)->_register_))%32)
+
+/* Returns 0-31 representing bit offset within a DWORD of a bitfield. */
+#define AMAP_BIT_OFFSET(_struct_, _register_)                  \
+    (((size_t)&(((struct BE_ ## _struct_ ## _AMAP*)0)->_register_))%32)
+
+/* Returns 0-n representing byte offset of bitfield with the structure */
+#define AMAP_BYTE_OFFSET_UNION(_struct_, _register_)                  \
+    (((size_t)&(((union BE_ ## _struct_ ## _AMAP *)0)->_register_))/8)
+
+/* Returns 0-n representing byte offset of bitfield with the structure. */
+#define AMAP_BYTE_OFFSET(_struct_, _register_)                  \
+	(((size_t)&(((struct BE_ ## _struct_ ## _AMAP *)0)->_register_))/8)
+
+/* Returns 0-n representing DWORD offset of bitfield within the structure. */
+#define AMAP_WORD_OFFSET_UNION(_struct_, _register_)  \
+		(AMAP_BYTE_OFFSET_UNION(_struct_, _register_)/4)
+
+/* Returns 0-n representing DWORD offset of bitfield within the structure. */
+#define AMAP_WORD_OFFSET(_struct_, _register_)  \
+		  (AMAP_BYTE_OFFSET(_struct_, _register_)/4)
+
+/*
+ * Gets a pointer to a field within a structure
+ * The field must be byte aligned.
+ */
+#define AMAP_GET_PTR(_struct_, _register_, _structPtr_)                     \
+    (void *) ((u8 *)(_structPtr_) + AMAP_BYTE_OFFSET(_struct_, _register_))
+
+/* Returns size of bitfield in bits. */
+#define AMAP_BIT_SIZE_UNION(_struct_, _register_) \
+		sizeof(((union BE_ ## _struct_ ## _AMAP*)0)->_register_)
+
+/* Returns size of bitfield in bits. */
+#define AMAP_BIT_SIZE(_struct_, _register_) \
+		sizeof(((struct BE_ ## _struct_ ## _AMAP*)0)->_register_)
+
+/* Returns size of bitfield in bytes. */
+#define AMAP_BYTE_SIZE(_struct_) (sizeof(struct BE_ ## _struct_ ## _AMAP)/8)
+
+/* Returns size of bitfield in DWORDS. */
+#define AMAP_WORD_SIZE(_struct_) (AMAP_BYTE_SIZE(_struct_)/4)
+
+static
+inline u64 sa_bit_range64(u64 value, u32 bit_offset, u32 num_bits)
+{
+	ASSERT(bit_offset <= sizeof(value) * 8);
+	ASSERT(num_bits <= sizeof(value) * 8);
+	return (value >> bit_offset) & ((1ULL << num_bits) - 1);
+}
+
+static inline u64 sa_upper_bits64(u64 value, u32 num_bits)
+{
+	ASSERT(num_bits <= sizeof(value) * 8);
+	return sa_bit_range64(value, sizeof(value) * 8 - num_bits, num_bits);
+}
+
+
+#if !defined(BE_CONFIG)
+#define BE_CONFIG 0
+#define CONFIG0
+#endif
+
+/*Id ranges and RID conversions based on config */
+#include "be_gen_id_ranges.h"
+
+/* Srcgen includes */
+
+#include "regmap.h"		/* srcgen array map output */
+#include "be_common_bmap.h"	/* srcgen array map output */
+#include "fwcmd_top.h"		/* srcgen array map output */
+
+#include "fwcmd_top_bmap.h"	/* srcgen bitmap output */
+
+#include "bestatus.h"
+
+/* Debug trace categories. */
+enum BE_DEBUG_LEVELS {
+	DL_HW = 0x00000100,
+	DL_FWCMD = 0x00000200,
+
+	BE_DL_MIN_VALUE = 0x100,	/* this is the min value used */
+	BE_DL_MAX_VALUE = 0x800	/* this is the higheset value used */
+} ;
+
+SA_GLOBAL_C_ASSERT(beclib_debug_level_range,
+		   ((u32) BE_DL_MIN_VALUE > (u32) SA_DL_MAX_VALUE));
+
+#include "beregister.h"	/* Macros for register access using srcgen structs */
+#include "beclib_stats.h"
+
+/*  BECLIB status data type maps to the SA_STATUS */
+typedef SA_STATUS BESTATUS ;
+
+/* Forward declarations. */
+struct be_function_object;
+struct be_eq_object;
+struct be_cq_object;
+
+/* Callback types.  Deprecate most of these. */
+typedef void (*MCC_WRB_CQE_CALLBACK) (void *context,
+				BESTATUS status,
+				struct MCC_WRB_AMAP *optional_wrb);
+typedef void (*MCC_ASYNC_EVENT_CALLBACK) (void *context,
+				u32 event_code,
+				void *event);
+
+typedef BESTATUS(*EQ_CALLBACK) (struct be_function_object *,
+				struct be_eq_object *, void *context);
+typedef BESTATUS(*CQ_CALLBACK) (struct be_function_object *,
+				struct be_cq_object *, void *context);
+
+#endif /* __beclib_common_h__ */
diff --git a/drivers/message/beclib/beclib_ll_bmap_nic.h b/drivers/message/beclib/beclib_ll_bmap_nic.h
new file mode 100644
index 0000000..357f02e
--- /dev/null
+++ b/drivers/message/beclib/beclib_ll_bmap_nic.h
@@ -0,0 +1,1111 @@
+/*
+ * Copyright (C) 2005 - 2008 ServerEngines
+ * All rights reserved.
+ *
+ * This program is free software; you can redistribute it and/or
+ * modify it under the terms of the GNU General Public License version 2
+ * as published by the Free Software Foundation.  The full GNU General
+ * Public License is included in this distribution in the file called COPYING.
+ *
+ * Contact Information:
+ * linux-drivers@serverengines.com
+ *
+ * ServerEngines
+ * 209 N. Fair Oaks Ave
+ * Sunnyvale, CA 94085
+ */
+/*
+ * Autogenerated by srcgen version: 0127
+ */
+#ifndef __beclib_ll_bmap_h__
+#define __beclib_ll_bmap_h__
+
+#ifndef SG_C_ASSERT
+#define SG_C_ASSERT(_name_, _condition_)
+#endif
+
+/*
+ *-----------------------------------------------------
+ * Function: be_initialize_library
+ *   Call to initialize the static library. This initializes the debug traces.
+ * return status - BE_SUCCESS (0) on success. Negative error code on failure.
+ *-----------------------------------------------------
+ */
+BESTATUS be_initialize_library(void);
+
+/*
+ *---------------------------------------------------
+ * Function: be_function_and_chip_create
+ *   Create both function and chip object with one call.
+ *   The lower level API will rarely *   use more than one function object.
+ * sa_dev          - Previously created device.
+ * function_type   -
+ * mailbox_sgl     - SGL with length equal to sizeof(MCC_MAILBOX). This must be
+ *                   physically contiguous. The starting address must be
+ *                   aligned to 16 byte boundary.
+ * emulation_sgl   - SGL with length equal to one page . Must be physically
+ *                   contiguous. Starting address must be 16 byte aligned.
+ * pfob - On input, a pointer to an allocated function object. On
+ *                   output, it is initialized. This is an opaque object.
+ *                   Do not access the members.
+ * chip            - On input this is a pointer to an allocated chip object.
+ * 		     On output, it is initialized. This is an opaque object.
+ * 		     Do not access the members.
+ * return status   - BE_SUCCESS (0) on success. Negative error code on failure.
+ *---------------------------------------------------
+ */
+BESTATUS
+be_function_and_chip_create(struct sa_dev *sa_dev,
+	    u32 function_type, struct sa_sgl *mailbox_sgl,
+	    struct sa_sgl *emulation_sgl, struct be_function_object *pfob,
+	    struct be_chip_object *chip);
+
+/*
+ *---------------------------------------------------
+ * Function: be_function_object_create
+ *   Create function object .
+ * sa_dev          - Previously created device.
+ * function_type   -
+ * mailbox_sgl     - SGL with length equal to sizeof(MCC_MAILBOX).
+ * 		     This must be physically contiguous. The starting
+ * 		     address must be aligned to 16 byte boundary.
+ * pfob - On input this is a pointer to an allocated function
+ * 		     object. On output, it is initialized. This is an
+ * 		     opaque object. Do not access the members.
+ * chip            - On input this is a pointer to an allocated chip object.
+ * 		     On output, it is initialized. This is an opaque object.
+ * 		     Do not access the members.
+ * return status   - BE_SUCCESS (0) on success. Negative error code on failure.
+ *----------------------------------------------------
+ */
+BESTATUS
+be_function_object_create(struct sa_dev *sa_dev,
+	  u32 function_type, struct sa_sgl *mailbox_sgl,
+	  struct be_function_object *pfob, struct be_chip_object *chip);
+
+/*
+ *-----------------------------------------------
+ * Function: be_chip_object_create
+ *   Create chip object .
+ * chip          - On input this is a pointer to an allocated chip object.
+ * 		   On output, it is initialized. This is an opaque object.
+ * 		   Do not access the members.
+ * return status - BE_SUCCESS (0) on success. Negative error code on failure.
+ *---------------------------------------------------------------
+ */
+BESTATUS be_chip_object_create(struct be_chip_object *chip);
+
+/*
+ *---------------------------------------------------------------
+ * Function: be_function_and_chip_destroy
+ *   This destroys the function and chip object created by the
+ *   be_function_and_chip_create function. It assumes that all
+ *   sub-objects created for this function have already been
+ *   destroyed -- it asserts if this is not true. This function is called by
+ *   be_function_cleanup -- Use be_function_cleanup to automatically cleanup all
+ *   sub-objects.
+ * pfob - Previously created function object.
+ * chip            - Previously created chip object.
+ * return status   - BE_SUCCESS (0) on success. Negative error code on failure.
+ *---------------------------------------------------------------
+ */
+BESTATUS
+be_function_and_chip_destroy(struct be_function_object *pfob,
+			     struct be_chip_object *chip);
+
+/*
+ *---------------------------------------------------------------
+ * Function: be_function_object_destroy
+ *   This destroys the function object created by the
+ *   be_function_object_create function.  It assumes that all
+ *   sub-objects created for this function have already been destroyed
+ *   -- it asserts if this is not true. This function is called by
+ *   be_function_cleanup --
+ *   Use be_function_cleanup to automatically cleanup all sub-objects.
+ * pfob - Previously created function object.
+ * chip            - Previously created chip object.
+ * return status   - BE_SUCCESS (0) on success. Negative error code on failure.
+ *---------------------------------------------------------------
+ */
+BESTATUS
+be_function_object_destroy(struct be_function_object *pfob,
+			   struct be_chip_object *chip);
+
+/*
+ *---------------------------------------------------------------
+ * Function: be_chip_object_destroy
+ *   This destroys the chip object created by the
+ *   be_chip_object_create function. It assumes that all sub-objects
+ *   created for this chip have already been destroyed -- it
+ *   asserts if this is not true. This function is called by
+ *   be_function_cleanup -- Use be_function_cleanup to automatically
+ *   cleanup all sub-objects.
+ * chip          - Previously created chip object.
+ * return status - BE_SUCCESS (0) on success. Negative error code on failure.
+ *---------------------------------------------------------------
+ */
+BESTATUS be_chip_object_destroy(struct be_chip_object *chip);
+
+/*
+ *---------------------------------------------------------------
+ * Function: be_function_cleanup
+ *   This function destroys all objects that reference the function
+ *   object including the all queues  (mcc, etx, erx, iscsi/wrbq/defq, eq)  -
+ *   iscsi ooo buffers  - software jell buffers (during emulation)  -
+ *   template header buffers (if host based)  - WDMA
+ *   zero buffer (during emulation)  - vlan tags  - multicast addresses  - rss
+ *   configuration  - wake on lan entries (ACPI)  - chip object  -
+ *   pfob  All objects are destroyed with synchronous FWCMDs
+ *   that poll for their completions. This
+ *   function is optional, all objects can be explicitly cleaned up.
+ * pfob - Previously created function object
+ * return status   - BE_SUCCESS (0) on success. Negative error code on failure.
+ *---------------------------------------------------------------
+ */
+BESTATUS be_function_cleanup(struct be_function_object *pfob);
+
+/*
+ *---------------------------------------------------------------
+ * Function: be_function_get_function_number
+ *   Returns the PCI function number.
+ * pfob        - Previously created function object
+ * return function_number -
+ *---------------------------------------------------------------
+ */
+u32 be_function_get_function_number(struct be_function_object *pfob);
+
+/*
+ *---------------------------------------------------------------
+ * Function: be_function_get_function_type
+ *   Returns the function type.
+ * return function_type -
+ *---------------------------------------------------------------
+ */
+u32 be_function_get_function_type(struct be_function_object *pfob);
+
+/*
+ *---------------------------------------------------------------
+ * Function: be_function_is_iscsi
+ *   Returns TRUE for the ISCSI function.
+ * return is_iscsi -
+ *---------------------------------------------------------------
+ */
+static inline bool be_function_is_iscsi(struct be_function_object *pfob);
+
+/*
+ *---------------------------------------------------------------
+ * Function: be_function_is_networking
+ *   Returns TRUE for the networking function.
+ * return is_networking -
+ *---------------------------------------------------------------
+ */
+static inline bool be_function_is_networking(struct be_function_object *pfob);
+
+/*
+ *---------------------------------------------------------------
+ * Function: be_function_get_fw_version
+ *   Retrieves the firmware version on the adpater. If the callback
+ *   is NULL this call executes synchronously. If the callback is
+ *   not NULL, the returned status will be BE_PENDING if the
+ *   command was issued successfully.
+ * pfob    -
+ * fw_version         - Pointer to response buffer if callback is NULL.
+ * callback           - Callback function invoked when the FWCMD completes.
+ * callback_context   - Passed to the callback function.
+ * return pend_status - BE_SUCCESS (0) on success.
+ * 			BE_PENDING (postive value) if the FWCMD
+ *                      completion is pending. Negative error code on failure.
+ *---------------------------------------------------------------
+ */
+BESTATUS
+be_function_get_fw_version(struct be_function_object *pfob,
+	struct FWCMD_COMMON_GET_FW_VERSION_RESPONSE_PAYLOAD *fw_version,
+	MCC_WRB_CQE_CALLBACK callback, void *callback_context);
+
+/*
+ *---------------------------------------------------------------
+ * Function: be_eq_modify_delay
+ *   Changes the EQ delay for a group of EQs.
+ * pfob    -
+ * num_eq             - The number of EQs in the eq_array to adjust.
+ * 			This also is the number of delay values in the
+ * 			eq_delay_array.
+ * eq_array           - Array of struct be_eq_object pointers to adjust.
+ * eq_delay_array     - Array of "num_eq" timer delays in units of
+ * 			microseconds. The be_eq_query_delay_range fwcmd
+ * 			returns the resolution and range of legal EQ delays.
+ * callback           -
+ * callback_context   -
+ * queue_context      - Optional. Pointer to a previously allocated struct.
+ * 			If the MCC WRB ring is full, this structure is
+ * 			used to queue the operation. It will be posted to
+ * 			the MCC ring when space becomes available. All
+ *                      queued commands will be posted to the ring
+ *                      in the order they are received. It is always
+ *                      valid to pass a pointer to a generic
+ *                      be_generic_queue_context. However, the
+ *                      specific context structs
+ *                      are generally smaller than the generic struct.
+ * return pend_status - BE_SUCCESS (0) on success.
+ * 			BE_PENDING (postive value) if the FWCMD
+ *                      completion is pending. Negative error code on failure.
+ *---------------------------------------------------------------
+ */
+BESTATUS
+be_eq_modify_delay(struct be_function_object *pfob,
+		   u32 num_eq, struct be_eq_object **eq_array,
+		   u32 *eq_delay_array, MCC_WRB_CQE_CALLBACK callback,
+		   void *callback_context,
+		   struct be_eq_modify_delay_queue_context *queue_context);
+
+/*
+ *---------------------------------------------------------------
+ * Function: be_eq_query_delay_range
+ *   Queries the resolution and range allowed for EQ delay. This is
+ *   a constant set by the firmware, so it may be queried one time
+ *   at system boot. It is the same for all EQs.  This is a synchronous FWCMD.
+ * pfob     -
+ * eq_delay_resolution - Resolution of EQ delay in microseconds.
+ * eq_delay_max        - Max value of EQ delay in microseconds.
+ * return status       - BE_SUCCESS (0) on success. Negative error code
+ * 			on failure.
+ *---------------------------------------------------------------
+ */
+BESTATUS
+be_eq_query_delay_range(struct be_function_object *pfob,
+			u32 *eq_delay_resolution, u32 *eq_delay_max);
+
+/*
+ *---------------------------------------------------------------
+ * Function: be_eq_create
+ *   Creates an eq_object. This is a synchronous FWCMD.
+ * pfob -
+ * sgl             - No virtual address required.
+ * eqe_size        - EQ entry size in bytes. Either 4 or 16.
+ * num_entries     - Power of 2, fom 256 to 4k.
+ * watermark       - Eventable CQs only. CEV_WMARK_* or ~0UL for no watermark.
+ * timer_delay     - Interrupt timer delay. ~0UL disables timer. Otherwise,
+ * 			it is eq_delay_resolution units up to eq_delay_max
+ * 			decimal. The resolution and max are queried from
+ * 			be_eq_query_delay_range. e.g. If an 16 us delay
+ * 			is required, timer_delay should be
+ * 			8us/eq_delay_resolution.
+ * eq_object       - Created EQ object.
+ * return status   - BE_SUCCESS (0) on success. Negative error code on failure.
+ *---------------------------------------------------------------
+ */
+BESTATUS
+be_eq_create(struct be_function_object *pfob,
+	     struct sa_sgl *sgl, u32 eqe_size, u32 num_entries,
+	     u32 watermark, u32 timer_delay, struct be_eq_object *eq_object);
+
+
+/*
+ *---------------------------------------------------------------
+ * Function: be_eq_destroy
+ *   Destroys an eq_object. This function is called as part of
+ *   be_function_cleanup.
+ * eq            -
+ * return status - BE_SUCCESS (0) on success. Negative error code on failure.
+ *---------------------------------------------------------------
+ */
+BESTATUS be_eq_destroy(struct be_eq_object *eq);
+
+/*
+ *---------------------------------------------------------------
+ * Function: be_eq_get_id
+ *   Return the allocated ID that must be used to ring the doorbell for the EQ.
+ *---------------------------------------------------------------
+ */
+u32 be_eq_get_id(struct be_eq_object *eq);
+
+/*
+ *---------------------------------------------------------------
+ * Function: be_cq_create
+ *   Creates a CQ. This uses a synchronous FWCMD.
+ * pfob     -
+ * sgl                 - No virtual address required, except for MCC CQ.
+ * length              - Length is bytes of queue. Number of entries is
+ * 			power of 2, from 256 to 1k.  solicited_eventable -
+ * 			If TRUE, only CQEs with solicited event bit cause
+ * 			eqe write.
+ * no_delay            - If eventable, TRUE means force interrupt
+ * 			immediately (ignore watermark & timer).
+ * wm_thresh           - If eventable, watermark encodings CEV_WMARK_* or
+ * 			~0UL for no watermark.
+ * eq_object           - Optional, if set this is an eventable CQ.
+ * cq_object           - Created CQ object.
+ * return status       - BE_SUCCESS (0) on success.
+ * 			Negative error code on failure.
+ *---------------------------------------------------------------
+ */
+BESTATUS
+be_cq_create(struct be_function_object *pfob,
+	struct sa_sgl *sgl, u32 length,
+	bool solicited_eventable, bool no_delay,
+	u32 wm_thresh, struct be_eq_object *eq_object,
+	struct be_cq_object *cq_object);
+
+/*
+ *---------------------------------------------------------------
+ * Function: be_cq_destroy
+ *   Destroys a CQ. All clients that reference this CQ must
+ *   be destroyed first. This function is called as part of
+ *   be_function_cleanup.
+ * cq            -
+ * return status - BE_SUCCESS (0) on success. Negative error code on failure.
+ *---------------------------------------------------------------
+ */
+BESTATUS be_cq_destroy(struct be_cq_object *cq);
+
+/*
+ *---------------------------------------------------------------
+ * Function: be_cq_get_id
+ *   Returns the allocated CQ id used for ringing the doorbell.
+ * return id -
+ *---------------------------------------------------------------
+ */
+u32 be_cq_get_id(struct be_cq_object *cq);
+
+/*
+ *---------------------------------------------------------------
+ * Function: be_mcc_ring_create
+ *   This creates a MCC ring and switches from mailbox mode to ring mode.
+ *   The number of outstanding MCC commands is the minimum of the
+ *   number of entries in the ring and the number of context structures
+ *   (i.e. num_context_entries). BECLIB uses the context entries to
+ *   track outstanding MCC WRBs since they may complete out-of-order. You may
+ *   provide zero context entries, which will limit BECLIB to one
+ *   MCC WRB at a time.
+ * sgl                 - A virtual address is required.
+ * length              - length in bytes
+ * context_array       - Array of context structs. Each outstanding MCC WRB
+ * 			 requires a context entry. BECLIB has 1 by
+ * 			 default. The context array allows you to post
+ * 			 more -- this must be non-pageable memory, but it is
+ *                       not used for DMA. Most likely the number of
+ *                       context structs will match the size of the
+ *                       MCC ring. Since commands complete out-of-order,
+ *                       this lets beclib fully utilize the ring. However,
+ *                       the size may be either lower or higher than
+ *                       the ring size.  num_context_entries - number of
+ *                       context structs
+ * cq                  - Associated completion queue created with an SGL
+ * 			 with a mapped virtual address
+ * mcc                 - On input this is a pointer to an allocated
+ * 			 MCC_OBJECT On ouput this is a created MCC object.
+ * 			 This is an opaque object. Do not reference any
+ * 			 members.
+ * return status       - BE_SUCCESS (0) on success.
+ * 			 Negative error code on failure.
+ *---------------------------------------------------------------
+ */
+BESTATUS
+be_mcc_ring_create(struct be_function_object *pfob,
+		   struct sa_sgl *sgl, u32 length,
+		   struct be_mcc_wrb_context *context_array,
+		   u32 num_context_entries,
+		   struct be_cq_object *cq, struct be_mcc_object *mcc);
+
+/*
+ *---------------------------------------------------------------
+ * Function: be_mcc_ring_destroy
+ *   Cleans up MCC ring and switches to mailbox mode. This function is
+ *   called as part of be_function_cleanup.
+ * mcc_object    -
+ * return status - BE_SUCCESS (0) on success. Negative error code on failure.
+ *---------------------------------------------------------------
+ */
+BESTATUS be_mcc_ring_destroy(struct be_mcc_object *mcc_object);
+
+/*
+ *---------------------------------------------------------------
+ * Function: be_mcc_process_cq
+ *   Processes mcc completions. This should be called from
+ *   the interrupt or DPC to process the MCC cq, when a corresponding
+ *   event queue entry is received. It can also be called to
+ *   poll the CQ from a timer routine for non-eventable completions.
+ *   Keep in mind, only one thread can be inside beclib at any
+ *   given time. That means this function must be
+ *   serialized with the posting of MCC WRBs.
+ * mcc_object    -
+ * rearm         - rearm should be TRUE only if called due to EQE
+ * return status - BE_SUCCESS (0) on success. Negative error code on failure.
+ *---------------------------------------------------------------
+ */
+BESTATUS be_mcc_process_cq(struct be_mcc_object *mcc_object, bool rearm);
+
+/*
+ *---------------------------------------------------------------
+ * Function: be_mcc_add_async_event_callback
+ * mcc_object       -
+ * callback         - Function callback invoked when an asynchronous event
+ * 			is received on the MCC cq. It follows the prototype:
+ *  typedef void (*MCC_ASYNC_EVENT_CALLBACK) (void *context,
+ *  				u32 event_code, void *event);
+ *
+ *  			The context parameter is a copy of the
+ *  			callback_context pointer provided to this function.
+ *  			The event_code is the code from the common
+ *  			portion of the event entry. The event
+ *  			parameter is a pointer to the 16 byte async
+ *  			event message.
+ * callback_context - Passed to the callback function.
+ * return status    - BE_SUCCESS (0) on success. Negative error code on
+ * 			failure.
+ *---------------------------------------------------------------
+ */
+BESTATUS
+be_mcc_add_async_event_callback(struct be_mcc_object *mcc_object,
+		MCC_ASYNC_EVENT_CALLBACK callback, void *callback_context);
+
+/*
+ *---------------------------------------------------------------
+ * Function: be_pci_soft_reset
+ *   This function is called to issue a BladeEngine soft reset. Callers
+ *   should acquire the soft reset semaphore before calling this function.
+ *   Additionaly, callers should ensure they cannot be pre-empted while
+ *   the routine executes. Upon completion of this routine, callers
+ *   should release the reset semaphore. This routine implicitly waits
+ *   for BladeEngine POST to complete.
+ * pfob -
+ * return status   - BE_SUCCESS (0) on success. Negative error code on failure.
+ *---------------------------------------------------------------
+ */
+BESTATUS be_pci_soft_reset(struct be_function_object *pfob);
+
+
+/*
+ *---------------------------------------------------------------
+ * Function: be_drive_POST
+ *   This function is called to drive BladeEngine POST. The
+ *   caller should ensure they cannot be pre-empted while this routine
+ *   executes.
+ * pfob -
+ * return status   - BE_SUCCESS (0) on success. Negative error code on failure.
+ *---------------------------------------------------------------
+ */
+BESTATUS be_drive_POST(struct be_function_object *pfob);
+
+/*
+ *---------------------------------------------------------------
+ * Function: be_eth_sq_create
+ *   Creates an ethernet send ring.
+ * pfob -
+ * sgl             - no virtual address required
+ * length_in_bytes -
+ * type            - The type of ring to create.
+ * ulp             - The requested ULP number for the ring. This
+ * 			should be zero based, i.e. 0,1,2. This must be valid
+ * 			NIC ULP based on the firmware config.  All
+ * 			doorbells for this ring must be sent to this ULP. The
+ * 			first network ring allocated for each ULP are
+ * 			igher performance than subsequent rings.
+ * cq_object       - cq object for completions
+ * eth_sq          -
+ * return status   - BE_SUCCESS (0) on success. Negative error code on failure.
+ *---------------------------------------------------------------
+ */
+BESTATUS
+be_eth_sq_create(struct be_function_object *pfob,
+		struct sa_sgl *sgl, u32 length_in_bytes,
+		u32 type, u32 ulp, struct be_cq_object *cq_object,
+		struct be_ethsq_object *eth_sq);
+
+/*
+ * This is a set of optional parameters for be_eth_sq_create_ex. Certain
+ * ring types require additional parameters provided in this struct.
+ */
+struct be_eth_sq_parameters {
+	u32 port;
+	u32 rsvd0[2];
+} ;
+
+/*
+ *---------------------------------------------------------------
+ * Function: be_eth_sq_create_ex
+ *   Creates an ethernet send ring - extended version with additional parameters
+ * pfob -
+ * sgl             - no virtual address required
+ * length_in_bytes -
+ * type            - The type of ring to create.
+ * ulp             - The requested ULP number for the ring. This
+ * 			should be zero based, i.e. 0,1,2. This must be
+ * 			valid NIC ULP based on the firmware config.
+ * 			All doorbells for this ring must be sent to
+ * 			this ULP. The first network ring allocated for
+ * 			each ULP are higher performance than subsequent rings.
+ * cq_object       - cq object for completions
+ * ex_parameters   - Additional parameters (that may increase in future
+ * 			revisions). These parameters are only used for
+ * 			certain ring types -- see BE_ETH_SQ_PARAMETER
+ * 			for details.
+ * eth_sq          -
+ * return status   - BE_SUCCESS (0) on success. Negative error code on failure.
+ *---------------------------------------------------------------
+ */
+BESTATUS
+be_eth_sq_create_ex(struct be_function_object *pfob,
+		    struct sa_sgl *sgl, u32 length_in_bytes,
+		    u32 type, u32 ulp, struct be_cq_object *cq_object,
+		    struct be_eth_sq_parameters *ex_parameters,
+		    struct be_ethsq_object *eth_sq);
+
+/*
+ *---------------------------------------------------------------
+ * Function: be_eth_sq_destroy
+ *   Destroys an ethernet send ring. The driver must wait for
+ *   all send completions before destroying the ring. This function
+ *   is called as part of be_function_cleanup.
+ * eth_sq        -
+ * return status - BE_SUCCESS (0) on success. Negative error code on failure.
+ *---------------------------------------------------------------
+ */
+BESTATUS be_eth_sq_destroy(struct be_ethsq_object *eth_sq);
+
+/*
+ *---------------------------------------------------------------
+ * Function: be_eth_sq_get_id
+ *   Query the allocated id for the send ring. This ID is used
+ *   to ring the doorbell.
+ *---------------------------------------------------------------
+ */
+u32 be_eth_sq_get_id(struct be_ethsq_object *eth_sq);
+
+/*
+ *---------------------------------------------------------------
+ * Function: be_eth_set_flow_control
+ *   This function sets the flow control characteristics of BladeEngine.
+ * return status   - BE_SUCCESS (0) on success. Negative error code on failure.
+ *---------------------------------------------------------------
+ */
+BESTATUS
+be_eth_set_flow_control(struct be_function_object *pfob,
+			bool txfc_enable, bool rxfc_enable);
+
+/*
+ *---------------------------------------------------------------
+ * Function: be_eth_get_flow_control
+ *   This function gets the flow control characteristics of BladeEngine.
+ * return status   - BE_SUCCESS (0) on success. Negative error code on failure.
+ *---------------------------------------------------------------
+ */
+BESTATUS
+be_eth_get_flow_control(struct be_function_object *pfob,
+			bool *txfc_enable, bool *rxfc_enable);
+
+/*
+ *---------------------------------------------------------------
+ * Function: be_eth_set_qos
+ *   This function sets the ethernet transmit Quality of Service (QoS)
+ *   characteristics of BladeEngine for the domain. All ethernet transmit
+ *   rings of the domain will evenly share the bandwidth. The exeception
+ *   to sharing is the host primary (super) ethernet transmit
+ *   ring as well as the host ethernet forwarding ring for missed offload
+ *   data.
+ * max_bps         - the maximum bits per second in units of
+ * 			10 Mbps (valid 0-100)
+ * max_pps         - the maximum packets per second in units
+ * 			of 1 Kpps (0 indicates no limit)
+ * return status   - BE_SUCCESS (0) on success. Negative error code on failure.
+ *---------------------------------------------------------------
+ */
+BESTATUS
+be_eth_set_qos(struct be_function_object *pfob, u32 max_bps, u32 max_pps);
+
+/*
+ *---------------------------------------------------------------
+ * Function: be_eth_get_qos
+ *   This function retrieves the ethernet transmit Quality of Service (QoS)
+ *   characteristics for the domain.
+ * pfob -
+ * max_bps         - the maximum bits per second in units of 10
+ * 			Mbps (valid 0-100)
+ * max_pps         - the maximum packets per second in units of
+ * 			1 Kpps (0 indicates no limit)
+ * return status   - BE_SUCCESS (0) on success. Negative error code on failure.
+ *---------------------------------------------------------------
+ */
+BESTATUS
+be_eth_get_qos(struct be_function_object *pfob, u32 *max_bps, u32 *max_pps);
+
+/*
+ *---------------------------------------------------------------
+ * Function: be_eth_set_frame_size
+ *   This function sets the ethernet maximum frame size. The
+ *   previous values are returned.
+ * pfob -
+ * tx_frame_size   - maximum transmit frame size in bytes
+ * rx_frame_size   - maximum receive frame size in bytes
+ * return status   - BE_SUCCESS (0) on success. Negative error code on failure.
+ *---------------------------------------------------------------
+ */
+BESTATUS
+be_eth_set_frame_size(struct be_function_object *pfob,
+		      u32 *tx_frame_size, u32 *rx_frame_size);
+
+/*
+ *---------------------------------------------------------------
+ * Function: be_eth_rq_create
+ *   Creates an ethernet receive ring for posting rx buffers. Each
+ *   buffer posted to the ring should be the size indicated from
+ *   calling the be_eth_rq_get_frag_size function.
+ *   Only the host protection domain can receive broadcast/multicast
+ *   frames. It can choose to receive the CQ entries for these
+ *   frames on a separate completion queue, or it can
+ *   use the same CQ. This is determines by the bcmc_cq_object parameter.
+ * return status   - BE_SUCCESS (0) on success. Negative error code on failure.
+ *---------------------------------------------------------------
+ */
+BESTATUS
+be_eth_rq_create(struct be_function_object *pfob,
+		 struct sa_sgl *sgl, struct be_cq_object *cq_object,
+		 struct be_cq_object *bcmc_cq_object,
+		 struct be_ethrq_object *eth_rq);
+
+/*
+ *---------------------------------------------------------------
+ * Function: be_eth_rq_destroy
+ *   Destroys an ethernet receive ring. This function is called as part of
+ *   be_function_cleanup.
+ * return status - BE_SUCCESS (0) on success. Negative error code on failure.
+ *---------------------------------------------------------------
+ */
+BESTATUS be_eth_rq_destroy(struct be_ethrq_object *eth_rq);
+
+/*
+ *---------------------------------------------------------------
+ * Function: be_eth_rq_destroy_options
+ *   Destroys an ethernet receive ring with finer granularity
+ *   options than the standard be_eth_rq_destroy() API function.
+ * eth_rq           -
+ * flush            - Set to 1 to flush the ring, set to 0 to
+ * 			bypass the flush and force invalidation.
+ * callback         - Callback function on completion
+ * callback_context - Callback context
+ * return status    - BE_SUCCESS (0) on success. Negative error
+ * 			code on failure.
+ *---------------------------------------------------------------
+ */
+BESTATUS
+be_eth_rq_destroy_options(struct be_ethrq_object *eth_rq, bool flush,
+		MCC_WRB_CQE_CALLBACK callback, void *callback_context);
+
+/*
+ *---------------------------------------------------------------
+ * Function: be_eth_rq_destroy_async
+ *   Same as be_eth_rq_destroy, but this version allows an async callback.
+ * return pend_status - BE_SUCCESS (0) on success.
+ * 			BE_PENDING (postive value) if the FWCMD
+ *                      completion is pending. Negative error code on failure.
+ *---------------------------------------------------------------
+ */
+BESTATUS
+be_eth_rq_destroy_async(struct be_ethrq_object *eth_rq,
+		MCC_WRB_CQE_CALLBACK callback, void *callback_context);
+
+/*
+ *---------------------------------------------------------------
+ * Function: be_eth_rq_get_id
+ *   Queries the allocated ID for the ethernet receive ring.
+ *   This should be used for ringing the doorbell to post buffers.
+ *---------------------------------------------------------------
+ */
+u32 be_eth_rq_get_id(struct be_ethrq_object *EthRq);
+
+/*
+ *---------------------------------------------------------------
+ * Function: be_eth_rq_set_frag_size
+ *   Changes the global ethernet receive fragment size. This
+ *   is very expensive and should rarely be done.  This function may
+ *   require a reboot for the fragsize to take affect. If the function
+ *   succeeds, and the returned actual_frag_size_bytes does not match
+ *   new_frag_size_bytes, then the driver must continue to use
+ *   the actual_frag_size_bytes until the next reboot.
+ * pfob        -
+ * new_frag_size_bytes    - New frag size to set. This must be a
+ * 				power of 2, from 128 to 16k.
+ * actual_frag_size_bytes - The current actual frag size. If the function
+ * 				succeeds, and this differs from the
+ * 				new_frag_size_bytes, then the new frag
+ * 				size will be applied after a reboot.
+ * 				The driver must use this size.
+ * return status          - BE_SUCCESS (0) on success. Negative error
+ * 				code on failure.
+ *---------------------------------------------------------------
+ */
+BESTATUS
+be_eth_rq_set_frag_size(struct be_function_object *pfob,
+		u32 new_frag_size_bytes, u32 *actual_frag_size_bytes);
+
+/*
+ *---------------------------------------------------------------
+ * Function: be_eth_rq_get_frag_size
+ *   Queries the global ethernet receive fragment size. All drivers
+ *   should query the frag size and use the specified size.
+ *   Alternatively, they should use the maximum fragment size.
+ * pfob -
+ * frag_size_bytes - The current actual frag size. If the function
+ * 			succeeds, and this differs from the
+ * 			new_frag_size_bytes, then the new frag size will be
+ * 			applied after a reboot. The driver must use this size.
+ * return status   - BE_SUCCESS (0) on success. Negative error code on failure.
+ *---------------------------------------------------------------
+ */
+BESTATUS
+be_eth_rq_get_frag_size(struct be_function_object *pfob, u32 *frag_size_bytes);
+
+/*
+ *---------------------------------------------------------------
+ * Function: be_function_prepare_embedded_fwcmd
+ *   Use the BE_PREPARE_EMBEDDED_FWCMD macro, instead of calling this
+ *   function directly.
+ *---------------------------------------------------------------
+ */
+void *
+be_function_prepare_embedded_fwcmd(struct be_function_object *pfob,
+		   struct MCC_WRB_AMAP *wrb,
+		   u32 payload_length, u32 request_length,
+		   u32 response_length, u32 opcode, u32 subsystem);
+/*
+ *---------------------------------------------------------------
+ * Function: be_function_prepare_nonembedded_fwcmd
+ *   Use the BE_PREPARE_NONEMBEDDED_FWCMD macro, instead of
+ *   calling this function directly.
+ *---------------------------------------------------------------
+ */
+void *
+be_function_prepare_nonembedded_fwcmd(struct be_function_object *pfob,
+	struct MCC_WRB_AMAP *wrb, void *fwcmd_header_va, u64 fwcmd_header_pa,
+	u32 payload_length, u32 request_length, u32 response_length,
+	u32 opcode, u32 subsystem);
+
+
+/*
+ *---------------------------------------------------------------
+ * Function: be_function_peek_mcc_wrb
+ *   Returns a pointer to the next WRB to post, either the mailbox
+ *   buffer or the next WRB in the ring. When using this function,
+ *   the caller must ensure that no other thread
+ *   will post an MCC wrb until after this WRB is posted.
+ * return wrb      - Pointer to the next WRB to post, NULL on failure.
+ *---------------------------------------------------------------
+ */
+struct MCC_WRB_AMAP *
+be_function_peek_mcc_wrb(struct be_function_object *pfob);
+
+/*
+ *---------------------------------------------------------------
+ * Function: be_function_post_mcc_wrb
+ *   Posts a WRB to either mailbox or mcc ring. The wrb pointer
+ *   may be the pointer returned by the be_function_peek_mcc_wrb function.
+ *   It not, the wrb is copied into the ring/mailbox. The callback may
+ *   be NULL, in which case the function will not return until the
+ *   WRB completes. It will poll the mailbox status or MCC CQ in that case.
+ *   Other outstanding MCC WRBs may be completed in this context
+ *   if the callback is NULL.  This function (nor any other synchronous
+ *   FWCMD function) may be called from an MCC_WRB_CQE_CALLBACK context.
+ *   Only asynchronous FWCMD may be posted during the completion of
+ *   another FWCMD. Otherwise, the software will deadlock.
+ *
+ * return pend_status - BE_SUCCESS (0) on success.
+ * 			BE_PENDING (postive value) if the FWCMD
+ *                      completion is pending. Negative error code on failure.
+ *---------------------------------------------------------------
+ */
+BESTATUS
+be_function_post_mcc_wrb(struct be_function_object *funcobj,
+		 struct MCC_WRB_AMAP *wrb, MCC_WRB_CQE_CALLBACK callback,
+		 void *callback_context, void *optional_fwcmd_va);
+
+/*
+ *---------------------------------------------------------------
+ * Function: be_rxf_mac_address_read_write
+ *   Reads or writes the MAC address.
+ * pfob    -
+ * port1              - Specifies port 0 or 1
+ * mac1               - Specifies addres 0 or 1 (BE has 2 per port)
+ * mgmt               - Specifies the management port. If TRUE, the
+ * 			port1 and mac1
+ *                      parameters are ignored.
+ * write              - If TRUE, the MAC address is set.
+ * permanent          - If TRUE, the MAC read is the permanent address
+ * mac_address        - Address to set, or address returned.
+ * callback           - optional
+ * callback_context   - optional
+ * return pend_status - BE_SUCCESS (0) on success.
+ * 			BE_PENDING (postive value) if the FWCMD
+ *                      completion is pending. Negative error code on failure.
+ *---------------------------------------------------------------
+ */
+BESTATUS
+be_rxf_mac_address_read_write(struct be_function_object *pfob,
+	      bool port1, bool mac1, bool mgmt,
+	      bool write, bool permanent, u8 *mac_address,
+	      MCC_WRB_CQE_CALLBACK callback,
+	      void *callback_context);
+
+/*
+ *---------------------------------------------------------------
+ * Function: be_rxf_multicast_config
+ *   Writes all multicast addresses for this protection domain.
+ *   This function is called as part of be_function_cleanup to
+ *   remove all multicast filters.
+ * pfob    -
+ * promiscuous        - TRUE, enables promiscuous mode where all multicast
+ * 			packets are passed up. Allows supporting >32
+ * 			multicast addresses.
+ * num                - number of mac addresses in the table. Max=32.
+ * mac_table          -
+ * callback           - optional
+ * callback_context   - optional
+ * queue_context      - Optional. Pointer to a previously allocated
+ * 			struct. If the MCC WRB ring is full, this
+ * 			structure is used to queue the operation. It
+ *                      will be posted to the MCC ring when space
+ *                      becomes available. All queued commands will be
+ *                      posted to the ring in the order they are
+ *                      received. It is always valid to pass a pointer
+ *                      to a generic be_generic_queue_context. However, the
+ *                      specific context structs are generally smaller
+ *                      than the generic struct.
+ * return pend_status - BE_SUCCESS (0) on success.
+ * 			BE_PENDING (postive value) if the FWCMD
+ *                      completion is pending. Negative error code on failure.
+ *---------------------------------------------------------------
+ */
+BESTATUS
+be_rxf_multicast_config(struct be_function_object *pfob,
+			bool promiscuous, u32 num, u8 *mac_table,
+			MCC_WRB_CQE_CALLBACK callback,
+			void *callback_context,
+			struct be_multicast_queue_context *queue_context);
+
+/*
+ *---------------------------------------------------------------
+ * Function: be_rxf_vlan_config
+ *   Writes all vlan tags for this protection domain. This function
+ *   is called as part of be_function_cleanup to remove all vlan filters.
+ * pfob    -
+ * promiscuous        - TRUE, enables promiscuous mode where all
+ * 			vlan packets are passed up the stack. Allows
+ * 			supporting >32 vlan tags.
+ * num                - Number of vlan tags in the array.
+ * vlan_tag_array     -
+ * callback           - optional
+ * callback_context   - optional
+ * queue_context      - Optional. Pointer to a previously allocated struct.
+ * 			If the MCC WRB ring is full, this structure is used
+ * 			to queue the operation. It will be posted to the
+ * 			MCC ring when space becomes available. All
+ *                      queued commands will be posted to the ring in
+ *                      the order they are received. It is always valid
+ *                      to pass a pointer to a generic
+ *                      be_generic_queue_context. However, the specific
+ *                      context structs are generally smaller than
+ *                      the generic struct.
+ * return pend_status - BE_SUCCESS (0) on success.
+ * 			BE_PENDING (postive value) if the FWCMD
+ *                      completion is pending. Negative error code on failure.
+ *---------------------------------------------------------------
+ */
+BESTATUS
+be_rxf_vlan_config(struct be_function_object *pfob,
+	   bool promiscuous, u32 num, u16 *vlan_tag_array,
+	   MCC_WRB_CQE_CALLBACK callback, void *callback_context,
+	   struct be_vlan_queue_context *queue_context);
+
+/*
+ *---------------------------------------------------------------
+ * Function: be_rxf_wake_on_lan_config
+ *   Configures wake-on-lan for the controller. Wake-on-lan is only
+ *   supported for the host system virtual machine - wake-on-lan is not
+ *   supported per protection domain. To enable magic packet
+ *   reception, use null pointer arguments for pattern & pattern mask,
+ *   set magic_packet_enable to true, and set the port enables
+ *   to true. To disable magic packet reception, use null pointer
+ *   arguments for pattern & pattern mask, set magic_packet_enable to true,
+ *   and set the port enables to false. To remove a pattern, set both
+ *   enable_port0 and enable_port1 to FALSE, and provide the index
+ *   you previously used to enable the pattern. This function is
+ *   not called as part of be_function_cleanup to remove all wake-on-lan
+ *   patterns, since be_function_cleanup could be called when the
+ *   system wants to wake up on a magic or interesting packet.
+ * pfob     -
+ * enable_port0        - If TRUE, enable this pattern for port0.
+ * enable_port1        - If TRUE, enable this pattern for port1.
+ * magic_packet_enable - If TRUE, enable magic packet for the enabled ports.
+ * index               - index 0-3 for the packet to program
+ * pattern             - 128 byte magic pattern
+ * pattern_mask        - 128 bit mask indicating which bytes in the
+ * 			pattern should be matched.
+ * callback            - optional
+ * callback_context    - optional
+ * queue_context       - Optional. Pointer to a previously allocated struct.
+ * 			 If the MCC WRB ring is full, this structure is
+ * 			 used to queue the operation. It will be posted
+ * 			 to the MCC ring when space becomes available.
+ * 			 All queued commands will be posted to the
+ * 			 ring in the order they are received. It is
+ * 			 always valid to pass a pointer to a generic
+ * 			 be_generic_queue_context. However, the specific
+ * 			 context structs are generally smaller than
+ * 			 the generic struct.
+ * return pend_status  - BE_SUCCESS (0) on success. BE_PENDING
+ * 			 (postive value) if the FWCMD completion
+ * 			 is pending. Negative error code on failure.
+ *---------------------------------------------------------------
+ */
+BESTATUS
+be_rxf_wake_on_lan_config(struct be_function_object *pfob,
+			bool enable_port0, bool enable_port1,
+			bool magic_packet_enable, u32 index,
+			void *pattern, void *pattern_mask,
+			MCC_WRB_CQE_CALLBACK callback,
+			void *callback_context,
+			struct be_wake_on_lan_queue_context *queue_context);
+/*
+ *---------------------------------------------------------------
+ * Function: be_rxf_link_status
+ *   Queries the link status.
+ * pfob    -
+ * link_status        - returned status
+ * callback           - optional
+ * callback_context   - optional
+ * queue_context      - Optional. Pointer to a previously allocated struct.
+ * 			If the MCC WRB ring is full, this structure is
+ * 			used to queue the operation. It will be posted
+ * 			to the MCC ring when space becomes available. All
+ *                      queued commands will be posted to the ring in
+ *                      the order they are received. It is always valid
+ *                      to pass a pointer to a generic
+ *                      be_generic_queue_context. However, the specific
+ *                      context structs are generally smaller than
+ *                      the generic struct.
+ * return pend_status - BE_SUCCESS (0) on success.
+ * 			BE_PENDING (postive value) if the FWCMD
+ *                      completion is pending. Negative error code on failure.
+ *---------------------------------------------------------------
+ */
+BESTATUS
+be_rxf_link_status(struct be_function_object *pfob,
+		   struct BE_LINK_STATUS *link_status,
+		   MCC_WRB_CQE_CALLBACK callback,
+		   void *callback_context,
+		   struct be_link_status_queue_context *queue_context);
+
+/*
+ *---------------------------------------------------------------
+ * Function: be_rxf_query_eth_statistics
+ *   Queries the ethernet statistics. The resulting statistics are
+ *   stored in the fwcmd response buffer.
+ * pfob    -
+ * va_for_fwcmd       - Virtual address of the FWCMD buffer. This buffer must be
+ *                      physically contiguous.
+ * pa_for_fwcmd       - Physical address of the FWCMD buffer. This buffer must
+ * 			be physically contiguous.
+ * callback           - optional
+ * callback_context   - optional
+ * queue_context      - Optional. Pointer to a previously allocated
+ * 			struct. If the MCC WRB ring is full, this
+ * 			structure is used to queue the operation.
+ * 			It will be posted to the MCC ring when space
+ * 			becomes available. All queued commands will be posted
+ * 			to the ring in the order they are received.
+ * 			It is always valid to pass a pointer to a
+ * 			generic be_generic_queue_context. However, the
+ * 			specific context structs are generally smaller than
+ * 			the generic struct.
+ * return pend_status - BE_SUCCESS (0) on success. BE_PENDING (postive value)
+ * 			if the FWCMD
+ *                      completion is pending. Negative error code on failure.
+ *---------------------------------------------------------------
+ */
+BESTATUS
+be_rxf_query_eth_statistics(struct be_function_object *pfob,
+		struct FWCMD_ETH_GET_STATISTICS *va_for_fwcmd,
+		u64 pa_for_fwcmd, MCC_WRB_CQE_CALLBACK callback,
+		void *callback_context,
+		struct be_nonembedded_queue_context *queue_context);
+
+/*
+ *---------------------------------------------------------------
+ * Function: be_rxf_promiscuous
+ *   Enables or disables promiscuous mode for each MAC port.
+ * pfob    -
+ * enable_port0       - Enable/Disable promiscuous mode on port 0.
+ * enable_port1       - Enable/Disable promiscuous mode on port 1.
+ * callback           - optional
+ * callback_context   - optional
+ * queue_context      - Optional. Pointer to a previously allocated
+ * 			struct. If the MCC WRB ring is full, this
+ * 			structure is used to queue the operation.
+ * 			It will be posted to the MCC ring when space
+ * 			becomes available. All queued commands will be
+ * 			posted to the ring in the order they are
+ * 			received. It is always valid to pass a
+ * 			pointer to a generic be_generic_queue_context.
+ * 			However, the specific context structs are
+ * 			generally smaller than the generic struct.
+ * return pend_status - BE_SUCCESS (0) on success.
+ * 			BE_PENDING (postive value) if the FWCMD
+ *                      completion is pending. Negative error code on failure.
+ *---------------------------------------------------------------
+ */
+BESTATUS
+be_rxf_promiscuous(struct be_function_object *pfob,
+		   bool enable_port0, bool enable_port1,
+		   MCC_WRB_CQE_CALLBACK callback, void *callback_context,
+		   struct be_promiscuous_queue_context *queue_context);
+
+
+/*
+ *---------------------------------------------------------------
+ * Function: be_rxf_filter_config
+ *   Configures BladeEngine ethernet receive filter settings.
+ * pfob    -
+ * settings           - Pointer to the requested filter settings.
+ * 			The response from BladeEngine will be placed back
+ * 			in this structure.
+ * callback           - optional
+ * callback_context   - optional
+ * queue_context      - Optional. Pointer to a previously allocated struct.
+ * 			If the MCC WRB ring is full, this structure is
+ * 			used to queue the operation. It will be posted to
+ * 			the MCC ring when space becomes available. All
+ * 			queued commands will be posted to the ring in
+ * 			the order they are received. It is always valid
+ * 			to pass a pointer to a generic
+ * 			be_generic_queue_context. However, the
+ * 			specific context structs are generally
+ * 			smaller than the generic struct.
+ * return pend_status - BE_SUCCESS (0) on success. BE_PENDING (postive value)
+ * 			if the FWCMD
+ *                      completion is pending. Negative error code on failure.
+ *---------------------------------------------------------------
+ */
+BESTATUS
+be_rxf_filter_config(struct be_function_object *pfob,
+		     struct NTWK_RX_FILTER_SETTINGS *settings,
+		     MCC_WRB_CQE_CALLBACK callback,
+		     void *callback_context,
+		     struct be_rxf_filter_queue_context *queue_context);
+
+/*
+ *---------------------------------------------------------------
+ * Function: be_function_enable_interrupts
+ *   Enables interrupts for the given PCI function.
+ *---------------------------------------------------------------
+ */
+void be_function_enable_interrupts(struct be_function_object *pfob);
+
+/*
+ *---------------------------------------------------------------
+ * Function: be_function_disable_interrupts
+ *   Disables interrupts for the given PCI function.
+ *---------------------------------------------------------------
+ */
+void
+be_function_disable_interrupts(struct be_function_object *pfob);
+
+#endif /* __beclib_ll_bmap_h__ */
diff --git a/drivers/message/beclib/beclib_ll_enum_nic.h b/drivers/message/beclib/beclib_ll_enum_nic.h
new file mode 100644
index 0000000..532e062
--- /dev/null
+++ b/drivers/message/beclib/beclib_ll_enum_nic.h
@@ -0,0 +1,48 @@
+/*
+ * Copyright (C) 2005 - 2008 ServerEngines
+ * All rights reserved.
+ *
+ * This program is free software; you can redistribute it and/or
+ * modify it under the terms of the GNU General Public License version 2
+ * as published by the Free Software Foundation.  The full GNU General
+ * Public License is included in this distribution in the file called COPYING.
+ *
+ * Contact Information:
+ * linux-drivers@serverengines.com
+ *
+ * ServerEngines
+ * 209 N. Fair Oaks Ave
+ * Sunnyvale, CA 94085
+ */
+/*
+ * Autogenerated by srcgen version: 0127
+ */
+#ifndef __beclib_ll_enum_h__
+#define __beclib_ll_enum_h__
+
+/* --- BE_FUNCTION_ENUM --- */
+#define BE_FUNCTION_TYPE_ISCSI          (0)
+#define BE_FUNCTION_TYPE_NETWORK        (1)
+#define BE_FUNCTION_TYPE_ARM            (2)
+
+enum BE_FUNCTION_ENUM {
+	ENUM_BE_FUNCTION_TYPE_ISCSI = 0x0UL,
+	ENUM_BE_FUNCTION_TYPE_NETWORK = 0x1UL,
+	ENUM_BE_FUNCTION_TYPE_ARM = 0x2UL
+} ;
+
+/* --- BE_ETH_TX_RING_TYPE_ENUM --- */
+#define BE_ETH_TX_RING_TYPE_FORWARDING  (1) 	/* Ether ring for forwarding */
+#define BE_ETH_TX_RING_TYPE_STANDARD    (2)	/* Ether ring for sending */
+						/* network packets. */
+#define BE_ETH_TX_RING_TYPE_BOUND       (3)	/* Ethernet ring for sending */
+						/* network packets, bound */
+						/* to a physical port. */
+
+enum BE_ETH_TX_RING_TYPE_ENUM {
+	ENUM_BE_ETH_TX_RING_TYPE_FORWARDING = 0x1UL,
+	ENUM_BE_ETH_TX_RING_TYPE_STANDARD = 0x2UL,
+	ENUM_BE_ETH_TX_RING_TYPE_BOUND = 0x3UL
+} ;
+
+#endif /* __beclib_ll_enum_h__ */
-- 
1.5.5

___________________________________________________________________________________
This message, together with any attachment(s), contains confidential and proprietary information of
ServerEngines Corporation and is intended only for the designated recipient(s) named above. Any unauthorized
review, printing, retention, copying, disclosure or distribution is strictly prohibited.  If you are not the
intended recipient of this message, please immediately advise the sender by reply email message and
delete all copies of this message and any attachment(s). Thank you.

