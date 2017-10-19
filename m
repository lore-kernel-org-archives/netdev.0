From: Xin Long <lucien.xin@gmail.com>
Subject: [PATCH net 1/2] sock_diag: request _diag module only when the family has been registered
Date: Thu, 19 Oct 2017 15:32:24 +0800
Message-ID: <e36e2f048c38d63f10386798dc1eced0882df9bf.1508398111.git.lucien.xin@gmail.com>
References: <cover.1508398111.git.lucien.xin@gmail.com>
Cc: davem@davemloft.net, Eric Dumazet <edumazet@google.com>,
        Marcelo Ricardo Leitner <marcelo.leitner@gmail.com>,
        Sabrina Dubroca <sd@queasysnail.net>
To: network dev <netdev@vger.kernel.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-pf0-f196.google.com ([209.85.192.196]:46388 "EHLO
        mail-pf0-f196.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1751724AbdJSHcn (ORCPT
        <rfc822;netdev@vger.kernel.org>); Thu, 19 Oct 2017 03:32:43 -0400
Received: by mail-pf0-f196.google.com with SMTP id p87so5911257pfj.3
        for <netdev@vger.kernel.org>; Thu, 19 Oct 2017 00:32:42 -0700 (PDT)
In-Reply-To: <cover.1508398111.git.lucien.xin@gmail.com>
In-Reply-To: <cover.1508398111.git.lucien.xin@gmail.com>
References: <cover.1508398111.git.lucien.xin@gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Now when using 'ss' in iproute, kernel would try to load all _diag
modules. It causes the corresponding family or proto modules to be
loaded as well.

Like after 'ss -a', sctp, dccp, af_packet(if it works as a moudle)
will be loaded.

As these family or proto modules are loaded unexpectly, this might
have some security implications.

This patch is to introduce sock_diag_request_module() in sock_diag
where we only request _diag module when it's corresponding family
has been registered. The fix for inet_diag will be done in later
patch.

Note that we can't just load _diag module without the family or
proto loaded, as some symbols in _diag module are from the family
or proto moudle.

Fixes: 8ef874bfc729 ("sock_diag: Move the sock_ code to net/core/")
Reported-by: Sabrina Dubroca <sd@queasysnail.net>
Signed-off-by: Xin Long <lucien.xin@gmail.com>
---
 include/linux/net.h  |  1 +
 net/core/sock_diag.c | 21 +++++++++++++--------
 net/socket.c         |  5 +++++
 3 files changed, 19 insertions(+), 8 deletions(-)

diff --git a/include/linux/net.h b/include/linux/net.h
index d97d80d..6c7cf09 100644
--- a/include/linux/net.h
+++ b/include/linux/net.h
@@ -225,6 +225,7 @@ enum {
 int sock_wake_async(struct socket_wq *sk_wq, int how, int band);
 int sock_register(const struct net_proto_family *fam);
 void sock_unregister(int family);
+bool sock_is_registered(int family);
 int __sock_create(struct net *net, int family, int type, int proto,
 		  struct socket **res, int kern);
 int sock_create(int family, int type, int proto, struct socket **res);
diff --git a/net/core/sock_diag.c b/net/core/sock_diag.c
index 217f4e3..643a446 100644
--- a/net/core/sock_diag.c
+++ b/net/core/sock_diag.c
@@ -207,6 +207,15 @@ void sock_diag_unregister(const struct sock_diag_handler *hnld)
 }
 EXPORT_SYMBOL_GPL(sock_diag_unregister);
 
+static int sock_diag_request_module(int family)
+{
+	if (!sock_is_registered(family))
+		return -ENOENT;
+
+	return request_module("net-pf-%d-proto-%d-type-%d", PF_NETLINK,
+			      NETLINK_SOCK_DIAG, family);
+}
+
 static int __sock_diag_cmd(struct sk_buff *skb, struct nlmsghdr *nlh)
 {
 	int err;
@@ -220,8 +229,7 @@ static int __sock_diag_cmd(struct sk_buff *skb, struct nlmsghdr *nlh)
 		return -EINVAL;
 
 	if (sock_diag_handlers[req->sdiag_family] == NULL)
-		request_module("net-pf-%d-proto-%d-type-%d", PF_NETLINK,
-				NETLINK_SOCK_DIAG, req->sdiag_family);
+		sock_diag_request_module(req->sdiag_family);
 
 	mutex_lock(&sock_diag_table_mutex);
 	hndl = sock_diag_handlers[req->sdiag_family];
@@ -247,8 +255,7 @@ static int sock_diag_rcv_msg(struct sk_buff *skb, struct nlmsghdr *nlh,
 	case TCPDIAG_GETSOCK:
 	case DCCPDIAG_GETSOCK:
 		if (inet_rcv_compat == NULL)
-			request_module("net-pf-%d-proto-%d-type-%d", PF_NETLINK,
-					NETLINK_SOCK_DIAG, AF_INET);
+			sock_diag_request_module(AF_INET);
 
 		mutex_lock(&sock_diag_table_mutex);
 		if (inet_rcv_compat != NULL)
@@ -281,14 +288,12 @@ static int sock_diag_bind(struct net *net, int group)
 	case SKNLGRP_INET_TCP_DESTROY:
 	case SKNLGRP_INET_UDP_DESTROY:
 		if (!sock_diag_handlers[AF_INET])
-			request_module("net-pf-%d-proto-%d-type-%d", PF_NETLINK,
-				       NETLINK_SOCK_DIAG, AF_INET);
+			sock_diag_request_module(AF_INET);
 		break;
 	case SKNLGRP_INET6_TCP_DESTROY:
 	case SKNLGRP_INET6_UDP_DESTROY:
 		if (!sock_diag_handlers[AF_INET6])
-			request_module("net-pf-%d-proto-%d-type-%d", PF_NETLINK,
-				       NETLINK_SOCK_DIAG, AF_INET);
+			sock_diag_request_module(AF_INET);
 		break;
 	}
 	return 0;
diff --git a/net/socket.c b/net/socket.c
index c729625..733d657 100644
--- a/net/socket.c
+++ b/net/socket.c
@@ -2590,6 +2590,11 @@ void sock_unregister(int family)
 }
 EXPORT_SYMBOL(sock_unregister);
 
+bool sock_is_registered(int family)
+{
+	return family < NPROTO && rcu_access_pointer(net_families[family]);
+}
+
 static int __init sock_init(void)
 {
 	int err;
-- 
2.1.0
