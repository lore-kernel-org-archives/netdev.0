From: Changli Gao <xiaosuo@gmail.com>
Subject: [PATCH] HTB updates class's bstats in one place
Date: Wed, 29 Oct 2008 16:54:11 +0800
Message-ID: <490824B3.20100@gmail.com>
Reply-To: xiaosuo@gmail.com
Mime-Version: 1.0
Content-Type: text/plain; charset=GB2312
Content-Transfer-Encoding: 7bit
Cc: xiaosuo <xiaosuo@gmail.com>
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from ti-out-0910.google.com ([209.85.142.190]:48399 "EHLO
	ti-out-0910.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752263AbYJ2Iyx (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 29 Oct 2008 04:54:53 -0400
Received: by ti-out-0910.google.com with SMTP id b6so1617874tic.23
        for <netdev@vger.kernel.org>; Wed, 29 Oct 2008 01:54:51 -0700 (PDT)
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

This patch make HTB update class's bstats in one place when dequeuing
packets instead of updating the leaf's when enqueuing and updating the
other's when dequeuing. It also fixes a statistics bug, the statistics
data of leaf class will exceeds its parent classes's due to packets are
dropped by its inner qdisc.

Signed-off-by: Changli Gao <xiaosuo@gmail.com <mailto:xiaosuo@gmail.com>>
---
sch_htb.c | 13 ++++---------
1 file changed, 4 insertions(+), 9 deletions(-)

--- net/sched/sch_htb.c.orig	2008-10-29 16:18:13.000000000 +0800
+++ net/sched/sch_htb.c	2008-10-29 16:19:54.000000000 +0800
@@ -579,9 +579,6 @@
 		}
 		return ret;
 	} else {
-		cl->bstats.packets +=
-			skb_is_gso(skb)?skb_shinfo(skb)->gso_segs:1;
-		cl->bstats.bytes += qdisc_pkt_len(skb);
 		htb_activate(q, cl);
 	}
 
@@ -679,12 +676,10 @@
 				htb_add_to_wait_tree(q, cl, diff);
 		}
 
-		/* update byte stats except for leaves which are already updated */
-		if (cl->level) {
-			cl->bstats.bytes += bytes;
-			cl->bstats.packets += skb_is_gso(skb)?
-					skb_shinfo(skb)->gso_segs:1;
-		}
+		cl->bstats.bytes += bytes;
+		cl->bstats.packets += skb_is_gso(skb)?
+				skb_shinfo(skb)->gso_segs:1;
+
 		cl = cl->parent;
 	}
 }


