From: Jon Maloy <jon.maloy@ericsson.com>
Subject: [PATCH net-next 5/5] tipc: correct return value of link_cmd_set_value routine
Date: Tue, 24 Sep 2013 04:27:48 -0500
Message-ID: <1380014868-2797-6-git-send-email-jon.maloy@ericsson.com>
References: <1380014868-2797-1-git-send-email-jon.maloy@ericsson.com>
Cc: netdev@vger.kernel.org,
	Paul Gortmaker <paul.gortmaker@windriver.com>,
	erik.hugne@ericsson.com, ying.xue@windriver.com, maloy@donjonn.com,
	tipc-discussion@lists.sourceforge.net,
	Jon Maloy <jon.maloy@ericsson.com>
To: davem@davemloft.net
Return-path: <netdev-owner@vger.kernel.org>
Received: from smtp106.biz.mail.bf1.yahoo.com ([98.139.244.54]:29743 "HELO
	smtp106.biz.mail.bf1.yahoo.com" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with SMTP id S1752942Ab3IXJey (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 24 Sep 2013 05:34:54 -0400
In-Reply-To: <1380014868-2797-1-git-send-email-jon.maloy@ericsson.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Ying Xue <ying.xue@windriver.com>

link_cmd_set_value() takes commands for link, bearer and media related
configuration. Genereally the function returns 0 when a command is
recognized, and -EINVAL when it is not. However, in the switch for link
related commands it returns 0 even when the command is unrecognized. This
will sometimes make it look as if a failed configuration command has been
successful, but has otherwise no negative effects.

We remove this anomaly by returning -EINVAL even for link commands. We also
rework all three switches to make them  conforming to common kernel coding
style.

Signed-off-by: Ying Xue <ying.xue@windriver.com>
Reviewed-by: Paul Gortmaker <paul.gortmaker@windriver.com>
Signed-off-by: Jon Maloy <jon.maloy@ericsson.com>
---
 net/tipc/link.c |   28 +++++++++++++++++++---------
 1 file changed, 19 insertions(+), 9 deletions(-)

diff --git a/net/tipc/link.c b/net/tipc/link.c
index 40521ae..8bbe4ca 100644
--- a/net/tipc/link.c
+++ b/net/tipc/link.c
@@ -2647,6 +2647,7 @@ static int link_cmd_set_value(const char *name, u32 new_value, u16 cmd)
 	struct tipc_link *l_ptr;
 	struct tipc_bearer *b_ptr;
 	struct tipc_media *m_ptr;
+	int res = 0;
 
 	l_ptr = link_find_link(name, &node);
 	if (l_ptr) {
@@ -2669,9 +2670,12 @@ static int link_cmd_set_value(const char *name, u32 new_value, u16 cmd)
 		case TIPC_CMD_SET_LINK_WINDOW:
 			tipc_link_set_queue_limits(l_ptr, new_value);
 			break;
+		default:
+			res = -EINVAL;
+			break;
 		}
 		tipc_node_unlock(node);
-		return 0;
+		return res;
 	}
 
 	b_ptr = tipc_bearer_find(name);
@@ -2679,15 +2683,18 @@ static int link_cmd_set_value(const char *name, u32 new_value, u16 cmd)
 		switch (cmd) {
 		case TIPC_CMD_SET_LINK_TOL:
 			b_ptr->tolerance = new_value;
-			return 0;
+			break;
 		case TIPC_CMD_SET_LINK_PRI:
 			b_ptr->priority = new_value;
-			return 0;
+			break;
 		case TIPC_CMD_SET_LINK_WINDOW:
 			b_ptr->window = new_value;
-			return 0;
+			break;
+		default:
+			res = -EINVAL;
+			break;
 		}
-		return -EINVAL;
+		return res;
 	}
 
 	m_ptr = tipc_media_find(name);
@@ -2696,15 +2703,18 @@ static int link_cmd_set_value(const char *name, u32 new_value, u16 cmd)
 	switch (cmd) {
 	case TIPC_CMD_SET_LINK_TOL:
 		m_ptr->tolerance = new_value;
-		return 0;
+		break;
 	case TIPC_CMD_SET_LINK_PRI:
 		m_ptr->priority = new_value;
-		return 0;
+		break;
 	case TIPC_CMD_SET_LINK_WINDOW:
 		m_ptr->window = new_value;
-		return 0;
+		break;
+	default:
+		res = -EINVAL;
+		break;
 	}
-	return -EINVAL;
+	return res;
 }
 
 struct sk_buff *tipc_link_cmd_config(const void *req_tlv_area, int req_tlv_space,
-- 
1.7.9.5
