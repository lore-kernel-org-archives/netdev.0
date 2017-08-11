From: Stephen Hemminger <stephen@networkplumber.org>
Subject: [PATCH iproute2 net-next] config: put CFLAGS/LDLIBS in config.mk
Date: Thu, 10 Aug 2017 17:10:03 -0700
Message-ID: <20170811001003.8595-1-stephen@networkplumber.org>
Cc: Stephen Hemminger <stephen@networkplumber.org>
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-pf0-f182.google.com ([209.85.192.182]:36057 "EHLO
        mail-pf0-f182.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1750841AbdHKAKN (ORCPT
        <rfc822;netdev@vger.kernel.org>); Thu, 10 Aug 2017 20:10:13 -0400
Received: by mail-pf0-f182.google.com with SMTP id c28so9150672pfe.3
        for <netdev@vger.kernel.org>; Thu, 10 Aug 2017 17:10:12 -0700 (PDT)
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

This renames Config to config.mk and includes more Make input.
Now configure generates all the required CFLAGS and LDLIBS for
the optional libraries.

Also, use pkg-config to test for libelf, rather than using a test
program. This makes it consistent with other libraries.

Signed-off-by: Stephen Hemminger <stephen@networkplumber.org>
---
 .gitignore       |  1 -
 Makefile         |  8 +++---
 README           |  5 ++--
 bridge/Makefile  | 11 +-------
 configure        | 81 ++++++++++++++++++++++++++++----------------------------
 devlink/Makefile |  3 ++-
 genl/Makefile    |  7 +----
 ip/Makefile      | 15 +----------
 lib/Makefile     | 14 +---------
 misc/Makefile    | 16 +----------
 netem/Makefile   |  7 +----
 tc/Makefile      | 15 +----------
 tipc/Makefile    |  5 ++--
 13 files changed, 59 insertions(+), 129 deletions(-)

diff --git a/.gitignore b/.gitignore
index c3b8d386450b..308aec6ba80b 100644
--- a/.gitignore
+++ b/.gitignore
@@ -1,6 +1,5 @@
 static-syms.h
 config.*
-Config
 *.o
 *.a
 *.so
diff --git a/Makefile b/Makefile
index 1f88f7f56691..b0ea6794285c 100644
--- a/Makefile
+++ b/Makefile
@@ -54,12 +54,12 @@ SUBDIRS=lib ip tc bridge misc netem genl tipc devlink man
 LIBNETLINK=../lib/libnetlink.a ../lib/libutil.a
 LDLIBS += $(LIBNETLINK)
 
-all: Config
+all: config.mk
 	@set -e; \
 	for i in $(SUBDIRS); \
 	do echo; echo $$i; $(MAKE) $(MFLAGS) -C $$i; done
 
-Config:
+config.mk:
 	sh configure $(KERNEL_INCLUDE)
 
 install: all
@@ -88,9 +88,9 @@ clean:
 	do $(MAKE) $(MFLAGS) -C $$i clean; done
 
 clobber:
-	touch Config
+	touch config.mk
 	$(MAKE) $(MFLAGS) clean
-	rm -f Config cscope.*
+	rm -f config.mk cscope.*
 
 distclean: clobber
 
diff --git a/README b/README
index c7a5118dd6d0..386fbaf6cf7d 100644
--- a/README
+++ b/README
@@ -21,8 +21,9 @@ database routines.  Often this is in the db-devel package.
 
 2. make
 
-The makefile will automatically build a Config file which
-contains whether or not ATM is available, etc.
+The makefile will automatically build a config.mk file which
+contains definitions of libraries that may or may not be available
+on the system such as: ATM, ELF, MNL, and SELINUX.
 
 3. To make documentation, cd to doc/ directory , then
    look at start of Makefile and set correct values for
diff --git a/bridge/Makefile b/bridge/Makefile
index fa448ea2e4fa..b2ae0a4ed04d 100644
--- a/bridge/Makefile
+++ b/bridge/Makefile
@@ -1,15 +1,6 @@
 BROBJ = bridge.o fdb.o monitor.o link.o mdb.o vlan.o
 
-include ../Config
-
-ifeq ($(IP_CONFIG_SETNS),y)
-	CFLAGS += -DHAVE_SETNS
-endif
-
-ifeq ($(HAVE_MNL),y)
-	CFLAGS += -DHAVE_LIBMNL $(shell $(PKG_CONFIG) libmnl --cflags)
-	LDLIBS += $(shell $(PKG_CONFIG) libmnl --libs)
-endif
+include ../config.mk
 
 all: bridge
 
diff --git a/configure b/configure
index 88cbdb825689..7be8fb113cc9 100755
--- a/configure
+++ b/configure
@@ -3,6 +3,9 @@
 #
 INCLUDE=${1:-"$PWD/include"}
 
+# Output file which is input to Makefile
+CONFIG=config.mk
+
 # Make a temp directory in build tree.
 TMPDIR=$(mktemp -d config.XXXXXX)
 trap 'status=$?; rm -rf $TMPDIR; exit $status' EXIT HUP INT QUIT TERM
@@ -10,7 +13,7 @@ trap 'status=$?; rm -rf $TMPDIR; exit $status' EXIT HUP INT QUIT TERM
 check_prog()
 {
     echo -n "$2"
-    command -v $1 >/dev/null 2>&1 && (echo "$3:=y" >> Config; echo "yes") || (echo "no"; return 1)
+    command -v $1 >/dev/null 2>&1 && (echo "$3:=y" >> $CONFIG; echo "yes") || (echo "no"; return 1)
 }
 
 check_docs()
@@ -30,9 +33,9 @@ check_toolchain()
     : ${PKG_CONFIG:=pkg-config}
     : ${AR=ar}
     : ${CC=gcc}
-    echo "PKG_CONFIG:=${PKG_CONFIG}" >>Config
-    echo "AR:=${AR}" >>Config
-    echo "CC:=${CC}" >>Config
+    echo "PKG_CONFIG:=${PKG_CONFIG}" >>$CONFIG
+    echo "AR:=${AR}" >>$CONFIG
+    echo "CC:=${CC}" >>$CONFIG
 }
 
 check_atm()
@@ -49,7 +52,7 @@ EOF
     $CC -I$INCLUDE -o $TMPDIR/atmtest $TMPDIR/atmtest.c -latm >/dev/null 2>&1
     if [ $? -eq 0 ]
     then
-	echo "TC_CONFIG_ATM:=y" >>Config
+	echo "TC_CONFIG_ATM:=y" >>$CONFIG
 	echo yes
     else
 	echo no
@@ -61,7 +64,7 @@ check_xtables()
 {
 	if ! ${PKG_CONFIG} xtables --exists
 	then
-		echo "TC_CONFIG_NO_XT:=y" >>Config
+		echo "TC_CONFIG_NO_XT:=y" >>$CONFIG
 	fi
 }
 
@@ -90,7 +93,7 @@ EOF
     if $CC -I$INCLUDE $IPTC -o $TMPDIR/ipttest $TMPDIR/ipttest.c $IPTL \
 	$(${PKG_CONFIG} xtables --cflags --libs) -ldl >/dev/null 2>&1
     then
-	echo "TC_CONFIG_XT:=y" >>Config
+	echo "TC_CONFIG_XT:=y" >>$CONFIG
 	echo "using xtables"
     fi
     rm -f $TMPDIR/ipttest.c $TMPDIR/ipttest
@@ -99,7 +102,7 @@ EOF
 check_xt_old()
 {
     # bail if previous XT checks has already succeded.
-    if grep -q TC_CONFIG_XT Config
+    if grep -q TC_CONFIG_XT $CONFIG
     then
 	return
     fi
@@ -129,7 +132,7 @@ EOF
     $CC -I$INCLUDE $IPTC -o $TMPDIR/ipttest $TMPDIR/ipttest.c $IPTL -ldl >/dev/null 2>&1
     if [ $? -eq 0 ]
     then
-	echo "TC_CONFIG_XT_OLD:=y" >>Config
+	echo "TC_CONFIG_XT_OLD:=y" >>$CONFIG
 	echo "using old xtables (no need for xt-internal.h)"
     fi
     rm -f $TMPDIR/ipttest.c $TMPDIR/ipttest
@@ -138,7 +141,7 @@ EOF
 check_xt_old_internal_h()
 {
     # bail if previous XT checks has already succeded.
-    if grep -q TC_CONFIG_XT Config
+    if grep -q TC_CONFIG_XT $CONFIG
     then
 	return
     fi
@@ -170,14 +173,14 @@ EOF
 	if [ $? -eq 0 ]
 	then
 	    echo "using old xtables with xt-internal.h"
-	    echo "TC_CONFIG_XT_OLD_H:=y" >>Config
+	    echo "TC_CONFIG_XT_OLD_H:=y" >>$CONFIG
 	fi
 	rm -f $TMPDIR/ipttest.c $TMPDIR/ipttest
 }
 
 check_ipt()
 {
-	if ! grep TC_CONFIG_XT Config > /dev/null
+	if ! grep TC_CONFIG_XT $CONFIG > /dev/null
 	then
 		echo "using iptables"
 	fi
@@ -188,7 +191,7 @@ check_ipt_lib_dir()
 	IPT_LIB_DIR=$(${PKG_CONFIG} --variable=xtlibdir xtables)
 	if [ -n "$IPT_LIB_DIR" ]; then
 		echo $IPT_LIB_DIR
-		echo "IPT_LIB_DIR:=$IPT_LIB_DIR" >> Config
+		echo "IPT_LIB_DIR:=$IPT_LIB_DIR" >> $CONFIG
 		return
 	fi
 
@@ -197,7 +200,7 @@ check_ipt_lib_dir()
 		for file in $dir/{xtables,iptables}/lib*t_*so ; do
 			if [ -f $file ]; then
 				echo ${file%/*}
-				echo "IPT_LIB_DIR:=${file%/*}" >> Config
+				echo "IPT_LIB_DIR:=${file%/*}" >> $CONFIG
 				return
 			fi
 		done
@@ -218,8 +221,9 @@ EOF
     $CC -I$INCLUDE -o $TMPDIR/setnstest $TMPDIR/setnstest.c >/dev/null 2>&1
     if [ $? -eq 0 ]
     then
-	echo "IP_CONFIG_SETNS:=y" >>Config
+	echo "IP_CONFIG_SETNS:=y" >>$CONFIG
 	echo "yes"
+	echo "CFLAGS += -DHAVE_SETNS" >>$CONFIG
     else
 	echo "no"
     fi
@@ -249,7 +253,7 @@ EOF
 
     if $CC -I$INCLUDE -o $TMPDIR/ipsettest $TMPDIR/ipsettest.c >/dev/null 2>&1
     then
-	echo "TC_CONFIG_IPSET:=y" >>Config
+	echo "TC_CONFIG_IPSET:=y" >>$CONFIG
 	echo "yes"
     else
 	echo "no"
@@ -259,25 +263,16 @@ EOF
 
 check_elf()
 {
-    cat >$TMPDIR/elftest.c <<EOF
-#include <libelf.h>
-#include <gelf.h>
-int main(void)
-{
-	Elf_Scn *scn __attribute__((__unused__));
-	GElf_Shdr shdr  __attribute__((__unused__));;
-	return elf_version(EV_CURRENT);
-}
-EOF
-
-    if $CC -I$INCLUDE -o $TMPDIR/elftest $TMPDIR/elftest.c -lelf >/dev/null 2>&1
+    if ${PKG_CONFIG} libelf --exists
     then
-	echo "HAVE_ELF:=y" >>Config
+	echo "HAVE_ELF:=y" >>$CONFIG
 	echo "yes"
+
+	echo 'CFLAGS += -DHAVE_ELF' `${PKG_CONFIG} libelf --cflags` >> $CONFIG
+	echo 'LDLIBS += ' `${PKG_CONFIG} libelf --libs` >>$CONFIG
     else
 	echo "no"
     fi
-    rm -f $TMPDIR/elftest.c $TMPDIR/elftest
 }
 
 check_selinux()
@@ -285,8 +280,11 @@ check_selinux()
 {
 	if ${PKG_CONFIG} libselinux --exists
 	then
-		echo "HAVE_SELINUX:=y" >>Config
+		echo "HAVE_SELINUX:=y" >>$CONFIG
 		echo "yes"
+
+		echo 'LDLIBS +=' `${PKG_CONFIG} --libs libselinux` >>$CONFIG
+		echo 'CFLAGS += -DHAVE_SELINUX' `${PKG_CONFIG} --cflags libselinux` >>$CONFIG
 	else
 		echo "no"
 	fi
@@ -296,8 +294,11 @@ check_mnl()
 {
 	if ${PKG_CONFIG} libmnl --exists
 	then
-		echo "HAVE_MNL:=y" >>Config
+		echo "HAVE_MNL:=y" >>$CONFIG
 		echo "yes"
+
+		echo 'CFLAGS += -DHAVE_LIBMNL' `${PKG_CONFIG} libmnl --cflags` >>$CONFIG
+		echo 'LDLIBS +=' `${PKG_CONFIG} libmnl --libs` >> $CONFIG
 	else
 		echo "no"
 	fi
@@ -317,7 +318,7 @@ EOF
     $CC -I$INCLUDE -o $TMPDIR/dbtest $TMPDIR/dbtest.c -ldb >/dev/null 2>&1
     if [ $? -eq 0 ]
     then
-	echo "HAVE_BERKELEY_DB:=y" >>Config
+	echo "HAVE_BERKELEY_DB:=y" >>$CONFIG
 	echo "yes"
     else
 	echo "no"
@@ -351,8 +352,8 @@ endif
 EOF
 }
 
-echo "# Generated config based on" $INCLUDE >Config
-quiet_config >> Config
+echo "# Generated config based on" $INCLUDE >$CONFIG
+quiet_config >> $CONFIG
 
 check_toolchain
 
@@ -362,7 +363,7 @@ echo -n " ATM	"
 check_atm
 
 check_xtables
-if ! grep -q TC_CONFIG_NO_XT Config
+if ! grep -q TC_CONFIG_NO_XT $CONFIG
 then
 	echo -n " IPT	"
 	check_xt
@@ -375,7 +376,7 @@ then
 fi
 
 echo
-if ! grep -q TC_CONFIG_NO_XT Config
+if ! grep -q TC_CONFIG_NO_XT $CONFIG
 then
 	echo -n "iptables modules directory: "
 	check_ipt_lib_dir
@@ -401,6 +402,6 @@ echo -n "docs:"
 check_docs
 echo
 
-echo >> Config
-echo "%.o: %.c" >> Config
-echo '	$(QUIET_CC)$(CC) $(CFLAGS) $(EXTRA_CFLAGS) -c -o $@ $<' >> Config
+echo >> $CONFIG
+echo "%.o: %.c" >> $CONFIG
+echo '	$(QUIET_CC)$(CC) $(CFLAGS) $(EXTRA_CFLAGS) -c -o $@ $<' >> $CONFIG
diff --git a/devlink/Makefile b/devlink/Makefile
index 7256c28708eb..3b2067d6658c 100644
--- a/devlink/Makefile
+++ b/devlink/Makefile
@@ -1,4 +1,5 @@
-include ../Config
+include ../config.mk
+
 ifeq ($(HAVE_MNL),y)
 
 DEVLINKOBJ = devlink.o mnlg.o
diff --git a/genl/Makefile b/genl/Makefile
index f0efe1ac6647..de1635e498ad 100644
--- a/genl/Makefile
+++ b/genl/Makefile
@@ -1,6 +1,6 @@
 GENLOBJ=genl.o
 
-include ../Config
+include ../config.mk
 SHARED_LIBS ?= y
 
 CFLAGS += -fno-strict-aliasing
@@ -17,11 +17,6 @@ LDFLAGS += -Wl,-export-dynamic
 LDLIBS  += -lm -ldl
 endif
 
-ifeq ($(HAVE_MNL),y)
-	CFLAGS += -DHAVE_LIBMNL $(shell $(PKG_CONFIG) libmnl --cflags)
-	LDLIBS += $(shell $(PKG_CONFIG) libmnl --libs)
-endif
-
 all: genl
 
 genl: $(GENLOBJ) $(LIBNETLINK) $(LIBUTIL) $(GENLLIB)
diff --git a/ip/Makefile b/ip/Makefile
index a754c04d2dbb..5a1c7ad2d264 100644
--- a/ip/Makefile
+++ b/ip/Makefile
@@ -13,20 +13,7 @@ IPOBJ=ip.o ipaddress.o ipaddrlabel.o iproute.o iprule.o ipnetns.o \
 
 RTMONOBJ=rtmon.o
 
-include ../Config
-
-ifeq ($(IP_CONFIG_SETNS),y)
-	CFLAGS += -DHAVE_SETNS
-endif
-
-ifeq ($(HAVE_ELF),y)
-	CFLAGS += -DHAVE_ELF
-	LDLIBS += -lelf
-endif
-ifeq ($(HAVE_MNL),y)
-	CFLAGS += -DHAVE_LIBMNL $(shell $(PKG_CONFIG) libmnl --cflags)
-	LDLIBS += $(shell $(PKG_CONFIG) libmnl --libs)
-endif
+include ../config.mk
 
 ALLOBJ=$(IPOBJ) $(RTMONOBJ)
 SCRIPTS=ifcfg rtpr routel routef
diff --git a/lib/Makefile b/lib/Makefile
index b7b1d5685b94..5e9f72facd36 100644
--- a/lib/Makefile
+++ b/lib/Makefile
@@ -1,16 +1,4 @@
-include ../Config
-
-ifeq ($(IP_CONFIG_SETNS),y)
-	CFLAGS += -DHAVE_SETNS
-endif
-
-ifeq ($(HAVE_ELF),y)
-	CFLAGS += -DHAVE_ELF
-endif
-
-ifeq ($(HAVE_MNL),y)
-	CFLAGS += -DHAVE_LIBMNL $(shell $(PKG_CONFIG) libmnl --cflags)
-endif
+include ../config.mk
 
 CFLAGS += -fPIC
 
diff --git a/misc/Makefile b/misc/Makefile
index fa90308e4848..d02616e3482a 100644
--- a/misc/Makefile
+++ b/misc/Makefile
@@ -3,26 +3,12 @@ LNSTATOBJ=lnstat.o lnstat_util.o
 
 TARGETS=ss nstat ifstat rtacct lnstat
 
-include ../Config
+include ../config.mk
 
 ifeq ($(HAVE_BERKELEY_DB),y)
 	TARGETS += arpd
 endif
 
-ifeq ($(HAVE_SELINUX),y)
-	LDLIBS += $(shell $(PKG_CONFIG) --libs libselinux)
-	CFLAGS += $(shell $(PKG_CONFIG) --cflags libselinux) -DHAVE_SELINUX
-endif
-
-ifeq ($(IP_CONFIG_SETNS),y)
-	CFLAGS += -DHAVE_SETNS
-endif
-
-ifeq ($(HAVE_MNL),y)
-	CFLAGS += -DHAVE_LIBMNL $(shell $(PKG_CONFIG) libmnl --cflags)
-	LDLIBS += $(shell $(PKG_CONFIG) libmnl --libs)
-endif
-
 all: $(TARGETS)
 
 ss: $(SSOBJ)
diff --git a/netem/Makefile b/netem/Makefile
index 2499f086f24d..434185273f64 100644
--- a/netem/Makefile
+++ b/netem/Makefile
@@ -1,4 +1,4 @@
-include ../Config
+include ../config.mk
 
 DISTGEN = maketable normal pareto paretonormal
 DISTDATA = normal.dist pareto.dist paretonormal.dist experimental.dist
@@ -7,11 +7,6 @@ HOSTCC ?= $(CC)
 CCOPTS  = $(CBUILD_CFLAGS)
 LDLIBS += -lm
 
-ifeq ($(HAVE_MNL),y)
-	CFLAGS += -DHAVE_LIBMNL $(shell $(PKG_CONFIG) libmnl --cflags)
-	LDLIBS += $(shell $(PKG_CONFIG) libmnl --libs)
-endif
-
 all: $(DISTGEN) $(DISTDATA)
 
 $(DISTGEN):
diff --git a/tc/Makefile b/tc/Makefile
index a9b4b8e60dac..777de5e6da76 100644
--- a/tc/Makefile
+++ b/tc/Makefile
@@ -2,11 +2,7 @@ TCOBJ= tc.o tc_qdisc.o tc_class.o tc_filter.o tc_util.o tc_monitor.o \
        tc_exec.o m_police.o m_estimator.o m_action.o m_ematch.o \
        emp_ematch.yacc.o emp_ematch.lex.o
 
-include ../Config
-
-ifeq ($(IP_CONFIG_SETNS),y)
-	CFLAGS += -DHAVE_SETNS
-endif
+include ../config.mk
 
 SHARED_LIBS ?= y
 
@@ -102,15 +98,6 @@ endif
 TCOBJ += $(TCMODULES)
 LDLIBS += -L. -lm
 
-ifeq ($(HAVE_ELF),y)
-	CFLAGS += -DHAVE_ELF
-	LDLIBS += -lelf
-endif
-ifeq ($(HAVE_MNL),y)
-	CFLAGS += -DHAVE_LIBMNL $(shell $(PKG_CONFIG) libmnl --cflags)
-	LDLIBS += $(shell $(PKG_CONFIG) libmnl --libs)
-endif
-
 ifeq ($(SHARED_LIBS),y)
 LDLIBS += -ldl
 LDFLAGS += -Wl,-export-dynamic
diff --git a/tipc/Makefile b/tipc/Makefile
index 87e3cac3756f..2212beb06534 100644
--- a/tipc/Makefile
+++ b/tipc/Makefile
@@ -1,4 +1,5 @@
-include ../Config
+include ../config.mk
+
 ifeq ($(HAVE_MNL),y)
 
 TIPCOBJ=bearer.o \
@@ -8,8 +9,6 @@ TIPCOBJ=bearer.o \
     node.o socket.o \
     peer.o tipc.o
 
-include ../Config
-
 TARGETS=tipc
 CFLAGS += $(shell $(PKG_CONFIG) libmnl --cflags)
 LDLIBS += $(shell $(PKG_CONFIG) libmnl --libs)
-- 
2.11.0
