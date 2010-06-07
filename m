From: Eric Dumazet <eric.dumazet@gmail.com>
Subject: [PATCH net-next-2.6] ipv4: avoid two atomic ops in ip_rt_redirect()
Date: Mon, 07 Jun 2010 15:23:03 +0200
Message-ID: <1275916983.2545.73.camel@edumazet-laptop>
Mime-Version: 1.0
Content-Type: text/plain; charset="UTF-8"
Content-Transfer-Encoding: 7bit
Cc: netdev <netdev@vger.kernel.org>
To: David Miller <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-ww0-f46.google.com ([74.125.82.46]:45257 "EHLO
	mail-ww0-f46.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751004Ab0FGNXH (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 7 Jun 2010 09:23:07 -0400
Received: by wwe15 with SMTP id 15so385093wwe.19
        for <netdev@vger.kernel.org>; Mon, 07 Jun 2010 06:23:05 -0700 (PDT)
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

in_dev_get() -> __in_dev_get_rcu() in a rcu protected function.

Signed-off-by: Eric Dumazet <eric.dumazet@gmail.com>
---
 net/ipv4/route.c |    9 ++-------
 1 file changed, 2 insertions(+), 7 deletions(-)

diff --git a/net/ipv4/route.c b/net/ipv4/route.c
index 7b8eacd..0c30534 100644
--- a/net/ipv4/route.c
+++ b/net/ipv4/route.c
@@ -1343,11 +1343,12 @@ static void rt_del(unsigned hash, struct rtable *rt)
 	spin_unlock_bh(rt_hash_lock_addr(hash));
 }
 
+/* called in rcu_read_lock() section */
 void ip_rt_redirect(__be32 old_gw, __be32 daddr, __be32 new_gw,
 		    __be32 saddr, struct net_device *dev)
 {
 	int i, k;
-	struct in_device *in_dev = in_dev_get(dev);
+	struct in_device *in_dev = __in_dev_get_rcu(dev);
 	struct rtable *rth, **rthp;
 	__be32  skeys[2] = { saddr, 0 };
 	int  ikeys[2] = { dev->ifindex, 0 };
@@ -1383,7 +1384,6 @@ void ip_rt_redirect(__be32 old_gw, __be32 daddr, __be32 new_gw,
 
 			rthp=&rt_hash_table[hash].chain;
 
-			rcu_read_lock();
 			while ((rth = rcu_dereference(*rthp)) != NULL) {
 				struct rtable *rt;
 
@@ -1405,12 +1405,10 @@ void ip_rt_redirect(__be32 old_gw, __be32 daddr, __be32 new_gw,
 					break;
 
 				dst_hold(&rth->u.dst);
-				rcu_read_unlock();
 
 				rt = dst_alloc(&ipv4_dst_ops);
 				if (rt == NULL) {
 					ip_rt_put(rth);
-					in_dev_put(in_dev);
 					return;
 				}
 
@@ -1463,12 +1461,10 @@ void ip_rt_redirect(__be32 old_gw, __be32 daddr, __be32 new_gw,
 					ip_rt_put(rt);
 				goto do_next;
 			}
-			rcu_read_unlock();
 		do_next:
 			;
 		}
 	}
-	in_dev_put(in_dev);
 	return;
 
 reject_redirect:
@@ -1479,7 +1475,6 @@ reject_redirect:
 		       &old_gw, dev->name, &new_gw,
 		       &saddr, &daddr);
 #endif
-	in_dev_put(in_dev);
 }
 
 static struct dst_entry *ipv4_negative_advice(struct dst_entry *dst)


