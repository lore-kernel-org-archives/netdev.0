From: Andrey Vagin <avagin@openvz.org>
Subject: [PATCH 4/4] ss: Get netlink sockets info via sock-diag
Date: Thu, 21 Mar 2013 13:33:26 +0400
Message-ID: <1363858406-1489-5-git-send-email-avagin@openvz.org>
References: <1363857669-19990-1-git-send-email-avagin@openvz.org>
 <1363858406-1489-1-git-send-email-avagin@openvz.org>
Cc: Pavel Emelyanov <xemul@parallels.com>,
	Andrey Vagin <avagin@openvz.org>,
	Stephen Hemminger <stephen@networkplumber.org>
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mailhub.sw.ru ([195.214.232.25]:41600 "EHLO relay.sw.ru"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S932970Ab3CUJfJ (ORCPT <rfc822;netdev@vger.kernel.org>);
	Thu, 21 Mar 2013 05:35:09 -0400
In-Reply-To: <1363858406-1489-1-git-send-email-avagin@openvz.org>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Cc: Stephen Hemminger <stephen@networkplumber.org>
Signed-off-by: Andrey Vagin <avagin@openvz.org>
---
 include/linux/netlink_diag.h | 40 +++++++++++++++++++++++++++++++
 misc/ss.c                    | 56 ++++++++++++++++++++++++++++++++++++++++++++
 2 files changed, 96 insertions(+)
 create mode 100644 include/linux/netlink_diag.h

diff --git a/include/linux/netlink_diag.h b/include/linux/netlink_diag.h
new file mode 100644
index 0000000..9328866
--- /dev/null
+++ b/include/linux/netlink_diag.h
@@ -0,0 +1,40 @@
+#ifndef __NETLINK_DIAG_H__
+#define __NETLINK_DIAG_H__
+
+#include <linux/types.h>
+
+struct netlink_diag_req {
+	__u8	sdiag_family;
+	__u8	sdiag_protocol;
+	__u16	pad;
+	__u32	ndiag_ino;
+	__u32	ndiag_show;
+	__u32	ndiag_cookie[2];
+};
+
+struct netlink_diag_msg {
+	__u8	ndiag_family;
+	__u8	ndiag_type;
+	__u8	ndiag_protocol;
+	__u8	ndiag_state;
+
+	__u32	ndiag_portid;
+	__u32	ndiag_dst_portid;
+	__u32	ndiag_dst_group;
+	__u32	ndiag_ino;
+	__u32	ndiag_cookie[2];
+};
+
+enum {
+	NETLINK_DIAG_MEMINFO,
+	NETLINK_DIAG_GROUPS,
+
+	NETLINK_DIAG_MAX,
+};
+
+#define NDIAG_PROTO_ALL		((__u8) ~0)
+
+#define NDIAG_SHOW_MEMINFO	0x00000001 /* show memory info of a socket */
+#define NDIAG_SHOW_GROUPS	0x00000002 /* show groups of a netlink socket */
+
+#endif
diff --git a/misc/ss.c b/misc/ss.c
index 1af677a..49312f1 100644
--- a/misc/ss.c
+++ b/misc/ss.c
@@ -36,6 +36,7 @@
 #include <linux/sock_diag.h>
 #include <linux/inet_diag.h>
 #include <linux/unix_diag.h>
+#include <linux/netlink_diag.h>
 
 int resolve_hosts = 0;
 int resolve_services = 1;
@@ -2548,6 +2549,61 @@ static void netlink_show_one(struct filter *f,
 	return;
 }
 
+static int netlink_show_sock(struct nlmsghdr *nlh, struct filter *f)
+{
+	struct netlink_diag_msg *r = NLMSG_DATA(nlh);
+	struct rtattr *tb[NETLINK_DIAG_MAX+1];
+	int rq = 0, wq = 0;
+	unsigned long groups = 0;
+
+	parse_rtattr(tb, NETLINK_DIAG_MAX, (struct rtattr*)(r+1),
+		     nlh->nlmsg_len - NLMSG_LENGTH(sizeof(*r)));
+
+	if (tb[NETLINK_DIAG_GROUPS] && RTA_PAYLOAD(tb[NETLINK_DIAG_GROUPS]))
+		groups = *(unsigned long *) RTA_DATA(tb[NETLINK_DIAG_GROUPS]);
+
+	if (tb[NETLINK_DIAG_MEMINFO]) {
+		const __u32 *skmeminfo;
+		skmeminfo = RTA_DATA(tb[NETLINK_DIAG_MEMINFO]);
+
+		rq = skmeminfo[SK_MEMINFO_RMEM_ALLOC];
+		wq = skmeminfo[SK_MEMINFO_WMEM_ALLOC];
+	}
+
+	netlink_show_one(f, r->ndiag_protocol, r->ndiag_portid, groups,
+			 r->ndiag_state, r->ndiag_dst_portid, r->ndiag_dst_group,
+			 rq, wq, 0, 0);
+
+	if (show_mem) {
+		printf("\t");
+		print_skmeminfo(tb, NETLINK_DIAG_MEMINFO);
+		printf("\n");
+	}
+
+	return 0;
+}
+
+static int netlink_show_netlink(struct filter *f, FILE *dump_fp)
+{
+	struct {
+		struct nlmsghdr nlh;
+		struct netlink_diag_req r;
+	} req;
+
+	memset(&req, 0, sizeof(req));
+	req.nlh.nlmsg_len = sizeof(req);
+	req.nlh.nlmsg_type = SOCK_DIAG_BY_FAMILY;
+	req.nlh.nlmsg_flags = NLM_F_ROOT|NLM_F_MATCH|NLM_F_REQUEST;
+	req.nlh.nlmsg_seq = 123456;
+
+	req.r.sdiag_family = AF_NETLINK;
+	req.r.sdiag_protocol = NDIAG_PROTO_ALL;
+	req.r.ndiag_show = NDIAG_SHOW_GROUPS | NDIAG_SHOW_MEMINFO;
+
+	return handle_netlink_request(f, dump_fp, &req.nlh,
+					sizeof(req), netlink_show_sock);
+}
+
 static int netlink_show(struct filter *f)
 {
 	FILE *fp;
-- 
1.7.11.7
