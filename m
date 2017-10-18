From: Felix Manlunas <felix.manlunas@cavium.com>
Subject: [PATCH net-next] liquidio: xmit_more support
Date: Wed, 18 Oct 2017 10:36:02 -0700
Message-ID: <20171018173602.GA14082@felix-thinkpad.cavium.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: netdev@vger.kernel.org, raghu.vatsavayi@cavium.com,
        derek.chickles@cavium.com, satananda.burla@cavium.com
To: davem@davemloft.net
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-bn3nam01on0083.outbound.protection.outlook.com ([104.47.33.83]:57291
        "EHLO NAM01-BN3-obe.outbound.protection.outlook.com"
        rhost-flags-OK-OK-OK-FAIL) by vger.kernel.org with ESMTP
        id S1750954AbdJRRgJ (ORCPT <rfc822;netdev@vger.kernel.org>);
        Wed, 18 Oct 2017 13:36:09 -0400
Content-Disposition: inline
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Intiyaz Basha <intiyaz.basha@cavium.com>

Do not write the Tx doorbell if skb->xmit_more is set unless the Tx
queue is full or stopped.

Signed-off-by: Intiyaz Basha <intiyaz.basha@cavium.com>
Signed-off-by: Derek Chickles <derek.chickles@cavium.com>
Signed-off-by: Felix Manlunas <felix.manlunas@cavium.com>
---
 drivers/net/ethernet/cavium/liquidio/lio_core.c        |  6 ++++--
 drivers/net/ethernet/cavium/liquidio/lio_main.c        | 15 +++++++++------
 drivers/net/ethernet/cavium/liquidio/lio_vf_main.c     | 14 +++++++++-----
 drivers/net/ethernet/cavium/liquidio/octeon_main.h     |  2 +-
 drivers/net/ethernet/cavium/liquidio/octeon_nic.c      |  5 +++--
 drivers/net/ethernet/cavium/liquidio/octeon_nic.h      |  3 ++-
 drivers/net/ethernet/cavium/liquidio/request_manager.c |  5 +++--
 7 files changed, 31 insertions(+), 19 deletions(-)

diff --git a/drivers/net/ethernet/cavium/liquidio/lio_core.c b/drivers/net/ethernet/cavium/liquidio/lio_core.c
index 23f6b60..b891d85 100644
--- a/drivers/net/ethernet/cavium/liquidio/lio_core.c
+++ b/drivers/net/ethernet/cavium/liquidio/lio_core.c
@@ -91,7 +91,7 @@ void octeon_update_tx_completion_counters(void *buf, int reqtype,
 	*bytes_compl += skb->len;
 }
 
-void octeon_report_sent_bytes_to_bql(void *buf, int reqtype)
+int octeon_report_sent_bytes_to_bql(void *buf, int reqtype)
 {
 	struct octnet_buf_free_info *finfo;
 	struct sk_buff *skb;
@@ -112,11 +112,13 @@ void octeon_report_sent_bytes_to_bql(void *buf, int reqtype)
 		break;
 
 	default:
-		return;
+		return 0;
 	}
 
 	txq = netdev_get_tx_queue(skb->dev, skb_get_queue_mapping(skb));
 	netdev_tx_sent_queue(txq, skb->len);
+
+	return netif_xmit_stopped(txq);
 }
 
 void liquidio_link_ctrl_cmd_completion(void *nctrl_ptr)
diff --git a/drivers/net/ethernet/cavium/liquidio/lio_main.c b/drivers/net/ethernet/cavium/liquidio/lio_main.c
index 963803b..f9a0e14 100644
--- a/drivers/net/ethernet/cavium/liquidio/lio_main.c
+++ b/drivers/net/ethernet/cavium/liquidio/lio_main.c
@@ -2479,7 +2479,8 @@ static void handle_timestamp(struct octeon_device *oct,
  */
 static inline int send_nic_timestamp_pkt(struct octeon_device *oct,
 					 struct octnic_data_pkt *ndata,
-					 struct octnet_buf_free_info *finfo)
+					 struct octnet_buf_free_info *finfo,
+					 int xmit_more)
 {
 	int retval;
 	struct octeon_soft_command *sc;
@@ -2514,7 +2515,7 @@ static inline int send_nic_timestamp_pkt(struct octeon_device *oct,
 		len = (u32)((struct octeon_instr_ih2 *)
 			    (&sc->cmd.cmd2.ih2))->dlengsz;
 
-	ring_doorbell = 1;
+	ring_doorbell = !xmit_more;
 
 	retval = octeon_send_command(oct, sc->iq_no, ring_doorbell, &sc->cmd,
 				     sc, len, ndata->reqtype);
@@ -2548,7 +2549,7 @@ static int liquidio_xmit(struct sk_buff *skb, struct net_device *netdev)
 	union tx_info *tx_info;
 	int status = 0;
 	int q_idx = 0, iq_no = 0;
-	int j;
+	int j, xmit_more = 0;
 	u64 dptr = 0;
 	u32 tag = 0;
 
@@ -2753,17 +2754,19 @@ static int liquidio_xmit(struct sk_buff *skb, struct net_device *netdev)
 		irh->vlan = skb_vlan_tag_get(skb) & 0xfff;
 	}
 
+	xmit_more = skb->xmit_more;
+
 	if (unlikely(cmdsetup.s.timestamp))
-		status = send_nic_timestamp_pkt(oct, &ndata, finfo);
+		status = send_nic_timestamp_pkt(oct, &ndata, finfo, xmit_more);
 	else
-		status = octnet_send_nic_data_pkt(oct, &ndata);
+		status = octnet_send_nic_data_pkt(oct, &ndata, xmit_more);
 	if (status == IQ_SEND_FAILED)
 		goto lio_xmit_failed;
 
 	netif_info(lio, tx_queued, lio->netdev, "Transmit queued successfully\n");
 
 	if (status == IQ_SEND_STOP)
-		stop_q(lio->netdev, q_idx);
+		stop_q(netdev, q_idx);
 
 	netif_trans_update(netdev);
 
diff --git a/drivers/net/ethernet/cavium/liquidio/lio_vf_main.c b/drivers/net/ethernet/cavium/liquidio/lio_vf_main.c
index 2e993ce..a6a5dff 100644
--- a/drivers/net/ethernet/cavium/liquidio/lio_vf_main.c
+++ b/drivers/net/ethernet/cavium/liquidio/lio_vf_main.c
@@ -1691,7 +1691,8 @@ static void handle_timestamp(struct octeon_device *oct, u32 status, void *buf)
  */
 static int send_nic_timestamp_pkt(struct octeon_device *oct,
 				  struct octnic_data_pkt *ndata,
-				  struct octnet_buf_free_info *finfo)
+				  struct octnet_buf_free_info *finfo,
+				  int xmit_more)
 {
 	struct octeon_soft_command *sc;
 	int ring_doorbell;
@@ -1721,7 +1722,7 @@ static int send_nic_timestamp_pkt(struct octeon_device *oct,
 
 	len = (u32)((struct octeon_instr_ih3 *)(&sc->cmd.cmd3.ih3))->dlengsz;
 
-	ring_doorbell = 1;
+	ring_doorbell = !xmit_more;
 
 	retval = octeon_send_command(oct, sc->iq_no, ring_doorbell, &sc->cmd,
 				     sc, len, ndata->reqtype);
@@ -1753,6 +1754,7 @@ static int liquidio_xmit(struct sk_buff *skb, struct net_device *netdev)
 	struct octeon_device *oct;
 	int q_idx = 0, iq_no = 0;
 	union tx_info *tx_info;
+	int xmit_more = 0;
 	struct lio *lio;
 	int status = 0;
 	u64 dptr = 0;
@@ -1941,10 +1943,12 @@ static int liquidio_xmit(struct sk_buff *skb, struct net_device *netdev)
 		irh->vlan = skb_vlan_tag_get(skb) & VLAN_VID_MASK;
 	}
 
+	xmit_more = skb->xmit_more;
+
 	if (unlikely(cmdsetup.s.timestamp))
-		status = send_nic_timestamp_pkt(oct, &ndata, finfo);
+		status = send_nic_timestamp_pkt(oct, &ndata, finfo, xmit_more);
 	else
-		status = octnet_send_nic_data_pkt(oct, &ndata);
+		status = octnet_send_nic_data_pkt(oct, &ndata, xmit_more);
 	if (status == IQ_SEND_FAILED)
 		goto lio_xmit_failed;
 
@@ -1953,7 +1957,7 @@ static int liquidio_xmit(struct sk_buff *skb, struct net_device *netdev)
 	if (status == IQ_SEND_STOP) {
 		dev_err(&oct->pci_dev->dev, "Rcvd IQ_SEND_STOP signal; stopping IQ-%d\n",
 			iq_no);
-		stop_q(lio->netdev, q_idx);
+		stop_q(netdev, q_idx);
 	}
 
 	netif_trans_update(netdev);
diff --git a/drivers/net/ethernet/cavium/liquidio/octeon_main.h b/drivers/net/ethernet/cavium/liquidio/octeon_main.h
index 32ef3a7..c846eec 100644
--- a/drivers/net/ethernet/cavium/liquidio/octeon_main.h
+++ b/drivers/net/ethernet/cavium/liquidio/octeon_main.h
@@ -63,7 +63,7 @@ struct octnet_buf_free_info {
 };
 
 /* BQL-related functions */
-void octeon_report_sent_bytes_to_bql(void *buf, int reqtype);
+int octeon_report_sent_bytes_to_bql(void *buf, int reqtype);
 void octeon_update_tx_completion_counters(void *buf, int reqtype,
 					  unsigned int *pkts_compl,
 					  unsigned int *bytes_compl);
diff --git a/drivers/net/ethernet/cavium/liquidio/octeon_nic.c b/drivers/net/ethernet/cavium/liquidio/octeon_nic.c
index b457cf2..150609b 100644
--- a/drivers/net/ethernet/cavium/liquidio/octeon_nic.c
+++ b/drivers/net/ethernet/cavium/liquidio/octeon_nic.c
@@ -82,9 +82,10 @@
 }
 
 int octnet_send_nic_data_pkt(struct octeon_device *oct,
-			     struct octnic_data_pkt *ndata)
+			     struct octnic_data_pkt *ndata,
+			     int xmit_more)
 {
-	int ring_doorbell = 1;
+	int ring_doorbell = !xmit_more;
 
 	return octeon_send_command(oct, ndata->q_no, ring_doorbell, &ndata->cmd,
 				   ndata->buf, ndata->datasize,
diff --git a/drivers/net/ethernet/cavium/liquidio/octeon_nic.h b/drivers/net/ethernet/cavium/liquidio/octeon_nic.h
index 6480ef8..de4130d 100644
--- a/drivers/net/ethernet/cavium/liquidio/octeon_nic.h
+++ b/drivers/net/ethernet/cavium/liquidio/octeon_nic.h
@@ -279,7 +279,8 @@ static inline int octnet_iq_is_full(struct octeon_device *oct, u32 q_no)
  * queue should be stopped, and IQ_SEND_OK if it sent okay.
  */
 int octnet_send_nic_data_pkt(struct octeon_device *oct,
-			     struct octnic_data_pkt *ndata);
+			     struct octnic_data_pkt *ndata,
+			     int xmit_more);
 
 /** Send a NIC control packet to the device
  * @param oct - octeon device pointer
diff --git a/drivers/net/ethernet/cavium/liquidio/request_manager.c b/drivers/net/ethernet/cavium/liquidio/request_manager.c
index 1e0fbce..0086cda 100644
--- a/drivers/net/ethernet/cavium/liquidio/request_manager.c
+++ b/drivers/net/ethernet/cavium/liquidio/request_manager.c
@@ -543,6 +543,7 @@ static void check_db_timeout(struct work_struct *work)
 		    u32 force_db, void *cmd, void *buf,
 		    u32 datasize, u32 reqtype)
 {
+	int xmit_stopped;
 	struct iq_post_status st;
 	struct octeon_instr_queue *iq = oct->instr_queue[iq_no];
 
@@ -554,12 +555,12 @@ static void check_db_timeout(struct work_struct *work)
 	st = __post_command2(iq, cmd);
 
 	if (st.status != IQ_SEND_FAILED) {
-		octeon_report_sent_bytes_to_bql(buf, reqtype);
+		xmit_stopped = octeon_report_sent_bytes_to_bql(buf, reqtype);
 		__add_to_request_list(iq, st.index, buf, reqtype);
 		INCR_INSTRQUEUE_PKT_COUNT(oct, iq_no, bytes_sent, datasize);
 		INCR_INSTRQUEUE_PKT_COUNT(oct, iq_no, instr_posted, 1);
 
-		if (force_db)
+		if (force_db || xmit_stopped || st.status == IQ_SEND_STOP)
 			ring_doorbell(oct, iq);
 	} else {
 		INCR_INSTRQUEUE_PKT_COUNT(oct, iq_no, instr_dropped, 1);
-- 
1.8.3.1
