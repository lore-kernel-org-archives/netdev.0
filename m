From: Denys Fedoryshchenko <denys@visp.net.lb>
Subject: iproute2/m_ipt fix, opts was not set properly
Date: Tue, 5 Aug 2008 22:24:36 +0300
Message-ID: <200808052224.36773.denys@visp.net.lb>
Mime-Version: 1.0
Content-Type: Multipart/Mixed;
  boundary="Boundary-00=_0jKmIM4QQ7Ci3Hs"
Cc: netdev@vger.kernel.org
To: Stephen Hemminger <shemminger@linux-foundation.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from relay2.globalproof.net ([194.146.153.25]:53083 "EHLO
	relay2.globalproof.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1760781AbYHETZY (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 5 Aug 2008 15:25:24 -0400
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

--Boundary-00=_0jKmIM4QQ7Ci3Hs
Content-Type: text/plain;
  charset="us-ascii"
Content-Transfer-Encoding: 7bit
Content-Disposition: inline

Since opts global variable, if it is set to original_opts, it was done in 
local context of function, and global variable in result was pointing to 
freed memory. Sure result of that - segfault, it is possible to trigger it 
only while processing batch, cause only on next iteration opts was wrong.

There is two ways to fix that, both patches attached.
Please send me note, which way correct (at least i will learn something :-) )


--Boundary-00=_0jKmIM4QQ7Ci3Hs
Content-Type: text/x-diff;
  charset="us-ascii";
  name="ipt_m_v1.patch"
Content-Transfer-Encoding: 7bit
Content-Disposition: attachment;
	filename="ipt_m_v1.patch"

diff -Naur iproute2-original/tc/m_ipt.c iproute2-patched/tc/m_ipt.c
--- iproute2-original/tc/m_ipt.c	2008-08-05 19:15:56.000000000 +0000
+++ iproute2-patched/tc/m_ipt.c	2008-08-05 19:20:20.000000000 +0000
@@ -162,7 +162,7 @@
 	return result;
 }
 
-static void free_opts(struct option *opts)
+static void free_opts(void)
 {
 	if (opts != original_opts) {
 		free(opts);
@@ -455,7 +455,7 @@
 		if (matches(argv[optind], "index") == 0) {
 			if (get_u32(&index, argv[optind + 1], 10)) {
 				fprintf(stderr, "Illegal \"index\"\n");
-				free_opts(opts);
+				free_opts();
 				return -1;
 			}
 			iok++;
@@ -513,7 +513,7 @@
 	*argv_p = argv;
 
 	optind = 1;
-	free_opts(opts);
+	free_opts();
 
 	return 0;
 
@@ -594,7 +594,7 @@
 		fprintf(f, " \n");
 
 	}
-	free_opts(opts);
+	free_opts();
 
 	return 0;
 }

--Boundary-00=_0jKmIM4QQ7Ci3Hs
Content-Type: text/x-diff;
  charset="us-ascii";
  name="ipt_m_v2.patch"
Content-Transfer-Encoding: 7bit
Content-Disposition: attachment;
	filename="ipt_m_v2.patch"

diff -Naur iproute2-original/tc/m_ipt.c iproute2-patched2/tc/m_ipt.c
--- iproute2-original/tc/m_ipt.c	2008-08-05 19:15:56.000000000 +0000
+++ iproute2-patched2/tc/m_ipt.c	2008-08-05 19:22:55.000000000 +0000
@@ -162,10 +162,10 @@
 	return result;
 }
 
-static void free_opts(struct option *opts)
+static void free_opts(struct option *opts_local)
 {
-	if (opts != original_opts) {
-		free(opts);
+	if (opts_local != original_opts) {
+		free(opts_local);
 		opts = original_opts;
 		global_option_offset = 0;
 	}

--Boundary-00=_0jKmIM4QQ7Ci3Hs--
