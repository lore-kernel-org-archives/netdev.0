From: "Paul E. McKenney" <paulmck@linux.vnet.ibm.com>
Subject: [PATCH tip/core/rcu 11/14] bonding/bond_main: Apply
	ACCESS_ONCE() to avoid sparse false positive
Date: Fri, 15 Nov 2013 16:40:14 -0800
Message-ID: <1384562417-817-11-git-send-email-paulmck@linux.vnet.ibm.com>
References: <20131116003946.GA316@linux.vnet.ibm.com>
	<1384562417-817-1-git-send-email-paulmck@linux.vnet.ibm.com>
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
In-Reply-To: <1384562417-817-1-git-send-email-paulmck@linux.vnet.ibm.com>
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
bond_change_active_slave() and __bond_release_one() are legitimate:
They are assigning a pointer to an element from an RCU-protected list
(or a NULL pointer), and all elements of this list are already visible
to caller.

This commit therefore silences these false positives either by laundering
the pointers using ACCESS_ONCE() as suggested by Eric Dumazet and Josh
Triplett, or by using RCU_INIT_POINTER() for NULL pointer assignments.

Reported-by: kbuild test robot <fengguang.wu@intel.com>
Signed-off-by: Paul E. McKenney <paulmck@linux.vnet.ibm.com>
Cc: Stephen Hemminger <stephen@networkplumber.org>
Cc: "David S. Miller" <davem@davemloft.net>
Cc: bridge@lists.linux-foundation.org
Cc: netdev@vger.kernel.org
---
 drivers/net/bonding/bond_main.c | 5 +++--
 1 file changed, 3 insertions(+), 2 deletions(-)

diff --git a/drivers/net/bonding/bond_main.c b/drivers/net/bonding/bond_main.c
index 72df399c4ab3..bbd7fd3e46fe 100644
--- a/drivers/net/bonding/bond_main.c
+++ b/drivers/net/bonding/bond_main.c
@@ -890,7 +890,8 @@ void bond_change_active_slave(struct bonding *bond, struct slave *new_active)
 		if (new_active)
 			bond_set_slave_active_flags(new_active);
 	} else {
-		rcu_assign_pointer(bond->curr_active_slave, new_active);
+		/* Both --rcu and visible, so ACCESS_ONCE() is OK. */
+		ACCESS_ONCE(bond->curr_active_slave) = new_active;
 	}
 
 	if (bond->params.mode == BOND_MODE_ACTIVEBACKUP) {
@@ -1801,7 +1802,7 @@ static int __bond_release_one(struct net_device *bond_dev,
 	}
 
 	if (all) {
-		rcu_assign_pointer(bond->curr_active_slave, NULL);
+		RCU_INIT_POINTER(bond->curr_active_slave, NULL);
 	} else if (oldcurrent == slave) {
 		/*
 		 * Note that we hold RTNL over this sequence, so there
-- 
1.8.1.5
