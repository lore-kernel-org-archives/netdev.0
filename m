From: Jon Mason <jon.mason@intel.com>
Subject: [PATCH 11/21] NTB: correct stack usage warning in debugfs_read
Date: Sat, 19 Jan 2013 02:02:25 -0700
Message-ID: <1358586155-23322-12-git-send-email-jon.mason@intel.com>
References: <1358586155-23322-1-git-send-email-jon.mason@intel.com>
Cc: linux-kernel@vger.kernel.org, netdev@vger.kernel.org,
	Dave Jiang <dave.jiang@intel.com>,
	Nicholas Bellinger <nab@linux-iscsi.org>
To: Greg KH <gregkh@linuxfoundation.org>
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <1358586155-23322-1-git-send-email-jon.mason@intel.com>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Correct gcc warning of using too much stack debugfs_read.  This is done
by kmallocing the buffer instead of using the char array on stack.
Also, shrinking the buffer to something closer to what is currently
being used.

Signed-off-by: Jon Mason <jon.mason@intel.com>
---
 drivers/ntb/ntb_transport.c |   13 ++++++++++---
 1 file changed, 10 insertions(+), 3 deletions(-)

diff --git a/drivers/ntb/ntb_transport.c b/drivers/ntb/ntb_transport.c
index e11b57e..1bed1ba 100644
--- a/drivers/ntb/ntb_transport.c
+++ b/drivers/ntb/ntb_transport.c
@@ -368,10 +368,14 @@ static ssize_t debugfs_read(struct file *filp, char __user *ubuf, size_t count,
 			    loff_t *offp)
 {
 	struct ntb_transport_qp *qp;
-	char buf[1024];
+	char *buf;
 	ssize_t ret, out_offset, out_count;
 
-	out_count = 1024;
+	out_count = 600;
+
+	buf = kmalloc(out_count, GFP_KERNEL);
+	if (!buf)
+		return -ENOMEM;
 
 	qp = filp->private_data;
 	out_offset = 0;
@@ -410,10 +414,13 @@ static ssize_t debugfs_read(struct file *filp, char __user *ubuf, size_t count,
 			       "tx_mw_end - \t%p\n", qp->tx_mw_end);
 
 	out_offset += snprintf(buf + out_offset, out_count - out_offset,
-			       "QP Link %s\n", (qp->qp_link == NTB_LINK_UP) ?
+			       "\nQP Link %s\n", (qp->qp_link == NTB_LINK_UP) ?
 			       "Up" : "Down");
+	if (out_offset > out_count)
+		out_offset = out_count;
 
 	ret = simple_read_from_buffer(ubuf, count, offp, buf, out_offset);
+	kfree(buf);
 	return ret;
 }
 
-- 
1.7.9.5
