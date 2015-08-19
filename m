From: Nikolay Aleksandrov <razor@blackwall.org>
Subject: [PATCH net-next 3/4] vrf: move vrf_insert_slave so we can drop a goto label
Date: Wed, 19 Aug 2015 06:27:09 +0300
Message-ID: <1439954830-24947-4-git-send-email-razor@blackwall.org>
References: <1439954830-24947-1-git-send-email-razor@blackwall.org>
Cc: dsa@cumulusnetworks.com, shm@cumulusnetworks.com,
	davem@davemloft.net,
	Nikolay Aleksandrov <nikolay@cumulusnetworks.com>
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-wi0-f178.google.com ([209.85.212.178]:36738 "EHLO
	mail-wi0-f178.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1753462AbbHSPAu (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 19 Aug 2015 11:00:50 -0400
Received: by wicja10 with SMTP id ja10so122563287wic.1
        for <netdev@vger.kernel.org>; Wed, 19 Aug 2015 08:00:49 -0700 (PDT)
In-Reply-To: <1439954830-24947-1-git-send-email-razor@blackwall.org>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Nikolay Aleksandrov <nikolay@cumulusnetworks.com>

We can simplify do_vrf_add_slave by moving vrf_insert_slave in the end
of the enslaving and thus eliminate an error goto label. It always
succeeds and isn't needed before that anyway.

Signed-off-by: Nikolay Aleksandrov <nikolay@cumulusnetworks.com>
---
 drivers/net/vrf.c | 8 ++------
 1 file changed, 2 insertions(+), 6 deletions(-)

diff --git a/drivers/net/vrf.c b/drivers/net/vrf.c
index 9907550ff640..4825c65c62fd 100644
--- a/drivers/net/vrf.c
+++ b/drivers/net/vrf.c
@@ -363,15 +363,13 @@ static int do_vrf_add_slave(struct net_device *dev, struct net_device *port_dev)
 	vrf_ptr->ifindex = dev->ifindex;
 	vrf_ptr->tb_id = vrf->tb_id;
 
-	__vrf_insert_slave(queue, slave);
-
 	/* register the packet handler for slave ports */
 	ret = netdev_rx_handler_register(port_dev, vrf_handle_frame, dev);
 	if (ret) {
 		netdev_err(port_dev,
 			   "Device %s failed to register rx_handler\n",
 			   port_dev->name);
-		goto out_remove;
+		goto out_fail;
 	}
 
 	ret = netdev_master_upper_dev_link(port_dev, dev);
@@ -379,7 +377,7 @@ static int do_vrf_add_slave(struct net_device *dev, struct net_device *port_dev)
 		goto out_unregister;
 
 	port_dev->flags |= IFF_SLAVE;
-
+	__vrf_insert_slave(queue, slave);
 	rcu_assign_pointer(port_dev->vrf_ptr, vrf_ptr);
 	cycle_netdev(port_dev);
 
@@ -387,8 +385,6 @@ static int do_vrf_add_slave(struct net_device *dev, struct net_device *port_dev)
 
 out_unregister:
 	netdev_rx_handler_unregister(port_dev);
-out_remove:
-	__vrf_remove_slave(queue, slave);
 out_fail:
 	kfree(vrf_ptr);
 	kfree(slave);
-- 
2.4.3
