From: Benjamin LaHaise <ben.lahaise@neterion.com>
Subject: [4/6] vxge: prefetch RxD descriptors
Date: Tue, 4 Aug 2009 16:21:39 -0400
Message-ID: <20090804202139.GE9924@neterion.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from barracuda.s2io.com ([72.1.205.138]:33063 "EHLO
	barracuda.s2io.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S932510AbZHDUj6 (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 4 Aug 2009 16:39:58 -0400
Received: from guinness.s2io.com (localhost [127.0.0.1])
	by barracuda.s2io.com (Spam Firewall) with ESMTP id 9ACA52065B9F
	for <netdev@vger.kernel.org>; Tue,  4 Aug 2009 16:21:46 -0400 (EDT)
Received: from guinness.s2io.com (142-46-210.147.tel-ott.com [142.46.210.147]) by barracuda.s2io.com with ESMTP id ddIyu0dAtd2uL428 for <netdev@vger.kernel.org>; Tue, 04 Aug 2009 16:21:46 -0400 (EDT)
Received: from neterion.com ([10.16.18.36])
	by guinness.s2io.com (8.12.6/8.12.6) with ESMTP id n74KLemd013316
	for <netdev@vger.kernel.org>; Tue, 4 Aug 2009 16:21:41 -0400 (EDT)
Content-Disposition: inline
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

This patch prefetches RxD descriptors which helps to lower the latency of a 
cache miss in vxge_hw_ring_rxd_next_completed.  This lowers the % of CPU 
time used by vxge_hw_ring_rxd_next_completed() where the descriptor is 
accessed in profiling netperf on a P4 Xeon from 1.5% to 1.0%.

Signed-off-by: Benjamin LaHaise <ben.lahaise@neterion.com>
Signed-off-by: Sreenivasa Honnur <sreenivasa.honnur@neterion.com>
Signed-off-by: Ramkrishna Vepa <ram.vepa@neterion.com>
---
--- a/drivers/net/vxge/vxge-main.c.orig	2009-05-04 15:04:14.000000000 -0700
+++ b/drivers/net/vxge/vxge-main.c	2009-05-04 14:58:48.000000000 -0700
@@ -445,6 +431,7 @@ vxge_rx_1b_compl(struct __vxge_hw_ring *
 	vxge_hw_ring_replenish(ringh, 0);
 
 	do {
+		prefetch((char *)dtr + L1_CACHE_BYTES);
 		rx_priv = vxge_hw_ring_rxd_private_get(dtr);
 		skb = rx_priv->skb;
 		data_size = rx_priv->data_size;
diff --git a/drivers/net/vxge/vxge-traffic.c b/drivers/net/vxge/vxge-traffic.c
index 7be0ae1..9a6b10d 100644
--- a/drivers/net/vxge/vxge-traffic.c
+++ b/drivers/net/vxge/vxge-traffic.c
@@ -731,6 +731,7 @@ vxge_hw_channel_dtr_try_complete(struct __vxge_hw_channel *channel, void **dtrh)
 	vxge_assert(channel->compl_index < channel->length);
 
 	*dtrh =	channel->work_arr[channel->compl_index];
+	prefetch(*dtrh);
 }
 
 /*
