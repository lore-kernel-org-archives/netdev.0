From: John Fastabend <john.fastabend@gmail.com>
Subject: [net-next PATCH 01/15] net: sched: cleanup qdisc_run and
 __qdisc_run semantics
Date: Tue, 23 Aug 2016 13:22:56 -0700
Message-ID: <20160823202256.14368.76284.stgit@john-Precision-Tower-5810>
References: <20160823202135.14368.62466.stgit@john-Precision-Tower-5810>
Mime-Version: 1.0
Content-Type: text/plain; charset="utf-8"
Content-Transfer-Encoding: 7bit
Cc: john.r.fastabend@intel.com, netdev@vger.kernel.org,
        john.fastabend@gmail.com
To: eric.dumazet@gmail.com, jhs@mojatatu.com, davem@davemloft.net,
        brouer@redhat.com, xiyou.wangcong@gmail.com,
        alexei.starovoitov@gmail.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-pf0-f194.google.com ([209.85.192.194]:35647 "EHLO
        mail-pf0-f194.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1755331AbcHWUXO (ORCPT
        <rfc822;netdev@vger.kernel.org>); Tue, 23 Aug 2016 16:23:14 -0400
Received: by mail-pf0-f194.google.com with SMTP id h186so8786051pfg.2
        for <netdev@vger.kernel.org>; Tue, 23 Aug 2016 13:23:14 -0700 (PDT)
In-Reply-To: <20160823202135.14368.62466.stgit@john-Precision-Tower-5810>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Currently __qdisc_run calls qdisc_run_end() but does not call
qdisc_run_begin(). This makes it hard to track pairs of
qdisc_run_{begin,end} across function calls.

To simplify reading these code paths and simpler code this
patch moves begin/end calls into qdisc_run().

Signed-off-by: John Fastabend <john.r.fastabend@intel.com>
---
 include/net/pkt_sched.h |    4 +++-
 net/core/dev.c          |    5 +++--
 net/sched/sch_generic.c |    2 --
 3 files changed, 6 insertions(+), 5 deletions(-)

diff --git a/include/net/pkt_sched.h b/include/net/pkt_sched.h
index 7caa99b..69540c6 100644
--- a/include/net/pkt_sched.h
+++ b/include/net/pkt_sched.h
@@ -107,8 +107,10 @@ void __qdisc_run(struct Qdisc *q);
 
 static inline void qdisc_run(struct Qdisc *q)
 {
-	if (qdisc_run_begin(q))
+	if (qdisc_run_begin(q)) {
 		__qdisc_run(q);
+		qdisc_run_end(q);
+	}
 }
 
 int tc_classify(struct sk_buff *skb, const struct tcf_proto *tp,
diff --git a/net/core/dev.c b/net/core/dev.c
index 4ce07dc..bcd4cdd 100644
--- a/net/core/dev.c
+++ b/net/core/dev.c
@@ -3106,9 +3106,9 @@ static inline int __dev_xmit_skb(struct sk_buff *skb, struct Qdisc *q,
 				contended = false;
 			}
 			__qdisc_run(q);
-		} else
-			qdisc_run_end(q);
+		}
 
+		qdisc_run_end(q);
 		rc = NET_XMIT_SUCCESS;
 	} else {
 		rc = q->enqueue(skb, q, &to_free) & NET_XMIT_MASK;
@@ -3118,6 +3118,7 @@ static inline int __dev_xmit_skb(struct sk_buff *skb, struct Qdisc *q,
 				contended = false;
 			}
 			__qdisc_run(q);
+			qdisc_run_end(q);
 		}
 	}
 	spin_unlock(root_lock);
diff --git a/net/sched/sch_generic.c b/net/sched/sch_generic.c
index e95b67c..e305a55 100644
--- a/net/sched/sch_generic.c
+++ b/net/sched/sch_generic.c
@@ -262,8 +262,6 @@ void __qdisc_run(struct Qdisc *q)
 			break;
 		}
 	}
-
-	qdisc_run_end(q);
 }
 
 unsigned long dev_trans_start(struct net_device *dev)
