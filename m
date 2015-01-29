From: Pablo Neira Ayuso <pablo@netfilter.org>
Subject: [PATCH net] netlink: fix wrong subscription bitmask to group mapping in
Date: Thu, 29 Jan 2015 10:51:53 +0100
Message-ID: <1422525113-5698-1-git-send-email-pablo@netfilter.org>
Cc: davem@davemloft.net, colona@arista.com, andre@tomt.net
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail.us.es ([193.147.175.20]:54835 "EHLO mail.us.es"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S932326AbbA2JtH (ORCPT <rfc822;netdev@vger.kernel.org>);
	Thu, 29 Jan 2015 04:49:07 -0500
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

The subscription bitmask passed via struct sockaddr_nl is converted to
the group number when calling the netlink_bind() and netlink_unbind()
callbacks.

The conversion is however incorrect since bitmask (1 << 0) needs to be
mapped to group number 1. Note that you cannot specify the group number 0
(usually known as _NONE) from setsockopt() using NETLINK_ADD_MEMBERSHIP
since this is rejected through -EINVAL.

This problem became noticeable since 97840cb ("netfilter: nfnetlink:
fix insufficient validation in nfnetlink_bind") when binding to bitmask
(1 << 0) in ctnetlink.

Reported-by: Andre Tomt <andre@tomt.net>
Reported-by: Ivan Delalande <colona@arista.com>
Signed-off-by: Pablo Neira Ayuso <pablo@netfilter.org>
---
v2: Rebased upon current net tree. Previous patch:

http://patchwork.ozlabs.org/patch/426205/

did not apply cleanly.

 net/netlink/af_netlink.c |    4 ++--
 1 file changed, 2 insertions(+), 2 deletions(-)

diff --git a/net/netlink/af_netlink.c b/net/netlink/af_netlink.c
index 02fdde2..75532ef 100644
--- a/net/netlink/af_netlink.c
+++ b/net/netlink/af_netlink.c
@@ -1438,7 +1438,7 @@ static void netlink_undo_bind(int group, long unsigned int groups,
 
 	for (undo = 0; undo < group; undo++)
 		if (test_bit(undo, &groups))
-			nlk->netlink_unbind(sock_net(sk), undo);
+			nlk->netlink_unbind(sock_net(sk), undo + 1);
 }
 
 static int netlink_bind(struct socket *sock, struct sockaddr *addr,
@@ -1476,7 +1476,7 @@ static int netlink_bind(struct socket *sock, struct sockaddr *addr,
 		for (group = 0; group < nlk->ngroups; group++) {
 			if (!test_bit(group, &groups))
 				continue;
-			err = nlk->netlink_bind(net, group);
+			err = nlk->netlink_bind(net, group + 1);
 			if (!err)
 				continue;
 			netlink_undo_bind(group, groups, sk);
-- 
1.7.10.4
