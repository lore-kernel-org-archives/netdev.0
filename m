From: Vadim Kochan <vadim4j@gmail.com>
Subject: [PATCH iproute2] configure: Check for Berkeley DB for arpd compilation
Date: Fri, 18 Sep 2015 19:17:13 +0300
Message-ID: <1442593033-27449-1-git-send-email-vadim4j@gmail.com>
Cc: Vadim Kochan <vadim4j@gmail.com>
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-wi0-f178.google.com ([209.85.212.178]:38726 "EHLO
	mail-wi0-f178.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751195AbbIRQUd (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 18 Sep 2015 12:20:33 -0400
Received: by wiclk2 with SMTP id lk2so37553666wic.1
        for <netdev@vger.kernel.org>; Fri, 18 Sep 2015 09:20:32 -0700 (PDT)
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Vadim Kochan <vadim4j@gmail.com>

Add check for Berkeley DB header & lib before compile arpd util.

Signed-off-by: Vadim Kochan <vadim4j@gmail.com>
---
 configure     | 29 +++++++++++++++++++++++++++--
 misc/Makefile |  6 +++++-
 2 files changed, 32 insertions(+), 3 deletions(-)

diff --git a/configure b/configure
index 3ae4c95..d2540b0 100755
--- a/configure
+++ b/configure
@@ -289,12 +289,34 @@ check_mnl()
 	if ${PKG_CONFIG} libmnl --exists
 	then
 		echo "HAVE_MNL:=y" >>Config
-		echo -n "yes"
+		echo "yes"
 	else
-		echo -n "no"
+		echo "no"
 	fi
 }
 
+check_berkeley_db()
+{
+    cat >$TMPDIR/dbtest.c <<EOF
+#include <fcntl.h>
+#include <stdlib.h>
+#include <db_185.h>
+int main(int argc, char **argv) {
+	dbopen("/tmp/xxx_test_db.db", O_CREAT|O_RDWR, 0644, DB_HASH, NULL);
+	return 0;
+}
+EOF
+    $CC -I$INCLUDE -o $TMPDIR/dbtest $TMPDIR/dbtest.c -ldb >/dev/null 2>&1
+    if [ $? -eq 0 ]
+    then
+	echo "HAVE_BERKELEY_DB:=y" >>Config
+	echo "yes"
+    else
+	echo "no"
+    fi
+    rm -f $TMPDIR/dbtest.c $TMPDIR/dbtest
+}
+
 echo "# Generated config based on" $INCLUDE >Config
 check_toolchain
 
@@ -328,6 +350,9 @@ check_elf
 echo -n "libmnl support: "
 check_mnl
 
+echo -n "Berkeley DB: "
+check_berkeley_db
+
 echo
 echo -n "docs:"
 check_docs
diff --git a/misc/Makefile b/misc/Makefile
index 6185217..389c1b0 100644
--- a/misc/Makefile
+++ b/misc/Makefile
@@ -1,10 +1,14 @@
 SSOBJ=ss.o ssfilter.o
 LNSTATOBJ=lnstat.o lnstat_util.o
 
-TARGETS=ss nstat ifstat rtacct arpd lnstat
+TARGETS=ss nstat ifstat rtacct lnstat
 
 include ../Config
 
+ifeq ($(HAVE_BERKELEY_DB),y)
+	TARGETS += arpd
+endif
+
 ifeq ($(HAVE_SELINUX),y)
 	LDLIBS += $(shell pkg-config --libs libselinux)
 	CFLAGS += $(shell pkg-config --cflags libselinux) -DHAVE_SELINUX
-- 
2.4.2
