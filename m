From: Amit Kumar Salecha <amit.salecha@qlogic.com>
Subject: [PATCH NEXT 7/7] qlcnic: add loppback diagnostic test
Date: Mon,  1 Feb 2010 06:30:44 -0800
Message-ID: <1265034644-19461-8-git-send-email-amit.salecha@qlogic.com>
References: <1265034644-19461-1-git-send-email-amit.salecha@qlogic.com>
Cc: netdev@vger.kernel.org, dhananjay.phadke@qlogic.com,
	ameen.rahman@qlogic.com
To: davem@davemloft.net
Return-path: <netdev-owner@vger.kernel.org>
Received: from mvnat01.qlogic.com ([198.186.3.73]:9789 "HELO unm84.unmin.com"
	rhost-flags-OK-OK-OK-FAIL) by vger.kernel.org with SMTP
	id S1754775Ab0BAOaq (ORCPT <rfc822;netdev@vger.kernel.org>);
	Mon, 1 Feb 2010 09:30:46 -0500
In-Reply-To: <1265034644-19461-1-git-send-email-amit.salecha@qlogic.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Loopback test (offline) added in ethtool self test.
o Set device in loopback mode
o Send packets
o Process receive packets in qlcnic_process_rcv_ring_diag()
o Compare packets
o Reset device in normal mode.

Signed-off-by: Amit Kumar Salecha <amit.salecha@qlogic.com>
---
 drivers/net/qlcnic/qlcnic.h         |    6 +++
 drivers/net/qlcnic/qlcnic_ethtool.c |   82 ++++++++++++++++++++++++++++++++++-
 drivers/net/qlcnic/qlcnic_hw.c      |   50 +++++++++++++++++++++
 drivers/net/qlcnic/qlcnic_init.c    |   75 ++++++++++++++++++++++++++++++++
 drivers/net/qlcnic/qlcnic_main.c    |   20 +++++----
 5 files changed, 223 insertions(+), 10 deletions(-)

diff --git a/drivers/net/qlcnic/qlcnic.h b/drivers/net/qlcnic/qlcnic.h
index b19be26..f4924ae 100644
--- a/drivers/net/qlcnic/qlcnic.h
+++ b/drivers/net/qlcnic/qlcnic.h
@@ -897,6 +897,7 @@ struct qlcnic_mac_req {
 #define __QLCNIC_START_FW 		4
 
 #define QLCNIC_INTERRUPT_TEST		1
+#define QLCNIC_LOOPBACK_TEST		2
 
 struct qlcnic_adapter {
 	struct qlcnic_hardware_context ahw;
@@ -1066,6 +1067,8 @@ int qlcnic_send_lro_cleanup(struct qlcnic_adapter *adapter);
 void qlcnic_update_cmd_producer(struct qlcnic_adapter *adapter,
 		struct qlcnic_host_tx_ring *tx_ring);
 int qlcnic_get_mac_addr(struct qlcnic_adapter *adapter, u64 *mac);
+void qlcnic_clear_ilb_mode(struct qlcnic_adapter *adapter);
+int qlcnic_set_ilb_mode(struct qlcnic_adapter *adapter);
 
 /* Functions from qlcnic_main.c */
 int qlcnic_reset_context(struct qlcnic_adapter *);
@@ -1073,6 +1076,9 @@ u32 qlcnic_issue_cmd(struct qlcnic_adapter *adapter,
 	u32 pci_fn, u32 version, u32 arg1, u32 arg2, u32 arg3, u32 cmd);
 void qlcnic_diag_free_res(struct net_device *netdev, int max_sds_rings);
 int qlcnic_diag_alloc_res(struct net_device *netdev, int test);
+int qlcnic_check_loopback_buff(unsigned char *data);
+netdev_tx_t qlcnic_xmit_frame(struct sk_buff *skb, struct net_device *netdev);
+void qlcnic_process_rcv_ring_diag(struct qlcnic_host_sds_ring *sds_ring);
 
 /*
  * QLOGIC Board information
diff --git a/drivers/net/qlcnic/qlcnic_ethtool.c b/drivers/net/qlcnic/qlcnic_ethtool.c
index 3aafcdd..8a65a9d 100644
--- a/drivers/net/qlcnic/qlcnic_ethtool.c
+++ b/drivers/net/qlcnic/qlcnic_ethtool.c
@@ -67,7 +67,8 @@ static const char qlcnic_gstrings_test[][ETH_GSTRING_LEN] = {
 	"Register_Test_on_offline",
 	"Link_Test_on_offline",
 	"LED_Test_on_offline",
-	"Interrupt_Test_offline"
+	"Interrupt_Test_offline",
+	"Loopback_Test_offline"
 };
 
 #define QLCNIC_TEST_LEN	ARRAY_SIZE(qlcnic_gstrings_test)
@@ -615,6 +616,80 @@ static int qlcnic_get_sset_count(struct net_device *dev, int sset)
 	}
 }
 
+#define QLC_ILB_PKT_SIZE 64
+
+static void qlcnic_create_loopback_buff(unsigned char *data)
+{
+	unsigned char random_data[] = {0xa8, 0x06, 0x45, 0x00};
+	memset(data, 0x4e, QLC_ILB_PKT_SIZE);
+	memset(data, 0xff, 12);
+	memcpy(data + 12, random_data, sizeof(random_data));
+}
+
+int qlcnic_check_loopback_buff(unsigned char *data)
+{
+	unsigned char buff[QLC_ILB_PKT_SIZE];
+	qlcnic_create_loopback_buff(buff);
+	return memcmp(data, buff, QLC_ILB_PKT_SIZE);
+}
+
+static int qlcnic_do_ilb_test(struct qlcnic_adapter *adapter)
+{
+	struct qlcnic_recv_context *recv_ctx = &adapter->recv_ctx;
+	struct qlcnic_host_sds_ring *sds_ring = &recv_ctx->sds_rings[0];
+	struct sk_buff *skb;
+	int i;
+
+	for (i = 0; i < 16; i++) {
+		skb = dev_alloc_skb(QLC_ILB_PKT_SIZE);
+		qlcnic_create_loopback_buff(skb->data);
+		skb_put(skb, QLC_ILB_PKT_SIZE);
+
+		adapter->diag_cnt = 0;
+
+		qlcnic_xmit_frame(skb, adapter->netdev);
+
+		msleep(5);
+
+		qlcnic_process_rcv_ring_diag(sds_ring);
+
+		dev_kfree_skb_any(skb);
+		if (!adapter->diag_cnt)
+			return -1;
+	}
+	return 0;
+}
+
+static int qlcnic_loopback_test(struct net_device *netdev)
+{
+	struct qlcnic_adapter *adapter = netdev_priv(netdev);
+	int max_sds_rings = adapter->max_sds_rings;
+	int ret;
+
+	if (test_and_set_bit(__QLCNIC_RESETTING, &adapter->state))
+		return -EIO;
+
+	ret = qlcnic_diag_alloc_res(netdev, QLCNIC_LOOPBACK_TEST);
+	if (ret)
+		goto clear_it;
+
+	ret = qlcnic_set_ilb_mode(adapter);
+	if (ret)
+		goto done;
+
+	ret = qlcnic_do_ilb_test(adapter);
+
+	qlcnic_clear_ilb_mode(adapter);
+
+done:
+	qlcnic_diag_free_res(netdev, max_sds_rings);
+
+clear_it:
+	adapter->max_sds_rings = max_sds_rings;
+	clear_bit(__QLCNIC_RESETTING, &adapter->state);
+	return ret;
+}
+
 static int qlcnic_irq_test(struct net_device *netdev)
 {
 	struct qlcnic_adapter *adapter = netdev_priv(netdev);
@@ -659,6 +734,11 @@ qlcnic_diag_test(struct net_device *dev, struct ethtool_test *eth_test,
 		data[3] = qlcnic_irq_test(dev);
 		if (data[3])
 			eth_test->flags |= ETH_TEST_FL_FAILED;
+
+		data[4] = qlcnic_loopback_test(dev);
+		if (data[4])
+			eth_test->flags |= ETH_TEST_FL_FAILED;
+
 	}
 
 	data[0] = qlcnic_reg_test(dev);
diff --git a/drivers/net/qlcnic/qlcnic_hw.c b/drivers/net/qlcnic/qlcnic_hw.c
index 4e60c21..7ced3b8 100644
--- a/drivers/net/qlcnic/qlcnic_hw.c
+++ b/drivers/net/qlcnic/qlcnic_hw.c
@@ -1246,4 +1246,54 @@ int qlcnic_led_test(struct qlcnic_adapter *adapter)
 	return 0;
 }
 
+static int qlcnic_set_fw_loopback(struct qlcnic_adapter *adapter, u32 flag)
+{
+	struct qlcnic_nic_req	req;
+	int			rv;
+	u64			word;
+
+	memset(&req, 0, sizeof(struct qlcnic_nic_req));
+	req.qhdr = cpu_to_le64(QLCNIC_HOST_REQUEST << 23);
+
+	word = QLCNIC_H2C_OPCODE_CONFIG_LOOPBACK |
+			((u64)adapter->portnum << 16);
+	req.req_hdr = cpu_to_le64(word);
+	req.words[0] = cpu_to_le64(flag);
+
+	rv = qlcnic_send_cmd_descs(adapter, (struct cmd_desc_type0 *)&req, 1);
+	if (rv)
+		dev_err(&adapter->pdev->dev,
+			"%sting loopback mode failed.\n",
+					flag ? "Set" : "Reset");
+	return rv;
+}
+
+int qlcnic_set_ilb_mode(struct qlcnic_adapter *adapter)
+{
+	if (qlcnic_set_fw_loopback(adapter, 1))
+		return -EIO;
+
+	if (qlcnic_nic_set_promisc(adapter,
+				VPORT_MISS_MODE_ACCEPT_ALL)) {
+		qlcnic_set_fw_loopback(adapter, 0);
+		return -EIO;
+	}
 
+	msleep(1000);
+	return 0;
+}
+
+void qlcnic_clear_ilb_mode(struct qlcnic_adapter *adapter)
+{
+	int mode = VPORT_MISS_MODE_DROP;
+	struct net_device *netdev = adapter->netdev;
+
+	qlcnic_set_fw_loopback(adapter, 0);
+
+	if (netdev->flags & IFF_PROMISC)
+		mode = VPORT_MISS_MODE_ACCEPT_ALL;
+	else if (netdev->flags & IFF_ALLMULTI)
+		mode = VPORT_MISS_MODE_ACCEPT_MULTI;
+
+	qlcnic_nic_set_promisc(adapter, mode);
+}
diff --git a/drivers/net/qlcnic/qlcnic_init.c b/drivers/net/qlcnic/qlcnic_init.c
index 7ae8bcc..ea00ab4 100644
--- a/drivers/net/qlcnic/qlcnic_init.c
+++ b/drivers/net/qlcnic/qlcnic_init.c
@@ -1464,3 +1464,78 @@ qlcnic_post_rx_buffers_nodb(struct qlcnic_adapter *adapter,
 	spin_unlock(&rds_ring->lock);
 }
 
+static struct qlcnic_rx_buffer *
+qlcnic_process_rcv_diag(struct qlcnic_adapter *adapter,
+		struct qlcnic_host_sds_ring *sds_ring,
+		int ring, u64 sts_data0)
+{
+	struct qlcnic_recv_context *recv_ctx = &adapter->recv_ctx;
+	struct qlcnic_rx_buffer *buffer;
+	struct sk_buff *skb;
+	struct qlcnic_host_rds_ring *rds_ring;
+	int index, length, cksum, pkt_offset;
+
+	if (unlikely(ring >= adapter->max_rds_rings))
+		return NULL;
+
+	rds_ring = &recv_ctx->rds_rings[ring];
+
+	index = qlcnic_get_sts_refhandle(sts_data0);
+	if (unlikely(index >= rds_ring->num_desc))
+		return NULL;
+
+	buffer = &rds_ring->rx_buf_arr[index];
+
+	length = qlcnic_get_sts_totallength(sts_data0);
+	cksum  = qlcnic_get_sts_status(sts_data0);
+	pkt_offset = qlcnic_get_sts_pkt_offset(sts_data0);
+
+	skb = qlcnic_process_rxbuf(adapter, rds_ring, index, cksum);
+	if (!skb)
+		return buffer;
+
+	skb_put(skb, rds_ring->skb_size);
+
+	if (pkt_offset)
+		skb_pull(skb, pkt_offset);
+
+	skb->truesize = skb->len + sizeof(struct sk_buff);
+
+	if (!qlcnic_check_loopback_buff(skb->data))
+		adapter->diag_cnt++;
+
+	dev_kfree_skb_any(skb);
+
+	return buffer;
+}
+
+void
+qlcnic_process_rcv_ring_diag(struct qlcnic_host_sds_ring *sds_ring)
+{
+	struct qlcnic_adapter *adapter = sds_ring->adapter;
+	struct status_desc *desc;
+	struct qlcnic_rx_buffer *rxbuf;
+	u64 sts_data0;
+
+	int opcode, ring, desc_cnt;
+	u32 consumer = sds_ring->consumer;
+
+	desc = &sds_ring->desc_head[consumer];
+	sts_data0 = le64_to_cpu(desc->status_desc_data[0]);
+
+	if (!(sts_data0 & STATUS_OWNER_HOST))
+		return;
+
+	desc_cnt = qlcnic_get_sts_desc_cnt(sts_data0);
+	opcode = qlcnic_get_sts_opcode(sts_data0);
+
+	ring = qlcnic_get_sts_type(sts_data0);
+	rxbuf = qlcnic_process_rcv_diag(adapter, sds_ring,
+					ring, sts_data0);
+
+	desc->status_desc_data[0] = cpu_to_le64(STATUS_OWNER_PHANTOM);
+	consumer = get_next_index(consumer, sds_ring->num_desc);
+
+	sds_ring->consumer = consumer;
+	writel(consumer, sds_ring->crb_sts_consumer);
+}
diff --git a/drivers/net/qlcnic/qlcnic_main.c b/drivers/net/qlcnic/qlcnic_main.c
index a8b0712..665e8e5 100644
--- a/drivers/net/qlcnic/qlcnic_main.c
+++ b/drivers/net/qlcnic/qlcnic_main.c
@@ -65,8 +65,6 @@ static int __devinit qlcnic_probe(struct pci_dev *pdev,
 static void __devexit qlcnic_remove(struct pci_dev *pdev);
 static int qlcnic_open(struct net_device *netdev);
 static int qlcnic_close(struct net_device *netdev);
-static netdev_tx_t qlcnic_xmit_frame(struct sk_buff *,
-					       struct net_device *);
 static void qlcnic_tx_timeout(struct net_device *netdev);
 static void qlcnic_tx_timeout_task(struct work_struct *work);
 static void qlcnic_attach_work(struct work_struct *work);
@@ -937,9 +935,11 @@ void qlcnic_diag_free_res(struct net_device *netdev, int max_sds_rings)
 	struct qlcnic_host_sds_ring *sds_ring;
 	int ring;
 
-	for (ring = 0; ring < adapter->max_sds_rings; ring++) {
-		sds_ring = &adapter->recv_ctx.sds_rings[ring];
-		qlcnic_disable_int(sds_ring);
+	if (adapter->diag_test == QLCNIC_INTERRUPT_TEST) {
+		for (ring = 0; ring < adapter->max_sds_rings; ring++) {
+			sds_ring = &adapter->recv_ctx.sds_rings[ring];
+			qlcnic_disable_int(sds_ring);
+		}
 	}
 
 	qlcnic_detach(adapter);
@@ -977,9 +977,11 @@ int qlcnic_diag_alloc_res(struct net_device *netdev, int test)
 	if (ret)
 		return ret;
 
-	for (ring = 0; ring < adapter->max_sds_rings; ring++) {
-		sds_ring = &adapter->recv_ctx.sds_rings[ring];
-		qlcnic_enable_int(sds_ring);
+	if (adapter->diag_test == QLCNIC_INTERRUPT_TEST) {
+		for (ring = 0; ring < adapter->max_sds_rings; ring++) {
+			sds_ring = &adapter->recv_ctx.sds_rings[ring];
+			qlcnic_enable_int(sds_ring);
+		}
 	}
 
 	return 0;
@@ -1549,7 +1551,7 @@ qlcnic_clear_cmddesc(u64 *desc)
 	desc[2] = 0ULL;
 }
 
-static netdev_tx_t
+netdev_tx_t
 qlcnic_xmit_frame(struct sk_buff *skb, struct net_device *netdev)
 {
 	struct qlcnic_adapter *adapter = netdev_priv(netdev);
-- 
1.6.0.2

