From: Alexei Starovoitov <ast@plumgrid.com>
Subject: [PATCH v2 net-next 4/5] net_sched: convert rsvp to call tcf_exts_destroy from rcu callback
Date: Tue, 25 Aug 2015 20:06:34 -0700
Message-ID: <1440558395-7765-5-git-send-email-ast@plumgrid.com>
References: <1440558395-7765-1-git-send-email-ast@plumgrid.com>
Cc: Eric Dumazet <edumazet@google.com>,
	Daniel Borkmann <daniel@iogearbox.net>, netdev@vger.kernel.org
To: "David S. Miller" <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-pa0-f44.google.com ([209.85.220.44]:33680 "EHLO
	mail-pa0-f44.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752134AbbHZDGq (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 25 Aug 2015 23:06:46 -0400
Received: by pacti10 with SMTP id ti10so71733482pac.0
        for <netdev@vger.kernel.org>; Tue, 25 Aug 2015 20:06:45 -0700 (PDT)
In-Reply-To: <1440558395-7765-1-git-send-email-ast@plumgrid.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Adjust destroy path of cls_rsvp to call tcf_exts_destroy() after
rcu grace period.

Signed-off-by: Alexei Starovoitov <ast@plumgrid.com>
---
 net/sched/cls_rsvp.h |   18 ++++++++++++++----
 1 file changed, 14 insertions(+), 4 deletions(-)

diff --git a/net/sched/cls_rsvp.h b/net/sched/cls_rsvp.h
index 02fa82792dab..f9c9fc075fe6 100644
--- a/net/sched/cls_rsvp.h
+++ b/net/sched/cls_rsvp.h
@@ -283,12 +283,22 @@ static int rsvp_init(struct tcf_proto *tp)
 	return -ENOBUFS;
 }
 
-static void
-rsvp_delete_filter(struct tcf_proto *tp, struct rsvp_filter *f)
+static void rsvp_delete_filter_rcu(struct rcu_head *head)
 {
-	tcf_unbind_filter(tp, &f->res);
+	struct rsvp_filter *f = container_of(head, struct rsvp_filter, rcu);
+
 	tcf_exts_destroy(&f->exts);
-	kfree_rcu(f, rcu);
+	kfree(f);
+}
+
+static void rsvp_delete_filter(struct tcf_proto *tp, struct rsvp_filter *f)
+{
+	tcf_unbind_filter(tp, &f->res);
+	/* all classifiers are required to call tcf_exts_destroy() after rcu
+	 * grace period, since converted-to-rcu actions are relying on that
+	 * in cleanup() callback
+	 */
+	call_rcu(&f->rcu, rsvp_delete_filter_rcu);
 }
 
 static bool rsvp_destroy(struct tcf_proto *tp, bool force)
-- 
1.7.9.5
