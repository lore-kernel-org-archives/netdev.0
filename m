From: Pablo Neira Ayuso <pablo@netfilter.org>
Subject: [PATCH net] netlink: fix wrong subscription bitmask to group mapping in binding callbacks
Date: Wed,  7 Jan 2015 13:31:55 +0100
Message-ID: <1420633915-25475-1-git-send-email-pablo@netfilter.org>
Cc: davem@davemloft.net
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail.us.es ([193.147.175.20]:41087 "EHLO mail.us.es"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1753100AbbAGM3Q (ORCPT <rfc822;netdev@vger.kernel.org>);
	Wed, 7 Jan 2015 07:29:16 -0500
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
Signed-off-by: Pablo Neira Ayuso <pablo@netfilter.org>
---
 net/netlink/af_netlink.c |    4 ++--
 1 file changed, 2 insertions(+), 2 deletions(-)

diff --git a/net/netlink/af_netlink.c b/net/netlink/af_netlink.c
index 074cf3e..cbcf73b 100644
--- a/net/netlink/af_netlink.c
+++ b/net/netlink/af_netlink.c
@@ -1420,7 +1420,7 @@ static void netlink_unbind(int group, long unsigned int groups,
 
 	for (undo = 0; undo < group; undo++)
 		if (test_bit(undo, &groups))
-			nlk->netlink_unbind(undo);
+			nlk->netlink_unbind(undo + 1);
 }
 
 static int netlink_bind(struct socket *sock, struct sockaddr *addr,
@@ -1458,7 +1458,7 @@ static int netlink_bind(struct socket *sock, struct sockaddr *addr,
 		for (group = 0; group < nlk->ngroups; group++) {
 			if (!test_bit(group, &groups))
 				continue;
-			err = nlk->netlink_bind(group);
+			err = nlk->netlink_bind(group + 1);
 			if (!err)
 				continue;
 			netlink_unbind(group, groups, nlk);
-- 
1.7.10.4
