From: "Paul E. McKenney" <paulmck@linux.vnet.ibm.com>
Subject: [PATCH tip/core/rcu 05/13] decnet: Apply rcu_access_pointer() to avoid sparse false positive
Date: Tue, 24 Sep 2013 18:35:08 -0700
Message-ID: <1380072916-31557-5-git-send-email-paulmck@linux.vnet.ibm.com>
References: <20130925013451.GA31260@linux.vnet.ibm.com>
 <1380072916-31557-1-git-send-email-paulmck@linux.vnet.ibm.com>
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
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <1380072916-31557-1-git-send-email-paulmck@linux.vnet.ibm.com>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

From: "Paul E. McKenney" <paulmck@linux.vnet.ibm.com>

The sparse checking for rcu_assign_pointer() was recently upgraded
to reject non-__kernel address spaces.  This also rejects __rcu,
which is almost always the right thing to do.  However, the use in
dn_insert_route() is legitimate: It is assigning a pointer to an element
from an RCU-protected list, and all elements of this list are already
visible to caller.

This commit therefore silences this false positive by laundering the
pointer using rcu_access_pointer() as suggested by Josh Triplett.

Reported-by: kbuild test robot <fengguang.wu@intel.com>
Signed-off-by: Paul E. McKenney <paulmck@linux.vnet.ibm.com>
Cc: "David S. Miller" <davem@davemloft.net>
Cc: Thomas Graf <tgraf@suug.ch>
Cc: Gao feng <gaofeng@cn.fujitsu.com>
Cc: Stephen Hemminger <shemminger@vyatta.com>
Cc: linux-decnet-user@lists.sourceforge.net
Cc: netdev@vger.kernel.org
---
 net/decnet/dn_route.c | 5 +++--
 1 file changed, 3 insertions(+), 2 deletions(-)

diff --git a/net/decnet/dn_route.c b/net/decnet/dn_route.c
index fe32388..3b1357b 100644
--- a/net/decnet/dn_route.c
+++ b/net/decnet/dn_route.c
@@ -345,7 +345,7 @@ static int dn_insert_route(struct dn_route *rt, unsigned int hash, struct dn_rou
 			/* Put it first */
 			*rthp = rth->dst.dn_next;
 			rcu_assign_pointer(rth->dst.dn_next,
-					   dn_rt_hash_table[hash].chain);
+					   rcu_access_pointer(dn_rt_hash_table[hash].chain));
 			rcu_assign_pointer(dn_rt_hash_table[hash].chain, rth);
 
 			dst_use(&rth->dst, now);
@@ -358,7 +358,8 @@ static int dn_insert_route(struct dn_route *rt, unsigned int hash, struct dn_rou
 		rthp = &rth->dst.dn_next;
 	}
 
-	rcu_assign_pointer(rt->dst.dn_next, dn_rt_hash_table[hash].chain);
+	rcu_assign_pointer(rt->dst.dn_next,
+			   rcu_access_pointer(dn_rt_hash_table[hash].chain));
 	rcu_assign_pointer(dn_rt_hash_table[hash].chain, rt);
 
 	dst_use(&rt->dst, now);
-- 
1.8.1.5
