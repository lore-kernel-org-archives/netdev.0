From: Stephen Hemminger <stephen@networkplumber.org>
Subject: [PATCH 5/5] netvsc: replace netdev_alloc_skb_ip_align with napi_alloc_skb
Date: Mon, 27 Feb 2017 10:26:51 -0800
Message-ID: <20170227182651.3956-6-sthemmin@microsoft.com>
References: <20170227182651.3956-1-sthemmin@microsoft.com>
Cc: netdev@vger.kernel.org, Stephen Hemminger <sthemmin@microsoft.com>
To: davem@davemloft.net
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-pg0-f47.google.com ([74.125.83.47]:33884 "EHLO
        mail-pg0-f47.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1751039AbdB0SgD (ORCPT
        <rfc822;netdev@vger.kernel.org>); Mon, 27 Feb 2017 13:36:03 -0500
Received: by mail-pg0-f47.google.com with SMTP id p5so23717406pga.1
        for <netdev@vger.kernel.org>; Mon, 27 Feb 2017 10:34:25 -0800 (PST)
In-Reply-To: <20170227182651.3956-1-sthemmin@microsoft.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Gives potential performance gain.

Signed-off-by: Stephen Hemminger <sthemmin@microsoft.com>
---
 drivers/net/hyperv/netvsc_drv.c | 6 ++++--
 1 file changed, 4 insertions(+), 2 deletions(-)

diff --git a/drivers/net/hyperv/netvsc_drv.c b/drivers/net/hyperv/netvsc_drv.c
index 6dcd1f08b834..f95d686b7957 100644
--- a/drivers/net/hyperv/netvsc_drv.c
+++ b/drivers/net/hyperv/netvsc_drv.c
@@ -589,13 +589,14 @@ void netvsc_linkstatus_callback(struct hv_device *device_obj,
 }
 
 static struct sk_buff *netvsc_alloc_recv_skb(struct net_device *net,
+					     struct napi_struct *napi,
 					     const struct ndis_tcp_ip_checksum_info *csum_info,
 					     const struct ndis_pkt_8021q_info *vlan,
 					     void *data, u32 buflen)
 {
 	struct sk_buff *skb;
 
-	skb = netdev_alloc_skb_ip_align(net, buflen);
+	skb = napi_alloc_skb(napi, buflen);
 	if (!skb)
 		return skb;
 
@@ -664,7 +665,8 @@ int netvsc_recv_callback(struct net_device *net,
 		net = vf_netdev;
 
 	/* Allocate a skb - TODO direct I/O to pages? */
-	skb = netvsc_alloc_recv_skb(net, csum_info, vlan, data, len);
+	skb = netvsc_alloc_recv_skb(net, &nvchan->napi,
+				    csum_info, vlan, data, len);
 	if (unlikely(!skb)) {
 		++net->stats.rx_dropped;
 		rcu_read_unlock();
-- 
2.11.0
