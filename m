From: Tom Herbert <tom@herbertland.com>
Subject: [PATCH v3 net-next 5/7] udp: Add UDP flow dissection functions to IPv4 and IPv6
Date: Tue, 18 Oct 2016 10:02:41 -0700
Message-ID: <20161018170243.1369807-6-tom@herbertland.com>
References: <20161018170243.1369807-1-tom@herbertland.com>
Mime-Version: 1.0
Content-Type: text/plain
Cc: <kernel-team@fb.com>
To: <davem@davemloft.net>, <netdev@vger.kernel.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mx0b-00082601.pphosted.com ([67.231.153.30]:60521 "EHLO
        mx0a-00082601.pphosted.com" rhost-flags-OK-OK-OK-FAIL)
        by vger.kernel.org with ESMTP id S1760185AbcJRRC5 (ORCPT
        <rfc822;netdev@vger.kernel.org>); Tue, 18 Oct 2016 13:02:57 -0400
Received: from pps.filterd (m0001303.ppops.net [127.0.0.1])
        by m0001303.ppops.net (8.16.0.17/8.16.0.17) with SMTP id u9IH1N5w023382
        for <netdev@vger.kernel.org>; Tue, 18 Oct 2016 10:02:56 -0700
Received: from mail.thefacebook.com ([199.201.64.23])
        by m0001303.ppops.net with ESMTP id 265jhu9r56-1
        (version=TLSv1 cipher=ECDHE-RSA-AES256-SHA bits=256 verify=NOT)
        for <netdev@vger.kernel.org>; Tue, 18 Oct 2016 10:02:56 -0700
Received: from facebook.com (2401:db00:21:6030:face:0:92:0)     by
 mx-out.facebook.com (10.223.100.99) with ESMTP id
 b62f24ba955411e6a80524be05956610-51ffaa50 for <netdev@vger.kernel.org>;        Tue,
 18 Oct 2016 10:02:54 -0700
In-Reply-To: <20161018170243.1369807-1-tom@herbertland.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Add per protocol offload callbacks for flow_dissect to UDP for
IPv4 and IPv6. The callback functions extract the port number
information and with the packet addresses (given in an argument with
type flow_dissector_key_addrs) it performs a lookup on the UDP
socket. If a socket is found and flow_dissect is set for the
socket then that function is called.

Signed-off-by: Tom Herbert <tom@herbertland.com>
---
 net/ipv4/udp_offload.c | 39 +++++++++++++++++++++++++++++++++++++++
 net/ipv6/udp_offload.c | 40 +++++++++++++++++++++++++++++++++++++++-
 2 files changed, 78 insertions(+), 1 deletion(-)

diff --git a/net/ipv4/udp_offload.c b/net/ipv4/udp_offload.c
index f9333c9..c7753ba 100644
--- a/net/ipv4/udp_offload.c
+++ b/net/ipv4/udp_offload.c
@@ -377,11 +377,50 @@ static int udp4_gro_complete(struct sk_buff *skb, int nhoff)
 	return udp_gro_complete(skb, nhoff, udp4_lib_lookup_skb);
 }
 
+/* Assumes rcu lock is held */
+static int udp4_flow_dissect(const struct sk_buff *skb, void *data, int hlen,
+			     int *nhoff, u8 *ip_proto, __be16 *proto,
+			     struct flow_dissector_key_addrs *key_addrs)
+{
+	u16 _ports[2], *ports;
+	struct net *net;
+	struct sock *sk;
+	int dif = -1;
+
+	/* See if there is a flow dissector in the UDP socket */
+
+	if (skb->dev) {
+		net = dev_net(skb->dev);
+		dif = skb->dev->ifindex;
+	} else if (skb->sk) {
+		net = sock_net(skb->sk);
+	} else {
+		return FLOW_DIS_RET_PASS;
+	}
+
+	ports = __skb_header_pointer(skb, *nhoff, sizeof(_ports),
+				     data, hlen, &_ports);
+	if (!ports)
+		return FLOW_DIS_RET_BAD;
+
+	sk = udp4_lib_lookup_noref(net,
+				   key_addrs->v4addrs.src, ports[0],
+				   key_addrs->v4addrs.dst, ports[1],
+				   dif);
+
+	if (sk && udp_sk(sk)->flow_dissect)
+		return udp_sk(sk)->flow_dissect(sk, skb, data, hlen, nhoff,
+						ip_proto, proto);
+	else
+		return FLOW_DIS_RET_PASS;
+}
+
 static const struct net_offload udpv4_offload = {
 	.callbacks = {
 		.gso_segment = udp4_ufo_fragment,
 		.gro_receive  =	udp4_gro_receive,
 		.gro_complete =	udp4_gro_complete,
+		.flow_dissect = udp4_flow_dissect,
 	},
 };
 
diff --git a/net/ipv6/udp_offload.c b/net/ipv6/udp_offload.c
index ac858c4..12d9a92 100644
--- a/net/ipv6/udp_offload.c
+++ b/net/ipv6/udp_offload.c
@@ -1,5 +1,5 @@
 /*
- *	IPV6 GSO/GRO offload support
+ *	ipv6 gso/gro offload support
  *	Linux INET6 implementation
  *
  *	This program is free software; you can redistribute it and/or
@@ -163,11 +163,49 @@ static int udp6_gro_complete(struct sk_buff *skb, int nhoff)
 	return udp_gro_complete(skb, nhoff, udp6_lib_lookup_skb);
 }
 
+/* Assumes rcu lock is held */
+static int udp6_flow_dissect(const struct sk_buff *skb, void *data, int hlen,
+			     int *nhoff, u8 *ip_proto, __be16 *proto,
+			     const struct flow_dissector_key_addrs *key_addrs)
+{
+	u16 _ports[2], *ports;
+	struct net *net;
+	struct sock *sk;
+	int dif = -1;
+
+	/* See if there is a flow dissector in the UDP socket */
+
+	if (skb->dev) {
+		net = dev_net(skb->dev);
+		dif = skb->dev->ifindex;
+	} else if (skb->sk) {
+		net = sock_net(skb->sk);
+	} else {
+		return FLOW_DIS_RET_PASS;
+	}
+
+	ports = __skb_header_pointer(skb, *nhoff, sizeof(_ports),
+				     data, hlen, &_ports);
+	if (!ports)
+		return FLOW_DIS_RET_BAD;
+
+	sk = udp6_lib_lookup_noref(net,
+				   &key_addrs->v6addrs.src, ports[0],
+				   &key_addrs->v6addrs.dst, ports[1],
+				   dif);
+
+	if (sk && udp_sk(sk)->flow_dissect)
+		return udp_sk(sk)->flow_dissect(sk, skb, data, hlen, nhoff,
+						ip_proto, proto);
+	return FLOW_DIS_RET_PASS;
+}
+
 static const struct net_offload udpv6_offload = {
 	.callbacks = {
 		.gso_segment	=	udp6_ufo_fragment,
 		.gro_receive	=	udp6_gro_receive,
 		.gro_complete	=	udp6_gro_complete,
+		.flow_dissect	=	udp6_flow_dissect,
 	},
 };
 
-- 
2.9.3
