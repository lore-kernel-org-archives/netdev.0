From: Stephen Hemminger <shemminger@vyatta.com>
Subject: [PATCH 3/3] bonding: handle case of device named bonding_master
Date: Wed, 14 May 2008 18:15:28 -0700
Message-ID: <20080514181528.1ff1791a@extreme>
References: <20080514170316.672f809d@extreme>
	<20080514181257.74fbb5aa@extreme>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, bonding-devel@lists.sourceforge.net,
	linux-kernel@vger.kernel.org
To: David Miller <davem@davemloft.net>, fubar@us.ibm.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail.vyatta.com ([216.93.170.194]:50089 "EHLO mail.vyatta.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1755514AbYEOBQQ (ORCPT <rfc822;netdev@vger.kernel.org>);
	Wed, 14 May 2008 21:16:16 -0400
In-Reply-To: <20080514181257.74fbb5aa@extreme>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

If device already exists named bonding_masters, then fail. This is a wierd
corner case only a QA group could love.

Signed-off-by: Stephen Hemminger <shemminger@vyatta.com>
---
Note: bonding is not yet network namespace aware, it will need lots of
work to get this to happen.

--- a/drivers/net/bonding/bond_sysfs.c	2008-05-14 17:49:29.000000000 -0700
+++ b/drivers/net/bonding/bond_sysfs.c	2008-05-14 18:02:36.000000000 -0700
@@ -1437,8 +1437,16 @@ int bond_create_sysfs(void)
 	 * configure multiple bonding devices.
 	 */
 	if (ret == -EEXIST) {
-		netdev_class = NULL;
-		return 0;
+		/* Is someone being kinky and naming a device bonding_master? */
+		if (__dev_get_by_name(&init_net,
+				      class_attr_bonding_masters.attr.name))
+			printk(KERN_ERR
+			       "network device named %s already exists in sysfs",
+			       class_attr_bonding_masters.attr.name);
+		else {
+			netdev_class = NULL;
+			return 0;
+		}
 	}
 
 	return ret;
