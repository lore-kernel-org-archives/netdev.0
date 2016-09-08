From: Hangbin Liu <liuhangbin@gmail.com>
Subject: [PATCHv2 iproute2] ip route: check ftell, fseek return value
Date: Thu,  8 Sep 2016 10:26:57 +0800
Message-ID: <1473301617-9123-1-git-send-email-liuhangbin@gmail.com>
Cc: David Laight <David.Laight@ACULAB.COM>, Phil Sutter <phil@nwl.cc>,
        Stephen Hemminger <stephen@networkplumber.org>,
        Hangbin Liu <liuhangbin@gmail.com>
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-pa0-f67.google.com ([209.85.220.67]:35532 "EHLO
        mail-pa0-f67.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1751529AbcIHC1T (ORCPT
        <rfc822;netdev@vger.kernel.org>); Wed, 7 Sep 2016 22:27:19 -0400
Received: by mail-pa0-f67.google.com with SMTP id pp5so1698960pac.2
        for <netdev@vger.kernel.org>; Wed, 07 Sep 2016 19:27:19 -0700 (PDT)
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

ftell() may return -1 in error case, which is not handled and therefore pass a
negative offset to fseek(). The return code of fseek() is also not checked.

Reported-by: Phil Sutter <phil@nwl.cc>
Signed-off-by: Hangbin Liu <liuhangbin@gmail.com>
---
 ip/iproute.c | 10 +++++++++-
 1 file changed, 9 insertions(+), 1 deletion(-)

diff --git a/ip/iproute.c b/ip/iproute.c
index 3da23af..c06a474 100644
--- a/ip/iproute.c
+++ b/ip/iproute.c
@@ -1860,6 +1860,11 @@ static int iproute_restore(void)
 		exit(-1);
 
 	pos = ftell(stdin);
+	if (pos == -1) {
+		perror("Failed to restore: ftell");
+		exit(-1);
+	}
+
 	for (prio = 0; prio < 3; prio++) {
 		int err;
 
@@ -1867,7 +1872,10 @@ static int iproute_restore(void)
 		if (err)
 			exit(err);
 
-		fseek(stdin, pos, SEEK_SET);
+		if (fseek(stdin, pos, SEEK_SET) == -1) {
+			perror("Failed to restore: fseek");
+			exit(-1);
+		}
 	}
 
 	exit(0);
-- 
2.5.5
