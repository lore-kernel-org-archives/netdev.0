From: Rafal Ozieblo <rafalo@cadence.com>
Subject: RE: [PATCH v2 4/4] net: macb: Add hardware PTP support
Date: Thu, 8 Jun 2017 12:48:40 +0000
Message-ID: <BN3PR07MB251692E2A639D8B08DF2F3DCC9C90@BN3PR07MB2516.namprd07.prod.outlook.com>
References: <1496413439-12900-1-git-send-email-rafalo@cadence.com>
 <1496413690-22826-1-git-send-email-rafalo@cadence.com>
 <20170606183358.GA25220@localhost.localdomain>
 <BN3PR07MB2516A47C2CFEB58BCFFB2C46C9C80@BN3PR07MB2516.namprd07.prod.outlook.com>
 <20170607132817.GA28329@localhost.localdomain>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: quoted-printable
Cc: David Miller <davem@davemloft.net>,
        "nicolas.ferre@atmel.com" <nicolas.ferre@atmel.com>,
        "netdev@vger.kernel.org" <netdev@vger.kernel.org>,
        "linux-kernel@vger.kernel.org" <linux-kernel@vger.kernel.org>,
        "devicetree@vger.kernel.org" <devicetree@vger.kernel.org>,
        "linux-arm-kernel@lists.infradead.org"
        <linux-arm-kernel@lists.infradead.org>,
        "harini.katakam@xilinx.com" <harini.katakam@xilinx.com>,
        "andrei.pistirica@microchip.com" <andrei.pistirica@microchip.com>
To: Richard Cochran <richardcochran@gmail.com>
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <20170607132817.GA28329@localhost.localdomain>
Content-Language: en-US
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

> From: Richard Cochran [mailto:richardcochran@gmail.com]
> Sent: 7 czerwca 2017 15:28
> To: Rafal Ozieblo <rafalo@cadence.com>
> Cc: David Miller <davem@davemloft.net>; nicolas.ferre@atmel.com;
> netdev@vger.kernel.org; linux-kernel@vger.kernel.org;
> devicetree@vger.kernel.org; linux-arm-kernel@lists.infradead.org;
> harini.katakam@xilinx.com; andrei.pistirica@microchip.com
> Subject: Re: [PATCH v2 4/4] net: macb: Add hardware PTP support
>=20
> ********** EXTERNAL MAIL. PLEASE USE CAUTION WHEN CLICKING LINKS
> OR OPENING ATTACHMENTS **********
>=20
> On Wed, Jun 07, 2017 at 11:13:36AM +0000, Rafal Ozieblo wrote:
> > Please look at following call-stack:
> >
> > 1. macb_interrupt()   // spin_lock(&bp->lock) is taken
> > 2. macb_tx_interrupt()
> > 3. macb_handle_txtstamp()
> > 4. skb_tstamp_tx()
> > 5. __skb_tstamp_tx()
> > 6. skb_may_tx_timestamp()
> > 7. read_lock_bh() // second lock is taken
>=20
> Well, you can always drop the lock, or postpone the call to
> skb_tstamp_tx() until after the spin lock is released...
Postponing is done using worker. Another pros is that skb_tstamp_tx() is ca=
lled
outside interrupt routine.
>=20
> > I know that those are different locks and different types. But this cou=
ld
> lead
> > to deadlocks. This is the reason of warning I could see.
>=20
> Can you please post the lockdep splat?
>=20
[ 1264.352242] =3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=
=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D
[ 1264.356719] [ INFO: inconsistent lock state ]
[ 1264.361242] 4.4.0-42139-g418b7a0-dirty #16 Not tainted
[ 1264.366502] ---------------------------------
[ 1264.371004] inconsistent {HARDIRQ-ON-W} -> {IN-HARDIRQ-W} usage.
[ 1264.377204] ptp4l/105 [HC1[1]:SC0[4]:HE0:SE0] takes:
[ 1264.382286]  (&(&list->lock)->rlock){?.-...}, at: [<d03250f8>] skb_queue=
_tail+0x18/0x34
[ 1264.390622] {HARDIRQ-ON-W} state was registered at:
[ 1264.395618]   [<d0039d50>] lock_acquire+0x124/0x158
[ 1264.400730]   [<d03e81f8>] _raw_spin_lock_bh+0x50/0x5c
[ 1264.406095]   [<d0381745>] first_packet_length+0x35/0x1b4
[ 1264.411710]   [<d0381f80>] udp_poll+0x30/0x3c
[ 1264.416267]   [<d031743d>] sock_poll+0x141/0x148
[ 1264.421092]   [<d00ea20d>] do_sys_poll+0x171/0x300
[ 1264.426111]   [<d00ea41d>] SyS_poll+0x45/0x80
[ 1264.430676]   [<d000481c>] system_call+0x40/0x50
[ 1264.435492]   [<d00043d1>] common_exception_return+0x0/0x83
[ 1264.441274] irq event stamp: 23325
[ 1264.444802] hardirqs last  enabled at (23324): [<d03e84da>] _raw_spin_un=
lock_irqrestore+0x4e/0x78
[ 1264.453929] hardirqs last disabled at (23325): [<d00065af>] do_interrupt=
+0x13/0x90
[ 1264.461732] softirqs last  enabled at (23292): [<d0362cf8>] ip_finish_ou=
tput2+0x80/0x43c
[ 1264.470073] softirqs last disabled at (23294): [<d0362da6>] ip_finish_ou=
tput2+0x12e/0x43c
[ 1264.478480]=20
[ 1264.478480] other info that might help us debug this:
[ 1264.485211]  Possible unsafe locking scenario:
[ 1264.485211]=20
[ 1264.491323]        CPU0
[ 1264.493883]        ----
[ 1264.496439]   lock(&(&list->lock)->rlock);
[ 1264.500665]   <Interrupt>
[ 1264.503392]     lock(&(&list->lock)->rlock);
[ 1264.507793]=20
[ 1264.507793]  *** DEADLOCK ***
[ 1264.507793]=20
[ 1264.514016] 4 locks held by ptp4l/105:
[ 1264.517886]  #0:  (rcu_read_lock_bh){......}, at: [<d0362da6>] ip_finish=
_output2+0x12e/0x43c
[ 1264.526675]  #1:  (rcu_read_lock_bh){......}, at: [<d03330f4>] __dev_que=
ue_xmit+0x38/0x5f8
[ 1264.535287]  #2:  (_xmit_ETHER#2){+.-...}, at: [<d0348381>] sch_direct_x=
mit+0x51/0x138
[ 1264.543593]  #3:  (&(&bp->lock)->rlock){-.-...}, at: [<d02caeb2>] macb_i=
nterrupt+0x36/0x564
[ 1264.552316]=20
[ 1264.552316] stack backtrace:
[ 1264.556962] CPU: 0 PID: 105 Comm: ptp4l Not tainted 4.4.0-42139-g418b7a0=
-dirty #16
[ 1264.564654]=20
[ 1264.564654] Stack: d1786130 d75815e3 00001ffc d75815e0 9003811c d7581620=
 d7558c00 d1c0bd60=20
[ 1264.564654]        00000004 00000001 00000001 d7581600 900389fc d7581650=
 d7558c00 d7559160=20
[ 1264.564654]        00000004 00000000 00000000 d7559160 d04ecc34 d1bf2de0=
 00000179 d7581620=20
[ 1264.588339] Call Trace:
[ 1264.590894]  [<d009a8af>] print_usage_bug.part.33+0x1c7/0x1cc
[ 1264.596883]  [<d003811c>] mark_lock+0x2f4/0x44c
[ 1264.601639]  [<d00389fc>] __lock_acquire+0x460/0x1228
[ 1264.606907]  [<d0039d50>] lock_acquire+0x124/0x158
[ 1264.611907]  [<d03e8335>] _raw_spin_lock_irqsave+0x45/0x54
[ 1264.617612]  [<d03250f8>] skb_queue_tail+0x18/0x34
[ 1264.622594]  [<d03251f0>] sock_queue_err_skb+0xdc/0x108
[ 1264.628017]  [<d0326705>] __skb_complete_tx_timestamp+0x55/0x60
[ 1264.634146]  [<d0326810>] __skb_tstamp_tx+0x94/0x98
[ 1264.639215]  [<d032682c>] skb_tstamp_tx+0x18/0x1c
[ 1264.644110]  [<d02cb065>] macb_interrupt+0x1e9/0x564
[ 1264.649302]  [<d0041af5>] handle_irq_event_percpu+0xe9/0x2a4
[ 1264.655179]  [<d0041ce6>] handle_irq_event+0x36/0x50
[ 1264.660343]  [<d0043965>] handle_level_irq+0x99/0xb8
[ 1264.665525]  [<d00415c5>] generic_handle_irq+0x19/0x24
[ 1264.670863]  [<d000491d>] do_IRQ+0x35/0x38
[ 1264.675141]  [<d000660c>] do_interrupt+0x70/0x90
[ 1264.679959]  [<d00043d1>] common_exception_return+0x0/0x83
[ 1264.685635]  [<d02c8eb4>] macb_start_xmit+0x414/0x418
[ 1264.690905]  [<d0332eb1>] dev_hard_start_xmit+0x2ed/0x450
[ 1264.696521]  [<d034839e>] sch_direct_xmit+0x6e/0x138
[ 1264.701720]  [<d0333449>] __dev_queue_xmit+0x38d/0x5f8
[ 1264.707058]  [<d03336c8>] dev_queue_xmit+0x14/0x18
[ 1264.712049]  [<d033ab64>] neigh_resolve_output+0x180/0x190
[ 1264.717734]  [<d0362ff2>] ip_finish_output2+0x37a/0x43c
[ 1264.723186]  [<d0364168>] ip_finish_output+0x1b8/0x200
[ 1264.728532]  [<d0364969>] ip_mc_output+0x179/0x1cc
[ 1264.733532]  [<d03642e5>] ip_local_out+0x45/0x5c
[ 1264.738359]  [<d03651ae>] ip_send_skb+0x16/0x64
[ 1264.743097]  [<d03815f4>] udp_send_skb+0x160/0x1c8
[ 1264.748098]  [<d0382741>] udp_sendmsg+0x45d/0x5a8
[ 1264.753009]  [<d038a7f9>] inet_sendmsg+0x21/0x3c
[ 1264.757801]  [<d0317de5>] sock_sendmsg+0x1d/0x44
[ 1264.762629]  [<d03188e1>] SyS_sendto+0x89/0xa4
[ 1264.767288]  [<d000481c>] system_call+0x40/0x50
[ 1264.772010]  [<d00043d1>] common_exception_return+0x0/0x83

> Thanks,
> Richard

Regards,
Rafal
