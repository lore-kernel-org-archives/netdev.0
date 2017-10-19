From: Xin Long <lucien.xin@gmail.com>
Subject: [PATCH net 2/2] inet_diag: request _diag module only when the proto has been registered
Date: Thu, 19 Oct 2017 15:32:25 +0800
Message-ID: <024cfc1e036f4780ea668a33c463f01eed022633.1508398111.git.lucien.xin@gmail.com>
References: <cover.1508398111.git.lucien.xin@gmail.com>
 <e36e2f048c38d63f10386798dc1eced0882df9bf.1508398111.git.lucien.xin@gmail.com>
Cc: davem@davemloft.net, Eric Dumazet <edumazet@google.com>,
        Marcelo Ricardo Leitner <marcelo.leitner@gmail.com>,
        Sabrina Dubroca <sd@queasysnail.net>
To: network dev <netdev@vger.kernel.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-pg0-f65.google.com ([74.125.83.65]:50798 "EHLO
        mail-pg0-f65.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1751724AbdJSHcv (ORCPT
        <rfc822;netdev@vger.kernel.org>); Thu, 19 Oct 2017 03:32:51 -0400
Received: by mail-pg0-f65.google.com with SMTP id y7so6420703pgb.7
        for <netdev@vger.kernel.org>; Thu, 19 Oct 2017 00:32:51 -0700 (PDT)
In-Reply-To: <e36e2f048c38d63f10386798dc1eced0882df9bf.1508398111.git.lucien.xin@gmail.com>
In-Reply-To: <cover.1508398111.git.lucien.xin@gmail.com>
References: <cover.1508398111.git.lucien.xin@gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

The patch 'sock_diag: request _diag module only when the family has
been registered' fixed a security issue for sock_diag, the same fix
is needed for inet_diag module when requesting _diag module.

Fixes: 305e1e969114 ("[INET]: Let inet_diag and friends autoload")
Reported-by: Sabrina Dubroca <sd@queasysnail.net>
Signed-off-by: Xin Long <lucien.xin@gmail.com>
---
 include/net/protocol.h | 1 +
 net/ipv4/inet_diag.c   | 3 ++-
 net/ipv4/protocol.c    | 6 ++++++
 3 files changed, 9 insertions(+), 1 deletion(-)

diff --git a/include/net/protocol.h b/include/net/protocol.h
index 4fc75f7..bf0dcc2 100644
--- a/include/net/protocol.h
+++ b/include/net/protocol.h
@@ -103,6 +103,7 @@ extern struct inet6_protocol __rcu *inet6_protos[MAX_INET_PROTOS];
 
 int inet_add_protocol(const struct net_protocol *prot, unsigned char num);
 int inet_del_protocol(const struct net_protocol *prot, unsigned char num);
+bool inet_proto_is_added(unsigned char num);
 int inet_add_offload(const struct net_offload *prot, unsigned char num);
 int inet_del_offload(const struct net_offload *prot, unsigned char num);
 void inet_register_protosw(struct inet_protosw *p);
diff --git a/net/ipv4/inet_diag.c b/net/ipv4/inet_diag.c
index c9c35b6..1460031 100644
--- a/net/ipv4/inet_diag.c
+++ b/net/ipv4/inet_diag.c
@@ -27,6 +27,7 @@
 #include <net/inet_hashtables.h>
 #include <net/inet_timewait_sock.h>
 #include <net/inet6_hashtables.h>
+#include <net/protocol.h>
 #include <net/netlink.h>
 
 #include <linux/inet.h>
@@ -52,7 +53,7 @@ static DEFINE_MUTEX(inet_diag_table_mutex);
 
 static const struct inet_diag_handler *inet_diag_lock_handler(int proto)
 {
-	if (!inet_diag_table[proto])
+	if (!inet_diag_table[proto] && inet_proto_is_added(proto))
 		request_module("net-pf-%d-proto-%d-type-%d-%d", PF_NETLINK,
 			       NETLINK_SOCK_DIAG, AF_INET, proto);
 
diff --git a/net/ipv4/protocol.c b/net/ipv4/protocol.c
index 32a691b..183386a 100644
--- a/net/ipv4/protocol.c
+++ b/net/ipv4/protocol.c
@@ -77,3 +77,9 @@ int inet_del_offload(const struct net_offload *prot, unsigned char protocol)
 	return ret;
 }
 EXPORT_SYMBOL(inet_del_offload);
+
+bool inet_proto_is_added(unsigned char protocol)
+{
+	return !!rcu_access_pointer(inet_protos[protocol]);
+}
+EXPORT_SYMBOL(inet_proto_is_added);
-- 
2.1.0
