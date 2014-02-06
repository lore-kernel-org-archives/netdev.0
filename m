From: Christoph Paasch <christoph.paasch@uclouvain.be>
Subject: [PATCH iproute2 2/3] tcp_metrics: Display source-address
Date: Thu,  6 Feb 2014 23:15:03 +0100
Message-ID: <1391724904-30504-3-git-send-email-christoph.paasch@uclouvain.be>
References: <1391724904-30504-1-git-send-email-christoph.paasch@uclouvain.be>
Cc: netdev@vger.kernel.org
To: Stephen Hemminger <stephen@networkplumber.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-ee0-f46.google.com ([74.125.83.46]:47031 "EHLO
	mail-ee0-f46.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752223AbaBFWPV (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 6 Feb 2014 17:15:21 -0500
Received: by mail-ee0-f46.google.com with SMTP id c13so1177673eek.33
        for <netdev@vger.kernel.org>; Thu, 06 Feb 2014 14:15:20 -0800 (PST)
In-Reply-To: <1391724904-30504-1-git-send-email-christoph.paasch@uclouvain.be>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

This patch allows to display the source-IP.
stype will be used in the next patch that allows to remove based on the
source-IP.

Signed-off-by: Christoph Paasch <christoph.paasch@uclouvain.be>
---
 include/linux/tcp_metrics.h |  2 ++
 ip/tcp_metrics.c            | 30 ++++++++++++++++++++++++++++--
 2 files changed, 30 insertions(+), 2 deletions(-)

diff --git a/include/linux/tcp_metrics.h b/include/linux/tcp_metrics.h
index cb5157b55f32..54a37b13f2c4 100644
--- a/include/linux/tcp_metrics.h
+++ b/include/linux/tcp_metrics.h
@@ -35,6 +35,8 @@ enum {
 	TCP_METRICS_ATTR_FOPEN_SYN_DROPS,	/* u16, count of drops */
 	TCP_METRICS_ATTR_FOPEN_SYN_DROP_TS,	/* msecs age */
 	TCP_METRICS_ATTR_FOPEN_COOKIE,		/* binary */
+	TCP_METRICS_ATTR_SADDR_IPV4,		/* u32 */
+	TCP_METRICS_ATTR_SADDR_IPV6,		/* binary */
 
 	__TCP_METRICS_ATTR_MAX,
 };
diff --git a/ip/tcp_metrics.c b/ip/tcp_metrics.c
index 4b30771ae3a8..a7215c86379f 100644
--- a/ip/tcp_metrics.c
+++ b/ip/tcp_metrics.c
@@ -95,8 +95,8 @@ static int process_msg(const struct sockaddr_nl *who, struct nlmsghdr *n,
 	struct rtattr *attrs[TCP_METRICS_ATTR_MAX + 1], *a;
 	int len = n->nlmsg_len;
 	char abuf[256];
-	inet_prefix daddr;
-	int family, i, atype, dlen = 0;
+	inet_prefix daddr, saddr;
+	int family, i, atype, stype, dlen = 0, slen = 0;
 
 	if (n->nlmsg_type != genl_family)
 		return -1;
@@ -135,6 +135,26 @@ static int process_msg(const struct sockaddr_nl *who, struct nlmsghdr *n,
 			return 0;
 	}
 
+	a = attrs[TCP_METRICS_ATTR_SADDR_IPV4];
+	if (a) {
+		if (f.saddr.family && f.saddr.family != AF_INET)
+			return 0;
+		memcpy(&saddr.data, RTA_DATA(a), 4);
+		saddr.bytelen = 4;
+		stype = TCP_METRICS_ATTR_SADDR_IPV4;
+		slen = RTA_PAYLOAD(a);
+	} else {
+		a = attrs[TCP_METRICS_ATTR_SADDR_IPV6];
+		if (a) {
+			if (f.saddr.family && f.saddr.family != AF_INET6)
+				return 0;
+			memcpy(&saddr.data, RTA_DATA(a), 16);
+			saddr.bytelen = 16;
+			stype = TCP_METRICS_ATTR_SADDR_IPV6;
+			slen = RTA_PAYLOAD(a);
+		}
+	}
+
 	if (f.daddr.family && f.daddr.bitlen >= 0 &&
 	    inet_addr_match(&daddr, &f.daddr, f.daddr.bitlen))
 		return 0;
@@ -248,6 +268,12 @@ static int process_msg(const struct sockaddr_nl *who, struct nlmsghdr *n,
 		fprintf(fp, " fo_cookie %s", cookie);
 	}
 
+	if (slen) {
+		fprintf(fp, " source %s",
+			format_host(family, slen, &saddr.data, abuf,
+				    sizeof(abuf)));
+	}
+
 	fprintf(fp, "\n");
 
 	fflush(fp);
-- 
1.8.3.2
