From: Lorenzo Colitti <lorenzo@google.com>
Subject: [ss PATCH 1/2] libnetlink: ignore some errors from SOCK_DIAG_BY_FAMILY
Date: Wed, 18 Nov 2015 10:52:09 +0900
Message-ID: <1447811530-10756-2-git-send-email-lorenzo@google.com>
References: <1447811530-10756-1-git-send-email-lorenzo@google.com>
Cc: edumazet@google.com, ek@google.com, maze@google.com,
	dtor@google.com, Lorenzo Colitti <lorenzo@google.com>
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-pa0-f44.google.com ([209.85.220.44]:33008 "EHLO
	mail-pa0-f44.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1754540AbbKRBw3 (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 17 Nov 2015 20:52:29 -0500
Received: by pabfh17 with SMTP id fh17so28052485pab.0
        for <netdev@vger.kernel.org>; Tue, 17 Nov 2015 17:52:29 -0800 (PST)
In-Reply-To: <1447811530-10756-1-git-send-email-lorenzo@google.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

rtnl_dump ignors ENOENT or EOPNOTSUPP when attempting
SOCK_DIAG_BY_FAMILY dumps. Do the same in rtnl_talk.

Signed-off-by: Lorenzo Colitti <lorenzo@google.com>
---
 include/libnetlink.h | 3 +++
 lib/libnetlink.c     | 5 +++++
 2 files changed, 8 insertions(+)

diff --git a/include/libnetlink.h b/include/libnetlink.h
index 2280c39..9855fd5 100644
--- a/include/libnetlink.h
+++ b/include/libnetlink.h
@@ -65,6 +65,9 @@ struct rtnl_dump_filter_arg
 int rtnl_dump_filter_l(struct rtnl_handle *rth,
 			      const struct rtnl_dump_filter_arg *arg);
 int rtnl_dump_filter(struct rtnl_handle *rth, rtnl_filter_t filter, void *arg);
+int rtnl_talk_l(struct rtnl_handle *rtnl, struct nlmsghdr *n,
+	      struct nlmsghdr *answer, size_t len, int expect_success)
+	__attribute__((warn_unused_result));
 int rtnl_talk(struct rtnl_handle *rtnl, struct nlmsghdr *n,
 	      struct nlmsghdr *answer, size_t len)
 	__attribute__((warn_unused_result));
diff --git a/lib/libnetlink.c b/lib/libnetlink.c
index 09b0e91..7e768a6 100644
--- a/lib/libnetlink.c
+++ b/lib/libnetlink.c
@@ -417,6 +417,11 @@ int rtnl_talk(struct rtnl_handle *rtnl, struct nlmsghdr *n,
 					return 0;
 				}
 
+				if (rtnl->proto == NETLINK_SOCK_DIAG &&
+				    (errno == ENOENT ||
+				     errno == EOPNOTSUPP))
+					return -1;
+
 				fprintf(stderr, "RTNETLINK answers: %s\n",
 					strerror(-err->error));
 				errno = -err->error;
-- 
2.6.0.rc2.230.g3dd15c0
