From: Ben Hutchings <bhutchings@solarflare.com>
Subject: Re: [PATCH] bnx2: Use dev_kfree_skb_any() in bnx2_tx_int()
Date: Fri, 1 Nov 2013 23:34:50 +0000
Message-ID: <1383348890.1737.40.camel@bwh-desktop.uk.level5networks.com>
References: <CAM_iQpWAbSWVeAMwhQADTwO_RdYUXfog-wG9gs4+Zek0g_5Oyg@mail.gmail.com>
	 <20131031.002602.2030884257299947291.davem@davemloft.net>
	 <CAM_iQpXPrEj619=PRaKN4PxgOoEB96U0mLFS65AzXOezSWvhxQ@mail.gmail.com>
	 <20131101.180147.629210014672277622.davem@davemloft.net>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: <xiyou.wangcong@gmail.com>, <mchan@broadcom.com>,
	<tdmackey@booleanhaiku.com>, <netdev@vger.kernel.org>,
	<linux-kernel@vger.kernel.org>
To: David Miller <davem@davemloft.net>
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <20131101.180147.629210014672277622.davem@davemloft.net>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On Fri, 2013-11-01 at 18:01 -0400, David Miller wrote:
> From: Cong Wang <xiyou.wangcong@gmail.com>
> Date: Thu, 31 Oct 2013 21:19:16 -0700
>=20
> > 2013=E5=B9=B410=E6=9C=8830=E6=97=A5 =E4=B8=8B=E5=8D=889:26=E4=BA=8E=
 "David Miller" <davem@davemloft.net>=E5=86=99=E9=81=93=EF=BC=9A
> >>
> >> We have to provide a softint compatible environment for this callb=
ack
> >> to run in else everything is completely broken.
> >>
> >> All these drivers can safely assume softirq safe locking is
> >> sufficient, you're suggesting we need to take this hardirq safety =
and
> >> I'm really not willing to allow things to go that far.  A lot of
> >> effort has been expended precisely to avoid that kind of overhead =
and
> >> cost.
> >=20
> > Alright, I am thinking to move netpoll_poll_dev() to a delayed work=
=2E
> =20
> What if the printk is outputting a message that will help us discover
> that work queues are deadlocked?
>=20
> You can't delay the message, because every layer of indirection you
> add increases the possibility that the message it never seen.  You
> have to do it synchronously.

As you've said, the ndo_start_xmit and NAPI poll operations are intende=
d
to be called in softirq context, so everything that interlocks with the=
m
will use spin_lock_bh().  Calling them from hardirq context obviously
opens the possibility of a deadlock.  How do you expect anyone to solve
that?

I think that most of the time netpoll doesn't actually call the NAPI
poll function, and the driver ndo_start_xmit function doesn't take any
locks, so we don't actually hit the deadlock in practice (on mainline
kernels - RT is a different story).

Obviously, the less machinery netpoll relies on continuing to work, the
better, so it should preferably defer to sofirq context rather than
workqueue context.  I think this means hooking queue_process() into
net_tx_action(), and then cutting out much of the rest of netpoll.

Ben.

--=20
Ben Hutchings, Staff Engineer, Solarflare
Not speaking for my employer; that's the marketing department's job.
They asked us to note that Solarflare product names are trademarked.
