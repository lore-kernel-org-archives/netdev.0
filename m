From: Hannes Frederic Sowa <hannes@stressinduktion.org>
Subject: Re: Atheros Communications Inc. AR8121/AR8113/AR8114 Gigabit or Fast Ethernet (rev b0) 1.0.0.7 md5/sha1 corrupted using NFS and samba (updated) Version 2
Date: Thu, 28 Mar 2013 04:19:32 +0100
Message-ID: <20130328031932.GC2176@order.stressinduktion.org>
References: <20130326044025.GD29705@order.stressinduktion.org> <157393863283F442885425D2C4542856489E8232@nasanexd02f.na.qualcomm.com> <20130327220248.GD23223@order.stressinduktion.org> <157393863283F442885425D2C45428564F1FDF82@nasanexd02f.na.qualcomm.com> <20130327223433.GE23223@order.stressinduktion.org> <157393863283F442885425D2C45428564F1FFFCE@nasanexd02f.na.qualcomm.com> <20130328004024.GA2176@order.stressinduktion.org> <157393863283F442885425D2C45428564F200FE9@nasanexd02f.na.qualcomm.com> <20130328011602.GB2176@order.stressinduktion.org> <157393863283F442885425D2C45428564F200FFD@nasanexd02f.na.qualcomm.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=utf-8
Cc: Sven Hartge <sven@svenhartge.de>,
	"netdev@vger.kernel.org" <netdev@vger.kernel.org>
To: "Huang, Xiong" <xiong@qca.qualcomm.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from order.stressinduktion.org ([87.106.68.36]:35417 "EHLO
	order.stressinduktion.org" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1754316Ab3C1DTe (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 27 Mar 2013 23:19:34 -0400
Content-Disposition: inline
In-Reply-To: <157393863283F442885425D2C45428564F200FFD@nasanexd02f.na.qualcomm.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Thu, Mar 28, 2013 at 01:17:53AM +0000, Huang, Xiong wrote:
> > 
> > We will try to go with RXQ_CTRL_PBA_ALIGN_256 in REG_RXQ_CTRL next.
> > Just have to check the ring resources are initialized correctly.
> > 
> > Thanks,
> 
> 
> ALIGN_256 require the RXF page 256 byte alignment, you should also revise the memory allocation function.

Could you have a look at the following diff? It does not work either. Perhaps
something is wrong in the calculations (but there are no seq number mismatches).

diff --git a/drivers/net/ethernet/atheros/atl1e/atl1e_main.c b/drivers/net/ethernet/atheros/atl1e/atl1e_main.c
index e1f1b2a..5264810 100644
--- a/drivers/net/ethernet/atheros/atl1e/atl1e_main.c
+++ b/drivers/net/ethernet/atheros/atl1e/atl1e_main.c
@@ -697,7 +697,7 @@ static void atl1e_cal_ring_size(struct atl1e_adapter *adapter, u32 *ring_size)
 		     sizeof(struct atl1e_tpd_desc) + 7
 			/* tx ring, qword align */
 		     + adapter->rx_ring.real_page_size * AT_PAGE_NUM_PER_QUEUE *
-			adapter->num_rx_queues + 31
+			adapter->num_rx_queues + 255
 			/* rx ring,  32 bytes align */
 		     + (1 + AT_PAGE_NUM_PER_QUEUE * adapter->num_rx_queues) *
 			sizeof(u32) + 3));
@@ -714,7 +714,7 @@ static void atl1e_init_ring_resources(struct atl1e_adapter *adapter)
 				 + adapter->hw.max_frame_size
 				 + ETH_HLEN + VLAN_HLEN
 				 + ETH_FCS_LEN;
-	rx_ring->real_page_size = roundup(rx_ring->real_page_size, 32);
+	rx_ring->real_page_size = roundup(rx_ring->real_page_size, 256);
 	atl1e_cal_ring_size(adapter, &adapter->ring_size);
 
 	adapter->ring_vir_addr = NULL;
@@ -825,7 +825,7 @@ static int atl1e_setup_ring_resources(struct atl1e_adapter *adapter)
 
 	/* Init RXF-Pages */
 	offset += (sizeof(struct atl1e_tpd_desc) * tx_ring->count);
-	offset = roundup(offset, 32);
+	offset = roundup(offset, 256);
 
 	for (i = 0; i < adapter->num_rx_queues; i++) {
 		for (j = 0; j < AT_PAGE_NUM_PER_QUEUE; j++) {
@@ -1003,7 +1003,7 @@ static inline void atl1e_configure_rx(struct atl1e_adapter *adapter)
 		rxq_ctrl_data |=
 			(RXQ_CTRL_HASH_ENABLE | RXQ_CTRL_RSS_MODE_MQUESINT);
 
-	rxq_ctrl_data |= RXQ_CTRL_IPV6_XSUM_VERIFY_EN | RXQ_CTRL_PBA_ALIGN_32 |
+	rxq_ctrl_data |= RXQ_CTRL_IPV6_XSUM_VERIFY_EN | RXQ_CTRL_PBA_ALIGN_256 |
 			 RXQ_CTRL_CUT_THRU_EN | RXQ_CTRL_EN;
 
 	AT_WRITE_REG(hw, REG_RXQ_CTRL, rxq_ctrl_data);
@@ -1444,8 +1444,8 @@ skip_pkt:
 			rx_page->read_offset +=
 				(((u32)((prrs->word1 >> RRS_PKT_SIZE_SHIFT) &
 				RRS_PKT_SIZE_MASK) +
-				sizeof(struct atl1e_recv_ret_status) + 31) &
-						0xFFFFFFE0);
+				sizeof(struct atl1e_recv_ret_status) + 255) &
+						0xFFFFFF00);
 
 			if (rx_page->read_offset >= rx_ring->page_size) {
 				/* mark this page clean */
