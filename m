From: Li Zefan <lizf@cn.fujitsu.com>
Subject: [PATCH v2] CONNECTOR: add a proc entry to list connectors
Date: Tue, 24 Jun 2008 16:38:17 +0800
Message-ID: <4860B279.9070105@cn.fujitsu.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Content-Transfer-Encoding: 7bit
Cc: Evgeniy Polyakov <johnpol@2ka.mipt.ru>,
	LKML <linux-kernel@vger.kernel.org>, netdev@vger.kernel.org
To: David Miller <davem@davemloft.net>
Return-path: <linux-kernel-owner+glk-linux-kernel-3=40m.gmane.org-S1758623AbYFXIkK@vger.kernel.org>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

I got a problem when I wanted to check if the kernel supports process
event connector, and It seems there's no way to do this check.

At best I can check if the kernel supports connector or not, by looking
into /proc/net/netlink, or maybe checking the return value of bind() to
see if it's ENOENT.

So it would be useful to add /proc/net/connector to list all supported
connectors:
 # cat /proc/net/connector
 Name            ID
 connector       4294967295:4294967295
 cn_proc         1:1
 w1              3:1

Changelog:
- fix memory leak: s/seq_release/single_release
- use spin_lock_bh instead of spin_lock_irqsave

Signed-off-by: Li Zefan <lizf@cn.fujitsu.com>
Acked-by: Evgeniy Polyakov <johnpol@2ka.mipt.ru>
---
 drivers/connector/connector.c |   40 ++++++++++++++++++++++++++++++++++++++++
 1 files changed, 40 insertions(+), 0 deletions(-)

diff --git a/drivers/connector/connector.c b/drivers/connector/connector.c
index 85e2ba7..bf48300 100644
--- a/drivers/connector/connector.c
+++ b/drivers/connector/connector.c
@@ -27,6 +27,8 @@
 #include <linux/moduleparam.h>
 #include <linux/connector.h>
 #include <linux/mutex.h>
+#include <linux/proc_fs.h>
+#include <linux/spinlock.h>
 
 #include <net/sock.h>
 
@@ -403,6 +405,40 @@ static void cn_callback(void *data)
 	mutex_unlock(&notify_lock);
 }
 
+static int cn_proc_show(struct seq_file *m, void *v)
+{
+	struct cn_queue_dev *dev = cdev.cbdev;
+	struct cn_callback_entry *cbq;
+
+	seq_printf(m, "Name            ID\n");
+
+	spin_lock_bh(&dev->queue_lock);
+
+	list_for_each_entry(cbq, &dev->queue_list, callback_entry) {
+		seq_printf(m, "%-15s %u:%u\n",
+			   cbq->id.name,
+			   cbq->id.id.idx,
+			   cbq->id.id.val);
+	}
+
+	spin_unlock_bh(&dev->queue_lock);
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
+	.release = single_release
+};
+
 static int __devinit cn_init(void)
 {
 	struct cn_dev *dev = &cdev;
@@ -434,6 +470,8 @@ static int __devinit cn_init(void)
 		return -EINVAL;
 	}
 
+	proc_net_fops_create(&init_net, "connector", S_IRUGO, &cn_file_ops);
+
 	return 0;
 }
 
@@ -443,6 +481,8 @@ static void __devexit cn_fini(void)
 
 	cn_already_initialized = 0;
 
+	proc_net_remove(&init_net, "connector");
+
 	cn_del_callback(&dev->id);
 	cn_queue_free_dev(dev->cbdev);
 	netlink_kernel_release(dev->nls);
-- 
1.5.4.rc3
