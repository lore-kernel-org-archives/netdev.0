From: Nicolas Dichtel <nicolas.dichtel@6wind.com>
Subject: [PATCH iproute2] tc: fix bpf compilation with old glibc
Date: Wed, 22 Jul 2015 14:29:30 +0200
Message-ID: <1437568170-16995-1-git-send-email-nicolas.dichtel@6wind.com>
Cc: netdev@vger.kernel.org,
	Nicolas Dichtel <nicolas.dichtel@6wind.com>,
	Daniel Borkmann <daniel@iogearbox.net>
To: shemminger@vyatta.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from host.76.145.23.62.rev.coltfrance.com ([62.23.145.76]:47328 "EHLO
	proxy.6wind.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1756481AbbGVMfb (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 22 Jul 2015 08:35:31 -0400
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Error was:
f_bpf.o: In function `bpf_parse_opt':
f_bpf.c:(.text+0x88f): undefined reference to `secure_getenv'
m_bpf.o: In function `parse_bpf':
m_bpf.c:(.text+0x587): undefined reference to `secure_getenv'
collect2: error: ld returned 1 exit status

CC: Daniel Borkmann <daniel@iogearbox.net>
Fixes: 88eea5395483 ("tc: {f,m}_bpf: allow to retrieve uds path from env")
Signed-off-by: Nicolas Dichtel <nicolas.dichtel@6wind.com>
---
 configure   | 49 +++++++++++++++++++++++++++++++++++++++++++++++--
 tc/Makefile |  6 ++++++
 tc/tc_bpf.h |  9 +++++++++
 3 files changed, 62 insertions(+), 2 deletions(-)

diff --git a/configure b/configure
index 3ae4c955ae8e..1eacdc67dbb9 100755
--- a/configure
+++ b/configure
@@ -289,12 +289,54 @@ check_mnl()
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
 
+check_secure_getenv()
+{
+	#check if we have secure_getenv()
+	cat >$TMPDIR/secure_getenv_test.c <<EOF
+#include <stdlib.h>
+
+int main(int argc, char **argv)
+{
+	secure_getenv("foo");
+	return 0;
+}
+EOF
+
+	$CC -I$INCLUDE -o $TMPDIR/secure_getenv_test $TMPDIR/secure_getenv_test.c >/dev/null 2>&1
+	if [ $? -eq 0 ]
+	then
+		echo "HAVE_SECURE_GETENV:=y" >>Config
+		echo "yes"
+	else
+		#check if we have __secure_getenv()
+		cat >$TMPDIR/secure_getenv_test.c <<EOF
+#include <stdlib.h>
+
+int main(int argc, char **argv)
+{
+	__secure_getenv("foo");
+	return 0;
+}
+EOF
+
+		$CC -I$INCLUDE -o $TMPDIR/secure_getenv_test $TMPDIR/secure_getenv_test.c >/dev/null 2>&1
+		if [ $? -eq 0 ]
+		then
+			echo "HAVE___SECURE_GETENV:=y" >>Config
+			echo "yes"
+		else
+			echo "no"
+		fi
+	fi
+	rm -f $TMPDIR/secure_getenv_test.c $TMPDIR/secure_getenv_test
+}
+
 echo "# Generated config based on" $INCLUDE >Config
 check_toolchain
 
@@ -328,6 +370,9 @@ check_elf
 echo -n "libmnl support: "
 check_mnl
 
+echo -n "secure_getenv() support: "
+check_secure_getenv
+
 echo
 echo -n "docs:"
 check_docs
diff --git a/tc/Makefile b/tc/Makefile
index 56acbaa1ab13..d598fc29532f 100644
--- a/tc/Makefile
+++ b/tc/Makefile
@@ -7,6 +7,12 @@ include ../Config
 ifeq ($(IP_CONFIG_SETNS),y)
 	CFLAGS += -DHAVE_SETNS
 endif
+ifeq ($(HAVE_SECURE_GETENV),y)
+	CFLAGS += -DHAVE_SECURE_GETENV
+endif
+ifeq ($(HAVE___SECURE_GETENV),y)
+	CFLAGS += -DHAVE___SECURE_GETENV
+endif
 
 SHARED_LIBS ?= y
 
diff --git a/tc/tc_bpf.h b/tc/tc_bpf.h
index 2ad881219e68..2e4b1a985f05 100644
--- a/tc/tc_bpf.h
+++ b/tc/tc_bpf.h
@@ -21,12 +21,21 @@
 #include <errno.h>
 #include <stdio.h>
 #include <stdint.h>
+#include <stdlib.h>
 
 #include "utils.h"
 #include "bpf_scm.h"
 
 #define BPF_ENV_UDS	"TC_BPF_UDS"
 
+#ifndef HAVE_SECURE_GETENV
+#  ifdef HAVE___SECURE_GETENV
+#    define secure_getenv __secure_getenv
+#  else
+#    error neither secure_getenv nor __secure_getenv is available
+#  endif
+#endif
+
 int bpf_parse_string(char *arg, bool from_file, __u16 *bpf_len,
 		     char **bpf_string, bool *need_release,
 		     const char separator);
-- 
2.4.2
