From: Sridhar Samudrala <sri@us.ibm.com>
Subject: [PATCH net-next-2.6] net: Handle vlan packets in skb_gso_segment()
Date: Mon, 25 Jan 2010 13:16:34 -0800
Message-ID: <1264454194.28852.130.camel@w-sridhar.beaverton.ibm.com>
Mime-Version: 1.0
Content-Type: text/plain
Content-Transfer-Encoding: 7bit
Cc: netdev <netdev@vger.kernel.org>
To: David Miller <davem@davemloft.net>,
	Herbert Xu <herbert@gondor.apana.org.au>
Return-path: <netdev-owner@vger.kernel.org>
Received: from e35.co.us.ibm.com ([32.97.110.153]:52635 "EHLO
	e35.co.us.ibm.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1750846Ab0AYVQp (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 25 Jan 2010 16:16:45 -0500
Received: from d03relay02.boulder.ibm.com (d03relay02.boulder.ibm.com [9.17.195.227])
	by e35.co.us.ibm.com (8.14.3/8.13.1) with ESMTP id o0PL2lRU023675
	for <netdev@vger.kernel.org>; Mon, 25 Jan 2010 14:02:47 -0700
Received: from d03av06.boulder.ibm.com (d03av06.boulder.ibm.com [9.17.195.245])
	by d03relay02.boulder.ibm.com (8.13.8/8.13.8/NCO v9.1) with ESMTP id o0PLGdo9218794
	for <netdev@vger.kernel.org>; Mon, 25 Jan 2010 14:16:40 -0700
Received: from d03av06.boulder.ibm.com (loopback [127.0.0.1])
	by d03av06.boulder.ibm.com (8.14.3/8.13.1/NCO v10.0 AVout) with ESMTP id o0PLIhXL027197
	for <netdev@vger.kernel.org>; Mon, 25 Jan 2010 14:18:44 -0700
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Handle VLAN packets in skb_gso_segment(). Currently, when large
VLAN packets are sent via virtio_net on guest and tun on host, 
skb_gso_segment() fails with EPROTONOSUPPORT.

Signed-off-by: Sridhar Samudrala <sri@us.ibm.com>

diff --git a/net/core/dev.c b/net/core/dev.c
--- a/net/core/dev.c
+++ b/net/core/dev.c
@@ -1672,6 +1672,12 @@ struct sk_buff *skb_gso_segment(struct sk_buff *skb, int features)
 
	skb_reset_mac_header(skb);
	skb->mac_len = skb->network_header - skb->mac_header;
+	if (ntohs(type) == ETH_P_8021Q) {
+		skb->protocol = vlan_eth_hdr(skb)->h_vlan_encapsulated_proto;
+		type = skb->protocol;
+		skb->mac_len += VLAN_HLEN;
+		skb_set_network_header(skb, skb->mac_len);
+	}
	__skb_pull(skb, skb->mac_len);
 
	if (unlikely(skb->ip_summed != CHECKSUM_PARTIAL)) {



