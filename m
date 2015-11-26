From: Marcin Wojtas <mw@semihalf.com>
Subject: [PATCH v2 net 5/6] net: mvneta: enable setting custom TX IP checksum limit
Date: Thu, 26 Nov 2015 19:08:12 +0100
Message-ID: <1448561293-16431-6-git-send-email-mw@semihalf.com>
References: <1448561293-16431-1-git-send-email-mw@semihalf.com>
Cc: davem@davemloft.net, linux@arm.linux.org.uk,
	sebastian.hesselbarth@gmail.com, andrew@lunn.ch,
	jason@lakedaemon.net, thomas.petazzoni@free-electrons.com,
	gregory.clement@free-electrons.com, simon.guinot@sequanux.org,
	nadavh@marvell.com, alior@marvell.com, xswang@marvell.com,
	myair@marvell.com, nitroshift@yahoo.com, mw@semihalf.com,
	jaz@semihalf.com, tn@semihalf.com, <stable@vger.kernel.org>
To: linux-kernel@vger.kernel.org, linux-arm-kernel@lists.infradead.org,
	netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-lf0-f45.google.com ([209.85.215.45]:33102 "EHLO
	mail-lf0-f45.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1753312AbbKZSIa (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 26 Nov 2015 13:08:30 -0500
Received: by lfaz4 with SMTP id z4so105655750lfa.0
        for <netdev@vger.kernel.org>; Thu, 26 Nov 2015 10:08:28 -0800 (PST)
In-Reply-To: <1448561293-16431-1-git-send-email-mw@semihalf.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Since Armada 38x SoC can support IP checksum for jumbo frames only on
a single port, it means that this feature should be enabled per-port,
rather than for the whole SoC.

This patch enables setting custom TX IP checksum limit by adding new
optional property to the mvneta device tree node. If not used, by
default 1600B is set for "marvell,armada-370-neta" and 9800B for other
strings, which ensures backward compatibility. Binding documentation
is updated accordingly.

Signed-off-by: Marcin Wojtas <mw@semihalf.com>
Cc: <stable@vger.kernel.org> # v3.18+
---
 .../bindings/net/marvell-armada-370-neta.txt          |  6 ++++++
 drivers/net/ethernet/marvell/mvneta.c                 | 19 +++++++++++++++++--
 2 files changed, 23 insertions(+), 2 deletions(-)

diff --git a/Documentation/devicetree/bindings/net/marvell-armada-370-neta.txt b/Documentation/devicetree/bindings/net/marvell-armada-370-neta.txt
index f5a8ca2..aeea50c 100644
--- a/Documentation/devicetree/bindings/net/marvell-armada-370-neta.txt
+++ b/Documentation/devicetree/bindings/net/marvell-armada-370-neta.txt
@@ -8,6 +8,11 @@ Required properties:
 - phy-mode: See ethernet.txt file in the same directory
 - clocks: a pointer to the reference clock for this device.
 
+Optional properties:
+- tx-csum-limit: maximum mtu supported by port that allow TX checksum.
+  Value is presented in bytes. If not used, by default 1600B is set for
+  "marvell,armada-370-neta" and 9800B for others.
+
 Example:
 
 ethernet@d0070000 {
@@ -15,6 +20,7 @@ ethernet@d0070000 {
 	reg = <0xd0070000 0x2500>;
 	interrupts = <8>;
 	clocks = <&gate_clk 4>;
+	tx-csum-limit = <9800>
 	status = "okay";
 	phy = <&phy0>;
 	phy-mode = "rgmii-id";
diff --git a/drivers/net/ethernet/marvell/mvneta.c b/drivers/net/ethernet/marvell/mvneta.c
index 62cf971..32d6f28 100644
--- a/drivers/net/ethernet/marvell/mvneta.c
+++ b/drivers/net/ethernet/marvell/mvneta.c
@@ -243,6 +243,7 @@
 #define MVNETA_VLAN_TAG_LEN             4
 
 #define MVNETA_CPU_D_CACHE_LINE_SIZE    32
+#define MVNETA_TX_CSUM_DEF_SIZE		1600
 #define MVNETA_TX_CSUM_MAX_SIZE		9800
 #define MVNETA_ACC_MODE_EXT		1
 
@@ -3257,6 +3258,7 @@ static int mvneta_probe(struct platform_device *pdev)
 	char hw_mac_addr[ETH_ALEN];
 	const char *mac_from;
 	const char *managed;
+	int tx_csum_limit;
 	int phy_mode;
 	int err;
 	int cpu;
@@ -3357,8 +3359,21 @@ static int mvneta_probe(struct platform_device *pdev)
 		}
 	}
 
-	if (of_device_is_compatible(dn, "marvell,armada-370-neta"))
-		pp->tx_csum_limit = 1600;
+	if (!of_property_read_u32(dn, "tx-csum-limit", &tx_csum_limit)) {
+		if (tx_csum_limit < 0 ||
+		    tx_csum_limit > MVNETA_TX_CSUM_MAX_SIZE) {
+			tx_csum_limit = MVNETA_TX_CSUM_DEF_SIZE;
+			dev_info(&pdev->dev,
+				 "Wrong TX csum limit in DT, set to %dB\n",
+				 MVNETA_TX_CSUM_DEF_SIZE);
+		}
+	} else if (of_device_is_compatible(dn, "marvell,armada-370-neta")) {
+		tx_csum_limit = MVNETA_TX_CSUM_DEF_SIZE;
+	} else {
+		tx_csum_limit = MVNETA_TX_CSUM_MAX_SIZE;
+	}
+
+	pp->tx_csum_limit = tx_csum_limit;
 
 	pp->tx_ring_size = MVNETA_MAX_TXD;
 	pp->rx_ring_size = MVNETA_MAX_RXD;
-- 
1.8.3.1
