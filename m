From: Michael Ellerman <michael@ellerman.id.au>
Subject: [PATCH 8/18] iseries_veth: Make init_connection() &
	destroy_connection() symmetrical
Date: Thu,  1 Sep 2005 11:29:08 +1000 (EST)
Message-ID: <20050901012908.E24DF68212@ozlabs.org>
References: <1125538127.859382.875909607846.qpush@concordia>
Cc: netdev@vger.kernel.org, linux-kernel@vger.kernel.org,
	linuxppc64-dev@ozlabs.org
Return-path: <linuxppc64-dev-bounces@ozlabs.org>
To: <jgarzik@pobox.com>
In-Reply-To: <1125538127.859382.875909607846.qpush@concordia>
List-Unsubscribe: <https://ozlabs.org/mailman/listinfo/linuxppc64-dev>,
	<mailto:linuxppc64-dev-request@ozlabs.org?subject=unsubscribe>
List-Archive: <http://ozlabs.org/pipermail/linuxppc64-dev>
List-Post: <mailto:linuxppc64-dev@ozlabs.org>
List-Help: <mailto:linuxppc64-dev-request@ozlabs.org?subject=help>
List-Subscribe: <https://ozlabs.org/mailman/listinfo/linuxppc64-dev>,
	<mailto:linuxppc64-dev-request@ozlabs.org?subject=subscribe>
Sender: linuxppc64-dev-bounces@ozlabs.org
Errors-To: linuxppc64-dev-bounces@ozlabs.org
List-Id: netdev.vger.kernel.org

This patch makes veth_init_connection() and veth_destroy_connection()
symmetrical in that they allocate/deallocate the same data.

Currently if there's an error while initialising connections (ie. ENOMEM)
we call veth_module_cleanup(), however this will oops because we call
driver_unregister() before we've called driver_register(). I've never seen
this actually happen though.

So instead we explicitly call veth_destroy_connection() for each connection,
any that have been set up will be deallocated.

We also fix a potential leak if vio_register_driver() fails.

Signed-off-by: Michael Ellerman <michael@ellerman.id.au>
---

 drivers/net/iseries_veth.c |   35 ++++++++++++++++++++++-------------
 1 files changed, 22 insertions(+), 13 deletions(-)

Index: veth-dev2/drivers/net/iseries_veth.c
===================================================================
--- veth-dev2.orig/drivers/net/iseries_veth.c
+++ veth-dev2/drivers/net/iseries_veth.c
@@ -683,6 +683,14 @@ static void veth_stop_connection(u8 rlp)
 
 	/* Wait for the state machine to run. */
 	flush_scheduled_work();
+}
+
+static void veth_destroy_connection(u8 rlp)
+{
+	struct veth_lpar_connection *cnx = veth_cnx[rlp];
+
+	if (! cnx)
+		return;
 
 	if (cnx->num_events > 0)
 		mf_deallocate_lp_events(cnx->remote_lp,
@@ -694,14 +702,6 @@ static void veth_stop_connection(u8 rlp)
 				      HvLpEvent_Type_VirtualLan,
 				      cnx->num_ack_events,
 				      NULL, NULL);
-}
-
-static void veth_destroy_connection(u8 rlp)
-{
-	struct veth_lpar_connection *cnx = veth_cnx[rlp];
-
-	if (! cnx)
-		return;
 
 	kfree(cnx->msgs);
 	kfree(cnx);
@@ -1441,15 +1441,24 @@ int __init veth_module_init(void)
 
 	for (i = 0; i < HVMAXARCHITECTEDLPS; ++i) {
 		rc = veth_init_connection(i);
-		if (rc != 0) {
-			veth_module_cleanup();
-			return rc;
-		}
+		if (rc != 0)
+			goto error;
 	}
 
 	HvLpEvent_registerHandler(HvLpEvent_Type_VirtualLan,
 				  &veth_handle_event);
 
-	return vio_register_driver(&veth_driver);
+	rc = vio_register_driver(&veth_driver);
+	if (rc != 0)
+		goto error;
+
+	return 0;
+
+error:
+	for (i = 0; i < HVMAXARCHITECTEDLPS; ++i) {
+		veth_destroy_connection(i);
+	}
+
+	return rc;
 }
 module_init(veth_module_init);
