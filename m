From: Arkadi Sharshevsky <arkadis@mellanox.com>
Subject: [PATCH net-next RFC 04/12] net: dsa: Add ordered workqueue
Date: Wed,  5 Jul 2017 18:36:22 +0300
Message-ID: <1499268990-19251-5-git-send-email-arkadis@mellanox.com>
References: <1499268990-19251-1-git-send-email-arkadis@mellanox.com>
Cc: davem@davemloft.net, jiri@resnulli.us, ivecera@redhat.com,
        f.fainelli@gmail.com, andrew@lunn.ch,
        vivien.didelot@savoirfairelinux.com, Woojung.Huh@microchip.com,
        stephen@networkplumber.org, mlxsw@mellanox.com,
        Arkadi Sharshevsky <arkadis@mellanox.com>
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-il-dmz.mellanox.com ([193.47.165.129]:49190 "EHLO
        mellanox.co.il" rhost-flags-OK-OK-OK-FAIL) by vger.kernel.org
        with ESMTP id S1751692AbdGEPdb (ORCPT
        <rfc822;netdev@vger.kernel.org>); Wed, 5 Jul 2017 11:33:31 -0400
In-Reply-To: <1499268990-19251-1-git-send-email-arkadis@mellanox.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

This workqueue will be used for FDB add/del processing. It should
be destroyed after all devices unregistered successfully.

Signed-off-by: Arkadi Sharshevsky <arkadis@mellanox.com>
---
 include/net/dsa.h |  1 +
 net/dsa/dsa.c     | 13 +++++++++++++
 2 files changed, 14 insertions(+)

diff --git a/include/net/dsa.h b/include/net/dsa.h
index f054d41..4835b0e 100644
--- a/include/net/dsa.h
+++ b/include/net/dsa.h
@@ -451,6 +451,7 @@ void unregister_switch_driver(struct dsa_switch_driver *type);
 struct mii_bus *dsa_host_dev_to_mii_bus(struct device *dev);
 
 struct net_device *dsa_dev_to_net_device(struct device *dev);
+bool dsa_schedule_work(struct work_struct *work);
 
 /* Keep inline for faster access in hot path */
 static inline bool netdev_uses_dsa(struct net_device *dev)
diff --git a/net/dsa/dsa.c b/net/dsa/dsa.c
index 416ac4e..9abe6dc 100644
--- a/net/dsa/dsa.c
+++ b/net/dsa/dsa.c
@@ -271,10 +271,22 @@ static struct packet_type dsa_pack_type __read_mostly = {
 	.func	= dsa_switch_rcv,
 };
 
+static struct workqueue_struct *dsa_owq;
+
+bool dsa_schedule_work(struct work_struct *work)
+{
+	return queue_work(dsa_owq, work);
+}
+
 static int __init dsa_init_module(void)
 {
 	int rc;
 
+	dsa_owq = alloc_ordered_workqueue("dsa_ordered",
+					  WQ_MEM_RECLAIM);
+	if (!dsa_owq)
+		return -ENOMEM;
+
 	rc = dsa_slave_register_notifier();
 	if (rc)
 		return rc;
@@ -294,6 +306,7 @@ static void __exit dsa_cleanup_module(void)
 	dsa_slave_unregister_notifier();
 	dev_remove_pack(&dsa_pack_type);
 	dsa_legacy_unregister();
+	destroy_workqueue(dsa_owq);
 }
 module_exit(dsa_cleanup_module);
 
-- 
2.4.11
