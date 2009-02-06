From: Gautam Kachroo <gk@aristanetworks.com>
Subject: [PATCH] neighbour information dumping: some entries can be skipped
Date: Thu, 5 Feb 2009 18:37:38 -0800
Message-ID: <4e0db5bc0902051837o75eeb554h592a03f9506fd9b1@mail.gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1
Content-Transfer-Encoding: 7bit
Cc: ebiederm@xmission.com
To: netdev@vger.kernel.org, davem@davemloft.net
Return-path: <netdev-owner@vger.kernel.org>
Received: from rn-out-0910.google.com ([64.233.170.190]:60378 "EHLO
	rn-out-0910.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751371AbZBFCho (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 5 Feb 2009 21:37:44 -0500
Received: by rn-out-0910.google.com with SMTP id k40so440728rnd.17
        for <netdev@vger.kernel.org>; Thu, 05 Feb 2009 18:37:38 -0800 (PST)
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

neightbl_dump_info and neigh_dump_table  can skip entries if the
*fill*info functions return an error. This results in an incomplete
dump ((invoked by netlink requests for RTM_GETNEIGHTBL or
RTM_GETNEIGH)

nidx and idx should not be incremented if the current entry was not
placed in the output buffer

Signed-off-by: Gautam Kachroo <gk@aristanetworks.com>
---
It looks like the problem crept in with commit
426b5303eb435d98b9bee37a807be386bc2b3320

Index: linux-2.6.27.4/net/core/neighbour.c
===================================================================
--- linux-2.6.27.4.orig/net/core/neighbour.c
+++ linux-2.6.27.4/net/core/neighbour.c
@@ -2012,8 +2012,8 @@ static int neightbl_dump_info(struct sk_
 			if (!net_eq(neigh_parms_net(p), net))
 				continue;

-			if (nidx++ < neigh_skip)
-				continue;
+			if (nidx < neigh_skip)
+				goto next;

 			if (neightbl_fill_param_info(skb, tbl, p,
 						     NETLINK_CB(cb->skb).pid,
@@ -2021,6 +2021,8 @@ static int neightbl_dump_info(struct sk_
 						     RTM_NEWNEIGHTBL,
 						     NLM_F_MULTI) <= 0)
 				goto out;
+		next:
+			nidx++;
 		}

 		neigh_skip = 0;
@@ -2100,12 +2102,10 @@ static int neigh_dump_table(struct neigh
 		if (h > s_h)
 			s_idx = 0;
 		for (n = tbl->hash_buckets[h], idx = 0; n; n = n->next) {
-			int lidx;
 			if (dev_net(n->dev) != net)
 				continue;
-			lidx = idx++;
-			if (lidx < s_idx)
-				continue;
+			if (idx < s_idx)
+				goto next;
 			if (neigh_fill_info(skb, n, NETLINK_CB(cb->skb).pid,
 					    cb->nlh->nlmsg_seq,
 					    RTM_NEWNEIGH,
@@ -2114,6 +2114,8 @@ static int neigh_dump_table(struct neigh
 				rc = -1;
 				goto out;
 			}
+		next:
+			idx++;
 		}
 	}
 	read_unlock_bh(&tbl->lock);
