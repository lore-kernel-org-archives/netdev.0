From: Jiri Bohac <jbohac@suse.cz>
Subject: Re: [PATCH] ipv6: properly prevent temp_prefered_lft sysctl race
Date: Thu, 20 Oct 2016 12:29:26 +0200
Message-ID: <20161020102926.ysgqdjghmvc573s4@dwarf.suse.cz>
References: <20161018150154.4tpivtvxygp7kjpd@dwarf.suse.cz>
 <20161018.142525.1262217492229127435.davem@davemloft.net>
 <20161019131636.zhusbqh63qlbq5vy@dwarf.suse.cz>
 <20161019.145816.259194714319437266.davem@davemloft.net>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: julia.lawall@lip6.fr, kuznet@ms2.inr.ac.ru, jmorris@namei.org,
        yoshfuji@linux-ipv6.org, kaber@trash.net, netdev@vger.kernel.org,
        kbuild-all@01.org
To: David Miller <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mx2.suse.de ([195.135.220.15]:54276 "EHLO mx2.suse.de"
        rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
        id S1754041AbcJTK3c (ORCPT <rfc822;netdev@vger.kernel.org>);
        Thu, 20 Oct 2016 06:29:32 -0400
Content-Disposition: inline
In-Reply-To: <20161019.145816.259194714319437266.davem@davemloft.net>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

The check for an underflow of tmp_prefered_lft is always false
because tmp_prefered_lft is unsigned. The intention of the check
was to guard against racing with an update of the
temp_prefered_lft sysctl, potentially resulting in an underflow.

As suggested by David Miller, the best way to prevent the race is
by reading the sysctl variable using READ_ONCE.

Signed-off-by: Jiri Bohac <jbohac@suse.cz>
Reported-by: Julia Lawall <julia.lawall@lip6.fr>
Fixes: 76506a986dc3 ("IPv6: fix DESYNC_FACTOR")

diff --git a/net/ipv6/addrconf.c b/net/ipv6/addrconf.c
index cc7c26d..060dd99 100644
--- a/net/ipv6/addrconf.c
+++ b/net/ipv6/addrconf.c
@@ -1185,6 +1185,7 @@ static int ipv6_create_tempaddr(struct inet6_ifaddr *ifp, struct inet6_ifaddr *i
 	u32 addr_flags;
 	unsigned long now = jiffies;
 	long max_desync_factor;
+	s32 cnf_temp_preferred_lft;
 
 	write_lock_bh(&idev->lock);
 	if (ift) {
@@ -1228,9 +1229,10 @@ static int ipv6_create_tempaddr(struct inet6_ifaddr *ifp, struct inet6_ifaddr *i
 	/* recalculate max_desync_factor each time and update
 	 * idev->desync_factor if it's larger
 	 */
+	cnf_temp_preferred_lft = READ_ONCE(idev->cnf.temp_prefered_lft);
 	max_desync_factor = min_t(__u32,
 				  idev->cnf.max_desync_factor,
-				  idev->cnf.temp_prefered_lft - regen_advance);
+				  cnf_temp_preferred_lft - regen_advance);
 
 	if (unlikely(idev->desync_factor > max_desync_factor)) {
 		if (max_desync_factor > 0) {
@@ -1245,11 +1247,8 @@ static int ipv6_create_tempaddr(struct inet6_ifaddr *ifp, struct inet6_ifaddr *i
 	tmp_valid_lft = min_t(__u32,
 			      ifp->valid_lft,
 			      idev->cnf.temp_valid_lft + age);
-	tmp_prefered_lft = idev->cnf.temp_prefered_lft + age -
+	tmp_prefered_lft = cnf_temp_preferred_lft + age -
 			    idev->desync_factor;
-	/* guard against underflow in case of concurrent updates to cnf */
-	if (unlikely(tmp_prefered_lft < 0))
-		tmp_prefered_lft = 0;
 	tmp_prefered_lft = min_t(__u32, ifp->prefered_lft, tmp_prefered_lft);
 	tmp_plen = ifp->prefix_len;
 	tmp_tstamp = ifp->tstamp;
-- 
Jiri Bohac <jbohac@suse.cz>
SUSE Labs, SUSE CZ
