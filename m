From: <richard.alpe@ericsson.com>
Subject: [PATCH v2 net-next 10/15] tipc: add media set to new netlink api
Date: Thu, 2 Oct 2014 16:58:36 +0200
Message-ID: <1412261921-28510-11-git-send-email-richard.alpe@ericsson.com>
References: <1412261921-28510-1-git-send-email-richard.alpe@ericsson.com>
Mime-Version: 1.0
Content-Type: text/plain
Cc: <tipc-discussion@lists.sourceforge.net>,
	Richard Alpe <richard.alpe@ericsson.com>
To: <netdev@vger.kernel.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from sessmg23.ericsson.net ([193.180.251.45]:43721 "EHLO
	sessmg23.ericsson.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1754515AbaJBPAM (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 2 Oct 2014 11:00:12 -0400
In-Reply-To: <1412261921-28510-1-git-send-email-richard.alpe@ericsson.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Richard Alpe <richard.alpe@ericsson.com>

Add TIPC_NL_MEDIA_SET command to the new tipc netlink API.

This command can set one or more link properties for a particular
media.

Netlink logical layout of bearer set message:
-> media
    -> name
    -> link properties
        [ -> tolerance ]
        [ -> priority ]
        [ -> window ]

Signed-off-by: Richard Alpe <richard.alpe@ericsson.com>
Reviewed-by: Erik Hugne <erik.hugne@ericsson.com>
Reviewed-by: Jon Maloy <jon.maloy@ericsson.com>
Acked-by: Ying Xue <ying.xue@windriver.com>
---
 include/uapi/linux/tipc_config.h |    1 +
 net/tipc/bearer.c                |   47 ++++++++++++++++++++++++++++++++++++++
 net/tipc/bearer.h                |    1 +
 net/tipc/netlink.c               |    5 ++++
 4 files changed, 54 insertions(+)

diff --git a/include/uapi/linux/tipc_config.h b/include/uapi/linux/tipc_config.h
index f22f27c..6774c60 100644
--- a/include/uapi/linux/tipc_config.h
+++ b/include/uapi/linux/tipc_config.h
@@ -60,6 +60,7 @@ enum {
 	TIPC_NL_LINK_SET,
 	TIPC_NL_LINK_RESET_STATS,
 	TIPC_NL_MEDIA_GET,
+	TIPC_NL_MEDIA_SET,
 
 	__TIPC_NL_CMD_MAX,
 	TIPC_NL_CMD_MAX = __TIPC_NL_CMD_MAX - 1
diff --git a/net/tipc/bearer.c b/net/tipc/bearer.c
index ad33e44..3e33771 100644
--- a/net/tipc/bearer.c
+++ b/net/tipc/bearer.c
@@ -1023,3 +1023,50 @@ err_out:
 
 	return err;
 }
+
+int tipc_nl_media_set(struct sk_buff *skb, struct genl_info *info)
+{
+	int err;
+	char *name;
+	struct tipc_media *m;
+	struct nlattr *attrs[TIPC_NLA_BEARER_MAX + 1];
+
+	if (!info->attrs[TIPC_NLA_MEDIA])
+		return -EINVAL;
+
+	err = nla_parse_nested(attrs, TIPC_NLA_MEDIA_MAX,
+			       info->attrs[TIPC_NLA_MEDIA],
+			       tipc_nl_media_policy);
+
+	if (!attrs[TIPC_NLA_MEDIA_NAME])
+		return -EINVAL;
+	name = nla_data(attrs[TIPC_NLA_MEDIA_NAME]);
+
+	rtnl_lock();
+	m = tipc_media_find(name);
+	if (!m) {
+		rtnl_unlock();
+		return -EINVAL;
+	}
+
+	if (attrs[TIPC_NLA_MEDIA_PROP]) {
+		struct nlattr *props[TIPC_NLA_PROP_MAX + 1];
+
+		err = tipc_nl_parse_link_prop(attrs[TIPC_NLA_MEDIA_PROP],
+					      props);
+		if (err) {
+			rtnl_unlock();
+			return err;
+		}
+
+		if (props[TIPC_NLA_PROP_TOL])
+			m->tolerance = nla_get_u32(props[TIPC_NLA_PROP_TOL]);
+		if (props[TIPC_NLA_PROP_PRIO])
+			m->priority = nla_get_u32(props[TIPC_NLA_PROP_PRIO]);
+		if (props[TIPC_NLA_PROP_WIN])
+			m->window = nla_get_u32(props[TIPC_NLA_PROP_WIN]);
+	}
+	rtnl_unlock();
+
+	return 0;
+}
diff --git a/net/tipc/bearer.h b/net/tipc/bearer.h
index bacd225..b1d9052 100644
--- a/net/tipc/bearer.h
+++ b/net/tipc/bearer.h
@@ -186,6 +186,7 @@ int tipc_nl_bearer_set(struct sk_buff *skb, struct genl_info *info);
 
 int tipc_nl_media_dump(struct sk_buff *skb, struct netlink_callback *cb);
 int tipc_nl_media_get(struct sk_buff *skb, struct genl_info *info);
+int tipc_nl_media_set(struct sk_buff *skb, struct genl_info *info);
 
 int tipc_media_set_priority(const char *name, u32 new_value);
 int tipc_media_set_window(const char *name, u32 new_value);
diff --git a/net/tipc/netlink.c b/net/tipc/netlink.c
index ae96460..42ea5cd 100644
--- a/net/tipc/netlink.c
+++ b/net/tipc/netlink.c
@@ -146,6 +146,11 @@ static const struct genl_ops tipc_genl_ops[] = {
 		.doit	= tipc_nl_media_get,
 		.dumpit	= tipc_nl_media_dump,
 		.policy = tipc_nl_policy,
+	},
+	{
+		.cmd	= TIPC_NL_MEDIA_SET,
+		.doit	= tipc_nl_media_set,
+		.policy = tipc_nl_policy,
 	}
 };
 
-- 
1.7.10.4
