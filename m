From: "Paul E. McKenney" <paulmck@linux.vnet.ibm.com>
Subject: [PATCH tip/core/rcu 11/47] mac80211: Convert call_rcu() to kfree_rcu(), drop mesh_gate_node_reclaim()
Date: Fri,  3 Feb 2012 17:44:46 -0800
Message-ID: <1328319922-30828-11-git-send-email-paulmck@linux.vnet.ibm.com>
References: <20120204014452.GA29811@linux.vnet.ibm.com>
 <1328319922-30828-1-git-send-email-paulmck@linux.vnet.ibm.com>
Cc: mingo@elte.hu, laijs@cn.fujitsu.com, dipankar@in.ibm.com,
	akpm@linux-foundation.org, mathieu.desnoyers@polymtl.ca,
	josh@joshtriplett.org, niv@us.ibm.com, tglx@linutronix.de,
	peterz@infradead.org, rostedt@goodmis.org, Valdis.Kletnieks@vt.edu,
	dhowells@redhat.com, eric.dumazet@gmail.com, darren@dvhart.com,
	fweisbec@gmail.com, patches@linaro.org,
	"Paul E. McKenney" <paul.mckenney@linaro.org>,
	"Paul E. McKenney" <paulmck@linux.vnet.ibm.com>,
	"John W. Linville" <linville@tuxdriver.com>,
	Johannes Berg <johannes@sipsolutions.net>,
	"David S. Miller" <davem@davemloft.net>,
	linux-wireless@vger.kernel.org, netdev@vger.kernel.org
To: linux-kernel@vger.kernel.org
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <1328319922-30828-1-git-send-email-paulmck@linux.vnet.ibm.com>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

From: "Paul E. McKenney" <paul.mckenney@linaro.org>

The call_rcu() in mesh_gate_del() invokes mesh_gate_node_reclaim(),
which simply calls kfree().  So convert the call_rcu() to kfree_rcu(),
allowing mesh_gate_node_reclaim() to be eliminated.

Signed-off-by: Paul E. McKenney <paul.mckenney@linaro.org>
Signed-off-by: Paul E. McKenney <paulmck@linux.vnet.ibm.com>
Cc: "John W. Linville" <linville@tuxdriver.com>
Cc: Johannes Berg <johannes@sipsolutions.net>
Cc: "David S. Miller" <davem@davemloft.net>
Cc: linux-wireless@vger.kernel.org
Cc: netdev@vger.kernel.org
---
 net/mac80211/mesh_pathtbl.c |    8 +-------
 1 files changed, 1 insertions(+), 7 deletions(-)

diff --git a/net/mac80211/mesh_pathtbl.c b/net/mac80211/mesh_pathtbl.c
index edf167e..30420bc 100644
--- a/net/mac80211/mesh_pathtbl.c
+++ b/net/mac80211/mesh_pathtbl.c
@@ -413,12 +413,6 @@ struct mesh_path *mesh_path_lookup_by_idx(int idx, struct ieee80211_sub_if_data
 	return NULL;
 }
 
-static void mesh_gate_node_reclaim(struct rcu_head *rp)
-{
-	struct mpath_node *node = container_of(rp, struct mpath_node, rcu);
-	kfree(node);
-}
-
 /**
  * mesh_path_add_gate - add the given mpath to a mesh gate to our path table
  * @mpath: gate path to add to table
@@ -479,7 +473,7 @@ static int mesh_gate_del(struct mesh_table *tbl, struct mesh_path *mpath)
 		if (gate->mpath == mpath) {
 			spin_lock_bh(&tbl->gates_lock);
 			hlist_del_rcu(&gate->list);
-			call_rcu(&gate->rcu, mesh_gate_node_reclaim);
+			kfree_rcu(gate, rcu);
 			spin_unlock_bh(&tbl->gates_lock);
 			mpath->sdata->u.mesh.num_gates--;
 			mpath->is_gate = false;
-- 
1.7.8
