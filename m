From: Hangbin Liu <liuhangbin@gmail.com>
Subject: [PATCH iproute2] ip: Use specific slave id
Date: Tue, 20 Sep 2016 18:02:12 +0800
Message-ID: <1474365732-6087-1-git-send-email-liuhangbin@gmail.com>
Cc: Stephen Hemminger <stephen@networkplumber.org>,
        Phil Sutter <phil@nwl.cc>,
        Nikolay Aleksandrov <nikolay@cumulusnetworks.com>,
        David Ahern <dsa@cumulusnetworks.com>,
        Sabrina Dubroca <sd@queasysnail.net>,
        Hangbin Liu <liuhangbin@gmail.com>
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-pf0-f193.google.com ([209.85.192.193]:33707 "EHLO
        mail-pf0-f193.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1751540AbcITKCj (ORCPT
        <rfc822;netdev@vger.kernel.org>); Tue, 20 Sep 2016 06:02:39 -0400
Received: by mail-pf0-f193.google.com with SMTP id q2so763400pfj.0
        for <netdev@vger.kernel.org>; Tue, 20 Sep 2016 03:02:39 -0700 (PDT)
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

The original bond/bridge/vrf and slaves use same id, which make people
confused. Use bond/bridge/vrf_slave as id name will make code more clear.

Acked-by: Phil Sutter <psutter@redhat.com>
Signed-off-by: Hangbin Liu <liuhangbin@gmail.com>
---
 ip/ip_common.h           |  2 --
 ip/ipaddress.c           |  4 +++-
 ip/iplink.c              | 36 +++++++-----------------------------
 ip/iplink_bond_slave.c   |  3 +--
 ip/iplink_bridge_slave.c |  3 +--
 ip/iplink_vrf.c          |  3 +--
 ip/ipmacsec.c            |  1 -
 7 files changed, 13 insertions(+), 39 deletions(-)

diff --git a/ip/ip_common.h b/ip/ip_common.h
index 93ff5bc..1c1cbdf 100644
--- a/ip/ip_common.h
+++ b/ip/ip_common.h
@@ -83,11 +83,9 @@ struct link_util {
 					     struct rtattr *);
 	void			(*print_help)(struct link_util *, int, char **,
 					     FILE *);
-	bool			slave;
 };
 
 struct link_util *get_link_kind(const char *kind);
-struct link_util *get_link_slave_kind(const char *slave_kind);
 
 void br_dump_bridge_id(const struct ifla_bridge_id *id, char *buf, size_t len);
 
diff --git a/ip/ipaddress.c b/ip/ipaddress.c
index 76bd7b3..fcc3c53 100644
--- a/ip/ipaddress.c
+++ b/ip/ipaddress.c
@@ -232,6 +232,7 @@ static void print_linktype(FILE *fp, struct rtattr *tb)
 	struct rtattr *linkinfo[IFLA_INFO_MAX+1];
 	struct link_util *lu;
 	struct link_util *slave_lu;
+	char slave[32];
 	char *kind;
 	char *slave_kind;
 
@@ -265,8 +266,9 @@ static void print_linktype(FILE *fp, struct rtattr *tb)
 
 		fprintf(fp, "%s", _SL_);
 		fprintf(fp, "    %s_slave ", slave_kind);
+		snprintf(slave, sizeof(slave), "%s_slave", slave_kind);
 
-		slave_lu = get_link_slave_kind(slave_kind);
+		slave_lu = get_link_kind(slave);
 		if (slave_lu && slave_lu->print_opt) {
 			struct rtattr *attr[slave_lu->maxattr+1], **data = NULL;
 
diff --git a/ip/iplink.c b/ip/iplink.c
index 6b1db18..dec8268 100644
--- a/ip/iplink.c
+++ b/ip/iplink.c
@@ -119,15 +119,14 @@ static int on_off(const char *msg, const char *realval)
 static void *BODY;		/* cached dlopen(NULL) handle */
 static struct link_util *linkutil_list;
 
-static struct link_util *__get_link_kind(const char *id, bool slave)
+struct link_util *get_link_kind(const char *id)
 {
 	void *dlh;
 	char buf[256];
 	struct link_util *l;
 
 	for (l = linkutil_list; l; l = l->next)
-		if (strcmp(l->id, id) == 0 &&
-		    l->slave == slave)
+		if (strcmp(l->id, id) == 0)
 			return l;
 
 	snprintf(buf, sizeof(buf), LIBDIR "/ip/link_%s.so", id);
@@ -142,10 +141,7 @@ static struct link_util *__get_link_kind(const char *id, bool slave)
 		}
 	}
 
-	if (slave)
-		snprintf(buf, sizeof(buf), "%s_slave_link_util", id);
-	else
-		snprintf(buf, sizeof(buf), "%s_link_util", id);
+	snprintf(buf, sizeof(buf), "%s_link_util", id);
 	l = dlsym(dlh, buf);
 	if (l == NULL)
 		return NULL;
@@ -155,16 +151,6 @@ static struct link_util *__get_link_kind(const char *id, bool slave)
 	return l;
 }
 
-struct link_util *get_link_kind(const char *id)
-{
-	return __get_link_kind(id, false);
-}
-
-struct link_util *get_link_slave_kind(const char *id)
-{
-	return __get_link_kind(id, true);
-}
-
 static int get_link_mode(const char *mode)
 {
 	if (strcasecmp(mode, "default") == 0)
@@ -872,26 +858,18 @@ static int iplink_modify(int cmd, unsigned int flags, int argc, char **argv)
 
 	if (type) {
 		struct rtattr *linkinfo;
-		char slavebuf[128], *ulinep = strchr(type, '_');
+		char *ulinep = strchr(type, '_');
 		int iflatype;
 
 		linkinfo = addattr_nest(&req.n, sizeof(req), IFLA_LINKINFO);
 		addattr_l(&req.n, sizeof(req), IFLA_INFO_KIND, type,
 			 strlen(type));
 
-		if (ulinep && !strcmp(ulinep, "_slave")) {
-			strncpy(slavebuf, type, sizeof(slavebuf));
-			slavebuf[sizeof(slavebuf) - 1] = '\0';
-			ulinep = strchr(slavebuf, '_');
-			/* check in case it was after sizeof(slavebuf) - 1*/
-			if (ulinep)
-				*ulinep = '\0';
-			lu = get_link_slave_kind(slavebuf);
+		lu = get_link_kind(type);
+		if (ulinep && !strcmp(ulinep, "_slave"))
 			iflatype = IFLA_INFO_SLAVE_DATA;
-		} else {
-			lu = get_link_kind(type);
+		else
 			iflatype = IFLA_INFO_DATA;
-		}
 		if (lu && argc) {
 			struct rtattr *data = addattr_nest(&req.n,
 							   sizeof(req), iflatype);
diff --git a/ip/iplink_bond_slave.c b/ip/iplink_bond_slave.c
index 9c60dea..877e2d9 100644
--- a/ip/iplink_bond_slave.c
+++ b/ip/iplink_bond_slave.c
@@ -130,10 +130,9 @@ static void bond_slave_print_help(struct link_util *lu, int argc, char **argv,
 }
 
 struct link_util bond_slave_link_util = {
-	.id		= "bond",
+	.id		= "bond_slave",
 	.maxattr	= IFLA_BOND_SLAVE_MAX,
 	.print_opt	= bond_slave_print_opt,
 	.parse_opt	= bond_slave_parse_opt,
 	.print_help	= bond_slave_print_help,
-	.slave		= true,
 };
diff --git a/ip/iplink_bridge_slave.c b/ip/iplink_bridge_slave.c
index a44d4e4..6c5c59a 100644
--- a/ip/iplink_bridge_slave.c
+++ b/ip/iplink_bridge_slave.c
@@ -293,10 +293,9 @@ static void bridge_slave_print_help(struct link_util *lu, int argc, char **argv,
 }
 
 struct link_util bridge_slave_link_util = {
-	.id		= "bridge",
+	.id		= "bridge_slave",
 	.maxattr	= IFLA_BRPORT_MAX,
 	.print_opt	= bridge_slave_print_opt,
 	.parse_opt	= bridge_slave_parse_opt,
 	.print_help     = bridge_slave_print_help,
-	.slave		= true,
 };
diff --git a/ip/iplink_vrf.c b/ip/iplink_vrf.c
index 015b41e..a238b29 100644
--- a/ip/iplink_vrf.c
+++ b/ip/iplink_vrf.c
@@ -91,10 +91,9 @@ struct link_util vrf_link_util = {
 };
 
 struct link_util vrf_slave_link_util = {
-	.id             = "vrf",
+	.id             = "vrf_slave",
 	.maxattr        = IFLA_VRF_PORT_MAX,
 	.print_opt	= vrf_slave_print_opt,
-	.slave          = true,
 };
 
 /* returns table id if name is a VRF device */
diff --git a/ip/ipmacsec.c b/ip/ipmacsec.c
index 2e670e9..afbf67e 100644
--- a/ip/ipmacsec.c
+++ b/ip/ipmacsec.c
@@ -1265,5 +1265,4 @@ struct link_util macsec_link_util = {
 	.parse_opt = macsec_parse_opt,
 	.print_help = macsec_print_help,
 	.print_opt = macsec_print_opt,
-	.slave = false,
 };
-- 
2.5.5
