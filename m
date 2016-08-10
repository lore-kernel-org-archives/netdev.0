From: Pablo Neira Ayuso <pablo@netfilter.org>
Subject: [PATCH 1/9] netfilter: nf_ct_h323: do not re-activate already expired timer
Date: Wed, 10 Aug 2016 21:16:37 +0200
Message-ID: <1470856605-7903-2-git-send-email-pablo@netfilter.org>
References: <1470856605-7903-1-git-send-email-pablo@netfilter.org>
Cc: davem@davemloft.net, netdev@vger.kernel.org
To: netfilter-devel@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail.us.es ([193.147.175.20]:58018 "EHLO mail.us.es"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S933821AbcHJTQ4 (ORCPT <rfc822;netdev@vger.kernel.org>);
	Wed, 10 Aug 2016 15:16:56 -0400
Received: from antivirus1-rhel7.int (unknown [192.168.2.11])
	by mail.us.es (Postfix) with ESMTP id C3F801F18CB
	for <netdev@vger.kernel.org>; Wed, 10 Aug 2016 21:16:54 +0200 (CEST)
Received: from antivirus1-rhel7.int (localhost [127.0.0.1])
	by antivirus1-rhel7.int (Postfix) with ESMTP id A99FE100A60
	for <netdev@vger.kernel.org>; Wed, 10 Aug 2016 21:16:54 +0200 (CEST)
Received: from antivirus1-rhel7.int (localhost [127.0.0.1])
	by antivirus1-rhel7.int (Postfix) with ESMTP id D51E0100794
	for <netdev@vger.kernel.org>; Wed, 10 Aug 2016 21:16:50 +0200 (CEST)
In-Reply-To: <1470856605-7903-1-git-send-email-pablo@netfilter.org>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Liping Zhang <liping.zhang@spreadtrum.com>

Commit 96d1327ac2e3 ("netfilter: h323: Use mod_timer instead of
set_expect_timeout") just simplify the source codes
    if (!del_timer(&exp->timeout))
        return 0;
    add_timer(&exp->timeout);
to mod_timer(&exp->timeout, jiffies + info->timeout * HZ);

This is not correct, and introduce a race codition:
    CPU0                     CPU1
     -                     timer expire
  process_rcf              expectation_timed_out
  lock(exp_lock)              -
  find_exp                 waiting exp_lock...
  re-activate timer!!      waiting exp_lock...
  unlock(exp_lock)         lock(exp_lock)
     -                     unlink expect
     -                     free(expect)
     -                     unlock(exp_lock)
So when the timer expires again, we will access the memory that
was already freed.

Replace mod_timer with mod_timer_pending here to fix this problem.

Fixes: 96d1327ac2e3 ("netfilter: h323: Use mod_timer instead of set_expect_timeout")
Cc: Gao Feng <fgao@ikuai8.com>
Signed-off-by: Liping Zhang <liping.zhang@spreadtrum.com>
Signed-off-by: Pablo Neira Ayuso <pablo@netfilter.org>
---
 net/netfilter/nf_conntrack_h323_main.c | 3 ++-
 1 file changed, 2 insertions(+), 1 deletion(-)

diff --git a/net/netfilter/nf_conntrack_h323_main.c b/net/netfilter/nf_conntrack_h323_main.c
index bb77a97..5c0db5c 100644
--- a/net/netfilter/nf_conntrack_h323_main.c
+++ b/net/netfilter/nf_conntrack_h323_main.c
@@ -1473,7 +1473,8 @@ static int process_rcf(struct sk_buff *skb, struct nf_conn *ct,
 				 "timeout to %u seconds for",
 				 info->timeout);
 			nf_ct_dump_tuple(&exp->tuple);
-			mod_timer(&exp->timeout, jiffies + info->timeout * HZ);
+			mod_timer_pending(&exp->timeout,
+					  jiffies + info->timeout * HZ);
 		}
 		spin_unlock_bh(&nf_conntrack_expect_lock);
 	}
-- 
2.1.4
