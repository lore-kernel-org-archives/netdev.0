From: <richard.alpe@ericsson.com>
Subject: [PATCH net-next v1 03/17] tipc: convert legacy nl
	bearer enable/disable to nl compat
Date: Mon, 9 Feb 2015 09:50:05 +0100
Message-ID: <1423471819-23112-4-git-send-email-richard.alpe@ericsson.com>
References: <1423471819-23112-1-git-send-email-richard.alpe@ericsson.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
Cc: tipc-discussion@lists.sourceforge.net
To: <netdev@vger.kernel.org>
Return-path: <tipc-discussion-bounces@lists.sourceforge.net>
In-Reply-To: <1423471819-23112-1-git-send-email-richard.alpe@ericsson.com>
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

Introduce a framework for transcoding legacy nl action into actions
(.doit) calls from the new nl API. This is done by converting the
incoming TLV data into netlink data with nested netlink attributes.
Unfortunately due to the randomness of the legacy API we can't do this
generically so each legacy netlink command requires a specific
transcoding recipe. In this case for bearer enable and bearer disable.

Convert TIPC_CMD_ENABLE_BEARER and TIPC_CMD_DISABLE_BEARER into doit
compat calls.

Signed-off-by: Richard Alpe <richard.alpe@ericsson.com>
Reviewed-by: Erik Hugne <erik.hugne@ericsson.com>
Reviewed-by: Ying Xue <ying.xue@windriver.com>
Reviewed-by: Jon Maloy <jon.maloy@ericsson.com>
---
 include/uapi/linux/tipc_config.h |   5 ++
 net/tipc/bearer.c                |  26 ++-----
 net/tipc/bearer.h                |   3 -
 net/tipc/config.c                |  33 ---------
 net/tipc/netlink_compat.c        | 144 +++++++++++++++++++++++++++++++++++++++
 5 files changed, 154 insertions(+), 57 deletions(-)

diff --git a/include/uapi/linux/tipc_config.h b/include/uapi/linux/tipc_config.h
index e1f4f05..f922656 100644
--- a/include/uapi/linux/tipc_config.h
+++ b/include/uapi/linux/tipc_config.h
@@ -277,6 +277,11 @@ static inline int TLV_GET_LEN(struct tlv_desc *tlv)
 	return ntohs(tlv->tlv_len);
 }
 
+static inline int TLV_CHECK_TYPE(struct tlv_desc *tlv,  __u16 type)
+{
+	return (ntohs(tlv->tlv_type) == type);
+}
+
 static inline int TLV_SET(void *tlv, __u16 type, void *data, __u16 len)
 {
 	struct tlv_desc *tlv_ptr;
diff --git a/net/tipc/bearer.c b/net/tipc/bearer.c
index 7a9e296..de1c800 100644
--- a/net/tipc/bearer.c
+++ b/net/tipc/bearer.c
@@ -236,8 +236,8 @@ void tipc_bearer_remove_dest(struct net *net, u32 bearer_id, u32 dest)
 /**
  * tipc_enable_bearer - enable bearer with the given name
  */
-int tipc_enable_bearer(struct net *net, const char *name, u32 disc_domain,
-		       u32 priority)
+static int tipc_enable_bearer(struct net *net, const char *name,
+			      u32 disc_domain, u32 priority)
 {
 	struct tipc_net *tn = net_generic(net, tipc_net_id);
 	struct tipc_bearer *b_ptr;
@@ -393,22 +393,6 @@ static void bearer_disable(struct net *net, struct tipc_bearer *b_ptr,
 	kfree_rcu(b_ptr, rcu);
 }
 
-int tipc_disable_bearer(struct net *net, const char *name)
-{
-	struct tipc_bearer *b_ptr;
-	int res;
-
-	b_ptr = tipc_bearer_find(net, name);
-	if (b_ptr == NULL) {
-		pr_warn("Attempt to disable unknown bearer <%s>\n", name);
-		res = -EINVAL;
-	} else {
-		bearer_disable(net, b_ptr, false);
-		res = 0;
-	}
-	return res;
-}
-
 int tipc_enable_l2_media(struct net *net, struct tipc_bearer *b)
 {
 	struct net_device *dev;
@@ -756,7 +740,7 @@ int tipc_nl_bearer_disable(struct sk_buff *skb, struct genl_info *info)
 	char *name;
 	struct tipc_bearer *bearer;
 	struct nlattr *attrs[TIPC_NLA_BEARER_MAX + 1];
-	struct net *net = genl_info_net(info);
+	struct net *net = sock_net(skb->sk);
 
 	if (!info->attrs[TIPC_NLA_BEARER])
 		return -EINVAL;
@@ -787,11 +771,11 @@ int tipc_nl_bearer_disable(struct sk_buff *skb, struct genl_info *info)
 
 int tipc_nl_bearer_enable(struct sk_buff *skb, struct genl_info *info)
 {
-	struct net *net = genl_info_net(info);
-	struct tipc_net *tn = net_generic(net, tipc_net_id);
 	int err;
 	char *bearer;
 	struct nlattr *attrs[TIPC_NLA_BEARER_MAX + 1];
+	struct net *net = sock_net(skb->sk);
+	struct tipc_net *tn = net_generic(net, tipc_net_id);
 	u32 domain;
 	u32 prio;
 
diff --git a/net/tipc/bearer.h b/net/tipc/bearer.h
index 9568582..06f25d1 100644
--- a/net/tipc/bearer.h
+++ b/net/tipc/bearer.h
@@ -173,9 +173,6 @@ struct tipc_bearer_names {
  */
 
 void tipc_rcv(struct net *net, struct sk_buff *skb, struct tipc_bearer *b_ptr);
-int tipc_enable_bearer(struct net *net, const char *bearer_name,
-		       u32 disc_domain, u32 priority);
-int tipc_disable_bearer(struct net *net, const char *name);
 
 /*
  * Routines made available to TIPC by supported media types
diff --git a/net/tipc/config.c b/net/tipc/config.c
index 52e84b0..f8cd5e1 100644
--- a/net/tipc/config.c
+++ b/net/tipc/config.c
@@ -134,33 +134,6 @@ static struct sk_buff *tipc_show_stats(void)
 	return buf;
 }
 
-static struct sk_buff *cfg_enable_bearer(struct net *net)
-{
-	struct tipc_bearer_config *args;
-
-	if (!TLV_CHECK(req_tlv_area, req_tlv_space, TIPC_TLV_BEARER_CONFIG))
-		return tipc_cfg_reply_error_string(TIPC_CFG_TLV_ERROR);
-
-	args = (struct tipc_bearer_config *)TLV_DATA(req_tlv_area);
-	if (tipc_enable_bearer(net, args->name,
-			       ntohl(args->disc_domain),
-			       ntohl(args->priority)))
-		return tipc_cfg_reply_error_string("unable to enable bearer");
-
-	return tipc_cfg_reply_none();
-}
-
-static struct sk_buff *cfg_disable_bearer(struct net *net)
-{
-	if (!TLV_CHECK(req_tlv_area, req_tlv_space, TIPC_TLV_BEARER_NAME))
-		return tipc_cfg_reply_error_string(TIPC_CFG_TLV_ERROR);
-
-	if (tipc_disable_bearer(net, (char *)TLV_DATA(req_tlv_area)))
-		return tipc_cfg_reply_error_string("unable to disable bearer");
-
-	return tipc_cfg_reply_none();
-}
-
 static struct sk_buff *cfg_set_own_addr(struct net *net)
 {
 	struct tipc_net *tn = net_generic(net, tipc_net_id);
@@ -267,12 +240,6 @@ struct sk_buff *tipc_cfg_do_cmd(struct net *net, u32 orig_node, u16 cmd,
 		rep_tlv_buf = tipc_link_cmd_config(net, req_tlv_area,
 						   req_tlv_space, cmd);
 		break;
-	case TIPC_CMD_ENABLE_BEARER:
-		rep_tlv_buf = cfg_enable_bearer(net);
-		break;
-	case TIPC_CMD_DISABLE_BEARER:
-		rep_tlv_buf = cfg_disable_bearer(net);
-		break;
 	case TIPC_CMD_SET_NODE_ADDR:
 		rep_tlv_buf = cfg_set_own_addr(net);
 		break;
diff --git a/net/tipc/netlink_compat.c b/net/tipc/netlink_compat.c
index bd75ea2..12b0f44 100644
--- a/net/tipc/netlink_compat.c
+++ b/net/tipc/netlink_compat.c
@@ -49,6 +49,7 @@
 struct tipc_nl_compat_msg {
 	u16 cmd;
 	int rep_size;
+	int req_type;
 	struct sk_buff *rep;
 	struct tlv_desc *req;
 	struct sock *dst_sk;
@@ -59,6 +60,11 @@ struct tipc_nl_compat_cmd_dump {
 	int (*format)(struct tipc_nl_compat_msg *msg, struct nlattr **attrs);
 };
 
+struct tipc_nl_compat_cmd_doit {
+	int (*doit)(struct sk_buff *skb, struct genl_info *info);
+	int (*transcode)(struct sk_buff *skb, struct tipc_nl_compat_msg *msg);
+};
+
 static int tipc_skb_tailroom(struct sk_buff *skb)
 {
 	int tailroom;
@@ -213,6 +219,78 @@ static int tipc_nl_compat_dumpit(struct tipc_nl_compat_cmd_dump *cmd,
 	return err;
 }
 
+static int __tipc_nl_compat_doit(struct tipc_nl_compat_cmd_doit *cmd,
+				 struct tipc_nl_compat_msg *msg)
+{
+	int err;
+	struct sk_buff *doit_buf;
+	struct sk_buff *trans_buf;
+	struct nlattr **attrbuf;
+	struct genl_info info;
+
+	trans_buf = alloc_skb(NLMSG_GOODSIZE, GFP_KERNEL);
+	if (!trans_buf)
+		return -ENOMEM;
+
+	err = (*cmd->transcode)(trans_buf, msg);
+	if (err)
+		goto trans_out;
+
+	attrbuf = kmalloc((tipc_genl_family.maxattr + 1) *
+			sizeof(struct nlattr *), GFP_KERNEL);
+	if (!attrbuf) {
+		err = -ENOMEM;
+		goto trans_out;
+	}
+
+	err = nla_parse(attrbuf, tipc_genl_family.maxattr,
+			(const struct nlattr *)trans_buf->data,
+			trans_buf->len, NULL);
+	if (err)
+		goto parse_out;
+
+	doit_buf = alloc_skb(NLMSG_GOODSIZE, GFP_KERNEL);
+	if (!doit_buf) {
+		err = -ENOMEM;
+		goto parse_out;
+	}
+
+	doit_buf->sk = msg->dst_sk;
+
+	memset(&info, 0, sizeof(info));
+	info.attrs = attrbuf;
+
+	err = (*cmd->doit)(doit_buf, &info);
+
+	kfree_skb(doit_buf);
+parse_out:
+	kfree(attrbuf);
+trans_out:
+	kfree_skb(trans_buf);
+
+	return err;
+}
+
+static int tipc_nl_compat_doit(struct tipc_nl_compat_cmd_doit *cmd,
+			       struct tipc_nl_compat_msg *msg)
+{
+	int err;
+
+	if (msg->req_type && !TLV_CHECK_TYPE(msg->req, msg->req_type))
+		return -EINVAL;
+
+	err = __tipc_nl_compat_doit(cmd, msg);
+	if (err)
+		return err;
+
+	/* The legacy API considered an empty message a success message */
+	msg->rep = tipc_tlv_alloc(0);
+	if (!msg->rep)
+		return -ENOMEM;
+
+	return 0;
+}
+
 static int tipc_nl_compat_bearer_dump(struct tipc_nl_compat_msg *msg,
 				      struct nlattr **attrs)
 {
@@ -226,11 +304,65 @@ static int tipc_nl_compat_bearer_dump(struct tipc_nl_compat_msg *msg,
 			    nla_len(bearer[TIPC_NLA_BEARER_NAME]));
 }
 
+static int tipc_nl_compat_bearer_enable(struct sk_buff *skb,
+					struct tipc_nl_compat_msg *msg)
+{
+	struct nlattr *prop;
+	struct nlattr *bearer;
+	struct tipc_bearer_config *b;
+
+	b = (struct tipc_bearer_config *)TLV_DATA(msg->req);
+
+	bearer = nla_nest_start(skb, TIPC_NLA_BEARER);
+	if (!bearer)
+		return -EMSGSIZE;
+
+	if (nla_put_string(skb, TIPC_NLA_BEARER_NAME, b->name))
+		return -EMSGSIZE;
+
+	if (nla_put_u32(skb, TIPC_NLA_BEARER_DOMAIN, ntohl(b->disc_domain)))
+		return -EMSGSIZE;
+
+	if (ntohl(b->priority) <= TIPC_MAX_LINK_PRI) {
+		prop = nla_nest_start(skb, TIPC_NLA_BEARER_PROP);
+		if (!prop)
+			return -EMSGSIZE;
+		if (nla_put_u32(skb, TIPC_NLA_PROP_PRIO, ntohl(b->priority)))
+			return -EMSGSIZE;
+		nla_nest_end(skb, prop);
+	}
+	nla_nest_end(skb, bearer);
+
+	return 0;
+}
+
+static int tipc_nl_compat_bearer_disable(struct sk_buff *skb,
+					 struct tipc_nl_compat_msg *msg)
+{
+	char *name;
+	struct nlattr *bearer;
+
+	name = (char *)TLV_DATA(msg->req);
+
+	bearer = nla_nest_start(skb, TIPC_NLA_BEARER);
+	if (!bearer)
+		return -EMSGSIZE;
+
+	if (nla_put_string(skb, TIPC_NLA_BEARER_NAME, name))
+		return -EMSGSIZE;
+
+	nla_nest_end(skb, bearer);
+
+	return 0;
+}
+
 static int tipc_nl_compat_handle(struct tipc_nl_compat_msg *msg)
 {
 	struct tipc_nl_compat_cmd_dump dump;
+	struct tipc_nl_compat_cmd_doit doit;
 
 	memset(&dump, 0, sizeof(dump));
+	memset(&doit, 0, sizeof(doit));
 
 	switch (msg->cmd) {
 	case TIPC_CMD_GET_BEARER_NAMES:
@@ -238,6 +370,16 @@ static int tipc_nl_compat_handle(struct tipc_nl_compat_msg *msg)
 		dump.dumpit = tipc_nl_bearer_dump;
 		dump.format = tipc_nl_compat_bearer_dump;
 		return tipc_nl_compat_dumpit(&dump, msg);
+	case TIPC_CMD_ENABLE_BEARER:
+		msg->req_type = TIPC_TLV_BEARER_CONFIG;
+		doit.doit = tipc_nl_bearer_enable;
+		doit.transcode = tipc_nl_compat_bearer_enable;
+		return tipc_nl_compat_doit(&doit, msg);
+	case TIPC_CMD_DISABLE_BEARER:
+		msg->req_type = TIPC_TLV_BEARER_NAME;
+		doit.doit = tipc_nl_bearer_disable;
+		doit.transcode = tipc_nl_compat_bearer_disable;
+		return tipc_nl_compat_doit(&doit, msg);
 	}
 
 	return -EOPNOTSUPP;
@@ -335,6 +477,8 @@ static int tipc_nl_compat_tmp_wrap(struct sk_buff *skb, struct genl_info *info)
 
 	switch (req->cmd) {
 	case TIPC_CMD_GET_BEARER_NAMES:
+	case TIPC_CMD_ENABLE_BEARER:
+	case TIPC_CMD_DISABLE_BEARER:
 		return tipc_nl_compat_recv(skb, info);
 	}
 
-- 
2.1.4


------------------------------------------------------------------------------
Dive into the World of Parallel Programming. The Go Parallel Website,
sponsored by Intel and developed in partnership with Slashdot Media, is your
hub for all things parallel software development, from weekly thought
leadership blogs to news, videos, case studies, tutorials and more. Take a
look and join the conversation now. http://goparallel.sourceforge.net/
