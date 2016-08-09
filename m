From: Florian Westphal <fw@strlen.de>
Subject: [PATCH net-next 6/6] xfrm: state: don't use lock anymore unless acquire operation is needed
Date: Tue,  9 Aug 2016 12:16:09 +0200
Message-ID: <1470737769-30438-7-git-send-email-fw@strlen.de>
References: <1470737769-30438-1-git-send-email-fw@strlen.de>
Cc: Florian Westphal <fw@strlen.de>
To: <netdev@vger.kernel.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from Chamillionaire.breakpoint.cc ([146.0.238.67]:43914 "EHLO
	Chamillionaire.breakpoint.cc" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with ESMTP id S1751914AbcHIKQf (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 9 Aug 2016 06:16:35 -0400
In-Reply-To: <1470737769-30438-1-git-send-email-fw@strlen.de>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

push the lock down, after earlier patches we can rely on rcu to
make sure state struct won't go away.

Signed-off-by: Florian Westphal <fw@strlen.de>
---
 include/net/netns/xfrm.h | 6 +++---
 net/xfrm/xfrm_state.c    | 6 ++++--
 2 files changed, 7 insertions(+), 5 deletions(-)

diff --git a/include/net/netns/xfrm.h b/include/net/netns/xfrm.h
index 24cd394..1ab51d1 100644
--- a/include/net/netns/xfrm.h
+++ b/include/net/netns/xfrm.h
@@ -38,9 +38,9 @@ struct netns_xfrm {
 	 * mode. Also, it can be used by ah/esp icmp error handler to find
 	 * offending SA.
 	 */
-	struct hlist_head	*state_bydst;
-	struct hlist_head	*state_bysrc;
-	struct hlist_head	*state_byspi;
+	struct hlist_head	__rcu *state_bydst;
+	struct hlist_head	__rcu *state_bysrc;
+	struct hlist_head	__rcu *state_byspi;
 	unsigned int		state_hmask;
 	unsigned int		state_num;
 	struct work_struct	state_hash_work;
diff --git a/net/xfrm/xfrm_state.c b/net/xfrm/xfrm_state.c
index 53e7867..1a15b65 100644
--- a/net/xfrm/xfrm_state.c
+++ b/net/xfrm/xfrm_state.c
@@ -799,7 +799,7 @@ xfrm_state_find(const xfrm_address_t *daddr, const xfrm_address_t *saddr,
 
 	sequence = read_seqcount_begin(&xfrm_state_hash_generation);
 
-	spin_lock_bh(&net->xfrm.xfrm_state_lock);
+	rcu_read_lock();
 	h = xfrm_dst_hash(net, daddr, saddr, tmpl->reqid, encap_family);
 	hlist_for_each_entry_rcu(x, net->xfrm.state_bydst + h, bydst) {
 		if (x->props.family == encap_family &&
@@ -870,6 +870,7 @@ found:
 		}
 
 		if (km_query(x, tmpl, pol) == 0) {
+			spin_lock_bh(&net->xfrm.xfrm_state_lock);
 			x->km.state = XFRM_STATE_ACQ;
 			list_add(&x->km.all, &net->xfrm.state_all);
 			hlist_add_head_rcu(&x->bydst, net->xfrm.state_bydst + h);
@@ -883,6 +884,7 @@ found:
 			tasklet_hrtimer_start(&x->mtimer, ktime_set(net->xfrm.sysctl_acq_expires, 0), HRTIMER_MODE_REL);
 			net->xfrm.state_num++;
 			xfrm_hash_grow_check(net, x->bydst.next != NULL);
+			spin_unlock_bh(&net->xfrm.xfrm_state_lock);
 		} else {
 			x->km.state = XFRM_STATE_DEAD;
 			to_put = x;
@@ -899,7 +901,7 @@ out:
 	} else {
 		*err = acquire_in_progress ? -EAGAIN : error;
 	}
-	spin_unlock_bh(&net->xfrm.xfrm_state_lock);
+	rcu_read_unlock();
 	if (to_put)
 		xfrm_state_put(to_put);
 
-- 
2.7.3
