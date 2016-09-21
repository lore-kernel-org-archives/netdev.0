From: Aaron Conole <aconole@bytheb.org>
Subject: [PATCH nf-next v3 3/7] netfilter: call nf_hook_ingress with rcu_read_lock
Date: Wed, 21 Sep 2016 11:35:03 -0400
Message-ID: <1474472107-12992-4-git-send-email-aconole@bytheb.org>
References: <1474472107-12992-1-git-send-email-aconole@bytheb.org>
Cc: Florian Westphal <fw@strlen.de>,
        Pablo Neira Ayuso <pablo@netfilter.org>
To: netfilter-devel@vger.kernel.org, netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-yw0-f196.google.com ([209.85.161.196]:35978 "EHLO
        mail-yw0-f196.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1757822AbcIUPfp (ORCPT
        <rfc822;netdev@vger.kernel.org>); Wed, 21 Sep 2016 11:35:45 -0400
Received: by mail-yw0-f196.google.com with SMTP id v2so3078585ywg.3
        for <netdev@vger.kernel.org>; Wed, 21 Sep 2016 08:35:45 -0700 (PDT)
In-Reply-To: <1474472107-12992-1-git-send-email-aconole@bytheb.org>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

This commit ensures that the rcu read-side lock is held while the
ingress hook is called.  This ensures that a call to nf_hook_slow (and
ultimately nf_ingress) will be read protected.

Signed-off-by: Aaron Conole <aconole@bytheb.org>
---
 net/core/dev.c | 7 ++++++-
 1 file changed, 6 insertions(+), 1 deletion(-)

diff --git a/net/core/dev.c b/net/core/dev.c
index 34b5322..0649194 100644
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
2.7.4
