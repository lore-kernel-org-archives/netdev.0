From: Eric Dumazet <eric.dumazet@gmail.com>
Subject: Re: [2.6.35-rc1] page alloc failure order:1, mode:0x4020
Date: Sun, 05 Sep 2010 22:25:04 +0200
Message-ID: <1283718304.3402.370.camel@edumazet-laptop>
References: <20100604092025.GA96690@trillian.comsick.at>
	 <1275656014.2482.169.camel@edumazet-laptop>
	 <20100604161644.GA98048@trillian.local>
	 <20100606095640.GA4436@trillian.comsick.at>
	 <1275820945.5238.987.camel@edumazet-laptop>
	 <AANLkTimf5iZV2ytoymCXJ=B2Vgowr6qb6u2nBg+RtBUg@mail.gmail.com>
	 <1282769089.2681.159.camel@edumazet-laptop>
	 <AANLkTi=TU8d8tsp28qN-Rz9z0hTcH7hRE=d8W4GKhrkk@mail.gmail.com>
	 <AANLkTi=jLwvU=EWR51Y=TQ5JYVp_DqeTx0Ocbt=NEC1-@mail.gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: Michael Guntsche <mike@it-loops.com>,
	linux-kernel <linux-kernel@vger.kernel.org>,
	netdev <netdev@vger.kernel.org>
To: Nikhil Sethi
	 =?UTF-8?Q?=28=E0=A4=A8=E0=A4=BF=E0=A4=96=E0=A4=BF=E0=A4=B2_?=
	 =?UTF-8?Q?=E0=A4=B8=E0=A5=87=E0=A4=A0=E0=A5=80=29?=
	<nikhil@sethi.ws>
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <AANLkTi=jLwvU=EWR51Y=TQ5JYVp_DqeTx0Ocbt=NEC1-@mail.gmail.com>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Le dimanche 05 septembre 2010 =C3=A0 08:51 -0700, Nikhil Sethi (=E0=A4=A8=
=E0=A4=BF=E0=A4=96=E0=A4=BF=E0=A4=B2 =E0=A4=B8=E0=A5=87=E0=A4=A0=E0=A5=80=
) a
=C3=A9crit :
> This came back. Here is the dmesg output. It might be the problem onl=
y
> happens if I have wmm_enabled=3D1 in my hostapd.conf. That is the onl=
y
> thing that I changed yesterday, and today I saw these messages in my
> logs. I will try to conform this.
>=20
>=20
> I am running 2.6.35.4 with this patch:
>=20
>=20
> *** 225,234 ****
>    int error =3D 0, i;
>    u32 size;
>  =20
> !=20
> ! common->rx_bufsize =3D roundup(IEEE80211_MAX_MPDU_LEN +
> !     ah->caps.rx_status_len,
> !     min(common->cachelsz, (u16)64));
>  =20
>    ath9k_hw_set_rx_bufsize(ah, common->rx_bufsize -
>       ah->caps.rx_status_len);
> --- 225,234 ----
>    int error =3D 0, i;
>    u32 size;
>  =20
> ! size =3D roundup(IEEE80211_MAX_MPDU_LEN + ah->caps.rx_status_len,
> !                        min(common->cachelsz, (u16)64));
> !         common->rx_bufsize =3D min_t(u32, size,
> !                                    SKB_MAX_ORDER(NET_SKB_PAD +
> common->cachelsz, 0));
>  =20
>    ath9k_hw_set_rx_bufsize(ah, common->rx_bufsize -
>       ah->caps.rx_status_len);
>=20
>=20
> dmesg output:
>=20
>=20
> skbuff alloc of size 3872 failed
> ps: page allocation failure. order:1, mode:0x4020
> Pid: 16022, comm: ps Tainted: G        W   2.6.35.4 #1
> Call Trace:
>  [<c0243bfe>] ? __alloc_pages_nodemask+0x3e6/0x513
>  [<c025be97>] ? slob_new_pages+0xc/0x23

Unfortunately you use SLOB, and it seems to ask order-1 pages, while
we want less than a page.

Please try SLAB or SLUB

>  [<c025c0a1>] ? __kmalloc_node+0x39/0x72
>  [<c03338d8>] ? __alloc_skb+0x5c/0x105
>  [<d09fa01a>] ? ath_rxbuf_alloc+0x1a/0x78 [ath]
>  [<d0ab7109>] ? ath_rx_tasklet+0x2fb/0x808 [ath9k]
>  [<c030fd49>] ? scsi_next_command+0x27/0x34
>  [<d0ab53c5>] ? ath9k_tasklet+0xcc/0x107 [ath9k]
>  [<c02193c3>] ? tasklet_action+0x5f/0x65
>  [<c0219677>] ? __do_softirq+0x60/0xc6
>  [<c021970b>] ? do_softirq+0x2e/0x30
>  [<c02197fd>] ? irq_exit+0x53/0x55
>  [<c020392c>] ? do_IRQ+0x3a/0x72
>  [<c0202be9>] ? common_interrupt+0x29/0x30
>  [<c0247874>] ? __remove_mapping+0x4b/0x8d
>  [<c023ea9f>] ? try_to_release_page+0x20/0x30
>  [<c0247d36>] ? shrink_page_list+0x2b8/0x46c
>  [<c03158ea>] ? sd_prep_fn+0x1a5/0x92b
>  [<c024816b>] ? shrink_inactive_list+0x281/0x552
>  [<c02445d9>] ? determine_dirtyable_memory+0xc/0x12
>  [<c024462c>] ? get_dirty_limits+0x18/0x2b0
>  [<c032875e>] ? ata_bmdma_port_intr+0x21/0xcd
>  [<c0248683>] ? shrink_zone+0x247/0x38f
>  [<c021968c>] ? __do_softirq+0x75/0xc6
>  [<c0247114>] ? shrink_slab+0x13c/0x186
>  [<c0248f25>] ? try_to_free_pages+0x1ab/0x2be
>  [<c0248f25>] ? try_to_free_pages+0x1ab/0x2be
>  [<c0243acf>] ? __alloc_pages_nodemask+0x2b7/0x513
>  [<c025be97>] ? slob_new_pages+0xc/0x23
>  [<c025c038>] ? kmem_cache_alloc_node+0x23/0x53
>  [<c0264b20>] ? getname+0x19/0xae
>  [<c0266d00>] ? user_path_at+0x11/0x64
>  [<c0250949>] ? access_process_vm+0xe0/0x1e7
>  [<c0250a08>] ? access_process_vm+0x19f/0x1e7
>  [<c02603d2>] ? vfs_fstatat+0x25/0x63
>  [<c02604a9>] ? vfs_stat+0x10/0x12
>  [<c02604ba>] ? sys_stat64+0xf/0x23
>  [<c025e86b>] ? fput+0x88/0x191
>  [<c026ab3b>] ? dput+0x92/0xd4
>  [<c025e8ff>] ? fput+0x11c/0x191
>  [<c026ebec>] ? mntput_no_expire+0x13/0x60
>  [<c025c398>] ? filp_close+0x3b/0x54
>  [<c025c403>] ? sys_close+0x52/0x72
>  [<c038ad3d>] ? syscall_call+0x7/0xb
>  [<c0380000>] ? unix_dgram_sendmsg+0x258/0x3c1
> Mem-Info:
