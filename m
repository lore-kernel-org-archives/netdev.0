From: "Paul E. McKenney" <paulmck@linux.vnet.ibm.com>
Subject: [PATCH v2 tip/core/rcu 03/13] bridge: Apply
	rcu_access_pointer() to avoid sparse false positive
Date: Wed,  9 Oct 2013 14:29:36 -0700
Message-ID: <1381354186-16285-3-git-send-email-paulmck@linux.vnet.ibm.com>
References: <20131009212920.GA15413@linux.vnet.ibm.com>
	<1381354186-16285-1-git-send-email-paulmck@linux.vnet.ibm.com>
Cc: Stephen Hemminger <stephen@networkplumber.org>, tglx@linutronix.de,
	laijs@cn.fujitsu.com, edumazet@google.com, peterz@infradead.org,
	fweisbec@gmail.com, bridge@lists.linux-foundation.org,
	josh@joshtriplett.org, rostedt@goodmis.org,
	"David S. Miller" <davem@davemloft.net>, dhowells@redhat.com,
	sbw@mit.edu, niv@us.ibm.com, netdev@vger.kernel.org,
	mathieu.desnoyers@efficios.com, dipankar@in.ibm.com,
	darren@dvhart.com, akpm@linux-foundation.org,
	"Paul E. McKenney" <paulmck@linux.vnet.ibm.com>, mingo@kernel.org
To: linux-kernel@vger.kernel.org
Return-path: <bridge-bounces@lists.linux-foundation.org>
In-Reply-To: <1381354186-16285-1-git-send-email-paulmck@linux.vnet.ibm.com>
List-Unsubscribe: <https://lists.linuxfoundation.org/mailman/options/bridge>,
	<mailto:bridge-request@lists.linux-foundation.org?subject=unsubscribe>
List-Archive: <http://lists.linuxfoundation.org/pipermail/bridge/>
List-Post: <mailto:bridge@lists.linux-foundation.org>
List-Help: <mailto:bridge-request@lists.linux-foundation.org?subject=help>
List-Subscribe: <https://lists.linuxfoundation.org/mailman/listinfo/bridge>,
	<mailto:bridge-request@lists.linux-foundation.org?subject=subscribe>
Sender: bridge-bounces@lists.linux-foundation.org
Errors-To: bridge-bounces@lists.linux-foundation.org
List-Id: netdev.vger.kernel.org

From: "Paul E. McKenney" <paulmck@linux.vnet.ibm.com>

The sparse checking for rcu_assign_pointer() was recently upgraded
to reject non-__kernel address spaces.  This also rejects __rcu,
which is almost always the right thing to do.  However, the uses in
br_multicast_del_pg() and br_multicast_new_port_group() are legitimate:
They are assigning a pointer to an element from an RCU-protected list,
and all elements of this list are already visible to caller.

This commit therefore silences these false positives by laundering the
pointers using rcu_access_pointer() as suggested by Josh Triplett.

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
index d1c578630678..314c81cc5855 100644
--- a/net/bridge/br_multicast.c
+++ b/net/bridge/br_multicast.c
@@ -267,7 +267,7 @@ static void br_multicast_del_pg(struct net_bridge *br,
 		if (p != pg)
 			continue;
 
-		rcu_assign_pointer(*pp, p->next);
+		rcu_assign_pointer(*pp, rcu_access_pointer(p->next));
 		hlist_del_init(&p->mglist);
 		del_timer(&p->timer);
 		call_rcu_bh(&p->rcu, br_multicast_free_pg);
@@ -646,7 +646,7 @@ struct net_bridge_port_group *br_multicast_new_port_group(
 	p->addr = *group;
 	p->port = port;
 	p->state = state;
-	rcu_assign_pointer(p->next, next);
+	rcu_assign_pointer(p->next, rcu_access_pointer(next));
 	hlist_add_head(&p->mglist, &port->mglist);
 	setup_timer(&p->timer, br_multicast_port_group_expired,
 		    (unsigned long)p);
-- 
1.8.1.5
