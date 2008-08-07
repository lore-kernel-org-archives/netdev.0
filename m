From: Denys Fedoryshchenko <denys@visp.net.lb>
Subject: [PATCH] reset optind and fix memory leak in m_ipt/iptables target structure
Date: Thu, 7 Aug 2008 17:33:25 +0300
Message-ID: <200808071733.26376.denys@visp.net.lb>
Mime-Version: 1.0
Content-Type: text/plain;
  charset="us-ascii"
Content-Transfer-Encoding: 7bit
Cc: hadi@cyberus.ca,
	Stephen Hemminger <shemminger@linux-foundation.org>
To: Netdev <netdev@vger.kernel.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from relay2.globalproof.net ([194.146.153.25]:46910 "EHLO
	relay2.globalproof.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1753910AbYHGOe2 (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 7 Aug 2008 10:34:28 -0400
Content-Disposition: inline
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>


According iptables sources for reusing iptables target optind must be reset to
 zero, this is important in batch processing. Also if we are using iptables
 target, we are allocating memory for two temporary variables and inside
 structure of iptables_target, which must be freed when job done. Also 
tflags and used in structure must be reset, to zero for next reuse of 
structure.

Signed-off-by: Denys Fedoryshchenko <denys@visp.net.lb>
Tested-by: Denys Fedoryshchenko <denys@visp.net.lb>

---
diff -Naur iproute2-original/tc/m_ipt.c iproute2-patched/tc/m_ipt.c
--- iproute2-original/tc/m_ipt.c	2008-08-05 19:15:56.000000000 +0000
+++ iproute2-patched/tc/m_ipt.c	2008-08-05 21:39:49.000000000 +0000
@@ -277,6 +277,8 @@
 		if (!handle) {
 			fputs(dlerror(), stderr);
 			printf("\n");
+			free(l_name);
+			free(new_name);
 			return NULL;
 		}
 	}
@@ -292,12 +294,16 @@
 					fputs(error, stderr);
 					fprintf(stderr, "\n");
 					dlclose(handle);
+					free(l_name);
+					free(new_name);
 					return NULL;
 				}
 			}
 		}
 	}
 
+	free(l_name);
+	free(new_name);
 	return m;
 }
 
@@ -512,8 +518,15 @@
 	*argc_p = rargc - iargc;
 	*argv_p = argv;
 
-	optind = 1;
+	optind = 0;
 	free_opts(opts);
+	/* Clear flags if target will be used again */
+        m->tflags=0;
+        m->used=0;
+	/* Free allocated memory */
+        if (m->t)
+            free(m->t);
+
 
 	return 0;
 
