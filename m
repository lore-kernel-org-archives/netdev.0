From: <richard.alpe@ericsson.com>
Subject: [PATCH net-next 02/14] tipc: add bearer get/dump
	to new netlink api
Date: Thu, 11 Sep 2014 10:29:15 +0200
Message-ID: <1410424167-17427-3-git-send-email-richard.alpe@ericsson.com>
References: <1410424167-17427-1-git-send-email-richard.alpe@ericsson.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
Cc: tipc-discussion@lists.sourceforge.net
To: <netdev@vger.kernel.org>
Return-path: <tipc-discussion-bounces@lists.sourceforge.net>
In-Reply-To: <1410424167-17427-1-git-send-email-richard.alpe@ericsson.com>
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

Add TIPC_NL_BEARER_GET command to the new tipc netlink API.

This command supports dumping all data about all bearers or getting
all information about a specific bearer.

The information about a bearer includes name, link priorities and
domain.

Netlink logical layout of bearer get message:
-> bearer
    -> name

Netlink logical layout of returned bearer information:
-> bearer
    -> name
    -> link properties
        -> priority
        -> tolerance
        -> window
    -> domain

Signed-off-by: Richard Alpe <richard.alpe@ericsson.com>
Reviewed-by: Erik Hugne <erik.hugne@ericsson.com>
Reviewed-by: Jon Maloy <jon.maloy@ericsson.com>
Acked-by: Ying Xue <ying.xue@windriver.com>
---
 include/uapi/linux/tipc_config.h |    1 +
 net/tipc/bearer.c                |  125 ++++++++++++++++++++++++++++++++++++++
 net/tipc/bearer.h                |    2 +
 net/tipc/netlink.c               |    6 ++
 4 files changed, 134 insertions(+)

diff --git a/include/uapi/linux/tipc_config.h b/include/uapi/linux/tipc_config.h
index 954ecaa..6caf581 100644
--- a/include/uapi/linux/tipc_config.h
+++ b/include/uapi/linux/tipc_config.h
@@ -52,6 +52,7 @@ enum {
 	TIPC_NL_LEGACY,
 	TIPC_NL_BEARER_DISABLE,
 	TIPC_NL_BEARER_ENABLE,
+	TIPC_NL_BEARER_GET,
 
 	__TIPC_NL_CMD_MAX,
 	TIPC_NL_CMD_MAX = __TIPC_NL_CMD_MAX - 1
diff --git a/net/tipc/bearer.c b/net/tipc/bearer.c
index 59815be..7f77cec 100644
--- a/net/tipc/bearer.c
+++ b/net/tipc/bearer.c
@@ -640,6 +640,131 @@ void tipc_bearer_stop(void)
 	}
 }
 
+/* Caller should hold rtnl_lock to protect the bearer */
+int __tipc_nl_add_bearer(struct tipc_nl_msg *msg, struct tipc_bearer *bearer)
+{
+	void *hdr;
+	struct nlattr *attrs;
+	struct nlattr *prop;
+
+	hdr = genlmsg_put(msg->skb, msg->portid, msg->seq, &tipc_genl_family,
+			  NLM_F_MULTI, TIPC_NL_BEARER_GET);
+	if (!hdr)
+		return -EMSGSIZE;
+
+	attrs = nla_nest_start(msg->skb, TIPC_NLA_BEARER);
+	if (!attrs)
+		goto msg_full;
+
+	if (nla_put_string(msg->skb, TIPC_NLA_BEARER_NAME, bearer->name))
+		goto attr_msg_full;
+
+	prop = nla_nest_start(msg->skb, TIPC_NLA_BEARER_PROP);
+	if (!prop)
+		goto prop_msg_full;
+	if (nla_put_u32(msg->skb, TIPC_NLA_PROP_PRIO, bearer->priority))
+		goto prop_msg_full;
+	if (nla_put_u32(msg->skb, TIPC_NLA_PROP_TOL, bearer->tolerance))
+		goto prop_msg_full;
+	if (nla_put_u32(msg->skb, TIPC_NLA_PROP_WIN, bearer->window))
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
+int tipc_nl_bearer_dump(struct sk_buff *skb, struct netlink_callback *cb)
+{
+	int err;
+	int i = cb->args[0];
+	struct tipc_bearer *bearer;
+	struct tipc_nl_msg msg;
+
+	if (i == MAX_BEARERS)
+		return 0;
+
+	msg.skb = skb;
+	msg.portid = NETLINK_CB(cb->skb).portid;
+	msg.seq = cb->nlh->nlmsg_seq;
+
+	rtnl_lock();
+	for (i = 0; i < MAX_BEARERS; i++) {
+		bearer = rtnl_dereference(bearer_list[i]);
+		if (!bearer)
+			continue;
+
+		err = __tipc_nl_add_bearer(&msg, bearer);
+		if (err)
+			break;
+	}
+	rtnl_unlock();
+
+	cb->args[0] = i;
+	return skb->len;
+}
+
+int tipc_nl_bearer_get(struct sk_buff *skb, struct genl_info *info)
+{
+	int err;
+	char *name;
+	struct sk_buff *rep;
+	struct tipc_bearer *bearer;
+	struct tipc_nl_msg msg;
+	struct nlattr *attrs[TIPC_NLA_BEARER_MAX + 1];
+
+	if (!info->attrs[TIPC_NLA_BEARER])
+		return -EINVAL;
+
+	err = nla_parse_nested(attrs, TIPC_NLA_BEARER_MAX,
+			       info->attrs[TIPC_NLA_BEARER],
+			       tipc_nl_bearer_policy);
+	if (err)
+		return err;
+
+	if (!attrs[TIPC_NLA_BEARER_NAME])
+		return -EINVAL;
+	name = nla_data(attrs[TIPC_NLA_BEARER_NAME]);
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
+	bearer = tipc_bearer_find(name);
+	if (!bearer) {
+		err = -EINVAL;
+		goto err_out;
+	}
+
+	err = __tipc_nl_add_bearer(&msg, bearer);
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
+
 int tipc_nl_bearer_disable(struct sk_buff *skb, struct genl_info *info)
 {
 	int err;
diff --git a/net/tipc/bearer.h b/net/tipc/bearer.h
index a87e8c7..2d07e35 100644
--- a/net/tipc/bearer.h
+++ b/net/tipc/bearer.h
@@ -180,6 +180,8 @@ extern struct tipc_media ib_media_info;
 
 int tipc_nl_bearer_disable(struct sk_buff *skb, struct genl_info *info);
 int tipc_nl_bearer_enable(struct sk_buff *skb, struct genl_info *info);
+int tipc_nl_bearer_dump(struct sk_buff *skb, struct netlink_callback *cb);
+int tipc_nl_bearer_get(struct sk_buff *skb, struct genl_info *info);
 
 int tipc_media_set_priority(const char *name, u32 new_value);
 int tipc_media_set_window(const char *name, u32 new_value);
diff --git a/net/tipc/netlink.c b/net/tipc/netlink.c
index 7c0cf46..ef106a7 100644
--- a/net/tipc/netlink.c
+++ b/net/tipc/netlink.c
@@ -97,6 +97,12 @@ static const struct genl_ops tipc_genl_ops[] = {
 		.cmd	= TIPC_NL_BEARER_ENABLE,
 		.doit	= tipc_nl_bearer_enable,
 		.policy = tipc_nl_policy,
+	},
+	{
+		.cmd	= TIPC_NL_BEARER_GET,
+		.doit	= tipc_nl_bearer_get,
+		.dumpit	= tipc_nl_bearer_dump,
+		.policy = tipc_nl_policy,
 	}
 };
 
-- 
1.7.10.4


------------------------------------------------------------------------------
Want excitement?
Manually upgrade your production database.
When you want reliability, choose Perforce
Perforce version control. Predictably reliable.
http://pubads.g.doubleclick.net/gampad/clk?id=157508191&iu=/4140/ostg.clktrk
