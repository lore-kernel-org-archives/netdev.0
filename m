From: Eric Dumazet <eric.dumazet@gmail.com>
Subject: Re: [PATCH net-next-2.6] net: __alloc_skb() speedup
Date: Wed, 05 May 2010 14:00:09 +0200
Message-ID: <1273060809.2367.67.camel@edumazet-laptop>
References: <1272993054.2245.21.camel@edumazet-laptop>
	 <20100505.010658.48498744.davem@davemloft.net>
	 <1273047734.2367.3.camel@edumazet-laptop>
	 <20100505.012647.260083711.davem@davemloft.net>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: netdev@vger.kernel.org, hadi@cyberus.ca, therbert@google.com
To: David Miller <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-bw0-f225.google.com ([209.85.218.225]:49376 "EHLO
	mail-bw0-f225.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1753137Ab0EEMAO (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 5 May 2010 08:00:14 -0400
Received: by bwz25 with SMTP id 25so2891408bwz.28
        for <netdev@vger.kernel.org>; Wed, 05 May 2010 05:00:12 -0700 (PDT)
In-Reply-To: <20100505.012647.260083711.davem@davemloft.net>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Le mercredi 05 mai 2010 =C3=A0 01:26 -0700, David Miller a =C3=A9crit :
> From: Eric Dumazet <eric.dumazet@gmail.com>
> Date: Wed, 05 May 2010 10:22:14 +0200
>=20
> > You mean memset() wont be inlined by ompiler to plain memory writes=
, but
> > use the custom kernel memset()  ?
>=20
> I hope memset() is never inlined for a 202 byte piece of memory on
> sparc64 or powerpc.  What happens and makes sense on x86 is x86's
> business :-)
>=20
> Especially since that elides the cache invalidate optimizations, and
> for anything >=3D 64 bytes those are absolutely critical on Niagara.
> -

Sorry, I was thinking about the shinfo part :

memset(shinfo, 0, offsetof(struct skb_shared_info, dataref));

offsetof(struct skb_shared_info, dataref) is small enough and we dont
dirty a full cache line, so maybe I can keep prefetchw(data + size) ?

If not, in which cases can we use prefetchw() in kernel, if some arches
dont handle it well ?

Note1 : Without prefetchw(skb) (I removed it in this v2 patch), some
packets are dropped again...

Note2: If NET_SKB_PAD changed to 64, cpu0 has about 2% of free cpu
cycles (as noticed by a user application cycles burner)

-----------------------------------------------------------------------=
------------------------------------------------------------------
   PerfTop:    1001 irqs/sec  kernel:99.8% [1000Hz cycles],  (all, cpu:=
 0)
-----------------------------------------------------------------------=
------------------------------------------------------------------

             samples  pcnt function                      DSO
             _______ _____ _____________________________ ___________
             1018.00 16.8% eth_type_trans               =20
              960.00 15.9% __alloc_skb                  =20
              757.00 12.5% __netdev_alloc_skb           =20
              681.00 11.3% _raw_spin_lock               =20
              479.00  7.9% nommu_map_page               =20
              424.00  7.0% tg3_poll_work                =20
              209.00  3.5% get_rps_cpu                  =20
              205.00  3.4% _raw_spin_lock_irqsave       =20
              188.00  3.1% __kmalloc                   =20
              164.00  2.7% enqueue_to_backlog           =20
              119.00  2.0% tg3_alloc_rx_skb             =20
              112.00  1.9% kmem_cache_alloc             =20

Thanks !

[PATCH v2 net-next-2.6] net: __alloc_skb() speedup

With following patch I can reach maximum rate of my pktgen+udpsink
simulator :
- 'old' machine : dual quad core E5450  @3.00GHz
- 64 UDP rx flows (only differ by destination port)
- RPS enabled, NIC interrupts serviced on cpu0
- rps dispatched on 7 other cores. (~130.000 IPI per second)
- SLAB allocator (faster than SLUB in this workload)
- tg3 NIC [BCM5715S Gigabit Ethernet (rev a3)]
- 1.080.000 pps with few drops (~150 packets per second) at NIC level.
- 32bit kernel

Idea is to add one prefetchw() call in __alloc_skb() to hint cpu we are
about to clear part of skb_shared_info.

Also using one memset() to initialize all skb_shared_info fields instea=
d
of one by one to reduce number of instructions, using long word moves.

All skb_shared_info fields before 'dataref' are cleared in=20
__alloc_skb().

Signed-off-by: Eric Dumazet <eric.dumazet@gmail.com>
---
 include/linux/skbuff.h |    7 ++++++-
 net/core/skbuff.c      |   21 +++++----------------
 2 files changed, 11 insertions(+), 17 deletions(-)

diff --git a/include/linux/skbuff.h b/include/linux/skbuff.h
index 746a652..f32ccc9 100644
--- a/include/linux/skbuff.h
+++ b/include/linux/skbuff.h
@@ -187,7 +187,6 @@ union skb_shared_tx {
  * the end of the header data, ie. at skb->end.
  */
 struct skb_shared_info {
-	atomic_t	dataref;
 	unsigned short	nr_frags;
 	unsigned short	gso_size;
 	/* Warning: this field is not always filled in (UFO)! */
@@ -197,6 +196,12 @@ struct skb_shared_info {
 	union skb_shared_tx tx_flags;
 	struct sk_buff	*frag_list;
 	struct skb_shared_hwtstamps hwtstamps;
+
+	/*
+	 * Warning : all fields before dataref are cleared in __alloc_skb()
+	 */
+	atomic_t	dataref;
+=09
 	skb_frag_t	frags[MAX_SKB_FRAGS];
 	/* Intermediate layers must ensure that destructor_arg
 	 * remains valid until skb destructor */
diff --git a/net/core/skbuff.c b/net/core/skbuff.c
index 8b9c109..7cafe50 100644
--- a/net/core/skbuff.c
+++ b/net/core/skbuff.c
@@ -187,6 +187,8 @@ struct sk_buff *__alloc_skb(unsigned int size, gfp_=
t gfp_mask,
 			gfp_mask, node);
 	if (!data)
 		goto nodata;
+	/* prepare shinfo initialization */
+	prefetchw(data + size);
=20
 	/*
 	 * Only clear those fields we need to clear, not those that we will
@@ -208,15 +210,8 @@ struct sk_buff *__alloc_skb(unsigned int size, gfp=
_t gfp_mask,
=20
 	/* make sure we initialize shinfo sequentially */
 	shinfo =3D skb_shinfo(skb);
+	memset(shinfo, 0, offsetof(struct skb_shared_info, dataref));
 	atomic_set(&shinfo->dataref, 1);
-	shinfo->nr_frags  =3D 0;
-	shinfo->gso_size =3D 0;
-	shinfo->gso_segs =3D 0;
-	shinfo->gso_type =3D 0;
-	shinfo->ip6_frag_id =3D 0;
-	shinfo->tx_flags.flags =3D 0;
-	skb_frag_list_init(skb);
-	memset(&shinfo->hwtstamps, 0, sizeof(shinfo->hwtstamps));
=20
 	if (fclone) {
 		struct sk_buff *child =3D skb + 1;
@@ -505,16 +500,10 @@ int skb_recycle_check(struct sk_buff *skb, int sk=
b_size)
 		return 0;
=20
 	skb_release_head_state(skb);
+
 	shinfo =3D skb_shinfo(skb);
+	memset(shinfo, 0, offsetof(struct skb_shared_info, dataref));
 	atomic_set(&shinfo->dataref, 1);
-	shinfo->nr_frags =3D 0;
-	shinfo->gso_size =3D 0;
-	shinfo->gso_segs =3D 0;
-	shinfo->gso_type =3D 0;
-	shinfo->ip6_frag_id =3D 0;
-	shinfo->tx_flags.flags =3D 0;
-	skb_frag_list_init(skb);
-	memset(&shinfo->hwtstamps, 0, sizeof(shinfo->hwtstamps));
=20
 	memset(skb, 0, offsetof(struct sk_buff, tail));
 	skb->data =3D skb->head + NET_SKB_PAD;


