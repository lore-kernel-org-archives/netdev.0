From: Stephen Hemminger <shemminger@osdl.org>
Subject: [PATCH 3/5] tcp: restrict congestion control choices
Date: Tue, 31 Oct 2006 15:01:43 -0800
Message-ID: <20061031230213.880147861@osdl.org>
References: <20061031230140.191929094@osdl.org>
Cc: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from smtp.osdl.org ([65.172.181.4]:25786 "EHLO smtp.osdl.org")
	by vger.kernel.org with ESMTP id S1423856AbWJaXEP (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 31 Oct 2006 18:04:15 -0500
To: David Miller <davem@davemloft.net>
Content-Disposition: inline; filename=tcp-allowed.patch
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Allow normal users to only choose among a restricted set of congestion
control choices.  The default is reno and what ever has been configured
as default. But the policy can be changed by administrator at any time.

For example, to allow any choice:
    cp /proc/sys/net/ipv4/tcp_available_congestion_control \
       /proc/sys/net/ipv4/tcp_allowed_congestion_control

Signed-off-by: Stephen Hemminger <shemminger@osdl.org>

---
 Documentation/networking/ip-sysctl.txt |    6 +++
 include/net/tcp.h                      |    3 +
 net/ipv4/sysctl_net_ipv4.c             |   52 ++++++++++++++++++++++++++
 net/ipv4/tcp_cong.c                    |   64 +++++++++++++++++++++++++++++++++
 4 files changed, 125 insertions(+)

--- tcp.orig/include/net/tcp.h	2006-10-31 14:58:39.000000000 -0800
+++ tcp/include/net/tcp.h	2006-10-31 14:59:20.000000000 -0800
@@ -626,6 +626,7 @@
 
 struct tcp_congestion_ops {
 	struct list_head	list;
+	int	non_restricted;
 
 	/* initialize private data (optional) */
 	void (*init)(struct sock *sk);
@@ -664,6 +665,8 @@
 extern int tcp_set_default_congestion_control(const char *name);
 extern void tcp_get_default_congestion_control(char *name);
 extern void tcp_get_available_congestion_control(char *buf, size_t len);
+extern void tcp_get_allowed_congestion_control(char *buf, size_t len);
+extern int tcp_set_allowed_congestion_control(char *allowed);
 extern int tcp_set_congestion_control(struct sock *sk, const char *name);
 extern void tcp_slow_start(struct tcp_sock *tp);
 
--- tcp.orig/net/ipv4/sysctl_net_ipv4.c	2006-10-31 14:58:39.000000000 -0800
+++ tcp/net/ipv4/sysctl_net_ipv4.c	2006-10-31 14:59:20.000000000 -0800
@@ -146,6 +146,50 @@
 	return ret;
 }
 
+static int proc_allowed_congestion_control(ctl_table *ctl,
+					   int write, struct file * filp,
+					   void __user *buffer, size_t *lenp,
+					   loff_t *ppos)
+{
+	ctl_table tbl = { .maxlen = TCP_CA_BUF_MAX };
+	int ret;
+
+	tbl.data = kmalloc(tbl.maxlen, GFP_USER);
+	if (!tbl.data)
+		return -ENOMEM;
+
+	tcp_get_allowed_congestion_control(tbl.data, tbl.maxlen);
+	ret = proc_dostring(&tbl, write, filp, buffer, lenp, ppos);
+	if (write && ret == 0)
+		ret = tcp_set_allowed_congestion_control(tbl.data);
+	kfree(tbl.data);
+	return ret;
+}
+
+static int strategy_allowed_congestion_control(ctl_table *table, int __user *name,
+					       int nlen, void __user *oldval,
+					       size_t __user *oldlenp,
+					       void __user *newval, size_t newlen,
+					       void **context)
+{
+	ctl_table tbl = { .maxlen = TCP_CA_BUF_MAX };
+	int ret;
+
+	tbl.data = kmalloc(tbl.maxlen, GFP_USER);
+	if (!tbl.data)
+		return -ENOMEM;
+
+	tcp_get_available_congestion_control(tbl.data, tbl.maxlen);
+	ret = sysctl_string(&tbl, name, nlen, oldval, oldlenp, newval, newlen,
+			    context);
+	if (ret == 0 && newval && newlen)
+		ret = tcp_set_allowed_congestion_control(tbl.data);
+	kfree(tbl.data);
+
+	return ret;
+
+}
+
 ctl_table ipv4_table[] = {
         {
 		.ctl_name	= NET_IPV4_TCP_TIMESTAMPS,
@@ -755,6 +799,14 @@
 		.mode		= 0444,
 		.proc_handler   = &proc_tcp_available_congestion_control,
 	},
+	{
+		.ctl_name	= NET_TCP_ALLOWED_CONG_CONTROL,
+		.procname	= "tcp_allowed_congestion_control",
+		.maxlen		= TCP_CA_BUF_MAX,
+		.mode		= 0644,
+		.proc_handler   = &proc_allowed_congestion_control,
+		.strategy	= &strategy_allowed_congestion_control,
+	},
 	{ .ctl_name = 0 }
 };
 
--- tcp.orig/net/ipv4/tcp_cong.c	2006-10-31 14:58:39.000000000 -0800
+++ tcp/net/ipv4/tcp_cong.c	2006-10-31 15:00:26.000000000 -0800
@@ -123,6 +123,7 @@
 #endif
 
 	if (ca) {
+		ca->non_restricted = 1;	/* default is always allowed */
 		list_move(&ca->list, &tcp_cong_list);
 		ret = 0;
 	}
@@ -168,6 +169,64 @@
 	rcu_read_unlock();
 }
 
+/* Built list of non-restricted congestion control values */
+void tcp_get_allowed_congestion_control(char *buf, size_t maxlen)
+{
+	struct tcp_congestion_ops *ca;
+	size_t offs = 0;
+
+	*buf = '\0';
+	rcu_read_lock();
+	list_for_each_entry_rcu(ca, &tcp_cong_list, list) {
+		if (!ca->non_restricted)
+			continue;
+		offs += snprintf(buf + offs, maxlen - offs,
+				 "%s%s",
+				 offs == 0 ? "" : " ", ca->name);
+
+	}
+	rcu_read_unlock();
+}
+
+/* Change list of non-restricted congestion control */
+int tcp_set_allowed_congestion_control(char *val)
+{
+	struct tcp_congestion_ops *ca;
+	char *clone, *name;
+	int ret = 0;
+
+	clone = kstrdup(val, GFP_USER);
+	if (!clone)
+		return -ENOMEM;
+
+	spin_lock(&tcp_cong_list_lock);
+	/* pass 1 check for bad entries */
+	while ((name = strsep(&clone, " ")) && *name) {
+		ca = tcp_ca_find(name);
+		if (!ca) {
+			ret = -ENOENT;
+			goto out;
+		}
+	}
+
+	/* pass 2 clear */
+	list_for_each_entry_rcu(ca, &tcp_cong_list, list)
+		ca->non_restricted = 0;
+
+	/* pass 3 mark as allowed */
+	while ((name = strsep(&val, " ")) && *name) {
+		ca = tcp_ca_find(name);
+		WARN_ON(!ca);
+		if (ca)
+			ca->non_restricted = 1;
+	}
+out:
+	spin_unlock(&tcp_cong_list_lock);
+
+	return ret;
+}
+
+
 /* Change congestion control for socket */
 int tcp_set_congestion_control(struct sock *sk, const char *name)
 {
@@ -183,6 +242,9 @@
 	if (!ca)
 		err = -ENOENT;
 
+	else if (!(ca->non_restricted || capable(CAP_NET_ADMIN)))
+		err = -EPERM;
+
 	else if (!try_module_get(ca->owner))
 		err = -EBUSY;
 
@@ -284,6 +346,7 @@
 
 struct tcp_congestion_ops tcp_reno = {
 	.name		= "reno",
+	.non_restricted = 1,
 	.owner		= THIS_MODULE,
 	.ssthresh	= tcp_reno_ssthresh,
 	.cong_avoid	= tcp_reno_cong_avoid,
--- tcp.orig/Documentation/networking/ip-sysctl.txt	2006-10-31 14:58:39.000000000 -0800
+++ tcp/Documentation/networking/ip-sysctl.txt	2006-10-31 14:59:20.000000000 -0800
@@ -351,6 +351,12 @@
 	where packet loss is typically due to random radio interference
 	rather than intermediate router congestion.
 
+tcp_allowed_congestion_control - STRING
+	Show/set the congestion control choices available to non-privileged
+	processes. The list is a subset of those listed in
+	tcp_available_congestion_control.
+	Default is "reno" and the default setting (tcp_congestion_control).
+
 tcp_available_congestion_control - STRING
 	Shows the available congestion control choices that are registered.
 	More congestion control algorithms may be available as modules,
--- tcp.orig/include/linux/sysctl.h	2006-10-31 14:59:28.000000000 -0800
+++ tcp/include/linux/sysctl.h	2006-10-31 14:59:40.000000000 -0800
@@ -419,6 +419,7 @@
 	NET_CIPSOV4_RBM_OPTFMT=120,
 	NET_CIPSOV4_RBM_STRICTVALID=121,
 	NET_TCP_AVAIL_CONG_CONTROL=122,
+	NET_TCP_ALLOWED_CONG_CONTROL=123,
 };
 
 enum {

--
Stephen Hemminger <shemminger@osdl.org>

