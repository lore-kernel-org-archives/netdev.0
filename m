From: Eric Dumazet <eric.dumazet@gmail.com>
Subject: Re: [2.6.35-rc1] page alloc failure order:1, mode:0x4020
Date: Fri, 04 Jun 2010 14:53:34 +0200
Message-ID: <1275656014.2482.169.camel@edumazet-laptop>
References: <20100604092025.GA96690@trillian.comsick.at>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: linux-kernel <linux-kernel@vger.kernel.org>,
	netdev <netdev@vger.kernel.org>
To: Michael Guntsche <mike@it-loops.com>
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <20100604092025.GA96690@trillian.comsick.at>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Le vendredi 04 juin 2010 =C3=A0 11:20 +0200, Michael Guntsche a =C3=A9c=
rit :
> Hi list,
>=20
> Testing 2.6.35-rc1 on my powerpc based routerboard I saw the followin=
g page allocation
> error happening during an apt-get update with a semi loaded wlan
> interface
>=20
> [309611.189267] __alloc_pages_slowpath: 52 callbacks suppressed
> [309611.194959] gzip: page allocation failure. order:1, mode:0x4020
> [309611.200981] Call Trace:
> [309611.203547] [c399bc50] [c0008144] show_stack+0x48/0x15c (unreliab=
le)
> [309611.210041] [c399bc80] [c006268c] __alloc_pages_nodemask+0x3d4/0x=
52c
> [309611.216512] [c399bd20] [c008619c] __slab_alloc+0x560/0x570
> [309611.222111] [c399bd60] [c0086a98] __kmalloc_track_caller+0xd4/0x1=
04
> [309611.228505] [c399bd80] [c01dd220] __alloc_skb+0x64/0x124
> [309611.233944] [c399bda0] [c994e034] ath_rxbuf_alloc+0x34/0xbc [ath]
> [309611.240178] [c399bdc0] [c9a1ec9c] ath_rx_tasklet+0x480/0x7c4 [ath=
9k]
> [309611.246658] [c399be80] [c9a1dae0] ath9k_tasklet+0x114/0x13c [ath9=
k]
> [309611.253055] [c399bea0] [c002532c] tasklet_action+0x88/0x104
> [309611.258746] [c399bec0] [c0025e30] __do_softirq+0xb4/0x134
> [309611.264261] [c399bf00] [c0005ec4] do_softirq+0x58/0x5c
> [309611.269514] [c399bf10] [c0025c20] irq_exit+0x7c/0x9c
> [309611.274591] [c399bf20] [c0005f64] do_IRQ+0x9c/0xb4
> [309611.279509] [c399bf40] [c00117d8] ret_from_except+0x0/0x14
> [309611.285112] --- Exception: 501 at 0xff31f0c
> [309611.285121]     LR =3D 0xff32548
> [309611.292536] Mem-Info:
> [309611.294899] DMA per-cpu:
> [309611.297528] CPU    0: hi:   42, btch:   7 usd:  18
> [309611.302444] active_anon:1040 inactive_anon:1160 isolated_anon:0
> [309611.302455]  active_file:14871 inactive_file:9440 isolated_file:0
> [309611.302467]  unevictable:491 dirty:1258 writeback:0 unstable:0
> [309611.302478]  free:628 slab_reclaimable:832 slab_unreclaimable:231=
2
> [309611.302490]  mapped:2254 shmem:36 pagetables:202 bounce:0
> [309611.332409] DMA free:2512kB min:1440kB low:1800kB high:2160kB act=
ive_anon:4160kB inactive_anon:4640kB active_file:59484kB inactive_file:=
37760kB unevictable:1964kB isolated(anon):0kB isolated(file):0kB presen=
t:130048kB mlocked:1964kB dirty:5032kB writeback:0kB mapped:9016kB shme=
m:144kB slab_reclaimable:3328kB slab_unreclaimable:9248kB kernel_stack:=
528kB pagetables:808kB unstable:0kB bounce:0kB writeback_tmp:0kB pages_=
scanned:0 all_unreclaimable? no
> [309611.372230] lowmem_reserve[]: 0 0 0
> [309611.375835] DMA: 596*4kB 14*8kB 1*16kB 0*32kB 0*64kB 0*128kB 0*25=
6kB 0*512kB 0*1024kB 0*2048kB 0*4096kB =3D 2512kB
> [309611.386215] 24770 total pagecache pages
> [309611.390147] 0 pages in swap cache
> [309611.393559] Swap cache stats: add 0, delete 0, find 0/0
> [309611.398884] Free swap  =3D 0kB
> [309611.401857] Total swap =3D 0kB
> [309611.411877] 32768 pages RAM
> [309611.414765] 1228 pages reserved
> [309611.418000] 27690 pages shared
> [309611.421147] 8802 pages non-shared
> [309611.424560] SLUB: Unable to allocate memory on node -1 (gfp=3D0x2=
0)
> [309611.430764]   cache: kmalloc-8192, object size: 8192, buffer size=
: 8192, default order: 3, min order: 1
> [309611.440276]   node 0: slabs: 155, objs: 620, free: 0
> [309611.445439] skbuff alloc of size 3872 failed

order-1 allocations are unfortunate, since this hardware should use
order-0 ones if possible, and it seems it was its goal.

3872 (0xF20) comes from=20

#define IEEE80211_MAX_MPDU_LEN     (3840 + FCS_LEN +
	(IEEE80211_WEP_IVLEN +  \
	IEEE80211_WEP_KIDLEN + \
	IEEE80211_WEP_CRCLEN))

common->rx_bufsize =3D roundup(IEEE80211_MAX_MPDU_LEN +
	ah->caps.rx_status_len,
	min(common->cachelsz, (u16)64));

Then __dev_alloc_skb() adds two more blocs :

NET_SKB_PAD  (64 bytes on your platform ?)

sizeof(struct skb_shared_info)=20
(on 32bit : 0x104 ... oh well that might be the problem : it is rounded
to 0x140)


And ath driver adds common->cachelsz  (I dont know its value)

-> more than 4096 bytes

1) Maybe rx_bufsize should not include the roundup() since=20
ath_rxbuf_alloc() also do an alignment adjustment ?

2) We should try to reduce skb_shared_info by four bytes.

Could you try this patch ?


We make sure rx_bufsize + various overhead <=3D PAGE_SIZE
But I am not sure its legal for the hardware...

diff --git a/drivers/net/wireless/ath/ath9k/recv.c b/drivers/net/wirele=
ss/ath/ath9k/recv.c
index ca6065b..0a0dc3a 100644
--- a/drivers/net/wireless/ath/ath9k/recv.c
+++ b/drivers/net/wireless/ath/ath9k/recv.c
@@ -226,10 +226,10 @@ static int ath_rx_edma_init(struct ath_softc *sc,=
 int nbufs)
 	u32 size;
=20
=20
-	common->rx_bufsize =3D roundup(IEEE80211_MAX_MPDU_LEN +
-				     ah->caps.rx_status_len,
-				     min(common->cachelsz, (u16)64));
-
+	size =3D roundup(IEEE80211_MAX_MPDU_LEN + ah->caps.rx_status_len,
+		       min(common->cachelsz, (u16)64));
+	common->rx_bufsize =3D max_t(u32, size,
+				   SKB_MAX_ORDER(NET_SKB_PAD + common->cachelsz, 0));
 	ath9k_hw_set_rx_bufsize(ah, common->rx_bufsize -
 				    ah->caps.rx_status_len);
=20
