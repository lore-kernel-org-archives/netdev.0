From: David Miller <davem@davemloft.net>
Subject: [PATCH 6/7]:
Date: Mon, 07 Jan 2008 21:40:51 -0800 (PST)
Message-ID: <20080107.214051.95043537.davem@davemloft.net>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from 74-93-104-97-Washington.hfc.comcastbusiness.net ([74.93.104.97]:32888
	"EHLO sunset.davemloft.net" rhost-flags-OK-FAIL-OK-OK)
	by vger.kernel.org with ESMTP id S1752446AbYAHFkv (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 8 Jan 2008 00:40:51 -0500
Received: from localhost (localhost [127.0.0.1])
	by sunset.davemloft.net (Postfix) with ESMTP id 365D9C8C217
	for <netdev@vger.kernel.org>; Mon,  7 Jan 2008 21:40:51 -0800 (PST)
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>


[NET]: Stop polling when napi_disable() is pending.

This finally adds the code in net_rx_action() to break out of the
->poll()'ing loop when a napi_disable() is found to be pending.

Now, even if a device is being flooded with packets it can be cleanly
brought down.

Signed-off-by: David S. Miller <davem@davemloft.net>
---
 net/core/dev.c |    8 ++++++--
 1 files changed, 6 insertions(+), 2 deletions(-)

diff --git a/net/core/dev.c b/net/core/dev.c
index be9d301..0879f52 100644
--- a/net/core/dev.c
+++ b/net/core/dev.c
@@ -2207,8 +2207,12 @@ static void net_rx_action(struct softirq_action *h)
 		 * still "owns" the NAPI instance and therefore can
 		 * move the instance around on the list at-will.
 		 */
-		if (unlikely(work == weight))
-			list_move_tail(&n->poll_list, list);
+		if (unlikely(work == weight)) {
+			if (unlikely(napi_disable_pending(n)))
+				__napi_complete(n);
+			else
+				list_move_tail(&n->poll_list, list);
+		}
 
 		netpoll_poll_unlock(have);
 	}
-- 
1.5.4.rc2.38.gd6da3

