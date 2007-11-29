From: Ursula Braun <braunu@de.ibm.com>
Subject: [patch 1/1] ctc: make use of alloc_netdev()
Date: Thu, 29 Nov 2007 17:36:27 +0100
Message-ID: <20071129163934.296999000@linux.vnet.ibm.com>
References: <20071129163626.573067000@linux.vnet.ibm.com>
Cc: Peter Tiedemann <ptiedem@de.ibm.com>
To: jgarzik@pobox.com, netdev@vger.kernel.org,
	linux-s390@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mtagate2.de.ibm.com ([195.212.29.151]:3945 "EHLO
	mtagate2.de.ibm.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1760142AbXK2Qji (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 29 Nov 2007 11:39:38 -0500
Content-Disposition: inline; filename=ctc.diff
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

From: Peter Tiedemann <ptiedem@de.ibm.com>

Currently ctc-device initialization is broken (kernel bug in
ctc_new_device).
The new network namespace code reveals a deficiency of the
ctc driver. It should make use of alloc_netdev() as described
in Documentation/networking/netdevices.txt.

Signed-off-by: Peter Tiedemann <ptiedem@de.ibm.com>
Signed-off-by: Ursula Braun <braunu@de.ibm.com>
---
 drivers/s390/net/ctcmain.c |   45 ++++++++++++++++-----------------------------
 1 file changed, 16 insertions(+), 29 deletions(-)

Index: linux-2.6-uschi/drivers/s390/net/ctcmain.c
===================================================================
--- linux-2.6-uschi.orig/drivers/s390/net/ctcmain.c
+++ linux-2.6-uschi/drivers/s390/net/ctcmain.c
@@ -2782,35 +2782,14 @@ ctc_probe_device(struct ccwgroup_device 
 }
 
 /**
- * Initialize everything of the net device except the name and the
- * channel structs.
+ * Device setup function called by alloc_netdev().
+ *
+ * @param dev  Device to be setup.
  */
-static struct net_device *
-ctc_init_netdevice(struct net_device * dev, int alloc_device,
-		   struct ctc_priv *privptr)
+void ctc_init_netdevice(struct net_device * dev)
 {
-	if (!privptr)
-		return NULL;
-
 	DBF_TEXT(setup, 3, __FUNCTION__);
 
-	if (alloc_device) {
-		dev = kzalloc(sizeof(struct net_device), GFP_KERNEL);
-		if (!dev)
-			return NULL;
-	}
-
-	dev->priv = privptr;
-	privptr->fsm = init_fsm("ctcdev", dev_state_names,
-				dev_event_names, CTC_NR_DEV_STATES, CTC_NR_DEV_EVENTS,
-				dev_fsm, DEV_FSM_LEN, GFP_KERNEL);
-	if (privptr->fsm == NULL) {
-		if (alloc_device)
-			kfree(dev);
-		return NULL;
-	}
-	fsm_newstate(privptr->fsm, DEV_STATE_STOPPED);
-	fsm_settimer(privptr->fsm, &privptr->restart_timer);
 	if (dev->mtu == 0)
 		dev->mtu = CTC_BUFSIZE_DEFAULT - LL_HEADER_LENGTH - 2;
 	dev->hard_start_xmit = ctc_tx;
@@ -2823,7 +2802,7 @@ ctc_init_netdevice(struct net_device * d
 	dev->type = ARPHRD_SLIP;
 	dev->tx_queue_len = 100;
 	dev->flags = IFF_POINTOPOINT | IFF_NOARP;
-	return dev;
+	SET_MODULE_OWNER(dev);
 }
 
 
@@ -2879,14 +2858,22 @@ ctc_new_device(struct ccwgroup_device *c
 		 	"ccw_device_set_online (cdev[1]) failed with ret = %d\n", ret);
 	}
 
-	dev = ctc_init_netdevice(NULL, 1, privptr);
-
+	dev = alloc_netdev(0, "ctc%d", ctc_init_netdevice);
 	if (!dev) {
 		ctc_pr_warn("ctc_init_netdevice failed\n");
 		goto out;
 	}
+	dev->priv = privptr;
 
-	strlcpy(dev->name, "ctc%d", IFNAMSIZ);
+	privptr->fsm = init_fsm("ctcdev", dev_state_names,
+			dev_event_names, CTC_NR_DEV_STATES, CTC_NR_DEV_EVENTS,
+			dev_fsm, DEV_FSM_LEN, GFP_KERNEL);
+	if (privptr->fsm == NULL) {
+		free_netdev(dev);
+		goto out;
+	}
+	fsm_newstate(privptr->fsm, DEV_STATE_STOPPED);
+	fsm_settimer(privptr->fsm, &privptr->restart_timer);
 
 	for (direction = READ; direction <= WRITE; direction++) {
 		privptr->channel[direction] =

-- 
