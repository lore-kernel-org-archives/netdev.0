From: Jiri Benc <jbenc@redhat.com>
Subject: [PATCH net-next] nfnetlink: do not ack malformed messages
Date: Thu,  7 Nov 2013 19:59:19 +0100
Message-ID: <fa44451df8aa56773b1b17cbbd86ced8b54eca5a.1383850681.git.jbenc@redhat.com>
Cc: Pablo Neira Ayuso <pablo@netfilter.org>,
	Petr Matousek <pmatouse@redhat.com>
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mx1.redhat.com ([209.132.183.28]:3105 "EHLO mx1.redhat.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1750793Ab3KGTA4 (ORCPT <rfc822;netdev@vger.kernel.org>);
	Thu, 7 Nov 2013 14:00:56 -0500
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Commit 0628b123c96d ("netfilter: nfnetlink: add batch support and use it
from nf_tables") introduced a bug leading to various crashes in netlink_ack
when netlink message with invalid nlmsg_len was sent by an unprivileged
user.

Signed-off-by: Jiri Benc <jbenc@redhat.com>
---
 net/netfilter/nfnetlink.c |    8 +++++---
 1 files changed, 5 insertions(+), 3 deletions(-)

diff --git a/net/netfilter/nfnetlink.c b/net/netfilter/nfnetlink.c
index 027f16a..046aa13 100644
--- a/net/netfilter/nfnetlink.c
+++ b/net/netfilter/nfnetlink.c
@@ -363,13 +363,15 @@ static void nfnetlink_rcv(struct sk_buff *skb)
 	struct net *net = sock_net(skb->sk);
 	int msglen;
 
-	if (!ns_capable(net->user_ns, CAP_NET_ADMIN))
-		return netlink_ack(skb, nlh, -EPERM);
-
 	if (nlh->nlmsg_len < NLMSG_HDRLEN ||
 	    skb->len < nlh->nlmsg_len)
 		return;
 
+	if (!ns_capable(net->user_ns, CAP_NET_ADMIN)) {
+		netlink_ack(skb, nlh, -EPERM);
+		return;
+	}
+
 	if (nlh->nlmsg_type == NFNL_MSG_BATCH_BEGIN) {
 		struct nfgenmsg *nfgenmsg;
 
-- 
1.7.6.5
