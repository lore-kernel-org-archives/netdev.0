From: Marcus Huewe <suse-tux@gmx.de>
Subject: [PATCH net] ipv6: addrconf: fix generation of new temporary addresses
Date: Mon, 6 Feb 2017 18:34:56 +0100
Message-ID: <20170206173455.ghiltporvklvumsp@linux.fritz.box>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: netdev@vger.kernel.org
To: davem@davemloft.net, kuznet@ms2.inr.ac.ru, jmorris@namei.org,
        yoshfuji@linux-ipv6.org, kaber@trash.net
Return-path: <netdev-owner@vger.kernel.org>
Received: from mout.gmx.net ([212.227.15.19]:52054 "EHLO mout.gmx.net"
        rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
        id S1751154AbdBFRfO (ORCPT <rfc822;netdev@vger.kernel.org>);
        Mon, 6 Feb 2017 12:35:14 -0500
Content-Disposition: inline
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Under some circumstances it is possible that no new temporary addresses
will be generated.

For instance, addrconf_prefix_rcv_add_addr() indirectly calls
ipv6_create_tempaddr(), which creates a tentative temporary address and
starts dad. Next, addrconf_prefix_rcv_add_addr() indirectly calls
addrconf_verify_rtnl(). Now, assume that the previously created temporary
address has the least preferred lifetime among all existing addresses and
is still tentative (that is, dad is still running). Hence, the next run of
addrconf_verify_rtnl() is performed when the preferred lifetime of the
temporary address ends. If dad succeeds before the next run, the temporary
address becomes deprecated during the next run, but no new temporary
address is generated.

In order to fix this, schedule the next addrconf_verify_rtnl() run slightly
before the temporary address becomes deprecated, if dad succeeded.

Signed-off-by: Marcus Huewe <suse-tux@gmx.de>
---
 net/ipv6/addrconf.c | 6 ++++++
 1 file changed, 6 insertions(+)

diff --git a/net/ipv6/addrconf.c b/net/ipv6/addrconf.c
index f60e88e56255..27a5cc3d375d 100644
--- a/net/ipv6/addrconf.c
+++ b/net/ipv6/addrconf.c
@@ -4009,6 +4009,12 @@ static void addrconf_dad_completed(struct inet6_ifaddr *ifp, bool bump_id)
 
 	if (bump_id)
 		rt_genid_bump_ipv6(dev_net(dev));
+
+	/* Make sure that a new temporary address will be created
+	 * before this temporary address becomes deprecated.
+	 */
+	if (ifp->flags & IFA_F_TEMPORARY)
+		addrconf_verify_rtnl();
 }
 
 static void addrconf_dad_run(struct inet6_dev *idev)
-- 
2.11.0
