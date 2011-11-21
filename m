From: Eric Dumazet <eric.dumazet@gmail.com>
Subject: Re: WARNING: at mm/slub.c:3357, kernel BUG at mm/slub.c:3413
Date: Mon, 21 Nov 2011 17:52:33 +0100
Message-ID: <1321894353.10470.19.camel@edumazet-HP-Compaq-6005-Pro-SFF-PC>
References: <20111118085436.GC1615@x4.trippels.de>
	 <20111118120201.GA1642@x4.trippels.de> <1321836285.30341.554.camel@debian>
	 <20111121080554.GB1625@x4.trippels.de>
	 <20111121082445.GD1625@x4.trippels.de>
	 <1321866988.2552.10.camel@edumazet-HP-Compaq-6005-Pro-SFF-PC>
	 <20111121131531.GA1679@x4.trippels.de>
	 <1321884966.10470.2.camel@edumazet-HP-Compaq-6005-Pro-SFF-PC>
	 <20111121153621.GA1678@x4.trippels.de>
	 <1321890510.10470.11.camel@edumazet-HP-Compaq-6005-Pro-SFF-PC>
	 <20111121161036.GA1679@x4.trippels.de>
Mime-Version: 1.0
Content-Type: text/plain; charset="UTF-8"
Content-Transfer-Encoding: quoted-printable
Cc: "Alex,Shi" <alex.shi@intel.com>, "linux-kernel@vger.kernel.org"
 <linux-kernel@vger.kernel.org>, "linux-mm@kvack.org" <linux-mm@kvack.org>,
 Christoph Lameter <cl@linux-foundation.org>, Pekka Enberg
 <penberg@kernel.org>, Matt Mackall <mpm@selenic.com>,
 "netdev@vger.kernel.org" <netdev@vger.kernel.org>, tj@kernel.org
To: Markus Trippelsdorf <markus@trippelsdorf.de>
Return-path: <owner-linux-mm@kvack.org>
In-Reply-To: <20111121161036.GA1679@x4.trippels.de>
Sender: owner-linux-mm@kvack.org
List-Id: netdev.vger.kernel.org

Le lundi 21 novembre 2011 =C3=A0 17:10 +0100, Markus Trippelsdorf a =C3=A9=
crit :

> Sure. This one happend with CONFIG_DEBUG_PAGEALLOC=3Dy:
>=20
> [drm] Initialized radeon 2.11.0 20080528 for 0000:01:05.0 on minor 0
> loop: module loaded
> ahci 0000:00:11.0: version 3.0
> ahci 0000:00:11.0: PCI INT A -> GSI 22 (level, low) -> IRQ 22
> ahci 0000:00:11.0: AHCI 0001.0100 32 slots 6 ports 3 Gbps 0x3f impl SAT=
A mode
> ahci 0000:00:11.0: flags: 64bit ncq sntf ilck pm led clo pmp pio slum p=
art ccc=20
> scsi0 : ahci
> scsi1 : ahci
> =3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=
=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=
=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=
=3D=3D=3D
> BUG task_struct: Poison overwritten
> -----------------------------------------------------------------------=
------

Unfortunately thats the same problem, not catched by DEBUG_PAGEALLOC
because freed page is immediately reused.

We should keep pages in free list longer, to have a bigger window.

Hmm...

Please try following patch :

diff --git a/mm/page_alloc.c b/mm/page_alloc.c
index 9dd443d..b8932a6 100644
--- a/mm/page_alloc.c
+++ b/mm/page_alloc.c
@@ -1196,7 +1196,7 @@ void free_hot_cold_page(struct page *page, int cold=
)
 	}
=20
 	pcp =3D &this_cpu_ptr(zone->pageset)->pcp;
-	if (cold)
+	if (IS_ENABLED(CONFIG_DEBUG_PAGEALLOC) || cold)
 		list_add_tail(&page->lru, &pcp->lists[migratetype]);
 	else
 		list_add(&page->lru, &pcp->lists[migratetype]);


--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Fight unfair telecom internet charges in Canada: sign http://stopthemeter=
.ca/
Don't email: <a href=3Dmailto:"dont@kvack.org"> email@kvack.org </a>
