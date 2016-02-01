From: Xin Long <lucien.xin@gmail.com>
Subject: [PATCH net] route: add rcu_read_lock when lookup route and update fnhe in __ip_do_redirect
Date: Mon,  1 Feb 2016 18:22:12 +0800
Message-ID: <db60649416c596fc5e76930484b726cb180b14b8.1454322132.git.lucien.xin@gmail.com>
Cc: davem@davemloft.net, hannes@stressinduktion.org
To: network dev <netdev@vger.kernel.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-pa0-f68.google.com ([209.85.220.68]:35098 "EHLO
	mail-pa0-f68.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751886AbcBAKWV (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 1 Feb 2016 05:22:21 -0500
Received: by mail-pa0-f68.google.com with SMTP id gi1so7030865pac.2
        for <netdev@vger.kernel.org>; Mon, 01 Feb 2016 02:22:20 -0800 (PST)
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

The only free exceptions is free_nh_exceptions():
  free_fib_info_rcu()->free_nh_exceptions()
It is in call_rcu():
 free_fib_info():
      call_rcu(&fi->rcu, free_fib_info_rcu);
There is no issue, because it's protected by fib_info rcu.

In ip_route_input(output)_slow:
 rcu_read_lock()
 fib_lookup() [check fib_info dead]
 __mkroute_input(ouput) -> find_exception()
 rcu_read_unlock()
Also safe.

The same thing is done in __ip_rt_update_pmtu():
     rcu_read_lock();
     if (fib_lookup(dev_net(dst->dev), fl4, &res, 0) == 0) {
         struct fib_nh *nh = &FIB_RES_NH(res);

         update_or_create_fnhe(nh, fl4->daddr, 0, mtu,
                       jiffies + ip_rt_mtu_expires);
     }
     rcu_read_unlock();

But there may be an issue in __ip_do_redirect():
         } else {
             if (fib_lookup(net, fl4, &res, 0) == 0) {
                 struct fib_nh *nh = &FIB_RES_NH(res);

                 update_or_create_fnhe(nh, fl4->daddr, new_gw,
                               0, 0);
             }

Which is not running in rcu_read_lock(), it may update a fnhe that
has been freed.

So fix it by adding rcu_read_lock() just like other parts.

Signed-off-by: Xin Long <lucien.xin@gmail.com>
---
 net/ipv4/route.c | 2 ++
 1 file changed, 2 insertions(+)

diff --git a/net/ipv4/route.c b/net/ipv4/route.c
index 85f184e..08b9e6c 100644
--- a/net/ipv4/route.c
+++ b/net/ipv4/route.c
@@ -751,12 +751,14 @@ static void __ip_do_redirect(struct rtable *rt, struct sk_buff *skb, struct flow
 		if (!(n->nud_state & NUD_VALID)) {
 			neigh_event_send(n, NULL);
 		} else {
+			rcu_read_lock();
 			if (fib_lookup(net, fl4, &res, 0) == 0) {
 				struct fib_nh *nh = &FIB_RES_NH(res);
 
 				update_or_create_fnhe(nh, fl4->daddr, new_gw,
 						      0, 0);
 			}
+			rcu_read_unlock();
 			if (kill_route)
 				rt->dst.obsolete = DST_OBSOLETE_KILL;
 			call_netevent_notifiers(NETEVENT_NEIGH_UPDATE, n);
-- 
2.1.0
