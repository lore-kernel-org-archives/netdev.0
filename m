From: Shahed Shaikh <shahed.shaikh@qlogic.com>
Subject: [PATCH net-next 4/8] qlcnic: Do MAC learning for SRIOV PF.
Date: Fri, 10 Jan 2014 11:48:55 -0500
Message-ID: <1389372539-13753-5-git-send-email-shahed.shaikh@qlogic.com>
References: <1389372539-13753-1-git-send-email-shahed.shaikh@qlogic.com>
Mime-Version: 1.0
Content-Type: text/plain
Cc: <netdev@vger.kernel.org>, <Dept_NX_Linux_NIC_Driver@qlogic.com>,
	Sucheta Chakraborty <sucheta.chakraborty@qlogic.com>
To: <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mx0b-0016ce01.pphosted.com ([67.231.156.153]:45078 "EHLO
	mx0b-0016ce01.pphosted.com" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with ESMTP id S1752557AbaAJRXM (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 10 Jan 2014 12:23:12 -0500
In-Reply-To: <1389372539-13753-1-git-send-email-shahed.shaikh@qlogic.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Sucheta Chakraborty <sucheta.chakraborty@qlogic.com>

o MAC learning will be done for SRIOV PF to help program VLAN filters
  onto adapter. This will help VNIC traffic to flow through without
  flooding traffic.

Signed-off-by: Sucheta Chakraborty <sucheta.chakraborty@qlogic.com>
---
 drivers/net/ethernet/qlogic/qlcnic/qlcnic.h        |  1 +
 .../net/ethernet/qlogic/qlcnic/qlcnic_83xx_hw.c    |  2 +
 .../net/ethernet/qlogic/qlcnic/qlcnic_83xx_init.c  |  1 +
 .../net/ethernet/qlogic/qlcnic/qlcnic_83xx_vnic.c  |  8 ++-
 drivers/net/ethernet/qlogic/qlcnic/qlcnic_hw.c     |  3 +
 drivers/net/ethernet/qlogic/qlcnic/qlcnic_io.c     | 80 ++++++++++++++--------
 6 files changed, 64 insertions(+), 31 deletions(-)

diff --git a/drivers/net/ethernet/qlogic/qlcnic/qlcnic.h b/drivers/net/ethernet/qlogic/qlcnic/qlcnic.h
index 35d4876..76740c2 100644
--- a/drivers/net/ethernet/qlogic/qlcnic/qlcnic.h
+++ b/drivers/net/ethernet/qlogic/qlcnic/qlcnic.h
@@ -1079,6 +1079,7 @@ struct qlcnic_adapter {
 	u64 dev_rst_time;
 	bool drv_mac_learn;
 	bool fdb_mac_learn;
+	u8 rx_mac_learn;
 	unsigned long vlans[BITS_TO_LONGS(VLAN_N_VID)];
 	u8 flash_mfg_id;
 	struct qlcnic_npar_info *npars;
diff --git a/drivers/net/ethernet/qlogic/qlcnic/qlcnic_83xx_hw.c b/drivers/net/ethernet/qlogic/qlcnic/qlcnic_83xx_hw.c
index ca22160..03f70e8 100644
--- a/drivers/net/ethernet/qlogic/qlcnic/qlcnic_83xx_hw.c
+++ b/drivers/net/ethernet/qlogic/qlcnic/qlcnic_83xx_hw.c
@@ -1591,7 +1591,9 @@ static void qlcnic_83xx_set_interface_id_promisc(struct qlcnic_adapter *adapter,
 						 u32 *interface_id)
 {
 	if (qlcnic_sriov_pf_check(adapter)) {
+		qlcnic_alloc_lb_filters_mem(adapter);
 		qlcnic_pf_set_interface_id_promisc(adapter, interface_id);
+		adapter->rx_mac_learn = 1;
 	} else {
 		if (!qlcnic_sriov_vf_check(adapter))
 			*interface_id = adapter->recv_ctx->context_id << 16;
diff --git a/drivers/net/ethernet/qlogic/qlcnic/qlcnic_83xx_init.c b/drivers/net/ethernet/qlogic/qlcnic/qlcnic_83xx_init.c
index 22ae884..abe3924 100644
--- a/drivers/net/ethernet/qlogic/qlcnic/qlcnic_83xx_init.c
+++ b/drivers/net/ethernet/qlogic/qlcnic/qlcnic_83xx_init.c
@@ -2214,6 +2214,7 @@ int qlcnic_83xx_init(struct qlcnic_adapter *adapter, int pci_using_dac)
 	struct qlcnic_hardware_context *ahw = adapter->ahw;
 	int err = 0;
 
+	adapter->rx_mac_learn = 0;
 	ahw->msix_supported = !!qlcnic_use_msi_x;
 
 	qlcnic_83xx_init_rings(adapter);
diff --git a/drivers/net/ethernet/qlogic/qlcnic/qlcnic_83xx_vnic.c b/drivers/net/ethernet/qlogic/qlcnic/qlcnic_83xx_vnic.c
index 474320a..23c4fd1 100644
--- a/drivers/net/ethernet/qlogic/qlcnic/qlcnic_83xx_vnic.c
+++ b/drivers/net/ethernet/qlogic/qlcnic/qlcnic_83xx_vnic.c
@@ -224,10 +224,14 @@ int qlcnic_83xx_config_vnic_opmode(struct qlcnic_adapter *adapter)
 		return -EIO;
 	}
 
-	if (ahw->capabilities & QLC_83XX_ESWITCH_CAPABILITY)
+	if (ahw->capabilities & QLC_83XX_ESWITCH_CAPABILITY) {
 		adapter->flags |= QLCNIC_ESWITCH_ENABLED;
-	else
+		if (adapter->drv_mac_learn)
+			adapter->rx_mac_learn = 1;
+	} else {
 		adapter->flags &= ~QLCNIC_ESWITCH_ENABLED;
+		adapter->rx_mac_learn = 0;
+	}
 
 	ahw->idc.vnic_state = QLCNIC_DEV_NPAR_NON_OPER;
 	ahw->idc.vnic_wait_limit = QLCNIC_DEV_NPAR_OPER_TIMEO;
diff --git a/drivers/net/ethernet/qlogic/qlcnic/qlcnic_hw.c b/drivers/net/ethernet/qlogic/qlcnic/qlcnic_hw.c
index a9a149b..18cc365 100644
--- a/drivers/net/ethernet/qlogic/qlcnic/qlcnic_hw.c
+++ b/drivers/net/ethernet/qlogic/qlcnic/qlcnic_hw.c
@@ -546,8 +546,11 @@ void __qlcnic_set_multi(struct net_device *netdev, u16 vlan)
 	    !adapter->fdb_mac_learn) {
 		qlcnic_alloc_lb_filters_mem(adapter);
 		adapter->drv_mac_learn = 1;
+		if (adapter->flags & QLCNIC_ESWITCH_ENABLED)
+			adapter->rx_mac_learn = 1;
 	} else {
 		adapter->drv_mac_learn = 0;
+		adapter->rx_mac_learn = 0;
 	}
 
 	qlcnic_nic_set_promisc(adapter, mode);
diff --git a/drivers/net/ethernet/qlogic/qlcnic/qlcnic_io.c b/drivers/net/ethernet/qlogic/qlcnic/qlcnic_io.c
index 6373f60..cbe4a30 100644
--- a/drivers/net/ethernet/qlogic/qlcnic/qlcnic_io.c
+++ b/drivers/net/ethernet/qlogic/qlcnic/qlcnic_io.c
@@ -156,9 +156,9 @@ static inline void qlcnic_83xx_disable_tx_intr(struct qlcnic_adapter *adapter,
 	writel(1, tx_ring->crb_intr_mask);
 }
 
-static inline u8 qlcnic_mac_hash(u64 mac)
+static inline u8 qlcnic_mac_hash(u64 mac, u16 vlan)
 {
-	return (u8)((mac & 0xff) ^ ((mac >> 40) & 0xff));
+	return (u8)((mac & 0xff) ^ ((mac >> 40) & 0xff) ^ (vlan & 0xff));
 }
 
 static inline u32 qlcnic_get_ref_handle(struct qlcnic_adapter *adapter,
@@ -221,8 +221,11 @@ void qlcnic_add_lb_filter(struct qlcnic_adapter *adapter, struct sk_buff *skb,
 	u8 hindex, op;
 	int ret;
 
+	if (!qlcnic_sriov_pf_check(adapter) || (vlan_id == 0xffff))
+		vlan_id = 0;
+
 	memcpy(&src_addr, phdr->h_source, ETH_ALEN);
-	hindex = qlcnic_mac_hash(src_addr) &
+	hindex = qlcnic_mac_hash(src_addr, vlan_id) &
 		 (adapter->fhash.fbucket_size - 1);
 
 	if (loopback_pkt) {
@@ -322,27 +325,43 @@ static void qlcnic_send_filter(struct qlcnic_adapter *adapter,
 			       struct cmd_desc_type0 *first_desc,
 			       struct sk_buff *skb)
 {
+	struct vlan_ethhdr *vh = (struct vlan_ethhdr *)(skb->data);
+	struct ethhdr *phdr = (struct ethhdr *)(skb->data);
+	struct net_device *netdev = adapter->netdev;
+	u16 protocol = ntohs(skb->protocol);
 	struct qlcnic_filter *fil, *tmp_fil;
-	struct hlist_node *n;
 	struct hlist_head *head;
-	struct net_device *netdev = adapter->netdev;
-	struct ethhdr *phdr = (struct ethhdr *)(skb->data);
+	struct hlist_node *n;
 	u64 src_addr = 0;
 	u16 vlan_id = 0;
-	u8 hindex;
+	u8 hindex, hval;
 
-	if (ether_addr_equal(phdr->h_source, adapter->mac_addr))
-		return;
+	if (!qlcnic_sriov_pf_check(adapter)) {
+		if (ether_addr_equal(phdr->h_source, adapter->mac_addr))
+			return;
+	} else {
+		if (protocol == ETH_P_8021Q) {
+			vh = (struct vlan_ethhdr *)skb->data;
+			vlan_id = ntohs(vh->h_vlan_TCI);
+		} else if (vlan_tx_tag_present(skb)) {
+			vlan_id = vlan_tx_tag_get(skb);
+		}
+
+		if (ether_addr_equal(phdr->h_source, adapter->mac_addr) &&
+		    !vlan_id)
+			return;
+	}
 
 	if (adapter->fhash.fnum >= adapter->fhash.fmax) {
 		adapter->stats.mac_filter_limit_overrun++;
-		netdev_info(netdev, "Can not add more than %d mac addresses\n",
-			    adapter->fhash.fmax);
+		netdev_info(netdev, "Can not add more than %d mac-vlan filters, configured %d\n",
+			    adapter->fhash.fmax, adapter->fhash.fnum);
 		return;
 	}
 
 	memcpy(&src_addr, phdr->h_source, ETH_ALEN);
-	hindex = qlcnic_mac_hash(src_addr) & (adapter->fhash.fbucket_size - 1);
+	hval = qlcnic_mac_hash(src_addr, vlan_id);
+	hindex = hval & (adapter->fhash.fbucket_size - 1);
 	head = &(adapter->fhash.fhead[hindex]);
 
 	hlist_for_each_entry_safe(tmp_fil, n, head, fnode) {
@@ -1599,7 +1618,8 @@ qlcnic_83xx_process_rcv(struct qlcnic_adapter *adapter,
 	struct sk_buff *skb;
 	struct qlcnic_host_rds_ring *rds_ring;
 	int index, length, cksum, is_lb_pkt;
-	u16 vid = 0xffff, t_vid;
+	u16 vid = 0xffff;
+	int err;
 
 	if (unlikely(ring >= adapter->max_rds_rings))
 		return NULL;
@@ -1617,19 +1637,19 @@ qlcnic_83xx_process_rcv(struct qlcnic_adapter *adapter,
 	if (!skb)
 		return buffer;
 
-	if (adapter->drv_mac_learn &&
-	    (adapter->flags & QLCNIC_ESWITCH_ENABLED)) {
-		t_vid = 0;
-		is_lb_pkt = qlcnic_83xx_is_lb_pkt(sts_data[1], 0);
-		qlcnic_add_lb_filter(adapter, skb, is_lb_pkt, t_vid);
-	}
-
 	if (length > rds_ring->skb_size)
 		skb_put(skb, rds_ring->skb_size);
 	else
 		skb_put(skb, length);
 
-	if (unlikely(qlcnic_check_rx_tagging(adapter, skb, &vid))) {
+	err = qlcnic_check_rx_tagging(adapter, skb, &vid);
+
+	if (adapter->rx_mac_learn) {
+		is_lb_pkt = qlcnic_83xx_is_lb_pkt(sts_data[1], 0);
+		qlcnic_add_lb_filter(adapter, skb, is_lb_pkt, vid);
+	}
+
+	if (unlikely(err)) {
 		adapter->stats.rxdropped++;
 		dev_kfree_skb(skb);
 		return buffer;
@@ -1664,7 +1684,8 @@ qlcnic_83xx_process_lro(struct qlcnic_adapter *adapter,
 	int l2_hdr_offset, l4_hdr_offset;
 	int index, is_lb_pkt;
 	u16 lro_length, length, data_offset, gso_size;
-	u16 vid = 0xffff, t_vid;
+	u16 vid = 0xffff;
+	int err;
 
 	if (unlikely(ring > adapter->max_rds_rings))
 		return NULL;
@@ -1686,12 +1707,6 @@ qlcnic_83xx_process_lro(struct qlcnic_adapter *adapter,
 	if (!skb)
 		return buffer;
 
-	if (adapter->drv_mac_learn &&
-	    (adapter->flags & QLCNIC_ESWITCH_ENABLED)) {
-		t_vid = 0;
-		is_lb_pkt = qlcnic_83xx_is_lb_pkt(sts_data[1], 1);
-		qlcnic_add_lb_filter(adapter, skb, is_lb_pkt, t_vid);
-	}
 	if (qlcnic_83xx_is_tstamp(sts_data[1]))
 		data_offset = l4_hdr_offset + QLCNIC_TCP_TS_HDR_SIZE;
 	else
@@ -1700,7 +1715,14 @@ qlcnic_83xx_process_lro(struct qlcnic_adapter *adapter,
 	skb_put(skb, lro_length + data_offset);
 	skb_pull(skb, l2_hdr_offset);
 
-	if (unlikely(qlcnic_check_rx_tagging(adapter, skb, &vid))) {
+	err = qlcnic_check_rx_tagging(adapter, skb, &vid);
+
+	if (adapter->rx_mac_learn) {
+		is_lb_pkt = qlcnic_83xx_is_lb_pkt(sts_data[1], 1);
+		qlcnic_add_lb_filter(adapter, skb, is_lb_pkt, vid);
+	}
+
+	if (unlikely(err)) {
 		adapter->stats.rxdropped++;
 		dev_kfree_skb(skb);
 		return buffer;
-- 
1.8.3.1
