From: Yuval Mintz <Yuval.Mintz-YGCgFSpz5w/QT0dZR+AlfA@public.gmane.org>
Subject: [PATCH net-next 8/8] qed: collect GSI port statistics
Date: Thu, 8 Jun 2017 19:13:23 +0300
Message-ID: <20170608161323.7597-9-Yuval.Mintz@cavium.com>
References: <20170608161323.7597-1-Yuval.Mintz@cavium.com>
Mime-Version: 1.0
Content-Type: text/plain
Cc: <linux-rdma-u79uwXL29TY76Z2rM5mHXA@public.gmane.org>, <Michal.Kalderon-YGCgFSpz5w/QT0dZR+AlfA@public.gmane.org>,
        Yuval Mintz <Yuval.Mintz-YGCgFSpz5w/QT0dZR+AlfA@public.gmane.org>
To: <netdev-u79uwXL29TY76Z2rM5mHXA@public.gmane.org>, <davem-fT/PcQaiUtIeIZ0/mPfg9Q@public.gmane.org>
Return-path: <linux-rdma-owner-u79uwXL29TY76Z2rM5mHXA@public.gmane.org>
In-Reply-To: <20170608161323.7597-1-Yuval.Mintz-YGCgFSpz5w/QT0dZR+AlfA@public.gmane.org>
Sender: linux-rdma-owner-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
List-Id: netdev.vger.kernel.org

The LL2 statistics already have place holders for these, but haven't
populated them so far.

Signed-off-by: Yuval Mintz <Yuval.Mintz-YGCgFSpz5w/QT0dZR+AlfA@public.gmane.org>
---
 drivers/net/ethernet/qlogic/qed/qed_ll2.c | 23 +++++++++++++++++++++++
 1 file changed, 23 insertions(+)

diff --git a/drivers/net/ethernet/qlogic/qed/qed_ll2.c b/drivers/net/ethernet/qlogic/qed/qed_ll2.c
index c6172a77e..0e26193 100644
--- a/drivers/net/ethernet/qlogic/qed/qed_ll2.c
+++ b/drivers/net/ethernet/qlogic/qed/qed_ll2.c
@@ -1902,6 +1902,27 @@ void qed_ll2_free(struct qed_hwfn *p_hwfn)
 	p_hwfn->p_ll2_info = NULL;
 }
 
+static void _qed_ll2_get_port_stats(struct qed_hwfn *p_hwfn,
+				    struct qed_ptt *p_ptt,
+				    struct qed_ll2_stats *p_stats)
+{
+	struct core_ll2_port_stats port_stats;
+
+	memset(&port_stats, 0, sizeof(port_stats));
+	qed_memcpy_from(p_hwfn, p_ptt, &port_stats,
+			BAR0_MAP_REG_TSDM_RAM +
+			TSTORM_LL2_PORT_STAT_OFFSET(MFW_PORT(p_hwfn)),
+			sizeof(port_stats));
+
+	p_stats->gsi_invalid_hdr = HILO_64_REGPAIR(port_stats.gsi_invalid_hdr);
+	p_stats->gsi_invalid_pkt_length =
+	    HILO_64_REGPAIR(port_stats.gsi_invalid_pkt_length);
+	p_stats->gsi_unsupported_pkt_typ =
+	    HILO_64_REGPAIR(port_stats.gsi_unsupported_pkt_typ);
+	p_stats->gsi_crcchksm_error =
+	    HILO_64_REGPAIR(port_stats.gsi_crcchksm_error);
+}
+
 static void _qed_ll2_get_tstats(struct qed_hwfn *p_hwfn,
 				struct qed_ptt *p_ptt,
 				struct qed_ll2_info *p_ll2_conn,
@@ -1986,6 +2007,8 @@ int qed_ll2_get_stats(void *cxt,
 		return -EINVAL;
 	}
 
+	if (p_ll2_conn->input.gsi_enable)
+		_qed_ll2_get_port_stats(p_hwfn, p_ptt, p_stats);
 	_qed_ll2_get_tstats(p_hwfn, p_ptt, p_ll2_conn, p_stats);
 	_qed_ll2_get_ustats(p_hwfn, p_ptt, p_ll2_conn, p_stats);
 	if (p_ll2_conn->tx_stats_en)
-- 
2.9.4

--
To unsubscribe from this list: send the line "unsubscribe linux-rdma" in
the body of a message to majordomo-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
More majordomo info at  http://vger.kernel.org/majordomo-info.html
