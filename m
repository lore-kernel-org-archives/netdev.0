From: Florian Westphal <fw@strlen.de>
Subject: [PATCH ipsec-next 5/8] xfrm: policy: make xfrm_policy_lookup_bytype lockless
Date: Thu, 11 Aug 2016 15:17:56 +0200
Message-ID: <1470921479-25592-6-git-send-email-fw@strlen.de>
References: <1470921479-25592-1-git-send-email-fw@strlen.de>
Cc: Florian Westphal <fw@strlen.de>
To: <netdev@vger.kernel.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from Chamillionaire.breakpoint.cc ([146.0.238.67]:54976 "EHLO
	Chamillionaire.breakpoint.cc" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with ESMTP id S1752723AbcHKNR6 (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 11 Aug 2016 09:17:58 -0400
In-Reply-To: <1470921479-25592-1-git-send-email-fw@strlen.de>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

side effect: no longer disables BH (should be fine).

Signed-off-by: Florian Westphal <fw@strlen.de>
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
index cbc9005..398661c 100644
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
2.7.3
