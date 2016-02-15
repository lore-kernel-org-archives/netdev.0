From: Mark Tomlinson <mark.tomlinson@alliedtelesis.co.nz>
Subject: [PATCH] l2tp: Fix error creating L2TP tunnels
Date: Mon, 15 Feb 2016 16:24:44 +1300
Message-ID: <1455506684-27033-1-git-send-email-mark.tomlinson@alliedtelesis.co.nz>
Cc: davem@davemloft.net, bhong@brocade.com,
	Mark Tomlinson <mark.tomlinson@alliedtelesis.co.nz>
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from gate2.alliedtelesis.co.nz ([202.36.163.20]:46090 "EHLO
	gate2.alliedtelesis.co.nz" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751861AbcBODZV (ORCPT
	<rfc822;netdev@vger.kernel.org>); Sun, 14 Feb 2016 22:25:21 -0500
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

A previous commit (33f72e6) added notification via netlink for tunnels
when created/modified/deleted. If the notification returned an error,
this error was returned from the tunnel function. If there were no
listeners, the error code ESRCH was returned, even though having no
listeners is not an error. Other calls to this and other similar
notification functions either ignore the error code, or filter ESRCH.
This patch checks for ESRCH and does not flag this as an error.

Reviewed-by: Hamish Martin <hamish.martin@alliedtelesis.co.nz>
Signed-off-by: Mark Tomlinson <mark.tomlinson@alliedtelesis.co.nz>
---
 net/l2tp/l2tp_netlink.c | 18 ++++++++++++++----
 1 file changed, 14 insertions(+), 4 deletions(-)

diff --git a/net/l2tp/l2tp_netlink.c b/net/l2tp/l2tp_netlink.c
index f93c5be..2caaa84 100644
--- a/net/l2tp/l2tp_netlink.c
+++ b/net/l2tp/l2tp_netlink.c
@@ -124,8 +124,13 @@ static int l2tp_tunnel_notify(struct genl_family *family,
 	ret = l2tp_nl_tunnel_send(msg, info->snd_portid, info->snd_seq,
 				  NLM_F_ACK, tunnel, cmd);
 
-	if (ret >= 0)
-		return genlmsg_multicast_allns(family, msg, 0,	0, GFP_ATOMIC);
+	if (ret >= 0) {
+		ret = genlmsg_multicast_allns(family, msg, 0, 0, GFP_ATOMIC);
+		/* We don't care if no one is listening */
+		if (ret == -ESRCH)
+			ret = 0;
+		return ret;
+	}
 
 	nlmsg_free(msg);
 
@@ -147,8 +152,13 @@ static int l2tp_session_notify(struct genl_family *family,
 	ret = l2tp_nl_session_send(msg, info->snd_portid, info->snd_seq,
 				   NLM_F_ACK, session, cmd);
 
-	if (ret >= 0)
-		return genlmsg_multicast_allns(family, msg, 0,	0, GFP_ATOMIC);
+	if (ret >= 0) {
+		ret = genlmsg_multicast_allns(family, msg, 0, 0, GFP_ATOMIC);
+		/* We don't care if no one is listening */
+		if (ret == -ESRCH)
+			ret = 0;
+		return ret;
+	}
 
 	nlmsg_free(msg);
 
-- 
2.7.1
