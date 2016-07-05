From: Tom Herbert <tom@herbertland.com>
Subject: [RFC PATCH 1/2] strparser: Stream parser for messages
Date: Tue, 5 Jul 2016 12:03:33 -0700
Message-ID: <1467745414-2763835-2-git-send-email-tom@herbertland.com>
References: <1467745414-2763835-1-git-send-email-tom@herbertland.com>
Mime-Version: 1.0
Content-Type: text/plain
Cc: <kernel-team@fb.com>
To: <davem@davemloft.net>, <netdev@vger.kernel.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mx0a-00082601.pphosted.com ([67.231.145.42]:4359 "EHLO
	mx0a-00082601.pphosted.com" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with ESMTP id S1752100AbcGETDq (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 5 Jul 2016 15:03:46 -0400
Received: from pps.filterd (m0044010.ppops.net [127.0.0.1])
	by mx0a-00082601.pphosted.com (8.16.0.11/8.16.0.11) with SMTP id u65J21EZ023597
	for <netdev@vger.kernel.org>; Tue, 5 Jul 2016 12:03:45 -0700
Received: from mail.thefacebook.com ([199.201.64.23])
	by mx0a-00082601.pphosted.com with ESMTP id 240jkxg1pf-2
	(version=TLSv1 cipher=ECDHE-RSA-AES256-SHA bits=256 verify=NOT)
	for <netdev@vger.kernel.org>; Tue, 05 Jul 2016 12:03:45 -0700
Received: from devbig284.prn2.facebook.com (10.35.15.32)	by
 mx-out.facebook.com (10.223.100.99) with ESMTP	id
 31c092e042e311e6896f24be05956610-4b4f8af0 for <netdev@vger.kernel.org>;	Tue,
 05 Jul 2016 12:03:44 -0700
In-Reply-To: <1467745414-2763835-1-git-send-email-tom@herbertland.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

This patch introduces a utility for parsing application layer protocol
messages in a TCP stream. This is a generalization of the mechanism
implemented of Kernel Connection Multiplexor.

The API includes a context structure, a set of callbacks, utility
functions, and a data ready function.

A stream parser instance is defined by a strparse structure that
is bound to a TCP socket. The function to initialize the structure
is:

int strp_init(struct strparser *strp, struct sock *csk,
              struct strp_callbacks *cb);

csk is the TCP socket being bound to and cb are the parser callbacks.

A parser is bound to a TCP socket by setting data_ready function to
strp_tcp_data_ready so that all receive indications on the socket
go through the parser. This is assumes that sk_user_data is set to
the strparser structure.

There are four callbacks.
 - parse_msg is called to parse the message (returns length or error).
 - rcv_msg is called when a complete message has been received
 - read_sock_done is called when data_ready function exits
 - abort_parser is called to abort the parser

The input to parse_msg is an skbuff which contains next message under
construction. The backend processing of parse_msg will parse the
application layer protocol headers to determine the length of
the message in the stream. The possible return values are:

   >0 : indicates length of successfully parsed message
   0  : indicates more data must be received to parse the message
   -ESTRPIPE : current message should not be processed by the
      kernel, return control of the socket to userspace which
      can proceed to read the messages itself
   other < 0 : Error is parsing, give control back to userspace
      assuming that synchronzation is lost and the stream
      is unrecoverable (application expected to close TCP socket)

In the case of error return (< 0) strparse will stop the parser
and report and error to userspace. The application must deal
with the error. To handle the error the strparser is unbound
from the TCP socket. If the error indicates that the stream
TCP socket is at recoverable point (ESTRPIPE) then the application
can read the TCP socket to process the stream. Once the application
has dealt with the exceptions in the stream, it may again bind the
socket to a strparser to continue data operations.

Note that ENODATA may be returned to the application. In this case
parse_msg returned -ESTRPIPE, however strparser was unable to maintain
synchronization of the stream (i.e. some of the message in question
was already read by the parser).

strp_pause and strp_unpause are used to provide flow control. For
instance, if rcv_msg is called but the upper layer can't immediately
consume the message it can hold the message and pause strparser.

Returns values from rcv_msg callback are:
   0  : message was consumed and strparser can continue to parse the
       next message
   !0 : message is held by uppoer layer, strparser cannot proceed to
       parse the next message. The upper layer should also do
       strp_pause to prevent strparser from proceeding until
       the held message is cleared

Signed-off-by: Tom Herbert <tom@herbertland.com>
---
 include/net/strparser.h   | 146 ++++++++++++++
 net/Kconfig               |   1 +
 net/Makefile              |   1 +
 net/strparser/Kconfig     |   4 +
 net/strparser/Makefile    |   1 +
 net/strparser/strparser.c | 472 ++++++++++++++++++++++++++++++++++++++++++++++
 6 files changed, 625 insertions(+)
 create mode 100644 include/net/strparser.h
 create mode 100644 net/strparser/Kconfig
 create mode 100644 net/strparser/Makefile
 create mode 100644 net/strparser/strparser.c

diff --git a/include/net/strparser.h b/include/net/strparser.h
new file mode 100644
index 0000000..ef372d5
--- /dev/null
+++ b/include/net/strparser.h
@@ -0,0 +1,146 @@
+/*
+ * Stream Parser
+ *
+ * Copyright (c) 2016 Tom Herbert <tom@herbertland.com>
+ *
+ * This program is free software; you can redistribute it and/or modify
+ * it under the terms of the GNU General Public License version 2
+ * as published by the Free Software Foundation.
+ */
+
+#ifndef __NET_STRPARSER_H_
+#define __NET_STRPARSER_H_
+
+#include <linux/skbuff.h>
+#include <net/sock.h>
+
+#define STRP_STATS_ADD(stat, count) ((stat) += (count))
+#define STRP_STATS_INCR(stat) ((stat)++)
+
+struct strp_stats {
+	unsigned long long rx_msgs;
+	unsigned long long rx_bytes;
+	unsigned int rx_mem_fail;
+	unsigned int rx_need_more_hdr;
+	unsigned int rx_msg_too_big;
+	unsigned int rx_msg_timeouts;
+	unsigned int rx_bad_hdr_len;
+};
+
+struct strp_aggr_stats {
+	unsigned long long rx_msgs;
+	unsigned long long rx_bytes;
+	unsigned int rx_mem_fail;
+	unsigned int rx_need_more_hdr;
+	unsigned int rx_msg_too_big;
+	unsigned int rx_msg_timeouts;
+	unsigned int rx_bad_hdr_len;
+	unsigned int rx_aborts;
+	unsigned int rx_interrupted;
+	unsigned int rx_unrecov_intr;
+};
+
+struct strp_rx_msg {
+	int full_len;
+	int accum_len;
+	int offset;
+	int early_eaten;
+};
+
+static inline struct strp_rx_msg *strp_rx_msg(struct sk_buff *skb)
+{
+	return (struct strp_rx_msg *)((void *)skb->cb +
+	       offsetof(struct qdisc_skb_cb, data));
+}
+
+struct strparser;
+
+struct strp_callbacks {
+	int (*parse_msg)(struct strparser *strp, struct sk_buff *skb);
+	int (*rcv_msg)(struct strparser *strp, struct sk_buff *skb);
+	int (*read_sock_done)(struct strparser *strp, int err);
+	void (*abort_parser)(struct strparser *strp, int err);
+};
+
+/* Structure for an attached lower socket */
+struct strparser {
+	struct sock *sk;
+
+	u32 rx_stopped : 1;
+	u32 rx_paused : 1;
+	u32 rx_aborted : 1;
+	u32 rx_interrupted : 1;
+	u32 rx_unrecov_intr : 1;
+
+	struct sk_buff **rx_skb_nextp;
+	struct timer_list rx_msg_timer;
+	struct sk_buff *rx_skb_head;
+	unsigned int rx_need_bytes;
+	struct delayed_work rx_delayed_work;
+	struct work_struct rx_work;
+	struct strp_stats stats;
+	struct strp_callbacks cb;
+};
+
+static inline void strp_pause(struct strparser *strp)
+{
+	strp->rx_paused = 1;
+}
+
+static inline void strp_unpause(struct strparser *strp)
+{
+	strp->rx_paused = 0;
+}
+
+static inline void save_strp_stats(struct strparser *strp,
+				   struct strp_aggr_stats *agg_stats)
+{
+	/* Save psock statistics in the mux when psock is being unattached. */
+
+#define SAVE_PSOCK_STATS(_stat) (agg_stats->_stat +=		\
+				 strp->stats._stat)
+	SAVE_PSOCK_STATS(rx_msgs);
+	SAVE_PSOCK_STATS(rx_bytes);
+	SAVE_PSOCK_STATS(rx_mem_fail);
+	SAVE_PSOCK_STATS(rx_need_more_hdr);
+	SAVE_PSOCK_STATS(rx_msg_too_big);
+	SAVE_PSOCK_STATS(rx_msg_timeouts);
+	SAVE_PSOCK_STATS(rx_bad_hdr_len);
+#undef SAVE_PSOCK_STATS
+
+	if (strp->rx_aborted)
+		agg_stats->rx_aborts++;
+	if (strp->rx_interrupted)
+		agg_stats->rx_interrupted++;
+	if (strp->rx_unrecov_intr)
+		agg_stats->rx_unrecov_intr++;
+}
+
+static inline void aggregate_strp_stats(struct strp_aggr_stats *stats,
+					struct strp_aggr_stats *agg_stats)
+{
+#define SAVE_PSOCK_STATS(_stat) (agg_stats->_stat += stats->_stat)
+	SAVE_PSOCK_STATS(rx_msgs);
+	SAVE_PSOCK_STATS(rx_bytes);
+	SAVE_PSOCK_STATS(rx_mem_fail);
+	SAVE_PSOCK_STATS(rx_need_more_hdr);
+	SAVE_PSOCK_STATS(rx_msg_too_big);
+	SAVE_PSOCK_STATS(rx_msg_timeouts);
+	SAVE_PSOCK_STATS(rx_bad_hdr_len);
+	SAVE_PSOCK_STATS(rx_aborts);
+	SAVE_PSOCK_STATS(rx_interrupted);
+	SAVE_PSOCK_STATS(rx_unrecov_intr);
+#undef SAVE_PSOCK_STATS
+
+}
+
+void strp_done(struct strparser *strp);
+void strp_stop(struct strparser *strp);
+void strp_check_rcv(struct strparser *strp);
+int strp_init(struct strparser *strp, struct sock *csk,
+	      struct strp_callbacks *cb);
+
+void strp_tcp_data_ready(struct sock *sk);
+
+
+#endif /* __NET_STRPARSER_H_ */
diff --git a/net/Kconfig b/net/Kconfig
index ff40562..ac48707 100644
--- a/net/Kconfig
+++ b/net/Kconfig
@@ -368,6 +368,7 @@ source "net/irda/Kconfig"
 source "net/bluetooth/Kconfig"
 source "net/rxrpc/Kconfig"
 source "net/kcm/Kconfig"
+source "net/strparser/Kconfig"
 
 config FIB_RULES
 	bool
diff --git a/net/Makefile b/net/Makefile
index bdd1455..be48b30 100644
--- a/net/Makefile
+++ b/net/Makefile
@@ -35,6 +35,7 @@ obj-$(CONFIG_BT)		+= bluetooth/
 obj-$(CONFIG_SUNRPC)		+= sunrpc/
 obj-$(CONFIG_AF_RXRPC)		+= rxrpc/
 obj-$(CONFIG_AF_KCM)		+= kcm/
+obj-$(CONFIG_STREAM_PARSER)	+= strparser/
 obj-$(CONFIG_ATM)		+= atm/
 obj-$(CONFIG_L2TP)		+= l2tp/
 obj-$(CONFIG_DECNET)		+= decnet/
diff --git a/net/strparser/Kconfig b/net/strparser/Kconfig
new file mode 100644
index 0000000..6cff3f6
--- /dev/null
+++ b/net/strparser/Kconfig
@@ -0,0 +1,4 @@
+
+config STREAM_PARSER
+	tristate
+	default n
diff --git a/net/strparser/Makefile b/net/strparser/Makefile
new file mode 100644
index 0000000..858a126
--- /dev/null
+++ b/net/strparser/Makefile
@@ -0,0 +1 @@
+obj-$(CONFIG_STREAM_PARSER) += strparser.o
diff --git a/net/strparser/strparser.c b/net/strparser/strparser.c
new file mode 100644
index 0000000..6ac3c89
--- /dev/null
+++ b/net/strparser/strparser.c
@@ -0,0 +1,472 @@
+#include <linux/bpf.h>
+#include <linux/errno.h>
+#include <linux/errqueue.h>
+#include <linux/file.h>
+#include <linux/in.h>
+#include <linux/kernel.h>
+#include <linux/module.h>
+#include <linux/net.h>
+#include <linux/netdevice.h>
+#include <linux/poll.h>
+#include <linux/rculist.h>
+#include <linux/skbuff.h>
+#include <linux/socket.h>
+#include <linux/uaccess.h>
+#include <linux/workqueue.h>
+#include <net/strparser.h>
+#include <net/netns/generic.h>
+#include <net/sock.h>
+#include <net/tcp.h>
+
+static struct workqueue_struct *strp_wq;
+
+static void report_csk_error(struct sock *csk, int err)
+{
+	csk->sk_err = EPIPE;
+	csk->sk_error_report(csk);
+}
+
+/* Callback lock held */
+static void strp_abort_rx_strp(struct strparser *strp, int err)
+{
+	struct sock *csk = strp->sk;
+
+	/* Unrecoverable error in receive */
+
+	del_timer(&strp->rx_msg_timer);
+
+	if (strp->rx_stopped)
+		return;
+
+	strp->rx_stopped = 1;
+	strp->rx_aborted = 1;
+
+	/* Report an error on the lower socket */
+	report_csk_error(csk, err);
+}
+
+static void strp_start_rx_timer(struct strparser *strp)
+{
+	if (strp->sk->sk_rcvtimeo)
+		mod_timer(&strp->rx_msg_timer, strp->sk->sk_rcvtimeo);
+}
+
+void strp_parser_err(struct strparser *strp, int err, read_descriptor_t *desc)
+{
+	desc->error = err;
+	kfree_skb(strp->rx_skb_head);
+	strp->rx_skb_head = NULL;
+	strp_abort_rx_strp(strp, err);
+}
+
+/* Lower socket lock held */
+static int strp_tcp_recv(read_descriptor_t *desc, struct sk_buff *orig_skb,
+			 unsigned int orig_offset, size_t orig_len)
+{
+	struct strparser *strp = (struct strparser *)desc->arg.data;
+	struct strp_rx_msg *rxm;
+	struct sk_buff *head, *skb;
+	size_t eaten = 0, cand_len;
+	ssize_t extra;
+	int err;
+	bool cloned_orig = false;
+
+	if (strp->rx_paused)
+		return 0;
+
+	head = strp->rx_skb_head;
+	if (head) {
+		/* Message already in progress */
+
+		rxm = strp_rx_msg(head);
+		if (unlikely(rxm->early_eaten)) {
+			/* Already some number of bytes on the receive sock
+			 * data saved in rx_skb_head, just indicate they
+			 * are consumed.
+			 */
+			eaten = orig_len <= rxm->early_eaten ?
+				orig_len : rxm->early_eaten;
+			rxm->early_eaten -= eaten;
+
+			return eaten;
+		}
+
+		if (unlikely(orig_offset)) {
+			/* Getting data with a non-zero offset when a message is
+			 * in progress is not expected. If it does happen, we
+			 * need to clone and pull since we can't deal with
+			 * offsets in the skbs for a message expect in the head.
+			 */
+			orig_skb = skb_clone(orig_skb, GFP_ATOMIC);
+			if (!orig_skb) {
+				STRP_STATS_INCR(strp->stats.rx_mem_fail);
+				desc->error = -ENOMEM;
+				return 0;
+			}
+			if (!pskb_pull(orig_skb, orig_offset)) {
+				STRP_STATS_INCR(strp->stats.rx_mem_fail);
+				kfree_skb(orig_skb);
+				desc->error = -ENOMEM;
+				return 0;
+			}
+			cloned_orig = true;
+			orig_offset = 0;
+		}
+
+		if (!strp->rx_skb_nextp) {
+			/* We are going to append to the frags_list of head.
+			 * Need to unshare the frag_list.
+			 */
+			err = skb_unclone(head, GFP_ATOMIC);
+			if (err) {
+				STRP_STATS_INCR(strp->stats.rx_mem_fail);
+				desc->error = err;
+				return 0;
+			}
+
+			if (unlikely(skb_shinfo(head)->frag_list)) {
+				/* We can't append to an sk_buff that already
+				 * has a frag_list. We create a new head, point
+				 * the frag_list of that to the old head, and
+				 * then are able to use the old head->next for
+				 * appending to the message.
+				 */
+				if (WARN_ON(head->next)) {
+					desc->error = -EINVAL;
+					return 0;
+				}
+
+				skb = alloc_skb(0, GFP_ATOMIC);
+				if (!skb) {
+					STRP_STATS_INCR(strp->stats.rx_mem_fail);
+					desc->error = -ENOMEM;
+					return 0;
+				}
+				skb->len = head->len;
+				skb->data_len = head->len;
+				skb->truesize = head->truesize;
+				*strp_rx_msg(skb) = *strp_rx_msg(head);
+				strp->rx_skb_nextp = &head->next;
+				skb_shinfo(skb)->frag_list = head;
+				strp->rx_skb_head = skb;
+				head = skb;
+			} else {
+				strp->rx_skb_nextp =
+				    &skb_shinfo(head)->frag_list;
+			}
+		}
+	}
+
+	while (eaten < orig_len) {
+		/* Always clone since we will consume something */
+		skb = skb_clone(orig_skb, GFP_ATOMIC);
+		if (!skb) {
+			STRP_STATS_INCR(strp->stats.rx_mem_fail);
+			desc->error = -ENOMEM;
+			break;
+		}
+
+		cand_len = orig_len - eaten;
+
+		head = strp->rx_skb_head;
+		if (!head) {
+			head = skb;
+			strp->rx_skb_head = head;
+			/* Will set rx_skb_nextp on next packet if needed */
+			strp->rx_skb_nextp = NULL;
+			rxm = strp_rx_msg(head);
+			memset(rxm, 0, sizeof(*rxm));
+			rxm->offset = orig_offset + eaten;
+		} else {
+			/* Unclone since we may be appending to an skb that we
+			 * already share a frag_list with.
+			 */
+			err = skb_unclone(skb, GFP_ATOMIC);
+			if (err) {
+				STRP_STATS_INCR(strp->stats.rx_mem_fail);
+				desc->error = err;
+				break;
+			}
+
+			rxm = strp_rx_msg(head);
+			*strp->rx_skb_nextp = skb;
+			strp->rx_skb_nextp = &skb->next;
+			head->data_len += skb->len;
+			head->len += skb->len;
+			head->truesize += skb->truesize;
+		}
+
+		if (!rxm->full_len) {
+			ssize_t len;
+
+			len = (*strp->cb.parse_msg)(strp, skb);
+
+			if (!len) {
+				/* Need more header to determine length */
+				if (!rxm->accum_len) {
+					/* Start RX timer for new message */
+					strp_start_rx_timer(strp);
+				}
+				rxm->accum_len += cand_len;
+				eaten += cand_len;
+				STRP_STATS_INCR(strp->stats.rx_need_more_hdr);
+				WARN_ON(eaten != orig_len);
+				break;
+			} else if (len < 0) {
+				if (len == -ESTRPIPE && rxm->accum_len) {
+					len = -ENODATA;
+					strp->rx_unrecov_intr = 1;
+				} else {
+					strp->rx_interrupted = 1;
+				}
+				strp_parser_err(strp, err, desc);
+				break;
+			} else if (len > strp->sk->sk_rcvbuf) {
+				/* Message length exceeds maximum allowed */
+				STRP_STATS_INCR(strp->stats.rx_msg_too_big);
+				strp_parser_err(strp, -EMSGSIZE, desc);
+				break;
+			} else if (len <= (ssize_t)head->len -
+					  skb->len - rxm->offset) {
+				/* Length must be into new skb (and also
+				 * greater than zero)
+				 */
+				STRP_STATS_INCR(strp->stats.rx_bad_hdr_len);
+				strp_parser_err(strp, -EPROTO, desc);
+				break;
+			}
+
+			rxm->full_len = len;
+		}
+
+		extra = (ssize_t)(rxm->accum_len + cand_len) - rxm->full_len;
+
+		if (extra < 0) {
+			/* Message not complete yet. */
+			if (rxm->full_len - rxm->accum_len >
+			    tcp_inq(strp->sk)) {
+				/* Don't have the whole messages in the socket
+				 * buffer. Set strp->rx_need_bytes to wait for
+				 * the rest of the message. Also, set "early
+				 * eaten" since we've already buffered the skb
+				 * but don't consume yet per tcp_read_sock.
+				 */
+
+				if (!rxm->accum_len) {
+					/* Start RX timer for new message */
+					strp_start_rx_timer(strp);
+				}
+
+				strp->rx_need_bytes = rxm->full_len -
+						       rxm->accum_len;
+				rxm->accum_len += cand_len;
+				rxm->early_eaten = cand_len;
+				STRP_STATS_ADD(strp->stats.rx_bytes, cand_len);
+				desc->count = 0; /* Stop reading socket */
+				break;
+			}
+			rxm->accum_len += cand_len;
+			eaten += cand_len;
+			WARN_ON(eaten != orig_len);
+			break;
+		}
+
+		/* Positive extra indicates ore bytes than needed for the
+		 * message
+		 */
+
+		WARN_ON(extra > cand_len);
+
+		eaten += (cand_len - extra);
+
+		/* Hurray, we have a new message! */
+		del_timer(&strp->rx_msg_timer);
+		strp->rx_skb_head = NULL;
+		STRP_STATS_INCR(strp->stats.rx_msgs);
+
+		if (strp->cb.rcv_msg(strp, head)) {
+			/* Upper layer held message and pause strp */
+			break;
+		}
+	}
+
+	if (cloned_orig)
+		kfree_skb(orig_skb);
+
+	STRP_STATS_ADD(strp->stats.rx_bytes, eaten);
+
+	return eaten;
+}
+
+static int default_read_sock_done(struct strparser *strp, int err)
+{
+	return err;
+}
+
+/* Called with lock held on lower socket */
+static int strp_tcp_read_sock(struct strparser *strp)
+{
+	read_descriptor_t desc;
+
+	desc.arg.data = strp;
+	desc.error = 0;
+	desc.count = 1; /* give more than one skb per call */
+
+	/* sk should be locked here, so okay to do tcp_read_sock */
+	tcp_read_sock(strp->sk, &desc, strp_tcp_recv);
+
+	desc.error = strp->cb.read_sock_done(strp, desc.error);
+
+	return desc.error;
+}
+
+/* Lower sock lock held */
+void strp_tcp_data_ready(struct sock *sk)
+{
+	struct strparser *strp;
+
+	read_lock_bh(&sk->sk_callback_lock);
+
+	strp = (struct strparser *)sk->sk_user_data;
+	if (unlikely(!strp || strp->rx_stopped))
+		goto out;
+
+	if (strp->rx_paused)
+		goto out;
+
+	if (strp->rx_need_bytes) {
+		if (tcp_inq(sk) >= strp->rx_need_bytes)
+			strp->rx_need_bytes = 0;
+		else
+			goto out;
+	}
+
+	if (strp_tcp_read_sock(strp) == -ENOMEM)
+		queue_delayed_work(strp_wq, &strp->rx_delayed_work, 0);
+
+out:
+	read_unlock_bh(&sk->sk_callback_lock);
+}
+EXPORT_SYMBOL(strp_tcp_data_ready);
+
+static void do_strp_rx_work(struct strparser *strp)
+{
+	read_descriptor_t rd_desc;
+	struct sock *csk = strp->sk;
+
+	/* We need the read lock to synchronize with strp_tcp_data_ready. We
+	 * need the socket lock for calling tcp_read_sock.
+	 */
+	lock_sock(csk);
+	read_lock_bh(&csk->sk_callback_lock);
+
+	if (unlikely(csk->sk_user_data != strp))
+		goto out;
+
+	if (unlikely(strp->rx_stopped))
+		goto out;
+
+	if (strp->rx_paused)
+		goto out;
+
+	rd_desc.arg.data = strp;
+
+	if (strp_tcp_read_sock(strp) == -ENOMEM)
+		queue_delayed_work(strp_wq, &strp->rx_delayed_work, 0);
+
+out:
+	read_unlock_bh(&csk->sk_callback_lock);
+	release_sock(csk);
+}
+
+static void strp_rx_work(struct work_struct *w)
+{
+	do_strp_rx_work(container_of(w, struct strparser, rx_work));
+}
+
+static void strp_rx_delayed_work(struct work_struct *w)
+{
+	do_strp_rx_work(container_of(w, struct strparser,
+				     rx_delayed_work.work));
+}
+
+static void strp_rx_msg_timeout(unsigned long arg)
+{
+	struct strparser *strp = (struct strparser *)arg;
+
+	/* Message assembly timed out */
+	STRP_STATS_INCR(strp->stats.rx_msg_timeouts);
+	strp_abort_rx_strp(strp, ETIMEDOUT);
+}
+
+void strp_queue_work(struct strparser *strp)
+{
+	queue_work(strp_wq, &strp->rx_work);
+}
+
+int strp_init(struct strparser *strp, struct sock *csk,
+	      struct strp_callbacks *cb)
+{
+	if (!cb || !cb->rcv_msg || !cb->parse_msg)
+		return -EINVAL;
+
+	memset(strp, 0, sizeof(*strp));
+
+	strp->sk = csk;
+
+	setup_timer(&strp->rx_msg_timer, strp_rx_msg_timeout,
+		    (unsigned long)strp);
+
+	INIT_WORK(&strp->rx_work, strp_rx_work);
+	INIT_DELAYED_WORK(&strp->rx_delayed_work, strp_rx_delayed_work);
+
+	strp->cb.rcv_msg = cb->rcv_msg;
+	strp->cb.parse_msg = cb->parse_msg;
+	strp->cb.read_sock_done = cb->read_sock_done ? : default_read_sock_done;
+	strp->cb.abort_parser = cb->abort_parser ? : strp_abort_rx_strp;
+
+	return 0;
+}
+EXPORT_SYMBOL(strp_init);
+
+void strp_done(struct strparser *strp)
+{
+	del_timer_sync(&strp->rx_msg_timer);
+	cancel_work_sync(&strp->rx_work);
+	cancel_delayed_work_sync(&strp->rx_delayed_work);
+
+	if (strp->rx_skb_head) {
+		strp->rx_aborted = 1;
+		kfree_skb(strp->rx_skb_head);
+		strp->rx_skb_head = NULL;
+	}
+}
+EXPORT_SYMBOL(strp_done);
+
+void strp_stop(struct strparser *strp)
+{
+	strp->rx_stopped = 1;
+}
+EXPORT_SYMBOL(strp_stop);
+
+void strp_check_rcv(struct strparser *strp)
+{
+	queue_work(strp_wq, &strp->rx_work);
+}
+EXPORT_SYMBOL(strp_check_rcv);
+
+static int __init strp_mod_init(void)
+{
+	strp_wq = create_singlethread_workqueue("kstrp");
+
+	return 0;
+}
+
+static void __exit strp_mod_exit(void)
+{
+}
+module_init(strp_mod_init);
+module_exit(strp_mod_exit);
+
+MODULE_LICENSE("GPL");
+
-- 
2.8.0.rc2
