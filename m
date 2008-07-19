From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH 20/31]: pkt_sched: Perform bulk of qdisc destruction in
 RCU.
Date: Fri, 18 Jul 2008 20:59:02 -0700 (PDT)
Message-ID: <20080718.205902.180487935.davem@davemloft.net>
References: <20080717.051726.226040470.davem@davemloft.net>
	<487F4327.1000107@trash.net>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, johannes@sipsolutions.net,
	linux-wireless@vger.kernel.org
To: kaber@trash.net
Return-path: <netdev-owner@vger.kernel.org>
Received: from 74-93-104-97-Washington.hfc.comcastbusiness.net ([74.93.104.97]:51774
	"EHLO sunset.davemloft.net" rhost-flags-OK-FAIL-OK-OK)
	by vger.kernel.org with ESMTP id S1750736AbYGSD7E (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 18 Jul 2008 23:59:04 -0400
In-Reply-To: <487F4327.1000107@trash.net>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Patrick McHardy <kaber@trash.net>
Date: Thu, 17 Jul 2008 15:03:35 +0200

> The remaining problem is data that was previously only used and
> modified under the RTNL (u32_list is one example). Modifications
> during destruction now need protection against concurrent use in
> process context.

I took a closer look at u32_list.

It's members seem to be keyed by qdisc :-)

All this thing is doing is making up for the lack of a classifier
private pointer in the Qdisc.

It's tough because classifiers of different types can be queued
up to a qdisc, so it's not like we can add one traffic classifier
private pointer to struct Qdisc and be done with it.

However, I could not find anything other than u32 that seems to need
some global state that works like this.

So what I've done is checked in the following change for now to make
u32 delete operation safe entirely within a qdisc tree's namespace.

pkt_sched: Get rid of u32_list.

The u32_list is just an indirect way of maintaining a reference
to a U32 node on a per-qdisc basis.

Just add an explicit node pointer for u32 to struct Qdisc an do
away with this global list.

Signed-off-by: David S. Miller <davem@davemloft.net>

diff --git a/include/net/sch_generic.h b/include/net/sch_generic.h
index 0a158ff..8a44386 100644
--- a/include/net/sch_generic.h
+++ b/include/net/sch_generic.h
@@ -56,6 +56,8 @@ struct Qdisc
 	int			(*reshape_fail)(struct sk_buff *skb,
 					struct Qdisc *q);
 
+	void			*u32_node;
+
 	/* This field is deprecated, but it is still used by CBQ
 	 * and it will live until better solution will be invented.
 	 */
diff --git a/net/sched/cls_u32.c b/net/sched/cls_u32.c
index 4d75544..527db25 100644
--- a/net/sched/cls_u32.c
+++ b/net/sched/cls_u32.c
@@ -75,7 +75,6 @@ struct tc_u_hnode
 
 struct tc_u_common
 {
-	struct tc_u_common	*next;
 	struct tc_u_hnode	*hlist;
 	struct Qdisc		*q;
 	int			refcnt;
@@ -87,8 +86,6 @@ static const struct tcf_ext_map u32_ext_map = {
 	.police = TCA_U32_POLICE
 };
 
-static struct tc_u_common *u32_list;
-
 static __inline__ unsigned u32_hash_fold(__be32 key, struct tc_u32_sel *sel, u8 fshift)
 {
 	unsigned h = ntohl(key & sel->hmask)>>fshift;
@@ -287,9 +284,7 @@ static int u32_init(struct tcf_proto *tp)
 	struct tc_u_hnode *root_ht;
 	struct tc_u_common *tp_c;
 
-	for (tp_c = u32_list; tp_c; tp_c = tp_c->next)
-		if (tp_c->q == tp->q)
-			break;
+	tp_c = tp->q->u32_node;
 
 	root_ht = kzalloc(sizeof(*root_ht), GFP_KERNEL);
 	if (root_ht == NULL)
@@ -307,8 +302,7 @@ static int u32_init(struct tcf_proto *tp)
 			return -ENOBUFS;
 		}
 		tp_c->q = tp->q;
-		tp_c->next = u32_list;
-		u32_list = tp_c;
+		tp->q->u32_node = tp_c;
 	}
 
 	tp_c->refcnt++;
@@ -402,14 +396,8 @@ static void u32_destroy(struct tcf_proto *tp)
 
 	if (--tp_c->refcnt == 0) {
 		struct tc_u_hnode *ht;
-		struct tc_u_common **tp_cp;
 
-		for (tp_cp = &u32_list; *tp_cp; tp_cp = &(*tp_cp)->next) {
-			if (*tp_cp == tp_c) {
-				*tp_cp = tp_c->next;
-				break;
-			}
-		}
+		tp->q->u32_node = NULL;
 
 		for (ht = tp_c->hlist; ht; ht = ht->next) {
 			ht->refcnt--;
