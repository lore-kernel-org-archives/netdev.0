From: Cong Wang <xiyou.wangcong@gmail.com>
Subject: [Patch net 06/15] net_sched: remove RCU callbacks in rsvp filter
Date: Mon, 23 Oct 2017 15:02:55 -0700
Message-ID: <20171023220304.2268-7-xiyou.wangcong@gmail.com>
References: <20171023220304.2268-1-xiyou.wangcong@gmail.com>
Cc: paulmck@linux.vnet.ibm.com, jhs@mojatatu.com,
        john.fastabend@gmail.com, Chris Mi <chrism@mellanox.com>,
        Cong Wang <xiyou.wangcong@gmail.com>,
        Daniel Borkmann <daniel@iogearbox.net>,
        Jiri Pirko <jiri@resnulli.us>
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-pg0-f65.google.com ([74.125.83.65]:54811 "EHLO
        mail-pg0-f65.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1751317AbdJWWDj (ORCPT
        <rfc822;netdev@vger.kernel.org>); Mon, 23 Oct 2017 18:03:39 -0400
Received: by mail-pg0-f65.google.com with SMTP id l24so12831395pgu.11
        for <netdev@vger.kernel.org>; Mon, 23 Oct 2017 15:03:39 -0700 (PDT)
In-Reply-To: <20171023220304.2268-1-xiyou.wangcong@gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Replace call_rcu() with synchronize_rcu(). I don't
touch the rest kfree_rcu() because they are not relevant
here and they are more complicated.

Reported-by: Chris Mi <chrism@mellanox.com>
Cc: Daniel Borkmann <daniel@iogearbox.net>
Cc: Jiri Pirko <jiri@resnulli.us>
Cc: John Fastabend <john.fastabend@gmail.com>
Cc: Jamal Hadi Salim <jhs@mojatatu.com>
Cc: "Paul E. McKenney" <paulmck@linux.vnet.ibm.com>
Signed-off-by: Cong Wang <xiyou.wangcong@gmail.com>
---
 net/sched/cls_rsvp.h | 13 +++----------
 1 file changed, 3 insertions(+), 10 deletions(-)

diff --git a/net/sched/cls_rsvp.h b/net/sched/cls_rsvp.h
index b1f6ed48bc72..5013e9a58f30 100644
--- a/net/sched/cls_rsvp.h
+++ b/net/sched/cls_rsvp.h
@@ -97,7 +97,6 @@ struct rsvp_filter {
 
 	u32				handle;
 	struct rsvp_session		*sess;
-	struct rcu_head			rcu;
 };
 
 static inline unsigned int hash_dst(__be32 *dst, u8 protocol, u8 tunnelid)
@@ -282,14 +281,6 @@ static int rsvp_init(struct tcf_proto *tp)
 	return -ENOBUFS;
 }
 
-static void rsvp_delete_filter_rcu(struct rcu_head *head)
-{
-	struct rsvp_filter *f = container_of(head, struct rsvp_filter, rcu);
-
-	tcf_exts_destroy(&f->exts);
-	kfree(f);
-}
-
 static void rsvp_delete_filter(struct tcf_proto *tp, struct rsvp_filter *f)
 {
 	tcf_unbind_filter(tp, &f->res);
@@ -297,7 +288,9 @@ static void rsvp_delete_filter(struct tcf_proto *tp, struct rsvp_filter *f)
 	 * grace period, since converted-to-rcu actions are relying on that
 	 * in cleanup() callback
 	 */
-	call_rcu(&f->rcu, rsvp_delete_filter_rcu);
+	synchronize_rcu();
+	tcf_exts_destroy(&f->exts);
+	kfree(f);
 }
 
 static void rsvp_destroy(struct tcf_proto *tp)
-- 
2.13.0
