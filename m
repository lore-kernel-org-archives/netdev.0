From: Li Zefan <lizf@cn.fujitsu.com>
Subject: [PATCH] CONNECTOR: add a proc entry to list connectors
Date: Tue, 24 Jun 2008 09:30:44 +0800
Message-ID: <48604E44.5040402@cn.fujitsu.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Content-Transfer-Encoding: 7bit
Cc: LKML <linux-kernel@vger.kernel.org>, netdev@vger.kernel.org,
	Evgeniy Polyakov <johnpol@2ka.mipt.ru>
To: David Miller <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from cn.fujitsu.com ([222.73.24.84]:60067 "EHLO song.cn.fujitsu.com"
	rhost-flags-OK-FAIL-OK-OK) by vger.kernel.org with ESMTP
	id S1756155AbYFXBcP (ORCPT <rfc822;netdev@vger.kernel.org>);
	Mon, 23 Jun 2008 21:32:15 -0400
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

I got a problem when I wanted to check if the kernel supports process
event connector, and It seems there's no way to do this check.

At best I can check if the kernel supports connector or not, by looking
into /proc/net/netlink, or maybe checking the return value of bind() to
see if it's ENOENT.

So how about add /proc/net/connector to list all supported connectors?
 # cat /proc/net/connector
 Name      ID
 connector 4294967295:4294967295
 cn_proc   1:1
 w1        3:1

Signed-off-by: Li Zefan <lizf@cn.fujitsu.com>
---
 drivers/connector/connector.c |   41 +++++++++++++++++++++++++++++++++++++++++
 1 files changed, 41 insertions(+), 0 deletions(-)

diff --git a/drivers/connector/connector.c b/drivers/connector/connector.c
index 85e2ba7..08f9983 100644
--- a/drivers/connector/connector.c
+++ b/drivers/connector/connector.c
@@ -27,6 +27,8 @@
 #include <linux/moduleparam.h>
 #include <linux/connector.h>
 #include <linux/mutex.h>
+#include <linux/proc_fs.h>
+#include <linux/spinlock.h>
 
 #include <net/sock.h>
 
@@ -403,6 +405,41 @@ static void cn_callback(void *data)
 	mutex_unlock(&notify_lock);
 }
 
+static int cn_proc_show(struct seq_file *m, void *v)
+{
+	struct cn_queue_dev *dev = cdev.cbdev;
+	struct cn_callback_entry *cbq;
+	unsigned long flags;
+
+	seq_printf(m, "Name      ID\n");
+
+	spin_lock_irqsave(&dev->queue_lock, flags);
+
+	list_for_each_entry(cbq, &dev->queue_list, callback_entry) {
+		seq_printf(m, "%-9s %u:%u\n",
+			   cbq->id.name,
+			   cbq->id.id.idx,
+			   cbq->id.id.val);
+	}
+
+	spin_unlock_irqrestore(&dev->queue_lock, flags);
+
+	return 0;
+}
+
+static int cn_proc_open(struct inode *inode, struct file *file)
+{
+	return single_open(file, cn_proc_show, NULL);
+}
+
+static const struct file_operations cn_file_ops = {
+	.owner   = THIS_MODULE,
+	.open    = cn_proc_open,
+	.read    = seq_read,
+	.llseek  = seq_lseek,
+	.release = seq_release
+};
+
 static int __devinit cn_init(void)
 {
 	struct cn_dev *dev = &cdev;
@@ -434,6 +471,8 @@ static int __devinit cn_init(void)
 		return -EINVAL;
 	}
 
+	proc_net_fops_create(&init_net, "connector", S_IRUGO, &cn_file_ops);
+
 	return 0;
 }
 
@@ -443,6 +482,8 @@ static void __devexit cn_fini(void)
 
 	cn_already_initialized = 0;
 
+	proc_net_remove(&init_net, "connector");
+
 	cn_del_callback(&dev->id);
 	cn_queue_free_dev(dev->cbdev);
 	netlink_kernel_release(dev->nls);
-- 
1.5.4.rc3

