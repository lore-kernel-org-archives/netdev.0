From: Julian Anastasov <ja@ssi.bg>
Subject: [PATCHv3 net 2/2] ipv4: update RTNH_F_LINKDOWN flag on UP event
Date: Fri, 30 Oct 2015 10:23:34 +0200
Message-ID: <1446193414-8244-3-git-send-email-ja@ssi.bg>
References: <1446193414-8244-1-git-send-email-ja@ssi.bg>
Cc: netdev@vger.kernel.org, Andy Gospodarek <gospo@cumulusnetworks.com>
To: David Miller <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from ja.ssi.bg ([178.16.129.10]:49557 "EHLO ja.ssi.bg"
	rhost-flags-OK-FAIL-OK-FAIL) by vger.kernel.org with ESMTP
	id S1758578AbbJ3IX6 (ORCPT <rfc822;netdev@vger.kernel.org>);
	Fri, 30 Oct 2015 04:23:58 -0400
In-Reply-To: <1446193414-8244-1-git-send-email-ja@ssi.bg>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

When nexthop is part of multipath route we should clear the
LINKDOWN flag when link goes UP or when first address is added.
This is needed because we always set LINKDOWN flag when DEAD flag
was set but now on UP the nexthop is not dead anymore. Examples when
LINKDOWN bit can be forgotten when no NETDEV_CHANGE is delivered:

- link goes down (LINKDOWN is set), then link goes UP and device
shows carrier OK but LINKDOWN remains set

- last address is deleted (LINKDOWN is set), then address is
added and device shows carrier OK but LINKDOWN remains set

Steps to reproduce:
modprobe dummy
ifconfig dummy0 192.168.168.1 up

here add a multipath route where one nexthop is for dummy0:

ip route add 1.2.3.4 nexthop dummy0 nexthop SOME_OTHER_DEVICE
ifconfig dummy0 down
ifconfig dummy0 up

now ip route shows nexthop that is not dead. Now set the sysctl var:

echo 1 > /proc/sys/net/ipv4/conf/dummy0/ignore_routes_with_linkdown

now ip route will show a dead nexthop because the forgotten
RTNH_F_LINKDOWN is propagated as RTNH_F_DEAD.

Fixes: 8a3d03166f19 ("net: track link-status of ipv4 nexthops")
Signed-off-by: Julian Anastasov <ja@ssi.bg>
---
 net/ipv4/fib_semantics.c | 7 +++++++
 1 file changed, 7 insertions(+)

diff --git a/net/ipv4/fib_semantics.c b/net/ipv4/fib_semantics.c
index 2aa5b5e..e966f85 100644
--- a/net/ipv4/fib_semantics.c
+++ b/net/ipv4/fib_semantics.c
@@ -1445,6 +1445,13 @@ int fib_sync_up(struct net_device *dev, unsigned int nh_flags)
 	if (!(dev->flags & IFF_UP))
 		return 0;
 
+	if (nh_flags & RTNH_F_DEAD) {
+		unsigned int flags = dev_get_flags(dev);
+
+		if (flags & (IFF_RUNNING | IFF_LOWER_UP))
+			nh_flags |= RTNH_F_LINKDOWN;
+	}
+
 	prev_fi = NULL;
 	hash = fib_devindex_hashfn(dev->ifindex);
 	head = &fib_info_devhash[hash];
-- 
1.9.3
