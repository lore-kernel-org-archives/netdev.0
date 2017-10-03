From: Michal Kalderon <Michal.Kalderon@cavium.com>
Subject: [PATCH v2 net-next 11/12] qed: Add support for MPA header being split over two tcp packets
Date: Tue, 3 Oct 2017 11:55:01 +0300
Message-ID: <1507020902-4952-12-git-send-email-Michal.Kalderon@cavium.com>
References: <1507020902-4952-1-git-send-email-Michal.Kalderon@cavium.com>
Mime-Version: 1.0
Content-Type: text/plain
Cc: <netdev@vger.kernel.org>, <linux-rdma@vger.kernel.org>,
        <dledford@redhat.com>,
        Michal Kalderon <Michal.Kalderon@cavium.com>,
        "Ariel Elior" <Ariel.Elior@cavium.com>
To: <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-by2nam01on0069.outbound.protection.outlook.com ([104.47.34.69]:25601
        "EHLO NAM01-BY2-obe.outbound.protection.outlook.com"
        rhost-flags-OK-OK-OK-FAIL) by vger.kernel.org with ESMTP
        id S1751201AbdJCI42 (ORCPT <rfc822;netdev@vger.kernel.org>);
        Tue, 3 Oct 2017 04:56:28 -0400
In-Reply-To: <1507020902-4952-1-git-send-email-Michal.Kalderon@cavium.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

There is a special case where an MPA header is split over to tcp
packets, in this case we need to wait for the next packet to
get the fpdu length. We use the incomplete_bytes to mark this
fpdu as a "special" one which requires updating the length with
the next packet

Signed-off-by: Michal Kalderon <Michal.Kalderon@cavium.com>
Signed-off-by: Ariel Elior <Ariel.Elior@cavium.com>
---
 drivers/net/ethernet/qlogic/qed/qed_iwarp.c | 36 ++++++++++++++++++++++++++++-
 drivers/net/ethernet/qlogic/qed/qed_iwarp.h |  6 +++++
 2 files changed, 41 insertions(+), 1 deletion(-)

diff --git a/drivers/net/ethernet/qlogic/qed/qed_iwarp.c b/drivers/net/ethernet/qlogic/qed/qed_iwarp.c
index 8b17369..2994942 100644
--- a/drivers/net/ethernet/qlogic/qed/qed_iwarp.c
+++ b/drivers/net/ethernet/qlogic/qed/qed_iwarp.c
@@ -1742,6 +1742,7 @@ enum qed_iwarp_mpa_pkt_type {
 	QED_IWARP_MPA_PKT_UNALIGNED
 };
 
+#define QED_IWARP_INVALID_FPDU_LENGTH 0xffff
 #define QED_IWARP_MPA_FPDU_LENGTH_SIZE (2)
 #define QED_IWARP_MPA_CRC32_DIGEST_SIZE (4)
 
@@ -1774,6 +1775,15 @@ enum qed_iwarp_mpa_pkt_type {
 		goto out;
 	}
 
+	/* special case of one byte remaining...
+	 * lower byte will be read next packet
+	 */
+	if (tcp_payload_len == 1) {
+		fpdu->fpdu_length = *mpa_data << BITS_PER_BYTE;
+		pkt_type = QED_IWARP_MPA_PKT_PARTIAL;
+		goto out;
+	}
+
 	mpa_len = ntohs(*((u16 *)(mpa_data)));
 	fpdu->fpdu_length = QED_IWARP_FPDU_LEN_WITH_PAD(mpa_len);
 
@@ -1802,7 +1812,9 @@ enum qed_iwarp_mpa_pkt_type {
 	fpdu->mpa_frag = buf->data_phys_addr + pkt_data->first_mpa_offset;
 	fpdu->mpa_frag_virt = (u8 *)(buf->data) + pkt_data->first_mpa_offset;
 
-	if (tcp_payload_size < fpdu->fpdu_length)
+	if (tcp_payload_size == 1)
+		fpdu->incomplete_bytes = QED_IWARP_INVALID_FPDU_LENGTH;
+	else if (tcp_payload_size < fpdu->fpdu_length)
 		fpdu->incomplete_bytes = fpdu->fpdu_length - tcp_payload_size;
 	else
 		fpdu->incomplete_bytes = 0;	/* complete fpdu */
@@ -1810,6 +1822,27 @@ enum qed_iwarp_mpa_pkt_type {
 	fpdu->mpa_frag_len = fpdu->fpdu_length - fpdu->incomplete_bytes;
 }
 
+static void
+qed_iwarp_update_fpdu_length(struct qed_hwfn *p_hwfn,
+			     struct qed_iwarp_fpdu *fpdu, u8 *mpa_data)
+{
+	u16 mpa_len;
+
+	/* Update incomplete packets if needed */
+	if (fpdu->incomplete_bytes == QED_IWARP_INVALID_FPDU_LENGTH) {
+		/* Missing lower byte is now available */
+		mpa_len = fpdu->fpdu_length | *mpa_data;
+		fpdu->fpdu_length = QED_IWARP_FPDU_LEN_WITH_PAD(mpa_len);
+		fpdu->mpa_frag_len = fpdu->fpdu_length;
+		/* one byte of hdr */
+		fpdu->incomplete_bytes = fpdu->fpdu_length - 1;
+		DP_VERBOSE(p_hwfn,
+			   QED_MSG_RDMA,
+			   "MPA_ALIGN: Partial header mpa_len=%x fpdu_length=%x incomplete_bytes=%x\n",
+			   mpa_len, fpdu->fpdu_length, fpdu->incomplete_bytes);
+	}
+}
+
 static int
 qed_iwarp_send_fpdu(struct qed_hwfn *p_hwfn,
 		    struct qed_iwarp_fpdu *fpdu,
@@ -1960,6 +1993,7 @@ enum qed_iwarp_mpa_pkt_type {
 			curr_pkt->first_mpa_offset += fpdu->fpdu_length;
 			break;
 		case QED_IWARP_MPA_PKT_UNALIGNED:
+			qed_iwarp_update_fpdu_length(p_hwfn, fpdu, mpa_data);
 			rc = qed_iwarp_send_fpdu(p_hwfn, fpdu, curr_pkt, buf,
 						 mpa_buf->tcp_payload_len,
 						 pkt_type);
diff --git a/drivers/net/ethernet/qlogic/qed/qed_iwarp.h b/drivers/net/ethernet/qlogic/qed/qed_iwarp.h
index 58db51a..c58793a 100644
--- a/drivers/net/ethernet/qlogic/qed/qed_iwarp.h
+++ b/drivers/net/ethernet/qlogic/qed/qed_iwarp.h
@@ -69,6 +69,12 @@ struct qed_iwarp_ll2_mpa_buf {
 	u8 placement_offset;
 };
 
+/* In some cases a fpdu will arrive with only one byte of the header, in this
+ * case the fpdu_length will be partial (contain only higher byte and
+ * incomplete bytes will contain the invalid value
+ */
+#define QED_IWARP_INVALID_INCOMPLETE_BYTES 0xffff
+
 struct qed_iwarp_fpdu {
 	struct qed_iwarp_ll2_buff *mpa_buf;
 	void *mpa_frag_virt;
-- 
1.8.3.1
