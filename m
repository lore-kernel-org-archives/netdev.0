From: "Paul E. McKenney" <paulmck@linux.vnet.ibm.com>
Subject: [PATCH tip/core/rcu 04/14] decnet: Apply ACCESS_ONCE() to avoid sparse false positive
Date: Fri, 15 Nov 2013 16:40:07 -0800
Message-ID: <1384562417-817-4-git-send-email-paulmck@linux.vnet.ibm.com>
References: <20131116003946.GA316@linux.vnet.ibm.com>
 <1384562417-817-1-git-send-email-paulmck@linux.vnet.ibm.com>
Cc: mingo@kernel.org, laijs@cn.fujitsu.com, dipankar@in.ibm.com,
	akpm@linux-foundation.org, mathieu.desnoyers@efficios.com,
	josh@joshtriplett.org, niv@us.ibm.com, tglx@linutronix.de,
	peterz@infradead.org, rostedt@goodmis.org, dhowells@redhat.com,
	edumazet@google.com, darren@dvhart.com, fweisbec@gmail.com,
	sbw@mit.edu, "Paul E. McKenney" <paulmck@linux.vnet.ibm.com>,
	"David S. Miller" <davem@davemloft.net>,
	Thomas Graf <tgraf@suug.ch>, Gao feng <gaofeng@cn.fujitsu.com>,
	Stephen Hemminger <shemminger@vyatta.com>,
	linux-decnet-user@lists.sourceforge.net, netdev@vger.kernel.org
To: linux-kernel@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from e32.co.us.ibm.com ([32.97.110.150]:41137 "EHLO
	e32.co.us.ibm.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1754109Ab3KPAke (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 15 Nov 2013 19:40:34 -0500
Received: from /spool/local
	by e32.co.us.ibm.com with IBM ESMTP SMTP Gateway: Authorized Use Only! Violators will be prosecuted
	for <netdev@vger.kernel.org> from <paulmck@linux.vnet.ibm.com>;
	Fri, 15 Nov 2013 17:40:34 -0700
In-Reply-To: <1384562417-817-1-git-send-email-paulmck@linux.vnet.ibm.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: "Paul E. McKenney" <paulmck@linux.vnet.ibm.com>

The sparse checking for rcu_assign_pointer() was recently upgraded
to reject non-__kernel address spaces.  This also rejects __rcu,
which is almost always the right thing to do.  However, the use in
dn_insert_route() is legitimate: It is assigning a pointer to an element
from an RCU-protected list, and all elements of this list are already
visible to caller.

This commit therefore silences this false positive by laundering the
pointer using ACCESS_ONCE() as suggested by Eric Dumazet and Josh
Triplett.

Reported-by: kbuild test robot <fengguang.wu@intel.com>
Signed-off-by: Paul E. McKenney <paulmck@linux.vnet.ibm.com>
Cc: "David S. Miller" <davem@davemloft.net>
Cc: Thomas Graf <tgraf@suug.ch>
Cc: Gao feng <gaofeng@cn.fujitsu.com>
Cc: Stephen Hemminger <shemminger@vyatta.com>
Cc: linux-decnet-user@lists.sourceforge.net
Cc: netdev@vger.kernel.org
---
 net/decnet/dn_route.c | 8 +++++---
 1 file changed, 5 insertions(+), 3 deletions(-)

diff --git a/net/decnet/dn_route.c b/net/decnet/dn_route.c
index fe32388ea24f..a6ef8b025035 100644
--- a/net/decnet/dn_route.c
+++ b/net/decnet/dn_route.c
@@ -344,8 +344,9 @@ static int dn_insert_route(struct dn_route *rt, unsigned int hash, struct dn_rou
 		if (compare_keys(&rth->fld, &rt->fld)) {
 			/* Put it first */
 			*rthp = rth->dst.dn_next;
-			rcu_assign_pointer(rth->dst.dn_next,
-					   dn_rt_hash_table[hash].chain);
+			/* Both --rcu and visible, so ACCESS_ONCE() is OK. */
+			ACCESS_ONCE(rth->dst.dn_next) =
+					   dn_rt_hash_table[hash].chain;
 			rcu_assign_pointer(dn_rt_hash_table[hash].chain, rth);
 
 			dst_use(&rth->dst, now);
@@ -358,7 +359,8 @@ static int dn_insert_route(struct dn_route *rt, unsigned int hash, struct dn_rou
 		rthp = &rth->dst.dn_next;
 	}
 
-	rcu_assign_pointer(rt->dst.dn_next, dn_rt_hash_table[hash].chain);
+	/* Both --rcu and visible, so ACCESS_ONCE() is OK. */
+	ACCESS_ONCE(rt->dst.dn_next) = dn_rt_hash_table[hash].chain;
 	rcu_assign_pointer(dn_rt_hash_table[hash].chain, rt);
 
 	dst_use(&rt->dst, now);
-- 
1.8.1.5
