From: Eric Dumazet <eric.dumazet@gmail.com>
Subject: [PATCH] inetpeer: reduce stack usage
Date: Tue, 12 Apr 2011 10:39:40 +0200
Message-ID: <1302597580.3233.14.camel@edumazet-laptop>
References: <4D9E62D9.5010400@scotdoyle.com>
	 <20110408121700.0aad53fe@nehalam>	<4D9FE5BE.6060600@scotdoyle.com>
	 <20110409161908.a2aca120.shimoda.hiroaki@gmail.com>
	 <4DA39330.2030102@scotdoyle.com> <20110411183105.46e86684@nehalam>
	 <4DA3CB4B.9090506@scotdoyle.com> <1302581384.3603.14.camel@edumazet-laptop>
	 <1302582172.3603.18.camel@edumazet-laptop> <4DA3E074.5090603@scotdoyle.com>
	 <1302587490.3603.22.camel@edumazet-laptop> <4DA3F909.5020609@scotdoyle.com>
	 <1302593469.3603.44.camel@edumazet-laptop>
Mime-Version: 1.0
Content-Type: text/plain; charset="UTF-8"
Content-Transfer-Encoding: 7bit
Cc: Stephen Hemminger <shemminger@vyatta.com>,
	Hiroaki SHIMODA <shimoda.hiroaki@gmail.com>,
	netdev@vger.kernel.org
To: Scot Doyle <lkml@scotdoyle.com>, David Miller <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-ww0-f44.google.com ([74.125.82.44]:46673 "EHLO
	mail-ww0-f44.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1753716Ab1DLIjp (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 12 Apr 2011 04:39:45 -0400
Received: by wwa36 with SMTP id 36so7616502wwa.1
        for <netdev@vger.kernel.org>; Tue, 12 Apr 2011 01:39:44 -0700 (PDT)
In-Reply-To: <1302593469.3603.44.camel@edumazet-laptop>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

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
---
 net/ipv4/inetpeer.c |   13 +++++++------
 1 file changed, 7 insertions(+), 6 deletions(-)

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


