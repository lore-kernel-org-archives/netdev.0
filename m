From: margitsw@t-online.de (Margit Schubert-While)
Subject: [PATCH Linux-2.6.8-rc2] prism54 Fix memory leaks
Date: Fri, 6 Aug 2004 13:24:01 +0200
Sender: prism54-devel-bounces@prism54.org
Message-ID: <200408061324.01557.margitsw@t-online.de>
Mime-Version: 1.0
Content-Type: Multipart/Mixed;
  boundary="Boundary-00=_Rp2EBG9hsa+OUU0"
Cc: netdev@oss.sgi.com, prism54-devel@prism54.org
Return-path: <prism54-devel-bounces@prism54.org>
To: jgarzik@pobox.com
List-Unsubscribe: <http://prism54.org/mailman/listinfo/prism54-devel>,
	<mailto:prism54-devel-request@prism54.org?subject=unsubscribe>
List-Archive: <http://prism54.org/pipermail/prism54-devel>
List-Post: <mailto:prism54-devel@prism54.org>
List-Help: <mailto:prism54-devel-request@prism54.org?subject=help>
List-Subscribe: <http://prism54.org/mailman/listinfo/prism54-devel>,
	<mailto:prism54-devel-request@prism54.org?subject=subscribe>
Errors-To: prism54-devel-bounces@prism54.org
List-Id: netdev.vger.kernel.org


--Boundary-00=_Rp2EBG9hsa+OUU0
Content-Type: text/plain;
  charset="us-ascii"
Content-Transfer-Encoding: 7bit
Content-Disposition: inline

2004-08-06 Margit Schubert-While <margitsw@t-online.de>
* Change the "version" OID to what it should be.
*
* Fix memory leaks - mgt_get_request always returns
* allocated memory for non-int OIDS (with an exception -
* keep reading). If the caller checks the return and itself
* returns, then it must free memory.
* However, it is possible to return from mgt_get_request
* early (!priv->mib). In this case, weird things can happen
* in isl_ioctl. Quick fix, at least to force an oops, is
* to set the union value to NULL. The real fix is to
* recode all mgt_get_request calls in isl_ioctl.

 Jeff, have had no response to patch "Fix IRQ handling"
 from 2004-07-30.

Margit

Margit











--Boundary-00=_Rp2EBG9hsa+OUU0
Content-Type: text/x-diff;
  charset="us-ascii";
  name="memleak.patch"
Content-Transfer-Encoding: 7bit
Content-Disposition: attachment;
	filename="memleak.patch"

diff -Naur linux-2.6.8-01/drivers/net/wireless/prism54/isl_ioctl.c linux-2.6.8-04/drivers/net/wireless/prism54/isl_ioctl.c
--- linux-2.6.8-01/drivers/net/wireless/prism54/isl_ioctl.c	2004-07-27 19:42:33.000000000 +0200
+++ linux-2.6.8-04/drivers/net/wireless/prism54/isl_ioctl.c	2004-08-06 11:42:40.000000000 +0200
@@ -820,9 +820,11 @@
 		return mgt_set_request(priv, DOT11_OID_PROFILES, 0, &profile);
 	}
 
-	if ((ret =
-	     mgt_get_request(priv, DOT11_OID_SUPPORTEDRATES, 0, NULL, &r)))
+	ret = mgt_get_request(priv, DOT11_OID_SUPPORTEDRATES, 0, NULL, &r);
+	if (ret) {
+		kfree(r.ptr);
 		return ret;
+	}
 
 	rate = (u32) (vwrq->value / 500000);
 	data = r.ptr;
@@ -840,6 +842,7 @@
 	}
 
 	if (!data[i]) {
+		kfree(r.ptr);
 		return -EINVAL;
 	}
 
@@ -888,8 +891,11 @@
 	vwrq->value = r.u * 500000;
 
 	/* request the device for the enabled rates */
-	if ((rvalue = mgt_get_request(priv, DOT11_OID_RATES, 0, NULL, &r)))
+	rvalue = mgt_get_request(priv, DOT11_OID_RATES, 0, NULL, &r);
+	if (rvalue) {
+		kfree(r.ptr);
 		return rvalue;
+	}
 	data = r.ptr;
 	vwrq->fixed = (data[0] != 0) && (data[1] == 0);
 	kfree(r.ptr);
diff -Naur linux-2.6.8-01/drivers/net/wireless/prism54/oid_mgt.c linux-2.6.8-04/drivers/net/wireless/prism54/oid_mgt.c
--- linux-2.6.8-01/drivers/net/wireless/prism54/oid_mgt.c	2004-07-27 19:42:33.000000000 +0200
+++ linux-2.6.8-04/drivers/net/wireless/prism54/oid_mgt.c	2004-08-06 11:42:50.000000000 +0200
@@ -219,7 +219,7 @@
 	OID_UNKNOWN(OID_INL_MEMORY, 0xFF020002),
 	OID_U32_C(OID_INL_MODE, 0xFF020003),
 	OID_UNKNOWN(OID_INL_COMPONENT_NR, 0xFF020004),
-	OID_UNKNOWN(OID_INL_VERSION, 0xFF020005),
+	OID_STRUCT(OID_INL_VERSION, 0xFF020005, u8[8], OID_TYPE_RAW),
 	OID_UNKNOWN(OID_INL_INTERFACE_ID, 0xFF020006),
 	OID_UNKNOWN(OID_INL_COMPONENT_ID, 0xFF020007),
 	OID_U32_C(OID_INL_CONFIG, 0xFF020008),
@@ -481,6 +481,8 @@
 	BUG_ON(OID_NUM_LAST <= n);
 	BUG_ON(extra > isl_oid[n].range);
 
+	res->ptr = NULL;
+
 	if (!priv->mib)
 		/* memory has been freed */
 		return -1;

--Boundary-00=_Rp2EBG9hsa+OUU0
Content-Type: text/plain; charset="us-ascii"
MIME-Version: 1.0
Content-Transfer-Encoding: 7bit
Content-Disposition: inline

_______________________________________________
Prism54-devel mailing list
Prism54-devel@prism54.org
http://prism54.org/mailman/listinfo/prism54-devel

--Boundary-00=_Rp2EBG9hsa+OUU0--
