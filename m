From: Tom Herbert <tom@herbertland.com>
Subject: [PATCH iproute] ila: Add support for ILA lwtunnels
Date: Mon, 30 Nov 2015 14:57:28 -0800
Message-ID: <1448924248-4025991-1-git-send-email-tom@herbertland.com>
Mime-Version: 1.0
Content-Type: text/plain
Cc: <kernel-team@fb.com>, Tom Herbert <tom@herbertland.com>
To: <shemming@brocade.com>, <netdev@vger.kernel.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mx0a-00082601.pphosted.com ([67.231.145.42]:36277 "EHLO
	mx0a-00082601.pphosted.com" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with ESMTP id S1754990AbbK3W5h (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 30 Nov 2015 17:57:37 -0500
Received: from pps.filterd (m0044010.ppops.net [127.0.0.1])
	by mx0a-00082601.pphosted.com (8.15.0.59/8.15.0.59) with SMTP id tAUMsMVH003635
	for <netdev@vger.kernel.org>; Mon, 30 Nov 2015 14:57:37 -0800
Received: from mail.thefacebook.com ([199.201.64.23])
	by mx0a-00082601.pphosted.com with ESMTP id 1yf8f78m4e-1
	(version=TLSv1/SSLv3 cipher=AES128-SHA bits=128 verify=NOT)
	for <netdev@vger.kernel.org>; Mon, 30 Nov 2015 14:57:37 -0800
Received: from devbig284.prn2.facebook.com (10.35.15.32)	by
 mx-out.facebook.com (10.212.236.89) with ESMTP	id
 bf22535a97b511e58c3b0002c95209d8-2a7fd230 for <netdev@vger.kernel.org>;	Mon,
 30 Nov 2015 14:57:35 -0800
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

This patch:
 - Adds a utility function for parsing a 64 bit address
 - Adds a utility function for converting a 64 bit address to ASCII
 - Adds and ILA encap type in lwt tunnels

Signed-off-by: Tom Herbert <tom@herbertland.com>
---
 include/utils.h       |  3 +++
 ip/iproute_lwtunnel.c | 45 +++++++++++++++++++++++++++++++++++++++
 lib/utils.c           | 59 +++++++++++++++++++++++++++++++++++++++++++++++++++
 3 files changed, 107 insertions(+)

diff --git a/include/utils.h b/include/utils.h
index 1d35149..96aa020 100644
--- a/include/utils.h
+++ b/include/utils.h
@@ -93,6 +93,7 @@ int get_prefix_1(inet_prefix *dst, char *arg, int family);
 int get_addr(inet_prefix *dst, const char *arg, int family);
 int get_prefix(inet_prefix *dst, char *arg, int family);
 int mask2bits(__u32 netmask);
+int get_addr_ila(__u64 *val, const char *arg);
 
 int get_integer(int *val, const char *arg, int base);
 int get_unsigned(unsigned *val, const char *arg, int base);
@@ -110,6 +111,8 @@ int get_s8(__s8 *val, const char *arg, int base);
 
 char* hexstring_n2a(const __u8 *str, int len, char *buf, int blen);
 __u8* hexstring_a2n(const char *str, __u8 *buf, int blen);
+#define ADDR64_BUF_SIZE sizeof("xxxx:xxxx:xxxx:xxxx")
+int addr64_n2a(__u64 addr, char *buff, size_t len);
 
 int af_bit_len(int af);
 int af_byte_len(int af);
diff --git a/ip/iproute_lwtunnel.c b/ip/iproute_lwtunnel.c
index 63322a1..b2764a6 100644
--- a/ip/iproute_lwtunnel.c
+++ b/ip/iproute_lwtunnel.c
@@ -16,6 +16,7 @@
 #include <unistd.h>
 #include <fcntl.h>
 #include <string.h>
+#include <linux/ila.h>
 #include <linux/lwtunnel.h>
 #include <linux/mpls_iptunnel.h>
 #include <errno.h>
@@ -32,6 +33,8 @@ static int read_encap_type(const char *name)
 		return LWTUNNEL_ENCAP_IP;
 	else if (strcmp(name, "ip6") == 0)
 		return LWTUNNEL_ENCAP_IP6;
+	else if (strcmp(name, "ila") == 0)
+		return LWTUNNEL_ENCAP_ILA;
 	else
 		return LWTUNNEL_ENCAP_NONE;
 }
@@ -45,6 +48,8 @@ static const char *format_encap_type(int type)
 		return "ip";
 	case LWTUNNEL_ENCAP_IP6:
 		return "ip6";
+	case LWTUNNEL_ENCAP_ILA:
+		return "ila";
 	default:
 		return "unknown";
 	}
@@ -95,6 +100,21 @@ static void print_encap_ip(FILE *fp, struct rtattr *encap)
 		fprintf(fp, "tos %d ", rta_getattr_u8(tb[LWTUNNEL_IP_TOS]));
 }
 
+static void print_encap_ila(FILE *fp, struct rtattr *encap)
+{
+	struct rtattr *tb[ILA_ATTR_MAX+1];
+
+	parse_rtattr_nested(tb, ILA_ATTR_MAX, encap);
+
+	if (tb[ILA_ATTR_LOCATOR]) {
+		char abuf[ADDR64_BUF_SIZE];
+
+		addr64_n2a(*(__u64 *)RTA_DATA(tb[ILA_ATTR_LOCATOR]),
+			   abuf, sizeof(abuf));
+		fprintf(fp, " %s ", abuf);
+	}
+}
+
 void lwt_print_encap(FILE *fp, struct rtattr *encap_type,
 			  struct rtattr *encap)
 {
@@ -114,6 +134,9 @@ void lwt_print_encap(FILE *fp, struct rtattr *encap_type,
 	case LWTUNNEL_ENCAP_IP:
 		print_encap_ip(fp, encap);
 		break;
+	case LWTUNNEL_ENCAP_ILA:
+		print_encap_ila(fp, encap);
+		break;
 	}
 }
 
@@ -186,6 +209,25 @@ static int parse_encap_ip(struct rtattr *rta, size_t len, int *argcp, char ***ar
 	return 0;
 }
 
+static int parse_encap_ila(struct rtattr *rta, size_t len,
+			   int *argcp, char ***argvp)
+{
+	__u64 locator;
+	int argc = *argcp;
+	char **argv = *argvp;
+
+	if (get_addr64(&locator, *argv) < 0) {
+		fprintf(stderr, "Bad locator: %s\n", *argv);
+		exit(1);
+	}
+
+	rta_addattr64(rta, 1024, ILA_ATTR_LOCATOR, locator);
+
+	*argcp = argc;
+	*argvp = argv;
+
+	return 0;
+}
 
 int lwt_parse_encap(struct rtattr *rta, size_t len, int *argcp, char ***argvp)
 {
@@ -213,6 +255,9 @@ int lwt_parse_encap(struct rtattr *rta, size_t len, int *argcp, char ***argvp)
 	case LWTUNNEL_ENCAP_IP:
 		parse_encap_ip(rta, len, &argc, &argv);
 		break;
+	case LWTUNNEL_ENCAP_ILA:
+		parse_encap_ila(rta, len, &argc, &argv);
+		break;
 	default:
 		fprintf(stderr, "Error: unsupported encap type\n");
 		break;
diff --git a/lib/utils.c b/lib/utils.c
index 939a44f..fa35f4d 100644
--- a/lib/utils.c
+++ b/lib/utils.c
@@ -384,6 +384,41 @@ static int get_addr_ipv4(__u8 *ap, const char *cp)
 	return 1;
 }
 
+int get_addr64(__u64 *ap, const char *cp)
+{
+	int i;
+
+	union {
+		__u16 v16[4];
+		__u64 v64;
+	} val;
+
+	for (i = 0; i < 4; i++) {
+		unsigned long n;
+		char *endp;
+
+		n = strtoul(cp, &endp, 16);
+		if (n > 0xffff)
+			return -1;	/* bogus network value */
+
+		if (endp == cp) /* no digits */
+			return -1;
+
+		val.v16[i] = htons(n);
+
+		if (*endp == '\0')
+			break;
+
+		if (i == 3 || *endp != ':')
+			return -1;	/* extra characters */
+		cp = endp + 1;
+	}
+
+	*ap = val.v64;
+
+	return 1;
+}
+
 int get_addr_1(inet_prefix *addr, const char *name, int family)
 {
 	memset(addr, 0, sizeof(*addr));
@@ -838,6 +873,30 @@ __u8* hexstring_a2n(const char *str, __u8 *buf, int blen)
 	return buf;
 }
 
+int addr64_n2a(__u64 addr, char *buff, size_t len)
+{
+	__u16 *words = (__u16 *)&addr;
+	__u16 v;
+	int i, ret;
+	size_t written = 0;
+	char *sep = ":";
+
+	for (i = 0; i < 4; i++) {
+		v = ntohs(words[i]);
+
+		if (i == 3)
+			sep = "";
+
+		ret = snprintf(&buff[written], len - written, "%x%s", v, sep);
+		if (ret < 0)
+			return ret;
+
+		written += ret;
+	}
+
+	return written;
+}
+
 int print_timestamp(FILE *fp)
 {
 	struct timeval tv;
-- 
2.4.6
