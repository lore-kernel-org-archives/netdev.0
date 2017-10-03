From: Michal Kalderon <Michal.Kalderon@cavium.com>
Subject: [PATCH v2 net-next 05/12] qed: Add the source of a packet sent on an iWARP ll2 connection
Date: Tue, 3 Oct 2017 11:54:55 +0300
Message-ID: <1507020902-4952-6-git-send-email-Michal.Kalderon@cavium.com>
References: <1507020902-4952-1-git-send-email-Michal.Kalderon@cavium.com>
Mime-Version: 1.0
Content-Type: text/plain
Cc: <netdev@vger.kernel.org>, <linux-rdma@vger.kernel.org>,
        <dledford@redhat.com>,
        Michal Kalderon <Michal.Kalderon@cavium.com>,
        "Ariel Elior" <Ariel.Elior@cavium.com>
To: <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-bl2nam02on0083.outbound.protection.outlook.com ([104.47.38.83]:22208
        "EHLO NAM02-BL2-obe.outbound.protection.outlook.com"
        rhost-flags-OK-OK-OK-FAIL) by vger.kernel.org with ESMTP
        id S1751277AbdJCIz4 (ORCPT <rfc822;netdev@vger.kernel.org>);
        Tue, 3 Oct 2017 04:55:56 -0400
In-Reply-To: <1507020902-4952-1-git-send-email-Michal.Kalderon@cavium.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

When a packet is sent back to iWARP FW via the tx ll2 connection
the FW needs to know the source of the packet. Whether it is
OOO or unaligned MPA related. Since OOO is implemented entirely
inside the ll2 code (and shared with iSCSI), packets are marked
as IN_ORDER inside the ll2 code. For unaligned mpa the value
will be determined in the iWARP code and sent on the pkt->vlan
field.

Signed-off-by: Michal Kalderon <Michal.Kalderon@cavium.com>
Signed-off-by: Ariel Elior <Ariel.Elior@cavium.com>
---
 drivers/net/ethernet/qlogic/qed/qed_ll2.c | 7 ++++++-
 1 file changed, 6 insertions(+), 1 deletion(-)

diff --git a/drivers/net/ethernet/qlogic/qed/qed_ll2.c b/drivers/net/ethernet/qlogic/qed/qed_ll2.c
index 6d14474..8eb9645 100644
--- a/drivers/net/ethernet/qlogic/qed/qed_ll2.c
+++ b/drivers/net/ethernet/qlogic/qed/qed_ll2.c
@@ -1613,7 +1613,12 @@ static void qed_ll2_prepare_tx_packet_set(struct qed_hwfn *p_hwfn,
 	}
 
 	start_bd = (struct core_tx_bd *)qed_chain_produce(p_tx_chain);
-	start_bd->nw_vlan_or_lb_echo = cpu_to_le16(pkt->vlan);
+	if (QED_IS_IWARP_PERSONALITY(p_hwfn) &&
+	    p_ll2->input.conn_type == QED_LL2_TYPE_OOO)
+		start_bd->nw_vlan_or_lb_echo =
+		    cpu_to_le16(IWARP_LL2_IN_ORDER_TX_QUEUE);
+	else
+		start_bd->nw_vlan_or_lb_echo = cpu_to_le16(pkt->vlan);
 	SET_FIELD(start_bd->bitfield1, CORE_TX_BD_L4_HDR_OFFSET_W,
 		  cpu_to_le16(pkt->l4_hdr_offset_w));
 	SET_FIELD(start_bd->bitfield1, CORE_TX_BD_TX_DST, tx_dest);
-- 
1.8.3.1
