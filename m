From: Phil Sutter <phil@nwl.cc>
Subject: [iproute PATCH v3 2/5] libnetlink: introduce nc_flags
Date: Tue, 24 Nov 2015 15:31:01 +0100
Message-ID: <1448375464-12145-3-git-send-email-phil@nwl.cc>
References: <20151123163115.5f8be482@xeon-e3>
 <1448375464-12145-1-git-send-email-phil@nwl.cc>
Cc: netdev@vger.kernel.org
To: Stephen Hemminger <shemming@brocade.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from orbit.nwl.cc ([176.31.251.142]:40652 "EHLO mail.nwl.cc"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1753317AbbKXObX (ORCPT <rfc822;netdev@vger.kernel.org>);
	Tue, 24 Nov 2015 09:31:23 -0500
In-Reply-To: <1448375464-12145-1-git-send-email-phil@nwl.cc>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Allow for a filter to ignore certain nlmsg_flags.

Signed-off-by: Phil Sutter <phil@nwl.cc>
---
 include/libnetlink.h |  7 ++++++-
 lib/libnetlink.c     | 10 ++++++----
 2 files changed, 12 insertions(+), 5 deletions(-)

diff --git a/include/libnetlink.h b/include/libnetlink.h
index 2280c39..431189e 100644
--- a/include/libnetlink.h
+++ b/include/libnetlink.h
@@ -60,11 +60,16 @@ struct rtnl_dump_filter_arg
 {
 	rtnl_filter_t filter;
 	void *arg1;
+	__u16 nc_flags;
 };
 
 int rtnl_dump_filter_l(struct rtnl_handle *rth,
 			      const struct rtnl_dump_filter_arg *arg);
-int rtnl_dump_filter(struct rtnl_handle *rth, rtnl_filter_t filter, void *arg);
+int rtnl_dump_filter_nc(struct rtnl_handle *rth,
+			rtnl_filter_t filter,
+			void *arg, __u16 nc_flags);
+#define rtnl_dump_filter(rth, filter, arg) \
+	rtnl_dump_filter_nc(rth, filter, arg, 0)
 int rtnl_talk(struct rtnl_handle *rtnl, struct nlmsghdr *n,
 	      struct nlmsghdr *answer, size_t len)
 	__attribute__((warn_unused_result));
diff --git a/lib/libnetlink.c b/lib/libnetlink.c
index 09b0e91..922ec2d 100644
--- a/lib/libnetlink.c
+++ b/lib/libnetlink.c
@@ -259,6 +259,8 @@ int rtnl_dump_filter_l(struct rtnl_handle *rth,
 			while (NLMSG_OK(h, msglen)) {
 				int err = 0;
 
+				h->nlmsg_flags &= ~a->nc_flags;
+
 				if (nladdr.nl_pid != 0 ||
 				    h->nlmsg_pid != rth->local.nl_pid ||
 				    h->nlmsg_seq != rth->dump)
@@ -317,13 +319,13 @@ skip_it:
 	}
 }
 
-int rtnl_dump_filter(struct rtnl_handle *rth,
+int rtnl_dump_filter_nc(struct rtnl_handle *rth,
 		     rtnl_filter_t filter,
-		     void *arg1)
+		     void *arg1, __u16 nc_flags)
 {
 	const struct rtnl_dump_filter_arg a[2] = {
-		{ .filter = filter, .arg1 = arg1, },
-		{ .filter = NULL,   .arg1 = NULL, },
+		{ .filter = filter, .arg1 = arg1, .nc_flags = nc_flags, },
+		{ .filter = NULL,   .arg1 = NULL, .nc_flags = 0, },
 	};
 
 	return rtnl_dump_filter_l(rth, a);
-- 
2.5.0
