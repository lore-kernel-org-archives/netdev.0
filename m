From: Michal Kalderon <Michal.Kalderon-YGCgFSpz5w/QT0dZR+AlfA@public.gmane.org>
Subject: [PATCH net-next 03/12] qed: Add ll2 option for dropping a tx packet
Date: Mon, 2 Oct 2017 11:23:49 +0300
Message-ID: <1506932638-26268-4-git-send-email-Michal.Kalderon@cavium.com>
References: <1506932638-26268-1-git-send-email-Michal.Kalderon@cavium.com>
Mime-Version: 1.0
Content-Type: text/plain
Cc: <netdev-u79uwXL29TY76Z2rM5mHXA@public.gmane.org>, <linux-rdma-u79uwXL29TY76Z2rM5mHXA@public.gmane.org>,
        <dledford-H+wXaHxf7aLQT0dZR+AlfA@public.gmane.org>,
        Michal Kalderon <Michal.Kalderon-YGCgFSpz5w/QT0dZR+AlfA@public.gmane.org>,
        "Ariel Elior" <Ariel.Elior-YGCgFSpz5w/QT0dZR+AlfA@public.gmane.org>
To: <davem-fT/PcQaiUtIeIZ0/mPfg9Q@public.gmane.org>
Return-path: <linux-rdma-owner-u79uwXL29TY76Z2rM5mHXA@public.gmane.org>
In-Reply-To: <1506932638-26268-1-git-send-email-Michal.Kalderon-YGCgFSpz5w/QT0dZR+AlfA@public.gmane.org>
Sender: linux-rdma-owner-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
List-Id: netdev.vger.kernel.org

The option of sending a packet on the ll2 and dropping it exists in
hardware and was not used until now, thus not exposed.
The iWARP unaligned MPA flow requires this functionality for
flushing the tx queue.

Signed-off-by: Michal Kalderon <Michal.Kalderon-YGCgFSpz5w/QT0dZR+AlfA@public.gmane.org>
Signed-off-by: Ariel Elior <Ariel.Elior-YGCgFSpz5w/QT0dZR+AlfA@public.gmane.org>
---
 drivers/net/ethernet/qlogic/qed/qed_ll2.c | 16 ++++++++++++++--
 include/linux/qed/qed_ll2_if.h            |  1 +
 2 files changed, 15 insertions(+), 2 deletions(-)

diff --git a/drivers/net/ethernet/qlogic/qed/qed_ll2.c b/drivers/net/ethernet/qlogic/qed/qed_ll2.c
index 1dd0cca..49fcfda 100644
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
index 25153ff..aa7cb3b 100644
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

--
To unsubscribe from this list: send the line "unsubscribe linux-rdma" in
the body of a message to majordomo-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
More majordomo info at  http://vger.kernel.org/majordomo-info.html
