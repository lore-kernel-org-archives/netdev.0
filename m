From: Vlad Yasevich <vyasevic@redhat.com>
Subject: [PATCH] bridge: update mdb expiration timer upon reports.
Date: Thu, 10 Oct 2013 15:57:59 -0400
Message-ID: <1381435079-15387-1-git-send-email-vyasevic@redhat.com>
Cc: Vlad Yasevich <vyasevic@redhat.com>,
	Cong Wang <xiyou.wangcong@gmail.com>,
	Herbert Xu <herbert@gondor.hengli.com.au>,
	Stephen Hemminger <stephen@networkplumber.org>
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mx1.redhat.com ([209.132.183.28]:36024 "EHLO mx1.redhat.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1755783Ab3JJT6P (ORCPT <rfc822;netdev@vger.kernel.org>);
	Thu, 10 Oct 2013 15:58:15 -0400
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

commit 9f00b2e7cf241fa389733d41b615efdaa2cb0f5b
	bridge: only expire the mdb entry when query is received
changed the mdb expiration timer to be armed only when QUERY is
received.  Howerver, this causes issues in an environment where
the multicast server socket comes and goes very fast while a client
is trying to send traffic to it.

The root cause is a race where a sequence of LEAVE followed by REPORT
messages can race against QUERY messages generated in response to LEAVE.
The QUERY ends up starting the expiration timer, and that timer can
potentially expire after the new REPORT message has been received signaling
the new join operation.  This leads to a significant drop in multicast
traffic and possible complete stall. 

The solution is to have REPORT messages update the expiration timer
on entries that already exist.

CC: Cong Wang <xiyou.wangcong@gmail.com>
CC: Herbert Xu <herbert@gondor.apana.org.au>
CC: Stephen Hemminger <stephen@networkplumber.org>
Signed-off-by: Vlad Yasevich <vyasevic@redhat.com>
---
 net/bridge/br_multicast.c | 9 ++++++++-
 1 file changed, 8 insertions(+), 1 deletion(-)

diff --git a/net/bridge/br_multicast.c b/net/bridge/br_multicast.c
index d1c5786..1085f21 100644
--- a/net/bridge/br_multicast.c
+++ b/net/bridge/br_multicast.c
@@ -611,6 +611,9 @@ rehash:
 		break;
 
 	default:
+		/* If we have an existing entry, update it's expire timer */
+		mod_timer(&mp->timer,
+			  jiffies + br->multicast_membership_interval);
 		goto out;
 	}
 
@@ -680,8 +683,12 @@ static int br_multicast_add_group(struct net_bridge *br,
 	for (pp = &mp->ports;
 	     (p = mlock_dereference(*pp, br)) != NULL;
 	     pp = &p->next) {
-		if (p->port == port)
+		if (p->port == port) {
+			/* We already have a portgroup, update the timer.  */
+			mod_timer(&p->timer,
+				  jiffies + br->multicast_membership_interval);
 			goto out;
+		}
 		if ((unsigned long)p->port < (unsigned long)port)
 			break;
 	}
-- 
1.8.3.1
