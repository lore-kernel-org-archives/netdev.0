From: Joe Perches <joe@perches.com>
Subject: [PATCH 5/8] wan: Remove unnecessary alloc/OOM messages
Date: Sun,  3 Feb 2013 19:28:12 -0800
Message-ID: <392e9b2c652a41f6c5791268dde1eb8c71d0be90.1359939013.git.joe@perches.com>
References: <cover.1359939012.git.joe@perches.com>
Cc: "Jan \"Yenya\" Kasprzak" <kas@fi.muni.cz>,
	Kevin Curtis <kevin.curtis@farsite.co.uk>,
	Krzysztof Halasa <khc@pm.waw.pl>, linux-kernel@vger.kernel.org
To: netdev@vger.kernel.org
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <cover.1359939012.git.joe@perches.com>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

alloc failures already get standardized OOM
messages and a dump_stack.

Hoist assigns from if tests.

Signed-off-by: Joe Perches <joe@perches.com>
---
 drivers/net/wan/cosa.c    | 9 ++++-----
 drivers/net/wan/farsync.c | 6 ++----
 drivers/net/wan/hdlc.c    | 9 ++++-----
 drivers/net/wan/x25_asy.c | 1 -
 4 files changed, 10 insertions(+), 15 deletions(-)

diff --git a/drivers/net/wan/cosa.c b/drivers/net/wan/cosa.c
index 6aed238..0179cef 100644
--- a/drivers/net/wan/cosa.c
+++ b/drivers/net/wan/cosa.c
@@ -795,8 +795,8 @@ static ssize_t cosa_read(struct file *file,
 	if (mutex_lock_interruptible(&chan->rlock))
 		return -ERESTARTSYS;
 	
-	if ((chan->rxdata = kmalloc(COSA_MTU, GFP_DMA|GFP_KERNEL)) == NULL) {
-		pr_info("%s: cosa_read() - OOM\n", cosa->name);
+	chan->rxdata = kmalloc(COSA_MTU, GFP_DMA|GFP_KERNEL);
+	if (chan->rxdata == NULL) {
 		mutex_unlock(&chan->rlock);
 		return -ENOMEM;
 	}
@@ -874,9 +874,8 @@ static ssize_t cosa_write(struct file *file,
 		count = COSA_MTU;
 	
 	/* Allocate the buffer */
-	if ((kbuf = kmalloc(count, GFP_KERNEL|GFP_DMA)) == NULL) {
-		pr_notice("%s: cosa_write() OOM - dropping packet\n",
-			  cosa->name);
+	kbuf = kmalloc(count, GFP_KERNEL|GFP_DMA);
+	if (kbuf == NULL) {
 		up(&chan->wsem);
 		return -ENOMEM;
 	}
diff --git a/drivers/net/wan/farsync.c b/drivers/net/wan/farsync.c
index 56941d6..3f0c4f2 100644
--- a/drivers/net/wan/farsync.c
+++ b/drivers/net/wan/farsync.c
@@ -2448,11 +2448,9 @@ fst_add_one(struct pci_dev *pdev, const struct pci_device_id *ent)
 	}
 
 	/* Allocate driver private data */
-	card = kzalloc(sizeof (struct fst_card_info), GFP_KERNEL);
-	if (card == NULL) {
-		pr_err("FarSync card found but insufficient memory for driver storage\n");
+	card = kzalloc(sizeof(struct fst_card_info), GFP_KERNEL);
+	if (card == NULL)
 		return -ENOMEM;
-	}
 
 	/* Try to enable the device */
 	if ((err = pci_enable_device(pdev)) != 0) {
diff --git a/drivers/net/wan/hdlc.c b/drivers/net/wan/hdlc.c
index 10cc7df..a0a932c 100644
--- a/drivers/net/wan/hdlc.c
+++ b/drivers/net/wan/hdlc.c
@@ -280,14 +280,13 @@ int attach_hdlc_protocol(struct net_device *dev, struct hdlc_proto *proto,
 	if (!try_module_get(proto->module))
 		return -ENOSYS;
 
-	if (size)
-		if ((dev_to_hdlc(dev)->state = kmalloc(size,
-						       GFP_KERNEL)) == NULL) {
-			netdev_warn(dev,
-				    "Memory squeeze on hdlc_proto_attach()\n");
+	if (size) {
+		dev_to_hdlc(dev)->state = kmalloc(size, GFP_KERNEL);
+		if (dev_to_hdlc(dev)->state == NULL) {
 			module_put(proto->module);
 			return -ENOBUFS;
 		}
+	}
 	dev_to_hdlc(dev)->proto = proto;
 	return 0;
 }
diff --git a/drivers/net/wan/x25_asy.c b/drivers/net/wan/x25_asy.c
index 44db8b7..5895f19 100644
--- a/drivers/net/wan/x25_asy.c
+++ b/drivers/net/wan/x25_asy.c
@@ -128,7 +128,6 @@ static int x25_asy_change_mtu(struct net_device *dev, int newmtu)
 	rbuff = kmalloc(len + 4, GFP_ATOMIC);
 
 	if (xbuff == NULL || rbuff == NULL) {
-		netdev_warn(dev, "unable to grow X.25 buffers, MTU change cancelled\n");
 		kfree(xbuff);
 		kfree(rbuff);
 		return -ENOMEM;
-- 
1.8.0.dirty
