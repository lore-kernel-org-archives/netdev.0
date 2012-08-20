From: Eric Dumazet <eric.dumazet@gmail.com>
Subject: Re: [PATCH net-next] xfrm: fix RCU bugs
Date: Mon, 20 Aug 2012 07:33:20 +0200
Message-ID: <1345440800.5158.239.camel@edumazet-glaptop>
References: <1345372308.5158.54.camel@edumazet-glaptop>
	 <5031BFB1.200@windriver.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: David Miller <davem@davemloft.net>,
	netdev <netdev@vger.kernel.org>, fengguang.wu@intel.com,
	Priyanka Jain <Priyanka.Jain@freescale.com>
To: Fan Du <fan.du@windriver.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-wg0-f44.google.com ([74.125.82.44]:59614 "EHLO
	mail-wg0-f44.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1753738Ab2HTFdZ (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 20 Aug 2012 01:33:25 -0400
Received: by wgbdr13 with SMTP id dr13so5018791wgb.1
        for <netdev@vger.kernel.org>; Sun, 19 Aug 2012 22:33:24 -0700 (PDT)
In-Reply-To: <5031BFB1.200@windriver.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Mon, 2012-08-20 at 12:40 +0800, Fan Du wrote:
> Hi Eric
>=20
> Please correct me if I'm wrong about below comments.
>=20
> On 2012=E5=B9=B408=E6=9C=8819=E6=97=A5 18:31, Eric Dumazet wrote:
> > From: Eric Dumazet<edumazet@google.com>
> >
> > This patch reverts commit 56892261ed1a (xfrm: Use rcu_dereference_b=
h to
> > deference pointer protected by rcu_read_lock_bh), and fixes bugs
> > introduced in commit 418a99ac6ad ( Replace rwlock on xfrm_policy_af=
info
> > with rcu )
> >
> > 1) We properly use RCU variant in this file, not a mix of RCU/RCU_B=
H
> >
> > 2) We must defer some writes after the synchronize_rcu() call or a =
reader
> >   can crash dereferencing NULL pointer.
>=20
> Not exactly.
>=20
> net/ipv4/xfrm4_policy.c
> static void __exit xfrm4_policy_fini(void)
>    -> xfrm_policy_unregister_afinfo
>=20
> IMHO, ip stack can never be compiled as module, so is xfrm4_policy_fi=
ni
> freed up after system bootup? which means xfrm4_policy_fini can never=
 be
> called.
>=20
> so an dereferencing NULL pointer by a reader could not happen.
>=20

Last famous words.

Anyway xfrm_policy_unregister_afinfo() is also called from
xfrm6_policy_fini(), and IPv6 is a module. The day we can rmmod it,
we uncover this bug.

RCU is complex (most people dont get it right, thats the truth),
and we should make it rock solid, or I can guarantee you
many patch attempts from future readers of this code.

You wont tell them :

"OK but dont worry we never call this function for real, why do you car=
e
at all"

> >
> > 3) Now we use the xfrm_policy_afinfo_lock spinlock only from proces=
s
> > context, we no longer need to block BH in xfrm_policy_register_afin=
fo()
> > and xfrm_policy_unregister_afinfo()
> >
> I don't think it's related to what kinds of locks we are using.
> we call xfrm_policy_register_afinfo in process context, but actually
> what xfrm_policy_afinfo_lock protected can be used in soft irq contex=
t.
> that's why xx_bh is used in:

You did an RCU conversion and obviously have little idea of what
happened there.

This _bh stuff was needed because _before_ RCU, an rwlock was used.

And since read_lock() was used from BH handler, _all_ write_lock() had
to use the write_lock_bh() variant to avoid a possible deadlock.

But after RCU, this no longer is needed, as an rcu_read_lock() cannot
block a writer anymore in the lock/unlock section.

In fact, xfrm_policy_afinfo_lock could be replaced by a mutex. So _bh()
is absolutely not needed anymore.
