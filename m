From: David Miller <davem@davemloft.net>
Subject: Re: [Bug 32772] New: PROBLEM: kernel BUG at net/ipv4/inetpeer.c:386
Date: Wed, 13 Apr 2011 13:24:03 -0700 (PDT)
Message-ID: <20110413.132403.179942105.davem@davemloft.net>
References: <BANLkTinhnPR6fHRQD-vvbxX1n+Zxr=HTZw@mail.gmail.com>
	<20110406.111649.193697123.davem@davemloft.net>
	<BANLkTi=PTqcYd1wO_QzQTtg_PWEq2fAJMg@mail.gmail.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: eric.dumazet@gmail.com, shemminger@linux-foundation.org,
	netdev@vger.kernel.org
To: dimetrios@gmail.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from 74-93-104-97-Washington.hfc.comcastbusiness.net ([74.93.104.97]:50274
	"EHLO sunset.davemloft.net" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with ESMTP id S1757492Ab1DMUYj (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 13 Apr 2011 16:24:39 -0400
In-Reply-To: <BANLkTi=PTqcYd1wO_QzQTtg_PWEq2fAJMg@mail.gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Dmitry Novikov <dimetrios@gmail.com>
Date: Wed, 13 Apr 2011 23:14:03 +0300

> Crash again after 7 days of uptime. slub_nomerge is set

Looks like too deep stack, try this patch which is in net-2.6:

--------------------
inetpeer: reduce stack usage

On 64bit arches, we use 752 bytes of stack when cleanup_once() is called
from inet_getpeer().

Lets share the avl stack to save ~376 bytes.

Before patch :

# objdump -d net/ipv4/inetpeer.o | scripts/checkstack.pl

0x000006c3 unlink_from_pool [inetpeer.o]:		376
0x00000721 unlink_from_pool [inetpeer.o]:		376
0x00000cb1 inet_getpeer [inetpeer.o]:			376
0x00000e6d inet_getpeer [inetpeer.o]:			376
0x0004 inet_initpeers [inetpeer.o]:			112
# size net/ipv4/inetpeer.o
   text	   data	    bss	    dec	    hex	filename
   5320	    432	     21	   5773	   168d	net/ipv4/inetpeer.o

After patch :

objdump -d net/ipv4/inetpeer.o | scripts/checkstack.pl
0x00000c11 inet_getpeer [inetpeer.o]:			376
0x00000dcd inet_getpeer [inetpeer.o]:			376
0x00000ab9 peer_check_expire [inetpeer.o]:		328
0x00000b7f peer_check_expire [inetpeer.o]:		328
0x0004 inet_initpeers [inetpeer.o]:			112
# size net/ipv4/inetpeer.o
   text	   data	    bss	    dec	    hex	filename
   5163	    432	     21	   5616	   15f0	net/ipv4/inetpeer.o

Signed-off-by: Eric Dumazet <eric.dumazet@gmail.com>
Cc: Scot Doyle <lkml@scotdoyle.com>
Cc: Stephen Hemminger <shemminger@vyatta.com>
Cc: Hiroaki SHIMODA <shimoda.hiroaki@gmail.com>
Reviewed-by: Hiroaki SHIMODA <shimoda.hiroaki@gmail.com>
Signed-off-by: David S. Miller <davem@davemloft.net>
---
 net/ipv4/inetpeer.c |   13 +++++++------
 1 files changed, 7 insertions(+), 6 deletions(-)

diff --git a/net/ipv4/inetpeer.c b/net/ipv4/inetpeer.c
index dd1b20e..9df4e63 100644
--- a/net/ipv4/inetpeer.c
+++ b/net/ipv4/inetpeer.c
@@ -354,7 +354,8 @@ static void inetpeer_free_rcu(struct rcu_head *head)
 }
 
 /* May be called with local BH enabled. */
-static void unlink_from_pool(struct inet_peer *p, struct inet_peer_base *base)
+static void unlink_from_pool(struct inet_peer *p, struct inet_peer_base *base,
+			     struct inet_peer __rcu **stack[PEER_MAXDEPTH])
 {
 	int do_free;
 
@@ -368,7 +369,6 @@ static void unlink_from_pool(struct inet_peer *p, struct inet_peer_base *base)
 	 * We use refcnt=-1 to alert lockless readers this entry is deleted.
 	 */
 	if (atomic_cmpxchg(&p->refcnt, 1, -1) == 1) {
-		struct inet_peer __rcu **stack[PEER_MAXDEPTH];
 		struct inet_peer __rcu ***stackptr, ***delp;
 		if (lookup(&p->daddr, stack, base) != p)
 			BUG();
@@ -422,7 +422,7 @@ static struct inet_peer_base *peer_to_base(struct inet_peer *p)
 }
 
 /* May be called with local BH enabled. */
-static int cleanup_once(unsigned long ttl)
+static int cleanup_once(unsigned long ttl, struct inet_peer __rcu **stack[PEER_MAXDEPTH])
 {
 	struct inet_peer *p = NULL;
 
@@ -454,7 +454,7 @@ static int cleanup_once(unsigned long ttl)
 		 * happen because of entry limits in route cache. */
 		return -1;
 
-	unlink_from_pool(p, peer_to_base(p));
+	unlink_from_pool(p, peer_to_base(p), stack);
 	return 0;
 }
 
@@ -524,7 +524,7 @@ struct inet_peer *inet_getpeer(struct inetpeer_addr *daddr, int create)
 
 	if (base->total >= inet_peer_threshold)
 		/* Remove one less-recently-used entry. */
-		cleanup_once(0);
+		cleanup_once(0, stack);
 
 	return p;
 }
@@ -540,6 +540,7 @@ static void peer_check_expire(unsigned long dummy)
 {
 	unsigned long now = jiffies;
 	int ttl, total;
+	struct inet_peer __rcu **stack[PEER_MAXDEPTH];
 
 	total = compute_total();
 	if (total >= inet_peer_threshold)
@@ -548,7 +549,7 @@ static void peer_check_expire(unsigned long dummy)
 		ttl = inet_peer_maxttl
 				- (inet_peer_maxttl - inet_peer_minttl) / HZ *
 					total / inet_peer_threshold * HZ;
-	while (!cleanup_once(ttl)) {
+	while (!cleanup_once(ttl, stack)) {
 		if (jiffies != now)
 			break;
 	}
-- 
1.7.4.3

