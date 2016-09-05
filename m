From: Pablo Neira Ayuso <pablo@netfilter.org>
Subject: [PATCH 22/29] netfilter: don't rely on DYING bit to detect when destroy event was sent
Date: Mon,  5 Sep 2016 12:58:37 +0200
Message-ID: <1473073124-5015-23-git-send-email-pablo@netfilter.org>
References: <1473073124-5015-1-git-send-email-pablo@netfilter.org>
Cc: davem@davemloft.net, netdev@vger.kernel.org
To: netfilter-devel@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail.us.es ([193.147.175.20]:35198 "EHLO mail.us.es"
        rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
        id S933474AbcIEK7Q (ORCPT <rfc822;netdev@vger.kernel.org>);
        Mon, 5 Sep 2016 06:59:16 -0400
Received: from antivirus1-rhel7.int (unknown [192.168.2.11])
        by mail.us.es (Postfix) with ESMTP id 305D82EFEB9
        for <netdev@vger.kernel.org>; Mon,  5 Sep 2016 12:59:15 +0200 (CEST)
Received: from antivirus1-rhel7.int (localhost [127.0.0.1])
        by antivirus1-rhel7.int (Postfix) with ESMTP id 1FF7F32CD
        for <netdev@vger.kernel.org>; Mon,  5 Sep 2016 12:59:15 +0200 (CEST)
Received: from antivirus1-rhel7.int (localhost [127.0.0.1])
        by antivirus1-rhel7.int (Postfix) with ESMTP id C37E41150C9
        for <netdev@vger.kernel.org>; Mon,  5 Sep 2016 12:59:12 +0200 (CEST)
In-Reply-To: <1473073124-5015-1-git-send-email-pablo@netfilter.org>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Florian Westphal <fw@strlen.de>

The reliable event delivery mode currently (ab)uses the DYING bit to
detect which entries on the dying list have to be skipped when
re-delivering events from the eache worker in reliable event mode.

Currently when we delete the conntrack from main table we only set this
bit if we could also deliver the netlink destroy event to userspace.

If we fail we move it to the dying list, the ecache worker will
reattempt event delivery for all confirmed conntracks on the dying list
that do not have the DYING bit set.

Once timer is gone, we can no longer use if (del_timer()) to detect
when we 'stole' the reference count owned by the timer/hash entry, so
we need some other way to avoid racing with other cpu.

Pablo suggested to add a marker in the ecache extension that skips
entries that have been unhashed from main table but are still waiting
for the last reference count to be dropped (e.g. because one skb waiting
on nfqueue verdict still holds a reference).

We do this by adding a tristate.
If we fail to deliver the destroy event, make a note of this in the
eache extension.  The worker can then skip all entries that are in
a different state.  Either they never delivered a destroy event,
e.g. because the netlink backend was not loaded, or redelivery took
place already.

Once the conntrack timer is removed we will now be able to replace
del_timer() test with test_and_set_bit(DYING, &ct->status) to avoid
racing with other cpu that tries to evict the same conntrack.

Because DYING will then be set right before we report the destroy event
we can no longer skip event reporting when dying bit is set.

Suggested-by: Pablo Neira Ayuso <pablo@netfilter.org>
Signed-off-by: Florian Westphal <fw@strlen.de>
Acked-by: Eric Dumazet <edumazet@google.com>
Signed-off-by: Pablo Neira Ayuso <pablo@netfilter.org>
---
 include/net/netfilter/nf_conntrack_ecache.h | 17 ++++++++++++-----
 net/netfilter/nf_conntrack_ecache.c         | 22 ++++++++++++++--------
 2 files changed, 26 insertions(+), 13 deletions(-)

diff --git a/include/net/netfilter/nf_conntrack_ecache.h b/include/net/netfilter/nf_conntrack_ecache.h
index fa36447..12d967b 100644
--- a/include/net/netfilter/nf_conntrack_ecache.h
+++ b/include/net/netfilter/nf_conntrack_ecache.h
@@ -12,12 +12,19 @@
 #include <linux/netfilter/nf_conntrack_tuple_common.h>
 #include <net/netfilter/nf_conntrack_extend.h>
 
+enum nf_ct_ecache_state {
+	NFCT_ECACHE_UNKNOWN,		/* destroy event not sent */
+	NFCT_ECACHE_DESTROY_FAIL,	/* tried but failed to send destroy event */
+	NFCT_ECACHE_DESTROY_SENT,	/* sent destroy event after failure */
+};
+
 struct nf_conntrack_ecache {
-	unsigned long cache;	/* bitops want long */
-	unsigned long missed;	/* missed events */
-	u16 ctmask;		/* bitmask of ct events to be delivered */
-	u16 expmask;		/* bitmask of expect events to be delivered */
-	u32 portid;		/* netlink portid of destroyer */
+	unsigned long cache;		/* bitops want long */
+	unsigned long missed;		/* missed events */
+	u16 ctmask;			/* bitmask of ct events to be delivered */
+	u16 expmask;			/* bitmask of expect events to be delivered */
+	u32 portid;			/* netlink portid of destroyer */
+	enum nf_ct_ecache_state state;	/* ecache state */
 };
 
 static inline struct nf_conntrack_ecache *
diff --git a/net/netfilter/nf_conntrack_ecache.c b/net/netfilter/nf_conntrack_ecache.c
index d28011b..da9df2d 100644
--- a/net/netfilter/nf_conntrack_ecache.c
+++ b/net/netfilter/nf_conntrack_ecache.c
@@ -49,8 +49,13 @@ static enum retry_state ecache_work_evict_list(struct ct_pcpu *pcpu)
 
 	hlist_nulls_for_each_entry(h, n, &pcpu->dying, hnnode) {
 		struct nf_conn *ct = nf_ct_tuplehash_to_ctrack(h);
+		struct nf_conntrack_ecache *e;
 
-		if (nf_ct_is_dying(ct))
+		if (!nf_ct_is_confirmed(ct))
+			continue;
+
+		e = nf_ct_ecache_find(ct);
+		if (!e || e->state != NFCT_ECACHE_DESTROY_FAIL)
 			continue;
 
 		if (nf_conntrack_event(IPCT_DESTROY, ct)) {
@@ -58,8 +63,7 @@ static enum retry_state ecache_work_evict_list(struct ct_pcpu *pcpu)
 			break;
 		}
 
-		/* we've got the event delivered, now it's dying */
-		set_bit(IPS_DYING_BIT, &ct->status);
+		e->state = NFCT_ECACHE_DESTROY_SENT;
 		refs[evicted] = ct;
 
 		if (++evicted >= ARRAY_SIZE(refs)) {
@@ -130,7 +134,7 @@ int nf_conntrack_eventmask_report(unsigned int eventmask, struct nf_conn *ct,
 	if (!e)
 		goto out_unlock;
 
-	if (nf_ct_is_confirmed(ct) && !nf_ct_is_dying(ct)) {
+	if (nf_ct_is_confirmed(ct)) {
 		struct nf_ct_event item = {
 			.ct	= ct,
 			.portid	= e->portid ? e->portid : portid,
@@ -150,11 +154,13 @@ int nf_conntrack_eventmask_report(unsigned int eventmask, struct nf_conn *ct,
 				 * triggered by a process, we store the PORTID
 				 * to include it in the retransmission.
 				 */
-				if (eventmask & (1 << IPCT_DESTROY) &&
-				    e->portid == 0 && portid != 0)
-					e->portid = portid;
-				else
+				if (eventmask & (1 << IPCT_DESTROY)) {
+					if (e->portid == 0 && portid != 0)
+						e->portid = portid;
+					e->state = NFCT_ECACHE_DESTROY_FAIL;
+				} else {
 					e->missed |= eventmask;
+				}
 			} else {
 				e->missed &= ~missed;
 			}
-- 
2.1.4
