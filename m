From: Michal Kubecek <mkubecek@suse.cz>
Subject: [PATCH nf] netfilter: use RCU safe kfree for conntrack extensions
Date: Wed, 11 Sep 2013 10:17:27 +0200
Message-ID: <20130911090900.0129AE8AFF@unicorn.suse.cz>
Cc: netdev@vger.kernel.org, Pablo Neira Ayuso <pablo@netfilter.org>,
	Patrick McHardy <kaber@trash.net>,
	Jozsef Kadlecsik <kadlec@blackhole.kfki.hu>,
	coreteam@netfilter.org
To: netfilter-devel@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from cantor2.suse.de ([195.135.220.15]:54922 "EHLO mx2.suse.de"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1753119Ab3IKJJB (ORCPT <rfc822;netdev@vger.kernel.org>);
	Wed, 11 Sep 2013 05:09:01 -0400
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Commit 68b80f11 (netfilter: nf_nat: fix RCU races) introduced
RCU protection for freeing extension data when reallocation
moves them to a new location. We need the same protection when
freeing them in nf_ct_ext_free() in order to prevent a
use-after-free by other threads referencing a NAT extension data
via bysource list.

Signed-off-by: Michal Kubecek <mkubecek@suse.cz>
---
 include/net/netfilter/nf_conntrack_extend.h | 2 +-
 1 file changed, 1 insertion(+), 1 deletion(-)

diff --git a/include/net/netfilter/nf_conntrack_extend.h b/include/net/netfilter/nf_conntrack_extend.h
index 977bc8a..3313108 100644
--- a/include/net/netfilter/nf_conntrack_extend.h
+++ b/include/net/netfilter/nf_conntrack_extend.h
@@ -80,7 +80,7 @@ static inline void nf_ct_ext_destroy(struct nf_conn *ct)
 static inline void nf_ct_ext_free(struct nf_conn *ct)
 {
 	if (ct->ext)
-		kfree(ct->ext);
+		kfree_rcu(ct->ext, rcu);
 }
 
 /* Add this type, returns pointer to data or NULL. */
-- 
1.8.1.4
