From: Baruch Siach <baruch@tkos.co.il>
Subject: [PATCH v3] lib: fix multiple strlcpy definition
Date: Mon,  9 Oct 2017 08:49:44 +0300
Message-ID: <9a00dc2dca0650efd7e169db9bb15ae1ec043c08.1507528184.git.baruch@tkos.co.il>
Cc: netdev@vger.kernel.org, Phil Sutter <phil@nwl.cc>,
        Baruch Siach <baruch@tkos.co.il>
To: Stephen Hemminger <stephen@networkplumber.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from guitar.tcltek.co.il ([192.115.133.116]:51013 "EHLO
        mx.tkos.co.il" rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
        id S1751581AbdJIFuw (ORCPT <rfc822;netdev@vger.kernel.org>);
        Mon, 9 Oct 2017 01:50:52 -0400
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Some C libraries, like uClibc and musl, provide BSD compatible
strlcpy(). Add check_strlcpy() to configure, and avoid defining strlcpy
and strlcat when the C library provides them.

This fixes the following static link error with uClibc-ng:

.../sysroot/usr/lib/libc.a(strlcpy.os): In function `strlcpy':
strlcpy.c:(.text+0x0): multiple definition of `strlcpy'
../lib/libutil.a(utils.o):utils.c:(.text+0x1ddc): first defined here
collect2: error: ld returned 1 exit status

Acked-by: Phil Sutter <phil@nwl.cc>
Signed-off-by: Baruch Siach <baruch@tkos.co.il>
---
v3: Set CFLAGS directly in config.mk
v2: Fix the order of strlcpy parameters
---
 configure   | 24 ++++++++++++++++++++++++
 lib/utils.c |  2 ++
 2 files changed, 26 insertions(+)

diff --git a/configure b/configure
index 7be8fb113cc9..f0668ab3f7e9 100755
--- a/configure
+++ b/configure
@@ -326,6 +326,27 @@ EOF
     rm -f $TMPDIR/dbtest.c $TMPDIR/dbtest
 }
 
+check_strlcpy()
+{
+    cat >$TMPDIR/strtest.c <<EOF
+#include <string.h>
+int main(int argc, char **argv) {
+	char dst[10];
+	strlcpy(dst, "test", sizeof(dst));
+	return 0;
+}
+EOF
+    $CC -I$INCLUDE -o $TMPDIR/strtest $TMPDIR/strtest.c >/dev/null 2>&1
+    if [ $? -eq 0 ]
+    then
+	echo "no"
+    else
+	echo 'CFLAGS += -DNEED_STRLCPY' >>$CONFIG
+	echo "yes"
+    fi
+    rm -f $TMPDIR/strtest.c $TMPDIR/strtest
+}
+
 quiet_config()
 {
 	cat <<EOF
@@ -397,6 +418,9 @@ check_mnl
 echo -n "Berkeley DB: "
 check_berkeley_db
 
+echo -n "need for strlcpy: "
+check_strlcpy
+
 echo
 echo -n "docs:"
 check_docs
diff --git a/lib/utils.c b/lib/utils.c
index 0cf99619c302..632fd0ddac82 100644
--- a/lib/utils.c
+++ b/lib/utils.c
@@ -1260,6 +1260,7 @@ int get_real_family(int rtm_type, int rtm_family)
 	return rtm_family;
 }
 
+#ifdef NEED_STRLCPY
 size_t strlcpy(char *dst, const char *src, size_t size)
 {
 	size_t srclen = strlen(src);
@@ -1282,3 +1283,4 @@ size_t strlcat(char *dst, const char *src, size_t size)
 
 	return dlen + strlcpy(dst + dlen, src, size - dlen);
 }
+#endif
-- 
2.14.2
