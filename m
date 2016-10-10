From: Eric Dumazet <eric.dumazet@gmail.com>
Subject: [PATCH net] net_sched: do not broadcast RTM_GETTFILTER result
Date: Sun, 09 Oct 2016 20:25:55 -0700
Message-ID: <1476069955.28155.292.camel@edumazet-glaptop3.roam.corp.google.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="UTF-8"
Content-Transfer-Encoding: 7bit
Cc: netdev <netdev@vger.kernel.org>,
        Jamal Hadi Salim <jhs@mojatatu.com>
To: David Miller <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-io0-f193.google.com ([209.85.223.193]:33096 "EHLO
        mail-io0-f193.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1751713AbcJJDZ6 (ORCPT
        <rfc822;netdev@vger.kernel.org>); Sun, 9 Oct 2016 23:25:58 -0400
Received: by mail-io0-f193.google.com with SMTP id q192so6461208iod.0
        for <netdev@vger.kernel.org>; Sun, 09 Oct 2016 20:25:57 -0700 (PDT)
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Eric Dumazet <edumazet@google.com>

There are two ways to get tc filters from kernel to user space.

1) Full dump (tc_dump_tfilter())
2) RTM_GETTFILTER to get one precise filter, reducing overhead.

The second operation is unfortunately broadcasting its result,
polluting "tc monitor" users.

This patch makes sure only the requester gets the result, using
netlink_unicast() instead of rtnetlink_send()

Jamal cooked an iproute2 patch to implement "tc filter get" operation,
but other user space libraries already use RTM_GETTFILTER when a single
filter is queried, instead of dumping all filters.

Signed-off-by: Eric Dumazet <edumazet@google.com>
Cc: Jamal Hadi Salim <jhs@mojatatu.com>
---
 net/sched/cls_api.c |   18 +++++++++++-------
 1 file changed, 11 insertions(+), 7 deletions(-)

diff --git a/net/sched/cls_api.c b/net/sched/cls_api.c
index 11da7da0b7c4..2ee29a3375f6 100644
--- a/net/sched/cls_api.c
+++ b/net/sched/cls_api.c
@@ -101,7 +101,7 @@ EXPORT_SYMBOL(unregister_tcf_proto_ops);
 
 static int tfilter_notify(struct net *net, struct sk_buff *oskb,
 			  struct nlmsghdr *n, struct tcf_proto *tp,
-			  unsigned long fh, int event);
+			  unsigned long fh, int event, bool unicast);
 
 static void tfilter_notify_chain(struct net *net, struct sk_buff *oskb,
 				 struct nlmsghdr *n,
@@ -112,7 +112,7 @@ static void tfilter_notify_chain(struct net *net, struct sk_buff *oskb,
 
 	for (it_chain = chain; (tp = rtnl_dereference(*it_chain)) != NULL;
 	     it_chain = &tp->next)
-		tfilter_notify(net, oskb, n, tp, 0, event);
+		tfilter_notify(net, oskb, n, tp, 0, event, false);
 }
 
 /* Select new prio value from the range, managed by kernel. */
@@ -319,7 +319,8 @@ replay:
 
 			RCU_INIT_POINTER(*back, next);
 
-			tfilter_notify(net, skb, n, tp, fh, RTM_DELTFILTER);
+			tfilter_notify(net, skb, n, tp, fh,
+				       RTM_DELTFILTER, false);
 			tcf_destroy(tp, true);
 			err = 0;
 			goto errout;
@@ -345,14 +346,14 @@ replay:
 				struct tcf_proto *next = rtnl_dereference(tp->next);
 
 				tfilter_notify(net, skb, n, tp, fh,
-					       RTM_DELTFILTER);
+					       RTM_DELTFILTER, false);
 				if (tcf_destroy(tp, false))
 					RCU_INIT_POINTER(*back, next);
 			}
 			goto errout;
 		case RTM_GETTFILTER:
 			err = tfilter_notify(net, skb, n, tp, fh,
-					     RTM_NEWTFILTER);
+					     RTM_NEWTFILTER, true);
 			goto errout;
 		default:
 			err = -EINVAL;
@@ -367,7 +368,7 @@ replay:
 			RCU_INIT_POINTER(tp->next, rtnl_dereference(*back));
 			rcu_assign_pointer(*back, tp);
 		}
-		tfilter_notify(net, skb, n, tp, fh, RTM_NEWTFILTER);
+		tfilter_notify(net, skb, n, tp, fh, RTM_NEWTFILTER, false);
 	} else {
 		if (tp_created)
 			tcf_destroy(tp, true);
@@ -419,7 +420,7 @@ nla_put_failure:
 
 static int tfilter_notify(struct net *net, struct sk_buff *oskb,
 			  struct nlmsghdr *n, struct tcf_proto *tp,
-			  unsigned long fh, int event)
+			  unsigned long fh, int event, bool unicast)
 {
 	struct sk_buff *skb;
 	u32 portid = oskb ? NETLINK_CB(oskb).portid : 0;
@@ -433,6 +434,9 @@ static int tfilter_notify(struct net *net, struct sk_buff *oskb,
 		return -EINVAL;
 	}
 
+	if (unicast)
+		return netlink_unicast(net->rtnl, skb, portid, MSG_DONTWAIT);
+
 	return rtnetlink_send(skb, net, portid, RTNLGRP_TC,
 			      n->nlmsg_flags & NLM_F_ECHO);
 }
