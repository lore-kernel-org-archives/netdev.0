From: Stephen Hemminger <shemminger@osdl.org>
Subject: [PATCH] tcp probe connection tracing
Date: Tue, 30 May 2006 10:29:44 -0700
Message-ID: <20060530102944.440cd682@dxpl.pdx.osdl.net>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from smtp.osdl.org ([65.172.181.4]:12490 "EHLO smtp.osdl.org")
	by vger.kernel.org with ESMTP id S932353AbWE3R3n (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 30 May 2006 13:29:43 -0400
To: "David S. Miller" <davem@davemloft.net>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Since there seems to be lots of interest in TCP congestion control, here
is a cleaned up version of my TCP congestion tracker. I will put in the
TCP git tree for 2.6.18
----

This adds a new module for tracking TCP state variables non-intrusively
using kprobes.  It has a simple /proc interface that outputs one line
for each packet received. A sample usage is to collect congestion
window and ssthresh over time graphs.

Signed-off-by: Stephen Hemminger <shemminger@osdl.org>

---

 net/Kconfig          |   15 ++++
 net/ipv4/Makefile    |    1 
 net/ipv4/tcp_probe.c |  179 ++++++++++++++++++++++++++++++++++++++++++++++++++
 3 files changed, 195 insertions(+), 0 deletions(-)
 create mode 100644 net/ipv4/tcp_probe.c

f62dd92bdf3b6be5904c1ba347fa21f0f2deccda
diff --git a/net/Kconfig b/net/Kconfig
index 4193cdc..ff0db80 100644
--- a/net/Kconfig
+++ b/net/Kconfig
@@ -215,6 +215,21 @@ config NET_PKTGEN
 	  To compile this code as a module, choose M here: the
 	  module will be called pktgen.
 
+config NET_TCPPROBE
+	tristate "TCP connection probing"
+	depends on INET && EXPERIMENTAL && PROC_FS && KPROBES
+	---help---
+	This module allows for capturing the changes to TCP connection
+	state in response to incoming patckets. It is used for debugging
+	TCP congestion avoidance modules. If you don't understand
+	what was just said, you don't need it: say N.
+
+	Documentation on how to use the packet generator can be found
+	at http://linux-net.osdl.org/index.php/TcpProbe
+
+	To compile this code as a module, choose M here: the
+	module will be called tcp_probe.
+
 endmenu
 
 endmenu
diff --git a/net/ipv4/Makefile b/net/ipv4/Makefile
index 65ab5ba..ac7eb0e 100644
--- a/net/ipv4/Makefile
+++ b/net/ipv4/Makefile
@@ -34,6 +34,7 @@ obj-$(CONFIG_IP_VS) += ipvs/
 obj-$(CONFIG_INET_DIAG) += inet_diag.o 
 obj-$(CONFIG_IP_ROUTE_MULTIPATH_CACHED) += multipath.o
 obj-$(CONFIG_INET_TCP_DIAG) += tcp_diag.o
+obj-$(CONFIG_NET_TCPPROBE) += tcp_probe.o
 obj-$(CONFIG_TCP_CONG_BIC) += tcp_bic.o
 obj-$(CONFIG_TCP_CONG_CUBIC) += tcp_cubic.o
 obj-$(CONFIG_TCP_CONG_WESTWOOD) += tcp_westwood.o
diff --git a/net/ipv4/tcp_probe.c b/net/ipv4/tcp_probe.c
new file mode 100644
index 0000000..0bb8c5b
--- /dev/null
+++ b/net/ipv4/tcp_probe.c
@@ -0,0 +1,179 @@
+/*
+ * tcpprobe - Observe the TCP flow with kprobes.
+ *
+ * The idea for this came from Werner Almesberger's umlsim
+ * Copyright (C) 2004, Stephen Hemminger <shemminger@osdl.org>
+ *
+ * This program is free software; you can redistribute it and/or modify
+ * it under the terms of the GNU General Public License as published by
+ * the Free Software Foundation; either version 2 of the License, or
+ * (at your option) any later version.
+ *
+ * This program is distributed in the hope that it will be useful,
+ * but WITHOUT ANY WARRANTY; without even the implied warranty of
+ * MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
+ * GNU General Public License for more details.
+ *
+ * You should have received a copy of the GNU General Public License
+ * along with this program; if not, write to the Free Software
+ * Foundation, Inc., 675 Mass Ave, Cambridge, MA 02139, USA.
+ */
+
+#include <linux/kernel.h>
+#include <linux/kprobes.h>
+#include <linux/socket.h>
+#include <linux/tcp.h>
+#include <linux/proc_fs.h>
+#include <linux/module.h>
+#include <linux/kfifo.h>
+#include <linux/vmalloc.h>
+
+#include <net/tcp.h>
+
+MODULE_AUTHOR("Stephen Hemminger <shemminger@osdl.org>");
+MODULE_DESCRIPTION("TCP cwnd snooper");
+MODULE_LICENSE("GPL");
+
+static int port = 0;
+MODULE_PARM_DESC(port, "Port to match (0=all)");
+module_param(port, int, 0);
+
+static int bufsize = 64*1024;
+MODULE_PARM_DESC(bufsize, "Log buffer size (default 64k)");
+module_param(bufsize, int, 0);
+
+static const char procname[] = "tcpprobe";
+
+struct {
+	struct kfifo  *fifo;
+	spinlock_t    lock;
+	wait_queue_head_t wait;
+	struct timeval tstart;
+} tcpw;
+
+static void printl(const char *fmt, ...)
+{
+	va_list args;
+	int len;
+	struct timeval now;
+	char tbuf[256];
+
+	va_start(args, fmt);
+	do_gettimeofday(&now);
+	
+	now.tv_sec -= tcpw.tstart.tv_sec;
+	now.tv_usec -= tcpw.tstart.tv_usec;
+	if (now.tv_usec < 0) {
+		--now.tv_sec;
+		now.tv_usec += 1000000;
+	}
+
+	len = sprintf(tbuf, "%lu.%06lu ", now.tv_sec, now.tv_usec);
+	len += vscnprintf(tbuf+len, sizeof(tbuf)-len, fmt, args);
+	va_end(args);
+
+	kfifo_put(tcpw.fifo, tbuf, len);
+	wake_up(&tcpw.wait);
+}
+
+static int jtcp_sendmsg(struct kiocb *iocb, struct sock *sk,
+			struct msghdr *msg, size_t size)
+{
+	const struct tcp_sock *tp = tcp_sk(sk);
+	const struct inet_sock *inet = inet_sk(sk);
+
+	if (port == 0 || ntohs(inet->dport) == port ||
+	    ntohs(inet->sport) == port) { 
+		printl("%d.%d.%d.%d:%u %d.%d.%d.%d:%u %d %#x %#x %u %u %u\n",
+		       NIPQUAD(inet->saddr), ntohs(inet->sport),
+		       NIPQUAD(inet->daddr), ntohs(inet->dport),
+		       size, tp->snd_nxt, tp->snd_una, 
+		       tp->snd_cwnd, tcp_current_ssthresh(sk),
+		       tp->snd_wnd);
+	}
+
+	jprobe_return();
+	return 0;
+}
+
+static struct jprobe tcp_send_probe = {
+	.kp = { .addr = (kprobe_opcode_t *) &tcp_sendmsg, },
+	.entry = (kprobe_opcode_t *) &jtcp_sendmsg,
+};
+
+
+static int tcpprobe_open(struct inode * inode, struct file * file)
+{
+	kfifo_reset(tcpw.fifo);
+	do_gettimeofday(&tcpw.tstart);
+	return 0;
+}
+
+static ssize_t tcpprobe_read(struct file *file, char __user *buf,
+			     size_t len, loff_t *ppos)
+{
+	int error = 0, cnt;
+	unsigned char *tbuf;
+
+	if (!buf || len < 0)
+		return -EINVAL;
+
+	if (len == 0)
+		return 0;
+
+	tbuf = vmalloc(len);
+	if (!tbuf)
+		return -ENOMEM;
+
+	error = wait_event_interruptible(tcpw.wait,
+					 __kfifo_len(tcpw.fifo) != 0);
+	if (error)
+		return error;
+
+	cnt = kfifo_get(tcpw.fifo, tbuf, len);
+	error = copy_to_user(buf, tbuf, cnt);
+
+	vfree(tbuf);
+
+	return error ? error : cnt;
+}
+
+static struct file_operations tcpprobe_fops = {
+	.owner	 = THIS_MODULE,
+	.open	 = tcpprobe_open,
+	.read    = tcpprobe_read,
+};
+
+static __init int tcpprobe_init(void)
+{
+	int ret = -ENOMEM;
+
+	init_waitqueue_head(&tcpw.wait);
+	spin_lock_init(&tcpw.lock);
+	tcpw.fifo = kfifo_alloc(bufsize, GFP_KERNEL, &tcpw.lock);
+
+	if (!proc_net_fops_create(procname, S_IRUSR, &tcpprobe_fops))
+		goto err0;
+
+	ret = register_jprobe(&tcp_send_probe);
+	if (ret)
+		goto err1;
+
+	pr_info("TCP watch registered (port=%d)\n", port);
+	return 0;
+ err1:
+	proc_net_remove(procname);
+ err0:
+	kfifo_free(tcpw.fifo);
+	return ret;
+}
+module_init(tcpprobe_init);
+
+static __exit void tcpprobe_exit(void)
+{
+	kfifo_free(tcpw.fifo);
+	proc_net_remove(procname);
+	unregister_jprobe(&tcp_send_probe);
+
+}
+module_exit(tcpprobe_exit);
-- 
1.3.3

