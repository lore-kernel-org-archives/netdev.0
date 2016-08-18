From: Pablo Neira Ayuso <pablo@netfilter.org>
Subject: [PATCH 5/6] netfilter: nfnetlink_acct: fix race between nfacct del and xt_nfacct destroy
Date: Thu, 18 Aug 2016 19:29:07 +0200
Message-ID: <1471541348-1538-6-git-send-email-pablo@netfilter.org>
References: <1471541348-1538-1-git-send-email-pablo@netfilter.org>
Cc: davem@davemloft.net, netdev@vger.kernel.org
To: netfilter-devel@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail.us.es ([193.147.175.20]:43980 "EHLO mail.us.es"
        rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
        id S1754158AbcHSA5m (ORCPT <rfc822;netdev@vger.kernel.org>);
        Thu, 18 Aug 2016 20:57:42 -0400
Received: from antivirus1-rhel7.int (unknown [192.168.2.11])
        by mail.us.es (Postfix) with ESMTP id 86C296EF28
        for <netdev@vger.kernel.org>; Thu, 18 Aug 2016 19:29:29 +0200 (CEST)
Received: from antivirus1-rhel7.int (localhost [127.0.0.1])
        by antivirus1-rhel7.int (Postfix) with ESMTP id 78771CA102
        for <netdev@vger.kernel.org>; Thu, 18 Aug 2016 19:29:29 +0200 (CEST)
Received: from antivirus1-rhel7.int (localhost [127.0.0.1])
        by antivirus1-rhel7.int (Postfix) with ESMTP id C65B3FF2FD
        for <netdev@vger.kernel.org>; Thu, 18 Aug 2016 19:29:20 +0200 (CEST)
In-Reply-To: <1471541348-1538-1-git-send-email-pablo@netfilter.org>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Liping Zhang <liping.zhang@spreadtrum.com>

Suppose that we input the following commands at first:
  # nfacct add test
  # iptables -A INPUT -m nfacct --nfacct-name test

And now "test" acct's refcnt is 2, but later when we try to delete the
"test" nfacct and the related iptables rule at the same time, race maybe
happen:
      CPU0                                    CPU1
  nfnl_acct_try_del                      nfnl_acct_put
  atomic_dec_and_test //ref=1,testfail          -
       -                                 atomic_dec_and_test //ref=0,testok
       -                                 kfree_rcu
  atomic_inc //ref=1                            -

So after the rcu grace period, nf_acct will be freed but it is still linked
in the nfnl_acct_list, and we can access it later, then oops will happen.

Convert atomic_dec_and_test and atomic_inc combinaiton to one atomic
operation atomic_cmpxchg here to fix this problem.

Signed-off-by: Liping Zhang <liping.zhang@spreadtrum.com>
Signed-off-by: Pablo Neira Ayuso <pablo@netfilter.org>
---
 net/netfilter/nfnetlink_acct.c | 8 ++++----
 1 file changed, 4 insertions(+), 4 deletions(-)

diff --git a/net/netfilter/nfnetlink_acct.c b/net/netfilter/nfnetlink_acct.c
index 796605b..70eb2f6a 100644
--- a/net/netfilter/nfnetlink_acct.c
+++ b/net/netfilter/nfnetlink_acct.c
@@ -326,14 +326,14 @@ static int nfnl_acct_try_del(struct nf_acct *cur)
 {
 	int ret = 0;
 
-	/* we want to avoid races with nfnl_acct_find_get. */
-	if (atomic_dec_and_test(&cur->refcnt)) {
+	/* We want to avoid races with nfnl_acct_put. So only when the current
+	 * refcnt is 1, we decrease it to 0.
+	 */
+	if (atomic_cmpxchg(&cur->refcnt, 1, 0) == 1) {
 		/* We are protected by nfnl mutex. */
 		list_del_rcu(&cur->head);
 		kfree_rcu(cur, rcu_head);
 	} else {
-		/* still in use, restore reference counter. */
-		atomic_inc(&cur->refcnt);
 		ret = -EBUSY;
 	}
 	return ret;
-- 
2.1.4
