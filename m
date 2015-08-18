From: Dan Carpenter <dan.carpenter@oracle.com>
Subject: [patch] cxgb4: memory corruption in debugfs
Date: Tue, 18 Aug 2015 12:31:44 +0300
Message-ID: <20150818093144.GG3965@mwanda>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: netdev@vger.kernel.org, kernel-janitors@vger.kernel.org
To: Hariprasad S <hariprasad@chelsio.com>
Return-path: <kernel-janitors-owner@vger.kernel.org>
Content-Disposition: inline
Sender: kernel-janitors-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

You can't use kstrtoul() with an int or it causes memory corruption.
Also j should be unsigned or we have underflow bugs.

I considered changing "j" to unsigned long but everything fits in a u32.

Fixes: 8e3d04fd7d70 ('cxgb4: Add MPS tracing support')
Signed-off-by: Dan Carpenter <dan.carpenter@oracle.com>

diff --git a/drivers/net/ethernet/chelsio/cxgb4/cxgb4_debugfs.c b/drivers/net/ethernet/chelsio/cxgb4/cxgb4_debugfs.c
index 1732e29..0a87a32 100644
--- a/drivers/net/ethernet/chelsio/cxgb4/cxgb4_debugfs.c
+++ b/drivers/net/ethernet/chelsio/cxgb4/cxgb4_debugfs.c
@@ -1289,13 +1289,14 @@ static unsigned int xdigit2int(unsigned char c)
 static ssize_t mps_trc_write(struct file *file, const char __user *buf,
 			     size_t count, loff_t *pos)
 {
-	int i, j, enable, ret;
+	int i, enable, ret;
 	u32 *data, *mask;
 	struct trace_params tp;
 	const struct inode *ino;
 	unsigned int trcidx;
 	char *s, *p, *word, *end;
 	struct adapter *adap;
+	u32 j;
 
 	ino = file_inode(file);
 	trcidx = (uintptr_t)ino->i_private & 3;
@@ -1340,7 +1341,7 @@ static ssize_t mps_trc_write(struct file *file, const char __user *buf,
 
 		if (!strncmp(word, "qid=", 4)) {
 			end = (char *)word + 4;
-			ret = kstrtoul(end, 10, (unsigned long *)&j);
+			ret = kstrtouint(end, 10, &j);
 			if (ret)
 				goto out;
 			if (!adap->trace_rss) {
@@ -1369,7 +1370,7 @@ static ssize_t mps_trc_write(struct file *file, const char __user *buf,
 		}
 		if (!strncmp(word, "snaplen=", 8)) {
 			end = (char *)word + 8;
-			ret = kstrtoul(end, 10, (unsigned long *)&j);
+			ret = kstrtouint(end, 10, &j);
 			if (ret || j > 9600) {
 inval:				count = -EINVAL;
 				goto out;
@@ -1379,7 +1380,7 @@ inval:				count = -EINVAL;
 		}
 		if (!strncmp(word, "minlen=", 7)) {
 			end = (char *)word + 7;
-			ret = kstrtoul(end, 10, (unsigned long *)&j);
+			ret = kstrtouint(end, 10, &j);
 			if (ret || j > TFMINPKTSIZE_M)
 				goto inval;
 			tp.min_len = j;
@@ -1453,7 +1454,7 @@ inval:				count = -EINVAL;
 		}
 		if (*word == '@') {
 			end = (char *)word + 1;
-			ret = kstrtoul(end, 10, (unsigned long *)&j);
+			ret = kstrtouint(end, 10, &j);
 			if (*end && *end != '\n')
 				goto inval;
 			if (j & 7)          /* doesn't start at multiple of 8 */
