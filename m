From: Ben Hutchings <ben@decadent.org.uk>
Subject: [PATCH 2/2] ipv6: Use interface max_desync_factor instead of
 static default
Date: Sat, 26 Jun 2010 22:42:55 +0100
Message-ID: <1277588575.26161.311.camel@localhost>
References: <1277588267.26161.300.camel@localhost>
Mime-Version: 1.0
Content-Type: text/plain; charset="UTF-8"
Content-Transfer-Encoding: 8BIT
Cc: Hideaki YOSHIFUJI <yoshfuji@linux-ipv6.org>,
	Patrick McHardy <kaber@trash.net>, 514646@bugs.debian.org,
	Piotr Lewandowski <piotr.lewandowski@gmail.com>,
	netdev <netdev@vger.kernel.org>
To: David Miller <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from shadbolt.e.decadent.org.uk ([88.96.1.126]:57671 "EHLO
	shadbolt.e.decadent.org.uk" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with ESMTP id S1754146Ab0FZVnD convert rfc822-to-8bit
	(ORCPT <rfc822;netdev@vger.kernel.org>);
	Sat, 26 Jun 2010 17:43:03 -0400
In-Reply-To: <1277588267.26161.300.camel@localhost>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

max_desync_factor can be configured per-interface, but nothing is
using the value.

Reported-by: Piotr Lewandowski <piotr.lewandowski@gmail.com>
Signed-off-by: Ben Hutchings <ben@decadent.org.uk>
---
Also compile-tested only.

Note that there is nothing to stop temp_prefered_lft being set smaller
than max_desync_factor, which can result in underflow in calculation of
tmp_prefered_lft in ipv6_create_tempaddr().  However, the same applies
to the current static variable desync_factor.

Ben.

 net/ipv6/addrconf.c |    8 ++++----
 1 files changed, 4 insertions(+), 4 deletions(-)

diff --git a/net/ipv6/addrconf.c b/net/ipv6/addrconf.c
index 1459eed..ec8c92f 100644
--- a/net/ipv6/addrconf.c
+++ b/net/ipv6/addrconf.c
@@ -121,8 +121,6 @@ static inline void addrconf_sysctl_unregister(struct inet6_dev *idev)
 static int __ipv6_regen_rndid(struct inet6_dev *idev);
 static int __ipv6_try_regen_rndid(struct inet6_dev *idev, struct in6_addr *tmpaddr);
 static void ipv6_regen_rndid(unsigned long data);
-
-static int desync_factor = MAX_DESYNC_FACTOR * HZ;
 #endif
 
 static int ipv6_generate_eui64(u8 *eui, struct net_device *dev);
@@ -890,7 +888,8 @@ retry:
 			      idev->cnf.temp_valid_lft);
 	tmp_prefered_lft = min_t(__u32,
 				 ifp->prefered_lft,
-				 idev->cnf.temp_prefered_lft - desync_factor / HZ);
+				 idev->cnf.temp_prefered_lft -
+				 idev->cnf.max_desync_factor);
 	tmp_plen = ifp->prefix_len;
 	max_addresses = idev->cnf.max_addresses;
 	tmp_cstamp = ifp->cstamp;
@@ -1650,7 +1649,8 @@ static void ipv6_regen_rndid(unsigned long data)
 
 	expires = jiffies +
 		idev->cnf.temp_prefered_lft * HZ -
-		idev->cnf.regen_max_retry * idev->cnf.dad_transmits * idev->nd_parms->retrans_time - desync_factor;
+		idev->cnf.regen_max_retry * idev->cnf.dad_transmits * idev->nd_parms->retrans_time -
+		idev->cnf.max_desync_factor * HZ;
 	if (time_before(expires, jiffies)) {
 		printk(KERN_WARNING
 			"ipv6_regen_rndid(): too short regeneration interval; timer disabled for %s.\n",
-- 
1.7.1


