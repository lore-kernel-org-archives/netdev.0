From: Eric Dumazet <eric.dumazet@gmail.com>
Subject: [PATCH net-next] neigh: reorder struct neighbour fields
Date: Tue, 12 Oct 2010 00:02:47 +0200
Message-ID: <1286834567.30423.102.camel@edumazet-laptop>
References: <1286484247.3745.91.camel@edumazet-laptop>
	 <20101011.121609.246536311.davem@davemloft.net>
	 <1286826361.3218.14.camel@edumazet-laptop>
	 <20101011.130128.245392712.davem@davemloft.net>
Mime-Version: 1.0
Content-Type: text/plain; charset="UTF-8"
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org
To: David Miller <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-ww0-f44.google.com ([74.125.82.44]:45308 "EHLO
	mail-ww0-f44.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1756416Ab0JKWDH (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 11 Oct 2010 18:03:07 -0400
Received: by wwj40 with SMTP id 40so4256064wwj.1
        for <netdev@vger.kernel.org>; Mon, 11 Oct 2010 15:03:06 -0700 (PDT)
In-Reply-To: <20101011.130128.245392712.davem@davemloft.net>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Here is the followup patch.

Thanks !

[PATCH net-next] neigh: reorder struct neighbour fields

(refcnt) and (ha_lock, ha, dev, output, ops, primary_key) should be
placed on a separate cache lines.

refcnt can be often written, while other fields are mostly read.

This gave me good result on stress test :

before:

real    0m45.570s
user    0m15.525s
sys     9m56.669s

After:

real    0m41.841s
user    0m15.261s
sys     8m45.949s

Signed-off-by: Eric Dumazet <eric.dumazet@gmail.com>
---
 include/net/neighbour.h |    6 +++---
 1 files changed, 3 insertions(+), 3 deletions(-)

diff --git a/include/net/neighbour.h b/include/net/neighbour.h
index f04e7a2..822802a 100644
--- a/include/net/neighbour.h
+++ b/include/net/neighbour.h
@@ -94,7 +94,6 @@ struct neighbour {
 	struct neighbour __rcu	*next;
 	struct neigh_table	*tbl;
 	struct neigh_parms	*parms;
-	struct net_device	*dev;
 	unsigned long		used;
 	unsigned long		confirmed;
 	unsigned long		updated;
@@ -103,16 +102,17 @@ struct neighbour {
 	__u8			type;
 	__u8			dead;
 	atomic_t		refcnt;
+	struct sk_buff_head	arp_queue;
+	struct timer_list	timer;
 	atomic_t		probes;
 	rwlock_t		lock;
 	seqlock_t		ha_lock;
 	unsigned char		ha[ALIGN(MAX_ADDR_LEN, sizeof(unsigned long))];
 	struct hh_cache		*hh;
 	int			(*output)(struct sk_buff *skb);
-	struct sk_buff_head	arp_queue;
-	struct timer_list	timer;
 	const struct neigh_ops	*ops;
 	struct rcu_head		rcu;
+	struct net_device	*dev;
 	u8			primary_key[0];
 };
 


