From: Tom Herbert <tom@herbertland.com>
Subject: [PATCH v2 net-next 12/13] kcm: Add receive message timeout
Date: Mon, 7 Mar 2016 14:11:11 -0800
Message-ID: <1457388672-2600559-13-git-send-email-tom@herbertland.com>
References: <1457388672-2600559-1-git-send-email-tom@herbertland.com>
Mime-Version: 1.0
Content-Type: text/plain
Cc: <kernel-team@fb.com>
To: <davem@davemloft.net>, <netdev@vger.kernel.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mx0a-00082601.pphosted.com ([67.231.145.42]:60541 "EHLO
	mx0a-00082601.pphosted.com" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with ESMTP id S1753766AbcCGWMT (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 7 Mar 2016 17:12:19 -0500
Received: from pps.filterd (m0044010.ppops.net [127.0.0.1])
	by mx0a-00082601.pphosted.com (8.15.0.59/8.15.0.59) with SMTP id u27MA8vf003229
	for <netdev@vger.kernel.org>; Mon, 7 Mar 2016 14:12:19 -0800
Received: from mail.thefacebook.com ([199.201.64.23])
	by mx0a-00082601.pphosted.com with ESMTP id 21hgcygj9x-1
	(version=TLSv1/SSLv3 cipher=AES128-SHA bits=128 verify=NOT)
	for <netdev@vger.kernel.org>; Mon, 07 Mar 2016 14:12:19 -0800
Received: from devbig284.prn2.facebook.com (10.35.15.32)	by
 mx-out.facebook.com (10.212.236.87) with ESMTP	id
 a7c5318ee4b111e599860002c9521c9e-b91d7420 for <netdev@vger.kernel.org>;	Mon,
 07 Mar 2016 14:12:18 -0800
In-Reply-To: <1457388672-2600559-1-git-send-email-tom@herbertland.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

This patch adds receive timeout for message assembly on the attached TCP
sockets. The timeout is set when a new messages is started and the whole
message has not been received by TCP (not in the receive queue). If the
completely message is subsequently received the timer is cancelled, if the
timer expires the RX side is aborted.

The timeout value is taken from the socket timeout (SO_RCVTIMEO) that is
set on a TCP socket (i.e. set by get sockopt before attaching a TCP socket
to KCM.

Signed-off-by: Tom Herbert <tom@herbertland.com>
---
 include/net/kcm.h |  3 +++
 net/kcm/kcmproc.c |  6 ++++--
 net/kcm/kcmsock.c | 32 ++++++++++++++++++++++++++++++++
 3 files changed, 39 insertions(+), 2 deletions(-)

diff --git a/include/net/kcm.h b/include/net/kcm.h
index d892956..95c425c 100644
--- a/include/net/kcm.h
+++ b/include/net/kcm.h
@@ -29,6 +29,7 @@ struct kcm_psock_stats {
 	unsigned int rx_mem_fail;
 	unsigned int rx_need_more_hdr;
 	unsigned int rx_msg_too_big;
+	unsigned int rx_msg_timeouts;
 	unsigned int rx_bad_hdr_len;
 	unsigned long long reserved;
 	unsigned long long unreserved;
@@ -130,6 +131,7 @@ struct kcm_psock {
 	struct kcm_sock *rx_kcm;
 	unsigned long long saved_rx_bytes;
 	unsigned long long saved_rx_msgs;
+	struct timer_list rx_msg_timer;
 	unsigned int rx_need_bytes;
 
 	/* Transmit */
@@ -194,6 +196,7 @@ static inline void aggregate_psock_stats(struct kcm_psock_stats *stats,
 	SAVE_PSOCK_STATS(rx_mem_fail);
 	SAVE_PSOCK_STATS(rx_need_more_hdr);
 	SAVE_PSOCK_STATS(rx_msg_too_big);
+	SAVE_PSOCK_STATS(rx_msg_timeouts);
 	SAVE_PSOCK_STATS(rx_bad_hdr_len);
 	SAVE_PSOCK_STATS(tx_msgs);
 	SAVE_PSOCK_STATS(tx_bytes);
diff --git a/net/kcm/kcmproc.c b/net/kcm/kcmproc.c
index 7638b35..7380087 100644
--- a/net/kcm/kcmproc.c
+++ b/net/kcm/kcmproc.c
@@ -331,7 +331,7 @@ static int kcm_stats_seq_show(struct seq_file *seq, void *v)
 		   mux_stats.rx_ready_drops);
 
 	seq_printf(seq,
-		   "%-8s %-10s %-16s %-10s %-16s %-10s %-10s %-10s %-10s %-10s %-10s %-10s %-10s\n",
+		   "%-8s %-10s %-16s %-10s %-16s %-10s %-10s %-10s %-10s %-10s %-10s %-10s %-10s %-10s\n",
 		   "Psock",
 		   "RX-Msgs",
 		   "RX-Bytes",
@@ -344,10 +344,11 @@ static int kcm_stats_seq_show(struct seq_file *seq, void *v)
 		   "RX-NeedMor",
 		   "RX-BadLen",
 		   "RX-TooBig",
+		   "RX-Timeout",
 		   "TX-Aborts");
 
 	seq_printf(seq,
-		   "%-8s %-10llu %-16llu %-10llu %-16llu %-10llu %-10llu %-10u %-10u %-10u %-10u %-10u %-10u\n",
+		   "%-8s %-10llu %-16llu %-10llu %-16llu %-10llu %-10llu %-10u %-10u %-10u %-10u %-10u %-10u %-10u\n",
 		   "",
 		   psock_stats.rx_msgs,
 		   psock_stats.rx_bytes,
@@ -360,6 +361,7 @@ static int kcm_stats_seq_show(struct seq_file *seq, void *v)
 		   psock_stats.rx_need_more_hdr,
 		   psock_stats.rx_bad_hdr_len,
 		   psock_stats.rx_msg_too_big,
+		   psock_stats.rx_msg_timeouts,
 		   psock_stats.tx_aborts);
 
 	return 0;
diff --git a/net/kcm/kcmsock.c b/net/kcm/kcmsock.c
index 8bc38d3..40662d73 100644
--- a/net/kcm/kcmsock.c
+++ b/net/kcm/kcmsock.c
@@ -55,6 +55,8 @@ static void kcm_abort_rx_psock(struct kcm_psock *psock, int err,
 
 	/* Unrecoverable error in receive */
 
+	del_timer(&psock->rx_msg_timer);
+
 	if (psock->rx_stopped)
 		return;
 
@@ -351,6 +353,12 @@ static void unreserve_rx_kcm(struct kcm_psock *psock,
 	spin_unlock_bh(&mux->rx_lock);
 }
 
+static void kcm_start_rx_timer(struct kcm_psock *psock)
+{
+	if (psock->sk->sk_rcvtimeo)
+		mod_timer(&psock->rx_msg_timer, psock->sk->sk_rcvtimeo);
+}
+
 /* Macro to invoke filter function. */
 #define KCM_RUN_FILTER(prog, ctx) \
 	(*prog->bpf_func)(ctx, prog->insnsi)
@@ -500,6 +508,10 @@ static int kcm_tcp_recv(read_descriptor_t *desc, struct sk_buff *orig_skb,
 
 			if (!len) {
 				/* Need more header to determine length */
+				if (!rxm->accum_len) {
+					/* Start RX timer for new message */
+					kcm_start_rx_timer(psock);
+				}
 				rxm->accum_len += cand_len;
 				eaten += cand_len;
 				KCM_STATS_INCR(psock->stats.rx_need_more_hdr);
@@ -540,6 +552,11 @@ static int kcm_tcp_recv(read_descriptor_t *desc, struct sk_buff *orig_skb,
 				 * but don't consume yet per tcp_read_sock.
 				 */
 
+				if (!rxm->accum_len) {
+					/* Start RX timer for new message */
+					kcm_start_rx_timer(psock);
+				}
+
 				psock->rx_need_bytes = rxm->full_len -
 						       rxm->accum_len;
 				rxm->accum_len += cand_len;
@@ -563,6 +580,7 @@ static int kcm_tcp_recv(read_descriptor_t *desc, struct sk_buff *orig_skb,
 		eaten += (cand_len - extra);
 
 		/* Hurray, we have a new message! */
+		del_timer(&psock->rx_msg_timer);
 		psock->rx_skb_head = NULL;
 		KCM_STATS_INCR(psock->stats.rx_msgs);
 
@@ -1656,6 +1674,15 @@ static void init_kcm_sock(struct kcm_sock *kcm, struct kcm_mux *mux)
 	spin_unlock_bh(&mux->rx_lock);
 }
 
+static void kcm_rx_msg_timeout(unsigned long arg)
+{
+	struct kcm_psock *psock = (struct kcm_psock *)arg;
+
+	/* Message assembly timed out */
+	KCM_STATS_INCR(psock->stats.rx_msg_timeouts);
+	kcm_abort_rx_psock(psock, ETIMEDOUT, NULL);
+}
+
 static int kcm_attach(struct socket *sock, struct socket *csock,
 		      struct bpf_prog *prog)
 {
@@ -1685,6 +1712,10 @@ static int kcm_attach(struct socket *sock, struct socket *csock,
 	psock->mux = mux;
 	psock->sk = csk;
 	psock->bpf_prog = prog;
+
+	setup_timer(&psock->rx_msg_timer, kcm_rx_msg_timeout,
+		    (unsigned long)psock);
+
 	INIT_WORK(&psock->rx_work, psock_rx_work);
 	INIT_DELAYED_WORK(&psock->rx_delayed_work, psock_rx_delayed_work);
 
@@ -1796,6 +1827,7 @@ static void kcm_unattach(struct kcm_psock *psock)
 
 	write_unlock_bh(&csk->sk_callback_lock);
 
+	del_timer_sync(&psock->rx_msg_timer);
 	cancel_work_sync(&psock->rx_work);
 	cancel_delayed_work_sync(&psock->rx_delayed_work);
 
-- 
2.6.5
