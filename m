From: Michael Bussmann <bus@mb-net.net>
Subject: IPV6_LEAVE_GROUP with ipv6mr_interface=0
Date: Mon, 9 Sep 2002 17:36:58 +0200
Sender: netdev-bounce@oss.sgi.com
Message-ID: <20020909153658.GA14597@ruf098.fkie.fgan.de>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: netdev@oss.sgi.com
Return-path: <netdev-bounce@oss.sgi.com>
To: davem@redhat.com, pekkas@netcore.fi
Content-Disposition: inline
Errors-to: netdev-bounce@oss.sgi.com
List-Id: netdev.vger.kernel.org

Hi there,

I've had some problems with leaving IPv6 multicast groups when specifing
ipv6mr_interface=0:

I joined a group with

| imr.ipv6mr_multiaddr=FF1E::123
| imr.ipv6mr_interface=0
| setsockopt(.., IPV6_JOIN_GROUP, &imr, ...)

This works perfectly so far.  Leaving this group, however, with

| imr.ipv6mr_multiaddr=FF1E::123
| imr.ipv6mr_interface=0
| setsockopt(.., IPV6_LEAVE_GROUP, &imr, ...)

always resulted in a ENOENT.

Is ipv6mr_interface=0 not appropiate for leaving a multicast group (it
works under Solaris 2.8)?

The following patch (for 2.4.18, but it should work with 2.5.33) makes
the interface=0 stuff work.  Maybe it breaks everything else...

Best regards,
MB

-- 
Michael Bussmann <bus@mb-net.net>
Who will take the coal from the mine? Who will take the salt from the earth?
Who'll take a leaf and grow it to a tree?  Don't Look Now, it ain't you or me.
	-- CCR, 'Dont Look Now', 1969

Patch for linux/net/ipv6/mcast.c:

--- mcast.c.orig	Mon Sep  9 16:40:07 2002
+++ mcast.c	Mon Sep  9 16:40:10 2002
@@ -140,15 +140,26 @@
 	struct ipv6_mc_socklist *mc_lst, **lnk;
 
 	write_lock_bh(&ipv6_sk_mc_lock);
+
 	for (lnk = &np->ipv6_mc_list; (mc_lst = *lnk) !=NULL ; lnk = &mc_lst->next) {
-		if (mc_lst->ifindex == ifindex &&
+		if ((ifindex==0) || (mc_lst->ifindex == ifindex) &&
 		    ipv6_addr_cmp(&mc_lst->addr, addr) == 0) {
 			struct net_device *dev;
 
 			*lnk = mc_lst->next;
 			write_unlock_bh(&ipv6_sk_mc_lock);
+			if (ifindex == 0) {
+				struct rt6_info *rt;
+				rt = rt6_lookup(addr, NULL, 0, 0);
+				if (rt) {
+					dev = rt->rt6i_dev;
+					dev_hold(dev);
+					dst_release(&rt->u.dst);
+				}
+			} else
+				dev = dev_get_by_index(ifindex);
 
-			if ((dev = dev_get_by_index(ifindex)) != NULL) {
+			if (dev!= NULL) {
 				ipv6_dev_mc_dec(dev, &mc_lst->addr);
 				dev_put(dev);
 			}
