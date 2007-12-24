From: "Denys Fedoryshchenko" <denys@visp.net.lb>
Subject: [PATCH] [IPROUTE2] Compatibility with iptables 1.4.0
Date: Mon, 24 Dec 2007 18:07:38 +0200
Message-ID: <20071224160739.M84357@visp.net.lb>
Mime-Version: 1.0
Content-Type: text/plain;
	charset=koi8-r
Cc: netdev@vger.kernel.org
To: hadi@cyberus.ca
Return-path: <netdev-owner@vger.kernel.org>
Received: from usermail.globalproof.net ([194.146.153.18]:58312 "EHLO
	usermail.globalproof.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1750842AbXLXQH6 (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 24 Dec 2007 11:07:58 -0500
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Hi, probably like this will be better?
Previous patch was not backward compatible.

Btw i checked twice, name is changed from libipt_MARK to libxt_MARK. So
probably when you have tested this, your iproute2 was looking to old
libipt_MARK (iptables is not deleting old libraries on make install).

-------------------------

New iptables 1.4.0 need additional dummy functions, and some library names is
changed from libipt to libxt.
It is prefferable also to open libxt_ first, as newer "style".

Signed-off-by: Denys Fedoryshchenko <nuclearcat@nuclearcat.com>
---
 drivers/watchdog/w83697hf_wdt.c |    4 +++-
 1 files changed, 3 insertions(+), 1 deletions(-)
diff -Naur iproute2/tc/m_ipt.c iproute2-new/tc/m_ipt.c
--- iproute2/tc/m_ipt.c     2007-12-24 16:59:19.000000000 +0200
+++ iproute2-new/tc/m_ipt.c     2007-12-24 17:46:14.000000000 +0200
@@ -69,6 +69,27 @@
 }

 void
+xtables_register_target(struct iptables_target *me)
+{
+       me->next = t_list;
+       t_list = me;
+}
+
+
+void
+xtables_register_match(struct iptables_target *me)
+{
+       me->next = t_list;
+       t_list = me;
+}
+
+void
 exit_tryhelp(int status)
 {
        fprintf(stderr, "Try `%s -h' or '%s --help' for more information.\n",
@@ -248,16 +269,25 @@
                }
        }

-       sprintf(path,  "%s/libipt_%s.so",lib_dir, new_name);
+       sprintf(path,  "%s/libxt_%s.so",lib_dir, new_name);
        handle = dlopen(path, RTLD_LAZY);
        if (!handle) {
-               sprintf(path, lib_dir, "/libipt_%s.so", lname);
+               sprintf(path, "%s/libipt_%s.so", lib_dir , new_name);
                handle = dlopen(path, RTLD_LAZY);
-               if (!handle) {
-                       fputs(dlerror(), stderr);
-                       printf("\n");
-                       return NULL;
-               }
+       }
+       if (!handle) {
+               sprintf(path, "%s/libxt_%s.so", lib_dir , lname);
+               handle = dlopen(path, RTLD_LAZY);
+       }
+       if (!handle) {
+               sprintf(path, "%s/libipt_%s.so", lib_dir , lname);
+               handle = dlopen(path, RTLD_LAZY);
+       }
+       if (!handle) {
+               sprintf(path, "%s/libipt_%s.so", lib_dir , lname);
+               fputs(dlerror(), stderr);
+               printf("\n");
+               return NULL;
        }

        m = dlsym(handle, new_name);


--
Denys Fedoryshchenko
Technical Manager
Virtual ISP S.A.L.

