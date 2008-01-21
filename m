From: David Miller <davem@davemloft.net>
Subject: Re: [patch for 2.6.24? 1/1] bonding: locking fix
Date: Sun, 20 Jan 2008 16:57:16 -0800 (PST)
Message-ID: <20080120.165716.172421176.davem@davemloft.net>
References: <20080114144754.29a448ad.akpm@linux-foundation.org>
	<16796.1200351673@death>
	<20080117154243.9ee4265c.akpm@linux-foundation.org>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: fubar@us.ibm.com, olel@ans.pl, jeff@garzik.org,
	shemminger@linux-foundation.org, netdev@vger.kernel.org
To: akpm@linux-foundation.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from 74-93-104-97-Washington.hfc.comcastbusiness.net ([74.93.104.97]:40453
	"EHLO sunset.davemloft.net" rhost-flags-OK-FAIL-OK-OK)
	by vger.kernel.org with ESMTP id S1755772AbYAUA5L (ORCPT
	<rfc822;netdev@vger.kernel.org>); Sun, 20 Jan 2008 19:57:11 -0500
In-Reply-To: <20080117154243.9ee4265c.akpm@linux-foundation.org>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Andrew Morton <akpm@linux-foundation.org>
Date: Thu, 17 Jan 2008 15:42:43 -0800

> Applying this:
> 
> --- a/drivers/net/bonding/bond_sysfs.c~bonding-locking-fix
> +++ a/drivers/net/bonding/bond_sysfs.c
> @@ -1111,8 +1111,6 @@ static ssize_t bonding_store_primary(str
>  out:
>  	write_unlock_bh(&bond->lock);
>  
> -	rtnl_unlock();
> -
>  	return count;
>  }
>  static DEVICE_ATTR(primary, S_IRUGO | S_IWUSR, bonding_show_primary, bonding_store_primary);
> 
> 
> is better than doing nothing.

If you look at the change that introduced this:

    commit 6603a6f25e4bca922a7dfbf0bf03072d98850176
    Author: Jay Vosburgh <fubar@us.ibm.com>
    Date:   Wed Oct 17 17:37:50 2007 -0700

    bonding: Convert more locks to _bh, acquire rtnl, for new locking
    
    	Convert more lock acquisitions to _bh flavor to avoid deadlock
    with workqueue activity and add acquisition of RTNL in appropriate places.
    Affects ALB mode, as well as core bonding functions and sysfs.
    
    Signed-off-by: Andy Gospodarek <andy@greyhouse.net>
    Signed-off-by: Jay Vosburgh <fubar@us.ibm.com>
    Signed-off-by: Jeff Garzik <jeff@garzik.org>

It is clearly the author's intent to surround the execution
of this function (and also bonding_show_active_slave() which
was done correctly) with RTNL semaphore holding.

Therefore the correct fix, which I'll push, is:

commit 991a15cb1cd60a918bd864bb79e7649c30aab275
Author: David S. Miller <davem@davemloft.net>
Date:   Sun Jan 20 16:55:20 2008 -0800

    [BONDING]: Fix rtnl locking in bonding_store_primary().
    
    Changeset 6603a6f25e4bca922a7dfbf0bf03072d98850176 (Convert more locks
    to _bh, acquire rtnl, for new locking) added a regression.
    
    A rtnl_unlock() was added but a rtnl_lock() was not.
    
    Signed-off-by: David S. Miller <davem@davemloft.net>

diff --git a/drivers/net/bonding/bond_sysfs.c b/drivers/net/bonding/bond_sysfs.c
index 11b76b3..4845c01 100644
--- a/drivers/net/bonding/bond_sysfs.c
+++ b/drivers/net/bonding/bond_sysfs.c
@@ -1075,6 +1075,7 @@ static ssize_t bonding_store_primary(struct device *d,
 	struct slave *slave;
 	struct bonding *bond = to_bond(d);
 
+	rtnl_lock();
 	write_lock_bh(&bond->lock);
 	if (!USES_PRIMARY(bond->params.mode)) {
 		printk(KERN_INFO DRV_NAME
