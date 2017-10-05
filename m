From: Patrick Talbert <ptalbert@redhat.com>
Subject: [PATCH net-next 1/1] [net] bonding: Add NUMA notice
Date: Thu,  5 Oct 2017 16:23:45 -0400
Message-ID: <1507235025-21689-1-git-send-email-ptalbert@redhat.com>
Cc: Patrick Talbert <ptalbert@redhat.com>
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mx1.redhat.com ([209.132.183.28]:48186 "EHLO mx1.redhat.com"
        rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
        id S1751350AbdJEUXs (ORCPT <rfc822;netdev@vger.kernel.org>);
        Thu, 5 Oct 2017 16:23:48 -0400
Received: from smtp.corp.redhat.com (int-mx03.intmail.prod.int.phx2.redhat.com [10.5.11.13])
        (using TLSv1.2 with cipher AECDH-AES256-SHA (256/256 bits))
        (No client certificate requested)
        by mx1.redhat.com (Postfix) with ESMTPS id DD6795F298A
        for <netdev@vger.kernel.org>; Thu,  5 Oct 2017 20:23:47 +0000 (UTC)
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Network performance can suffer when a load balancing bond uses slave
interfaces which are in different NUMA domains.

This compares the NUMA domain of a newly enslaved interface against any
existing enslaved interfaces and prints a warning if they do not match.

Signed-off-by: Patrick Talbert <ptalbert@redhat.com>
---
:100644 100644 b19dc03... 250a969... M	drivers/net/bonding/bond_main.c
 drivers/net/bonding/bond_main.c | 16 ++++++++++++++++
 1 file changed, 16 insertions(+)

diff --git a/drivers/net/bonding/bond_main.c b/drivers/net/bonding/bond_main.c
index b19dc03..250a969 100644
--- a/drivers/net/bonding/bond_main.c
+++ b/drivers/net/bonding/bond_main.c
@@ -55,6 +55,7 @@
 #include <asm/dma.h>
 #include <linux/uaccess.h>
 #include <linux/errno.h>
+#include <linux/device.h>
 #include <linux/netdevice.h>
 #include <linux/inetdevice.h>
 #include <linux/igmp.h>
@@ -1450,6 +1451,21 @@ int bond_enslave(struct net_device *bond_dev, struct net_device *slave_dev)
 		}
 	}
 
+	if (bond_has_slaves(bond)) {
+		struct list_head *iter;
+		struct slave *slave;
+
+		bond_for_each_slave(bond, slave, iter) {
+			if (slave_dev->dev.numa_node !=
+			    slave->dev->dev.numa_node) {
+				netdev_warn(bond_dev,
+					    "%s does not match NUMA domain of existing slaves. This could have a performance impact.",
+					    slave_dev->name);
+				break;
+			}
+		}
+	}
+
 	call_netdevice_notifiers(NETDEV_JOIN, slave_dev);
 
 	/* If this is the first slave, then we need to set the master's hardware
-- 
1.8.3.1
