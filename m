From: Tom Herbert <tom@herbertland.com>
Subject: [PATCH v5 net-next 06/14] fou: Call setup_udp_tunnel_sock
Date: Sun, 15 May 2016 16:42:27 -0700
Message-ID: <1463355755-3481375-7-git-send-email-tom@herbertland.com>
References: <1463355755-3481375-1-git-send-email-tom@herbertland.com>
Mime-Version: 1.0
Content-Type: text/plain
Cc: <kernel-team@fb.com>
To: <davem@davemloft.net>, <netdev@vger.kernel.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mx0a-00082601.pphosted.com ([67.231.145.42]:48361 "EHLO
	mx0a-00082601.pphosted.com" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with ESMTP id S1752256AbcEOXmy (ORCPT
	<rfc822;netdev@vger.kernel.org>); Sun, 15 May 2016 19:42:54 -0400
Received: from pps.filterd (m0044012.ppops.net [127.0.0.1])
	by mx0a-00082601.pphosted.com (8.16.0.11/8.16.0.11) with SMTP id u4FNfeEi029010
	for <netdev@vger.kernel.org>; Sun, 15 May 2016 16:42:53 -0700
Received: from mail.thefacebook.com ([199.201.64.23])
	by mx0a-00082601.pphosted.com with ESMTP id 22x1q54km8-1
	(version=TLSv1 cipher=ECDHE-RSA-AES256-SHA bits=256 verify=NOT)
	for <netdev@vger.kernel.org>; Sun, 15 May 2016 16:42:53 -0700
Received: from devbig284.prn2.facebook.com (10.35.15.32)	by
 mx-out.facebook.com (10.223.101.97) with ESMTP	id
 bd64a7f61af611e6a12624be0595f910-d34ebc50 for <netdev@vger.kernel.org>;	Sun,
 15 May 2016 16:42:52 -0700
In-Reply-To: <1463355755-3481375-1-git-send-email-tom@herbertland.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Use helper function to set up UDP tunnel related information for a fou
socket.

Signed-off-by: Tom Herbert <tom@herbertland.com>
---
 net/ipv4/fou.c | 50 ++++++++++++++++----------------------------------
 1 file changed, 16 insertions(+), 34 deletions(-)

diff --git a/net/ipv4/fou.c b/net/ipv4/fou.c
index eeec7d6..6cbc725 100644
--- a/net/ipv4/fou.c
+++ b/net/ipv4/fou.c
@@ -448,31 +448,13 @@ static void fou_release(struct fou *fou)
 	kfree_rcu(fou, rcu);
 }
 
-static int fou_encap_init(struct sock *sk, struct fou *fou, struct fou_cfg *cfg)
-{
-	udp_sk(sk)->encap_rcv = fou_udp_recv;
-	udp_sk(sk)->gro_receive = fou_gro_receive;
-	udp_sk(sk)->gro_complete = fou_gro_complete;
-	fou_from_sock(sk)->protocol = cfg->protocol;
-
-	return 0;
-}
-
-static int gue_encap_init(struct sock *sk, struct fou *fou, struct fou_cfg *cfg)
-{
-	udp_sk(sk)->encap_rcv = gue_udp_recv;
-	udp_sk(sk)->gro_receive = gue_gro_receive;
-	udp_sk(sk)->gro_complete = gue_gro_complete;
-
-	return 0;
-}
-
 static int fou_create(struct net *net, struct fou_cfg *cfg,
 		      struct socket **sockp)
 {
 	struct socket *sock = NULL;
 	struct fou *fou = NULL;
 	struct sock *sk;
+	struct udp_tunnel_sock_cfg tunnel_cfg;
 	int err;
 
 	/* Open UDP socket */
@@ -491,33 +473,33 @@ static int fou_create(struct net *net, struct fou_cfg *cfg,
 
 	fou->flags = cfg->flags;
 	fou->port = cfg->udp_config.local_udp_port;
+	fou->type = cfg->type;
+	fou->sock = sock;
+
+	memset(&tunnel_cfg, 0, sizeof(tunnel_cfg));
+	tunnel_cfg.encap_type = 1;
+	tunnel_cfg.sk_user_data = fou;
+	tunnel_cfg.encap_destroy = NULL;
 
 	/* Initial for fou type */
 	switch (cfg->type) {
 	case FOU_ENCAP_DIRECT:
-		err = fou_encap_init(sk, fou, cfg);
-		if (err)
-			goto error;
+		tunnel_cfg.encap_rcv = fou_udp_recv;
+		tunnel_cfg.gro_receive = fou_gro_receive;
+		tunnel_cfg.gro_complete = fou_gro_complete;
+		fou->protocol = cfg->protocol;
 		break;
 	case FOU_ENCAP_GUE:
-		err = gue_encap_init(sk, fou, cfg);
-		if (err)
-			goto error;
+		tunnel_cfg.encap_rcv = gue_udp_recv;
+		tunnel_cfg.gro_receive = gue_gro_receive;
+		tunnel_cfg.gro_complete = gue_gro_complete;
 		break;
 	default:
 		err = -EINVAL;
 		goto error;
 	}
 
-	fou->type = cfg->type;
-
-	udp_sk(sk)->encap_type = 1;
-	udp_encap_enable();
-
-	sk->sk_user_data = fou;
-	fou->sock = sock;
-
-	inet_inc_convert_csum(sk);
+	setup_udp_tunnel_sock(net, sock, &tunnel_cfg);
 
 	sk->sk_allocation = GFP_ATOMIC;
 
-- 
2.8.0.rc2
