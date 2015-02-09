From: <richard.alpe@ericsson.com>
Subject: [PATCH net-next v1 02/17] tipc: convert legacy nl
	bearer dump to nl compat
Date: Mon, 9 Feb 2015 09:50:04 +0100
Message-ID: <1423471819-23112-3-git-send-email-richard.alpe@ericsson.com>
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

Introduce a framework for dumping netlink data from the new netlink
API and formatting it to the old legacy API format. This is done by
looping the dump data and calling a format handler for each entity, in
this case a bearer.

We dump until either all data is dumped or we reach the limited buffer
size of the legacy API. Remember, the legacy API doesn't scale.

In this commit we convert TIPC_CMD_GET_BEARER_NAMES to use the compat
layer.

Signed-off-by: Richard Alpe <richard.alpe@ericsson.com>
Reviewed-by: Erik Hugne <erik.hugne@ericsson.com>
Reviewed-by: Ying Xue <ying.xue@windriver.com>
Reviewed-by: Jon Maloy <jon.maloy@ericsson.com>
---
 include/uapi/linux/tipc_config.h |   5 +
 net/tipc/bearer.c                |  29 -----
 net/tipc/bearer.h                |   1 -
 net/tipc/config.c                |   3 -
 net/tipc/netlink_compat.c        | 274 ++++++++++++++++++++++++++++++++++++++-
 5 files changed, 278 insertions(+), 34 deletions(-)

diff --git a/include/uapi/linux/tipc_config.h b/include/uapi/linux/tipc_config.h
index 876d0a1..e1f4f05 100644
--- a/include/uapi/linux/tipc_config.h
+++ b/include/uapi/linux/tipc_config.h
@@ -272,6 +272,11 @@ static inline int TLV_CHECK(const void *tlv, __u16 space, __u16 exp_type)
 		(ntohs(((struct tlv_desc *)tlv)->tlv_type) == exp_type);
 }
 
+static inline int TLV_GET_LEN(struct tlv_desc *tlv)
+{
+	return ntohs(tlv->tlv_len);
+}
+
 static inline int TLV_SET(void *tlv, __u16 type, void *data, __u16 len)
 {
 	struct tlv_desc *tlv_ptr;
diff --git a/net/tipc/bearer.c b/net/tipc/bearer.c
index 35d400e..7a9e296 100644
--- a/net/tipc/bearer.c
+++ b/net/tipc/bearer.c
@@ -205,35 +205,6 @@ struct tipc_bearer *tipc_bearer_find(struct net *net, const char *name)
 	return NULL;
 }
 
-/**
- * tipc_bearer_get_names - record names of bearers in buffer
- */
-struct sk_buff *tipc_bearer_get_names(struct net *net)
-{
-	struct tipc_net *tn = net_generic(net, tipc_net_id);
-	struct sk_buff *buf;
-	struct tipc_bearer *b;
-	int i, j;
-
-	buf = tipc_cfg_reply_alloc(MAX_BEARERS * TLV_SPACE(TIPC_MAX_BEARER_NAME));
-	if (!buf)
-		return NULL;
-
-	for (i = 0; media_info_array[i] != NULL; i++) {
-		for (j = 0; j < MAX_BEARERS; j++) {
-			b = rtnl_dereference(tn->bearer_list[j]);
-			if (!b)
-				continue;
-			if (b->media == media_info_array[i]) {
-				tipc_cfg_append_tlv(buf, TIPC_TLV_BEARER_NAME,
-						    b->name,
-						    strlen(b->name) + 1);
-			}
-		}
-	}
-	return buf;
-}
-
 void tipc_bearer_add_dest(struct net *net, u32 bearer_id, u32 dest)
 {
 	struct tipc_net *tn = net_generic(net, tipc_net_id);
diff --git a/net/tipc/bearer.h b/net/tipc/bearer.h
index c035e3e..9568582 100644
--- a/net/tipc/bearer.h
+++ b/net/tipc/bearer.h
@@ -205,7 +205,6 @@ void tipc_disable_l2_media(struct tipc_bearer *b);
 int tipc_l2_send_msg(struct net *net, struct sk_buff *buf,
 		     struct tipc_bearer *b, struct tipc_media_addr *dest);
 
-struct sk_buff *tipc_bearer_get_names(struct net *net);
 void tipc_bearer_add_dest(struct net *net, u32 bearer_id, u32 dest);
 void tipc_bearer_remove_dest(struct net *net, u32 bearer_id, u32 dest);
 struct tipc_bearer *tipc_bearer_find(struct net *net, const char *name);
diff --git a/net/tipc/config.c b/net/tipc/config.c
index 6873360..52e84b0 100644
--- a/net/tipc/config.c
+++ b/net/tipc/config.c
@@ -252,9 +252,6 @@ struct sk_buff *tipc_cfg_do_cmd(struct net *net, u32 orig_node, u16 cmd,
 		rep_tlv_buf = tipc_nametbl_get(net, req_tlv_area,
 					       req_tlv_space);
 		break;
-	case TIPC_CMD_GET_BEARER_NAMES:
-		rep_tlv_buf = tipc_bearer_get_names(net);
-		break;
 	case TIPC_CMD_GET_MEDIA_NAMES:
 		rep_tlv_buf = tipc_media_get_names();
 		break;
diff --git a/net/tipc/netlink_compat.c b/net/tipc/netlink_compat.c
index f752854..bd75ea2 100644
--- a/net/tipc/netlink_compat.c
+++ b/net/tipc/netlink_compat.c
@@ -33,9 +33,265 @@
 
 #include "core.h"
 #include "config.h"
+#include "bearer.h"
 #include <net/genetlink.h>
 #include <linux/tipc_config.h>
 
+/* The legacy API had an artificial message length limit called
+ * ULTRA_STRING_MAX_LEN.
+ */
+#define ULTRA_STRING_MAX_LEN 32768
+
+#define TIPC_SKB_MAX TLV_SPACE(ULTRA_STRING_MAX_LEN)
+
+#define REPLY_TRUNCATED "<truncated>\n"
+
+struct tipc_nl_compat_msg {
+	u16 cmd;
+	int rep_size;
+	struct sk_buff *rep;
+	struct tlv_desc *req;
+	struct sock *dst_sk;
+};
+
+struct tipc_nl_compat_cmd_dump {
+	int (*dumpit)(struct sk_buff *, struct netlink_callback *);
+	int (*format)(struct tipc_nl_compat_msg *msg, struct nlattr **attrs);
+};
+
+static int tipc_skb_tailroom(struct sk_buff *skb)
+{
+	int tailroom;
+	int limit;
+
+	tailroom = skb_tailroom(skb);
+	limit = TIPC_SKB_MAX - skb->len;
+
+	if (tailroom < limit)
+		return tailroom;
+
+	return limit;
+}
+
+static int tipc_add_tlv(struct sk_buff *skb, u16 type, void *data, u16 len)
+{
+	struct tlv_desc *tlv = (struct tlv_desc *)skb_tail_pointer(skb);
+
+	if (tipc_skb_tailroom(skb) < TLV_SPACE(len))
+		return -EMSGSIZE;
+
+	skb_put(skb, TLV_SPACE(len));
+	tlv->tlv_type = htons(type);
+	tlv->tlv_len = htons(TLV_LENGTH(len));
+	if (len && data)
+		memcpy(TLV_DATA(tlv), data, len);
+
+	return 0;
+}
+
+static struct sk_buff *tipc_tlv_alloc(int size)
+{
+	int hdr_len;
+	struct sk_buff *buf;
+
+	size = TLV_SPACE(size);
+	hdr_len = nlmsg_total_size(GENL_HDRLEN + TIPC_GENL_HDRLEN);
+
+	buf = alloc_skb(hdr_len + size, GFP_KERNEL);
+	if (!buf)
+		return NULL;
+
+	skb_reserve(buf, hdr_len);
+
+	return buf;
+}
+
+static struct sk_buff *tipc_get_err_tlv(char *str)
+{
+	int str_len = strlen(str) + 1;
+	struct sk_buff *buf;
+
+	buf = tipc_tlv_alloc(TLV_SPACE(str_len));
+	if (buf)
+		tipc_add_tlv(buf, TIPC_TLV_ERROR_STRING, str, str_len);
+
+	return buf;
+}
+
+static int __tipc_nl_compat_dumpit(struct tipc_nl_compat_cmd_dump *cmd,
+				   struct tipc_nl_compat_msg *msg,
+				   struct sk_buff *arg)
+{
+	int len = 0;
+	int err;
+	struct sk_buff *buf;
+	struct nlmsghdr *nlmsg;
+	struct netlink_callback cb;
+
+	memset(&cb, 0, sizeof(cb));
+	cb.nlh = (struct nlmsghdr *)arg->data;
+	cb.skb = arg;
+
+	buf = nlmsg_new(NLMSG_GOODSIZE, GFP_KERNEL);
+	if (!buf)
+		return -ENOMEM;
+
+	buf->sk = msg->dst_sk;
+
+	do {
+		int rem;
+
+		len = (*cmd->dumpit)(buf, &cb);
+
+		nlmsg_for_each_msg(nlmsg, nlmsg_hdr(buf), len, rem) {
+			struct nlattr **attrs;
+
+			err = tipc_nlmsg_parse(nlmsg, &attrs);
+			if (err)
+				goto err_out;
+
+			err = (*cmd->format)(msg, attrs);
+			if (err)
+				goto err_out;
+
+			if (tipc_skb_tailroom(msg->rep) <= 1) {
+				err = -EMSGSIZE;
+				goto err_out;
+			}
+		}
+
+		skb_reset_tail_pointer(buf);
+		buf->len = 0;
+
+	} while (len);
+
+	err = 0;
+
+err_out:
+	kfree_skb(buf);
+
+	if (err == -EMSGSIZE) {
+		/* The legacy API only considered messages filling
+		 * "ULTRA_STRING_MAX_LEN" to be truncated.
+		 */
+		if ((TIPC_SKB_MAX - msg->rep->len) <= 1) {
+			char *tail = skb_tail_pointer(msg->rep);
+
+			if (*tail != '\0')
+				sprintf(tail - sizeof(REPLY_TRUNCATED) - 1,
+					REPLY_TRUNCATED);
+		}
+
+		return 0;
+	}
+
+	return err;
+}
+
+static int tipc_nl_compat_dumpit(struct tipc_nl_compat_cmd_dump *cmd,
+				 struct tipc_nl_compat_msg *msg)
+{
+	int err;
+	struct sk_buff *arg;
+
+	msg->rep = tipc_tlv_alloc(msg->rep_size);
+	if (!msg->rep)
+		return -ENOMEM;
+
+	arg = nlmsg_new(0, GFP_KERNEL);
+	if (!arg) {
+		kfree_skb(msg->rep);
+		return -ENOMEM;
+	}
+
+	err = __tipc_nl_compat_dumpit(cmd, msg, arg);
+	if (err)
+		kfree_skb(msg->rep);
+
+	kfree_skb(arg);
+
+	return err;
+}
+
+static int tipc_nl_compat_bearer_dump(struct tipc_nl_compat_msg *msg,
+				      struct nlattr **attrs)
+{
+	struct nlattr *bearer[TIPC_NLA_BEARER_MAX + 1];
+
+	nla_parse_nested(bearer, TIPC_NLA_BEARER_MAX, attrs[TIPC_NLA_BEARER],
+			 NULL);
+
+	return tipc_add_tlv(msg->rep, TIPC_TLV_BEARER_NAME,
+			    nla_data(bearer[TIPC_NLA_BEARER_NAME]),
+			    nla_len(bearer[TIPC_NLA_BEARER_NAME]));
+}
+
+static int tipc_nl_compat_handle(struct tipc_nl_compat_msg *msg)
+{
+	struct tipc_nl_compat_cmd_dump dump;
+
+	memset(&dump, 0, sizeof(dump));
+
+	switch (msg->cmd) {
+	case TIPC_CMD_GET_BEARER_NAMES:
+		msg->rep_size = MAX_BEARERS * TLV_SPACE(TIPC_MAX_BEARER_NAME);
+		dump.dumpit = tipc_nl_bearer_dump;
+		dump.format = tipc_nl_compat_bearer_dump;
+		return tipc_nl_compat_dumpit(&dump, msg);
+	}
+
+	return -EOPNOTSUPP;
+}
+
+static int tipc_nl_compat_recv(struct sk_buff *skb, struct genl_info *info)
+{
+	int err;
+	int len;
+	struct tipc_nl_compat_msg msg;
+	struct nlmsghdr *req_nlh;
+	struct nlmsghdr *rep_nlh;
+	struct tipc_genlmsghdr *req_userhdr = info->userhdr;
+	struct net *net = genl_info_net(info);
+
+	memset(&msg, 0, sizeof(msg));
+
+	req_nlh = (struct nlmsghdr *)skb->data;
+	msg.req = nlmsg_data(req_nlh) + GENL_HDRLEN + TIPC_GENL_HDRLEN;
+	msg.cmd = req_userhdr->cmd;
+	msg.dst_sk = info->dst_sk;
+
+	if ((msg.cmd & 0xC000) && (!netlink_net_capable(skb, CAP_NET_ADMIN))) {
+		msg.rep = tipc_get_err_tlv(TIPC_CFG_NOT_NET_ADMIN);
+		err = -EACCES;
+		goto send;
+	}
+
+	len = nlmsg_attrlen(req_nlh, GENL_HDRLEN + TIPC_GENL_HDRLEN);
+	if (TLV_GET_LEN(msg.req) && !TLV_OK(msg.req, len)) {
+		msg.rep = tipc_get_err_tlv(TIPC_CFG_NOT_SUPPORTED);
+		err = -EOPNOTSUPP;
+		goto send;
+	}
+
+	err = tipc_nl_compat_handle(&msg);
+	if (err == -EOPNOTSUPP)
+		msg.rep = tipc_get_err_tlv(TIPC_CFG_NOT_SUPPORTED);
+	else if (err == -EINVAL)
+		msg.rep = tipc_get_err_tlv(TIPC_CFG_TLV_ERROR);
+send:
+	if (!msg.rep)
+		return err;
+
+	len = nlmsg_total_size(GENL_HDRLEN + TIPC_GENL_HDRLEN);
+	skb_push(msg.rep, len);
+	rep_nlh = nlmsg_hdr(msg.rep);
+	memcpy(rep_nlh, info->nlhdr, len);
+	rep_nlh->nlmsg_len = msg.rep->len;
+	genlmsg_unicast(net, msg.rep, NETLINK_CB(skb).portid);
+
+	return err;
+}
+
 static int handle_cmd(struct sk_buff *skb, struct genl_info *info)
 {
 	struct net *net = genl_info_net(info);
@@ -69,6 +325,22 @@ static int handle_cmd(struct sk_buff *skb, struct genl_info *info)
 	return 0;
 }
 
+/* Temporary function to keep functionality throughout the patchset
+ * without having to mess with the global variables and other trickery
+ * of the old API.
+ */
+static int tipc_nl_compat_tmp_wrap(struct sk_buff *skb, struct genl_info *info)
+{
+	struct tipc_genlmsghdr *req = info->userhdr;
+
+	switch (req->cmd) {
+	case TIPC_CMD_GET_BEARER_NAMES:
+		return tipc_nl_compat_recv(skb, info);
+	}
+
+	return handle_cmd(skb, info);
+}
+
 static struct genl_family tipc_genl_compat_family = {
 	.id		= GENL_ID_GENERATE,
 	.name		= TIPC_GENL_NAME,
@@ -81,7 +353,7 @@ static struct genl_family tipc_genl_compat_family = {
 static struct genl_ops tipc_genl_compat_ops[] = {
 	{
 		.cmd		= TIPC_GENL_CMD,
-		.doit		= handle_cmd,
+		.doit		= tipc_nl_compat_tmp_wrap,
 	},
 };
 
-- 
2.1.4


------------------------------------------------------------------------------
Dive into the World of Parallel Programming. The Go Parallel Website,
sponsored by Intel and developed in partnership with Slashdot Media, is your
hub for all things parallel software development, from weekly thought
leadership blogs to news, videos, case studies, tutorials and more. Take a
look and join the conversation now. http://goparallel.sourceforge.net/
