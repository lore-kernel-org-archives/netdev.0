From: Patrick McHardy <kaber@trash.net>
Subject: netfilter 21/41: xt_hashlimit fix
Date: Tue, 24 Mar 2009 15:03:35 +0100 (MET)
Message-ID: <20090324140330.31401.74214.sendpatchset@x2.localnet>
References: <20090324140302.31401.37732.sendpatchset@x2.localnet>
Cc: netdev@vger.kernel.org, Patrick McHardy <kaber@trash.net>,
	netfilter-devel@vger.kernel.org
To: davem@davemloft.net
Return-path: <netdev-owner@vger.kernel.org>
Received: from stinky.trash.net ([213.144.137.162]:34794 "EHLO
	stinky.trash.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1758357AbZCXODh (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 24 Mar 2009 10:03:37 -0400
In-Reply-To: <20090324140302.31401.37732.sendpatchset@x2.localnet>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

commit 28337ff5438a640afa713d874d076e3a8a9150da
Author: Eric Dumazet <dada1@cosmosbay.com>
Date:   Tue Feb 24 15:30:29 2009 +0100

    netfilter: xt_hashlimit fix
    
    Commit 784544739a25c30637397ace5489eeb6e15d7d49
    (netfilter: iptables: lock free counters) broke xt_hashlimit netfilter module :
    
    This module was storing a pointer inside its xt_hashlimit_info, and this pointer
    is not relocated when we temporarly switch tables (iptables -L).
    
    This hack is not not needed at all (probably a leftover from
    ancient time), as each cpu should and can access to its own copy.
    
    Signed-off-by: Eric Dumazet <dada1@cosmosbay.com>
    Signed-off-by: Patrick McHardy <kaber@trash.net>

diff --git a/net/netfilter/xt_hashlimit.c b/net/netfilter/xt_hashlimit.c
index 2482055..a5b5369 100644
--- a/net/netfilter/xt_hashlimit.c
+++ b/net/netfilter/xt_hashlimit.c
@@ -565,8 +565,7 @@ hashlimit_init_dst(const struct xt_hashlimit_htable *hinfo,
 static bool
 hashlimit_mt_v0(const struct sk_buff *skb, const struct xt_match_param *par)
 {
-	const struct xt_hashlimit_info *r =
-		((const struct xt_hashlimit_info *)par->matchinfo)->u.master;
+	const struct xt_hashlimit_info *r = par->matchinfo;
 	struct xt_hashlimit_htable *hinfo = r->hinfo;
 	unsigned long now = jiffies;
 	struct dsthash_ent *dh;
@@ -702,8 +701,6 @@ static bool hashlimit_mt_check_v0(const struct xt_mtchk_param *par)
 	}
 	mutex_unlock(&hlimit_mutex);
 
-	/* Ugly hack: For SMP, we only want to use one set */
-	r->u.master = r;
 	return true;
 }
 
