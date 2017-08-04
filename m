From: Jiri Pirko <jiri@resnulli.us>
Subject: [patch net-next v2 18/20] net: sched: cls_route: no need to call tcf_exts_change for newly allocated struct
Date: Fri,  4 Aug 2017 14:29:13 +0200
Message-ID: <20170804122915.15177-19-jiri@resnulli.us>
References: <20170804122915.15177-1-jiri@resnulli.us>
Cc: davem@davemloft.net, jhs@mojatatu.com, xiyou.wangcong@gmail.com,
        daniel@iogearbox.net, mlxsw@mellanox.com
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-wm0-f68.google.com ([74.125.82.68]:35426 "EHLO
        mail-wm0-f68.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1752330AbdHDMaF (ORCPT
        <rfc822;netdev@vger.kernel.org>); Fri, 4 Aug 2017 08:30:05 -0400
Received: by mail-wm0-f68.google.com with SMTP id r77so5553677wmd.2
        for <netdev@vger.kernel.org>; Fri, 04 Aug 2017 05:30:04 -0700 (PDT)
In-Reply-To: <20170804122915.15177-1-jiri@resnulli.us>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Jiri Pirko <jiri@mellanox.com>

As the f struct was allocated right before route4_set_parms call,
no need to use tcf_exts_change to do atomic change, and we can just
fill-up the unused exts struct directly by tcf_exts_validate.

Signed-off-by: Jiri Pirko <jiri@mellanox.com>
---
 net/sched/cls_route.c | 30 +++++++++---------------------
 1 file changed, 9 insertions(+), 21 deletions(-)

diff --git a/net/sched/cls_route.c b/net/sched/cls_route.c
index 26f8636..f1e7d78 100644
--- a/net/sched/cls_route.c
+++ b/net/sched/cls_route.c
@@ -372,37 +372,32 @@ static int route4_set_parms(struct net *net, struct tcf_proto *tp,
 	struct route4_filter *fp;
 	unsigned int h1;
 	struct route4_bucket *b;
-	struct tcf_exts e;
 	int err;
 
-	err = tcf_exts_init(&e, TCA_ROUTE4_ACT, TCA_ROUTE4_POLICE);
+	err = tcf_exts_validate(net, tp, tb, est, &f->exts, ovr);
 	if (err < 0)
 		return err;
-	err = tcf_exts_validate(net, tp, tb, est, &e, ovr);
-	if (err < 0)
-		goto errout;
 
-	err = -EINVAL;
 	if (tb[TCA_ROUTE4_TO]) {
 		if (new && handle & 0x8000)
-			goto errout;
+			return -EINVAL;
 		to = nla_get_u32(tb[TCA_ROUTE4_TO]);
 		if (to > 0xFF)
-			goto errout;
+			return -EINVAL;
 		nhandle = to;
 	}
 
 	if (tb[TCA_ROUTE4_FROM]) {
 		if (tb[TCA_ROUTE4_IIF])
-			goto errout;
+			return -EINVAL;
 		id = nla_get_u32(tb[TCA_ROUTE4_FROM]);
 		if (id > 0xFF)
-			goto errout;
+			return -EINVAL;
 		nhandle |= id << 16;
 	} else if (tb[TCA_ROUTE4_IIF]) {
 		id = nla_get_u32(tb[TCA_ROUTE4_IIF]);
 		if (id > 0x7FFF)
-			goto errout;
+			return -EINVAL;
 		nhandle |= (id | 0x8000) << 16;
 	} else
 		nhandle |= 0xFFFF << 16;
@@ -410,27 +405,25 @@ static int route4_set_parms(struct net *net, struct tcf_proto *tp,
 	if (handle && new) {
 		nhandle |= handle & 0x7F00;
 		if (nhandle != handle)
-			goto errout;
+			return -EINVAL;
 	}
 
 	h1 = to_hash(nhandle);
 	b = rtnl_dereference(head->table[h1]);
 	if (!b) {
-		err = -ENOBUFS;
 		b = kzalloc(sizeof(struct route4_bucket), GFP_KERNEL);
 		if (b == NULL)
-			goto errout;
+			return -ENOBUFS;
 
 		rcu_assign_pointer(head->table[h1], b);
 	} else {
 		unsigned int h2 = from_hash(nhandle >> 16);
 
-		err = -EEXIST;
 		for (fp = rtnl_dereference(b->ht[h2]);
 		     fp;
 		     fp = rtnl_dereference(fp->next))
 			if (fp->handle == f->handle)
-				goto errout;
+				return -EEXIST;
 	}
 
 	if (tb[TCA_ROUTE4_TO])
@@ -450,12 +443,7 @@ static int route4_set_parms(struct net *net, struct tcf_proto *tp,
 		tcf_bind_filter(tp, &f->res, base);
 	}
 
-	tcf_exts_change(tp, &f->exts, &e);
-
 	return 0;
-errout:
-	tcf_exts_destroy(&e);
-	return err;
 }
 
 static int route4_change(struct net *net, struct sk_buff *in_skb,
-- 
2.9.3
