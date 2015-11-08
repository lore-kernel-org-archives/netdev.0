From: Eric Dumazet <edumazet@google.com>
Subject: [PATCH net 1/6] net: add skb_to_full_sk() helper and use it in selinux_netlbl_skbuff_setsid()
Date: Sun,  8 Nov 2015 10:54:07 -0800
Message-ID: <1447008853-16060-2-git-send-email-edumazet@google.com>
References: <1447008853-16060-1-git-send-email-edumazet@google.com>
Cc: netdev <netdev@vger.kernel.org>,
	Pablo Neira Ayuso <pablo@netfilter.org>,
	Paul Moore <paul@paul-moore.com>,
	Casey Schaufler <casey@schaufler-ca.com>,
	Eric Dumazet <edumazet@google.com>,
	Eric Dumazet <eric.dumazet@gmail.com>
To: "David S . Miller" <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-pa0-f48.google.com ([209.85.220.48]:33617 "EHLO
	mail-pa0-f48.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1750909AbbKHSy0 (ORCPT
	<rfc822;netdev@vger.kernel.org>); Sun, 8 Nov 2015 13:54:26 -0500
Received: by pabfh17 with SMTP id fh17so174799146pab.0
        for <netdev@vger.kernel.org>; Sun, 08 Nov 2015 10:54:26 -0800 (PST)
In-Reply-To: <1447008853-16060-1-git-send-email-edumazet@google.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Generalize selinux_skb_sk() added in commit 212cd0895330
("selinux: fix random read in selinux_ip_postroute_compat()")
so that we can use it other contexts.

Use it right away in selinux_netlbl_skbuff_setsid()

Fixes: ca6fb0651883 ("tcp: attach SYNACK messages to request sockets instead of listener")
Signed-off-by: Eric Dumazet <edumazet@google.com>
---
 include/net/inet_sock.h     | 12 ++++++++++++
 security/selinux/hooks.c    | 16 ++--------------
 security/selinux/netlabel.c |  2 +-
 3 files changed, 15 insertions(+), 15 deletions(-)

diff --git a/include/net/inet_sock.h b/include/net/inet_sock.h
index f5bf7310e334..2134e6d815bc 100644
--- a/include/net/inet_sock.h
+++ b/include/net/inet_sock.h
@@ -210,6 +210,18 @@ struct inet_sock {
 #define IP_CMSG_ORIGDSTADDR	BIT(6)
 #define IP_CMSG_CHECKSUM	BIT(7)
 
+/* SYNACK messages might be attached to request sockets.
+ * Some places want to reach the listener in this case.
+ */
+static inline struct sock *skb_to_full_sk(const struct sk_buff *skb)
+{
+	struct sock *sk = skb->sk;
+
+	if (sk && sk->sk_state == TCP_NEW_SYN_RECV)
+		sk = inet_reqsk(sk)->rsk_listener;
+	return sk;
+}
+
 static inline struct inet_sock *inet_sk(const struct sock *sk)
 {
 	return (struct inet_sock *)sk;
diff --git a/security/selinux/hooks.c b/security/selinux/hooks.c
index c9b2d5467477..23307da15f1d 100644
--- a/security/selinux/hooks.c
+++ b/security/selinux/hooks.c
@@ -4931,23 +4931,11 @@ static unsigned int selinux_ipv4_output(void *priv,
 	return selinux_ip_output(skb, PF_INET);
 }
 
-/* SYNACK messages might be attached to request sockets.
- * To get back to sk_security, we need to look at the listener.
- */
-static struct sock *selinux_skb_sk(const struct sk_buff *skb)
-{
-	struct sock *sk = skb->sk;
-
-	if (sk && sk->sk_state == TCP_NEW_SYN_RECV)
-		sk = inet_reqsk(sk)->rsk_listener;
-	return sk;
-}
-
 static unsigned int selinux_ip_postroute_compat(struct sk_buff *skb,
 						int ifindex,
 						u16 family)
 {
-	struct sock *sk = selinux_skb_sk(skb);
+	struct sock *sk = skb_to_full_sk(skb);
 	struct sk_security_struct *sksec;
 	struct common_audit_data ad;
 	struct lsm_network_audit net = {0,};
@@ -5002,7 +4990,7 @@ static unsigned int selinux_ip_postroute(struct sk_buff *skb,
 	if (!secmark_active && !peerlbl_active)
 		return NF_ACCEPT;
 
-	sk = selinux_skb_sk(skb);
+	sk = skb_to_full_sk(skb);
 
 #ifdef CONFIG_XFRM
 	/* If skb->dst->xfrm is non-NULL then the packet is undergoing an IPsec
diff --git a/security/selinux/netlabel.c b/security/selinux/netlabel.c
index 0364120d1ec8..1f989a539fd4 100644
--- a/security/selinux/netlabel.c
+++ b/security/selinux/netlabel.c
@@ -245,7 +245,7 @@ int selinux_netlbl_skbuff_setsid(struct sk_buff *skb,
 
 	/* if this is a locally generated packet check to see if it is already
 	 * being labeled by it's parent socket, if it is just exit */
-	sk = skb->sk;
+	sk = skb_to_full_sk(skb);
 	if (sk != NULL) {
 		struct sk_security_struct *sksec = sk->sk_security;
 		if (sksec->nlbl_state != NLBL_REQSKB)
-- 
2.6.0.rc2.230.g3dd15c0
