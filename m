From: Michal Kalderon <Michal.Kalderon@cavium.com>
Subject: [PATCH v2 net-next 03/12] qed: Add ll2 option for dropping a tx packet
Date: Tue, 3 Oct 2017 11:54:53 +0300
Message-ID: <1507020902-4952-4-git-send-email-Michal.Kalderon@cavium.com>
References: <1507020902-4952-1-git-send-email-Michal.Kalderon@cavium.com>
Mime-Version: 1.0
Content-Type: text/plain
Cc: <netdev@vger.kernel.org>, <linux-rdma@vger.kernel.org>,
        <dledford@redhat.com>,
        Michal Kalderon <Michal.Kalderon@cavium.com>,
        "Ariel Elior" <Ariel.Elior@cavium.com>
To: <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-bl2nam02on0078.outbound.protection.outlook.com ([104.47.38.78]:40290
        "EHLO NAM02-BL2-obe.outbound.protection.outlook.com"
        rhost-flags-OK-OK-OK-FAIL) by vger.kernel.org with ESMTP
        id S1751250AbdJCIzp (ORCPT <rfc822;netdev@vger.kernel.org>);
        Tue, 3 Oct 2017 04:55:45 -0400
In-Reply-To: <1507020902-4952-1-git-send-email-Michal.Kalderon@cavium.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

The option of sending a packet on the ll2 and dropping it exists in
hardware and was not used until now, thus not exposed.
The iWARP unaligned MPA flow requires this functionality for
flushing the tx queue.

Signed-off-by: Michal Kalderon <Michal.Kalderon@cavium.com>
Signed-off-by: Ariel Elior <Ariel.Elior@cavium.com>
---
 drivers/net/ethernet/qlogic/qed/qed_ll2.c | 16 ++++++++++++++--
 include/linux/qed/qed_ll2_if.h            |  1 +
 2 files changed, 15 insertions(+), 2 deletions(-)

diff --git a/drivers/net/ethernet/qlogic/qed/qed_ll2.c b/drivers/net/ethernet/qlogic/qed/qed_ll2.c
index 3c695da..ad67d36 100644
--- a/drivers/net/ethernet/qlogic/qed/qed_ll2.c
+++ b/drivers/net/ethernet/qlogic/qed/qed_ll2.c
@@ -1597,8 +1597,20 @@ static void qed_ll2_prepare_tx_packet_set(struct qed_hwfn *p_hwfn,
 	roce_flavor = (pkt->qed_roce_flavor == QED_LL2_ROCE) ? CORE_ROCE
 							     : CORE_RROCE;
 
-	tx_dest = (pkt->tx_dest == QED_LL2_TX_DEST_NW) ? CORE_TX_DEST_NW
-						       : CORE_TX_DEST_LB;
+	switch (pkt->tx_dest) {
+	case QED_LL2_TX_DEST_NW:
+		tx_dest = CORE_TX_DEST_NW;
+		break;
+	case QED_LL2_TX_DEST_LB:
+		tx_dest = CORE_TX_DEST_LB;
+		break;
+	case QED_LL2_TX_DEST_DROP:
+		tx_dest = CORE_TX_DEST_DROP;
+		break;
+	default:
+		tx_dest = CORE_TX_DEST_LB;
+		break;
+	}
 
 	start_bd = (struct core_tx_bd *)qed_chain_produce(p_tx_chain);
 	start_bd->nw_vlan_or_lb_echo = cpu_to_le16(pkt->vlan);
diff --git a/include/linux/qed/qed_ll2_if.h b/include/linux/qed/qed_ll2_if.h
index d7cca59..95fdf02 100644
--- a/include/linux/qed/qed_ll2_if.h
+++ b/include/linux/qed/qed_ll2_if.h
@@ -64,6 +64,7 @@ enum qed_ll2_roce_flavor_type {
 enum qed_ll2_tx_dest {
 	QED_LL2_TX_DEST_NW, /* Light L2 TX Destination to the Network */
 	QED_LL2_TX_DEST_LB, /* Light L2 TX Destination to the Loopback */
+	QED_LL2_TX_DEST_DROP, /* Light L2 Drop the TX packet */
 	QED_LL2_TX_DEST_MAX
 };
 
-- 
1.8.3.1
