From: Eric Dumazet <eric.dumazet@gmail.com>
Subject: [PATCH net-next] net: defer net_secret[] initialization
Date: Mon, 29 Apr 2013 08:58:52 -0700
Message-ID: <1367251132.8964.325.camel@edumazet-glaptop>
Mime-Version: 1.0
Content-Type: text/plain; charset="UTF-8"
Content-Transfer-Encoding: 7bit
Cc: netdev <netdev@vger.kernel.org>
To: David Miller <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-da0-f46.google.com ([209.85.210.46]:57785 "EHLO
	mail-da0-f46.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1756890Ab3D2P7B (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 29 Apr 2013 11:59:01 -0400
Received: by mail-da0-f46.google.com with SMTP id x4so2470315daj.19
        for <netdev@vger.kernel.org>; Mon, 29 Apr 2013 08:59:00 -0700 (PDT)
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Eric Dumazet <edumazet@google.com>

Instead of feeding net_secret[] at boot time, defer the init
at the point first socket is created.

This permits some platforms to use better entropy sources than
the ones available at boot time.

Signed-off-by: Eric Dumazet <edumazet@google.com>
---
 include/net/secure_seq.h |    1 +
 net/core/secure_seq.c    |    4 +---
 net/ipv4/af_inet.c       |    5 ++++-
 3 files changed, 6 insertions(+), 4 deletions(-)

diff --git a/include/net/secure_seq.h b/include/net/secure_seq.h
index c2e542b..6ca975b 100644
--- a/include/net/secure_seq.h
+++ b/include/net/secure_seq.h
@@ -3,6 +3,7 @@
 
 #include <linux/types.h>
 
+extern void net_secret_init(void);
 extern __u32 secure_ip_id(__be32 daddr);
 extern __u32 secure_ipv6_id(const __be32 daddr[4]);
 extern u32 secure_ipv4_port_ephemeral(__be32 saddr, __be32 daddr, __be16 dport);
diff --git a/net/core/secure_seq.c b/net/core/secure_seq.c
index e61a8bb..6a2f13c 100644
--- a/net/core/secure_seq.c
+++ b/net/core/secure_seq.c
@@ -12,12 +12,10 @@
 
 static u32 net_secret[MD5_MESSAGE_BYTES / 4] ____cacheline_aligned;
 
-static int __init net_secret_init(void)
+void net_secret_init(void)
 {
 	get_random_bytes(net_secret, sizeof(net_secret));
-	return 0;
 }
-late_initcall(net_secret_init);
 
 #ifdef CONFIG_INET
 static u32 seq_scale(u32 seq)
diff --git a/net/ipv4/af_inet.c b/net/ipv4/af_inet.c
index 93824c5..c61b3bb 100644
--- a/net/ipv4/af_inet.c
+++ b/net/ipv4/af_inet.c
@@ -114,6 +114,7 @@
 #include <net/inet_common.h>
 #include <net/xfrm.h>
 #include <net/net_namespace.h>
+#include <net/secure_seq.h>
 #ifdef CONFIG_IP_MROUTE
 #include <linux/mroute.h>
 #endif
@@ -262,8 +263,10 @@ void build_ehash_secret(void)
 		get_random_bytes(&rnd, sizeof(rnd));
 	} while (rnd == 0);
 
-	if (cmpxchg(&inet_ehash_secret, 0, rnd) == 0)
+	if (cmpxchg(&inet_ehash_secret, 0, rnd) == 0) {
 		get_random_bytes(&ipv6_hash_secret, sizeof(ipv6_hash_secret));
+		net_secret_init();
+	}
 }
 EXPORT_SYMBOL(build_ehash_secret);
 
