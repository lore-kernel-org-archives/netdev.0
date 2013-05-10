From: Rasesh Mody <rmody@brocade.com>
Subject: [net-next 2/4] bna: Fix Ucast Failure Handling
Date: Fri, 10 May 2013 10:02:15 -0700
Message-ID: <1368205337-4624-3-git-send-email-rmody@brocade.com>
References: <1368205337-4624-1-git-send-email-rmody@brocade.com>
Mime-Version: 1.0
Content-Type: text/plain
Cc: <adapter_linux_open_src_team@brocade.com>,
	Rasesh Mody <rmody@brocade.com>
To: <davem@davemloft.net>, <netdev@vger.kernel.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mx0a-000f0801.pphosted.com ([67.231.144.122]:58516 "EHLO
	mx0a-000f0801.pphosted.com" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with ESMTP id S1754883Ab3EJRUv (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 10 May 2013 13:20:51 -0400
In-Reply-To: <1368205337-4624-1-git-send-email-rmody@brocade.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

        Failure of the UCAST set for base mac address fails when user
        configures a duplicate mac address that matches that of another vNIC
        on the same port.
        The bna does not handle the ucast failure and keeps this address in
        cache. On disable of the vNIC, bna tries to delete the failed base mac
        address and the fw asserts.

        On failure of ucast address, mark ucast address set to false.

Signed-off-by: Rasesh Mody <rmody@brocade.com>
---
 drivers/net/ethernet/brocade/bna/bna.h       |    2 ++
 drivers/net/ethernet/brocade/bna/bna_enet.c  |    7 ++++++-
 drivers/net/ethernet/brocade/bna/bna_tx_rx.c |   15 +++++++++++++++
 3 files changed, 23 insertions(+), 1 deletions(-)

diff --git a/drivers/net/ethernet/brocade/bna/bna.h b/drivers/net/ethernet/brocade/bna/bna.h
index 25dae75..f1eafc4 100644
--- a/drivers/net/ethernet/brocade/bna/bna.h
+++ b/drivers/net/ethernet/brocade/bna/bna.h
@@ -455,6 +455,8 @@ void bna_bfi_rx_enet_stop_rsp(struct bna_rx *rx,
 void bna_bfi_rxf_cfg_rsp(struct bna_rxf *rxf, struct bfi_msgq_mhdr *msghdr);
 void bna_bfi_rxf_mcast_add_rsp(struct bna_rxf *rxf,
 			       struct bfi_msgq_mhdr *msghdr);
+void bna_bfi_rxf_ucast_set_rsp(struct bna_rxf *rxf,
+			       struct bfi_msgq_mhdr *msghdr);
 
 /* APIs for BNA */
 void bna_rx_mod_init(struct bna_rx_mod *rx_mod, struct bna *bna,
diff --git a/drivers/net/ethernet/brocade/bna/bna_enet.c b/drivers/net/ethernet/brocade/bna/bna_enet.c
index db14f69..3ca77fa 100644
--- a/drivers/net/ethernet/brocade/bna/bna_enet.c
+++ b/drivers/net/ethernet/brocade/bna/bna_enet.c
@@ -298,7 +298,6 @@ bna_msgq_rsp_handler(void *arg, struct bfi_msgq_mhdr *msghdr)
 	case BFI_ENET_I2H_RSS_ENABLE_RSP:
 	case BFI_ENET_I2H_RX_PROMISCUOUS_RSP:
 	case BFI_ENET_I2H_RX_DEFAULT_RSP:
-	case BFI_ENET_I2H_MAC_UCAST_SET_RSP:
 	case BFI_ENET_I2H_MAC_UCAST_CLR_RSP:
 	case BFI_ENET_I2H_MAC_UCAST_ADD_RSP:
 	case BFI_ENET_I2H_MAC_UCAST_DEL_RSP:
@@ -311,6 +310,12 @@ bna_msgq_rsp_handler(void *arg, struct bfi_msgq_mhdr *msghdr)
 			bna_bfi_rxf_cfg_rsp(&rx->rxf, msghdr);
 		break;
 
+	case BFI_ENET_I2H_MAC_UCAST_SET_RSP:
+		bna_rx_from_rid(bna, msghdr->enet_id, rx);
+		if (rx)
+			bna_bfi_rxf_ucast_set_rsp(&rx->rxf, msghdr);
+		break;
+
 	case BFI_ENET_I2H_MAC_MCAST_ADD_RSP:
 		bna_rx_from_rid(bna, msghdr->enet_id, rx);
 		if (rx)
diff --git a/drivers/net/ethernet/brocade/bna/bna_tx_rx.c b/drivers/net/ethernet/brocade/bna/bna_tx_rx.c
index ea6f4a0..57cd1bf 100644
--- a/drivers/net/ethernet/brocade/bna/bna_tx_rx.c
+++ b/drivers/net/ethernet/brocade/bna/bna_tx_rx.c
@@ -711,6 +711,21 @@ bna_bfi_rxf_cfg_rsp(struct bna_rxf *rxf, struct bfi_msgq_mhdr *msghdr)
 }
 
 void
+bna_bfi_rxf_ucast_set_rsp(struct bna_rxf *rxf,
+			struct bfi_msgq_mhdr *msghdr)
+{
+	struct bfi_enet_rsp *rsp =
+		(struct bfi_enet_rsp *)msghdr;
+
+	if (rsp->error) {
+		/* Clear ucast from cache */
+		rxf->ucast_active_set = 0;
+	}
+
+	bfa_fsm_send_event(rxf, RXF_E_FW_RESP);
+}
+
+void
 bna_bfi_rxf_mcast_add_rsp(struct bna_rxf *rxf,
 			struct bfi_msgq_mhdr *msghdr)
 {
-- 
1.7.1
