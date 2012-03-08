From: Li Wei <lw@cn.fujitsu.com>
Subject: [PATCH] IPv6: Fix Smatch warning.
Date: Thu, 08 Mar 2012 08:58:07 +0800
Message-ID: <4F58041F.5060209@cn.fujitsu.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Content-Transfer-Encoding: 7bit
Cc: Dan Carpenter <dan.carpenter@oracle.com>,
	netdev <netdev@vger.kernel.org>
To: "David S. Miller" <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from cn.fujitsu.com ([222.73.24.84]:42163 "EHLO song.cn.fujitsu.com"
	rhost-flags-OK-FAIL-OK-OK) by vger.kernel.org with ESMTP
	id S1751485Ab2CHBNY (ORCPT <rfc822;netdev@vger.kernel.org>);
	Wed, 7 Mar 2012 20:13:24 -0500
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>


With commit d6ddef9e641d(IPv6: Fix not join all-router mcast group
when forwarding set.) I check 'dev' after it's dereference that
leads to a Smatch complaint:

net/ipv6/addrconf.c:438 ipv6_add_dev()
	 warn: variable dereferenced before check 'dev' (see line 432)

net/ipv6/addrconf.c
   431		/* protected by rtnl_lock */
   432		rcu_assign_pointer(dev->ip6_ptr, ndev);
                                   ^^^^^^^^^^^^
Old dereference.

   433
   434		/* Join all-node multicast group */
   435		ipv6_dev_mc_inc(dev, &in6addr_linklocal_allnodes);
   436
   437		/* Join all-router multicast group if forwarding is set
*/
   438		if (ndev->cnf.forwarding && dev && (dev->flags &
IFF_MULTICAST))
                                            ^^^

Remove the check to avoid the complaint as 'dev' can't be NULL.

Reported-by: Dan Carpenter <dan.carpenter@oracle.com>
Signed-off-by: Li Wei <lw@cn.fujitsu.com>
---
 net/ipv6/addrconf.c |    2 +-
 1 files changed, 1 insertions(+), 1 deletions(-)

diff --git a/net/ipv6/addrconf.c b/net/ipv6/addrconf.c
index 6b8ebc5..6a3bb60 100644
--- a/net/ipv6/addrconf.c
+++ b/net/ipv6/addrconf.c
@@ -435,7 +435,7 @@ static struct inet6_dev * ipv6_add_dev(struct net_device *dev)
 	ipv6_dev_mc_inc(dev, &in6addr_linklocal_allnodes);
 
 	/* Join all-router multicast group if forwarding is set */
-	if (ndev->cnf.forwarding && dev && (dev->flags & IFF_MULTICAST))
+	if (ndev->cnf.forwarding && (dev->flags & IFF_MULTICAST))
 		ipv6_dev_mc_inc(dev, &in6addr_linklocal_allrouters);
 
 	return ndev;
-- 
1.7.1
