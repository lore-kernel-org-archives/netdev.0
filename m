From: Lucian Adrian Grijincu <lucian.grijincu@gmail.com>
Subject: [PATCH 04/24] sysctl: cookie: add netns_proc_dointvec and other netns_proc_* proc_handlers
Date: Sat,  2 Apr 2011 04:53:18 +0200
Message-ID: <ee0ed8a6f545609f39859047e2b1e7b4d066491d.1301711868.git.lucian.grijincu__36739.3720815473$1301713227$gmane$org@gmail.com>
References: <cover.1301711868.git.lucian.grijincu@gmail.com>
Cc: Lucian Adrian Grijincu <lucian.grijincu@gmail.com>
To: "'David S . Miller'" <davem@davemloft.net>,
	Alexey Dobriyan <adobriyan@gmail.com>,
	"Eric W . Biederman" <ebiederm@xmission.com>,
	Octavian Purdila <tavi@cs.pub.ro>,
	linux-kernel@vger.
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-wy0-f174.google.com ([74.125.82.174]:32917 "EHLO
	mail-wy0-f174.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1753127Ab1DBCyQ (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 1 Apr 2011 22:54:16 -0400
In-Reply-To: <cover.1301711868.git.lucian.grijincu@gmail.com>
In-Reply-To: <cover.1301711868.git.lucian.grijincu@gmail.com>
References: <cover.1301711868.git.lucian.grijincu@gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Use these handlers when you want to change a netns dependant
variable. The following restrictions apply:

- these handlers must receive as cookie a 'struct net*'

- the data field of ctl_table* must be at a constant offset from
  the init_net structure. e.g.: &init_net.member1.member2..memberN

- these handlers will call their equivalent handler with a
  ctl_table with data of the form: net->member1.member2..memberN

Signed-off-by: Lucian Adrian Grijincu <lucian.grijincu@gmail.com>
---
 include/net/net_namespace.h |   33 +++++++++++++++++++++++++++++++++
 net/sysctl_net.c            |   22 ++++++++++++++++++++++
 2 files changed, 55 insertions(+), 0 deletions(-)

diff --git a/include/net/net_namespace.h b/include/net/net_namespace.h
index 3ae4919..86c6e57 100644
--- a/include/net/net_namespace.h
+++ b/include/net/net_namespace.h
@@ -278,4 +278,37 @@ extern struct ctl_table_header *register_net_sysctl_rotable(
 	const struct ctl_path *path, struct ctl_table *table);
 extern void unregister_net_sysctl_table(struct ctl_table_header *header);
 
+
+
+/*
+ * Use these handlers when you want to change a netns dependant
+ * variable. The following restrictions apply:
+ *
+ * - these handlers must receive as cookie a 'struct net*'
+ *
+ * - the data field of ctl_table* must be at a constant offset from
+ *   the init_net structure. e.g.: &init_net.member1.member2..memberN
+ *
+ * - these handlers will call their equivalent handler with a
+ *   ctl_table with data of the form: net->member1.member2..memberN
+ */
+extern int netns_proc_dostring(struct ctl_table *,
+		int, void __user *, size_t *, loff_t *, void *net);
+extern int netns_proc_dointvec(struct ctl_table *, int,
+		void __user *, size_t *, loff_t *, void *net);
+extern int netns_proc_dointvec_minmax(struct ctl_table *, int,
+		void __user *, size_t *, loff_t *, void *net);
+extern int netns_proc_dointvec_jiffies(struct ctl_table *, int,
+		void __user *, size_t *, loff_t *, void *net);
+extern int netns_proc_dointvec_userhz_jiffies(struct ctl_table *, int,
+		void __user *, size_t *, loff_t *, void *net);
+extern int netns_proc_dointvec_ms_jiffies(struct ctl_table *, int,
+		void __user *, size_t *, loff_t *, void *net);
+extern int netns_proc_doulongvec_minmax(struct ctl_table *, int,
+		void __user *, size_t *, loff_t *, void *net);
+extern int netns_proc_doulongvec_ms_jiffies_minmax(struct ctl_table *table, int,
+		void __user *, size_t *, loff_t *, void *net);
+extern int netns_proc_do_large_bitmap(struct ctl_table *, int,
+		void __user *, size_t *, loff_t *, void *net);
+
 #endif /* __NET_NET_NAMESPACE_H */
diff --git a/net/sysctl_net.c b/net/sysctl_net.c
index 9dadd17..dfff9a3 100644
--- a/net/sysctl_net.c
+++ b/net/sysctl_net.c
@@ -127,3 +127,25 @@ void unregister_net_sysctl_table(struct ctl_table_header *header)
 	unregister_sysctl_table(header);
 }
 EXPORT_SYMBOL_GPL(unregister_net_sysctl_table);
+
+
+
+#define EXPORT_NETNS_PROC_HANDLER(handler)				\
+	int netns_##handler(struct ctl_table *table, int write,		\
+			    void __user *buffer, size_t *lenp,		\
+			    loff_t *ppos, void *net)			\
+	{								\
+		struct ctl_table t = *table;				\
+		t.data += (char *)net - (char *)&init_net;		\
+		return handler(&t, write, buffer, lenp, ppos, NULL);	\
+	}								\
+	EXPORT_SYMBOL_GPL(netns_##handler);
+
+EXPORT_NETNS_PROC_HANDLER(proc_dointvec);
+EXPORT_NETNS_PROC_HANDLER(proc_dointvec_minmax);
+EXPORT_NETNS_PROC_HANDLER(proc_dointvec_jiffies);
+EXPORT_NETNS_PROC_HANDLER(proc_dointvec_userhz_jiffies);
+EXPORT_NETNS_PROC_HANDLER(proc_dointvec_ms_jiffies);
+EXPORT_NETNS_PROC_HANDLER(proc_doulongvec_minmax)
+EXPORT_NETNS_PROC_HANDLER(proc_doulongvec_ms_jiffies_minmax);
+EXPORT_NETNS_PROC_HANDLER(proc_do_large_bitmap);
-- 
1.7.5.rc0

