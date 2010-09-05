From: =?UTF-8?B?TmlraGlsIFNldGhpICjgpKjgpL/gpJbgpL/gpLIg4KS44KWH4KSg4KWAKQ==?=
	<nikhil@sethi.ws>
Subject: Re: [2.6.35-rc1] page alloc failure order:1, mode:0x4020
Date: Sun, 5 Sep 2010 08:57:56 -0700
Message-ID: <AANLkTimzJFW7dgik6S0zRwYsv4gP5g9Wmonci48dbbei@mail.gmail.com>
References: <20100604092025.GA96690@trillian.comsick.at> <1275656014.2482.169.camel@edumazet-laptop>
 <20100604161644.GA98048@trillian.local> <20100606095640.GA4436@trillian.comsick.at>
 <1275820945.5238.987.camel@edumazet-laptop> <AANLkTimf5iZV2ytoymCXJ=B2Vgowr6qb6u2nBg+RtBUg@mail.gmail.com>
 <1282769089.2681.159.camel@edumazet-laptop> <AANLkTi=TU8d8tsp28qN-Rz9z0hTcH7hRE=d8W4GKhrkk@mail.gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: Michael Guntsche <mike@it-loops.com>,
	linux-kernel <linux-kernel@vger.kernel.org>,
	netdev <netdev@vger.kernel.org>
To: Eric Dumazet <eric.dumazet@gmail.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-ww0-f42.google.com ([74.125.82.42]:37459 "EHLO
	mail-ww0-f42.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752430Ab0IEP6i convert rfc822-to-8bit (ORCPT
	<rfc822;netdev@vger.kernel.org>); Sun, 5 Sep 2010 11:58:38 -0400
In-Reply-To: <AANLkTi=TU8d8tsp28qN-Rz9z0hTcH7hRE=d8W4GKhrkk@mail.gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

This came back. Here is the dmesg output. It might be the problem only
happens if I have wmm_enabled=3D1 in my hostapd.conf. That is the only
thing that I changed yesterday, and today I saw these messages in my
logs. I will try to conform this.

I am running 2.6.35.4 with this patch:

*** 225,234 ****
  	int error =3D 0, i;
  	u32 size;

!
! 	common->rx_bufsize =3D roundup(IEEE80211_MAX_MPDU_LEN +
! 				     ah->caps.rx_status_len,
! 				     min(common->cachelsz, (u16)64));

  	ath9k_hw_set_rx_bufsize(ah, common->rx_bufsize -
  				    ah->caps.rx_status_len);
--- 225,234 ----
  	int error =3D 0, i;
  	u32 size;

! 	size =3D roundup(IEEE80211_MAX_MPDU_LEN + ah->caps.rx_status_len,
!                        min(common->cachelsz, (u16)64));
!         common->rx_bufsize =3D min_t(u32, size,
!                                    SKB_MAX_ORDER(NET_SKB_PAD +
common->cachelsz, 0));

  	ath9k_hw_set_rx_bufsize(ah, common->rx_bufsize -
  				    ah->caps.rx_status_len);

dmesg output:

skbuff alloc of size 3872 failed
ps: page allocation failure. order:1, mode:0x4020
Pid: 16022, comm: ps Tainted: G        W   2.6.35.4 #1
Call Trace:
 [<c0243bfe>] ? __alloc_pages_nodemask+0x3e6/0x513
 [<c025be97>] ? slob_new_pages+0xc/0x23
 [<c025c0a1>] ? __kmalloc_node+0x39/0x72
 [<c03338d8>] ? __alloc_skb+0x5c/0x105
 [<d09fa01a>] ? ath_rxbuf_alloc+0x1a/0x78 [ath]
 [<d0ab7109>] ? ath_rx_tasklet+0x2fb/0x808 [ath9k]
 [<c030fd49>] ? scsi_next_command+0x27/0x34
 [<d0ab53c5>] ? ath9k_tasklet+0xcc/0x107 [ath9k]
 [<c02193c3>] ? tasklet_action+0x5f/0x65
 [<c0219677>] ? __do_softirq+0x60/0xc6
 [<c021970b>] ? do_softirq+0x2e/0x30
 [<c02197fd>] ? irq_exit+0x53/0x55
 [<c020392c>] ? do_IRQ+0x3a/0x72
 [<c0202be9>] ? common_interrupt+0x29/0x30
 [<c0247874>] ? __remove_mapping+0x4b/0x8d
 [<c023ea9f>] ? try_to_release_page+0x20/0x30
 [<c0247d36>] ? shrink_page_list+0x2b8/0x46c
 [<c03158ea>] ? sd_prep_fn+0x1a5/0x92b
 [<c024816b>] ? shrink_inactive_list+0x281/0x552
 [<c02445d9>] ? determine_dirtyable_memory+0xc/0x12
 [<c024462c>] ? get_dirty_limits+0x18/0x2b0
 [<c032875e>] ? ata_bmdma_port_intr+0x21/0xcd
 [<c0248683>] ? shrink_zone+0x247/0x38f
 [<c021968c>] ? __do_softirq+0x75/0xc6
 [<c0247114>] ? shrink_slab+0x13c/0x186
 [<c0248f25>] ? try_to_free_pages+0x1ab/0x2be
 [<c0248f25>] ? try_to_free_pages+0x1ab/0x2be
 [<c0243acf>] ? __alloc_pages_nodemask+0x2b7/0x513
 [<c025be97>] ? slob_new_pages+0xc/0x23
 [<c025c038>] ? kmem_cache_alloc_node+0x23/0x53
 [<c0264b20>] ? getname+0x19/0xae
 [<c0266d00>] ? user_path_at+0x11/0x64
 [<c0250949>] ? access_process_vm+0xe0/0x1e7
 [<c0250a08>] ? access_process_vm+0x19f/0x1e7
 [<c02603d2>] ? vfs_fstatat+0x25/0x63
 [<c02604a9>] ? vfs_stat+0x10/0x12
 [<c02604ba>] ? sys_stat64+0xf/0x23
 [<c025e86b>] ? fput+0x88/0x191
 [<c026ab3b>] ? dput+0x92/0xd4
 [<c025e8ff>] ? fput+0x11c/0x191
 [<c026ebec>] ? mntput_no_expire+0x13/0x60
 [<c025c398>] ? filp_close+0x3b/0x54
 [<c025c403>] ? sys_close+0x52/0x72
 [<c038ad3d>] ? syscall_call+0x7/0xb
 [<c0380000>] ? unix_dgram_sendmsg+0x258/0x3c1
Mem-Info:
DMA per-cpu:
CPU    0: hi:    0, btch:   1 usd:   0
Normal per-cpu:
CPU    0: hi:   90, btch:  15 usd:  79
active_anon:7578 inactive_anon:15111 isolated_anon:0
 active_file:11157 inactive_file:20027 isolated_file:32
 unevictable:467 dirty:1159 writeback:0 unstable:0
 free:706 slab_reclaimable:0 slab_unreclaimable:0
 mapped:2183 shmem:0 pagetables:278 bounce:0
DMA free:1000kB min:124kB low:152kB high:184kB active_anon:860kB
inactive_anon:2280kB active_file:3664kB inactive_file:4876kB
unevictable:0kB isolated(anon):0kB isolated(file):0kB present:15864kB
mlocked:0kB dirty:8kB writeback:0kB mapped:1212kB shmem:0kB
slab_reclaimable:0kB slab_unreclaimable:0kB kernel_stack:32kB
pagetables:48kB unstable:0kB bounce:0kB writeback_tmp:0kB
pages_scanned:0 all_unreclaimable? no
lowmem_reserve[]: 0 238 238
Normal free:1824kB min:1908kB low:2384kB high:2860kB
active_anon:29452kB inactive_anon:58164kB active_file:40964kB
inactive_file:75232kB unevictable:1868kB isolated(anon):0kB
isolated(file):128kB present:243840kB mlocked:1868kB dirty:4628kB
writeback:0kB mapped:7520kB shmem:0kB slab_reclaimable:0kB
slab_unreclaimable:0kB kernel_stack:1056kB pagetables:1064kB
unstable:0kB bounce:0kB writeback_tmp:0kB pages_scanned:0
all_unreclaimable? no
lowmem_reserve[]: 0 0 0
DMA: 2*4kB 0*8kB 0*16kB 1*32kB 1*64kB 1*128kB 1*256kB 1*512kB 0*1024kB
0*2048kB 0*4096kB =3D 1000kB
Normal: 366*4kB 45*8kB 0*16kB 0*32kB 0*64kB 0*128kB 0*256kB 0*512kB
0*1024kB 0*2048kB 0*4096kB =3D 1824kB
35298 total pagecache pages
3724 pages in swap cache
Swap cache stats: add 82399, delete 78675, find 45215/53344
=46ree swap  =3D 891536kB
Total swap =3D 963896kB
65535 pages RAM
1236 pages reserved
36808 pages shared
32201 pages non-shared
skbuff alloc of size 3872 failed
skbuff alloc of size 3872 failed
skbuff alloc of size 3872 failed
skbuff alloc of size 3872 failed
skbuff alloc of size 3872 failed
skbuff alloc of size 3872 failed
skbuff alloc of size 3872 failed
skbuff alloc of size 3872 failed
skbuff alloc of size 3872 failed
skbuff alloc of size 3872 failed
skbuff alloc of size 3872 failed
skbuff alloc of size 3872 failed
skbuff alloc of size 3872 failed
logdrop IN=3Deth0 OUT=3D MAC=3D00:00:24:cb:ca:c4:00:01:5c:32:6e:41:08:0=
0
SRC=3D219.143.125.205 DST=3D98.248.43.157 LEN=3D60 TOS=3D0x00 PREC=3D0x=
20 TTL=3D50
ID=3D362 DF PROTO=3DTCP SPT=3D53976 DPT=3D22 WINDOW=3D5840 RES=3D0x00 S=
YN URGP=3D0
OPT (020405640402080A1EDFFF550000000001030303)
__alloc_pages_slowpath: 12 callbacks suppressed
swapper: page allocation failure. order:1, mode:0x4020
Pid: 0, comm: swapper Tainted: G        W   2.6.35.4 #1
Call Trace:
 [<c0243bfe>] ? __alloc_pages_nodemask+0x3e6/0x513
 [<c025be97>] ? slob_new_pages+0xc/0x23
 [<c025c0a1>] ? __kmalloc_node+0x39/0x72
 [<c03338d8>] ? __alloc_skb+0x5c/0x105
 [<d09fa01a>] ? ath_rxbuf_alloc+0x1a/0x78 [ath]
 [<d0ab7109>] ? ath_rx_tasklet+0x2fb/0x808 [ath9k]
 [<d0ab53c5>] ? ath9k_tasklet+0xcc/0x107 [ath9k]
 [<c02193c3>] ? tasklet_action+0x5f/0x65
 [<c0219677>] ? __do_softirq+0x60/0xc6
 [<c021970b>] ? do_softirq+0x2e/0x30
 [<c02197fd>] ? irq_exit+0x53/0x55
 [<c020392c>] ? do_IRQ+0x3a/0x72
 [<c0202be9>] ? common_interrupt+0x29/0x30
 [<c020768e>] ? default_idle+0x25/0x38
 [<c02017d0>] ? cpu_idle+0x2e/0x47
 [<c042361a>] ? start_kernel+0x21a/0x21d
Mem-Info:
DMA per-cpu:
CPU    0: hi:    0, btch:   1 usd:   0
Normal per-cpu:
CPU    0: hi:   90, btch:  15 usd:  13
active_anon:11994 inactive_anon:12762 isolated_anon:0
 active_file:13736 inactive_file:14175 isolated_file:0
 unevictable:467 dirty:5803 writeback:9 unstable:0
 free:2013 slab_reclaimable:0 slab_unreclaimable:0
 mapped:1957 shmem:0 pagetables:281 bounce:0
DMA free:1000kB min:124kB low:152kB high:184kB active_anon:944kB
inactive_anon:2640kB active_file:4020kB inactive_file:4000kB
unevictable:0kB isolated(anon):0kB isolated(file):0kB present:15864kB
mlocked:0kB dirty:48kB writeback:0kB mapped:452kB shmem:0kB
slab_reclaimable:0kB slab_unreclaimable:0kB kernel_stack:24kB
pagetables:24kB unstable:0kB bounce:0kB writeback_tmp:0kB
pages_scanned:0 all_unreclaimable? no
lowmem_reserve[]: 0 238 238
Normal free:7052kB min:1908kB low:2384kB high:2860kB
active_anon:47032kB inactive_anon:48408kB active_file:50924kB
inactive_file:52700kB unevictable:1868kB isolated(anon):0kB
isolated(file):0kB present:243840kB mlocked:1868kB dirty:23164kB
writeback:36kB mapped:7376kB shmem:0kB slab_reclaimable:0kB
slab_unreclaimable:0kB kernel_stack:1040kB pagetables:1100kB
unstable:0kB bounce:0kB writeback_tmp:0kB pages_scanned:0
all_unreclaimable? no
lowmem_reserve[]: 0 0 0
DMA: 2*4kB 0*8kB 0*16kB 1*32kB 1*64kB 1*128kB 1*256kB 1*512kB 0*1024kB
0*2048kB 0*4096kB =3D 1000kB
Normal: 1673*4kB 45*8kB 0*16kB 0*32kB 0*64kB 0*128kB 0*256kB 0*512kB
0*1024kB 0*2048kB 0*4096kB =3D 7052kB
32351 total pagecache pages
4052 pages in swap cache
Swap cache stats: add 119272, delete 115220, find 58684/72663
=46ree swap  =3D 874472kB
Total swap =3D 963896kB
65535 pages RAM
1236 pages reserved
30733 pages shared
36511 pages non-shared
skbuff alloc of size 3872 failed
swapper: page allocation failure. order:1, mode:0x4020
Pid: 0, comm: swapper Tainted: G        W   2.6.35.4 #1
Call Trace:
 [<c0243bfe>] ? __alloc_pages_nodemask+0x3e6/0x513
 [<c025be97>] ? slob_new_pages+0xc/0x23
 [<c025c0a1>] ? __kmalloc_node+0x39/0x72
 [<c03338d8>] ? __alloc_skb+0x5c/0x105
 [<d09fa01a>] ? ath_rxbuf_alloc+0x1a/0x78 [ath]
 [<d0ab7109>] ? ath_rx_tasklet+0x2fb/0x808 [ath9k]
 [<d0ab53c5>] ? ath9k_tasklet+0xcc/0x107 [ath9k]
 [<c02193c3>] ? tasklet_action+0x5f/0x65
 [<c0219677>] ? __do_softirq+0x60/0xc6
 [<c021970b>] ? do_softirq+0x2e/0x30
 [<c02197fd>] ? irq_exit+0x53/0x55
 [<c020392c>] ? do_IRQ+0x3a/0x72
 [<c0202be9>] ? common_interrupt+0x29/0x30
 [<c020768e>] ? default_idle+0x25/0x38
 [<c02017d0>] ? cpu_idle+0x2e/0x47
 [<c042361a>] ? start_kernel+0x21a/0x21d
Mem-Info:
DMA per-cpu:
CPU    0: hi:    0, btch:   1 usd:   0
Normal per-cpu:
CPU    0: hi:   90, btch:  15 usd:  13


2010/8/26 Nikhil Sethi (=E0=A4=A8=E0=A4=BF=E0=A4=96=E0=A4=BF=E0=A4=B2 =E0=
=A4=B8=E0=A5=87=E0=A4=A0=E0=A5=80) <nikhil@sethi.ws>
>
> Thanks Eric. I have not been able to reproduce this problem after
> applying your new patch in about 12 hours of operation. Will let you
> know if the bug re-appears.
>
> Thanks
> Nikhil
>
> 2010/8/25 Eric Dumazet <eric.dumazet@gmail.com>:
> > Le mercredi 25 ao=C3=BBt 2010 =C3=A0 13:25 -0700, Nikhil Sethi (=E0=
=A4=A8=E0=A4=BF=E0=A4=96=E0=A4=BF=E0=A4=B2 =E0=A4=B8=E0=A5=87=E0=A4=A0=E0=
=A5=80) a
> > =C3=A9crit :
> >> Hello.
> >>
> >> I am running 2.5.35.3 with the above patch, and I still get these
> >> failures. Though they are much less often than without the patch. =
A
> >> snippet from dmesg below.
> >>
> >> Please let me know what other details I should provide. Thanks
> >>
> >> skbuff alloc of size 3872 failed
> >> java: page allocation failure. order:1, mode:0x4020
> >> Pid: 11464, comm: java Not tainted 2.6.35.3 #3
> >> Call Trace:
> >> =C2=A0[<c0243d26>] ? __alloc_pages_nodemask+0x3e6/0x513
> >> =C2=A0[<c025c293>] ? __slab_alloc+0x2d7/0x2eb
> >> =C2=A0[<c025c946>] ? __kmalloc_track_caller+0x74/0x95
> >> =C2=A0[<d09e801a>] ? ath_rxbuf_alloc+0x1a/0x78 [ath]
> >> =C2=A0[<d09e801a>] ? ath_rxbuf_alloc+0x1a/0x78 [ath]
> >> =C2=A0[<c0334097>] ? __alloc_skb+0x57/0x100
> >> =C2=A0[<d09e801a>] ? ath_rxbuf_alloc+0x1a/0x78 [ath]
> >> =C2=A0[<d0af4100>] ? ath_rx_tasklet+0x2fb/0x808 [ath9k]
> >> =C2=A0[<d0cbc89f>] ? br_handle_frame+0x1b3/0x1c3 [bridge]
> >> =C2=A0[<c033d18a>] ? __netif_receive_skb+0x141/0x25f
> >> =C2=A0[<d0af23c1>] ? ath9k_tasklet+0xcc/0x107 [ath9k]
> >> =C2=A0[<c02195bf>] ? tasklet_action+0x5f/0x65
> >> =C2=A0[<c0219873>] ? __do_softirq+0x60/0xc6
> >> =C2=A0[<c0219907>] ? do_softirq+0x2e/0x30
> >> =C2=A0[<c02199f9>] ? irq_exit+0x53/0x55
> >> =C2=A0[<c020392c>] ? do_IRQ+0x3a/0x72
> >> =C2=A0[<c0202be9>] ? common_interrupt+0x29/0x30
> >> Mem-Info:
> >> DMA per-cpu:
> >> CPU =C2=A0 =C2=A00: hi: =C2=A0 =C2=A00, btch: =C2=A0 1 usd: =C2=A0=
 0
> >> Normal per-cpu:
> >> CPU =C2=A0 =C2=A00: hi: =C2=A0 90, btch: =C2=A015 usd: =C2=A032
> >> active_anon:6158 inactive_anon:15748 isolated_anon:0
> >> =C2=A0active_file:11477 inactive_file:22926 isolated_file:0
> >> =C2=A0unevictable:468 dirty:5788 writeback:0 unstable:0
> >> =C2=A0free:990 slab_reclaimable:3091 slab_unreclaimable:2349
> >> =C2=A0mapped:1410 shmem:5 pagetables:227 bounce:0
> >> DMA free:1000kB min:124kB low:152kB high:184kB active_anon:1304kB
> >> inactive_anon:2304kB active_file:2584kB inactive_file:4900kB
> >> unevictable:0kB isolated(anon):0kB isolated(file):0kB present:1586=
4kB
> >> mlocked:0kB dirty:0kB writeback:0kB mapped:284kB shmem:0kB
> >> slab_reclaimable:648kB slab_unreclaimable:752kB kernel_stack:152kB
> >> pagetables:0kB unstable:0kB bounce:0kB writeback_tmp:0kB
> >> pages_scanned:0 all_unreclaimable? no
> >> lowmem_reserve[]: 0 238 238
> >> Normal free:2960kB min:1908kB low:2384kB high:2860kB
> >> active_anon:23328kB inactive_anon:60688kB active_file:43324kB
> >> inactive_file:86804kB unevictable:1872kB isolated(anon):0kB
> >> isolated(file):0kB present:243840kB mlocked:1872kB dirty:23152kB
> >> writeback:0kB mapped:5356kB shmem:20kB slab_reclaimable:11716kB
> >> slab_unreclaimable:8644kB kernel_stack:888kB pagetables:908kB
> >> unstable:0kB bounce:0kB writeback_tmp:0kB pages_scanned:0
> >> all_unreclaimable? no
> >> lowmem_reserve[]: 0 0 0
> >> DMA: 76*4kB 29*8kB 5*16kB 0*32kB 0*64kB 1*128kB 1*256kB 0*512kB
> >> 0*1024kB 0*2048kB 0*4096kB =3D 1000kB
> >> Normal: 650*4kB 9*8kB 2*16kB 8*32kB 0*64kB 0*128kB 0*256kB 0*512kB
> >> 0*1024kB 0*2048kB 0*4096kB =3D 2960kB
> >> 37964 total pagecache pages
> >> 3160 pages in swap cache
> >> Swap cache stats: add 164954, delete 161794, find 97931/115609
> >> Free swap =C2=A0=3D 937284kB
> >> Total swap =3D 963896kB
> >> 65535 pages RAM
> >> 1237 pages reserved
> >> 29042 pages shared
> >> 38802 pages non-shared
> >> SLUB: Unable to allocate memory on node -1 (gfp=3D0x20)
> >> =C2=A0 cache: kmalloc-8192, object size: 8192, buffer size: 8192, =
default
> >> order: 3, min order: 1
> >> =C2=A0 node 0: slabs: 0, objs: 0, free: 0
> >> skbuff alloc of size 3872 failed
> >> java: page allocation failure. order:1, mode:0x4020
> >> Pid: 11464, comm: java Not tainted 2.6.35.3 #3
> >> Call Trace:
> >> =C2=A0[<c0243d26>] ? __alloc_pages_nodemask+0x3e6/0x513
> >> =C2=A0[<c025c293>] ? __slab_alloc+0x2d7/0x2eb
> >> =C2=A0[<c025c946>] ? __kmalloc_track_caller+0x74/0x95
> >> =C2=A0[<d09e801a>] ? ath_rxbuf_alloc+0x1a/0x78 [ath]
> >> =C2=A0[<d09e801a>] ? ath_rxbuf_alloc+0x1a/0x78 [ath]
> >> =C2=A0[<c0334097>] ? __alloc_skb+0x57/0x100
> >> =C2=A0[<d09e801a>] ? ath_rxbuf_alloc+0x1a/0x78 [ath]
> >> =C2=A0[<d0af4100>] ? ath_rx_tasklet+0x2fb/0x808 [ath9k]
> >> =C2=A0[<d0cbc89f>] ? br_handle_frame+0x1b3/0x1c3 [bridge]
> >> =C2=A0[<c033d18a>] ? __netif_receive_skb+0x141/0x25f
> >> =C2=A0[<d0af23c1>] ? ath9k_tasklet+0xcc/0x107 [ath9k]
> >> =C2=A0[<c02195bf>] ? tasklet_action+0x5f/0x65
> >> =C2=A0[<c0219873>] ? __do_softirq+0x60/0xc6
> >> =C2=A0[<c0219907>] ? do_softirq+0x2e/0x30
> >> =C2=A0[<c02199f9>] ? irq_exit+0x53/0x55
> >> =C2=A0[<c020392c>] ? do_IRQ+0x3a/0x72
> >> =C2=A0[<c0202be9>] ? common_interrupt+0x29/0x30
> >> Mem-Info:
> >> DMA per-cpu:
> >> CPU =C2=A0 =C2=A00: hi: =C2=A0 =C2=A00, btch: =C2=A0 1 usd: =C2=A0=
 0
> >> Normal per-cpu:
> >> CPU =C2=A0 =C2=A00: hi: =C2=A0 90, btch: =C2=A015 usd: =C2=A032
> >> active_anon:6158 inactive_anon:15748 isolated_anon:0
> >> =C2=A0active_file:11477 inactive_file:22926 isolated_file:0
> >> =C2=A0unevictable:468 dirty:5788 writeback:0 unstable:0
> >> =C2=A0free:990 slab_reclaimable:3091 slab_unreclaimable:2349
> >> =C2=A0mapped:1410 shmem:5 pagetables:227 bounce:0
> >> DMA free:1000kB min:124kB low:152kB high:184kB active_anon:1304kB
> >> inactive_anon:2304kB active_file:2584kB inactive_file:4900kB
> >> unevictable:0kB isolated(anon):0kB isolated(file):0kB present:1586=
4kB
> >> mlocked:0kB dirty:0kB writeback:0kB mapped:284kB shmem:0kB
> >> slab_reclaimable:648kB slab_unreclaimable:752kB kernel_stack:152kB
> >> pagetables:0kB unstable:0kB bounce:0kB writeback_tmp:0kB
> >> pages_scanned:0 all_unreclaimable? no
> >> lowmem_reserve[]: 0 238 238
> >> Normal free:2960kB min:1908kB low:2384kB high:2860kB
> >> active_anon:23328kB inactive_anon:60688kB active_file:43324kB
> >> inactive_file:86804kB unevictable:1872kB isolated(anon):0kB
> >> isolated(file):0kB present:243840kB mlocked:1872kB dirty:23152kB
> >> writeback:0kB mapped:5356kB shmem:20kB slab_reclaimable:11716kB
> >> slab_unreclaimable:8644kB kernel_stack:888kB pagetables:908kB
> >> unstable:0kB bounce:0kB writeback_tmp:0kB pages_scanned:0
> >> all_unreclaimable? no
> >> lowmem_reserve[]: 0 0 0
> >> DMA: 76*4kB 29*8kB 5*16kB 0*32kB 0*64kB 1*128kB 1*256kB 0*512kB
> >> 0*1024kB 0*2048kB 0*4096kB =3D 1000kB
> >> Normal: 650*4kB 9*8kB 2*16kB 8*32kB 0*64kB 0*128kB 0*256kB 0*512kB
> >> 0*1024kB 0*2048kB 0*4096kB =3D 2960kB
> >> 37964 total pagecache pages
> >> 3160 pages in swap cache
> >>
> >> On Sun, Jun 6, 2010 at 3:42 AM, Eric Dumazet <eric.dumazet@gmail.c=
om> wrote:
> >> >
> >> > Le dimanche 06 juin 2010 =C3=A0 11:56 +0200, Michael Guntsche a =
=C3=A9crit :
> >> > > On 2010.06.04 18:16:44 , Michael Guntsche wrote:
> >> > > > I applied the patch recompiled and run it on the routerboard=
, trying
> >> > > > to trigger the bug again.
> >> > >
> >> > > Hi Eric,
> >> > >
> >> > > Up to now I was not able to reproduce the bug, do you think th=
is patch
> >> > > can be pushed to mainline or is there a "better"/other =C2=A0f=
ix for it?
> >> > >
> >> > > Kind regards,
> >> > > Michael
> >> > >
> >> > >
> >> >
> >> > Thanks Michael for testing.
> >> >
> >> > I'll submit ASAP an official patch, sent to all people involved =
in this
> >> > driver to get their Ack (or Nack).
> >> >
> >> > IEEE80211_MAX_MPDU_LEN being 3840 + somebits is suspect, since i=
t doesnt
> >> > match 802.11 specs.
> >> >
> >> > It should be more close of 2304 + MAC header (32bytes) + FCS (4 =
bytes) ?
> >> >
> >> >
> >> >
> >> > --
> >
> >
> > reading my former patch, I believe I mistakenly used a max_t() inst=
ead
> > of a min_() macro :
> >
> > diff --git a/drivers/net/wireless/ath/ath9k/recv.c b/drivers/net/wi=
reless/ath/ath9k/recv.c
> > index ca6065b..0a0dc3a 100644
> > --- a/drivers/net/wireless/ath/ath9k/recv.c
> > +++ b/drivers/net/wireless/ath/ath9k/recv.c
> > @@ -226,10 +226,10 @@ static int ath_rx_edma_init(struct ath_softc =
*sc, int nbufs)
> > =C2=A0 =C2=A0 =C2=A0 =C2=A0u32 size;
> >
> >
> > - =C2=A0 =C2=A0 =C2=A0 common->rx_bufsize =3D roundup(IEEE80211_MAX=
_MPDU_LEN +
> > - =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=
=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0ah->caps.rx_=
status_len,
> > - =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=
=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0min(common->=
cachelsz, (u16)64));
> > -
> > + =C2=A0 =C2=A0 =C2=A0 size =3D roundup(IEEE80211_MAX_MPDU_LEN + ah=
->caps.rx_status_len,
> > + =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=
=A0 =C2=A0min(common->cachelsz, (u16)64));
> > + =C2=A0 =C2=A0 =C2=A0 common->rx_bufsize =3D max_t(u32, size,
> > + =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=
=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0SKB_MAX_ORDER(NET_S=
KB_PAD + common->cachelsz, 0));
> > =C2=A0 =C2=A0 =C2=A0 =C2=A0ath9k_hw_set_rx_bufsize(ah, common->rx_b=
ufsize -
> > =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0=
 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0ah->caps.rx_sta=
tus_len);
> >
> >
> >
> > Please use instead this one :
> >
> > diff --git a/drivers/net/wireless/ath/ath9k/recv.c b/drivers/net/wi=
reless/ath/ath9k/recv.c
> > index ca6065b..0a0dc3a 100644
> > --- a/drivers/net/wireless/ath/ath9k/recv.c
> > +++ b/drivers/net/wireless/ath/ath9k/recv.c
> > @@ -226,10 +226,10 @@ static int ath_rx_edma_init(struct ath_softc =
*sc, int nbufs)
> > =C2=A0 =C2=A0 =C2=A0 =C2=A0u32 size;
> >
> >
> > - =C2=A0 =C2=A0 =C2=A0 common->rx_bufsize =3D roundup(IEEE80211_MAX=
_MPDU_LEN +
> > - =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=
=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0ah->caps.rx_=
status_len,
> > - =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=
=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0min(common->=
cachelsz, (u16)64));
> > -
> > + =C2=A0 =C2=A0 =C2=A0 size =3D roundup(IEEE80211_MAX_MPDU_LEN + ah=
->caps.rx_status_len,
> > + =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=
=A0 =C2=A0min(common->cachelsz, (u16)64));
> > + =C2=A0 =C2=A0 =C2=A0 common->rx_bufsize =3D min_t(u32, size,
> > + =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=
=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0SKB_MAX_ORDER(NET_S=
KB_PAD + common->cachelsz, 0));
> > =C2=A0 =C2=A0 =C2=A0 =C2=A0ath9k_hw_set_rx_bufsize(ah, common->rx_b=
ufsize -
> > =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0=
 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0ah->caps.rx_sta=
tus_len);
> >
> >
> >
> >
> >
