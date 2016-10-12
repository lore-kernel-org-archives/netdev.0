From: Nicolas Dichtel <nicolas.dichtel@6wind.com>
Subject: [PATCH net] ipv6: correctly add local routes when lo goes up
Date: Wed, 12 Oct 2016 10:10:40 +0200
Message-ID: <1476259840-26261-1-git-send-email-nicolas.dichtel@6wind.com>
Cc: netdev@vger.kernel.org,
        Nicolas Dichtel <nicolas.dichtel@6wind.com>,
        Balakumaran Kannan <Balakumaran.Kannan@ap.sony.com>,
        Maruthi Thotad <Maruthi.Thotad@ap.sony.com>,
        Sabrina Dubroca <sd@queasysnail.net>,
        Hannes Frederic Sowa <hannes@stressinduktion.org>,
        Weilong Chen <chenweilong@huawei.com>,
        Gao feng <gaofeng@cn.fujitsu.com>
To: davem@davemloft.net
Return-path: <netdev-owner@vger.kernel.org>
Received: from host.76.145.23.62.rev.coltfrance.com ([62.23.145.76]:40428 "EHLO
        proxy.6wind.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1752865AbcJLITP (ORCPT
        <rfc822;netdev@vger.kernel.org>); Wed, 12 Oct 2016 04:19:15 -0400
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

The goal of the patch is to fix this scenario:
 ip link add dummy1 type dummy
 ip link set dummy1 up
 ip link set lo down ; ip link set lo up

After that sequence, the local route to the link layer address of dummy1 is
not there anymore.

When the loopback is set down, all local routes are deleted by
addrconf_ifdown()/rt6_ifdown(). At this time, the rt6_info entry still
exists, because the corresponding idev has a reference on it. After the rcu
grace period, dst_rcu_free() is called, and thus ___dst_free(), which will
set obsolete to DST_OBSOLETE_DEAD.

In this case, init_loopback() is called before dst_rcu_free(), thus
obsolete is still sets to something <= 0. So, the function doesn't add the
route again. To avoid that race, let's check the rt6 refcnt instead.

Fixes: 25fb6ca4ed9c ("net IPv6 : Fix broken IPv6 routing table after loopback down-up")
Fixes: a881ae1f625c ("ipv6: don't call addrconf_dst_alloc again when enable lo")
Fixes: 33d99113b110 ("ipv6: reallocate addrconf router for ipv6 address when lo device up")
Reported-by: Francesco Santoro <francesco.santoro@6wind.com>
Reported-by: Samuel Gauthier <samuel.gauthier@6wind.com>
CC: Balakumaran Kannan <Balakumaran.Kannan@ap.sony.com>
CC: Maruthi Thotad <Maruthi.Thotad@ap.sony.com>
CC: Sabrina Dubroca <sd@queasysnail.net>
CC: Hannes Frederic Sowa <hannes@stressinduktion.org>
CC: Weilong Chen <chenweilong@huawei.com>
CC: Gao feng <gaofeng@cn.fujitsu.com>
Signed-off-by: Nicolas Dichtel <nicolas.dichtel@6wind.com>
---
 net/ipv6/addrconf.c | 2 +-
 1 file changed, 1 insertion(+), 1 deletion(-)

diff --git a/net/ipv6/addrconf.c b/net/ipv6/addrconf.c
index d8983e15f859..9faafe58516a 100644
--- a/net/ipv6/addrconf.c
+++ b/net/ipv6/addrconf.c
@@ -3018,7 +3018,7 @@ static void init_loopback(struct net_device *dev)
 				 * lo device down, release this obsolete dst and
 				 * reallocate a new router for ifa.
 				 */
-				if (sp_ifa->rt->dst.obsolete > 0) {
+				if (!atomic_read(&sp_ifa->rt->rt6i_ref)) {
 					ip6_rt_put(sp_ifa->rt);
 					sp_ifa->rt = NULL;
 				} else {
-- 
2.8.1
