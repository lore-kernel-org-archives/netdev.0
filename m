From: <richard.alpe@ericsson.com>
Subject: [PATCH v3 net-next 09/14] tipc: add media
	get/dump to new netlink api
Date: Thu, 20 Nov 2014 10:29:15 +0100
Message-ID: <1416475760-18914-10-git-send-email-richard.alpe@ericsson.com>
References: <1416475760-18914-1-git-send-email-richard.alpe@ericsson.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
Cc: tipc-discussion@lists.sourceforge.net
To: <netdev@vger.kernel.org>
Return-path: <tipc-discussion-bounces@lists.sourceforge.net>
In-Reply-To: <1416475760-18914-1-git-send-email-richard.alpe@ericsson.com>
List-Unsubscribe: <https://lists.sourceforge.net/lists/listinfo/tipc-discussion>,
	<mailto:tipc-discussion-request@lists.sourceforge.net?subject=unsubscribe>
List-Archive: <http://sourceforge.net/mailarchive/forum.php?forum_name=tipc-discussion>
List-Post: <mailto:tipc-discussion@lists.sourceforge.net>
List-Help: <mailto:tipc-discussion-request@lists.sourceforge.net?subject=help>
List-Subscribe: <https://lists.sourceforge.net/lists/listinfo/tipc-discussion>,
	<mailto:tipc-discussion-request@lists.sourceforge.net?subject=subscribe>
Errors-To: tipc-discussion-bounces@lists.sourceforge.net
List-Id: netdev.vger.kernel.org

From: Richard Alpe <richard.alpe@ericsson.com>

Add TIPC_NL_MEDIA_GET command to the new tipc netlink API.

This command supports dumping all information about all defined
media as well as getting all information about a specific media.

The information about a media includes name and link properties.

Netlink logical layout of media get response message:
-> media
    -> name
    -> link properties
        -> tolerance
        -> priority
        -> window

Signed-off-by: Richard Alpe <richard.alpe@ericsson.com>
Reviewed-by: Erik Hugne <erik.hugne@ericsson.com>
Reviewed-by: Jon Maloy <jon.maloy@ericsson.com>
Acked-by: Ying Xue <ying.xue@windriver.com>
---
 include/uapi/linux/tipc_netlink.h |   12 ++++
 net/tipc/bearer.c                 |  125 +++++++++++++++++++++++++++++++++++++
 net/tipc/bearer.h                 |    3 +
 net/tipc/netlink.c                |    7 +++
 4 files changed, 147 insertions(+)

diff --git a/include/uapi/linux/tipc_netlink.h b/include/uapi/linux/tipc_netlink.h
index 574882a..4101b70 100644
--- a/include/uapi/linux/tipc_netlink.h
+++ b/include/uapi/linux/tipc_netlink.h
@@ -50,6 +50,7 @@ enum {
 	TIPC_NL_LINK_GET,
 	TIPC_NL_LINK_SET,
 	TIPC_NL_LINK_RESET_STATS,
+	TIPC_NL_MEDIA_GET,
 
 	__TIPC_NL_CMD_MAX,
 	TIPC_NL_CMD_MAX = __TIPC_NL_CMD_MAX - 1
@@ -62,6 +63,7 @@ enum {
 	TIPC_NLA_SOCK,			/* nest */
 	TIPC_NLA_PUBL,			/* nest */
 	TIPC_NLA_LINK,			/* nest */
+	TIPC_NLA_MEDIA,			/* nest */
 
 	__TIPC_NLA_MAX,
 	TIPC_NLA_MAX = __TIPC_NLA_MAX - 1
@@ -108,6 +110,16 @@ enum {
 	TIPC_NLA_LINK_MAX = __TIPC_NLA_LINK_MAX - 1
 };
 
+/* Media info */
+enum {
+	TIPC_NLA_MEDIA_UNSPEC,
+	TIPC_NLA_MEDIA_NAME,		/* string */
+	TIPC_NLA_MEDIA_PROP,		/* nest */
+
+	__TIPC_NLA_MEDIA_MAX,
+	TIPC_NLA_MEDIA_MAX = __TIPC_NLA_MEDIA_MAX - 1
+};
+
 /* Publication info */
 enum {
 	TIPC_NLA_PUBL_UNSPEC,
diff --git a/net/tipc/bearer.c b/net/tipc/bearer.c
index 6d547d0..26630a5 100644
--- a/net/tipc/bearer.c
+++ b/net/tipc/bearer.c
@@ -61,6 +61,12 @@ tipc_nl_bearer_policy[TIPC_NLA_BEARER_MAX + 1]	= {
 	[TIPC_NLA_BEARER_DOMAIN]		= { .type = NLA_U32 }
 };
 
+static const struct nla_policy tipc_nl_media_policy[TIPC_NLA_MEDIA_MAX + 1] = {
+	[TIPC_NLA_MEDIA_UNSPEC]		= { .type = NLA_UNSPEC },
+	[TIPC_NLA_MEDIA_NAME]		= { .type = NLA_STRING },
+	[TIPC_NLA_MEDIA_PROP]		= { .type = NLA_NESTED }
+};
+
 struct tipc_bearer __rcu *bearer_list[MAX_BEARERS + 1];
 
 static void bearer_disable(struct tipc_bearer *b_ptr, bool shutting_down);
@@ -898,3 +904,122 @@ int tipc_nl_bearer_set(struct sk_buff *skb, struct genl_info *info)
 
 	return 0;
 }
+
+int __tipc_nl_add_media(struct tipc_nl_msg *msg, struct tipc_media *media)
+{
+	void *hdr;
+	struct nlattr *attrs;
+	struct nlattr *prop;
+
+	hdr = genlmsg_put(msg->skb, msg->portid, msg->seq, &tipc_genl_v2_family,
+			  NLM_F_MULTI, TIPC_NL_MEDIA_GET);
+	if (!hdr)
+		return -EMSGSIZE;
+
+	attrs = nla_nest_start(msg->skb, TIPC_NLA_MEDIA);
+	if (!attrs)
+		goto msg_full;
+
+	if (nla_put_string(msg->skb, TIPC_NLA_MEDIA_NAME, media->name))
+		goto attr_msg_full;
+
+	prop = nla_nest_start(msg->skb, TIPC_NLA_MEDIA_PROP);
+	if (!prop)
+		goto prop_msg_full;
+	if (nla_put_u32(msg->skb, TIPC_NLA_PROP_PRIO, media->priority))
+		goto prop_msg_full;
+	if (nla_put_u32(msg->skb, TIPC_NLA_PROP_TOL, media->tolerance))
+		goto prop_msg_full;
+	if (nla_put_u32(msg->skb, TIPC_NLA_PROP_WIN, media->window))
+		goto prop_msg_full;
+
+	nla_nest_end(msg->skb, prop);
+	nla_nest_end(msg->skb, attrs);
+	genlmsg_end(msg->skb, hdr);
+
+	return 0;
+
+prop_msg_full:
+	nla_nest_cancel(msg->skb, prop);
+attr_msg_full:
+	nla_nest_cancel(msg->skb, attrs);
+msg_full:
+	genlmsg_cancel(msg->skb, hdr);
+
+	return -EMSGSIZE;
+}
+
+int tipc_nl_media_dump(struct sk_buff *skb, struct netlink_callback *cb)
+{
+	int err;
+	int i = cb->args[0];
+	struct tipc_nl_msg msg;
+
+	if (i == MAX_MEDIA)
+		return 0;
+
+	msg.skb = skb;
+	msg.portid = NETLINK_CB(cb->skb).portid;
+	msg.seq = cb->nlh->nlmsg_seq;
+
+	rtnl_lock();
+	for (; media_info_array[i] != NULL; i++) {
+		err = __tipc_nl_add_media(&msg, media_info_array[i]);
+		if (err)
+			break;
+	}
+	rtnl_unlock();
+
+	cb->args[0] = i;
+	return skb->len;
+}
+
+int tipc_nl_media_get(struct sk_buff *skb, struct genl_info *info)
+{
+	int err;
+	char *name;
+	struct tipc_nl_msg msg;
+	struct tipc_media *media;
+	struct sk_buff *rep;
+	struct nlattr *attrs[TIPC_NLA_BEARER_MAX + 1];
+
+	if (!info->attrs[TIPC_NLA_MEDIA])
+		return -EINVAL;
+
+	err = nla_parse_nested(attrs, TIPC_NLA_MEDIA_MAX,
+			       info->attrs[TIPC_NLA_MEDIA],
+			       tipc_nl_media_policy);
+	if (err)
+		return err;
+
+	if (!attrs[TIPC_NLA_MEDIA_NAME])
+		return -EINVAL;
+	name = nla_data(attrs[TIPC_NLA_MEDIA_NAME]);
+
+	rep = nlmsg_new(NLMSG_GOODSIZE, GFP_KERNEL);
+	if (!rep)
+		return -ENOMEM;
+
+	msg.skb = rep;
+	msg.portid = info->snd_portid;
+	msg.seq = info->snd_seq;
+
+	rtnl_lock();
+	media = tipc_media_find(name);
+	if (!media) {
+		err = -EINVAL;
+		goto err_out;
+	}
+
+	err = __tipc_nl_add_media(&msg, media);
+	if (err)
+		goto err_out;
+	rtnl_unlock();
+
+	return genlmsg_reply(rep, info);
+err_out:
+	rtnl_unlock();
+	nlmsg_free(rep);
+
+	return err;
+}
diff --git a/net/tipc/bearer.h b/net/tipc/bearer.h
index c6cf9df..bacd225 100644
--- a/net/tipc/bearer.h
+++ b/net/tipc/bearer.h
@@ -184,6 +184,9 @@ int tipc_nl_bearer_dump(struct sk_buff *skb, struct netlink_callback *cb);
 int tipc_nl_bearer_get(struct sk_buff *skb, struct genl_info *info);
 int tipc_nl_bearer_set(struct sk_buff *skb, struct genl_info *info);
 
+int tipc_nl_media_dump(struct sk_buff *skb, struct netlink_callback *cb);
+int tipc_nl_media_get(struct sk_buff *skb, struct genl_info *info);
+
 int tipc_media_set_priority(const char *name, u32 new_value);
 int tipc_media_set_window(const char *name, u32 new_value);
 void tipc_media_addr_printf(char *buf, int len, struct tipc_media_addr *a);
diff --git a/net/tipc/netlink.c b/net/tipc/netlink.c
index 68bfd11..742e51a 100644
--- a/net/tipc/netlink.c
+++ b/net/tipc/netlink.c
@@ -77,6 +77,7 @@ static const struct nla_policy tipc_nl_policy[TIPC_NLA_MAX + 1] = {
 	[TIPC_NLA_SOCK]		= { .type = NLA_NESTED, },
 	[TIPC_NLA_PUBL]		= { .type = NLA_NESTED, },
 	[TIPC_NLA_LINK]		= { .type = NLA_NESTED, },
+	[TIPC_NLA_MEDIA]	= { .type = NLA_NESTED, },
 };
 
 /* Legacy ASCII API */
@@ -154,6 +155,12 @@ static const struct genl_ops tipc_genl_v2_ops[] = {
 		.cmd	= TIPC_NL_LINK_RESET_STATS,
 		.doit   = tipc_nl_link_reset_stats,
 		.policy = tipc_nl_policy,
+	},
+	{
+		.cmd	= TIPC_NL_MEDIA_GET,
+		.doit	= tipc_nl_media_get,
+		.dumpit	= tipc_nl_media_dump,
+		.policy = tipc_nl_policy,
 	}
 };
 
-- 
1.7.10.4


------------------------------------------------------------------------------
Download BIRT iHub F-Type - The Free Enterprise-Grade BIRT Server
from Actuate! Instantly Supercharge Your Business Reports and Dashboards
with Interactivity, Sharing, Native Excel Exports, App Integration & more
Get technology previously reserved for billion-dollar corporations, FREE
http://pubads.g.doubleclick.net/gampad/clk?id=157005751&iu=/4140/ostg.clktrk
