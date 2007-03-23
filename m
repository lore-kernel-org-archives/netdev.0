From: Stephen Hemminger <shemminger@linux-foundation.org>
Subject: [PATCH] tcp_probe: improvements for net-2.6.22
Date: Fri, 23 Mar 2007 13:40:16 -0700
Message-ID: <20070323134016.21581033@freekitty>
References: <56109191-2AB4-4307-8BC9-F0BE5840D629@nuim.ie>
	<20070323082438.52a728a2@mongrel>
	<5FBB64D9-2486-4600-9A36-441D8A7BF0C9@nuim.ie>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Cc: Douglas Leith <doug.leith@nuim.ie>, netdev@vger.kernel.org
To: "David S. Miller" <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from smtp.osdl.org ([65.172.181.24]:37533 "EHLO smtp.osdl.org"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S932564AbXCWUkW (ORCPT <rfc822;netdev@vger.kernel.org>);
	Fri, 23 Mar 2007 16:40:22 -0400
In-Reply-To: <5FBB64D9-2486-4600-9A36-441D8A7BF0C9@nuim.ie>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Change tcp_probe to use ktime (needed to add one export).
Add option to only get events when cwnd changes - from Doug Leith

Signed-off-by: Stephen Hemminger <shemminger@linux-foundation.org>
---
 kernel/time.c        |    1 +
 net/ipv4/tcp_probe.c |   68 ++++++++++++++++++++++++++++---------------------
 2 files changed, 40 insertions(+), 29 deletions(-)

diff --git a/kernel/time.c b/kernel/time.c
index ec5b10c..de66866 100644
--- a/kernel/time.c
+++ b/kernel/time.c
@@ -452,6 +452,7 @@ struct timespec ns_to_timespec(const s64 nsec)
 
 	return ts;
 }
+EXPORT_SYMBOL(ns_to_timespec);
 
 /**
  * ns_to_timeval - Convert nanoseconds to timeval
diff --git a/net/ipv4/tcp_probe.c b/net/ipv4/tcp_probe.c
index 61f406f..d03ae9b 100644
--- a/net/ipv4/tcp_probe.c
+++ b/net/ipv4/tcp_probe.c
@@ -26,6 +26,8 @@
 #include <linux/proc_fs.h>
 #include <linux/module.h>
 #include <linux/kfifo.h>
+#include <linux/ktime.h>
+#include <linux/time.h>
 #include <linux/vmalloc.h>
 
 #include <net/tcp.h>
@@ -34,43 +36,45 @@ MODULE_AUTHOR("Stephen Hemminger <shemminger@linux-foundation.org>");
 MODULE_DESCRIPTION("TCP cwnd snooper");
 MODULE_LICENSE("GPL");
 
-static int port = 0;
+static int port __read_mostly = 0;
 MODULE_PARM_DESC(port, "Port to match (0=all)");
 module_param(port, int, 0);
 
-static int bufsize = 64*1024;
+static int bufsize __read_mostly = 64*1024;
 MODULE_PARM_DESC(bufsize, "Log buffer size (default 64k)");
 module_param(bufsize, int, 0);
 
+static int full __read_mostly;
+MODULE_PARM_DESC(full, "Full log (1=every ack packet received,  0=only cwnd changes)");
+module_param(full, int, 0);
+
 static const char procname[] = "tcpprobe";
 
 struct {
-	struct kfifo  *fifo;
-	spinlock_t    lock;
+	struct kfifo	*fifo;
+	spinlock_t	lock;
 	wait_queue_head_t wait;
-	struct timeval tstart;
+	ktime_t		start;
+	u32		lastcwnd;
 } tcpw;
 
+/*
+ * Print to log with timestamps.
+ * FIXME: causes an extra copy
+ */
 static void printl(const char *fmt, ...)
 {
 	va_list args;
 	int len;
-	struct timeval now;
+	struct timespec tv;
 	char tbuf[256];
 
 	va_start(args, fmt);
-	do_gettimeofday(&now);
+	/* want monotonic time since start of tcp_probe */
+	tv = ktime_to_timespec(ktime_sub(ktime_get(), tcpw.start));
 
-	now.tv_sec -= tcpw.tstart.tv_sec;
-	now.tv_usec -= tcpw.tstart.tv_usec;
-	if (now.tv_usec < 0) {
-		--now.tv_sec;
-		now.tv_usec += 1000000;
-	}
-
-	len = sprintf(tbuf, "%lu.%06lu ",
-		      (unsigned long) now.tv_sec,
-		      (unsigned long) now.tv_usec);
+	len = sprintf(tbuf, "%lu.%09lu ", 
+		      (unsigned long) tv.tv_sec, (unsigned long) tv.tv_nsec);
 	len += vscnprintf(tbuf+len, sizeof(tbuf)-len, fmt, args);
 	va_end(args);
 
@@ -78,38 +82,44 @@ static void printl(const char *fmt, ...)
 	wake_up(&tcpw.wait);
 }
 
-static int jtcp_sendmsg(struct kiocb *iocb, struct sock *sk,
-			struct msghdr *msg, size_t size)
+/* 
+ * Hook inserted to be called before each receive packet.
+ * Note: arguments must match tcp_rcv_established()!
+ */
+static int jtcp_rcv_established(struct sock *sk, struct sk_buff *skb,
+			       struct tcphdr *th, unsigned len)
 {
 	const struct tcp_sock *tp = tcp_sk(sk);
 	const struct inet_sock *inet = inet_sk(sk);
 
-	if (port == 0 || ntohs(inet->dport) == port ||
-	    ntohs(inet->sport) == port) {
+	/* Only update if port matches */
+	if ((port == 0 || ntohs(inet->dport) == port || ntohs(inet->sport) == port)
+	    && (full || tp->snd_cwnd != tcpw.lastcwnd)) {
 		printl("%d.%d.%d.%d:%u %d.%d.%d.%d:%u %d %#x %#x %u %u %u\n",
 		       NIPQUAD(inet->saddr), ntohs(inet->sport),
 		       NIPQUAD(inet->daddr), ntohs(inet->dport),
-		       size, tp->snd_nxt, tp->snd_una,
+		       skb->len, tp->snd_nxt, tp->snd_una,
 		       tp->snd_cwnd, tcp_current_ssthresh(sk),
-		       tp->snd_wnd);
+		       tp->snd_wnd, tp->srtt >> 3);
+		tcpw.lastcwnd = tp->snd_cwnd;
 	}
 
 	jprobe_return();
 	return 0;
 }
 
-static struct jprobe tcp_send_probe = {
+static struct jprobe tcp_probe = {
 	.kp = {
-		.symbol_name	= "tcp_sendmsg",
+		.symbol_name	= "tcp_rcv_established",
 	},
-	.entry	= JPROBE_ENTRY(jtcp_sendmsg),
+	.entry	= JPROBE_ENTRY(jtcp_rcv_established),
 };
 
 
 static int tcpprobe_open(struct inode * inode, struct file * file)
 {
 	kfifo_reset(tcpw.fifo);
-	do_gettimeofday(&tcpw.tstart);
+	tcpw.start = ktime_get();
 	return 0;
 }
 
@@ -162,7 +172,7 @@ static __init int tcpprobe_init(void)
 	if (!proc_net_fops_create(procname, S_IRUSR, &tcpprobe_fops))
 		goto err0;
 
-	ret = register_jprobe(&tcp_send_probe);
+	ret = register_jprobe(&tcp_probe);
 	if (ret)
 		goto err1;
 
@@ -180,7 +190,7 @@ static __exit void tcpprobe_exit(void)
 {
 	kfifo_free(tcpw.fifo);
 	proc_net_remove(procname);
-	unregister_jprobe(&tcp_send_probe);
+	unregister_jprobe(&tcp_probe);
 
 }
 module_exit(tcpprobe_exit);
-- 
1.4.4.2

