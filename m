From: Jiri Pirko <jpirko@redhat.com>
Subject: [patch net-next 3/4] team: add binary option type
Date: Sat, 31 Mar 2012 23:01:21 +0200
Message-ID: <1333227682-10235-4-git-send-email-jpirko@redhat.com>
References: <1333227682-10235-1-git-send-email-jpirko@redhat.com>
Cc: davem@davemloft.net, eric.dumazet@gmail.com,
	bhutchings@solarflare.com, shemminger@vyatta.com,
	raise.sail@gmail.com, nuno.martins@caixamagica.pt, matt@ozlabs.org
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mx1.redhat.com ([209.132.183.28]:51443 "EHLO mx1.redhat.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1752933Ab2CaVBi (ORCPT <rfc822;netdev@vger.kernel.org>);
	Sat, 31 Mar 2012 17:01:38 -0400
In-Reply-To: <1333227682-10235-1-git-send-email-jpirko@redhat.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

For transfering generic binary data (e.g. BPF code), introduce new
binary option type.

Signed-off-by: Jiri Pirko <jpirko@redhat.com>
---
 drivers/net/team/team.c |   28 ++++++++++++++++++++++++----
 include/linux/if_team.h |    8 ++++++++
 2 files changed, 32 insertions(+), 4 deletions(-)

diff --git a/drivers/net/team/team.c b/drivers/net/team/team.c
index 8f81805..9ad52b5b 100644
--- a/drivers/net/team/team.c
+++ b/drivers/net/team/team.c
@@ -1145,10 +1145,7 @@ team_nl_option_policy[TEAM_ATTR_OPTION_MAX + 1] = {
 	},
 	[TEAM_ATTR_OPTION_CHANGED]		= { .type = NLA_FLAG },
 	[TEAM_ATTR_OPTION_TYPE]			= { .type = NLA_U8 },
-	[TEAM_ATTR_OPTION_DATA] = {
-		.type = NLA_BINARY,
-		.len = TEAM_STRING_MAX_LEN,
-	},
+	[TEAM_ATTR_OPTION_DATA]			= { .type = NLA_BINARY },
 };
 
 static int team_nl_cmd_noop(struct sk_buff *skb, struct genl_info *info)
@@ -1256,6 +1253,7 @@ static int team_nl_fill_options_get(struct sk_buff *skb,
 	list_for_each_entry(option, &team->option_list, list) {
 		struct nlattr *option_item;
 		long arg;
+		struct team_option_binary tbinary;
 
 		/* Include only changed options if fill all mode is not on */
 		if (!fillall && !option->changed)
@@ -1282,6 +1280,13 @@ static int team_nl_fill_options_get(struct sk_buff *skb,
 			NLA_PUT_STRING(skb, TEAM_ATTR_OPTION_DATA,
 				       (char *) arg);
 			break;
+		case TEAM_OPTION_TYPE_BINARY:
+			NLA_PUT_U8(skb, TEAM_ATTR_OPTION_TYPE, NLA_BINARY);
+			arg = (long) &tbinary;
+			team_option_get(team, option, &arg);
+			NLA_PUT(skb, TEAM_ATTR_OPTION_DATA,
+				tbinary.data_len, tbinary.data);
+			break;
 		default:
 			BUG();
 		}
@@ -1366,6 +1371,9 @@ static int team_nl_cmd_options_set(struct sk_buff *skb, struct genl_info *info)
 		case NLA_STRING:
 			opt_type = TEAM_OPTION_TYPE_STRING;
 			break;
+		case NLA_BINARY:
+			opt_type = TEAM_OPTION_TYPE_BINARY;
+			break;
 		default:
 			goto team_put;
 		}
@@ -1374,19 +1382,31 @@ static int team_nl_cmd_options_set(struct sk_buff *skb, struct genl_info *info)
 		list_for_each_entry(option, &team->option_list, list) {
 			long arg;
 			struct nlattr *opt_data_attr;
+			struct team_option_binary tbinary;
+			int data_len;
 
 			if (option->type != opt_type ||
 			    strcmp(option->name, opt_name))
 				continue;
 			opt_found = true;
 			opt_data_attr = mode_attrs[TEAM_ATTR_OPTION_DATA];
+			data_len = nla_len(opt_data_attr);
 			switch (opt_type) {
 			case TEAM_OPTION_TYPE_U32:
 				arg = nla_get_u32(opt_data_attr);
 				break;
 			case TEAM_OPTION_TYPE_STRING:
+				if (data_len > TEAM_STRING_MAX_LEN) {
+					err = -EINVAL;
+					goto team_put;
+				}
 				arg = (long) nla_data(opt_data_attr);
 				break;
+			case TEAM_OPTION_TYPE_BINARY:
+				tbinary.data_len = data_len;
+				tbinary.data = nla_data(opt_data_attr);
+				arg = (long) &tbinary;
+				break;
 			default:
 				BUG();
 			}
diff --git a/include/linux/if_team.h b/include/linux/if_team.h
index 58404b0..41163ac 100644
--- a/include/linux/if_team.h
+++ b/include/linux/if_team.h
@@ -68,6 +68,7 @@ struct team_mode_ops {
 enum team_option_type {
 	TEAM_OPTION_TYPE_U32,
 	TEAM_OPTION_TYPE_STRING,
+	TEAM_OPTION_TYPE_BINARY,
 };
 
 struct team_option {
@@ -82,6 +83,13 @@ struct team_option {
 	bool removed;
 };
 
+struct team_option_binary {
+	u32 data_len;
+	void *data;
+};
+
+#define team_optarg_tbinary(arg) (*((struct team_option_binary **) arg))
+
 struct team_mode {
 	struct list_head list;
 	const char *kind;
-- 
1.7.9.1
