From: Eric Dumazet <dada1@cosmosbay.com>
Subject: [PATCH] [NET] reduce sizeof(struct inet_peer), cleanup,
 change in peer_check_expire()
Date: Thu, 12 Oct 2006 22:14:12 +0200
Message-ID: <452EA214.7080905@cosmosbay.com>
References: <20051217071029.GY23384@wotan.suse.de>
 <20051216.231517.68922847.davem@davemloft.net>
 <43A3EE8A.5020907@cosmosbay.com> <43CCBF3D.2070900@cosmosbay.com>
 <4415A4C1.1030906@cosmosbay.com>
Mime-Version: 1.0
Content-Type: multipart/mixed; boundary="Boundary_(ID_1FGYHykOkDxT3R8vlGePng)"
Cc: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from sp604005mt.neufgp.fr ([84.96.92.11]:63470 "EHLO smtp.Neuf.fr")
	by vger.kernel.org with ESMTP id S1750856AbWJLUZN (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 12 Oct 2006 16:25:13 -0400
Received: from [192.168.30.203] ([88.137.140.131]) by sp604005mt.gpm.neuf.ld
 (Sun Java System Messaging Server 6.2-5.05 (built Feb 16 2006))
 with ESMTP id <0J7100N48HJI3L50@sp604005mt.gpm.neuf.ld> for
 netdev@vger.kernel.org; Thu, 12 Oct 2006 22:14:06 +0200 (CEST)
In-reply-to: <4415A4C1.1030906@cosmosbay.com>
To: "David S. Miller" <davem@davemloft.net>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

This is a multi-part message in MIME format.

--Boundary_(ID_1FGYHykOkDxT3R8vlGePng)
Content-type: text/plain; charset=ISO-8859-1; format=flowed
Content-transfer-encoding: 7BIT

Hi David

Please find this patch against include/net/inetpeer.h and net/ipv4/inetpeer.c

1) shrink struct inet_peer on 64 bits platforms.
------------------------------------------------
I noticed sizeof(struct inet_peer) was 64+8 on x86_64

As we dont really need 64 bits timestamps (we only care for garbage 
collection), we can use 32bits ones and reduce sizeof(struct inet_peer) to 64 
bytes : Because of SLAB_HWCACHE_ALIGN constraint, final allocation is 64 bytes 
instead of 128 bytes per inet_peer structure.

2) Cleanup
----------
  inet_putpeer() is not anymore inlined in inetpeer.h, as this is not called 
in fast paths, to reduce text size. Some exports are not anymore needed 
(inet_peer_unused_lock, inet_peer_unused_tailp) and can be declared static.

3) No more hard limit (PEER_MAX_CLEANUP_WORK = 30)
--------------------------------------------------
  peer_check_expire() try to delete entries for at most one timer tick. CPUS 
are going faster, hard limits are becoming useless... Similar thing is done in 
net/ipv4/route.c garbage collector.

Signed-off-by: Eric Dumazet <dada1@cosmosbay.com>


--Boundary_(ID_1FGYHykOkDxT3R8vlGePng)
Content-type: text/plain; name=peer.patch
Content-transfer-encoding: 7BIT
Content-disposition: inline; filename=peer.patch

--- linux-2.6.18/include/net/inetpeer.h	Wed Sep 20 05:42:06 2006
+++ linux-2.6.18-ed/include/net/inetpeer.h	Thu Oct 12 21:40:28 2006
@@ -19,7 +19,7 @@
 {
 	struct inet_peer	*avl_left, *avl_right;
 	struct inet_peer	*unused_next, **unused_prevp;
-	unsigned long		dtime;		/* the time of last use of not
+	__u32			dtime;		/* the time of last use of not
 						 * referenced entries */
 	atomic_t		refcnt;
 	__u32			v4daddr;	/* peer's address */
@@ -35,21 +35,8 @@
 /* can be called with or without local BH being disabled */
 struct inet_peer	*inet_getpeer(__u32 daddr, int create);
 
-extern spinlock_t inet_peer_unused_lock;
-extern struct inet_peer **inet_peer_unused_tailp;
 /* can be called from BH context or outside */
-static inline void	inet_putpeer(struct inet_peer *p)
-{
-	spin_lock_bh(&inet_peer_unused_lock);
-	if (atomic_dec_and_test(&p->refcnt)) {
-		p->unused_prevp = inet_peer_unused_tailp;
-		p->unused_next = NULL;
-		*inet_peer_unused_tailp = p;
-		inet_peer_unused_tailp = &p->unused_next;
-		p->dtime = jiffies;
-	}
-	spin_unlock_bh(&inet_peer_unused_lock);
-}
+extern void inet_putpeer(struct inet_peer *p);
 
 extern spinlock_t inet_peer_idlock;
 /* can be called with or without local BH being disabled */
--- linux-2.6.18/net/ipv4/inetpeer.c	Wed Sep 20 05:42:06 2006
+++ linux-2.6.18-ed/net/ipv4/inetpeer.c	Thu Oct 12 21:55:23 2006
@@ -94,10 +94,8 @@
 int inet_peer_maxttl = 10 * 60 * HZ;	/* usual time to live: 10 min */
 
 static struct inet_peer *inet_peer_unused_head;
-/* Exported for inet_putpeer inline function.  */
-struct inet_peer **inet_peer_unused_tailp = &inet_peer_unused_head;
-DEFINE_SPINLOCK(inet_peer_unused_lock);
-#define PEER_MAX_CLEANUP_WORK 30
+static struct inet_peer **inet_peer_unused_tailp = &inet_peer_unused_head;
+static DEFINE_SPINLOCK(inet_peer_unused_lock);
 
 static void peer_check_expire(unsigned long dummy);
 static DEFINE_TIMER(peer_periodic_timer, peer_check_expire, 0, 0);
@@ -343,7 +341,8 @@
 	spin_lock_bh(&inet_peer_unused_lock);
 	p = inet_peer_unused_head;
 	if (p != NULL) {
-		if (time_after(p->dtime + ttl, jiffies)) {
+		__u32 delta = (__u32)jiffies - p->dtime;
+		if (delta < ttl) {
 			/* Do not prune fresh entries. */
 			spin_unlock_bh(&inet_peer_unused_lock);
 			return -1;
@@ -435,7 +434,7 @@
 /* Called with local BH disabled. */
 static void peer_check_expire(unsigned long dummy)
 {
-	int i;
+	unsigned long now = jiffies;
 	int ttl;
 
 	if (peer_total >= inet_peer_threshold)
@@ -444,7 +443,10 @@
 		ttl = inet_peer_maxttl
 				- (inet_peer_maxttl - inet_peer_minttl) / HZ *
 					peer_total / inet_peer_threshold * HZ;
-	for (i = 0; i < PEER_MAX_CLEANUP_WORK && !cleanup_once(ttl); i++);
+	while (!cleanup_once(ttl)) {
+		if (jiffies != now)
+			break;
+	}
 
 	/* Trigger the timer after inet_peer_gc_mintime .. inet_peer_gc_maxtime
 	 * interval depending on the total number of entries (more entries,
@@ -458,3 +460,16 @@
 				peer_total / inet_peer_threshold * HZ;
 	add_timer(&peer_periodic_timer);
 }
+
+void inet_putpeer(struct inet_peer *p)
+{
+	spin_lock_bh(&inet_peer_unused_lock);
+	if (atomic_dec_and_test(&p->refcnt)) {
+		p->unused_prevp = inet_peer_unused_tailp;
+		p->unused_next = NULL;
+		*inet_peer_unused_tailp = p;
+		inet_peer_unused_tailp = &p->unused_next;
+		p->dtime = (__u32)jiffies;
+	}
+	spin_unlock_bh(&inet_peer_unused_lock);
+}

--Boundary_(ID_1FGYHykOkDxT3R8vlGePng)--
