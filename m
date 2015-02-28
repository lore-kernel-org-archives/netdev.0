From: Vadim Kochan <vadim4j@gmail.com>
Subject: [PATCH iproute2] lib utils: Use helpers to get AF bit/byte len
Date: Sat, 28 Feb 2015 02:50:24 +0200
Message-ID: <1425084624-20025-1-git-send-email-vadim4j@gmail.com>
Cc: netdev@vger.kernel.org, Vadim Kochan <vadim4j@gmail.com>
To: stephen@networkplumber.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-la0-f45.google.com ([209.85.215.45]:34992 "EHLO
	mail-la0-f45.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751053AbbB1BBr (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 27 Feb 2015 20:01:47 -0500
Received: by labgm9 with SMTP id gm9so20777738lab.2
        for <netdev@vger.kernel.org>; Fri, 27 Feb 2015 17:01:46 -0800 (PST)
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Vadim Kochan <vadim4j@gmail.com>

Added funcs to get AF_XXX len in bit/bytes and replace
places where switch(AF_XXX) is used for this.

Signed-off-by: Vadim Kochan <vadim4j@gmail.com>
---
 include/utils.h |  3 +++
 ip/iproute.c    | 22 ++++------------------
 ip/iprule.c     |  9 +--------
 lib/utils.c     | 58 +++++++++++++++++++++++++--------------------------------
 4 files changed, 33 insertions(+), 59 deletions(-)

diff --git a/include/utils.h b/include/utils.h
index fec9ef4..9151c4f 100644
--- a/include/utils.h
+++ b/include/utils.h
@@ -101,6 +101,9 @@ extern int get_s8(__s8 *val, const char *arg, int base);
 extern char* hexstring_n2a(const __u8 *str, int len, char *buf, int blen);
 extern __u8* hexstring_a2n(const char *str, __u8 *buf, int blen);
 
+extern int af_bit_len(int af);
+extern int af_byte_len(int af);
+
 extern const char *format_host(int af, int len, const void *addr,
 			       char *buf, int buflen);
 extern const char *rt_addr_n2a(int af, const void *addr,
diff --git a/ip/iproute.c b/ip/iproute.c
index 76d8e36..b32025f 100644
--- a/ip/iproute.c
+++ b/ip/iproute.c
@@ -268,20 +268,6 @@ static int filter_nlmsg(struct nlmsghdr *n, struct rtattr **tb, int host_len)
 	return 1;
 }
 
-static int calc_host_len(const struct rtmsg *r)
-{
-	if (r->rtm_family == AF_INET6)
-		return 128;
-	else if (r->rtm_family == AF_INET)
-		return 32;
-	else if (r->rtm_family == AF_DECnet)
-		return 16;
-	else if (r->rtm_family == AF_IPX)
-		return 80;
-	else
-		return -1;
-}
-
 static void print_rtax_features(FILE *fp, unsigned int features)
 {
 	unsigned int of = features;
@@ -302,7 +288,7 @@ int print_route(const struct sockaddr_nl *who, struct nlmsghdr *n, void *arg)
 	int len = n->nlmsg_len;
 	struct rtattr * tb[RTA_MAX+1];
 	char abuf[256];
-	int host_len = -1;
+	int host_len;
 	__u32 table;
 	SPRINT_BUF(b1);
 	static int hz;
@@ -320,7 +306,7 @@ int print_route(const struct sockaddr_nl *who, struct nlmsghdr *n, void *arg)
 		return -1;
 	}
 
-	host_len = calc_host_len(r);
+	host_len = af_bit_len(r->rtm_family);
 
 	parse_rtattr(tb, RTA_MAX, RTM_RTA(r), len);
 	table = rtm_get_table(r, tb);
@@ -1134,9 +1120,9 @@ static int save_route(const struct sockaddr_nl *who, struct nlmsghdr *n,
 	int len = n->nlmsg_len;
 	struct rtmsg *r = NLMSG_DATA(n);
 	struct rtattr *tb[RTA_MAX+1];
-	int host_len = -1;
+	int host_len;
 
-	host_len = calc_host_len(r);
+	host_len = af_bit_len(r->rtm_family);
 	len -= NLMSG_LENGTH(sizeof(*r));
 	parse_rtattr(tb, RTA_MAX, RTM_RTA(r), len);
 
diff --git a/ip/iprule.c b/ip/iprule.c
index 366878e..54ed753 100644
--- a/ip/iprule.c
+++ b/ip/iprule.c
@@ -66,14 +66,7 @@ int print_rule(const struct sockaddr_nl *who, struct nlmsghdr *n, void *arg)
 
 	parse_rtattr(tb, FRA_MAX, RTM_RTA(r), len);
 
-	if (r->rtm_family == AF_INET)
-		host_len = 32;
-	else if (r->rtm_family == AF_INET6)
-		host_len = 128;
-	else if (r->rtm_family == AF_DECnet)
-		host_len = 16;
-	else if (r->rtm_family == AF_IPX)
-		host_len = 80;
+	host_len = af_bit_len(r->rtm_family);
 
 	if (n->nlmsg_type == RTM_DELRULE)
 		fprintf(fp, "Deleted ");
diff --git a/lib/utils.c b/lib/utils.c
index e2b05bc..9cda268 100644
--- a/lib/utils.c
+++ b/lib/utils.c
@@ -431,6 +431,27 @@ int get_addr_1(inet_prefix *addr, const char *name, int family)
 	return 0;
 }
 
+int af_bit_len(int af)
+{
+	switch (af) {
+	case AF_INET6:
+		return 128;
+	case AF_INET:
+		return 32;
+	case AF_DECnet:
+		return 16;
+	case AF_IPX:
+		return 80;
+	}
+
+	return 0;
+}
+
+int af_byte_len(int af)
+{
+	return af_bit_len(af) / 8;
+}
+
 int get_prefix_1(inet_prefix *dst, char *arg, int family)
 {
 	int err;
@@ -456,17 +477,8 @@ int get_prefix_1(inet_prefix *dst, char *arg, int family)
 
 	err = get_addr_1(dst, arg, family);
 	if (err == 0) {
-		switch(dst->family) {
-		case AF_INET6:
-			dst->bitlen = 128;
-			break;
-		case AF_DECnet:
-			dst->bitlen = 16;
-			break;
-		default:
-		case AF_INET:
-			dst->bitlen = 32;
-		}
+		dst->bitlen = af_bit_len(family);
+
 		if (slash) {
 			if (get_netmask(&plen, slash+1, 0)
 			    || plen > dst->bitlen) {
@@ -697,7 +709,6 @@ static const char *resolve_address(const void *addr, int len, int af)
 }
 #endif
 
-
 const char *format_host(int af, int len, const void *addr,
 			char *buf, int buflen)
 {
@@ -705,27 +716,8 @@ const char *format_host(int af, int len, const void *addr,
 	if (resolve_hosts) {
 		const char *n;
 
-		if (len <= 0) {
-			switch (af) {
-			case AF_INET:
-				len = 4;
-				break;
-			case AF_INET6:
-				len = 16;
-				break;
-			case AF_IPX:
-				len = 10;
-				break;
-#ifdef AF_DECnet
-			/* I see no reasons why gethostbyname
-			   may not work for DECnet */
-			case AF_DECnet:
-				len = 2;
-				break;
-#endif
-			default: ;
-			}
-		}
+		len = len <= 0 ? af_byte_len(af) : len;
+
 		if (len > 0 &&
 		    (n = resolve_address(addr, len, af)) != NULL)
 			return n;
-- 
2.2.2
