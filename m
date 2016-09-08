From: Steffen Klassert <steffen.klassert@secunet.com>
Subject: [PATCH 12/17] xfrm: policy: make xfrm_policy_lookup_bytype lockless
Date: Thu, 8 Sep 2016 07:54:47 +0200
Message-ID: <1473314092-11319-13-git-send-email-steffen.klassert@secunet.com>
References: <1473314092-11319-1-git-send-email-steffen.klassert@secunet.com>
Mime-Version: 1.0
Content-Type: text/plain
Cc: Herbert Xu <herbert@gondor.apana.org.au>,
        Steffen Klassert <steffen.klassert@secunet.com>,
        <netdev@vger.kernel.org>
To: David Miller <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from a.mx.secunet.com ([62.96.220.36]:36357 "EHLO a.mx.secunet.com"
        rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
        id S1752965AbcIHGv0 (ORCPT <rfc822;netdev@vger.kernel.org>);
        Thu, 8 Sep 2016 02:51:26 -0400
In-Reply-To: <1473314092-11319-1-git-send-email-steffen.klassert@secunet.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Florian Westphal <fw@strlen.de>

side effect: no longer disables BH (should be fine).

Signed-off-by: Florian Westphal <fw@strlen.de>
Signed-off-by: Steffen Klassert <steffen.klassert@secunet.com>
---
 include/net/netns/xfrm.h | 2 +-
 net/xfrm/xfrm_policy.c   | 4 ++--
 2 files changed, 3 insertions(+), 3 deletions(-)

diff --git a/include/net/netns/xfrm.h b/include/net/netns/xfrm.h
index 1ab51d1..3ab828a 100644
--- a/include/net/netns/xfrm.h
+++ b/include/net/netns/xfrm.h
@@ -11,7 +11,7 @@
 struct ctl_table_header;
 
 struct xfrm_policy_hash {
-	struct hlist_head	*table;
+	struct hlist_head	__rcu *table;
 	unsigned int		hmask;
 	u8			dbits4;
 	u8			sbits4;
diff --git a/net/xfrm/xfrm_policy.c b/net/xfrm/xfrm_policy.c
index 09f2e2b..9302647 100644
--- a/net/xfrm/xfrm_policy.c
+++ b/net/xfrm/xfrm_policy.c
@@ -1123,7 +1123,7 @@ static struct xfrm_policy *xfrm_policy_lookup_bytype(struct net *net, u8 type,
 	if (unlikely(!daddr || !saddr))
 		return NULL;
 
-	read_lock_bh(&net->xfrm.xfrm_policy_lock);
+	rcu_read_lock();
  retry:
 	do {
 		sequence = read_seqcount_begin(&xfrm_policy_hash_generation);
@@ -1172,7 +1172,7 @@ static struct xfrm_policy *xfrm_policy_lookup_bytype(struct net *net, u8 type,
 	if (ret && !xfrm_pol_hold_rcu(ret))
 		goto retry;
 fail:
-	read_unlock_bh(&net->xfrm.xfrm_policy_lock);
+	rcu_read_unlock();
 
 	return ret;
 }
-- 
1.9.1
