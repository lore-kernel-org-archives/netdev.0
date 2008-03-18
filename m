From: Benoit Boissinot <benoit.boissinot@ens-lyon.org>
Subject: [PATCH] [IPv6] Don't generate a temporary address for deprecated
	addresses
Date: Tue, 18 Mar 2008 13:40:08 +0100
Message-ID: <20080318124008.GA6977@ens-lyon.fr>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: yoshfuji@linux-ipv6.org
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from pilet.ens-lyon.fr ([140.77.167.16]:38349 "EHLO
	pilet.ens-lyon.fr" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752293AbYCRNAj (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 18 Mar 2008 09:00:39 -0400
Content-Disposition: inline
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

The RFC states that if the preferred lifetime is less than
REGEN_ADVANCE, no temporary address should be created.

Signed-off-by: Benoit Boissinot <benoit.boissinot@ens-lyon.org>

diff --git a/net/ipv6/addrconf.c b/net/ipv6/addrconf.c 
index 101e0e7..5d0e404 100644 
--- a/net/ipv6/addrconf.c 
+++ b/net/ipv6/addrconf.c 
@@ -776,6 +776,7 @@ static int ipv6_create_tempaddr(struct inet6_ifaddr *ifp, struct inet6_ifaddr *i 
        struct inet6_dev *idev = ifp->idev; 
        struct in6_addr addr, *tmpaddr; 
        unsigned long tmp_prefered_lft, tmp_valid_lft, tmp_cstamp, tmp_tstamp; 
+       unsigned long regen_advance; 
        int tmp_plen; 
        int ret = 0; 
        int max_addresses; 
@@ -838,6 +839,22 @@ retry: 
  
        write_unlock(&idev->lock); 
  
+       regen_advance = ifp->idev->cnf.regen_max_retry * 
+                       ifp->idev->cnf.dad_transmits * 
+                       ifp->idev->nd_parms->retrans_time / HZ; 
+ 
+       /* A temporary address is created only if this calculated Preferred 
+        * Lifetime is greater than REGEN_ADVANCE time units.  In particular, 
+        * an implementation must not create a temporary address with a zero 
+        * Preferred Lifetime. 
+        */ 
+       if (tmp_prefered_lft <= regen_advance) { 
+               in6_ifa_put(ifp); 
+               in6_dev_put(idev); 
+               ret = -1; 
+               goto out; 
+       } 
+ 
        addr_flags = IFA_F_TEMPORARY;
        /* set in addrconf_prefix_rcv() */
        if (ifp->flags & IFA_F_OPTIMISTIC)

-- 
:wq
