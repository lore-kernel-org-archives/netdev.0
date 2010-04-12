From: Andreas Henriksson <andreas@fatal.se>
Subject: [PATCH] iproute2: add option to build m_xt as a tc module.
Date: Mon, 12 Apr 2010 13:55:38 +0200
Message-ID: <20100412115538.GA28338@amd64.fatal.se>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: netdev@vger.kernel.org
To: shemminger@vyatta.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from smtprelay-h12.telenor.se ([62.127.194.5]:60762 "EHLO
	smtprelay-h12.telenor.se" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1753374Ab0DLLyJ (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 12 Apr 2010 07:54:09 -0400
Received: from ipb2.telenor.se (ipb2.telenor.se [195.54.127.165])
	by smtprelay-h12.telenor.se (Postfix) with ESMTP id 6609BC622
	for <netdev@vger.kernel.org>; Mon, 12 Apr 2010 13:54:39 +0200 (CEST)
Content-Disposition: inline
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Add TC_CONFIG_XT_MODULE option that can be added
either to Config (after ./configure) or as an argument to "make".

This will build the xt module (action ipt) of tc as a
shared object that is linked at runtime by tc if used,
rather then built into tc.

This is similar to how the atm qdisc support
is handled (q_atm.so).

Signed-off-by: Andreas Henriksson <andreas@fatal.se>

---

The reason for this is simply to be able to avoid
the tc binary from being linked to libxtables. This way
distributions who ship binary packages can
avoid a dependency on the iptables package by
ignoring m_xt.so in the dependency analysis
and let actual users of the tc arguments "action ipt"
make sure they have iptables installed.
(See http://bugs.debian.org/576953 )

This was not a problem with the old/deprecated
m_ipt module which did runtime linking of
the iptables library.

Having the split inside tc, rather then between tc and the required
library, is preferred. This way we'll notice at build-time
when the required library breaks API/ABI rather
then having to rely on people that uses the functionality
to report back when the ABI is broken.
(We've learned this the hard way in debian after many
angry bugreports.)

I've had jamal pre-review this and he didn't see any
problems with this.


diff --git a/tc/Makefile b/tc/Makefile
index 805c108..3af33cf 100644
--- a/tc/Makefile
+++ b/tc/Makefile
@@ -43,10 +43,18 @@ TCMODULES += em_cmp.o
 TCMODULES += em_u32.o
 TCMODULES += em_meta.o
 
+TCSO :=
+ifeq ($(TC_CONFIG_ATM),y)
+  TCSO += q_atm.so
+endif
 
 ifeq ($(TC_CONFIG_XT),y)
-  TCMODULES += m_xt.o
-  LDLIBS += -lxtables
+  ifeq ($(TC_CONFIG_XT_MODULE),y)
+    TCSO += m_xt.so
+  else
+    TCMODULES += m_xt.o
+    LDLIBS += -lxtables
+  endif
 else
   ifeq ($(TC_CONFIG_XT_OLD),y)
     TCMODULES += m_xt_old.o
@@ -81,11 +89,6 @@ ifneq ($(IPT_LIB_DIR),)
 	CFLAGS += -DIPT_LIB_DIR=\"$(IPT_LIB_DIR)\"
 endif
 
-TCSO :=
-ifeq ($(TC_CONFIG_ATM),y)
-  TCSO += q_atm.so
-endif
-
 YACC := bison
 LEX := flex
 
@@ -114,6 +117,9 @@ clean:
 q_atm.so: q_atm.c
 	$(CC) $(CFLAGS) $(LDFLAGS) -shared -fpic -o q_atm.so q_atm.c -latm
 
+m_xt.so: m_xt.c
+	$(CC) $(CFLAGS) $(LDFLAGS) -shared -fpic -o m_xt.so m_xt.c -lxtables
+
 %.yacc.c: %.y
 	$(YACC) $(YACCFLAGS) -o $@ $<
 
