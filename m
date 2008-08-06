From: Denys Fedoryshchenko <denys@visp.net.lb>
Subject: [PATCH] correct pointer assignment in free_opts()
Date: Wed, 6 Aug 2008 17:47:51 +0300
Message-ID: <200808061747.51671.denys@visp.net.lb>
Mime-Version: 1.0
Content-Type: text/plain;
  charset="us-ascii"
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, hadi@cyberus.ca
To: Stephen Hemminger <shemminger@linux-foundation.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from relay2.globalproof.net ([194.146.153.25]:51466 "EHLO
	relay2.globalproof.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1753040AbYHFOsl (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 6 Aug 2008 10:48:41 -0400
Content-Disposition: inline
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>


Invalid way of pointer assignment in free_opts causing global opts variable
pointingto freed memory. It was possible to trigger this bug only by batching
multiple rules with ipt action.

Signed-off-by: Denys Fedoryshchenko <denys@visp.net.lb>
Acked-by: Jamal Hadi Salim <hadi@cyberus.ca>
Tested-by: Denys Fedoryshchenko <denys@visp.net.lb>

---
diff -uprN iproute-original/tc/m_ipt.c iproute2-patched2/tc/m_ipt.c
--- iproute-original/tc/m_ipt.c	2008-08-05 22:15:56.000000000 +0300
+++ iproute2-patched2/tc/m_ipt.c	2008-08-06 16:34:13.000000000 +0300
@@ -162,11 +162,11 @@ int string_to_number(const char *s, unsi
 	return result;
 }
 
-static void free_opts(struct option *opts)
+static void free_opts(struct option **opts)
 {
-	if (opts != original_opts) {
-		free(opts);
-		opts = original_opts;
+	if (*opts != original_opts) {
+		free(*opts);
+		*opts = original_opts;
 		global_option_offset = 0;
 	}
 }
@@ -455,7 +455,7 @@ static int parse_ipt(struct action_util 
 		if (matches(argv[optind], "index") == 0) {
 			if (get_u32(&index, argv[optind + 1], 10)) {
 				fprintf(stderr, "Illegal \"index\"\n");
-				free_opts(opts);
+				free_opts(&opts);
 				return -1;
 			}
 			iok++;
@@ -513,7 +513,7 @@ static int parse_ipt(struct action_util 
 	*argv_p = argv;
 
 	optind = 1;
-	free_opts(opts);
+	free_opts(&opts);
 
 	return 0;
 
@@ -594,7 +594,7 @@ print_ipt(struct action_util *au,FILE * 
 		fprintf(f, " \n");
 
 	}
-	free_opts(opts);
+	free_opts(&opts);
 
 	return 0;
 }
