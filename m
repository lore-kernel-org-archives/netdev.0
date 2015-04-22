From: Robert Shearman <rshearma@brocade.com>
Subject: [PATCH v2 2/3] mpls: Per-device enabling of packet input
Date: Wed, 22 Apr 2015 11:14:38 +0100
Message-ID: <1429697679-13767-3-git-send-email-rshearma@brocade.com>
References: <1429648467-8449-1-git-send-email-rshearma@brocade.com>
 <1429697679-13767-1-git-send-email-rshearma@brocade.com>
Mime-Version: 1.0
Content-Type: text/plain
Cc: <netdev@vger.kernel.org>, Robert Shearman <rshearma@brocade.com>
To: <davem@davemloft.net>, <ebiederm@xmission.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mx0b-000f0801.pphosted.com ([67.231.152.113]:55634 "EHLO
	mx0b-000f0801.pphosted.com" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with ESMTP id S934584AbbDVKPj (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 22 Apr 2015 06:15:39 -0400
In-Reply-To: <1429697679-13767-1-git-send-email-rshearma@brocade.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

An MPLS network is a single trust domain where the edges must be in
control of what labels make their way into the core. The simplest way
of ensuring this is for the edge device to always impose the labels,
and not allow forward labeled traffic from untrusted neighbours. This
is achieved by allowing a per-device configuration of whether MPLS
traffic input from that interface should be processed or not.

To be secure by default, the default state is changed to MPLS being
disabled on all interfaces unless explicitly enabled and no global
option is provided to change the default. Whilst this differs from
other protocols (e.g. IPv6), network operators are used to explicitly
enabling MPLS forwarding on interfaces, and with the number of links
to the MPLS core typically fairly low this doesn't present too much of
a burden on operators.

Cc: "Eric W. Biederman" <ebiederm@xmission.com>
Signed-off-by: Robert Shearman <rshearma@brocade.com>
---
 Documentation/networking/mpls-sysctl.txt |  9 +++++
 net/mpls/af_mpls.c                       | 68 +++++++++++++++++++++++++++++++-
 net/mpls/internal.h                      |  3 ++
 3 files changed, 78 insertions(+), 2 deletions(-)

diff --git a/Documentation/networking/mpls-sysctl.txt b/Documentation/networking/mpls-sysctl.txt
index 639ddf0ece9b..9ed15f86c17c 100644
--- a/Documentation/networking/mpls-sysctl.txt
+++ b/Documentation/networking/mpls-sysctl.txt
@@ -18,3 +18,12 @@ platform_labels - INTEGER
 
 	Possible values: 0 - 1048575
 	Default: 0
+
+conf/<interface>/input - BOOL
+	Control whether packets can be input on this interface.
+
+	If disabled, packets will be discarded without further
+	processing.
+
+	0 - disabled (default)
+	not 0 - enabled
diff --git a/net/mpls/af_mpls.c b/net/mpls/af_mpls.c
index ad45017eed99..9fdd94cba83e 100644
--- a/net/mpls/af_mpls.c
+++ b/net/mpls/af_mpls.c
@@ -150,7 +150,7 @@ static int mpls_forward(struct sk_buff *skb, struct net_device *dev,
 	/* Careful this entire function runs inside of an rcu critical section */
 
 	mdev = mpls_dev_get(dev);
-	if (!mdev)
+	if (!mdev || !mdev->input_enabled)
 		goto drop;
 
 	if (skb->pkt_type != PACKET_HOST)
@@ -438,6 +438,60 @@ errout:
 	return err;
 }
 
+#define MPLS_PERDEV_SYSCTL_OFFSET(field)	\
+	(&((struct mpls_dev *)0)->field)
+
+static const struct ctl_table mpls_dev_table[] = {
+	{
+		.procname	= "input",
+		.maxlen		= sizeof(int),
+		.mode		= 0644,
+		.proc_handler	= proc_dointvec,
+		.data		= MPLS_PERDEV_SYSCTL_OFFSET(input_enabled),
+	},
+	{ }
+};
+
+static int mpls_dev_sysctl_register(struct net_device *dev,
+				    struct mpls_dev *mdev)
+{
+	char path[sizeof("net/mpls/conf/") + IFNAMSIZ];
+	struct ctl_table *table;
+	int i;
+
+	table = kmemdup(&mpls_dev_table, sizeof(mpls_dev_table), GFP_KERNEL);
+	if (!table)
+		goto out;
+
+	/* Table data contains only offsets relative to the base of
+	 * the mdev at this point, so make them absolute.
+	 */
+	for (i = 0; i < ARRAY_SIZE(mpls_dev_table); i++)
+		table[i].data = (char *)mdev + (uintptr_t)table[i].data;
+
+	snprintf(path, sizeof(path), "net/mpls/conf/%s", dev->name);
+
+	mdev->sysctl = register_net_sysctl(dev_net(dev), path, table);
+	if (!mdev->sysctl)
+		goto free;
+
+	return 0;
+
+free:
+	kfree(table);
+out:
+	return -ENOBUFS;
+}
+
+static void mpls_dev_sysctl_unregister(struct mpls_dev *mdev)
+{
+	struct ctl_table *table;
+
+	table = mdev->sysctl->ctl_table_arg;
+	unregister_net_sysctl_table(mdev->sysctl);
+	kfree(table);
+}
+
 static struct mpls_dev *mpls_add_dev(struct net_device *dev)
 {
 	struct mpls_dev *mdev;
@@ -449,9 +503,17 @@ static struct mpls_dev *mpls_add_dev(struct net_device *dev)
 	if (!mdev)
 		return ERR_PTR(err);
 
+	err = mpls_dev_sysctl_register(dev, mdev);
+	if (err)
+		goto free;
+
 	rcu_assign_pointer(dev->mpls_ptr, mdev);
 
 	return mdev;
+
+free:
+	kfree(mdev);
+	return ERR_PTR(err);
 }
 
 static void mpls_ifdown(struct net_device *dev)
@@ -475,6 +537,8 @@ static void mpls_ifdown(struct net_device *dev)
 	if (!mdev)
 		return;
 
+	mpls_dev_sysctl_unregister(mdev);
+
 	RCU_INIT_POINTER(dev->mpls_ptr, NULL);
 
 	kfree(mdev);
@@ -958,7 +1022,7 @@ static int mpls_platform_labels(struct ctl_table *table, int write,
 	return ret;
 }
 
-static struct ctl_table mpls_table[] = {
+static const struct ctl_table mpls_table[] = {
 	{
 		.procname	= "platform_labels",
 		.data		= NULL,
diff --git a/net/mpls/internal.h b/net/mpls/internal.h
index 8090cb3099b4..693877d69606 100644
--- a/net/mpls/internal.h
+++ b/net/mpls/internal.h
@@ -23,6 +23,9 @@ struct mpls_entry_decoded {
 };
 
 struct mpls_dev {
+	int			input_enabled;
+
+	struct ctl_table_header *sysctl;
 };
 
 struct sk_buff;
-- 
2.1.4
