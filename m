From: David Ahern <dsahern@gmail.com>
Subject: [PATCH] net: rocker: Add basic netdev counters - v2
Date: Fri, 16 Jan 2015 14:22:29 -0700
Message-ID: <1421443349-77718-1-git-send-email-dsahern@gmail.com>
Cc: David Ahern <dsahern@gmail.com>, Scott Feldman <sfeldma@gmail.com>,
	Jiri Pirko <jiri@resnulli.us>
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-pd0-f176.google.com ([209.85.192.176]:57119 "EHLO
	mail-pd0-f176.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752251AbbAPVWd (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 16 Jan 2015 16:22:33 -0500
Received: by mail-pd0-f176.google.com with SMTP id r10so24903242pdi.7
        for <netdev@vger.kernel.org>; Fri, 16 Jan 2015 13:22:33 -0800 (PST)
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Add packet and byte counters for RX and TX paths.

$ ifconfig eth1
eth1: flags=4163<UP,BROADCAST,RUNNING,MULTICAST>  mtu 1500
        inet6 fe80::5054:ff:fe12:3501  prefixlen 64  scopeid 0x20<link>
        ether 52:54:00:12:35:01  txqueuelen 1000  (Ethernet)
        RX packets 63  bytes 15813 (15.4 KiB)
        RX errors 1  dropped 0  overruns 0  frame 0
        TX packets 79  bytes 17991 (17.5 KiB)
        TX errors 7  dropped 0 overruns 0  carrier 0  collisions 0

Rx / Tx errors tested by injecting faults in qemu's hardware model for Rocker.

v2:
- moved counter locations to avoid potential use after free per Florian's comment

Signed-off-by: David Ahern <dsahern@gmail.com>
Cc: Scott Feldman <sfeldma@gmail.com>
Cc: Jiri Pirko <jiri@resnulli.us>
---
 drivers/net/ethernet/rocker/rocker.c | 21 ++++++++++++++++++++-
 1 file changed, 20 insertions(+), 1 deletion(-)

diff --git a/drivers/net/ethernet/rocker/rocker.c b/drivers/net/ethernet/rocker/rocker.c
index c5548164d1a8..f9daf67117b9 100644
--- a/drivers/net/ethernet/rocker/rocker.c
+++ b/drivers/net/ethernet/rocker/rocker.c
@@ -3915,6 +3915,8 @@ static netdev_tx_t rocker_port_xmit(struct sk_buff *skb, struct net_device *dev)
 	rocker_tlv_nest_cancel(desc_info, frags);
 out:
 	dev_kfree_skb(skb);
+	dev->stats.tx_dropped++;
+
 	return NETDEV_TX_OK;
 }
 
@@ -4238,12 +4240,22 @@ static int rocker_port_poll_tx(struct napi_struct *napi, int budget)
 
 	/* Cleanup tx descriptors */
 	while ((desc_info = rocker_desc_tail_get(&rocker_port->tx_ring))) {
+		struct sk_buff *skb;
+
 		err = rocker_desc_err(desc_info);
 		if (err && net_ratelimit())
 			netdev_err(rocker_port->dev, "tx desc received with err %d\n",
 				   err);
 		rocker_tx_desc_frags_unmap(rocker_port, desc_info);
-		dev_kfree_skb_any(rocker_desc_cookie_ptr_get(desc_info));
+
+		skb = rocker_desc_cookie_ptr_get(desc_info);
+		if (err == 0) {
+			rocker_port->dev->stats.tx_packets++;
+			rocker_port->dev->stats.tx_bytes += skb->len;
+		} else
+			rocker_port->dev->stats.tx_errors++;
+
+		dev_kfree_skb_any(skb);
 		credits++;
 	}
 
@@ -4276,6 +4288,10 @@ static int rocker_port_rx_proc(struct rocker *rocker,
 	rx_len = rocker_tlv_get_u16(attrs[ROCKER_TLV_RX_FRAG_LEN]);
 	skb_put(skb, rx_len);
 	skb->protocol = eth_type_trans(skb, rocker_port->dev);
+
+	rocker_port->dev->stats.rx_packets++;
+	rocker_port->dev->stats.rx_bytes += skb->len;
+
 	netif_receive_skb(skb);
 
 	return rocker_dma_rx_ring_skb_alloc(rocker, rocker_port, desc_info);
@@ -4309,6 +4325,9 @@ static int rocker_port_poll_rx(struct napi_struct *napi, int budget)
 				netdev_err(rocker_port->dev, "rx processing failed with err %d\n",
 					   err);
 		}
+		if (err)
+			rocker_port->dev->stats.rx_errors++;
+
 		rocker_desc_gen_clear(desc_info);
 		rocker_desc_head_set(rocker, &rocker_port->rx_ring, desc_info);
 		credits++;
-- 
1.9.3 (Apple Git-50)
