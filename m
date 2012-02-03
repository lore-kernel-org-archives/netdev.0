From: Rajesh Borundia <rajesh.borundia@qlogic.com>
Subject: [PATCH NEXT 4/6] netxen_nic: Error logging on firmware hang
Date: Fri, 3 Feb 2012 13:35:13 -0800
Message-ID: <1328304915-12858-5-git-send-email-rajesh.borundia@qlogic.com>
References: <1328304915-12858-1-git-send-email-rajesh.borundia@qlogic.com>
Mime-Version: 1.0
Content-Type: text/plain
Cc: netdev <netdev@vger.kernel.org>,
	Ameen Rahman <ameen.rahman@qlogic.com>,
	Sony Chacko <sony.chacko@qlogic.com>,
	Sritej Velaga <sritej.velaga@qlogic.com>
To: David Miller <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from ch1ehsobe001.messaging.microsoft.com ([216.32.181.181]:3168
	"EHLO ch1outboundpool.messaging.microsoft.com" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with ESMTP id S1757952Ab2BCVvK (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 3 Feb 2012 16:51:10 -0500
In-Reply-To: <1328304915-12858-1-git-send-email-rajesh.borundia@qlogic.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Sritej Velaga <sritej.velaga@qlogic.com>

Log states of essential registers on firmware hang detection.

Signed-off-by: Sritej Velaga <sritej.velaga@qlogic.com>
---
 .../net/ethernet/qlogic/netxen/netxen_nic_hdr.h    |    1 +
 .../net/ethernet/qlogic/netxen/netxen_nic_main.c   |   21 ++++++++++++++++++-
 2 files changed, 20 insertions(+), 2 deletions(-)

diff --git a/drivers/net/ethernet/qlogic/netxen/netxen_nic_hdr.h b/drivers/net/ethernet/qlogic/netxen/netxen_nic_hdr.h
index dc1967c..b1a897c 100644
--- a/drivers/net/ethernet/qlogic/netxen/netxen_nic_hdr.h
+++ b/drivers/net/ethernet/qlogic/netxen/netxen_nic_hdr.h
@@ -969,6 +969,7 @@ enum {
 #define NX_RCODE_FATAL_ERROR		0x80000000
 #define NX_FWERROR_PEGNUM(code)		((code) & 0xff)
 #define NX_FWERROR_CODE(code)		((code >> 8) & 0xfffff)
+#define NX_FWERROR_PEGSTAT1(code)	((code >> 8) & 0x1fffff)
 
 #define FW_POLL_DELAY			(2 * HZ)
 #define FW_FAIL_THRESH			3
diff --git a/drivers/net/ethernet/qlogic/netxen/netxen_nic_main.c b/drivers/net/ethernet/qlogic/netxen/netxen_nic_main.c
index f67655f..f517c16 100644
--- a/drivers/net/ethernet/qlogic/netxen/netxen_nic_main.c
+++ b/drivers/net/ethernet/qlogic/netxen/netxen_nic_main.c
@@ -2596,6 +2596,7 @@ static int
 netxen_check_health(struct netxen_adapter *adapter)
 {
 	u32 state, heartbit;
+	u32 peg_status;
 	struct net_device *netdev = adapter->netdev;
 
 	state = NXRD32(adapter, NX_CRB_DEV_STATE);
@@ -2642,8 +2643,24 @@ netxen_check_health(struct netxen_adapter *adapter)
 
 	clear_bit(__NX_FW_ATTACHED, &adapter->state);
 
-	dev_info(&netdev->dev, "firmware hang detected\n");
-
+	dev_err(&netdev->dev, "firmware hang detected\n");
+	peg_status = NXRD32(adapter, NETXEN_PEG_HALT_STATUS1);
+	dev_err(&adapter->pdev->dev, "Dumping hw/fw registers\n"
+			"PEG_HALT_STATUS1: 0x%x, PEG_HALT_STATUS2: 0x%x,\n"
+			"PEG_NET_0_PC: 0x%x, PEG_NET_1_PC: 0x%x,\n"
+			"PEG_NET_2_PC: 0x%x, PEG_NET_3_PC: 0x%x,\n"
+			"PEG_NET_4_PC: 0x%x\n",
+			peg_status,
+			NXRD32(adapter, NETXEN_PEG_HALT_STATUS2),
+			NXRD32(adapter, NETXEN_CRB_PEG_NET_0 + 0x3c),
+			NXRD32(adapter, NETXEN_CRB_PEG_NET_1 + 0x3c),
+			NXRD32(adapter, NETXEN_CRB_PEG_NET_2 + 0x3c),
+			NXRD32(adapter, NETXEN_CRB_PEG_NET_3 + 0x3c),
+			NXRD32(adapter, NETXEN_CRB_PEG_NET_4 + 0x3c));
+	if (NX_FWERROR_PEGSTAT1(peg_status) == 0x67)
+		dev_err(&adapter->pdev->dev,
+			"Firmware aborted with error code 0x00006700. "
+				"Device is being reset.\n");
 detach:
 	if ((auto_fw_reset == AUTO_FW_RESET_ENABLED) &&
 			!test_and_set_bit(__NX_RESETTING, &adapter->state))
-- 
1.7.3.3
