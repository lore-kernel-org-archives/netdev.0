From: greearb@candelatech.com
Subject: [RFC] iproute:  Support cross-compiling.
Date: Tue, 15 Nov 2011 17:04:42 -0800
Message-ID: <1321405482-18445-1-git-send-email-greearb@candelatech.com>
Cc: Ben Greear <greearb@candelatech.com>
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail.candelatech.com ([208.74.158.172]:36330 "EHLO
	ns3.lanforge.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1756933Ab1KPBEx (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 15 Nov 2011 20:04:53 -0500
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Ben Greear <greearb@candelatech.com>

This lets users use their own compiler instead of
hard-coding to use gcc.

Also adds tests to disable some things that were not supported
in my ARM cross-compile toolchain.

Signed-off-by: Ben Greear <greearb@candelatech.com>
---
:100644 100644 c6e4943... 3b00076... M	Makefile
:100755 100755 f5c3d40... 680fdcb... M	configure
:100644 100644 8d03993... 5c91e18... M	ip/Makefile
:100644 100644 e41a598... 773f7cb... M	ip/ipnetns.c
:100644 100644 8c25381... d04358d... M	misc/Makefile
 Makefile      |    2 +-
 configure     |   88 +++++++++++++++++++++++++++++++++++++++++++++++++++++---
 ip/Makefile   |    8 +++++
 ip/ipnetns.c  |   17 +++++++++++
 misc/Makefile |    5 +++
 5 files changed, 114 insertions(+), 6 deletions(-)

diff --git a/Makefile b/Makefile
index c6e4943..3b00076 100644
--- a/Makefile
+++ b/Makefile
@@ -27,7 +27,7 @@ ADDLIB+=dnet_ntop.o dnet_pton.o
 #options for ipx
 ADDLIB+=ipx_ntop.o ipx_pton.o
 
-CC = gcc
+CC ?= gcc
 HOSTCC = gcc
 CCOPTS = -D_GNU_SOURCE -O2 -Wstrict-prototypes -Wall
 CFLAGS = $(CCOPTS) -I../include $(DEFINES)
diff --git a/configure b/configure
index f5c3d40..680fdcb 100755
--- a/configure
+++ b/configure
@@ -3,6 +3,11 @@
 #
 INCLUDE=${1:-"$PWD/include"}
 
+if [ "_$CC" == "_" ]
+then
+    CC=gcc
+fi
+
 check_atm()
 {
 cat >/tmp/atmtest.c <<EOF
@@ -13,7 +18,7 @@ int main(int argc, char **argv) {
 	return 0;
 }
 EOF
-gcc -I$INCLUDE -o /tmp/atmtest /tmp/atmtest.c -latm >/dev/null 2>&1 
+${CC} -I$INCLUDE -o /tmp/atmtest /tmp/atmtest.c -latm >/dev/null 2>&1
 if [ $? -eq 0 ]
 then
     echo "TC_CONFIG_ATM:=y" >>Config
@@ -47,7 +52,7 @@ int main(int argc, char **argv)
 
 EOF
 
-if gcc -I$INCLUDE $IPTC -o /tmp/ipttest /tmp/ipttest.c $IPTL -ldl -lxtables >/dev/null 2>&1
+if ${CC} -I$INCLUDE $IPTC -o /tmp/ipttest /tmp/ipttest.c $IPTL -ldl -lxtables >/dev/null 2>&1
 then
 	echo "TC_CONFIG_XT:=y" >>Config
 	echo "using xtables"
@@ -84,7 +89,7 @@ int main(int argc, char **argv) {
 }
 
 EOF
-gcc -I$INCLUDE $IPTC -o /tmp/ipttest /tmp/ipttest.c $IPTL -ldl >/dev/null 2>&1
+${CC} -I$INCLUDE $IPTC -o /tmp/ipttest /tmp/ipttest.c $IPTL -ldl >/dev/null 2>&1
 
 if [ $? -eq 0 ]
 then
@@ -124,7 +129,7 @@ int main(int argc, char **argv) {
 }
 
 EOF
-gcc -I$INCLUDE $IPTC -o /tmp/ipttest /tmp/ipttest.c $IPTL -ldl >/dev/null 2>&1
+${CC} -I$INCLUDE $IPTC -o /tmp/ipttest /tmp/ipttest.c $IPTL -ldl >/dev/null 2>&1
 
 if [ $? -eq 0 ]
 then
@@ -168,7 +173,7 @@ int main(int argc, char **argv)
 	return 0;
 }
 EOF
-gcc -I$INCLUDE -o /tmp/setnstest /tmp/setnstest.c >/dev/null 2>&1
+${CC} -I$INCLUDE -o /tmp/setnstest /tmp/setnstest.c >/dev/null 2>&1
 if [ $? -eq 0 ]
 then
 	echo "IP_CONFIG_SETNS:=y" >>Config
@@ -179,6 +184,70 @@ fi
 rm -f /tmp/setnstest.c /tmp/setnstest
 }
 
+check_inotify()
+{
+cat >/tmp/inotify_test.c <<EOF
+#include <sys/inotify.h>
+int main(int argc, char **argv)
+{
+	return 0;
+}
+EOF
+${CC} -I$INCLUDE -o /tmp/inotify_test /tmp/inotify_test.c >/dev/null 2>&1
+if [ $? -eq 0 ]
+then
+	echo "yes"
+else
+	echo "IP_CONFIG_DISABLE_INOTIFY:=y" >>Config
+	echo "no"
+fi
+rm -f /tmp/inotify_test.c /tmp/inotify_test
+}
+
+
+check_unshare()
+{
+cat >/tmp/unshare_test.c <<EOF
+#define _GNU_SOURCE             /* See feature_test_macros(7) */
+#include <sched.h>
+int main(int argc, char **argv)
+{
+	return unshare(0); /* 0 == no op */
+}
+EOF
+${CC} -I$INCLUDE -o /tmp/unshare_test /tmp/unshare_test.c >/dev/null 2>&1
+if [ $? -eq 0 ]
+then
+	echo "yes"
+else
+	echo "IP_CONFIG_DISABLE_UNSHARE:=y" >>Config
+	echo "no"
+fi
+rm -f /tmp/unshare_test.c /tmp/unshare_test
+}
+
+
+check_db185()
+{
+cat >/tmp/db185_test.c <<EOF
+#include <db_185.h>
+int main(int argc, char **argv)
+{
+	return 0;
+}
+EOF
+${CC} -I$INCLUDE -o /tmp/db185_test /tmp/db185_test.c >/dev/null 2>&1
+if [ $? -eq 0 ]
+then
+	echo "yes"
+else
+	echo "IP_CONFIG_DISABLE_DB185:=y" >>Config
+	echo "no"
+fi
+rm -f /tmp/db185_test.c /tmp/db185_test
+}
+
+
 echo "# Generated config based on" $INCLUDE >Config
 
 echo "TC schedulers"
@@ -197,3 +266,12 @@ check_ipt_lib_dir
 
 echo -n "libc has setns: "
 check_setns
+
+echo -n "libc has inotify support: "
+check_inotify
+
+echo -n "libc has unshare support: "
+check_unshare
+
+echo -n "libc has db_185 support: "
+check_db185
diff --git a/ip/Makefile b/ip/Makefile
index 8d03993..5c91e18 100644
--- a/ip/Makefile
+++ b/ip/Makefile
@@ -13,6 +13,14 @@ ifeq ($(IP_CONFIG_SETNS),y)
 	CFLAGS += -DHAVE_SETNS
 endif
 
+ifeq ($(IP_CONFIG_DISABLE_INOTIFY),y)
+	CFLAGS += -DDISABLE_INOTIFY
+endif
+
+ifeq ($(IP_CONFIG_DISABLE_UNSHARE),y)
+	CFLAGS += -DCONFIG_IP_NO_UNSHARE
+endif
+
 ALLOBJ=$(IPOBJ) $(RTMONOBJ)
 SCRIPTS=ifcfg rtpr routel routef
 TARGETS=ip rtmon
diff --git a/ip/ipnetns.c b/ip/ipnetns.c
index e41a598..773f7cb 100644
--- a/ip/ipnetns.c
+++ b/ip/ipnetns.c
@@ -2,7 +2,9 @@
 #include <sys/types.h>
 #include <sys/stat.h>
 #include <sys/wait.h>
+#ifndef DISABLE_INOTIFY
 #include <sys/inotify.h>
+#endif
 #include <sys/mount.h>
 #include <sys/param.h>
 #include <sys/syscall.h>
@@ -118,6 +120,10 @@ static void bind_etc(const char *name)
 
 static int netns_exec(int argc, char **argv)
 {
+#ifdef CONFIG_IP_NO_UNSHARE
+	fprintf(stderr, "No unshare on this platform, cannod do netns_exec\n");
+	return -1;
+#else
 	/* Setup the proper environment for apps that are not netns
 	 * aware, and execute a program in that environment.
 	 */
@@ -169,6 +175,7 @@ static int netns_exec(int argc, char **argv)
 		fprintf(stderr, "exec of %s failed: %s\n",
 			cmd, strerror(errno));
 	exit(-1);
+#endif
 }
 
 static int netns_delete(int argc, char **argv)
@@ -194,6 +201,10 @@ static int netns_delete(int argc, char **argv)
 
 static int netns_add(int argc, char **argv)
 {
+#ifdef CONFIG_IP_NO_UNSHARE
+	fprintf(stderr, "No unshare on this platform, cannod do netns_add\n");
+	return -1;
+#else
 	/* This function creates a new network namespace and
 	 * a new mount namespace and bind them into a well known
 	 * location in the filesystem based on the name provided.
@@ -242,11 +253,16 @@ out_delete:
 	netns_delete(argc, argv);
 	exit(-1);
 	return -1;
+#endif
 }
 
 
 static int netns_monitor(int argc, char **argv)
 {
+#ifdef DISABLE_INOTIFY
+	fprintf(stderr, "inotify not supported (compiled out)\n");
+	return -1;
+#else
 	char buf[4096];
 	struct inotify_event *event;
 	int fd;
@@ -278,6 +294,7 @@ static int netns_monitor(int argc, char **argv)
 		}
 	}
 	return 0;
+#endif
 }
 
 int do_netns(int argc, char **argv)
diff --git a/misc/Makefile b/misc/Makefile
index 8c25381..d04358d 100644
--- a/misc/Makefile
+++ b/misc/Makefile
@@ -18,8 +18,13 @@ ifstat: ifstat.c
 rtacct: rtacct.c
 	$(CC) $(CFLAGS) $(LDFLAGS) -o rtacct rtacct.c $(LIBNETLINK) -lm
 
+ifeq ($(IP_CONFIG_DISABLE_DB185),y)
+arpd:
+	@echo "Cannot build arpd on this system, no db_185.h file."
+else
 arpd: arpd.c
 	$(CC) $(CFLAGS) -I$(DBM_INCLUDE) $(LDFLAGS) -o arpd arpd.c $(LIBNETLINK) -ldb -lpthread
+endif
 
 ssfilter.c: ssfilter.y
 	bison ssfilter.y -o ssfilter.c
-- 
1.7.3.4
