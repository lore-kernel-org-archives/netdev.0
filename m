From: "Paul E. McKenney" <paulmck@linux.vnet.ibm.com>
Subject: [PATCH v2 tip/core/rcu 04/13] wireless: Apply rcu_access_pointer() to avoid sparse false positive
Date: Wed,  9 Oct 2013 14:29:37 -0700
Message-ID: <1381354186-16285-4-git-send-email-paulmck@linux.vnet.ibm.com>
References: <20131009212920.GA15413@linux.vnet.ibm.com>
 <1381354186-16285-1-git-send-email-paulmck@linux.vnet.ibm.com>
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
Received: from e35.co.us.ibm.com ([32.97.110.153]:48362 "EHLO
	e35.co.us.ibm.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1756728Ab3JIVa2 (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 9 Oct 2013 17:30:28 -0400
Received: from /spool/local
	by e35.co.us.ibm.com with IBM ESMTP SMTP Gateway: Authorized Use Only! Violators will be prosecuted
	for <netdev@vger.kernel.org> from <paulmck@linux.vnet.ibm.com>;
	Wed, 9 Oct 2013 15:29:59 -0600
In-Reply-To: <1381354186-16285-1-git-send-email-paulmck@linux.vnet.ibm.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: "Paul E. McKenney" <paulmck@linux.vnet.ibm.com>

The sparse checking for rcu_assign_pointer() was recently upgraded
to reject non-__kernel address spaces.  This also rejects __rcu,
which is almost always the right thing to do.  However, the uses in
cfg80211_combine_bsses() and cfg80211_bss_update() are legitimate:
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
 net/wireless/scan.c | 14 +++++++-------
 1 file changed, 7 insertions(+), 7 deletions(-)

diff --git a/net/wireless/scan.c b/net/wireless/scan.c
index eeb71480f1af..edde117c1863 100644
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
