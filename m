From: Alexei Starovoitov <ast@plumgrid.com>
Subject: [PATCH v2 net-next] tc: remove unused redirect ttl
Date: Thu, 30 Apr 2015 20:11:36 -0700
Message-ID: <1430449896-5406-1-git-send-email-ast@plumgrid.com>
Cc: Jamal Hadi Salim <jhs@mojatatu.com>,
	Daniel Borkmann <daniel@iogearbox.net>,
	Florian Westphal <fw@strlen.de>, netdev@vger.kernel.org
To: "David S. Miller" <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-pd0-f169.google.com ([209.85.192.169]:35287 "EHLO
	mail-pd0-f169.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1753132AbbEADLn (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 30 Apr 2015 23:11:43 -0400
Received: by pdbqd1 with SMTP id qd1so80055073pdb.2
        for <netdev@vger.kernel.org>; Thu, 30 Apr 2015 20:11:42 -0700 (PDT)
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

improves ingress+u32 performance from 22.4 Mpps to 22.9 Mpps

Signed-off-by: Jamal Hadi Salim <jhs@mojatatu.com>
Signed-off-by: Alexei Starovoitov <ast@plumgrid.com>
---
The code is from Jamal. I only did testing and benchmarking.

V1->V2: missed removal of unused 'dev' variable.

 include/uapi/linux/pkt_cls.h |    2 ++
 net/core/dev.c               |    9 ---------
 2 files changed, 2 insertions(+), 9 deletions(-)

diff --git a/include/uapi/linux/pkt_cls.h b/include/uapi/linux/pkt_cls.h
index bf08e76bf505..f6344a522cd6 100644
--- a/include/uapi/linux/pkt_cls.h
+++ b/include/uapi/linux/pkt_cls.h
@@ -62,11 +62,13 @@ bits 9,10,11: redirect counter -  redirect TTL. Loop avoidance
 #define SET_TC_NCLS(v)   ( TC_NCLS | (v & ~TC_NCLS))
 #define CLR_TC_NCLS(v)   ( v & ~TC_NCLS)
 
+#ifndef __KERNEL__
 #define S_TC_RTTL          _TC_MAKE32(9)
 #define M_TC_RTTL          _TC_MAKEMASK(3,S_TC_RTTL)
 #define G_TC_RTTL(x)       _TC_GETVALUE(x,S_TC_RTTL,M_TC_RTTL)
 #define V_TC_RTTL(x)       _TC_MAKEVALUE(x,S_TC_RTTL)
 #define SET_TC_RTTL(v,n)   ((V_TC_RTTL(n)) | (v & ~M_TC_RTTL))
+#endif
 
 #define S_TC_AT          _TC_MAKE32(12)
 #define M_TC_AT          _TC_MAKEMASK(2,S_TC_AT)
diff --git a/net/core/dev.c b/net/core/dev.c
index c7ba0388f1be..97a15ae8d07a 100644
--- a/net/core/dev.c
+++ b/net/core/dev.c
@@ -3531,18 +3531,9 @@ EXPORT_SYMBOL_GPL(br_fdb_test_addr_hook);
  */
 static int ing_filter(struct sk_buff *skb, struct netdev_queue *rxq)
 {
-	struct net_device *dev = skb->dev;
-	u32 ttl = G_TC_RTTL(skb->tc_verd);
 	int result = TC_ACT_OK;
 	struct Qdisc *q;
 
-	if (unlikely(MAX_RED_LOOP < ttl++)) {
-		net_warn_ratelimited("Redir loop detected Dropping packet (%d->%d)\n",
-				     skb->skb_iif, dev->ifindex);
-		return TC_ACT_SHOT;
-	}
-
-	skb->tc_verd = SET_TC_RTTL(skb->tc_verd, ttl);
 	skb->tc_verd = SET_TC_AT(skb->tc_verd, AT_INGRESS);
 
 	q = rcu_dereference(rxq->qdisc);
-- 
1.7.9.5
