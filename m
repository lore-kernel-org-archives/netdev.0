From: Ulrich Weber <uweber@astaro.com>
Subject: [RFC PATCH] dont create cached routes from ARP requests
Date: Wed, 22 Sep 2010 18:22:09 +0200
Message-ID: <20100922162209.GA10281@babylon>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from dhost002-15.dex002.intermedia.net ([64.78.21.81]:39183 "EHLO
	dhost002-15.dex002.intermedia.net" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with ESMTP id S1752085Ab0IVQhb (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 22 Sep 2010 12:37:31 -0400
Content-Disposition: inline
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Do we really have to cache routes based on ARP requests?
Are there any other reasons than expecting new connections?

Attached is a patch to skip caching for ARP requests
not related to local IP addresses or ARP proxy.

Background: At home I have two Internet connections, DSL and Cable.
DSL is the primary uplink while Cable is the secondary.
My Cable ISP is flooding me with ARP request from 10.0.0.0/8,
which creates routes via the primary uplink.
There are thousands of cached routes and after some time
I get "Neighbour table overflow" messages.

Cheers
 Ulrich

---
[PATCH] dont create cached routes from ARP requests

except for local destination or enabled ARP proxy. Otherwise
Neighbour table can overflow on broken network setups.

Signed-off-by: Ulrich Weber <uweber@astaro.com>
---
 include/linux/in_route.h |    1 +
 net/ipv4/route.c         |    5 ++++-
 2 files changed, 5 insertions(+), 1 deletions(-)

diff --git a/include/linux/in_route.h b/include/linux/in_route.h
index b261b8c..d97dd35 100644
--- a/include/linux/in_route.h
+++ b/include/linux/in_route.h
@@ -18,6 +18,7 @@
 #define RTCF_MASQ	0x00400000 /* unused */
 #define RTCF_SNAT	0x00800000 /* unused */
 #define RTCF_DOREDIRECT 0x01000000
+#define RTCF_NOCACHE	0x02000000
 #define RTCF_DIRECTSRC	0x04000000
 #define RTCF_DNAT	0x08000000
 #define RTCF_BROADCAST	0x10000000
diff --git a/net/ipv4/route.c b/net/ipv4/route.c
index e24d48d..7f05e45 100644
--- a/net/ipv4/route.c
+++ b/net/ipv4/route.c
@@ -1090,7 +1090,7 @@ restart:
 	candp = NULL;
 	now = jiffies;
 
-	if (!rt_caching(dev_net(rt->dst.dev))) {
+	if (rt->rt_flags & RTCF_NOCACHE || !rt_caching(dev_net(rt->dst.dev))) {
 		/*
 		 * If we're not caching, just tell the caller we
 		 * were successful and don't touch the route.  The
@@ -2001,6 +2001,9 @@ static int __mkroute_input(struct sk_buff *skb,
 			err = -EINVAL;
 			goto cleanup;
 		}
+		if (!(out_dev->dev->flags & IFF_LOOPBACK) &&
+		    !IN_DEV_PROXY_ARP(in_dev) && !IN_DEV_PROXY_ARP_PVLAN(in_dev))
+			flags |= RTCF_NOCACHE;
 	}
 
 
-- 
1.7.0.4

