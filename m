From: ebiederm@xmission.com (Eric W. Biederman)
Subject: [PATCH net-next 3/8] mpls: Add a sysctl to control the size of the mpls label table
Date: Wed, 25 Feb 2015 11:15:35 -0600
Message-ID: <878uflx688.fsf@x220.int.ebiederm.org>
References: <87pp8xx6ik.fsf@x220.int.ebiederm.org>
Mime-Version: 1.0
Content-Type: text/plain
Cc: <netdev@vger.kernel.org>, roopa <roopa@cumulusnetworks.com>,
	Stephen Hemminger <stephen@networkplumber.org>,
	santiago@crfreenet.org
To: David Miller <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from out02.mta.xmission.com ([166.70.13.232]:49656 "EHLO
	out02.mta.xmission.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752358AbbBYRTE (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 25 Feb 2015 12:19:04 -0500
In-Reply-To: <87pp8xx6ik.fsf@x220.int.ebiederm.org> (Eric W. Biederman's
	message of "Wed, 25 Feb 2015 11:09:23 -0600")
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>


This sysctl gives two benefits.  By defaulting the table size to 0
mpls even when compiled in and enabled defaults to not forwarding
any packets.  This prevents unpleasant surprises for users.

The other benefit is that as mpls labels are allocated locally a dense
table a small dense label table may be used which saves memory and
is extremely simple and efficient to implement.

This sysctl allows userspace to choose the restrictions on the label
table size userspace applications need to cope with.

Signed-off-by: "Eric W. Biederman" <ebiederm@xmission.com>
---
 Documentation/networking/mpls-sysctl.txt |  20 +++++
 include/net/netns/mpls.h                 |   2 +
 net/mpls/af_mpls.c                       | 140 +++++++++++++++++++++++++++++++
 3 files changed, 162 insertions(+)
 create mode 100644 Documentation/networking/mpls-sysctl.txt

diff --git a/Documentation/networking/mpls-sysctl.txt b/Documentation/networking/mpls-sysctl.txt
new file mode 100644
index 000000000000..639ddf0ece9b
--- /dev/null
+++ b/Documentation/networking/mpls-sysctl.txt
@@ -0,0 +1,20 @@
+/proc/sys/net/mpls/* Variables:
+
+platform_labels - INTEGER
+	Number of entries in the platform label table.  It is not
+	possible to configure forwarding for label values equal to or
+	greater than the number of platform labels.
+
+	A dense utliziation of the entries in the platform label table
+	is possible and expected aas the platform labels are locally
+	allocated.
+
+	If the number of platform label table entries is set to 0 no
+	label will be recognized by the kernel and mpls forwarding
+	will be disabled.
+
+	Reducing this value will remove all label routing entries that
+	no longer fit in the table.
+
+	Possible values: 0 - 1048575
+	Default: 0
diff --git a/include/net/netns/mpls.h b/include/net/netns/mpls.h
index f90aaf8d4f89..d29203651c01 100644
--- a/include/net/netns/mpls.h
+++ b/include/net/netns/mpls.h
@@ -6,10 +6,12 @@
 #define __NETNS_MPLS_H__
 
 struct mpls_route;
+struct ctl_table_header;
 
 struct netns_mpls {
 	size_t platform_labels;
 	struct mpls_route __rcu * __rcu *platform_label;
+	struct ctl_table_header *ctl;
 };
 
 #endif /* __NETNS_MPLS_H__ */
diff --git a/net/mpls/af_mpls.c b/net/mpls/af_mpls.c
index c84c8057d3df..d49a54ea288e 100644
--- a/net/mpls/af_mpls.c
+++ b/net/mpls/af_mpls.c
@@ -1,6 +1,7 @@
 #include <linux/types.h>
 #include <linux/skbuff.h>
 #include <linux/socket.h>
+#include <linux/sysctl.h>
 #include <linux/net.h>
 #include <linux/module.h>
 #include <linux/if_arp.h>
@@ -29,6 +30,9 @@ struct mpls_route { /* next hop label forwarding entry */
 	struct rcu_head		rt_rcu;
 };
 
+static int zero = 0;
+static int label_limit = (1 << 20) - 1;
+
 static struct mpls_route *mpls_route_input_rcu(struct net *net, unsigned index)
 {
 	struct mpls_route *rt = NULL;
@@ -260,18 +264,154 @@ static struct notifier_block mpls_dev_notifier = {
 	.notifier_call = mpls_dev_notify,
 };
 
+static int resize_platform_label_table(struct net *net, size_t limit)
+{
+	size_t size = sizeof(struct mpls_route *) * limit;
+	size_t old_limit;
+	size_t cp_size;
+	struct mpls_route __rcu **labels = NULL, **old;
+	struct mpls_route *rt0 = NULL, *rt2 = NULL;
+	unsigned index;
+
+	if (size) {
+		labels = kzalloc(size, GFP_KERNEL | __GFP_NOWARN | __GFP_NORETRY);
+		if (!labels)
+			labels = vzalloc(size);
+
+		if (!labels)
+			goto nolabels;
+	}
+
+	/* In case the predefined labels need to be populated */
+	if (limit > LABEL_IPV4_EXPLICIT_NULL) {
+		rt0 = mpls_rt_alloc();
+		if (!rt0)
+			goto nort0;
+		rt0->rt_dev = net->loopback_dev;
+		rt0->rt_protocol = RTPROT_KERNEL;
+	}
+	if (limit > LABEL_IPV6_EXPLICIT_NULL) {
+		rt2 = mpls_rt_alloc();
+		if (!rt2)
+			goto nort2;
+		rt2->rt_dev = net->loopback_dev;
+		rt2->rt_protocol = RTPROT_KERNEL;
+	}
+
+	rtnl_lock();
+	/* Remember the original table */
+	old = net->mpls.platform_label;
+	old_limit = net->mpls.platform_labels;
+
+	/* Free any labels beyond the new table */
+	for (index = limit; index < old_limit; index++)
+		mpls_route_update(net, index, NULL, NULL, NULL);
+
+	/* Copy over the old labels */
+	cp_size = size;
+	if (old_limit < limit)
+		cp_size = old_limit * sizeof(struct mpls_route *);
+
+	memcpy(labels, old, cp_size);
+
+	/* If needed set the predefined labels */
+	if ((old_limit <= LABEL_IPV6_EXPLICIT_NULL) &&
+	    (limit > LABEL_IPV6_EXPLICIT_NULL)) {
+		labels[LABEL_IPV6_EXPLICIT_NULL] = rt2;
+		rt2 = NULL;
+	}
+
+	if ((old_limit <= LABEL_IPV4_EXPLICIT_NULL) &&
+	    (limit > LABEL_IPV4_EXPLICIT_NULL)) {
+		labels[LABEL_IPV4_EXPLICIT_NULL] = rt0;
+		rt0 = NULL;
+	}
+
+	/* Update the global pointers */
+	net->mpls.platform_labels = limit;
+	net->mpls.platform_label = labels;
+
+	rtnl_unlock();
+
+	mpls_rt_free(rt2);
+	mpls_rt_free(rt0);
+
+	if (old) {
+		synchronize_rcu();
+		kvfree(old);
+	}
+	return 0;
+
+nort2:
+	mpls_rt_free(rt0);
+nort0:
+	kvfree(labels);
+nolabels:
+	return -ENOMEM;
+}
+
+static int mpls_platform_labels(struct ctl_table *table, int write,
+				void __user *buffer, size_t *lenp, loff_t *ppos)
+{
+	struct net *net = table->data;
+	int platform_labels = net->mpls.platform_labels;
+	int ret;
+	struct ctl_table tmp = {
+		.procname	= table->procname,
+		.data		= &platform_labels,
+		.maxlen		= sizeof(int),
+		.mode		= table->mode,
+		.extra1		= &zero,
+		.extra2		= &label_limit,
+	};
+
+	ret = proc_dointvec_minmax(&tmp, write, buffer, lenp, ppos);
+
+	if (write && ret == 0)
+		ret = resize_platform_label_table(net, platform_labels);
+
+	return ret;
+}
+
+static struct ctl_table mpls_table[] = {
+	{
+		.procname	= "platform_labels",
+		.data		= NULL,
+		.maxlen		= sizeof(int),
+		.mode		= 0644,
+		.proc_handler	= mpls_platform_labels,
+	},
+	{ }
+};
+
 static int mpls_net_init(struct net *net)
 {
+	struct ctl_table *table;
+
 	net->mpls.platform_labels = 0;
 	net->mpls.platform_label = NULL;
 
+	table = kmemdup(mpls_table, sizeof(mpls_table), GFP_KERNEL);
+	if (table == NULL)
+		return -ENOMEM;
+
+	table[0].data = net;
+	net->mpls.ctl = register_net_sysctl(net, "net/mpls", table);
+	if (net->mpls.ctl == NULL)
+		return -ENOMEM;
+
 	return 0;
 }
 
 static void mpls_net_exit(struct net *net)
 {
+	struct ctl_table *table;
 	unsigned int index;
 
+	table = net->mpls.ctl->ctl_table_arg;
+	unregister_net_sysctl_table(net->mpls.ctl);
+	kfree(table);
+
 	/* An rcu grace period haselapsed since there was a device in
 	 * the network namespace (and thus the last in fqlight packet)
 	 * left this network namespace.  This is because
-- 
2.2.1
