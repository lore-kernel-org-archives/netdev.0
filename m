From: "Subbu Seetharaman" <subbus@serverengines.com>
Subject: [PATHCH 9/16]  ServerEngines 10Gb NIC driver
Date: Sat, 16 Feb 2008 18:43:57 -0800
Message-ID: <20080217024357.da474378@mailhost.serverengines.com>
Mime-Version: 1.0
Content-Type: text/plain;
	charset="us-ascii"
Content-Transfer-Encoding: 8BIT
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail192.messagelabs.com ([216.82.242.147]:32982 "EHLO
	mail192.messagelabs.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1753300AbYBQCoC convert rfc822-to-8bit (ORCPT
	<rfc822;netdev@vger.kernel.org>); Sat, 16 Feb 2008 21:44:02 -0500
Received: from 59.93.89.51 ([59.93.89.51])
	by mailhost.serverengines.com
	for netdev@vger.kernel.org;
	Sat, 16 Feb 2008 18:43:58 -0800
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

System abstraction function for Linux.  beclib uses these helper routines / macros to do OS dependent functions.

--------------------
diff -uprN orig/linux-2.6.24.2/drivers/message/beclib/sa/setypes.h benet/linux-2.6.24.2/drivers/message/beclib/sa/setypes.h
--- orig/linux-2.6.24.2/drivers/message/beclib/sa/setypes.h	1970-01-01 05:30:00.000000000 +0530
+++ benet/linux-2.6.24.2/drivers/message/beclib/sa/setypes.h	2008-02-14 15:23:07.812205128 +0530
@@ -0,0 +1,70 @@
+
+/*
+ * These are the data types used in management apps that we are 
+maintaining for
+ * legacy/personal preference reasons.
+ */
+
+#ifndef __setypes_h__
+#define __setypes_h__
+/*
+ *----- data types used in SA ----
+ * Signed integers.
+ */
+typedef signed char i8;
+typedef signed short i16;
+typedef signed int i32;
+typedef signed long long i64;
+
+/* Narrow and wide characters. */
+typedef char c8;
+typedef u16 c16;
+
+/* Native size_t for interfacing to libraries. */ typedef size_t 
+SA_SIZE_T, *PSA_SIZE_T;
+
+typedef int boolean;
+
+/* Common pointer to a void notation. */ typedef void *PVOID;
+
+/*
+ * Explicitly sized booleans -- useful for packing a struct while still
+ * indicating that the value is treated as TRUE or FALSE.
+ */
+typedef u8 bool8;
+typedef u16 bool16;
+typedef u32 bool32;
+
+/* Define boolean types if necessary. */ #ifndef TRUE #define TRUE (1) 
+#endif
+
+#ifndef FALSE
+#define FALSE (0)
+#endif
+
+#if !defined(NULL)
+#define NULL            ((void *) 0)
+#endif
+
+/* Physical address definition */
+typedef u64 SA_PHYSICAL_ADDRESS, *PSA_PHYSICAL_ADDRESS;
+
+#define SA_EXTERN_C extern "C"
+#define INLINE      inline
+#define STATIC      static
+#define SA_STDCALL
+#define STDCALL
+#define SA_CDECL
+#define SA_FASTCALL
+
+#ifndef FASTCALL
+#define FASTCALL
+#endif
+
+#define IN
+#define OUT
+#define INOUT
+
+#endif
diff -uprN orig/linux-2.6.24.2/drivers/message/beclib/sa/sa.c benet/linux-2.6.24.2/drivers/message/beclib/sa/sa.c
--- orig/linux-2.6.24.2/drivers/message/beclib/sa/sa.c	1970-01-01 05:30:00.000000000 +0530
+++ benet/linux-2.6.24.2/drivers/message/beclib/sa/sa.c	2008-02-14 15:23:07.812205128 +0530
@@ -0,0 +1,278 @@
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
+ */
+/*
+ * system abstraction functions / macros for Linux  */ #include "sa.h"
+#include <asm/io.h>
+#include <linux/delay.h>
+
+/* Table lookup for number of bits set in each byte. */
+u8 sa_bits_in_byte_table[256] = {
+	0, 1, 1, 2, 1, 2, 2, 3, 1, 2, 2, 3, 2, 3, 3, 4,
+	1, 2, 2, 3, 2, 3, 3, 4, 2, 3, 3, 4, 3, 4, 4, 5,
+	1, 2, 2, 3, 2, 3, 3, 4, 2, 3, 3, 4, 3, 4, 4, 5,
+	2, 3, 3, 4, 3, 4, 4, 5, 3, 4, 4, 5, 4, 5, 5, 6,
+	1, 2, 2, 3, 2, 3, 3, 4, 2, 3, 3, 4, 3, 4, 4, 5,
+	2, 3, 3, 4, 3, 4, 4, 5, 3, 4, 4, 5, 4, 5, 5, 6,
+	2, 3, 3, 4, 3, 4, 4, 5, 3, 4, 4, 5, 4, 5, 5, 6,
+	3, 4, 4, 5, 4, 5, 5, 6, 4, 5, 5, 6, 5, 6, 6, 7,
+	1, 2, 2, 3, 2, 3, 3, 4, 2, 3, 3, 4, 3, 4, 4, 5,
+	2, 3, 3, 4, 3, 4, 4, 5, 3, 4, 4, 5, 4, 5, 5, 6,
+	2, 3, 3, 4, 3, 4, 4, 5, 3, 4, 4, 5, 4, 5, 5, 6,
+	3, 4, 4, 5, 4, 5, 5, 6, 4, 5, 5, 6, 5, 6, 6, 7,
+	2, 3, 3, 4, 3, 4, 4, 5, 3, 4, 4, 5, 4, 5, 5, 6,
+	3, 4, 4, 5, 4, 5, 5, 6, 4, 5, 5, 6, 5, 6, 6, 7,
+	3, 4, 4, 5, 4, 5, 5, 6, 4, 5, 5, 6, 5, 6, 6, 7,
+	4, 5, 5, 6, 5, 6, 6, 7, 5, 6, 6, 7, 6, 7, 7, 8 };
+
+unsigned int trace_level;
+
+
+SA_STATUS sa_dev_create(SA_DEV_BAR_LOCATIONS *bars, u32 num_bars,
+		SA_DEV_OS_HANDLE os_handle, SA_DEV *dev) {
+	SA_NOT_USED(os_handle); /* Not used in Linux */
+	ASSERT(dev);
+	ASSERT(bars);
+
+	/* Zero the struct */
+	SA_ZERO_MEM(dev);
+
+	/* Copy the bar info */
+	dev->magic = SA_DEV_MAGIC;
+	dev->num_bars = num_bars;
+	sa_memcpy(dev->bars, bars,
+		  sizeof(SA_DEV_BAR_LOCATIONS) * num_bars);
+
+	/* Figure out the csr/pd/pci bar numbers. */
+	_sa_cache_bar_nums(dev);
+
+	return SA_SUCCESS;
+}
+
+void sa_dev_destroy(SA_DEV *dev)
+{
+	SA_DEV_ASSERT(dev);
+	SA_ZERO_MEM(dev);
+}
+
+u8 sa_dev_read_u8(SA_DEV *dev, u32 bar, u32 offset) {
+	u8 *real_offset = 0;
+	u8 value = 0;
+
+	SA_DEV_ASSERT(dev);
+	ASSERT(bar < dev->num_bars);
+	ASSERT(offset < dev->bars[bar].length);
+
+	real_offset = (u8 *) dev->bars[bar].base_va + offset;
+	value = readb((void *)real_offset);
+	return value;
+}
+
+u16 sa_dev_read_u16(SA_DEV *dev, u32 bar, u32 offset) {
+	u8 *real_offset = 0;
+	u16 value = 0;
+
+	SA_DEV_ASSERT(dev);
+	ASSERT(bar < dev->num_bars);
+	ASSERT(offset < dev->bars[bar].length);
+
+	real_offset = (u8 *) dev->bars[bar].base_va + offset;
+	value = readw((void *)real_offset);
+	return value;
+}
+
+u32 sa_dev_read_u32(SA_DEV *dev, u32 bar, u32 offset) {
+	u8 *real_offset = 0;
+	u32 value = 0;
+
+	SA_DEV_ASSERT(dev);
+	ASSERT(bar < dev->num_bars);
+	ASSERT(offset < dev->bars[bar].length);
+
+	real_offset = (u8 *) dev->bars[bar].base_va + offset;
+	value = readl((void *)real_offset);
+	return value;
+}
+
+void sa_dev_write_u8(SA_DEV *dev, u32 bar, u32 offset, u8 value) {
+	u8 *real_offset = 0;
+
+	SA_DEV_ASSERT(dev);
+	ASSERT(bar < dev->num_bars);
+	ASSERT(offset < dev->bars[bar].length);
+
+	real_offset = (u8 *) dev->bars[bar].base_va + offset;
+	writeb(value, (void *)real_offset);
+}
+
+void sa_dev_write_u16(SA_DEV *dev, u32 bar, u32 offset, u16 value) {
+	u8 *real_offset = 0;
+
+	SA_DEV_ASSERT(dev);
+	ASSERT(bar < dev->num_bars);
+	ASSERT(offset < dev->bars[bar].length);
+
+	real_offset = (u8 *) dev->bars[bar].base_va + offset;
+	writew(value, (void *)real_offset);
+}
+
+void sa_dev_write_u32(SA_DEV *dev, u32 bar, u32 offset, u32 value) {
+	u8 *real_offset = 0;
+
+	SA_DEV_ASSERT(dev);
+	ASSERT(bar < dev->num_bars);
+	ASSERT(offset < dev->bars[bar].length);
+
+	real_offset = (u8 *) dev->bars[bar].base_va + offset;
+	writel(value, (void *)real_offset);
+}
+
+SA_STATUS
+sa_dev_read_buffer_u8(SA_DEV *dev,
+		      u32 bar, u32 offset, u8 *buffer, u32 count) {
+	u8 *real_offset = 0;
+
+	SA_DEV_ASSERT(dev);
+	ASSERT(bar < dev->num_bars);
+	ASSERT(offset + count < dev->bars[bar].length);
+	ASSERT(count > 0);
+	ASSERT(buffer);
+
+	real_offset = (u8 *) dev->bars[bar].base_va + offset;
+	memcpy_fromio(buffer, (void *)real_offset, count);
+
+	return SA_SUCCESS;
+}
+
+SA_STATUS
+sa_dev_read_buffer_u16(SA_DEV *dev,
+		       u32 bar, u32 offset, u16 *buffer, u32 count) {
+	u8 *real_offset = 0;
+
+	SA_DEV_ASSERT(dev);
+	ASSERT(bar < dev->num_bars);
+	ASSERT(offset + count * sizeof(u16) < dev->bars[bar].length);
+	ASSERT(count > 0);
+	ASSERT(buffer);
+
+	real_offset = (u8 *) dev->bars[bar].base_va + offset;
+	memcpy_fromio(buffer, (void *)real_offset, count * sizeof(u16));
+
+	return SA_SUCCESS;
+}
+
+SA_STATUS
+dev_read_buffer_u32(SA_DEV *dev,
+		    u32 bar, u32 offset, u32 *buffer, u32 count) {
+	u8 *real_offset = 0;
+
+	SA_DEV_ASSERT(dev);
+	ASSERT(bar < dev->num_bars);
+	ASSERT(offset + count * sizeof(u32) < dev->bars[bar].length);
+	ASSERT(count > 0);
+	ASSERT(buffer);
+
+	real_offset = (u8 *) dev->bars[bar].base_va + offset;
+	memcpy_fromio(buffer, (void *)real_offset, count * sizeof(u32));
+
+	return SA_SUCCESS;
+}
+
+SA_STATUS
+sa_dev_write_buffer_u8(SA_DEV *dev,
+		       u32 bar, u32 offset, u8 *buffer, u32 count) {
+	u8 *real_offset = 0;
+
+	SA_DEV_ASSERT(dev);
+	ASSERT(bar < dev->num_bars);
+	ASSERT(offset + count < dev->bars[bar].length);
+	ASSERT(count > 0);
+	ASSERT(buffer);
+
+	real_offset = (u8 *) dev->bars[bar].base_va + offset;
+	memcpy_toio((void *)real_offset, buffer, count);
+
+	return SA_SUCCESS;
+}
+
+SA_STATUS
+sa_dev_write_buffer_u16(SA_DEV *dev,
+			u32 bar, u32 offset, u16 *buffer, u32 count) {
+	u8 *real_offset = 0;
+
+	SA_DEV_ASSERT(dev);
+	ASSERT(bar < dev->num_bars);
+	ASSERT(offset + count * sizeof(u16) < dev->bars[bar].length);
+	ASSERT(count > 0);
+	ASSERT(buffer);
+
+	real_offset = (u8 *) dev->bars[bar].base_va + offset;
+	memcpy_toio((void *)real_offset, buffer, count * sizeof(u16));
+
+	return SA_SUCCESS;
+}
+
+SA_STATUS
+sa_dev_write_buffer_u32(SA_DEV *dev,
+			u32 bar, u32 offset, u32 *buffer, u32 count) {
+	u8 *real_offset = 0;
+
+	SA_DEV_ASSERT(dev);
+	ASSERT(bar < dev->num_bars);
+	ASSERT(offset + count * sizeof(u32) < dev->bars[bar].length);
+	ASSERT(count > 0);
+	ASSERT(buffer);
+
+	real_offset = (u8 *) dev->bars[bar].base_va + offset;
+	memcpy_toio((void *)real_offset, buffer, count * sizeof(u32));
+
+	return SA_SUCCESS;
+}
+
+void sa_dev_stall(SA_DEV *dev, u32 us_to_stall) {
+	udelay(us_to_stall);
+}
diff -uprN orig/linux-2.6.24.2/drivers/message/beclib/sa/sa.h benet/linux-2.6.24.2/drivers/message/beclib/sa/sa.h
--- orig/linux-2.6.24.2/drivers/message/beclib/sa/sa.h	1970-01-01 05:30:00.000000000 +0530
+++ benet/linux-2.6.24.2/drivers/message/beclib/sa/sa.h	2008-02-14 15:23:07.813204976 +0530
@@ -0,0 +1,1004 @@
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
+ */
+/*
+ * system abstraction functions / macros for Linux  */ #ifndef __sa_h__ 
+#define __sa_h__
+
+#include <asm/io.h>
+#include <linux/list.h>
+#include <linux/kernel.h>
+#include <linux/spinlock.h>
+#include <linux/errno.h>
+#include <linux/string.h>
+#include <asm/semaphore.h>
+
+/*-----  Platform specific defines for Linux -------*/ #define SA_OS 
+"linux"
+#define SA_LINUX
+
+#define SA_KERNEL
+#define SA_LINUX_KERNEL
+#define SA_LINUXK
+
+#define  SA_CPP_HEADER
+#define  SA_CPP_TRAILER
+
+/*
+ *---------   Assert related --------
+ * a way to force  compilation error
+ */
+#define SA_C_ASSERT(_expression_)       { \
+	typedef u8 __COMPILE_TIME_ASSERT_NAME__[(_expression_) ? 1 : -1];  \ }
+
+#ifdef SA_DEBUG
+
+#define ASSERT(c)       if (!(c)) \
+				BUG();
+
+#define SA_DBG_CSTR(_str_)        (_str_)
+#define SA_DBG_ONLY(_anything_)   _anything_
+
+#else
+
+#define ASSERT(c)
+#define BREAKPOINT()
+#define SA_BREAKPOINT_MSG(_str_)
+#define SA_DBG_CSTR(_str_)        ""
+#define SA_DBG_ONLY(_anything_)
+
+#endif
+
+#define SA_ASSERT	ASSERT
+
+#define SA_COMPILETIME_NAMED_TYPEDEF_ASSERT(_name_, _expression_)    \
+	typedef u8 _name_##__COMPILE_TIME_ASSERT__[(_expression_)?1: -1]  \
+
+#define SA_GLOBAL_C_ASSERT          SA_COMPILETIME_NAMED_TYPEDEF_ASSERT
+
+/*---------   Trace log related --------*/
+
+/* debug levels */
+typedef enum _SA_DEBUG_LEVELS {
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
+} SA_DEBUG_LEVELS, *PSA_DEBUG_LEVELS;
+
+/* Bit mask describing events of interest to be traced */ extern 
+unsigned int trace_level;
+
+#define SA_TRACE(lm, fmt, args...)  {					\
+		if (trace_level & lm) {				\
+			printk(KERN_NOTICE "BE: %s:%d \n" fmt,	\
+			__FILE__ , __LINE__ , ## args);	\
+		}						\
+	}
+
+#define TRACE			SA_TRACE
+#define SA_TRACE_ENTRY()	SA_TRACE(DL_ENTRY, "Entry - \n")
+#define SA_TRACE_EXIT()		SA_TRACE(DL_EXIT , "Exit  - \n")
+
+static inline unsigned int sa_trace_set_level(unsigned int l) {
+	unsigned int old_level = trace_level;
+	trace_level = l;
+	return (old_level);
+}
+
+#define sa_trace_get_level() 	trace_level
+#define sa_trace_set_debug_level_string(lm, s)	/* nothing */
+
+#include "setypes.h"
+
+/*----- power of 2  functions -----*/
+static inline u32 sa_required_bits(u32 x) {
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
+*/ static inline u32 sa_log2(u32 x) {
+	return sa_required_bits(x) - 1;
+}
+
+/*
+ * "greater than power of 2"
+ * Returns the next higher power of 2 -- even if input is a power of 2.
+ * input->output
+ * 0->1, 1->2, 2->4, 3->4, 4->8, 5->8, 6->8, 7->8, 8->16, 9->16  */ 
+static inline u32 sa_gt_power2(u32 x) {
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
+ *----- status codes returned by SA functions -----
+ * Status code datatype
+ */
+typedef i32 SA_STATUS, *PSA_STATUS;
+
+/* Error codes */
+#define SA_STATUS_SUCCESS             (0x00000000L)
+#define SA_SUCCESS                    SA_STATUS_SUCCESS	/* abbreviation */
+
+#define SA_STATUS_PENDING             (0x20070001L)
+#define SA_STATUS_NOT_OK              (0xE0070002L)
+#define SA_NOT_OK                     SA_STATUS_NOT_OK	/* abbreviation */
+#define SA_STATUS_NO_SYSTEM_RESOURCES (0xE0070003L)
+#define SA_STATUS_NO_CHIP_RESOURCES   (0xE0070004L)
+#define SA_STATUS_BUSY                (0xE0070006L)
+
+#define SA_STATUS_INVALID_PARAMETER   (0xE0000007L)
+#define SA_STATUS_INVALID_ADDRESS     (0xE000000CL)
+#define SA_STATUS_NOT_SUPPORTED       (0xE000000DL)
+
+#define SA_STATUS_ACCESS_DENIED       (0xE000000EL)
+
+#define SA_STATUS_TIMEOUT             (0xE000100FL)
+#define SA_STATUS_ALERTED             (0xE0001010L)
+
+/*-------- Basic defines -------*/
+#define SA_PAGE_SHIFT  12
+#define SA_PAGE_SIZE   4096	/* BUG */
+
+/* Standard MIN and MAX macros */
+#define MIN(_a_, _b_) (((_a_) < (_b_)) ? (_a_) : (_b_)) #define 
+MAX(_a_, _b_) (((_a_) > (_b_)) ? (_a_) : (_b_))
+
+/*
+ * Returns number of pages spanned by the size of data
+ * starting at the given address.
+ */
+#define SA_PAGES_SPANNED(_address, _size) \
+   ((u32)(((SA_PTR_TO_INT(_address) & (SA_PAGE_SIZE - 1)) + \
+		(_size) + (SA_PAGE_SIZE - 1)) >> SA_PAGE_SHIFT))
+
+/*
+ * number of elements in an array
+ *  e.g.  u32 array[128];
+ *  SA_NUMBER_OF(array) == 128
+ */
+#define SA_NUMBER_OF(_x_) 	(sizeof(_x_)/sizeof((_x_)[0]))
+
+/*
+ * Appropriate casts to avoid compiler warnings about casting between
+ * integers and pointers.
+ */
+#define SA_PTR_TO_INT(_p_) ((SA_SIZE_T)(_p_)) #define 
+SA_PTR_TO_U32(_p_) ((u32)SA_PTR_TO_INT(_p_)) #define SA_PTR_TO_U64(_p_) 
+((u64)SA_PTR_TO_INT(_p_))
+
+#define SA_PTR_TO_INT(_p_) ((SA_SIZE_T)(_p_)) #define 
+SA_U64_TO_PTR(_u_) ((PVOID)(SA_SIZE_T)(_u_)) #define SA_U32_TO_PTR(_u_) 
+((PVOID)(SA_SIZE_T)(_u_)) #define SA_PAGE_OFFSET(_addr_) 
+(SA_PTR_TO_INT(_addr_) & (SA_PAGE_SIZE-1))
+
+/* Returns the next higher page aligned address. */ static inline PVOID 
+SA_PAGE_ALIGN(PVOID _addr_) {
+	u32 addr = SA_PTR_TO_U32(_addr_);
+	if (addr & (SA_PAGE_SIZE - 1)) {
+		addr = (addr & ~(SA_PAGE_SIZE - 1)) + SA_PAGE_SIZE;
+		return SA_U32_TO_PTR(addr);
+	}
+	return _addr_;
+}
+
+/* Conversion from 64 bit values to hi and lo 32-bit values. */ static 
+inline u32 sa_hi(u64 quad) {
+	return (u32) (quad >> 32);
+}
+static inline u32 sa_lo(u64 quad)
+{
+	return (u32) (quad);
+}
+
+static inline u64 sa_make_u64(u32 hi, u32 lo) {
+	return (((u64) hi) << 32) | lo;
+}
+
+static inline u32 sa_pvoid_hi(PVOID p)
+{
+	return sa_hi(SA_PTR_TO_U64(p));
+}
+
+static inline u32 sa_pvoid_lo(PVOID p)
+{
+	return sa_lo(SA_PTR_TO_U64(p));
+}
+
+static inline PVOID sa_make_pvoid(u32 hi, u32 lo) {
+	return SA_U64_TO_PTR(sa_make_u64(hi, lo)); }
+
+/* Returns byte offset of field within given struct type. */
+#define SA_FIELD_OFFSET(_type_, _field_)              \
+	(SA_PTR_TO_U32((u8 *)&(((_type_ *)0)->_field_)))
+
+/* Returns byte size of given field with a structure. */ #define 
+SA_SIZEOF_FIELD(_type_, _field_)  \
+	sizeof(((_type_ *)0)->_field_)
+
+/* Returns the number of items in the field array. */
+#define SA_NUMBER_OF_FIELD(_type_, _field_)                                \
+	(SA_SIZEOF_FIELD(_type_, _field_)/sizeof((((_type_ *)0)->_field_[0])))
+
+/* Explicitly acknowledges that an input parameter is ignored. */ 
+#define SA_UNREFERENCED_PARAMETER(_p_)  ((_p_) = (_p_))
+#define SA_NOT_USED SA_UNREFERENCED_PARAMETER	/* abbreviation */
+
+/* Returns x/y plus 1 if there is a remainder. */ static inline u32 
+sa_ceiling(u32 x, u32 y) {
+	ASSERT(y > 0);
+	return (x + y - 1) / y;
+}
+
+/*
+ * Round Up Increment
+ * Returns number to add to x to round up to next multiple
+ * of y.  If x is multiple of y it returns 0.
+ */
+static inline u32 sa_round_up_inc(u32 x, u32 y) {
+	u32 z;
+	ASSERT(y > 0);
+	z = x % y;
+	return (z > 0 ? y - z : 0);
+}
+
+/*
+ * Returns x rounded to next multiple of y.  If x is a multiple
+ * of y, it returns x.
+ */
+static inline u32 sa_round_up(u32 x, u32 y) {
+	return x + sa_round_up_inc(x, y);
+}
+
+/*
+ * circular subtract.
+ * Returns a - b assuming a circular number system, where a and b are
+ * in range (0, maxValue-1). If a==b, zero is returned so the
+ * highest value possible with this subtraction is maxValue-1.
+ */
+static inline u32 sa_subc(u32 a, u32 b, u32 max) {
+	ASSERT(a <= max && b <= max);
+	ASSERT(max > 0);
+	return (a >= b ? (a - b) : (max - b + a)); }
+
+static inline u32 sa_addc(u32 a, u32 b, u32 max) {
+	ASSERT(a < max);
+	ASSERT(max > 0);
+	return ((max - a > b) ? (a + b) : (b + a - max)); }
+
+#define C_LT(a, b)   ((i32)((a)-(b)) < 0)
+#define C_LE(a, b)   ((i32)((a)-(b)) <= 0)
+#define C_GT(a, b)   ((i32)((a)-(b)) > 0)
+#define C_GE(a, b)   ((i32)((a)-(b)) >= 0)
+
+/*------ List manipulation functions and macros ----*/
+
+/*
+ * Calculate the address of the base of the structure given its type, 
+and an
+ * address of a field within the structure.
+ */
+#define SA_CONTAINING_RECORD(_address_, _type_, _field_) \
+	((_type_ *)((u8 *)(_address_) - (u8 *)(&((_type_ *)0)->_field_)))
+
+typedef struct list_head SA_LIST_ENTRY; typedef struct list_head 
+*PSA_LIST_ENTRY;
+
+#define SA_FOR_EACH_LIST_ENTRY(_LE, _LH, _TYPE, _LF)                   \
+	for ((_LE) =  SA_CONTAINING_RECORD((_LH).next, _TYPE, _LF.next); \
+		&(_LE)->_LF != &(_LH);                          \
+		(_LE) = SA_CONTAINING_RECORD((_LE)->_LF.next,   \
+		_TYPE, _LF.next))
+
+
+
+#define	sa_initialize_list_head		INIT_LIST_HEAD
+#define sa_is_list_empty 		list_empty
+#define IsListEmpty 			list_empty
+#define sa_remove_entry_list 		list_del
+#define sa_insert_tail_list(H, E)	list_add_tail(E, H)
+#define InsertTailList(H, E)		list_add_tail(E, H)
+#define	sa_insert_head_list(H, E)	list_add(E, H)
+#define RemoveHeadList		sa_remove_head_list
+
+static
+inline PSA_LIST_ENTRY sa_list_head(IN PSA_LIST_ENTRY head) {
+	if (head->next == head)
+		return ((PSA_LIST_ENTRY) 0);
+	else
+		return (head->next);
+}
+
+static
+inline PSA_LIST_ENTRY sa_remove_head_list(IN PSA_LIST_ENTRY head) {
+	PSA_LIST_ENTRY entry = head->next;
+
+	list_del((struct list_head *)entry);
+	return (entry);
+}
+
+static
+inline PSA_LIST_ENTRY sa_remove_tail_list(IN PSA_LIST_ENTRY head) {
+	PSA_LIST_ENTRY entry = head->prev;
+
+	list_del((struct list_head *)entry);
+	return (entry);
+}
+
+/*------- Memory Allocation / copy related ------*/
+
+typedef struct _SA_SGL {
+	u32 length;
+	PVOID va;
+	u64 pa;
+} SA_SGL, *PSA_SGL;
+
+/*
+ * simple compile time assert to verify the length of the input string.
+ * The gcc compiler optimizes the entire thing to a constant with -02.
+ */
+#define SA_TAG(__four_char_string__) ({			\
+	SA_GLOBAL_C_ASSERT(tag_must_be_4_char,		\
+		sizeof(__four_char_string__) == 5);	\
+	(((u32)(__four_char_string__[3])<<24) |		\
+	((u32)(__four_char_string__[2])<<16) |		\
+	((u32)(__four_char_string__[1])<<8)  |		\
+	((u32)(__four_char_string__[0])));		\
+})
+#define SA_ZERO_MEM(_ptr_) 	sa_zero_mem((_ptr_), sizeof(*(_ptr_)))
+
+static inline u32 sa_sgl_get_byte_count(IN PSA_SGL sgl) {
+	ASSERT(sgl);
+	return sgl->length;
+}
+
+static inline u32 sa_sgl_get_page_count(PSA_SGL sgl) {
+	ASSERT(sgl);
+	return SA_PAGES_SPANNED(sgl->va, sgl->length); }
+
+static inline PVOID sa_sgl_get_base_va(IN PSA_SGL sgl) {
+	ASSERT(sgl);
+	return sgl->va;
+}
+
+static inline u32 sa_sgl_get_offset(PSA_SGL sgl) {
+	ASSERT(sgl);
+	return SA_PAGE_OFFSET(sgl->va);
+}
+
+static inline SA_PHYSICAL_ADDRESS
+sa_sgl_get_page(IN PSA_SGL sgl, IN u32 page_index) {
+	SA_PHYSICAL_ADDRESS pa;
+
+	ASSERT(sgl);
+	ASSERT(page_index < sa_sgl_get_page_count(sgl));
+
+	if (page_index == 0) {
+		pa = virt_to_phys(sgl->va);
+		pa &= ~(SA_PAGE_SIZE - 1);	/* next lower pa */
+	} else {
+		u64 va = SA_PTR_TO_U64(sgl->va) & ~(SA_PAGE_SIZE - 1);
+		va += page_index * SA_PAGE_SIZE; /* offset to correct page  */
+		pa = virt_to_phys(SA_U64_TO_PTR(va));
+	}
+
+	ASSERT(pa);
+
+	/* must return page aligned address. */
+	ASSERT(SA_PAGE_ALIGN(SA_U64_TO_PTR(pa)) == SA_U64_TO_PTR(pa));
+	return cpu_to_le64(pa);
+}
+
+/*
+ * Optimized as the kernel version for the given platform.
+ *static inline void*
+ */
+static inline void *sa_zero_mem(void *ptr, u32 bytes) {
+	return memset(ptr, 0, (SA_SIZE_T) bytes); }
+
+static inline void *sa_memset(PVOID ptr, u32 value, u32 bytes) {
+	return memset(ptr, value, (SA_SIZE_T) bytes); }
+
+static inline void *sa_memcpy(PVOID dest, const void *src, u32 bytes) {
+	return memcpy(dest, src, (SA_SIZE_T) bytes); }
+
+/* Returns value of dest. */
+static inline void *sa_memmove(PVOID dest, const void *src, u32 bytes) 
+{
+	return (void *)memmove(dest, src, (SA_SIZE_T) bytes); }
+
+static inline i32 sa_memcmp(const void *a, const void *b, u32 bytes) {
+	return memcmp(a, b, (SA_SIZE_T) bytes); }
+
+/*----- Device I/O related ---------*/
+
+typedef enum {
+	SA_BAR_TYPE_INVALID = 0,
+
+	SA_BAR_TYPE_BOOT,
+	SA_BAR_TYPE_CSR,
+	SA_BAR_TYPE_PD,
+	SA_BAR_TYPE_PCI,
+
+	SA_BAR_TYPE_MAX
+} SA_DEV_BAR_TYPE;
+
+/*
+ * MemOrIOMapped has the following two values
+ * for reference purpose
+ */
+typedef enum {
+	SA_IO_MAPPED = 0x01,
+	SA_MEM_MAPPED = 0x02
+} SA_DEV_MAPPED_TYPE;
+
+typedef struct _SA_DEV_BAR_LOCATIONS {
+	void *base_va;		/* Virtual Address */
+	u64 base_pa;		/* Physical Address */
+	u32 length;		/* Length of register space */
+
+	SA_DEV_MAPPED_TYPE mem_or_io_mapped;	/* io or memory mapped */
+	SA_DEV_BAR_TYPE type;	/* What is this BAR used for. */
+
+} SA_DEV_BAR_LOCATIONS, *PSA_DEV_BAR_LOCATIONS;
+
+typedef u64 SA_DEV_BUS_ADDRESS, *PSA_DEV_BUS_ADDRESS;
+
+/*
+ * The device object uses a "magic" field to help catch memory
+ * corruption bugs.  It is initialized to the magic number defined here
+ * and ASSERTS verify this number in all other functions.
+ */
+#define SA_DEV_MAGIC (0x12345678)
+#define SA_DEV_ASSERT(_pdev_) ASSERT ((_pdev_)->magic == SA_DEV_MAGIC) 
+#define SA_DEV_MAX_BARS (8)
+/*
+ * Context structure passed to create the device object.  This is the
+ * device extension for the storage miniport.
+ */
+typedef PVOID SA_DEV_OS_HANDLE, *PSA_DEV_OS_HANDLE;
+/*
+ * Device Object
+ */
+typedef struct _SA_DEV {
+	u32 magic;
+	u32 num_bars;
+	SA_DEV_BAR_LOCATIONS bars[SA_DEV_MAX_BARS];
+	u32 csr_bar_num, pd_bar_num, pci_bar_num; } SA_DEV, *PSA_DEV;
+
+/*
+ * This assumes that each type defines the members "bars" and "num_bars"
+ * Returns the bar number, or ~0 if the given type doesn't exist.
+ */
+static inline u32 sa_get_bar_num(SA_DEV *dev, SA_DEV_BAR_TYPE type) {
+	u32 i;
+	for (i = 0; i < dev->num_bars; i++) {
+		if (type == dev->bars[i].type) {
+			return i;
+		}
+	}
+
+	return ~(u32) 0;
+}
+
+/* Internal function. */
+static inline void _sa_cache_bar_nums(SA_DEV *dev) {
+	dev->csr_bar_num = sa_get_bar_num(dev, SA_BAR_TYPE_CSR);
+	dev->pd_bar_num = sa_get_bar_num(dev, SA_BAR_TYPE_PD);
+	dev->pci_bar_num = sa_get_bar_num(dev, SA_BAR_TYPE_PCI); }
+
+/* Assume these values are cached in the sa_dev. */ static inline u32 
+sa_get_csr_bar(SA_DEV *dev) {
+	return dev->csr_bar_num;
+}
+
+static inline u32 sa_get_pd_bar(SA_DEV *dev) {
+	return dev->pd_bar_num;
+}
+
+static inline u32 sa_get_pci_bar(SA_DEV *dev) {
+	return dev->pci_bar_num;
+}
+
+SA_STATUS
+sa_dev_create(SA_DEV_BAR_LOCATIONS *, u32, SA_DEV_OS_HANDLE, SA_DEV *); 
+void sa_dev_destroy(SA_DEV *);
+
+u32 sa_dev_read_u32(SA_DEV *dev, u32 bar, u32 offset); void 
+sa_dev_write_u32(SA_DEV *dev, u32 bar, u32 offset, u32 value); void 
+sa_dev_stall(SA_DEV *dev, u32 us_to_stall);
+
+/*
+ *------- ring manipulation related ------
+ * This structure stores information about a ring shared between 
+hardware
+ * and software.  Each ring is allocated by the driver in the uncached
+ * extension and mapped into BladeEngine's unified table.  BEKLIB 
+manages
+ * creation and destruction of the rings in hardware.  It returns the
+ * corresponding HANDLE to the ring.
+ */
+typedef struct _SA_RING {
+	u32 pages;		/* queue size in pages */
+	u32 id;			/* queue id assigned by beklib */
+	u32 num;		/* number of elements in queue */
+	u32 cidx;		/* consumer index */
+	u32 pidx;		/* producer index -- not used by most rings */
+	u32 itemSize;		/* size in bytes of one object */
+
+	PVOID va;		/* The virtual address of the ring.
+				   This should be last to allow 32 & 64
+				   bit debugger extensions to work. */
+
+} SA_RING, *PSA_RING;
+
+#define SA_RING_FOREACH_ITEM(_pRing_, _pItem_, _type_,_code_) \
+{							\
+	u32 ring_num_pending = sa_ring_num_pending((_pRing_)); \
+	u32 ring_index; \
+	for (ring_index = 0; ring_index < ring_num_pending; ring_index++) { \
+		_pItem_ = (_type_)((u8 *)(_pRing_)->va + \
+		(_pRing_)->itemSize * \
+		(((_pRing_)->cidx + ring_index) % (_pRing_)->num));  \
+		ASSERT(sizeof (*(_pItem_)) == (_pRing_)->itemSize); \
+		_code_  \
+	}  \
+}  \
+
+static
+inline void sa_ring_create(PSA_RING ring,
+			       u32 num, u32 itemSize, PVOID va) {
+	ASSERT(ring);
+	sa_zero_mem(ring, sizeof(SA_RING));
+	ring->num = num;
+	ring->pages = sa_ceiling(num * itemSize, SA_PAGE_SIZE);
+	ring->itemSize = itemSize;
+	ring->va = va;
+}
+
+static inline void sa_ring_set_id(PSA_RING ring, u32 id) {
+	ASSERT(ring);
+	ring->id = id;
+}
+
+static inline u32 sa_ring_num(PSA_RING ring) {
+	ASSERT(ring);
+	return ring->num;
+}
+
+static inline PVOID sa_ring_va(PSA_RING ring) {
+	ASSERT(ring);
+	return ring->va;
+}
+
+static inline void sa_ring_clear(PSA_RING ring) {
+	ASSERT(ring);
+	ring->pidx = ring->cidx = 0;
+}
+
+/*
+ * 
+-----------------------------------------------------------------------
+ * Interface for 2 index rings. i.e. consumer/producer rings
+ * 
+-----------------------------------------------------------------------
+---
+ */
+
+/* Returns TRUE if ring is empty */
+static inline boolean sa_ring_is_empty(PSA_RING ring) {
+	ASSERT(ring);
+	return (ring->pidx == ring->cidx);
+}
+
+/* Define the power2 version equivalent */ #define 
+sa_ring_power2_is_empty sa_ring_is_empty
+
+/* Returns number items pending on ring. */ static inline u32 
+sa_ring_num_pending(PSA_RING ring) {
+	ASSERT(ring);
+	if (ring->num == 0) {
+		return 0;
+	}
+	return sa_subc(ring->pidx, ring->cidx, ring->num); }
+
+/* Returns number items free on ring. */ static inline u32 
+sa_ring_num_empty(PSA_RING ring) {
+	ASSERT(ring);
+	return ring->num - 1 - sa_ring_num_pending(ring); }
+
+/* Returns TRUE if ring is full */
+static inline boolean sa_ring_is_full(PSA_RING ring) {
+	ASSERT(ring);
+	return sa_ring_num_pending(ring) == (ring->num - 1); }
+
+/* Consume 1 item */
+static inline void sa_ring_consume(PSA_RING ring) {
+	ASSERT(ring);
+	ASSERT(!sa_ring_is_empty(ring));
+	ring->cidx = sa_addc(ring->cidx, 1, ring->num); }
+
+/* Produce 1 item */
+static inline void sa_ring_produce(PSA_RING ring) {
+	ASSERT(ring);
+	ASSERT(!sa_ring_is_full(ring));
+	ring->pidx = sa_addc(ring->pidx, 1, ring->num); }
+
+/* Consume count items */
+static inline void sa_ring_consume_multiple(PSA_RING ring, u32 count) {
+	ASSERT(ring);
+	ASSERT(sa_ring_num_pending(ring) >= count);
+	ring->cidx = sa_addc(ring->cidx, count, ring->num); }
+
+static inline PVOID sa_ring_item(PSA_RING ring, u32 index) {
+	ASSERT(ring);
+	ASSERT(index < ring->num);
+	ASSERT(ring->itemSize > 0);
+	return (u8 *) ring->va + index * ring->itemSize; }
+
+#define sa_ring_power2_item sa_ring_item
+
+/* Ptr to produce item */
+static inline PVOID sa_ring_producer_ptr(PSA_RING ring) {
+	ASSERT(ring);
+	ASSERT(!sa_ring_is_full(ring));
+	return sa_ring_item(ring, ring->pidx); }
+
+#define sa_ring_power2_producer_ptr sa_ring_producer_ptr
+
+/*
+ * Returns a pointer to the current location in the ring.
+ * This is used for rings with 1 index.
+ */
+static inline PVOID sa_ring_current(PSA_RING ring) {
+	ASSERT(ring);
+	ASSERT(ring->pidx == 0);	/* not used */
+
+	return sa_ring_item(ring, ring->cidx); }
+
+/* Ptr to consume item */
+static inline PVOID sa_ring_consumer_ptr(PSA_RING ring) {
+	ASSERT(ring);
+	ASSERT(!sa_ring_is_empty(ring));
+	return sa_ring_item(ring, ring->cidx); }
+
+#define sa_ring_power2_current sa_ring_current
+
+/*
+ * Increment index for rings with only 1 index.
+ * This is used for rings with 1 index.
+ */
+static inline PVOID sa_ring_next(PSA_RING ring) {
+	ASSERT(ring);
+	ASSERT(ring->num > 0);
+	ASSERT(ring->pidx == 0);	/* not used */
+
+	ring->cidx = sa_addc(ring->cidx, 1, ring->num);
+	return sa_ring_current(ring);
+}
+
+/*
+ * Each bit is 1 byte in array maps.
+ */
+typedef u8 AMAP_BIT;
+typedef AMAP_BIT BE_BIT;
+
+/* Returns 0-31 representing bit offset within a DWORD of a bitfield. */
+#define AMAP_BIT_OFFSET(_struct_, _register_)                   \
+	(((SA_SIZE_T)&(((BE_ ## _struct_ ## _AMAP *)0)->_register_))%32)
+
+
+/* Returns 0-n representing byte offset of bitfield with the structure. */
+#define AMAP_BYTE_OFFSET(_struct_, _register_)                  \
+	(((SA_SIZE_T)&(((BE_ ## _struct_ ## _AMAP *)0)->_register_))/8)
+
+/* Returns 0-n representing DWORD offset of bitfield within the 
+structure. */ #define AMAP_WORD_OFFSET(_struct_, _register_)  \
+  (AMAP_BYTE_OFFSET(_struct_, _register_)/4)
+
+/*-------- spinlock / mutex related -------*/
+
+typedef spinlock_t SA_REAL_SPINLOCK, *PSA_REAL_SPINLOCK; typedef 
+spinlock_t SA_SPINLOCK, *PSA_SPINLOCK; typedef struct semaphore 
+SA_FAST_MUTEX, *PSA_FAST_MUTEX; typedef struct semaphore SA_EVENT, 
+*PSA_EVENT; typedef u64 SA_IRQ, *PSA_IRQ;
+
+#define sa_init_spinlock           sa_init_spinlock_real
+#define sa_acquire_spinlock        sa_acquire_spinlock_real
+#define sa_release_spinlock        sa_release_spinlock_real
+#define sa_acquire_spinlock_noirq  sa_acquire_spinlock_noirq_real 
+#define sa_release_spinlock_noirq  sa_release_spinlock_noirq_real
+#define sa_is_spin_lock_held       sa_is_spin_lock_held_real
+#define sa_is_spinlock_not_held    sa_is_spinlock_not_held_real
+
+void sa_init_spinlock_real(IN PSA_REAL_SPINLOCK); void 
+sa_acquire_spinlock_real(IN PSA_REAL_SPINLOCK, OUT PSA_IRQ); void 
+sa_release_spinlock_real(IN PSA_REAL_SPINLOCK, IN PSA_IRQ); void 
+sa_initialize_fast_mutex(IN PSA_FAST_MUTEX);
+
+static inline u32 sa_atomic_decrement(u32 *value) {
+	atomic_dec((atomic_t *) value);
+	return *value;
+}
+
+/* Returns resulting value. */
+static inline u32 sa_atomic_increment(u32 *value) {
+	atomic_inc((atomic_t *) value);
+	return *value;
+}
+
+/* Atomically does this: *v += i; */
+#define sa_atomic_add(i, v)	atomic_add (i, (atomic_t *)v)
+
+/* Atomically does this: *v -= i; */
+#define sa_atomic_sub(i, v)	atomic_sub(i, (atomic_t *)v)
+
+#define sa_init_spinlock_real(s)		spin_lock_init(s)
+#define sa_acquire_spinlock_real(s, i)		spin_lock_irqsave(s, *i)
+#define sa_acquire_spinlock_noirq_real(s) 	spin_lock (s)
+#define sa_release_spinlock_real(s, i)		spin_unlock_irqrestore(s, *i);
+#define sa_release_spinlock_noirq_real(s) 	spin_unlock(spinlock)
+#define sa_is_spin_lock_held_real(s) 		spin_is_locked (s);
+#define sa_is_spinlock_not_held_real(s) 	(!(spin_is_locked (lock))
+
+/* Returns size of bitfield in bits. */ #define AMAP_BIT_SIZE(_struct_, 
+_register_) \
+		sizeof(((BE_ ## _struct_ ## _AMAP *)0)->_register_)
+
+/*
+ * Masks the bits (before shifting!) and then shifts to correct offset.
+ * contextMemory.dw[1] = AMAP_SET_BITS (struct, field1, 123) |
+ *                       AMAP_SET_BITS (struct, field2, 456):
+ * Remember this does not clear bits!
+ */
+static inline u32 amap_set_bits(u32 mask, u32 offset, u32 new_value) {
+	return (mask & new_value) << offset;
+}
+
+/*
+ * Returns the a bit mask for the register that is NOT shifted into location.
+ * That means return values always look like: 0x1, 0xFF, 0x7FF, etc...
+ */
+static inline u32 amap_mask(u32 bit_size) {
+	return (bit_size == 32 ? 0xFFFFFFFF : (1 << bit_size) - 1); }
+
+#define AMAP_SET_BITS(_struct_, _register_, _new_value_)  \
+	amap_set_bits(AMAP_BIT_MASK(_struct_, _register_),    \
+	AMAP_BIT_OFFSET(_struct_, _register_), _new_value_)
+
+#define AMAP_BIT_MASK(_struct_, _register_)       \
+	amap_mask (AMAP_BIT_SIZE (_struct_, _register_))
+
+#define BE_BIT_OFFSET   AMAP_BIT_OFFSET
+#define BE_WORD_OFFSET  AMAP_WORD_OFFSET
+#define BE_BIT_SIZE     AMAP_BIT_SIZE
+#define BE_BYTE_OFFSET  AMAP_BYTE_OFFSET
+#define BE_SET_BITS     AMAP_SET_BITS
+
+/*------- MAC address related -------*/
+
+#define SA_MAC_FORMAT "%02x:%02x:%02x:%02x:%02x:%02x"
+
+#define SA_MAC_ADDRESS_SIZE (6)
+typedef struct _SA_MAC_ADDRESS {
+	u8 bytes[SA_MAC_ADDRESS_SIZE];
+} __attribute__ ((packed)) SA_MAC_ADDRESS, *PSA_MAC_ADDRESS;
+
+#define SA_MAC_ARGS(_mac_address_)  \
+	(u32)((_mac_address_).bytes[0]),     \
+	(u32)((_mac_address_).bytes[1]),     \
+	(u32)((_mac_address_).bytes[2]),     \
+	(u32)((_mac_address_).bytes[3]),     \
+	(u32)((_mac_address_).bytes[4]),     \
+	(u32)((_mac_address_).bytes[5])
+
+/*
+ * Creates a SGL for a physically contiguous chunk of memory.
+ * The sgl struct must be previously allocated.
+ */
+static inline SA_STATUS
+sa_sgl_create_contiguous(PVOID va, SA_PHYSICAL_ADDRESS pa,
+			 u32 length, PSA_SGL sgl)
+{
+
+	sgl->va = va;
+	sgl->pa = pa;
+	sgl->length = length;
+	return (SA_SUCCESS);
+}
+
+#define sa_sgl_destroy_contiguous(sgl) SA_ZERO_MEM (sgl)
+
+/*
+ *------ bit manipulation macros / functions -----
+ * Checks for truncation of the value when assigning to a bitfield that
+ * may have fewer bits.  e.g.
+ * struct { u32 hi : 1; } me;
+ * SA_SET_BITFIELD(me.hi, 2);
+ */
+#define SA_SET_BITFIELD(_bitfield_, _value_)  \
+	do {\
+		(_bitfield_) = (_value_);                 \
+		ASSERT((_bitfield_) == (_value_))        \
+	} while (0) \
+
+static
+inline u32 sa_bit_range(u32 value, u32 bit_offset, u32 num_bits) {
+	ASSERT(bit_offset <= sizeof(value) * 8);
+	ASSERT(num_bits <= sizeof(value) * 8);
+	return (value >> bit_offset) & ((1UL << num_bits) - 1); }
+
+static
+inline u64 sa_bit_range64(u64 value, u32 bit_offset, u32 num_bits) {
+	ASSERT(bit_offset <= sizeof(value) * 8);
+	ASSERT(num_bits <= sizeof(value) * 8);
+	return (value >> bit_offset) & ((1ULL << num_bits) - 1); }
+
+static inline u32 sa_upper_bits(u32 value, u32 num_bits) {
+	ASSERT(num_bits <= sizeof(value) * 8);
+	return sa_bit_range(value, sizeof(value) * 8 - num_bits, num_bits); }
+
+static inline u64 sa_upper_bits64(u64 value, u32 num_bits) {
+	ASSERT(num_bits <= sizeof(value) * 8);
+	return sa_bit_range64(value, sizeof(value) * 8 - num_bits,
+			      num_bits);
+}
+
+/* The bit vector structure. */
+typedef struct _SA_BIT_VECTOR {
+	u32 magic;
+	u32 numBits;
+	u32 numDwords;
+	u32 numSet;
+	u32 *bits;
+} SA_BIT_VECTOR, *PSA_BIT_VECTOR;
+
+#endif /* __sa_h__ */

___________________________________________________________________________________
This message, together with any attachment(s), contains confidential and proprietary information of
ServerEngines Corporation and is intended only for the designated recipient(s) named above. Any unauthorized
review, printing, retention, copying, disclosure or distribution is strictly prohibited.  If you are not the
intended recipient of this message, please immediately advise the sender by reply email message and
delete all copies of this message and any attachment(s). Thank you.

