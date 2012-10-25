From: Pavel Emelyanov <xemul@parallels.com>
Subject: [PATCH 5/5] ss: Show inet and unix sockets' shutdown state
Date: Thu, 25 Oct 2012 17:26:44 +0400
Message-ID: <50893E14.60001@parallels.com>
References: <50893BAF.7030500@parallels.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1
Content-Transfer-Encoding: 7bit
To: Stephen Hemminger <shemminger@vyatta.com>,
	Linux Netdev List <netdev@vger.kernel.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mailhub.sw.ru ([195.214.232.25]:30866 "EHLO relay.sw.ru"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1759018Ab2JYN0p (ORCPT <rfc822;netdev@vger.kernel.org>);
	Thu, 25 Oct 2012 09:26:45 -0400
In-Reply-To: <50893BAF.7030500@parallels.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

To see this we need kernel >=3.7 with _SHUTDOWN nlarrts in diag messages.
The output will look like arrows at the end of each line, like this:

ESTAB 0 0  127.0.0.1:41705  127.0.0.1:12345  ino:143321 sk:ffff88003a8cea00 -->
ESTAB 0 0  127.0.0.1:46925  127.0.0.1:12346  ino:143322 sk:ffff88003a8ce4c0 <--
ESTAB 0 0  127.0.0.1:51678  127.0.0.1:12347  ino:143323 sk:ffff88003a8cdf80 ---
ESTAB 0 0  127.0.0.1:46911  127.0.0.1:12348  ino:143324 sk:ffff88003b7f05c0 <->

for SHUT_RD, SHUT_WR, SHUT_RDWR and non-shutdown sockets respectively.

Signed-off-by: Pavel Emelyanov <xemul@parallels.com>

---
 include/linux/inet_diag.h |    3 ++-
 include/linux/unix_diag.h |    1 +
 misc/ss.c                 |   26 ++++++++++++++++++++------
 3 files changed, 23 insertions(+), 7 deletions(-)

diff --git a/include/linux/inet_diag.h b/include/linux/inet_diag.h
index 8c469af..bbde90f 100644
--- a/include/linux/inet_diag.h
+++ b/include/linux/inet_diag.h
@@ -109,9 +109,10 @@ enum {
 	INET_DIAG_TOS,
 	INET_DIAG_TCLASS,
 	INET_DIAG_SKMEMINFO,
+	INET_DIAG_SHUTDOWN,
 };
 
-#define INET_DIAG_MAX INET_DIAG_SKMEMINFO
+#define INET_DIAG_MAX INET_DIAG_SHUTDOWN
 
 
 /* INET_DIAG_MEM */
diff --git a/include/linux/unix_diag.h b/include/linux/unix_diag.h
index b1d2bf1..b8a2494 100644
--- a/include/linux/unix_diag.h
+++ b/include/linux/unix_diag.h
@@ -37,6 +37,7 @@ enum {
 	UNIX_DIAG_ICONS,
 	UNIX_DIAG_RQLEN,
 	UNIX_DIAG_MEMINFO,
+	UNIX_DIAG_SHUTDOWN,
 
 	UNIX_DIAG_MAX,
 };
diff --git a/misc/ss.c b/misc/ss.c
index a0ab2e9..0b70ee6 100644
--- a/misc/ss.c
+++ b/misc/ss.c
@@ -1327,15 +1327,12 @@ static char *sprint_bw(char *buf, double bw)
 	return buf;
 }
 
-static void tcp_show_info(const struct nlmsghdr *nlh, struct inet_diag_msg *r)
+static void tcp_show_info(const struct nlmsghdr *nlh, struct inet_diag_msg *r,
+		struct rtattr *tb[])
 {
-	struct rtattr * tb[INET_DIAG_MAX+1];
 	char b1[64];
 	double rtt = 0;
 
-	parse_rtattr(tb, INET_DIAG_MAX, (struct rtattr*)(r+1),
-		     nlh->nlmsg_len - NLMSG_LENGTH(sizeof(*r)));
-
 	if (tb[INET_DIAG_SKMEMINFO]) {
 		const __u32 *skmeminfo = RTA_DATA(tb[INET_DIAG_SKMEMINFO]);
 
@@ -1435,6 +1432,10 @@ static int inet_show_sock(struct nlmsghdr *nlh, struct filter *f)
 {
 	struct inet_diag_msg *r = NLMSG_DATA(nlh);
 	struct tcpstat s;
+	struct rtattr * tb[INET_DIAG_MAX+1];
+
+	parse_rtattr(tb, INET_DIAG_MAX, (struct rtattr*)(r+1),
+		     nlh->nlmsg_len - NLMSG_LENGTH(sizeof(*r)));
 
 	s.state = r->idiag_state;
 	s.local.family = s.remote.family = r->idiag_family;
@@ -1484,10 +1485,15 @@ static int inet_show_sock(struct nlmsghdr *nlh, struct filter *f)
 		if (r->id.idiag_cookie[1] != 0)
 			printf("%08x", r->id.idiag_cookie[1]);
  		printf("%08x", r->id.idiag_cookie[0]);
+		if (tb[INET_DIAG_SHUTDOWN]) {
+			unsigned char mask;
+			mask = *(__u8 *)RTA_DATA(tb[INET_DIAG_SHUTDOWN]);
+			printf(" %c-%c", mask & 1 ? '-' : '<', mask & 2 ? '-' : '>');
+		}
 	}
 	if (show_mem || show_tcpinfo) {
 		printf("\n\t");
-		tcp_show_info(nlh, r);
+		tcp_show_info(nlh, r, tb);
 	}
 
 	printf("\n");
@@ -2184,6 +2190,14 @@ static int unix_show_sock(struct nlmsghdr *nlh, struct filter *f)
 			printf(" users:(%s)", ubuf);
 	}
 
+	if (show_details) {
+		if (tb[UNIX_DIAG_SHUTDOWN]) {
+			unsigned char mask;
+			mask = *(__u8 *)RTA_DATA(tb[UNIX_DIAG_SHUTDOWN]);
+			printf(" %c-%c", mask & 1 ? '-' : '<', mask & 2 ? '-' : '>');
+		}
+	}
+
 	printf("\n");
 
 	return 0;
-- 
1.7.1
