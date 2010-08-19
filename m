From: Amit Kumar Salecha <amit.salecha@qlogic.com>
Subject: [PATCH NEXT 06/12] qlcnic: support anti mac spoofing
Date: Thu, 19 Aug 2010 08:08:27 -0700
Message-ID: <1282230513-25286-7-git-send-email-amit.salecha@qlogic.com>
References: <1282230513-25286-1-git-send-email-amit.salecha@qlogic.com>
Cc: netdev@vger.kernel.org, ameen.rahman@qlogic.com,
	anirban.chakraborty@qlogic.com,
	Sony Chacko <sony.chacko@qlogic.com>
To: davem@davemloft.net
Return-path: <netdev-owner@vger.kernel.org>
Received: from mvnat01.qlogic.com ([198.186.3.73]:22261 "HELO unm84.unmin.com"
	rhost-flags-OK-OK-OK-FAIL) by vger.kernel.org with SMTP
	id S1753804Ab0HSPIe (ORCPT <rfc822;netdev@vger.kernel.org>);
	Thu, 19 Aug 2010 11:08:34 -0400
In-Reply-To: <1282230513-25286-1-git-send-email-amit.salecha@qlogic.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Sony Chacko <sony.chacko@qlogic.com>

Administrator can configure to drop packet in transmit,
if it doesn't match interface mac address, in case of virtual function.

Signed-off-by: Sony Chacko <sony.chacko@qlogic.com>
Signed-off-by: Amit Kumar Salecha <amit.salecha@qlogic.com>
---
 drivers/net/qlcnic/qlcnic.h      |    1 +
 drivers/net/qlcnic/qlcnic_main.c |   11 +++++++++++
 2 files changed, 12 insertions(+), 0 deletions(-)

diff --git a/drivers/net/qlcnic/qlcnic.h b/drivers/net/qlcnic/qlcnic.h
index 9433a05..b58c411 100644
--- a/drivers/net/qlcnic/qlcnic.h
+++ b/drivers/net/qlcnic/qlcnic.h
@@ -900,6 +900,7 @@ struct qlcnic_mac_req {
 #define QLCNIC_BRIDGE_ENABLED       	0X10
 #define QLCNIC_DIAG_ENABLED		0x20
 #define QLCNIC_ESWITCH_ENABLED		0x40
+#define QLCNIC_MACSPOOF			0x200
 #define QLCNIC_IS_MSI_FAMILY(adapter) \
 	((adapter)->flags & (QLCNIC_MSI_ENABLED | QLCNIC_MSIX_ENABLED))
 
diff --git a/drivers/net/qlcnic/qlcnic_main.c b/drivers/net/qlcnic/qlcnic_main.c
index aa1f6b3..de4be00 100644
--- a/drivers/net/qlcnic/qlcnic_main.c
+++ b/drivers/net/qlcnic/qlcnic_main.c
@@ -762,6 +762,11 @@ static void
 qlcnic_set_eswitch_port_features(struct qlcnic_adapter *adapter,
 		struct qlcnic_esw_func_cfg *esw_cfg)
 {
+	adapter->flags &= ~QLCNIC_MACSPOOF;
+	if (adapter->op_mode == QLCNIC_NON_PRIV_FUNC)
+		if (esw_cfg->mac_anti_spoof)
+			adapter->flags |= QLCNIC_MACSPOOF;
+
 	qlcnic_set_netdev_features(adapter, esw_cfg);
 }
 
@@ -1912,6 +1917,12 @@ qlcnic_xmit_frame(struct sk_buff *skb, struct net_device *netdev)
 		return NETDEV_TX_BUSY;
 	}
 
+	if (adapter->flags & QLCNIC_MACSPOOF) {
+		if (compare_ether_addr(eth_hdr(skb)->h_source,
+					adapter->mac_addr))
+			goto drop_packet;
+	}
+
 	frag_count = skb_shinfo(skb)->nr_frags + 1;
 
 	/* 4 fragments per cmd des */
-- 
1.6.0.2

