From: Andrei Vagin <avagin@openvz.org>
Subject: [PATCH] ss: replace all zero characters in a unix name to '@'
Date: Sat,  1 Apr 2017 04:31:57 +0300
Message-ID: <1491010317-27083-1-git-send-email-avagin@openvz.org>
Cc: netdev@vger.kernel.org, Andrei Vagin <avagin@virtuozzo.com>
To: stephen@networkplumber.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-pf0-f194.google.com ([209.85.192.194]:34868 "EHLO
        mail-pf0-f194.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1754944AbdDABcC (ORCPT
        <rfc822;netdev@vger.kernel.org>); Fri, 31 Mar 2017 21:32:02 -0400
Received: by mail-pf0-f194.google.com with SMTP id n11so2813390pfg.2
        for <netdev@vger.kernel.org>; Fri, 31 Mar 2017 18:32:02 -0700 (PDT)
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Andrei Vagin <avagin@virtuozzo.com>

A name of an abstract socket can contain zero characters.
Now we replace only the first character. If a name contains more
than one zero character, the ss tool shows only a part of the name:
u_str  UNCONN    0    0     @                            1931097   * 0

the output with this patch:
u_str  UNCONN    0    0     @@zdtm-./sk-unix-unconn-23/@ 1931097   * 0

Signed-off-by: Andrei Vagin <avagin@virtuozzo.com>
---
 misc/ss.c | 16 +++++++++++++++-
 1 file changed, 15 insertions(+), 1 deletion(-)

diff --git a/misc/ss.c b/misc/ss.c
index 5cda728..a3200a1 100644
--- a/misc/ss.c
+++ b/misc/ss.c
@@ -2726,10 +2726,24 @@ static int unix_show_sock(const struct sockaddr_nl *addr, struct nlmsghdr *nlh,
 	if (tb[UNIX_DIAG_NAME]) {
 		int len = RTA_PAYLOAD(tb[UNIX_DIAG_NAME]);
 
+		if (len > sizeof(name) - 1)
+			len = sizeof(name) - 1;
+
 		memcpy(name, RTA_DATA(tb[UNIX_DIAG_NAME]), len);
 		name[len] = '\0';
-		if (name[0] == '\0')
+		if (name[0] == '\0') {
+			char *n;
+
 			name[0] = '@';
+
+			n = name + 1;
+			while (n && n < name + len) {
+				n = memchr(n, 0, name + len - n);
+				if (n == NULL)
+					break;
+				*n = '@';
+			}
+		}
 		stat.name = &name[0];
 		memcpy(stat.local.data, &stat.name, sizeof(stat.name));
 	}
-- 
2.7.4
