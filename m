From: margitsw@t-online.de (Margit Schubert-While)
Subject: [PATCH 4/6 linux-2.6.9-rc1/2.4.28-pre2] prism54 add
	WE17 support
Date: Sun, 5 Sep 2004 12:18:28 +0200
Sender: prism54-devel-bounces@prism54.org
Message-ID: <200409051218.28597.margitsw@t-online.de>
Mime-Version: 1.0
Content-Type: Multipart/Mixed;
  boundary="Boundary-00=_0fuOBMb4BojZJud"
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


--Boundary-00=_0fuOBMb4BojZJud
Content-Type: text/plain;
  charset="us-ascii"
Content-Transfer-Encoding: 7bit
Content-Disposition: inline

2004-09-05 Margit Schubert-While <margitsw@t-online.de>
2004-08-18 Luis R. Rodriguez <mcgrof@ruslug.rutgers.edu>

* Add support for WE17 from Jean Tourrilhes

Margit















--Boundary-00=_0fuOBMb4BojZJud
Content-Type: text/x-diff; charset="us-ascii"; name="04_handle_we17.patch"
Content-Transfer-Encoding: 7bit
Content-Disposition: attachment;
	filename="04_handle_we17.patch"

diff -Naur linux-2.6.9rc1/drivers/net/wireless/prism54/isl_ioctl.c linux-2.6.9-rc1msw/drivers/net/wireless/prism54/isl_ioctl.c
--- linux-2.6.9rc1/drivers/net/wireless/prism54/isl_ioctl.c	2004-09-05 10:46:50.000000000 +0200
+++ linux-2.6.9-rc1msw/drivers/net/wireless/prism54/isl_ioctl.c	2004-09-05 10:47:13.000000000 +0200
@@ -451,6 +451,15 @@
 	/* txpower is supported in dBm's */
 	range->txpower_capa = IW_TXPOW_DBM;
 
+#if WIRELESS_EXT > 16
+	/* Event capability (kernel + driver) */
+	range->event_capa[0] = (IW_EVENT_CAPA_K_0 |
+	IW_EVENT_CAPA_MASK(SIOCGIWTHRSPY) |
+	IW_EVENT_CAPA_MASK(SIOCGIWAP));
+	range->event_capa[1] = IW_EVENT_CAPA_K_1;
+	range->event_capa[4] = IW_EVENT_CAPA_MASK(IWEVCUSTOM);
+#endif /* WIRELESS_EXT > 16 */
+
 	if (islpci_get_state(priv) < PRV_STATE_INIT)
 		return 0;
 
@@ -656,19 +665,33 @@
 	rvalue = mgt_get_request(priv, DOT11_OID_NOISEFLOOR, 0, NULL, &r);
 	noise = r.u;
 
-	/* Ask the device for a list of known bss. We can report at most
-	 * IW_MAX_AP=64 to the range struct. But the device won't repport anything
-	 * if you change the value of IWMAX_BSS=24.
-	 */
+	/* Ask the device for a list of known bss.
+	* The old API, using SIOCGIWAPLIST, had a hard limit of IW_MAX_AP=64.
+	* The new API, using SIOCGIWSCAN, is only limited by the buffer size.
+	* WE-14->WE-16, the buffer is limited to IW_SCAN_MAX_DATA bytes.
+	* Starting with WE-17, the buffer can be as big as needed.
+	* But the device won't repport anything if you change the value
+	* of IWMAX_BSS=24. */
+	
 	rvalue |= mgt_get_request(priv, DOT11_OID_BSSLIST, 0, NULL, &r);
 	bsslist = r.ptr;
 
 	/* ok now, scan the list and translate its info */
-	for (i = 0; i < min(IW_MAX_AP, (int) bsslist->nr); i++)
+	for (i = 0; i < (int) bsslist->nr; i++) {
 		current_ev = prism54_translate_bss(ndev, current_ev,
-						   extra + IW_SCAN_MAX_DATA,
+						   extra + dwrq->length,
 						   &(bsslist->bsslist[i]),
 						   noise);
+#if WIRELESS_EXT > 16
+		/* Check if there is space for one more entry */
+		if((extra + dwrq->length - current_ev) <= IW_EV_ADDR_LEN) {
+			/* Ask user space to try again with a bigger buffer */
+			rvalue = -E2BIG;
+			break;
+		}
+#endif /* WIRELESS_EXT > 16 */
+	}
+
 	kfree(bsslist);
 	dwrq->length = (current_ev - extra);
 	dwrq->flags = 0;	/* todo */
@@ -2222,7 +2245,9 @@
 	.standard = (iw_handler *) prism54_handler,
 	.private = (iw_handler *) prism54_private_handler,
 	.private_args = (struct iw_priv_args *) prism54_private_args,
+#if WIRELESS_EXT == 16
 	.spy_offset = offsetof(islpci_private, spy_data),
+#endif /* WIRELESS_EXT == 16 */
 };
 
 /* For ioctls that don't work with the new API */
diff -Naur linux-2.6.9rc1/drivers/net/wireless/prism54/islpci_dev.c linux-2.6.9-rc1msw/drivers/net/wireless/prism54/islpci_dev.c
--- linux-2.6.9rc1/drivers/net/wireless/prism54/islpci_dev.c	2004-09-05 10:44:54.000000000 +0200
+++ linux-2.6.9-rc1msw/drivers/net/wireless/prism54/islpci_dev.c	2004-09-05 10:47:13.000000000 +0200
@@ -829,6 +829,12 @@
 	priv->ndev->type = (priv->iw_mode == IW_MODE_MONITOR) ?
 		priv->monitor_type : ARPHRD_ETHER;
 
+#if WIRELESS_EXT > 16
+	/* Add pointers to enable iwspy support. */
+	priv->wireless_data.spy_data = &priv->spy_data;
+	ndev->wireless_data = &priv->wireless_data;
+#endif /* WIRELESS_EXT > 16 */
+
 	/* save the start and end address of the PCI memory area */
 	ndev->mem_start = (unsigned long) priv->device_base;
 	ndev->mem_end = ndev->mem_start + ISL38XX_PCI_MEM_SIZE;
diff -Naur linux-2.6.9rc1/drivers/net/wireless/prism54/islpci_dev.h linux-2.6.9-rc1msw/drivers/net/wireless/prism54/islpci_dev.h
--- linux-2.6.9rc1/drivers/net/wireless/prism54/islpci_dev.h	2004-08-14 07:36:56.000000000 +0200
+++ linux-2.6.9-rc1msw/drivers/net/wireless/prism54/islpci_dev.h	2004-09-05 10:47:13.000000000 +0200
@@ -100,6 +100,10 @@
 
 	struct iw_spy_data spy_data; /* iwspy support */
 
+#if WIRELESS_EXT > 16
+	struct iw_public_data wireless_data;
+#endif /* WIRELESS_EXT > 16 */
+
 	int monitor_type; /* ARPHRD_IEEE80211 or ARPHRD_IEEE80211_PRISM */
 
 	struct islpci_acl acl;

--Boundary-00=_0fuOBMb4BojZJud
Content-Type: text/plain; charset="us-ascii"
MIME-Version: 1.0
Content-Transfer-Encoding: 7bit
Content-Disposition: inline

_______________________________________________
Prism54-devel mailing list
Prism54-devel@prism54.org
http://prism54.org/mailman/listinfo/prism54-devel

--Boundary-00=_0fuOBMb4BojZJud--
