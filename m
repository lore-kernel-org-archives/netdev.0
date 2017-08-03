From: Jiri Pirko <jiri@resnulli.us>
Subject: [patch net-next 06/21] ipv6: fib: Add FIB notifiers callbacks
Date: Thu,  3 Aug 2017 13:28:16 +0200
Message-ID: <20170803112831.1831-7-jiri@resnulli.us>
References: <20170803112831.1831-1-jiri@resnulli.us>
Cc: davem@davemloft.net, idosch@mellanox.com, mlxsw@mellanox.com,
        dsahern@gmail.com, roopa@cumulusnetworks.com,
        nikolay@cumulusnetworks.com, kafai@fb.com,
        hannes@stressinduktion.org, yoshfuji@linux-ipv6.org,
        edumazet@google.com, yanhaishuang@cmss.chinamobile.com
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-wr0-f194.google.com ([209.85.128.194]:38337 "EHLO
        mail-wr0-f194.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1752106AbdHCL2q (ORCPT
        <rfc822;netdev@vger.kernel.org>); Thu, 3 Aug 2017 07:28:46 -0400
Received: by mail-wr0-f194.google.com with SMTP id g32so799114wrd.5
        for <netdev@vger.kernel.org>; Thu, 03 Aug 2017 04:28:45 -0700 (PDT)
In-Reply-To: <20170803112831.1831-1-jiri@resnulli.us>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Ido Schimmel <idosch@mellanox.com>

We're about to add IPv6 FIB offload support, so implement the necessary
callbacks in IPv6 code, which will later allow us to add routes and
rules notifications.

Signed-off-by: Ido Schimmel <idosch@mellanox.com>
Signed-off-by: Jiri Pirko <jiri@mellanox.com>
---
 include/net/ip6_fib.h    | 11 ++++++++++
 include/net/netns/ipv6.h |  1 +
 net/ipv6/Makefile        |  2 +-
 net/ipv6/fib6_notifier.c | 55 ++++++++++++++++++++++++++++++++++++++++++++++++
 net/ipv6/ip6_fib.c       |  7 ++++++
 5 files changed, 75 insertions(+), 1 deletion(-)
 create mode 100644 net/ipv6/fib6_notifier.c

diff --git a/include/net/ip6_fib.h b/include/net/ip6_fib.h
index 6000b0d..be8ddf3 100644
--- a/include/net/ip6_fib.h
+++ b/include/net/ip6_fib.h
@@ -16,10 +16,12 @@
 #include <linux/ipv6_route.h>
 #include <linux/rtnetlink.h>
 #include <linux/spinlock.h>
+#include <linux/notifier.h>
 #include <net/dst.h>
 #include <net/flow.h>
 #include <net/netlink.h>
 #include <net/inetpeer.h>
+#include <net/fib_notifier.h>
 
 #ifdef CONFIG_IPV6_MULTIPLE_TABLES
 #define FIB6_TABLE_HASHSZ 256
@@ -292,6 +294,15 @@ int fib6_init(void);
 
 int ipv6_route_open(struct inode *inode, struct file *file);
 
+int call_fib6_notifier(struct notifier_block *nb, struct net *net,
+		       enum fib_event_type event_type,
+		       struct fib_notifier_info *info);
+int call_fib6_notifiers(struct net *net, enum fib_event_type event_type,
+			struct fib_notifier_info *info);
+
+int __net_init fib6_notifier_init(struct net *net);
+void __net_exit fib6_notifier_exit(struct net *net);
+
 #ifdef CONFIG_IPV6_MULTIPLE_TABLES
 int fib6_rules_init(void);
 void fib6_rules_cleanup(void);
diff --git a/include/net/netns/ipv6.h b/include/net/netns/ipv6.h
index de7745e..abdf3b4 100644
--- a/include/net/netns/ipv6.h
+++ b/include/net/netns/ipv6.h
@@ -86,6 +86,7 @@ struct netns_ipv6 {
 	atomic_t		dev_addr_genid;
 	atomic_t		fib6_sernum;
 	struct seg6_pernet_data *seg6_data;
+	struct fib_notifier_ops	*notifier_ops;
 };
 
 #if IS_ENABLED(CONFIG_NF_DEFRAG_IPV6)
diff --git a/net/ipv6/Makefile b/net/ipv6/Makefile
index 217e9ff..f8b24c2 100644
--- a/net/ipv6/Makefile
+++ b/net/ipv6/Makefile
@@ -9,7 +9,7 @@ ipv6-objs :=	af_inet6.o anycast.o ip6_output.o ip6_input.o addrconf.o \
 		route.o ip6_fib.o ipv6_sockglue.o ndisc.o udp.o udplite.o \
 		raw.o icmp.o mcast.o reassembly.o tcp_ipv6.o ping.o \
 		exthdrs.o datagram.o ip6_flowlabel.o inet6_connection_sock.o \
-		udp_offload.o seg6.o
+		udp_offload.o seg6.o fib6_notifier.o
 
 ipv6-offload :=	ip6_offload.o tcpv6_offload.o exthdrs_offload.o
 
diff --git a/net/ipv6/fib6_notifier.c b/net/ipv6/fib6_notifier.c
new file mode 100644
index 0000000..c2bb1ab
--- /dev/null
+++ b/net/ipv6/fib6_notifier.c
@@ -0,0 +1,55 @@
+#include <linux/notifier.h>
+#include <linux/socket.h>
+#include <linux/kernel.h>
+#include <net/net_namespace.h>
+#include <net/fib_notifier.h>
+#include <net/netns/ipv6.h>
+#include <net/ip6_fib.h>
+
+int call_fib6_notifier(struct notifier_block *nb, struct net *net,
+		       enum fib_event_type event_type,
+		       struct fib_notifier_info *info)
+{
+	info->family = AF_INET6;
+	return call_fib_notifier(nb, net, event_type, info);
+}
+
+int call_fib6_notifiers(struct net *net, enum fib_event_type event_type,
+			struct fib_notifier_info *info)
+{
+	info->family = AF_INET6;
+	return call_fib_notifiers(net, event_type, info);
+}
+
+static unsigned int fib6_seq_read(struct net *net)
+{
+	return 0;
+}
+
+static int fib6_dump(struct net *net, struct notifier_block *nb)
+{
+	return 0;
+}
+
+static const struct fib_notifier_ops fib6_notifier_ops_template = {
+	.family		= AF_INET6,
+	.fib_seq_read	= fib6_seq_read,
+	.fib_dump	= fib6_dump,
+};
+
+int __net_init fib6_notifier_init(struct net *net)
+{
+	struct fib_notifier_ops *ops;
+
+	ops = fib_notifier_ops_register(&fib6_notifier_ops_template, net);
+	if (IS_ERR(ops))
+		return PTR_ERR(ops);
+	net->ipv6.notifier_ops = ops;
+
+	return 0;
+}
+
+void __net_exit fib6_notifier_exit(struct net *net)
+{
+	fib_notifier_ops_unregister(net->ipv6.notifier_ops);
+}
diff --git a/net/ipv6/ip6_fib.c b/net/ipv6/ip6_fib.c
index ebb299c..f93976e 100644
--- a/net/ipv6/ip6_fib.c
+++ b/net/ipv6/ip6_fib.c
@@ -1839,6 +1839,11 @@ static void fib6_gc_timer_cb(unsigned long arg)
 static int __net_init fib6_net_init(struct net *net)
 {
 	size_t size = sizeof(struct hlist_head) * FIB6_TABLE_HASHSZ;
+	int err;
+
+	err = fib6_notifier_init(net);
+	if (err)
+		return err;
 
 	spin_lock_init(&net->ipv6.fib6_gc_lock);
 	rwlock_init(&net->ipv6.fib6_walker_lock);
@@ -1891,6 +1896,7 @@ static int __net_init fib6_net_init(struct net *net)
 out_rt6_stats:
 	kfree(net->ipv6.rt6_stats);
 out_timer:
+	fib6_notifier_exit(net);
 	return -ENOMEM;
 }
 
@@ -1907,6 +1913,7 @@ static void fib6_net_exit(struct net *net)
 	kfree(net->ipv6.fib6_main_tbl);
 	kfree(net->ipv6.fib_table_hash);
 	kfree(net->ipv6.rt6_stats);
+	fib6_notifier_exit(net);
 }
 
 static struct pernet_operations fib6_net_ops = {
-- 
2.9.3
