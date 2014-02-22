From: lucien <lucien.xin@gmail.com>
Subject: [PATCH net-next] ip_tunnel:multicast process cause panic due to skb->_skb_refdst
 NULL pointer
Date: Sat, 22 Feb 2014 16:43:26 +0800
Message-ID: <5308632E.10101@gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1; format=flowed
Content-Transfer-Encoding: 7bit
Cc: davem@davemloft.net, kuznet@ms2.inr.ac.ru, jmorris@namei.org,
	yoshfuji@linux-ipv6.org, kaber@trash.net
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-pa0-f48.google.com ([209.85.220.48]:56876 "EHLO
	mail-pa0-f48.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751009AbaBVInv (ORCPT
	<rfc822;netdev@vger.kernel.org>); Sat, 22 Feb 2014 03:43:51 -0500
Received: by mail-pa0-f48.google.com with SMTP id kx10so4460861pab.7
        for <netdev@vger.kernel.org>; Sat, 22 Feb 2014 00:43:51 -0800 (PST)
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

when ip_tunnel process multicast packets, it may check if the packet is
looped back packet though 'rt_is_output_route(skb_rtable(skb))' in
ip_tunnel_rcv(), but before that , skb->_skb_refdst has been dropped in
iptunnel_pull_header(), so which leads to a panic.

fix the bug: https://bugzilla.kernel.org/show_bug.cgi?id=70681

diff --git a/net/ipv4/ip_tunnel_core.c b/net/ipv4/ip_tunnel_core.c
index 6156f4e..88b08aa 100644
--- a/net/ipv4/ip_tunnel_core.c
+++ b/net/ipv4/ip_tunnel_core.c
@@ -108,7 +108,6 @@ int iptunnel_pull_header(struct sk_buff *skb, int 
hdr_len, __be16 inner_proto)
         nf_reset(skb);
         secpath_reset(skb);
         skb_clear_hash_if_not_l4(skb);
-       skb_dst_drop(skb);
         skb->vlan_tci = 0;
         skb_set_queue_mapping(skb, 0);
         skb->pkt_type = PACKET_HOST;
