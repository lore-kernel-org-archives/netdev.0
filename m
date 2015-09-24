From: Dan Webster <dsw@hexology.net>
Subject: [PATCH iproute2] ss: fix file-based filtering segfault
Date: Thu, 24 Sep 2015 09:36:53 +0200
Message-ID: <1443080213-2553-1-git-send-email-dsw@hexology.net>
Cc: Dan Webster <dsw@hexology.net>,
	Stephen Hemminger <shemming@brocade.com>,
	Vadim Kochan <vadim4j@gmail.com>
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from hexology.net ([92.243.28.49]:36039 "EHLO hexology.net"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1754415AbbIXHrV (ORCPT <rfc822;netdev@vger.kernel.org>);
	Thu, 24 Sep 2015 03:47:21 -0400
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Commit 1527a17 introduced a change where the second of two ssfilter_parse()
calls in ss.c was moved outside of a conditional block (ss.c: ~3575). This
commit enabled the parsing of services, such as 'sport = :ssh', but
inadvertently broke the '-F' file-based filtering:

--
$ cat filt.txt
src 127.0.0.1

$ ss -F filt.txt
Segmentation fault (core dumped)

Program received signal SIGSEGV, Segmentation fault.
yylex () at ssfilter.y:183
183         while (*tokptr == 0) {
--

The first (redundant) ssfilter_parse() was mangling yylex() for the latter
call.

Signed-off-by: Dan Webster <dsw@hexology.net>
---
 misc/ss.c | 6 ------
 1 file changed, 6 deletions(-)

diff --git a/misc/ss.c b/misc/ss.c
index 9efc3c8..7c3dfa3 100644
--- a/misc/ss.c
+++ b/misc/ss.c
@@ -3782,12 +3782,6 @@ int main(int argc, char *argv[])
 			exit(0);
 	}
 
-	/* Now parse filter... */
-	if (argc == 0 && filter_fp) {
-		if (ssfilter_parse(&current_filter.f, 0, NULL, filter_fp))
-			usage();
-	}
-
 	while (argc > 0) {
 		if (strcmp(*argv, "state") == 0) {
 			NEXT_ARG();
-- 
2.1.4
