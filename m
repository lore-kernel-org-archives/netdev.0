From: Romain Francoise <romain@orebokech.com>
Subject: [PATCH] vhost-net: fall back to vmalloc if high-order allocation fails
Date: Wed, 23 Jan 2013 21:46:47 +0100
Message-ID: <87k3r31vbc.fsf@silenus.orebokech.com>
Mime-Version: 1.0
Content-Type: text/plain
Cc: kvm@vger.kernel.org, netdev@vger.kernel.org,
	linux-kernel@vger.kernel.org
To: "Michael S. Tsirkin" <mst@redhat.com>
Return-path: <kvm-owner@vger.kernel.org>
Sender: kvm-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Creating a vhost-net device allocates an object large enough (34320 bytes
on x86-64) to trigger an order-4 allocation, which may fail if memory if
fragmented:

 libvirtd: page allocation failure: order:4, mode:0x2000d0
 ...
 SLAB: Unable to allocate memory on node 0 (gfp=0xd0)
   cache: size-65536, object size: 65536, order: 4
   node 0: slabs: 8/8, objs: 8/8, free: 0

In that situation, rather than forcing the caller to use regular
virtio-net, try to allocate the descriptor with vmalloc().

Signed-off-by: Romain Francoise <romain@orebokech.com>
---
 drivers/vhost/net.c | 18 +++++++++++++++---
 1 file changed, 15 insertions(+), 3 deletions(-)

diff --git a/drivers/vhost/net.c b/drivers/vhost/net.c
index ebd08b2..1ded79b 100644
--- a/drivers/vhost/net.c
+++ b/drivers/vhost/net.c
@@ -18,6 +18,7 @@
 #include <linux/rcupdate.h>
 #include <linux/file.h>
 #include <linux/slab.h>
+#include <linux/vmalloc.h>
 
 #include <linux/net.h>
 #include <linux/if_packet.h>
@@ -603,12 +604,23 @@ static void handle_rx_net(struct vhost_work *work)
 	handle_rx(net);
 }
 
+static void vhost_net_kvfree(void *addr)
+{
+	if (is_vmalloc_addr(addr))
+		vfree(addr);
+	else
+		kfree(addr);
+}
+
 static int vhost_net_open(struct inode *inode, struct file *f)
 {
-	struct vhost_net *n = kmalloc(sizeof *n, GFP_KERNEL);
+	struct vhost_net *n;
 	struct vhost_dev *dev;
 	int r;
 
+	n = kmalloc(sizeof *n, GFP_KERNEL | __GFP_NOWARN);
+	if (!n)
+		n = vmalloc(sizeof *n);
 	if (!n)
 		return -ENOMEM;
 
@@ -617,7 +629,7 @@ static int vhost_net_open(struct inode *inode, struct file *f)
 	n->vqs[VHOST_NET_VQ_RX].handle_kick = handle_rx_kick;
 	r = vhost_dev_init(dev, n->vqs, VHOST_NET_VQ_MAX);
 	if (r < 0) {
-		kfree(n);
+		vhost_net_kvfree(n);
 		return r;
 	}
 
@@ -719,7 +731,7 @@ static int vhost_net_release(struct inode *inode, struct file *f)
 	/* We do an extra flush before freeing memory,
 	 * since jobs can re-queue themselves. */
 	vhost_net_flush(n);
-	kfree(n);
+	vhost_net_kvfree(n);
 	return 0;
 }
 
-- 
1.8.1.1

