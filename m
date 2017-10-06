From: Ivan Delalande <colona@arista.com>
Subject: [PATCH iproute2 2/2] ss: print MD5 signature keys configured on TCP sockets
Date: Fri,  6 Oct 2017 16:48:20 -0700
Message-ID: <20171006234820.27567-2-colona@arista.com>
References: <20171006234820.27567-1-colona@arista.com>
Cc: netdev@vger.kernel.org, Ivan Delalande <colona@arista.com>
To: Stephen Hemminger <stephen@networkplumber.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from prod-mx.aristanetworks.com ([162.210.130.12]:22401 "EHLO
        prod-mx.aristanetworks.com" rhost-flags-OK-OK-OK-OK)
        by vger.kernel.org with ESMTP id S1752191AbdJFX6C (ORCPT
        <rfc822;netdev@vger.kernel.org>); Fri, 6 Oct 2017 19:58:02 -0400
In-Reply-To: <20171006234820.27567-1-colona@arista.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

These keys are reported by kernel 4.14 and later under the
INET_DIAG_MD5SIG attribute, when INET_DIAG_INFO is requested (ss -i)
and we have CAP_NET_ADMIN. The additional output looks like:

	md5keys:fe80::/64=signing_key,10.1.2.0/24=foobar,::1/128=Test

Signed-off-by: Ivan Delalande <colona@arista.com>
---
 misc/ss.c | 21 +++++++++++++++++++++
 1 file changed, 21 insertions(+)

diff --git a/misc/ss.c b/misc/ss.c
index dd8dfaa4..09bff8a7 100644
--- a/misc/ss.c
+++ b/misc/ss.c
@@ -2153,6 +2153,16 @@ static void print_skmeminfo(struct rtattr *tb[], int attrtype)
 	printf(")");
 }
 
+static void print_md5sig(struct tcp_diag_md5sig *sig)
+{
+	printf("%s/%d=",
+	       format_host(sig->tcpm_family,
+			   sig->tcpm_family == AF_INET6 ? 16 : 4,
+			   &sig->tcpm_addr),
+	       sig->tcpm_prefixlen);
+	print_escape_buf(sig->tcpm_key, sig->tcpm_keylen, " ,");
+}
+
 #define TCPI_HAS_OPT(info, opt) !!(info->tcpi_options & (opt))
 
 static void tcp_show_info(const struct nlmsghdr *nlh, struct inet_diag_msg *r,
@@ -2289,6 +2299,17 @@ static void tcp_show_info(const struct nlmsghdr *nlh, struct inet_diag_msg *r,
 		free(s.dctcp);
 		free(s.bbr_info);
 	}
+	if (tb[INET_DIAG_MD5SIG]) {
+		struct tcp_diag_md5sig *sig = RTA_DATA(tb[INET_DIAG_MD5SIG]);
+		int len = RTA_PAYLOAD(tb[INET_DIAG_MD5SIG]);
+
+		printf(" md5keys:");
+		print_md5sig(sig++);
+		for (len -= sizeof(*sig); len > 0; len -= sizeof(*sig)) {
+			printf(",");
+			print_md5sig(sig++);
+		}
+	}
 }
 
 static const char *format_host_sa(struct sockaddr_storage *sa)
-- 
2.14.2
