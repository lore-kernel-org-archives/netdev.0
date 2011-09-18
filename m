From: Paul Gortmaker <paul.gortmaker@windriver.com>
Subject: [PATCH net-next 05/28] tipc: Enhance filtering of out-dated link reset messages
Date: Sat, 17 Sep 2011 23:32:01 -0400
Message-ID: <1316316744-29514-6-git-send-email-paul.gortmaker@windriver.com>
References: <1316316744-29514-1-git-send-email-paul.gortmaker@windriver.com>
Cc: netdev@vger.kernel.org, allan.stephens@windriver.com,
	ying.xue@windriver.com,
	Paul Gortmaker <paul.gortmaker@windriver.com>
To: davem@davemloft.net
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail.windriver.com ([147.11.1.11]:49964 "EHLO
	mail.windriver.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1753271Ab1IRDcn (ORCPT
	<rfc822;netdev@vger.kernel.org>); Sat, 17 Sep 2011 23:32:43 -0400
In-Reply-To: <1316316744-29514-1-git-send-email-paul.gortmaker@windriver.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Allan Stephens <allan.stephens@windriver.com>

Ensure TIPC ignores an out-dated link reset message whose session
number predates the current session number. (Previously, TIPC only
ignored an out-date reset message whose session number was equal
to the current link session number.)

Out-dated link reset messages should not occur under normal circumstances;
however, they can be generated if a link endpoint is unable to send a
link reset message right away and queues it for later delivery, but the
queued message is not sent until after the link is established.

Thanks to Laser [gotolaser@gmail.com] for diagnosing the problem and
contributing a prototype patch.

Signed-off-by: Allan Stephens <allan.stephens@windriver.com>
Signed-off-by: Paul Gortmaker <paul.gortmaker@windriver.com>
---
 net/tipc/link.c |    4 ++--
 1 files changed, 2 insertions(+), 2 deletions(-)

diff --git a/net/tipc/link.c b/net/tipc/link.c
index e0bf6d5..b43beea 100644
--- a/net/tipc/link.c
+++ b/net/tipc/link.c
@@ -2045,8 +2045,8 @@ static void link_recv_proto_msg(struct link *l_ptr, struct sk_buff *buf)
 	case RESET_MSG:
 		if (!link_working_unknown(l_ptr) &&
 		    (l_ptr->peer_session != INVALID_SESSION)) {
-			if (msg_session(msg) == l_ptr->peer_session)
-				break; /* duplicate: ignore */
+			if (less_eq(msg_session(msg), l_ptr->peer_session))
+				break; /* duplicate or old reset: ignore */
 		}
 		/* fall thru' */
 	case ACTIVATE_MSG:
-- 
1.7.4.4
