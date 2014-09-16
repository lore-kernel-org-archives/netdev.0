From: John Fastabend <john.fastabend@gmail.com>
Subject: [net-next PATCH 2/3] net: sched: cls_u32 add missing
 rcu_assign_pointer and annotation
Date: Mon, 15 Sep 2014 19:48:01 -0700
Message-ID: <20140916024759.3010.24175.stgit@nitbit.x32>
References: <20140916024729.3010.47421.stgit@nitbit.x32>
Mime-Version: 1.0
Content-Type: text/plain; charset="utf-8"
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, jhs@mojatatu.com
To: xiyou.wangcong@gmail.com, davem@davemloft.net,
	eric.dumazet@gmail.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-oa0-f54.google.com ([209.85.219.54]:37889 "EHLO
	mail-oa0-f54.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1753051AbaIPCsb (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 15 Sep 2014 22:48:31 -0400
Received: by mail-oa0-f54.google.com with SMTP id jd19so3285268oac.27
        for <netdev@vger.kernel.org>; Mon, 15 Sep 2014 19:48:26 -0700 (PDT)
In-Reply-To: <20140916024729.3010.47421.stgit@nitbit.x32>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Add missing rcu_assign_pointer and missing  annotation for ht_up
in cls_u32.c

Caught by kbuild bot,

>> net/sched/cls_u32.c:378:36: sparse: incorrect type in initializer (different address spaces)
   net/sched/cls_u32.c:378:36:    expected struct tc_u_hnode *ht
   net/sched/cls_u32.c:378:36:    got struct tc_u_hnode [noderef] <asn:4>*ht_up
>> net/sched/cls_u32.c:610:54: sparse: incorrect type in argument 4 (different address spaces)
   net/sched/cls_u32.c:610:54:    expected struct tc_u_hnode *ht
   net/sched/cls_u32.c:610:54:    got struct tc_u_hnode [noderef] <asn:4>*ht_up
>> net/sched/cls_u32.c:684:18: sparse: incorrect type in assignment (different address spaces)
   net/sched/cls_u32.c:684:18:    expected struct tc_u_hnode [noderef] <asn:4>*ht_up
   net/sched/cls_u32.c:684:18:    got struct tc_u_hnode *[assigned] ht
>> net/sched/cls_u32.c:359:18: sparse: dereference of noderef expression

Signed-off-by: John Fastabend <john.r.fastabend@intel.com>
---
 net/sched/cls_u32.c |    7 ++++---
 1 file changed, 4 insertions(+), 3 deletions(-)

diff --git a/net/sched/cls_u32.c b/net/sched/cls_u32.c
index 8cffe5a..19b2808 100644
--- a/net/sched/cls_u32.c
+++ b/net/sched/cls_u32.c
@@ -375,7 +375,7 @@ static int u32_delete_key(struct tcf_proto *tp, struct tc_u_knode *key)
 {
 	struct tc_u_knode __rcu **kp;
 	struct tc_u_knode *pkp;
-	struct tc_u_hnode *ht = key->ht_up;
+	struct tc_u_hnode *ht = rtnl_dereference(key->ht_up);
 
 	if (ht) {
 		kp = &ht->ht[TC_U32_HASH(key->handle)];
@@ -607,7 +607,8 @@ static int u32_change(struct net *net, struct sk_buff *in_skb,
 		if (TC_U32_KEY(n->handle) == 0)
 			return -EINVAL;
 
-		return u32_set_parms(net, tp, base, n->ht_up, n, tb,
+		return u32_set_parms(net, tp, base,
+				     rtnl_dereference(n->ht_up), n, tb,
 				     tca[TCA_RATE], ovr);
 	}
 
@@ -681,7 +682,7 @@ static int u32_change(struct net *net, struct sk_buff *in_skb,
 #endif
 
 	memcpy(&n->sel, s, sizeof(*s) + s->nkeys*sizeof(struct tc_u32_key));
-	n->ht_up = ht;
+	rcu_assign_pointer(n->ht_up, ht);
 	n->handle = handle;
 	n->fshift = s->hmask ? ffs(ntohl(s->hmask)) - 1 : 0;
 	tcf_exts_init(&n->exts, TCA_U32_ACT, TCA_U32_POLICE);
