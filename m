From: "Paul E. McKenney" <paulmck@linux.vnet.ibm.com>
Subject: [PATCH tip/core/rcu 09/14] mac80211: Apply ACCESS_ONCE() to avoid sparse false positive
Date: Fri, 15 Nov 2013 16:40:12 -0800
Message-ID: <1384562417-817-9-git-send-email-paulmck@linux.vnet.ibm.com>
References: <20131116003946.GA316@linux.vnet.ibm.com>
 <1384562417-817-1-git-send-email-paulmck@linux.vnet.ibm.com>
Cc: mingo@kernel.org, laijs@cn.fujitsu.com, dipankar@in.ibm.com,
	akpm@linux-foundation.org, mathieu.desnoyers@efficios.com,
	josh@joshtriplett.org, niv@us.ibm.com, tglx@linutronix.de,
	peterz@infradead.org, rostedt@goodmis.org, dhowells@redhat.com,
	edumazet@google.com, darren@dvhart.com, fweisbec@gmail.com,
	sbw@mit.edu, "Paul E. McKenney" <paulmck@linux.vnet.ibm.com>,
	"John W. Linville" <linville@tuxdriver.com>,
	Johannes Berg <johannes@sipsolutions.net>,
	"David S. Miller" <davem@davemloft.net>,
	linux-wireless@vger.kernel.org, netdev@vger.kernel.org
To: linux-kernel@vger.kernel.org
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <1384562417-817-1-git-send-email-paulmck@linux.vnet.ibm.com>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

From: "Paul E. McKenney" <paulmck@linux.vnet.ibm.com>

The sparse checking for rcu_assign_pointer() was recently upgraded
to reject non-__kernel address spaces.  This also rejects __rcu,
which is almost always the right thing to do.  However, the uses in
sta_info_hash_del() are legitimate: They are assigning a pointer to an
element from an RCU-protected list, and all elements of this list are
already visible to caller.

This commit therefore silences this false positive by laundering the
pointer using ACCESS_ONCE() as suggested by Eric Dumazet and Josh
Triplett.

Reported-by: kbuild test robot <fengguang.wu@intel.com>
Signed-off-by: Paul E. McKenney <paulmck@linux.vnet.ibm.com>
Cc: "John W. Linville" <linville@tuxdriver.com>
Cc: Johannes Berg <johannes@sipsolutions.net>
Cc: "David S. Miller" <davem@davemloft.net>
Cc: linux-wireless@vger.kernel.org
Cc: netdev@vger.kernel.org
---
 net/mac80211/sta_info.c | 7 ++++---
 1 file changed, 4 insertions(+), 3 deletions(-)

diff --git a/net/mac80211/sta_info.c b/net/mac80211/sta_info.c
index aeb967a0aeed..494f03c0831f 100644
--- a/net/mac80211/sta_info.c
+++ b/net/mac80211/sta_info.c
@@ -74,8 +74,8 @@ static int sta_info_hash_del(struct ieee80211_local *local,
 	if (!s)
 		return -ENOENT;
 	if (s == sta) {
-		rcu_assign_pointer(local->sta_hash[STA_HASH(sta->sta.addr)],
-				   s->hnext);
+		/* Both --rcu and visible, so ACCESS_ONCE() is OK. */
+		ACCESS_ONCE(local->sta_hash[STA_HASH(sta->sta.addr)]) = s->hnext;
 		return 0;
 	}
 
@@ -84,7 +84,8 @@ static int sta_info_hash_del(struct ieee80211_local *local,
 		s = rcu_dereference_protected(s->hnext,
 					lockdep_is_held(&local->sta_mtx));
 	if (rcu_access_pointer(s->hnext)) {
-		rcu_assign_pointer(s->hnext, sta->hnext);
+		/* Both --rcu and visible, so ACCESS_ONCE() is OK. */
+		ACCESS_ONCE(s->hnext) = sta->hnext;
 		return 0;
 	}
 
-- 
1.8.1.5
