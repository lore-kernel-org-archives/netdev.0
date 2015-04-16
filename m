From: Tejun Heo <tj@kernel.org>
Subject: [PATCH 14/16] netconsole: implement ack handling and emergency transmission
Date: Thu, 16 Apr 2015 19:03:51 -0400
Message-ID: <1429225433-11946-15-git-send-email-tj@kernel.org>
References: <1429225433-11946-1-git-send-email-tj@kernel.org>
Cc: linux-kernel@vger.kernel.org, netdev@vger.kernel.org,
	Tejun Heo <tj@kernel.org>
To: akpm@linux-foundation.org, davem@davemloft.net
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-qg0-f46.google.com ([209.85.192.46]:33086 "EHLO
	mail-qg0-f46.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1753902AbbDPXEl (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 16 Apr 2015 19:04:41 -0400
In-Reply-To: <1429225433-11946-1-git-send-email-tj@kernel.org>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

While the retransmission support added by the previous patch goes a
long way towards enabling implementation of reliable remote logger, it
depends on a lot larger part of the kernel working and there's no
non-polling way of discovering whether the latest messages have been
lost.

This patch implements an optional ack handling.  An extended remote
logger can respond with a message formatted like the following.

 nca[<ack-seq>] <missing-seq> <missing-seq>...

The optional <ack-seq> enables ack handling.  Whenever ack lags
transmission by more than ACK_TIMEOUT (10s), the netconsole target
will retransmit all unacked messages with increasing interval (100ms
between message at the beginning, exponentially backing out to 10s).
This ensures that the remote logger has a very high chance of getting
all the messages even after severe failures as long as the timer and
netpoll are working.

This doesn't interfere with the normal transmission path.  Even if
something goes wrong with timer, the normal transmission path should
keep working.

Emergency transmissions are marked with "emg=1" header.

Signed-off-by: Tejun Heo <tj@kernel.org>
Cc: David Miller <davem@davemloft.net>
---
 drivers/net/netconsole.c | 136 +++++++++++++++++++++++++++++++++++++++++++----
 1 file changed, 127 insertions(+), 9 deletions(-)

diff --git a/drivers/net/netconsole.c b/drivers/net/netconsole.c
index b2763e0..82c8be0 100644
--- a/drivers/net/netconsole.c
+++ b/drivers/net/netconsole.c
@@ -49,6 +49,7 @@
 #include <linux/inet.h>
 #include <linux/file.h>
 #include <linux/poll.h>
+#include <linux/timer.h>
 #include <linux/configfs.h>
 #include <linux/etherdevice.h>
 
@@ -59,6 +60,10 @@ MODULE_LICENSE("GPL");
 #define MAX_PARAM_LENGTH	256
 #define MAX_PRINT_CHUNK		1000
 
+#define ACK_TIMEOUT		(10 * HZ)
+#define EMG_TX_MIN_INTV		(HZ / 10)
+#define EMG_TX_MAX_INTV		HZ
+
 static char config[MAX_PARAM_LENGTH];
 module_param_string(netconsole, config, MAX_PARAM_LENGTH, 0);
 MODULE_PARM_DESC(netconsole, " netconsole=[src-port]@[src-ip]/[dev],[tgt-port]@<tgt-ip>/[tgt-macaddr]");
@@ -137,6 +142,13 @@ struct netconsole_target {
 	wait_queue_t		rx_wait;	/* ditto */
 	wait_queue_head_t	*rx_waitq;	/* ditto */
 	struct work_struct	rx_work;	/* receive & process packets */
+
+	/* ack handling and emergency transmission for extended netconsoles */
+	unsigned long		ack_tstmp;	/* pending ack timestamp */
+	u64			ack_seq;	/* last acked sequence */
+	struct timer_list	ack_timer;	/* ack timeout */
+	unsigned long		emg_tx_intv;	/* emergency tx interval */
+	u64			emg_tx_seq;	/* current emg tx sequence */
 };
 
 #ifdef	CONFIG_NETCONSOLE_DYNAMIC
@@ -223,16 +235,17 @@ static struct netconsole_target *alloc_netconsole_target(void)
  * @nt: target to send message to
  * @msg: extended log message to send
  * @msg_len: length of message
+ * @emg_tx: is it for emergency transmission?
  *
  * Transfer extended log @msg to @nt.  If @msg is too long, it'll be split
  * and transmitted in multiple chunks with ncfrag header field added to
- * enable correct reassembly.
+ * enable correct reassembly.  If @emg_tx, emg header field is added.
  */
 static void send_ext_msg_udp(struct netconsole_target *nt, const char *msg,
-			     int msg_len)
+			     int msg_len, bool emg_tx)
 {
 	static char buf[MAX_PRINT_CHUNK];
-	const int max_extra_len = sizeof(",ncfrag=0000@00/00");
+	const int max_extra_len = sizeof(",emg=1,ncfrag=0000@00/00");
 	const char *header, *body;
 	int header_len = msg_len, body_len = 0;
 	int chunk_len, nr_chunks, i;
@@ -240,7 +253,7 @@ static void send_ext_msg_udp(struct netconsole_target *nt, const char *msg,
 	if (!nt->enabled || !netif_running(nt->np.dev))
 		return;
 
-	if (msg_len <= MAX_PRINT_CHUNK) {
+	if (!emg_tx && msg_len <= MAX_PRINT_CHUNK) {
 		netpoll_send_udp(&nt->np, msg, msg_len);
 		return;
 	}
@@ -261,6 +274,8 @@ static void send_ext_msg_udp(struct netconsole_target *nt, const char *msg,
 	/*
 	 * Transfer possibly multiple chunks with extra header fields.
 	 *
+	 * For emergency transfers due to missing acks, add "emg=1".
+	 *
 	 * If @msg needs to be split to fit MAX_PRINT_CHUNK, add
 	 * "ncfrag=<byte-offset>@<0-based-chunk-index>/<total-chunks>" to
 	 * enable proper reassembly on receiver side.
@@ -272,6 +287,10 @@ static void send_ext_msg_udp(struct netconsole_target *nt, const char *msg,
 		int this_header = header_len;
 		int this_chunk;
 
+		if (emg_tx)
+			this_header += scnprintf(buf + this_header,
+						 sizeof(buf) - this_header,
+						 ",emg=1");
 		if (nr_chunks > 1)
 			this_header += scnprintf(buf + this_header,
 						 sizeof(buf) - this_header,
@@ -309,6 +328,78 @@ static bool sockaddr_in46_equal(union sockaddr_in46 *a, union sockaddr_in46 *b)
 }
 
 /**
+ * netconsole_ack_timer_fn - timer function to handle netconsole ack timeouts
+ * @data: netconsole_target
+ *
+ * For an extended netconsole, if the remote logger acked messages
+ * previously but is failing to ack new messages for over ACK_TIMEOUT, this
+ * timer kicks in for emergency transmission.
+ *
+ * The lack of ack may be caused by a number of things including the ack
+ * packet being dropped or the network stack oopsing.  Whatever the cause
+ * may be, we repeatedly retransmit the unacked message at increasing
+ * interval which should allow the remote logger to eventually obtain all
+ * messages as long as the packets are going out.
+ *
+ * This mechanism depends only on the timer and netpoll working.
+ */
+static void netconsole_ack_timer_fn(unsigned long data)
+{
+	struct netconsole_target *nt = (void *)data;
+	unsigned long now = jiffies;
+	unsigned long next_at;
+	char *buf = netconsole_ext_tx_buf;
+	u64 begin_seq, end_seq, seq;
+	int len;
+
+	if (!console_trylock()) {
+		mod_timer(&nt->ack_timer, now + 1);
+		return;
+	}
+
+	log_seq_range(&begin_seq, &end_seq);
+	if (nt->ack_seq == end_seq - 1) {
+		nt->ack_tstmp = 0;
+		next_at = now + ACK_TIMEOUT;
+		goto out_unlock;
+	}
+	if (time_before(now, nt->ack_tstmp + ACK_TIMEOUT)) {
+		next_at = nt->ack_tstmp + ACK_TIMEOUT;
+		goto out_unlock;
+	}
+
+	/* zero emg_tx_intv indicates that we're starting emergency tx */
+	if (!nt->emg_tx_intv) {
+		nt->emg_tx_intv = EMG_TX_MIN_INTV;
+		nt->emg_tx_seq = nt->ack_seq + 1;
+	}
+
+	seq = nt->emg_tx_seq;
+	do {
+		len = ext_log_from_seq(buf, CONSOLE_EXT_LOG_MAX, seq);
+	} while (len < 0 && ++seq < end_seq);
+
+	if (len >= 0) {
+		send_ext_msg_udp(nt, buf, len, true);
+		seq++;
+	}
+
+	nt->emg_tx_seq = seq;
+
+	if (nt->emg_tx_seq >= end_seq) {
+		/* all messages transferred, bump up intv and repeat */
+		nt->emg_tx_intv = min_t(unsigned long, 2 * nt->emg_tx_intv,
+					EMG_TX_MAX_INTV);
+		nt->emg_tx_seq = nt->ack_seq + 1;
+	}
+
+	next_at = now + nt->emg_tx_intv;
+out_unlock:
+	console_unlock();
+	mod_timer(&nt->ack_timer, next_at);
+}
+
+/**
  * netconsole_rx_work_fn - work function to handle netconsole ack packets
  * @work: netconsole_target->rx_work
  *
@@ -316,7 +407,7 @@ static bool sockaddr_in46_equal(union sockaddr_in46 *a, union sockaddr_in46 *b)
  * of extended netconsole target and responds to ack messages from the
  * remote logger.  An ack message has the following format.
  *
- * nca <missing-seq> <missing-seq> ...
+ * nca[<ack-seq>] <missing-seq> <missing-seq> ...
  *
  * There can be any number of missing-seq's as long as the whole payload
  * fits inside MAX_PRINT_CHUNK.  This function re-transmits each message
@@ -327,6 +418,10 @@ static bool sockaddr_in46_equal(union sockaddr_in46 *a, union sockaddr_in46 *b)
  * actually sends out the messages, and that path doesn't depend on
  * anything more working compared to the normal tx path.  As such, this
  * shouldn't make netconsole any less robust when things start going south.
+ *
+ * If <ack-seq> exists, emergency tx is enabled.  Whenever ack is lagging
+ * by more than ACK_TIMEOUT, netconsole will repeatedly send out unacked
+ * messages with increasing interval.  See netconsole_ack_timer_fn().
  */
 static void netconsole_rx_work_fn(struct work_struct *work)
 {
@@ -335,6 +430,7 @@ static void netconsole_rx_work_fn(struct work_struct *work)
 	union sockaddr_in46 raddr;
 	struct msghdr msgh = { .msg_name = &raddr.addr, };
 	struct kvec iov;
+	bool ack_was_enabled = nt->ack_seq;
 	char *tx_buf = netconsole_ext_tx_buf;
 	char *rx_buf, *pos, *tok;
 	u64 seq;
@@ -355,6 +451,9 @@ repeat:
 	if (len < 0) {
 		if (len != -EAGAIN && printk_ratelimit())
 			pr_warning("RX failed err=%d\n", len);
+		if (!ack_was_enabled && nt->ack_seq)
+			pr_info("ACK timeout enabled for %pIS:%d\n",
+				&nt->raddr.addr, ntohs(nt->raddr.in4.sin_port));
 		kfree(rx_buf);
 		return;
 	}
@@ -381,12 +480,25 @@ repeat:
 
 	console_lock();
 
+	/* <ack-seq> */
+	if (sscanf(tok, "%llu", &seq)) {
+		u64 begin_seq, end_seq;
+
+		log_seq_range(&begin_seq, &end_seq);
+		if (seq && seq < end_seq) {
+			nt->ack_seq = max(seq, nt->ack_seq);
+			nt->emg_tx_intv = 0;
+			if (!ack_was_enabled)
+				mod_timer(&nt->ack_timer, jiffies);
+		}
+	}
+
 	/* <missing-seq>... */
 	while ((tok = strsep(&pos, " "))) {
 		if (sscanf(tok, "%llu", &seq)) {
 			len = ext_log_from_seq(tx_buf, CONSOLE_EXT_LOG_MAX, seq);
 			if (len >= 0)
-				send_ext_msg_udp(nt, tx_buf, len);
+				send_ext_msg_udp(nt, tx_buf, len, false);
 		}
 	}
 
@@ -480,6 +592,7 @@ static void netconsole_enable_rx(struct netconsole_target *nt)
 	init_poll_funcptr(&nt->rx_ptable, netconsole_rx_ptable_queue_fn);
 	init_waitqueue_func_entry(&nt->rx_wait, netconsole_rx_wait_fn);
 	INIT_WORK(&nt->rx_work, netconsole_rx_work_fn);
+	setup_timer(&nt->ack_timer, netconsole_ack_timer_fn, (unsigned long)nt);
 
 	ret = file->f_op->poll(file, &nt->rx_ptable);
 	if (ret < 0) {
@@ -501,6 +614,7 @@ static void netconsole_disable_rx(struct netconsole_target *nt)
 
 	remove_wait_queue(nt->rx_waitq, &nt->rx_wait);
 	cancel_work_sync(&nt->rx_work);
+	del_timer_sync(&nt->ack_timer);
 
 	fput(nt->rx_file);
 	nt->rx_file = NULL;
@@ -1148,9 +1262,13 @@ static void write_ext_msg(struct console *con, const char *msg,
 	if ((oops_only && !oops_in_progress) || list_empty(&target_list))
 		return;
 
-	list_for_each_entry(nt, &target_list, list)
-		if (nt->extended)
-			send_ext_msg_udp(nt, msg, len);
+	list_for_each_entry(nt, &target_list, list) {
+		if (nt->extended) {
+			send_ext_msg_udp(nt, msg, len, false);
+			if (!nt->ack_tstmp)
+				nt->ack_tstmp = jiffies ?: 1;
+		}
+	}
 }
 
 static void write_msg(struct console *con, const char *msg, unsigned int len)
-- 
2.1.0
