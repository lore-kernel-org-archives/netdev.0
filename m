From: Jiri Pirko <jiri@resnulli.us>
Subject: [patch net-next 13/21] ipv6: Regenerate host route according to node pointer upon loopback up
Date: Thu,  3 Aug 2017 13:28:23 +0200
Message-ID: <20170803112831.1831-14-jiri@resnulli.us>
References: <20170803112831.1831-1-jiri@resnulli.us>
Cc: davem@davemloft.net, idosch@mellanox.com, mlxsw@mellanox.com,
        dsahern@gmail.com, roopa@cumulusnetworks.com,
        nikolay@cumulusnetworks.com, kafai@fb.com,
        hannes@stressinduktion.org, yoshfuji@linux-ipv6.org,
        edumazet@google.com, yanhaishuang@cmss.chinamobile.com
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-wm0-f65.google.com ([74.125.82.65]:33333 "EHLO
        mail-wm0-f65.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1752084AbdHCL26 (ORCPT
        <rfc822;netdev@vger.kernel.org>); Thu, 3 Aug 2017 07:28:58 -0400
Received: by mail-wm0-f65.google.com with SMTP id q189so1836196wmd.0
        for <netdev@vger.kernel.org>; Thu, 03 Aug 2017 04:28:58 -0700 (PDT)
In-Reply-To: <20170803112831.1831-1-jiri@resnulli.us>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Ido Schimmel <idosch@mellanox.com>

When the loopback device is brought back up we need to check if the host
route attached to the address is still in the FIB and regenerate one in
case it's not.

Host routes using the loopback device are always inserted into and
removed from the FIB under RTNL (under which this function is called),
so we can test their node pointer instead of the reference count in
order to check if the route is in the FIB or not.

Tested using the following script from Nicolas mentioned in
commit a220445f9f43 ("ipv6: correctly add local routes when lo goes up"):

$ ip link add dummy1 type dummy
$ ip link set dummy1 up
$ ip link set lo down ; ip link set lo up

The host route is correctly regenerated.

Signed-off-by: Ido Schimmel <idosch@mellanox.com>
Signed-off-by: Jiri Pirko <jiri@mellanox.com>
---
 net/ipv6/addrconf.c | 2 +-
 1 file changed, 1 insertion(+), 1 deletion(-)

diff --git a/net/ipv6/addrconf.c b/net/ipv6/addrconf.c
index 3c46e95..e8e4f86 100644
--- a/net/ipv6/addrconf.c
+++ b/net/ipv6/addrconf.c
@@ -3066,7 +3066,7 @@ static void init_loopback(struct net_device *dev)
 				 * lo device down, release this obsolete dst and
 				 * reallocate a new router for ifa.
 				 */
-				if (!atomic_read(&sp_ifa->rt->rt6i_ref)) {
+				if (!sp_ifa->rt->rt6i_node) {
 					ip6_rt_put(sp_ifa->rt);
 					sp_ifa->rt = NULL;
 				} else {
-- 
2.9.3
