From: Nicolas Dichtel <nicolas.dichtel@6wind.com>
Subject: [PATCH net-next 2/2] netns: fix error code when the nsid is already used
Date: Fri,  9 Jun 2017 14:41:57 +0200
Message-ID: <1497012117-1344-2-git-send-email-nicolas.dichtel@6wind.com>
References: <1497012117-1344-1-git-send-email-nicolas.dichtel@6wind.com>
Cc: netdev@vger.kernel.org,
        Nicolas Dichtel <nicolas.dichtel@6wind.com>,
        Jamal Hadi Salim <jhs@mojatatu.com>
To: davem@davemloft.net
Return-path: <netdev-owner@vger.kernel.org>
Received: from host.76.145.23.62.rev.coltfrance.com ([62.23.145.76]:48389 "EHLO
        proxy.6wind.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1751684AbdFIN5b (ORCPT
        <rfc822;netdev@vger.kernel.org>); Fri, 9 Jun 2017 09:57:31 -0400
In-Reply-To: <1497012117-1344-1-git-send-email-nicolas.dichtel@6wind.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

When the user tries to assign a specific nsid, idr_alloc() is called with
the range [nsid, nsid+1]. If this nsid is already used, idr_alloc() returns
ENOSPC (No space left on device). In our case, it's better to return
EEXIST to make it clear that the nsid is not available.

CC: Jamal Hadi Salim <jhs@mojatatu.com>
Signed-off-by: Nicolas Dichtel <nicolas.dichtel@6wind.com>
---
 net/core/net_namespace.c | 1 +
 1 file changed, 1 insertion(+)

diff --git a/net/core/net_namespace.c b/net/core/net_namespace.c
index 1f60c180e2de..2178db8e47cd 100644
--- a/net/core/net_namespace.c
+++ b/net/core/net_namespace.c
@@ -642,6 +642,7 @@ static int rtnl_net_newid(struct sk_buff *skb, struct nlmsghdr *nlh,
 		rtnl_net_notifyid(net, RTM_NEWNSID, err);
 		err = 0;
 	} else if (err == -ENOSPC && nsid >= 0) {
+		err = -EEXIST;
 		NL_SET_BAD_ATTR(extack, tb[NETNSA_NSID]);
 		NL_SET_ERR_MSG(extack, "The specified nsid is already used");
 	}
-- 
2.8.1
