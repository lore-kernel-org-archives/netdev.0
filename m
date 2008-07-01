From: Denys Fedoryshchenko <denys@visp.net.lb>
Subject: iproute2 / xtables / undefined symbol in m_ipt again
Date: Tue, 1 Jul 2008 18:54:00 +0300
Message-ID: <200807011854.00319.denys@visp.net.lb>
Mime-Version: 1.0
Content-Type: Multipart/Mixed;
  boundary="Boundary-00=_YMlaITao++tnU0r"
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from relay2.globalproof.net ([194.146.153.25]:40321 "EHLO
	relay2.globalproof.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752187AbYGAPyC (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 1 Jul 2008 11:54:02 -0400
Received: from localhost (unknown [195.69.208.251])
	by relay2.globalproof.net (Postfix) with ESMTP id 4E8F3130422
	for <netdev@vger.kernel.org>; Tue,  1 Jul 2008 18:54:00 +0300 (EEST)
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

--Boundary-00=_YMlaITao++tnU0r
Content-Type: text/plain;
  charset="us-ascii"
Content-Transfer-Encoding: 7bit
Content-Disposition: inline

After building git iproute2 and trying to use with iptables 1.4.1.1 i notice error.

/sbin/tc: symbol lookup error: /lib/iptables/libxt_MARK.so: undefined symbol: param_act

I remember that many functions "stolen" from iptables source. It is defined in iptables package, in xtables.h, but ugly thing, 
all this functions not available over some shared library, but available in xtables.o, which is linked statically with many iptables binaries on build time.
No idea, why they didn't make it dynamic, and as result reduce binaries size? And also they can make by that life for m_ipt.c MUCH easier (and binary smaller too).

There is two ways to fix it:
1)Easiest and ugliest. Add all missing functions there, it works and tested. Patch attached.
2)Tricky. Get xtables.c from iptables build, add to iproute2 binaries and link with m_ipt
3)Normal. Someone must talk with iptables guys to make xtables.c as shared library. It will remove all headache with updating m_ipt and 
  incompatibility with different/new iptables versions.

-- 
------
Technical Manager
Virtual ISP S.A.L.
Lebanon

--Boundary-00=_YMlaITao++tnU0r
Content-Type: text/x-diff;
  charset="us-ascii";
  name="iproute2-01052008-git.patch"
Content-Transfer-Encoding: 7bit
Content-Disposition: attachment;
	filename="iproute2-01052008-git.patch"

diff -Naur iproute2-ok/include/iptables_common.h iproute2/include/iptables_common.h
--- iproute2-ok/include/iptables_common.h	2008-07-01 18:28:41.000000000 +0300
+++ iproute2/include/iptables_common.h	2008-07-01 18:39:11.000000000 +0300
@@ -3,10 +3,14 @@
 /* Shared definitions between ipv4 and ipv6. */
 
 enum exittype {
-	OTHER_PROBLEM = 1,
-	PARAMETER_PROBLEM,
-	VERSION_PROBLEM,
-	RESOURCE_PROBLEM
+        OTHER_PROBLEM = 1,
+        PARAMETER_PROBLEM,
+        VERSION_PROBLEM,
+        RESOURCE_PROBLEM,
+        P_ONLY_ONCE,
+        P_NO_INVERT,
+        P_BAD_VALUE,
+        P_ONE_ACTION,
 };
 
 /* this is a special 64bit data type that is 8-byte aligned */
diff -Naur iproute2-ok/tc/m_ipt.c iproute2/tc/m_ipt.c
--- iproute2-ok/tc/m_ipt.c	2008-07-01 18:28:41.000000000 +0300
+++ iproute2/tc/m_ipt.c	2008-07-01 18:42:59.000000000 +0300
@@ -22,6 +22,7 @@
 #include "tc_util.h"
 #include <linux/tc_act/tc_ipt.h>
 #include <stdio.h>
+#include <stdbool.h>
 #include <dlfcn.h>
 #include <getopt.h>
 #include <errno.h>
@@ -59,6 +60,91 @@
 
 char *lib_dir;
 
+bool strtonuml(const char *s, char **end, unsigned long *value,
+               unsigned long min, unsigned long max)
+{
+        unsigned long v;
+        char *my_end;
+
+        errno = 0;
+        v = strtoul(s, &my_end, 0);
+
+        if (my_end == s)
+                return false;
+        if (end != NULL)
+                *end = my_end;
+
+        if (errno != ERANGE && min <= v && (max == 0 || v <= max)) {
+                if (value != NULL)
+                        *value = v;
+                if (end == NULL)
+                        return *my_end == '\0';
+                return true;
+        }
+
+        return false;
+}
+
+bool strtonum(const char *s, char **end, unsigned int *value,
+                  unsigned int min, unsigned int max)
+{
+        unsigned long v;
+        bool ret;
+
+        ret = strtonuml(s, end, &v, min, max);
+        if (value != NULL)
+                *value = v;
+        return ret;
+}
+
+void param_act(unsigned int status, const char *p1, ...)
+{
+        const char *p2, *p3;
+        va_list args;
+        bool b;
+
+        va_start(args, p1);
+
+        switch (status) {
+        case P_ONLY_ONCE:
+                p2 = va_arg(args, const char *);
+                b  = va_arg(args, unsigned int);
+                if (!b)
+                        return;
+                exit_error(PARAMETER_PROBLEM,
+                           "%s: \"%s\" option may only be specified once",
+                           p1, p2);
+                break;
+        case P_NO_INVERT:
+                p2 = va_arg(args, const char *);
+                b  = va_arg(args, unsigned int);
+                if (!b)
+                        return;
+                exit_error(PARAMETER_PROBLEM,
+                           "%s: \"%s\" option cannot be inverted", p1, p2);
+                break;
+        case P_BAD_VALUE:
+                p2 = va_arg(args, const char *);
+                p3 = va_arg(args, const char *);
+                exit_error(PARAMETER_PROBLEM,
+                           "%s: Bad value for \"%s\" option: \"%s\"",
+                           p1, p2, p3);
+                break;
+        case P_ONE_ACTION:
+                b = va_arg(args, unsigned int);
+                if (!b)
+                        return;
+                exit_error(PARAMETER_PROBLEM,
+                           "%s: At most one action is possible", p1);
+                break;
+        default:
+                exit_error(status, p1, args);
+                break;
+        }
+
+        va_end(args);
+}
+
 void
 register_target(struct iptables_target *me)
 {

--Boundary-00=_YMlaITao++tnU0r--
