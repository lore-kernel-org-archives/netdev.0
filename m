From: Eric Dumazet <eric.dumazet@gmail.com>
Subject: RE: [PATCH] bnx2x: fix panic when TX ring is full
Date: Mon, 18 Jun 2012 09:38:56 +0200
Message-ID: <1340005136.7491.609.camel@edumazet-glaptop>
References: <1339616716.22704.661.camel@edumazet-glaptop>
	 <20120615.153049.103988387813257203.davem@davemloft.net>
	 <504C9EFCA2D0054393414C9CB605C37F1CF19E@SJEXCHMB06.corp.ad.broadcom.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: 'David Miller' <davem@davemloft.net>,
	"netdev@vger.kernel.org" <netdev@vger.kernel.org>,
	"therbert@google.com" <therbert@google.com>,
	"evansr@google.com" <evansr@google.com>,
	Eilon Greenstein <eilong@broadcom.com>,
	Merav Sicron <meravs@broadcom.com>,
	Yaniv Rosner <yaniv.rosner@broadcom.com>,
	"willemb@google.com" <willemb@google.com>,
	"thruby@google.com" <thruby@google.com>
To: Dmitry Kravkov <dmitry@broadcom.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-ey0-f174.google.com ([209.85.215.174]:40524 "EHLO
	mail-ey0-f174.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751614Ab2FRHjC (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 18 Jun 2012 03:39:02 -0400
Received: by eaak11 with SMTP id k11so1427553eaa.19
        for <netdev@vger.kernel.org>; Mon, 18 Jun 2012 00:39:00 -0700 (PDT)
In-Reply-To: <504C9EFCA2D0054393414C9CB605C37F1CF19E@SJEXCHMB06.corp.ad.broadcom.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Sat, 2012-06-16 at 07:40 +0000, Dmitry Kravkov wrote:
> Hi Eric and Tomas
>=20
> > From: netdev-owner@vger.kernel.org [mailto:netdev-
> > owner@vger.kernel.org] On Behalf Of David Miller
> > Sent: Saturday, June 16, 2012 1:31 AM
> > To: eric.dumazet@gmail.com
> > Cc: netdev@vger.kernel.org; therbert@google.com; evansr@google.com;
> > Eilon Greenstein; Merav Sicron; Yaniv Rosner; willemb@google.com;
> > thruby@google.com
> > Subject: Re: [PATCH] bnx2x: fix panic when TX ring is full
> >=20
> > From: Eric Dumazet <eric.dumazet@gmail.com>
> > Date: Wed, 13 Jun 2012 21:45:16 +0200
> >=20
> > > From: Eric Dumazet <edumazet@google.com>
> > >
> > > There is a off by one error in the minimal number of BD in
> > > bnx2x_start_xmit() and bnx2x_tx_int() before stopping/resuming tx
> > queue.
> > >
> > > A full size GSO packet, with data included in skb->head really ne=
eds
> > > (MAX_SKB_FRAGS + 4) BDs, because of bnx2x_tx_split()
> > >
> > > This error triggers if BQL is disabled and heavy TCP transmit tra=
ffic
> > > occurs.
> > >
> > > bnx2x_tx_split() definitely can be called, remove a wrong comment=
=2E
> > >
> > > Reported-by: Tomas Hruby <thruby@google.com>
> > > Signed-off-by: Eric Dumazet <edumazet@google.com>
>=20
> Theoretically a can't see how we can reach the case with 4 BDs requir=
ed apart of frags,
> Usually we need 2, when split invoked 3:
> 1.Start
> 2.Start(split)
> 3.Parsing
> + Frags
>=20
> Next pages descriptors and 2 extras for full indication are not count=
ed as available.
>=20
> Practically I'm running the traffic for more then a day without hitti=
ng the panic.
>=20
> Can you describe the scenario you reproduced this in details? And whi=
ch code has paniced?=20

Thats pretty immediate.

Disable bql on your NIC.

Say you have 4 queues :

for q in 0 1 2 3
do
  echo max >/sys/class/net/eth0/queues/tx-$q/byte_queue_limits/limit_mi=
n
done

Then start 40 netperf

for i in `seq 1 40`
do
 netperf -H 192.168.1.4 &
done


[  811.369026] bnx2x: [bnx2x_attn_int_deasserted3:3647(eth0)]MC assert!
[  811.369030] bnx2x:
[bnx2x_mc_assert:597(eth0)]XSTORM_ASSERT_LIST_INDEX 0x2
[  811.369036] bnx2x: [bnx2x_mc_assert:614(eth0)]XSTORM_ASSERT_INDEX 0x=
0
=3D 0x00110000 0x00000042 0x06981000 0x0001003a
[  811.369052] bnx2x: [bnx2x_attn_int_deasserted3:3653(eth0)]driver
assert
[  811.369054] bnx2x: [bnx2x_panic_dump:773(eth0)]begin crash dump
-----------------
[  811.369056] bnx2x: [bnx2x_panic_dump:780(eth0)]def_idx(0x327)
def_att_idx(0x4)  attn_state(0x1)  spq_prod_idx(0x2f)
next_stats_cnt(0x31c)
[  811.369058] bnx2x: [bnx2x_panic_dump:785(eth0)]DSB: attn bits(0x0)
ack(0x1)  id(0x0)  idx(0x4)
[  811.369060] bnx2x: [bnx2x_panic_dump:786(eth0)]     def (0x0 0x0 0x0
0x0 0x0 0x0 0x0 0x32a 0x0 0x0 0x0 0x0 0x0 0x0 0x0 0x0)  igu_sb_id(0x0)
igu_seg_id(0x1) pf_id(0x0)  vnic_id(0x0)  vf_id(0xff)  vf_valid (0x0)
state(0x1)
[  811.369073] bnx2x: [bnx2x_panic_dump:830(eth0)]fp0:
rx_bd_prod(0xdfae)  rx_bd_cons(0xfb0)  rx_comp_prod(0xe86f)
rx_comp_cons(0xd86f)  *rx_cons_sb(0xd86f)
[  811.369076] bnx2x: [bnx2x_panic_dump:834(eth0)]
rx_sge_prod(0x400)  last_max_sge(0x2b)  fp_hc_idx(0x6a2f)
[  811.369078] bnx2x: [bnx2x_panic_dump:846(eth0)]fp0:
tx_pkt_prod(0xb184)  tx_pkt_cons(0xb088)  tx_bd_prod(0xa48)
tx_bd_cons(0xf943)  *tx_cons_sb(0xb088)
[  811.369080] bnx2x: [bnx2x_panic_dump:846(eth0)]fp0: tx_pkt_prod(0x0)
tx_pkt_cons(0x0)  tx_bd_prod(0x0)  tx_bd_cons(0x0)  *tx_cons_sb(0x0)
[  811.369082] bnx2x: [bnx2x_panic_dump:858(eth0)]     run indexes
(0x6a2f 0x0)
[  811.369084] bnx2x: [bnx2x_panic_dump:864(eth0)]     indexes (0x0
0xd86f 0x0 0x0 0x0 0xb088 0x0 0x0)pf_id(0x0)  vf_id(0xff)  vf_valid(0x0=
)
vnic_id(0x0)  same_igu_sb_1b(0x1) state(0x1)
[  811.369103] SM[0] __flags (0x0) igu_sb_id (0x1)  igu_seg_id(0x0)
time_to_expire (0x2f68cf91) timer_value(0xff)
[  811.369104] SM[1] __flags (0x0) igu_sb_id (0x1)  igu_seg_id(0x0)
time_to_expire (0x2f68cfc0) timer_value(0xff)
[  811.369106] INDEX[0] flags (0x0) timeout (0x0)
[  811.369107] INDEX[1] flags (0x2) timeout (0x6)
[  811.369108] INDEX[2] flags (0x0) timeout (0x0)
[  811.369110] INDEX[3] flags (0x0) timeout (0x0)
[  811.369111] INDEX[4] flags (0x1) timeout (0x0)
[  811.369112] INDEX[5] flags (0x3) timeout (0xc)
[  811.369113] INDEX[6] flags (0x1) timeout (0x0)
[  811.369114] INDEX[7] flags (0x1) timeout (0x0)
[  811.369116] bnx2x: [bnx2x_panic_dump:830(eth0)]fp1:
rx_bd_prod(0x11ee)  rx_bd_cons(0x1f0)  rx_comp_prod(0x1e54)
rx_comp_cons(0xe54)  *rx_cons_sb(0xe54)
[  811.369119] bnx2x: [bnx2x_panic_dump:834(eth0)]
rx_sge_prod(0x400)  last_max_sge(0x29)  fp_hc_idx(0x969d)
[  811.369121] bnx2x: [bnx2x_panic_dump:846(eth0)]fp1:
tx_pkt_prod(0xba3f)  tx_pkt_cons(0xb92f)  tx_bd_prod(0x1aee)
tx_bd_cons(0xb18)  *tx_cons_sb(0xb92f)
[  811.369123] bnx2x: [bnx2x_panic_dump:846(eth0)]fp1: tx_pkt_prod(0x0)
tx_pkt_cons(0x0)  tx_bd_prod(0x0)  tx_bd_cons(0x0)  *tx_cons_sb(0x0)
[  811.369125] bnx2x: [bnx2x_panic_dump:858(eth0)]     run indexes
(0x969d 0x0)
[  811.369128] bnx2x: [bnx2x_panic_dump:864(eth0)]     indexes (0x0
0xe54 0x0 0x0 0x0 0xb92f 0x0 0x0)pf_id(0x0)  vf_id(0xff)  vf_valid(0x0)
vnic_id(0x0)  same_igu_sb_1b(0x1) state(0x1)
[  811.369146] SM[0] __flags (0x0) igu_sb_id (0x2)  igu_seg_id(0x0)
time_to_expire (0x2f68cf8a) timer_value(0xff)
[  811.369148] SM[1] __flags (0x1) igu_sb_id (0x2)  igu_seg_id(0x0)
time_to_expire (0x2f68cfc4) timer_value(0xc)
[  811.369150] INDEX[0] flags (0x0) timeout (0x0)
[  811.369151] INDEX[1] flags (0x2) timeout (0x6)
[  811.369152] INDEX[2] flags (0x0) timeout (0x0)
[  811.369153] INDEX[3] flags (0x0) timeout (0x0)
[  811.369154] INDEX[4] flags (0x1) timeout (0x0)
[  811.369156] INDEX[5] flags (0x3) timeout (0xc)
[  811.369157] INDEX[6] flags (0x1) timeout (0x0)
[  811.369158] INDEX[7] flags (0x1) timeout (0x0)
[  811.369160] bnx2x: [bnx2x_panic_dump:830(eth0)]fp2:
rx_bd_prod(0xa84f)  rx_bd_cons(0x851)  rx_comp_prod(0xb367)
rx_comp_cons(0xa367)  *rx_cons_sb(0xa367)
[  811.369162] bnx2x: [bnx2x_panic_dump:834(eth0)]
rx_sge_prod(0x400)  last_max_sge(0x1f)  fp_hc_idx(0x2bf7)
[  811.369164] bnx2x: [bnx2x_panic_dump:846(eth0)]fp2:
tx_pkt_prod(0xb38d)  tx_pkt_cons(0xb296)  tx_bd_prod(0x1947)
tx_bd_cons(0xb59)  *tx_cons_sb(0xb296)
[  811.369166] bnx2x: [bnx2x_panic_dump:846(eth0)]fp2: tx_pkt_prod(0x0)
tx_pkt_cons(0x0)  tx_bd_prod(0x0)  tx_bd_cons(0x0)  *tx_cons_sb(0x0)
[  811.369168] bnx2x: [bnx2x_panic_dump:858(eth0)]     run indexes
(0x2bf7 0x0)
[  811.369170] bnx2x: [bnx2x_panic_dump:864(eth0)]     indexes (0x0
0xa367 0x0 0x0 0x0 0xb296 0x0 0x0)pf_id(0x0)  vf_id(0xff)  vf_valid(0x0=
)
vnic_id(0x0)  same_igu_sb_1b(0x1) state(0x1)
[  811.369189] SM[0] __flags (0x1) igu_sb_id (0x3)  igu_seg_id(0x0)
time_to_expire (0x2f68cfc7) timer_value(0x6)
[  811.369191] SM[1] __flags (0x0) igu_sb_id (0x3)  igu_seg_id(0x0)
time_to_expire (0x2f68cf9d) timer_value(0xff)
[  811.369192] INDEX[0] flags (0x0) timeout (0x0)
[  811.369193] INDEX[1] flags (0x2) timeout (0x6)
[  811.369194] INDEX[2] flags (0x0) timeout (0x0)
[  811.369196] INDEX[3] flags (0x0) timeout (0x0)
[  811.369197] INDEX[4] flags (0x1) timeout (0x0)
[  811.369198] INDEX[5] flags (0x3) timeout (0xc)
[  811.369199] INDEX[6] flags (0x1) timeout (0x0)
[  811.369200] INDEX[7] flags (0x1) timeout (0x0)
[  811.369202] bnx2x: [bnx2x_panic_dump:830(eth0)]fp3:
rx_bd_prod(0x7df1)  rx_bd_cons(0xdf3)  rx_comp_prod(0x8887)
rx_comp_cons(0x7887)  *rx_cons_sb(0x7887)
[  811.369204] bnx2x: [bnx2x_panic_dump:834(eth0)]
rx_sge_prod(0x400)  last_max_sge(0x1a)  fp_hc_idx(0x5cb)
[  811.369206] bnx2x: [bnx2x_panic_dump:846(eth0)]fp3:
tx_pkt_prod(0xb8ce)  tx_pkt_cons(0xb7cc)  tx_bd_prod(0x15cf)
tx_bd_cons(0x8c5)  *tx_cons_sb(0xb7cc)
[  811.369208] bnx2x: [bnx2x_panic_dump:846(eth0)]fp3: tx_pkt_prod(0x0)
tx_pkt_cons(0x0)  tx_bd_prod(0x0)  tx_bd_cons(0x0)  *tx_cons_sb(0x0)
[  811.369210] bnx2x: [bnx2x_panic_dump:858(eth0)]     run indexes
(0x5cb 0x0)
[  811.369212] bnx2x: [bnx2x_panic_dump:864(eth0)]     indexes (0x0
0x7887 0x0 0x0 0x0 0xb7cc 0x0 0x0)pf_id(0x0)  vf_id(0xff)  vf_valid(0x0=
)
vnic_id(0x0)  same_igu_sb_1b(0x1) state(0x1)
[  811.369231] SM[0] __flags (0x0) igu_sb_id (0x4)  igu_seg_id(0x0)
time_to_expire (0x2f68cf9e) timer_value(0xff)
[  811.369233] SM[1] __flags (0x1) igu_sb_id (0x4)  igu_seg_id(0x0)
time_to_expire (0x2f68cfe5) timer_value(0xc)
[  811.369235] INDEX[0] flags (0x0) timeout (0x0)
[  811.369236] INDEX[1] flags (0x2) timeout (0x6)
[  811.369237] INDEX[2] flags (0x0) timeout (0x0)
[  811.369238] INDEX[3] flags (0x0) timeout (0x0)
[  811.369239] INDEX[4] flags (0x1) timeout (0x0)
[  811.369240] INDEX[5] flags (0x3) timeout (0xc)
[  811.369241] INDEX[6] flags (0x1) timeout (0x0)
[  811.369242] INDEX[7] flags (0x1) timeout (0x0)
[  811.369246] bnx2x 0000:03:00.0: eth0: bc 6.2.8
[  811.369250] begin fw dump (mark 0x3c65b0)
[  811.369257] ttn 0x0->0x10
[  811.369257] attn 0x10->0x0
[  811.369258] attn 0x0->0x10
[  811.369265] attn 0x10->0x0
[  811.369265] attn 0x0->0x10
[  811.369272] attn 0x10->0x0
[  811.369272] attn 0x0->0x10
[  811.369279] attn 0x10->0x0
[  811.369279] attn 0x0->0x10
[  811.369286] attn 0x10->0x0
[  811.369286] attn 0x0->0x10
[  811.369293] attn 0x10->0x0
[  811.369294] attn 0x0->0x10
[  811.369301] attn 0x10->0x0
[  811.369301] attn 0x0->0x10
[  811.369308] attn 0x10->0x0
[  811.369308] attn 0x0->0x10
[  811.369309] attn 0x10->0x0
[  811.369316] attn 0x0->0x10
[  811.369316] attn 0x10->0x0
[  811.369323] attn 0x0->0x10
[  811.369324] attn 0x10->0x0
[  811.369331] attn 0x0->0x10
[  811.369331] attn 0x10->0x0
[  811.369338] attn 0x0->0x10
[  811.369338] attn 0x10->0x0
[  811.369345] attn 0x0->0x10
[  811.369345] attn 0x10->0x0
[  811.369352] attn 0x0->0x10
[  811.369352] attn 0x10->0x0
[  811.369359] attn 0x0->0x10
[  811.369360] attn 0x10->0x0
[  811.369360] attn 0x0->0x10
[  811.369367] attn 0x10->0x0
[  811.369367] attn 0x0->0x10
[  811.369374] attn 0x10->0x0
[  811.369375] attn 0x0->0x10
[  811.369382] attn 0x10->0x0
[  811.369382] attn 0x0->0x10
[  811.369389] attn 0x10->0x0
[  811.369389] attn 0x0->0x10
[  811.369396] attn 0x10->0x0
[  811.369396] attn 0x0->0x10
[  811.369403] attn 0x10->0x0
[  811.369403] attn 0x0->0x10
[  811.369410] attn 0x10->0x0
[  811.369411] attn 0x0->0x10
[  811.369417] attn 0x10->0x0
[  811.369418] attn 0x0->0x10
[  811.369418] attn 0x10->0x0
[  811.369439] attn 0x0->0x10
[  811.369439] attn 0x10->0x0
[  811.369446] attn 0x0->0x10
[  811.369446] attn 0x10->0x0
[  811.369453] attn 0x0->0x10
[  811.369454] attn 0x10->0x0
[  811.369461] attn 0x0->0x10
[  811.369461] attn 0x10->0x0
[  811.369469] attn 0x0->0x10
[  811.369469] attn 0x10->0x0
[  811.369477] attn 0x0->0x10
[  811.369477] attn 0x10->0x0
[  811.369484] f0: UNLOAD_REQ_WOL_DIS 0x4
[  811.369485] evnt[0.0] 0x1mcp intr[0.0]: 0x10:RSV ACCESS =3D> 0x0 PC
0x800dd28
[  811.369507] >0x0
[  811.369507] attn 0x0->0x10
[  811.369507] attn 0x10->0x0
[  811.369515] f0: UNLOAD_DONE 0x5
[  811.369515] mcp intr[0.0]: 0x10:RSV ACCESS =3D> 0x0 PC 0x8015e88
[  811.369530] lnk_cmn_int[0]: (rc 0)
[  811.369537] link_init[1.0]: 0x4
[  811.369538] idx =3D 0, req_line_speed =3D 0x3e8, req_duplex=3D0x1
[  811.369552] idx =3D 1, req_line_speed =3D 0x0, req_duplex=3D0x1
[  811.369560] ML recurs lvl 1
[  811.369568] init_phy[1.0]: done
[  811.369568] ML recurs lvl 1
[  811.369576] link_init[0.0]: 0x4
[  811.369576] idx =3D 0, req_line_speed =3D 0x3e8, req_duplex=3D0x1
[  811.369590] idx =3D 1, req_line_speed =3D 0x0, req_duplex=3D0x1
[  811.369598] ML recurs lvl 1
[  811.369605] init_phy[0.0]: done
[  811.369606] f0: LOAD_REQ 0x6
[  811.369613] 0.0:PMF->f0
[  811.369614] f0: LOAD_DONE 0x7
[  811.369621] evnt[0.0] 0x0->0x1000
[  811.369629] evnt[0.0] 0x1000->0x0
[  811.369629] f0: UNLOAD_REQ_WOL_DIS 0x8
[  811.369637] f0: UNLOAD_DONE 0x9
[  811.369644] lnk_cmn_int[0]: (rc 0)
[  811.369645] link_init[1.0]: 0x4
[  811.369652] idx =3D 0, req_line_speed =3D 0x3e8, req_duplex=3D0x1
[  811.369667] idx =3D 1, req_line_speed =3D 0x0, req_duplex=3D0x1
[  811.369675] Ap=01=EF=BF=BDAML recurs lvl 1
[  811.369682] init_phy[1.0]: done
[  811.369690] ML recurs lvl 1
[  811.369690] link_init[0.0]: 0x4
[  811.369698] idx =3D 0, req_line_speed =3D 0x3e8, req_duplex=3D0x1
[  811.369706] idx =3D 1, req_line_speed =3D 0x0, req_duplex=3D0x1
[  811.369720] ML recurs lvl 1
[  811.369720] init_phy[0.0]: done
[  811.369728] f0: LOAD_REQ 0xa
[  811.369728] 0.0:PMF->f0
[  811.369735] f0: LOAD_DONE 0xb
[  811.369735] evnt[0.0] 0x0->0x1000
[  811.369742] evnt[0.0] 0x1000->0x0
[  811.369749] end of fw dump
[  811.369752] bnx2x:
[bnx2x_mc_assert:597(eth0)]XSTORM_ASSERT_LIST_INDEX 0x2
[  811.369758] bnx2x: [bnx2x_mc_assert:614(eth0)]XSTORM_ASSERT_INDEX 0x=
0
=3D 0x00110000 0x00000042 0x06981000 0x0001003a
[  811.369776] bnx2x: [bnx2x_panic_dump:996(eth0)]end crash dump
-----------------
[  819.771607] ------------[ cut here ]------------
[  819.771618] WARNING: at net/sched/sch_generic.c:263 dev_watchdog
+0x267/0x270()
[  819.771622] Hardware name: TBG,ICH10
[  819.771625] NETDEV WATCHDOG: eth0 (bnx2x): transmit queue 1 timed ou=
t
[  819.771627] Modules linked in: act_mirred cls_u32 cls_tcindex
sch_dsmark xt_multiport iptable_mangle ip_tables x_tables pca954x
i2c_mux processor cdc_acm uhci_hcd ehci_hcd i2c_dev i2c_i801 i2c_core
i2c_debug msr cpuid bnx2x crc32c libcrc32c mdio ipv6 genrtc
[  819.771661] Pid: 0, comm: swapper/6 Tainted: G        W
3.3.6-dbg-DEV #5
[  819.771664] Call Trace:
[  819.771666]  <IRQ>  [<ffffffff8107fc0f>] warn_slowpath_common
+0x7f/0xc0
[  819.771679]  [<ffffffff8107fd06>] warn_slowpath_fmt+0x46/0x50
[  819.771685]  [<ffffffff814cd327>] dev_watchdog+0x267/0x270
[  819.771692]  [<ffffffff81090343>] run_timer_softirq+0x183/0x440
[  819.771696]  [<ffffffff810902b4>] ? run_timer_softirq+0xf4/0x440
[  819.771701]  [<ffffffff814cd0c0>] ? pfifo_fast_init+0x90/0x90
[  819.771707]  [<ffffffff810875ad>] __do_softirq+0xbd/0x250
[  819.771714]  [<ffffffff810ca054>] ? tick_program_event+0x24/0x30
[  819.771724]  [<ffffffff8156169c>] call_softirq+0x1c/0x30
[  819.771730]  [<ffffffff8104f21d>] do_softirq+0x8d/0xc0
[  819.771732]  [<ffffffff810879de>] irq_exit+0x9e/0xc0
[  819.771735]  [<ffffffff81003dee>] smp_apic_timer_interrupt+0x6e/0x99
[  819.771738]  [<ffffffff81560cb0>] apic_timer_interrupt+0x70/0x80
[  819.771739]  <EOI>  [<ffffffffa011503c>] ? acpi_idle_enter_bm
+0x220/0x260 [processor]
[  819.771746]  [<ffffffffa0115037>] ? acpi_idle_enter_bm+0x21b/0x260
[processor]
[  819.771751]  [<ffffffff8146c2cd>] cpuidle_idle_call+0xcd/0x2a0
[  819.771755]  [<ffffffff8155be60>] ? notifier_call_chain+0x70/0x70
[  819.771758]  [<ffffffff8104c1d5>] cpu_idle+0x85/0xe0
[  819.771763]  [<ffffffff8154b726>] start_secondary+0x1e3/0x1ea
[  819.771764] ---[ end trace e93713a9d40cd06f ]---
[  820.851700] bnx2x: [bnx2x_clean_tx_queue:1381(eth0)]timeout waiting
for queue[0]: txdata->tx_pkt_prod(45546) !=3D txdata->tx_pkt_cons(45192=
)
[  821.926357] bnx2x: [bnx2x_clean_tx_queue:1381(eth0)]timeout waiting
for queue[1]: txdata->tx_pkt_prod(47679) !=3D txdata->tx_pkt_cons(47407=
)
[  823.000384] bnx2x: [bnx2x_clean_tx_queue:1381(eth0)]timeout waiting
for queue[2]: txdata->tx_pkt_prod(46070) !=3D txdata->tx_pkt_cons(45718=
)
[  824.082211] bnx2x: [bnx2x_clean_tx_queue:1381(eth0)]timeout waiting
for queue[3]: txdata->tx_pkt_prod(47370) !=3D txdata->tx_pkt_cons(47052=
)
[  824.084515] bnx2x: [bnx2x_del_all_macs:7179(eth0)]Failed to delete
MACs: -5
[  824.084520] bnx2x: [bnx2x_chip_cleanup:7952(eth0)]Failed to schedule
DEL commands for UC MACs list: -5
[  824.097445] bnx2x: [bnx2x_func_stop:7758(eth0)]FUNC_STOP ramrod
failed. Running a dry transaction
[  824.960780] bnx2x 0000:03:00.0: eth0: using MSI-X  IRQs: sp 41  fp[0=
]
42 ... fp[3] 45
[  824.967241] bnx2x: [bnx2x_nic_load:1857(eth0)]Function start failed!
