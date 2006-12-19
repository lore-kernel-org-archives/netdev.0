From: Akinobu Mita <akinobu.mita@gmail.com>
Subject: [PATCH] irlan: handle out of memory errors
Date: Tue, 19 Dec 2006 17:56:01 +0900
Message-ID: <20061219085601.GL4049@APFDCB5C>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: Samuel Ortiz <samuel@sortiz.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from wx-out-0506.google.com ([66.249.82.231]:19294 "EHLO
	wx-out-0506.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S932085AbWLSI4y (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 19 Dec 2006 03:56:54 -0500
Received: by wx-out-0506.google.com with SMTP id h27so1616072wxd
        for <netdev@vger.kernel.org>; Tue, 19 Dec 2006 00:56:54 -0800 (PST)
To: netdev@vger.kernel.org
Content-Disposition: inline
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

This patch checks return values:

- irlmp_register_client()
- irlmp_register_service()
- irlan_open()

Cc: Samuel Ortiz <samuel@sortiz.org>
Signed-off-by: Akinobu Mita <akinobu.mita@gmail.com>

---
 net/irda/irlan/irlan_common.c |   23 ++++++++++++++++++++---
 1 file changed, 20 insertions(+), 3 deletions(-)

Index: 2.6-mm/net/irda/irlan/irlan_common.c
===================================================================
--- 2.6-mm.orig/net/irda/irlan/irlan_common.c
+++ 2.6-mm/net/irda/irlan/irlan_common.c
@@ -144,12 +144,18 @@ static int __init irlan_init(void)
 	/* Register with IrLMP as a client */
 	ckey = irlmp_register_client(hints, &irlan_client_discovery_indication,
 				     NULL, NULL);
-	
+	if (!ckey)
+		goto err_ckey;
+
 	/* Register with IrLMP as a service */
- 	skey = irlmp_register_service(hints);
+	skey = irlmp_register_service(hints);
+	if (!skey)
+		goto err_skey;
 
 	/* Start the master IrLAN instance (the only one for now) */
- 	new = irlan_open(DEV_ADDR_ANY, DEV_ADDR_ANY);
+	new = irlan_open(DEV_ADDR_ANY, DEV_ADDR_ANY);
+	if (!new)
+		goto err_open;
 
 	/* The master will only open its (listen) control TSAP */
 	irlan_provider_open_ctrl_tsap(new);
@@ -158,6 +164,17 @@ static int __init irlan_init(void)
 	irlmp_discovery_request(DISCOVERY_DEFAULT_SLOTS);
 
 	return 0;
+
+err_open:
+	irlmp_unregister_service(skey);
+err_skey:
+	irlmp_unregister_client(ckey);
+err_ckey:
+#ifdef CONFIG_PROC_FS
+	remove_proc_entry("irlan", proc_irda);
+#endif /* CONFIG_PROC_FS */
+
+	return -ENOMEM;
 }
 
 static void __exit irlan_cleanup(void) 
