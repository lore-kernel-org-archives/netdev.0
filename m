From: Nicolas Dichtel <nicolas.dichtel@6wind.com>
Subject: [PATCH iproute2 3/3] ipnetns: add a runtime check for RTM_GETNSID support
Date: Mon, 13 Apr 2015 10:23:05 +0200
Message-ID: <1428913385-4331-3-git-send-email-nicolas.dichtel@6wind.com>
References: <5527F790.4080301@6wind.com>
 <1428913385-4331-1-git-send-email-nicolas.dichtel@6wind.com>
Cc: netdev@vger.kernel.org, vadim4j@gmail.com, jbenc@redhat.com,
	Nicolas Dichtel <nicolas.dichtel@6wind.com>
To: shemminger@vyatta.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from 33.106-14-84.ripe.coltfrance.com ([84.14.106.33]:40920 "EHLO
	proxy.6wind.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751971AbbDMIXN (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 13 Apr 2015 04:23:13 -0400
In-Reply-To: <1428913385-4331-1-git-send-email-nicolas.dichtel@6wind.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

The goal of this patch is to test during the runtime if the command RTM_GETNSID
is supported by the kernel.

Signed-off-by: Nicolas Dichtel <nicolas.dichtel@6wind.com>
---
 ip/ipnetns.c | 56 +++++++++++++++++++++++++++++++++++++++++++++++++++++---
 1 file changed, 53 insertions(+), 3 deletions(-)

diff --git a/ip/ipnetns.c b/ip/ipnetns.c
index 5a213dcf46cd..12f6b90de89a 100644
--- a/ip/ipnetns.c
+++ b/ip/ipnetns.c
@@ -34,6 +34,54 @@ static int usage(void)
 	exit(-1);
 }
 
+static int have_rtnl_getnsid = -1;
+
+static int ipnetns_accept_msg(const struct sockaddr_nl *who,
+			      struct nlmsghdr *n, void *arg)
+{
+	struct nlmsgerr *err = (struct nlmsgerr *)NLMSG_DATA(n);
+
+	if (n->nlmsg_type == NLMSG_ERROR &&
+	    (err->error == -EOPNOTSUPP || err->error == -EINVAL))
+		have_rtnl_getnsid = 0;
+	else
+		have_rtnl_getnsid = 1;
+	return -1;
+}
+
+static int ipnetns_have_nsid(void)
+{
+	struct {
+		struct nlmsghdr n;
+		struct rtgenmsg g;
+		char            buf[1024];
+	} req;
+	int fd;
+
+	if (have_rtnl_getnsid < 0) {
+		memset(&req, 0, sizeof(req));
+		req.n.nlmsg_len = NLMSG_LENGTH(sizeof(struct rtgenmsg));
+		req.n.nlmsg_flags = NLM_F_REQUEST;
+		req.n.nlmsg_type = RTM_GETNSID;
+		req.g.rtgen_family = AF_UNSPEC;
+
+		fd = open("/proc/self/ns/net", O_RDONLY);
+		if (fd < 0)
+			return fd;
+
+		addattr32(&req.n, 1024, NETNSA_FD, fd);
+
+		if (rtnl_send(&rth, &req.n, req.n.nlmsg_len) < 0) {
+			perror("request send failed");
+			exit(1);
+		}
+		rtnl_listen(&rth, ipnetns_accept_msg, NULL);
+		close(fd);
+	}
+
+	return have_rtnl_getnsid;
+}
+
 static int get_netnsid_from_name(const char *name)
 {
 	struct {
@@ -95,9 +143,11 @@ static int netns_list(int argc, char **argv)
 		if (strcmp(entry->d_name, "..") == 0)
 			continue;
 		printf("%s", entry->d_name);
-		id = get_netnsid_from_name(entry->d_name);
-		if (id >= 0)
-			printf(" (id: %d)", id);
+		if (ipnetns_have_nsid()) {
+			id = get_netnsid_from_name(entry->d_name);
+			if (id >= 0)
+				printf(" (id: %d)", id);
+		}
 		printf("\n");
 	}
 	closedir(dir);
-- 
2.2.2
