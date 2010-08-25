From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH] tcp: Fix sysctl_tcp_max_orphans when PAGE_SIZE != 4k
Date: Wed, 25 Aug 2010 16:57:59 -0700 (PDT)
Message-ID: <20100825.165759.27789477.davem@davemloft.net>
References: <20100825071626.GA13681@kryten>
	<20100825071701.GA14962@kryten>
	<1282758634.2487.576.camel@edumazet-laptop>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: anton@samba.org, netdev@vger.kernel.org, miltonm@bga.com
To: eric.dumazet@gmail.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from 74-93-104-97-Washington.hfc.comcastbusiness.net ([74.93.104.97]:60040
	"EHLO sunset.davemloft.net" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with ESMTP id S1751824Ab0HYX5o (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 25 Aug 2010 19:57:44 -0400
In-Reply-To: <1282758634.2487.576.camel@edumazet-laptop>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Eric Dumazet <eric.dumazet@gmail.com>
Date: Wed, 25 Aug 2010 19:50:34 +0200

> In fact, existing code makes litle sense....
> 
> (tcp_hashinfo.bhash_size * sizeof(struct inet_bind_hashbucket))
> 
> is much bigger if spinlock debugging is on. Its strange to select bigger
> limits in this case (where kernel structures are also bigger)
> 
> bhash_size max is 65536, and we get this value even for small machines. 
> 
> Sizing would probably be better if using ehash_size instead of
> bhash_size

Yes, that would avoid debugging unduly influencing this tunable.

Also, I think the "4096" constant is a reference to thing we now
call SK_MEM_QUANTUM.  Back when this sizing code was added in:

commit 1f28b683339f74f9664b77532f4a2f1aad512451
Author: davem <davem>
Date:   Sun Jan 16 05:10:52 2000 +0000

    Merge in TCP/UDP optimizations and
    bug fixing from softnet patches.  Softnet patch
    set decreases size by approx. 300k

of the netdev-vger-cvs tree, we used the '4096' constant explicitly.

> Maybe remove the 'order' loop and use ehash_size, already a result of
> the available memory or thash_entries tunable.
> 
> unsigned int ehash_size = tcp_hashinfo.ehash_mask + 1;
> 
> tcp_death_row.sysctl_max_tw_buckets = cnt / 2;
> sysctl_tcp_max_orphans = cnt / 2;
> sysctl_max_syn_backlog = min(128, cnt / 256);

Yeah, something like the following, Anton?

diff --git a/net/ipv4/tcp.c b/net/ipv4/tcp.c
index 197b9b7..403c029 100644
--- a/net/ipv4/tcp.c
+++ b/net/ipv4/tcp.c
@@ -3209,7 +3209,7 @@ void __init tcp_init(void)
 {
 	struct sk_buff *skb = NULL;
 	unsigned long nr_pages, limit;
-	int order, i, max_share;
+	int order, i, max_share, cnt;
 	unsigned long jiffy = jiffies;
 
 	BUILD_BUG_ON(sizeof(struct tcp_skb_cb) > sizeof(skb->cb));
@@ -3258,22 +3258,11 @@ void __init tcp_init(void)
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
+	cnt = tcp_hashinfo.ehash_mask + 1;
+
+	tcp_death_row.sysctl_max_tw_buckets = cnt / 2;
+	sysctl_tcp_max_orphans = cnt / 2;
+	sysctl_max_syn_backlog = min(128, cnt / 256);
 
 	/* Set the pressure threshold to be a fraction of global memory that
 	 * is up to 1/2 at 256 MB, decreasing toward zero with the amount of
