From: pablo@netfilter.org
Subject: [PATCH 17/18] netfilter: nfnetlink: check callbacks before using those in nfnetlink_rcv_msg
Date: Fri,  6 Jul 2012 13:17:07 +0200
Message-ID: <1341573428-3204-18-git-send-email-pablo@netfilter.org>
References: <1341573428-3204-1-git-send-email-pablo@netfilter.org>
Cc: davem@davemloft.net, netdev@vger.kernel.org
To: netfilter-devel@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail.us.es ([193.147.175.20]:43561 "EHLO mail.us.es"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S933565Ab2GFLTO (ORCPT <rfc822;netdev@vger.kernel.org>);
	Fri, 6 Jul 2012 07:19:14 -0400
In-Reply-To: <1341573428-3204-1-git-send-email-pablo@netfilter.org>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Tomasz Bursztyka <tomasz.bursztyka@linux.intel.com>

nfnetlink_rcv_msg() might call a NULL callback which will cause NULL pointer
dereference.

Signed-off-by: Tomasz Bursztyka <tomasz.bursztyka@linux.intel.com>
Signed-off-by: Pablo Neira Ayuso <pablo@netfilter.org>
---
 net/netfilter/nfnetlink.c |    4 +++-
 1 file changed, 3 insertions(+), 1 deletion(-)

diff --git a/net/netfilter/nfnetlink.c b/net/netfilter/nfnetlink.c
index 3e797d1..4acdd76 100644
--- a/net/netfilter/nfnetlink.c
+++ b/net/netfilter/nfnetlink.c
@@ -184,9 +184,11 @@ replay:
 					lockdep_is_held(&nfnl_mutex)) != ss ||
 			    nfnetlink_find_client(type, ss) != nc)
 				err = -EAGAIN;
-			else
+			else if (nc->call)
 				err = nc->call(net->nfnl, skb, nlh,
 						   (const struct nlattr **)cda);
+			else
+				err = -EINVAL;
 			nfnl_unlock();
 		}
 		if (err == -EAGAIN)
-- 
1.7.10
