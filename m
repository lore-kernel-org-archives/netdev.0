From: Xin Long <lucien.xin@gmail.com>
Subject: [PATCH net] sock_diag: request _diag module only when the family or proto has been registered
Date: Tue, 17 Oct 2017 13:13:56 +0800
Message-ID: <69c0824505548e733f2f7be3ff288f2c4e461afa.1508217236.git.lucien.xin@gmail.com>
Cc: davem@davemloft.net,
        Marcelo Ricardo Leitner <marcelo.leitner@gmail.com>,
        Sabrina Dubroca <sd@queasysnail.net>
To: network dev <netdev@vger.kernel.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-pg0-f67.google.com ([74.125.83.67]:53101 "EHLO
        mail-pg0-f67.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1754398AbdJQFOF (ORCPT
        <rfc822;netdev@vger.kernel.org>); Tue, 17 Oct 2017 01:14:05 -0400
Received: by mail-pg0-f67.google.com with SMTP id a192so529614pge.9
        for <netdev@vger.kernel.org>; Mon, 16 Oct 2017 22:14:05 -0700 (PDT)
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Now when using 'ss' in iproute, kernel would try to load all _diag
modules. It causes the corresponding family or proto modules to be
loaded as well.

Like after 'ss -a', sctp, dccp, af_packet(if it works as a moudle)
will be loaded.

As these family or proto modules are loaded unexpectly, this might
have some security implications.

This patch is to introduce sock_diag_request_module() in which we
only request the _diag module when it's corresponding family or
proto has been registered.

Note that we can't just load _diag module without the family or
proto loaded, as some symbols in _diag module are from the family
or proto moudle.

Reported-by: Sabrina Dubroca <sd@queasysnail.net>
Signed-off-by: Xin Long <lucien.xin@gmail.com>
---
 include/linux/net.h       |  1 +
 include/linux/sock_diag.h |  1 +
 net/core/sock_diag.c      | 32 ++++++++++++++++++++++++--------
 net/ipv4/inet_diag.c      |  3 +--
 net/socket.c              |  5 +++++
 5 files changed, 32 insertions(+), 10 deletions(-)

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
diff --git a/include/linux/sock_diag.h b/include/linux/sock_diag.h
index a2f8109..e9a1b8d 100644
--- a/include/linux/sock_diag.h
+++ b/include/linux/sock_diag.h
@@ -77,4 +77,5 @@ bool sock_diag_has_destroy_listeners(const struct sock *sk)
 void sock_diag_broadcast_destroy(struct sock *sk);
 
 int sock_diag_destroy(struct sock *sk, int err);
+int sock_diag_request_module(int family, int protocol);
 #endif
diff --git a/net/core/sock_diag.c b/net/core/sock_diag.c
index 217f4e3..caad6b6 100644
--- a/net/core/sock_diag.c
+++ b/net/core/sock_diag.c
@@ -7,6 +7,7 @@
 #include <net/net_namespace.h>
 #include <linux/module.h>
 #include <net/sock.h>
+#include <net/protocol.h>
 #include <linux/kernel.h>
 #include <linux/tcp.h>
 #include <linux/workqueue.h>
@@ -207,6 +208,25 @@ void sock_diag_unregister(const struct sock_diag_handler *hnld)
 }
 EXPORT_SYMBOL_GPL(sock_diag_unregister);
 
+int sock_diag_request_module(int family, int protocol)
+{
+	if (!protocol) {
+		if (!sock_is_registered(family))
+			return -ENOENT;
+
+		return request_module("net-pf-%d-proto-%d-type-%d", PF_NETLINK,
+				      NETLINK_SOCK_DIAG, family);
+	}
+
+	if (family == AF_INET &&
+	    !rcu_access_pointer(inet_protos[protocol]))
+		return -ENOENT;
+
+	return request_module("net-pf-%d-proto-%d-type-%d-%d", PF_NETLINK,
+			      NETLINK_SOCK_DIAG, family, protocol);
+}
+EXPORT_SYMBOL_GPL(sock_diag_request_module);
+
 static int __sock_diag_cmd(struct sk_buff *skb, struct nlmsghdr *nlh)
 {
 	int err;
@@ -220,8 +240,7 @@ static int __sock_diag_cmd(struct sk_buff *skb, struct nlmsghdr *nlh)
 		return -EINVAL;
 
 	if (sock_diag_handlers[req->sdiag_family] == NULL)
-		request_module("net-pf-%d-proto-%d-type-%d", PF_NETLINK,
-				NETLINK_SOCK_DIAG, req->sdiag_family);
+		sock_diag_request_module(req->sdiag_family, 0);
 
 	mutex_lock(&sock_diag_table_mutex);
 	hndl = sock_diag_handlers[req->sdiag_family];
@@ -247,8 +266,7 @@ static int sock_diag_rcv_msg(struct sk_buff *skb, struct nlmsghdr *nlh,
 	case TCPDIAG_GETSOCK:
 	case DCCPDIAG_GETSOCK:
 		if (inet_rcv_compat == NULL)
-			request_module("net-pf-%d-proto-%d-type-%d", PF_NETLINK,
-					NETLINK_SOCK_DIAG, AF_INET);
+			sock_diag_request_module(AF_INET, 0);
 
 		mutex_lock(&sock_diag_table_mutex);
 		if (inet_rcv_compat != NULL)
@@ -281,14 +299,12 @@ static int sock_diag_bind(struct net *net, int group)
 	case SKNLGRP_INET_TCP_DESTROY:
 	case SKNLGRP_INET_UDP_DESTROY:
 		if (!sock_diag_handlers[AF_INET])
-			request_module("net-pf-%d-proto-%d-type-%d", PF_NETLINK,
-				       NETLINK_SOCK_DIAG, AF_INET);
+			sock_diag_request_module(AF_INET, 0);
 		break;
 	case SKNLGRP_INET6_TCP_DESTROY:
 	case SKNLGRP_INET6_UDP_DESTROY:
 		if (!sock_diag_handlers[AF_INET6])
-			request_module("net-pf-%d-proto-%d-type-%d", PF_NETLINK,
-				       NETLINK_SOCK_DIAG, AF_INET);
+			sock_diag_request_module(AF_INET, 0);
 		break;
 	}
 	return 0;
diff --git a/net/ipv4/inet_diag.c b/net/ipv4/inet_diag.c
index c9c35b6..d10c8fa 100644
--- a/net/ipv4/inet_diag.c
+++ b/net/ipv4/inet_diag.c
@@ -53,8 +53,7 @@ static DEFINE_MUTEX(inet_diag_table_mutex);
 static const struct inet_diag_handler *inet_diag_lock_handler(int proto)
 {
 	if (!inet_diag_table[proto])
-		request_module("net-pf-%d-proto-%d-type-%d-%d", PF_NETLINK,
-			       NETLINK_SOCK_DIAG, AF_INET, proto);
+		sock_diag_request_module(AF_INET, proto);
 
 	mutex_lock(&inet_diag_table_mutex);
 	if (!inet_diag_table[proto])
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
