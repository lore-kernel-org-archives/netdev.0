From: Jiri Bohac <jbohac@suse.cz>
Subject: [PATCH] bonding: fix a race condition in calls to slave MII ioctls
Date: Wed, 21 Oct 2009 15:03:01 +0200
Message-ID: <20091021130301.GA4762@midget.suse.cz>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: netdev@vger.kernel.org
To: fubar@us.ibm.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from cantor.suse.de ([195.135.220.2]:52050 "EHLO mx1.suse.de"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1751746AbZJUNDF (ORCPT <rfc822;netdev@vger.kernel.org>);
	Wed, 21 Oct 2009 09:03:05 -0400
Content-Disposition: inline
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Hi,

In mii monitor mode, bond_check_dev_link() calls the the ioctl
handler of slave devices. It stores the ndo_do_ioctl function
pointer to a static (!) ioctl variable and later uses it to call the
handler with the IOCTL macro.

If another thread executes bond_check_dev_link() at the same time
(even with a different bond, which none of the locks prevent), a
race condition occurs. If the two racing slaves have different
drivers, this may result in one driver's ioctl handler being
called with a pointer to a net_device controlled with a different
driver, resulting in unpredictable breakage.

Unless I am overlooking something, the "static" must be a
copy'n'paste error (?).


Signed-off-by: Jiri Bohac <jbohac@suse.cz>

diff --git a/drivers/net/bonding/bond_main.c b/drivers/net/bonding/bond_main.c
index 69c5b15..5bfdd0c 100644
--- a/drivers/net/bonding/bond_main.c
+++ b/drivers/net/bonding/bond_main.c
@@ -691,7 +691,7 @@ static int bond_check_dev_link(struct bonding *bond,
 			       struct net_device *slave_dev, int reporting)
 {
 	const struct net_device_ops *slave_ops = slave_dev->netdev_ops;
-	static int (*ioctl)(struct net_device *, struct ifreq *, int);
+	int (*ioctl)(struct net_device *, struct ifreq *, int);
 	struct ifreq ifr;
 	struct mii_ioctl_data *mii;
 



-- 
Jiri Bohac <jbohac@suse.cz>
SUSE Labs, SUSE CZ

