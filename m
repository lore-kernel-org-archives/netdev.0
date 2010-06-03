From: Eric Dumazet <eric.dumazet@gmail.com>
Subject: [PATCH net-next-2.6] ipv4: RCU changes in __mkroute_input()
Date: Thu, 03 Jun 2010 16:13:21 +0200
Message-ID: <1275574401.2456.55.camel@edumazet-laptop>
Mime-Version: 1.0
Content-Type: text/plain; charset="UTF-8"
Content-Transfer-Encoding: 7bit
Cc: netdev <netdev@vger.kernel.org>
To: David Miller <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-wy0-f174.google.com ([74.125.82.174]:64472 "EHLO
	mail-wy0-f174.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1755123Ab0FCOUA (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 3 Jun 2010 10:20:00 -0400
Received: by wyi11 with SMTP id 11so86974wyi.19
        for <netdev@vger.kernel.org>; Thu, 03 Jun 2010 07:19:59 -0700 (PDT)
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Avoid two atomic ops on output device refcount

Signed-off-by: Eric Dumazet <eric.dumazet@gmail.com>
---
 net/ipv4/route.c |    8 +++-----
 1 files changed, 3 insertions(+), 5 deletions(-)

diff --git a/net/ipv4/route.c b/net/ipv4/route.c
index 1cfe0d1..7b8eacd 100644
--- a/net/ipv4/route.c
+++ b/net/ipv4/route.c
@@ -1957,22 +1957,22 @@ static void ip_handle_martian_source(struct net_device *dev,
 #endif
 }
 
+/* called in rcu_read_lock() section */
 static int __mkroute_input(struct sk_buff *skb,
 			   struct fib_result *res,
 			   struct in_device *in_dev,
 			   __be32 daddr, __be32 saddr, u32 tos,
 			   struct rtable **result)
 {
-
 	struct rtable *rth;
 	int err;
 	struct in_device *out_dev;
-	unsigned flags = 0;
+	unsigned int flags = 0;
 	__be32 spec_dst;
 	u32 itag;
 
 	/* get a working reference to the output device */
-	out_dev = in_dev_get(FIB_RES_DEV(*res));
+	out_dev = __in_dev_get_rcu(FIB_RES_DEV(*res));
 	if (out_dev == NULL) {
 		if (net_ratelimit())
 			printk(KERN_CRIT "Bug in ip_route_input" \
@@ -2053,8 +2053,6 @@ static int __mkroute_input(struct sk_buff *skb,
 	*result = rth;
 	err = 0;
  cleanup:
-	/* release the working reference to the output device */
-	in_dev_put(out_dev);
 	return err;
 }
 


