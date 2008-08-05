From: Denys Fedoryshchenko <denys@visp.net.lb>
Subject: few more fixes for iproute2/m_ipt
Date: Wed, 6 Aug 2008 00:42:53 +0300
Message-ID: <200808060042.53503.denys@visp.net.lb>
Mime-Version: 1.0
Content-Type: Multipart/Mixed;
  boundary="Boundary-00=_dlMmITw/x9FeSa5"
Cc: netdev@vger.kernel.org
To: Stephen Hemminger <shemminger@linux-foundation.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from relay2.globalproof.net ([194.146.153.25]:57952 "EHLO
	relay2.globalproof.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1757757AbYHEVni (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 5 Aug 2008 17:43:38 -0400
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

--Boundary-00=_dlMmITw/x9FeSa5
Content-Type: text/plain;
  charset="us-ascii"
Content-Transfer-Encoding: 7bit
Content-Disposition: inline

Comments:
1)optind according iptables sources have to be set to 0. If it is set to 1, in 
batch it will mess up things. Also in iptables sources i notice that ->tflags 
and ->used need to be reset.

2)Since target->t = fw_calloc(1, size); allocated memory in function build_st, 
it have to be freed at the end, or in batch we will have memory leak. TODO: 
Probably it must be freed in all "return -1" cases in parse_ipt after 
build_st. About this i am not sure, up to Stephen.

3)lname and new_name was malloc'ed, but not freed

Point 1 fix is critical, since without it m_ipt crashing iproute2 in batch 
mode.

--Boundary-00=_dlMmITw/x9FeSa5
Content-Type: text/x-diff;
  charset="us-ascii";
  name="m_ipt_fix3.patch"
Content-Transfer-Encoding: 7bit
Content-Disposition: attachment;
	filename="m_ipt_fix3.patch"

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
 

--Boundary-00=_dlMmITw/x9FeSa5--
