From: Joel Sing <jsing@google.com>
Subject: [PATCH] ipv4/route.c: respect prefsrc for local routes
Date: Tue,  4 Jan 2011 17:24:20 +1100
Message-ID: <1294122260-13245-1-git-send-email-jsing@google.com>
Cc: Joel Sing <jsing@google.com>
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from smtp-out.google.com ([216.239.44.51]:50973 "EHLO
	smtp-out.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1750886Ab1ADGYs (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 4 Jan 2011 01:24:48 -0500
Received: from hpaq1.eem.corp.google.com (hpaq1.eem.corp.google.com [172.25.149.1])
	by smtp-out.google.com with ESMTP id p046Olrc015007
	for <netdev@vger.kernel.org>; Mon, 3 Jan 2011 22:24:47 -0800
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

The preferred source address is currently ignored for local routes,
which results in all local connections having a src address that is the
same as the local dst address. Fix this by respecting the preferred source
address when it is provided for local routes.

This bug can be demonstrated as follows:

 # ifconfig dummy0 192.168.0.1
 # ip route show table local | grep local.*dummy0
 local 192.168.0.1 dev dummy0  proto kernel  scope host  src 192.168.0.1
 # ip route change table local local 192.168.0.1 dev dummy0 \
     proto kernel scope host src 127.0.0.1
 # ip route show table local | grep local.*dummy0
 local 192.168.0.1 dev dummy0  proto kernel  scope host  src 127.0.0.1

We now establish a local connection and verify the source IP
address selection:

 # nc -l 192.168.0.1 3128 &
 # nc 192.168.0.1 3128 &
 # netstat -ant | grep 192.168.0.1:3128.*EST
 tcp        0      0 192.168.0.1:3128        192.168.0.1:33228 ESTABLISHED
 tcp        0      0 192.168.0.1:33228       192.168.0.1:3128  ESTABLISHED

Signed-off-by: Joel Sing <jsing@google.com>
---
 net/ipv4/route.c |    8 ++++++--
 1 files changed, 6 insertions(+), 2 deletions(-)

diff --git a/net/ipv4/route.c b/net/ipv4/route.c
index df948b0..93bfd95 100644
--- a/net/ipv4/route.c
+++ b/net/ipv4/route.c
@@ -2649,8 +2649,12 @@ static int ip_route_output_slow(struct net *net, struct rtable **rp,
 	}
 
 	if (res.type == RTN_LOCAL) {
-		if (!fl.fl4_src)
-			fl.fl4_src = fl.fl4_dst;
+		if (!fl.fl4_src) {
+			if (res.fi->fib_prefsrc)
+				fl.fl4_src = res.fi->fib_prefsrc;
+			else
+				fl.fl4_src = fl.fl4_dst;
+		}
 		dev_out = net->loopback_dev;
 		fl.oif = dev_out->ifindex;
 		res.fi = NULL;
-- 
1.7.3.1

