From: Stephen Hemminger <shemminger@vyatta.com>
Subject: [PATCH 1/2] tun: reserves space for network in skb
Date: Wed, 08 Jun 2011 17:33:07 -0700
Message-ID: <20110609003321.904295399@vyatta.com>
References: <20110609003306.651532958@vyatta.com>
Cc: netdev@vger.kernel.org
To: "David S. Miller" <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from suva.vyatta.com ([76.74.103.44]:34274 "EHLO suva.vyatta.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1751481Ab1FIBQ2 (ORCPT <rfc822;netdev@vger.kernel.org>);
	Wed, 8 Jun 2011 21:16:28 -0400
Content-Disposition: inline; filename=tun-tap-pad.patch
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

The tun driver allocates skb's to hold data from user and then passes
the data into the network stack as received data. Most network devices
allocate the receive skb with routines like dev_alloc_skb() that reserves
additional space for use by network protocol stack but tun does not.

Because of the lack of padding, when the packet is passed through bridge
netfilter a new skb has to be allocated.

Signed-off-by: Stephen Hemminger <shemminger@vyatta.com>

--- a/drivers/net/tun.c	2011-05-13 12:37:11.619318207 -0700
+++ b/drivers/net/tun.c	2011-05-13 16:43:25.643040523 -0700
@@ -584,7 +584,7 @@ static __inline__ ssize_t tun_get_user(s
 {
 	struct tun_pi pi = { 0, cpu_to_be16(ETH_P_IP) };
 	struct sk_buff *skb;
-	size_t len = count, align = 0;
+	size_t len = count, align = NET_SKB_PAD;
 	struct virtio_net_hdr gso = { 0 };
 	int offset = 0;
 
@@ -614,7 +614,7 @@ static __inline__ ssize_t tun_get_user(s
 	}
 
 	if ((tun->flags & TUN_TYPE_MASK) == TUN_TAP_DEV) {
-		align = NET_IP_ALIGN;
+		align += NET_IP_ALIGN;
 		if (unlikely(len < ETH_HLEN ||
 			     (gso.hdr_len && gso.hdr_len < ETH_HLEN)))
 			return -EINVAL;


