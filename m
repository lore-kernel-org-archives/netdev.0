From: Patrick McHardy <kaber@trash.net>
Subject: netfilter 05/07: nf_log: fix direct userspace memory access in proc handler
Date: Mon, 22 Jun 2009 14:53:55 +0200 (MEST)
Message-ID: <20090622125355.6531.82025.sendpatchset@x2.localnet>
References: <20090622125349.6531.35515.sendpatchset@x2.localnet>
Cc: netdev@vger.kernel.org, Patrick McHardy <kaber@trash.net>,
	netfilter-devel@vger.kernel.org
To: davem@davemloft.net
Return-path: <netdev-owner@vger.kernel.org>
Received: from stinky.trash.net ([213.144.137.162]:39236 "EHLO
	stinky.trash.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752269AbZFVMxw (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 22 Jun 2009 08:53:52 -0400
In-Reply-To: <20090622125349.6531.35515.sendpatchset@x2.localnet>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

commit 249556192859490b6280552d4b877064f9f5ee48
Author: Patrick McHardy <kaber@trash.net>
Date:   Mon Jun 22 14:15:30 2009 +0200

    netfilter: nf_log: fix direct userspace memory access in proc handler
    
    Signed-off-by: Patrick McHardy <kaber@trash.net>

diff --git a/net/netfilter/nf_log.c b/net/netfilter/nf_log.c
index 2fefe14..4e62030 100644
--- a/net/netfilter/nf_log.c
+++ b/net/netfilter/nf_log.c
@@ -47,7 +47,6 @@ int nf_log_register(u_int8_t pf, struct nf_logger *logger)
 	mutex_lock(&nf_log_mutex);
 
 	if (pf == NFPROTO_UNSPEC) {
-		int i;
 		for (i = NFPROTO_UNSPEC; i < NFPROTO_NUMPROTO; i++)
 			list_add_tail(&(logger->list[i]), &(nf_loggers_l[i]));
 	} else {
@@ -216,7 +215,7 @@ static const struct file_operations nflog_file_ops = {
 #endif /* PROC_FS */
 
 #ifdef CONFIG_SYSCTL
-struct ctl_path nf_log_sysctl_path[] = {
+static struct ctl_path nf_log_sysctl_path[] = {
 	{ .procname = "net", .ctl_name = CTL_NET, },
 	{ .procname = "netfilter", .ctl_name = NET_NETFILTER, },
 	{ .procname = "nf_log", .ctl_name = CTL_UNNUMBERED, },
@@ -228,19 +227,26 @@ static struct ctl_table nf_log_sysctl_table[NFPROTO_NUMPROTO+1];
 static struct ctl_table_header *nf_log_dir_header;
 
 static int nf_log_proc_dostring(ctl_table *table, int write, struct file *filp,
-			 void *buffer, size_t *lenp, loff_t *ppos)
+			 void __user *buffer, size_t *lenp, loff_t *ppos)
 {
 	const struct nf_logger *logger;
+	char buf[NFLOGGER_NAME_LEN];
+	size_t size = *lenp;
 	int r = 0;
 	int tindex = (unsigned long)table->extra1;
 
 	if (write) {
-		if (!strcmp(buffer, "NONE")) {
+		if (size > sizeof(buf))
+			size = sizeof(buf);
+		if (copy_from_user(buf, buffer, size))
+			return -EFAULT;
+
+		if (!strcmp(buf, "NONE")) {
 			nf_log_unbind_pf(tindex);
 			return 0;
 		}
 		mutex_lock(&nf_log_mutex);
-		logger = __find_logger(tindex, buffer);
+		logger = __find_logger(tindex, buf);
 		if (logger == NULL) {
 			mutex_unlock(&nf_log_mutex);
 			return -ENOENT;
