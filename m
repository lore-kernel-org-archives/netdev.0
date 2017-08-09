From: Felix Manlunas <felix.manlunas@cavium.com>
Subject: [PATCH net-next] liquidio: napi cleanup
Date: Tue, 8 Aug 2017 19:34:28 -0700
Message-ID: <20170809023428.GA2054@felix-thinkpad.cavium.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: netdev@vger.kernel.org, raghu.vatsavayi@cavium.com,
        derek.chickles@cavium.com, satananda.burla@cavium.com,
        intiyaz.basha@cavium.com
To: davem@davemloft.net
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-co1nam03on0078.outbound.protection.outlook.com ([104.47.40.78]:15617
        "EHLO NAM03-CO1-obe.outbound.protection.outlook.com"
        rhost-flags-OK-OK-OK-FAIL) by vger.kernel.org with ESMTP
        id S1752466AbdHICe5 (ORCPT <rfc822;netdev@vger.kernel.org>);
        Tue, 8 Aug 2017 22:34:57 -0400
Content-Disposition: inline
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Intiyaz Basha <intiyaz.basha@cavium.com>

Disable napi when interface is going down.
Delete napi when destroying the interface.

Signed-off-by: Intiyaz Basha <intiyaz.basha@cavium.com>
Signed-off-by: Felix Manlunas <felix.manlunas@cavium.com>
---
 drivers/net/ethernet/cavium/liquidio/lio_main.c    | 15 +++++++++++++++
 drivers/net/ethernet/cavium/liquidio/lio_vf_main.c | 14 ++++++++++++++
 2 files changed, 29 insertions(+)

diff --git a/drivers/net/ethernet/cavium/liquidio/lio_main.c b/drivers/net/ethernet/cavium/liquidio/lio_main.c
index 3ec0dd9..cbd6287 100644
--- a/drivers/net/ethernet/cavium/liquidio/lio_main.c
+++ b/drivers/net/ethernet/cavium/liquidio/lio_main.c
@@ -1736,6 +1736,10 @@ static void liquidio_destroy_nic_device(struct octeon_device *oct, int ifidx)
 			oct->droq[0]->ops.poll_mode = 0;
 	}
 
+	/* Delete NAPI */
+	list_for_each_entry_safe(napi, n, &netdev->napi_list, dev_list)
+		netif_napi_del(napi);
+
 	if (atomic_read(&lio->ifstate) & LIO_IFSTATE_REGISTERED)
 		unregister_netdev(netdev);
 
@@ -2770,6 +2774,17 @@ static int liquidio_stop(struct net_device *netdev)
 {
 	struct lio *lio = GET_LIO(netdev);
 	struct octeon_device *oct = lio->oct_dev;
+	struct napi_struct *napi, *n;
+
+	if (oct->props[lio->ifidx].napi_enabled) {
+		list_for_each_entry_safe(napi, n, &netdev->napi_list, dev_list)
+			napi_disable(napi);
+
+		oct->props[lio->ifidx].napi_enabled = 0;
+
+		if (OCTEON_CN23XX_PF(oct))
+			oct->droq[0]->ops.poll_mode = 0;
+	}
 
 	ifstate_reset(lio, LIO_IFSTATE_RUNNING);
 
diff --git a/drivers/net/ethernet/cavium/liquidio/lio_vf_main.c b/drivers/net/ethernet/cavium/liquidio/lio_vf_main.c
index 935ff29..c6f52f2 100644
--- a/drivers/net/ethernet/cavium/liquidio/lio_vf_main.c
+++ b/drivers/net/ethernet/cavium/liquidio/lio_vf_main.c
@@ -1137,6 +1137,10 @@ static void liquidio_destroy_nic_device(struct octeon_device *oct, int ifidx)
 		oct->droq[0]->ops.poll_mode = 0;
 	}
 
+	/* Delete NAPI */
+	list_for_each_entry_safe(napi, n, &netdev->napi_list, dev_list)
+		netif_napi_del(napi);
+
 	if (atomic_read(&lio->ifstate) & LIO_IFSTATE_REGISTERED)
 		unregister_netdev(netdev);
 
@@ -1784,6 +1788,16 @@ static int liquidio_stop(struct net_device *netdev)
 {
 	struct lio *lio = GET_LIO(netdev);
 	struct octeon_device *oct = lio->oct_dev;
+	struct napi_struct *napi, *n;
+
+	if (oct->props[lio->ifidx].napi_enabled) {
+		list_for_each_entry_safe(napi, n, &netdev->napi_list, dev_list)
+			napi_disable(napi);
+
+		oct->props[lio->ifidx].napi_enabled = 0;
+
+		oct->droq[0]->ops.poll_mode = 0;
+	}
 
 	netif_info(lio, ifdown, lio->netdev, "Stopping interface!\n");
 	/* Inform that netif carrier is down */
