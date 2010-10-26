From: Eric Dumazet <eric.dumazet@gmail.com>
Subject: [PATCH] net: add __rcu annotations to protocol
Date: Tue, 26 Oct 2010 09:02:28 +0200
Message-ID: <1288076548.3296.89.camel@edumazet-laptop>
Mime-Version: 1.0
Content-Type: text/plain; charset="UTF-8"
Content-Transfer-Encoding: 7bit
Cc: netdev <netdev@vger.kernel.org>
To: David Miller <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-wy0-f174.google.com ([74.125.82.174]:40428 "EHLO
	mail-wy0-f174.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1755785Ab0JZHCi (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 26 Oct 2010 03:02:38 -0400
Received: by mail-wy0-f174.google.com with SMTP id 28so4262799wyf.19
        for <netdev@vger.kernel.org>; Tue, 26 Oct 2010 00:02:37 -0700 (PDT)
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Add __rcu annotations to :
        struct net_protocol *inet_protos
        struct net_protocol *inet6_protos

And use appropriate casts to reduce sparse warnings if
CONFIG_SPARSE_RCU_POINTER=y

Signed-off-by: Eric Dumazet <eric.dumazet@gmail.com>
---
 include/net/protocol.h |    4 ++--
 net/ipv4/protocol.c    |    8 +++++---
 net/ipv6/protocol.c    |    8 +++++---
 3 files changed, 12 insertions(+), 8 deletions(-)

diff --git a/include/net/protocol.h b/include/net/protocol.h
index f1effdd..dc07495 100644
--- a/include/net/protocol.h
+++ b/include/net/protocol.h
@@ -89,10 +89,10 @@ struct inet_protosw {
 #define INET_PROTOSW_PERMANENT 0x02  /* Permanent protocols are unremovable. */
 #define INET_PROTOSW_ICSK      0x04  /* Is this an inet_connection_sock? */
 
-extern const struct net_protocol *inet_protos[MAX_INET_PROTOS];
+extern const struct net_protocol __rcu *inet_protos[MAX_INET_PROTOS];
 
 #if defined(CONFIG_IPV6) || defined (CONFIG_IPV6_MODULE)
-extern const struct inet6_protocol *inet6_protos[MAX_INET_PROTOS];
+extern const struct inet6_protocol __rcu *inet6_protos[MAX_INET_PROTOS];
 #endif
 
 extern int	inet_add_protocol(const struct net_protocol *prot, unsigned char num);
diff --git a/net/ipv4/protocol.c b/net/ipv4/protocol.c
index 65699c2..9ae5c01 100644
--- a/net/ipv4/protocol.c
+++ b/net/ipv4/protocol.c
@@ -28,7 +28,7 @@
 #include <linux/spinlock.h>
 #include <net/protocol.h>
 
-const struct net_protocol *inet_protos[MAX_INET_PROTOS] __read_mostly;
+const struct net_protocol __rcu *inet_protos[MAX_INET_PROTOS] __read_mostly;
 
 /*
  *	Add a protocol handler to the hash tables
@@ -38,7 +38,8 @@ int inet_add_protocol(const struct net_protocol *prot, unsigned char protocol)
 {
 	int hash = protocol & (MAX_INET_PROTOS - 1);
 
-	return !cmpxchg(&inet_protos[hash], NULL, prot) ? 0 : -1;
+	return !cmpxchg((const struct net_protocol **)&inet_protos[hash],
+			NULL, prot) ? 0 : -1;
 }
 EXPORT_SYMBOL(inet_add_protocol);
 
@@ -50,7 +51,8 @@ int inet_del_protocol(const struct net_protocol *prot, unsigned char protocol)
 {
 	int ret, hash = protocol & (MAX_INET_PROTOS - 1);
 
-	ret = (cmpxchg(&inet_protos[hash], prot, NULL) == prot) ? 0 : -1;
+	ret = (cmpxchg((const struct net_protocol **)&inet_protos[hash],
+		       prot, NULL) == prot) ? 0 : -1;
 
 	synchronize_net();
 
diff --git a/net/ipv6/protocol.c b/net/ipv6/protocol.c
index 9bb936a..9a7978f 100644
--- a/net/ipv6/protocol.c
+++ b/net/ipv6/protocol.c
@@ -25,13 +25,14 @@
 #include <linux/spinlock.h>
 #include <net/protocol.h>
 
-const struct inet6_protocol *inet6_protos[MAX_INET_PROTOS] __read_mostly;
+const struct inet6_protocol __rcu *inet6_protos[MAX_INET_PROTOS] __read_mostly;
 
 int inet6_add_protocol(const struct inet6_protocol *prot, unsigned char protocol)
 {
 	int hash = protocol & (MAX_INET_PROTOS - 1);
 
-	return !cmpxchg(&inet6_protos[hash], NULL, prot) ? 0 : -1;
+	return !cmpxchg((const struct inet6_protocol **)&inet6_protos[hash],
+			NULL, prot) ? 0 : -1;
 }
 EXPORT_SYMBOL(inet6_add_protocol);
 
@@ -43,7 +44,8 @@ int inet6_del_protocol(const struct inet6_protocol *prot, unsigned char protocol
 {
 	int ret, hash = protocol & (MAX_INET_PROTOS - 1);
 
-	ret = (cmpxchg(&inet6_protos[hash], prot, NULL) == prot) ? 0 : -1;
+	ret = (cmpxchg((const struct inet6_protocol **)&inet6_protos[hash],
+		       prot, NULL) == prot) ? 0 : -1;
 
 	synchronize_net();
 


