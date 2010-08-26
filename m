From: Eric Dumazet <eric.dumazet@gmail.com>
Subject: [PATCH] tcp: fix three tcp sysctls tuning
Date: Thu, 26 Aug 2010 07:15:53 +0200
Message-ID: <1282799753.2681.714.camel@edumazet-laptop>
References: <20100825071626.GA13681@kryten> <20100825071701.GA14962@kryten>
	 <1282758634.2487.576.camel@edumazet-laptop>
	 <20100825.165759.27789477.davem@davemloft.net>
	 <20100826003834.GA17882@kryten>
Mime-Version: 1.0
Content-Type: text/plain; charset="UTF-8"
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, miltonm@bga.com
To: Anton Blanchard <anton@samba.org>,
	David Miller <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-wy0-f174.google.com ([74.125.82.174]:54923 "EHLO
	mail-wy0-f174.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752816Ab0HZFP7 (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 26 Aug 2010 01:15:59 -0400
Received: by wyb35 with SMTP id 35so1712726wyb.19
        for <netdev@vger.kernel.org>; Wed, 25 Aug 2010 22:15:57 -0700 (PDT)
In-Reply-To: <20100826003834.GA17882@kryten>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

As discovered by Anton Blanchard, current code to autotune 
tcp_death_row.sysctl_max_tw_buckets, sysctl_tcp_max_orphans and
sysctl_max_syn_backlog makes litle sense.

The bigger a page is, the less tcp_max_orphans is : 4096 on a 512GB
machine in Anton's case.

(tcp_hashinfo.bhash_size * sizeof(struct inet_bind_hashbucket))
is much bigger if spinlock debugging is on. Its wrong to select bigger
limits in this case (where kernel structures are also bigger)

bhash_size max is 65536, and we get this value even for small machines. 

A better ground is to use size of ehash table, this also makes code
shorter and more obvious.

Based on a patch from Anton, and another from David.

Reported-and-tested-by: Anton Blanchard <anton@samba.org>
Signed-off-by: Eric Dumazet <eric.dumazet@gmail.com>
---
 net/ipv4/tcp.c |   24 +++++++-----------------
 1 file changed, 7 insertions(+), 17 deletions(-)

diff --git a/net/ipv4/tcp.c b/net/ipv4/tcp.c
index 197b9b7..e2add5f 100644
--- a/net/ipv4/tcp.c
+++ b/net/ipv4/tcp.c
@@ -3209,7 +3209,7 @@ void __init tcp_init(void)
 {
 	struct sk_buff *skb = NULL;
 	unsigned long nr_pages, limit;
-	int order, i, max_share;
+	int i, max_share, cnt;
 	unsigned long jiffy = jiffies;
 
 	BUILD_BUG_ON(sizeof(struct tcp_skb_cb) > sizeof(skb->cb));
@@ -3258,22 +3258,12 @@ void __init tcp_init(void)
 		INIT_HLIST_HEAD(&tcp_hashinfo.bhash[i].chain);
 	}
 
-	/* Try to be a bit smarter and adjust defaults depending
-	 * on available memory.
-	 */
-	for (order = 0; ((1 << order) << PAGE_SHIFT) <
-			(tcp_hashinfo.bhash_size * sizeof(struct inet_bind_hashbucket));
-			order++)
-		;
-	if (order >= 4) {
-		tcp_death_row.sysctl_max_tw_buckets = 180000;
-		sysctl_tcp_max_orphans = 4096 << (order - 4);
-		sysctl_max_syn_backlog = 1024;
-	} else if (order < 3) {
-		tcp_death_row.sysctl_max_tw_buckets >>= (3 - order);
-		sysctl_tcp_max_orphans >>= (3 - order);
-		sysctl_max_syn_backlog = 128;
-	}
+
+	cnt = tcp_hashinfo.ehash_mask + 1;
+
+	tcp_death_row.sysctl_max_tw_buckets = cnt / 2;
+	sysctl_tcp_max_orphans = cnt / 2;
+	sysctl_max_syn_backlog = max(128, cnt / 256);
 
 	/* Set the pressure threshold to be a fraction of global memory that
 	 * is up to 1/2 at 256 MB, decreasing toward zero with the amount of


