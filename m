From: Jiri Pirko <jiri@resnulli.us>
Subject: [patch net-next 14/21] ipv6: Regenerate host route according to node pointer upon interface up
Date: Thu,  3 Aug 2017 13:28:24 +0200
Message-ID: <20170803112831.1831-15-jiri@resnulli.us>
References: <20170803112831.1831-1-jiri@resnulli.us>
Cc: davem@davemloft.net, idosch@mellanox.com, mlxsw@mellanox.com,
        dsahern@gmail.com, roopa@cumulusnetworks.com,
        nikolay@cumulusnetworks.com, kafai@fb.com,
        hannes@stressinduktion.org, yoshfuji@linux-ipv6.org,
        edumazet@google.com, yanhaishuang@cmss.chinamobile.com
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-wm0-f65.google.com ([74.125.82.65]:33343 "EHLO
        mail-wm0-f65.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1752154AbdHCL3A (ORCPT
        <rfc822;netdev@vger.kernel.org>); Thu, 3 Aug 2017 07:29:00 -0400
Received: by mail-wm0-f65.google.com with SMTP id q189so1836377wmd.0
        for <netdev@vger.kernel.org>; Thu, 03 Aug 2017 04:29:00 -0700 (PDT)
In-Reply-To: <20170803112831.1831-1-jiri@resnulli.us>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Ido Schimmel <idosch@mellanox.com>

When an interface is brought back up, the kernel tries to restore the
host routes tied to its permanent addresses.

However, if the host route was removed from the FIB, then we need to
reinsert it. This is done by releasing the current dst and allocating a
new, so as to not reuse a dst with obsolete values.

Since this function is called under RTNL and using the same explanation
from the previous patch, we can test if the route is in the FIB by
checking its node pointer instead of its reference count.

Tested using the following script and Andrey's reproducer mentioned
in commit 8048ced9beb2 ("net: ipv6: regenerate host route if moved to gc
list") and linked below:

$ ip link set dev lo up
$ ip link add dummy1 type dummy
$ ip -6 address add cafe::1/64 dev dummy1
$ ip link set dev lo down	# cafe::1/128 is removed
$ ip link set dev dummy1 up
$ ip link set dev lo up

The host route is correctly regenerated.

Signed-off-by: Ido Schimmel <idosch@mellanox.com>
Link: http://lkml.kernel.org/r/CAAeHK+zSe82vc5gCRgr_EoUwiALPnWVdWJBPwJZBpbxYz=kGJw@mail.gmail.com
Signed-off-by: Jiri Pirko <jiri@mellanox.com>
---
 net/ipv6/addrconf.c | 4 ++--
 1 file changed, 2 insertions(+), 2 deletions(-)

diff --git a/net/ipv6/addrconf.c b/net/ipv6/addrconf.c
index e8e4f86..30ee23e 100644
--- a/net/ipv6/addrconf.c
+++ b/net/ipv6/addrconf.c
@@ -3321,11 +3321,11 @@ static void addrconf_gre_config(struct net_device *dev)
 static int fixup_permanent_addr(struct inet6_dev *idev,
 				struct inet6_ifaddr *ifp)
 {
-	/* rt6i_ref == 0 means the host route was removed from the
+	/* !rt6i_node means the host route was removed from the
 	 * FIB, for example, if 'lo' device is taken down. In that
 	 * case regenerate the host route.
 	 */
-	if (!ifp->rt || !atomic_read(&ifp->rt->rt6i_ref)) {
+	if (!ifp->rt || !ifp->rt->rt6i_node) {
 		struct rt6_info *rt, *prev;
 
 		rt = addrconf_dst_alloc(idev, &ifp->addr, false);
-- 
2.9.3
