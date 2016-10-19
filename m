From: Jiri Bohac <jbohac@suse.cz>
Subject: Re: [PATCH] ipv6: don't check for tmp_prefered_lft underflow
Date: Wed, 19 Oct 2016 15:25:39 +0200
Message-ID: <20161019132539.x2ou3hfgutxe6d57@dwarf.suse.cz>
References: <alpine.DEB.2.20.1610151945380.9280@hadrien>
 <20161018150154.4tpivtvxygp7kjpd@dwarf.suse.cz>
 <20161018.142525.1262217492229127435.davem@davemloft.net>
 <20161019131636.zhusbqh63qlbq5vy@dwarf.suse.cz>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: julia.lawall@lip6.fr, kuznet@ms2.inr.ac.ru, jmorris@namei.org,
        yoshfuji@linux-ipv6.org, kaber@trash.net, netdev@vger.kernel.org,
        kbuild-all@01.org
To: David Miller <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mx2.suse.de ([195.135.220.15]:38643 "EHLO mx2.suse.de"
        rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
        id S936131AbcJSONt (ORCPT <rfc822;netdev@vger.kernel.org>);
        Wed, 19 Oct 2016 10:13:49 -0400
Content-Disposition: inline
In-Reply-To: <20161019131636.zhusbqh63qlbq5vy@dwarf.suse.cz>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

The check for an underflow of tmp_prefered_lft is always false
because tmp_prefered_lft is unsigned.

The intention of the check was to guard against racing with an
update of the temp_prefered_lft sysctl, potentially resulting in
an underflow and a very large preferred lifetime. However, the
result of the check in such a situation would be not creating the
temporary address at all, which might be an even worse outcome
than the bogus lifetime.

Drop the faulty check.

Signed-off-by: Jiri Bohac <jbohac@suse.cz>
Reported-by: Julia Lawall <julia.lawall@lip6.fr>
Fixes: 76506a986dc3 ("IPv6: fix DESYNC_FACTOR")

diff --git a/net/ipv6/addrconf.c b/net/ipv6/addrconf.c
index cc7c26d..f7c7c2b 100644
--- a/net/ipv6/addrconf.c
+++ b/net/ipv6/addrconf.c
@@ -1247,9 +1247,6 @@ static int ipv6_create_tempaddr(struct inet6_ifaddr *ifp, struct inet6_ifaddr *i
 			      idev->cnf.temp_valid_lft + age);
 	tmp_prefered_lft = idev->cnf.temp_prefered_lft + age -
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
