From: Dean Nelson <dcn@sgi.com>
Subject: [PATCH 2/4] SGI Altix cross partition functionality (1st revision)
Date: Tue, 24 Aug 2004 13:23:44 -0500
Sender: netdev-bounce@oss.sgi.com
Message-ID: <20040824182344.GB13961@sgi.com>
References: <412B823E.mailxAMX1HROPJ@aqua.americas.sgi.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Return-path: <netdev-bounce@oss.sgi.com>
To: linux-ia64@vger.kernel.org, netdev@oss.sgi.com
Content-Disposition: inline
In-Reply-To: <412B823E.mailxAMX1HROPJ@aqua.americas.sgi.com>
Errors-to: netdev-bounce@oss.sgi.com
List-Id: netdev.vger.kernel.org

This patch contains the shim module (XP) which interfaces between the
communication module (XPC) and the functional support modules (like XPNET).

Signed-off-by: Dean Nelson <dcn@sgi.com>


Index: linux/arch/ia64/Kconfig
===================================================================
--- linux.orig/arch/ia64/Kconfig	2004-08-17 13:31:26.000000000 -0500
+++ linux/arch/ia64/Kconfig	2004-08-23 11:39:50.000000000 -0500
@@ -189,6 +189,16 @@
 	depends on !IA64_HP_SIM
 	default y
 
+config IA64_SGI_SN_XPC
+	tristate "Support DMA Messaging between SGI machines"
+	depends on FETCHOP
+	help
+	  An SGI machine can be divided into multiple Single System
+	  Images which act independently of each other and have
+	  hardware based memory protection from the others.  Enabling
+	  this feature will allow limited communication between
+	  those System Images without allowing write access.
+
 config IA64_SGI_SN_SIM
 	bool "SGI Medusa Simulator Support"
 	depends on IA64_SGI_SN2
Index: linux/arch/ia64/sn/kernel/Makefile
===================================================================
--- linux.orig/arch/ia64/sn/kernel/Makefile	2004-06-16 00:18:59.000000000 -0500
+++ linux/arch/ia64/sn/kernel/Makefile	2004-08-23 10:55:03.000000000 -0500
@@ -9,3 +9,5 @@
 
 obj-y				+= probe.o setup.o bte.o irq.o mca.o idle.o sn2/
 obj-$(CONFIG_IA64_GENERIC)      += machvec.o
+obj-$(CONFIG_IA64_SGI_SN_XPC)	+= xp.o
+xp-y				:= xp_main.o xp_kdb.o xp_nofault.o
Index: linux/arch/ia64/sn/kernel/xp_main.c
===================================================================
--- /dev/null	1970-01-01 00:00:00.000000000 +0000
+++ linux/arch/ia64/sn/kernel/xp_main.c	2004-08-23 10:55:03.000000000 -0500
@@ -0,0 +1,358 @@
+/*
+ * This file is subject to the terms and conditions of the GNU General Public
+ * License.  See the file "COPYING" in the main directory of this archive
+ * for more details.
+ *
+ * Copyright (c) 2004 Silicon Graphics, Inc.  All Rights Reserved.
+ */
+
+
+/*
+ * Cross Partition (XP) base.
+ *
+ *	XP provides a base from which its users can interact
+ *	with XPC, yet not be dependent on XPC.
+ *
+ */
+
+
+#include <linux/kernel.h>
+#include <linux/interrupt.h>
+#include <linux/module.h>
+#include <asm/sn/intr.h>
+#include <asm/sn/sn_sal.h>
+#include <asm/sn/xp.h>
+
+
+/*
+ * xpc_registrations[] keeps track of xpc_connect()'s done by the kernel-level
+ * users of XPC.
+ */
+struct xpc_registration xpc_registrations[XPC_NCHANNELS];
+
+
+/*
+ * Initialize the XPC interface to inidicate that XPC isn't loaded.
+ */
+static enum xpc_retval xpc_notloaded(void) { return xpcNotLoaded; }
+
+struct xpc_interface xpc_interface = {
+	(void (*)(int)) xpc_notloaded,
+	(void (*)(int)) xpc_notloaded,
+	(enum xpc_retval (*)(partid_t, int, u32, void **)) xpc_notloaded,
+	(enum xpc_retval (*)(partid_t, int, void *)) xpc_notloaded,
+	(enum xpc_retval (*)(partid_t, int, void *, xpc_notify_func, void *))
+							xpc_notloaded,
+	(void (*)(partid_t, int, void *)) xpc_notloaded,
+	(enum xpc_retval (*)(partid_t, void *)) xpc_notloaded
+};
+
+
+char *
+xpc_get_ascii_reason_code(enum xpc_retval reason)
+{
+	switch (reason) {
+	case xpcSuccess:		return "";
+	case xpcNotConnected:		return "xpcNotConnected";
+	case xpcConnected:		return "xpcConnected";
+	case xpcRETIRED1:		return "xpcRETIRED1";
+	case xpcMsgReceived:		return "xpcMsgReceived";
+	case xpcMsgDelivered:		return "xpcMsgDelivered";
+	case xpcRETIRED2:		return "xpcRETIRED2";
+	case xpcNoWait:			return "xpcNoWait";
+	case xpcRetry:			return "xpcRetry";
+	case xpcTimeout:		return "xpcTimeout";
+	case xpcInterrupted:		return "xpcInterrupted";
+	case xpcUnequalMsgSizes:	return "xpcUnequalMsgSizes";
+	case xpcInvalidAddress:		return "xpcInvalidAddress";
+	case xpcNoMemory:		return "xpcNoMemory";
+	case xpcLackOfResources:	return "xpcLackOfResources";
+	case xpcUnregistered:		return "xpcUnregistered";
+	case xpcAlreadyRegistered:	return "xpcAlreadyRegistered";
+	case xpcPartitionDown:		return "xpcPartitionDown";
+	case xpcNotLoaded:		return "xpcNotLoaded";
+	case xpcUnloading:		return "xpcUnloading";
+	case xpcBadMagic:		return "xpcBadMagic";
+	case xpcReactivating:		return "xpcReactivating";
+	case xpcUnregistering:		return "xpcUnregistering";
+	case xpcOtherUnregistering:	return "xpcOtherUnregistering";
+	case xpcCloneKThread:		return "xpcCloneKThread";
+	case xpcCloneKThreadFailed:	return "xpcCloneKThreadFailed";
+	case xpcNoHeartbeat:		return "xpcNoHeartbeat";
+	case xpcPioReadError:		return "xpcPioReadError";
+	case xpcPhysAddrRegFailed:	return "xpcPhysAddrRegFailed";
+	case xpcBteDirectoryError:	return "xpcBteDirectoryError";
+	case xpcBtePoisonError:		return "xpcBtePoisonError";
+	case xpcBteWriteError:		return "xpcBteWriteError";
+	case xpcBteAccessError:		return "xpcBteAccessError";
+	case xpcBtePWriteError:		return "xpcBtePWriteError";
+	case xpcBtePReadError:		return "xpcBtePReadError";
+	case xpcBteTimeOutError:	return "xpcBteTimeOutError";
+	case xpcBteXtalkError:		return "xpcBteXtalkError";
+	case xpcBteNotAvailable:	return "xpcBteNotAvailable";
+	case xpcBteUnmappedError:	return "xpcBteUnmappedError";
+	case xpcBadVersion:		return "xpcBadVersion";
+	case xpcVarsNotSet:		return "xpcVarsNotSet";
+	case xpcNoRsvdPageAddr:		return "xpcNoRsvdPageAddr";
+	case xpcInvalidPartid:		return "xpcInvalidPartid";
+	case xpcLocalPartid:		return "xpcLocalPartid";
+	case xpcUnknownReason:		return "xpcUnknownReason";
+	default:			return "undefined reason code";
+	}
+}
+
+
+static void
+xp_init_xpc(void)
+{
+	extern void xp_kdb_register(void);
+	int ch_number;
+
+
+	xp_kdb_register();
+
+	/* initialize the connection registration semaphores */
+	for (ch_number = 0; ch_number < XPC_NCHANNELS; ch_number++) {
+		sema_init(&xpc_registrations[ch_number].sema, 1);  /* mutex */
+	}
+}
+
+
+static void
+xp_exit_xpc(void)
+{
+	extern void xp_kdb_unregister(void);
+
+
+	xp_kdb_unregister();
+}
+
+
+/*
+ * XPC calls this when it (the XPC module) has been loaded.
+ */
+void
+xpc_set_interface(void (*connect)(int),
+		void (*disconnect)(int),
+		enum xpc_retval (*allocate)(partid_t, int, u32, void **),
+		enum xpc_retval (*send)(partid_t, int, void *),
+		enum xpc_retval (*send_notify)(partid_t, int, void *,
+						xpc_notify_func, void *),
+		void (*received)(partid_t, int, void *),
+		enum xpc_retval (*partid_to_nasids)(partid_t, void *))
+{
+	xpc_interface.connect = connect;
+	xpc_interface.disconnect = disconnect;
+	xpc_interface.allocate = allocate;
+	xpc_interface.send = send;
+	xpc_interface.send_notify = send_notify;
+	xpc_interface.received = received;
+	xpc_interface.partid_to_nasids = partid_to_nasids;
+}
+
+
+/*
+ * XPC calls this when it (the XPC module) is being unloaded.
+ */
+void
+xpc_clear_interface(void)
+{
+	xpc_interface.connect = (void (*)(int)) xpc_notloaded;
+	xpc_interface.disconnect = (void (*)(int)) xpc_notloaded;
+	xpc_interface.allocate = (enum xpc_retval (*)(partid_t, int, u32,
+					void **)) xpc_notloaded;
+	xpc_interface.send = (enum xpc_retval (*)(partid_t, int, void *))
+					xpc_notloaded;
+	xpc_interface.send_notify = (enum xpc_retval (*)(partid_t, int, void *,
+				    xpc_notify_func, void *)) xpc_notloaded;
+	xpc_interface.received = (void (*)(partid_t, int, void *))
+					xpc_notloaded;
+	xpc_interface.partid_to_nasids = (enum xpc_retval (*)(partid_t, void *))
+					xpc_notloaded;
+}
+
+
+/*
+ * Register for automatic establishment of a channel connection whenever
+ * a partition comes up.
+ *
+ * Arguments:
+ *
+ *	ch_number - channel # to register for connection.
+ *	func - function to call for asynchronous notification of channel
+ *	       state changes (i.e., connection, disconnection, error) and
+ *	       the arrival of incoming messages.
+ *      key - pointer to optional user-defined value that gets passed back
+ *	      to the user on any callouts made to func.
+ *	payload_size - size in bytes of the XPC message's payload area which
+ *		       contains a user-defined message. The user should make
+ *		       this large enough to hold their largest message.
+ *	nentries - max #of XPC message entries a message queue can contain.
+ *		   The actual number, which is determined when a connection
+ * 		   is established and may be less then requested, will be
+ *		   passed to the user via the xpcConnected callout.
+ *	assigned_limit - max number of kthreads allowed to be processing
+ * 			 messages (per connection) at any given instant.
+ *	idle_limit - max number of kthreads allowed to be idle at any given
+ * 		     instant.
+ */
+enum xpc_retval
+xpc_connect(int ch_number, xpc_channel_func func, void *key, u16 payload_size,
+		u16 nentries, u32 assigned_limit, u32 idle_limit)
+{
+	struct xpc_registration *registration;
+
+
+	DBUG_ON(ch_number < 0 || ch_number >= XPC_NCHANNELS);
+	DBUG_ON(payload_size == 0 || nentries == 0);
+	DBUG_ON(func == NULL);
+	DBUG_ON(assigned_limit == 0 || idle_limit > assigned_limit);
+
+	registration = &xpc_registrations[ch_number];
+
+	if (down_interruptible(&registration->sema) != 0) {
+		return xpcInterrupted;
+	}
+
+	/* if XPC_CHANNEL_REGISTERED(ch_number) */
+	if (registration->func != NULL) {
+		up(&registration->sema);
+		return xpcAlreadyRegistered;
+	}
+
+	/* register the channel for connection */
+	registration->msg_size = XPC_MSG_SIZE(payload_size);
+	registration->nentries = nentries;
+	registration->assigned_limit = assigned_limit;
+	registration->idle_limit = idle_limit;
+	registration->key = key;
+	registration->func = func;
+
+	up(&registration->sema);
+
+	xpc_interface.connect(ch_number);
+
+	return xpcSuccess;
+}
+
+
+/*
+ * Remove the registration for automatic connection of the specified channel
+ * when a partition comes up.
+ *
+ * Before returning this xpc_disconnect() will wait for all connections on the
+ * specified channel have been closed/torndown. So the caller can be assured
+ * that they will not be receiving any more callouts from XPC to their
+ * function registered via xpc_connect().
+ *
+ * Arguments:
+ *
+ *	ch_number - channel # to unregister.
+ */
+void
+xpc_disconnect(int ch_number)
+{
+	struct xpc_registration *registration;
+
+
+	DBUG_ON(ch_number < 0 || ch_number >= XPC_NCHANNELS);
+
+	registration = &xpc_registrations[ch_number];
+
+	/*
+	 * We've decided not to make this a down_interruptible(), since we
+	 * figured XPC's users will just turn around and call xpc_disconnect()
+	 * again anyways, so we might as well wait, if need be.
+	 */
+	down(&registration->sema);
+
+	/* if !XPC_CHANNEL_REGISTERED(ch_number) */
+	if (registration->func == NULL) {
+		up(&registration->sema);
+		return;
+	}
+
+	/* remove the connection registration for the specified channel */
+	registration->func = NULL;
+	registration->key = NULL;
+	registration->nentries = 0;
+	registration->msg_size = 0;
+	registration->assigned_limit = 0;
+	registration->idle_limit = 0;
+
+	xpc_interface.disconnect(ch_number);
+
+	up(&registration->sema);
+
+	return;
+}
+
+
+int __init
+xp_init(void)
+{
+	int ret;
+	int (* pior_func)(void *) = xp_nofault_PIOR;
+	int (* pior_err_func)(void) = xp_error_PIOR;
+
+
+	if (!ia64_platform_is("sn2")) {
+		return -ENODEV;
+	}
+
+
+	/*
+	 * Register a nofault code region which performs a cross-partition
+	 * PIO read. If the PIO read times out, the MCA handler will consume
+	 * the error and return to a kernel-provided instruction to indicate
+	 * an error. This PIO read exists because it is guaranteed to timeout
+	 * if the destination is down (AMO operations do not timeout on at
+	 * least some CPUs on Shubs <= v1.2, which unfortunately we have to
+	 * work around).
+	 */
+	if ((ret = sn_register_nofault_code(*(u64 *) pior_func,
+					*(u64 *) pior_err_func,
+					*(u64 *) pior_err_func, 1, 1)) != 0) {
+		printk(KERN_ERR "XP: can't register nofault code, error=%d\n",
+			ret);
+	}
+
+
+	xp_init_xpc();
+
+	return 0;
+}
+module_init(xp_init);
+
+
+void __exit
+xp_exit(void)
+{
+	int (* pior_func)(void *) = xp_nofault_PIOR;
+	int (* pior_err_func)(void) = xp_error_PIOR;
+
+
+	xp_exit_xpc();
+
+
+	/* unregister the PIO nofault code region */
+	(void) sn_register_nofault_code(*(u64 *) pior_func,
+					*(u64 *) pior_err_func,
+					*(u64 *) pior_err_func, 1, 0);
+}
+module_exit(xp_exit);
+
+
+MODULE_AUTHOR("Silicon Graphics, Inc.");
+MODULE_DESCRIPTION("Cross Partition (XP) base");
+MODULE_LICENSE("GPL");
+
+EXPORT_SYMBOL(xp_nofault_PIOR);
+EXPORT_SYMBOL(xpc_get_ascii_reason_code);
+EXPORT_SYMBOL(xpc_registrations);
+EXPORT_SYMBOL(xpc_interface);
+EXPORT_SYMBOL(xpc_clear_interface);
+EXPORT_SYMBOL(xpc_set_interface);
+EXPORT_SYMBOL(xpc_connect);
+EXPORT_SYMBOL(xpc_disconnect);
+
Index: linux/arch/ia64/sn/kernel/xp_nofault.S
===================================================================
--- /dev/null	1970-01-01 00:00:00.000000000 +0000
+++ linux/arch/ia64/sn/kernel/xp_nofault.S	2004-08-23 10:55:03.000000000 -0500
@@ -0,0 +1,31 @@
+/*
+ * This file is subject to the terms and conditions of the GNU General Public
+ * License.  See the file "COPYING" in the main directory of this archive
+ * for more details.
+ *
+ * Copyright (c) 2004 Silicon Graphics, Inc.  All Rights Reserved.
+ */
+
+
+/*
+ * The xp_nofault_PIOR function takes a pointer to a remote PIO register
+ * and attempts to load and consume a value from it.  This function
+ * will be registered as a nofault code block.  In the event that the
+ * PIO read fails, the MCA handler will force the error to look
+ * corrected and vector to the xp_error_PIOR which will return an error.
+ *
+ *	extern int xp_nofault_PIOR(void *remote_register);
+ */
+
+	.global xp_nofault_PIOR
+xp_nofault_PIOR:
+	mov	r8=r0			// Stage a success return value
+	ld8.acq	r9=[r32];;		// PIO Read the specified register
+	adds	r9=1,r9			// Add to force a consume
+	br.ret.sptk.many b0;;		// Return success
+
+	.global xp_error_PIOR
+xp_error_PIOR:
+	mov	r8=1			// Return value of 1
+	br.ret.sptk.many b0;;		// Return failure
+
Index: linux/include/asm-ia64/sn/xp.h
===================================================================
--- /dev/null	1970-01-01 00:00:00.000000000 +0000
+++ linux/include/asm-ia64/sn/xp.h	2004-08-23 10:55:03.000000000 -0500
@@ -0,0 +1,426 @@
+/*
+ * This file is subject to the terms and conditions of the GNU General Public
+ * License.  See the file "COPYING" in the main directory of this archive
+ * for more details.
+ *
+ * Copyright (C) 2004 Silicon Graphics, Inc. All rights reserved.
+ */
+
+
+/*
+ * External Cross Partition (XP) structures and defines.
+ */
+
+
+#ifndef _ASM_IA64_SN_XP_H
+#define _ASM_IA64_SN_XP_H
+
+
+#include <linux/version.h>
+#include <linux/cache.h>
+#include <asm/sn/types.h>
+#include <asm/sn/bte.h>
+#include <asm/hardirq.h>
+
+
+#ifdef USE_DBUG_ON
+#define DBUG_ON(condition)	BUG_ON(condition)
+#else
+#define DBUG_ON(condition)
+#endif
+
+
+/*
+ * Define the number of u64s required to represent all the C-brick nasids
+ * as a bitmap.  The cross-partition kernel modules deal only with
+ * C-brick nasids, thus the need for bitmaps which don't account for
+ * odd-numbered (non C-brick) nasids.
+ */
+#define XP_MAX_NASIDS		(MAX_NASIDS / 2)
+#define XP_NUM_NASID_WORDS	((XP_MAX_NASIDS + 63)/ 64)
+
+
+/*
+ * Wrapper for bte_copy() that should it return a failure status will retry
+ * the bte_copy() once in the hope that the failure was due to a temporary
+ * aberration (i.e., the link going down temporarily).
+ *
+ * See bte_copy for definition of the input parameters.
+ *
+ * Note: xp_bte_copy() should never be called while holding a spinlock.
+ */
+static inline bte_result_t
+xp_bte_copy(u64 src, u64 dest, u64 len, u64 mode, void *notification)
+{
+	bte_result_t ret;
+
+
+	ret = bte_copy(src, dest, len, mode, notification);
+
+	if (ret != BTE_SUCCESS) {
+		if (!in_interrupt()) {
+			cond_resched();
+		}
+		ret = bte_copy(src, dest, len, mode, notification);
+	}
+
+	return ret;
+}
+
+
+/*
+ * XPC establishes channel connections between the local partition and any
+ * other partition that is currently up. Over these channels, kernel-level
+ * `users' can communicate with their counterparts on the other partitions.
+ *
+ * The maxinum number of channels is limited to eight. For performance reasons,
+ * the internal cross partition structures require sixteen bytes per channel,
+ * and eight allows all of this interface-shared info to fit in one cache line.
+ *
+ * XPC_NCHANNELS reflects the total number of channels currently defined.
+ * If the need for additional channels arises, one can simply increase
+ * XPC_NCHANNELS accordingly. If the day should come where that number
+ * exceeds the MAXIMUM number of channels allowed (eight), then one will need
+ * to make changes to the XPC code to allow for this.
+ */
+#define XPC_MEM_CHANNEL		0	/* memory channel number */
+#define	XPC_NET_CHANNEL		1	/* network channel number */
+
+#define	XPC_NCHANNELS		2	/* #of defined channels */
+#define XPC_MAX_NCHANNELS	8	/* max #of channels allowed */
+
+#if XPC_NCHANNELS > XPC_MAX_NCHANNELS
+#error	XPC_NCHANNELS exceeds MAXIMUM allowed.
+#endif
+
+
+/*
+ * The format of an XPC message is as follows:
+ *
+ *      +-------+--------------------------------+
+ *      | flags |////////////////////////////////|
+ *      +-------+--------------------------------+
+ *      |             message #                  |
+ *      +----------------------------------------+
+ *      |     payload (user-defined message)     |
+ *      |                                        |
+ *         		:
+ *      |                                        |
+ *      +----------------------------------------+
+ *
+ * The size of the payload is defined by the user via xpc_connect(). A user-
+ * defined message resides in the payload area.
+ *
+ * The user should have no dealings with the message header, but only the
+ * message's payload. When a message entry is allocated (via xpc_allocate())
+ * a pointer to the payload area is returned and not the actual beginning of
+ * the XPC message. The user then constructs a message in the payload area
+ * and passes that pointer as an argument on xpc_send() or xpc_send_notify().
+ *
+ * The size of a message entry (within a message queue) must be a cacheline
+ * sized multiple in order to facilitate the BTE transfer of messages from one
+ * message queue to another. A macro, XPC_MSG_SIZE(), is provided for the user
+ * that wants to fit as many msg entries as possible in a given memory size
+ * (e.g. a memory page).
+ */
+struct xpc_msg {
+	u8 flags;		/* FOR XPC INTERNAL USE ONLY */
+	u8 reserved[7];		/* FOR XPC INTERNAL USE ONLY */
+	s64 number;		/* FOR XPC INTERNAL USE ONLY */
+
+	u64 payload;		/* user defined portion of message */
+};
+
+
+#define XPC_MSG_PAYLOAD_OFFSET	(u64) (&((struct xpc_msg *)0)->payload)
+#define XPC_MSG_SIZE(_payload_size) \
+		L1_CACHE_ALIGN(XPC_MSG_PAYLOAD_OFFSET + (_payload_size))
+
+
+/*
+ * Define the return values and values passed to user's callout functions. 
+ * (It is important to add new value codes at the end just preceding
+ * xpcUnknownReason, which must have the highest numerical value.)
+ */
+enum xpc_retval {
+	xpcSuccess = 0,
+
+	xpcNotConnected,	/*  1: channel is not connected */
+	xpcConnected,		/*  2: channel connected (opened) */
+	xpcRETIRED1,		/*  3: (formerly xpcDisconnected) */
+
+	xpcMsgReceived,		/*  4: message received */
+	xpcMsgDelivered,	/*  5: message delivered and acknowledged */
+
+	xpcRETIRED2,		/*  6: (formerly xpcTransferFailed) */
+
+	xpcNoWait,		/*  7: operation would require wait */
+	xpcRetry,		/*  8: retry operation */
+	xpcTimeout,		/*  9: timeout in xpc_allocate_msg_wait() */
+	xpcInterrupted,		/* 10: interrupted wait */
+
+	xpcUnequalMsgSizes,	/* 11: message size disparity between sides */
+	xpcInvalidAddress,	/* 12: invalid address */
+
+	xpcNoMemory,		/* 13: no memory available for XPC structures */
+	xpcLackOfResources,	/* 14: insufficient resources for operation */
+	xpcUnregistered,	/* 15: channel is not registered */
+	xpcAlreadyRegistered,	/* 16: channel is already registered */
+
+	xpcPartitionDown,	/* 17: remote partition is down */
+	xpcNotLoaded,		/* 18: XPC module is not loaded */
+	xpcUnloading,		/* 19: this side is unloading XPC module */
+
+	xpcBadMagic,		/* 20: XPC MAGIC string not found */
+
+	xpcReactivating,	/* 21: remote partition was reactivated */
+
+	xpcUnregistering,	/* 22: this side is unregistering channel */
+	xpcOtherUnregistering,	/* 23: other side is unregistering channel */
+
+	xpcCloneKThread,	/* 24: cloning kernel thread */
+	xpcCloneKThreadFailed,	/* 25: cloning kernel thread failed */
+
+	xpcNoHeartbeat,		/* 26: remote partition has no heartbeat */
+
+	xpcPioReadError,	/* 27: PIO read error */
+	xpcPhysAddrRegFailed,	/* 28: registration of phys addr range failed */
+
+	xpcBteDirectoryError,	/* 29: maps to BTEFAIL_DIR */
+	xpcBtePoisonError,	/* 30: maps to BTEFAIL_POISON */
+	xpcBteWriteError,	/* 31: maps to BTEFAIL_WERR */
+	xpcBteAccessError,	/* 32: maps to BTEFAIL_ACCESS */
+	xpcBtePWriteError,	/* 33: maps to BTEFAIL_PWERR */
+	xpcBtePReadError,	/* 34: maps to BTEFAIL_PRERR */
+	xpcBteTimeOutError,	/* 35: maps to BTEFAIL_TOUT */
+	xpcBteXtalkError,	/* 36: maps to BTEFAIL_XTERR */
+	xpcBteNotAvailable,	/* 37: maps to BTEFAIL_NOTAVAIL */
+	xpcBteUnmappedError,	/* 38: unmapped BTEFAIL_ error */
+
+	xpcBadVersion,		/* 39: bad version number */
+	xpcVarsNotSet,		/* 40: the XPC variables are not set up */
+	xpcNoRsvdPageAddr,	/* 41: unable to get rsvd page's phys addr */
+	xpcInvalidPartid,	/* 42: invalid partition ID */
+	xpcLocalPartid,		/* 43: local partition ID */
+
+	xpcUnknownReason	/* 44: unknown reason -- must be last in list */
+};
+
+
+/*
+ * Define the callout function types used by XPC to update the user on
+ * connection activity and state changes (via the user function registered by
+ * xpc_connect()) and to notify them of messages received and delivered (via
+ * the user function registered by xpc_send_notify()).
+ *
+ * The two function types are xpc_channel_func and xpc_notify_func and
+ * both share the following arguments, with the exception of "data", which
+ * only xpc_channel_func has.
+ *
+ * Arguments:
+ *
+ *	reason - reason code. (See following table.)
+ *	partid - partition ID associated with condition.
+ *	ch_number - channel # associated with condition.
+ *	data - pointer to optional data. (See following table.)
+ *	key - pointer to optional user-defined value provided as the "key"
+ *	      argument to xpc_connect() or xpc_send_notify().
+ *
+ * In the following table the "Optional Data" column applies to callouts made
+ * to functions registered by xpc_connect(). A "NA" in that column indicates
+ * that this reason code can be passed to functions registered by
+ * xpc_send_notify() (i.e. they don't have data arguments).
+ *
+ * Also, the first three reason codes in the following table indicate
+ * success, whereas the others indicate failure. When a failure reason code
+ * is received, one can assume that the channel is not connected.
+ *
+ *
+ * Reason Code          | Cause                          | Optional Data
+ * =====================+================================+=====================
+ * xpcConnected         | connection has been established| max #of entries
+ *                      | to the specified partition on  | allowed in message
+ *                      | the specified channel          | queue 
+ * ---------------------+--------------------------------+---------------------
+ * xpcMsgReceived       | an XPC message arrived from    | address of payload
+ *                      | the specified partition on the |
+ *                      | specified channel              | [the user must call
+ *                      |                                | xpc_received() when
+ *                      |                                | finished with the
+ *                      |                                | payload]
+ * ---------------------+--------------------------------+---------------------
+ * xpcMsgDelivered      | notification that the message  | NA
+ *                      | was delivered to the intended  |
+ *                      | recipient and that they have   |
+ *                      | acknowledged its receipt by    |
+ *                      | calling xpc_received()         |
+ * =====================+================================+=====================
+ * xpcUnequalMsgSizes   | can't connect to the specified | NULL
+ *                      | partition on the specified     |
+ *                      | channel because of mismatched  |
+ *                      | message sizes                  |
+ * ---------------------+--------------------------------+---------------------
+ * xpcNoMemory          | insufficient memory avaiable   | NULL
+ *                      | to allocate message queue      | 
+ * ---------------------+--------------------------------+---------------------
+ * xpcLackOfResources   | lack of resources to create    | NULL
+ *                      | the necessary kthreads to      |
+ *                      | support the channel            |
+ * ---------------------+--------------------------------+---------------------
+ * xpcUnregistering     | this side's user has           | NULL or NA
+ *                      | unregistered by calling        | 
+ *                      | xpc_disconnect()               |
+ * ---------------------+--------------------------------+---------------------
+ * xpcOtherUnregistering| the other side's user has      | NULL or NA
+ *                      | unregistered by calling        |
+ *                      | xpc_disconnect()               |
+ * ---------------------+--------------------------------+---------------------
+ * xpcNoHeartbeat       | the other side's XPC is no     | NULL or NA
+ *                      | longer heartbeating            |
+ *                      |                                |
+ * ---------------------+--------------------------------+---------------------
+ * xpcUnloading         | this side's XPC module is      | NULL or NA
+ *                      | being unloaded                 |
+ *                      |                                |
+ * ---------------------+--------------------------------+---------------------
+ * xpcOtherUnloading    | the other side's XPC module is | NULL or NA
+ *                      | is being unloaded              |
+ *                      |                                |
+ * ---------------------+--------------------------------+---------------------
+ * xpcPioReadError      | xp_nofault_PIOR() returned an  | NULL or NA
+ *                      | error while sending an IPI     |
+ *                      |                                |
+ * ---------------------+--------------------------------+---------------------
+ * xpcInvalidAddress    | the address either received or | NULL or NA
+ *                      | sent by the specified partition|
+ *                      | is invalid                     |
+ * ---------------------+--------------------------------+---------------------
+ * xpcBteNotAvailable   | attempt to pull data from the  | NULL or NA
+ * xpcBtePoisonError    | specified partition over the   |
+ * xpcBteWriteError     | specified channel via a        |
+ * xpcBteAccessError    | bte_copy() failed              |
+ * xpcBteTimeOutError   |                                |
+ * xpcBteXtalkError     |                                |
+ * xpcBteDirectoryError |                                |
+ * xpcBteGenericError   |                                |
+ * xpcBteUnmappedError  |                                |
+ * ---------------------+--------------------------------+---------------------
+ * xpcUnknownReason     | the specified channel to the   | NULL or NA
+ *                      | specified partition was        |
+ *                      | unavailable for unknown reasons|
+ * =====================+================================+=====================
+ */
+
+typedef void (*xpc_channel_func)(enum xpc_retval reason, partid_t partid,
+		int ch_number, void *data, void *key);
+
+typedef void (*xpc_notify_func)(enum xpc_retval reason, partid_t partid,
+		int ch_number, void *key);
+
+
+/*
+ * The following is a registration entry. There is a global array of these,
+ * one per channel. It is used to record the connection registration made
+ * by the users of XPC. As long as a registration entry exists, for any
+ * partition that comes up, XPC will attempt to establish a connection on
+ * that channel. Notification that a connection has been made will occur via
+ * the xpc_channel_func function.
+ */
+struct xpc_registration {
+
+	struct semaphore sema;
+
+	/*
+	 * Function to call when aynchronous notification is required for
+	 * such events as, a connection established/lost, or an incomming
+	 * message received, or an error condition encountered. A non-NULL
+	 * func field indicates that there is an active registration for
+	 * the channel.
+	 */
+	xpc_channel_func func;
+	void *key;			/* pointer to user's key */
+
+	u16 nentries;			/* #of msg entries in local msg queue */
+	u16 msg_size;			/* message queue's message size */
+	u32 assigned_limit;		/* limit on #of assigned kthreads */
+	u32 idle_limit;			/* limit on #of idle kthreads */
+} ____cacheline_aligned;
+
+
+#define XPC_CHANNEL_REGISTERED(_c)	(xpc_registrations[_c].func != NULL)
+
+
+/* the following are valid xpc_allocate() flags */
+#define XPC_WAIT	0		/* wait flag */
+#define XPC_NOWAIT	1		/* no wait flag */
+
+
+struct xpc_interface {
+	void (*connect)(int);
+	void (*disconnect)(int);
+	enum xpc_retval (*allocate)(partid_t, int, u32, void **);
+	enum xpc_retval (*send)(partid_t, int, void *);
+	enum xpc_retval (*send_notify)(partid_t, int, void *,
+						xpc_notify_func, void *);
+	void (*received)(partid_t, int, void *);
+	enum xpc_retval (*partid_to_nasids)(partid_t, void *);
+};
+
+
+extern struct xpc_interface xpc_interface;
+
+extern void xpc_set_interface(void (*)(int),
+		void (*)(int),
+		enum xpc_retval (*)(partid_t, int, u32, void **),
+		enum xpc_retval (*)(partid_t, int, void *),
+		enum xpc_retval (*)(partid_t, int, void *, xpc_notify_func,
+								void *),
+		void (*)(partid_t, int, void *),
+		enum xpc_retval (*)(partid_t, void *));
+extern void xpc_clear_interface(void);
+
+
+extern enum xpc_retval xpc_connect(int, xpc_channel_func, void *, u16,
+						u16, u32, u32);
+extern void xpc_disconnect(int);
+
+static inline enum xpc_retval
+xpc_allocate(partid_t partid, int ch_number, u32 flags, void **payload)
+{
+	return xpc_interface.allocate(partid, ch_number, flags, payload);
+}
+
+static inline enum xpc_retval
+xpc_send(partid_t partid, int ch_number, void *payload)
+{
+	return xpc_interface.send(partid, ch_number, payload);
+}
+
+static inline enum xpc_retval
+xpc_send_notify(partid_t partid, int ch_number, void *payload,
+			xpc_notify_func func, void *key)
+{
+	return xpc_interface.send_notify(partid, ch_number, payload, func, key);
+}
+
+static inline void
+xpc_received(partid_t partid, int ch_number, void *payload)
+{
+	return xpc_interface.received(partid, ch_number, payload);
+}
+
+static inline enum xpc_retval
+xpc_partid_to_nasids(partid_t partid, void *nasids)
+{
+	return xpc_interface.partid_to_nasids(partid, nasids);
+}
+
+
+extern char *xpc_get_ascii_reason_code(enum xpc_retval);
+
+extern int xp_nofault_PIOR(void *);
+extern int xp_error_PIOR(void);
+
+
+#endif /* _ASM_IA64_SN_XP_H */
+
Index: linux/arch/ia64/sn/kernel/xp_kdb.c
===================================================================
--- /dev/null	1970-01-01 00:00:00.000000000 +0000
+++ linux/arch/ia64/sn/kernel/xp_kdb.c	2004-08-23 10:55:03.000000000 -0500
@@ -0,0 +1,109 @@
+/*
+ * This file is subject to the terms and conditions of the GNU General Public
+ * License.  See the file "COPYING" in the main directory of this archive
+ * for more details.
+ *
+ * Copyright (c) 2004 Silicon Graphics, Inc.  All Rights Reserved.
+ */
+
+
+/*
+ * Cross Partition (XP) base kdb support.
+ *
+ *	This is the part of XP that provides kdb functions for
+ *	debugging purposes.
+ *
+ */
+
+
+#include <linux/kernel.h>
+#ifdef CONFIG_KDB
+#include <linux/kdb.h>
+#include <linux/kdbprivate.h>
+#endif
+#include <asm/sn/xp.h>
+
+
+#ifdef CONFIG_KDB
+
+static void
+xpc_kdb_print_users(struct xpc_registration *registration, int ch_number)
+{
+	kdb_printf("xpc_registrations[channel=%d] (0x%p):\n", ch_number,
+							(void *) registration);
+
+	kdb_printf("\t&sema=0x%p\n", (void *) &registration->sema);
+	kdb_printf("\tfunc=0x%p\n", (void *) registration->func);
+	kdb_printf("\tkey=0x%p\n", registration->key);
+	kdb_printf("\tnentries=%d\n", registration->nentries);
+	kdb_printf("\tmsg_size=%d\n", registration->msg_size);
+	kdb_printf("\tassigned_limit=%d\n", registration->assigned_limit);
+	kdb_printf("\tidle_limit=%d\n", registration->idle_limit);
+}
+
+
+/*
+ * Display current XPC users who have registered via xpc_connect().
+ *
+ *	xpcusers [ <channel> ]
+ */
+static int
+xpc_kdb_users(int argc, const char **argv, const char **envp,
+			struct pt_regs *regs)
+{
+	extern struct xpc_registration xpc_registrations[];
+	int ret;
+	struct xpc_registration *registration;
+	int ch_number;
+
+
+	if (argc > 1) {
+		return KDB_ARGCOUNT;
+
+	} else if (argc == 1) {
+		ret = kdbgetularg(argv[1], (unsigned long *) &ch_number);
+		if (ret) {
+			return ret;
+		}
+		if (ch_number < 0 || ch_number >= XPC_NCHANNELS) {
+			kdb_printf("invalid channel #\n");
+			return KDB_BADINT;
+		}
+		registration = &xpc_registrations[ch_number];
+		xpc_kdb_print_users(registration, ch_number);
+
+	} else {
+		for (ch_number = 0; ch_number < XPC_NCHANNELS; ch_number++) {
+			registration = &xpc_registrations[ch_number];
+
+			/* if !XPC_CHANNEL_REGISTERED(ch_number) */
+			if (registration->func == NULL) {
+				continue;
+			}
+			xpc_kdb_print_users(registration, ch_number);
+		}
+	}
+	return 0;
+}
+
+#endif /* CONFIG_KDB */
+
+
+void
+xp_kdb_register(void)
+{
+#ifdef CONFIG_KDB
+	(void) kdb_register("xpcusers", xpc_kdb_users, "[ <channel> ]",
+				"Display struct xpc_registration entries", 0);
+#endif /* CONFIG_KDB */
+}
+
+
+void
+xp_kdb_unregister(void)
+{
+#ifdef CONFIG_KDB
+	(void) kdb_unregister("xpcusers");
+#endif /* CONFIG_KDB */
+}
+
