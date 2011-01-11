From: Casey Leedom <leedom@chelsio.com>
Subject: [PATCH net-26] cxgb4vf: recover from failure in cxgb4vf_open()
Date: Tue, 11 Jan 2011 13:57:59 -0800
Message-ID: <1294783079-7481-1-git-send-email-leedom@chelsio.com>
Cc: davem@davemloft.net, Casey Leedom <leedom@chelsio.com>
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from stargate.chelsio.com ([67.207.112.58]:4044 "EHLO
	stargate.chelsio.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752112Ab1AKV6E (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 11 Jan 2011 16:58:04 -0500
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

If the Link Start fails in cxgb4vf_open(), we need to back out any state
that we've built up ...

Signed-off-by: Casey Leedom <leedom@chelsio.com>
---
 drivers/net/cxgb4vf/cxgb4vf_main.c |   15 ++++++++++-----
 1 files changed, 10 insertions(+), 5 deletions(-)

diff --git a/drivers/net/cxgb4vf/cxgb4vf_main.c b/drivers/net/cxgb4vf/cxgb4vf_main.c
index 3c403f8..56166ae 100644
--- a/drivers/net/cxgb4vf/cxgb4vf_main.c
+++ b/drivers/net/cxgb4vf/cxgb4vf_main.c
@@ -749,13 +749,19 @@ static int cxgb4vf_open(struct net_device *dev)
 	netif_set_real_num_tx_queues(dev, pi->nqsets);
 	err = netif_set_real_num_rx_queues(dev, pi->nqsets);
 	if (err)
-		return err;
-	set_bit(pi->port_id, &adapter->open_device_map);
+		goto err_unwind;
 	err = link_start(dev);
 	if (err)
-		return err;
+		goto err_unwind;
+
 	netif_tx_start_all_queues(dev);
+	set_bit(pi->port_id, &adapter->open_device_map);
 	return 0;
+
+err_unwind:
+	if (adapter->open_device_map == 0)
+		adapter_down(adapter);
+	return err;
 }
 
 /*
@@ -764,13 +770,12 @@ static int cxgb4vf_open(struct net_device *dev)
  */
 static int cxgb4vf_stop(struct net_device *dev)
 {
-	int ret;
 	struct port_info *pi = netdev_priv(dev);
 	struct adapter *adapter = pi->adapter;
 
 	netif_tx_stop_all_queues(dev);
 	netif_carrier_off(dev);
-	ret = t4vf_enable_vi(adapter, pi->viid, false, false);
+	t4vf_enable_vi(adapter, pi->viid, false, false);
 	pi->link_cfg.link_ok = 0;
 
 	clear_bit(pi->port_id, &adapter->open_device_map);
-- 
1.7.0.4

