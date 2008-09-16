From: =?utf-8?q?R=C3=A9mi=20Denis-Courmont?=
	<remi.denis-courmont@nokia.com>
Subject: [PATCH 12/14] Phonet: proc interface for port range
Date: Tue, 16 Sep 2008 18:08:12 +0300
Message-ID: <1221577694-4513-12-git-send-email-remi.denis-courmont@nokia.com>
References: <200809161757.38571.remi.denis-courmont@nokia.com>
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from smtp.nokia.com ([192.100.122.233]:44486 "EHLO
	mgw-mx06.nokia.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1754163AbYIPPIb (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 16 Sep 2008 11:08:31 -0400
Received: from vaebh105.NOE.Nokia.com (vaebh105.europe.nokia.com [10.160.244.31])
	by mgw-mx06.nokia.com (Switch-3.2.6/Switch-3.2.6) with ESMTP id m8GF8KFW000538
	for <netdev@vger.kernel.org>; Tue, 16 Sep 2008 18:08:28 +0300
In-Reply-To: <200809161757.38571.remi.denis-courmont@nokia.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Phonet endpoints are bound to individual ports.
This provides a /proc/sys/net/phonet (or sysctl) interface for
selecting the range of automatically allocated ports (much like the
ip_local_port_range with IPv4).

Signed-off-by: Remi Denis-Courmont <remi.denis-courmont@nokia.com>
---
 include/net/phonet/phonet.h |    3 +
 net/phonet/Makefile         |    1 +
 net/phonet/af_phonet.c      |    3 +
 net/phonet/socket.c         |    3 +-
 net/phonet/sysctl.c         |  113 +++++++++++++++++++++++++++++++++++++++++++
 5 files changed, 122 insertions(+), 1 deletions(-)
 create mode 100644 net/phonet/sysctl.c

diff --git a/include/net/phonet/phonet.h b/include/net/phonet/phonet.h
index ead764d..8555bc7 100644
--- a/include/net/phonet/phonet.h
+++ b/include/net/phonet/phonet.h
@@ -45,6 +45,7 @@ struct pn_sock {
 extern const struct proto_ops phonet_dgram_ops;
 
 struct sock *pn_find_sock_by_sa(const struct sockaddr_pn *sa);
+void phonet_get_local_port_range(int *min, int *max);
 void pn_sock_hash(struct sock *sk);
 void pn_sock_unhash(struct sock *sk);
 int pn_sock_get_port(struct sock *sk, unsigned short sport);
@@ -93,6 +94,8 @@ int phonet_proto_register(int protocol, struct phonet_protocol *pp);
 void phonet_proto_unregister(int protocol, struct phonet_protocol *pp);
 
 void phonet_socket_init(void);
+int phonet_sysctl_init(void);
+void phonet_sysctl_exit(void);
 void phonet_netlink_register(void);
 int isi_register(void);
 void isi_unregister(void);
diff --git a/net/phonet/Makefile b/net/phonet/Makefile
index d218abc..ae9c3ed 100644
--- a/net/phonet/Makefile
+++ b/net/phonet/Makefile
@@ -5,4 +5,5 @@ phonet-objs := \
 	pn_netlink.o \
 	socket.o \
 	datagram.o \
+	sysctl.o \
 	af_phonet.o
diff --git a/net/phonet/af_phonet.c b/net/phonet/af_phonet.c
index 2593d9c..c18664d 100644
--- a/net/phonet/af_phonet.c
+++ b/net/phonet/af_phonet.c
@@ -367,6 +367,7 @@ static int __init phonet_init(void)
 	}
 
 	dev_add_pack(&phonet_packet_type);
+	phonet_sysctl_init();
 	phonet_netlink_register();
 
 	err = isi_register();
@@ -375,6 +376,7 @@ static int __init phonet_init(void)
 	return 0;
 
 err2:
+	phonet_sysctl_exit();
 	phonet_device_exit();
 unregister:
 	sock_unregister(AF_PHONET);
@@ -384,6 +386,7 @@ unregister:
 static void __exit phonet_exit(void)
 {
 	isi_unregister();
+	phonet_sysctl_exit();
 	sock_unregister(AF_PHONET);
 	dev_remove_pack(&phonet_packet_type);
 	phonet_device_exit();
diff --git a/net/phonet/socket.c b/net/phonet/socket.c
index 0e28327..ba2a975 100644
--- a/net/phonet/socket.c
+++ b/net/phonet/socket.c
@@ -268,8 +268,9 @@ int pn_sock_get_port(struct sock *sk, unsigned short sport)
 
 	if (!sport) {
 		/* search free port */
-		int port, pmin = 0x40, pmax = 0x7f;
+		int port, pmin, pmax;
 
+		phonet_get_local_port_range(&pmin, &pmax);
 		for (port = pmin; port <= pmax; port++) {
 			port_cur++;
 			if (port_cur < pmin || port_cur > pmax)
diff --git a/net/phonet/sysctl.c b/net/phonet/sysctl.c
new file mode 100644
index 0000000..600a430
--- /dev/null
+++ b/net/phonet/sysctl.c
@@ -0,0 +1,113 @@
+/*
+ * File: sysctl.c
+ *
+ * Phonet /proc/sys/net/phonet interface implementation
+ *
+ * Copyright (C) 2008 Nokia Corporation.
+ *
+ * Contact: Remi Denis-Courmont <remi.denis-courmont@nokia.com>
+ *
+ * This program is free software; you can redistribute it and/or
+ * modify it under the terms of the GNU General Public License
+ * version 2 as published by the Free Software Foundation.
+ *
+ * This program is distributed in the hope that it will be useful, but
+ * WITHOUT ANY WARRANTY; without even the implied warranty of
+ * MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the GNU
+ * General Public License for more details.
+ *
+ * You should have received a copy of the GNU General Public License
+ * along with this program; if not, write to the Free Software
+ * Foundation, Inc., 51 Franklin St, Fifth Floor, Boston, MA
+ * 02110-1301 USA
+ */
+
+#include <linux/seqlock.h>
+#include <linux/sysctl.h>
+#include <linux/errno.h>
+#include <linux/init.h>
+
+#define DYNAMIC_PORT_MIN	0x40
+#define DYNAMIC_PORT_MAX	0x7f
+
+static DEFINE_SEQLOCK(local_port_range_lock);
+static int local_port_range_min[2] = {0, 0};
+static int local_port_range_max[2] = {1023, 1023};
+static int local_port_range[2] = {DYNAMIC_PORT_MIN, DYNAMIC_PORT_MAX};
+static struct ctl_table_header *phonet_table_hrd;
+
+static void set_local_port_range(int range[2])
+{
+	write_seqlock(&local_port_range_lock);
+	local_port_range[0] = range[0];
+	local_port_range[1] = range[1];
+	write_sequnlock(&local_port_range_lock);
+}
+
+void phonet_get_local_port_range(int *min, int *max)
+{
+	unsigned seq;
+	do {
+		seq = read_seqbegin(&local_port_range_lock);
+		if (min)
+			*min = local_port_range[0];
+		if (max)
+			*max = local_port_range[1];
+	} while (read_seqretry(&local_port_range_lock, seq));
+}
+
+static int proc_local_port_range(ctl_table *table, int write, struct file *filp,
+				void __user *buffer,
+				size_t *lenp, loff_t *ppos)
+{
+	int ret;
+	int range[2] = {local_port_range[0], local_port_range[1]};
+	ctl_table tmp = {
+		.data = &range,
+		.maxlen = sizeof(range),
+		.mode = table->mode,
+		.extra1 = &local_port_range_min,
+		.extra2 = &local_port_range_max,
+	};
+
+	ret = proc_dointvec_minmax(&tmp, write, filp, buffer, lenp, ppos);
+
+	if (write && ret == 0) {
+		if (range[1] < range[0])
+			ret = -EINVAL;
+		else
+			set_local_port_range(range);
+	}
+
+	return ret;
+}
+
+static struct ctl_table phonet_table[] = {
+	{
+		.ctl_name	= CTL_UNNUMBERED,
+		.procname	= "local_port_range",
+		.data		= &local_port_range,
+		.maxlen		= sizeof(local_port_range),
+		.mode		= 0644,
+		.proc_handler	= &proc_local_port_range,
+		.strategy	= NULL,
+	},
+	{ .ctl_name = 0 }
+};
+
+struct ctl_path phonet_ctl_path[] = {
+	{ .procname = "net", .ctl_name = CTL_NET, },
+	{ .procname = "phonet", .ctl_name = CTL_UNNUMBERED, },
+	{ },
+};
+
+int __init phonet_sysctl_init(void)
+{
+	phonet_table_hrd = register_sysctl_paths(phonet_ctl_path, phonet_table);
+	return phonet_table_hrd == NULL ? -ENOMEM : 0;
+}
+
+void phonet_sysctl_exit(void)
+{
+	unregister_sysctl_table(phonet_table_hrd);
+}
-- 
1.5.4.3

