From: Tobias Diedrich <ranma+kernel@tdiedrich.de>
Subject: [PATCH] Re: forcedeth: lockdep warning on ethtool -s
Date: Sun, 15 Jun 2008 21:44:15 +0200
Message-ID: <20080615194415.GB2824@yamamaya.is-a-geek.org>
References: <20080601083700.GA3036@yamamaya.is-a-geek.org> <20080605221842.a444ec9d.akpm@linux-foundation.org>
Mime-Version: 1.0
Content-Type: text/plain; charset=utf-8
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: netdev@vger.kernel.org, linux-kernel@vger.kernel.org,
	Ayaz Abdulla <aabdulla@nvidia.com>
To: Andrew Morton <akpm@linux-foundation.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from yumi.tdiedrich.de ([85.10.210.183]:33177 "EHLO mx.tdiedrich.de"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1751080AbYFOTov (ORCPT <rfc822;netdev@vger.kernel.org>);
	Sun, 15 Jun 2008 15:44:51 -0400
Content-Disposition: inline
In-Reply-To: <20080605221842.a444ec9d.akpm@linux-foundation.org>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Andrew Morton wrote:
> On Sun, 1 Jun 2008 10:37:01 +0200 Tobias Diedrich <ranma+kernel@tdied=
rich.de> wrote:
>=20
> > Hi,
> >=20
> > After enabling CONFIG_LOCKDEP and CONFIG_PROVE_LOCKING I get the
> > following warning when ethtool -s is first called on one of the
> > forcedeth ports:
> >=20
> > =3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=
=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D
> > [ INFO: inconsistent lock state ]
> > 2.6.26-rc4 #28
> > ---------------------------------
> > inconsistent {in-hardirq-W} -> {hardirq-on-W} usage.
> > ethtool/1985 [HC0[0]:SC0[1]:HE1:SE0] takes:
> >  (&np->lock){++..}, at: [<ffffffffa000c5fd>] nv_set_settings+0xc8/0=
x3de [forcedeth]
> > {in-hardirq-W} state was registered at:
> >   [<ffffffffffffffff>] 0xffffffffffffffff
> > irq event stamp: 3606
> > hardirqs last  enabled at (3605): [<ffffffff8068106f>] _spin_unlock=
_irqrestore+0x3f/0x68
> > hardirqs last disabled at (3604): [<ffffffff80680d38>] _spin_lock_i=
rqsave+0x13/0x46
> > softirqs last  enabled at (3534): [<ffffffff80246ba5>] __do_softirq=
+0xbc/0xc5
> > softirqs last disabled at (3606): [<ffffffff80680b33>] _spin_lock_b=
h+0x11/0x41
> >=20
> > other info that might help us debug this:
> > 2 locks held by ethtool/1985:
> >  #0:  (rtnl_mutex){--..}, at: [<ffffffff80596072>] rtnl_lock+0x12/0=
x14
> >  #1:  (_xmit_ETHER){-+..}, at: [<ffffffffa000c5e8>] nv_set_settings=
+0xb3/0x3de [forcedeth]
> >=20
> > stack backtrace:
> > Pid: 1985, comm: ethtool Not tainted 2.6.26-rc4 #28
> >=20
> > Call Trace:
> >  [<ffffffff8025f190>] print_usage_bug+0x162/0x173
> >  [<ffffffff8025fa8b>] mark_lock+0x231/0x41f
> >  [<ffffffff802607cf>] __lock_acquire+0x4e7/0xcac
> >  [<ffffffff8025fe64>] ? trace_hardirqs_on+0xf1/0x115
> >  [<ffffffff80272c3a>] ? disable_irq_nosync+0x6f/0x7b
> >  [<ffffffff80261375>] lock_acquire+0x55/0x6e
> >  [<ffffffffa000c5fd>] ? :forcedeth:nv_set_settings+0xc8/0x3de
> >  [<ffffffff80680b15>] _spin_lock+0x2f/0x3c
> >  [<ffffffffa000c5fd>] :forcedeth:nv_set_settings+0xc8/0x3de
> >  [<ffffffff8058f8bb>] dev_ethtool+0x186/0xea3
> >  [<ffffffff8067f446>] ? mutex_lock_nested+0x243/0x275
> >  [<ffffffff8025df2b>] ? debug_mutex_free_waiter+0x46/0x4a
> >  [<ffffffff8067f469>] ? mutex_lock_nested+0x266/0x275
> >  [<ffffffff8058e1ce>] dev_ioctl+0x4eb/0x600
> >  [<ffffffff8068106f>] ? _spin_unlock_irqrestore+0x3f/0x68
> >  [<ffffffff80580f91>] sock_ioctl+0x1f5/0x202
> >  [<ffffffff802a322e>] vfs_ioctl+0x2a/0x77
> >  [<ffffffff802a34d6>] do_vfs_ioctl+0x25b/0x270
> >  [<ffffffff806807b6>] ? trace_hardirqs_on_thunk+0x35/0x3a
> >  [<ffffffff802a352d>] sys_ioctl+0x42/0x65
> >  [<ffffffff8021fffb>] system_call_after_swapgs+0x7b/0x80
> >=20
> >=20
> > I think this is caused by the following snippet in nv_set_settings:
> >=20
> > 	netif_carrier_off(dev);
> > 	if (netif_running(dev)) {
> > 		nv_disable_irq(dev);
> > 		netif_tx_lock_bh(dev);
> > 		spin_lock(&np->lock);
> > 		/* stop engines */
> > 		nv_stop_rxtx(dev);
> > 		spin_unlock(&np->lock);
> > 		netif_tx_unlock_bh(dev);
> > 	}
> >=20
> >=20
> > Because of nv_disable_irq this is probably not really a problem
> > though (I guess) and replacing the spin_lock with spin_lock_irqsave
> > could keep interrupts disabled for a longer period of time because
> > of delays in nv_stop_rx and nv_stop_tx.
>=20
> Could you please try that and if it works, send the patch?

Here you go, with this patch applied I get no warning:

Signed-Off-By: Tobias Diedrich <ranma+kernel@tdiedrich.de>

Index: linux-2.6.26-rc4.forcedwol/drivers/net/forcedeth.c
=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=
=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=
=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D
--- linux-2.6.26-rc4.forcedwol.orig/drivers/net/forcedeth.c	2008-06-15 =
20:45:32.000000000 +0200
+++ linux-2.6.26-rc4.forcedwol/drivers/net/forcedeth.c	2008-06-15 20:55=
:27.000000000 +0200
@@ -4198,12 +4198,23 @@
=20
 	netif_carrier_off(dev);
 	if (netif_running(dev)) {
+		unsigned long flags;
+
 		nv_disable_irq(dev);
 		netif_tx_lock_bh(dev);
-		spin_lock(&np->lock);
+		/* with plain spinlock lockdep complains */
+		spin_lock_irqsave(&np->lock, flags);
 		/* stop engines */
+		/* FIXME:
+		 * this can take some time, and interrupts are disabled
+		 * due to spin_lock_irqsave, but let's hope no daemon
+		 * is going to change the settings very often...
+		 * Worst case:
+		 * NV_RXSTOP_DELAY1MAX + NV_TXSTOP_DELAY1MAX=20
+		 * + some minor delays, which is up to a second approximately
+		 */
 		nv_stop_rxtx(dev);
-		spin_unlock(&np->lock);
+		spin_unlock_irqrestore(&np->lock, flags);
 		netif_tx_unlock_bh(dev);
 	}

--=20
Tobias						PGP: http://9ac7e0bc.uguu.de
=E3=81=93=E3=81=AE=E3=83=A1=E3=83=BC=E3=83=AB=E3=81=AF=E5=8D=81=E5=89=B2=
=E5=86=8D=E5=88=A9=E7=94=A8=E3=81=95=E3=82=8C=E3=81=9F=E3=83=93=E3=83=83=
=E3=83=88=E3=81=A7=E4=BD=9C=E3=82=89=E3=82=8C=E3=81=A6=E3=81=84=E3=81=BE=
=E3=81=99=E3=80=82
