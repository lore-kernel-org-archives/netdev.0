From: Ursula Braun <braunu@de.ibm.com>
Subject: [patch 4/7] ctcm: replaced ctc driver - part 1
Date: Fri, 01 Feb 2008 15:51:32 +0100
Message-ID: <20080201145258.662986000@linux.vnet.ibm.com>
References: <20080201145128.462823000@linux.vnet.ibm.com>
Cc: Peter Tiedemann <ptiedem@de.ibm.com>
To: jgarzik@pobox.com, netdev@vger.kernel.org,
	linux-s390@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mtagate4.de.ibm.com ([195.212.29.153]:50610 "EHLO
	mtagate4.de.ibm.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1755142AbYBAOxC (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 1 Feb 2008 09:53:02 -0500
Content-Disposition: inline; filename=ctcm_base.diff
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Peter Tiedemann <ptiedem@de.ibm.com>

ctcm driver supports the channel-to-channel connections of the
old ctc driver plus an additional MPC protocol to provide SNA
connectivity.
This is part 1 of the ctcm-stuff comprising
    the main routine
    the sysfs interface
    the ctc debugging facilities

Signed-off-by: Peter Tiedemann <ptiedem@de.ibm.com>
Signed-off-by: Ursula Braun <braunu@de.ibm.com>

---
 drivers/s390/net/ctcm_dbug.c  |   67 +
 drivers/s390/net/ctcm_dbug.h  |  158 +++
 drivers/s390/net/ctcm_main.c  | 1772 ++++++++++++++++++++++++++++++++++++++++++
 drivers/s390/net/ctcm_main.h  |  287 ++++++
 drivers/s390/net/ctcm_sysfs.c |  210 ++++
 5 files changed, 2494 insertions(+)

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
+	#define do_debug 1
+#else
+	#define do_debug 0
+#endif
+#ifdef DEBUGDATA
+	#define do_debug_data 1
+#else
+	#define do_debug_data 0
+#endif
+#ifdef DEBUGCCW
+	#define do_debug_ccw 1
+#else
+	#define do_debug_ccw 0
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
+ * @param ch The channel where this skb has been received.
+ * @param pskb The received skb.
+ */
+void ctcm_unpack_skb(struct channel *ch, struct sk_buff *pskb)
+{
+	struct net_device *dev = ch->netdev;
+	struct ctcm_priv *privptr = (struct ctcm_priv *)dev->priv;
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
+			privptr->stats.rx_dropped++;
+			privptr->stats.rx_frame_errors++;
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
+			privptr->stats.rx_dropped++;
+			privptr->stats.rx_length_errors++;
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
+			privptr->stats.rx_dropped++;
+			privptr->stats.rx_length_errors++;
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
+			privptr->stats.rx_dropped++;
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
+		privptr->stats.rx_packets++;
+		privptr->stats.rx_bytes += skblen;
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
+ * @param ch Pointer to channel struct to be released.
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
+ * @param ch Pointer to channel struct to be released.
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
+ * @param type Type of channel we are interested in.
+ * @param id Id of channel we are interested in.
+ * @param direction Direction we want to use this channel for.
+ *
+ * @return Pointer to a channel or NULL if no matching channel available.
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
+ * @param ch    The channel, the sense code belongs to.
+ * @param sense The sense code to inspect.
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
+ * @param dev Pointer to interface struct.
+ *
+ * @return 0 on success, -ERRNO on failure. (Never fails.)
+ */
+int ctcm_open(struct net_device *dev)
+{
+	struct ctcm_priv *privptr = (struct ctcm_priv *)dev->priv;
+
+	CTCMY_DBF_DEV_NAME(SETUP, dev, "");
+	if (!IS_MPC(privptr))
+		fsm_event(privptr->fsm,	DEV_EVENT_START, dev);
+	return 0;
+}
+
+/**
+ * Close an interface.
+ * Called from generic network layer when ifconfig down is run.
+ *
+ * @param dev Pointer to interface struct.
+ *
+ * @return 0 on success, -ERRNO on failure. (Never fails.)
+ */
+int ctcm_close(struct net_device *dev)
+{
+	struct ctcm_priv *privptr = (struct ctcm_priv *)dev->priv;
+
+	CTCMY_DBF_DEV_NAME(SETUP, dev, "");
+	if (!IS_MPC(privptr))
+		fsm_event(privptr->fsm, DEV_EVENT_STOP, dev);
+	return 0;
+}
+
+
+/**
+ * Transmit a packet.
+ * This is a helper function for ctcm_tx().
+ *
+ * @param ch Channel to be used for sending.
+ * @param skb Pointer to struct sk_buff of packet to send.
+ *            The linklevel header has already been set up
+ *            by ctcm_tx().
+ *
+ * @return 0 on success, -ERRNO on failure. (Never fails.)
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
+		struct ctcm_priv *privptr = dev->priv;
+		privptr->stats.tx_packets++;
+		privptr->stats.tx_bytes += skb->len - LL_HEADER_LENGTH;
+	}
+done:
+	ctcm_clear_busy(ch->netdev);
+	return rc;
+}
+
+static void ctcmpc_send_sweep_req(struct channel *rch)
+{
+	struct net_device *dev = rch->netdev;
+	struct ctcm_priv *privptr;
+	struct mpc_group *grpptr;
+	struct th_sweep *header;
+	struct sk_buff *sweep_skb;
+	struct channel *ch;
+	int rc = 0;
+
+	privptr = (struct ctcm_priv *)dev->priv;
+	grpptr = privptr->mpcg;
+	ch = privptr->channel[WRITE];
+
+	if (do_debug)
+		MPC_DBF_DEV_NAME(TRACE, dev, ch->id);
+
+	/* sweep processing is not complete until response and request */
+	/* has completed for all read channels in group		       */
+	if (grpptr->in_sweep == 0) {
+		grpptr->in_sweep = 1;
+		grpptr->sweep_rsp_pend_num = grpptr->active_channels[READ];
+		grpptr->sweep_req_pend_num = grpptr->active_channels[READ];
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
+		grpptr->in_sweep = 0;
+		ctcm_clear_busy(dev);
+		fsm_event(grpptr->fsm, MPCG_EVENT_INOP, dev);
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
+	struct ctcm_priv *privptr = (struct ctcm_priv *)dev->priv;
+	struct mpc_group *grpptr = privptr->mpcg;
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
+	if ((fsm_getstate(ch->fsm) != CTC_STATE_TXIDLE) || grpptr->in_sweep) {
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
+			fsm_event(privptr->mpcg->fsm, MPCG_EVENT_INOP, dev);
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
+			fsm_event(privptr->mpcg->fsm, MPCG_EVENT_INOP, dev);
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
+		fsm_event(privptr->mpcg->fsm, MPCG_EVENT_INOP, dev);
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
+		fsm_event(privptr->mpcg->fsm, MPCG_EVENT_INOP, dev);
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
+			fsm_event(privptr->mpcg->fsm, MPCG_EVENT_INOP, dev);
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
+		privptr->stats.tx_packets++;
+		privptr->stats.tx_bytes += skb->len - TH_HEADER_LENGTH;
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
+ * @param skb Pointer to buffer containing the packet.
+ * @param dev Pointer to interface struct.
+ *
+ * @return 0 if packet consumed, !0 if packet rejected.
+ *         Note: If we return !0, then the packet is free'd by
+ *               the generic network layer.
+ */
+/* first merge version - leaving both functions separated */
+static int ctcm_tx(struct sk_buff *skb, struct net_device *dev)
+{
+	int rc = 0;
+	struct ctcm_priv *privptr;
+
+	CTCM_DBF_TEXT(TRACE, 5, __FUNCTION__);
+	privptr = (struct ctcm_priv *)dev->priv;
+
+	if (skb == NULL) {
+		ctcm_pr_warn("%s: NULL sk_buff passed\n", dev->name);
+		privptr->stats.tx_dropped++;
+		return 0;
+	}
+	if (skb_headroom(skb) < (LL_HEADER_LENGTH + 2)) {
+		ctcm_pr_warn("%s: Got sk_buff with head room < %ld bytes\n",
+			    dev->name, LL_HEADER_LENGTH + 2);
+		dev_kfree_skb(skb);
+		privptr->stats.tx_dropped++;
+		return 0;
+	}
+
+	/*
+	 * If channels are not running, try to restart them
+	 * and throw away packet.
+	 */
+	if (fsm_getstate(privptr->fsm) != DEV_STATE_RUNNING) {
+		fsm_event(privptr->fsm, DEV_EVENT_START, dev);
+		dev_kfree_skb(skb);
+		privptr->stats.tx_dropped++;
+		privptr->stats.tx_errors++;
+		privptr->stats.tx_carrier_errors++;
+		return 0;
+	}
+
+	if (ctcm_test_and_set_busy(dev))
+		return -EBUSY;
+
+	dev->trans_start = jiffies;
+	if (ctcm_transmit_skb(privptr->channel[WRITE], skb) != 0)
+		rc = 1;
+	return rc;
+}
+
+/* unmerged MPC variant of ctcm_tx */
+static int ctcmpc_tx(struct sk_buff *skb, struct net_device *dev)
+{
+	int len = 0;
+	struct ctcm_priv *privptr = NULL;
+	struct mpc_group *grpptr  = NULL;
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
+	privptr = (struct ctcm_priv *)dev->priv;
+	grpptr  = privptr->mpcg;
+	/*
+	 * Some sanity checks ...
+	 */
+	if (skb == NULL) {
+		ctcm_pr_warn("ctcmpc: %s: NULL sk_buff passed\n", dev->name);
+		privptr->stats.tx_dropped++;
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
+			privptr->stats.tx_dropped++;
+			privptr->stats.tx_errors++;
+			privptr->stats.tx_carrier_errors++;
+			fsm_event(grpptr->fsm, MPCG_EVENT_INOP, dev);
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
+	if ((fsm_getstate(privptr->fsm) != DEV_STATE_RUNNING) ||
+	   (fsm_getstate(grpptr->fsm) <  MPCG_STATE_XID2INITW)) {
+		dev_kfree_skb_any(skb);
+		printk(KERN_INFO "ctcmpc: %s() DATA RCVD - MPC GROUP "
+		       "NOT ACTIVE - DROPPED\n",
+		       __FUNCTION__);
+		privptr->stats.tx_dropped++;
+		privptr->stats.tx_errors++;
+		privptr->stats.tx_carrier_errors++;
+					goto done;
+	}
+
+	if (ctcm_test_and_set_busy(dev)) {
+		printk(KERN_WARNING "%s:DEVICE ERR - UNRECOVERABLE DATA LOSS\n",
+		       __FUNCTION__);
+		dev_kfree_skb_any(skb);
+		privptr->stats.tx_dropped++;
+		privptr->stats.tx_errors++;
+		privptr->stats.tx_carrier_errors++;
+		fsm_event(grpptr->fsm, MPCG_EVENT_INOP, dev);
+					goto done;
+	}
+
+	dev->trans_start = jiffies;
+	if (ctcmpc_transmit_skb(privptr->channel[WRITE], skb) != 0) {
+		printk(KERN_WARNING "ctcmpc: %s() DEVICE ERROR"
+		       ": Data Lost \n",
+		       __FUNCTION__);
+		printk(KERN_WARNING "ctcmpc: %s() DEVICE ERROR"
+		       " - UNRECOVERABLE DATA LOSS\n",
+		       __FUNCTION__);
+		dev_kfree_skb_any(skb);
+		privptr->stats.tx_dropped++;
+		privptr->stats.tx_errors++;
+		privptr->stats.tx_carrier_errors++;
+		ctcm_clear_busy(dev);
+		fsm_event(grpptr->fsm, MPCG_EVENT_INOP, dev);
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
+ * @param dev     Pointer to interface struct.
+ * @param new_mtu The new MTU to use for this interface.
+ *
+ * @return 0 on success, -EINVAL if MTU is out of valid range.
+ *         (valid range is 576 .. 65527). If VM is on the
+ *         remote side, maximum MTU is 32760, however this is
+ *         <em>not</em> checked here.
+ */
+static int ctcm_change_mtu(struct net_device *dev, int new_mtu)
+{
+	struct ctcm_priv *privptr;
+	int max_bufsize;
+
+	CTCM_DBF_TEXT(SETUP, CTC_DBF_INFO, __FUNCTION__);
+
+	if (new_mtu < 576 || new_mtu > 65527)
+		return -EINVAL;
+
+	privptr = (struct ctcm_priv *)dev->priv;
+	max_bufsize = privptr->channel[READ]->max_bufsize;
+
+	if (IS_MPC(privptr)) {
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
+ * @param dev Pointer to interface struct.
+ *
+ * @return Pointer to stats struct of this interface.
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
+	struct ctcm_priv *privptr;
+	struct mpc_group *grpptr;
+
+	CTCM_DBF_TEXT(SETUP, CTC_DBF_INFO, __FUNCTION__);
+
+	if (!dev)
+		return;
+	privptr = dev->priv;
+	if (privptr) {
+		grpptr = privptr->mpcg;
+		if (grpptr) {
+			if (grpptr->fsm)
+				kfree_fsm(grpptr->fsm);
+			if (grpptr->xid_skb)
+				dev_kfree_skb(grpptr->xid_skb);
+			if (grpptr->rcvd_xid_skb)
+				dev_kfree_skb(grpptr->rcvd_xid_skb);
+			tasklet_kill(&grpptr->mpc_tasklet2);
+			kfree(grpptr);
+			privptr->mpcg = NULL;
+		}
+		if (privptr->fsm) {
+			kfree_fsm(privptr->fsm);
+			privptr->fsm = NULL;
+		}
+		kfree(privptr->xid);
+		privptr->xid = NULL;
+	/*
+	 * Note: kfree(privptr); is done in "opposite" function of
+	 * allocator function probe_device which is remove_device.
+	 */
+	}
+#ifdef MODULE
+	free_netdev(dev);
+#endif
+}
+
+struct mpc_group *ctcmpc_init_mpc_group(struct ctcm_priv *privptr);
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
+static struct net_device *ctcm_init_netdevice(struct ctcm_priv *privptr)
+{
+	struct net_device *dev;
+	struct mpc_group *grpptr;
+	if (!privptr)
+		return NULL;
+
+	if (IS_MPC(privptr))
+		dev = alloc_netdev(0, MPC_DEVICE_GENE, ctcm_dev_setup);
+	else
+		dev = alloc_netdev(0, CTC_DEVICE_GENE, ctcm_dev_setup);
+
+	if (!dev) {
+		ctcm_pr_err("%s: Out of memory\n", __FUNCTION__);
+		return NULL;
+	}
+	dev->priv = privptr;
+	privptr->fsm = init_fsm("ctcmdev", dev_state_names, dev_event_names,
+				CTCM_NR_DEV_STATES, CTCM_NR_DEV_EVENTS,
+				dev_fsm, dev_fsm_len, GFP_KERNEL);
+	if (privptr->fsm == NULL) {
+		CTCMY_DBF_DEV(SETUP, dev, "init_fsm error");
+		kfree(dev);
+		return NULL;
+	}
+	fsm_newstate(privptr->fsm, DEV_STATE_STOPPED);
+	fsm_settimer(privptr->fsm, &privptr->restart_timer);
+
+	if (IS_MPC(privptr)) {
+		/*  MPC Group Initializations  */
+		grpptr = ctcmpc_init_mpc_group(privptr);
+		if (grpptr == NULL) {
+			MPC_DBF_DEV(SETUP, dev, "init_mpc_group error");
+			kfree(dev);
+			return NULL;
+		}
+		tasklet_init(&grpptr->mpc_tasklet2,
+				mpc_group_ready, (unsigned long)dev);
+		dev->mtu = MPC_BUFSIZE_DEFAULT -
+				TH_HEADER_LENGTH - PDU_HEADER_LENGTH;
+
+		dev->hard_start_xmit = ctcmpc_tx;
+		dev->hard_header_len = TH_HEADER_LENGTH + PDU_HEADER_LENGTH;
+		privptr->buffer_size = MPC_BUFSIZE_DEFAULT;
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
+ * @param cdev    The ccw_device the interrupt is for.
+ * @param intparm interruption parameter.
+ * @param irb     interruption response block.
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
+ * @param cgdev pointer to ccwgroup_device just added
+ *
+ * @returns 0 on success, !0 on failure.
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
+ * @param cdev  The ccw_device to be added.
+ * @param type  The type class of the new channel.
+ * @param priv  Points to the private data of the ccwgroup_device.
+ *
+ * @return 0 on success, !0 on error.
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
+ * @param cgdev  Device to be setup.
+ *
+ * @returns 0 on success, !0 on failure.
+ */
+static int ctcm_new_device(struct ccwgroup_device *cgdev)
+{
+	char read_id[CTCM_ID_SIZE];
+	char write_id[CTCM_ID_SIZE];
+	int direction;
+	enum channel_types type;
+	struct ctcm_priv *privptr;
+	struct net_device *dev;
+	int ret;
+
+	CTCM_DBF_TEXT(SETUP, CTC_DBF_INFO, __FUNCTION__);
+
+	privptr = dev_get_drvdata(&cgdev->dev);
+	if (!privptr)
+		return -ENODEV;
+
+	type = get_channel_type(&cgdev->cdev[0]->id);
+
+	snprintf(read_id, CTCM_ID_SIZE, "ch-%s", cgdev->cdev[0]->dev.bus_id);
+	snprintf(write_id, CTCM_ID_SIZE, "ch-%s", cgdev->cdev[1]->dev.bus_id);
+
+	ret = add_channel(cgdev->cdev[0], type, privptr);
+	if (ret)
+		return ret;
+	ret = add_channel(cgdev->cdev[1], type, privptr);
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
+	dev = ctcm_init_netdevice(privptr);
+
+	if (dev == NULL) {
+		ctcm_pr_warn("ctcm_init_netdevice failed\n");
+					goto out;
+	}
+
+	for (direction = READ; direction <= WRITE; direction++) {
+		privptr->channel[direction] =
+		    channel_get(type, direction == READ ? read_id : write_id,
+				direction);
+		if (privptr->channel[direction] == NULL) {
+			if (direction == WRITE)
+				channel_free(privptr->channel[READ]);
+			ctcm_free_netdevice(dev);
+					goto out;
+		}
+		privptr->channel[direction]->netdev = dev;
+		privptr->channel[direction]->protocol = privptr->protocol;
+		privptr->channel[direction]->max_bufsize = privptr->buffer_size;
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
+	strlcpy(privptr->fsm->name, dev->name, sizeof(privptr->fsm->name));
+
+	CTCM_DBF_TEXT_(SETUP, CTC_DBF_INFO,
+			"setup(%s) ok : r/w = %s / %s, proto : %d",
+			dev->name, privptr->channel[READ]->id,
+			privptr->channel[WRITE]->id, privptr->protocol);
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
+ * @param cgdev  Device to be shut down.
+ *
+ * @returns 0 on success, !0 on failure.
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
+ * <em>not</em> called, if the usage count is !0, so we don't need to check
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
+ * @return 0 on success, !0 on error.
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
+	struct mpc_group *grpptr;
+	grpptr = ((struct ctcm_priv *)dev->priv)->mpcg;
+
+	if (!(grpptr && grpptr->in_sweep))
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
+struct mpc_group *ctcmpc_init_mpc_group(struct ctcm_priv *privptr);
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

-- 
