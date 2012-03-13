From: Florian Westphal <fw@strlen.de>
Subject: [PATCH][iproute2] ip: xfrm: report nat-t/encapsulation portmapping updates
Date: Tue, 13 Mar 2012 23:35:25 +0100
Message-ID: <1331678125-5307-1-git-send-email-fw@strlen.de>
Cc: Florian Westphal <fw@strlen.de>
To: <netdev@vger.kernel.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from Chamillionaire.breakpoint.cc ([85.10.199.196]:55499 "EHLO
	Chamillionaire.breakpoint.cc" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with ESMTP id S1759840Ab2CMWjl (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 13 Mar 2012 18:39:41 -0400
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Signed-off-by: Florian Westphal <fw@strlen.de>
---
 ip/xfrm_monitor.c |   56 ++++++++++++++++++++++++++++++++++++++++++++++------
 1 files changed, 49 insertions(+), 7 deletions(-)

diff --git a/ip/xfrm_monitor.c b/ip/xfrm_monitor.c
index 6a5b331..ea17987 100644
--- a/ip/xfrm_monitor.c
+++ b/ip/xfrm_monitor.c
@@ -221,6 +221,20 @@ void xfrm_ae_flags_print(__u32 flags, void *arg)
 
 }
 
+static void xfrm_usersa_print(const struct xfrm_usersa_id *sa_id, __u32 reqid, FILE *fp)
+{
+	char buf[256];
+
+	buf[0] = 0;
+	fprintf(fp, "dst %s ", rt_addr_n2a(sa_id->family,
+		sizeof(sa_id->daddr), &sa_id->daddr, buf, sizeof(buf)));
+
+	fprintf(fp, " reqid 0x%x", reqid);
+
+	fprintf(fp, " protocol %s ", strxf_proto(sa_id->proto));
+	fprintf(fp, " SPI 0x%x", ntohl(sa_id->spi));
+}
+
 static int xfrm_ae_print(const struct sockaddr_nl *who,
 			     struct nlmsghdr *n, void *arg)
 {
@@ -235,13 +249,8 @@ static int xfrm_ae_print(const struct sockaddr_nl *who,
 	fprintf(fp, "src %s ", rt_addr_n2a(id->sa_id.family,
 		sizeof(id->saddr), &id->saddr,
 		abuf, sizeof(abuf)));
-	memset(abuf, '\0', sizeof(abuf));
-	fprintf(fp, "dst %s ", rt_addr_n2a(id->sa_id.family,
-		sizeof(id->sa_id.daddr), &id->sa_id.daddr,
-		abuf, sizeof(abuf)));
-	fprintf(fp, " reqid 0x%x", id->reqid);
-	fprintf(fp, " protocol %s ", strxf_proto(id->sa_id.proto));
-	fprintf(fp, " SPI 0x%x", ntohl(id->sa_id.spi));
+
+	xfrm_usersa_print(&id->sa_id, id->reqid, fp);
 
 	fprintf(fp, "\n");
 	fflush(fp);
@@ -249,6 +258,36 @@ static int xfrm_ae_print(const struct sockaddr_nl *who,
 	return 0;
 }
 
+static void xfrm_print_addr(FILE *fp, int family, xfrm_address_t *a, size_t s)
+{
+	char buf[256];
+
+	buf[0] = 0;
+	fprintf(fp, "%s", rt_addr_n2a(family, s, a, buf, sizeof(buf)));
+}
+
+static int xfrm_mapping_print(const struct sockaddr_nl *who,
+			     struct nlmsghdr *n, void *arg)
+{
+	FILE *fp = (FILE*)arg;
+	struct xfrm_user_mapping *map = NLMSG_DATA(n);
+
+	fprintf(fp, "Mapping change ");
+	xfrm_print_addr(fp, map->id.family, &map->old_saddr,
+			sizeof(map->old_saddr));
+
+	fprintf(fp, ":%d -> ", ntohs(map->old_sport));
+	xfrm_print_addr(fp, map->id.family, &map->new_saddr,
+			sizeof(map->new_saddr));
+	fprintf(fp, ":%d\n\t", ntohs(map->new_sport));
+
+	xfrm_usersa_print(&map->id, map->reqid, fp);
+
+	fprintf(fp, "\n");
+	fflush(fp);
+	return 0;
+}
+
 static int xfrm_accept_msg(const struct sockaddr_nl *who,
 			   struct nlmsghdr *n, void *arg)
 {
@@ -285,6 +324,9 @@ static int xfrm_accept_msg(const struct sockaddr_nl *who,
 	case XFRM_MSG_NEWAE:
 		xfrm_ae_print(who, n, arg);
 		return 0;
+	case XFRM_MSG_MAPPING:
+		xfrm_mapping_print(who, n, arg);
+		return 0;
 	default:
 		break;
 	}
-- 
1.7.3.4
