From: Dan Carpenter <dan.carpenter@oracle.com>
Subject: [PATCH net] rocker: move dereference before free
Date: Wed, 28 Jun 2017 14:44:21 +0300
Message-ID: <20170628114421.qyv6lmugpbjqntpt@mwanda>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: netdev@vger.kernel.org, kernel-janitors@vger.kernel.org
To: Jiri Pirko <jiri@resnulli.us>, Arnd Bergmann <arnd@arndb.de>
Return-path: <netdev-owner@vger.kernel.org>
Received: from aserp1040.oracle.com ([141.146.126.69]:38309 "EHLO
        aserp1040.oracle.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1751513AbdF1Loj (ORCPT
        <rfc822;netdev@vger.kernel.org>); Wed, 28 Jun 2017 07:44:39 -0400
Content-Disposition: inline
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

My static checker complains that ofdpa_neigh_del() can sometimes free
"found".   It just makes sense to use it first before deleting it.

Fixes: ecf244f753e0 ("rocker: fix maybe-uninitialized warning")
Signed-off-by: Dan Carpenter <dan.carpenter@oracle.com>
---
Most ref counting function use atomic_dec() but ofdpa_neigh_del() just
uses normal decrement.  Are you sure this isn't racy?

This applies to net.  In net-next the code has shifted around and it
doesn't apply anymore.  Should I send a different patch for net-next?

diff --git a/drivers/net/ethernet/rocker/rocker_ofdpa.c b/drivers/net/ethernet/rocker/rocker_ofdpa.c
index 2ae852454780..a9ce82d3e9cf 100644
--- a/drivers/net/ethernet/rocker/rocker_ofdpa.c
+++ b/drivers/net/ethernet/rocker/rocker_ofdpa.c
@@ -1505,8 +1505,8 @@ static int ofdpa_port_ipv4_nh(struct ofdpa_port *ofdpa_port,
 		*index = entry->index;
 		resolved = false;
 	} else if (removing) {
-		ofdpa_neigh_del(trans, found);
 		*index = found->index;
+		ofdpa_neigh_del(trans, found);
 	} else if (updating) {
 		ofdpa_neigh_update(found, trans, NULL, false);
 		resolved = !is_zero_ether_addr(found->eth_dst);
