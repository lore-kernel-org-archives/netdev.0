From: Andy Gospodarek <andy@greyhouse.net>
Subject: Re: [Bugme-new] [Bug 9543] New: RTNL: assertion failed at net/ipv6/addrconf.c (2164)/RTNL: assertion failed at net/ipv4/devinet.c (1055)
Date: Fri, 14 Dec 2007 17:47:22 -0500
Message-ID: <20071214224722.GA8728@gospo.usersys.redhat.com>
References: <E1J2Rgs-0006mz-00@gondolin.me.apana.org.au> <28503.1197481615@death> <Pine.LNX.4.64.0712141707090.30334@bizon.gios.gov.pl> <20071214182638.GC25879@gospo.usersys.redhat.com> <Pine.LNX.4.64.0712141955080.12202@bizon.gios.gov.pl>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: Andy Gospodarek <andy@greyhouse.net>,
	Jay Vosburgh <fubar@us.ibm.com>,
	Herbert Xu <herbert@gondor.apana.org.au>,
	Andrew Morton <akpm@linux-foundation.org>,
	bugme-daemon@bugzilla.kernel.org, shemminger@linux-foundation.org,
	davem@davemloft.net, netdev@vger.kernel.org
To: Krzysztof Oledzki <olel@ans.pl>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mx1.redhat.com ([66.187.233.31]:42206 "EHLO mx1.redhat.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1751563AbXLNWrp (ORCPT <rfc822;netdev@vger.kernel.org>);
	Fri, 14 Dec 2007 17:47:45 -0500
Content-Disposition: inline
In-Reply-To: <Pine.LNX.4.64.0712141955080.12202@bizon.gios.gov.pl>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Fri, Dec 14, 2007 at 07:57:42PM +0100, Krzysztof Oledzki wrote:
> 
> 
> On Fri, 14 Dec 2007, Andy Gospodarek wrote:
> 
> >On Fri, Dec 14, 2007 at 05:14:57PM +0100, Krzysztof Oledzki wrote:
> >>
> >>
> >>On Wed, 12 Dec 2007, Jay Vosburgh wrote:
> >>
> >>>Herbert Xu <herbert@gondor.apana.org.au> wrote:
> >>>
> >>>>>diff -puN drivers/net/bonding/bond_sysfs.c~bonding-locking-fix
> >>>>>drivers/net/bonding/bond_sysfs.c
> >>>>>--- a/drivers/net/bonding/bond_sysfs.c~bonding-locking-fix
> >>>>>+++ a/drivers/net/bonding/bond_sysfs.c
> >>>>>@@ -1111,8 +1111,6 @@ static ssize_t bonding_store_primary(str
> >>>>>out:
> >>>>>      write_unlock_bh(&bond->lock);
> >>>>>
> >>>>>-       rtnl_unlock();
> >>>>>-
> >>>>
> >>>>Looking at the changeset that added this perhaps the intention
> >>>>is to hold the lock? If so we should add an rtnl_lock to the start
> >>>>of the function.
> >>>
> >>>	Yes, this function needs to hold locks, and more than just
> >>>what's there now.  I believe the following should be correct; I haven't
> >>>tested it, though (I'm supposedly on vacation right now).
> >>>
> >>>	The following change should be correct for the
> >>>bonding_store_primary case discussed in this thread, and also corrects
> >>>the bonding_store_active case which performs similar functions.
> >>>
> >>>	The bond_change_active_slave and bond_select_active_slave
> >>>functions both require rtnl, bond->lock for read and curr_slave_lock for
> >>>write_bh, and no other locks.  This is so that the lower level
> >>>mode-specific functions can release locks down to just rtnl in order to
> >>>call, e.g., dev_set_mac_address with the locks it expects (rtnl only).
> >>>
> >>>Signed-off-by: Jay Vosburgh <fubar@us.ibm.com>
> >>>
> >>>diff --git a/drivers/net/bonding/bond_sysfs.c
> >>>b/drivers/net/bonding/bond_sysfs.c
> >>>index 11b76b3..28a2d80 100644
> >>>--- a/drivers/net/bonding/bond_sysfs.c
> >>>+++ b/drivers/net/bonding/bond_sysfs.c
> >>>@@ -1075,7 +1075,10 @@ static ssize_t bonding_store_primary(struct device
> >>>*d,
> >>>	struct slave *slave;
> >>>	struct bonding *bond = to_bond(d);
> >>>
> >>>-	write_lock_bh(&bond->lock);
> >>>+	rtnl_lock();
> >>>+	read_lock(&bond->lock);
> >>>+	write_lock_bh(&bond->curr_slave_lock);
> >>>+
> >>>	if (!USES_PRIMARY(bond->params.mode)) {
> >>>		printk(KERN_INFO DRV_NAME
> >>>		       ": %s: Unable to set primary slave; %s is in mode
> >>>		       %d\n",
> >>>@@ -1109,8 +1112,8 @@ static ssize_t bonding_store_primary(struct device
> >>>*d,
> >>>		}
> >>>	}
> >>>out:
> >>>-	write_unlock_bh(&bond->lock);
> >>>-
> >>>+	write_unlock_bh(&bond->curr_slave_lock);
> >>>+	read_unlock(&bond->lock);
> >>>	rtnl_unlock();
> >>>
> >>>	return count;
> >>>@@ -1190,7 +1193,8 @@ static ssize_t bonding_store_active_slave(struct
> >>>device *d,
> >>>	struct bonding *bond = to_bond(d);
> >>>
> >>>	rtnl_lock();
> >>>-	write_lock_bh(&bond->lock);
> >>>+	read_lock(&bond->lock);
> >>>+	write_lock_bh(&bond->curr_slave_lock);
> >>>
> >>>	if (!USES_PRIMARY(bond->params.mode)) {
> >>>		printk(KERN_INFO DRV_NAME
> >>>@@ -1247,7 +1251,8 @@ static ssize_t bonding_store_active_slave(struct
> >>>device *d,
> >>>		}
> >>>	}
> >>>out:
> >>>-	write_unlock_bh(&bond->lock);
> >>>+	write_unlock_bh(&bond->curr_slave_lock);
> >>>+	read_unlock(&bond->lock);
> >>>	rtnl_unlock();
> >>>
> >>>	return count;
> >>
> >>Vanilla 2.6.24-rc5 plus this patch:
> >>
> >>=========================================================
> >>[ INFO: possible irq lock inversion dependency detected ]
> >>2.6.24-rc5 #1
> >>---------------------------------------------------------
> >>events/0/9 just changed the state of lock:
> >> (&mc->mca_lock){-+..}, at: [<c0411c7a>] mld_ifc_timer_expire+0x130/0x1fb
> >>but this lock took another, soft-read-irq-unsafe lock in the past:
> >> (&bond->lock){-.--}
> >>
> >>and interrupts could create inverse lock ordering between them.
> >>
> >>
> >
> >Grrr, I should have seen that -- sorry.  Try your luck with this instead:
> <CUT>
> 
> No luck.
> 


I'm guessing if we go back to using a write-lock for bond->lock this
will go back to working again, but I'm not totally convinced since there
are plenty of places where we used a read-lock with it.


diff --git a/drivers/net/bonding/bond_sysfs.c b/drivers/net/bonding/bond_sysfs.c
index 11b76b3..635b857 100644
--- a/drivers/net/bonding/bond_sysfs.c
+++ b/drivers/net/bonding/bond_sysfs.c
@@ -1075,7 +1075,10 @@ static ssize_t bonding_store_primary(struct device *d,
 	struct slave *slave;
 	struct bonding *bond = to_bond(d);
 
+	rtnl_lock();
 	write_lock_bh(&bond->lock);
+	write_lock_bh(&bond->curr_slave_lock);
+
 	if (!USES_PRIMARY(bond->params.mode)) {
 		printk(KERN_INFO DRV_NAME
 		       ": %s: Unable to set primary slave; %s is in mode %d\n",
@@ -1109,8 +1112,8 @@ static ssize_t bonding_store_primary(struct device *d,
 		}
 	}
 out:
+	write_unlock_bh(&bond->curr_slave_lock);
 	write_unlock_bh(&bond->lock);
-
 	rtnl_unlock();
 
 	return count;
@@ -1191,6 +1194,7 @@ static ssize_t bonding_store_active_slave(struct device *d,
 
 	rtnl_lock();
 	write_lock_bh(&bond->lock);
+	write_lock_bh(&bond->curr_slave_lock);
 
 	if (!USES_PRIMARY(bond->params.mode)) {
 		printk(KERN_INFO DRV_NAME
@@ -1247,6 +1251,7 @@ static ssize_t bonding_store_active_slave(struct device *d,
 		}
 	}
 out:
+	write_unlock_bh(&bond->curr_slave_lock);
 	write_unlock_bh(&bond->lock);
 	rtnl_unlock();
 
