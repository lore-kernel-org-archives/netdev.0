From: Xin Long <lucien.xin@gmail.com>
Subject: [PATCH] ip_tunnel:multicast process cause panic due to skb->_skb_refdst NULL pointer
Date: Mon, 24 Feb 2014 12:35:19 +0800
Message-ID: <1393216519-9066-1-git-send-email-lucien.xin@gmail.com>
Cc: Xin Long <lucien.xin@gmail.com>
To: network dev <netdev@vger.kernel.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-pd0-f171.google.com ([209.85.192.171]:48045 "EHLO
	mail-pd0-f171.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751408AbaBXEff (ORCPT
	<rfc822;netdev@vger.kernel.org>); Sun, 23 Feb 2014 23:35:35 -0500
Received: by mail-pd0-f171.google.com with SMTP id r10so254581pdi.2
        for <netdev@vger.kernel.org>; Sun, 23 Feb 2014 20:35:35 -0800 (PST)
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
