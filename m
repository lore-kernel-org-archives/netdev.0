From: Jitendra Kalsaria <jitendra.kalsaria@qlogic.com>
Subject: [net-next PATCH 2/8] qlcnic: enable LRO on IPv6 without dest ip check
Date: Fri, 25 Jan 2013 15:20:35 -0500
Message-ID: <1359145241-5175-3-git-send-email-jitendra.kalsaria@qlogic.com>
References: <1359145241-5175-1-git-send-email-jitendra.kalsaria@qlogic.com>
Cc: netdev@vger.kernel.org, sony.chacko@qlogic.com,
	Dept_NX_Linux_NIC_Driver@qlogic.com,
	Shahed Shaikh <shahed.shaikh@qlogic.com>
To: davem@davemloft.net
Return-path: <netdev-owner@vger.kernel.org>
Received: from mvnat01.qlogic.com ([198.186.3.73]:6853 "HELO linux-zupk.site"
	rhost-flags-OK-OK-OK-FAIL) by vger.kernel.org with SMTP
	id S1751056Ab3AYUlX (ORCPT <rfc822;netdev@vger.kernel.org>);
	Fri, 25 Jan 2013 15:41:23 -0500
In-Reply-To: <1359145241-5175-1-git-send-email-jitendra.kalsaria@qlogic.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Shahed Shaikh <shahed.shaikh@qlogic.com>

Signed-off-by: Shahed Shaikh <shahed.shaikh@qlogic.com>
---
 drivers/net/ethernet/qlogic/qlcnic/qlcnic.h      |    2 ++
 drivers/net/ethernet/qlogic/qlcnic/qlcnic_hw.c   |   15 ++++++++++++++-
 drivers/net/ethernet/qlogic/qlcnic/qlcnic_io.c   |   22 ++++++++++++++++------
 drivers/net/ethernet/qlogic/qlcnic/qlcnic_main.c |    6 ++++++
 4 files changed, 38 insertions(+), 7 deletions(-)

diff --git a/drivers/net/ethernet/qlogic/qlcnic/qlcnic.h b/drivers/net/ethernet/qlogic/qlcnic/qlcnic.h
index c1ab34e..311d545 100644
--- a/drivers/net/ethernet/qlogic/qlcnic/qlcnic.h
+++ b/drivers/net/ethernet/qlogic/qlcnic/qlcnic.h
@@ -436,6 +436,7 @@ struct qlcnic_hardware_context {
 	u16 act_pci_func;
 
 	u32 capabilities;
+	u32 capabilities2;
 	u32 temp;
 	u32 int_vec_bit;
 	u32 fw_hal_version;
@@ -798,6 +799,7 @@ struct qlcnic_mac_list_s {
 #define QLCNIC_FW_CAPABILITY_MORE_CAPS		BIT_31
 
 #define QLCNIC_FW_CAPABILITY_2_LRO_MAX_TCP_SEG	BIT_2
+#define QLCNIC_FW_CAP2_HW_LRO_IPV6		BIT_3
 #define QLCNIC_FW_CAPABILITY_2_OCBB		BIT_5
 
 /* module types */
diff --git a/drivers/net/ethernet/qlogic/qlcnic/qlcnic_hw.c b/drivers/net/ethernet/qlogic/qlcnic/qlcnic_hw.c
index 6f5b5eb..8e0412b 100644
--- a/drivers/net/ethernet/qlogic/qlcnic/qlcnic_hw.c
+++ b/drivers/net/ethernet/qlogic/qlcnic/qlcnic_hw.c
@@ -687,6 +687,11 @@ void qlcnic_82xx_config_intr_coalesce(struct qlcnic_adapter *adapter)
 			"Could not send interrupt coalescing parameters\n");
 }
 
+#define QLCNIC_ENABLE_IPV4_LRO		1
+#define QLCNIC_ENABLE_IPV6_LRO		2
+#define QLCNIC_NO_DEST_IPV4_CHECK	(1 << 8)
+#define QLCNIC_NO_DEST_IPV6_CHECK	(2 << 8)
+
 int qlcnic_82xx_config_hw_lro(struct qlcnic_adapter *adapter, int enable)
 {
 	struct qlcnic_nic_req req;
@@ -703,7 +708,15 @@ int qlcnic_82xx_config_hw_lro(struct qlcnic_adapter *adapter, int enable)
 	word = QLCNIC_H2C_OPCODE_CONFIG_HW_LRO | ((u64)adapter->portnum << 16);
 	req.req_hdr = cpu_to_le64(word);
 
-	req.words[0] = cpu_to_le64(enable);
+	word = 0;
+	if (enable) {
+		word = QLCNIC_ENABLE_IPV4_LRO | QLCNIC_NO_DEST_IPV4_CHECK;
+		if (adapter->ahw->capabilities2 & QLCNIC_FW_CAP2_HW_LRO_IPV6)
+			word |= QLCNIC_ENABLE_IPV6_LRO |
+				QLCNIC_NO_DEST_IPV6_CHECK;
+	}
+
+	req.words[0] = cpu_to_le64(word);
 
 	rv = qlcnic_send_cmd_descs(adapter, (struct cmd_desc_type0 *)&req, 1);
 	if (rv != 0)
diff --git a/drivers/net/ethernet/qlogic/qlcnic/qlcnic_io.c b/drivers/net/ethernet/qlogic/qlcnic/qlcnic_io.c
index 383ecd2..0033971 100644
--- a/drivers/net/ethernet/qlogic/qlcnic/qlcnic_io.c
+++ b/drivers/net/ethernet/qlogic/qlcnic/qlcnic_io.c
@@ -973,6 +973,7 @@ qlcnic_process_lro(struct qlcnic_adapter *adapter,
 	struct sk_buff *skb;
 	struct qlcnic_host_rds_ring *rds_ring;
 	struct iphdr *iph;
+	struct ipv6hdr *ipv6h;
 	struct tcphdr *th;
 	bool push, timestamp;
 	int index, l2_hdr_offset, l4_hdr_offset;
@@ -1016,12 +1017,21 @@ qlcnic_process_lro(struct qlcnic_adapter *adapter,
 	}
 
 	skb->protocol = eth_type_trans(skb, netdev);
-	iph = (struct iphdr *)skb->data;
-	th = (struct tcphdr *)(skb->data + (iph->ihl << 2));
-	length = (iph->ihl << 2) + (th->doff << 2) + lro_length;
-	iph->tot_len = htons(length);
-	iph->check = 0;
-	iph->check = ip_fast_csum((unsigned char *)iph, iph->ihl);
+
+	if (htons(skb->protocol) == ETH_P_IPV6) {
+		ipv6h = (struct ipv6hdr *)skb->data;
+		th = (struct tcphdr *)(skb->data + sizeof(struct ipv6hdr));
+		length = (th->doff << 2) + lro_length;
+		ipv6h->payload_len = htons(length);
+	} else {
+		iph = (struct iphdr *)skb->data;
+		th = (struct tcphdr *)(skb->data + (iph->ihl << 2));
+		length = (iph->ihl << 2) + (th->doff << 2) + lro_length;
+		iph->tot_len = htons(length);
+		iph->check = 0;
+		iph->check = ip_fast_csum((unsigned char *)iph, iph->ihl);
+	}
+
 	th->psh = push;
 	th->seq = htonl(seq_number);
 	length = skb->len;
diff --git a/drivers/net/ethernet/qlogic/qlcnic/qlcnic_main.c b/drivers/net/ethernet/qlogic/qlcnic/qlcnic_main.c
index 5f3308a..e460401 100644
--- a/drivers/net/ethernet/qlogic/qlcnic/qlcnic_main.c
+++ b/drivers/net/ethernet/qlogic/qlcnic/qlcnic_main.c
@@ -781,6 +781,12 @@ qlcnic_initialize_nic(struct qlcnic_adapter *adapter)
 	adapter->ahw->max_tx_ques = nic_info.max_tx_ques;
 	adapter->ahw->max_rx_ques = nic_info.max_rx_ques;
 	adapter->ahw->capabilities = nic_info.capabilities;
+
+	if (adapter->ahw->capabilities & QLCNIC_FW_CAPABILITY_MORE_CAPS) {
+		u32 temp;
+		temp = QLCRD32(adapter, CRB_FW_CAPABILITIES_2);
+		adapter->ahw->capabilities2 = temp;
+	}
 	adapter->ahw->max_mac_filters = nic_info.max_mac_filters;
 	adapter->ahw->max_mtu = nic_info.max_mtu;
 
-- 
1.7.1
