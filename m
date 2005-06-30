From: Michael Ellerman <michael@ellerman.id.au>
Subject: [PATCH 3/12] iseries_veth: Make init_connection() & destroy_connection() symmetrical
Date: Thu, 30 Jun 2005 20:20:39 +1000
Message-ID: <1120126839.290253.340047065213.qpatch__43723.3042474419$1120126800$gmane$org@concordia>
References: <200506302016.55125.michael@ellerman.id.au>
Return-path: <netdev-bounce@oss.sgi.com>
To: linuxppc64-dev@ozlabs.org, netdev@oss.sgi.com,
        linux-kernel@vger.kernel.org
In-Reply-To: <200506302016.55125.michael@ellerman.id.au>
Sender: netdev-bounce@oss.sgi.com
Errors-to: netdev-bounce@oss.sgi.com
List-Id: netdev.vger.kernel.org

This patch makes veth_init_connection() and veth_destroy_connection()
symmetrical in that they allocate/deallocate the same data.

Currently if there's an error while initialising connections (ie. ENOMEM)
we call veth_module_cleanup(), however this will oops because we call
driver_unregister() before we've called driver_register(). I've never seen
this actually happen though.

So instead we explicitly call veth_destroy_connection() in a reverse
loop for the connections we've successfully initialised.


---

 drivers/net/iseries_veth.c |   22 +++++++++++-----------
 1 files changed, 11 insertions(+), 11 deletions(-)

Index: veth-dev/drivers/net/iseries_veth.c
===================================================================
--- veth-dev.orig/drivers/net/iseries_veth.c
+++ veth-dev/drivers/net/iseries_veth.c
@@ -664,6 +664,14 @@ static void veth_stop_connection(u8 rlp)
 	 * been deleted by the state machine, just want to make sure
 	 * its not running any more */
 	del_timer_sync(&cnx->ack_timer);
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
@@ -675,14 +683,6 @@ static void veth_stop_connection(u8 rlp)
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
@@ -1424,15 +1424,15 @@ module_exit(veth_module_cleanup);
 
 int __init veth_module_init(void)
 {
-	int i;
-	int rc;
+	int i, rc;
 
 	this_lp = HvLpConfig_getLpIndex_outline();
 
 	for (i = 0; i < HVMAXARCHITECTEDLPS; ++i) {
 		rc = veth_init_connection(i);
 		if (rc != 0) {
-			veth_module_cleanup();
+			for (; i >= 0; i--)
+				veth_destroy_connection(i);
 			return rc;
 		}
 	}
