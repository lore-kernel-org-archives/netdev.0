From: Michal Kubecek <mkubecek@suse.cz>
Subject: [PATCH iproute2 net-next-for-3.13 1/2] iplink: display slave
 information
Date: Mon, 10 Feb 2014 09:11:46 +0100 (CET)
Message-ID: <20140210081146.6F4FEE5697@unicorn.suse.cz>
Cc: netdev@vger.kernel.org
To: Stephen Hemminger <stephen@networkplumber.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from cantor2.suse.de ([195.135.220.15]:43739 "EHLO mx2.suse.de"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1751691AbaBJILr (ORCPT <rfc822;netdev@vger.kernel.org>);
	Mon, 10 Feb 2014 03:11:47 -0500
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Add print_slave_opt() callback and maxslattr value to struct
link_util. These are analogous to print_opt() and maxattr but
relate to slave info (IFLA_INFO_SLAVE_{KIND,DATA}).

Display the slave specific info in output of "ip -d link show".

Signed-off-by: Michal Kubecek <mkubecek@suse.cz>
---
 ip/ip_common.h |  3 +++
 ip/ipaddress.c | 27 +++++++++++++++++++++++++--
 2 files changed, 28 insertions(+), 2 deletions(-)

diff --git a/ip/ip_common.h b/ip/ip_common.h
index f9b4734..b1703a7 100644
--- a/ip/ip_common.h
+++ b/ip/ip_common.h
@@ -66,12 +66,15 @@ struct link_util
 	struct link_util	*next;
 	const char		*id;
 	int			maxattr;
+	int			maxslattr;
 	int			(*parse_opt)(struct link_util *, int, char **,
 					     struct nlmsghdr *);
 	void			(*print_opt)(struct link_util *, FILE *,
 					     struct rtattr *[]);
 	void			(*print_xstats)(struct link_util *, FILE *,
 					     struct rtattr *);
+	void			(*print_slave_opt)(struct link_util *, FILE *,
+					     struct rtattr *[]);
 };
 
 struct link_util *get_link_kind(const char *kind);
diff --git a/ip/ipaddress.c b/ip/ipaddress.c
index f794fa1..3cb7ee7 100644
--- a/ip/ipaddress.c
+++ b/ip/ipaddress.c
@@ -197,7 +197,7 @@ static void print_linktype(FILE *fp, struct rtattr *tb)
 	parse_rtattr_nested(linkinfo, IFLA_INFO_MAX, tb);
 
 	if (!linkinfo[IFLA_INFO_KIND])
-		return;
+		goto no_info;
 	kind = RTA_DATA(linkinfo[IFLA_INFO_KIND]);
 
 	fprintf(fp, "%s", _SL_);
@@ -205,7 +205,7 @@ static void print_linktype(FILE *fp, struct rtattr *tb)
 
 	lu = get_link_kind(kind);
 	if (!lu || !lu->print_opt)
-		return;
+		goto no_info;
 
 	if (1) {
 		struct rtattr *attr[lu->maxattr+1], **data = NULL;
@@ -221,6 +221,29 @@ static void print_linktype(FILE *fp, struct rtattr *tb)
 		    lu->print_xstats)
 			lu->print_xstats(lu, fp, linkinfo[IFLA_INFO_XSTATS]);
 	}
+
+no_info:
+	if (!linkinfo[IFLA_INFO_SLAVE_KIND])
+		return;
+	kind = RTA_DATA(linkinfo[IFLA_INFO_SLAVE_KIND]);
+
+	fprintf(fp, "%s", _SL_);
+	fprintf(fp, "    %s_slave ", kind);
+
+	lu = get_link_kind(kind);
+	if (!lu || !lu->print_slave_opt)
+		return;
+
+	if (1) {
+		struct rtattr *attr[lu->maxslattr+1], **data = NULL;
+
+		if (linkinfo[IFLA_INFO_SLAVE_DATA]) {
+			parse_rtattr_nested(attr, lu->maxslattr,
+					    linkinfo[IFLA_INFO_SLAVE_DATA]);
+			data = attr;
+		}
+		lu->print_slave_opt(lu, fp, data);
+	}
 }
 
 static void print_vfinfo(FILE *fp, struct rtattr *vfinfo)
-- 
1.8.1.4
