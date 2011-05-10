From: Christoph Lameter <cl@linux.com>
Subject: Re: [Bugme-new] [Bug 33502] New: Caught 64-bit read from uninitialized
 memory in __alloc_skb
Date: Tue, 10 May 2011 13:07:22 -0500 (CDT)
Message-ID: <alpine.DEB.2.00.1105101304440.4023@router.home>
References: <bug-33502-10286@https.bugzilla.kernel.org/>  <1303183217.4152.49.camel@edumazet-laptop>  <alpine.DEB.2.00.1104191210011.17888@router.home>  <1303244270.2756.3.camel@edumazet-laptop> <4DC90D7D.9030808@cs.helsinki.fi>  <1305022632.2614.18.camel@edumazet-laptop>
  <4DC91137.4030109@cs.helsinki.fi>  <a49ddd5511b74b8d9b81af8c3ef72d5a@ulrik.uio.no>  <alpine.DEB.2.00.1105101133440.2611@router.home> <1305047682.2758.1.camel@edumazet-laptop> <alpine.DEB.2.00.1105101226460.2875@router.home>
 <alpine.DEB.2.00.1105101242420.2875@router.home>
Mime-Version: 1.0
Content-Type: TEXT/PLAIN; charset=US-ASCII
Cc: Vegard Nossum <vegardno@ifi.uio.no>,
	Pekka Enberg <penberg@cs.helsinki.fi>,
	casteyde.christian@free.fr,
	Andrew Morton <akpm@linux-foundation.org>,
	netdev@vger.kernel.org, bugzilla-daemon@bugzilla.kernel.org,
	bugme-daemon@bugzilla.kernel.org
To: Eric Dumazet <eric.dumazet@gmail.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from smtp107.prem.mail.ac4.yahoo.com ([76.13.13.46]:47034 "HELO
	smtp107.prem.mail.ac4.yahoo.com" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with SMTP id S1751593Ab1EJSH1 (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 10 May 2011 14:07:27 -0400
In-Reply-To: <alpine.DEB.2.00.1105101242420.2875@router.home>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

There is a simpler version and we can get away without interrupt disable I
think. The value that we get from the read does not matter since the TID
will not match.


Subject: slub: Make CONFIG_PAGE_ALLOC work with new fastpath

Fastpath can do a speculative access to a page that CONFIG_PAGE_ALLOC may have
marked as invalid to retrieve the pointer to the next free object.

Probe that address before dereferencing the pointer to the page.

Signed-off-by: Christoph Lameter <cl@linux.com>
---
 mm/slub.c |   14 +++++++++++++-
 1 file changed, 13 insertions(+), 1 deletion(-)

Index: linux-2.6/mm/slub.c
===================================================================
--- linux-2.6.orig/mm/slub.c	2011-05-10 12:54:00.000000000 -0500
+++ linux-2.6/mm/slub.c	2011-05-10 13:04:18.000000000 -0500
@@ -261,6 +261,18 @@ static inline void *get_freepointer(stru
 	return *(void **)(object + s->offset);
 }

+static inline void *get_freepointer_safe(struct kmem_cache *s, void *object)
+{
+	void *p;
+
+#ifdef CONFIG_DEBUG_PAGEALLOC
+	probe_kernel_read(&p, (void **)(object + s->offset), sizeof(p));
+#else
+	p = get_freepointer(s, object);
+#endif
+	return p;
+}
+
 static inline void set_freepointer(struct kmem_cache *s, void *object, void *fp)
 {
 	*(void **)(object + s->offset) = fp;
@@ -1943,7 +1955,7 @@ redo:
 		if (unlikely(!irqsafe_cpu_cmpxchg_double(
 				s->cpu_slab->freelist, s->cpu_slab->tid,
 				object, tid,
-				get_freepointer(s, object), next_tid(tid)))) {
+				get_freepointer_safe(s, object), next_tid(tid)))) {

 			note_cmpxchg_failure("slab_alloc", s, tid);
 			goto redo;
