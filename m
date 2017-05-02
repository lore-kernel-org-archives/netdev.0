From: David Ahern <dsa@cumulusnetworks.com>
Subject: [PATCH net-next iproute2 3/3] ip link: Add extack handling for setlink
Date: Mon,  1 May 2017 20:18:25 -0700
Message-ID: <1493695105-9418-4-git-send-email-dsa@cumulusnetworks.com>
References: <1493695105-9418-1-git-send-email-dsa@cumulusnetworks.com>
Cc: jakub.kicinski@netronome.com, David Ahern <dsa@cumulusnetworks.com>
To: netdev@vger.kernel.org, stephen@networkplumber.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-pg0-f41.google.com ([74.125.83.41]:36423 "EHLO
        mail-pg0-f41.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1751194AbdEBDSc (ORCPT
        <rfc822;netdev@vger.kernel.org>); Mon, 1 May 2017 23:18:32 -0400
Received: by mail-pg0-f41.google.com with SMTP id t7so53616361pgt.3
        for <netdev@vger.kernel.org>; Mon, 01 May 2017 20:18:32 -0700 (PDT)
In-Reply-To: <1493695105-9418-1-git-send-email-dsa@cumulusnetworks.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Flip iplink_modify to rtnl_talk_extack. For this first patch only
error messages returned from the kernel are displayed to the user.

Follow on patches can add parsing of the returned message and the
error offset to show which attribute caused an error.

Signed-off-by: David Ahern <dsa@cumulusnetworks.com>
---
 ip/iplink.c | 18 ++++++++++++++++--
 1 file changed, 16 insertions(+), 2 deletions(-)

diff --git a/ip/iplink.c b/ip/iplink.c
index ae1c70ebcc81..aad0220a63a7 100644
--- a/ip/iplink.c
+++ b/ip/iplink.c
@@ -861,6 +861,19 @@ int iplink_parse(int argc, char **argv, struct iplink_req *req,
 	return ret - argc;
 }
 
+static int iplink_extack(const char *errmsg, __u32 off,
+			 struct nlmsghdr *err_nlh)
+{
+	int rc = 0;
+
+	if (errmsg) {
+		rc++;
+		fprintf(stderr, "Error: %s\n", errmsg);
+	}
+
+	return rc;
+}
+
 static int iplink_modify(int cmd, unsigned int flags, int argc, char **argv)
 {
 	int len;
@@ -906,7 +919,8 @@ static int iplink_modify(int cmd, unsigned int flags, int argc, char **argv)
 
 			req.i.ifi_index = 0;
 			addattr32(&req.n, sizeof(req), IFLA_GROUP, group);
-			if (rtnl_talk(&rth, &req.n, NULL, 0) < 0)
+			if (rtnl_talk_extack(&rth, &req.n, NULL, 0,
+					     iplink_extack) < 0)
 				return -2;
 			return 0;
 		}
@@ -1001,7 +1015,7 @@ static int iplink_modify(int cmd, unsigned int flags, int argc, char **argv)
 		return -1;
 	}
 
-	if (rtnl_talk(&rth, &req.n, NULL, 0) < 0)
+	if (rtnl_talk_extack(&rth, &req.n, NULL, 0, iplink_extack) < 0)
 		return -2;
 
 	return 0;
-- 
2.1.4
