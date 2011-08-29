From: Sony Chacko <sony.chacko@qlogic.com>
Subject: [PATCH net-next 2/5] qlcnic: Change debug messages in loopback path
Date: Mon, 29 Aug 2011 15:50:27 -0700
Message-ID: <1314658231-30735-2-git-send-email-sony.chacko@qlogic.com>
References: <1314658231-30735-1-git-send-email-sony.chacko@qlogic.com>
Mime-Version: 1.0
Content-Type: text/plain
Cc: netdev <netdev@vger.kernel.org>,
	Dept_NX_Linux_NIC_Driver <Dept_NX_Linux_NIC_Driver@qlogic.com>,
	Manish chopra <Manish.Chopra@qlogic.com>
To: David Miller <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from ch1ehsobe006.messaging.microsoft.com ([216.32.181.186]:10248
	"EHLO ch1outboundpool.messaging.microsoft.com" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with ESMTP id S1755259Ab1H2XBG (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 29 Aug 2011 19:01:06 -0400
In-Reply-To: <1314658231-30735-1-git-send-email-sony.chacko@qlogic.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Manish chopra <Manish.Chopra@qlogic.com>

Added more debug messages while loopback test in progress

Signed-off-by: Manish chopra <Manish.Chopra@qlogic.com>
Signed-off-by: Sony Chacko <sony.chacko@qlogic.com>
---
 .../net/ethernet/qlogic/qlcnic/qlcnic_ethtool.c    |   15 ++++++++++-----
 drivers/net/ethernet/qlogic/qlcnic/qlcnic_init.c   |    6 +++---
 2 files changed, 13 insertions(+), 8 deletions(-)

diff --git a/drivers/net/ethernet/qlogic/qlcnic/qlcnic_ethtool.c b/drivers/net/ethernet/qlogic/qlcnic/qlcnic_ethtool.c
index 59d73f2..720b333 100644
--- a/drivers/net/ethernet/qlogic/qlcnic/qlcnic_ethtool.c
+++ b/drivers/net/ethernet/qlogic/qlcnic/qlcnic_ethtool.c
@@ -710,7 +710,7 @@ int qlcnic_check_loopback_buff(unsigned char *data, u8 mac[])
 	return memcmp(data, buff, QLCNIC_ILB_PKT_SIZE);
 }
 
-static int qlcnic_do_lb_test(struct qlcnic_adapter *adapter)
+static int qlcnic_do_lb_test(struct qlcnic_adapter *adapter, u8 mode)
 {
 	struct qlcnic_recv_context *recv_ctx = adapter->recv_ctx;
 	struct qlcnic_host_sds_ring *sds_ring = &recv_ctx->sds_rings[0];
@@ -736,13 +736,18 @@ static int qlcnic_do_lb_test(struct qlcnic_adapter *adapter)
 		dev_kfree_skb_any(skb);
 
 		if (!adapter->diag_cnt)
-			dev_warn(&adapter->pdev->dev, "LB Test: %dth packet"
-				" not recevied\n", i + 1);
+			QLCDB(adapter, DRV,
+			"LB Test: packet #%d was not received\n", i + 1);
 		else
 			cnt++;
 	}
 	if (cnt != i) {
 		dev_warn(&adapter->pdev->dev, "LB Test failed\n");
+		if (mode != QLCNIC_ILB_MODE) {
+			dev_warn(&adapter->pdev->dev,
+				"WARNING: Please make sure external"
+				"loopback connector is plugged in\n");
+		}
 		return -1;
 	}
 	return 0;
@@ -761,7 +766,7 @@ static int qlcnic_loopback_test(struct net_device *netdev, u8 mode)
 		return -EOPNOTSUPP;
 	}
 
-	netdev_info(netdev, "%s loopback test in progress\n",
+	QLCDB(adapter, DRV, "%s loopback test in progress\n",
 		   mode == QLCNIC_ILB_MODE ? "internal" : "external");
 	if (adapter->op_mode == QLCNIC_NON_PRIV_FUNC) {
 		netdev_warn(netdev, "Loopback test not supported for non "
@@ -797,7 +802,7 @@ static int qlcnic_loopback_test(struct net_device *netdev, u8 mode)
 		}
 	} while (!QLCNIC_IS_LB_CONFIGURED(adapter->ahw->loopback_state));
 
-	ret = qlcnic_do_lb_test(adapter);
+	ret = qlcnic_do_lb_test(adapter, mode);
 
 	qlcnic_clear_lb_mode(adapter);
 
diff --git a/drivers/net/ethernet/qlogic/qlcnic/qlcnic_init.c b/drivers/net/ethernet/qlogic/qlcnic/qlcnic_init.c
index 3b6741e..b02859c 100644
--- a/drivers/net/ethernet/qlogic/qlcnic/qlcnic_init.c
+++ b/drivers/net/ethernet/qlogic/qlcnic/qlcnic_init.c
@@ -1779,14 +1779,14 @@ qlcnic_post_rx_buffers_nodb(struct qlcnic_adapter *adapter,
 	spin_unlock(&rds_ring->lock);
 }
 
-static void dump_skb(struct sk_buff *skb)
+static void dump_skb(struct sk_buff *skb, struct qlcnic_adapter *adapter)
 {
 	int i;
 	unsigned char *data = skb->data;
 
 	printk(KERN_INFO "\n");
 	for (i = 0; i < skb->len; i++) {
-		printk(KERN_INFO "%02x ", data[i]);
+		QLCDB(adapter, DRV, "%02x ", data[i]);
 		if ((i & 0x0f) == 8)
 			printk(KERN_INFO "\n");
 	}
@@ -1829,7 +1829,7 @@ void qlcnic_process_rcv_diag(struct qlcnic_adapter *adapter,
 	if (!qlcnic_check_loopback_buff(skb->data, adapter->mac_addr))
 		adapter->diag_cnt++;
 	else
-		dump_skb(skb);
+		dump_skb(skb, adapter);
 
 	dev_kfree_skb_any(skb);
 	adapter->stats.rx_pkts++;
-- 
1.6.0.2
