From: Nikolay Aleksandrov <razor@blackwall.org>
Subject: [PATCH net-next] vrf: plug skb leaks
Date: Wed, 19 Aug 2015 06:12:29 +0300
Message-ID: <1439953949-23736-1-git-send-email-razor@blackwall.org>
Cc: dsa@cumulusnetworks.com, shm@cumulusnetworks.com,
	davem@davemloft.net,
	Nikolay Aleksandrov <nikolay@cumulusnetworks.com>
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-wi0-f181.google.com ([209.85.212.181]:35472 "EHLO
	mail-wi0-f181.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752945AbbHSOrH (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 19 Aug 2015 10:47:07 -0400
Received: by wicne3 with SMTP id ne3so122738924wic.0
        for <netdev@vger.kernel.org>; Wed, 19 Aug 2015 07:47:06 -0700 (PDT)
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Nikolay Aleksandrov <nikolay@cumulusnetworks.com>

Currently whenever a packet different from ETH_P_IP is sent through the
VRF device it is leaked so plug the leaks and properly drop these
packets.

Signed-off-by: Nikolay Aleksandrov <nikolay@cumulusnetworks.com>
---
 drivers/net/vrf.c | 13 ++++++++++---
 1 file changed, 10 insertions(+), 3 deletions(-)

diff --git a/drivers/net/vrf.c b/drivers/net/vrf.c
index ed208317cbb5..4aa06450fafa 100644
--- a/drivers/net/vrf.c
+++ b/drivers/net/vrf.c
@@ -97,6 +97,12 @@ static bool is_ip_rx_frame(struct sk_buff *skb)
 	return false;
 }
 
+static void vrf_tx_error(struct net_device *vrf_dev, struct sk_buff *skb)
+{
+	vrf_dev->stats.tx_errors++;
+	kfree_skb(skb);
+}
+
 /* note: already called with rcu_read_lock */
 static rx_handler_result_t vrf_handle_frame(struct sk_buff **pskb)
 {
@@ -149,7 +155,8 @@ static struct rtnl_link_stats64 *vrf_get_stats64(struct net_device *dev,
 static netdev_tx_t vrf_process_v6_outbound(struct sk_buff *skb,
 					   struct net_device *dev)
 {
-	return 0;
+	vrf_tx_error(dev, skb);
+	return NET_XMIT_DROP;
 }
 
 static int vrf_send_v4_prep(struct sk_buff *skb, struct flowi4 *fl4,
@@ -206,8 +213,7 @@ static netdev_tx_t vrf_process_v4_outbound(struct sk_buff *skb,
 out:
 	return ret;
 err:
-	vrf_dev->stats.tx_errors++;
-	kfree_skb(skb);
+	vrf_tx_error(vrf_dev, skb);
 	goto out;
 }
 
@@ -219,6 +225,7 @@ static netdev_tx_t is_ip_tx_frame(struct sk_buff *skb, struct net_device *dev)
 	case htons(ETH_P_IPV6):
 		return vrf_process_v6_outbound(skb, dev);
 	default:
+		vrf_tx_error(dev, skb);
 		return NET_XMIT_DROP;
 	}
 }
-- 
2.4.3
