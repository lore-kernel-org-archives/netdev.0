From: "Michael S. Tsirkin" <mst@redhat.com>
Subject: [PULL 1/2] vhost-net: extend device allocation to vmalloc
Date: Tue, 3 Jun 2014 00:30:15 +0300
Message-ID: <1401744482-17764-2-git-send-email-mst@redhat.com>
References: <1401744482-17764-1-git-send-email-mst@redhat.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
Cc: Michael Mueller <mimu@linux.vnet.ibm.com>, kvm@vger.kernel.org,
	netdev@vger.kernel.org, Romain Francoise <romain@orebokech.com>,
	virtualization@lists.linux-foundation.org,
	David Miller <davem@davemloft.net>
To: linux-kernel@vger.kernel.org
Return-path: <virtualization-bounces@lists.linux-foundation.org>
Content-Disposition: inline
In-Reply-To: <1401744482-17764-1-git-send-email-mst@redhat.com>
List-Unsubscribe: <https://lists.linuxfoundation.org/mailman/options/virtualization>,
	<mailto:virtualization-request@lists.linux-foundation.org?subject=unsubscribe>
List-Archive: <http://lists.linuxfoundation.org/pipermail/virtualization/>
List-Post: <mailto:virtualization@lists.linux-foundation.org>
List-Help: <mailto:virtualization-request@lists.linux-foundation.org?subject=help>
List-Subscribe: <https://lists.linuxfoundation.org/mailman/listinfo/virtualization>,
	<mailto:virtualization-request@lists.linux-foundation.org?subject=subscribe>
Sender: virtualization-bounces@lists.linux-foundation.org
Errors-To: virtualization-bounces@lists.linux-foundation.org
List-Id: netdev.vger.kernel.org

Michael Mueller provided a patch to reduce the size of
vhost-net structure as some allocations could fail under
memory pressure/fragmentation. We are still left with
high order allocations though.

This patch is handling the problem at the core level, allowing
vhost structures to use vmalloc() if kmalloc() failed.

As vmalloc() adds overhead on a critical network path, add __GFP_REPEAT
to kzalloc() flags to do this fallback only when really needed.

People are still looking at cleaner ways to handle the problem
at the API level, probably passing in multiple iovecs.
This hack seems consistent with approaches
taken since then by drivers/vhost/scsi.c and net/core/dev.c

Based on patch by Romain Francoise.

Cc: Michael Mueller <mimu@linux.vnet.ibm.com>
Signed-off-by: Romain Francoise <romain@orebokech.com>
Acked-by: Michael S. Tsirkin <mst@redhat.com>
---
 drivers/vhost/net.c | 23 ++++++++++++++++++-----
 1 file changed, 18 insertions(+), 5 deletions(-)

diff --git a/drivers/vhost/net.c b/drivers/vhost/net.c
index be414d2b..e489161 100644
--- a/drivers/vhost/net.c
+++ b/drivers/vhost/net.c
@@ -17,6 +17,7 @@
 #include <linux/workqueue.h>
 #include <linux/file.h>
 #include <linux/slab.h>
+#include <linux/vmalloc.h>
 
 #include <linux/net.h>
 #include <linux/if_packet.h>
@@ -699,18 +700,30 @@ static void handle_rx_net(struct vhost_work *work)
 	handle_rx(net);
 }
 
+static void vhost_net_free(void *addr)
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
 	struct vhost_virtqueue **vqs;
 	int i;
 
-	if (!n)
-		return -ENOMEM;
+	n = kmalloc(sizeof *n, GFP_KERNEL | __GFP_NOWARN | __GFP_REPEAT);
+	if (!n) {
+		n = vmalloc(sizeof *n);
+		if (!n)
+			return -ENOMEM;
+	}
 	vqs = kmalloc(VHOST_NET_VQ_MAX * sizeof(*vqs), GFP_KERNEL);
 	if (!vqs) {
-		kfree(n);
+		vhost_net_free(n);
 		return -ENOMEM;
 	}
 
@@ -827,7 +840,7 @@ static int vhost_net_release(struct inode *inode, struct file *f)
 	 * since jobs can re-queue themselves. */
 	vhost_net_flush(n);
 	kfree(n->dev.vqs);
-	kfree(n);
+	vhost_net_free(n);
 	return 0;
 }
 
-- 
MST
