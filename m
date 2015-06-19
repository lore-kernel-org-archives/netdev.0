From: Pablo Neira Ayuso <pablo@netfilter.org>
Subject: [PATCH 02/12] netfilter: xt_socket: add XT_SOCKET_RESTORESKMARK flag
Date: Fri, 19 Jun 2015 19:17:39 +0200
Message-ID: <1434734269-4545-3-git-send-email-pablo@netfilter.org>
References: <1434734269-4545-1-git-send-email-pablo@netfilter.org>
Cc: davem@davemloft.net, netdev@vger.kernel.org
To: netfilter-devel@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail.us.es ([193.147.175.20]:55517 "EHLO mail.us.es"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1754658AbbFSRMe (ORCPT <rfc822;netdev@vger.kernel.org>);
	Fri, 19 Jun 2015 13:12:34 -0400
In-Reply-To: <1434734269-4545-1-git-send-email-pablo@netfilter.org>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Harout Hedeshian <harouth@codeaurora.org>

xt_socket is useful for matching sockets with IP_TRANSPARENT and
taking some action on the matching packets. However, it lacks the
ability to match only a small subset of transparent sockets.

Suppose there are 2 applications, each with its own set of transparent
sockets. The first application wants all matching packets dropped,
while the second application wants them forwarded somewhere else.

Add the ability to retore the skb->mark from the sk_mark. The mark
is only restored if a matching socket is found and the transparent /
nowildcard conditions are satisfied.

Now the 2 hypothetical applications can differentiate their sockets
based on a mark value set with SO_MARK.

iptables -t mangle -I PREROUTING -m socket --transparent \
                                           --restore-skmark -j action
iptables -t mangle -A action -m mark --mark 10 -j action2
iptables -t mangle -A action -m mark --mark 11 -j action3

Signed-off-by: Harout Hedeshian <harouth@codeaurora.org>
Signed-off-by: Pablo Neira Ayuso <pablo@netfilter.org>
---
 include/uapi/linux/netfilter/xt_socket.h |    8 ++++
 net/netfilter/xt_socket.c                |   59 +++++++++++++++++++++++++++---
 2 files changed, 61 insertions(+), 6 deletions(-)

diff --git a/include/uapi/linux/netfilter/xt_socket.h b/include/uapi/linux/netfilter/xt_socket.h
index 6315e2a..87644f8 100644
--- a/include/uapi/linux/netfilter/xt_socket.h
+++ b/include/uapi/linux/netfilter/xt_socket.h
@@ -6,6 +6,7 @@
 enum {
 	XT_SOCKET_TRANSPARENT = 1 << 0,
 	XT_SOCKET_NOWILDCARD = 1 << 1,
+	XT_SOCKET_RESTORESKMARK = 1 << 2,
 };
 
 struct xt_socket_mtinfo1 {
@@ -18,4 +19,11 @@ struct xt_socket_mtinfo2 {
 };
 #define XT_SOCKET_FLAGS_V2 (XT_SOCKET_TRANSPARENT | XT_SOCKET_NOWILDCARD)
 
+struct xt_socket_mtinfo3 {
+	__u8 flags;
+};
+#define XT_SOCKET_FLAGS_V3 (XT_SOCKET_TRANSPARENT \
+			   | XT_SOCKET_NOWILDCARD \
+			   | XT_SOCKET_RESTORESKMARK)
+
 #endif /* _XT_SOCKET_H */
diff --git a/net/netfilter/xt_socket.c b/net/netfilter/xt_socket.c
index e092cb0..43e26c8 100644
--- a/net/netfilter/xt_socket.c
+++ b/net/netfilter/xt_socket.c
@@ -205,6 +205,7 @@ static bool
 socket_match(const struct sk_buff *skb, struct xt_action_param *par,
 	     const struct xt_socket_mtinfo1 *info)
 {
+	struct sk_buff *pskb = (struct sk_buff *)skb;
 	struct sock *sk = skb->sk;
 
 	if (!sk)
@@ -226,6 +227,10 @@ socket_match(const struct sk_buff *skb, struct xt_action_param *par,
 		if (info->flags & XT_SOCKET_TRANSPARENT)
 			transparent = xt_socket_sk_is_transparent(sk);
 
+		if (info->flags & XT_SOCKET_RESTORESKMARK && !wildcard &&
+		    transparent)
+			pskb->mark = sk->sk_mark;
+
 		if (sk != skb->sk)
 			sock_gen_put(sk);
 
@@ -247,7 +252,7 @@ socket_mt4_v0(const struct sk_buff *skb, struct xt_action_param *par)
 }
 
 static bool
-socket_mt4_v1_v2(const struct sk_buff *skb, struct xt_action_param *par)
+socket_mt4_v1_v2_v3(const struct sk_buff *skb, struct xt_action_param *par)
 {
 	return socket_match(skb, par, par->matchinfo);
 }
@@ -371,9 +376,10 @@ static struct sock *xt_socket_lookup_slow_v6(const struct sk_buff *skb,
 }
 
 static bool
-socket_mt6_v1_v2(const struct sk_buff *skb, struct xt_action_param *par)
+socket_mt6_v1_v2_v3(const struct sk_buff *skb, struct xt_action_param *par)
 {
 	const struct xt_socket_mtinfo1 *info = (struct xt_socket_mtinfo1 *) par->matchinfo;
+	struct sk_buff *pskb = (struct sk_buff *)skb;
 	struct sock *sk = skb->sk;
 
 	if (!sk)
@@ -395,6 +401,10 @@ socket_mt6_v1_v2(const struct sk_buff *skb, struct xt_action_param *par)
 		if (info->flags & XT_SOCKET_TRANSPARENT)
 			transparent = xt_socket_sk_is_transparent(sk);
 
+		if (info->flags & XT_SOCKET_RESTORESKMARK && !wildcard &&
+		    transparent)
+			pskb->mark = sk->sk_mark;
+
 		if (sk != skb->sk)
 			sock_gen_put(sk);
 
@@ -428,6 +438,19 @@ static int socket_mt_v2_check(const struct xt_mtchk_param *par)
 	return 0;
 }
 
+static int socket_mt_v3_check(const struct xt_mtchk_param *par)
+{
+	const struct xt_socket_mtinfo3 *info =
+				    (struct xt_socket_mtinfo3 *)par->matchinfo;
+
+	if (info->flags & ~XT_SOCKET_FLAGS_V3) {
+		pr_info("unknown flags 0x%x\n",
+			info->flags & ~XT_SOCKET_FLAGS_V3);
+		return -EINVAL;
+	}
+	return 0;
+}
+
 static struct xt_match socket_mt_reg[] __read_mostly = {
 	{
 		.name		= "socket",
@@ -442,7 +465,7 @@ static struct xt_match socket_mt_reg[] __read_mostly = {
 		.name		= "socket",
 		.revision	= 1,
 		.family		= NFPROTO_IPV4,
-		.match		= socket_mt4_v1_v2,
+		.match		= socket_mt4_v1_v2_v3,
 		.checkentry	= socket_mt_v1_check,
 		.matchsize	= sizeof(struct xt_socket_mtinfo1),
 		.hooks		= (1 << NF_INET_PRE_ROUTING) |
@@ -454,7 +477,7 @@ static struct xt_match socket_mt_reg[] __read_mostly = {
 		.name		= "socket",
 		.revision	= 1,
 		.family		= NFPROTO_IPV6,
-		.match		= socket_mt6_v1_v2,
+		.match		= socket_mt6_v1_v2_v3,
 		.checkentry	= socket_mt_v1_check,
 		.matchsize	= sizeof(struct xt_socket_mtinfo1),
 		.hooks		= (1 << NF_INET_PRE_ROUTING) |
@@ -466,7 +489,7 @@ static struct xt_match socket_mt_reg[] __read_mostly = {
 		.name		= "socket",
 		.revision	= 2,
 		.family		= NFPROTO_IPV4,
-		.match		= socket_mt4_v1_v2,
+		.match		= socket_mt4_v1_v2_v3,
 		.checkentry	= socket_mt_v2_check,
 		.matchsize	= sizeof(struct xt_socket_mtinfo1),
 		.hooks		= (1 << NF_INET_PRE_ROUTING) |
@@ -478,7 +501,7 @@ static struct xt_match socket_mt_reg[] __read_mostly = {
 		.name		= "socket",
 		.revision	= 2,
 		.family		= NFPROTO_IPV6,
-		.match		= socket_mt6_v1_v2,
+		.match		= socket_mt6_v1_v2_v3,
 		.checkentry	= socket_mt_v2_check,
 		.matchsize	= sizeof(struct xt_socket_mtinfo1),
 		.hooks		= (1 << NF_INET_PRE_ROUTING) |
@@ -486,6 +509,30 @@ static struct xt_match socket_mt_reg[] __read_mostly = {
 		.me		= THIS_MODULE,
 	},
 #endif
+	{
+		.name		= "socket",
+		.revision	= 3,
+		.family		= NFPROTO_IPV4,
+		.match		= socket_mt4_v1_v2_v3,
+		.checkentry	= socket_mt_v3_check,
+		.matchsize	= sizeof(struct xt_socket_mtinfo1),
+		.hooks		= (1 << NF_INET_PRE_ROUTING) |
+				  (1 << NF_INET_LOCAL_IN),
+		.me		= THIS_MODULE,
+	},
+#ifdef XT_SOCKET_HAVE_IPV6
+	{
+		.name		= "socket",
+		.revision	= 3,
+		.family		= NFPROTO_IPV6,
+		.match		= socket_mt6_v1_v2_v3,
+		.checkentry	= socket_mt_v3_check,
+		.matchsize	= sizeof(struct xt_socket_mtinfo1),
+		.hooks		= (1 << NF_INET_PRE_ROUTING) |
+				  (1 << NF_INET_LOCAL_IN),
+		.me		= THIS_MODULE,
+	},
+#endif
 };
 
 static int __init socket_mt_init(void)
-- 
1.7.10.4
