From: Jesse Gross <jesse@nicira.com>
Subject: [PATCH net] udptunnel: Add SKB_GSO_UDP_TUNNEL during gro_complete.
Date: Fri,  7 Nov 2014 12:26:09 -0800
Message-ID: <1415391969-108511-1-git-send-email-jesse@nicira.com>
Cc: netdev@vger.kernel.org, Jay Vosburgh <jay.vosburgh@canonical.com>
To: David Miller <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from na3sys009aog132.obsmtp.com ([74.125.149.250]:36099 "HELO
	na3sys009aog132.obsmtp.com" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with SMTP id S1751569AbaKGU0P (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 7 Nov 2014 15:26:15 -0500
Received: by mail-pd0-f169.google.com with SMTP id y10so3944014pdj.14
        for <netdev@vger.kernel.org>; Fri, 07 Nov 2014 12:26:14 -0800 (PST)
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

When doing GRO processing for UDP tunnels, we never add
SKB_GSO_UDP_TUNNEL to gso_type - only the type of the inner protocol
is added (such as SKB_GSO_TCPV4). The result is that if the packet is
later resegmented we will do GSO but not treat it as a tunnel. This
results in UDP fragmentation and since that is not the original layout
of the skb, a panic in skb_segment().

Reported-by: Jay Vosburgh <jay.vosburgh@canonical.com>
Signed-off-by: Jesse Gross <jesse@nicira.com>
---
This problem occurs back to 3.14 for VXLAN but the FOU portion needs to
be removed for kernels other than the 'net' tree.
---
 drivers/net/vxlan.c      | 2 ++
 include/net/udp_tunnel.h | 9 +++++++++
 net/ipv4/fou.c           | 2 ++
 3 files changed, 13 insertions(+)

diff --git a/drivers/net/vxlan.c b/drivers/net/vxlan.c
index ca30982..cfb892b 100644
--- a/drivers/net/vxlan.c
+++ b/drivers/net/vxlan.c
@@ -621,6 +621,8 @@ static int vxlan_gro_complete(struct sk_buff *skb, int nhoff)
 	int vxlan_len  = sizeof(struct vxlanhdr) + sizeof(struct ethhdr);
 	int err = -ENOSYS;
 
+	udp_tunnel_gro_complete(skb, nhoff);
+
 	eh = (struct ethhdr *)(skb->data + nhoff + sizeof(struct vxlanhdr));
 	type = eh->h_proto;
 
diff --git a/include/net/udp_tunnel.h b/include/net/udp_tunnel.h
index a47790b..2a50a70 100644
--- a/include/net/udp_tunnel.h
+++ b/include/net/udp_tunnel.h
@@ -100,6 +100,15 @@ static inline struct sk_buff *udp_tunnel_handle_offloads(struct sk_buff *skb,
 	return iptunnel_handle_offloads(skb, udp_csum, type);
 }
 
+static inline void udp_tunnel_gro_complete(struct sk_buff *skb, int nhoff)
+{
+	struct udphdr *uh;
+
+	uh = (struct udphdr *)(skb->data + nhoff - sizeof(struct udphdr));
+	skb_shinfo(skb)->gso_type |= uh->check ?
+				SKB_GSO_UDP_TUNNEL_CSUM : SKB_GSO_UDP_TUNNEL;
+}
+
 static inline void udp_tunnel_encap_enable(struct socket *sock)
 {
 #if IS_ENABLED(CONFIG_IPV6)
diff --git a/net/ipv4/fou.c b/net/ipv4/fou.c
index 32e7892..606c520 100644
--- a/net/ipv4/fou.c
+++ b/net/ipv4/fou.c
@@ -133,6 +133,8 @@ static int fou_gro_complete(struct sk_buff *skb, int nhoff)
 	int err = -ENOSYS;
 	const struct net_offload **offloads;
 
+	udp_tunnel_gro_complete(skb, nhoff);
+
 	rcu_read_lock();
 	offloads = NAPI_GRO_CB(skb)->is_ipv6 ? inet6_offloads : inet_offloads;
 	ops = rcu_dereference(offloads[proto]);
-- 
1.9.1
