From: Vladislav Yasevich <vyasevich@gmail.com>
Subject: [PATCH] macvlan: Propagate promiscuity setting to lower devices.
Date: Fri,  1 May 2015 17:36:37 -0400
Message-ID: <1430516197-3271-1-git-send-email-vyasevic@redhat.com>
Cc: Vladislav Yasevich <vyasevic@redhat.com>
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-qc0-f169.google.com ([209.85.216.169]:36129 "EHLO
	mail-qc0-f169.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751378AbbEAVhN (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 1 May 2015 17:37:13 -0400
Received: by qcbdu2 with SMTP id du2so7418451qcb.3
        for <netdev@vger.kernel.org>; Fri, 01 May 2015 14:37:12 -0700 (PDT)
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

When a macvlan device is placed in promiscuous mode, it currently
just sets it's multicast mask to permissive, but doesn't change
the state of the lower device.  As a result, not all multicast
traffic can be received on such device.  Additionally, none of
a vlan traffic can be received on such device as well.
This patch propagates the promiscuous mode setting to lower device
so that lower device may receive all packets that macvlan may
be interested in.

Signed-off-by: Vladislav Yasevich <vyasevic@redhat.com>
---
 drivers/net/macvlan.c | 15 +++++++++++++++
 1 file changed, 15 insertions(+)

diff --git a/drivers/net/macvlan.c b/drivers/net/macvlan.c
index b227a13..806e83d 100644
--- a/drivers/net/macvlan.c
+++ b/drivers/net/macvlan.c
@@ -599,10 +599,18 @@ static int macvlan_open(struct net_device *dev)
 			goto del_unicast;
 	}
 
+	if (dev->flags & IFF_PROMISC) {
+		err = dev_set_promiscuity(lowerdev, 1);
+		if (err < 0)
+			goto clear_multi;
+	}
+
 hash_add:
 	macvlan_hash_add(vlan);
 	return 0;
 
+clear_multi:
+	dev_set_allmulti(lowerdev, -1);
 del_unicast:
 	dev_uc_del(lowerdev, dev->dev_addr);
 out:
@@ -638,6 +646,9 @@ static int macvlan_stop(struct net_device *dev)
 	if (dev->flags & IFF_ALLMULTI)
 		dev_set_allmulti(lowerdev, -1);
 
+	if (dev->flags & IFF_PROMISC)
+		dev_set_promiscuity(lowerdev, -1);
+
 	dev_uc_del(lowerdev, dev->dev_addr);
 
 hash_del:
@@ -696,6 +707,10 @@ static void macvlan_change_rx_flags(struct net_device *dev, int change)
 	if (dev->flags & IFF_UP) {
 		if (change & IFF_ALLMULTI)
 			dev_set_allmulti(lowerdev, dev->flags & IFF_ALLMULTI ? 1 : -1);
+		if (change & IFF_PROMISC)
+			dev_set_promiscuity(lowerdev,
+					    dev->flags & IFF_PROMISC ? 1 : -1);
+
 	}
 }
 
-- 
1.9.3
