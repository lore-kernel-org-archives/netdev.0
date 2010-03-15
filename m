From: Eric Dumazet <eric.dumazet@gmail.com>
Subject: Re: inconsistent lock state
Date: Mon, 15 Mar 2010 22:01:05 +0100
Message-ID: <1268686865.2824.4.camel@edumazet-laptop>
References: <20100307192305.GA598@elte.hu>
	 <20100308125122.GA11242@redhat.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: Ingo Molnar <mingo@elte.hu>,
	Sergey Senozhatsky <sergey.senozhatsky@gmail.com>,
	Francois Romieu <romieu@fr.zoreil.com>,
	Peter Zijlstra <a.p.zijlstra@chello.nl>,
	netdev@vger.kernel.org, linux-kernel@vger.kernel.org,
	David Miller <davem@davemloft.net>
To: Oleg Nesterov <oleg@redhat.com>
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <20100308125122.GA11242@redhat.com>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Le lundi 08 mars 2010 =C3=A0 13:51 +0100, Oleg Nesterov a =C3=A9crit :
> Sergey Senozhatsky wrote:
> >
> > Hello,
> >
> > Hardly reproducible.
> > /*
> > * 2.6.33. x86. ASUS f3jc
> > */
> >
> > [329645.010697] =3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=
=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D
> > [329645.010699] [ INFO: inconsistent lock state ]
> > [329645.010703] 2.6.33-33-0-dbg #31
> > [329645.010705] ---------------------------------
> > [329645.010708] inconsistent {IN-SOFTIRQ-W} -> {SOFTIRQ-ON-W} usage=
=2E
> >
> > ...
> >
> > [329645.011083]  [<c128858d>] netif_receive_skb+0x340/0x360
> > [329645.011093]  [<fd1ab6f4>] rtl8169_rx_interrupt+0x2bf/0x37e [r81=
69]
> > [329645.011100]  [<fd1aba02>] rtl8169_reset_task+0x38/0xcd [r8169]
> > [329645.011105]  [<c1044f71>] worker_thread+0x1ac/0x27c
>=20
> I don't understand this code, but at first glance drivers/net/r8169.c
> is obviously buggy.
>=20
> The work->func, rtl8169_reset_task(), calls rtl8169_rx_interrupt() ->
> netif_receive_skb(), and the last one may only be called from softirq=
=2E
>=20

Yes, this is wrong. In this context (process context, not softirq), we
should use netif_rx() or just drop frames if we are in reset phase.

Also, this driver schedules a reset in case a fifo error is reported in
rtl8169_rx_interrupt()

                if (status & RxFOVF) {
                        rtl8169_schedule_work(dev, rtl8169_reset_task);
                        dev->stats.rx_fifo_errors++;
                }


This seems very strange too : In case of a RX spike, we reset card ?
