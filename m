From: "Paul E. McKenney" <paulmck@linux.vnet.ibm.com>
Subject: [PATCH tip/core/rcu 04/13] wireless: Apply
	rcu_access_pointer() to avoid sparse false positive
Date: Tue, 24 Sep 2013 18:35:07 -0700
Message-ID: <1380072916-31557-4-git-send-email-paulmck@linux.vnet.ibm.com>
References: <20130925013451.GA31260@linux.vnet.ibm.com>
	<1380072916-31557-1-git-send-email-paulmck@linux.vnet.ibm.com>
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
In-Reply-To: <1380072916-31557-1-git-send-email-paulmck@linux.vnet.ibm.com>
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
cfg80211_combine_bsses() and cfg80211_bss_update() are legitimate:
They is assigning a pointer to an element from an RCU-protected list,
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
 net/wireless/scan.c | 14 +++++++-------
 1 file changed, 7 insertions(+), 7 deletions(-)

diff --git a/net/wireless/scan.c b/net/wireless/scan.c
index eeb7148..edde117 100644
--- a/net/wireless/scan.c
+++ b/net/wireless/scan.c
@@ -671,7 +671,7 @@ static bool cfg80211_combine_bsses(struct cfg80211_registered_device *dev,
 		bss->pub.hidden_beacon_bss = &new->pub;
 		new->refcount += bss->refcount;
 		rcu_assign_pointer(bss->pub.beacon_ies,
-				   new->pub.beacon_ies);
+				   rcu_access_pointer(new->pub.beacon_ies));
 	}
 
 	return true;
@@ -706,10 +706,10 @@ cfg80211_bss_update(struct cfg80211_registered_device *dev,
 			old = rcu_access_pointer(found->pub.proberesp_ies);
 
 			rcu_assign_pointer(found->pub.proberesp_ies,
-					   tmp->pub.proberesp_ies);
+					   rcu_access_pointer(tmp->pub.proberesp_ies));
 			/* Override possible earlier Beacon frame IEs */
 			rcu_assign_pointer(found->pub.ies,
-					   tmp->pub.proberesp_ies);
+					   rcu_access_pointer(tmp->pub.proberesp_ies));
 			if (old)
 				kfree_rcu((struct cfg80211_bss_ies *)old,
 					  rcu_head);
@@ -740,12 +740,12 @@ cfg80211_bss_update(struct cfg80211_registered_device *dev,
 			old = rcu_access_pointer(found->pub.beacon_ies);
 
 			rcu_assign_pointer(found->pub.beacon_ies,
-					   tmp->pub.beacon_ies);
+					   rcu_access_pointer(tmp->pub.beacon_ies));
 
 			/* Override IEs if they were from a beacon before */
 			if (old == rcu_access_pointer(found->pub.ies))
 				rcu_assign_pointer(found->pub.ies,
-						   tmp->pub.beacon_ies);
+						   rcu_access_pointer(tmp->pub.beacon_ies));
 
 			/* Assign beacon IEs to all sub entries */
 			list_for_each_entry(bss, &found->hidden_list,
@@ -756,7 +756,7 @@ cfg80211_bss_update(struct cfg80211_registered_device *dev,
 				WARN_ON(ies != old);
 
 				rcu_assign_pointer(bss->pub.beacon_ies,
-						   tmp->pub.beacon_ies);
+						   rcu_access_pointer(tmp->pub.beacon_ies));
 			}
 
 			if (old)
@@ -804,7 +804,7 @@ cfg80211_bss_update(struct cfg80211_registered_device *dev,
 					 &hidden->hidden_list);
 				hidden->refcount++;
 				rcu_assign_pointer(new->pub.beacon_ies,
-						   hidden->pub.beacon_ies);
+						   rcu_access_pointer(hidden->pub.beacon_ies));
 			}
 		} else {
 			/*
-- 
1.8.1.5
