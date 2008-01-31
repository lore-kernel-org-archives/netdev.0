From: "Denis V. Lunev" <den@openvz.org>
Subject: [PATCH 3/3] [RAW]: Wrong content of the /proc/net/raw6.
Date: Thu, 31 Jan 2008 14:34:54 +0300
Message-ID: <1201779294-21987-3-git-send-email-den@openvz.org>
References: <47A1B1E4.2010804@sw.ru>
Cc: netdev@vger.kernel.org, linux-kernel@vger.kernel.org,
	devel@openvz.org, xemul@openvz.org, bunk@kernel.org,
	"Denis V. Lunev" <den@openvz.org>
To: davem@davemloft.net
Return-path: <netdev-owner@vger.kernel.org>
Received: from swsoft-msk-nat.sw.ru ([195.214.232.10]:51975 "EHLO iris.sw.ru"
	rhost-flags-OK-OK-OK-FAIL) by vger.kernel.org with ESMTP
	id S1756448AbYAaLev (ORCPT <rfc822;netdev@vger.kernel.org>);
	Thu, 31 Jan 2008 06:34:51 -0500
In-Reply-To: <47A1B1E4.2010804@sw.ru>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

The address of IPv6 raw sockets was shown in the wrong format, from IPv4 ones.
The problem has been introduced by the
commit 42a73808ed4f30b739eb52bcbb33a02fe62ceef5
Author: Pavel Emelyanov <xemul@openvz.org>
Date:   Mon Nov 19 22:38:33 2007 -0800

Thanks to Adrian Bunk who originally noticed the problem.

Signed-off-by: Denis V. Lunev <den@openvz.org>
---
 include/net/raw.h |    3 ++-
 net/ipv4/raw.c    |    8 ++++----
 net/ipv6/raw.c    |    2 +-
 3 files changed, 7 insertions(+), 6 deletions(-)

diff --git a/include/net/raw.h b/include/net/raw.h
index c7ea7a2..1828f81 100644
--- a/include/net/raw.h
+++ b/include/net/raw.h
@@ -48,7 +48,8 @@ struct raw_iter_state {
 void *raw_seq_start(struct seq_file *seq, loff_t *pos);
 void *raw_seq_next(struct seq_file *seq, void *v, loff_t *pos);
 void raw_seq_stop(struct seq_file *seq, void *v);
-int raw_seq_open(struct inode *ino, struct file *file, struct raw_hashinfo *h);
+int raw_seq_open(struct inode *ino, struct file *file,
+		 struct raw_hashinfo *h, const struct seq_operations *ops);
 
 #endif
 
diff --git a/net/ipv4/raw.c b/net/ipv4/raw.c
index 830f19e..a3002fe 100644
--- a/net/ipv4/raw.c
+++ b/net/ipv4/raw.c
@@ -962,13 +962,13 @@ static const struct seq_operations raw_seq_ops = {
 	.show  = raw_seq_show,
 };
 
-int raw_seq_open(struct inode *ino, struct file *file, struct raw_hashinfo *h)
+int raw_seq_open(struct inode *ino, struct file *file,
+		 struct raw_hashinfo *h, const struct seq_operations *ops)
 {
 	int err;
 	struct raw_iter_state *i;
 
-	err = seq_open_net(ino, file, &raw_seq_ops,
-			sizeof(struct raw_iter_state));
+	err = seq_open_net(ino, file, ops, sizeof(struct raw_iter_state));
 	if (err < 0)
 		return err;
 
@@ -980,7 +980,7 @@ EXPORT_SYMBOL_GPL(raw_seq_open);
 
 static int raw_v4_seq_open(struct inode *inode, struct file *file)
 {
-	return raw_seq_open(inode, file, &raw_v4_hashinfo);
+	return raw_seq_open(inode, file, &raw_v4_hashinfo, &raw_seq_ops);
 }
 
 static const struct file_operations raw_seq_fops = {
diff --git a/net/ipv6/raw.c b/net/ipv6/raw.c
index a2cf499..8897ccf 100644
--- a/net/ipv6/raw.c
+++ b/net/ipv6/raw.c
@@ -1262,7 +1262,7 @@ static const struct seq_operations raw6_seq_ops = {
 
 static int raw6_seq_open(struct inode *inode, struct file *file)
 {
-	return raw_seq_open(inode, file, &raw_v6_hashinfo);
+	return raw_seq_open(inode, file, &raw_v6_hashinfo, &raw6_seq_ops);
 }
 
 static const struct file_operations raw6_seq_fops = {
-- 
1.5.3.rc5

