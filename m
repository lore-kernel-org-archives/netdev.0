From: Eric Dumazet <eric.dumazet@gmail.com>
Subject: [PATCH net-next-2.6] net: inet_add_protocol() can use cmpxchg()
Date: Thu, 09 Sep 2010 00:56:16 +0200
Message-ID: <1283986576.2428.21.camel@edumazet-laptop>
Mime-Version: 1.0
Content-Type: text/plain; charset="UTF-8"
Content-Transfer-Encoding: 7bit
Cc: netdev <netdev@vger.kernel.org>
To: David Miller <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-fx0-f46.google.com ([209.85.161.46]:40255 "EHLO
	mail-fx0-f46.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1755835Ab0IHW4V (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 8 Sep 2010 18:56:21 -0400
Received: by fxm16 with SMTP id 16so528884fxm.19
        for <netdev@vger.kernel.org>; Wed, 08 Sep 2010 15:56:20 -0700 (PDT)
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Use cmpxchg() to get rid of spinlocks in inet_add_protocol() and
friends.

inet_protos[] & inet6_protos[] are moved to read_mostly section

Signed-off-by: Eric Dumazet <eric.dumazet@gmail.com>
---
 net/ipv4/protocol.c |   31 +++++--------------------------
 net/ipv6/protocol.c |   32 ++++----------------------------
 2 files changed, 9 insertions(+), 54 deletions(-)

diff --git a/net/ipv4/protocol.c b/net/ipv4/protocol.c
index f2d2973..65699c2 100644
--- a/net/ipv4/protocol.c
+++ b/net/ipv4/protocol.c
@@ -28,8 +28,7 @@
 #include <linux/spinlock.h>
 #include <net/protocol.h>
 
-const struct net_protocol *inet_protos[MAX_INET_PROTOS] ____cacheline_aligned_in_smp;
-static DEFINE_SPINLOCK(inet_proto_lock);
+const struct net_protocol *inet_protos[MAX_INET_PROTOS] __read_mostly;
 
 /*
  *	Add a protocol handler to the hash tables
@@ -37,20 +36,9 @@ static DEFINE_SPINLOCK(inet_proto_lock);
 
 int inet_add_protocol(const struct net_protocol *prot, unsigned char protocol)
 {
-	int hash, ret;
+	int hash = protocol & (MAX_INET_PROTOS - 1);
 
-	hash = protocol & (MAX_INET_PROTOS - 1);
-
-	spin_lock_bh(&inet_proto_lock);
-	if (inet_protos[hash]) {
-		ret = -1;
-	} else {
-		inet_protos[hash] = prot;
-		ret = 0;
-	}
-	spin_unlock_bh(&inet_proto_lock);
-
-	return ret;
+	return !cmpxchg(&inet_protos[hash], NULL, prot) ? 0 : -1;
 }
 EXPORT_SYMBOL(inet_add_protocol);
 
@@ -60,18 +48,9 @@ EXPORT_SYMBOL(inet_add_protocol);
 
 int inet_del_protocol(const struct net_protocol *prot, unsigned char protocol)
 {
-	int hash, ret;
-
-	hash = protocol & (MAX_INET_PROTOS - 1);
+	int ret, hash = protocol & (MAX_INET_PROTOS - 1);
 
-	spin_lock_bh(&inet_proto_lock);
-	if (inet_protos[hash] == prot) {
-		inet_protos[hash] = NULL;
-		ret = 0;
-	} else {
-		ret = -1;
-	}
-	spin_unlock_bh(&inet_proto_lock);
+	ret = (cmpxchg(&inet_protos[hash], prot, NULL) == prot) ? 0 : -1;
 
 	synchronize_net();
 
diff --git a/net/ipv6/protocol.c b/net/ipv6/protocol.c
index 1fa3468..9bb936a 100644
--- a/net/ipv6/protocol.c
+++ b/net/ipv6/protocol.c
@@ -25,28 +25,14 @@
 #include <linux/spinlock.h>
 #include <net/protocol.h>
 
-const struct inet6_protocol *inet6_protos[MAX_INET_PROTOS];
-static DEFINE_SPINLOCK(inet6_proto_lock);
-
+const struct inet6_protocol *inet6_protos[MAX_INET_PROTOS] __read_mostly;
 
 int inet6_add_protocol(const struct inet6_protocol *prot, unsigned char protocol)
 {
-	int ret, hash = protocol & (MAX_INET_PROTOS - 1);
-
-	spin_lock_bh(&inet6_proto_lock);
-
-	if (inet6_protos[hash]) {
-		ret = -1;
-	} else {
-		inet6_protos[hash] = prot;
-		ret = 0;
-	}
-
-	spin_unlock_bh(&inet6_proto_lock);
+	int hash = protocol & (MAX_INET_PROTOS - 1);
 
-	return ret;
+	return !cmpxchg(&inet6_protos[hash], NULL, prot) ? 0 : -1;
 }
-
 EXPORT_SYMBOL(inet6_add_protocol);
 
 /*
@@ -57,20 +43,10 @@ int inet6_del_protocol(const struct inet6_protocol *prot, unsigned char protocol
 {
 	int ret, hash = protocol & (MAX_INET_PROTOS - 1);
 
-	spin_lock_bh(&inet6_proto_lock);
-
-	if (inet6_protos[hash] != prot) {
-		ret = -1;
-	} else {
-		inet6_protos[hash] = NULL;
-		ret = 0;
-	}
-
-	spin_unlock_bh(&inet6_proto_lock);
+	ret = (cmpxchg(&inet6_protos[hash], prot, NULL) == prot) ? 0 : -1;
 
 	synchronize_net();
 
 	return ret;
 }
-
 EXPORT_SYMBOL(inet6_del_protocol);


