From: Eric Dumazet <eric.dumazet@gmail.com>
Subject: [PATCH] bridge: do not call setup_timer() multiple times
Date: Fri, 19 Jul 2013 20:07:16 -0700
Message-ID: <1374289636.26476.42.camel@edumazet-glaptop>
References: <51E557C0.2060602@linux.vnet.ibm.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="UTF-8"
Content-Transfer-Encoding: 7bit
Cc: "linux-kernel@vger.kernel.org" <linux-kernel@vger.kernel.org>,
	Thomas Gleixner <tglx@linutronix.de>,
	netdev <netdev@vger.kernel.org>
To: "Srivatsa S. Bhat" <srivatsa.bhat@linux.vnet.ibm.com>,
	David Miller <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-pb0-f44.google.com ([209.85.160.44]:54559 "EHLO
	mail-pb0-f44.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1753547Ab3GTDHT (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 19 Jul 2013 23:07:19 -0400
In-Reply-To: <51E557C0.2060602@linux.vnet.ibm.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Eric Dumazet <edumazet@google.com>

commit 9f00b2e7cf24 ("bridge: only expire the mdb entry when query is
received") added a nasty bug as an active timer can be reinitialized.

setup_timer() must be done once, no matter how many time mod_timer()
is called. br_multicast_new_group() is the right place to do this.

Reported-by: Srivatsa S. Bhat <srivatsa.bhat@linux.vnet.ibm.com>
Diagnosed-by: Thomas Gleixner <tglx@linutronix.de>
Signed-off-by: Eric Dumazet <edumazet@google.com>
Tested-by: Srivatsa S. Bhat <srivatsa.bhat@linux.vnet.ibm.com>
Cc: Cong Wang <amwang@redhat.com>
---
 net/bridge/br_multicast.c |    5 +++--
 1 file changed, 3 insertions(+), 2 deletions(-)

diff --git a/net/bridge/br_multicast.c b/net/bridge/br_multicast.c
index 69af490..4b99c9a 100644
--- a/net/bridge/br_multicast.c
+++ b/net/bridge/br_multicast.c
@@ -619,6 +619,9 @@ rehash:
 	mp->br = br;
 	mp->addr = *group;
 
+	setup_timer(&mp->timer, br_multicast_group_expired,
+		    (unsigned long)mp);
+
 	hlist_add_head_rcu(&mp->hlist[mdb->ver], &mdb->mhash[hash]);
 	mdb->size++;
 
@@ -1126,7 +1129,6 @@ static int br_ip4_multicast_query(struct net_bridge *br,
 	if (!mp)
 		goto out;
 
-	setup_timer(&mp->timer, br_multicast_group_expired, (unsigned long)mp);
 	mod_timer(&mp->timer, now + br->multicast_membership_interval);
 	mp->timer_armed = true;
 
@@ -1204,7 +1206,6 @@ static int br_ip6_multicast_query(struct net_bridge *br,
 	if (!mp)
 		goto out;
 
-	setup_timer(&mp->timer, br_multicast_group_expired, (unsigned long)mp);
 	mod_timer(&mp->timer, now + br->multicast_membership_interval);
 	mp->timer_armed = true;
 
