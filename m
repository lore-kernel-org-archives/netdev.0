From: pablo@netfilter.org
Subject: [PATCH 1/4] netfilter: ctnetlink: fix NULL dereference while trying to change helper
Date: Tue, 19 Jun 2012 05:16:26 +0200
Message-ID: <1340075789-6196-2-git-send-email-pablo@netfilter.org>
References: <1340075789-6196-1-git-send-email-pablo@netfilter.org>
Cc: davem@davemloft.net, netdev@vger.kernel.org
To: netfilter-devel@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail.us.es ([193.147.175.20]:53884 "EHLO mail.us.es"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1752886Ab2FSDRM (ORCPT <rfc822;netdev@vger.kernel.org>);
	Mon, 18 Jun 2012 23:17:12 -0400
In-Reply-To: <1340075789-6196-1-git-send-email-pablo@netfilter.org>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Pablo Neira Ayuso <pablo@netfilter.org>

The patch 1afc56794e03: "netfilter: nf_ct_helper: implement variable
length helper private data" from Jun 7, 2012, leads to the following
Smatch complaint:

net/netfilter/nf_conntrack_netlink.c:1231 ctnetlink_change_helper()
         error: we previously assumed 'help->helper' could be null (see line 1228)

This NULL dereference can be triggered with the following sequence:

1) attach the helper for first time when the conntrack is created.
2) remove the helper module or detach the helper from the conntrack
   via ctnetlink.
3) attach helper again (the same or different one, no matter) to the
   that existing conntrack again via ctnetlink.

This patch fixes the problem by removing the use case that allows you
to re-assign again a helper for one conntrack entry via ctnetlink since
I cannot find any practical use for it.

Reported-by: Dan Carpenter <dan.carpenter@oracle.com>
Signed-off-by: Pablo Neira Ayuso <pablo@netfilter.org>
---
 net/netfilter/nf_conntrack_netlink.c |   13 +++----------
 1 file changed, 3 insertions(+), 10 deletions(-)

diff --git a/net/netfilter/nf_conntrack_netlink.c b/net/netfilter/nf_conntrack_netlink.c
index ae156df..76271a1 100644
--- a/net/netfilter/nf_conntrack_netlink.c
+++ b/net/netfilter/nf_conntrack_netlink.c
@@ -1224,19 +1224,12 @@ ctnetlink_change_helper(struct nf_conn *ct, const struct nlattr * const cda[])
 			if (helper->from_nlattr && helpinfo)
 				helper->from_nlattr(helpinfo, ct);
 			return 0;
-		}
-		if (help->helper)
+		} else
 			return -EBUSY;
-		/* need to zero data of old helper */
-		memset(help->data, 0, help->helper->data_len);
-	} else {
-		/* we cannot set a helper for an existing conntrack */
-		return -EOPNOTSUPP;
 	}
 
-	rcu_assign_pointer(help->helper, helper);
-
-	return 0;
+	/* we cannot set a helper for an existing conntrack */
+	return -EOPNOTSUPP;
 }
 
 static inline int
-- 
1.7.10
