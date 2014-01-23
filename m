From: Jiri Pirko <jiri@resnulli.us>
Subject: [patch iproute2 net-next-for-3.13 1/2] introduce support for slave info data
Date: Thu, 23 Jan 2014 17:52:53 +0100
Message-ID: <1390495974-11234-2-git-send-email-jiri@resnulli.us>
References: <1390495974-11234-1-git-send-email-jiri@resnulli.us>
Cc: davem@davemloft.net, fubar@us.ibm.com, vfalico@redhat.com,
	andy@greyhouse.net, sfeldma@cumulusnetworks.com,
	stephen@networkplumber.org, john.r.fastabend@intel.com
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-we0-f175.google.com ([74.125.82.175]:49623 "EHLO
	mail-we0-f175.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752351AbaAWQxA (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 23 Jan 2014 11:53:00 -0500
Received: by mail-we0-f175.google.com with SMTP id p61so1461913wes.20
        for <netdev@vger.kernel.org>; Thu, 23 Jan 2014 08:52:59 -0800 (PST)
In-Reply-To: <1390495974-11234-1-git-send-email-jiri@resnulli.us>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Signed-off-by: Jiri Pirko <jiri@resnulli.us>
---
 include/linux/if_link.h |  2 ++
 ip/ip_common.h          |  4 ++++
 ip/ipaddress.c          | 54 ++++++++++++++++++++++++++++++++-----------------
 ip/iplink.c             | 21 ++++++++++++++++---
 4 files changed, 60 insertions(+), 21 deletions(-)

diff --git a/include/linux/if_link.h b/include/linux/if_link.h
index 9cb5909..d59f05e 100644
--- a/include/linux/if_link.h
+++ b/include/linux/if_link.h
@@ -239,6 +239,8 @@ enum {
 	IFLA_INFO_KIND,
 	IFLA_INFO_DATA,
 	IFLA_INFO_XSTATS,
+	IFLA_INFO_SLAVE_KIND,
+	IFLA_INFO_SLAVE_DATA,
 	__IFLA_INFO_MAX,
 };
 
diff --git a/ip/ip_common.h b/ip/ip_common.h
index f9b4734..698dc7a 100644
--- a/ip/ip_common.h
+++ b/ip/ip_common.h
@@ -61,6 +61,8 @@ static inline int rtm_get_table(struct rtmsg *r, struct rtattr **tb)
 
 extern struct rtnl_handle rth;
 
+#include <stdbool.h>
+
 struct link_util
 {
 	struct link_util	*next;
@@ -72,9 +74,11 @@ struct link_util
 					     struct rtattr *[]);
 	void			(*print_xstats)(struct link_util *, FILE *,
 					     struct rtattr *);
+	bool			slave;
 };
 
 struct link_util *get_link_kind(const char *kind);
+struct link_util *get_link_slave_kind(const char *slave_kind);
 int get_netns_fd(const char *name);
 
 #ifndef	INFINITY_LIFE_TIME
diff --git a/ip/ipaddress.c b/ip/ipaddress.c
index f794fa1..33698ae 100644
--- a/ip/ipaddress.c
+++ b/ip/ipaddress.c
@@ -192,34 +192,52 @@ static void print_linktype(FILE *fp, struct rtattr *tb)
 {
 	struct rtattr *linkinfo[IFLA_INFO_MAX+1];
 	struct link_util *lu;
+	struct link_util *slave_lu;
 	char *kind;
+	char *slave_kind;
 
 	parse_rtattr_nested(linkinfo, IFLA_INFO_MAX, tb);
 
-	if (!linkinfo[IFLA_INFO_KIND])
-		return;
-	kind = RTA_DATA(linkinfo[IFLA_INFO_KIND]);
+	if (linkinfo[IFLA_INFO_KIND]) {
+		kind = RTA_DATA(linkinfo[IFLA_INFO_KIND]);
 
-	fprintf(fp, "%s", _SL_);
-	fprintf(fp, "    %s ", kind);
+		fprintf(fp, "%s", _SL_);
+		fprintf(fp, "    %s ", kind);
 
-	lu = get_link_kind(kind);
-	if (!lu || !lu->print_opt)
-		return;
+		lu = get_link_kind(kind);
+		if (lu && lu->print_opt) {
+			struct rtattr *attr[lu->maxattr+1], **data = NULL;
 
-	if (1) {
-		struct rtattr *attr[lu->maxattr+1], **data = NULL;
+			if (linkinfo[IFLA_INFO_DATA]) {
+				parse_rtattr_nested(attr, lu->maxattr,
+						    linkinfo[IFLA_INFO_DATA]);
+				data = attr;
+			}
+			lu->print_opt(lu, fp, data);
 
-		if (linkinfo[IFLA_INFO_DATA]) {
-			parse_rtattr_nested(attr, lu->maxattr,
-					    linkinfo[IFLA_INFO_DATA]);
-			data = attr;
+			if (linkinfo[IFLA_INFO_XSTATS] && show_stats &&
+			    lu->print_xstats)
+				lu->print_xstats(lu, fp, linkinfo[IFLA_INFO_XSTATS]);
 		}
-		lu->print_opt(lu, fp, data);
+	}
 
-		if (linkinfo[IFLA_INFO_XSTATS] && show_stats &&
-		    lu->print_xstats)
-			lu->print_xstats(lu, fp, linkinfo[IFLA_INFO_XSTATS]);
+	if (linkinfo[IFLA_INFO_SLAVE_KIND]) {
+		slave_kind = RTA_DATA(linkinfo[IFLA_INFO_SLAVE_KIND]);
+
+		fprintf(fp, "%s", _SL_);
+		fprintf(fp, "    %s_slave ", slave_kind);
+
+		slave_lu = get_link_slave_kind(slave_kind);
+		if (slave_lu && slave_lu->print_opt) {
+			struct rtattr *attr[slave_lu->maxattr+1], **data = NULL;
+
+			if (linkinfo[IFLA_INFO_SLAVE_DATA]) {
+				parse_rtattr_nested(attr, slave_lu->maxattr,
+						    linkinfo[IFLA_INFO_SLAVE_DATA]);
+				data = attr;
+			}
+			slave_lu->print_opt(slave_lu, fp, data);
+		}
 	}
 }
 
diff --git a/ip/iplink.c b/ip/iplink.c
index 343b29f..6a62cc0 100644
--- a/ip/iplink.c
+++ b/ip/iplink.c
@@ -27,6 +27,7 @@
 #include <string.h>
 #include <sys/ioctl.h>
 #include <linux/sockios.h>
+#include <stdbool.h>
 
 #include "rt_names.h"
 #include "utils.h"
@@ -105,14 +106,15 @@ static int on_off(const char *msg, const char *realval)
 static void *BODY;		/* cached dlopen(NULL) handle */
 static struct link_util *linkutil_list;
 
-struct link_util *get_link_kind(const char *id)
+static struct link_util *__get_link_kind(const char *id, bool slave)
 {
 	void *dlh;
 	char buf[256];
 	struct link_util *l;
 
 	for (l = linkutil_list; l; l = l->next)
-		if (strcmp(l->id, id) == 0)
+		if (strcmp(l->id, id) == 0 &&
+		    l->slave == slave)
 			return l;
 
 	snprintf(buf, sizeof(buf), LIBDIR "/ip/link_%s.so", id);
@@ -127,7 +129,10 @@ struct link_util *get_link_kind(const char *id)
 		}
 	}
 
-	snprintf(buf, sizeof(buf), "%s_link_util", id);
+	if (slave)
+		snprintf(buf, sizeof(buf), "%s_slave_link_util", id);
+	else
+		snprintf(buf, sizeof(buf), "%s_link_util", id);
 	l = dlsym(dlh, buf);
 	if (l == NULL)
 		return NULL;
@@ -137,6 +142,16 @@ struct link_util *get_link_kind(const char *id)
 	return l;
 }
 
+struct link_util *get_link_kind(const char *id)
+{
+	return __get_link_kind(id, false);
+}
+
+struct link_util *get_link_slave_kind(const char *id)
+{
+	return __get_link_kind(id, true);
+}
+
 static int get_link_mode(const char *mode)
 {
 	if (strcasecmp(mode, "default") == 0)
-- 
1.8.3.1
