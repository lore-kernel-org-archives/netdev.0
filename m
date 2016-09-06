From: Hangbin Liu <liuhangbin@gmail.com>
Subject: [PATCH iproute2] ip route: check ftell, fseek return value
Date: Tue,  6 Sep 2016 14:39:50 +0800
Message-ID: <1473143990-9291-1-git-send-email-liuhangbin@gmail.com>
Cc: Phil Sutter <phil@nwl.cc>,
        Stephen Hemminger <stephen@networkplumber.org>,
        Hangbin Liu <liuhangbin@gmail.com>
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-pa0-f67.google.com ([209.85.220.67]:36319 "EHLO
        mail-pa0-f67.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1752088AbcIFGkF (ORCPT
        <rfc822;netdev@vger.kernel.org>); Tue, 6 Sep 2016 02:40:05 -0400
Received: by mail-pa0-f67.google.com with SMTP id ez1so10430652pab.3
        for <netdev@vger.kernel.org>; Mon, 05 Sep 2016 23:40:05 -0700 (PDT)
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

ftell() may return -1 in error case, which is not handled and therefore pass a
negative offset to fseek(). The return code of fseek() is also not checked.

Reported-by: Phil Sutter <phil@nwl.cc>
Signed-off-by: Hangbin Liu <liuhangbin@gmail.com>
---
 ip/iproute.c | 11 +++++++++--
 1 file changed, 9 insertions(+), 2 deletions(-)

diff --git a/ip/iproute.c b/ip/iproute.c
index 3da23af..ba877dc 100644
--- a/ip/iproute.c
+++ b/ip/iproute.c
@@ -1859,7 +1859,11 @@ static int iproute_restore(void)
 	if (route_dump_check_magic())
 		exit(-1);
 
-	pos = ftell(stdin);
+	if ((pos = ftell(stdin)) == -1) {
+		perror("Failed to restore: ftell");
+		exit(errno);
+	}
+
 	for (prio = 0; prio < 3; prio++) {
 		int err;
 
@@ -1867,7 +1871,10 @@ static int iproute_restore(void)
 		if (err)
 			exit(err);
 
-		fseek(stdin, pos, SEEK_SET);
+		if (fseek(stdin, pos, SEEK_SET) == -1) {
+			perror("Failed to restore: fseek");
+			exit(errno);
+		}
 	}
 
 	exit(0);
-- 
2.5.5
