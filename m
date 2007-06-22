From: Patrick McHardy <kaber@trash.net>
Subject: Re: [IPROUTE]: Add nested compat attribute
Date: Fri, 22 Jun 2007 19:21:40 +0200
Message-ID: <467C0524.6010208@trash.net>
References: <467BF665.60406@trash.net>
Mime-Version: 1.0
Content-Type: multipart/mixed;
 boundary="------------060701060508000505000904"
Cc: netdev@vger.kernel.org,
	PJ Waskiewicz <peter.p.waskiewicz.jr@intel.com>
To: Stephen Hemminger <shemminger@linux-foundation.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from stinky.trash.net ([213.144.137.162]:35137 "EHLO
	stinky.trash.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1754734AbXFVRWW (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 22 Jun 2007 13:22:22 -0400
In-Reply-To: <467BF665.60406@trash.net>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

This is a multi-part message in MIME format.
--------------060701060508000505000904
Content-Type: text/plain; charset=ISO-8859-15
Content-Transfer-Encoding: 7bit

Patrick McHardy wrote:
>  extern int parse_rtattr(struct rtattr *tb[], int max, struct rtattr *rta, int len);
>  extern int parse_rtattr_byindex(struct rtattr *tb[], int max, struct rtattr *rta, int len);
> +extern int parse_rtattr_nested_compat(struct rtattr *tb[], int max, struct rtattr *rta, void **data, int len);


Same change as in the kernel patch, avoid cast in caller
and make the signature match existing ones better.


--------------060701060508000505000904
Content-Type: text/plain;
 name="x2"
Content-Transfer-Encoding: 7bit
Content-Disposition: inline;
 filename="x2"

[IPROUTE]: Add nested compat attribute

Add a nested compat attribute type that can be used to convert
attributes that contain a structure to nested attributes in a
backwards compatible way.

The attribute looks like this:

struct {
	[ compat contents ]
	struct rtattr {
		.rta_len	= total size,
		.rta_type	= type,
	} rta;
	struct old_structure struct;

	[ nested top-level attribute ]
	struct rtattr {
		.rta_len	= nest size,
		.rta_type	= type,
	} nest_attr;

	[ optional 0 .. n nested attributes ]
	struct rtattr {
		.rta_len	= private attribute len,
		.rta_type	= private attribute typ,
	} nested_attr;
	struct nested_data data;
};

Since both userspace and kernel deal correctly with attributes that are
larger than expected old versions will just parse the compat part and
ignore the rest.

Signed-off-by: Patrick McHardy <kaber@trash.net>

---
commit 7d4cee8b6e0ddceda300ad1e4242cd068a722f0c
tree ea8b1245518d6ed352ef5d8e379588fa76981de9
parent cd71a8e07f57a74d52e62cc1fed39c03ad64bc08
author Patrick McHardy <kaber@gw.localnet> Fri, 22 Jun 2007 19:13:08 +0200
committer Patrick McHardy <kaber@gw.localnet> Fri, 22 Jun 2007 19:13:08 +0200

 include/libnetlink.h |    9 +++++++++
 lib/libnetlink.c     |   46 ++++++++++++++++++++++++++++++++++++++++++++++
 2 files changed, 55 insertions(+), 0 deletions(-)

diff --git a/include/libnetlink.h b/include/libnetlink.h
index 49e248e..b67c5a5 100644
--- a/include/libnetlink.h
+++ b/include/libnetlink.h
@@ -39,15 +39,24 @@ extern int rtnl_send(struct rtnl_handle 
 extern int addattr32(struct nlmsghdr *n, int maxlen, int type, __u32 data);
 extern int addattr_l(struct nlmsghdr *n, int maxlen, int type, const void *data, int alen);
 extern int addraw_l(struct nlmsghdr *n, int maxlen, const void *data, int len);
+extern struct rtattr *addattr_nest(struct nlmsghdr *n, int maxlen, int type);
+extern int addattr_nest_end(struct nlmsghdr *n, struct rtattr *nest);
+extern struct rtattr *addattr_nest_compat(struct nlmsghdr *n, int maxlen, int type, const void *data, int len);
+extern int addattr_nest_compat_end(struct nlmsghdr *n, struct rtattr *nest);
 extern int rta_addattr32(struct rtattr *rta, int maxlen, int type, __u32 data);
 extern int rta_addattr_l(struct rtattr *rta, int maxlen, int type, const void *data, int alen);
 
 extern int parse_rtattr(struct rtattr *tb[], int max, struct rtattr *rta, int len);
 extern int parse_rtattr_byindex(struct rtattr *tb[], int max, struct rtattr *rta, int len);
+extern int __parse_rtattr_nested_compat(struct rtattr *tb[], int max, struct rtattr *rta, int len);
 
 #define parse_rtattr_nested(tb, max, rta) \
 	(parse_rtattr((tb), (max), RTA_DATA(rta), RTA_PAYLOAD(rta)))
 
+#define parse_rtattr_nested_compat(tb, max, rta, data, len) \
+({	data = RTA_PAYLOAD(rta) >= len ? RTA_DATA(rta) : NULL; \
+	__parse_rtattr_nested_compat(tb, max, rta, len); })
+
 extern int rtnl_listen(struct rtnl_handle *, rtnl_filter_t handler,
 		       void *jarg);
 extern int rtnl_from_file(FILE *, rtnl_filter_t handler,
diff --git a/lib/libnetlink.c b/lib/libnetlink.c
index 555dd5c..12883fe 100644
--- a/lib/libnetlink.c
+++ b/lib/libnetlink.c
@@ -527,6 +527,39 @@ int addraw_l(struct nlmsghdr *n, int max
 	return 0;
 }
 
+struct rtattr *addattr_nest(struct nlmsghdr *n, int maxlen, int type)
+{
+	struct rtattr *nest = NLMSG_TAIL(n);
+
+	addattr_l(n, maxlen, type, NULL, 0);
+	return nest;
+}
+
+int addattr_nest_end(struct nlmsghdr *n, struct rtattr *nest)
+{
+	nest->rta_len = (void *)NLMSG_TAIL(n) - (void *)nest;
+	return n->nlmsg_len;
+}
+
+struct rtattr *addattr_nest_compat(struct nlmsghdr *n, int maxlen, int type,
+				   const void *data, int len)
+{
+	struct rtattr *start = NLMSG_TAIL(n);
+
+	addattr_l(n, maxlen, type, data, len);
+	addattr_nest(n, maxlen, type);
+	return start;
+}
+
+int addattr_nest_compat_end(struct nlmsghdr *n, struct rtattr *start)
+{
+	struct rtattr *nest = (void *)start + NLMSG_ALIGN(start->rta_len);
+
+	start->rta_len = (void *)NLMSG_TAIL(n) - (void *)start;
+	addattr_nest_end(n, nest);
+	return n->nlmsg_len;
+}
+
 int rta_addattr32(struct rtattr *rta, int maxlen, int type, __u32 data)
 {
 	int len = RTA_LENGTH(4);
@@ -589,3 +622,16 @@ int parse_rtattr_byindex(struct rtattr *
 		fprintf(stderr, "!!!Deficit %d, rta_len=%d\n", len, rta->rta_len);
 	return i;
 }
+
+int __parse_rtattr_nested_compat(struct rtattr *tb[], int max, struct rtattr *rta,
+			         int len)
+{
+	if (RTA_PAYLOAD(rta) < len)
+		return -1;
+	if (RTA_PAYLOAD(rta) >= RTA_ALIGN(len) + sizeof(struct rtattr)) {
+		rta = RTA_DATA(rta) + RTA_ALIGN(len);
+		return parse_rtattr_nested(tb, max, rta);
+	}
+	memset(tb, 0, sizeof(struct rtattr *) * max);
+	return 0;
+}


--------------060701060508000505000904--
