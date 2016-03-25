From: Bjorn Helgaas <helgaas@kernel.org>
Subject: netpoll rtnl_dereference() usage
Date: Fri, 25 Mar 2016 12:30:32 -0500
Message-ID: <20160325173032.GC29822@localhost>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: "David S. Miller" <davem@davemloft.net>,
	Nikolay Aleksandrov <nikolay@cumulusnetworks.com>,
	netdev@vger.kernel.org, Alexander Duyck <aduyck@mirantis.com>,
	linux-kernel@vger.kernel.org
To: Neil Horman <nhorman@redhat.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail.kernel.org ([198.145.29.136]:55801 "EHLO mail.kernel.org"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1753501AbcCYRaj (ORCPT <rfc822;netdev@vger.kernel.org>);
	Fri, 25 Mar 2016 13:30:39 -0400
Content-Disposition: inline
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Hi Neil,

Since we're looking at netpoll, here's another question (or two).
0790bbb68f9d ("netpoll: cleanup sparse warnings") adds this:

@@ -1236,7 +1236,11 @@ void __netpoll_cleanup(struct netpoll *np)
        struct netpoll_info *npinfo;
        unsigned long flags;
 
-       npinfo = np->dev->npinfo;
+       /* rtnl_dereference would be preferable here but
+        * rcu_cleanup_netpoll path can put us in here safely without
+        * holding the rtnl, so plain rcu_dereference it is
+        */
+       npinfo = rtnl_dereference(np->dev->npinfo);
        if (!npinfo)
                return;

The comment seems to contradict the code: the comment says "we would
like to use rtnl_dereference(), but we have to use rcu_dereference()."
But the code in fact *does* use rtnl_dereference().

Also, "rcu_cleanup_netpoll" doesn't exist; maybe it's a typo for
rcu_cleanup_netpoll_info()?  I don't see the path that leads from
rcu_cleanup_netpoll_info() to __netpoll_cleanup(), but I don't claim
to understand the netpoll async subtleties.

Bjorn
