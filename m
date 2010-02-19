From: Florian Westphal <fwestphal@astaro.com>
Subject: [PATCH 1/5] netlink: append NLMSG_DONE to compatskb, too
Date: Fri, 19 Feb 2010 13:41:43 +0100
Message-ID: <1266583307-3049-2-git-send-email-fwestphal@astaro.com>
References: <1266583307-3049-1-git-send-email-fwestphal@astaro.com>
Cc: johannes@sipsolutions.net, Florian Westphal <fwestphal@astaro.com>
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from Chamillionaire.breakpoint.cc ([85.10.199.196]:48615 "EHLO
	Chamillionaire.breakpoint.cc" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with ESMTP id S1751312Ab0BSMln (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 19 Feb 2010 07:41:43 -0500
In-Reply-To: <1266583307-3049-1-git-send-email-fwestphal@astaro.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

modules using netlink may supply a 2nd skb, (via frag_list)
that contains an alternative data set meant for applications
using 32bit compatibility mode.

In such a case, netlink_recvmsg will use this 2nd skb instead of the
original one.

Without this patch, such compat applications will retrieve
all netlink dump data, but will then get an unexpected EOF.

Cc: Johannes Berg <johannes@sipsolutions.net>
Signed-off-by: Florian Westphal <fwestphal@astaro.com>
---
 no changes since v1.

 net/netlink/af_netlink.c |    8 ++++++++
 1 files changed, 8 insertions(+), 0 deletions(-)

diff --git a/net/netlink/af_netlink.c b/net/netlink/af_netlink.c
index 4c5972b..4910031 100644
--- a/net/netlink/af_netlink.c
+++ b/net/netlink/af_netlink.c
@@ -1698,6 +1698,14 @@ static int netlink_dump(struct sock *sk)
 
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
1.6.3.3

