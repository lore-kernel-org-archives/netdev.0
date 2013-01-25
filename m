From: Mike Frysinger <vapier@gentoo.org>
Subject: [PATCH [iputils] 5/6] ping6: allow disabling of openssl support
Date: Fri, 25 Jan 2013 00:24:14 -0500
Message-ID: <1359091455-25380-5-git-send-email-vapier@gentoo.org>
References: <1359091455-25380-1-git-send-email-vapier@gentoo.org>
Cc: netdev@vger.kernel.org
To: YOSHIFUJI Hideaki <yoshfuji@linux-ipv6.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from smtp.gentoo.org ([140.211.166.183]:38491 "EHLO smtp.gentoo.org"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1751359Ab3AYFYP (ORCPT <rfc822;netdev@vger.kernel.org>);
	Fri, 25 Jan 2013 00:24:15 -0500
In-Reply-To: <1359091455-25380-1-git-send-email-vapier@gentoo.org>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Signed-off-by: Mike Frysinger <vapier@gentoo.org>
---
 Makefile |  5 ++++-
 ping6.c  | 14 +++++++++++++-
 2 files changed, 17 insertions(+), 2 deletions(-)

diff --git a/Makefile b/Makefile
index 89249f5..2c49940 100644
--- a/Makefile
+++ b/Makefile
@@ -36,7 +36,7 @@ ARPING_DEFAULT_DEVICE=
 
 # GNU TLS library for ping6 [yes|no|static]
 USE_GNUTLS=yes
-# Crypto library for ping6 [shared|static]
+# Crypto library for ping6 [shared|static|no]
 USE_CRYPTO=shared
 # Resolv library for ping6 [yes|static]
 USE_RESOLV=yes
@@ -63,7 +63,10 @@ ifneq ($(USE_GNUTLS),no)
 	LIB_CRYPTO = $(call FUNC_LIB,$(USE_GNUTLS),$(LDFLAG_GNUTLS))
 	DEF_CRYPTO = -DUSE_GNUTLS
 else
+ifneq ($(USE_CRYPTO),no)
 	LIB_CRYPTO = $(call FUNC_LIB,$(USE_CRYPTO),$(LDFLAG_CRYPTO))
+	DEF_CRYPTO = -DUSE_OPENSSL
+endif
 endif
 
 # USE_RESOLV: LIB_RESOLV
diff --git a/ping6.c b/ping6.c
index c39864d..f2f90af 100644
--- a/ping6.c
+++ b/ping6.c
@@ -168,8 +168,10 @@ static int icmp_sock;
 
 #ifdef USE_GNUTLS
 # include <gnutls/openssl.h>
-#else
+# define USE_CRYPTO
+#elif defined USE_OPENSSL
 # include <openssl/md5.h>
+# define USE_CRYPTO
 #endif
 
 /* Node Information query */
@@ -326,6 +328,7 @@ static void niquery_init_nonce(void)
 #if !PING6_NONCE_MEMORY
 static int niquery_nonce(__u8 *nonce, int fill)
 {
+# ifdef USE_CRYPTO
 	static __u8 digest[MD5_DIGEST_LENGTH];
 	static int seq = -1;
 
@@ -348,6 +351,10 @@ static int niquery_nonce(__u8 *nonce, int fill)
 			return -1;
 		return ntohsp((__u16 *)nonce);
 	}
+# else
+	fprintf(stderr, "ping6: function not available; crypto disabled\n");
+	exit(3);
+# endif
 }
 #endif
 
@@ -502,6 +509,7 @@ static int niquery_option_subject_addr_handler(int index, const char *arg)
 
 static int niquery_option_subject_name_handler(int index, const char *arg)
 {
+#ifdef USE_CRYPTO
 	static char nigroup_buf[INET6_ADDRSTRLEN + 1 + IFNAMSIZ];
 	unsigned char *dnptrs[2], **dpp, **lastdnptr;
 	int n;
@@ -627,6 +635,10 @@ errexit:
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
1.8.0.2
