From: Andreas Henriksson <andreas@fatal.se>
Subject: [PATCH] iproute2: add option to build m_xt as a tc module (v3)
Date: Mon, 12 Apr 2010 20:24:23 +0200
Message-ID: <20100412182423.GA5253@amd64.fatal.se>
References: <20100412115538.GA28338@amd64.fatal.se>
 <20100412083317.0d9e9f3f@nehalam>
 <20100412181359.GA4612@amd64.fatal.se>
 <20100412181943.GB4612@amd64.fatal.se>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: netdev@vger.kernel.org
To: Stephen Hemminger <shemminger@vyatta.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from smtprelay-h21.telenor.se ([195.54.99.196]:32951 "EHLO
	smtprelay-h21.telenor.se" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752751Ab0DLSWw (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 12 Apr 2010 14:22:52 -0400
Received: from ipb1.telenor.se (ipb1.telenor.se [195.54.127.164])
	by smtprelay-h21.telenor.se (Postfix) with ESMTP id 3AE7AEB7D3
	for <netdev@vger.kernel.org>; Mon, 12 Apr 2010 20:22:49 +0200 (CEST)
Content-Disposition: inline
In-Reply-To: <20100412181943.GB4612@amd64.fatal.se>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

This will build the xt module (action ipt) of tc as a
shared object that is linked at runtime by tc if used,
rather then built into tc.

This is similar to how the atm qdisc support
is handled (q_atm.so).

Signed-off-by: Andreas Henriksson <andreas@xxxxxxxx>

---

v3:
fix cut'n'paste problem in m_xt_old.so make rule. SORRY!

v2:
Updated to not be a configurable option, always
build as module.
Also build m_xt_old as module (untested!).
Give dlopen full path to modules rather then just filename.
Fix make install module destination directory problems (untested!).


diff --git a/tc/Makefile b/tc/Makefile
index 805c108..01a16fc 100644
--- a/tc/Makefile
+++ b/tc/Makefile
@@ -43,19 +43,20 @@ TCMODULES += em_cmp.o
 TCMODULES += em_u32.o
 TCMODULES += em_meta.o
 
+TCSO :=
+ifeq ($(TC_CONFIG_ATM),y)
+  TCSO += q_atm.so
+endif
 
 ifeq ($(TC_CONFIG_XT),y)
-  TCMODULES += m_xt.o
-  LDLIBS += -lxtables
+  TCSO += m_xt.so
 else
   ifeq ($(TC_CONFIG_XT_OLD),y)
-    TCMODULES += m_xt_old.o
-    LDLIBS += -lxtables
+    TCSO += m_xt_old.so
   else
     ifeq ($(TC_CONFIG_XT_OLD_H),y)
 	CFLAGS += -DTC_CONFIG_XT_H
-	TCMODULES += m_xt_old.o
-	LDLIBS += -lxtables
+	TCSO += m_xt_old.so
     else
       TCMODULES += m_ipt.o
     endif
@@ -81,14 +82,11 @@ ifneq ($(IPT_LIB_DIR),)
 	CFLAGS += -DIPT_LIB_DIR=\"$(IPT_LIB_DIR)\"
 endif
 
-TCSO :=
-ifeq ($(TC_CONFIG_ATM),y)
-  TCSO += q_atm.so
-endif
-
 YACC := bison
 LEX := flex
 
+MODDESTDIR := $(DESTDIR)$(patsubst /usr%,%,$(LIBDIR))/tc
+
 %.so: %.c
 	$(CC) $(CFLAGS) $(LDFLAGS) -shared -fpic $< -o $@
 
@@ -101,11 +99,18 @@ libtc.a: $(TCLIB)
 	$(AR) rcs $@ $(TCLIB)
 
 install: all
-	mkdir -p $(DESTDIR)$(LIBDIR)/tc
-	install -m 0755 tc $(DESTDIR)$(SBINDIR)
+	echo mkdir -p $(MODDESTDIR)
+	echo install -m 0755 tc $(DESTDIR)$(SBINDIR)
 	for i in $(TCSO); \
-	do install -m 755 $$i $(DESTDIR)$(LIBDIR)/tc; \
+	do echo install -m 755 $$i $(MODDESTDIR); \
 	done
+	if [ ! -f $(MODDESTDIR)/m_ipt.so ]; then \
+	if [ -f $(MODDESTDIR)/m_xt.so ]; \
+		then ln -s m_xt.so $(MODDESTDIR)/m_ipt.so ; \
+	elif [ -f $(MODDESTDIR)/m_xt_old.so ]; \
+		then ln -s m_xt_old.so $(MODDESTDIR)/m_ipt.so ; \
+	fi; \
+	fi
 
 clean:
 	rm -f $(TCOBJ) $(TCLIB) libtc.a tc *.so emp_ematch.yacc.h; \
@@ -114,6 +119,12 @@ clean:
 q_atm.so: q_atm.c
 	$(CC) $(CFLAGS) $(LDFLAGS) -shared -fpic -o q_atm.so q_atm.c -latm
 
+m_xt.so: m_xt.c
+	$(CC) $(CFLAGS) $(LDFLAGS) -shared -fpic -o m_xt.so m_xt.c -lxtables
+
+m_xt_old.so: m_xt_old.c
+	$(CC) $(CFLAGS) $(LDFLAGS) -shared -fpic -o m_xt_old.so m_xt_old.c -lxtables
+
 %.yacc.c: %.y
 	$(YACC) $(YACCFLAGS) -o $@ $<
 
diff --git a/tc/m_action.c b/tc/m_action.c
index 9f24022..a198158 100644
--- a/tc/m_action.c
+++ b/tc/m_action.c
@@ -98,7 +98,7 @@ restart_s:
 			return a;
 	}
 
-	snprintf(buf, sizeof(buf), "m_%s.so", str);
+	snprintf(buf, sizeof(buf), "%s/m_%s.so", get_tc_lib(), str);
 	dlh = dlopen(buf, RTLD_LAZY);
 	if (dlh == NULL) {
 		dlh = aBODY;
