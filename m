From: Tejun Heo <tj@kernel.org>
Subject: [PATCH 13/16] netconsole: implement retransmission support for extended consoles
Date: Thu, 16 Apr 2015 19:03:50 -0400
Message-ID: <1429225433-11946-14-git-send-email-tj@kernel.org>
References: <1429225433-11946-1-git-send-email-tj@kernel.org>
Cc: linux-kernel@vger.kernel.org, netdev@vger.kernel.org,
	Tejun Heo <tj@kernel.org>
To: akpm@linux-foundation.org, davem@davemloft.net
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <1429225433-11946-1-git-send-email-tj@kernel.org>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

With extended netconsole, the logger can reliably determine which
messages are missing.  This patch implements receiver for extended
netconsole which accepts retransmission request packets coming into
the the netconsole source port and sends back the requested messages.

The receiving socket is automatically created when an extended console
is enabled.  A poll_table with a custom callback is queued on the
socket.  When a packet is received on the socket, a work item is
scheduled which reads and parses the payload and sends back the
requested ones.  A retransmission packet looks like the following.

 nca <missing-seq> <missing-seq>...

The receiver doesn't interfere with the normal transmission path.
Even if something goes wrong with the network stack or receiver
itself, the normal transmission path should keep working.

This can be used to implement reliable netconsole logger.

Signed-off-by: Tejun Heo <tj@kernel.org>
Cc: David Miller <davem@davemloft.net>
---
 drivers/net/netconsole.c | 238 +++++++++++++++++++++++++++++++++++++++++++++++
 1 file changed, 238 insertions(+)

diff --git a/drivers/net/netconsole.c b/drivers/net/netconsole.c
index 626d9f0..b2763e0 100644
--- a/drivers/net/netconsole.c
+++ b/drivers/net/netconsole.c
@@ -45,7 +45,10 @@
 #include <linux/kernel.h>
 #include <linux/string.h>
 #include <linux/netpoll.h>
+#include <linux/net.h>
 #include <linux/inet.h>
+#include <linux/file.h>
+#include <linux/poll.h>
 #include <linux/configfs.h>
 #include <linux/etherdevice.h>
 
@@ -89,6 +92,14 @@ static struct console netconsole_ext;
 
 static struct console netconsole;
 
+union sockaddr_in46 {
+	struct sockaddr		addr;
+	struct sockaddr_in6	in6;
+	struct sockaddr_in	in4;
+};
+
+static char *netconsole_ext_tx_buf;	/* CONSOLE_EXT_LOG_MAX */
+
 /**
  * struct netconsole_target - Represents a configured netconsole target.
  * @list:	Links this target into the target_list.
@@ -118,6 +129,14 @@ struct netconsole_target {
 	bool			disable_scheduled;
 	bool			extended;
 	struct netpoll		np;
+
+	/* response packet handling for extended netconsoles */
+	union sockaddr_in46	raddr;		/* logging target address */
+	struct file		*rx_file;	/* sock to receive responses */
+	poll_table		rx_ptable;	/* for polling the socket */
+	wait_queue_t		rx_wait;	/* ditto */
+	wait_queue_head_t	*rx_waitq;	/* ditto */
+	struct work_struct	rx_work;	/* receive & process packets */
 };
 
 #ifdef	CONFIG_NETCONSOLE_DYNAMIC
@@ -274,6 +293,219 @@ static void send_ext_msg_udp(struct netconsole_target *nt, const char *msg,
 	}
 }
 
+static bool sockaddr_in46_equal(union sockaddr_in46 *a, union sockaddr_in46 *b)
+{
+	if (a->addr.sa_family != b->addr.sa_family)
+		return false;
+	if (a->in4.sin_port != b->in4.sin_port)
+		return false;
+	if (a->addr.sa_family == AF_INET &&
+	    memcmp(&a->in4.sin_addr, &b->in4.sin_addr, sizeof(a->in4.sin_addr)))
+		return false;
+	if (a->addr.sa_family == AF_INET6 &&
+	    memcmp(&a->in6.sin6_addr, &b->in6.sin6_addr, sizeof(a->in6.sin6_addr)))
+		return false;
+	return true;
+}
+
+/**
+ * netconsole_rx_work_fn - work function to handle netconsole ack packets
+ * @work: netconsole_target->rx_work
+ *
+ * This function is scheduled when packets are received on the source port
+ * of extended netconsole target and responds to ack messages from the
+ * remote logger.  An ack message has the following format.
+ *
+ * nca <missing-seq> <missing-seq> ...
+ *
+ * There can be any number of missing-seq's as long as the whole payload
+ * fits inside MAX_PRINT_CHUNK.  This function re-transmits each message
+ * matching the missing-seq's if available.  This can be used to implement
+ * reliable logging from the receiver side.
+ *
+ * The rx path doesn't interfere with the normal tx path except for when it
+ * actually sends out the messages, and that path doesn't depend on
+ * anything more working compared to the normal tx path.  As such, this
+ * shouldn't make netconsole any less robust when things start going south.
+ */
+static void netconsole_rx_work_fn(struct work_struct *work)
+{
+	struct netconsole_target *nt =
+		container_of(work, struct netconsole_target, rx_work);
+	union sockaddr_in46 raddr;
+	struct msghdr msgh = { .msg_name = &raddr.addr, };
+	struct kvec iov;
+	char *tx_buf = netconsole_ext_tx_buf;
+	char *rx_buf, *pos, *tok;
+	u64 seq;
+	int len;
+
+	rx_buf = kmalloc(MAX_PRINT_CHUNK + 1, GFP_KERNEL);
+	if (!rx_buf && printk_ratelimit()) {
+		pr_warning("failed to allocate RX buffer\n");
+		return;
+	}
+
+	iov.iov_base = rx_buf;
+	iov.iov_len = MAX_PRINT_CHUNK;
+repeat:
+	msgh.msg_namelen = sizeof(raddr);
+	len = kernel_recvmsg(sock_from_file(nt->rx_file, &len), &msgh, &iov, 1,
+			     MAX_PRINT_CHUNK, MSG_DONTWAIT);
+	if (len < 0) {
+		if (len != -EAGAIN && printk_ratelimit())
+			pr_warning("RX failed err=%d\n", len);
+		kfree(rx_buf);
+		return;
+	}
+
+	if (!sockaddr_in46_equal(msgh.msg_name, &nt->raddr)) {
+		if (printk_ratelimit())
+			pr_warning("stray packet from %pIS:%u\n",
+				   &raddr.addr, ntohs(raddr.in4.sin_port));
+		goto repeat;
+	}
+
+	rx_buf[len] = '\0';
+	pos = rx_buf;
+	tok = strsep(&pos, " ");
+
+	/* nca header */
+	if (strncmp(tok, "nca", 3)) {
+		if (printk_ratelimit())
+			pr_warning("malformed packet from %pIS:%u\n",
+				   &nt->raddr, ntohs(nt->raddr.in4.sin_port));
+		goto repeat;
+	}
+	tok += 3;
+
+	console_lock();
+
+	/* <missing-seq>... */
+	while ((tok = strsep(&pos, " "))) {
+		if (sscanf(tok, "%llu", &seq)) {
+			len = ext_log_from_seq(tx_buf, CONSOLE_EXT_LOG_MAX, seq);
+			if (len >= 0)
+				send_ext_msg_udp(nt, tx_buf, len);
+		}
+	}
+
+	console_unlock();
+	goto repeat;
+}
+
+static int netconsole_rx_wait_fn(wait_queue_t *wait, unsigned mode, int flags,
+				 void *key)
+{
+	struct netconsole_target *nt =
+		container_of(wait, struct netconsole_target, rx_wait);
+
+	schedule_work(&nt->rx_work);
+	return 0;
+}
+
+static void netconsole_rx_ptable_queue_fn(struct file *file,
+					  wait_queue_head_t *waitq,
+					  poll_table *ptable)
+{
+	struct netconsole_target *nt =
+		container_of(ptable, struct netconsole_target, rx_ptable);
+
+	nt->rx_waitq = waitq;
+	add_wait_queue(waitq, &nt->rx_wait);
+}
+
+static void netconsole_enable_rx(struct netconsole_target *nt)
+{
+	union sockaddr_in46 laddr = { }, raddr = { };
+	struct socket *sock;
+	struct file *file;
+	int addr_len, ret;
+
+	if (!netconsole_ext_tx_buf) {
+		char *buf;
+
+		buf = kmalloc(CONSOLE_EXT_LOG_MAX, GFP_KERNEL);
+		if (!buf) {
+			kfree(buf);
+			pr_warning("failed to allocate TX buffer\n");
+			return;
+		}
+
+		if (cmpxchg(&netconsole_ext_tx_buf, NULL, buf))
+			kfree(buf);
+	}
+
+	if (!nt->np.ipv6) {
+		laddr.in4.sin_family = AF_INET;
+		laddr.in4.sin_port = htons(nt->np.local_port);
+		laddr.in4.sin_addr = nt->np.local_ip.in;
+		raddr.in4.sin_family = AF_INET;
+		raddr.in4.sin_port = htons(nt->np.remote_port);
+		raddr.in4.sin_addr = nt->np.remote_ip.in;
+		addr_len = sizeof(laddr.in4);
+	} else {
+		laddr.in6.sin6_family = AF_INET6;
+		laddr.in6.sin6_port = htons(nt->np.local_port);
+		laddr.in6.sin6_addr = nt->np.local_ip.in6;
+		raddr.in6.sin6_family = AF_INET6;
+		raddr.in6.sin6_port = htons(nt->np.remote_port);
+		raddr.in6.sin6_addr = nt->np.remote_ip.in6;
+		addr_len = sizeof(laddr.in6);
+	}
+
+	ret = sock_create_kern(laddr.addr.sa_family, SOCK_DGRAM, IPPROTO_UDP,
+			       &sock);
+	if (ret) {
+		pr_warning("failed to create rx socket, err=%d\n", ret);
+		return;
+	}
+
+	file = sock_alloc_file(sock, 0, NULL);
+	if (IS_ERR(file)) {
+		pr_warning("failed to rx socket file, err=%ld\n", PTR_ERR(file));
+		sock_release(sock);
+		return;
+	}
+
+	ret = sock->ops->bind(sock, &laddr.addr, addr_len);
+	if (ret) {
+		pr_warning("failed to bind rx socket at %pIS:%u, err=%d\n",
+			   &laddr.addr, ntohs(laddr.in4.sin_port), ret);
+		fput(file);
+		return;
+	}
+
+	nt->raddr = raddr;
+	init_poll_funcptr(&nt->rx_ptable, netconsole_rx_ptable_queue_fn);
+	init_waitqueue_func_entry(&nt->rx_wait, netconsole_rx_wait_fn);
+	INIT_WORK(&nt->rx_work, netconsole_rx_work_fn);
+
+	ret = file->f_op->poll(file, &nt->rx_ptable);
+	if (ret < 0) {
+		pr_warning("failed to poll rx socket, err=%d\n", ret);
+		fput(file);
+		return;
+	}
+
+	if (ret & POLLIN)
+		schedule_work(&nt->rx_work);
+
+	nt->rx_file = file;
+}
+
+static void netconsole_disable_rx(struct netconsole_target *nt)
+{
+	if (!nt->rx_file)
+		return;
+
+	remove_wait_queue(nt->rx_waitq, &nt->rx_wait);
+	cancel_work_sync(&nt->rx_work);
+
+	fput(nt->rx_file);
+	nt->rx_file = NULL;
+}
+
 static int netconsole_enable(struct netconsole_target *nt)
 {
 	int err;
@@ -285,6 +517,9 @@ static int netconsole_enable(struct netconsole_target *nt)
 	if (err)
 		return err;
 
+	if (nt->extended)
+		netconsole_enable_rx(nt);
+
 	console_lock();
 	nt->enabled = true;
 	console_unlock();
@@ -305,6 +540,7 @@ static void netconsole_disable(struct netconsole_target *nt)
 		nt->enabled = false;
 		console_unlock();
 
+		netconsole_disable_rx(nt);
 		netpoll_cleanup(&nt->np);
 	}
 }
@@ -974,6 +1210,8 @@ static void __init_or_module netconsole_destroy_all(void)
 		netconsole_disable(nt);
 		kfree(nt);
 	}
+
+	kfree(netconsole_ext_tx_buf);
 }
 
 static int __init init_netconsole(void)
-- 
2.1.0
