From: Tom Parkin <tparkin@katalix.com>
Subject: [PATCH 08/12] l2tp: add session reorder queue purge function to core
Date: Tue, 19 Mar 2013 16:11:19 +0000
Message-ID: <1363709483-24021-9-git-send-email-tparkin@katalix.com>
References: <1363709483-24021-1-git-send-email-tparkin@katalix.com>
Cc: Tom Parkin <tparkin@katalix.com>,
	James Chapman <jchapman@katalix.com>
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from katalix.com ([82.103.140.233]:36145 "EHLO bert.katalix.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S932861Ab3CSQLc (ORCPT <rfc822;netdev@vger.kernel.org>);
	Tue, 19 Mar 2013 12:11:32 -0400
In-Reply-To: <1363709483-24021-1-git-send-email-tparkin@katalix.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

If an l2tp session is deleted, it is necessary to delete skbs in-flight
on the session's reorder queue before taking it down.

Rather than having each pseudowire implementation reaching into the
l2tp_session struct to handle this itself, provide a function in l2tp_core to
purge the session queue.

Signed-off-by: Tom Parkin <tparkin@katalix.com>
Signed-off-by: James Chapman <jchapman@katalix.com>
---
 net/l2tp/l2tp_core.c |   17 +++++++++++++++++
 net/l2tp/l2tp_core.h |    1 +
 2 files changed, 18 insertions(+)

diff --git a/net/l2tp/l2tp_core.c b/net/l2tp/l2tp_core.c
index e841ef2..69c316d 100644
--- a/net/l2tp/l2tp_core.c
+++ b/net/l2tp/l2tp_core.c
@@ -829,6 +829,23 @@ discard:
 }
 EXPORT_SYMBOL(l2tp_recv_common);
 
+/* Drop skbs from the session's reorder_q
+ */
+int l2tp_session_queue_purge(struct l2tp_session *session)
+{
+	struct sk_buff *skb = NULL;
+	BUG_ON(!session);
+	BUG_ON(session->magic != L2TP_SESSION_MAGIC);
+	while ((skb = skb_dequeue(&session->reorder_q))) {
+		atomic_long_inc(&session->stats.rx_errors);
+		kfree_skb(skb);
+		if (session->deref)
+			(*session->deref)(session);
+	}
+	return 0;
+}
+EXPORT_SYMBOL_GPL(l2tp_session_queue_purge);
+
 /* Internal UDP receive frame. Do the real work of receiving an L2TP data frame
  * here. The skb is not on a list when we get here.
  * Returns 0 if the packet was a data packet and was successfully passed on.
diff --git a/net/l2tp/l2tp_core.h b/net/l2tp/l2tp_core.h
index b0861f6..d40713d 100644
--- a/net/l2tp/l2tp_core.h
+++ b/net/l2tp/l2tp_core.h
@@ -246,6 +246,7 @@ extern struct l2tp_session *l2tp_session_create(int priv_size, struct l2tp_tunne
 extern int l2tp_session_delete(struct l2tp_session *session);
 extern void l2tp_session_free(struct l2tp_session *session);
 extern void l2tp_recv_common(struct l2tp_session *session, struct sk_buff *skb, unsigned char *ptr, unsigned char *optr, u16 hdrflags, int length, int (*payload_hook)(struct sk_buff *skb));
+extern int l2tp_session_queue_purge(struct l2tp_session *session);
 extern int l2tp_udp_encap_recv(struct sock *sk, struct sk_buff *skb);
 
 extern int l2tp_xmit_skb(struct l2tp_session *session, struct sk_buff *skb, int hdr_len);
-- 
1.7.9.5
