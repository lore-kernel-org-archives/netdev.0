From: Paolo Abeni <pabeni@redhat.com>
Subject: [PATCH net] net/tunnel: set inner protocol in network gro hooks
Date: Tue,  7 Mar 2017 18:33:31 +0100
Message-ID: <4cfee33672b0fd2b1db66d603574a93e76e118b3.1488907722.git.pabeni@redhat.com>
Cc: "David S. Miller" <davem@davemloft.net>,
        Alexander Duyck <alexander.duyck@gmail.com>,
        Tom Herbert <tom@herbertland.com>
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mx1.redhat.com ([209.132.183.28]:38364 "EHLO mx1.redhat.com"
        rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
        id S932583AbdCGRnC (ORCPT <rfc822;netdev@vger.kernel.org>);
        Tue, 7 Mar 2017 12:43:02 -0500
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

The gso code of several tunnels type (gre and udp tunnels)
takes for granted that the skb->inner_protocol is properly
initialized and drops the packet elsewhere.

On the forwarding path no one is initializing such field,
so gro encapsulated packets are dropped on forward.

Since commit 38720352412a ("gre: Use inner_proto to obtain
inner header protocol"), this can be reproduced when the
encapsulated packets use gre as the tunneling protocol.

The issue happens also with vxlan and geneve tunnels since
commit 8bce6d7d0d1e ("udp: Generalize skb_udp_segment"), if the
forwarding host's ingress nic has h/w offload for such tunnel
and a vxlan/geneve device is configured on top of it, regardless
of the configured peer address and vni.

To address the issue, this change initialize the inner_protocol
field for encapsulated packets in both ipv4 and ipv6 gro complete
callbacks.

Fixes: 38720352412a ("gre: Use inner_proto to obtain inner header protocol")
Fixes: 8bce6d7d0d1e ("udp: Generalize skb_udp_segment")
Signed-off-by: Paolo Abeni <pabeni@redhat.com>
---
 net/ipv4/af_inet.c     | 4 +++-
 net/ipv6/ip6_offload.c | 4 +++-
 2 files changed, 6 insertions(+), 2 deletions(-)

diff --git a/net/ipv4/af_inet.c b/net/ipv4/af_inet.c
index 602d40f..5091f46 100644
--- a/net/ipv4/af_inet.c
+++ b/net/ipv4/af_inet.c
@@ -1487,8 +1487,10 @@ int inet_gro_complete(struct sk_buff *skb, int nhoff)
 	int proto = iph->protocol;
 	int err = -ENOSYS;
 
-	if (skb->encapsulation)
+	if (skb->encapsulation) {
+		skb_set_inner_protocol(skb, cpu_to_be16(ETH_P_IP));
 		skb_set_inner_network_header(skb, nhoff);
+	}
 
 	csum_replace2(&iph->check, iph->tot_len, newlen);
 	iph->tot_len = newlen;
diff --git a/net/ipv6/ip6_offload.c b/net/ipv6/ip6_offload.c
index 0838e6d..93e58a5 100644
--- a/net/ipv6/ip6_offload.c
+++ b/net/ipv6/ip6_offload.c
@@ -294,8 +294,10 @@ static int ipv6_gro_complete(struct sk_buff *skb, int nhoff)
 	struct ipv6hdr *iph = (struct ipv6hdr *)(skb->data + nhoff);
 	int err = -ENOSYS;
 
-	if (skb->encapsulation)
+	if (skb->encapsulation) {
+		skb_set_inner_protocol(skb, cpu_to_be16(ETH_P_IPV6));
 		skb_set_inner_network_header(skb, nhoff);
+	}
 
 	iph->payload_len = htons(skb->len - nhoff - sizeof(*iph));
 
-- 
2.9.3
