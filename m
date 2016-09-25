From: Pablo Neira Ayuso <pablo@netfilter.org>
Subject: [PATCH 39/53] netfilter: call nf_hook_ingress with rcu_read_lock
Date: Mon, 26 Sep 2016 01:06:49 +0200
Message-ID: <1474844823-2026-40-git-send-email-pablo@netfilter.org>
References: <1474844823-2026-1-git-send-email-pablo@netfilter.org>
Cc: davem@davemloft.net, netdev@vger.kernel.org
To: netfilter-devel@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail.us.es ([193.147.175.20]:54768 "EHLO mail.us.es"
        rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
        id S1034844AbcIYXIA (ORCPT <rfc822;netdev@vger.kernel.org>);
        Sun, 25 Sep 2016 19:08:00 -0400
Received: from antivirus1-rhel7.int (unknown [192.168.2.11])
        by mail.us.es (Postfix) with ESMTP id CE175C8812
        for <netdev@vger.kernel.org>; Mon, 26 Sep 2016 01:07:58 +0200 (CEST)
Received: from antivirus1-rhel7.int (localhost [127.0.0.1])
        by antivirus1-rhel7.int (Postfix) with ESMTP id BE27FDA842
        for <netdev@vger.kernel.org>; Mon, 26 Sep 2016 01:07:58 +0200 (CEST)
Received: from antivirus1-rhel7.int (localhost [127.0.0.1])
        by antivirus1-rhel7.int (Postfix) with ESMTP id A9E97DA817
        for <netdev@vger.kernel.org>; Mon, 26 Sep 2016 01:07:56 +0200 (CEST)
In-Reply-To: <1474844823-2026-1-git-send-email-pablo@netfilter.org>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Aaron Conole <aconole@bytheb.org>

This commit ensures that the rcu read-side lock is held while the
ingress hook is called.  This ensures that a call to nf_hook_slow (and
ultimately nf_ingress) will be read protected.

Signed-off-by: Aaron Conole <aconole@bytheb.org>
Signed-off-by: Pablo Neira Ayuso <pablo@netfilter.org>
---
 net/core/dev.c | 7 ++++++-
 1 file changed, 6 insertions(+), 1 deletion(-)

diff --git a/net/core/dev.c b/net/core/dev.c
index 34b5322bc081..064919425b7d 100644
--- a/net/core/dev.c
+++ b/net/core/dev.c
@@ -4040,12 +4040,17 @@ static inline int nf_ingress(struct sk_buff *skb, struct packet_type **pt_prev,
 {
 #ifdef CONFIG_NETFILTER_INGRESS
 	if (nf_hook_ingress_active(skb)) {
+		int ingress_retval;
+
 		if (*pt_prev) {
 			*ret = deliver_skb(skb, *pt_prev, orig_dev);
 			*pt_prev = NULL;
 		}
 
-		return nf_hook_ingress(skb);
+		rcu_read_lock();
+		ingress_retval = nf_hook_ingress(skb);
+		rcu_read_unlock();
+		return ingress_retval;
 	}
 #endif /* CONFIG_NETFILTER_INGRESS */
 	return 0;
-- 
2.1.4
