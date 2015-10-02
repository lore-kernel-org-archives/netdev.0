From: David Ahern <dsa@cumulusnetworks.com>
Subject: [PATCH] ip neigh: Add support for filtering dumps by master device
Date: Fri,  2 Oct 2015 09:42:27 -0700
Message-ID: <1443804147-40174-1-git-send-email-dsa@cumulusnetworks.com>
Cc: dsahern@gmail.com, David Ahern <dsa@cumulusnetworks.com>
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-pa0-f49.google.com ([209.85.220.49]:35878 "EHLO
	mail-pa0-f49.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751781AbbJBQme (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 2 Oct 2015 12:42:34 -0400
Received: by pablk4 with SMTP id lk4so110217150pab.3
        for <netdev@vger.kernel.org>; Fri, 02 Oct 2015 09:42:33 -0700 (PDT)
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Add support for filtering neighbor dumps by master device. Kernel side
support provided by commit 21fdd092acc7. Since the feature is not
available in older kernels the user is given a warning message if the
kernel does not support the request.

Signed-off-by: David Ahern <dsa@cumulusnetworks.com>
---
 include/libnetlink.h |  2 ++
 ip/ipneigh.c         | 35 +++++++++++++++++++++++++++++++----
 lib/libnetlink.c     | 21 +++++++++++++++++++++
 3 files changed, 54 insertions(+), 4 deletions(-)

diff --git a/include/libnetlink.h b/include/libnetlink.h
index 0503dea5c367..4813359172ca 100644
--- a/include/libnetlink.h
+++ b/include/libnetlink.h
@@ -42,6 +42,8 @@ int rtnl_wilddump_req_filter(struct rtnl_handle *rth, int fam, int type,
 int rtnl_dump_request(struct rtnl_handle *rth, int type, void *req,
 			     int len)
 	__attribute__((warn_unused_result));
+int rtnl_dump_request_n(struct rtnl_handle *rth, struct nlmsghdr *n)
+	__attribute__((warn_unused_result));
 
 struct rtnl_ctrl_data {
 	int	nsid;
diff --git a/ip/ipneigh.c b/ip/ipneigh.c
index a9e23f450c16..ba25a00b2a78 100644
--- a/ip/ipneigh.c
+++ b/ip/ipneigh.c
@@ -39,6 +39,7 @@ static struct
 	char *flushb;
 	int flushp;
 	int flushe;
+	int master;
 } filter;
 
 static void usage(void) __attribute__((noreturn));
@@ -193,6 +194,7 @@ int print_neigh(const struct sockaddr_nl *who, struct nlmsghdr *n, void *arg)
 	int len = n->nlmsg_len;
 	struct rtattr * tb[NDA_MAX+1];
 	char abuf[256];
+	static int logit = 1;
 
 	if (n->nlmsg_type != RTM_NEWNEIGH && n->nlmsg_type != RTM_DELNEIGH &&
 	    n->nlmsg_type != RTM_GETNEIGH) {
@@ -220,6 +222,14 @@ int print_neigh(const struct sockaddr_nl *who, struct nlmsghdr *n, void *arg)
              (r->ndm_family != AF_DECnet))
 		return 0;
 
+	if (filter.master && !(n->nlmsg_flags & NLM_F_DUMP_FILTERED)) {
+		if (logit) {
+			logit = 0;
+			fprintf(fp,
+				"\nWARNING: Kernel does not support filtering by master device\n\n");
+		}
+	}
+
 	parse_rtattr(tb, NDA_MAX, NDA_RTA(r), n->nlmsg_len - NLMSG_LENGTH(sizeof(*r)));
 
 	if (tb[NDA_DST]) {
@@ -327,9 +337,18 @@ void ipneigh_reset_filter(int ifindex)
 
 static int do_show_or_flush(int argc, char **argv, int flush)
 {
+	struct {
+		struct nlmsghdr	n;
+		struct ndmsg		ndm;
+		char  			buf[256];
+	} req;
 	char *filter_dev = NULL;
 	int state_given = 0;
-	struct ndmsg ndm = { 0 };
+
+	memset(&req, 0, sizeof(req));
+
+	req.n.nlmsg_type = RTM_GETNEIGH;
+	req.n.nlmsg_len = NLMSG_LENGTH(sizeof(struct ndmsg));
 
 	ipneigh_reset_filter(0);
 
@@ -351,6 +370,14 @@ static int do_show_or_flush(int argc, char **argv, int flush)
 			if (filter_dev)
 				duparg("dev", *argv);
 			filter_dev = *argv;
+		} else if (strcmp(*argv, "master") == 0) {
+			int ifindex;
+			NEXT_ARG();
+			ifindex = ll_name_to_index(*argv);
+			if (!ifindex)
+				invarg("Device does not exist\n", *argv);
+			addattr32(&req.n, sizeof(req), NDA_MASTER, ifindex);
+			filter.master = ifindex;
 		} else if (strcmp(*argv, "unused") == 0) {
 			filter.unused_only = 1;
 		} else if (strcmp(*argv, "nud") == 0) {
@@ -371,7 +398,7 @@ static int do_show_or_flush(int argc, char **argv, int flush)
 				state = 0x100;
 			filter.state |= state;
 		} else if (strcmp(*argv, "proxy") == 0)
-			ndm.ndm_flags = NTF_PROXY;
+			req.ndm.ndm_flags = NTF_PROXY;
 		else {
 			if (strcmp(*argv, "to") == 0) {
 				NEXT_ARG();
@@ -436,9 +463,9 @@ static int do_show_or_flush(int argc, char **argv, int flush)
 		return 1;
 	}
 
-	ndm.ndm_family = filter.family;
+	req.ndm.ndm_family = filter.family;
 
-	if (rtnl_dump_request(&rth, RTM_GETNEIGH, &ndm, sizeof(struct ndmsg)) < 0) {
+	if (rtnl_dump_request_n(&rth, &req.n) < 0) {
 		perror("Cannot send dump request");
 		exit(1);
 	}
diff --git a/lib/libnetlink.c b/lib/libnetlink.c
index 46cac34c7581..8e3762c1795d 100644
--- a/lib/libnetlink.c
+++ b/lib/libnetlink.c
@@ -191,6 +191,27 @@ int rtnl_dump_request(struct rtnl_handle *rth, int type, void *req, int len)
 	return sendmsg(rth->fd, &msg, 0);
 }
 
+int rtnl_dump_request_n(struct rtnl_handle *rth, struct nlmsghdr *n)
+{
+	struct sockaddr_nl nladdr = { .nl_family = AF_NETLINK };
+	struct iovec iov = {
+		.iov_base = (void*) n,
+		.iov_len = n->nlmsg_len
+	};
+	struct msghdr msg = {
+		.msg_name = &nladdr,
+		.msg_namelen = sizeof(nladdr),
+		.msg_iov = &iov,
+		.msg_iovlen = 1,
+	};
+
+	n->nlmsg_flags = NLM_F_DUMP|NLM_F_REQUEST;
+	n->nlmsg_pid = 0;
+	n->nlmsg_seq = rth->dump = ++rth->seq;
+
+	return sendmsg(rth->fd, &msg, 0);
+}
+
 int rtnl_dump_filter_l(struct rtnl_handle *rth,
 		       const struct rtnl_dump_filter_arg *arg)
 {
-- 
1.9.1
