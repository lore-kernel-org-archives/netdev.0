From: margitsw@t-online.de (Margit Schubert-While)
Subject: [PATCH 4/4 linux-2.6.9-rc3/linux-2.4.28-pre3]
	prism54 bug initialization/mgt_commit
Date: Sat, 2 Oct 2004 16:48:17 +0200
Sender: prism54-devel-bounces@prism54.org
Message-ID: <200410021648.17552.margitsw@t-online.de>
Mime-Version: 1.0
Content-Type: Multipart/Mixed;
  boundary="Boundary-00=_x+rXBVB5F4FxvYp"
Cc: netdev@oss.sgi.com, prism54-devel@prism54.org
Return-path: <prism54-devel-bounces@prism54.org>
To: jgarzik@pobox.com
List-Unsubscribe: <http://prism54.org/mailman/listinfo/prism54-devel>,
	<mailto:prism54-devel-request@prism54.org?subject=unsubscribe>
List-Archive: <http://mcgrof.com/pipermail/prism54-devel>
List-Post: <mailto:prism54-devel@prism54.org>
List-Help: <mailto:prism54-devel-request@prism54.org?subject=help>
List-Subscribe: <http://prism54.org/mailman/listinfo/prism54-devel>,
	<mailto:prism54-devel-request@prism54.org?subject=subscribe>
Errors-To: prism54-devel-bounces@prism54.org
List-Id: netdev.vger.kernel.org


--Boundary-00=_x+rXBVB5F4FxvYp
Content-Type: text/plain;
  charset="us-ascii"
Content-Transfer-Encoding: 7bit
Content-Disposition: inline

2004-10-02 Margit Schubert-While <margitsw@t-online.de>

* 04_mgtcommit.patch
*  Change mgt_commit from void to int
*  (and pass a return code)
*  We call this from device initialization,
*  therefore we need to know that it has succeeded
*  If it hasn't, we do not have a working device and
*  should pass a non-zero value upwards

Margit

















--Boundary-00=_x+rXBVB5F4FxvYp
Content-Type: text/x-diff;
  charset="us-ascii";
  name="04_mgtcommit.patch"
Content-Transfer-Encoding: 7bit
Content-Disposition: attachment;
	filename="04_mgtcommit.patch"

diff -Naur linux-2.6.9rc2/drivers/net/wireless/prism54/isl_ioctl.c linux-2.6.9-rc2msw/drivers/net/wireless/prism54/isl_ioctl.c
--- linux-2.6.9rc2/drivers/net/wireless/prism54/isl_ioctl.c	2004-10-02 12:23:39.000000000 +0200
+++ linux-2.6.9-rc2msw/drivers/net/wireless/prism54/isl_ioctl.c	2004-10-02 15:09:25.000000000 +0200
@@ -340,7 +340,10 @@
 
 	mgt_set(priv, DOT11_OID_MLMEAUTOLEVEL, &mlmeautolevel);
 
-	mgt_commit(priv);
+	if (mgt_commit(priv)) {
+		up_write(&priv->mib_sem);
+		return -EIO;
+	}
 	priv->ndev->type = (priv->iw_mode == IW_MODE_MONITOR)
 	    ? priv->monitor_type : ARPHRD_ETHER;
 	up_write(&priv->mib_sem);
@@ -1401,7 +1404,10 @@
 		mlmeautolevel = DOT11_MLME_EXTENDED;
 	mgt_set(priv, DOT11_OID_MLMEAUTOLEVEL, &mlmeautolevel);
 	/* restart the card with our new policy */
-	mgt_commit(priv);
+	if (mgt_commit(priv)) {
+		up_write(&priv->mib_sem);
+		return -EIO;
+	}
 	up_write(&priv->mib_sem);
 
 	return 0;
diff -Naur linux-2.6.9rc2/drivers/net/wireless/prism54/islpci_dev.c linux-2.6.9-rc2msw/drivers/net/wireless/prism54/islpci_dev.c
--- linux-2.6.9rc2/drivers/net/wireless/prism54/islpci_dev.c	2004-10-02 12:31:55.000000000 +0200
+++ linux-2.6.9-rc2msw/drivers/net/wireless/prism54/islpci_dev.c	2004-10-02 15:04:56.000000000 +0200
@@ -522,7 +522,12 @@
 	isl38xx_enable_common_interrupts(priv->device_base);
 
 	down_write(&priv->mib_sem);
-	mgt_commit(priv);
+	result = mgt_commit(priv);
+	if (result) {
+		printk(KERN_ERR "%s: interface reset failure\n", priv->ndev->name);
+		up_write(&priv->mib_sem);
+		return result;
+	}
 	up_write(&priv->mib_sem);
 
 	islpci_set_state(priv, PRV_STATE_READY);
diff -Naur linux-2.6.9rc2/drivers/net/wireless/prism54/oid_mgt.c linux-2.6.9-rc2msw/drivers/net/wireless/prism54/oid_mgt.c
--- linux-2.6.9rc2/drivers/net/wireless/prism54/oid_mgt.c	2004-10-02 12:23:40.000000000 +0200
+++ linux-2.6.9-rc2msw/drivers/net/wireless/prism54/oid_mgt.c	2004-10-02 15:01:21.000000000 +0200
@@ -697,14 +697,14 @@
 
 #define VEC_SIZE(a) (sizeof(a)/sizeof(a[0]))
 
-void
+int
 mgt_commit(islpci_private *priv)
 {
 	int rvalue;
 	u32 u;
 
 	if (islpci_get_state(priv) < PRV_STATE_INIT)
-		return;
+		return 0;
 
 	rvalue = mgt_commit_list(priv, commit_part1, VEC_SIZE(commit_part1));
 
@@ -720,6 +720,7 @@
 		   incoherent state. We should reset it ! */
 		printk(KERN_DEBUG "%s: mgt_commit: failure\n", priv->ndev->name);
 	}
+	return rvalue;
 }
 
 /* The following OIDs need to be "unlatched":
diff -Naur linux-2.6.9rc2/drivers/net/wireless/prism54/oid_mgt.h linux-2.6.9-rc2msw/drivers/net/wireless/prism54/oid_mgt.h
--- linux-2.6.9rc2/drivers/net/wireless/prism54/oid_mgt.h	2004-10-02 12:23:39.000000000 +0200
+++ linux-2.6.9-rc2msw/drivers/net/wireless/prism54/oid_mgt.h	2004-10-02 15:01:41.000000000 +0200
@@ -48,7 +48,7 @@
 
 void mgt_get(islpci_private *, enum oid_num_t, void *);
 
-void mgt_commit(islpci_private *);
+int mgt_commit(islpci_private *);
 void mgt_unlatch_all(islpci_private *);
 
 int mgt_mlme_answer(islpci_private *);

--Boundary-00=_x+rXBVB5F4FxvYp
Content-Type: text/plain; charset="us-ascii"
MIME-Version: 1.0
Content-Transfer-Encoding: 7bit
Content-Disposition: inline

_______________________________________________
Prism54-devel mailing list
Prism54-devel@prism54.org
http://prism54.org/mailman/listinfo/prism54-devel

--Boundary-00=_x+rXBVB5F4FxvYp--
