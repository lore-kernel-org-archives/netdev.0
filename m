From: Ursula Braun <ursula.braun@de.ibm.com>
Subject: [patch 2/3] ctcm: message cleanup
Date: Fri, 18 Jul 2008 15:24:57 +0200
Message-ID: <20080718133555.368554000@linux.vnet.ibm.com>
References: <20080718132455.214854000@linux.vnet.ibm.com>
Cc: Martin Schwidefsky <schwidefsky@de.ibm.com>,
	Peter Tiedemann <ptiedem@de.ibm.com>,
	Ursula Braun <ursula.braun@de.ibm.com>
To: jgarzik@pobox.com, netdev@vger.kernel.org,
	linux-s390@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mtagate7.de.ibm.com ([195.212.29.156]:44334 "EHLO
	mtagate7.de.ibm.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1754963AbYGRNhz (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 18 Jul 2008 09:37:55 -0400
Content-Disposition: inline; filename=604-ctcm.diff
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Peter Tiedemann <ptiedem@de.ibm.com>

Cc: Martin Schwidefsky <schwidefsky@de.ibm.com>
Signed-off-by: Peter Tiedemann <ptiedem@de.ibm.com>
Signed-off-by: Ursula Braun <ursula.braun@de.ibm.com>
---

 drivers/s390/net/ctcm_dbug.c |   29 -
 drivers/s390/net/ctcm_dbug.h |   39 -
 drivers/s390/net/ctcm_fsms.c |  406 ++++++---------
 drivers/s390/net/ctcm_main.c |  514 +++++++++----------
 drivers/s390/net/ctcm_main.h |   31 +
 drivers/s390/net/ctcm_mpc.c  | 1110 +++++++++++++++----------------------------
 drivers/s390/net/ctcm_mpc.h  |    2 
 7 files changed, 884 insertions(+), 1247 deletions(-)

Index: linux-2.6-uschi/drivers/s390/net/ctcm_dbug.c
===================================================================
--- linux-2.6-uschi.orig/drivers/s390/net/ctcm_dbug.c
+++ linux-2.6-uschi/drivers/s390/net/ctcm_dbug.c
@@ -7,6 +7,7 @@
  */
 
 #include <linux/stddef.h>
+#include <linux/string.h>
 #include <linux/kernel.h>
 #include <linux/errno.h>
 #include <linux/slab.h>
@@ -22,15 +23,13 @@
  * Debug Facility Stuff
  */
 
-DEFINE_PER_CPU(char[256], ctcm_dbf_txt_buf);
-
 struct ctcm_dbf_info ctcm_dbf[CTCM_DBF_INFOS] = {
-	[CTCM_DBF_SETUP]	= {"ctc_setup", 8, 1, 64, 5, NULL},
-	[CTCM_DBF_ERROR]	= {"ctc_error", 8, 1, 64, 3, NULL},
-	[CTCM_DBF_TRACE]	= {"ctc_trace", 8, 1, 64, 3, NULL},
-	[CTCM_DBF_MPC_SETUP]	= {"mpc_setup", 8, 1, 64, 5, NULL},
-	[CTCM_DBF_MPC_ERROR]	= {"mpc_error", 8, 1, 64, 3, NULL},
-	[CTCM_DBF_MPC_TRACE]	= {"mpc_trace", 8, 1, 64, 3, NULL},
+	[CTCM_DBF_SETUP]     = {"ctc_setup", 8, 1, 64, CTC_DBF_INFO, NULL},
+	[CTCM_DBF_ERROR]     = {"ctc_error", 8, 1, 64, CTC_DBF_ERROR, NULL},
+	[CTCM_DBF_TRACE]     = {"ctc_trace", 8, 1, 64, CTC_DBF_ERROR, NULL},
+	[CTCM_DBF_MPC_SETUP] = {"mpc_setup", 8, 1, 80, CTC_DBF_INFO, NULL},
+	[CTCM_DBF_MPC_ERROR] = {"mpc_error", 8, 1, 80, CTC_DBF_ERROR, NULL},
+	[CTCM_DBF_MPC_TRACE] = {"mpc_trace", 8, 1, 80, CTC_DBF_ERROR, NULL},
 };
 
 void ctcm_unregister_dbf_views(void)
@@ -65,3 +64,17 @@ int ctcm_register_dbf_views(void)
 	return 0;
 }
 
+void ctcm_dbf_longtext(enum ctcm_dbf_names dbf_nix, int level, char *fmt, ...)
+{
+	char dbf_txt_buf[64];
+	va_list args;
+
+	if (level > (ctcm_dbf[dbf_nix].id)->level)
+		return;
+	va_start(args, fmt);
+	vsnprintf(dbf_txt_buf, sizeof(dbf_txt_buf), fmt, args);
+	va_end(args);
+
+	debug_text_event(ctcm_dbf[dbf_nix].id, level, dbf_txt_buf);
+}
+
Index: linux-2.6-uschi/drivers/s390/net/ctcm_dbug.h
===================================================================
--- linux-2.6-uschi.orig/drivers/s390/net/ctcm_dbug.h
+++ linux-2.6-uschi/drivers/s390/net/ctcm_dbug.h
@@ -20,16 +20,17 @@
 #else
  #define do_debug 0
 #endif
-#ifdef DEBUGDATA
- #define do_debug_data 1
-#else
- #define do_debug_data 0
-#endif
 #ifdef DEBUGCCW
  #define do_debug_ccw 1
+ #define DEBUGDATA 1
 #else
  #define do_debug_ccw 0
 #endif
+#ifdef DEBUGDATA
+ #define do_debug_data 1
+#else
+ #define do_debug_data 0
+#endif
 
 /* define dbf debug levels similar to kernel msg levels */
 #define	CTC_DBF_ALWAYS	0	/* always print this 			*/
@@ -42,8 +43,6 @@
 #define	CTC_DBF_INFO	5	/* informational			*/
 #define	CTC_DBF_DEBUG	6	/* debug-level messages			*/
 
-DECLARE_PER_CPU(char[256], ctcm_dbf_txt_buf);
-
 enum ctcm_dbf_names {
 	CTCM_DBF_SETUP,
 	CTCM_DBF_ERROR,
@@ -67,6 +66,7 @@ extern struct ctcm_dbf_info ctcm_dbf[CTC
 
 int ctcm_register_dbf_views(void);
 void ctcm_unregister_dbf_views(void);
+void ctcm_dbf_longtext(enum ctcm_dbf_names dbf_nix, int level, char *text, ...);
 
 static inline const char *strtail(const char *s, int n)
 {
@@ -74,12 +74,6 @@ static inline const char *strtail(const 
 	return (l > n) ? s + (l - n) : s;
 }
 
-/* sort out levels early to avoid unnecessary sprintfs */
-static inline int ctcm_dbf_passes(debug_info_t *dbf_grp, int level)
-{
-	return (dbf_grp->level >= level);
-}
-
 #define CTCM_FUNTAIL strtail((char *)__func__, 16)
 
 #define CTCM_DBF_TEXT(name, level, text) \
@@ -94,16 +88,7 @@ static inline int ctcm_dbf_passes(debug_
 	} while (0)
 
 #define CTCM_DBF_TEXT_(name, level, text...) \
-	do { \
-		if (ctcm_dbf_passes(ctcm_dbf[CTCM_DBF_##name].id, level)) { \
-			char *ctcm_dbf_txt_buf = \
-					 get_cpu_var(ctcm_dbf_txt_buf); \
-			sprintf(ctcm_dbf_txt_buf, text); \
-			debug_text_event(ctcm_dbf[CTCM_DBF_##name].id, \
-					level, ctcm_dbf_txt_buf); \
-			put_cpu_var(ctcm_dbf_txt_buf); \
-		} \
-	} while (0)
+	ctcm_dbf_longtext(CTCM_DBF_##name, level, text)
 
 /*
  * cat : one of {setup, mpc_setup, trace, mpc_trace, error, mpc_error}.
@@ -112,13 +97,13 @@ static inline int ctcm_dbf_passes(debug_
  */
 #define CTCM_DBF_DEV_NAME(cat, dev, text) \
 	do { \
-		CTCM_DBF_TEXT_(cat, CTC_DBF_INFO, "%s(%s) : %s", \
+		CTCM_DBF_TEXT_(cat, CTC_DBF_INFO, "%s(%s) :- %s", \
 			CTCM_FUNTAIL, dev->name, text); \
 	} while (0)
 
 #define MPC_DBF_DEV_NAME(cat, dev, text) \
 	do { \
-		CTCM_DBF_TEXT_(MPC_##cat, CTC_DBF_INFO, "%s(%s) : %s", \
+		CTCM_DBF_TEXT_(MPC_##cat, CTC_DBF_INFO, "%s(%s) := %s", \
 			CTCM_FUNTAIL, dev->name, text); \
 	} while (0)
 
@@ -137,13 +122,13 @@ static inline int ctcm_dbf_passes(debug_
  */
 #define CTCM_DBF_DEV(cat, dev, text) \
 	do { \
-		CTCM_DBF_TEXT_(cat, CTC_DBF_INFO, "%s(%p) : %s", \
+		CTCM_DBF_TEXT_(cat, CTC_DBF_INFO, "%s(%p) :-: %s", \
 			CTCM_FUNTAIL, dev, text); \
 	} while (0)
 
 #define MPC_DBF_DEV(cat, dev, text) \
 	do { \
-		CTCM_DBF_TEXT_(MPC_##cat, CTC_DBF_INFO, "%s(%p) : %s", \
+		CTCM_DBF_TEXT_(MPC_##cat, CTC_DBF_INFO, "%s(%p) :=: %s", \
 			CTCM_FUNTAIL, dev, text); \
 	} while (0)
 
Index: linux-2.6-uschi/drivers/s390/net/ctcm_fsms.c
===================================================================
--- linux-2.6-uschi.orig/drivers/s390/net/ctcm_fsms.c
+++ linux-2.6-uschi/drivers/s390/net/ctcm_fsms.c
@@ -190,7 +190,8 @@ static void ctcmpc_chx_send_sweep(fsm_in
 void ctcm_ccw_check_rc(struct channel *ch, int rc, char *msg)
 {
 	CTCM_DBF_TEXT_(ERROR, CTC_DBF_ERROR,
-			"ccw error %s (%s): %04x\n", ch->id, msg, rc);
+			"%s(%s): %s: %04x\n",
+				CTCM_FUNTAIL, ch->id, msg, rc);
 	switch (rc) {
 	case -EBUSY:
 		ctcm_pr_warn("%s (%s): Busy !\n", ch->id, msg);
@@ -212,7 +213,7 @@ void ctcm_purge_skb_queue(struct sk_buff
 {
 	struct sk_buff *skb;
 
-	CTCM_DBF_TEXT(TRACE, 3, __FUNCTION__);
+	CTCM_DBF_TEXT(TRACE, CTC_DBF_DEBUG, __func__);
 
 	while ((skb = skb_dequeue(q))) {
 		atomic_dec(&skb->users);
@@ -251,6 +252,8 @@ static void chx_txdone(fsm_instance *fi,
 	unsigned long duration;
 	struct timespec done_stamp = current_kernel_time(); /* xtime */
 
+	CTCM_PR_DEBUG("%s(%s): %s\n", __func__, ch->id, dev->name);
+
 	duration =
 	    (done_stamp.tv_sec - ch->prof.send_stamp.tv_sec) * 1000000 +
 	    (done_stamp.tv_nsec - ch->prof.send_stamp.tv_nsec) / 1000;
@@ -258,8 +261,9 @@ static void chx_txdone(fsm_instance *fi,
 		ch->prof.tx_time = duration;
 
 	if (ch->irb->scsw.cmd.count != 0)
-		ctcm_pr_debug("%s: TX not complete, remaining %d bytes\n",
-			     dev->name, ch->irb->scsw.cmd.count);
+		CTCM_DBF_TEXT_(TRACE, CTC_DBF_DEBUG,
+			"%s(%s): TX not complete, remaining %d bytes",
+			     CTCM_FUNTAIL, dev->name, ch->irb->scsw.cmd.count);
 	fsm_deltimer(&ch->timer);
 	while ((skb = skb_dequeue(&ch->io_queue))) {
 		priv->stats.tx_packets++;
@@ -334,7 +338,8 @@ void ctcm_chx_txidle(fsm_instance *fi, i
 	struct net_device *dev = ch->netdev;
 	struct ctcm_priv *priv = dev->priv;
 
-	CTCM_DBF_TEXT(TRACE, 6, __FUNCTION__);
+	CTCM_PR_DEBUG("%s(%s): %s\n", __func__, ch->id, dev->name);
+
 	fsm_deltimer(&ch->timer);
 	fsm_newstate(fi, CTC_STATE_TXIDLE);
 	fsm_event(priv->fsm, DEV_EVENT_TXUP, ch->netdev);
@@ -361,15 +366,17 @@ static void chx_rx(fsm_instance *fi, int
 
 	fsm_deltimer(&ch->timer);
 	if (len < 8) {
-		ctcm_pr_debug("%s: got packet with length %d < 8\n",
-			     dev->name, len);
+		CTCM_DBF_TEXT_(TRACE, CTC_DBF_NOTICE,
+			"%s(%s): got packet with length %d < 8\n",
+					CTCM_FUNTAIL, dev->name, len);
 		priv->stats.rx_dropped++;
 		priv->stats.rx_length_errors++;
 						goto again;
 	}
 	if (len > ch->max_bufsize) {
-		ctcm_pr_debug("%s: got packet with length %d > %d\n",
-			     dev->name, len, ch->max_bufsize);
+		CTCM_DBF_TEXT_(TRACE, CTC_DBF_NOTICE,
+			"%s(%s): got packet with length %d > %d\n",
+				CTCM_FUNTAIL, dev->name, len, ch->max_bufsize);
 		priv->stats.rx_dropped++;
 		priv->stats.rx_length_errors++;
 						goto again;
@@ -388,8 +395,9 @@ static void chx_rx(fsm_instance *fi, int
 		break;
 	}
 	if ((len < block_len) || (len > check_len)) {
-		ctcm_pr_debug("%s: got block length %d != rx length %d\n",
-			     dev->name, block_len, len);
+		CTCM_DBF_TEXT_(TRACE, CTC_DBF_NOTICE,
+			"%s(%s): got block length %d != rx length %d\n",
+				CTCM_FUNTAIL, dev->name, block_len, len);
 		if (do_debug)
 			ctcmpc_dump_skb(skb, 0);
 
@@ -425,17 +433,23 @@ static void chx_rx(fsm_instance *fi, int
  */
 static void chx_firstio(fsm_instance *fi, int event, void *arg)
 {
-	struct channel *ch = arg;
 	int rc;
+	struct channel *ch = arg;
+	int fsmstate = fsm_getstate(fi);
 
-	CTCM_DBF_TEXT(TRACE, 6, __FUNCTION__);
-
-	if (fsm_getstate(fi) == CTC_STATE_TXIDLE)
-		ctcm_pr_debug("%s: remote side issued READ?, init.\n", ch->id);
+	CTCM_DBF_TEXT_(TRACE, CTC_DBF_NOTICE,
+		"%s(%s) : %02x",
+		CTCM_FUNTAIL, ch->id, fsmstate);
+
+	ch->sense_rc = 0;	/* reset unit check report control */
+	if (fsmstate == CTC_STATE_TXIDLE)
+		CTCM_DBF_TEXT_(TRACE, CTC_DBF_DEBUG,
+			"%s(%s): remote side issued READ?, init.\n",
+				CTCM_FUNTAIL, ch->id);
 	fsm_deltimer(&ch->timer);
 	if (ctcm_checkalloc_buffer(ch))
 		return;
-	if ((fsm_getstate(fi) == CTC_STATE_SETUPWAIT) &&
+	if ((fsmstate == CTC_STATE_SETUPWAIT) &&
 	    (ch->protocol == CTCM_PROTO_OS390)) {
 		/* OS/390 resp. z/OS */
 		if (CHANNEL_DIRECTION(ch->flags) == READ) {
@@ -451,7 +465,6 @@ static void chx_firstio(fsm_instance *fi
 		}
 		return;
 	}
-
 	/*
 	 * Don't setup a timer for receiving the initial RX frame
 	 * if in compatibility mode, since VM TCP delays the initial
@@ -505,11 +518,10 @@ static void chx_rxidle(fsm_instance *fi,
 	__u16 buflen;
 	int rc;
 
-	CTCM_DBF_TEXT(TRACE, 6, __FUNCTION__);
 	fsm_deltimer(&ch->timer);
 	buflen = *((__u16 *)ch->trans_skb->data);
-	if (do_debug)
-		ctcm_pr_debug("%s: Initial RX count %d\n", dev->name, buflen);
+	CTCM_PR_DEBUG("%s: %s: Initial RX count = %d\n",
+			__func__, dev->name, buflen);
 
 	if (buflen >= CTCM_INITIAL_BLOCKLEN) {
 		if (ctcm_checkalloc_buffer(ch))
@@ -524,9 +536,9 @@ static void chx_rxidle(fsm_instance *fi,
 		} else
 			fsm_event(priv->fsm, DEV_EVENT_RXUP, dev);
 	} else {
-		if (do_debug)
-			ctcm_pr_debug("%s: Initial RX count %d not %d\n",
-				dev->name, buflen, CTCM_INITIAL_BLOCKLEN);
+		CTCM_PR_DEBUG("%s: %s: Initial RX count %d not %d\n",
+				__func__, dev->name,
+					buflen, CTCM_INITIAL_BLOCKLEN);
 		chx_firstio(fi, event, arg);
 	}
 }
@@ -548,14 +560,12 @@ static void ctcm_chx_setmode(fsm_instanc
 	fsm_deltimer(&ch->timer);
 	if (IS_MPC(ch)) {
 		timeout = 1500;
-		if (do_debug)
-			ctcm_pr_debug("ctcm enter: %s(): cp=%i ch=0x%p id=%s\n",
-				__FUNCTION__, smp_processor_id(), ch, ch->id);
+		CTCM_PR_DEBUG("enter %s: cp=%i ch=0x%p id=%s\n",
+				__func__, smp_processor_id(), ch, ch->id);
 	}
 	fsm_addtimer(&ch->timer, timeout, CTC_EVENT_TIMER, ch);
 	fsm_newstate(fi, CTC_STATE_SETUPWAIT);
-	if (do_debug_ccw && IS_MPC(ch))
-		ctcmpc_dumpit((char *)&ch->ccw[6], sizeof(struct ccw1) * 2);
+	CTCM_CCW_DUMP((char *)&ch->ccw[6], sizeof(struct ccw1) * 2);
 
 	if (event == CTC_EVENT_TIMER)	/* only for timer not yet locked */
 		spin_lock_irqsave(get_ccwdev_lock(ch->cdev), saveflags);
@@ -583,24 +593,12 @@ static void ctcm_chx_setmode(fsm_instanc
  */
 static void ctcm_chx_start(fsm_instance *fi, int event, void *arg)
 {
-	struct channel *ch = arg;
-	int rc;
-	struct net_device *dev;
+	struct channel *ch	= arg;
 	unsigned long saveflags;
+	int rc;
 
-	CTCM_DBF_TEXT(TRACE, 5, __FUNCTION__);
-	if (ch == NULL) {
-		ctcm_pr_warn("chx_start ch=NULL\n");
-		return;
-	}
-	if (ch->netdev == NULL) {
-		ctcm_pr_warn("chx_start dev=NULL, id=%s\n", ch->id);
-		return;
-	}
-	dev = ch->netdev;
-
-	if (do_debug)
-		ctcm_pr_debug("%s: %s channel start\n", dev->name,
+	CTCM_DBF_TEXT_(SETUP, CTC_DBF_INFO, "%s(%s): %s",
+			CTCM_FUNTAIL, ch->id,
 			(CHANNEL_DIRECTION(ch->flags) == READ) ? "RX" : "TX");
 
 	if (ch->trans_skb != NULL) {
@@ -618,11 +616,12 @@ static void ctcm_chx_start(fsm_instance 
 		ch->ccw[1].count = 0;
 	}
 	if (ctcm_checkalloc_buffer(ch)) {
-		ctcm_pr_notice("%s: %s trans_skb allocation delayed "
-				"until first transfer\n", dev->name,
+		CTCM_DBF_TEXT_(TRACE, CTC_DBF_DEBUG,
+			"%s(%s): %s trans_skb alloc delayed "
+			"until first transfer",
+			CTCM_FUNTAIL, ch->id,
 			(CHANNEL_DIRECTION(ch->flags) == READ) ? "RX" : "TX");
 	}
-
 	ch->ccw[0].cmd_code = CCW_CMD_PREPARE;
 	ch->ccw[0].flags = CCW_FLAG_SLI | CCW_FLAG_CC;
 	ch->ccw[0].count = 0;
@@ -661,7 +660,6 @@ static void ctcm_chx_haltio(fsm_instance
 	int rc;
 	int oldstate;
 
-	CTCM_DBF_TEXT(TRACE, 2, __FUNCTION__);
 	fsm_deltimer(&ch->timer);
 	if (IS_MPC(ch))
 		fsm_deltimer(&ch->sweep_timer);
@@ -684,7 +682,7 @@ static void ctcm_chx_haltio(fsm_instance
 		fsm_deltimer(&ch->timer);
 		if (event != CTC_EVENT_STOP) {
 			fsm_newstate(fi, oldstate);
-			ctcm_ccw_check_rc(ch, rc, (char *)__FUNCTION__);
+			ctcm_ccw_check_rc(ch, rc, (char *)__func__);
 		}
 	}
 }
@@ -703,7 +701,9 @@ static void ctcm_chx_cleanup(fsm_instanc
 	struct net_device *dev = ch->netdev;
 	struct ctcm_priv *priv = dev->priv;
 
-	CTCM_DBF_TEXT(TRACE, 3, __FUNCTION__);
+	CTCM_DBF_TEXT_(SETUP, CTC_DBF_NOTICE,
+			"%s(%s): %s[%d]\n",
+			CTCM_FUNTAIL, dev->name, ch->id, state);
 
 	fsm_deltimer(&ch->timer);
 	if (IS_MPC(ch))
@@ -743,7 +743,6 @@ static void ctcm_chx_cleanup(fsm_instanc
  */
 static void ctcm_chx_stopped(fsm_instance *fi, int event, void *arg)
 {
-	CTCM_DBF_TEXT(TRACE, 3, __FUNCTION__);
 	ctcm_chx_cleanup(fi, CTC_STATE_STOPPED, arg);
 }
 
@@ -771,7 +770,6 @@ static void ctcm_chx_stop(fsm_instance *
  */
 static void ctcm_chx_fail(fsm_instance *fi, int event, void *arg)
 {
-	CTCM_DBF_TEXT(TRACE, 3, __FUNCTION__);
 	ctcm_chx_cleanup(fi, CTC_STATE_NOTOP, arg);
 }
 
@@ -809,8 +807,8 @@ static void ctcm_chx_setuperr(fsm_instan
 	}
 
 	CTCM_DBF_TEXT_(ERROR, CTC_DBF_CRIT,
-		"%s : %s error during %s channel setup state=%s\n",
-		dev->name, ctc_ch_event_names[event],
+		"%s(%s) : %s error during %s channel setup state=%s\n",
+		CTCM_FUNTAIL, dev->name, ctc_ch_event_names[event],
 		(CHANNEL_DIRECTION(ch->flags) == READ) ? "RX" : "TX",
 		fsm_getstate_str(fi));
 
@@ -838,10 +836,12 @@ static void ctcm_chx_restart(fsm_instanc
 	int oldstate;
 	int rc;
 
-	CTCM_DBF_TEXT(TRACE, CTC_DBF_NOTICE, __FUNCTION__);
+	CTCM_DBF_TEXT_(TRACE, CTC_DBF_NOTICE,
+		"%s: %s[%d] of %s\n",
+			CTCM_FUNTAIL, ch->id, event, dev->name);
+
 	fsm_deltimer(&ch->timer);
-	ctcm_pr_debug("%s: %s channel restart\n", dev->name,
-		     (CHANNEL_DIRECTION(ch->flags) == READ) ? "RX" : "TX");
+
 	fsm_addtimer(&ch->timer, CTCM_TIME_5_SEC, CTC_EVENT_TIMER, ch);
 	oldstate = fsm_getstate(fi);
 	fsm_newstate(fi, CTC_STATE_STARTWAIT);
@@ -876,13 +876,10 @@ static void ctcm_chx_rxiniterr(fsm_insta
 	struct net_device *dev = ch->netdev;
 	struct ctcm_priv *priv = dev->priv;
 
-	CTCM_DBF_TEXT(SETUP, 3, __FUNCTION__);
 	if (event == CTC_EVENT_TIMER) {
 		if (!IS_MPCDEV(dev))
 			/* TODO : check if MPC deletes timer somewhere */
 			fsm_deltimer(&ch->timer);
-		ctcm_pr_debug("%s: Timeout during RX init handshake\n",
-				dev->name);
 		if (ch->retry++ < 3)
 			ctcm_chx_restart(fi, event, arg);
 		else {
@@ -907,9 +904,10 @@ static void ctcm_chx_rxinitfail(fsm_inst
 	struct net_device *dev = ch->netdev;
 	struct ctcm_priv *priv = dev->priv;
 
-	CTCM_DBF_TEXT(SETUP, 3, __FUNCTION__);
+	CTCM_DBF_TEXT_(ERROR, CTC_DBF_ERROR,
+			"%s(%s): RX %s busy, init. fail",
+				CTCM_FUNTAIL, dev->name, ch->id);
 	fsm_newstate(fi, CTC_STATE_RXERR);
-	ctcm_pr_warn("%s: RX busy. Initialization failed\n", dev->name);
 	fsm_event(priv->fsm, DEV_EVENT_RXDOWN, dev);
 }
 
@@ -927,11 +925,10 @@ static void ctcm_chx_rxdisc(fsm_instance
 	struct net_device *dev = ch->netdev;
 	struct ctcm_priv *priv = dev->priv;
 
-	CTCM_DBF_DEV_NAME(TRACE, dev, "Got remote disconnect, re-initializing");
+	CTCM_DBF_TEXT_(TRACE, CTC_DBF_NOTICE,
+			"%s: %s: remote disconnect - re-init ...",
+				CTCM_FUNTAIL, dev->name);
 	fsm_deltimer(&ch->timer);
-	if (do_debug)
-		ctcm_pr_debug("%s: Got remote disconnect, "
-				"re-initializing ...\n", dev->name);
 	/*
 	 * Notify device statemachine
 	 */
@@ -961,8 +958,6 @@ static void ctcm_chx_txiniterr(fsm_insta
 
 	if (event == CTC_EVENT_TIMER) {
 		fsm_deltimer(&ch->timer);
-		CTCM_DBF_DEV_NAME(ERROR, dev,
-				"Timeout during TX init handshake");
 		if (ch->retry++ < 3)
 			ctcm_chx_restart(fi, event, arg);
 		else {
@@ -971,9 +966,8 @@ static void ctcm_chx_txiniterr(fsm_insta
 		}
 	} else {
 		CTCM_DBF_TEXT_(ERROR, CTC_DBF_ERROR,
-			"%s : %s error during channel setup state=%s",
-			dev->name, ctc_ch_event_names[event],
-			fsm_getstate_str(fi));
+			"%s(%s): %s in %s", CTCM_FUNTAIL, ch->id,
+			ctc_ch_event_names[event], fsm_getstate_str(fi));
 
 		ctcm_pr_warn("%s: Error during TX init handshake\n", dev->name);
 	}
@@ -993,15 +987,15 @@ static void ctcm_chx_txretry(fsm_instanc
 	struct ctcm_priv *priv = dev->priv;
 	struct sk_buff *skb;
 
-	if (do_debug)
-		ctcm_pr_debug("ctcmpc enter: %s(): cp=%i ch=0x%p id=%s\n",
-			__FUNCTION__, smp_processor_id(), ch, ch->id);
+	CTCM_PR_DEBUG("Enter: %s: cp=%i ch=0x%p id=%s\n",
+			__func__, smp_processor_id(), ch, ch->id);
 
 	fsm_deltimer(&ch->timer);
 	if (ch->retry++ > 3) {
 		struct mpc_group *gptr = priv->mpcg;
-		ctcm_pr_debug("%s: TX retry failed, restarting channel\n",
-			     dev->name);
+		CTCM_DBF_TEXT_(TRACE, CTC_DBF_INFO,
+				"%s: %s: retries exceeded",
+					CTCM_FUNTAIL, ch->id);
 		fsm_event(priv->fsm, DEV_EVENT_TXDOWN, dev);
 		/* call restart if not MPC or if MPC and mpcg fsm is ready.
 			use gptr as mpc indicator */
@@ -1010,7 +1004,9 @@ static void ctcm_chx_txretry(fsm_instanc
 				goto done;
 	}
 
-	ctcm_pr_debug("%s: TX retry %d\n", dev->name, ch->retry);
+	CTCM_DBF_TEXT_(TRACE, CTC_DBF_DEBUG,
+			"%s : %s: retry %d",
+				CTCM_FUNTAIL, ch->id, ch->retry);
 	skb = skb_peek(&ch->io_queue);
 	if (skb) {
 		int rc = 0;
@@ -1018,8 +1014,9 @@ static void ctcm_chx_txretry(fsm_instanc
 		clear_normalized_cda(&ch->ccw[4]);
 		ch->ccw[4].count = skb->len;
 		if (set_normalized_cda(&ch->ccw[4], skb->data)) {
-			ctcm_pr_debug("%s: IDAL alloc failed, chan restart\n",
-						dev->name);
+			CTCM_DBF_TEXT_(TRACE, CTC_DBF_INFO,
+				"%s: %s: IDAL alloc failed",
+						CTCM_FUNTAIL, ch->id);
 			fsm_event(priv->fsm, DEV_EVENT_TXDOWN, dev);
 			ctcm_chx_restart(fi, event, arg);
 				goto done;
@@ -1061,22 +1058,21 @@ static void ctcm_chx_iofatal(fsm_instanc
 	struct channel *ch = arg;
 	struct net_device *dev = ch->netdev;
 	struct ctcm_priv *priv = dev->priv;
+	int rd = CHANNEL_DIRECTION(ch->flags);
 
-	CTCM_DBF_TEXT(TRACE, 3, __FUNCTION__);
 	fsm_deltimer(&ch->timer);
-	ctcm_pr_warn("%s %s : unrecoverable channel error\n",
-			CTC_DRIVER_NAME, dev->name);
+	CTCM_DBF_TEXT_(ERROR, CTC_DBF_ERROR,
+		"%s: %s: %s unrecoverable channel error",
+			CTCM_FUNTAIL, ch->id, rd == READ ? "RX" : "TX");
+
 	if (IS_MPC(ch)) {
 		priv->stats.tx_dropped++;
 		priv->stats.tx_errors++;
 	}
-
-	if (CHANNEL_DIRECTION(ch->flags) == READ) {
-		ctcm_pr_debug("%s: RX I/O error\n", dev->name);
+	if (rd == READ) {
 		fsm_newstate(fi, CTC_STATE_RXERR);
 		fsm_event(priv->fsm, DEV_EVENT_RXDOWN, dev);
 	} else {
-		ctcm_pr_debug("%s: TX I/O error\n", dev->name);
 		fsm_newstate(fi, CTC_STATE_TXERR);
 		fsm_event(priv->fsm, DEV_EVENT_TXDOWN, dev);
 	}
@@ -1216,27 +1212,27 @@ static void ctcmpc_chx_txdone(fsm_instan
 	struct sk_buff		*skb;
 	int		first = 1;
 	int		i;
-	struct timespec done_stamp;
 	__u32		data_space;
 	unsigned long	duration;
 	struct sk_buff	*peekskb;
 	int		rc;
 	struct th_header *header;
 	struct pdu	*p_header;
+	struct timespec done_stamp = current_kernel_time(); /* xtime */
 
-	if (do_debug)
-		ctcm_pr_debug("%s cp:%i enter:  %s()\n",
-			dev->name, smp_processor_id(), __FUNCTION__);
-
-	done_stamp = current_kernel_time(); /* xtime */
-	duration = (done_stamp.tv_sec - ch->prof.send_stamp.tv_sec) * 1000000
-		+ (done_stamp.tv_nsec - ch->prof.send_stamp.tv_nsec) / 1000;
+	CTCM_PR_DEBUG("Enter %s: %s cp:%i\n",
+			__func__, dev->name, smp_processor_id());
+
+	duration =
+		(done_stamp.tv_sec - ch->prof.send_stamp.tv_sec) * 1000000 +
+		(done_stamp.tv_nsec - ch->prof.send_stamp.tv_nsec) / 1000;
 	if (duration > ch->prof.tx_time)
 		ch->prof.tx_time = duration;
 
 	if (ch->irb->scsw.cmd.count != 0)
-		ctcm_pr_debug("%s: TX not complete, remaining %d bytes\n",
-				dev->name, ch->irb->scsw.cmd.count);
+		CTCM_DBF_TEXT_(MPC_TRACE, CTC_DBF_DEBUG,
+			"%s(%s): TX not complete, remaining %d bytes",
+			     CTCM_FUNTAIL, dev->name, ch->irb->scsw.cmd.count);
 	fsm_deltimer(&ch->timer);
 	while ((skb = skb_dequeue(&ch->io_queue))) {
 		priv->stats.tx_packets++;
@@ -1250,7 +1246,6 @@ static void ctcmpc_chx_txdone(fsm_instan
 	}
 	spin_lock(&ch->collect_lock);
 	clear_normalized_cda(&ch->ccw[4]);
-
 	if ((ch->collect_len <= 0) || (grp->in_sweep != 0)) {
 		spin_unlock(&ch->collect_lock);
 		fsm_newstate(fi, CTC_STATE_TXIDLE);
@@ -1269,17 +1264,13 @@ static void ctcmpc_chx_txdone(fsm_instan
 	if (ch->prof.maxcqueue < skb_queue_len(&ch->collect_queue))
 		ch->prof.maxcqueue = skb_queue_len(&ch->collect_queue);
 	i = 0;
-
-	if (do_debug_data)
-		ctcm_pr_debug("ctcmpc: %s() building "
-			       "trans_skb from collect_q \n", __FUNCTION__);
-
+	p_header = NULL;
 	data_space = grp->group_max_buflen - TH_HEADER_LENGTH;
 
-	if (do_debug_data)
-		ctcm_pr_debug("ctcmpc: %s() building trans_skb from collect_q"
-		       " data_space:%04x\n", __FUNCTION__, data_space);
-	p_header = NULL;
+	CTCM_PR_DBGDATA("%s: building trans_skb from collect_q"
+		       " data_space:%04x\n",
+		       __func__, data_space);
+
 	while ((skb = skb_dequeue(&ch->collect_queue))) {
 		memcpy(skb_put(ch->trans_skb, skb->len), skb->data, skb->len);
 		p_header = (struct pdu *)
@@ -1290,15 +1281,12 @@ static void ctcmpc_chx_txdone(fsm_instan
 		else
 			p_header->pdu_flag |= 0x20;
 
-		if (do_debug_data) {
-			ctcm_pr_debug("ctcmpc: %s()trans_skb len:%04x \n",
-				       __FUNCTION__, ch->trans_skb->len);
-			ctcm_pr_debug("ctcmpc: %s() pdu header and data"
-				       " for up to 32 bytes sent to vtam\n",
-				       __FUNCTION__);
-			ctcmpc_dumpit((char *)p_header,
-						min_t(int, skb->len, 32));
-		}
+		CTCM_PR_DBGDATA("%s: trans_skb len:%04x \n",
+				__func__, ch->trans_skb->len);
+		CTCM_PR_DBGDATA("%s: pdu header and data for up"
+				" to 32 bytes sent to vtam\n", __func__);
+		CTCM_D3_DUMP((char *)p_header, min_t(int, skb->len, 32));
+
 		ch->collect_len -= skb->len;
 		data_space -= skb->len;
 		priv->stats.tx_packets++;
@@ -1314,46 +1302,38 @@ static void ctcmpc_chx_txdone(fsm_instan
 	if (p_header)
 		p_header->pdu_flag |= PDU_LAST;	/*Say it's the last one*/
 	header = kzalloc(TH_HEADER_LENGTH, gfp_type());
-
 	if (!header) {
-		printk(KERN_WARNING "ctcmpc: OUT OF MEMORY IN %s()"
-		       ": Data Lost \n", __FUNCTION__);
 		spin_unlock(&ch->collect_lock);
 		fsm_event(priv->mpcg->fsm, MPCG_EVENT_INOP, dev);
-		goto done;
+				goto done;
 	}
-
 	header->th_ch_flag = TH_HAS_PDU;  /* Normal data */
 	ch->th_seq_num++;
 	header->th_seq_num = ch->th_seq_num;
 
-	if (do_debug_data)
-		ctcm_pr_debug("%s: ToVTAM_th_seq= %08x\n" ,
-					__FUNCTION__, ch->th_seq_num);
+	CTCM_PR_DBGDATA("%s: ToVTAM_th_seq= %08x\n" ,
+					__func__, ch->th_seq_num);
 
 	memcpy(skb_push(ch->trans_skb, TH_HEADER_LENGTH), header,
 		TH_HEADER_LENGTH);	/* put the TH on the packet */
 
 	kfree(header);
 
-	if (do_debug_data) {
-		ctcm_pr_debug("ctcmpc: %s()trans_skb len:%04x \n",
-		       __FUNCTION__, ch->trans_skb->len);
-
-		ctcm_pr_debug("ctcmpc: %s() up-to-50 bytes of trans_skb "
-			"data to vtam from collect_q\n", __FUNCTION__);
-		ctcmpc_dumpit((char *)ch->trans_skb->data,
+	CTCM_PR_DBGDATA("%s: trans_skb len:%04x \n",
+		       __func__, ch->trans_skb->len);
+	CTCM_PR_DBGDATA("%s: up-to-50 bytes of trans_skb "
+			"data to vtam from collect_q\n", __func__);
+	CTCM_D3_DUMP((char *)ch->trans_skb->data,
 				min_t(int, ch->trans_skb->len, 50));
-	}
 
 	spin_unlock(&ch->collect_lock);
 	clear_normalized_cda(&ch->ccw[1]);
 	if (set_normalized_cda(&ch->ccw[1], ch->trans_skb->data)) {
 		dev_kfree_skb_any(ch->trans_skb);
 		ch->trans_skb = NULL;
-		printk(KERN_WARNING
-		       "ctcmpc: %s()CCW failure - data lost\n",
-		       __FUNCTION__);
+		CTCM_DBF_TEXT_(MPC_TRACE, CTC_DBF_ERROR,
+			"%s: %s: IDAL alloc failed",
+				CTCM_FUNTAIL, ch->id);
 		fsm_event(priv->mpcg->fsm, MPCG_EVENT_INOP, dev);
 		return;
 	}
@@ -1373,7 +1353,6 @@ static void ctcmpc_chx_txdone(fsm_instan
 	}
 done:
 	ctcm_clear_busy(dev);
-	ctcm_pr_debug("ctcmpc exit: %s  %s()\n", dev->name, __FUNCTION__);
 	return;
 }
 
@@ -1393,26 +1372,25 @@ static void ctcmpc_chx_rx(fsm_instance *
 	struct mpc_group	*grp = priv->mpcg;
 	struct sk_buff		*skb = ch->trans_skb;
 	struct sk_buff		*new_skb;
-	unsigned long	saveflags = 0;	/* avoids compiler warning */
+	unsigned long		saveflags = 0;	/* avoids compiler warning */
 	int len	= ch->max_bufsize - ch->irb->scsw.cmd.count;
 
-	if (do_debug_data) {
-		CTCM_DBF_TEXT_(TRACE, CTC_DBF_DEBUG, "mpc_ch_rx %s cp:%i %s\n",
-				dev->name, smp_processor_id(), ch->id);
-		CTCM_DBF_TEXT_(TRACE, CTC_DBF_DEBUG, "mpc_ch_rx: maxbuf: %04x "
-				"len: %04x\n", ch->max_bufsize, len);
-	}
+	CTCM_PR_DEBUG("%s: %s: cp:%i %s maxbuf : %04x, len: %04x\n",
+			CTCM_FUNTAIL, dev->name, smp_processor_id(),
+				ch->id, ch->max_bufsize, len);
 	fsm_deltimer(&ch->timer);
 
 	if (skb == NULL) {
-		ctcm_pr_debug("ctcmpc exit:  %s() TRANS_SKB = NULL \n",
-			       __FUNCTION__);
-					goto again;
+		CTCM_DBF_TEXT_(MPC_ERROR, CTC_DBF_ERROR,
+			"%s(%s): TRANS_SKB = NULL",
+				CTCM_FUNTAIL, dev->name);
+			goto again;
 	}
 
 	if (len < TH_HEADER_LENGTH) {
-		ctcm_pr_info("%s: got packet with invalid length %d\n",
-				dev->name, len);
+		CTCM_DBF_TEXT_(MPC_ERROR, CTC_DBF_ERROR,
+				"%s(%s): packet length %d to short",
+					CTCM_FUNTAIL, dev->name, len);
 		priv->stats.rx_dropped++;
 		priv->stats.rx_length_errors++;
 	} else {
@@ -1422,11 +1400,9 @@ static void ctcmpc_chx_rx(fsm_instance *
 		new_skb = __dev_alloc_skb(ch->max_bufsize, GFP_ATOMIC);
 
 		if (new_skb == NULL) {
-			printk(KERN_INFO "ctcmpc:%s() NEW_SKB = NULL\n",
-			       __FUNCTION__);
-			printk(KERN_WARNING "ctcmpc: %s() MEMORY ALLOC FAILED"
-			       " - DATA LOST - MPC FAILED\n",
-			       __FUNCTION__);
+			CTCM_DBF_TEXT_(MPC_ERROR, CTC_DBF_ERROR,
+				"%s(%d): skb allocation failed",
+						CTCM_FUNTAIL, dev->name);
 			fsm_event(priv->mpcg->fsm, MPCG_EVENT_INOP, dev);
 					goto again;
 		}
@@ -1479,9 +1455,8 @@ again:
 		break;
 	}
 
-	if (do_debug)
-		ctcm_pr_debug("ctcmpc exit : %s %s(): ch=0x%p id=%s\n",
-				dev->name, __FUNCTION__, ch, ch->id);
+	CTCM_PR_DEBUG("Exit %s: %s, ch=0x%p, id=%s\n",
+			__func__, dev->name, ch, ch->id);
 
 }
 
@@ -1497,15 +1472,16 @@ static void ctcmpc_chx_firstio(fsm_insta
 	struct channel		*ch = arg;
 	struct net_device	*dev = ch->netdev;
 	struct ctcm_priv	*priv = dev->priv;
+	struct mpc_group	*gptr = priv->mpcg;
+
+	CTCM_PR_DEBUG("Enter %s: id=%s, ch=0x%p\n",
+				__func__, ch->id, ch);
+
+	CTCM_DBF_TEXT_(MPC_TRACE, CTC_DBF_INFO,
+			"%s: %s: chstate:%i, grpstate:%i, prot:%i\n",
+			CTCM_FUNTAIL, ch->id, fsm_getstate(fi),
+			fsm_getstate(gptr->fsm), ch->protocol);
 
-	if (do_debug) {
-		struct mpc_group *gptr = priv->mpcg;
-		ctcm_pr_debug("ctcmpc enter: %s(): ch=0x%p id=%s\n",
-				__FUNCTION__, ch, ch->id);
-		ctcm_pr_debug("%s() %s chstate:%i grpstate:%i chprotocol:%i\n",
-				__FUNCTION__, ch->id, fsm_getstate(fi),
-				fsm_getstate(gptr->fsm), ch->protocol);
-	}
 	if (fsm_getstate(fi) == CTC_STATE_TXIDLE)
 		MPC_DBF_DEV_NAME(TRACE, dev, "remote side issued READ? ");
 
@@ -1531,9 +1507,8 @@ static void ctcmpc_chx_firstio(fsm_insta
 		     ? CTC_STATE_RXINIT : CTC_STATE_TXINIT);
 
 done:
-	if (do_debug)
-		ctcm_pr_debug("ctcmpc exit : %s(): ch=0x%p id=%s\n",
-			__FUNCTION__, ch, ch->id);
+	CTCM_PR_DEBUG("Exit %s: id=%s, ch=0x%p\n",
+				__func__, ch->id, ch);
 	return;
 }
 
@@ -1556,12 +1531,9 @@ void ctcmpc_chx_rxidle(fsm_instance *fi,
 	unsigned long saveflags = 0;	/* avoids compiler warning */
 
 	fsm_deltimer(&ch->timer);
-	ctcm_pr_debug("%s cp:%i enter:  %s()\n",
-		       dev->name, smp_processor_id(), __FUNCTION__);
-	if (do_debug)
-		ctcm_pr_debug("%s() %s chstate:%i grpstate:%i\n",
-			__FUNCTION__, ch->id,
-			fsm_getstate(fi), fsm_getstate(grp->fsm));
+	CTCM_PR_DEBUG("%s: %s: %s: cp:%i, chstate:%i grpstate:%i\n",
+			__func__, ch->id, dev->name, smp_processor_id(),
+				fsm_getstate(fi), fsm_getstate(grp->fsm));
 
 	fsm_newstate(fi, CTC_STATE_RXIDLE);
 	/* XID processing complete */
@@ -1575,9 +1547,7 @@ void ctcmpc_chx_rxidle(fsm_instance *fi,
 		skb_reset_tail_pointer(ch->trans_skb);
 		ch->trans_skb->len = 0;
 		ch->ccw[1].count = ch->max_bufsize;
-		if (do_debug_ccw)
-			ctcmpc_dumpit((char *)&ch->ccw[0],
-						sizeof(struct ccw1) * 3);
+		CTCM_CCW_DUMP((char *)&ch->ccw[0], sizeof(struct ccw1) * 3);
 		if (event == CTC_EVENT_START)
 			/* see remark about conditional locking */
 			spin_lock_irqsave(get_ccwdev_lock(ch->cdev), saveflags);
@@ -1598,9 +1568,6 @@ void ctcmpc_chx_rxidle(fsm_instance *fi,
 
 	fsm_event(priv->fsm, DEV_EVENT_RXUP, dev);
 done:
-	if (do_debug)
-		ctcm_pr_debug("ctcmpc exit: %s  %s()\n",
-					dev->name, __FUNCTION__);
 	return;
 }
 
@@ -1616,13 +1583,9 @@ static void ctcmpc_chx_attn(fsm_instance
 	struct ctcm_priv  *priv   = dev->priv;
 	struct mpc_group  *grp = priv->mpcg;
 
-	if (do_debug) {
-		ctcm_pr_debug("ctcmpc enter: %s(): cp=%i ch=0x%p id=%s"
-				"GrpState:%s ChState:%s\n",
-				__FUNCTION__, smp_processor_id(), ch, ch->id,
-		fsm_getstate_str(grp->fsm),
-		fsm_getstate_str(ch->fsm));
-	}
+	CTCM_PR_DEBUG("%s(%s): %s(ch=0x%p), cp=%i, ChStat:%s, GrpStat:%s\n",
+		__func__, dev->name, ch->id, ch, smp_processor_id(),
+			fsm_getstate_str(ch->fsm), fsm_getstate_str(grp->fsm));
 
 	switch (fsm_getstate(grp->fsm)) {
 	case MPCG_STATE_XID2INITW:
@@ -1664,11 +1627,7 @@ static void ctcmpc_chx_attn(fsm_instance
 		break;
 	}
 
-	if (do_debug)
-		ctcm_pr_debug("ctcmpc exit : %s(): cp=%i ch=0x%p id=%s\n",
-			__FUNCTION__, smp_processor_id(), ch, ch->id);
 	return;
-
 }
 
 /*
@@ -1683,11 +1642,9 @@ static void ctcmpc_chx_attnbusy(fsm_inst
 	struct ctcm_priv  *priv   = dev->priv;
 	struct mpc_group  *grp    = priv->mpcg;
 
-	ctcm_pr_debug("ctcmpc enter: %s  %s() %s  \nGrpState:%s ChState:%s\n",
-		       dev->name,
-		       __FUNCTION__, ch->id,
-		       fsm_getstate_str(grp->fsm),
-		       fsm_getstate_str(ch->fsm));
+	CTCM_PR_DEBUG("%s(%s): %s\n  ChState:%s GrpState:%s\n",
+			__func__, dev->name, ch->id,
+			fsm_getstate_str(ch->fsm), fsm_getstate_str(grp->fsm));
 
 	fsm_deltimer(&ch->timer);
 
@@ -1750,16 +1707,12 @@ static void ctcmpc_chx_attnbusy(fsm_inst
 	if (ch->in_mpcgroup)
 		fsm_event(grp->fsm, MPCG_EVENT_XID0DO, ch);
 	else
-		printk(KERN_WARNING "ctcmpc: %s() Not all channels have"
-			" been added to group\n", __FUNCTION__);
+		CTCM_DBF_TEXT_(MPC_ERROR, CTC_DBF_ERROR,
+			"%s(%s): channel %s not added to group",
+				CTCM_FUNTAIL, dev->name, ch->id);
 
 done:
-	if (do_debug)
-		ctcm_pr_debug("ctcmpc exit : %s()%s ch=0x%p id=%s\n",
-				__FUNCTION__, dev->name, ch, ch->id);
-
 	return;
-
 }
 
 /*
@@ -1774,13 +1727,7 @@ static void ctcmpc_chx_resend(fsm_instan
 	struct ctcm_priv   *priv   = dev->priv;
 	struct mpc_group   *grp    = priv->mpcg;
 
-	ctcm_pr_debug("ctcmpc enter: %s  %s() %s  \nGrpState:%s ChState:%s\n",
-		       dev->name, __FUNCTION__, ch->id,
-		       fsm_getstate_str(grp->fsm),
-		       fsm_getstate_str(ch->fsm));
-
 	fsm_event(grp->fsm, MPCG_EVENT_XID0DO, ch);
-
 	return;
 }
 
@@ -1802,19 +1749,16 @@ static void ctcmpc_chx_send_sweep(fsm_in
 	int rc = 0;
 	unsigned long saveflags = 0;
 
-	if (do_debug)
-		ctcm_pr_debug("ctcmpc enter: %s(): cp=%i ch=0x%p id=%s\n",
-			__FUNCTION__, smp_processor_id(), ach, ach->id);
+	CTCM_PR_DEBUG("ctcmpc enter: %s(): cp=%i ch=0x%p id=%s\n",
+			__func__, smp_processor_id(), ach, ach->id);
 
 	if (grp->in_sweep == 0)
 				goto done;
 
-	if (do_debug_data) {
-		ctcm_pr_debug("ctcmpc: %s() 1: ToVTAM_th_seq= %08x\n" ,
-			       __FUNCTION__, wch->th_seq_num);
-		ctcm_pr_debug("ctcmpc: %s() 1: FromVTAM_th_seq= %08x\n" ,
-				__FUNCTION__, rch->th_seq_num);
-	}
+	CTCM_PR_DBGDATA("%s: 1: ToVTAM_th_seq= %08x\n" ,
+				__func__, wch->th_seq_num);
+	CTCM_PR_DBGDATA("%s: 1: FromVTAM_th_seq= %08x\n" ,
+				__func__, rch->th_seq_num);
 
 	if (fsm_getstate(wch->fsm) != CTC_STATE_TXIDLE) {
 		/* give the previous IO time to complete */
@@ -1853,11 +1797,9 @@ static void ctcmpc_chx_send_sweep(fsm_in
 
 	header->sw.th_last_seq = wch->th_seq_num;
 
-	if (do_debug_ccw)
-		ctcmpc_dumpit((char *)&wch->ccw[3], sizeof(struct ccw1) * 3);
-
-	ctcm_pr_debug("ctcmpc: %s() sweep packet\n", __FUNCTION__);
-	ctcmpc_dumpit((char *)header, TH_SWEEP_LENGTH);
+	CTCM_CCW_DUMP((char *)&wch->ccw[3], sizeof(struct ccw1) * 3);
+	CTCM_PR_DBGDATA("%s: sweep packet\n", __func__);
+	CTCM_D3_DUMP((char *)header, TH_SWEEP_LENGTH);
 
 	fsm_addtimer(&wch->timer, CTCM_TIME_5_SEC, CTC_EVENT_TIMER, wch);
 	fsm_newstate(wch->fsm, CTC_STATE_TX);
@@ -1876,19 +1818,13 @@ static void ctcmpc_chx_send_sweep(fsm_in
 		ctcm_clear_busy_do(dev);
 	}
 
-	if (do_debug_data) {
-		ctcm_pr_debug("ctcmpc: %s()2: ToVTAM_th_seq= %08x\n" ,
-			       __FUNCTION__, wch->th_seq_num);
-		ctcm_pr_debug("ctcmpc: %s()2: FromVTAM_th_seq= %08x\n" ,
-			       __FUNCTION__, rch->th_seq_num);
-	}
+	CTCM_PR_DBGDATA("%s: To-/From-VTAM_th_seq = %08x/%08x\n" ,
+			__func__, wch->th_seq_num, rch->th_seq_num);
 
 	if (rc != 0)
 		ctcm_ccw_check_rc(wch, rc, "send sweep");
 
 done:
-	if (do_debug)
-		ctcm_pr_debug("ctcmpc exit:  %s() %s\n", __FUNCTION__, ach->id);
 	return;
 }
 
@@ -2149,9 +2085,8 @@ static void dev_action_stop(fsm_instance
 		struct channel *ch = priv->channel[direction];
 		fsm_event(ch->fsm, CTC_EVENT_STOP, ch);
 		ch->th_seq_num = 0x00;
-	if (do_debug)
-		ctcm_pr_debug("ctcm: %s() CH_th_seq= %08x\n",
-				__FUNCTION__, ch->th_seq_num);
+		CTCM_PR_DEBUG("%s: CH_th_seq= %08x\n",
+				__func__, ch->th_seq_num);
 	}
 	if (IS_MPC(priv))
 		fsm_newstate(priv->mpcg->fsm, MPCG_STATE_RESET);
@@ -2199,8 +2134,11 @@ static void dev_action_chup(fsm_instance
 {
 	struct net_device *dev = arg;
 	struct ctcm_priv *priv = dev->priv;
+	int dev_stat = fsm_getstate(fi);
 
-	CTCMY_DBF_DEV_NAME(SETUP, dev, "");
+	CTCM_DBF_TEXT_(SETUP, CTC_DBF_NOTICE,
+			"%s(%s): priv = %p [%d,%d]\n ",	CTCM_FUNTAIL,
+				dev->name, dev->priv, dev_stat, event);
 
 	switch (fsm_getstate(fi)) {
 	case DEV_STATE_STARTWAIT_RXTX:
Index: linux-2.6-uschi/drivers/s390/net/ctcm_main.c
===================================================================
--- linux-2.6-uschi.orig/drivers/s390/net/ctcm_main.c
+++ linux-2.6-uschi/drivers/s390/net/ctcm_main.c
@@ -84,20 +84,19 @@ void ctcm_unpack_skb(struct channel *ch,
 		skb_pull(pskb, LL_HEADER_LENGTH);
 		if ((ch->protocol == CTCM_PROTO_S390) &&
 		    (header->type != ETH_P_IP)) {
-
 			if (!(ch->logflags & LOG_FLAG_ILLEGALPKT)) {
+				ch->logflags |= LOG_FLAG_ILLEGALPKT;
 				/*
 				 * Check packet type only if we stick strictly
 				 * to S/390's protocol of OS390. This only
 				 * supports IP. Otherwise allow any packet
 				 * type.
 				 */
-				ctcm_pr_warn("%s Illegal packet type 0x%04x "
-						"received, dropping\n",
-						dev->name, header->type);
-				ch->logflags |= LOG_FLAG_ILLEGALPKT;
+				CTCM_DBF_TEXT_(ERROR, CTC_DBF_ERROR,
+					"%s(%s): Illegal packet type 0x%04x"
+					" - dropping",
+					CTCM_FUNTAIL, dev->name, header->type);
 			}
-
 			priv->stats.rx_dropped++;
 			priv->stats.rx_frame_errors++;
 			return;
@@ -105,11 +104,11 @@ void ctcm_unpack_skb(struct channel *ch,
 		pskb->protocol = ntohs(header->type);
 		if (header->length <= LL_HEADER_LENGTH) {
 			if (!(ch->logflags & LOG_FLAG_ILLEGALSIZE)) {
-				ctcm_pr_warn(
-					"%s Illegal packet size %d "
-					"received (MTU=%d blocklen=%d), "
-					"dropping\n", dev->name, header->length,
-					dev->mtu, len);
+				CTCM_DBF_TEXT_(ERROR, CTC_DBF_ERROR,
+					"%s(%s): Illegal packet size %d(%d,%d)"
+					"- dropping",
+					CTCM_FUNTAIL, dev->name,
+					header->length, dev->mtu, len);
 				ch->logflags |= LOG_FLAG_ILLEGALSIZE;
 			}
 
@@ -122,10 +121,10 @@ void ctcm_unpack_skb(struct channel *ch,
 		if ((header->length > skb_tailroom(pskb)) ||
 			(header->length > len)) {
 			if (!(ch->logflags & LOG_FLAG_OVERRUN)) {
-				ctcm_pr_warn(
-					"%s Illegal packet size %d (beyond the"
-					" end of received data), dropping\n",
-					dev->name, header->length);
+				CTCM_DBF_TEXT_(ERROR, CTC_DBF_ERROR,
+					"%s(%s): Packet size %d (overrun)"
+					" - dropping", CTCM_FUNTAIL,
+						dev->name, header->length);
 				ch->logflags |= LOG_FLAG_OVERRUN;
 			}
 
@@ -139,9 +138,9 @@ void ctcm_unpack_skb(struct channel *ch,
 		skb = dev_alloc_skb(pskb->len);
 		if (!skb) {
 			if (!(ch->logflags & LOG_FLAG_NOMEM)) {
-				ctcm_pr_warn(
-					"%s Out of memory in ctcm_unpack_skb\n",
-					dev->name);
+				CTCM_DBF_TEXT_(ERROR, CTC_DBF_ERROR,
+					"%s(%s): MEMORY allocation error",
+						CTCM_FUNTAIL, dev->name);
 				ch->logflags |= LOG_FLAG_NOMEM;
 			}
 			priv->stats.rx_dropped++;
@@ -184,7 +183,7 @@ void ctcm_unpack_skb(struct channel *ch,
  */
 static void channel_free(struct channel *ch)
 {
-	CTCM_DBF_TEXT(TRACE, 2, __FUNCTION__);
+	CTCM_DBF_TEXT_(SETUP, CTC_DBF_INFO, "%s(%s)", CTCM_FUNTAIL, ch->id);
 	ch->flags &= ~CHANNEL_FLAGS_INUSE;
 	fsm_newstate(ch->fsm, CTC_STATE_IDLE);
 }
@@ -251,19 +250,12 @@ static struct channel *channel_get(enum 
 {
 	struct channel *ch = channels;
 
-	if (do_debug) {
-		char buf[64];
-		sprintf(buf, "%s(%d, %s, %d)\n",
-				CTCM_FUNTAIL, type, id, direction);
-		CTCM_DBF_TEXT(TRACE, CTC_DBF_INFO, buf);
-	}
 	while (ch && (strncmp(ch->id, id, CTCM_ID_SIZE) || (ch->type != type)))
 		ch = ch->next;
 	if (!ch) {
-		char buf[64];
-		sprintf(buf, "%s(%d, %s, %d) not found in channel list\n",
+		CTCM_DBF_TEXT_(ERROR, CTC_DBF_ERROR,
+				"%s(%d, %s, %d) not found in channel list\n",
 				CTCM_FUNTAIL, type, id, direction);
-		CTCM_DBF_TEXT(ERROR, CTC_DBF_ERROR, buf);
 	} else {
 		if (ch->flags & CHANNEL_FLAGS_INUSE)
 			ch = NULL;
@@ -283,8 +275,9 @@ static long ctcm_check_irb_error(struct 
 	if (!IS_ERR(irb))
 		return 0;
 
-	CTCM_DBF_TEXT_(ERROR, CTC_DBF_WARN, "irb error %ld on device %s\n",
-			PTR_ERR(irb), cdev->dev.bus_id);
+	CTCM_DBF_TEXT_(ERROR, CTC_DBF_WARN,
+			"irb error %ld on device %s\n",
+				PTR_ERR(irb), cdev->dev.bus_id);
 
 	switch (PTR_ERR(irb)) {
 	case -EIO:
@@ -307,58 +300,85 @@ static long ctcm_check_irb_error(struct 
  *  ch		The channel, the sense code belongs to.
  *  sense	The sense code to inspect.
  */
-static inline void ccw_unit_check(struct channel *ch, unsigned char sense)
+static inline void ccw_unit_check(struct channel *ch, __u8 sense)
 {
-	CTCM_DBF_TEXT(TRACE, 5, __FUNCTION__);
+	CTCM_DBF_TEXT_(TRACE, CTC_DBF_DEBUG,
+			"%s(%s): %02x",
+				CTCM_FUNTAIL, ch->id, sense);
+
 	if (sense & SNS0_INTERVENTION_REQ) {
 		if (sense & 0x01) {
-			ctcm_pr_debug("%s: Interface disc. or Sel. reset "
-					"(remote)\n", ch->id);
+			if (ch->sense_rc != 0x01) {
+				ctcm_pr_debug("%s: Interface disc. or Sel. "
+					      "reset (remote)\n", ch->id);
+				ch->sense_rc = 0x01;
+			}
 			fsm_event(ch->fsm, CTC_EVENT_UC_RCRESET, ch);
 		} else {
-			ctcm_pr_debug("%s: System reset (remote)\n", ch->id);
+			if (ch->sense_rc != SNS0_INTERVENTION_REQ) {
+				ctcm_pr_debug("%s: System reset (remote)\n",
+					      ch->id);
+				ch->sense_rc = SNS0_INTERVENTION_REQ;
+			}
 			fsm_event(ch->fsm, CTC_EVENT_UC_RSRESET, ch);
 		}
 	} else if (sense & SNS0_EQUIPMENT_CHECK) {
 		if (sense & SNS0_BUS_OUT_CHECK) {
-			ctcm_pr_warn("%s: Hardware malfunction (remote)\n",
-				ch->id);
+			if (ch->sense_rc != SNS0_BUS_OUT_CHECK) {
+				CTCM_DBF_TEXT_(TRACE, CTC_DBF_WARN,
+					"%s(%s): remote HW error %02x",
+						CTCM_FUNTAIL, ch->id, sense);
+				ch->sense_rc = SNS0_BUS_OUT_CHECK;
+			}
 			fsm_event(ch->fsm, CTC_EVENT_UC_HWFAIL, ch);
 		} else {
-			ctcm_pr_warn("%s: Read-data parity error (remote)\n",
-				ch->id);
+			if (ch->sense_rc != SNS0_EQUIPMENT_CHECK) {
+				CTCM_DBF_TEXT_(TRACE, CTC_DBF_WARN,
+					"%s(%s): remote read parity error %02x",
+						CTCM_FUNTAIL, ch->id, sense);
+				ch->sense_rc = SNS0_EQUIPMENT_CHECK;
+			}
 			fsm_event(ch->fsm, CTC_EVENT_UC_RXPARITY, ch);
 		}
 	} else if (sense & SNS0_BUS_OUT_CHECK) {
-		if (sense & 0x04) {
-			ctcm_pr_warn("%s: Data-streaming timeout)\n", ch->id);
+		if (ch->sense_rc != SNS0_BUS_OUT_CHECK) {
+			CTCM_DBF_TEXT_(TRACE, CTC_DBF_WARN,
+				"%s(%s): BUS OUT error %02x",
+					CTCM_FUNTAIL, ch->id, sense);
+			ch->sense_rc = SNS0_BUS_OUT_CHECK;
+		}
+		if (sense & 0x04)	/* data-streaming timeout */
 			fsm_event(ch->fsm, CTC_EVENT_UC_TXTIMEOUT, ch);
-		} else {
-			ctcm_pr_warn("%s: Data-transfer parity error\n",
-					ch->id);
+		else			/* Data-transfer parity error */
 			fsm_event(ch->fsm, CTC_EVENT_UC_TXPARITY, ch);
-		}
 	} else if (sense & SNS0_CMD_REJECT) {
-		ctcm_pr_warn("%s: Command reject\n", ch->id);
+		if (ch->sense_rc != SNS0_CMD_REJECT) {
+			CTCM_DBF_TEXT_(TRACE, CTC_DBF_WARN,
+				"%s(%s): Command rejected",
+						CTCM_FUNTAIL, ch->id);
+			ch->sense_rc = SNS0_CMD_REJECT;
+		}
 	} else if (sense == 0) {
-		ctcm_pr_debug("%s: Unit check ZERO\n", ch->id);
+		CTCM_DBF_TEXT_(TRACE, CTC_DBF_WARN,
+			"%s(%s): Unit check ZERO",
+					CTCM_FUNTAIL, ch->id);
 		fsm_event(ch->fsm, CTC_EVENT_UC_ZERO, ch);
 	} else {
-		ctcm_pr_warn("%s: Unit Check with sense code: %02x\n",
-			    ch->id, sense);
+		CTCM_DBF_TEXT_(TRACE, CTC_DBF_WARN,
+			"%s(%s): Unit check code %02x unknown",
+					CTCM_FUNTAIL, ch->id, sense);
 		fsm_event(ch->fsm, CTC_EVENT_UC_UNKNOWN, ch);
 	}
 }
 
 int ctcm_ch_alloc_buffer(struct channel *ch)
 {
-	CTCM_DBF_TEXT(TRACE, 5, __FUNCTION__);
-
 	clear_normalized_cda(&ch->ccw[1]);
 	ch->trans_skb = __dev_alloc_skb(ch->max_bufsize, GFP_ATOMIC | GFP_DMA);
 	if (ch->trans_skb == NULL) {
-		ctcm_pr_warn("%s: Couldn't alloc %s trans_skb\n",
-			ch->id,
+		CTCM_DBF_TEXT_(ERROR, CTC_DBF_ERROR,
+			"%s(%s): %s trans_skb allocation error",
+			CTCM_FUNTAIL, ch->id,
 			(CHANNEL_DIRECTION(ch->flags) == READ) ? "RX" : "TX");
 		return -ENOMEM;
 	}
@@ -367,9 +387,9 @@ int ctcm_ch_alloc_buffer(struct channel 
 	if (set_normalized_cda(&ch->ccw[1], ch->trans_skb->data)) {
 		dev_kfree_skb(ch->trans_skb);
 		ch->trans_skb = NULL;
-		ctcm_pr_warn("%s: set_normalized_cda for %s "
-			"trans_skb failed, dropping packets\n",
-			ch->id,
+		CTCM_DBF_TEXT_(ERROR, CTC_DBF_ERROR,
+			"%s(%s): %s set norm_cda failed",
+			CTCM_FUNTAIL, ch->id,
 			(CHANNEL_DIRECTION(ch->flags) == READ) ? "RX" : "TX");
 		return -ENOMEM;
 	}
@@ -516,7 +536,7 @@ static int ctcm_transmit_skb(struct chan
 			atomic_dec(&skb->users);
 			skb_pull(skb, LL_HEADER_LENGTH + 2);
 			ctcm_clear_busy(ch->netdev);
-			return -EBUSY;
+			return -ENOMEM;
 		}
 
 		skb_reset_tail_pointer(ch->trans_skb);
@@ -570,15 +590,12 @@ static void ctcmpc_send_sweep_req(struct
 	struct th_sweep *header;
 	struct sk_buff *sweep_skb;
 	struct channel *ch;
-	int rc = 0;
+	/* int rc = 0; */
 
 	priv = dev->priv;
 	grp = priv->mpcg;
 	ch = priv->channel[WRITE];
 
-	if (do_debug)
-		MPC_DBF_DEV_NAME(TRACE, dev, ch->id);
-
 	/* sweep processing is not complete until response and request */
 	/* has completed for all read channels in group		       */
 	if (grp->in_sweep == 0) {
@@ -590,17 +607,16 @@ static void ctcmpc_send_sweep_req(struct
 	sweep_skb = __dev_alloc_skb(MPC_BUFSIZE_DEFAULT, GFP_ATOMIC|GFP_DMA);
 
 	if (sweep_skb == NULL)	{
-		printk(KERN_INFO "Couldn't alloc sweep_skb\n");
-		rc = -ENOMEM;
-					goto done;
+		/* rc = -ENOMEM; */
+				goto nomem;
 	}
 
 	header = kmalloc(TH_SWEEP_LENGTH, gfp_type());
 
 	if (!header) {
 		dev_kfree_skb_any(sweep_skb);
-		rc = -ENOMEM;
-					goto done;
+		/* rc = -ENOMEM; */
+				goto nomem;
 	}
 
 	header->th.th_seg	= 0x00 ;
@@ -621,12 +637,10 @@ static void ctcmpc_send_sweep_req(struct
 
 	return;
 
-done:
-	if (rc != 0) {
-		grp->in_sweep = 0;
-		ctcm_clear_busy(dev);
-		fsm_event(grp->fsm, MPCG_EVENT_INOP, dev);
-	}
+nomem:
+	grp->in_sweep = 0;
+	ctcm_clear_busy(dev);
+	fsm_event(grp->fsm, MPCG_EVENT_INOP, dev);
 
 	return;
 }
@@ -648,11 +662,9 @@ static int ctcmpc_transmit_skb(struct ch
 	unsigned long saveflags = 0;	/* avoids compiler warning */
 	__u16 block_len;
 
-	if (do_debug)
-		ctcm_pr_debug(
-			"ctcm enter: %s(): %s cp=%i ch=0x%p id=%s state=%s\n",
-			__FUNCTION__, dev->name, smp_processor_id(), ch,
-			ch->id, fsm_getstate_str(ch->fsm));
+	CTCM_PR_DEBUG("Enter %s: %s, cp=%i ch=0x%p id=%s state=%s\n",
+			__func__, dev->name, smp_processor_id(), ch,
+					ch->id, fsm_getstate_str(ch->fsm));
 
 	if ((fsm_getstate(ch->fsm) != CTC_STATE_TXIDLE) || grp->in_sweep) {
 		spin_lock_irqsave(&ch->collect_lock, saveflags);
@@ -660,14 +672,8 @@ static int ctcmpc_transmit_skb(struct ch
 		p_header = kmalloc(PDU_HEADER_LENGTH, gfp_type());
 
 		if (!p_header) {
-			printk(KERN_WARNING "ctcm: OUT OF MEMORY IN %s():"
-			       " Data Lost \n", __FUNCTION__);
-
-			atomic_dec(&skb->users);
-			dev_kfree_skb_any(skb);
 			spin_unlock_irqrestore(&ch->collect_lock, saveflags);
-			fsm_event(priv->mpcg->fsm, MPCG_EVENT_INOP, dev);
-					goto done;
+				goto nomem_exit;
 		}
 
 		p_header->pdu_offset = skb->len;
@@ -682,13 +688,10 @@ static int ctcmpc_transmit_skb(struct ch
 		memcpy(skb_push(skb, PDU_HEADER_LENGTH), p_header,
 		       PDU_HEADER_LENGTH);
 
-		if (do_debug_data) {
-			ctcm_pr_debug("ctcm: %s() Putting on collect_q"
-			       " - skb len: %04x \n", __FUNCTION__, skb->len);
-			ctcm_pr_debug("ctcm: %s() pdu header and data"
-			       " for up to 32 bytes\n", __FUNCTION__);
-			ctcmpc_dump32((char *)skb->data, skb->len);
-		}
+		CTCM_PR_DEBUG("%s(%s): Put on collect_q - skb len: %04x \n"
+				"pdu header and data for up to 32 bytes:\n",
+				__func__, dev->name, skb->len);
+		CTCM_D3_DUMP((char *)skb->data, min_t(int, 32, skb->len));
 
 		skb_queue_tail(&ch->collect_queue, skb);
 		ch->collect_len += skb->len;
@@ -713,12 +716,7 @@ static int ctcmpc_transmit_skb(struct ch
 	if (hi) {
 		nskb = __dev_alloc_skb(skb->len, GFP_ATOMIC | GFP_DMA);
 		if (!nskb) {
-			printk(KERN_WARNING "ctcm: %s() OUT OF MEMORY"
-				"-  Data Lost \n", __FUNCTION__);
-			atomic_dec(&skb->users);
-			dev_kfree_skb_any(skb);
-			fsm_event(priv->mpcg->fsm, MPCG_EVENT_INOP, dev);
-				goto done;
+			goto nomem_exit;
 		} else {
 			memcpy(skb_put(nskb, skb->len), skb->data, skb->len);
 			atomic_inc(&nskb->users);
@@ -730,15 +728,8 @@ static int ctcmpc_transmit_skb(struct ch
 
 	p_header = kmalloc(PDU_HEADER_LENGTH, gfp_type());
 
-	if (!p_header) {
-		printk(KERN_WARNING "ctcm: %s() OUT OF MEMORY"
-		       ": Data Lost \n", __FUNCTION__);
-
-		atomic_dec(&skb->users);
-		dev_kfree_skb_any(skb);
-		fsm_event(priv->mpcg->fsm, MPCG_EVENT_INOP, dev);
-				goto done;
-	}
+	if (!p_header)
+		goto nomem_exit;
 
 	p_header->pdu_offset = skb->len;
 	p_header->pdu_proto = 0x01;
@@ -768,15 +759,8 @@ static int ctcmpc_transmit_skb(struct ch
 	ch->prof.txlen += skb->len - PDU_HEADER_LENGTH;
 
 	header = kmalloc(TH_HEADER_LENGTH, gfp_type());
-
-	if (!header) {
-		printk(KERN_WARNING "ctcm: %s() OUT OF MEMORY: Data Lost \n",
-				__FUNCTION__);
-		atomic_dec(&skb->users);
-		dev_kfree_skb_any(skb);
-		fsm_event(priv->mpcg->fsm, MPCG_EVENT_INOP, dev);
-				goto done;
-	}
+	if (!header)
+		goto nomem_exit;
 
 	header->th_seg = 0x00;
 	header->th_ch_flag = TH_HAS_PDU;  /* Normal data */
@@ -785,41 +769,31 @@ static int ctcmpc_transmit_skb(struct ch
 	ch->th_seq_num++;
 	header->th_seq_num = ch->th_seq_num;
 
-	if (do_debug_data)
-		ctcm_pr_debug("ctcm: %s() ToVTAM_th_seq= %08x\n" ,
-		       __FUNCTION__, ch->th_seq_num);
+	CTCM_PR_DBGDATA("%s(%s) ToVTAM_th_seq= %08x\n" ,
+		       __func__, dev->name, ch->th_seq_num);
 
 	/* put the TH on the packet */
 	memcpy(skb_push(skb, TH_HEADER_LENGTH), header, TH_HEADER_LENGTH);
 
 	kfree(header);
 
-	if (do_debug_data) {
-		ctcm_pr_debug("ctcm: %s(): skb len: %04x \n",
-				__FUNCTION__, skb->len);
-		ctcm_pr_debug("ctcm: %s(): pdu header and data for up to 32 "
-				"bytes sent to vtam\n", __FUNCTION__);
-		ctcmpc_dump32((char *)skb->data, skb->len);
-	}
+	CTCM_PR_DBGDATA("%s(%s): skb len: %04x\n - pdu header and data for "
+			"up to 32 bytes sent to vtam:\n",
+				__func__, dev->name, skb->len);
+	CTCM_D3_DUMP((char *)skb->data, min_t(int, 32, skb->len));
 
 	ch->ccw[4].count = skb->len;
 	if (set_normalized_cda(&ch->ccw[4], skb->data)) {
 		/*
-		 * idal allocation failed, try via copying to
-		 * trans_skb. trans_skb usually has a pre-allocated
-		 * idal.
+		 * idal allocation failed, try via copying to trans_skb.
+		 * trans_skb usually has a pre-allocated idal.
 		 */
 		if (ctcm_checkalloc_buffer(ch)) {
 			/*
-			 * Remove our header. It gets added
-			 * again on retransmit.
+			 * Remove our header.
+			 * It gets added again on retransmit.
 			 */
-			atomic_dec(&skb->users);
-			dev_kfree_skb_any(skb);
-			printk(KERN_WARNING "ctcm: %s()OUT OF MEMORY:"
-					" Data Lost \n", __FUNCTION__);
-			fsm_event(priv->mpcg->fsm, MPCG_EVENT_INOP, dev);
-				goto done;
+				goto nomem_exit;
 		}
 
 		skb_reset_tail_pointer(ch->trans_skb);
@@ -829,14 +803,11 @@ static int ctcmpc_transmit_skb(struct ch
 		atomic_dec(&skb->users);
 		dev_kfree_skb_irq(skb);
 		ccw_idx = 0;
-		if (do_debug_data) {
-			ctcm_pr_debug("ctcm: %s() TRANS skb len: %d \n",
-			       __FUNCTION__, ch->trans_skb->len);
-			ctcm_pr_debug("ctcm: %s up to 32 bytes of data"
-				" sent to vtam\n", __FUNCTION__);
-			ctcmpc_dump32((char *)ch->trans_skb->data,
-					ch->trans_skb->len);
-		}
+		CTCM_PR_DBGDATA("%s(%s): trans_skb len: %04x\n"
+				"up to 32 bytes sent to vtam:\n",
+				__func__, dev->name, ch->trans_skb->len);
+		CTCM_D3_DUMP((char *)ch->trans_skb->data,
+				min_t(int, 32, ch->trans_skb->len));
 	} else {
 		skb_queue_tail(&ch->io_queue, skb);
 		ccw_idx = 3;
@@ -865,13 +836,21 @@ static int ctcmpc_transmit_skb(struct ch
 		priv->stats.tx_packets++;
 		priv->stats.tx_bytes += skb->len - TH_HEADER_LENGTH;
 	}
-	if (ch->th_seq_num > 0xf0000000)	/* Chose 4Billion at random. */
+	if (ch->th_seq_num > 0xf0000000)	/* Chose at random. */
 		ctcmpc_send_sweep_req(ch);
 
+	goto done;
+nomem_exit:
+	CTCM_DBF_TEXT_(MPC_ERROR, CTC_DBF_CRIT,
+			"%s(%s): MEMORY allocation ERROR\n",
+			CTCM_FUNTAIL, ch->id);
+	rc = -ENOMEM;
+	atomic_dec(&skb->users);
+	dev_kfree_skb_any(skb);
+	fsm_event(priv->mpcg->fsm, MPCG_EVENT_INOP, dev);
 done:
-	if (do_debug)
-		ctcm_pr_debug("ctcm exit: %s  %s()\n", dev->name, __FUNCTION__);
-	return 0;
+	CTCM_PR_DEBUG("Exit %s(%s)\n", __func__, dev->name);
+	return rc;
 }
 
 /**
@@ -888,20 +867,19 @@ done:
 /* first merge version - leaving both functions separated */
 static int ctcm_tx(struct sk_buff *skb, struct net_device *dev)
 {
-	int rc = 0;
-	struct ctcm_priv *priv;
-
-	CTCM_DBF_TEXT(TRACE, 5, __FUNCTION__);
-	priv = dev->priv;
+	struct ctcm_priv *priv = dev->priv;
 
 	if (skb == NULL) {
-		ctcm_pr_warn("%s: NULL sk_buff passed\n", dev->name);
+		CTCM_DBF_TEXT_(ERROR, CTC_DBF_ERROR,
+				"%s(%s): NULL sk_buff passed",
+					CTCM_FUNTAIL, dev->name);
 		priv->stats.tx_dropped++;
 		return 0;
 	}
 	if (skb_headroom(skb) < (LL_HEADER_LENGTH + 2)) {
-		ctcm_pr_warn("%s: Got sk_buff with head room < %ld bytes\n",
-			    dev->name, LL_HEADER_LENGTH + 2);
+		CTCM_DBF_TEXT_(ERROR, CTC_DBF_ERROR,
+			"%s(%s): Got sk_buff with head room < %ld bytes",
+			CTCM_FUNTAIL, dev->name, LL_HEADER_LENGTH + 2);
 		dev_kfree_skb(skb);
 		priv->stats.tx_dropped++;
 		return 0;
@@ -925,51 +903,43 @@ static int ctcm_tx(struct sk_buff *skb, 
 
 	dev->trans_start = jiffies;
 	if (ctcm_transmit_skb(priv->channel[WRITE], skb) != 0)
-		rc = 1;
-	return rc;
+		return 1;
+	return 0;
 }
 
 /* unmerged MPC variant of ctcm_tx */
 static int ctcmpc_tx(struct sk_buff *skb, struct net_device *dev)
 {
 	int len = 0;
-	struct ctcm_priv *priv = NULL;
-	struct mpc_group *grp  = NULL;
+	struct ctcm_priv *priv = dev->priv;
+	struct mpc_group *grp  = priv->mpcg;
 	struct sk_buff *newskb = NULL;
 
-	if (do_debug)
-		ctcm_pr_debug("ctcmpc enter: %s(): skb:%0lx\n",
-			__FUNCTION__, (unsigned long)skb);
-
-	CTCM_DBF_TEXT_(MPC_TRACE, CTC_DBF_DEBUG,
-			"ctcmpc enter: %s(): skb:%0lx\n",
-			__FUNCTION__, (unsigned long)skb);
-
-	priv = dev->priv;
-	grp  = priv->mpcg;
 	/*
 	 * Some sanity checks ...
 	 */
 	if (skb == NULL) {
-		ctcm_pr_warn("ctcmpc: %s: NULL sk_buff passed\n", dev->name);
+		CTCM_DBF_TEXT_(MPC_ERROR, CTC_DBF_ERROR,
+			"%s(%s): NULL sk_buff passed",
+					CTCM_FUNTAIL, dev->name);
 		priv->stats.tx_dropped++;
 					goto done;
 	}
 	if (skb_headroom(skb) < (TH_HEADER_LENGTH + PDU_HEADER_LENGTH)) {
-		CTCM_DBF_TEXT_(MPC_TRACE, CTC_DBF_WARN,
-			"%s: Got sk_buff with head room < %ld bytes\n",
-			dev->name, TH_HEADER_LENGTH + PDU_HEADER_LENGTH);
+		CTCM_DBF_TEXT_(MPC_TRACE, CTC_DBF_ERROR,
+			"%s(%s): Got sk_buff with head room < %ld bytes",
+			CTCM_FUNTAIL, dev->name,
+				TH_HEADER_LENGTH + PDU_HEADER_LENGTH);
 
-		if (do_debug_data)
-			ctcmpc_dump32((char *)skb->data, skb->len);
+		CTCM_D3_DUMP((char *)skb->data, min_t(int, 32, skb->len));
 
 		len =  skb->len + TH_HEADER_LENGTH + PDU_HEADER_LENGTH;
 		newskb = __dev_alloc_skb(len, gfp_type() | GFP_DMA);
 
 		if (!newskb) {
-			printk(KERN_WARNING "ctcmpc: %s() OUT OF MEMORY-"
-			       "Data Lost\n",
-			       __FUNCTION__);
+			CTCM_DBF_TEXT_(MPC_TRACE, CTC_DBF_ERROR,
+				"%s: %s: __dev_alloc_skb failed",
+						__func__, dev->name);
 
 			dev_kfree_skb_any(skb);
 			priv->stats.tx_dropped++;
@@ -993,9 +963,9 @@ static int ctcmpc_tx(struct sk_buff *skb
 	if ((fsm_getstate(priv->fsm) != DEV_STATE_RUNNING) ||
 	   (fsm_getstate(grp->fsm) <  MPCG_STATE_XID2INITW)) {
 		dev_kfree_skb_any(skb);
-		printk(KERN_INFO "ctcmpc: %s() DATA RCVD - MPC GROUP "
-		       "NOT ACTIVE - DROPPED\n",
-		       __FUNCTION__);
+		CTCM_DBF_TEXT_(MPC_ERROR, CTC_DBF_ERROR,
+			"%s(%s): inactive MPCGROUP - dropped",
+					CTCM_FUNTAIL, dev->name);
 		priv->stats.tx_dropped++;
 		priv->stats.tx_errors++;
 		priv->stats.tx_carrier_errors++;
@@ -1003,8 +973,9 @@ static int ctcmpc_tx(struct sk_buff *skb
 	}
 
 	if (ctcm_test_and_set_busy(dev)) {
-		printk(KERN_WARNING "%s:DEVICE ERR - UNRECOVERABLE DATA LOSS\n",
-		       __FUNCTION__);
+		CTCM_DBF_TEXT_(MPC_ERROR, CTC_DBF_ERROR,
+			"%s(%s): device busy - dropped",
+					CTCM_FUNTAIL, dev->name);
 		dev_kfree_skb_any(skb);
 		priv->stats.tx_dropped++;
 		priv->stats.tx_errors++;
@@ -1015,12 +986,9 @@ static int ctcmpc_tx(struct sk_buff *skb
 
 	dev->trans_start = jiffies;
 	if (ctcmpc_transmit_skb(priv->channel[WRITE], skb) != 0) {
-		printk(KERN_WARNING "ctcmpc: %s() DEVICE ERROR"
-		       ": Data Lost \n",
-		       __FUNCTION__);
-		printk(KERN_WARNING "ctcmpc: %s() DEVICE ERROR"
-		       " - UNRECOVERABLE DATA LOSS\n",
-		       __FUNCTION__);
+		CTCM_DBF_TEXT_(MPC_ERROR, CTC_DBF_ERROR,
+			"%s(%s): device error - dropped",
+					CTCM_FUNTAIL, dev->name);
 		dev_kfree_skb_any(skb);
 		priv->stats.tx_dropped++;
 		priv->stats.tx_errors++;
@@ -1054,8 +1022,6 @@ static int ctcm_change_mtu(struct net_de
 	struct ctcm_priv *priv;
 	int max_bufsize;
 
-	CTCM_DBF_TEXT(SETUP, CTC_DBF_INFO, __FUNCTION__);
-
 	if (new_mtu < 576 || new_mtu > 65527)
 		return -EINVAL;
 
@@ -1087,30 +1053,13 @@ static struct net_device_stats *ctcm_sta
 	return &((struct ctcm_priv *)dev->priv)->stats;
 }
 
-
-static void ctcm_netdev_unregister(struct net_device *dev)
-{
-	CTCM_DBF_TEXT(SETUP, CTC_DBF_INFO, __FUNCTION__);
-	if (!dev)
-		return;
-	unregister_netdev(dev);
-}
-
-static int ctcm_netdev_register(struct net_device *dev)
-{
-	CTCM_DBF_TEXT(SETUP, CTC_DBF_INFO, __FUNCTION__);
-	return register_netdev(dev);
-}
-
 static void ctcm_free_netdevice(struct net_device *dev)
 {
 	struct ctcm_priv *priv;
 	struct mpc_group *grp;
 
-	CTCM_DBF_TEXT(SETUP, CTC_DBF_INFO, __FUNCTION__);
-
-	if (!dev)
-		return;
+	CTCM_DBF_TEXT_(SETUP, CTC_DBF_INFO,
+			"%s(%s)", CTCM_FUNTAIL, dev->name);
 	priv = dev->priv;
 	if (priv) {
 		grp = priv->mpcg;
@@ -1171,7 +1120,9 @@ static struct net_device *ctcm_init_netd
 		dev = alloc_netdev(0, CTC_DEVICE_GENE, ctcm_dev_setup);
 
 	if (!dev) {
-		ctcm_pr_err("%s: Out of memory\n", __FUNCTION__);
+		CTCM_DBF_TEXT_(ERROR, CTC_DBF_CRIT,
+			"%s: MEMORY allocation ERROR",
+			CTCM_FUNTAIL);
 		return NULL;
 	}
 	dev->priv = priv;
@@ -1209,6 +1160,7 @@ static struct net_device *ctcm_init_netd
 	}
 
 	CTCMY_DBF_DEV(SETUP, dev, "finished");
+
 	return dev;
 }
 
@@ -1226,18 +1178,24 @@ static void ctcm_irq_handler(struct ccw_
 	struct net_device	*dev;
 	struct ctcm_priv	*priv;
 	struct ccwgroup_device	*cgdev;
+	int cstat;
+	int dstat;
+
+	CTCM_DBF_TEXT_(TRACE, CTC_DBF_DEBUG,
+		"Enter %s(%s)", CTCM_FUNTAIL, &cdev->dev.bus_id);
 
-	CTCM_DBF_TEXT(TRACE, CTC_DBF_DEBUG, __FUNCTION__);
 	if (ctcm_check_irb_error(cdev, irb))
 		return;
 
 	cgdev = dev_get_drvdata(&cdev->dev);
 
+	cstat = irb->scsw.cmd.cstat;
+	dstat = irb->scsw.cmd.dstat;
+
 	/* Check for unsolicited interrupts. */
 	if (cgdev == NULL) {
-		ctcm_pr_warn("ctcm: Got unsolicited irq: %s c-%02x d-%02x\n",
-			    cdev->dev.bus_id, irb->scsw.cmd.cstat,
-			    irb->scsw.cmd.dstat);
+		ctcm_pr_warn("ctcm: Got unsolicited irq: c-%02x d-%02x\n",
+			     cstat, dstat);
 		return;
 	}
 
@@ -1254,26 +1212,22 @@ static void ctcm_irq_handler(struct ccw_
 		return;
 	}
 
-	dev = (struct net_device *)(ch->netdev);
+	dev = ch->netdev;
 	if (dev == NULL) {
 		ctcm_pr_crit("ctcm: %s dev=NULL bus_id=%s, ch=0x%p\n",
-				__FUNCTION__, cdev->dev.bus_id, ch);
+				__func__, cdev->dev.bus_id, ch);
 		return;
 	}
 
-	if (do_debug)
-		ctcm_pr_debug("%s: interrupt for device: %s "
-				"received c-%02x d-%02x\n",
-				dev->name,
-				ch->id,
-				irb->scsw.cmd.cstat,
-				irb->scsw.cmd.dstat);
+	CTCM_DBF_TEXT_(TRACE, CTC_DBF_DEBUG,
+		"%s(%s): int. for %s: cstat=%02x dstat=%02x",
+			CTCM_FUNTAIL, dev->name, ch->id, cstat, dstat);
 
 	/* Copy interruption response block. */
 	memcpy(ch->irb, irb, sizeof(struct irb));
 
-	/* Check for good subchannel return code, otherwise error message */
 	if (irb->scsw.cmd.cstat) {
+	/* Check for good subchannel return code, otherwise error message */
 		fsm_event(ch->fsm, CTC_EVENT_SC_UNKNOWN, ch);
 		ctcm_pr_warn("%s: subchannel check for dev: %s - %02x %02x\n",
 			    dev->name, ch->id, irb->scsw.cmd.cstat,
@@ -1283,6 +1237,11 @@ static void ctcm_irq_handler(struct ccw_
 
 	/* Check the reason-code of a unit check */
 	if (irb->scsw.cmd.dstat & DEV_STAT_UNIT_CHECK) {
+		if ((irb->ecw[0] & ch->sense_rc) == 0)
+			/* print it only once */
+			CTCM_DBF_TEXT_(TRACE, CTC_DBF_INFO,
+				"%s(%s): sense=%02x, ds=%02x",
+				CTCM_FUNTAIL, ch->id, irb->ecw[0], dstat);
 		ccw_unit_check(ch, irb->ecw[0]);
 		return;
 	}
@@ -1320,14 +1279,18 @@ static int ctcm_probe_device(struct ccwg
 	struct ctcm_priv *priv;
 	int rc;
 
-	CTCM_DBF_TEXT_(SETUP, CTC_DBF_INFO, "%s %p", __FUNCTION__, cgdev);
+	CTCM_DBF_TEXT_(SETUP, CTC_DBF_INFO,
+			"%s %p",
+			__func__, cgdev);
 
 	if (!get_device(&cgdev->dev))
 		return -ENODEV;
 
 	priv = kzalloc(sizeof(struct ctcm_priv), GFP_KERNEL);
 	if (!priv) {
-		ctcm_pr_err("%s: Out of memory\n", __FUNCTION__);
+		CTCM_DBF_TEXT_(ERROR, CTC_DBF_ERROR,
+			"%s: memory allocation failure",
+			CTCM_FUNTAIL);
 		put_device(&cgdev->dev);
 		return -ENOMEM;
 	}
@@ -1364,10 +1327,13 @@ static int add_channel(struct ccw_device
 	int ccw_num;
 	int rc = 0;
 
-	CTCM_DBF_TEXT(TRACE, 2, __FUNCTION__);
+	CTCM_DBF_TEXT_(SETUP, CTC_DBF_INFO,
+		"%s(%s), type %d, proto %d",
+			__func__, cdev->dev.bus_id,	type, priv->protocol);
+
 	ch = kzalloc(sizeof(struct channel), GFP_KERNEL);
 	if (ch == NULL)
-					goto nomem_return;
+		return -ENOMEM;
 
 	ch->protocol = priv->protocol;
 	if (IS_MPC(priv)) {
@@ -1478,7 +1444,7 @@ static int add_channel(struct ccw_device
 	if (*c && (!strncmp((*c)->id, ch->id, CTCM_ID_SIZE))) {
 		CTCM_DBF_TEXT_(SETUP, CTC_DBF_INFO,
 				"%s (%s) already in list, using old entry",
-				__FUNCTION__, (*c)->id);
+				__func__, (*c)->id);
 
 				goto free_return;
 	}
@@ -1498,11 +1464,10 @@ static int add_channel(struct ccw_device
 	return 0;
 
 nomem_return:
-	ctcm_pr_warn("ctcm: Out of memory in %s\n", __FUNCTION__);
 	rc = -ENOMEM;
 
 free_return:	/* note that all channel pointers are 0 or valid */
-	kfree(ch->ccw);		/* TODO: check that again */
+	kfree(ch->ccw);
 	kfree(ch->discontact_th);
 	kfree_fsm(ch->fsm);
 	kfree(ch->irb);
@@ -1540,48 +1505,48 @@ static int ctcm_new_device(struct ccwgro
 	enum channel_types type;
 	struct ctcm_priv *priv;
 	struct net_device *dev;
+	struct ccw_device *cdev0;
+	struct ccw_device *cdev1;
 	int ret;
 
-	CTCM_DBF_TEXT(SETUP, CTC_DBF_INFO, __FUNCTION__);
-
 	priv = dev_get_drvdata(&cgdev->dev);
 	if (!priv)
 		return -ENODEV;
 
-	type = get_channel_type(&cgdev->cdev[0]->id);
+	cdev0 = cgdev->cdev[0];
+	cdev1 = cgdev->cdev[1];
+
+	type = get_channel_type(&cdev0->id);
 
-	snprintf(read_id, CTCM_ID_SIZE, "ch-%s", cgdev->cdev[0]->dev.bus_id);
-	snprintf(write_id, CTCM_ID_SIZE, "ch-%s", cgdev->cdev[1]->dev.bus_id);
+	snprintf(read_id, CTCM_ID_SIZE, "ch-%s", cdev0->dev.bus_id);
+	snprintf(write_id, CTCM_ID_SIZE, "ch-%s", cdev1->dev.bus_id);
 
-	ret = add_channel(cgdev->cdev[0], type, priv);
+	ret = add_channel(cdev0, type, priv);
 	if (ret)
 		return ret;
-	ret = add_channel(cgdev->cdev[1], type, priv);
+	ret = add_channel(cdev1, type, priv);
 	if (ret)
 		return ret;
 
-	ret = ccw_device_set_online(cgdev->cdev[0]);
+	ret = ccw_device_set_online(cdev0);
 	if (ret != 0) {
-		CTCM_DBF_TEXT(SETUP, CTC_DBF_WARN,
-				"ccw_device_set_online (cdev[0]) failed ");
-		ctcm_pr_warn("ccw_device_set_online (cdev[0]) failed "
-				"with ret = %d\n", ret);
+		/* may be ok to fail now - can be done later */
+		CTCM_DBF_TEXT_(TRACE, CTC_DBF_NOTICE,
+			"%s(%s) set_online rc=%d",
+				CTCM_FUNTAIL, read_id, ret);
 	}
 
-	ret = ccw_device_set_online(cgdev->cdev[1]);
+	ret = ccw_device_set_online(cdev1);
 	if (ret != 0) {
-		CTCM_DBF_TEXT(SETUP, CTC_DBF_WARN,
-				"ccw_device_set_online (cdev[1]) failed ");
-		ctcm_pr_warn("ccw_device_set_online (cdev[1]) failed "
-				"with ret = %d\n", ret);
+		/* may be ok to fail now - can be done later */
+		CTCM_DBF_TEXT_(TRACE, CTC_DBF_NOTICE,
+			"%s(%s) set_online rc=%d",
+				CTCM_FUNTAIL, write_id, ret);
 	}
 
 	dev = ctcm_init_netdevice(priv);
-
-	if (dev == NULL) {
-		ctcm_pr_warn("ctcm_init_netdevice failed\n");
-					goto out;
-	}
+	if (dev == NULL)
+			goto out;
 
 	for (direction = READ; direction <= WRITE; direction++) {
 		priv->channel[direction] =
@@ -1590,8 +1555,7 @@ static int ctcm_new_device(struct ccwgro
 		if (priv->channel[direction] == NULL) {
 			if (direction == WRITE)
 				channel_free(priv->channel[READ]);
-			ctcm_free_netdevice(dev);
-					goto out;
+			goto out_dev;
 		}
 		priv->channel[direction]->netdev = dev;
 		priv->channel[direction]->protocol = priv->protocol;
@@ -1600,26 +1564,24 @@ static int ctcm_new_device(struct ccwgro
 	/* sysfs magic */
 	SET_NETDEV_DEV(dev, &cgdev->dev);
 
-	if (ctcm_netdev_register(dev) != 0) {
-		ctcm_free_netdevice(dev);
-					goto out;
-	}
+	if (register_netdev(dev))
+			goto out_dev;
 
 	if (ctcm_add_attributes(&cgdev->dev)) {
-		ctcm_netdev_unregister(dev);
-/*		dev->priv = NULL;	why that ????	*/
-		ctcm_free_netdevice(dev);
-					goto out;
+		unregister_netdev(dev);
+			goto out_dev;
 	}
 
 	strlcpy(priv->fsm->name, dev->name, sizeof(priv->fsm->name));
 
 	CTCM_DBF_TEXT_(SETUP, CTC_DBF_INFO,
-			"setup(%s) ok : r/w = %s / %s, proto : %d",
-			dev->name, priv->channel[READ]->id,
+		"setup(%s) OK : r/w = %s/%s, protocol : %d", dev->name,
+			priv->channel[READ]->id,
 			priv->channel[WRITE]->id, priv->protocol);
 
 	return 0;
+out_dev:
+	ctcm_free_netdevice(dev);
 out:
 	ccw_device_set_offline(cgdev->cdev[1]);
 	ccw_device_set_offline(cgdev->cdev[0]);
@@ -1658,8 +1620,7 @@ static int ctcm_shutdown_device(struct c
 		channel_free(priv->channel[WRITE]);
 
 	if (dev) {
-		ctcm_netdev_unregister(dev);
-/*		dev->priv = NULL;	why that ???	*/
+		unregister_netdev(dev);
 		ctcm_free_netdevice(dev);
 	}
 
@@ -1682,13 +1643,16 @@ static int ctcm_shutdown_device(struct c
 
 static void ctcm_remove_device(struct ccwgroup_device *cgdev)
 {
-	struct ctcm_priv *priv;
+	struct ctcm_priv *priv = dev_get_drvdata(&cgdev->dev);
 
-	CTCM_DBF_TEXT(SETUP, CTC_DBF_ERROR, __FUNCTION__);
+	BUG_ON(priv == NULL);
+
+	CTCM_DBF_TEXT_(SETUP, CTC_DBF_INFO,
+			"removing device %s, r/w = %s/%s, proto : %d",
+			priv->channel[READ]->netdev->name,
+			priv->channel[READ]->id, priv->channel[WRITE]->id,
+			priv->protocol);
 
-	priv = dev_get_drvdata(&cgdev->dev);
-	if (!priv)
-		return;
 	if (cgdev->state == CCWGROUP_ONLINE)
 		ctcm_shutdown_device(cgdev);
 	ctcm_remove_files(&cgdev->dev);
@@ -1748,8 +1712,6 @@ static int __init ctcm_init(void)
 
 	ret = ctcm_register_dbf_views();
 	if (ret) {
-		ctcm_pr_crit("ctcm_init failed with ctcm_register_dbf_views "
-				"rc = %d\n", ret);
 		return ret;
 	}
 	ret = register_cu3088_discipline(&ctcm_group_driver);
Index: linux-2.6-uschi/drivers/s390/net/ctcm_main.h
===================================================================
--- linux-2.6-uschi.orig/drivers/s390/net/ctcm_main.h
+++ linux-2.6-uschi/drivers/s390/net/ctcm_main.h
@@ -22,9 +22,9 @@
 
 #define CTC_DRIVER_NAME	"ctcm"
 #define CTC_DEVICE_NAME	"ctc"
-#define CTC_DEVICE_GENE	"ctc%d"
 #define MPC_DEVICE_NAME	"mpc"
-#define MPC_DEVICE_GENE	"mpc%d"
+#define CTC_DEVICE_GENE CTC_DEVICE_NAME "%d"
+#define MPC_DEVICE_GENE	MPC_DEVICE_NAME "%d"
 
 #define CHANNEL_FLAGS_READ	0
 #define CHANNEL_FLAGS_WRITE	1
@@ -48,6 +48,30 @@
 #define ctcm_pr_err(fmt, arg...) printk(KERN_ERR fmt, ##arg)
 #define ctcm_pr_crit(fmt, arg...) printk(KERN_CRIT fmt, ##arg)
 
+#define CTCM_PR_DEBUG(fmt, arg...) \
+	do { \
+		if (do_debug) \
+			printk(KERN_DEBUG fmt, ##arg); \
+	} while (0)
+
+#define	CTCM_PR_DBGDATA(fmt, arg...) \
+	do { \
+		if (do_debug_data) \
+			printk(KERN_DEBUG fmt, ##arg); \
+	} while (0)
+
+#define	CTCM_D3_DUMP(buf, len) \
+	do { \
+		if (do_debug_data) \
+			ctcmpc_dumpit(buf, len); \
+	} while (0)
+
+#define	CTCM_CCW_DUMP(buf, len) \
+	do { \
+		if (do_debug_ccw) \
+			ctcmpc_dumpit(buf, len); \
+	} while (0)
+
 /*
  * CCW commands, used in this driver.
  */
@@ -161,8 +185,9 @@ struct channel {
 	fsm_instance *fsm;	/* finite state machine of this channel */
 	struct net_device *netdev;	/* corresponding net_device */
 	struct ctcm_profile prof;
-	unsigned char *trans_skb_data;
+	__u8 *trans_skb_data;
 	__u16 logflags;
+	__u8  sense_rc; /* last unit check sense code report control */
 };
 
 struct ctcm_priv {
Index: linux-2.6-uschi/drivers/s390/net/ctcm_mpc.c
===================================================================
--- linux-2.6-uschi.orig/drivers/s390/net/ctcm_mpc.c
+++ linux-2.6-uschi/drivers/s390/net/ctcm_mpc.c
@@ -149,7 +149,7 @@ void ctcmpc_dumpit(char *buf, int len)
 	for (ct = 0; ct < len; ct++, ptr++, rptr++) {
 		if (sw == 0) {
 			#if (UTS_MACHINE == s390x)
-			sprintf(addr, "%16.16lx", (unsigned long)rptr);
+			sprintf(addr, "%16.16lx", (__u64)rptr);
 			#else
 			sprintf(addr, "%8.8X", (__u32)rptr);
 			#endif
@@ -164,7 +164,7 @@ void ctcmpc_dumpit(char *buf, int len)
 			strcat(bhex, "	");
 
 		#if (UTS_MACHINE == s390x)
-		sprintf(tbuf, "%2.2lX", (unsigned long)*ptr);
+		sprintf(tbuf, "%2.2lX", (__u64)*ptr);
 		#else
 		sprintf(tbuf, "%2.2X", (__u32)*ptr);
 		#endif
@@ -179,24 +179,24 @@ void ctcmpc_dumpit(char *buf, int len)
 		basc[sw+1] = '\0';
 		sw++;
 		rm--;
-		if (sw == 16) {
-			if ((strcmp(duphex, bhex)) != 0) {
-				if (dup != 0) {
-					sprintf(tdup, "Duplicate as above "
-						"to %s", addr);
-					printk(KERN_INFO "		  "
-						"     --- %s ---\n", tdup);
-				}
-				printk(KERN_INFO "   %s (+%s) : %s  [%s]\n",
+		if (sw != 16)
+			continue;
+		if ((strcmp(duphex, bhex)) != 0) {
+			if (dup != 0) {
+				sprintf(tdup,
+					"Duplicate as above to %s", addr);
+				ctcm_pr_debug("		       --- %s ---\n",
+						tdup);
+			}
+			ctcm_pr_debug("   %s (+%s) : %s  [%s]\n",
 					addr, boff, bhex, basc);
-				dup = 0;
-				strcpy(duphex, bhex);
-			} else
-				dup++;
+			dup = 0;
+			strcpy(duphex, bhex);
+		} else
+			dup++;
 
-			sw = 0;
-			rm = 16;
-		}
+		sw = 0;
+		rm = 16;
 	}  /* endfor */
 
 	if (sw != 0) {
@@ -210,19 +210,17 @@ void ctcmpc_dumpit(char *buf, int len)
 		}
 		if (dup != 0) {
 			sprintf(tdup, "Duplicate as above to %s", addr);
-			printk(KERN_INFO "		  "
-				"     --- %s ---\n", tdup);
+			ctcm_pr_debug("		       --- %s ---\n", tdup);
 		}
-		printk(KERN_INFO "   %s (+%s) : %s  [%s]\n",
-			addr, boff, bhex, basc);
+		ctcm_pr_debug("   %s (+%s) : %s  [%s]\n",
+					addr, boff, bhex, basc);
 	} else {
 		if (dup >= 1) {
 			sprintf(tdup, "Duplicate as above to %s", addr);
-			printk(KERN_INFO "		  "
-				"     --- %s ---\n", tdup);
+			ctcm_pr_debug("		       --- %s ---\n", tdup);
 		}
 		if (dup != 0) {
-			printk(KERN_INFO "   %s (+%s) : %s  [%s]\n",
+			ctcm_pr_debug("   %s (+%s) : %s  [%s]\n",
 				addr, boff, bhex, basc);
 		}
 	}
@@ -241,7 +239,7 @@ void ctcmpc_dumpit(char *buf, int len)
  */
 void ctcmpc_dump_skb(struct sk_buff *skb, int offset)
 {
-	unsigned char *p = skb->data;
+	__u8 *p = skb->data;
 	struct th_header *header;
 	struct pdu *pheader;
 	int bl = skb->len;
@@ -253,8 +251,8 @@ void ctcmpc_dump_skb(struct sk_buff *skb
 	p += offset;
 	header = (struct th_header *)p;
 
-	printk(KERN_INFO "dump:\n");
-	printk(KERN_INFO "skb len=%d \n", skb->len);
+	ctcm_pr_debug("dump:\n");
+	ctcm_pr_debug("skb len=%d \n", skb->len);
 	if (skb->len > 2) {
 		switch (header->th_ch_flag) {
 		case TH_HAS_PDU:
@@ -273,32 +271,64 @@ void ctcmpc_dump_skb(struct sk_buff *skb
 		}
 
 		pheader = (struct pdu *)p;
-		printk(KERN_INFO "pdu->offset: %d hex: %04x\n",
-		       pheader->pdu_offset, pheader->pdu_offset);
-		printk(KERN_INFO "pdu->flag  : %02x\n", pheader->pdu_flag);
-		printk(KERN_INFO "pdu->proto : %02x\n", pheader->pdu_proto);
-		printk(KERN_INFO "pdu->seq   : %02x\n", pheader->pdu_seq);
+		ctcm_pr_debug("pdu->offset: %d hex: %04x\n",
+			       pheader->pdu_offset, pheader->pdu_offset);
+		ctcm_pr_debug("pdu->flag  : %02x\n", pheader->pdu_flag);
+		ctcm_pr_debug("pdu->proto : %02x\n", pheader->pdu_proto);
+		ctcm_pr_debug("pdu->seq   : %02x\n", pheader->pdu_seq);
 					goto dumpdata;
 
 dumpth:
-		printk(KERN_INFO "th->seg     : %02x\n", header->th_seg);
-		printk(KERN_INFO "th->ch      : %02x\n", header->th_ch_flag);
-		printk(KERN_INFO "th->blk_flag: %02x\n", header->th_blk_flag);
-		printk(KERN_INFO "th->type    : %s\n",
-		       (header->th_is_xid) ? "DATA" : "XID");
-		printk(KERN_INFO "th->seqnum  : %04x\n", header->th_seq_num);
+		ctcm_pr_debug("th->seg     : %02x\n", header->th_seg);
+		ctcm_pr_debug("th->ch      : %02x\n", header->th_ch_flag);
+		ctcm_pr_debug("th->blk_flag: %02x\n", header->th_blk_flag);
+		ctcm_pr_debug("th->type    : %s\n",
+			       (header->th_is_xid) ? "DATA" : "XID");
+		ctcm_pr_debug("th->seqnum  : %04x\n", header->th_seq_num);
 
 	}
 dumpdata:
 	if (bl > 32)
 		bl = 32;
-	printk(KERN_INFO "data: ");
+	ctcm_pr_debug("data: ");
 	for (i = 0; i < bl; i++)
-		printk(KERN_INFO "%02x%s", *p++, (i % 16) ? " " : "\n<7>");
-	printk(KERN_INFO "\n");
+		ctcm_pr_debug("%02x%s", *p++, (i % 16) ? " " : "\n");
+	ctcm_pr_debug("\n");
 }
 #endif
 
+static struct net_device *ctcmpc_get_dev(int port_num)
+{
+	char device[20];
+	struct net_device *dev;
+	struct ctcm_priv *priv;
+
+	sprintf(device, "%s%i", MPC_DEVICE_NAME, port_num);
+
+	dev = __dev_get_by_name(&init_net, device);
+
+	if (dev == NULL) {
+		CTCM_DBF_TEXT_(MPC_ERROR, CTC_DBF_ERROR,
+			"%s: Device not found by name: %s",
+					CTCM_FUNTAIL, device);
+		return NULL;
+	}
+	priv = dev->priv;
+	if (priv == NULL) {
+		CTCM_DBF_TEXT_(MPC_ERROR, CTC_DBF_ERROR,
+			"%s(%s): dev->priv is NULL",
+					CTCM_FUNTAIL, device);
+		return NULL;
+	}
+	if (priv->mpcg == NULL) {
+		CTCM_DBF_TEXT_(MPC_ERROR, CTC_DBF_ERROR,
+			"%s(%s): priv->mpcg is NULL",
+					CTCM_FUNTAIL, device);
+		return NULL;
+	}
+	return dev;
+}
+
 /*
  * ctc_mpc_alloc_channel
  *	(exported interface)
@@ -308,34 +338,23 @@ dumpdata:
  */
 int ctc_mpc_alloc_channel(int port_num, void (*callback)(int, int))
 {
-	char device[20];
 	struct net_device *dev;
 	struct mpc_group *grp;
 	struct ctcm_priv *priv;
 
-	ctcm_pr_debug("ctcmpc enter:	%s()\n", __FUNCTION__);
-
-	sprintf(device, "%s%i", MPC_DEVICE_NAME, port_num);
-	dev = __dev_get_by_name(&init_net, device);
-
-	if (dev == NULL) {
-		printk(KERN_INFO "ctc_mpc_alloc_channel %s dev=NULL\n", device);
+	dev = ctcmpc_get_dev(port_num);
+	if (dev == NULL)
 		return 1;
-	}
-
 	priv = dev->priv;
 	grp = priv->mpcg;
-	if (!grp)
-		return 1;
 
 	grp->allochanfunc = callback;
 	grp->port_num = port_num;
 	grp->port_persist = 1;
 
-	ctcm_pr_debug("ctcmpc: %s called for device %s state=%s\n",
-		       __FUNCTION__,
-		       dev->name,
-		       fsm_getstate_str(grp->fsm));
+	CTCM_DBF_TEXT_(MPC_SETUP, CTC_DBF_INFO,
+			"%s(%s): state=%s",
+			CTCM_FUNTAIL, dev->name, fsm_getstate_str(grp->fsm));
 
 	switch (fsm_getstate(grp->fsm)) {
 	case MPCG_STATE_INOP:
@@ -377,12 +396,8 @@ int ctc_mpc_alloc_channel(int port_num, 
 			grp->allocchan_callback_retries = 0;
 		}
 		break;
-	default:
-		return 0;
-
 	}
 
-	ctcm_pr_debug("ctcmpc exit:  %s()\n", __FUNCTION__);
 	return 0;
 }
 EXPORT_SYMBOL(ctc_mpc_alloc_channel);
@@ -394,31 +409,22 @@ EXPORT_SYMBOL(ctc_mpc_alloc_channel);
 void ctc_mpc_establish_connectivity(int port_num,
 				void (*callback)(int, int, int))
 {
-	char device[20];
 	struct net_device *dev;
 	struct mpc_group *grp;
 	struct ctcm_priv *priv;
 	struct channel *rch, *wch;
 
-	ctcm_pr_debug("ctcmpc enter:	%s()\n", __FUNCTION__);
-
-	sprintf(device, "%s%i", MPC_DEVICE_NAME, port_num);
-	dev = __dev_get_by_name(&init_net, device);
-
-	if (dev == NULL) {
-		printk(KERN_INFO "ctc_mpc_establish_connectivity "
-				"%s dev=NULL\n", device);
+	dev = ctcmpc_get_dev(port_num);
+	if (dev == NULL)
 		return;
-	}
 	priv = dev->priv;
+	grp = priv->mpcg;
 	rch = priv->channel[READ];
 	wch = priv->channel[WRITE];
 
-	grp = priv->mpcg;
-
-	ctcm_pr_debug("ctcmpc: %s() called for device %s state=%s\n",
-			__FUNCTION__, dev->name,
-			fsm_getstate_str(grp->fsm));
+	CTCM_DBF_TEXT_(MPC_SETUP, CTC_DBF_INFO,
+			"%s(%s): state=%s",
+			CTCM_FUNTAIL, dev->name, fsm_getstate_str(grp->fsm));
 
 	grp->estconnfunc = callback;
 	grp->port_num = port_num;
@@ -446,8 +452,10 @@ void ctc_mpc_establish_connectivity(int 
 	case MPCG_STATE_RESET:
 		/* MPC Group is not ready to start XID - min num of */
 		/* 1 read and 1 write channel have not been acquired*/
-		printk(KERN_WARNING "ctcmpc: %s() REJECTED ACTIVE XID Req"
-			"uest - Channel Pair is not Active\n", __FUNCTION__);
+
+		CTCM_DBF_TEXT_(MPC_ERROR, CTC_DBF_ERROR,
+			"%s(%s): REJECTED - inactive channels",
+					CTCM_FUNTAIL, dev->name);
 		if (grp->estconnfunc) {
 			grp->estconnfunc(grp->port_num, -1, 0);
 			grp->estconnfunc = NULL;
@@ -457,11 +465,12 @@ void ctc_mpc_establish_connectivity(int 
 		/* alloc channel was called but no XID exchange    */
 		/* has occurred. initiate xside XID exchange	   */
 		/* make sure yside XID0 processing has not started */
+
 		if ((fsm_getstate(rch->fsm) > CH_XID0_PENDING) ||
 			(fsm_getstate(wch->fsm) > CH_XID0_PENDING)) {
-			printk(KERN_WARNING "mpc: %s() ABORT ACTIVE XID"
-			       " Request- PASSIVE XID in process\n"
-			       , __FUNCTION__);
+			CTCM_DBF_TEXT_(MPC_ERROR, CTC_DBF_ERROR,
+				"%s(%s): ABORT - PASSIVE XID",
+					CTCM_FUNTAIL, dev->name);
 			break;
 		}
 		grp->send_qllc_disc = 1;
@@ -476,9 +485,9 @@ void ctc_mpc_establish_connectivity(int 
 				(fsm_getstate(rch->fsm) == CH_XID0_PENDING))
 			fsm_event(grp->fsm, MPCG_EVENT_XID0DO, rch);
 		else {
-			printk(KERN_WARNING "mpc: %s() Unable to start"
-			       " ACTIVE XID0 on read channel\n",
-			       __FUNCTION__);
+			CTCM_DBF_TEXT_(MPC_ERROR, CTC_DBF_ERROR,
+				"%s(%s): RX-%s not ready for ACTIVE XID0",
+					CTCM_FUNTAIL, dev->name, rch->id);
 			if (grp->estconnfunc) {
 				grp->estconnfunc(grp->port_num, -1, 0);
 				grp->estconnfunc = NULL;
@@ -490,9 +499,9 @@ void ctc_mpc_establish_connectivity(int 
 				(fsm_getstate(wch->fsm) == CH_XID0_PENDING))
 			fsm_event(grp->fsm, MPCG_EVENT_XID0DO, wch);
 		else {
-			printk(KERN_WARNING "mpc: %s() Unable to start"
-				" ACTIVE XID0 on write channel\n",
-					__FUNCTION__);
+			CTCM_DBF_TEXT_(MPC_ERROR, CTC_DBF_ERROR,
+				"%s(%s): WX-%s not ready for ACTIVE XID0",
+					CTCM_FUNTAIL, dev->name, wch->id);
 			if (grp->estconnfunc) {
 				grp->estconnfunc(grp->port_num, -1, 0);
 				grp->estconnfunc = NULL;
@@ -508,7 +517,7 @@ void ctc_mpc_establish_connectivity(int 
 	}
 
 done:
-	ctcm_pr_debug("ctcmpc exit:  %s()\n", __FUNCTION__);
+	CTCM_PR_DEBUG("Exit %s()\n", __func__);
 	return;
 }
 EXPORT_SYMBOL(ctc_mpc_establish_connectivity);
@@ -520,40 +529,22 @@ EXPORT_SYMBOL(ctc_mpc_establish_connecti
 void ctc_mpc_dealloc_ch(int port_num)
 {
 	struct net_device *dev;
-	char device[20];
 	struct ctcm_priv *priv;
 	struct mpc_group *grp;
 
-	ctcm_pr_debug("ctcmpc enter:	%s()\n", __FUNCTION__);
-	sprintf(device, "%s%i", MPC_DEVICE_NAME, port_num);
-	dev = __dev_get_by_name(&init_net, device);
-
-	if (dev == NULL) {
-		printk(KERN_INFO "%s() %s dev=NULL\n", __FUNCTION__, device);
-					goto done;
-	}
+	dev = ctcmpc_get_dev(port_num);
+	if (dev == NULL)
+		return;
+	priv = dev->priv;
+	grp = priv->mpcg;
 
-	ctcm_pr_debug("ctcmpc:%s %s() called for device %s refcount=%d\n",
-			dev->name, __FUNCTION__,
-			dev->name, atomic_read(&dev->refcnt));
+	CTCM_DBF_TEXT_(MPC_SETUP, CTC_DBF_DEBUG,
+			"%s: %s: refcount = %d\n",
+			CTCM_FUNTAIL, dev->name, atomic_read(&dev->refcnt));
 
-	priv = dev->priv;
-	if (priv == NULL) {
-		printk(KERN_INFO "%s() %s priv=NULL\n",
-				__FUNCTION__, device);
-					goto done;
-	}
 	fsm_deltimer(&priv->restart_timer);
-
-	grp = priv->mpcg;
-	if (grp == NULL) {
-		printk(KERN_INFO "%s() %s dev=NULL\n", __FUNCTION__, device);
-					goto done;
-	}
 	grp->channels_terminating = 0;
-
 	fsm_deltimer(&grp->timer);
-
 	grp->allochanfunc = NULL;
 	grp->estconnfunc = NULL;
 	grp->port_persist = 0;
@@ -561,8 +552,6 @@ void ctc_mpc_dealloc_ch(int port_num)
 	fsm_event(grp->fsm, MPCG_EVENT_INOP, dev);
 
 	ctcm_close(dev);
-done:
-	ctcm_pr_debug("ctcmpc exit:  %s()\n", __FUNCTION__);
 	return;
 }
 EXPORT_SYMBOL(ctc_mpc_dealloc_ch);
@@ -573,32 +562,22 @@ EXPORT_SYMBOL(ctc_mpc_dealloc_ch);
  */
 void ctc_mpc_flow_control(int port_num, int flowc)
 {
-	char device[20];
 	struct ctcm_priv *priv;
 	struct mpc_group *grp;
 	struct net_device *dev;
 	struct channel *rch;
 	int mpcg_state;
 
-	ctcm_pr_debug("ctcmpc enter:	%s() %i\n", __FUNCTION__, flowc);
-
-	sprintf(device, "%s%i", MPC_DEVICE_NAME, port_num);
-	dev = __dev_get_by_name(&init_net, device);
-
-	if (dev == NULL) {
-		printk(KERN_INFO "ctc_mpc_flow_control %s dev=NULL\n", device);
+	dev = ctcmpc_get_dev(port_num);
+	if (dev == NULL)
 		return;
-	}
+	priv = dev->priv;
+	grp = priv->mpcg;
 
-	ctcm_pr_debug("ctcmpc: %s %s called \n", dev->name, __FUNCTION__);
+	CTCM_DBF_TEXT_(MPC_TRACE, CTC_DBF_DEBUG,
+			"%s: %s: flowc = %d",
+				CTCM_FUNTAIL, dev->name, flowc);
 
-	priv  = dev->priv;
-	if (priv == NULL) {
-		printk(KERN_INFO "ctcmpc:%s() %s priv=NULL\n",
-		       __FUNCTION__, device);
-		return;
-	}
-	grp = priv->mpcg;
 	rch = priv->channel[READ];
 
 	mpcg_state = fsm_getstate(grp->fsm);
@@ -629,7 +608,6 @@ void ctc_mpc_flow_control(int port_num, 
 		break;
 	}
 
-	ctcm_pr_debug("ctcmpc exit:  %s() %i\n", __FUNCTION__, flowc);
 }
 EXPORT_SYMBOL(ctc_mpc_flow_control);
 
@@ -646,12 +624,8 @@ static void mpc_rcvd_sweep_resp(struct m
 	struct mpc_group  *grp = priv->mpcg;
 	struct channel	  *ch = priv->channel[WRITE];
 
-	if (do_debug)
-		ctcm_pr_debug("ctcmpc enter: %s(): ch=0x%p id=%s\n",
-			__FUNCTION__, ch, ch->id);
-
-	if (do_debug_data)
-		ctcmpc_dumpit((char *)mpcginfo->sweep, TH_SWEEP_LENGTH);
+	CTCM_PR_DEBUG("%s: ch=0x%p id=%s\n", __func__, ch, ch->id);
+	CTCM_D3_DUMP((char *)mpcginfo->sweep, TH_SWEEP_LENGTH);
 
 	grp->sweep_rsp_pend_num--;
 
@@ -684,14 +658,13 @@ static void ctcmpc_send_sweep_resp(struc
 	struct sk_buff *sweep_skb;
 	struct channel *ch  = priv->channel[WRITE];
 
-	if (do_debug)
-		ctcm_pr_debug("ctcmpc exit : %s(): ch=0x%p id=%s\n",
-			__FUNCTION__, rch, rch->id);
+	CTCM_PR_DEBUG("%s: ch=0x%p id=%s\n", __func__, rch, rch->id);
 
-	sweep_skb = __dev_alloc_skb(MPC_BUFSIZE_DEFAULT,
-				    GFP_ATOMIC|GFP_DMA);
+	sweep_skb = __dev_alloc_skb(MPC_BUFSIZE_DEFAULT, GFP_ATOMIC | GFP_DMA);
 	if (sweep_skb == NULL) {
-		printk(KERN_INFO "Couldn't alloc sweep_skb\n");
+		CTCM_DBF_TEXT_(MPC_ERROR, CTC_DBF_ERROR,
+			"%s(%s): sweep_skb allocation ERROR\n",
+			CTCM_FUNTAIL, rch->id);
 		rc = -ENOMEM;
 				goto done;
 	}
@@ -746,7 +719,7 @@ static void mpc_rcvd_sweep_req(struct mp
 
 	if (do_debug)
 		CTCM_DBF_TEXT_(MPC_TRACE, CTC_DBF_DEBUG,
-			" %s(): ch=0x%p id=%s\n", __FUNCTION__, ch, ch->id);
+			" %s(): ch=0x%p id=%s\n", __func__, ch, ch->id);
 
 	if (grp->in_sweep == 0) {
 		grp->in_sweep = 1;
@@ -755,8 +728,7 @@ static void mpc_rcvd_sweep_req(struct mp
 		grp->sweep_rsp_pend_num = grp->active_channels[READ];
 	}
 
-	if (do_debug_data)
-		ctcmpc_dumpit((char *)mpcginfo->sweep, TH_SWEEP_LENGTH);
+	CTCM_D3_DUMP((char *)mpcginfo->sweep, TH_SWEEP_LENGTH);
 
 	grp->sweep_req_pend_num--;
 	ctcmpc_send_sweep_resp(ch);
@@ -875,25 +847,13 @@ static int mpcg_fsm_len = ARRAY_SIZE(mpc
 static void mpc_action_go_ready(fsm_instance *fsm, int event, void *arg)
 {
 	struct net_device *dev = arg;
-	struct ctcm_priv *priv = NULL;
-	struct mpc_group *grp = NULL;
-
-	if (dev == NULL) {
-		printk(KERN_INFO "%s() dev=NULL\n", __FUNCTION__);
-		return;
-	}
-
-	ctcm_pr_debug("ctcmpc enter: %s  %s()\n", dev->name, __FUNCTION__);
-
-	priv = dev->priv;
-	if (priv == NULL) {
-		printk(KERN_INFO "%s() priv=NULL\n", __FUNCTION__);
-		return;
-	}
+	struct ctcm_priv *priv = dev->priv;
+	struct mpc_group *grp = priv->mpcg;
 
-	grp = priv->mpcg;
 	if (grp == NULL) {
-		printk(KERN_INFO "%s() grp=NULL\n", __FUNCTION__);
+		CTCM_DBF_TEXT_(MPC_ERROR, CTC_DBF_ERROR,
+			"%s(%s): No MPC group",
+				CTCM_FUNTAIL, dev->name);
 		return;
 	}
 
@@ -907,7 +867,12 @@ static void mpc_action_go_ready(fsm_inst
 			grp->estconnfunc = NULL;
 		} else if (grp->allochanfunc)
 			grp->send_qllc_disc = 1;
-					goto done;
+
+		fsm_event(grp->fsm, MPCG_EVENT_INOP, dev);
+		CTCM_DBF_TEXT_(MPC_ERROR, CTC_DBF_ERROR,
+				"%s(%s): fails",
+					CTCM_FUNTAIL, dev->name);
+		return;
 	}
 
 	grp->port_persist = 1;
@@ -916,14 +881,7 @@ static void mpc_action_go_ready(fsm_inst
 
 	tasklet_hi_schedule(&grp->mpc_tasklet2);
 
-	ctcm_pr_debug("ctcmpc exit: %s  %s()\n", dev->name, __FUNCTION__);
 	return;
-
-done:
-	fsm_event(grp->fsm, MPCG_EVENT_INOP, dev);
-
-
-	ctcm_pr_info("ctcmpc: %s()failure occurred\n", __FUNCTION__);
 }
 
 /*
@@ -933,42 +891,28 @@ done:
 void mpc_group_ready(unsigned long adev)
 {
 	struct net_device *dev = (struct net_device *)adev;
-	struct ctcm_priv *priv = NULL;
-	struct mpc_group  *grp = NULL;
+	struct ctcm_priv *priv = dev->priv;
+	struct mpc_group *grp = priv->mpcg;
 	struct channel *ch = NULL;
 
-
-	ctcm_pr_debug("ctcmpc enter:	%s()\n", __FUNCTION__);
-
-	if (dev == NULL) {
-		printk(KERN_INFO "%s() dev=NULL\n", __FUNCTION__);
-		return;
-	}
-
-	priv = dev->priv;
-	if (priv == NULL) {
-		printk(KERN_INFO "%s() priv=NULL\n", __FUNCTION__);
-		return;
-	}
-
-	grp = priv->mpcg;
 	if (grp == NULL) {
-		printk(KERN_INFO "ctcmpc:%s() grp=NULL\n", __FUNCTION__);
+		CTCM_DBF_TEXT_(MPC_ERROR, CTC_DBF_ERROR,
+			"%s(%s): No MPC group",
+				CTCM_FUNTAIL, dev->name);
 		return;
 	}
 
-	printk(KERN_NOTICE "ctcmpc: %s GROUP TRANSITIONED TO READY"
-	       "  maxbuf:%d\n",
-	       dev->name, grp->group_max_buflen);
+	CTCM_DBF_TEXT_(MPC_SETUP, CTC_DBF_NOTICE,
+		"%s: %s: GROUP TRANSITIONED TO READY, maxbuf = %d\n",
+			CTCM_FUNTAIL, dev->name, grp->group_max_buflen);
 
 	fsm_newstate(grp->fsm, MPCG_STATE_READY);
 
 	/* Put up a read on the channel */
 	ch = priv->channel[READ];
 	ch->pdu_seq = 0;
-	if (do_debug_data)
-		ctcm_pr_debug("ctcmpc: %s() ToDCM_pdu_seq= %08x\n" ,
-			__FUNCTION__, ch->pdu_seq);
+	CTCM_PR_DBGDATA("ctcmpc: %s() ToDCM_pdu_seq= %08x\n" ,
+			__func__, ch->pdu_seq);
 
 	ctcmpc_chx_rxidle(ch->fsm, CTC_EVENT_START, ch);
 	/* Put the write channel in idle state */
@@ -980,22 +924,18 @@ void mpc_group_ready(unsigned long adev)
 		spin_unlock(&ch->collect_lock);
 	}
 	ctcm_chx_txidle(ch->fsm, CTC_EVENT_START, ch);
-
 	ctcm_clear_busy(dev);
 
 	if (grp->estconnfunc) {
 		grp->estconnfunc(grp->port_num, 0,
 				    grp->group_max_buflen);
 		grp->estconnfunc = NULL;
-	} else
-		if (grp->allochanfunc)
-		grp->allochanfunc(grp->port_num,
-				     grp->group_max_buflen);
+	} else 	if (grp->allochanfunc)
+		grp->allochanfunc(grp->port_num, grp->group_max_buflen);
 
 	grp->send_qllc_disc = 1;
 	grp->changed_side = 0;
 
-	ctcm_pr_debug("ctcmpc exit:  %s()\n", __FUNCTION__);
 	return;
 
 }
@@ -1004,51 +944,26 @@ void mpc_group_ready(unsigned long adev)
  * Increment the MPC Group Active Channel Counts
  * helper of dev_action (called from channel fsm)
  */
-int mpc_channel_action(struct channel *ch, int direction, int action)
+void mpc_channel_action(struct channel *ch, int direction, int action)
 {
-	struct net_device  *dev     = ch->netdev;
-	struct ctcm_priv    *priv;
-	struct mpc_group   *grp  = NULL;
-	int	    rc = 0;
-
-	if (do_debug)
-		ctcm_pr_debug("ctcmpc enter: %s(): ch=0x%p id=%s\n",
-			__FUNCTION__, ch, ch->id);
-
-	if (dev == NULL) {
-		printk(KERN_INFO "ctcmpc_channel_action %i dev=NULL\n",
-		       action);
-		rc = 1;
-					goto done;
-	}
-
-	priv = dev->priv;
-	if (priv == NULL) {
-		printk(KERN_INFO
-		       "ctcmpc_channel_action%i priv=NULL, dev=%s\n",
-		       action, dev->name);
-		rc = 2;
-					goto done;
-	}
-
-	grp = priv->mpcg;
+	struct net_device  *dev  = ch->netdev;
+	struct ctcm_priv   *priv = dev->priv;
+	struct mpc_group   *grp  = priv->mpcg;
 
 	if (grp == NULL) {
-		printk(KERN_INFO "ctcmpc: %s()%i mpcgroup=NULL, dev=%s\n",
-		       __FUNCTION__, action, dev->name);
-		rc = 3;
-					goto done;
+		CTCM_DBF_TEXT_(MPC_ERROR, CTC_DBF_ERROR,
+			"%s(%s): No MPC group",
+				CTCM_FUNTAIL, dev->name);
+		return;
 	}
 
-	ctcm_pr_info(
-		      "ctcmpc: %s() %i(): Grp:%s total_channel_paths=%i "
-		      "active_channels read=%i, write=%i\n",
-		      __FUNCTION__,
-		      action,
-		      fsm_getstate_str(grp->fsm),
-		      grp->num_channel_paths,
-		      grp->active_channels[READ],
-		      grp->active_channels[WRITE]);
+	CTCM_PR_DEBUG("enter %s: ch=0x%p id=%s\n", __func__, ch, ch->id);
+
+	CTCM_DBF_TEXT_(MPC_TRACE, CTC_DBF_NOTICE,
+		"%s: %i / Grp:%s total_channels=%i, active_channels: "
+		"read=%i, write=%i\n", __func__, action,
+		fsm_getstate_str(grp->fsm), grp->num_channel_paths,
+		grp->active_channels[READ], grp->active_channels[WRITE]);
 
 	if ((action == MPC_CHANNEL_ADD) && (ch->in_mpcgroup == 0)) {
 		grp->num_channel_paths++;
@@ -1062,10 +977,11 @@ int mpc_channel_action(struct channel *c
 		ch->xid_skb = __dev_alloc_skb(MPC_BUFSIZE_DEFAULT,
 					GFP_ATOMIC | GFP_DMA);
 		if (ch->xid_skb == NULL) {
-			printk(KERN_INFO "ctcmpc: %s()"
-			       "Couldn't alloc ch xid_skb\n", __FUNCTION__);
+			CTCM_DBF_TEXT_(MPC_ERROR, CTC_DBF_ERROR,
+				"%s(%s): Couldn't alloc ch xid_skb\n",
+				CTCM_FUNTAIL, dev->name);
 			fsm_event(grp->fsm, MPCG_EVENT_INOP, dev);
-			return 1;
+			return;
 		}
 		ch->xid_skb_data = ch->xid_skb->data;
 		ch->xid_th = (struct th_header *)ch->xid_skb->data;
@@ -1097,8 +1013,9 @@ int mpc_channel_action(struct channel *c
 		    (grp->active_channels[WRITE] > 0) &&
 			(fsm_getstate(grp->fsm) < MPCG_STATE_XID2INITW)) {
 			fsm_newstate(grp->fsm, MPCG_STATE_XID2INITW);
-			printk(KERN_NOTICE "ctcmpc: %s MPC GROUP "
-					"CHANNELS ACTIVE\n", dev->name);
+			CTCM_DBF_TEXT_(MPC_SETUP, CTC_DBF_NOTICE,
+				"%s: %s: MPC GROUP CHANNELS ACTIVE\n",
+						__func__, dev->name);
 		}
 	} else if ((action == MPC_CHANNEL_REMOVE) &&
 			(ch->in_mpcgroup == 1)) {
@@ -1119,25 +1036,14 @@ int mpc_channel_action(struct channel *c
 					(grp->active_channels[READ] > 0)))
 			fsm_event(grp->fsm, MPCG_EVENT_INOP, dev);
 	}
-
 done:
+	CTCM_DBF_TEXT_(MPC_TRACE, CTC_DBF_DEBUG,
+		"exit %s: %i / Grp:%s total_channels=%i, active_channels: "
+		"read=%i, write=%i\n", __func__, action,
+		fsm_getstate_str(grp->fsm), grp->num_channel_paths,
+		grp->active_channels[READ], grp->active_channels[WRITE]);
 
-	if (do_debug) {
-		ctcm_pr_debug(
-		       "ctcmpc: %s() %i Grp:%s ttl_chan_paths=%i "
-		       "active_chans read=%i, write=%i\n",
-		       __FUNCTION__,
-		       action,
-		       fsm_getstate_str(grp->fsm),
-		       grp->num_channel_paths,
-		       grp->active_channels[READ],
-		       grp->active_channels[WRITE]);
-
-		ctcm_pr_debug("ctcmpc exit : %s(): ch=0x%p id=%s\n",
-				__FUNCTION__, ch, ch->id);
-	}
-	return rc;
-
+	CTCM_PR_DEBUG("exit %s: ch=0x%p id=%s\n", __func__, ch, ch->id);
 }
 
 /**
@@ -1163,9 +1069,8 @@ static void ctcmpc_unpack_skb(struct cha
 	int skblen;
 	int sendrc = 0;
 
-	if (do_debug)
-		ctcm_pr_debug("ctcmpc enter: %s() %s cp:%i ch:%s\n",
-		       __FUNCTION__, dev->name, smp_processor_id(), ch->id);
+	CTCM_PR_DEBUG("ctcmpc enter: %s() %s cp:%i ch:%s\n",
+			__func__, dev->name, smp_processor_id(), ch->id);
 
 	header = (struct th_header *)pskb->data;
 	if ((header->th_seg == 0) &&
@@ -1174,21 +1079,16 @@ static void ctcmpc_unpack_skb(struct cha
 		(header->th_seq_num == 0))
 		/* nothing for us */	goto done;
 
-	if (do_debug_data) {
-		ctcm_pr_debug("ctcmpc: %s() th_header\n", __FUNCTION__);
-		ctcmpc_dumpit((char *)header, TH_HEADER_LENGTH);
-		ctcm_pr_debug("ctcmpc: %s() pskb len: %04x \n",
-		       __FUNCTION__, pskb->len);
-	}
+	CTCM_PR_DBGDATA("%s: th_header\n", __func__);
+	CTCM_D3_DUMP((char *)header, TH_HEADER_LENGTH);
+	CTCM_PR_DBGDATA("%s: pskb len: %04x \n", __func__, pskb->len);
 
 	pskb->dev = dev;
 	pskb->ip_summed = CHECKSUM_UNNECESSARY;
 	skb_pull(pskb, TH_HEADER_LENGTH);
 
 	if (likely(header->th_ch_flag == TH_HAS_PDU)) {
-		if (do_debug_data)
-			ctcm_pr_debug("ctcmpc: %s() came into th_has_pdu\n",
-			       __FUNCTION__);
+		CTCM_PR_DBGDATA("%s: came into th_has_pdu\n", __func__);
 		if ((fsm_getstate(grp->fsm) == MPCG_STATE_FLOWC) ||
 		   ((fsm_getstate(grp->fsm) == MPCG_STATE_READY) &&
 		    (header->th_seq_num != ch->th_seq_num + 1) &&
@@ -1202,33 +1102,29 @@ static void ctcmpc_unpack_skb(struct cha
 			grp->out_of_sequence += 1;
 			__skb_push(pskb, TH_HEADER_LENGTH);
 			skb_queue_tail(&ch->io_queue, pskb);
-			if (do_debug_data)
-				ctcm_pr_debug("ctcmpc: %s() th_seq_num "
-				       "expect:%08x got:%08x\n", __FUNCTION__,
-				       ch->th_seq_num + 1, header->th_seq_num);
+			CTCM_PR_DBGDATA("%s: th_seq_num expect:%08x "
+					"got:%08x\n", __func__,
+				ch->th_seq_num + 1, header->th_seq_num);
 
 			return;
 		}
 		grp->out_of_sequence = 0;
 		ch->th_seq_num = header->th_seq_num;
 
-		if (do_debug_data)
-			ctcm_pr_debug("ctcmpc: %s() FromVTAM_th_seq=%08x\n",
-			       __FUNCTION__, ch->th_seq_num);
+		CTCM_PR_DBGDATA("ctcmpc: %s() FromVTAM_th_seq=%08x\n",
+					__func__, ch->th_seq_num);
 
 		if (unlikely(fsm_getstate(grp->fsm) != MPCG_STATE_READY))
 					goto done;
 		pdu_last_seen = 0;
 		while ((pskb->len > 0) && !pdu_last_seen) {
 			curr_pdu = (struct pdu *)pskb->data;
-			if (do_debug_data) {
-				ctcm_pr_debug("ctcm: %s() pdu_header\n",
-				       __FUNCTION__);
-				ctcmpc_dumpit((char *)pskb->data,
-						PDU_HEADER_LENGTH);
-				ctcm_pr_debug("ctcm: %s() pskb len: %04x \n",
-				       __FUNCTION__, pskb->len);
-			}
+
+			CTCM_PR_DBGDATA("%s: pdu_header\n", __func__);
+			CTCM_D3_DUMP((char *)pskb->data, PDU_HEADER_LENGTH);
+			CTCM_PR_DBGDATA("%s: pskb len: %04x \n",
+						__func__, pskb->len);
+
 			skb_pull(pskb, PDU_HEADER_LENGTH);
 
 			if (curr_pdu->pdu_flag & PDU_LAST)
@@ -1239,46 +1135,39 @@ static void ctcmpc_unpack_skb(struct cha
 				pskb->protocol = htons(ETH_P_SNA_DIX);
 
 			if ((pskb->len <= 0) || (pskb->len > ch->max_bufsize)) {
-				printk(KERN_INFO
-				       "%s Illegal packet size %d "
-				       "received "
-				       "dropping\n", dev->name,
-				       pskb->len);
+				CTCM_DBF_TEXT_(MPC_ERROR, CTC_DBF_ERROR,
+					"%s(%s): Dropping packet with "
+					"illegal siize %d",
+					CTCM_FUNTAIL, dev->name, pskb->len);
+
 				priv->stats.rx_dropped++;
 				priv->stats.rx_length_errors++;
 					goto done;
 			}
 			skb_reset_mac_header(pskb);
 			new_len = curr_pdu->pdu_offset;
-			if (do_debug_data)
-				ctcm_pr_debug("ctcmpc: %s() new_len: %04x \n",
-				       __FUNCTION__, new_len);
+			CTCM_PR_DBGDATA("%s: new_len: %04x \n",
+						__func__, new_len);
 			if ((new_len == 0) || (new_len > pskb->len)) {
 				/* should never happen		    */
 				/* pskb len must be hosed...bail out */
-				printk(KERN_INFO
-				       "ctcmpc: %s(): invalid pdu"
-				       " offset of %04x - data may be"
-				       "lost\n", __FUNCTION__, new_len);
-						goto done;
+				CTCM_DBF_TEXT_(MPC_ERROR, CTC_DBF_ERROR,
+					"%s(%s): non valid pdu_offset: %04x",
+					/* "data may be lost", */
+					CTCM_FUNTAIL, dev->name, new_len);
+				goto done;
 			}
 			skb = __dev_alloc_skb(new_len+4, GFP_ATOMIC);
 
 			if (!skb) {
-				printk(KERN_INFO
-				       "ctcm: %s Out of memory in "
-				       "%s()- request-len:%04x \n",
-				       dev->name,
-				       __FUNCTION__,
-				       new_len+4);
+				CTCM_DBF_TEXT_(MPC_ERROR, CTC_DBF_ERROR,
+					"%s(%s): MEMORY allocation error",
+						CTCM_FUNTAIL, dev->name);
 				priv->stats.rx_dropped++;
-				fsm_event(grp->fsm,
-					  MPCG_EVENT_INOP, dev);
+				fsm_event(grp->fsm, MPCG_EVENT_INOP, dev);
 						goto done;
 			}
-
-			memcpy(skb_put(skb, new_len),
-					pskb->data, new_len);
+			memcpy(skb_put(skb, new_len), pskb->data, new_len);
 
 			skb_reset_mac_header(skb);
 			skb->dev = pskb->dev;
@@ -1287,17 +1176,14 @@ static void ctcmpc_unpack_skb(struct cha
 			*((__u32 *) skb_push(skb, 4)) = ch->pdu_seq;
 			ch->pdu_seq++;
 
-			if (do_debug_data)
-				ctcm_pr_debug("%s: ToDCM_pdu_seq= %08x\n",
-				       __FUNCTION__, ch->pdu_seq);
-
-			ctcm_pr_debug("ctcm: %s() skb:%0lx "
-				"skb len: %d \n", __FUNCTION__,
-			       (unsigned long)skb, skb->len);
 			if (do_debug_data) {
-				ctcm_pr_debug("ctcmpc: %s() up to 32 bytes"
-					       " of pdu_data sent\n",
-					       __FUNCTION__);
+				ctcm_pr_debug("%s: ToDCM_pdu_seq= %08x\n",
+						__func__, ch->pdu_seq);
+				ctcm_pr_debug("%s: skb:%0lx "
+					"skb len: %d \n", __func__,
+					(unsigned long)skb, skb->len);
+				ctcm_pr_debug("%s: up to 32 bytes "
+					"of pdu_data sent\n", __func__);
 				ctcmpc_dump32((char *)skb->data, skb->len);
 			}
 
@@ -1316,8 +1202,8 @@ static void ctcmpc_unpack_skb(struct cha
 		mpcginfo->ch = ch;
 		mpcginfo->th = header;
 		mpcginfo->skb = pskb;
-		ctcm_pr_debug("ctcmpc: %s() Not PDU - may be control pkt\n",
-			       __FUNCTION__);
+		CTCM_PR_DEBUG("%s: Not PDU - may be control pkt\n",
+					__func__);
 		/*  it's a sweep?   */
 		sweep = (struct th_sweep *)pskb->data;
 		mpcginfo->sweep = sweep;
@@ -1333,8 +1219,9 @@ static void ctcmpc_unpack_skb(struct cha
 		} else if (header->th_blk_flag == TH_DISCONTACT)
 			fsm_event(grp->fsm, MPCG_EVENT_DISCONC, mpcginfo);
 		else if (header->th_seq_num != 0) {
-			printk(KERN_INFO "%s unexpected packet"
-					" expected control pkt\n", dev->name);
+			CTCM_DBF_TEXT_(MPC_ERROR, CTC_DBF_ERROR,
+				"%s(%s): control pkt expected\n",
+						CTCM_FUNTAIL, dev->name);
 			priv->stats.rx_dropped++;
 			/* mpcginfo only used for non-data transfers */
 			kfree(mpcginfo);
@@ -1347,13 +1234,12 @@ done:
 	dev_kfree_skb_any(pskb);
 	if (sendrc == NET_RX_DROP) {
 		printk(KERN_WARNING "%s %s() NETWORK BACKLOG EXCEEDED"
-		       " - PACKET DROPPED\n", dev->name, __FUNCTION__);
+		       " - PACKET DROPPED\n", dev->name, __func__);
 		fsm_event(grp->fsm, MPCG_EVENT_INOP, dev);
 	}
 
-	if (do_debug)
-		ctcm_pr_debug("ctcmpc exit : %s %s(): ch=0x%p id=%s\n",
-				dev->name, __FUNCTION__, ch, ch->id);
+	CTCM_PR_DEBUG("exit %s: %s: ch=0x%p id=%s\n",
+			__func__, dev->name, ch, ch->id);
 }
 
 /**
@@ -1366,15 +1252,14 @@ done:
  */
 void ctcmpc_bh(unsigned long thischan)
 {
-	struct channel	  *ch	    = (struct channel *)thischan;
+	struct channel	  *ch	= (struct channel *)thischan;
 	struct sk_buff	  *skb;
-	struct net_device *dev	    = ch->netdev;
-	struct ctcm_priv  *priv  = dev->priv;
-	struct mpc_group  *grp   = priv->mpcg;
+	struct net_device *dev	= ch->netdev;
+	struct ctcm_priv  *priv	= dev->priv;
+	struct mpc_group  *grp	= priv->mpcg;
 
-	if (do_debug)
-		ctcm_pr_debug("%s cp:%i enter:  %s() %s\n",
-		       dev->name, smp_processor_id(), __FUNCTION__, ch->id);
+	CTCM_PR_DEBUG("%s cp:%i enter:  %s() %s\n",
+	       dev->name, smp_processor_id(), __func__, ch->id);
 	/* caller has requested driver to throttle back */
 	while ((fsm_getstate(grp->fsm) != MPCG_STATE_FLOWC) &&
 			(skb = skb_dequeue(&ch->io_queue))) {
@@ -1390,9 +1275,8 @@ void ctcmpc_bh(unsigned long thischan)
 		if (skb == skb_peek(&ch->io_queue))
 			break;
 	}
-	if (do_debug)
-		ctcm_pr_debug("ctcmpc exit : %s %s(): ch=0x%p id=%s\n",
-			dev->name, __FUNCTION__, ch,  ch->id);
+	CTCM_PR_DEBUG("exit %s: %s: ch=0x%p id=%s\n",
+			__func__, dev->name, ch, ch->id);
 	return;
 }
 
@@ -1403,16 +1287,16 @@ struct mpc_group *ctcmpc_init_mpc_group(
 {
 	struct mpc_group *grp;
 
-	CTCM_DBF_TEXT(MPC_SETUP, 3, __FUNCTION__);
+	CTCM_DBF_TEXT_(MPC_SETUP, CTC_DBF_INFO,
+			"Enter %s(%p)", CTCM_FUNTAIL, priv);
 
 	grp = kzalloc(sizeof(struct mpc_group), GFP_KERNEL);
 	if (grp == NULL)
 		return NULL;
 
-	grp->fsm =
-		init_fsm("mpcg", mpcg_state_names, mpcg_event_names,
-				 MPCG_NR_STATES, MPCG_NR_EVENTS, mpcg_fsm,
-				 mpcg_fsm_len, GFP_KERNEL);
+	grp->fsm = init_fsm("mpcg", mpcg_state_names, mpcg_event_names,
+			MPCG_NR_STATES, MPCG_NR_EVENTS, mpcg_fsm,
+			mpcg_fsm_len, GFP_KERNEL);
 	if (grp->fsm == NULL) {
 		kfree(grp);
 		return NULL;
@@ -1424,7 +1308,6 @@ struct mpc_group *ctcmpc_init_mpc_group(
 	grp->xid_skb =
 		 __dev_alloc_skb(MPC_BUFSIZE_DEFAULT, GFP_ATOMIC | GFP_DMA);
 	if (grp->xid_skb == NULL) {
-		printk(KERN_INFO "Couldn't alloc MPCgroup xid_skb\n");
 		kfree_fsm(grp->fsm);
 		kfree(grp);
 		return NULL;
@@ -1435,7 +1318,7 @@ struct mpc_group *ctcmpc_init_mpc_group(
 	memcpy(skb_put(grp->xid_skb, TH_HEADER_LENGTH),
 			&thnorm, TH_HEADER_LENGTH);
 
-	grp->xid = (struct xid2 *) skb_tail_pointer(grp->xid_skb);
+	grp->xid = (struct xid2 *)skb_tail_pointer(grp->xid_skb);
 	memcpy(skb_put(grp->xid_skb, XID2_LENGTH), &init_xid, XID2_LENGTH);
 	grp->xid->xid2_adj_id = jiffies | 0xfff00000;
 	grp->xid->xid2_sender_id = jiffies;
@@ -1446,7 +1329,6 @@ struct mpc_group *ctcmpc_init_mpc_group(
 	grp->rcvd_xid_skb =
 		__dev_alloc_skb(MPC_BUFSIZE_DEFAULT, GFP_ATOMIC|GFP_DMA);
 	if (grp->rcvd_xid_skb == NULL) {
-		printk(KERN_INFO "Couldn't alloc MPCgroup rcvd_xid_skb\n");
 		kfree_fsm(grp->fsm);
 		dev_kfree_skb(grp->xid_skb);
 		kfree(grp);
@@ -1492,32 +1374,27 @@ static void mpc_action_go_inop(fsm_insta
 	int rc = 0;
 	struct channel *wch, *rch;
 
-	if (dev == NULL) {
-		printk(KERN_INFO "%s() dev=NULL\n", __FUNCTION__);
-		return;
-	}
-
-	ctcm_pr_debug("ctcmpc enter: %s  %s()\n", dev->name, __FUNCTION__);
+	BUG_ON(dev == NULL);
+	CTCM_PR_DEBUG("Enter %s: %s\n",	__func__, dev->name);
 
 	priv  = dev->priv;
 	grp =  priv->mpcg;
 	grp->flow_off_called = 0;
-
 	fsm_deltimer(&grp->timer);
-
 	if (grp->channels_terminating)
-					goto done;
+			return;
 
 	grp->channels_terminating = 1;
-
 	grp->saved_state = fsm_getstate(grp->fsm);
 	fsm_newstate(grp->fsm, MPCG_STATE_INOP);
 	if (grp->saved_state > MPCG_STATE_XID7INITF)
-		printk(KERN_NOTICE "%s:MPC GROUP INOPERATIVE\n", dev->name);
+		CTCM_DBF_TEXT_(MPC_TRACE, CTC_DBF_NOTICE,
+			"%s(%s): MPC GROUP INOPERATIVE",
+				CTCM_FUNTAIL, dev->name);
 	if ((grp->saved_state != MPCG_STATE_RESET) ||
 		/* dealloc_channel has been called */
-		((grp->saved_state == MPCG_STATE_RESET) &&
-				(grp->port_persist == 0)))
+			((grp->saved_state == MPCG_STATE_RESET) &&
+						(grp->port_persist == 0)))
 		fsm_deltimer(&priv->restart_timer);
 
 	wch = priv->channel[WRITE];
@@ -1567,29 +1444,24 @@ static void mpc_action_go_inop(fsm_insta
 	/* This can result in INOP of VTAM PU due to halting of  */
 	/* outstanding IO which causes a sense to be returned	 */
 	/* Only about 3 senses are allowed and then IOS/VTAM will*/
-	/* ebcome unreachable without manual intervention	 */
-	if ((grp->port_persist == 1)	|| (grp->alloc_called)) {
+	/* become unreachable without manual intervention	 */
+	if ((grp->port_persist == 1) || (grp->alloc_called)) {
 		grp->alloc_called = 0;
 		fsm_deltimer(&priv->restart_timer);
-		fsm_addtimer(&priv->restart_timer,
-			     500,
-			     DEV_EVENT_RESTART,
-			     dev);
+		fsm_addtimer(&priv->restart_timer, 500, DEV_EVENT_RESTART, dev);
 		fsm_newstate(grp->fsm, MPCG_STATE_RESET);
 		if (grp->saved_state > MPCG_STATE_XID7INITF)
-			printk(KERN_NOTICE "%s:MPC GROUP RECOVERY SCHEDULED\n",
-			       dev->name);
+			CTCM_DBF_TEXT_(MPC_TRACE, CTC_DBF_ALWAYS,
+				"%s(%s): MPC GROUP RECOVERY SCHEDULED",
+					CTCM_FUNTAIL, dev->name);
 	} else {
 		fsm_deltimer(&priv->restart_timer);
 		fsm_addtimer(&priv->restart_timer, 500, DEV_EVENT_STOP, dev);
 		fsm_newstate(grp->fsm, MPCG_STATE_RESET);
-		printk(KERN_NOTICE "%s:MPC GROUP RECOVERY NOT ATTEMPTED\n",
-		       dev->name);
+		CTCM_DBF_TEXT_(MPC_TRACE, CTC_DBF_ALWAYS,
+			"%s(%s): NO MPC GROUP RECOVERY ATTEMPTED",
+						CTCM_FUNTAIL, dev->name);
 	}
-
-done:
-	ctcm_pr_debug("ctcmpc exit:%s  %s()\n", dev->name, __FUNCTION__);
-	return;
 }
 
 /**
@@ -1609,12 +1481,7 @@ static void mpc_action_timeout(fsm_insta
 	struct channel *wch;
 	struct channel *rch;
 
-	CTCM_DBF_TEXT(MPC_TRACE, 6, __FUNCTION__);
-
-	if (dev == NULL) {
-		CTCM_DBF_TEXT_(MPC_ERROR, 4, "%s: dev=NULL\n", __FUNCTION__);
-		return;
-	}
+	BUG_ON(dev == NULL);
 
 	priv = dev->priv;
 	grp = priv->mpcg;
@@ -1633,8 +1500,9 @@ static void mpc_action_timeout(fsm_insta
 		fsm_event(grp->fsm, MPCG_EVENT_INOP, dev);
 	}
 
-	CTCM_DBF_TEXT_(MPC_TRACE, 6, "%s: dev=%s exit",
-					__FUNCTION__, dev->name);
+	CTCM_DBF_TEXT_(MPC_TRACE, CTC_DBF_DEBUG,
+			"%s: dev=%s exit",
+			CTCM_FUNTAIL, dev->name);
 	return;
 }
 
@@ -1646,25 +1514,25 @@ void mpc_action_discontact(fsm_instance 
 {
 	struct mpcg_info   *mpcginfo   = arg;
 	struct channel	   *ch	       = mpcginfo->ch;
-	struct net_device  *dev        = ch->netdev;
-	struct ctcm_priv   *priv    = dev->priv;
-	struct mpc_group   *grp     = priv->mpcg;
+	struct net_device  *dev;
+	struct ctcm_priv   *priv;
+	struct mpc_group   *grp;
 
-	if (ch == NULL)	{
-		printk(KERN_INFO "%s() ch=NULL\n", __FUNCTION__);
-		return;
-	}
-	if (ch->netdev == NULL)	{
-		printk(KERN_INFO "%s() dev=NULL\n", __FUNCTION__);
-		return;
+	if (ch) {
+		dev = ch->netdev;
+		if (dev) {
+			priv = dev->priv;
+			if (priv) {
+				CTCM_DBF_TEXT_(MPC_TRACE, CTC_DBF_NOTICE,
+					"%s: %s: %s\n",
+					CTCM_FUNTAIL, dev->name, ch->id);
+				grp = priv->mpcg;
+				grp->send_qllc_disc = 1;
+				fsm_event(grp->fsm, MPCG_EVENT_INOP, dev);
+			}
+		}
 	}
 
-	ctcm_pr_debug("ctcmpc enter: %s  %s()\n", dev->name, __FUNCTION__);
-
-	grp->send_qllc_disc = 1;
-	fsm_event(grp->fsm, MPCG_EVENT_INOP, dev);
-
-	ctcm_pr_debug("ctcmpc exit: %s  %s()\n", dev->name, __FUNCTION__);
 	return;
 }
 
@@ -1675,26 +1543,9 @@ void mpc_action_discontact(fsm_instance 
  */
 void mpc_action_send_discontact(unsigned long thischan)
 {
-	struct channel	   *ch;
-	struct net_device  *dev;
-	struct ctcm_priv    *priv;
-	struct mpc_group   *grp;
-	int rc = 0;
-	unsigned long	  saveflags;
-
-	ch = (struct channel *)thischan;
-	dev = ch->netdev;
-	priv = dev->priv;
-	grp = priv->mpcg;
-
-	ctcm_pr_info("ctcmpc: %s cp:%i enter: %s() GrpState:%s ChState:%s\n",
-		       dev->name,
-		       smp_processor_id(),
-		       __FUNCTION__,
-		       fsm_getstate_str(grp->fsm),
-		       fsm_getstate_str(ch->fsm));
-	saveflags = 0;	/* avoids compiler warning with
-			   spin_unlock_irqrestore */
+	int rc;
+	struct channel	*ch = (struct channel *)thischan;
+	unsigned long	saveflags = 0;
 
 	spin_lock_irqsave(get_ccwdev_lock(ch->cdev), saveflags);
 	rc = ccw_device_start(ch->cdev, &ch->ccw[15],
@@ -1702,16 +1553,9 @@ void mpc_action_send_discontact(unsigned
 	spin_unlock_irqrestore(get_ccwdev_lock(ch->cdev), saveflags);
 
 	if (rc != 0) {
-		ctcm_pr_info("ctcmpc: %s() ch:%s IO failed \n",
-			       __FUNCTION__,
-			       ch->id);
-		ctcm_ccw_check_rc(ch, rc, "send discontact");
-		/* Not checking return code value here */
-		/* Making best effort to notify partner*/
-		/* that MPC Group is going down        */
+		ctcm_ccw_check_rc(ch, rc, (char *)__func__);
 	}
 
-	ctcm_pr_debug("ctcmpc exit: %s  %s()\n", dev->name, __FUNCTION__);
 	return;
 }
 
@@ -1723,49 +1567,50 @@ void mpc_action_send_discontact(unsigned
 */
 static int mpc_validate_xid(struct mpcg_info *mpcginfo)
 {
-	struct channel	   *ch	    = mpcginfo->ch;
-	struct net_device  *dev     = ch->netdev;
+	struct channel	   *ch	 = mpcginfo->ch;
+	struct net_device  *dev  = ch->netdev;
 	struct ctcm_priv   *priv = dev->priv;
 	struct mpc_group   *grp  = priv->mpcg;
-	struct xid2	   *xid     = mpcginfo->xid;
-	int	failed	= 0;
-	int	rc	= 0;
-	__u64	our_id, their_id = 0;
-	int	len;
+	struct xid2	   *xid  = mpcginfo->xid;
+	int	rc	 = 0;
+	__u64	our_id   = 0;
+	__u64   their_id = 0;
+	int	len = TH_HEADER_LENGTH + PDU_HEADER_LENGTH;
 
-	len = TH_HEADER_LENGTH + PDU_HEADER_LENGTH;
+	CTCM_PR_DEBUG("Enter %s: xid=%p\n", __func__, xid);
 
-	ctcm_pr_debug("ctcmpc enter:	%s()\n", __FUNCTION__);
-
-	if (mpcginfo->xid == NULL) {
-		printk(KERN_INFO "%s() xid=NULL\n", __FUNCTION__);
+	if (xid == NULL) {
 		rc = 1;
-					goto done;
+		/* XID REJECTED: xid == NULL */
+		CTCM_DBF_TEXT_(MPC_ERROR, CTC_DBF_ERROR,
+			"%s(%s): xid = NULL",
+				CTCM_FUNTAIL, ch->id);
+			goto done;
 	}
 
-	ctcm_pr_debug("ctcmpc :  %s  xid received()\n", __FUNCTION__);
-	ctcmpc_dumpit((char *)mpcginfo->xid, XID2_LENGTH);
+	CTCM_D3_DUMP((char *)xid, XID2_LENGTH);
 
 	/*the received direction should be the opposite of ours  */
 	if (((CHANNEL_DIRECTION(ch->flags) == READ) ? XID2_WRITE_SIDE :
 				XID2_READ_SIDE) != xid->xid2_dlc_type) {
-		failed = 1;
-		printk(KERN_INFO "ctcmpc:%s() XID REJECTED - READ-WRITE CH "
-			"Pairing Invalid \n", __FUNCTION__);
+		rc = 2;
+		/* XID REJECTED: r/w channel pairing mismatch */
+		CTCM_DBF_TEXT_(MPC_ERROR, CTC_DBF_ERROR,
+			"%s(%s): r/w channel pairing mismatch",
+				CTCM_FUNTAIL, ch->id);
+			goto done;
 	}
 
 	if (xid->xid2_dlc_type == XID2_READ_SIDE) {
-		ctcm_pr_debug("ctcmpc: %s(): grpmaxbuf:%d xid2buflen:%d\n",
-				__FUNCTION__, grp->group_max_buflen,
-				xid->xid2_buf_len);
+		CTCM_PR_DEBUG("%s: grpmaxbuf:%d xid2buflen:%d\n", __func__,
+				grp->group_max_buflen, xid->xid2_buf_len);
 
-		if (grp->group_max_buflen == 0 ||
-			grp->group_max_buflen > xid->xid2_buf_len - len)
+		if (grp->group_max_buflen == 0 || grp->group_max_buflen >
+						xid->xid2_buf_len - len)
 			grp->group_max_buflen = xid->xid2_buf_len - len;
 	}
 
-
-	if (grp->saved_xid2 == NULL)	{
+	if (grp->saved_xid2 == NULL) {
 		grp->saved_xid2 =
 			(struct xid2 *)skb_tail_pointer(grp->rcvd_xid_skb);
 
@@ -1786,49 +1631,54 @@ static int mpc_validate_xid(struct mpcg_
 		/* lower id assume the xside role */
 		if (our_id < their_id) {
 			grp->roll = XSIDE;
-			ctcm_pr_debug("ctcmpc :%s() WE HAVE LOW ID-"
-				       "TAKE XSIDE\n", __FUNCTION__);
+			CTCM_DBF_TEXT_(MPC_TRACE, CTC_DBF_NOTICE,
+				"%s(%s): WE HAVE LOW ID - TAKE XSIDE",
+					CTCM_FUNTAIL, ch->id);
 		} else {
 			grp->roll = YSIDE;
-			ctcm_pr_debug("ctcmpc :%s() WE HAVE HIGH ID-"
-				       "TAKE YSIDE\n", __FUNCTION__);
+			CTCM_DBF_TEXT_(MPC_TRACE, CTC_DBF_NOTICE,
+				"%s(%s): WE HAVE HIGH ID - TAKE YSIDE",
+					CTCM_FUNTAIL, ch->id);
 		}
 
 	} else {
 		if (xid->xid2_flag4 != grp->saved_xid2->xid2_flag4) {
-			failed = 1;
-			printk(KERN_INFO "%s XID REJECTED - XID Flag Byte4\n",
-			       __FUNCTION__);
+			rc = 3;
+			/* XID REJECTED: xid flag byte4 mismatch */
+			CTCM_DBF_TEXT_(MPC_ERROR, CTC_DBF_ERROR,
+				"%s(%s): xid flag byte4 mismatch",
+					CTCM_FUNTAIL, ch->id);
 		}
 		if (xid->xid2_flag2 == 0x40) {
-			failed = 1;
-			printk(KERN_INFO "%s XID REJECTED - XID NOGOOD\n",
-			       __FUNCTION__);
+			rc = 4;
+			/* XID REJECTED - xid NOGOOD */
+			CTCM_DBF_TEXT_(MPC_ERROR, CTC_DBF_ERROR,
+				"%s(%s): xid NOGOOD",
+					CTCM_FUNTAIL, ch->id);
 		}
 		if (xid->xid2_adj_id != grp->saved_xid2->xid2_adj_id) {
-			failed = 1;
-			printk(KERN_INFO "%s XID REJECTED - "
-				"Adjacent Station ID Mismatch\n",
-				__FUNCTION__);
+			rc = 5;
+			/* XID REJECTED - Adjacent Station ID Mismatch */
+			CTCM_DBF_TEXT_(MPC_ERROR, CTC_DBF_ERROR,
+				"%s(%s): Adjacent Station ID Mismatch",
+					CTCM_FUNTAIL, ch->id);
 		}
 		if (xid->xid2_sender_id != grp->saved_xid2->xid2_sender_id) {
-			failed = 1;
-			printk(KERN_INFO "%s XID REJECTED - "
-				"Sender Address Mismatch\n", __FUNCTION__);
-
+			rc = 6;
+			/* XID REJECTED - Sender Address Mismatch */
+			CTCM_DBF_TEXT_(MPC_ERROR, CTC_DBF_ERROR,
+				"%s(%s): Sender Address Mismatch",
+					CTCM_FUNTAIL, ch->id);
 		}
 	}
 
-	if (failed) {
+done:
+	if (rc) {
 		ctcm_pr_info("ctcmpc	   :  %s() failed\n", __FUNCTION__);
 		priv->xid->xid2_flag2 = 0x40;
 		grp->saved_xid2->xid2_flag2 = 0x40;
-		rc = 1;
 	}
 
-done:
-
-	ctcm_pr_debug("ctcmpc exit:  %s()\n", __FUNCTION__);
 	return rc;
 }
 
@@ -1839,46 +1689,20 @@ done:
 static void mpc_action_side_xid(fsm_instance *fsm, void *arg, int side)
 {
 	struct channel *ch = arg;
-	struct ctcm_priv *priv;
-	struct mpc_group *grp = NULL;
-	struct net_device *dev = NULL;
 	int rc = 0;
 	int gotlock = 0;
 	unsigned long saveflags = 0;	/* avoids compiler warning with
-			   spin_unlock_irqrestore */
-
-	if (ch == NULL)	{
-		printk(KERN_INFO "%s ch=NULL\n", __FUNCTION__);
-					goto done;
-	}
-
-	if (do_debug)
-		ctcm_pr_debug("ctcmpc enter: %s(): cp=%i ch=0x%p id=%s\n",
-			__FUNCTION__, smp_processor_id(), ch, ch->id);
-
-	dev = ch->netdev;
-	if (dev == NULL) {
-		printk(KERN_INFO "%s dev=NULL\n", __FUNCTION__);
-					goto done;
-	}
-
-	priv = dev->priv;
-	if (priv == NULL) {
-		printk(KERN_INFO "%s priv=NULL\n", __FUNCTION__);
-					goto done;
-	}
+					   spin_unlock_irqrestore */
 
-	grp = priv->mpcg;
-	if (grp == NULL) {
-		printk(KERN_INFO "%s grp=NULL\n", __FUNCTION__);
-					goto done;
-	}
+	CTCM_PR_DEBUG("Enter %s: cp=%i ch=0x%p id=%s\n",
+			__func__, smp_processor_id(), ch, ch->id);
 
 	if (ctcm_checkalloc_buffer(ch))
 					goto done;
 
-	/* skb data-buffer referencing: */
-
+	/*
+	 * skb data-buffer referencing:
+	 */
 	ch->trans_skb->data = ch->trans_skb_data;
 	skb_reset_tail_pointer(ch->trans_skb);
 	ch->trans_skb->len = 0;
@@ -1911,22 +1735,22 @@ static void mpc_action_side_xid(fsm_inst
 	ch->ccw[8].count	= 0;
 	ch->ccw[8].cda		= 0x00;
 
+	if (!(ch->xid_th && ch->xid && ch->xid_id))
+		CTCM_DBF_TEXT_(MPC_TRACE, CTC_DBF_INFO,
+			"%s(%s): xid_th=%p, xid=%p, xid_id=%p",
+			CTCM_FUNTAIL, ch->id, ch->xid_th, ch->xid, ch->xid_id);
+
 	if (side == XSIDE) {
 		/* mpc_action_xside_xid */
-		if (ch->xid_th == NULL) {
-			printk(KERN_INFO "%s ch->xid_th=NULL\n", __FUNCTION__);
-					goto done;
-		}
+		if (ch->xid_th == NULL)
+				goto done;
 		ch->ccw[9].cmd_code	= CCW_CMD_WRITE;
 		ch->ccw[9].flags	= CCW_FLAG_SLI | CCW_FLAG_CC;
 		ch->ccw[9].count	= TH_HEADER_LENGTH;
 		ch->ccw[9].cda		= virt_to_phys(ch->xid_th);
 
-		if (ch->xid == NULL) {
-			printk(KERN_INFO "%s ch->xid=NULL\n", __FUNCTION__);
-					goto done;
-		}
-
+		if (ch->xid == NULL)
+				goto done;
 		ch->ccw[10].cmd_code	= CCW_CMD_WRITE;
 		ch->ccw[10].flags	= CCW_FLAG_SLI | CCW_FLAG_CC;
 		ch->ccw[10].count	= XID2_LENGTH;
@@ -1956,28 +1780,22 @@ static void mpc_action_side_xid(fsm_inst
 		ch->ccw[10].count	= XID2_LENGTH;
 		ch->ccw[10].cda		= virt_to_phys(ch->rcvd_xid);
 
-		if (ch->xid_th == NULL)	{
-			printk(KERN_INFO "%s ch->xid_th=NULL\n", __FUNCTION__);
-					goto done;
-		}
+		if (ch->xid_th == NULL)
+				goto done;
 		ch->ccw[11].cmd_code	= CCW_CMD_WRITE;
 		ch->ccw[11].flags	= CCW_FLAG_SLI | CCW_FLAG_CC;
 		ch->ccw[11].count	= TH_HEADER_LENGTH;
 		ch->ccw[11].cda		= virt_to_phys(ch->xid_th);
 
-		if (ch->xid == NULL) {
-			printk(KERN_INFO "%s ch->xid=NULL\n", __FUNCTION__);
-					goto done;
-		}
+		if (ch->xid == NULL)
+				goto done;
 		ch->ccw[12].cmd_code	= CCW_CMD_WRITE;
 		ch->ccw[12].flags	= CCW_FLAG_SLI | CCW_FLAG_CC;
 		ch->ccw[12].count	= XID2_LENGTH;
 		ch->ccw[12].cda		= virt_to_phys(ch->xid);
 
-		if (ch->xid_id == NULL)	{
-			printk(KERN_INFO "%s ch->xid_id=NULL\n", __FUNCTION__);
-					goto done;
-		}
+		if (ch->xid_id == NULL)
+				goto done;
 		ch->ccw[13].cmd_code	= CCW_CMD_WRITE;
 		ch->ccw[13].cda		= virt_to_phys(ch->xid_id);
 
@@ -1990,12 +1808,11 @@ static void mpc_action_side_xid(fsm_inst
 	ch->ccw[14].count	= 0;
 	ch->ccw[14].cda		= 0;
 
-	if (do_debug_ccw)
-		ctcmpc_dumpit((char *)&ch->ccw[8], sizeof(struct ccw1) * 7);
+	CTCM_CCW_DUMP((char *)&ch->ccw[8], sizeof(struct ccw1) * 7);
+	CTCM_D3_DUMP((char *)ch->xid_th, TH_HEADER_LENGTH);
+	CTCM_D3_DUMP((char *)ch->xid, XID2_LENGTH);
+	CTCM_D3_DUMP((char *)ch->xid_id, 4);
 
-	ctcmpc_dumpit((char *)ch->xid_th, TH_HEADER_LENGTH);
-	ctcmpc_dumpit((char *)ch->xid, XID2_LENGTH);
-	ctcmpc_dumpit((char *)ch->xid_id, 4);
 	if (!in_irq()) {
 			 /* Such conditional locking is a known problem for
 			  * sparse because its static undeterministic.
@@ -2012,16 +1829,13 @@ static void mpc_action_side_xid(fsm_inst
 		spin_unlock_irqrestore(get_ccwdev_lock(ch->cdev), saveflags);
 
 	if (rc != 0) {
-		ctcm_pr_info("ctcmpc: %s() ch:%s IO failed \n",
-				__FUNCTION__, ch->id);
 		ctcm_ccw_check_rc(ch, rc,
 				(side == XSIDE) ? "x-side XID" : "y-side XID");
 	}
 
 done:
-	if (do_debug)
-		ctcm_pr_debug("ctcmpc exit : %s(): ch=0x%p id=%s\n",
-				__FUNCTION__, ch, ch->id);
+	CTCM_PR_DEBUG("Exit %s: ch=0x%p id=%s\n",
+				__func__, ch, ch->id);
 	return;
 
 }
@@ -2050,41 +1864,19 @@ static void mpc_action_yside_xid(fsm_ins
  */
 static void mpc_action_doxid0(fsm_instance *fsm, int event, void *arg)
 {
-	struct channel	   *ch = arg;
-	struct ctcm_priv    *priv;
-	struct mpc_group   *grp     = NULL;
-	struct net_device *dev = NULL;
-
-	if (do_debug)
-		ctcm_pr_debug("ctcmpc enter: %s(): cp=%i ch=0x%p id=%s\n",
-			__FUNCTION__, smp_processor_id(), ch, ch->id);
-
-	if (ch == NULL) {
-		printk(KERN_WARNING "%s ch=NULL\n", __FUNCTION__);
-					goto done;
-	}
-
-	dev = ch->netdev;
-	if (dev == NULL) {
-		printk(KERN_WARNING "%s dev=NULL\n", __FUNCTION__);
-					goto done;
-	}
-
-	priv = dev->priv;
-	if (priv == NULL) {
-		printk(KERN_WARNING "%s priv=NULL\n", __FUNCTION__);
-					goto done;
-	}
+	struct channel	   *ch   = arg;
+	struct net_device  *dev  = ch->netdev;
+	struct ctcm_priv   *priv = dev->priv;
+	struct mpc_group   *grp  = priv->mpcg;
 
-	grp = priv->mpcg;
-	if (grp == NULL) {
-		printk(KERN_WARNING "%s grp=NULL\n", __FUNCTION__);
-					goto done;
-	}
+	CTCM_PR_DEBUG("Enter %s: cp=%i ch=0x%p id=%s\n",
+			__func__, smp_processor_id(), ch, ch->id);
 
 	if (ch->xid == NULL) {
-		printk(KERN_WARNING "%s ch-xid=NULL\n", __FUNCTION__);
-					goto done;
+		CTCM_DBF_TEXT_(MPC_ERROR, CTC_DBF_ERROR,
+			"%s(%s): ch->xid == NULL",
+				CTCM_FUNTAIL, dev->name);
+		return;
 	}
 
 	fsm_newstate(ch->fsm, CH_XID0_INPROGRESS);
@@ -2104,12 +1896,7 @@ static void mpc_action_doxid0(fsm_instan
 
 	fsm_event(grp->fsm, MPCG_EVENT_DOIO, ch);
 
-done:
-	if (do_debug)
-		ctcm_pr_debug("ctcmpc exit : %s(): ch=0x%p id=%s\n",
-			__FUNCTION__, ch, ch->id);
 	return;
-
 }
 
 /*
@@ -2119,32 +1906,16 @@ done:
 static void mpc_action_doxid7(fsm_instance *fsm, int event, void *arg)
 {
 	struct net_device *dev = arg;
-	struct ctcm_priv   *priv = NULL;
-	struct mpc_group  *grp = NULL;
+	struct ctcm_priv  *priv = dev->priv;
+	struct mpc_group  *grp  = NULL;
 	int direction;
-	int rc = 0;
 	int send = 0;
 
-	ctcm_pr_debug("ctcmpc enter:	%s() \n", __FUNCTION__);
-
-	if (dev == NULL) {
-		printk(KERN_INFO "%s dev=NULL \n", __FUNCTION__);
-		rc = 1;
-					goto done;
-	}
-
-	priv = dev->priv;
-	if (priv == NULL) {
-		printk(KERN_INFO "%s priv=NULL \n", __FUNCTION__);
-		rc = 1;
-					goto done;
-	}
-
-	grp = priv->mpcg;
+	if (priv)
+		grp = priv->mpcg;
 	if (grp == NULL) {
-		printk(KERN_INFO "%s grp=NULL \n", __FUNCTION__);
-		rc = 1;
-					goto done;
+		fsm_event(grp->fsm, MPCG_EVENT_INOP, dev);
+		return;
 	}
 
 	for (direction = READ; direction <= WRITE; direction++)	{
@@ -2199,11 +1970,6 @@ static void mpc_action_doxid7(fsm_instan
 			fsm_event(grp->fsm, MPCG_EVENT_DOIO, ch);
 	}
 
-done:
-
-	if (rc != 0)
-		fsm_event(grp->fsm, MPCG_EVENT_INOP, dev);
-
 	return;
 }
 
@@ -2214,24 +1980,15 @@ done:
 static void mpc_action_rcvd_xid0(fsm_instance *fsm, int event, void *arg)
 {
 
-	struct mpcg_info   *mpcginfo   = arg;
-	struct channel	   *ch	       = mpcginfo->ch;
-	struct net_device  *dev        = ch->netdev;
-	struct ctcm_priv   *priv;
-	struct mpc_group   *grp;
-
-	if (do_debug)
-		ctcm_pr_debug("ctcmpc enter: %s(): cp=%i ch=0x%p id=%s\n",
-			__FUNCTION__, smp_processor_id(), ch, ch->id);
-
-	priv = dev->priv;
-	grp = priv->mpcg;
+	struct mpcg_info   *mpcginfo  = arg;
+	struct channel	   *ch   = mpcginfo->ch;
+	struct net_device  *dev  = ch->netdev;
+	struct ctcm_priv   *priv = dev->priv;
+	struct mpc_group   *grp  = priv->mpcg;
 
-	ctcm_pr_debug("ctcmpc in:%s() %s xid2:%i xid7:%i xidt_p2:%i \n",
-		       __FUNCTION__, ch->id,
-		       grp->outstanding_xid2,
-		       grp->outstanding_xid7,
-		       grp->outstanding_xid7_p2);
+	CTCM_PR_DEBUG("%s: ch-id:%s xid2:%i xid7:%i xidt_p2:%i \n",
+			__func__, ch->id, grp->outstanding_xid2,
+			grp->outstanding_xid7, grp->outstanding_xid7_p2);
 
 	if (fsm_getstate(ch->fsm) < CH_XID7_PENDING)
 		fsm_newstate(ch->fsm, CH_XID7_PENDING);
@@ -2268,17 +2025,12 @@ static void mpc_action_rcvd_xid0(fsm_ins
 	}
 	kfree(mpcginfo);
 
-	if (do_debug) {
-		ctcm_pr_debug("ctcmpc:%s() %s xid2:%i xid7:%i xidt_p2:%i \n",
-				__FUNCTION__, ch->id,
-				grp->outstanding_xid2,
-				grp->outstanding_xid7,
-				grp->outstanding_xid7_p2);
-		ctcm_pr_debug("ctcmpc:%s() %s grpstate: %s chanstate: %s \n",
-				__FUNCTION__, ch->id,
-				fsm_getstate_str(grp->fsm),
-				fsm_getstate_str(ch->fsm));
-	}
+	CTCM_PR_DEBUG("ctcmpc:%s() %s xid2:%i xid7:%i xidt_p2:%i \n",
+		__func__, ch->id, grp->outstanding_xid2,
+		grp->outstanding_xid7, grp->outstanding_xid7_p2);
+	CTCM_PR_DEBUG("ctcmpc:%s() %s grpstate: %s chanstate: %s \n",
+		__func__, ch->id,
+		fsm_getstate_str(grp->fsm), fsm_getstate_str(ch->fsm));
 	return;
 
 }
@@ -2296,15 +2048,10 @@ static void mpc_action_rcvd_xid7(fsm_ins
 	struct ctcm_priv   *priv    = dev->priv;
 	struct mpc_group   *grp     = priv->mpcg;
 
-	if (do_debug) {
-		ctcm_pr_debug("ctcmpc enter: %s(): cp=%i ch=0x%p id=%s\n",
-				__FUNCTION__, smp_processor_id(), ch, ch->id);
-
-		ctcm_pr_debug("ctcmpc:  outstanding_xid7: %i, "
-				" outstanding_xid7_p2: %i\n",
-				grp->outstanding_xid7,
-				grp->outstanding_xid7_p2);
-	}
+	CTCM_PR_DEBUG("Enter %s: cp=%i ch=0x%p id=%s\n",
+		__func__, smp_processor_id(), ch, ch->id);
+	CTCM_PR_DEBUG("%s: outstanding_xid7: %i, outstanding_xid7_p2: %i\n",
+		__func__, grp->outstanding_xid7, grp->outstanding_xid7_p2);
 
 	grp->outstanding_xid7--;
 	ch->xid_skb->data = ch->xid_skb_data;
@@ -2337,14 +2084,8 @@ static void mpc_action_rcvd_xid7(fsm_ins
 		mpc_validate_xid(mpcginfo);
 		break;
 	}
-
 	kfree(mpcginfo);
-
-	if (do_debug)
-		ctcm_pr_debug("ctcmpc exit: %s(): cp=%i ch=0x%p id=%s\n",
-			__FUNCTION__, smp_processor_id(), ch, ch->id);
 	return;
-
 }
 
 /*
@@ -2353,36 +2094,14 @@ static void mpc_action_rcvd_xid7(fsm_ins
  */
 static int mpc_send_qllc_discontact(struct net_device *dev)
 {
-	int	rc	= 0;
 	__u32	new_len	= 0;
 	struct sk_buff   *skb;
 	struct qllc      *qllcptr;
-	struct ctcm_priv *priv;
-	struct mpc_group *grp;
-
-	ctcm_pr_debug("ctcmpc enter:	%s()\n", __FUNCTION__);
-
-	if (dev == NULL) {
-		printk(KERN_INFO "%s() dev=NULL\n", __FUNCTION__);
-		rc = 1;
-					goto done;
-	}
-
-	priv = dev->priv;
-	if (priv == NULL) {
-		printk(KERN_INFO "%s() priv=NULL\n", __FUNCTION__);
-		rc = 1;
-					goto done;
-	}
+	struct ctcm_priv *priv = dev->priv;
+	struct mpc_group *grp = priv->mpcg;
 
-	grp = priv->mpcg;
-	if (grp == NULL) {
-		printk(KERN_INFO "%s() grp=NULL\n", __FUNCTION__);
-		rc = 1;
-					goto done;
-	}
-	ctcm_pr_info("ctcmpc: %s() GROUP STATE: %s\n", __FUNCTION__,
-			mpcg_state_names[grp->saved_state]);
+	CTCM_PR_DEBUG("%s: GROUP STATE: %s\n",
+		__func__, mpcg_state_names[grp->saved_state]);
 
 	switch (grp->saved_state) {
 	/*
@@ -2408,11 +2127,10 @@ static int mpc_send_qllc_discontact(stru
 		new_len = sizeof(struct qllc);
 		qllcptr = kzalloc(new_len, gfp_type() | GFP_DMA);
 		if (qllcptr == NULL) {
-			printk(KERN_INFO
-			       "ctcmpc: Out of memory in %s()\n",
-			       dev->name);
-			rc = 1;
-				goto done;
+			CTCM_DBF_TEXT_(MPC_ERROR, CTC_DBF_ERROR,
+				"%s(%s): qllcptr allocation error",
+						CTCM_FUNTAIL, dev->name);
+			return -ENOMEM;
 		}
 
 		qllcptr->qllc_address = 0xcc;
@@ -2421,31 +2139,29 @@ static int mpc_send_qllc_discontact(stru
 		skb = __dev_alloc_skb(new_len, GFP_ATOMIC);
 
 		if (skb == NULL) {
-			printk(KERN_INFO "%s Out of memory in mpc_send_qllc\n",
-			       dev->name);
+			CTCM_DBF_TEXT_(MPC_ERROR, CTC_DBF_ERROR,
+				"%s(%s): skb allocation error",
+						CTCM_FUNTAIL, dev->name);
 			priv->stats.rx_dropped++;
-			rc = 1;
 			kfree(qllcptr);
-				goto done;
+			return -ENOMEM;
 		}
 
 		memcpy(skb_put(skb, new_len), qllcptr, new_len);
 		kfree(qllcptr);
 
 		if (skb_headroom(skb) < 4) {
-			printk(KERN_INFO "ctcmpc: %s() Unable to"
-			       " build discontact for %s\n",
-			       __FUNCTION__, dev->name);
-			rc = 1;
+			CTCM_DBF_TEXT_(MPC_ERROR, CTC_DBF_ERROR,
+				"%s(%s): skb_headroom error",
+						CTCM_FUNTAIL, dev->name);
 			dev_kfree_skb_any(skb);
-				goto done;
+			return -ENOMEM;
 		}
 
 		*((__u32 *)skb_push(skb, 4)) = priv->channel[READ]->pdu_seq;
 		priv->channel[READ]->pdu_seq++;
-		if (do_debug_data)
-			ctcm_pr_debug("ctcmpc: %s ToDCM_pdu_seq= %08x\n",
-				__FUNCTION__, priv->channel[READ]->pdu_seq);
+		CTCM_PR_DBGDATA("ctcmpc: %s ToDCM_pdu_seq= %08x\n",
+				__func__, priv->channel[READ]->pdu_seq);
 
 		/* receipt of CC03 resets anticipated sequence number on
 		      receiving side */
@@ -2455,7 +2171,7 @@ static int mpc_send_qllc_discontact(stru
 		skb->protocol = htons(ETH_P_SNAP);
 		skb->ip_summed = CHECKSUM_UNNECESSARY;
 
-		ctcmpc_dumpit((char *)skb->data, (sizeof(struct qllc) + 4));
+		CTCM_D3_DUMP(skb->data, (sizeof(struct qllc) + 4));
 
 		netif_rx(skb);
 		break;
@@ -2464,9 +2180,7 @@ static int mpc_send_qllc_discontact(stru
 
 	}
 
-done:
-	ctcm_pr_debug("ctcmpc exit:  %s()\n", __FUNCTION__);
-	return rc;
+	return 0;
 }
 /* --- This is the END my friend --- */
 
Index: linux-2.6-uschi/drivers/s390/net/ctcm_mpc.h
===================================================================
--- linux-2.6-uschi.orig/drivers/s390/net/ctcm_mpc.h
+++ linux-2.6-uschi/drivers/s390/net/ctcm_mpc.h
@@ -231,7 +231,7 @@ static inline void ctcmpc_dump32(char *b
 int ctcmpc_open(struct net_device *);
 void ctcm_ccw_check_rc(struct channel *, int, char *);
 void mpc_group_ready(unsigned long adev);
-int mpc_channel_action(struct channel *ch, int direction, int action);
+void mpc_channel_action(struct channel *ch, int direction, int action);
 void mpc_action_send_discontact(unsigned long thischan);
 void mpc_action_discontact(fsm_instance *fi, int event, void *arg);
 void ctcmpc_bh(unsigned long thischan);

-- 
