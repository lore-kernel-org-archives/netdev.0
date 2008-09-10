From: David Miller <davem@davemloft.net>
Subject: Re: ipv6 neighbour code keeps interfaces held
Date: Wed, 10 Sep 2008 16:40:09 -0700 (PDT)
Message-ID: <20080910.164009.92497081.davem@davemloft.net>
References: <1221081539.3804.33.camel@johannes.berg>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org
To: johannes@sipsolutions.net
Return-path: <netdev-owner@vger.kernel.org>
Received: from 74-93-104-97-Washington.hfc.comcastbusiness.net ([74.93.104.97]:44243
	"EHLO sunset.davemloft.net" rhost-flags-OK-FAIL-OK-OK)
	by vger.kernel.org with ESMTP id S1752168AbYIJXkQ (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 10 Sep 2008 19:40:16 -0400
In-Reply-To: <1221081539.3804.33.camel@johannes.berg>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Johannes Berg <johannes@sipsolutions.net>
Date: Wed, 10 Sep 2008 23:18:59 +0200

> [22369.076567] Call Trace:
> [22369.076571] [efff5ef0] [c028f984] neigh_destroy+0x16c/0x1b8 (unreliable)
> [22369.076577] [efff5f00] [c0306b6c] ip6_dst_destroy+0x44/0x54
> [22369.076582] [efff5f10] [c028c304] dst_destroy+0x78/0x154
> [22369.076586] [efff5f30] [c030a270] icmp6_dst_gc+0xa4/0xd4
> [22369.076591] [efff5f50] [c030b084] fib6_run_gc+0x50/0x110

This is yet another side effect of how ipv6 handles ICMP routes
seperately from "real" ipv6 routes.

And this seperation has been responsible for a large number of
bugs over the years.

Anyways, what happens is that when a device goes down a notifier
goes out, and in IPV6's case it has a notifier registered in
net/ipv6/addrconf.c that ends up calling rt6_ifdown() on
the device.

This is supposed to purge routes from the tree so that the device
references can be dropped (eventually).

This is done in ipv6 by fib6_clean_all() but that only handles
normal routes.  The seperate ICMP6 routes are not purged properly
in this situation.

Here is a quick patch that might resolve this specific situation.
Let me know how it works for you:

diff --git a/net/ipv6/route.c b/net/ipv6/route.c
index 9af6115..776871e 100644
--- a/net/ipv6/route.c
+++ b/net/ipv6/route.c
@@ -1003,6 +1003,25 @@ int icmp6_dst_gc(void)
 	return more;
 }
 
+static void icmp6_clean_all(int (*func)(struct rt6_info *rt, void *arg),
+			    void *arg)
+{
+	struct dst_entry *dst, **pprev;
+
+	spin_lock_bh(&icmp6_dst_lock);
+	pprev = &icmp6_dst_gc_list;
+	while ((dst = *pprev) != NULL) {
+		struct rt6_info *rt = (struct rt6_info *) dst;
+		if (func(rt, arg)) {
+			*pprev = dst->next;
+			dst_free(dst);
+		} else {
+			pprev = &dst->next;
+		}
+	}
+	spin_unlock_bh(&icmp6_dst_lock);
+}
+
 static int ip6_dst_gc(struct dst_ops *ops)
 {
 	unsigned long now = jiffies;
@@ -1930,6 +1949,7 @@ void rt6_ifdown(struct net *net, struct net_device *dev)
 	};
 
 	fib6_clean_all(net, fib6_ifdown, 0, &adn);
+	icmp6_clean_all(fib6_ifdown, &adn);
 }
 
 struct rt6_mtu_change_arg
