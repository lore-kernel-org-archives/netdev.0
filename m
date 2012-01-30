From: Wei Yongjun <weiyj.lk@gmail.com>
Subject: [PATCH] net/hyperv: fix the issue that large packets be dropped by bridge
Date: Mon, 30 Jan 2012 16:12:45 +0800
Message-ID: <CAPgLHd-Z2B88ZxCKmKuRTcndJXt2y3N00MazBxD7aXKUVhywqg@mail.gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1
Cc: haiyangz@microsoft.com, kys@microsoft.com, netdev@vger.kernel.org
To: davem@davemloft.net
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-qy0-f174.google.com ([209.85.216.174]:58559 "EHLO
	mail-qy0-f174.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752642Ab2A3IMq (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 30 Jan 2012 03:12:46 -0500
Received: by qcsg15 with SMTP id g15so2065938qcs.19
        for <netdev@vger.kernel.org>; Mon, 30 Jan 2012 00:12:45 -0800 (PST)
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Wei Yongjun <yongjun_wei@trendmicro.com.cn>

The packets with size larger than 1452 will be dropped by bridge
which with two hyperv netdevice ports. This cause by hyperv netvsc
driver always copy the trailer padding to the data packet, and then
the skb received from netdevice may include wrong skb->len (20 bytes
larger than the real size normally). The captured packet may like
this:

  Ethernet II, Src: Microsof_00:00:07 (00:15:5d:00:00:07),
               Dst: HewlettP_00:00:4e (00:1f:29:00:00:4e)
    Destination: HewlettP_e6:00:4e (00:1f:29:00:00:4e)
    Source: Microsof_f6:6d:07 (00:15:5d:f6:6d:07)
    Type: IP (0x0800)
    Trailer: 1415161718191A1B1C1D1E1F20212223
    Frame check sequence: 0x24252627 [incorrect, should be 0x7c2e5a5e]

The following command help to reproduction it, and the ping ICMP
packets will be dropped by bridge.
  $ ping ip -s 1453

This patch fixed it by removing the trailer padding from the data
packet.

Signed-off-by: Wei Yongjun <yongjun_wei@trendmicro.com.cn>
---
 drivers/net/hyperv/rndis_filter.c |   19 +++++++++++++++++++
 1 files changed, 19 insertions(+), 0 deletions(-)

diff --git a/drivers/net/hyperv/rndis_filter.c b/drivers/net/hyperv/rndis_filter.c
index da181f9..7568984 100644
--- a/drivers/net/hyperv/rndis_filter.c
+++ b/drivers/net/hyperv/rndis_filter.c
@@ -321,6 +321,25 @@ static void rndis_filter_receive_data(struct rndis_device *dev,
 	data_offset = RNDIS_HEADER_SIZE + rndis_pkt->data_offset;
 
 	pkt->total_data_buflen -= data_offset;
+
+	/*
+	 * Make sure we got a valid packet message, now total_data_buflen
+	 * should be the data packet size plus the trailer padding size
+	 */
+	if (pkt->total_data_buflen < rndis_pkt->data_len) {
+		netdev_err(dev->net_dev->ndev, "incoming packet message "
+			   "buffer overflow detected (got %u, min %u)"
+			   "...dropping this message!\n",
+			   pkt->total_data_buflen, rndis_pkt->data_len);
+		return;
+	}
+
+	/*
+	 * Remove the rndis trailer padding from packet message
+	 * rndis_pkt->data_len tell us the real data length, we only copy
+	 * the data packet to the stack, without the rndis trailer padding
+	 */
+	pkt->total_data_buflen = rndis_pkt->data_len;
 	pkt->data = (void *)((unsigned long)pkt->data + data_offset);
 
 	pkt->is_data_pkt = true;
-- 
1.7.1
