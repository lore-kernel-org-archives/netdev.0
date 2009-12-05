From: Amit Kumar Salecha <amit.salecha@qlogic.com>
Subject: [PATCH NEXT 2/3] netxen:fix napi intr enable check
Date: Sat,  5 Dec 2009 14:23:55 -0800
Message-ID: <1260051836-14425-3-git-send-email-amit.salecha@qlogic.com>
References: <1260051836-14425-1-git-send-email-amit.salecha@qlogic.com>
Cc: netdev@vger.kernel.org, dhananjay.phadke@qlogic.com
To: davem@davemloft.net
Return-path: <netdev-owner@vger.kernel.org>
Received: from mvnat01.qlogic.com ([198.186.3.73]:33744 "HELO unm84.unmin.com"
	rhost-flags-OK-OK-OK-FAIL) by vger.kernel.org with SMTP
	id S1755929AbZLEWXv (ORCPT <rfc822;netdev@vger.kernel.org>);
	Sat, 5 Dec 2009 17:23:51 -0500
In-Reply-To: <1260051836-14425-1-git-send-email-amit.salecha@qlogic.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

o netif_running() check for enabling interrupt at end of napi poll is
  not enough to cover firmwar recovery. Instead test __NX_DEV_UP bit.
o Avoid re-entry into to netxen_nic_down() with __NX_DEV_UP bit check.

Acked-by: Dhananjay Phadke <dhananjay.phadke@qlogic.com>
Signed-off-by: Amit Kumar Salecha <amit.salecha@qlogic.com>
---
 drivers/net/netxen/netxen_nic_main.c |    6 ++++--
 1 files changed, 4 insertions(+), 2 deletions(-)

diff --git a/drivers/net/netxen/netxen_nic_main.c b/drivers/net/netxen/netxen_nic_main.c
index 8ffb30b..f499684 100644
--- a/drivers/net/netxen/netxen_nic_main.c
+++ b/drivers/net/netxen/netxen_nic_main.c
@@ -1011,8 +1011,10 @@ __netxen_nic_down(struct netxen_adapter *adapter, struct net_device *netdev)
 	if (adapter->is_up != NETXEN_ADAPTER_UP_MAGIC)
 		return;
 
-	clear_bit(__NX_DEV_UP, &adapter->state);
+	if (!test_and_clear_bit(__NX_DEV_UP, &adapter->state))
+		return;
 
+	smp_mb();
 	spin_lock(&adapter->tx_clean_lock);
 	netif_carrier_off(netdev);
 	netif_tx_disable(netdev);
@@ -2053,7 +2055,7 @@ static int netxen_nic_poll(struct napi_struct *napi, int budget)
 
 	if ((work_done < budget) && tx_complete) {
 		napi_complete(&sds_ring->napi);
-		if (netif_running(adapter->netdev))
+		if (test_bit(__NX_DEV_UP, &adapter->state))
 			netxen_nic_enable_int(sds_ring);
 	}
 
-- 
1.6.0.2

