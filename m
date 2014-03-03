From: Xin Long <lucien.xin@gmail.com>
Subject: [PATCH] ip_tunnel:multicast process cause panic due to skb->_skb_refdst NULL pointer
Date: Mon,  3 Mar 2014 20:18:36 +0800
Message-ID: <1393849116-3940-1-git-send-email-lucien.xin@gmail.com>
Cc: Xin Long <lucien.xin@gmail.com>
To: network dev <netdev@vger.kernel.org>,
	Hannes Frederic Sowa <hannes@stressinduktion.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-pb0-f50.google.com ([209.85.160.50]:61526 "EHLO
	mail-pb0-f50.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1753706AbaCCMSr (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 3 Mar 2014 07:18:47 -0500
Received: by mail-pb0-f50.google.com with SMTP id md12so3690929pbc.23
        for <netdev@vger.kernel.org>; Mon, 03 Mar 2014 04:18:47 -0800 (PST)
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

when ip_tunnel process multicast packets, it may check if the packet is looped
back packet though 'rt_is_output_route(skb_rtable(skb))' in ip_tunnel_rcv(),
but before that , skb->_skb_refdst has been dropped in iptunnel_pull_header(),
so which leads to a panic.

fix the bug: https://bugzilla.kernel.org/show_bug.cgi?id=70681

Signed-off-by: Xin Long <lucien.xin@gmail.com>
---
 net/ipv4/ip_tunnel_core.c | 1 -
 1 file changed, 1 deletion(-)

diff --git a/net/ipv4/ip_tunnel_core.c b/net/ipv4/ip_tunnel_core.c
index 6156f4e..88b08aa 100644
--- a/net/ipv4/ip_tunnel_core.c
+++ b/net/ipv4/ip_tunnel_core.c
@@ -108,7 +108,6 @@ int iptunnel_pull_header(struct sk_buff *skb, int hdr_len, __be16 inner_proto)
 	nf_reset(skb);
 	secpath_reset(skb);
 	skb_clear_hash_if_not_l4(skb);
-	skb_dst_drop(skb);
 	skb->vlan_tci = 0;
 	skb_set_queue_mapping(skb, 0);
 	skb->pkt_type = PACKET_HOST;
-- 
1.8.3.1
