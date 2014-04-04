From: Dan Williams <dcbw@redhat.com>
Subject: [RFC PATCH] bridge: remove !IFF_UP restriction when deleting bridge
 from ioctl
Date: Fri, 04 Apr 2014 09:56:22 -0500
Message-ID: <1396623382.15118.6.camel@dcbw.local>
Mime-Version: 1.0
Content-Type: text/plain; charset="UTF-8"
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org
To: Stephen Hemminger <stephen@networkplumber.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mx1.redhat.com ([209.132.183.28]:29816 "EHLO mx1.redhat.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1753521AbaDDO4H (ORCPT <rfc822;netdev@vger.kernel.org>);
	Fri, 4 Apr 2014 10:56:07 -0400
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

netlink doesn't care about IFF_UP when deleting a bridge, so "ip link
del br0" works just fine.  The ioctl does care, which means that brctl
complains "bridge br0 still up; can't delete it".  Make things
consistent by always allowing bridge deletion even if the bridge is up.

Signed-off-by: Dan Williams <dcbw@redhat.com>
---
Question: does anyone consider the ioctl behavior API?  Can we change it
even though it's been this way forever?  It means that bridges that
previously would not have been deleted by brctl will now be deleted.
But anyone using /sbin/ip could already delete them.

diff --git a/net/bridge/br_if.c b/net/bridge/br_if.c
index 54d207d..33cd83f 100644
--- a/net/bridge/br_if.c
+++ b/net/bridge/br_if.c
@@ -264,19 +264,14 @@ int br_del_bridge(struct net *net, const char *name)
 		ret =  -ENXIO; 	/* Could not find device */
 
 	else if (!(dev->priv_flags & IFF_EBRIDGE)) {
 		/* Attempt to delete non bridge device! */
 		ret = -EPERM;
 	}
 
-	else if (dev->flags & IFF_UP) {
-		/* Not shutdown yet. */
-		ret = -EBUSY;
-	}
-
 	else
 		br_dev_delete(dev, NULL);
 
 	rtnl_unlock();
 	return ret;
 }
 
