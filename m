From: Jiri Bohac <jbohac@suse.cz>
Subject: [PATCH] Fix NULL pointer dereference on ipx unload
Date: Fri, 9 Feb 2007 00:28:29 +0100
Message-ID: <20070208232828.GA25728@dwarf.suse.cz>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: netdev@vger.kernel.org
To: acme@conectiva.com.br
Return-path: <netdev-owner@vger.kernel.org>
Received: from styx.suse.cz ([82.119.242.94]:42311 "EHLO mail.suse.cz"
	rhost-flags-OK-OK-OK-FAIL) by vger.kernel.org with ESMTP
	id S965223AbXBHX1Q (ORCPT <rfc822;netdev@vger.kernel.org>);
	Thu, 8 Feb 2007 18:27:16 -0500
Content-Disposition: inline
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Fixes a null pointer dereference when unloading the ipx module.

On initialization of the ipx module, registering certain packet
types can fail. When this happens, unloading the module later
dereferences NULL pointers.  This patch fixes that. Please apply.

Signed-off-by: Jiri Bohac <jbohac@suse.cz>

diff -ur linux-2.6.20-rc6/net/ipx/af_ipx.c linux-2.6.20-rc6.fixed/net/ipx/af_ipx.c
--- linux-2.6.20-rc6/net/ipx/af_ipx.c	2007-01-25 03:19:28.000000000 +0100
+++ linux-2.6.20-rc6.fixed/net/ipx/af_ipx.c	2007-02-08 18:13:53.000000000 +0100
@@ -2035,19 +2035,27 @@
 
 	ipxitf_cleanup();
 
-	unregister_snap_client(pSNAP_datalink);
-	pSNAP_datalink = NULL;
-
-	unregister_8022_client(p8022_datalink);
-	p8022_datalink = NULL;
+	if (pSNAP_datalink) {
+		unregister_snap_client(pSNAP_datalink);
+		pSNAP_datalink = NULL;
+	}
+
+	if (p8022_datalink) {
+		unregister_8022_client(p8022_datalink);
+		p8022_datalink = NULL;
+	}
 
 	dev_remove_pack(&ipx_8023_packet_type);
-	destroy_8023_client(p8023_datalink);
-	p8023_datalink = NULL;
+	if (p8023_datalink) {
+		destroy_8023_client(p8023_datalink);
+		p8023_datalink = NULL;
+	}
 
 	dev_remove_pack(&ipx_dix_packet_type);
-	destroy_EII_client(pEII_datalink);
-	pEII_datalink = NULL;
+	if (pEII_datalink) {
+		destroy_EII_client(pEII_datalink);
+		pEII_datalink = NULL;
+	}
 
 	proto_unregister(&ipx_proto);
 	sock_unregister(ipx_family_ops.family);


-- 
Jiri Bohac <jbohac@suse.cz>
SUSE Labs, SUSE CZ

