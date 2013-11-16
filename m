From: "Paul E. McKenney" <paulmck@linux.vnet.ibm.com>
Subject: [PATCH tip/core/rcu 03/14] bridge: Apply ACCESS_ONCE() to avoid sparse false positive
Date: Fri, 15 Nov 2013 16:40:06 -0800
Message-ID: <1384562417-817-3-git-send-email-paulmck@linux.vnet.ibm.com>
References: <20131116003946.GA316@linux.vnet.ibm.com>
 <1384562417-817-1-git-send-email-paulmck@linux.vnet.ibm.com>
Cc: mingo@kernel.org, laijs@cn.fujitsu.com, dipankar@in.ibm.com,
	akpm@linux-foundation.org, mathieu.desnoyers@efficios.com,
	josh@joshtriplett.org, niv@us.ibm.com, tglx@linutronix.de,
	peterz@infradead.org, rostedt@goodmis.org, dhowells@redhat.com,
	edumazet@google.com, darren@dvhart.com, fweisbec@gmail.com,
	sbw@mit.edu, "Paul E. McKenney" <paulmck@linux.vnet.ibm.com>,
	Stephen Hemminger <stephen@networkplumber.org>,
	"David S. Miller" <davem@davemloft.net>,
	bridge@lists.linux-foundation.org, netdev@vger.kernel.org
To: linux-kernel@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from e32.co.us.ibm.com ([32.97.110.150]:41080 "EHLO
	e32.co.us.ibm.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1754840Ab3KPAk1 (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 15 Nov 2013 19:40:27 -0500
Received: from /spool/local
	by e32.co.us.ibm.com with IBM ESMTP SMTP Gateway: Authorized Use Only! Violators will be prosecuted
	for <netdev@vger.kernel.org> from <paulmck@linux.vnet.ibm.com>;
	Fri, 15 Nov 2013 17:40:26 -0700
In-Reply-To: <1384562417-817-1-git-send-email-paulmck@linux.vnet.ibm.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: "Paul E. McKenney" <paulmck@linux.vnet.ibm.com>

The sparse checking for rcu_assign_pointer() was recently upgraded
to reject non-__kernel address spaces.  This also rejects __rcu,
which is almost always the right thing to do.  However, the uses in
br_multicast_del_pg() and br_multicast_new_port_group() are legitimate:
They are assigning a pointer to an element from an RCU-protected list,
and all elements of this list are already visible to caller.

This commit therefore silences these false positives by laundering
the pointers using ACCESS_ONCE() as suggested by Eric Dumazet and Josh
Triplett.

Reported-by: kbuild test robot <fengguang.wu@intel.com>
Signed-off-by: Paul E. McKenney <paulmck@linux.vnet.ibm.com>
Cc: Stephen Hemminger <stephen@networkplumber.org>
Cc: "David S. Miller" <davem@davemloft.net>
Cc: bridge@lists.linux-foundation.org
Cc: netdev@vger.kernel.org
---
 net/bridge/br_multicast.c | 4 ++--
 1 file changed, 2 insertions(+), 2 deletions(-)

diff --git a/net/bridge/br_multicast.c b/net/bridge/br_multicast.c
index d1c578630678..bcc4bbc16498 100644
--- a/net/bridge/br_multicast.c
+++ b/net/bridge/br_multicast.c
@@ -267,7 +267,7 @@ static void br_multicast_del_pg(struct net_bridge *br,
 		if (p != pg)
 			continue;
 
-		rcu_assign_pointer(*pp, p->next);
+		ACCESS_ONCE(*pp) = p->next; /* OK: Both --rcu and visible. */
 		hlist_del_init(&p->mglist);
 		del_timer(&p->timer);
 		call_rcu_bh(&p->rcu, br_multicast_free_pg);
@@ -646,7 +646,7 @@ struct net_bridge_port_group *br_multicast_new_port_group(
 	p->addr = *group;
 	p->port = port;
 	p->state = state;
-	rcu_assign_pointer(p->next, next);
+	ACCESS_ONCE(p->next) = next; /* OK: Both --rcu and visible. */
 	hlist_add_head(&p->mglist, &port->mglist);
 	setup_timer(&p->timer, br_multicast_port_group_expired,
 		    (unsigned long)p);
-- 
1.8.1.5
