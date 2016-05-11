From: David Ahern <dsa@cumulusnetworks.com>
Subject: [PATCH iproute2] ip link: Add support for kernel side filtering
Date: Wed, 11 May 2016 06:51:58 -0700
Message-ID: <1462974718-12860-1-git-send-email-dsa@cumulusnetworks.com>
Cc: David Ahern <dsa@cumulusnetworks.com>
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-pa0-f53.google.com ([209.85.220.53]:35859 "EHLO
	mail-pa0-f53.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S932825AbcEKNwE (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 11 May 2016 09:52:04 -0400
Received: by mail-pa0-f53.google.com with SMTP id bt5so17856274pac.3
        for <netdev@vger.kernel.org>; Wed, 11 May 2016 06:52:04 -0700 (PDT)
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Kernel gained support for filtering link dumps with commit dc599f76c22b
("net: Add support for filtering link dump by master device and kind").
Add support to ip link command. If a user passes master device or
kind to ip link command they are added to the link dump request message.

Signed-off-by: David Ahern <dsa@cumulusnetworks.com>
---
 include/libnetlink.h |  6 ++++++
 ip/ipaddress.c       | 33 ++++++++++++++++++++++++++++++++-
 lib/libnetlink.c     | 28 ++++++++++++++++++++++++++++
 3 files changed, 66 insertions(+), 1 deletion(-)

diff --git a/include/libnetlink.h b/include/libnetlink.h
index 491263f7e103..f7b85dccef36 100644
--- a/include/libnetlink.h
+++ b/include/libnetlink.h
@@ -38,6 +38,12 @@ int rtnl_wilddump_request(struct rtnl_handle *rth, int fam, int type)
 int rtnl_wilddump_req_filter(struct rtnl_handle *rth, int fam, int type,
 				    __u32 filt_mask)
 	__attribute__((warn_unused_result));
+
+typedef int (*req_filter_fn_t)(struct nlmsghdr *nlh, int reqlen);
+
+int rtnl_wilddump_req_filter_fn(struct rtnl_handle *rth, int fam, int type,
+				req_filter_fn_t fn)
+	__attribute__((warn_unused_result));
 int rtnl_dump_request(struct rtnl_handle *rth, int type, void *req,
 			     int len)
 	__attribute__((warn_unused_result));
diff --git a/ip/ipaddress.c b/ip/ipaddress.c
index aac7970e16dd..0692fbacd669 100644
--- a/ip/ipaddress.c
+++ b/ip/ipaddress.c
@@ -1476,6 +1476,36 @@ static int ipaddr_flush(void)
 	return 1;
 }
 
+static int iplink_filter_req(struct nlmsghdr *nlh, int reqlen)
+{
+	int err;
+
+	err = addattr32(nlh, reqlen, IFLA_EXT_MASK, RTEXT_FILTER_VF);
+	if (err)
+		return err;
+
+	if (filter.master) {
+		err = addattr32(nlh, reqlen, IFLA_MASTER, filter.master);
+		if (err)
+			return err;
+	}
+
+	if (filter.kind) {
+		struct rtattr *linkinfo;
+
+		linkinfo = addattr_nest(nlh, reqlen, IFLA_LINKINFO);
+
+		err = addattr_l(nlh, reqlen, IFLA_INFO_KIND, filter.kind,
+				strlen(filter.kind));
+		if (err)
+			return err;
+
+		addattr_nest_end(nlh, linkinfo);
+	}
+
+	return 0;
+}
+
 static int ipaddr_list_flush_or_save(int argc, char **argv, int action)
 {
 	struct nlmsg_chain linfo = { NULL, NULL};
@@ -1638,7 +1668,8 @@ static int ipaddr_list_flush_or_save(int argc, char **argv, int action)
 		exit(0);
 	}
 
-	if (rtnl_wilddump_request(&rth, preferred_family, RTM_GETLINK) < 0) {
+	if (rtnl_wilddump_req_filter_fn(&rth, preferred_family, RTM_GETLINK,
+					iplink_filter_req) < 0) {
 		perror("Cannot send dump request");
 		exit(1);
 	}
diff --git a/lib/libnetlink.c b/lib/libnetlink.c
index a90e52ca2c0a..0adcbf3f6e38 100644
--- a/lib/libnetlink.c
+++ b/lib/libnetlink.c
@@ -129,6 +129,34 @@ int rtnl_wilddump_req_filter(struct rtnl_handle *rth, int family, int type,
 	return send(rth->fd, (void*)&req, sizeof(req), 0);
 }
 
+int rtnl_wilddump_req_filter_fn(struct rtnl_handle *rth, int family, int type,
+				req_filter_fn_t filter_fn)
+{
+	struct {
+		struct nlmsghdr nlh;
+		struct ifinfomsg ifm;
+		char buf[1024];
+	} req;
+	int err;
+
+	if (!filter_fn)
+		return -EINVAL;
+
+	memset(&req, 0, sizeof(req));
+	req.nlh.nlmsg_len = NLMSG_LENGTH(sizeof(struct ifinfomsg));
+	req.nlh.nlmsg_type = type;
+	req.nlh.nlmsg_flags = NLM_F_DUMP|NLM_F_REQUEST;
+	req.nlh.nlmsg_pid = 0;
+	req.nlh.nlmsg_seq = rth->dump = ++rth->seq;
+	req.ifm.ifi_family = family;
+
+	err = filter_fn(&req.nlh, sizeof(req));
+	if (err)
+		return err;
+
+	return send(rth->fd, (void*)&req, sizeof(req), 0);
+}
+
 int rtnl_send(struct rtnl_handle *rth, const void *buf, int len)
 {
 	return send(rth->fd, buf, len, 0);
-- 
2.1.4
