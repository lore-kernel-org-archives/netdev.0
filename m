From: Wang Weidong <wangweidong1@huawei.com>
Subject: [PATCH v4] sctp: check the rto_min and rto_max
Date: Thu, 5 Dec 2013 10:19:25 +0800
Message-ID: <529FE2AD.5020700@huawei.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="ISO-8859-1"
Content-Transfer-Encoding: 7bit
Cc: <netdev@vger.kernel.org>, <linux-sctp@vger.kernel.org>
To: Vlad Yasevich <vyasevich@gmail.com>,
	Neil Horman <nhorman@tuxdriver.com>,
	David Miller <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from szxga03-in.huawei.com ([119.145.14.66]:45920 "EHLO
	szxga03-in.huawei.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1756298Ab3LECT6 (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 4 Dec 2013 21:19:58 -0500
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

rto_min should be smaller than rto_max while rto_max should be larger
than rto_min. Add two proc_handler for the checking. Add the check in
sctp_setsockopt_rtoinfo.
delete a blank line in proc_sctp_do_hmac_alg() declaration.

Suggested-by: Vlad Yasevich <vyasevich@gmail.com>
Signed-off-by: Wang Weidong <wangweidong1@huawei.com>
---
 net/sctp/socket.c |  5 ++++
 net/sctp/sysctl.c | 74 +++++++++++++++++++++++++++++++++++++++++++++++++++----
 2 files changed, 74 insertions(+), 5 deletions(-)

diff --git a/net/sctp/socket.c b/net/sctp/socket.c
index 72046b9..2e1af1b 100644
--- a/net/sctp/socket.c
+++ b/net/sctp/socket.c
@@ -2818,6 +2818,11 @@ static int sctp_setsockopt_rtoinfo(struct sock *sk, char __user *optval, unsigne
 	if (copy_from_user(&rtoinfo, optval, optlen))
 		return -EFAULT;
 
+	if (rtoinfo.srto_min < 1 ||
+	    rtoinfo.srto_max > 86400000 ||
+	    rtoinfo.srto_max < rtoinfo.srto_min)
+		return -EINVAL;
+
 	asoc = sctp_id2assoc(sk, rtoinfo.srto_assoc_id);
 
 	/* Set the values to the specific association */
diff --git a/net/sctp/sysctl.c b/net/sctp/sysctl.c
index 6b36561..8d6757a 100644
--- a/net/sctp/sysctl.c
+++ b/net/sctp/sysctl.c
@@ -59,8 +59,16 @@ extern int sysctl_sctp_wmem[3];
 static int proc_sctp_do_hmac_alg(struct ctl_table *ctl,
 				int write,
 				void __user *buffer, size_t *lenp,
-
 				loff_t *ppos);
+static int proc_sctp_do_rto_min(struct ctl_table *ctl,
+				int write,
+				void __user *buffer, size_t *lenp,
+				loff_t *ppos);
+static int proc_sctp_do_rto_max(struct ctl_table *ctl,
+				int write,
+				void __user *buffer, size_t *lenp,
+				loff_t *ppos);
+
 static struct ctl_table sctp_table[] = {
 	{
 		.procname	= "sctp_mem",
@@ -102,17 +110,17 @@ static struct ctl_table sctp_net_table[] = {
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
@@ -342,6 +350,62 @@ static int proc_sctp_do_hmac_alg(struct ctl_table *ctl,
 	return ret;
 }
 
+static int proc_sctp_do_rto_min(struct ctl_table *ctl,
+				int write,
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
+static int proc_sctp_do_rto_max(struct ctl_table *ctl,
+				int write,
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
