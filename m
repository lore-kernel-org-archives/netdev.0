From: Stephen Hemminger <shemminger@osdl.org>
Subject: [PATCH 2/5] tcp: add tcp_available_congestion_control sysctl
Date: Tue, 31 Oct 2006 15:01:42 -0800
Message-ID: <20061031230213.704489579@osdl.org>
References: <20061031230140.191929094@osdl.org>
Cc: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from smtp.osdl.org ([65.172.181.4]:15802 "EHLO smtp.osdl.org")
	by vger.kernel.org with ESMTP id S1423853AbWJaXDq (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 31 Oct 2006 18:03:46 -0500
To: David Miller <davem@davemloft.net>
Content-Disposition: inline; filename=tcp-available.patch
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Create /proc/sys/net/ipv4/tcp_available_congestion_control
that reflects currently available TCP choices.

Signed-off-by: Stephen Hemminger <shemminger@osdl.org>

---
 Documentation/networking/ip-sysctl.txt |    6 ++++++
 include/linux/sysctl.h                 |    2 ++
 include/net/tcp.h                      |    4 ++++
 net/ipv4/sysctl_net_ipv4.c             |   24 ++++++++++++++++++++++++
 net/ipv4/tcp_cong.c                    |   16 ++++++++++++++++
 5 files changed, 52 insertions(+)

--- tcp.orig/include/linux/sysctl.h	2006-10-31 14:57:56.000000000 -0800
+++ tcp/include/linux/sysctl.h	2006-10-31 14:58:53.000000000 -0800
@@ -418,6 +418,7 @@
 	NET_CIPSOV4_CACHE_BUCKET_SIZE=119,
 	NET_CIPSOV4_RBM_OPTFMT=120,
 	NET_CIPSOV4_RBM_STRICTVALID=121,
+	NET_TCP_AVAIL_CONG_CONTROL=122,
 };
 
 enum {
--- tcp.orig/include/net/tcp.h	2006-10-31 14:57:56.000000000 -0800
+++ tcp/include/net/tcp.h	2006-10-31 14:58:39.000000000 -0800
@@ -621,6 +621,9 @@
  * Interface for adding new TCP congestion control handlers
  */
 #define TCP_CA_NAME_MAX	16
+#define TCP_CA_MAX	128
+#define TCP_CA_BUF_MAX	(TCP_CA_NAME_MAX*TCP_CA_MAX)
+
 struct tcp_congestion_ops {
 	struct list_head	list;
 
@@ -660,6 +663,7 @@
 extern void tcp_cleanup_congestion_control(struct sock *sk);
 extern int tcp_set_default_congestion_control(const char *name);
 extern void tcp_get_default_congestion_control(char *name);
+extern void tcp_get_available_congestion_control(char *buf, size_t len);
 extern int tcp_set_congestion_control(struct sock *sk, const char *name);
 extern void tcp_slow_start(struct tcp_sock *tp);
 
--- tcp.orig/net/ipv4/sysctl_net_ipv4.c	2006-10-31 14:58:36.000000000 -0800
+++ tcp/net/ipv4/sysctl_net_ipv4.c	2006-10-31 14:58:39.000000000 -0800
@@ -129,6 +129,23 @@
 	return ret;
 }
 
+static int proc_tcp_available_congestion_control(ctl_table *ctl,
+						 int write, struct file * filp,
+						 void __user *buffer, size_t *lenp,
+						 loff_t *ppos)
+{
+	ctl_table tbl = { .maxlen = TCP_CA_BUF_MAX, };
+	int ret;
+
+	tbl.data = kmalloc(tbl.maxlen, GFP_USER);
+	if (!tbl.data)
+		return -ENOMEM;
+	tcp_get_available_congestion_control(tbl.data, TCP_CA_BUF_MAX);
+	ret = proc_dostring(&tbl, write, filp, buffer, lenp, ppos);
+	kfree(tbl.data);
+	return ret;
+}
+
 ctl_table ipv4_table[] = {
         {
 		.ctl_name	= NET_IPV4_TCP_TIMESTAMPS,
@@ -731,6 +748,13 @@
 		.proc_handler	= &proc_dointvec,
 	},
 #endif /* CONFIG_NETLABEL */
+	{
+		.ctl_name	= NET_TCP_AVAIL_CONG_CONTROL,
+		.procname	= "tcp_available_congestion_control",
+		.maxlen		= TCP_CA_BUF_MAX,
+		.mode		= 0444,
+		.proc_handler   = &proc_tcp_available_congestion_control,
+	},
 	{ .ctl_name = 0 }
 };
 
--- tcp.orig/net/ipv4/tcp_cong.c	2006-10-31 14:58:36.000000000 -0800
+++ tcp/net/ipv4/tcp_cong.c	2006-10-31 14:58:39.000000000 -0800
@@ -139,6 +139,22 @@
 late_initcall(tcp_congestion_default);
 
 
+/* Build string with list of available congestion control values */
+void tcp_get_available_congestion_control(char *buf, size_t maxlen)
+{
+	struct tcp_congestion_ops *ca;
+	size_t offs = 0;
+
+	rcu_read_lock();
+	list_for_each_entry_rcu(ca, &tcp_cong_list, list) {
+		offs += snprintf(buf + offs, maxlen - offs,
+				 "%s%s",
+				 offs == 0 ? "" : " ", ca->name);
+
+	}
+	rcu_read_unlock();
+}
+
 /* Get current default congestion control */
 void tcp_get_default_congestion_control(char *name)
 {
--- tcp.orig/Documentation/networking/ip-sysctl.txt	2006-10-31 14:57:56.000000000 -0800
+++ tcp/Documentation/networking/ip-sysctl.txt	2006-10-31 14:58:39.000000000 -0800
@@ -351,10 +351,16 @@
 	where packet loss is typically due to random radio interference
 	rather than intermediate router congestion.
 
+tcp_available_congestion_control - STRING
+	Shows the available congestion control choices that are registered.
+	More congestion control algorithms may be available as modules,
+	but not loaded.
+
 tcp_congestion_control - STRING
 	Set the congestion control algorithm to be used for new
 	connections. The algorithm "reno" is always available, but
 	additional choices may be available based on kernel configuration.
+	Default is set as part of kernel configuration.
 
 somaxconn - INTEGER
 	Limit of socket listen() backlog, known in userspace as SOMAXCONN.

--
Stephen Hemminger <shemminger@osdl.org>

