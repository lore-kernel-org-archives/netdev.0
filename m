From: Nicolas Dichtel <nicolas.dichtel@6wind.com>
Subject: [PATCH net] netlink: don't send unknown nsid
Date: Thu,  1 Jun 2017 10:00:07 +0200
Message-ID: <1496304007-1962-1-git-send-email-nicolas.dichtel@6wind.com>
References: <4942f9fe-625b-bb97-7b45-4a1e8bf69b1b@6wind.com>
Cc: netdev@vger.kernel.org, fbl@sysclose.org,
        Nicolas Dichtel <nicolas.dichtel@6wind.com>
To: davem@davemloft.net
Return-path: <netdev-owner@vger.kernel.org>
Received: from host.76.145.23.62.rev.coltfrance.com ([62.23.145.76]:54304 "EHLO
        proxy.6wind.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1751013AbdFAIKZ (ORCPT
        <rfc822;netdev@vger.kernel.org>); Thu, 1 Jun 2017 04:10:25 -0400
In-Reply-To: <4942f9fe-625b-bb97-7b45-4a1e8bf69b1b@6wind.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

The NETLINK_F_LISTEN_ALL_NSID otion enables to listen all netns that have a
nsid assigned into the netns where the netlink socket is opened.
The nsid is sent as metadata to userland, but the existence of this nsid is
checked only for netns that are different from the socket netns. Thus, if
no nsid is assigned to the socket netns, NETNSA_NSID_NOT_ASSIGNED is
reported to the userland. This value is confusing and useless.
After this patch, only valid nsid are sent to userland.

Reported-by: Flavio Leitner <fbl@sysclose.org>
Signed-off-by: Nicolas Dichtel <nicolas.dichtel@6wind.com>
---
 net/netlink/af_netlink.c | 4 +++-
 1 file changed, 3 insertions(+), 1 deletion(-)

diff --git a/net/netlink/af_netlink.c b/net/netlink/af_netlink.c
index ee841f00a6ec..7586d446d7dc 100644
--- a/net/netlink/af_netlink.c
+++ b/net/netlink/af_netlink.c
@@ -62,6 +62,7 @@
 #include <asm/cacheflush.h>
 #include <linux/hash.h>
 #include <linux/genetlink.h>
+#include <linux/net_namespace.h>
 
 #include <net/net_namespace.h>
 #include <net/sock.h>
@@ -1415,7 +1416,8 @@ static void do_one_broadcast(struct sock *sk,
 		goto out;
 	}
 	NETLINK_CB(p->skb2).nsid = peernet2id(sock_net(sk), p->net);
-	NETLINK_CB(p->skb2).nsid_is_set = true;
+	if (NETLINK_CB(p->skb2).nsid != NETNSA_NSID_NOT_ASSIGNED)
+		NETLINK_CB(p->skb2).nsid_is_set = true;
 	val = netlink_broadcast_deliver(sk, p->skb2);
 	if (val < 0) {
 		netlink_overrun(sk);
-- 
2.8.1
