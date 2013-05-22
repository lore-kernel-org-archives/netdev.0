From: Cong Wang <amwang@redhat.com>
Subject: [Patch net-next v5 3/3] bridge: send query as soon as leave is received
Date: Wed, 22 May 2013 15:52:56 +0800
Message-ID: <1369209176-6841-3-git-send-email-amwang@redhat.com>
References: <1369209176-6841-1-git-send-email-amwang@redhat.com>
Cc: Herbert Xu <herbert@gondor.hengli.com.au>,
	Stephen Hemminger <stephen@networkplumber.org>,
	"David S. Miller" <davem@davemloft.net>,
	Adam Baker <linux@baker-net.org.uk>,
	Cong Wang <amwang@redhat.com>
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mx1.redhat.com ([209.132.183.28]:23735 "EHLO mx1.redhat.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1752176Ab3EVHxs (ORCPT <rfc822;netdev@vger.kernel.org>);
	Wed, 22 May 2013 03:53:48 -0400
In-Reply-To: <1369209176-6841-1-git-send-email-amwang@redhat.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Cong Wang <amwang@redhat.com>

Continue sending queries when leave is received if the user marks
it as a querier.

Cc: Herbert Xu <herbert@gondor.apana.org.au>
Cc: Stephen Hemminger <stephen@networkplumber.org>
Cc: "David S. Miller" <davem@davemloft.net>
Cc: Adam Baker <linux@baker-net.org.uk>
Signed-off-by: Cong Wang <amwang@redhat.com>
---
v5: no change
v4: use the right timeout value
    re-arm timers here
v3: use non-general query
v2: only send query to the port received leave

 net/bridge/br_multicast.c |   26 ++++++++++++++++++++++++++
 1 files changed, 26 insertions(+), 0 deletions(-)

diff --git a/net/bridge/br_multicast.c b/net/bridge/br_multicast.c
index 40bda80..37a4676 100644
--- a/net/bridge/br_multicast.c
+++ b/net/bridge/br_multicast.c
@@ -1250,6 +1250,32 @@ static void br_multicast_leave_group(struct net_bridge *br,
 	if (!mp)
 		goto out;
 
+	if (br->multicast_querier &&
+	    !timer_pending(&br->multicast_querier_timer)) {
+		__br_multicast_send_query(br, port, &mp->addr);
+
+		time = jiffies + br->multicast_last_member_count *
+				 br->multicast_last_member_interval;
+		mod_timer(port ? &port->multicast_query_timer :
+				 &br->multicast_query_timer, time);
+
+		for (p = mlock_dereference(mp->ports, br);
+		     p != NULL;
+		     p = mlock_dereference(p->next, br)) {
+			if (p->port != port)
+				continue;
+
+			if (!hlist_unhashed(&p->mglist) &&
+			    (timer_pending(&p->timer) ?
+			     time_after(p->timer.expires, time) :
+			     try_to_del_timer_sync(&p->timer) >= 0)) {
+				mod_timer(&p->timer, time);
+			}
+
+			break;
+		}
+	}
+
 	if (port && (port->flags & BR_MULTICAST_FAST_LEAVE)) {
 		struct net_bridge_port_group __rcu **pp;
 
-- 
1.7.7.6
