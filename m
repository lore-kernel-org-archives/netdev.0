From: Tom Herbert <tom@herbertland.com>
Subject: [PATCH v3 net-next 6/7] udp: UDP tunnel flow dissection infrastructure
Date: Tue, 18 Oct 2016 10:02:42 -0700
Message-ID: <20161018170243.1369807-7-tom@herbertland.com>
References: <20161018170243.1369807-1-tom@herbertland.com>
Mime-Version: 1.0
Content-Type: text/plain
Cc: <kernel-team@fb.com>
To: <davem@davemloft.net>, <netdev@vger.kernel.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mx0a-00082601.pphosted.com ([67.231.145.42]:42527 "EHLO
        mx0a-00082601.pphosted.com" rhost-flags-OK-OK-OK-OK)
        by vger.kernel.org with ESMTP id S1760186AbcJRRC5 (ORCPT
        <rfc822;netdev@vger.kernel.org>); Tue, 18 Oct 2016 13:02:57 -0400
Received: from pps.filterd (m0044010.ppops.net [127.0.0.1])
        by mx0a-00082601.pphosted.com (8.16.0.17/8.16.0.17) with SMTP id u9IH04pO011536
        for <netdev@vger.kernel.org>; Tue, 18 Oct 2016 10:02:56 -0700
Received: from mail.thefacebook.com ([199.201.64.23])
        by mx0a-00082601.pphosted.com with ESMTP id 265n2p8yy4-1
        (version=TLSv1 cipher=ECDHE-RSA-AES256-SHA bits=256 verify=NOT)
        for <netdev@vger.kernel.org>; Tue, 18 Oct 2016 10:02:56 -0700
Received: from facebook.com (2401:db00:21:6030:face:0:92:0)     by
 mx-out.facebook.com (10.223.100.99) with ESMTP id
 b6c98e56955411e6b11b24be05956610-4d3fba50 for <netdev@vger.kernel.org>;        Tue,
 18 Oct 2016 10:02:55 -0700
In-Reply-To: <20161018170243.1369807-1-tom@herbertland.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Add infrastructure to allow UDP tunnels to setup flow dissecion.

Signed-off-by: Tom Herbert <tom@herbertland.com>
---
 include/net/udp_tunnel.h | 5 +++++
 net/ipv4/udp_tunnel.c    | 5 +++++
 2 files changed, 10 insertions(+)

diff --git a/include/net/udp_tunnel.h b/include/net/udp_tunnel.h
index 02c5be0..81d2584 100644
--- a/include/net/udp_tunnel.h
+++ b/include/net/udp_tunnel.h
@@ -69,6 +69,10 @@ typedef struct sk_buff **(*udp_tunnel_gro_receive_t)(struct sock *sk,
 						     struct sk_buff *skb);
 typedef int (*udp_tunnel_gro_complete_t)(struct sock *sk, struct sk_buff *skb,
 					 int nhoff);
+typedef int (*udp_tunnel_flow_dissect_t)(struct sock *sk,
+					 const struct sk_buff *skb,
+					 void *data, int hlen, int *nhoff,
+					 u8 *ip_proto, __be16 *proto);
 
 struct udp_tunnel_sock_cfg {
 	void *sk_user_data;     /* user data used by encap_rcv call back */
@@ -78,6 +82,7 @@ struct udp_tunnel_sock_cfg {
 	udp_tunnel_encap_destroy_t encap_destroy;
 	udp_tunnel_gro_receive_t gro_receive;
 	udp_tunnel_gro_complete_t gro_complete;
+	udp_tunnel_flow_dissect_t flow_dissect;
 };
 
 /* Setup the given (UDP) sock to receive UDP encapsulated packets */
diff --git a/net/ipv4/udp_tunnel.c b/net/ipv4/udp_tunnel.c
index 58bd39f..4459288 100644
--- a/net/ipv4/udp_tunnel.c
+++ b/net/ipv4/udp_tunnel.c
@@ -72,6 +72,11 @@ void setup_udp_tunnel_sock(struct net *net, struct socket *sock,
 	udp_sk(sk)->gro_receive = cfg->gro_receive;
 	udp_sk(sk)->gro_complete = cfg->gro_complete;
 
+	if (cfg->flow_dissect) {
+		udp_sk(sk)->flow_dissect = cfg->flow_dissect;
+		udp_flow_dissect_enable();
+	}
+
 	udp_tunnel_encap_enable(sock);
 }
 EXPORT_SYMBOL_GPL(setup_udp_tunnel_sock);
-- 
2.9.3
