From: Daniel Borkmann <dborkman@redhat.com>
Subject: [PATCH net] net: sctp: propagate sysctl errors from proc_do* properly
Date: Thu, 19 Jun 2014 01:31:30 +0200
Message-ID: <1403134290-23765-1-git-send-email-dborkman@redhat.com>
Cc: netdev@vger.kernel.org, linux-sctp@vger.kernel.org
To: davem@davemloft.net
Return-path: <netdev-owner@vger.kernel.org>
Received: from mx1.redhat.com ([209.132.183.28]:33283 "EHLO mx1.redhat.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1752276AbaFRXbc (ORCPT <rfc822;netdev@vger.kernel.org>);
	Wed, 18 Jun 2014 19:31:32 -0400
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

sysctl handler proc_sctp_do_hmac_alg(), proc_sctp_do_rto_min() and
proc_sctp_do_rto_max() do not properly reflect some error cases
when writing values via sysctl from internal proc functions such
as proc_dointvec() and proc_dostring().

In all these cases we pass the test for write != 0 and partially
do additional work just to notice that additional sanity checks
fail and we return with hard-coded -EINVAL while proc_do*
functions might also return different errors. So fix this up by
simply testing a successful return of proc_do* right after
calling it.

This also allows to propagate its return value onwards to the user.
While touching this, also fix up some minor style issues.

Fixes: 4f3fdf3bc59c ("sctp: add check rto_min and rto_max in sysctl")
Fixes: 3c68198e7511 ("sctp: Make hmac algorithm selection for cookie generation dynamic")
Signed-off-by: Daniel Borkmann <dborkman@redhat.com>
---
 net/sctp/sysctl.c | 43 +++++++++++++++++++++++--------------------
 1 file changed, 23 insertions(+), 20 deletions(-)

diff --git a/net/sctp/sysctl.c b/net/sctp/sysctl.c
index 8a5b5c2..12c7e01 100644
--- a/net/sctp/sysctl.c
+++ b/net/sctp/sysctl.c
@@ -321,41 +321,40 @@ static int proc_sctp_do_hmac_alg(struct ctl_table *ctl, int write,
 				loff_t *ppos)
 {
 	struct net *net = current->nsproxy->net_ns;
-	char tmp[8];
 	struct ctl_table tbl;
-	int ret;
-	int changed = 0;
+	bool changed = false;
 	char *none = "none";
+	char tmp[8];
+	int ret;
 
 	memset(&tbl, 0, sizeof(struct ctl_table));
 
 	if (write) {
 		tbl.data = tmp;
-		tbl.maxlen = 8;
+		tbl.maxlen = sizeof(tmp);
 	} else {
 		tbl.data = net->sctp.sctp_hmac_alg ? : none;
 		tbl.maxlen = strlen(tbl.data);
 	}
-		ret = proc_dostring(&tbl, write, buffer, lenp, ppos);
 
-	if (write) {
+	ret = proc_dostring(&tbl, write, buffer, lenp, ppos);
+	if (write && ret == 0) {
 #ifdef CONFIG_CRYPTO_MD5
 		if (!strncmp(tmp, "md5", 3)) {
 			net->sctp.sctp_hmac_alg = "md5";
-			changed = 1;
+			changed = true;
 		}
 #endif
 #ifdef CONFIG_CRYPTO_SHA1
 		if (!strncmp(tmp, "sha1", 4)) {
 			net->sctp.sctp_hmac_alg = "sha1";
-			changed = 1;
+			changed = true;
 		}
 #endif
 		if (!strncmp(tmp, "none", 4)) {
 			net->sctp.sctp_hmac_alg = NULL;
-			changed = 1;
+			changed = true;
 		}
-
 		if (!changed)
 			ret = -EINVAL;
 	}
@@ -368,11 +367,10 @@ static int proc_sctp_do_rto_min(struct ctl_table *ctl, int write,
 				loff_t *ppos)
 {
 	struct net *net = current->nsproxy->net_ns;
-	int new_value;
-	struct ctl_table tbl;
 	unsigned int min = *(unsigned int *) ctl->extra1;
 	unsigned int max = *(unsigned int *) ctl->extra2;
-	int ret;
+	struct ctl_table tbl;
+	int ret, new_value;
 
 	memset(&tbl, 0, sizeof(struct ctl_table));
 	tbl.maxlen = sizeof(unsigned int);
@@ -381,12 +379,15 @@ static int proc_sctp_do_rto_min(struct ctl_table *ctl, int write,
 		tbl.data = &new_value;
 	else
 		tbl.data = &net->sctp.rto_min;
+
 	ret = proc_dointvec(&tbl, write, buffer, lenp, ppos);
-	if (write) {
-		if (ret || new_value > max || new_value < min)
+	if (write && ret == 0) {
+		if (new_value > max || new_value < min)
 			return -EINVAL;
+
 		net->sctp.rto_min = new_value;
 	}
+
 	return ret;
 }
 
@@ -395,11 +396,10 @@ static int proc_sctp_do_rto_max(struct ctl_table *ctl, int write,
 				loff_t *ppos)
 {
 	struct net *net = current->nsproxy->net_ns;
-	int new_value;
-	struct ctl_table tbl;
 	unsigned int min = *(unsigned int *) ctl->extra1;
 	unsigned int max = *(unsigned int *) ctl->extra2;
-	int ret;
+	struct ctl_table tbl;
+	int ret, new_value;
 
 	memset(&tbl, 0, sizeof(struct ctl_table));
 	tbl.maxlen = sizeof(unsigned int);
@@ -408,12 +408,15 @@ static int proc_sctp_do_rto_max(struct ctl_table *ctl, int write,
 		tbl.data = &new_value;
 	else
 		tbl.data = &net->sctp.rto_max;
+
 	ret = proc_dointvec(&tbl, write, buffer, lenp, ppos);
-	if (write) {
-		if (ret || new_value > max || new_value < min)
+	if (write && ret == 0) {
+		if (new_value > max || new_value < min)
 			return -EINVAL;
+
 		net->sctp.rto_max = new_value;
 	}
+
 	return ret;
 }
 
-- 
1.7.11.7
