From: Michael Ellerman <michael@ellerman.id.au>
Subject: [PATCH 9/18] iseries_veth: Use kobjects to track lifecycle of
	connection structs
Date: Thu,  1 Sep 2005 11:29:09 +1000 (EST)
Message-ID: <20050901012909.C98036820F@ozlabs.org>
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

The iseries_veth driver can attach to multiple vlans, which correspond to
multiple net devices. However there is only 1 connection between each LPAR,
so the connection structure may be shared by multiple net devices.

This makes module removal messy, because we can't deallocate the connections
until we know there are no net devices still using them. The solution is to
use ref counts on the connections, so we can delete them (actually stop) as
soon as the ref count hits zero.

This patch fixes (part of) a bug we were seeing with IPv6 sending probes to
a dead LPAR, which would then hang us forever due to leftover skbs.

Signed-off-by: Michael Ellerman <michael@ellerman.id.au>
---

 drivers/net/iseries_veth.c |  121 ++++++++++++++++++++++++++++++---------------
 1 files changed, 83 insertions(+), 38 deletions(-)

Index: veth-dev2/drivers/net/iseries_veth.c
===================================================================
--- veth-dev2.orig/drivers/net/iseries_veth.c
+++ veth-dev2/drivers/net/iseries_veth.c
@@ -129,6 +129,7 @@ struct veth_lpar_connection {
 	int num_events;
 	struct VethCapData local_caps;
 
+	struct kobject kobject;
 	struct timer_list ack_timer;
 
 	spinlock_t lock;
@@ -171,6 +172,11 @@ static void veth_recycle_msg(struct veth
 static void veth_flush_pending(struct veth_lpar_connection *cnx);
 static void veth_receive(struct veth_lpar_connection *, struct VethLpEvent *);
 static void veth_timed_ack(unsigned long connectionPtr);
+static void veth_release_connection(struct kobject *kobject);
+
+static struct kobj_type veth_lpar_connection_ktype = {
+	.release	= veth_release_connection
+};
 
 /*
  * Utility functions
@@ -611,7 +617,7 @@ static int veth_init_connection(u8 rlp)
 {
 	struct veth_lpar_connection *cnx;
 	struct veth_msg *msgs;
-	int i;
+	int i, rc;
 
 	if ( (rlp == this_lp)
 	     || ! HvLpConfig_doLpsCommunicateOnVirtualLan(this_lp, rlp) )
@@ -632,6 +638,14 @@ static int veth_init_connection(u8 rlp)
 
 	veth_cnx[rlp] = cnx;
 
+	/* This gets us 1 reference, which is held on behalf of the driver
+	 * infrastructure. It's released at module unload. */
+	kobject_init(&cnx->kobject);
+	cnx->kobject.ktype = &veth_lpar_connection_ktype;
+	rc = kobject_set_name(&cnx->kobject, "cnx%.2d", rlp);
+	if (rc != 0)
+		return rc;
+
 	msgs = kmalloc(VETH_NUMBUFFERS * sizeof(struct veth_msg), GFP_KERNEL);
 	if (! msgs) {
 		veth_error("Can't allocate buffers for LPAR %d.\n", rlp);
@@ -660,11 +674,9 @@ static int veth_init_connection(u8 rlp)
 	return 0;
 }
 
-static void veth_stop_connection(u8 rlp)
+static void veth_stop_connection(struct veth_lpar_connection *cnx)
 {
-	struct veth_lpar_connection *cnx = veth_cnx[rlp];
-
-	if (! cnx)
+	if (!cnx)
 		return;
 
 	spin_lock_irq(&cnx->lock);
@@ -685,11 +697,9 @@ static void veth_stop_connection(u8 rlp)
 	flush_scheduled_work();
 }
 
-static void veth_destroy_connection(u8 rlp)
+static void veth_destroy_connection(struct veth_lpar_connection *cnx)
 {
-	struct veth_lpar_connection *cnx = veth_cnx[rlp];
-
-	if (! cnx)
+	if (!cnx)
 		return;
 
 	if (cnx->num_events > 0)
@@ -704,8 +714,16 @@ static void veth_destroy_connection(u8 r
 				      NULL, NULL);
 
 	kfree(cnx->msgs);
+	veth_cnx[cnx->remote_lp] = NULL;
 	kfree(cnx);
-	veth_cnx[rlp] = NULL;
+}
+
+static void veth_release_connection(struct kobject *kobj)
+{
+	struct veth_lpar_connection *cnx;
+	cnx = container_of(kobj, struct veth_lpar_connection, kobject);
+	veth_stop_connection(cnx);
+	veth_destroy_connection(cnx);
 }
 
 /*
@@ -1349,15 +1367,31 @@ static void veth_timed_ack(unsigned long
 
 static int veth_remove(struct vio_dev *vdev)
 {
-	int i = vdev->unit_address;
+	struct veth_lpar_connection *cnx;
 	struct net_device *dev;
+	struct veth_port *port;
+	int i;
 
-	dev = veth_dev[i];
-	if (dev != NULL) {
-		veth_dev[i] = NULL;
-		unregister_netdev(dev);
-		free_netdev(dev);
+	dev = veth_dev[vdev->unit_address];
+
+	if (! dev)
+		return 0;
+
+	port = netdev_priv(dev);
+
+	for (i = 0; i < HVMAXARCHITECTEDLPS; i++) {
+		cnx = veth_cnx[i];
+
+		if (cnx && (port->lpar_map & (1 << i))) {
+			/* Drop our reference to connections on our VLAN */
+			kobject_put(&cnx->kobject);
+		}
 	}
+
+	veth_dev[vdev->unit_address] = NULL;
+	unregister_netdev(dev);
+	free_netdev(dev);
+
 	return 0;
 }
 
@@ -1365,6 +1399,7 @@ static int veth_probe(struct vio_dev *vd
 {
 	int i = vdev->unit_address;
 	struct net_device *dev;
+	struct veth_port *port;
 
 	dev = veth_probe_one(i, &vdev->dev);
 	if (dev == NULL) {
@@ -1373,11 +1408,23 @@ static int veth_probe(struct vio_dev *vd
 	}
 	veth_dev[i] = dev;
 
-	/* Start the state machine on each connection, to commence
-	 * link negotiation */
-	for (i = 0; i < HVMAXARCHITECTEDLPS; i++)
-		if (veth_cnx[i])
-			veth_kick_statemachine(veth_cnx[i]);
+	port = (struct veth_port*)netdev_priv(dev);
+
+	/* Start the state machine on each connection on this vlan. If we're
+	 * the first dev to do so this will commence link negotiation */
+	for (i = 0; i < HVMAXARCHITECTEDLPS; i++) {
+		struct veth_lpar_connection *cnx;
+
+		if (! (port->lpar_map & (1 << i)))
+			continue;
+
+		cnx = veth_cnx[i];
+		if (!cnx)
+			continue;
+
+		kobject_get(&cnx->kobject);
+		veth_kick_statemachine(cnx);
+	}
 
 	return 0;
 }
@@ -1406,29 +1453,27 @@ static struct vio_driver veth_driver = {
 void __exit veth_module_cleanup(void)
 {
 	int i;
+	struct veth_lpar_connection *cnx;
 
-	/* Stop the queues first to stop any new packets being sent. */
-	for (i = 0; i < HVMAXARCHITECTEDVIRTUALLANS; i++)
-		if (veth_dev[i])
-			netif_stop_queue(veth_dev[i]);
-
-	/* Stop the connections before we unregister the driver. This
-	 * ensures there's no skbs lying around holding the device open. */
-	for (i = 0; i < HVMAXARCHITECTEDLPS; ++i)
-		veth_stop_connection(i);
-
+	/* Disconnect our "irq" to stop events coming from the Hypervisor. */
 	HvLpEvent_unregisterHandler(HvLpEvent_Type_VirtualLan);
 
-	/* Hypervisor callbacks may have scheduled more work while we
-	 * were stoping connections. Now that we've disconnected from
-	 * the hypervisor make sure everything's finished. */
+	/* Make sure any work queued from Hypervisor callbacks is finished. */
 	flush_scheduled_work();
 
-	vio_unregister_driver(&veth_driver);
+	for (i = 0; i < HVMAXARCHITECTEDLPS; ++i) {
+		cnx = veth_cnx[i];
+
+		if (!cnx)
+			continue;
 
-	for (i = 0; i < HVMAXARCHITECTEDLPS; ++i)
-		veth_destroy_connection(i);
+		/* Drop the driver's reference to the connection */
+		kobject_put(&cnx->kobject);
+	}
 
+	/* Unregister the driver, which will close all the netdevs and stop
+	 * the connections when they're no longer referenced. */
+	vio_unregister_driver(&veth_driver);
 }
 module_exit(veth_module_cleanup);
 
@@ -1456,7 +1501,7 @@ int __init veth_module_init(void)
 
 error:
 	for (i = 0; i < HVMAXARCHITECTEDLPS; ++i) {
-		veth_destroy_connection(i);
+		veth_destroy_connection(veth_cnx[i]);
 	}
 
 	return rc;
