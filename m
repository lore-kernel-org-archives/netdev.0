From: Stephen Hemminger <shemminger@linux-foundation.org>
Subject: [PATCH] tcp: tcp probe wraparound handling and other changes
Date: Wed, 11 Jul 2007 10:51:15 -0700
Message-ID: <20070711105115.43ae0530@freepuppy.rosehill.hemminger.net>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org
To: "David S. Miller" <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from smtp2.linux-foundation.org ([207.189.120.14]:58370 "EHLO
	smtp2.linux-foundation.org" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with ESMTP id S1754469AbXGKRvV (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 11 Jul 2007 13:51:21 -0400
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Switch from formatting messages in probe routine and copying with kfifo, 
to using a small circular queue of information and formatting on read. 
This avoids wraparound issues with kfifo, and saves one copy.

Also make sure to state correct license, rather than copying off some other
driver I started with.

Signed-off-by: Stephen Hemminger <shemminger@linux-foundation.org>

---
 net/ipv4/tcp_probe.c |  201 ++++++++++++++++++++++++++++++---------------------
 1 file changed, 119 insertions(+), 82 deletions(-)

--- a/net/ipv4/tcp_probe.c	2007-06-25 09:03:23.000000000 -0700
+++ b/net/ipv4/tcp_probe.c	2007-07-11 10:44:04.000000000 -0700
@@ -6,8 +6,7 @@
  *
  * This program is free software; you can redistribute it and/or modify
  * it under the terms of the GNU General Public License as published by
- * the Free Software Foundation; either version 2 of the License, or
- * (at your option) any later version.
+ * the Free Software Foundation; either version 2 of the License.
  *
  * This program is distributed in the hope that it will be useful,
  * but WITHOUT ANY WARRANTY; without even the implied warranty of
@@ -25,23 +24,22 @@
 #include <linux/tcp.h>
 #include <linux/proc_fs.h>
 #include <linux/module.h>
-#include <linux/kfifo.h>
 #include <linux/ktime.h>
 #include <linux/time.h>
-#include <linux/vmalloc.h>
 
 #include <net/tcp.h>
 
 MODULE_AUTHOR("Stephen Hemminger <shemminger@linux-foundation.org>");
 MODULE_DESCRIPTION("TCP cwnd snooper");
 MODULE_LICENSE("GPL");
+MODULE_VERSION("1.1");
 
 static int port __read_mostly = 0;
 MODULE_PARM_DESC(port, "Port to match (0=all)");
 module_param(port, int, 0);
 
-static int bufsize __read_mostly = 64*1024;
-MODULE_PARM_DESC(bufsize, "Log buffer size (default 64k)");
+static int bufsize __read_mostly = 4096;
+MODULE_PARM_DESC(bufsize, "Log buffer size in packets (4096)");
 module_param(bufsize, int, 0);
 
 static int full __read_mostly;
@@ -50,39 +48,38 @@ module_param(full, int, 0);
 
 static const char procname[] = "tcpprobe";
 
-struct {
-	struct kfifo	*fifo;
+struct tcp_log {
+	ktime_t tstamp;
+	__be32	saddr, daddr;
+	__be16	sport, dport;
+	u16	length;
+	u32	snd_nxt;
+	u32	snd_una;
+	u32	snd_wnd;
+	u32	snd_cwnd;
+	u32	ssthresh;
+	u32	srtt;
+};
+
+static struct {
 	spinlock_t	lock;
 	wait_queue_head_t wait;
 	ktime_t		start;
 	u32		lastcwnd;
-} tcpw;
 
-/*
- * Print to log with timestamps.
- * FIXME: causes an extra copy
- */
-static void printl(const char *fmt, ...)
-	__attribute__ ((format (printf, 1, 2)));
+	unsigned long	head, tail;
+	struct tcp_log	*log;
+} tcp_probe;
+
 
-static void printl(const char *fmt, ...)
+static inline int tcp_probe_used(void)
 {
-	va_list args;
-	int len;
-	struct timespec tv;
-	char tbuf[256];
-
-	va_start(args, fmt);
-	/* want monotonic time since start of tcp_probe */
-	tv = ktime_to_timespec(ktime_sub(ktime_get(), tcpw.start));
-
-	len = sprintf(tbuf, "%lu.%09lu ",
-		      (unsigned long) tv.tv_sec, (unsigned long) tv.tv_nsec);
-	len += vscnprintf(tbuf+len, sizeof(tbuf)-len, fmt, args);
-	va_end(args);
+	return (tcp_probe.head - tcp_probe.tail) % bufsize;
+}
 
-	kfifo_put(tcpw.fifo, tbuf, len);
-	wake_up(&tcpw.wait);
+static inline int tcp_probe_avail(void)
+{
+	return bufsize - tcp_probe_used();
 }
 
 /*
@@ -97,63 +94,117 @@ static int jtcp_rcv_established(struct s
 
 	/* Only update if port matches */
 	if ((port == 0 || ntohs(inet->dport) == port || ntohs(inet->sport) == port)
-	    && (full || tp->snd_cwnd != tcpw.lastcwnd)) {
-		printl("%d.%d.%d.%d:%u %d.%d.%d.%d:%u %d %#x %#x %u %u %u %u\n",
-		       NIPQUAD(inet->saddr), ntohs(inet->sport),
-		       NIPQUAD(inet->daddr), ntohs(inet->dport),
-		       skb->len, tp->snd_nxt, tp->snd_una,
-		       tp->snd_cwnd, tcp_current_ssthresh(sk),
-		       tp->snd_wnd, tp->srtt >> 3);
-		tcpw.lastcwnd = tp->snd_cwnd;
+	    && (full || tp->snd_cwnd != tcp_probe.lastcwnd)) {
+
+		spin_lock(&tcp_probe.lock);
+		/* If log fills, just silently drop */
+		if (tcp_probe_avail() > 1) {
+			struct tcp_log *p = tcp_probe.log + tcp_probe.head;
+
+			p->tstamp = ktime_get();
+			p->saddr = inet->saddr;
+			p->sport = inet->sport;
+			p->daddr = inet->daddr;
+			p->dport = inet->dport;
+			p->length = skb->len;
+			p->snd_nxt = tp->snd_nxt;
+			p->snd_una = tp->snd_una;
+			p->snd_cwnd = tp->snd_cwnd;
+			p->snd_wnd = tp->snd_wnd;
+			p->srtt = tp->srtt >> 3;
+
+			tcp_probe.head = (tcp_probe.head + 1) % bufsize;
+		}
+		tcp_probe.lastcwnd = tp->snd_cwnd;
+		spin_unlock(&tcp_probe.lock);
+
+		wake_up(&tcp_probe.wait);
 	}
 
 	jprobe_return();
 	return 0;
 }
 
-static struct jprobe tcp_probe = {
+static struct jprobe tcp_jprobe = {
 	.kp = {
 		.symbol_name	= "tcp_rcv_established",
 	},
 	.entry	= JPROBE_ENTRY(jtcp_rcv_established),
 };
 
-
 static int tcpprobe_open(struct inode * inode, struct file * file)
 {
-	kfifo_reset(tcpw.fifo);
-	tcpw.start = ktime_get();
+	/* Reset (empty) log */
+	spin_lock_bh(&tcp_probe.lock);
+	tcp_probe.head = tcp_probe.tail = 0;
+	tcp_probe.start = ktime_get();
+	spin_unlock_bh(&tcp_probe.lock);
+
 	return 0;
 }
 
+static int tcpprobe_sprint(char *tbuf, int n)
+{
+	const struct tcp_log *p
+		= tcp_probe.log + tcp_probe.tail % bufsize;
+	struct timespec tv
+		= ktime_to_timespec(ktime_sub(p->tstamp, tcp_probe.start));
+
+	return snprintf(tbuf, n,
+			"%lu.%09lu %d.%d.%d.%d:%u %d.%d.%d.%d:%u"
+			" %d %#x %#x %u %u %u %u\n",
+			(unsigned long) tv.tv_sec,
+			(unsigned long) tv.tv_nsec,
+			NIPQUAD(p->saddr), ntohs(p->sport),
+			NIPQUAD(p->daddr), ntohs(p->dport),
+			p->length, p->snd_nxt, p->snd_una,
+			p->snd_cwnd, p->ssthresh, p->snd_wnd, p->srtt);
+}
+
 static ssize_t tcpprobe_read(struct file *file, char __user *buf,
 			     size_t len, loff_t *ppos)
 {
 	int error = 0, cnt = 0;
-	unsigned char *tbuf;
 
 	if (!buf || len < 0)
 		return -EINVAL;
 
-	if (len == 0)
-		return 0;
-
-	tbuf = vmalloc(len);
-	if (!tbuf)
-		return -ENOMEM;
-
-	error = wait_event_interruptible(tcpw.wait,
-					 __kfifo_len(tcpw.fifo) != 0);
-	if (error)
-		goto out_free;
-
-	cnt = kfifo_get(tcpw.fifo, tbuf, len);
-	error = copy_to_user(buf, tbuf, cnt);
-
-out_free:
-	vfree(tbuf);
+	while (cnt < len) {
+		char tbuf[128];
+		int width;
+
+		/* Wait for data in buffer */
+		error = wait_event_interruptible(tcp_probe.wait,
+						 tcp_probe_used() > 0);
+		if (error)
+			break;
+
+		spin_lock_bh(&tcp_probe.lock);
+		if (tcp_probe.head == tcp_probe.tail) {
+			/* multiple readers race? */
+			spin_unlock_bh(&tcp_probe.lock);
+			continue;
+		}
+
+		width = tcpprobe_sprint(tbuf, sizeof(tbuf));
+
+		if (width < len)
+			tcp_probe.tail = (tcp_probe.tail + 1) % bufsize;
+
+		spin_unlock_bh(&tcp_probe.lock);
+
+		/* if record greater than space available
+		   return partial buffer (so far) */
+		if (width >= len)
+			break;
+
+		error = copy_to_user(buf + cnt, tbuf, width);
+		if (error)
+			break;
+		cnt += width;
+	}
 
-	return error ? error : cnt;
+	return cnt == 0 ? error : cnt;
 }
 
 static const struct file_operations tcpprobe_fops = {
@@ -166,34 +217,37 @@ static __init int tcpprobe_init(void)
 {
 	int ret = -ENOMEM;
 
-	init_waitqueue_head(&tcpw.wait);
-	spin_lock_init(&tcpw.lock);
-	tcpw.fifo = kfifo_alloc(bufsize, GFP_KERNEL, &tcpw.lock);
-	if (IS_ERR(tcpw.fifo))
-		return PTR_ERR(tcpw.fifo);
+	init_waitqueue_head(&tcp_probe.wait);
+	spin_lock_init(&tcp_probe.lock);
+
+	if (bufsize < 0)
+		return -EINVAL;
+
+	tcp_probe.log = kcalloc(sizeof(struct tcp_log), bufsize, GFP_KERNEL);
+	if (!tcp_probe.log)
+		goto err0;
 
 	if (!proc_net_fops_create(procname, S_IRUSR, &tcpprobe_fops))
 		goto err0;
 
-	ret = register_jprobe(&tcp_probe);
+	ret = register_jprobe(&tcp_jprobe);
 	if (ret)
 		goto err1;
 
-	pr_info("TCP watch registered (port=%d)\n", port);
+	pr_info("TCP probe registered (port=%d)\n", port);
 	return 0;
  err1:
 	proc_net_remove(procname);
  err0:
-	kfifo_free(tcpw.fifo);
+	kfree(tcp_probe.log);
 	return ret;
 }
 module_init(tcpprobe_init);
 
 static __exit void tcpprobe_exit(void)
 {
-	kfifo_free(tcpw.fifo);
 	proc_net_remove(procname);
-	unregister_jprobe(&tcp_probe);
-
+	unregister_jprobe(&tcp_jprobe);
+	kfree(tcp_probe.log);
 }
 module_exit(tcpprobe_exit);
