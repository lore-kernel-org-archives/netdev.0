From: Sebastian Siewior <bigeasy@linutronix.de>
Subject: [PATCH 3/5] m68knommu: fec typedef a function
Date: Wed, 02 Apr 2008 22:58:29 +0200
Message-ID: <20080402210103.987045815@linutronix.de>
References: <20080402204417.597098190@linutronix.de>
Cc: Jeff Garzik <jgarzik@pobox.com>, netdev@vger.kernel.org,
	uclinux-dev@uclinux.org
To: Greg Ungerer <gerg@uclinux.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from Chamillionaire.breakpoint.cc ([85.10.199.196]:58657 "EHLO
	Chamillionaire.breakpoint.cc" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with ESMTP id S1754351AbYDBU6e (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 2 Apr 2008 16:58:34 -0400
Content-Disposition: inline; filename=m68knommu-fec-typedef_mii_func.diff
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Make a typedef for a function that is refered as a function pointer.
Also move the conditial call of the callback function in fec_enet_mii()
of the area that is protected with spinlock beacause the callbacked
function might grab the same lock.

Signed-off-by: Sebastian Siewior <bigeasy@linutronix.de>
--- a/drivers/net/fec.c
+++ b/drivers/net/fec.c
@@ -116,10 +116,10 @@ static unsigned char fec_mac_default[] =
 
 /* Forward declarations of some structures to support different PHYs
 */
-
+typedef void (mii_func)(uint val, struct net_device *dev);
 typedef struct {
 	uint mii_data;
-	void (*funct)(uint mii_reg, struct net_device *dev);
+	mii_func *funct;
 } phy_cmd_t;
 
 typedef struct {
@@ -258,8 +258,7 @@ static mii_list_t *mii_free;
 static mii_list_t *mii_head;
 static mii_list_t *mii_tail;
 
-static int mii_queue(struct net_device *dev, int request,
-		     void (*func) (uint, struct net_device *));
+static int mii_queue(struct net_device *dev, int request, mii_func *funct);
 
 /* Make MII read/write commands for the FEC.
 */
@@ -693,6 +692,7 @@ static void fec_enet_mii(struct net_devi
 	volatile fec_t *ep;
 	mii_list_t *mip;
 	uint mii_reg;
+	mii_func *mii_func = NULL;
 
 	fep = netdev_priv(dev);
 	ep = fep->hwp;
@@ -706,7 +706,7 @@ static void fec_enet_mii(struct net_devi
 	}
 
 	if (mip->mii_func != NULL)
-		(*(mip->mii_func)) (mii_reg, dev);
+		mii_func = *(mip->mii_func);
 
 	mii_head = mip->mii_next;
 	mip->mii_next = mii_free;
@@ -717,11 +717,11 @@ static void fec_enet_mii(struct net_devi
 
 unlock:
 	spin_unlock(&fep->lock);
+	if (mii_func)
+		mii_func(mii_reg, dev);
 }
 
-static int
-mii_queue(struct net_device *dev, int regval,
-	  void (*func) (uint, struct net_device *))
+static int mii_queue(struct net_device *dev, int regval, mii_func *func)
 {
 	struct fec_enet_private *fep;
 	unsigned long flags;

-- 

