From: Vlad Yasevich <vyasevic@redhat.com>
Subject: [PATCHv2 iproute2 1/3] bridge: Add vlan support to fdb entries
Date: Thu, 28 Feb 2013 15:04:04 -0500
Message-ID: <1362081846-25268-2-git-send-email-vyasevic@redhat.com>
References: <1362081846-25268-1-git-send-email-vyasevic@redhat.com>
Cc: shemminger@vyatta.com
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mx1.redhat.com ([209.132.183.28]:52784 "EHLO mx1.redhat.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1753346Ab3B1UEL (ORCPT <rfc822;netdev@vger.kernel.org>);
	Thu, 28 Feb 2013 15:04:11 -0500
In-Reply-To: <1362081846-25268-1-git-send-email-vyasevic@redhat.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Provide the ability to set and show vlans on FDB entries.

Signed-off-by: Vlad Yasevich <vyasevic@redhat.com>
---
 bridge/fdb.c |   16 +++++++++++++++-
 1 files changed, 15 insertions(+), 1 deletions(-)

diff --git a/bridge/fdb.c b/bridge/fdb.c
index 4ca4861..447045e 100644
--- a/bridge/fdb.c
+++ b/bridge/fdb.c
@@ -29,7 +29,7 @@ int filter_index;
 
 static void usage(void)
 {
-	fprintf(stderr, "Usage: bridge fdb { add | del } ADDR dev DEV {self|master} [ temp ] [ dst IPADDR]\n");
+	fprintf(stderr, "Usage: bridge fdb { add | del } ADDR dev DEV {self|master} [ temp ] [ dst IPADDR] [ vlan VID ]\n");
 	fprintf(stderr, "       bridge fdb {show} [ dev DEV ]\n");
 	exit(-1);
 }
@@ -107,6 +107,11 @@ int print_fdb(const struct sockaddr_nl *who, struct nlmsghdr *n, void *arg)
 				    abuf, sizeof(abuf)));
 	}
 
+	if (tb[NDA_VLAN]) {
+		__u16 vid = rta_getattr_u16(tb[NDA_VLAN]);
+		fprintf(fp, "vlan %hu ", vid);
+	}
+
 	if (show_stats && tb[NDA_CACHEINFO]) {
 		struct nda_cacheinfo *ci = RTA_DATA(tb[NDA_CACHEINFO]);
 		int hz = get_user_hz();
@@ -171,6 +176,7 @@ static int fdb_modify(int cmd, int flags, int argc, char **argv)
 	char abuf[ETH_ALEN];
 	int dst_ok = 0;
 	inet_prefix dst;
+	short vid = -1;
 
 	memset(&req, 0, sizeof(req));
 
@@ -199,6 +205,11 @@ static int fdb_modify(int cmd, int flags, int argc, char **argv)
 			req.ndm.ndm_state |= NUD_PERMANENT;
 		} else if (matches(*argv, "temp") == 0) {
 			req.ndm.ndm_state |= NUD_REACHABLE;
+		} else if (matches(*argv, "vlan") == 0) {
+			if (vid >= 0)
+				duparg2("vlan", *argv);
+			NEXT_ARG();
+			vid = atoi(*argv);
 		} else {
 			if (strcmp(*argv, "to") == 0) {
 				NEXT_ARG();
@@ -236,6 +247,9 @@ static int fdb_modify(int cmd, int flags, int argc, char **argv)
 	if (dst_ok)
 		addattr_l(&req.n, sizeof(req), NDA_DST, &dst.data, dst.bytelen);
 
+	if (vid >= 0)
+		addattr16(&req.n, sizeof(req), NDA_VLAN, vid); 
+
 	req.ndm.ndm_ifindex = ll_name_to_index(d);
 	if (req.ndm.ndm_ifindex == 0) {
 		fprintf(stderr, "Cannot find device \"%s\"\n", d);
-- 
1.7.7.6
