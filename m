From: Eric Dumazet <eric.dumazet@gmail.com>
Subject: [PATCH net-next] ipv4: harden fnhe_hashfun()
Date: Thu, 04 Sep 2014 08:21:31 -0700
Message-ID: <1409844091.26422.123.camel@edumazet-glaptop2.roam.corp.google.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="UTF-8"
Content-Transfer-Encoding: 7bit
Cc: netdev <netdev@vger.kernel.org>,
	Neal Cardwell <ncardwell@google.com>
To: David Miller <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-pd0-f176.google.com ([209.85.192.176]:34373 "EHLO
	mail-pd0-f176.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1750882AbaIDPVe (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 4 Sep 2014 11:21:34 -0400
Received: by mail-pd0-f176.google.com with SMTP id w10so4449577pde.21
        for <netdev@vger.kernel.org>; Thu, 04 Sep 2014 08:21:33 -0700 (PDT)
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Eric Dumazet <edumazet@google.com>

Lets make this hash function a bit secure, as ICMP attacks are still
in the wild.

Signed-off-by: Eric Dumazet <edumazet@google.com>
---
 include/net/ip_fib.h |    3 ++-
 net/ipv4/route.c     |    8 ++++----
 2 files changed, 6 insertions(+), 5 deletions(-)

diff --git a/include/net/ip_fib.h b/include/net/ip_fib.h
index 9922093f575e..6c8f00236a47 100644
--- a/include/net/ip_fib.h
+++ b/include/net/ip_fib.h
@@ -65,7 +65,8 @@ struct fnhe_hash_bucket {
 	struct fib_nh_exception __rcu	*chain;
 };
 
-#define FNHE_HASH_SIZE		2048
+#define FNHE_HASH_SHIFT		11
+#define FNHE_HASH_SIZE		(1 << FNHE_HASH_SHIFT)
 #define FNHE_RECLAIM_DEPTH	5
 
 struct fib_nh {
diff --git a/net/ipv4/route.c b/net/ipv4/route.c
index eaa4b000c7b4..deb7a2ec3669 100644
--- a/net/ipv4/route.c
+++ b/net/ipv4/route.c
@@ -596,12 +596,12 @@ static struct fib_nh_exception *fnhe_oldest(struct fnhe_hash_bucket *hash)
 
 static inline u32 fnhe_hashfun(__be32 daddr)
 {
+	static u32 fnhe_hashrnd __read_mostly;
 	u32 hval;
 
-	hval = (__force u32) daddr;
-	hval ^= (hval >> 11) ^ (hval >> 22);
-
-	return hval & (FNHE_HASH_SIZE - 1);
+	net_get_random_once(&fnhe_hashrnd, sizeof(fnhe_hashrnd));
+	hval = jhash_1word((__force u32) daddr, fnhe_hashrnd);
+	return hash_32(hval, FNHE_HASH_SHIFT);
 }
 
 static void fill_route_from_fnhe(struct rtable *rt, struct fib_nh_exception *fnhe)
