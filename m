From: Florian Lehner <dev@der-flo.net>
Subject: [PATCH v3] ss: Enclose IPv6 address in brackets
Date: Tue, 1 Aug 2017 12:05:13 +0200
Message-ID: <17aba498-3d75-2659-5fdc-4c95b0d214fa@der-flo.net>
References: <fc81757c-8dbb-dbed-7a24-7011cb8bb9e0@der-flo.net>
Mime-Version: 1.0
Content-Type: text/plain; charset=utf-8
Content-Transfer-Encoding: 7bit
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mx.der-flo.net ([193.160.39.236]:45751 "EHLO mx.der-flo.net"
        rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
        id S1751217AbdHAKFQ (ORCPT <rfc822;netdev@vger.kernel.org>);
        Tue, 1 Aug 2017 06:05:16 -0400
Received: from [IPv6:2a02:1205:c693:af80:5ee0:c5ff:fe8a:a179] (unknown [IPv6:2a02:1205:c693:af80:5ee0:c5ff:fe8a:a179])
        (using TLSv1.2 with cipher ECDHE-ECDSA-AES128-GCM-SHA256 (128/128 bits))
        (No client certificate requested)
        by mx.der-flo.net (Postfix) with ESMTPSA id 47BA047E3C
        for <netdev@vger.kernel.org>; Tue,  1 Aug 2017 12:05:14 +0200 (CEST)
In-Reply-To: <fc81757c-8dbb-dbed-7a24-7011cb8bb9e0@der-flo.net>
Content-Language: en-US
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

This updated patch adds support for RFC2732 IPv6 address format with
brackets for the tool ss.
It implements the suggestion by Phil Sutter to use a further value,
whether an address was resolved to a hostname.

Signed-off-by: Lehner Florian <dev@der-flo.net>
---
 include/utils.h | 10 +++++++---
 lib/utils.c     | 11 +++++++----
 misc/ss.c       | 20 +++++++++++++++-----
 3 files changed, 29 insertions(+), 12 deletions(-)

diff --git a/include/utils.h b/include/utils.h
index 6080b96..ffacb49 100644
--- a/include/utils.h
+++ b/include/utils.h
@@ -114,9 +114,13 @@ int addr64_n2a(__u64 addr, char *buff, size_t len);
 int af_bit_len(int af);
 int af_byte_len(int af);

-const char *format_host_r(int af, int len, const void *addr,
-			       char *buf, int buflen);
-const char *format_host(int af, int lne, const void *addr);
+const char *format_host_rb(int af, int len, const void *addr,
+			       char *buf, int buflen, bool *resolved);
+#define format_host_r(af, len, addr, buf, buflen) \
+	format_host_rb(af, len, addr, buf, buflen, NULL)
+const char *format_host_b(int af, int lne, const void *addr, bool
*resolved);
+#define format_host(af, lne, addr) \
+	format_host_b(af, lne, addr, NULL)
 #define format_host_rta(af, rta) \
 	format_host(af, RTA_PAYLOAD(rta), RTA_DATA(rta))
 const char *rt_addr_n2a_r(int af, int len, const void *addr,
diff --git a/lib/utils.c b/lib/utils.c
index 9aa3219..42c3bf5 100644
--- a/lib/utils.c
+++ b/lib/utils.c
@@ -898,8 +898,8 @@ static const char *resolve_address(const void *addr,
int len, int af)
 }
 #endif

-const char *format_host_r(int af, int len, const void *addr,
-			char *buf, int buflen)
+const char *format_host_rb(int af, int len, const void *addr,
+			char *buf, int buflen, bool *resolved)
 {
 #ifdef RESOLVE_HOSTNAMES
 	if (resolve_hosts) {
@@ -909,17 +909,20 @@ const char *format_host_r(int af, int len, const
void *addr,

 		if (len > 0 &&
 		    (n = resolve_address(addr, len, af)) != NULL)
+		{
+			*resolved = true;
 			return n;
+		}
 	}
 #endif
 	return rt_addr_n2a_r(af, len, addr, buf, buflen);
 }

-const char *format_host(int af, int len, const void *addr)
+const char *format_host_b(int af, int len, const void *addr, bool
*resolved)
 {
 	static char buf[256];

-	return format_host_r(af, len, addr, buf, 256);
+	return format_host_rb(af, len, addr, buf, 256, resolved);
 }


diff --git a/misc/ss.c b/misc/ss.c
index 12763c9..d37bd1d 100644
--- a/misc/ss.c
+++ b/misc/ss.c
@@ -1046,20 +1046,30 @@ do_numeric:

 static void inet_addr_print(const inet_prefix *a, int port, unsigned
int ifindex)
 {
-	char buf[1024];
-	const char *ap = buf;
+	char b1[1024], b2[1024];
+	const char *ap = b1;
 	int est_len = addr_width;
 	const char *ifname = NULL;
+	bool resolved = false;

 	if (a->family == AF_INET) {
 		if (a->data[0] == 0) {
-			buf[0] = '*';
-			buf[1] = 0;
+			b1[0] = '*';
+			b1[1] = 0;
 		} else {
 			ap = format_host(AF_INET, 4, a->data);
 		}
 	} else {
-		ap = format_host(a->family, 16, a->data);
+		if (a->family == AF_INET6) {
+			ap = format_host_b(a->family, 16, a->data, &resolved);
+			if (!resolved)
+			{
+				sprintf(b2, "[%s]", ap);
+				ap = b2;
+			}
+		} else {
+			ap = format_host(a->family, 16, a->data);
+		}
 		est_len = strlen(ap);
 		if (est_len <= addr_width)
 			est_len = addr_width;
-- 
2.9.4
