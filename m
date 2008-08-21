From: Ursula Braun <ursula.braun@de.ibm.com>
Subject: [patch 1/4] claw: fix memory leak in claw_probe.
Date: Thu, 21 Aug 2008 17:10:22 +0200
Message-ID: <20080821151652.052680000@linux.vnet.ibm.com>
References: <20080821151021.069615000@linux.vnet.ibm.com>
Cc: Daniel <danielm77@spray.se>,
	Martin Schwidefsky <schwidefsky@de.ibm.com>,
	Ursula Braun <ursula.braun@de.ibm.com>
To: jgarzik@pobox.com, netdev@vger.kernel.org,
	linux-s390@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mtagate8.de.ibm.com ([195.212.29.157]:55994 "EHLO
	mtagate8.de.ibm.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1760404AbYHUPRs (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 21 Aug 2008 11:17:48 -0400
Content-Disposition: inline; filename=606-claw-memleak.diff
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Martin Schwidefsky <schwidefsky@de.ibm.com>

probe_error() frees memory only, if cgdev->dev.driver_data refers
to the claw_privbk structure. Move forward its setting in claw_probe()
to ensure proper freeing of claw_privbk allocations.

Cc: Daniel <danielm77@spray.se>
Signed-off-by: Martin Schwidefsky <schwidefsky@de.ibm.com>
Signed-off-by: Ursula Braun <ursula.braun@de.ibm.com>
---

 drivers/s390/net/claw.c |   19 ++++++++-----------
 1 file changed, 8 insertions(+), 11 deletions(-)

Index: linux-2.6-uschi/drivers/s390/net/claw.c
===================================================================
--- linux-2.6-uschi.orig/drivers/s390/net/claw.c
+++ linux-2.6-uschi/drivers/s390/net/claw.c
@@ -271,6 +271,7 @@ claw_probe(struct ccwgroup_device *cgdev
 	if (!get_device(&cgdev->dev))
 		return -ENODEV;
 	privptr = kzalloc(sizeof(struct claw_privbk), GFP_KERNEL);
+	cgdev->dev.driver_data = privptr;
 	if (privptr == NULL) {
 		probe_error(cgdev);
 		put_device(&cgdev->dev);
@@ -305,7 +306,6 @@ claw_probe(struct ccwgroup_device *cgdev
 	privptr->p_env->p_priv = privptr;
         cgdev->cdev[0]->handler = claw_irq_handler;
 	cgdev->cdev[1]->handler = claw_irq_handler;
-	cgdev->dev.driver_data = privptr;
 	CLAW_DBF_TEXT(2, setup, "prbext 0");
 
         return 0;
@@ -1960,19 +1960,16 @@ init_ccw_bk(struct net_device *dev)
 static void
 probe_error( struct ccwgroup_device *cgdev)
 {
-  struct claw_privbk *privptr;
+	struct claw_privbk *privptr;
 
 	CLAW_DBF_TEXT(4, trace, "proberr");
-        privptr=(struct claw_privbk *)cgdev->dev.driver_data;
-	if (privptr!=NULL) {
+	privptr = (struct claw_privbk *) cgdev->dev.driver_data;
+	if (privptr != NULL) {
+		cgdev->dev.driver_data = NULL;
 		kfree(privptr->p_env);
-		privptr->p_env=NULL;
-                kfree(privptr->p_mtc_envelope);
-               	privptr->p_mtc_envelope=NULL;
-                kfree(privptr);
-                privptr=NULL;
-        }
-        return;
+		kfree(privptr->p_mtc_envelope);
+		kfree(privptr);
+	}
 }    /*    probe_error    */
 
 /*-------------------------------------------------------------------*

-- 
