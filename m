From: Florian Westphal <fw@strlen.de>
Subject: [PATCH net-next 4/6] xfrm: state: add sequence count to detect hash resizes
Date: Tue,  9 Aug 2016 12:16:07 +0200
Message-ID: <1470737769-30438-5-git-send-email-fw@strlen.de>
References: <1470737769-30438-1-git-send-email-fw@strlen.de>
Cc: Florian Westphal <fw@strlen.de>
To: <netdev@vger.kernel.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from Chamillionaire.breakpoint.cc ([146.0.238.67]:43910 "EHLO
	Chamillionaire.breakpoint.cc" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with ESMTP id S1751596AbcHIKQf (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 9 Aug 2016 06:16:35 -0400
In-Reply-To: <1470737769-30438-1-git-send-email-fw@strlen.de>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Once xfrm_state_find is lockless we have to cope with a concurrent
resize opertion.

We use a sequence counter to block in case a resize is in progress
and to detect if we might have missed a state that got moved to
a new hash table.

Signed-off-by: Florian Westphal <fw@strlen.de>
---
 net/xfrm/xfrm_state.c | 15 +++++++++++++++
 1 file changed, 15 insertions(+)

diff --git a/net/xfrm/xfrm_state.c b/net/xfrm/xfrm_state.c
index 8e37387..ac4037c 100644
--- a/net/xfrm/xfrm_state.c
+++ b/net/xfrm/xfrm_state.c
@@ -36,6 +36,7 @@
  */
 
 static unsigned int xfrm_state_hashmax __read_mostly = 1 * 1024 * 1024;
+static __read_mostly seqcount_t xfrm_state_hash_generation = SEQCNT_ZERO(xfrm_state_hash_generation);
 
 static inline bool xfrm_state_hold_rcu(struct xfrm_state __rcu *x)
 {
@@ -127,6 +128,7 @@ static void xfrm_hash_resize(struct work_struct *work)
 	}
 
 	spin_lock_bh(&net->xfrm.xfrm_state_lock);
+	write_seqcount_begin(&xfrm_state_hash_generation);
 
 	nhashmask = (nsize / sizeof(struct hlist_head)) - 1U;
 	for (i = net->xfrm.state_hmask; i >= 0; i--)
@@ -143,6 +145,7 @@ static void xfrm_hash_resize(struct work_struct *work)
 	net->xfrm.state_byspi = nspi;
 	net->xfrm.state_hmask = nhashmask;
 
+	write_seqcount_end(&xfrm_state_hash_generation);
 	spin_unlock_bh(&net->xfrm.xfrm_state_lock);
 
 	osize = (ohashmask + 1) * sizeof(struct hlist_head);
@@ -787,10 +790,13 @@ xfrm_state_find(const xfrm_address_t *daddr, const xfrm_address_t *saddr,
 	struct xfrm_state *best = NULL;
 	u32 mark = pol->mark.v & pol->mark.m;
 	unsigned short encap_family = tmpl->encap_family;
+	unsigned int sequence;
 	struct km_event c;
 
 	to_put = NULL;
 
+	sequence = read_seqcount_begin(&xfrm_state_hash_generation);
+
 	spin_lock_bh(&net->xfrm.xfrm_state_lock);
 	h = xfrm_dst_hash(net, daddr, saddr, tmpl->reqid, encap_family);
 	hlist_for_each_entry_rcu(x, net->xfrm.state_bydst + h, bydst) {
@@ -894,6 +900,15 @@ out:
 	spin_unlock_bh(&net->xfrm.xfrm_state_lock);
 	if (to_put)
 		xfrm_state_put(to_put);
+
+	if (read_seqcount_retry(&xfrm_state_hash_generation, sequence)) {
+		*err = -EAGAIN;
+		if (x) {
+			xfrm_state_put(x);
+			x = NULL;
+		}
+	}
+
 	return x;
 }
 
-- 
2.7.3
