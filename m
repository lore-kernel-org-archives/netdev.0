From: Tom Herbert <tom@herbertland.com>
Subject: [PATCH RFC 5/9] udp: Add socket based GRO and fast receive encap to tunnel config
Date: Wed, 23 Mar 2016 15:36:54 -0700
Message-ID: <1458772618-845742-6-git-send-email-tom@herbertland.com>
References: <1458772618-845742-1-git-send-email-tom@herbertland.com>
Mime-Version: 1.0
Content-Type: text/plain
Cc: <kernel-team@fb.com>
To: <davem@davemloft.net>, <netdev@vger.kernel.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mx0b-00082601.pphosted.com ([67.231.153.30]:50779 "EHLO
	mx0b-00082601.pphosted.com" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with ESMTP id S1751395AbcCWWj3 (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 23 Mar 2016 18:39:29 -0400
Received: from pps.filterd (m0001255.ppops.net [127.0.0.1])
	by mx0b-00082601.pphosted.com (8.16.0.11/8.16.0.11) with SMTP id u2NMaDqS002940
	for <netdev@vger.kernel.org>; Wed, 23 Mar 2016 15:39:27 -0700
Received: from mail.thefacebook.com ([199.201.64.23])
	by mx0b-00082601.pphosted.com with ESMTP id 21v01d17ys-18
	(version=TLSv1 cipher=AES128-SHA bits=128 verify=NOT)
	for <netdev@vger.kernel.org>; Wed, 23 Mar 2016 15:39:25 -0700
Received: from devbig284.prn2.facebook.com (10.35.15.32)	by
 mx-out.facebook.com (10.212.236.87) with ESMTP	id
 ca323ee0f14711e5ae670002c9521c9e-781fb3f0 for <netdev@vger.kernel.org>;	Wed,
 23 Mar 2016 15:37:14 -0700
In-Reply-To: <1458772618-845742-1-git-send-email-tom@herbertland.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Add gro_receive, gro_complete and encap_fast to
struct udp_tunnel_sock_cfg.

Signed-off-by: Tom Herbert <tom@herbertland.com>
---
 include/net/udp_tunnel.h | 8 ++++++++
 net/ipv4/udp_tunnel.c    | 3 +++
 2 files changed, 11 insertions(+)

diff --git a/include/net/udp_tunnel.h b/include/net/udp_tunnel.h
index b831140..3c534e7 100644
--- a/include/net/udp_tunnel.h
+++ b/include/net/udp_tunnel.h
@@ -64,13 +64,21 @@ static inline int udp_sock_create(struct net *net,
 
 typedef int (*udp_tunnel_encap_rcv_t)(struct sock *sk, struct sk_buff *skb);
 typedef void (*udp_tunnel_encap_destroy_t)(struct sock *sk);
+typedef struct sk_buff **(*udp_tunnel_gro_receive_t)(struct sock *sk,
+						     struct sk_buff **head,
+						     struct sk_buff *skb);
+typedef int (*udp_tunnel_gro_complete_t)(struct sock *sk, struct sk_buff *skb,
+					 int nhoff);
 
 struct udp_tunnel_sock_cfg {
 	void *sk_user_data;     /* user data used by encap_rcv call back */
 	/* Used for setting up udp_sock fields, see udp.h for details */
 	__u8  encap_type;
+	__u8 encap_fast:1;
 	udp_tunnel_encap_rcv_t encap_rcv;
 	udp_tunnel_encap_destroy_t encap_destroy;
+	udp_tunnel_gro_receive_t gro_receive;
+	udp_tunnel_gro_complete_t gro_complete;
 };
 
 /* Setup the given (UDP) sock to receive UDP encapsulated packets */
diff --git a/net/ipv4/udp_tunnel.c b/net/ipv4/udp_tunnel.c
index 96599d1..b5b13f8 100644
--- a/net/ipv4/udp_tunnel.c
+++ b/net/ipv4/udp_tunnel.c
@@ -69,6 +69,9 @@ void setup_udp_tunnel_sock(struct net *net, struct socket *sock,
 	udp_sk(sk)->encap_type = cfg->encap_type;
 	udp_sk(sk)->encap_rcv = cfg->encap_rcv;
 	udp_sk(sk)->encap_destroy = cfg->encap_destroy;
+	udp_sk(sk)->encap_fast = cfg->encap_fast;
+	udp_sk(sk)->gro_receive = cfg->gro_receive;
+	udp_sk(sk)->gro_complete = cfg->gro_complete;
 
 	udp_tunnel_encap_enable(sock);
 }
-- 
2.8.0.rc2
