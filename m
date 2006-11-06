From: Stephen Hemminger <shemminger@osdl.org>
Subject: Re: [sungem] proposal for a new locking strategy
Date: Mon, 6 Nov 2006 13:49:41 -0800
Message-ID: <20061106134941.09a7d9bb@freekitty>
References: <5cac192f0611050500m19f72209vc349f235680023a1@mail.gmail.com>
	<20061105090254.66710154@localhost.localdomain>
	<5cac192f0611050928w50127396l2a88978bf97b2bff@mail.gmail.com>
	<20061105094136.75677aa4@localhost.localdomain>
	<5cac192f0611050952w443e6042r11c6c66b0e84685d@mail.gmail.com>
	<20061105104955.2d9a9473@localhost.localdomain>
	<5cac192f0611051211t55e4c724w3eea5043dfc53db6@mail.gmail.com>
	<20061106095551.18f9661c@freekitty>
	<5cac192f0611061255hbe26632t8b605300e27bc1fa@mail.gmail.com>
	<20061106125723.0fa9c5e6@freekitty>
	<5cac192f0611061310o7b4d267eg37fef6a0cb81bd61@mail.gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Cc: "Benjamin Herrenschmidt" <benh@kernel.crashing.org>,
	"David S. Miller" <davem@davemloft.net>, netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from smtp.osdl.org ([65.172.181.4]:52427 "EHLO smtp.osdl.org")
	by vger.kernel.org with ESMTP id S1753840AbWKFVtr (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 6 Nov 2006 16:49:47 -0500
To: "Eric Lemoine" <eric.lemoine@gmail.com>
In-Reply-To: <5cac192f0611061310o7b4d267eg37fef6a0cb81bd61@mail.gmail.com>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

O
> > > > But the spin is still there, just more complex..
> > > > In qdisc_restart() processing of NETDEV_TX_LOCKED causes:
> > > >         spin_lock(dev->xmit_lock)
> > > >
> > > >         q->requeue()
> > > >         netif_schedule(dev);
> > > >
> > > > SOFTIRQ:
> > > >         net_tx_action()
> > > >         qdisc_run() --> qdisc_restart()
> > > >
> > > > So instead of spinning in tight loop, you end up with a longer code
> > > > path.
> > >
> > > Stephen, sorry for insisting a bit but I'm failing to see how B is
> > > different from C in that respect. With method B, in qdisc_restart(),
> > > if netif_tx_trylock() fails to acquire the lock then we also
> > > requeue(), etc. Same long code path in case of contention.
> > >
> >
> > Method C LLTX causes repeated softirq's which will be slower since the loop
> > requires more instructions than a simple spin loop (Method B).
> 
> What I'm saying above is that Method B also causes repeated tx
> softirqs in case of contention on netif_tx_lock. The code path is :
> netif_tx_trylock() fails -> requeue() -> netif_schedule() ->
> raise_softirq(NET_TX_SOFTIRQ). Am I missing anything?
> 

Never mind, you right.  I think the netif_tx_trylock() there is a bad
idea because of the long route as shown.  Trylock's are usually bad SMP
design anyway. Not sure if it would be possible to change the locking
in qdisc_restart() without causing collateral damage in network drivers.


-- 
Stephen Hemminger <shemminger@osdl.org>
