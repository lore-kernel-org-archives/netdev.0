From: Baozeng Ding <sploving1@gmail.com>
Subject: [PATCH] netlink: fix null pointer dereference on nlk->groups
Date: Fri,  8 Jan 2016 13:46:10 +0800
Message-ID: <1452231970-27357-1-git-send-email-sploving1@gmail.com>
Cc: netdev@vger.kernel.org, Baozeng Ding <sploving1@gmail.com>
To: davem@davemloft.net, herbert@gondor.apana.org.au,
	daniel@iogearbox.net, tgraf@suug.ch, pablo@netfilter.org,
	chamaken@gmail.com, nicolas.dichtel@6wind.com, fw@strlen.de
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-pf0-f180.google.com ([209.85.192.180]:34337 "EHLO
	mail-pf0-f180.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1750766AbcAHFqR (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 8 Jan 2016 00:46:17 -0500
Received: by mail-pf0-f180.google.com with SMTP id q63so4811994pfb.1
        for <netdev@vger.kernel.org>; Thu, 07 Jan 2016 21:46:16 -0800 (PST)
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

If groups is not 0 and nlk->groups is NULL, it will not return
immediately and cause a null pointer dereference later.

Signed-off-by: Baozeng Ding <sploving1@gmail.com>
---
 net/netlink/af_netlink.c | 10 +++++++---
 1 file changed, 7 insertions(+), 3 deletions(-)

diff --git a/net/netlink/af_netlink.c b/net/netlink/af_netlink.c
index 59651af..38efde0 100644
--- a/net/netlink/af_netlink.c
+++ b/net/netlink/af_netlink.c
@@ -1524,6 +1524,7 @@ static int netlink_bind(struct socket *sock, struct sockaddr *addr,
 	int err;
 	long unsigned int groups = nladdr->nl_groups;
 	bool bound;
+	unsigned long nlgroups;
 
 	if (addr_len < sizeof(struct sockaddr_nl))
 		return -EINVAL;
@@ -1576,14 +1577,17 @@ static int netlink_bind(struct socket *sock, struct sockaddr *addr,
 		}
 	}
 
-	if (!groups && (nlk->groups == NULL || !(u32)nlk->groups[0]))
+	if (nlk->groups == NULL)
+		return 0;
+	nlgroups = nlk->groups[0];
+	if (!groups && !(u32)nlgroups)
 		return 0;
 
 	netlink_table_grab();
 	netlink_update_subscriptions(sk, nlk->subscriptions +
 					 hweight32(groups) -
-					 hweight32(nlk->groups[0]));
-	nlk->groups[0] = (nlk->groups[0] & ~0xffffffffUL) | groups;
+					 hweight32(nlgroups));
+	nlk->groups[0] = (nlgroups & ~0xffffffffUL) | groups;
 	netlink_update_listeners(sk);
 	netlink_table_ungrab();
 
-- 
1.9.1
