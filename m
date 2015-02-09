From: <richard.alpe@ericsson.com>
Subject: [PATCH net-next v1 10/17] tipc: convert legacy nl
	media dump to nl compat
Date: Mon, 9 Feb 2015 09:50:12 +0100
Message-ID: <1423471819-23112-11-git-send-email-richard.alpe@ericsson.com>
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

Convert TIPC_CMD_GET_MEDIA_NAMES to compat dumpit.

Signed-off-by: Richard Alpe <richard.alpe@ericsson.com>
Reviewed-by: Erik Hugne <erik.hugne@ericsson.com>
Reviewed-by: Ying Xue <ying.xue@windriver.com>
Reviewed-by: Jon Maloy <jon.maloy@ericsson.com>
---
 net/tipc/bearer.c         | 20 --------------------
 net/tipc/bearer.h         |  1 -
 net/tipc/config.c         |  3 ---
 net/tipc/netlink_compat.c | 19 +++++++++++++++++++
 4 files changed, 19 insertions(+), 24 deletions(-)

diff --git a/net/tipc/bearer.c b/net/tipc/bearer.c
index de1c800..c7e3b5d 100644
--- a/net/tipc/bearer.c
+++ b/net/tipc/bearer.c
@@ -124,26 +124,6 @@ void tipc_media_addr_printf(char *buf, int len, struct tipc_media_addr *a)
 }
 
 /**
- * tipc_media_get_names - record names of registered media in buffer
- */
-struct sk_buff *tipc_media_get_names(void)
-{
-	struct sk_buff *buf;
-	int i;
-
-	buf = tipc_cfg_reply_alloc(MAX_MEDIA * TLV_SPACE(TIPC_MAX_MEDIA_NAME));
-	if (!buf)
-		return NULL;
-
-	for (i = 0; media_info_array[i] != NULL; i++) {
-		tipc_cfg_append_tlv(buf, TIPC_TLV_MEDIA_NAME,
-				    media_info_array[i]->name,
-				    strlen(media_info_array[i]->name) + 1);
-	}
-	return buf;
-}
-
-/**
  * bearer_name_validate - validate & (optionally) deconstruct bearer name
  * @name: ptr to bearer name string
  * @name_parts: ptr to area for bearer name components (or NULL if not needed)
diff --git a/net/tipc/bearer.h b/net/tipc/bearer.h
index 06f25d1..6b17795 100644
--- a/net/tipc/bearer.h
+++ b/net/tipc/bearer.h
@@ -196,7 +196,6 @@ int tipc_nl_media_set(struct sk_buff *skb, struct genl_info *info);
 int tipc_media_set_priority(const char *name, u32 new_value);
 int tipc_media_set_window(const char *name, u32 new_value);
 void tipc_media_addr_printf(char *buf, int len, struct tipc_media_addr *a);
-struct sk_buff *tipc_media_get_names(void);
 int tipc_enable_l2_media(struct net *net, struct tipc_bearer *b);
 void tipc_disable_l2_media(struct tipc_bearer *b);
 int tipc_l2_send_msg(struct net *net, struct sk_buff *buf,
diff --git a/net/tipc/config.c b/net/tipc/config.c
index 6e4c215..df41082 100644
--- a/net/tipc/config.c
+++ b/net/tipc/config.c
@@ -209,9 +209,6 @@ struct sk_buff *tipc_cfg_do_cmd(struct net *net, u32 orig_node, u16 cmd,
 		rep_tlv_buf = tipc_node_get_nodes(net, req_tlv_area,
 						  req_tlv_space);
 		break;
-	case TIPC_CMD_GET_MEDIA_NAMES:
-		rep_tlv_buf = tipc_media_get_names();
-		break;
 	case TIPC_CMD_SHOW_STATS:
 		rep_tlv_buf = tipc_show_stats();
 		break;
diff --git a/net/tipc/netlink_compat.c b/net/tipc/netlink_compat.c
index 48e15a4..d23075e 100644
--- a/net/tipc/netlink_compat.c
+++ b/net/tipc/netlink_compat.c
@@ -822,6 +822,19 @@ static int tipc_nl_compat_sk_dump(struct tipc_nl_compat_msg *msg,
 	return 0;
 }
 
+static int tipc_nl_compat_media_dump(struct tipc_nl_compat_msg *msg,
+				     struct nlattr **attrs)
+{
+	struct nlattr *media[TIPC_NLA_MEDIA_MAX + 1];
+
+	nla_parse_nested(media, TIPC_NLA_MEDIA_MAX, attrs[TIPC_NLA_MEDIA],
+			 NULL);
+
+	return tipc_add_tlv(msg->rep, TIPC_TLV_MEDIA_NAME,
+			    nla_data(media[TIPC_NLA_MEDIA_NAME]),
+			    nla_len(media[TIPC_NLA_MEDIA_NAME]));
+}
+
 static int tipc_nl_compat_handle(struct tipc_nl_compat_msg *msg)
 {
 	struct tipc_nl_compat_cmd_dump dump;
@@ -885,6 +898,11 @@ static int tipc_nl_compat_handle(struct tipc_nl_compat_msg *msg)
 		dump.dumpit = tipc_nl_sk_dump;
 		dump.format = tipc_nl_compat_sk_dump;
 		return tipc_nl_compat_dumpit(&dump, msg);
+	case TIPC_CMD_GET_MEDIA_NAMES:
+		msg->rep_size = MAX_MEDIA * TLV_SPACE(TIPC_MAX_MEDIA_NAME);
+		dump.dumpit = tipc_nl_media_dump;
+		dump.format = tipc_nl_compat_media_dump;
+		return tipc_nl_compat_dumpit(&dump, msg);
 	}
 
 	return -EOPNOTSUPP;
@@ -992,6 +1010,7 @@ static int tipc_nl_compat_tmp_wrap(struct sk_buff *skb, struct genl_info *info)
 	case TIPC_CMD_RESET_LINK_STATS:
 	case TIPC_CMD_SHOW_NAME_TABLE:
 	case TIPC_CMD_SHOW_PORTS:
+	case TIPC_CMD_GET_MEDIA_NAMES:
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
