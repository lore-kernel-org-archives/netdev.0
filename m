From: Wei Liu <wei.liu2@citrix.com>
Subject: [RFC PATCH V4 03/13] netback: add module get/put
	operations along with vif connect/disconnect.
Date: Thu, 2 Feb 2012 16:49:13 +0000
Message-ID: <1328201363-13915-4-git-send-email-wei.liu2@citrix.com>
References: <1328201363-13915-1-git-send-email-wei.liu2@citrix.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
Cc: Wei Liu <wei.liu2@citrix.com>, ian.campbell@citrix.com,
	konrad.wilk@oracle.com
To: netdev@vger.kernel.org, xen-devel@lists.xensource.com
Return-path: <xen-devel-bounces@lists.xensource.com>
In-Reply-To: <1328201363-13915-1-git-send-email-wei.liu2@citrix.com>
List-Unsubscribe: <http://lists.xensource.com/mailman/options/xen-devel>,
	<mailto:xen-devel-request@lists.xensource.com?subject=unsubscribe>
List-Post: <mailto:xen-devel@lists.xensource.com>
List-Help: <mailto:xen-devel-request@lists.xensource.com?subject=help>
List-Subscribe: <http://lists.xensource.com/mailman/listinfo/xen-devel>,
	<mailto:xen-devel-request@lists.xensource.com?subject=subscribe>
Sender: xen-devel-bounces@lists.xensource.com
Errors-To: xen-devel-bounces@lists.xensource.com
List-Id: netdev.vger.kernel.org

If there is vif running and user unloads netback, it will certainly
cause problems -- guest's network interface just mysteriously stops
working.

disconnect function may get called by the generic framework even
before vif connects.

Tested-by: Konrad Rzeszutek Wilk <konrad.wilk@oracle.com>
Signed-off-by: Wei Liu <wei.liu2@citrix.com>
---
 drivers/net/xen-netback/interface.c |   12 +++++++++++-
 1 files changed, 11 insertions(+), 1 deletions(-)

diff --git a/drivers/net/xen-netback/interface.c b/drivers/net/xen-netback/interface.c
index 1825629..4795c0f 100644
--- a/drivers/net/xen-netback/interface.c
+++ b/drivers/net/xen-netback/interface.c
@@ -312,6 +312,8 @@ int xenvif_connect(struct xenvif *vif, unsigned long tx_ring_ref,
 	if (vif->irq)
 		return 0;
 
+	__module_get(THIS_MODULE);
+
 	err = xen_netbk_map_frontend_rings(vif, tx_ring_ref, rx_ring_ref);
 	if (err < 0)
 		goto err;
@@ -339,12 +341,15 @@ int xenvif_connect(struct xenvif *vif, unsigned long tx_ring_ref,
 err_unmap:
 	xen_netbk_unmap_frontend_rings(vif);
 err:
+	module_put(THIS_MODULE);
 	return err;
 }
 
 void xenvif_disconnect(struct xenvif *vif)
 {
 	struct net_device *dev = vif->dev;
+	int need_module_put = 0;
+
 	if (netif_carrier_ok(dev)) {
 		rtnl_lock();
 		netif_carrier_off(dev); /* discard queued packets */
@@ -359,12 +364,17 @@ void xenvif_disconnect(struct xenvif *vif)
 
 	del_timer_sync(&vif->credit_timeout);
 
-	if (vif->irq)
+	if (vif->irq) {
 		unbind_from_irqhandler(vif->irq, vif);
+		need_module_put = 1;
+	}
 
 	unregister_netdev(vif->dev);
 
 	xen_netbk_unmap_frontend_rings(vif);
 
 	free_netdev(vif->dev);
+
+	if (need_module_put)
+		module_put(THIS_MODULE);
 }
-- 
1.7.2.5
