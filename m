From: Pavel Emelyanov <xemul@parallels.com>
Subject: [PATCH] ss:  Show inet and unix sockets' shutdown state
Date: Fri, 17 May 2013 19:02:01 +0400
Message-ID: <51964669.7020503@parallels.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1
Content-Transfer-Encoding: 7bit
To: Stephen Hemminger <shemminger@linux-foundation.org>,
	Linux Netdev List <netdev@vger.kernel.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mailhub.sw.ru ([195.214.232.25]:9119 "EHLO relay.sw.ru"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1755395Ab3EQPCM (ORCPT <rfc822;netdev@vger.kernel.org>);
	Fri, 17 May 2013 11:02:12 -0400
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

When extended info is requested (-e option) one will be able to observe
arrows in the output, like this:

ESTAB 0 0  127.0.0.1:41705  127.0.0.1:12345  ino:143321 sk:ffff88003a8cea00 -->
ESTAB 0 0  127.0.0.1:46925  127.0.0.1:12346  ino:143322 sk:ffff88003a8ce4c0 <--
ESTAB 0 0  127.0.0.1:51678  127.0.0.1:12347  ino:143323 sk:ffff88003a8cdf80 ---
ESTAB 0 0  127.0.0.1:46911  127.0.0.1:12348  ino:143324 sk:ffff88003b7f05c0 <->

for SHUT_RD, SHUT_WR, SHUT_RDWR and non-shutdown sockets respectively.

The respective nlattrs in *_diag messages has appeared in Linux v3.7 and
are already present in ss's headers.

Signed-off-by: Pavel Emelyanov <xemul@parallels.com>

---

diff --git a/misc/ss.c b/misc/ss.c
index 5493630..c32574c 100644
--- a/misc/ss.c
+++ b/misc/ss.c
@@ -1350,15 +1350,12 @@ static void print_skmeminfo(struct rtattr *tb[], int attrtype)
 	printf(")");
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
 		print_skmeminfo(tb, INET_DIAG_SKMEMINFO);
 	} else if (tb[INET_DIAG_MEMINFO]) {
@@ -1443,9 +1440,13 @@ static void tcp_show_info(const struct nlmsghdr *nlh, struct inet_diag_msg *r)
 
 static int inet_show_sock(struct nlmsghdr *nlh, struct filter *f)
 {
+	struct rtattr * tb[INET_DIAG_MAX+1];
 	struct inet_diag_msg *r = NLMSG_DATA(nlh);
 	struct tcpstat s;
 
+	parse_rtattr(tb, INET_DIAG_MAX, (struct rtattr*)(r+1),
+		     nlh->nlmsg_len - NLMSG_LENGTH(sizeof(*r)));
+
 	s.state = r->idiag_state;
 	s.local.family = s.remote.family = r->idiag_family;
 	s.lport = ntohs(r->id.idiag_sport);
@@ -1494,10 +1495,15 @@ static int inet_show_sock(struct nlmsghdr *nlh, struct filter *f)
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
@@ -2203,6 +2209,14 @@ static int unix_show_sock(struct nlmsghdr *nlh, struct filter *f)
 		print_skmeminfo(tb, UNIX_DIAG_MEMINFO);
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
