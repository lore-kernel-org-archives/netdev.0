From: Shahed Shaikh <shahed.shaikh@qlogic.com>
Subject: [PATCH net-next 7/9] qlcnic: fix TSO race condition
Date: Sat, 13 Apr 2013 13:28:32 -0400
Message-ID: <1365874114-6759-8-git-send-email-shahed.shaikh@qlogic.com>
References: <1365874114-6759-1-git-send-email-shahed.shaikh@qlogic.com>
Cc: netdev@vger.kernel.org, Dept_NX_Linux_NIC_Driver@qlogic.com,
	Sritej Velaga <sritej.velaga@qlogic.com>
To: davem@davemloft.net
Return-path: <netdev-owner@vger.kernel.org>
Received: from mvnat01.qlogic.com ([198.186.3.73]:49392 "HELO linux-zupk.site"
	rhost-flags-OK-OK-OK-FAIL) by vger.kernel.org with SMTP
	id S1753088Ab3DMRw5 (ORCPT <rfc822;netdev@vger.kernel.org>);
	Sat, 13 Apr 2013 13:52:57 -0400
In-Reply-To: <1365874114-6759-1-git-send-email-shahed.shaikh@qlogic.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Sritej Velaga <sritej.velaga@qlogic.com>

When driver receives a packet with gso size > 0 and when TSO is disabled,
it should be transmitted as a TSO packet to prevent Tx timeout and subsequent
firmware reset.

Signed-off-by: Sritej Velaga <sritej.velaga@qlogic.com>
Signed-off-by: Shahed Shaikh <shahed.shaikh@qlogic.com>
---
 drivers/net/ethernet/qlogic/qlcnic/qlcnic.h        |    1 +
 .../net/ethernet/qlogic/qlcnic/qlcnic_ethtool.c    |    2 ++
 drivers/net/ethernet/qlogic/qlcnic/qlcnic_io.c     |    8 ++++++--
 3 files changed, 9 insertions(+), 2 deletions(-)

diff --git a/drivers/net/ethernet/qlogic/qlcnic/qlcnic.h b/drivers/net/ethernet/qlogic/qlcnic/qlcnic.h
index 7551b18..53c414f 100644
--- a/drivers/net/ethernet/qlogic/qlcnic/qlcnic.h
+++ b/drivers/net/ethernet/qlogic/qlcnic/qlcnic.h
@@ -485,6 +485,7 @@ struct qlcnic_adapter_stats {
 	u64  tx_dma_map_error;
 	u64  spurious_intr;
 	u64  mac_filter_limit_overrun;
+	u64  invalid_tso_pkt;
 };
 
 /*
diff --git a/drivers/net/ethernet/qlogic/qlcnic/qlcnic_ethtool.c b/drivers/net/ethernet/qlogic/qlcnic/qlcnic_ethtool.c
index 7b56a50..48434ee 100644
--- a/drivers/net/ethernet/qlogic/qlcnic/qlcnic_ethtool.c
+++ b/drivers/net/ethernet/qlogic/qlcnic/qlcnic_ethtool.c
@@ -53,6 +53,8 @@ static const struct qlcnic_stats qlcnic_gstrings_stats[] = {
 				QLC_OFF(stats.mac_filter_limit_overrun)},
 	{"spurious intr", QLC_SIZEOF(stats.spurious_intr),
 	 QLC_OFF(stats.spurious_intr)},
+	{"invalid_tso_pkt", QLC_SIZEOF(stats.invalid_tso_pkt),
+			QLC_OFF(stats.invalid_tso_pkt)},
 
 };
 
diff --git a/drivers/net/ethernet/qlogic/qlcnic/qlcnic_io.c b/drivers/net/ethernet/qlogic/qlcnic/qlcnic_io.c
index a85ca63..cb19e30 100644
--- a/drivers/net/ethernet/qlogic/qlcnic/qlcnic_io.c
+++ b/drivers/net/ethernet/qlogic/qlcnic/qlcnic_io.c
@@ -362,8 +362,12 @@ set_flags:
 		memcpy(&first_desc->eth_addr, skb->data, ETH_ALEN);
 	}
 	opcode = TX_ETHER_PKT;
-	if ((adapter->netdev->features & (NETIF_F_TSO | NETIF_F_TSO6)) &&
-	    skb_shinfo(skb)->gso_size > 0) {
+
+	if (skb_shinfo(skb)->gso_size > 0) {
+		if (!(adapter->netdev->features &
+		      (NETIF_F_TSO | NETIF_F_TSO6))) {
+			adapter->stats.invalid_tso_pkt++;
+		}
 		hdr_len = skb_transport_offset(skb) + tcp_hdrlen(skb);
 		first_desc->mss = cpu_to_le16(skb_shinfo(skb)->gso_size);
 		first_desc->total_hdr_length = hdr_len;
-- 
1.5.6
