From: Wang Weidong <wangweidong1@huawei.com>
Subject: [PATCH v5 1/2] sctp: check the rto_min and rto_max
Date: Sat, 7 Dec 2013 15:17:30 +0800
Message-ID: <1386400651-21744-2-git-send-email-wangweidong1@huawei.com>
References: <1386400651-21744-1-git-send-email-wangweidong1@huawei.com>
Mime-Version: 1.0
Content-Type: text/plain
Cc: <dborkman@redhat.com>, <netdev@vger.kernel.org>,
	<linux-sctp@vger.kernel.org>
To: <vyasevich@gmail.com>, <nhorman@tuxdriver.com>,
	<davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from szxga03-in.huawei.com ([119.145.14.66]:65188 "EHLO
	szxga03-in.huawei.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752093Ab3LGHSO (ORCPT
	<rfc822;netdev@vger.kernel.org>); Sat, 7 Dec 2013 02:18:14 -0500
In-Reply-To: <1386400651-21744-1-git-send-email-wangweidong1@huawei.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

rto_min should be smaller than rto_max while rto_max should be larger
than rto_min. Add two proc_handler for the checking. Add the check in
sctp_setsockopt_rtoinfo.

Suggested-by: Vlad Yasevich <vyasevich@gmail.com>
Signed-off-by: Wang Weidong <wangweidong1@huawei.com>
---
 include/net/sctp/constants.h |  3 ++
 net/sctp/socket.c            |  5 +++
 net/sctp/sysctl.c            | 73 ++++++++++++++++++++++++++++++++++++++++----
 3 files changed, 75 insertions(+), 6 deletions(-)

diff --git a/include/net/sctp/constants.h b/include/net/sctp/constants.h
index 2f0a565..d276978 100644
--- a/include/net/sctp/constants.h
+++ b/include/net/sctp/constants.h
@@ -279,6 +279,9 @@ enum { SCTP_MAX_GABS = 16 };
 #define SCTP_RTO_ALPHA          3   /* 1/8 when converted to right shifts. */
 #define SCTP_RTO_BETA           2   /* 1/4 when converted to right shifts. */
 
+#define SCTP_ONE                1        /* 1 ms */
+#define SCTP_TIMER_MAX          86400000 /* ms in one day */
+
 /* Maximum number of new data packets that can be sent in a burst.  */
 #define SCTP_DEFAULT_MAX_BURST		4
 
diff --git a/net/sctp/socket.c b/net/sctp/socket.c
index 72046b9..13411ad 100644
--- a/net/sctp/socket.c
+++ b/net/sctp/socket.c
@@ -2818,6 +2818,11 @@ static int sctp_setsockopt_rtoinfo(struct sock *sk, char __user *optval, unsigne
 	if (copy_from_user(&rtoinfo, optval, optlen))
 		return -EFAULT;
 
+	if (rtoinfo.srto_min < SCTP_ONE ||
+	    rtoinfo.srto_max > SCTP_TIMER_MAX ||
+	    rtoinfo.srto_max < rtoinfo.srto_min)
+		return -EINVAL;
+
 	asoc = sctp_id2assoc(sk, rtoinfo.srto_assoc_id);
 
 	/* Set the values to the specific association */
diff --git a/net/sctp/sysctl.c b/net/sctp/sysctl.c
index 6b36561..33c56c6 100644
--- a/net/sctp/sysctl.c
+++ b/net/sctp/sysctl.c
@@ -40,8 +40,8 @@
 #include <linux/sysctl.h>
 
 static int zero = 0;
-static int one = 1;
-static int timer_max = 86400000; /* ms in one day */
+static int one = SCTP_ONE;
+static int timer_max = SCTP_TIMER_MAX;
 static int int_max = INT_MAX;
 static int sack_timer_min = 1;
 static int sack_timer_max = 500;
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
