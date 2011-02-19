From: kaber@trash.net
Subject: [PATCH 1/2] netfilter: tproxy: do not assign timewait sockets to skb->sk
Date: Sat, 19 Feb 2011 16:41:04 +0100
Message-ID: <1298130065-14205-2-git-send-email-kaber@trash.net>
References: <1298130065-14205-1-git-send-email-kaber@trash.net>
Cc: netfilter-devel@vger.kernel.org, netdev@vger.kernel.org
To: davem@davemloft.net
Return-path: <netfilter-devel-owner@vger.kernel.org>
In-Reply-To: <1298130065-14205-1-git-send-email-kaber@trash.net>
Sender: netfilter-devel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

From: Florian Westphal <fwestphal@astaro.com>

Assigning a socket in timewait state to skb->sk can trigger
kernel oops, e.g. in nfnetlink_log, which does:

if (skb->sk) {
        read_lock_bh(&skb->sk->sk_callback_lock);
        if (skb->sk->sk_socket && skb->sk->sk_socket->file) ...

in the timewait case, accessing sk->sk_callback_lock and sk->sk_socket
is invalid.

Either all of these spots will need to add a test for sk->sk_state != TCP_TIME_WAIT,
or xt_TPROXY must not assign a timewait socket to skb->sk.

This does the latter.

If a TW socket is found, assign the tproxy nfmark, but skip the skb->sk assignment,
thus mimicking behaviour of a '-m socket .. -j MARK/ACCEPT' re-routing rule.

The 'SYN to TW socket' case is left unchanged -- we try to redirect to the
listener socket.

Cc: Balazs Scheidler <bazsi@balabit.hu>
Cc: KOVACS Krisztian <hidden@balabit.hu>
Signed-off-by: Florian Westphal <fwestphal@astaro.com>
Signed-off-by: Patrick McHardy <kaber@trash.net>
---
 include/net/netfilter/nf_tproxy_core.h |   12 +-----------
 net/netfilter/nf_tproxy_core.c         |   27 ++++++++++++---------------
 net/netfilter/xt_TPROXY.c              |   22 ++++++++++++++++++++--
 net/netfilter/xt_socket.c              |   13 +++++++++++--
 4 files changed, 44 insertions(+), 30 deletions(-)

diff --git a/include/net/netfilter/nf_tproxy_core.h b/include/net/netfilter/nf_tproxy_core.h
index cd85b3b..e505358 100644
--- a/include/net/netfilter/nf_tproxy_core.h
+++ b/include/net/netfilter/nf_tproxy_core.h
@@ -201,18 +201,8 @@ nf_tproxy_get_sock_v6(struct net *net, const u8 protocol,
 }
 #endif
 
-static inline void
-nf_tproxy_put_sock(struct sock *sk)
-{
-	/* TIME_WAIT inet sockets have to be handled differently */
-	if ((sk->sk_protocol == IPPROTO_TCP) && (sk->sk_state == TCP_TIME_WAIT))
-		inet_twsk_put(inet_twsk(sk));
-	else
-		sock_put(sk);
-}
-
 /* assign a socket to the skb -- consumes sk */
-int
+void
 nf_tproxy_assign_sock(struct sk_buff *skb, struct sock *sk);
 
 #endif
diff --git a/net/netfilter/nf_tproxy_core.c b/net/netfilter/nf_tproxy_core.c
index 4d87bef..474d621 100644
--- a/net/netfilter/nf_tproxy_core.c
+++ b/net/netfilter/nf_tproxy_core.c
@@ -28,26 +28,23 @@ nf_tproxy_destructor(struct sk_buff *skb)
 	skb->destructor = NULL;
 
 	if (sk)
-		nf_tproxy_put_sock(sk);
+		sock_put(sk);
 }
 
 /* consumes sk */
-int
+void
 nf_tproxy_assign_sock(struct sk_buff *skb, struct sock *sk)
 {
-	bool transparent = (sk->sk_state == TCP_TIME_WAIT) ?
-				inet_twsk(sk)->tw_transparent :
-				inet_sk(sk)->transparent;
-
-	if (transparent) {
-		skb_orphan(skb);
-		skb->sk = sk;
-		skb->destructor = nf_tproxy_destructor;
-		return 1;
-	} else
-		nf_tproxy_put_sock(sk);
-
-	return 0;
+	/* assigning tw sockets complicates things; most
+	 * skb->sk->X checks would have to test sk->sk_state first */
+	if (sk->sk_state == TCP_TIME_WAIT) {
+		inet_twsk_put(inet_twsk(sk));
+		return;
+	}
+
+	skb_orphan(skb);
+	skb->sk = sk;
+	skb->destructor = nf_tproxy_destructor;
 }
 EXPORT_SYMBOL_GPL(nf_tproxy_assign_sock);
 
diff --git a/net/netfilter/xt_TPROXY.c b/net/netfilter/xt_TPROXY.c
index 640678f..dcfd57e 100644
--- a/net/netfilter/xt_TPROXY.c
+++ b/net/netfilter/xt_TPROXY.c
@@ -33,6 +33,20 @@
 #include <net/netfilter/nf_tproxy_core.h>
 #include <linux/netfilter/xt_TPROXY.h>
 
+static bool tproxy_sk_is_transparent(struct sock *sk)
+{
+	if (sk->sk_state != TCP_TIME_WAIT) {
+		if (inet_sk(sk)->transparent)
+			return true;
+		sock_put(sk);
+	} else {
+		if (inet_twsk(sk)->tw_transparent)
+			return true;
+		inet_twsk_put(inet_twsk(sk));
+	}
+	return false;
+}
+
 static inline __be32
 tproxy_laddr4(struct sk_buff *skb, __be32 user_laddr, __be32 daddr)
 {
@@ -141,7 +155,7 @@ tproxy_tg4(struct sk_buff *skb, __be32 laddr, __be16 lport,
 					   skb->dev, NFT_LOOKUP_LISTENER);
 
 	/* NOTE: assign_sock consumes our sk reference */
-	if (sk && nf_tproxy_assign_sock(skb, sk)) {
+	if (sk && tproxy_sk_is_transparent(sk)) {
 		/* This should be in a separate target, but we don't do multiple
 		   targets on the same rule yet */
 		skb->mark = (skb->mark & ~mark_mask) ^ mark_value;
@@ -149,6 +163,8 @@ tproxy_tg4(struct sk_buff *skb, __be32 laddr, __be16 lport,
 		pr_debug("redirecting: proto %hhu %pI4:%hu -> %pI4:%hu, mark: %x\n",
 			 iph->protocol, &iph->daddr, ntohs(hp->dest),
 			 &laddr, ntohs(lport), skb->mark);
+
+		nf_tproxy_assign_sock(skb, sk);
 		return NF_ACCEPT;
 	}
 
@@ -306,7 +322,7 @@ tproxy_tg6_v1(struct sk_buff *skb, const struct xt_action_param *par)
 					   par->in, NFT_LOOKUP_LISTENER);
 
 	/* NOTE: assign_sock consumes our sk reference */
-	if (sk && nf_tproxy_assign_sock(skb, sk)) {
+	if (sk && tproxy_sk_is_transparent(sk)) {
 		/* This should be in a separate target, but we don't do multiple
 		   targets on the same rule yet */
 		skb->mark = (skb->mark & ~tgi->mark_mask) ^ tgi->mark_value;
@@ -314,6 +330,8 @@ tproxy_tg6_v1(struct sk_buff *skb, const struct xt_action_param *par)
 		pr_debug("redirecting: proto %hhu %pI6:%hu -> %pI6:%hu, mark: %x\n",
 			 tproto, &iph->saddr, ntohs(hp->source),
 			 laddr, ntohs(lport), skb->mark);
+
+		nf_tproxy_assign_sock(skb, sk);
 		return NF_ACCEPT;
 	}
 
diff --git a/net/netfilter/xt_socket.c b/net/netfilter/xt_socket.c
index 00d6ae8..9cc4635 100644
--- a/net/netfilter/xt_socket.c
+++ b/net/netfilter/xt_socket.c
@@ -35,6 +35,15 @@
 #include <net/netfilter/nf_conntrack.h>
 #endif
 
+static void
+xt_socket_put_sk(struct sock *sk)
+{
+	if (sk->sk_state == TCP_TIME_WAIT)
+		inet_twsk_put(inet_twsk(sk));
+	else
+		sock_put(sk);
+}
+
 static int
 extract_icmp4_fields(const struct sk_buff *skb,
 		    u8 *protocol,
@@ -164,7 +173,7 @@ socket_match(const struct sk_buff *skb, struct xt_action_param *par,
 				       (sk->sk_state == TCP_TIME_WAIT &&
 					inet_twsk(sk)->tw_transparent));
 
-		nf_tproxy_put_sock(sk);
+		xt_socket_put_sk(sk);
 
 		if (wildcard || !transparent)
 			sk = NULL;
@@ -298,7 +307,7 @@ socket_mt6_v1(const struct sk_buff *skb, struct xt_action_param *par)
 				       (sk->sk_state == TCP_TIME_WAIT &&
 					inet_twsk(sk)->tw_transparent));
 
-		nf_tproxy_put_sock(sk);
+		xt_socket_put_sk(sk);
 
 		if (wildcard || !transparent)
 			sk = NULL;
-- 
1.7.2.3

