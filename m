From: Tom Herbert <tom@herbertland.com>
Subject: [PATCH net-next 4/8] udp: Add socket based GRO and config
Date: Tue, 5 Apr 2016 08:22:52 -0700
Message-ID: <1459869776-2090500-5-git-send-email-tom@herbertland.com>
References: <1459869776-2090500-1-git-send-email-tom@herbertland.com>
Mime-Version: 1.0
Content-Type: text/plain
Cc: <kernel-team@fb.com>
To: <davem@davemloft.net>, <netdev@vger.kernel.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mx0b-00082601.pphosted.com ([67.231.153.30]:45910 "EHLO
	mx0b-00082601.pphosted.com" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with ESMTP id S1758971AbcDEPXO (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 5 Apr 2016 11:23:14 -0400
Received: from pps.filterd (m0001303.ppops.net [127.0.0.1])
	by m0001303.ppops.net (8.16.0.11/8.16.0.11) with SMTP id u35FJD9D021584
	for <netdev@vger.kernel.org>; Tue, 5 Apr 2016 08:23:13 -0700
Received: from mail.thefacebook.com ([199.201.64.23])
	by m0001303.ppops.net with ESMTP id 222xhcekyk-1
	(version=TLSv1 cipher=AES128-SHA bits=128 verify=NOT)
	for <netdev@vger.kernel.org>; Tue, 05 Apr 2016 08:23:13 -0700
Received: from devbig284.prn2.facebook.com (10.35.15.32)	by
 mx-out.facebook.com (10.223.100.99) with ESMTP	id
 4ed3944cfb4211e5b9fc24be05956610-e6fc13f0 for <netdev@vger.kernel.org>;	Tue,
 05 Apr 2016 08:23:11 -0700
In-Reply-To: <1459869776-2090500-1-git-send-email-tom@herbertland.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Add gro_receive and  gro_complete to struct udp_tunnel_sock_cfg.

Signed-off-by: Tom Herbert <tom@herbertland.com>
---
 include/net/udp_tunnel.h | 7 +++++++
 net/ipv4/udp_tunnel.c    | 2 ++
 2 files changed, 9 insertions(+)

diff --git a/include/net/udp_tunnel.h b/include/net/udp_tunnel.h
index b831140..2dcf1de 100644
--- a/include/net/udp_tunnel.h
+++ b/include/net/udp_tunnel.h
@@ -64,6 +64,11 @@ static inline int udp_sock_create(struct net *net,
 
 typedef int (*udp_tunnel_encap_rcv_t)(struct sock *sk, struct sk_buff *skb);
 typedef void (*udp_tunnel_encap_destroy_t)(struct sock *sk);
+typedef struct sk_buff **(*udp_tunnel_gro_receive_t)(struct sock *sk,
+						     struct sk_buff **head,
+						     struct sk_buff *skb);
+typedef int (*udp_tunnel_gro_complete_t)(struct sock *sk, struct sk_buff *skb,
+					 int nhoff);
 
 struct udp_tunnel_sock_cfg {
 	void *sk_user_data;     /* user data used by encap_rcv call back */
@@ -71,6 +76,8 @@ struct udp_tunnel_sock_cfg {
 	__u8  encap_type;
 	udp_tunnel_encap_rcv_t encap_rcv;
 	udp_tunnel_encap_destroy_t encap_destroy;
+	udp_tunnel_gro_receive_t gro_receive;
+	udp_tunnel_gro_complete_t gro_complete;
 };
 
 /* Setup the given (UDP) sock to receive UDP encapsulated packets */
diff --git a/net/ipv4/udp_tunnel.c b/net/ipv4/udp_tunnel.c
index 96599d1..47f12c7 100644
--- a/net/ipv4/udp_tunnel.c
+++ b/net/ipv4/udp_tunnel.c
@@ -69,6 +69,8 @@ void setup_udp_tunnel_sock(struct net *net, struct socket *sock,
 	udp_sk(sk)->encap_type = cfg->encap_type;
 	udp_sk(sk)->encap_rcv = cfg->encap_rcv;
 	udp_sk(sk)->encap_destroy = cfg->encap_destroy;
+	udp_sk(sk)->gro_receive = cfg->gro_receive;
+	udp_sk(sk)->gro_complete = cfg->gro_complete;
 
 	udp_tunnel_encap_enable(sock);
 }
-- 
2.8.0.rc2
