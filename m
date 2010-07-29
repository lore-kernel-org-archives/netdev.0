From: Andy Gospodarek <andy@greyhouse.net>
Subject: Re: [PATCH net-next] bonding: take rtnl in bond_loadbalance_arp_mon
Date: Wed, 28 Jul 2010 21:13:56 -0400
Message-ID: <20100729011355.GV7497@gospo.rdu.redhat.com>
References: <1280351076-19973-1-git-send-email-andy@greyhouse.net> <29111.1280353189@death>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: netdev@vger.kernel.org
To: Jay Vosburgh <fubar@us.ibm.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mx1.redhat.com ([209.132.183.28]:34643 "EHLO mx1.redhat.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1751178Ab0G2BN6 (ORCPT <rfc822;netdev@vger.kernel.org>);
	Wed, 28 Jul 2010 21:13:58 -0400
Content-Disposition: inline
In-Reply-To: <29111.1280353189@death>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Wed, Jul 28, 2010 at 02:39:49PM -0700, Jay Vosburgh wrote:
> Andy Gospodarek <andy@greyhouse.net> wrote:
> 
> >With the latest code in net-next-2.6 the following (and similar) are
> >spewed when using arp monitoring and balance-alb.
> 
> 	Does the ARP monitor function correctly for balance-alb?  My
> recollection is that the ARP monitor probes interfere with the tailored
> ARP messages that balance-alb sends.

It seems to work fine here on a few tries (I only use sysfs for
configuration anymore), but it might be blind luck that the addresses
chosen are hashing out correctly to make arp monitoring work.

> The bond_check_params function
> disallows setting arp_interval (it forces miimon on).  I suspect this
> nuance was missed when setting up the sysfs code, but if it does work,
> then perhaps it is too strict.

You are correct, it does.  It is clear that some checks should be added
to the sysfs code and it also seems like some work should be done to
more clearly define what modes support which form of link monitoring (it
doesn't seem to me like balance-rr should support can monitoring in it's
current implementation, but there is no explicit code to check for it in
the sysfs-layer or bond_check_params).

> 	As I recall, I had deliberately left acquiring rtnl out of the
> loadbalance_arp_mon function, since none of the modes that used it
> required rtnl for failover.

Understood.

Based on your comments, at least something like the following should
probably be done.


[PATCH net-next] bonding: prevent sysfs from allowing arp monitoring with alb/tlb

When using module options arp monitoring and balance-alb/balance-tlb
are mutually exclusive options.  Anytime balance-alb/balance-tlb are
enabled mii monitoring is forced to 100ms if not set.  When configuring
via sysfs no checking is currently done.

Handling these cases with sysfs has to be done a bit differently because
we do not have all configuration information available at once.  This
patch will not allow a mode change to balance-alb/balance-tlb if
arp_interval is already non-zero.  It will also not allow the user to
set a non-zero arp_interval value if the mode is already set to
balance-alb/balance-tlb.  They are still mutually exclusive on a
first-come, first serve basis.

Tested with initscripts on Fedora and manual setting via sysfs.

Signed-off-by: Andy Gospodarek <gospo@redhat.com>

---
 drivers/net/bonding/bond_sysfs.c |   37 +++++++++++++++++++++++++------------
 1 files changed, 25 insertions(+), 12 deletions(-)

diff --git a/drivers/net/bonding/bond_sysfs.c b/drivers/net/bonding/bond_sysfs.c
index 1a99764..c311aed 100644
--- a/drivers/net/bonding/bond_sysfs.c
+++ b/drivers/net/bonding/bond_sysfs.c
@@ -313,19 +313,26 @@ static ssize_t bonding_store_mode(struct device *d,
 		       bond->dev->name, (int)strlen(buf) - 1, buf);
 		ret = -EINVAL;
 		goto out;
-	} else {
-		if (bond->params.mode == BOND_MODE_8023AD)
-			bond_unset_master_3ad_flags(bond);
+	}
+	if ((new_value == BOND_MODE_ALB ||
+	     new_value == BOND_MODE_TLB) &&
+	    bond->params.arp_interval) {
+		pr_err("%s: %s mode is incompatible with arp monitoring.\n",
+		       bond->dev->name, bond_mode_tbl[new_value].modename);
+		ret = -EINVAL;
+		goto out;
+	}
+	if (bond->params.mode == BOND_MODE_8023AD)
+		bond_unset_master_3ad_flags(bond);
 
-		if (bond->params.mode == BOND_MODE_ALB)
-			bond_unset_master_alb_flags(bond);
+	if (bond->params.mode == BOND_MODE_ALB)
+		bond_unset_master_alb_flags(bond);
 
-		bond->params.mode = new_value;
-		bond_set_mode_ops(bond, bond->params.mode);
-		pr_info("%s: setting mode to %s (%d).\n",
-			bond->dev->name, bond_mode_tbl[new_value].modename,
-		       new_value);
-	}
+	bond->params.mode = new_value;
+	bond_set_mode_ops(bond, bond->params.mode);
+	pr_info("%s: setting mode to %s (%d).\n",
+		bond->dev->name, bond_mode_tbl[new_value].modename,
+		new_value);
 out:
 	return ret;
 }
@@ -510,7 +517,13 @@ static ssize_t bonding_store_arp_interval(struct device *d,
 		ret = -EINVAL;
 		goto out;
 	}
-
+	if (bond->params.mode == BOND_MODE_ALB ||
+	    bond->params.mode == BOND_MODE_TLB) {
+		pr_info("%s: ARP monitoring cannot be used with ALB/TLB. Only MII monitoring is supported on %s.\n",
+			bond->dev->name, bond->dev->name);
+		ret = -EINVAL;
+		goto out;
+	}
 	pr_info("%s: Setting ARP monitoring interval to %d.\n",
 		bond->dev->name, new_value);
 	bond->params.arp_interval = new_value;
-- 
1.7.0.1

