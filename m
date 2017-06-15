From: Xin Long <lucien.xin@gmail.com>
Subject: [PATCH net] ipv6: fix calling in6_ifa_hold incorrectly for dad work
Date: Thu, 15 Jun 2017 16:33:58 +0800
Message-ID: <2d710ef288455604efab24f72f4476ec5edb13bb.1497515638.git.lucien.xin@gmail.com>
Cc: davem@davemloft.net, hannes@stressinduktion.org
To: network dev <netdev@vger.kernel.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-pf0-f195.google.com ([209.85.192.195]:35228 "EHLO
        mail-pf0-f195.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1750774AbdFOIeJ (ORCPT
        <rfc822;netdev@vger.kernel.org>); Thu, 15 Jun 2017 04:34:09 -0400
Received: by mail-pf0-f195.google.com with SMTP id s66so1036225pfs.2
        for <netdev@vger.kernel.org>; Thu, 15 Jun 2017 01:34:09 -0700 (PDT)
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Now when starting the dad work in addrconf_mod_dad_work, if the dad work
is idle and queued, it needs to hold ifa.

The problem is there's one gap in [1], during which if the pending dad work
is removed elsewhere. It will miss to hold ifa, but the dad word is still
idea and queue.

        if (!delayed_work_pending(&ifp->dad_work))
                in6_ifa_hold(ifp);
                    <--------------[1]
        mod_delayed_work(addrconf_wq, &ifp->dad_work, delay);

An use-after-free issue can be caused by this.

Chen Wei found this issue when WARN_ON(!hlist_unhashed(&ifp->addr_lst)) in
net6_ifa_finish_destroy was hit because of it.

As Hannes' suggestion, this patch is to fix it by holding ifa first in
addrconf_mod_dad_work, then calling mod_delayed_work and putting ifa if
the dad_work is already in queue.

Note that this patch did not choose to fix it with:

  if (!mod_delayed_work(delay))
          in6_ifa_hold(ifp);

As with it, when delay == 0, dad_work would be scheduled immediately, all
addrconf_mod_dad_work(0) callings had to be moved under ifp->lock.

Reported-by: Wei Chen <weichen@redhat.com>
Suggested-by: Hannes Frederic Sowa <hannes@stressinduktion.org>
Acked-by: Hannes Frederic Sowa <hannes@stressinduktion.org>
Signed-off-by: Xin Long <lucien.xin@gmail.com>
---
 net/ipv6/addrconf.c | 6 +++---
 1 file changed, 3 insertions(+), 3 deletions(-)

diff --git a/net/ipv6/addrconf.c b/net/ipv6/addrconf.c
index 6a4fb1e..686c923 100644
--- a/net/ipv6/addrconf.c
+++ b/net/ipv6/addrconf.c
@@ -332,9 +332,9 @@ static void addrconf_mod_rs_timer(struct inet6_dev *idev,
 static void addrconf_mod_dad_work(struct inet6_ifaddr *ifp,
 				   unsigned long delay)
 {
-	if (!delayed_work_pending(&ifp->dad_work))
-		in6_ifa_hold(ifp);
-	mod_delayed_work(addrconf_wq, &ifp->dad_work, delay);
+	in6_ifa_hold(ifp);
+	if (mod_delayed_work(addrconf_wq, &ifp->dad_work, delay))
+		in6_ifa_put(ifp);
 }
 
 static int snmp6_alloc_dev(struct inet6_dev *idev)
-- 
2.1.0
