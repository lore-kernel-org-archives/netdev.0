From: Eric Dumazet <eric.dumazet@gmail.com>
Subject: [PATCH] slub: fix slab_pad_check() and SLAB_DESTROY_BY_RCU
Date: Thu, 03 Sep 2009 03:04:32 +0200
Message-ID: <4A9F1620.2080105@gmail.com>
References: <c4e36d110908110542l3de51aaepcbd62c84b9848f2b@mail.gmail.com>	 <c4e36d110908111410y29b922ceod6871fda2514f6e6@mail.gmail.com>	 <c4e36d110908121516u504809e9y537e9babfa95df1d@mail.gmail.com>	 <alpine.DEB.1.10.0908121820410.3257@gentwo.org>	 <c4e36d110908131009l78b29bffvb4d41b90f9b83288@mail.gmail.com>	 <c4e36d110908140233v59421ba6y82192b858210370d@mail.gmail.com>	 <4A87CE60.4020506@gmail.com> <4A896324.3040104@trash.net>	 <c4e36d110909021445l5f44183es9e338437dfbbd195@mail.gmail.com>	 <4A9EEF07.5070800@gmail.com> <c4e36d110909021531v324a9ce2x3ff2c93b7c5a57de@mail.gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: Patrick McHardy <kaber@trash.net>,
	Christoph Lameter <cl@linux-foundation.org>,
	Robin Holt <holt@sgi.com>,
	Linux Kernel Mailing List <linux-kernel@vger.kernel.org>,
	Pekka Enberg <penberg@cs.helsinki.fi>,
	Jesper Dangaard Brouer <hawk@comx.dk>,
	Linux Netdev List <netdev@vger.kernel.org>,
	Netfilter Developers <netfilter-devel@vger.kernel.org>
To: Zdenek Kabelac <zdenek.kabelac@gmail.com>
Return-path: <linux-kernel-owner+glk-linux-kernel-3=40m.gmane.org-S1753995AbZICBIX@vger.kernel.org>
In-Reply-To: <c4e36d110909021531v324a9ce2x3ff2c93b7c5a57de@mail.gmail.com>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Zdenek Kabelac a =E9crit :
>=20
> Well I'm not noticing any ill behavior - also note - rcu_barrier() is
> there before the cache is destroyed.
> But as I said - it's just my shot into the dark - which seems to work=
 for me...
>=20

Reading again your traces, I do believe there are two bugs in slub

Maybe not explaining your problem, but worth to fix !

Thank you

[PATCH] slub: fix slab_pad_check() and SLAB_DESTROY_BY_RCU

When SLAB_POISON is used and slab_pad_check() finds an overwrite of the
slab padding, we call restore_bytes() on the whole slab, not only
on the padding.

kmem_cache_destroy() should call rcu_barrier() *after* kmem_cache_close=
()
and *before* sysfs_slab_remove() or risk rcu_free_slab()
being called after kmem_cache is deleted (kfreed).

rmmod nf_conntrack can crash the machine because it has to
kmem_cache_destroy() a SLAB_DESTROY_BY_RCU enabled cache.

Reported-by: Zdenek Kabelac <zdenek.kabelac@gmail.com>
Signed-off-by: Eric Dumazet <eric.dumazet@gmail.com>
---
diff --git a/mm/slub.c b/mm/slub.c
index b9f1491..0ac839f 100644
--- a/mm/slub.c
+++ b/mm/slub.c
@@ -646,7 +646,7 @@ static int slab_pad_check(struct kmem_cache *s, str=
uct page *page)
 	slab_err(s, page, "Padding overwritten. 0x%p-0x%p", fault, end - 1);
 	print_section("Padding", end - remainder, remainder);
=20
-	restore_bytes(s, "slab padding", POISON_INUSE, start, end);
+	restore_bytes(s, "slab padding", POISON_INUSE, end - remainder, end);
 	return 0;
 }
=20
@@ -2594,8 +2594,6 @@ static inline int kmem_cache_close(struct kmem_ca=
che *s)
  */
 void kmem_cache_destroy(struct kmem_cache *s)
 {
-	if (s->flags & SLAB_DESTROY_BY_RCU)
-		rcu_barrier();
 	down_write(&slub_lock);
 	s->refcount--;
 	if (!s->refcount) {
@@ -2606,6 +2604,8 @@ void kmem_cache_destroy(struct kmem_cache *s)
 				"still has objects.\n", s->name, __func__);
 			dump_stack();
 		}
+		if (s->flags & SLAB_DESTROY_BY_RCU)
+			rcu_barrier();
 		sysfs_slab_remove(s);
 	} else
 		up_write(&slub_lock);
