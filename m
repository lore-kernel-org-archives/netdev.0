From: Alexander Couzens <lynxis@fe80.eu>
Subject: [PATCH] l2tp_netlink: ignore -ESRCH of genlmsg_multicast_allns()
Date: Sun, 21 Feb 2016 21:58:45 +0100
Message-ID: <1456088325-22375-1-git-send-email-lynxis@fe80.eu>
Cc: Alexander Couzens <lynxis@fe80.eu>
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail.base45.de ([80.241.61.77]:34899 "EHLO mail.base45.de"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1751373AbcBUV3B (ORCPT <rfc822;netdev@vger.kernel.org>);
	Sun, 21 Feb 2016 16:29:01 -0500
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

If no one registered to the l2tp netlink group, genlmsg_multicast_allns
returns -ESRCH. Ignore return code -ESRCH of genlmsg_mulitcast_allns
within tunnel_create and session_create calls.

Signed-off-by: Alexander Couzens <lynxis@fe80.eu>
---
 net/l2tp/l2tp_netlink.c | 24 ++++++++++++++++--------
 1 file changed, 16 insertions(+), 8 deletions(-)

diff --git a/net/l2tp/l2tp_netlink.c b/net/l2tp/l2tp_netlink.c
index f93c5be..eced13a 100644
--- a/net/l2tp/l2tp_netlink.c
+++ b/net/l2tp/l2tp_netlink.c
@@ -123,11 +123,15 @@ static int l2tp_tunnel_notify(struct genl_family *family,
 
 	ret = l2tp_nl_tunnel_send(msg, info->snd_portid, info->snd_seq,
 				  NLM_F_ACK, tunnel, cmd);
+	if (ret < 0) {
+		nlmsg_free(msg);
+		return ret;
+	}
 
-	if (ret >= 0)
-		return genlmsg_multicast_allns(family, msg, 0,	0, GFP_ATOMIC);
-
-	nlmsg_free(msg);
+	ret = genlmsg_multicast_allns(family, msg, 0, 0, GFP_ATOMIC);
+	/* We don't care if no one is listening */
+	if (ret == -ESRCH)
+		ret = 0;
 
 	return ret;
 }
@@ -146,11 +150,15 @@ static int l2tp_session_notify(struct genl_family *family,
 
 	ret = l2tp_nl_session_send(msg, info->snd_portid, info->snd_seq,
 				   NLM_F_ACK, session, cmd);
+	if (ret < 0) {
+		nlmsg_free(msg);
+		return ret;
+	}
 
-	if (ret >= 0)
-		return genlmsg_multicast_allns(family, msg, 0,	0, GFP_ATOMIC);
-
-	nlmsg_free(msg);
+	ret = genlmsg_multicast_allns(family, msg, 0, 0, GFP_ATOMIC);
+	/* We don't care if no one is listening */
+	if (ret == -ESRCH)
+		ret = 0;
 
 	return ret;
 }
-- 
2.7.1
