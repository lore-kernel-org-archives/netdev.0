From: margitsw@t-online.de (Margit Schubert-While)
Subject: [PATCH 11/17 linux-2.6.7-rc2] prism54: Don't allow mib reads while unconfigured (resend)
Date: Sat, 5 Jun 2004 14:49:55 +0200
Sender: netdev-bounce@oss.sgi.com
Message-ID: <200406051449.55893.margitsw@t-online.de>
Mime-Version: 1.0
Content-Type: Multipart/Mixed;
  boundary="Boundary-00=_zFcwAfFmTGrEPSo"
Cc: netdev@oss.sgi.com
Return-path: <netdev-bounce@oss.sgi.com>
To: jgarzik@pobox.com
Errors-to: netdev-bounce@oss.sgi.com
List-Id: netdev.vger.kernel.org


--Boundary-00=_zFcwAfFmTGrEPSo
Content-Type: text/plain;
  charset="us-ascii"
Content-Transfer-Encoding: 7bit
Content-Disposition: inline

004-04-17      Aurelien Alleaume <slts@free.fr>

        * oid_mgt.c, isl_ioctl.c : Cleanup. Prevented real oid reading
        before the card is configured with mib values (might be
        related to
        bug #53).



--Boundary-00=_zFcwAfFmTGrEPSo
Content-Type: text/x-diff;
  charset="us-ascii";
  name="11-prevent-oid-read-before-config.patch"
Content-Transfer-Encoding: 7bit
Content-Disposition: attachment;
	filename="11-prevent-oid-read-before-config.patch"

diff -Naur linux-2.6.6ct/drivers/net/wireless/prism54/isl_ioctl.c linux-2.6.6-01/drivers/net/wireless/prism54/isl_ioctl.c
--- linux-2.6.6ct/drivers/net/wireless/prism54/isl_ioctl.c	2004-06-05 14:02:14.000000000 +0200
+++ linux-2.6.6-01/drivers/net/wireless/prism54/isl_ioctl.c	2004-06-05 14:03:15.000000000 +0200
@@ -173,14 +173,6 @@
 	prism54_mib_mode_helper(priv, init_mode);
 }
 
-void
-prism54_mib_init_work(islpci_private *priv)
-{
-	down_write(&priv->mib_sem);
-	mgt_commit(priv);
-	up_write(&priv->mib_sem);
-}
-
 /* this will be executed outside of atomic context thanks to
  * schedule_work(), thus we can as well use sleeping semaphore
  * locking */
@@ -195,13 +187,6 @@
 	if (down_interruptible(&priv->stats_sem))
 		return;
 
-/* missing stats are :
- *  iwstatistics.qual.updated
- *  iwstatistics.discard.nwid	    
- *  iwstatistics.discard.fragment	    
- *  iwstatistics.discard.misc
- *  iwstatistics.miss.beacon */
-
 /* Noise floor.
  * I'm not sure if the unit is dBm.
  * Note : If we are not connected, this value seems to be irrelevant. */
@@ -425,7 +410,6 @@
 	/* by default  the card sets this to 20. */
 	sens = vwrq->disabled ? 20 : vwrq->value;
 
-	/* set the ed threshold. */
 	return mgt_set_request(priv, DOT11_OID_EDTHRESHOLD, 0, &sens);
 }
 
@@ -712,7 +696,7 @@
 
 	/* Ask the device for a list of known bss. We can report at most
 	 * IW_MAX_AP=64 to the range struct. But the device won't repport anything
-	 * if you change the value of MAXBSS=24. Anyway 24 AP It is probably enough.
+	 * if you change the value of IWMAX_BSS=24.
 	 */
 	rvalue |= mgt_get_request(priv, DOT11_OID_BSSLIST, 0, NULL, &r);
 	bsslist = r.ptr;
@@ -969,8 +953,6 @@
  * small frame <=>  smaller than the rts threshold
  * This is not really the behavior expected by the wireless tool but it seems
  * to be a common behavior in other drivers.
- * 
- * It seems that playing with this tends to hang the card -> DISABLED
  */
 
 static int
@@ -1002,14 +984,13 @@
 		lifetime = vwrq->value / 1024;
 
 	/* now set what is requested */
-
-	if (slimit != 0)
+	if (slimit)
 		rvalue =
 		    mgt_set_request(priv, DOT11_OID_SHORTRETRIES, 0, &slimit);
-	if (llimit != 0)
+	if (llimit)
 		rvalue |=
 		    mgt_set_request(priv, DOT11_OID_LONGRETRIES, 0, &llimit);
-	if (lifetime != 0)
+	if (lifetime)
 		rvalue |=
 		    mgt_set_request(priv, DOT11_OID_MAXTXLIFETIME, 0,
 				    &lifetime);
@@ -1261,11 +1242,6 @@
 prism54_set_u32(struct net_device *ndev, struct iw_request_info *info,
 		   __u32 * uwrq, char *extra)
 {
-	/*
-	   u32 *i = (int *) extra;
-	   int param = *i;
-	   int u = *(i + 1);
-	 */
 	u32 oid = uwrq[0], u = uwrq[1];
 
 	return mgt_set_request((islpci_private *) ndev->priv, oid, 0, &u);
@@ -1836,9 +1812,7 @@
 				     0);
 		break;
 
-		/* Note : the following should never happen since we don't run the card in
-		 * extended mode.
-		 * Note : "mlme" is actually a "struct obj_mlmeex *" here, but this
+		/* Note : "mlme" is actually a "struct obj_mlmeex *" here, but this
 		 * is backward compatible layout-wise with "struct obj_mlme".
 		 */
 
diff -Naur linux-2.6.6ct/drivers/net/wireless/prism54/isl_ioctl.h linux-2.6.6-01/drivers/net/wireless/prism54/isl_ioctl.h
--- linux-2.6.6ct/drivers/net/wireless/prism54/isl_ioctl.h	2004-06-05 13:39:20.000000000 +0200
+++ linux-2.6.6-01/drivers/net/wireless/prism54/isl_ioctl.h	2004-06-05 14:03:15.000000000 +0200
@@ -30,7 +30,6 @@
 #define SUPPORTED_WIRELESS_EXT                  16
 
 void prism54_mib_init(islpci_private *);
-void prism54_mib_init_work(islpci_private *);
 
 struct iw_statistics *prism54_get_wireless_stats(struct net_device *);
 void prism54_update_stats(islpci_private *);
diff -Naur linux-2.6.6ct/drivers/net/wireless/prism54/islpci_dev.c linux-2.6.6-01/drivers/net/wireless/prism54/islpci_dev.c
--- linux-2.6.6ct/drivers/net/wireless/prism54/islpci_dev.c	2004-06-05 13:58:59.000000000 +0200
+++ linux-2.6.6-01/drivers/net/wireless/prism54/islpci_dev.c	2004-06-05 14:03:15.000000000 +0200
@@ -504,7 +504,9 @@
 	 * the IRQ line until we know for sure the reset went through */
 	isl38xx_enable_common_interrupts(priv->device_base);
 
-	prism54_mib_init_work(priv);
+	down_write(&priv->mib_sem);
+	mgt_commit(priv);
+	up_write(&priv->mib_sem);
 
 	islpci_set_state(priv, PRV_STATE_READY);
 
diff -Naur linux-2.6.6ct/drivers/net/wireless/prism54/islpci_mgt.c linux-2.6.6-01/drivers/net/wireless/prism54/islpci_mgt.c
--- linux-2.6.6ct/drivers/net/wireless/prism54/islpci_mgt.c	2004-06-05 14:02:14.000000000 +0200
+++ linux-2.6.6-01/drivers/net/wireless/prism54/islpci_mgt.c	2004-06-05 14:03:15.000000000 +0200
@@ -312,8 +312,9 @@
                  * size of a receive buffer.  Thus, if this check
                  * triggers, we likely have kernel heap corruption. */
                 if (frag_len > MGMT_FRAME_SIZE) {
-                        printk(KERN_WARNING "%s: Bogus packet size of %d (%#x).\
-n", ndev->name, frag_len, frag_len);
+			printk(KERN_WARNING
+				"%s: Bogus packet size of %d (%#x).\n",
+				ndev->name, frag_len, frag_len);
                         frag_len = MGMT_FRAME_SIZE;
                 }
 
@@ -488,7 +489,8 @@
 		}
 		if (timeleft == 0) {
 			printk(KERN_DEBUG
-			       "%s: timeout waiting for mgmt response %lu, trigging device\n",
+				"%s: timeout waiting for mgmt response %lu, "
+				"triggering device\n",
 			       ndev->name, timeout_left);
 			islpci_trigger(priv);
 		}
diff -Naur linux-2.6.6ct/drivers/net/wireless/prism54/oid_mgt.c linux-2.6.6-01/drivers/net/wireless/prism54/oid_mgt.c
--- linux-2.6.6ct/drivers/net/wireless/prism54/oid_mgt.c	2004-06-05 14:02:14.000000000 +0200
+++ linux-2.6.6-01/drivers/net/wireless/prism54/oid_mgt.c	2004-06-05 14:03:15.000000000 +0200
@@ -446,7 +446,7 @@
 	if (cache)
 		down_write(&priv->mib_sem);
 
-	if (islpci_get_state(priv) >= PRV_STATE_INIT) {
+	if (islpci_get_state(priv) >= PRV_STATE_READY) {
 		ret = islpci_mgt_transaction(priv->ndev, PIMFOR_OP_SET, oid,
 					     _data, dlen, &response);
 		if (!ret) {
@@ -500,7 +500,7 @@
 	if (cache)
 		down_read(&priv->mib_sem);
 
-	if (islpci_get_state(priv) >= PRV_STATE_INIT) {
+	if (islpci_get_state(priv) >= PRV_STATE_READY) {
 		ret = islpci_mgt_transaction(priv->ndev, PIMFOR_OP_GET,
 					     oid, data, dlen, &response);
 		if (ret || !response ||
@@ -539,7 +539,7 @@
 	if (reslen > isl_oid[n].size)
 		printk(KERN_DEBUG
 		       "mgt_get_request(0x%x): received data length was bigger "
-		       "than expected (%d > %d). Memory is probably corrupted... ",
+		       "than expected (%d > %d). Memory is probably corrupted...",
 		       oid, reslen, isl_oid[n].size);
 	
 	return ret;
@@ -622,12 +622,32 @@
 	OID_INL_OUTPUTPOWER,
 };
 
+/* update the MAC addr. */
+static int
+mgt_update_addr(islpci_private *priv)
+{
+	struct islpci_mgmtframe *res;
+	int ret;
+
+	ret = islpci_mgt_transaction(priv->ndev, PIMFOR_OP_GET,
+				     isl_oid[GEN_OID_MACADDRESS].oid, NULL,
+				     isl_oid[GEN_OID_MACADDRESS].size, &res);
+
+	if ((ret == 0) && res && (res->header->operation != PIMFOR_OP_ERROR))
+		memcpy(priv->ndev->dev_addr, res->data, 6);
+	else
+		ret = -EIO;
+	if (res)
+		islpci_mgt_release(res);
+
+	return ret;
+}
+
 void
 mgt_commit(islpci_private *priv)
 {
 	int rvalue;
 	u32 u;
-	union oid_res_t r;
 
 	if (islpci_get_state(priv) < PRV_STATE_INIT)
 		return;
@@ -643,6 +663,7 @@
 
 	u = OID_INL_MODE;
 	rvalue |= mgt_commit_list(priv, &u, 1);
+	rvalue |= mgt_update_addr(priv);
 
 	if (rvalue) {
 		/* some request have failed. The device might be in an
@@ -650,14 +671,6 @@
 		printk(KERN_DEBUG "%s: mgt_commit has failed. Restart the "
                 "device \n", priv->ndev->name);
 	}
-
-	/* update the MAC addr. As it's not cached, no lock will be acquired by
-	 * the mgt_get_request
-	 */
-	mgt_get_request(priv, GEN_OID_MACADDRESS, 0, NULL, &r);
-	memcpy(priv->ndev->dev_addr, r.ptr, 6);
-	kfree(r.ptr);
-
 }
 
 /* This will tell you if you are allowed to answer a mlme(ex) request .*/
@@ -710,8 +723,11 @@
 	case OID_TYPE_BSS:{
 			struct obj_bss *bss = r->ptr;
 			return snprintf(str, PRIV_STR_SIZE,
-					"age=%u\nchannel=%u\n\
-				        capinfo=0x%X\nrates=0x%X\nbasic_rates=0x%X\n", bss->age, bss->channel, bss->capinfo, bss->rates, bss->basic_rates);
+					"age=%u\nchannel=%u\n"
+					"capinfo=0x%X\nrates=0x%X\n"
+					"basic_rates=0x%X\n", bss->age,
+					bss->channel, bss->capinfo,
+					bss->rates, bss->basic_rates);
 		}
 		break;
 	case OID_TYPE_BSSLIST:{
@@ -720,7 +736,9 @@
 			k = snprintf(str, PRIV_STR_SIZE, "nr=%u\n", list->nr);
 			for (i = 0; i < list->nr; i++)
 				k += snprintf(str + k, PRIV_STR_SIZE - k,
-					      "bss[%u] : \nage=%u\nchannel=%u\ncapinfo=0x%X\nrates=0x%X\nbasic_rates=0x%X\n",
+					      "bss[%u] : \nage=%u\nchannel=%u\n"
+					      "capinfo=0x%X\nrates=0x%X\n"
+					      "basic_rates=0x%X\n",
 					      i, list->bsslist[i].age,
 					      list->bsslist[i].channel,
 					      list->bsslist[i].capinfo,
@@ -742,16 +760,17 @@
 		break;
 	case OID_TYPE_MLME:{
 			struct obj_mlme *mlme = r->ptr;
-			return snprintf(str, PRIV_STR_SIZE, "id=0x%X\nstate=0x%X\n\
-			         code=0x%X\n", mlme->id, mlme->state,
-					mlme->code);
+			return snprintf(str, PRIV_STR_SIZE,
+					"id=0x%X\nstate=0x%X\ncode=0x%X\n",
+					mlme->id, mlme->state, mlme->code);
 		}
 		break;
 	case OID_TYPE_MLMEEX:{
 			struct obj_mlmeex *mlme = r->ptr;
-			return snprintf(str, PRIV_STR_SIZE, "id=0x%X\nstate=0x%X\n\
-			         code=0x%X\nsize=0x%X\n", mlme->id, mlme->state,
-					mlme->code, mlme->size);
+			return snprintf(str, PRIV_STR_SIZE,
+					"id=0x%X\nstate=0x%X\n"
+					"code=0x%X\nsize=0x%X\n", mlme->id,
+					mlme->state, mlme->code, mlme->size);
 		}
 		break;
 	case OID_TYPE_SSID:{

--Boundary-00=_zFcwAfFmTGrEPSo--
