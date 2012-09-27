From: Nicolas Dichtel <nicolas.dichtel@6wind.com>
Subject: [PATCH] inetpeer: ensure to set the maximum tokens the first time
Date: Thu, 27 Sep 2012 14:33:57 +0200
Message-ID: <1348749237-3919-1-git-send-email-nicolas.dichtel@6wind.com>
Cc: Nicolas Dichtel <nicolas.dichtel@6wind.com>
To: netdev@vger.kernel.org, davem@davemloft.net
Return-path: <netdev-owner@vger.kernel.org>
Received: from 33.106-14-84.ripe.coltfrance.com ([84.14.106.33]:34841 "EHLO
	proxy.6wind.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751192Ab2I0Maj (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 27 Sep 2012 08:30:39 -0400
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

When jiffies wraps around (for example, 5 minutes after the boot, see
INITIAL_JIFFIES) and peer has just been created, now - peer->rate_last can be
< XRLIM_BURST_FACTOR * timeout, so token is not set to the maximum value, thus
some icmp packets can be unexpectedly dropped.

With this patch, it's still possible that last_rate and rate_tokens are 0 at the
same time after jiffies wraps round, but the probability is very low and the
only consequence is to let some ICMP packets bypass the filter.

Signed-off-by: Nicolas Dichtel <nicolas.dichtel@6wind.com>
---
 net/ipv4/inetpeer.c | 10 +++++++---
 1 file changed, 7 insertions(+), 3 deletions(-)

diff --git a/net/ipv4/inetpeer.c b/net/ipv4/inetpeer.c
index e1e0a4e..92fec02 100644
--- a/net/ipv4/inetpeer.c
+++ b/net/ipv4/inetpeer.c
@@ -559,10 +559,14 @@ bool inet_peer_xrlim_allow(struct inet_peer *peer, int timeout)
 
 	token = peer->rate_tokens;
 	now = jiffies;
-	token += now - peer->rate_last;
-	peer->rate_last = now;
-	if (token > XRLIM_BURST_FACTOR * timeout)
+	if (!peer->rate_last && !token)
 		token = XRLIM_BURST_FACTOR * timeout;
+	else {
+		token += now - peer->rate_last;
+		if (token > XRLIM_BURST_FACTOR * timeout)
+			token = XRLIM_BURST_FACTOR * timeout;
+	}
+	peer->rate_last = now;
 	if (token >= timeout) {
 		token -= timeout;
 		rc = true;
-- 
1.7.12
