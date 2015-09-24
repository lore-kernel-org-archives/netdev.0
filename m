From: "John W. Linville" <linville@tuxdriver.com>
Subject: [PATCH iproute2] geneve: add support for IPv6 link partners
Date: Thu, 24 Sep 2015 14:39:39 -0400
Message-ID: <1443119979-14479-1-git-send-email-linville@tuxdriver.com>
References: <1443119682-14236-1-git-send-email-linville@tuxdriver.com>
Cc: Stephen Hemminger <stephen@networkplumber.org>,
	Pravin B Shelar <pshelar@nicira.com>,
	Jesse Gross <jesse@nicira.com>, davem@davemloft.net,
	"John W. Linville" <linville@tuxdriver.com>
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from charlotte.tuxdriver.com ([70.61.120.58]:46227 "EHLO
	smtp.tuxdriver.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751853AbbIXSkJ (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 24 Sep 2015 14:40:09 -0400
In-Reply-To: <1443119682-14236-1-git-send-email-linville@tuxdriver.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Signed-off-by: John W. Linville <linville@tuxdriver.com>
---
 include/linux/if_link.h |  1 +
 ip/iplink_geneve.c      | 20 +++++++++++++-------
 2 files changed, 14 insertions(+), 7 deletions(-)

diff --git a/include/linux/if_link.h b/include/linux/if_link.h
index 193456660ee8..d0f385579c83 100644
--- a/include/linux/if_link.h
+++ b/include/linux/if_link.h
@@ -410,6 +410,7 @@ enum {
 	IFLA_GENEVE_TOS,
 	IFLA_GENEVE_PORT,	/* destination port */
 	IFLA_GENEVE_COLLECT_METADATA,
+	IFLA_GENEVE_REMOTE6,
 	__IFLA_GENEVE_MAX
 };
 #define IFLA_GENEVE_MAX	(__IFLA_GENEVE_MAX - 1)
diff --git a/ip/iplink_geneve.c b/ip/iplink_geneve.c
index 0a45647844f5..92fae46ed9e4 100644
--- a/ip/iplink_geneve.c
+++ b/ip/iplink_geneve.c
@@ -57,7 +57,7 @@ static int geneve_parse_opt(struct link_util *lu, int argc, char **argv,
 				fprintf(stderr, "Invalid address \"%s\"\n", *argv);
 				return -1;
 			}
-			if (IN_MULTICAST(ntohl(daddr)))
+			if (IN6_IS_ADDR_MULTICAST(&daddr6) || IN_MULTICAST(ntohl(daddr)))
 				invarg("invalid remote address", *argv);
 		} else if (!matches(*argv, "ttl") ||
 			   !matches(*argv, "hoplimit")) {
@@ -102,18 +102,16 @@ static int geneve_parse_opt(struct link_util *lu, int argc, char **argv,
 		return -1;
 	}
 
-	if (!daddr) {
-		fprintf(stderr, "geneve: remove link partner not specified\n");
-		return -1;
-	}
-	if (memcmp(&daddr6, &in6addr_any, sizeof(daddr6)) != 0) {
-		fprintf(stderr, "geneve: remove link over IPv6 not supported\n");
+	if (!daddr && memcmp(&daddr6, &in6addr_any, sizeof(daddr6)) == 0) {
+		fprintf(stderr, "geneve: remote link partner not specified\n");
 		return -1;
 	}
 
 	addattr32(n, 1024, IFLA_GENEVE_ID, vni);
 	if (daddr)
 		addattr_l(n, 1024, IFLA_GENEVE_REMOTE, &daddr, 4);
+	if (memcmp(&daddr6, &in6addr_any, sizeof(daddr6)) != 0)
+		addattr_l(n, 1024, IFLA_GENEVE_REMOTE6, &daddr6, sizeof(struct in6_addr));
 	addattr8(n, 1024, IFLA_GENEVE_TTL, ttl);
 	addattr8(n, 1024, IFLA_GENEVE_TOS, tos);
 
@@ -144,6 +142,14 @@ static void geneve_print_opt(struct link_util *lu, FILE *f, struct rtattr *tb[])
 		if (addr)
 			fprintf(f, "remote %s ",
 				format_host(AF_INET, 4, &addr, s1, sizeof(s1)));
+	} else if (tb[IFLA_GENEVE_REMOTE6]) {
+		struct in6_addr addr;
+		memcpy(&addr, RTA_DATA(tb[IFLA_GENEVE_REMOTE6]), sizeof(struct in6_addr));
+		if (memcmp(&addr, &in6addr_any, sizeof(addr)) != 0) {
+			if (IN6_IS_ADDR_MULTICAST(&addr))
+				fprintf(f, "remote %s ",
+					format_host(AF_INET6, sizeof(struct in6_addr), &addr, s1, sizeof(s1)));
+		}
 	}
 
 	if (tb[IFLA_GENEVE_TTL]) {
-- 
2.4.3
