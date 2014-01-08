From: Masatake YAMATO <yamato@redhat.com>
Subject: [PATCH 1/3] ss: handle seqpacket type of unix domain socket
Date: Wed,  8 Jan 2014 20:13:46 +0900
Message-ID: <1389179628-22147-1-git-send-email-yamato@redhat.com>
Cc: yamato@redhat.com
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mx1.redhat.com ([209.132.183.28]:10415 "EHLO mx1.redhat.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1755950AbaAHLOE (ORCPT <rfc822;netdev@vger.kernel.org>);
	Wed, 8 Jan 2014 06:14:04 -0500
Received: from int-mx09.intmail.prod.int.phx2.redhat.com (int-mx09.intmail.prod.int.phx2.redhat.com [10.5.11.22])
	by mx1.redhat.com (8.14.4/8.14.4) with ESMTP id s08BE4QX000989
	(version=TLSv1/SSLv3 cipher=DHE-RSA-AES256-SHA bits=256 verify=OK)
	for <netdev@vger.kernel.org>; Wed, 8 Jan 2014 06:14:04 -0500
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

ss didn't distignish seqpacket type from dgram type.
With this patch ss can distignish it.

 $ misc/ss -x -a | grep seq
 u_seq  LISTEN     0      128    /run/udev/control 10966                 * 0
 u_seq  ESTAB      0      0                    * 115103                * 115104
 u_seq  ESTAB      0      0                    * 115104                * 115103

Signed-off-by: Masatake YAMATO <yamato@redhat.com>
---
 misc/ss.c | 31 ++++++++++++++++++++++++++++---
 1 file changed, 28 insertions(+), 3 deletions(-)

diff --git a/misc/ss.c b/misc/ss.c
index e59ca5c..bac1f9e 100644
--- a/misc/ss.c
+++ b/misc/ss.c
@@ -71,6 +71,7 @@ enum
 	RAW_DB,
 	UNIX_DG_DB,
 	UNIX_ST_DB,
+	UNIX_SQ_DB,
 	PACKET_DG_DB,
 	PACKET_R_DB,
 	NETLINK_DB,
@@ -78,7 +79,7 @@ enum
 };
 
 #define PACKET_DBM ((1<<PACKET_DG_DB)|(1<<PACKET_R_DB))
-#define UNIX_DBM ((1<<UNIX_DG_DB)|(1<<UNIX_ST_DB))
+#define UNIX_DBM ((1<<UNIX_DG_DB)|(1<<UNIX_ST_DB)|(1<<UNIX_SQ_DB))
 #define ALL_DB ((1<<MAX_DB)-1)
 
 enum {
@@ -2114,6 +2115,25 @@ static void unix_list_free(struct unixstat *list)
 	}
 }
 
+static const char *unix_netid_name(int type)
+{
+	const char *netid;
+
+	switch (type) {
+	case SOCK_STREAM:
+		netid = "u_str";
+		break;
+	case SOCK_SEQPACKET:
+		netid = "u_seq";
+		break;
+	case SOCK_DGRAM:
+	default:
+		netid = "u_dgr";
+		break;
+	}
+	return netid;
+}
+
 static void unix_list_print(struct unixstat *list, struct filter *f)
 {
 	struct unixstat *s;
@@ -2126,6 +2146,8 @@ static void unix_list_print(struct unixstat *list, struct filter *f)
 			continue;
 		if (s->type == SOCK_DGRAM && !(f->dbs&(1<<UNIX_DG_DB)))
 			continue;
+		if (s->type == SOCK_SEQPACKET && !(f->dbs&(1<<UNIX_SQ_DB)))
+			continue;
 
 		peer = "*";
 		if (s->peer) {
@@ -2156,7 +2178,7 @@ static void unix_list_print(struct unixstat *list, struct filter *f)
 
 		if (netid_width)
 			printf("%-*s ", netid_width,
-			       s->type == SOCK_STREAM ? "u_str" : "u_dgr");
+			       unix_netid_name(s->type));
 		if (state_width)
 			printf("%-*s ", state_width, sstate_name[s->state]);
 		printf("%-6d %-6d ", s->rq, s->wq);
@@ -2185,7 +2207,7 @@ static int unix_show_sock(struct nlmsghdr *nlh, struct filter *f)
 
 	if (netid_width)
 		printf("%-*s ", netid_width,
-				r->udiag_type == SOCK_STREAM ? "u_str" : "u_dgr");
+		       		unix_netid_name(r->udiag_type));
 	if (state_width)
 		printf("%-*s ", state_width, sstate_name[r->udiag_state]);
 
@@ -3253,6 +3275,9 @@ int main(int argc, char *argv[])
 				} else if (strcasecmp(p, "unix_dgram") == 0 ||
 					   strcmp(p, "u_dgr") == 0) {
 					current_filter.dbs |= (1<<UNIX_DG_DB);
+				} else if (strcasecmp(p, "unix_seqpacket") == 0 ||
+					   strcmp(p, "u_seq") == 0) {
+					current_filter.dbs |= (1<<UNIX_SQ_DB);
 				} else if (strcmp(p, "packet") == 0) {
 					current_filter.dbs |= PACKET_DBM;
 				} else if (strcmp(p, "packet_raw") == 0 ||
-- 
1.8.4.2
