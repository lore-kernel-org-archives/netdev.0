From: Hiroaki SHIMODA <shimoda.hiroaki@gmail.com>
Subject: [PATCH net] netlink: Properly unbind in error conditions.
Date: Thu, 13 Nov 2014 04:24:10 +0900
Message-ID: <20141113042410.013c5d044aa442a05832d6d9@gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, rgb@redhat.com
To: davem@davemloft.net
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-pa0-f47.google.com ([209.85.220.47]:33854 "EHLO
	mail-pa0-f47.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1753198AbaKLTYP (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 12 Nov 2014 14:24:15 -0500
Received: by mail-pa0-f47.google.com with SMTP id kx10so13580906pab.34
        for <netdev@vger.kernel.org>; Wed, 12 Nov 2014 11:24:14 -0800 (PST)
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Even if netlink_kernel_cfg::unbind is implemented the unbind() method is
not called, because cfg->unbind is omitted in __netlink_kernel_create().
And fix wrong argument of test_bit() and off by one problem.

At this point, no unbind() method is implemented, so there is no real
issue.

Fixes: 4f520900522f ("netlink: have netlink per-protocol bind function return an error code.")
Signed-off-by: Hiroaki SHIMODA <shimoda.hiroaki@gmail.com>
Cc: Richard Guy Briggs <rgb@redhat.com>
---
 net/netlink/af_netlink.c | 5 +++--
 1 file changed, 3 insertions(+), 2 deletions(-)

diff --git a/net/netlink/af_netlink.c b/net/netlink/af_netlink.c
index f1de72de273e..0007b8180397 100644
--- a/net/netlink/af_netlink.c
+++ b/net/netlink/af_netlink.c
@@ -1440,7 +1440,7 @@ static void netlink_unbind(int group, long unsigned int groups,
 		return;
 
 	for (undo = 0; undo < group; undo++)
-		if (test_bit(group, &groups))
+		if (test_bit(undo, &groups))
 			nlk->netlink_unbind(undo);
 }
 
@@ -1492,7 +1492,7 @@ static int netlink_bind(struct socket *sock, struct sockaddr *addr,
 			netlink_insert(sk, net, nladdr->nl_pid) :
 			netlink_autobind(sock);
 		if (err) {
-			netlink_unbind(nlk->ngroups - 1, groups, nlk);
+			netlink_unbind(nlk->ngroups, groups, nlk);
 			return err;
 		}
 	}
@@ -2509,6 +2509,7 @@ __netlink_kernel_create(struct net *net, int unit, struct module *module,
 		nl_table[unit].module = module;
 		if (cfg) {
 			nl_table[unit].bind = cfg->bind;
+			nl_table[unit].unbind = cfg->unbind;
 			nl_table[unit].flags = cfg->flags;
 			if (cfg->compare)
 				nl_table[unit].compare = cfg->compare;
-- 
2.0.4
