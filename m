From: Dave Wiltshire <david.wiltshire@gmx.com>
Subject: [PATCH 2/3] skbuff: skb_cow_head not used in some drivers.
Date: Wed, 12 Jun 2013 22:40:10 +1000
Message-ID: <1371040811-8319-1-git-send-email-david.wiltshire@gmx.com>
References: <1371030906-2396-1-git-send-email-david.wiltshire@gmx.com>
Cc: netdev@vger.kernel.org, linux-kernel@vger.kernel.org,
	nsujir@broadcom.com, mchan@broadcom.com, rmody@brocade.com,
	jcliburn@gmail.com, chris.snook@gmail.com,
	jeffrey.t.kirsher@intel.com, bruce.w.allan@intel.com,
	alexander.h.duyck@intel.com, cooldavid@cooldavid.org,
	linux-driver@qlogic.com, linux-wimax@intel.com,
	wimax@linuxwimax.org, linux-wireless@vger.kernel.org,
	viro@zeniv.linux.org.uk, eparis@redhat.com, edumazet@google.com,
	dev@openvswitch.org, jhs@mojatatu.com,
	Dave Wiltshire <david.wiltshire@gmx.com>
To: davem@davemloft.net
Return-path: <netdev-owner@vger.kernel.org>
Received: from mout.gmx.net ([212.227.17.20]:62726 "EHLO mout.gmx.net"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1751402Ab3FLMjR (ORCPT <rfc822;netdev@vger.kernel.org>);
	Wed, 12 Jun 2013 08:39:17 -0400
In-Reply-To: <1371030906-2396-1-git-send-email-david.wiltshire@gmx.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

There is a helper function skb_cow_head which checks if a skb needs to
be expanded. This was unused in some drivers. Fixing that leads to
cleaner code in the drivers.

Signed-off-by: Dave Wiltshire <david.wiltshire@gmx.com>
---
 drivers/net/ethernet/atheros/atl1c/atl1c_main.c   |    8 ++------
 drivers/net/ethernet/atheros/atl1e/atl1e_main.c   |    8 ++------
 drivers/net/ethernet/atheros/atlx/atl1.c          |    8 ++------
 drivers/net/ethernet/broadcom/tg3.c               |    3 +--
 drivers/net/ethernet/brocade/bna/bnad.c           |   11 +++--------
 drivers/net/ethernet/intel/e1000/e1000_main.c     |    8 ++------
 drivers/net/ethernet/intel/e1000e/netdev.c        |    8 ++------
 drivers/net/ethernet/intel/igb/igb_main.c         |    7 ++-----
 drivers/net/ethernet/intel/igbvf/netdev.c         |   11 +++--------
 drivers/net/ethernet/intel/ixgb/ixgb_main.c       |    8 ++------
 drivers/net/ethernet/intel/ixgbe/ixgbe_main.c     |   10 +++-------
 drivers/net/ethernet/intel/ixgbevf/ixgbevf_main.c |    7 ++-----
 drivers/net/ethernet/jme.c                        |    3 +--
 drivers/net/ethernet/qlogic/qlge/qlge_main.c      |    8 ++------
 drivers/net/wimax/i2400m/netdev.c                 |    3 +--
 15 files changed, 30 insertions(+), 81 deletions(-)

diff --git a/drivers/net/ethernet/atheros/atl1c/atl1c_main.c b/drivers/net/ethernet/atheros/atl1c/atl1c_main.c
index 786a874..8c69cda 100644
--- a/drivers/net/ethernet/atheros/atl1c/atl1c_main.c
+++ b/drivers/net/ethernet/atheros/atl1c/atl1c_main.c
@@ -1931,14 +1931,10 @@ static int atl1c_tso_csum(struct atl1c_adapter *adapter,
 	u8 hdr_len;
 	u32 real_len;
 	unsigned short offload_type;
-	int err;
 
 	if (skb_is_gso(skb)) {
-		if (skb_header_cloned(skb)) {
-			err = pskb_expand_head(skb, 0, 0, GFP_ATOMIC);
-			if (unlikely(err))
-				return -1;
-		}
+		if (unlikely(skb_cow_head(skb, 0)))
+			return -1;
 		offload_type = skb_shinfo(skb)->gso_type;
 
 		if (offload_type & SKB_GSO_TCPV4) {
diff --git a/drivers/net/ethernet/atheros/atl1e/atl1e_main.c b/drivers/net/ethernet/atheros/atl1e/atl1e_main.c
index 895f537..ff10d03 100644
--- a/drivers/net/ethernet/atheros/atl1e/atl1e_main.c
+++ b/drivers/net/ethernet/atheros/atl1e/atl1e_main.c
@@ -1599,14 +1599,10 @@ static int atl1e_tso_csum(struct atl1e_adapter *adapter,
 	u8 hdr_len;
 	u32 real_len;
 	unsigned short offload_type;
-	int err;
 
 	if (skb_is_gso(skb)) {
-		if (skb_header_cloned(skb)) {
-			err = pskb_expand_head(skb, 0, 0, GFP_ATOMIC);
-			if (unlikely(err))
-				return -1;
-		}
+		if (unlikely(skb_cow_head(skb, 0)))
+			return -1;
 		offload_type = skb_shinfo(skb)->gso_type;
 
 		if (offload_type & SKB_GSO_TCPV4) {
diff --git a/drivers/net/ethernet/atheros/atlx/atl1.c b/drivers/net/ethernet/atheros/atlx/atl1.c
index 538211d..da7169c 100644
--- a/drivers/net/ethernet/atheros/atlx/atl1.c
+++ b/drivers/net/ethernet/atheros/atlx/atl1.c
@@ -2115,14 +2115,10 @@ static int atl1_tso(struct atl1_adapter *adapter, struct sk_buff *skb,
 {
 	u8 hdr_len, ip_off;
 	u32 real_len;
-	int err;
 
 	if (skb_shinfo(skb)->gso_size) {
-		if (skb_header_cloned(skb)) {
-			err = pskb_expand_head(skb, 0, 0, GFP_ATOMIC);
-			if (unlikely(err))
-				return -1;
-		}
+		if (unlikely(skb_cow_head(skb, 0)))
+			return -1;
 
 		if (skb->protocol == htons(ETH_P_IP)) {
 			struct iphdr *iph = ip_hdr(skb);
diff --git a/drivers/net/ethernet/broadcom/tg3.c b/drivers/net/ethernet/broadcom/tg3.c
index 28a645f..6daf8f9 100644
--- a/drivers/net/ethernet/broadcom/tg3.c
+++ b/drivers/net/ethernet/broadcom/tg3.c
@@ -7803,8 +7803,7 @@ static netdev_tx_t tg3_start_xmit(struct sk_buff *skb, struct net_device *dev)
 		struct iphdr *iph;
 		u32 tcp_opt_len, hdr_len;
 
-		if (skb_header_cloned(skb) &&
-		    pskb_expand_head(skb, 0, 0, GFP_ATOMIC))
+		if (skb_cow_head(skb, 0))
 			goto drop;
 
 		iph = ip_hdr(skb);
diff --git a/drivers/net/ethernet/brocade/bna/bnad.c b/drivers/net/ethernet/brocade/bna/bnad.c
index b78e69e..ba5325a 100644
--- a/drivers/net/ethernet/brocade/bna/bnad.c
+++ b/drivers/net/ethernet/brocade/bna/bnad.c
@@ -2303,14 +2303,9 @@ bnad_mbox_irq_sync(struct bnad *bnad)
 static int
 bnad_tso_prepare(struct bnad *bnad, struct sk_buff *skb)
 {
-	int err;
-
-	if (skb_header_cloned(skb)) {
-		err = pskb_expand_head(skb, 0, 0, GFP_ATOMIC);
-		if (err) {
-			BNAD_UPDATE_CTR(bnad, tso_err);
-			return err;
-		}
+	if (skb_cow_head(skb, 0)) {
+		BNAD_UPDATE_CTR(bnad, tso_err);
+		return -ENOMEM;
 	}
 
 	/*
diff --git a/drivers/net/ethernet/intel/e1000/e1000_main.c b/drivers/net/ethernet/intel/e1000/e1000_main.c
index 59ad007..828d850 100644
--- a/drivers/net/ethernet/intel/e1000/e1000_main.c
+++ b/drivers/net/ethernet/intel/e1000/e1000_main.c
@@ -2704,14 +2704,10 @@ static int e1000_tso(struct e1000_adapter *adapter,
 	u32 cmd_length = 0;
 	u16 ipcse = 0, tucse, mss;
 	u8 ipcss, ipcso, tucss, tucso, hdr_len;
-	int err;
 
 	if (skb_is_gso(skb)) {
-		if (skb_header_cloned(skb)) {
-			err = pskb_expand_head(skb, 0, 0, GFP_ATOMIC);
-			if (err)
-				return err;
-		}
+		if (skb_cow_head(skb, 0))
+			return -ENOMEM;
 
 		hdr_len = skb_transport_offset(skb) + tcp_hdrlen(skb);
 		mss = skb_shinfo(skb)->gso_size;
diff --git a/drivers/net/ethernet/intel/e1000e/netdev.c b/drivers/net/ethernet/intel/e1000e/netdev.c
index 77f81cb..da3de16 100644
--- a/drivers/net/ethernet/intel/e1000e/netdev.c
+++ b/drivers/net/ethernet/intel/e1000e/netdev.c
@@ -5070,12 +5070,8 @@ static int e1000_tso(struct e1000_ring *tx_ring, struct sk_buff *skb)
 	if (!skb_is_gso(skb))
 		return 0;
 
-	if (skb_header_cloned(skb)) {
-		int err = pskb_expand_head(skb, 0, 0, GFP_ATOMIC);
-
-		if (err)
-			return err;
-	}
+	if (skb_cow_head(skb, 0))
+		return -ENOMEM;
 
 	hdr_len = skb_transport_offset(skb) + tcp_hdrlen(skb);
 	mss = skb_shinfo(skb)->gso_size;
diff --git a/drivers/net/ethernet/intel/igb/igb_main.c b/drivers/net/ethernet/intel/igb/igb_main.c
index 6a0c1b6..917cacb 100644
--- a/drivers/net/ethernet/intel/igb/igb_main.c
+++ b/drivers/net/ethernet/intel/igb/igb_main.c
@@ -4292,11 +4292,8 @@ static int igb_tso(struct igb_ring *tx_ring,
 	if (!skb_is_gso(skb))
 		return 0;
 
-	if (skb_header_cloned(skb)) {
-		int err = pskb_expand_head(skb, 0, 0, GFP_ATOMIC);
-		if (err)
-			return err;
-	}
+	if (skb_cow_head(skb, 0))
+		return -ENOMEM;
 
 	/* ADV DTYP TUCMD MKRLOC/ISCSIHEDLEN */
 	type_tucmd = E1000_ADVTXD_TUCMD_L4T_TCP;
diff --git a/drivers/net/ethernet/intel/igbvf/netdev.c b/drivers/net/ethernet/intel/igbvf/netdev.c
index 93eb7ee..5be1dc2 100644
--- a/drivers/net/ethernet/intel/igbvf/netdev.c
+++ b/drivers/net/ethernet/intel/igbvf/netdev.c
@@ -1911,19 +1911,14 @@ static int igbvf_tso(struct igbvf_adapter *adapter,
 {
 	struct e1000_adv_tx_context_desc *context_desc;
 	unsigned int i;
-	int err;
 	struct igbvf_buffer *buffer_info;
 	u32 info = 0, tu_cmd = 0;
 	u32 mss_l4len_idx, l4len;
 	*hdr_len = 0;
 
-	if (skb_header_cloned(skb)) {
-		err = pskb_expand_head(skb, 0, 0, GFP_ATOMIC);
-		if (err) {
-			dev_err(&adapter->pdev->dev,
-			        "igbvf_tso returning an error\n");
-			return err;
-		}
+	if (skb_cow_head(skb, 0)) {
+		dev_err(&adapter->pdev->dev, "igbvf_tso returning an error\n");
+		return -ENOMEM;
 	}
 
 	l4len = tcp_hdrlen(skb);
diff --git a/drivers/net/ethernet/intel/ixgb/ixgb_main.c b/drivers/net/ethernet/intel/ixgb/ixgb_main.c
index fce3e92..59e768e 100644
--- a/drivers/net/ethernet/intel/ixgb/ixgb_main.c
+++ b/drivers/net/ethernet/intel/ixgb/ixgb_main.c
@@ -1226,17 +1226,13 @@ ixgb_tso(struct ixgb_adapter *adapter, struct sk_buff *skb)
 	unsigned int i;
 	u8 ipcss, ipcso, tucss, tucso, hdr_len;
 	u16 ipcse, tucse, mss;
-	int err;
 
 	if (likely(skb_is_gso(skb))) {
 		struct ixgb_buffer *buffer_info;
 		struct iphdr *iph;
 
-		if (skb_header_cloned(skb)) {
-			err = pskb_expand_head(skb, 0, 0, GFP_ATOMIC);
-			if (err)
-				return err;
-		}
+		if (skb_cow_head(skb, 0))
+			return -ENOMEM;
 
 		hdr_len = skb_transport_offset(skb) + tcp_hdrlen(skb);
 		mss = skb_shinfo(skb)->gso_size;
diff --git a/drivers/net/ethernet/intel/ixgbe/ixgbe_main.c b/drivers/net/ethernet/intel/ixgbe/ixgbe_main.c
index 047ebaa..57a0c00 100644
--- a/drivers/net/ethernet/intel/ixgbe/ixgbe_main.c
+++ b/drivers/net/ethernet/intel/ixgbe/ixgbe_main.c
@@ -6060,11 +6060,8 @@ static int ixgbe_tso(struct ixgbe_ring *tx_ring,
 	if (!skb_is_gso(skb))
 		return 0;
 
-	if (skb_header_cloned(skb)) {
-		int err = pskb_expand_head(skb, 0, 0, GFP_ATOMIC);
-		if (err)
-			return err;
-	}
+	if (skb_cow_head(skb, 0))
+		return -ENOMEM;
 
 	/* ADV DTYP TUCMD MKRLOC/ISCSIHEDLEN */
 	type_tucmd = IXGBE_ADVTXD_TUCMD_L4T_TCP;
@@ -6609,8 +6606,7 @@ netdev_tx_t ixgbe_xmit_frame_ring(struct sk_buff *skb,
 					IXGBE_TX_FLAGS_VLAN_PRIO_SHIFT;
 		if (tx_flags & IXGBE_TX_FLAGS_SW_VLAN) {
 			struct vlan_ethhdr *vhdr;
-			if (skb_header_cloned(skb) &&
-			    pskb_expand_head(skb, 0, 0, GFP_ATOMIC))
+			if (skb_cow_head(skb, 0))
 				goto out_drop;
 			vhdr = (struct vlan_ethhdr *)skb->data;
 			vhdr->h_vlan_TCI = htons(tx_flags >>
diff --git a/drivers/net/ethernet/intel/ixgbevf/ixgbevf_main.c b/drivers/net/ethernet/intel/ixgbevf/ixgbevf_main.c
index 1f5166a..088402e 100644
--- a/drivers/net/ethernet/intel/ixgbevf/ixgbevf_main.c
+++ b/drivers/net/ethernet/intel/ixgbevf/ixgbevf_main.c
@@ -2726,11 +2726,8 @@ static int ixgbevf_tso(struct ixgbevf_ring *tx_ring,
 	if (!skb_is_gso(skb))
 		return 0;
 
-	if (skb_header_cloned(skb)) {
-		int err = pskb_expand_head(skb, 0, 0, GFP_ATOMIC);
-		if (err)
-			return err;
-	}
+	if (skb_cow_head(skb, 0))
+		return -ENOMEM;
 
 	/* ADV DTYP TUCMD MKRLOC/ISCSIHEDLEN */
 	type_tucmd = IXGBE_ADVTXD_TUCMD_L4T_TCP;
diff --git a/drivers/net/ethernet/jme.c b/drivers/net/ethernet/jme.c
index 7fbe6ab..7493db2 100644
--- a/drivers/net/ethernet/jme.c
+++ b/drivers/net/ethernet/jme.c
@@ -2057,8 +2057,7 @@ static int
 jme_expand_header(struct jme_adapter *jme, struct sk_buff *skb)
 {
 	if (unlikely(skb_shinfo(skb)->gso_size &&
-			skb_header_cloned(skb) &&
-			pskb_expand_head(skb, 0, 0, GFP_ATOMIC))) {
+		     skb_cow_head(skb, 0))) {
 		dev_kfree_skb(skb);
 		return -1;
 	}
diff --git a/drivers/net/ethernet/qlogic/qlge/qlge_main.c b/drivers/net/ethernet/qlogic/qlge/qlge_main.c
index 2553cf4..ab7e177 100644
--- a/drivers/net/ethernet/qlogic/qlge/qlge_main.c
+++ b/drivers/net/ethernet/qlogic/qlge/qlge_main.c
@@ -2496,12 +2496,8 @@ static int ql_tso(struct sk_buff *skb, struct ob_mac_tso_iocb_req *mac_iocb_ptr)
 {
 
 	if (skb_is_gso(skb)) {
-		int err;
-		if (skb_header_cloned(skb)) {
-			err = pskb_expand_head(skb, 0, 0, GFP_ATOMIC);
-			if (err)
-				return err;
-		}
+		if (skb_cow_head(skb, 0))
+			return -ENOMEM;
 
 		mac_iocb_ptr->opcode = OPCODE_OB_MAC_TSO_IOCB;
 		mac_iocb_ptr->flags3 |= OB_MAC_TSO_IOCB_IC;
diff --git a/drivers/net/wimax/i2400m/netdev.c b/drivers/net/wimax/i2400m/netdev.c
index 4889613..a9970f1 100644
--- a/drivers/net/wimax/i2400m/netdev.c
+++ b/drivers/net/wimax/i2400m/netdev.c
@@ -374,8 +374,7 @@ netdev_tx_t i2400m_hard_start_xmit(struct sk_buff *skb,
 
 	d_fnstart(3, dev, "(skb %p net_dev %p)\n", skb, net_dev);
 
-	if (skb_header_cloned(skb) && 
-	    pskb_expand_head(skb, 0, 0, GFP_ATOMIC))
+	if (skb_cow_head(skb, 0))
 		goto drop;
 
 	if (i2400m->state == I2400M_SS_IDLE)
-- 
1.7.10.4
