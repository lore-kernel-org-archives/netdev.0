From: akpm@linux-foundation.org
Subject: [patch 15/15] use mutex instead of binary semaphore in FORE Systems 200E-series driver for ATM
Date: Thu, 26 Apr 2007 00:27:37 -0700
Message-ID: <200704260727.l3Q7RbJ0023993@shell0.pdx.osdl.net>
Cc: netdev@vger.kernel.org, akpm@linux-foundation.org,
	matthias.kaehlcke@gmail.com
To: davem@davemloft.net
Return-path: <netdev-owner@vger.kernel.org>
Received: from smtp1.linux-foundation.org ([65.172.181.25]:33887 "EHLO
	smtp1.linux-foundation.org" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with ESMTP id S933580AbXDZH7S (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 26 Apr 2007 03:59:18 -0400
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

From: Matthias Kaehlcke <matthias.kaehlcke@gmail.com>

(akpm: remove CVS control string too)

Signed-off-by: Matthias Kaehlcke <matthias.kaehlcke@gmail.com>
Signed-off-by: Andrew Morton <akpm@linux-foundation.org>
---

 drivers/atm/fore200e.c |   20 +++++++++-----------
 drivers/atm/fore200e.h |    2 +-
 2 files changed, 10 insertions(+), 12 deletions(-)

diff -puN drivers/atm/fore200e.c~use-mutex-instead-of-binary-semaphore-in-fore-systems-200e-series-driver-for-atm drivers/atm/fore200e.c
--- a/drivers/atm/fore200e.c~use-mutex-instead-of-binary-semaphore-in-fore-systems-200e-series-driver-for-atm
+++ a/drivers/atm/fore200e.c
@@ -1,6 +1,4 @@
 /*
-  $Id: fore200e.c,v 1.5 2000/04/14 10:10:34 davem Exp $
-
   A FORE Systems 200E-series driver for ATM on Linux.
   Christophe Lizzi (lizzi@cnam.fr), October 1999-March 2003.
 
@@ -1502,9 +1500,9 @@ fore200e_open(struct atm_vcc *vcc)
     /* pseudo-CBR bandwidth requested? */
     if ((vcc->qos.txtp.traffic_class == ATM_CBR) && (vcc->qos.txtp.max_pcr > 0)) {
 	
-	down(&fore200e->rate_sf);
+	mutex_lock(&fore200e->rate_mtx);
 	if (fore200e->available_cell_rate < vcc->qos.txtp.max_pcr) {
-	    up(&fore200e->rate_sf);
+	    mutex_unlock(&fore200e->rate_mtx);
 
 	    kfree(fore200e_vcc);
 	    vc_map->vcc = NULL;
@@ -1513,7 +1511,7 @@ fore200e_open(struct atm_vcc *vcc)
 
 	/* reserve bandwidth */
 	fore200e->available_cell_rate -= vcc->qos.txtp.max_pcr;
-	up(&fore200e->rate_sf);
+	mutex_unlock(&fore200e->rate_mtx);
     }
     
     vcc->itf = vcc->dev->number;
@@ -1599,9 +1597,9 @@ fore200e_close(struct atm_vcc* vcc)
     /* release reserved bandwidth, if any */
     if ((vcc->qos.txtp.traffic_class == ATM_CBR) && (vcc->qos.txtp.max_pcr > 0)) {
 
-	down(&fore200e->rate_sf);
+	mutex_lock(&fore200e->rate_mtx);
 	fore200e->available_cell_rate += vcc->qos.txtp.max_pcr;
-	up(&fore200e->rate_sf);
+	mutex_unlock(&fore200e->rate_mtx);
 
 	clear_bit(ATM_VF_HASQOS, &vcc->flags);
     }
@@ -2064,16 +2062,16 @@ fore200e_change_qos(struct atm_vcc* vcc,
 
     if ((qos->txtp.traffic_class == ATM_CBR) && (qos->txtp.max_pcr > 0)) {
 
-	down(&fore200e->rate_sf);
+	mutex_lock(&fore200e->rate_mtx);
 	if (fore200e->available_cell_rate + vcc->qos.txtp.max_pcr < qos->txtp.max_pcr) {
-	    up(&fore200e->rate_sf);
+	    mutex_unlock(&fore200e->rate_mtx);
 	    return -EAGAIN;
 	}
 
 	fore200e->available_cell_rate += vcc->qos.txtp.max_pcr;
 	fore200e->available_cell_rate -= qos->txtp.max_pcr;
 
-	up(&fore200e->rate_sf);
+	mutex_unlock(&fore200e->rate_mtx);
 	
 	memcpy(&vcc->qos, qos, sizeof(struct atm_qos));
 	
@@ -2459,7 +2457,7 @@ fore200e_initialize(struct fore200e* for
 
     DPRINTK(2, "device %s being initialized\n", fore200e->name);
 
-    init_MUTEX(&fore200e->rate_sf);
+    mutex_init(&fore200e->rate_mtx);
     spin_lock_init(&fore200e->q_lock);
 
     cpq = fore200e->cp_queues = fore200e->virt_base + FORE200E_CP_QUEUES_OFFSET;
diff -puN drivers/atm/fore200e.h~use-mutex-instead-of-binary-semaphore-in-fore-systems-200e-series-driver-for-atm drivers/atm/fore200e.h
--- a/drivers/atm/fore200e.h~use-mutex-instead-of-binary-semaphore-in-fore-systems-200e-series-driver-for-atm
+++ a/drivers/atm/fore200e.h
@@ -869,7 +869,7 @@ typedef struct fore200e {
 
     struct stats*              stats;                  /* last snapshot of the stats         */
     
-    struct semaphore           rate_sf;                /* protects rate reservation ops      */
+    struct mutex               rate_mtx;               /* protects rate reservation ops      */
     spinlock_t                 q_lock;                 /* protects queue ops                 */
 #ifdef FORE200E_USE_TASKLET
     struct tasklet_struct      tx_tasklet;             /* performs tx interrupt work         */
_
