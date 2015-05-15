From: Roopa Prabhu <roopa@cumulusnetworks.com>
Subject: [PATCH net iproute2] mpls: modify RTA_NEWDST netlink attribute to include family
Date: Thu, 14 May 2015 22:40:23 -0700
Message-ID: <1431668423-21028-1-git-send-email-roopa@cumulusnetworks.com>
Cc: davem@davemloft.net, rshearma@brocade.com, netdev@vger.kernel.org,
	vivek@cumulusnetworks.com
To: ebiederm@xmission.com, stephen@networkplumber.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-ie0-f175.google.com ([209.85.223.175]:34050 "EHLO
	mail-ie0-f175.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752507AbbEOFk2 (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 15 May 2015 01:40:28 -0400
Received: by ieczm2 with SMTP id zm2so20249974iec.1
        for <netdev@vger.kernel.org>; Thu, 14 May 2015 22:40:28 -0700 (PDT)
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Roopa Prabhu <roopa@cumulusnetworks.com>

This patch changes mpls RTA_NEWDST netlink attribute
parse and fill code to follow new kernel RTA_NEWDST format
 which includes family in RTA_NEWDST.

Encoding family in the attribute will help its reuse in the
future.

One usecase where family with RTA_NEWDST becomes necessary
is when we implement mpls label edge router function.

Signed-off-by: Roopa Prabhu <roopa@cumulusnetworks.com>
---
This patch follows a kernel patch with the same patch title.
The kernel patch has not been accepted yet.

 include/linux/rtnetlink.h |    6 ++++++
 ip/iproute.c              |   32 +++++++++++++++++++++-----------
 2 files changed, 27 insertions(+), 11 deletions(-)

diff --git a/include/linux/rtnetlink.h b/include/linux/rtnetlink.h
index 702b19b..50ae024 100644
--- a/include/linux/rtnetlink.h
+++ b/include/linux/rtnetlink.h
@@ -356,6 +356,12 @@ struct rtvia {
 	__u8			rtvia_addr[0];
 };
 
+/* RTA_NEWDST */
+struct rtnewdst {
+	__kernel_sa_family_t	family;
+	__u8	dst[0];
+};
+
 /* RTM_CACHEINFO */
 
 struct rta_cacheinfo {
diff --git a/ip/iproute.c b/ip/iproute.c
index 670a4c6..b97322f 100644
--- a/ip/iproute.c
+++ b/ip/iproute.c
@@ -392,12 +392,18 @@ int print_route(const struct sockaddr_nl *who, struct nlmsghdr *n, void *arg)
 		fprintf(fp, "from 0/%u ", r->rtm_src_len);
 	}
 	if (tb[RTA_NEWDST]) {
-		fprintf(fp, "as to %s ", format_host(r->rtm_family,
-						  RTA_PAYLOAD(tb[RTA_NEWDST]),
-						  RTA_DATA(tb[RTA_NEWDST]),
-						  abuf, sizeof(abuf))
-			);
+		size_t len = RTA_PAYLOAD(tb[RTA_NEWDST]) - 2;
+		struct rtnewdst *newdst = RTA_DATA(tb[RTA_NEWDST]);
+
+		if (newdst->family == r->rtm_family)
+			fprintf(fp, "as to %s ", format_host(newdst->family,
+				len, newdst->dst, abuf, sizeof(abuf)));
+		else
+			fprintf(fp, "as to %s %s ", family_name(newdst->family),
+				format_host(newdst->family, len, newdst->dst,
+					    abuf, sizeof(abuf)));
 	}
+
 	if (r->rtm_tos && filter.tosmask != -1) {
 		SPRINT_BUF(b1);
 		fprintf(fp, "tos %s ", rtnl_dsfield_n2a(r->rtm_tos, b1, sizeof(b1)));
@@ -832,14 +838,18 @@ static int iproute_modify(int cmd, unsigned flags, int argc, char **argv)
 			addattr_l(&req.n, sizeof(req), RTA_PREFSRC, &addr.data, addr.bytelen);
 		} else if (strcmp(*argv, "as") == 0) {
 			inet_prefix addr;
+			int family;
 			NEXT_ARG();
-			if (strcmp(*argv, "to") == 0) {
+			if (strcmp(*argv, "to") == 0)
 				NEXT_ARG();
-			}
-			get_addr(&addr, *argv, req.r.rtm_family);
-			if (req.r.rtm_family == AF_UNSPEC)
-				req.r.rtm_family = addr.family;
-			addattr_l(&req.n, sizeof(req), RTA_NEWDST, &addr.data, addr.bytelen);
+			family = read_family(*argv);
+			if (family == AF_UNSPEC)
+				family = req.r.rtm_family;
+			else
+				NEXT_ARG();
+			get_addr(&addr, *argv, family);
+			addattr_l(&req.n, sizeof(req), RTA_NEWDST,
+				  &addr.family, addr.bytelen+2);
 		} else if (strcmp(*argv, "via") == 0) {
 			inet_prefix addr;
 			int family;
-- 
1.7.10.4
