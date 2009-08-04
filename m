From: Benjamin LaHaise <ben.lahaise@neterion.com>
Subject: [1/6] vxge: don't drop frame on tx queue full
Date: Tue, 4 Aug 2009 16:20:44 -0400
Message-ID: <20090804202044.GB9924@neterion.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from barracuda.s2io.com ([72.1.205.138]:33060 "EHLO
	barracuda.s2io.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S932498AbZHDUj5 (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 4 Aug 2009 16:39:57 -0400
Received: from guinness.s2io.com (localhost [127.0.0.1])
	by barracuda.s2io.com (Spam Firewall) with ESMTP id 965FC206601A
	for <netdev@vger.kernel.org>; Tue,  4 Aug 2009 16:20:47 -0400 (EDT)
Received: from guinness.s2io.com (142-46-210.147.tel-ott.com [142.46.210.147]) by barracuda.s2io.com with ESMTP id VXPUjGB25STZKgFz for <netdev@vger.kernel.org>; Tue, 04 Aug 2009 16:20:47 -0400 (EDT)
Received: from neterion.com ([10.16.18.36])
	by guinness.s2io.com (8.12.6/8.12.6) with ESMTP id n74KKimd013249
	for <netdev@vger.kernel.org>; Tue, 4 Aug 2009 16:20:45 -0400 (EDT)
Content-Disposition: inline
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

The vxge driver will drop a packet in its transmit function if the number
of TxDs available hits 0.  Instead of doing that, simply stop the transmit
queue when transmitting a packet with the last available TxD.

Signed-off-by: Benjamin LaHaise <ben.lahaise@neterion.com>
Signed-off-by: Sreenivasa Honnur <sreenivasa.honnur@neterion.com>
Signed-off-by: Ramkrishna Vepa <ram.vepa@neterion.com>
---
 drivers/net/vxge/vxge-main.c |    6 ++++++
 1 files changed, 6 insertions(+), 0 deletions(-)

diff --git a/drivers/net/vxge/vxge-main.c b/drivers/net/vxge/vxge-main.c
index 7b5402b..7c2241c 100644
--- a/drivers/net/vxge/vxge-main.c
+++ b/drivers/net/vxge/vxge-main.c
@@ -895,6 +895,12 @@ vxge_xmit(struct sk_buff *skb, struct net_device *dev)
 		goto _exit2;
 	}
 
+	/* Last TXD?  Stop tx queue to avoid dropping packets.  TX
+	 * completion will resume the queue.
+	 */
+	if (avail == 1)
+		vxge_stop_tx_queue(fifo);
+
 	status = vxge_hw_fifo_txdl_reserve(fifo_hw, &dtr, &dtr_priv);
 	if (unlikely(status != VXGE_HW_OK)) {
 		vxge_debug_tx(VXGE_ERR,
-- 
1.6.0.6

