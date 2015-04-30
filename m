From: Florian Westphal <fw@strlen.de>
Subject: [PATCH -next] net: sched: remove TC_MUNGED bits
Date: Thu, 30 Apr 2015 12:12:00 +0200
Message-ID: <1430388720-5112-1-git-send-email-fw@strlen.de>
Cc: Florian Westphal <fw@strlen.de>
To: <netdev@vger.kernel.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from Chamillionaire.breakpoint.cc ([80.244.247.6]:38731 "EHLO
	Chamillionaire.breakpoint.cc" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with ESMTP id S1750933AbbD3KMJ (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 30 Apr 2015 06:12:09 -0400
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Not used.

pedit sets TC_MUNGED when packet content was altered, but all the core
does is unset MUNGED again and then set OK2MUNGE.

And the latter isn't tested anywhere. So lets remove both
TC_MUNGED and TC_OK2MUNGE.

Signed-off-by: Florian Westphal <fw@strlen.de>
---
 This is part of a (larger) patchset to dissect tc_verd to determine
 which parts of the state/information kept therein is required.

 I will send the other changes if this one is accepted.

 Documentation/networking/tc-actions-env-rules.txt | 2 --
 include/net/sch_generic.h                         | 2 --
 include/uapi/linux/pkt_cls.h                      | 3 +++
 net/sched/act_api.c                               | 5 -----
 net/sched/act_pedit.c                             | 5 +----
 5 files changed, 4 insertions(+), 13 deletions(-)

diff --git a/Documentation/networking/tc-actions-env-rules.txt b/Documentation/networking/tc-actions-env-rules.txt
index 70d6cf6..95c7171 100644
--- a/Documentation/networking/tc-actions-env-rules.txt
+++ b/Documentation/networking/tc-actions-env-rules.txt
@@ -14,8 +14,6 @@ resets them for you, so invoke skb_act_clone() rather than skb_clone().
 
 2) If you munge any packet thou shalt call pskb_expand_head in the case
 someone else is referencing the skb. After that you "own" the skb.
-You must also tell us if it is ok to munge the packet (TC_OK2MUNGE),
-this way any action downstream can stomp on the packet.
 
 3) Dropping packets you don't own is a no-no. You simply return
 TC_ACT_SHOT to the caller and they will drop it.
diff --git a/include/net/sch_generic.h b/include/net/sch_generic.h
index 6d778ef..994b5a0 100644
--- a/include/net/sch_generic.h
+++ b/include/net/sch_generic.h
@@ -755,8 +755,6 @@ static inline struct sk_buff *skb_act_clone(struct sk_buff *skb, gfp_t gfp_mask,
 
 	if (n) {
 		n->tc_verd = SET_TC_VERD(n->tc_verd, 0);
-		n->tc_verd = CLR_TC_OK2MUNGE(n->tc_verd);
-		n->tc_verd = CLR_TC_MUNGED(n->tc_verd);
 	}
 	return n;
 }
diff --git a/include/uapi/linux/pkt_cls.h b/include/uapi/linux/pkt_cls.h
index bf08e76..6810ca4 100644
--- a/include/uapi/linux/pkt_cls.h
+++ b/include/uapi/linux/pkt_cls.h
@@ -35,6 +35,8 @@ bits 9,10,11: redirect counter -  redirect TTL. Loop avoidance
  *
  * */
 
+#ifndef __KERNEL__
+/* backwards compat for userspace only */
 #define TC_MUNGED          _TC_MAKEMASK1(0)
 #define SET_TC_MUNGED(v)   ( TC_MUNGED | (v & ~TC_MUNGED))
 #define CLR_TC_MUNGED(v)   ( v & ~TC_MUNGED)
@@ -42,6 +44,7 @@ bits 9,10,11: redirect counter -  redirect TTL. Loop avoidance
 #define TC_OK2MUNGE        _TC_MAKEMASK1(1)
 #define SET_TC_OK2MUNGE(v)   ( TC_OK2MUNGE | (v & ~TC_OK2MUNGE))
 #define CLR_TC_OK2MUNGE(v)   ( v & ~TC_OK2MUNGE)
+#endif
 
 #define S_TC_VERD          _TC_MAKE32(2)
 #define M_TC_VERD          _TC_MAKEMASK(4,S_TC_VERD)
diff --git a/net/sched/act_api.c b/net/sched/act_api.c
index 3d43e49..af427a3 100644
--- a/net/sched/act_api.c
+++ b/net/sched/act_api.c
@@ -392,11 +392,6 @@ int tcf_action_exec(struct sk_buff *skb, const struct list_head *actions,
 	list_for_each_entry(a, actions, list) {
 repeat:
 		ret = a->ops->act(skb, a, res);
-		if (TC_MUNGED & skb->tc_verd) {
-			/* copied already, allow trampling */
-			skb->tc_verd = SET_TC_OK2MUNGE(skb->tc_verd);
-			skb->tc_verd = CLR_TC_MUNGED(skb->tc_verd);
-		}
 		if (ret == TC_ACT_REPEAT)
 			goto repeat;	/* we need a ttl - JHS */
 		if (ret != TC_ACT_PIPE)
diff --git a/net/sched/act_pedit.c b/net/sched/act_pedit.c
index 59649d5..17e6d66 100644
--- a/net/sched/act_pedit.c
+++ b/net/sched/act_pedit.c
@@ -108,7 +108,7 @@ static int tcf_pedit(struct sk_buff *skb, const struct tc_action *a,
 		     struct tcf_result *res)
 {
 	struct tcf_pedit *p = a->priv;
-	int i, munged = 0;
+	int i;
 	unsigned int off;
 
 	if (skb_unclone(skb, GFP_ATOMIC))
@@ -156,11 +156,8 @@ static int tcf_pedit(struct sk_buff *skb, const struct tc_action *a,
 			*ptr = ((*ptr & tkey->mask) ^ tkey->val);
 			if (ptr == &_data)
 				skb_store_bits(skb, off + offset, ptr, 4);
-			munged++;
 		}
 
-		if (munged)
-			skb->tc_verd = SET_TC_MUNGED(skb->tc_verd);
 		goto done;
 	} else
 		WARN(1, "pedit BUG: index %d\n", p->tcf_index);
-- 
2.0.5
