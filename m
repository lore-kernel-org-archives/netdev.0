From: Eric Dumazet <eric.dumazet@gmail.com>
Subject: [PATCH net] xfrm: take care of request sockets
Date: Mon, 07 Dec 2015 08:53:17 -0800
Message-ID: <1449507197.25029.73.camel@edumazet-glaptop2.roam.corp.google.com>
References: <20151130232733.GA27119@codemonkey.org.uk>
	 <1448932931.25582.2.camel@edumazet-glaptop2.roam.corp.google.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="UTF-8"
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org,
	Steffen Klassert <steffen.klassert@secunet.com>
To: Dave Jones <davej@codemonkey.org.uk>,
	David Miller <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-pa0-f43.google.com ([209.85.220.43]:35053 "EHLO
	mail-pa0-f43.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1755648AbbLGQxU (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 7 Dec 2015 11:53:20 -0500
Received: by pacej9 with SMTP id ej9so127728093pac.2
        for <netdev@vger.kernel.org>; Mon, 07 Dec 2015 08:53:19 -0800 (PST)
In-Reply-To: <1448932931.25582.2.camel@edumazet-glaptop2.roam.corp.google.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Eric Dumazet <edumazet@google.com>

TCP SYNACK messages might now be attached to request sockets.

XFRM needs to get back to a listener socket.

Adds new helpers that might be used elsewhere :
sk_to_full_sk() and sk_const_to_full_sk()

Note: We also need to add RCU protection for xfrm lookups,
now TCP/DCCP have lockless listener processing. This will
be addressed in separate patches.

Fixes: ca6fb0651883 ("tcp: attach SYNACK messages to request sockets instead of listener")
Reported-by: Dave Jones <davej@codemonkey.org.uk>
Signed-off-by: Eric Dumazet <edumazet@google.com>
Cc: Steffen Klassert <steffen.klassert@secunet.com>
---
 include/net/inet_sock.h |   27 +++++++++++++++++++++++----
 net/xfrm/xfrm_policy.c  |    2 ++
 2 files changed, 25 insertions(+), 4 deletions(-)

diff --git a/include/net/inet_sock.h b/include/net/inet_sock.h
index 2134e6d815bc..625bdf95d673 100644
--- a/include/net/inet_sock.h
+++ b/include/net/inet_sock.h
@@ -210,18 +210,37 @@ struct inet_sock {
 #define IP_CMSG_ORIGDSTADDR	BIT(6)
 #define IP_CMSG_CHECKSUM	BIT(7)
 
-/* SYNACK messages might be attached to request sockets.
+/**
+ * sk_to_full_sk - Access to a full socket
+ * @sk: pointer to a socket
+ *
+ * SYNACK messages might be attached to request sockets.
  * Some places want to reach the listener in this case.
  */
-static inline struct sock *skb_to_full_sk(const struct sk_buff *skb)
+static inline struct sock *sk_to_full_sk(struct sock *sk)
 {
-	struct sock *sk = skb->sk;
-
+#ifdef CONFIG_INET
 	if (sk && sk->sk_state == TCP_NEW_SYN_RECV)
 		sk = inet_reqsk(sk)->rsk_listener;
+#endif
+	return sk;
+}
+
+/* sk_to_full_sk() variant with a const argument */
+static inline const struct sock *sk_const_to_full_sk(const struct sock *sk)
+{
+#ifdef CONFIG_INET
+	if (sk && sk->sk_state == TCP_NEW_SYN_RECV)
+		sk = ((const struct request_sock *)sk)->rsk_listener;
+#endif
 	return sk;
 }
 
+static inline struct sock *skb_to_full_sk(const struct sk_buff *skb)
+{
+	return sk_to_full_sk(skb->sk);
+}
+
 static inline struct inet_sock *inet_sk(const struct sock *sk)
 {
 	return (struct inet_sock *)sk;
diff --git a/net/xfrm/xfrm_policy.c b/net/xfrm/xfrm_policy.c
index 09bfcbac63bb..18276f0cc32b 100644
--- a/net/xfrm/xfrm_policy.c
+++ b/net/xfrm/xfrm_policy.c
@@ -2198,6 +2198,7 @@ struct dst_entry *xfrm_lookup(struct net *net, struct dst_entry *dst_orig,
 	xdst = NULL;
 	route = NULL;
 
+	sk = sk_const_to_full_sk(sk);
 	if (sk && sk->sk_policy[XFRM_POLICY_OUT]) {
 		num_pols = 1;
 		pols[0] = xfrm_sk_policy_lookup(sk, XFRM_POLICY_OUT, fl);
@@ -2477,6 +2478,7 @@ int __xfrm_policy_check(struct sock *sk, int dir, struct sk_buff *skb,
 	}
 
 	pol = NULL;
+	sk = sk_to_full_sk(sk);
 	if (sk && sk->sk_policy[dir]) {
 		pol = xfrm_sk_policy_lookup(sk, dir, &fl);
 		if (IS_ERR(pol)) {
