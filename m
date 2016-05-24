From: David Ahern <dsa@cumulusnetworks.com>
Subject: [PATCH v2] Make builds default to quiet mode
Date: Tue, 24 May 2016 15:04:49 -0700
Message-ID: <1464127489-5232-1-git-send-email-dsa@cumulusnetworks.com>
Cc: David Ahern <dsa@cumulusnetworks.com>
To: netdev@vger.kernel.org, shemming@brocade.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-pf0-f169.google.com ([209.85.192.169]:35366 "EHLO
	mail-pf0-f169.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751284AbcEXWE4 (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 24 May 2016 18:04:56 -0400
Received: by mail-pf0-f169.google.com with SMTP id g64so11112732pfb.2
        for <netdev@vger.kernel.org>; Tue, 24 May 2016 15:04:56 -0700 (PDT)
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Similar to the Linux kernel and perf add infrastructure to reduce the
amount of output tossed to a user during a build. Full build output
can be obtained with 'make V=1'

Builds go from:

make[1]: Leaving directory `/home/dsa/iproute2.git/lib'
make[1]: Entering directory `/home/dsa/iproute2.git/ip'
gcc -Wall -Wstrict-prototypes  -Wmissing-prototypes -Wmissing-declarations -Wold-style-definition -Wformat=2 -O2 -I../include -DRESOLVE_HOSTNAMES -DLIBDIR=\"/usr/lib\" -DCONFDIR=\"/etc/iproute2\" -D_GNU_SOURCE -D_FILE_OFFSET_BITS=64 -D_LARGEFILE_SOURCE -D_LARGEFILE64_SOURCE    -c -o ip.o ip.c
gcc -Wall -Wstrict-prototypes  -Wmissing-prototypes -Wmissing-declarations -Wold-style-definition -Wformat=2 -O2 -I../include -DRESOLVE_HOSTNAMES -DLIBDIR=\"/usr/lib\" -DCONFDIR=\"/etc/iproute2\" -D_GNU_SOURCE -D_FILE_OFFSET_BITS=64 -D_LARGEFILE_SOURCE -D_LARGEFILE64_SOURCE    -c -o ipaddress.o ipaddress.c

to:

...
    AR       libutil.a

ip
    CC       ip.o
    CC       ipaddress.o
...

Signed-off-by: David Ahern <dsa@cumulusnetworks.com>
---
v2
- changed 'echo  "\n$$i"' to 'echo; echo $$i' per Andreas'
  comment

 Makefile         |  6 +++++-
 bridge/Makefile  |  1 +
 configure        | 32 ++++++++++++++++++++++++++++++++
 devlink/Makefile |  1 +
 genl/Makefile    |  1 +
 ip/Makefile      |  2 ++
 lib/Makefile     |  4 ++--
 misc/Makefile    | 12 +++++++-----
 tc/Makefile      | 15 ++++++++-------
 tipc/Makefile    |  1 +
 10 files changed, 60 insertions(+), 15 deletions(-)

diff --git a/Makefile b/Makefile
index eb571a5accf8..15c81ecfdca3 100644
--- a/Makefile
+++ b/Makefile
@@ -1,3 +1,7 @@
+ifndef VERBOSE
+MAKEFLAGS += --no-print-directory
+endif
+
 PREFIX?=/usr
 LIBDIR?=$(PREFIX)/lib
 SBINDIR?=/sbin
@@ -50,7 +54,7 @@ LDLIBS += $(LIBNETLINK)
 all: Config
 	@set -e; \
 	for i in $(SUBDIRS); \
-	do $(MAKE) $(MFLAGS) -C $$i; done
+	do echo; echo $$i; $(MAKE) $(MFLAGS) -C $$i; done
 
 Config:
 	sh configure $(KERNEL_INCLUDE)
diff --git a/bridge/Makefile b/bridge/Makefile
index 98007530240a..7203f70bc510 100644
--- a/bridge/Makefile
+++ b/bridge/Makefile
@@ -9,6 +9,7 @@ endif
 all: bridge
 
 bridge: $(BROBJ) $(LIBNETLINK) 
+	$(QUIET_LINK)$(CC) $^ $(LDFLAGS) $(LDLIBS) -o $@
 
 install: all
 	install -m 0755 bridge $(DESTDIR)$(SBINDIR)
diff --git a/configure b/configure
index d2540b0d3219..60eb6b51a571 100755
--- a/configure
+++ b/configure
@@ -317,7 +317,35 @@ EOF
     rm -f $TMPDIR/dbtest.c $TMPDIR/dbtest
 }
 
+quiet_config()
+{
+	cat <<EOF
+# user can control verbosity similar to kernel builds (e.g., V=1)
+ifeq ("\$(origin V)", "command line")
+  VERBOSE = \$(V)
+endif
+ifndef VERBOSE
+  VERBOSE = 0
+endif
+ifeq (\$(VERBOSE),1)
+  Q =
+else
+  Q = @
+endif
+
+ifeq (\$(VERBOSE), 0)
+    QUIET_CC       = @echo '    CC       '\$@;
+    QUIET_AR       = @echo '    AR       '\$@;
+    QUIET_LINK     = @echo '    LINK     '\$@;
+    QUIET_YACC     = @echo '    YACC     '\$@;
+    QUIET_LEX      = @echo '    LEX      '\$@;
+endif
+EOF
+}
+
 echo "# Generated config based on" $INCLUDE >Config
+quiet_config >> Config
+
 check_toolchain
 
 echo "TC schedulers"
@@ -357,3 +385,7 @@ echo
 echo -n "docs:"
 check_docs
 echo
+
+echo >> Config
+echo "%.o: %.c" >> Config
+echo '	$(QUIET_CC)$(CC) $(CFLAGS) $(EXTRA_CFLAGS) -c -o $@ $<' >> Config
diff --git a/devlink/Makefile b/devlink/Makefile
index 3fdaa6904ee1..7256c28708eb 100644
--- a/devlink/Makefile
+++ b/devlink/Makefile
@@ -12,6 +12,7 @@ endif
 all: $(TARGETS) $(LIBS)
 
 devlink: $(DEVLINKOBJ)
+	$(QUIET_LINK)$(CC) $^ $(LDFLAGS) $(LDLIBS) -o $@
 
 install: all
 	install -m 0755 $(TARGETS) $(DESTDIR)$(SBINDIR)
diff --git a/genl/Makefile b/genl/Makefile
index 03d1f26a1cee..f5a0bfe42aff 100644
--- a/genl/Makefile
+++ b/genl/Makefile
@@ -20,6 +20,7 @@ endif
 all: genl
 
 genl: $(GENLOBJ) $(LIBNETLINK) $(LIBUTIL) $(GENLLIB)
+	$(QUIET_LINK)$(CC) $^ $(LDFLAGS) $(LDLIBS) -o $@
 
 install: all
 	install -m 0755 genl $(DESTDIR)$(SBINDIR)
diff --git a/ip/Makefile b/ip/Makefile
index f3d298739cac..a7f9c1101798 100644
--- a/ip/Makefile
+++ b/ip/Makefile
@@ -24,8 +24,10 @@ TARGETS=ip rtmon
 all: $(TARGETS) $(SCRIPTS)
 
 ip: $(IPOBJ) $(LIBNETLINK)
+	$(QUIET_LINK)$(CC) $^ $(LDFLAGS) $(LDLIBS) -o $@
 
 rtmon: $(RTMONOBJ)
+	$(QUIET_LINK)$(CC) $^ $(LDFLAGS) $(LDLIBS) -o $@
 
 install: all
 	install -m 0755 $(TARGETS) $(DESTDIR)$(SBINDIR)
diff --git a/lib/Makefile b/lib/Makefile
index 9d1307dd4df2..52e016db50b6 100644
--- a/lib/Makefile
+++ b/lib/Makefile
@@ -15,10 +15,10 @@ NLOBJ=libgenl.o ll_map.o libnetlink.o
 all: libnetlink.a libutil.a
 
 libnetlink.a: $(NLOBJ)
-	$(AR) rcs $@ $(NLOBJ)
+	$(QUIET_AR)$(AR) rcs $@ $^
 
 libutil.a: $(UTILOBJ) $(ADDLIB)
-	$(AR) rcs $@ $(UTILOBJ) $(ADDLIB)
+	$(QUIET_AR)$(AR) rcs $@ $^
 
 install:
 
diff --git a/misc/Makefile b/misc/Makefile
index f50e7403a33b..72807678054b 100644
--- a/misc/Makefile
+++ b/misc/Makefile
@@ -21,23 +21,25 @@ endif
 all: $(TARGETS)
 
 ss: $(SSOBJ)
+	$(QUIET_LINK)$(CC) $^ $(LDFLAGS) $(LDLIBS) -o $@
 
 nstat: nstat.c
-	$(CC) $(CFLAGS) $(LDFLAGS) -o nstat nstat.c $(LIBNETLINK) -lm
+	$(QUIET_CC)$(CC) $(CFLAGS) $(LDFLAGS) -o nstat nstat.c $(LIBNETLINK) -lm
 
 ifstat: ifstat.c
-	$(CC) $(CFLAGS) $(LDFLAGS) -o ifstat ifstat.c $(LIBNETLINK) -lm
+	$(QUIET_CC)$(CC) $(CFLAGS) $(LDFLAGS) -o ifstat ifstat.c $(LIBNETLINK) -lm
 
 rtacct: rtacct.c
-	$(CC) $(CFLAGS) $(LDFLAGS) -o rtacct rtacct.c $(LIBNETLINK) -lm
+	$(QUIET_CC)$(CC) $(CFLAGS) $(LDFLAGS) -o rtacct rtacct.c $(LIBNETLINK) -lm
 
 arpd: arpd.c
-	$(CC) $(CFLAGS) -I$(DBM_INCLUDE) $(LDFLAGS) -o arpd arpd.c $(LIBNETLINK) -ldb -lpthread
+	$(QUIET_CC)$(CC) $(CFLAGS) -I$(DBM_INCLUDE) $(LDFLAGS) -o arpd arpd.c $(LIBNETLINK) -ldb -lpthread
 
 ssfilter.c: ssfilter.y
-	bison ssfilter.y -o ssfilter.c
+	$(QUIET_YACC)bison ssfilter.y -o ssfilter.c
 
 lnstat: $(LNSTATOBJ)
+	$(QUIET_LINK)$(CC) $^ $(LDFLAGS) $(LDLIBS) -o $@
 
 install: all
 	install -m 0755 $(TARGETS) $(DESTDIR)$(SBINDIR)
diff --git a/tc/Makefile b/tc/Makefile
index 20f51100047a..42747c517ee1 100644
--- a/tc/Makefile
+++ b/tc/Makefile
@@ -125,15 +125,16 @@ CFLAGS += -DYY_NO_INPUT
 MODDESTDIR := $(DESTDIR)$(LIBDIR)/tc
 
 %.so: %.c
-	$(CC) $(CFLAGS) $(LDFLAGS) -shared -fpic $< -o $@
+	$(QUIET_CC)$(CC) $(CFLAGS) $(LDFLAGS) -shared -fpic $< -o $@
 
 
 all: libtc.a tc $(TCSO)
 
 tc: $(TCOBJ) $(TCLIB)
+	$(QUIET_LINK)$(CC) $^ $(LDFLAGS) $(LDLIBS) -o $@
 
 libtc.a: $(TCLIB)
-	$(AR) rcs $@ $(TCLIB)
+	$(QUIET_AR)$(AR) rcs $@ $(TCLIB)
 
 install: all
 	mkdir -p $(MODDESTDIR)
@@ -154,21 +155,21 @@ install: all
 	rm -f emp_ematch.yacc.*
 
 q_atm.so: q_atm.c
-	$(CC) $(CFLAGS) $(LDFLAGS) -shared -fpic -o q_atm.so q_atm.c -latm
+	$(QUIET_CC)$(CC) $(CFLAGS) $(LDFLAGS) -shared -fpic -o q_atm.so q_atm.c -latm
 
 m_xt.so: m_xt.c
-	$(CC) $(CFLAGS) $(LDFLAGS) -shared -fpic -o m_xt.so m_xt.c $$($(PKG_CONFIG) xtables --cflags --libs)
+	$(QUIET_CC)$(CC) $(CFLAGS) $(LDFLAGS) -shared -fpic -o m_xt.so m_xt.c $$($(PKG_CONFIG) xtables --cflags --libs)
 
 m_xt_old.so: m_xt_old.c
-	$(CC) $(CFLAGS) $(LDFLAGS) -shared -fpic -o m_xt_old.so m_xt_old.c $$($(PKG_CONFIG) xtables --cflags --libs)
+	$(QUIET_CC)$(CC) $(CFLAGS) $(LDFLAGS) -shared -fpic -o m_xt_old.so m_xt_old.c $$($(PKG_CONFIG) xtables --cflags --libs)
 
 em_ipset.o: CFLAGS += $$($(PKG_CONFIG) xtables --cflags)
 
 %.yacc.c: %.y
-	$(YACC) $(YACCFLAGS) -o $@ $<
+	$(QUIET_YACC)$(YACC) $(YACCFLAGS) -o $@ $<
 
 %.lex.c: %.l
-	$(LEX) $(LEXFLAGS) -o$@ $<
+	$(QUIET_LEX)$(LEX) $(LEXFLAGS) -o$@ $<
 
 # our lexer includes the header from yacc, so make sure
 # we don't attempt to compile it before the header has
diff --git a/tipc/Makefile b/tipc/Makefile
index bc5ecfd37518..868d13abf511 100644
--- a/tipc/Makefile
+++ b/tipc/Makefile
@@ -19,6 +19,7 @@ endif
 all: $(TARGETS) $(LIBS)
 
 tipc: $(TIPCOBJ)
+	$(QUIET_LINK)$(CC) $^ $(LDFLAGS) $(LDLIBS) -o $@
 
 install: all
 	install -m 0755 $(TARGETS) $(DESTDIR)$(SBINDIR)
-- 
2.1.4
