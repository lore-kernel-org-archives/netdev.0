From: Guillaume Nault <g.nault@alphalink.fr>
Subject: [PATCH net 4/5] l2tp: hold session while sending creation
 notifications
Date: Fri, 31 Mar 2017 13:02:29 +0200
Message-ID: <4469e0a955ea4ca4aca626f39b5c2ae5846c1fef.1490955471.git.g.nault@alphalink.fr>
References: <cover.1490955471.git.g.nault@alphalink.fr>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: James Chapman <jchapman@katalix.com>, Bill Hong <bhong@brocade.com>
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from zimbra.alphalink.fr ([217.15.80.77]:51782 "EHLO
        zimbra.alphalink.fr" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S932993AbdCaLCd (ORCPT
        <rfc822;netdev@vger.kernel.org>); Fri, 31 Mar 2017 07:02:33 -0400
Content-Disposition: inline
In-Reply-To: <cover.1490955471.git.g.nault@alphalink.fr>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

l2tp_session_find() doesn't take any reference on the returned session.
Therefore, the session may disappear while sending the notification.

Use l2tp_session_get() instead and decrement session's refcount once
the notification is sent.

Fixes: 33f72e6f0c67 ("l2tp : multicast notification to the registered listeners")
Signed-off-by: Guillaume Nault <g.nault@alphalink.fr>
---
 net/l2tp/l2tp_netlink.c | 6 ++++--
 1 file changed, 4 insertions(+), 2 deletions(-)

diff --git a/net/l2tp/l2tp_netlink.c b/net/l2tp/l2tp_netlink.c
index 3620fba31786..f1b68effb077 100644
--- a/net/l2tp/l2tp_netlink.c
+++ b/net/l2tp/l2tp_netlink.c
@@ -642,10 +642,12 @@ static int l2tp_nl_cmd_session_create(struct sk_buff *skb, struct genl_info *inf
 			session_id, peer_session_id, &cfg);
 
 	if (ret >= 0) {
-		session = l2tp_session_find(net, tunnel, session_id);
-		if (session)
+		session = l2tp_session_get(net, tunnel, session_id, false);
+		if (session) {
 			ret = l2tp_session_notify(&l2tp_nl_family, info, session,
 						  L2TP_CMD_SESSION_CREATE);
+			l2tp_session_dec_refcount(session);
+		}
 	}
 
 out:
-- 
2.11.0
