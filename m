From: Cong Wang <amwang@redhat.com>
Subject: [Patch net-next v3 3/3] bridge: send query as soon as leave is received
Date: Tue, 30 Apr 2013 15:10:19 +0800
Message-ID: <1367305819-14013-3-git-send-email-amwang@redhat.com>
References: <1367305819-14013-1-git-send-email-amwang@redhat.com>
Cc: Herbert Xu <herbert@gondor.hengli.com.au>,
	Stephen Hemminger <stephen@networkplumber.org>,
	"David S. Miller" <davem@davemloft.net>,
	Adam Baker <linux@baker-net.org.uk>,
	Cong Wang <amwang@redhat.com>
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mx1.redhat.com ([209.132.183.28]:46658 "EHLO mx1.redhat.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1758244Ab3D3HK4 (ORCPT <rfc822;netdev@vger.kernel.org>);
	Tue, 30 Apr 2013 03:10:56 -0400
In-Reply-To: <1367305819-14013-1-git-send-email-amwang@redhat.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Cong Wang <amwang@redhat.com>

Send a non-general query when leave is received, if the user marks
it as a querier.

Cc: Herbert Xu <herbert@gondor.apana.org.au>
Cc: Stephen Hemminger <stephen@networkplumber.org>
Cc: "David S. Miller" <davem@davemloft.net>
Cc: Adam Baker <linux@baker-net.org.uk>
Signed-off-by: Cong Wang <amwang@redhat.com>
---
v3: use non-general query
v2: only send query to the port received leave

 net/bridge/br_multicast.c |   15 +++++++++++++++
 1 files changed, 15 insertions(+), 0 deletions(-)

diff --git a/net/bridge/br_multicast.c b/net/bridge/br_multicast.c
index 6a05522..d73276b 100644
--- a/net/bridge/br_multicast.c
+++ b/net/bridge/br_multicast.c
@@ -1250,6 +1250,21 @@ static void br_multicast_leave_group(struct net_bridge *br,
 	if (!mp)
 		goto out;
 
+	if (br->multicast_querier &&
+	    !timer_pending(&br->multicast_querier_timer)) {
+		u32 sent;
+
+		__br_multicast_send_query(br, port, &mp->addr);
+		sent = port ? port->multicast_startup_queries_sent :
+			      br->multicast_startup_queries_sent;
+		time = jiffies;
+		time += sent < br->multicast_startup_query_count ?
+			br->multicast_startup_query_interval :
+			br->multicast_query_interval;
+		mod_timer(port ? &port->multicast_query_timer :
+				 &br->multicast_query_timer, time);
+	}
+
 	if (port && (port->flags & BR_MULTICAST_FAST_LEAVE)) {
 		struct net_bridge_port_group __rcu **pp;
 
