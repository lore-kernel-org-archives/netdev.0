From: Baruch Siach <baruch@tkos.co.il>
Subject: [PATCH v2] lib: fix multiple strlcpy definition
Date: Thu, 28 Sep 2017 21:02:11 +0300
Message-ID: <6910008ec8db3f63c8120b1624a08328cd203e92.1506621731.git.baruch@tkos.co.il>
Cc: netdev@vger.kernel.org, Phil Sutter <phil@nwl.cc>,
        Baruch Siach <baruch@tkos.co.il>
To: Stephen Hemminger <stephen@networkplumber.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from guitar.tcltek.co.il ([192.115.133.116]:50309 "EHLO
        mx.tkos.co.il" rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
        id S1750759AbdI1SDH (ORCPT <rfc822;netdev@vger.kernel.org>);
        Thu, 28 Sep 2017 14:03:07 -0400
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
v2: Fix the order of strlcpy parameters
---
 configure    | 24 ++++++++++++++++++++++++
 lib/Makefile |  4 ++++
 lib/utils.c  |  2 ++
 3 files changed, 30 insertions(+)

diff --git a/configure b/configure
index 7be8fb113cc9..e0982f34a992 100755
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
+	echo "NEED_STRLCPY:=y" >>$CONFIG
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
diff --git a/lib/Makefile b/lib/Makefile
index 0fbdf4c31f50..132ad00c3335 100644
--- a/lib/Makefile
+++ b/lib/Makefile
@@ -1,5 +1,9 @@
 include ../config.mk
 
+ifeq ($(NEED_STRLCPY),y)
+	CFLAGS += -DNEED_STRLCPY
+endif
+
 CFLAGS += -fPIC
 
 UTILOBJ = utils.o rt_names.o ll_types.o ll_proto.o ll_addr.o \
diff --git a/lib/utils.c b/lib/utils.c
index bbd3cbc46a0e..240e7426a810 100644
--- a/lib/utils.c
+++ b/lib/utils.c
@@ -1231,6 +1231,7 @@ int get_real_family(int rtm_type, int rtm_family)
 	return rtm_family;
 }
 
+#ifdef NEED_STRLCPY
 size_t strlcpy(char *dst, const char *src, size_t size)
 {
 	size_t srclen = strlen(src);
@@ -1253,3 +1254,4 @@ size_t strlcat(char *dst, const char *src, size_t size)
 
 	return dlen + strlcpy(dst + dlen, src, size - dlen);
 }
+#endif
-- 
2.14.2
