From: akpm@linux-foundation.org
Subject: [patch 1/8] use mutex instead of binary semaphore in idt77252 driver
Date: Thu, 10 May 2007 22:53:42 -0700
Message-ID: <200705110553.l4B5rg6B007847@shell0.pdx.osdl.net>
Cc: netdev@vger.kernel.org, akpm@linux-foundation.org,
	matthias.kaehlcke@gmail.com, chas@cmf.nrl.navy.mil
To: davem@davemloft.net
Return-path: <netdev-owner@vger.kernel.org>
Received: from smtp1.linux-foundation.org ([65.172.181.25]:43432 "EHLO
	smtp1.linux-foundation.org" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with ESMTP id S1758334AbXEKFyg (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 11 May 2007 01:54:36 -0400
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

From: Matthias Kaehlcke <matthias.kaehlcke@gmail.com>

Use mutex instead of binary semaphore in idt77252 driver.

Signed-off-by: Matthias Kaehlcke <matthias.kaehlcke@gmail.com>
Cc: chas williams <chas@cmf.nrl.navy.mil>
Signed-off-by: Andrew Morton <akpm@linux-foundation.org>
---

 drivers/atm/idt77252.c |   27 ++++++++++++++-------------
 drivers/atm/idt77252.h |    4 ++--
 2 files changed, 16 insertions(+), 15 deletions(-)

diff -puN drivers/atm/idt77252.c~use-mutex-instead-of-binary-semaphore-in-idt77252-driver drivers/atm/idt77252.c
--- a/drivers/atm/idt77252.c~use-mutex-instead-of-binary-semaphore-in-idt77252-driver
+++ a/drivers/atm/idt77252.c
@@ -47,7 +47,8 @@ static char const rcsid[] =
 #include <linux/bitops.h>
 #include <linux/wait.h>
 #include <linux/jiffies.h>
-#include <asm/semaphore.h>
+#include <linux/mutex.h>
+
 #include <asm/io.h>
 #include <asm/uaccess.h>
 #include <asm/atomic.h>
@@ -2435,7 +2436,7 @@ idt77252_open(struct atm_vcc *vcc)
 
 	set_bit(ATM_VF_ADDR, &vcc->flags);
 
-	down(&card->mutex);
+	mutex_lock(&card->mutex);
 
 	OPRINTK("%s: opening vpi.vci: %d.%d\n", card->name, vpi, vci);
 
@@ -2446,7 +2447,7 @@ idt77252_open(struct atm_vcc *vcc)
 		break;
 	default:
 		printk("%s: Unsupported AAL: %d\n", card->name, vcc->qos.aal);
-		up(&card->mutex);
+		mutex_unlock(&card->mutex);
 		return -EPROTONOSUPPORT;
 	}
 
@@ -2455,7 +2456,7 @@ idt77252_open(struct atm_vcc *vcc)
 		card->vcs[index] = kzalloc(sizeof(struct vc_map), GFP_KERNEL);
 		if (!card->vcs[index]) {
 			printk("%s: can't alloc vc in open()\n", card->name);
-			up(&card->mutex);
+			mutex_unlock(&card->mutex);
 			return -ENOMEM;
 		}
 		card->vcs[index]->card = card;
@@ -2484,14 +2485,14 @@ idt77252_open(struct atm_vcc *vcc)
 	if (inuse) {
 		printk("%s: %s vci already in use.\n", card->name,
 		       inuse == 1 ? "tx" : inuse == 2 ? "rx" : "tx and rx");
-		up(&card->mutex);
+		mutex_unlock(&card->mutex);
 		return -EADDRINUSE;
 	}
 
 	if (vcc->qos.txtp.traffic_class != ATM_NONE) {
 		error = idt77252_init_tx(card, vc, vcc, &vcc->qos);
 		if (error) {
-			up(&card->mutex);
+			mutex_unlock(&card->mutex);
 			return error;
 		}
 	}
@@ -2499,14 +2500,14 @@ idt77252_open(struct atm_vcc *vcc)
 	if (vcc->qos.rxtp.traffic_class != ATM_NONE) {
 		error = idt77252_init_rx(card, vc, vcc, &vcc->qos);
 		if (error) {
-			up(&card->mutex);
+			mutex_unlock(&card->mutex);
 			return error;
 		}
 	}
 
 	set_bit(ATM_VF_READY, &vcc->flags);
 
-	up(&card->mutex);
+	mutex_unlock(&card->mutex);
 	return 0;
 }
 
@@ -2520,7 +2521,7 @@ idt77252_close(struct atm_vcc *vcc)
 	unsigned long addr;
 	unsigned long timeout;
 
-	down(&card->mutex);
+	mutex_lock(&card->mutex);
 
 	IPRINTK("%s: idt77252_close: vc = %d (%d.%d)\n",
 		card->name, vc->index, vcc->vpi, vcc->vci);
@@ -2591,7 +2592,7 @@ done:
 		free_scq(card, vc->scq);
 	}
 
-	up(&card->mutex);
+	mutex_unlock(&card->mutex);
 }
 
 static int
@@ -2602,7 +2603,7 @@ idt77252_change_qos(struct atm_vcc *vcc,
 	struct vc_map *vc = vcc->dev_data;
 	int error = 0;
 
-	down(&card->mutex);
+	mutex_lock(&card->mutex);
 
 	if (qos->txtp.traffic_class != ATM_NONE) {
 	    	if (!test_bit(VCF_TX, &vc->flags)) {
@@ -2648,7 +2649,7 @@ idt77252_change_qos(struct atm_vcc *vcc,
 	set_bit(ATM_VF_HASQOS, &vcc->flags);
 
 out:
-	up(&card->mutex);
+	mutex_unlock(&card->mutex);
 	return error;
 }
 
@@ -3709,7 +3710,7 @@ idt77252_init_one(struct pci_dev *pcidev
 	membase = pci_resource_start(pcidev, 1);
 	srambase = pci_resource_start(pcidev, 2);
 
-	init_MUTEX(&card->mutex);
+	mutex_init(&card->mutex);
 	spin_lock_init(&card->cmd_lock);
 	spin_lock_init(&card->tst_lock);
 
diff -puN drivers/atm/idt77252.h~use-mutex-instead-of-binary-semaphore-in-idt77252-driver drivers/atm/idt77252.h
--- a/drivers/atm/idt77252.h~use-mutex-instead-of-binary-semaphore-in-idt77252-driver
+++ a/drivers/atm/idt77252.h
@@ -37,7 +37,7 @@
 #include <linux/ptrace.h>
 #include <linux/skbuff.h>
 #include <linux/workqueue.h>
-
+#include <linux/mutex.h>
 
 /*****************************************************************************/
 /*                                                                           */
@@ -359,7 +359,7 @@ struct idt77252_dev
 	unsigned long		srambase;	/* SAR's sram  base address */
 	void __iomem		*fbq[4];	/* FBQ fill addresses */
 
-	struct semaphore	mutex;
+	struct mutex		mutex;
 	spinlock_t		cmd_lock;	/* for r/w utility/sram */
 
 	unsigned long		softstat;
_
