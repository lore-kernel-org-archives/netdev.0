From: Willy Tarreau <willy@w.ods.org>
Subject: Re: Linux 2.4.30-rc2
Date: Sat, 26 Mar 2005 11:59:22 +0100
Message-ID: <20050326105922.GM30052@alpha.home.local>
References: <20050326004631.GC17637@logos.cnet>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: linux-kernel@vger.kernel.org, netdev@oss.sgi.com
To: Marcelo Tosatti <marcelo.tosatti@cyclades.com>, davem@davemloft.net
Content-Disposition: inline
In-Reply-To: <20050326004631.GC17637@logos.cnet>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Marcelo, David,

could we merge this patch from Mitch Williams in 2.4.30 ? It fixes a
stack dump when unloading the bonding module in 802.3ad mode if spinlock
debugging is turned on.

Thanks in advance,
Willy


diff -urN linux-2.4.29/drivers/net/bonding/bond_main.c linux-2.4.29-bond-2.6.1/drivers/net/bonding/bond_main.c
--- linux-2.4.29/drivers/net/bonding/bond_main.c	Sun Dec 12 12:06:28 2004
+++ linux-2.4.29-bond-2.6.1/drivers/net/bonding/bond_main.c	Sun Feb  6 20:32:49 2005
@@ -469,6 +469,13 @@
  *	  * Add support for VLAN hardware acceleration capable slaves.
  *	  * Add capability to tag self generated packets in ALB/TLB modes.
  *	  Set version to 2.6.0.
+ * 2004/10/29 - Mitch Williams <mitch.a.williams at intel dot com>
+ *	- Fixed bug when unloading module while using 802.3ad.  If
+ *	  spinlock debugging is turned on, this causes a stack dump.
+ *	  Solution is to move call to dev_remove_pack outside of the
+ *	  spinlock.
+ *	  Set version to 2.6.1.
+ *
  */
 
 //#define BONDING_DEBUG 1
@@ -3565,14 +3572,14 @@
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
+
+	write_lock_bh(&bond->lock);
+
+	bond_mc_list_destroy(bond);
 
 	/* signal timers not to re-arm */
 	bond->kill_timers = 1;
