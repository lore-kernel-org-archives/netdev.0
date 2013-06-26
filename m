From: Hannes Frederic Sowa <hannes@stressinduktion.org>
Subject: [PATCH net-next] ipv6: rearm router solicitaion timer when setting new tokenized address
Date: Wed, 26 Jun 2013 03:41:49 +0200
Message-ID: <20130626014149.GB20081@order.stressinduktion.org>
Mime-Version: 1.0
Content-Type: text/plain; charset=utf-8
Cc: dborkman@redhat.com
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from order.stressinduktion.org ([87.106.68.36]:37931 "EHLO
	order.stressinduktion.org" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751263Ab3FZBlu (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 25 Jun 2013 21:41:50 -0400
Content-Disposition: inline
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

When a new tokenized address gets installed we send out just one
router solicition. We should send out `rtr_solicits' in case one router
advertisment got lost.

So, rearm the timer as we do in addrconf_dad_complete.

Cc: Daniel Borkmann <dborkman@redhat.com>
Signed-off-by: Hannes Frederic Sowa <hannes@stressinduktion.org>
---
 net/ipv6/addrconf.c | 5 ++++-
 1 file changed, 4 insertions(+), 1 deletion(-)

diff --git a/net/ipv6/addrconf.c b/net/ipv6/addrconf.c
index afaf3cd..4e4cc1f 100644
--- a/net/ipv6/addrconf.c
+++ b/net/ipv6/addrconf.c
@@ -4361,8 +4361,11 @@ static int inet6_set_iftoken(struct inet6_dev *idev, struct in6_addr *token)
 
 	write_lock_bh(&idev->lock);
 
-	if (update_rs)
+	if (update_rs) {
 		idev->if_flags |= IF_RS_SENT;
+		idev->rs_probes = 1;
+		addrconf_mod_rs_timer(idev, idev->cnf.rtr_solicit_interval);
+	}
 
 	/* Well, that's kinda nasty ... */
 	list_for_each_entry(ifp, &idev->addr_list, if_list) {
-- 
1.8.1.4
