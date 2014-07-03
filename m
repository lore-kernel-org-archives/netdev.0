From: roopa@cumulusnetworks.com
Subject: [RFC PATCH iproute2] link dump filter
Date: Thu,  3 Jul 2014 16:07:15 -0700
Message-ID: <1404428835-21011-1-git-send-email-roopa@cumulusnetworks.com>
Cc: shm@cumulusnetworks.com, nolan@cumulusnetworks.com,
	sfeldma@cumulusnetworks.com, jhs@mojatatu.com
To: davem@davemloft.net, stephen@networkplumber.org,
	netdev@vger.kernel.org, roopa@cumulusnetworks.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from ext3.cumulusnetworks.com ([198.211.106.187]:36255 "EHLO
	ext3.cumulusnetworks.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752275AbaGCXGo (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 3 Jul 2014 19:06:44 -0400
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Roopa Prabhu <roopa@cumulusnetworks.com>

This patch avoids a full link wildump request when the user has specified
a single link. Uses RTM_GETLINK without the NLM_F_DUMP flag.

This helps on a system with large number of interfaces.

This patch currently only uses the link ifindex in the filter.
Hoping to provide a subsequent kernel patch to do link dump filtering on
other attributes in the kernel.

In iplink_get, to be safe, this patch currently sets the answer buffer
size to the max size that libnetlink rtnl_talk can copy. The current api
does not seem to provide a way to indicate the answer buf size.

Signed-off-by: Roopa Prabhu <roopa@cumulusnetworks.com>
---
 ip/ip_common.h |    1 +
 ip/ipaddress.c |   20 +++++++++++++++++---
 ip/iplink.c    |   32 ++++++++++++++++++++++++++++++++
 3 files changed, 50 insertions(+), 3 deletions(-)

diff --git a/ip/ip_common.h b/ip/ip_common.h
index ac1e4c1..e56d1ac 100644
--- a/ip/ip_common.h
+++ b/ip/ip_common.h
@@ -51,6 +51,7 @@ extern int do_ipl2tp(int argc, char **argv);
 extern int do_tcp_metrics(int argc, char **argv);
 extern int do_ipnetconf(int argc, char **argv);
 extern int do_iptoken(int argc, char **argv);
+extern int iplink_get(unsigned int flags, char *name, __u32 filt_mask);
 
 static inline int rtm_get_table(struct rtmsg *r, struct rtattr **tb)
 {
diff --git a/ip/ipaddress.c b/ip/ipaddress.c
index 8138e86..d111fab 100644
--- a/ip/ipaddress.c
+++ b/ip/ipaddress.c
@@ -1241,9 +1241,23 @@ static int ipaddr_list_flush_or_save(int argc, char **argv, int action)
 		exit(0);
 	}
 
-	if (rtnl_wilddump_request(&rth, preferred_family, RTM_GETLINK) < 0) {
-		perror("Cannot send dump request");
-		exit(1);
+	if (filter_dev && filter.group == -1 && do_link == 1) {
+		/*
+		 * If only filter_dev present and none of the other
+		 * link filters are present, use RTM_GETLINK to get
+		 * the link device
+		 */
+		if (iplink_get(0, filter_dev, RTEXT_FILTER_VF) < 0) {
+			perror("Cannot send link get request");
+			exit(1);
+		}
+		exit(0);
+	} else {
+		if (rtnl_wilddump_request(&rth, preferred_family,
+					RTM_GETLINK) < 0) {
+			perror("Cannot send dump request");
+			exit(1);
+		}
 	}
 
 	if (rtnl_dump_filter(&rth, store_nlmsg, &linfo) < 0) {
diff --git a/ip/iplink.c b/ip/iplink.c
index 0d020ef..7ac2813 100644
--- a/ip/iplink.c
+++ b/ip/iplink.c
@@ -703,6 +703,38 @@ static int iplink_modify(int cmd, unsigned int flags, int argc, char **argv)
 	return 0;
 }
 
+int iplink_get(unsigned int flags, char *name, __u32 filt_mask)
+{
+	int len;
+	struct iplink_req req;
+	char answer[16384];
+
+	memset(&req, 0, sizeof(req));
+
+	req.n.nlmsg_len = NLMSG_LENGTH(sizeof(struct ifinfomsg));
+	req.n.nlmsg_flags = NLM_F_REQUEST|flags;
+	req.n.nlmsg_type = RTM_GETLINK;
+	req.i.ifi_family = preferred_family;
+
+	if (name) {
+		len = strlen(name) + 1;
+		if (len == 1)
+			invarg("\"\" is not a valid device identifier\n",
+				   "name");
+		if (len > IFNAMSIZ)
+			invarg("\"name\" too long\n", name);
+		addattr_l(&req.n, sizeof(req), IFLA_IFNAME, name, len);
+	}
+	addattr32(&req.n, sizeof(req), IFLA_EXT_MASK, filt_mask);
+
+	if (rtnl_talk(&rth, &req.n, 0, 0, (struct nlmsghdr *)answer) < 0)
+		return -2;
+
+	print_linkinfo(NULL, (struct nlmsghdr *)answer, stdout);
+
+	return 0;
+}
+
 #if IPLINK_IOCTL_COMPAT
 static int get_ctl_fd(void)
 {
-- 
1.7.10.4
