From: Wei Liu <wei.liu2@citrix.com>
Subject: [PATCH net-next] xen-netback: enable user to unload netback module
Date: Fri, 17 May 2013 10:26:11 +0100
Message-ID: <1368782771-24005-1-git-send-email-wei.liu2@citrix.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: Wei Liu <wei.liu2@citrix.com>
To: <netdev@vger.kernel.org>, <xen-devel@lists.xen.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from smtp02.citrix.com ([66.165.176.63]:9341 "EHLO SMTP02.CITRIX.COM"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1752033Ab3EQJ0W (ORCPT <rfc822;netdev@vger.kernel.org>);
	Fri, 17 May 2013 05:26:22 -0400
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

This patch enables user to unload netback module, which is useful when =
user
wants to upgrade to a newer netback module without rebooting the host.

Netfront cannot handle netback removal event. As we cannot fix all poss=
ible
frontends we add module get / put along with vif get / put to avoid
mis-unloading of netback. To unload netback module, user needs to shutd=
own all
VMs or migrate them to another host or unplug all vifs before hand.

Signed-off-by: Wei Liu <wei.liu2@citrix.com>
Acked-by: Ian Campbell <ian.campbell@citrix.com>=C2=AC
---
 drivers/net/xen-netback/common.h    |    1 +
 drivers/net/xen-netback/interface.c |   19 ++++++++++++++++++-
 drivers/net/xen-netback/netback.c   |   20 ++++++++++++++++++++
 drivers/net/xen-netback/xenbus.c    |    5 +++++
 4 files changed, 44 insertions(+), 1 deletion(-)

diff --git a/drivers/net/xen-netback/common.h b/drivers/net/xen-netback=
/common.h
index 9d7f172..6102a6c 100644
--- a/drivers/net/xen-netback/common.h
+++ b/drivers/net/xen-netback/common.h
@@ -120,6 +120,7 @@ void xenvif_get(struct xenvif *vif);
 void xenvif_put(struct xenvif *vif);
=20
 int xenvif_xenbus_init(void);
+void xenvif_xenbus_fini(void);
=20
 int xenvif_schedulable(struct xenvif *vif);
=20
diff --git a/drivers/net/xen-netback/interface.c b/drivers/net/xen-netb=
ack/interface.c
index d984141..82202c2 100644
--- a/drivers/net/xen-netback/interface.c
+++ b/drivers/net/xen-netback/interface.c
@@ -316,6 +316,8 @@ int xenvif_connect(struct xenvif *vif, unsigned lon=
g tx_ring_ref,
 	if (vif->irq)
 		return 0;
=20
+	__module_get(THIS_MODULE);
+
 	err =3D xen_netbk_map_frontend_rings(vif, tx_ring_ref, rx_ring_ref);
 	if (err < 0)
 		goto err;
@@ -343,6 +345,7 @@ int xenvif_connect(struct xenvif *vif, unsigned lon=
g tx_ring_ref,
 err_unmap:
 	xen_netbk_unmap_frontend_rings(vif);
 err:
+	module_put(THIS_MODULE);
 	return err;
 }
=20
@@ -360,18 +363,32 @@ void xenvif_carrier_off(struct xenvif *vif)
=20
 void xenvif_disconnect(struct xenvif *vif)
 {
+	/* Disconnect funtion might get called by generic framework
+	 * even before vif connects, so we need to check if we really
+	 * need to do a module_put.
+	 */
+	int need_module_put =3D 0;
+
 	if (netif_carrier_ok(vif->dev))
 		xenvif_carrier_off(vif);
=20
 	atomic_dec(&vif->refcnt);
 	wait_event(vif->waiting_to_free, atomic_read(&vif->refcnt) =3D=3D 0);
=20
-	if (vif->irq)
+	if (vif->irq) {
 		unbind_from_irqhandler(vif->irq, vif);
+		/* vif->irq is valid, we had a module_get in
+		 * xenvif_connect.
+		 */
+		need_module_put =3D 1;
+	}
=20
 	unregister_netdev(vif->dev);
=20
 	xen_netbk_unmap_frontend_rings(vif);
=20
 	free_netdev(vif->dev);
+
+	if (need_module_put)
+		module_put(THIS_MODULE);
 }
diff --git a/drivers/net/xen-netback/netback.c b/drivers/net/xen-netbac=
k/netback.c
index 295a9c2..2d9477f 100644
--- a/drivers/net/xen-netback/netback.c
+++ b/drivers/net/xen-netback/netback.c
@@ -1949,5 +1949,25 @@ failed_init:
=20
 module_init(netback_init);
=20
+static void __exit netback_fini(void)
+{
+	int i, j;
+
+	xenvif_xenbus_fini();
+
+	for (i =3D 0; i < xen_netbk_group_nr; i++) {
+		struct xen_netbk *netbk =3D &xen_netbk[i];
+		del_timer_sync(&netbk->net_timer);
+		kthread_stop(netbk->task);
+		for (j =3D 0; j < MAX_PENDING_REQS; j++) {
+			if (netbk->mmap_pages[i])
+				__free_page(netbk->mmap_pages[i]);
+		}
+	}
+
+	vfree(xen_netbk);
+}
+module_exit(netback_fini);
+
 MODULE_LICENSE("Dual BSD/GPL");
 MODULE_ALIAS("xen-backend:vif");
diff --git a/drivers/net/xen-netback/xenbus.c b/drivers/net/xen-netback=
/xenbus.c
index 410018c..d230c14 100644
--- a/drivers/net/xen-netback/xenbus.c
+++ b/drivers/net/xen-netback/xenbus.c
@@ -485,3 +485,8 @@ int xenvif_xenbus_init(void)
 {
 	return xenbus_register_backend(&netback_driver);
 }
+
+void xenvif_xenbus_fini(void)
+{
+	return xenbus_unregister_driver(&netback_driver);
+}
--=20
1.7.10.4
