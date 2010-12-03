From: Anirban Chakraborty <anirban.chakraborty@qlogic.com>
Subject: [PATCH net-next-2.6 1/4] qlcnic: Disable loopback support
Date: Thu, 2 Dec 2010 22:41:23 -0800
Message-ID: <alpine.OSX.2.00.1012022227290.19027@n6030irds86zn1.qlogic.org>
Mime-Version: 1.0
Content-Type: text/plain; charset="US-ASCII"
Cc: Dept_NX_Linux_NIC_Driver <Dept_NX_Linux_NIC_Driver@qlogic.com>
To: David Miller <davem@davemloft.net>,
	"netdev@vger.kernel.org" <netdev@vger.kernel.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from avexcashub1.qlogic.com ([198.70.193.61]:53787 "EHLO
	avexcashub1.qlogic.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751489Ab0LCGly (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 3 Dec 2010 01:41:54 -0500
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Sucheta Chakraborty <sucheta.chakraborty@qlogic.com>

Loopback mode can not be supported in CNA mode. Removing it until FW is fixed. 

Signed-off-by: Sucheta Chakraborty <sucheta.chakraborty@qlogic.com>
Signed-off-by: Anirban Chakraborty <anirban.chakraborty@qlogic.com>
---
 drivers/net/qlcnic/qlcnic.h         |    7 --
 drivers/net/qlcnic/qlcnic_ethtool.c |  104 +----------------------------------
 drivers/net/qlcnic/qlcnic_hw.c      |   53 ------------------
 drivers/net/qlcnic/qlcnic_init.c    |   93 -------------------------------
 drivers/net/qlcnic/qlcnic_main.c    |   55 ------------------
 5 files changed, 1 insertions(+), 311 deletions(-)

diff --git a/drivers/net/qlcnic/qlcnic.h b/drivers/net/qlcnic/qlcnic.h
index 9513a83..1fd476d 100644
--- a/drivers/net/qlcnic/qlcnic.h
+++ b/drivers/net/qlcnic/qlcnic.h
@@ -798,7 +798,6 @@ struct qlcnic_nic_intr_coalesce {
 #define QLCNIC_H2C_OPCODE_GET_NET_STATS 		16
 #define QLCNIC_H2C_OPCODE_PROXY_UPDATE_P2V		17
 #define QLCNIC_H2C_OPCODE_CONFIG_IPADDR 		18
-#define QLCNIC_H2C_OPCODE_CONFIG_LOOPBACK		19
 #define QLCNIC_H2C_OPCODE_PROXY_STOP_DONE		20
 #define QLCNIC_H2C_OPCODE_GET_LINKEVENT 		21
 #define QLCNIC_C2C_OPCODE				22
@@ -1314,21 +1313,15 @@ int qlcnic_config_bridged_mode(struct qlcnic_adapter *adapter, u32 enable);
 int qlcnic_send_lro_cleanup(struct qlcnic_adapter *adapter);
 void qlcnic_update_cmd_producer(struct qlcnic_adapter *adapter,
 		struct qlcnic_host_tx_ring *tx_ring);
-void qlcnic_clear_ilb_mode(struct qlcnic_adapter *adapter);
-int qlcnic_set_ilb_mode(struct qlcnic_adapter *adapter);
 void qlcnic_fetch_mac(struct qlcnic_adapter *, u32, u32, u8, u8 *);
 
 /* Functions from qlcnic_main.c */
-int qlcnic_request_quiscent_mode(struct qlcnic_adapter *adapter);
-void qlcnic_clear_quiscent_mode(struct qlcnic_adapter *adapter);
 int qlcnic_reset_context(struct qlcnic_adapter *);
 u32 qlcnic_issue_cmd(struct qlcnic_adapter *adapter,
 	u32 pci_fn, u32 version, u32 arg1, u32 arg2, u32 arg3, u32 cmd);
 void qlcnic_diag_free_res(struct net_device *netdev, int max_sds_rings);
 int qlcnic_diag_alloc_res(struct net_device *netdev, int test);
-int qlcnic_check_loopback_buff(unsigned char *data);
 netdev_tx_t qlcnic_xmit_frame(struct sk_buff *skb, struct net_device *netdev);
-void qlcnic_process_rcv_ring_diag(struct qlcnic_host_sds_ring *sds_ring);
 
 /* Management functions */
 int qlcnic_get_mac_address(struct qlcnic_adapter *, u8*);
diff --git a/drivers/net/qlcnic/qlcnic_ethtool.c b/drivers/net/qlcnic/qlcnic_ethtool.c
index c389296..2aa9d8b 100644
--- a/drivers/net/qlcnic/qlcnic_ethtool.c
+++ b/drivers/net/qlcnic/qlcnic_ethtool.c
@@ -101,8 +101,7 @@ static const char qlcnic_device_gstrings_stats[][ETH_GSTRING_LEN] = {
 static const char qlcnic_gstrings_test[][ETH_GSTRING_LEN] = {
 	"Register_Test_on_offline",
 	"Link_Test_on_offline",
-	"Interrupt_Test_offline",
-	"Loopback_Test_offline"
+	"Interrupt_Test_offline"
 };
 
 #define QLCNIC_TEST_LEN	ARRAY_SIZE(qlcnic_gstrings_test)
@@ -643,104 +642,6 @@ static int qlcnic_get_sset_count(struct net_device *dev, int sset)
 	}
 }
 
-#define QLC_ILB_PKT_SIZE 64
-#define QLC_NUM_ILB_PKT	16
-#define QLC_ILB_MAX_RCV_LOOP 10
-
-static void qlcnic_create_loopback_buff(unsigned char *data)
-{
-	unsigned char random_data[] = {0xa8, 0x06, 0x45, 0x00};
-	memset(data, 0x4e, QLC_ILB_PKT_SIZE);
-	memset(data, 0xff, 12);
-	memcpy(data + 12, random_data, sizeof(random_data));
-}
-
-int qlcnic_check_loopback_buff(unsigned char *data)
-{
-	unsigned char buff[QLC_ILB_PKT_SIZE];
-	qlcnic_create_loopback_buff(buff);
-	return memcmp(data, buff, QLC_ILB_PKT_SIZE);
-}
-
-static int qlcnic_do_ilb_test(struct qlcnic_adapter *adapter)
-{
-	struct qlcnic_recv_context *recv_ctx = &adapter->recv_ctx;
-	struct qlcnic_host_sds_ring *sds_ring = &recv_ctx->sds_rings[0];
-	struct sk_buff *skb;
-	int i, loop, cnt = 0;
-
-	for (i = 0; i < QLC_NUM_ILB_PKT; i++) {
-		skb = dev_alloc_skb(QLC_ILB_PKT_SIZE);
-		qlcnic_create_loopback_buff(skb->data);
-		skb_put(skb, QLC_ILB_PKT_SIZE);
-
-		adapter->diag_cnt = 0;
-		qlcnic_xmit_frame(skb, adapter->netdev);
-
-		loop = 0;
-		do {
-			msleep(1);
-			qlcnic_process_rcv_ring_diag(sds_ring);
-		} while (loop++ < QLC_ILB_MAX_RCV_LOOP &&
-			 !adapter->diag_cnt);
-
-		dev_kfree_skb_any(skb);
-
-		if (!adapter->diag_cnt)
-			dev_warn(&adapter->pdev->dev, "ILB Test: %dth packet"
-				" not recevied\n", i + 1);
-		else
-			cnt++;
-	}
-	if (cnt != i) {
-		dev_warn(&adapter->pdev->dev, "ILB Test failed\n");
-		return -1;
-	}
-	return 0;
-}
-
-static int qlcnic_loopback_test(struct net_device *netdev)
-{
-	struct qlcnic_adapter *adapter = netdev_priv(netdev);
-	int max_sds_rings = adapter->max_sds_rings;
-	int ret;
-
-	if (adapter->op_mode == QLCNIC_NON_PRIV_FUNC) {
-		dev_warn(&adapter->pdev->dev, "Loopback test not supported"
-				"for non privilege function\n");
-		return 0;
-	}
-
-	if (test_and_set_bit(__QLCNIC_RESETTING, &adapter->state))
-		return -EIO;
-
-	if (qlcnic_request_quiscent_mode(adapter)) {
-		clear_bit(__QLCNIC_RESETTING, &adapter->state);
-		return -EIO;
-	}
-
-	ret = qlcnic_diag_alloc_res(netdev, QLCNIC_LOOPBACK_TEST);
-	if (ret)
-		goto clear_it;
-
-	ret = qlcnic_set_ilb_mode(adapter);
-	if (ret)
-		goto done;
-
-	ret = qlcnic_do_ilb_test(adapter);
-
-	qlcnic_clear_ilb_mode(adapter);
-
-done:
-	qlcnic_diag_free_res(netdev, max_sds_rings);
-
-clear_it:
-	qlcnic_clear_quiscent_mode(adapter);
-	adapter->max_sds_rings = max_sds_rings;
-	clear_bit(__QLCNIC_RESETTING, &adapter->state);
-	return ret;
-}
-
 static int qlcnic_irq_test(struct net_device *netdev)
 {
 	struct qlcnic_adapter *adapter = netdev_priv(netdev);
@@ -793,9 +694,6 @@ qlcnic_diag_test(struct net_device *dev, struct ethtool_test *eth_test,
 		if (data[2])
 			eth_test->flags |= ETH_TEST_FL_FAILED;
 
-		data[3] = qlcnic_loopback_test(dev);
-		if (data[3])
-			eth_test->flags |= ETH_TEST_FL_FAILED;
 
 	}
 }
diff --git a/drivers/net/qlcnic/qlcnic_hw.c b/drivers/net/qlcnic/qlcnic_hw.c
index 7a47a2a..8630118 100644
--- a/drivers/net/qlcnic/qlcnic_hw.c
+++ b/drivers/net/qlcnic/qlcnic_hw.c
@@ -1234,56 +1234,3 @@ int qlcnic_config_led(struct qlcnic_adapter *adapter, u32 state, u32 rate)
 
 	return rv;
 }
-
-static int qlcnic_set_fw_loopback(struct qlcnic_adapter *adapter, u32 flag)
-{
-	struct qlcnic_nic_req	req;
-	int			rv;
-	u64			word;
-
-	memset(&req, 0, sizeof(struct qlcnic_nic_req));
-	req.qhdr = cpu_to_le64(QLCNIC_HOST_REQUEST << 23);
-
-	word = QLCNIC_H2C_OPCODE_CONFIG_LOOPBACK |
-			((u64)adapter->portnum << 16);
-	req.req_hdr = cpu_to_le64(word);
-	req.words[0] = cpu_to_le64(flag);
-
-	rv = qlcnic_send_cmd_descs(adapter, (struct cmd_desc_type0 *)&req, 1);
-	if (rv)
-		dev_err(&adapter->pdev->dev,
-			"%sting loopback mode failed.\n",
-					flag ? "Set" : "Reset");
-	return rv;
-}
-
-int qlcnic_set_ilb_mode(struct qlcnic_adapter *adapter)
-{
-	if (qlcnic_set_fw_loopback(adapter, 1))
-		return -EIO;
-
-	if (qlcnic_nic_set_promisc(adapter,
-				VPORT_MISS_MODE_ACCEPT_ALL)) {
-		qlcnic_set_fw_loopback(adapter, 0);
-		return -EIO;
-	}
-
-	msleep(1000);
-	return 0;
-}
-
-void qlcnic_clear_ilb_mode(struct qlcnic_adapter *adapter)
-{
-	int mode = VPORT_MISS_MODE_DROP;
-	struct net_device *netdev = adapter->netdev;
-
-	qlcnic_set_fw_loopback(adapter, 0);
-
-	if (netdev->flags & IFF_PROMISC)
-		mode = VPORT_MISS_MODE_ACCEPT_ALL;
-	else if (netdev->flags & IFF_ALLMULTI)
-		mode = VPORT_MISS_MODE_ACCEPT_MULTI;
-
-	qlcnic_nic_set_promisc(adapter, mode);
-	msleep(1000);
-}
diff --git a/drivers/net/qlcnic/qlcnic_init.c b/drivers/net/qlcnic/qlcnic_init.c
index c5ea2f4..6d0ec6c 100644
--- a/drivers/net/qlcnic/qlcnic_init.c
+++ b/drivers/net/qlcnic/qlcnic_init.c
@@ -1690,99 +1690,6 @@ qlcnic_post_rx_buffers_nodb(struct qlcnic_adapter *adapter,
 	spin_unlock(&rds_ring->lock);
 }
 
-static void dump_skb(struct sk_buff *skb)
-{
-	int i;
-	unsigned char *data = skb->data;
-
-	for (i = 0; i < skb->len; i++) {
-		printk("%02x ", data[i]);
-		if ((i & 0x0f) == 8)
-			printk("\n");
-	}
-}
-
-static struct qlcnic_rx_buffer *
-qlcnic_process_rcv_diag(struct qlcnic_adapter *adapter,
-		struct qlcnic_host_sds_ring *sds_ring,
-		int ring, u64 sts_data0)
-{
-	struct qlcnic_recv_context *recv_ctx = &adapter->recv_ctx;
-	struct qlcnic_rx_buffer *buffer;
-	struct sk_buff *skb;
-	struct qlcnic_host_rds_ring *rds_ring;
-	int index, length, cksum, pkt_offset;
-
-	if (unlikely(ring >= adapter->max_rds_rings))
-		return NULL;
-
-	rds_ring = &recv_ctx->rds_rings[ring];
-
-	index = qlcnic_get_sts_refhandle(sts_data0);
-	if (unlikely(index >= rds_ring->num_desc))
-		return NULL;
-
-	buffer = &rds_ring->rx_buf_arr[index];
-
-	length = qlcnic_get_sts_totallength(sts_data0);
-	cksum  = qlcnic_get_sts_status(sts_data0);
-	pkt_offset = qlcnic_get_sts_pkt_offset(sts_data0);
-
-	skb = qlcnic_process_rxbuf(adapter, rds_ring, index, cksum);
-	if (!skb)
-		return buffer;
-
-	if (length > rds_ring->skb_size)
-		skb_put(skb, rds_ring->skb_size);
-	else
-		skb_put(skb, length);
-
-	if (pkt_offset)
-		skb_pull(skb, pkt_offset);
-
-	if (!qlcnic_check_loopback_buff(skb->data))
-		adapter->diag_cnt++;
-	else
-		dump_skb(skb);
-
-	dev_kfree_skb_any(skb);
-	adapter->stats.rx_pkts++;
-	adapter->stats.rxbytes += length;
-
-	return buffer;
-}
-
-void
-qlcnic_process_rcv_ring_diag(struct qlcnic_host_sds_ring *sds_ring)
-{
-	struct qlcnic_adapter *adapter = sds_ring->adapter;
-	struct status_desc *desc;
-	struct qlcnic_rx_buffer *rxbuf;
-	u64 sts_data0;
-
-	int opcode, ring, desc_cnt;
-	u32 consumer = sds_ring->consumer;
-
-	desc = &sds_ring->desc_head[consumer];
-	sts_data0 = le64_to_cpu(desc->status_desc_data[0]);
-
-	if (!(sts_data0 & STATUS_OWNER_HOST))
-		return;
-
-	desc_cnt = qlcnic_get_sts_desc_cnt(sts_data0);
-	opcode = qlcnic_get_sts_opcode(sts_data0);
-
-	ring = qlcnic_get_sts_type(sts_data0);
-	rxbuf = qlcnic_process_rcv_diag(adapter, sds_ring,
-					ring, sts_data0);
-
-	desc->status_desc_data[0] = cpu_to_le64(STATUS_OWNER_PHANTOM);
-	consumer = get_next_index(consumer, sds_ring->num_desc);
-
-	sds_ring->consumer = consumer;
-	writel(consumer, sds_ring->crb_sts_consumer);
-}
-
 void
 qlcnic_fetch_mac(struct qlcnic_adapter *adapter, u32 off1, u32 off2,
 			u8 alt_mac, u8 *mac)
diff --git a/drivers/net/qlcnic/qlcnic_main.c b/drivers/net/qlcnic/qlcnic_main.c
index 899df5a..08d4b37 100644
--- a/drivers/net/qlcnic/qlcnic_main.c
+++ b/drivers/net/qlcnic/qlcnic_main.c
@@ -2859,61 +2859,6 @@ qlcnic_set_npar_non_operational(struct qlcnic_adapter *adapter)
 	qlcnic_api_unlock(adapter);
 }
 
-/* Caller should held RESETTING bit.
- * This should be call in sync with qlcnic_request_quiscent_mode.
- */
-void qlcnic_clear_quiscent_mode(struct qlcnic_adapter *adapter)
-{
-	qlcnic_clr_drv_state(adapter);
-	qlcnic_api_lock(adapter);
-	QLCWR32(adapter, QLCNIC_CRB_DEV_STATE, QLCNIC_DEV_READY);
-	qlcnic_api_unlock(adapter);
-}
-
-/* Caller should held RESETTING bit.
- */
-int qlcnic_request_quiscent_mode(struct qlcnic_adapter *adapter)
-{
-	u8 timeo = adapter->dev_init_timeo / 2;
-	u32 state;
-
-	if (qlcnic_api_lock(adapter))
-		return -EIO;
-
-	state = QLCRD32(adapter, QLCNIC_CRB_DEV_STATE);
-	if (state != QLCNIC_DEV_READY)
-		return -EIO;
-
-	QLCWR32(adapter, QLCNIC_CRB_DEV_STATE, QLCNIC_DEV_NEED_QUISCENT);
-	qlcnic_api_unlock(adapter);
-	QLCDB(adapter, DRV, "NEED QUISCENT state set\n");
-	qlcnic_idc_debug_info(adapter, 0);
-
-	qlcnic_set_drv_state(adapter, QLCNIC_DEV_NEED_QUISCENT);
-
-	do {
-		msleep(2000);
-		state = QLCRD32(adapter, QLCNIC_CRB_DEV_STATE);
-		if (state == QLCNIC_DEV_QUISCENT)
-			return 0;
-		if (!qlcnic_check_drv_state(adapter)) {
-			if (qlcnic_api_lock(adapter))
-				return -EIO;
-			QLCWR32(adapter, QLCNIC_CRB_DEV_STATE,
-							QLCNIC_DEV_QUISCENT);
-			qlcnic_api_unlock(adapter);
-			QLCDB(adapter, DRV, "QUISCENT mode set\n");
-			return 0;
-		}
-	} while (--timeo);
-
-	dev_err(&adapter->pdev->dev, "Failed to quiesce device, DRV_STATE=%08x"
-		" DRV_ACTIVE=%08x\n", QLCRD32(adapter, QLCNIC_CRB_DRV_STATE),
-		QLCRD32(adapter, QLCNIC_CRB_DRV_ACTIVE));
-	qlcnic_clear_quiscent_mode(adapter);
-	return -EIO;
-}
-
 /*Transit to RESET state from READY state only */
 static void
 qlcnic_dev_request_reset(struct qlcnic_adapter *adapter)
-- 
1.5.4.5

