From: Dhananjay Phadke <dhananjay@netxen.com>
Subject: [PATCH 2/7] netxen: fix rxbuf leak across driver reload
Date: Fri,  8 Aug 2008 00:08:40 -0700
Message-ID: <1218179325-32493-3-git-send-email-dhananjay@netxen.com>
Cc: jeff@garzik.org
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from [64.209.101.202] ([64.209.101.202]:60719 "EHLO unm84.unminc.com"
	rhost-flags-FAIL-FAIL-OK-FAIL) by vger.kernel.org with ESMTP
	id S1752210AbYHHHIr (ORCPT <rfc822;netdev@vger.kernel.org>);
	Fri, 8 Aug 2008 03:08:47 -0400
In-Reply-To: <>
References: <>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Free up rx ring during driver unload or open() failure.

Signed-off-by: Dhananjay Phadke <dhananjay@netxen.com>
---
 drivers/net/netxen/netxen_nic_main.c |    6 ++++--
 1 files changed, 4 insertions(+), 2 deletions(-)

diff --git a/drivers/net/netxen/netxen_nic_main.c b/drivers/net/netxen/netxen_nic_main.c
index 6fc42cd..056f6b1 100644
--- a/drivers/net/netxen/netxen_nic_main.c
+++ b/drivers/net/netxen/netxen_nic_main.c
@@ -1017,6 +1017,7 @@ static void __devexit netxen_nic_remove(struct pci_dev *pdev)
 
 	if (adapter->is_up == NETXEN_ADAPTER_UP_MAGIC) {
 		netxen_free_hw_resources(adapter);
+		netxen_release_rx_buffers(adapter);
 		netxen_free_sw_resources(adapter);
 	}
 
@@ -1111,7 +1112,7 @@ static int netxen_nic_open(struct net_device *netdev)
 				  flags, netdev->name, adapter);
 		if (err) {
 			printk(KERN_ERR "request_irq failed with: %d\n", err);
-			goto err_out_free_hw;
+			goto err_out_free_rxbuf;
 		}
 
 		adapter->is_up = NETXEN_ADAPTER_UP_MAGIC;
@@ -1144,7 +1145,8 @@ static int netxen_nic_open(struct net_device *netdev)
 
 err_out_free_irq:
 	free_irq(adapter->irq, adapter);
-err_out_free_hw:
+err_out_free_rxbuf:
+	netxen_release_rx_buffers(adapter);
 	netxen_free_hw_resources(adapter);
 err_out_free_sw:
 	netxen_free_sw_resources(adapter);
-- 
1.5.4.3

