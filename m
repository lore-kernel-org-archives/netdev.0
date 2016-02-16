From: Pablo Neira Ayuso <pablo@netfilter.org>
Subject: [PATCH 3/6] netfilter: cttimeout: fix deadlock due to erroneous unlock/lock conversion
Date: Tue, 16 Feb 2016 18:02:34 +0100
Message-ID: <1455642157-6864-4-git-send-email-pablo@netfilter.org>
References: <1455642157-6864-1-git-send-email-pablo@netfilter.org>
Cc: davem@davemloft.net, netdev@vger.kernel.org
To: netfilter-devel@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail.us.es ([193.147.175.20]:52931 "EHLO mail.us.es"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S932143AbcBPREU (ORCPT <rfc822;netdev@vger.kernel.org>);
	Tue, 16 Feb 2016 12:04:20 -0500
Received: from antivirus1-rhel7.int (unknown [192.168.2.11])
	by mail.us.es (Postfix) with ESMTP id A92246EF43
	for <netdev@vger.kernel.org>; Tue, 16 Feb 2016 18:04:19 +0100 (CET)
Received: from antivirus1-rhel7.int (localhost [127.0.0.1])
	by antivirus1-rhel7.int (Postfix) with ESMTP id 99C7E1B3D29
	for <netdev@vger.kernel.org>; Tue, 16 Feb 2016 18:04:19 +0100 (CET)
Received: from antivirus1-rhel7.int (localhost [127.0.0.1])
	by antivirus1-rhel7.int (Postfix) with ESMTP id 9C6EE1B3D29
	for <netdev@vger.kernel.org>; Tue, 16 Feb 2016 18:04:15 +0100 (CET)
In-Reply-To: <1455642157-6864-1-git-send-email-pablo@netfilter.org>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Florian Westphal <fw@strlen.de>

The spin_unlock call should have been left as-is, revert.

Fixes: b16c29191dc89bd ("netfilter: nf_conntrack: use safer way to lock all buckets")
Reported-by: kernel test robot <fengguang.wu@intel.com>
Signed-off-by: Florian Westphal <fw@strlen.de>
Signed-off-by: Pablo Neira Ayuso <pablo@netfilter.org>
---
 net/netfilter/nfnetlink_cttimeout.c | 2 +-
 1 file changed, 1 insertion(+), 1 deletion(-)

diff --git a/net/netfilter/nfnetlink_cttimeout.c b/net/netfilter/nfnetlink_cttimeout.c
index 94837d2..2671b9d 100644
--- a/net/netfilter/nfnetlink_cttimeout.c
+++ b/net/netfilter/nfnetlink_cttimeout.c
@@ -312,7 +312,7 @@ static void ctnl_untimeout(struct net *net, struct ctnl_timeout *timeout)
 			hlist_nulls_for_each_entry(h, nn, &net->ct.hash[i], hnnode)
 				untimeout(h, timeout);
 		}
-		nf_conntrack_lock(&nf_conntrack_locks[i % CONNTRACK_LOCKS]);
+		spin_unlock(&nf_conntrack_locks[i % CONNTRACK_LOCKS]);
 	}
 	local_bh_enable();
 }
-- 
2.1.4
