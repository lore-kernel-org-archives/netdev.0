From: Manish Chopra <manish.chopra@qlogic.com>
Subject: [PATCH net 1/2] netxen: Fix BUG "sleeping function called from invalid context"
Date: Tue, 30 Sep 2014 03:56:35 -0400
Message-ID: <1412063796-25959-2-git-send-email-manish.chopra@qlogic.com>
References: <1412063796-25959-1-git-send-email-manish.chopra@qlogic.com>
Mime-Version: 1.0
Content-Type: text/plain
Cc: <netdev@vger.kernel.org>, <umgwanakikbuti@gmail.com>,
	<Dept-GELinuxNICDev@qlogic.com>
To: <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mx0a-0016ce01.pphosted.com ([67.231.148.157]:10898 "EHLO
	mx0a-0016ce01.pphosted.com" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with ESMTP id S1751017AbaI3Iar (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 30 Sep 2014 04:30:47 -0400
In-Reply-To: <1412063796-25959-1-git-send-email-manish.chopra@qlogic.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

o __netxen_nic_down() function might sleep while holding spinlock_t(tx_clean_lock).
  Acquire this lock for only releasing TX buffers instead of taking it
  for whole down path.

Reported-by: Mike Galbraith <umgwanakikbuti@gmail.com>
Signed-off-by: Manish Chopra <manish.chopra@qlogic.com>
---
 .../net/ethernet/qlogic/netxen/netxen_nic_init.c   |    2 ++
 .../net/ethernet/qlogic/netxen/netxen_nic_main.c   |    2 --
 2 files changed, 2 insertions(+), 2 deletions(-)

diff --git a/drivers/net/ethernet/qlogic/netxen/netxen_nic_init.c b/drivers/net/ethernet/qlogic/netxen/netxen_nic_init.c
index 3205861..ae4ec7b 100644
--- a/drivers/net/ethernet/qlogic/netxen/netxen_nic_init.c
+++ b/drivers/net/ethernet/qlogic/netxen/netxen_nic_init.c
@@ -135,6 +135,7 @@ void netxen_release_tx_buffers(struct netxen_adapter *adapter)
 	int i, j;
 	struct nx_host_tx_ring *tx_ring = adapter->tx_ring;
 
+	spin_lock(&adapter->tx_clean_lock);
 	cmd_buf = tx_ring->cmd_buf_arr;
 	for (i = 0; i < tx_ring->num_desc; i++) {
 		buffrag = cmd_buf->frag_array;
@@ -158,6 +159,7 @@ void netxen_release_tx_buffers(struct netxen_adapter *adapter)
 		}
 		cmd_buf++;
 	}
+	spin_unlock(&adapter->tx_clean_lock);
 }
 
 void netxen_free_sw_resources(struct netxen_adapter *adapter)
diff --git a/drivers/net/ethernet/qlogic/netxen/netxen_nic_main.c b/drivers/net/ethernet/qlogic/netxen/netxen_nic_main.c
index 1159031..5ec5a2b 100644
--- a/drivers/net/ethernet/qlogic/netxen/netxen_nic_main.c
+++ b/drivers/net/ethernet/qlogic/netxen/netxen_nic_main.c
@@ -1186,7 +1186,6 @@ __netxen_nic_down(struct netxen_adapter *adapter, struct net_device *netdev)
 		return;
 
 	smp_mb();
-	spin_lock(&adapter->tx_clean_lock);
 	netif_carrier_off(netdev);
 	netif_tx_disable(netdev);
 
@@ -1204,7 +1203,6 @@ __netxen_nic_down(struct netxen_adapter *adapter, struct net_device *netdev)
 	netxen_napi_disable(adapter);
 
 	netxen_release_tx_buffers(adapter);
-	spin_unlock(&adapter->tx_clean_lock);
 }
 
 /* Usage: During suspend and firmware recovery module */
-- 
1.7.1
