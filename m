From: Florian Westphal <fw@strlen.de>
Subject: [PATCH 1/4] netlink: append NLMSG_DONE to compatskb, too
Date: Tue,  6 Apr 2010 00:27:08 +0200
Message-ID: <1270506431-25578-2-git-send-email-fw@strlen.de>
References: <1270506431-25578-1-git-send-email-fw@strlen.de>
Cc: johannes@sipsolutions.net, Florian Westphal <fwestphal@astaro.com>,
	Florian Westphal <fw@strlen.de>
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from Chamillionaire.breakpoint.cc ([85.10.199.196]:60850 "EHLO
	Chamillionaire.breakpoint.cc" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with ESMTP id S1756787Ab0DEW2x (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 5 Apr 2010 18:28:53 -0400
In-Reply-To: <1270506431-25578-1-git-send-email-fw@strlen.de>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Florian Westphal <fwestphal@astaro.com>

modules using netlink may supply a 2nd skb, (via frag_list)
that contains an alternative data set meant for applications
using 32bit compatibility mode.

In such a case, netlink_recvmsg will use this 2nd skb instead of the
original one.

Without this patch, such compat applications will retrieve
all netlink dump data, but will then get an unexpected EOF.

Cc: Johannes Berg <johannes@sipsolutions.net>
Signed-off-by: Florian Westphal <fw@strlen.de>
---
 net/netlink/af_netlink.c |    8 ++++++++
 1 files changed, 8 insertions(+), 0 deletions(-)

diff --git a/net/netlink/af_netlink.c b/net/netlink/af_netlink.c
index 274d977..beaada0 100644
--- a/net/netlink/af_netlink.c
+++ b/net/netlink/af_netlink.c
@@ -1709,6 +1709,14 @@ static int netlink_dump(struct sock *sk)
 
 	memcpy(nlmsg_data(nlh), &len, sizeof(len));
 
+#ifdef CONFIG_COMPAT_NETLINK_MESSAGES
+	if (unlikely(skb_shinfo(skb)->frag_list)) {
+		nlh = nlmsg_put_answer(skb_shinfo(skb)->frag_list, cb,
+					NLMSG_DONE, sizeof(len), NLM_F_MULTI);
+		if (nlh)
+			memcpy(nlmsg_data(nlh), &len, sizeof(len));
+	}
+#endif
 	if (sk_filter(sk, skb))
 		kfree_skb(skb);
 	else {
-- 
1.6.4.4

