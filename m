From: Ursula Braun <braunu@de.ibm.com>
Subject: [patch 5/7] ctcm: replaced ctc driver - part 2
Date: Fri, 01 Feb 2008 15:51:33 +0100
Message-ID: <20080201145259.375938000@linux.vnet.ibm.com>
References: <20080201145128.462823000@linux.vnet.ibm.com>
Cc: Peter Tiedemann <ptiedem@de.ibm.com>
To: jgarzik@pobox.com, netdev@vger.kernel.org,
	linux-s390@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mtagate3.de.ibm.com ([195.212.29.152]:31861 "EHLO
	mtagate3.de.ibm.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1755179AbYBAOxD (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 1 Feb 2008 09:53:03 -0500
Content-Disposition: inline; filename=ctcm_fsm.diff
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Peter Tiedemann <ptiedem@de.ibm.com>

ctcm driver supports the channel-to-channel connections of the
old ctc driver plus an additional MPC protocol to provide SNA
connectivity.
This is part 2 of the ctcm-stuff comprising
    the final state machines for the ctc-driver

Signed-off-by: Peter Tiedemann <ptiedem@de.ibm.com>
Signed-off-by: Ursula Braun <braunu@de.ibm.com>

---
 drivers/s390/net/ctcm_fsms.c | 2338 +++++++++++++++++++++++++++++++++++++++++++
 drivers/s390/net/ctcm_fsms.h |  359 ++++++
 2 files changed, 2697 insertions(+)

Index: linux-2.6-uschi/drivers/s390/net/ctcm_fsms.c
===================================================================
--- /dev/null
+++ linux-2.6-uschi/drivers/s390/net/ctcm_fsms.c
@@ -0,0 +1,2338 @@
+/*
+ * drivers/s390/net/ctcm_fsms.c
+ *
+ * Copyright IBM Corp. 2001, 2007
+ * Authors:	Fritz Elfert (felfert@millenux.com)
+ * 		Peter Tiedemann (ptiedem@de.ibm.com)
+ * 	MPC additions :
+ * 		Belinda Thompson (belindat@us.ibm.com)
+ * 		Andy Richter (richtera@us.ibm.com)
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
+ * @param ch	      The channel, the error belongs to.
+ * @param return_code The error code (!= 0) to inspect.
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
+/*
+ * Actions for channel - statemachines.
+ */
+
+/**
+ * Normal data has been send. Free the corresponding
+ * skb (it's in io_queue), reset dev->tbusy and
+ * revert to idle state.
+ *
+ * @param fi	An instance of a channel statemachine.
+ * @param event The event, just happened.
+ * @param arg	Generic pointer, casted from channel * upon call.
+ */
+static void chx_txdone(fsm_instance *fi, int event, void *arg)
+{
+	struct channel *ch = (struct channel *)arg;
+	struct net_device *dev = ch->netdev;
+	struct ctcm_priv *privptr = dev->priv;
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
+		privptr->stats.tx_packets++;
+		privptr->stats.tx_bytes += skb->len - LL_HEADER_LENGTH;
+		if (first) {
+			privptr->stats.tx_bytes += 2;
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
+			privptr->stats.tx_packets++;
+			privptr->stats.tx_bytes += skb->len - LL_HEADER_LENGTH;
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
+			privptr->stats.tx_dropped += i;
+			privptr->stats.tx_errors += i;
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
+ * @param fi	An instance of a channel statemachine.
+ * @param event The event, just happened.
+ * @param arg	Generic pointer, casted from channel * upon call.
+ */
+void ctcm_chx_txidle(fsm_instance *fi, int event, void *arg)
+{
+	struct channel *ch = (struct channel *)arg;
+
+	CTCM_DBF_TEXT(TRACE, 6, __FUNCTION__);
+	fsm_deltimer(&ch->timer);
+	fsm_newstate(fi, CTC_STATE_TXIDLE);
+	fsm_event(((struct ctcm_priv *)ch->netdev->priv)->fsm, DEV_EVENT_TXUP,
+		  ch->netdev);
+}
+
+/**
+ * Got normal data, check for sanity, queue it up, allocate new buffer
+ * trigger bottom half, and initiate next read.
+ *
+ * @param fi	An instance of a channel statemachine.
+ * @param event The event, just happened.
+ * @param arg	Generic pointer, casted from channel * upon call.
+ */
+static void chx_rx(fsm_instance *fi, int event, void *arg)
+{
+	struct channel *ch = (struct channel *)arg;
+	struct net_device *dev = ch->netdev;
+	struct ctcm_priv *privptr = dev->priv;
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
+		privptr->stats.rx_dropped++;
+		privptr->stats.rx_length_errors++;
+						goto again;
+	}
+	if (len > ch->max_bufsize) {
+		ctcm_pr_debug("%s: got packet with length %d > %d\n",
+			     dev->name, len, ch->max_bufsize);
+		privptr->stats.rx_dropped++;
+		privptr->stats.rx_length_errors++;
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
+		privptr->stats.rx_dropped++;
+		privptr->stats.rx_length_errors++;
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
+static void chx_rxidle(fsm_instance *fi, int event, void *arg);
+
+/**
+ * Initialize connection by sending a __u16 of value 0.
+ *
+ * @param fi	An instance of a channel statemachine.
+ * @param event The event, just happened.
+ * @param arg	Generic pointer, casted from channel * upon call.
+ */
+static void chx_firstio(fsm_instance *fi, int event, void *arg)
+{
+	struct channel *ch = (struct channel *)arg;
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
+			fsm_newstate(fi, CTC_STATE_TXIDLE);
+			fsm_event(((struct ctcm_priv *)dev->priv)->fsm,
+				  DEV_EVENT_TXUP, dev);
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
+		fsm_event(((struct ctcm_priv *)dev->priv)->fsm, DEV_EVENT_RXUP,
+			  dev);
+	}
+}
+
+/**
+ * Got initial data, check it. If OK,
+ * notify device statemachine that we are up and
+ * running.
+ *
+ * @param fi	An instance of a channel statemachine.
+ * @param event The event, just happened.
+ * @param arg	Generic pointer, casted from channel * upon call.
+ */
+static void chx_rxidle(fsm_instance *fi, int event, void *arg)
+{
+	struct channel *ch = (struct channel *)arg;
+	struct net_device *dev = ch->netdev;
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
+			fsm_event(((struct ctcm_priv *)dev->priv)->fsm,
+				  DEV_EVENT_RXUP, dev);
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
+ * @param fi	An instance of a channel statemachine.
+ * @param event The event, just happened.
+ * @param arg	Generic pointer, casted from channel * upon call.
+ */
+static void ctcm_chx_setmode(fsm_instance *fi, int event, void *arg)
+{
+	struct channel *ch = (struct channel *)arg;
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
+ * @param fi	An instance of a channel statemachine.
+ * @param event The event, just happened.
+ * @param arg	Generic pointer, casted from channel * upon call.
+ */
+static void ctcm_chx_start(fsm_instance *fi, int event, void *arg)
+{
+	struct channel *ch = (struct channel *)arg;
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
+ * @param fi	An instance of a channel statemachine.
+ * @param event The event, just happened.
+ * @param arg	Generic pointer, casted from channel * upon call.
+ */
+static void ctcm_chx_haltio(fsm_instance *fi, int event, void *arg)
+{
+	struct channel *ch = (struct channel *)arg;
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
+ * @param fi	An instance of a channel statemachine.
+ * @param state The next state (depending on caller).
+ * @param ch 	The channel to operate on.
+ */
+static void ctcm_chx_cleanup(fsm_instance *fi, int state,
+		struct channel *ch)
+{
+	struct net_device *dev = ch->netdev;
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
+		fsm_event(((struct ctcm_priv *)dev->priv)->fsm,
+			  DEV_EVENT_RXDOWN, dev);
+	} else {
+		ctcm_purge_skb_queue(&ch->io_queue);
+		if (IS_MPC(ch))
+			ctcm_purge_skb_queue(&ch->sweep_queue);
+		spin_lock(&ch->collect_lock);
+		ctcm_purge_skb_queue(&ch->collect_queue);
+		ch->collect_len = 0;
+		spin_unlock(&ch->collect_lock);
+		fsm_event(((struct ctcm_priv *)dev->priv)->fsm,
+			  DEV_EVENT_TXDOWN, dev);
+	}
+}
+
+/**
+ * A channel has successfully been halted.
+ * Cleanup it's queue and notify interface statemachine.
+ *
+ * @param fi	An instance of a channel statemachine.
+ * @param event The event, just happened.
+ * @param arg	Generic pointer, casted from channel * upon call.
+ */
+static void ctcm_chx_stopped(fsm_instance *fi, int event, void *arg)
+{
+	CTCM_DBF_TEXT(TRACE, 3, __FUNCTION__);
+	ctcm_chx_cleanup(fi, CTC_STATE_STOPPED, (struct channel *)arg);
+}
+
+/**
+ * A stop command from device statemachine arrived and we are in
+ * not operational mode. Set state to stopped.
+ *
+ * @param fi	An instance of a channel statemachine.
+ * @param event The event, just happened.
+ * @param arg	Generic pointer, casted from channel * upon call.
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
+ * @param fi	An instance of a channel statemachine.
+ * @param event The event, just happened.
+ * @param arg	Generic pointer, casted from channel * upon call.
+ */
+static void ctcm_chx_fail(fsm_instance *fi, int event, void *arg)
+{
+	CTCM_DBF_TEXT(TRACE, 3, __FUNCTION__);
+	ctcm_chx_cleanup(fi, CTC_STATE_NOTOP, (struct channel *)arg);
+}
+
+/**
+ * Handle error during setup of channel.
+ *
+ * @param fi	An instance of a channel statemachine.
+ * @param event The event, just happened.
+ * @param arg	Generic pointer, casted from channel * upon call.
+ */
+static void ctcm_chx_setuperr(fsm_instance *fi, int event, void *arg)
+{
+	struct channel *ch = (struct channel *)arg;
+	struct net_device *dev = ch->netdev;
+	struct ctcm_priv *priv = (struct ctcm_priv *)dev->priv;
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
+ * @param fi	An instance of a channel statemachine.
+ * @param event The event, just happened.
+ * @param arg	Generic pointer, casted from channel * upon call.
+ */
+static void ctcm_chx_restart(fsm_instance *fi, int event, void *arg)
+{
+	struct channel *ch = (struct channel *)arg;
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
+ * @param fi	An instance of a channel statemachine.
+ * @param event The event, just happened.
+ * @param arg	Generic pointer, casted from channel * upon call.
+ */
+static void ctcm_chx_rxiniterr(fsm_instance *fi, int event, void *arg)
+{
+	struct channel *ch = (struct channel *)arg;
+	struct net_device *dev = ch->netdev;
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
+			fsm_event(((struct ctcm_priv *)dev->priv)->fsm,
+				  DEV_EVENT_RXDOWN, dev);
+		}
+	} else
+		ctcm_pr_warn("%s: Error during RX init handshake\n", dev->name);
+}
+
+/**
+ * Notify device statemachine if we gave up initialization
+ * of RX channel.
+ *
+ * @param fi	An instance of a channel statemachine.
+ * @param event The event, just happened.
+ * @param arg	Generic pointer, casted from channel * upon call.
+ */
+static void ctcm_chx_rxinitfail(fsm_instance *fi, int event, void *arg)
+{
+	struct channel *ch = (struct channel *)arg;
+	struct net_device *dev = ch->netdev;
+
+	CTCM_DBF_TEXT(SETUP, 3, __FUNCTION__);
+	fsm_newstate(fi, CTC_STATE_RXERR);
+	ctcm_pr_warn("%s: RX busy. Initialization failed\n", dev->name);
+	fsm_event(((struct ctcm_priv *)dev->priv)->fsm, DEV_EVENT_RXDOWN, dev);
+}
+
+/**
+ * Handle RX Unit check remote reset (remote disconnected)
+ *
+ * @param fi	An instance of a channel statemachine.
+ * @param event The event, just happened.
+ * @param arg	Generic pointer, casted from channel * upon call.
+ */
+static void ctcm_chx_rxdisc(fsm_instance *fi, int event, void *arg)
+{
+	struct channel *ch = (struct channel *)arg;
+	struct channel *ch2;
+	struct net_device *dev = ch->netdev;
+
+	CTCM_DBF_DEV_NAME(TRACE, dev, "Got remote disconnect, re-initializing");
+	fsm_deltimer(&ch->timer);
+	if (do_debug)
+		ctcm_pr_debug("%s: Got remote disconnect, "
+				"re-initializing ...\n", dev->name);
+	/*
+	 * Notify device statemachine
+	 */
+	fsm_event(((struct ctcm_priv *)dev->priv)->fsm, DEV_EVENT_RXDOWN, dev);
+	fsm_event(((struct ctcm_priv *)dev->priv)->fsm, DEV_EVENT_TXDOWN, dev);
+
+	fsm_newstate(fi, CTC_STATE_DTERM);
+	ch2 = ((struct ctcm_priv *)dev->priv)->channel[WRITE];
+	fsm_newstate(ch2->fsm, CTC_STATE_DTERM);
+
+	ccw_device_halt(ch->cdev, (unsigned long)ch);
+	ccw_device_halt(ch2->cdev, (unsigned long)ch2);
+}
+
+/**
+ * Handle error during TX channel initialization.
+ *
+ * @param fi	An instance of a channel statemachine.
+ * @param event The event, just happened.
+ * @param arg	Generic pointer, casted from channel * upon call.
+ */
+static void ctcm_chx_txiniterr(fsm_instance *fi, int event, void *arg)
+{
+	struct channel *ch = (struct channel *)arg;
+	struct net_device *dev = ch->netdev;
+
+	if (event == CTC_EVENT_TIMER) {
+		fsm_deltimer(&ch->timer);
+		CTCM_DBF_DEV_NAME(ERROR, dev,
+				"Timeout during TX init handshake");
+		if (ch->retry++ < 3)
+			ctcm_chx_restart(fi, event, arg);
+		else {
+			fsm_newstate(fi, CTC_STATE_TXERR);
+			fsm_event(((struct ctcm_priv *)dev->priv)->fsm,
+					DEV_EVENT_TXDOWN, dev);
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
+ * @param fi	An instance of a channel statemachine.
+ * @param event The event, just happened.
+ * @param arg	Generic pointer, casted from channel * upon call.
+ */
+static void ctcm_chx_txretry(fsm_instance *fi, int event, void *arg)
+{
+	struct channel *ch = (struct channel *)arg;
+	struct net_device *dev = ch->netdev;
+	struct ctcm_priv *priv = (struct ctcm_priv *)dev->priv;
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
+ * @param fi	An instance of a channel statemachine.
+ * @param event The event, just happened.
+ * @param arg	Generic pointer, casted from channel * upon call.
+ */
+static void ctcm_chx_iofatal(fsm_instance *fi, int event, void *arg)
+{
+	struct channel *ch = (struct channel *)arg;
+	struct net_device *dev = ch->netdev;
+
+	CTCM_DBF_TEXT(TRACE, 3, __FUNCTION__);
+	fsm_deltimer(&ch->timer);
+	ctcm_pr_warn("%s %s : unrecoverable channel error\n",
+			CTC_DRIVER_NAME, dev->name);
+	if (IS_MPC(ch)) {
+		((struct ctcm_priv *)dev->priv)->stats.tx_dropped++;
+		((struct ctcm_priv *)dev->priv)->stats.tx_errors++;
+	}
+
+	if (CHANNEL_DIRECTION(ch->flags) == READ) {
+		ctcm_pr_debug("%s: RX I/O error\n", dev->name);
+		fsm_newstate(fi, CTC_STATE_RXERR);
+		fsm_event(((struct ctcm_priv *)dev->priv)->fsm,
+			  DEV_EVENT_RXDOWN, dev);
+	} else {
+		ctcm_pr_debug("%s: TX I/O error\n", dev->name);
+		fsm_newstate(fi, CTC_STATE_TXERR);
+		fsm_event(((struct ctcm_priv *)dev->priv)->fsm,
+			  DEV_EVENT_TXDOWN, dev);
+	}
+}
+
+/*
+ * The ctcm statemachine for a channel.
+ */
+const fsm_node ch_fsm[] = {
+	{ CTC_STATE_STOPPED,	CTC_EVENT_STOP,		fsm_action_nop  },
+	{ CTC_STATE_STOPPED,	CTC_EVENT_START,	ctcm_chx_start  },
+	{ CTC_STATE_STOPPED,	CTC_EVENT_FINSTAT,	fsm_action_nop  },
+	{ CTC_STATE_STOPPED,	CTC_EVENT_MC_FAIL,	fsm_action_nop  },
+
+	{ CTC_STATE_NOTOP,	CTC_EVENT_STOP,		ctcm_chx_stop  },
+	{ CTC_STATE_NOTOP,	CTC_EVENT_START,	fsm_action_nop  },
+	{ CTC_STATE_NOTOP,	CTC_EVENT_FINSTAT,	fsm_action_nop  },
+	{ CTC_STATE_NOTOP,	CTC_EVENT_MC_FAIL,	fsm_action_nop  },
+	{ CTC_STATE_NOTOP,	CTC_EVENT_MC_GOOD,	ctcm_chx_start  },
+
+	{ CTC_STATE_STARTWAIT,	CTC_EVENT_STOP,		ctcm_chx_haltio  },
+	{ CTC_STATE_STARTWAIT,	CTC_EVENT_START,	fsm_action_nop  },
+	{ CTC_STATE_STARTWAIT,	CTC_EVENT_FINSTAT,	ctcm_chx_setmode  },
+	{ CTC_STATE_STARTWAIT,	CTC_EVENT_TIMER,	ctcm_chx_setuperr  },
+	{ CTC_STATE_STARTWAIT,	CTC_EVENT_IO_ENODEV,	ctcm_chx_iofatal  },
+	{ CTC_STATE_STARTWAIT,	CTC_EVENT_MC_FAIL,	ctcm_chx_fail  },
+
+	{ CTC_STATE_STARTRETRY,	CTC_EVENT_STOP,		ctcm_chx_haltio  },
+	{ CTC_STATE_STARTRETRY,	CTC_EVENT_TIMER,	ctcm_chx_setmode  },
+	{ CTC_STATE_STARTRETRY,	CTC_EVENT_FINSTAT,	fsm_action_nop  },
+	{ CTC_STATE_STARTRETRY,	CTC_EVENT_MC_FAIL,	ctcm_chx_fail  },
+
+	{ CTC_STATE_SETUPWAIT,	CTC_EVENT_STOP,		ctcm_chx_haltio  },
+	{ CTC_STATE_SETUPWAIT,	CTC_EVENT_START,	fsm_action_nop  },
+	{ CTC_STATE_SETUPWAIT,	CTC_EVENT_FINSTAT,	chx_firstio  },
+	{ CTC_STATE_SETUPWAIT,	CTC_EVENT_UC_RCRESET,	ctcm_chx_setuperr  },
+	{ CTC_STATE_SETUPWAIT,	CTC_EVENT_UC_RSRESET,	ctcm_chx_setuperr  },
+	{ CTC_STATE_SETUPWAIT,	CTC_EVENT_TIMER,	ctcm_chx_setmode  },
+	{ CTC_STATE_SETUPWAIT,	CTC_EVENT_IO_ENODEV,	ctcm_chx_iofatal  },
+	{ CTC_STATE_SETUPWAIT,	CTC_EVENT_MC_FAIL,	ctcm_chx_fail  },
+
+	{ CTC_STATE_RXINIT,	CTC_EVENT_STOP,		ctcm_chx_haltio  },
+	{ CTC_STATE_RXINIT,	CTC_EVENT_START,	fsm_action_nop  },
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
+	{ CTC_STATE_RXIDLE,	CTC_EVENT_START,	fsm_action_nop  },
+	{ CTC_STATE_RXIDLE,	CTC_EVENT_FINSTAT,	chx_rx  },
+	{ CTC_STATE_RXIDLE,	CTC_EVENT_UC_RCRESET,	ctcm_chx_rxdisc  },
+	{ CTC_STATE_RXIDLE,	CTC_EVENT_IO_ENODEV,	ctcm_chx_iofatal  },
+	{ CTC_STATE_RXIDLE,	CTC_EVENT_MC_FAIL,	ctcm_chx_fail  },
+	{ CTC_STATE_RXIDLE,	CTC_EVENT_UC_ZERO,	chx_rx  },
+
+	{ CTC_STATE_TXINIT,	CTC_EVENT_STOP,		ctcm_chx_haltio  },
+	{ CTC_STATE_TXINIT,	CTC_EVENT_START,	fsm_action_nop  },
+	{ CTC_STATE_TXINIT,	CTC_EVENT_FINSTAT,	ctcm_chx_txidle  },
+	{ CTC_STATE_TXINIT,	CTC_EVENT_UC_RCRESET,	ctcm_chx_txiniterr  },
+	{ CTC_STATE_TXINIT,	CTC_EVENT_UC_RSRESET,	ctcm_chx_txiniterr  },
+	{ CTC_STATE_TXINIT,	CTC_EVENT_TIMER,	ctcm_chx_txiniterr  },
+	{ CTC_STATE_TXINIT,	CTC_EVENT_IO_ENODEV,	ctcm_chx_iofatal  },
+	{ CTC_STATE_TXINIT,	CTC_EVENT_MC_FAIL,	ctcm_chx_fail  },
+
+	{ CTC_STATE_TXIDLE,	CTC_EVENT_STOP,		ctcm_chx_haltio  },
+	{ CTC_STATE_TXIDLE,	CTC_EVENT_START,	fsm_action_nop  },
+	{ CTC_STATE_TXIDLE,	CTC_EVENT_FINSTAT,	chx_firstio  },
+	{ CTC_STATE_TXIDLE,	CTC_EVENT_UC_RCRESET,	fsm_action_nop  },
+	{ CTC_STATE_TXIDLE,	CTC_EVENT_UC_RSRESET,	fsm_action_nop  },
+	{ CTC_STATE_TXIDLE,	CTC_EVENT_IO_ENODEV,	ctcm_chx_iofatal  },
+	{ CTC_STATE_TXIDLE,	CTC_EVENT_MC_FAIL,	ctcm_chx_fail  },
+
+	{ CTC_STATE_TERM,	CTC_EVENT_STOP,		fsm_action_nop  },
+	{ CTC_STATE_TERM,	CTC_EVENT_START,	ctcm_chx_restart  },
+	{ CTC_STATE_TERM,	CTC_EVENT_FINSTAT,	ctcm_chx_stopped  },
+	{ CTC_STATE_TERM,	CTC_EVENT_UC_RCRESET,	fsm_action_nop  },
+	{ CTC_STATE_TERM,	CTC_EVENT_UC_RSRESET,	fsm_action_nop  },
+	{ CTC_STATE_TERM,	CTC_EVENT_MC_FAIL,	ctcm_chx_fail  },
+
+	{ CTC_STATE_DTERM,	CTC_EVENT_STOP,		ctcm_chx_haltio  },
+	{ CTC_STATE_DTERM,	CTC_EVENT_START,	ctcm_chx_restart  },
+	{ CTC_STATE_DTERM,	CTC_EVENT_FINSTAT,	ctcm_chx_setmode  },
+	{ CTC_STATE_DTERM,	CTC_EVENT_UC_RCRESET,	fsm_action_nop  },
+	{ CTC_STATE_DTERM,	CTC_EVENT_UC_RSRESET,	fsm_action_nop  },
+	{ CTC_STATE_DTERM,	CTC_EVENT_MC_FAIL,	ctcm_chx_fail  },
+
+	{ CTC_STATE_TX,		CTC_EVENT_STOP,		ctcm_chx_haltio  },
+	{ CTC_STATE_TX,		CTC_EVENT_START,	fsm_action_nop  },
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
+ * @param fi	An instance of a channel statemachine.
+ * @param event The event, just happened.
+ * @param arg	Generic pointer, casted from channel * upon call.
+ */
+static void ctcmpc_chx_txdone(fsm_instance *fi, int event, void *arg)
+{
+	struct channel		*ch = (struct channel *)arg;
+	struct net_device	*dev = ch->netdev;
+	struct ctcm_priv	*privptr = dev->priv;
+	struct mpc_group	*grpptr = privptr->mpcg;
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
+		privptr->stats.tx_packets++;
+		privptr->stats.tx_bytes += skb->len - TH_HEADER_LENGTH;
+		if (first) {
+			privptr->stats.tx_bytes += 2;
+			first = 0;
+		}
+		atomic_dec(&skb->users);
+		dev_kfree_skb_irq(skb);
+	}
+	spin_lock(&ch->collect_lock);
+	clear_normalized_cda(&ch->ccw[4]);
+
+	if ((ch->collect_len <= 0) || (grpptr->in_sweep != 0)) {
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
+	data_space = grpptr->group_max_buflen - TH_HEADER_LENGTH;
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
+			ctcmpc_dumpit((char *)p_header, min((int)skb->len, 32));
+		}
+		ch->collect_len -= skb->len;
+		data_space -= skb->len;
+		privptr->stats.tx_packets++;
+		privptr->stats.tx_bytes += skb->len;
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
+		fsm_event(privptr->mpcg->fsm, MPCG_EVENT_INOP, dev);
+				goto done;
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
+				min((int)ch->trans_skb->len, 50));
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
+		fsm_event(privptr->mpcg->fsm, MPCG_EVENT_INOP, dev);
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
+		privptr->stats.tx_dropped += i;
+		privptr->stats.tx_errors += i;
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
+ * @param fi	An instance of a channel statemachine.
+ * @param event The event, just happened.
+ * @param arg	Generic pointer, casted from channel * upon call.
+ */
+static void ctcmpc_chx_rx(fsm_instance *fi, int event, void *arg)
+{
+	struct channel		*ch = (struct channel *)arg;
+	struct net_device	*dev = ch->netdev;
+	struct ctcm_priv	*privptr = dev->priv;
+	struct mpc_group	*grpptr = privptr->mpcg;
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
+		privptr->stats.rx_dropped++;
+		privptr->stats.rx_length_errors++;
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
+			fsm_event(privptr->mpcg->fsm, MPCG_EVENT_INOP, dev);
+					goto again;
+		}
+		switch (fsm_getstate(grpptr->fsm)) {
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
+	switch (fsm_getstate(grpptr->fsm)) {
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
+ * @param fi	An instance of a channel statemachine.
+ * @param event The event, just happened.
+ * @param arg	Generic pointer, casted from channel * upon call.
+ */
+static void ctcmpc_chx_firstio(fsm_instance *fi, int event, void *arg)
+{
+	struct channel *ch = (struct channel *)arg;
+	struct net_device *dev = ch->netdev;
+
+	if (do_debug) {
+		struct mpc_group *gptr = ((struct ctcm_priv *)dev->priv)->mpcg;
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
+			fsm_event(((struct ctcm_priv *)dev->priv)->fsm,
+					DEV_EVENT_TXUP, dev);
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
+ * @param fi	An instance of a channel statemachine.
+ * @param event The event, just happened.
+ * @param arg	Generic pointer, casted from channel * upon call.
+ */
+void ctcmpc_chx_rxidle(fsm_instance *fi, int event, void *arg)
+{
+	struct channel *ch = (struct channel *)arg;
+	struct net_device *dev = ch->netdev;
+	struct ctcm_priv   *privptr = (struct ctcm_priv *)dev->priv;
+	struct mpc_group  *grpptr = privptr->mpcg;
+	int rc;
+	unsigned long saveflags = 0;	/* avoids compiler warning */
+
+	fsm_deltimer(&ch->timer);
+	ctcm_pr_debug("%s cp:%i enter:  %s()\n",
+		       dev->name, smp_processor_id(), __FUNCTION__);
+	if (do_debug)
+		ctcm_pr_debug("%s() %s chstate:%i grpstate:%i\n",
+			__FUNCTION__, ch->id,
+			fsm_getstate(fi), fsm_getstate(grpptr->fsm));
+
+	fsm_newstate(fi, CTC_STATE_RXIDLE);
+	/* XID processing complete */
+
+	switch (fsm_getstate(grpptr->fsm)) {
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
+	fsm_event(((struct ctcm_priv *)dev->priv)->fsm, DEV_EVENT_RXUP, dev);
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
+	struct channel	   *ch	       = (struct channel *)arg;
+	struct net_device  *dev        = ch->netdev;
+	struct ctcm_priv   *privptr    = (struct ctcm_priv *)dev->priv;
+	struct mpc_group   *grpptr     = privptr->mpcg;
+
+	if (do_debug) {
+		ctcm_pr_debug("ctcmpc enter: %s(): cp=%i ch=0x%p id=%s"
+				"GrpState:%s ChState:%s\n",
+				__FUNCTION__, smp_processor_id(), ch, ch->id,
+		fsm_getstate_str(grpptr->fsm),
+		fsm_getstate_str(ch->fsm));
+	}
+
+	switch (fsm_getstate(grpptr->fsm)) {
+	case MPCG_STATE_XID2INITW:
+		/* ok..start yside xid exchanges */
+		if (!ch->in_mpcgroup)
+			break;
+		if (fsm_getstate(ch->fsm) ==  CH_XID0_PENDING) {
+			fsm_deltimer(&grpptr->timer);
+			fsm_addtimer(&grpptr->timer,
+				MPC_XID_TIMEOUT_VALUE,
+				MPCG_EVENT_TIMER, dev);
+			fsm_event(grpptr->fsm, MPCG_EVENT_XID0DO, ch);
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
+		fsm_event(grpptr->fsm, MPCG_EVENT_XID7DONE, dev);
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
+	struct channel	   *ch	       = (struct channel *)arg;
+	struct net_device  *dev        = ch->netdev;
+	struct ctcm_priv    *privptr    = (struct ctcm_priv *)dev->priv;
+	struct mpc_group   *grpptr     = privptr->mpcg;
+
+	ctcm_pr_debug("ctcmpc enter: %s  %s() %s  \nGrpState:%s ChState:%s\n",
+		       dev->name,
+		       __FUNCTION__, ch->id,
+		       fsm_getstate_str(grpptr->fsm),
+		       fsm_getstate_str(ch->fsm));
+
+	fsm_deltimer(&ch->timer);
+
+	switch (fsm_getstate(grpptr->fsm)) {
+	case MPCG_STATE_XID0IOWAIT:
+		/* vtam wants to be primary.start yside xid exchanges*/
+		/* only receive one attn-busy at a time so must not  */
+		/* change state each time			     */
+		grpptr->changed_side = 1;
+		fsm_newstate(grpptr->fsm, MPCG_STATE_XID2INITW);
+		break;
+	case MPCG_STATE_XID2INITW:
+		if (grpptr->changed_side == 1) {
+			grpptr->changed_side = 2;
+			break;
+		}
+		/* process began via call to establish_conn	 */
+		/* so must report failure instead of reverting	 */
+		/* back to ready-for-xid passive state		 */
+		if (grpptr->estconnfunc)
+				goto done;
+		/* this attnbusy is NOT the result of xside xid  */
+		/* collisions so yside must have been triggered  */
+		/* by an ATTN that was not intended to start XID */
+		/* processing. Revert back to ready-for-xid and  */
+		/* wait for ATTN interrupt to signal xid start	 */
+		if (fsm_getstate(ch->fsm) == CH_XID0_INPROGRESS) {
+			fsm_newstate(ch->fsm, CH_XID0_PENDING) ;
+			fsm_deltimer(&grpptr->timer);
+				goto done;
+		}
+		fsm_event(grpptr->fsm, MPCG_EVENT_INOP, dev);
+				goto done;
+	case MPCG_STATE_XID2INITX:
+		/* XID2 was received before ATTN Busy for second
+		   channel.Send yside xid for second channel.
+		*/
+		if (grpptr->changed_side == 1) {
+			grpptr->changed_side = 2;
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
+		fsm_event(grpptr->fsm, MPCG_EVENT_INOP, dev);
+				goto done;
+	}
+
+	if (grpptr->changed_side == 1) {
+		fsm_deltimer(&grpptr->timer);
+		fsm_addtimer(&grpptr->timer, MPC_XID_TIMEOUT_VALUE,
+			     MPCG_EVENT_TIMER, dev);
+	}
+	if (ch->in_mpcgroup)
+		fsm_event(grpptr->fsm, MPCG_EVENT_XID0DO, ch);
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
+	struct channel	   *ch	       = (struct channel *)arg;
+	struct net_device  *dev        = ch->netdev;
+	struct ctcm_priv    *privptr    = (struct ctcm_priv *)dev->priv;
+	struct mpc_group   *grpptr     = privptr->mpcg;
+
+	ctcm_pr_debug("ctcmpc enter: %s  %s() %s  \nGrpState:%s ChState:%s\n",
+		       dev->name, __FUNCTION__, ch->id,
+		       fsm_getstate_str(grpptr->fsm),
+		       fsm_getstate_str(ch->fsm));
+
+	fsm_event(grpptr->fsm, MPCG_EVENT_XID0DO, ch);
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
+	struct channel *ach = (struct channel *)arg;
+	struct net_device *dev = ach->netdev;
+	struct ctcm_priv *privptr = (struct ctcm_priv *)dev->priv;
+	struct mpc_group *grpptr = privptr->mpcg;
+	struct channel *wch = privptr->channel[WRITE];
+	struct channel *rch = privptr->channel[READ];
+	struct sk_buff *skb;
+	struct th_sweep *header;
+	int rc = 0;
+	unsigned long saveflags = 0;
+
+	if (do_debug)
+		ctcm_pr_debug("ctcmpc enter: %s(): cp=%i ch=0x%p id=%s\n",
+			__FUNCTION__, smp_processor_id(), ach, ach->id);
+
+	if (grpptr->in_sweep == 0)
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
+		grpptr->in_sweep = 0;
+		ctcm_clear_busy_do(dev);
+		dev_kfree_skb_any(skb);
+		fsm_event(grpptr->fsm, MPCG_EVENT_INOP, dev);
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
+		grpptr->sweep_req_pend_num--;
+		break;
+	case TH_SWEEP_RESP:
+		grpptr->sweep_rsp_pend_num--;
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
+	if ((grpptr->sweep_req_pend_num == 0) &&
+	   (grpptr->sweep_rsp_pend_num == 0)) {
+		grpptr->in_sweep = 0;
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
+	{ CTC_STATE_STOPPED,	CTC_EVENT_STOP,		fsm_action_nop  },
+	{ CTC_STATE_STOPPED,	CTC_EVENT_START,	ctcm_chx_start  },
+	{ CTC_STATE_STOPPED,	CTC_EVENT_IO_ENODEV,	ctcm_chx_iofatal  },
+	{ CTC_STATE_STOPPED,	CTC_EVENT_FINSTAT,	fsm_action_nop  },
+	{ CTC_STATE_STOPPED,	CTC_EVENT_MC_FAIL,	fsm_action_nop  },
+
+	{ CTC_STATE_NOTOP,	CTC_EVENT_STOP,		ctcm_chx_stop  },
+	{ CTC_STATE_NOTOP,	CTC_EVENT_START,	fsm_action_nop  },
+	{ CTC_STATE_NOTOP,	CTC_EVENT_FINSTAT,	fsm_action_nop  },
+	{ CTC_STATE_NOTOP,	CTC_EVENT_MC_FAIL,	fsm_action_nop  },
+	{ CTC_STATE_NOTOP,	CTC_EVENT_MC_GOOD,	ctcm_chx_start  },
+	{ CTC_STATE_NOTOP,	CTC_EVENT_UC_RCRESET,	ctcm_chx_stop  },
+	{ CTC_STATE_NOTOP,	CTC_EVENT_UC_RSRESET,	ctcm_chx_stop  },
+	{ CTC_STATE_NOTOP,	CTC_EVENT_IO_ENODEV,	ctcm_chx_iofatal  },
+
+	{ CTC_STATE_STARTWAIT,	CTC_EVENT_STOP,		ctcm_chx_haltio  },
+	{ CTC_STATE_STARTWAIT,	CTC_EVENT_START,	fsm_action_nop  },
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
+	{ CTC_STATE_SETUPWAIT,	CTC_EVENT_START,	fsm_action_nop  },
+	{ CTC_STATE_SETUPWAIT,	CTC_EVENT_FINSTAT,	ctcmpc_chx_firstio  },
+	{ CTC_STATE_SETUPWAIT,	CTC_EVENT_UC_RCRESET,	ctcm_chx_setuperr  },
+	{ CTC_STATE_SETUPWAIT,	CTC_EVENT_UC_RSRESET,	ctcm_chx_setuperr  },
+	{ CTC_STATE_SETUPWAIT,	CTC_EVENT_TIMER,	ctcm_chx_setmode  },
+	{ CTC_STATE_SETUPWAIT,	CTC_EVENT_IO_ENODEV,	ctcm_chx_iofatal  },
+	{ CTC_STATE_SETUPWAIT,	CTC_EVENT_MC_FAIL,	ctcm_chx_fail  },
+
+	{ CTC_STATE_RXINIT,	CTC_EVENT_STOP,		ctcm_chx_haltio  },
+	{ CTC_STATE_RXINIT,	CTC_EVENT_START,	fsm_action_nop  },
+	{ CTC_STATE_RXINIT,	CTC_EVENT_FINSTAT,	ctcmpc_chx_rxidle  },
+	{ CTC_STATE_RXINIT,	CTC_EVENT_UC_RCRESET,	ctcm_chx_rxiniterr  },
+	{ CTC_STATE_RXINIT,	CTC_EVENT_UC_RSRESET,	ctcm_chx_rxiniterr  },
+	{ CTC_STATE_RXINIT,	CTC_EVENT_TIMER,	ctcm_chx_rxiniterr  },
+	{ CTC_STATE_RXINIT,	CTC_EVENT_ATTNBUSY,	ctcm_chx_rxinitfail  },
+	{ CTC_STATE_RXINIT,	CTC_EVENT_IO_ENODEV,	ctcm_chx_iofatal  },
+	{ CTC_STATE_RXINIT,	CTC_EVENT_UC_ZERO,	ctcmpc_chx_firstio  },
+	{ CTC_STATE_RXINIT,	CTC_EVENT_MC_FAIL,	ctcm_chx_fail  },
+
+	{ CH_XID0_PENDING,	CTC_EVENT_FINSTAT,	fsm_action_nop  },
+	{ CH_XID0_PENDING,	CTC_EVENT_ATTN,		ctcmpc_chx_attn  },
+	{ CH_XID0_PENDING,	CTC_EVENT_STOP,		ctcm_chx_haltio  },
+	{ CH_XID0_PENDING,	CTC_EVENT_START,	fsm_action_nop  },
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
+	{ CH_XID0_INPROGRESS,	CTC_EVENT_START,	fsm_action_nop  },
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
+	{ CH_XID7_PENDING,	CTC_EVENT_START,	fsm_action_nop  },
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
+	{ CH_XID7_PENDING1,	CTC_EVENT_START,	fsm_action_nop  },
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
+	{ CH_XID7_PENDING2,	CTC_EVENT_START,	fsm_action_nop  },
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
+	{ CH_XID7_PENDING3,	CTC_EVENT_START,	fsm_action_nop  },
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
+	{ CH_XID7_PENDING4,	CTC_EVENT_START,	fsm_action_nop  },
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
+	{ CTC_STATE_RXIDLE,	CTC_EVENT_START,	fsm_action_nop  },
+	{ CTC_STATE_RXIDLE,	CTC_EVENT_FINSTAT,	ctcmpc_chx_rx  },
+	{ CTC_STATE_RXIDLE,	CTC_EVENT_UC_RCRESET,	ctcm_chx_rxdisc  },
+	{ CTC_STATE_RXIDLE,	CTC_EVENT_UC_RSRESET,	ctcm_chx_fail  },
+	{ CTC_STATE_RXIDLE,	CTC_EVENT_IO_ENODEV,	ctcm_chx_iofatal  },
+	{ CTC_STATE_RXIDLE,	CTC_EVENT_MC_FAIL,	ctcm_chx_fail  },
+	{ CTC_STATE_RXIDLE,	CTC_EVENT_UC_ZERO,	ctcmpc_chx_rx  },
+
+	{ CTC_STATE_TXINIT,	CTC_EVENT_STOP,		ctcm_chx_haltio  },
+	{ CTC_STATE_TXINIT,	CTC_EVENT_START,	fsm_action_nop  },
+	{ CTC_STATE_TXINIT,	CTC_EVENT_FINSTAT,	ctcm_chx_txidle  },
+	{ CTC_STATE_TXINIT,	CTC_EVENT_UC_RCRESET,	ctcm_chx_txiniterr  },
+	{ CTC_STATE_TXINIT,	CTC_EVENT_UC_RSRESET,	ctcm_chx_txiniterr  },
+	{ CTC_STATE_TXINIT,	CTC_EVENT_TIMER,	ctcm_chx_txiniterr  },
+	{ CTC_STATE_TXINIT,	CTC_EVENT_IO_ENODEV,	ctcm_chx_iofatal  },
+	{ CTC_STATE_TXINIT,	CTC_EVENT_MC_FAIL,	ctcm_chx_fail  },
+	{ CTC_STATE_TXINIT,	CTC_EVENT_RSWEEP_TIMER,	ctcmpc_chx_send_sweep },
+
+	{ CTC_STATE_TXIDLE,	CTC_EVENT_STOP,		ctcm_chx_haltio  },
+	{ CTC_STATE_TXIDLE,	CTC_EVENT_START,	fsm_action_nop  },
+	{ CTC_STATE_TXIDLE,	CTC_EVENT_FINSTAT,	ctcmpc_chx_firstio  },
+	{ CTC_STATE_TXIDLE,	CTC_EVENT_UC_RCRESET,	ctcm_chx_fail  },
+	{ CTC_STATE_TXIDLE,	CTC_EVENT_UC_RSRESET,	ctcm_chx_fail  },
+	{ CTC_STATE_TXIDLE,	CTC_EVENT_IO_ENODEV,	ctcm_chx_iofatal  },
+	{ CTC_STATE_TXIDLE,	CTC_EVENT_MC_FAIL,	ctcm_chx_fail  },
+	{ CTC_STATE_TXIDLE,	CTC_EVENT_RSWEEP_TIMER,	ctcmpc_chx_send_sweep },
+
+	{ CTC_STATE_TERM,	CTC_EVENT_STOP,		fsm_action_nop  },
+	{ CTC_STATE_TERM,	CTC_EVENT_START,	ctcm_chx_restart  },
+	{ CTC_STATE_TERM,	CTC_EVENT_FINSTAT,	ctcm_chx_stopped  },
+	{ CTC_STATE_TERM,	CTC_EVENT_UC_RCRESET,	fsm_action_nop  },
+	{ CTC_STATE_TERM,	CTC_EVENT_UC_RSRESET,	fsm_action_nop  },
+	{ CTC_STATE_TERM,	CTC_EVENT_MC_FAIL,	ctcm_chx_fail  },
+	{ CTC_STATE_TERM,	CTC_EVENT_IO_EBUSY,	ctcm_chx_fail  },
+	{ CTC_STATE_TERM,	CTC_EVENT_IO_ENODEV,	ctcm_chx_iofatal  },
+
+	{ CTC_STATE_DTERM,	CTC_EVENT_STOP,		ctcm_chx_haltio  },
+	{ CTC_STATE_DTERM,	CTC_EVENT_START,	ctcm_chx_restart  },
+	{ CTC_STATE_DTERM,	CTC_EVENT_FINSTAT,	ctcm_chx_setmode  },
+	{ CTC_STATE_DTERM,	CTC_EVENT_UC_RCRESET,	fsm_action_nop  },
+	{ CTC_STATE_DTERM,	CTC_EVENT_UC_RSRESET,	fsm_action_nop  },
+	{ CTC_STATE_DTERM,	CTC_EVENT_MC_FAIL,	ctcm_chx_fail  },
+	{ CTC_STATE_DTERM,	CTC_EVENT_IO_ENODEV,	ctcm_chx_iofatal  },
+
+	{ CTC_STATE_TX,		CTC_EVENT_STOP,		ctcm_chx_haltio  },
+	{ CTC_STATE_TX,		CTC_EVENT_START,	fsm_action_nop  },
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
+ * @param fi	An instance of an interface statemachine.
+ * @param event The event, just happened.
+ * @param arg	Generic pointer, casted from struct net_device * upon call.
+ */
+static void dev_action_start(fsm_instance *fi, int event, void *arg)
+{
+	struct net_device *dev = (struct net_device *)arg;
+	struct ctcm_priv *privptr = dev->priv;
+	int direction;
+
+	CTCMY_DBF_DEV_NAME(SETUP, dev, "");
+
+	fsm_deltimer(&privptr->restart_timer);
+	fsm_newstate(fi, DEV_STATE_STARTWAIT_RXTX);
+	if (IS_MPC(privptr))
+		privptr->mpcg->channels_terminating = 0;
+	for (direction = READ; direction <= WRITE; direction++) {
+		struct channel *ch = privptr->channel[direction];
+		fsm_event(ch->fsm, CTC_EVENT_START, ch);
+	}
+}
+
+/**
+ * Shutdown channels by sending CTC_EVENT_STOP to each channel.
+ *
+ * @param fi	An instance of an interface statemachine.
+ * @param event The event, just happened.
+ * @param arg	Generic pointer, casted from struct net_device * upon call.
+ */
+static void dev_action_stop(fsm_instance *fi, int event, void *arg)
+{
+	int direction;
+	struct net_device *dev = (struct net_device *)arg;
+	struct ctcm_priv *privptr = (struct ctcm_priv *)dev->priv;
+
+	CTCMY_DBF_DEV_NAME(SETUP, dev, "");
+
+	fsm_newstate(fi, DEV_STATE_STOPWAIT_RXTX);
+	for (direction = READ; direction <= WRITE; direction++) {
+		struct channel *ch = privptr->channel[direction];
+		fsm_event(ch->fsm, CTC_EVENT_STOP, ch);
+		ch->th_seq_num = 0x00;
+	if (do_debug)
+		ctcm_pr_debug("ctcm: %s() CH_th_seq= %08x\n",
+				__FUNCTION__, ch->th_seq_num);
+	}
+	if (IS_MPC(privptr))
+		fsm_newstate(privptr->mpcg->fsm, MPCG_STATE_RESET);
+}
+
+static void dev_action_restart(fsm_instance *fi, int event, void *arg)
+{
+	int restart_timer;
+	struct net_device *dev = (struct net_device *)arg;
+	struct ctcm_priv *privptr = (struct ctcm_priv *)dev->priv;
+
+	CTCMY_DBF_DEV_NAME(TRACE, dev, "");
+
+	if (IS_MPC(privptr)) {
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
+	fsm_event(privptr->fsm, DEV_EVENT_STOP, dev);
+	if (IS_MPC(privptr))
+		fsm_newstate(privptr->mpcg->fsm, MPCG_STATE_RESET);
+
+	/* going back into start sequence too quickly can	  */
+	/* result in the other side becoming unreachable   due	  */
+	/* to sense reported when IO is aborted			  */
+	fsm_addtimer(&privptr->restart_timer, restart_timer,
+			DEV_EVENT_START, dev);
+}
+
+/**
+ * Called from channel statemachine
+ * when a channel is up and running.
+ *
+ * @param fi	An instance of an interface statemachine.
+ * @param event The event, just happened.
+ * @param arg	Generic pointer, casted from struct net_device * upon call.
+ */
+static void dev_action_chup(fsm_instance *fi, int event, void *arg)
+{
+	struct net_device *dev = (struct net_device *)arg;
+	struct ctcm_priv *privptr = (struct ctcm_priv *)dev->priv;
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
+	if (IS_MPC(privptr)) {
+		if (event == DEV_EVENT_RXUP)
+			mpc_channel_action(privptr->channel[READ],
+				READ, MPC_CHANNEL_ADD);
+		else
+			mpc_channel_action(privptr->channel[WRITE],
+				WRITE, MPC_CHANNEL_ADD);
+	}
+}
+
+/**
+ * Called from device statemachine
+ * when a channel has been shutdown.
+ *
+ * @param fi	An instance of an interface statemachine.
+ * @param event The event, just happened.
+ * @param arg	Generic pointer, casted from struct net_device * upon call.
+ */
+static void dev_action_chdown(fsm_instance *fi, int event, void *arg)
+{
+
+	struct net_device *dev = (struct net_device *)arg;
+	struct ctcm_priv *privptr = (struct ctcm_priv *)dev->priv;
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
+	if (IS_MPC(privptr)) {
+		if (event == DEV_EVENT_RXDOWN)
+			mpc_channel_action(privptr->channel[READ],
+				READ, MPC_CHANNEL_REMOVE);
+		else
+			mpc_channel_action(privptr->channel[WRITE],
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
+	{ DEV_STATE_RUNNING,        DEV_EVENT_TXUP,    fsm_action_nop     },
+	{ DEV_STATE_RUNNING,        DEV_EVENT_RXUP,    fsm_action_nop     },
+	{ DEV_STATE_RUNNING,        DEV_EVENT_RESTART, dev_action_restart },
+};
+
+int dev_fsm_len = ARRAY_SIZE(dev_fsm);
+
+/* --- This is the END my friend --- */
+
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

-- 
