From: Eric Dumazet <eric.dumazet@gmail.com>
Subject: [PATCH iproute2] ss: report SK_MEMINFO_BACKLOG
Date: Thu, 26 Jul 2012 11:20:20 +0200
Message-ID: <1343294420.2626.11264.camel@edumazet-glaptop>
Mime-Version: 1.0
Content-Type: text/plain; charset="UTF-8"
Content-Transfer-Encoding: 7bit
Cc: netdev <netdev@vger.kernel.org>,
	Vijay Subramanian <subramanian.vijay@gmail.com>
To: Stephen Hemminger <shemminger@vyatta.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-bk0-f46.google.com ([209.85.214.46]:47702 "EHLO
	mail-bk0-f46.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751131Ab2GZJUZ (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 26 Jul 2012 05:20:25 -0400
Received: by bkwj10 with SMTP id j10so1127173bkw.19
        for <netdev@vger.kernel.org>; Thu, 26 Jul 2012 02:20:24 -0700 (PDT)
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Eric Dumazet <edumazet@google.com>

linux-3.6-rc1 supports SK_MEMINFO_BACKLOG with commit d594e987c6f54
(sock_diag: add SK_MEMINFO_BACKLOG)

ss command can display it if provided by the kernel.

Signed-off-by: Eric Dumazet <edumazet@google.com>
Cc: Vijay Subramanian <subramanian.vijay@gmail.com>
---
 include/linux/sock_diag.h |    1 +
 misc/ss.c                 |   13 ++++++++++---
 2 files changed, 11 insertions(+), 3 deletions(-)

diff --git a/include/linux/sock_diag.h b/include/linux/sock_diag.h
index 39e4b1c..ac9db19 100644
--- a/include/linux/sock_diag.h
+++ b/include/linux/sock_diag.h
@@ -18,6 +18,7 @@ enum {
 	SK_MEMINFO_FWD_ALLOC,
 	SK_MEMINFO_WMEM_QUEUED,
 	SK_MEMINFO_OPTMEM,
+	SK_MEMINFO_BACKLOG,
 
 	SK_MEMINFO_VARS,
 };
diff --git a/misc/ss.c b/misc/ss.c
index cf529ef..d8429cc 100644
--- a/misc/ss.c
+++ b/misc/ss.c
@@ -1337,8 +1337,9 @@ static void tcp_show_info(const struct nlmsghdr *nlh, struct inet_diag_msg *r)
 		     nlh->nlmsg_len - NLMSG_LENGTH(sizeof(*r)));
 
 	if (tb[INET_DIAG_SKMEMINFO]) {
-		const __u32 *skmeminfo =  RTA_DATA(tb[INET_DIAG_SKMEMINFO]);
-		printf(" skmem:(r%u,rb%u,t%u,tb%u,f%u,w%u,o%u)",
+		const __u32 *skmeminfo = RTA_DATA(tb[INET_DIAG_SKMEMINFO]);
+
+		printf(" skmem:(r%u,rb%u,t%u,tb%u,f%u,w%u,o%u",
 			skmeminfo[SK_MEMINFO_RMEM_ALLOC],
 			skmeminfo[SK_MEMINFO_RCVBUF],
 			skmeminfo[SK_MEMINFO_WMEM_ALLOC],
@@ -1346,7 +1347,13 @@ static void tcp_show_info(const struct nlmsghdr *nlh, struct inet_diag_msg *r)
 			skmeminfo[SK_MEMINFO_FWD_ALLOC],
 			skmeminfo[SK_MEMINFO_WMEM_QUEUED],
 			skmeminfo[SK_MEMINFO_OPTMEM]);
-	}else if (tb[INET_DIAG_MEMINFO]) {
+
+		if (RTA_PAYLOAD(tb[INET_DIAG_SKMEMINFO]) >=
+			(SK_MEMINFO_BACKLOG + 1) * sizeof(__u32))
+			printf(",bl%u", skmeminfo[SK_MEMINFO_BACKLOG]);
+
+		printf(")");
+	} else if (tb[INET_DIAG_MEMINFO]) {
 		const struct inet_diag_meminfo *minfo
 			= RTA_DATA(tb[INET_DIAG_MEMINFO]);
 		printf(" mem:(r%u,w%u,f%u,t%u)",
