From: Mike Frysinger <vapier@gentoo.org>
Subject: [PATCH iputils v3] ping6: allow disabling of openssl/libgcrypt support
Date: Thu,  2 Jun 2016 13:16:41 -0400
Message-ID: <1464887801-31279-1-git-send-email-vapier@gentoo.org>
References: <1464843561-31856-1-git-send-email-vapier@gentoo.org>
Cc: netdev@vger.kernel.org
To: YOSHIFUJI Hideaki <yoshfuji@linux-ipv6.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from smtp.gentoo.org ([140.211.166.183]:58536 "EHLO smtp.gentoo.org"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1030184AbcFBRQp (ORCPT <rfc822;netdev@vger.kernel.org>);
	Thu, 2 Jun 2016 13:16:45 -0400
In-Reply-To: <1464843561-31856-1-git-send-email-vapier@gentoo.org>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Signed-off-by: Mike Frysinger <vapier@gentoo.org>
---
 Makefile         |  5 ++++-
 iputils_md5dig.h |  2 +-
 ping6.c          | 28 +++++++++++++++++++++++++++-
 3 files changed, 32 insertions(+), 3 deletions(-)

diff --git a/Makefile b/Makefile
index b6cf512f22a5..8b9e2aa232e6 100644
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
@@ -66,7 +66,10 @@ ifneq ($(USE_GCRYPT),no)
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
index 4cec86699465..9f09ba0a8c60 100644
--- a/iputils_md5dig.h
+++ b/iputils_md5dig.h
@@ -5,7 +5,7 @@
 # include <stdlib.h>
 # include <gcrypt.h>
 # define IPUTILS_MD5DIG_LEN	16
-#else
+#elif defined(USE_OPENSSL)
 # include <openssl/md5.h>
 #endif
 
diff --git a/ping6.c b/ping6.c
index 6d1a6db37146..95568ec4fbaf 100644
--- a/ping6.c
+++ b/ping6.c
@@ -85,6 +85,12 @@ char copyright[] =
 #include "ping6_niquery.h"
 #include "in6_flowlabel.h"
 
+#if defined(USE_GCRYPT) || defined(USE_OPENSSL)
+# define ENABLE_NIQUERY 1
+#else
+# define ENABLE_NIQUERY 0
+#endif
+
 #ifndef SOL_IPV6
 #define SOL_IPV6 IPPROTO_IPV6
 #endif
@@ -238,6 +244,8 @@ unsigned int if_name2index(const char *ifname)
 	return i;
 }
 
+#if ENABLE_NIQUERY
+
 struct niquery_option {
 	char *name;
 	int namelen;
@@ -669,6 +677,12 @@ int niquery_option_handler(const char *opt_arg)
 	return ret;
 }
 
+#else
+
+# define niquery_is_enabled() 0
+
+#endif /* ENABLE_NIQUERY */
+
 static int hextoui(const char *str)
 {
 	unsigned long val;
@@ -790,6 +804,7 @@ int main(int argc, char *argv[])
 			printf("ping6 utility, iputils-%s\n", SNAPSHOT);
 			exit(0);
 		case 'N':
+#if ENABLE_NIQUERY
 			if (using_ping_socket) {
 				fprintf(stderr, "ping: -N requires raw socket permissions\n");
 				exit(2);
@@ -798,6 +813,10 @@ int main(int argc, char *argv[])
 				usage();
 				break;
 			}
+#else
+			fprintf(stderr, "ping: function not available; crypto disabled\n");
+			exit(2);
+#endif
 			break;
 		COMMON_OPTIONS
 			common_options(ch);
@@ -891,6 +910,7 @@ int main(int argc, char *argv[])
 	}
 #endif
 
+#if ENABLE_NIQUERY
 	if (niquery_is_enabled()) {
 		niquery_init_nonce();
 
@@ -900,6 +920,7 @@ int main(int argc, char *argv[])
 			ni_subject_type = NI_SUBJ_IPV6;
 		}
 	}
+#endif
 
 	if (argc > 1) {
 #ifndef ENABLE_PING6_RTHDR
@@ -1369,7 +1390,7 @@ int build_echo(__u8 *_icmph)
 	return cc;
 }
 
-
+#if ENABLE_NIQUERY
 int build_niquery(__u8 *_nih)
 {
 	struct ni_hdr *nih;
@@ -1391,6 +1412,7 @@ int build_niquery(__u8 *_nih)
 
 	return cc;
 }
+#endif
 
 int send_probe(void)
 {
@@ -1398,9 +1420,11 @@ int send_probe(void)
 
 	rcvd_clear(ntransmitted + 1);
 
+#if ENABLE_NIQUERY
 	if (niquery_is_enabled())
 		len = build_niquery(outpack);
 	else
+#endif
 		len = build_echo(outpack);
 
 	if (cmsglen == 0) {
@@ -1619,6 +1643,7 @@ parse_reply(struct msghdr *msg, int cc, void *addr, struct timeval *tv)
 				      hops, 0, tv, pr_addr(&from->sin6_addr),
 				      pr_echo_reply))
 			return 0;
+#if ENABLE_NIQUERY
 	} else if (icmph->icmp6_type == ICMPV6_NI_REPLY) {
 		struct ni_hdr *nih = (struct ni_hdr *)icmph;
 		int seq = niquery_check_nonce(nih->ni_nonce);
@@ -1629,6 +1654,7 @@ parse_reply(struct msghdr *msg, int cc, void *addr, struct timeval *tv)
 				      hops, 0, tv, pr_addr(&from->sin6_addr),
 				      pr_niquery_reply))
 			return 0;
+#endif
 	} else {
 		int nexthdr;
 		struct ip6_hdr *iph1 = (struct ip6_hdr*)(icmph+1);
-- 
2.8.2
