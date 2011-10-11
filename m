From: Steffen Klassert <steffen.klassert@secunet.com>
Subject: [PATCH 4/4] ipv4: Fix inetpeer expire time information
Date: Tue, 11 Oct 2011 13:12:02 +0200
Message-ID: <20111011111202.GG1830@secunet.com>
References: <20111011110842.GC1830@secunet.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: netdev@vger.kernel.org
To: David Miller <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from a.mx.secunet.com ([195.81.216.161]:57897 "EHLO a.mx.secunet.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1752571Ab1JKLME (ORCPT <rfc822;netdev@vger.kernel.org>);
	Tue, 11 Oct 2011 07:12:04 -0400
Content-Disposition: inline
In-Reply-To: <20111011110842.GC1830@secunet.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

As we update the learned pmtu informations on demand, we might
report a nagative expiration time value to userspace if the
pmtu informations are already expired and we have not send a
packet to that inetpeer after expiration. With this patch we
send a expire time of null to userspace after expiration
until the next packet is send to that inetpeer.

Signed-off-by: Steffen Klassert <steffen.klassert@secunet.com>
---
 net/ipv4/route.c |   10 +++++++---
 1 files changed, 7 insertions(+), 3 deletions(-)

diff --git a/net/ipv4/route.c b/net/ipv4/route.c
index cda370c..501a3c0 100644
--- a/net/ipv4/route.c
+++ b/net/ipv4/route.c
@@ -2832,7 +2832,7 @@ static int rt_fill_info(struct net *net,
 	struct rtable *rt = skb_rtable(skb);
 	struct rtmsg *r;
 	struct nlmsghdr *nlh;
-	long expires = 0;
+	unsigned long expires = 0;
 	const struct inet_peer *peer = rt->peer;
 	u32 id = 0, ts = 0, tsage = 0, error;
 
@@ -2889,8 +2889,12 @@ static int rt_fill_info(struct net *net,
 			tsage = get_seconds() - peer->tcp_ts_stamp;
 		}
 		expires = ACCESS_ONCE(peer->pmtu_expires);
-		if (expires)
-			expires -= jiffies;
+		if (expires) {
+			if (time_before(jiffies, expires))
+				expires -= jiffies;
+			else
+				expires = 0;
+		}
 	}
 
 	if (rt_is_input_route(rt)) {
-- 
1.7.0.4
