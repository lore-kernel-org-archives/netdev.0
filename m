From: Tom Herbert <tom@herbertland.com>
Subject: [PATCH net-next 4/5] udp: UDP tunnel flow dissection infrastructure
Date: Wed, 12 Oct 2016 16:25:46 -0700
Message-ID: <20161012232547.2383961-5-tom@herbertland.com>
References: <20161012232547.2383961-1-tom@herbertland.com>
Mime-Version: 1.0
Content-Type: text/plain
Cc: <kernel-team@fb.com>
To: <davem@davemloft.net>, <netdev@vger.kernel.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mx0b-00082601.pphosted.com ([67.231.153.30]:58935 "EHLO
        mx0a-00082601.pphosted.com" rhost-flags-OK-OK-OK-FAIL)
        by vger.kernel.org with ESMTP id S933409AbcJLX0B (ORCPT
        <rfc822;netdev@vger.kernel.org>); Wed, 12 Oct 2016 19:26:01 -0400
Received: from pps.filterd (m0001303.ppops.net [127.0.0.1])
        by m0001303.ppops.net (8.16.0.17/8.16.0.17) with SMTP id u9CNLXqa000892
        for <netdev@vger.kernel.org>; Wed, 12 Oct 2016 16:26:00 -0700
Received: from mail.thefacebook.com ([199.201.64.23])
        by m0001303.ppops.net with ESMTP id 2615d3fygm-2
        (version=TLSv1 cipher=ECDHE-RSA-AES256-SHA bits=256 verify=NOT)
        for <netdev@vger.kernel.org>; Wed, 12 Oct 2016 16:26:00 -0700
Received: from facebook.com (2401:db00:21:6030:face:0:92:0)     by
 mx-out.facebook.com (10.103.99.99) with ESMTP  id
 3a50d48690d311e69a850002c9dfb610-35de9a50 for <netdev@vger.kernel.org>;        Wed,
 12 Oct 2016 16:25:57 -0700
In-Reply-To: <20161012232547.2383961-1-tom@herbertland.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Add infrastructure to allow UDP tunnels to setup flow dissection.

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
