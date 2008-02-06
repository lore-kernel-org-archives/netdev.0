From: urs.thuermann@gmx.de
Subject: [patch 2/3] CAN: Move proto_{,un}register() out of spin-locked region
Date: Wed,  6 Feb 2008 23:07:51 +0100
Message-ID: <20080206220826.20500.2@janus.isnogud.escape.de>
References: <20080206220749.20500.0@janus.isnogud.escape.de>
Cc: Urs Thuermann <urs.thuermann@volkswagen.de>,
	Oliver Hartkopp <oliver.hartkopp@volkswagen.de>,
	Oliver Hartkopp <oliver@hartkopp.net>
To: David Miller <davem@davemloft.net>, netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from oker.escape.de ([194.120.234.254]:54363 "EHLO oker.escape.de"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1760954AbYBFXH0 (ORCPT <rfc822;netdev@vger.kernel.org>);
	Wed, 6 Feb 2008 18:07:26 -0500
Content-Disposition: inline; filename=proto_register
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

The implementation of proto_register() has changed so that it can now
sleep.  The call to proto_register() must be moved out of the
spin-locked region.

Signed-off-by: Urs Thuermann <urs.thuermann@volkswagen.de>
Signed-off-by: Oliver Hartkopp <oliver.hartkopp@volkswagen.de>

---
 net/can/af_can.c |   27 ++++++++++++++-------------
 1 file changed, 14 insertions(+), 13 deletions(-)

Index: net-2.6/net/can/af_can.c
===================================================================
--- net-2.6.orig/net/can/af_can.c	2008-02-06 22:20:46.000000000 +0100
+++ net-2.6/net/can/af_can.c	2008-02-06 22:22:51.000000000 +0100
@@ -656,26 +656,26 @@
 		return -EINVAL;
 	}
 
+	err = proto_register(cp->prot, 0);
+	if (err < 0)
+		return err;
+
 	spin_lock(&proto_tab_lock);
 	if (proto_tab[proto]) {
 		printk(KERN_ERR "can: protocol %d already registered\n",
 		       proto);
 		err = -EBUSY;
-		goto errout;
+	} else {
+		proto_tab[proto] = cp;
+
+		/* use generic ioctl function if not defined by module */
+		if (!cp->ops->ioctl)
+			cp->ops->ioctl = can_ioctl;
 	}
+	spin_unlock(&proto_tab_lock);
 
-	err = proto_register(cp->prot, 0);
 	if (err < 0)
-		goto errout;
-
-	proto_tab[proto] = cp;
-
-	/* use generic ioctl function if the module doesn't bring its own */
-	if (!cp->ops->ioctl)
-		cp->ops->ioctl = can_ioctl;
-
- errout:
-	spin_unlock(&proto_tab_lock);
+		proto_unregister(cp->prot);
 
 	return err;
 }
@@ -694,9 +694,10 @@
 		printk(KERN_ERR "BUG: can: protocol %d is not registered\n",
 		       proto);
 	}
-	proto_unregister(cp->prot);
 	proto_tab[proto] = NULL;
 	spin_unlock(&proto_tab_lock);
+
+	proto_unregister(cp->prot);
 }
 EXPORT_SYMBOL(can_proto_unregister);
 

--
