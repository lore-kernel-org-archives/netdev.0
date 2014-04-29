From: "Andrew J. Bennieston" <andrew.bennieston@citrix.com>
Subject: [PATCH V7 net-next 1/7] xen-netback: Move grant_copy_op
	array back into struct xenvif.
Date: Tue, 29 Apr 2014 14:27:09 +0100
Message-ID: <1398778035-26233-2-git-send-email-andrew.bennieston@citrix.com>
References: <1398778035-26233-1-git-send-email-andrew.bennieston@citrix.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
Cc: wei.liu2@citrix.com, ian.campbell@citrix.com, netdev@vger.kernel.org,
	paul.durrant@citrix.com, david.vrabel@citrix.com, zoltan.kiss@citrix.com,
	"Andrew J. Bennieston" <andrew.bennieston@citrix.com>
To: <xen-devel@lists.xenproject.org>, <davem@davemloft.net>
Return-path: <xen-devel-bounces@lists.xen.org>
In-Reply-To: <1398778035-26233-1-git-send-email-andrew.bennieston@citrix.com>
List-Unsubscribe: <http://lists.xen.org/cgi-bin/mailman/options/xen-devel>,
	<mailto:xen-devel-request@lists.xen.org?subject=unsubscribe>
List-Post: <mailto:xen-devel@lists.xen.org>
List-Help: <mailto:xen-devel-request@lists.xen.org?subject=help>
List-Subscribe: <http://lists.xen.org/cgi-bin/mailman/listinfo/xen-devel>,
	<mailto:xen-devel-request@lists.xen.org?subject=subscribe>
Sender: xen-devel-bounces@lists.xen.org
Errors-To: xen-devel-bounces@lists.xen.org
List-Id: netdev.vger.kernel.org

From: "Andrew J. Bennieston" <andrew.bennieston@citrix.com>

This array was allocated separately in commit ac3d5ac2 due to it being
very large, and a struct xenvif is allocated as the netdev_priv part of
a struct net_device, i.e. via kmalloc() but falling back to vmalloc() if
the initial alloc. fails.

In preparation for the multi-queue patches, where this array becomes
part of struct xenvif_queue and is always allocated through vzalloc(),
move this back into the struct xenvif.

Signed-off-by: Andrew J. Bennieston <andrew.bennieston@citrix.com>
---
 drivers/net/xen-netback/common.h    |    3 +--
 drivers/net/xen-netback/interface.c |    9 ---------
 2 files changed, 1 insertion(+), 11 deletions(-)

diff --git a/drivers/net/xen-netback/common.h b/drivers/net/xen-netback/common.h
index 630a3fc..747853e 100644
--- a/drivers/net/xen-netback/common.h
+++ b/drivers/net/xen-netback/common.h
@@ -158,8 +158,7 @@ struct xenvif {
 
 	struct timer_list wake_queue;
 
-	/* This array is allocated seperately as it is large */
-	struct gnttab_copy *grant_copy_op;
+	struct gnttab_copy grant_copy_op[MAX_GRANT_COPY_OPS];
 
 	/* We create one meta structure per ring request we consume, so
 	 * the maximum number is the same as the ring size.
diff --git a/drivers/net/xen-netback/interface.c b/drivers/net/xen-netback/interface.c
index ef05c5c..bcc2e7f 100644
--- a/drivers/net/xen-netback/interface.c
+++ b/drivers/net/xen-netback/interface.c
@@ -358,14 +358,6 @@ struct xenvif *xenvif_alloc(struct device *parent, domid_t domid,
 
 	vif = netdev_priv(dev);
 
-	vif->grant_copy_op = vmalloc(sizeof(struct gnttab_copy) *
-				     MAX_GRANT_COPY_OPS);
-	if (vif->grant_copy_op == NULL) {
-		pr_warn("Could not allocate grant copy space for %s\n", name);
-		free_netdev(dev);
-		return ERR_PTR(-ENOMEM);
-	}
-
 	vif->domid  = domid;
 	vif->handle = handle;
 	vif->can_sg = 1;
@@ -625,7 +617,6 @@ void xenvif_free(struct xenvif *vif)
 
 	unregister_netdev(vif->dev);
 
-	vfree(vif->grant_copy_op);
 	free_netdev(vif->dev);
 
 	module_put(THIS_MODULE);
-- 
1.7.10.4
