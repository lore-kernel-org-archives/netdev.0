From: Mike Frysinger <vapier@gentoo.org>
Subject: [PATCH iputils 3/6] ping6: allow disabling of openssl support
Date: Tue, 31 May 2016 23:48:22 -0400
Message-ID: <1464752905-10347-3-git-send-email-vapier@gentoo.org>
References: <1464752905-10347-1-git-send-email-vapier@gentoo.org>
Cc: netdev@vger.kernel.org
To: YOSHIFUJI Hideaki <yoshfuji@linux-ipv6.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from smtp.gentoo.org ([140.211.166.183]:58830 "EHLO smtp.gentoo.org"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1757120AbcFADsa (ORCPT <rfc822;netdev@vger.kernel.org>);
	Tue, 31 May 2016 23:48:30 -0400
In-Reply-To: <1464752905-10347-1-git-send-email-vapier@gentoo.org>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Signed-off-by: Mike Frysinger <vapier@gentoo.org>
---
 Makefile         |  5 ++++-
 iputils_md5dig.h |  4 +++-
 ping6.c          | 10 ++++++++++
 3 files changed, 17 insertions(+), 2 deletions(-)

diff --git a/Makefile b/Makefile
index 54e5a6d..7147f08 100644
--- a/Makefile
+++ b/Makefile
@@ -36,7 +36,7 @@ ARPING_DEFAULT_DEVICE=
 
 # Libgcrypt (for MD5) for ping6 [yes|no|static]
 USE_GCRYPT=yes
-# Crypto library for ping6 [shared|static]
+# Crypto library for ping6 [shared|static|no]
 USE_CRYPTO=shared
 # Resolv library for ping6 [yes|static]
 USE_RESOLV=yes
@@ -63,7 +63,10 @@ ifneq ($(USE_GCRYPT),no)
 	LIB_CRYPTO = $(call FUNC_LIB,$(USE_GCRYPT),$(LDFLAG_GCRYPT))
 	DEF_CRYPTO = -DUSE_GCRYPT
 else
+ifneq ($(USE_CRYPTO),no)
 	LIB_CRYPTO = $(call FUNC_LIB,$(USE_CRYPTO),$(LDFLAG_CRYPTO))
+	DEF_CRYPTO = -DUSE_OPENSSL
+endif
 endif
 
 # USE_RESOLV: LIB_RESOLV
diff --git a/iputils_md5dig.h b/iputils_md5dig.h
index 4cec866..d6c4d46 100644
--- a/iputils_md5dig.h
+++ b/iputils_md5dig.h
@@ -5,8 +5,10 @@
 # include <stdlib.h>
 # include <gcrypt.h>
 # define IPUTILS_MD5DIG_LEN	16
-#else
+# define USE_CRYPTO
+#elif defined(USE_OPENSSL)
 # include <openssl/md5.h>
+# define USE_CRYPTO
 #endif
 
 #ifdef USE_GCRYPT
diff --git a/ping6.c b/ping6.c
index 6d1a6db..cd140e2 100644
--- a/ping6.c
+++ b/ping6.c
@@ -324,6 +324,7 @@ static void niquery_init_nonce(void)
 #if !PING6_NONCE_MEMORY
 static int niquery_nonce(__u8 *nonce, int fill)
 {
+# ifdef USE_CRYPTO
 	static __u8 digest[MD5_DIGEST_LENGTH];
 	static int seq = -1;
 
@@ -346,6 +347,10 @@ static int niquery_nonce(__u8 *nonce, int fill)
 			return -1;
 		return ntohsp((__u16 *)nonce);
 	}
+# else
+	fprintf(stderr, "ping6: function not available; crypto disabled\n");
+	exit(3);
+# endif
 }
 #endif
 
@@ -500,6 +505,7 @@ static int niquery_option_subject_addr_handler(int index, const char *arg)
 
 static int niquery_option_subject_name_handler(int index, const char *arg)
 {
+#ifdef USE_CRYPTO
 	static char nigroup_buf[INET6_ADDRSTRLEN + 1 + IFNAMSIZ];
 	unsigned char *dnptrs[2], **dpp, **lastdnptr;
 	int n;
@@ -625,6 +631,10 @@ errexit:
 	free(idn);
 	free(name);
 	exit(1);
+#else
+	fprintf(stderr, "ping6: function not available; crypto disabled\n");
+	exit(3);
+#endif
 }
 
 int niquery_option_help_handler(int index, const char *arg)
-- 
2.8.2
