From: Hannes Frederic Sowa <hannes@stressinduktion.org>
Subject: [PATCH net-next RFC v1 27/27] afnetns: allow only whitelisted protocols to operate inside afnetns
Date: Mon, 13 Mar 2017 00:01:51 +0100
Message-ID: <20170312230151.5185-28-hannes@stressinduktion.org>
References: <20170312230151.5185-1-hannes@stressinduktion.org>
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from out1-smtp.messagingengine.com ([66.111.4.25]:55858 "EHLO
        out1-smtp.messagingengine.com" rhost-flags-OK-OK-OK-OK)
        by vger.kernel.org with ESMTP id S935686AbdCLXCY (ORCPT
        <rfc822;netdev@vger.kernel.org>); Sun, 12 Mar 2017 19:02:24 -0400
Received: from compute7.internal (compute7.nyi.internal [10.202.2.47])
        by mailout.nyi.internal (Postfix) with ESMTP id C193E20769
        for <netdev@vger.kernel.org>; Sun, 12 Mar 2017 19:02:17 -0400 (EDT)
Received: from m.localhost.localhost (unknown [213.55.211.72])
        by mail.messagingengine.com (Postfix) with ESMTPA id 3433B2423E
        for <netdev@vger.kernel.org>; Sun, 12 Mar 2017 19:02:17 -0400 (EDT)
In-Reply-To: <20170312230151.5185-1-hannes@stressinduktion.org>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

We only care about inet protocols (which is IPv4 and IPv6). Other
protocols, like netlink are not under control of afnetns and thus must
be hardened with capabilities.

Signed-off-by: Hannes Frederic Sowa <hannes@stressinduktion.org>
---
 include/net/protocol.h |  1 +
 net/ipv4/af_inet.c     | 20 +++++++++++++++-----
 net/ipv4/udplite.c     |  3 ++-
 net/ipv6/af_inet6.c    | 14 +++++++++++---
 net/ipv6/tcp_ipv6.c    |  3 ++-
 net/ipv6/udp.c         |  3 ++-
 net/ipv6/udplite.c     |  3 ++-
 7 files changed, 35 insertions(+), 12 deletions(-)

diff --git a/include/net/protocol.h b/include/net/protocol.h
index bf36ca34af7ad2..7b64f71b16ccc0 100644
--- a/include/net/protocol.h
+++ b/include/net/protocol.h
@@ -91,6 +91,7 @@ struct inet_protosw {
 #define INET_PROTOSW_REUSE 0x01	     /* Are ports automatically reusable? */
 #define INET_PROTOSW_PERMANENT 0x02  /* Permanent protocols are unremovable. */
 #define INET_PROTOSW_ICSK      0x04  /* Is this an inet_connection_sock? */
+#define INET_PROTOSW_AFNETNS_OK 0x08 /* Is this proto afnetns compatible? */
 
 extern const struct net_protocol __rcu *inet_protos[MAX_INET_PROTOS];
 extern const struct net_offload __rcu *inet_offloads[MAX_INET_PROTOS];
diff --git a/net/ipv4/af_inet.c b/net/ipv4/af_inet.c
index da7e6299073743..1eb8a8ea49f56c 100644
--- a/net/ipv4/af_inet.c
+++ b/net/ipv4/af_inet.c
@@ -302,14 +302,22 @@ static int inet_create(struct net *net, struct socket *sock, int protocol,
 			goto out_rcu_unlock;
 	}
 
+	sock->ops = answer->ops;
+	answer_prot = answer->prot;
+	answer_flags = answer->flags;
+
 	err = -EPERM;
 	if (sock->type == SOCK_RAW && !kern &&
 	    !ns_capable(net->user_ns, CAP_NET_RAW))
 		goto out_rcu_unlock;
 
-	sock->ops = answer->ops;
-	answer_prot = answer->prot;
-	answer_flags = answer->flags;
+#if IS_ENABLED(CONFIG_AFNETNS)
+	if (unlikely(!kern &&
+		     current->nsproxy->afnet_ns != net->afnet_ns &&
+		     !(answer_flags & INET_PROTOSW_AFNETNS_OK)))
+		goto out_rcu_unlock;
+#endif
+
 	rcu_read_unlock();
 
 	WARN_ON(!answer_prot->slab);
@@ -1060,7 +1068,8 @@ static struct inet_protosw inetsw_array[] =
 		.prot =       &tcp_prot,
 		.ops =        &inet_stream_ops,
 		.flags =      INET_PROTOSW_PERMANENT |
-			      INET_PROTOSW_ICSK,
+			      INET_PROTOSW_ICSK |
+			      INET_PROTOSW_AFNETNS_OK,
 	},
 
 	{
@@ -1068,7 +1077,8 @@ static struct inet_protosw inetsw_array[] =
 		.protocol =   IPPROTO_UDP,
 		.prot =       &udp_prot,
 		.ops =        &inet_dgram_ops,
-		.flags =      INET_PROTOSW_PERMANENT,
+		.flags =      INET_PROTOSW_PERMANENT |
+			      INET_PROTOSW_AFNETNS_OK,
        },
 
        {
diff --git a/net/ipv4/udplite.c b/net/ipv4/udplite.c
index 59f10fe9782e57..fbdb4208ebc483 100644
--- a/net/ipv4/udplite.c
+++ b/net/ipv4/udplite.c
@@ -69,7 +69,8 @@ static struct inet_protosw udplite4_protosw = {
 	.protocol	=  IPPROTO_UDPLITE,
 	.prot		=  &udplite_prot,
 	.ops		=  &inet_dgram_ops,
-	.flags		=  INET_PROTOSW_PERMANENT,
+	.flags		=  INET_PROTOSW_PERMANENT |
+			   INET_PROTOSW_AFNETNS_OK,
 };
 
 #ifdef CONFIG_PROC_FS
diff --git a/net/ipv6/af_inet6.c b/net/ipv6/af_inet6.c
index 4aa221826e753c..e21804b24be408 100644
--- a/net/ipv6/af_inet6.c
+++ b/net/ipv6/af_inet6.c
@@ -167,14 +167,22 @@ static int inet6_create(struct net *net, struct socket *sock, int protocol,
 			goto out_rcu_unlock;
 	}
 
+	sock->ops = answer->ops;
+	answer_prot = answer->prot;
+	answer_flags = answer->flags;
+
 	err = -EPERM;
 	if (sock->type == SOCK_RAW && !kern &&
 	    !ns_capable(net->user_ns, CAP_NET_RAW))
 		goto out_rcu_unlock;
 
-	sock->ops = answer->ops;
-	answer_prot = answer->prot;
-	answer_flags = answer->flags;
+#if IS_ENABLED(CONFIG_AFNETNS)
+	if (unlikely(!kern &&
+		     current->nsproxy->afnet_ns != net->afnet_ns &&
+		     !(answer_flags & INET_PROTOSW_AFNETNS_OK)))
+		goto out_rcu_unlock;
+#endif
+
 	rcu_read_unlock();
 
 	WARN_ON(!answer_prot->slab);
diff --git a/net/ipv6/tcp_ipv6.c b/net/ipv6/tcp_ipv6.c
index 56f742fff96723..5b3b34495d4538 100644
--- a/net/ipv6/tcp_ipv6.c
+++ b/net/ipv6/tcp_ipv6.c
@@ -1944,7 +1944,8 @@ static struct inet_protosw tcpv6_protosw = {
 	.prot		=	&tcpv6_prot,
 	.ops		=	&inet6_stream_ops,
 	.flags		=	INET_PROTOSW_PERMANENT |
-				INET_PROTOSW_ICSK,
+				INET_PROTOSW_ICSK |
+				INET_PROTOSW_AFNETNS_OK,
 };
 
 static int __net_init tcpv6_net_init(struct net *net)
diff --git a/net/ipv6/udp.c b/net/ipv6/udp.c
index d63e0e362fe72b..8707aab65872f9 100644
--- a/net/ipv6/udp.c
+++ b/net/ipv6/udp.c
@@ -1475,7 +1475,8 @@ static struct inet_protosw udpv6_protosw = {
 	.protocol =  IPPROTO_UDP,
 	.prot =      &udpv6_prot,
 	.ops =       &inet6_dgram_ops,
-	.flags =     INET_PROTOSW_PERMANENT,
+	.flags =     INET_PROTOSW_PERMANENT |
+		     INET_PROTOSW_AFNETNS_OK,
 };
 
 int __init udpv6_init(void)
diff --git a/net/ipv6/udplite.c b/net/ipv6/udplite.c
index 2784cc363f2b53..331a6eb7a278da 100644
--- a/net/ipv6/udplite.c
+++ b/net/ipv6/udplite.c
@@ -63,7 +63,8 @@ static struct inet_protosw udplite6_protosw = {
 	.protocol	= IPPROTO_UDPLITE,
 	.prot		= &udplitev6_prot,
 	.ops		= &inet6_dgram_ops,
-	.flags		= INET_PROTOSW_PERMANENT,
+	.flags		= INET_PROTOSW_PERMANENT |
+			  INET_PROTOSW_AFNETNS_OK,
 };
 
 int __init udplitev6_init(void)
-- 
2.9.3
