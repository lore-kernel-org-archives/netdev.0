From: Wei Liu <wei.liu2@citrix.com>
Subject: [PATCH v3 net] xen-netback: disable rogue vif in kthread context
Date: Tue, 1 Apr 2014 12:33:57 +0100
Message-ID: <1396352037-7721-1-git-send-email-wei.liu2@citrix.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: <david.vrabel@citrix.com>, <zoltan.kiss@citrix.com>,
	<edwin@etorok.net>, Wei Liu <wei.liu2@citrix.com>,
	Ian Campbell <ian.campbell@citrix.com>
To: <netdev@vger.kernel.org>, <xen-devel@lists.xen.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from smtp02.citrix.com ([66.165.176.63]:23688 "EHLO
	SMTP02.CITRIX.COM" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752924AbaDALd7 (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 1 Apr 2014 07:33:59 -0400
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

When netback discovers frontend is sending malformed packet it will
disables the interface which serves that frontend.

However disabling a network interface involving taking a mutex which
cannot be done in softirq context, so we need to defer this process to
kthread context.

This patch does the following:
1. introduce a flag to indicate the interface is disabled.
2. check that flag in TX path, don't do any work if it's true.
3. check that flag in RX path, turn off that interface if it's true.

The reason to disable it in RX path is because RX uses kthread. After
this change the behavior of netback is still consistent -- it won't do
any TX work for a rogue frontend, and the interface will be eventually
turned off.

Also change a "continue" to "break" after xenvif_fatal_tx_err, as it
doesn't make sense to continue processing packets if frontend is rogue.

This is a fix for XSA-90.

Reported-by: T=C3=B6r=C3=B6k Edwin <edwin@etorok.net>
Signed-off-by: Wei Liu <wei.liu2@citrix.com>
Cc: Ian Campbell <ian.campbell@citrix.com>
---
v3: use napi_complete instead of __napi_complete as it does all necessa=
ry
    work for us.
---
 drivers/net/xen-netback/common.h    |    5 +++++
 drivers/net/xen-netback/interface.c |   11 +++++++++++
 drivers/net/xen-netback/netback.c   |   15 +++++++++++++--
 3 files changed, 29 insertions(+), 2 deletions(-)

diff --git a/drivers/net/xen-netback/common.h b/drivers/net/xen-netback=
/common.h
index ae413a2..4bf5b33 100644
--- a/drivers/net/xen-netback/common.h
+++ b/drivers/net/xen-netback/common.h
@@ -113,6 +113,11 @@ struct xenvif {
 	domid_t          domid;
 	unsigned int     handle;
=20
+	/* Is this interface disabled? True when backend discovers
+	 * frontend is rogue.
+	 */
+	bool disabled;
+
 	/* Use NAPI for guest TX */
 	struct napi_struct napi;
 	/* When feature-split-event-channels =3D 0, tx_irq =3D rx_irq. */
diff --git a/drivers/net/xen-netback/interface.c b/drivers/net/xen-netb=
ack/interface.c
index 301cc03..2e92d52 100644
--- a/drivers/net/xen-netback/interface.c
+++ b/drivers/net/xen-netback/interface.c
@@ -62,6 +62,15 @@ static int xenvif_poll(struct napi_struct *napi, int=
 budget)
 	struct xenvif *vif =3D container_of(napi, struct xenvif, napi);
 	int work_done;
=20
+	/* This vif is rogue, we pretend we've there is nothing to do
+	 * for this vif to deschedule it from NAPI. But this interface
+	 * will be turned off in thread context later.
+	 */
+	if (unlikely(vif->disabled)) {
+		napi_complete(napi);
+		return 0;
+	}
+
 	work_done =3D xenvif_tx_action(vif, budget);
=20
 	if (work_done < budget) {
@@ -321,6 +330,8 @@ struct xenvif *xenvif_alloc(struct device *parent, =
domid_t domid,
 	vif->ip_csum =3D 1;
 	vif->dev =3D dev;
=20
+	vif->disabled =3D false;
+
 	vif->credit_bytes =3D vif->remaining_credit =3D ~0UL;
 	vif->credit_usec  =3D 0UL;
 	init_timer(&vif->credit_timeout);
diff --git a/drivers/net/xen-netback/netback.c b/drivers/net/xen-netbac=
k/netback.c
index cd0bd95..a1c1f2a 100644
--- a/drivers/net/xen-netback/netback.c
+++ b/drivers/net/xen-netback/netback.c
@@ -680,7 +680,8 @@ static void xenvif_tx_err(struct xenvif *vif,
 static void xenvif_fatal_tx_err(struct xenvif *vif)
 {
 	netdev_err(vif->dev, "fatal error; disabling device\n");
-	xenvif_carrier_off(vif);
+	vif->disabled =3D true;
+	xenvif_kick_thread(vif);
 }
=20
 static int xenvif_count_requests(struct xenvif *vif,
@@ -1151,7 +1152,7 @@ static unsigned xenvif_tx_build_gops(struct xenvi=
f *vif, int budget)
 				   vif->tx.sring->req_prod, vif->tx.req_cons,
 				   XEN_NETIF_TX_RING_SIZE);
 			xenvif_fatal_tx_err(vif);
-			continue;
+			break;
 		}
=20
 		work_to_do =3D RING_HAS_UNCONSUMED_REQUESTS(&vif->tx);
@@ -1574,6 +1575,16 @@ int xenvif_kthread(void *data)
 		wait_event_interruptible(vif->wq,
 					 rx_work_todo(vif) ||
 					 kthread_should_stop());
+
+		/* This frontend is found to be rogue, disable it in
+		 * kthread context. Currently this is only set when
+		 * netback finds out frontend sends malformed packet,
+		 * but we cannot disable the interface in softirq
+		 * context so we defer it here.
+		 */
+		if (unlikely(vif->disabled && netif_carrier_ok(vif->dev)))
+			xenvif_carrier_off(vif);
+
 		if (kthread_should_stop())
 			break;
=20
--=20
1.7.10.4
