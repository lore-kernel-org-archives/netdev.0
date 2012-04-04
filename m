From: Jiri Pirko <jpirko@redhat.com>
Subject: [patch net-next 1/2] team: add binary option type
Date: Thu,  5 Apr 2012 00:16:26 +0200
Message-ID: <1333577787-878-1-git-send-email-jpirko@redhat.com>
Cc: davem@davemloft.net, eric.dumazet@gmail.com,
	bhutchings@solarflare.com, shemminger@vyatta.com,
	raise.sail@gmail.com, nuno.martins@caixamagica.pt, matt@ozlabs.org
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mx1.redhat.com ([209.132.183.28]:31927 "EHLO mx1.redhat.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1757399Ab2DEAJz (ORCPT <rfc822;netdev@vger.kernel.org>);
	Wed, 4 Apr 2012 20:09:55 -0400
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

For transfering generic binary data (e.g. BPF code), introduce new
binary option type.

Signed-off-by: Jiri Pirko <jpirko@redhat.com>
---
 drivers/net/team/team.c |   30 ++++++++++++++++++++++++++----
 include/linux/if_team.h |    8 ++++++++
 2 files changed, 34 insertions(+), 4 deletions(-)

diff --git a/drivers/net/team/team.c b/drivers/net/team/team.c
index 0db6e66..ea96f82 100644
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
@@ -1257,6 +1254,7 @@ static int team_nl_fill_options_get(struct sk_buff *skb,
 	list_for_each_entry(option, &team->option_list, list) {
 		struct nlattr *option_item;
 		long arg;
+		struct team_option_binary tbinary;
 
 		/* Include only changed options if fill all mode is not on */
 		if (!fillall && !option->changed)
@@ -1290,6 +1288,15 @@ static int team_nl_fill_options_get(struct sk_buff *skb,
 					   (char *) arg))
 				goto nla_put_failure;
 			break;
+		case TEAM_OPTION_TYPE_BINARY:
+			if (nla_put_u8(skb, TEAM_ATTR_OPTION_TYPE, NLA_BINARY))
+				goto nla_put_failure;
+			arg = (long) &tbinary;
+			team_option_get(team, option, &arg);
+			if (nla_put(skb, TEAM_ATTR_OPTION_DATA,
+				    tbinary.data_len, tbinary.data))
+				goto nla_put_failure;
+			break;
 		default:
 			BUG();
 		}
@@ -1374,6 +1381,9 @@ static int team_nl_cmd_options_set(struct sk_buff *skb, struct genl_info *info)
 		case NLA_STRING:
 			opt_type = TEAM_OPTION_TYPE_STRING;
 			break;
+		case NLA_BINARY:
+			opt_type = TEAM_OPTION_TYPE_BINARY;
+			break;
 		default:
 			goto team_put;
 		}
@@ -1382,19 +1392,31 @@ static int team_nl_cmd_options_set(struct sk_buff *skb, struct genl_info *info)
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
