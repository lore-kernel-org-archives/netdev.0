From: Stephen Hemminger <shemminger@osdl.org>
Subject: [RFC] tcp: available congetsion control
Date: Fri, 27 Oct 2006 20:10:37 -0700
Message-ID: <20061027201037.1bc85ae1@localhost.localdomain>
References: <20061027145913.04dc0e5f@dxpl.pdx.osdl.net>
	<20061027.151238.59655130.davem@davemloft.net>
	<20061027152149.42bcb539@dxpl.pdx.osdl.net>
	<20061027.152444.48528262.davem@davemloft.net>
	<20061027174816.29bd6563@localhost.localdomain>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Cc: David Miller <davem@davemloft.net>, hagen@jauu.net,
	jheffner@psc.edu, netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from smtp.osdl.org ([65.172.181.4]:60069 "EHLO smtp.osdl.org")
	by vger.kernel.org with ESMTP id S1751157AbWJ1DLV (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 27 Oct 2006 23:11:21 -0400
To: Stephen Hemminger <shemminger@osdl.org>
In-Reply-To: <20061027174816.29bd6563@localhost.localdomain>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Nice way to see what congestion control modules are loaded.
It does impose a soft limit of 32 possibilities.

Signed-off-by: Stephen Hemminger <shemminger@osdl.org>

---
 include/linux/sysctl.h     |    1 +
 include/net/tcp.h          |    3 +++
 net/ipv4/sysctl_net_ipv4.c |   25 ++++++++++++++++++++++++-
 net/ipv4/tcp_cong.c        |   14 ++++++++++++++
 4 files changed, 42 insertions(+), 1 deletion(-)

--- skge.orig/include/linux/sysctl.h
+++ skge/include/linux/sysctl.h
@@ -418,6 +418,7 @@ enum
 	NET_CIPSOV4_CACHE_BUCKET_SIZE=119,
 	NET_CIPSOV4_RBM_OPTFMT=120,
 	NET_CIPSOV4_RBM_STRICTVALID=121,
+	NET_TCP_AVAIL_CONG_CONTROL=122,
 };
 
 enum {
--- skge.orig/include/net/tcp.h
+++ skge/include/net/tcp.h
@@ -621,6 +621,8 @@ enum tcp_ca_event {
  * Interface for adding new TCP congestion control handlers
  */
 #define TCP_CA_NAME_MAX	16
+#define TCP_CA_MAX	32
+
 struct tcp_congestion_ops {
 	struct list_head	list;
 
@@ -659,6 +661,7 @@ extern void tcp_unregister_congestion_co
 extern void tcp_init_congestion_control(struct sock *sk);
 extern void tcp_cleanup_congestion_control(struct sock *sk);
 extern int tcp_set_default_congestion_control(const char *name);
+extern void tcp_get_available_congestion_control(char *name, int maxlen);
 extern void tcp_get_default_congestion_control(char *name);
 extern int tcp_set_congestion_control(struct sock *sk, const char *name);
 extern void tcp_slow_start(struct tcp_sock *tp);
--- skge.orig/net/ipv4/sysctl_net_ipv4.c
+++ skge/net/ipv4/sysctl_net_ipv4.c
@@ -108,6 +108,22 @@ static int proc_tcp_congestion_control(c
 	return ret;
 }
 
+static int proc_tcp_available_congestion_control(ctl_table *ctl,
+						 int write, struct file * filp,
+						 void __user *buffer, size_t *lenp,
+						 loff_t *ppos)
+{
+	char val[TCP_CA_MAX*(TCP_CA_NAME_MAX+1)];
+	ctl_table tbl = {
+		.data = val,
+		.maxlen = TCP_CA_MAX*(TCP_CA_NAME_MAX+1),
+	};
+
+	tcp_get_available_congestion_control(val, tbl.maxlen);
+
+	return proc_dostring(&tbl, write, filp, buffer, lenp, ppos);
+}
+
 static int sysctl_tcp_congestion_control(ctl_table *table, int __user *name,
 					 int nlen, void __user *oldval,
 					 size_t __user *oldlenp,
@@ -133,9 +149,9 @@ static int __init tcp_congestion_default
 {
 	return tcp_set_default_congestion_control(CONFIG_DEFAULT_TCP_CONG);
 }
-
 late_initcall(tcp_congestion_default);
 
+
 ctl_table ipv4_table[] = {
         {
 		.ctl_name	= NET_IPV4_TCP_TIMESTAMPS,
@@ -738,6 +754,13 @@ ctl_table ipv4_table[] = {
 		.proc_handler	= &proc_dointvec,
 	},
 #endif /* CONFIG_NETLABEL */
+	{
+		.ctl_name	= NET_TCP_AVAIL_CONG_CONTROL,
+		.procname	= "tcp_available_congestion_control",
+		.mode		= 0444,
+		.maxlen		= TCP_CA_MAX*(TCP_CA_NAME_MAX+1),
+		.proc_handler   = &proc_tcp_available_congestion_control,
+	},
 	{ .ctl_name = 0 }
 };
 
--- skge.orig/net/ipv4/tcp_cong.c
+++ skge/net/ipv4/tcp_cong.c
@@ -144,6 +144,20 @@ void tcp_get_default_congestion_control(
 	rcu_read_unlock();
 }
 
+/* Build string with list of available congestion control values */
+void tcp_get_available_congestion_control(char *name, int maxlen)
+{
+	struct tcp_congestion_ops *ca;
+	int offs = 0;
+
+	rcu_read_lock();
+	list_for_each_entry_rcu(ca, &tcp_cong_list, list) {
+		offs += snprintf(name + offs, maxlen - offs, "%s%s",
+				 offs == 0 ? "" : " ", ca->name);
+	}
+	rcu_read_unlock();
+}
+
 /* Change congestion control for socket */
 int tcp_set_congestion_control(struct sock *sk, const char *name)
 {
