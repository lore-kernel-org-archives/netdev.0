From: Eric Dumazet <eric.dumazet@gmail.com>
Subject: Re: [PATCH v6 0/2] Ethernet drivers for WIZnet chips
Date: Tue, 03 Apr 2012 14:29:16 +0200
Message-ID: <1333456156.18626.93.camel@edumazet-glaptop>
References: <1332752876-1650-1-git-send-email-msink@permonline.ru>
	 <1333450726-24455-1-git-send-email-msink@permonline.ru>
	 <1333453170.18626.65.camel@edumazet-glaptop> <4F7AE9D3.80204@permonline.ru>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: netdev@vger.kernel.org, linux-kernel@vger.kernel.org
To: Mike Sinkovsky <msink@permonline.ru>
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <4F7AE9D3.80204@permonline.ru>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On Tue, 2012-04-03 at 18:15 +0600, Mike Sinkovsky wrote:
> 03.04.2012 17:39, Eric Dumazet =D0=BD=D0=B0=D0=BF=D0=B8=D1=81=D0=B0=D0=
=BB:
> > On Tue, 2012-04-03 at 16:58 +0600, Mike Sinkovsky wrote:
> >> Based on original driver from chip manufacturer, but nearly full r=
ewite.
> >> Tested and used in production with Blackfin BF531 embedded process=
or.
> >>
> >> Signed-off-by: Mike Sinkovsky<msink@permonline.ru>
> >> ---
> >> v6:
> >>   - remove (S0_TX_FSR<  skb->len) check in TX handler, it doesn't =
work
> >>     anyway. Chip can transmit only one frame with MTU 1500 at a ti=
me,
> >>     and tx buffer size is bigger.
> >
> > So what happens if XXX frames are given to start_xmit() in a flood =
?
> >
> > You removed any flow control, how can this work ?
> >
> > Device has an infinite queue ?
>=20
> As I understand from datasheet, device doesn't have tx queue at all.
> It have tx buffer, processor must save transmitted frame to it, and t=
hen=20
> save SEND command to command register. When transmission completed,=20
> SENDOK bit in interrupt register will be set to '1', and interrupt=20
> handler will be called.
>=20
> So, according to datasheet, driver must stop queue in start_xmit()=20
> routine, and wake in interrupt handler of SENDOK bit.
> I tried this, and it basically works, but SOMETIMES, very rare, I see=
=20
> tx_timeout().
>=20
> And without any flow control - driver works perfectly.
> Weird, don't know why.

Really this should be fixed, since your driver makes qdisc flow control
impossible (unless adding a rate limiter like HTB/CBQ)

You probably had a race on your xmit routine, and interrupt routine.

You need proper synchronization : A spinlock to make this easy, or a
smart barrier game.
