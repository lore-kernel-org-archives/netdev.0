From: Mathias Krause <minipli@googlemail.com>
Subject: [PATCH net-next 2/3] pktgen: simplify error handling in pgctrl_write()
Date: Fri, 21 Feb 2014 21:38:35 +0100
Message-ID: <1393015116-7488-3-git-send-email-minipli@googlemail.com>
References: <1393015116-7488-1-git-send-email-minipli@googlemail.com>
Cc: netdev@vger.kernel.org, Mathias Krause <minipli@googlemail.com>
To: "David S. Miller" <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-bk0-f50.google.com ([209.85.214.50]:40144 "EHLO
	mail-bk0-f50.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752456AbaBUUiv (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 21 Feb 2014 15:38:51 -0500
Received: by mail-bk0-f50.google.com with SMTP id d7so1198790bkh.9
        for <netdev@vger.kernel.org>; Fri, 21 Feb 2014 12:38:49 -0800 (PST)
In-Reply-To: <1393015116-7488-1-git-send-email-minipli@googlemail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

The 'out' label is just a relict from previous times as pgctrl_write()
had multiple error paths. Get rid of it and simply return right away
on errors.

Cc: "David S. Miller" <davem@davemloft.net>
Signed-off-by: Mathias Krause <minipli@googlemail.com>
---
 net/core/pktgen.c |   19 ++++++-------------
 1 file changed, 6 insertions(+), 13 deletions(-)

diff --git a/net/core/pktgen.c b/net/core/pktgen.c
index cc07c43494..53c3097117 100644
--- a/net/core/pktgen.c
+++ b/net/core/pktgen.c
@@ -476,14 +476,11 @@ static int pgctrl_show(struct seq_file *seq, void *v)
 static ssize_t pgctrl_write(struct file *file, const char __user *buf,
 			    size_t count, loff_t *ppos)
 {
-	int err = 0;
 	char data[128];
 	struct pktgen_net *pn = net_generic(current->nsproxy->net_ns, pg_net_id);
 
-	if (!capable(CAP_NET_ADMIN)) {
-		err = -EPERM;
-		goto out;
-	}
+	if (!capable(CAP_NET_ADMIN))
+		return -EPERM;
 
 	if (count == 0)
 		return -EINVAL;
@@ -491,10 +488,9 @@ static ssize_t pgctrl_write(struct file *file, const char __user *buf,
 	if (count > sizeof(data))
 		count = sizeof(data);
 
-	if (copy_from_user(data, buf, count)) {
-		err = -EFAULT;
-		goto out;
-	}
+	if (copy_from_user(data, buf, count))
+		return -EFAULT;
+
 	data[count - 1] = 0;	/* Strip trailing '\n' and terminate string */
 
 	if (!strcmp(data, "stop"))
@@ -509,10 +505,7 @@ static ssize_t pgctrl_write(struct file *file, const char __user *buf,
 	else
 		pr_warning("Unknown command: %s\n", data);
 
-	err = count;
-
-out:
-	return err;
+	return count;
 }
 
 static int pgctrl_open(struct inode *inode, struct file *file)
-- 
1.7.10.4
