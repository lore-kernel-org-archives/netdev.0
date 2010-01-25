From: Stephen Hemminger <shemminger@vyatta.com>
Subject: [PATCH] tcp_probe: avoid modulus operation and wrap fix
Date: Sun, 24 Jan 2010 21:50:01 -0800
Message-ID: <20100124215001.78251e25@nehalam>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org
To: David Miller <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail.vyatta.com ([76.74.103.46]:37455 "EHLO mail.vyatta.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1751177Ab0AYFuX (ORCPT <rfc822;netdev@vger.kernel.org>);
	Mon, 25 Jan 2010 00:50:23 -0500
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

By rounding up the buffer size to power of 2, several expensive
modulus operations can be avoided.  This patch also solves a bug where
the gap need when ring gets full was not being accounted for.

Signed-off-by: Stephen Hemminger <shemminger@vyatta.com>


--- a/net/ipv4/tcp_probe.c	2010-01-24 21:43:07.069894439 -0800
+++ b/net/ipv4/tcp_probe.c	2010-01-24 21:46:15.301153066 -0800
@@ -39,9 +39,9 @@ static int port __read_mostly = 0;
 MODULE_PARM_DESC(port, "Port to match (0=all)");
 module_param(port, int, 0);
 
-static int bufsize __read_mostly = 4096;
+static unsigned int bufsize __read_mostly = 4096;
 MODULE_PARM_DESC(bufsize, "Log buffer size in packets (4096)");
-module_param(bufsize, int, 0);
+module_param(bufsize, uint, 0);
 
 static int full __read_mostly;
 MODULE_PARM_DESC(full, "Full log (1=every ack packet received,  0=only cwnd changes)");
@@ -75,12 +75,12 @@ static struct {
 
 static inline int tcp_probe_used(void)
 {
-	return (tcp_probe.head - tcp_probe.tail) % bufsize;
+	return (tcp_probe.head - tcp_probe.tail) & (bufsize - 1);
 }
 
 static inline int tcp_probe_avail(void)
 {
-	return bufsize - tcp_probe_used();
+	return bufsize - tcp_probe_used() - 1;
 }
 
 /*
@@ -116,7 +116,7 @@ static int jtcp_rcv_established(struct s
 			p->ssthresh = tcp_current_ssthresh(sk);
 			p->srtt = tp->srtt >> 3;
 
-			tcp_probe.head = (tcp_probe.head + 1) % bufsize;
+			tcp_probe.head = (tcp_probe.head + 1) & (bufsize - 1);
 		}
 		tcp_probe.lastcwnd = tp->snd_cwnd;
 		spin_unlock(&tcp_probe.lock);
@@ -149,7 +149,7 @@ static int tcpprobe_open(struct inode * 
 static int tcpprobe_sprint(char *tbuf, int n)
 {
 	const struct tcp_log *p
-		= tcp_probe.log + tcp_probe.tail % bufsize;
+		= tcp_probe.log + tcp_probe.tail;
 	struct timespec tv
 		= ktime_to_timespec(ktime_sub(p->tstamp, tcp_probe.start));
 
@@ -192,7 +192,7 @@ static ssize_t tcpprobe_read(struct file
 		width = tcpprobe_sprint(tbuf, sizeof(tbuf));
 
 		if (cnt + width < len)
-			tcp_probe.tail = (tcp_probe.tail + 1) % bufsize;
+			tcp_probe.tail = (tcp_probe.tail + 1) & (bufsize - 1);
 
 		spin_unlock_bh(&tcp_probe.lock);
 
@@ -222,9 +222,10 @@ static __init int tcpprobe_init(void)
 	init_waitqueue_head(&tcp_probe.wait);
 	spin_lock_init(&tcp_probe.lock);
 
-	if (bufsize < 0)
+	if (bufsize == 0)
 		return -EINVAL;
 
+	bufsize = roundup_pow_of_two(bufsize);
 	tcp_probe.log = kcalloc(bufsize, sizeof(struct tcp_log), GFP_KERNEL);
 	if (!tcp_probe.log)
 		goto err0;
@@ -236,7 +237,7 @@ static __init int tcpprobe_init(void)
 	if (ret)
 		goto err1;
 
-	pr_info("TCP probe registered (port=%d)\n", port);
+	pr_info("TCP probe registered (port=%d) bufsize=%u\n", port, bufsize);
 	return 0;
  err1:
 	proc_net_remove(&init_net, procname);
