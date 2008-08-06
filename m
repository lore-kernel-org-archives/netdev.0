From: Denys Fedoryshchenko <denys@visp.net.lb>
Subject: Re: iproute2 proposal
Date: Wed, 6 Aug 2008 13:22:54 +0300
Message-ID: <200808061322.54655.denys@visp.net.lb>
References: <200808060125.38260.denys@visp.net.lb> <200808061304.45392.denys@visp.net.lb> <4899784C.5060405@trash.net>
Mime-Version: 1.0
Content-Type: Multipart/Mixed;
  boundary="Boundary-00=_+tXmI8j9VImqiZj"
Cc: Stephen Hemminger <shemminger@linux-foundation.org>,
	netdev@vger.kernel.org
To: Patrick McHardy <kaber@trash.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from relay2.globalproof.net ([194.146.153.25]:47880 "EHLO
	relay2.globalproof.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1753071AbYHFKXm (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 6 Aug 2008 06:23:42 -0400
In-Reply-To: <4899784C.5060405@trash.net>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

--Boundary-00=_+tXmI8j9VImqiZj
Content-Type: text/plain;
  charset="iso-8859-15"
Content-Transfer-Encoding: 7bit
Content-Disposition: inline

On Wednesday 06 August 2008, Patrick McHardy wrote:

> No patch attached ..

Sorry :-) Now must be attached

--Boundary-00=_+tXmI8j9VImqiZj
Content-Type: text/x-diff;
  charset="iso-8859-15";
  name="iproute2-proposal2.patch"
Content-Transfer-Encoding: 7bit
Content-Disposition: attachment;
	filename="iproute2-proposal2.patch"

diff -Naur iproute2-original/tc/f_route.c iproute2-patched/tc/f_route.c
--- iproute2-original/tc/f_route.c	2008-08-05 19:15:56.000000000 +0000
+++ iproute2-patched/tc/f_route.c	2008-08-06 09:50:48.000000000 +0000
@@ -25,6 +25,8 @@
 #include "tc_common.h"
 #include "tc_util.h"
 
+extern int link_cache;
+
 static void explain(void)
 {
 	fprintf(stderr, "Usage: ... route [ from REALM | fromif TAG ] [ to REALM ]\n");
@@ -83,7 +85,10 @@
 		} else if (matches(*argv, "fromif") == 0) {
 			__u32 id;
 			NEXT_ARG();
-			ll_init_map(&rth);
+			if (!link_cache) {
+ 			    ll_init_map(&rth);
+			    link_cache = 1;
+			}
 			if ((id=ll_name_to_index(*argv)) <= 0) {
 				fprintf(stderr, "Illegal \"fromif\"\n");
 				return -1;
diff -Naur iproute2-original/tc/m_mirred.c iproute2-patched/tc/m_mirred.c
--- iproute2-original/tc/m_mirred.c	2008-08-05 19:15:56.000000000 +0000
+++ iproute2-patched/tc/m_mirred.c	2008-08-06 09:49:39.000000000 +0000
@@ -27,6 +27,7 @@
 #include <linux/tc_act/tc_mirred.h>
 
 int mirred_d = 1;
+extern int link_cache;
 
 static void
 explain(void)
@@ -146,7 +147,10 @@
 
 	if (d[0])  {
 		int idx;
-		ll_init_map(&rth);
+		if (!link_cache) {
+ 		    ll_init_map(&rth);
+		    link_cache = 1;
+		}
 
 		if ((idx = ll_name_to_index(d)) == 0) {
 			fprintf(stderr, "Cannot find device \"%s\"\n", d);
diff -Naur iproute2-original/tc/tc.c iproute2-patched/tc/tc.c
--- iproute2-original/tc/tc.c	2008-08-05 19:15:56.000000000 +0000
+++ iproute2-patched/tc/tc.c	2008-08-06 09:47:18.000000000 +0000
@@ -38,6 +38,7 @@
 int resolve_hosts = 0;
 int use_iec = 0;
 int force = 0;
+int link_cache = 0;
 struct rtnl_handle rth;
 
 static void *BODY = NULL;	/* cached handle dlopen(NULL) */
diff -Naur iproute2-original/tc/tc_class.c iproute2-patched/tc/tc_class.c
--- iproute2-original/tc/tc_class.c	2008-08-05 19:15:56.000000000 +0000
+++ iproute2-patched/tc/tc_class.c	2008-08-06 09:51:18.000000000 +0000
@@ -25,6 +25,8 @@
 #include "tc_util.h"
 #include "tc_common.h"
 
+extern int link_cache;
+
 static void usage(void);
 
 static void usage(void)
@@ -130,7 +132,10 @@
 	}
 
 	if (d[0])  {
-		ll_init_map(&rth);
+		if (!link_cache) {
+ 		    ll_init_map(&rth);
+		    link_cache = 1;
+		}
 
 		if ((req.t.tcm_ifindex = ll_name_to_index(d)) == 0) {
 			fprintf(stderr, "Cannot find device \"%s\"\n", d);
@@ -273,7 +278,10 @@
 		argc--; argv++;
 	}
 
- 	ll_init_map(&rth);
+	if (!link_cache) {
+	    ll_init_map(&rth);
+	    link_cache = 1;
+	}
 
 	if (d[0]) {
 		if ((t.tcm_ifindex = ll_name_to_index(d)) == 0) {
diff -Naur iproute2-original/tc/tc_filter.c iproute2-patched/tc/tc_filter.c
--- iproute2-original/tc/tc_filter.c	2008-08-05 19:15:56.000000000 +0000
+++ iproute2-patched/tc/tc_filter.c	2008-08-06 09:48:54.000000000 +0000
@@ -26,6 +26,7 @@
 #include "tc_util.h"
 #include "tc_common.h"
 
+extern int link_cache;
 static void usage(void);
 
 static void usage(void)
@@ -158,7 +159,10 @@
 
 
 	if (d[0])  {
- 		ll_init_map(&rth);
+		if (!link_cache) {
+ 		    ll_init_map(&rth);
+		    link_cache = 1;
+		}
 
 		if ((req.t.tcm_ifindex = ll_name_to_index(d)) == 0) {
 			fprintf(stderr, "Cannot find device \"%s\"\n", d);
diff -Naur iproute2-original/tc/tc_qdisc.c iproute2-patched/tc/tc_qdisc.c
--- iproute2-original/tc/tc_qdisc.c	2008-08-05 19:15:56.000000000 +0000
+++ iproute2-patched/tc/tc_qdisc.c	2008-08-06 09:53:11.000000000 +0000
@@ -25,6 +25,8 @@
 #include "tc_util.h"
 #include "tc_common.h"
 
+extern int link_cache;
+
 static int usage(void);
 
 static int usage(void)
@@ -145,7 +147,10 @@
 	if (d[0])  {
 		int idx;
 
- 		ll_init_map(&rth);
+		if (!link_cache) {
+ 		    ll_init_map(&rth);
+		    link_cache = 1;
+		}
 
 		if ((idx = ll_name_to_index(d)) == 0) {
 			fprintf(stderr, "Cannot find device \"%s\"\n", d);
@@ -272,7 +277,10 @@
 		argc--; argv++;
 	}
 
- 	ll_init_map(&rth);
+	if (!link_cache) {
+ 	    ll_init_map(&rth);
+	    link_cache = 1;
+	}
 
 	if (d[0]) {
 		if ((t.tcm_ifindex = ll_name_to_index(d)) == 0) {

--Boundary-00=_+tXmI8j9VImqiZj--
