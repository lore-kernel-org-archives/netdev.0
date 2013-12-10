From: Wang Weidong <wangweidong1@huawei.com>
Subject: [PATCH v6 2/3] sctp: add check rto_min and rto_max in sysctl
Date: Tue, 10 Dec 2013 10:46:36 +0800
Message-ID: <1386643597-22156-3-git-send-email-wangweidong1@huawei.com>
References: <1386643597-22156-1-git-send-email-wangweidong1@huawei.com>
Mime-Version: 1.0
Content-Type: text/plain
Cc: <dborkman@redhat.com>, <netdev@vger.kernel.org>,
	<linux-sctp@vger.kernel.org>
To: <vyasevich@gmail.com>, <nhorman@tuxdriver.com>,
	<davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from szxga03-in.huawei.com ([119.145.14.66]:18176 "EHLO
	szxga03-in.huawei.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1750858Ab3LJCr0 (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 9 Dec 2013 21:47:26 -0500
In-Reply-To: <1386643597-22156-1-git-send-email-wangweidong1@huawei.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

rto_min should be smaller than rto_max while rto_max should be larger
than rto_min. Add two proc_handler for the checking.

Suggested-by: Vlad Yasevich <vyasevich@gmail.com>
Signed-off-by: Wang Weidong <wangweidong1@huawei.com>
---
 net/sctp/sysctl.c | 69 +++++++++++++++++++++++++++++++++++++++++++++++++++----
 1 file changed, 65 insertions(+), 4 deletions(-)

diff --git a/net/sctp/sysctl.c b/net/sctp/sysctl.c
index 6b36561..ed4ec89 100644
--- a/net/sctp/sysctl.c
+++ b/net/sctp/sysctl.c
@@ -61,6 +61,13 @@ static int proc_sctp_do_hmac_alg(struct ctl_table *ctl,
 				void __user *buffer, size_t *lenp,
 
 				loff_t *ppos);
+static int proc_sctp_do_rto_min(struct ctl_table *ctl, int write,
+				void __user *buffer, size_t *lenp,
+				loff_t *ppos);
+static int proc_sctp_do_rto_max(struct ctl_table *ctl, int write,
+				void __user *buffer, size_t *lenp,
+				loff_t *ppos);
+
 static struct ctl_table sctp_table[] = {
 	{
 		.procname	= "sctp_mem",
@@ -102,17 +109,17 @@ static struct ctl_table sctp_net_table[] = {
 		.data		= &init_net.sctp.rto_min,
 		.maxlen		= sizeof(unsigned int),
 		.mode		= 0644,
-		.proc_handler	= proc_dointvec_minmax,
+		.proc_handler	= proc_sctp_do_rto_min,
 		.extra1         = &one,
-		.extra2         = &timer_max
+		.extra2         = &init_net.sctp.rto_max
 	},
 	{
 		.procname	= "rto_max",
 		.data		= &init_net.sctp.rto_max,
 		.maxlen		= sizeof(unsigned int),
 		.mode		= 0644,
-		.proc_handler	= proc_dointvec_minmax,
-		.extra1         = &one,
+		.proc_handler	= proc_sctp_do_rto_max,
+		.extra1         = &init_net.sctp.rto_min,
 		.extra2         = &timer_max
 	},
 	{
@@ -342,6 +349,60 @@ static int proc_sctp_do_hmac_alg(struct ctl_table *ctl,
 	return ret;
 }
 
+static int proc_sctp_do_rto_min(struct ctl_table *ctl, int write,
+				void __user*buffer, size_t *lenp,
+				loff_t *ppos)
+{
+	struct net *net = current->nsproxy->net_ns;
+	int new_value;
+	struct ctl_table tbl;
+	unsigned int min = *(unsigned int *) ctl->extra1;
+	unsigned int max = *(unsigned int *) ctl->extra2;
+	int ret;
+
+	memset(&tbl, 0, sizeof(struct ctl_table));
+	tbl.maxlen = sizeof(unsigned int);
+
+	if (write)
+		tbl.data = &new_value;
+	else
+		tbl.data = &net->sctp.rto_min;
+	ret = proc_dointvec(&tbl, write, buffer, lenp, ppos);
+	if (write) {
+		if (ret || new_value > max || new_value < min)
+			return -EINVAL;
+		net->sctp.rto_min = new_value;
+	}
+	return ret;
+}
+
+static int proc_sctp_do_rto_max(struct ctl_table *ctl, int write,
+				void __user*buffer, size_t *lenp,
+				loff_t *ppos)
+{
+	struct net *net = current->nsproxy->net_ns;
+	int new_value;
+	struct ctl_table tbl;
+	unsigned int min = *(unsigned int *) ctl->extra1;
+	unsigned int max = *(unsigned int *) ctl->extra2;
+	int ret;
+
+	memset(&tbl, 0, sizeof(struct ctl_table));
+	tbl.maxlen = sizeof(unsigned int);
+
+	if (write)
+		tbl.data = &new_value;
+	else
+		tbl.data = &net->sctp.rto_max;
+	ret = proc_dointvec(&tbl, write, buffer, lenp, ppos);
+	if (write) {
+                if (ret || new_value > max || new_value < min)
+			return -EINVAL;
+		net->sctp.rto_max = new_value;
+	}
+	return ret;
+}
+
 int sctp_sysctl_net_register(struct net *net)
 {
 	struct ctl_table *table;
-- 
1.7.12
