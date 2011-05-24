From: Neil Horman <nhorman@tuxdriver.com>
Subject: Re: [PATCH] bonding: prevent deadlock on slave store with alb mode
Date: Tue, 24 May 2011 16:37:14 -0400
Message-ID: <20110524203714.GG28521@hmsreliant.think-freely.org>
References: <1306265765-8257-1-git-send-email-nhorman@tuxdriver.com>
 <20110524200047.GI21309@gospo.rdu.redhat.com>
 <4DDC116F.8020602@gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=iso-8859-1
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: Andy Gospodarek <andy@greyhouse.net>, netdev@vger.kernel.org,
	Jay Vosburgh <fubar@us.ibm.com>,
	"David S. Miller" <daevm@davemloft.net>
To: Nicolas de =?iso-8859-1?Q?Peslo=FCan?=
	<nicolas.2p.debian@gmail.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from charlotte.tuxdriver.com ([70.61.120.58]:58211 "EHLO
	smtp.tuxdriver.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1757174Ab1EXUhY (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 24 May 2011 16:37:24 -0400
Content-Disposition: inline
In-Reply-To: <4DDC116F.8020602@gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Tue, May 24, 2011 at 10:13:35PM +0200, Nicolas de Peslo=FCan wrote:
> Le 24/05/2011 22:00, Andy Gospodarek a =E9crit :
> >On Tue, May 24, 2011 at 03:36:05PM -0400, Neil Horman wrote:
> >>This soft lockup was recently reported:
> >>
> >>[root@dell-per715-01 ~]# echo +bond5>  /sys/class/net/bonding_maste=
rs
> >>[root@dell-per715-01 ~]# echo +eth1>  /sys/class/net/bond5/bonding/=
slaves
> >>bonding: bond5: doing slave updates when interface is down.
> >>bonding bond5: master_dev is not up in bond_enslave
> >>[root@dell-per715-01 ~]# echo -eth1>  /sys/class/net/bond5/bonding/=
slaves
> >>bonding: bond5: doing slave updates when interface is down.
> >>
> >>BUG: soft lockup - CPU#12 stuck for 60s! [bash:6444]
> >>CPU 12:
> >>Modules linked in: bonding autofs4 hidp rfcomm l2cap bluetooth lock=
d sunrpc
> >>be2d
> >>Pid: 6444, comm: bash Not tainted 2.6.18-262.el5 #1
> >>RIP: 0010:[<ffffffff80064bf0>]  [<ffffffff80064bf0>]
> >>.text.lock.spinlock+0x26/00
> >>RSP: 0018:ffff810113167da8  EFLAGS: 00000286
> >>RAX: ffff810113167fd8 RBX: ffff810123a47800 RCX: 0000000000ff1025
> >>RDX: 0000000000000000 RSI: ffff810123a47800 RDI: ffff81021b57f6f8
> >>RBP: ffff81021b57f500 R08: 0000000000000000 R09: 000000000000000c
> >>R10: 00000000ffffffff R11: ffff81011d41c000 R12: ffff81021b57f000
> >>R13: 0000000000000000 R14: 0000000000000282 R15: 0000000000000282
> >>FS:  00002b3b41ef3f50(0000) GS:ffff810123b27940(0000) knlGS:0000000=
000000000
> >>CS:  0010 DS: 0000 ES: 0000 CR0: 000000008005003b
> >>CR2: 00002b3b456dd000 CR3: 000000031fc60000 CR4: 00000000000006e0
> >>
> >>Call Trace:
> >>  [<ffffffff80064af9>] _spin_lock_bh+0x9/0x14
> >>  [<ffffffff886937d7>] :bonding:tlb_clear_slave+0x22/0xa1
> >>  [<ffffffff8869423c>] :bonding:bond_alb_deinit_slave+0xba/0xf0
> >>  [<ffffffff8868dda6>] :bonding:bond_release+0x1b4/0x450
> >>  [<ffffffff8006457b>] __down_write_nested+0x12/0x92
> >>  [<ffffffff88696ae4>] :bonding:bonding_store_slaves+0x25c/0x2f7
> >>  [<ffffffff801106f7>] sysfs_write_file+0xb9/0xe8
> >>  [<ffffffff80016b87>] vfs_write+0xce/0x174
> >>  [<ffffffff80017450>] sys_write+0x45/0x6e
> >>  [<ffffffff8005d28d>] tracesys+0xd5/0xe0
> >>
> >>It occurs because we are able to change the slave configuarion of a=
 bond while
> >>the bond interface is down.  The bonding driver initializes some da=
ta structures
> >>only after its ndo_open routine is called.  Among them is the inita=
lization of
> >>the alb tx and rx hash locks.  So if we add or remove a slave witho=
ut first
> >>opening the bond master device, we run the risk of trying to lock/u=
nlock a
> >>spinlock that has garbage for data in it, which results in our abov=
e softlock.
> >>
> >>We could fix it by moving the spin lock initalization to the device=
 creation
> >>path, but it seems that since we're warning people about not doing =
this, we
> >>should probably just disallow them from doing it, so fix it by addi=
ng an EINVAL
> >>return if we're not up yet.  Tested by the reporter and confirmed t=
o fix the
> >>problem.
> >>
> >>Signed-off-by: Neil Horman<nhorman@tuxdriver.com>
> >
> >Signed-off-by: Andy Gospodarek<andy@greyhouse.net>
> >
> >>Reported-by: jtluka@redhat.com
> >>CC: Jay Vosburgh<fubar@us.ibm.com>
> >>CC: Andy Gospodarek<andy@greyhouse.net>
> >>CC: "David S. Miller"<daevm@davemloft.net>
> >>---
> >>  drivers/net/bonding/bond_sysfs.c |    1 +
> >>  1 files changed, 1 insertions(+), 0 deletions(-)
> >>
> >>diff --git a/drivers/net/bonding/bond_sysfs.c b/drivers/net/bonding=
/bond_sysfs.c
> >>index 4059bfc..206c543 100644
> >>--- a/drivers/net/bonding/bond_sysfs.c
> >>+++ b/drivers/net/bonding/bond_sysfs.c
> >>@@ -231,6 +231,7 @@ static ssize_t bonding_store_slaves(struct devi=
ce *d,
> >>  	if (!(bond->dev->flags&  IFF_UP)) {
> >>  		pr_warning("%s: doing slave updates when interface is down.\n",
> >>  			   bond->dev->name);
> >>+		return -EINVAL;
>=20
> This will turn a warning into an error.
>=20
Yes, because it should have been an error all along.

> This warning existed for long, but never caused the bonding setup to
> fail. This patch cause some regression for user space. For example,
> current ifenslave-2.6 package in Debian doesn't ensure bond is UP
> before enslaving, because this was never required.
>=20
Thats not a regression, thats the kernel returning an error where it sh=
ould have
done so all along.  Just because a utility got away with it for awhile =
and it
didn't always cause a lockup, doesn't grandfather that application in t=
o a
situation where the kernel has to support its broken behavior in perpit=
uity. =20

Besides, iirc, the ifsenslave utility still uses the ioctl path, which =
this
patch doesn't touch, so ifenslave is currently unaffected (although I s=
hould
look in the ioctl path to see if we have already added such a check, le=
st you be
able to deadlock your system as previously indicated using that tool).

Neil

