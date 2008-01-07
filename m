From: Jay Vosburgh <fubar@us.ibm.com>
Subject: Re: [Bugme-new] [Bug 9543] New: RTNL: assertion failed at net/ipv6/addrconf.c (2164)/RTNL: assertion failed at net/ipv4/devinet.c (1055)
Date: Mon, 07 Jan 2008 12:40:25 -0800
Message-ID: <3528.1199738425@death>
References: <E1J2Rgs-0006mz-00@gondolin.me.apana.org.au> <28503.1197481615@death> <Pine.LNX.4.64.0712141707090.30334@bizon.gios.gov.pl> <20071214182638.GC25879@gospo.usersys.redhat.com> <Pine.LNX.4.64.0712141955080.12202@bizon.gios.gov.pl> <20071214224722.GA8728@gospo.usersys.redhat.com> <Pine.LNX.4.64.0712182052490.24949@bizon.gios.gov.pl> <20071219144208.GB8728@gospo.usersys.redhat.com> <Pine.LNX.4.64.0801071854140.6696@bizon.gios.gov.pl> <20080107202626.GC8728@gospo.usersys.redhat.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=utf-8
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: Krzysztof Oledzki <olel@ans.pl>,
	Herbert Xu <herbert@gondor.apana.org.au>,
	Andrew Morton <akpm@linux-foundation.org>,
	bugme-daemon@bugzilla.kernel.org, shemminger@linux-foundation.org,
	davem@davemloft.net, netdev@vger.kernel.org
To: Andy Gospodarek <andy@greyhouse.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from e36.co.us.ibm.com ([32.97.110.154]:48459 "EHLO
	e36.co.us.ibm.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1754891AbYAGUke convert rfc822-to-8bit (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 7 Jan 2008 15:40:34 -0500
Received: from d03relay02.boulder.ibm.com (d03relay02.boulder.ibm.com [9.17.195.227])
	by e36.co.us.ibm.com (8.13.8/8.13.8) with ESMTP id m07KeTia002436
	for <netdev@vger.kernel.org>; Mon, 7 Jan 2008 15:40:29 -0500
Received: from d03av02.boulder.ibm.com (d03av02.boulder.ibm.com [9.17.195.168])
	by d03relay02.boulder.ibm.com (8.13.8/8.13.8/NCO v8.7) with ESMTP id m07KeT8T009086
	for <netdev@vger.kernel.org>; Mon, 7 Jan 2008 13:40:29 -0700
Received: from d03av02.boulder.ibm.com (loopback [127.0.0.1])
	by d03av02.boulder.ibm.com (8.12.11.20060308/8.13.3) with ESMTP id m07KeRvc016935
	for <netdev@vger.kernel.org>; Mon, 7 Jan 2008 13:40:28 -0700
In-reply-to: <20080107202626.GC8728@gospo.usersys.redhat.com> 
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Andy Gospodarek <andy@greyhouse.net> wrote:

>On Mon, Jan 07, 2008 at 06:57:25PM +0100, Krzysztof Oledzki wrote:
>>=20
>>=20
>> On Wed, 19 Dec 2007, Andy Gospodarek wrote:
>>=20
>> >On Tue, Dec 18, 2007 at 08:53:39PM +0100, Krzysztof Oledzki wrote:
>> >>
>> >>
>> >>On Fri, 14 Dec 2007, Andy Gospodarek wrote:
>> >>
>> >>>On Fri, Dec 14, 2007 at 07:57:42PM +0100, Krzysztof Oledzki wrote=
:
>> >>>>
>> >>>>
>> >>>>On Fri, 14 Dec 2007, Andy Gospodarek wrote:
>> >>>>
>> >>>>>On Fri, Dec 14, 2007 at 05:14:57PM +0100, Krzysztof Oledzki wro=
te:
>> >>>>>>
>> >>>>>>
>> >>>>>>On Wed, 12 Dec 2007, Jay Vosburgh wrote:
>> >>>>>>
>> >>>>>>>Herbert Xu <herbert@gondor.apana.org.au> wrote:
>> >>>>>>>
>> >>>>>>>>>diff -puN drivers/net/bonding/bond_sysfs.c~bonding-locking-=
fix
>> >>>>>>>>>drivers/net/bonding/bond_sysfs.c
>> >>>>>>>>>--- a/drivers/net/bonding/bond_sysfs.c~bonding-locking-fix
>> >>>>>>>>>+++ a/drivers/net/bonding/bond_sysfs.c
>> >>>>>>>>>@@ -1111,8 +1111,6 @@ static ssize_t bonding_store_primary(=
str
>> >>>>>>>>>out:
>> >>>>>>>>>    write_unlock_bh(&bond->lock);
>> >>>>>>>>>
>> >>>>>>>>>-       rtnl_unlock();
>> >>>>>>>>>-
>> >>>>>>>>
>> >>>>>>>>Looking at the changeset that added this perhaps the intenti=
on
>> >>>>>>>>is to hold the lock? If so we should add an rtnl_lock to the=
 start
>> >>>>>>>>of the function.
>> >>>>>>>
>> >>>>>>>	Yes, this function needs to hold locks, and more than just
>> >>>>>>>what's there now.  I believe the following should be correct;=
 I=20
>> >>>>>>>haven't
>> >>>>>>>tested it, though (I'm supposedly on vacation right now).
>> >>>>>>>
>> >>>>>>>	The following change should be correct for the
>> >>>>>>>bonding_store_primary case discussed in this thread, and also=
=20
>> >>>>>>>corrects
>> >>>>>>>the bonding_store_active case which performs similar function=
s.
>> >>>>>>>
>> >>>>>>>	The bond_change_active_slave and bond_select_active_slave
>> >>>>>>>functions both require rtnl, bond->lock for read and curr_sla=
ve_lock
>> >>>>>>>for
>> >>>>>>>write_bh, and no other locks.  This is so that the lower leve=
l
>> >>>>>>>mode-specific functions can release locks down to just rtnl i=
n order=20
>> >>>>>>>to
>> >>>>>>>call, e.g., dev_set_mac_address with the locks it expects (rt=
nl=20
>> >>>>>>>only).
>> >>>>>>>
>> >>>>>>>Signed-off-by: Jay Vosburgh <fubar@us.ibm.com>
>> >>>>>>>
>> >>>>>>>diff --git a/drivers/net/bonding/bond_sysfs.c
>> >>>>>>>b/drivers/net/bonding/bond_sysfs.c
>> >>>>>>>index 11b76b3..28a2d80 100644
>> >>>>>>>--- a/drivers/net/bonding/bond_sysfs.c
>> >>>>>>>+++ b/drivers/net/bonding/bond_sysfs.c
>> >>>>>>>@@ -1075,7 +1075,10 @@ static ssize_t bonding_store_primary(s=
truct
>> >>>>>>>device
>> >>>>>>>*d,
>> >>>>>>>	struct slave *slave;
>> >>>>>>>	struct bonding *bond =3D to_bond(d);
>> >>>>>>>
>> >>>>>>>-	write_lock_bh(&bond->lock);
>> >>>>>>>+	rtnl_lock();
>> >>>>>>>+	read_lock(&bond->lock);
>> >>>>>>>+	write_lock_bh(&bond->curr_slave_lock);
>> >>>>>>>+
>> >>>>>>>	if (!USES_PRIMARY(bond->params.mode)) {
>> >>>>>>>		printk(KERN_INFO DRV_NAME
>> >>>>>>>		       ": %s: Unable to set primary slave; %s is in=20
>> >>>>>>>		       mode
>> >>>>>>>		       %d\n",
>> >>>>>>>@@ -1109,8 +1112,8 @@ static ssize_t bonding_store_primary(st=
ruct
>> >>>>>>>device
>> >>>>>>>*d,
>> >>>>>>>		}
>> >>>>>>>	}
>> >>>>>>>out:
>> >>>>>>>-	write_unlock_bh(&bond->lock);
>> >>>>>>>-
>> >>>>>>>+	write_unlock_bh(&bond->curr_slave_lock);
>> >>>>>>>+	read_unlock(&bond->lock);
>> >>>>>>>	rtnl_unlock();
>> >>>>>>>
>> >>>>>>>	return count;
>> >>>>>>>@@ -1190,7 +1193,8 @@ static ssize_t=20
>> >>>>>>>bonding_store_active_slave(struct
>> >>>>>>>device *d,
>> >>>>>>>	struct bonding *bond =3D to_bond(d);
>> >>>>>>>
>> >>>>>>>	rtnl_lock();
>> >>>>>>>-	write_lock_bh(&bond->lock);
>> >>>>>>>+	read_lock(&bond->lock);
>> >>>>>>>+	write_lock_bh(&bond->curr_slave_lock);
>> >>>>>>>
>> >>>>>>>	if (!USES_PRIMARY(bond->params.mode)) {
>> >>>>>>>		printk(KERN_INFO DRV_NAME
>> >>>>>>>@@ -1247,7 +1251,8 @@ static ssize_t=20
>> >>>>>>>bonding_store_active_slave(struct
>> >>>>>>>device *d,
>> >>>>>>>		}
>> >>>>>>>	}
>> >>>>>>>out:
>> >>>>>>>-	write_unlock_bh(&bond->lock);
>> >>>>>>>+	write_unlock_bh(&bond->curr_slave_lock);
>> >>>>>>>+	read_unlock(&bond->lock);
>> >>>>>>>	rtnl_unlock();
>> >>>>>>>
>> >>>>>>>	return count;
>> >>>>>>
>> >>>>>>Vanilla 2.6.24-rc5 plus this patch:
>> >>>>>>
>> >>>>>>=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=
=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=
=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D
>> >>>>>>[ INFO: possible irq lock inversion dependency detected ]
>> >>>>>>2.6.24-rc5 #1
>> >>>>>>---------------------------------------------------------
>> >>>>>>events/0/9 just changed the state of lock:
>> >>>>>>(&mc->mca_lock){-+..}, at: [<c0411c7a>]=20
>> >>>>>>mld_ifc_timer_expire+0x130/0x1fb
>> >>>>>>but this lock took another, soft-read-irq-unsafe lock in the p=
ast:
>> >>>>>>(&bond->lock){-.--}
>> >>>>>>
>> >>>>>>and interrupts could create inverse lock ordering between them=
=2E
>> >>>>>>
>> >>>>>>
>> >>>>>
>> >>>>>Grrr, I should have seen that -- sorry.  Try your luck with thi=
s=20
>> >>>>>instead:
>> >>>><CUT>
>> >>>>
>> >>>>No luck.
>> >>>>
>> >>>
>> >>>
>> >>>I'm guessing if we go back to using a write-lock for bond->lock t=
his
>> >>>will go back to working again, but I'm not totally convinced sinc=
e there
>> >>>are plenty of places where we used a read-lock with it.
>> >>
>> >>Should I check this patch or rather, based on a future discussion,=
 wait
>> >>for another version?
>> >>
>> >>>
>> >>>diff --git a/drivers/net/bonding/bond_sysfs.c
>> >>>b/drivers/net/bonding/bond_sysfs.c
>> >>>index 11b76b3..635b857 100644
>> >>>--- a/drivers/net/bonding/bond_sysfs.c
>> >>>+++ b/drivers/net/bonding/bond_sysfs.c
>> >>>@@ -1075,7 +1075,10 @@ static ssize_t bonding_store_primary(struc=
t device
>> >>>*d,
>> >>>	struct slave *slave;
>> >>>	struct bonding *bond =3D to_bond(d);
>> >>>
>> >>>+	rtnl_lock();
>> >>>	write_lock_bh(&bond->lock);
>> >>>+	write_lock_bh(&bond->curr_slave_lock);
>> >>>+
>> >>>	if (!USES_PRIMARY(bond->params.mode)) {
>> >>>		printk(KERN_INFO DRV_NAME
>> >>>		       ": %s: Unable to set primary slave; %s is in mode
>> >>>		       %d\n",
>> >>>@@ -1109,8 +1112,8 @@ static ssize_t bonding_store_primary(struct=
 device
>> >>>*d,
>> >>>		}
>> >>>	}
>> >>>out:
>> >>>+	write_unlock_bh(&bond->curr_slave_lock);
>> >>>	write_unlock_bh(&bond->lock);
>> >>>-
>> >>>	rtnl_unlock();
>> >>>
>> >>>	return count;
>> >>>@@ -1191,6 +1194,7 @@ static ssize_t bonding_store_active_slave(s=
truct
>> >>>device *d,
>> >>>
>> >>>	rtnl_lock();
>> >>>	write_lock_bh(&bond->lock);
>> >>>+	write_lock_bh(&bond->curr_slave_lock);
>> >>>
>> >>>	if (!USES_PRIMARY(bond->params.mode)) {
>> >>>		printk(KERN_INFO DRV_NAME
>> >>>@@ -1247,6 +1251,7 @@ static ssize_t bonding_store_active_slave(s=
truct
>> >>>device *d,
>> >>>		}
>> >>>	}
>> >>>out:
>> >>>+	write_unlock_bh(&bond->curr_slave_lock);
>> >>>	write_unlock_bh(&bond->lock);
>> >>>	rtnl_unlock();
>> >>>
>> >>
>> >>
>> >>Best regards,
>> >>
>> >>					Krzysztof Ol=C4=99dzki
>> >
>> >For now, I prefer Jay's original patch -- with the read_locks (rath=
er
>> >than read/write_lock_bh) and the added rtnl_lock.  There is still a
>> >lockdep issue that we need to sort-out, but this patch is needed fi=
rst.
>>=20
>> This bug has not been fixed yet as it still exists in 2.6.24-rc7. An=
y=20
>> chances to cure it before 2.6.24-final?
>>=20
>> Best regards,
>>=20
>> 				Krzysztof Ol=C4=99dzki
>
>Krzysztof,
>
>I doubt the lockdep issue will be fixed, but the patch Jay posted and =
I
>acked needs to be included in 2.6.24.

	I'm (finally) back from vacation and am working on the lock
problem right now; there are a couple of other changes that need to go
in (in addition to what was posted previously).  One is a spurious RTNL
warning, the other is a similar 'wrong lock' type of problem that arise=
s
during module unload.

	I should have a patch set for this posted in a couple of hours.

>I played around with the locking when setting the multicast list and I
>can make the lockdep issue go away, but I need to be sure that it's OK
>to switch it to a read-lock from a write-lock (and I don't really thin=
k
>it is).

	I haven't looked at the lockdep problem yet.  If you want to be
brave and post your working patch for the lockdep thing, I might be abl=
e
to crush your hopes that it's ok.

	-J

---
	-Jay Vosburgh, IBM Linux Technology Center, fubar@us.ibm.com
