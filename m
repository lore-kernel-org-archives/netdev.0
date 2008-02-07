From: Ursula Braun <braunu@de.ibm.com>
Subject: [patch 2/3] ctcm: infrastructure for replaced ctc driver
Date: Fri, 08 Feb 2008 00:03:49 +0100
Message-ID: <20080207232607.992190000@linux.vnet.ibm.com>
References: <20080207230347.075759000@linux.vnet.ibm.com>
Cc: Peter Tiedemann <ptiedem@de.ibm.com>
To: jgarzik@pobox.com, netdev@vger.kernel.org,
	linux-s390@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mtagate1.de.ibm.com ([195.212.29.150]:38027 "EHLO
	mtagate1.de.ibm.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1757930AbYBGX0N (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 7 Feb 2008 18:26:13 -0500
Content-Disposition: inline; filename=702-ctcm-diff
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Peter Tiedemann <ptiedem@de.ibm.com>

ctcm driver supports the channel-to-channel connections of the
old ctc driver plus an additional MPC protocol to provide SNA
connectivity.

This new ctcm driver replaces the existing ctc driver.

Signed-off-by: Peter Tiedemann <ptiedem@de.ibm.com>
Signed-off-by: Ursula Braun <braunu@de.ibm.com>
---

 drivers/s390/net/Kconfig      |   12 
 drivers/s390/net/Makefile     |    5 
 drivers/s390/net/ctcm_dbug.c  |   67 +
 drivers/s390/net/ctcm_dbug.h  |  158 ++
 drivers/s390/net/ctcm_fsms.c  | 2347 +++++++++++++++++++++++++++++++++++++++
 drivers/s390/net/ctcm_fsms.h  |  359 ++++++
 drivers/s390/net/ctcm_main.c  | 1772 ++++++++++++++++++++++++++++++
 drivers/s390/net/ctcm_main.h  |  287 ++++
 drivers/s390/net/ctcm_mpc.c   | 2472 ++++++++++++++++++++++++++++++++++++++++++
 drivers/s390/net/ctcm_mpc.h   |  239 ++++
 drivers/s390/net/ctcm_sysfs.c |  210 +++
 11 files changed, 7920 insertions(+), 8 deletions(-)

Index: linux-2.6-uschi/drivers/s390/net/Makefile
===================================================================
--- linux-2.6-uschi.orig/drivers/s390/net/Makefile
+++ linux-2.6-uschi/drivers/s390/net/Makefile
@@ -2,11 +2,10 @@
 # S/390 network devices
 #
 
-ctc-objs := ctcmain.o ctcdbug.o
-
+ctcm-y += ctcm_main.o ctcm_fsms.o ctcm_mpc.o ctcm_sysfs.o ctcm_dbug.o
+obj-$(CONFIG_CTCM) += ctcm.o fsm.o cu3088.o
 obj-$(CONFIG_NETIUCV) += netiucv.o fsm.o
 obj-$(CONFIG_SMSGIUCV) += smsgiucv.o
-obj-$(CONFIG_CTC) += ctc.o fsm.o cu3088.o
 obj-$(CONFIG_LCS) += lcs.o cu3088.o
 obj-$(CONFIG_CLAW) += claw.o cu3088.o
 qeth-y := qeth_main.o qeth_mpc.o qeth_sys.o qeth_eddp.o 
Index: linux-2.6-uschi/drivers/s390/net/Kconfig
===================================================================
--- linux-2.6-uschi.orig/drivers/s390/net/Kconfig
+++ linux-2.6-uschi/drivers/s390/net/Kconfig
@@ -11,15 +11,17 @@ config LCS
 	   To compile as a module, choose M. The module name is lcs.ko.
 	   If you do not know what it is, it's safe to choose Y.
 
-config CTC
-	tristate "CTC device support"
+config CTCM
+	tristate "CTC and MPC SNA device support"
 	depends on CCW && NETDEVICES
 	help
 	  Select this option if you want to use channel-to-channel
 	  point-to-point networking on IBM System z.
 	  This device driver supports real CTC coupling using ESCON.
 	  It also supports virtual CTCs when running under VM.
-	  To compile as a module, choose M. The module name is ctc.ko.
+	  This driver also supports channel-to-channel MPC SNA devices.
+	  MPC is an SNA protocol device used by Communication Server for Linux.
+	  To compile as a module, choose M. The module name is ctcm.ko.
 	  To compile into the kernel, choose Y.
 	  If you do not need any channel-to-channel connection, choose N.
 
@@ -84,7 +86,7 @@ config QETH_VLAN
 	  802.1q VLAN support in the qeth device driver.
 
 config CCWGROUP
- 	tristate
-	default (LCS || CTC || QETH)
+	tristate
+	default (LCS || CTCM || QETH)
 
 endmenu
Index: linux-2.6-uschi/drivers/s390/net/ctcm_dbug.c
===================================================================
--- /dev/null
+++ linux-2.6-uschi/drivers/s390/net/ctcm_dbug.c
@@ -0,0 +1,67 @@
+/*
+ *	drivers/s390/net/ctcm_dbug.c
+ *
+ *	Copyright IBM Corp. 2001, 2007
+ *	Authors:	Peter Tiedemann (ptiedem@de.ibm.com)
+ *
+ */
+
+#include <linux/stddef.h>
+#include <linux/kernel.h>
+#include <linux/errno.h>
+#include <linux/slab.h>
+#include <linux/ctype.h>
+#include <linux/sysctl.h>
+#include <linux/module.h>
+#include <linux/init.h>
+#include <linux/fs.h>
+#include <linux/debugfs.h>
+#include "ctcm_dbug.h"
+
+/*
+ * Debug Facility Stuff
+ */
+
+DEFINE_PER_CPU(char[256], ctcm_dbf_txt_buf);
+
+struct ctcm_dbf_info ctcm_dbf[CTCM_DBF_INFOS] = {
+	[CTCM_DBF_SETUP]	= {"ctc_setup", 8, 1, 64, 5, NULL},
+	[CTCM_DBF_ERROR]	= {"ctc_error", 8, 1, 64, 3, NULL},
+	[CTCM_DBF_TRACE]	= {"ctc_trace", 8, 1, 64, 3, NULL},
+	[CTCM_DBF_MPC_SETUP]	= {"mpc_setup", 8, 1, 64, 5, NULL},
+	[CTCM_DBF_MPC_ERROR]	= {"mpc_error", 8, 1, 64, 3, NULL},
+	[CTCM_DBF_MPC_TRACE]	= {"mpc_trace", 8, 1, 64, 3, NULL},
+};
+
+void ctcm_unregister_dbf_views(void)
+{
+	int x;
+	for (x = 0; x < CTCM_DBF_INFOS; x++) {
+		debug_unregister(ctcm_dbf[x].id);
+		ctcm_dbf[x].id = NULL;
+	}
+}
+
+int ctcm_register_dbf_views(void)
+{
+	int x;
+	for (x = 0; x < CTCM_DBF_INFOS; x++) {
+		/* register the areas */
+		ctcm_dbf[x].id = debug_register(ctcm_dbf[x].name,
+						ctcm_dbf[x].pages,
+						ctcm_dbf[x].areas,
+						ctcm_dbf[x].len);
+		if (ctcm_dbf[x].id == NULL) {
+			ctcm_unregister_dbf_views();
+			return -ENOMEM;
+		}
+
+		/* register a view */
+		debug_register_view(ctcm_dbf[x].id, &debug_hex_ascii_view);
+		/* set a passing level */
+		debug_set_level(ctcm_dbf[x].id, ctcm_dbf[x].level);
+	}
+
+	return 0;
+}
+
Index: linux-2.6-uschi/drivers/s390/net/ctcm_dbug.h
===================================================================
--- /dev/null
+++ linux-2.6-uschi/drivers/s390/net/ctcm_dbug.h
@@ -0,0 +1,158 @@
+/*
+ *	drivers/s390/net/ctcm_dbug.h
+ *
+ *	Copyright IBM Corp. 2001, 2007
+ *	Authors:	Peter Tiedemann (ptiedem@de.ibm.com)
+ *
+ */
+
+#ifndef _CTCM_DBUG_H_
+#define _CTCM_DBUG_H_
+
+/*
+ * Debug Facility stuff
+ */
+
+#include <asm/debug.h>
+
+#ifdef DEBUG
+ #define do_debug 1
+#else
+ #define do_debug 0
+#endif
+#ifdef DEBUGDATA
+ #define do_debug_data 1
+#else
+ #define do_debug_data 0
+#endif
+#ifdef DEBUGCCW
+ #define do_debug_ccw 1
+#else
+ #define do_debug_ccw 0
+#endif
+
+/* define dbf debug levels similar to kernel msg levels */
+#define	CTC_DBF_ALWAYS	0	/* always print this 			*/
+#define	CTC_DBF_EMERG	0	/* system is unusable			*/
+#define	CTC_DBF_ALERT	1	/* action must be taken immediately	*/
+#define	CTC_DBF_CRIT	2	/* critical conditions			*/
+#define	CTC_DBF_ERROR	3	/* error conditions			*/
+#define	CTC_DBF_WARN	4	/* warning conditions			*/
+#define	CTC_DBF_NOTICE	5	/* normal but significant condition	*/
+#define	CTC_DBF_INFO	5	/* informational			*/
+#define	CTC_DBF_DEBUG	6	/* debug-level messages			*/
+
+DECLARE_PER_CPU(char[256], ctcm_dbf_txt_buf);
+
+enum ctcm_dbf_names {
+	CTCM_DBF_SETUP,
+	CTCM_DBF_ERROR,
+	CTCM_DBF_TRACE,
+	CTCM_DBF_MPC_SETUP,
+	CTCM_DBF_MPC_ERROR,
+	CTCM_DBF_MPC_TRACE,
+	CTCM_DBF_INFOS	/* must be last element */
+};
+
+struct ctcm_dbf_info {
+	char name[DEBUG_MAX_NAME_LEN];
+	int pages;
+	int areas;
+	int len;
+	int level;
+	debug_info_t *id;
+};
+
+extern struct ctcm_dbf_info ctcm_dbf[CTCM_DBF_INFOS];
+
+int ctcm_register_dbf_views(void);
+void ctcm_unregister_dbf_views(void);
+
+static inline const char *strtail(const char *s, int n)
+{
+	int l = strlen(s);
+	return (l > n) ? s + (l - n) : s;
+}
+
+/* sort out levels early to avoid unnecessary sprintfs */
+static inline int ctcm_dbf_passes(debug_info_t *dbf_grp, int level)
+{
+	return (dbf_grp->level >= level);
+}
+
+#define CTCM_FUNTAIL strtail((char *)__func__, 16)
+
+#define CTCM_DBF_TEXT(name, level, text) \
+	do { \
+		debug_text_event(ctcm_dbf[CTCM_DBF_##name].id, level, text); \
+	} while (0)
+
+#define CTCM_DBF_HEX(name, level, addr, len) \
+	do { \
+		debug_event(ctcm_dbf[CTCM_DBF_##name].id, \
+					level, (void *)(addr), len); \
+	} while (0)
+
+#define CTCM_DBF_TEXT_(name, level, text...) \
+	do { \
+		if (ctcm_dbf_passes(ctcm_dbf[CTCM_DBF_##name].id, level)) { \
+			char *ctcm_dbf_txt_buf = \
+					 get_cpu_var(ctcm_dbf_txt_buf); \
+			sprintf(ctcm_dbf_txt_buf, text); \
+			debug_text_event(ctcm_dbf[CTCM_DBF_##name].id, \
+					level, ctcm_dbf_txt_buf); \
+			put_cpu_var(ctcm_dbf_txt_buf); \
+		} \
+	} while (0)
+
+/*
+ * cat : one of {setup, mpc_setup, trace, mpc_trace, error, mpc_error}.
+ * dev : netdevice with valid name field.
+ * text: any text string.
+ */
+#define CTCM_DBF_DEV_NAME(cat, dev, text) \
+	do { \
+		CTCM_DBF_TEXT_(cat, CTC_DBF_INFO, "%s(%s) : %s", \
+			CTCM_FUNTAIL, dev->name, text); \
+	} while (0)
+
+#define MPC_DBF_DEV_NAME(cat, dev, text) \
+	do { \
+		CTCM_DBF_TEXT_(MPC_##cat, CTC_DBF_INFO, "%s(%s) : %s", \
+			CTCM_FUNTAIL, dev->name, text); \
+	} while (0)
+
+#define CTCMY_DBF_DEV_NAME(cat, dev, text) \
+	do { \
+		if (IS_MPCDEV(dev)) \
+			MPC_DBF_DEV_NAME(cat, dev, text); \
+		else \
+			CTCM_DBF_DEV_NAME(cat, dev, text); \
+	} while (0)
+
+/*
+ * cat : one of {setup, mpc_setup, trace, mpc_trace, error, mpc_error}.
+ * dev : netdevice.
+ * text: any text string.
+ */
+#define CTCM_DBF_DEV(cat, dev, text) \
+	do { \
+		CTCM_DBF_TEXT_(cat, CTC_DBF_INFO, "%s(%p) : %s", \
+			CTCM_FUNTAIL, dev, text); \
+	} while (0)
+
+#define MPC_DBF_DEV(cat, dev, text) \
+	do { \
+		CTCM_DBF_TEXT_(MPC_##cat, CTC_DBF_INFO, "%s(%p) : %s", \
+			CTCM_FUNTAIL, dev, text); \
+	} while (0)
+
+#define CTCMY_DBF_DEV(cat, dev, text) \
+	do { \
+		if (IS_MPCDEV(dev)) \
+			MPC_DBF_DEV(cat, dev, text); \
+		else \
+			CTCM_DBF_DEV(cat, dev, text); \
+	} while (0)
+
+#endif
Index: linux-2.6-uschi/drivers/s390/net/ctcm_fsms.h
===================================================================
--- /dev/null
+++ linux-2.6-uschi/drivers/s390/net/ctcm_fsms.h
@@ -0,0 +1,359 @@
+/*
+ * drivers/s390/net/ctcm_fsms.h
+ *
+ * Copyright IBM Corp. 2001, 2007
+ * Authors: 	Fritz Elfert (felfert@millenux.com)
+ * 		Peter Tiedemann (ptiedem@de.ibm.com)
+ * 	MPC additions :
+ *		Belinda Thompson (belindat@us.ibm.com)
+ *		Andy Richter (richtera@us.ibm.com)
+ */
+#ifndef _CTCM_FSMS_H_
+#define _CTCM_FSMS_H_
+
+#include <linux/module.h>
+#include <linux/init.h>
+#include <linux/kernel.h>
+#include <linux/slab.h>
+#include <linux/errno.h>
+#include <linux/types.h>
+#include <linux/interrupt.h>
+#include <linux/timer.h>
+#include <linux/bitops.h>
+
+#include <linux/signal.h>
+#include <linux/string.h>
+
+#include <linux/ip.h>
+#include <linux/if_arp.h>
+#include <linux/tcp.h>
+#include <linux/skbuff.h>
+#include <linux/ctype.h>
+#include <net/dst.h>
+
+#include <linux/io.h>
+#include <asm/ccwdev.h>
+#include <asm/ccwgroup.h>
+#include <linux/uaccess.h>
+
+#include <asm/idals.h>
+
+#include "fsm.h"
+#include "cu3088.h"
+#include "ctcm_main.h"
+
+/*
+ * Definitions for the channel statemachine(s) for ctc and ctcmpc
+ *
+ * To allow better kerntyping, prefix-less definitions for channel states
+ * and channel events have been replaced :
+ * ch_event... -> ctc_ch_event...
+ * CH_EVENT... -> CTC_EVENT...
+ * ch_state... -> ctc_ch_state...
+ * CH_STATE... -> CTC_STATE...
+ */
+/*
+ * Events of the channel statemachine(s) for ctc and ctcmpc
+ */
+enum ctc_ch_events {
+	/*
+	 * Events, representing return code of
+	 * I/O operations (ccw_device_start, ccw_device_halt et al.)
+	 */
+	CTC_EVENT_IO_SUCCESS,
+	CTC_EVENT_IO_EBUSY,
+	CTC_EVENT_IO_ENODEV,
+	CTC_EVENT_IO_UNKNOWN,
+
+	CTC_EVENT_ATTNBUSY,
+	CTC_EVENT_ATTN,
+	CTC_EVENT_BUSY,
+	/*
+	 * Events, representing unit-check
+	 */
+	CTC_EVENT_UC_RCRESET,
+	CTC_EVENT_UC_RSRESET,
+	CTC_EVENT_UC_TXTIMEOUT,
+	CTC_EVENT_UC_TXPARITY,
+	CTC_EVENT_UC_HWFAIL,
+	CTC_EVENT_UC_RXPARITY,
+	CTC_EVENT_UC_ZERO,
+	CTC_EVENT_UC_UNKNOWN,
+	/*
+	 * Events, representing subchannel-check
+	 */
+	CTC_EVENT_SC_UNKNOWN,
+	/*
+	 * Events, representing machine checks
+	 */
+	CTC_EVENT_MC_FAIL,
+	CTC_EVENT_MC_GOOD,
+	/*
+	 * Event, representing normal IRQ
+	 */
+	CTC_EVENT_IRQ,
+	CTC_EVENT_FINSTAT,
+	/*
+	 * Event, representing timer expiry.
+	 */
+	CTC_EVENT_TIMER,
+	/*
+	 * Events, representing commands from upper levels.
+	 */
+	CTC_EVENT_START,
+	CTC_EVENT_STOP,
+	CTC_NR_EVENTS,
+	/*
+	 * additional MPC events
+	 */
+	CTC_EVENT_SEND_XID = CTC_NR_EVENTS,
+	CTC_EVENT_RSWEEP_TIMER,
+	/*
+	 * MUST be always the last element!!
+	 */
+	CTC_MPC_NR_EVENTS,
+};
+
+/*
+ * States of the channel statemachine(s) for ctc and ctcmpc.
+ */
+enum ctc_ch_states {
+	/*
+	 * Channel not assigned to any device,
+	 * initial state, direction invalid
+	 */
+	CTC_STATE_IDLE,
+	/*
+	 * Channel assigned but not operating
+	 */
+	CTC_STATE_STOPPED,
+	CTC_STATE_STARTWAIT,
+	CTC_STATE_STARTRETRY,
+	CTC_STATE_SETUPWAIT,
+	CTC_STATE_RXINIT,
+	CTC_STATE_TXINIT,
+	CTC_STATE_RX,
+	CTC_STATE_TX,
+	CTC_STATE_RXIDLE,
+	CTC_STATE_TXIDLE,
+	CTC_STATE_RXERR,
+	CTC_STATE_TXERR,
+	CTC_STATE_TERM,
+	CTC_STATE_DTERM,
+	CTC_STATE_NOTOP,
+	CTC_NR_STATES,     /* MUST be the last element of non-expanded states */
+	/*
+	 * additional MPC states
+	 */
+	CH_XID0_PENDING = CTC_NR_STATES,
+	CH_XID0_INPROGRESS,
+	CH_XID7_PENDING,
+	CH_XID7_PENDING1,
+	CH_XID7_PENDING2,
+	CH_XID7_PENDING3,
+	CH_XID7_PENDING4,
+	CTC_MPC_NR_STATES, /* MUST be the last element of expanded mpc states */
+};
+
+extern const char *ctc_ch_event_names[];
+
+extern const char *ctc_ch_state_names[];
+
+void ctcm_ccw_check_rc(struct channel *ch, int rc, char *msg);
+void ctcm_purge_skb_queue(struct sk_buff_head *q);
+void fsm_action_nop(fsm_instance *fi, int event, void *arg);
+
+/*
+ * ----- non-static actions for ctcm channel statemachine -----
+ *
+ */
+void ctcm_chx_txidle(fsm_instance *fi, int event, void *arg);
+
+/*
+ * ----- FSM (state/event/action) of the ctcm channel statemachine -----
+ */
+extern const fsm_node ch_fsm[];
+extern int ch_fsm_len;
+
+
+/*
+ * ----- non-static actions for ctcmpc channel statemachine ----
+ *
+ */
+/* shared :
+void ctcm_chx_txidle(fsm_instance * fi, int event, void *arg);
+ */
+void ctcmpc_chx_rxidle(fsm_instance *fi, int event, void *arg);
+
+/*
+ * ----- FSM (state/event/action) of the ctcmpc channel statemachine -----
+ */
+extern const fsm_node ctcmpc_ch_fsm[];
+extern int mpc_ch_fsm_len;
+
+/*
+ * Definitions for the device interface statemachine for ctc and mpc
+ */
+
+/*
+ * States of the device interface statemachine.
+ */
+enum dev_states {
+	DEV_STATE_STOPPED,
+	DEV_STATE_STARTWAIT_RXTX,
+	DEV_STATE_STARTWAIT_RX,
+	DEV_STATE_STARTWAIT_TX,
+	DEV_STATE_STOPWAIT_RXTX,
+	DEV_STATE_STOPWAIT_RX,
+	DEV_STATE_STOPWAIT_TX,
+	DEV_STATE_RUNNING,
+	/*
+	 * MUST be always the last element!!
+	 */
+	CTCM_NR_DEV_STATES
+};
+
+extern const char *dev_state_names[];
+
+/*
+ * Events of the device interface statemachine.
+ * ctcm and ctcmpc
+ */
+enum dev_events {
+	DEV_EVENT_START,
+	DEV_EVENT_STOP,
+	DEV_EVENT_RXUP,
+	DEV_EVENT_TXUP,
+	DEV_EVENT_RXDOWN,
+	DEV_EVENT_TXDOWN,
+	DEV_EVENT_RESTART,
+	/*
+	 * MUST be always the last element!!
+	 */
+	CTCM_NR_DEV_EVENTS
+};
+
+extern const char *dev_event_names[];
+
+/*
+ * Actions for the device interface statemachine.
+ * ctc and ctcmpc
+ */
+/*
+static void dev_action_start(fsm_instance * fi, int event, void *arg);
+static void dev_action_stop(fsm_instance * fi, int event, void *arg);
+static void dev_action_restart(fsm_instance *fi, int event, void *arg);
+static void dev_action_chup(fsm_instance * fi, int event, void *arg);
+static void dev_action_chdown(fsm_instance * fi, int event, void *arg);
+*/
+
+/*
+ * The (state/event/action) fsm table of the device interface statemachine.
+ * ctcm and ctcmpc
+ */
+extern const fsm_node dev_fsm[];
+extern int dev_fsm_len;
+
+
+/*
+ * Definitions for the MPC Group statemachine
+ */
+
+/*
+ * MPC Group Station FSM States
+
+State Name		When In This State
+======================	=======================================
+MPCG_STATE_RESET	Initial State When Driver Loaded
+			We receive and send NOTHING
+
+MPCG_STATE_INOP         INOP Received.
+			Group level non-recoverable error
+
+MPCG_STATE_READY	XID exchanges for at least 1 write and
+			1 read channel have completed.
+			Group is ready for data transfer.
+
+States from ctc_mpc_alloc_channel
+==============================================================
+MPCG_STATE_XID2INITW	Awaiting XID2(0) Initiation
+			      ATTN from other side will start
+			      XID negotiations.
+			      Y-side protocol only.
+
+MPCG_STATE_XID2INITX	XID2(0) negotiations are in progress.
+			      At least 1, but not all, XID2(0)'s
+			      have been received from partner.
+
+MPCG_STATE_XID7INITW	XID2(0) complete
+			      No XID2(7)'s have yet been received.
+			      XID2(7) negotiations pending.
+
+MPCG_STATE_XID7INITX	XID2(7) negotiations in progress.
+			      At least 1, but not all, XID2(7)'s
+			      have been received from partner.
+
+MPCG_STATE_XID7INITF	XID2(7) negotiations complete.
+			      Transitioning to READY.
+
+MPCG_STATE_READY	      Ready for Data Transfer.
+
+
+States from ctc_mpc_establish_connectivity call
+==============================================================
+MPCG_STATE_XID0IOWAIT	Initiating XID2(0) negotiations.
+			      X-side protocol only.
+			      ATTN-BUSY from other side will convert
+			      this to Y-side protocol and the
+			      ctc_mpc_alloc_channel flow will begin.
+
+MPCG_STATE_XID0IOWAIX	XID2(0) negotiations are in progress.
+			      At least 1, but not all, XID2(0)'s
+			      have been received from partner.
+
+MPCG_STATE_XID7INITI	XID2(0) complete
+			      No XID2(7)'s have yet been received.
+			      XID2(7) negotiations pending.
+
+MPCG_STATE_XID7INITZ	XID2(7) negotiations in progress.
+			      At least 1, but not all, XID2(7)'s
+			      have been received from partner.
+
+MPCG_STATE_XID7INITF	XID2(7) negotiations complete.
+			      Transitioning to READY.
+
+MPCG_STATE_READY	      Ready for Data Transfer.
+
+*/
+
+enum mpcg_events {
+	MPCG_EVENT_INOP,
+	MPCG_EVENT_DISCONC,
+	MPCG_EVENT_XID0DO,
+	MPCG_EVENT_XID2,
+	MPCG_EVENT_XID2DONE,
+	MPCG_EVENT_XID7DONE,
+	MPCG_EVENT_TIMER,
+	MPCG_EVENT_DOIO,
+	MPCG_NR_EVENTS,
+};
+
+enum mpcg_states {
+	MPCG_STATE_RESET,
+	MPCG_STATE_INOP,
+	MPCG_STATE_XID2INITW,
+	MPCG_STATE_XID2INITX,
+	MPCG_STATE_XID7INITW,
+	MPCG_STATE_XID7INITX,
+	MPCG_STATE_XID0IOWAIT,
+	MPCG_STATE_XID0IOWAIX,
+	MPCG_STATE_XID7INITI,
+	MPCG_STATE_XID7INITZ,
+	MPCG_STATE_XID7INITF,
+	MPCG_STATE_FLOWC,
+	MPCG_STATE_READY,
+	MPCG_NR_STATES,
+};
+
+#endif
+/* --- This is the END my friend --- */
Index: linux-2.6-uschi/drivers/s390/net/ctcm_main.c
===================================================================
--- /dev/null
+++ linux-2.6-uschi/drivers/s390/net/ctcm_main.c
@@ -0,0 +1,1772 @@
+/*
+ * drivers/s390/net/ctcm_main.c
+ *
+ * Copyright IBM Corp. 2001, 2007
+ * Author(s):
+ *	Original CTC driver(s):
+ *		Fritz Elfert (felfert@millenux.com)
+ *		Dieter Wellerdiek (wel@de.ibm.com)
+ *		Martin Schwidefsky (schwidefsky@de.ibm.com)
+ *		Denis Joseph Barrow (barrow_dj@yahoo.com)
+ *		Jochen Roehrig (roehrig@de.ibm.com)
+ *		Cornelia Huck <cornelia.huck@de.ibm.com>
+ *	MPC additions:
+ *		Belinda Thompson (belindat@us.ibm.com)
+ *		Andy Richter (richtera@us.ibm.com)
+ *	Revived by:
+ *		Peter Tiedemann (ptiedem@de.ibm.com)
+ */
+
+#undef DEBUG
+#undef DEBUGDATA
+#undef DEBUGCCW
+
+#include <linux/module.h>
+#include <linux/init.h>
+#include <linux/kernel.h>
+#include <linux/slab.h>
+#include <linux/errno.h>
+#include <linux/types.h>
+#include <linux/interrupt.h>
+#include <linux/timer.h>
+#include <linux/bitops.h>
+
+#include <linux/signal.h>
+#include <linux/string.h>
+
+#include <linux/ip.h>
+#include <linux/if_arp.h>
+#include <linux/tcp.h>
+#include <linux/skbuff.h>
+#include <linux/ctype.h>
+#include <net/dst.h>
+
+#include <linux/io.h>
+#include <asm/ccwdev.h>
+#include <asm/ccwgroup.h>
+#include <linux/uaccess.h>
+
+#include <asm/idals.h>
+
+#include "cu3088.h"
+#include "ctcm_fsms.h"
+#include "ctcm_main.h"
+
+/* Some common global variables */
+
+/*
+ * Linked list of all detected channels.
+ */
+struct channel *channels;
+
+/**
+ * Unpack a just received skb and hand it over to
+ * upper layers.
+ *
+ *  ch		The channel where this skb has been received.
+ *  pskb	The received skb.
+ */
+void ctcm_unpack_skb(struct channel *ch, struct sk_buff *pskb)
+{
+	struct net_device *dev = ch->netdev;
+	struct ctcm_priv *priv = dev->priv;
+	__u16 len = *((__u16 *) pskb->data);
+
+	skb_put(pskb, 2 + LL_HEADER_LENGTH);
+	skb_pull(pskb, 2);
+	pskb->dev = dev;
+	pskb->ip_summed = CHECKSUM_UNNECESSARY;
+	while (len > 0) {
+		struct sk_buff *skb;
+		int skblen;
+		struct ll_header *header = (struct ll_header *)pskb->data;
+
+		skb_pull(pskb, LL_HEADER_LENGTH);
+		if ((ch->protocol == CTCM_PROTO_S390) &&
+		    (header->type != ETH_P_IP)) {
+
+			if (!(ch->logflags & LOG_FLAG_ILLEGALPKT)) {
+				/*
+				 * Check packet type only if we stick strictly
+				 * to S/390's protocol of OS390. This only
+				 * supports IP. Otherwise allow any packet
+				 * type.
+				 */
+				ctcm_pr_warn("%s Illegal packet type 0x%04x "
+						"received, dropping\n",
+						dev->name, header->type);
+				ch->logflags |= LOG_FLAG_ILLEGALPKT;
+			}
+
+			priv->stats.rx_dropped++;
+			priv->stats.rx_frame_errors++;
+			return;
+		}
+		pskb->protocol = ntohs(header->type);
+		if (header->length <= LL_HEADER_LENGTH) {
+			if (!(ch->logflags & LOG_FLAG_ILLEGALSIZE)) {
+				ctcm_pr_warn(
+					"%s Illegal packet size %d "
+					"received (MTU=%d blocklen=%d), "
+					"dropping\n", dev->name, header->length,
+					dev->mtu, len);
+				ch->logflags |= LOG_FLAG_ILLEGALSIZE;
+			}
+
+			priv->stats.rx_dropped++;
+			priv->stats.rx_length_errors++;
+			return;
+		}
+		header->length -= LL_HEADER_LENGTH;
+		len -= LL_HEADER_LENGTH;
+		if ((header->length > skb_tailroom(pskb)) ||
+			(header->length > len)) {
+			if (!(ch->logflags & LOG_FLAG_OVERRUN)) {
+				ctcm_pr_warn(
+					"%s Illegal packet size %d (beyond the"
+					" end of received data), dropping\n",
+					dev->name, header->length);
+				ch->logflags |= LOG_FLAG_OVERRUN;
+			}
+
+			priv->stats.rx_dropped++;
+			priv->stats.rx_length_errors++;
+			return;
+		}
+		skb_put(pskb, header->length);
+		skb_reset_mac_header(pskb);
+		len -= header->length;
+		skb = dev_alloc_skb(pskb->len);
+		if (!skb) {
+			if (!(ch->logflags & LOG_FLAG_NOMEM)) {
+				ctcm_pr_warn(
+					"%s Out of memory in ctcm_unpack_skb\n",
+					dev->name);
+				ch->logflags |= LOG_FLAG_NOMEM;
+			}
+			priv->stats.rx_dropped++;
+			return;
+		}
+		skb_copy_from_linear_data(pskb, skb_put(skb, pskb->len),
+					  pskb->len);
+		skb_reset_mac_header(skb);
+		skb->dev = pskb->dev;
+		skb->protocol = pskb->protocol;
+		pskb->ip_summed = CHECKSUM_UNNECESSARY;
+		skblen = skb->len;
+		/*
+		 * reset logflags
+		 */
+		ch->logflags = 0;
+		priv->stats.rx_packets++;
+		priv->stats.rx_bytes += skblen;
+		netif_rx_ni(skb);
+		dev->last_rx = jiffies;
+		if (len > 0) {
+			skb_pull(pskb, header->length);
+			if (skb_tailroom(pskb) < LL_HEADER_LENGTH) {
+				if (!(ch->logflags & LOG_FLAG_OVERRUN)) {
+					CTCM_DBF_DEV_NAME(TRACE, dev,
+						"Overrun in ctcm_unpack_skb");
+					ch->logflags |= LOG_FLAG_OVERRUN;
+				}
+				return;
+			}
+			skb_put(pskb, LL_HEADER_LENGTH);
+		}
+	}
+}
+
+/**
+ * Release a specific channel in the channel list.
+ *
+ *  ch		Pointer to channel struct to be released.
+ */
+static void channel_free(struct channel *ch)
+{
+	CTCM_DBF_TEXT(TRACE, 2, __FUNCTION__);
+	ch->flags &= ~CHANNEL_FLAGS_INUSE;
+	fsm_newstate(ch->fsm, CTC_STATE_IDLE);
+}
+
+/**
+ * Remove a specific channel in the channel list.
+ *
+ *  ch		Pointer to channel struct to be released.
+ */
+static void channel_remove(struct channel *ch)
+{
+	struct channel **c = &channels;
+	char chid[CTCM_ID_SIZE+1];
+	int ok = 0;
+
+	if (ch == NULL)
+		return;
+	else
+		strncpy(chid, ch->id, CTCM_ID_SIZE);
+
+	channel_free(ch);
+	while (*c) {
+		if (*c == ch) {
+			*c = ch->next;
+			fsm_deltimer(&ch->timer);
+			if (IS_MPC(ch))
+				fsm_deltimer(&ch->sweep_timer);
+
+			kfree_fsm(ch->fsm);
+			clear_normalized_cda(&ch->ccw[4]);
+			if (ch->trans_skb != NULL) {
+				clear_normalized_cda(&ch->ccw[1]);
+				dev_kfree_skb_any(ch->trans_skb);
+			}
+			if (IS_MPC(ch)) {
+				tasklet_kill(&ch->ch_tasklet);
+				tasklet_kill(&ch->ch_disc_tasklet);
+				kfree(ch->discontact_th);
+			}
+			kfree(ch->ccw);
+			kfree(ch->irb);
+			kfree(ch);
+			ok = 1;
+			break;
+		}
+		c = &((*c)->next);
+	}
+
+	CTCM_DBF_TEXT_(SETUP, CTC_DBF_INFO, "%s(%s) %s", CTCM_FUNTAIL,
+			chid, ok ? "OK" : "failed");
+}
+
+/**
+ * Get a specific channel from the channel list.
+ *
+ *  type	Type of channel we are interested in.
+ *  id		Id of channel we are interested in.
+ *  direction	Direction we want to use this channel for.
+ *
+ * returns Pointer to a channel or NULL if no matching channel available.
+ */
+static struct channel *channel_get(enum channel_types type,
+					char *id, int direction)
+{
+	struct channel *ch = channels;
+
+	if (do_debug) {
+		char buf[64];
+		sprintf(buf, "%s(%d, %s, %d)\n",
+				CTCM_FUNTAIL, type, id, direction);
+		CTCM_DBF_TEXT(TRACE, CTC_DBF_INFO, buf);
+	}
+	while (ch && (strncmp(ch->id, id, CTCM_ID_SIZE) || (ch->type != type)))
+		ch = ch->next;
+	if (!ch) {
+		char buf[64];
+		sprintf(buf, "%s(%d, %s, %d) not found in channel list\n",
+				CTCM_FUNTAIL, type, id, direction);
+		CTCM_DBF_TEXT(ERROR, CTC_DBF_ERROR, buf);
+	} else {
+		if (ch->flags & CHANNEL_FLAGS_INUSE)
+			ch = NULL;
+		else {
+			ch->flags |= CHANNEL_FLAGS_INUSE;
+			ch->flags &= ~CHANNEL_FLAGS_RWMASK;
+			ch->flags |= (direction == WRITE)
+			    ? CHANNEL_FLAGS_WRITE : CHANNEL_FLAGS_READ;
+			fsm_newstate(ch->fsm, CTC_STATE_STOPPED);
+		}
+	}
+	return ch;
+}
+
+static long ctcm_check_irb_error(struct ccw_device *cdev, struct irb *irb)
+{
+	if (!IS_ERR(irb))
+		return 0;
+
+	CTCM_DBF_TEXT_(ERROR, CTC_DBF_WARN, "irb error %ld on device %s\n",
+			PTR_ERR(irb), cdev->dev.bus_id);
+
+	switch (PTR_ERR(irb)) {
+	case -EIO:
+		ctcm_pr_warn("i/o-error on device %s\n", cdev->dev.bus_id);
+		break;
+	case -ETIMEDOUT:
+		ctcm_pr_warn("timeout on device %s\n", cdev->dev.bus_id);
+		break;
+	default:
+		ctcm_pr_warn("unknown error %ld on device %s\n",
+				PTR_ERR(irb), cdev->dev.bus_id);
+	}
+	return PTR_ERR(irb);
+}
+
+
+/**
+ * Check sense of a unit check.
+ *
+ *  ch		The channel, the sense code belongs to.
+ *  sense	The sense code to inspect.
+ */
+static inline void ccw_unit_check(struct channel *ch, unsigned char sense)
+{
+	CTCM_DBF_TEXT(TRACE, 5, __FUNCTION__);
+	if (sense & SNS0_INTERVENTION_REQ) {
+		if (sense & 0x01) {
+			ctcm_pr_debug("%s: Interface disc. or Sel. reset "
+					"(remote)\n", ch->id);
+			fsm_event(ch->fsm, CTC_EVENT_UC_RCRESET, ch);
+		} else {
+			ctcm_pr_debug("%s: System reset (remote)\n", ch->id);
+			fsm_event(ch->fsm, CTC_EVENT_UC_RSRESET, ch);
+		}
+	} else if (sense & SNS0_EQUIPMENT_CHECK) {
+		if (sense & SNS0_BUS_OUT_CHECK) {
+			ctcm_pr_warn("%s: Hardware malfunction (remote)\n",
+				ch->id);
+			fsm_event(ch->fsm, CTC_EVENT_UC_HWFAIL, ch);
+		} else {
+			ctcm_pr_warn("%s: Read-data parity error (remote)\n",
+				ch->id);
+			fsm_event(ch->fsm, CTC_EVENT_UC_RXPARITY, ch);
+		}
+	} else if (sense & SNS0_BUS_OUT_CHECK) {
+		if (sense & 0x04) {
+			ctcm_pr_warn("%s: Data-streaming timeout)\n", ch->id);
+			fsm_event(ch->fsm, CTC_EVENT_UC_TXTIMEOUT, ch);
+		} else {
+			ctcm_pr_warn("%s: Data-transfer parity error\n",
+					ch->id);
+			fsm_event(ch->fsm, CTC_EVENT_UC_TXPARITY, ch);
+		}
+	} else if (sense & SNS0_CMD_REJECT) {
+		ctcm_pr_warn("%s: Command reject\n", ch->id);
+	} else if (sense == 0) {
+		ctcm_pr_debug("%s: Unit check ZERO\n", ch->id);
+		fsm_event(ch->fsm, CTC_EVENT_UC_ZERO, ch);
+	} else {
+		ctcm_pr_warn("%s: Unit Check with sense code: %02x\n",
+			    ch->id, sense);
+		fsm_event(ch->fsm, CTC_EVENT_UC_UNKNOWN, ch);
+	}
+}
+
+int ctcm_ch_alloc_buffer(struct channel *ch)
+{
+	CTCM_DBF_TEXT(TRACE, 5, __FUNCTION__);
+
+	clear_normalized_cda(&ch->ccw[1]);
+	ch->trans_skb = __dev_alloc_skb(ch->max_bufsize, GFP_ATOMIC | GFP_DMA);
+	if (ch->trans_skb == NULL) {
+		ctcm_pr_warn("%s: Couldn't alloc %s trans_skb\n",
+			ch->id,
+			(CHANNEL_DIRECTION(ch->flags) == READ) ? "RX" : "TX");
+		return -ENOMEM;
+	}
+
+	ch->ccw[1].count = ch->max_bufsize;
+	if (set_normalized_cda(&ch->ccw[1], ch->trans_skb->data)) {
+		dev_kfree_skb(ch->trans_skb);
+		ch->trans_skb = NULL;
+		ctcm_pr_warn("%s: set_normalized_cda for %s "
+			"trans_skb failed, dropping packets\n",
+			ch->id,
+			(CHANNEL_DIRECTION(ch->flags) == READ) ? "RX" : "TX");
+		return -ENOMEM;
+	}
+
+	ch->ccw[1].count = 0;
+	ch->trans_skb_data = ch->trans_skb->data;
+	ch->flags &= ~CHANNEL_FLAGS_BUFSIZE_CHANGED;
+	return 0;
+}
+
+/*
+ * Interface API for upper network layers
+ */
+
+/**
+ * Open an interface.
+ * Called from generic network layer when ifconfig up is run.
+ *
+ *  dev		Pointer to interface struct.
+ *
+ * returns 0 on success, -ERRNO on failure. (Never fails.)
+ */
+int ctcm_open(struct net_device *dev)
+{
+	struct ctcm_priv *priv = dev->priv;
+
+	CTCMY_DBF_DEV_NAME(SETUP, dev, "");
+	if (!IS_MPC(priv))
+		fsm_event(priv->fsm,	DEV_EVENT_START, dev);
+	return 0;
+}
+
+/**
+ * Close an interface.
+ * Called from generic network layer when ifconfig down is run.
+ *
+ *  dev		Pointer to interface struct.
+ *
+ * returns 0 on success, -ERRNO on failure. (Never fails.)
+ */
+int ctcm_close(struct net_device *dev)
+{
+	struct ctcm_priv *priv = dev->priv;
+
+	CTCMY_DBF_DEV_NAME(SETUP, dev, "");
+	if (!IS_MPC(priv))
+		fsm_event(priv->fsm, DEV_EVENT_STOP, dev);
+	return 0;
+}
+
+
+/**
+ * Transmit a packet.
+ * This is a helper function for ctcm_tx().
+ *
+ *  ch		Channel to be used for sending.
+ *  skb		Pointer to struct sk_buff of packet to send.
+ *            The linklevel header has already been set up
+ *            by ctcm_tx().
+ *
+ * returns 0 on success, -ERRNO on failure. (Never fails.)
+ */
+static int ctcm_transmit_skb(struct channel *ch, struct sk_buff *skb)
+{
+	unsigned long saveflags;
+	struct ll_header header;
+	int rc = 0;
+	__u16 block_len;
+	int ccw_idx;
+	struct sk_buff *nskb;
+	unsigned long hi;
+
+	/* we need to acquire the lock for testing the state
+	 * otherwise we can have an IRQ changing the state to
+	 * TXIDLE after the test but before acquiring the lock.
+	 */
+	spin_lock_irqsave(&ch->collect_lock, saveflags);
+	if (fsm_getstate(ch->fsm) != CTC_STATE_TXIDLE) {
+		int l = skb->len + LL_HEADER_LENGTH;
+
+		if (ch->collect_len + l > ch->max_bufsize - 2) {
+			spin_unlock_irqrestore(&ch->collect_lock, saveflags);
+			return -EBUSY;
+		} else {
+			atomic_inc(&skb->users);
+			header.length = l;
+			header.type = skb->protocol;
+			header.unused = 0;
+			memcpy(skb_push(skb, LL_HEADER_LENGTH), &header,
+			       LL_HEADER_LENGTH);
+			skb_queue_tail(&ch->collect_queue, skb);
+			ch->collect_len += l;
+		}
+		spin_unlock_irqrestore(&ch->collect_lock, saveflags);
+				goto done;
+	}
+	spin_unlock_irqrestore(&ch->collect_lock, saveflags);
+	/*
+	 * Protect skb against beeing free'd by upper
+	 * layers.
+	 */
+	atomic_inc(&skb->users);
+	ch->prof.txlen += skb->len;
+	header.length = skb->len + LL_HEADER_LENGTH;
+	header.type = skb->protocol;
+	header.unused = 0;
+	memcpy(skb_push(skb, LL_HEADER_LENGTH), &header, LL_HEADER_LENGTH);
+	block_len = skb->len + 2;
+	*((__u16 *)skb_push(skb, 2)) = block_len;
+
+	/*
+	 * IDAL support in CTCM is broken, so we have to
+	 * care about skb's above 2G ourselves.
+	 */
+	hi = ((unsigned long)skb_tail_pointer(skb) + LL_HEADER_LENGTH) >> 31;
+	if (hi) {
+		nskb = alloc_skb(skb->len, GFP_ATOMIC | GFP_DMA);
+		if (!nskb) {
+			atomic_dec(&skb->users);
+			skb_pull(skb, LL_HEADER_LENGTH + 2);
+			ctcm_clear_busy(ch->netdev);
+			return -ENOMEM;
+		} else {
+			memcpy(skb_put(nskb, skb->len), skb->data, skb->len);
+			atomic_inc(&nskb->users);
+			atomic_dec(&skb->users);
+			dev_kfree_skb_irq(skb);
+			skb = nskb;
+		}
+	}
+
+	ch->ccw[4].count = block_len;
+	if (set_normalized_cda(&ch->ccw[4], skb->data)) {
+		/*
+		 * idal allocation failed, try via copying to
+		 * trans_skb. trans_skb usually has a pre-allocated
+		 * idal.
+		 */
+		if (ctcm_checkalloc_buffer(ch)) {
+			/*
+			 * Remove our header. It gets added
+			 * again on retransmit.
+			 */
+			atomic_dec(&skb->users);
+			skb_pull(skb, LL_HEADER_LENGTH + 2);
+			ctcm_clear_busy(ch->netdev);
+			return -EBUSY;
+		}
+
+		skb_reset_tail_pointer(ch->trans_skb);
+		ch->trans_skb->len = 0;
+		ch->ccw[1].count = skb->len;
+		skb_copy_from_linear_data(skb,
+				skb_put(ch->trans_skb, skb->len), skb->len);
+		atomic_dec(&skb->users);
+		dev_kfree_skb_irq(skb);
+		ccw_idx = 0;
+	} else {
+		skb_queue_tail(&ch->io_queue, skb);
+		ccw_idx = 3;
+	}
+	ch->retry = 0;
+	fsm_newstate(ch->fsm, CTC_STATE_TX);
+	fsm_addtimer(&ch->timer, CTCM_TIME_5_SEC, CTC_EVENT_TIMER, ch);
+	spin_lock_irqsave(get_ccwdev_lock(ch->cdev), saveflags);
+	ch->prof.send_stamp = current_kernel_time(); /* xtime */
+	rc = ccw_device_start(ch->cdev, &ch->ccw[ccw_idx],
+					(unsigned long)ch, 0xff, 0);
+	spin_unlock_irqrestore(get_ccwdev_lock(ch->cdev), saveflags);
+	if (ccw_idx == 3)
+		ch->prof.doios_single++;
+	if (rc != 0) {
+		fsm_deltimer(&ch->timer);
+		ctcm_ccw_check_rc(ch, rc, "single skb TX");
+		if (ccw_idx == 3)
+			skb_dequeue_tail(&ch->io_queue);
+		/*
+		 * Remove our header. It gets added
+		 * again on retransmit.
+		 */
+		skb_pull(skb, LL_HEADER_LENGTH + 2);
+	} else if (ccw_idx == 0) {
+		struct net_device *dev = ch->netdev;
+		struct ctcm_priv *priv = dev->priv;
+		priv->stats.tx_packets++;
+		priv->stats.tx_bytes += skb->len - LL_HEADER_LENGTH;
+	}
+done:
+	ctcm_clear_busy(ch->netdev);
+	return rc;
+}
+
+static void ctcmpc_send_sweep_req(struct channel *rch)
+{
+	struct net_device *dev = rch->netdev;
+	struct ctcm_priv *priv;
+	struct mpc_group *grp;
+	struct th_sweep *header;
+	struct sk_buff *sweep_skb;
+	struct channel *ch;
+	int rc = 0;
+
+	priv = dev->priv;
+	grp = priv->mpcg;
+	ch = priv->channel[WRITE];
+
+	if (do_debug)
+		MPC_DBF_DEV_NAME(TRACE, dev, ch->id);
+
+	/* sweep processing is not complete until response and request */
+	/* has completed for all read channels in group		       */
+	if (grp->in_sweep == 0) {
+		grp->in_sweep = 1;
+		grp->sweep_rsp_pend_num = grp->active_channels[READ];
+		grp->sweep_req_pend_num = grp->active_channels[READ];
+	}
+
+	sweep_skb = __dev_alloc_skb(MPC_BUFSIZE_DEFAULT, GFP_ATOMIC|GFP_DMA);
+
+	if (sweep_skb == NULL)	{
+		printk(KERN_INFO "Couldn't alloc sweep_skb\n");
+		rc = -ENOMEM;
+					goto done;
+	}
+
+	header = kmalloc(TH_SWEEP_LENGTH, gfp_type());
+
+	if (!header) {
+		dev_kfree_skb_any(sweep_skb);
+		rc = -ENOMEM;
+					goto done;
+	}
+
+	header->th.th_seg	= 0x00 ;
+	header->th.th_ch_flag	= TH_SWEEP_REQ;  /* 0x0f */
+	header->th.th_blk_flag	= 0x00;
+	header->th.th_is_xid	= 0x00;
+	header->th.th_seq_num	= 0x00;
+	header->sw.th_last_seq	= ch->th_seq_num;
+
+	memcpy(skb_put(sweep_skb, TH_SWEEP_LENGTH), header, TH_SWEEP_LENGTH);
+
+	kfree(header);
+
+	dev->trans_start = jiffies;
+	skb_queue_tail(&ch->sweep_queue, sweep_skb);
+
+	fsm_addtimer(&ch->sweep_timer, 100, CTC_EVENT_RSWEEP_TIMER, ch);
+
+	return;
+
+done:
+	if (rc != 0) {
+		grp->in_sweep = 0;
+		ctcm_clear_busy(dev);
+		fsm_event(grp->fsm, MPCG_EVENT_INOP, dev);
+	}
+
+	return;
+}
+
+/*
+ * MPC mode version of transmit_skb
+ */
+static int ctcmpc_transmit_skb(struct channel *ch, struct sk_buff *skb)
+{
+	struct pdu *p_header;
+	struct net_device *dev = ch->netdev;
+	struct ctcm_priv *priv = dev->priv;
+	struct mpc_group *grp = priv->mpcg;
+	struct th_header *header;
+	struct sk_buff *nskb;
+	int rc = 0;
+	int ccw_idx;
+	unsigned long hi;
+	unsigned long saveflags = 0;	/* avoids compiler warning */
+	__u16 block_len;
+
+	if (do_debug)
+		ctcm_pr_debug(
+			"ctcm enter: %s(): %s cp=%i ch=0x%p id=%s state=%s\n",
+			__FUNCTION__, dev->name, smp_processor_id(), ch,
+			ch->id, fsm_getstate_str(ch->fsm));
+
+	if ((fsm_getstate(ch->fsm) != CTC_STATE_TXIDLE) || grp->in_sweep) {
+		spin_lock_irqsave(&ch->collect_lock, saveflags);
+		atomic_inc(&skb->users);
+		p_header = kmalloc(PDU_HEADER_LENGTH, gfp_type());
+
+		if (!p_header) {
+			printk(KERN_WARNING "ctcm: OUT OF MEMORY IN %s():"
+			       " Data Lost \n", __FUNCTION__);
+
+			atomic_dec(&skb->users);
+			dev_kfree_skb_any(skb);
+			spin_unlock_irqrestore(&ch->collect_lock, saveflags);
+			fsm_event(priv->mpcg->fsm, MPCG_EVENT_INOP, dev);
+					goto done;
+		}
+
+		p_header->pdu_offset = skb->len;
+		p_header->pdu_proto = 0x01;
+		p_header->pdu_flag = 0x00;
+		if (skb->protocol == ntohs(ETH_P_SNAP)) {
+			p_header->pdu_flag |= PDU_FIRST | PDU_CNTL;
+		} else {
+			p_header->pdu_flag |= PDU_FIRST;
+		}
+		p_header->pdu_seq = 0;
+		memcpy(skb_push(skb, PDU_HEADER_LENGTH), p_header,
+		       PDU_HEADER_LENGTH);
+
+		if (do_debug_data) {
+			ctcm_pr_debug("ctcm: %s() Putting on collect_q"
+			       " - skb len: %04x \n", __FUNCTION__, skb->len);
+			ctcm_pr_debug("ctcm: %s() pdu header and data"
+			       " for up to 32 bytes\n", __FUNCTION__);
+			ctcmpc_dump32((char *)skb->data, skb->len);
+		}
+
+		skb_queue_tail(&ch->collect_queue, skb);
+		ch->collect_len += skb->len;
+		kfree(p_header);
+
+		spin_unlock_irqrestore(&ch->collect_lock, saveflags);
+			goto done;
+	}
+
+	/*
+	 * Protect skb against beeing free'd by upper
+	 * layers.
+	 */
+	atomic_inc(&skb->users);
+
+	block_len = skb->len + TH_HEADER_LENGTH + PDU_HEADER_LENGTH;
+	/*
+	 * IDAL support in CTCM is broken, so we have to
+	 * care about skb's above 2G ourselves.
+	 */
+	hi = ((unsigned long)skb->tail + TH_HEADER_LENGTH) >> 31;
+	if (hi) {
+		nskb = __dev_alloc_skb(skb->len, GFP_ATOMIC | GFP_DMA);
+		if (!nskb) {
+			printk(KERN_WARNING "ctcm: %s() OUT OF MEMORY"
+				"-  Data Lost \n", __FUNCTION__);
+			atomic_dec(&skb->users);
+			dev_kfree_skb_any(skb);
+			fsm_event(priv->mpcg->fsm, MPCG_EVENT_INOP, dev);
+				goto done;
+		} else {
+			memcpy(skb_put(nskb, skb->len), skb->data, skb->len);
+			atomic_inc(&nskb->users);
+			atomic_dec(&skb->users);
+			dev_kfree_skb_irq(skb);
+			skb = nskb;
+		}
+	}
+
+	p_header = kmalloc(PDU_HEADER_LENGTH, gfp_type());
+
+	if (!p_header) {
+		printk(KERN_WARNING "ctcm: %s() OUT OF MEMORY"
+		       ": Data Lost \n", __FUNCTION__);
+
+		atomic_dec(&skb->users);
+		dev_kfree_skb_any(skb);
+		fsm_event(priv->mpcg->fsm, MPCG_EVENT_INOP, dev);
+				goto done;
+	}
+
+	p_header->pdu_offset = skb->len;
+	p_header->pdu_proto = 0x01;
+	p_header->pdu_flag = 0x00;
+	p_header->pdu_seq = 0;
+	if (skb->protocol == ntohs(ETH_P_SNAP)) {
+		p_header->pdu_flag |= PDU_FIRST | PDU_CNTL;
+	} else {
+		p_header->pdu_flag |= PDU_FIRST;
+	}
+	memcpy(skb_push(skb, PDU_HEADER_LENGTH), p_header, PDU_HEADER_LENGTH);
+
+	kfree(p_header);
+
+	if (ch->collect_len > 0) {
+		spin_lock_irqsave(&ch->collect_lock, saveflags);
+		skb_queue_tail(&ch->collect_queue, skb);
+		ch->collect_len += skb->len;
+		skb = skb_dequeue(&ch->collect_queue);
+		ch->collect_len -= skb->len;
+		spin_unlock_irqrestore(&ch->collect_lock, saveflags);
+	}
+
+	p_header = (struct pdu *)skb->data;
+	p_header->pdu_flag |= PDU_LAST;
+
+	ch->prof.txlen += skb->len - PDU_HEADER_LENGTH;
+
+	header = kmalloc(TH_HEADER_LENGTH, gfp_type());
+
+	if (!header) {
+		printk(KERN_WARNING "ctcm: %s() OUT OF MEMORY: Data Lost \n",
+				__FUNCTION__);
+		atomic_dec(&skb->users);
+		dev_kfree_skb_any(skb);
+		fsm_event(priv->mpcg->fsm, MPCG_EVENT_INOP, dev);
+				goto done;
+	}
+
+	header->th_seg = 0x00;
+	header->th_ch_flag = TH_HAS_PDU;  /* Normal data */
+	header->th_blk_flag = 0x00;
+	header->th_is_xid = 0x00;          /* Just data here */
+	ch->th_seq_num++;
+	header->th_seq_num = ch->th_seq_num;
+
+	if (do_debug_data)
+		ctcm_pr_debug("ctcm: %s() ToVTAM_th_seq= %08x\n" ,
+		       __FUNCTION__, ch->th_seq_num);
+
+	/* put the TH on the packet */
+	memcpy(skb_push(skb, TH_HEADER_LENGTH), header, TH_HEADER_LENGTH);
+
+	kfree(header);
+
+	if (do_debug_data) {
+		ctcm_pr_debug("ctcm: %s(): skb len: %04x \n",
+				__FUNCTION__, skb->len);
+		ctcm_pr_debug("ctcm: %s(): pdu header and data for up to 32 "
+				"bytes sent to vtam\n", __FUNCTION__);
+		ctcmpc_dump32((char *)skb->data, skb->len);
+	}
+
+	ch->ccw[4].count = skb->len;
+	if (set_normalized_cda(&ch->ccw[4], skb->data)) {
+		/*
+		 * idal allocation failed, try via copying to
+		 * trans_skb. trans_skb usually has a pre-allocated
+		 * idal.
+		 */
+		if (ctcm_checkalloc_buffer(ch)) {
+			/*
+			 * Remove our header. It gets added
+			 * again on retransmit.
+			 */
+			atomic_dec(&skb->users);
+			dev_kfree_skb_any(skb);
+			printk(KERN_WARNING "ctcm: %s()OUT OF MEMORY:"
+					" Data Lost \n", __FUNCTION__);
+			fsm_event(priv->mpcg->fsm, MPCG_EVENT_INOP, dev);
+				goto done;
+		}
+
+		skb_reset_tail_pointer(ch->trans_skb);
+		ch->trans_skb->len = 0;
+		ch->ccw[1].count = skb->len;
+		memcpy(skb_put(ch->trans_skb, skb->len), skb->data, skb->len);
+		atomic_dec(&skb->users);
+		dev_kfree_skb_irq(skb);
+		ccw_idx = 0;
+		if (do_debug_data) {
+			ctcm_pr_debug("ctcm: %s() TRANS skb len: %d \n",
+			       __FUNCTION__, ch->trans_skb->len);
+			ctcm_pr_debug("ctcm: %s up to 32 bytes of data"
+				" sent to vtam\n", __FUNCTION__);
+			ctcmpc_dump32((char *)ch->trans_skb->data,
+					ch->trans_skb->len);
+		}
+	} else {
+		skb_queue_tail(&ch->io_queue, skb);
+		ccw_idx = 3;
+	}
+	ch->retry = 0;
+	fsm_newstate(ch->fsm, CTC_STATE_TX);
+	fsm_addtimer(&ch->timer, CTCM_TIME_5_SEC, CTC_EVENT_TIMER, ch);
+
+	if (do_debug_ccw)
+		ctcmpc_dumpit((char *)&ch->ccw[ccw_idx],
+					sizeof(struct ccw1) * 3);
+
+	spin_lock_irqsave(get_ccwdev_lock(ch->cdev), saveflags);
+	ch->prof.send_stamp = current_kernel_time(); /* xtime */
+	rc = ccw_device_start(ch->cdev, &ch->ccw[ccw_idx],
+					(unsigned long)ch, 0xff, 0);
+	spin_unlock_irqrestore(get_ccwdev_lock(ch->cdev), saveflags);
+	if (ccw_idx == 3)
+		ch->prof.doios_single++;
+	if (rc != 0) {
+		fsm_deltimer(&ch->timer);
+		ctcm_ccw_check_rc(ch, rc, "single skb TX");
+		if (ccw_idx == 3)
+			skb_dequeue_tail(&ch->io_queue);
+	} else if (ccw_idx == 0) {
+		priv->stats.tx_packets++;
+		priv->stats.tx_bytes += skb->len - TH_HEADER_LENGTH;
+	}
+	if (ch->th_seq_num > 0xf0000000)	/* Chose 4Billion at random. */
+		ctcmpc_send_sweep_req(ch);
+
+done:
+	if (do_debug)
+		ctcm_pr_debug("ctcm exit: %s  %s()\n", dev->name, __FUNCTION__);
+	return 0;
+}
+
+/**
+ * Start transmission of a packet.
+ * Called from generic network device layer.
+ *
+ *  skb		Pointer to buffer containing the packet.
+ *  dev		Pointer to interface struct.
+ *
+ * returns 0 if packet consumed, !0 if packet rejected.
+ *         Note: If we return !0, then the packet is free'd by
+ *               the generic network layer.
+ */
+/* first merge version - leaving both functions separated */
+static int ctcm_tx(struct sk_buff *skb, struct net_device *dev)
+{
+	int rc = 0;
+	struct ctcm_priv *priv;
+
+	CTCM_DBF_TEXT(TRACE, 5, __FUNCTION__);
+	priv = dev->priv;
+
+	if (skb == NULL) {
+		ctcm_pr_warn("%s: NULL sk_buff passed\n", dev->name);
+		priv->stats.tx_dropped++;
+		return 0;
+	}
+	if (skb_headroom(skb) < (LL_HEADER_LENGTH + 2)) {
+		ctcm_pr_warn("%s: Got sk_buff with head room < %ld bytes\n",
+			    dev->name, LL_HEADER_LENGTH + 2);
+		dev_kfree_skb(skb);
+		priv->stats.tx_dropped++;
+		return 0;
+	}
+
+	/*
+	 * If channels are not running, try to restart them
+	 * and throw away packet.
+	 */
+	if (fsm_getstate(priv->fsm) != DEV_STATE_RUNNING) {
+		fsm_event(priv->fsm, DEV_EVENT_START, dev);
+		dev_kfree_skb(skb);
+		priv->stats.tx_dropped++;
+		priv->stats.tx_errors++;
+		priv->stats.tx_carrier_errors++;
+		return 0;
+	}
+
+	if (ctcm_test_and_set_busy(dev))
+		return -EBUSY;
+
+	dev->trans_start = jiffies;
+	if (ctcm_transmit_skb(priv->channel[WRITE], skb) != 0)
+		rc = 1;
+	return rc;
+}
+
+/* unmerged MPC variant of ctcm_tx */
+static int ctcmpc_tx(struct sk_buff *skb, struct net_device *dev)
+{
+	int len = 0;
+	struct ctcm_priv *priv = NULL;
+	struct mpc_group *grp  = NULL;
+	struct sk_buff *newskb = NULL;
+
+	if (do_debug)
+		ctcm_pr_debug("ctcmpc enter: %s(): skb:%0lx\n",
+			__FUNCTION__, (unsigned long)skb);
+
+	CTCM_DBF_TEXT_(MPC_TRACE, CTC_DBF_DEBUG,
+			"ctcmpc enter: %s(): skb:%0lx\n",
+			__FUNCTION__, (unsigned long)skb);
+
+	priv = dev->priv;
+	grp  = priv->mpcg;
+	/*
+	 * Some sanity checks ...
+	 */
+	if (skb == NULL) {
+		ctcm_pr_warn("ctcmpc: %s: NULL sk_buff passed\n", dev->name);
+		priv->stats.tx_dropped++;
+					goto done;
+	}
+	if (skb_headroom(skb) < (TH_HEADER_LENGTH + PDU_HEADER_LENGTH)) {
+		CTCM_DBF_TEXT_(MPC_TRACE, CTC_DBF_WARN,
+			"%s: Got sk_buff with head room < %ld bytes\n",
+			dev->name, TH_HEADER_LENGTH + PDU_HEADER_LENGTH);
+
+		if (do_debug_data)
+			ctcmpc_dump32((char *)skb->data, skb->len);
+
+		len =  skb->len + TH_HEADER_LENGTH + PDU_HEADER_LENGTH;
+		newskb = __dev_alloc_skb(len, gfp_type() | GFP_DMA);
+
+		if (!newskb) {
+			printk(KERN_WARNING "ctcmpc: %s() OUT OF MEMORY-"
+			       "Data Lost\n",
+			       __FUNCTION__);
+
+			dev_kfree_skb_any(skb);
+			priv->stats.tx_dropped++;
+			priv->stats.tx_errors++;
+			priv->stats.tx_carrier_errors++;
+			fsm_event(grp->fsm, MPCG_EVENT_INOP, dev);
+					goto done;
+		}
+		newskb->protocol = skb->protocol;
+		skb_reserve(newskb, TH_HEADER_LENGTH + PDU_HEADER_LENGTH);
+		memcpy(skb_put(newskb, skb->len), skb->data, skb->len);
+		dev_kfree_skb_any(skb);
+		skb = newskb;
+	}
+
+	/*
+	 * If channels are not running,
+	 * notify anybody about a link failure and throw
+	 * away packet.
+	 */
+	if ((fsm_getstate(priv->fsm) != DEV_STATE_RUNNING) ||
+	   (fsm_getstate(grp->fsm) <  MPCG_STATE_XID2INITW)) {
+		dev_kfree_skb_any(skb);
+		printk(KERN_INFO "ctcmpc: %s() DATA RCVD - MPC GROUP "
+		       "NOT ACTIVE - DROPPED\n",
+		       __FUNCTION__);
+		priv->stats.tx_dropped++;
+		priv->stats.tx_errors++;
+		priv->stats.tx_carrier_errors++;
+					goto done;
+	}
+
+	if (ctcm_test_and_set_busy(dev)) {
+		printk(KERN_WARNING "%s:DEVICE ERR - UNRECOVERABLE DATA LOSS\n",
+		       __FUNCTION__);
+		dev_kfree_skb_any(skb);
+		priv->stats.tx_dropped++;
+		priv->stats.tx_errors++;
+		priv->stats.tx_carrier_errors++;
+		fsm_event(grp->fsm, MPCG_EVENT_INOP, dev);
+					goto done;
+	}
+
+	dev->trans_start = jiffies;
+	if (ctcmpc_transmit_skb(priv->channel[WRITE], skb) != 0) {
+		printk(KERN_WARNING "ctcmpc: %s() DEVICE ERROR"
+		       ": Data Lost \n",
+		       __FUNCTION__);
+		printk(KERN_WARNING "ctcmpc: %s() DEVICE ERROR"
+		       " - UNRECOVERABLE DATA LOSS\n",
+		       __FUNCTION__);
+		dev_kfree_skb_any(skb);
+		priv->stats.tx_dropped++;
+		priv->stats.tx_errors++;
+		priv->stats.tx_carrier_errors++;
+		ctcm_clear_busy(dev);
+		fsm_event(grp->fsm, MPCG_EVENT_INOP, dev);
+					goto done;
+	}
+	ctcm_clear_busy(dev);
+done:
+	if (do_debug)
+		MPC_DBF_DEV_NAME(TRACE, dev, "exit");
+
+	return 0;	/* handle freeing of skb here */
+}
+
+
+/**
+ * Sets MTU of an interface.
+ *
+ *  dev		Pointer to interface struct.
+ *  new_mtu	The new MTU to use for this interface.
+ *
+ * returns 0 on success, -EINVAL if MTU is out of valid range.
+ *         (valid range is 576 .. 65527). If VM is on the
+ *         remote side, maximum MTU is 32760, however this is
+ *         not checked here.
+ */
+static int ctcm_change_mtu(struct net_device *dev, int new_mtu)
+{
+	struct ctcm_priv *priv;
+	int max_bufsize;
+
+	CTCM_DBF_TEXT(SETUP, CTC_DBF_INFO, __FUNCTION__);
+
+	if (new_mtu < 576 || new_mtu > 65527)
+		return -EINVAL;
+
+	priv = dev->priv;
+	max_bufsize = priv->channel[READ]->max_bufsize;
+
+	if (IS_MPC(priv)) {
+		if (new_mtu > max_bufsize - TH_HEADER_LENGTH)
+			return -EINVAL;
+		dev->hard_header_len = TH_HEADER_LENGTH + PDU_HEADER_LENGTH;
+	} else {
+		if (new_mtu > max_bufsize - LL_HEADER_LENGTH - 2)
+			return -EINVAL;
+		dev->hard_header_len = LL_HEADER_LENGTH + 2;
+	}
+	dev->mtu = new_mtu;
+	return 0;
+}
+
+/**
+ * Returns interface statistics of a device.
+ *
+ *  dev		Pointer to interface struct.
+ *
+ * returns Pointer to stats struct of this interface.
+ */
+static struct net_device_stats *ctcm_stats(struct net_device *dev)
+{
+	return &((struct ctcm_priv *)dev->priv)->stats;
+}
+
+
+static void ctcm_netdev_unregister(struct net_device *dev)
+{
+	CTCM_DBF_TEXT(SETUP, CTC_DBF_INFO, __FUNCTION__);
+	if (!dev)
+		return;
+	unregister_netdev(dev);
+}
+
+static int ctcm_netdev_register(struct net_device *dev)
+{
+	CTCM_DBF_TEXT(SETUP, CTC_DBF_INFO, __FUNCTION__);
+	return register_netdev(dev);
+}
+
+static void ctcm_free_netdevice(struct net_device *dev)
+{
+	struct ctcm_priv *priv;
+	struct mpc_group *grp;
+
+	CTCM_DBF_TEXT(SETUP, CTC_DBF_INFO, __FUNCTION__);
+
+	if (!dev)
+		return;
+	priv = dev->priv;
+	if (priv) {
+		grp = priv->mpcg;
+		if (grp) {
+			if (grp->fsm)
+				kfree_fsm(grp->fsm);
+			if (grp->xid_skb)
+				dev_kfree_skb(grp->xid_skb);
+			if (grp->rcvd_xid_skb)
+				dev_kfree_skb(grp->rcvd_xid_skb);
+			tasklet_kill(&grp->mpc_tasklet2);
+			kfree(grp);
+			priv->mpcg = NULL;
+		}
+		if (priv->fsm) {
+			kfree_fsm(priv->fsm);
+			priv->fsm = NULL;
+		}
+		kfree(priv->xid);
+		priv->xid = NULL;
+	/*
+	 * Note: kfree(priv); is done in "opposite" function of
+	 * allocator function probe_device which is remove_device.
+	 */
+	}
+#ifdef MODULE
+	free_netdev(dev);
+#endif
+}
+
+struct mpc_group *ctcmpc_init_mpc_group(struct ctcm_priv *priv);
+
+void static ctcm_dev_setup(struct net_device *dev)
+{
+	dev->open = ctcm_open;
+	dev->stop = ctcm_close;
+	dev->get_stats = ctcm_stats;
+	dev->change_mtu = ctcm_change_mtu;
+	dev->type = ARPHRD_SLIP;
+	dev->tx_queue_len = 100;
+	dev->flags = IFF_POINTOPOINT | IFF_NOARP;
+}
+
+/*
+ * Initialize everything of the net device except the name and the
+ * channel structs.
+ */
+static struct net_device *ctcm_init_netdevice(struct ctcm_priv *priv)
+{
+	struct net_device *dev;
+	struct mpc_group *grp;
+	if (!priv)
+		return NULL;
+
+	if (IS_MPC(priv))
+		dev = alloc_netdev(0, MPC_DEVICE_GENE, ctcm_dev_setup);
+	else
+		dev = alloc_netdev(0, CTC_DEVICE_GENE, ctcm_dev_setup);
+
+	if (!dev) {
+		ctcm_pr_err("%s: Out of memory\n", __FUNCTION__);
+		return NULL;
+	}
+	dev->priv = priv;
+	priv->fsm = init_fsm("ctcmdev", dev_state_names, dev_event_names,
+				CTCM_NR_DEV_STATES, CTCM_NR_DEV_EVENTS,
+				dev_fsm, dev_fsm_len, GFP_KERNEL);
+	if (priv->fsm == NULL) {
+		CTCMY_DBF_DEV(SETUP, dev, "init_fsm error");
+		kfree(dev);
+		return NULL;
+	}
+	fsm_newstate(priv->fsm, DEV_STATE_STOPPED);
+	fsm_settimer(priv->fsm, &priv->restart_timer);
+
+	if (IS_MPC(priv)) {
+		/*  MPC Group Initializations  */
+		grp = ctcmpc_init_mpc_group(priv);
+		if (grp == NULL) {
+			MPC_DBF_DEV(SETUP, dev, "init_mpc_group error");
+			kfree(dev);
+			return NULL;
+		}
+		tasklet_init(&grp->mpc_tasklet2,
+				mpc_group_ready, (unsigned long)dev);
+		dev->mtu = MPC_BUFSIZE_DEFAULT -
+				TH_HEADER_LENGTH - PDU_HEADER_LENGTH;
+
+		dev->hard_start_xmit = ctcmpc_tx;
+		dev->hard_header_len = TH_HEADER_LENGTH + PDU_HEADER_LENGTH;
+		priv->buffer_size = MPC_BUFSIZE_DEFAULT;
+	} else {
+		dev->mtu = CTCM_BUFSIZE_DEFAULT - LL_HEADER_LENGTH - 2;
+		dev->hard_start_xmit = ctcm_tx;
+		dev->hard_header_len = LL_HEADER_LENGTH + 2;
+	}
+
+	CTCMY_DBF_DEV(SETUP, dev, "finished");
+	return dev;
+}
+
+/**
+ * Main IRQ handler.
+ *
+ *  cdev	The ccw_device the interrupt is for.
+ *  intparm	interruption parameter.
+ *  irb		interruption response block.
+ */
+static void ctcm_irq_handler(struct ccw_device *cdev,
+				unsigned long intparm, struct irb *irb)
+{
+	struct channel		*ch;
+	struct net_device	*dev;
+	struct ctcm_priv	*priv;
+	struct ccwgroup_device	*cgdev;
+
+	CTCM_DBF_TEXT(TRACE, CTC_DBF_DEBUG, __FUNCTION__);
+	if (ctcm_check_irb_error(cdev, irb))
+		return;
+
+	cgdev = dev_get_drvdata(&cdev->dev);
+
+	/* Check for unsolicited interrupts. */
+	if (cgdev == NULL) {
+		ctcm_pr_warn("ctcm: Got unsolicited irq: %s c-%02x d-%02x\n",
+			    cdev->dev.bus_id, irb->scsw.cstat,
+			    irb->scsw.dstat);
+		return;
+	}
+
+	priv = dev_get_drvdata(&cgdev->dev);
+
+	/* Try to extract channel from driver data. */
+	if (priv->channel[READ]->cdev == cdev)
+		ch = priv->channel[READ];
+	else if (priv->channel[WRITE]->cdev == cdev)
+		ch = priv->channel[WRITE];
+	else {
+		ctcm_pr_err("ctcm: Can't determine channel for interrupt, "
+			   "device %s\n", cdev->dev.bus_id);
+		return;
+	}
+
+	dev = (struct net_device *)(ch->netdev);
+	if (dev == NULL) {
+		ctcm_pr_crit("ctcm: %s dev=NULL bus_id=%s, ch=0x%p\n",
+				__FUNCTION__, cdev->dev.bus_id, ch);
+		return;
+	}
+
+	if (do_debug)
+		ctcm_pr_debug("%s: interrupt for device: %s "
+				"received c-%02x d-%02x\n",
+				dev->name,
+				ch->id,
+				irb->scsw.cstat,
+				irb->scsw.dstat);
+
+	/* Copy interruption response block. */
+	memcpy(ch->irb, irb, sizeof(struct irb));
+
+	/* Check for good subchannel return code, otherwise error message */
+	if (irb->scsw.cstat) {
+		fsm_event(ch->fsm, CTC_EVENT_SC_UNKNOWN, ch);
+		ctcm_pr_warn("%s: subchannel check for dev: %s - %02x %02x\n",
+			    dev->name, ch->id, irb->scsw.cstat,
+			    irb->scsw.dstat);
+		return;
+	}
+
+	/* Check the reason-code of a unit check */
+	if (irb->scsw.dstat & DEV_STAT_UNIT_CHECK) {
+		ccw_unit_check(ch, irb->ecw[0]);
+		return;
+	}
+	if (irb->scsw.dstat & DEV_STAT_BUSY) {
+		if (irb->scsw.dstat & DEV_STAT_ATTENTION)
+			fsm_event(ch->fsm, CTC_EVENT_ATTNBUSY, ch);
+		else
+			fsm_event(ch->fsm, CTC_EVENT_BUSY, ch);
+		return;
+	}
+	if (irb->scsw.dstat & DEV_STAT_ATTENTION) {
+		fsm_event(ch->fsm, CTC_EVENT_ATTN, ch);
+		return;
+	}
+	if ((irb->scsw.stctl & SCSW_STCTL_SEC_STATUS) ||
+	    (irb->scsw.stctl == SCSW_STCTL_STATUS_PEND) ||
+	    (irb->scsw.stctl ==
+	     (SCSW_STCTL_ALERT_STATUS | SCSW_STCTL_STATUS_PEND)))
+		fsm_event(ch->fsm, CTC_EVENT_FINSTAT, ch);
+	else
+		fsm_event(ch->fsm, CTC_EVENT_IRQ, ch);
+
+}
+
+/**
+ * Add ctcm specific attributes.
+ * Add ctcm private data.
+ *
+ *  cgdev	pointer to ccwgroup_device just added
+ *
+ * returns 0 on success, !0 on failure.
+ */
+static int ctcm_probe_device(struct ccwgroup_device *cgdev)
+{
+	struct ctcm_priv *priv;
+	int rc;
+
+	CTCM_DBF_TEXT_(SETUP, CTC_DBF_INFO, "%s %p", __FUNCTION__, cgdev);
+
+	if (!get_device(&cgdev->dev))
+		return -ENODEV;
+
+	priv = kzalloc(sizeof(struct ctcm_priv), GFP_KERNEL);
+	if (!priv) {
+		ctcm_pr_err("%s: Out of memory\n", __FUNCTION__);
+		put_device(&cgdev->dev);
+		return -ENOMEM;
+	}
+
+	rc = ctcm_add_files(&cgdev->dev);
+	if (rc) {
+		kfree(priv);
+		put_device(&cgdev->dev);
+		return rc;
+	}
+	priv->buffer_size = CTCM_BUFSIZE_DEFAULT;
+	cgdev->cdev[0]->handler = ctcm_irq_handler;
+	cgdev->cdev[1]->handler = ctcm_irq_handler;
+	dev_set_drvdata(&cgdev->dev, priv);
+
+	return 0;
+}
+
+/**
+ * Add a new channel to the list of channels.
+ * Keeps the channel list sorted.
+ *
+ *  cdev	The ccw_device to be added.
+ *  type	The type class of the new channel.
+ *  priv	Points to the private data of the ccwgroup_device.
+ *
+ * returns 0 on success, !0 on error.
+ */
+static int add_channel(struct ccw_device *cdev, enum channel_types type,
+				struct ctcm_priv *priv)
+{
+	struct channel **c = &channels;
+	struct channel *ch;
+	int ccw_num;
+	int rc = 0;
+
+	CTCM_DBF_TEXT(TRACE, 2, __FUNCTION__);
+	ch = kzalloc(sizeof(struct channel), GFP_KERNEL);
+	if (ch == NULL)
+					goto nomem_return;
+
+	ch->protocol = priv->protocol;
+	if (IS_MPC(priv)) {
+		ch->discontact_th = (struct th_header *)
+				kzalloc(TH_HEADER_LENGTH, gfp_type());
+		if (ch->discontact_th == NULL)
+					goto nomem_return;
+
+		ch->discontact_th->th_blk_flag = TH_DISCONTACT;
+		tasklet_init(&ch->ch_disc_tasklet,
+			mpc_action_send_discontact, (unsigned long)ch);
+
+		tasklet_init(&ch->ch_tasklet, ctcmpc_bh, (unsigned long)ch);
+		ch->max_bufsize = (MPC_BUFSIZE_DEFAULT - 35);
+		ccw_num = 17;
+	} else
+		ccw_num = 8;
+
+	ch->ccw = (struct ccw1 *)
+		kzalloc(ccw_num * sizeof(struct ccw1), GFP_KERNEL | GFP_DMA);
+	if (ch->ccw == NULL)
+					goto nomem_return;
+
+	ch->cdev = cdev;
+	snprintf(ch->id, CTCM_ID_SIZE, "ch-%s", cdev->dev.bus_id);
+	ch->type = type;
+
+	/**
+	 * "static" ccws are used in the following way:
+	 *
+	 * ccw[0..2] (Channel program for generic I/O):
+	 *           0: prepare
+	 *           1: read or write (depending on direction) with fixed
+	 *              buffer (idal allocated once when buffer is allocated)
+	 *           2: nop
+	 * ccw[3..5] (Channel program for direct write of packets)
+	 *           3: prepare
+	 *           4: write (idal allocated on every write).
+	 *           5: nop
+	 * ccw[6..7] (Channel program for initial channel setup):
+	 *           6: set extended mode
+	 *           7: nop
+	 *
+	 * ch->ccw[0..5] are initialized in ch_action_start because
+	 * the channel's direction is yet unknown here.
+	 *
+	 * ccws used for xid2 negotiations
+	 *  ch-ccw[8-14] need to be used for the XID exchange either
+	 *    X side XID2 Processing
+	 *       8:  write control
+	 *       9:  write th
+	 *	     10: write XID
+	 *	     11: read th from secondary
+	 *	     12: read XID   from secondary
+	 *	     13: read 4 byte ID
+	 *	     14: nop
+	 *    Y side XID Processing
+	 *	     8:  sense
+	 *       9:  read th
+	 *	     10: read XID
+	 *	     11: write th
+	 *	     12: write XID
+	 *	     13: write 4 byte ID
+	 *	     14: nop
+	 *
+	 *  ccws used for double noop due to VM timing issues
+	 *  which result in unrecoverable Busy on channel
+	 *       15: nop
+	 *       16: nop
+	 */
+	ch->ccw[6].cmd_code	= CCW_CMD_SET_EXTENDED;
+	ch->ccw[6].flags	= CCW_FLAG_SLI;
+
+	ch->ccw[7].cmd_code	= CCW_CMD_NOOP;
+	ch->ccw[7].flags	= CCW_FLAG_SLI;
+
+	if (IS_MPC(priv)) {
+		ch->ccw[15].cmd_code = CCW_CMD_WRITE;
+		ch->ccw[15].flags    = CCW_FLAG_SLI | CCW_FLAG_CC;
+		ch->ccw[15].count    = TH_HEADER_LENGTH;
+		ch->ccw[15].cda      = virt_to_phys(ch->discontact_th);
+
+		ch->ccw[16].cmd_code = CCW_CMD_NOOP;
+		ch->ccw[16].flags    = CCW_FLAG_SLI;
+
+		ch->fsm = init_fsm(ch->id, ctc_ch_state_names,
+				ctc_ch_event_names, CTC_MPC_NR_STATES,
+				CTC_MPC_NR_EVENTS, ctcmpc_ch_fsm,
+				mpc_ch_fsm_len, GFP_KERNEL);
+	} else {
+		ch->fsm = init_fsm(ch->id, ctc_ch_state_names,
+				ctc_ch_event_names, CTC_NR_STATES,
+				CTC_NR_EVENTS, ch_fsm,
+				ch_fsm_len, GFP_KERNEL);
+	}
+	if (ch->fsm == NULL)
+				goto free_return;
+
+	fsm_newstate(ch->fsm, CTC_STATE_IDLE);
+
+	ch->irb = kzalloc(sizeof(struct irb), GFP_KERNEL);
+	if (ch->irb == NULL)
+				goto nomem_return;
+
+	while (*c && ctcm_less_than((*c)->id, ch->id))
+		c = &(*c)->next;
+
+	if (*c && (!strncmp((*c)->id, ch->id, CTCM_ID_SIZE))) {
+		CTCM_DBF_TEXT_(SETUP, CTC_DBF_INFO,
+				"%s (%s) already in list, using old entry",
+				__FUNCTION__, (*c)->id);
+
+				goto free_return;
+	}
+
+	spin_lock_init(&ch->collect_lock);
+
+	fsm_settimer(ch->fsm, &ch->timer);
+	skb_queue_head_init(&ch->io_queue);
+	skb_queue_head_init(&ch->collect_queue);
+
+	if (IS_MPC(priv)) {
+		fsm_settimer(ch->fsm, &ch->sweep_timer);
+		skb_queue_head_init(&ch->sweep_queue);
+	}
+	ch->next = *c;
+	*c = ch;
+	return 0;
+
+nomem_return:
+	ctcm_pr_warn("ctcm: Out of memory in %s\n", __FUNCTION__);
+	rc = -ENOMEM;
+
+free_return:	/* note that all channel pointers are 0 or valid */
+	kfree(ch->ccw);		/* TODO: check that again */
+	kfree(ch->discontact_th);
+	kfree_fsm(ch->fsm);
+	kfree(ch->irb);
+	kfree(ch);
+	return rc;
+}
+
+/*
+ * Return type of a detected device.
+ */
+static enum channel_types get_channel_type(struct ccw_device_id *id)
+{
+	enum channel_types type;
+	type = (enum channel_types)id->driver_info;
+
+	if (type == channel_type_ficon)
+		type = channel_type_escon;
+
+	return type;
+}
+
+/**
+ *
+ * Setup an interface.
+ *
+ *  cgdev	Device to be setup.
+ *
+ * returns 0 on success, !0 on failure.
+ */
+static int ctcm_new_device(struct ccwgroup_device *cgdev)
+{
+	char read_id[CTCM_ID_SIZE];
+	char write_id[CTCM_ID_SIZE];
+	int direction;
+	enum channel_types type;
+	struct ctcm_priv *priv;
+	struct net_device *dev;
+	int ret;
+
+	CTCM_DBF_TEXT(SETUP, CTC_DBF_INFO, __FUNCTION__);
+
+	priv = dev_get_drvdata(&cgdev->dev);
+	if (!priv)
+		return -ENODEV;
+
+	type = get_channel_type(&cgdev->cdev[0]->id);
+
+	snprintf(read_id, CTCM_ID_SIZE, "ch-%s", cgdev->cdev[0]->dev.bus_id);
+	snprintf(write_id, CTCM_ID_SIZE, "ch-%s", cgdev->cdev[1]->dev.bus_id);
+
+	ret = add_channel(cgdev->cdev[0], type, priv);
+	if (ret)
+		return ret;
+	ret = add_channel(cgdev->cdev[1], type, priv);
+	if (ret)
+		return ret;
+
+	ret = ccw_device_set_online(cgdev->cdev[0]);
+	if (ret != 0) {
+		CTCM_DBF_TEXT(SETUP, CTC_DBF_WARN,
+				"ccw_device_set_online (cdev[0]) failed ");
+		ctcm_pr_warn("ccw_device_set_online (cdev[0]) failed "
+				"with ret = %d\n", ret);
+	}
+
+	ret = ccw_device_set_online(cgdev->cdev[1]);
+	if (ret != 0) {
+		CTCM_DBF_TEXT(SETUP, CTC_DBF_WARN,
+				"ccw_device_set_online (cdev[1]) failed ");
+		ctcm_pr_warn("ccw_device_set_online (cdev[1]) failed "
+				"with ret = %d\n", ret);
+	}
+
+	dev = ctcm_init_netdevice(priv);
+
+	if (dev == NULL) {
+		ctcm_pr_warn("ctcm_init_netdevice failed\n");
+					goto out;
+	}
+
+	for (direction = READ; direction <= WRITE; direction++) {
+		priv->channel[direction] =
+		    channel_get(type, direction == READ ? read_id : write_id,
+				direction);
+		if (priv->channel[direction] == NULL) {
+			if (direction == WRITE)
+				channel_free(priv->channel[READ]);
+			ctcm_free_netdevice(dev);
+					goto out;
+		}
+		priv->channel[direction]->netdev = dev;
+		priv->channel[direction]->protocol = priv->protocol;
+		priv->channel[direction]->max_bufsize = priv->buffer_size;
+	}
+	/* sysfs magic */
+	SET_NETDEV_DEV(dev, &cgdev->dev);
+
+	if (ctcm_netdev_register(dev) != 0) {
+		ctcm_free_netdevice(dev);
+					goto out;
+	}
+
+	if (ctcm_add_attributes(&cgdev->dev)) {
+		ctcm_netdev_unregister(dev);
+/*		dev->priv = NULL;	why that ????	*/
+		ctcm_free_netdevice(dev);
+					goto out;
+	}
+
+	strlcpy(priv->fsm->name, dev->name, sizeof(priv->fsm->name));
+
+	CTCM_DBF_TEXT_(SETUP, CTC_DBF_INFO,
+			"setup(%s) ok : r/w = %s / %s, proto : %d",
+			dev->name, priv->channel[READ]->id,
+			priv->channel[WRITE]->id, priv->protocol);
+
+	return 0;
+out:
+	ccw_device_set_offline(cgdev->cdev[1]);
+	ccw_device_set_offline(cgdev->cdev[0]);
+
+	return -ENODEV;
+}
+
+/**
+ * Shutdown an interface.
+ *
+ *  cgdev	Device to be shut down.
+ *
+ * returns 0 on success, !0 on failure.
+ */
+static int ctcm_shutdown_device(struct ccwgroup_device *cgdev)
+{
+	struct ctcm_priv *priv;
+	struct net_device *dev;
+
+	priv = dev_get_drvdata(&cgdev->dev);
+	if (!priv)
+		return -ENODEV;
+
+	if (priv->channel[READ]) {
+		dev = priv->channel[READ]->netdev;
+		CTCM_DBF_DEV(SETUP, dev, "");
+		/* Close the device */
+		ctcm_close(dev);
+		dev->flags &= ~IFF_RUNNING;
+		ctcm_remove_attributes(&cgdev->dev);
+		channel_free(priv->channel[READ]);
+	} else
+		dev = NULL;
+
+	if (priv->channel[WRITE])
+		channel_free(priv->channel[WRITE]);
+
+	if (dev) {
+		ctcm_netdev_unregister(dev);
+/*		dev->priv = NULL;	why that ???	*/
+		ctcm_free_netdevice(dev);
+	}
+
+	if (priv->fsm)
+		kfree_fsm(priv->fsm);
+
+	ccw_device_set_offline(cgdev->cdev[1]);
+	ccw_device_set_offline(cgdev->cdev[0]);
+
+	if (priv->channel[READ])
+		channel_remove(priv->channel[READ]);
+	if (priv->channel[WRITE])
+		channel_remove(priv->channel[WRITE]);
+	priv->channel[READ] = priv->channel[WRITE] = NULL;
+
+	return 0;
+
+}
+
+
+static void ctcm_remove_device(struct ccwgroup_device *cgdev)
+{
+	struct ctcm_priv *priv;
+
+	CTCM_DBF_TEXT(SETUP, CTC_DBF_ERROR, __FUNCTION__);
+
+	priv = dev_get_drvdata(&cgdev->dev);
+	if (!priv)
+		return;
+	if (cgdev->state == CCWGROUP_ONLINE)
+		ctcm_shutdown_device(cgdev);
+	ctcm_remove_files(&cgdev->dev);
+	dev_set_drvdata(&cgdev->dev, NULL);
+	kfree(priv);
+	put_device(&cgdev->dev);
+}
+
+static struct ccwgroup_driver ctcm_group_driver = {
+	.owner       = THIS_MODULE,
+	.name        = CTC_DRIVER_NAME,
+	.max_slaves  = 2,
+	.driver_id   = 0xC3E3C3D4,	/* CTCM */
+	.probe       = ctcm_probe_device,
+	.remove      = ctcm_remove_device,
+	.set_online  = ctcm_new_device,
+	.set_offline = ctcm_shutdown_device,
+};
+
+
+/*
+ * Module related routines
+ */
+
+/*
+ * Prepare to be unloaded. Free IRQ's and release all resources.
+ * This is called just before this module is unloaded. It is
+ * not called, if the usage count is !0, so we don't need to check
+ * for that.
+ */
+static void __exit ctcm_exit(void)
+{
+	unregister_cu3088_discipline(&ctcm_group_driver);
+	ctcm_unregister_dbf_views();
+	ctcm_pr_info("CTCM driver unloaded\n");
+}
+
+/*
+ * Print Banner.
+ */
+static void print_banner(void)
+{
+	printk(KERN_INFO "CTCM driver initialized\n");
+}
+
+/**
+ * Initialize module.
+ * This is called just after the module is loaded.
+ *
+ * returns 0 on success, !0 on error.
+ */
+static int __init ctcm_init(void)
+{
+	int ret;
+
+	channels = NULL;
+
+	ret = ctcm_register_dbf_views();
+	if (ret) {
+		ctcm_pr_crit("ctcm_init failed with ctcm_register_dbf_views "
+				"rc = %d\n", ret);
+		return ret;
+	}
+	ret = register_cu3088_discipline(&ctcm_group_driver);
+	if (ret) {
+		ctcm_unregister_dbf_views();
+		ctcm_pr_crit("ctcm_init failed with register_cu3088_discipline "
+				"(rc = %d)\n", ret);
+		return ret;
+	}
+	print_banner();
+	return ret;
+}
+
+module_init(ctcm_init);
+module_exit(ctcm_exit);
+
+MODULE_AUTHOR("Peter Tiedemann <ptiedem@de.ibm.com>");
+MODULE_DESCRIPTION("Network driver for S/390 CTC + CTCMPC (SNA)");
+MODULE_LICENSE("GPL");
+
Index: linux-2.6-uschi/drivers/s390/net/ctcm_main.h
===================================================================
--- /dev/null
+++ linux-2.6-uschi/drivers/s390/net/ctcm_main.h
@@ -0,0 +1,287 @@
+/*
+ *	drivers/s390/net/ctcm_main.h
+ *
+ *	Copyright IBM Corp. 2001, 2007
+ *	Authors:	Fritz Elfert (felfert@millenux.com)
+ *			Peter Tiedemann (ptiedem@de.ibm.com)
+ */
+
+#ifndef _CTCM_MAIN_H_
+#define _CTCM_MAIN_H_
+
+#include <asm/ccwdev.h>
+#include <asm/ccwgroup.h>
+
+#include <linux/skbuff.h>
+#include <linux/netdevice.h>
+
+#include "fsm.h"
+#include "cu3088.h"
+#include "ctcm_dbug.h"
+#include "ctcm_mpc.h"
+
+#define CTC_DRIVER_NAME	"ctcm"
+#define CTC_DEVICE_NAME	"ctc"
+#define CTC_DEVICE_GENE	"ctc%d"
+#define MPC_DEVICE_NAME	"mpc"
+#define MPC_DEVICE_GENE	"mpc%d"
+
+#define CHANNEL_FLAGS_READ	0
+#define CHANNEL_FLAGS_WRITE	1
+#define CHANNEL_FLAGS_INUSE	2
+#define CHANNEL_FLAGS_BUFSIZE_CHANGED	4
+#define CHANNEL_FLAGS_FAILED	8
+#define CHANNEL_FLAGS_WAITIRQ	16
+#define CHANNEL_FLAGS_RWMASK	1
+#define CHANNEL_DIRECTION(f) (f & CHANNEL_FLAGS_RWMASK)
+
+#define LOG_FLAG_ILLEGALPKT	1
+#define LOG_FLAG_ILLEGALSIZE	2
+#define LOG_FLAG_OVERRUN	4
+#define LOG_FLAG_NOMEM		8
+
+#define ctcm_pr_debug(fmt, arg...) printk(KERN_DEBUG fmt, ##arg)
+#define ctcm_pr_info(fmt, arg...) printk(KERN_INFO fmt, ##arg)
+#define ctcm_pr_notice(fmt, arg...) printk(KERN_NOTICE fmt, ##arg)
+#define ctcm_pr_warn(fmt, arg...) printk(KERN_WARNING fmt, ##arg)
+#define ctcm_pr_emerg(fmt, arg...) printk(KERN_EMERG fmt, ##arg)
+#define ctcm_pr_err(fmt, arg...) printk(KERN_ERR fmt, ##arg)
+#define ctcm_pr_crit(fmt, arg...) printk(KERN_CRIT fmt, ##arg)
+
+/*
+ * CCW commands, used in this driver.
+ */
+#define CCW_CMD_WRITE		0x01
+#define CCW_CMD_READ		0x02
+#define CCW_CMD_NOOP		0x03
+#define CCW_CMD_TIC             0x08
+#define CCW_CMD_SENSE_CMD	0x14
+#define CCW_CMD_WRITE_CTL	0x17
+#define CCW_CMD_SET_EXTENDED	0xc3
+#define CCW_CMD_PREPARE		0xe3
+
+#define CTCM_PROTO_S390		0
+#define CTCM_PROTO_LINUX	1
+#define CTCM_PROTO_LINUX_TTY	2
+#define CTCM_PROTO_OS390	3
+#define CTCM_PROTO_MPC		4
+#define CTCM_PROTO_MAX		4
+
+#define CTCM_BUFSIZE_LIMIT	65535
+#define CTCM_BUFSIZE_DEFAULT	32768
+#define MPC_BUFSIZE_DEFAULT	CTCM_BUFSIZE_LIMIT
+
+#define CTCM_TIME_1_SEC		1000
+#define CTCM_TIME_5_SEC		5000
+#define CTCM_TIME_10_SEC	10000
+
+#define CTCM_INITIAL_BLOCKLEN	2
+
+#define READ			0
+#define WRITE			1
+
+#define CTCM_ID_SIZE		BUS_ID_SIZE+3
+
+struct ctcm_profile {
+	unsigned long maxmulti;
+	unsigned long maxcqueue;
+	unsigned long doios_single;
+	unsigned long doios_multi;
+	unsigned long txlen;
+	unsigned long tx_time;
+	struct timespec send_stamp;
+};
+
+/*
+ * Definition of one channel
+ */
+struct channel {
+	struct channel *next;
+	char id[CTCM_ID_SIZE];
+	struct ccw_device *cdev;
+	/*
+	 * Type of this channel.
+	 * CTC/A or Escon for valid channels.
+	 */
+	enum channel_types type;
+	/*
+	 * Misc. flags. See CHANNEL_FLAGS_... below
+	 */
+	__u32 flags;
+	__u16 protocol;		/* protocol of this channel (4 = MPC) */
+	/*
+	 * I/O and irq related stuff
+	 */
+	struct ccw1 *ccw;
+	struct irb *irb;
+	/*
+	 * RX/TX buffer size
+	 */
+	int max_bufsize;
+	struct sk_buff *trans_skb;	/* transmit/receive buffer */
+	struct sk_buff_head io_queue;	/* universal I/O queue */
+	struct tasklet_struct ch_tasklet;	/* MPC ONLY */
+	/*
+	 * TX queue for collecting skb's during busy.
+	 */
+	struct sk_buff_head collect_queue;
+	/*
+	 * Amount of data in collect_queue.
+	 */
+	int collect_len;
+	/*
+	 * spinlock for collect_queue and collect_len
+	 */
+	spinlock_t collect_lock;
+	/*
+	 * Timer for detecting unresposive
+	 * I/O operations.
+	 */
+	fsm_timer timer;
+	/* MPC ONLY section begin */
+	__u32	th_seq_num;	/* SNA TH seq number */
+	__u8	th_seg;
+	__u32	pdu_seq;
+	struct sk_buff		*xid_skb;
+	char			*xid_skb_data;
+	struct th_header	*xid_th;
+	struct xid2		*xid;
+	char			*xid_id;
+	struct th_header	*rcvd_xid_th;
+	struct xid2		*rcvd_xid;
+	char			*rcvd_xid_id;
+	__u8			in_mpcgroup;
+	fsm_timer		sweep_timer;
+	struct sk_buff_head	sweep_queue;
+	struct th_header	*discontact_th;
+	struct tasklet_struct	ch_disc_tasklet;
+	/* MPC ONLY section end */
+
+	int retry;		/* retry counter for misc. operations */
+	fsm_instance *fsm;	/* finite state machine of this channel */
+	struct net_device *netdev;	/* corresponding net_device */
+	struct ctcm_profile prof;
+	unsigned char *trans_skb_data;
+	__u16 logflags;
+};
+
+struct ctcm_priv {
+	struct net_device_stats	stats;
+	unsigned long	tbusy;
+
+	/* The MPC group struct of this interface */
+	struct	mpc_group	*mpcg;	/* MPC only */
+	struct	xid2		*xid;	/* MPC only */
+
+	/* The finite state machine of this interface */
+	fsm_instance *fsm;
+
+	/* The protocol of this device */
+	__u16 protocol;
+
+	/* Timer for restarting after I/O Errors */
+	fsm_timer	restart_timer;
+
+	int buffer_size;	/* ctc only */
+
+	struct channel *channel[2];
+};
+
+int ctcm_open(struct net_device *dev);
+int ctcm_close(struct net_device *dev);
+
+/*
+ * prototypes for non-static sysfs functions
+ */
+int ctcm_add_attributes(struct device *dev);
+void ctcm_remove_attributes(struct device *dev);
+int ctcm_add_files(struct device *dev);
+void ctcm_remove_files(struct device *dev);
+
+/*
+ * Compatibility macros for busy handling
+ * of network devices.
+ */
+static inline void ctcm_clear_busy_do(struct net_device *dev)
+{
+	clear_bit(0, &(((struct ctcm_priv *)dev->priv)->tbusy));
+	netif_wake_queue(dev);
+}
+
+static inline void ctcm_clear_busy(struct net_device *dev)
+{
+	struct mpc_group *grp;
+	grp = ((struct ctcm_priv *)dev->priv)->mpcg;
+
+	if (!(grp && grp->in_sweep))
+		ctcm_clear_busy_do(dev);
+}
+
+
+static inline int ctcm_test_and_set_busy(struct net_device *dev)
+{
+	netif_stop_queue(dev);
+	return test_and_set_bit(0, &(((struct ctcm_priv *)dev->priv)->tbusy));
+}
+
+extern int loglevel;
+extern struct channel *channels;
+
+void ctcm_unpack_skb(struct channel *ch, struct sk_buff *pskb);
+
+/*
+ * Functions related to setup and device detection.
+ */
+
+static inline int ctcm_less_than(char *id1, char *id2)
+{
+	unsigned long dev1, dev2;
+
+	id1 = id1 + 5;
+	id2 = id2 + 5;
+
+	dev1 = simple_strtoul(id1, &id1, 16);
+	dev2 = simple_strtoul(id2, &id2, 16);
+
+	return (dev1 < dev2);
+}
+
+int ctcm_ch_alloc_buffer(struct channel *ch);
+
+static inline int ctcm_checkalloc_buffer(struct channel *ch)
+{
+	if (ch->trans_skb == NULL)
+		return ctcm_ch_alloc_buffer(ch);
+	if (ch->flags & CHANNEL_FLAGS_BUFSIZE_CHANGED) {
+		dev_kfree_skb(ch->trans_skb);
+		return ctcm_ch_alloc_buffer(ch);
+	}
+	return 0;
+}
+
+struct mpc_group *ctcmpc_init_mpc_group(struct ctcm_priv *priv);
+
+/* test if protocol attribute (of struct ctcm_priv or struct channel)
+ * has MPC protocol setting. Type is not checked
+ */
+#define IS_MPC(p) ((p)->protocol == CTCM_PROTO_MPC)
+
+/* test if struct ctcm_priv of struct net_device has MPC protocol setting */
+#define IS_MPCDEV(d) IS_MPC((struct ctcm_priv *)d->priv)
+
+static inline gfp_t gfp_type(void)
+{
+	return in_interrupt() ? GFP_ATOMIC : GFP_KERNEL;
+}
+
+/*
+ * Definition of our link level header.
+ */
+struct ll_header {
+	__u16 length;
+	__u16 type;
+	__u16 unused;
+};
+#define LL_HEADER_LENGTH (sizeof(struct ll_header))
+
+#endif
Index: linux-2.6-uschi/drivers/s390/net/ctcm_mpc.c
===================================================================
--- /dev/null
+++ linux-2.6-uschi/drivers/s390/net/ctcm_mpc.c
@@ -0,0 +1,2472 @@
+/*
+ *	drivers/s390/net/ctcm_mpc.c
+ *
+ *	Copyright IBM Corp. 2004, 2007
+ *	Authors:	Belinda Thompson (belindat@us.ibm.com)
+ *			Andy Richter (richtera@us.ibm.com)
+ *			Peter Tiedemann (ptiedem@de.ibm.com)
+ */
+
+/*
+	This module exports functions to be used by CCS:
+	EXPORT_SYMBOL(ctc_mpc_alloc_channel);
+	EXPORT_SYMBOL(ctc_mpc_establish_connectivity);
+	EXPORT_SYMBOL(ctc_mpc_dealloc_ch);
+	EXPORT_SYMBOL(ctc_mpc_flow_control);
+*/
+
+#undef DEBUG
+#undef DEBUGDATA
+#undef DEBUGCCW
+
+#include <linux/version.h>
+#include <linux/module.h>
+#include <linux/init.h>
+#include <linux/kernel.h>
+#include <linux/slab.h>
+#include <linux/errno.h>
+#include <linux/types.h>
+#include <linux/interrupt.h>
+#include <linux/timer.h>
+#include <linux/sched.h>
+
+#include <linux/signal.h>
+#include <linux/string.h>
+#include <linux/proc_fs.h>
+
+#include <linux/ip.h>
+#include <linux/if_arp.h>
+#include <linux/tcp.h>
+#include <linux/skbuff.h>
+#include <linux/ctype.h>
+#include <linux/netdevice.h>
+#include <net/dst.h>
+
+#include <linux/io.h>		/* instead of <asm/io.h> ok ? */
+#include <asm/ccwdev.h>
+#include <asm/ccwgroup.h>
+#include <linux/bitops.h>	/* instead of <asm/bitops.h> ok ? */
+#include <linux/uaccess.h>	/* instead of <asm/uaccess.h> ok ? */
+#include <linux/wait.h>
+#include <linux/moduleparam.h>
+#include <asm/idals.h>
+
+#include "cu3088.h"
+#include "ctcm_mpc.h"
+#include "ctcm_main.h"
+#include "ctcm_fsms.h"
+
+static const struct xid2 init_xid = {
+	.xid2_type_id	=	XID_FM2,
+	.xid2_len	=	0x45,
+	.xid2_adj_id	=	0,
+	.xid2_rlen	=	0x31,
+	.xid2_resv1	=	0,
+	.xid2_flag1	=	0,
+	.xid2_fmtt	=	0,
+	.xid2_flag4	=	0x80,
+	.xid2_resv2	=	0,
+	.xid2_tgnum	=	0,
+	.xid2_sender_id	=	0,
+	.xid2_flag2	=	0,
+	.xid2_option	=	XID2_0,
+	.xid2_resv3	=	"\x00",
+	.xid2_resv4	=	0,
+	.xid2_dlc_type	=	XID2_READ_SIDE,
+	.xid2_resv5	=	0,
+	.xid2_mpc_flag	=	0,
+	.xid2_resv6	=	0,
+	.xid2_buf_len	=	(MPC_BUFSIZE_DEFAULT - 35),
+};
+
+static const struct th_header thnorm = {
+	.th_seg		=	0x00,
+	.th_ch_flag	=	TH_IS_XID,
+	.th_blk_flag	=	TH_DATA_IS_XID,
+	.th_is_xid	=	0x01,
+	.th_seq_num	=	0x00000000,
+};
+
+static const struct th_header thdummy = {
+	.th_seg		=	0x00,
+	.th_ch_flag	=	0x00,
+	.th_blk_flag	=	TH_DATA_IS_XID,
+	.th_is_xid	=	0x01,
+	.th_seq_num	=	0x00000000,
+};
+
+/*
+ * Definition of one MPC group
+ */
+
+/*
+ * Compatibility macros for busy handling
+ * of network devices.
+ */
+
+static void ctcmpc_unpack_skb(struct channel *ch, struct sk_buff *pskb);
+
+/*
+ * MPC Group state machine actions (static prototypes)
+ */
+static void mpc_action_nop(fsm_instance *fsm, int event, void *arg);
+static void mpc_action_go_ready(fsm_instance *fsm, int event, void *arg);
+static void mpc_action_go_inop(fsm_instance *fi, int event, void *arg);
+static void mpc_action_timeout(fsm_instance *fi, int event, void *arg);
+static int  mpc_validate_xid(struct mpcg_info *mpcginfo);
+static void mpc_action_yside_xid(fsm_instance *fsm, int event, void *arg);
+static void mpc_action_doxid0(fsm_instance *fsm, int event, void *arg);
+static void mpc_action_doxid7(fsm_instance *fsm, int event, void *arg);
+static void mpc_action_xside_xid(fsm_instance *fsm, int event, void *arg);
+static void mpc_action_rcvd_xid0(fsm_instance *fsm, int event, void *arg);
+static void mpc_action_rcvd_xid7(fsm_instance *fsm, int event, void *arg);
+
+#ifdef DEBUGDATA
+/*-------------------------------------------------------------------*
+* Dump buffer format						     *
+*								     *
+*--------------------------------------------------------------------*/
+void ctcmpc_dumpit(char *buf, int len)
+{
+	__u32	ct, sw, rm, dup;
+	char	*ptr, *rptr;
+	char	tbuf[82], tdup[82];
+	#if (UTS_MACHINE == s390x)
+	char	addr[22];
+	#else
+	char	addr[12];
+	#endif
+	char	boff[12];
+	char	bhex[82], duphex[82];
+	char	basc[40];
+
+	sw  = 0;
+	rptr = ptr = buf;
+	rm  = 16;
+	duphex[0] = 0x00;
+	dup = 0;
+
+	for (ct = 0; ct < len; ct++, ptr++, rptr++) {
+		if (sw == 0) {
+			#if (UTS_MACHINE == s390x)
+			sprintf(addr, "%16.16lx", (unsigned long)rptr);
+			#else
+			sprintf(addr, "%8.8X", (__u32)rptr);
+			#endif
+
+			sprintf(boff, "%4.4X", (__u32)ct);
+			bhex[0] = '\0';
+			basc[0] = '\0';
+		}
+		if ((sw == 4) || (sw == 12))
+			strcat(bhex, " ");
+		if (sw == 8)
+			strcat(bhex, "	");
+
+		#if (UTS_MACHINE == s390x)
+		sprintf(tbuf, "%2.2lX", (unsigned long)*ptr);
+		#else
+		sprintf(tbuf, "%2.2X", (__u32)*ptr);
+		#endif
+
+		tbuf[2] = '\0';
+		strcat(bhex, tbuf);
+		if ((0 != isprint(*ptr)) && (*ptr >= 0x20))
+			basc[sw] = *ptr;
+		else
+			basc[sw] = '.';
+
+		basc[sw+1] = '\0';
+		sw++;
+		rm--;
+		if (sw == 16) {
+			if ((strcmp(duphex, bhex)) != 0) {
+				if (dup != 0) {
+					sprintf(tdup, "Duplicate as above "
+						"to %s", addr);
+					printk(KERN_INFO "		  "
+						"     --- %s ---\n", tdup);
+				}
+				printk(KERN_INFO "   %s (+%s) : %s  [%s]\n",
+					addr, boff, bhex, basc);
+				dup = 0;
+				strcpy(duphex, bhex);
+			} else
+				dup++;
+
+			sw = 0;
+			rm = 16;
+		}
+	}  /* endfor */
+
+	if (sw != 0) {
+		for ( ; rm > 0; rm--, sw++) {
+			if ((sw == 4) || (sw == 12))
+				strcat(bhex, " ");
+			if (sw == 8)
+				strcat(bhex, "	");
+			strcat(bhex, "	");
+			strcat(basc, " ");
+		}
+		if (dup != 0) {
+			sprintf(tdup, "Duplicate as above to %s", addr);
+			printk(KERN_INFO "		  "
+				"     --- %s ---\n", tdup);
+		}
+		printk(KERN_INFO "   %s (+%s) : %s  [%s]\n",
+			addr, boff, bhex, basc);
+	} else {
+		if (dup >= 1) {
+			sprintf(tdup, "Duplicate as above to %s", addr);
+			printk(KERN_INFO "		  "
+				"     --- %s ---\n", tdup);
+		}
+		if (dup != 0) {
+			printk(KERN_INFO "   %s (+%s) : %s  [%s]\n",
+				addr, boff, bhex, basc);
+		}
+	}
+
+	return;
+
+}   /*	 end of ctcmpc_dumpit  */
+#endif
+
+#ifdef DEBUGDATA
+/*
+ * Dump header and first 16 bytes of an sk_buff for debugging purposes.
+ *
+ * skb		The sk_buff to dump.
+ * offset	Offset relative to skb-data, where to start the dump.
+ */
+void ctcmpc_dump_skb(struct sk_buff *skb, int offset)
+{
+	unsigned char *p = skb->data;
+	struct th_header *header;
+	struct pdu *pheader;
+	int bl = skb->len;
+	int i;
+
+	if (p == NULL)
+		return;
+
+	p += offset;
+	header = (struct th_header *)p;
+
+	printk(KERN_INFO "dump:\n");
+	printk(KERN_INFO "skb len=%d \n", skb->len);
+	if (skb->len > 2) {
+		switch (header->th_ch_flag) {
+		case TH_HAS_PDU:
+			break;
+		case 0x00:
+		case TH_IS_XID:
+			if ((header->th_blk_flag == TH_DATA_IS_XID) &&
+			   (header->th_is_xid == 0x01))
+				goto dumpth;
+		case TH_SWEEP_REQ:
+				goto dumpth;
+		case TH_SWEEP_RESP:
+				goto dumpth;
+		default:
+			break;
+		}
+
+		pheader = (struct pdu *)p;
+		printk(KERN_INFO "pdu->offset: %d hex: %04x\n",
+		       pheader->pdu_offset, pheader->pdu_offset);
+		printk(KERN_INFO "pdu->flag  : %02x\n", pheader->pdu_flag);
+		printk(KERN_INFO "pdu->proto : %02x\n", pheader->pdu_proto);
+		printk(KERN_INFO "pdu->seq   : %02x\n", pheader->pdu_seq);
+					goto dumpdata;
+
+dumpth:
+		printk(KERN_INFO "th->seg     : %02x\n", header->th_seg);
+		printk(KERN_INFO "th->ch      : %02x\n", header->th_ch_flag);
+		printk(KERN_INFO "th->blk_flag: %02x\n", header->th_blk_flag);
+		printk(KERN_INFO "th->type    : %s\n",
+		       (header->th_is_xid) ? "DATA" : "XID");
+		printk(KERN_INFO "th->seqnum  : %04x\n", header->th_seq_num);
+
+	}
+dumpdata:
+	if (bl > 32)
+		bl = 32;
+	printk(KERN_INFO "data: ");
+	for (i = 0; i < bl; i++)
+		printk(KERN_INFO "%02x%s", *p++, (i % 16) ? " " : "\n<7>");
+	printk(KERN_INFO "\n");
+}
+#endif
+
+/*
+ * ctc_mpc_alloc_channel
+ *	(exported interface)
+ *
+ * Device Initialization :
+ *	ACTPATH  driven IO operations
+ */
+int ctc_mpc_alloc_channel(int port_num, void (*callback)(int, int))
+{
+	char device[20];
+	struct net_device *dev;
+	struct mpc_group *grp;
+	struct ctcm_priv *priv;
+
+	ctcm_pr_debug("ctcmpc enter:	%s()\n", __FUNCTION__);
+
+	sprintf(device, "%s%i", MPC_DEVICE_NAME, port_num);
+	dev = __dev_get_by_name(&init_net, device);
+
+	if (dev == NULL) {
+		printk(KERN_INFO "ctc_mpc_alloc_channel %s dev=NULL\n", device);
+		return 1;
+	}
+
+	priv = dev->priv;
+	grp = priv->mpcg;
+	if (!grp)
+		return 1;
+
+	grp->allochanfunc = callback;
+	grp->port_num = port_num;
+	grp->port_persist = 1;
+
+	ctcm_pr_debug("ctcmpc: %s called for device %s state=%s\n",
+		       __FUNCTION__,
+		       dev->name,
+		       fsm_getstate_str(grp->fsm));
+
+	switch (fsm_getstate(grp->fsm)) {
+	case MPCG_STATE_INOP:
+		/* Group is in the process of terminating */
+		grp->alloc_called = 1;
+		break;
+	case MPCG_STATE_RESET:
+		/* MPC Group will transition to state		  */
+		/* MPCG_STATE_XID2INITW iff the minimum number	  */
+		/* of 1 read and 1 write channel have successfully*/
+		/* activated					  */
+		/*fsm_newstate(grp->fsm, MPCG_STATE_XID2INITW);*/
+		if (callback)
+			grp->send_qllc_disc = 1;
+	case MPCG_STATE_XID0IOWAIT:
+		fsm_deltimer(&grp->timer);
+		grp->outstanding_xid2 = 0;
+		grp->outstanding_xid7 = 0;
+		grp->outstanding_xid7_p2 = 0;
+		grp->saved_xid2 = NULL;
+		if (callback)
+			ctcm_open(dev);
+		fsm_event(priv->fsm, DEV_EVENT_START, dev);
+		break;
+	case MPCG_STATE_READY:
+		/* XID exchanges completed after PORT was activated */
+		/* Link station already active			    */
+		/* Maybe timing issue...retry callback		    */
+		grp->allocchan_callback_retries++;
+		if (grp->allocchan_callback_retries < 4) {
+			if (grp->allochanfunc)
+				grp->allochanfunc(grp->port_num,
+					      grp->group_max_buflen);
+		} else {
+			/* there are problems...bail out	    */
+			/* there may be a state mismatch so restart */
+			grp->port_persist = 1;
+			fsm_event(grp->fsm, MPCG_EVENT_INOP, dev);
+			grp->allocchan_callback_retries = 0;
+		}
+		break;
+	default:
+		return 0;
+
+	}
+
+	ctcm_pr_debug("ctcmpc exit:  %s()\n", __FUNCTION__);
+	return 0;
+}
+EXPORT_SYMBOL(ctc_mpc_alloc_channel);
+
+/*
+ * ctc_mpc_establish_connectivity
+ *	(exported interface)
+ */
+void ctc_mpc_establish_connectivity(int port_num,
+				void (*callback)(int, int, int))
+{
+	char device[20];
+	struct net_device *dev;
+	struct mpc_group *grp;
+	struct ctcm_priv *priv;
+	struct channel *rch, *wch;
+
+	ctcm_pr_debug("ctcmpc enter:	%s()\n", __FUNCTION__);
+
+	sprintf(device, "%s%i", MPC_DEVICE_NAME, port_num);
+	dev = __dev_get_by_name(&init_net, device);
+
+	if (dev == NULL) {
+		printk(KERN_INFO "ctc_mpc_establish_connectivity "
+				"%s dev=NULL\n", device);
+		return;
+	}
+	priv = dev->priv;
+	rch = priv->channel[READ];
+	wch = priv->channel[WRITE];
+
+	grp = priv->mpcg;
+
+	ctcm_pr_debug("ctcmpc: %s() called for device %s state=%s\n",
+			__FUNCTION__, dev->name,
+			fsm_getstate_str(grp->fsm));
+
+	grp->estconnfunc = callback;
+	grp->port_num = port_num;
+
+	switch (fsm_getstate(grp->fsm)) {
+	case MPCG_STATE_READY:
+		/* XID exchanges completed after PORT was activated */
+		/* Link station already active			    */
+		/* Maybe timing issue...retry callback		    */
+		fsm_deltimer(&grp->timer);
+		grp->estconn_callback_retries++;
+		if (grp->estconn_callback_retries < 4) {
+			if (grp->estconnfunc) {
+				grp->estconnfunc(grp->port_num, 0,
+						grp->group_max_buflen);
+				grp->estconnfunc = NULL;
+			}
+		} else {
+			/* there are problems...bail out	 */
+			fsm_event(grp->fsm, MPCG_EVENT_INOP, dev);
+			grp->estconn_callback_retries = 0;
+		}
+		break;
+	case MPCG_STATE_INOP:
+	case MPCG_STATE_RESET:
+		/* MPC Group is not ready to start XID - min num of */
+		/* 1 read and 1 write channel have not been acquired*/
+		printk(KERN_WARNING "ctcmpc: %s() REJECTED ACTIVE XID Req"
+			"uest - Channel Pair is not Active\n", __FUNCTION__);
+		if (grp->estconnfunc) {
+			grp->estconnfunc(grp->port_num, -1, 0);
+			grp->estconnfunc = NULL;
+		}
+		break;
+	case MPCG_STATE_XID2INITW:
+		/* alloc channel was called but no XID exchange    */
+		/* has occurred. initiate xside XID exchange	   */
+		/* make sure yside XID0 processing has not started */
+		if ((fsm_getstate(rch->fsm) > CH_XID0_PENDING) ||
+			(fsm_getstate(wch->fsm) > CH_XID0_PENDING)) {
+			printk(KERN_WARNING "mpc: %s() ABORT ACTIVE XID"
+			       " Request- PASSIVE XID in process\n"
+			       , __FUNCTION__);
+			break;
+		}
+		grp->send_qllc_disc = 1;
+		fsm_newstate(grp->fsm, MPCG_STATE_XID0IOWAIT);
+		fsm_deltimer(&grp->timer);
+		fsm_addtimer(&grp->timer, MPC_XID_TIMEOUT_VALUE,
+						MPCG_EVENT_TIMER, dev);
+		grp->outstanding_xid7 = 0;
+		grp->outstanding_xid7_p2 = 0;
+		grp->saved_xid2 = NULL;
+		if ((rch->in_mpcgroup) &&
+				(fsm_getstate(rch->fsm) == CH_XID0_PENDING))
+			fsm_event(grp->fsm, MPCG_EVENT_XID0DO, rch);
+		else {
+			printk(KERN_WARNING "mpc: %s() Unable to start"
+			       " ACTIVE XID0 on read channel\n",
+			       __FUNCTION__);
+			if (grp->estconnfunc) {
+				grp->estconnfunc(grp->port_num, -1, 0);
+				grp->estconnfunc = NULL;
+			}
+			fsm_deltimer(&grp->timer);
+				goto done;
+		}
+		if ((wch->in_mpcgroup) &&
+				(fsm_getstate(wch->fsm) == CH_XID0_PENDING))
+			fsm_event(grp->fsm, MPCG_EVENT_XID0DO, wch);
+		else {
+			printk(KERN_WARNING "mpc: %s() Unable to start"
+				" ACTIVE XID0 on write channel\n",
+					__FUNCTION__);
+			if (grp->estconnfunc) {
+				grp->estconnfunc(grp->port_num, -1, 0);
+				grp->estconnfunc = NULL;
+			}
+			fsm_deltimer(&grp->timer);
+				goto done;
+			}
+		break;
+	case MPCG_STATE_XID0IOWAIT:
+		/* already in active XID negotiations */
+	default:
+		break;
+	}
+
+done:
+	ctcm_pr_debug("ctcmpc exit:  %s()\n", __FUNCTION__);
+	return;
+}
+EXPORT_SYMBOL(ctc_mpc_establish_connectivity);
+
+/*
+ * ctc_mpc_dealloc_ch
+ *	(exported interface)
+ */
+void ctc_mpc_dealloc_ch(int port_num)
+{
+	struct net_device *dev;
+	char device[20];
+	struct ctcm_priv *priv;
+	struct mpc_group *grp;
+
+	ctcm_pr_debug("ctcmpc enter:	%s()\n", __FUNCTION__);
+	sprintf(device, "%s%i", MPC_DEVICE_NAME, port_num);
+	dev = __dev_get_by_name(&init_net, device);
+
+	if (dev == NULL) {
+		printk(KERN_INFO "%s() %s dev=NULL\n", __FUNCTION__, device);
+					goto done;
+	}
+
+	ctcm_pr_debug("ctcmpc:%s %s() called for device %s refcount=%d\n",
+			dev->name, __FUNCTION__,
+			dev->name, atomic_read(&dev->refcnt));
+
+	priv = dev->priv;
+	if (priv == NULL) {
+		printk(KERN_INFO "%s() %s priv=NULL\n",
+				__FUNCTION__, device);
+					goto done;
+	}
+	fsm_deltimer(&priv->restart_timer);
+
+	grp = priv->mpcg;
+	if (grp == NULL) {
+		printk(KERN_INFO "%s() %s dev=NULL\n", __FUNCTION__, device);
+					goto done;
+	}
+	grp->channels_terminating = 0;
+
+	fsm_deltimer(&grp->timer);
+
+	grp->allochanfunc = NULL;
+	grp->estconnfunc = NULL;
+	grp->port_persist = 0;
+	grp->send_qllc_disc = 0;
+	fsm_event(grp->fsm, MPCG_EVENT_INOP, dev);
+
+	ctcm_close(dev);
+done:
+	ctcm_pr_debug("ctcmpc exit:  %s()\n", __FUNCTION__);
+	return;
+}
+EXPORT_SYMBOL(ctc_mpc_dealloc_ch);
+
+/*
+ * ctc_mpc_flow_control
+ *	(exported interface)
+ */
+void ctc_mpc_flow_control(int port_num, int flowc)
+{
+	char device[20];
+	struct ctcm_priv *priv;
+	struct mpc_group *grp;
+	struct net_device *dev;
+	struct channel *rch;
+	int mpcg_state;
+
+	ctcm_pr_debug("ctcmpc enter:	%s() %i\n", __FUNCTION__, flowc);
+
+	sprintf(device, "%s%i", MPC_DEVICE_NAME, port_num);
+	dev = __dev_get_by_name(&init_net, device);
+
+	if (dev == NULL) {
+		printk(KERN_INFO "ctc_mpc_flow_control %s dev=NULL\n", device);
+		return;
+	}
+
+	ctcm_pr_debug("ctcmpc: %s %s called \n", dev->name, __FUNCTION__);
+
+	priv  = dev->priv;
+	if (priv == NULL) {
+		printk(KERN_INFO "ctcmpc:%s() %s priv=NULL\n",
+		       __FUNCTION__, device);
+		return;
+	}
+	grp = priv->mpcg;
+	rch = priv->channel[READ];
+
+	mpcg_state = fsm_getstate(grp->fsm);
+	switch (flowc) {
+	case 1:
+		if (mpcg_state == MPCG_STATE_FLOWC)
+			break;
+		if (mpcg_state == MPCG_STATE_READY) {
+			if (grp->flow_off_called == 1)
+				grp->flow_off_called = 0;
+			else
+				fsm_newstate(grp->fsm, MPCG_STATE_FLOWC);
+			break;
+		}
+		break;
+	case 0:
+		if (mpcg_state == MPCG_STATE_FLOWC) {
+			fsm_newstate(grp->fsm, MPCG_STATE_READY);
+			/* ensure any data that has accumulated */
+			/* on the io_queue will now be sen t	*/
+			tasklet_schedule(&rch->ch_tasklet);
+		}
+		/* possible race condition			*/
+		if (mpcg_state == MPCG_STATE_READY) {
+			grp->flow_off_called = 1;
+			break;
+		}
+		break;
+	}
+
+	ctcm_pr_debug("ctcmpc exit:  %s() %i\n", __FUNCTION__, flowc);
+}
+EXPORT_SYMBOL(ctc_mpc_flow_control);
+
+static int mpc_send_qllc_discontact(struct net_device *);
+
+/*
+ * helper function of ctcmpc_unpack_skb
+*/
+static void mpc_rcvd_sweep_resp(struct mpcg_info *mpcginfo)
+{
+	struct channel	  *rch = mpcginfo->ch;
+	struct net_device *dev = rch->netdev;
+	struct ctcm_priv   *priv = dev->priv;
+	struct mpc_group  *grp = priv->mpcg;
+	struct channel	  *ch = priv->channel[WRITE];
+
+	if (do_debug)
+		ctcm_pr_debug("ctcmpc enter: %s(): ch=0x%p id=%s\n",
+			__FUNCTION__, ch, ch->id);
+
+	if (do_debug_data)
+		ctcmpc_dumpit((char *)mpcginfo->sweep, TH_SWEEP_LENGTH);
+
+	grp->sweep_rsp_pend_num--;
+
+	if ((grp->sweep_req_pend_num == 0) &&
+			(grp->sweep_rsp_pend_num == 0)) {
+		fsm_deltimer(&ch->sweep_timer);
+		grp->in_sweep = 0;
+		rch->th_seq_num = 0x00;
+		ch->th_seq_num = 0x00;
+		ctcm_clear_busy_do(dev);
+	}
+
+	kfree(mpcginfo);
+
+	return;
+
+}
+
+/*
+ * helper function of mpc_rcvd_sweep_req
+ * which is a helper of ctcmpc_unpack_skb
+ */
+static void ctcmpc_send_sweep_resp(struct channel *rch)
+{
+	struct net_device *dev = rch->netdev;
+	struct ctcm_priv *priv = dev->priv;
+	struct mpc_group *grp = priv->mpcg;
+	int rc = 0;
+	struct th_sweep *header;
+	struct sk_buff *sweep_skb;
+	struct channel *ch  = priv->channel[WRITE];
+
+	if (do_debug)
+		ctcm_pr_debug("ctcmpc exit : %s(): ch=0x%p id=%s\n",
+			__FUNCTION__, rch, rch->id);
+
+	sweep_skb = __dev_alloc_skb(MPC_BUFSIZE_DEFAULT,
+				    GFP_ATOMIC|GFP_DMA);
+	if (sweep_skb == NULL) {
+		printk(KERN_INFO "Couldn't alloc sweep_skb\n");
+		rc = -ENOMEM;
+				goto done;
+	}
+
+	header = (struct th_sweep *)
+			kmalloc(sizeof(struct th_sweep), gfp_type());
+
+	if (!header) {
+		dev_kfree_skb_any(sweep_skb);
+		rc = -ENOMEM;
+				goto done;
+	}
+
+	header->th.th_seg	= 0x00 ;
+	header->th.th_ch_flag	= TH_SWEEP_RESP;
+	header->th.th_blk_flag	= 0x00;
+	header->th.th_is_xid	= 0x00;
+	header->th.th_seq_num	= 0x00;
+	header->sw.th_last_seq	= ch->th_seq_num;
+
+	memcpy(skb_put(sweep_skb, TH_SWEEP_LENGTH), header, TH_SWEEP_LENGTH);
+
+	kfree(header);
+
+	dev->trans_start = jiffies;
+	skb_queue_tail(&ch->sweep_queue, sweep_skb);
+
+	fsm_addtimer(&ch->sweep_timer, 100, CTC_EVENT_RSWEEP_TIMER, ch);
+
+	return;
+
+done:
+	if (rc != 0) {
+		grp->in_sweep = 0;
+		ctcm_clear_busy_do(dev);
+		fsm_event(grp->fsm, MPCG_EVENT_INOP, dev);
+	}
+
+	return;
+}
+
+/*
+ * helper function of ctcmpc_unpack_skb
+ */
+static void mpc_rcvd_sweep_req(struct mpcg_info *mpcginfo)
+{
+	struct channel	  *rch     = mpcginfo->ch;
+	struct net_device *dev     = rch->netdev;
+	struct ctcm_priv  *priv = dev->priv;
+	struct mpc_group  *grp  = priv->mpcg;
+	struct channel	  *ch	   = priv->channel[WRITE];
+
+	if (do_debug)
+		CTCM_DBF_TEXT_(MPC_TRACE, CTC_DBF_DEBUG,
+			" %s(): ch=0x%p id=%s\n", __FUNCTION__, ch, ch->id);
+
+	if (grp->in_sweep == 0) {
+		grp->in_sweep = 1;
+		ctcm_test_and_set_busy(dev);
+		grp->sweep_req_pend_num = grp->active_channels[READ];
+		grp->sweep_rsp_pend_num = grp->active_channels[READ];
+	}
+
+	if (do_debug_data)
+		ctcmpc_dumpit((char *)mpcginfo->sweep, TH_SWEEP_LENGTH);
+
+	grp->sweep_req_pend_num--;
+	ctcmpc_send_sweep_resp(ch);
+	kfree(mpcginfo);
+	return;
+}
+
+/*
+  * MPC Group Station FSM definitions
+ */
+static const char *mpcg_event_names[] = {
+	[MPCG_EVENT_INOP]	= "INOP Condition",
+	[MPCG_EVENT_DISCONC]	= "Discontact Received",
+	[MPCG_EVENT_XID0DO]	= "Channel Active - Start XID",
+	[MPCG_EVENT_XID2]	= "XID2 Received",
+	[MPCG_EVENT_XID2DONE]	= "XID0 Complete",
+	[MPCG_EVENT_XID7DONE]	= "XID7 Complete",
+	[MPCG_EVENT_TIMER]	= "XID Setup Timer",
+	[MPCG_EVENT_DOIO]	= "XID DoIO",
+};
+
+static const char *mpcg_state_names[] = {
+	[MPCG_STATE_RESET]	= "Reset",
+	[MPCG_STATE_INOP]	= "INOP",
+	[MPCG_STATE_XID2INITW]	= "Passive XID- XID0 Pending Start",
+	[MPCG_STATE_XID2INITX]	= "Passive XID- XID0 Pending Complete",
+	[MPCG_STATE_XID7INITW]	= "Passive XID- XID7 Pending P1 Start",
+	[MPCG_STATE_XID7INITX]	= "Passive XID- XID7 Pending P2 Complete",
+	[MPCG_STATE_XID0IOWAIT]	= "Active  XID- XID0 Pending Start",
+	[MPCG_STATE_XID0IOWAIX]	= "Active  XID- XID0 Pending Complete",
+	[MPCG_STATE_XID7INITI]	= "Active  XID- XID7 Pending Start",
+	[MPCG_STATE_XID7INITZ]	= "Active  XID- XID7 Pending Complete ",
+	[MPCG_STATE_XID7INITF]	= "XID        - XID7 Complete ",
+	[MPCG_STATE_FLOWC]	= "FLOW CONTROL ON",
+	[MPCG_STATE_READY]	= "READY",
+};
+
+/*
+ * The MPC Group Station FSM
+ *   22 events
+ */
+static const fsm_node mpcg_fsm[] = {
+	{ MPCG_STATE_RESET,	MPCG_EVENT_INOP,	mpc_action_go_inop    },
+	{ MPCG_STATE_INOP,	MPCG_EVENT_INOP,	mpc_action_nop        },
+	{ MPCG_STATE_FLOWC,	MPCG_EVENT_INOP,	mpc_action_go_inop    },
+
+	{ MPCG_STATE_READY,	MPCG_EVENT_DISCONC,	mpc_action_discontact },
+	{ MPCG_STATE_READY,	MPCG_EVENT_INOP,	mpc_action_go_inop    },
+
+	{ MPCG_STATE_XID2INITW,	MPCG_EVENT_XID0DO,	mpc_action_doxid0     },
+	{ MPCG_STATE_XID2INITW,	MPCG_EVENT_XID2,	mpc_action_rcvd_xid0  },
+	{ MPCG_STATE_XID2INITW,	MPCG_EVENT_INOP,	mpc_action_go_inop    },
+	{ MPCG_STATE_XID2INITW,	MPCG_EVENT_TIMER,	mpc_action_timeout    },
+	{ MPCG_STATE_XID2INITW,	MPCG_EVENT_DOIO,	mpc_action_yside_xid  },
+
+	{ MPCG_STATE_XID2INITX,	MPCG_EVENT_XID0DO,	mpc_action_doxid0     },
+	{ MPCG_STATE_XID2INITX,	MPCG_EVENT_XID2,	mpc_action_rcvd_xid0  },
+	{ MPCG_STATE_XID2INITX,	MPCG_EVENT_INOP,	mpc_action_go_inop    },
+	{ MPCG_STATE_XID2INITX,	MPCG_EVENT_TIMER,	mpc_action_timeout    },
+	{ MPCG_STATE_XID2INITX,	MPCG_EVENT_DOIO,	mpc_action_yside_xid  },
+
+	{ MPCG_STATE_XID7INITW,	MPCG_EVENT_XID2DONE,	mpc_action_doxid7     },
+	{ MPCG_STATE_XID7INITW,	MPCG_EVENT_DISCONC,	mpc_action_discontact },
+	{ MPCG_STATE_XID7INITW,	MPCG_EVENT_XID2,	mpc_action_rcvd_xid7  },
+	{ MPCG_STATE_XID7INITW,	MPCG_EVENT_INOP,	mpc_action_go_inop    },
+	{ MPCG_STATE_XID7INITW,	MPCG_EVENT_TIMER,	mpc_action_timeout    },
+	{ MPCG_STATE_XID7INITW,	MPCG_EVENT_XID7DONE,	mpc_action_doxid7     },
+	{ MPCG_STATE_XID7INITW,	MPCG_EVENT_DOIO,	mpc_action_yside_xid  },
+
+	{ MPCG_STATE_XID7INITX,	MPCG_EVENT_DISCONC,	mpc_action_discontact },
+	{ MPCG_STATE_XID7INITX,	MPCG_EVENT_XID2,	mpc_action_rcvd_xid7  },
+	{ MPCG_STATE_XID7INITX,	MPCG_EVENT_INOP,	mpc_action_go_inop    },
+	{ MPCG_STATE_XID7INITX,	MPCG_EVENT_XID7DONE,	mpc_action_doxid7     },
+	{ MPCG_STATE_XID7INITX,	MPCG_EVENT_TIMER,	mpc_action_timeout    },
+	{ MPCG_STATE_XID7INITX,	MPCG_EVENT_DOIO,	mpc_action_yside_xid  },
+
+	{ MPCG_STATE_XID0IOWAIT, MPCG_EVENT_XID0DO,	mpc_action_doxid0     },
+	{ MPCG_STATE_XID0IOWAIT, MPCG_EVENT_DISCONC,	mpc_action_discontact },
+	{ MPCG_STATE_XID0IOWAIT, MPCG_EVENT_XID2,	mpc_action_rcvd_xid0  },
+	{ MPCG_STATE_XID0IOWAIT, MPCG_EVENT_INOP,	mpc_action_go_inop    },
+	{ MPCG_STATE_XID0IOWAIT, MPCG_EVENT_TIMER,	mpc_action_timeout    },
+	{ MPCG_STATE_XID0IOWAIT, MPCG_EVENT_DOIO,	mpc_action_xside_xid  },
+
+	{ MPCG_STATE_XID0IOWAIX, MPCG_EVENT_XID0DO,	mpc_action_doxid0     },
+	{ MPCG_STATE_XID0IOWAIX, MPCG_EVENT_DISCONC,	mpc_action_discontact },
+	{ MPCG_STATE_XID0IOWAIX, MPCG_EVENT_XID2,	mpc_action_rcvd_xid0  },
+	{ MPCG_STATE_XID0IOWAIX, MPCG_EVENT_INOP,	mpc_action_go_inop    },
+	{ MPCG_STATE_XID0IOWAIX, MPCG_EVENT_TIMER,	mpc_action_timeout    },
+	{ MPCG_STATE_XID0IOWAIX, MPCG_EVENT_DOIO,	mpc_action_xside_xid  },
+
+	{ MPCG_STATE_XID7INITI,	MPCG_EVENT_XID2DONE,	mpc_action_doxid7     },
+	{ MPCG_STATE_XID7INITI,	MPCG_EVENT_XID2,	mpc_action_rcvd_xid7  },
+	{ MPCG_STATE_XID7INITI,	MPCG_EVENT_DISCONC,	mpc_action_discontact },
+	{ MPCG_STATE_XID7INITI,	MPCG_EVENT_INOP,	mpc_action_go_inop    },
+	{ MPCG_STATE_XID7INITI,	MPCG_EVENT_TIMER,	mpc_action_timeout    },
+	{ MPCG_STATE_XID7INITI,	MPCG_EVENT_XID7DONE,	mpc_action_doxid7     },
+	{ MPCG_STATE_XID7INITI,	MPCG_EVENT_DOIO,	mpc_action_xside_xid  },
+
+	{ MPCG_STATE_XID7INITZ,	MPCG_EVENT_XID2,	mpc_action_rcvd_xid7  },
+	{ MPCG_STATE_XID7INITZ,	MPCG_EVENT_XID7DONE,	mpc_action_doxid7     },
+	{ MPCG_STATE_XID7INITZ,	MPCG_EVENT_DISCONC,	mpc_action_discontact },
+	{ MPCG_STATE_XID7INITZ,	MPCG_EVENT_INOP,	mpc_action_go_inop    },
+	{ MPCG_STATE_XID7INITZ,	MPCG_EVENT_TIMER,	mpc_action_timeout    },
+	{ MPCG_STATE_XID7INITZ,	MPCG_EVENT_DOIO,	mpc_action_xside_xid  },
+
+	{ MPCG_STATE_XID7INITF,	MPCG_EVENT_INOP,	mpc_action_go_inop    },
+	{ MPCG_STATE_XID7INITF,	MPCG_EVENT_XID7DONE,	mpc_action_go_ready   },
+};
+
+static int mpcg_fsm_len = ARRAY_SIZE(mpcg_fsm);
+
+/*
+ * MPC Group Station FSM action
+ * CTCM_PROTO_MPC only
+ */
+static void mpc_action_go_ready(fsm_instance *fsm, int event, void *arg)
+{
+	struct net_device *dev = arg;
+	struct ctcm_priv *priv = NULL;
+	struct mpc_group *grp = NULL;
+
+	if (dev == NULL) {
+		printk(KERN_INFO "%s() dev=NULL\n", __FUNCTION__);
+		return;
+	}
+
+	ctcm_pr_debug("ctcmpc enter: %s  %s()\n", dev->name, __FUNCTION__);
+
+	priv = dev->priv;
+	if (priv == NULL) {
+		printk(KERN_INFO "%s() priv=NULL\n", __FUNCTION__);
+		return;
+	}
+
+	grp = priv->mpcg;
+	if (grp == NULL) {
+		printk(KERN_INFO "%s() grp=NULL\n", __FUNCTION__);
+		return;
+	}
+
+	fsm_deltimer(&grp->timer);
+
+	if (grp->saved_xid2->xid2_flag2 == 0x40) {
+		priv->xid->xid2_flag2 = 0x00;
+		if (grp->estconnfunc) {
+			grp->estconnfunc(grp->port_num, 1,
+					grp->group_max_buflen);
+			grp->estconnfunc = NULL;
+		} else if (grp->allochanfunc)
+			grp->send_qllc_disc = 1;
+					goto done;
+	}
+
+	grp->port_persist = 1;
+	grp->out_of_sequence = 0;
+	grp->estconn_called = 0;
+
+	tasklet_hi_schedule(&grp->mpc_tasklet2);
+
+	ctcm_pr_debug("ctcmpc exit: %s  %s()\n", dev->name, __FUNCTION__);
+	return;
+
+done:
+	fsm_event(grp->fsm, MPCG_EVENT_INOP, dev);
+
+
+	ctcm_pr_info("ctcmpc: %s()failure occurred\n", __FUNCTION__);
+}
+
+/*
+ * helper of ctcm_init_netdevice
+ * CTCM_PROTO_MPC only
+ */
+void mpc_group_ready(unsigned long adev)
+{
+	struct net_device *dev = (struct net_device *)adev;
+	struct ctcm_priv *priv = NULL;
+	struct mpc_group  *grp = NULL;
+	struct channel *ch = NULL;
+
+
+	ctcm_pr_debug("ctcmpc enter:	%s()\n", __FUNCTION__);
+
+	if (dev == NULL) {
+		printk(KERN_INFO "%s() dev=NULL\n", __FUNCTION__);
+		return;
+	}
+
+	priv = dev->priv;
+	if (priv == NULL) {
+		printk(KERN_INFO "%s() priv=NULL\n", __FUNCTION__);
+		return;
+	}
+
+	grp = priv->mpcg;
+	if (grp == NULL) {
+		printk(KERN_INFO "ctcmpc:%s() grp=NULL\n", __FUNCTION__);
+		return;
+	}
+
+	printk(KERN_NOTICE "ctcmpc: %s GROUP TRANSITIONED TO READY"
+	       "  maxbuf:%d\n",
+	       dev->name, grp->group_max_buflen);
+
+	fsm_newstate(grp->fsm, MPCG_STATE_READY);
+
+	/* Put up a read on the channel */
+	ch = priv->channel[READ];
+	ch->pdu_seq = 0;
+	if (do_debug_data)
+		ctcm_pr_debug("ctcmpc: %s() ToDCM_pdu_seq= %08x\n" ,
+			__FUNCTION__, ch->pdu_seq);
+
+	ctcmpc_chx_rxidle(ch->fsm, CTC_EVENT_START, ch);
+	/* Put the write channel in idle state */
+	ch = priv->channel[WRITE];
+	if (ch->collect_len > 0) {
+		spin_lock(&ch->collect_lock);
+		ctcm_purge_skb_queue(&ch->collect_queue);
+		ch->collect_len = 0;
+		spin_unlock(&ch->collect_lock);
+	}
+	ctcm_chx_txidle(ch->fsm, CTC_EVENT_START, ch);
+
+	ctcm_clear_busy(dev);
+
+	if (grp->estconnfunc) {
+		grp->estconnfunc(grp->port_num, 0,
+				    grp->group_max_buflen);
+		grp->estconnfunc = NULL;
+	} else
+		if (grp->allochanfunc)
+		grp->allochanfunc(grp->port_num,
+				     grp->group_max_buflen);
+
+	grp->send_qllc_disc = 1;
+	grp->changed_side = 0;
+
+	ctcm_pr_debug("ctcmpc exit:  %s()\n", __FUNCTION__);
+	return;
+
+}
+
+/*
+ * Increment the MPC Group Active Channel Counts
+ * helper of dev_action (called from channel fsm)
+ */
+int mpc_channel_action(struct channel *ch, int direction, int action)
+{
+	struct net_device  *dev     = ch->netdev;
+	struct ctcm_priv    *priv;
+	struct mpc_group   *grp  = NULL;
+	int	    rc = 0;
+
+	if (do_debug)
+		ctcm_pr_debug("ctcmpc enter: %s(): ch=0x%p id=%s\n",
+			__FUNCTION__, ch, ch->id);
+
+	if (dev == NULL) {
+		printk(KERN_INFO "ctcmpc_channel_action %i dev=NULL\n",
+		       action);
+		rc = 1;
+					goto done;
+	}
+
+	priv = dev->priv;
+	if (priv == NULL) {
+		printk(KERN_INFO
+		       "ctcmpc_channel_action%i priv=NULL, dev=%s\n",
+		       action, dev->name);
+		rc = 2;
+					goto done;
+	}
+
+	grp = priv->mpcg;
+
+	if (grp == NULL) {
+		printk(KERN_INFO "ctcmpc: %s()%i mpcgroup=NULL, dev=%s\n",
+		       __FUNCTION__, action, dev->name);
+		rc = 3;
+					goto done;
+	}
+
+	ctcm_pr_info(
+		      "ctcmpc: %s() %i(): Grp:%s total_channel_paths=%i "
+		      "active_channels read=%i, write=%i\n",
+		      __FUNCTION__,
+		      action,
+		      fsm_getstate_str(grp->fsm),
+		      grp->num_channel_paths,
+		      grp->active_channels[READ],
+		      grp->active_channels[WRITE]);
+
+	if ((action == MPC_CHANNEL_ADD) && (ch->in_mpcgroup == 0)) {
+		grp->num_channel_paths++;
+		grp->active_channels[direction]++;
+		grp->outstanding_xid2++;
+		ch->in_mpcgroup = 1;
+
+		if (ch->xid_skb != NULL)
+			dev_kfree_skb_any(ch->xid_skb);
+
+		ch->xid_skb = __dev_alloc_skb(MPC_BUFSIZE_DEFAULT,
+					GFP_ATOMIC | GFP_DMA);
+		if (ch->xid_skb == NULL) {
+			printk(KERN_INFO "ctcmpc: %s()"
+			       "Couldn't alloc ch xid_skb\n", __FUNCTION__);
+			fsm_event(grp->fsm, MPCG_EVENT_INOP, dev);
+			return 1;
+		}
+		ch->xid_skb_data = ch->xid_skb->data;
+		ch->xid_th = (struct th_header *)ch->xid_skb->data;
+		skb_put(ch->xid_skb, TH_HEADER_LENGTH);
+		ch->xid = (struct xid2 *)skb_tail_pointer(ch->xid_skb);
+		skb_put(ch->xid_skb, XID2_LENGTH);
+		ch->xid_id = skb_tail_pointer(ch->xid_skb);
+		ch->xid_skb->data = ch->xid_skb_data;
+		skb_reset_tail_pointer(ch->xid_skb);
+		ch->xid_skb->len = 0;
+
+		memcpy(skb_put(ch->xid_skb, grp->xid_skb->len),
+				grp->xid_skb->data,
+				grp->xid_skb->len);
+
+		ch->xid->xid2_dlc_type = ((CHANNEL_DIRECTION(ch->flags) == READ)
+				? XID2_READ_SIDE : XID2_WRITE_SIDE);
+
+		if (CHANNEL_DIRECTION(ch->flags) == WRITE)
+			ch->xid->xid2_buf_len = 0x00;
+
+		ch->xid_skb->data = ch->xid_skb_data;
+		skb_reset_tail_pointer(ch->xid_skb);
+		ch->xid_skb->len = 0;
+
+		fsm_newstate(ch->fsm, CH_XID0_PENDING);
+
+		if ((grp->active_channels[READ]  > 0) &&
+		    (grp->active_channels[WRITE] > 0) &&
+			(fsm_getstate(grp->fsm) < MPCG_STATE_XID2INITW)) {
+			fsm_newstate(grp->fsm, MPCG_STATE_XID2INITW);
+			printk(KERN_NOTICE "ctcmpc: %s MPC GROUP "
+					"CHANNELS ACTIVE\n", dev->name);
+		}
+	} else if ((action == MPC_CHANNEL_REMOVE) &&
+			(ch->in_mpcgroup == 1)) {
+		ch->in_mpcgroup = 0;
+		grp->num_channel_paths--;
+		grp->active_channels[direction]--;
+
+		if (ch->xid_skb != NULL)
+			dev_kfree_skb_any(ch->xid_skb);
+		ch->xid_skb = NULL;
+
+		if (grp->channels_terminating)
+					goto done;
+
+		if (((grp->active_channels[READ] == 0) &&
+					(grp->active_channels[WRITE] > 0))
+			|| ((grp->active_channels[WRITE] == 0) &&
+					(grp->active_channels[READ] > 0)))
+			fsm_event(grp->fsm, MPCG_EVENT_INOP, dev);
+	}
+
+done:
+
+	if (do_debug) {
+		ctcm_pr_debug(
+		       "ctcmpc: %s() %i Grp:%s ttl_chan_paths=%i "
+		       "active_chans read=%i, write=%i\n",
+		       __FUNCTION__,
+		       action,
+		       fsm_getstate_str(grp->fsm),
+		       grp->num_channel_paths,
+		       grp->active_channels[READ],
+		       grp->active_channels[WRITE]);
+
+		ctcm_pr_debug("ctcmpc exit : %s(): ch=0x%p id=%s\n",
+				__FUNCTION__, ch, ch->id);
+	}
+	return rc;
+
+}
+
+/**
+ * Unpack a just received skb and hand it over to
+ * upper layers.
+ * special MPC version of unpack_skb.
+ *
+ * ch		The channel where this skb has been received.
+ * pskb		The received skb.
+ */
+static void ctcmpc_unpack_skb(struct channel *ch, struct sk_buff *pskb)
+{
+	struct net_device *dev	= ch->netdev;
+	struct ctcm_priv *priv = dev->priv;
+	struct mpc_group *grp = priv->mpcg;
+	struct pdu *curr_pdu;
+	struct mpcg_info *mpcginfo;
+	struct th_header *header = NULL;
+	struct th_sweep *sweep = NULL;
+	int pdu_last_seen = 0;
+	__u32 new_len;
+	struct sk_buff *skb;
+	int skblen;
+	int sendrc = 0;
+
+	if (do_debug)
+		ctcm_pr_debug("ctcmpc enter: %s() %s cp:%i ch:%s\n",
+		       __FUNCTION__, dev->name, smp_processor_id(), ch->id);
+
+	header = (struct th_header *)pskb->data;
+	if ((header->th_seg == 0) &&
+		(header->th_ch_flag == 0) &&
+		(header->th_blk_flag == 0) &&
+		(header->th_seq_num == 0))
+		/* nothing for us */	goto done;
+
+	if (do_debug_data) {
+		ctcm_pr_debug("ctcmpc: %s() th_header\n", __FUNCTION__);
+		ctcmpc_dumpit((char *)header, TH_HEADER_LENGTH);
+		ctcm_pr_debug("ctcmpc: %s() pskb len: %04x \n",
+		       __FUNCTION__, pskb->len);
+	}
+
+	pskb->dev = dev;
+	pskb->ip_summed = CHECKSUM_UNNECESSARY;
+	skb_pull(pskb, TH_HEADER_LENGTH);
+
+	if (likely(header->th_ch_flag == TH_HAS_PDU)) {
+		if (do_debug_data)
+			ctcm_pr_debug("ctcmpc: %s() came into th_has_pdu\n",
+			       __FUNCTION__);
+		if ((fsm_getstate(grp->fsm) == MPCG_STATE_FLOWC) ||
+		   ((fsm_getstate(grp->fsm) == MPCG_STATE_READY) &&
+		    (header->th_seq_num != ch->th_seq_num + 1) &&
+		    (ch->th_seq_num != 0))) {
+			/* This is NOT the next segment		*
+			 * we are not the correct race winner	*
+			 * go away and let someone else win	*
+			 * BUT..this only applies if xid negot	*
+			 * is done				*
+			*/
+			grp->out_of_sequence += 1;
+			__skb_push(pskb, TH_HEADER_LENGTH);
+			skb_queue_tail(&ch->io_queue, pskb);
+			if (do_debug_data)
+				ctcm_pr_debug("ctcmpc: %s() th_seq_num "
+				       "expect:%08x got:%08x\n", __FUNCTION__,
+				       ch->th_seq_num + 1, header->th_seq_num);
+
+			return;
+		}
+		grp->out_of_sequence = 0;
+		ch->th_seq_num = header->th_seq_num;
+
+		if (do_debug_data)
+			ctcm_pr_debug("ctcmpc: %s() FromVTAM_th_seq=%08x\n",
+			       __FUNCTION__, ch->th_seq_num);
+
+		if (unlikely(fsm_getstate(grp->fsm) != MPCG_STATE_READY))
+					goto done;
+		pdu_last_seen = 0;
+		while ((pskb->len > 0) && !pdu_last_seen) {
+			curr_pdu = (struct pdu *)pskb->data;
+			if (do_debug_data) {
+				ctcm_pr_debug("ctcm: %s() pdu_header\n",
+				       __FUNCTION__);
+				ctcmpc_dumpit((char *)pskb->data,
+						PDU_HEADER_LENGTH);
+				ctcm_pr_debug("ctcm: %s() pskb len: %04x \n",
+				       __FUNCTION__, pskb->len);
+			}
+			skb_pull(pskb, PDU_HEADER_LENGTH);
+
+			if (curr_pdu->pdu_flag & PDU_LAST)
+				pdu_last_seen = 1;
+			if (curr_pdu->pdu_flag & PDU_CNTL)
+				pskb->protocol = htons(ETH_P_SNAP);
+			else
+				pskb->protocol = htons(ETH_P_SNA_DIX);
+
+			if ((pskb->len <= 0) || (pskb->len > ch->max_bufsize)) {
+				printk(KERN_INFO
+				       "%s Illegal packet size %d "
+				       "received "
+				       "dropping\n", dev->name,
+				       pskb->len);
+				priv->stats.rx_dropped++;
+				priv->stats.rx_length_errors++;
+					goto done;
+			}
+			skb_reset_mac_header(pskb);
+			new_len = curr_pdu->pdu_offset;
+			if (do_debug_data)
+				ctcm_pr_debug("ctcmpc: %s() new_len: %04x \n",
+				       __FUNCTION__, new_len);
+			if ((new_len == 0) || (new_len > pskb->len)) {
+				/* should never happen		    */
+				/* pskb len must be hosed...bail out */
+				printk(KERN_INFO
+				       "ctcmpc: %s(): invalid pdu"
+				       " offset of %04x - data may be"
+				       "lost\n", __FUNCTION__, new_len);
+						goto done;
+			}
+			skb = __dev_alloc_skb(new_len+4, GFP_ATOMIC);
+
+			if (!skb) {
+				printk(KERN_INFO
+				       "ctcm: %s Out of memory in "
+				       "%s()- request-len:%04x \n",
+				       dev->name,
+				       __FUNCTION__,
+				       new_len+4);
+				priv->stats.rx_dropped++;
+				fsm_event(grp->fsm,
+					  MPCG_EVENT_INOP, dev);
+						goto done;
+			}
+
+			memcpy(skb_put(skb, new_len),
+					pskb->data, new_len);
+
+			skb_reset_mac_header(skb);
+			skb->dev = pskb->dev;
+			skb->protocol = pskb->protocol;
+			skb->ip_summed = CHECKSUM_UNNECESSARY;
+			*((__u32 *) skb_push(skb, 4)) = ch->pdu_seq;
+			ch->pdu_seq++;
+
+			if (do_debug_data)
+				ctcm_pr_debug("%s: ToDCM_pdu_seq= %08x\n",
+				       __FUNCTION__, ch->pdu_seq);
+
+			ctcm_pr_debug("ctcm: %s() skb:%0lx "
+				"skb len: %d \n", __FUNCTION__,
+			       (unsigned long)skb, skb->len);
+			if (do_debug_data) {
+				ctcm_pr_debug("ctcmpc: %s() up to 32 bytes"
+					       " of pdu_data sent\n",
+					       __FUNCTION__);
+				ctcmpc_dump32((char *)skb->data, skb->len);
+			}
+
+			skblen = skb->len;
+			sendrc = netif_rx(skb);
+			priv->stats.rx_packets++;
+			priv->stats.rx_bytes += skblen;
+			skb_pull(pskb, new_len); /* point to next PDU */
+		}
+	} else {
+		mpcginfo = (struct mpcg_info *)
+				kmalloc(sizeof(struct mpcg_info), gfp_type());
+		if (mpcginfo == NULL)
+					goto done;
+
+		mpcginfo->ch = ch;
+		mpcginfo->th = header;
+		mpcginfo->skb = pskb;
+		ctcm_pr_debug("ctcmpc: %s() Not PDU - may be control pkt\n",
+			       __FUNCTION__);
+		/*  it's a sweep?   */
+		sweep = (struct th_sweep *)pskb->data;
+		mpcginfo->sweep = sweep;
+		if (header->th_ch_flag == TH_SWEEP_REQ)
+			mpc_rcvd_sweep_req(mpcginfo);
+		else if (header->th_ch_flag == TH_SWEEP_RESP)
+			mpc_rcvd_sweep_resp(mpcginfo);
+		else if (header->th_blk_flag == TH_DATA_IS_XID) {
+			struct xid2 *thisxid = (struct xid2 *)pskb->data;
+			skb_pull(pskb, XID2_LENGTH);
+			mpcginfo->xid = thisxid;
+			fsm_event(grp->fsm, MPCG_EVENT_XID2, mpcginfo);
+		} else if (header->th_blk_flag == TH_DISCONTACT)
+			fsm_event(grp->fsm, MPCG_EVENT_DISCONC, mpcginfo);
+		else if (header->th_seq_num != 0) {
+			printk(KERN_INFO "%s unexpected packet"
+					" expected control pkt\n", dev->name);
+			priv->stats.rx_dropped++;
+			/* mpcginfo only used for non-data transfers */
+			kfree(mpcginfo);
+			if (do_debug_data)
+				ctcmpc_dump_skb(pskb, -8);
+		}
+	}
+done:
+
+	dev_kfree_skb_any(pskb);
+	if (sendrc == NET_RX_DROP) {
+		printk(KERN_WARNING "%s %s() NETWORK BACKLOG EXCEEDED"
+		       " - PACKET DROPPED\n", dev->name, __FUNCTION__);
+		fsm_event(grp->fsm, MPCG_EVENT_INOP, dev);
+	}
+
+	if (do_debug)
+		ctcm_pr_debug("ctcmpc exit : %s %s(): ch=0x%p id=%s\n",
+				dev->name, __FUNCTION__, ch, ch->id);
+}
+
+/**
+ * tasklet helper for mpc's skb unpacking.
+ *
+ * ch		The channel to work on.
+ * Allow flow control back pressure to occur here.
+ * Throttling back channel can result in excessive
+ * channel inactivity and system deact of channel
+ */
+void ctcmpc_bh(unsigned long thischan)
+{
+	struct channel	  *ch	    = (struct channel *)thischan;
+	struct sk_buff	  *skb;
+	struct net_device *dev	    = ch->netdev;
+	struct ctcm_priv  *priv  = dev->priv;
+	struct mpc_group  *grp   = priv->mpcg;
+
+	if (do_debug)
+		ctcm_pr_debug("%s cp:%i enter:  %s() %s\n",
+		       dev->name, smp_processor_id(), __FUNCTION__, ch->id);
+	/* caller has requested driver to throttle back */
+	while ((fsm_getstate(grp->fsm) != MPCG_STATE_FLOWC) &&
+			(skb = skb_dequeue(&ch->io_queue))) {
+		ctcmpc_unpack_skb(ch, skb);
+		if (grp->out_of_sequence > 20) {
+			/* assume data loss has occurred if */
+			/* missing seq_num for extended     */
+			/* period of time		    */
+			grp->out_of_sequence = 0;
+			fsm_event(grp->fsm, MPCG_EVENT_INOP, dev);
+			break;
+		}
+		if (skb == skb_peek(&ch->io_queue))
+			break;
+	}
+	if (do_debug)
+		ctcm_pr_debug("ctcmpc exit : %s %s(): ch=0x%p id=%s\n",
+			dev->name, __FUNCTION__, ch,  ch->id);
+	return;
+}
+
+/*
+ *  MPC Group Initializations
+ */
+struct mpc_group *ctcmpc_init_mpc_group(struct ctcm_priv *priv)
+{
+	struct mpc_group *grp;
+
+	CTCM_DBF_TEXT(MPC_SETUP, 3, __FUNCTION__);
+
+	grp = kzalloc(sizeof(struct mpc_group), GFP_KERNEL);
+	if (grp == NULL)
+		return NULL;
+
+	grp->fsm =
+		init_fsm("mpcg", mpcg_state_names, mpcg_event_names,
+				 MPCG_NR_STATES, MPCG_NR_EVENTS, mpcg_fsm,
+				 mpcg_fsm_len, GFP_KERNEL);
+	if (grp->fsm == NULL) {
+		kfree(grp);
+		return NULL;
+	}
+
+	fsm_newstate(grp->fsm, MPCG_STATE_RESET);
+	fsm_settimer(grp->fsm, &grp->timer);
+
+	grp->xid_skb =
+		 __dev_alloc_skb(MPC_BUFSIZE_DEFAULT, GFP_ATOMIC | GFP_DMA);
+	if (grp->xid_skb == NULL) {
+		printk(KERN_INFO "Couldn't alloc MPCgroup xid_skb\n");
+		kfree_fsm(grp->fsm);
+		kfree(grp);
+		return NULL;
+	}
+	/*  base xid for all channels in group  */
+	grp->xid_skb_data = grp->xid_skb->data;
+	grp->xid_th = (struct th_header *)grp->xid_skb->data;
+	memcpy(skb_put(grp->xid_skb, TH_HEADER_LENGTH),
+			&thnorm, TH_HEADER_LENGTH);
+
+	grp->xid = (struct xid2 *) skb_tail_pointer(grp->xid_skb);
+	memcpy(skb_put(grp->xid_skb, XID2_LENGTH), &init_xid, XID2_LENGTH);
+	grp->xid->xid2_adj_id = jiffies | 0xfff00000;
+	grp->xid->xid2_sender_id = jiffies;
+
+	grp->xid_id = skb_tail_pointer(grp->xid_skb);
+	memcpy(skb_put(grp->xid_skb, 4), "VTAM", 4);
+
+	grp->rcvd_xid_skb =
+		__dev_alloc_skb(MPC_BUFSIZE_DEFAULT, GFP_ATOMIC|GFP_DMA);
+	if (grp->rcvd_xid_skb == NULL) {
+		printk(KERN_INFO "Couldn't alloc MPCgroup rcvd_xid_skb\n");
+		kfree_fsm(grp->fsm);
+		dev_kfree_skb(grp->xid_skb);
+		kfree(grp);
+		return NULL;
+	}
+	grp->rcvd_xid_data = grp->rcvd_xid_skb->data;
+	grp->rcvd_xid_th = (struct th_header *)grp->rcvd_xid_skb->data;
+	memcpy(skb_put(grp->rcvd_xid_skb, TH_HEADER_LENGTH),
+			&thnorm, TH_HEADER_LENGTH);
+	grp->saved_xid2 = NULL;
+	priv->xid = grp->xid;
+	priv->mpcg = grp;
+	return grp;
+}
+
+/*
+ * The MPC Group Station FSM
+ */
+
+/*
+ * MPC Group Station FSM actions
+ * CTCM_PROTO_MPC only
+ */
+
+/**
+ * NOP action for statemachines
+ */
+static void mpc_action_nop(fsm_instance *fi, int event, void *arg)
+{
+}
+
+/*
+ * invoked when the device transitions to dev_stopped
+ * MPC will stop each individual channel if a single XID failure
+ * occurs, or will intitiate all channels be stopped if a GROUP
+ * level failure occurs.
+ */
+static void mpc_action_go_inop(fsm_instance *fi, int event, void *arg)
+{
+	struct net_device  *dev = arg;
+	struct ctcm_priv    *priv;
+	struct mpc_group *grp;
+	int rc = 0;
+	struct channel *wch, *rch;
+
+	if (dev == NULL) {
+		printk(KERN_INFO "%s() dev=NULL\n", __FUNCTION__);
+		return;
+	}
+
+	ctcm_pr_debug("ctcmpc enter: %s  %s()\n", dev->name, __FUNCTION__);
+
+	priv  = dev->priv;
+	grp =  priv->mpcg;
+	grp->flow_off_called = 0;
+
+	fsm_deltimer(&grp->timer);
+
+	if (grp->channels_terminating)
+					goto done;
+
+	grp->channels_terminating = 1;
+
+	grp->saved_state = fsm_getstate(grp->fsm);
+	fsm_newstate(grp->fsm, MPCG_STATE_INOP);
+	if (grp->saved_state > MPCG_STATE_XID7INITF)
+		printk(KERN_NOTICE "%s:MPC GROUP INOPERATIVE\n", dev->name);
+	if ((grp->saved_state != MPCG_STATE_RESET) ||
+		/* dealloc_channel has been called */
+		((grp->saved_state == MPCG_STATE_RESET) &&
+				(grp->port_persist == 0)))
+		fsm_deltimer(&priv->restart_timer);
+
+	wch = priv->channel[WRITE];
+	rch = priv->channel[READ];
+
+	switch (grp->saved_state) {
+	case MPCG_STATE_RESET:
+	case MPCG_STATE_INOP:
+	case MPCG_STATE_XID2INITW:
+	case MPCG_STATE_XID0IOWAIT:
+	case MPCG_STATE_XID2INITX:
+	case MPCG_STATE_XID7INITW:
+	case MPCG_STATE_XID7INITX:
+	case MPCG_STATE_XID0IOWAIX:
+	case MPCG_STATE_XID7INITI:
+	case MPCG_STATE_XID7INITZ:
+	case MPCG_STATE_XID7INITF:
+		break;
+	case MPCG_STATE_FLOWC:
+	case MPCG_STATE_READY:
+	default:
+		tasklet_hi_schedule(&wch->ch_disc_tasklet);
+	}
+
+	grp->xid2_tgnum = 0;
+	grp->group_max_buflen = 0;  /*min of all received */
+	grp->outstanding_xid2 = 0;
+	grp->outstanding_xid7 = 0;
+	grp->outstanding_xid7_p2 = 0;
+	grp->saved_xid2 = NULL;
+	grp->xidnogood = 0;
+	grp->changed_side = 0;
+
+	grp->rcvd_xid_skb->data = grp->rcvd_xid_data;
+	skb_reset_tail_pointer(grp->rcvd_xid_skb);
+	grp->rcvd_xid_skb->len = 0;
+	grp->rcvd_xid_th = (struct th_header *)grp->rcvd_xid_skb->data;
+	memcpy(skb_put(grp->rcvd_xid_skb, TH_HEADER_LENGTH), &thnorm,
+	       TH_HEADER_LENGTH);
+
+	if (grp->send_qllc_disc == 1) {
+		grp->send_qllc_disc = 0;
+		rc = mpc_send_qllc_discontact(dev);
+	}
+
+	/* DO NOT issue DEV_EVENT_STOP directly out of this code */
+	/* This can result in INOP of VTAM PU due to halting of  */
+	/* outstanding IO which causes a sense to be returned	 */
+	/* Only about 3 senses are allowed and then IOS/VTAM will*/
+	/* ebcome unreachable without manual intervention	 */
+	if ((grp->port_persist == 1)	|| (grp->alloc_called)) {
+		grp->alloc_called = 0;
+		fsm_deltimer(&priv->restart_timer);
+		fsm_addtimer(&priv->restart_timer,
+			     500,
+			     DEV_EVENT_RESTART,
+			     dev);
+		fsm_newstate(grp->fsm, MPCG_STATE_RESET);
+		if (grp->saved_state > MPCG_STATE_XID7INITF)
+			printk(KERN_NOTICE "%s:MPC GROUP RECOVERY SCHEDULED\n",
+			       dev->name);
+	} else {
+		fsm_deltimer(&priv->restart_timer);
+		fsm_addtimer(&priv->restart_timer, 500, DEV_EVENT_STOP, dev);
+		fsm_newstate(grp->fsm, MPCG_STATE_RESET);
+		printk(KERN_NOTICE "%s:MPC GROUP RECOVERY NOT ATTEMPTED\n",
+		       dev->name);
+	}
+
+done:
+	ctcm_pr_debug("ctcmpc exit:%s  %s()\n", dev->name, __FUNCTION__);
+	return;
+}
+
+/**
+ * Handle mpc group  action timeout.
+ * MPC Group Station FSM action
+ * CTCM_PROTO_MPC only
+ *
+ * fi		An instance of an mpc_group fsm.
+ * event	The event, just happened.
+ * arg		Generic pointer, casted from net_device * upon call.
+ */
+static void mpc_action_timeout(fsm_instance *fi, int event, void *arg)
+{
+	struct net_device *dev = arg;
+	struct ctcm_priv *priv;
+	struct mpc_group *grp;
+	struct channel *wch;
+	struct channel *rch;
+
+	CTCM_DBF_TEXT(MPC_TRACE, 6, __FUNCTION__);
+
+	if (dev == NULL) {
+		CTCM_DBF_TEXT_(MPC_ERROR, 4, "%s: dev=NULL\n", __FUNCTION__);
+		return;
+	}
+
+	priv = dev->priv;
+	grp = priv->mpcg;
+	wch = priv->channel[WRITE];
+	rch = priv->channel[READ];
+
+	switch (fsm_getstate(grp->fsm)) {
+	case MPCG_STATE_XID2INITW:
+		/* Unless there is outstanding IO on the  */
+		/* channel just return and wait for ATTN  */
+		/* interrupt to begin XID negotiations	  */
+		if ((fsm_getstate(rch->fsm) == CH_XID0_PENDING) &&
+		   (fsm_getstate(wch->fsm) == CH_XID0_PENDING))
+			break;
+	default:
+		fsm_event(grp->fsm, MPCG_EVENT_INOP, dev);
+	}
+
+	CTCM_DBF_TEXT_(MPC_TRACE, 6, "%s: dev=%s exit",
+					__FUNCTION__, dev->name);
+	return;
+}
+
+/*
+ * MPC Group Station FSM action
+ * CTCM_PROTO_MPC only
+ */
+void mpc_action_discontact(fsm_instance *fi, int event, void *arg)
+{
+	struct mpcg_info   *mpcginfo   = arg;
+	struct channel	   *ch	       = mpcginfo->ch;
+	struct net_device  *dev        = ch->netdev;
+	struct ctcm_priv   *priv    = dev->priv;
+	struct mpc_group   *grp     = priv->mpcg;
+
+	if (ch == NULL)	{
+		printk(KERN_INFO "%s() ch=NULL\n", __FUNCTION__);
+		return;
+	}
+	if (ch->netdev == NULL)	{
+		printk(KERN_INFO "%s() dev=NULL\n", __FUNCTION__);
+		return;
+	}
+
+	ctcm_pr_debug("ctcmpc enter: %s  %s()\n", dev->name, __FUNCTION__);
+
+	grp->send_qllc_disc = 1;
+	fsm_event(grp->fsm, MPCG_EVENT_INOP, dev);
+
+	ctcm_pr_debug("ctcmpc exit: %s  %s()\n", dev->name, __FUNCTION__);
+	return;
+}
+
+/*
+ * MPC Group Station - not part of FSM
+ * CTCM_PROTO_MPC only
+ * called from add_channel in ctcm_main.c
+ */
+void mpc_action_send_discontact(unsigned long thischan)
+{
+	struct channel	   *ch;
+	struct net_device  *dev;
+	struct ctcm_priv    *priv;
+	struct mpc_group   *grp;
+	int rc = 0;
+	unsigned long	  saveflags;
+
+	ch = (struct channel *)thischan;
+	dev = ch->netdev;
+	priv = dev->priv;
+	grp = priv->mpcg;
+
+	ctcm_pr_info("ctcmpc: %s cp:%i enter: %s() GrpState:%s ChState:%s\n",
+		       dev->name,
+		       smp_processor_id(),
+		       __FUNCTION__,
+		       fsm_getstate_str(grp->fsm),
+		       fsm_getstate_str(ch->fsm));
+	saveflags = 0;	/* avoids compiler warning with
+			   spin_unlock_irqrestore */
+
+	spin_lock_irqsave(get_ccwdev_lock(ch->cdev), saveflags);
+	rc = ccw_device_start(ch->cdev, &ch->ccw[15],
+					(unsigned long)ch, 0xff, 0);
+	spin_unlock_irqrestore(get_ccwdev_lock(ch->cdev), saveflags);
+
+	if (rc != 0) {
+		ctcm_pr_info("ctcmpc: %s() ch:%s IO failed \n",
+			       __FUNCTION__,
+			       ch->id);
+		ctcm_ccw_check_rc(ch, rc, "send discontact");
+		/* Not checking return code value here */
+		/* Making best effort to notify partner*/
+		/* that MPC Group is going down        */
+	}
+
+	ctcm_pr_debug("ctcmpc exit: %s  %s()\n", dev->name, __FUNCTION__);
+	return;
+}
+
+
+/*
+ * helper function of mpc FSM
+ * CTCM_PROTO_MPC only
+ * mpc_action_rcvd_xid7
+*/
+static int mpc_validate_xid(struct mpcg_info *mpcginfo)
+{
+	struct channel	   *ch	    = mpcginfo->ch;
+	struct net_device  *dev     = ch->netdev;
+	struct ctcm_priv   *priv = dev->priv;
+	struct mpc_group   *grp  = priv->mpcg;
+	struct xid2	   *xid     = mpcginfo->xid;
+	int	failed	= 0;
+	int	rc	= 0;
+	__u64	our_id, their_id = 0;
+	int	len;
+
+	len = TH_HEADER_LENGTH + PDU_HEADER_LENGTH;
+
+	ctcm_pr_debug("ctcmpc enter:	%s()\n", __FUNCTION__);
+
+	if (mpcginfo->xid == NULL) {
+		printk(KERN_INFO "%s() xid=NULL\n", __FUNCTION__);
+		rc = 1;
+					goto done;
+	}
+
+	ctcm_pr_debug("ctcmpc :  %s  xid received()\n", __FUNCTION__);
+	ctcmpc_dumpit((char *)mpcginfo->xid, XID2_LENGTH);
+
+	/*the received direction should be the opposite of ours  */
+	if (((CHANNEL_DIRECTION(ch->flags) == READ) ? XID2_WRITE_SIDE :
+				XID2_READ_SIDE) != xid->xid2_dlc_type) {
+		failed = 1;
+		printk(KERN_INFO "ctcmpc:%s() XID REJECTED - READ-WRITE CH "
+			"Pairing Invalid \n", __FUNCTION__);
+	}
+
+	if (xid->xid2_dlc_type == XID2_READ_SIDE) {
+		ctcm_pr_debug("ctcmpc: %s(): grpmaxbuf:%d xid2buflen:%d\n",
+				__FUNCTION__, grp->group_max_buflen,
+				xid->xid2_buf_len);
+
+		if (grp->group_max_buflen == 0 ||
+			grp->group_max_buflen > xid->xid2_buf_len - len)
+			grp->group_max_buflen = xid->xid2_buf_len - len;
+	}
+
+
+	if (grp->saved_xid2 == NULL)	{
+		grp->saved_xid2 =
+			(struct xid2 *)skb_tail_pointer(grp->rcvd_xid_skb);
+
+		memcpy(skb_put(grp->rcvd_xid_skb,
+					XID2_LENGTH), xid, XID2_LENGTH);
+		grp->rcvd_xid_skb->data = grp->rcvd_xid_data;
+
+		skb_reset_tail_pointer(grp->rcvd_xid_skb);
+		grp->rcvd_xid_skb->len = 0;
+
+		/* convert two 32 bit numbers into 1 64 bit for id compare */
+		our_id = (__u64)priv->xid->xid2_adj_id;
+		our_id = our_id << 32;
+		our_id = our_id + priv->xid->xid2_sender_id;
+		their_id = (__u64)xid->xid2_adj_id;
+		their_id = their_id << 32;
+		their_id = their_id + xid->xid2_sender_id;
+		/* lower id assume the xside role */
+		if (our_id < their_id) {
+			grp->roll = XSIDE;
+			ctcm_pr_debug("ctcmpc :%s() WE HAVE LOW ID-"
+				       "TAKE XSIDE\n", __FUNCTION__);
+		} else {
+			grp->roll = YSIDE;
+			ctcm_pr_debug("ctcmpc :%s() WE HAVE HIGH ID-"
+				       "TAKE YSIDE\n", __FUNCTION__);
+		}
+
+	} else {
+		if (xid->xid2_flag4 != grp->saved_xid2->xid2_flag4) {
+			failed = 1;
+			printk(KERN_INFO "%s XID REJECTED - XID Flag Byte4\n",
+			       __FUNCTION__);
+		}
+		if (xid->xid2_flag2 == 0x40) {
+			failed = 1;
+			printk(KERN_INFO "%s XID REJECTED - XID NOGOOD\n",
+			       __FUNCTION__);
+		}
+		if (xid->xid2_adj_id != grp->saved_xid2->xid2_adj_id) {
+			failed = 1;
+			printk(KERN_INFO "%s XID REJECTED - "
+				"Adjacent Station ID Mismatch\n",
+				__FUNCTION__);
+		}
+		if (xid->xid2_sender_id != grp->saved_xid2->xid2_sender_id) {
+			failed = 1;
+			printk(KERN_INFO "%s XID REJECTED - "
+				"Sender Address Mismatch\n", __FUNCTION__);
+
+		}
+	}
+
+	if (failed) {
+		ctcm_pr_info("ctcmpc	   :  %s() failed\n", __FUNCTION__);
+		priv->xid->xid2_flag2 = 0x40;
+		grp->saved_xid2->xid2_flag2 = 0x40;
+		rc = 1;
+	}
+
+done:
+
+	ctcm_pr_debug("ctcmpc exit:  %s()\n", __FUNCTION__);
+	return rc;
+}
+
+/*
+ * MPC Group Station FSM action
+ * CTCM_PROTO_MPC only
+ */
+static void mpc_action_side_xid(fsm_instance *fsm, void *arg, int side)
+{
+	struct channel *ch = arg;
+	struct ctcm_priv *priv;
+	struct mpc_group *grp = NULL;
+	struct net_device *dev = NULL;
+	int rc = 0;
+	int gotlock = 0;
+	unsigned long saveflags = 0;	/* avoids compiler warning with
+			   spin_unlock_irqrestore */
+
+	if (ch == NULL)	{
+		printk(KERN_INFO "%s ch=NULL\n", __FUNCTION__);
+					goto done;
+	}
+
+	if (do_debug)
+		ctcm_pr_debug("ctcmpc enter: %s(): cp=%i ch=0x%p id=%s\n",
+			__FUNCTION__, smp_processor_id(), ch, ch->id);
+
+	dev = ch->netdev;
+	if (dev == NULL) {
+		printk(KERN_INFO "%s dev=NULL\n", __FUNCTION__);
+					goto done;
+	}
+
+	priv = dev->priv;
+	if (priv == NULL) {
+		printk(KERN_INFO "%s priv=NULL\n", __FUNCTION__);
+					goto done;
+	}
+
+	grp = priv->mpcg;
+	if (grp == NULL) {
+		printk(KERN_INFO "%s grp=NULL\n", __FUNCTION__);
+					goto done;
+	}
+
+	if (ctcm_checkalloc_buffer(ch))
+					goto done;
+
+	/* skb data-buffer referencing: */
+
+	ch->trans_skb->data = ch->trans_skb_data;
+	skb_reset_tail_pointer(ch->trans_skb);
+	ch->trans_skb->len = 0;
+	/* result of the previous 3 statements is NOT always
+	 * already set after ctcm_checkalloc_buffer
+	 * because of possible reuse of the trans_skb
+	 */
+	memset(ch->trans_skb->data, 0, 16);
+	ch->rcvd_xid_th =  (struct th_header *)ch->trans_skb_data;
+	/* check is main purpose here: */
+	skb_put(ch->trans_skb, TH_HEADER_LENGTH);
+	ch->rcvd_xid = (struct xid2 *)skb_tail_pointer(ch->trans_skb);
+	/* check is main purpose here: */
+	skb_put(ch->trans_skb, XID2_LENGTH);
+	ch->rcvd_xid_id = skb_tail_pointer(ch->trans_skb);
+	/* cleanup back to startpoint */
+	ch->trans_skb->data = ch->trans_skb_data;
+	skb_reset_tail_pointer(ch->trans_skb);
+	ch->trans_skb->len = 0;
+
+	/* non-checking rewrite of above skb data-buffer referencing: */
+	/*
+	memset(ch->trans_skb->data, 0, 16);
+	ch->rcvd_xid_th =  (struct th_header *)ch->trans_skb_data;
+	ch->rcvd_xid = (struct xid2 *)(ch->trans_skb_data + TH_HEADER_LENGTH);
+	ch->rcvd_xid_id = ch->trans_skb_data + TH_HEADER_LENGTH + XID2_LENGTH;
+	 */
+
+	ch->ccw[8].flags	= CCW_FLAG_SLI | CCW_FLAG_CC;
+	ch->ccw[8].count	= 0;
+	ch->ccw[8].cda		= 0x00;
+
+	if (side == XSIDE) {
+		/* mpc_action_xside_xid */
+		if (ch->xid_th == NULL) {
+			printk(KERN_INFO "%s ch->xid_th=NULL\n", __FUNCTION__);
+					goto done;
+		}
+		ch->ccw[9].cmd_code	= CCW_CMD_WRITE;
+		ch->ccw[9].flags	= CCW_FLAG_SLI | CCW_FLAG_CC;
+		ch->ccw[9].count	= TH_HEADER_LENGTH;
+		ch->ccw[9].cda		= virt_to_phys(ch->xid_th);
+
+		if (ch->xid == NULL) {
+			printk(KERN_INFO "%s ch->xid=NULL\n", __FUNCTION__);
+					goto done;
+		}
+
+		ch->ccw[10].cmd_code	= CCW_CMD_WRITE;
+		ch->ccw[10].flags	= CCW_FLAG_SLI | CCW_FLAG_CC;
+		ch->ccw[10].count	= XID2_LENGTH;
+		ch->ccw[10].cda		= virt_to_phys(ch->xid);
+
+		ch->ccw[11].cmd_code	= CCW_CMD_READ;
+		ch->ccw[11].flags	= CCW_FLAG_SLI | CCW_FLAG_CC;
+		ch->ccw[11].count	= TH_HEADER_LENGTH;
+		ch->ccw[11].cda		= virt_to_phys(ch->rcvd_xid_th);
+
+		ch->ccw[12].cmd_code	= CCW_CMD_READ;
+		ch->ccw[12].flags	= CCW_FLAG_SLI | CCW_FLAG_CC;
+		ch->ccw[12].count	= XID2_LENGTH;
+		ch->ccw[12].cda		= virt_to_phys(ch->rcvd_xid);
+
+		ch->ccw[13].cmd_code	= CCW_CMD_READ;
+		ch->ccw[13].cda		= virt_to_phys(ch->rcvd_xid_id);
+
+	} else { /* side == YSIDE : mpc_action_yside_xid */
+		ch->ccw[9].cmd_code	= CCW_CMD_READ;
+		ch->ccw[9].flags	= CCW_FLAG_SLI | CCW_FLAG_CC;
+		ch->ccw[9].count	= TH_HEADER_LENGTH;
+		ch->ccw[9].cda		= virt_to_phys(ch->rcvd_xid_th);
+
+		ch->ccw[10].cmd_code	= CCW_CMD_READ;
+		ch->ccw[10].flags	= CCW_FLAG_SLI | CCW_FLAG_CC;
+		ch->ccw[10].count	= XID2_LENGTH;
+		ch->ccw[10].cda		= virt_to_phys(ch->rcvd_xid);
+
+		if (ch->xid_th == NULL)	{
+			printk(KERN_INFO "%s ch->xid_th=NULL\n", __FUNCTION__);
+					goto done;
+		}
+		ch->ccw[11].cmd_code	= CCW_CMD_WRITE;
+		ch->ccw[11].flags	= CCW_FLAG_SLI | CCW_FLAG_CC;
+		ch->ccw[11].count	= TH_HEADER_LENGTH;
+		ch->ccw[11].cda		= virt_to_phys(ch->xid_th);
+
+		if (ch->xid == NULL) {
+			printk(KERN_INFO "%s ch->xid=NULL\n", __FUNCTION__);
+					goto done;
+		}
+		ch->ccw[12].cmd_code	= CCW_CMD_WRITE;
+		ch->ccw[12].flags	= CCW_FLAG_SLI | CCW_FLAG_CC;
+		ch->ccw[12].count	= XID2_LENGTH;
+		ch->ccw[12].cda		= virt_to_phys(ch->xid);
+
+		if (ch->xid_id == NULL)	{
+			printk(KERN_INFO "%s ch->xid_id=NULL\n", __FUNCTION__);
+					goto done;
+		}
+		ch->ccw[13].cmd_code	= CCW_CMD_WRITE;
+		ch->ccw[13].cda		= virt_to_phys(ch->xid_id);
+
+	}
+	ch->ccw[13].flags	= CCW_FLAG_SLI | CCW_FLAG_CC;
+	ch->ccw[13].count	= 4;
+
+	ch->ccw[14].cmd_code	= CCW_CMD_NOOP;
+	ch->ccw[14].flags	= CCW_FLAG_SLI;
+	ch->ccw[14].count	= 0;
+	ch->ccw[14].cda		= 0;
+
+	if (do_debug_ccw)
+		ctcmpc_dumpit((char *)&ch->ccw[8], sizeof(struct ccw1) * 7);
+
+	ctcmpc_dumpit((char *)ch->xid_th, TH_HEADER_LENGTH);
+	ctcmpc_dumpit((char *)ch->xid, XID2_LENGTH);
+	ctcmpc_dumpit((char *)ch->xid_id, 4);
+	if (!in_irq()) {
+			 /* Such conditional locking is a known problem for
+			  * sparse because its static undeterministic.
+			  * Warnings should be ignored here. */
+		spin_lock_irqsave(get_ccwdev_lock(ch->cdev), saveflags);
+		gotlock = 1;
+	}
+
+	fsm_addtimer(&ch->timer, 5000 , CTC_EVENT_TIMER, ch);
+	rc = ccw_device_start(ch->cdev, &ch->ccw[8],
+				(unsigned long)ch, 0xff, 0);
+
+	if (gotlock)	/* see remark above about conditional locking */
+		spin_unlock_irqrestore(get_ccwdev_lock(ch->cdev), saveflags);
+
+	if (rc != 0) {
+		ctcm_pr_info("ctcmpc: %s() ch:%s IO failed \n",
+				__FUNCTION__, ch->id);
+		ctcm_ccw_check_rc(ch, rc,
+				(side == XSIDE) ? "x-side XID" : "y-side XID");
+	}
+
+done:
+	if (do_debug)
+		ctcm_pr_debug("ctcmpc exit : %s(): ch=0x%p id=%s\n",
+				__FUNCTION__, ch, ch->id);
+	return;
+
+}
+
+/*
+ * MPC Group Station FSM action
+ * CTCM_PROTO_MPC only
+ */
+static void mpc_action_xside_xid(fsm_instance *fsm, int event, void *arg)
+{
+	mpc_action_side_xid(fsm, arg, XSIDE);
+}
+
+/*
+ * MPC Group Station FSM action
+ * CTCM_PROTO_MPC only
+ */
+static void mpc_action_yside_xid(fsm_instance *fsm, int event, void *arg)
+{
+	mpc_action_side_xid(fsm, arg, YSIDE);
+}
+
+/*
+ * MPC Group Station FSM action
+ * CTCM_PROTO_MPC only
+ */
+static void mpc_action_doxid0(fsm_instance *fsm, int event, void *arg)
+{
+	struct channel	   *ch = arg;
+	struct ctcm_priv    *priv;
+	struct mpc_group   *grp     = NULL;
+	struct net_device *dev = NULL;
+
+	if (do_debug)
+		ctcm_pr_debug("ctcmpc enter: %s(): cp=%i ch=0x%p id=%s\n",
+			__FUNCTION__, smp_processor_id(), ch, ch->id);
+
+	if (ch == NULL) {
+		printk(KERN_WARNING "%s ch=NULL\n", __FUNCTION__);
+					goto done;
+	}
+
+	dev = ch->netdev;
+	if (dev == NULL) {
+		printk(KERN_WARNING "%s dev=NULL\n", __FUNCTION__);
+					goto done;
+	}
+
+	priv = dev->priv;
+	if (priv == NULL) {
+		printk(KERN_WARNING "%s priv=NULL\n", __FUNCTION__);
+					goto done;
+	}
+
+	grp = priv->mpcg;
+	if (grp == NULL) {
+		printk(KERN_WARNING "%s grp=NULL\n", __FUNCTION__);
+					goto done;
+	}
+
+	if (ch->xid == NULL) {
+		printk(KERN_WARNING "%s ch-xid=NULL\n", __FUNCTION__);
+					goto done;
+	}
+
+	fsm_newstate(ch->fsm, CH_XID0_INPROGRESS);
+
+	ch->xid->xid2_option =	XID2_0;
+
+	switch (fsm_getstate(grp->fsm)) {
+	case MPCG_STATE_XID2INITW:
+	case MPCG_STATE_XID2INITX:
+		ch->ccw[8].cmd_code = CCW_CMD_SENSE_CMD;
+		break;
+	case MPCG_STATE_XID0IOWAIT:
+	case MPCG_STATE_XID0IOWAIX:
+		ch->ccw[8].cmd_code = CCW_CMD_WRITE_CTL;
+		break;
+	}
+
+	fsm_event(grp->fsm, MPCG_EVENT_DOIO, ch);
+
+done:
+	if (do_debug)
+		ctcm_pr_debug("ctcmpc exit : %s(): ch=0x%p id=%s\n",
+			__FUNCTION__, ch, ch->id);
+	return;
+
+}
+
+/*
+ * MPC Group Station FSM action
+ * CTCM_PROTO_MPC only
+*/
+static void mpc_action_doxid7(fsm_instance *fsm, int event, void *arg)
+{
+	struct net_device *dev = arg;
+	struct ctcm_priv   *priv = NULL;
+	struct mpc_group  *grp = NULL;
+	int direction;
+	int rc = 0;
+	int send = 0;
+
+	ctcm_pr_debug("ctcmpc enter:	%s() \n", __FUNCTION__);
+
+	if (dev == NULL) {
+		printk(KERN_INFO "%s dev=NULL \n", __FUNCTION__);
+		rc = 1;
+					goto done;
+	}
+
+	priv = dev->priv;
+	if (priv == NULL) {
+		printk(KERN_INFO "%s priv=NULL \n", __FUNCTION__);
+		rc = 1;
+					goto done;
+	}
+
+	grp = priv->mpcg;
+	if (grp == NULL) {
+		printk(KERN_INFO "%s grp=NULL \n", __FUNCTION__);
+		rc = 1;
+					goto done;
+	}
+
+	for (direction = READ; direction <= WRITE; direction++)	{
+		struct channel *ch = priv->channel[direction];
+		struct xid2 *thisxid = ch->xid;
+		ch->xid_skb->data = ch->xid_skb_data;
+		skb_reset_tail_pointer(ch->xid_skb);
+		ch->xid_skb->len = 0;
+		thisxid->xid2_option = XID2_7;
+		send = 0;
+
+		/* xid7 phase 1 */
+		if (grp->outstanding_xid7_p2 > 0) {
+			if (grp->roll == YSIDE) {
+				if (fsm_getstate(ch->fsm) == CH_XID7_PENDING1) {
+					fsm_newstate(ch->fsm, CH_XID7_PENDING2);
+					ch->ccw[8].cmd_code = CCW_CMD_SENSE_CMD;
+					memcpy(skb_put(ch->xid_skb,
+							TH_HEADER_LENGTH),
+					       &thdummy, TH_HEADER_LENGTH);
+					send = 1;
+				}
+			} else if (fsm_getstate(ch->fsm) < CH_XID7_PENDING2) {
+					fsm_newstate(ch->fsm, CH_XID7_PENDING2);
+					ch->ccw[8].cmd_code = CCW_CMD_WRITE_CTL;
+					memcpy(skb_put(ch->xid_skb,
+						       TH_HEADER_LENGTH),
+					       &thnorm, TH_HEADER_LENGTH);
+					send = 1;
+			}
+		} else {
+			/* xid7 phase 2 */
+			if (grp->roll == YSIDE) {
+				if (fsm_getstate(ch->fsm) < CH_XID7_PENDING4) {
+					fsm_newstate(ch->fsm, CH_XID7_PENDING4);
+					memcpy(skb_put(ch->xid_skb,
+						       TH_HEADER_LENGTH),
+					       &thnorm, TH_HEADER_LENGTH);
+					ch->ccw[8].cmd_code = CCW_CMD_WRITE_CTL;
+					send = 1;
+				}
+			} else if (fsm_getstate(ch->fsm) == CH_XID7_PENDING3) {
+				fsm_newstate(ch->fsm, CH_XID7_PENDING4);
+				ch->ccw[8].cmd_code = CCW_CMD_SENSE_CMD;
+				memcpy(skb_put(ch->xid_skb, TH_HEADER_LENGTH),
+						&thdummy, TH_HEADER_LENGTH);
+				send = 1;
+			}
+		}
+
+		if (send)
+			fsm_event(grp->fsm, MPCG_EVENT_DOIO, ch);
+	}
+
+done:
+
+	if (rc != 0)
+		fsm_event(grp->fsm, MPCG_EVENT_INOP, dev);
+
+	return;
+}
+
+/*
+ * MPC Group Station FSM action
+ * CTCM_PROTO_MPC only
+ */
+static void mpc_action_rcvd_xid0(fsm_instance *fsm, int event, void *arg)
+{
+
+	struct mpcg_info   *mpcginfo   = arg;
+	struct channel	   *ch	       = mpcginfo->ch;
+	struct net_device  *dev        = ch->netdev;
+	struct ctcm_priv   *priv;
+	struct mpc_group   *grp;
+
+	if (do_debug)
+		ctcm_pr_debug("ctcmpc enter: %s(): cp=%i ch=0x%p id=%s\n",
+			__FUNCTION__, smp_processor_id(), ch, ch->id);
+
+	priv = dev->priv;
+	grp = priv->mpcg;
+
+	ctcm_pr_debug("ctcmpc in:%s() %s xid2:%i xid7:%i xidt_p2:%i \n",
+		       __FUNCTION__, ch->id,
+		       grp->outstanding_xid2,
+		       grp->outstanding_xid7,
+		       grp->outstanding_xid7_p2);
+
+	if (fsm_getstate(ch->fsm) < CH_XID7_PENDING)
+		fsm_newstate(ch->fsm, CH_XID7_PENDING);
+
+	grp->outstanding_xid2--;
+	grp->outstanding_xid7++;
+	grp->outstanding_xid7_p2++;
+
+	/* must change state before validating xid to */
+	/* properly handle interim interrupts received*/
+	switch (fsm_getstate(grp->fsm)) {
+	case MPCG_STATE_XID2INITW:
+		fsm_newstate(grp->fsm, MPCG_STATE_XID2INITX);
+		mpc_validate_xid(mpcginfo);
+		break;
+	case MPCG_STATE_XID0IOWAIT:
+		fsm_newstate(grp->fsm, MPCG_STATE_XID0IOWAIX);
+		mpc_validate_xid(mpcginfo);
+		break;
+	case MPCG_STATE_XID2INITX:
+		if (grp->outstanding_xid2 == 0) {
+			fsm_newstate(grp->fsm, MPCG_STATE_XID7INITW);
+			mpc_validate_xid(mpcginfo);
+			fsm_event(grp->fsm, MPCG_EVENT_XID2DONE, dev);
+		}
+		break;
+	case MPCG_STATE_XID0IOWAIX:
+		if (grp->outstanding_xid2 == 0) {
+			fsm_newstate(grp->fsm, MPCG_STATE_XID7INITI);
+			mpc_validate_xid(mpcginfo);
+			fsm_event(grp->fsm, MPCG_EVENT_XID2DONE, dev);
+		}
+		break;
+	}
+	kfree(mpcginfo);
+
+	if (do_debug) {
+		ctcm_pr_debug("ctcmpc:%s() %s xid2:%i xid7:%i xidt_p2:%i \n",
+				__FUNCTION__, ch->id,
+				grp->outstanding_xid2,
+				grp->outstanding_xid7,
+				grp->outstanding_xid7_p2);
+		ctcm_pr_debug("ctcmpc:%s() %s grpstate: %s chanstate: %s \n",
+				__FUNCTION__, ch->id,
+				fsm_getstate_str(grp->fsm),
+				fsm_getstate_str(ch->fsm));
+	}
+	return;
+
+}
+
+
+/*
+ * MPC Group Station FSM action
+ * CTCM_PROTO_MPC only
+ */
+static void mpc_action_rcvd_xid7(fsm_instance *fsm, int event, void *arg)
+{
+	struct mpcg_info   *mpcginfo   = arg;
+	struct channel	   *ch	       = mpcginfo->ch;
+	struct net_device  *dev        = ch->netdev;
+	struct ctcm_priv   *priv    = dev->priv;
+	struct mpc_group   *grp     = priv->mpcg;
+
+	if (do_debug) {
+		ctcm_pr_debug("ctcmpc enter: %s(): cp=%i ch=0x%p id=%s\n",
+				__FUNCTION__, smp_processor_id(), ch, ch->id);
+
+		ctcm_pr_debug("ctcmpc:  outstanding_xid7: %i, "
+				" outstanding_xid7_p2: %i\n",
+				grp->outstanding_xid7,
+				grp->outstanding_xid7_p2);
+	}
+
+	grp->outstanding_xid7--;
+	ch->xid_skb->data = ch->xid_skb_data;
+	skb_reset_tail_pointer(ch->xid_skb);
+	ch->xid_skb->len = 0;
+
+	switch (fsm_getstate(grp->fsm)) {
+	case MPCG_STATE_XID7INITI:
+		fsm_newstate(grp->fsm, MPCG_STATE_XID7INITZ);
+		mpc_validate_xid(mpcginfo);
+		break;
+	case MPCG_STATE_XID7INITW:
+		fsm_newstate(grp->fsm, MPCG_STATE_XID7INITX);
+		mpc_validate_xid(mpcginfo);
+		break;
+	case MPCG_STATE_XID7INITZ:
+	case MPCG_STATE_XID7INITX:
+		if (grp->outstanding_xid7 == 0) {
+			if (grp->outstanding_xid7_p2 > 0) {
+				grp->outstanding_xid7 =
+					grp->outstanding_xid7_p2;
+				grp->outstanding_xid7_p2 = 0;
+			} else
+				fsm_newstate(grp->fsm, MPCG_STATE_XID7INITF);
+
+			mpc_validate_xid(mpcginfo);
+			fsm_event(grp->fsm, MPCG_EVENT_XID7DONE, dev);
+			break;
+		}
+		mpc_validate_xid(mpcginfo);
+		break;
+	}
+
+	kfree(mpcginfo);
+
+	if (do_debug)
+		ctcm_pr_debug("ctcmpc exit: %s(): cp=%i ch=0x%p id=%s\n",
+			__FUNCTION__, smp_processor_id(), ch, ch->id);
+	return;
+
+}
+
+/*
+ * mpc_action helper of an MPC Group Station FSM action
+ * CTCM_PROTO_MPC only
+ */
+static int mpc_send_qllc_discontact(struct net_device *dev)
+{
+	int	rc	= 0;
+	__u32	new_len	= 0;
+	struct sk_buff   *skb;
+	struct qllc      *qllcptr;
+	struct ctcm_priv *priv;
+	struct mpc_group *grp;
+
+	ctcm_pr_debug("ctcmpc enter:	%s()\n", __FUNCTION__);
+
+	if (dev == NULL) {
+		printk(KERN_INFO "%s() dev=NULL\n", __FUNCTION__);
+		rc = 1;
+					goto done;
+	}
+
+	priv = dev->priv;
+	if (priv == NULL) {
+		printk(KERN_INFO "%s() priv=NULL\n", __FUNCTION__);
+		rc = 1;
+					goto done;
+	}
+
+	grp = priv->mpcg;
+	if (grp == NULL) {
+		printk(KERN_INFO "%s() grp=NULL\n", __FUNCTION__);
+		rc = 1;
+					goto done;
+	}
+	ctcm_pr_info("ctcmpc: %s() GROUP STATE: %s\n", __FUNCTION__,
+			mpcg_state_names[grp->saved_state]);
+
+	switch (grp->saved_state) {
+	/*
+	 * establish conn callback function is
+	 * preferred method to report failure
+	 */
+	case MPCG_STATE_XID0IOWAIT:
+	case MPCG_STATE_XID0IOWAIX:
+	case MPCG_STATE_XID7INITI:
+	case MPCG_STATE_XID7INITZ:
+	case MPCG_STATE_XID2INITW:
+	case MPCG_STATE_XID2INITX:
+	case MPCG_STATE_XID7INITW:
+	case MPCG_STATE_XID7INITX:
+		if (grp->estconnfunc) {
+			grp->estconnfunc(grp->port_num, -1, 0);
+			grp->estconnfunc = NULL;
+			break;
+		}
+	case MPCG_STATE_FLOWC:
+	case MPCG_STATE_READY:
+		grp->send_qllc_disc = 2;
+		new_len = sizeof(struct qllc);
+		qllcptr = kzalloc(new_len, gfp_type() | GFP_DMA);
+		if (qllcptr == NULL) {
+			printk(KERN_INFO
+			       "ctcmpc: Out of memory in %s()\n",
+			       dev->name);
+			rc = 1;
+				goto done;
+		}
+
+		qllcptr->qllc_address = 0xcc;
+		qllcptr->qllc_commands = 0x03;
+
+		skb = __dev_alloc_skb(new_len, GFP_ATOMIC);
+
+		if (skb == NULL) {
+			printk(KERN_INFO "%s Out of memory in mpc_send_qllc\n",
+			       dev->name);
+			priv->stats.rx_dropped++;
+			rc = 1;
+			kfree(qllcptr);
+				goto done;
+		}
+
+		memcpy(skb_put(skb, new_len), qllcptr, new_len);
+		kfree(qllcptr);
+
+		if (skb_headroom(skb) < 4) {
+			printk(KERN_INFO "ctcmpc: %s() Unable to"
+			       " build discontact for %s\n",
+			       __FUNCTION__, dev->name);
+			rc = 1;
+			dev_kfree_skb_any(skb);
+				goto done;
+		}
+
+		*((__u32 *)skb_push(skb, 4)) = priv->channel[READ]->pdu_seq;
+		priv->channel[READ]->pdu_seq++;
+		if (do_debug_data)
+			ctcm_pr_debug("ctcmpc: %s ToDCM_pdu_seq= %08x\n",
+				__FUNCTION__, priv->channel[READ]->pdu_seq);
+
+		/* receipt of CC03 resets anticipated sequence number on
+		      receiving side */
+		priv->channel[READ]->pdu_seq = 0x00;
+		skb_reset_mac_header(skb);
+		skb->dev = dev;
+		skb->protocol = htons(ETH_P_SNAP);
+		skb->ip_summed = CHECKSUM_UNNECESSARY;
+
+		ctcmpc_dumpit((char *)skb->data, (sizeof(struct qllc) + 4));
+
+		netif_rx(skb);
+		break;
+	default:
+		break;
+
+	}
+
+done:
+	ctcm_pr_debug("ctcmpc exit:  %s()\n", __FUNCTION__);
+	return rc;
+}
+/* --- This is the END my friend --- */
+
Index: linux-2.6-uschi/drivers/s390/net/ctcm_mpc.h
===================================================================
--- /dev/null
+++ linux-2.6-uschi/drivers/s390/net/ctcm_mpc.h
@@ -0,0 +1,239 @@
+/*
+ * drivers/s390/net/ctcm_mpc.h
+ *
+ * Copyright IBM Corp. 2007
+ * Authors:	Peter Tiedemann (ptiedem@de.ibm.com)
+ *
+ * 	MPC additions:
+ *		Belinda Thompson (belindat@us.ibm.com)
+ *		Andy Richter (richtera@us.ibm.com)
+ */
+
+#ifndef _CTC_MPC_H_
+#define _CTC_MPC_H_
+
+#include <linux/skbuff.h>
+#include "fsm.h"
+
+/*
+ * MPC external interface
+ * Note that ctc_mpc_xyz are called with a lock on ................
+ */
+
+/*  port_number is the mpc device 0, 1, 2 etc mpc2 is port_number 2 */
+
+/*  passive open  Just wait for XID2 exchange */
+extern int ctc_mpc_alloc_channel(int port,
+		void (*callback)(int port_num, int max_write_size));
+/* active open  Alloc then send XID2 */
+extern void ctc_mpc_establish_connectivity(int port,
+		void (*callback)(int port_num, int rc, int max_write_size));
+
+extern void ctc_mpc_dealloc_ch(int port);
+extern void ctc_mpc_flow_control(int port, int flowc);
+
+/*
+ * other MPC Group prototypes and structures
+ */
+
+#define ETH_P_SNA_DIX	0x80D5
+
+/*
+ * Declaration of an XID2
+ *
+ */
+#define ALLZEROS 0x0000000000000000
+
+#define XID_FM2		0x20
+#define XID2_0		0x00
+#define XID2_7		0x07
+#define XID2_WRITE_SIDE 0x04
+#define XID2_READ_SIDE	0x05
+
+struct xid2 {
+	__u8	xid2_type_id;
+	__u8	xid2_len;
+	__u32	xid2_adj_id;
+	__u8	xid2_rlen;
+	__u8	xid2_resv1;
+	__u8	xid2_flag1;
+	__u8	xid2_fmtt;
+	__u8	xid2_flag4;
+	__u16	xid2_resv2;
+	__u8	xid2_tgnum;
+	__u32	xid2_sender_id;
+	__u8	xid2_flag2;
+	__u8	xid2_option;
+	char  xid2_resv3[8];
+	__u16	xid2_resv4;
+	__u8	xid2_dlc_type;
+	__u16	xid2_resv5;
+	__u8	xid2_mpc_flag;
+	__u8	xid2_resv6;
+	__u16	xid2_buf_len;
+	char xid2_buffer[255 - (13 * sizeof(__u8) +
+				2 * sizeof(__u32) +
+				4 * sizeof(__u16) +
+				8 * sizeof(char))];
+} __attribute__ ((packed));
+
+#define XID2_LENGTH  (sizeof(struct xid2))
+
+struct th_header {
+	__u8	th_seg;
+	__u8	th_ch_flag;
+#define TH_HAS_PDU	0xf0
+#define TH_IS_XID	0x01
+#define TH_SWEEP_REQ	0xfe
+#define TH_SWEEP_RESP	0xff
+	__u8	th_blk_flag;
+#define TH_DATA_IS_XID	0x80
+#define TH_RETRY	0x40
+#define TH_DISCONTACT	0xc0
+#define TH_SEG_BLK	0x20
+#define TH_LAST_SEG	0x10
+#define TH_PDU_PART	0x08
+	__u8	th_is_xid;	/* is 0x01 if this is XID  */
+	__u32	th_seq_num;
+} __attribute__ ((packed));
+
+struct th_addon {
+	__u32	th_last_seq;
+	__u32	th_resvd;
+} __attribute__ ((packed));
+
+struct th_sweep {
+	struct th_header th;
+	struct th_addon sw;
+} __attribute__ ((packed));
+
+#define TH_HEADER_LENGTH (sizeof(struct th_header))
+#define TH_SWEEP_LENGTH (sizeof(struct th_sweep))
+
+#define PDU_LAST	0x80
+#define PDU_CNTL	0x40
+#define PDU_FIRST	0x20
+
+struct pdu {
+	__u32	pdu_offset;
+	__u8	pdu_flag;
+	__u8	pdu_proto;   /*  0x01 is APPN SNA  */
+	__u16	pdu_seq;
+} __attribute__ ((packed));
+
+#define PDU_HEADER_LENGTH  (sizeof(struct pdu))
+
+struct qllc {
+	__u8	qllc_address;
+#define QLLC_REQ	0xFF
+#define QLLC_RESP	0x00
+	__u8	qllc_commands;
+#define QLLC_DISCONNECT 0x53
+#define QLLC_UNSEQACK	0x73
+#define QLLC_SETMODE	0x93
+#define QLLC_EXCHID	0xBF
+} __attribute__ ((packed));
+
+
+/*
+ * Definition of one MPC group
+ */
+
+#define MAX_MPCGCHAN		10
+#define MPC_XID_TIMEOUT_VALUE	10000
+#define MPC_CHANNEL_ADD		0
+#define MPC_CHANNEL_REMOVE	1
+#define MPC_CHANNEL_ATTN	2
+#define XSIDE	1
+#define YSIDE	0
+
+struct mpcg_info {
+	struct sk_buff	*skb;
+	struct channel	*ch;
+	struct xid2	*xid;
+	struct th_sweep	*sweep;
+	struct th_header *th;
+};
+
+struct mpc_group {
+	struct tasklet_struct mpc_tasklet;
+	struct tasklet_struct mpc_tasklet2;
+	int	changed_side;
+	int	saved_state;
+	int	channels_terminating;
+	int	out_of_sequence;
+	int	flow_off_called;
+	int	port_num;
+	int	port_persist;
+	int	alloc_called;
+	__u32	xid2_adj_id;
+	__u8	xid2_tgnum;
+	__u32	xid2_sender_id;
+	int	num_channel_paths;
+	int	active_channels[2];
+	__u16	group_max_buflen;
+	int	outstanding_xid2;
+	int	outstanding_xid7;
+	int	outstanding_xid7_p2;
+	int	sweep_req_pend_num;
+	int	sweep_rsp_pend_num;
+	struct sk_buff	*xid_skb;
+	char		*xid_skb_data;
+	struct th_header *xid_th;
+	struct xid2	*xid;
+	char		*xid_id;
+	struct th_header *rcvd_xid_th;
+	struct sk_buff	*rcvd_xid_skb;
+	char		*rcvd_xid_data;
+	__u8		in_sweep;
+	__u8		roll;
+	struct xid2	*saved_xid2;
+	void 		(*allochanfunc)(int, int);
+	int		allocchan_callback_retries;
+	void 		(*estconnfunc)(int, int, int);
+	int		estconn_callback_retries;
+	int		estconn_called;
+	int		xidnogood;
+	int		send_qllc_disc;
+	fsm_timer	timer;
+	fsm_instance	*fsm; /* group xid fsm */
+};
+
+#ifdef DEBUGDATA
+void ctcmpc_dumpit(char *buf, int len);
+#else
+static inline void ctcmpc_dumpit(char *buf, int len)
+{
+}
+#endif
+
+#ifdef DEBUGDATA
+/*
+ * Dump header and first 16 bytes of an sk_buff for debugging purposes.
+ *
+ * skb	 The struct sk_buff to dump.
+ * offset Offset relative to skb-data, where to start the dump.
+ */
+void ctcmpc_dump_skb(struct sk_buff *skb, int offset);
+#else
+static inline void ctcmpc_dump_skb(struct sk_buff *skb, int offset)
+{}
+#endif
+
+static inline void ctcmpc_dump32(char *buf, int len)
+{
+	if (len < 32)
+		ctcmpc_dumpit(buf, len);
+	else
+		ctcmpc_dumpit(buf, 32);
+}
+
+int ctcmpc_open(struct net_device *);
+void ctcm_ccw_check_rc(struct channel *, int, char *);
+void mpc_group_ready(unsigned long adev);
+int mpc_channel_action(struct channel *ch, int direction, int action);
+void mpc_action_send_discontact(unsigned long thischan);
+void mpc_action_discontact(fsm_instance *fi, int event, void *arg);
+void ctcmpc_bh(unsigned long thischan);
+#endif
+/* --- This is the END my friend --- */
Index: linux-2.6-uschi/drivers/s390/net/ctcm_sysfs.c
===================================================================
--- /dev/null
+++ linux-2.6-uschi/drivers/s390/net/ctcm_sysfs.c
@@ -0,0 +1,210 @@
+/*
+ * drivers/s390/net/ctcm_sysfs.c
+ *
+ * Copyright IBM Corp. 2007, 2007
+ * Authors:	Peter Tiedemann (ptiedem@de.ibm.com)
+ *
+ */
+
+#undef DEBUG
+#undef DEBUGDATA
+#undef DEBUGCCW
+
+#include <linux/sysfs.h>
+#include "ctcm_main.h"
+
+/*
+ * sysfs attributes
+ */
+
+static ssize_t ctcm_buffer_show(struct device *dev,
+				struct device_attribute *attr, char *buf)
+{
+	struct ctcm_priv *priv = dev_get_drvdata(dev);
+
+	if (!priv)
+		return -ENODEV;
+	return sprintf(buf, "%d\n", priv->buffer_size);
+}
+
+static ssize_t ctcm_buffer_write(struct device *dev,
+		struct device_attribute *attr, const char *buf, size_t count)
+{
+	struct net_device *ndev;
+	int bs1;
+	struct ctcm_priv *priv = dev_get_drvdata(dev);
+
+	if (!(priv && priv->channel[READ] &&
+			(ndev = priv->channel[READ]->netdev))) {
+		CTCM_DBF_TEXT(SETUP, CTC_DBF_ERROR, "bfnondev");
+		return -ENODEV;
+	}
+
+	sscanf(buf, "%u", &bs1);
+	if (bs1 > CTCM_BUFSIZE_LIMIT)
+					goto einval;
+	if (bs1 < (576 + LL_HEADER_LENGTH + 2))
+					goto einval;
+	priv->buffer_size = bs1;	/* just to overwrite the default */
+
+	if ((ndev->flags & IFF_RUNNING) &&
+	    (bs1 < (ndev->mtu + LL_HEADER_LENGTH + 2)))
+					goto einval;
+
+	priv->channel[READ]->max_bufsize = bs1;
+	priv->channel[WRITE]->max_bufsize = bs1;
+	if (!(ndev->flags & IFF_RUNNING))
+		ndev->mtu = bs1 - LL_HEADER_LENGTH - 2;
+	priv->channel[READ]->flags |= CHANNEL_FLAGS_BUFSIZE_CHANGED;
+	priv->channel[WRITE]->flags |= CHANNEL_FLAGS_BUFSIZE_CHANGED;
+
+	CTCM_DBF_DEV(SETUP, ndev, buf);
+	return count;
+
+einval:
+	CTCM_DBF_DEV(SETUP, ndev, "buff_err");
+	return -EINVAL;
+}
+
+static void ctcm_print_statistics(struct ctcm_priv *priv)
+{
+	char *sbuf;
+	char *p;
+
+	if (!priv)
+		return;
+	sbuf = kmalloc(2048, GFP_KERNEL);
+	if (sbuf == NULL)
+		return;
+	p = sbuf;
+
+	p += sprintf(p, "  Device FSM state: %s\n",
+		     fsm_getstate_str(priv->fsm));
+	p += sprintf(p, "  RX channel FSM state: %s\n",
+		     fsm_getstate_str(priv->channel[READ]->fsm));
+	p += sprintf(p, "  TX channel FSM state: %s\n",
+		     fsm_getstate_str(priv->channel[WRITE]->fsm));
+	p += sprintf(p, "  Max. TX buffer used: %ld\n",
+		     priv->channel[WRITE]->prof.maxmulti);
+	p += sprintf(p, "  Max. chained SKBs: %ld\n",
+		     priv->channel[WRITE]->prof.maxcqueue);
+	p += sprintf(p, "  TX single write ops: %ld\n",
+		     priv->channel[WRITE]->prof.doios_single);
+	p += sprintf(p, "  TX multi write ops: %ld\n",
+		     priv->channel[WRITE]->prof.doios_multi);
+	p += sprintf(p, "  Netto bytes written: %ld\n",
+		     priv->channel[WRITE]->prof.txlen);
+	p += sprintf(p, "  Max. TX IO-time: %ld\n",
+		     priv->channel[WRITE]->prof.tx_time);
+
+	printk(KERN_INFO "Statistics for %s:\n%s",
+				priv->channel[WRITE]->netdev->name, sbuf);
+	kfree(sbuf);
+	return;
+}
+
+static ssize_t stats_show(struct device *dev,
+				struct device_attribute *attr, char *buf)
+{
+	struct ctcm_priv *priv = dev_get_drvdata(dev);
+	if (!priv)
+		return -ENODEV;
+	ctcm_print_statistics(priv);
+	return sprintf(buf, "0\n");
+}
+
+static ssize_t stats_write(struct device *dev, struct device_attribute *attr,
+				const char *buf, size_t count)
+{
+	struct ctcm_priv *priv = dev_get_drvdata(dev);
+	if (!priv)
+		return -ENODEV;
+	/* Reset statistics */
+	memset(&priv->channel[WRITE]->prof, 0,
+				sizeof(priv->channel[WRITE]->prof));
+	return count;
+}
+
+static ssize_t ctcm_proto_show(struct device *dev,
+				struct device_attribute *attr, char *buf)
+{
+	struct ctcm_priv *priv = dev_get_drvdata(dev);
+	if (!priv)
+		return -ENODEV;
+
+	return sprintf(buf, "%d\n", priv->protocol);
+}
+
+static ssize_t ctcm_proto_store(struct device *dev,
+		struct device_attribute *attr, const char *buf, size_t count)
+{
+	int value;
+	struct ctcm_priv *priv = dev_get_drvdata(dev);
+
+	if (!priv)
+		return -ENODEV;
+	sscanf(buf, "%u", &value);
+	if (!((value == CTCM_PROTO_S390)  ||
+	      (value == CTCM_PROTO_LINUX) ||
+	      (value == CTCM_PROTO_MPC) ||
+	      (value == CTCM_PROTO_OS390)))
+		return -EINVAL;
+	priv->protocol = value;
+	CTCM_DBF_DEV(SETUP, dev, buf);
+
+	return count;
+}
+
+static ssize_t ctcm_type_show(struct device *dev,
+				struct device_attribute *attr, char *buf)
+{
+	struct ccwgroup_device *cgdev;
+
+	cgdev = to_ccwgroupdev(dev);
+	if (!cgdev)
+		return -ENODEV;
+
+	return sprintf(buf, "%s\n",
+			cu3088_type[cgdev->cdev[0]->id.driver_info]);
+}
+
+static DEVICE_ATTR(buffer, 0644, ctcm_buffer_show, ctcm_buffer_write);
+static DEVICE_ATTR(protocol, 0644, ctcm_proto_show, ctcm_proto_store);
+static DEVICE_ATTR(type, 0444, ctcm_type_show, NULL);
+static DEVICE_ATTR(stats, 0644, stats_show, stats_write);
+
+static struct attribute *ctcm_attr[] = {
+	&dev_attr_protocol.attr,
+	&dev_attr_type.attr,
+	&dev_attr_buffer.attr,
+	NULL,
+};
+
+static struct attribute_group ctcm_attr_group = {
+	.attrs = ctcm_attr,
+};
+
+int ctcm_add_attributes(struct device *dev)
+{
+	int rc;
+
+	rc = device_create_file(dev, &dev_attr_stats);
+
+	return rc;
+}
+
+void ctcm_remove_attributes(struct device *dev)
+{
+	device_remove_file(dev, &dev_attr_stats);
+}
+
+int ctcm_add_files(struct device *dev)
+{
+	return sysfs_create_group(&dev->kobj, &ctcm_attr_group);
+}
+
+void ctcm_remove_files(struct device *dev)
+{
+	sysfs_remove_group(&dev->kobj, &ctcm_attr_group);
+}
+
Index: linux-2.6-uschi/drivers/s390/net/ctcm_fsms.c
===================================================================
--- /dev/null
+++ linux-2.6-uschi/drivers/s390/net/ctcm_fsms.c
@@ -0,0 +1,2347 @@
+/*
+ * drivers/s390/net/ctcm_fsms.c
+ *
+ * Copyright IBM Corp. 2001, 2007
+ * Authors:	Fritz Elfert (felfert@millenux.com)
+ * 		Peter Tiedemann (ptiedem@de.ibm.com)
+ *	MPC additions :
+ *		Belinda Thompson (belindat@us.ibm.com)
+ *		Andy Richter (richtera@us.ibm.com)
+ */
+
+#undef DEBUG
+#undef DEBUGDATA
+#undef DEBUGCCW
+
+#include <linux/module.h>
+#include <linux/init.h>
+#include <linux/kernel.h>
+#include <linux/slab.h>
+#include <linux/errno.h>
+#include <linux/types.h>
+#include <linux/interrupt.h>
+#include <linux/timer.h>
+#include <linux/bitops.h>
+
+#include <linux/signal.h>
+#include <linux/string.h>
+
+#include <linux/ip.h>
+#include <linux/if_arp.h>
+#include <linux/tcp.h>
+#include <linux/skbuff.h>
+#include <linux/ctype.h>
+#include <net/dst.h>
+
+#include <linux/io.h>
+#include <asm/ccwdev.h>
+#include <asm/ccwgroup.h>
+#include <linux/uaccess.h>
+
+#include <asm/idals.h>
+
+#include "fsm.h"
+#include "cu3088.h"
+
+#include "ctcm_dbug.h"
+#include "ctcm_main.h"
+#include "ctcm_fsms.h"
+
+const char *dev_state_names[] = {
+	[DEV_STATE_STOPPED]		= "Stopped",
+	[DEV_STATE_STARTWAIT_RXTX]	= "StartWait RXTX",
+	[DEV_STATE_STARTWAIT_RX]	= "StartWait RX",
+	[DEV_STATE_STARTWAIT_TX]	= "StartWait TX",
+	[DEV_STATE_STOPWAIT_RXTX]	= "StopWait RXTX",
+	[DEV_STATE_STOPWAIT_RX]		= "StopWait RX",
+	[DEV_STATE_STOPWAIT_TX]		= "StopWait TX",
+	[DEV_STATE_RUNNING]		= "Running",
+};
+
+const char *dev_event_names[] = {
+	[DEV_EVENT_START]	= "Start",
+	[DEV_EVENT_STOP]	= "Stop",
+	[DEV_EVENT_RXUP]	= "RX up",
+	[DEV_EVENT_TXUP]	= "TX up",
+	[DEV_EVENT_RXDOWN]	= "RX down",
+	[DEV_EVENT_TXDOWN]	= "TX down",
+	[DEV_EVENT_RESTART]	= "Restart",
+};
+
+const char *ctc_ch_event_names[] = {
+	[CTC_EVENT_IO_SUCCESS]	= "ccw_device success",
+	[CTC_EVENT_IO_EBUSY]	= "ccw_device busy",
+	[CTC_EVENT_IO_ENODEV]	= "ccw_device enodev",
+	[CTC_EVENT_IO_UNKNOWN]	= "ccw_device unknown",
+	[CTC_EVENT_ATTNBUSY]	= "Status ATTN & BUSY",
+	[CTC_EVENT_ATTN]	= "Status ATTN",
+	[CTC_EVENT_BUSY]	= "Status BUSY",
+	[CTC_EVENT_UC_RCRESET]	= "Unit check remote reset",
+	[CTC_EVENT_UC_RSRESET]	= "Unit check remote system reset",
+	[CTC_EVENT_UC_TXTIMEOUT] = "Unit check TX timeout",
+	[CTC_EVENT_UC_TXPARITY]	= "Unit check TX parity",
+	[CTC_EVENT_UC_HWFAIL]	= "Unit check Hardware failure",
+	[CTC_EVENT_UC_RXPARITY]	= "Unit check RX parity",
+	[CTC_EVENT_UC_ZERO]	= "Unit check ZERO",
+	[CTC_EVENT_UC_UNKNOWN]	= "Unit check Unknown",
+	[CTC_EVENT_SC_UNKNOWN]	= "SubChannel check Unknown",
+	[CTC_EVENT_MC_FAIL]	= "Machine check failure",
+	[CTC_EVENT_MC_GOOD]	= "Machine check operational",
+	[CTC_EVENT_IRQ]		= "IRQ normal",
+	[CTC_EVENT_FINSTAT]	= "IRQ final",
+	[CTC_EVENT_TIMER]	= "Timer",
+	[CTC_EVENT_START]	= "Start",
+	[CTC_EVENT_STOP]	= "Stop",
+	/*
+	* additional MPC events
+	*/
+	[CTC_EVENT_SEND_XID]	= "XID Exchange",
+	[CTC_EVENT_RSWEEP_TIMER] = "MPC Group Sweep Timer",
+};
+
+const char *ctc_ch_state_names[] = {
+	[CTC_STATE_IDLE]	= "Idle",
+	[CTC_STATE_STOPPED]	= "Stopped",
+	[CTC_STATE_STARTWAIT]	= "StartWait",
+	[CTC_STATE_STARTRETRY]	= "StartRetry",
+	[CTC_STATE_SETUPWAIT]	= "SetupWait",
+	[CTC_STATE_RXINIT]	= "RX init",
+	[CTC_STATE_TXINIT]	= "TX init",
+	[CTC_STATE_RX]		= "RX",
+	[CTC_STATE_TX]		= "TX",
+	[CTC_STATE_RXIDLE]	= "RX idle",
+	[CTC_STATE_TXIDLE]	= "TX idle",
+	[CTC_STATE_RXERR]	= "RX error",
+	[CTC_STATE_TXERR]	= "TX error",
+	[CTC_STATE_TERM]	= "Terminating",
+	[CTC_STATE_DTERM]	= "Restarting",
+	[CTC_STATE_NOTOP]	= "Not operational",
+	/*
+	* additional MPC states
+	*/
+	[CH_XID0_PENDING]	= "Pending XID0 Start",
+	[CH_XID0_INPROGRESS]	= "In XID0 Negotiations ",
+	[CH_XID7_PENDING]	= "Pending XID7 P1 Start",
+	[CH_XID7_PENDING1]	= "Active XID7 P1 Exchange ",
+	[CH_XID7_PENDING2]	= "Pending XID7 P2 Start ",
+	[CH_XID7_PENDING3]	= "Active XID7 P2 Exchange ",
+	[CH_XID7_PENDING4]	= "XID7 Complete - Pending READY ",
+};
+
+static void ctcm_action_nop(fsm_instance *fi, int event, void *arg);
+
+/*
+ * ----- static ctcm actions for channel statemachine -----
+ *
+*/
+static void chx_txdone(fsm_instance *fi, int event, void *arg);
+static void chx_rx(fsm_instance *fi, int event, void *arg);
+static void chx_rxidle(fsm_instance *fi, int event, void *arg);
+static void chx_firstio(fsm_instance *fi, int event, void *arg);
+static void ctcm_chx_setmode(fsm_instance *fi, int event, void *arg);
+static void ctcm_chx_start(fsm_instance *fi, int event, void *arg);
+static void ctcm_chx_haltio(fsm_instance *fi, int event, void *arg);
+static void ctcm_chx_stopped(fsm_instance *fi, int event, void *arg);
+static void ctcm_chx_stop(fsm_instance *fi, int event, void *arg);
+static void ctcm_chx_fail(fsm_instance *fi, int event, void *arg);
+static void ctcm_chx_setuperr(fsm_instance *fi, int event, void *arg);
+static void ctcm_chx_restart(fsm_instance *fi, int event, void *arg);
+static void ctcm_chx_rxiniterr(fsm_instance *fi, int event, void *arg);
+static void ctcm_chx_rxinitfail(fsm_instance *fi, int event, void *arg);
+static void ctcm_chx_rxdisc(fsm_instance *fi, int event, void *arg);
+static void ctcm_chx_txiniterr(fsm_instance *fi, int event, void *arg);
+static void ctcm_chx_txretry(fsm_instance *fi, int event, void *arg);
+static void ctcm_chx_iofatal(fsm_instance *fi, int event, void *arg);
+
+/*
+ * ----- static ctcmpc actions for ctcmpc channel statemachine -----
+ *
+*/
+static void ctcmpc_chx_txdone(fsm_instance *fi, int event, void *arg);
+static void ctcmpc_chx_rx(fsm_instance *fi, int event, void *arg);
+static void ctcmpc_chx_firstio(fsm_instance *fi, int event, void *arg);
+/* shared :
+static void ctcm_chx_setmode(fsm_instance *fi, int event, void *arg);
+static void ctcm_chx_start(fsm_instance *fi, int event, void *arg);
+static void ctcm_chx_haltio(fsm_instance *fi, int event, void *arg);
+static void ctcm_chx_stopped(fsm_instance *fi, int event, void *arg);
+static void ctcm_chx_stop(fsm_instance *fi, int event, void *arg);
+static void ctcm_chx_fail(fsm_instance *fi, int event, void *arg);
+static void ctcm_chx_setuperr(fsm_instance *fi, int event, void *arg);
+static void ctcm_chx_restart(fsm_instance *fi, int event, void *arg);
+static void ctcm_chx_rxiniterr(fsm_instance *fi, int event, void *arg);
+static void ctcm_chx_rxinitfail(fsm_instance *fi, int event, void *arg);
+static void ctcm_chx_rxdisc(fsm_instance *fi, int event, void *arg);
+static void ctcm_chx_txiniterr(fsm_instance *fi, int event, void *arg);
+static void ctcm_chx_txretry(fsm_instance *fi, int event, void *arg);
+static void ctcm_chx_iofatal(fsm_instance *fi, int event, void *arg);
+*/
+static void ctcmpc_chx_attn(fsm_instance *fsm, int event, void *arg);
+static void ctcmpc_chx_attnbusy(fsm_instance *, int, void *);
+static void ctcmpc_chx_resend(fsm_instance *, int, void *);
+static void ctcmpc_chx_send_sweep(fsm_instance *fsm, int event, void *arg);
+
+/**
+ * Check return code of a preceeding ccw_device call, halt_IO etc...
+ *
+ * ch	:	The channel, the error belongs to.
+ * Returns the error code (!= 0) to inspect.
+ */
+void ctcm_ccw_check_rc(struct channel *ch, int rc, char *msg)
+{
+	CTCM_DBF_TEXT_(ERROR, CTC_DBF_ERROR,
+			"ccw error %s (%s): %04x\n", ch->id, msg, rc);
+	switch (rc) {
+	case -EBUSY:
+		ctcm_pr_warn("%s (%s): Busy !\n", ch->id, msg);
+		fsm_event(ch->fsm, CTC_EVENT_IO_EBUSY, ch);
+		break;
+	case -ENODEV:
+		ctcm_pr_emerg("%s (%s): Invalid device called for IO\n",
+			     ch->id, msg);
+		fsm_event(ch->fsm, CTC_EVENT_IO_ENODEV, ch);
+		break;
+	default:
+		ctcm_pr_emerg("%s (%s): Unknown error in do_IO %04x\n",
+			     ch->id, msg, rc);
+		fsm_event(ch->fsm, CTC_EVENT_IO_UNKNOWN, ch);
+	}
+}
+
+void ctcm_purge_skb_queue(struct sk_buff_head *q)
+{
+	struct sk_buff *skb;
+
+	CTCM_DBF_TEXT(TRACE, 3, __FUNCTION__);
+
+	while ((skb = skb_dequeue(q))) {
+		atomic_dec(&skb->users);
+		dev_kfree_skb_any(skb);
+	}
+}
+
+/**
+ * NOP action for statemachines
+ */
+static void ctcm_action_nop(fsm_instance *fi, int event, void *arg)
+{
+}
+
+/*
+ * Actions for channel - statemachines.
+ */
+
+/**
+ * Normal data has been send. Free the corresponding
+ * skb (it's in io_queue), reset dev->tbusy and
+ * revert to idle state.
+ *
+ * fi		An instance of a channel statemachine.
+ * event	The event, just happened.
+ * arg		Generic pointer, casted from channel * upon call.
+ */
+static void chx_txdone(fsm_instance *fi, int event, void *arg)
+{
+	struct channel *ch = arg;
+	struct net_device *dev = ch->netdev;
+	struct ctcm_priv *priv = dev->priv;
+	struct sk_buff *skb;
+	int first = 1;
+	int i;
+	unsigned long duration;
+	struct timespec done_stamp = current_kernel_time(); /* xtime */
+
+	duration =
+	    (done_stamp.tv_sec - ch->prof.send_stamp.tv_sec) * 1000000 +
+	    (done_stamp.tv_nsec - ch->prof.send_stamp.tv_nsec) / 1000;
+	if (duration > ch->prof.tx_time)
+		ch->prof.tx_time = duration;
+
+	if (ch->irb->scsw.count != 0)
+		ctcm_pr_debug("%s: TX not complete, remaining %d bytes\n",
+			     dev->name, ch->irb->scsw.count);
+	fsm_deltimer(&ch->timer);
+	while ((skb = skb_dequeue(&ch->io_queue))) {
+		priv->stats.tx_packets++;
+		priv->stats.tx_bytes += skb->len - LL_HEADER_LENGTH;
+		if (first) {
+			priv->stats.tx_bytes += 2;
+			first = 0;
+		}
+		atomic_dec(&skb->users);
+		dev_kfree_skb_irq(skb);
+	}
+	spin_lock(&ch->collect_lock);
+	clear_normalized_cda(&ch->ccw[4]);
+	if (ch->collect_len > 0) {
+		int rc;
+
+		if (ctcm_checkalloc_buffer(ch)) {
+			spin_unlock(&ch->collect_lock);
+			return;
+		}
+		ch->trans_skb->data = ch->trans_skb_data;
+		skb_reset_tail_pointer(ch->trans_skb);
+		ch->trans_skb->len = 0;
+		if (ch->prof.maxmulti < (ch->collect_len + 2))
+			ch->prof.maxmulti = ch->collect_len + 2;
+		if (ch->prof.maxcqueue < skb_queue_len(&ch->collect_queue))
+			ch->prof.maxcqueue = skb_queue_len(&ch->collect_queue);
+		*((__u16 *)skb_put(ch->trans_skb, 2)) = ch->collect_len + 2;
+		i = 0;
+		while ((skb = skb_dequeue(&ch->collect_queue))) {
+			skb_copy_from_linear_data(skb,
+				skb_put(ch->trans_skb, skb->len), skb->len);
+			priv->stats.tx_packets++;
+			priv->stats.tx_bytes += skb->len - LL_HEADER_LENGTH;
+			atomic_dec(&skb->users);
+			dev_kfree_skb_irq(skb);
+			i++;
+		}
+		ch->collect_len = 0;
+		spin_unlock(&ch->collect_lock);
+		ch->ccw[1].count = ch->trans_skb->len;
+		fsm_addtimer(&ch->timer, CTCM_TIME_5_SEC, CTC_EVENT_TIMER, ch);
+		ch->prof.send_stamp = current_kernel_time(); /* xtime */
+		rc = ccw_device_start(ch->cdev, &ch->ccw[0],
+						(unsigned long)ch, 0xff, 0);
+		ch->prof.doios_multi++;
+		if (rc != 0) {
+			priv->stats.tx_dropped += i;
+			priv->stats.tx_errors += i;
+			fsm_deltimer(&ch->timer);
+			ctcm_ccw_check_rc(ch, rc, "chained TX");
+		}
+	} else {
+		spin_unlock(&ch->collect_lock);
+		fsm_newstate(fi, CTC_STATE_TXIDLE);
+	}
+	ctcm_clear_busy_do(dev);
+}
+
+/**
+ * Initial data is sent.
+ * Notify device statemachine that we are up and
+ * running.
+ *
+ * fi		An instance of a channel statemachine.
+ * event	The event, just happened.
+ * arg		Generic pointer, casted from channel * upon call.
+ */
+void ctcm_chx_txidle(fsm_instance *fi, int event, void *arg)
+{
+	struct channel *ch = arg;
+	struct net_device *dev = ch->netdev;
+	struct ctcm_priv *priv = dev->priv;
+
+	CTCM_DBF_TEXT(TRACE, 6, __FUNCTION__);
+	fsm_deltimer(&ch->timer);
+	fsm_newstate(fi, CTC_STATE_TXIDLE);
+	fsm_event(priv->fsm, DEV_EVENT_TXUP, ch->netdev);
+}
+
+/**
+ * Got normal data, check for sanity, queue it up, allocate new buffer
+ * trigger bottom half, and initiate next read.
+ *
+ * fi		An instance of a channel statemachine.
+ * event	The event, just happened.
+ * arg		Generic pointer, casted from channel * upon call.
+ */
+static void chx_rx(fsm_instance *fi, int event, void *arg)
+{
+	struct channel *ch = arg;
+	struct net_device *dev = ch->netdev;
+	struct ctcm_priv *priv = dev->priv;
+	int len = ch->max_bufsize - ch->irb->scsw.count;
+	struct sk_buff *skb = ch->trans_skb;
+	__u16 block_len = *((__u16 *)skb->data);
+	int check_len;
+	int rc;
+
+	fsm_deltimer(&ch->timer);
+	if (len < 8) {
+		ctcm_pr_debug("%s: got packet with length %d < 8\n",
+			     dev->name, len);
+		priv->stats.rx_dropped++;
+		priv->stats.rx_length_errors++;
+						goto again;
+	}
+	if (len > ch->max_bufsize) {
+		ctcm_pr_debug("%s: got packet with length %d > %d\n",
+			     dev->name, len, ch->max_bufsize);
+		priv->stats.rx_dropped++;
+		priv->stats.rx_length_errors++;
+						goto again;
+	}
+
+	/*
+	 * VM TCP seems to have a bug sending 2 trailing bytes of garbage.
+	 */
+	switch (ch->protocol) {
+	case CTCM_PROTO_S390:
+	case CTCM_PROTO_OS390:
+		check_len = block_len + 2;
+		break;
+	default:
+		check_len = block_len;
+		break;
+	}
+	if ((len < block_len) || (len > check_len)) {
+		ctcm_pr_debug("%s: got block length %d != rx length %d\n",
+			     dev->name, block_len, len);
+		if (do_debug)
+			ctcmpc_dump_skb(skb, 0);
+
+		*((__u16 *)skb->data) = len;
+		priv->stats.rx_dropped++;
+		priv->stats.rx_length_errors++;
+						goto again;
+	}
+	block_len -= 2;
+	if (block_len > 0) {
+		*((__u16 *)skb->data) = block_len;
+		ctcm_unpack_skb(ch, skb);
+	}
+ again:
+	skb->data = ch->trans_skb_data;
+	skb_reset_tail_pointer(skb);
+	skb->len = 0;
+	if (ctcm_checkalloc_buffer(ch))
+		return;
+	ch->ccw[1].count = ch->max_bufsize;
+	rc = ccw_device_start(ch->cdev, &ch->ccw[0],
+					(unsigned long)ch, 0xff, 0);
+	if (rc != 0)
+		ctcm_ccw_check_rc(ch, rc, "normal RX");
+}
+
+/**
+ * Initialize connection by sending a __u16 of value 0.
+ *
+ * fi		An instance of a channel statemachine.
+ * event	The event, just happened.
+ * arg		Generic pointer, casted from channel * upon call.
+ */
+static void chx_firstio(fsm_instance *fi, int event, void *arg)
+{
+	struct channel *ch = arg;
+	int rc;
+
+	CTCM_DBF_TEXT(TRACE, 6, __FUNCTION__);
+
+	if (fsm_getstate(fi) == CTC_STATE_TXIDLE)
+		ctcm_pr_debug("%s: remote side issued READ?, init.\n", ch->id);
+	fsm_deltimer(&ch->timer);
+	if (ctcm_checkalloc_buffer(ch))
+		return;
+	if ((fsm_getstate(fi) == CTC_STATE_SETUPWAIT) &&
+	    (ch->protocol == CTCM_PROTO_OS390)) {
+		/* OS/390 resp. z/OS */
+		if (CHANNEL_DIRECTION(ch->flags) == READ) {
+			*((__u16 *)ch->trans_skb->data) = CTCM_INITIAL_BLOCKLEN;
+			fsm_addtimer(&ch->timer, CTCM_TIME_5_SEC,
+				     CTC_EVENT_TIMER, ch);
+			chx_rxidle(fi, event, arg);
+		} else {
+			struct net_device *dev = ch->netdev;
+			struct ctcm_priv *priv = dev->priv;
+			fsm_newstate(fi, CTC_STATE_TXIDLE);
+			fsm_event(priv->fsm, DEV_EVENT_TXUP, dev);
+		}
+		return;
+	}
+
+	/*
+	 * Don't setup a timer for receiving the initial RX frame
+	 * if in compatibility mode, since VM TCP delays the initial
+	 * frame until it has some data to send.
+	 */
+	if ((CHANNEL_DIRECTION(ch->flags) == WRITE) ||
+	    (ch->protocol != CTCM_PROTO_S390))
+		fsm_addtimer(&ch->timer, CTCM_TIME_5_SEC, CTC_EVENT_TIMER, ch);
+
+	*((__u16 *)ch->trans_skb->data) = CTCM_INITIAL_BLOCKLEN;
+	ch->ccw[1].count = 2;	/* Transfer only length */
+
+	fsm_newstate(fi, (CHANNEL_DIRECTION(ch->flags) == READ)
+		     ? CTC_STATE_RXINIT : CTC_STATE_TXINIT);
+	rc = ccw_device_start(ch->cdev, &ch->ccw[0],
+					(unsigned long)ch, 0xff, 0);
+	if (rc != 0) {
+		fsm_deltimer(&ch->timer);
+		fsm_newstate(fi, CTC_STATE_SETUPWAIT);
+		ctcm_ccw_check_rc(ch, rc, "init IO");
+	}
+	/*
+	 * If in compatibility mode since we don't setup a timer, we
+	 * also signal RX channel up immediately. This enables us
+	 * to send packets early which in turn usually triggers some
+	 * reply from VM TCP which brings up the RX channel to it's
+	 * final state.
+	 */
+	if ((CHANNEL_DIRECTION(ch->flags) == READ) &&
+	    (ch->protocol == CTCM_PROTO_S390)) {
+		struct net_device *dev = ch->netdev;
+		struct ctcm_priv *priv = dev->priv;
+		fsm_event(priv->fsm, DEV_EVENT_RXUP, dev);
+	}
+}
+
+/**
+ * Got initial data, check it. If OK,
+ * notify device statemachine that we are up and
+ * running.
+ *
+ * fi		An instance of a channel statemachine.
+ * event	The event, just happened.
+ * arg		Generic pointer, casted from channel * upon call.
+ */
+static void chx_rxidle(fsm_instance *fi, int event, void *arg)
+{
+	struct channel *ch = arg;
+	struct net_device *dev = ch->netdev;
+	struct ctcm_priv *priv = dev->priv;
+	__u16 buflen;
+	int rc;
+
+	CTCM_DBF_TEXT(TRACE, 6, __FUNCTION__);
+	fsm_deltimer(&ch->timer);
+	buflen = *((__u16 *)ch->trans_skb->data);
+	if (do_debug)
+		ctcm_pr_debug("%s: Initial RX count %d\n", dev->name, buflen);
+
+	if (buflen >= CTCM_INITIAL_BLOCKLEN) {
+		if (ctcm_checkalloc_buffer(ch))
+			return;
+		ch->ccw[1].count = ch->max_bufsize;
+		fsm_newstate(fi, CTC_STATE_RXIDLE);
+		rc = ccw_device_start(ch->cdev, &ch->ccw[0],
+						(unsigned long)ch, 0xff, 0);
+		if (rc != 0) {
+			fsm_newstate(fi, CTC_STATE_RXINIT);
+			ctcm_ccw_check_rc(ch, rc, "initial RX");
+		} else
+			fsm_event(priv->fsm, DEV_EVENT_RXUP, dev);
+	} else {
+		if (do_debug)
+			ctcm_pr_debug("%s: Initial RX count %d not %d\n",
+				dev->name, buflen, CTCM_INITIAL_BLOCKLEN);
+		chx_firstio(fi, event, arg);
+	}
+}
+
+/**
+ * Set channel into extended mode.
+ *
+ * fi		An instance of a channel statemachine.
+ * event	The event, just happened.
+ * arg		Generic pointer, casted from channel * upon call.
+ */
+static void ctcm_chx_setmode(fsm_instance *fi, int event, void *arg)
+{
+	struct channel *ch = arg;
+	int rc;
+	unsigned long saveflags = 0;
+	int timeout = CTCM_TIME_5_SEC;
+
+	fsm_deltimer(&ch->timer);
+	if (IS_MPC(ch)) {
+		timeout = 1500;
+		if (do_debug)
+			ctcm_pr_debug("ctcm enter: %s(): cp=%i ch=0x%p id=%s\n",
+				__FUNCTION__, smp_processor_id(), ch, ch->id);
+	}
+	fsm_addtimer(&ch->timer, timeout, CTC_EVENT_TIMER, ch);
+	fsm_newstate(fi, CTC_STATE_SETUPWAIT);
+	if (do_debug_ccw && IS_MPC(ch))
+		ctcmpc_dumpit((char *)&ch->ccw[6], sizeof(struct ccw1) * 2);
+
+	if (event == CTC_EVENT_TIMER)	/* only for timer not yet locked */
+		spin_lock_irqsave(get_ccwdev_lock(ch->cdev), saveflags);
+			/* Such conditional locking is undeterministic in
+			 * static view. => ignore sparse warnings here. */
+
+	rc = ccw_device_start(ch->cdev, &ch->ccw[6],
+					(unsigned long)ch, 0xff, 0);
+	if (event == CTC_EVENT_TIMER)	/* see above comments */
+		spin_unlock_irqrestore(get_ccwdev_lock(ch->cdev), saveflags);
+	if (rc != 0) {
+		fsm_deltimer(&ch->timer);
+		fsm_newstate(fi, CTC_STATE_STARTWAIT);
+		ctcm_ccw_check_rc(ch, rc, "set Mode");
+	} else
+		ch->retry = 0;
+}
+
+/**
+ * Setup channel.
+ *
+ * fi		An instance of a channel statemachine.
+ * event	The event, just happened.
+ * arg		Generic pointer, casted from channel * upon call.
+ */
+static void ctcm_chx_start(fsm_instance *fi, int event, void *arg)
+{
+	struct channel *ch = arg;
+	int rc;
+	struct net_device *dev;
+	unsigned long saveflags;
+
+	CTCM_DBF_TEXT(TRACE, 5, __FUNCTION__);
+	if (ch == NULL) {
+		ctcm_pr_warn("chx_start ch=NULL\n");
+		return;
+	}
+	if (ch->netdev == NULL) {
+		ctcm_pr_warn("chx_start dev=NULL, id=%s\n", ch->id);
+		return;
+	}
+	dev = ch->netdev;
+
+	if (do_debug)
+		ctcm_pr_debug("%s: %s channel start\n", dev->name,
+			(CHANNEL_DIRECTION(ch->flags) == READ) ? "RX" : "TX");
+
+	if (ch->trans_skb != NULL) {
+		clear_normalized_cda(&ch->ccw[1]);
+		dev_kfree_skb(ch->trans_skb);
+		ch->trans_skb = NULL;
+	}
+	if (CHANNEL_DIRECTION(ch->flags) == READ) {
+		ch->ccw[1].cmd_code = CCW_CMD_READ;
+		ch->ccw[1].flags = CCW_FLAG_SLI;
+		ch->ccw[1].count = 0;
+	} else {
+		ch->ccw[1].cmd_code = CCW_CMD_WRITE;
+		ch->ccw[1].flags = CCW_FLAG_SLI | CCW_FLAG_CC;
+		ch->ccw[1].count = 0;
+	}
+	if (ctcm_checkalloc_buffer(ch)) {
+		ctcm_pr_notice("%s: %s trans_skb allocation delayed "
+				"until first transfer\n", dev->name,
+			(CHANNEL_DIRECTION(ch->flags) == READ) ? "RX" : "TX");
+	}
+
+	ch->ccw[0].cmd_code = CCW_CMD_PREPARE;
+	ch->ccw[0].flags = CCW_FLAG_SLI | CCW_FLAG_CC;
+	ch->ccw[0].count = 0;
+	ch->ccw[0].cda = 0;
+	ch->ccw[2].cmd_code = CCW_CMD_NOOP;	/* jointed CE + DE */
+	ch->ccw[2].flags = CCW_FLAG_SLI;
+	ch->ccw[2].count = 0;
+	ch->ccw[2].cda = 0;
+	memcpy(&ch->ccw[3], &ch->ccw[0], sizeof(struct ccw1) * 3);
+	ch->ccw[4].cda = 0;
+	ch->ccw[4].flags &= ~CCW_FLAG_IDA;
+
+	fsm_newstate(fi, CTC_STATE_STARTWAIT);
+	fsm_addtimer(&ch->timer, 1000, CTC_EVENT_TIMER, ch);
+	spin_lock_irqsave(get_ccwdev_lock(ch->cdev), saveflags);
+	rc = ccw_device_halt(ch->cdev, (unsigned long)ch);
+	spin_unlock_irqrestore(get_ccwdev_lock(ch->cdev), saveflags);
+	if (rc != 0) {
+		if (rc != -EBUSY)
+			fsm_deltimer(&ch->timer);
+		ctcm_ccw_check_rc(ch, rc, "initial HaltIO");
+	}
+}
+
+/**
+ * Shutdown a channel.
+ *
+ * fi		An instance of a channel statemachine.
+ * event	The event, just happened.
+ * arg		Generic pointer, casted from channel * upon call.
+ */
+static void ctcm_chx_haltio(fsm_instance *fi, int event, void *arg)
+{
+	struct channel *ch = arg;
+	unsigned long saveflags = 0;
+	int rc;
+	int oldstate;
+
+	CTCM_DBF_TEXT(TRACE, 2, __FUNCTION__);
+	fsm_deltimer(&ch->timer);
+	if (IS_MPC(ch))
+		fsm_deltimer(&ch->sweep_timer);
+
+	fsm_addtimer(&ch->timer, CTCM_TIME_5_SEC, CTC_EVENT_TIMER, ch);
+
+	if (event == CTC_EVENT_STOP)	/* only for STOP not yet locked */
+		spin_lock_irqsave(get_ccwdev_lock(ch->cdev), saveflags);
+			/* Such conditional locking is undeterministic in
+			 * static view. => ignore sparse warnings here. */
+	oldstate = fsm_getstate(fi);
+	fsm_newstate(fi, CTC_STATE_TERM);
+	rc = ccw_device_halt(ch->cdev, (unsigned long)ch);
+
+	if (event == CTC_EVENT_STOP)
+		spin_unlock_irqrestore(get_ccwdev_lock(ch->cdev), saveflags);
+			/* see remark above about conditional locking */
+
+	if (rc != 0 && rc != -EBUSY) {
+		fsm_deltimer(&ch->timer);
+		if (event != CTC_EVENT_STOP) {
+			fsm_newstate(fi, oldstate);
+			ctcm_ccw_check_rc(ch, rc, (char *)__FUNCTION__);
+		}
+	}
+}
+
+/**
+ * Cleanup helper for chx_fail and chx_stopped
+ * cleanup channels queue and notify interface statemachine.
+ *
+ * fi		An instance of a channel statemachine.
+ * state	The next state (depending on caller).
+ * ch		The channel to operate on.
+ */
+static void ctcm_chx_cleanup(fsm_instance *fi, int state,
+		struct channel *ch)
+{
+	struct net_device *dev = ch->netdev;
+	struct ctcm_priv *priv = dev->priv;
+
+	CTCM_DBF_TEXT(TRACE, 3, __FUNCTION__);
+
+	fsm_deltimer(&ch->timer);
+	if (IS_MPC(ch))
+		fsm_deltimer(&ch->sweep_timer);
+
+	fsm_newstate(fi, state);
+	if (state == CTC_STATE_STOPPED && ch->trans_skb != NULL) {
+		clear_normalized_cda(&ch->ccw[1]);
+		dev_kfree_skb_any(ch->trans_skb);
+		ch->trans_skb = NULL;
+	}
+
+	ch->th_seg = 0x00;
+	ch->th_seq_num = 0x00;
+	if (CHANNEL_DIRECTION(ch->flags) == READ) {
+		skb_queue_purge(&ch->io_queue);
+		fsm_event(priv->fsm, DEV_EVENT_RXDOWN, dev);
+	} else {
+		ctcm_purge_skb_queue(&ch->io_queue);
+		if (IS_MPC(ch))
+			ctcm_purge_skb_queue(&ch->sweep_queue);
+		spin_lock(&ch->collect_lock);
+		ctcm_purge_skb_queue(&ch->collect_queue);
+		ch->collect_len = 0;
+		spin_unlock(&ch->collect_lock);
+		fsm_event(priv->fsm, DEV_EVENT_TXDOWN, dev);
+	}
+}
+
+/**
+ * A channel has successfully been halted.
+ * Cleanup it's queue and notify interface statemachine.
+ *
+ * fi		An instance of a channel statemachine.
+ * event	The event, just happened.
+ * arg		Generic pointer, casted from channel * upon call.
+ */
+static void ctcm_chx_stopped(fsm_instance *fi, int event, void *arg)
+{
+	CTCM_DBF_TEXT(TRACE, 3, __FUNCTION__);
+	ctcm_chx_cleanup(fi, CTC_STATE_STOPPED, arg);
+}
+
+/**
+ * A stop command from device statemachine arrived and we are in
+ * not operational mode. Set state to stopped.
+ *
+ * fi		An instance of a channel statemachine.
+ * event	The event, just happened.
+ * arg		Generic pointer, casted from channel * upon call.
+ */
+static void ctcm_chx_stop(fsm_instance *fi, int event, void *arg)
+{
+	fsm_newstate(fi, CTC_STATE_STOPPED);
+}
+
+/**
+ * A machine check for no path, not operational status or gone device has
+ * happened.
+ * Cleanup queue and notify interface statemachine.
+ *
+ * fi		An instance of a channel statemachine.
+ * event	The event, just happened.
+ * arg		Generic pointer, casted from channel * upon call.
+ */
+static void ctcm_chx_fail(fsm_instance *fi, int event, void *arg)
+{
+	CTCM_DBF_TEXT(TRACE, 3, __FUNCTION__);
+	ctcm_chx_cleanup(fi, CTC_STATE_NOTOP, arg);
+}
+
+/**
+ * Handle error during setup of channel.
+ *
+ * fi		An instance of a channel statemachine.
+ * event	The event, just happened.
+ * arg		Generic pointer, casted from channel * upon call.
+ */
+static void ctcm_chx_setuperr(fsm_instance *fi, int event, void *arg)
+{
+	struct channel *ch = arg;
+	struct net_device *dev = ch->netdev;
+	struct ctcm_priv *priv = dev->priv;
+
+	/*
+	 * Special case: Got UC_RCRESET on setmode.
+	 * This means that remote side isn't setup. In this case
+	 * simply retry after some 10 secs...
+	 */
+	if ((fsm_getstate(fi) == CTC_STATE_SETUPWAIT) &&
+	    ((event == CTC_EVENT_UC_RCRESET) ||
+	     (event == CTC_EVENT_UC_RSRESET))) {
+		fsm_newstate(fi, CTC_STATE_STARTRETRY);
+		fsm_deltimer(&ch->timer);
+		fsm_addtimer(&ch->timer, CTCM_TIME_5_SEC, CTC_EVENT_TIMER, ch);
+		if (!IS_MPC(ch) && (CHANNEL_DIRECTION(ch->flags) == READ)) {
+			int rc = ccw_device_halt(ch->cdev, (unsigned long)ch);
+			if (rc != 0)
+				ctcm_ccw_check_rc(ch, rc,
+					"HaltIO in chx_setuperr");
+		}
+		return;
+	}
+
+	CTCM_DBF_TEXT_(ERROR, CTC_DBF_CRIT,
+		"%s : %s error during %s channel setup state=%s\n",
+		dev->name, ctc_ch_event_names[event],
+		(CHANNEL_DIRECTION(ch->flags) == READ) ? "RX" : "TX",
+		fsm_getstate_str(fi));
+
+	if (CHANNEL_DIRECTION(ch->flags) == READ) {
+		fsm_newstate(fi, CTC_STATE_RXERR);
+		fsm_event(priv->fsm, DEV_EVENT_RXDOWN, dev);
+	} else {
+		fsm_newstate(fi, CTC_STATE_TXERR);
+		fsm_event(priv->fsm, DEV_EVENT_TXDOWN, dev);
+	}
+}
+
+/**
+ * Restart a channel after an error.
+ *
+ * fi		An instance of a channel statemachine.
+ * event	The event, just happened.
+ * arg		Generic pointer, casted from channel * upon call.
+ */
+static void ctcm_chx_restart(fsm_instance *fi, int event, void *arg)
+{
+	struct channel *ch = arg;
+	struct net_device *dev = ch->netdev;
+	unsigned long saveflags = 0;
+	int oldstate;
+	int rc;
+
+	CTCM_DBF_TEXT(TRACE, CTC_DBF_NOTICE, __FUNCTION__);
+	fsm_deltimer(&ch->timer);
+	ctcm_pr_debug("%s: %s channel restart\n", dev->name,
+		     (CHANNEL_DIRECTION(ch->flags) == READ) ? "RX" : "TX");
+	fsm_addtimer(&ch->timer, CTCM_TIME_5_SEC, CTC_EVENT_TIMER, ch);
+	oldstate = fsm_getstate(fi);
+	fsm_newstate(fi, CTC_STATE_STARTWAIT);
+	if (event == CTC_EVENT_TIMER)	/* only for timer not yet locked */
+		spin_lock_irqsave(get_ccwdev_lock(ch->cdev), saveflags);
+			/* Such conditional locking is a known problem for
+			 * sparse because its undeterministic in static view.
+			 * Warnings should be ignored here. */
+	rc = ccw_device_halt(ch->cdev, (unsigned long)ch);
+	if (event == CTC_EVENT_TIMER)
+		spin_unlock_irqrestore(get_ccwdev_lock(ch->cdev), saveflags);
+	if (rc != 0) {
+		if (rc != -EBUSY) {
+		    fsm_deltimer(&ch->timer);
+		    fsm_newstate(fi, oldstate);
+		}
+		ctcm_ccw_check_rc(ch, rc, "HaltIO in ctcm_chx_restart");
+	}
+}
+
+/**
+ * Handle error during RX initial handshake (exchange of
+ * 0-length block header)
+ *
+ * fi		An instance of a channel statemachine.
+ * event	The event, just happened.
+ * arg		Generic pointer, casted from channel * upon call.
+ */
+static void ctcm_chx_rxiniterr(fsm_instance *fi, int event, void *arg)
+{
+	struct channel *ch = arg;
+	struct net_device *dev = ch->netdev;
+	struct ctcm_priv *priv = dev->priv;
+
+	CTCM_DBF_TEXT(SETUP, 3, __FUNCTION__);
+	if (event == CTC_EVENT_TIMER) {
+		if (!IS_MPCDEV(dev))
+			/* TODO : check if MPC deletes timer somewhere */
+			fsm_deltimer(&ch->timer);
+		ctcm_pr_debug("%s: Timeout during RX init handshake\n",
+				dev->name);
+		if (ch->retry++ < 3)
+			ctcm_chx_restart(fi, event, arg);
+		else {
+			fsm_newstate(fi, CTC_STATE_RXERR);
+			fsm_event(priv->fsm, DEV_EVENT_RXDOWN, dev);
+		}
+	} else
+		ctcm_pr_warn("%s: Error during RX init handshake\n", dev->name);
+}
+
+/**
+ * Notify device statemachine if we gave up initialization
+ * of RX channel.
+ *
+ * fi		An instance of a channel statemachine.
+ * event	The event, just happened.
+ * arg		Generic pointer, casted from channel * upon call.
+ */
+static void ctcm_chx_rxinitfail(fsm_instance *fi, int event, void *arg)
+{
+	struct channel *ch = arg;
+	struct net_device *dev = ch->netdev;
+	struct ctcm_priv *priv = dev->priv;
+
+	CTCM_DBF_TEXT(SETUP, 3, __FUNCTION__);
+	fsm_newstate(fi, CTC_STATE_RXERR);
+	ctcm_pr_warn("%s: RX busy. Initialization failed\n", dev->name);
+	fsm_event(priv->fsm, DEV_EVENT_RXDOWN, dev);
+}
+
+/**
+ * Handle RX Unit check remote reset (remote disconnected)
+ *
+ * fi		An instance of a channel statemachine.
+ * event	The event, just happened.
+ * arg		Generic pointer, casted from channel * upon call.
+ */
+static void ctcm_chx_rxdisc(fsm_instance *fi, int event, void *arg)
+{
+	struct channel *ch = arg;
+	struct channel *ch2;
+	struct net_device *dev = ch->netdev;
+	struct ctcm_priv *priv = dev->priv;
+
+	CTCM_DBF_DEV_NAME(TRACE, dev, "Got remote disconnect, re-initializing");
+	fsm_deltimer(&ch->timer);
+	if (do_debug)
+		ctcm_pr_debug("%s: Got remote disconnect, "
+				"re-initializing ...\n", dev->name);
+	/*
+	 * Notify device statemachine
+	 */
+	fsm_event(priv->fsm, DEV_EVENT_RXDOWN, dev);
+	fsm_event(priv->fsm, DEV_EVENT_TXDOWN, dev);
+
+	fsm_newstate(fi, CTC_STATE_DTERM);
+	ch2 = priv->channel[WRITE];
+	fsm_newstate(ch2->fsm, CTC_STATE_DTERM);
+
+	ccw_device_halt(ch->cdev, (unsigned long)ch);
+	ccw_device_halt(ch2->cdev, (unsigned long)ch2);
+}
+
+/**
+ * Handle error during TX channel initialization.
+ *
+ * fi		An instance of a channel statemachine.
+ * event	The event, just happened.
+ * arg		Generic pointer, casted from channel * upon call.
+ */
+static void ctcm_chx_txiniterr(fsm_instance *fi, int event, void *arg)
+{
+	struct channel *ch = arg;
+	struct net_device *dev = ch->netdev;
+	struct ctcm_priv *priv = dev->priv;
+
+	if (event == CTC_EVENT_TIMER) {
+		fsm_deltimer(&ch->timer);
+		CTCM_DBF_DEV_NAME(ERROR, dev,
+				"Timeout during TX init handshake");
+		if (ch->retry++ < 3)
+			ctcm_chx_restart(fi, event, arg);
+		else {
+			fsm_newstate(fi, CTC_STATE_TXERR);
+			fsm_event(priv->fsm, DEV_EVENT_TXDOWN, dev);
+		}
+	} else {
+		CTCM_DBF_TEXT_(ERROR, CTC_DBF_ERROR,
+			"%s : %s error during channel setup state=%s",
+			dev->name, ctc_ch_event_names[event],
+			fsm_getstate_str(fi));
+
+		ctcm_pr_warn("%s: Error during TX init handshake\n", dev->name);
+	}
+}
+
+/**
+ * Handle TX timeout by retrying operation.
+ *
+ * fi		An instance of a channel statemachine.
+ * event	The event, just happened.
+ * arg		Generic pointer, casted from channel * upon call.
+ */
+static void ctcm_chx_txretry(fsm_instance *fi, int event, void *arg)
+{
+	struct channel *ch = arg;
+	struct net_device *dev = ch->netdev;
+	struct ctcm_priv *priv = dev->priv;
+	struct sk_buff *skb;
+
+	if (do_debug)
+		ctcm_pr_debug("ctcmpc enter: %s(): cp=%i ch=0x%p id=%s\n",
+			__FUNCTION__, smp_processor_id(), ch, ch->id);
+
+	fsm_deltimer(&ch->timer);
+	if (ch->retry++ > 3) {
+		struct mpc_group *gptr = priv->mpcg;
+		ctcm_pr_debug("%s: TX retry failed, restarting channel\n",
+			     dev->name);
+		fsm_event(priv->fsm, DEV_EVENT_TXDOWN, dev);
+		/* call restart if not MPC or if MPC and mpcg fsm is ready.
+			use gptr as mpc indicator */
+		if (!(gptr && (fsm_getstate(gptr->fsm) != MPCG_STATE_READY)))
+			ctcm_chx_restart(fi, event, arg);
+				goto done;
+	}
+
+	ctcm_pr_debug("%s: TX retry %d\n", dev->name, ch->retry);
+	skb = skb_peek(&ch->io_queue);
+	if (skb) {
+		int rc = 0;
+		unsigned long saveflags = 0;
+		clear_normalized_cda(&ch->ccw[4]);
+		ch->ccw[4].count = skb->len;
+		if (set_normalized_cda(&ch->ccw[4], skb->data)) {
+			ctcm_pr_debug("%s: IDAL alloc failed, chan restart\n",
+						dev->name);
+			fsm_event(priv->fsm, DEV_EVENT_TXDOWN, dev);
+			ctcm_chx_restart(fi, event, arg);
+				goto done;
+		}
+		fsm_addtimer(&ch->timer, 1000, CTC_EVENT_TIMER, ch);
+		if (event == CTC_EVENT_TIMER) /* for TIMER not yet locked */
+			spin_lock_irqsave(get_ccwdev_lock(ch->cdev), saveflags);
+			/* Such conditional locking is a known problem for
+			 * sparse because its undeterministic in static view.
+			 * Warnings should be ignored here. */
+		if (do_debug_ccw)
+			ctcmpc_dumpit((char *)&ch->ccw[3],
+					sizeof(struct ccw1) * 3);
+
+		rc = ccw_device_start(ch->cdev, &ch->ccw[3],
+						(unsigned long)ch, 0xff, 0);
+		if (event == CTC_EVENT_TIMER)
+			spin_unlock_irqrestore(get_ccwdev_lock(ch->cdev),
+					saveflags);
+		if (rc != 0) {
+			fsm_deltimer(&ch->timer);
+			ctcm_ccw_check_rc(ch, rc, "TX in chx_txretry");
+			ctcm_purge_skb_queue(&ch->io_queue);
+		}
+	}
+done:
+	return;
+}
+
+/**
+ * Handle fatal errors during an I/O command.
+ *
+ * fi		An instance of a channel statemachine.
+ * event	The event, just happened.
+ * arg		Generic pointer, casted from channel * upon call.
+ */
+static void ctcm_chx_iofatal(fsm_instance *fi, int event, void *arg)
+{
+	struct channel *ch = arg;
+	struct net_device *dev = ch->netdev;
+	struct ctcm_priv *priv = dev->priv;
+
+	CTCM_DBF_TEXT(TRACE, 3, __FUNCTION__);
+	fsm_deltimer(&ch->timer);
+	ctcm_pr_warn("%s %s : unrecoverable channel error\n",
+			CTC_DRIVER_NAME, dev->name);
+	if (IS_MPC(ch)) {
+		priv->stats.tx_dropped++;
+		priv->stats.tx_errors++;
+	}
+
+	if (CHANNEL_DIRECTION(ch->flags) == READ) {
+		ctcm_pr_debug("%s: RX I/O error\n", dev->name);
+		fsm_newstate(fi, CTC_STATE_RXERR);
+		fsm_event(priv->fsm, DEV_EVENT_RXDOWN, dev);
+	} else {
+		ctcm_pr_debug("%s: TX I/O error\n", dev->name);
+		fsm_newstate(fi, CTC_STATE_TXERR);
+		fsm_event(priv->fsm, DEV_EVENT_TXDOWN, dev);
+	}
+}
+
+/*
+ * The ctcm statemachine for a channel.
+ */
+const fsm_node ch_fsm[] = {
+	{ CTC_STATE_STOPPED,	CTC_EVENT_STOP,		ctcm_action_nop  },
+	{ CTC_STATE_STOPPED,	CTC_EVENT_START,	ctcm_chx_start  },
+	{ CTC_STATE_STOPPED,	CTC_EVENT_FINSTAT,	ctcm_action_nop  },
+	{ CTC_STATE_STOPPED,	CTC_EVENT_MC_FAIL,	ctcm_action_nop  },
+
+	{ CTC_STATE_NOTOP,	CTC_EVENT_STOP,		ctcm_chx_stop  },
+	{ CTC_STATE_NOTOP,	CTC_EVENT_START,	ctcm_action_nop  },
+	{ CTC_STATE_NOTOP,	CTC_EVENT_FINSTAT,	ctcm_action_nop  },
+	{ CTC_STATE_NOTOP,	CTC_EVENT_MC_FAIL,	ctcm_action_nop  },
+	{ CTC_STATE_NOTOP,	CTC_EVENT_MC_GOOD,	ctcm_chx_start  },
+
+	{ CTC_STATE_STARTWAIT,	CTC_EVENT_STOP,		ctcm_chx_haltio  },
+	{ CTC_STATE_STARTWAIT,	CTC_EVENT_START,	ctcm_action_nop  },
+	{ CTC_STATE_STARTWAIT,	CTC_EVENT_FINSTAT,	ctcm_chx_setmode  },
+	{ CTC_STATE_STARTWAIT,	CTC_EVENT_TIMER,	ctcm_chx_setuperr  },
+	{ CTC_STATE_STARTWAIT,	CTC_EVENT_IO_ENODEV,	ctcm_chx_iofatal  },
+	{ CTC_STATE_STARTWAIT,	CTC_EVENT_MC_FAIL,	ctcm_chx_fail  },
+
+	{ CTC_STATE_STARTRETRY,	CTC_EVENT_STOP,		ctcm_chx_haltio  },
+	{ CTC_STATE_STARTRETRY,	CTC_EVENT_TIMER,	ctcm_chx_setmode  },
+	{ CTC_STATE_STARTRETRY,	CTC_EVENT_FINSTAT,	ctcm_action_nop  },
+	{ CTC_STATE_STARTRETRY,	CTC_EVENT_MC_FAIL,	ctcm_chx_fail  },
+
+	{ CTC_STATE_SETUPWAIT,	CTC_EVENT_STOP,		ctcm_chx_haltio  },
+	{ CTC_STATE_SETUPWAIT,	CTC_EVENT_START,	ctcm_action_nop  },
+	{ CTC_STATE_SETUPWAIT,	CTC_EVENT_FINSTAT,	chx_firstio  },
+	{ CTC_STATE_SETUPWAIT,	CTC_EVENT_UC_RCRESET,	ctcm_chx_setuperr  },
+	{ CTC_STATE_SETUPWAIT,	CTC_EVENT_UC_RSRESET,	ctcm_chx_setuperr  },
+	{ CTC_STATE_SETUPWAIT,	CTC_EVENT_TIMER,	ctcm_chx_setmode  },
+	{ CTC_STATE_SETUPWAIT,	CTC_EVENT_IO_ENODEV,	ctcm_chx_iofatal  },
+	{ CTC_STATE_SETUPWAIT,	CTC_EVENT_MC_FAIL,	ctcm_chx_fail  },
+
+	{ CTC_STATE_RXINIT,	CTC_EVENT_STOP,		ctcm_chx_haltio  },
+	{ CTC_STATE_RXINIT,	CTC_EVENT_START,	ctcm_action_nop  },
+	{ CTC_STATE_RXINIT,	CTC_EVENT_FINSTAT,	chx_rxidle  },
+	{ CTC_STATE_RXINIT,	CTC_EVENT_UC_RCRESET,	ctcm_chx_rxiniterr  },
+	{ CTC_STATE_RXINIT,	CTC_EVENT_UC_RSRESET,	ctcm_chx_rxiniterr  },
+	{ CTC_STATE_RXINIT,	CTC_EVENT_TIMER,	ctcm_chx_rxiniterr  },
+	{ CTC_STATE_RXINIT,	CTC_EVENT_ATTNBUSY,	ctcm_chx_rxinitfail  },
+	{ CTC_STATE_RXINIT,	CTC_EVENT_IO_ENODEV,	ctcm_chx_iofatal  },
+	{ CTC_STATE_RXINIT,	CTC_EVENT_UC_ZERO,	chx_firstio  },
+	{ CTC_STATE_RXINIT,	CTC_EVENT_MC_FAIL,	ctcm_chx_fail  },
+
+	{ CTC_STATE_RXIDLE,	CTC_EVENT_STOP,		ctcm_chx_haltio  },
+	{ CTC_STATE_RXIDLE,	CTC_EVENT_START,	ctcm_action_nop  },
+	{ CTC_STATE_RXIDLE,	CTC_EVENT_FINSTAT,	chx_rx  },
+	{ CTC_STATE_RXIDLE,	CTC_EVENT_UC_RCRESET,	ctcm_chx_rxdisc  },
+	{ CTC_STATE_RXIDLE,	CTC_EVENT_IO_ENODEV,	ctcm_chx_iofatal  },
+	{ CTC_STATE_RXIDLE,	CTC_EVENT_MC_FAIL,	ctcm_chx_fail  },
+	{ CTC_STATE_RXIDLE,	CTC_EVENT_UC_ZERO,	chx_rx  },
+
+	{ CTC_STATE_TXINIT,	CTC_EVENT_STOP,		ctcm_chx_haltio  },
+	{ CTC_STATE_TXINIT,	CTC_EVENT_START,	ctcm_action_nop  },
+	{ CTC_STATE_TXINIT,	CTC_EVENT_FINSTAT,	ctcm_chx_txidle  },
+	{ CTC_STATE_TXINIT,	CTC_EVENT_UC_RCRESET,	ctcm_chx_txiniterr  },
+	{ CTC_STATE_TXINIT,	CTC_EVENT_UC_RSRESET,	ctcm_chx_txiniterr  },
+	{ CTC_STATE_TXINIT,	CTC_EVENT_TIMER,	ctcm_chx_txiniterr  },
+	{ CTC_STATE_TXINIT,	CTC_EVENT_IO_ENODEV,	ctcm_chx_iofatal  },
+	{ CTC_STATE_TXINIT,	CTC_EVENT_MC_FAIL,	ctcm_chx_fail  },
+
+	{ CTC_STATE_TXIDLE,	CTC_EVENT_STOP,		ctcm_chx_haltio  },
+	{ CTC_STATE_TXIDLE,	CTC_EVENT_START,	ctcm_action_nop  },
+	{ CTC_STATE_TXIDLE,	CTC_EVENT_FINSTAT,	chx_firstio  },
+	{ CTC_STATE_TXIDLE,	CTC_EVENT_UC_RCRESET,	ctcm_action_nop  },
+	{ CTC_STATE_TXIDLE,	CTC_EVENT_UC_RSRESET,	ctcm_action_nop  },
+	{ CTC_STATE_TXIDLE,	CTC_EVENT_IO_ENODEV,	ctcm_chx_iofatal  },
+	{ CTC_STATE_TXIDLE,	CTC_EVENT_MC_FAIL,	ctcm_chx_fail  },
+
+	{ CTC_STATE_TERM,	CTC_EVENT_STOP,		ctcm_action_nop  },
+	{ CTC_STATE_TERM,	CTC_EVENT_START,	ctcm_chx_restart  },
+	{ CTC_STATE_TERM,	CTC_EVENT_FINSTAT,	ctcm_chx_stopped  },
+	{ CTC_STATE_TERM,	CTC_EVENT_UC_RCRESET,	ctcm_action_nop  },
+	{ CTC_STATE_TERM,	CTC_EVENT_UC_RSRESET,	ctcm_action_nop  },
+	{ CTC_STATE_TERM,	CTC_EVENT_MC_FAIL,	ctcm_chx_fail  },
+
+	{ CTC_STATE_DTERM,	CTC_EVENT_STOP,		ctcm_chx_haltio  },
+	{ CTC_STATE_DTERM,	CTC_EVENT_START,	ctcm_chx_restart  },
+	{ CTC_STATE_DTERM,	CTC_EVENT_FINSTAT,	ctcm_chx_setmode  },
+	{ CTC_STATE_DTERM,	CTC_EVENT_UC_RCRESET,	ctcm_action_nop  },
+	{ CTC_STATE_DTERM,	CTC_EVENT_UC_RSRESET,	ctcm_action_nop  },
+	{ CTC_STATE_DTERM,	CTC_EVENT_MC_FAIL,	ctcm_chx_fail  },
+
+	{ CTC_STATE_TX,		CTC_EVENT_STOP,		ctcm_chx_haltio  },
+	{ CTC_STATE_TX,		CTC_EVENT_START,	ctcm_action_nop  },
+	{ CTC_STATE_TX,		CTC_EVENT_FINSTAT,	chx_txdone  },
+	{ CTC_STATE_TX,		CTC_EVENT_UC_RCRESET,	ctcm_chx_txretry  },
+	{ CTC_STATE_TX,		CTC_EVENT_UC_RSRESET,	ctcm_chx_txretry  },
+	{ CTC_STATE_TX,		CTC_EVENT_TIMER,	ctcm_chx_txretry  },
+	{ CTC_STATE_TX,		CTC_EVENT_IO_ENODEV,	ctcm_chx_iofatal  },
+	{ CTC_STATE_TX,		CTC_EVENT_MC_FAIL,	ctcm_chx_fail  },
+
+	{ CTC_STATE_RXERR,	CTC_EVENT_STOP,		ctcm_chx_haltio  },
+	{ CTC_STATE_TXERR,	CTC_EVENT_STOP,		ctcm_chx_haltio  },
+	{ CTC_STATE_TXERR,	CTC_EVENT_MC_FAIL,	ctcm_chx_fail  },
+	{ CTC_STATE_RXERR,	CTC_EVENT_MC_FAIL,	ctcm_chx_fail  },
+};
+
+int ch_fsm_len = ARRAY_SIZE(ch_fsm);
+
+/*
+ * MPC actions for mpc channel statemachine
+ * handling of MPC protocol requires extra
+ * statemachine and actions which are prefixed ctcmpc_ .
+ * The ctc_ch_states and ctc_ch_state_names,
+ * ctc_ch_events and ctc_ch_event_names share the ctcm definitions
+ * which are expanded by some elements.
+ */
+
+/*
+ * Actions for mpc channel statemachine.
+ */
+
+/**
+ * Normal data has been send. Free the corresponding
+ * skb (it's in io_queue), reset dev->tbusy and
+ * revert to idle state.
+ *
+ * fi		An instance of a channel statemachine.
+ * event	The event, just happened.
+ * arg		Generic pointer, casted from channel * upon call.
+ */
+static void ctcmpc_chx_txdone(fsm_instance *fi, int event, void *arg)
+{
+	struct channel		*ch = arg;
+	struct net_device	*dev = ch->netdev;
+	struct ctcm_priv	*priv = dev->priv;
+	struct mpc_group	*grp = priv->mpcg;
+	struct sk_buff		*skb;
+	int		first = 1;
+	int		i;
+	struct timespec done_stamp;
+	__u32		data_space;
+	unsigned long	duration;
+	struct sk_buff	*peekskb;
+	int		rc;
+	struct th_header *header;
+	struct pdu	*p_header;
+
+	if (do_debug)
+		ctcm_pr_debug("%s cp:%i enter:  %s()\n",
+			dev->name, smp_processor_id(), __FUNCTION__);
+
+	done_stamp = current_kernel_time(); /* xtime */
+	duration = (done_stamp.tv_sec - ch->prof.send_stamp.tv_sec) * 1000000
+		+ (done_stamp.tv_nsec - ch->prof.send_stamp.tv_nsec) / 1000;
+	if (duration > ch->prof.tx_time)
+		ch->prof.tx_time = duration;
+
+	if (ch->irb->scsw.count != 0)
+		ctcm_pr_debug("%s: TX not complete, remaining %d bytes\n",
+				dev->name, ch->irb->scsw.count);
+	fsm_deltimer(&ch->timer);
+	while ((skb = skb_dequeue(&ch->io_queue))) {
+		priv->stats.tx_packets++;
+		priv->stats.tx_bytes += skb->len - TH_HEADER_LENGTH;
+		if (first) {
+			priv->stats.tx_bytes += 2;
+			first = 0;
+		}
+		atomic_dec(&skb->users);
+		dev_kfree_skb_irq(skb);
+	}
+	spin_lock(&ch->collect_lock);
+	clear_normalized_cda(&ch->ccw[4]);
+
+	if ((ch->collect_len <= 0) || (grp->in_sweep != 0)) {
+		spin_unlock(&ch->collect_lock);
+		fsm_newstate(fi, CTC_STATE_TXIDLE);
+				goto done;
+	}
+
+	if (ctcm_checkalloc_buffer(ch)) {
+		spin_unlock(&ch->collect_lock);
+				goto done;
+	}
+	ch->trans_skb->data = ch->trans_skb_data;
+	skb_reset_tail_pointer(ch->trans_skb);
+	ch->trans_skb->len = 0;
+	if (ch->prof.maxmulti < (ch->collect_len + TH_HEADER_LENGTH))
+		ch->prof.maxmulti = ch->collect_len + TH_HEADER_LENGTH;
+	if (ch->prof.maxcqueue < skb_queue_len(&ch->collect_queue))
+		ch->prof.maxcqueue = skb_queue_len(&ch->collect_queue);
+	i = 0;
+
+	if (do_debug_data)
+		ctcm_pr_debug("ctcmpc: %s() building "
+			       "trans_skb from collect_q \n", __FUNCTION__);
+
+	data_space = grp->group_max_buflen - TH_HEADER_LENGTH;
+
+	if (do_debug_data)
+		ctcm_pr_debug("ctcmpc: %s() building trans_skb from collect_q"
+		       " data_space:%04x\n", __FUNCTION__, data_space);
+	p_header = NULL;
+	while ((skb = skb_dequeue(&ch->collect_queue))) {
+		memcpy(skb_put(ch->trans_skb, skb->len), skb->data, skb->len);
+		p_header = (struct pdu *)
+			(skb_tail_pointer(ch->trans_skb) - skb->len);
+		p_header->pdu_flag = 0x00;
+		if (skb->protocol == ntohs(ETH_P_SNAP))
+			p_header->pdu_flag |= 0x60;
+		else
+			p_header->pdu_flag |= 0x20;
+
+		if (do_debug_data) {
+			ctcm_pr_debug("ctcmpc: %s()trans_skb len:%04x \n",
+				       __FUNCTION__, ch->trans_skb->len);
+			ctcm_pr_debug("ctcmpc: %s() pdu header and data"
+				       " for up to 32 bytes sent to vtam\n",
+				       __FUNCTION__);
+			ctcmpc_dumpit((char *)p_header,
+						min_t(int, skb->len, 32));
+		}
+		ch->collect_len -= skb->len;
+		data_space -= skb->len;
+		priv->stats.tx_packets++;
+		priv->stats.tx_bytes += skb->len;
+		atomic_dec(&skb->users);
+		dev_kfree_skb_any(skb);
+		peekskb = skb_peek(&ch->collect_queue);
+		if (peekskb->len > data_space)
+			break;
+		i++;
+	}
+	/* p_header points to the last one we handled */
+	if (p_header)
+		p_header->pdu_flag |= PDU_LAST;	/*Say it's the last one*/
+	header = kzalloc(TH_HEADER_LENGTH, gfp_type());
+
+	if (!header) {
+		printk(KERN_WARNING "ctcmpc: OUT OF MEMORY IN %s()"
+		       ": Data Lost \n", __FUNCTION__);
+		spin_unlock(&ch->collect_lock);
+		fsm_event(priv->mpcg->fsm, MPCG_EVENT_INOP, dev);
+		goto done;
+	}
+
+	header->th_ch_flag = TH_HAS_PDU;  /* Normal data */
+	ch->th_seq_num++;
+	header->th_seq_num = ch->th_seq_num;
+
+	if (do_debug_data)
+		ctcm_pr_debug("%s: ToVTAM_th_seq= %08x\n" ,
+					__FUNCTION__, ch->th_seq_num);
+
+	memcpy(skb_push(ch->trans_skb, TH_HEADER_LENGTH), header,
+		TH_HEADER_LENGTH);	/* put the TH on the packet */
+
+	kfree(header);
+
+	if (do_debug_data) {
+		ctcm_pr_debug("ctcmpc: %s()trans_skb len:%04x \n",
+		       __FUNCTION__, ch->trans_skb->len);
+
+		ctcm_pr_debug("ctcmpc: %s() up-to-50 bytes of trans_skb "
+			"data to vtam from collect_q\n", __FUNCTION__);
+		ctcmpc_dumpit((char *)ch->trans_skb->data,
+				min_t(int, ch->trans_skb->len, 50));
+	}
+
+	spin_unlock(&ch->collect_lock);
+	clear_normalized_cda(&ch->ccw[1]);
+	if (set_normalized_cda(&ch->ccw[1], ch->trans_skb->data)) {
+		dev_kfree_skb_any(ch->trans_skb);
+		ch->trans_skb = NULL;
+		printk(KERN_WARNING
+		       "ctcmpc: %s()CCW failure - data lost\n",
+		       __FUNCTION__);
+		fsm_event(priv->mpcg->fsm, MPCG_EVENT_INOP, dev);
+		return;
+	}
+	ch->ccw[1].count = ch->trans_skb->len;
+	fsm_addtimer(&ch->timer, CTCM_TIME_5_SEC, CTC_EVENT_TIMER, ch);
+	ch->prof.send_stamp = current_kernel_time(); /* xtime */
+	if (do_debug_ccw)
+		ctcmpc_dumpit((char *)&ch->ccw[0], sizeof(struct ccw1) * 3);
+	rc = ccw_device_start(ch->cdev, &ch->ccw[0],
+					(unsigned long)ch, 0xff, 0);
+	ch->prof.doios_multi++;
+	if (rc != 0) {
+		priv->stats.tx_dropped += i;
+		priv->stats.tx_errors += i;
+		fsm_deltimer(&ch->timer);
+		ctcm_ccw_check_rc(ch, rc, "chained TX");
+	}
+done:
+	ctcm_clear_busy(dev);
+	ctcm_pr_debug("ctcmpc exit: %s  %s()\n", dev->name, __FUNCTION__);
+	return;
+}
+
+/**
+ * Got normal data, check for sanity, queue it up, allocate new buffer
+ * trigger bottom half, and initiate next read.
+ *
+ * fi		An instance of a channel statemachine.
+ * event	The event, just happened.
+ * arg		Generic pointer, casted from channel * upon call.
+ */
+static void ctcmpc_chx_rx(fsm_instance *fi, int event, void *arg)
+{
+	struct channel		*ch = arg;
+	struct net_device	*dev = ch->netdev;
+	struct ctcm_priv	*priv = dev->priv;
+	struct mpc_group	*grp = priv->mpcg;
+	struct sk_buff		*skb = ch->trans_skb;
+	struct sk_buff		*new_skb;
+	unsigned long	saveflags = 0;	/* avoids compiler warning */
+	int len	= ch->max_bufsize - ch->irb->scsw.count;
+
+	if (do_debug_data) {
+		CTCM_DBF_TEXT_(TRACE, CTC_DBF_DEBUG, "mpc_ch_rx %s cp:%i %s\n",
+				dev->name, smp_processor_id(), ch->id);
+		CTCM_DBF_TEXT_(TRACE, CTC_DBF_DEBUG, "mpc_ch_rx: maxbuf: %04x "
+				"len: %04x\n", ch->max_bufsize, len);
+	}
+	fsm_deltimer(&ch->timer);
+
+	if (skb == NULL) {
+		ctcm_pr_debug("ctcmpc exit:  %s() TRANS_SKB = NULL \n",
+			       __FUNCTION__);
+					goto again;
+	}
+
+	if (len < TH_HEADER_LENGTH) {
+		ctcm_pr_info("%s: got packet with invalid length %d\n",
+				dev->name, len);
+		priv->stats.rx_dropped++;
+		priv->stats.rx_length_errors++;
+	} else {
+		/* must have valid th header or game over */
+		__u32	block_len = len;
+		len = TH_HEADER_LENGTH + XID2_LENGTH + 4;
+		new_skb = __dev_alloc_skb(ch->max_bufsize, GFP_ATOMIC);
+
+		if (new_skb == NULL) {
+			printk(KERN_INFO "ctcmpc:%s() NEW_SKB = NULL\n",
+			       __FUNCTION__);
+			printk(KERN_WARNING "ctcmpc: %s() MEMORY ALLOC FAILED"
+			       " - DATA LOST - MPC FAILED\n",
+			       __FUNCTION__);
+			fsm_event(priv->mpcg->fsm, MPCG_EVENT_INOP, dev);
+					goto again;
+		}
+		switch (fsm_getstate(grp->fsm)) {
+		case MPCG_STATE_RESET:
+		case MPCG_STATE_INOP:
+			dev_kfree_skb_any(new_skb);
+			break;
+		case MPCG_STATE_FLOWC:
+		case MPCG_STATE_READY:
+			memcpy(skb_put(new_skb, block_len),
+					       skb->data, block_len);
+			skb_queue_tail(&ch->io_queue, new_skb);
+			tasklet_schedule(&ch->ch_tasklet);
+			break;
+		default:
+			memcpy(skb_put(new_skb, len), skb->data, len);
+			skb_queue_tail(&ch->io_queue, new_skb);
+			tasklet_hi_schedule(&ch->ch_tasklet);
+			break;
+		}
+	}
+
+again:
+	switch (fsm_getstate(grp->fsm)) {
+	int rc, dolock;
+	case MPCG_STATE_FLOWC:
+	case MPCG_STATE_READY:
+		if (ctcm_checkalloc_buffer(ch))
+			break;
+		ch->trans_skb->data = ch->trans_skb_data;
+		skb_reset_tail_pointer(ch->trans_skb);
+		ch->trans_skb->len = 0;
+		ch->ccw[1].count = ch->max_bufsize;
+			if (do_debug_ccw)
+			ctcmpc_dumpit((char *)&ch->ccw[0],
+					sizeof(struct ccw1) * 3);
+		dolock = !in_irq();
+		if (dolock)
+			spin_lock_irqsave(
+				get_ccwdev_lock(ch->cdev), saveflags);
+		rc = ccw_device_start(ch->cdev, &ch->ccw[0],
+						(unsigned long)ch, 0xff, 0);
+		if (dolock) /* see remark about conditional locking */
+			spin_unlock_irqrestore(
+				get_ccwdev_lock(ch->cdev), saveflags);
+		if (rc != 0)
+			ctcm_ccw_check_rc(ch, rc, "normal RX");
+	default:
+		break;
+	}
+
+	if (do_debug)
+		ctcm_pr_debug("ctcmpc exit : %s %s(): ch=0x%p id=%s\n",
+				dev->name, __FUNCTION__, ch, ch->id);
+
+}
+
+/**
+ * Initialize connection by sending a __u16 of value 0.
+ *
+ * fi		An instance of a channel statemachine.
+ * event	The event, just happened.
+ * arg		Generic pointer, casted from channel * upon call.
+ */
+static void ctcmpc_chx_firstio(fsm_instance *fi, int event, void *arg)
+{
+	struct channel		*ch = arg;
+	struct net_device	*dev = ch->netdev;
+	struct ctcm_priv	*priv = dev->priv;
+
+	if (do_debug) {
+		struct mpc_group *gptr = priv->mpcg;
+		ctcm_pr_debug("ctcmpc enter: %s(): ch=0x%p id=%s\n",
+				__FUNCTION__, ch, ch->id);
+		ctcm_pr_debug("%s() %s chstate:%i grpstate:%i chprotocol:%i\n",
+				__FUNCTION__, ch->id, fsm_getstate(fi),
+				fsm_getstate(gptr->fsm), ch->protocol);
+	}
+	if (fsm_getstate(fi) == CTC_STATE_TXIDLE)
+		MPC_DBF_DEV_NAME(TRACE, dev, "remote side issued READ? ");
+
+	fsm_deltimer(&ch->timer);
+	if (ctcm_checkalloc_buffer(ch))
+				goto done;
+
+	switch (fsm_getstate(fi)) {
+	case CTC_STATE_STARTRETRY:
+	case CTC_STATE_SETUPWAIT:
+		if (CHANNEL_DIRECTION(ch->flags) == READ) {
+			ctcmpc_chx_rxidle(fi, event, arg);
+		} else {
+			fsm_newstate(fi, CTC_STATE_TXIDLE);
+			fsm_event(priv->fsm, DEV_EVENT_TXUP, dev);
+		}
+				goto done;
+	default:
+		break;
+	};
+
+	fsm_newstate(fi, (CHANNEL_DIRECTION(ch->flags) == READ)
+		     ? CTC_STATE_RXINIT : CTC_STATE_TXINIT);
+
+done:
+	if (do_debug)
+		ctcm_pr_debug("ctcmpc exit : %s(): ch=0x%p id=%s\n",
+			__FUNCTION__, ch, ch->id);
+	return;
+}
+
+/**
+ * Got initial data, check it. If OK,
+ * notify device statemachine that we are up and
+ * running.
+ *
+ * fi		An instance of a channel statemachine.
+ * event	The event, just happened.
+ * arg		Generic pointer, casted from channel * upon call.
+ */
+void ctcmpc_chx_rxidle(fsm_instance *fi, int event, void *arg)
+{
+	struct channel *ch = arg;
+	struct net_device *dev = ch->netdev;
+	struct ctcm_priv  *priv = dev->priv;
+	struct mpc_group  *grp = priv->mpcg;
+	int rc;
+	unsigned long saveflags = 0;	/* avoids compiler warning */
+
+	fsm_deltimer(&ch->timer);
+	ctcm_pr_debug("%s cp:%i enter:  %s()\n",
+		       dev->name, smp_processor_id(), __FUNCTION__);
+	if (do_debug)
+		ctcm_pr_debug("%s() %s chstate:%i grpstate:%i\n",
+			__FUNCTION__, ch->id,
+			fsm_getstate(fi), fsm_getstate(grp->fsm));
+
+	fsm_newstate(fi, CTC_STATE_RXIDLE);
+	/* XID processing complete */
+
+	switch (fsm_getstate(grp->fsm)) {
+	case MPCG_STATE_FLOWC:
+	case MPCG_STATE_READY:
+		if (ctcm_checkalloc_buffer(ch))
+				goto done;
+		ch->trans_skb->data = ch->trans_skb_data;
+		skb_reset_tail_pointer(ch->trans_skb);
+		ch->trans_skb->len = 0;
+		ch->ccw[1].count = ch->max_bufsize;
+		if (do_debug_ccw)
+			ctcmpc_dumpit((char *)&ch->ccw[0],
+						sizeof(struct ccw1) * 3);
+		if (event == CTC_EVENT_START)
+			/* see remark about conditional locking */
+			spin_lock_irqsave(get_ccwdev_lock(ch->cdev), saveflags);
+		rc = ccw_device_start(ch->cdev, &ch->ccw[0],
+						(unsigned long)ch, 0xff, 0);
+		if (event == CTC_EVENT_START)
+			spin_unlock_irqrestore(
+					get_ccwdev_lock(ch->cdev), saveflags);
+		if (rc != 0) {
+			fsm_newstate(fi, CTC_STATE_RXINIT);
+			ctcm_ccw_check_rc(ch, rc, "initial RX");
+				goto done;
+		}
+		break;
+	default:
+		break;
+	}
+
+	fsm_event(priv->fsm, DEV_EVENT_RXUP, dev);
+done:
+	if (do_debug)
+		ctcm_pr_debug("ctcmpc exit: %s  %s()\n",
+					dev->name, __FUNCTION__);
+	return;
+}
+
+/*
+ * ctcmpc channel FSM action
+ * called from several points in ctcmpc_ch_fsm
+ * ctcmpc only
+ */
+static void ctcmpc_chx_attn(fsm_instance *fsm, int event, void *arg)
+{
+	struct channel	  *ch     = arg;
+	struct net_device *dev    = ch->netdev;
+	struct ctcm_priv  *priv   = dev->priv;
+	struct mpc_group  *grp = priv->mpcg;
+
+	if (do_debug) {
+		ctcm_pr_debug("ctcmpc enter: %s(): cp=%i ch=0x%p id=%s"
+				"GrpState:%s ChState:%s\n",
+				__FUNCTION__, smp_processor_id(), ch, ch->id,
+		fsm_getstate_str(grp->fsm),
+		fsm_getstate_str(ch->fsm));
+	}
+
+	switch (fsm_getstate(grp->fsm)) {
+	case MPCG_STATE_XID2INITW:
+		/* ok..start yside xid exchanges */
+		if (!ch->in_mpcgroup)
+			break;
+		if (fsm_getstate(ch->fsm) ==  CH_XID0_PENDING) {
+			fsm_deltimer(&grp->timer);
+			fsm_addtimer(&grp->timer,
+				MPC_XID_TIMEOUT_VALUE,
+				MPCG_EVENT_TIMER, dev);
+			fsm_event(grp->fsm, MPCG_EVENT_XID0DO, ch);
+
+		} else if (fsm_getstate(ch->fsm) < CH_XID7_PENDING1)
+			/* attn rcvd before xid0 processed via bh */
+			fsm_newstate(ch->fsm, CH_XID7_PENDING1);
+		break;
+	case MPCG_STATE_XID2INITX:
+	case MPCG_STATE_XID0IOWAIT:
+	case MPCG_STATE_XID0IOWAIX:
+		/* attn rcvd before xid0 processed on ch
+		but mid-xid0 processing for group    */
+		if (fsm_getstate(ch->fsm) < CH_XID7_PENDING1)
+			fsm_newstate(ch->fsm, CH_XID7_PENDING1);
+		break;
+	case MPCG_STATE_XID7INITW:
+	case MPCG_STATE_XID7INITX:
+	case MPCG_STATE_XID7INITI:
+	case MPCG_STATE_XID7INITZ:
+		switch (fsm_getstate(ch->fsm)) {
+		case CH_XID7_PENDING:
+			fsm_newstate(ch->fsm, CH_XID7_PENDING1);
+			break;
+		case CH_XID7_PENDING2:
+			fsm_newstate(ch->fsm, CH_XID7_PENDING3);
+			break;
+		}
+		fsm_event(grp->fsm, MPCG_EVENT_XID7DONE, dev);
+		break;
+	}
+
+	if (do_debug)
+		ctcm_pr_debug("ctcmpc exit : %s(): cp=%i ch=0x%p id=%s\n",
+			__FUNCTION__, smp_processor_id(), ch, ch->id);
+	return;
+
+}
+
+/*
+ * ctcmpc channel FSM action
+ * called from one point in ctcmpc_ch_fsm
+ * ctcmpc only
+ */
+static void ctcmpc_chx_attnbusy(fsm_instance *fsm, int event, void *arg)
+{
+	struct channel	  *ch     = arg;
+	struct net_device *dev    = ch->netdev;
+	struct ctcm_priv  *priv   = dev->priv;
+	struct mpc_group  *grp    = priv->mpcg;
+
+	ctcm_pr_debug("ctcmpc enter: %s  %s() %s  \nGrpState:%s ChState:%s\n",
+		       dev->name,
+		       __FUNCTION__, ch->id,
+		       fsm_getstate_str(grp->fsm),
+		       fsm_getstate_str(ch->fsm));
+
+	fsm_deltimer(&ch->timer);
+
+	switch (fsm_getstate(grp->fsm)) {
+	case MPCG_STATE_XID0IOWAIT:
+		/* vtam wants to be primary.start yside xid exchanges*/
+		/* only receive one attn-busy at a time so must not  */
+		/* change state each time			     */
+		grp->changed_side = 1;
+		fsm_newstate(grp->fsm, MPCG_STATE_XID2INITW);
+		break;
+	case MPCG_STATE_XID2INITW:
+		if (grp->changed_side == 1) {
+			grp->changed_side = 2;
+			break;
+		}
+		/* process began via call to establish_conn	 */
+		/* so must report failure instead of reverting	 */
+		/* back to ready-for-xid passive state		 */
+		if (grp->estconnfunc)
+				goto done;
+		/* this attnbusy is NOT the result of xside xid  */
+		/* collisions so yside must have been triggered  */
+		/* by an ATTN that was not intended to start XID */
+		/* processing. Revert back to ready-for-xid and  */
+		/* wait for ATTN interrupt to signal xid start	 */
+		if (fsm_getstate(ch->fsm) == CH_XID0_INPROGRESS) {
+			fsm_newstate(ch->fsm, CH_XID0_PENDING) ;
+			fsm_deltimer(&grp->timer);
+				goto done;
+		}
+		fsm_event(grp->fsm, MPCG_EVENT_INOP, dev);
+				goto done;
+	case MPCG_STATE_XID2INITX:
+		/* XID2 was received before ATTN Busy for second
+		   channel.Send yside xid for second channel.
+		*/
+		if (grp->changed_side == 1) {
+			grp->changed_side = 2;
+			break;
+		}
+	case MPCG_STATE_XID0IOWAIX:
+	case MPCG_STATE_XID7INITW:
+	case MPCG_STATE_XID7INITX:
+	case MPCG_STATE_XID7INITI:
+	case MPCG_STATE_XID7INITZ:
+	default:
+		/* multiple attn-busy indicates too out-of-sync      */
+		/* and they are certainly not being received as part */
+		/* of valid mpc group negotiations..		     */
+		fsm_event(grp->fsm, MPCG_EVENT_INOP, dev);
+				goto done;
+	}
+
+	if (grp->changed_side == 1) {
+		fsm_deltimer(&grp->timer);
+		fsm_addtimer(&grp->timer, MPC_XID_TIMEOUT_VALUE,
+			     MPCG_EVENT_TIMER, dev);
+	}
+	if (ch->in_mpcgroup)
+		fsm_event(grp->fsm, MPCG_EVENT_XID0DO, ch);
+	else
+		printk(KERN_WARNING "ctcmpc: %s() Not all channels have"
+			" been added to group\n", __FUNCTION__);
+
+done:
+	if (do_debug)
+		ctcm_pr_debug("ctcmpc exit : %s()%s ch=0x%p id=%s\n",
+				__FUNCTION__, dev->name, ch, ch->id);
+
+	return;
+
+}
+
+/*
+ * ctcmpc channel FSM action
+ * called from several points in ctcmpc_ch_fsm
+ * ctcmpc only
+ */
+static void ctcmpc_chx_resend(fsm_instance *fsm, int event, void *arg)
+{
+	struct channel	   *ch	   = arg;
+	struct net_device  *dev    = ch->netdev;
+	struct ctcm_priv   *priv   = dev->priv;
+	struct mpc_group   *grp    = priv->mpcg;
+
+	ctcm_pr_debug("ctcmpc enter: %s  %s() %s  \nGrpState:%s ChState:%s\n",
+		       dev->name, __FUNCTION__, ch->id,
+		       fsm_getstate_str(grp->fsm),
+		       fsm_getstate_str(ch->fsm));
+
+	fsm_event(grp->fsm, MPCG_EVENT_XID0DO, ch);
+
+	return;
+}
+
+/*
+ * ctcmpc channel FSM action
+ * called from several points in ctcmpc_ch_fsm
+ * ctcmpc only
+ */
+static void ctcmpc_chx_send_sweep(fsm_instance *fsm, int event, void *arg)
+{
+	struct channel *ach = arg;
+	struct net_device *dev = ach->netdev;
+	struct ctcm_priv *priv = dev->priv;
+	struct mpc_group *grp = priv->mpcg;
+	struct channel *wch = priv->channel[WRITE];
+	struct channel *rch = priv->channel[READ];
+	struct sk_buff *skb;
+	struct th_sweep *header;
+	int rc = 0;
+	unsigned long saveflags = 0;
+
+	if (do_debug)
+		ctcm_pr_debug("ctcmpc enter: %s(): cp=%i ch=0x%p id=%s\n",
+			__FUNCTION__, smp_processor_id(), ach, ach->id);
+
+	if (grp->in_sweep == 0)
+				goto done;
+
+	if (do_debug_data) {
+		ctcm_pr_debug("ctcmpc: %s() 1: ToVTAM_th_seq= %08x\n" ,
+			       __FUNCTION__, wch->th_seq_num);
+		ctcm_pr_debug("ctcmpc: %s() 1: FromVTAM_th_seq= %08x\n" ,
+				__FUNCTION__, rch->th_seq_num);
+	}
+
+	if (fsm_getstate(wch->fsm) != CTC_STATE_TXIDLE) {
+		/* give the previous IO time to complete */
+		fsm_addtimer(&wch->sweep_timer,
+			200, CTC_EVENT_RSWEEP_TIMER, wch);
+				goto done;
+	}
+
+	skb = skb_dequeue(&wch->sweep_queue);
+	if (!skb)
+				goto done;
+
+	if (set_normalized_cda(&wch->ccw[4], skb->data)) {
+		grp->in_sweep = 0;
+		ctcm_clear_busy_do(dev);
+		dev_kfree_skb_any(skb);
+		fsm_event(grp->fsm, MPCG_EVENT_INOP, dev);
+				goto done;
+	} else {
+		atomic_inc(&skb->users);
+		skb_queue_tail(&wch->io_queue, skb);
+	}
+
+	/* send out the sweep */
+	wch->ccw[4].count = skb->len;
+
+	header = (struct th_sweep *)skb->data;
+	switch (header->th.th_ch_flag) {
+	case TH_SWEEP_REQ:
+		grp->sweep_req_pend_num--;
+		break;
+	case TH_SWEEP_RESP:
+		grp->sweep_rsp_pend_num--;
+		break;
+	}
+
+	header->sw.th_last_seq = wch->th_seq_num;
+
+	if (do_debug_ccw)
+		ctcmpc_dumpit((char *)&wch->ccw[3], sizeof(struct ccw1) * 3);
+
+	ctcm_pr_debug("ctcmpc: %s() sweep packet\n", __FUNCTION__);
+	ctcmpc_dumpit((char *)header, TH_SWEEP_LENGTH);
+
+	fsm_addtimer(&wch->timer, CTCM_TIME_5_SEC, CTC_EVENT_TIMER, wch);
+	fsm_newstate(wch->fsm, CTC_STATE_TX);
+
+	spin_lock_irqsave(get_ccwdev_lock(wch->cdev), saveflags);
+	wch->prof.send_stamp = current_kernel_time(); /* xtime */
+	rc = ccw_device_start(wch->cdev, &wch->ccw[3],
+					(unsigned long) wch, 0xff, 0);
+	spin_unlock_irqrestore(get_ccwdev_lock(wch->cdev), saveflags);
+
+	if ((grp->sweep_req_pend_num == 0) &&
+	   (grp->sweep_rsp_pend_num == 0)) {
+		grp->in_sweep = 0;
+		rch->th_seq_num = 0x00;
+		wch->th_seq_num = 0x00;
+		ctcm_clear_busy_do(dev);
+	}
+
+	if (do_debug_data) {
+		ctcm_pr_debug("ctcmpc: %s()2: ToVTAM_th_seq= %08x\n" ,
+			       __FUNCTION__, wch->th_seq_num);
+		ctcm_pr_debug("ctcmpc: %s()2: FromVTAM_th_seq= %08x\n" ,
+			       __FUNCTION__, rch->th_seq_num);
+	}
+
+	if (rc != 0)
+		ctcm_ccw_check_rc(wch, rc, "send sweep");
+
+done:
+	if (do_debug)
+		ctcm_pr_debug("ctcmpc exit:  %s() %s\n", __FUNCTION__, ach->id);
+	return;
+}
+
+
+/*
+ * The ctcmpc statemachine for a channel.
+ */
+
+const fsm_node ctcmpc_ch_fsm[] = {
+	{ CTC_STATE_STOPPED,	CTC_EVENT_STOP,		ctcm_action_nop  },
+	{ CTC_STATE_STOPPED,	CTC_EVENT_START,	ctcm_chx_start  },
+	{ CTC_STATE_STOPPED,	CTC_EVENT_IO_ENODEV,	ctcm_chx_iofatal  },
+	{ CTC_STATE_STOPPED,	CTC_EVENT_FINSTAT,	ctcm_action_nop  },
+	{ CTC_STATE_STOPPED,	CTC_EVENT_MC_FAIL,	ctcm_action_nop  },
+
+	{ CTC_STATE_NOTOP,	CTC_EVENT_STOP,		ctcm_chx_stop  },
+	{ CTC_STATE_NOTOP,	CTC_EVENT_START,	ctcm_action_nop  },
+	{ CTC_STATE_NOTOP,	CTC_EVENT_FINSTAT,	ctcm_action_nop  },
+	{ CTC_STATE_NOTOP,	CTC_EVENT_MC_FAIL,	ctcm_action_nop  },
+	{ CTC_STATE_NOTOP,	CTC_EVENT_MC_GOOD,	ctcm_chx_start  },
+	{ CTC_STATE_NOTOP,	CTC_EVENT_UC_RCRESET,	ctcm_chx_stop  },
+	{ CTC_STATE_NOTOP,	CTC_EVENT_UC_RSRESET,	ctcm_chx_stop  },
+	{ CTC_STATE_NOTOP,	CTC_EVENT_IO_ENODEV,	ctcm_chx_iofatal  },
+
+	{ CTC_STATE_STARTWAIT,	CTC_EVENT_STOP,		ctcm_chx_haltio  },
+	{ CTC_STATE_STARTWAIT,	CTC_EVENT_START,	ctcm_action_nop  },
+	{ CTC_STATE_STARTWAIT,	CTC_EVENT_FINSTAT,	ctcm_chx_setmode  },
+	{ CTC_STATE_STARTWAIT,	CTC_EVENT_TIMER,	ctcm_chx_setuperr  },
+	{ CTC_STATE_STARTWAIT,	CTC_EVENT_IO_ENODEV,	ctcm_chx_iofatal  },
+	{ CTC_STATE_STARTWAIT,	CTC_EVENT_MC_FAIL,	ctcm_chx_fail  },
+
+	{ CTC_STATE_STARTRETRY,	CTC_EVENT_STOP,		ctcm_chx_haltio  },
+	{ CTC_STATE_STARTRETRY,	CTC_EVENT_TIMER,	ctcm_chx_setmode  },
+	{ CTC_STATE_STARTRETRY,	CTC_EVENT_FINSTAT,	ctcm_chx_setmode  },
+	{ CTC_STATE_STARTRETRY,	CTC_EVENT_MC_FAIL,	ctcm_chx_fail  },
+	{ CTC_STATE_STARTRETRY,	CTC_EVENT_IO_ENODEV,	ctcm_chx_iofatal  },
+
+	{ CTC_STATE_SETUPWAIT,	CTC_EVENT_STOP,		ctcm_chx_haltio  },
+	{ CTC_STATE_SETUPWAIT,	CTC_EVENT_START,	ctcm_action_nop  },
+	{ CTC_STATE_SETUPWAIT,	CTC_EVENT_FINSTAT,	ctcmpc_chx_firstio  },
+	{ CTC_STATE_SETUPWAIT,	CTC_EVENT_UC_RCRESET,	ctcm_chx_setuperr  },
+	{ CTC_STATE_SETUPWAIT,	CTC_EVENT_UC_RSRESET,	ctcm_chx_setuperr  },
+	{ CTC_STATE_SETUPWAIT,	CTC_EVENT_TIMER,	ctcm_chx_setmode  },
+	{ CTC_STATE_SETUPWAIT,	CTC_EVENT_IO_ENODEV,	ctcm_chx_iofatal  },
+	{ CTC_STATE_SETUPWAIT,	CTC_EVENT_MC_FAIL,	ctcm_chx_fail  },
+
+	{ CTC_STATE_RXINIT,	CTC_EVENT_STOP,		ctcm_chx_haltio  },
+	{ CTC_STATE_RXINIT,	CTC_EVENT_START,	ctcm_action_nop  },
+	{ CTC_STATE_RXINIT,	CTC_EVENT_FINSTAT,	ctcmpc_chx_rxidle  },
+	{ CTC_STATE_RXINIT,	CTC_EVENT_UC_RCRESET,	ctcm_chx_rxiniterr  },
+	{ CTC_STATE_RXINIT,	CTC_EVENT_UC_RSRESET,	ctcm_chx_rxiniterr  },
+	{ CTC_STATE_RXINIT,	CTC_EVENT_TIMER,	ctcm_chx_rxiniterr  },
+	{ CTC_STATE_RXINIT,	CTC_EVENT_ATTNBUSY,	ctcm_chx_rxinitfail  },
+	{ CTC_STATE_RXINIT,	CTC_EVENT_IO_ENODEV,	ctcm_chx_iofatal  },
+	{ CTC_STATE_RXINIT,	CTC_EVENT_UC_ZERO,	ctcmpc_chx_firstio  },
+	{ CTC_STATE_RXINIT,	CTC_EVENT_MC_FAIL,	ctcm_chx_fail  },
+
+	{ CH_XID0_PENDING,	CTC_EVENT_FINSTAT,	ctcm_action_nop  },
+	{ CH_XID0_PENDING,	CTC_EVENT_ATTN,		ctcmpc_chx_attn  },
+	{ CH_XID0_PENDING,	CTC_EVENT_STOP,		ctcm_chx_haltio  },
+	{ CH_XID0_PENDING,	CTC_EVENT_START,	ctcm_action_nop  },
+	{ CH_XID0_PENDING,	CTC_EVENT_IO_ENODEV,	ctcm_chx_iofatal  },
+	{ CH_XID0_PENDING,	CTC_EVENT_MC_FAIL,	ctcm_chx_fail  },
+	{ CH_XID0_PENDING,	CTC_EVENT_UC_RCRESET,	ctcm_chx_setuperr  },
+	{ CH_XID0_PENDING,	CTC_EVENT_UC_RSRESET,	ctcm_chx_setuperr  },
+	{ CH_XID0_PENDING,	CTC_EVENT_UC_RSRESET,	ctcm_chx_setuperr  },
+	{ CH_XID0_PENDING,	CTC_EVENT_ATTNBUSY,	ctcm_chx_iofatal  },
+
+	{ CH_XID0_INPROGRESS,	CTC_EVENT_FINSTAT,	ctcmpc_chx_rx  },
+	{ CH_XID0_INPROGRESS,	CTC_EVENT_ATTN,		ctcmpc_chx_attn  },
+	{ CH_XID0_INPROGRESS,	CTC_EVENT_STOP,		ctcm_chx_haltio  },
+	{ CH_XID0_INPROGRESS,	CTC_EVENT_START,	ctcm_action_nop  },
+	{ CH_XID0_INPROGRESS,	CTC_EVENT_IO_ENODEV,	ctcm_chx_iofatal  },
+	{ CH_XID0_INPROGRESS,	CTC_EVENT_MC_FAIL,	ctcm_chx_fail  },
+	{ CH_XID0_INPROGRESS,	CTC_EVENT_UC_ZERO,	ctcmpc_chx_rx  },
+	{ CH_XID0_INPROGRESS,	CTC_EVENT_UC_RCRESET,	ctcm_chx_setuperr },
+	{ CH_XID0_INPROGRESS,	CTC_EVENT_ATTNBUSY,	ctcmpc_chx_attnbusy  },
+	{ CH_XID0_INPROGRESS,	CTC_EVENT_TIMER,	ctcmpc_chx_resend  },
+	{ CH_XID0_INPROGRESS,	CTC_EVENT_IO_EBUSY,	ctcm_chx_fail  },
+
+	{ CH_XID7_PENDING,	CTC_EVENT_FINSTAT,	ctcmpc_chx_rx  },
+	{ CH_XID7_PENDING,	CTC_EVENT_ATTN,		ctcmpc_chx_attn  },
+	{ CH_XID7_PENDING,	CTC_EVENT_STOP,		ctcm_chx_haltio  },
+	{ CH_XID7_PENDING,	CTC_EVENT_START,	ctcm_action_nop  },
+	{ CH_XID7_PENDING,	CTC_EVENT_IO_ENODEV,	ctcm_chx_iofatal  },
+	{ CH_XID7_PENDING,	CTC_EVENT_MC_FAIL,	ctcm_chx_fail  },
+	{ CH_XID7_PENDING,	CTC_EVENT_UC_ZERO,	ctcmpc_chx_rx  },
+	{ CH_XID7_PENDING,	CTC_EVENT_UC_RCRESET,	ctcm_chx_setuperr  },
+	{ CH_XID7_PENDING,	CTC_EVENT_UC_RSRESET,	ctcm_chx_setuperr  },
+	{ CH_XID7_PENDING,	CTC_EVENT_UC_RSRESET,	ctcm_chx_setuperr  },
+	{ CH_XID7_PENDING,	CTC_EVENT_ATTNBUSY,	ctcm_chx_iofatal  },
+	{ CH_XID7_PENDING,	CTC_EVENT_TIMER,	ctcmpc_chx_resend  },
+	{ CH_XID7_PENDING,	CTC_EVENT_IO_EBUSY,	ctcm_chx_fail  },
+
+	{ CH_XID7_PENDING1,	CTC_EVENT_FINSTAT,	ctcmpc_chx_rx  },
+	{ CH_XID7_PENDING1,	CTC_EVENT_ATTN,		ctcmpc_chx_attn  },
+	{ CH_XID7_PENDING1,	CTC_EVENT_STOP,		ctcm_chx_haltio  },
+	{ CH_XID7_PENDING1,	CTC_EVENT_START,	ctcm_action_nop  },
+	{ CH_XID7_PENDING1,	CTC_EVENT_IO_ENODEV,	ctcm_chx_iofatal  },
+	{ CH_XID7_PENDING1,	CTC_EVENT_MC_FAIL,	ctcm_chx_fail  },
+	{ CH_XID7_PENDING1,	CTC_EVENT_UC_ZERO,	ctcmpc_chx_rx  },
+	{ CH_XID7_PENDING1,	CTC_EVENT_UC_RCRESET,	ctcm_chx_setuperr  },
+	{ CH_XID7_PENDING1,	CTC_EVENT_UC_RSRESET,	ctcm_chx_setuperr  },
+	{ CH_XID7_PENDING1,	CTC_EVENT_ATTNBUSY,	ctcm_chx_iofatal  },
+	{ CH_XID7_PENDING1,	CTC_EVENT_TIMER,	ctcmpc_chx_resend  },
+	{ CH_XID7_PENDING1,	CTC_EVENT_IO_EBUSY,	ctcm_chx_fail  },
+
+	{ CH_XID7_PENDING2,	CTC_EVENT_FINSTAT,	ctcmpc_chx_rx  },
+	{ CH_XID7_PENDING2,	CTC_EVENT_ATTN,		ctcmpc_chx_attn  },
+	{ CH_XID7_PENDING2,	CTC_EVENT_STOP,		ctcm_chx_haltio  },
+	{ CH_XID7_PENDING2,	CTC_EVENT_START,	ctcm_action_nop  },
+	{ CH_XID7_PENDING2,	CTC_EVENT_IO_ENODEV,	ctcm_chx_iofatal  },
+	{ CH_XID7_PENDING2,	CTC_EVENT_MC_FAIL,	ctcm_chx_fail  },
+	{ CH_XID7_PENDING2,	CTC_EVENT_UC_ZERO,	ctcmpc_chx_rx  },
+	{ CH_XID7_PENDING2,	CTC_EVENT_UC_RCRESET,	ctcm_chx_setuperr  },
+	{ CH_XID7_PENDING2,	CTC_EVENT_UC_RSRESET,	ctcm_chx_setuperr  },
+	{ CH_XID7_PENDING2,	CTC_EVENT_ATTNBUSY,	ctcm_chx_iofatal  },
+	{ CH_XID7_PENDING2,	CTC_EVENT_TIMER,	ctcmpc_chx_resend  },
+	{ CH_XID7_PENDING2,	CTC_EVENT_IO_EBUSY,	ctcm_chx_fail  },
+
+	{ CH_XID7_PENDING3,	CTC_EVENT_FINSTAT,	ctcmpc_chx_rx  },
+	{ CH_XID7_PENDING3,	CTC_EVENT_ATTN,		ctcmpc_chx_attn  },
+	{ CH_XID7_PENDING3,	CTC_EVENT_STOP,		ctcm_chx_haltio  },
+	{ CH_XID7_PENDING3,	CTC_EVENT_START,	ctcm_action_nop  },
+	{ CH_XID7_PENDING3,	CTC_EVENT_IO_ENODEV,	ctcm_chx_iofatal  },
+	{ CH_XID7_PENDING3,	CTC_EVENT_MC_FAIL,	ctcm_chx_fail  },
+	{ CH_XID7_PENDING3,	CTC_EVENT_UC_ZERO,	ctcmpc_chx_rx  },
+	{ CH_XID7_PENDING3,	CTC_EVENT_UC_RCRESET,	ctcm_chx_setuperr  },
+	{ CH_XID7_PENDING3,	CTC_EVENT_UC_RSRESET,	ctcm_chx_setuperr  },
+	{ CH_XID7_PENDING3,	CTC_EVENT_ATTNBUSY,	ctcm_chx_iofatal  },
+	{ CH_XID7_PENDING3,	CTC_EVENT_TIMER,	ctcmpc_chx_resend  },
+	{ CH_XID7_PENDING3,	CTC_EVENT_IO_EBUSY,	ctcm_chx_fail  },
+
+	{ CH_XID7_PENDING4,	CTC_EVENT_FINSTAT,	ctcmpc_chx_rx  },
+	{ CH_XID7_PENDING4,	CTC_EVENT_ATTN,		ctcmpc_chx_attn  },
+	{ CH_XID7_PENDING4,	CTC_EVENT_STOP,		ctcm_chx_haltio  },
+	{ CH_XID7_PENDING4,	CTC_EVENT_START,	ctcm_action_nop  },
+	{ CH_XID7_PENDING4,	CTC_EVENT_IO_ENODEV,	ctcm_chx_iofatal  },
+	{ CH_XID7_PENDING4,	CTC_EVENT_MC_FAIL,	ctcm_chx_fail  },
+	{ CH_XID7_PENDING4,	CTC_EVENT_UC_ZERO,	ctcmpc_chx_rx  },
+	{ CH_XID7_PENDING4,	CTC_EVENT_UC_RCRESET,	ctcm_chx_setuperr  },
+	{ CH_XID7_PENDING4,	CTC_EVENT_UC_RSRESET,	ctcm_chx_setuperr  },
+	{ CH_XID7_PENDING4,	CTC_EVENT_ATTNBUSY,	ctcm_chx_iofatal  },
+	{ CH_XID7_PENDING4,	CTC_EVENT_TIMER,	ctcmpc_chx_resend  },
+	{ CH_XID7_PENDING4,	CTC_EVENT_IO_EBUSY,	ctcm_chx_fail  },
+
+	{ CTC_STATE_RXIDLE,	CTC_EVENT_STOP,		ctcm_chx_haltio  },
+	{ CTC_STATE_RXIDLE,	CTC_EVENT_START,	ctcm_action_nop  },
+	{ CTC_STATE_RXIDLE,	CTC_EVENT_FINSTAT,	ctcmpc_chx_rx  },
+	{ CTC_STATE_RXIDLE,	CTC_EVENT_UC_RCRESET,	ctcm_chx_rxdisc  },
+	{ CTC_STATE_RXIDLE,	CTC_EVENT_UC_RSRESET,	ctcm_chx_fail  },
+	{ CTC_STATE_RXIDLE,	CTC_EVENT_IO_ENODEV,	ctcm_chx_iofatal  },
+	{ CTC_STATE_RXIDLE,	CTC_EVENT_MC_FAIL,	ctcm_chx_fail  },
+	{ CTC_STATE_RXIDLE,	CTC_EVENT_UC_ZERO,	ctcmpc_chx_rx  },
+
+	{ CTC_STATE_TXINIT,	CTC_EVENT_STOP,		ctcm_chx_haltio  },
+	{ CTC_STATE_TXINIT,	CTC_EVENT_START,	ctcm_action_nop  },
+	{ CTC_STATE_TXINIT,	CTC_EVENT_FINSTAT,	ctcm_chx_txidle  },
+	{ CTC_STATE_TXINIT,	CTC_EVENT_UC_RCRESET,	ctcm_chx_txiniterr  },
+	{ CTC_STATE_TXINIT,	CTC_EVENT_UC_RSRESET,	ctcm_chx_txiniterr  },
+	{ CTC_STATE_TXINIT,	CTC_EVENT_TIMER,	ctcm_chx_txiniterr  },
+	{ CTC_STATE_TXINIT,	CTC_EVENT_IO_ENODEV,	ctcm_chx_iofatal  },
+	{ CTC_STATE_TXINIT,	CTC_EVENT_MC_FAIL,	ctcm_chx_fail  },
+	{ CTC_STATE_TXINIT,	CTC_EVENT_RSWEEP_TIMER,	ctcmpc_chx_send_sweep },
+
+	{ CTC_STATE_TXIDLE,	CTC_EVENT_STOP,		ctcm_chx_haltio  },
+	{ CTC_STATE_TXIDLE,	CTC_EVENT_START,	ctcm_action_nop  },
+	{ CTC_STATE_TXIDLE,	CTC_EVENT_FINSTAT,	ctcmpc_chx_firstio  },
+	{ CTC_STATE_TXIDLE,	CTC_EVENT_UC_RCRESET,	ctcm_chx_fail  },
+	{ CTC_STATE_TXIDLE,	CTC_EVENT_UC_RSRESET,	ctcm_chx_fail  },
+	{ CTC_STATE_TXIDLE,	CTC_EVENT_IO_ENODEV,	ctcm_chx_iofatal  },
+	{ CTC_STATE_TXIDLE,	CTC_EVENT_MC_FAIL,	ctcm_chx_fail  },
+	{ CTC_STATE_TXIDLE,	CTC_EVENT_RSWEEP_TIMER,	ctcmpc_chx_send_sweep },
+
+	{ CTC_STATE_TERM,	CTC_EVENT_STOP,		ctcm_action_nop  },
+	{ CTC_STATE_TERM,	CTC_EVENT_START,	ctcm_chx_restart  },
+	{ CTC_STATE_TERM,	CTC_EVENT_FINSTAT,	ctcm_chx_stopped  },
+	{ CTC_STATE_TERM,	CTC_EVENT_UC_RCRESET,	ctcm_action_nop  },
+	{ CTC_STATE_TERM,	CTC_EVENT_UC_RSRESET,	ctcm_action_nop  },
+	{ CTC_STATE_TERM,	CTC_EVENT_MC_FAIL,	ctcm_chx_fail  },
+	{ CTC_STATE_TERM,	CTC_EVENT_IO_EBUSY,	ctcm_chx_fail  },
+	{ CTC_STATE_TERM,	CTC_EVENT_IO_ENODEV,	ctcm_chx_iofatal  },
+
+	{ CTC_STATE_DTERM,	CTC_EVENT_STOP,		ctcm_chx_haltio  },
+	{ CTC_STATE_DTERM,	CTC_EVENT_START,	ctcm_chx_restart  },
+	{ CTC_STATE_DTERM,	CTC_EVENT_FINSTAT,	ctcm_chx_setmode  },
+	{ CTC_STATE_DTERM,	CTC_EVENT_UC_RCRESET,	ctcm_action_nop  },
+	{ CTC_STATE_DTERM,	CTC_EVENT_UC_RSRESET,	ctcm_action_nop  },
+	{ CTC_STATE_DTERM,	CTC_EVENT_MC_FAIL,	ctcm_chx_fail  },
+	{ CTC_STATE_DTERM,	CTC_EVENT_IO_ENODEV,	ctcm_chx_iofatal  },
+
+	{ CTC_STATE_TX,		CTC_EVENT_STOP,		ctcm_chx_haltio  },
+	{ CTC_STATE_TX,		CTC_EVENT_START,	ctcm_action_nop  },
+	{ CTC_STATE_TX,		CTC_EVENT_FINSTAT,	ctcmpc_chx_txdone  },
+	{ CTC_STATE_TX,		CTC_EVENT_UC_RCRESET,	ctcm_chx_fail  },
+	{ CTC_STATE_TX,		CTC_EVENT_UC_RSRESET,	ctcm_chx_fail  },
+	{ CTC_STATE_TX,		CTC_EVENT_TIMER,	ctcm_chx_txretry  },
+	{ CTC_STATE_TX,		CTC_EVENT_IO_ENODEV,	ctcm_chx_iofatal  },
+	{ CTC_STATE_TX,		CTC_EVENT_MC_FAIL,	ctcm_chx_fail  },
+	{ CTC_STATE_TX,		CTC_EVENT_RSWEEP_TIMER,	ctcmpc_chx_send_sweep },
+	{ CTC_STATE_TX,		CTC_EVENT_IO_EBUSY,	ctcm_chx_fail  },
+
+	{ CTC_STATE_RXERR,	CTC_EVENT_STOP,		ctcm_chx_haltio  },
+	{ CTC_STATE_TXERR,	CTC_EVENT_STOP,		ctcm_chx_haltio  },
+	{ CTC_STATE_TXERR,	CTC_EVENT_IO_ENODEV,	ctcm_chx_iofatal  },
+	{ CTC_STATE_TXERR,	CTC_EVENT_MC_FAIL,	ctcm_chx_fail  },
+	{ CTC_STATE_RXERR,	CTC_EVENT_MC_FAIL,	ctcm_chx_fail  },
+};
+
+int mpc_ch_fsm_len = ARRAY_SIZE(ctcmpc_ch_fsm);
+
+/*
+ * Actions for interface - statemachine.
+ */
+
+/**
+ * Startup channels by sending CTC_EVENT_START to each channel.
+ *
+ * fi		An instance of an interface statemachine.
+ * event	The event, just happened.
+ * arg		Generic pointer, casted from struct net_device * upon call.
+ */
+static void dev_action_start(fsm_instance *fi, int event, void *arg)
+{
+	struct net_device *dev = arg;
+	struct ctcm_priv *priv = dev->priv;
+	int direction;
+
+	CTCMY_DBF_DEV_NAME(SETUP, dev, "");
+
+	fsm_deltimer(&priv->restart_timer);
+	fsm_newstate(fi, DEV_STATE_STARTWAIT_RXTX);
+	if (IS_MPC(priv))
+		priv->mpcg->channels_terminating = 0;
+	for (direction = READ; direction <= WRITE; direction++) {
+		struct channel *ch = priv->channel[direction];
+		fsm_event(ch->fsm, CTC_EVENT_START, ch);
+	}
+}
+
+/**
+ * Shutdown channels by sending CTC_EVENT_STOP to each channel.
+ *
+ * fi		An instance of an interface statemachine.
+ * event	The event, just happened.
+ * arg		Generic pointer, casted from struct net_device * upon call.
+ */
+static void dev_action_stop(fsm_instance *fi, int event, void *arg)
+{
+	int direction;
+	struct net_device *dev = arg;
+	struct ctcm_priv *priv = dev->priv;
+
+	CTCMY_DBF_DEV_NAME(SETUP, dev, "");
+
+	fsm_newstate(fi, DEV_STATE_STOPWAIT_RXTX);
+	for (direction = READ; direction <= WRITE; direction++) {
+		struct channel *ch = priv->channel[direction];
+		fsm_event(ch->fsm, CTC_EVENT_STOP, ch);
+		ch->th_seq_num = 0x00;
+	if (do_debug)
+		ctcm_pr_debug("ctcm: %s() CH_th_seq= %08x\n",
+				__FUNCTION__, ch->th_seq_num);
+	}
+	if (IS_MPC(priv))
+		fsm_newstate(priv->mpcg->fsm, MPCG_STATE_RESET);
+}
+
+static void dev_action_restart(fsm_instance *fi, int event, void *arg)
+{
+	int restart_timer;
+	struct net_device *dev = arg;
+	struct ctcm_priv *priv = dev->priv;
+
+	CTCMY_DBF_DEV_NAME(TRACE, dev, "");
+
+	if (IS_MPC(priv)) {
+		ctcm_pr_info("ctcm: %s Restarting Device and "
+		       "MPC Group in 5 seconds\n",
+		       dev->name);
+		restart_timer = CTCM_TIME_1_SEC;
+	} else {
+		ctcm_pr_info("%s: Restarting\n", dev->name);
+		restart_timer = CTCM_TIME_5_SEC;
+	}
+
+	dev_action_stop(fi, event, arg);
+	fsm_event(priv->fsm, DEV_EVENT_STOP, dev);
+	if (IS_MPC(priv))
+		fsm_newstate(priv->mpcg->fsm, MPCG_STATE_RESET);
+
+	/* going back into start sequence too quickly can	  */
+	/* result in the other side becoming unreachable   due	  */
+	/* to sense reported when IO is aborted			  */
+	fsm_addtimer(&priv->restart_timer, restart_timer,
+			DEV_EVENT_START, dev);
+}
+
+/**
+ * Called from channel statemachine
+ * when a channel is up and running.
+ *
+ * fi		An instance of an interface statemachine.
+ * event	The event, just happened.
+ * arg		Generic pointer, casted from struct net_device * upon call.
+ */
+static void dev_action_chup(fsm_instance *fi, int event, void *arg)
+{
+	struct net_device *dev = arg;
+	struct ctcm_priv *priv = dev->priv;
+
+	CTCMY_DBF_DEV_NAME(SETUP, dev, "");
+
+	switch (fsm_getstate(fi)) {
+	case DEV_STATE_STARTWAIT_RXTX:
+		if (event == DEV_EVENT_RXUP)
+			fsm_newstate(fi, DEV_STATE_STARTWAIT_TX);
+		else
+			fsm_newstate(fi, DEV_STATE_STARTWAIT_RX);
+		break;
+	case DEV_STATE_STARTWAIT_RX:
+		if (event == DEV_EVENT_RXUP) {
+			fsm_newstate(fi, DEV_STATE_RUNNING);
+			ctcm_pr_info("%s: connected with remote side\n",
+				    dev->name);
+			ctcm_clear_busy(dev);
+		}
+		break;
+	case DEV_STATE_STARTWAIT_TX:
+		if (event == DEV_EVENT_TXUP) {
+			fsm_newstate(fi, DEV_STATE_RUNNING);
+			ctcm_pr_info("%s: connected with remote side\n",
+				    dev->name);
+			ctcm_clear_busy(dev);
+		}
+		break;
+	case DEV_STATE_STOPWAIT_TX:
+		if (event == DEV_EVENT_RXUP)
+			fsm_newstate(fi, DEV_STATE_STOPWAIT_RXTX);
+		break;
+	case DEV_STATE_STOPWAIT_RX:
+		if (event == DEV_EVENT_TXUP)
+			fsm_newstate(fi, DEV_STATE_STOPWAIT_RXTX);
+		break;
+	}
+
+	if (IS_MPC(priv)) {
+		if (event == DEV_EVENT_RXUP)
+			mpc_channel_action(priv->channel[READ],
+				READ, MPC_CHANNEL_ADD);
+		else
+			mpc_channel_action(priv->channel[WRITE],
+				WRITE, MPC_CHANNEL_ADD);
+	}
+}
+
+/**
+ * Called from device statemachine
+ * when a channel has been shutdown.
+ *
+ * fi		An instance of an interface statemachine.
+ * event	The event, just happened.
+ * arg		Generic pointer, casted from struct net_device * upon call.
+ */
+static void dev_action_chdown(fsm_instance *fi, int event, void *arg)
+{
+
+	struct net_device *dev = arg;
+	struct ctcm_priv *priv = dev->priv;
+
+	CTCMY_DBF_DEV_NAME(SETUP, dev, "");
+
+	switch (fsm_getstate(fi)) {
+	case DEV_STATE_RUNNING:
+		if (event == DEV_EVENT_TXDOWN)
+			fsm_newstate(fi, DEV_STATE_STARTWAIT_TX);
+		else
+			fsm_newstate(fi, DEV_STATE_STARTWAIT_RX);
+		break;
+	case DEV_STATE_STARTWAIT_RX:
+		if (event == DEV_EVENT_TXDOWN)
+			fsm_newstate(fi, DEV_STATE_STARTWAIT_RXTX);
+		break;
+	case DEV_STATE_STARTWAIT_TX:
+		if (event == DEV_EVENT_RXDOWN)
+			fsm_newstate(fi, DEV_STATE_STARTWAIT_RXTX);
+		break;
+	case DEV_STATE_STOPWAIT_RXTX:
+		if (event == DEV_EVENT_TXDOWN)
+			fsm_newstate(fi, DEV_STATE_STOPWAIT_RX);
+		else
+			fsm_newstate(fi, DEV_STATE_STOPWAIT_TX);
+		break;
+	case DEV_STATE_STOPWAIT_RX:
+		if (event == DEV_EVENT_RXDOWN)
+			fsm_newstate(fi, DEV_STATE_STOPPED);
+		break;
+	case DEV_STATE_STOPWAIT_TX:
+		if (event == DEV_EVENT_TXDOWN)
+			fsm_newstate(fi, DEV_STATE_STOPPED);
+		break;
+	}
+	if (IS_MPC(priv)) {
+		if (event == DEV_EVENT_RXDOWN)
+			mpc_channel_action(priv->channel[READ],
+				READ, MPC_CHANNEL_REMOVE);
+		else
+			mpc_channel_action(priv->channel[WRITE],
+				WRITE, MPC_CHANNEL_REMOVE);
+	}
+}
+
+const fsm_node dev_fsm[] = {
+	{ DEV_STATE_STOPPED,        DEV_EVENT_START,   dev_action_start   },
+	{ DEV_STATE_STOPWAIT_RXTX,  DEV_EVENT_START,   dev_action_start   },
+	{ DEV_STATE_STOPWAIT_RXTX,  DEV_EVENT_RXDOWN,  dev_action_chdown  },
+	{ DEV_STATE_STOPWAIT_RXTX,  DEV_EVENT_TXDOWN,  dev_action_chdown  },
+	{ DEV_STATE_STOPWAIT_RXTX,  DEV_EVENT_RESTART, dev_action_restart },
+	{ DEV_STATE_STOPWAIT_RX,    DEV_EVENT_START,   dev_action_start   },
+	{ DEV_STATE_STOPWAIT_RX,    DEV_EVENT_RXUP,    dev_action_chup    },
+	{ DEV_STATE_STOPWAIT_RX,    DEV_EVENT_TXUP,    dev_action_chup    },
+	{ DEV_STATE_STOPWAIT_RX,    DEV_EVENT_RXDOWN,  dev_action_chdown  },
+	{ DEV_STATE_STOPWAIT_RX,    DEV_EVENT_RESTART, dev_action_restart },
+	{ DEV_STATE_STOPWAIT_TX,    DEV_EVENT_START,   dev_action_start   },
+	{ DEV_STATE_STOPWAIT_TX,    DEV_EVENT_RXUP,    dev_action_chup    },
+	{ DEV_STATE_STOPWAIT_TX,    DEV_EVENT_TXUP,    dev_action_chup    },
+	{ DEV_STATE_STOPWAIT_TX,    DEV_EVENT_TXDOWN,  dev_action_chdown  },
+	{ DEV_STATE_STOPWAIT_TX,    DEV_EVENT_RESTART, dev_action_restart },
+	{ DEV_STATE_STARTWAIT_RXTX, DEV_EVENT_STOP,    dev_action_stop    },
+	{ DEV_STATE_STARTWAIT_RXTX, DEV_EVENT_RXUP,    dev_action_chup    },
+	{ DEV_STATE_STARTWAIT_RXTX, DEV_EVENT_TXUP,    dev_action_chup    },
+	{ DEV_STATE_STARTWAIT_RXTX, DEV_EVENT_RXDOWN,  dev_action_chdown  },
+	{ DEV_STATE_STARTWAIT_RXTX, DEV_EVENT_TXDOWN,  dev_action_chdown  },
+	{ DEV_STATE_STARTWAIT_RXTX, DEV_EVENT_RESTART, dev_action_restart },
+	{ DEV_STATE_STARTWAIT_TX,   DEV_EVENT_STOP,    dev_action_stop    },
+	{ DEV_STATE_STARTWAIT_TX,   DEV_EVENT_RXUP,    dev_action_chup    },
+	{ DEV_STATE_STARTWAIT_TX,   DEV_EVENT_TXUP,    dev_action_chup    },
+	{ DEV_STATE_STARTWAIT_TX,   DEV_EVENT_RXDOWN,  dev_action_chdown  },
+	{ DEV_STATE_STARTWAIT_TX,   DEV_EVENT_RESTART, dev_action_restart },
+	{ DEV_STATE_STARTWAIT_RX,   DEV_EVENT_STOP,    dev_action_stop    },
+	{ DEV_STATE_STARTWAIT_RX,   DEV_EVENT_RXUP,    dev_action_chup    },
+	{ DEV_STATE_STARTWAIT_RX,   DEV_EVENT_TXUP,    dev_action_chup    },
+	{ DEV_STATE_STARTWAIT_RX,   DEV_EVENT_TXDOWN,  dev_action_chdown  },
+	{ DEV_STATE_STARTWAIT_RX,   DEV_EVENT_RESTART, dev_action_restart },
+	{ DEV_STATE_RUNNING,        DEV_EVENT_STOP,    dev_action_stop    },
+	{ DEV_STATE_RUNNING,        DEV_EVENT_RXDOWN,  dev_action_chdown  },
+	{ DEV_STATE_RUNNING,        DEV_EVENT_TXDOWN,  dev_action_chdown  },
+	{ DEV_STATE_RUNNING,        DEV_EVENT_TXUP,    ctcm_action_nop    },
+	{ DEV_STATE_RUNNING,        DEV_EVENT_RXUP,    ctcm_action_nop    },
+	{ DEV_STATE_RUNNING,        DEV_EVENT_RESTART, dev_action_restart },
+};
+
+int dev_fsm_len = ARRAY_SIZE(dev_fsm);
+
+/* --- This is the END my friend --- */
+

-- 
