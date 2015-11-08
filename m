From: Eric Dumazet <edumazet@google.com>
Subject: [PATCH net 2/6] smack: use skb_to_full_sk() helper
Date: Sun,  8 Nov 2015 10:54:08 -0800
Message-ID: <1447008853-16060-3-git-send-email-edumazet@google.com>
References: <1447008853-16060-1-git-send-email-edumazet@google.com>
Cc: netdev <netdev@vger.kernel.org>,
	Pablo Neira Ayuso <pablo@netfilter.org>,
	Paul Moore <paul@paul-moore.com>,
	Casey Schaufler <casey@schaufler-ca.com>,
	Eric Dumazet <edumazet@google.com>,
	Eric Dumazet <eric.dumazet@gmail.com>
To: "David S . Miller" <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-pa0-f44.google.com ([209.85.220.44]:34058 "EHLO
	mail-pa0-f44.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751275AbbKHSya (ORCPT
	<rfc822;netdev@vger.kernel.org>); Sun, 8 Nov 2015 13:54:30 -0500
Received: by padhx2 with SMTP id hx2so166373018pad.1
        for <netdev@vger.kernel.org>; Sun, 08 Nov 2015 10:54:30 -0800 (PST)
In-Reply-To: <1447008853-16060-1-git-send-email-edumazet@google.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

This module wants to access sk->sk_security, which is not
available for request sockets.

Fixes: ca6fb0651883 ("tcp: attach SYNACK messages to request sockets instead of listener")
Signed-off-by: Eric Dumazet <edumazet@google.com>
---
 security/smack/smack_netfilter.c | 11 +++++++----
 1 file changed, 7 insertions(+), 4 deletions(-)

diff --git a/security/smack/smack_netfilter.c b/security/smack/smack_netfilter.c
index 6d1706c9777e..aa6bf1b22ec5 100644
--- a/security/smack/smack_netfilter.c
+++ b/security/smack/smack_netfilter.c
@@ -17,6 +17,7 @@
 #include <linux/netfilter_ipv4.h>
 #include <linux/netfilter_ipv6.h>
 #include <linux/netdevice.h>
+#include <net/inet_sock.h>
 #include "smack.h"
 
 #if defined(CONFIG_IPV6) || defined(CONFIG_IPV6_MODULE)
@@ -25,11 +26,12 @@ static unsigned int smack_ipv6_output(void *priv,
 					struct sk_buff *skb,
 					const struct nf_hook_state *state)
 {
+	struct sock *sk = skb_to_full_sk(skb);
 	struct socket_smack *ssp;
 	struct smack_known *skp;
 
-	if (skb && skb->sk && skb->sk->sk_security) {
-		ssp = skb->sk->sk_security;
+	if (sk && sk->sk_security) {
+		ssp = sk->sk_security;
 		skp = ssp->smk_out;
 		skb->secmark = skp->smk_secid;
 	}
@@ -42,11 +44,12 @@ static unsigned int smack_ipv4_output(void *priv,
 					struct sk_buff *skb,
 					const struct nf_hook_state *state)
 {
+	struct sock *sk = skb_to_full_sk(skb);
 	struct socket_smack *ssp;
 	struct smack_known *skp;
 
-	if (skb && skb->sk && skb->sk->sk_security) {
-		ssp = skb->sk->sk_security;
+	if (sk && sk->sk_security) {
+		ssp = sk->sk_security;
 		skp = ssp->smk_out;
 		skb->secmark = skp->smk_secid;
 	}
-- 
2.6.0.rc2.230.g3dd15c0
