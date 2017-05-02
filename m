From: John Fastabend <john.fastabend@gmail.com>
Subject: [RFC PATCH v2 01/17] net: sched: cleanup qdisc_run and __qdisc_run
 semantics
Date: Tue, 02 May 2017 08:36:23 -0700
Message-ID: <20170502153623.9304.42848.stgit@john-Precision-Tower-5810>
References: <20170502153518.9304.17904.stgit@john-Precision-Tower-5810>
Mime-Version: 1.0
Content-Type: text/plain; charset="utf-8"
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, john.fastabend@gmail.com
To: eric.dumazet@gmail.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-pg0-f65.google.com ([74.125.83.65]:36598 "EHLO
        mail-pg0-f65.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1750733AbdEBPgm (ORCPT
        <rfc822;netdev@vger.kernel.org>); Tue, 2 May 2017 11:36:42 -0400
Received: by mail-pg0-f65.google.com with SMTP id v1so23009146pgv.3
        for <netdev@vger.kernel.org>; Tue, 02 May 2017 08:36:42 -0700 (PDT)
In-Reply-To: <20170502153518.9304.17904.stgit@john-Precision-Tower-5810>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Currently __qdisc_run calls qdisc_run_end() but does not call
qdisc_run_begin(). This makes it hard to track pairs of
qdisc_run_{begin,end} across function calls.

To simplify reading these code paths and simpler code this
patch moves begin/end calls into qdisc_run().

Signed-off-by: John Fastabend <john.r.fastabend@intel.com>
Acked-by: Eric Dumazet <edumazet@google.com>
---
 include/net/pkt_sched.h |    4 +++-
 net/core/dev.c          |    5 +++--
 net/sched/sch_generic.c |    2 --
 3 files changed, 6 insertions(+), 5 deletions(-)

diff --git a/include/net/pkt_sched.h b/include/net/pkt_sched.h
index bec46f6..b7f5776 100644
--- a/include/net/pkt_sched.h
+++ b/include/net/pkt_sched.h
@@ -109,8 +109,10 @@ int sch_direct_xmit(struct sk_buff *skb, struct Qdisc *q,
 
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
index db6e315..3169074 100644
--- a/net/core/dev.c
+++ b/net/core/dev.c
@@ -3099,9 +3099,9 @@ static inline int __dev_xmit_skb(struct sk_buff *skb, struct Qdisc *q,
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
@@ -3111,6 +3111,7 @@ static inline int __dev_xmit_skb(struct sk_buff *skb, struct Qdisc *q,
 				contended = false;
 			}
 			__qdisc_run(q);
+			qdisc_run_end(q);
 		}
 	}
 	spin_unlock(root_lock);
diff --git a/net/sched/sch_generic.c b/net/sched/sch_generic.c
index 52a2c55..ef33bf8 100644
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
