From: Andi Kleen <ak@suse.de>
Subject: Re: PATCH: bonding might sleep with lock held
Date: Thu, 13 May 2004 10:20:53 +0200
Sender: netdev-bounce@oss.sgi.com
Message-ID: <20040513082053.GC27682@wotan.suse.de>
References: <200405130215.i4D2FX52016740@death.nxdomain.ibm.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: netdev@oss.sgi.com
Return-path: <netdev-bounce@oss.sgi.com>
To: Jay Vosburgh <fubar@us.ibm.com>
Content-Disposition: inline
In-Reply-To: <200405130215.i4D2FX52016740@death.nxdomain.ibm.com>
Errors-to: netdev-bounce@oss.sgi.com
List-Id: netdev.vger.kernel.org

On Wed, May 12, 2004 at 07:15:33PM -0700, Jay Vosburgh wrote:
> 
> 	In 802.3ad mode, the bond_close() function will eventually call
> dev_remove_pack() with a lock held.  In turn, dev_remove_pack() calls
> synchronize_net() which eventually might sleep in wait_for_completion().
> Probably not good.
> 
> 	This patch replaces dev_remove_pack() with __dev_remove_pack()
> and adds a synchronize_net() call outside the lock.  The patch is
> against 2.6.5, but applied to 2.6.6 for me.

I would rather fix bond_close to not call this with the lock hold.
You can just move the call a few lines up. dev->close has own
synchronization anyways and dev_remove_pack has a lock too, so this
should be safe.

Patch to do that appeneded.

-Andi


diff -u linux/drivers/net/bonding/bond_main.c-o linux/drivers/net/bonding/bond_main.c
--- linux/drivers/net/bonding/bond_main.c-o	1970-01-01 01:12:51.000000000 +0100
+++ linux/drivers/net/bonding/bond_main.c	2004-05-13 10:20:06.000000000 +0200
@@ -3566,15 +3566,15 @@
 {
 	struct bonding *bond = bond_dev->priv;
 
-	write_lock_bh(&bond->lock);
-
-	bond_mc_list_destroy(bond);
-
 	if (bond->params.mode == BOND_MODE_8023AD) {
 		/* Unregister the receive of LACPDUs */
 		bond_unregister_lacpdu(bond);
 	}
 
+	write_lock_bh(&bond->lock);
+
+	bond_mc_list_destroy(bond);
+
 	/* signal timers not to re-arm */
 	bond->kill_timers = 1;
 
