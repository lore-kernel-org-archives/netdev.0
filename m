From: David Ahern <dsa@cumulusnetworks.com>
Subject: [iproute2 net-next v2 1/3] netlink: Add flag to suppress print of nlmsg error
Date: Thu, 23 Mar 2017 19:51:20 -0700
Message-ID: <1490323882-11609-2-git-send-email-dsa@cumulusnetworks.com>
References: <1490323882-11609-1-git-send-email-dsa@cumulusnetworks.com>
Cc: nicolas.dichtel@6wind.com, David Ahern <dsa@cumulusnetworks.com>
To: netdev@vger.kernel.org, stephen@networkplumber.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-pf0-f171.google.com ([209.85.192.171]:36704 "EHLO
        mail-pf0-f171.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S934798AbdCXCvb (ORCPT
        <rfc822;netdev@vger.kernel.org>); Thu, 23 Mar 2017 22:51:31 -0400
Received: by mail-pf0-f171.google.com with SMTP id o126so1186358pfb.3
        for <netdev@vger.kernel.org>; Thu, 23 Mar 2017 19:51:30 -0700 (PDT)
In-Reply-To: <1490323882-11609-1-git-send-email-dsa@cumulusnetworks.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Allow callers of the dump API to handle nlmsg errors (e.g., an
unsupported feature). Setting RTNL_HANDLE_F_SUPPRESS_NLERR in the
rtnl_handle avoids unnecessary messages to the users in some case.
For example,

  RTNETLINK answers: Operation not supported

when probing for support of a new feature.

Signed-off-by: David Ahern <dsa@cumulusnetworks.com>
---
 include/libnetlink.h | 1 +
 lib/libnetlink.c     | 3 ++-
 2 files changed, 3 insertions(+), 1 deletion(-)

diff --git a/include/libnetlink.h b/include/libnetlink.h
index bd0267dfcc02..c43ab0a2d9d9 100644
--- a/include/libnetlink.h
+++ b/include/libnetlink.h
@@ -21,6 +21,7 @@ struct rtnl_handle {
 	int			proto;
 	FILE		       *dump_fp;
 #define RTNL_HANDLE_F_LISTEN_ALL_NSID		0x01
+#define RTNL_HANDLE_F_SUPPRESS_NLERR		0x02
 	int			flags;
 };
 
diff --git a/lib/libnetlink.c b/lib/libnetlink.c
index 9303b6686e2c..5b75b2db4e0b 100644
--- a/lib/libnetlink.c
+++ b/lib/libnetlink.c
@@ -299,7 +299,8 @@ static void rtnl_dump_error(const struct rtnl_handle *rth,
 		     errno == EOPNOTSUPP))
 			return;
 
-		perror("RTNETLINK answers");
+		if (!(rth->flags & RTNL_HANDLE_F_SUPPRESS_NLERR))
+			perror("RTNETLINK answers");
 	}
 }
 
-- 
2.1.4
